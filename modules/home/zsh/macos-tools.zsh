# Android開発環境。
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export NDK_HOME="$ANDROID_HOME/ndk/30.0.14904198"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

# zoxideの候補表示を設定する。
export _ZO_FZF_OPTS="--no-sort --keep-right --height=60% --info=inline --layout=reverse --exit-0 --select-1 --bind=ctrl-z:ignore,btab:up,tab:down --preview-window=right,50%,sharp --preview='CLICOLOR_FORCE=1 ls -lhAG {2..}'"
eval "$(zoxide init zsh)"

# macOS用ツールのPATH。
export PATH="$HOME/src/github.com/iorinu/simple-reminder:$PATH"
export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"

# APIキーの値は設定ファイルへ書かず、必要な場合だけKeychainから取得する。
if [[ -z "${TYPESAFE_API_KEY:-}" ]]; then
  export TYPESAFE_API_KEY="$(security find-generic-password -a "$USER" -s "typesafe-api-key" -w 2>/dev/null)"
fi
