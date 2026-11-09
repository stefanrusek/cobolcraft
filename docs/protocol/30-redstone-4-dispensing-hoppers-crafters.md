# 30-4 Redstone: dispensers, droppers, hoppers and crafters

| Item | Value |
|---|---|
| Covers | `DispenserBlock` and `DropperBlock` (facing, `triggered`, quasi-connectivity, the 4-tick delay, slot choice, events and sounds); the whole `DispenseItemBehavior` registry (every registered item grouped by behaviour, the default-choice rules, every behaviour's inputs, effects, return value, events and sounds); `HopperBlock` (state, shape, placement, locking by signal) with the pointer to the hopper block entity transfer engine already specified in 31-2; `CrafterBlock` (state, placement, the dispatch algorithm, comparator output) with the corrections found while re-reading it. Round RS12 (GAP-10c of `docs/design/README.md`), Part 4 of the redstone family |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the client's level-event handler (every case of the sound table in section 2, including 1018 `blaze.shoot`, was read in its switch), with no execution. Class names are cited only to say where a fact was read. Nothing was taken from memory without a read in this round; items marked "(inferred)" or "(not read)" are listed in Open questions |
| Data versus code | Per the operator decisions, data rows are not tabulated. Not tabulated here: the item tags `sulfur_cube_swallowable`; the block tags `beehives`, `rails`, `convertible_to_mud`; the fluid tag `water`; the `equippable` component values that a data pack supplies (slot, `dispensable`, allowed entity types), the recipes the crafter matches, and the potion contents of items. They come from the data pack the extraction tool builds (22, 23). The item defaults are not only data: the item class builds several `equippable` components in code (saddle, harness per colour, llama carpet per colour, the carved pumpkin: slot HEAD, not swappable, camera overlay `misc/pumpkinblur`), and the `Equippable` record has a `dispensable` flag with a setter whose default is true (inferred from the constructor; the builder default was not traced to the end). This document specifies the code-defined behaviours that read them |
| Siblings | Scope not covered here is in the sibling files of this family, all present in the repository (30-6, 30-7 and 30-8 already cite this document as part 4): 30-1 (shared power model, redstone wire, torches, `hasNeighborSignal`, `hasSignal`); 30-2 (repeaters, comparators, observers; the container signal of 31-2 section 2.5 is consumed there); 30-3 (pistons and the move resolver); 30-5 (switches, plates, sensors, note blocks; buttons, levers, daylight detectors, target blocks, lightning rods as far as that file lists them); 30-6 (rails; the hopper minecart is driven by the same transfer functions); 30-7 (doors, trapdoors, gates, lamps, copper bulbs, TNT ignition); 30-8 (tripwire, sculk sensors, bells, vibration). The jukebox is in 31-4 |
| Cross references | 31-7 (vault and trial spawner, which also call the default `spawnItem`), 31-2 (block entities: sections 5 hopper, 6 dispenser and dropper, 7 crafter, whose facts are not repeated, only extended and corrected), 29 (block updates, `DirectionalPlaceContext`), 29b-1 (bone meal growth, `BoneMealItem.growCrop`), 41 (item entity physics and pickup), 42-7 section 8 (level events 1000 to 3003, the dispenser smoke particles 2000 and 2010, bone meal 1505, wax 3003), 44-8 (projectile framework: `Projectile.shoot`, `getMovementToShoot`, arrows, potions, wind charges, boats, minecarts), 45-8 (entity save data), 18 (mob framework: equipment slots), 26 (loot, recipes), 13 section 3 (recipe cache), 46 (registry ids) |

All tick values are game ticks (20 per second). Directions are the six `Direction` values; "front" means the block next to the dispenser or dropper in its `facing` direction (`pos.relative(facing)`), and `centre` is `Vec3.atCenterOf(pos)` (position plus 0.5 on every axis). `BlockSource` is a record of (server level, position, block state, dispenser block entity); `centre()` is the block centre.

## 1. Dispenser and dropper blocks

### 1.1 State and placement (`DispenserBlock`)

| Item | Value |
|---|---|
| Properties | `facing` (all six directions, default NORTH), `triggered` (boolean, default false) |
| Placement | `facing = getNearestLookingDirection().getOpposite()`. The block therefore faces **away** from the way the placer looks, including up and down. `triggered` starts false |
| Block entity | `DispenserBlockEntity` (dropper: `DropperBlockEntity`), 9 slots, 31-2 section 6 |
| `rotate` / `mirror` | `facing` is rotated by the `Rotation` or mirrored through `Mirror.getRotation` |
| Use (right click) | server side only: open the container menu; award the stat `inspect_dropper` when the entity is a dropper, otherwise `inspect_dispenser`; the result is SUCCESS in every case |
| Analog output | has one; the value is the container signal of 31-2 section 2.5 (`AbstractContainerMenu.getRedstoneSignalFromBlockEntity`) |
| Removal | `Containers.updateNeighboursAfterDestroy` (31-2 section 2.8); the contents are dropped by the block entity |
| `TRIGGER_DURATION` | 4 |

### 1.2 Triggering (`neighborChanged`, `tick`)

Verified against 31-2 section 6.3. On every neighbour change at the position:

1. `powered = level.hasNeighborSignal(pos) OR level.hasNeighborSignal(pos.above())`. The second test is the **quasi-connectivity**: a power source that would power the block above the dispenser also triggers it, even though nothing powers the dispenser itself. `hasNeighborSignal(p)` is the "any of the six neighbours gives a signal towards `p`" test of part 1.
2. If `powered` and not `triggered`: schedule a block tick for this block at this position **4 ticks** later, and write `triggered = true` with update flags 2 (client sync only, no neighbour update).
3. Else if not `powered` and `triggered`: write `triggered = false` with flags 2. No tick is scheduled.
4. Otherwise nothing.

There is no `onPlace` or `setPlacedBy` handling: a dispenser placed next to a powered source with `triggered = false` fires on the first neighbour update it receives. The scheduled `tick` simply runs `dispenseFrom(level, state, pos)`. Because `triggered` is set when the pulse starts and cleared only when the power ends, one rising edge produces exactly one dispense, however long the signal stays on. A pulse shorter than 4 ticks still dispenses once: the tick was scheduled when `triggered` went true, and it is not cancelled when `triggered` goes false again.

### 1.3 `dispenseFrom` (dispenser)

Specified in 31-2 section 6.4; the registry it refers to is section 3 of this document. Order of effects for one tick:

1. Block entity missing: log and stop.
2. `slot = getRandomSlot(level.getRandom())` (31-2 section 6.2: reservoir selection, one `nextInt(n)` per non-empty slot in slot order).
3. `slot < 0` (empty): level event **1001** at the position (data 0), then game event `block_activate` with the block state as context. Stop.
4. `behaviour = getDispenseMethod(level, stack)`: the default behaviour when the item is not enabled by the level's feature flags; else the registry entry for the item (identity map keyed by `Item`); else `getDefaultDispenseMethod` (section 3.1).
5. If `behaviour != NOOP`: the slot is set to `behaviour.dispense(source, stack)`. `NOOP` is the constant `DispenseItemBehavior.NOOP`, a lambda that returns the stack unchanged; it is not registered for any item here, so in practice every item takes the other branch.

### 1.4 Dropper (`DropperBlock`)

Verified against 31-2 section 6.6, with additions:

1. Same block entity lookup (log and stop), same `getRandomSlot`.
2. `slot < 0`: level event 1001 at the position and stop. **No game event** is fired (Open question 3 of 31-2 closed: the dropper has none).
3. `stack = item in slot`. **If the stack is empty, stop** with no write and no event (cannot normally happen after `getRandomSlot`).
4. The facing is **re-read from the block state in the world** at the position (not from the state passed to the tick). `target = HopperBlockEntity.getContainerAt(level, pos.relative(facing))` (31-2 section 5.7).
5. No container: `result = DISPENSE_BEHAVIOUR.dispense(source, stack)`, where the constant is a plain `DefaultDispenseItemBehavior` (section 2). The registry is never consulted, so a dropper drops every item, including TNT, as an item entity (events 1000 and 2000 play).
6. A container: `rest = HopperBlockEntity.addItem(dropper, target, stack.copyWithCount(1), facing.getOpposite())`. If `rest` is empty, `result = stack.copy()` reduced by 1; otherwise `result = stack.copy()` unchanged. **No level event of any kind** is fired on the container path (no click, no smoke).
7. `slot := result`. (`addItem` already marked the target changed through `tryMoveInItem`.)

## 2. The default dispense behaviour and event system

`DefaultDispenseItemBehavior` is the base of every behaviour. `dispense(source, stack)` is **final** and always runs, in this order: `result = execute(source, stack)`; `playSound(source)`; `playAnimation(source, facing)`; return `result`. Subclasses override `execute`, `playSound` and `playAnimation`, never `dispense`.

| Hook | Default | Effect |
|---|---|---|
| `playSound` | level event **1000**, data 0, at the dispenser position | sound `dispenser.dispense`, block category, volume 1.0, pitch 1.0 (client handler of 42-7 section 8) |
| `playAnimation` | level event **2000**, data `facing.get3DDataValue()` | smoke particles streaming from the front face (`shootParticles`, 42-7 section 8.1). 2010 is the same with white smoke and is used by the crafter only |

`DEFAULT_ACCURACY = 6`.

`execute` (default): `position = DispenserBlock.getDispensePosition(source)`; `one = stack.split(1)`; `spawnItem(level, one, 6, facing, position)`; return the reduced stack. `getDispensePosition(source, offset, extra)` is `centre + offset * facing_step + extra`; the default call uses offset 0.7 and extra zero.

`spawnItem(level, stack, accuracy, facing, position)` is also called by the vault and the trial spawner (31-7) with accuracy 2 and direction UP, so accuracy is not always 6. It is exactly as 31-2 section 6.5: `y -= 0.125` when the facing axis is Y, else `y -= 0.15625`; an `ItemEntity` at that point; `speed = nextDouble() * 0.1 + 0.2`; motion `(triangle(stepX * speed, 0.0172275 * accuracy), triangle(0.2, 0.0172275 * accuracy), triangle(stepZ * speed, 0.0172275 * accuracy))` where `triangle(c, d) = c + d * (nextDouble() - nextDouble())`; random order: `speed`, then x, y, z triangles (two draws each); `addFreshEntity`. The item entity's pickup delay and ageing are 41.

`consumeWithRemainder(source, stack, remainder)` (read again): `stack.shrink(1)`; if empty return `remainder`; otherwise return the stack after `addToInventoryOrDispense(remainder)`: `DispenserBlockEntity.insertItem(remainder)` and, if anything is left, `spawnItem` of the leftover (accuracy 6, default position, facing as above). The caller's own `playSound`/`playAnimation` still run afterwards.

`OptionalDispenseItemBehavior` (abstract, extends default) adds a boolean `success`, **initially true and kept in the behaviour object** (one object serves every dispenser and every use of its items). Its `playSound` is event **1000** when `success`, event **1001** otherwise (so a failed attempt plays the dry-click sound instead of the dispense sound). `playAnimation` stays the default (event 2000 is always sent, success or not). Behaviours that extend it set `success` themselves; section 4 notes the ones that never set it back to true.

Level event client sounds used in this document (read in `LevelEventHandler`, all through `playLocalSound(pos, sound, category, volume, pitch, false)`):

| Id | Sound event | Category | Volume | Pitch |
|---|---|---|---|---|
| 1000 | `dispenser.dispense` | blocks | 1.0 | 1.0 |
| 1001 | `dispenser.fail` | blocks | 1.0 | 1.2 |
| 1002 | `dispenser.launch` | blocks | 1.0 | 1.2 |
| 1004 | `firework_rocket.shoot` | neutral | 1.0 | 1.2 |
| 1018 | `blaze.shoot` | hostile | 2.0 | `(r1 - r2) * 0.2 + 1.0` with two `nextFloat` draws of the client's level random, r1 first |
| 1049 | `crafter.craft` | blocks | 1.0 | 1.0 |
| 1050 | `crafter.fail` | blocks | 1.0 | 1.0 |
| 1051 | `wind_charge.throw` | blocks | 0.5 | `0.4 / (nextFloat * 0.4 + 0.8)` with one draw |

Level event 1505 (bone meal growth particles) with data 15, 2000 and 2010 (smoke), and 3003 (wax on particles) are in 42-7 section 8; sounds that behaviours play directly on the server (`TNT_PRIMED`, `BOTTLE_EMPTY`, `HONEYCOMB_WAX_ON`, `BEEHIVE_SHEAR`) are server `playSound` calls with the volume and pitch stated below.

## 3. The behaviour registry

### 3.1 Choosing a behaviour (`DispenserBlock.getDispenseMethod`)

1. The item is not enabled by the level's feature flags: `DefaultDispenseItemBehavior` (the shared instance `DEFAULT_BEHAVIOR`).
2. `DISPENSER_REGISTRY` (an identity map from `Item` to behaviour, filled by `DispenseItemBehavior.bootStrap`): the registered entry if present.
3. Otherwise `getDefaultDispenseMethod(stack)`, the first rule that matches:
   1. the stack has the `equippable` component: `EquipmentDispenseItemBehavior.INSTANCE` (section 4.9);
   2. the stack is in the item tag `sulfur_cube_swallowable`: `SulfurCubeBlockDispenseItemBehavior.INSTANCE` (section 4.12);
   3. the item is a `SpawnEggItem` **and** the stack has the `entity_data` component: `SpawnEggItemBehavior.INSTANCE` (section 4.11);
   4. `DEFAULT_BEHAVIOR`.

Registered entries win over the default rules. So an item with `equippable` that is also registered (the carved pumpkin, the wither skeleton skull) uses its own behaviour, which itself falls back to `dispenseEquipment` (4.7, 4.8).

### 3.2 Registered items by behaviour (read from `bootStrap`, in registration order)

`registerProjectileBehavior(item)` registers a `ProjectileDispenseBehavior` for the item. Counting: 13 projectile items, 1 armor stand, 1 chest, 22 boats and rafts, 10 filled-bucket items sharing one behaviour, 1 empty bucket, flint and steel, bone meal, TNT, wither skeleton skull, carved pumpkin, 17 shulker boxes (the undyed one plus the 16 of the `DYED_SHULKER_BOX` colour collection), glass bottle, glowstone, shears, brush, honeycomb, potion, 6 minecarts.

| Group | Items | Behaviour | Section |
|---|---|---|---|
| Projectiles | `arrow`, `tipped_arrow`, `spectral_arrow`, `egg`, `blue_egg`, `brown_egg`, `snowball`, `experience_bottle`, `splash_potion`, `lingering_potion`, `firework_rocket`, `fire_charge`, `wind_charge` | `ProjectileDispenseBehavior` (each item's own `ProjectileItem` configuration) | 4.1 |
| Armor stand | `armor_stand` | anonymous `$1` | 4.2 |
| Chest | `chest` | anonymous `$2` (extends Optional) | 4.3 |
| Boats | `oak_boat`, `spruce_boat`, `birch_boat`, `jungle_boat`, `dark_oak_boat`, `acacia_boat`, `cherry_boat`, `mangrove_boat`, `poplar_boat`, `pale_oak_boat`, `bamboo_raft`, and the eleven matching `*_chest_boat` / `bamboo_chest_raft` items | `BoatDispenseItemBehavior(entity type)` | 4.4 |
| Filled buckets | `lava_bucket`, `water_bucket`, `powder_snow_bucket`, `salmon_bucket`, `cod_bucket`, `pufferfish_bucket`, `tropical_fish_bucket`, `axolotl_bucket`, `sulfur_cube_bucket`, `tadpole_bucket` | anonymous `$3`, one shared instance | 4.5 |
| Empty bucket | `bucket` | anonymous `$4` | 4.6 |
| Flint and steel | `flint_and_steel` | `FlintAndSteelDispenseItemBehavior` | 4.10 |
| Bone meal | `bone_meal` | anonymous `$5` (extends Optional) | 4.13 |
| TNT | the `tnt` block item | anonymous `$6` (extends Optional) | 4.14 |
| Wither skull | `wither_skeleton_skull` | anonymous `$7` (extends Optional) | 4.7 |
| Carved pumpkin | the `carved_pumpkin` block item | anonymous `$8` (extends Optional) | 4.8 |
| Shulker boxes | `shulker_box` and the 16 dyed boxes | one shared `ShulkerBoxDispenseBehavior` | 4.15 |
| Glass bottle | `glass_bottle` | anonymous `$9` (extends Optional) | 4.16 |
| Glowstone | `glowstone` (the block item) | anonymous `$10` (extends Optional) | 4.17 |
| Shears | `shears` | `ShearsDispenseItemBehavior` | 4.18 |
| Brush | `brush` | anonymous `$11` (extends Optional) | 4.19 |
| Honeycomb | `honeycomb` | anonymous `$12` (extends Optional) | 4.20 |
| Water potion | `potion` | anonymous `$13` | 4.21 |
| Minecarts | `minecart`, `chest_minecart`, `furnace_minecart`, `tnt_minecart`, `hopper_minecart`, `command_block_minecart` | `MinecartDispenseItemBehavior(entity type)` | 4.22 |

Items not in the table (every other item) use rule 3 of 3.1: items that carry the `equippable` component (read in code: saddle, harness, llama carpet; the carved pumpkin is registered and so not in this rule; armor, elytra, wolf armor and mob heads were not read in this round, (not read), Open question 7), swallowable items, spawn eggs, and everything else drops as an item entity.

## 4. The behaviours

Every behaviour below finishes with the final `dispense` of section 2 (events 1000 or 1001, then 2000) unless it says its `playSound` is overridden. "Front block" is `pos.relative(facing)`. "Front box" is the `AABB` of the front block, `getEntitiesOfClass(type, new AABB(frontPos), filter)`; entities come back in the world's entity-query order and the first one that passes is used. "Fallback" means the default spawn of section 2 (`DefaultDispenseItemBehavior.execute`, one item entity). Where a behaviour contains a **second** `DefaultDispenseItemBehavior` object and calls its `dispense` as the fallback (boat, minecart, filled bucket, potion), that call plays events 1000 and 2000 itself and the outer `dispense` then plays them **again**: such a fallback emits the click and the smoke twice at the same position.

### 4.1 Projectiles (`ProjectileDispenseBehavior`)

Constructed with an item that must be a `ProjectileItem` (otherwise `IllegalArgumentException`). Each projectile item supplies a `DispenseConfig` of four values: `positionFunction`, `uncertainty`, `power`, and an optional `overrideDispenseEvent`. The defaults (`DispenseConfig.DEFAULT`): `positionFunction` = `centre + 0.7 * facing_step + (0, 0.1, 0)`, `uncertainty` 6.0, `power` 1.1, event override absent.

`execute(source, stack)`:
1. `position = config.positionFunction(source, facing)`.
2. `projectile = item.asProjectile(level, position, stack, facing)` (item-specific, table below).
3. `Projectile.spawnProjectileUsingShoot(projectile, level, stack, facing.stepX, facing.stepY, facing.stepZ, power, uncertainty)`: applies the shot (`Projectile.shoot(dx, dy, dz, power, uncertainty)`, 44-8 section 6.1: velocity `normalize(d) + triangle(0, 0.0172275 * uncertainty)` per axis, times `power`; rotations from the velocity) and adds the entity to the level. Read order inside `Projectile.spawnProjectileUsingShoot`: a consumer that calls `shoot(dx, dy, dz, power, uncertainty)` on the projectile **before** it is added to the level; then `addFreshEntity`; then `applyOnProjectileSpawned(level, stack)`, which runs the enchantment spawn hook for the stack and, only for an `AbstractArrow` with a non-empty weapon item, a weapon-item branch. Dispenser arrows have a null weapon, so that branch is skipped.
4. `stack.shrink(1)`; return the stack.

`playSound`: level event `config.overrideDispenseEvent` when present, else **1002** (`dispenser.launch`); data 0. `playAnimation` is the default (2000).

| Item | Entity made by `asProjectile` | positionFunction | uncertainty | power | sound event |
|---|---|---|---|---|---|
| `arrow` | `Arrow` at the position with a one-item copy of the stack; `pickup = ALLOWED` | default | 6.0 | 1.1 | 1002 |
| `spectral_arrow` | `SpectralArrow`, same shape (one-item copy, `pickup = ALLOWED`) | default | 6.0 | 1.1 | 1002 |
| `tipped_arrow` | read: `TippedArrowItem` extends `ArrowItem` and declares only a constructor, `getDefaultInstance` and `getName`, with no `asProjectile` override, so it uses the `ArrowItem` path: an `Arrow` built from `copyWithCount(1)` of the stack with a null weapon argument, `pickup = ALLOWED` (the stack's potion contents therefore travel with the arrow) | default | 6.0 | 1.1 | 1002 |
| `egg`, `blue_egg`, `brown_egg` | `ThrownEgg(level, x, y, z, stack)` (the stack carries the variant) | default | 6.0 | 1.1 | 1002 |
| `snowball` | `Snowball(level, x, y, z, stack)` | default | 6.0 | 1.1 | 1002 |
| `experience_bottle` | `ThrownExperienceBottle(level, x, y, z, stack)` | default | `6.0 * 0.5 = 3.0` | `1.1 * 1.25 = 1.375` | 1002 |
| `splash_potion` | `ThrownSplashPotion(level, x, y, z, stack)` | default | 3.0 | 1.375 | 1002 |
| `lingering_potion` | `ThrownLingeringPotion(level, x, y, z, stack)` | default | 3.0 | 1.375 | 1002 |
| `firework_rocket` | `FireworkRocketEntity(level, one-item copy, x, y, z, shotAtAngle = true)` | `centre + 0.5000099999997474 * facing_step` (no extra y) | 1.0 | 0.5 | 1004 |
| `fire_charge` | `SmallFireball(level, x, y, z, normalize(v))` with `v = (triangle(stepX, 0.11485000000000001), triangle(stepY, 0.11485000000000001), triangle(stepZ, 0.11485000000000001))`, drawn in x, y, z order (two `nextDouble` per axis) from the level random; then `setItem(stack)` | `centre + 1.0 * facing_step` | 6.6666665 | 1.0 | 1018 |
| `wind_charge` | `WindCharge(level, x, y, z, v)` with the same `v` formula (not normalised); then `setDeltaMovement(v)` | `centre + 1.0 * facing_step` | 6.6666665 | 1.0 | 1051 |

Random sources: the `asProjectile` triangles of the fire charge and wind charge (0.11485000000000001) come from the **level random** (`Level.getRandom`); the `shoot` triangles (0.0172275 * uncertainty) come from the **projectile entity's own `random` field**. `FireChargeItem` and `WindChargeItem` each override `ProjectileItem.shoot` with an empty body, but that override is bypassed here, because `Projectile.spawnProjectileUsingShoot` calls `Projectile.shoot` directly through its lambda, so the re-aim happens.

For the fire charge and the wind charge, `asProjectile` consumes the random draws first (6 `nextDouble`), then `spawnProjectileUsingShoot` calls `shoot`, which draws three more triangles (6 `nextDouble`), in the order x, y, z. The `shoot` velocity overrides the delta movement set inside `asProjectile` (the wind charge sets it explicitly, the small fireball keeps the direction it was constructed with and is then re-shot). Shooting power and flight are in 44-8 (arrow section 7, wind charge, fireball motion, thrown items, potion clouds, and the firework rocket).

### 4.2 Armor stand (`$1`)

`execute`: `pos = frontPos`. Spawn an `ArmorStand` with `EntityType.spawn(level, postSpawn, pos, DISPENSER, alignPosition = false, alignY = false)` where `postSpawn` composes the default stack configuration (`EntityType.appendDefaultStackConfig`: entity data and custom name from the stack's components) with the step "set `yRot = facing.toYRot()`" (the armor stand looks the way the dispenser points; for UP or DOWN `toYRot` is 0). If the spawn returned an entity, `stack.shrink(1)`. Return the stack. Default events 1000 and 2000 (the sound plays even when the spawn failed). The spawn position passed is the front block position; with both alignment flags false `EntityType.spawn` places the entity at (blockX + 0.5, blockY, blockZ + 0.5), the bottom centre of the front block with no y offset. It then snaps the entity with a **random yaw** (the level random `nextFloat() * 360`, wrapped) and pitch 0 and sets a `Mob`'s head and body rotation to that yaw; this level-random draw is part of the RNG sequence. The armor stand post-spawn step then overwrites `yRot` with `facing.toYRot()`.

### 4.3 Chest (`$2`, extends Optional)

`execute`: gather `AbstractChestedHorse` entities in the front box whose filter is "alive and has no chest" (`isAlive() && !hasChest()`). For each in order: if it `isTamed()`, take its `SlotAccess` for slot index **499** (the chest slot); if that access exists and `set(stack)` returns true: `stack.shrink(1)`; `success = true`; return the stack. If no entity took the chest, `super.execute` (default spawn of the whole behaviour chain: one item entity). `success` is never set to false, so the sound is always 1000. The behaviour passes the dispenser's own stack object to `SlotAccess.set`, calls `stack.shrink(1)` and sets `success` only after `set` returned true. The horse's slot-499 access neither copies nor stores the stack: for an empty stack it removes the chest (`setChest(false)` plus a fresh inventory when a chest was present) and returns true; for a chest item it sets `setChest(true)` plus a fresh inventory when no chest is present; any other item returns false. The dispenser's filter already requires no chest. The item is simply consumed by the `shrink(1)`; the horse only gets a flag and an empty new inventory.

### 4.4 Boats and rafts (`BoatDispenseItemBehavior`)

Constructed with a boat `EntityType`. Its own `playSound` always sends event 1000 (not the Optional variant); `playAnimation` is the default.

`execute`:
1. `d = 0.5625 + type.getWidth() / 2.0` (the width of the boat entity type, a float widened to double).
2. `x = centre.x + stepX * d`; `z = centre.z + stepZ * d`; `y = centre.y + (double)((float)stepY * 1.125f)` (the vertical step is multiplied in single precision).
3. `frontPos = pos.relative(facing)`. If the front block's fluid state is in the fluid tag `water`: `yOffset = 1.0`. Else if the front block state is air **and** the block below the front block has a water fluid state: `yOffset = 0.0`. Otherwise run the second default behaviour's `dispense` (the fallback, see the note above about doubled events) and return its result.
4. Create the boat entity with `type.create(level, DISPENSER)`; if it exists: `setInitialPos(x, y + yOffset, z)`; apply `EntityType.createDefaultStackConfig(level, stack, null)` to it; `setYRot(facing.toYRot())`; `addFreshEntity`; `stack.shrink(1)`. Return the stack.

Boats are therefore only dispensed onto water (or onto air above water); dry land gives a dropped boat item.

### 4.5 Filled buckets (`$3`)

One instance for all ten items. `execute`: the item must be a `DispensibleContainerItem`. Call `item.emptyContents(null, level, frontPos, null)` (no player, no hit result: the item places its fluid or entity at the front block; the fluid placement rules and the entity release of each bucket are in 29 and 29b). If it returns true: `item.checkExtraContent(null, level, stack, frontPos)` (post-placement hook, e.g. fish buckets) and return `consumeWithRemainder(source, stack, new ItemStack(BUCKET))` (the empty bucket goes back into the dispenser, or is dropped when it does not fit). If it returns false: the fallback default dispense (doubled events, see above).

### 4.6 Empty bucket (`$4`)

`execute`: `state = level.getBlockState(frontPos)`, `block = state.getBlock()`. If the block is a `BucketPickup`: `picked = block.pickupBlock(null, level, frontPos, state)`. If `picked` is empty: `DefaultDispenseItemBehavior.execute` (drops the empty bucket; note this calls the base `execute` directly, so only one pair of events). Otherwise fire the game event `fluid_pickup` at the front position (no entity) and the remainder item is `picked.getItem()`. If the block is not a `BucketPickup`: `DefaultDispenseItemBehavior.execute`. In the pickup case: `consumeWithRemainder(source, stack, new ItemStack(picked item))`.

### 4.7 Wither skeleton skull (`$7`, extends Optional)

`execute` (it does **not** set `success` at the start; only the explicit sets below matter, so no value carries over from a previous use of the shared instance): `frontPos`. If the front block is air (`isEmptyBlock`) **and** `WitherSkullBlock.canSpawnMob(level, frontPos, stack)`: set the block `wither_skeleton_skull` with `rotation = RotationSegment.convertToSegment(facing)` through `setBlockAndUpdate`; game event `block_place`; if the new block entity is a `SkullBlockEntity`, call `WitherSkullBlock.checkSpawn(level, frontPos, entity)` (the wither pattern check, 24 and 44); `stack.shrink(1)`; `success = true`. Otherwise `success = EquipmentDispenseItemBehavior.dispenseEquipment(source, stack)` (a mob head is equipped onto a living entity in the front box when possible). Return the stack. In the equip failure case the item is **not** dropped and the click is the failure click (1001).

### 4.8 Carved pumpkin (`$8`, extends Optional)

`execute` (no initial `success` assignment, as for the skull): `block = carved_pumpkin`. If the front block is air and `block.canSpawnGolem(level, frontPos)` (24 and 44: the snow golem and iron golem patterns): when not on the client, `setBlockAndUpdate(frontPos, carved_pumpkin default state)` and game event `block_place`; `stack.shrink(1)`; `success = true`. Otherwise `success = dispenseEquipment(source, stack)`. Return the stack. As for the skull, no item drop on failure.

### 4.9 Equipment (`EquipmentDispenseItemBehavior`, the default rule 3.1.1)

`execute`: if `dispenseEquipment` succeeds return the stack; otherwise run the base default `execute` (drop one item). The static `dispenseEquipment(source, stack)`:

1. `entities = getEntitiesOfClass(LivingEntity, AABB(frontPos), e -> e.canEquipWithDispenser(stack))`. Empty: return false.
2. `e = first`. `slot = e.getEquipmentSlotForItem(stack)` (the stack's `equippable` slot when the entity can use that slot, else MAINHAND). `item = stack.split(1)`; `e.setItemSlot(slot, item)`.
3. If `e` is a `Mob`: `setGuaranteedDrop(slot)` and `setPersistenceRequired()` (the mob keeps the item on death and never despawns).
4. Return true.

`LivingEntity.canEquipWithDispenser(stack)` (final): false when the entity is not alive or is a spectator; the stack's `equippable` component must exist and have `dispensable = true` (a data flag); `canUseSlot(equippable.slot)` and `equippable.canBeEquippedBy(entity type)` must hold; and the entity's current item in that slot must be **empty** and `canDispenserEquipIntoSlot(slot)` must be true. `canDispenserEquipIntoSlot`: `LivingEntity` base true (so players, armor stands and other non-mobs accept it); `Mob`: `canPickUpLoot()` (so most mobs accept dispenser equipment only when they can pick up loot); `AbstractHorse`: true for the BODY and SADDLE slots **when tamed**, otherwise the animal's own rule; `SulfurCube`: true only for the BODY slot. All other slots follow the same rules per class (not enumerated: the data of which entity types may wear which item is the `equippable` component's allowed-entities list).

### 4.10 Flint and steel (`FlintAndSteelDispenseItemBehavior`, Optional)

`execute`: `success = true`; `frontPos`, `state` of the front block. In order, the first rule that applies:
1. `tryIgniteExplosiveEntities(level, frontPos)`: find `SulfurCube` entities in the front box that pass a filter (not read); if any, the first has `primeTime(false)` called and the rule succeeds (nothing else happens).
2. `BaseFireBlock.canBePlacedAt(level, frontPos, facing)`: `setBlockAndUpdate(frontPos, BaseFireBlock.getState(level, frontPos))`, game event `block_place`.
3. The block can be lit (`CampfireBlock.canLight(state)`, `CandleBlock.canLight(state)` or `CandleCakeBlock.canLight(state)`): set `lit = true`, game event `block_change`.
4. The block is a `TntBlock`: `TntBlock.prime(level, frontPos, null, stack)`; if it returns true, `removeBlock(frontPos, false)`; if false, `success = false`.
5. Otherwise `success = false`.

If `success` at the end: `stack.hurtAndBreak(1, level, null, ignored)` (one point of durability, no player; breaking just removes the item). Return the stack. Never drops the item.

### 4.11 Spawn eggs (`SpawnEggItemBehavior`, default rule 3.1.3)

`execute`: `type = SpawnEggItem.getType(stack)`; null: return the stack. Otherwise `type.spawn(level, stack, null, frontPos, DISPENSER, alignPosition = (facing != UP), alignY = false)`. In `create`, `alignPosition = true` first places the entity at (x + 0.5, y + 1, z + 0.5) and the y offset then comes from the collision-based `getYOffset(level, pos, alignY, boundingBox)`; with `alignPosition = false` (facing UP) the placement is the plain bottom centre of 4.2. In both cases the same random yaw draw and rotation snap of 4.2 follow. So for facing other than UP the egg entity is aligned with the collision offset; for UP it is not. If the result is null return the stack unchanged. On an exception (logged) return an **empty** stack (the egg is lost). Otherwise `stack.shrink(1)`, game event `entity_place` at the dispenser position (no entity), return the stack. Default events.

### 4.12 Sulfur cube swallowing (`SulfurCubeBlockDispenseItemBehavior`, default rule 3.1.2)

`dispenseBlock(level, frontPos, stack)`: for each `SulfurCube` in the front box, in order, `cube.equipItem(stack)`; the first that returns true makes the stack shrink by 1 and the function return true; none gives false. `execute`: when `dispenseBlock` is true return the stack, else the base default drop. The item tag `sulfur_cube_swallowable` is a list of 12 tag references, all under `sulfur_cube_archetype/`: bouncy, regular, slow_flat, fast_flat, light, fast_sliding, slow_sliding, sticky, high_resistance, explosive, hot, slow_bouncy. `SulfurCube.equipItem(stack)`: false for a baby cube; false when the stack is the same item as the current BODY item; otherwise, if a BODY item exists it is spawned as an item entity at the passenger attachment point, then BODY is set to `stack.copyWithCount(1)` with drop-when-killed, and the result is true. `canDispenserEquipIntoSlot` is BODY only. Not read: the filter of `tryIgniteExplosiveEntities` (Open question 6). The TNT behaviour (4.14) tries the same function first.

### 4.13 Bone meal (`$5`, Optional)

`execute`: `success = true`; if `BoneMealItem.growCrop(stack, level, frontPos)` or `BoneMealItem.growWaterPlant(stack, level, frontPos, null)` returned true: when not on the client, level event **1505** at the front position with data **15**. Else `success = false`. Return the stack. Both growth functions consume the item themselves (29b-1; the stack shrinks inside them). A failed use plays the failure click (1001) and the item stays.

### 4.14 TNT (`$6`, Optional)

`execute`: if the game rule `tnt_explodes` is false: `success = false`, return the stack. Else if `SulfurCubeBlockDispenseItemBehavior.dispenseBlock(level, frontPos, stack)` is true return the stack. Otherwise create `PrimedTnt(level, frontX + 0.5, frontY, frontZ + 0.5, owner = null)` (the block's x and z centre, **y at the block floor**), `addFreshEntity`, play `TNT_PRIMED` (blocks, volume 1.0, pitch 1.0, no source entity) at the entity position, game event `entity_place` at the front position, `stack.shrink(1)`, `success = true`. Return the stack. (The primed entity's fuse and explosion are 44.) The behaviour shares one `success` flag like 4.7 and 4.19: when `tnt_explodes` is true and the swallow returns true, it returns **without setting `success`**, so the sound reflects whatever the last use left (possibly false, i.e. click 1001 for a successful swallow).

### 4.15 Shulker boxes (`ShulkerBoxDispenseBehavior`, Optional)

`execute`: `success = false`. When the item is a `BlockItem`: `frontPos`; `placeDirection = facing`; `up = (level.isEmptyBlock(frontPos.below())) ? facing : UP`. `result = blockItem.place(new DirectionalPlaceContext(level, frontPos, facing, stack, up))` (29, DirectionalPlaceContext: the block is placed at `frontPos`; the context's `placementUp` is the last argument); `success = result.consumesAction()`. Any exception is caught and logged. Return the stack (the place call consumes the item itself). Failure plays event 1001 and keeps the item; it never drops it. The facing of the placed box comes from the context's "nearest looking direction" rules of 29 (always DOWN for this context class, see 29 Open question 18).

### 4.16 Glass bottle (`$9`, Optional)

`execute`: `success = false`; `frontPos`, `state`.
1. If the state is in the block tag `beehives` **and** has the property `honey_level` **and** its block is a `BeehiveBlock`, and `honey_level >= 5`: `block.releaseBeesAndResetHoneyLevel(level, state, frontPos, null, BEE_RELEASED)`; `success = true`; return `takeLiquid(source, stack, honey_bottle)`.
2. Else if the front block's fluid state is in the fluid tag `water`: `success = true`; return `takeLiquid(source, stack, PotionContents.createItemStack(POTION, WATER))` (the item `potion` with the `water` potion).
3. Else `super.execute` (drop one glass bottle) with `success` false (so the failure click plays even though the bottle is dropped).

`takeLiquid(source, stack, filled)`: game event `fluid_pickup` at the dispenser position (no entity); return `consumeWithRemainder(source, stack, filled)`.

Note: the water case does not remove or change the fluid block; only the beehive case changes the world.

### 4.17 Glowstone (`$10`, Optional)

`execute`: `success = true`; `state` of the front block. If it is a `respawn_anchor`: when `charge != 4`: `RespawnAnchorBlock.charge(null, level, frontPos, state)` and `stack.shrink(1)`; when `charge == 4`: `success = false`. Return the stack (no drop in this branch, even when full). For any other block: `super.execute` (drops one glowstone block item), `success` stays true.

### 4.18 Shears (`ShearsDispenseItemBehavior`, Optional)

`execute` (server side only; on a client level nothing happens and the stack is returned): `success = tryShearBeehive(level, stack, frontPos) OR tryShearEntity(level, frontPos, stack)`; if `success`: `stack.hurtAndBreak(1, level, null, ignored)`. Return the stack. The item is never dropped.
- `tryShearBeehive`: the front block is in the tag `beehives`, has `honey_level`, is a `BeehiveBlock`, and `honey_level >= 5`: play `BEEHIVE_SHEAR` (blocks, volume 1.0, pitch 1.0) at the front position; `BeehiveBlock.dropHoneycomb(level, stack, state, blockEntity, null, frontPos)`; `releaseBeesAndResetHoneyLevel(..., null, BEE_RELEASED)`; game event `shear` at the front position; return true. Otherwise false.
- `tryShearEntity`: for each `Entity` in the front box that is not a spectator, in order: if `entity.shearOffAllLeashConnections(null)` returns true, return true at once; else if it is alive, is `Shearable` and `readyForShearing()`: `shear(level, BLOCKS, stack)` and the game event `shear` at the front position, return true. None: false.

### 4.19 Brush (`$11`, Optional)

`execute`: `armadillos = getEntitiesOfClass(Armadillo, AABB(frontPos), NO_SPECTATORS)`. Empty: `success = false`, return the stack. For each in order: `armadillo.brushOffScute(null, stack)`; the first that returns true makes the brush take 16 durability (`stack.hurtAndBreak(16, level, null, ignored)`) and the function return the stack. If none accepted: `success = false`, return the stack. **`success` is never set back to true in this behaviour**: after the first failed attempt the shared instance keeps `success = false` and every later brush dispense plays the failure click (event 1001) instead of 1000, even when a scute is brushed off. Item never dropped.

### 4.20 Honeycomb (`$12`, Optional)

`execute`: `state = level.getBlockState(frontPos)`; `waxed = HoneycombItem.getWaxed(state)` (the wax-on block map, a code table of the item class, tabulated with copper in 29b-5 where it exists). If present: `setBlockAndUpdate(frontPos, waxed)`; level event **3003** at the front position (data 0: wax-on particles, 42-7); play `HONEYCOMB_WAX_ON` (blocks, 1.0, 1.0) at the front position; `stack.shrink(1)`; `success = true`; return. Otherwise `super.execute` (drop one honeycomb). `success` is never set to false (always the 1000 click).

### 4.21 Potion (`$13`)

`execute`: if the stack's `potion_contents` (default empty) is **not** the `water` potion: the fallback default dispense (so every non-water potion drops as an item, with doubled events). If it is water: `frontPos`, `state`. If the front block is in the block tag `convertible_to_mud`: (server side) five times, in a loop: `sendParticles(SPLASH, dispenserX + nextDouble(), dispenserY + 1, dispenserZ + nextDouble(), count 1, offset 0, 0, 0, speed 1.0)` (draw order per iteration: x then z; the position is the **dispenser's**, read in the bytecode, the same local as the sound and the game event); then play `BOTTLE_EMPTY` (blocks, 1.0, 1.0) at the **dispenser** position; game event `fluid_place` at the dispenser position; `setBlockAndUpdate(frontPos, mud)`; return `consumeWithRemainder(source, stack, new ItemStack(GLASS_BOTTLE))`. If the block is not convertible: the fallback default dispense. Only `setBlockAndUpdate(mud)` targets the front block.

### 4.22 Minecarts (`MinecartDispenseItemBehavior`)

Constructed with a minecart `EntityType`. Own `playSound`: always event 1000.

`execute`:
1. `x = centre.x + stepX * 1.125`; `z = centre.z + stepZ * 1.125`; `y = floor(centre.y) + stepY` (the dispenser's own block y plus the vertical step).
2. `frontState`. If it is in the block tag `rails`: `railShape` = the state's shape property if the block is a `BaseRailBlock` else north-south; `yOffset = railShape.isSlope() ? 0.6 : 0.1`. Else if the front block is air **and** the block below it is in the tag `rails`: `belowShape` as above; `yOffset = -0.9` if the facing is DOWN **or** the rail below is not a slope, else `-0.4`. Any other case: fallback default dispense (doubled events), return its result.
3. `cart = AbstractMinecart.createMinecart(level, x, y + yOffset, z, type, DISPENSER, stack-or-null, player null)` (the call passes a null stack argument, so no stack configuration is applied); if created: `addFreshEntity(cart)`, `stack.shrink(1)`. Return the stack.

Minecarts therefore only come out onto a rail or above a rail; the offsets put the cart on the rail surface (flat 0.1, slope 0.6 above the front block floor).

### 4.23 Items without a behaviour

The dropper (1.4) never uses this registry. A dispenser that holds an item with no registered behaviour and no matching default rule drops it as an item entity (the default behaviour, section 2).

## 5. Hopper

### 5.1 Block (`HopperBlock`)

| Item | Value |
|---|---|
| Properties | `facing` (`FACING_HOPPER`: DOWN or one of the four horizontal directions; default DOWN), `enabled` (default true) |
| Placement | `facing = clickedFace.getOpposite()` with a vertical result replaced by DOWN (so the output points into the block that was clicked; placed on the side of a block it points into it; placed on top or bottom it points down); `enabled = true` at creation, corrected by `onPlace` |
| Block entity | `HopperBlockEntity`; server-only ticker `pushItemsTick` (31-2 section 5.3). The ticker is absent on the client |
| `onPlace` | when the block really is new (the old state is a different block): `checkPoweredState` |
| `neighborChanged` | `checkPoweredState` |
| `checkPoweredState` | `shouldEnable = NOT level.hasNeighborSignal(pos)`; if it differs from `enabled`, write `enabled = shouldEnable` with flags 2. Uses no quasi-connectivity: only the hopper's own neighbours matter |
| Locked by signal | `enabled = false` makes `tryMoveItems` do nothing (31-2 section 5.3): neither the eject nor the suck step runs, the cooldown is not reset. Item entities inside the block are not picked up either (`entityInside` goes through the same `tryMoveItems`). Container-to-hopper pushes from other hoppers or droppers **are** still accepted by `addItem`, because the check lives only in the hopper's own tick |
| Use | open the menu, stat `inspect_hopper`; SUCCESS |
| Analog output | the container signal (31-2 section 2.5) |
| `entityInside` | forwards to `HopperBlockEntity.entityInside` (31-2 section 5.8) |
| `isPathfindable` | false for every computation type |
| Removal | `Containers.updateNeighboursAfterDestroy` |

### 5.2 Collision shape

All lengths in sixteenths of a block, `Block.column(width, minY, maxY)` is a centred column of that width and vertical range and `Block.boxZ(width, y0, y1, z0, z1)` is a box of that x width, centred in x, with the stated y and z ranges.

1. **Bowl**: the union of `column(16, 10, 16)` (the wide top ring) and `column(8, 4, 10)` (the neck); from this the **inner cavity** `column(12, 11, 16)` is removed (boolean ONLY_FIRST): the top is an open tray with 2/16 walls and a floor at y = 10/16 to 11/16.
2. **Spout**: the box `boxZ(4, 4, 8, 0, 8)` (width 4, y 4 to 8, z 0 to 8: a stub pointing north) rotated into all six directions about the point `(8, 6, 8) / 16`, clipped to the unit cube (boolean AND with the full block).
3. The state's shape is the bowl plus the spout of the state's `facing` (`enabled` does not change it).

The **interaction (outline and picking) shape** is a separate per-facing map of five entries, built in the constructor: for the four horizontal directions, the union of the cavity column `column(12, 11, 16)` and the box `boxZ(4, 8, 10, 0, 4)` (a 4-wide stub, y 8 to 10, z 0 to 4, north orientation) rotated horizontally; for DOWN, the cavity column alone. Read from the bytecode: `Shapes.or(column(12, 11, 16), boxZ(4, 8, 10, 0, 4))` rotated with the horizontal rotation for the four sides, the cavity column alone for DOWN. The bowl, cavity and spout constants above (16/10/16, 8/4/10, 12/11/16, `boxZ(4, 4, 8, 0, 8)`, pivot (8, 6, 8)/16, ONLY_FIRST then AND with the block) were also read.

### 5.3 Transfer engine

The hopper block entity (container size 5, `TransferCooldown`, the 8-tick cooldown, `ejectItems`, `suckInItems`, `addItem`, `getContainerAt`, the pickup column `SUCK_AABB`, the entity container selection) is specified in 31-2 section 5 and was re-read in this round against the bytecode: the constants `MOVE_ITEM_SPEED = 8`, `HOPPER_CONTAINER_SIZE = 5`, `NO_COOLDOWN_TIME = -1`, the use of `getSlots(container, face)` (the worldly container's `getSlotsForFace(direction)`, otherwise a cached flat array `0..size-1`), `DOES_NOT_BLOCK_HOPPERS`, the `0.5` half-extents of the entity container box, and the order of the steps in `suckInItems` (container above first; item entities only when there is no container) agree with that text. Facts this round adds:

1. **Transfers are one item at a time** from the source and into the first accepting slot; a hopper never moves a stack. A hopper chain therefore moves at most 1 item per 8 ticks per hopper, which is the throughput (2.5 items per second) of a hopper line.
2. **Cooldown handoff between two hoppers** (31-2 section 5.6): when a hopper receives an item into an empty inventory from another hopper that has ticked **no later** than itself in the same game tick, its cooldown becomes 7 instead of 8, so a chain does not lose a tick per link. Guards read in `addItem`: the handoff applies only when the item went into an **empty** destination that is a `HopperBlockEntity` not already on a custom cooldown; the bonus (k = 1, cooldown 8 - k) additionally needs the **source** to be a `HopperBlockEntity` with `dest.tickedGameTime >= source.tickedGameTime`; otherwise k = 0 and the destination cooldown becomes 8 (for example a dropper pushing into a hopper).
3. **Container above** includes entity containers: a chest minecart, hopper minecart or any `Container` entity in the box centred on the block above is a source (31-2 section 5.7, one picked by `nextInt(count)` when several). The hopper minecart (`MinecartHopper`, 44-8) is itself a `Hopper` with `isGridAligned = false` and its own enable rule (part 6).
4. **Dropper and crafter outputs** use the same `addItem(source, dest, stack, direction)` as a hopper with `direction = facing.getOpposite()`, which for a worldly destination (furnace, brewing stand, shulker box...) restricts the accepted slots to that face's slot list.

## 6. Crafter

### 6.1 Block (`CrafterBlock`)

Verified against 31-2 section 7.4 and extended:

| Item | Value |
|---|---|
| Properties | `orientation` (`FrontAndTop`, default `NORTH_UP`), `triggered` (boolean), `crafting` (boolean) |
| Constants | `CRAFTING_TICK_DELAY = 4`, `MAX_CRAFTING_TICKS = 6`, recipe cache of 10 entries (`RecipeCache`), advancement diameter (box edge) 17 |
| Placement | let `F = getNearestLookingDirection().getOpposite()` be the front. The `top` is: for `F = DOWN`, `getHorizontalDirection().getOpposite()`; for `F = UP`, `getHorizontalDirection()`; for the four horizontal fronts, `UP`. The state's `orientation = FrontAndTop.fromFrontAndTop(F, top)`. `triggered = level.hasNeighborSignal(clickedPos)` at placement (a crafter placed against a powered block starts `triggered` and schedules its tick in `setPlacedBy`) |
| `rotate`, `mirror` | the orientation is transformed through the octahedral group of the `Rotation` or `Mirror` |
| Analog output | `getRedstoneSignal()` of the block entity: the number of slots that are non-empty or disabled (0 to 9), 31-2 section 7.2 |
| Use (right click) | server side: opens the menu only if the block entity exists; no stat is awarded; the result is SUCCESS in every case |
| Quasi-connectivity | **none**: `neighborChanged` tests `hasNeighborSignal(pos)` only (contrast with 1.2) |

### 6.2 Triggering and delay

`neighborChanged` (31-2 section 7.4 step 1, confirmed): `powered = hasNeighborSignal(pos)`. With the block entity present: powered and not `triggered`: `scheduleTick(pos, block, 4)`, `triggered = true` (flags 2) and the entity's `triggered` set; not powered and `triggered`: `triggered = false`, `crafting = false` (flags 2), entity `triggered` false. `tick` runs `dispenseFrom`.

### 6.3 `dispenseFrom` (crafting)

1. Block entity missing: stop.
2. `input = entity.asCraftInput()` (3x3 `CraftingInput` of the container, 31-2 section 7.1). `getPotentialResults(level, input)` = `RECIPE_CACHE.get(level, input)`: the crafting recipe holder, if any (13).
3. No recipe: level event **1050** (`crafter.fail`) and stop. Recipe present but its `assemble(input)` is empty: also 1050 and stop. The block and the slots are left untouched.
4. `entity.setCraftingTicksRemaining(6)`; write `crafting = true` (flags 2); `result.onCraftedBySystem(level)`.
5. `dispenseItem(...)` (6.4) for the result; then for each non-empty item of `recipe.getRemainingItems(input)` (container items such as buckets and bottles) `dispenseItem` again with the same arguments.
6. Every slot that is **non-empty** shrinks by exactly 1 (a loop over the item list; empty and disabled-empty slots are skipped). `setChanged`.

The crafter animation ends through the entity ticker (31-2 section 7.3: after 6 ticks `crafting` is written false).

### 6.4 `dispenseItem(level, pos, entity, stack, state, recipe)` (agrees with 31-2 section 7.5)

Parameters: `front = state.orientation.front()`; `target = HopperBlockEntity.getContainerAt(level, pos.relative(front))`; `rest = stack.copy()`.

1. **Container path A** (one item at a time), taken when a target exists and **either** the target is a `CrafterBlockEntity` **or** `stack.count > target.getMaxStackSize(stack)`: repeat while `rest` is non-empty: `moved = HopperBlockEntity.addItem(entity, target, rest.copyWithCount(1), front.getOpposite())`; if `moved` (the remainder) is non-empty stop the loop; else `rest.shrink(1)`. 
2. **Container path B** (whole-stack `addItem`), taken when a target exists, is not a crafter and `stack.count <= target.getMaxStackSize(stack)`: repeat while `rest` is non-empty: `before = rest.count`; `rest = HopperBlockEntity.addItem(entity, target, rest, front.getOpposite())`; stop when the count did not change.
3. **No target**: neither path runs.
4. **Only if `rest` is still non-empty afterwards**: `DefaultDispenseItemBehavior.spawnItem(level, rest, 6, front, centre + 0.7 * front_step)` (the item entity; section 2); then every `ServerPlayer` in the 17 x 17 x 17 box centred on the crafter gets the `crafter_recipe_crafted` advancement trigger with the recipe key and the crafter's item list; level event **1049** (`crafter.craft`) at the position; level event **2010** (white smoke) at the position with data `front.get3DDataValue()`.

Consequence, in agreement with 31-2 section 7.5 (which already states that the advancement and events 1049 and 2010 happen only when something remains): when **all** of an output was accepted by a container in front of the crafter, **no** advancement trigger, **no** crafting sound and **no** smoke is sent. They are produced only when something was dropped into the world. A crafter facing a hopper or chest is silent for items that fit; one facing open air always sounds and puffs. Also a crafter that fails to craft never plays 1049.

### 6.5 Comparator and block entity behaviour

Output signal, slot enabling, `canPlaceItem` fairness rule, saved keys and the ticker are in 31-2 sections 7.1 to 7.3. Items hoppers push into a crafter are accepted slot by slot under the `canPlaceItem` rule (an item goes to the emptier of equal slots; disabled slots refuse), which with the one-item-per-transfer rule of hoppers fills a crafter's 9 slots evenly.

## 7. Worked examples

1. **Dispenser pulse.** A dispenser at (0, 64, 0) facing east holds 5 arrows in slot 4 only. A lever at (0, 64, -1) turns on at game tick 100. The dispenser's `neighborChanged` sees `hasNeighborSignal(pos)` true: schedules a tick for tick 104, sets `triggered = true`. The lever turns off at tick 102: `triggered = false`, but the tick at 104 still runs. At tick 104 `getRandomSlot` returns 4 (one `nextInt(1)` call); the registry gives `ProjectileDispenseBehavior(arrow)`: `position = (0.5 + 0.7, 64.5 + 0.0 + 0.1, 0.5)` = (1.2, 64.6, 0.5); an arrow is shot with velocity direction (1, 0, 0), uncertainty 6.0, power 1.1; the stack becomes 4 arrows; event 1002 (launch sound) then 2000 with data 5 (the 3D data value of east). If the lever is flipped again after tick 104 the dispenser fires again.
2. **Quasi-connectivity.** The same dispenser at (0, 64, 0). A redstone block at (0, 66, 0) is a neighbour of (0, 65, 0) (the block above the dispenser), so `hasNeighborSignal((0, 65, 0))` is true and the dispenser is triggered even though its own neighbours carry no signal. A redstone block at (0, 67, 0) is not a neighbour of (0, 65, 0) and does not trigger it. A crafter or hopper at (0, 64, 0) is unaffected by the block at (0, 66, 0).
3. **Boat onto water.** A dispenser faces north at (0, 64, 0); the front block (0, 64, -1) is water; it holds an oak boat. `d = 0.5625 + width / 2` where the oak boat's width is read from the entity type; `x = 0.5`, `y = 64.5 + 0.0 = 64.5`, `z = 0.5 - d`. The front fluid is water, so `yOffset = 1.0` and the boat is set at `y = 65.5`; `yRot = 180` (north). If the front block is air above water, `yOffset = 0.0` and the boat appears at `y = 64.5`. If the front block is stone, the fallback drops the boat as an item and events 1000 and 2000 are sent twice.
4. **Glass bottle on a full hive.** A hive in front has `honey_level 5`: bees leave, `honey_level` resets, the dispenser's slot loses one glass bottle and gains one honey bottle (or the honey bottle is dropped if it did not fit); sound 1000; game event `fluid_pickup`. With `honey_level 4` and no water the bottle is dropped and the click is 1001.
5. **Crafter into a hopper.** Abstract recipe (recalled, not verified: no concrete recipe is read here, recipes are data-pack content, 22 and 23): a crafter facing down onto a hopper holds ingredients matching a recipe whose result is 4 of item R. `dispenseFrom` crafts; `dispenseItem` path B (the target is not a crafter and 4 <= 64) moves the 4 R into the hopper with whole-stack `addItem` calls (the hopper has 5 slots, `HOPPER_CONTAINER_SIZE = 5`): no events at all besides the block state change. If instead all 5 hopper slots are already full of R at its maximum stack size, nothing is accepted and the 4 R are spawned as item entities at the crafter's front position (centre + 0.7 downwards, minus the 0.125 vertical offset of `spawnItem`) and the 1049 sound, 2010 smoke and the advancement fire.
6. **Dropper onto a chest.** A dropper facing east with a double chest east of it: `addItem(dropper, chest, one item, WEST)` moves one item, the dropper slot shrinks by 1, no events are sent. With a full chest nothing is moved, the stack is unchanged, and still no events (a full-chest dropper is silent).
7. **Hopper lock.** A hopper next to a powered repeater whose output faces the hopper (a repeater only emits into the neighbour it faces, so `hasNeighborSignal` sees it only then) is `enabled = false`: its `tryMoveItems` returns without action, but a dropper facing into it still fills it with `addItem`.

## 8. Validation

An implementation is acceptable against this document when:

1. A dispenser dispatches in exactly the order 1.3 and plays event 1001 plus game event `block_activate` for an empty dispenser, and a dropper plays only 1001.
2. `triggered` and the 4-tick schedule follow 1.2 including the quasi-connected `pos.above()` test; a crafter follows 6.2 without it; a hopper follows 5.1 without it.
3. Every item of the table 3.2 resolves to the stated behaviour; every other item resolves by the four rules of 3.1.
4. The 13 projectile rows give the stated position functions, uncertainties, powers and events; the arrow row `power 1.1`, the potion row `1.375`, the firework row `0.5`.
5. Boats refuse dry land; minecarts refuse non-rail fronts; shulker boxes, glass bottles, glowstone, shears, honeycomb, brush, bone meal and TNT keep or drop their items exactly as in 4.7 to 4.21 (no drop for shears, brush, shulker box, skull, pumpkin, flint and steel, bone meal; drop for glass bottle, glowstone, honeycomb, chest, bucket, potion and equipment fallbacks as stated).
6. The doubled-event rule of section 4 for the second-default-object fallbacks.
7. The crafter silence rule of 6.4: no 1049, 2010 or advancement for items that fit into a container in front.
8. The shared-instance `success` flag of the Optional behaviours (4.19) is reproduced or the divergence is noted as deliberate.

## Open questions

1. **Dispenser smoke direction data**: the particle spread and counts of events 2000 and 2010 are in 42-7 section 8.1, not repeated or re-read here.
2. **`Equippable` data** (4.9): the allowed entity types and slots are data (22, 23); `canUseSlot` per entity type and the `canEquipWithDispenser` per-class rules are in the mob documents and were not enumerated.
3. **`SulfurCube`** (4.10, 4.12): the filter of `tryIgniteExplosiveEntities` (searched: only the call site was read) and the `primeTime` internals were not read.
4. **Hopper minecart**: the enable and disable rule and rail interaction are in 44-8 and 30-6, not repeated.
5. **Sound registry ids** for the sound events named here (`dispenser.dispense`, `dispenser.fail`, ...) are resolved through the sounds registry (46, 08); only the symbolic field names were read in the level event handler.
6. **Feature-flag gating** (1.3 step 4): the set of items disabled by the default feature flags was not computed; all items above are assumed enabled.
7. **Default `equippable` items** (3.2): armor, elytra, wolf armor and mob heads were not read in this round; the default value of `dispensable` is inferred from the constructor.
8. **Cross-reference for the 31-2 owner**: 31-2 cites "30-4 section 6.2" for the crafter path rule, which is in 6.4.
9. **Shared `success` flag** (4.7, 4.14, 4.19): reproducing the shared-instance behaviour is an implementation choice; a divergence must be noted as deliberate.
