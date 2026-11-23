# What the work Mac installs: formulae, and only the one cask work allows
# (claude-code). `just install` runs it.

# Shell and prompt
brew "starship"                   # Shell prompt
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "tmux"                       # Terminal multiplexer

# This repo
brew "stow"                       # Links home/ into $HOME
brew "just"                       # Runs the recipes in the justfile

# Git
brew "glab"                       # GitLab CLI
brew "lazygit"                    # Git TUI
brew "git-delta"                  # Better git diff

# Modern CLI replacements
brew "bat"                        # Better cat
brew "eza"                        # Better ls
brew "fd"                         # Better find
brew "fzf"                        # Fuzzy finder
brew "ripgrep"                    # Better grep
brew "zoxide"                     # Smarter cd
brew "jq"                         # JSON processor (also the Claude status line)
brew "yq"                         # YAML processor
brew "tree"                       # Folder tree
brew "glow"                       # Markdown reader
brew "btop"                       # System monitor

# Per-project tools
brew "fnm"                        # Node version manager (switches on cd)
brew "direnv"                     # Loads a folder's .envrc on cd

# Agents
cask "claude-code"                # Claude Code CLI
brew "herdr"                      # Agent multiplexer

# Work workflow (the skills in home/.claude/skills)
tap "atlassian/homebrew-acli"
brew "atlassian/homebrew-acli/acli" # Jira Cloud CLI; for a self-hosted Jira, brew install jira-cli
brew "agent-browser"              # Drives a browser for walkthroughs and videos
brew "ffmpeg"                     # Joins the before and after videos
