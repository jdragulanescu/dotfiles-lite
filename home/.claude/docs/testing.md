# Testing

How to choose and run the checks that prove a change, in every repo. A project's
commands live in its testing doc, `<project>-meta/docs/agents/testing.md`, one
section for each repo. Read it before running any test.

- The **fast suite** is every unit, component and HTTP-level test of a repo. It
  always runs whole.
- Test every piece of logic added or changed, through its interface: the expected
  result, and the invalid input, error paths and boundaries a caller can reach. Test
  **stress** (large inputs, many items) and **partial failure** (a later step failing
  after earlier ones succeeded) when a criterion names them. Coverage percentage does
  not matter.
- When existing tests break, **ALWAYS** make sure the code works first, then update
  the tests.
- Pick the cheapest check that proves the change:

| What changed | Test that stays in the repo | Check while building | E2E |
| --- | --- | --- | --- |
| Logic or a domain module | Unit tests | — | No |
| A UI component | Component tests | `browser-check`, or `tui-check` for a terminal UI | No |
| A user journey | The story's step in its journey file | `browser-check` or `tui-check` | That journey |
| An API | HTTP-level tests | Call it on this worktree's server | No |
| A CLI | Tests that run the real binary | Run it once | Only that command |
| An action whose tests fake a boundary it crosses | A test that fails when a request is one the real side refuses | Use the action once for real | No |

- **NEVER** run the full e2e suite. Run the journey files a story touches. The full
  suite is CI's job.
- A changed screen no e2e path covers is walked with `browser-check` or
  `tui-check` and reported, never skipped silently.

## E2E shape

- **A folder is an area, a file is a journey.** Journeys that cross repos live in
  `<project>-meta/e2e/`; a repo that has its own e2e suite keeps its journeys there.
- **A story extends the journey file it belongs to**, and creates one only for a new
  journey.
- **An e2e test proves the journey only**: the happy path and the one failure a user
  would hit. Validation, edge cases and error branches are unit or component tests.
- **Every journey file stays within 60 seconds**, unless the testing doc sets
  another budget. Tests share setup, never depend on each other, and run in parallel.

## Isolation

Several worktrees of one repo can be live at once. The testing doc's section for a
repo records what it shares (ports, databases, containers) and the commands that give
a worktree its own copy: **Setup**, **Start** and **Stop**.

- In a worktree, start servers only through its **Start**, and run its **Stop** before
  the worktree is removed, pass or fail.
- Keep one worktree of a repo live at a time until its **Start** gives each its own
  port and state.
