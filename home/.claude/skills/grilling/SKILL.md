---
name: grilling
description: Draft an answer to a plan, decision, or idea for the user to read, then grill them relentlessly on the branches they challenge. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Reach a shared understanding of a plan, decision, or idea. Map it as a **design tree**: every decision branches into the decisions that hang off it. Work the tree **draft-first**: you answer every decision yourself, the user reads the **draft**, and the branches they challenge get grilled.

Finding _facts_ is your job, never the user's. When a decision needs a fact from the environment (filesystem, tools, the web), look it up yourself, or dispatch a sub-agent when the digging is broad. The _decisions_ are the user's: a drafted answer is a proposal until they agree to it.

Docs a companion skill maintains (glossary terms, ADRs) are written only from decisions the user has agreed to or answered themselves. A decision that proposes a glossary term or an ADR carries its exact wording, so agreeing covers the text. This rule outranks a companion skill's instruction to write inline.

## 1. Draft

Collect the facts first; a draft resting on a fact you haven't looked up is a guess.

Some facts only the user holds: their goal, a constraint, a taste. When the root of the tree hangs on one, and a wrong guess would redraw the whole draft, ask it before drafting, once the facts are in: one round, three questions at most, each written as **Asking the user** in `~/.claude/CLAUDE.md` describes, with your recommended answer last. Everything below the root gets drafted. A turn that ends on those questions is complete; draft once they are answered, and carry each answer into the draft as a decision the user settled.

Then walk the tree from the root, giving every decision your recommended answer and treating each answer as settled for the decisions below it. A decision earns an id when a reasonable person could choose otherwise; what follows mechanically from its parent is stated in the parent's line. A decision an earlier ticket or ADR already made is a fact, listed under What I found, unless this session was asked to reopen it.

Present the draft in this shape, written for a reader arriving cold:

```
# <what is being decided>

## Problem
<what is unclear today, why it matters, and what settling it unblocks, in the user's terms. When a ticket started this session, this is the question that ticket clears.>

## What I found
- <a fact the draft rests on> (<where it came from, or "assumed" / "derived from …">)

## Proposed draft
**<the one rule or idea, in a single bold sentence.>**

<How the pieces fit — at most one short paragraph per area, under 150 words
total. No evidence and no case-by-case argument: those are the why lines
below, and saying them twice is what makes a draft unreadable.>

## Decisions

<confidence dot> **<CONFIDENCE> · D1 · <what will happen, in the user's terms>**
   <Why, and what it costs, in one or two plain sentences on their own line. When a reasonable person would choose otherwise, say what their choice would do instead.>

   ↳ 🟡 **LEAN · D1.1 · <a decision hanging off D1, same format>**
     <Why.>

---

## Where I'm likely wrong
- **<D-id>:** <the fact I couldn't check, or the intent I may have misread>. <What changes if I'm wrong.>

## TL;DR
**Why:** <two to four sentences: what is blocked, which questions are open, and anything found along the way that changes the picture.>

**Proposal:**
1. **<short name for D1>:** <what will happen, and the one reason.>
2. **<short name for D2>:** <…>
```

The `---` rule separates the decisions from the two closing sections, so the reader sees where the draft ends and the summary begins.

A skill that calls grilling may add one block of its own between Proposed draft and Decisions, under the `##` heading it names; the block sits outside the Proposed draft's 150 words.

**Where I'm likely wrong** holds an assumption about the user's intent the environment couldn't confirm, or a coin-flip that is costly to reverse. Each bullet opens with the ids it touches. When there is nothing to flag, it says "Nothing I couldn't check." instead of being dropped.

**TL;DR** is what a reader who skipped everything above needs: why this is being decided, and the proposal as one numbered line per top-level decision. Keep it under about 120 words. It only restates the draft; a fact or decision that appears here first belongs in the body.

Confidence says where the user's attention belongs, so it opens each decision line, where a reader scanning the left edge sees it. 🟢 **FIRM**: the facts settle it. 🟡 **LEAN**: a good reason from the user would flip it. 🟠 **COIN-FLIP**: no real basis to choose; the user's call. 🔵 **YOURS**: the user settled it.

Nest two levels at most. A third level means D1 was really two decisions.

Every decision line and every question follows **Asking the user** in `~/.claude/CLAUDE.md`: a decision says what will happen and what it costs, never just a name for the design.

Write the draft, its decisions and its questions the way you would say them out loud: one idea per sentence, subject first. The reader is deciding, not admiring.

- **Say the claim plainly.** "Cursor does load shared hook scripts, but we have none worth sharing."
- **Write whole sentences.** "We never wrote them and never edited them. About 25 duplicate the library."
- **One aside per paragraph.** A second aside becomes its own sentence.
- **Name who acts.** "We untrack hooks.json instead of fighting Orca over it."
- **Put the subject first.** "It must solve the response envelope."

Close by asking the one question: **agree with the draft, or grill?** The user answers with `agree`, with the ids to grill (`grill D2 D4.1`, or `grill all`), or by overruling (`D3: tokens instead`).

**Done when** the recommended path runs to its leaves: every part of the request and every fact under What I found ends in a decision or a parent's line, every decision that earned an id has an answer and a confidence, the draft ends with Where I'm likely wrong and a TL;DR, and the question has been put.

## 2. Grill the challenged branches

A grilled decision **reopens**, along with everything hanging off it; the rest of the draft stands. An overruled decision takes the user's answer as settled and reopens only what hangs off it. A reopened decision the new answer makes mechanical folds into its parent's line; tell the user it is gone.

Re-check the facts under each reopened branch before asking. When a fact found mid-grill breaks a standing decision, say so and reopen it.

Work the reopened branches in **rounds**. The **frontier** is every reopened decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: keep each decision's id and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **D2 - <what is being decided, as a plain question>**
<the situation in this project where the choice shows up: who does what, and what happens next>

- **(a) <what happens>.** <what it gains and what it costs; say it is hard to undo only when it is>
- **(b) <what happens>.** <the same, for this option>

➡️ <the recommended option>: <its one reason>

---

❓ **D4 - <the next question of this round, in the same form>**
<the situation>

- **(a) <what happens>.** <what it gains and what it costs>
- **(b) <what happens>.** <the same, for this option>

➡️ <the recommended option>: <its one reason>
```

A question with no fixed options (a name, a number, a constraint only the user holds) keeps the situation line and asks for that one thing.

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them, and may add decisions the draft never had. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one. A running fact-finding sub-agent is an unsettled prerequisite: only the questions downstream of it wait.

When the frontier is empty, show the draft's **changes** (the decisions that moved, and the Proposed draft if it reads differently now), then the refreshed Where I'm likely wrong and TL;DR, and ask the one question again.

## Done

The session is done when the user agrees with the draft: every branch of the design tree answered, by them or by a proposal they accepted. Act on the draft only then; a term the user has settled themselves is written as it lands.
