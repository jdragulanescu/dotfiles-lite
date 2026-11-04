# ============================================
# LOCALE
# ============================================
# Set UTF-8 locale if available, fallback gracefully. One `locale -a`, its
# lines matched in zsh, rather than a locale and grep pair per candidate.
_locales=(${(f)"$(locale -a 2>/dev/null)"})
for _locale in en_US.UTF-8 en_US.utf8 C.UTF-8; do
    if (( ${_locales[(Ie)$_locale]} )); then
        export LANG="$_locale"
        export LC_ALL="$_locale"
        break
    fi
done
unset _locales _locale

# ============================================
# PATH
# ============================================
# Where a command is looked up, first match wins:
#   1. the node fnm picks (VERSION MANAGERS, below)
#   2. ~/.local/bin
#   3. Homebrew
#   4. the system's folders
#   5. the apps' commands: VS Code, OrbStack
# Each is skipped on a machine without it. All of it is here, not in
# ~/.zprofile; an installer that appends a line there can have it moved here.
typeset -U path fpath  # a folder added again keeps its first place

# 3. Homebrew: what `brew shellenv` prints, written out, as running brew costs
# ~20 ms per shell. On an Intel Mac /usr/local/bin is already a system folder.
if [ -x /opt/homebrew/bin/brew ]; then
    export HOMEBREW_PREFIX=/opt/homebrew
    export HOMEBREW_CELLAR=/opt/homebrew/Cellar
    export HOMEBREW_REPOSITORY=/opt/homebrew
    path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
fi

# 2. ~/.local/bin (also in .zshenv; typeset -U keeps one copy)
path=("$HOME/.local/bin" $path)

# 5. The apps' commands, searched last
[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ] && \
    path+=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin")
# OrbStack's own file: adds ~/.orbstack/bin and its completions.
[ -r ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh

# ============================================
# HISTORY
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# ============================================
# COMPLETIONS
# ============================================
# compinit checks every completion file and rewrites its dump on each start;
# -C reuses the dump, so the full check runs only when the dump is a day old.
# A completion installed since then shows up the next day, or after `reload`
# (in ~/.aliases), which runs the full check first.
autoload -Uz compinit
_old_compdump=( ${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24) )
if (( $#_old_compdump )); then
    compinit
else
    compinit -C
fi
unset _old_compdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ============================================
# DEFERRED LOADING
# ============================================
# zsh-defer (`just install` clones it) runs the plugin loads below once the
# first prompt is drawn, so it appears ~25 ms sooner; they keep their order. -dmp: they don't change the prompt, so no chpwd or precmd hooks
# and no prompt redraw after each one. Without zsh-defer they load at once.
[ -f ~/.zsh/zsh-defer/zsh-defer.plugin.zsh ] && source ~/.zsh/zsh-defer/zsh-defer.plugin.zsh
_after_prompt() {
    if (( $+functions[zsh-defer] )); then
        zsh-defer -dmp "$@"
    else
        "$@"
    fi
}

# ============================================
# FZF-TAB (must load AFTER compinit, BEFORE autosuggestions)
# ============================================
# `just install` clones it.
[ -f ~/.zsh/fzf-tab/fzf-tab.plugin.zsh ] && _after_prompt source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh

# Preview directory contents on cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Preview git operations
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --color=always $word'

# Switch groups with < and >
zstyle ':fzf-tab:*' switch-group '<' '>'

# ============================================
# PLUGINS (sourced directly, no framework)
# ============================================
# Sources Homebrew's copy of the plugin $1 (its file $2), when it is installed.
_load_plugin() {
    local file="${HOMEBREW_PREFIX:-/opt/homebrew}/share/$1/$2"
    [ -f "$file" ] && source "$file"
}

# zsh-autosuggestions
_after_prompt _load_plugin "zsh-autosuggestions" "zsh-autosuggestions.zsh"

# zsh-syntax-highlighting
_after_prompt _load_plugin "zsh-syntax-highlighting" "zsh-syntax-highlighting.zsh"

# fzf keybindings (Ctrl-R for history, Ctrl-T for files)
_load_fzf() {
    local dir="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf/shell"
    [ -f "$dir/key-bindings.zsh" ] && source "$dir/key-bindings.zsh"
    [ -f "$dir/completion.zsh" ] && source "$dir/completion.zsh"
}
_after_prompt _load_fzf

# ============================================
# VERSION MANAGERS
# ============================================
# fnm
#
# Switches node on cd to the version a .nvmrc or .node-version names, looking
# up the parent folders too. Not cached: `fnm env` makes a new folder for each
# shell and prints its path. Its node comes before the default one .zshenv
# puts on PATH. FNM_DIR is set in .zshenv.
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --version-file-strategy recursive --shell zsh)"

# ============================================
# TOOLS
# ============================================
# Runs a tool's init command ($2...) once and keeps what it prints in
# ~/.cache/zsh/$1.zsh, so a new shell reads a file instead of starting the
# tool. The cache's first line names the tool's resolved path and the
# command's arguments, and the cache is redone when either changes: a
# Homebrew upgrade moves the tool to a new Cellar folder, and an edit here
# changes the arguments.
_source_cached_init() {
    local bin=${commands[$2]}
    [ -n "$bin" ] || return 0
    local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$1.zsh"
    local key="# ${bin:A} ${(j: :)${(q)@:3}}" first=
    [ -s "$cache" ] && IFS= read -r first <"$cache"
    if [[ $first != "$key" ]]; then
        mkdir -p "${cache:h}"
        { print -r -- "$key"; "${@:2}" } >| "$cache.new" && mv -f "$cache.new" "$cache"
    fi
    [ -s "$cache" ] && source "$cache"
}

_source_cached_init starship-init starship init zsh
# starship.toml has no right_format, so the right prompt is always empty, yet
# starship would still run for it on every prompt.
unset RPROMPT
# A person typing gets zoxide as cd (and cdi). An agent's shell keeps the
# builtin cd: zoxide's cd jumps to a remembered folder when the one named is
# missing, where an agent's `cd src && …` must fail. Agents run commands
# without a terminal, and mark the shells they start, a tmux session they
# drive included: Claude Code sets AI_AGENT; other agents set CLAUDECODE or
# CODEX_THREAD_ID.
_typed_by_a_person() {
    [[ -t 0 && -t 1 && -z $CLAUDECODE$AI_AGENT$CODEX_THREAD_ID ]]
}
if _typed_by_a_person; then
    _source_cached_init zoxide-init-cd zoxide init zsh --cmd cd
    z() { __zoxide_z "$@"; }
    zi() { __zoxide_zi "$@"; }
else
    _source_cached_init zoxide-init zoxide init zsh
fi

# direnv: loads a folder's .envrc on cd, once `direnv allow` trusts it.
_source_cached_init direnv-hook direnv hook zsh

# ============================================
# ALIASES
# ============================================
[ -f ~/.aliases ] && source ~/.aliases

# ============================================
# LOCAL
# ============================================
# This machine's own settings (never committed), last so they win. A missing
# file is skipped.
[ -r ~/.zshrc.local ] && source ~/.zshrc.local
# A skipped include leaves a non-zero status, which the first prompt would
# show as a failed command.
true
