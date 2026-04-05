#!/usr/bin/env bash

set -euo pipefail

# 用法：从 dotfiles-linux 仓库根目录或任意位置执行都可以。
# 功能：备份当前本机配置，并建立指向仓库文件的符号链接。

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_ROOT="$HOME/.local/state/dotfiles-linux-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
BACKUP_CREATED=0

link_file() {
  local source_file="$1"
  local target_file="$2"

  mkdir -p "$(dirname "$target_file")"

  if [[ -L "$target_file" && "$(readlink "$target_file")" == "$source_file" ]]; then
    printf 'Already linked: %s -> %s\n' "$target_file" "$source_file"
    return
  fi

  if [[ -e "$target_file" || -L "$target_file" ]]; then
    if [[ "$BACKUP_CREATED" -eq 0 ]]; then
      mkdir -p "$BACKUP_DIR"
      BACKUP_CREATED=1
    fi

    mkdir -p "$BACKUP_DIR$(dirname "$target_file")"
    cp -a "$target_file" "$BACKUP_DIR$target_file"
    printf 'Backed up: %s\n' "$target_file"

    rm -f "$target_file"
  fi

  ln -s "$source_file" "$target_file"
  printf 'Linked: %s -> %s\n' "$target_file" "$source_file"
}

main() {
  link_file "$REPO_ROOT/zsh/.zshenv" "$HOME/.zshenv"
  link_file "$REPO_ROOT/zsh/.zshrc" "$HOME/.zshrc"
  link_file "$REPO_ROOT/config/starship.toml" "$HOME/.config/starship.toml"
  link_file "$REPO_ROOT/config/npm/npmrc" "$HOME/.config/npm/npmrc"

  if [[ "$BACKUP_CREATED" -eq 1 ]]; then
    printf '\nBackup saved to: %s\n' "$BACKUP_DIR"
  else
    printf '\nNo existing files needed backup.\n'
  fi

  printf 'Open a new zsh session or run: source ~/.zshenv && source ~/.zshrc\n'
}

main "$@"
