---
spile: ticket
id: CC-0041
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0039, CC-0029]
  supersedes: []
implementation: []
---

# CC-0041: Game events and vibrations are emitted by the actions that cause them

## Summary

The actions that doc 30 part 8 and the game-event rules name post their game events (and vibrations): teleports, bow
and crossbow use, entity interactions, block place and destroy, shears, dismounts, shield deflection, and the flapping
of birds and bats.

## User Stories

### As a Player, I want sculk and other listeners to react to what I do

- Given an action with a game event in the doc (chorus fruit teleport, drawing a bow, shearing a sheep, dismounting a
  boat, a chicken flapping), when it happens, then the event is posted at the doc's position and a sculk sensor in
  range hears it.

## Functional Requirements

- FR-001: GAME-EVENT-SENSORS dispatches posted events to the vibration listeners (the sculk dispatch of lane p46h).
- FR-002: Every emitter of the doc has a test through the real action.

## State at the end of the polish run (2026-11-23)

- Built by lane p49z and wrap agent C (origin): GAME-EVENT-EQUIP, the hunger, potion, shield-raise, bobber and bone
  meal emitters, shoot, land and firework events, damaged and killed events, the movement events (step, swim, flap,
  hit_ground, splash, bounce) from ENTITY-MOVE.
- Open task lines in lanes/p49z.md: T56401 (chorus fruit and shulker teleports), T56402 (TNT minecart and sulfur cube
  prime_fuse), T56403 (resting bats still flap; nothing sets EN-CROUCHING for cat and ocelot), T56404
  (item_interact_start and finish for bow and crossbow, TOOL-TOTEM-USE has no caller), T56405 (entity_interact of the
  species that return no flag), T56406 (sniffer, creaking, turtle digging), T56407 (block_place and block_destroy
  emitters), T56408 (shear events, chest boat and minecart container_open, bottles, cauldrons, powder snow), T56409
  (entity_dismount on removal, shield deflection, projectile damage to boats and minecarts), T56410
  (GAME-EVENT-SENSORS wiring). T56101 (lanes/p49y.md): chicken and parrot flap needs flapSpeed.
