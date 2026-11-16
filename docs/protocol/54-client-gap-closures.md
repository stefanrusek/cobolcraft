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
- The server sets it from goals: the zombie attack goal raises it when its raise-arm counter reaches 5 ticks and clears it on stop (18, ZombieAttackGoal); the ranged bow goal sets it while running; illager, piglin and panda attack goals set it for their duration (18).
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

---

## Open questions

1. None for §1 and §2 beyond those of the cited documents.
