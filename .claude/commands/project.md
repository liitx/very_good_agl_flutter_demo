---
description: Triage the project — read the current items, break down lanes and blockers, audit labels, and walk the user through what to do next.
argument-hint: "[audit|blockers]"
---

You are the **project triage** command. Make the user aware of the current work, surface what's
blocking, enforce the ticket conventions, and walk them through next steps interactively.

Owner is `liitx`, repo `very_good_agl_flutter_demo`. Use `gh` (on PATH at `~/.local/bin`).

## 1. Detect the data source

Run `gh project list --owner liitx 2>&1`.
- If it lists projects: a board exists. Find the one titled like "very_good_agl_flutter_demo
  roadmap", note its number, and read items + their **Stage** field with
  `gh project item-list <number> --owner liitx --format json`.
- If it errors with a missing-scope message: the board is not available yet. Tell the user the
  board needs `gh auth refresh -s project`, then continue in **Issues mode** (below). Do not stop.

Always also read the issues (works with the current token):
`gh issue list --state open --limit 100 --json number,title,labels,url`.

## 2. Break down the current list

Summarize concisely:
- **By lane.** If a board exists, group by the Stage field (Backlog, Ready, Analysis, In
  progress, Blockers, Done) with counts. In Issues mode, group by the lane labels present
  (default everything labeled `backlog` is Backlog) and note lanes are approximate without the board.
- **Blockers first.** Explicitly list every item in **Blockers** (board) or labeled `blocked`
  (issues), each with one line on what it's waiting on (from the issue body/comments).
- Show In progress and Ready next, then a count for Backlog and Done.

## 3. Audit the conventions (enforce labels)

Every open issue must have:
- a **type** label: `idea` or `bug`, and
- a **variant** label: one of `variant:x86`, `variant:usb`, `variant:rpi4`, `variant:docs`, `variant:tooling`.

List any issue missing either. For each, offer to fix:
- Infer **type** from the title prefix (`[idea]` / `[bug]`); if ambiguous, ask.
- Infer **variant** from the issue body's "Which variant" answer (the form captures it); if
  ambiguous, ask. Apply with `gh issue edit <number> --add-label "<type>" --add-label "variant:<v>"`.
Only relabel after the user confirms. If invoked as `/project audit`, do just this section.

## 4. Walk the user through next steps

Use a multiple-choice question (AskUserQuestion) so the user goes through it as answer choices.
Offer actions grounded in the real list, e.g.:
- "Which blocker do you want to tackle?" → list the blocked items.
- "Pick an item to move to the next lane" → list In progress / Ready items.
- "Pick something from Backlog to pull into Ready."
- "Fix the N issues missing labels."

Then act on the choice:
- Move a card (board mode): `gh project item-edit` to set its Stage field. If invoked as
  `/project blockers`, focus the walkthrough on the Blockers lane.
- Relabel (issues mode): `gh issue edit`.
- Start work: open the relevant files / run the matching `/setup-agl-*` flow.

## Notes
- New items enter via the issue forms (`💡 idea` / `🐛 bug`) and start in **Backlog**. See CONTRIBUTING.md.
- If the board does not exist yet, after triage offer to create it (needs `project` scope):
  create the project, add a **Stage** single-select field (Backlog, Ready, Analysis, In progress,
  Blockers, Done), link it to the repo, set the "item added → Backlog" workflow, and seed cards
  from the open issues.
