---
name: mr
description: Write a GitLab merge request's body and publish it — why, a picture of the change, the before-and-after evidence with its "What to look at" list, merge danger, how to try it. Use when opening an MR, or writing or updating an MR body.
---

# MR

Owns how every MR body looks and how it is published. `implement` hands it the
content; asked directly, gather it yourself from the branch, its commits and the Jira
story its branch or title names. `/mr <iid>` rewrites an existing MR's body into this
form. Commands are in the metarepo's `docs/agents/gitlab.md`.

## 1. Gather

- **The diff**: `git diff origin/<default>...<branch>` and its commits.
- **The story** and its epic (`jira.md`), and the story's ticket note.
- **The evidence**: the joined video or images, and `what-to-look-at.md`, from
  `${TMPDIR:-/tmp}/evidence/<KEY>/`; for a change with no screen, the before and
  after outputs.
- **The other MRs of the story**, in merge order, when it changes several repos.
- **The repo's MR template**, when it has one (`.gitlab/merge_request_templates/`,
  `Default.md` first). Its headings come first, filled as it asks; a section below
  that it already has is written once, in its place.

## 2. Write

Title: `<KEY>: <story title>`. Body:

```markdown
**Jira:** [<KEY>](<url>) · **Epic:** [<EPIC>](<url>)

## Summary

<one sentence: why, the problem this change solves for a user>

<the smallest picture of the change: a diagram, a tree, or a diff sketch>

## Evidence

<the video or image, uploaded>

**What to look at**
- 0:04 · 1. <step> — before: <…>; after: <…>

## Steps

- <sha> <what this commit builds, one line>

## Merge danger

**Door:** <one-way or two-way>, <why>
**Blast radius:** <who or what is affected if it is wrong>
**Merge order:** <this MR first, or after <link>>, or "alone"

## Try it

1. <command or URL for this branch> → <what you should see>

## Checks

- <typecheck, lint, fast suite: pass> · E2E: <journey file: pass, or none>
- Review: <rounds>, <clean, or each open finding>
- Rules followed: <each rule file read, and the rules that applied>
```

- **Summary** opens with why, from the story, in the user's words and the glossary's.
- **Evidence** is a result a reviewer can check: "tests green" alone is a claim. A
  change with no screen shows the before and after output in code blocks.
- **Door**: one-way when reverting the merge would not undo its effect (data migrated
  or deleted, a contract another team relies on, something published).
- A section with nothing to say is left out, except Summary, Evidence and Merge
  danger.

## 3. Publish

Write the body to a temporary file. Upload each video and image first (`gitlab.md`,
Upload) and put each returned `markdown` link where its placeholder is; a file over
the upload limit is shrunk (`ffmpeg -crf 30`) or left as its local path, said so in
the body. Then open the MR (`gitlab.md`, Open an MR) ready for review, never as a
draft unless the caller asks, or update the existing one. Read the body back with
`glab mr view`; fix any link still pointing at a local path.

**Done when** the MR is open, its body read back shows every section with something to
say, and every link resolves.
