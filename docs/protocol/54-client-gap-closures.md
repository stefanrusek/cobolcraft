# 54. Client gap closures (walk animation, swing and aggressive pose, teleport permission, trades, variant ids, camel, goat)

| Item | Value |
|---|---|
| Covers | Gaps recorded on task lines of `specs/002-client-polish/tasks.md` and in lane reports: the walk animation update and its feeds (§1), the swing and aggressive-pose drivers (§2), `/tp` location-form permission (§3), villager trade enchantment data and tag members (§4), registry order of metadata variants (§5), camel dash and sit (§6), goat ram (§7), remaining item and tag lists (§8); round cr4: teleport dimension and coordinates (§9), playsound range (§10), saturation instance (§11), spawn-reason light and sniffer dig cadence (§12), `/compute` (§13), tab-completion server side (§14); round cr5, data component wire and NBT layouts: persistence table and enchantments (§15) |
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

Runs **on the client only**, every client tick of every living entity **including the local player** (the call sits unconditionally in the client-side branch of `LivingEntity.aiStep`, after movement; `RemotePlayer.tick` additionally calls it with flag false after the base tick, as read; the local player's own value is therefore also derived from its position change). The server never runs it, and no packet carries walk state: the client derives it from the entity's position change.

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
- The server sets it from goals: the zombie attack goal raises it when its raise-arm counter reaches 5 ticks and clears it on stop (18, ZombieAttackGoal); the ranged bow goal sets it while running; the other writers were enumerated by a scan of every class that calls `setAggressive` (the pandas are not among them):

| Writer | Rule |
|---|---|
| melee attack goal (`MeleeAttackGoal`, 18) and the skeleton's melee goal | set on start, cleared on stop |
| zombie attack goal | as above (raise-arm counter) |
| bow and crossbow attack goals, spear-use goal and spear behaviours, the drowned trident goal | set while running (start), cleared on stop (the crossbow goal and the raider hold-ground goal clear it on stop; hold-ground also sets it in its tick) |
| brains of the hoglin, piglin and piglin brute | each `updateActivity` pass: aggressive = the brain holds an attack target |
| zoglin | in its `updateActivity` (same attack-target pattern, not traced further) |

Open question 3 is closed apart from the zoglin and hold-ground conditions.
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

State: `jumpRidingTicks` (int, starts 0) and `jumpRidingScale` (float). The vehicle must be a jumpable (`canJump`: the camel needs to be saddled and not sitting or transitioning, 19 §3.8) and its `getJumpCooldown()` (the dash cooldown) must be 0; otherwise the scale is forced to 0 each tick. With the jump key states "was" (the key state captured at the start of `aiStep`, before this tick's input update; read) and "now" (after the update). The four rows form an if / else-if chain after the first row:

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
| `canCamelChangePose` | the camel would not suffocate in the other pose (the test uses the other pose's dimensions; the sitting dimensions are fixed boxes, not a lowering of the standing box: adult sitting = the camel type's width x **1.43** height, eye height 0.845; baby sitting 0.95 x 0.425, eye 0.41; baby standing 0.95 x 1.4, eye 1.38 (read from the static initialiser; the adult standing box is the entity-type box, 19 §3.8)) |

So sitting down takes 40 ticks and standing up takes 52 ticks, measured from L. In `tick`: a sitting camel in water stands up instantly; a rider pressing forward (`zza` > 0) while the camel is sitting and not in transition makes it `standUp`.

**Random sitting (server, brain idle activity):** `RandomSitting(20)` has minimal pose time 20 x 20 = 400 ticks (20 seconds). It can start when: not in water, `poseTime` >= 400, not leashed, on the ground, no controlling passenger, and `canCamelChangePose`. On start: sitting camel stands up; a standing one sits down unless it is panicking. It is one entry (weight 1) of a RunOne list with stroll, walk-to-look-target and a 30 to 60 tick do-nothing (19 §3.8), so a standing camel that satisfies the conditions sits down within a few brain selections.

**Client animation states (`setupAnimationStates`, each client tick):** the idle animation restarts whenever its timeout reaches 0 (the timeout is then set to 80 + nextInt(40) ticks, else it decrements by 1; it runs whether sitting or not). If visually sitting: the stand-up and dash animations stop; while `isVisuallySittingDown` the sit animation starts if stopped and the sit-pose animation stops; once the 40 ticks have passed the sit animation stops and the sit-pose (held) animation starts if stopped. If not visually sitting: sit and sit-pose animations stop; the dash animation runs while DASH is true; the stand-up animation runs while in a pose transition with poseTime >= 0 (that is, during the 52 ticks after standing up). The model animations (key frames) are in 34-4.

## 7. Goat ram behaviour

**Gap closed:** trigger, charge, hit and knockback, cooldown and sounds of the goat ram (19 §10 gave only the constants and said the ram code "was not read"). Read from `GoatAi.initRamActivity`, `PrepareRamNearestTarget`, `RamTarget`, `Goat`. The ram is the `RAM` brain activity (19 §10, selection order RAM, LONG_JUMP, IDLE); the `CountDownCooldownTicks` behaviour of the core activity decrements `RAM_COOLDOWN_TICKS` each tick. Constants repeated from 19 §10 are marked (19).

### 7.1 Phase 1: choosing a run-up (`PrepareRamNearestTarget`, brain priority 1 of the RAM activity)

- **Runs when** (memories): no `RAM_COOLDOWN_TICKS`, no `RAM_TARGET`, no tempting player, no breed target, and `NEAREST_VISIBLE_LIVING_ENTITIES` present. Time-out 160 ticks. Parameters (19): minimum run-up distance 4, maximum 7, walk speed 1.25, prepare time 20 ticks, targeting conditions `RAM_TARGET_CONDITIONS`.
- **Targeting conditions:** the combat targeting conditions plus a selector that rejects other goats, rejects armor stands unless mob griefing is on, and requires the candidate's bounding box to lie within the world border (19).
- **start:** among the goat's nearest visible living entities, the closest one that passes `RAM_TARGET_CONDITIONS` becomes the target and a run-up is chosen (below); if none passes, nothing is chosen.
- **Choosing the run-up (`chooseRamPosition`):** clear the "reached" timestamp. The target's block position T must be a *walkable block* (the goat's navigation says it is a stable destination, and the path-type malus of that block for the goat is exactly 0), otherwise there is no candidate. For each of the four horizontal directions (the order of `Direction.Plane.HORIZONTAL`: north, east, south, west), start at T and step one block at a time up to 7 steps; stop (stepping back one block) at the first block that is not walkable. Keep the end position when its Manhattan distance to T is at least 4. Sort the kept positions by distance to the goat's own block position (closest first; squared distance, inferred) and take the first one for which the navigation can create a path to it (distance parameter 0) that reaches it. That position S with the target's block T and the target entity form the candidate; if none qualifies, there is no candidate.
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

## 9. Dimension and coordinate handling of `teleport` / `tp`

**Gap closed:** which dimension each `teleport` form uses (T4805; unblocks T4807 and T4813). Source: `TeleportCommand` (all execution methods and `performTeleport`), `Relative`, `Entity.teleport` (cr4 round, same jar as above).

### 9.1 Dimension per form

| Form | Destination level | Notes |
|---|---|---|
| `teleport <location>` (source itself) | the **executor's** level (`CommandSourceStack.getLevel`, the level `execute in <dimension>` sets) | a source without an entity fails with the usual "entity required" error |
| `teleport <targets> <location>` and every variant (rotation, `facing <location>`, `facing entity <entity> [anchor]`) | the **executor's** level | the same level is used for every target |
| `teleport <destination>` and `teleport <targets> <destination>` | the **destination entity's own level**, with its x, y, z, yaw and pitch and an empty relative set | the executor's level plays no part |

Neither the target's own level nor a world default is consulted: a target in another dimension than the destination level is moved into it. So `execute in <dimension> run tp <player> x y z` does send the player to that dimension, and `tp <player> <entity in another dimension>` follows the destination entity across dimensions.

### 9.2 Same dimension or crossing

Each target is handed to `Entity.teleport` with a transition naming the destination level, the position, zero velocity and the rotation. `Entity.teleport` compares the destination dimension key with the entity's current one:

- equal: same-dimension move (passengers are moved by their own transitions first; the position is set; players are sent the position update);
- different: cross-dimension move: passengers are ejected and each teleported by its own transition; a **new entity of the same type** is created in the destination level (spawn reason `DIMENSION_TRAVEL`), state is copied from the old one (`restoreFrom`), the old one is removed, and the new one is positioned and added to the destination level. For players the usual dimension-change path (Respawn, chunk and state resend: 05a/05b, 17 §4.10) is expected (the `ServerPlayer` override was not read; inferred).

Targets in different dimensions from each other are independent: each goes to the one destination level. A target whose `teleportTo` returns false (removed entity) gets no facing step and none of the step-5 side effects, but it **is still counted**: the move routine returns nothing and the loop tracks every target unconditionally (corrected in review; 16 §5.2's older "not counted" wording is superseded). The result is therefore the number of targets selected, and the success message reports that count.

### 9.3 Relative and local coordinates (refines 5.2)

1. The coordinate argument is resolved **against the executor** once for all targets (`~` adds the source's position as `positioned` set it; `^` uses the source's rotation), not per target. 5.2's "added to the entity's current value" is true only when target and executor coincide.
2. The bounds test of 5.2 applies to the resolved position. The code turns a relative axis into a delta against the target and the move adds the target's position back, so the net position is always the resolved absolute one.
3. Relative set handed to the move: relative coordinate axes set the matching **velocity** (DELTA_X/Y/Z) flags (that velocity component is kept); the position (X, Y, Z) flags are set only when the target already is in the destination dimension, otherwise none. Rotation: without a rotation argument yaw and pitch are both flagged relative (the target keeps its own); with one, each is relative per its own `~`.
4. Yaw and pitch are wrapped to (-180, 180] (`Mth.wrapDegrees`) before the move.
5. After a successful move: the facing step, if any; then, for a living entity that is not fall-flying, velocity x (1, 0, 1); on-ground = true; a pathfinder mob's navigation is stopped.

Worked examples: `execute in the_nether run tp @s 8 70 8` from the overworld: the player ends in the Nether at (8, 70, 8). `execute at <pig> run tp @a ~ ~1 ~`: every player goes to the one point one block above that pig, and a player in another dimension than the executor's level is moved into the executor's level.

---

## 10. `/playsound` audible distance

**Gap closed:** the range, minimum-volume and listener rules behind `commands.playsound.failed` (T1913). Source: `PlaySoundCommand.playSound`, `SoundEvent.getRange`, `CommandResponseTracker`.

1. **Listeners.** Only targets whose level is the executor's level are considered (a target in another dimension is skipped silently). Without `<targets>` the target set is the calling player alone; the position default is the executor's position; volume 1.0, pitch 1.0, minVolume 0.0.
2. **Range.** The command builds a variable-range sound event from the id (no fixed range, whatever the sound table says): range = 16 when volume <= 1, else 16 x volume. The check compares the squared distance from the given position to the target's position (x, y, z) against range squared.
3. **Inside range** (distance squared <= range squared): the target gets Sound (0x77, 05b) at the given position with the given volume and pitch.
4. **Outside range:** if minVolume <= 0 the target is skipped (nothing sent). If minVolume > 0 the target gets the sound at a position 2 blocks from the target along the line towards the given position (target + 2 x unit vector), with volume = minVolume (the client attenuates by its own rules, 12 sound).
5. One seed (`nextLong` of the executor level's random source) is drawn before the loop and sent to every target in the packet's seed field. The sound is sent as an inline (direct) sound event holding the id, never a registry id.
6. Every target that was sent a packet (rule 3 or 4) is tracked. Zero tracked: error `commands.playsound.failed`. One: `commands.playsound.success.single` (sound id, the player's display name); several: `.multiple` (sound id, count). Result = tracker total (the number of players reached).

Worked examples: players at distance 10 and 100 from the position, volume 1, minVolume 0: only the first is reached, result 1. Same with minVolume 0.5: both are reached, the second hears volume 0.5 at 2 blocks away; result 2. Volume 8: range 128, both are in range. No players in range and minVolume 0: failed.

---

## 11. Saturation effect as an effect instance (`/effect give`, beacons, anything that adds the instance)

**Gap closed:** how the `saturation` effect restores food when it is held as an instance (it was documented only for drinking, 17 §4.9). Source: `SaturationMobEffect`, `InstantaneousMobEffect`, `MobEffectInstance.tickServer`, `LivingEntity.tickEffects` and `addEffect`, `EffectCommands.giveEffect` / `computeDurationInTicks`.

1. **Instance creation by `/effect give <targets> <effect> [seconds] [amplifier] [hideParticles]`.** For an instantaneous effect (`instant_health`, `instant_damage`, `saturation`) the duration is the given `seconds` value taken **as ticks, not multiplied by 20**; without it the duration is 1 tick. (Other effects: seconds x 20, `infinite` is -1, default 600 ticks.) The instance is added with `addEffect`; adding does **not** apply the effect (`onEffectStarted` of the base class is empty and the saturation class overrides neither it nor `onEffectAdded`).
2. **Per-tick application.** Once per server tick of the living entity, each active instance is ticked. An instantaneous effect applies when its remaining duration is >= 1, then the duration is reduced by 1; the instance is removed when the duration reaches 0. So a saturation instance of duration D applies on D consecutive ticks, starting with the entity tick after the command: `/effect give @s saturation` (duration 1) applies once; `/effect give @s saturation 5` applies 5 times; amplifier `a` is used for every application.
3. **One application** (`SaturationMobEffect.applyEffectTick`): for a player, `FoodData.eat(a + 1, 1.0)`: food = clamp(food + a + 1, 0, 20) and saturation = clamp(saturation + (a + 1) x 1.0 x 2, 0, food) (17 §4.9). For any non-player target nothing happens (the instance is still consumed).
4. **Interplay with hunger** (17 §4.9): there is none beyond the food and saturation values. The instance does not touch exhaustion; the regeneration rule that uses "food = 20 and saturation > 0" (heal every 10 ticks) therefore starts at once after the first application. Ordinary food and saturation changes mark the player for a Set Health packet (0x6A) as in 17 §4.9.
5. `/effect clear` removes the instance like any other effect.

Worked examples: food 10, saturation 0: `/effect give @s saturation` (a = 0): after the next tick food 11, saturation 2.0 (min(0 + 2, 11)). `/effect give @s saturation 3 4`: three ticks, each +5 food and +10 saturation, both capped (saturation to the food level): after tick 1 food 15, saturation 10; tick 2 food 20, saturation 20; tick 3 food 20, saturation 20. Amplifier 255 (maximum): +256 per application, clamped to 20.

---

## 12. Spawn-reason light rules (zombie reinforcements) and sniffer dig cadence

**Gap closed:** the "reasons that ignore light requirements" that 20 §3.3 left unread, and the timings of the sniffer's dig cycle that 19 §14 lacked. Source: `EntitySpawnReason`, `Monster.checkMonsterSpawnRules`, `Sniffer`, `SnifferAi` and its nested behaviours.

### 12.1 Spawn reasons and light

`EntitySpawnReason` declares 19 reasons, in this order (ordinals 0 to 18, inferred from declaration order): NATURAL, CHUNK_GENERATION, SPAWNER, STRUCTURE, BREEDING, MOB_SUMMONED, JOCKEY, EVENT, CONVERSION, REINFORCEMENT, TRIGGERED, BUCKET, SPAWN_ITEM_USE, COMMAND, DISPENSER, PATROL, TRIAL_SPAWNER, LOAD, DIMENSION_TRAVEL.

| Predicate | True for |
|---|---|
| `ignoresLightRequirements` | **TRIAL_SPAWNER only** |
| `isSpawner` | SPAWNER and TRIAL_SPAWNER |

`checkMonsterSpawnRules` runs the dark check of 20 §3.3 for every reason except TRIAL_SPAWNER, then the standard mob rule. So a **REINFORCEMENT** spawn (zombie reinforcements, 20 §3 "Reinforcements") must pass the full dark check at its chosen position: sky light <= a fresh nextInt(32), block light 0 in the Overworld, and the raw brightness <= one 0..7 sample (flat 10 in a thunderstorm). A SPAWNER (classic spawner block) is not exempt from the dark check by this predicate; it is exempt only from the sky-access test of `checkSurfaceMonstersSpawnRules` (20 §3.3) through `isSpawner`. The random calls of the dark check are drawn from the spawning level's random source.

### 12.2 Sniffer dig cycle (extends 19 §14)

Activities in priority order DIG, SNIFF, IDLE (`setActiveActivityToFirstValid`, evaluated by `updateActivity` every server tick after the brain tick). Definitions:

| Piece | Rule |
|---|---|
| `canSniff` | false when tempted, panicking, in water, in love, off the ground, a passenger or leashed |
| Sniffing behaviour (idle activity, 40 to 80 ticks run time, per 19 §14 "Sniffing(40, 80)") | start: not a baby, `canSniff`, no walk target, no sniffing target, no sniff cooldown; start moves to state SNIFFING (3); when it ends **by timing out** the state returns to IDLING and `calculateDigPosition` chooses a spot (up to 5 attempts of a random land position near the sniffer, horizontal radius 10, vertical 2 (inferred reading of the constants), first one whose block below passes the dig test of 19 §14 and is not in the explored list); the sniffing-target memory is set to it and a walk target to it with speed 1.25 |
| Searching behaviour (activity SNIFF) | needs a walk target, a sniffing target and not panicking; max run time 600 ticks; start: state SEARCHING (4); keeps running while `canSniff` and the walk target equals the sniffing target; on stop, if `canDig` and `canSniff`: set the digging memory, erase the walk target and the sniffing target |
| Digging behaviour (activity DIG) | needs the digging memory, no walk target, no sniff cooldown, not panicking; run time 160 to 180 ticks (random between); keeps going while the digging memory is present, `canDig` and not in love; start: state DIGGING (5) (seed tick = `tickCount + 120`, entity event 63; the sniffer then emits digging particles and the seed drops per 19 §14 when `tickCount` reaches the stored value, with the drop sound, from the head block) |
| End of Digging | **timed out** (ran its full 160 to 180 ticks): the sniff cooldown memory is set for **9600 ticks** (8 minutes) and the digging memory stays; **interrupted**: `resetSniffing` (erase the digging and sniffing-target memories and go to state IDLING; no cooldown) |
| FinishedDigging behaviour | needs the digging memory and the sniff cooldown both present, no walk target, not panicking; run time 40 ticks; start: state RISING (6); stop: if it timed out, state IDLING; then `onDiggingComplete` (stores the dug position in the explored list, 19 §14), erase the digging memory and set the happy memory (the FEELING_HAPPY idle behaviour then plays) |
| Cooldown effect | the Sniffing behaviour cannot start while the sniff cooldown exists, so a completed dig is followed by at least 9600 ticks without a new sniff, search or dig; a dig interrupted before its end leaves no cooldown |

Cycle length for a successful dig: sniff 40 to 80 ticks, walk to the target (path length dependent, searching limited to 600 ticks), dig 160 to 180 ticks (seed at 120 ticks into it), rise 40 ticks, then 9600 ticks cooldown.

Worked example: a sniffer starts Sniffing at tick 0 and times out at tick 60: IDLING, a target is chosen 7 blocks away and walked to at speed 1.25 (about 35 ticks): Searching stops, digging memory set at about tick 95; Digging runs 170 ticks (ends tick 265), the seed dropped at tick 215; sniff cooldown until tick 9865; FinishedDigging 40 ticks to tick 305, RISING then IDLING.

Not read: the exact argument order of the random position lookup (marked inferred), `FeelingHappy` and `Scenting` internals beyond the 19 §14 figures (40 to 100 and 40 to 80 ticks).

---

## 13. `/compute`: grammar, context sources, provider ids, results

**Gap closed:** what T1832 / T1833 lacked: the context-source nodes, the provider argument grammar, the provider ids, evaluation and result rules (16 §10.9 gave only message keys). Source: `ComputeCommand`, `LootContextSources` and its `ContextDecorator`, `ResourceOrIdArgument`, `LootContextParamSets`, the 4 + 26 data files. The provider JSON forms and arithmetic are in 26 §9 and 25-1 §9; this section only adds what the command does with them.

### 13.1 Tree

Level 2 on the `compute` root only. The provider part is the same under four prefixes:

```
compute                         (float <provider> [<scale:float>] | integer <provider>)
compute default                 (same)
compute block <pos:block_pos>   (same)
compute entity <target:entity>  (same)
```

`compute ...` without a source is the same context as `compute default ...`. `<scale>` is any float (no bounds) and defaults to 1.0 (inferred: the no-scale handler passes the constant 1). Argument names: `provider`, `scale`, `computePos`, `computeTarget`.

### 13.2 Context built for the evaluation

All start with the source's level, the optional parameter `this_entity` = the executing entity (absent when the source has none) and `origin` = the source's position (a Vec3, possibly fractional). The parameter sets are those of 26 §3.2:

| Form | Set | Extra parameters |
|---|---|---|
| none / `default` | `command_compute_default` | none |
| `block <pos>` | `command_compute_position` | the position must be loaded (the loaded-block-position getter; an unloaded position gives the usual unloaded-position error, inferred from the getter); `block_state` = the state at `<pos>` in the source's level; `block_entity` = the block entity there, optional |
| `entity <target>` | `command_compute_entity` | `target_entity` = the one entity selected (the usual single-entity selector rules) |

The loot context is created without a seed (a fresh random source: any random provider is unseeded).

### 13.3 Provider argument

The argument is parsed by `ResourceOrIdArgument`: either an **identifier** naming an entry of the registry the node needs (`context_float_provider` after `float`, `context_int_provider` after `integer`), or an inline SNBT value decoded with the provider's codec (a plain number is a constant provider; `{...}` a compound form of 26 §9). A missing identifier fails with `argument.resource_or_id.no_such_element` (argument: the id); an inline value the codec rejects fails with `argument.resource_or_id.failed_to_parse`. Suggestions: the registry entry ids. Examples listed by the argument: `foo`, `foo:bar`, `012`, `{}`, `true`.

Provider ids (the pack's entries, count read from the jar):
- `context_float_provider` (4): `brewing/speed_default`, `cooking/fast_speed_multiplier`, `cooking/normal_speed_multiplier`, `cooking/speed_default`.
- `context_int_provider` (26): `brewing/uses_default`; `compostable/always_add_one`, `compostable/low`, `compostable/low_medium`, `compostable/medium`, `compostable/medium_high`; `cooking/fast_burn_time_reduction_factor`, `cooking/normal_burn_time_reduction_factor`; `cooking/time_bamboo`, `time_blaze_rod`, `time_boats`, `time_coal`, `time_coal_block`, `time_dried_kelp_block`, `time_dry_plants`, `time_hanging_signs`, `time_lava_bucket`, `time_roots`, `time_wood_blocks`, `time_wood_items_extra_small`, `time_wood_items_large`, `time_wood_items_small`, `time_wood_slabs`, `time_wool`, `time_wool_carpets`, `time_wool_slabs` (each under the `cooking/` prefix, namespace `minecraft`). Values: 25-1 §9.

### 13.4 Evaluation and result

- **integer:** the provider is evaluated with `getIntUnsafe` (arithmetic problems throw, such as a division by zero). Result = that int. Message: `command.compute.result.named.exact` (provider id, value) when the provider was given by an id, else `command.compute.result.unnamed.exact` (value). Both are sent as success feedback (broadcast to ops allowed: inferred).
- **float:** evaluated with `getFloatUnsafe` to v. If v is not finite (NaN, infinite), the command fails with the invalid-value message (below) carrying `Float.toString(v)` (`NaN`, `Infinity`, `-Infinity`). Otherwise result r = floor(v x scale) as an int. Message: when `(float) r` equals v, the **exact** message with r; else the **rounded** message `command.compute.result.named.rounded` (id, v, r) / `.unnamed.rounded` (v, r). (The comparison is against the unscaled v, as read; so with scale 1 the exact message appears only for whole values, and `compute float 0.5 2` prints rounded with v 0.5 and r 1.)
- **Invalid:** an arithmetic exception while evaluating fails with `command.compute.result.named.invalid` (id, exception message) when named, `command.compute.result.unnamed.invalid` (message) when inline. These are command errors, so the result is 0 and there is no success output.
- The named forms print the provider id as a translation-style argument built from the identifier (rendered as the id text when no translation exists: inferred).

Worked examples: `compute integer cooking/time_coal` prints "<id> returned value N" with N the provider's value (25-1 §9) and returns N; `compute float 2.5` prints "Number provider returned value 2.5 (rounded to 2)" and returns 2; `compute float 3` prints "Number provider returned value 3" (the exact message carries the int r) and returns 3; `compute float 0.5 2` prints "... returned value 0.5 (rounded to 1)" and returns 1.

---

## 14. Server side of tab completion (Commands and Command Suggestions)

**Gap closed:** what the server does between a Command Suggestion request (05c 0x0F) and the Command Suggestions answer (05a 0x0F), and when it sends the Commands tree (T2014 fixtures). Source: `ServerGamePacketListenerImpl.handleCustomCommandSuggestions`, `ServerCommandSuggestionsProvider`, `ClientboundCommandSuggestionsPacket`, `PlayerList` (`placeNewPlayer`, `respawn`, `op`, `deop`, `sendPlayerPermissionLevel`), `Commands.sendCommands`.

### 14.1 Request handling

1. The handler keeps the request's transaction id and passes the text to the player's `ServerCommandSuggestionsProvider`. Each player has one provider and one slot for the **latest unprocessed request**.
2. A new request replaces the slot's content. A replaced request that was not yet processed is **dropped without any answer** (its id is never echoed: its pending answer is simply never completed, no cancel call exists). Only the newest request is answered. The same applies to a request being parsed: after the parse, if the slot has been refilled by a newer request, the current one is abandoned unanswered and the newer one is handled on a later tick.
3. Once per server tick (the budget is refilled every tick: the minimum interval is 1 tick) the provider takes the slot, so **at most one request per player is processed per tick**; a request arriving with budget available is scheduled on the server thread at once (executed at the next server task run), otherwise it waits for the next tick.
4. Processing: if the text starts with `/` that one character is skipped (the reader keeps the full text, so every range stays counted in the original text **including the slash**, as 09 says); the text is parsed by the command dispatcher with the player's own command source (so requirement predicates and permission levels filter what can be suggested: 15 framework); completion suggestions are then asked from the parse result at the end of the text (15a §6).
5. The result is capped at **1000** suggestions (the first 1000 of the sorted list; the range is kept). The text of each entry is the suggestion text; the tooltip is present only when the suggestion carries one.
6. The answer is Command Suggestions (0x0F) with the request's transaction id, Start and Length of the suggestions' range (`StringRange` start and length), and the entries in order. It is not sent when the connection no longer accepts messages (disconnected: the request is dropped). A parse or completion failure is logged and gives no answer.

Worked example: text `/gamemode s`, one request, budget available: range start 10 length 1 (the `s`), entries `spectator`, `survival` in the library's sorted order, id echoed. Two requests `/g` (id 1) and `/ga` (id 2) arriving within the same tick before processing: only id 2 is answered (start 1 length 2).

### 14.2 When the Commands tree is sent

Commands (0x10) is built per player: the dispatcher's root is copied keeping only the nodes the player's command source may use (requirement predicates evaluated for that player; children of a hidden node are hidden with it), then serialised (15 framework, 05a 0x10). It is sent: when the player joins (`placeNewPlayer`), after a respawn (`respawn`), and whenever the permission level is re-sent (`op`, `deop`, and the public `sendPlayerPermissionLevel`). Within the permission re-send the order is: when the player has a connection, an Entity Event (0x22 in 05a) on the player with status 24 + permission level (24 to 28, level 0 to 4) is sent first, then Commands. Before the player's first server tick the provider has no budget, so a request that early waits for that tick. No other trigger was found: among the classes of `net.minecraft.server.players`, `net.minecraft.commands` and the top-level `net.minecraft.server` / `server.commands` classes, only `PlayerList` calls `Commands.sendCommands` (a `/reload` path that re-sends the tree through the public permission re-send was not traced; see Open questions).

---

## 15. Data components: conventions, persistence table, enchantments (round cr5)

Gap closed: 00 §12.2 and 25-1 §7 name the component registry but not the per-type payloads. Sections 15 to 25 give them, in the priority order of the cr5 task. Section 15 holds the shared conventions, the persistence table of all 122 types, `enchantments`, `stored_enchantments` and `tooltip_display` (the 26.x replacement of the old per-component `show_in_tooltip` flag).

### 15.1 Conventions used by sections 15 to 25

| Term | Meaning |
|---|---|
| Component id | Position in the `data_component_type` registry (46 §8.1; ids re-checked in this round against the registration order of `DataComponents.<clinit>`, no difference). |
| Network layout | The component's `StreamCodec`, the bytes after the VarInt type id in 00 §12.2 / §12.3. Field order is the declaration order given in the tables. |
| NBT form | The `Codec` used when the stack is saved, i.e. the value under the key `<component id string>` in the stack's `components` compound (07 and 45-3 §4.1 give the patch syntax: key `minecraft:name`, or `!minecraft:name` for a removed default). All numeric widths below are the NBT tag type; an Int means `TAG_Int`. |
| Opt(x) | An optional field: absent from NBT when equal to the default x (the codec reads a missing key as x). On the network an optional field is a Boolean presence flag followed by the value (00 §6.6) unless the table says otherwise. |
| Unit | A component with no data. Network: zero bytes. NBT: an empty compound (`MapCodec.unitCodec`; any compound is accepted on load). |
| Identifier | String(32767) on the network (00 §3.2); NBT String with a namespace (a bare name is read as `minecraft:`). |
| RegistryId | VarInt registry position (00 §10.1). A `holderRegistry` codec is exactly this (a reference holder; no inline form). NBT: the entry's identifier string. |
| Holder | 00 §10.2: VarInt 0 followed by an inline value, or n > 0 for registry position n - 1. NBT: the identifier string, or an inline compound for those registries that allow it (said where it matters). |
| Text | Network: TextComponent NBT form (00 §9.1). NBT: the JSON-like component form (a String for plain text, a compound or list otherwise; `ComponentSerialization.CODEC`). |
| `cacheEncoding` | A server-side optimisation on the type (the encoded value is memoised). It does not change any byte. |
| Equality | Component values are compared by value equality of their record classes (field by field; collections element by element, `ItemEnchantments` as a map). Two stacks merge only if item and the whole effective component map are equal (17 §1.1, 13 §3.7). |

### 15.2 Persistence table: which types are saved and which are sent

Every type of 46 §8.1 has both an NBT codec and a network codec, except the nine below (read from the registration lambdas: the builder either lacks `persistent(...)` or lacks `networkSynchronized(...)`).

| Id | Key | Saved in NBT | Sent on the wire | Consequence |
|---|---|---|---|---|
| 20 | `creative_slot_lock` | no | yes (Unit) | Never written to disk; a client-side creative-inventory marker. |
| 42 | `additional_trade_cost` | no | yes (VarInt) | Transient; a merchant-screen overlay (40-5). |
| 50 | `map_post_processing` | no | yes | Transient enum (§24.3). |
| 22 | `intangible_projectile` | yes (Unit) | no | The client never sees it. |
| 49 | `map_decorations` | yes | no | Server-only; the client draws decorations from the map data packet. |
| 59 | `debug_stick_state` | yes | no | Server-only. |
| 68 | `recipes` | yes | no | Server-only. |
| 81 | `lock` | yes | no | Server-only. |
| 82 | `container_loot` | yes | no | Server-only. |

A type that is not sent must be stripped when a stack is written to a client (the patch simply omits it); a type that is not saved must be dropped when a stack is saved and is absent after a reload. A decoder that meets a non-persistent key in NBT fails the decode of that stack (45-3 §4.1 already states this for transient types).

### 15.3 `enchantments` (13) and `stored_enchantments` (45)

Both types share one value class (`ItemEnchantments`) and one codec; they differ only in meaning (an enchanted book keeps its enchantments in `stored_enchantments` and they do not act on the book).

| Aspect | Rule |
|---|---|
| Value | A map from enchantment (registry entry of `enchantment`) to a level. No duplicate keys; iteration order is the map's hash order and carries no meaning (the tooltip sorts, §15.5). |
| Network layout | VarInt count N, then N pairs: RegistryId of the enchantment (VarInt), VarInt level. No upper bound on N is checked by the codec. |
| NBT form | A compound whose keys are enchantment identifiers (`minecraft:sharpness`) and whose values are Int levels. Example: `{"minecraft:sharpness": 5, "minecraft:unbreaking": 3}`. There is no `levels` wrapper and no `show_in_tooltip` key in 26.3 (the old flag no longer exists; hiding is §15.4). |
| Level validation (NBT) | An Int from 1 to 255 inclusive (`Codec.intRange(1, 255)`); a value outside the range fails the decode of the component, and so does an unknown enchantment identifier. |
| Level validation (network and constructor) | The value-class constructor rejects any stored level below 0 or above 255 with an exception ("Enchantment ... has invalid level"); the network decoder builds the map first and then constructs, so an out-of-range level is a decode failure there too (inferred from the composite codec's construct step). A level of 0 is therefore accepted on the wire and rejected in NBT. |
| Default / prototype | `enchantments`: `ItemEnchantments.EMPTY` is in the common prototype of every item (25-1 §7.1), so a stack without the key has no enchantments. `stored_enchantments`: no default except that `enchanted_book` has `EMPTY` (25-6). |
| Empty value | Written as an empty compound when the component is present. A patch that sets `enchantments` to EMPTY is distinct from one that removes the component (a removed `enchantments` makes `getEnchantments` fall back to EMPTY too, so the two behave the same in play). |
| Edit operations (`ItemEnchantments.Mutable`) | `set(e, level)`: a level of 0 or less removes the entry, otherwise stores `min(level, 255)`. `upgrade(e, level)`: if level is greater than 0, stores the larger of the existing level and `min(level, 255)` (insert when absent); no-op for level 0 or less. `removeIf(pred)` drops matching entries. `getLevel` is 0 when absent. `toImmutable` freezes it. |
| Equality / stacking | Map equality (same keys, same levels). Two enchanted stacks merge only when equal. |
| Foil | `enchantments` non-empty gives the foil unless `enchantment_glint_override` decides otherwise (§19). `stored_enchantments` never gives foil by itself (the enchanted book has the override set to true). |

### 15.4 `tooltip_display` (18)

Replaces the pre-26 per-component `show_in_tooltip` Booleans. Common prototype value: `DEFAULT` = hide_tooltip false, hidden set empty (25-1 §7.1).

| Field | Network | NBT key | Default |
|---|---|---|---|
| hide_tooltip | Boolean | `hide_tooltip` Byte (0/1) | false |
| hidden_components | VarInt count, then RegistryId of `data_component_type` each (a linked set: order kept, duplicates collapse) | `hidden_components` List of component identifier Strings | empty |

Rule (`TooltipDisplay.shows(type)`): a component's tooltip lines are shown iff `hide_tooltip` is false and the type is not in the hidden set. This is the whole mechanism by which `enchantments`, `stored_enchantments`, `attribute_modifiers`, `dyed_color`, `trim`, `unbreakable`, `can_place_on`, `can_break`, `potion_contents` and the other tooltip-providing components are hidden. `withHidden(type, hidden)` adds or removes one type. Nothing about the glint or the stack's behaviour depends on this component, only on the tooltip text.

### 15.5 Enchantment tooltip order (for completeness)

Enchantment lines are written first for the enchantments in the data tag `#minecraft:tooltip_order` (in the tag's order, only those present with level above 0), then for the remaining enchantments in the map's iteration order. Each line is the enchantment's full name for that level (the enchantment's name with its level appended; the level text rules were not read in this round). No sort by level.

---

## Open questions

1. The zoglin's and the raider hold-ground goal's exact aggressive conditions (2.3) were not traced.
2. The ram-run-up distance ordering (7.1, "squared distance") and the camel `standUpInstantly` constant (6.4) remain as marked.

3. (cr4) Not read: the `ServerPlayer` cross-dimension override (9.2); the argument order of the sniffer dig-position lookup (12.2); `FeelingHappy` and `Scenting` internals (12.2); how a float provider's value is printed (Java float text assumed, 13.4); the message of integer arithmetic exceptions (13.4); whether `/reload` re-sends the Commands tree (14.2); `/test`, `/dialog show`, `/raid` failure keys and `/perf` report format (not traced; `/jfr` is a JVM profiler and not applicable).

Closed in review: the horizontal plane order is north, east, south, west (read from the plane's static initialiser; also in 24); the camel sitting dimensions are in 6.4.
