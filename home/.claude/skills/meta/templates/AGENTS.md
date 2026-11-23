# <Project>

<One paragraph: what the project is, who uses it, and what it is for.>

This is the project's metarepo. Start every session here. The repos sit beside it
in `~/dev/<project>/`, and their worktrees in `~/dev/<project>/worktrees/`.

## Repos

One line for each repo, in this form; `just clone` reads these lines:

- <name> (<what it is>): ../<name>. Clone from <remote> if missing.

Before you change a repo, read its note, `docs/agents/repos/<name>.md`. A hook
makes you read the repo's own rule files before your first edit there.

## Where things go

| What | Where |
| --- | --- |
| Jira: commands, item types, statuses, layout | `docs/agents/jira.md` |
| GitLab: commands for MRs and CI | `docs/agents/gitlab.md` |
| Setup, start, stop and test commands, for each repo | `docs/agents/testing.md` |
| What a repo is, how it fits, what surprises | `docs/agents/repos/<repo>.md` |
| One note for each epic and story: findings, decisions, steps, progress, MRs, evidence | `tickets/<KEY>.md` |
| The words of the domain | `GLOSSARY.md` |
| A decision that outlives one epic | `docs/adr/NNNN-<slug>.md` |
| E2E journeys that cross repos | `e2e/<area>/<journey>` |
| Docs for people | `docs/guides/<name>.html` |

## Models

The lead session runs on the model you start it with. Its subagents take their
model from `WORK_IMPLEMENTER_MODEL`, `WORK_REVIEWER_MODEL` and
`WORK_RESEARCH_MODEL` in the `env` of `~/.claude/settings.json`. To change them
for this project only, set them in `.claude/settings.json` here.

## Worktrees

`../worktrees/<repo>/<KEY>/`, on the branch `<KEY>-<slug>`, cut from the repo's
default branch.

## Lessons

One short line each: what to do for a whole kind of change, true of the code today.
`implement` and `retro` add lines only with evidence from two runs.
