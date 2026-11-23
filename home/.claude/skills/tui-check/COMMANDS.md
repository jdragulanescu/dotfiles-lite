# Commands

Every command here was run live (tmux 3.7c) against two probe apps: a curses app, and a raw-mode app that turns on SGR mouse mode and button-event tracking (modes 1006 and 1002). The Drag row was run on tmux 3.8 against both, each drag recorded with `video`. The image and video rows were run on tmux 3.8, agent-browser 0.39.0, ansi-to-html 0.7.2 and ffmpeg-static 5.3.0, against a screen of 16-colour, 256-colour and truecolour text and a block that moves. The Find text row was run on tmux 3.8 and Python 3.15 against a screen of `×`, `日本` and one text on three rows. The Run folder and Clipboard sections were run on tmux 3.8 and macOS 27: two runs at once in one worktree, each with its own session, helper file and captures folder, and a copy made during a walk, which `clip_restore` undid. On macOS 27, `clip_save` and `clip_restore` were also run, in zsh and in bash, on a clipboard holding a PNG image (it came back with the same bytes and the same nine types), two items each with two types, an empty clipboard, a saved file that could not be read, an item with `org.nspasteboard.ConcealedType` or `org.nspasteboard.TransientType`, alone and beside a plain-text item (it came back with the same bytes and types, and `clip_save` printed its line), and a plain-text item beside a PNG image (it came back whole, and `clip_save` printed nothing); each time the saved file was gone after the restore. The Linux clipboard commands were not run.

Make the [run folder](#run-folder) first, and start every later shell call by sourcing its helper file. Use `-t "$S"` on every tmux command, and `ab` (below) for every agent-browser one.

| Need | Command |
| --- | --- |
| Session name | `S`, the [run folder](#run-folder)'s name (`tui-check-` and six random letters and digits): new for each run, so two runs in one worktree never share a screen, and free of the `.` that tmux reads in `-t` as a window.pane |
| Open | `tmux new-session -d -s "$S" -x <cols> -y <rows>`, then `tmux send-keys -t "$S" '<launch command>' Enter`. Default 140x40. The shell stays behind the app, so a crash leaves its output on screen. |
| Save clipboard | `clip_save`, in [Clipboard](#clipboard) below, after Open and before the first step |
| Capture | `tmux capture-pane -p -t "$S"` (plain text; add `-e` for colours) |
| Find text | `find_text '<text>' [nth] [from-row]`, below: prints `<col> <row>` of the text's first cell |
| Keys | `tmux send-keys -t "$S" Down Enter`; names: `Up`, `Down`, `Left`, `Right`, `Enter`, `Escape`, `Tab`, `BSpace`, `C-b` (Ctrl-b), `M-x` (Alt-x), `F1`. A lone `;` goes as `tmux send-keys -t "$S" -H 3b`: tmux reads a `;` argument as its command separator and drops it, with or without `-l` |
| Text | `tmux send-keys -t "$S" -l '<text>'` (`-l` sends it as typed, never as key names) |
| Click | Raw bytes with `-H`, below. A click is a press then a release. |
| Drag | Raw bytes with `-H`, below |
| Assert text | `wait_text '<expected>'`, below: exit 0 pass, exit 1 fail after 10 s |
| Browser session | `AB` and `ab`, in [Browser](#browser) below |
| Save capture | `shot NN-<slug>`, below: the text, and the image with its colours |
| Video | `video NN-<slug> <frame> <frame> …`, below |
| Close | `clip_restore`, then `tmux kill-session -t "$S"`, then `ab close`, pass or fail |

## Run folder

Each shell call starts afresh, so the helpers below live in one file per run, in a folder of its own that also names the run's sessions and holds its captures:

```bash
RUN=$(mktemp -d "${TMPDIR:-/tmp}/tui-check-XXXXXX")
S=${RUN##*/}
mkdir "$RUN/captures"
printf "RUN='%s'\nS='%s'\nDIR='%s/captures'\nAB='%s'\n" "$RUN" "$S" "$RUN" "$S" > "$RUN/helpers.bash"
echo "$RUN"
```

Append every function below (`wait_text`, `find_text`, `sgr`, `x10`, `ab`, `shot`, `video`, `clip_save`, `clip_restore`) to `$RUN/helpers.bash`, and the `FF` line's value when [Browser](#browser) sets it, then start every later shell call with `source '<the printed folder>/helpers.bash'`. Never write the helpers to a fixed path such as `/tmp/tui-check-helpers/h.sh`: a run beside this one overwrites it, and this run's keys go into the other run's session.

## Waiting for text

A poll on the screen itself, with a deadline:

```bash
wait_text() {
  local end=$((SECONDS + 10))
  until tmux capture-pane -p -t "$S" | rg -qF -- "$1"; do
    [ "$SECONDS" -ge "$end" ] && return 1
    sleep 0.2
  done
}
```

## Finding text

The cell a click or drag aims at, in the [mouse](#mouse) numbering: `find_text` counts screen cells, so a wide character (`日`) is two and a combining mark none, where a count of bytes lands past the text. `nth` picks the nth match (default 1), and `from-row` skips the rows above it, so a tab strip or status line that shows the same text is passed over. Exit 1 when there is no match.

```bash
find_text() {
  tmux capture-pane -p -t "$S" | python3 -c '
import sys, unicodedata
text, nth, first = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
for row, line in enumerate(sys.stdin.read().splitlines(), 1):
    i = line.find(text) if row >= first else -1
    while i != -1:
        nth -= 1
        if nth == 0:
            col = 1 + sum(0 if unicodedata.combining(c) else 2 if unicodedata.east_asian_width(c) in "WF" else 1 for c in line[:i])
            print(col, row)
            sys.exit(0)
        i = line.find(text, i + 1)
sys.exit(1)
' "$1" "${2:-1}" "${3:-1}"
}
```

`read -r col row < <(find_text 'notes.md' 1 3)` puts the cell in two variables.

## Mouse

Columns and rows count from 1 at the top left of the pane, in screen cells: [find_text](#finding-text) gives a text's cell. Buttons: `0` left, `1` middle, `2` right, `64` wheel up, `65` wheel down. `send-keys -l` splits an escape sequence and the app reads plain keys; send the bytes with `-H`.

A **drag** is a press at the start cell, one move or more with the button held, and a release at the end cell. A move is the button plus 32, sent to a cell on the way: as many moves as the step needs to show the travel, the last at the end cell. Send each event on its own, so a frame can be saved after it ([Video](#video)).

- **SGR** (apps that turn on mode 1006: crossterm and ratatui, bubbletea, textual): press `ESC [ < b ; col ; row M`, release the same ending in `m`. `sgr` sends one event; a fourth argument `m` makes it a release. A click, then a drag:

  ```bash
  sgr() { printf '\e[<%d;%d;%d%s' "$1" "$2" "$3" "${4:-M}" | od -An -tx1; }
  tmux send-keys -t "$S" -H $(sgr 0 <col> <row>) $(sgr 0 <col> <row> m)

  tmux send-keys -t "$S" -H $(sgr 0 <col> <row>)
  tmux send-keys -t "$S" -H $(sgr 32 <next col> <next row>)
  tmux send-keys -t "$S" -H $(sgr 0 <end col> <end row> m)
  ```

- **X10** (curses apps, which read the mouse through terminfo): press `ESC [ M` then three bytes, `32+b`, `32+col`, `32+row`; release is button `3`. It cannot reach past column or row 223: for a cell beyond that, open the session narrower or shorter. A click, then a drag:

  ```bash
  x10() { printf '1b 5b 4d %x %x %x' $((32 + $1)) $((32 + $2)) $((32 + $3)); }
  tmux send-keys -t "$S" -H $(x10 0 <col> <row>) $(x10 3 <col> <row>)

  tmux send-keys -t "$S" -H $(x10 0 <col> <row>)
  tmux send-keys -t "$S" -H $(x10 32 <next col> <next row>)
  tmux send-keys -t "$S" -H $(x10 3 <end col> <end row>)
  ```

When `testing.md` does not say which the app reads, try SGR on the first click or drag, then X10, and name the one that worked in the report.

## Capture directory

`$DIR`, the run folder's `captures/`, made with the folder: each run, and so each walk, has its own.

## Browser

Define `ab` and put `ffmpeg` on `PATH` with the two snippets in [browser-check's agent-browser section](../browser-check/COMMANDS.md#agent-browser), for the reason it gives, in every run and before the first `ab` call: the first `shot` opens the session a later `video` records in. That `ab` reads its session from `AB`, which the helper file sets to the run's own, `$S`, in place of browser-check's `AB` line: agent-browser takes a session name of letters, digits, hyphens and underscores, which `S` is. One browser session per run, not per worktree, so two runs never draw into one viewport.

## Images

`capture-pane -e` keeps the colours as escape codes; `ansi-to-html` turns them into HTML (`-x` escapes the screen's `<` and `&`), and agent-browser screenshots the `pre` that holds it. The font list names the Nerd Font first, so a prompt's icons are drawn rather than shown as boxes.

```bash
shot() {
  tmux capture-pane -p -t "$S" > "$DIR/$1.txt"
  {
    printf '<body style="margin:0;background:#000"><pre style="margin:0;padding:8px;color:#fff;font:14px/1.25 JetBrainsMono Nerd Font,Menlo,monospace">'
    tmux capture-pane -p -e -t "$S" | npx --yes ansi-to-html@0.7.2 -x
    printf '</pre>'
  } > "$DIR/$1.html"
  ab open "file://$DIR/$1.html"
  ab screenshot pre "$DIR/$1.png"
}
```

## Video

For a step that moves, save a frame after each event of its action (`shot NN-<slug>-1`, `shot NN-<slug>-2`, …), then record them, half a second each:

```bash
video() {
  local name=$1 first=$2 frame
  shift 2
  ab set viewport 1280 720
  ab open "file://$DIR/$first.html"
  ab record start "$DIR/$name.webm"
  for frame in "$@"; do
    ab wait 500
    ab open "file://$DIR/$frame.html"
  done
  ab wait 500
  ab record stop
}
```

The video shows only the browser's viewport, which is 1280x578 unless set, so `video` sets it to 1280x720, which holds the default 140x40 pane; for a larger pane, raise both numbers to the size of its image.

## Clipboard

A step can copy (a key the app binds to copy, a drag that selects), and the copy lands in the user's clipboard. `clip_save` keeps it when the walk starts, and `clip_restore` puts it back when the walk ends, pass or fail, whatever the steps did; a step that tests a copy reads `pbpaste` in its own assert, before the restore.

`clip_save` keeps every item on the clipboard with the data of each of its types, so an image (a screenshot) comes back as an image, and an empty clipboard comes back empty. `clip_restore` deletes the saved file after it puts the clipboard back, also when the restore fails, because the file can hold a secret (a password just copied).

```bash
clip_save() {
  osascript -l JavaScript - "$RUN/clipboard.json" <<'JXA'
ObjC.import('AppKit')
function run(argv) {
  const items = $.NSPasteboard.generalPasteboard.pasteboardItems
  const secret = ['org.nspasteboard.ConcealedType', 'org.nspasteboard.TransientType'], saved = []
  let marked = false
  for (let i = 0; i < (items.isNil() ? 0 : items.count); i++) {
    const item = items.objectAtIndex(i), types = ObjC.deepUnwrap(item.types), pairs = []
    if (types.some(type => secret.includes(type))) marked = true
    for (const type of types) {
      const data = item.dataForType(type)
      if (!data.isNil()) pairs.push([type, ObjC.unwrap(data.base64EncodedStringWithOptions(0))])
    }
    saved.push(pairs)
  }
  $(JSON.stringify(saved)).writeToFileAtomicallyEncodingError(argv[0], true, $.NSUTF8StringEncoding, null)
  if (marked) return "clipboard: a password manager's copy kept"
}
JXA
}
clip_restore() {
  [ -f "$RUN/clipboard.json" ] || return 0
  osascript -l JavaScript - "$RUN/clipboard.json" <<'JXA'
ObjC.import('AppKit')
function run(argv) {
  const saved = JSON.parse(ObjC.unwrap($.NSString.stringWithContentsOfFileEncodingError(argv[0], $.NSUTF8StringEncoding, null)))
  const board = $.NSPasteboard.generalPasteboard, objects = $.NSMutableArray.array
  for (const pairs of saved) {
    const item = $.NSPasteboardItem.alloc.init
    for (const [type, data] of pairs) item.setDataForType($.NSData.alloc.initWithBase64EncodedStringOptions(data, 0), type)
    objects.addObject(item)
  }
  board.clearContents
  if (saved.length) board.writeObjects(objects)
}
JXA
  local rc=$?  # never `status`: zsh, which sources this file too, keeps that name read-only
  rm -f "$RUN/clipboard.json"
  return "$rc"
}
```

When an item has the type `org.nspasteboard.ConcealedType` or `org.nspasteboard.TransientType`, which a password manager puts on the password it copies, `clip_save` still keeps it, with those types, and prints `clipboard: a password manager's copy kept`. When it printed that line, the report's Clipboard line takes its second form: the manager's timed wipe does not remove a copy that `clip_restore` puts back, so the password stays on the clipboard after the walk.

On Linux, both keep text only, and were not run: `clip_save` is `wl-paste -n > "$RUN/clipboard.json"` (Wayland) or `xclip -selection clipboard -o > "$RUN/clipboard.json"` (X11), and `clip_restore` puts it back with `wl-copy` or `xclip -selection clipboard` from that file, then deletes the file as above. With none of them, there is no clipboard to keep, and both do nothing.

The report's Clipboard line takes its third form, `not put back: <why>`, when the clipboard did not come back: `clip_restore` exits non-zero (it could not read the saved file), `clip_save` wrote no `$RUN/clipboard.json` (then `clip_restore` returns 0 but puts nothing back), or, on Linux, the clipboard held something that is not text, or there is no clipboard tool. The `<why>` names which of these it was.
