# Coding standards

The code-shape rules for every repo. This file lives once, at
`~/.claude/docs/coding-standards.md`, and is never copied into a project. A
repo's own `CODING_STANDARDS.md` adds to it, and wins where the two conflict.

Each rule has a row per linter naming the lint rule that enforces it, or `none`
when the linter has no rule for it. A row lists only a lint rule verified
against that linter's docs; a linter missing from a table gets its row once its
rule names are verified. `partial` means the lint rule enforces only part of the
rule, and the rest is still checked by reading the code.

## Flat conditionals

Keep conditionals **flat**: a conditional that produces a value (a ternary, or
an `if`/`match`/`switch` expression) never contains another one; put the inner
one in a variable or return early.

| Linter | Lint rule |
| --- | --- |
| ESLint core | `no-nested-ternary` |
| sonarjs | `sonarjs/no-nested-conditional` |
| typescript-eslint | none |
| clippy | none |
| Ruff | none |

## Cognitive complexity

Keep every function's Cognitive Complexity at 15 or below.

| Linter | Lint rule |
| --- | --- |
| ESLint core | none |
| sonarjs | `sonarjs/cognitive-complexity` (its threshold defaults to 15) |
| typescript-eslint | none |
| clippy | `clippy::cognitive_complexity` (restriction group; its threshold defaults to 25, so set `cognitive-complexity-threshold = 15` in `clippy.toml`) |
| Ruff | `C901` (`complex-structure`), partial: caps McCabe complexity (decision points), not nesting; its threshold defaults to 10, so set `lint.mccabe.max-complexity = 15` |

## Comments

Write code that reads without comments. When you want a comment to explain
what code does, rename or restructure the code instead. A comment stays only
for what code cannot say: why it is this way (a workaround, a constraint, an
outside contract), with the link behind it.

| Linter | Lint rule |
| --- | --- |
| ESLint core | none |
| sonarjs | none |
| typescript-eslint | none |
| clippy | none |
| Ruff | none (`ERA001` flags only commented-out code) |

## Readonly members

Make a class member **readonly** when nothing reassigns it.

| Linter | Lint rule |
| --- | --- |
| ESLint core | none |
| sonarjs | none |
| typescript-eslint | `@typescript-eslint/prefer-readonly`, partial: private members only |
| clippy | none (Rust has no readonly modifier; bindings and fields are immutable unless declared `mut`) |
| Ruff | none |
