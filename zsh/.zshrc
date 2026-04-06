# 当前这套配置以 Linux 为主，不强求跨平台完全一致。
# 后续如果切到别的系统，建议单独维护对应版本，
# 只保持整体结构和主要行为一致。

# 把支持 XDG 的常见工具文件收拢到标准目录，
# 避免在 HOME 根目录散落大量 dot 文件。
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"

# PATH 设置：本地用户命令优先。
typeset -U path PATH
path=(
  "$HOME/.opencode/bin"
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
)
export PATH

# Shell 历史记录：追加写入、去重，并放到状态目录。
HISTSIZE=1000
SAVEHIST=2000
HISTFILE=$XDG_STATE_HOME/zsh/history
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# 如果系统提供 lesspipe，则启用更友好的 less 行为。
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# 终端标题：在支持的终端里显示 user@host:cwd。
if [[ -z "${debian_chroot:-}" && -r /etc/debian_chroot ]]; then
  debian_chroot=$(</etc/debian_chroot)
fi

autoload -Uz add-zsh-hook
case "$TERM" in
  xterm*|rxvt*)
    set_terminal_title() {
      print -Pn "\e]0;${debian_chroot:+($debian_chroot)}%n@%m: %~\a"
    }
    add-zsh-hook precmd set_terminal_title
    ;;
esac

# 启用常见颜色和基础别名。
if [[ -x /usr/bin/dircolors ]]; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [[ -f ~/.bash_aliases ]]; then
  source ~/.bash_aliases
fi

# 补全缓存显式写入 XDG 缓存目录，
# 避免重新生成 ~/.zcompdump。
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Zsh 自动建议插件；缺失时跳过，避免新环境首次启动报错。
if [[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# fnm：Node.js 版本管理器。
# 二进制安装在 XDG 数据目录，环境由 fnm 自己注入。
if [[ -x "$FNM_DIR/fnm" ]]; then
  path=("$FNM_DIR" $path)
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# 提示符交给 starship 管理，避免在 zshrc 里手写复杂 PROMPT。
eval "$(starship init zsh)"
