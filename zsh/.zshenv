# Zsh 启动最早读取的文件。
# 这里只放必须尽早生效的环境变量，避免放交互逻辑。

# Ubuntu 会在全局 zshrc 里自动执行 compinit，
# 这会把 zcompdump 写到 HOME 目录。
# 提前设置这个变量后，改由 ~/.zshrc 手动初始化补全，
# 这样就能把缓存收拢到 XDG 目录。
skip_global_compinit=1

# XDG 基础目录：尽量把配置、缓存、数据、状态文件
# 从 HOME 根目录收拢到标准位置。
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# fnm 数据目录。
# 使用 XDG 数据目录，避免在 HOME 根目录生成 ~/.fnm。
export FNM_DIR="$XDG_DATA_HOME/fnm"

# wget HSTS 状态文件。
# 收拢到 XDG 状态目录，避免在 HOME 根目录生成 ~/.wget-hsts。
export WGETHSTS="$XDG_STATE_HOME/wget-hsts"
