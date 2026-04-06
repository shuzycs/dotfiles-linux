#!/usr/bin/env bash

set -euo pipefail

# 用法：在 Linux 新环境中执行，安装当前 shell 配置依赖的基础工具。
# 当前优先支持 Debian / Ubuntu。

if [[ "$(uname -s)" != "Linux" ]]; then
  printf 'This init script only supports Linux.\n' >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  printf 'Only Debian/Ubuntu apt is supported right now.\n' >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  printf 'sudo is required for package installation.\n' >&2
  exit 1
fi

PACKAGES=(
  zsh
  git
  curl
  less
)

install_starship() {
  if command -v starship >/dev/null 2>&1; then
    printf 'starship is already installed.\n'
    return
  fi

  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
}

install_zsh_autosuggestions() {
  local target_dir="$HOME/.local/share/zsh/zsh-autosuggestions"
  local legacy_dir="$HOME/.zsh/zsh-autosuggestions"

  if [[ -d "$target_dir/.git" ]]; then
    printf 'zsh-autosuggestions is already installed.\n'
    return
  fi

  mkdir -p "$(dirname "$target_dir")"

  if [[ -d "$legacy_dir/.git" ]]; then
    mv "$legacy_dir" "$target_dir"
    printf 'Moved zsh-autosuggestions to: %s\n' "$target_dir"
    return
  fi

  git clone https://github.com/zsh-users/zsh-autosuggestions "$target_dir"
}

main() {
  sudo apt-get update
  sudo apt-get install -y "${PACKAGES[@]}"

  install_starship
  install_zsh_autosuggestions

  mkdir -p \
    "$HOME/.config" \
    "$HOME/.cache/zsh" \
    "$HOME/.cache/npm" \
    "$HOME/.local/share/zsh" \
    "$HOME/.local/state/zsh" \
    "$HOME/.local/state/less" \
    "$HOME/.local/state/python" \
    "$HOME/workspace"

  printf '\nLinux initialization completed.\n'
  printf 'Next step: run ./scripts/restore.sh to create symlinks from your home directory to the repository files.\n'
}

main "$@"
