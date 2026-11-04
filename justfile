# Every command in this repo is a recipe here. `just` lists them.

# Where the files go. Set DOTFILES_TARGET to a temporary folder to try a
# recipe without touching the real home.
target := env("DOTFILES_TARGET", env("HOME"))

# --no-folding links each file, never a whole folder, so an app that writes
# into ~/.config or ~/.claude writes into the home, not into this repo.
stow := "stow --no-folding --ignore='(^|/)\\.DS_Store' -d '" + justfile_directory() + "' -t '" + target + "'"

# List every recipe
default:
    @just --justfile "{{ justfile() }}" --list

# Install the Brewfile (Claude Code included), the zsh plugins and the Nerd Font. Each one already there is skipped.
[script("bash")]
install:
    set -euo pipefail
    brew bundle --no-upgrade --file "{{ justfile_directory() }}/Brewfile"
    clone() { [ -d "$2" ] || git clone --depth 1 "$1" "$2"; }
    clone https://github.com/Aloxaf/fzf-tab "{{ target }}/.zsh/fzf-tab"
    clone https://github.com/romkatv/zsh-defer "{{ target }}/.zsh/zsh-defer"
    fonts="{{ target }}/Library/Fonts"
    if ! ls "$fonts"/JetBrainsMonoNerdFont-*.ttf >/dev/null 2>&1; then
        tmp=$(mktemp -d "${TMPDIR:-/tmp}/nerd-font.XXXXXX")
        curl -fLsS -o "$tmp/JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -oq "$tmp/JetBrainsMono.zip" -d "$tmp"
        mkdir -p "$fonts"
        cp "$tmp"/JetBrainsMonoNerdFont-*.ttf "$fonts/"
        rm -r "$tmp"
    fi

# Link home/ into the home, after copying each copy/ file that is missing there
[script("bash")]
link:
    set -euo pipefail
    cd "{{ justfile_directory() }}/copy"
    # An app rewrites these files itself, so each is copied once, never linked.
    fd -H -t f . | while IFS= read -r file; do
        if [ ! -e "{{ target }}/$file" ]; then
            mkdir -p "$(dirname "{{ target }}/$file")"
            cp "$file" "{{ target }}/$file"
            echo "copied $file"
        fi
    done
    mkdir -p "{{ target }}/dev" "{{ target }}/workspaces/worktrees"
    {{ stow }} -v home

# Show what link would do, changing nothing
check:
    {{ stow }} -n -v home

# Remove every link that link made (the copied files stay)
unlink:
    {{ stow }} -v -D home
