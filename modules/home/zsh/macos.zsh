# Home Managerが参照するmacOS用エントリポイント。リポジトリの実パスを明示する。
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

source /Users/iori/.dotfiles/modules/home/zsh/common-early.zsh
source /Users/iori/.dotfiles/modules/home/zsh/macos-environment.zsh
source /Users/iori/.dotfiles/modules/home/zsh/common-late.zsh
source /Users/iori/.dotfiles/modules/home/zsh/macos-tools.zsh
