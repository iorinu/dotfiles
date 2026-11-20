export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

. "$HOME/.local/bin/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PATH="/Library/TeX/texbin:$PATH"

# GoのユーザーツールをPATHに追加する。
export PATH="$HOME/go/bin:$PATH"

# macOS上のHermesが使うcua-driverの実行ファイルを指定する。
export HERMES_CUA_DRIVER_CMD="/Applications/CuaDriver.app/Contents/MacOS/cua-driver"
