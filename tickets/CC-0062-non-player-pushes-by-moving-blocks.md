---
spile: ticket
id: CC-0062
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0029, CC-0057, CC-0065]
  supersedes: []
implementation: []
---

# CC-0062: Mobs, items and other entities are moved by pistons, shulker boxes and growing blocks as in Minecraft

## Summary

An entity that is not a Player is pushed by a moving piston, lifted by an opening shulker box and lifted by a block
that grows taller under it, exactly as in Minecraft.

## User Stories

### As a Player, I want contraptions to move mobs and items as in Minecraft

- Given a piston pushing an entity toward a low step, when it extends, then the entity steps up as far as it may.
- Given an entity pushed toward another piston's moving block, when it is pushed, then it does not pass into that block.
- Given an entity pushed off or onto the ground, when the push ends, then it counts as on the ground only when it is.
- Given a marker armour stand, when a piston meets it, then it stays where it is.
- Given a shulker box under a mob or an item, when it opens, then the mob or item is lifted.
- Given a dirt path, farmland or mud that turns into a taller block under a mob or an item, when it changes, then the
  mob or item is lifted onto it.

## Functional Requirements

- FR-001: The server's entity push follows docs/protocol 30 part 3 sections 8.1 to 8.4: collision with step-up,
  moving blocks of other pistons, the on-ground flag and the entities that ignore pistons.
- FR-002: Opening shulker boxes push non-player entities (31 part 1 section 13.5).
- FR-003: Every block change the documents give `pushEntitiesUp` lifts the non-player entities in the new volume
  (29b part 2 section 9.5).

## Notes

- Found while planning feature `specs/003-vanilla-movement`, which builds these rules for Players only. Its
  specification leaves how mobs move unchanged.
- The sticking of entities to a honey block and the stuck-speed multiplier on a piston push are CC-0029.

> [!NOTE]
> The header of core/src/piston-push.cob records the first four as open approximations: the world collision of a pushed
> entity is an overlap test with no step up, moving blocks of another piston are not looked at, the on-ground flag keeps
> its value, and a marker armour stand is not told apart. The server does not tick the opening of a shulker box. Of the
> growing blocks the server performs, trampled farmland lifts entities and an eye of ender filling an end portal frame
> does not.
