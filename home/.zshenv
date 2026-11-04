# Read by every zsh, including the non-interactive shells agents run commands in.

# Where git worktrees live: $WORKTREES_DIR/<repo>/<name>. Agents and scripts
# read this instead of choosing a location themselves.
export WORKTREES_DIR="$HOME/workspaces/worktrees"

# ~/.local/bin holds your own scripts. Here, not only in
# .zshrc, so a non-interactive zsh (an agent's command) finds them too.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# fnm keeps its node versions here; `fnm default <version>` picks the default.
# That default goes on PATH here, so a non-interactive zsh (an agent's command)
# finds node and npx with no `fnm env`, which would make a new folder each time.
# An interactive shell's fnm env (in .zshrc) puts its own node first.
export FNM_DIR="$HOME/.local/share/fnm"
case ":$PATH:" in
    *":$FNM_DIR/aliases/default/bin:"*) ;;
    *) [ -d "$FNM_DIR/aliases/default/bin" ] && export PATH="$FNM_DIR/aliases/default/bin:$PATH" ;;
esac
