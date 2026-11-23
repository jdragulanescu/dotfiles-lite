# GitLab

GitLab holds the code and the MRs. Use `glab`, run inside the repo's clone or worktree.

- **Group**: <group path>

| Need | Command |
| --- | --- |
| Log in | `glab auth login` |
| List the group's repos | `glab repo list -g <group> --per-page 100` |
| Create a repo | `glab repo create <group>/<name> --private` |
| Open an MR | `glab mr create --source-branch <branch> --target-branch <default> --title '<KEY>: <title>' --description "$(cat <file>)" --remove-source-branch --yes` |
| Read an MR | `glab mr view <iid> --comments` |
| An MR's diff | `glab mr diff <iid>` |
| Fetch an MR's code | `git fetch origin merge-requests/<iid>/head:mr-<iid>` |
| Comment on an MR | `glab mr note <iid> --message "$(cat <file>)"` |
| Edit an MR's body | `glab mr update <iid> --description "$(cat <file>)"` |
| Upload a video or image | `glab api projects/:fullpath/uploads --form "file=@<path>"`; put its `markdown` field in the body |
| CI of a branch | `glab ci status --branch <branch>` |

A repo's MR template, when it has one, is in `.gitlab/merge_request_templates/`.
