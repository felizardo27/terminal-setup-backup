#!/bin/zsh
# Main interactive entry point for Terminal Setup Backup.
set -euo pipefail

script_dir="${0:A:h}"
source "$script_dir/lib/ui.zsh"

while true; do
  menu_select "Terminal Setup Backup" \
    "Create a backup snapshot" \
    "Restore a snapshot" \
    "List available snapshots" \
    "Exit"

  case "$MENU_SELECTION" in
    1)
      zsh "$script_dir/backup-terminal.sh" --create
      wait_for_key
      ;;
    2)
      zsh "$script_dir/restore-terminal.sh"
      wait_for_key
      ;;
    3)
      zsh "$script_dir/backup-terminal.sh" --list
      wait_for_key
      ;;
    4)
      printf '\033[2J\033[H'
      exit 0
      ;;
  esac
done
