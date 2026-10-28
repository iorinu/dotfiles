# dotfiles
alias dotfiles='git -C $HOME/.dotfiles'

# ディレクトリ構成を浅く表示する。
alias tree='tree -L 2 --gitignore'

# macOSのアプリでもXDG設定ディレクトリを使う。
export XDG_CONFIG_HOME="$HOME/.config"
