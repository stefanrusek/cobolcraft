# Feature Specification: Movement That Matches Minecraft

**Feature Branch**: `003-vanilla-movement`

**Created**: 2026-11-26

**Status**: Draft

**Input**: Operator's requests in a working session on 2026-11-26 (`/speckit-specify` was run with no text, so the
input is the conversation that preceded it): the play-test report "the ice is slippier on the MC client than on
cobolcraft and generally movement is smeoother in MC", and the question "Were you proposing different movement
mechanics in CobolCraft and in Minecraft mode?", asked about a proposal to change only standard worlds.

## Clarifications

### Session 2026-11-26

- Q: Blocks such as soul sand, honey, cobweb, berry bushes, powder snow and bubble columns do not change how a
  Player moves in CobolCraft today. Are their movement effects part of this feature? → A: Yes, include them all
  (operator decision).
- Q: May the missing movement rules be documented from the Minecraft client through a clean-room round (plan Q-1)?
  → A: Yes, run one round now, before the tasks phase (operator decision).
- Q: The movement rules give a brief dip in speed when a Player first walks onto ice. Follow them? (plan Q-2) → A:
  Yes, match Minecraft and reword scenario 3 (operator decision).
- Q: Are Speed, Slowness, Levitation, Soul Speed, Depth Strider and Swift Sneak part of this feature, beside Jump
  Boost, Slow Falling, Dolphin's Grace and Blindness (plan Q-3)? → A: Yes, include them (operator decision).
- Q: Do blocks that break a fall in Minecraft also spare the Player fall damage here (plan Q-4)? → A: Yes
  (operator decision).
- Q: Does a push from a hit or an explosion add to the Player's momentum or replace it (plan Q-5)? → A: Whatever
  Minecraft does (operator decision).
- Q: In Minecraft a landing that hurts removes almost all forward momentum a moment later. Keep that momentum or
  match Minecraft? → A: Match Minecraft (operator decision).
- Q: In Minecraft a Player stepping from ice onto ordinary ground speeds up for an instant before slowing. Match it,
  or slow down smoothly? → A: Match Minecraft (operator decision).
- Q: In Minecraft almost any damage, not only a hurting landing, removes momentum. Which damage does so here (plan
  Q-6)? → A: All that Minecraft does (operator decision).
- Q: Do pistons, shulker boxes, other entities and fishing hooks push the Player in this feature (plan Q-7)? → A:
  Pistons and shulker boxes do; crowding entities and fishing hooks stay out (operator decision).
- Q: Are the effects that protect from falls in Minecraft part of this feature (plan Q-8)? → A: Yes (operator
  decision).
- Q: Cacti do not hurt a Player in CobolCraft. Should they, or does the damage rule cover only damage CobolCraft
  already deals (plan Q-9)? → A: Only damage CobolCraft already deals (operator decision).
- Q: Does a block that grows taller under a Player lift them in this feature, with one more clean-room round (plan
  Q-10)? → A: Yes, and the round is authorised (operator decision).
- Q: Are moving piston blocks drawn in this feature (plan Q-11)? → A: No, later work (operator decision).
- Q: May this feature edit the server's piston pushing without fixing its limits for entities other than Players,
  an exception to constitution Principle 5.7 (plan Q-12)? → A: Yes; the limits stay recorded in tickets (operator
  decision).
- Q: Minecraft lifts any Player whose body is where a block grows, not only one standing on it. Which does the spec
  require? → A: As Minecraft (operator decision).
- Q: CobolCraft turns farmland to dirt only by trampling. Is farmland drying part of this feature? → A: No, later
  work (operator decision).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - As a Player, I want to move the way I do in Minecraft (Priority: P1)

A Player walks, sprints, sneaks, jumps, swims, climbs and flies in the CobolCraft game window. Speed builds up and
winds down, momentum carries through the air, and slippery ground slides, as it does for a player in a Minecraft
client.

**Why this priority**: Movement is what the Player does all the time. In play testing, CobolCraft felt less smooth
than a Minecraft client playing in the same world, and ice behaved differently.

**Independent Test**: In a prepared world with flat ground, an ice strip, a gap to jump, a pool of water, a pool of
lava and a ladder, move through each in CobolCraft and compare distances, speeds and heights with the worked values
of the movement rules; repeat the walk on ice beside a Player using a Minecraft client.

**Acceptance Scenarios**:

1. **Given** a Player standing on level ordinary ground, **When** they hold forward, **Then** their speed builds up
   over the first moments and settles at 4.32 blocks per second, or 5.61 while sprinting.
2. **Given** a Player walking on level ordinary ground, **When** they release all movement keys, **Then** they glide
   about a quarter of a block and stop.
3. **Given** a Player walking from ordinary ground onto ice, **When** they keep holding forward, **Then** their
   speed dips briefly, from 4.32 to no less than 2.8 blocks per second, and is back above 4 blocks per second within
   two seconds.
4. **Given** a Player walking steadily on level ice, **When** they release all movement keys and stay on the ice,
   **Then** they slide about 1.7 blocks and stop.
5. **Given** a Player on level ground, **When** they jump, **Then** they rise about 1.25 blocks; **When** they keep
   holding jump, **Then** they jump again as soon as they land.
6. **Given** a moving Player who leaves the ground, **When** they press or release movement keys in the air, **Then**
   their momentum carries on and the keys steer it only a little.
7. **Given** a sprinting Player, **When** they jump, **Then** they get the extra forward push of a sprint jump.
8. **Given** a Player sneaking on level ordinary ground, **When** they hold forward, **Then** their speed settles at
   1.3 blocks per second.
9. **Given** a Player in water or lava, **When** they move, rise, sink or swim, **Then** their speed builds up, is
   dragged down and follows their keys and view as the movement rules say for that fluid.
10. **Given** a Player on a ladder or other climbable block, **When** they climb, descend, hold still or move
    sideways, **Then** their speed is limited as the movement rules say.
11. **Given** a Player who is allowed to fly, **When** they fly, **Then** speed builds up to 10.9 blocks per second
    (21.8 while sprinting) and 7.5 up or down, and they glide to a stop after releasing the keys.
12. **Given** a standard world and a `cobolcraft` world with the same ground, **When** a Player presses the same keys
    for the same time in each, **Then** they move the same way.
13. **Given** a world hosted by CobolCraft, whether the Player's own or one they joined, **When** they move at any
    speed these rules produce, **Then** they are not pulled back or disconnected for it.
14. **Given** any way a Player moves under their own control on any ground, in any fluid or in the air, **When** they
    start, stop or turn, **Then** their speed changes only as the movement rules say; none of them jumps from rest to
    full speed, or from full speed to rest, where those rules build it up or wind it down.
15. **Given** any block that changes how a Player moves in Minecraft, such as soul sand, honey, cobweb, a berry
    bush, powder snow or a bubble column, **When** the Player walks on it, jumps from it, or moves into, through or
    against it, **Then** their movement changes as it does in Minecraft.
16. **Given** a Player under an effect or wearing an enchantment that changes movement (Speed, Slowness, Jump Boost,
    Levitation, Slow Falling, Dolphin's Grace, Blindness, Soul Speed, Depth Strider or Swift Sneak), **When** they
    move while it applies, **Then** their movement changes as it does in Minecraft.
17. **Given** a falling Player, **When** they pass into, slide down or land on a block that breaks a fall in
    Minecraft, **Then** the fall damage they take is what Minecraft would deal.
18. **Given** a moving piston, including one carrying slime or honey, or an opening shulker box that meets or carries
    a Player, **When** it moves, **Then** the Player is pushed, carried or launched as in Minecraft.
19. **Given** a Player under Jump Boost, Slow Falling or Levitation, **When** they jump, fall or land, **Then** the
    fall damage they take is what Minecraft would deal.
20. **Given** a Player whose body is where a block grows taller, whether or not they stand on that block (for
    example farmland turning back into dirt under them), **When** it changes, **Then** the Player is lifted as in
    Minecraft.

---

### Edge Cases

- (US1-4, US1-6) A Player who lands from a jump or a fall without being hurt keeps their horizontal momentum, and
  the ground they land on then decides how it fades.
- (US1-14, US1-17) Damage that hurts the Player in CobolCraft, such as a hurting landing or a hit, takes away almost
  all of their momentum a moment later, as in Minecraft. Drowning and fully blocked damage do not, and neither does
  a second hit soon after another that only adds damage, apart from any extra knockback of the attack.
- (US1-14) A Player who runs into a wall loses the speed into the wall and keeps the speed along it.
- (US1-14) A push from a hit or an explosion changes the Player's momentum as it does in Minecraft, and then fades
  like the rest of it.
- (US1-14) After the server moves a Player (teleport, respawn, correction), only the momentum the server's move
  allows remains.
- (US1-3) A Player who steps from ice back onto ordinary ground speeds up for an instant, from about 4.2 to about
  5.7 blocks per second, and then slows to the ordinary 4.32.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001** (US1): The Player's movement follows `docs/protocol/13-client-gameplay-and-controls.md` section 1,
  `docs/protocol/53-player-poses.md` sections 6 and 9, the block friction rule of
  `docs/protocol/18-mob-framework.md` section 3.2 and `docs/protocol/59-player-movement-simulation.md`; for pistons,
  shulker boxes and growing blocks also `docs/protocol/30-redstone-3-pistons.md`, document 31 part 1 section 13,
  `docs/protocol/51-block-shapes.md` section 3.8 and document 29b section 9.5. Every movement value comes from these
  documents.
- **FR-002** (US1): Where those documents are silent or incomplete about a movement rule in this feature's scope
  (for example the open question on fluid movement in document 13), the document is completed through a clean-room
  round before the behaviour is built (constitution, Principle II).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For each worked example of a movement rule that this feature covers, the Player's position agrees with
  the example to within 0.001 blocks at every step.
- **SC-002**: The same sequence of key presses on the same ground ends at the same position in a standard world and
  in a `cobolcraft` world.
- **SC-003**: The operator, playing the same stretch of ground and ice in CobolCraft and in a Minecraft client,
  reports no difference in starting, stopping, jumping and sliding.
- **SC-004**: A session that uses every way of moving on a CobolCraft server has no pull-back or disconnect caused
  by movement.

## Assumptions

- One set of movement rules serves both world types. CobolCraft's design document already retired its own movement
  values for both world types and refers to document 13 (`docs/design/standin-content.md` sections 11.1 to 11.4),
  so `cobolcraft` worlds change too.
- "Movement" covers every way a Player moves under their own control that document 13 section 1 describes: walking,
  sprinting, sneaking, jumping, falling, ice and other friction, climbing, water, lava, swimming and flying. It
  also covers every block's effect on that movement.
- Of a block's effects, only its effect on movement and on fall damage is in scope. Others, such as the damage of a
  berry bush or the freezing of powder snow (including the slow-down freezing causes), are unchanged.
- Riding vehicles and animals, elytra gliding, and how mobs move are unchanged.
- Pushes from other entities (including boats and minecarts) and pulls from fishing hooks are not part of this
  feature.
- Drawing moving piston blocks is not part of this feature.
- Which blocks CobolCraft makes grow taller is unchanged by this feature. Farmland drying out and similar block
  changes it does not perform today are later work (CC-0065).
- Key bindings, mouse look and the Minecraft client's own movement are unchanged.
- Frame rate and stutter are outside this feature. The play-test slowdown on the M1 MacBook Air is being
  investigated separately.
- No timing or error-handling requirements beyond the movement rules were requested.

## Plan-Phase Handoff

Non-binding observations for the plan phase to verify.

- `client/src/physics.cob` applies the full walking speed in one tick on ordinary ground and in the air. Its header
  cites the retired design section 11.4 and uses 0.2 walking, 0.28 sprinting, 0.5 flying and 0.375 vertical flying,
  in blocks per tick.
- Momentum is kept only for slippery ground (`physics.cob`, the "Slippery ground" block). Stepping from ordinary
  ground onto ice seems to start from almost no speed. This is the likely cause of the ice report. It was found by
  reading the code and was not measured.
- Knockback is carried by a separate fading term in the same program.
- Tests that may expect the current speeds: `client/tests/test_physics*.cob`, `test_sneak.cob`, `test_swim.cob`,
  `test_sprint_rules.cob`, `acc_us3_fly.cob`, `acc_us8_sprint.cob`.
- View bobbing (`client/src/smooth.cob`) derives its speed on the assumption of ordinary-ground drag.
- A search of the client's physics code found no soul sand, honey, cobweb or similar handling.
- Block speed and jump factors are fields of the block registry documents (`docs/protocol/24-*`, section 4). Whether
  documents describe each block's other movement effects has not been checked.
- The server's checks on player movement (`core/src/movement.cob`) need checking against the higher flying and
  sprinting speeds.
- Document 13's open question 6 says its fluid, honey and soul sand details are summarised, not complete; document
  53 section 9 gives the swimming order.
- The branch starts from `main` at `aba05242` (v0.2.1), which includes a recent landing change in `physics.cob`.
