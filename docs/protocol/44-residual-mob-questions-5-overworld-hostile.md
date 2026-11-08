# 44 — Residual mob questions, part 5: overworld hostile mobs (round RS26)

| Item | Value |
|---|---|
| Covers | The residual open questions of [20](20-mobs-overworld-hostile.md) that this round could read: crossbow shooting arithmetic (Quick Charge, Multishot, Piercing, mob shooting), the warden (sniff, dig, emerge, entity sensor, anger ordering), the effect of the sulfur cube attributes `bounciness`, `friction_modifier` and `air_drag_modifier` on movement, the entity-type id check (answered as a recomputed id list), and the block blast-resistance table with the exact resistance lookup used by explosions; also the breeze attack sensor and the creaking heart block entity |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the `data/minecraft/` JSON inside the jar, with no execution. A statement is read from the artifact unless it is marked "(inferred)" or "(recalled, not verified)", or names an open question. Nothing here is marked recalled. |
| Data versus code | Per the operator decisions (design README Part 0, rule R7), data rows (enchantment JSON, loot tables, tags, archetype JSON) are not tabulated here beyond the few values needed to make a worked example; the engines that read them are specified. Block resistance is **code** (`Blocks.<clinit>`), so section 6 is complete for it. |
| Related | Shared mob framework 18; hostile mobs 20 (this document closes or narrows its open questions 10, 22, 24, 25 and 27); item side of the crossbow 17 §3.9; explosion algorithm 20 §6.2; warden behaviour summary 20 §15; sulfur cube 20 §18.2; breeze 20 §16; creaking 20 §17; enchantment effect data 17 §6. The structure spawners belong to [44-2](44-residual-mob-questions-2-spawning-structures.md), the village, point-of-interest and raid logic to [44-3](44-residual-mob-questions-3-villagers-poi-raids.md), and the wind charge entities to [44-8](44-residual-mob-questions-8-vehicles-and-projectiles.md); none of that is repeated here. |

Scope not covered in this document (see Open questions 1 to 6): villages (points of interest, golem and raid spawn rules; see 44-3), and the per-mob "not traced" lines of 20 §4 to §14 other than those named above. The reading budget of the round went to the engines whose questions are listed by number in 20 §22.

## 1. Dispositions of the open questions of 20

| 20 §22 question | Disposition here |
|---|---|
| 10 (Quick Charge arithmetic, `performShooting`, multishot, piercing) | Closed: section 2 |
| 22 (warden `TryToSniff`, `Digging`, `Emerging`, sensor, anger) | Closed for the four behaviours, the sensor and the anger ordering: section 3. The spawn path through the sculk shrieker is already complete in 20 §15 (re-read here, no difference found in the constants it lists, which are not repeated) |
| 24 (sulfur cube attributes) | Closed for `bounciness`, `friction_modifier`, `air_drag_modifier`: section 4. The archetype `knockback` modifiers and the push-sound settings remain open (Open question 7) |
| 25 (entity id check) | Answered: section 5 gives the complete id list recomputed from `EntityTypes.<clinit>` and states the rule; a wire capture is still the only runtime check |
| 27 (block blast resistance) | Closed: section 6 |
| 20 §16 breeze sensor | Closed: section 7. The wind charge behaviour is in 44-8, not repeated here |
| 20 §17 creaking heart linking and tracking | Narrowed: section 8 |

## 2. Crossbow and projectile-weapon arithmetic

Classes read: `CrossbowItem`, `ProjectileWeaponItem`, `CrossbowAttackMob`, `Monster.getProjectile`, `EnchantmentHelper`, `Enchantment`, the value-effect classes `AddValue`, `MultiplyValue`, `SetValue`, `RemoveBinomial`, `ScaleExponentially`, `AllOf$ValueEffects`, the `LevelBasedValue` records, `AbstractArrow`, and the enchantment JSON `quick_charge`, `multishot`, `piercing`, `infinity`.

### 2.1 Enchantment value engine used by the crossbow

An enchantment holds a data component map of effects. A *value effect* has one operation `process(level, random, current) -> float`:

| `type` | Result |
|---|---|
| `add` | `current + value(level)` |
| `multiply` | `current * factor(level)` |
| `set` | `value(level)` (ignores `current`) |
| `all_of` | applies the listed value effects in list order, each on the previous result |
| `scale_exponentially` | `current * base(level) ^ exponent(level)` (the power is taken in double precision) |
| `remove_binomial` | Let `c` = current and `p` = `chance(level)`. **Small branch** (when `c <= 128.0`, or `c*p < 20.0`, or `c*(1-p) < 20.0`; constants 128.0 and 20.0): the count is the number of integers `i = 0, 1, ...` with `i < c` (float comparison) for which `nextFloat() < p`, one draw per iteration. **Large branch**: `mean = floor(c*p)` (double), `sd = sqrt(c*p*(1-p))` (double), `count = round(mean + nextGaussian()*sd)` (`Math.round`, the long narrowed to int), clamped to the range 0 to `int(c)`. Both branches return `c - count`. Not used by the crossbow enchantments |

A `LevelBasedValue` is a function of the enchantment level `L` (an integer from 1): `constant` (a fixed float), `linear` (`base + per_level_above_first * (L - 1)`), `clamped` (the inner value clamped to `[min, max]`; `max` must exceed `min`), `fraction` (`numerator(L) / denominator(L)`, and 0 when the denominator is 0), and three more, all read in `calculate`:

| `type` | Value at level `L` |
|---|---|
| `levels_squared` | `L * L` (integer square, then converted to float) plus the float `added` |
| `lookup` | when `L <=` the size of the `values` list: `values[L - 1]` (one-based level); otherwise the `fallback` level-based value evaluated at `L` |
| `exponent` | `base(L) ^ power(L)`: both inner values are widened to double, the power is taken in double precision, and the result is narrowed to float |

Two ways of applying an effect exist:

- **Unfiltered** (`Enchantment.modifyUnfilteredValue`): the component holds a single value effect; when present the running value is replaced by `effect.process(level, random, value)`. `crossbow_charge_time` is of this kind.
- **Entity-filtered** (`modifyEntityFilteredValue`): the component holds a list of (effect, optional requirements); the requirements are evaluated against a loot context built from the level, the enchantment level, the entity and the entity position; each effect whose requirements hold is applied in list order. `projectile_count`, `projectile_spread`, `projectile_piercing` (item-based filtered) and `ammo_use` (item-filtered with a `match_tool` predicate on the ammunition) use list components.

The helper that walks an item's enchantments (`runIterationOnItem`) visits the entries of the `enchantments` component in map iteration order (the order of the stored entry set); all enchantments of the stack are applied one after another to one running float, so enchantments that both touch the same component compose in that order. After the walk the helpers clamp: `processProjectileCount` returns `max(0, int(value))` (the float is truncated toward zero), `processProjectileSpread` returns `max(0.0, value)`, `getPiercingCount` returns `max(0, int(value))`, `modifyCrossbowChargingTime` returns `max(0.0, value)`, and `processAmmoUse` returns `int(value)` (truncated, with no lower clamp). Starting values passed in: count 1, spread 0.0, ammo use 1, piercing 0.0, charge time 1.25 (seconds).

### 2.2 Data values (read from the JSON, for worked examples)

| Enchantment | Component | Effect |
|---|---|---|
| `quick_charge` (max level 3) | `crossbow_charge_time` | `add`, `linear(base -0.25, per_level_above_first -0.25)`, so `-0.25 * L` seconds |
| `quick_charge` | `crossbow_charging_sounds` | three entries (levels 1, 2, 3): start sounds `item.crossbow.quick_charge_1`, `_2`, `_3`, end sound `item.crossbow.loading_end`; `pickHighestLevel` takes the entry for the highest level present; with none, the default sounds apply |
| `multishot` (max level 1) | `projectile_count` | `add`, `linear(2, 2)`: `+2 * L` |
| `multishot` | `projectile_spread` | `add`, `linear(10, 10)`: `+10 * L` degrees |
| `piercing` (max level 4) | `projectile_piercing` | `add`, `linear(1, 1)`: `+L` |
| `multishot`, `piercing` | `exclusive_set` | both name the tag `#minecraft:exclusive_set/crossbow`, so Multishot and Piercing are mutually exclusive in the enchantment data (a command-given stack can still hold both) |
| `infinity` | `ammo_use` | `set` 0, only when the ammunition item is `arrow`; the crossbow enchantments exclude it |

### 2.3 Charge time and use

1. `getChargeDuration(stack, entity)` = `floor(max(0, modifyCrossbowChargingTime(stack, entity, 1.25)) * 20)` ticks. The random source passed to the effect is the entity's.
2. Quick Charge level `L` gives `1.25 - 0.25 L` seconds: 25, 20, 15, 10 ticks for L = 0 to 3 (the arithmetic is single precision; all four values are exact binary fractions, so no rounding issue arises). The duration is clamped to 0 at Quick Charge level 5 and above (`max(0, ...)` in `modifyCrossbowChargingTime`). With duration 0, `onUseTick` divides the elapsed ticks by 0 in single precision: at elapsed 0 the progress is NaN, so no sound flag changes and nothing loads; at elapsed 1 or more it is +Infinity, so every threshold passes and `tryLoadProjectiles` runs at once. In effect a duration-0 crossbow loads on the first tick with elapsed >= 1.
3. `getUseDuration` is 72000 ticks. While using, `onUseTick` on the server computes `progress = (useDuration - remainingUseTicks) / chargeDuration`; below 0.2 it resets the two sound flags; at progress >= 0.2 it plays the start sound once; at >= 0.5 the middle sound once; at >= 1 and not already charged it calls `tryLoadProjectiles` and, on success, plays the end sound.
4. `tryLoadProjectiles(entity, crossbow)`: ammunition = `entity.getProjectile(crossbow)`; `draw` (2.4) returns a list; when the list is not empty it is stored in the `charged_projectiles` component and loading succeeded.
5. `releaseUsing` returns whether `getPowerForTime >= 1` (use ticks / charge duration, capped at 1) and the item is charged; it loads and shoots nothing.
6. `use`: if `charged_projectiles` is not empty the crossbow fires at once (`performShooting` with power 3.15, or 1.6 when the charged list contains a firework rocket; uncertainty 1.0; no target) and the interaction result is CONSUME; otherwise charging starts when the player has a projectile (`Player.getProjectile` not empty), after resetting both sound flags.
7. `Monster.getProjectile(weapon)` (used by all monster crossbow and bow users): when the weapon is a projectile weapon, the held projectile is taken by `getHeldProjectile` (the off-hand stack if it passes the weapon's held-projectile predicate, else the main-hand stack if it passes, else empty); when that is empty a **fresh `arrow` item stack** is returned. So a monster always has ammunition. `LivingEntity.getProjectile` (the base) returns the empty stack. The held-projectile predicate of the crossbow accepts the item tag `arrows` or `firework_rocket`.

### 2.4 `draw`: how many projectiles and what is consumed

Inputs: weapon, ammunition stack, shooter. When the ammunition stack is empty `draw` returns the empty list at once. The count `n = processProjectileCount(level, weapon, shooter, 1)` **only on a server level**, and 1 otherwise (so `1 + 2 L` with Multishot on a server; 3 at level 1). A copy of the ammunition stack is made once before the loop. For `i = 0 .. n-1`: take the **original** ammunition stack when `i = 0`, otherwise the **copy**; call `useAmmo(weapon, thatStack, shooter, forceFree = (i > 0))`; keep the result when non-empty.

`useAmmo`: `cost = 0` when `forceFree`, or the shooter has infinite materials, or the level is not a server level; otherwise `cost = processAmmoUse(level, weapon, ammo, 1)`. If `cost > ammo.count` the result is empty. If `cost = 0` the result is a copy with count 1 carrying the `intangible_projectile` flag (a projectile that cannot be picked up). Otherwise `cost` items are split off the stack; if the stack became empty and the shooter is a player, the stack is removed from the player's inventory.

The ammunition is consumed here, at load time (`draw` and `useAmmo`), never in `shoot` (2.5). Consequences: with Multishot (n = 3) the first projectile consumes 1 arrow (or 0 with an `ammo_use` effect that sets 0), and projectiles 2 and 3 are always free and intangible. A monster that has no held projectile fires from a fresh stack that is never persisted.

### 2.5 `performShooting` and `shoot`

`performShooting(level, shooter, hand, weapon, power, uncertainty, target)` runs only on a server level. It takes the `charged_projectiles` component, **replaces it with the empty value first**, returns if it was absent or empty, builds the list of item copies, and calls `shoot(level, shooter, hand, weapon, projectiles, power, uncertainty, crit = shooter is a Player, target)`. Afterwards, for a server player: the `shot_crossbow` advancement trigger fires with the weapon, and the `item_used` statistic of the crossbow item is awarded. Mobs call it through `CrossbowAttackMob.performCrossbowAttack(mob, speed)`; the `speed` argument is passed on unchanged as the **power**. Both callers read (the pillager and the piglin `performRangedAttack`) pass the constant **1.6** (`CrossbowItem.MOB_ARROW_POWER = 1.6f`), whatever the ammunition. The values 3.15 and 1.6 (firework) of 2.3 step 6 therefore apply only to the player `use` path. In `performCrossbowAttack` the hand is the one holding a crossbow, `uncertainty = rangedAttackUncertainty(level)` (20 §13.2: `14 - 4 * difficultyId`), the target is the mob's attack target, and `onCrossbowAttackPerformed` follows.

`shoot` (`ProjectileWeaponItem.shoot`), with `n` the list size:

1. `spread = processProjectileSpread(level, weapon, shooter, 0)` (degrees; 0 without Multishot, 10 with level 1).
2. Step `s = 0` when `n = 1`, else `s = 2 * spread / (n - 1)`.
3. Base offset `b = ((n - 1) mod 2) * s / 2` (so an even count is centred between two projectiles, an odd count on the aim line).
4. A sign `g` starts at +1. For `i = 0 .. n-1` (an empty stack is skipped: it does **not** flip the sign, but the loop index `i` still advances past it, so `floor((i + 1) / 2)`, the shot index handed to `shootProjectile` and the sound-pitch index all continue from the advanced `i`): `angle_i = b + g * floor((i + 1) / 2) * s`, then `g = -g`. The angle is passed in **degrees**.
5. The projectile is created (`createProjectile`; 2.6) and spawned with `shootProjectile(shooter, projectile, i, power, uncertainty, angle_i, target)` executed before it is added to the world.
6. After spawning each projectile the weapon takes `getDurabilityUse(projectileStack)` durability: 1, or 3 for a firework rocket (the crossbow override; the base value is 1), charged to the hand's equipment slot; the loop ends if the weapon is then empty (broken).

Resulting angles (degrees, in spawn order): n = 1: 0. n = 2 (spread S): `+S, -S` (step `2S`, base `S`). n = 3: `0, -S, +S`. n = 4: `S/3`, then `-S/3`, then `S`, `-S`; in general projectile `i` has `b + (-1)^i * floor((i+1)/2) * s`.

### 2.6 Aiming and sound (`CrossbowItem.shootProjectile`)

- **Player or any shooter with no target**: the projectile direction is the shooter's view vector rotated by `angle` degrees about the shooter's up vector (`getUpVector(1.0)`); then `Projectile.shoot(dx, dy, dz, power, uncertainty)` (the uncertainty spread of `Projectile.shoot` is in 20 §16).
- **Shooter with a target (mobs)**: `dx = target.x - shooter.x`, `dz = target.z - shooter.z`, `h = sqrt(dx² + dz²)`, `dy = target.getY(1/3) - projectile.y + h * 0.2` (the constant is the float 0.2 widened to double, 0.20000000298). The vector is normalised `u`; an axis `a = u x (0, 1, 0)`; when `|a|² <= 1e-7` the axis is instead `shooterUp x u`; the vector `p = u` rotated by +90 degrees (1.5707964 rad) about `a`; the final direction is `u` rotated about `p` by `angle` degrees. In effect a sideways fan perpendicular to the vertical plane of the aim. `Projectile.shoot(direction, power, uncertainty)` follows.
- **Sound**: `CROSSBOW_SHOOT` at the shooter, volume 1.0, pitch `getShotPitch(random, i)`: **1.0 with no random draw for `i = 0`**; for `i > 0` one `nextFloat` `r` is drawn and the pitch is `base + 1 / (0.5 r + 1.8)` with `base = 0.63` when `i` is odd and `0.43` when `i` is even. Range: `base + 0.4348 .. base + 0.5556`.
- **Projectile creation**: a `firework_rocket` stack makes a `FireworkRocketEntity` at `(shooter.x, shooter.eyeY - 0.15, shooter.z)` flagged as shot at an angle (the boolean constant 1 is passed); anything else creates the arrow of the ammunition item (`ArrowItem.createArrow`; an item that is not an `ArrowItem` uses the plain `arrow` item's), marks it crit when `crit` is true, and sets the arrow's sound event to `CROSSBOW_HIT`.
- **Crit rule (corrects 17 §3.9)**: in `CrossbowItem.createProjectile` the constant 1 is only the angled-shot flag of the `FireworkRocketEntity` constructor. For arrows the incoming `crit` argument is passed unchanged to `ProjectileWeaponItem.createProjectile`, which calls `setCritArrow(true)` only when it is true; `performShooting` supplies `shooter instanceof Player`. So arrows from a **player's** crossbow are crit arrows and arrows from a pillager or piglin are **not** crit. 17 §3.9, which says the crossbow passes the constant 1 so that its arrows are crit, is contradicted by the jar and its editors should correct it; the shot-pitch wording of 17 ("nextFloat x 0.5 + 0.43 style") is superseded by the exact formula in the Sound bullet above.
- **Spawn side effect**: `Projectile.spawnProjectile` calls `EnchantmentHelper.onProjectileSpawned`, which runs the weapon's `projectile_spawned` effects; the piercing level is set on the arrow in its constructor (2.7).

### 2.7 Piercing arithmetic (`AbstractArrow`)

1. The arrow constructor that takes the firing weapon stores a copy of the weapon (an empty weapon is an error), computes `p = getPiercingCount(level, weapon, ammunitionStack)` and, when `p > 0`, sets the arrow's `pierce_level` byte to `p`.
2. `onHitEntity(hit)`: `speed = |velocity|`, `base = baseDamage` raised by `EnchantmentHelper.modifyDamage` when a weapon is present (17 §3.8); `damage = ceil(clamp(speed * base, 0, 2147483647))`. If `pierce_level > 0`: the arrow keeps an id set of entities already struck (initial capacity 5). When the set size is **smaller than `pierce_level + 1`** the struck entity's id is added and the hit continues; otherwise the arrow is discarded and the hit does nothing. Hence an arrow with `pierce_level` P damages at most **P + 1** entities.
3. A crit arrow then adds `nextInt(damage / 2 + 2)` (integer division; result 0 to `damage/2 + 1`), capped at the int maximum.
4. The target is set ablaze for 5 seconds when the arrow is burning, then `hurtOrSimulate` with the arrow damage source. On success on a living entity, while `pierce_level <= 0` the target's stuck-arrow count rises by 1; knockback (`doKnockback`), post-attack enchantment effects, `doPostHurtEffects` follow; a player owner gets the arrow-hit game event (the packet "play arrow hit sound", value 0) unless the arrow is silent or the target is the owner; killed entities are collected for the `killed_by_arrow` trigger (an arrow that pierces several kills reports the whole list); the impact sound plays at volume 1 with pitch `1.2 / (0.9 + 0.2 * nextFloat)`; the arrow is discarded when `pierce_level <= 0`.
5. When the hurt fails (immune target) the arrow is deflected (reverse deflection, 0.2 factor) and, when it is almost stationary and pickup is allowed, drops its pickup item (with a 0.1 offset) and is discarded.
6. `canHitEntity` excludes entities in the struck id set; a player arrow cannot hit another player that the owner cannot harm.
7. When the arrow hits a block, it is embedded as described below and the crit flag and the pierce level are reset to 0, the sound is reset to the default hit sound, and the struck set and the killed list are cleared (so a piercing arrow that has hit a block no longer pierces). The arrow does not bounce; `AbstractArrow.onHitBlock` embeds it: it moves the arrow back along the normalised sign vector of its velocity scaled by 0.05000000074505806 (position minus that vector), sets the velocity to zero, plays the hit-ground sound (the pitch uses the constants 1.2, 0.2 and 0.9 and one `nextFloat` `r`, matching `1.2 / (0.9 + 0.2 r)` of step 4; the volume was not separately read and is (inferred) 1.0), sets `inGround` true, sets `shakeTime` to 7, and then clears the crit flag, sets `pierce_level` to 0, restores the default `ARROW_HIT` sound and clears the struck set.

## 3. Warden residual behaviours

All durations are ticks. Constants in `WardenAi`: digging duration `ceil(100.0)` = 100, emerge `ceil(133.59999)` = 134, roar `ceil(84.0)` = 84, sniffing `ceil(83.2)` = 84, dig cooldown 1200, disturbance-location expiry 100 (all agree with 20 §15).

### 3.1 Activity table (which behaviours run in which activity)

| Activity | Required memory | Contents (priority: behaviour) |
|---|---|---|
| CORE | none | 0: swim (0.8), look-target setter (`SetWardenLookTarget`), look-at-target sink (45, 90), move-to-target sink |
| EMERGE | `is_emerging` present | 5: `Emerging` (134) |
| DIG | `roar_target` absent and `dig_cooldown` absent | 0: `ForceUnmount`, 1: `Digging` (100) |
| IDLE | none | 10: `SetRoarTarget`; 11: `TryToSniff`; 12: the RunOne group (stroll 0.5 weight 2, nothing for 30 to 60 ticks weight 1; the whole group runs only while `is_sniffing` is absent). List order is that of `initIdleActivity` (read). 20 §15 words this as "SetRoarTarget first; a stroll ...; TryToSniff", which puts `TryToSniff` last; the order read here is the one intended: `TryToSniff` is second and the stroll group is last, with priorities 10, 11, 12, and the editors of 20 should adopt both the order and the priorities |
| ROAR | `roar_target` present | 10: `Roar` |
| FIGHT | `attack_target` present | 10: the `DIG_COOLDOWN_SETTER` behaviour (refreshes the 1200-tick dig cooldown, only when that memory is present, 3.3 remarks); 11: stop-attacking-if-target-invalid (callback: clear the anger of the target when `canTargetEntity` fails, then refresh the dig cooldown the same way); 12: look at the target within follow range; 13: walk to the target at 1.2 when out of reach; 14: `SonicBoom`; 15: melee (18) |
| INVESTIGATE | `disturbance_location` present | 5: `SetRoarTarget`; 6: walk to the disturbance location (completion distance 2, speed 0.7) |
| SNIFF | `is_sniffing` present | 5: `SetRoarTarget`; 6: `Sniffing` (84) |

**Priority rule** (read, `ActivityData.create(activity, startPriority, behaviours)` through `createPriorityPairs`): the behaviours of a list receive consecutive priorities `start`, `start + 1`, ... one per behaviour in list order; a lower number runs first. The single-entry activities (EMERGE 5, ROAR 10) and the explicitly numbered CORE and DIG rows are consistent with this rule.

`updateActivity` picks the **first valid** in the order EMERGE, DIG, ROAR, FIGHT, INVESTIGATE, SNIFF, IDLE.

### 3.2 `TryToSniff`

Start condition (all must hold): memory `is_sniffing` registered (need not hold a value), `walk_target` registered, `sniff_cooldown` **absent**, `nearest_attackable` **present**, `disturbance_location` **absent**. Effect, in order: set `is_sniffing`; set `sniff_cooldown` with an expiry drawn uniformly from the integers 100 to 200 inclusive (one `IntProvider` sample from the level random); erase `walk_target`; set the pose to SNIFFING. The behaviour reports success, so the brain re-evaluates and selects the SNIFF activity on the next update (it needs `is_sniffing`); `Sniffing` (20 §15) then runs 84 ticks and on stop clears `is_sniffing`.

### 3.3 `Digging`

Requires `attack_target` absent and `walk_target` absent; runs 100 ticks; `canStillUse` while the warden has not been removed. It can start only when the warden is on the ground **or** in a liquid. On start: when on the ground the pose becomes DIGGING and the `warden_dig` sound plays (volume 5.0, pitch 1.0); otherwise (in a liquid, off the ground) the `warden_agitated` sound plays and the behaviour stops at once. On stop (whether after 100 ticks or at once) the warden is **removed with reason DISCARDED** when it is not already removed. So a warden that digs in leaves the world (it does not stay buried): the 100-tick pose only animates the removal.

Remarks: the dig cooldown helper (`DIG_COOLDOWN_SETTER`, and `WardenAi.setDigCooldown`) refreshes the memory to a 1200-tick expiry **only when the memory is currently present**; it never creates it. The memory is created at `finalizeSpawn` (20 §15). The warden digs in when the cooldown has expired, no roar target exists and it has neither attack target nor walk target.

### 3.4 `Emerging`

Requires `is_emerging` present and `walk_target` absent (the look target need only be registered). On start: pose EMERGING, sound `warden_emerge` (volume 5.0, pitch 1.0). It never ends by itself (`canStillUse` is always true) and is bounded by its 134-tick duration and by the expiry of `is_emerging` (set for 134 ticks when spawned with reason TRIGGERED, 20 §15); on stop, when the pose is still EMERGING it becomes STANDING.

### 3.5 `warden_entity_sensor` (`WardenEntitySensor`)

Extends the nearest-living-entities sensor. Scan interval: **20 ticks**. The class calls the no-argument constructor of the nearest-living-entities sensor, which calls the no-argument `Sensor` constructor, which delegates to the one-argument constructor with 20 (`DEFAULT_SCAN_RATE`); the sensor-type registration only supplies a constructor, so nothing overrides it. The same holds for the breeze attack sensor (section 7). Each scan:

1. Take every living entity in the warden's bounding box inflated by the **follow range** (24, attribute value) on all three axes, except the warden itself and any entity that is not alive; sort ascending by squared distance to the warden; store it in `nearest_living_entities` (and the visibility-filtered wrapper in `nearest_visible_living_entities`).
2. From that list, pick the **first player** for which `Warden.canTargetEntity` holds; when there is none, the **first non-player** for which it holds.
3. Set `nearest_attackable` to the pick, or erase the memory when nothing qualifies.

The sensor is registered together with the `nearest_players` sensor in the warden's sensor list.

### 3.6 Anger ordering (`AngerManagement`)

Two maps: anger by entity (live entities) and anger by UUID (stored values waiting to be matched with an entity), plus the suspect list. Constants: max anger 150, conversion period 2 ticks (the initial delay is a random integer 0 to 2 inclusive), decrease 1 per manager tick (20 §15 gives the manager's call rate). `AngerLevel` constants (read in `AngerLevel.<clinit>`): CALM 0, AGITATED 40, ANGRY 80; `byAnger(value)` picks the level by these thresholds and `isAngry` is true for ANGRY only (they agree with 20 §15).

- `increaseAnger(entity, amount)`: new value `min(150, old + amount)`; when the entity had no live entry, any pending UUID value for that entity is removed and **added** to the new value (the cap is not re-applied to that sum), and the entity joins the suspect list; then the suspects are re-sorted. Returns the new value.
- `clearAnger(entity)`: remove the entry and the suspect, re-sort.
- `tick(level, filter)`: decrement the conversion delay; at or below 0, every UUID entry whose entity is now found in the level moves to the live map and the suspect list, and the delay resets to 2. Then every UUID entry with value <= 1 is dropped, else decremented by 1. Then every live entry: if the entity is removed, or its value is <= 1, or the filter rejects it, it is removed from both structures; and when the value was > 1 and the entity is removed with reason CHANGED_DIMENSION, UNLOADED_TO_CHUNK or UNLOADED_WITH_PLAYER, its value minus 1 is stored in the UUID map (so anger survives an unload or a dimension change and is re-matched by UUID); a removal with any other reason (killed, discarded) just drops the entry; a still-valid entity keeps its entry with the value decremented by 1. Finally the suspects are sorted.
- **Sort order** (`Sorter.compare(a, b)`): equal entities compare 0; an entity whose level is ANGRY (`AngerLevel.byAnger(value).isAngry()`) sorts **before** a non-angry one; among equals in angriness, a **player** sorts before a non-player; then **higher value first**. While comparing, a running maximum `highestAnger` takes the larger of the compared values. `sortAndUpdateHighestAnger` sets `highestAnger` to 0 **first**, then sorts the suspect list with `ArrayList.sort(Sorter)` (a JDK library call), then, when exactly one suspect exists, sets `highestAnger` to that suspect's value. So with no suspects it is 0 and with one suspect it is that suspect's value; it is exact only in those cases; with several suspects it is raised only by values that appear in comparator calls, and therefore depends on **which pairs the sort algorithm happens to compare** (a suspect that is never compared never contributes). The comparison sequence belongs to the JDK `ArrayList.sort` and is not in the artifact, so it cannot be answered from the jar (Open question 16). Implementer rule: treat `highestAnger` as the maximum of the values over the compared pairs as specified above (taking the maximum over all suspects is the closest reading).
- `getTopSuspect`: the first suspect in sorted order that passes the filter, or none. `getActiveEntity`: the top suspect when it is a living entity. `getActiveAnger(entity)`: `highestAnger` when the argument is null (no specific entity), else that entity's value (0 when unknown).
- Save format: a list `suspects` of records (`uuid`, `anger` >= 0); on load all values go into the UUID map.

## 4. Sulfur cube movement attributes (living-entity rules)

The three attributes are part of `LivingEntity` (not only of the sulfur cube): `createLivingAttributes` registers them for every living entity. Registered ranges (`Attributes.<clinit>`, all synced to the client):

| Attribute | Default | Min | Max |
|---|---|---|---|
| `bounciness` | 0.0 | 0.0 | 1.0 |
| `friction_modifier` | 1.0 | 0.0 | 2048.0 |
| `air_drag_modifier` | 1.0 | 0.0 | 2048.0 |

Archetype modifiers (20 §18.2): `knockback_resistance`, `explosion_knockback_resistance` and `bounciness` use `add_value`, the other two `add_multiplied_total` (17 §1 gives the attribute formula: for a lone `add_multiplied_total` amount `m` on base 1 the value is `1 * (1 + m)`, clamped to the range above). Example: archetype `regular`: friction `-0.7` gives 0.3, air drag `-0.9` gives 0.1; archetype `sticky`: friction `+1` gives 2.0, air drag `-0.99` gives 0.01; archetype `light`: air drag `+0.8` gives 1.8. Bounciness (base 0.0, `add_value`, read from the archetype JSON): `regular` 0.5, `sticky` 0.0, `light` 1.0. The stored `air_drag_modifier` amounts are -0.8999999985098839 (regular), -0.9900000002235174 (sticky) and +0.7999999523162842 (light), so the effective values are 0.1000000015, 0.0099999998 and 1.7999999523; the rounded 0.1, 0.01 and 1.8 above are fine for tests with a tolerance. The friction amounts are stored as -0.699999988079071 (regular, light) and 1.0 (sticky).

The jar holds **12** archetype files under `data/minecraft/sulfur_cube_archetype/`: `bouncy`, `explosive`, `fast_flat`, `fast_sliding`, `high_resistance`, `hot`, `light`, `regular`, `slow_bouncy`, `slow_flat`, `slow_sliding`, `sticky`. Three are tabulated here; the other nine are not (Open question 7). Additional columns for the three (read):

| Archetype | `knockback_resistance` (`add_value`) | `explosion_knockback_resistance` (`add_value`) | `buoyant` |
|---|---|---|---|
| `regular` | -1.0 | -1.0 | true |
| `sticky` | -2.0 | -2.0 | absent |
| `light` | -1.0 | -1.0 | true |

Archetype knockback and push-sound data (read from `data/minecraft/sulfur_cube_archetype/*.json`; the code that consumes them was not traced, Open question 7):

| Archetype | `knockback_modifiers.horizontal_power` | `vertical_power` | `push_sound_cooldown` | `push_sound_impulse_threshold` |
|---|---|---|---|---|
| `regular` | 0.4125 | 0.09 | 0.5 | 0.2 |
| `sticky` | 0.4125 | 0.09 | 0.5 | 0.05 |
| `light` | 0.4125 | 0.18 | 0.7 | 0.2 |

### 4.1 Friction and drag helper

`computeModifiedFriction(base, modifier) = clamp(1 - (1 - base) * modifier, 0, 1)` (single precision).

### 4.2 Ground and air movement (`LivingEntity.travelInAir`)

Applies to a living entity that is not in a fluid and not flying (the fluid and gliding paths use their own constants and were not re-read).

1. `blockFriction` = `Block.getFriction()` of the block below that affects movement (default 0.6 for blocks with no `friction` property override). When the entity is on the ground, `f = computeModifiedFriction(blockFriction, friction_modifier)`; in the air `f = 1.0`.
2. Movement input is applied with `getFrictionInfluencedSpeed(f)`: on the ground, `f > 0.6` gives `speed * 0.21600002 / f³`, `f <= 0.6` gives `speed`; in the air the flying speed (0.02, or `speed * 0.1` when the controlling passenger is a player). Then the entity moves (climbing handling aside).
3. Vertical velocity `y`: with the Levitation effect `y += (0.05 * (amplifier + 1) - y) * 0.2`; otherwise, **on the server, gravity always applies**: `y -= effectiveGravity`, with no chunk test. The loaded-chunk test exists only when the level is client side: a client whose chunk at the entity position is loaded subtracts gravity, and a client with the chunk absent uses -0.1 when the entity is above the world's minimum Y, else 0 (so that fallback concerns clients only).
4. If the entity "discards friction" its velocity becomes `(vx, y, vz)`. Otherwise `a = air_drag_modifier`; horizontal factor `H = f * computeModifiedFriction(0.91, a)`; vertical factor `V = computeModifiedFriction(0.91, a)` when the entity is an omnidirectional air mover, else `computeModifiedFriction(0.98, a)`; the new velocity is `(vx * H, y * V, vz * H)`.
5. `getAirDrag()` (used by the restitution step below) is the same `V` expression: `computeModifiedFriction(omnidirectional ? 0.91 : 0.98, air_drag_modifier)`.

### 4.3 Bounce (`Entity.restituteMovementAfterCollisions`)

Runs in `Entity.move` when movement is simulated here and (the vertical movement component was non-zero and a vertical collision occurred, or a horizontal collision occurred). Inputs: the block below, whether the X movement and the Z movement were stopped by a collision, and the requested movement vector. Let `v` = the entity's current velocity, `b` = bounce factor, 0 when the entity suppresses bounce (`isSuppressingBounce` = shift key down, so sneaking), else `getEntityBounciness()`, which for a living entity is its `bounciness` attribute value (0 for non-living entities).

1. For each horizontal axis that collided, that velocity component becomes `-v_axis * b`.
2. `bouncy` flag = `b > 0` and at least one horizontal axis collided.
3. If a vertical collision occurred: when it was **not below** (a ceiling hit) the vertical factor is simply `b`, with no block term and no gravity test. When it was below, and the downward speed does not exceed the effective gravity (`-v.y <= gravity`), or the entity suppresses bounce, or the block below is in the block tag `suppresses_bounce`, the vertical bounce factor is 0, else it is `max(b, getBlockBounciness(block))` where `getBlockBounciness` is the block's `bounce_restitution` property multiplied by 0.8 when the entity is **not** a living entity. The property default is 0 (the field has no initialiser; read). Blocks that set it in `Blocks.<clinit>`: `slime_block` 1.0, the per-colour bed factory 0.75 (the bed family; the pairing is read, 6.3) and `shelf_mushroom` 0.75. The bed factory and `shelf_mushroom` also set `fallDistanceReduction` 0.5. The block tag `suppresses_bounce` holds only `honey_block`. A vertical bounce with factor > 0 uses `r = requestedMovement.y / v.y`, gravity term `r * effectiveGravity`, and drag term `lerp(r, 1.0, getAirDrag())`, and sets the flag; the new vertical velocity is `(gravityTerm - v.y) * dragTerm * factor` (with factor 0: the term is 0 and the drag term is 1, so the new vertical velocity is 0).
4. If the flag is set, the block below's `bounceOn(level, state, pos, entity, fallDistance)` runs, the game event `bounce` is emitted and the entity's position is flagged for synchronisation. Finally the new velocity is stored.

Notes: `v` is the **pre-collision velocity** (read). In `Entity.move` the only `setDeltaMovement` calls are before `collide` and after the whole collision and bounce step; nothing zeroes a velocity component between `collide` and this restitution step. The zeroing of a collided axis happens inside this step through the factor: the new component is `-v * b`, which is 0 when there is no bounce (`b = 0`). (This closes the former Open question 10.)

### 4.4 Worked examples (4.1 to 4.2)

All with block friction 0.6, speed attribute `S` (any), vertical velocity before gravity `y`:

| Archetype | friction mod | air drag mod | `f` on ground | `H` | `V` (non-omni) |
|---|---|---|---|---|---|
| `regular` | 0.3 | 0.1 | `1 - 0.4*0.3 = 0.88` | `0.88 * (1 - 0.09*0.1) = 0.88 * 0.991 = 0.87208` | `1 - 0.02*0.1 = 0.998` |
| `sticky` | 2.0 | 0.01 | `1 - 0.4*2.0 = 0.2` | `0.2 * (1 - 0.09*0.01) = 0.2 * 0.9991 = 0.19982` | `0.9998` |
| `light` | 0.3 | 1.8 | 0.88 | `0.88 * (1 - 0.09*1.8) = 0.88 * 0.838 = 0.73744` | `1 - 0.02*1.8 = 0.964` |
| plain (no modifier) | 1.0 | 1.0 | 0.6 | `0.6 * 0.91 = 0.546` | 0.98 |

Speed influence with `regular` (`f = 0.88 > 0.6`): the movement speed input is multiplied by `0.216 / 0.88³ = 0.3170` (to four places); with `sticky` (`f = 0.2 <= 0.6`) by 1.

## 5. Entity-type id check (20 Open question 25)

`EntityTypes.<clinit>` assigns each entity type one registry id in the order the fields are registered (161 entries; the key of every entry equals the lower-case name of its field, checked against `EntityTypeIds`); `Registry.register` appends, so the **id is the zero-based position in this list**. All 32 id values that documents 20 and 21 state in their `minecraft:<key>` | id tables were compared with this list by script and all agree. The list (id: key):

0 acacia_boat; 1 acacia_chest_boat; 2 allay; 3 area_effect_cloud; 4 armadillo; 5 armor_stand; 6 arrow; 7 axolotl; 8 bamboo_chest_raft; 9 bamboo_raft; 10 bat; 11 bee; 12 birch_boat; 13 birch_chest_boat; 14 blaze; 15 block_display; 16 bogged; 17 breeze; 18 breeze_wind_charge; 19 camel; 20 camel_husk; 21 cat; 22 cave_spider; 23 cherry_boat; 24 cherry_chest_boat; 25 chest_minecart; 26 chicken; 27 cod; 28 copper_golem; 29 command_block_minecart; 30 cow; 31 creaking; 32 creeper; 33 cushion; 34 dark_oak_boat; 35 dark_oak_chest_boat; 36 dolphin; 37 donkey; 38 dragon_fireball; 39 drowned; 40 egg; 41 elder_guardian; 42 enderman; 43 endermite; 44 ender_dragon; 45 ender_pearl; 46 end_crystal; 47 evoker; 48 evoker_fangs; 49 experience_bottle; 50 experience_orb; 51 eye_of_ender; 52 falling_block; 53 fireball; 54 firework_rocket; 55 fox; 56 frog; 57 furnace_minecart; 58 ghast; 59 happy_ghast; 60 giant; 61 glow_item_frame; 62 glow_squid; 63 goat; 64 guardian; 65 hoglin; 66 hopper_minecart; 67 horse; 68 husk; 69 illusioner; 70 interaction; 71 iron_golem; 72 item; 73 item_display; 74 item_frame; 75 jungle_boat; 76 jungle_chest_boat; 77 leash_knot; 78 lightning_bolt; 79 llama; 80 llama_spit; 81 magma_cube; 82 mangrove_boat; 83 mangrove_chest_boat; 84 mannequin; 85 marker; 86 minecart; 87 mooshroom; 88 mule; 89 nautilus; 90 oak_boat; 91 oak_chest_boat; 92 ocelot; 93 ominous_item_spawner; 94 painting; 95 pale_oak_boat; 96 pale_oak_chest_boat; 97 panda; 98 parched; 99 parrot; 100 phantom; 101 pig; 102 piglin; 103 piglin_brute; 104 pillager; 105 polar_bear; 106 poplar_boat; 107 poplar_chest_boat; 108 splash_potion; 109 lingering_potion; 110 pufferfish; 111 rabbit; 112 ravager; 113 salmon; 114 sheep; 115 shulker; 116 shulker_bullet; 117 silverfish; 118 skeleton; 119 skeleton_horse; 120 slime; 121 small_fireball; 122 sniffer; 123 snowball; 124 snow_golem; 125 spawner_minecart; 126 spectral_arrow; 127 spider; 128 spruce_boat; 129 spruce_chest_boat; 130 squid; 131 stray; 132 strider; 133 sulfur_cube; 134 tadpole; 135 text_display; 136 tnt; 137 tnt_minecart; 138 trader_llama; 139 trident; 140 tropical_fish; 141 turtle; 142 vex; 143 villager; 144 vindicator; 145 wandering_trader; 146 warden; 147 wind_charge; 148 witch; 149 wither; 150 wither_skeleton; 151 wither_skull; 152 wolf; 153 zoglin; 154 zombie; 155 zombie_horse; 156 zombie_nautilus; 157 zombie_villager; 158 zombified_piglin; 159 player; 160 fishing_bobber.

Notes: the order is the registration order of the class initialiser, which is mostly alphabetical by key with exceptions (the potion entities `splash_potion`, `lingering_potion` follow `poplar_chest_boat`, `cushion` follows `creeper`, `player` and `fishing_bobber` are last). This is a static reading; whether the registry-sync packet's own id numbering equals the registry position (and not a separately sorted one) is the 04 §5.1 rule and was not re-tested against a capture (Open question 11).

## 6. Block blast resistance and the explosion resistance lookup (20 Open question 27)

### 6.1 Where the number comes from

1. Each block has one float `explosionResistance`, set by its `BlockBehaviour$Properties` while `Blocks.<clinit>` registers it: `strength(h, r)` sets destroy time `h` and resistance `r`; `strength(x)` sets both to `x`; `instabreak()` is `strength(0)`; an explicit `explosionResistance(r)` overrides the resistance; **every setter of the resistance clamps it to `max(0, r)`** (so `-1` becomes 0; unbreakable blocks use destroy time -1 and a huge resistance). A block registered with no strength call keeps the default 0.
2. Copies: `ofLegacyCopy(other)` and `ofFullCopy(other)` copy the other block's properties, including the resistance (stairs, slabs and walls are registered this way from their full block; `registerSlab(id, base, d)` replaces only the destroy time; `registerSlab(id, base, d, r)` replaces both).
3. `InfestedBlock`'s constructor halves the copied block's destroy time and sets the resistance to **0.75**; the registered infested blocks therefore have resistance 0.75.
4. `Block.getExplosionResistance()` returns this float. Fluids: `FluidState.getExplosionResistance()` is 100.0 for water and lava (their fluid classes), 0 for the empty fluid.

### 6.2 The lookup used by explosions

`ExplosionDamageCalculator.getBlockExplosionResistance(explosion, level, pos, blockState, fluidState)` (default): when the block is air **and** the fluid is empty it returns "no value" (the ray passes through at no cost, see 20 §6.2); otherwise `max(block resistance, fluid resistance)`. Variants:

| Calculator | Change |
|---|---|
| Entity-based (default for entity explosions) | the default value, then passed through the source entity's `getBlockExplosionResistance(explosion, level, pos, block, fluid, value)`; `shouldBlockExplode` is also delegated to the entity |
| Simple (used by wind charges and other configured explosions) | when a list of immune blocks is configured and the block is in it, the value is **3600000.0**; when it is configured and the block is not in it, "no value" (no cost); with no list the default applies. It carries three more settings: whether blocks explode, whether entities are damaged, an optional knockback multiplier (players that are flying take 0 knockback) |
| Primed TNT (anonymous subclass) | `nether_portal` blocks: "no value" and never explode; otherwise default |
| Respawn anchor (anonymous subclass) | at the anchor's own position, when it is in water, the value is water's block resistance; otherwise default |

Entity overrides of `getBlockExplosionResistance`: the base `Entity` returns the passed value unchanged and `shouldBlockExplode` is true; a dangerous (charged) wither skull returns `min(0.8, value)` for blocks the wither can destroy (the `WitherBoss.canDestroy` test); a primed TNT minecart returns 0 and does not allow the block to explode when the block is a rail or the block above is a rail (so it never destroys its own track).

### 6.3 Resistance of every block in `Blocks` (878 plain `Block` fields; the colour families are separate)

Values below are read from `Blocks.<clinit>`; each group lists the blocks (registry key) that have that resistance. For the 7 infested blocks the value is from 6.1 item 3. Group sizes are in parentheses; the sum is 878, the number of plain `Block` fields (each is listed exactly once). The colour families are separate `ColorCollection` fields of `Blocks` and are not in the 878.

**0** (187): air, oak_sapling, spruce_sapling, birch_sapling, jungle_sapling, acacia_sapling, cherry_sapling, dark_oak_sapling, pale_oak_sapling, mangrove_propagule, poplar_sapling, short_grass, fern, dead_bush, bush, red_shrub, short_dry_grass, tall_dry_grass, seagrass, tall_seagrass, moving_piston, dandelion, golden_dandelion, torchflower, poppy, blue_orchid, allium, azure_bluet, red_tulip, orange_tulip, white_tulip, pink_tulip, oxeye_daisy, cornflower, wither_rose, lily_of_the_valley, brown_mushroom, red_mushroom, tnt, torch, wall_torch, fire, soul_fire, redstone_wire, wheat, redstone_torch, redstone_wall_torch, cactus_flower, sugar_cane, soul_torch, soul_wall_torch, copper_torch, copper_wall_torch, nether_portal, repeater, attached_pumpkin_stem, attached_melon_stem, pumpkin_stem, melon_stem, resin_clump, lily_pad, resin_block, nether_wart, shelf_mushroom, tripwire_hook, tripwire, flower_pot, potted_torchflower, potted_oak_sapling, potted_spruce_sapling, potted_birch_sapling, potted_jungle_sapling, potted_acacia_sapling, potted_cherry_sapling, potted_dark_oak_sapling, potted_pale_oak_sapling, potted_poplar_sapling, potted_mangrove_propagule, potted_fern, potted_dandelion, potted_golden_dandelion, potted_poppy, potted_blue_orchid, potted_allium, potted_azure_bluet, potted_red_tulip, potted_orange_tulip, potted_white_tulip, potted_pink_tulip, potted_oxeye_daisy, potted_cornflower, potted_lily_of_the_valley, potted_wither_rose, potted_red_mushroom, potted_brown_mushroom, potted_dead_bush, potted_cactus, carrots, potatoes, comparator, slime_block, sunflower, lilac, rose_bush, peony, tall_grass, large_fern, end_rod, torchflower_crop, pitcher_crop, pitcher_plant, beetroots, structure_void, kelp, kelp_plant, dried_ghast, dead_tube_coral, dead_brain_coral, dead_bubble_coral, dead_fire_coral, dead_horn_coral, tube_coral, brain_coral, bubble_coral, fire_coral, horn_coral, dead_tube_coral_fan, dead_brain_coral_fan, dead_bubble_coral_fan, dead_fire_coral_fan, dead_horn_coral_fan, tube_coral_fan, brain_coral_fan, bubble_coral_fan, fire_coral_fan, horn_coral_fan, dead_tube_coral_wall_fan, dead_brain_coral_wall_fan, dead_bubble_coral_wall_fan, dead_fire_coral_wall_fan, dead_horn_coral_wall_fan, tube_coral_wall_fan, brain_coral_wall_fan, bubble_coral_wall_fan, fire_coral_wall_fan, horn_coral_wall_fan, sea_pickle, potted_bamboo, void_air, cave_air, bubble_column, scaffolding, sweet_berry_bush, warped_fungus, warped_roots, nether_sprouts, crimson_fungus, weeping_vines, weeping_vines_plant, twisting_vines, twisting_vines_plant, crimson_roots, honey_block, potted_crimson_fungus, potted_warped_fungus, potted_crimson_roots, potted_warped_roots, cave_vines, cave_vines_plant, spore_blossom, azalea, flowering_azalea, pink_petals, wildflowers, leaf_litter, small_dripleaf, hanging_roots, potted_azalea, potted_flowering_azalea, frogspawn, decorated_pot, pale_hanging_moss, open_eyeblossom, closed_eyeblossom, potted_open_eyeblossom, potted_closed_eyeblossom, firefly_bush

**0.1** (8): snow, candle, moss_carpet, moss_block, big_dripleaf, big_dripleaf_stem, pale_moss_block, pale_moss_carpet

**0.2** (24): oak_leaves, spruce_leaves, birch_leaves, jungle_leaves, acacia_leaves, cherry_leaves, dark_oak_leaves, pale_oak_leaves, mangrove_leaves, red_poplar_leaves, orange_poplar_leaves, yellow_poplar_leaves, azalea_leaves, flowering_azalea_leaves, straw_bed, snow_block, brown_mushroom_block, red_mushroom_block, mushroom_stem, vine, glow_lichen, daylight_detector, sculk, sculk_vein

**0.25** (3): suspicious_sand, suspicious_gravel, powder_snow

**0.3** (10): glass, glowstone, glass_pane, redstone_lamp, sea_lantern, bee_nest, tinted_glass, ochre_froglight, verdant_froglight, pearlescent_froglight

**0.4** (7): ladder, cactus, netherrack, chorus_plant, chorus_flower, warped_nylium, crimson_nylium

**0.5** (53): dirt, coarse_dirt, podzol, sand, red_sand, lever, stone_pressure_plate, oak_pressure_plate, spruce_pressure_plate, birch_pressure_plate, jungle_pressure_plate, acacia_pressure_plate, cherry_pressure_plate, dark_oak_pressure_plate, pale_oak_pressure_plate, mangrove_pressure_plate, poplar_pressure_plate, bamboo_pressure_plate, stone_button, ice, soul_sand, soul_soil, cake, brewing_stand, oak_button, spruce_button, birch_button, jungle_button, acacia_button, cherry_button, dark_oak_button, pale_oak_button, mangrove_button, poplar_button, bamboo_button, light_weighted_pressure_plate, heavy_weighted_pressure_plate, hay_block, packed_ice, frosted_ice, magma_block, turtle_egg, sniffer_egg, crimson_pressure_plate, warped_pressure_plate, crimson_button, warped_button, target, polished_blackstone_pressure_plate, polished_blackstone_button, candle_cake, rooted_dirt, mud

**0.6** (10): grass_block, gravel, sponge, wet_sponge, farmland, clay, mycelium, composter, beehive, honeycomb_block

**0.65** (1): dirt_path

**0.7** (6): mangrove_roots, muddy_mangrove_roots, powered_rail, detector_rail, rail, activator_rail

**0.75** (8): infested_stone, infested_cobblestone, infested_stone_bricks, infested_mossy_stone_bricks, infested_cracked_stone_bricks, infested_chiseled_stone_bricks, calcite, infested_deepslate

**0.8** (19): sandstone, chiseled_sandstone, cut_sandstone, note_block, sandstone_stairs, quartz_block, chiseled_quartz_block, quartz_pillar, quartz_stairs, red_sandstone, chiseled_red_sandstone, cut_red_sandstone, red_sandstone_stairs, quartz_slab, red_sandstone_slab, cut_red_sandstone_slab, red_sandstone_wall, sandstone_wall, quartz_bricks

**1** (76): oak_sign, spruce_sign, birch_sign, acacia_sign, cherry_sign, jungle_sign, dark_oak_sign, pale_oak_sign, mangrove_sign, poplar_sign, bamboo_sign, oak_wall_sign, spruce_wall_sign, birch_wall_sign, acacia_wall_sign, cherry_wall_sign, jungle_wall_sign, dark_oak_wall_sign, pale_oak_wall_sign, mangrove_wall_sign, poplar_wall_sign, bamboo_wall_sign, oak_hanging_sign, spruce_hanging_sign, birch_hanging_sign, acacia_hanging_sign, cherry_hanging_sign, jungle_hanging_sign, dark_oak_hanging_sign, pale_oak_hanging_sign, crimson_hanging_sign, warped_hanging_sign, mangrove_hanging_sign, poplar_hanging_sign, bamboo_hanging_sign, oak_wall_hanging_sign, spruce_wall_hanging_sign, birch_wall_hanging_sign, acacia_wall_hanging_sign, cherry_wall_hanging_sign, jungle_wall_hanging_sign, dark_oak_wall_hanging_sign, pale_oak_wall_hanging_sign, mangrove_wall_hanging_sign, poplar_wall_hanging_sign, crimson_wall_hanging_sign, warped_wall_hanging_sign, bamboo_wall_hanging_sign, carved_pumpkin, jack_o_lantern, pumpkin, melon, skeleton_skull, skeleton_wall_skull, wither_skeleton_skull, wither_skeleton_wall_skull, zombie_head, zombie_wall_head, player_head, player_wall_head, creeper_head, creeper_wall_head, dragon_head, dragon_wall_head, piglin_head, piglin_wall_head, nether_wart_block, bamboo_sapling, bamboo, warped_wart_block, shroomlight, crimson_sign, warped_sign, crimson_wall_sign, warped_wall_sign, dripstone_block

**1.5** (13): sticky_piston, piston, piston_head, bookshelf, chiseled_bookshelf, amethyst_block, budding_amethyst, amethyst_cluster, large_amethyst_bud, medium_amethyst_bud, small_amethyst_bud, sculk_sensor, calibrated_sculk_sensor

**2** (58): pale_oak_wood, oak_log, spruce_log, birch_log, jungle_log, acacia_log, cherry_log, dark_oak_log, pale_oak_log, mangrove_log, poplar_log, bamboo_block, stripped_spruce_log, stripped_birch_log, stripped_jungle_log, stripped_acacia_log, stripped_cherry_log, stripped_dark_oak_log, stripped_pale_oak_log, stripped_oak_log, stripped_mangrove_log, stripped_poplar_log, stripped_bamboo_block, oak_wood, spruce_wood, birch_wood, jungle_wood, acacia_wood, cherry_wood, dark_oak_wood, mangrove_wood, poplar_wood, stripped_oak_wood, stripped_spruce_wood, stripped_birch_wood, stripped_jungle_wood, stripped_acacia_wood, stripped_cherry_wood, stripped_dark_oak_wood, stripped_pale_oak_wood, stripped_mangrove_wood, stripped_poplar_wood, cauldron, water_cauldron, lava_cauldron, powder_snow_cauldron, bone_block, shulker_box, campfire, soul_campfire, warped_stem, stripped_warped_stem, warped_hyphae, stripped_warped_hyphae, crimson_stem, stripped_crimson_stem, crimson_hyphae, stripped_crimson_hyphae

**2.5** (10): chest, crafting_table, trapped_chest, dried_kelp_block, loom, barrel, cartography_table, fletching_table, lectern, smithing_table

**2.8** (1): blue_ice

**3** (139): oak_planks, spruce_planks, birch_planks, jungle_planks, acacia_planks, cherry_planks, dark_oak_planks, pale_oak_planks, mangrove_planks, poplar_planks, bamboo_planks, bamboo_mosaic, gold_ore, deepslate_gold_ore, iron_ore, deepslate_iron_ore, coal_ore, deepslate_coal_ore, nether_gold_ore, lapis_ore, deepslate_lapis_ore, lapis_block, acacia_shelf, bamboo_shelf, birch_shelf, cherry_shelf, crimson_shelf, dark_oak_shelf, jungle_shelf, mangrove_shelf, oak_shelf, pale_oak_shelf, poplar_shelf, spruce_shelf, warped_shelf, oak_stairs, diamond_ore, deepslate_diamond_ore, oak_door, redstone_ore, deepslate_redstone_ore, oak_fence, oak_trapdoor, spruce_trapdoor, birch_trapdoor, jungle_trapdoor, acacia_trapdoor, cherry_trapdoor, dark_oak_trapdoor, pale_oak_trapdoor, mangrove_trapdoor, poplar_trapdoor, bamboo_trapdoor, packed_mud, mud_bricks, oak_fence_gate, mud_brick_stairs, cocoa, emerald_ore, deepslate_emerald_ore, spruce_stairs, birch_stairs, jungle_stairs, beacon, nether_quartz_ore, acacia_stairs, cherry_stairs, dark_oak_stairs, pale_oak_stairs, mangrove_stairs, poplar_stairs, bamboo_stairs, bamboo_mosaic_stairs, oak_slab, spruce_slab, birch_slab, jungle_slab, acacia_slab, cherry_slab, dark_oak_slab, pale_oak_slab, mangrove_slab, poplar_slab, bamboo_slab, bamboo_mosaic_slab, mud_brick_slab, spruce_fence_gate, birch_fence_gate, jungle_fence_gate, acacia_fence_gate, cherry_fence_gate, dark_oak_fence_gate, pale_oak_fence_gate, mangrove_fence_gate, poplar_fence_gate, bamboo_fence_gate, spruce_fence, birch_fence, jungle_fence, acacia_fence, cherry_fence, dark_oak_fence, pale_oak_fence, mangrove_fence, poplar_fence, bamboo_fence, spruce_door, birch_door, jungle_door, acacia_door, cherry_door, dark_oak_door, pale_oak_door, mangrove_door, poplar_door, bamboo_door, observer, conduit, mud_brick_wall, crimson_planks, warped_planks, crimson_slab, warped_slab, crimson_fence, warped_fence, crimson_trapdoor, warped_trapdoor, crimson_fence_gate, warped_fence_gate, crimson_stairs, warped_stairs, crimson_door, warped_door, sculk_catalyst, sculk_shrieker, copper_ore, deepslate_copper_ore, pointed_dripstone, sulfur_spike

**3.5** (10): dispenser, furnace, dropper, smoker, blast_furnace, stonecutter, lantern, soul_lantern, lodestone, crafter

**4** (1): cobweb

**4.2** (4): basalt, polished_basalt, terracotta, smooth_basalt

**4.8** (1): hopper

**5** (4): spawner, iron_door, iron_trapdoor, bell

**6** (189): stone, granite, polished_granite, diorite, polished_diorite, andesite, polished_andesite, cobblestone, gold_block, iron_block, bricks, mossy_cobblestone, diamond_block, cobblestone_stairs, jukebox, stone_bricks, mossy_stone_bricks, cracked_stone_bricks, chiseled_stone_bricks, iron_bars, iron_chain, brick_stairs, stone_brick_stairs, resin_bricks, resin_brick_stairs, resin_brick_slab, resin_brick_wall, chiseled_resin_bricks, nether_bricks, nether_brick_fence, nether_brick_stairs, emerald_block, cobblestone_wall, mossy_cobblestone_wall, redstone_block, prismarine, prismarine_bricks, dark_prismarine, prismarine_stairs, prismarine_brick_stairs, dark_prismarine_stairs, prismarine_slab, prismarine_brick_slab, dark_prismarine_slab, coal_block, stone_slab, sandstone_slab, cut_sandstone_slab, petrified_oak_slab, cobblestone_slab, brick_slab, stone_brick_slab, nether_brick_slab, smooth_stone, smooth_stone_slab, smooth_sandstone, smooth_quartz, smooth_red_sandstone, purpur_block, purpur_slab, purpur_pillar, purpur_stairs, red_nether_bricks, dead_tube_coral_block, dead_brain_coral_block, dead_bubble_coral_block, dead_fire_coral_block, dead_horn_coral_block, tube_coral_block, brain_coral_block, bubble_coral_block, fire_coral_block, horn_coral_block, polished_granite_stairs, smooth_red_sandstone_stairs, mossy_stone_brick_stairs, polished_diorite_stairs, mossy_cobblestone_stairs, stone_stairs, smooth_sandstone_stairs, smooth_quartz_stairs, granite_stairs, andesite_stairs, red_nether_brick_stairs, polished_andesite_stairs, diorite_stairs, polished_granite_slab, smooth_red_sandstone_slab, mossy_stone_brick_slab, polished_diorite_slab, mossy_cobblestone_slab, smooth_sandstone_slab, smooth_quartz_slab, granite_slab, andesite_slab, red_nether_brick_slab, polished_andesite_slab, diorite_slab, brick_wall, prismarine_wall, mossy_stone_brick_wall, granite_wall, stone_brick_wall, nether_brick_wall, andesite_wall, red_nether_brick_wall, diorite_wall, grindstone, blackstone, blackstone_stairs, blackstone_wall, blackstone_slab, polished_blackstone, polished_blackstone_bricks, cracked_polished_blackstone_bricks, chiseled_polished_blackstone, polished_blackstone_brick_slab, polished_blackstone_brick_stairs, polished_blackstone_brick_wall, gilded_blackstone, polished_blackstone_stairs, polished_blackstone_slab, polished_blackstone_wall, chiseled_nether_bricks, cracked_nether_bricks, tuff, tuff_slab, tuff_stairs, tuff_wall, polished_tuff, polished_tuff_slab, polished_tuff_stairs, polished_tuff_wall, chiseled_tuff, tuff_bricks, tuff_brick_slab, tuff_brick_stairs, tuff_brick_wall, chiseled_tuff_bricks, sulfur, potent_sulfur, sulfur_slab, sulfur_stairs, sulfur_wall, polished_sulfur, polished_sulfur_slab, polished_sulfur_stairs, polished_sulfur_wall, sulfur_bricks, sulfur_brick_slab, sulfur_brick_stairs, sulfur_brick_wall, chiseled_sulfur, cinnabar, cinnabar_slab, cinnabar_stairs, cinnabar_wall, polished_cinnabar, polished_cinnabar_slab, polished_cinnabar_stairs, polished_cinnabar_wall, cinnabar_bricks, cinnabar_brick_slab, cinnabar_brick_stairs, cinnabar_brick_wall, chiseled_cinnabar, deepslate, cobbled_deepslate, cobbled_deepslate_stairs, cobbled_deepslate_slab, cobbled_deepslate_wall, polished_deepslate, polished_deepslate_stairs, polished_deepslate_slab, polished_deepslate_wall, deepslate_tiles, deepslate_tile_stairs, deepslate_tile_slab, deepslate_tile_wall, deepslate_bricks, deepslate_brick_stairs, deepslate_brick_slab, deepslate_brick_wall, chiseled_deepslate, cracked_deepslate_bricks, cracked_deepslate_tiles, raw_iron_block, raw_copper_block, raw_gold_block

**9** (6): end_stone, dragon_egg, end_stone_bricks, end_stone_brick_stairs, end_stone_brick_slab, end_stone_brick_wall

**10** (1): creaking_heart

**50** (2): trial_spawner, vault

**100** (2): water, lava

**600** (1): ender_chest

**1200** (11): obsidian, enchanting_table, anvil, chipped_anvil, damaged_anvil, netherite_block, ancient_debris, crying_obsidian, respawn_anchor, reinforced_deepslate, heavy_core

**3600000** (11): bedrock, end_portal, end_portal_frame, command_block, end_gateway, repeating_command_block, chain_command_block, structure_block, jigsaw, test_block, test_instance_block

**3600000.75** (2): barrier, light. The literal in `Blocks.<clinit>` is the float `3600000.8f`; float spacing at that magnitude is 0.25, so the stored value is exactly **3600000.75**. Use single precision (a decimal 3600000.8 would differ). The `3600000` of the group above and the `SimpleExplosionDamageCalculator` immune value 3600000.0 are exact floats.

**Colour families** (each has the 16 dye colours and is a `ColorCollection` field of `Blocks`; the `invokedynamic` Function immediately before each `ColorCollection.registerBlocks` call names its lambda through the bootstrap table, so the pairing is read, not inferred): `bed` = lambda 44, strength 0.2 (also `bounceRestitution` 0.75, `fallDistanceReduction` 0.5, wood sound); `wool` = lambda 49, 0.8; `stained_glass` = lambda 158, 0.3; `dyed terracotta` = lambda 254, 1.25 destroy time and **4.2** resistance; `stained_glass_pane` = lambda 255, 0.3; `carpet` = lambda 258, 0.1; `glazed_terracotta` = lambda 294, 1.4; `concrete` = lambda 296, 1.8; `concrete_powder` = lambda 300, 0.5. Also: `banner` and `wall_banner` 1.0; `dyed_shulker_box` 2.0 (the shared shulker helper); `dyed_candle` 0.1 (the shared candle helper); wool and concrete stairs and slabs copy their full block (0.8 and 1.8); the colored candle cake copies the plain candle cake (its own value is in the groups above). `shelf_mushroom` also carries `fallDistanceReduction` 0.5 and `slime_block` has friction 0.8. Water and lava source blocks are in the group 100.

Special cases inside the groups: the unbreakable blocks (bedrock, barrier, command blocks, end portal frame and the like) have the 3600000 values; the "0" group includes air, all plants, torches, redstone components without strength and blocks with no strength call (default).

## 7. Breeze attack sensor (`BreezeAttackEntitySensor`)

Extends the nearest-living-entities sensor (the same scan as section 3.5 step 1 of this document, with the breeze's own follow range of 24). Each scan it takes `nearest_living_entities`, drops creative and spectator players (`EntitySelector.NO_CREATIVE_OR_SPECTATOR`), keeps entities for which `Sensor.isEntityAttackable(level, breeze, target)` holds (the framework's attackable test with the breeze's attack-target conditions, 18), takes the **first in list order** (nearest first) and sets `nearest_attackable` to it, or erases the memory when none qualifies. The breeze's own `canAttack` rule (only players and iron golems, 20 §16) applies through that test. The breeze wind charge entity (id 18) and its explosion belong to 44-8.

## 8. Creaking heart block entity (`CreakingHeartBlockEntity`)

State: a link to one protector creaking, held either as a live reference or as a UUID; `ticksExisted`, a tick countdown `ticker`, a particle `emitter` counter with a target point, and the cached analog output. The block state property `creaking_heart_state` has the values UPROOTED, DORMANT and AWAKE.

**Server tick** (every tick, server only; `ticksExisted` rises by 1 first):

1. Recompute the comparator output (see below); when it changed, store it and notify neighbours.
2. When `emitter > 0` (a hurt visual is running): while `emitter > 50` it spawns the two particle bursts each tick; when `emitter mod 10 == 0` and a target point exists it calls the hurt effect on the protector, computes `t = 0.2 + 0.8 * (100 - emitter) / 100`, plays `creaking_heart_hurt` at the block `lerp(target, centre, t)` position with pitch `0.5 + (emitter / 2) / 100` and volume 1; then `emitter` falls by 1.
3. The state update runs only on some ticks. Each tick the counter `ticker` is decremented by 1, and the **value read before the decrement** is tested: when it was `>= 0` the tick ends here; only when it was **below 0** does the rest of the tick run, after which `ticker` is reset to `R = 20 + nextInt(5)` (20 to 24; when the block entity has no level the reset value is 20). After a reset to `R` the counter takes `R + 1` ticks to reach -1 and the body runs on the following tick, so the body runs **R + 2 ticks later**: a period of 22 to 26 ticks.
4. State (`hasRequiredLogs`, read: the block on **each** side of the heart along its `axis` property must be in the block tag `pale_oak_logs` and have the same `axis` value as the heart): when the block no longer has its required logs (hasRequiredLogs false) and there is no creaking link, the state becomes UPROOTED; otherwise it is AWAKE when the environment attribute `gameplay/creaking_active` is true at the block position, else DORMANT. A change is written with a block update. When the new state is UPROOTED the tick ends.
5. When a link exists: obtain the protector; if there is a protector and (the attribute is false and the creaking does not require persistence, or the creaking is farther than **34** blocks from the heart, or the creaking reports that a player is stuck in it) the protector is removed (`removeProtector(null)`: `tearDown`). The tick ends.
6. When there is no link and the state is AWAKE: spawning needs the server to allow monsters and difficulty not Peaceful, and any non-spectator player within **32** blocks (`Level.getNearestPlayer(x, y, z, 32.0, false)`: the last argument is the filter-out-creative flag, and with `false` the selector is `EntitySelector.NO_SPECTATORS` read in `EntityGetter.getNearestPlayer`, so creative players DO count and only spectators are excluded); then `spawnProtector`: `SpawnUtil.trySpawnMob(creaking, reason SPAWNER, level, heartPos, attempts 5, horizontal range 16, vertical range 8, strategy ON_TOP_OF_COLLIDER_NO_LEAVES, final boolean true)`; on success the game event `entity_place` is emitted at the creaking, entity event 60 is broadcast, the creaking is marked transient with the heart position as home, the link is set, the creaking makes its spawn sound and the heart plays `creaking_heart_spawn` (volume 1, pitch 1).

**Link resolution** (`getCreakingProtector`): a live reference is used while the entity is not removed; a removed one is converted to its UUID. A UUID is looked up in the server level; when found as a creaking it becomes the live link; when not found and `ticksExisted >= 30` the link is cleared (grace period of 30 ticks after a UUID link was set, which resets `ticksExisted` to 0).

**Hurt** (`creakingHurt`, called when the creaking is damaged): ignored when there is no protector, on a client, or while `emitter > 0`. Otherwise: 20 particle emissions (non-ongoing), then, when the heart is AWAKE, `nextIntBetweenInclusive(2, 3)` resin spreads (below), then `emitter = 100` and the target point is the protector's bounding-box centre.

**Resin spread** (`spreadResin`): a breadth-first traversal from the heart with maximum depth 2 and at most 64 positions, using the level random. Rules (read):

1. **Neighbour enumeration**: from a visited position, the six directions are shuffled with the level random and each neighbour that is in the block tag `pale_oak_logs` is offered to the traversal; so the traversal moves only through pale oak logs.
2. **Visit**: a visited position that is not a pale oak log is accepted with no action. At a log position, the six directions are shuffled again (a second, independent shuffle). For each direction `d` in that order, the neighbour `n = pos + d` is examined with the face `f = opposite(d)` (the face of `n` that looks back at the log):
   - `n` is air: the candidate is a `resin_clump` default state;
   - `n` is a water source block: the candidate is a `resin_clump` with `waterlogged` true;
   - otherwise the candidate is `n`'s current state.
   When the candidate is a `resin_clump` that does **not** yet have face `f`, face `f` is set on it, the result is written to `n` with a block update, `n` is recorded as the changed position, and the traversal **stops**. Any other neighbour (not air, not a water source, not a clump, or a clump already having `f`) is skipped and the next direction is tried; a log with no usable neighbour is accepted and the traversal continues.
3. The function returns the recorded position, if any, for particles. In a separate callback (`creakingHurt`) the `resin_place` sound (volume 1, pitch 1, block sound source) is played at that position and a `block_place` game event is emitted.

**Removal**: `removeProtector(source)`: with a protector, a null source runs `tearDown`; a source runs the creaking's death effects, sets the tearing-down flag and sets its health to 0; the link is then cleared. `preRemoveSideEffects` (heart broken) calls `removeProtector(null)`.

**Comparator output**: 0 without a protector, else `15 - floor(15 * clamp(distance_to_protector, 0, 32) / 32)`.

**Save**: key `creaking` holds the protector's UUID (live links are saved as their UUID; load installs a UUID link, or clears when absent).

## 9. Worked examples

1. **Quick Charge**: level 2: `1.25 + (-0.25 + -0.25 * 1) = 0.75` s, `floor(0.75 * 20) = 15` ticks; level 3: `0.5` s, 10 ticks. A crossbow with Quick Charge 5 (command-given) would give `1.25 - 1.25 = 0`, a charge duration of 0: it loads on the first tick with elapsed >= 1 (2.3 step 2: NaN at elapsed 0, +Infinity after); level 6 gives `-0.25`, clamped to 0.
2. **Multishot fan**: level 1, n = 3, spread 10: `s = 2*10/2 = 10`, `b = (2 mod 2)*10/2 = 0`; angles 0, -10, +10. With a data-pack variant of n = 2 and spread 10: `s = 20`, `b = 10`: angles +10 then -10.
3. **Crossbow ammunition**: a player with Multishot and a stack of 5 arrows fires 3 arrows and the stack drops to 4; the second and third arrows are intangible (cannot be picked up). A creative player: all three intangible, stack unchanged.
4. **Piercing**: Piercing 2 gives `pierce_level` 2, so one arrow damages up to 3 entities in a line; the fourth is not damaged and the arrow vanishes.
5. **Crossbow damage (with 17)**: arrow speed 3.15, base 2.0 (17 §3.9), no Power: `ceil(3.15 * 2.0) = 7`; a crit adds `nextInt(7/2 + 2) = nextInt(5)`: final 7 to 11.
6. **Shot pitch**: shot index 1 with `r = 0.5`: `0.63 + 1/(0.25 + 1.8) = 0.63 + 0.4878 = 1.1178`; index 2: `0.43 + 0.4878 = 0.9178`; index 0: exactly 1.0 with no draw.
7. **Warden sniff cycle**: idle warden with a nearest attackable player, no disturbance, no sniff cooldown: `TryToSniff` sets the sniff cooldown to U(100..200) ticks, pose SNIFFING; 84 ticks later `Sniffing` ends and `increaseAngerAt` (35) is applied if the nearest attackable is within 6 horizontally and 20 vertically (20 §15); the next sniff cannot start before the cooldown expires.
8. **Warden sensor**: a pig at 3 blocks and a player at 10 blocks, both inside the 24-block box and both passing `canTargetEntity`: the pick is the **player** (players first) even though the pig is nearer; with the player out of the box the pick is the pig.
9. **Anger sort**: suspects A (player, 60, not angry), B (zombie, 90, angry), C (player, 85, angry): order C (angry, player), B (angry), A; top suspect C; `highestAnger` depends on which pairs the sort compares (3.6): it can only be raised by values that appear in comparator calls, so 90 is reached only if B takes part in a comparison, which is likely but not guaranteed by the rules read. With a single suspect it is exactly that suspect's value.
10. **Explosion resistance**: a ray in a creeper explosion crossing a water source block: block resistance 100, fluid 100, value 100; the strength drops by `(100 + 0.3) * 0.3 = 30.09`, far more than a 3 power ray holds (about 2.1 to 3.9 at the start); obsidian (1200) and bedrock (3600000) stop all rays; a wall of `glass` (0.3) costs `(0.3 + 0.3) * 0.3 = 0.18` per sample.
11. **Sulfur cube on stone**: see 4.4; the `regular` cube on friction 0.6 keeps 87.2 % of its horizontal speed per tick before bounce effects, the `sticky` cube 20.0 %.

## 10. Validation

An implementation can check itself against:

1. `getChargeDuration` returns 25, 20, 15, 10 for Quick Charge 0 to 3, and 0 for any level >= 5 (such a crossbow loads on the first tick with elapsed >= 1).
2. Multishot with n = 3, spread 10 spawns projectiles with angle offsets 0, -10, +10 degrees in that order; n = 2 gives +S then -S; loading (`draw` and `useAmmo`, not `shoot`) consumes exactly 1 ammunition (or 0 for creative or infinity-matching ammunition) however many projectiles are fired.
3. The charged component is emptied before the projectiles are created.
4. A mob crossbow with an empty hand slot fires a fresh arrow every shot.
5. An arrow with `pierce_level` P damages exactly P + 1 distinct entities when enough are in line.
6. Shot pitch index 0 consumes no random number; others consume one.
7. Warden: the sniff cooldown is uniform in 100 to 200; digging ends by removing the warden after 100 ticks; emerging lasts 134 ticks; the nearest-attackable pick prefers players.
8. Anger sort order: angry before not angry, then players first, then higher value; increases cap at 150.
9. `computeModifiedFriction(0.6, 0.3) = 0.88`, `(0.6, 2.0) = 0.2`, `(0.6, 10) = 0` (clamped), `(0.91, 0.1) = 0.991`.
10. The id of `warden` is 146, `breeze` 17, `creaking` 31 and the registry has 161 entries.
11. `obsidian` 1200, `bedrock` 3600000, stone 6.0, water 100.0, glass 0.3, tnt 0; an explosion ray never gains strength; the resistance is clamped to 0 at registration.
12. Creaking heart comparator output at distance 0 is 15, at 32 or more it is 0; the protector is removed when farther than 34 blocks; the state update runs every 22 to 26 ticks.
13. On a server, a living entity in the air always loses `effectiveGravity` from its vertical velocity (no chunk test).
14. A mob crossbow shot uses power 1.6; the sulfur cube `regular` bounciness is 0.5.

## 10A. Further readings (fix pass of round RS26)

Read from `SpecialDates`, the explosion-hit methods of block classes, `Raid` and the English language file.

1. **Halloween date source** (`SpecialDates`): `HALLOWEEN` is the month-day 31 October; `isHalloween` is true when the month-day of the **current wall-clock date** (`ZonedDateTime.now()` in the host's default time zone) equals it. The same class holds `CHRISTMAS_RANGE` = 24, 25 and 26 December, `CHRISTMAS` = 24 December and `NEW_YEAR` = 1 January. A server therefore needs only the host date; the world's game time plays no part.
2. **Trigger-block reactions** (20 §6.2). The explosion-hit hook of each class below does nothing unless the explosion reports that it can trigger blocks. `ServerExplosion.canTriggerBlocks` is true when `blockInteraction == TRIGGER_BLOCK` AND (the explosion source is not a `breeze_wind_charge` entity OR the `mob_griefing` game rule is true); `shouldAffectBlocklikeEntities` also reads `mob_griefing`. The base hook ignores air and acts only when the block interaction is not TRIGGER_BLOCK; the classes read here override it:

| Block class | Reaction when the explosion can trigger blocks |
|---|---|
| Buttons (`ButtonBlock`) | when not `powered`: press it (powered, neighbour update, release tick scheduled, click sound, `block_activate` game event) |
| Doors (`DoorBlock`) | only the LOWER half, when the door's block set `canOpenByWindCharge` and it is not `powered`: toggle `open` |
| Trapdoors (`TrapDoorBlock`) | when the block set `canOpenByWindCharge` and it is not `powered`: toggle `open` (with the water tick when waterlogged) |
| Fence gates (`FenceGateBlock`) | when not `powered`: toggle `open` and play the wood type's open or close sound |
| Bell (`BellBlock`) | attempt to ring the bell (no direction) |

   `BlockSetType.canOpenByWindCharge` is the second boolean of the constructor (after `canOpenByHand`, before `canButtonBeActivatedByArrows`). Read values: iron false (false, false, false); gold true (false, true, false); copper, stone, polished_blackstone, cherry, crimson, warped and bamboo true; the one-argument wood types (oak, spruce, birch, acacia, jungle, dark_oak, pale_oak, poplar, mangrove) all true. So only the iron door and iron trapdoor are never opened by a wind charge. Which other block classes (levers, candles, TNT and so on) override the hook remains unread (Open question 3).
3. **Raid bar texts**: the English language file has `event.minecraft.raid` = "Raid", `event.minecraft.raid.raiders_remaining` = "Raiders Remaining: %s", `event.minecraft.raid.victory` = "Victory", `event.minecraft.raid.defeat` = "Defeat", `event.minecraft.raid.victory.full` = "Raid - Victory" and `event.minecraft.raid.defeat.full` = "Raid - Defeat". `Raid` builds the raiders-remaining component from the `raiders_remaining` key (with a " - " separator constant nearby); how the bar title is composed in each phase was not traced (Open question 2).
4. **Block resistance setters** (extends 6.1): `strength(h, r)` calls the destroy-time setter and then `explosionResistance(r)`, which stores `max(0, r)`; `strength(x)` calls `strength(x, x)`; `instabreak()` calls `strength(0)`. `InfestedBlock` is the one block class that sets the resistance itself (0.75).

## 11. Open questions

1. Villages (points of interest, village bookkeeping, golem spawn rules, siege) are covered by [44-3](44-residual-mob-questions-3-villagers-poi-raids.md) and not repeated here.
2. Still not traced from the "not traced" lines of 20 §4 to §14 (not searched in the fix pass): skeleton family, creeper, spiders, enderman, silverfish, slime, witch, phantom statistic reset, ravager, vex (non-village parts), and the zombie family beyond the Halloween date (read, 10A item 1). Of the illager raid-bar strings only the language keys were read (10A item 3); the composition of the bar title per phase was not traced.
3. Trigger-block reactions: five block classes were read (10A item 2); `canTriggerBlocks` and the `BlockSetType` values are now answered there. Not read: whether other block classes (levers, candles, TNT and others) override the explosion-hit hook; only the classes named in 10A were searched.
4. 20 Open question 12 (mineshaft cave-spider spawners and mansion spawns) belongs to 44-2 (structure spawners); not searched here.
5. Wind charge entities (`breeze_wind_charge`, `wind_charge`): damage, knockback, explosion parameters: see 44-8.
6. Spawning of the breeze through trial spawners: see 44-2.
7. Sulfur cube: the archetype knockback and push-sound data for `regular`, `sticky` and `light` are now in 4 (read); the other nine archetypes (12 files exist, 4) were not tabulated, and the code that consumes them (the push constants 1.3, 0.5, 0.3, 0.16, 0.3, 1.6, 0.5, 0.8, 0.25 listed in 20 §18.2) was not traced.
8. Closed: `remove_binomial` small and large branches are read (2.1); `levels_squared`, `lookup` and `exponent` are closed too.
9. Closed: the warden and breeze entity sensors scan every 20 ticks (3.5).
10. Closed: `v` in the bounce step is the pre-collision velocity (4.3).
11. The entity id list was recomputed from the registration order; the actual registry-sync numbering was not captured (needs a run).
12. Closed: `hasRequiredLogs` and `spreadResin` rules are in section 8 (read, including the face being the opposite of the iteration direction).
13. Closed: the colour-family pairing is read from the `invokedynamic` lambda before each `ColorCollection.registerBlocks` call (6.3). The 878 plain-block values come directly from `Blocks.<clinit>`. Blocks whose classes might override resistance were checked by searching for the setter name: only `Block`, `Blocks`, `Properties` and `InfestedBlock` contain it; the `Properties` clamp `max(0, r)` and the routing of both `strength` forms through it are read (10A item 4).
14. Closed: `AngerLevel` thresholds CALM 0, AGITATED 40, ANGRY 80 were read (3.6).
15. The `gameplay/creaking_active` and other environment attribute values are read from the data pack timeline (12 §3); only their use is specified here.
16. Not answerable from the artifact: `highestAnger` with several suspects depends on the comparison sequence of the JDK `ArrayList.sort` used by the suspect list (searched: `AngerManagement.sortAndUpdateHighestAnger` and `Sorter`; the call is a library call). See the implementer rule in 3.6.
17. Arrow hit-ground sound on embedding (2.7 step 7): the volume argument was not read separately (inferred 1.0); searched `AbstractArrow.onHitBlock` constants only.
