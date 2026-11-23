---
spile: ticket
id: CC-0018
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0018: A void world stays void around its saved island

## Summary

A world whose level data declares a flat-void, mod or noise generator keeps its empty chunks empty and is not
rewritten with generated terrain; the core uses the generator the world declares for chunks missing from the region
files.

## User Stories

### As a Player, I want my skyblock world to stay a skyblock

- Given a world with one saved island and a void generator declared in world_gen_settings.dat, when I join and play
  for a while, then no chunk other than the saved island holds non-air blocks and the world files hold no generated
  terrain.

## Functional Requirements

- FR-001: The world type is decided from level data and world_gen_settings.dat (docs/protocol 25 and 35 flat settings,
  38 dimension types): an unknown or custom generator gives void chunks, never the standard generator.

## Notes

> [!NOTE]
> Operator report (try19, 2026-11-19): my skyblock world bugged out and started generating chunks.

## State at the end of the polish run (2026-11-23)

- Built on branch 002-lane-bugskyblock (tip b92ca819, two commits, not on origin): d42677d0 a test that skyblock
  worlds (a declared flat, mod or noise generator) stay void around the saved island, red first; b92ca819 a 26.3 world
  gets the overworld generator its world_gen_settings.dat declares (flat void stays void, a generator of a mod gives
  void chunks). Brief: scratchpad/pending-lanes.md, section bugskyblock (ids T63200-T63299). The operator's own world
  is read-only reference material (folder name containing bandclam under /tmp/cc-test/saves); it is never modified.
- Left: merge and gates; whether the operator's world now stays void was not re-checked.
