# Prose rules

The reader is a smart newcomer: a developer with no background in the domain. Write so they can follow without asking anyone.

## Sentences: ASD-STE100

- One idea per sentence. Most sentences under 20 words; procedural steps under 20, descriptive under 25.
- Active voice, present tense: "The issuer pays the coupon", "The script rounds the result".
- One word, one meaning in the whole page. Pick the plain word ("face value", "repayment") and keep it; mention the jargon synonym once, where the term is defined.
- Name the actor: "the market rate", "the buyer pays the seller", never a bare "the rate" or "it is paid".
- Short paragraphs: 1–4 sentences. Use a list or table when there are three or more parallel items.
- Say what to do or what is true. Use "Thus" / "Because" to show cause.

## Teaching

These apply to every page:

- **Primer first.** Before the details, explain the background the reader needs: the problem, the people or systems involved. Then go from the big idea to the details.
- **Every abstract rule gets a concrete example** directly after it: real values, a real screen, a real request.
- **Explain why before how.** Say why a rule, formula, or design has its shape before you show it.
- **Split overloaded words.** If one word means two things, make two terms and use each one consistently.

Use these when the topic has the matching shape:

- **Numbers:** each number says where it comes from, its unit, and its scale. Convert units in view (11.5% → 0.115). For a formula, give a table: symbol, value in the example, meaning.
- **A normal value:** when a value has a usual anchor (par = 100, a default limit), show cases below, at, and above it.
- **Things with a lifecycle** (an order, a post, a request, a contract): follow one instance from start to end. Show each state, each actor, and what moves between them.
- **Inputs the reader does not control** (a rate, an API, an upstream service): say who owns or sets it and when it changes.

## Single source of truth

- Each term has one definition, in one place: the glossary when the page has one, otherwise the sentence where the term first appears. Later uses refer back to it (with `a.g` links when there is a glossary) instead of defining it again.
- Deep dives hold the extra detail. The main text stays complete and short without them.

## What the page leaves out

- Write for the reader of the topic, not the reader of the repo. When the page is based on code, leave out file names, function names, script inputs, and "run this" instructions unless the user asks for them. The code decides the facts; the page explains them in domain words.
- Facts come from the source code or official sources, never from memory. If neither supports a claim, remove it.
