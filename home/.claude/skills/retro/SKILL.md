---
name: retro
description: Look back at a work session, every session of one story or epic, or every session since a date, and propose changes to the environment (checks, repo notes, rules, tools) that would make the next run cheaper. Use when the user runs /retro, or asks what went wrong or what to improve.
disable-model-invocation: true
---

# Retro

Suggest improvements to the agent's **environment**, so the next run goes better.
You only propose; you write only what the user accepts in step 5.

Call the Skill tool with "writing-for-agents" first, for how to word what lands.

## 1. Pick the sessions

Claude Code keeps each session as `~/.claude/projects/<folder>/<session-id>.jsonl`,
with its subagents in `<session-id>/subagents/agent-*.jsonl` beside it. `<folder>` is
the start folder with every character that is not a letter or digit replaced by `-`.

- **No argument**: this session. Read it from your context. When it spawned subagents
  or was compacted, also find its log (the newest `.jsonl` in this folder's
  directory that holds your `/retro` message), for those parts.
- **A Jira key** (`/retro <KEY>`, a story or an epic with its stories): every session
  that worked on it: `rg -l --max-depth 2 '"gitBranch":"<KEY>-' ~/.claude/projects/`,
  plus `rg -l --max-depth 2 '<KEY>' ~/.claude/projects/<the metarepo's folder>/`.
- **A date** (`/retro --since <date>`): every top-level log that started on or after
  it: `fd -e jsonl --max-depth 2 --changed-after <date> . ~/.claude/projects/ -X rg -m1 -o --with-filename '"timestamp":"[^"]+"'`,
  then keep each whose first timestamp is on or after the date.

None found: say which you searched, and stop.

## 2. Find the moments

Look for these, in this session yourself and in each log through a reader:

- **Navigation**: the agent took long to find a file or a fact a pointer in a repo
  note or `AGENTS.md` would have given.
- **Automated checks**: a mistake a lint rule, type, test or hook could have caught.
  Read the repo's own check commands and CI first: a check that exists but is not
  wired is the finding.
- **Rules**: a review caught something a repo rule or coding standard should state;
  or a rule that changed nothing.
- **Tool economy**: an expensive tool call (a huge output, a search repeated) that a
  narrower command would have avoided.
- **Information access**: a fact the agent could not reach (logs, a service, a doc).
- **The workflow**: a step of `work`, `implement` or `review` that cost a round
  (a brief too thin for the build model, a step too big, a resume that lost state).

One reader subagent for each log, all in one message, on `WORK_RESEARCH_MODEL`
(`printenv`; empty means `sonnet`, `inherit` means unset). Brief:

> Read this Claude Code session log and its subagents' logs: <paths>. Find the
> moments the session struggled, in these categories: <the list above, in full>. For
> each: its category, what happened in one sentence, what it cost (turns, tokens, a
> review round, a wrong build), and the moment quoted word for word with its
> timestamp. Leave out secrets and tokens. No moments is a good result for a smooth
> session. Name any log you could not read, and why. Do the work yourself; spawn no
> agents.

## 3. Drop what is known

Read the metarepo's `AGENTS.md` `## Lessons`, the repo notes, and the MRs' Lessons
lines of the stories involved. A candidate already recorded is dropped when all its
moments came before the record, and marked `(rule broken)` when one came after: it
then needs a check, never a longer line.

## 4. Route and rank

- **A check** (a lint rule, type, test or hook) may come from one moment.
- **A line** in the metarepo's `## Lessons`, or a repo rule, needs the same thing seen
  in two sessions.
- **A navigation gap** is a pointer in the repo's note in the metarepo.
- **A tool or access gap** is a change to `docs/agents/` in the metarepo, or a
  suggestion.
- **A change to a skill, `~/.claude/CLAUDE.md` or `~/.claude/docs/`** is always a
  **suggestion**, never written here: those files are shared by every project.

Merge one thing seen in several sessions into one candidate. Rank by what it cost
times how many sessions it happened in.

## 5. Present and land

Show each candidate: its rank and category, what happened and what it cost, its
quoted moments, and where it lands with what that costs. Ask which to land, as
**Asking the user** in `~/.claude/CLAUDE.md` says. Write each accepted one in the
metarepo and commit it (`docs(agents): <lesson>`). A check to build in a team repo is
a Jira item only when the user asks for one. List the suggestions under **Needs
you**, and each log you could not read under **Not read**.
