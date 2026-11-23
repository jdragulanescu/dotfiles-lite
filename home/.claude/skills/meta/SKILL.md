---
name: meta
description: Set up a work project's metarepo, `<project>-meta`, the folder every work session starts in, or add a repo to one. Use when the user runs /meta, wants to set up a project for work, or add a repo to a project.
disable-model-invocation: true
---

# Meta

Set up a project so that every session starts in one place and knows the whole
project. The layout, and why, is in **Work projects** in `~/.claude/CLAUDE.md`:

```
~/dev/<project>/
  <project>-meta/          this skill writes it; start every session here
  <repo>/ …                each repo, cloned beside it
  worktrees/<repo>/<KEY>/  one worktree for each story and repo
```

The templates are in [templates/](templates/). Copy them; never write a layout of
your own. Everything this skill writes about the project (the Jira site, keys, group
names, statuses) goes in the metarepo, never in a skill or in `~/.claude`.

Three uses:

- `/meta` in an empty project folder, or a folder of clones: **New**, all steps.
- `/meta add <repo URL>` in a metarepo: steps 4 and 5 for that repo only, then
  update `docs/guides/project.html` with "writing-html-docs", then 8.
- `/meta check` in a metarepo: step 2 only, and fix `jira.md` and `gitlab.md`.

## 1. Ask

Find what you can first: the folder name (the project name), the clones already in
the folder and their `git remote get-url origin`. Then ask, in one round, as
**Asking the user** in `~/.claude/CLAUDE.md` says, only what you could not find:

- the GitLab group, or the repo URLs;
- the Jira site and project key;
- one sentence on what the project is for.

With a group, list its repos (`glab repo list -g <group> --per-page 100`) and let the
user pick which belong to the project.

**Done when** you hold the project name, every repo's name and remote, the Jira site
and key, and the one sentence.

## 2. Check the tools

- **GitLab**: `glab auth status`. Logged out: give the user `! glab auth login`.
- **Jira**: try `acli jira auth status`, then `jira me`. The first one that answers
  is the project's CLI. Neither: give the install and login lines from `jira.md`'s
  Commands table and go on; the CLI line stays `TODO`.
- Read one item in the Jira project with that CLI, to prove the key and the access.
  Write the output's shape (JSON, plain text, which format the description came in)
  under **Body format** in `jira.md`.

**Done when** each tool is logged in or its line says `TODO` and why.

## 3. Write the metarepo

Create `<project>-meta/` in the project folder, copy every template into it
(`gitignore` becomes `.gitignore`; `tickets/TICKET.md` and
`docs/agents/repos/REPO.md` stay as the forms the other skills copy), then fill the
placeholders you hold: the project paragraph, the Repos lines, the Jira site, key
and CLI (delete the other CLI's column), the GitLab group. Leave every `TODO` line
in place: it marks what only the team's process can settle.

Write `.claude/settings.local.json` with the project folder's absolute path, so the
session can reach the repos beside it. Git ignores this file, as each laptop has its
own path:

```json
{ "permissions": { "additionalDirectories": ["<absolute path of ~/dev/<project>>"] } }
```

Run `git init -b main` in it.

**Done when** every template is in place with the known placeholders filled.

## 4. Clone

Run `just clone` in the metarepo. A clone that fails is reported with its error, and
its line stays in `AGENTS.md`.

## 5. Learn each repo

For each repo, one subagent (up to 4 at once), on the model `WORK_RESEARCH_MODEL`
names (`printenv WORK_RESEARCH_MODEL`; empty means `sonnet`, `inherit` means leave
the model unset). Brief:

> Read the repo at <path>. Write two things, from what the code and its docs show,
> never from guesses. (1) `<meta>/docs/agents/repos/<repo>.md`, filling the form at
> `<meta>/docs/agents/repos/REPO.md`: what it is, its rule files, what it talks to,
> one line for each top folder, and surprises with their evidence. (2) The section
> for this repo in `<meta>/docs/agents/testing.md`: each command copied from the
> repo's package scripts, Makefile, justfile, CI file or README; a field you cannot
> find reads `none`. Do not run installs or servers. Change nothing in the repo.
> Report the two paths and the fields you left `none`. Do the work yourself; spawn
> no agents.

Then read each note: a line that names no file or command as its source is a guess;
cut it.

**Done when** each repo has its note and its testing section.

## 6. Write the guide for people

Call the Skill tool with "writing-html-docs" to write `docs/guides/project.html`:
what the project is for, each repo and how they talk to each other (a diagram), how
to set it up and run it, and where work starts (`/work` from `<project>-meta`).
Take every fact from the repo notes and `testing.md`; a fact they do not hold is
left out, never guessed.

**Done when** the page opens with the project's name and every section has a source
in the notes.

## 7. Show and publish

Show the user the tree and each `TODO`. Then ask before you publish, because it
creates a repo your team can see: "Create `<group>/<project>-meta` as a private repo
on GitLab and push?" On yes: `glab repo create <group>/<project>-meta --private`, add
the remote, commit (`chore: set up <project>-meta`), push.

## 8. Close

Print what was made, each `TODO` left, and the next step: `/work <Jira key>` for a
story, or `/work <idea>` for a new feature, both from `<project>-meta`.
