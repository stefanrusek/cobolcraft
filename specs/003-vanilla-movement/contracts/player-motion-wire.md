# Contract: player motion packets (core and client)

Fixed before any task that consumes it. Packet layouts are those of `docs/protocol/` 05a, 05b and 05c and the profile
09. Fixtures live in `contract/fixtures/wire/`; codecs are the existing `proto` entries. The 09 rows for Update
Attributes to a player and for the times Set Entity Motion is sent are written before the code that sends them.

## 1. Server to client (about the receiving player)

| Packet | Core sends | Client does |
|---|---|---|
| Player Position 0x49, a teleport | position, velocity (0, 0, 0), flags 0 (unchanged); a new id each time, a re-send included | position, velocity and rotation by the flags (59 §13.2), previous-tick values moved likewise, ground flag and fall distance kept, a passenger ignoring the change; answers Accept Teleportation with the result; stops a block break; keeps the values last sent |
| Set Entity Motion 0x67 | the server velocity, at the moments of 59 §13.5: after every accepted full hit that is not fully blocked and not drowning | replaces all three components (59 §13.1); while gliding unchanged |
| Explode 0x24 knockback | the knockback of 59 §13.5, also added to the server velocity | adds all three components; nothing else changes |
| Update Mob Effect 0x87, Remove Mob Effect 0x4F | as 59 §11.5 | keeps each effect until Remove; reads Jump Boost, Levitation, Slow Falling, Dolphin's Grace, Blindness, Weaving |
| Update Attributes 0x86 | when a movement attribute changed, at the next tracker pass (59 §11.5): base value and all modifiers | for each listed attribute replaces base and modifiers; adds and removes `minecraft:sprinting` itself (59 §11.1, §11.5) |
| Block Event 0x07 of a piston or shulker box | unchanged; sent before the block updates its move causes | runs the move on its own world (30 part 3 §10.1) or drives the lid (31 part 1 §13.3) ([moving-blocks.md](moving-blocks.md)) |
| Block Update 0x08, Section Blocks Update 0x56 | unchanged | a cell it names ends that cell's moving block (30 part 3 §7.4) |
| Chunk data with a moving piston | the block entity entry, if it is not sent today (gap S18) | starts the moving block from the entry (30 part 3 §7.6) |
| Player Position, the lift by a growing block | change (0, lift, 0), velocity (0, 0, 0), yaw 0, pitch 0, flags 0x000001FF, sent also when the lift is 0, before the block update of the same level tick (59 §13.6) | as the teleport above: raised from its own position, velocity unchanged |
| Respawn 0x54 | keep bits (unchanged: 3 on travel) | bit 0x02 keeps the velocity, bit 0x01 the attribute modifiers; otherwise zero and base values (59 §13.2) |
| Player Abilities 0x41 | unchanged | flight permission and state (13 §1.4); the speed fields stay unused (09) |
| Player Info Update changing the receiver's game mode to spectator | unchanged (whether the core sends it for this change is checked with the slice) | vertical velocity 0 (59 §2.4) |

Attributes and registry ids (59 §11.5; 46): movement efficiency 25, movement speed 26, safe fall distance 29, sneaking
speed 31, water movement efficiency 37. Whether the cobolcraft set's registry sends the same ids is checked first (gap
S10).

## 2. Client to server

| Packet | Client sends | Server |
|---|---|---|
| Player Input 0x2B | the shift bit on change, before the position of the same tick (53 §10.1) | sneak state, used as "descending" |
| Player Command 0x2A | start and stop sprinting on change, before the position | sprint flag and its movement speed modifier |
| Player Abilities 0x28 | flying bit on change | flight from creative players (unchanged) |
| Move Player 0x1E to 0x21 | once a tick when loaded and not a passenger, by 05c against the values last sent: position when the squared distance exceeds 4.0E-8 or on the twentieth call without one; rotation on a difference; Status Only on a changed flag; flags 0x01 on ground and 0x02 horizontal collision | acceptance by [data-model.md](../data-model.md) section 7; replay on the server velocity; becomes the known movement |
| Client Tick End 0x0D | after each tick's packets (unchanged) | zeroes the known movement when no accepted movement packet came since the last one |
| Accept Teleportation 0x00 | once for each Player Position, with the id and the resolved position and rotation | counts only with the newest id while one is awaited, otherwise ignored; the player is put at the awaited position and the answer is handled as a movement with flags false |
| Use Item On, Move Vehicle | unchanged | not acted on while a teleport is unconfirmed (05c) |

While unconfirmed, a Move Player changes the rotation only, and one arriving more than 20 server ticks after the last
send causes an absolute re-send with zero velocity and a new id.

## 3. Invariant (US1-13, SC-004)

For any movement the client's rules produce on a CobolCraft world, the server answers no Player Position and closes no
connection. A Player Position sent for a teleport, a respawn, a portal or the lift of a growing block, or re-sent
because one of these is unconfirmed, is not a movement correction.

## 4. Contract tests

| Program | Package | Asserts |
|---|---|---|
| `contract_motion_wire_client` | client | each server-to-client fixture of section 1 produces the stated client state, including new fixtures for the lift's Player Position (flags 0x1FF), an Update Attributes of the player, a Respawn with and without the keep bits and the Block Event of a piston; each client-to-server packet of section 2 equals its fixture |
| `contract_motion_wire_core` | core | the core's builders equal the fixtures; the server-side decode of the section 2 fixtures gives the stated state |

New fixtures are written by hand from the documents. Existing cases in `contract/cases/wire-core.tsv`,
`client/tests/contract_wire_client.cob` and `core/tests/WIREPLAY.cpy` that cover a row are kept and not duplicated.
