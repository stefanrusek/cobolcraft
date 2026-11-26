# Contract: player motion packets (core and client)

Fixed before any task that consumes it. Packet layouts are those of `docs/protocol/` 05a, 05b and 05c and the
profile 09; no packet is added unless open question Q-3 of [plan.md](../plan.md) is answered B. Fixtures live in
`contract/fixtures/wire/`; codecs are the existing `proto` entries.

## 1. Server to client

| Packet | Core sends | Client does |
|---|---|---|
| Player Position 0x49 | absolute position, velocity (0, 0, 0), flags 0 (unchanged) | resolves position, velocity, yaw and pitch by the relative flags (39 section 6.3), keeps exactly the resolved velocity, answers Accept Teleportation with the result. Today velocity and flags are discarded |
| Set Entity Motion 0x67 (own entity) | knockback velocity (unchanged, `core/src/combat.cob`) | DG-7 under the answer to Q-5. While gliding: unchanged |
| Explode 0x24 knockback | unchanged | DG-7 under the answer to Q-5 |
| Player Abilities 0x41 | unchanged | flight permission and state (13 section 1.4); the speed fields stay unused (09) |
| Update Mob Effect, Remove Mob Effect | unchanged | the movement effects of 13 section 1 read the client's effect list: Jump Boost, Slow Falling, Dolphin's Grace, Blindness |
| Respawn 0x54 | unchanged | clears the movement state |
| Update Attributes 0x86 (own entity) | not sent today | only if Q-3 is B: the core sends it and the client reads movement attributes. This section is then completed after DG-10, before any consumer task |

## 2. Client to server

| Packet | Client sends | Server accepts (unchanged rules) |
|---|---|---|
| Player Input 0x2B | the shift bit on change, before the position of the same tick (53 section 10.1) | sneak state, used as "descending" of the collision context |
| Player Command 0x2A | start and stop sprinting on change, before the position | sprint flag |
| Player Abilities 0x28 | flying bit on change | flight from creative players |
| Move Player 0x1E to 0x21 | position, rotation, flags 0x01 on ground and 0x02 horizontal collision as the new move computes them; "changed" tested on the difference (research R2) | [data-model.md](../data-model.md) section 5 |

## 3. Invariant (US1-13, SC-004)

For any movement the client's rules produce on a CobolCraft world, the server answers no Player Position and closes no
connection. A Player Position sent for a teleport, a respawn or a portal is not a movement correction.

## 4. Contract tests

| Program | Package | Asserts |
|---|---|---|
| `contract_motion_wire_client` | client | each server-to-client fixture of section 1 produces the stated client state, including a new relative-flags Player Position fixture written from 05b and 39; each client-to-server packet of section 2 equals its fixture |
| `contract_motion_wire_core` | core | the core's builders equal the fixtures; the server-side decode of the section 2 fixtures gives the stated state |

Existing cases in `contract/cases/wire-core.tsv`, `client/tests/contract_wire_client.cob` and
`core/tests/WIREPLAY.cpy` that cover a row are kept and not duplicated.
