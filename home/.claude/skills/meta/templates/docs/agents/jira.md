# Jira

Every work item of this project is in Jira. GitLab holds only code and MRs.

- **Site**: <https://…>
- **Project key**: <KEY>
- **CLI**: <acli | jira-cli>, the one that worked when `/meta` ran

## Levels

- **Epic** = a spec: a feature the project builds towards.
- **Story** = a ticket: one finished thing a user can do, built as one MR for each
  repo it changes.

## Statuses

TODO: match the statuses to the team's Jira process.

| Moment | Status |
| --- | --- |
| A story is claimed | <In Progress> |
| Its MRs are open | <In Review> |
| Its MRs are merged | <Done> |

## Layout

TODO: match the epic and story layout to the team's Jira process. Until then, the
`spec` and `stories` skills give the layout.

## Body format

TODO: at the first run, check how the CLI takes a description and a comment (plain
text, Markdown or Jira's own format, ADF) and whether a folded section works. Write
the answer here, with a command that worked.

## Commands

Check each row with the CLI's `--help` at the first run, fix it here, and delete the
other CLI's column.

| Need | acli | jira-cli |
| --- | --- | --- |
| Log in | `acli jira auth login --web` | `jira init` |
| Read an item | `acli jira workitem view <KEY> --json` | `jira issue view <KEY> --comments 50 --raw` |
| Search | `acli jira workitem search --jql '<JQL>' --json` | `jira issue list -q '<JQL>' --plain` |
| Stories of an epic | search `parent = <EPIC>` | `jira issue list -q 'parent = <EPIC>' --plain` |
| Create an epic | `acli jira workitem create --project <KEY> --type Epic --summary '<title>' --description-file <file>` | `jira epic create -s'<title>' -b"$(cat <file>)" --no-input` |
| Create a story | `acli jira workitem create --project <KEY> --type Story --summary '<title>' --description-file <file> --parent <EPIC>` | `jira issue create -tStory -s'<title>' -b"$(cat <file>)" -P <EPIC> --no-input` |
| Edit a body | `acli jira workitem edit --key <KEY> --description-file <file>` | `jira issue edit <KEY> -b"$(cat <file>)" --no-input` |
| Comment | `acli jira workitem comment create --key <KEY> --body-file <file>` | `jira issue comment add <KEY> "$(cat <file>)"` |
| Move to a status | `acli jira workitem transition --key <KEY> --status '<status>' --yes` | `jira issue move <KEY> '<status>'` |
| Assign to me | `acli jira workitem assign --key <KEY> --assignee @me` | `jira issue assign <KEY> "$(jira me)"` |
| Link "blocks" | TODO: check | `jira issue link <KEY> <BLOCKED-KEY> Blocks` |
| Attach a file | TODO: check; with none, link the MR's upload | TODO: check |
