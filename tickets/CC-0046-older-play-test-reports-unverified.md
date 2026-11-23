---
spile: ticket
id: CC-0046
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0009]
  supersedes: []
implementation: []
---

# CC-0046: Play-test reports of try8 to try11 are checked against a current build

## Summary

The operator's play-test reports from builds try8 to try11 (from 2026-11-16) were queued as next-run work. Many were
handled by lanes since; each is checked on a current build and either closed or turned into its own bug ticket.

## User Stories

### As a Player, I want the problems I reported to be fixed or answered

- Given each report below, when it is tried on a current build, then it is confirmed fixed (with the lane or commit),
  or it becomes a bug ticket with the corrected behaviour.

## Functional Requirements

- FR-001: Nothing here is assumed fixed or broken: each item is verified in the game, or by a test through the real
  path, before anything is written.

## Open Questions

- try8: a torch under a falling gravel block is deleted and the user expected the gravel to break it; gravel above a
  placed torch did not place (CC-0009 and the falling-block landing rules).
- try8: no sulfur cubes spawned in a sulfur cave under spawn on seed 4 (T2504 unchecked).
- try9: leaf_litter had no texture (later reported correct); spiders and zombies spawn in daylight in a well-lit
  forest; /locate structure village and stronghold found nothing.
- try10: villager arm and leg skins upside down; spawn-egg villagers never take a profession; trading dialog does not
  open; /execute run tp into the nether does nothing; hostile mobs appear at once in a new world; STDMOB-AGGRO reads
  raw stored light (T6803); pink_petals, glow_lichen and other decals z-fight with the block they sit on; leaf_litter
  and pink_petals should stack in one block.
- try10 performance profile (release build): about 110 s on Loading terrain, ENTITY-MODEL-EMIT 53 percent of the main
  thread in play, WORLD-FIND 15, M182-ENV-TICK 7; a profiling pass with symbols comes first. Unreproduced: /locate or
  an eye of ender before the main process has generated a chunk may use an un-initialised generator state.
- try11: villagers render without profession clothing; a dirt_path in front of a door stops the player (door collision
  against the 1/16 drop); the later lanes bugvillage, buglocate, doorpath, villlook, bugvlag and bugleaves handled
  parts of these.
- Idea (operator, 2026-11-17): extend the hidden debug world (docs/design/debug-world.md says no mobs and nothing
  ticks) with a frozen mob area of every type and variant, a redstone gallery, and the vanilla test blocks as a place
  for automated checks, as new hidden world types or regions of the debug world.

## State at the end of the polish run (2026-11-23)

- Source: scratchpad/next-run-bugs.md of the orchestrating session (git-ignored, not in the repository); the items
  above are copied from it without re-testing.
