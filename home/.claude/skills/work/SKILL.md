---
name: work
description: The way into any piece of work in a project's metarepo — a Jira story, bug, task or epic, an MR to review, or an idea for a new feature. Reads it, researches the code, grills the user only on the gaps, then builds it or specs it. Use when the user runs /work, or hands over a Jira key or an idea to build at work.
disable-model-invocation: true
---

# Work

Take one piece of work from "here is a key or an idea" to built, or to the next step.
You are the **lead**: you hold the plan and the user's decisions; subagents do the
reading and the building. Facts are your job; decisions are the user's.

## 0. Where

Run in a metarepo: the folder holds `AGENTS.md` with a `## Repos` list. Read it,
then `docs/agents/jira.md`. Anywhere else, stop: the next step is `/meta`.

Subagent models: `printenv WORK_RESEARCH_MODEL` (empty means `sonnet`). The value
`inherit` means leave the Agent tool's model unset; any other value is passed as
`model`.

## 1. What came in

| Input | Route |
| --- | --- |
| A Jira key or URL, and `tickets/<KEY>.md` has a Status that is not `done` | **Resume**: read the note, then go on at the step its Status names (`building` → `implement`, which resumes). |
| A story, bug or task key | Steps 2 to 5, then `implement`. |
| An epic key | Its stories (`jira.md`, Stories of an epic). None: `stories`. Else name the first open story none of whose blockers is open, and run it from step 2. |
| An MR (URL, or `!<iid>` with a repo) | `review` on it. |
| An idea in words | **New feature**: `grilling` on it, then `spec`, then `stories`. Stop there with the closing output. |
| Nothing | Ask which. |

## 2. Read

Read the item whole: body, comments, attachments' names, its epic (body and
comments), and each linked item's summary and status. Create `tickets/<KEY>.md`
from `tickets/TICKET.md` with Status `researching`, or open the one there.

## 3. Research

Find what the item touches. One subagent for each repo that might be involved (the
repo notes in `docs/agents/repos/` say which), up to 4 at once. Brief:

> Read <repo path> to find where <the item, in two sentences> would be built. Report,
> with paths and line numbers: the code that changes, similar code to copy from, the
> tests that cover that code, how this repo talks to <the other repos involved>, and
> anything that makes the change hard. Change nothing. No finding is a good result
> when it is true. Do the work yourself; spawn no agents. Under 300 words.

Write what comes back under **Findings** in the note, each with its path. A
surprise that will cost the next agent time also goes under Surprises in that repo's
note.

## 4. Ready

The item is **ready** when you can state all five from the item and the findings:

1. **Outcome**: what a user can do or see when it is done.
2. **Done when**: checks someone can see or run, including errors and empty states.
3. **Where**: the repos and modules that change, and the order their MRs merge in.
4. **Approach**: how, in a few lines, following the code that is there.
5. **Tests**: which tests prove it, at which level (`~/.claude/docs/testing.md`).

Each one the item and the findings cannot settle is a gap. With gaps, call the Skill
tool with "grilling" on those gaps only, with your proposed answer to each. Write
every settled point under **Decisions** in the note.

Then, when the grilling changed or added to what the item says, show the user a
comment that records the decisions for the team, and ask before posting it: it
goes out in their name. On yes, post it (`jira.md`, Comment).

**Done when** all five are stated in the note and Status is `ready`.

## 5. Size

- **One finished thing a user can do**, however many build steps it needs:
  `implement` builds it, and splits it into steps itself.
- **Two or more separate things a user can do**: propose a split into stories, each
  one finished on its own (as `stories` defines them), and ask before changing a
  story the team wrote. On yes, `stories` publishes it.

## 6. Build

Call the Skill tool with "implement", with the key. It reads the note.

## Closing output

Every run ends with this, also when it stops early:

```
<KEY> <title> — <Status from the note>
Done: <what this run did, one line each>
Waiting on you: <questions or approvals, or none>
Next: <one command, such as /work ABC-143, or none>
```
