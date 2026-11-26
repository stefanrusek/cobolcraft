# Research: Movement That Matches Minecraft

Companion of [plan.md](plan.md). Values come from `docs/protocol/` and `docs/design/` only (constitution, Principle
II). Everything here was read from the repository at `aba05242` on 2026-11-26 or observed by the probes in
[spikes/](spikes/). The client jar was not read.

## 1. Probes (constitution 3.1)

The feature adds no library, service or protocol library. The one dependency whose behaviour the repository does not
control and the plan relies on is GnuCOBOL 3.2.0 floating-point arithmetic (with the shim's `FPFAST` replacement of
libcob arithmetic, `tools/package.mk`). The behaviour of a real Minecraft client is the other outside fact; it cannot
be probed at plan time (the jar is read only by a clean-room reader) and reaches the feature through the documents.

| Probe | Question | Observed result | Verdict |
|---|---|---|---|
| [spike_move_arith.cob](spikes/spike_move_arith.cob) with [spike_move_reference.py](spikes/spike_move_reference.py), output [spike_move_arith.out.txt](spikes/spike_move_arith.out.txt) | Can `FLOAT-LONG` `COMPUTE` follow the per-tick formulas of 13 section 1.3 within 0.001 blocks (SC-001)? | Ground 55 ticks, ice 150 ticks, jump 12 ticks, rotated walk 40 ticks: largest difference from an independent IEEE-double reference 5e-13 blocks, with `FPFAST` and with libcob. Ground step 0.215859, release glide 0.255846; ice step 0.207646, slide 1.686716; jump peak 1.252203. These match US1-1, US1-2, US1-4 and US1-5. | Pass |
| same | Does single precision plus the 65536-entry sine table (39) differ from double plus `FUNCTION SIN`? | Straight walks differ by at most 4.2e-6 blocks in 150 ticks. A walk at yaw 37.5 degrees differs by 4.2e-4 blocks in 40 ticks and the difference grows with distance. | Finding: decision R1 |
| same | Cost of one tick of two-axis arithmetic with a sine and a cosine | 200,000 ticks: 0.25 s with `FPFAST` (1.25 us a tick); 46 s with libcob alone (230 us a tick). | Pass |
| same | Comparisons of `FLOAT-LONG` items | `0.0029999999999 < 0.003` is false (relative tolerance 1e-7). `a NOT = b` is false for a position difference of 0.0005 at coordinate 10000.5, 0.005 at 100000.5, 0.065 at 1000000.5 and 0.28 at 29999000.5, with and without `FPFAST`. | Finding: decision R2, gap K10 |
| [spike_move_current.cob](spikes/spike_move_current.cob), output [spike_move_current.out.txt](spikes/spike_move_current.out.txt) | What does today's client do when a walk crosses from ordinary ground onto ice, and on release? (spec Plan-Phase Handoff) | 0.200000 blocks a tick on ground, then 0.020838 on the first ice tick, 0.143855 after 12 ticks; release on ordinary ground stops in the same tick (0.000000). | Handoff cause confirmed |
| `spike_move_reference.py --crossing` (same output file) | What do the documented rules give for the same crossing? | 0.215859 on ground, 0.140350 on the first ice tick, rising to 0.207744; back on ground with the key held 0.283267, 0.252664, 0.235954 towards 0.215859. | Finding: open question Q-2 of the plan |

How to run the probes: each `.cob` header says what it measures. `spike_move_arith.cob` compiles alone (add the
`-A` defines of `tools/package.mk` and link `libccshim.a` and `-lgmp` for the production arithmetic).
`spike_move_current.cob` links the client library, the other packages' libraries and `client/tests/CLTEST.cpy`, and
runs from a folder that holds `client`, `contract` and an empty `build/`. Probes are not tests and are outside
coverage.

## 2. Handoff verification record (constitution 2.6)

| # | Handoff item of spec.md | Result | Evidence |
|---|---|---|---|
| H1 | `physics.cob` applies the full walking speed in one tick on ground and in air; uses 0.2, 0.28, 0.5, 0.375 and cites design 11.4 | Confirmed | `client/src/physics.cob` header and lines 173 to 235; probe: 0.200000 from the first tick |
| H2 | Momentum is kept only for slippery ground; ground to ice starts from almost no speed; likely cause of the ice report | Confirmed and measured | lines 290 to 313; probe: 0.200 to 0.021 |
| H3 | Knockback is a separate fading term | Confirmed | lines 315 to 330, `PL-KB-X`, `PL-KB-Z`; `EXPLODE-READ` adds to it |
| H4 | The named client tests may expect the current speeds | Superseded: the set is wider | 48 client test programs run `PHYS-TICK` or step the client tick, and convergence programs walk the player (`client/tests/acc_us3_movement.cob` asserts 0.2 a tick). Which of them fail is established in implementation |
| H5 | `smooth.cob` derives the bob speed from ordinary-ground drag | Confirmed | `client/src/smooth.cob` line 50 (`x 0.546`) |
| H6 | No soul sand, honey, cobweb or similar handling in the client's physics | Confirmed, with one exception | no such rule in `client/src/physics*.cob`; slime and bed vertical bounce exist (`physics-bounce.cob`) |
| H7 | Speed and jump factors are registry fields; other block effects' documentation unchecked | Partly refuted | The closed factor list is 44 part 1 section 4.4 (seven blocks); registry rows are inconsistent (packed ice and slime rows carry no friction, 24 part 5). Other effects are documented in 44 part x1 section 2, 29a section 6, 29b part 7 section 6, 29b part 2, 24 part 5 (slime), 31 part 8 section 9.6. No document shows the set is complete (DG-9) |
| H8 | The server's movement checks need checking against higher speeds | Refuted for speed | `core/src/movement.cob` and `move-check.cob` have no speed or distance check; `MOVE-ABILITIES` accepts flight from creative players. The real pull-back risks are shapes that depend on the Player and the ground claim (gap S1) |
| H9 | 13 Open question 6 leaves fluids, honey and soul sand summarised; 53 section 9 gives the swimming order | Confirmed, mostly closed by other documents | 53 section 9 and 18 section 3.2 give water and lava; 29b part 7 section 6 and 44 part 1 section 4.4 give honey and soul sand. Remainder: DG-8, DG-9 |
| H10 | The branch starts from `main` at `aba05242` with a recent landing change | Confirmed | `git log`; landing flag `WS-LANDED` from `b352317a` (CC-0011). No local tag points at that commit (the newest local release tag is v0.2.0), so "v0.2.1" is not confirmed |

## 3. Documentation gaps: the clean-room round (FR-002, Principle II)

The round is not started. It is a prerequisite (plan open question Q-1). Target: new sections in
`docs/protocol/13-client-gameplay-and-controls.md` (section 1) or one new document that section 1 points to, plus
the corrections named below. Artifact: `minecraft-26.3-client.jar`, SHA-256
`4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`.

| Gap | Document and section | Missing rule | Slices blocked |
|---|---|---|---|
| DG-1 Local player tick order | 13 sections 1.1, 1.3 to 1.5; 53 sections 3 to 5 and 9; 39 section 2.2a | One ordered list of everything the local player does to input, flags and velocity in a tick: timers, velocity clean-up, input vector, sprint start and stop, flight toggle and flight vertical input ("applied before `travel`", 13 section 1.4, with no order against clean-up and jump), the sneak and sink step, jump, travel, block effects, pose update; which tick's crouch and shift values each step reads; any further velocity change the local player makes (the reader states whether one exists). Also the definition of "distance-to-unit-square" in 13 section 1.1 | tick pipeline, all stories' ordering |
| DG-2 After the collision | 30 part 8 section 14.1.1 steps 3 and 7; 18 section 3.3; 44 part 1 section 4.4; 13 section 1.4 | Which velocity components the block speed factor multiplies and with which per-player conditions; whether jump factor, climbing, bounce, block speed factor and `stepOn` apply while the Player flies (13 section 1.4 names only fluids and stuck blocks) | speed factors, flight |
| DG-3 Climbable test | 24 part 1 section 12.2 row `climbable` ("a trapdoor test follows (not read further)"); 17 open item 19; 18 section 3.2.1 B4 | The rule by which a trapdoor is climbable; the cell the test reads; the powder snow climbing condition for a player | climbing |
| DG-4 Fall distance on the client | 30 part 8 sections 14.1.1 step 4 and 14.1.7 | Whether and how the local player accumulates and resets fall distance. Needed by the powder snow collision shape (`fallDistance > 2.5`, 44 part x1 section 2.2) and the sneak edge rule (53 section 5.1) | powder snow, sneak edge |
| DG-5 Block effect pass | 39 section 2.2a; 30 part 8 section 14.1.11 ("on a server level always") | Whether the pass runs on the client for its own player every tick; the order of the cells within a leg, which decides the result when several cells change velocity (a column of bubble cells, cobweb with a berry bush) | block effects |
| DG-6 Minor horizontal collision | 13 section 1.5 (`minorHorizontalCollision`) | The test that makes a horizontal collision minor | sprint stop |
| DG-7 Pushes and server velocity | 05a section 0x24; 05b section 0x67; 42 part 7 section 3.2 step 4 | What the client does to its velocity for Set Entity Motion on itself and for the Explode knockback (replace or add, which components, when in the tick) | pushes (also open question Q-5) |
| DG-8 Leaving a fluid | 53 section 9.2 step 9 against 18 section 3.2 | The two documents give different expressions for the free-space test of the ledge assist; whether a fluid in that space blocks it; whether the lava falling adjustment depends on sprinting | fluids |
| DG-9 Completeness of block movement effects | 18 section 3.3 ("not specified here"); 24 part 8 open question 22 (mud) | A closed list of every block behaviour that changes a player's movement (inside, step-on, landing and bounce hooks, shapes that depend on the Player, block entities that move players), with the rule of each one not yet written; mud's slowdown or its absence; the friction of packed ice and slime blocks in the 24 part 5 rows, to agree with 44 part 1 section 4.4; close 13 Open question 6 with pointers | US1-15 |
| DG-10 (only if Q-3 is answered B) Effects and enchantments | 17 sections on effects and enchantments; 28; 18 section 2.6 | Speed and Slowness amounts and operations, when Soul Speed's location modifiers apply and end, which attribute updates the server sends a player and when | effect attributes |

Worked examples: SC-001 measures against the worked examples of the movement documents (13 section 9 "Jump arc" and
"Flight toggle", the steady-state values of 13 sections 1.3 and 1.4, 53 sections 5.4, 6.2 and 9.2, 18 section
3.2.1 player row, 51 section 6.1, 29a E12, 29b part 7 and 44 part x1 section 2). The round adds a worked example for
every rule it writes, so SC-001 covers it.

## 4. Decisions

### R1 Arithmetic
- Decision: movement state is `FLOAT-LONG`; the built-in `FPFAST` arithmetic is used as it is; yaw sines and cosines
  come from the documented 65536-entry float table (39 section 6.3) through one small program; constants are written
  with the widened values the documents give.
- Rationale: double matches the documented formulas to 5e-13 blocks and costs 1.25 us a tick; the table removes the
  one difference from Minecraft that grows with distance.
- Alternatives: single-precision fields everywhere (no measurable gain on straight walks, more conversions);
  `FUNCTION SIN` (drifts from Minecraft at oblique yaw); new C glue (nothing to adapt, Principle I).

### R2 Comparisons
- Decision: a position or velocity "changed" test compares the difference with zero; thresholds keep `<` and `>`
  (the 1e-7 relative tolerance moves a 0.003 threshold by 3e-10).
- Rationale: probe: `NOT =` between two positions hides real movement far from the origin.
- Alternatives: scaled integers for positions (a rewrite of every packet and collision path).

### R3 One velocity, the documented pipeline
- Decision: the client keeps one velocity vector and runs the documented tick: input, jump, travel by medium (air,
  water, lava, flying), one entity move (stuck multiplier, edge protection, collision with step-up, flags, bounce,
  speed factor), block effects, pose. The separate ice, knockback, fluid-velocity and direct-step paths are deleted.
- Rationale: every acceptance scenario of US1 follows from the same chain; the special cases of today's code exist
  because it has no momentum.
- Alternatives: add momentum to the air and ground branches of `PHYS-TICK` (keeps four velocity states and cannot
  express the documented order).

### R4 Block movement data belongs to content
- Decision: extend the shape tables (`contract/copy/CTBSHAPE.cpy`) with the movement properties of every state,
  filled from one table in `content` that cites its documents. Friction names, climbable lists, bounce values and
  climb keys now spread over content, core and client move there.
- Rationale: client and server must agree; the tables already carry friction and climbability.
- Alternatives: derive from the generated registry rows (rows are inconsistent, H7); keep per-package lists.

### R5 Collision shapes that depend on the Player
- Decision: one content entry returns a cell's collision shape for a context (feet height, descending, fall
  distance, powder-snow walker); the client's collision and the server's movement check both use it.
- Rationale: scaffolding and powder snow (51 section 3, R-C20; 44 part x1 section 2.2) are static today, and any
  client-only change would be refused by the server.
- Alternatives: turn the server check off for those blocks (changes what the server accepts without a rule).

### R6 One player box and eye height
- Decision: the pose box and eye height live in `content`; the copies in client (`PHYS-STAND-BOX`, `PHYS-BOX`,
  `PHYS-EYE`) and core (`MOVE-POSE-BOX`, `POSE-EYE`) call it.
- Rationale: they differ today (swimming width of the cobolcraft set, no gliding pose on the server).

### R7 Input timing in ticks
- Decision: sprint start and stop and the flight toggle run in the client tick with the documented tick counters;
  the per-frame code keeps only the latch of a key pressed between ticks.
- Rationale: 13 sections 1.4 and 1.5 are written per tick; today they run per frame with milliseconds.

### R8 Server scope
- Decision: the server gains no movement validation. It changes only where it would otherwise disagree with the new
  movement (R5, R6, climbable cells) and, depending on Q-3 and Q-4, effect attributes and fall-distance resets.
- Rationale: US1-13 asks for no pull-back; the spec asks for no new check (Principle 2.7).

### R9 Server teleports and pushes
- Decision: the client applies Player Position with its velocity and relative flags by the rule of 39 section 6.3 and
  answers with the result; pushes follow DG-7 under the answer to Q-5.
- Rationale: edge case "after the server moves a Player"; today velocity and flags are discarded.

### R10 Tests
- Decision: one `acc_f3us1_<topic>` program per acceptance scenario and edge case in the lowest layer that can
  express it; expected values are transcribed from the documents, never taken from a run of the code; SC-004 is a
  cross-package convergence test; no test double; no E2E.

### R11 Body size per content set is unchanged
- Decision: the cobolcraft set keeps its 0.7 x 1.75 box (standin section 3) and the standard set 0.6 x 1.8.
- Rationale: US1-12 and SC-002 compare movement over the same ground. Design sections 11.1 to 11.4 retired movement
  values, not the body. The two sets can differ only where the body touches something (against a wall, in a gap).

### R12 Gliding and riding
- Decision: the glide step and riding are unchanged; a glide still starts from the last tick's horizontal
  displacement.
- Rationale: spec Assumptions.

### R13 Execution mode
- Decision: standard (plan, "Execution mode").

### R14 Order of the round and the tasks phase
- Decision: the clean-room round runs before tasks are generated, and its findings are checked against
  [data-model.md](data-model.md) and [contracts/](contracts/); a contract change returns to the plan.
- Rationale: five gaps (DG-1, DG-3, DG-5, DG-7, DG-9) can change the shape of the contracts or the pipeline.
