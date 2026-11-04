# Global Claude Code Guidelines

- Never attribute work to an AI: no co-author line, "Generated with" footer or
  similar, in commits, PRs, branch names or code comments.
- Use `fd` instead of `find`, and `rg` instead of `grep`.
- Create git worktrees only under `$WORKTREES_DIR/<repo>/<name>`, where `<repo>`
  is the repository's folder name; if `WORKTREES_DIR` is unset, ask where. The
  main checkout's dev server belongs to the user: use it there and leave it
  running, and start servers only in a worktree.
