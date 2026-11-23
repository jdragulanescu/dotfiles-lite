# Evidence

How the before and after of a story are recorded, so a reviewer sees what changed
without running anything. The lead gives this file to one subagent, with: the story's
**How to try it** steps, each repo's story worktree and base, the metarepo path, and
the output folder `${TMPDIR:-/tmp}/evidence/<KEY>/`. The brief ends: "Do the work
yourself; spawn no agents. Report the files you made and the What to look at list."

## Pick the form

| The story changes | Evidence |
| --- | --- |
| A web screen, and something moves or happens over time (a click that loads, a dialog, a drag, a list that fills) | **Video**, before and after side by side |
| A web screen, and only a text, colour or layout changes | **Screenshots**, before and after side by side, at most 3 |
| A terminal UI | `tui-check`'s images or video, joined side by side the same way |
| No screen (an API, a job, a CLI) | The command or test output before and after, as text |

Video is the default whenever both fit.

## Make the steps concrete

Rewrite each How to try it step as one action and one expected text: a URL, an
element by its visible text or label, and the exact text that shows after. At most
about 8 steps, so the video stays under 60 seconds; a story with more gets one video
for each journey.

## Before and after

- **After**: the story's worktrees, each started with its **Start** from
  `<metarepo>/docs/agents/testing.md`.
- **Before**: for each repo the steps need, a worktree at its base, started the same
  way:

  ```bash
  git -C <project>/<repo> worktree add --detach <project>/worktrees/<repo>/<KEY>-before <base>
  ```

  Run its **Setup** and **Start**. When you are done, run its **Stop**, then
  `git -C <project>/<repo> worktree remove <project>/worktrees/<repo>/<KEY>-before`.

Walk the same steps on both. On **before**, a step may fail because the feature is
not there yet: that is the point. Record what the page shows, with a short wait
(`--timeout 3000`), and go on.

## Record a walk (agent-browser)

Set up the session as browser-check's [COMMANDS.md](../browser-check/COMMANDS.md#agent-browser)
says (`ab`, and `ffmpeg` on `PATH`). Then, in one helper file the run sources in
every shell call:

```bash
OUT="${TMPDIR:-/tmp}/evidence/<KEY>"; mkdir -p "$OUT"
now() { perl -MTime::HiRes=time -e 'printf "%.1f", time'; }
since() { perl -e "printf '%d:%02d', int(($(now) - $1)/60), ($(now) - $1) % 60"; }
caption() {  # caption "<text>": a bar at the bottom of the page
  ab eval "(() => { let c = document.getElementById('__ev'); if (!c) { c = document.createElement('div'); c.id = '__ev'; c.style.cssText = 'position:fixed;left:0;right:0;bottom:0;z-index:2147483647;padding:14px 24px;background:rgba(13,17,23,.92);color:#fff;font:600 22px/1.35 -apple-system,system-ui,sans-serif;pointer-events:none'; document.body.appendChild(c); } c.textContent = $(jq -Rn --arg t "$1" '$t'); })()" >/dev/null
}
mark() {  # mark "<visible text or label>": a yellow outline on that element
  ab eval "(() => { document.querySelectorAll('[data-ev]').forEach(e => { e.style.outline = ''; e.removeAttribute('data-ev'); }); const want = $(jq -Rn --arg t "$1" '$t'); const e = [...document.querySelectorAll('button,a,input,select,textarea,label,[role],h1,h2,h3,li,td')].find(x => (x.getAttribute('aria-label') || x.innerText || x.value || '').trim() === want); if (!e) return false; e.setAttribute('data-ev', ''); e.style.outline = '4px solid #f5c518'; e.style.outlineOffset = '3px'; e.scrollIntoView({block: 'center'}); return true; })()" >/dev/null
}
```

Each walk (`before`, then `after`):

1. `ab set viewport 1280 800`, `ab open <first URL>`, then
   `ab record start "$OUT/<walk>.webm"` and `T0=$(now)`.
2. Each step `n`:
   - note `since $T0` as the step's time (the after walk's times go in the list);
   - `caption "<n>. <action> → <expected>"` and `mark "<element>"`, then `sleep 1.5`,
     so the viewer sees what is about to happen;
   - act (`ab click`, `ab fill`, …) and assert (`ab wait --text "<expected>"`);
   - `caption "<n>. ✓ <what now shows>"` (on before: `"<n>. ✗ <what shows instead>"`),
     then `sleep 2.5`, so the result stays on screen. A page load removes the bar,
     so this sets it again.
3. `caption "<KEY>: done"`, `sleep 1.5`, `ab record stop`.

## Join them

```bash
side_by_side() {  # side_by_side <before> <after> <out> [ffmpeg output options]
  local font=/System/Library/Fonts/Supplemental/Arial\ Bold.ttf
  [ -f "$font" ] || font=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
  local pane="pad=iw+2:ih+2:1:1:color=0x30363d,pad=iw+64:ih+104:32:80:color=0x0d1117,drawtext=fontfile='$font':fontsize=20:fontcolor=white:box=1:boxborderw=9:x=(w-tw)/2:y=32"
  "${FF:+$FF/}ffmpeg" -y -loglevel error -i "$1" -i "$2" -filter_complex \
    "[0]$pane:boxcolor=0xda3633:text=BEFORE[b];[1]$pane:boxcolor=0x238636:text=AFTER[a];[b][a]xstack=inputs=2:layout=0_0|w0-32_0:fill=0x0d1117,scale='min(1920,iw)':-2,pad=ceil(iw/2)*2:ceil(ih/2)*2:color=0x0d1117" \
    "${@:4}" "$3"
}
side_by_side "$OUT/before.webm" "$OUT/after.webm" "$OUT/before-after.mp4" -c:v libx264 -pix_fmt yuv420p -movflags +faststart
```

Both walks play together; the shorter holds its last frame. For screenshots, join each
pair the same way into a `.png` (no output options).

## What to look at

Write `$OUT/what-to-look-at.md`, one line for each step, with the after walk's time:

```
- 0:04 · 1. Open Reports — before: no Export button; after: Export shows beside Print
- 0:09 · 2. Click Export — before: —; after: report.csv downloads and a "Saved" toast shows
```

Say what to look at, not only what was done. Then watch the joined video once at its
step times (screenshots at each time are enough): a caption that is cut off, a step
that is too fast to follow, or an outline on the wrong element is fixed and recorded
again.

## Without a screen

Run the same command or test at the base and at the head, and keep both outputs,
trimmed to the lines that differ, as `before.txt` and `after.txt`, with one line on
what to look at.
