---
name: spec
description: Turn a grilled idea in this conversation into a spec, published as a Jira epic with a part for people and folded agent notes detailed enough for a smaller model to build from. Use after grilling a new feature, when /work routes an idea here, or when the user asks to write a spec or an epic.
---

# Spec

A **spec** is a feature the project builds towards. In Jira it is an **epic**; its
stories are the slices `stories` cuts from it. The spec is the source of truth while
it is open: when a decision changes, the epic changes, with a dated line under
**Changes**.

Do not interview the user. Write from what the conversation settled and what the
code shows. The one round you ask is step 3.

Run in a metarepo. Read `AGENTS.md`, `docs/agents/jira.md` (its Layout and Body
format win over this file where they differ), `GLOSSARY.md` and `docs/adr/`. Use
the glossary's words everywhere.

## 1. Explore

Read the code the feature touches, in every repo it touches, until you can name the
modules, the data and how the repos talk to each other. Use one subagent for each
repo when that is broad (model: `printenv WORK_RESEARCH_MODEL`, empty means
`sonnet`, `inherit` means unset).

## 2. Fill the gaps

The spec must be buildable by a smaller model that was not in this conversation. For
each point the conversation left open (a case nobody covered, an error, a limit, what
happens on a second click), decide the smallest thing that closes it.

Check that these are all settled:

- every user story has the modules that own it and the seam where a test sees it;
- each piece of state has its **key** (what identifies it), **scope** (one per user,
  per server, per browser) and **lifecycle** (create, change, delete, create again);
- each new call between repos has its contract: the route or event, the request,
  the response, and each error;
- the e2e journey that proves the feature, and the steps a person does by hand.

## 3. Agree

Put every gap decision, the module split and the acceptance check to the user as
[grilling](../grilling/SKILL.md)'s draft, and publish nothing before they agree.

## 4. Write and publish

TODO: match the epic layout to the team's Jira process (`docs/agents/jira.md`,
Layout). Until then, write this, in the format `jira.md`'s Body format names:

```
Why
<one or two sentences: the user's problem>

What users get
- <one line for each user story: "A <user> can <do what>, so that <why>">

Done when
- <the e2e journey that proves the whole feature, by file path>
- <each step a person does by hand, numbered, with what they should see>

Out of scope
- <what this feature does not do>

▸ Agent notes (folded)
Decisions: <each settled decision, one line, with who settled it>
Repos and modules: <for each repo: the modules that change and what each owns>
State: <each piece of state: key, scope, lifecycle>
Contracts: <each call between repos: route or event, request, response, errors>
Tests: <the seams agreed for each module, and the cases specific to this feature>
Prior art: <similar code and tests to copy from, by path>
Guide: <docs/guides/<name>.html to write or update for people, by which story, or none>
Changes: <dated lines, newest last, when the spec changes after stories exist>
```

Agent notes may name files and functions: a story is built soon after, and the lead
checks each path again before it builds. Write every line so that someone who was not
here can act on it without asking: name the thing, the place, and the expected
result.

Create the epic (`jira.md`, Create an epic). Create `tickets/<EPIC>.md` from the
form, with Status `ready`, the decisions, and a link to the epic.

A feature people must learn to use or run (a new flow, a setup, an operation) gets
a guide for people in the metarepo's `docs/guides/`, written with the
`writing-html-docs` skill by the story the Agent notes name.

A decision that will matter after this epic (hard to undo, or surprising without its
reason) is offered as an ADR in `docs/adr/`, its words agreed in step 3. A new domain
word goes in `GLOSSARY.md`.

## Closing output

```
<EPIC> <title> — spec published
Waiting on you: <anything not agreed, or none>
Next: /stories <EPIC>
```
