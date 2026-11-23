---
name: browser-check
description: Quick check of UI work against this worktree's own server, or the user's dev server in the main checkout — walks numbered steps and reports what was seen, console errors, failed requests and screenshots. Use for a `browser-check` Verify line or a changed screen no e2e path covers at acceptance, to reproduce a UI bug, or to show a visual proposal.
---

# Browser Check

Drive the app's server through numbered steps and report, per step, what the browser showed. The report is a **walkthrough**: `implement` records it in the story's ticket note, and the story's e2e step is written from it, so every step names a concrete URL, an element by its accessible name, and the exact text expected.

A check is evidence, not a test. It never replaces the fast suite or an e2e file (see `~/.claude/docs/testing.md`).

Exact commands for both tools are in [COMMANDS.md](COMMANDS.md).

## 1. Inputs

- **URL**: the one the caller gives; else, in a worktree, the URL its **Start** prints (the repo's section of the project's testing doc, `<project>-meta/docs/agents/testing.md`); in the main checkout, the user's dev server, whose URL you ask for. The first step's `open` is the probe. If nothing answers, stop and say which server is down.
- **Steps**: numbered, from the caller or the ticket's acceptance criteria. Each step is one action and one expected result. Rewrite a vague step ("check the form works") into a concrete one before running it, and show the rewrite in the report.

**Done when** the URL answers and every step has an action and an expected text.

## 2. Tool

Take the first that applies:

1. The tool the project's testing doc names under **Browser tool**.
2. `agent-browser`, if `command -v agent-browser` finds it.
3. `playwright-cli`, if `command -v playwright-cli` finds it.

Neither → stop and give the install line: `brew install agent-browser`, then `agent-browser install` if no Chrome is installed.

## 3. Session

One named session per worktree, so parallel runs never share a browser. Name it, and keep screenshots and videos outside the repo in `${TMPDIR:-/tmp}/browser-check/<session>/`, never committed. When a step moves something (see 4) and the tool is `agent-browser`, put `ffmpeg` on `PATH` before the session opens, as [COMMANDS.md](COMMANDS.md#agent-browser) shows. Close the session at the end, pass or fail.

## 4. Walk the steps

For each step, in order:

1. **Snapshot** to get element refs. Take a fresh one after every navigation, and after a dialog opens or closes; refs taken before the change are stale.
2. **Act** on the ref whose accessible name matches the step (click, fill, press, open).
3. **Assert** the expected text mechanically. With `agent-browser`, `wait --text` exits 0 on pass and 1 on fail. With `playwright-cli`, `find` exits 0 even with no match, so assert with `--raw eval` and read `true`/`false`.
4. **Screenshot** when the step changed the view, named `NN-<slug>.png`.

A step that **moves** something (a drag, a scroll, an animation: a step whose motion is what it checks, which a screenshot of where it ended cannot show) is also recorded as a video, `NN-<slug>.webm`: start recording before its action and stop a second after its assert: an assert can pass while the motion is still going, and stopping at once cuts its end off. Both tools record, as [COMMANDS.md](COMMANDS.md) shows.

A failed step is recorded, not retried into passing. Continue with the remaining steps only if they do not depend on the failed one; mark the rest `skipped`.

After the last step, collect console errors, uncaught page errors, and failed requests (status 4xx/5xx).

**Done when** every step has a pass, fail or skipped result, the three lists are collected, and the session is closed.

## 5. Report

Print this block exactly. It is what the caller records, and the caller's run goes on from it: when a skill called this one, its next step follows in the same turn.

```
Browser check — <url> — <tool>, session <session>
1. <action: URL / element by accessible name / value> → seen: <what the page showed> → pass | fail | skipped
2. ...
Console: none | <each error message>
Errors: none | <each uncaught error>
Failed requests: none | <METHOD url status>, ...
Screenshots: <directory> (<files>)
Videos: none | <each .webm>
Verdict: pass | fail — <failed step numbers, and any console error, uncaught error or failed request>
```

Screenshots and Videos name every file the run saved, so the caller can attach them.

The verdict is **pass** only when every step passed and Console, Errors and Failed requests are all `none`. Every line is still reported, but a missing `/favicon.ico` alone never fails the check. Anything else is **fail**, and the caller decides what it means.

**Done when** the block is printed with every line filled.
