---
spile: ticket
id: CC-0038
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0029, CC-0030, CC-0031, CC-0032]
  supersedes: []
implementation: []
---

# CC-0038: Reference docs settle the block, container, item and worldgen conflicts and gaps

## Summary

A clean-room reader round (or a text fix after a reader check) settles the doc conflicts in which code followed one
document over another, and answers the gaps that blocked block, container, item and worldgen work. Clean-room round
(Principle II, skill clean-room): a reader agent studies the shipped artifact and writes prose, tables and data
schemas only, a separate reviewer checks for contamination and completeness.

## User Stories

### As a Contributor, I want the docs to agree with each other

- Given each conflict below, when the round is done, then both documents give the same rule and the code follows it,
  or the doc records why they differ.

## Functional Requirements

- FR-001: Each conflict names the document that is right, and the other is corrected.
- FR-002: Each gap is answered in prose, tables and data schemas only.

## Open Questions

- Conflict: 30-4 section 4.15 says a dispensed shulker box's facing is always DOWN; 24 part 6 section 6.12 gives a
  registry rule (facing is the dispenser's facing when the cell under the front cell is air, else up). The registry
  rule is followed in code (T29574).
- Conflict: 30-3 section 7.6 names the moving block's blockState keys Name and Properties; 07 section 7.3 says
  lowercase id and properties for this version. 07 is followed (T29571).
- Conflict: 24 part 8 section 4.3 (trapdoor row) has the placer and side branch conditions the opposite of 24-3
  section 7.7 and 30 part 7; code follows 24-3 (T33102). A text fix.
- 30-5 section 4.1 pressure plate prose, the has_eye versus eye property name (30-2 section 5.3 versus the registry)
  and a blank instrument column (T29580).
- 25-6 open question 5: the wire layout of Filterable<T> (lectern, written_book_content, CC-0030).
- 25-6 open question 2: LivingEntity.randomTeleport's safe-ground descent (chorus fruit teleport, T56401,
  lanes/p49z.md); the shulker teleport also lacks an attach face rule.
- 25 part 1 section 5.3: the direction of the walk for a non-sneaking side click on scaffolding (CC-0031).
- T33100 (lanes/wallitems.md): placement state of glazed terracotta, carved pumpkin facing, campfire, hopper, bed, end
  rod, bell, cocoa, command blocks, crafter and chiseled bookshelf (24-3 section 7.12 gives the states only).
- Glass bottle 4.16 and water potion 4.21 (30-4): potion contents as a slot patch; the respawn anchor charge sound.
- T19507, T19508, T19510 (lanes/p46c.md): the order of the four elements of bastion/starts and the rule order of each
  processor list (37-6 section 5), the netherrack spread table (section 6), 37-6 sections 9.1 and 9.6.
- From scratchpad/doc-gaps.md group B (2026-11-18), not re-verified: 36-6 section 5.2 wing connector indexes (5 and 9
  printed, 25 and 29 by the formula), 36-5 section 2.13 versus 2.8 draws outside the write box, 36-5 section 3.9
  EntryDoor, 35-4 section 7.5 RuleTest family, 35-6 section 2.4 Column.scan, 36-1 open question 1 (noise spawn
  finder), 38 section 2 (End chunk memory 256 rows in the doc, 128 in the core).
- 57-4 section 7: no node listing of publish and unpublish, and the semantics of swing with no target, time, random
  reset, test and dialog show.
- Corrected, not a gap: 37-nether-2 section 10 open question 2 was marked a doc gap but the section answers it (only
  nether_fossil contributes; 10.3 gives the beard term); the Nether beardifier hook is built (wrap agent I1, T1653 and
  T1654).

## State at the end of the polish run (2026-11-23)

- Evidence: scratchpad/doc-gaps.md groups B and D, and the DOC GAP and doc conflict notes on the task lines named
  above (lanes/p46h.md, wallitems.md, p46c.md, p49z.md).
