# dotfiles-lite

A small set of dotfiles for a Mac where casks are mostly not allowed: zsh, git,
glab, tmux, starship, Ghostty and Claude Code. Files are linked
with GNU Stow, and every command is a recipe in the `justfile`.

## Set up a Mac

This repo is public, so the clone needs no login.

```bash
# 1. The Xcode tools and Homebrew, then the two tools the recipes need
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install just stow

# 2. Clone, install and link
git clone https://github.com/jdragulanescu/dotfiles-lite ~/dotfiles
cd ~/dotfiles
just install   # the Brewfile, zsh plugins, JetBrains Mono Nerd Font, Claude Code
just check     # what link would do
just link

# 3. Your git identity for this machine (never committed)
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "you@work.example"

# 4. A default node for fnm (agents' shells use it; a .nvmrc overrides it)
fnm install --lts
fnm default lts-latest

# 5. Log in to GitLab (it asks for the GitLab host and a token)
glab auth login

# 6. Log in to Claude Code
claude
```

Then restart the terminal. If zsh is not the login shell yet, run
`chsh -s /bin/zsh`.

## Recipes

| Recipe | Does |
| --- | --- |
| `just install` | Install the Brewfile (Claude Code included), fzf-tab and zsh-defer, and the Nerd Font; each one already there is skipped |
| `just link` | Copy each file in `copy/` that is missing in the home, then link `home/` into the home |
| `just check` | Show what `link` would do, changing nothing |
| `just unlink` | Remove the links (the copied files stay) |

Set `DOTFILES_TARGET` to a temporary folder to try `link`, `check` or
`unlink` without touching the real home.

## Where a change goes

| Change | Goes in |
| --- | --- |
| A config file | `home/`, laid out like `$HOME` |
| A file an app rewrites itself (Claude's `settings.json`) | `copy/`, copied once when missing, never linked |
| A secret, or a setting for one machine only | `~/<file>.local` in that machine's home, never committed |
| A tool to install | `Brewfile` (formulae; a cask only when work allows it) |

These files load a `.local` file when it exists, last so it wins:
`.zshrc`, `.aliases`, `.gitconfig`, `.tmux.conf` and Ghostty's `config`.
