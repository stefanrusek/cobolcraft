# 54. Client gap closures (walk animation, swing and aggressive pose, teleport permission, trades, variant ids, camel, goat)

| Item | Value |
|---|---|
| Covers | Gaps recorded on task lines of `specs/002-client-polish/tasks.md` and in lane reports: the walk animation update and its feeds (§1), the swing and aggressive-pose drivers (§2), `/tp` location-form permission (§3), villager trade enchantment data and tag members (§4), registry order of metadata variants (§5), camel dash and sit (§6), goat ram (§7), remaining item and tag lists (§8) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution; clean-room round "cr3" (reader only; a reviewer follows) |
| Extends | 12 §6.4 (swing state), 18 (mob flags), 34-1 §8 (render state), 34-2 §4 (humanoid models), 05a (Animate), 05b (Swing Animation) |

All numbers are Java `float` unless stated. Each section starts with a "Gap closed" line naming what it answers.

---

## 1. Walk animation update

**Gap closed:** how `LivingEntity.walkAnimation` (`WalkAnimationState`) is updated each tick for the client models, with the per-type factors.

### 1.1 State

Four floats per living entity: `speedOld` (0), `speed` (0), `position` (0), `positionScale` (1).

| Operation | Effect |
|---|---|
| `update(target, smoothing, scale)` | speedOld = speed; speed = speed + (target - speed) x smoothing; position = position + speed; positionScale = scale |
| `stop()` | speedOld = speed = position = 0 (positionScale unchanged) |
| `setSpeed(v)` | speed = v (no change to speedOld or position) |
| `speed(pt)` (render) | min(lerp(pt, speedOld, speed), 1) |
| `position(pt)` (render) | (position - speed x (1 - pt)) x positionScale |
| `isMoving` | speed > 1.0e-5 |

### 1.2 Per-tick driver (`LivingEntity.calculateEntityAnimation(flag)`)

Runs **on the client only**, every client tick of every living entity other than the local player (the call sits in `LivingEntity.aiStep`, guarded by "level is client side"; `RemotePlayer.tick` calls it with flag false after the base tick). The server never runs it, and no packet carries walk state: the client derives it from the entity's position change.

1. d = length of (x - xo, dy, z - zo), where xo, yo, zo are the position at the previous tick and dy = (y - yo) only when `flag` is true, else 0. `flag` = the entity's `omnidirectionalAirMover()`: false by default; true for the bee, the parrot, and the sulfur cube when it has a body item (checked: `Entity` false, `Bee` true, `Parrot` true, `SulfurCube` = has body item). Remote players use false.
2. If the entity is a passenger or not alive: `stop()`. Otherwise `updateWalkAnimation(d)`.

### 1.3 `updateWalkAnimation(d)` by type

| Type | target speed | smoothing | positionScale |
|---|---|---|---|
| default (all other living entities) | min(d x 4, 1) | 0.4 | 3 if baby, else 1 |
| camel | min(d x 6, 1) when pose is STANDING and the dash animation is not running, else 0 | 0.2 | 3 if baby, else 1 |
| frog | 0 while the jump animation state is started, else min(d x 25, 1) | 0.4 | 3 if baby, else 1 |
| creaking | min(d x 25, 3) (note the cap 3) | 0.4 | 1 |

Other writers: the damage event (Damage Event packet, `handleDamageEvent`) sets `speed` to 1.5 directly, so a hurt entity swings its limbs for a few ticks while the smoothing decays it (the value is clamped to 1 at render time by `speed(pt)`).

### 1.4 What the renderer reads (`LivingEntityRenderer.extractRenderState`)

If the entity is not a passenger and is alive: `walkAnimationPos` = `position(pt)`, `walkAnimationSpeed` = `speed(pt)`; otherwise both 0. `wornHeadAnimationPos` = the vehicle's `position(pt)` when the vehicle is a living entity, else the entity's own `walkAnimationPos`. The models consume the two values as in 34-1 and 34-2 (limb swing angle from position, amplitude from speed).

### 1.5 Worked examples

1. Default adult moving at constant 0.2 blocks per tick from rest: target = min(0.8, 1) = 0.8; speed after tick 1 = 0.32, tick 2 = 0.32 + 0.48 x 0.4 = 0.512, tick 3 = 0.6272; position after tick 3 = 0.32 + 0.512 + 0.6272 = 1.4592; `position(pt = 1)` for an adult = 1.4592, for a baby 4.3776.
2. Standing still after that: target 0, speed decays by x 0.6 per tick (0.3763 on the next tick) and position keeps advancing by the decaying speed.
3. Camel running (0.1 per tick) while its dash animation runs: target 0, so the legs stop cycling.

---

## 2. Swing and the aggressive pose

**Gap closed:** how the living-entity attack swing and the arms-up "aggressive" pose are driven, with ids, durations and the readers.

### 2.1 Swing

- **Packet:** Swing Animation (clientbound 0x7B, 05b): entity id, hand, animation type and duration. On receipt the client calls `swing(hand, animation, false)` on the living entity (ignored for non-living entities). The state machine (ticks, `animation` = min(ticks / duration, 1), end when ticks exceed the duration, lerp for rendering) is in 12 §6.4; the same object serves every living entity.
- **Start rule (`SwingState.startIfAble`):** a new swing starts only when there is no swing running, or the running swing is at least half over (ticks > duration / 2, integer division), or ticks <= 0. Otherwise the call returns false and nothing is sent. Starting resets ticks to 0 and, when the new (hand, animation, duration) triple differs from the current one, also resets the animation value to 0.
- **Server send:** a successful server-side `swing` sends the packet to every player tracking the entity (and also to the entity itself when its third argument is true; mobs always pass false).
- **Duration:** the animation's `duration` field, modified by `getModifiedSwingDuration`: Haste amplifier a gives duration - (1 + a); otherwise Mining Fatigue amplifier a gives duration + (1 + a) x 2. The default animation is type `whack`, 6 ticks. An item's `attack_animation` component (default: whack, 6) supplies the animation for attacks.
- **Mob attacks (`Mob.swingForAttack(hand)`):** takes the attack animation of the item in that hand (the default when empty-handed or the item has no component) and swings with it. Called by the melee-attack goal and brain behaviour just before the damage is dealt (once per attack cooldown, 18 §attack goals) and by the break-door goal. Mobs that do not call it (their attack is signalled with Entity Event ids instead, such as the iron golem and the ravager) show their own animation (34-3).
- **Animate packet (0x02, 05a):** only actions 0 (leave bed), 1 (critical hit particles) and 2 (enchanted hit particles) exist in the client handler; the old arm-swing action is gone (Open question 1 of 05a is closed: arm swings use 0x7B).

### 2.2 Progress value for models

`getSwingAnimation(pt)` = `lerp(pt, animationOld, animation)`, with the wrap rule of 12 §6.4. The armed render state (34-1 §8) stores it as `swingAnimation` and the current swing description as `currentSwing`; in 34-2 the formulas call it `swing` or `attackTime`. A model applies the swing only while `swingAnimation` > 0 and `currentSwing` exists.

### 2.3 Aggressive flag

- Mob metadata slot 15 (BYTE, 18 §1.4): bit 1 no AI, bit 2 left-handed, **bit 4 aggressive** (set with `value | 4`, cleared with `value & ~4`; the other bits are untouched). It is replicated like any metadata, so the client reads it from Set Entity Data.
- The server sets it from goals: the zombie attack goal raises it when its raise-arm counter reaches 5 ticks and clears it on stop (18, ZombieAttackGoal); the ranged bow goal sets it while running; other goal-driven setters exist in the raider hold-ground goal, the illagers, the piglins and the pandas (classes that call `setAggressive` were listed, their conditions were not read; Open question 3).
- **Readers (client):** extraction copies `isAggressive` into the render state of: zombie, husk, drowned, zombie villager, zombified piglin (not the giant: flag stays false), skeleton family (stray, bogged, wither skeleton), illagers (pillager, vindicator, illusioner; evoker and others use `armPose`), and the piglin and piglin brute (via their arm pose). The pose formulas are 34-2 §4.3 (zombie arms, -2.0943952 aggressive and -1.3962634 otherwise), 34-2 §4.5 (skeleton), 34-2 §4.6 (piglin) and 34-3 §4.3 (illagers); this section adds only the drivers.

## 3. `teleport` / `tp` permission of the location forms

**Gap closed:** which permission level the location forms need (16 §5.2 was silent).

Read from `TeleportCommand.register`: exactly two `requires` predicates exist in the class, one on the `teleport` root literal and one on the `tp` root literal, each "source has permission `LEVEL_GAMEMASTERS`" (level 2). No child node carries a predicate and the execution methods make no further permission check (the class contains four permission references, all inside those two registrations). Consequences:

| Form | Permission |
|---|---|
| `teleport <location>` | level 2 (the root's) |
| `teleport <destination>` | level 2 |
| `teleport <targets> <location>` (plus rotation, `facing <location>`, `facing entity <entity> [anchor]`) | level 2 |
| `teleport <targets> <destination>` | level 2 |
| every form under the alias `tp` | level 2 (its own predicate, the same value) |

So every form, including the one-argument location form that moves the source itself, needs level 2 (game master); there are no level-0 or level-1 forms. A source below level 2 does not see the `teleport` and `tp` nodes in the command tree sent to it (15 framework: requirement filtering), so the literal is also unknown for completion. The `<targets>` selector's own rule (selectors that name other entities need level 2) is already met when the root is.

## 4. Villager trades: enchantment data and tag members

**Gap closed:** the level ranges and extra price of enchanted-book and enchanted-equipment trades (19 §24 lacked them), and the tag members named in the task lines. Read from `data/minecraft/villager_trade/**`, `data/minecraft/tags/{enchantment,block,item,point_of_interest_type}/` and `data/minecraft/enchantment/*.json`. The offer-building steps themselves (19 §24, "Offer construction") are unchanged; this section supplies the data they read.

### 4.1 Enchanted-book trades (librarian levels 1 to 4)

Each trade's result is a plain `enchanted_book`; the result modifiers are `enchant_randomly` (`only_compatible` false, `include_additional_cost_component` true, `options` = tag `tradeable`), then a filter that discards the offer when the book has no stored enchantments. The trade also lists `double_trade_price_enchantments` = tag `double_trade_price`.

- **Which enchantment:** one drawn from the tag `tradeable`, with no compatibility restriction (a book accepts anything).
- **Level:** uniform from 1 (`Enchantment.getMinLevel` returns 1 for every enchantment) to the enchantment's `max_level`, inclusive. The table lists the max levels.
- **Extra price E** for the drawn level L: 2 + nextInt(5 + 10 x L) + 3 x L (nextInt(n) is uniform in 0 to n-1). If the book's stored enchantment is in `double_trade_price`, E is doubled. The first price is `emerald` with count 0 raised by E (so E emeralds), the second price is one `book`.
- **Range of E before doubling:** L = 1: 2 + [0,14] + 3 = 5 to 19; L = 2: 2 + [0,24] + 6 = 8 to 32; L = 3: 2 + [0,34] + 9 = 11 to 45; L = 4: 2 + [0,44] + 12 = 14 to 58; L = 5: 2 + [0,54] + 15 = 17 to 71. Doubled values apply to the treasure group below.

| Max level | Enchantments in `tradeable` that have it |
|---|---|
| 1 | aqua_affinity, binding_curse, channeling, flame, infinity, mending, multishot, silk_touch, vanishing_curse |
| 2 | fire_aspect, frost_walker, knockback, punch |
| 3 | depth_strider, fortune, looting, loyalty, luck_of_the_sea, lunge, lure, quick_charge, respiration, riptide, sweeping_edge, thorns, unbreaking |
| 4 | blast_protection, breach, feather_falling, fire_protection, piercing, projectile_protection, protection |
| 5 | bane_of_arthropods, density, efficiency, impaling, power, sharpness, smite |

(Not in `tradeable`: swift_sneak, soul_speed, wind_burst, which are treasure-only; they never come from a villager.)

### 4.2 Enchantment tags used by trades

| Tag | Members |
|---|---|
| `tradeable` | tag `non_treasure`, plus binding_curse, vanishing_curse, frost_walker, mending |
| `non_treasure` (36) | protection, fire_protection, feather_falling, blast_protection, projectile_protection, respiration, aqua_affinity, thorns, depth_strider, sharpness, smite, bane_of_arthropods, knockback, fire_aspect, looting, sweeping_edge, efficiency, silk_touch, unbreaking, fortune, power, punch, flame, infinity, luck_of_the_sea, lure, loyalty, impaling, riptide, channeling, multishot, quick_charge, piercing, density, breach, lunge |
| `treasure` (7) | binding_curse, vanishing_curse, swift_sneak, soul_speed, frost_walker, mending, wind_burst |
| `double_trade_price` | tag `treasure` (members above) |
| `on_traded_equipment` | tag `non_treasure` |

So the doubled book prices apply to: binding_curse, vanishing_curse, frost_walker, mending (the treasure members that are also tradeable).

### 4.3 Enchanted-equipment trades

Result modifiers: `enchant_with_levels` with `levels` = uniform 5 to 19 (integer provider, inclusive), `options` = tag `on_traded_equipment` (= `non_treasure`), `include_additional_cost_component` true, then a filter that discards the offer unless the item has at least one enchantment. The levels value V is the "level" input of the enchanting-table selection of 26 (`enchant_with_levels` row): the pool is `non_treasure` filtered by item compatibility, so no treasure or curse enchantment appears on traded gear. Extra price E = V (when V > 0 and the result is non-empty); the first price count = base count + V, where the base count is the trade's `wants` (the value printed per trade in 19 §24). Range of the first price = base + 5 to base + 19. Examples: armorer diamond leggings (base 14): 19 to 33 emeralds; bow (fletcher level 4, base 2): 7 to 21; wandering trader iron pickaxe (base 1): 6 to 20. Every such trade has max uses 3 (wandering trader 1).

### 4.4 Tags named in the task lines

| Tag | Registry | Members |
|---|---|---|
| `acquirable_job_site` | **point_of_interest_type** (not a block tag) | armorer, butcher, cartographer, cleric, farmer, fisherman, fletcher, leatherworker, librarian, mason, shepherd, toolsmith, weaponsmith |
| `villagers_can_sleep_on_bed` (block tag) | block | tag `beds` |
| `beds` | block | the sixteen colour beds: white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black (each `<colour>_bed`) |
| `villager_babies_can_jump_on_bed` | block | tag `beds` |
| `gold_ores` | block and item (same three members) | gold_ore, nether_gold_ore, deepslate_gold_ore |
| `piglin_loved` (item tag, 26 members) | item | tag `gold_ores`, gold_block, gilded_blackstone, light_weighted_pressure_plate, gold_ingot, bell, clock, golden_carrot, glistering_melon_slice, golden_apple, enchanted_golden_apple, golden_helmet, golden_chestplate, golden_leggings, golden_boots, golden_horse_armor, golden_nautilus_armor, golden_sword, golden_spear, golden_pickaxe, golden_shovel, golden_axe, golden_hoe, raw_gold, raw_gold_block, golden_dandelion |

## 5. Registry id order of metadata variants

**Gap closed:** how the numeric variant ids in entity metadata are determined, and the vanilla id lists.

- **What is sent:** the metadata types WOLF_VARIANT, FROG_VARIANT, CAT_VARIANT, PIG_VARIANT, COW_VARIANT, CHICKEN_VARIANT (and the sound-variant types, ZOMBIE_NAUTILUS_VARIANT; 00 §metadata types) carry a registry id, a VarInt: the position of the entry in that registry. The wire form is the plain id (not id + 1); there is no inline form (read: each variant class's `STREAM_CODEC` is `ByteBufCodecs.holderRegistry`, see 00 §10.1).
- **How the order is determined:** all of these are data-pack registries (JSON files under `data/<namespace>/<registry>/`, 04 §6, 23 §1). The id of an entry is its index in the sorted order of its identifier: **path first** (UTF-16 code-unit comparison), then namespace (23 §3.4). It is not file listing order, not an explicit field, and not alphabetical by display name. The Registry Data packet (04) lists the entries in id order, and both sides register in that order, so the ids in metadata are defined by what the server sent: a server that sends a different set sends different ids for the same names and the client follows. Adding any entry sorting earlier shifts every later id.
- **Vanilla set:** the default data pack in the jar's `data/minecraft/` (the optional packs under `data/minecraft/datapacks/` (`minecart_improvements`, `redstone_experiments`, `trade_rebalance`) hold no variant files). Entry names sorted as above, so ids follow:

| Registry | Count | Ids (id name) |
|---|---|---|
| `wolf_variant` | 9 | 0 ashen, 1 black, 2 chestnut, 3 pale, 4 rusty, 5 snowy, 6 spotted, 7 striped, 8 woods |
| `frog_variant` | 3 | 0 cold, 1 temperate, 2 warm |
| `cat_variant` | 11 | 0 all_black, 1 black, 2 british_shorthair, 3 calico, 4 jellie, 5 persian, 6 ragdoll, 7 red, 8 siamese, 9 tabby, 10 white |
| `pig_variant` | 3 | 0 cold, 1 temperate, 2 warm |
| `cow_variant` | 3 | 0 cold, 1 temperate, 2 warm |
| `chicken_variant` | 3 | 0 cold, 1 temperate, 2 warm |
| `zombie_nautilus_variant` | 2 | 0 temperate, 1 warm |
| `wolf_sound_variant` | 7 | 0 angry, 1 big, 2 classic, 3 cute, 4 grumpy, 5 puglin, 6 sad |
| `cat_sound_variant` | 2 | 0 classic, 1 royal |
| `pig_sound_variant` | 3 | 0 big, 1 classic, 2 mini |
| `cow_sound_variant` | 2 | 0 classic, 1 moody |
| `chicken_sound_variant` | 2 | 0 classic, 1 picky |
| `sulfur_cube_archetype` | 12 | 0 bouncy, 1 explosive, 2 fast_flat, 3 fast_sliding, 4 high_resistance, 5 hot, 6 light, 7 regular, 8 slow_bouncy, 9 slow_flat, 10 slow_sliding, 11 sticky |

- Each variant's biome or spawn condition and texture are data of the entries themselves (04 §6 schemas, 48); the order above does not depend on them.
- `painting_variant` (51 entries) is ordered the same way (rule only; its names are not needed for metadata and are not listed here).

## 6. Camel dash and sit pose cadence

**Gap closed:** the rider's jump-input charge, the dash formula and cooldown, and the sit and stand cadence. Extends 19 §3.8 (which gives the constants) and 44-7 §10.4 (the nautilus, which shares the jumpable-vehicle protocol). Read from `Camel`, `AbstractHorse`, `PlayerRideableJumping`, `CamelAi$RandomSitting`, `LocalPlayer.aiStep`/`sendRidingJump`.

### 6.1 Client charge (the riding player's `LocalPlayer`, every client tick while riding a vehicle that can jump)

State: `jumpRidingTicks` (int, starts 0) and `jumpRidingScale` (float). The vehicle must be a jumpable (`canJump`: the camel needs to be saddled and not sitting or transitioning, 19 §3.8) and its `getJumpCooldown()` (the dash cooldown) must be 0; otherwise the scale is forced to 0 each tick. With the jump key states "was" (the key state at the start of `aiStep`, before this tick's input update) and "now" (after it) (the order is inferred from the position of the reads):

| Condition (checked in this order) | Effect |
|---|---|
| (first, always) `jumpRidingTicks` < 0 | increment it; when it becomes 0, scale = 0 |
| was pressed and now released | `jumpRidingTicks` = -10; call `onPlayerJump(floor(scale x 100))` on the vehicle; send Player Command `START_RIDING_JUMP` (05c) with data = `floor(scale x 100)` |
| was not pressed and now pressed | `jumpRidingTicks` = 0, scale = 0 |
| was pressed and still pressed (held) | `jumpRidingTicks` += 1, then scale = 0.1 x ticks while ticks < 10, else 0.8 + (2 / (ticks - 9)) x 0.1 |

So the charge climbs by 0.1 per tick to 0.9 at tick 9, reaches 1.0 at tick 10, then falls toward 0.8 (0.9 at tick 11, 0.8667 at 12, 0.85 at 13). After a release the -10 lockout means a new charge cannot start for 10 ticks (a re-press during the lockout is ignored by the second row only once ticks reach 0).

### 6.2 Strength to scale

`onPlayerJump(strength)` with strength 0 to 100 (`AbstractHorse` and the camel override): ignored unless saddled, the dash cooldown is 0 and the camel is on the ground; then (a negative strength is treated as 0; the base class also calls its stand-if-possible routine for strength >= 0, an animal-rearing helper whose camel effect was not traced) `playerJumpPendingScale` = 1.0 when strength >= 90, else 0.4 + 0.4 x strength / 90. Examples: strength 0 gives 0.4; 45 gives 0.6; 89 gives 0.7956; 90 and above give 1.0.

### 6.3 The dash

- The pending scale is consumed by `AbstractHorse.tickRidden` on the instance that is authoritative (the controlling client): if the camel is on the ground, the pending scale > 0 and it is not already jumping, `executeRidersJump(scale)` runs and the pending scale resets to 0.
- `executeRidersJump(scale)`: velocity += (normalize(look.x, 0, look.z) x (22.2222 x scale x movement_speed x blockSpeedFactor), 0 vertical) + (0, 1.4285 x scale x J, 0 horizontal), where J = `getJumpPower()` = `jump_strength` attribute x blockJumpFactor + Jump Boost bonus (the attribute-based `getJumpPower(1.0)`; the camel's attribute is 0.42, 19 §3.8). Then `dashCooldown` = 55, metadata DASH (slot 19) = true, and a sync is requested. Example: movement_speed 0.09, scale 1.0, block factor 1: horizontal impulse length 22.2222 x 0.09 = 2.0; vertical 1.4285 x 0.42 = 0.6.
- Server: on `START_RIDING_JUMP` with data > 0 and `canJump`, `handleStartJump` plays the dash sound (`camel.dash`), emits game event `ENTITY_ACTION` and sets DASH true; `STOP_RIDING_JUMP` does nothing. The server does not apply the impulse itself.
- `onSyncedDataUpdated(DASH)` (not on the first tick): `dashCooldown` = 55 if it is 0, else unchanged, so the server and every client start the cooldown when the flag changes.
- `tick` (both sides): if DASH is true, `dashCooldown` < 50 and (on the ground, or in a liquid, or a passenger), DASH = false (so the flag lasts at least the first 6 ticks: cooldown 55 down to 50). If `dashCooldown` > 0, decrement it; on reaching 0 play `camel.dash_ready` (volume 1, pitch 1, source NEUTRAL, at the camel's block position, heard by all near). On the client `setupAnimationStates` runs each tick.
- Ridden speed (`getRiddenSpeed`): `movement_speed` + 0.1 when the rider is sprinting and the dash cooldown is 0, else + 0. The camel can always sprint.
- Sounds: dash `camel.dash`, dash ready `camel.dash_ready`, sit `camel.sit`, stand `camel.stand` (the sound event ids of `SoundEvents.CAMEL_*`; their registry ids are in 46).

### 6.4 Sit pose cadence

Metadata slot 20 (LONG, `LAST_POSE_CHANGE_TICK`) L; game time T. Definitions: sitting = L < 0; `poseTime` = T - |L|.

| Operation | Effect |
|---|---|
| `sitDown` | no-op if already sitting; else sound `camel.sit`, pose SITTING, game event `ENTITY_ACTION`, L = -T |
| `standUp` | no-op if not sitting; else sound `camel.stand`, pose STANDING, game event, L = T |
| `standUpInstantly` | pose STANDING, game event, L = max(0, T - 52 - 1) (so the transition is already over) |
| `isInPoseTransition` | poseTime < (40 if sitting else 52) |
| `isVisuallySittingDown` | sitting and 0 <= poseTime < 40 |
| `isCamelVisuallySitting` | (poseTime < 0) is not equal to sitting (normally equals sitting; differs when a client's clock lags) |
| `refuseToMove` | sitting or in transition: the camel does not walk (movement input zero, horizontal velocity zeroed on the ground, head clamped to the body) |
| `canCamelChangePose` | the camel would not suffocate in the other pose (the test uses the other pose's dimensions; the sitting box is the standing box lowered by `SITTING_HEIGHT_DIFFERENCE` 1.43 (inferred)) |

So sitting down takes 40 ticks and standing up takes 52 ticks, measured from L. In `tick`: a sitting camel in water stands up instantly; a rider pressing forward (`zza` > 0) while the camel is sitting and not in transition makes it `standUp`.

**Random sitting (server, brain idle activity):** `RandomSitting(20)` has minimal pose time 20 x 20 = 400 ticks (20 seconds). It can start when: not in water, `poseTime` >= 400, not leashed, on the ground, no controlling passenger, and `canCamelChangePose`. On start: sitting camel stands up; a standing one sits down unless it is panicking. It is one entry (weight 1) of a RunOne list with stroll, walk-to-look-target and a 30 to 60 tick do-nothing (19 §3.8), so a standing camel that satisfies the conditions sits down within a few brain selections.

**Client animation states (`setupAnimationStates`, each client tick):** the idle animation restarts whenever its timeout reaches 0 (the timeout is then set to 80 + nextInt(40) ticks, else it decrements by 1; it runs whether sitting or not). If visually sitting: the stand-up and dash animations stop; while `isVisuallySittingDown` the sit animation starts if stopped and the sit-pose animation stops; once the 40 ticks have passed the sit animation stops and the sit-pose (held) animation starts if stopped. If not visually sitting: sit and sit-pose animations stop; the dash animation runs while DASH is true; the stand-up animation runs while in a pose transition with poseTime >= 0 (that is, during the 52 ticks after standing up). The model animations (key frames) are in 34-4.

## 7. Goat ram behaviour

**Gap closed:** trigger, charge, hit and knockback, cooldown and sounds of the goat ram (19 §10 gave only the constants and said the ram code "was not read"). Read from `GoatAi.initRamActivity`, `PrepareRamNearestTarget`, `RamTarget`, `Goat`. The ram is the `RAM` brain activity (19 §10, selection order RAM, LONG_JUMP, IDLE); the `CountDownCooldownTicks` behaviour of the core activity decrements `RAM_COOLDOWN_TICKS` each tick. Constants repeated from 19 §10 are marked (19).

### 7.1 Phase 1: choosing a run-up (`PrepareRamNearestTarget`, brain priority 1 of the RAM activity)

- **Runs when** (memories): no `RAM_COOLDOWN_TICKS`, no `RAM_TARGET`, no tempting player, no breed target, and `NEAREST_VISIBLE_LIVING_ENTITIES` present. Time-out 160 ticks. Parameters (19): minimum run-up distance 4, maximum 7, walk speed 1.25, prepare time 20 ticks, targeting conditions `RAM_TARGET_CONDITIONS`.
- **Targeting conditions:** the combat targeting conditions plus a selector that rejects other goats, rejects armor stands unless mob griefing is on, and requires the candidate's bounding box to lie within the world border (19).
- **start:** among the goat's nearest visible living entities, the closest one that passes `RAM_TARGET_CONDITIONS` becomes the target and a run-up is chosen (below); if none passes, nothing is chosen.
- **Choosing the run-up (`chooseRamPosition`):** clear the "reached" timestamp. The target's block position T must be a *walkable block* (the goat's navigation says it is a stable destination, and the path-type malus of that block for the goat is exactly 0), otherwise there is no candidate. For each of the four horizontal directions (the order of `Direction.Plane.HORIZONTAL`), start at T and step one block at a time up to 7 steps; stop (stepping back one block) at the first block that is not walkable. Keep the end position when its Manhattan distance to T is at least 4. Sort the kept positions by distance to the goat's own block position (closest first; squared distance, inferred) and take the first one for which the navigation can create a path to it (distance parameter 0) that reaches it. That position S with the target's block T and the target entity form the candidate; if none qualifies, there is no candidate.
- **tick (every tick while running; with no candidate nothing happens):** set `WALK_TARGET` = S at speed 1.25 (completion range 0) and `LOOK_TARGET` = the target entity. Then:
  1. If the target's block position is no longer T: broadcast Entity Event **59** (stop lowering the head), stop the navigation, and choose a new run-up for the target (this also clears the reached timestamp).
  2. Else if the goat's block position equals S: broadcast Entity Event **58** (lower the head); on the first such tick record the current game time as the reached timestamp; when game time minus the timestamp is at least 20: set `RAM_TARGET` = the **far edge of T as seen from the goat**: the bottom centre of T plus (0.5 x sign(T.x - goatBlock.x), 0, 0.5 x sign(T.z - goatBlock.z)) (the sign of zero is 0), play the prepare sound (below) at the goat with volume 1 and the goat's voice pitch, and drop the candidate.
- **canStillUse:** a candidate exists and its target is alive. **stop:** if there is no `RAM_TARGET` (the run-up was abandoned or timed out): broadcast Entity Event 59 and set `RAM_COOLDOWN_TICKS` to the minimum of the goat's ram range: **600** for a normal goat, **100** for a screaming goat (19).

### 7.2 Phase 2: the charge (`RamTarget`, priority 0)

- **Runs when** `RAM_COOLDOWN_TICKS` is absent and `RAM_TARGET` is present; time-out **200** ticks.
- **start:** `ramDirection` = normalize of (goatBlock.x - RAM_TARGET.x, 0, goatBlock.z - RAM_TARGET.z), the horizontal direction **from the target point back toward the goat** (the goat's block position at this moment). `WALK_TARGET` = the `RAM_TARGET` point at ramming speed **3.0** (19), completion range 0.
- **tick:** first collect living entities whose boxes overlap the goat's own bounding box (not inflated) and that pass `RAM_TARGET_CONDITIONS`.
  - **Hit** (the list is non-empty; the first entity E is used): damage E with the "no aggro mob attack" damage source of the goat, amount = the goat's `attack_damage` attribute (adult 2, baby 1 (19)); if damage was dealt, apply the post-attack enchantment effects. Then compute the knockback: A = (Speed amplifier + 1 if the goat has Speed, else 0), B = (Slowness amplifier + 1 if it has Slowness, else 0); base = clamp(goat movement speed x 1.65, 0.2, 3.0) + 0.25 x (A - B). Run item blocking of E against a mob-attack damage source with the same amount (E's shield); let f = 0.5 if something was blocked (blocked amount > 0) else 1. E gets `knockback(f x base x force, ramDirection.x, ramDirection.z)` with force **2.5** for an adult goat and **1.0** for a baby (19), using the standard knockback of 17 (`LivingEntity.knockback`, the knockback-resistance factor, velocity halving and the ground lift apply). Because the direction points from the target back to the goat, the entity is thrown along the direction of the charge. Then `finishRam`, and the impact sound (below) plays at the goat (volume 1, pitch 1, NEUTRAL).
  - **Horn-breaking block** (no hit): the block at floor(goat position + normalize(goat velocity x (1, 0, 1))) or the block above it has the block tag `snaps_goat_horn` (members in 7.4). If so: play the impact sound; call `dropHorn` (19 §10: removes one horn and drops a goat horn item, not for babies; returns whether a horn dropped); if it dropped, play the horn-break sound; then `finishRam` (in both cases).
  - **Otherwise:** finish the ram when the `WALK_TARGET` memory is absent, or `RAM_TARGET` is absent, or the walk target's tracker position is within 0.25 blocks of `RAM_TARGET` (the tracker position is a block centre, so this last test practically never holds; the normal end is the navigation erasing the walk target on arrival, or the 200-tick time-out).
- **finishRam:** broadcast Entity Event **59**; set `RAM_COOLDOWN_TICKS` = a sample of the goat's range: **uniform 600 to 6000** for a normal goat, **uniform 100 to 300** for a screaming goat (19); erase `RAM_TARGET`.

### 7.3 Client side

Entity Event 58 sets the goat's `isLoweringHead`, Entity Event 59 clears it. Every client tick (`Goat.aiStep`): `lowerHeadTick` += 1 while lowering, else -= 2; then clamp to 0 to 20. The head pitch added by the model is `getRammingXHeadRot` = (lowerHeadTick / 20) x (52.5 degrees for a baby, 30 degrees for an adult) converted to radians (x 0.017453292). So the head lowers over 20 ticks and rises in 10.

### 7.4 Sounds and tags

| Moment | Normal goat | Screaming goat | Source, volume, pitch |
|---|---|---|---|
| prepare (run-up reached and 20 ticks held) | `entity.goat.prepare_ram` | `entity.goat.screaming.prepare_ram` | NEUTRAL, 1, voice pitch |
| impact (hit an entity or a horn-breaking block) | `entity.goat.ram_impact` | `entity.goat.screaming.ram_impact` | NEUTRAL, 1, 1 |
| horn drops | `entity.goat.horn_break` | `entity.goat.horn_break` (same) | NEUTRAL, 1, 1 |

Block tag `snaps_goat_horn`: `overworld_natural_logs` (tag), stone, packed_ice, iron_ore, coal_ore, copper_ore, emerald_ore.

---

## 8. Remaining lists and formulas named by open Phase 49 tasks

**Gaps closed:** the slime-chunk seed formula (task line of the slime, "seed formula not in docs") and the members of the sniffer diggable-block tag ("the sniffer_diggable_block tag ... not in the docs"). Read from `WorldgenRandom.seedSlimeChunk`, `SingleThreadedRandomSource` and `data/minecraft/tags/block/`.

### 8.1 Slime chunk test

20 §10 (b) says the test is `nextInt(10) == 0` on a generator seeded by `seedSlimeChunk(chunkX, chunkZ, worldSeed, 987234911)`. The seeding formula, with all arithmetic as Java: `a` = chunkX and `b` = chunkZ (32-bit ints), `S` = the world seed (64-bit), salt = 987234911.

| Term | Type and wrapping |
|---|---|
| T1 | (a x a) x 4987142, computed in 32-bit int arithmetic (wraps), then widened to 64 bits |
| T2 | a x 5947611, 32-bit int (wraps), widened |
| T3 | (b x b) in 32-bit int (wraps), widened to 64 bits, then multiplied by the 64-bit constant 4392871 (64-bit wrap) |
| T4 | b x 389711, 32-bit int (wraps), widened |

Seed = (S + T1 + T2 + T3 + T4) XOR 987234911, summed in 64-bit two's complement. The generator is `SingleThreadedRandomSource(seed)`: the `java.util.Random` linear congruential generator (multiplier 0x5DEECE66D, increment 11, 48-bit mask, initial scramble `(seed XOR 0x5DEECE66D) AND (2^48 - 1)`), the same algorithm as `LegacyRandomSource` in 10 §2.6, including `nextInt(bound)` (power-of-two shortcut or the `next(31) mod bound` rejection loop). The chunk is a slime chunk when the first `nextInt(10)` equals 0 (about 10 percent of chunks). Each query starts from a fresh generator (no state carries over).

Test vectors (computed from this formula with the generator above; not executed in the artifact):

| chunkX | chunkZ | world seed | seed after the XOR | slime chunk |
|---|---|---|---|---|
| 0 | 0 | 0 | 987234911 | no |
| 0 | 0 | 12345 | 987247206 | no |
| 1 | 0 | 12345 | 981403717 | no |
| -3 | 7 | 12345 | 876799905 | yes |
| 5 | 5 | -1 | 889565929 | no |
| 100 | -200 | 987654321 | 175648119546 | no |

For seed 12345 exactly 23 of the 256 chunks with x and z in -8 to 7 are slime chunks.

### 8.2 Sniffer diggable-block tag

`sniffer_diggable_block` (block tag, used by the sniffer's `canDig`, 19 §14) has the members: tag `dirt` (dirt, coarse_dirt, rooted_dirt), tag `mud` (mud, muddy_mangrove_roots), tag `moss_blocks` (moss_block, pale_moss_block), grass_block, podzol. Related tags: `sniffer_egg_hatch_boost` = moss_block; item tag `sniffer_food` = torchflower_seeds.

### 8.3 Not closed

The remaining Phase 49 task remarks were checked and are either already answered in 20 §10 (slime hop cadence: jump delay 10 + nextInt(20), a third of it when aggressive; per-size speed 0.2 + 0.1 x size) or are not data lists (zombie reinforcement spawn-rule light test reasons, sniffer dig cadence beyond 19 §14, which is already in that section). They are left as stated.

---

## Open questions

1. The order in which `Direction.Plane.HORIZONTAL` iterates (7.1) was assumed to be the plane constant's order (north, east, south, west) and not read.
2. The camel's sitting dimensions (6.4) were not read.
3. The set of mobs that set the aggressive flag from a goal (2.3), beyond the zombie attack goal and ranged bow goal of 18, was not enumerated; only the client readers were.
