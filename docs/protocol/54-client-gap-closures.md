# 54. Client gap closures (walk animation, swing and aggressive pose, teleport permission, trades, variant ids, camel, goat, data component layouts)

| Item | Value |
|---|---|
| Covers | Gaps recorded on task lines of `specs/002-client-polish/tasks.md` and in lane reports: the walk animation update and its feeds (§1), the swing and aggressive-pose drivers (§2), `/tp` location-form permission (§3), villager trade enchantment data and tag members (§4), registry order of metadata variants (§5), camel dash and sit (§6), goat ram (§7), remaining item and tag lists (§8); round cr4: teleport dimension and coordinates (§9), playsound range (§10), saturation instance (§11), spawn-reason light and sniffer dig cadence (§12), `/compute` (§13), tab-completion server side (§14); round cr5, data component wire and NBT layouts: persistence table and enchantments (§15); potion_contents and effect instances (§16); dyed_color (§17); trim (§18); glint and foil (§19); names, lore, rarity (§20); fireworks (§21); banners, omen bottle (§22); durability and stack components (§23); food, consumable, remainder, cooldown, stew (§24); containers and blobs (§25); maps, instruments, books, profile, attributes, tool, equippable (§26) |
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

Every type of 46 §8.1 has both an NBT codec and a network codec, except the ten below (read from the registration lambdas: the builder either lacks `persistent(...)` or lacks `networkSynchronized(...)`; re-read by the reviewer for all 122 registrations, and `custom_data` was the one missing from the reader's list).

| Id | Key | Saved in NBT | Sent on the wire | Consequence |
|---|---|---|---|---|
| 20 | `creative_slot_lock` | no | yes (Unit) | Never written to disk; a client-side creative-inventory marker. |
| 42 | `additional_trade_cost` | no | yes (VarInt) | Transient; a merchant-screen overlay (40-5). |
| 50 | `map_post_processing` | no | yes | Transient enum (§26.1). |
| 22 | `intangible_projectile` | yes (Unit) | no | The client never sees it. |
| 0 | `custom_data` | yes | no | Server-only. The network codec of `CustomData` exists (§25.5) but this registration does not use it, so a stack sent to a client carries no `custom_data` patch entry (the client cannot read it back; `bucket_entity_data`, id 61, is different: persistent and sent). |
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

Enchantment lines are written first for the enchantments in the data tag `#minecraft:tooltip_order` (in the tag's order, only those present with level above 0), then for the remaining enchantments in the map's iteration order. Each line is the enchantment's full name for that level (`Enchantment.getFullname`: the enchantment's description text in red when the enchantment is in the tag `#minecraft:curse` (binding and vanishing curse), otherwise gray; then, unless the level is 1 and the enchantment's maximum level is 1, a space and the translatable key `enchantment.level.<level>`, which `en_us` defines for 1 to 10 only (`I` to `X`), so level 11 and above show the raw key text). No sort by level.

---

## 16. `potion_contents` (53), `potion_duration_scale` (54) and the mob effect instance layouts

Gap closed: 25-5 §9 gives the behaviour of `PotionContents` (colour, name key, application, the 46 potions with their effects, effect colours) and says the layouts are a composite of four fields without field-level detail. This section gives the exact network and NBT layouts, including the effect instance record that `custom_effects` (and the suspicious stew, §23, and the consume effects, §22) reuse. The potion list itself is 25-5 §9.3 (registry ids in 46 §4.3); the effect list for each potion was spot-checked against the artifact in this round (all duration and amplifier numbers for night_vision, invisibility, leaping, fire_resistance, swiftness, slowness, turtle_master, water_breathing, healing, harming, poison, regeneration, strength, weakness, luck, slow_falling, wind_charged, weaving, oozing and infested agree; water, mundane, thick and awkward have no effect).

### 16.1 `potion_contents` (53)

| # | Field | Network | NBT key and form | Default / absent |
|---|---|---|---|---|
| 1 | potion | Optional (Boolean flag, then RegistryId of `potion`) | `potion` String, a potion identifier such as `minecraft:strong_healing` | absent |
| 2 | custom_color | Optional (Boolean flag, then Int, 4 bytes big-endian, not VarInt) | `custom_color` Int (ARGB as a signed 32-bit integer; for example `-13083194`) | absent |
| 3 | custom_effects | VarInt count, then count mob effect instances (§16.2) | `custom_effects` List of compounds (§16.2) | empty list (key omitted when empty on read: the codec reads a missing key as an empty list) |
| 4 | custom_name | Optional (Boolean flag, then String(32767)) | `custom_name` String | absent |

- **Shorthand on load:** the component codec first tries the compound form; if that fails it accepts a bare potion identifier String and builds a contents with only that potion (`new PotionContents(holder)`). Saving always writes the compound form. A compound with every key missing decodes to the empty contents.
- **Empty value** (`EMPTY`): all four fields absent. The `potion` item prototype is empty (25-5 §9.2); stacks created by `/give` or the creative tab carry the potion `water`.
- **Colour fields:** `custom_color` is an ARGB int. The colour used for drawing the potion item tint, the liquid in a cauldron and the particles is `getColor` of 25-5 §9.1 (the alpha byte of a `custom_color` is kept as stored; the weighted-effect colour is opaque).
- **`custom_name`** is not a text component but the last segment of the language key `<item description id>.effect.<custom_name>` (25-5 §9.1), for example the string `awkward` selects `item.minecraft.potion.effect.awkward`. Maximum length 32767 characters on the network (String codec bound, 00 §3.1).
- **Equality:** field-wise equality (potion holder, colour, list of instances in order, name). Two potions with the same potion and different custom effect order do not stack.
- **`isPotionWithoutCustomEffects`** (used by cauldron and brewing checks, 25-5 §9.1) is true when custom effects is empty.
- No validation limit exists on the number of custom effects or on the colour.

### 16.2 Mob effect instance (`MobEffectInstance.STREAM_CODEC` and `MobEffectInstance.CODEC`)

Used by `potion_contents.custom_effects`, `suspicious_stew_effects` (§24.3, as a different record), the `apply_effects` consume effect (§24.2) and saved entity effects. The record is the effect id followed by a nested "details" record.

| # | Field | Network | NBT key and form | Default (NBT) |
|---|---|---|---|---|
| 1 | effect | RegistryId of `mob_effect` (VarInt; a reference holder, no inline form) | `id` String (effect identifier, required) | required |
| 2 | amplifier | VarInt | `amplifier` Byte (an unsigned byte, 0 to 255; the codec is the unsigned-byte codec) | 0 |
| 3 | duration | VarInt (ticks; `-1` = infinite) | `duration` Int | 0 |
| 4 | ambient | Boolean | `ambient` Boolean | false |
| 5 | show_particles (the "visible" flag) | Boolean | `show_particles` Boolean | true |
| 6 | show_icon | Boolean | `show_icon` Boolean | **the value of show_particles** when the key is absent (read in `Details.create`) |
| 7 | hidden_effect | Optional details (Boolean flag, then fields 2 to 7 again, recursively) | `hidden_effect` Compound with keys 2 to 7 and `hidden_effect` again (recursive); absent when none | absent |

Notes:

- Field order on the wire is exactly the order of the table: effect id, then amplifier, duration, ambient, show_particles, show_icon, then the optional hidden effect. The hidden effect has no effect id of its own (it belongs to the same effect: it is the weaker previous instance that comes back when the stronger one expires).
- `INFINITE_DURATION` = -1. A duration of 0 is legal (an instant effect uses 1 in the potion table; `new MobEffectInstance(effect)` with no duration has duration 0).
- Constructors used by the potion table: (effect, duration) has amplifier 0, ambient false, visible true, icon true; (effect, duration, amplifier) the same with the amplifier.
- Effect duration scaling used by the potion duration scale (§16.3): scaled duration = `max(floor(duration * scale), 1)` (25-5 §9.1).
- Equality of instances is by value (effect, the details), including the hidden effect.

### 16.3 `potion_duration_scale` (54)

| Aspect | Value |
|---|---|
| Network | Float (4 bytes big-endian) |
| NBT | Float; the codec requires a value `>= 0.0` (a negative value fails the decode) |
| Default | absent = 1.0 where the consumer reads it with a default of 1.0 (`PotionContents.onConsume`, 25-5 §9.1) |
| Values in the item data | splash potion 1.0, lingering potion 0.25, tipped arrow 0.125 (17 §1.2 and 25-5 §9.2) |
| Behaviour | Multiplies the duration of every effect applied from the stack's `potion_contents` (not instant effects' amplifier, only their duration through the 25-5 rule); the display tooltip uses the same scale. It does not change the colour. |

### 16.4 Worked example

A tipped arrow for `strong_harming`: patch added entries `53 potion_contents` with network bytes `01 <VarInt registry id of strong_harming>` (potion present), `00` (no custom colour), `00` (no custom effects), `00` (no custom name), then `54 potion_duration_scale` with Float `0.125` (`3E 00 00 00`). A custom-effect potion with one effect `regeneration` amplifier 1 for 450 ticks, particles shown: after the potion field (`00`) and colour field (`00`): VarInt 1, VarInt effect id, VarInt 1, VarInt 450 (`C2 03`), Boolean 0, Boolean 1, Boolean 1, Boolean 0 (no hidden effect), then `00` for the name.

---

## 17. `dyed_color` (47) and the `dye` component (46)

Gap closed: 43 §7.4 gives the mixing formula and 43 §7 the tint use; this section gives the layouts, the accepted NBT forms and the constants.

| Aspect | `dyed_color` (47) |
|---|---|
| Value | A record with one field `rgb` (an Int). The tooltip-only `show_in_tooltip` flag of earlier versions does not exist in 26.3 (hiding the tooltip line is §15.4). |
| Network | Int, 4 bytes big-endian (not VarInt): the stored `rgb` value. Nothing else. |
| NBT | Int holding the colour. Accepted forms on load: an Int (taken as is), or a List of 3 Floats `[r, g, b]` in 0.0 to 1.0 which is converted to an opaque ARGB int. Saving always writes the Int. The value is not masked or range checked. |
| Meaning of the stored int | Only the red, green and blue bytes are used. Mixing (43 §7.4) writes alpha 0; vanilla data and commands may store an opaque value (alpha 255, a negative Int); both behave the same because every reader applies `ARGB.opaque(rgb)` (43 §7, `DyedItemColor.getOrDefault`). A stored value of `0` is a real colour (black), not "undyed". |
| Default | none: the component is absent on an undyed item. The renderer's fallback for an undyed leather piece is `LEATHER_COLOR` = `-6265536` = `0xFFA06540` (brown), used by the tint sources through `color_when_undyed` (43 §7). |
| Equality | `rgb` equality. Two leather armour pieces stack-merge only with the same stored int, so an alpha-0 and an alpha-255 encoding of the same colour are different component values. |
| Tooltip (not needed for the store) | Shows the colour as `#RRGGBB` (format `#%06X` of the low 24 bits) when advanced tooltips are on, else the translatable `item.dyed`. |
| Mixing | `DyedItemColor.applyDyes(stack, dyes)` returns a copy of the stack with `dyed_color` set to the 43 §7.4 result (stack and the plain-component forms exist; the stack form also requires nothing else). Used by the crafting recipe (27) and the cauldron wash (29b-7, which removes the component). |

The `dye` component (46) is a different thing: a bare `DyeColor` for dye items. Network: VarInt id of the dye colour (the enum order of 43 §8, ids 0 to 15, an id-enum codec); NBT: String with the dye name (`white`, `orange`, ... `black`). No default; an item that is a dye carries it in its prototype (25-4).

---

## 18. `trim` (58), `provides_trim_material` (64), the trim registries and how a trim is drawn

Gap closed: 04 §6 has the registry file schemas, 25-4 §5 the material items (with the layout of `provides_trim_material` "not read") and 34-2 §4 (item 6) the worn-armour drawing steps; the palette mechanism is in 14 §7.4. This section gives the component layouts, the full contents of the two registries (data files of the jar), the palette image contents and the recolouring and override rules, so that the models lane can draw a trim without reading anything else.

### 18.1 Layouts

| Component | Network | NBT form | Notes |
|---|---|---|---|
| `trim` (58), record `ArmorTrim` | Holder of `trim_material` (00 §10.2: VarInt 0 plus the inline material of the next table, or registry position + 1), **then** Holder of `trim_pattern` (same rule). Material first, pattern second. | Compound `{material: <id>, pattern: <id>}`, both required. Each value is the holder codec of a data-driven registry: a String identifier (`minecraft:gold`, `minecraft:wild`) for a registered entry, or an inline compound of the entry's own schema (the reader accepts both; the writer writes the identifier for a registered holder). | No default; the component is absent on an untrimmed item. The `show_in_tooltip` flag of 1.20 does not exist in 26.3 (hiding is 15.4 `hidden_components`). Equality: both holders equal. |
| `provides_trim_material` (64), value `TrimMaterial` holder | Holder of `trim_material` (as above) | String identifier, or inline `{palette_id, description}` | Set on the nine ingots and gems of 25-4 plus `redstone` and `resin_brick` (25-3 §5.5); a smithing table reads it from the material slot item. |
| inline `TrimMaterial` (network `DIRECT_STREAM_CODEC`) | Identifier `palette_id`, then TextComponent `description` | `palette_id` String (required), `description` text component (required) | **Exactly two fields in 26.3.** There is no `asset_name`, no `ingredient`, no `item_model_index` and no per-armour-material `override_armor_materials` map; the "darker" colour variant is a client-side rule (18.4). |
| inline `TrimPattern` (network `DIRECT_STREAM_CODEC`) | Identifier `asset_id`, TextComponent `description`, Boolean `decal` | `asset_id` String (required), `description` (required), `decal` Boolean, default false and always written | No template item or ingredient field (the link from a template item to its pattern is not in the registry entry; see 40-3). |

### 18.2 `trim_material` registry contents (11 entries, `data/minecraft/trim_material/<name>.json` in the artifact; registry ids are assigned in the order the registry is synchronised, 04 and 46; the registry loader sorts the entries by identifier before registering them, so the alphabetical order of the table is the id order, read)

All entries have the same shape (`palette_id`, `description` = a translatable component with a colour and key `trim_material.minecraft.<name>`). Values read from the files:

| name | `palette_id` (texture file `textures/palettes/trim/<n>.png`) | description colour (text colour of the tooltip line) |
|---|---|---|
| amethyst | `minecraft:trim/amethyst` | `#9A5CC6` |
| copper | `minecraft:trim/copper` | `#B4684D` |
| diamond | `minecraft:trim/diamond` | `#6EECD2` |
| emerald | `minecraft:trim/emerald` | `#11A036` |
| gold | `minecraft:trim/gold` | `#DEB12D` |
| iron | `minecraft:trim/iron` | `#ECECEC` |
| lapis | `minecraft:trim/lapis` | `#416E97` |
| netherite | `minecraft:trim/netherite` | `#625859` |
| quartz | `minecraft:trim/quartz` | `#E3D4C4` |
| redstone | `minecraft:trim/redstone` | `#971607` |
| resin | `minecraft:trim/resin` | `#FC7812` |

### 18.3 `trim_pattern` registry contents (18 entries, `data/minecraft/trim_pattern/<name>.json`)

Entries: `bolt`, `coast`, `dune`, `eye`, `flow`, `host`, `raiser`, `rib`, `sentry`, `shaper`, `silence`, `snout`, `spire`, `tide`, `vex`, `ward`, `wayfinder`, `wild`. Every entry has `asset_id` = `minecraft:<name>`, `decal` = **false**, `description` = translatable `trim_pattern.minecraft.<name>` (no colour). The worn-armour texture of a pattern is `textures/trims/entity/<layer type>/<name>.png` for the layer types `humanoid` (64 x 32 here; an armour-body sheet) and `humanoid_leggings`, each with a `.mcmeta` naming the key palette `trim_base`. 

### 18.4 Rendering rule (worn armour, and the same palettes for item icons)

1. **Key palette** (`textures/palettes/trim_base.png`, 8 x 1 pixels, left to right): `E0E0E0 C0C0C0 A0A0A0 808080 606060 404040 202020 000000`. A trim pattern texture is drawn in these eight greys only (read in `bolt.png`: the pixels are `A0A0A0`, `808080`, `C0C0C0` and `606060`, with alpha 255, the rest transparent).
2. **Palette selection.** The palette id is the material's `palette_id`, unless the equipment asset of the worn piece (the asset the armour item names, 22/34) has a `trim_overrides` list: its entries are tried in order and the first whose `when` matches the trim (`when` has `material` and/or `pattern`, at least one) replaces the palette (`palette`) and/or the pattern texture (`texture`), at least one of the two being given. In the 26.3 assets only five equipment assets have an override and each has one entry replacing the palette by the `_darker` variant when the trim material equals the armour's own material:

| Equipment asset (armour material) | Override `when.material` | Palette used instead |
|---|---|---|
| `iron` | `minecraft:iron` | `minecraft:trim/iron_darker` |
| `copper` | `minecraft:copper` | `minecraft:trim/copper_darker` |
| `gold` | `minecraft:gold` | `minecraft:trim/gold_darker` |
| `diamond` | `minecraft:diamond` | `minecraft:trim/diamond_darker` |
| `netherite` | `minecraft:netherite` | `minecraft:trim/netherite_darker` |

   Armour made of `leather`, `chainmail`, `turtle_scute`, `armadillo_scute` has no override, so a trim of any material uses the material's normal palette. The item-icon overlays use the same eleven normal palettes plus the five `_darker` ones through the items atlas (`paletted_permutations` with key `trim_base`, 14 §7.4), and the item models do choose it (read): each armour item's model (`assets/minecraft/items/<armour item>.json`) is a select on the item property `minecraft:trim_material` with one case per material, each naming a model whose second layer texture is `trims/items/<piece>_trim_<material>` (piece `helmet`, `chestplate`, `leggings`, `boots`), and the model of the armour's own material uses the `<material>_darker` texture instead (20 models: iron, golden (gold), diamond, netherite and copper armour, four pieces each, with the same-named trim); every other pairing and leather and chainmail use the plain texture. The items atlas builds those 16 permutations from the four `trims/items/<piece>_trim` greys with the key palette (14 §7.4).
3. **Texture path.** `textures/trims/entity/<layer type name>/<pattern asset path>.png` (the layer type names are `humanoid`, `humanoid_leggings`, `humanoid_baby`, ...; the layer type `humanoid_baby` has no trim, 34-2), unless the override gave a texture id (then that id's path is used with the same prefix).
4. **Recolouring** (done once per pair of texture and palette, then cached): the two palettes must have the same number of colours (8; a mismatch is an error). A mapping is built from each opaque-able entry of the key palette (alpha not 0) to the colour at the same index of the chosen palette. For every pixel of the pattern texture: if its alpha is 0 the pixel is left unchanged; otherwise its RGB (forced opaque) is looked up in the mapping; a colour not in the mapping stays as it is (inferred: the default of the lookup is the input colour); the output alpha is `pixelAlpha * paletteColorAlpha / 255`, the palette colours being opaque.
5. **Order and render type** are in 34-2 §4 item 6 (after the base layers, render type `armorTrim` with the pattern's `decal` flag, then once more with `trimmedArmorGlint` if the stack has the foil, 19.3).

### 18.5 The 16 palette images (`textures/palettes/trim/<name>.png`, all 8 x 1, left to right, RGB hex)

| Palette | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| amethyst | C98FF3 | 9A5CC6 | 6C49AA | 523687 | 422776 | 361C6A | 240C53 | 17063B |
| copper | E3826C | B4684D | 9A472C | 793C28 | 6D3420 | 5F2B18 | 4C2010 | 3D180B |
| copper_darker | 7B4135 | 6B3628 | 592A19 | 4C2416 | 401E11 | 36190F | 29140C | 1B0E08 |
| diamond | CBFFF5 | 6EECD2 | 2CBAA8 | 1D969A | 0C788D | 076578 | 04515F | 013C47 |
| diamond_darker | 15B3A1 | 0A9CA1 | 048185 | 027472 | 065D5B | 095148 | 034642 | 04403E |
| emerald | 82F6AD | 0EC754 | 11A036 | 107B24 | 0E7222 | 09631B | 035013 | 023D0E |
| gold | FFFD90 | ECD93F | DEB12D | B16712 | A0450A | 803503 | 712D00 | 572300 |
| gold_darker | C29C2A | BA8327 | A35F14 | 89470C | 803503 | 712D00 | 572300 | 3E1B03 |
| iron | C5D2D4 | BFC9C8 | 9DAAAA | 7B8989 | 717D7D | 657070 | 576363 | 465151 |
| iron_darker | A2B0B3 | 8A9291 | 6F7676 | 576363 | 3D4949 | 313B3B | 2B3434 | 1D2828 |
| lapis | 416E97 | 1C4D9C | 21497B | 123365 | 112E63 | 0C285A | 091E45 | 051636 |
| netherite | 5A575A | 443A3B | 312E31 | 2F2727 | 231E1E | 1A1616 | 100C0C | 090707 |
| netherite_darker | 2E2829 | 282425 | 281D1D | 241A1A | 1F1717 | 1D1313 | 140F0F | 0B0909 |
| quartz | F2EFED | F6EADF | E3DBC4 | B6AD96 | 908E80 | 656156 | 45433C | 2A2822 |
| redstone | E62008 | BD2008 | 971607 | 781101 | 650B01 | 520D06 | 360803 | 1D0502 |
| resin | FFC354 | F69F3B | F0852A | EC7214 | DB5F10 | C7490A | A53B11 | 802A1A |

All pixels opaque. Worked example: a pixel `A0A0A0` (key index 3) of a `wild` texture on a gold trim over diamond armour becomes `DEB12D` (gold palette index 3); on gold armour with a gold trim it becomes `A35F14` (`gold_darker` index 3); a `606060` pixel (index 5, counting from 1 as the table columns do) becomes `A0450A` on gold and `803503` on gold_darker (column 5 of each row).

### 18.6 Apply rules (where they live)

The smithing table result (template + armour + material) and the template tooltips are in 40-3; the stack's `trim` is set to the material found through `provides_trim_material` of the addition slot and the pattern of the template. The creative and recipe-display forms use the `smithing_trim` slot display (05a, with an inline `trim_pattern` holder).

---

## 19. `enchantment_glint_override` (21) and the foil rule: when the glint is drawn and what it looks like

Gap closed: 12 §8.3 states the texture transform and fade constants and describes the glint as a second additive pass; this section adds the component layout, the exact decision of whether a stack has the glint, which drawing paths exist in 26.3 (the item shaders add the glint in the same pass; only armour trims and patterned shields use a separate pass) and the glint-UV rule of the animated items.

### 19.1 The component

| Aspect | Value |
|---|---|
| Id, type | 21, `enchantment_glint_override` |
| Network | Boolean |
| NBT | Boolean (a Byte 0/1) |
| Default | absent. (25-6 lists the items whose prototype carries `true`: enchanted golden apple, experience bottle, written book, nether star, enchanted book, end crystal, debug stick.) |
| Equality | Boolean equality; an explicit `false` is a real value that differs from absence. |

### 19.2 The foil decision (`ItemStack.hasFoil`)

1. If the stack has `enchantment_glint_override`, its value is the answer (`false` suppresses the glint of an enchanted item; `true` forces it).
2. Otherwise the answer is `Item.isFoil(stack)`: for every item class this is "the `enchantments` component is non-empty" (`ItemStack.isEnchanted`), with one override: the compass class (`CompassItem`) is also foil when the stack has a `lodestone_tracker` component (25-5, any value of the component, enchanted or not; there is no AND with the enchantments).
3. `stored_enchantments`, `potion_contents`, `trim`, rarity and the `enchantable` component do not give foil. Potions have no glint in 26.3 (no override in the potion class or its prototype).
4. The decision is made at draw time from the stack; it is not stored. The tooltip name colour uses the rarity component (default `common`), raised when the stack is enchanted (`enchantments` non-empty, independent of the override): `common` and `uncommon` become `rare`, `rare` becomes `epic`, `epic` stays `epic` (`ItemStack.getRarity`).

### 19.3 Where the glint is drawn

| Case | Behaviour |
|---|---|
| Item models (inventory slot, hand, item frame, dropped item, shelf) | The item's quads are drawn once with a pipeline that has the `GLINT` shader define: after the base colour has been multiplied by the lightmap (and the damage-flash overlay mixed in), the shader adds the glint and then applies fog. The added term per colour channel is `(GlintAlpha * g)^2`, where `g` is the glint texture sample and `GlintAlpha` the "glint strength" option (12 §8.3 and 13: default 0.75, range 0 to 1). This equals the additive blend source colour times source colour that 12 §8.3 describes (the shader comment says it matches the GLINT blend function). In the shader `core/item` (both stages read), with the `GLINT` define the fragment's alpha is also raised to at least `GlintAlpha` (default 0.75) right after the cutout test and the multiplication by the vertex colour and `ColorModulator`, before the lightmap and the glint term. The item pipelines, cutout and translucent alike (`ITEM_CUTOUT_GLINT`, `ITEM_CUTOUT_GLINT_SPECIAL`, `ITEM_TRANSLUCENT_GLINT`, `ITEM_TRANSLUCENT_GLINT_SPECIAL`), all define `ALPHA_CUTOUT` 0.1 and discard alpha below 0.1 first, so a foil item's texels with alpha between 0.1 and `GlintAlpha` are drawn with alpha `GlintAlpha`. |
| Texture and transform for items | `textures/misc/enchanted_glint_item.png` (128 x 128 RGB, with the `blur` texture flag set), sampled through the texture matrix `GLINT_TEXTURING` = `setupGlintTexturing(8.0)` of 12 §8.3 (scroll speed from the "glint speed" option, rotation 10 degrees, scale 8). |
| Entity models drawn with a solid-entity pipeline (for example a held item shown through an entity render type) | The entity shader adds the same `(GlintAlpha * g)^2` and additionally forces the output alpha to at least `GlintAlpha`; the texture matrix is `setupGlintTexturing(0.16)` (`ENTITY_GLINT_TEXTURING`). |
| Armour (the first base layer, only when the stack has the foil **and no trim**) | Render type `armorCutoutNoCullGlint`: texture `textures/misc/enchanted_glint_armor.png` (128 x 128, `blur` flag set), texture matrix `setupGlintTexturing(0.5)` (`ARMOR_ENTITY_GLINT_TEXTURING`). |
| Armour with a trim | The base layers are drawn without the glint. After the trim layer (18.4), a separate pass with render type `trimmedArmorGlint` draws the whole armour model again with the plain `GLINT` pipeline (additive, as 12 §8.3), the armour glint texture, texture matrix scale 0.5, and a small view-space Z offset so it lies over the trim. This pass is made only when the stack has the foil and a trim. |
| Patterned shield (banner on a shield) | One extra pass `patterned_shield_glint` with the plain `GLINT` pipeline, the item glint texture and the entity matrix (scale 0.16). |
| Two foil kinds for item models | `CuboidItemModelWrapper.update`: when the stack has the foil (19.2) the layer's foil type is SPECIAL if `hasSpecialAnimatedTexture` holds, else STANDARD; with no foil it stays NONE. `hasSpecialAnimatedTexture` = the stack is in the item tag `compasses` (read: exactly `minecraft:compass` and `minecraft:recovery_compass`) or is `minecraft:clock`. `SpecialModelWrapper` (block-entity style and other code-drawn models) sets STANDARD when the stack has the foil, else NONE. A foil stack also marks its render state `animated` (so the GUI does not reuse a cached cell for it, 12 8.1). The reason for SPECIAL is the item definitions of 19.3.2: these three items change model every frame instead of animating one sprite |
| SPECIAL glint coordinates | Per-vertex coordinate `UV3`, not the item texture coordinate; the full rule (projection, unit, decal-pose factor per display context, worked values) is in 19.3.1 |
| Translucent items | The translucent item pipelines have the same two variants (`item_translucent_glint`, `item_translucent_glint_special`) and the same shader term; the order-independent-transparency variants use the same define. |
| Item entities and GUI | Use the same item-model path (above); the glint is drawn whenever `hasFoil` is true for the stack. In the inventory screen it uses the same pipelines. |

#### 19.3.1 The SPECIAL glint coordinate (compass, recovery compass, clock)

Read: `ItemFeatureRenderer.prepareMainSubmit` and `computeFoilDecalPose`, `VertexConsumer.putBakedQuadWithGlint`, `SheetedDecalTextureGenerator.setSheetedDecalUv`, `MatrixUtil.mulComponentWise`, `FaceBakery.bakeVertex`, `ItemModelGenerator`, `Direction.getRotation`, `ItemDisplayContext.firstPerson`, the shaders `core/item.vsh` and `core/item.fsh`, the pipelines `ITEM_CUTOUT_GLINT_SPECIAL` and `ITEM_TRANSLUCENT_GLINT_SPECIAL` (shader `core/item`, define `GLINT` plus `GLINT_SPECIAL`, vertex format `ENTITY_GLINT_SPECIAL` = Position, Color, UV0, UV1, UV2, **UV3** (two floats), Normal), and the three item definitions (`items/compass.json`, `recovery_compass.json`, `clock.json`).

**Per quad.** A layer with foil type SPECIAL draws each quad through the quad's `itemGlintSpecialRenderType` (or the translucent counterpart) with `putBakedQuadWithGlint(pose, quad, colours, decalPose)`. For each of the four vertices: the vertex is emitted as for a normal item quad (position = item pose times the quad's own vertex position; normal = pose normal matrix times the face direction; colour, UV0, overlay, light as usual) and then its `UV3` is set from the **decal pose** `D`, a copy of the item pose `P` (the pose of this layer: display transform and local transform included) whose 4 x 4 matrix is modified by `computeFoilDecalPose` as follows.

| Display context of the submit | Decal pose `D` | Factor `f` |
|---|---|---|
| `GUI` | every one of the 16 entries of `P`'s matrix multiplied by 0.5 (`mulComponentWise`: the translation column and the last row too; the normal matrix is not scaled) | 0.5 |
| `FIRST_PERSON_LEFT_HAND`, `FIRST_PERSON_RIGHT_HAND` (`firstPerson()`) | the same with 0.75 | 0.75 |
| every other context (`THIRD_PERSON_LEFT_HAND`, `THIRD_PERSON_RIGHT_HAND`, `HEAD`, `GROUND`, `FIXED`, `ON_SHELF`, `NONE`): a mob's hand, a dropped item, an item frame, a shelf, a head slot | an unmodified copy of `P` | 1 |

**`UV3` of a vertex.** Let `pos` be the vertex's own coordinates in the baked quad (**blocks**: the baker divides the model's 0 to 16 coordinates by 16, so a 16-pixel face spans 1.0 and the generated item models of the clock and compasses span x and y from 0 to 1 and z from 7.5/16 = 0.46875 (back) to 8.5/16 = 0.53125 (front)), and `d` the quad's own face direction. The generator is called with the vertex already transformed by `P`; it takes that point through the inverse of `D`'s matrix (a position transform that ignores the last row and does not divide by w) and the quad's transformed normal through the inverse of `D`'s normal matrix (to recover the face direction `d`, the nearest of the six directions). Because `D` = `f` times `P` entry by entry, the result is the quad's own `pos` divided by `f` (inferred: the inverse of a matrix whose entries were all multiplied by `f` is the inverse of `P` divided by `f`, and the position transform of `pos` carried through `P` returns `pos`; JOML is not in the artifact, 34-3 Open question 1, so the exact handling of the translation column for `f` other than 1 is (inferred), see Open question 5; for `f` = 1 no inference is needed: the result is `pos` itself). So **the glint coordinate does not depend on the pose, the animation frame, the model chosen by the item definition or the sprite**: only on the quad's geometry and `f`. With `p = pos / f`, the point is rotated by: Y by pi, then X by -pi/2, then by the quaternion of `d` (`Direction.getRotation`: DOWN rotation about X by pi; UP none; NORTH `rotationXYZ(pi/2, 0, pi)`; SOUTH about X by pi/2; WEST `rotationXYZ(pi/2, 0, pi/2)`; EAST `rotationXYZ(pi/2, 0, -pi/2)`), and `UV3 = (-x', -y') / 128` of the rotated point `(x', y', z')`. Reduced to a table (assuming right-handed rotations and the XYZ order that applies Z first, which maps each direction's quaternion `UP` to `d`; inferred), with `p = (x, y, z)`:

| Face direction `d` of the quad | `UV3` (before the texture matrix) |
|---|---|
| SOUTH (the front face of a generated item) | `(x, -y) / (128 f)` |
| NORTH (its back face) | `(-x, -y) / (128 f)` |
| UP (the 1-pixel side strips) | `(x, z) / (128 f)` |
| DOWN | `(x, -z) / (128 f)` |
| WEST | `(-z, -y) / (128 f)` |
| EAST | `(z, -y) / (128 f)` |

(The vertex shader then computes the glint texture coordinate as the texture matrix of 19.3 (`TextureMat`: translate by the scroll offset, rotate Z by 10 degrees, scale 8) applied to `(UV3, 0, 1)`; the fragment shader samples the glint texture there and adds `(GlintAlpha * rgb)^2` as in the first row. The WEST and EAST rows have the opposite handedness of the others: the rotated face normal ends on +z for them and on -z for the rest, so the pattern is mirrored on those two faces; the artifact does this, and it matters only for the strips at a sprite's left and right edges.)

**Worked values.** The front face of a compass or clock model (`item/generated`, 16 x 16 sprite, direction SOUTH, z = 0.53125) has the corners `pos` = (0,0), (1,0), (1,1), (0,1) in (x, y). Dropped item, item frame, mob hand, shelf or head (`f` = 1): `UV3` = (0, 0), (1/128, 0), (1/128, -1/128), (0, -1/128), i.e. the whole face spans 1/128 = 0.0078125 in each axis; after the scale of 8 in the texture matrix that is 0.0625 of the glint texture (8 texels of 128) per face. In the GUI (`f` = 0.5): (0,0), (1/64, 0), (1/64, -1/64), (0, -1/64): 0.125 of the texture (16 texels). First-person hand (`f` = 0.75): 1/96 per axis, 1/12 = 0.0833 of the texture (10.7 texels). The back face (NORTH) of the same model, `f` = 1: corners (0,0), (-1/128, 0), (-1/128, -1/128), (0, -1/128): the same size, mirrored in u. A side strip of the sprite's top edge (UP, one pixel wide, `pos` = (x, 1, z) for x in 0..1 and z from 0.46875 to 0.53125): `UV3` = (x, z) / 128, so it spans u in 0 to 1/128 and v in 0.46875/128 to 0.53125/128. Because `UV3` ignores the pose and the sprite, the glint pattern stays continuous when the item definition swaps the model from one frame to the next; only the time-based offset of the texture matrix moves it.

#### 19.3.2 The compass, recovery compass and clock models

The animation of these items is not a sprite animation: none of the textures `textures/item/compass_NN.png` (32 files, `NN` 00 to 31), `recovery_compass_NN.png` (32) and `clock_NN.png` (64) has a `.mcmeta` file (0 of 128), and every model (`models/item/compass_NN.json`, `recovery_compass_NN.json`, `clock_NN.json`) is the one-layer form `{parent: item/generated, textures: {layer0: that sprite}}` (so the quads are the extruded sprite of `ItemModelGenerator`: a SOUTH and a NORTH face plus the side strips, 19.3.1). The item definitions pick one model per frame: `compass` (a `condition` on `has_component` `lodestone_tracker`, both branches a `range_dispatch` on `minecraft:compass`, scale 32, 33 entries over the same 32 models, target `lodestone` when the component is present and `spawn` when not), `recovery_compass` (the same, target `recovery`) and `clock` (a `select` on `context_dimension`, the overworld and the fallback each a `range_dispatch` on `minecraft:time`, scale 64, 65 entries over the 64 models, source `daytime` or `random`); the selection rules are in 58 3.10 and 3.11. This is why the glint of these items cannot use the item texture coordinate (it would jump with each model swap) and uses the geometry-based `UV3` of 19.3.1.

**Does the lodestone compass differ?** Not in the glint drawing. It is the same item `compass` (tag `compasses`, so SPECIAL), it uses the same 32 models as the spawn-pointing compass (the two branches list the same model names), and its glint is decided by the same `hasFoil`: a compass with a `lodestone_tracker` component of any value has the foil unless `enchantment_glint_override` is `false` (the foil test of the compass class is an OR, 19.2 item 2: the tracker component is present, OR the base rule holds, i.e. the stack is enchanted; so the tracker alone is enough and enchantments are not needed); the plain compass without a tracker, the recovery compass and the clock have the foil only when enchanted or when the override is `true`, and then they glint as SPECIAL too. The only difference between a lodestone compass and a spawn compass is therefore that the first one always glints (the item-definition branch chooses the angle target only).

### 19.4 Constants summary

| Quantity | Value |
|---|---|
| Glint texture size | 128 x 128 (item: RGB, armour: palettised), both with the `blur` flag |
| Scroll formula | 12 §8.3: `t = ms * glintSpeed * 8.0`; translate `(-(t mod 110000) / 110000, (t mod 30000) / 30000)`, rotate Z by `0.17453292` rad, then scale |
| Texture scale | items 8.0, entity models 0.16, armour 0.5 |
| Strength | `GlintAlpha` = the glint strength option, default 0.75 |
| Added colour | `rgb += (GlintAlpha * sample.rgb)^2` per channel, before fog |
| SPECIAL coordinate scale | `1/128`, applied to the face-plane coordinate in blocks divided by the decal factor `f` (GUI 0.5, first person 0.75, all other contexts 1; 19.3.1) |
| `MAX_ENCHANTMENT_GLINT_SPEED_MILLIS` | 8.0 (the factor applied to the speed option in the formula above) |

---

## 20. `custom_name` (6), `item_name` (9), `lore` (11), `rarity` (12)

Gap closed: the four naming components had no layout section; 25-1 §7.2 has the `Rarity` enumeration without colours.

| Component | Network | NBT | Default / prototype | Limits and notes |
|---|---|---|---|---|
| `custom_name` (6) | TextComponent (00 §9.1, the network NBT form) | A text component in its save form (String for plain text, else compound or list) | absent | None on the codec. The anvil rename and the name tag limits are in 40-3 and 19. Equality: component value equality (tree of content, style and siblings). |
| `item_name` (9) | TextComponent (as above) | text component | set in every prototype to a translatable component keyed by the item's description id (25-1 §6.2: `item.minecraft.<key>` or `block.minecraft.<key>`) | A stack patch may replace it (renamed loot, books); it is not italic when displayed. |
| `lore` (11) | VarInt count (at most 256), then TextComponent per line | List of text components, at most 256 elements (a longer list fails the decode of the component) | common prototype: empty list (25-1 §7.1) | The network list codec has the same bound of 256. Every line is a separate component; a line is not split on newlines. |
| `rarity` (12) | VarInt, the enum id (0 `common`, 1 `uncommon`, 2 `rare`, 3 `epic`) | String: `common`, `uncommon`, `rare`, `epic` | `common` in the common prototype | Unknown name fails the decode. |

**Rarity colours** (the chat formatting colour each constant carries, read in `Rarity.<clinit>`): `common` white, `uncommon` yellow, `rare` aqua, `epic` light purple. Their RGB values (read in `TextColor.<clinit>`, the legacy-format colour table): white `FFFFFF` (16777215), yellow `FFFF55` (16777045), aqua `55FFFF` (5636095), light purple `FF55FF` (16733695). The lore base colour dark purple is `AA00AA` (11141290).

**Display rules** (`ItemStack`):

1. Hover name (`getHoverName`): the `custom_name` when present, otherwise the item's own name, which is the stack's `item_name` (25-1 §6: default empty text if absent).
2. Styled hover name (tooltip title and chat hover): the hover name, in the colour of the stack's effective rarity, and italic when (and only when) the stack has `custom_name`. Effective rarity = the `rarity` component (default `common`) raised by the enchantment rule of 19.2 item 4.
3. Display name (the bracketed form used in chat messages that show an item): `[` hover name `]`, italic when `custom_name` is present, and, unless the name is empty, coloured with the rarity colour; the item hover event is attached for the tooltip.
4. Lore lines (`ItemLore.styledLines`): every line is shown with the base style dark purple and italic, merged under the line's own style (a line that sets its own colour or italic keeps it). `lines()` gives the raw lines without that style.
5. `ItemLore.withLineAdded` appends a line (the 256 cap applies when the new list is built; the constructor rejects a list longer than 256).
6. Equality of each component is value equality; stacks with different lore or names do not merge.

---

## 21. `fireworks` (71) and `firework_explosion` (70)

Gap closed: 27 §8 (recipes), 26 and 42-2 use these values; the layouts were not written down. Colours are plain Ints in these components (the dye firework colours of 43 §8, as RGB, no alpha required).

### 21.1 `firework_explosion` (70), record `FireworkExplosion`

| # | Field | Network | NBT key and form | Default (NBT) |
|---|---|---|---|---|
| 1 | shape | VarInt shape id (table below; an id out of range reads as 0, strategy ZERO) | `shape` String (the serialised name; required) | required |
| 2 | colors | VarInt count, then count x Int (4 bytes each, big-endian) | `colors` List of Int | empty |
| 3 | fade_colors | same as `colors` | `fade_colors` List of Int | empty |
| 4 | has_trail | Boolean | `has_trail` Boolean | false |
| 5 | has_twinkle | Boolean | `has_twinkle` Boolean | false |

| Shape id | Serialised name | Particle shape (42-2) |
|---|---|---|
| 0 | `small_ball` | small ball |
| 1 | `large_ball` | large ball |
| 2 | `star` | star |
| 3 | `creeper` | creeper |
| 4 | `burst` | burst |

- No length limit is imposed on the colour lists by either codec.
- The `firework_star` item carries one of these; a rocket carries several inside `fireworks`.
- Equality: field-wise (shape, the two int lists in order, the two flags). Two stars with the same colours in a different order are different values.
- `withFadeColors(list)` returns a copy with only `fade_colors` replaced (used by the crafting of 27 §8).

### 21.2 `fireworks` (71), record `Fireworks`

| # | Field | Network | NBT key and form | Default (NBT) |
|---|---|---|---|---|
| 1 | flight_duration | VarInt | `flight_duration` Byte (unsigned byte, 0 to 255) | 0 |
| 2 | explosions | VarInt count (at most 256), then count `firework_explosion` values (21.1 layout, back to back, no component id) | `explosions` List of compounds (21.1), at most 256 | empty list |

- **Validation:** the record's constructor rejects a list of more than 256 explosions with an exception ("Got N explosions, but maximum is 256"), so the network decoder and the NBT decoder both fail on it. The flight duration has no range check on the network (VarInt), the NBT form accepts only 0 to 255.
- **Prototype:** the `firework_rocket` item has `fireworks` = (flight duration 1, no explosions) in its prototype (25-6 row 1053; behaviour 17 §3.13). The meaning of the duration and the crafting that fills the list are in 17 §3.13 and 27 §8, not repeated here.
- Equality: the duration and the list of explosions (each by 21.1 equality).

---

## 22. `banner_patterns` (74), `base_color` (75), `provides_banner_patterns` (67), `ominous_bottle_amplifier` (65), the omen bottle effect

Gap closed: 31-3 §3 gives the banner block entity's `patterns` and the 43 pattern entries; 20 and 25-8 give the omen behaviour. This section gives the item component layouts and the exact drawing rule of the layers (banner and shield) that 52 §6 leaves out ("patterns out of scope").

### 22.1 Layouts

| Component | Network | NBT | Default | Notes |
|---|---|---|---|---|
| `banner_patterns` (74), `BannerPatternLayers` | VarInt count, then count layers; layer = Holder of `banner_pattern` (00 §10.2: 0 + inline pattern, or registry position + 1) then VarInt dye colour id (43 §8 order, 0 to 15). No count limit. | List of compounds `{pattern: <id or inline>, color: <dye name String>}`, both keys required; the list has no length limit on load (31-3 §3: the limit 6 is only a crafting and tooltip rule) | `EMPTY` (no layers) is the prototype of the shield item (17 §2) and the value a banner stack gets when none is set | Inline pattern compound: `{asset_id: String, translation_key: String}` (04 §6). Equality: the ordered list of (pattern, colour). Tooltip: at most the first 6 layers are listed. |
| `base_color` (75) | VarInt dye colour id (the dye id enum of 43 §8) | String, the dye name (`white` ... `black`) | absent | Colour the shield base is tinted with (22.3); written to a shield when a banner is applied to it (crafting, 40-4). |
| `provides_banner_patterns` (67), a HolderSet of `banner_pattern` | HolderSet (00 §10.3: VarInt 0 plus a tag name String, or n + 1 followed by n ids) | Either a String `#minecraft:pattern_item/globe` (a tag, with the leading `#`), a single String id, or a List of ids | absent | On the 10 patterned banner items (31-3 §3: one tag per item, each tag naming one pattern); the loom reads the set of the pattern item. |
| `ominous_bottle_amplifier` (65), record `OminousBottleAmplifier` | VarInt `value` | Int in 0 to 4 inclusive (outside fails the decode); a bare Int, not a compound | the `ominous_bottle` prototype carries 0 (25-8) | Network layout confirmed: one VarInt, no range check on the wire (the range is a persistence codec rule; the network codec is a plain VarInt composite, inferred that a constructor does not re-check it). |

### 22.2 Omen bottle effect

Consuming an ominous bottle (listener `OminousBottleAmplifier.onConsume`): gives the consumer the mob effect `bad_omen` with duration **120000** ticks and amplifier = `value`. The three trailing flags of the instance (ambient, show_particles, show_icon) are false, false, true (20 §Starting). The tooltip shows the same effect (name and 120000 ticks, shown as `100:00`). What `bad_omen` does afterwards (turning into `raid_omen` and starting a raid inside a village, the per-tick checks) is 20 (Raid), 17 §4 (effect ticking) and is not repeated.

### 22.3 Drawing rules (banner layers and shield)

Inputs: base colour, the ordered layer list, a flag "is shield". Sprites come from two atlases whose definition files take a whole directory each: `textures/atlas/banner_patterns.png` from `entity/banner/` and `textures/atlas/shield_patterns.png` from `entity/shield/`; a layer's sprite is `entity/banner/<pattern asset id path>` (shield: `entity/shield/<...>`), and the pattern-less base sprite is `base` (`entity/banner/base` or `entity/shield/base`).

1. The base layer (order value 1) is the flag or shield model drawn with the `base` sprite tinted by the **base colour's diffuse colour** (43 §8 "diffuse", the colour used for leather mixing and banner layers; opaque).
2. Then, for the first `min(layers, 16)` layers in list order, layer `i` (0-based) is the same model drawn with that pattern's sprite, tinted by the layer's dye diffuse colour, at order value `i + 2`. The renderer cap is **16** layers (a constant of the renderer); the game's rules cap crafting at 6, so a stack or block entity loaded from NBT with 7 to 16 layers still draws them all, and layers beyond 16 are never drawn.
3. The render type of the pattern layers is the banner-pattern type (52 §1 table; translucent in the sense that the sprite alpha selects where the dye shows). The wind animation parameter of the flag is the same for the base and the layers.
4. **Shield.** A shield stack is "patterned" when its `banner_patterns` (default `EMPTY`) is non-empty **or** it has a `base_color`. A patterned shield draws the `shield_base` sprite (white shield with the pattern area), otherwise the plain `shield_base_nopattern` sprite. For a patterned shield, the pattern layers of rule 1 and 2 are drawn on top with `is shield` set; the base colour is `base_color`, or white when absent. When the stack has the foil (19), the plain-shield part is drawn with the solid-entity glint type and, if patterned, one extra glint pass (`patterned_shield_glint`, 19.3) is added over the pattern layers.
5. Block-entity banners use the same layer function with the `patterns` of the block entity and the block's own colour as base (52 §6.3; wall and standing transforms, the swing from `(game time + position hash) mod 100`).

---

## 23. `damage` (3), `max_damage` (2), `max_stack_size` (1), `repair_cost` (19), `unbreakable` (4) and stack validation

Gap closed: 17 §1.3 and 25-1 §7.3 give the behaviour; this section gives the persistence ranges, the network layouts, the "equality and stacking" consequences and the strict validation that rejects a stack.

| Component | Network | NBT | Range (NBT decode) | Default / prototype | Notes |
|---|---|---|---|---|---|
| `max_stack_size` (1) | VarInt | Int | 1 to 99 inclusive (`intRange(1, 99)`); the wire value is not range-checked | 64 in the common prototype (25-1 §7.1); 1 for every item built with `durability(n)` | Absolute cap 99. A stack's count above its effective max is rejected by 23.2. |
| `max_damage` (2) | VarInt | Int | 1 or more (a positive-int codec; 0 or negative fails) | absent except on durability items (`durability(n)` sets it) | An item with this component must have `max_stack_size` 1 (23.2). Enchantments such as unbreaking do not change it. |
| `damage` (3) | VarInt | Int | 0 or more (non-negative-int codec) | 0 on durability items' prototypes; absent elsewhere | Reading and writing through the stack clamps it to 0 to `max_damage` (17 §1.3). Marked `ignoreSwapAnimation`: a change of only this component does not play the re-equip (swap) animation of the held item, unlike every other component change. A stack whose damage reaches `max_damage` after a hurt breaks (17 §5.1). |
| `repair_cost` (19) | VarInt | Int | 0 or more | 0 in the common prototype | The anvil surcharge (40-3 gives how it grows); equality is by value, so two items with different repair costs do not merge. |
| `unbreakable` (4) | none (Unit) | empty compound | any compound accepted | absent | Presence makes `isDamageableItem` false (17 §1.3), so the item never loses durability and the durability bar is hidden. Its tooltip line is shown unless hidden by `tooltip_display` (15.4; the line text was not read). |

### 23.1 Stacking and equality

A merge (13 §3.7) needs the same item and equal component maps. For durability items this makes two stacks with different `damage` unmergeable, and since they have max stack 1 they never merge anyway; the rule matters for unbreakable or renamed stackable items, where every component that differs (`custom_name`, `lore`, `repair_cost`, `enchantments`) blocks the merge.

### 23.2 Strict validation (`ItemStack.validateStrict` and `validatedStreamCodec`)

A stack is rejected (a decode error for NBT through the strict codec; a decode failure for packets that use the validated stream codec) when either rule fails:

1. The stack's components contain `max_damage` and its effective `max_stack_size` (default 1 when absent in the map, read with `getOrDefault(max_stack_size, 1)`) is greater than 1.
2. The stack has one of the three container-like components `container` (§25), `bundle_contents` (§25) or `charged_projectiles` (§25), the three read in `validateComponents`, and any stack inside it has a count greater than that stack's own maximum stack size (the check is applied recursively through `validateStrict` of the contained stack).

An empty stack passes. The validated codec leaves the bytes unchanged (00 §12.1).

---

## 24. `food` (23), `consumable` (24), `use_remainder` (25), `use_cooldown` (26), consume effect payloads and `suspicious_stew_effects` (55)

Gap closed: 25-1 §7.2, 25-5 §4 (consume pipeline, the `Consumables` table with golden apple, rotten flesh, honey bottle and the rest) and 25-6 (chorus fruit) have the behaviour and values; this section adds the exact network and NBT field layouts (so that the component store can read and write them) and the stew entry record. Behaviour and numbers stay where they are; the effect values asked for in the task are re-listed in 24.5 for convenience (all re-read from `Consumables` in this round; no difference).

### 24.1 Layouts

| Component | Network | NBT | Defaults / limits |
|---|---|---|---|
| `food` (23), `FoodProperties` | VarInt nutrition, Float saturation, Boolean can_always_eat | `{nutrition: Int, saturation: Float, can_always_eat: Boolean}` | `nutrition` required, 0 or more; `saturation` required (no range check); `can_always_eat` default false. In a patch the value is the direct form (no holder). |
| `consumable` (24), `Consumable` | Float consume_seconds, VarInt animation (`ItemUseAnimation` id, 25-1 §7.2), sound (Holder of `sound_event`: 0 + inline `Identifier` and Optional Float range, or n + 1 for registry position n), Boolean has_consume_particles, VarInt count then count consume effects (24.2) | `{consume_seconds: Float, animation: String, sound: <id or {sound_id, range?}>, has_consume_particles: Boolean, on_consume_effects: List of compounds}` | `consume_seconds` default 1.6 and 0 or more; `animation` default `eat` (names `none`, `eat`, `drink`, `block`, `bow`, `trident`, `crossbow`, `spyglass`, `toot_horn`, `brush`, `bundle`, `spear`); `sound` default `entity.generic.eat`; `has_consume_particles` default true; `on_consume_effects` default empty. All five keys optional. |
| `use_remainder` (25), `UseRemainder` (one `ItemStackTemplate`) | RegistryId of `item` (VarInt), VarInt count, DataComponentPatch (00 §12.2) | `{id: <item id>, count: Int 1..99 (default 1), components: <patch> (default empty)}`, or a bare item id String (shorthand, count 1, no components) | The template must be a non-empty stack ("Item must be non-empty"). A template is a stack without the "empty" form: there is no count 0. |
| `use_cooldown` (26), `UseCooldown` | Float seconds, Optional Identifier cooldown_group (Boolean + String) | `{seconds: Float, cooldown_group: String (optional)}` | `seconds` required and positive (greater than 0; 0 fails the decode); no default group (the item's own registry key is used when absent, 17 §1.3); the cooldown lasts `seconds * 20` ticks. |

All four are `cacheEncoding` types (a server-side memoisation, not visible in the bytes). `food` and `consumable` are both read by the consume pipeline; either may exist alone (a `consumable` without `food` is a drink or a bucket; a `food` without `consumable` cannot be eaten).

### 24.2 Consume effect (list element of `on_consume_effects`, `death_protection` of §25 and so on)

Network: VarInt type id (`consume_effect_type`, 46 §8.2: 0 `apply_effects`, 1 `remove_effects`, 2 `clear_all_effects`, 3 `teleport_randomly`, 4 `play_sound`), then the type's payload:

| Id | Type | Network payload | NBT keys (the compound also carries the type name under key `type`, read: the dispatch codec uses its default key; the fields below sit in the same compound) | Defaults and limits |
|---|---|---|---|---|
| 0 | `apply_effects` | VarInt count, count mob effect instances (§16.2), Float probability | `effects` List of mob effect instances (§16.2), `probability` Float | `probability` default 1.0 and must be in 0.0 to 1.0; the effects apply when `nextFloat() < probability` (25-5 §4.4) |
| 1 | `remove_effects` | HolderSet of `mob_effect` (00 §10.3) | `effects` HolderSet: a String id, a String tag `#id`, or a list of ids | no default; required |
| 2 | `clear_all_effects` | nothing | no extra keys | |
| 3 | `teleport_randomly` | Float diameter, Boolean directional_particles | `diameter` Float, `directional_particles` Boolean | `diameter` default 16.0 and positive; `directional_particles` default **true** in NBT too (read) and for the no-argument constructor used by chorus fruit (25-6). Behaviour: 25-6. |
| 4 | `play_sound` | sound (Holder of `sound_event`, as in `consumable`) | `sound` (id or inline) | required |

### 24.3 `suspicious_stew_effects` (55), `SuspiciousStewEffects`

| Aspect | Value |
|---|---|
| Network | VarInt count, then count entries; entry = RegistryId of `mob_effect` (VarInt), VarInt duration (ticks) |
| NBT | List of `{id: <effect id>, duration: Int}`; `duration` is optional and read leniently (a wrong-typed value is replaced by the default) with default **160** ticks (8 s) |
| Default | the `suspicious_stew` item prototype has an empty list (25-6); a flower-bearing recipe fills it (27) |
| Entry to instance | `new MobEffectInstance(effect, duration)`: amplifier 0, not ambient, particles and icon shown (16.2) |
| On consume (`ConsumableListener`) | each entry's instance is applied to the eater with `addEffect`, in list order, at the end of the `food` handling of 25-5 §4.3 step 3c |
| Source of the entries | the flower's stew effect: `(effect, seconds)` of 24-2 §3 rows 140 to 154; the stored duration is `seconds * 20` ticks (inferred from the 160-tick default being 8 s; `0.35` s for the saturation of dandelion and golden dandelion is 7 ticks). A brown mooshroom stores the same entry list (19). |
| Equality | ordered list equality of (effect, duration) |

### 24.4 `death_protection` and other consume-effect lists

`death_protection` (36) is a record holding one list of consume effects: network = VarInt count then elements as in 24.2; NBT = `{death_effects: List of consume effects}`, the key optional with default empty list (read). The totem item's list (what it grants when it saves the player) is 17.

### 24.5 Effect values asked for (from 25-5 §4.5, re-read)

| Food or drink | Effect applied on consume |
|---|---|
| golden apple | `regeneration` 100 ticks amplifier 1, `absorption` 2400 ticks amplifier 0 (both, probability 1.0) |
| enchanted golden apple | `regeneration` 400/1, `resistance` 6000/0, `fire_resistance` 6000/0, `absorption` 2400/3 |
| rotten flesh | `hunger` 600 ticks amplifier 0 with probability 0.8 |
| chorus fruit | `teleport_randomly` (diameter 16.0, directional particles on), plus `use_cooldown` 1.0 s (25-6) |
| honey bottle | `remove_effects` `poison`; consume 2.0 s, drink animation |
| suspicious stew | the stew entries of 24.3 |
| pufferfish | `poison` 1200/1, `hunger` 300/2, `nausea` 300/0 (together, probability 1.0) |

---

## 25. Stack-holding and blob components: `container` (77), `bundle_contents` (52), `charged_projectiles` (51), `custom_data` (0), `bucket_entity_data` (61), `entity_data` (60), `block_entity_data` (62), `block_state` (78)

Gap closed: item stacks that live inside a component are an `ItemStackTemplate` in 26.3, not an `ItemStack`; the layouts below make the component store writable. Behaviour of bundles is 25-5 §7 (weights), of shulker and container items 31-1, of crossbows 25-7.

### 25.1 The item stack template (`ItemStackTemplate`, used by `use_remainder`, `container`, `bundle_contents`, `charged_projectiles`)

| Form | Layout |
|---|---|
| Network | RegistryId of `item` (VarInt), VarInt count, DataComponentPatch (00 §12.2). **Not** the stack form of 00 §12.1: there is no "count 0 means empty" shortcut, and the count and item order is item then count (the stack form has count first). |
| NBT | `{id: <item id>, count: Int 1..99 (default 1), components: <patch compound> (default empty)}`; a bare item id String is accepted as the shorthand. |
| Validity | The item must not be `air` and the count must be at least 1 ("Item must be non-empty", "Stack must be non-empty"). An empty slot is never a template; where a slot can be empty, the holder uses an absent value (25.2). |

### 25.2 `container` (77), `ItemContainerContents`

| Aspect | Value |
|---|---|
| Value | An ordered list of at most **256** slots; each slot is empty or an item stack template. Trailing empty slots are not stored (the list ends at the last non-empty slot when built from a container). |
| Network | VarInt count (at most 256), then count x Optional (Boolean present flag, then an ItemStackTemplate, 25.1). An empty slot is `00`. (The Optional wrapper is read: the stream codec is the template codec wrapped in the optional operation, then the 256-bounded list.) |
| NBT | List of at most 256 compounds `{slot: Int 0..255, item: <template compound>}`, one per **non-empty** slot, in any order; on load the slot list is sized to the highest slot index plus one with the rest empty. Duplicate slot indices: the later entry wins (read: the slots are written into the list in order). A slot number over 255 or a list of more than 256 entries fails the decode. |
| Default | `EMPTY` (no slots). Present in the prototype of the shulker box items (31-1). |
| Equality | Slot-by-slot list equality including trailing structure: `[A]` and `[A, empty]` are different lists, but the builders never produce the second. |
| Behaviour | Destroying a block item entity empties the component and drops the contents (25-1 §6); the tooltip shows the first few non-empty items plus a "more items" line (translation keys `item.container.item_count` and `item.container.more_items`). |

### 25.3 `bundle_contents` (52), `BundleContents`

Network: VarInt count then count ItemStackTemplates (no bound, no Optional). NBT: List of template compounds (no bound). The selected-slot index is transient: it is not on the wire and not saved. Weights, the capacity, the "bundle in a bundle" and beehive weights and the "excessive total bundle weight" rejection are in 25-5 (the decode of an over-capacity list fails with that message). Default `EMPTY`. Equality: ordered list of templates (the selected index does not take part, inferred from it being transient).

### 25.4 `charged_projectiles` (51), `ChargedProjectiles`

Network: VarInt count (at most **1024**) then count ItemStackTemplates. NBT: List of template compounds, at most 1024. On load, empty entries are dropped and the list is cut to 1024 with a logged message "Tried to load invalid items as charged projectiles" when anything was dropped. Default `EMPTY` (the loaded crossbow prototype has none). Tooltip keys `item.minecraft.crossbow.projectile.single` and `.multiple`. Strict validation of the contained counts: 23.2 rule 2.

### 25.5 `custom_data` (0) and `bucket_entity_data` (61)

Both are `CustomData`, a wrapper of one NBT compound.

| Aspect | Value |
|---|---|
| Network | `bucket_entity_data` (61): network NBT, compound only (00 §8: type byte 10, no root name, then the compound payload; an End root or a non-compound root fails), not length-prefixed, not Boolean-prefixed. `custom_data` (0): **not sent at all** (15.2: persistent only); the layout just described is the `CustomData` stream codec, which only `bucket_entity_data` uses. |
| NBT | A compound (the data as it is), **or** a String in the SNBT syntax which is parsed into a compound ("flattened" alternative; the writer always writes the compound). |
| Default | `EMPTY` (an empty compound). `bucket_entity_data` is in the prototype of every mob bucket as empty (25-5 §3); `custom_data` is absent by default. |
| Equality | NBT compound equality (key sets and values; list order matters). |
| Use | `custom_data` is free-form (commands, data packs, the `custom_data` predicate of 26 §10). `bucket_entity_data` holds the creature data of a mob bucket (25-5): the keys the bucket copies into and out of the entity. |
| Size | No limit in the codec; the network accounter limit of 00 §8 applies to the whole packet. |

### 25.6 `entity_data` (60) and `block_entity_data` (62), `TypedEntityData`

| Aspect | `entity_data` | `block_entity_data` |
|---|---|---|
| Type key | RegistryId of `entity_type` | RegistryId of `block_entity_type` |
| Network | the type id (VarInt), then network NBT compound (00 §8) of the data **without** the `id` key (order: type first, compound second; the order follows the composite codec's argument order and is inferred) | same, with the block entity type id |
| NBT | one compound: key `id` (String, the type identifier; required) plus the data keys at the same level | same |
| Stored form | the compound is held without `id`; reading the saved form strips `id` into the type, writing puts it back (`stripId`) | same |
| Apply | `loadInto(entity)`: the entity's current save data (without id) is merged under the component's compound (the component keys win), then loaded; used by spawn eggs and the like (25-6). Spawner use: the compound gets `id` put back and is merged into the spawn data. | `loadInto(block entity)`: the block entity's custom save data is merged under the compound, then loaded; on failure the previous data is restored ("rollback") and a message "Failed to apply custom data to block entity" is logged. Operators-only types: 31-1 (six types, `OP_ONLY_CUSTOM_DATA`). |
| Default | absent | absent |
| Equality | the type and the compound | same |
| Tooltip | for `entity_data` of a spawn-egg style item on a peaceful world the key `item.spawn_egg.peaceful` is used (text only) | none read |

### 25.7 `block_state` (78), `BlockItemStateProperties`

| Aspect | Value |
|---|---|
| Value | A map from property name String to value String; only listed properties override the block's default state when the block item is placed (25-1 §6, step 6: unknown names or illegal values are ignored by the application). |
| Network | VarInt count, then count x (String(32767) name, String(32767) value). |
| NBT | A compound whose values are all Strings (`{"facing": "north", "waterlogged": "true"}`); a non-string value fails the decode. Booleans and numbers are therefore written as their state-name strings. |
| Default | `EMPTY` (no properties); the component is absent on ordinary block items. |
| Equality | map equality. |

---

## 26. Remaining components: maps, instrument, jukebox, books, profile, lodestone tracker, glider, attribute modifiers, tool, equippable

Gap closed: layouts and NBT forms for the last group of the cr5 task. Behaviour stays in 17 (tool, equippable, attribute modifiers), 25-5 (maps, compass), 25-7 (jukebox discs, horns) and 31-4 (lectern books). The registry has **no** `map_color` component in 26.3 (the 122 types of 46 §8.1 contain `map_id`, `map_decorations` and `map_post_processing` only); a map's colour data lives in the map saved data.

### 26.1 Maps

| Component | Network | NBT | Default / notes |
|---|---|---|---|
| `map_id` (48), `MapId` | VarInt | Int | absent until the map is created; the key of the saved data `map_<id>` (45) |
| `map_decorations` (49) | **not sent** (persistent only) | compound mapping a decoration name String to `{type: <map_decoration_type id>, x: Double, z: Double, rotation: Float}` (all four required) | `EMPTY` is in the prototype of the map items (25-1 `mapProperties`); used by banners and structure markers on a map |
| `map_post_processing` (50) | VarInt enum id: 0 `lock`, 1 `scale` | **not saved** (transient) | marks a map stack that still needs its lock or scale step when first read by the server (25-5) |

### 26.2 `instrument` (63) and `jukebox_playable` (66)

| Component | Network | NBT | Notes |
|---|---|---|---|
| `instrument` (63), holder of `instrument` | Holder (00 §10.2): 0 + inline value, or registry position + 1; inline value: sound holder (17 §1.2 form), Float use_duration, Float range, VarInt durability_damage, TextComponent description | String id, or an inline compound `{sound_event: <sound>, use_duration: Float >= 0, range: Float > 0, durability_damage: Int >= 0 (default 0, read), description: <text>}` | `sound_event` is a sound holder in the NBT form (id String or `{sound_id, range?}`) |
| `jukebox_playable` (66) | Holder of `jukebox_song`: 0 + inline, or position + 1; inline: sound holder, TextComponent description, Float length_in_seconds, VarInt comparator_output | String id, or inline `{sound_event, description, length_in_seconds: Float > 0, comparator_output: Int 0..15}` | The component is the song itself (a one-field record); 25-7 §4.1 states the values per disc. |

### 26.3 Books

| Component | Network | NBT | Limits |
|---|---|---|---|
| `writable_book_content` (56) | VarInt count (at most 100), then pages; page = String(1024) **raw**, then Optional String(1024) **filtered** (Boolean + String) | `{pages: List}` (key optional, default empty); a page is either a String of at most 1024 characters, or `{raw: String, filtered: String (optional)}` | at most 100 pages; page length 1024 (`PAGE_EDIT_LENGTH`); the filtered text is only set by chat filtering and is empty in a normal server |
| `written_book_content` (57) | Filterable String title (raw String(32) + Optional filtered String(32)), String(32767) author, VarInt generation, VarInt page count then pages (each Filterable TextComponent: raw + Optional filtered), Boolean resolved | `{title: <String or {raw, filtered?}>, author: String, generation: Int 0..3 (default 0), pages: List (default empty), resolved: Boolean (default false)}`; a page is a text component or `{raw: <text>, filtered: <text> (optional)}` | title at most 32 characters in the codecs (the editing UI allows 16: `TITLE_LENGTH`); `MAX_GENERATION` = 3 (values 0 to 3; what each value means is not read); page text component serialised length at most 32767; no page-count bound seen in the codecs |

A Filterable value is the plain value, or a pair (raw, filtered). On the network the pair is always written (raw first, then Optional filtered); in NBT a plain value is read as (raw, none).

### 26.4 `profile` (72), `ResolvableProfile`

Network layout is in 00 §13.3 (Either full profile or partial, then the skin patch). NBT: a compound holding **either** the full stored profile (`id` as an int array of 4 (UUID), `name` (a player name: 1 to 16 characters), `properties` list of `{name, value, signature?}`) **or** the partial profile (`name` optional, `id` optional, `properties` default empty), together with the skin patch keys (`texture` body asset id, `cape` asset id, `elytra` asset id, `model` the model type name; each optional); or a bare String player name (shorthand, partial profile with only the name). Saving writes the compound form. The name rule (`PLAYER_NAME`) is a string of length 0 to 16 passing the name validation of 02.

### 26.5 `lodestone_tracker` (69), `glider` (34)

| Component | Network | NBT | Default |
|---|---|---|---|
| `lodestone_tracker` | Optional GlobalPos (Boolean + dimension identifier + position, 00 §4.3), Boolean tracked | `{target: <global pos compound>, tracked: Boolean}`; the `target` key is optional, `tracked` default **true** | no default; the key `target` form is the global position codec (`dimension` identifier and `pos` int array of 3, inferred); a compass with `tracked` true and a target that no longer has a lodestone block loses its target (25-5 §7). Equality: both fields. |
| `glider` | none (Unit) | empty compound | A marker component: an item that carries it can glide (17 §1.2 lists it as a Unit component; the flight rules are not in this section). |

### 26.6 `attribute_modifiers` (16)

| Level | Network | NBT |
|---|---|---|
| Component | VarInt count, then count entries | List of entries |
| Entry | RegistryId of `attribute` (VarInt; a reference holder), modifier (Identifier id, Double amount, VarInt operation id), VarInt slot group id, display (VarInt type id then payload) | `{type: <attribute id>, id: <identifier>, amount: Double, operation: String, slot: String (default `any`), display: {type: ..} (default `{type: "default"}`)}` |
| Operation | 0 `add_value`, 1 `add_multiplied_base`, 2 `add_multiplied_total` | the three names |
| Slot group | 0 `any`, 1 `mainhand`, 2 `offhand`, 3 `hand`, 4 `feet`, 5 `legs`, 6 `chest`, 7 `head`, 8 `armor`, 9 `body`, 10 `saddle` (the six listed group ids for `feet` to `saddle` were read; the lower ids follow the declaration order) | the lowercase names |
| Display | 0 `default` (no payload), 1 `hidden` (no payload), 2 `override` (TextComponent) | `{type: default}`, `{type: hidden}`, `{type: override, value: <text>}` |

`EMPTY` (no entries) is in the common prototype (25-1 §7.1). Equality: ordered list. Tooltip numbers use the pattern `#.##` for amounts (text rule only).

### 26.7 `tool` (28) and `equippable` (32): NBT and defaults

Network layouts are in 17 §1.2. NBT:

| Component | NBT keys (required unless a default is given) |
|---|---|
| `tool` | `rules` List of `{blocks: HolderSet of block (id, `#tag` or list), speed: Float > 0 (optional), correct_for_drops: Boolean (optional)}`; `default_mining_speed` Float default **1.0**; `damage_per_block` Int >= 0 default **1**; `can_destroy_blocks_in_creative` Boolean default **true** |
| `equippable` | `slot` String (required: `mainhand`, `offhand`, `feet`, `legs`, `chest`, `head`, `body`, `saddle`); `equip_sound` sound default `item.armor.equip_generic`; `asset_id` String (optional, an equipment asset key); `camera_overlay` String (optional identifier); `allowed_entities` HolderSet of entity type (optional); `dispensable` default **true**; `swappable` default **true**; `damage_on_hurt` default **true**; `equip_on_interact` default **false**; `can_be_sheared` default **false**; `shearing_sound` sound default `item.shears.snip` |

On the network `equippable` has no defaults: all fields are written (17 §1.2 order: slot, equip_sound, Optional asset, Optional camera overlay, Optional HolderSet, five Booleans, shearing sound).

---

## Open questions

1. The zoglin's and the raider hold-ground goal's exact aggressive conditions (2.3) were not traced.
2. The ram-run-up distance ordering (7.1, "squared distance") and the camel `standUpInstantly` constant (6.4) remain as marked.

3. (cr4) Not read: the `ServerPlayer` cross-dimension override (9.2); the argument order of the sniffer dig-position lookup (12.2); `FeelingHappy` and `Scenting` internals (12.2); how a float provider's value is printed (Java float text assumed, 13.4); the message of integer arithmetic exceptions (13.4); whether `/reload` re-sends the Commands tree (14.2); `/test`, `/dialog show`, `/raid` failure keys and `/perf` report format (not traced; `/jfr` is a JVM profiler and not applicable).

4. (cr5, after review) Still not read: whether the network decoder of `bundle_contents`, `ominous_bottle_amplifier` and `container` re-checks the persistence ranges (inferred not); the dye component's and dyed colour's id-enum codecs (17); the meaning of each book generation value (26.3); which hidden `ArmorTrim` tooltip lines exist. Settled by the reviewer from the artifact: the `_darker` icon selection (18.4), the enchantment level text (15.5), the container slot Optional wrapper and duplicate-slot rule (25.2), the `type` key of consume effects and attribute displays, the `directional_particles` NBT default (true), and the trim registry order (sorted by identifier, 18.2). Corrected: `custom_data` is persistent only and is not sent (15.2, 25.5).

Closed in review: the horizontal plane order is north, east, south, west (read from the plane's static initialiser; also in 24); the camel sitting dimensions are in 6.4.

5. 19.3.1: the glint coordinate's dependence on the decal factor `f` (positions divided by `f`) is inferred from the entry-wise scaling of the decal matrix and JOML's generic matrix inverse and position transform; JOML (`org.joml`) is not in the artifact. If the library re-derives an "affine" property after the entry-wise `set`, the inverse differs by a constant offset `A^-1 t (1/f - 1)` in the GUI and first-person cases (`A` the pose's 3 x 3 part, `t` its translation), which only shifts the scrolling pattern's phase; the scale `1/f` holds in both readings. The table of face directions assumes right-handed rotations (inferred from the property that `Direction.getRotation` maps the UP normal to each face's own normal); the WEST and EAST mirroring noted there follows from it.
