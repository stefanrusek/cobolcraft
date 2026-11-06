---
name: spile
description: CobolCraft's Spile ticket tracker in tickets/ (prefix CC). Use whenever creating, updating, transitioning, closing or listing tickets, recording deferred work (constitution Development Workflow, SDD 1.4), or picking the input for the next SDD run.
---

# Spile in CobolCraft

The authority is the Spile spec (v0.4.0) at https://sugarmaple.ai/spile.md. Fetch it when anything below is unclear;
when this skill and the spec disagree, the spec wins.

## Layout

- `tickets/README.md`: the root doc. Its front matter has `spile: project`, `project: CobolCraft`, `prefix: CC` and
  `counter:`, the last allocated ID number.
- `tickets/CC-NNNN-slug.md`: one ticket per file. The ID never changes; the slug may.
- `tickets/CC-NNNN-slug/`: an optional sidecar for supporting material. Nothing normative goes in it.
- `tickets/archive/`: closed tickets only, optional.
- `tickets/views/cobolcraft-view.md`: the generated view. Never edit it by hand.

## Minting a ticket

1. Read `counter` in `tickets/README.md`, add 1, and write it back. That number is the new ID, zero-padded to 4.
2. Create `tickets/CC-NNNN-<kebab-title>.md` with this front matter:
   - `spile: ticket`, `id`, `type` (feature or bug), `status`, `owner: stefanrusek`;
   - `resolution:` (empty), `blocked_by: []`, `created: <YYYY-MM-DD>`;
   - `relations` (depends_on / relates_to / supersedes) and `implementation` (branch, pr).
3. Write the body in the spec's skeleton: `# CC-NNNN: Title`, Summary (one paragraph), User Stories (H3 "As an
   <actor>, I want ...", each with Given/When/Then list items), Functional Requirements, then the optional tail
   sections.
4. Use only the personas in `.specify/memory/personas.md`: Player, Server operator, Pack creator, Contributor.
5. Write a bug as the corrected behaviour. The current broken behaviour goes in a `> [!NOTE]` under Notes.

Deferred work from an implement run starts in `draft` (constitution). Only the operator moves a ticket to `ready`.

## Every change

After any ticket mutation, run `python3 .claude/skills/spile/scripts/view.py tickets` and commit the view in the same
commit as the ticket change.

## Transitions

The lifecycle is draft → refining → ready → implementing → unverified → verifying → closed.

- When an SDD run picks a ticket up: set `implementing` and fill `implementation` (branch, pr).
- When the run's implement phases finish: set `unverified`.
- Closing takes `resolution` (done, wontfix, duplicate or superseded).
- A regression is a new bug ticket with `relates_to` the old one. Never reopen a closed ticket.
