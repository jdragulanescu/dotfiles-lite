---
name: writing-html-docs
description: Writes documentation a person reads (a guide, explainer, how-to, onboarding page) as one self-contained HTML page, or edits one. Use whenever a new doc is for humans; Markdown that agents read (AGENTS.md, CLAUDE.md, skills, docs/agents/, research notes, ADRs, GLOSSARY.md) stays Markdown.
---

A self-contained `.html` file in a dark, PlanetScale-blog style: one reading column, sticky "On this page" sidebar, plain teaching prose (ASD-STE100). The look lives in [`template.html`](template.html); the writing rules live in [`prose.md`](prose.md). The page's sections are the user's choice: the style is the contract, the outline is not.

## Steps

1. **Start from the template.** Copy `template.html` to the target path. Keep its CSS and JS, and the three things that say they are the template's: the `template-version` line in the head, and the `data-template` mark on its `<style>` and on its `<script>`. A script of the page's own goes in a second `<script>` with no mark. Replace the `UPPERCASE` placeholders. Done when the file opens with the user's title, top bar, and empty sections.
2. **Ground the facts.** When the page is based on code, read that code and run it to get every number, formula, and rule. Write a small check script (for example `/tmp/chk.py`) that calls the code with the page's example inputs and prints the outputs. The code is the truth: a claim the code does not support is removed or marked with `<span class="pill assume">assumption</span>`. External facts get a `.srcline` with links to official sources. Done when every number in the page appears in the check output or has a source link.
3. **Write the prose** by [`prose.md`](prose.md). Read it before writing the first paragraph.
4. **Build with the components** below. Done when each abstract rule has a worked example.
5. **Check.** Every `href="#x"` has a matching `id`; if there is a glossary, every `a.g` points at a `dt` in it; the check script still matches the page; the TOC lists every `h2` (and the `h3`s worth jumping to). A browser screenshot is optional.

Before a large edit to an existing page, copy it to `/tmp/<name>.vN.html`. Make string edits with a replace that asserts the old text occurs exactly once, so a reformatted file fails loudly instead of silently.

## Visual style

- **Frames, not stripes.** Callouts, dives, cards, figures, and playgrounds are a 1px `--line` border, `--bg-2` background, 8–10px radius. The type colour appears only in the small mono label (`.t`, `.k`). Every border is the same grey on all four sides.
- **Tables are open:** row lines only, mono uppercase headers, `td.num` right-aligned for numbers, `tr.total` for totals.
- **Colour is a signal:** orange `--accent` for section numbers, answers, and the active state; blue = note/deep dive; amber = warning/assumption; red = risk; green = tip/ok. Body text stays grey-white.
- **Mono for machinery:** labels, numbers, equations, captions, the TOC. Sans for prose.
- Self-contained: no external CSS, fonts, or JS libraries. Diagrams are inline SVG inside `<figure>`.

## Components (all styled in the template)

| Markup                                                | Use for                                                                     |
| ----------------------------------------------------- | --------------------------------------------------------------------------- |
| `h2 id` + `<span class="n">01 · LABEL</span>`         | Section with an orange eyebrow; add it to `aside.toc`                       |
| `.grid` > `a.card` (`.k`, `h4`, `p`)                  | Map of the page under the lede                                              |
| `.call.note` / `.warn` / `.risk` / `.tip` + `.t`      | One short boxed point                                                       |
| `details.dive` > `summary` (`.k` DEEP DIVE) + `.body` | Optional maths, proofs, edge cases: the main text reads complete without it |
| `.eq` with `.c` comments and `.a` answers             | Worked equations with real numbers                                          |
| `.tbl` > `table`                                      | Comparisons, symbol tables, step results                                    |
| `ol.steps`                                            | A process in order                                                          |
| `figure` > `svg` + `figcaption`                       | Diagrams: timelines, flows, who-pays-whom                                   |
| `.codehead` + `pre` (`.c .k .s .f`)                   | Code, only when the reader writes code                                      |
| `.pill.assume` / `.pill.ok`                           | Inline status badge                                                         |
| `.src.c-*`                                            | Tag for where a value comes from (rename classes per topic)                 |
| `dl.gloss` > `dt id="g-…"` (`<i>` other names) + `dd` | Glossary, optional (see below)                                              |
| `a.g href="#g-term"`                                  | Term link; the JS shows the glossary definition on hover                    |
| `.play` > `.tabs` + `.panel` + inputs + `.out`        | Interactive playground                                                      |

**Playground:** include one when the page is technical and has calculations a reader would want to try. Vanilla JS in a `<script>` of the page's own, with no mark, defaults equal to the worked example, and a comment plus visible note that it is for learning only (float maths, not production). Its outputs for the default inputs must match the check script.

**Glossary:** a `dl.gloss` section at the end of the page. Each entry is a `dt id="g-term"` (other names in `<i>(also: …)</i>`) and a `dd` with the one definition. In the text, `a.g href="#g-term"` links show that definition on hover. Add the section to the TOC. Without a glossary, delete the template's section and TOC entry.

**Trading card:** a shiny collectible card for one object and its properties, like a Pokémon card. Build it in the page's tokens: a gradient frame, holo shine that follows the pointer, a slight tilt, click or Enter to flip to the back, and real values from step 2 on both faces.
