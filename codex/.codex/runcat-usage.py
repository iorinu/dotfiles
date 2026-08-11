#!/usr/bin/env python3
"""Codex の ChatGPT 使用量を RunCat Neo 用 JSON に変換する。"""

import json
import os
import select
import shutil
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Optional

OUT = Path(
    os.environ.get("RUNCAT_OUT_FILE", str(Path.home() / ".codex" / "runcat-usage.json"))
)
TIMEOUT_SECONDS = 20


def find_codex() -> str:
    """launchd の最小 PATH でも Codex CLI を見つける。"""
    if codex_bin := os.environ.get("CODEX_BIN"):
        return codex_bin
    if codex_bin := shutil.which("codex"):
        return codex_bin

    # nvm 配下はバージョンごとに Codex CLI が置かれる。
    candidates = sorted(
        (Path.home() / ".nvm" / "versions" / "node").glob("*/bin/codex"),
        key=lambda path: path.parent.parent.name,
        reverse=True,
    )
    if candidates:
        return str(candidates[0])
    raise FileNotFoundError("Codex CLI が見つかりません。CODEX_BIN を設定してください。")


def rpc_request() -> Dict[str, Any]:
    """app-server の JSONL プロトコルから現在の使用量を一度だけ取得する。"""
    codex_bin = find_codex()
    environment = os.environ.copy()
    # nvm 版の codex は shebang から node を探すため、同じ bin を PATH の先頭に置く。
    environment["PATH"] = f"{Path(codex_bin).parent}:{environment.get('PATH', '')}"
    process = subprocess.Popen(
        [codex_bin, "app-server", "--stdio"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        encoding="utf-8",
        bufsize=1,
        env=environment,
    )
    stdin = process.stdin
    stdout = process.stdout
    if stdin is None or stdout is None:
        raise RuntimeError("Codex app-server の標準入出力を開けません")

    def send(message: Dict[str, Any]) -> None:
        stdin.write(json.dumps(message) + "\n")
        stdin.flush()

    def read_response(request_id: int) -> Dict[str, Any]:
        deadline = time.monotonic() + TIMEOUT_SECONDS
        while time.monotonic() < deadline:
            remaining = deadline - time.monotonic()
            readable, _, _ = select.select([stdout], [], [], remaining)
            if not readable:
                break
            line = stdout.readline()
            if not line:
                break
            response = json.loads(line)
            if response.get("id") == request_id:
                if "error" in response:
                    raise RuntimeError(response["error"].get("message", "使用量の取得に失敗しました"))
                return response["result"]
        raise TimeoutError("Codex app-server から使用量の応答がありません")

    try:
        send(
            {
                "method": "initialize",
                "id": 1,
                "params": {
                    "clientInfo": {
                        "name": "runcat-neo",
                        "title": "RunCat Neo",
                        "version": "1.0.0",
                    }
                },
            }
        )
        read_response(1)
        send({"method": "initialized", "params": {}})
        send({"method": "account/rateLimits/read", "id": 2})
        return read_response(2)
    finally:
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                process.kill()


def duration_label(minutes: Optional[int], index: int) -> str:
    """ウィンドウ時間をメニューバーに収まる短い表示へ変換する。"""
    if not minutes:
        return f"Limit {index}"
    if minutes % (24 * 60) == 0:
        return f"{minutes // (24 * 60)}d"
    if minutes % 60 == 0:
        return f"{minutes // 60}h"
    return f"{minutes}m"


def metric(window: Optional[Dict[str, Any]], index: int) -> Optional[Dict[str, Any]]:
    if not window or (used_percent := window.get("usedPercent")) is None:
        return None
    return {
        "title": duration_label(window.get("windowDurationMins"), index),
        "formattedValue": f"{used_percent:g}%",
        "normalizedValue": round(used_percent / 100, 4),
    }


def snapshot(rate_limits: Dict[str, Any]) -> Dict[str, Any]:
    primary = rate_limits.get("primary")
    secondary = rate_limits.get("secondary")
    metrics = [
        {"title": "Service", "formattedValue": "Codex"},
        metric(primary, 1),
        metric(secondary, 2),
    ]
    result = {
        "title": "Codex",
        "symbol": "terminal",
        "metrics": [item for item in metrics if item is not None],
        "lastUpdatedDate": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    if primary and (used_percent := primary.get("usedPercent")) is not None:
        result["metricsBarValue"] = f"{used_percent:g}%"
    return result


def write_snapshot(data: Dict[str, Any]) -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".runcat-", dir=str(OUT.parent))
    with os.fdopen(fd, "w", encoding="utf-8") as file:
        json.dump(data, file, ensure_ascii=False)
    os.replace(tmp, OUT)


def main() -> int:
    try:
        response = rpc_request()
        write_snapshot(snapshot(response["rateLimits"]))
    except (FileNotFoundError, KeyError, OSError, RuntimeError, TimeoutError, json.JSONDecodeError) as error:
        print(f"runcat-usage: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
