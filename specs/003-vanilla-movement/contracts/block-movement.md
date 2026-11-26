# Contract: block movement properties and collision context (content to client and core)

Fixed before any task that consumes it (constitution 3.3). A change of shape returns to the plan. Provider:
`content`. Consumers: `client`, `core`. Materialized as `contract/copy/CTBSHAPE.cpy` (extended),
`contract/copy/CTBSCTX.cpy` (new) and the entries below. Values: [data-model.md](../data-model.md) section 3.

## 1. Tables of `CTBSHAPE.cpy` (indexed by block state + 1, `BSH-MAX-STATES` rows, EXTERNAL record)

| Item | Type | Meaning | Today |
|---|---|---|---|
| `BSH-SLIP` | `BINARY-SHORT UNSIGNED` | friction in thousandths, 0 for the default 600 | exists, unchanged meaning (also read by `core/src/stdmobs.cob`) |
| `BSH-SPEED` | `BINARY-SHORT UNSIGNED` | speed factor in thousandths, 0 for 1000 | new |
| `BSH-JUMP` | `BINARY-SHORT UNSIGNED` | jump factor in thousandths, 0 for 1000 | new |
| `BSH-BOUNCE` | `BINARY-SHORT UNSIGNED` | block bounce in thousandths | new (replaces `BOUNCE-OF-KEY`) |
| `BSH-CLIMB` | `BINARY-CHAR UNSIGNED` | 0 none, 1 climbable tag, 2 scaffolding, 3 trapdoor candidate (DG-3), 4 powder snow | values 2 to 4 new; every existing reader of "not 0" is updated in the same slice |
| `BSH-INSIDE` | `BINARY-CHAR UNSIGNED` | 0 none, 1 cobweb, 2 berry bush, 3 powder snow, 4 honey, 5 bubble column push up, 6 bubble column drag down | new |
| `BSH-STEP` | `BINARY-CHAR UNSIGNED` | 0 none, 1 slime step slow-down | new |
| `BSH-FLAGS` | `BINARY-CHAR UNSIGNED` | bit 0 suppresses bounce, bit 1 geyser launches from this state, bit 2 geyser-passable | new |
| `BSH-CTX` | `BINARY-CHAR UNSIGNED` | 0 static shape, 1 light block, 2 scaffolding, 3 powder snow | values 2 and 3 new |

The stuck vectors, the honey, bubble, slime and geyser formulas are behaviour of the consumer, selected by these
kinds. `BSH-BUILD` fills every table when a content set is open, for both content sets.

If the round (DG-9) finds a behaviour that no kind covers, the kinds are extended here before the consumer task.

## 2. `CTBSCTX.cpy` (collision context, group `BSX-CONTEXT`)

| Item | Type | Meaning |
|---|---|---|
| `BSX-FEET-Y` | `FLOAT-LONG` | the entity's feet height |
| `BSX-FALL-DISTANCE` | `FLOAT-LONG` | blocks |
| `BSX-DESCENDING` | `BINARY-LONG` | 1 while shift is held |
| `BSX-SNOW-WALKER` | `BINARY-LONG` | 1 when the entity can walk on powder snow |

## 3. Entries

| Entry | Parameters | Result |
|---|---|---|
| `BSH-COLL-AT` | state, block y (`BINARY-LONG`), `BSX-CONTEXT`, shape id out | the cell's collision shape for the context: the rules of 51 R-C20 (scaffolding) and 44 part x1 section 2.2 (powder snow); for `BSH-CTX` 0 the id of `BSH-COLL-ID` |
| `PLAYER-POSE-BOX` | pose (`BINARY-LONG`, Pose enum id), half width out, height out, eye height out (`FLOAT-LONG`) | the box of the open content set's Player for the pose (53 section 2.1; standin section 3) |

`BSH-COLL-ID` stays for callers without an entity (mobs, items, rays).

## 4. Contract tests (both sides, no network)

| Program | Package | Asserts |
|---|---|---|
| `contract_movement_blocks_content` | content | every row of data-model section 3 in the tables; `BSH-COLL-AT` for the document cases of scaffolding and powder snow; the pose boxes |
| `contract_movement_blocks_client` | client | the client's collision and friction queries give the shape and property of a prepared state through these entries |
| `contract_movement_blocks_core` | core | the server's movement check, climbable test, landing rule and pose box give the same answers for the same states and context |
