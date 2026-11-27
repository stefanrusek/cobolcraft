---
spile: ticket
id: CC-0037
type: feature
status: implementing
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0034, CC-0035]
  supersedes: []
implementation:
  branch: 005-doc-rounds
---

# CC-0037: Reference docs state the client rendering and HUD rules that code had to skip

## Summary

A clean-room reader round extends docs/protocol 12, 34, 40, 53, 54 and 57 with the rendering, animation and HUD rules
that lanes recorded as doc gaps. Clean-room round (Principle II, skill clean-room): a reader agent studies the shipped
artifact and writes prose, tables and data schemas only, a separate reviewer checks for contamination and
completeness.

## User Stories

### As a Contributor, I want the rendering docs to state these rules so that implementation needs no guess

- Given each open question below, when the round is done, then the doc states the rule and the skipped drawing can be
  built from the docs alone.

## Functional Requirements

- FR-001: Each question is answered in the doc section it names, in prose, tables and data schemas only.
- FR-002: The unfinished round of the F3+B hitbox renderer (branch docs-hitbox) is finished or dropped on purpose.

## Open Questions

- T27510 (lanes/p46f.md): the third-person elytra attitude, wing model and layer and the flap animation (12 section 7,
  53 section 13.1); also the client's own start of gliding and fly_into_wall edge cases (T27511, judged low value).
- T59910 (lanes/bugscreenbg.md): which HUD parts draw behind a screen and in which order (12 section 5 only describes
  the gradient); T59911 the menu background blur.
- T60710 (lanes/bugsmooth.md): the vanilla living-entity lerp steps (44-8 item 18, 44-x2 item 14); walk and swing
  partial-tick lerp follow. The docs-lerp lane produced no commits.
- 34-3 section 9.4: the copper golem antenna block overlaps the knob by about 1 px, but the listed translate (0,
  -1.75, 0) leaves a 3 px gap (-1.5 would overlap 1 px).
- 34-5 sections 4.4 and 5.4 (fox and panda held items), 54 section 19.3 (compass and clock glint), copper golem idle
  animation start (see CC-0034).
- 34-1 section 7.5 open question 13 and T60003 (lanes/featshitbox.md): the F3+B hitbox renderer's view line, line
  widths, depth behaviour, point size, vehicle box, ender dragon sub-boxes, skip rules, eye height table and message.
  The unfinished edits of docs 13, 21 and 34-1 are uncommitted in /Users/stefanrusek/Code/cobolcraft-docs-hitbox.
- 12 section 8.1: which side faces of the isometric GUI cube are left and right (NORTH or WEST), and the held and
  dropped slab and stair item models.
- 57-5 (lane p70g): the position of the pending-line marker, which mask bit marks a masked character, the
  TeamParameters colour wire type (05b says Optional IdEnum), styled number format fields.
- 34-9 section 19 validation 6 says value 2 gives icon 1 but the section 14 tier table gives icon 0 (lane p70i).
- The project font versus the doc's glyph advances (l = 5 versus 3, T53030) and 40-8 section 6.1 hanging sign editor
  width 60 versus the code's 90.

## State at the end of the polish run (2026-11-23)

- Evidence: scratchpad/doc-gaps.md groups C and D, the task lines named above, and scratchpad/handoffs/wrapA-r3.md and
  wrapA-r6.md.
