#!/bin/zsh
# Restore a snapshot created by backup-terminal.sh.
set -euo pipefail

script_dir="${0:A:h}"
default_root="$script_dir/snapshots"
source "$script_dir/lib/ui.zsh"

usage() {
  cat <<'EOF'
Usage: restore-terminal.sh [snapshot] [--config|--packages|--all]

--config    Restore Fish and iTerm2 preferences only.
--packages  Reinstall Homebrew packages from Brewfile-all only.
--all       Perform both actions.

With no arguments, an interactive menu selects the snapshot and action.
EOF
}

require_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Install it first at https://brew.sh, then run this script again." >&2
    exit 1
  fi
}

validate_snapshot() {
  if [[ ! -d "$snapshot" ]]; then
    echo "Invalid snapshot: $snapshot" >&2
    exit 1
  fi
}

choose_snapshot() {
  local -a snapshots options
  local index
  snapshots=("$default_root"/terminal-*(N/))
  if (( ${#snapshots} == 0 )); then
    echo "No snapshots found in $default_root" >&2
    return 1
  fi

  options=("${snapshots[@]:t}" "Back to main menu")
  menu_select "Select a snapshot" "${options[@]}"
  index=$MENU_SELECTION
  if (( index == ${#options} )); then
    return 1
  fi
  snapshot="${snapshots[index]}"
}

choose_action() {
  menu_select "Restore $(basename "$snapshot")" \
    "Restore terminal configuration" \
    "Install Homebrew packages" \
    "Restore configuration and packages" \
    "Back to main menu"

  case "$MENU_SELECTION" in
    1) action="config" ;;
    2) action="packages" ;;
    3) action="all" ;;
    4) return 1 ;;
  esac
}

restore_config() {
  require_brew
  brew list --cask iterm2 >/dev/null 2>&1 || brew install --cask iterm2
  brew list fish >/dev/null 2>&1 || brew install fish

  if [[ -d "$snapshot/config" ]]; then
    (cd "$snapshot/config" && tar -cf - .) | (cd "$HOME" && tar -xf -)
  fi

  # Quit iTerm2 before this step so imported settings win.
  if [[ -f "$snapshot/iTerm2-preferences.plist" ]]; then
    defaults import com.googlecode.iterm2 "$snapshot/iTerm2-preferences.plist"
  fi

  echo "Configuration restored. Close and reopen iTerm2."
  echo "To make Fish your default shell: chsh -s \"$(command -v fish)\""
}

restore_packages() {
  require_brew
  local brewfile="$snapshot/Brewfile-all"
  if [[ ! -f "$brewfile" ]]; then
    echo "This snapshot has no Brewfile-all, so there are no packages to install." >&2
    return
  fi
  echo "Installing packages listed in: $brewfile"
  brew bundle --file="$brewfile"
}

snapshot=""
action=""
for argument in "$@"; do
  case "$argument" in
    --help|-h) usage; exit 0 ;;
    --config|--packages|--all) action="${argument#--}" ;;
    *)
      if [[ -n "$snapshot" ]]; then
        usage >&2
        exit 1
      fi
      snapshot="$argument"
      ;;
  esac
done

if [[ -z "$snapshot" ]]; then
  if [[ -t 0 ]]; then
    choose_snapshot || exit 0
  else
    usage >&2
    exit 1
  fi
fi
validate_snapshot

if [[ -z "$action" ]]; then
  if [[ -t 0 ]]; then
    choose_action || exit 0
  else
    action="all"
  fi
fi

case "$action" in
  config) restore_config ;;
  packages) restore_packages ;;
  all)
    restore_config
    restore_packages
    ;;
  *) usage >&2; exit 1 ;;
esac
