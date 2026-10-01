# AGENTS.md

## プロジェクト概要

このリポジトリは macOS と WSL Ubuntu 向けの dotfiles を管理します。
設定の配置には GNU Stow と Nix/Home Manager を使い、移行済みパスはHome Managerだけが所有します。

## 基本方針

- 変更は依頼された範囲に限定する。
- 既存の設定ファイルの書式・命名規則に合わせる。
- 秘密鍵、トークン、`.env` などの認証情報は読み書き・コミットしない。
- 破壊的な操作（削除、上書き、`git reset --hard` など）は、実行前に確認する。
- 外部サービスへの送信、公開、デプロイは明示的な依頼がある場合だけ行う。
- Home ManagerとStowで同じ配置先を同時に管理しない。移行対象パッケージはStowで再適用しない。
- Home Managerの適用（switch/activate）、Stowの実適用、ライブファイルの変更は、事前確認とユーザー承認なしに行わない。
- 旧ソースはWSLや他のStow利用者、復旧のため保持し、明示的な依頼なしに削除しない。

## dotfiles の変更方法

1. 変更対象のパッケージ、配置先の所有者、既存ファイルを確認する。
2. 必要なファイルだけを編集する。
3. Home Manager設定はFlake checkと対象構成の評価・ビルドで検証し、Stow対象はGNU Stowのdry-runで検証する。実行前にコマンドがライブ環境を変更しないことを確認する。

```sh
stow --simulate --verbose <package>
```

移行対象のStowパッケージには削除・再適用を行わない。Stowの削除simulationが無関係なリンクを扱う場合も実行しない。

4. 問題がなければ、手順と差分を提示し、ユーザーの許可を得てから適用する。

```sh
stow --restow <package>
```

## 検証

変更後は、少なくとも次を確認する。

```sh
git diff --check
git diff
git status --short
```

シェル設定を変更した場合は、該当シェルの構文チェックも実行する。

```sh
zsh -n path/to/file.zsh
```

Home Manager設定を変更した場合は、次の非適用検証を行う。`nix build`はactivation packageをビルドするだけで、Home Managerを適用せず、`--no-link`によりリポジトリ内に`result`リンクを作らない。switch/build結果やライブ状態を未確認のまま適用済みと記載しない。macOS構成名の例は`iori@macos`。

```sh
nix flake check --no-write-lock-file
nix build ".#homeConfigurations.\"<configuration>\".activationPackage" --no-link --no-write-lock-file
```

`nix build`は`--no-link`を付けることでrepo内にresultリンクを作らない。

## Git

- コミット前に差分を確認する。
- コミットメッセージは英語で書く。
- `push` の依頼は、特別な指示がなければコミット作成後に push する。
- 依頼に含まれない変更はコミットしない。
- Git commitはユーザーが明示的に依頼した場合だけ行う。

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: `npx openskills read <skill-name>` (run in your shell)
  - For multiple: `npx openskills read skill-one,skill-two`
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>natural-japanese</name>
<description>仕事の日本語文書を読みやすくわかりやすく書く・直すためのスキル。議事録（文字起こしからの議事録化を含む）、調査レポート・分析レポート、社内ガイド・マニュアル、リサーチメモ・ディスカッションペーパー・企画書・提案書・報告書・メール、スライド構成案といったビジネス文書の作成・校正、「結論から書いて」「論旨を明確に」「見出しを端的に」「専門用語をわかりやすく説明して」といった指示のいずれでも使用する。AI臭さの除去（「AIっぽい」「AI臭い」「機械翻訳っぽい」「不自然」「もっと自然な日本語に」「機械っぽい」「人間っぽくして」「単調」「〜することができる、と言えるだろう、のような言い回し」といった直接・間接・口語の指摘、AIで書いたと言われた/疑われた）、読みにくい・わかりにくい文章の改善依頼（語順がおかしい、一文が長い、何が言いたいか分からない、読点の位置がおかしい等）、note記事やブログ記事・エッセイの新規執筆（任意のテーマをゼロから書く・書き起こす依頼を含む）、既存文章のリライト・推敲、AI臭さの診断・採点（「この文章AIが書いた？」「AI臭さをスコアで出して」「どれくらいAIっぽいか判定して」という書き換えを伴わない依頼）、自分の文体を学ばせたい・プロファイル化したいという要望（過去の文章を読ませて自分らしく書いてほしいという依頼も含む）にも対応する。禁止語の除去、リズムの単調さ・段落構造の均質さ・英語統語の直訳調に加え、語順・読点・一文一義・主語述語の距離といった読みやすさの原則にも対応する。技術文書の章構成やMarkdownフォーマットの整形自体（一文一行化・引用ブロック・脚注記法など）は対象外——それは別スキルの領域であり、本スキルは文章の自然さ・読みやすさ・わかりやすさに特化する。</description>
<location>project</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
