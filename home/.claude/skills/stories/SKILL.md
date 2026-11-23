---
name: stories
description: Cut a spec (a Jira epic) into stories, each one finished thing a user can do, built as one MR for each repo it changes, and publish them under the epic with their blocking links. Re-run on an epic whose spec changed to bring its open stories in line. Use when /work or spec routes here, or the user asks to split an epic into stories.
---

# Stories

Cut an epic into **stories**. Each story is **narrow but finished**: it gives a user
one complete thing to do, at release quality, and its MRs merge to the default branch
on their own. Make a story smaller by cutting **scope** (one format, one kind of user,
fewer options), never quality: its checks of user input, its errors, its empty
states, its styling and its tests are part of it.

Run in a metarepo. Read `docs/agents/jira.md` and the epic, body and comments. Read
the code the Agent notes name.

## 1. Cut

Each story must pass all four tests:

1. **Something to try**: after it merges, a user or tester can do or see something
   new, and the MR can show it before and after. A prefactor story is the one
   exception: it changes no behaviour, and its proof is the tests staying green.
2. **Works alone**: after it merges, every repo builds, its tests pass, and users see
   nothing broken or half there. When a part is useful only with the next story, join
   the two; when the joined story is too big, hide the new part behind the repo's
   feature flag, only when the repo already has one.
3. **One lead session**: `implement` can build it in one session, as about 3 to 8
   steps that each fit one subagent. A story bigger than that is cut by scope.
4. **Its own test step**: it adds or extends the epic's e2e journey for what it
   delivers.

Order the stories so each one's blockers come first. A story blocks another when the
other builds on its code or its data.

## 2. Agree

Show the breakdown as [grilling](../grilling/SKILL.md)'s draft, with this block
before its decisions:

```
## Stories
1. <title> — <what a user can do after it> — repos: <…> — about <n> steps — blocked by: <none | 1>
```

Publish nothing before the user agrees.

## 3. Publish

TODO: match the story layout to the team's Jira process (`docs/agents/jira.md`,
Layout). Until then, write each story like this, in the format `jira.md`'s Body
format names:

```
What the user can do
<one sentence>

Done when
- [ ] <each check someone can see or run, the errors and empty states included>

How to try it
1. <action> → <what they see>

Evidence
<filled in when it is built: the video and the "What to look at" list>

▸ Agent notes (folded)
Repos: <each repo, and the order their MRs merge in>
Modules: <what changes in each, from the epic's Agent notes>
Tests: <the seams, and the e2e journey file it extends>
Blocked by: <keys, or none>
Note: tickets/<KEY>.md in the metarepo
```

Create each story under the epic (`jira.md`, Create a story), then the blocking
links. Add a line for each story to the epic's note, `tickets/<EPIC>.md`.

## Re-run on a changed epic

When stories exist, compare each open story to the epic's newest **Changes** line.
Propose, in one draft: stories to add, stories to change, stories to drop. Never
change a story someone has started without asking, and post a comment on it saying
what changed.

## Closing output

```
<EPIC> — <n> stories published
Next: /work <the first story none of whose blockers is open>
```
