# カスタム補完をOh My Zshのcompinitより前に登録する。
fpath=(~/.zfunc $fpath)

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git copypath colorize history)
ZSH_COLORIZE_TOOL=pygmentize
source $ZSH/oh-my-zsh.sh

# ghqのリポジトリをpecoで選択するウィジェット。
function peco-src () {
  local selected_dir=$(ghq list -p | peco --prompt="repositories >" --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^Xj' peco-src

eval "$(sheldon source)"

export ZENO_HOME=~/.config/zeno
export ZENO_GIT_CAT="bat --color=always"
export FZF_DEFAULT_OPTS='--layout=reverse'

if [[ -n $ZENO_LOADED ]]; then
  bindkey ' '  zeno-auto-snippet
  bindkey '^m' zeno-auto-snippet-and-accept-line
  bindkey '^i' zeno-completion
  bindkey '^xx' zeno-insert-snippet
  bindkey '^x '  zeno-insert-space
  bindkey '^x^m' accept-line
  bindkey '^x^z' zeno-toggle-auto-snippet
  bindkey '^xp' zeno-preprompt
  bindkey '^xs' zeno-preprompt-snippet
  bindkey '^r' zeno-smart-history-selection
fi

# URLからタイトルを取得するノート追加関数。
function nba() {
  if [ $# -lt 1 ]; then
    echo "Usage: nba <url>           # Auto-fetch title"
    echo "       nba <title> <url>   # Manual title"
    return 1
  fi

  local title=""
  local url=""
  if [ $# -eq 1 ]; then
    url="$1"
    echo "Fetching title from: $url"
    title=$(curl -sL --max-redirs 3 --max-time 5 --compressed "$url" | head -c 512 | perl -0777 -ne 'print $1 if /<title[^>]*>([^<]+)<\/title>/i')
    title=$(echo "$title" | perl -pe 's/^\s+|\s+$//g; s/\s+/ /g')
    if [ -z "$title" ]; then
      echo "Error: Could not fetch title from URL"
      return 1
    fi
    echo "Title: $title"
  else
    title="$1"
    url="$2"
  fi

  local content="# ${title}

参照: [${title}](${url})"
  nb add --filename "${title}.md" --content "$content"
  echo "Note created: [${title}](${url})"
}

# nb検索結果をfzfで選択する関数。
function nbq() {
  if [ -z "$1" ]; then
    echo "Usage: nbq <search query>"
    return 1
  fi
  local query="$*"
  local results=$(nb q "$query" --no-color 2>/dev/null | grep -E '^\[[0-9]+\]')
  if [ -z "$results" ]; then
    echo "No results found for: $query"
    return 1
  fi
  export _NBQ_QUERY="$query"
  local selected=$(echo "$results" | fzf --ansi \
    --preview 'note_id=$(echo {} | sed -E "s/^\[([0-9]+)\].*/\1/")
               echo "=== Note [$note_id] ==="
               echo ""
               nb show "$note_id" | head -5
               echo ""
               echo "=== Matching lines ==="
               echo ""
               nb show "$note_id" | grep -i --color=always -C 2 "$_NBQ_QUERY" | head -30' \
    --preview-window=right:60%:wrap \
    --header "Search: $query")
  unset _NBQ_QUERY
  if [ -n "$selected" ]; then
    local note_id=$(echo "$selected" | sed -E 's/^\[([0-9]+)\].*/\1/')
    nb edit "$note_id"
  fi
}

export BOUNDARY_ADDR=https://prosec.enpit.jais.co:9200
