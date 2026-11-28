# Research: Movement That Matches Minecraft

Companion of [plan.md](plan.md). Values come from `docs/protocol/` and `docs/design/` only (constitution, Principle
II). Repository facts were read at `aba05242` (code) and `62a2c406` (documents) on 2026-11-26, or observed by the probes
in [spikes/](spikes/). The client jar was not read by the plan phase. "59 §n" is
`docs/protocol/59-player-movement-simulation.md`.

## 1. Probes (constitution 3.1)

The feature adds no library, service or protocol library. The dependency whose behaviour the repository does not control
and the plan relies on is GnuCOBOL 3.2.0 (with the shim's `FPFAST` replacement of libcob arithmetic,
`tools/package.mk`). The behaviour of a real Minecraft client is the other outside fact; it cannot be probed and reaches
the feature through the documents.

| Probe | Question | Observed result | Verdict |
|---|---|---|---|
| [spike_move_arith.cob](spikes/spike_move_arith.cob), [spike_move_reference.py](spikes/spike_move_reference.py), [output](spikes/spike_move_arith.out.txt) | Can `FLOAT-LONG` `COMPUTE` follow the per-tick formulas within 0.001 blocks? | Ground 55 ticks, ice 150, jump 12, rotated walk 40: largest difference from an IEEE-double reference 5e-13, with `FPFAST` and with libcob. Walk step 0.215859, release glide 0.255846, ice step 0.207646, slide 1.686716, jump peak 1.252203 | Pass |
| same | Single precision and the sine table against double and `FUNCTION SIN` | Straight walks within 4.2e-6 in 150 ticks; at yaw 37.5, 4.2e-4 in 40 ticks and growing | Finding: R1 |
| same | Cost of a tick of two-axis arithmetic | 1.25 us with `FPFAST`; 230 us with libcob alone | Pass |
| same | `FLOAT-LONG` comparisons | Relative tolerance 1e-7: `NOT =` misses 0.0005 at coordinate 10000.5 and 0.28 at 29999000.5 | Finding: R2, gap K10 |
| [spike_move_current.cob](spikes/spike_move_current.cob), [output](spikes/spike_move_current.out.txt) | Today's client crossing onto ice (handoff) | 0.200000 on ground, 0.020838 on the first ice tick; release on ground stops at once | Handoff cause confirmed |
| `spike_move_reference.py --crossing` (same output) | The documented crossing | 0.215859, then 0.140350 on ice, rising to 0.207744; back on ground 0.283267 first. Matches the table of 59 §7.2 | Became Q-2, now decided |
| [spike_move_f32.cob](spikes/spike_move_f32.cob), [.py](spikes/spike_move_f32.py), [output](spikes/spike_move_f32.out.txt) | Do the single-precision points of 59 hold in COBOL: narrowing, the 65536-entry sine table, the table index of negative angles? | Narrowing into `FLOAT-SHORT` rounds to nearest (6 values); table bit-identical to C by checksum; index right for positive and negative angles; building the table takes 0.02 s with `FPFAST`, 7.3 s without | Pass: R1 |
| [spike_motion_callback.cob](spikes/spike_motion_callback.cob), [spike_motion_world.cob](spikes/spike_motion_world.cob), [output](spikes/spike_motion_callback.out.txt) | Can a lower library query the caller's world through a program pointer with `-fstatic-call`, from a static archive and from shared libraries, and at what cost? | Resolves and runs in all three link forms, the target being a program nothing calls by name in the same source file; 50 ns a call or less | Pass: R15. Not tried: a target alone in an archive member nothing else references |

Probes are not tests and are outside coverage. `spike_move_current.cob` links the client library, the other packages'
libraries and `client/tests/CLTEST.cpy`, and runs from a folder holding `client`, `contract` and an empty `build/`.

## 2. Handoff verification record (constitution 2.6)

| # | Handoff item of spec.md | Result | Evidence |
|---|---|---|---|
| H1 | `physics.cob` applies the full walking speed in one tick; 0.2, 0.28, 0.5, 0.375; cites design 11.4 | Confirmed | lines 173 to 235 and header; probe |
| H2 | Momentum only for slippery ground; ground to ice starts from almost nothing; likely cause of the ice report | Confirmed and measured | lines 290 to 313; probe 0.200 to 0.021 |
| H3 | Knockback is a separate fading term | Confirmed; Minecraft has no such term: Set Entity Motion replaces, Explode adds (59 §13.1) | lines 315 to 330 |
| H4 | The named client tests may expect the current speeds | Superseded: wider | 48 client test programs step the client tick; core fall and knockback tests too |
| H5 | `smooth.cob` derives bob speed from ordinary-ground drag | Confirmed | line 50 |
| H6 | No soul sand, honey, cobweb handling in client physics | Confirmed, except slime and bed vertical bounce | `physics*.cob` |
| H7 | Speed and jump factors are registry fields; other effects' documentation unchecked | Resolved: 59 §10.1 is the closed list | 59 §10 |
| H8 | Server movement checks need checking against higher speeds | Refuted for speed; the pull-back risks are player-dependent shapes and the ground claim | `movement.cob`, `move-check.cob` |
| H9 | 13 Open question 6: fluids, honey, soul sand summarised | Resolved: closed by the round | 13 open questions; 59 §7.4 to §7.6, §8, §10 |
| H10 | Branch starts at `aba05242` with a recent landing change | Confirmed | `WS-LANDED` from `b352317a` (CC-0011); no local tag points at that commit (newest release tag v0.2.0), so "v0.2.1" is not confirmed |

## 3. The clean-room rounds (`62a2c406`, then DG-11) and what they closed

Two reader and reviewer rounds from `minecraft-26.3-client.jar`. First round: review round 2 passed; seven minor fixes
after it were not reviewed again. Second round (DG-11): passed review. Worked examples of both are computed from the
written rules, not observed.

| Gap | Closed by | Status |
|---|---|---|
| DG-1 tick order, key values, distance to the unit square, other velocity changes | 59 §2, §3.2, §4 | Closed. The auto-jump trigger and writers outside this feature are named in 59 Open questions 1, 2 |
| DG-2 speed factor, flight | 59 §7.8, §8.3, §8.4; 30-8 §14.1.1; 44-1 | Closed |
| DG-3 climbable, trapdoor, powder snow | 59 §7.3; 24 part 1 | Closed. Powder snow is not climbable: it only climbs up |
| DG-4 client fall distance | 59 §12.1 to §12.3; 30-8 corrected | Closed |
| DG-5 block effect pass and cell order | 59 §9 | Closed; one corner-walk edge left as read (Open question 9) |
| DG-6 minor collision | 59 §5.4 | Closed |
| DG-7 pushes and server velocity | 59 §13; 05a, 05b, 42-7 | Closed; timing consequences computed, not observed (Open question 6) |
| DG-8 leaving a fluid | 59 §7.5, §7.6; 18, 53 corrected | Closed |
| DG-9 closed block list, mud, ice and slime rows | 59 §10; 24 parts 5 and 8 | Closed for blocks; boats and minecarts are entities and unread (Open question 3) |
| DG-10 effects, enchantments, updates | 59 §11 | Closed for the ten in scope |
| (new) fall damage | 59 §12 | Answered |
| DG-11 lift by a growing block (second round) | 29b part 2 §9.5; 59 §13.6, §13.2; 05b, 05c, 09 | Closed; see below |

Corrections that changed this plan's earlier statements: the move step updates the local player's flags and fall
distance (30-8); the fluid branch is chosen by touching a liquid, not by the block at the feet (53 §9.2); the ledge
assist box and its fluid test (18, 53); powder snow is not a climbable; Set Entity Motion replaces and Explode adds; the
server keeps its own velocity per player; knockback strength is the widened float 0.4; slime and packed ice rows carry
their friction; the straw bed is not a bed for movement.

### 59 open questions and their effect on this feature

| 59 Open question | Effect |
|---|---|
| 1 auto-jump trigger | none: auto-jump is out (CC-0058) |
| 2 other movement sources | Weaving is built with the cobweb (44 part x1 §2.4 gives its values); item use multipliers come from the item component (default and spears, 17 §1.3); powder snow freezing stays out by the spec; the rest are CC-0060 |
| 3 boats, minecarts, entity collision | out by the operator (spec Assumptions); CC-0057 |
| 4 client entity tick order | only matters for entity pushing, which is out (CC-0057) |
| 5 modifier order | none beyond the last bit |
| 6 server tick consequences computed | followed as written; risk; SC-003 |
| 7 server replay with stuck blocks | the core has no "moved wrongly" check, so no pull-back follows; the replay follows the move step |
| 8 suffocation internals | built from the description of 59 §4.4 with each state's suffocation property; low risk |
| 9 corner walk edge | built as written; matters only for a leg crossing several cells |
| 10 flying on the ground | followed as written |
| 11 Teleport Entity naming the player | not built: the core is expected never to send it (gap S11, to be checked) |
| 12 a client tick between a lift and its block update | not analysed by the documents; risk, covered by the live lift test |
| 13 lift of a riding player | followed as written; riding is unchanged by the spec |
| 14 server jump in the second walking example | the test follows the rule (a jump when the server's ground flag is true) |

No open question of 59 needs an operator decision. The decisions the planning raised (Q-6 to Q-12) are answered and
recorded in the spec's Clarifications.

### Pistons, shulker boxes and growing blocks (Q-7, Q-10)

| Need | Documents | Gap |
|---|---|---|
| Block event, resolver, move order, client behaviour | 30 part 3 §3 to §6, §10.1 | none for the Player's movement. The order of vacated cells depends on an unread JDK map (30 part 3 Open question 3); it orders neighbour updates only, which the client does not run |
| Moving block tick, shape, entity rules | 30 part 3 §7, §8; 51 §3.8.9 | none |
| Shulker lid tick, shape, push | 31 part 1 §13; 51 §3.8.8 | none |
| Effects on the Player's velocity, block pass, records | 59 §9.2, §10.5 | none |
| Lift by a growing block | 29b part 2 §9.5; 59 §13.6 | none: the closed list of block changes, candidates, lift amount, packet, client and server effect are given |

**DG-11 (closed).** The second clean-room round, run and reviewed on the operator's authority (Q-10), answered it. What
the design takes from it:

- The lift is a Player Position with change (0, lift, 0), zero velocity and rotation and all nine relative flags
  (59 §13.6; 05b, 09). The client keeps its velocity; the server's velocity becomes the known movement.
- Candidates are chosen by box overlap with the added shape, spectators excepted, not by standing on the block; the
  teleport is sent also when the lift is 0 (29b part 2 §9.5.1).
- The block changes that lift are a closed list of seven (§9.5.3); which of them the server performs is gap S16.
- Corrections that change behaviour outside the lift: the Move Player send rule (05c); an unconfirmed teleport (05c,
  59 §13.2: rotation still applied, re-send only on a movement packet after more than 20 ticks, with a new id, absolute
  and zero velocity); teleports write the server velocity (59 §13.5).

### Worked examples for SC-001

Engine examples (content): 59 §3, §4, §5.4, §6.2, §7 (all tables), §8, §9, §10, §12.1 to §12.3; 51 §6.1; 53 §5.4,
§6.2, §9.2; 13 §9 jump arc; the entity push, shape and shulker examples of 30 part 3 §12, 31 part 1 §14 and 51 §3.8.
Client: 59 §2.3, §5.3, §7.8 toggles, §11.1 to §11.3, §13.1 to §13.3 and §13.6. Core: 59 §11.4, §11.5, §12.4, §13.5,
§13.6; 29b part 2 §9.5. Not covered
by this feature, so outside SC-001: the hook and entity push examples of 59 §13.1 and §13.4, the wind charge impulse
rows and example of §12.4, and the redstone timing examples that move no Player.

## 4. Decisions

### R1 Arithmetic
- Decision: motion values are `FLOAT-LONG`; where 59 marks single precision, the value is narrowed through
  `FLOAT-SHORT`; yaw sine and cosine come from the documented float table, built once.
- Rationale: probes: rounding and table are exact, cost is negligible, and branch tests such as friction above 0.6
  depend on the widened float.
- Alternatives: double everywhere (differs from the documented thresholds and drifts at oblique yaw); single-precision
  fields (the documents keep velocity in double).

### R2 Comparisons
- Decision: "changed" tests compare a difference with zero.
- Rationale: probe: `NOT =` hides real movement far from the origin.

### R3 One velocity, the documented order
- Decision: one velocity; the client tick is the list of 59 §2.2. The ice, knockback, fluid and direct-step paths are
  deleted.

### R4 Block movement data belongs to content
- Decision: extend `CTBSHAPE.cpy`, filled from one table in `content` that cites its documents; friction, climbable,
  bounce and landing lists in content, core and client move there.
- Alternatives: derive from registry rows (friction is written two ways); keep per-package lists.

### R5 Shapes that depend on the Player
- Decision: one content entry returns a shape for a context; the engine and the server check use it.

### R6 One player box and eye height
- Decision: in `content`; the client and core copies call it.

### R7 Input timing in ticks
- Decision: sprint and flight toggle run in the tick with the documented counters; frames only latch a key.

### R8 Server scope
- Decision: the server gains the player's motion tick, fall rules, movement attributes and velocity sends. It gains no
  movement validation: the existing checks run over the new shapes.
- Rationale: the scenarios need the first four; US1-13 asks for no pull-back and the spec asks for no new check.

### R9 Teleports, respawn and pushes
- Decision: the client follows 59 §13 and §2.4: replace, add, teleport flags, keep bits, spectator, own attack.

### R10 Tests
- Decision: rules verified in content against 59's examples; one `acc_f3us1_<topic>` program per scenario and edge case
  at the lowest layer that observes it; convergence for what needs both sides; no double; no E2E.

### R11 Body size per content set is unchanged
- Decision: cobolcraft 0.7 x 1.75, standard 0.6 x 1.8. US1-12 and SC-002 compare movement; the retired design sections
  covered movement values, not the body. The sets differ only against walls and in gaps.

### R12 Gliding and riding
- Decision: unchanged; a glide still starts from the last tick's horizontal displacement.

### R13 Execution mode
- Decision: standard.

### R14 Round before tasks
- Decision: done; this revision checks the design against its text.

### R15 One motion engine in content
- Decision: the move, travel, fluid, jump and block rules are one implementation in `content`, with the caller's world
  reached through a program pointer (contract motion-engine).
- Rationale: the server must run the same rules with no input to keep its velocity (59 §13.5); content is below both
  consumers; the probe shows the call works and is cheap.
- Alternatives: a second, reduced step in the core (two implementations of climbing, fluids, bounce and block effects);
  the engine in the core with the client calling it (a client dependency on server code for its own movement, and the
  world access still needs the same seam); a new package (no gain over content, more build wiring).

### R16 Server velocity
- Decision: one velocity per player in the core, updated by the engine tick, replayed moves, hits and teleports; one
  entry applies a hit to it and marks or sends it. The existing senders of Set Entity Motion that are hits use it.

### R17 Attributes and effects
- Decision: the core computes the effective attributes and sends them; the client stores base and modifiers and adds
  only the sprint modifier. Command-set attribute values are not part of this (CC-0060).

### R18 Fall distance
- Decision: the core keeps a fall distance by 59 §12 in place of the fall start; the engine reports landings and resets.

### R19 Rules read into the spec's wording
- Built, because the spec's wording covers them: Weaving on the cobweb (scenario 15); push out of suffocating blocks
  (15, 14); the geyser (15); the slow-down of the Player's own attack (14); the unloaded-chunk fall rule of 59 §7.2 and
  the position clamp (14); the sprint field of view from the movement speed attribute (an approximation in an owned
  file).
- Not built: auto-jump, spectator pass-through, riding, gliding, the sources of CC-0060, the pushes of CC-0057, pistons
  and shulker boxes acting on other entities (CC-0062, CC-0029), the drawing of moving blocks (CC-0063).

### R20 Unknown chunks
- Decision: a cell of a chunk the client does not have stays a full cube (today's behaviour; the documents describe only
  the vertical fall rule, which is added). The SC-004 course shows whether sprint flight reaches such a cell.

### R21 Moving blocks are shared and the client runs the move
- Decision: the resolver, move plan, moving-block arithmetic and push geometry move from `core` to `content`; the
  client runs a piston move from the Block Event on its replica and holds the moving blocks in an overlay the renderer
  does not read.
- Rationale: Minecraft sends no block updates for moving blocks; the client must compute them (30 part 3 §10.1) and
  both sides must agree. The overlay leaves the picture as it is today.
- Alternatives: the server sends the moving block entities (departs from the documented wire); the client calls the
  resolver in `core` (the resolver reads core memory a joined client does not have); writing the moving blocks into the
  replica (pushed blocks would vanish from view while they move).

### R22 Movement acceptance
- Decision: the server refuses a position for a collision only when the new box meets a block the last accepted box did
  not (53 §10.3 rule 7).
- Rationale: with blocks that move, the current rule (refuse any overlap) pulls back a Player whom the server's piston
  has reached first; the documented rule accepts that and still refuses walking into a block.
- Alternatives: ignore collisions near moving blocks (accepts more than Minecraft); replay every move and compare
  (a new check the spec does not ask for).

### R23 Non-player entities
- Decision: their piston, shulker and lift behaviour is unchanged, the farmland lift they already get included.
- Rationale: spec Assumptions leave mob movement unchanged (plan, Complexity Tracking).

### R24 Teleports and confirmation
- Decision: one core entry performs every teleport and keeps the confirmation state and the known movement by 59 §13.2;
  the client resolves Player Position by its flags. The Move Player send rule of 05c replaces the client's comparison.
- Rationale: the lift depends on all of them, and the same server record serves the edge case about server moves.
- Alternatives: handle relative flags for the lift only (two teleport paths; the server velocity would be wrong after
  the others).

### R25 Which block changes lift
- Decision: one core lift entry, called by the changes of the closed list the server performs (trampling, the eye of
  ender). The changes it does not perform are not built (CC-0065); mobs are lifted as today (CC-0062).
- Rationale: the spec asks for the lift when a block grows taller, not for block growth the server lacks.

