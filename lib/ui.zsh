#!/bin/zsh
# Minimal dependency-free terminal menu for zsh.

readonly UI_RESET=$'\033[0m'
readonly UI_BOLD=$'\033[1m'
readonly UI_DIM=$'\033[2m'
readonly UI_CYAN=$'\033[38;5;81m'
readonly UI_MINT=$'\033[38;5;120m'
readonly UI_PURPLE=$'\033[38;5;141m'
readonly UI_MUTED=$'\033[38;5;245m'
readonly UI_SELECTED=$'\033[48;5;24m\033[38;5;255m\033[1m'

menu_select() {
  local title="$1"
  shift
  local -a options=("$@")
  local selected=1 key sequence index marker

  while true; do
    printf '\033[2J\033[H'
    printf '\n'
    printf "  ${UI_PURPLE}${UI_BOLD}╭──────────────────────────────────────────────────╮${UI_RESET}\n"
    printf "  ${UI_PURPLE}${UI_BOLD}│${UI_RESET}  ${UI_CYAN}${UI_BOLD}Terminal Setup Backup${UI_RESET}                              ${UI_PURPLE}${UI_BOLD}│${UI_RESET}\n"
    printf "  ${UI_PURPLE}${UI_BOLD}╰──────────────────────────────────────────────────╯${UI_RESET}\n\n"
    printf "  ${UI_BOLD}%s${UI_RESET}\n" "$title"
    printf "  ${UI_MUTED}────────────────────────────────────────────────────${UI_RESET}\n\n"

    for index in {1..${#options}}; do
      if (( index == selected )); then
        printf "  ${UI_SELECTED}  ❯  %-45s  ${UI_RESET}\n" "${options[index]}"
      else
        printf "  ${UI_MUTED}     %-45s${UI_RESET}\n" "${options[index]}"
      fi
    done

    printf "\n  ${UI_MINT}↑/↓${UI_RESET}${UI_MUTED} Navigate   ${UI_MINT}Enter${UI_RESET}${UI_MUTED} Select   ${UI_MINT}j/k${UI_RESET}${UI_MUTED} Also works${UI_RESET}\n"
    read -rsnk1 key

    if [[ "$key" == $'\e' ]]; then
      read -rsnk2 sequence
      key="$key$sequence"
    fi

    case "$key" in
      $'\e[A'|k) (( selected = selected > 1 ? selected - 1 : ${#options} )) ;;
      $'\e[B'|j) (( selected = selected < ${#options} ? selected + 1 : 1 )) ;;
      $'\n'|$'\r'|'')
        MENU_SELECTION=$selected
        printf '\033[2J\033[H'
        return 0
        ;;
    esac
  done
}

wait_for_key() {
  printf '\n\033[2mPress any key to return to the main menu.\033[0m'
  read -rsnk1
}
