---
spile: ticket
id: CC-0001
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-06
relations:
  depends_on: []
  relates_to: [CC-0002]
  supersedes: []
implementation: []
---

# CC-0001: Visual polish of the client

## Summary

The first manual run of the finished client (feature 001, 2026-11-06) worked but looked disappointing. This ticket is
the input for the second SDD run's visual work: the world, the HUD and the screens should look deliberate and
finished, not like a debug renderer. The stand-in content (`docs/design/standin-content.md`) stays the source of the
values, so new looks are added there first (Principle II).

## User Stories

### As a Player, I want the world to look finished

- Given a new world, when I look across the terrain, then block faces are shaded so that the shapes read clearly.
  The exact lighting model is an open question.
- Given the stand-in textures, when they are drawn at any distance, then they look as their authors intended, with no
  seams, shimmering or bleeding between atlas cells.

### As a Player, I want the HUD and screens to look deliberate

- Given the HUD, inventory and menus, when they are shown, then text, slots and buttons are aligned, consistently
  spaced and readable at the window's size.
- Given a stack of 1 item, when its slot is drawn, then no count is shown. Counts appear only from 2 up.

## Functional Requirements

- Given any visual change, when it lands, then its values come from `docs/design/standin-content.md` or
  `docs/protocol/`, never from constants invented in code.

## Open Questions

- What exactly disappointed the operator in the first run? Capture screenshots and the specific complaints in a
  sidecar before refining.
- Which looks are in scope: lighting (smooth lighting, ambient occlusion), sky and fog, clouds, HUD layout, font,
  screen backgrounds?

## Notes

> [!NOTE]
> Today a count is drawn on stacks of 1, unlike Minecraft.
