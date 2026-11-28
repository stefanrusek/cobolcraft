# Data model: Movement That Matches Minecraft

Companion of [plan.md](plan.md). Values are cited, not restated, except where one table gathers them. "59 §n" is
`docs/protocol/59-player-movement-simulation.md`.

## 1. Motion state (shared record, contract [motion-engine.md](contracts/motion-engine.md))

The state of 59 §1. Client-side it is part of `CLIENT-STATE` under the `PL-` names; the core keeps one per player in a
new copybook beside `CORESTATE`.

| Client field today | Change |
|---|---|
| `PL-X`, `PL-Y`, `PL-Z` | unchanged |
| `PL-VX`, `PL-VY`, `PL-VZ` | the Player's one velocity in every medium |
| `PL-MOVE-X`, `PL-MOVE-Z` | collided displacement of the last move (glide start unchanged) |
| `PL-SLIP-*`, `PL-KB-*`, `PL-PUSH-*` | removed |
| `PL-ON-GROUND`, `PL-COLLIDED` | set by the rules of 59 §8.1; minor collision and vertical collision new |
| supporting block, fall distance, stuck multiplier, powder snow flags, movement records | new |
| `PL-JUMP` | the latch of a jump press between two ticks; jump delay new |

Client-only: flight-toggle ticks (replaces `PL-SPACE-MS`), sprint-trigger ticks and the previous tick's keys (replace
`PL-TAP-MS`, `PL-SPRINT-KEY`, `PL-FWD-PREV`), crouching flag, the attribute map (base and modifiers of the five
attributes).

Client-only for sending: the position, rotation and flags last sent and the reminder counter (05c).

Core-only per player: the server velocity and its "velocity changed" mark; the known movement and whether a movement
packet arrived since the last Client Tick End; the awaited teleport position and the tick it was sent (the id and its
confirmation exist); the fall distance (replaces `PL-FALL-START`); effective movement attributes and the last sent
ones; Soul Speed active or not; the last seen block position.

## 2. State transitions

| State | Enter | Leave | Source |
|---|---|---|---|
| Jumping from the ground | jump held, on ground or shallow fluid, delay 0 | delay 10; released key or flight sets it to 0 | 59 §6.1 |
| Sprinting | may start, with the key or the second forward press in the window | the stop rules, with a collision that is not minor | 59 §5 |
| Flying | second press in the window with may-fly; at once for a spectator | second press; landing (not a spectator); server abilities | 59 §7.8 |
| Swimming | 53 section 4 | 53 section 4 | unchanged |
| Crouching, crawling, pose | 59 §2.2 step 11; 53 section 3 | same | |
| Stuck | cobweb or bush listed in the pass, or powder snow at the feet; the last wins | consumed by the next move; never while flying | 59 §8.1, §10.2 |
| Effect on the client | Update Mob Effect | Remove Mob Effect (a duration of 0 still applies) | 59 §11.1 |
| Soul Speed (server) | on a soul block, not riding or flying, at an evaluation | a later evaluation off the block on ground, or riding or flying | 59 §11.4 |
| Velocity changed (server) | any damage accepted as a full hit that is not fully blocked and not drowning | sent, at once or at the next tracker pass | 59 §13.5 |
| Fall distance reset by an effect | each tick under Slow Falling or Levitation | the effect ends | 59 §11.2, §12.2 |
| Teleport unconfirmed (server) | a teleport or a lift is sent; a re-send takes a new id | the answer with the newest id | 59 §13.2; 05c |
| Known movement (server) | an accepted movement packet: its displacement | a Client Tick End with no accepted packet since the previous one: zero | 59 §13.2 |

## 3. Block movement properties (contract [block-movement.md](contracts/block-movement.md))

Defaults: friction 0.6, speed factor 1, jump factor 1, restitution 0, no climbing, no inside effect, default landing.
The list of blocks is closed by 59 §10.1.

| Blocks | Property | Source |
|---|---|---|
| `ice`, `packed_ice`, `frosted_ice` | friction 0.98 | 59 §4.2 |
| `blue_ice` | friction 0.989 | 59 §4.2 |
| `slime_block` | friction 0.8; restitution 1.0; step slow-down; no fall damage | 59 §8.2, §10.3, §12.4 |
| the 16 dyed beds, `shelf_mushroom` (not the straw bed) | restitution 0.75; half fall distance | 59 §10.1, §12.4 |
| `soul_sand` | speed factor 0.4 | 59 §8.3 |
| `honey_block` | speed 0.4; jump 0.5; side slide; suppresses bounce; fall multiplier 0.2 | 59 §8, §10.4, §12.4 |
| `hay_block` | fall multiplier 0.2 | 59 §12.4 |
| upward `pointed_dripstone` tip | fall distance + 2.5, multiplier 2, stalagmite damage | 59 §12.4 |
| `cobweb` | stuck (0.25, 0.05, 0.25); (0.5, 0.25, 0.5) with Weaving | 59 §10.2; 44 part x1 §2.4 |
| `sweet_berry_bush` | stuck (0.8, 0.75, 0.8) | 59 §10.2 |
| `powder_snow` | stuck (0.9, 1.5, 0.9) at the feet; shape by boots, height, fall and sneak; climb-up with boots; no fall damage | 59 §7.3, §10.2, §10.6, §12.4 |
| `bubble_column` up or down | vertical velocity per touched cell, inside and surface rules | 59 §10.2 |
| `ladder`, `vine`, `scaffolding`, weeping, twisting and cave vines | climbable (the feet cell) | 59 §7.3 |
| open trapdoor over a ladder of the same facing | climbable | 59 §7.3 |
| `scaffolding` | shape by height and sneak | 59 §10.6 |
| `moving_piston` | shape and pushes of its moving block record; slime launches, honey carries | 30 part 3 §7, §8; 59 §10.5 |
| shulker boxes | lid shape and push of its record | 31 part 1 §13; 51 §3.8.8; 59 §10.5 |
| trampled farmland; an end portal frame receiving an eye (the changes to a taller block the server performs) | every non-spectator player whose box overlaps the added shape is lifted; the client keeps its velocity, the server's becomes the known movement | 29b part 2 §9.5; 59 §13.6 |
| `potent_sulfur` erupting or continuous | launches upward through geyser-passable water | 31 part 8 §9.6; 59 §10.5 |
| suffocating blocks | push the Player sideways | 59 §4.4 |
| `water`, `lava`, waterlogged blocks | fluid travel and currents | 59 §7.4, §7.5; 29a §8 |
| `climbable` tag, `sweet_berry_bush`, `cobweb`, water | reset a fall crossed by a long move | 59 §12.3 |
| `mud`, soul sand, honey and other partial blocks | shape only (exists) | 51 |

## 4. Movement attributes (59 §11.2, §11.3)

| Attribute | Default | Modifiers in scope | Used by |
|---|---|---|---|
| `movement_speed` | 0.1 | sprinting, Speed, Slowness, Soul Speed | both |
| `sneaking_speed` | 0.3 | Swift Sneak | client |
| `water_movement_efficiency` | 0 | Depth Strider | both |
| `movement_efficiency` | 0 | Soul Speed | both |
| `safe_fall_distance` | 3 | Jump Boost | core |

Value: base plus additions, then multiplied-base, then multiplied-total, then clamped (59 §11.3).

## 5. Collision context

| Member | Client value | Server value |
|---|---|---|
| feet height | the motion state at the query | the position being checked or replayed |
| descending | live shift | the player's sneak state |
| fall distance | client fall distance | server fall distance |
| powder-snow walker | leather boots in the inventory replica | the player's feet slot |
| moving block records, piston no-clip direction | the client overlay | the core's block entities |

## 6. Moving blocks (contract [moving-blocks.md](contracts/moving-blocks.md))

| Where | Held | Created by | Ended by |
|---|---|---|---|
| core | the block entity state (as today), one lid or piston record each | the block event; a menu opening a shulker box | the piston tick's finish; the lid closing |
| client | an overlay of records over the replica, not drawn, and not bounded by the renderer's shulker list | the Block Event; a chunk's moving piston entry | a server block update for the cell; the finish after the lingering ticks (30 part 3 §7.2); the lid closing; chunk or dimension unload |

The motion state also holds the piston's per-tick movement accumulators (30 part 3 §8.3).

## 7. Server acceptance of a Move Player position

- The Player's box of the server's pose meets no collision shape of the context, moving blocks included, that the
  last accepted box did not meet (changed from "no collision shape at all"; 53 section 10.3 rule 7).
- A rise that claims the ground needs support or a climbable cell.
- Flight is accepted from a creative player.
- While a teleport is unconfirmed only the rotation is taken. The answer's position is then accepted by these rules,
  measured from the awaited position, with the ground and collision flags false; the fall distance grows on a fall and
  is cleared on a rise (59 §13.2, §13.6).
