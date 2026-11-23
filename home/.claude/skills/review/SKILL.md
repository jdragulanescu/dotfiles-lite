---
name: review
description: Review a change on three axes in parallel subagents — Standards (the repo's own rule files and coding standards), Spec (the Jira story and its epic) and, when the change touches the attack surface, Security — and report them side by side. Use for a story's worktrees from implement, for a colleague's GitLab MR, or when the user asks to review a branch or asks for a security review.
---

# Review

Review the diff of each repo a change touches, between its head and a fixed point,
along up to three axes:

- **Standards**: does the code follow the repo's own rules and the coding standards?
- **Spec**: does it do what the Jira story and its epic asked, no more, no less?
- **Security**: can an attacker get in through it? Only when the diff changes the
  attack surface (step 4), or the caller asks.

Each axis runs as its own subagent, so they do not blur each other. Their model is
`WORK_REVIEWER_MODEL` (`printenv`; empty or `inherit` means leave the Agent tool's
model unset, so it runs on yours).

## 1. Pin the change

- **From `implement`**: each repo's worktree and base, as given.
- **An MR** (`/review <MR URL>`, or `!<iid>` in a repo): fetch its code into a
  worktree of its own (`gitlab.md`, Fetch an MR's code; then
  `git worktree add <project>/worktrees/<repo>/mr-<iid> mr-<iid>`). Its fixed point
  is `git merge-base origin/<target> mr-<iid>`. Remove the worktree at the end, by
  its exact path.
- **Anything else**: the fixed point the user names; ask when they named none.

For each repo, the diff command is `git -C <top> diff <fixed point>...HEAD` and the
commits `git -C <top> log <fixed point>..HEAD --oneline`. Check the fixed point
resolves and the diff is not empty before going on.

## 2. The spec source

The story the caller names; else a Jira key in the branch name, the MR title or the
commits (`jira.md`, Read an item); its epic too; and its ticket note
(`tickets/<KEY>.md`) for the decisions. With none, ask; with "there is none", Spec
is skipped and says so.

## 3. The standards sources

For each repo: every rule file the hook names (`CLAUDE.md`, `AGENTS.md`,
`.claude/rules/*.md`, `CONTRIBUTING.md`, `CODING_STANDARDS.md` at the top, and a
`CLAUDE.md` or `AGENTS.md` in each folder above a changed file), what they import,
the metarepo's repo note, `~/.claude/docs/coding-standards.md` and
`~/.claude/docs/testing.md`.

- **The repo wins**: where a repo rule contradicts a global one, keep the repo's.
- **The linter enforces it**: drop a coding-standards rule whose table names a lint
  rule the repo's config turns on, for the files that linter checks.

On top, the Standards axis carries this **smell baseline** (Fowler, _Refactoring_,
ch. 3), always as judgement calls, and always overruled by a repo rule: Mysterious
Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated
Switches, Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains,
Middle Man, Refused Bequest.

## 4. Does Security run

Yes when the caller asks, or when a hunk adds or changes: a way in from outside (a
route, handler, webhook, job reading outside data, a CLI reading input); sign-in,
sessions, roles or an access check; database queries, migrations or grants; HTML
built from anything but literals; file paths, uploads or requests to a URL that is
not constant; a shell command, `eval` or deserialiser fed values that are not
constant; caching, cookies, CORS or security headers; secrets, tokens, crypto or
config that reaches a client; dependencies, lockfiles or CI files; an LLM's output
that reaches a tool, a query or HTML. Read the hunks, not only the file names.

## 5. Run the axes

Start the subagents together, and give none of them your guesses about what is
wrong. Every brief ends with this **evidence bar**, as it is:

> "No findings is a good result, and the right one when it is true: never report to
> show effort. Report a finding only with a concrete case: quote the hunk, and say
> what goes wrong for a real input, which documented rule or spec line it breaks,
> which baseline smell it matches and what it makes harder to change, or who sends
> what to attack it and what they get. Leave out style preferences no documented
> standard states, rewordings of what is already clear, cases no real input reaches,
> and anything that works. End with the number of findings, which may be zero. Do
> the work yourself; spawn no agents."

- **Standards**: the diff commands, the source paths, the two drop rules and the
  smell baseline pasted in full. Brief: "Report, per file and hunk: (a) each break of
  a repo rule file or coding standard, citing the file and the rule; (b) untested
  logic: logic added or changed without the tests `~/.claude/docs/testing.md` asks
  for; (c) a baseline smell that makes this diff harder to change, as a judgement
  call; (d) an e2e case that could be a unit or component test. Mark each hard or
  judgement call. Under 400 words."
- **Spec**: the diff commands, the story, the epic and the note's Decisions. Brief:
  "Report: (a) what the story's Done when asks that is missing or partial; (b)
  behaviour nobody asked for; (c) what looks done but is wrong; (d) a missing error or
  empty state the story's Done when names; (e) a decision in the note the code does
  not follow. Quote the story line for each. Under 400 words."
- **Security**: the diff commands, what the change is for in two sentences, the
  attack-surface lines it matched with their hunks, and the absolute path of
  [SECURITY.md](SECURITY.md) with the diff's languages. Brief: "Name who can reach the
  changed code and what it guards. Check each entry point the diff adds or changes
  against every group in SECURITY.md, following calls into unchanged code. For each
  finding: severity, file:line, the attack, and the smallest fix. Then name the groups
  that came out clean. Under 400 words."

When the caller passes **settled findings**, paste them into every brief: "These are
already settled. Report one again only if the diff has changed it since."

## 6. Report

Show the three reports under `## Standards`, `## Spec` and `## Security`, as they
came; an axis that did not run gets one line saying why. Do not merge or rerank them:
a change can pass one axis and fail another. End with one line: the findings per axis
and the worst in each.

On a colleague's MR, post nothing. Offer to post the findings as MR comments, show
the text, and post only on yes.
