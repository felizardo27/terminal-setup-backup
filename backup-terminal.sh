#!/bin/zsh
# Create a portable terminal-setup snapshot for the current macOS user.
set -euo pipefail

script_dir="${0:A:h}"
default_root="$script_dir/snapshots"

usage() {
  cat <<'EOF'
Usage: backup-terminal.sh [--create] [--list] [destination]

Creates a local snapshot of terminal preferences. Snapshots are intentionally
ignored by Git and should be reviewed before sharing.
EOF
}

list_snapshots() {
  if [[ -d "$default_root" ]]; then
    print -l "$default_root"/terminal-*(N/)
  else
    echo "No snapshots have been created yet."
  fi
}

copy_path() {
  local source="$1"
  local relative="${source#$HOME/}"
  if [[ -e "$source" ]]; then
    # tar avoids an rsync socket incompatibility on recent macOS releases.
    (cd "$HOME" && tar --exclude='fish_history' --exclude='*.history' --exclude='.DS_Store' --exclude='.env' --exclude='*.pem' --exclude='*.key' --exclude='*.p12' -cf - "$relative") | (cd "$snapshot/config" && tar -xf -)
  fi
}

create_snapshot() {
  local backup_root="${1:-$default_root}"
  local stamp
  stamp="$(date +%Y-%m-%d_%H-%M-%S)"
  snapshot="$backup_root/terminal-$stamp"
  mkdir -p "$snapshot/config"
  chmod 700 "$snapshot"

  # Shell and prompt configuration. Histories are deliberately excluded.
  copy_path "$HOME/.config/fish"
  copy_path "$HOME/.config/starship.toml"
  copy_path "$HOME/.config/iterm2"
  copy_path "$HOME/.tmux.conf"
  copy_path "$HOME/.config/tmux"
  copy_path "$HOME/.zshrc"
  copy_path "$HOME/.zprofile"
  copy_path "$HOME/.p10k.zsh"

  # iTerm2 stores most profiles and settings in its preferences domain.
  if defaults export com.googlecode.iterm2 "$snapshot/iTerm2-preferences.plist" 2>/dev/null; then
    :
  else
    rm -f "$snapshot/iTerm2-preferences.plist"
  fi

  if command -v brew >/dev/null 2>&1; then
    brew bundle dump --file="$snapshot/Brewfile-all" --force --describe >/dev/null
    brew list --formula > "$snapshot/homebrew-formulae.txt"
    brew list --cask > "$snapshot/homebrew-casks.txt"
  fi

  {
    echo "Created: $(date -Iseconds)"
    echo "macOS: $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
    echo "Default shell: $(dscl . -read /Users/"$USER" UserShell 2>/dev/null | awk '{print $2}')"
    command -v fish >/dev/null 2>&1 && fish --version
    command -v starship >/dev/null 2>&1 && starship --version
    command -v brew >/dev/null 2>&1 && brew --version | head -n 1
    echo
    echo "Excluded: SSH directory, shell histories, Keychain, browser data, Wi-Fi settings, .env files, Docker credentials, and common private-key files."
    echo "Review this snapshot before sharing it; application settings can still contain personal paths or service-specific values."
  } > "$snapshot/README.txt"

  printf 'Backup created at:\n%s\n\nReview it and copy it to secure external storage before erasing or replacing this Mac.\n' "$snapshot"
}

case "${1:-}" in
  --help|-h) usage ;;
  --list) list_snapshots ;;
  --create) create_snapshot "${2:-$default_root}" ;;
  "") create_snapshot "$default_root" ;;
  *) create_snapshot "$1" ;;
esac
