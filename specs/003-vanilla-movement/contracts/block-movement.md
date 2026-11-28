# Contract: block movement properties, shapes and landing rules (content to client and core)

Fixed before any task that consumes it (constitution 3.3). A change of shape returns to the plan. Provider:
`content`. Consumers: `client`, `core` and the motion engine ([motion-engine.md](motion-engine.md)). Materialized as
`contract/copy/CTBSHAPE.cpy` (extended), `contract/copy/CTBSCTX.cpy` (new) and the entries below. Values:
[data-model.md](../data-model.md) section 3.

## 1. Tables of `CTBSHAPE.cpy` (indexed by block state + 1, `BSH-MAX-STATES` rows, EXTERNAL record)

| Item | Type | Meaning | Today |
|---|---|---|---|
| `BSH-SLIP` | `BINARY-SHORT UNSIGNED` | friction in thousandths, 0 for the default 600 | exists, unchanged meaning (also read by `core/src/stdmobs.cob`) |
| `BSH-SPEED` | `BINARY-SHORT UNSIGNED` | speed factor in thousandths, 0 for 1000 | new |
| `BSH-JUMP` | `BINARY-SHORT UNSIGNED` | jump factor in thousandths, 0 for 1000 | new |
| `BSH-BOUNCE` | `BINARY-SHORT UNSIGNED` | restitution in thousandths | new (replaces `BOUNCE-OF-KEY`) |
| `BSH-CLIMB` | `BINARY-CHAR UNSIGNED` | 0 none, 1 climbable tag, 2 scaffolding (no sneak hold), 3 ladder, 4 open trapdoor | values 2 to 4 new; every existing reader of "not 0" is updated with it, and kind 4 climbs only over a ladder of the same facing |
| `BSH-FACING` | `BINARY-CHAR UNSIGNED` | facing of a ladder or trapdoor: 0 none, 1 north, 2 south, 3 west, 4 east | new |
| `BSH-INSIDE` | `BINARY-CHAR UNSIGNED` | 0 none, 1 cobweb, 2 berry bush, 3 powder snow, 4 honey, 5 bubble column up, 6 bubble column down | new |
| `BSH-STEP` | `BINARY-CHAR UNSIGNED` | 0 none, 1 slime step slow-down | new |
| `BSH-FALL` | `BINARY-CHAR UNSIGNED` | landing rule: 0 default, 1 half distance (dyed bed, shelf mushroom), 2 multiplier 0.2 (hay, honey), 3 slime, 4 powder snow, 5 upward dripstone tip | new (replaces `FALL-ON-KEY`) |
| `BSH-FLUID`, `BSH-LEVEL` | `BINARY-CHAR UNSIGNED` | 0 none, 1 water, 2 lava; amount and falling as `ST-LEVEL` | new in content |
| `BSH-FLAGS` | `BINARY-SHORT UNSIGNED` | bits: suppresses bounce; suffocating; solid for fluid flow; resets a fall in the clip of 59 §12.3; fence, wall or fence gate (supporting block); erupting or continuous geyser; geyser-passable; has a block entity; unbreakable | new |
| `BSH-CTX` | `BINARY-CHAR UNSIGNED` | 0 static shape, 1 light block, 2 scaffolding, 3 powder snow, 4 moving piston, 5 shulker box | values 2 to 5 new |
| `BSH-PUSH` | `BINARY-CHAR UNSIGNED` | push reaction of the state (30 part 3 §5) | new in content (the core's block table holds it today) |

`BSH-BUILD` fills every table when a content set is open, for both content sets, from one movement table that cites its
documents. Tag-defined values are read from the open set's tags where the document names a tag.

## 2. `CTBSCTX.cpy` (collision context, group `BSX-CONTEXT`)

| Item | Type | Meaning |
|---|---|---|
| `BSX-FEET-Y` | `FLOAT-LONG` | the entity's feet height at the query |
| `BSX-FALL-DISTANCE` | `FLOAT-LONG` | blocks |
| `BSX-DESCENDING` | `BINARY-LONG` | 1 while shift is held |
| `BSX-SNOW-WALKER` | `BINARY-LONG` | 1 when leather boots are worn |
| `BSX-NOCLIP` | `BINARY-LONG` | the direction of a piston move in progress, else -1 (30 part 3 §7.5) |

## 3. Entries

| Entry | Parameters | Result |
|---|---|---|
| `BSH-COLL-AT` | state, block y (`BINARY-LONG`), `BSX-CONTEXT`, shape id out | the cell's collision shape for the context by 59 §10.6; for `BSH-CTX` 0 or 1 the id of `BSH-COLL-ID`; kinds 4 and 5 take their shape from the moving block record ([moving-blocks.md](moving-blocks.md)), and without one a moving piston is empty and a shulker box the full cube (51 §3.8.8, §3.8.9) |
| `BSH-FALL-ON` | state, shift (`BINARY-LONG`), distance factor, added distance, multiplier (`FLOAT-LONG`), damage kind out | the landing rule of 59 §12.4 |
| `PLAYER-POSE-BOX` | pose (`BINARY-LONG`, Pose enum id), half width, height, eye height out (`FLOAT-LONG`) | the box of the open content set's Player for the pose (53 §2.1; standin section 3) |

`BSH-COLL-ID` stays for callers without an entity (mobs, items, rays).

## 4. Contract tests (both sides, no network)

| Program | Package | Asserts |
|---|---|---|
| `contract_movement_blocks_content` | content | every row of data-model section 3 in the tables; `BSH-COLL-AT` on the examples of 59 §10.6; `BSH-FALL-ON` on the table of §12.4; the pose boxes |
| `contract_movement_blocks_client` | client | the client's collision and property queries give the shape and property of a prepared state through these entries |
| `contract_movement_blocks_core` | core | the server's movement check, climbable test, landing rule and pose box give the same answers for the same states and context |
