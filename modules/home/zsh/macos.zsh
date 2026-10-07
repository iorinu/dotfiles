# Home Managerが参照するmacOS用エントリポイント。リポジトリの実パスを明示する。
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# NixのコマンドをHomebrewやシステムのコマンドより優先する。
nix_bins=()
for nix_bin in "$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin; do
  [[ -d "$nix_bin" ]] && nix_bins+=("$nix_bin")
done
path=("${nix_bins[@]}" $path)

source /Users/iori/.dotfiles/modules/home/zsh/common-early.zsh
source /Users/iori/.dotfiles/modules/home/zsh/macos-environment.zsh
source /Users/iori/.dotfiles/modules/home/zsh/common-late.zsh
source /Users/iori/.dotfiles/modules/home/zsh/macos-tools.zsh
