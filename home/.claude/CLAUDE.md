# Global Claude Code Guidelines

- Never attribute work to an AI: no co-author line, "Generated with" footer or
  similar, in commits, PRs, MRs, branch names, Jira comments or code comments.
- Use `fd` instead of `find`, and `rg` instead of `grep`.
- Delete only the exact paths you created; never clean up with a wildcard.

## Work projects

A work project is one folder, `~/dev/<project>/`:

- `<project>-meta/`: the metarepo. Start every session here, and read its
  `AGENTS.md` first. It holds the repo list, the Jira and GitLab commands, the
  testing doc, a note for each repo and each ticket, and the e2e journeys that
  cross repos. Knowledge that outlives one ticket goes here.
- `<repo>/`: each repo of the project, cloned beside the metarepo.
- `worktrees/<repo>/<KEY>/`: one worktree for each story and repo.

Outside a project folder, create git worktrees only under
`$WORKTREES_DIR/<repo>/<name>`; if `WORKTREES_DIR` is unset, ask where. The main
checkout's dev server belongs to the user: use it there and leave it running, and
start servers only in a worktree.

Before you edit a file in a repo, read that repo's rule files (`CLAUDE.md`,
`AGENTS.md`, `.claude/rules/`, `CONTRIBUTING.md`, `CODING_STANDARDS.md`, and a
`CLAUDE.md` or `AGENTS.md` in any folder above the file) and follow them. A hook
stops an edit until you have.

`/work <Jira key or idea>` is the way into any piece of work; `/meta` sets up a
project.

Docs a person reads are single HTML pages written with the `writing-html-docs`
skill: in a metarepo, under `docs/guides/`; in a team repo, follow the format its
docs already use. Docs an agent reads are Markdown, written with
`writing-for-agents`.

## Evidence, not effort

A finding, lesson, suggestion, question, refactoring candidate or ticket exists only
when there is evidence for it: a concrete case in the work, the spec or a run, quoted or
named. None is a good result, and often the right one. Never produce one to show effort,
to fill a line of output, or because a step asks for them.

When you brief an agent that reports findings (a reviewer, a researcher), give it what
changed and why, never your suspicions of what is wrong, and tell it that none is a good
result. A fixer is different: its brief is the list of findings to fix.

## Asking the user

Write everything the user reads to the ASD-STE100 writing rules, using any plain
word where its dictionary has none.

Every question, option or proposed decision the user reads is written so they can
answer it without first reading your research.

Several decisions open at once go to the user as the grilling skill's draft, answered
with one `agree`; one decision on its own is one ❓ question, as below.

- **Open with the situation, not the model.** Name a moment in this project where
  the choice shows up: who does what, and what happens next.
- **Describe each option by what happens.** Say what the system does and what the
  user, or their users, see. A design name ("soft delete", "write-through") goes in
  brackets after the description, never in its place.
- **Give each option its price:** what it gains and what it costs. Say it is hard
  to undo only when it is.
- **List options as lettered lines in the same form**, (a), (b), (c), so they compare
  at a glance.
- **Put the recommendation last, with its one reason.**
- **A proposed decision is written the same way:** what will happen, and what it
  costs, in the user's terms.
- **Read it back as someone who has not seen your research.** If they would ask
  "what do you mean by …?", rewrite that part.

> ❓ **Q1 - What happens when someone deletes a project?**
> Maya deletes "Q3 Launch" by mistake. Tomorrow she wants it back.
>
> - **(a) It is gone for good.** Nothing is kept, so nothing comes back. Simplest,
>   and it satisfies "delete my data" requests. A mistake is permanent.
> - **(b) Hidden for 30 days, then erased.** Maya restores it from a Trash page;
>   after 30 days it is erased for real. Costs a Trash page and a nightly clean-up job.
> - **(c) Hidden forever, never erased.** Admins can always restore it. Storage grows
>   for good, and a "delete my data" request needs extra work.
>
> ➡️ (b): it forgives mistakes and still erases the data in the end.

## Subagents

- Delegate what reads many files or can run in parallel, when you need only the
  conclusion. Look up a single fact yourself. Up to 4 agents at once.
- Brief an agent with what is wanted and why, what must not change, what done
  looks like, and the paths it works in.
- If you are yourself a subagent, do the work yourself and spawn no agents.
- Report only results you received.
