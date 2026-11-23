# Step brief

The brief the lead gives each build-step subagent. Fill every <field> from the note;
a field you cannot fill is a gap in the plan: close it before sending. The subagent
may be a smaller model that was not in the conversation, so every line names the
thing, the place and the expected result.

```
You build one step of story <KEY> in <worktree path> (repo <repo>, branch <branch>).
Work only in that folder: run every command there.

Read first:
- <metarepo>/tickets/<KEY>.md: the Decisions and Rules sections.
- <metarepo>/docs/agents/repos/<repo>.md
- <each file to read, with what to look at in it>

Rules of this repo (a hook makes you read the files before your first edit):
- <each rule from the note's Rules that applies to this step, with its file>

Build:
<2 to 5 sentences: what this step adds, by name (function, component, route,
table), its inputs and outputs, and each error it returns.>

Files to change: <paths, and new files to create>
Do not change: <generated code, other repos, files outside this step>

Tests first. Call the Skill tool with "tdd". Write each test, see it fail, then make
it pass:
- <test name> → <expected result>
- the invalid input, error paths and boundaries a caller can reach, as
  ~/.claude/docs/testing.md says.
Copy the style of <an existing test file>.

Done when:
- the new tests and the existing tests of <the module> pass:
  <the test command from testing.md, narrowed to the files>;
- <typecheck and lint commands> pass for the changed files;
- the work is one commit: "<KEY>: <step title>".

If this brief is wrong, or a decision you need is missing, stop and report it.
Do not guess.

Report in at most 10 lines: the commit sha, the files changed, the tests added and
their result, anything that surprised you, anything left undone.
Do the work yourself; spawn no agents.
```
