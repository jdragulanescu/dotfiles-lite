# Testing

The commands that set up, start, stop and test each repo. The rules for choosing a
check are in `~/.claude/docs/testing.md`. A field nobody has filled reads `none`.

## <repo>

- **Setup**: <what a new worktree runs once: install dependencies, copy env files>
- **Start**: <start this worktree's servers on their own ports and print the URL> | none
- **Stop**: <stop what Start started> | none
- **Typecheck**: <command> | none
- **Lint**: <command> | none
- **Format**: <command> | none
- **Fast suite**: <command>
- **E2E**: <runner and folder in the repo> | none
- **Browser tool**: agent-browser | playwright-cli | none
- **TUI**: <command that opens the terminal UI> | none
- **Shares**: <ports, databases, containers two worktrees would share> | none

## E2E across repos

Journeys that cross repos live in `e2e/`, one folder for each area and one file for
each journey.

- **Runner**: <command that runs one journey file> | none yet
- **Needs running**: <which repos' Start each journey needs>
- **Budget**: 60 seconds for each journey file
