---
spile: ticket
id: CC-0007
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-06
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0007: Lighting, sky, fog and clouds

## Summary

Split out of CC-0001 (operator, 2026-11-06). The first manual run of the client looked flat: block faces were not
shaded well, and the sky, fog and clouds were simple. This ticket covers how the world is lit and how its sky looks.
The values come from `docs/protocol/12-client-rendering.md` §1 (block lighting) and §3 (sky, fog, clouds), and the
stand-in values in `docs/design/standin-content.md` §4.8 change where they differ (Principle II).

## User Stories

### As a Player, I want block faces shaded so the shapes read clearly

- Given a new world, when I look across the terrain, then each block face is shaded by its direction, with smooth
  lighting and ambient occlusion at the corners, as described in the rendering reference.
- Given block light and sky light, when a place is lit, then the two combine through the light map, with the
  brightness option applied.

### As a Player, I want a sky, fog and clouds that look finished

- Given the day cycle, when time passes, then the sky colour, the sun, the moon, the stars and the sunrise and sunset
  glow change through the day.
- Given any view distance, when I look into the distance, then fog fades the terrain out, and the fog changes under
  water, in lava and in other conditions.
- Given the clouds, when I look up, then they drift and are lit and shaded as described in the rendering reference.

## Open Questions

- The reference day timeline has 24000 ticks, while `docs/design/standin-content.md` §4.8 uses 30000 and a different
  night. Which one does the game use?
- `docs/design/standin-content.md` §4.9 says the `timeline` registry sends no packet. If the game keeps a 30000-tick
  day, it must send its own scaled timeline. Does it?

## State at the end of the polish run (2026-11-23)

- Lighting, sky, fog and clouds stayed out of scope of the second SDD run (operator decision, FR-043): no T0697 engine
  switch and no light-reader work. Nothing in this ticket's stories was built by that run.
- The 32 section engine exists as `core/src/light-32.cob` (its own 4 x 4 chunk window, programs L32-*); the stand-in
  `core/src/light.cob` still serves every caller. T0697 (`specs/002-client-polish/tasks/core/phase-42c.md`) is ticked
  with the note NOT DONE: the callers use the chunk cache of CELLS.cpy, so the engine cannot serve them without an
  adapter, and T19506 (lanes/p46c.md) says the block is the engine itself.
- Lane p46d, branch `002-lane-p46d` (tip 1a9f576d, eight commits not on origin by patch-id): fd9fde0d the light engine 32
  with a persistent 6 x 6 window over the chunk cache, unwired; 27049faa locate and bit tables without MOD or division,
  measured; 1a9f576d the finding that the engine stays unwired. Lane crashlight (f37ae4e7) holds an older incremental
  block light (LIGHT-ADD, LIGHT-REMOVE).
- Cut with the scope (task lines in lanes/): bugblack T33604 (sky light spreading), bugsky T30504 and T30505, bugcelestial
  T32201, bugsunchest T62202, bugtorchblack T42004, bugstairlight T62504 (face-shape occlusion, sky spreading, soul sand
  dampening, the emission floor; the block light of partial blocks is on origin).
