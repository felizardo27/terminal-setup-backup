# Terminal Setup Backup

A small, dependency-free macOS utility for backing up and restoring a terminal
environment. It captures shell and terminal preferences in a local snapshot,
then records installed Homebrew packages in a `Brewfile`.

The project is intentionally generic: a snapshot contains the aliases, prompt,
terminal preferences, and package list belonging to the user who created it.
This repository does not impose a default shell configuration or package set.

## Features

- Keyboard-first interactive menu: arrow keys or `j`/`k`, then Enter.
- Create timestamped snapshots of Fish, Starship, tmux, Zsh, and iTerm2
  settings when they exist.
- Restore configuration only, Homebrew packages only, or both.
- Run every action non-interactively for scripting or automation.
- Keep snapshots out of Git by default.

## Privacy and security

The backup script excludes SSH directories, shell history, Keychain data,
browser data, Wi-Fi settings, Docker credentials, `.env` files, and common
private-key/certificate file types.

This is a safeguard, not a guarantee that a snapshot contains no sensitive
information. Application configuration can still include personal paths or
service-specific values. Review a snapshot before sharing it.

**Never commit or publish `snapshots/`.** They are ignored by `.gitignore` and
should be stored separately in encrypted external storage or a trusted cloud
provider.

## Requirements

- macOS
- `zsh` (included with macOS)
- [Homebrew](https://brew.sh) only when restoring applications

## Quick start

Clone or download this project, then run the main menu:

```zsh
cd Terminal-Setup-Backup
zsh ./terminal-setup.sh
```

Use ↑/↓ or `j`/`k` to move, and Enter to select. The menu exits only when you
select **Exit**. Backup and restore submenus include **Back to main menu**.

## Create a backup

From the menu, select **Create a backup snapshot**. Or run it directly:

```zsh
zsh ./backup-terminal.sh --create
```

Snapshots are written next to the scripts:

```text
snapshots/terminal-YYYY-MM-DD_HH-MM-SS
```

List the available snapshots with:

```zsh
zsh ./backup-terminal.sh --list
```

Copy the full project directory, including the `snapshots` directory, to secure
external storage before erasing or replacing a Mac.

## Restore on a new Mac

1. Install Homebrew using the official instructions at
   [brew.sh](https://brew.sh).
2. Copy this project and the desired snapshot onto the new Mac.
3. Open Terminal in the project directory and run:

   ```zsh
   zsh ./terminal-setup.sh
   ```

4. Select **Restore a snapshot**, choose the snapshot, then select one action:
   - **Restore terminal configuration** installs Fish and iTerm2 if needed,
     restores shell configuration, and imports iTerm2 preferences.
   - **Install Homebrew packages** runs `brew bundle` against the snapshot's
     `Brewfile-all`.
   - **Restore configuration and packages** performs both operations.

Review `Brewfile-all` before installing packages, especially if the snapshot
came from another person or machine.

To use Fish as the default shell after restoring it:

```zsh
chsh -s "$(command -v fish)"
```

Close and reopen the terminal afterward.

## Command-line usage

The individual scripts are also usable without the interactive menu:

```zsh
# Create a snapshot
zsh ./backup-terminal.sh --create

# Restore both configuration and packages from a known snapshot
zsh ./restore-terminal.sh ./snapshots/terminal-YYYY-MM-DD_HH-MM-SS --all

# Restore only configuration or only packages
zsh ./restore-terminal.sh ./snapshots/terminal-YYYY-MM-DD_HH-MM-SS --config
zsh ./restore-terminal.sh ./snapshots/terminal-YYYY-MM-DD_HH-MM-SS --packages
```

Run any script with `--help` for its available options.

## Publishing this project on GitHub

The scripts, documentation, UI helper, and license are appropriate for a
public repository. Before committing, verify exactly what will be included:

```zsh
git status
```

Only commit the project source. Do not override `.gitignore` to add snapshots
or personal configuration files.

## Scope

This project restores a terminal environment; it is not a complete Mac backup.
It does not restore Apple accounts, passwords, SSH keys, access tokens,
repositories, personal files, or application data. Create fresh SSH keys and
new service sessions on a restored Mac.

## License

Released under the [MIT License](LICENSE).
# terminal-setup-backup
