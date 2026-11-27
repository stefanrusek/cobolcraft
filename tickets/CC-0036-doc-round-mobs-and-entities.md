---
spile: ticket
id: CC-0036
type: feature
status: implementing
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0040]
  supersedes: []
implementation:
  branch: 005-doc-rounds
---

# CC-0036: Reference docs state the mob and entity behaviour that code had to skip

## Summary

A clean-room reader round extends docs/protocol 18 to 21, 40 and 44 with the mob and entity rules that implementation
lanes recorded as doc gaps and had to skip or approximate. Clean-room round (Principle II, skill clean-room): a reader
agent studies the shipped artifact and writes prose, tables and data schemas only, a separate reviewer checks for
contamination and completeness.

## User Stories

### As a Contributor, I want the mob docs to state these rules so that implementation needs no guess

- Given each open question below, when the round is done, then the doc section states the rule with its numbers, and
  the skipped code can be built from the docs alone.

## Functional Requirements

- FR-001: Each question is answered in the doc section it names, in prose, tables and data schemas only.
- FR-002: A reviewer pass checks contamination and completeness before any implementation lane starts.

## Open Questions

- 18 section 4.6 (nautilus love): the doc words the delay as after breeding; the code reads it as the delay before
  spawnChildFromBreeding (the behaviour lasts 110 ticks, the delay is at most 109). Which reading is right? (T24090,
  wrapI2-r6.)
- 40-6 (horse interaction step 3): the rearing duration and the angry sound of makeMad when a non-food item is used on
  an untamed adult horse (T2341, phase-49c.md).
- T35590 (lanes/p49n.md): 20 section 10 move control (hop), 18 section 2 bucket handling, Pillager.wantsItem, metadata
  18, stepOn, the eye height column, sulfur cube health.
- T52092 (lanes/p49v.md): 19 section 21 copper golem transport: source versus destination predicate and the throw
  velocity; the idle animation start rule (44-3 section 8 or 19 section 21).
- T52096 (lanes/p49v.md): the pool lines that say which stand-in mob values differ from the standard ones, needed by
  acc_f2us15_mob_rules (T2915, FR-041).
- T56406 (lanes/p49z.md): the turtle digging cadence (Turtle.aiStep); T56401: see CC-0038 for the chorus fruit
  teleport.
- T24090 (lanes/p49j-a.md): getBreedOffspring of the frog, mule, zombie horse and skeleton horse; the moved-wrongly
  log texts and the containsInvalidValues limits (05c open question 1); wolf armor shearing; dispenser dispatch for
  other mobs; the level entity order of the first-entity rule.
- The other items of scratchpad/doc-gaps.md group A (2026-11-18), not re-verified against the later doc rounds: the
  entity ticking range (18 section 2.1), 18 section 10.2 scripted randoms, 19 section 25.4 versus 45-6 section 9
  (wandering trader roll), 20 section 17 creaking, 20 section 16 breeze, 20 section 15 warden, 21 section 4.1 fish
  schooling, 44-2 section 8, 44-3 section 4 and 2, 44-6, 17 section 3.9 draw table versus its formula, 17 section 3.10
  trident deflection sign.

## State at the end of the polish run (2026-11-23)

- No reader round is running. Branch docs-mobs (64a3afb7) holds an earlier group A round; its content was brought to
  origin through other commits (check before launching a reader).
- Evidence: scratchpad/doc-gaps.md (2026-11-18, additions 2026-11-19), the DOC GAP and doc-gap-noted task lines of
  specs/002-client-polish/tasks/lanes/ (p49j-a, p49n, p49v, p49z) and the handoff files in scratchpad/handoffs/
  (wrapI2-r6, wrapC-r*).
