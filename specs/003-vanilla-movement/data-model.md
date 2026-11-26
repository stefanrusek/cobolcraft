# Data model: Movement That Matches Minecraft

Companion of [plan.md](plan.md). Values are cited, not restated, except where one table gathers them. Rows marked
DG-n wait for the clean-room round ([research.md](research.md) section 3).

## 1. Client movement state (client-internal, `client/copy/CLSTATE.cpy`)

Velocities are blocks per tick, `FLOAT-LONG`.

| Field | Meaning | Change |
|---|---|---|
| `PL-X`, `PL-Y`, `PL-Z` | feet position | unchanged |
| `PL-VX`, `PL-VY`, `PL-VZ` | the Player's one velocity, in every medium | `PL-VX`, `PL-VZ` stop being fluid-only |
| `PL-MOVE-X`, `PL-MOVE-Z` | collided horizontal displacement of the last tick (glide start, R12) | kept |
| `PL-SLIP-X`, `PL-SLIP-Z`, `PL-KB-X`, `PL-KB-Z` | ice and knockback velocities | removed |
| `PL-PUSH-X`, `PL-PUSH-Z` | the current's push | removed: the push is added to the velocity (29a section 8.3) |
| `PL-ON-GROUND` | the vertical move was blocked while moving down (30 part 8 section 14.1.1) | rule changes |
| `PL-COLLIDED`, minor flag | horizontal collision, and whether it is minor (DG-6) | minor flag new |
| supporting cell, no-block flag | main supporting block (30 part 8 section 14.1.3) | new |
| jump delay | ticks until the next jump from the ground (13 section 1.3) | new |
| flight-toggle ticks | window of the double press (13 section 1.4) | replaces `PL-SPACE-MS` |
| sprint-trigger ticks, previous forward, previous shift | sprint start (13 section 1.5) | replace `PL-TAP-MS`, `PL-SPRINT-KEY` as 13 section 1.5 requires |
| `PL-JUMP` | the latch of a jump press between two ticks | kept |
| stuck multiplier (x, y, z) | set by a block, applied by the next move once (44 part x1 section 2.2) | new |
| fall distance | DG-4 | new |
| in powder snow, was in powder snow | climbing and the shape rule (DG-3) | new |

Session reset, dimension entry and respawn clear every field of this table except the position.

## 2. State transitions

| State | Enter | Leave | Source |
|---|---|---|---|
| Jumping from the ground | jump held, on ground or shallow fluid, delay 0 | delay set to 10; released key sets it to 0 | 13 section 1.3 |
| Sprinting | forward impulse, sprint possible, key held or second forward press inside the window | the stop rules, including a non-minor horizontal collision | 13 section 1.5, DG-6 |
| Flying | second jump press inside the window with `mayfly`; at once for a spectator | second press; landing (not a spectator); server abilities | 13 section 1.4 |
| Swimming | sprinting with eyes under water | not sprinting, not in water, flying | 29a section 8.4 |
| Crouching, crawling | 53 section 3 | 53 section 3 | unchanged |
| Stuck | inside cobweb, berry bush or powder snow | consumed by the next move; ignored while flying | 44 part x1 section 2; 13 section 1.4 |

## 3. Block movement properties (content; contract [block-movement.md](contracts/block-movement.md))

Defaults: friction 0.6, speed factor 1, jump factor 1, bounce 0, no climbing, no inside effect.

| Blocks | Property | Source |
|---|---|---|
| `ice`, `packed_ice`, `frosted_ice` | friction 0.98 | 44 part 1 section 4.4 |
| `blue_ice` | friction 0.989 | same |
| `slime_block` | friction 0.8; bounce 1.0; slows the horizontal velocity of a walker who is not sneaking and has abs(vy) below 0.1 by 0.4 + abs(vy) x 0.2 | same; 44 part 5 section 4.3; 24 part 5 |
| `soul_sand` | speed factor 0.4 | 44 part 1 section 4.4 |
| `honey_block` | speed factor 0.4, jump factor 0.5, wall slide, suppresses bounce | same; 29b part 7 section 6; 44 part 5 section 4.3 |
| every bed, `shelf_mushroom` | bounce 0.75 | 44 part 5 section 4.3 |
| `cobweb` | stuck (0.25, 0.05, 0.25); (0.5, 0.25, 0.5) with the Weaving effect | 44 part x1 section 2.4 |
| `sweet_berry_bush` | stuck (0.8, 0.75, 0.8) | 29b part 2 |
| `powder_snow` | stuck (0.9, 1.5, 0.9); shape depends on the Player; climbable for a Player who can walk on it (DG-3) | 44 part x1 section 2.2 |
| `bubble_column` (`drag` true or false) | vertical velocity, inside and above rules | 29a section 6 |
| `ladder`, `vine`, `scaffolding`, weeping, twisting and cave vines | climbable | 24 part 1 section 12.2 |
| trapdoors | climbable under a condition | DG-3 |
| `scaffolding` | shape depends on the Player and on `bottom`, `distance` | 24 part 7 section 11.4; 51 R-C20 |
| `potent_sulfur` in state erupting or continuous, with geyser-passable blocks above its water | launches entities | 31 part 8 section 9.6 |
| soul sand, mud, honey and other partial blocks | collision shapes (exist today) | 51 |
| any block the round adds | as written | DG-9 |

Water and lava keep their existing state tables (`ST-FLUID`, `ST-LEVEL`).

## 4. Collision context (content record, passed by client and server)

| Member | Meaning | Client value | Server value |
|---|---|---|---|
| feet height | the y the shape rules compare with the cell | the Player's box before the move | the position being checked |
| descending | shift held | live key | `PL-SNEAKING` |
| fall distance | for powder snow | client fall distance (DG-4) | fall start minus feet height |
| powder-snow walker | leather boots worn (44 part x1 section 2.2) | inventory replica | the Player's feet slot |

The feet-height and server fall-distance values are confirmed against the round's answer to DG-4 before use.

## 5. Validation rules

- A Move Player position is accepted when the Player's box of the server's pose overlaps no collision shape of the
  context (existing rule, new shapes).
- A rise that claims the ground still needs support or a climbable cell (existing rule, climbable set from content).
- Flight is accepted from a creative Player (existing).
