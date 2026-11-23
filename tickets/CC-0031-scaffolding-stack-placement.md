---
spile: ticket
id: CC-0031
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0009, CC-0021, CC-0038]
  supersedes: []
implementation: []
---

# CC-0031: Placing scaffolding on scaffolding builds a column up to the limit

## Summary

Placing scaffolding against a scaffolding block walks up the column and places at the top, up to the documented limit
of 7, and the scaffolding placement context (entities that obstruct building) is modelled.

## User Stories

### As a Player, I want to extend a scaffolding tower by clicking its side

- Given a scaffolding column, when I place scaffolding against any of its blocks, then the block goes on top of the
  column, up to the limit of 7 (docs/protocol 25 part 1 section 5.3).
- Given an entity standing where the block would go, when the block does not obstruct building by the doc, then it is
  placed.

## Functional Requirements

- FR-001: BLOCK-PLACE walks the column as the doc says instead of placing on the clicked face.
- FR-002: UI-BLOCKS-BUILDING (blockupd-29-use.cob, a library with no caller) is called from the placement path with
  the scaffolding context.

## Open Questions

- 25 part 1 section 5.3 does not give the direction of the walk for a non-sneaking side click (doc gap, wrap agent B
  round 2; see CC-0038).

## State at the end of the polish run (2026-11-23)

- Not built. Lane bugstackplace's task T61410 (its lane file exists only on branch 002-lane-bugstackplace, tip
  c33c0f6a, which built the sea pickle, turtle egg, candle and snow stacking, see CC-0021). Task T40210
  (lanes/bugplacehead.md): entities other than players and mobs that block building are done in part
  (BLOCK-OVERLAPS-BODY, test acc_wrapb_place_entities); the scaffolding context is open.
