# Client gameplay and controls

| Item | Value |
|---|---|
| Covers | Player movement physics and flight, block-break progress, crafting and the recipe book, the off-hand swap, the F3 debug overlay, F5 camera modes, the options screens and `options.txt`, the resource-pack screen |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (version 26.3). This is the artifact already recorded in [README.md](README.md); no new artifact. |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data files and language file inside the jar, with no execution |
| Ticket | `tickets/CC-0001-client-polish.md` |

The wire side of these features is already specified and is not repeated here. See
[05a](05a-play-clientbound-00-71.md) (Block Destruction 0x05, Place Ghost Recipe 0x40, Block Changed Ack),
[05b](05b-play-clientbound-72-143.md) (Recipe Book Add 0x4B, Remove 0x4C, Settings 0x4D, Update Recipes 0x88,
RecipeDisplayEntry), [05c](05c-play-serverbound.md) (Container Click 0x12, Place Recipe 0x27, Player Abilities 0x28,
Player Action 0x29, Player Input 0x2B, Recipe Book Change Settings 0x2F, Recipe Book Seen Recipe 0x30),
[09](09-cobolcraft-profile.md) (which of these CobolCraft sends) and
[../design/standin-content.md](../design/standin-content.md) (cited below as "standin-content §n": CobolCraft's own content). This document says what the client does with them.

Conventions: "tick" is 1/20 s. Class names in backticks say where a fact was read. "(inferred)" marks a value
deduced rather than read. Floating-point values are IEEE single precision (`float`) where the source used `float`
and double precision otherwise; where it matters it is stated.

---

## 1. Movement

### 1.1 Inputs

`KeyboardInput.tick` builds each tick a 7-flag `Input` record (forward, backward, left, right, jump, shift,
sprint; the same order as the Player Input packet masks 0x01 to 0x40 in 05c). The move vector is
`(left-right impulse, forward-back impulse)` where each impulse is +1, -1 or 0 (both or neither key = 0), then
normalised if non-zero. `LocalPlayer.modifyInput` then multiplies it by 0.98; by the item-use slow-down while using
an item; by the `sneaking_speed` attribute (default 0.3) while sneaking; and finally squares-off the vector
(`modifyInputSpeedForSquareMovement`: scale by min(1, length x distance-to-unit-square)). `LocalPlayer.applyInput`
copies the vector to the strafe/forward impulses and sets `jumping` = the jump flag.

### 1.2 Constants (attributes and entity values)

| Name | Value | Source |
|---|---|---|
| Gravity | 0.08 blocks/tick^2 (attribute `gravity`, range -1..1) | `Attributes` |
| Jump strength | 0.42 (attribute `jump_strength`, exactly 0.41999998688697815) | `Attributes` |
| Movement speed (player base) | 0.1 (0.10000000149011612) | `Player.createAttributes` |
| Sprint modifier | +0.3, multiplied (speed x 1.3) while sprinting | `LivingEntity` `SPEED_MODIFIER_SPRINTING` |
| Sneaking speed | 0.3 | `Attributes` |
| Step height | 0.6 | `Attributes` |
| Block friction (default) | 0.6; ice-type blocks override | `BlockBehaviour$Properties` |
| Block speed factor, jump factor (default) | 1.0, 1.0 | same |
| Air drag | horizontal 0.91, vertical 0.98 | `LivingEntity.travelInAir` |
| Abilities walking speed | 0.1 | `Abilities` |
| Abilities flying speed | 0.05 | `Abilities` |
| Sprint window (option `sprintWindow`) | 7 ticks, range 0..10 | `Options` |
| Jump delay (`noJumpDelay`) | 10 ticks | `LivingEntity.aiStep` |
| Flight toggle window (`jumpTriggerTime`) | 7 (see 1.4) | `LocalPlayer.aiStep` |

### 1.3 Per-tick order (`LocalPlayer.aiStep`, `LivingEntity.aiStep`, `LivingEntity.travel*`)

1. `Player.aiStep` (called at the end of `LocalPlayer.aiStep`) decrements `jumpTriggerTime` and, in
   `LivingEntity.aiStep`, `noJumpDelay` (each if above 0).
2. Velocity clean-up: for a player, if the horizontal speed squared is below 9.0E-6 then x and z are set to 0; if
   |y| < 0.003 then y is 0.
3. The input is applied (1.1). If `jumping`:
   - on ground (or in a fluid shallow enough, see below) and `noJumpDelay` = 0: `jumpFromGround`, then
     `noJumpDelay` = 10;
   - in water and the water is deeper than the fluid jump threshold (0.4 for a player whose eye height is not
     below 0.4) or the player is not on ground: add +0.04 to vertical velocity (`jumpInLiquid`);
   - in lava similarly (+0.04);
   - otherwise nothing. If `jumping` is false, `noJumpDelay` is reset to 0.
4. `travel` (below), which moves the player by the velocity.

**The jump rule (answers "no endless climb").** A jump starts only when the player is on the ground (or, for
liquids, in the cases in step 3) AND `noJumpDelay` is 0. Holding or re-pressing Space in the air does nothing in
survival: there is no air jump. After a jump `noJumpDelay` is 10; a normal jump lasts 12 ticks, so holding Space
re-jumps on the first tick the player is back on the ground. The server enforces nothing extra here; a
CobolCraft server may validate that vertical movement is consistent with this rule.

`jumpFromGround`: jump power = `jump_strength` x block jump factor + jump-boost effect power (0.1 x (amplifier+1)),
where the block jump factor is that of the block the player stands in, or the block below when the former is 1.0
(honey: 0.5). If the power is <= 1.0E-5 nothing happens. Otherwise vertical velocity = max(power, current vertical
velocity). When sprinting, horizontal velocity additionally gets +0.2 in the facing direction:
`(-sin(yaw) x 0.2, 0, cos(yaw) x 0.2)` with yaw in radians. Because the velocity is applied by `travel` in the
same tick, the player rises 0.42 on the first tick.

**Walking and falling (`travelInAir`)**, in order, with F = block friction of the block below (only when on
ground; otherwise F = 1.0):
1. Horizontal acceleration: input is rotated by yaw and added to velocity scaled by the "friction-influenced
   speed": on ground, `speed x 0.21600002 / F^3` (`speed` = 0.1, or 0.13 sprinting; with F = 0.6 this is exactly
   `speed`); in air, the flying speed (0.02 normally, 0.026 sprinting; while the Abilities `flying` flag is set,
   Abilities flying speed 0.05, doubled when sprinting).
2. Climbing (ladder/vine): x and z clamped to +-0.15, y floored at -0.15 (and 0 when sneaking on it).
3. The move is performed (`Entity.move`, collision resolution, step up to 0.6).
4. If horizontally blocked while climbing or jumping on a climbable the vertical velocity becomes 0.2.
5. Vertical velocity = vertical velocity - gravity (0.08). (Slow Falling caps gravity at 0.01 while descending;
   below the dimension minimum Y with no loaded chunk the value is -0.1 or 0 as a guard.)
6. Drag: x and z multiplied by F x 0.91; y multiplied by 0.98.

So the horizontal steady state on ordinary ground is 0.098/(1-0.546) = 0.2158 blocks/tick (4.32 blocks/s) walking
and 0.2806 (5.61 blocks/s) sprinting; in the air with the Abilities flag clear the horizontal acceleration is the
0.02 air value and the drag 0.91.

**Swimming and water (`travelInWater`).** Drag horizontal 0.8 (0.9 while sprinting; 0.96 with Dolphin's Grace),
vertical 0.8, acceleration 0.02. With the `water_movement_efficiency` attribute (default 0) above 0 the drag and
acceleration are interpolated toward 0.54600006 and the player's speed (halved when not on ground). After the move
the y velocity gets the fluid-falling adjustment (gravity/16 style: y - gravity/16, with a -0.003 floor when the
result is tiny) and a swim-up assist when pushing against a wall with a free block above. Sneaking in water adds
-0.04 vertical velocity per tick (`goDownInWater`); Space adds +0.04 (step 3). While swimming (the Swimming pose,
`Player.travel`) the y velocity is blended toward the look pitch: if the looking direction's Y is below -0.2 the
factor is 0.085, else 0.06; added to velocity `(0, (lookY - vy) x factor, 0)` only while looking up
and not holding Space, with fluid above the head position.

**Lava.** Drag 0.5 horizontally and vertically (`travelFlying` uses 0.5 in lava, 0.8 in water, 0.91 otherwise
for a flying entity).

### 1.4 Double-tap-Space flight toggle (`LocalPlayer.aiStep`)

The toggle exists only for players whose Abilities `mayfly` flag is set. That flag comes from the server's Player
Abilities packet (see 05a/09: creative and spectator set it; survival does not). A survival player therefore never
flies, whatever the keys do. The client sends the Abilities `flying` bit back with Player Abilities (05c 0x28,
bit 0x02) whenever it changes it (`onUpdateAbilities`).

Algorithm, each tick, evaluated with "jump pressed last tick" = the jump flag of the previous tick's Input
(read before `ClientInput.tick`), "jump pressed now" = the flag after, and not during an auto-jump:
- Spectator game mode: while `mayfly` is set and `flying` is false, `flying` is set to true immediately (no
  double-tap needed).
- Otherwise, on a rising edge of Space (not pressed last tick, pressed now):
  - if `jumpTriggerTime` is 0 it is set to 7 (first tap);
  - else (second tap inside the window), and the player is not swimming and not riding a vehicle that jumps:
    `flying` is toggled; if `flying` became true and the player is on the ground a normal `jumpFromGround` is
    performed; Player Abilities is sent; `jumpTriggerTime` is reset to 0.

`jumpTriggerTime` is decremented once per tick by `Player.aiStep`, after the check, so the window is: the second
rising edge must occur on one of the 6 ticks following the tick of the first rising edge (the value seen by the
check is 6, 5, ..., 1; on the 7th tick after, it is 0 and counts as a new first tap). Because a rising edge needs
the key to have been up on the previous tick, the effective second-tap ticks are the 2nd to the 6th after the
first (0.1 to 0.3 s).

When `flying` is true:
- On landing (`onGround`) with `flying` and not spectator, `flying` is cleared and Player Abilities sent (after
  `Player.aiStep` of that tick).
- Fall distance is reset each tick; swimming is cleared; fluids do not push (`Player.isAffectedByFluids` returns
  false while flying); stuck-in-block slow-down (cobweb, berry bush) is ignored; no step/fall sounds.
- Vertical control: Space adds, Shift subtracts, the vertical velocity by `Abilities.flyingSpeed x 3` per tick
  (0.15 with the default 0.05), applied before `travel`. Both keys cancel each other. This is not doubled by
  sprinting.
- `Player.travel` stores the vertical velocity, runs the normal travel (horizontal acceleration uses the flying
  speed 0.05, x2 when sprinting; drag 0.91; gravity is applied and then discarded), then sets the vertical
  velocity to the stored value x 0.6.

Steady state: vertical = 0.15/(1-0.6) = 0.375 blocks/tick (7.5 blocks/s); horizontal = 0.98 x 0.05/(1-0.91) =
0.544 blocks/tick (10.9 blocks/s), 21.8 blocks/s sprinting.

### 1.5 Sprint (`LocalPlayer.aiStep`, `canStartSprinting`, `isSprintingPossible`)

Definitions (all read from `LocalPlayer` and `Player`):
- **forward impulse**: the normalised move vector's forward component is above 1.0E-5 (so forward pressed and not
  cancelled by back).
- **sprint possible** (`isSprintingPossible(flying)`): the player does not have the Blindness effect
  (`isMobilityRestricted`); AND, if riding, the vehicle allows sprinting (`canSprint` and locally authoritative);
  AND `hasEnoughFoodToDoExhaustiveManoeuvres`: the food level is strictly greater than 6.0 (food 7 or more) OR the
  Abilities `mayfly` flag is set (creative and spectator can always sprint); AND (`flying` is true OR the player is
  not in shallow water, where "shallow water" = in water but with the head not under water).
- **slow due to using item**: an item is being used and its `use_effects` component does not allow sprinting
  (default effects do not allow it; for example eating or drawing a bow).
- **moving slowly**: crouching, or visually crawling (swim-crawl pose).

**Start** (each tick, after the inputs are read): sprinting begins when ALL of: not already sprinting; forward
impulse; sprint possible (with the current `flying` flag); not slow-due-to-using-item; if fall-flying then under
water; if moving slowly then under water. Then it begins either (a) because the sprint key is held, or (b) by the
double-tap of forward: when the forward impulse appears this tick but was absent before the input update, and
`sprintTriggerTime` is already > 0, sprinting starts; otherwise `sprintTriggerTime` is set to the option
`sprintWindow` (default 7 ticks). `sprintTriggerTime` is decremented once per tick at the start of `aiStep`, and is
reset to 0 when any of these holds (all read from the bytecode): the sneak flag was held (`aiStep` stores
`input.shift()` in a local before `ClientInput.tick` runs, and the reset uses that stored, pre-tick value), an item
is being used while not riding, or backward is pressed (this one uses the post-tick input). The "forward impulse
appeared this tick" test of the double-tap uses the `hasForwardImpulse` value likewise stored before `ClientInput.tick`:
the double-tap fires when that stored value was false and the current one is true.

**Stop**, evaluated after the start check, while sprinting:
- on foot (not swimming): stop if sprint is no longer possible (blindness, food <= 6 without `mayfly`, in shallow
  water without flying, vehicle cannot sprint), or there is no forward impulse, or the player has a horizontal
  collision that is not a minor one (`minorHorizontalCollision`, a collision that auto-jump or a half-block step
  can resolve);
- while swimming: stop if sprint is no longer possible (computed as with `flying` = true, so the shallow-water rule
  is skipped), or the player is not in water, or (no forward impulse AND not on the ground AND not holding sneak).
Taking damage or stopping hunger is handled by the server through food and by these checks; the client also reports
changes with Player Command `START_SPRINTING` / `STOP_SPRINTING` (05c 0x2A) via `sendIsSprintingIfNeeded`.
The `toggleSprint` option makes the sprint key a toggle (the `ToggleKeyMapping`), and the Input record's `sprint`
flag is the mapping's held state.

---

## 2. Block-break progress

### 2.1 Destroy speed (`Player.getDestroySpeed`) and progress per tick (`BlockBehaviour$BlockState.getDestroyProgress`)

Inputs: block hardness H (the state's `destroyTime`; -1 means unbreakable), the held item, the player's effects,
attributes and position.

1. Tool speed S0 = the first matching rule of the held item's `tool` component that carries a speed, else the
   component's default speed (1.0 for all vanilla tools), else 1.0 for an item with no tool component
   (`ItemStack.getDestroySpeed` -> `Tool.getMiningSpeed`: the rule list is searched in order and the first
   matching rule with a speed wins).
2. If S0 > 1 then S1 = S0 + `mining_efficiency` attribute (default 0). Efficiency enchantment adds
   level^2 + 1 to the attribute (`data/minecraft/enchantment/efficiency.json`: `levels_squared`, added 1.0, op
   `add_value`, max level 5). If S0 <= 1 the attribute is not added.
3. Haste (or Conduit Power, the larger amplifier): S2 = S1 x (1 + (amp + 1) x 0.2).
4. Mining Fatigue: S3 = S2 x 0.3^(amp+1) (float). Both haste and fatigue may apply.
5. S4 = S3 x `block_break_speed` attribute (default 1.0).
6. If the eyes are in water: S5 = S4 x `submerged_mining_speed` (default 0.2; Aqua Affinity is an enchantment
   attribute modifier on it).
7. If the player is not on the ground: S6 = S5 / 5.
8. Progress per tick = S6 / H / D, with D = 30 if the player "has the correct tool for drops" and 100 otherwise.
   If H = -1, progress per tick is 0 (never breaks).

Correct tool for drops (`Player.hasCorrectToolForDrops`): true if the block does not require a correct tool, or the
held item's tool component says so. A tool says so (`Tool.isCorrectForDrops`) when the first rule that carries a
`correct_for_drops` value and matches the block has it true. A tool material's rules are, in order: (1) the blocks
in the material's "incorrect blocks for drops" tag deny drops; (2) the blocks in the tool kind's `mineable/*` tag
mine with the material speed and allow drops. A sword has rules cobweb 15.0, a "sword instantly mines" tag at
speed 3.4028235E38 (instant), a "sword efficient" tag 1.5. Whether a block "requires a correct tool" is a block
property in the block registry; the pack's `mineable` tags are in `data/minecraft/tags/block/mineable/`.

Tool material speeds (`ToolMaterial`): wood 2.0, stone 4.0, copper 5.0, iron 6.0, diamond 8.0, netherite 9.0,
gold 12.0. Tool tier tags are listed in 2.6. Durability: wood 59, stone 131, copper 190, iron 250,
diamond 1561, gold 32, netherite 2031. A tool item has `canDestroyBlocksInCreative` true except swords: a sword
cannot break blocks in creative (`Item.canDestroyBlock`).

Break time in ticks (survival, no effects, standing): the smallest n with n x (progress per tick) >= 1.0,
i.e. ceil(1 / progress). Example in section 9.

### 2.2 Client state machine (`MultiPlayerGameMode`, `Minecraft.startAttack/continueAttack`)

State: `isDestroying`, `destroyBlockPos`, `destroyDirection`, `destroyingItem` (copy of the held stack),
`destroyProgress` (0..1), `destroyTicks`, `destroyDelay` (continuous-break cooldown), plus
`Minecraft.missTime`.

- **Pressing the attack key** calls `startAttack`: ignored while `missTime` > 0. A miss (nothing hit) in a mode
  where a miss cooldown applies (not creative) sets `missTime` = 10. Looking at a non-air block calls
  `startDestroyBlock(pos, face)`.
- **`startDestroyBlock`**: refused when the action is restricted (adventure/spectator rules, `blockActionRestricted`)
  or the position is outside the world border.
  - Creative (`Abilities.instabuild`): sends Player Action `START_DESTROY_BLOCK` with a fresh sequence id,
    breaks the block locally at once (prediction), and sets `destroyDelay` = 5. Nothing else.
  - Survival: if already destroying and the target is not the same position with the same item (compared by
    item and components), first sends `ABORT_DESTROY_BLOCK` for the old position. If not already destroying the same
    target, then (inside the prediction wrapper, with a fresh sequence id): if the block is not air and
    `destroyProgress` = 0, the block's `attack` hook runs; if the per-tick progress is >= 1.0 the block is
    broken locally at once (instant break); then `isDestroying` = true, target and face and item recorded,
    `destroyProgress` = 0, `destroyTicks` = 0, the client's own break stage is set on the level
    (`destroyBlockProgress(playerId, pos, stage)` with stage per 2.4), break particles/sound start, and Player Action
    `START_DESTROY_BLOCK` is sent.
- **Holding** calls `continueAttack(true)` every tick; while the key is down and the hit is a non-air block it
  calls `continueDestroyBlock(pos, face)`, which returns true if the player should swing the arm. When the call
  returns true the client swings and also sends the Punch packet (05c 0x2E, no fields). Releasing the key, or
  looking at air or another block, calls `stopDestroyBlock`.
- **`continueDestroyBlock`**:
  1. If `destroyDelay` > 0: decrement it and return true (no progress while cooling down).
  2. Creative: `destroyDelay` = 5, break at once with a new `START_DESTROY_BLOCK` (so holding the button in
     creative breaks one block every 6 ticks while the aim stays inside the world border).
  3. Survival, same target (same position and same item): if the block became air, `isDestroying` = false and
     return false. Otherwise `destroyProgress` += per-tick progress (2.1), `destroyTicks` += 1. If
     `destroyProgress` >= 1.0: `isDestroying` = false, break the block locally and send `STOP_DESTROY_BLOCK` (new
     sequence id), then `destroyDirection` = none, `destroyProgress` = 0, `destroyTicks` = 0, `destroyDelay` = 5.
     If the face changed since the start, send `CHANGE_DESTROY_DIRECTION` with the new face. In all cases the
     level's own break stage is updated (`destroyBlockProgress(playerId, pos, getDestroyStage())`).
  4. Survival, different target: act as `startDestroyBlock`.
- **`stopDestroyBlock`** (key released, aim moved, or the item changed): if destroying, send `ABORT_DESTROY_BLOCK`
  for the position with face DOWN, clear `isDestroying`, set `destroyProgress` = 0, clear the level's own break
  stage (stage -1), and reset the attack-strength ticker.

**Continuous-break cooldown**: after each completed break the next break (or the first progress) cannot start for
5 ticks (`destroyDelay` = 5, `DEFAULT_DESTROY_COOLDOWN_TICKS`); in creative it is also 5 between repeated breaks.

### 2.3 Sequence ids and acknowledgement

Each predicted action (start, stop, the creative break) is wrapped by `startPrediction`: the client's
`BlockStatePredictionHandler` increments the sequence number, the action runs (local block changes are recorded as
predictions), and the packet carries that number. `ABORT_DESTROY_BLOCK` and `CHANGE_DESTROY_DIRECTION` carry the
sequence too (0 when sent outside a prediction). The server (`ServerGamePacketListenerImpl.handlePlayerAction`)
calls `ackBlockChangesUpTo(sequence)` after handling a break action, which sends Block Changed Ack (05a) with the
highest sequence processed; until then the client keeps its predicted states and the server's Block Update packets
for those positions overrule them. The sequence rules in 05c apply as written.

### 2.4 Destroy stage (0 to 9) and what other players see

The stage is `floor(progress x 10)` when progress > 0 and -1 (no overlay) otherwise
(`MultiPlayerGameMode.getDestroyStage`; same formula on the server). The 10 crack textures are indexed 0 to 9.
The server (`ServerPlayerGameMode`) computes it itself and broadcasts Block Destruction (05a 0x05: entity id of the
breaker, position, stage; stage outside 0..9 clears) to nearby players. Other players' overlays are keyed by the
breaker's entity id; a new break by the same entity replaces the old overlay, and stage -1 (or a value outside
0..9) removes it.

Server side, for reference: on `START_DESTROY_BLOCK` (survival) it checks the position is within the player's block
interaction range (+1.0), below the world's max Y, not under spawn protection, `mayInteract`, and not restricted.
It starts timing with `gameTicks`, applies the block's attack hook, and if the per-tick progress is >= 1.0 breaks
at once (and acks). Otherwise it broadcasts the stage `floor(progress x 10)`. Every server tick while destroying
it recomputes progress = per-tick progress x (ticks since start + 1), re-broadcasts the stage when it changes, and
sends a block hit sound/event every 4 ticks. On `STOP_DESTROY_BLOCK` it accepts the break when
progress >= 0.7 (a deliberate tolerance, 70% of the break time); if it is less, the block is kept and the break
is re-checked on later ticks ("delayed destroy"). On `ABORT_DESTROY_BLOCK` it clears the stage (-1). A rejected
break results in a Block Update of the true state.

### 2.5 Creative instant break

In creative the client breaks on the START action alone and does not run the progress model. The server breaks
immediately on `START_DESTROY_BLOCK` when the player has `instabuild`, with a Block Changed Ack (and the survival
drop rules are skipped: `Player.preventsBlockDrops`). Creative also leaves a sword unable to break blocks (2.1).

### 2.6 Block hardness and tool requirements (blocks CobolCraft's survival player meets)

Read from the block initialiser (`Blocks`, `strength(hardness, blastResistance)`; `requiresCorrectToolForDrops`) and
the tag files under `data/minecraft/tags/block/` in the jar. "Req" = the block sets `requiresCorrectToolForDrops`
(then the correct-tool divisor is 30 only with a tool that is correct for drops, else 100, and no drops are given
without it). The tool column is the `mineable/*` tag (the tool kind whose rule gives the block its tool speed); the
tier is the `needs_*_tool` tag (a wooden tool is wrong for `needs_stone_tool` and above, stone for iron and above,
iron for diamond, gold behaves like wood). "direct" = value read from that block's own properties; "copy" = the
block is declared as a copy of another block's properties with only the strength overridden (so the Req flag is
inherited from the original: inferred from the copy semantics, not separately read).

| Block id | Hardness | Req | Tool (mineable tag) | Tier tag | Read |
|---|---|---|---|---|---|
| `stone` | 1.5 | yes | pickaxe | none | direct |
| `cobblestone` | 2.0 | yes | pickaxe | none | direct |
| `deepslate` | 3.0 | yes | pickaxe | none | direct |
| `cobbled_deepslate` | 3.5 | yes (inferred, copy of deepslate) | pickaxe | none | copy |
| `tuff` | 1.5 | yes | pickaxe | none | direct |
| `sandstone` | 0.8 | yes | pickaxe | none | direct |
| `dirt` | 0.5 | no | shovel | none | direct |
| `grass_block` | 0.6 | no | shovel | none | direct |
| `sand` | 0.5 | no | shovel | none | direct |
| `gravel` | 0.6 | no | shovel | none | direct |
| `clay` | 0.6 | no | shovel | none | direct |
| `snow_block` | 0.2 | yes | shovel | none | direct |
| `oak_log` and every `*_log` made by the log helper (`logProperties`) | 2.0 | no | axe (tag `#logs`) | none | direct (helper) |
| `oak_planks` (and the other plank kinds) | 2.0 | no | axe (tag `#planks`) | none | direct |
| `crafting_table` | 2.5 | no | axe | none | direct |
| `furnace` | 3.5 | yes | pickaxe | none | direct |
| `coal_ore` | 3.0 | yes | pickaxe | none | direct |
| `iron_ore` | 3.0 | yes | pickaxe | stone | direct |
| `copper_ore` | 3.0 (blast resistance 3.0) | yes | pickaxe | stone | copy of `iron_ore` (`ofLegacyCopy`), so it takes iron ore's strength and Req flag |
| `gold_ore` | 3.0 | yes | pickaxe | iron | direct |
| `diamond_ore` | 3.0 | yes | pickaxe | iron | direct |
| `redstone_ore` | 3.0 | yes | pickaxe | iron | direct |
| `lapis_ore` | 3.0 | yes | pickaxe | stone | direct |
| `emerald_ore` | 3.0 | yes | pickaxe | iron | direct |
| `deepslate_coal_ore`, `deepslate_iron_ore`, `deepslate_gold_ore`, `deepslate_diamond_ore`, `deepslate_copper_ore` (and the other deepslate ores) | 4.5 | yes (inferred, copy of the stone-variant ore) | pickaxe | same tier tag as the stone-variant ore | copy |
| `obsidian` | 50.0 | yes | pickaxe | diamond | direct |
| `bedrock` | -1 (unbreakable; blast resistance 3600000) | n/a | none | none | direct |
| `glass` | 0.3 | no | in no `mineable` tag (hand speed with every tool) | none | direct |
| `oak_leaves` and every leaves kind (`leavesProperties`) | 0.2 | no | hoe (tag `#leaves`) | none | direct (helper) |

Tool-kind speeds are the material speeds in 2.1 (a tool of the right kind gets the material speed on any block in
its `mineable` tag, and the base 1.0 elsewhere; a pickaxe on dirt is speed 1.0). The `incorrect_for_*_tool` tags (the "denies drops" list of each material, all read): wooden = needs_stone + needs_iron
+ needs_diamond; gold = the same three as wooden; stone = needs_iron + needs_diamond; copper = needs_iron +
needs_diamond; iron = needs_diamond; diamond and netherite = empty. The tier lists in the jar include many more blocks than the table
(copper variants, raw blocks, netherite and so on).

---

## 3. Crafting

### 3.1 Recipe data in the artifact

Recipes are JSON files under `data/minecraft/recipe/` in the jar: 2042 files, of which 1763 are directly in that
folder and 279 (all of type `brewing`) are in the subfolder `data/minecraft/recipe/brewing/`. Counts by `type`:
`brewing` 279 (subfolder `brewing/`), `crafting_shaped` 827, `crafting_shapeless` 375, `stonecutting` 351, `smelting` 73, `crafting_transmute` 33,
`blasting` 25, `smithing_trim` 18, `smithing_transform` 12, `smoking` 9, `campfire_cooking` 9, `crafting_dye` 6, `crafting_decorated_pot` 1, and
single `crafting_special_*` types (banner duplicate (16), shield decoration, repair item, map extending, firework
star/fade/rocket, book cloning) and `crafting_imbue`. Only the crafting types (`crafting_*`) matter for the
inventory 2x2 and the crafting table 3x3; stonecutting, smelting-family, smithing and brewing recipes belong to other
menus and are out of scope here.

`crafting_shaped` fields: `pattern` (array of 1 to 3 strings, each 1 to 3 characters, all the same length; a space
means an empty cell), `key` (map from a single non-space character to an ingredient), `result`
(`{id, count?}`; count defaults to 1; may carry components), optional `group` (string, recipes with the same group
share one recipe-book entry cell), `category` (`building`, `redstone`, `equipment`, `misc`; absent means `misc`
(inferred)), `show_notification` (boolean, default true; false for example in `crafting_table.json`). An
ingredient is an item id, a `#tag` reference, or an array of those (any of). Every key character must be used in the
pattern and every pattern character must be a key (an error otherwise).
`crafting_shapeless` fields: `ingredients` (array of ingredients), `result`, `group`, `category`.

Examples read from the jar:
- `crafting_table`: key `#` = tag `#minecraft:planks`, pattern `["##","##"]`, result 1 `crafting_table`,
  `show_notification` false.
- `stick`: key `#` = `#minecraft:planks`, pattern `["#","#"]`, result 4 `stick`, group `sticks`.
- `oak_planks`: shapeless, ingredients `["#minecraft:oak_logs"]`, result 4 `oak_planks`, category `building`,
  group `planks`.
- `wooden_pickaxe`: key `#` = `stick`, `X` = `#minecraft:wooden_tool_materials`, pattern
  `["XXX"," # "," # "]` (rows are equal length, spaces are empty cells), category `equipment`.

### 3.2 Shaped matching (`ShapedRecipePattern`, `CraftingInput`)

On load the pattern is trimmed (`shrink`): leading/trailing empty rows and columns are removed, so the stored
`width` x `height` is the bounding box of the non-empty cells; `ingredientCount` = the number of non-empty cells.
Matching a grid (`CraftingInput.ofPositioned`):
1. The grid contents are first trimmed the same way (empty outer rows and columns removed; the removed offset is
   remembered as `left`/`top`). An empty grid is "no recipe".
2. The recipe matches iff the non-empty-slot count equals `ingredientCount`, the trimmed width and height equal
   the recipe's, and every cell satisfies its ingredient (an empty pattern cell requires an empty slot).
3. If the pattern is not left-right symmetric, the grid is tested once as-is and once mirrored horizontally
   (column index c replaced by width-1-c); either match counts. Vertical mirroring is not allowed.
4. Item tests are item-identity plus the ingredient's tag membership; the item stack's count is irrelevant (1 is
   enough).

Placement is therefore free inside the grid: a 2x2 pattern can sit in any 2x2 window of a 3x3 grid. A recipe whose
trimmed size exceeds the grid (wider or taller than the 2x2 inventory grid) cannot be matched there.

### 3.3 Shapeless matching (`ShapelessRecipe.matches`)

The count of non-empty slots must equal the number of ingredients. One ingredient and one slot: a direct test.
Otherwise a bipartite matching is solved (`StackedItemContents.canCraft`): every ingredient must be given a distinct
slot's item, where an ingredient may accept several item kinds. Positions are irrelevant.

### 3.4 Which recipe is shown

After any change in the crafting slots the server finds the first recipe of type crafting that matches
(`RecipeManager.getRecipeFor`, using a one-entry cache) and puts its assembled result into slot 0. The recipe must be
enabled for the player (limited crafting makes unlocked-only recipes; vanilla `doLimitedCrafting` off by default).
No match: slot 0 becomes empty. The server sends Container Set Slot for slot 0. The client does not compute the
result itself.

### 3.5 Menus and slot indexes

**Inventory menu** (container id 0, `InventoryMenu`, no Open Screen packet; opened by the inventory key). Grid 2x2.

| Index | Slot | Position (x, y) in the 176x166 screen |
|---|---|---|
| 0 | crafting result | (154, 28) |
| 1 to 4 | crafting grid, row-major (1 = top left, 2 = top right, 3 = bottom left, 4 = bottom right) | x = 98 + 18 x col, y = 18 + 18 x row |
| 5 | helmet | (8, 8) |
| 6 | chestplate | (8, 26) |
| 7 | leggings | (8, 44) |
| 8 | boots | (8, 62) |
| 9 to 35 | main inventory, row-major (inventory index = menu index) | x = 8 + 18 x col, y = 84 + 18 x row |
| 36 to 44 | hotbar 0 to 8 (inventory index = menu index - 36) | x = 8 + 18 x i, y = 142 |
| 45 | off-hand (inventory index 40) | (77, 62) |

46 slots. The off-hand slot accepts only items that can be equipped in the off-hand slot (shield etc.; 4.x). `isHotbarSlot(i)` is
true for 36 to 44 and 45.

**Crafting-table menu** (`CraftingMenu`, `MenuType` `crafting`, registry id 12 in the menu type registry order
generic_9x1=0 ... crafting=12). 46 slots:

| Index | Slot | Position |
|---|---|---|
| 0 | result | (124, 35) |
| 1 to 9 | grid 3x3, row-major (1 = top left, 3 = top right, 4 = middle left, ..., 9 = bottom right) | x = 30 + 18 x col, y = 17 + 18 x row |
| 10 to 36 | main inventory (inventory 9..35) | x = 8 + 18 x col, y = 84 + 18 x row |
| 37 to 45 | hotbar | x = 8 + 18 x i, y = 142 |

(Slots are numbered in this order; there is no armor or off-hand slot in this menu.)

**Opening.** Using a crafting-table block without sneaking-with-item (`CraftingTableBlock.useWithoutItem`) calls
`openMenu` with a menu provider titled the translatable component `container.crafting` ("Crafting"). The server
sends Open Screen (05a) with a new container id (1 to 100 cycling), menu type `crafting` and that title, followed
by Container Set Content. The server counts the interaction stat `interact_with_crafting_table`. The menu stays
valid while the block is still a crafting table and the player is within 8 blocks (squared distance <= 64,
(inferred) `AbstractContainerMenu.stillValid`). On close (`removed`) the grid contents are returned to the
player's inventory (or dropped). Closing the inventory menu also returns its 2x2 grid items the same way.

### 3.6 Result slot (`ResultSlot`)

- Nothing may be placed into it (`mayPlace` false).
- Taking (cursor pick-up of the whole stack, or shift-click): `onTake` consumes one item from each non-empty grid
  slot covered by the matched trimmed region (using the recipe's remaining-items list: a slot whose item leaves a
  remainder, such as a bucket, receives the remainder: an empty slot gets it, an identical stack grows, otherwise the
  remainder goes to the inventory or is dropped). Then the grid changes and the result is recomputed.
- A pick-up with a non-empty cursor of a different item is refused; with the same item (`isSameItemSameComponents`)
  the cursor grows by the result count if it fits within the stack limit (inferred from `AbstractContainerMenu.doClick`).
- Statistics and the recipe-unlock award run via `checkTakeAchievements` (counts crafted items; awards the used
  recipes).

### 3.7 Quick move (shift-click) rules (`quickMoveStack`)

`moveItemStackTo(stack, from, to, reverse)`: pass 1, if the stack is stackable, merge into existing equal stacks in
the range up to each slot's max stack size (iterating from `to-1` down when `reverse`, else from `from` up); pass 2,
place the remainder into the first empty slot in the range that accepts it (`mayPlace`), moving at most the slot's
max stack size. Returns true if anything moved. Shift-click on a slot (Container Click `QUICK_MOVE`) repeats
`quickMoveStack` while the slot still holds the same item kind as the moved stack (so shift-clicking the result
repeats the craft until the grid no longer matches, until the destination is full, or the result changes).

Inventory menu (indexes in the table above):

| Clicked slot | Destination, in order |
|---|---|
| 0 result | 9..44 (reverse = true, prefers hotbar end); then `onQuickCraft`. Any leftover is dropped |
| 1 to 4 grid | 9..44 forward |
| 5 to 8 armor | 9..44 forward |
| 9 to 35 main, an armor item whose armor slot is empty | that armor slot (index 8 - slot index of the equipment: helmet 5 ... boots 8) |
| 9 to 35 main, an off-hand-equippable item and slot 45 empty | 45 |
| 9 to 35 main, otherwise | 36..44 (hotbar) |
| 36 to 44 hotbar, an armor item with empty armor slot, or off-hand item and empty slot 45 | as above |
| 36 to 44 hotbar, otherwise | 9..35 (main) |
| 45 off-hand | 9..44 |

If nothing could be moved the click returns "empty" (nothing changes). If the source is empty afterwards the slot is
cleared; otherwise it is marked changed; the call returns the original stack only if the count changed.

Crafting-table menu:

| Clicked slot | Destination, in order |
|---|---|
| 0 result | 10..45 reverse = true; then `onQuickCraft`. Leftover dropped |
| 10 to 45 (inventory) | first the grid 1..9; if that fails, a main slot (10..36) goes to the hotbar 37..45 and a hotbar slot (37..45) goes to main 10..36 |
| 1 to 9 grid | 10..45 forward |

### 3.8 The crafting grid after clicks and the server's placement ("fill the grid")

**Place Recipe** (05c 0x27: container id, display id, use-max flag; the client sets "use max" when Shift is held
during the click) is handled by `ServerPlaceRecipe`:
1. The container id must match the open menu; the recipe is looked up by display id; it must be in the player's
   recipe book and be a crafting recipe for a grid at least as large as the recipe.
2. Unless the grid already holds the same recipe's items, the server first tests that the grid contents fit back into the
   inventory (`testClearGrid`); if not, nothing happens.
3. It builds an item count of the player's inventory plus the grid; if the recipe is craftable from that, the grid is
   cleared into the inventory (`clearGrid`; leftover goes to free slots), and the ingredients are moved into the
   grid, otherwise the grid is cleared and Place Ghost Recipe (05a 0x40, container id + RecipeDisplay) is sent so the
   client shows a ghost.
4. How many sets are placed: with use-max = true the biggest craftable multiple, limited by the smallest ingredient
   max stack size; otherwise 1, except when the grid already contains this recipe's items, in which case one more set is
   added up to (smallest count in the grid + 1) bounded by max stack size.
5. Placement geometry (`PlaceRecipeHelper.placeRecipe`): for a shaped recipe of size rw x rh in a grid gw x gh,
   the recipe is placed top-left aligned when rw >= gw/2 (compared as floats); when rw < gw/2 it is centered with
   offset floor(gw/2 - rw/2) columns; likewise rows with rh and gh. In a 3x3 grid a 1-wide recipe is therefore
   centered (offset 1), a 2-wide recipe sits at the left (offset 0), and in a 2x2 grid everything sits at the
   top left. A shapeless recipe fills the grid slots in order from the first slot, one ingredient each. Each
   ingredient is taken from the inventory slot found by `findSlotMatchingCraftingIngredient` (item-matching with
   the ingredient; slots whose stack is damaged/enchanted are skipped in favour of plain ones, inferred).
   Mirroring is not used by the server; only the original orientation is placed.
6. The result is then computed as for 3.4. The server does not send Container Set Slot for every moved item
   individually beyond the normal menu synchronisation (Container Set Content / slot packets for changed slots).

### 3.9 The recipe book

**Data flow.**
- Server -> client: Update Recipes (05b 0x88) carries recipe-property sets and stonecutter entries (not the crafting
  recipes). Recipe Book Add (0x4B) carries `RecipeDisplayEntry` items (display id, display, group, category,
  optional crafting requirements) with per-entry flags: bit "notification" (a toast, `RecipeToast`, is shown) and bit
  "highlight" (the entry is marked new until viewed); Replace=true first clears the known list. Recipe Book Remove (0x4C) deletes
  entries (and their highlights). Recipe Book Settings (0x4D) carries four (open, filtering) pairs, one per book type
  (crafting, furnace, blast furnace, smoker); they replace the client's settings. After each of these the client calls
  `refreshRecipeBook` (rebuild collections; update the open screen's `recipesUpdated`; rebuild the search tree).
- Client -> server: Recipe Book Change Settings (0x2F) whenever the player opens/closes the book or toggles the
  filter (carries the book type, open, filtering); Recipe Book Seen Recipe (0x30: display id) when a highlighted
  entry is viewed (the highlight is removed locally at the same time: `removeRecipeHighlight`); Place Recipe
  (0x27) on a click.
- Unlocking is purely server-side: the server decides which recipes to add and when (for example on first
  obtaining an ingredient, on joining, on crafting); the client shows whatever it has been given.

**What the client holds** (`ClientRecipeBook`): a map from display id to entry (`known`), a highlight set, the settings.
`rebuildCollections` groups the known entries: for each recipe-book category (building blocks, redstone,
equipment, misc for crafting) entries with the same non-empty `group` number form one `RecipeCollection`; an entry
without a group is a collection of one. The "Search" pseudo-category contains all four crafting categories.

**Craftability** is evaluated on the client: `RecipeDisplayEntry.canCraft(stackedContents)` is true iff the entry
has crafting requirements (a list of ingredient alternatives, 05b) and the "stacked contents" (all counts of the
player's inventory plus the items in the menu's grid slots) can satisfy them (each requirement gets a distinct unit).
Entries without requirements are never craftable. The set of craftable ids is recomputed whenever the player's
inventory changes (`Inventory.getTimesChanged` differs from the last seen count, checked every tick while the book is
visible) or a crafting slot is clicked.

**Layout** (`RecipeBookComponent`): a 147 x 166 panel (texture 256 x 256), beside the main GUI (offset 86 to the
left of a 176-wide screen when the window is wide enough (the screen widens to 177 + 200 or less), over it
otherwise: `widthTooNarrow`). Search box at panel (25, 13), 81 x 14, hint "Search...", max 50 characters, white
text. A filter toggle button at (110, 12), 26 x 16: tooltips "Showing Craftable" (filter on) / "Showing All" (off),
sprites `recipe_book/filter_enabled(_highlighted)` and `filter_disabled(_highlighted)`. Vertical tab buttons
27 px apart to the left of the panel starting at y = (screen height - 166)/2 + 3, x = (screen width - 147)/2 -
offset - 30. Tabs in order: Search (magnifier), Equipment (icons iron axe + golden sword), Building Blocks (bricks),
Misc (lava bucket + apple), Redstone (redstone). A tab is hidden while it has no recipes (visibility is checked
with `RecipeBookTabButton.updateVisibility`); the first visible tab is selected by default (the Search tab). A
tab with a newly highlighted recipe plays a short wiggle animation.

**Book button.** An `ImageButton` of 20 x 18 pixels with the book sprites, positioned relative to the main screen's
left edge `leftPos`: in the inventory screen at (leftPos + 104, screen height / 2 - 22) (that is, right of the crafting
arrow), in the crafting-table screen at (leftPos + 5, screen height / 2 - 49). Clicking it toggles the panel and
re-positions both the panel and the button (`updateScreenPosition` moves the main GUI right by 86 px when the window
is wide enough: threshold: window width at least 379 (read as the constant used in `init`), otherwise the panel
overlays the screen). (Overlay details beyond the constants 25, 4/5 rows and 0.375 are inferred.)

**Variant overlay (`OverlayRecipeComponent`).** Opened by clicking (or right-clicking) a collection with more than one
displayable recipe: a rounded panel anchored to the clicked button. Each recipe is a 25 x 25 button (item rendered at
0.375 scale for the ingredients of crafting recipes: the shaped pattern is drawn as a small grid inside the button)
laid out in columns with at most 4 rows (5 rows for the larger variant set), the craftable ones normally and the
others with the uncraftable slot sprite; clicking a button places that recipe; clicking outside closes it.

The page grid shows 20 collections per page (`ITEMS_PER_PAGE`; 5 columns x 4 rows of 25 px cells at panel
(11, 31)), previous/next page arrows (12 x 17 sprites) at (38, 137) and (93, 137), and a "page/total" label
("%s/%s"). Each collection button shows its first displayable recipe's result item; a collection with several
recipes cycles which one it shows (every 30 ticks, `TICKS_TO_SWAP_SLOT`); a recipe that is craftable shows
normally, a non-craftable one is drawn with a red slot background/darkened sprite; a recipe with a pending
highlight shows a small "new" marker; hovering shows a tooltip and, for several recipes, "Right Click for More".

**Which collections are listed** (`updateCollections(resetPage, filtering)`):
1. Start from the collections of the selected tab; remove collections that have no recipe able to be displayed in
   this grid size: a shaped display must fit (`width <= gridWidth` and `height <= gridHeight`), a shapeless
   display must have at most gridWidth x gridHeight ingredients (`CraftingRecipeBookComponent.canDisplay`; in the
   2x2 inventory grid, 3-wide recipes are not shown).
2. If the search box is non-empty: the text is lower-cased (root locale) and looked up in the session search tree
   (`SessionSearchTrees.recipes`, built in the background whenever recipes change). The tree is a `FullTextSearchTree`
   over the collections: for every collection, for every recipe's result item stack(s), the item's tooltip lines
   (the normal item name plus any tooltip text, with the normal (not advanced) tooltip flag) are taken as strings,
   formatting codes stripped (`ChatFormatting.stripFormatting`), trimmed, empty ones dropped, and indexed in a
   suffix array for case-insensitive substring matching (a query matches a collection when it is a substring of any
   of those lines; lower-casing of the indexed text is inferred). A query containing a colon is instead split at the
   first colon into a namespace part and a path part (each trimmed) and matched against the registry ids of the
   result items: the namespace part by substring over the namespace, the path part by substring over the path, and a
   collection must satisfy both (intersection). A query without a colon is matched against the tooltip text and also
   merged (unique union) with id path matches. Results keep the collections' original order (the order the
   collections were first added, via an index comparator), so there is no relevance ranking.
3. If filtering is on (the filter button shows "Showing Craftable"), remove collections with no craftable recipe.
4. The page list is rebuilt; the page is reset to the first when requested (tab or search change).
The search string is re-checked each tick (`checkSearchStringUpdate`); a change re-runs the filter.

**Interaction.**
- Left-click a collection with one recipe: `tryPlaceRecipe` (not sent when the recipe is not craftable and was the
  last one placed): clears the ghost, sends Place Recipe with the container id of the open menu, the display id, and
  use-max = Shift held. Then, if the book is narrow, it hides.
- Click a collection with several recipes: opens an overlay (`OverlayRecipeComponent`) listing the variants; clicking
  a variant places it. Right-click on a multi-recipe collection opens the overlay as well.
- Shift-click requests the maximum craft (use-max).
- Clicking a recipe whose button is not craftable still places it: the server answers with Place Ghost Recipe when
  it cannot fill the grid.
- Any click on a crafting slot (`slotClicked`) clears the ghost and the "last placed" memory.

**Ghost recipe (`GhostSlots`).** On Place Ghost Recipe (05a 0x40) whose container id equals the open menu, the screen
shows the recipe as faint items in the grid slots (the `RecipeDisplay` slot displays; the result slot shows
the result display). A shaped display is positioned with the same geometry as 3.8 (centered when smaller than half
the grid); a shapeless one fills slots from the first. For slots with multiple possible items the ghost cycles
through the alternatives every 30 ticks. It is cleared when a crafting slot is clicked or the book component
requests (`clear`).

**Open/closed state.** The button on the inventory/crafting screen (a book icon next to the grid) toggles the
panel (`toggleVisibility`); the state is held in the book settings for the book type and sent via Change
Settings; `tick` re-synchronises the screen with the settings (a Recipe Book Settings packet can open/close it).
The panel's visibility is only for book types the server and menu declare (crafting for both menus here).

---

## 4. Off-hand

- The off-hand item is stored in player inventory index 40; in the inventory menu it is slot 45 (3.5). The main hand
  is the selected hotbar slot (inventory index = selected slot 0..8).
- **Swap key** (default F; key mapping `key.swapOffhand`, code 9): `Minecraft.handleKeybinds`, once per consumed
  click and when the player is not a spectator, sends Player Action (05c 0x29) with action `SWAP_ITEM_WITH_OFFHAND`
  (ordinal 7), block position (0, 0, 0), face DOWN and sequence 0. No local prediction; the server answers with the
  new contents of both hands (Container Set Slot or equipment updates). The server (`handlePlayerAction`) swaps the
  main-hand and off-hand stacks (not for a spectator), then stops any item use.
- **In the inventory screen** (`AbstractContainerScreen.checkHotbarMouseClicked`, also from key press): with a
  hovered slot and an EMPTY cursor, pressing the swap key (or a mouse button bound to it) sends a Container Click
  (05c 0x12) of type `SWAP` (id 2) on the hovered slot with button 40 (button 40 is "swap with the off-hand"; buttons
  0 to 8 swap with hotbar slots, via the hotbar keys `key.hotbar.1..9`). Nothing happens with a non-empty cursor.

---

## 5. F3 debug overlay

### 5.1 Keys

The key codes are numeric values of the new key-code space in which `KEY_A` = 4, `KEY_E` = 8, `KEY_W` = 26,
`KEY_F3` = 60 (USB-HID-like codes: A..Z are 4..29, 1..9 are 30..38, space 44, F1..F12 are 58..69, left ctrl 224,
left shift 225). Key mapping names are `key.keyboard.<name>` (`InputConstants`; `key.mouse.left` etc. for buttons).

`key.debug.modifier` and `key.debug.overlay` are both bound to F3 by default. `KeyboardHandler.keyPress`:
- Holding F3 and pressing another key runs the debug combination (below), if one is bound to it, sets
  `usedDebugKeyAsModifier`, and swallows the key.
- Releasing F3 toggles the overlay (`DebugScreenEntryList.toggleDebugOverlay`) unless a combination was used while it
  was held.
- Holding F3+C for 10 seconds (`DEBUG_CRASH_TIME` = 10000 ms) crashes the client on purpose (a manual crash).

Combinations (F3 + key), name (default key):

| Key | Action |
|---|---|
| A | reload all chunks ("Reloading all chunks") |
| B | toggle hitboxes (entity hitboxes entry) |
| C | copy location as a `/execute in <dim> run tp @s x y z yaw pitch` command to the clipboard ("%.2f" values); hold 10 s to crash |
| D | clear chat |
| G | toggle chunk borders |
| H | toggle advanced item tooltips (stored in `advancedItemTooltips`) |
| I | copy the targeted block/entity as a /setblock or /summon command |
| L | start/stop profiling (10 seconds) |
| N | toggle creative/spectator (needs permission) |
| P | toggle pause-on-lost-focus (`pauseOnLostFocus`) |
| S | dump dynamic textures |
| T | reload resource packs ("Reloaded resource packs") |
| V | dump client version info |
| X | toggle improved transparency |
| 1 | profiler chart |
| 2 | fps (and tps) charts |
| 3 | bandwidth and ping charts |
| 4 | lightmap texture |
| F4 | game-mode switcher (needs permission) |
| F6 | debug options screen (`DebugOptionsScreen`: per-entry on/off/in-overlay) |

Developer-only chunk-section visualisation keys exist (`handleChunkDebugKeys`: smart cull, octree, fog, frustum
capture, section visibility, wireframe, multi-draw) and are out of scope.

### 5.2 Entries and profiles

The overlay is a list of entries (`DebugScreenEntries`, ids in the `minecraft` namespace), each with a status:
`ALWAYS_ON`, `IN_OVERLAY` (shown only while the overlay is visible), or `NEVER`. A missing entry is `NEVER`. The
statuses persist in `debug-profile.json` (game directory) with the profile choice (`default`, `performance`).
The enabled list is sorted by identifier (natural order: alphabetical by path); `reducedDebugInfo` (option or
server `Login` flag) hides entries that are not allowed in reduced mode (`isAllowed`).

**Default profile** (`DEFAULT`): `IN_OVERLAY` for `3d_crosshair` (no text), `game_version`, `tps`, `fps`, `memory`,
`system_specs`, `player_position`, `player_section_position`, `simple_performance_impactors`. All others are
`NEVER` and are switched on through F3+F6 or the F3+key toggles. **Performance profile**: `tps` `IN_OVERLAY`, `fps`
`ALWAYS_ON`, `gpu_utilization`, `memory`, `simple_performance_impactors` `IN_OVERLAY`.

All entry ids: `game_version`, `fps`, `tps`, `memory`, `detailed_memory`, `system_specs`, `looking_at_block_state`,
`looking_at_block_tags`, `looking_at_fluid_state`, `looking_at_fluid_tags`, `looking_at_entity`,
`looking_at_entity_tags`, `chunk_render_stats`, `chunk_generation_stats`, `entity_render_stats`,
`particle_render_stats`, `chunk_source_stats`, `player_position`, `player_section_position`, `player_speed`,
`light_levels`, `heightmap`, `biome`, `local_difficulty`, `day_count`, `entity_spawn_counts`, `sound_mood`,
`sound_cache`, `post_effects`, `gpu_utilization`, `simple_performance_impactors`, and the no-text toggles
`entity_hitboxes`, `chunk_borders`, `3d_crosshair`, `chunk_section_paths`, `chunk_section_octree`,
`chunk_section_visibility`, and `visualize_*` (water_levels, heightmap, collision_boxes, entity_supporting_blocks,
block_light_levels, sky_light_levels, solid_faces, chunks_on_server, sky_light_sections).

### 5.3 Columns and line layout (`DebugScreenOverlay`)

Each entry's `display` adds text through one of: `addPriorityLine` (goes to the left column unless the left has more
lines than the right, then to the right: so priority lines fill both columns alternately starting left),
`addLine` (a regular line), or `addToGroup(entry id, lines)` (a group). Layout:
1. Priority lines (left/right as above), then a blank line each side when non-empty.
2. Regular lines, in entry order, are split in two: the first ceil(n/2) to the left column, the rest to the right.
3. Groups (in first-added order) are each kept together; they are distributed by index: the first
   ceil(groups/2) groups to the left, the rest to the right, each followed by a blank line.
4. When the overlay (not just ALWAYS_ON entries) is visible, a footer line lists the chart keys
   "Profiler: [F3]+[1] fps + tps: [F3]+[2] Bandwidth + Ping: [F3]+[3]..." (the `fps` text becomes `fps + tps`
   with a singleplayer server) and the lightmap key.
Text is drawn 2 px from the edge in a 9 px line height with a dark translucent background strip per line.

### 5.4 Line contents (formulas)

| Entry | Lines (printf-style, `%d` integer, `%.nf` fixed) |
|---|---|
| `game_version` (priority) | the launched version string (for example "26.3") |
| `fps` (priority) | `"%d fps T: %s%s @%sHz"`: the measured fps (`Minecraft.getFps`), the frame limit (`inf` when the limit is "unlimited"), the VSync suffix `" (immediate)"`, `" (mailbox)"`, `" (fifo)"`, `" (fifo relaxed)"`, the refresh rate |
| `tps` (regular) | singleplayer: `"Integrated server @ %.1f/%s ms%s, %.0f tx, %.0f rx"` (average tick ms / target ms, `" (frozen)"`, `" (frozen - stepping)"` or `" (sprinting)"`, packets sent/received averages); multiplayer: `"\"%s\" server%s, %.0f tx, %.0f rx"` (server brand, ...) |
| `memory` (group `memory`) | `"Mem: %2d%% %03d/%03dMiB"` (used x 100 / max, used MiB, max MiB), `"Allocation rate: %03dMiB/s"`, `"Allocated: %2d%% %03dMiB"` (total x 100 / max, total MiB); used = total - free, all /1048576 |
| `player_position` (group `position`) | `"XYZ: %.3f / %.5f / %.3f"` (x, y, z of the camera entity); `"Block: %d %d %d"` (block position); `"Chunk: %d %d %d [%d %d in r.%d.%d.mca]"` (section x, y, z = block >> 4; chunk x, z within region = (chunk & 31); region x, z = chunk >> 5); `"Facing: %s (%s) (%.1f / %.1f)"` (cardinal name, direction text, yaw, pitch): direction text "Towards negative Z" (north), "Towards positive Z" (south), "Towards negative X" (west), "Towards positive X" (east), "Invalid" |
| `player_section_position` | `"Section-relative: %02d %02d %02d"` (block position & 15 for each axis) |
| `player_speed` | `"Speed: %.3f blocks/tick"` |
| `simple_performance_impactors` | `"%s%sB: %d"` (graphics options such as improved-transparency, fast-/fancy-clouds, biome blend), `"Filtering: %s %dx"` / `"Filtering: %s"`, `"Terrain Rendering: %s"` (`multidrawindirect` or `naive`) |
| `biome` (lines added individually) | `"Biome: <id>"` for the camera block's biome in the client level; in singleplayer additionally `"Server Biome: <id>"`; an unregistered biome prints `"[unregistered <key>]"` |
| `light_levels` (group `light`) | `"Client Light: %d (%d sky, %d block)"` = the combined (raw) brightness at the camera block (`LevelLightEngine.getRawBrightness(pos, 0)`), the sky-layer light, the block-layer light; singleplayer adds `"Server Light: (%d sky, %d block)"`, otherwise the placeholder `"Server Light: (?? sky, ?? block)"` |
| `heightmap` (group `heightmaps`) | one line for the client chunk (prefix `CH`) and one for the server chunk (prefix `SH`): the heightmap values at the camera X/Z, one per type with the letters `SW` (world surface), `S` (surface), `OW` (ocean floor world), `O` (ocean floor), `M` (motion blocking), `ML` (motion blocking no leaves); `??` when the chunk is unavailable |
| `local_difficulty` | `"Local Difficulty: %.2f // %.2f"` (effective difficulty, day-time-adjusted difficulty) at the camera block (the second value's meaning and whether a multiplayer client prints it are inferred) |
| `day_count` | `"Day #%d"`: the period count of the overworld day timeline (`data/minecraft/timeline/day.json`, clock `minecraft:overworld`, `period_ticks` 24000), i.e. the overworld clock's ticks divided by 24000, rounded down; whether the first day prints as 0 or 1 is inferred |
| `looking_at_block_state` (group `looking_at_block`) | the targeted block within a 20.0 block reach: `"Targeted Block: x, y, z"`, then the block's registered name (`minecraft:stone`), then one line per block-state property `"<property>: <value>"` |
| `looking_at_block_tags` | the same hit, then `"#<tag id>"` for every block tag of the block (the `#\u0001` template) |
| `looking_at_fluid_state`, `looking_at_fluid_tags` | the same for the fluid at the targeted position (`"Targeted Fluid: x, y, z"`, name, properties; `#tag` lines) |
| `looking_at_entity`, `looking_at_entity_tags` | `"Targeted Entity"` heading followed by the entity type name and its tags (the body lines are inferred) |
| `sound_mood` | appends `" (Mood %d%%)"` (mood x 100) to a sound line (inferred placement) |
| `sound_cache` | `"Sound cache: %d buffers, %d MiB"` |
| `system_specs` | `"Java: %s"` (the `java.version` property), `"CPU: %s"` (processor count x name), `"Display: %dx%d (%s)"`, `"Window: %dx%d (%.2fx pixel density)"`, plus GPU/driver lines (inferred, not decoded) |
| `detailed_memory` | `"Memory (%s): i=%03dMiB u=%03dMiB c=%03dMiB m=%03dMiB"` for heap and for non-heap (init, used, committed, max) |
| `chunk_generation_stats` | `"Blending: Old"` and further generation counters (inferred, not decoded) |
| `particle_render_stats` | `"P: %d"` (the particle count; a server-side count may follow, inferred) |
| `entity_spawn_counts` | `"SC: %d, %d"` and per-mob-category counts (`"<category>: %d"`, inferred layout) |
| `chunk_render_stats`, `entity_render_stats`, `chunk_source_stats`, `post_effects`, `gpu_utilization` | renderer-internal statistics (visible/total chunk sections, entity counts, chunk cache counts, active post-effect names, GPU load %): not traced and out of scope |

**Scope decision for a CobolCraft client.** In scope (implement): `game_version`, `fps`, `tps`, `memory`,
`player_position`, `player_section_position`, `player_speed`, `biome`, `light_levels`, `local_difficulty`,
`day_count`, `looking_at_block_state`, `looking_at_block_tags`; their formulas above are complete enough to build.
Optional: `heightmap`, `looking_at_fluid_*`, `looking_at_entity*`, `simple_performance_impactors` (only its
"Filtering"/"Terrain Rendering" lines make sense for the client's own renderer). Out of scope (not needed by a
minimal client, not specified further): `system_specs`, `detailed_memory`, `chunk_render_stats`,
`chunk_generation_stats`, `entity_render_stats`, `particle_render_stats`, `chunk_source_stats`,
`entity_spawn_counts`, `sound_mood`, `sound_cache`, `post_effects`, `gpu_utilization`, and every no-text toggle
(`entity_hitboxes`, `chunk_borders`, `3d_crosshair`, `chunk_section_*`, `visualize_*`).

Defaults displayed on a fresh install are therefore: version, fps, tps, memory group, system specs, the position
group (XYZ, Block, Chunk, Facing), the section position, and the performance impactor lines. Biome, light, looking
at, and heightmap lines need F3+F6 or a restored non-default profile.

---

## 6. F5 camera modes

`CameraType` has three values in this order: `FIRST_PERSON` (first person, not mirrored), `THIRD_PERSON_BACK` (not
mirrored), `THIRD_PERSON_FRONT` (mirrored). Pressing `key.togglePerspective` (default F5, code 62) calls
`Options.setCameraType(cycle())` where `cycle` = the next value modulo 3 (first -> back -> front -> first). When the
first-person flag changes, the renderer re-checks the camera entity post-effect. The mode is not stored in
`options.txt` (7.2: no `cameraType` key is in the processing function; the runtime field exists only in memory,
and it starts as first person). The third-person camera sits 4.0 blocks away (`Camera`; shortened by blocks in
the way); the front mode looks back at the player (mirrored). `key.smoothCamera` (cinematic camera) is unbound by
default.

---

## 7. Options

### 7.1 `options.txt` on disk

File `options.txt` in the game directory (`Options.optionsFile`), UTF-8, written by `Options.save`, read by
`Options.load`:
- Line 1: `version:<data version>` (the current world data version, here 5023: the `DataVersion` of the running
  game). On load the file is parsed into a string map and upgraded through the data fixer from that version
  (`DataFixTypes.OPTIONS`); a missing or unparsable version counts as 0 (always upgraded).
- Every following line is `<name>:<value>`, split at the first `:` (`Splitter.on(':').limit(2)`); a line without
  `:` is skipped with a warning ("Skipping bad option").
- Value encodings: booleans `true`/`false`; integers and floats in decimal (a float may be given as `true`/`false`
  =1/0); strings raw; `OptionInstance` values as one JSON value produced by the option's codec (numbers bare,
  strings quoted `"..."`, enums as their quoted serialized names); lists (`resourcePacks`,
  `incompatibleResourcePacks`) as a JSON string array, for example `["vanilla","file/Faithful 32x - 26.3.zip"]`.
- Unparsable values log a warning and keep the default (integers: "Invalid integer value for option", floats
  likewise, option codecs: "Error parsing option value").
- Key bindings are written as `key_<mapping name>:<key name>` (for example `key_key.forward:key.keyboard.w`), sound
  categories as `soundCategory_<name>:<float>` and model parts as `modelPart_<part>:<true|false>`; the three prefixes
  `key_`, `soundCategory_`, `modelPart_` are literal templates in the constant pool of `Options`.
- Unknown lines are preserved only by being ignored; the file is rewritten in full on each save, in the order of
  the processing function (below). The last line may be `fullscreenResolution:<mode>` when a fullscreen video mode
  is chosen.
- Saving happens when an options screen is closed, on `Options.save` calls after changes, and on exit.

### 7.2 Option names, defaults and ranges

All read from the `Options` constructor (option objects and the plain fields) and its processing function. A slider
over an integer range is `OptionInstance$IntRange(min, max)`; a 0..1 slider is `UnitDouble`; "stored" gives the
file value when it differs from the slider value. Enum options are stored as the enum's serialised (lower-case)
name inside JSON quotes. Out-of-range file values are rejected by the codec (the option keeps its default).

**File header and resource packs**

| Key | Default | Value |
|---|---|---|
| `version` | the running data version (5023) | integer, first line of the file |
| `resourcePacks` | `[]` | JSON array of pack ids, lowest priority first; see section 8 for the id rules |
| `incompatibleResourcePacks` | `[]` | JSON array of pack ids that the player confirmed although incompatible |

**Video (Video Settings screen)**

| Key | Default | Range / values / step |
|---|---|---|
| `graphicsPreset` | `fancy` | enum slider (the preset set; changing a quality option below sets it to `custom`) |
| `preferredGraphicsBackend` | `default` | enum (graphics API choice; applies after restart) |
| `renderDistance` | 12 | integer 2 to 32 if the JVM max heap is above 1,000,000,000 bytes, else 2 to 16 (read: a memory test selects 32 or 16) |
| `simulationDistance` | 12 | integer 5 to 32 (2 to 32 in debug mode), same 32-or-16 cap |
| `entityDistanceScaling` | 1.0 | stored double 0.5 to 5.0; slider integer 2 to 20 (steps of 0.25: value = slider / 4, inferred) |
| `maxFps` | 120 | stored integer 10 to 260; slider integer 1 to 26 (value = slider x 10; the top step, 260, is shown as unlimited) |
| `enableVsync` | true | boolean |
| `inactivityFpsLimit` | `afk` | enum (frame-rate cap when the window is unfocused/idle) |
| `fullscreen` | false | boolean; `exclusiveFullscreen` false; `macFullscreenMenuVisibility` false (macOS only) |
| `guiScale` | 0 (Auto) | integer 0 to a window-dependent maximum (cap 2147483646), see below; `debugGuiScale` is a separate -1.. range used only in debug builds |
| `gamma` (Brightness) | 0.5 | 0.0 to 1.0 |
| `fov` | 70 | integer 30 to 110 (stored as a double, e.g. `70.0`) |
| `ao` (smooth lighting) | true | boolean |
| `biomeBlendRadius` | 2 | integer 0 to 7 (blend area (2 x r + 1)^2) |
| `renderClouds` / `cloudStatus` | `fancy` | enum `off`, `fast`, `fancy` (accepts the legacy boolean form); `cloudRange` 128, integer 2 to 128 |
| `weatherRadius` | 10 | integer 3 to 10 |
| `cutoutLeaves` | true | boolean; `vignette` true; `improvedTransparency` false |
| `particles` | `all` | enum `all`, `decreased`, `minimal` (legacy numeric form accepted) |
| `entityShadows` | true | boolean |
| `chunkSectionFadeInTime` | 0.75 | stored double 0.0 to 2.0 seconds; slider integer 0 to 40 (value = slider / 20, inferred) |
| `prioritizeChunkUpdates` | `none` | enum (chunk-update priority; legacy numeric form accepted) |
| `mipmapLevels` | 4 | integer 0 to 4 |
| `textureFiltering` | `none` | enum (filtering method); `maxAnisotropyBit` default 2, integer 1 to 3 |
| `bobView` | true | boolean (View Bobbing) |
| `attackIndicator` | `crosshair` | enum `off`, `crosshair`, `hotbar` |
| `glintSpeed` | 0.5 | 0.0 to 1.0; `glintStrength` 0.75, 0.0 to 1.0 |
| `showAutosaveIndicator` | true | boolean |
| `overrideWidth`, `overrideHeight` | 0, 0 | integers (window size override; 0 = none) |
| `fullscreenResolution` | absent | written as the last line only when a fullscreen video mode is chosen |

GUI scale (`Window.calculateScale`): the largest integer s starting from 1 such that s is below the requested
maximum and below the framebuffer width and height, and framebuffer width / (s + 1) is still >= 320 and
framebuffer height / (s + 1) is >= 240 (i.e. the GUI is kept at least 320 x 240); when "force unicode font" is on
and s is odd, 1 is added. Option value 0 means this automatic value; a non-zero value is clamped to the maximum.

**Controls and mouse**

| Key | Default | Range / values |
|---|---|---|
| `mouseSensitivity` | 0.5 | 0.0 to 1.0 (label "*yawn*" at 0, "HYPERSPEED!!!" at 1); camera turn = mouse delta x `(s x 0.6 + 0.2)^3 x 8` (`MouseHandler.turnPlayer`) |
| `invertXMouse`, `invertYMouse` | false | boolean |
| `discrete_mouse_scroll` | false | boolean |
| `mouseWheelSensitivity` | 0 | slider integer -200 to 100 (a logarithmic scale; effective multiplier 10^(v/100), inferred) |
| `allowCursorChanges` | true | boolean |
| `quitShortcuts` | true | boolean |
| `ctrlClickEmulatesRightClick` | false | boolean (macOS) |
| `autoJump` | false | boolean |
| `rotateWithMinecart` | false | boolean |
| `operatorItemsTab` | false | boolean |
| `toggleCrouch`, `toggleSprint`, `toggleAttack`, `toggleUse` | false each | boolean: hold-to-toggle behaviour of the sneak, sprint, attack and use keys |
| `sprintWindow` | 7 | integer 0 to 10 ticks (tooltip: "Time window in ticks where double-tapping the forward key activates sprint.") |
| `key_<mapping name>` | see 7.3 | value = the key's name (`key.keyboard.w`, `key.mouse.left`, `key.keyboard.unknown` = unbound); the `key_` prefix is the literal in the constant pool |
| `mainHand` | `right` | enum `left`, `right` |

**Sound (Music & Sounds screen)**

| Key | Default | Range |
|---|---|---|
| `soundCategory_master`, `soundCategory_music`, `soundCategory_record`, `soundCategory_weather`, `soundCategory_block`, `soundCategory_hostile`, `soundCategory_neutral`, `soundCategory_player`, `soundCategory_ambient`, `soundCategory_voice`, `soundCategory_ui` | 1.0 each (read: the slider option is created with default 1.0) | 0.0 to 1.0 (the file holds the float); labels "Master Volume", "Music", "Jukebox/Note Blocks", "Weather", "Blocks", "Hostile Mobs", "Friendly Mobs", "Players", "Ambient/Environment", "Narrator/Voice", "UI". The prefix `soundCategory_` is literal. |
| `soundDevice` | "" (system default) | string (audio device name) |
| `showSubtitles` | false | boolean |
| `directionalAudio` | false | boolean |
| `musicToast` | `never` | enum |
| `musicFrequency` | the enum's default constant (`DEFAULT`) | enum (how often music plays) |

Model parts: `modelPart_cape`, `modelPart_jacket`, `modelPart_left_sleeve`, `modelPart_right_sleeve`,
`modelPart_left_pants_leg`, `modelPart_right_pants_leg`, `modelPart_hat` (literal prefix `modelPart_`), boolean,
default true (the set of all parts is enabled at construction). `mainHand` is above.

**Chat**

| Key | Default | Range / values |
|---|---|---|
| `chatVisibility` | `full` | enum `full`, `system`, `hidden` |
| `chatColors`, `chatLinks`, `chatLinksPrompt` | true | boolean |
| `chatOpacity` | 1.0 | 0.0 to 1.0 |
| `chatLineSpacing` | 0.0 | 0.0 to 1.0 |
| `textBackgroundOpacity` | 0.5 | 0.0 to 1.0 |
| `backgroundForChatOnly` | true | boolean |
| `chatScale` | 1.0 | 0.0 to 1.0 slider (a scale factor) |
| `chatWidth` | 1.0 | 0.0 to 1.0 |
| `chatHeightFocused` | 1.0 | 0.0 to 1.0 |
| `chatHeightUnfocused` | computed by `ChatComponent.defaultUnfocusedPct()` from constants 180 (max height px), 20 (min height px) and 70.0 (target px): (70 - 20) / (180 - 20) = 0.3125 (inferred arithmetic on the constants read) | 0.0 to 1.0 |
| `chatDelay` | 0.0 | stored double 0.0 to 6.0 seconds; slider integer 0 to 60 (value = slider / 10) |
| `autoSuggestions` | true | boolean (command suggestions) |
| `hideMatchedNames` | true | boolean |
| `onlyShowSecureChat` | false | boolean |
| `saveChatDrafts` | false | boolean |
| `notificationDisplayTime` | 1.0 | stored double 0.5 to 10.0; slider integer 5 to 100 (value = slider / 10) |
| `hideServerAddress` | false | boolean (plain field) |
| `advancedItemTooltips` | false | boolean (toggled by F3+H) |

**Accessibility**

| Key | Default | Range / values |
|---|---|---|
| `narrator` | `off` | enum (legacy numeric form accepted) |
| `narratorHotkey` | true | boolean |
| `highContrast` | false | boolean (also toggled by enabling the `high_contrast` pack) |
| `highContrastBlockOutline` | false | boolean |
| `screenEffectScale` (Distortion Effects) | 1.0 | 0.0 to 1.0 |
| `fovEffectScale` (FOV Effects) | 1.0 | 0.0 to 1.0, the slider value is squared (the codec uses an `xmap`: sqrt for display, square for use; inferred) |
| `darknessEffectScale` | 1.0 | 0.0 to 1.0 |
| `damageTiltStrength` | 1.0 | 0.0 to 1.0 |
| `darkMojangStudiosBackground` | false | boolean |
| `hideLightningFlashes` | false | boolean |
| `hideSplashTexts` | false | boolean |
| `menuBackgroundBlurriness` | 5 | integer 0 to 10 |
| `panoramaScrollSpeed` | 1.0 | 0.0 to 1.0 |
| `reducedDebugInfo` | false | boolean |

**Other / bookkeeping (no player-facing widget in a minimal client)**

| Key | Default | Note |
|---|---|---|
| `lang` | `en_us` | language code |
| `lastServer` | "" | last multiplayer address |
| `pauseOnLostFocus` | true | boolean (F3+P) |
| `useNativeTransport` | true | boolean |
| `tutorialStep` | `movement` | enum (tutorial progress) |
| `joinedFirstServer` | false; `skipMultiplayerWarning` false; `onboardAccessibility` true; `startedCleanly` true; `syncChunkWrites` false; `glDebugVerbosity` 1 | internal flags |
| `realmsNotifications` | true | not applicable (Realms) |
| `allowServerListing` | true | server-list privacy toggle |
| `inGameNotification` | false; `sharePresence` `all`; `telemetryOptInExtra` false; `japaneseGlyphVariants` (default computed from the locale by `japaneseGlyphVariantsDefault`); `forceUnicodeFont` false | not applicable to a CobolCraft client |
| `cameraType` | not saved | the F5 mode is kept in memory only: no `cameraType` name appears in the processing function (resolves the earlier question) |

Keys not listed here are not in this version's options file. Options that need no equivalent in a CobolCraft client
(Realms, telemetry, presence sharing, narrator, graphics API, mac fullscreen, Japanese glyphs) can be ignored; the
loader must still tolerate them in a file (unknown lines are skipped).

The Options screens (language strings): "Options..." (`OptionsScreen`) leads to Video Settings
(`VideoSettingsScreen`: headers Display, Quality & Performance, Interface, Preferences), Music & Sounds
(`SoundOptionsScreen`), Controls (`ControlsScreen`, then Mouse Settings `MouseSettingsScreen` and Key Binds
`KeyBindsScreen` / `KeyBindsList` grouped by category), Accessibility, Chat, Language, Skin Customization,
Online, Resource Packs ("Resource Packs...", section 8). Option widgets are sliders (`OptionInstance$IntRange`,
`UnitDouble`), cycle buttons (`Enum`, boolean) and tooltip-carrying widgets; changing a widget calls the option's
value-changed listener (for example render distance resizes the loaded area, GUI scale re-lays out the screen,
`graphicsPreset` is set to custom when a quality option changes).

### 7.3 Key bindings (defaults)

Name (language label) = default key (code): category. Movement: `key.forward` W (26), `key.left` A (4), `key.back` S (22),
`key.right` D (7), `key.jump` Space (44), `key.sneak` Left Shift (225, a toggle-capable mapping), `key.sprint` Left Ctrl
(224, toggle-capable). Inventory: `key.inventory` E (8), `key.swapOffhand` F (9), `key.drop` Q (20),
`key.hotbar.1` to `.9` = 1 to 9 (30 to 38), `key.saveToolbarActivator` C (6, creative), `key.loadToolbarActivator` X
(27, creative). Gameplay: `key.use` right mouse button (`key.mouse.right`), `key.attack` left mouse button
(`key.mouse.left`), `key.pickItem` middle mouse. Multiplayer: `key.chat` T (23), `key.playerlist` Tab (43),
`key.command` / (56), `key.socialInteractions` P (19)... (friends key 18 = O is also defined). Misc:
`key.screenshot` F2 (59), `key.togglePerspective` F5 (62), `key.smoothCamera` unbound, `key.fullscreen` F11 (68),
`key.advancements` L (15), `key.quickActions` G (10), `key.toggleGui` F1 (58),
`key.toggleSpectatorShaderEffects` F4 (61). Spectator: `key.spectatorOutlines` unbound, `key.spectatorHotbar` middle
mouse. Debug: `key.debug.overlay` and `key.debug.modifier` F3 (60), then the letters in 5.1 (each a `key.debug.*`
mapping: crash C, reloadChunk A, showHitboxes B, clearChat D, showChunkBorders G, showAdvancedTooltips H,
copyRecreateCommand I, spectate N, switchGameMode F4, debugOptions F6, focusPause P, dumpDynamicTextures S,
reloadResourcePacks T, profiling L, copyLocation C, dumpVersion V, profilingChart 1, fpsCharts 2, networkCharts 3,
lightmapTexture 4, improvedTransparency X).

---

## 8. Resource-pack screen (`PackSelectionScreen`)

**Opening**: Options -> "Resource Packs..." creates the screen with the client's `PackRepository`, the pack
directory `Minecraft.getResourcePackDirectory()` (the folder `resourcepacks` inside the game directory by default;
it can be overridden by the launcher argument `resourcePackDir`, and the folder is created if missing), and an
"apply" callback that receives the repository on close.

**Layout**: header (title, then a line "Drag and drop files into this window to add packs", then a 200 x 15 search
box with hint "Search..."), body of two lists side by side, each 200 wide: "Available" (left) and "Selected" (right);
footer with two buttons separated by 8 px: **Open Pack Folder** ("Open Pack Folder", tooltip
"(Place pack files here)") and **Done**. Header element spacing 4 px; list item rows 33 px tall (inferred from the
66 px sizing constants).

**List semantics** (`PackSelectionModel`): the selected list is shown top = highest priority. Internally the
repository keeps lowest priority first, so the model reverses it. Each pack entry shows its icon (from
`pack.png`, else `textures/misc/unknown_pack.png`), title, one-line description and source ("built-in", "feature",
"local", "server", "world"; shown as `title (source)`), and an "Incompatible" note
("(Made for a newer/an older version of Minecraft)") when the pack format does not match.
- **Enable**: clicking an available entry (or its arrow button) removes it from Available and inserts it into
  Selected at the pack's default position (`Pack$Position.insert`: top for most folder packs; fixed-position packs
  stay where declared). The model calls the list-changed listener and `updateRepoSelectedList`.
- **Disable**: clicking a selected entry moves it back to Available (not allowed for a `required` pack such as the
  built-in vanilla pack).
- **Reorder**: up/down arrows on a selected entry swap it with its neighbour (`moveUp`/`moveDown`: not past a
  fixed-position pack, not when it is itself fixed).
- Selecting an incompatible pack asks for confirmation ("Are you sure you want to load this pack?" with the
  version-specific text) before enabling.
- The search box filters both lists by title/id substring (lower-case) as you type.
- Enabling the pack with id `high_contrast` sets the `highContrast` accessibility option; disabling clears it.

**Refresh**: a `WatchService` registered on the pack directory (create, delete and modify events) is polled each tick
(`Watcher.pollForChanges`). When it reports a change, the screen schedules a reload after a cooldown of 20 ticks
(`RELOAD_COOLDOWN`): the repository is re-scanned (`PackRepository.reload`), packs that disappeared are removed from
Selected, new packs appear in Available, and the lists are repopulated. If polling fails the watcher is closed and
auto-refresh stops. Dropping files or folders onto the window offers to copy them into the pack directory
("Do you want to add the following packs to Minecraft?"), then reloads; entries that are not packs are rejected with
a message.

**Open Pack Folder**: calls the platform's "open path" on the pack directory (`Blaze3D.openPath(packDir)`), i.e.
it opens the `resourcepacks` folder in the operating system's file manager.

**Pack ids and what `resourcePacks` stores** (`FolderRepositorySource`, `PackDetector`). The repository scans the pack
directory (one level) and accepts an entry as a pack in exactly two cases: (1) a **directory** that contains a regular
file `pack.mcmeta`; (2) a **regular file whose name ends in `.zip`**. Anything else is ignored ("Found non-pack
entry ... ignoring"); a symbolic link is validated first. Every discovered pack gets the id
`file/<entry name>`, where the entry name is the file or directory name exactly as on disk, including the
`.zip` extension for an archive, with no path and no other change; its displayed title is the literal entry name and
its source is "local". Examples: the archive `Faithful 32x - 26.3.zip` -> id `file/Faithful 32x - 26.3.zip`; an
unpacked folder named `MyPack` containing `pack.mcmeta` -> id `file/MyPack`. The built-in packs have their own
fixed ids (`vanilla`, also `high_contrast`, `programmer_art` and similar built-ins). Folder-discovered packs are
created with the default position TOP (a newly enabled one goes to the top of the Selected list = highest
priority) and "not required, not fixed".
`resourcePacks` stores the ids of the **selected** packs in repository order, lowest priority first (the reverse
of the on-screen top-to-bottom order). Example with the built-in pack and one zip enabled above it:
`resourcePacks:["vanilla","file/Faithful 32x - 26.3.zip"]`; with a directory pack additionally on top:
`resourcePacks:["vanilla","file/Faithful 32x - 26.3.zip","file/MyPack"]`. The id string of a zip contains the
extension, so renaming the file changes the id and un-selects the pack at the next load (the stale id is removed
with a warning).

**Done / closing** (`onClose`): `PackSelectionModel.commit` writes the selection into the repository, invokes the
callback, which updates the `resourcePacks` option, saves `options.txt`, and reloads resources
(`Minecraft.reloadResourcePacks`), then the watcher is closed.

**Loading at startup** (`Options.loadSelectedResourcePacks`): for each id in `resourcePacks`, a pack that does not
exist is dropped ("Removed resource pack ... from options because it doesn't seem to exist anymore"); an
incompatible pack is dropped unless its id is in `incompatibleResourcePacks`; a pack in `incompatibleResourcePacks` that
is now compatible is removed from that list; the surviving ids are given to `PackRepository.setSelected`. Required
packs are always added (`rebuildSelected`).

---

## 9. Worked examples (for tests)

**Jump arc (survival, flat ground, no sprint, no effects).** Starting at y = 0: velocity after `jumpFromGround` =
0.42. Each tick, the position changes by the current velocity, then velocity = (velocity - 0.08) x 0.98. Heights
after ticks 1 to 12: 0.4200, 0.7532, 1.0013, 1.1661, 1.2492, 1.2522 (peak), 1.1768, 1.0244, ... then below 0 at tick
12 (clamped to the ground, which lands the player in tick 12). Maximum height 1.2522 blocks. Re-pressing Space in
the air changes nothing; `noJumpDelay` is 10 and the player is not on the ground.

**Flight toggle.** Creative (Abilities `mayfly` = true). Space rising edges at ticks 100 and 103: the second edge
is 3 ticks after the first, inside the 2nd..6th window -> `flying` becomes true (and, on the ground, a jump
happens). Edges at 100 and 108: tick 108 is the 8th after, the check sees 0 -> it is a new first tap (no toggle).
Survival (`mayfly` = false): no toggle at any timing.

**Break time.** Stone: hardness 1.5, Req (2.6, read directly), held iron pickaxe (speed 6.0; correct tool), standing, no effects:
progress/tick = 6.0 / 1.5 / 30 = 0.13333; n = ceil(1/0.13333) = 8 ticks (7.5 rounds up). Bare hand: speed 1.0,
no correct tool: 1.0 / 1.5 / 100 = 0.006667 -> 150 ticks. Dirt (hardness 0.5, Req no, 2.6) by hand:
1.0 / 0.5 / 30 = 0.06667 -> 15 ticks. Iron pickaxe with Efficiency III on stone: speed 6 + (9 + 1) = 16;
16 / 1.5 / 30 = 0.3556 -> 3 ticks. The same while airborne (/5): 0.0711 -> 15 ticks. With Haste II: x(1 + 3 x 0.2)
= 1.6. With Mining Fatigue I: x 0.3. Eyes in water: x 0.2. Stage values for the first example after 1..7 ticks:
floor(10 x 0.1333 x n) = 1, 2, 4, 5, 6, 8, 9 (progress 0.133, 0.267, 0.4, 0.533, 0.667, 0.8, 0.933); the 8th tick
reaches 1.067 and breaks. The server accepts the stop packet once its own progress is >= 0.7, i.e. after 6 ticks
since the start (0.1333 x (5 + 1) = 0.8; at 4 ticks since start 0.667 < 0.7).

**Crafting matches.**
- 4 oak planks in a 2x2 square anywhere in a 3x3 grid, `crafting_table` pattern `["##","##"]` (key `#` = any plank):
  trimmed grid 2x2, ingredient count 4 = 4, size equals, all cells are planks -> result 1 crafting table.
  Planks in a 2x2 window at any corner of the 3x3 grid match; planks at (0,0),(1,0),(0,1),(2,2) do not (trimmed
  size 3x3).
- One plank above another in any column of the 3x3 grid, pattern `["#","#"]`: trimmed 1x2, result 4 sticks. In the
  inventory grid slots 1 and 3 (left column) or 2 and 4 both match.
- Mirroring: a recipe with pattern `["XX","X "]` (not symmetric) also matches a grid whose trimmed contents are
  `["XX"," X"]`, because the grid is tested mirrored horizontally. It does not match `["X ","XX"]` (that would need
  a vertical flip).
- Shapeless: a single oak log in any slot -> 4 oak planks (ingredient count 1 = slot count 1).
- Shift-click on the result with 3 logs in the inventory-menu grid slot 1 (stack of 3): one craft per
  `quickMoveStack`, repeated while the result is the same item: after 3 crafts the slot is empty, result changes to
  empty and the loop ends; the 12 planks went to inventory slots 9..44 (hotbar end first).
- Place Recipe for stick with 2 planks in the inventory and an empty 2x2 grid, use-max false: 1 plank -> grid slot 1
  and 1 -> slot 3 (top-left aligned in a 2x2: rw 1 is not < 2/2), result 4 sticks.
  In the 3x3 table the single-wide recipe is centered: grid slots 2 and 5 (offset floor(1.5-0.5) = 1).

**Quick move.** Hotbar slot 36 holding iron boots in the inventory menu, boots slot 8 empty: moves to slot 8. A stack
of cobblestone in main slot 10: to the hotbar 36..44 (first merges into partial stacks, then fills the first empty
slot). In the crafting table, shift-clicking planks in hotbar slot 37: they go first into grid slots 1..9.

**Options.txt sample lines** (format only): `version:5023`, `mouseSensitivity:0.5`, `fov:70.0`,
`renderDistance:12`, `guiScale:0`, `gamma:0.5`, `resourcePacks:["vanilla","file/Faithful 32x - 26.3.zip"]`,
`key_key.forward:key.keyboard.w`, `soundCategory_master:1.0`.

---

## Open questions

1. Block hardness and tool requirements are given in 2.6 for the listed blocks only; copy-declared blocks (the
   deepslate ores and `cobbled_deepslate`) inherit the Req flag by inference. Other blocks must be read
   from the same initialiser if needed.
2. Whether the first progress increment of a survival break occurs on the same tick as the click (start followed by
   continue in the same key-handling pass) is inferred from call order, not traced through the key-handling loop.
3. Recipe-book overlay and ghost details beyond the constants given (25 px cells, 4 or 5 rows, 0.375 scale, 30-tick
   cycling) were not traced; the recipe-button animation timings other than the 30-tick swap and the 15-tick
   `ANIMATION_TIME` constant are not traced.
4. The recipe search index lower-cases the indexed text (inferred); the order and tokenisation inside the suffix
   array for multi-word queries (whether a space is a literal or splits tokens) was not decoded.
5. Debug-entry lines marked "inferred" in 5.4 and the renderer statistics entries are out of the client scope
   decided in 5.4.
6. Fluid movement details (the fluid-falling adjustment, swim-up assist, Dolphin's Grace, honey and soul-sand
   effects) are summarised in 1.3, not complete.
7. Derived slider mappings marked "inferred" in 7.2 (entity distance scaling, chunk fade, chat delay, mouse wheel,
   FOV-effect squaring, unfocused chat height) come from reading the slider and codec constants, not from running the
   client.
