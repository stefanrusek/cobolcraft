# Contract: moving blocks of pistons and shulker boxes (content to client and core)

Fixed before any task that consumes it (constitution 3.3). A change of shape returns to the plan. Provider: `content`.
Consumers: `client` and `core`. Rules: `docs/protocol/30-redstone-3-pistons.md` sections 3 to 8 and 10.1,
`31-block-entities-1` section 13, `51-block-shapes.md` sections 3.8.8, 3.8.9 and 6, `59` sections 9.2 and 10.5. This
contract fixes only the interface.

## 1. Moving block record, `contract/copy/CTMOVING.cpy`

| Member | Meaning |
|---|---|
| kind | 1 moving piston, 2 shulker lid |
| dimension handle, block x, y, z | the cell |
| carried state | piston: the moved state; shulker: the box's state |
| facing | piston: the piston's facing; shulker: the box's facing |
| extending, source | piston only |
| progress, previous progress | single precision |
| status | shulker only: closed, opening, opened, closing |
| open count | shulker only |

The caller owns the records: the core in its block entity state, the client in its overlay.

## 2. World access additions (`CTMWORLD.cpy`)

| Member | Meaning |
|---|---|
| moving-block program | a `PROGRAM-POINTER` the engine calls with: handle, block x, y, z, record out, found out |

Where it answers found, the engine takes the cell's collision shape from the record, over the state the cell program
gives. The collision query also asks the neighbouring cells a moving or large shape can reach (51 §6).

## 3. Entries

| Entry | Does | Rules |
|---|---|---|
| the structure resolver (today's `PST-RESOLVE` and the `RS1-PSR-*` programs, moved unchanged, taking the world access) | the blocks a piston move pushes and destroys | 30 part 3 §4, §5 |
| the move plan (today's `RS1-PISTON-MOVEPLAN`, `RS1-PISTON-CONTRACT-PLAN`, moved) | the moving blocks and cell writes of an extend or contract event | 30 part 3 §3.2, §6 |
| `MOVING-TICK` (+ record) | one tick of progress or lid status; says when it ends and when neighbours are told | 30 part 3 §7.2; 31 part 1 §13.2 |
| `MOVING-SHAPE` (+ record, no-clip direction) | the collision shape of a moving block | 30 part 3 §7.5; 51 §3.8.8, §3.8.9 |
| `MOVING-PUSH` (+ record, an entity box) | the direction and distance a box is pushed, with the slime and base rules | 30 part 3 §8.1, §8.4; 31 part 1 §13.5 |
| `MOTION-PISTON` (motion state, world access, record) | applies a piston's tick to a player: slime velocity, push, honey carry, base fix, each move through `MOTION-MOVE` and followed by the block effect pass | 30 part 3 §8; 59 §10.5, §9.2 |
| `MOTION-SHULKER` (motion state, world access, record) | applies an opening lid's push to a player | 31 part 1 §13.5; 59 §10.5 |

`MOVING-PUSH` is also what the core's push of other entities uses, with unchanged behaviour for them.

`MOTION-MOVE` gains the mover kinds piston and shulker (59 §10.5: no edge rule; a stuck multiplier scales a shulker
move, is dropped without scaling for a piston, and both zero the velocity) and the piston's per-tick limit on each axis
(30 part 3 §8.3), whose accumulators join the motion state. `MOTION-BLOCKS` can run at once over one given movement
and drop the latest record (59 §9.2).

## 4. Rules of use

- Order on the client: block events in the packet phase create records; the block entity phase after the player's tick
  advances each record and calls `MOTION-PISTON` or `MOTION-SHULKER` (59 §2.1). A server block update for a cell ends
  its record (30 part 3 §7.4).
- Order on the server: the block entity tick advances the record, pushes other entities as today and calls the same two
  entries on each player's server motion record, leaving the accepted position unchanged.

## 5. Contract tests (both sides)

| Program | Package | Asserts |
|---|---|---|
| `contract_moving_blocks_content` | content | resolver and plan on the examples of 30 part 3 §12; progress, shapes and pushes on the examples of 30 part 3 §12, 31 part 1 §14, 51 and 59 §10.5 |
| `contract_moving_blocks_client` | client | the same prepared world and block event give the records and cell writes the content contract states |
| `contract_moving_blocks_core` | core | the live piston and shulker paths give the records of the contract; other entities are pushed as before |
