---
name: tui-check
description: Quick check of terminal UI work against this worktree's own server — drives the TUI in a tmux session through numbered steps (keys, text, mouse clicks and drags) and reports what the screen showed. Use for a `tui-check` Verify line or a changed TUI screen no e2e path covers at acceptance, or to reproduce a TUI bug.
---

# TUI Check

Drive the app's TUI through numbered steps and report, per step, what the screen showed. It is `browser-check` for a terminal app, and its report is the same kind of **walkthrough**: `implement` records it in the story's ticket note and uses it for the story's evidence, so every step names a concrete key, text or screen cell, and the exact text expected.

A check is evidence, not a test. It never replaces the fast suite or an e2e file (see `~/.claude/docs/testing.md`). Its worth is that it runs the real client against the real server: a request the real server refuses, which a fake in the tests let through, fails here.

Exact commands are in [COMMANDS.md](COMMANDS.md).

## 1. Inputs

- **Launch**: in a worktree, use the server the caller already started (`implement` runs **Start**, from the repo's section of the project's testing doc, `<project>-meta/docs/agents/testing.md`); with none running, run **Start** yourself, and with Start `none` the TUI needs no server. Then open the TUI with the **TUI** command from the same section, which also says how the app takes input (its window size, its mouse encoding). With no **TUI** line, find the command that opens this worktree's TUI against that server (the repo's task runner, README), use it, and suggest the line in the report. In the main checkout, ask the user which server to point at.- **Steps**: numbered, from the caller or the ticket's criteria and Verify line. Each step is one action (a key, typed text, a click at a named row or cell, a drag from one cell to another) and one expected text. Rewrite a vague step ("check the menu works") into a concrete one before running it, and show the rewrite in the report.

**Done when** the TUI shows its first screen in the session with no connection error, and every step has an action and an expected text.

## 2. Session

`tmux` drives the TUI, and `agent-browser` turns its screens into images and videos; if `command -v` finds either missing, stop and give its install line (`brew install tmux`, or `apt install tmux`; `brew install agent-browser`, then `agent-browser install` if no Chrome is installed). Each run makes its own run folder first, outside the repo, and takes from it its own tmux session name, browser session, helper file and captures folder, so two runs, in one worktree or two, never share a screen, a helper or a capture. A run walks its steps once, so each walk has its own captures folder; walking again is a new run. Keep captures, images and videos in it, never committed. Save the clipboard when the walk starts, before the first step, and put it back when it ends, pass or fail, whatever the steps did to it: a step that tests a copy reads the clipboard in its own assert. At the end, put the clipboard back, then kill the tmux session and close the browser, pass or fail. Run the worktree's **Stop** only when this run ran Start; a server the caller started is the caller's to stop.

## 3. Walk the steps

For each step, in order:

1. **Capture** the screen to find what to act on: a row's text, and for a click its column and row, for a drag its start and end cells, each cell on a text taken from `find_text`.
2. **Act**: send the keys, the text, or the mouse sequence.
3. **Assert** the expected text by waiting for it on the screen, with a deadline. A timeout is a fail. Pick expected text the step-1 capture does not already show; text already on screen passes before the action has done anything.
4. **Save** the capture when the step changed the screen: the text as `NN-<slug>.txt`, and the same screen with its colours as `NN-<slug>.png`, so a wrong colour or a misdrawn cell shows in the evidence. A step whose expected result is a colour or a style (dim text, an accent, a fill) takes its pass or fail from that image, opened and read: the text capture keeps a label's text even when it is drawn in the background colour.

A step that **moves** something (as [browser-check's Walk the steps](../browser-check/SKILL.md#4-walk-the-steps) defines it) also saves a frame after each event of its action, and records the frames as a video, `NN-<slug>.webm`.

A failed step is recorded, not retried into passing. Continue with the remaining steps that do not depend on the failed one; mark the ones that do `skipped`.

After the last step, collect every error the app showed on screen (a refusal, a status-line error, a panic) and, when `testing.md` names the server's log, the errors it logged during the run.

**Done when** every step has a pass, fail or skipped result, the errors are collected, the clipboard holds what it held before the walk, the tmux session is killed and the browser is closed.

## 4. Report

Print this block exactly. It is what the caller records, and the caller's run goes on from it: when a skill called this one, its next step follows in the same turn.

```
TUI check — <launch command> — tmux <cols>x<rows>, session <session>
1. <action: keys / text / click at col,row on "<text>" / drag from col,row to col,row> → seen: <what the screen showed> → pass | fail | skipped
2. ...
Screen errors: none | <each error the app showed>
Server log: none | not named | <each error logged>
Captures: <directory> (<each .txt>)
Images: <each .png>
Videos: none | <each .webm>
Clipboard: put back | put back, with a password a password manager copied: its timed wipe will not remove it | not put back: <why>
Verdict: pass | fail — <failed step numbers, and any error>
```

Images and Videos name every file the run saved, so the caller can attach them.

The verdict is **pass** only when every step passed and Screen errors and Server log are `none` or `not named`. Anything else is **fail**, and the caller decides what it means.

**Done when** the block is printed with every line filled.
