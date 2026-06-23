# Contributing — how to add and track items

Work is tracked on the [project board](https://github.com/liitx/very_good_agl_flutter_demo/projects).
This is the conventional flow for adding an item and moving it along.

## Add an item (the conventional way)

1. Open a new issue and pick a template:
   - **💡 Idea or feature request** — for anything you want built or changed.
   - **🐛 Bug report** — for something that doesn't work as documented.
2. Fill in the form. Use the title prefix the template sets (`[idea]` / `[bug]`) — keep it.
3. Submit. The template applies the `backlog` label, so the item **starts in the Backlog lane**
   of the board automatically.

That's it. You do not need board access to add an item — opening the issue is enough.

## The lanes (what each means)

| Lane | Meaning |
|---|---|
| **Backlog** | Captured, not yet committed to. Every new idea/bug starts here. |
| **Ready** | Scoped and agreed; ready to be picked up. |
| **Analysis** | Being investigated or designed before work starts. |
| **In progress** | Actively being worked on. |
| **Blockers** | Started but stuck — note what it's waiting on. |
| **Done** | Shipped and verified. |

Items move left to right. A maintainer (or you, if you have board access) drags the card to the
next lane as its state changes.

## Conventions

- **One item per issue.** Keep scope tight so it can move through the lanes cleanly.
- **Title prefixes:** `[idea]`, `[bug]`. Templates set these.
- **Labels (required):** every item carries a **type** label (`idea` or `bug`) and a **variant**
  label (`variant:x86`, `variant:usb`, `variant:rpi4`, `variant:docs`, or `variant:tooling`), plus
  `backlog` on entry. The issue forms set the type and capture the variant; running `/project audit`
  in Claude Code finds any item missing a type or variant label and applies it.
- **Reference logs** for bugs: paste from `scripts/logs.sh` (Variant A) or the device logs
  (Variant B). See the README "Logging" section.
- **Commits/PRs** that resolve an item should reference it (`Closes #NN`) so the board card
  moves to Done automatically.

## Code changes

See [CLAUDE.md](CLAUDE.md) for repo conventions (keep upstream parity, mark VERIFIED vs
UNVERIFIED in docs, build + run + read logs before claiming something works) and
[CONFIGURATION.md](CONFIGURATION.md) for the config contract.
