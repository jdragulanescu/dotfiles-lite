# Commands

Every command here was run live against a test page (agent-browser 0.38.1, playwright-cli 0.1.21, the Size rows on 0.38.2 and 0.1.22, the `ab` forms and the agent-browser Video row on agent-browser 0.39.0 with ffmpeg-static 5.3.0, and the playwright-cli Video row on 0.1.22). Use `<ref>` exactly as the latest snapshot printed it.

## agent-browser

`ab` runs agent-browser in the session named in `AB`. Set both up before anything else, and run every command of the run through `ab`, `open` first:

```bash
AB=$(agent-browser session id --scope worktree --prefix browser-check)
ab() { PATH="${FF:+$FF:}$PATH" agent-browser --session "$AB" "$@"; }
```

In a run with a step that moves, also put `ffmpeg` on `PATH` before `open`: `agent-browser record` needs it, and the browser's background process runs it with the `PATH` of the command that opened the session, so a session opened without it cannot record until it is closed. With no `ffmpeg` installed, npx fetches one: `ffmpeg-static` has no command of its own, so the line prints the folder its binary is in.

```bash
command -v ffmpeg >/dev/null || FF=$(npx --yes -p ffmpeg-static@5.3.0 -c 'p=${PATH%%:*}; echo "${p%/.bin}/ffmpeg-static"')
```

| Need | Command |
| --- | --- |
| Open | `ab open <url>` |
| Size | `ab set viewport <w> <h>` |
| Snapshot | `ab snapshot -i` (refs look like `@e3`) |
| Act | `ab click @e2`, `ab fill @e3 "<text>"`, `ab press Enter`, `ab select @e4 "<label>"`, `ab check @e5` |
| Assert text | `ab wait --text "<expected>"` — exit 0 pass, exit 1 `✗ Wait timed out` fail (after 25 s; add `--timeout <ms>` to shorten) |
| Assert gone | `ab wait --fn "!document.body.innerText.includes('<text>')"` — same exit codes |
| Read text | `ab get text <sel>`, `ab get url`, `ab get title` |
| Screenshot | `ab screenshot "$DIR/NN-<slug>.png"` |
| Video | `ab record start "$DIR/NN-<slug>.webm"` before the step's action; after its assert, `ab wait 1000`, then `ab record stop` |
| Console | `ab console` |
| Uncaught errors | `ab errors --json \| jq -r '.data.errors[].text'` |
| Failed requests | `ab network requests --status 400-599` |
| Close | `ab close` |

Resource-load 404s show under `network requests`, not `console`. Plain `errors` prints a bare `✗` per error with the message missing, and exits 0: read it with `--json`. Close last: any command after `close` relaunches a browser. So does a command run with different `AGENT_BROWSER_*` env vars than the one that opened the page (it lands on `about:blank`), so never prefix a single command with one.

## playwright-cli

If `command -v playwright-cli` finds nothing, `npx -y @playwright/cli@latest` works in its place. Pass `-s="$S"` on every command. It writes snapshot YAML into `.playwright-cli/` under the working directory, so run it from `$DIR`, never from the repo.

| Need | Command |
| --- | --- |
| Session name | `S=browser-check-$(basename "$(git rev-parse --show-toplevel)")` |
| Open | `playwright-cli -s="$S" open <url>`; later pages: `goto <url>` |
| Size | `playwright-cli -s="$S" resize <w> <h>` |
| Snapshot | `playwright-cli -s="$S" snapshot` (refs look like `e4`) |
| Act | `click e5`, `fill e4 "<text>"`, `press Enter`, `select e6 "<val>"`, `check e7` |
| Assert text | `playwright-cli -s="$S" --raw eval "() => document.body.innerText.includes('<expected>')"` — prints `true` pass, `false` fail; exits 0 either way, so read the output |
| Screenshot | `playwright-cli -s="$S" screenshot --filename="$DIR/NN-<slug>.png"` |
| Video | `playwright-cli -s="$S" video-start "$DIR/NN-<slug>.webm"` before the step's action; after its assert, `sleep 1`, then `playwright-cli -s="$S" video-stop`. Needs no `ffmpeg`; the video is scaled to fit 800x800 (`--size <w>x<h>` on `video-start` changes it) |
| Console | `playwright-cli -s="$S" console error` (includes `Failed to load resource … 404` lines) |
| Uncaught errors | No own command: they are the lines in `console error` without an `[ERROR]` prefix, e.g. `Error: kaboom` plus its stack |
| Failed requests | `playwright-cli -s="$S" requests`, then keep the lines whose `=> [status]` is 4xx or 5xx; it has no status filter |
| Close | `playwright-cli -s="$S" close` |

`find "<text>"` exits 0 even with no match: never use it as an assertion. It launches Google Chrome by default; without it, `open` fails with "Chromium distribution 'chrome' is not found". Point it at agent-browser's Chrome for Testing before `open` (`export PLAYWRIGHT_MCP_EXECUTABLE_PATH="$(fd -1 -t x '^Google Chrome for Testing$' ~/.agent-browser/browsers)"`), or run `playwright-cli install-browser`.

## Screenshot directory

```bash
DIR="${TMPDIR:-/tmp}/browser-check/${AB:-$S}"
mkdir -p "$DIR"
```
