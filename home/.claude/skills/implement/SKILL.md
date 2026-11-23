---
name: implement
description: Build one ready Jira story as the lead session — plan it in steps, give each step to a subagent on a smaller model, then test, review, record before-and-after evidence and open one MR for each repo it changes. Resumes from the story's ticket note after a stop. Use when /work routes a ready story here, or the user asks to implement or continue a story.
---

# Implement

You are the **lead**. You keep the plan, the decisions and the ticket note; subagents
read and write the code. Keep your own context small: never read code a subagent can
read for you, and keep only their short reports. The plan was settled upstream; do not
reopen it.

Run in the metarepo. Read `AGENTS.md`, `docs/agents/jira.md`,
`docs/agents/gitlab.md`, `docs/agents/testing.md` and the story's note,
`tickets/<KEY>.md`. A note that is missing, or not at Status `ready` or
`building`, stops the run: `Next: /work <KEY>`.

**Models.** Read each with `printenv`. The value `inherit` means leave the Agent
tool's `model` unset; empty means the default; any other value is passed as `model`.

| Subagent | Setting | Default |
| --- | --- | --- |
| A build step, a fix | `WORK_IMPLEMENTER_MODEL` | `sonnet` |
| A review axis | `WORK_REVIEWER_MODEL` | `inherit` |
| Research, a walkthrough, the evidence | `WORK_RESEARCH_MODEL` | `sonnet` |

## 1. Claim or resume

**Resume** (Status `building`): for each worktree in the note, list its commits since
its base (`git -C <worktree> log --oneline <base>..HEAD`). The commits are the truth:
tick each step whose commit is there, untick one whose commit is not. Go on at the
first open step.

**Claim** (Status `ready`): assign the story to the user and move it to the claimed
status (`jira.md`). For each repo the note's Decisions name, in the project folder:

```bash
git -C ../<repo> fetch origin
git -C ../<repo> worktree add -b <KEY>-<slug> ../worktrees/<repo>/<KEY> origin/<default-branch>
```

Record each worktree, branch and base (`git -C <worktree> rev-parse HEAD`) under
**Worktrees**, and run the repo's **Setup** there (`testing.md`). Read each repo's
rule files (the hook stops your first edit until you have) and write each rule that
applies to this story under **Rules**, one line each with its file.

## 2. Plan the steps

Cut the story into steps under **Steps**. Each step:

- builds one piece in one repo, test-first, and ends in one commit;
- fits one subagent on the implementer model: about one module and its tests;
- comes after the steps it builds on (a contract before its caller, data before the
  screen);
- carries what its subagent needs, so a smaller model does not guess: the files to
  read first, the files to change, the names and shapes it creates, the tests it
  writes (each test's name and expected result), and what it must not touch.

The last step extends the story's e2e journey (`~/.claude/docs/testing.md`, E2E
shape). Set Status to `building step 1 of <n>`.

## 3. Build

For each open step, in order, one subagent on the implementer model, with
[BRIEF.md](BRIEF.md)'s step brief filled in. Steps in different repos that do not
depend on each other may run at the same time; steps in one repo run one after the
other.

After each report: check its commit is there, tick the step with its sha, move Status
on, put each surprise under **Findings** and each open question under **Open**. A step
that failed gets one new subagent with the failure in its brief; a second failure
stops the run and asks the user.

**Context.** When your context is getting long (many steps done, long reports), stop
after the current step: the note holds everything, and `Next: /work <KEY>` resumes.

**Open choices.** A case the story left open is yours to decide. Give it an answer
and a confidence, as [grilling](../grilling/SKILL.md) defines them. FIRM or LEAN:
build it and note it under **Decisions**. COIN-FLIP, or a one-way door (a stored data
shape, a contract other code relies on, deleting data): ask the user, as grilling's
draft, before building it.

## 4. Verify

For each repo, one subagent on the implementer model: "In <worktree>, run
<typecheck, lint, format, fast suite from testing.md>. Fix each failure at its cause,
never by weakening a test, and commit each fix as `<KEY>: fix <what>`. Report each
command's result and each commit in at most 10 lines. Do the work yourself; spawn no
agents."

Then run the e2e journey files the story touched, with the repos' **Start** and
**Stop**. A failing journey is fixed like a failing test.

## 5. Review

Rounds of at most 3. Each round: call the Skill tool with "review", passing each
repo's worktree and base, the story and its epic as the spec source, and the findings
under **Open** as settled. Give each finding to be fixed to a fixer subagent on the
implementer model (its brief is the findings list, the worktree and the rules), then
review again from the commit the last round reviewed. Stop when a round is clean.
Findings left after round 3 go under **Open** and into the MR, and you tell the user.

## 6. Evidence

One subagent on the research model records the before and after, as
[EVIDENCE.md](EVIDENCE.md) says. Its files go in the MR and on the story.

## 7. Docs

One line each; act only where the answer is yes:

- A repo's setup, commands or surprises changed → its note, or `testing.md`.
- A domain word was born or changed → `GLOSSARY.md`.
- A hard-to-undo, surprising decision was made → offer an ADR in `docs/adr/`.
- A doc in a repo describes behaviour this story changed → update it in that repo.
- A mistake the review caught that an earlier story's review also caught → one line in
  `AGENTS.md`'s `## Lessons`, or a check to build, named in the MR.

## 8. Publish

For each repo, in the merge order the note names:

1. `git -C <worktree> push -u origin <branch>`.
2. Call the Skill tool with "mr", handing it the story, the epic, the steps and their
   commits, the evidence files, How to try it, the checks run and the review rounds.

Then comment on the story with the MR links and the "What to look at" list, attach
the video if `jira.md` has a command for it (else link the MR), and move the story
to the in-review status. Fill **Done** in the note, set Status `in review`, and
commit the note in the metarepo (`docs(tickets): <KEY> in review`).

## 9. After the merge

`/work <KEY>` when every MR is merged: run each repo's **Stop**, remove each worktree
by its exact path (`git -C ../<repo> worktree remove ../worktrees/<repo>/<KEY>`), delete
the local branches, move the story as `jira.md` says for merged work, set Status
`done`, and commit the note.

## Closing output

```
<KEY> <title> — <Status>
Steps: <done> of <n> · Review: <rounds>, <open findings or clean>
MRs: <links, in merge order>
Lessons: <added or none> · Needs you: <suggestions, questions, or none>
Next: <one command, or none>
```
