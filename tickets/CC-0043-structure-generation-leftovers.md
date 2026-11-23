---
spile: ticket
id: CC-0043
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0027]
  supersedes: []
implementation: []
---

# CC-0043: Structure generation leftovers: mineshaft loot, test bookkeeping and the cut families

## Summary

The small leftovers of structure generation in lanes p45, p46 and featsb: the mineshaft chest minecart with its loot
table, section-named tests of the proven structures, and families that were cut as having no consumer.

## User Stories

### As a Player, I want structures to hold the loot vanilla gives

- Given a mineshaft with a chest minecart, when I open it, then it holds its loot table's contents.

## Functional Requirements

- FR-001: The chest minecart of a mineshaft gets its LootTable hook (minecart-44.cob has the chest cart).

## Open Questions

- T19009 (lanes/p46b.md, T0327): which module owns the MOBS.cpy constants (flee speed, notice range, reach, cooldown,
  yield, caps, three spawn rules) once the copybook is gone. A design decision for the operator, not a doc gap; no doc
  names the owner.

## State at the end of the polish run (2026-11-23)

- Open task lines: T51526 (lanes/p45j.md, mineshaft chest minecart loot; the mineshaft piece is in the tree), T51541
  to T51548 (section-named tests and bookkeeping of the proven structure families), T19508 and T19510 (lanes/p46c.md,
  test coverage of the netherrack spread table and 37-6 9.1, 9.6), T9807 (lanes/featsb6.md, replace_single_block: no
  data uses it), T10003 (lanes/models5.md, the remaining structure families of featsb7), T6302 (lanes/nethperf.md, the
  portal generates 3 x 3 chunks inline, 1.9 s once; needs a window to profile).
- Built in this run by wrap agent I1: the piece NBT keys of every structure family (T1402, core/src/struct-start.cob,
  STRUCTPKEYS.cpy), /place jigsaw (T1378, T1379), the Nether fossil start and the Nether beardifier hook (T1653,
  T1654, T51501). The jigsaw memo redesign is CC-0027. Light of structures is CC-0007.
