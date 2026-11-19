# 57-2. Client closures, part 2: world data and miscellaneous (fishing hook motion, stronghold rings and the eye of ender, menu take sounds, saved-map files, brewing fuel)

| Item | Value |
|---|---|
| Covers | Closures of five gaps recorded on task lines of `specs/002-client-polish/tasks.md` (T9750 and neighbours) and in 40-4 Open question 9: the fishing hook's flying drag and the rest of its per-tick motion (§1); the stronghold ring table, its seed and the eye of ender's locate, flight and use sequence (§2); the sound events played when a result is taken out of the loom, cartography table, stonecutter, grindstone, smithing table and anvil, with who plays them (§3); the saved-map data files `maps/<id>` and `maps/last_id` (§4); brewing fuel (§5) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the jar's data files (`unzip -p`, `unzip -Z1`), with no execution; clean-room reader round "57-2" (reader only; a reviewer follows) |
| Extends or corrects | 17 §3.11 and 44-8 §10.1 (item 3 partly corrected: the bite does change the velocity, via the bite dip of §1.5) (fishing hook: drag, bite dip, which random generator is reseeded), 36-1 §4.6 and §11 and 36-5 §3.1 and §3.10 (stronghold rings and eye locate: verified, one open question closed), 25-5 §6.3 and §6.3a (eye of ender: verified, trajectory test vectors added), 40-3 §1 and 40-4 §1 rule 5 (take sounds: registry keys added, Open question 9 closed), 07 §10.3 (map files: payload schema added), 31-2 §4 (brewing fuel: verified); round-1 review additions: 17 §3.11 open-water rule inverted (§1.3a); 36-5 §1 (the "Tags used by code" row: `#minecraft:structure/eye_of_ender_located`, `#minecraft:structure/mineshaft`, `#minecraft:structure/on_mineshaft_maps`) and §3.10 write structure tags with a `structure/` prefix, but their files are `data/minecraft/tags/worldgen/structure/<name>.json` and the ids are `#minecraft:eye_of_ender_located`, `#minecraft:mineshaft` and `#minecraft:on_mineshaft_maps` (the `has_structure/...` biome tags of that row are correct; §2.5; 36-1 writes the eye tag without the prefix and is correct; 36-5 is not edited here); stale statements this document supersedes (not edited here): 07 §10.3 (file table row for `maps/last_id.dat` and `maps/<n>.dat`, "contents not traced"), 07 §10.4 and 07 Open question 20 (map payloads "not traced"); the schemas are §4 |

All numbers are Java `float` or `double` as the artifact states; unless a statement says "(computed)" it was read. "Computed" values are
test vectors produced by applying the rules of this document by hand or with a short script; nothing was executed from the artifact.
Each section starts with a "Gap closed" line. Artifact class names are cited in backticks only to say where a fact was read.

**Read this first: what was already documented.** Items 2 and 5 were already specified in the documents listed below. This round re-read the
artifact for them, found the earlier text correct (differences are listed in the sections) and wrote only what was missing.

| Scope item | Already documented in | This document |
|---|---|---|
| Bobber gravity, water factor, bobbing, bite timer, retrieve cost | 17 §3.11, 44-8 §10.1 | §1 adds the drag, the call order, the bite dip, the random generators and the lifetime |
| Stronghold ring algorithm, ring sizes, biome snap, locate | 36-1 §4.6 and §11, 36-5 §3.1 and §3.10 | §2 verifies it against the jar, closes the seed question, adds the radius table |
| Eye of ender item and entity | 25-5 §6.3, §6.3a, 21 §8.12 | §2.5 to §2.7 verify and add trajectory test vectors |
| Brewing fuel component, slot rules, charges | 25-1 §9, 25-5 §2.4, 31-2 §4, 40-2 §4 | §5 verifies and answers the "tag, component or hard-coded" question |
| Map items and `MapItemSavedData` runtime | 25-5 §8 | §4 adds only the saved files |

---

## 1. Fishing hook motion (`FishingHook`)

**Gap closed:** the velocity damping of a hook in flight and in the water (T9750 part b), the order of gravity, movement and damping inside one tick, the speed of the cast, the downward dip when a fish bites (17 says "magnitude not decoded"), the lifetime and range limits.

### 1.1 Constants (all read in `FishingHook`)

| Constant | Value | Notes |
|---|---|---|
| Gravity (`getDefaultGravity`) | 0.03 (the double 0.029999999329447746, the float 0.03 widened) | subtracted from the vertical velocity each tick, only when the hook is **not** in water, not on the ground and has no hooked entity |
| **Drag** (end of every full tick) | **0.92** on all three components | applied after movement, in the states FLYING and BOBBING whenever the tick was not ended early (hooked entity or water entry in FLYING); not applied on the tick the state changes to BOBBING, nor while HOOKED_IN_ENTITY |
| Water entry factor | (0.3, 0.2, 0.3) on (x, y, z) | applied once, on the tick a FLYING hook finds water at its block; that tick ends there (no gravity, no movement, no drag) |
| Bobbing damping | x and z times 0.9; vertical `vy - e x nextFloat x 0.2` | see 1.3; the 0.92 drag comes on top, after the move |
| Bobbing near-surface nudge | when `abs(e) < 0.01`, `e` grows by `sign(e) x 0.1` | `e` defined in 1.3 |
| Hooked entity follow height | 0.8 of the entity's height | `hookedIn.getY(0.8)` |
| On-ground discard | 1200 ticks of `life` | `life` counts consecutive ticks on the ground and resets to 0 on any tick off the ground |
| Owner distance limit | squared distance 1024.0 (32 blocks) | server only, 17 / 44-8 |
| Client render distance | squared distance below 4096.0 (64 blocks) | `shouldRenderAtSqrDistance`, as read |
| `MAX_OUT_OF_WATER_TIME` | 10 ticks | cap of the `outOfWaterTime` counter; while a bite is under way a value of 10 forces the open-water flag false (rule in 1.3a) |
| **Bite dip** (on the biting flag) | `vy = -0.4 x (0.6 + 0.4 x f)`, `f` = `nextFloat` of the synchronised generator, so `vy` is in (-0.4, -0.24] (`nextFloat` is in [0, 1)) | §1.5 |
| `triangle(0.5, 0.0103365)` | the cast factor term | §1.4 |
| Entity type | 0.25 x 0.25, tracking range 4, update interval 5, no loot, never saved | already in 18 and 21 |

### 1.2 Order of one tick

`FishingHook.tick`, in order (server and client both run it; the steps marked "server" are skipped on a client):

1. Reseed the **synchronised** generator (`syncronizedRandom`) with `(low 64 bits of the hook's UUID) xor (level game time)`. This is the only generator that is reseeded; the hook's ordinary `random` is not (corrects the last sentence of 17 §3.11's open-water bullet, which names "the hook's own random").
2. `Projectile.tick` (the one-time `projectile_shoot` game event, the left-owner check, the base entity tick).
3. If the owner is missing or is not a player: discard, end.
4. Server: `shouldStopFishing` (44-8 §10.1): discards and ends the tick when the owner cannot interact, does not hold a rod in either hand, or is farther than 32 blocks.
5. If on the ground: `life += 1`, and discard at `life >= 1200`; otherwise `life = 0`.
6. Look at the fluid in the block that contains the hook; if it is water, `f` = that fluid's height (0 to 1), else `f` = 0. In water means `f > 0`.
7. The state machine of 1.3 (it may end the tick early).
8. Gravity: when the block's fluid is not water **and** the hook is not on the ground **and** no entity is hooked: `vy -= 0.03`.
9. Move by the velocity (`MoverType.SELF`, normal block collision), apply block effects, update rotation.
10. If the state is FLYING and the hook is on the ground or has a horizontal collision: velocity becomes 0.
11. **Velocity times 0.92** (all three components), then re-apply the position.

### 1.3 The three states

| State | Per-tick action before steps 8 to 11 | Ends the tick early? |
|---|---|---|
| FLYING, a hooked entity is set | velocity = 0, state = HOOKED_IN_ENTITY | yes |
| FLYING, the block has water (`f > 0`) | velocity x (0.3, 0.2, 0.3), state = BOBBING | yes |
| FLYING, otherwise | projectile hit test along the velocity (`checkCollision`: entity hit hooks the entity on the server; a block hit scales the velocity to the distance of the hit, so the hook stops at the face) | no: gravity, move, zeroing on contact, drag follow |
| HOOKED_IN_ENTITY | if the entity is gone, cannot interact with the level or is in another dimension: no hooked entity, state FLYING (the tick ends). Else position = the entity's x, its y at 0.8 of its height, its z. **Edge case:** when the hooked-entity reference is null (for example the metadata id has not resolved to an entity yet on a client), the tick simply ends with no state change, no move and no drag | yes |
| BOBBING | `e = hook.y + vy - blockY - f` (blockY = the integer y of the hook's block); if `abs(e) < 0.01`, `e += sign(e) x 0.1`; velocity = `(vx x 0.9, vy - e x nextFloat x 0.2, vz x 0.9)` (`nextFloat` of the hook's ordinary generator); then the open-water flag update and, while in water, the biting term of 1.5 and (server) `catchingFish` | no: steps 8 to 11 follow (gravity does not apply in water, the move and the 0.92 drag do) |

`blockY` and `f` give the surface: the hook is pulled toward `y = blockY + f`, with spring constant `0.2 x nextFloat` (mean 0.1) and the horizontal friction 0.9 x 0.92 per tick. The open-water flag update is stated in 1.3a (it corrects 17 §3.11); the bite timer is in 17 §3.11 and 44-8 §10.1 and is not repeated.

A BOBBING hook whose block has no water any more (the water was removed) still has state BOBBING: it falls under gravity (step 8) and `outOfWaterTime` counts up to 10 (1.3a).

### 1.3a The open-water flag and `outOfWaterTime` (corrects 17 §3.11)

Re-read in the BOBBING branch of `FishingHook.tick` (the flag `openWater` starts true at construction; `outOfWaterTime` starts 0). Each BOBBING tick, after the velocity update of 1.3:

1. **Flag.** If `nibble > 0` or `timeUntilHooked > 0` (a fish is on its way or biting): `openWater = openWater AND outOfWaterTime < 10 AND calculateOpenWater(block)` (a flag that has become false stays false during the bite; the calculation of 17 §3.11 runs only while the AND has not already failed). Otherwise (`nibble <= 0` **and** `timeUntilHooked <= 0`): `openWater = true`, with no calculation. So the flag is only ever lowered while a bite is under way, and is reset to true between bites. 17 §3.11 says the opposite ("recomputed only while the hook is not yet nibbling"); the bytecode order is as stated here.
2. **Counter.** If the hook's block has water (`f > 0`): `outOfWaterTime = max(0, outOfWaterTime - 1)`, then the biting term of 1.5 (when `biting`) and, on the server, `catchingFish`. Otherwise: `outOfWaterTime = min(10, outOfWaterTime + 1)` and neither the biting term nor `catchingFish` runs.

The treasure branch of the fishing loot table reads `openWater` at the moment of the catch (26; 17 §3.11).

### 1.4 The cast (verification of 17 §3.11)

Read again in the constructor `FishingHook(Player, Level, luck, lure)`; every statement of 17 is correct. One precision: the random factor is `0.6 / len + triangle(0.5, 0.0103365)` per component, where `triangle(m, d) = m + d x (nextDouble - nextDouble)` (the default method of `RandomSource`, read), so the three factors are independent and each lies in `0.6 / len + 0.5 +/- 0.0103365` (mean `0.6 / len + 0.5`). The hook's rotation is set from the launch vector (yaw = atan2(x, z), pitch = atan2(y, horizontal length)) in degrees. The player's own velocity is **not** added. Luck and lure are `max(0, value)`. The server passes `lure = (int)(fishing_time_reduction x 20)` and `luck = fishing_luck_bonus` (the rod item's `use`, read); sounds are in 17.

Worked example (computed, trig in exact arithmetic, random terms at their mean): the player looks along +z at pitch 0, so `c1 = -1`, `s1 = 0`, `c2 = -1`, `s2 = 0`; the launch vector is (0, 0, 1) with `len = 1`, scaled by `0.6 + 0.5 = 1.1`: velocity (0, 0, 1.1). Flying in air, tick by tick (positions relative to the start; gravity first, then move, then the 0.92 drag):

| Tick | y offset | z offset | vy after drag | vz after drag |
|---|---|---|---|---|
| 1 | -0.03 | 1.1 | -0.0276 | 1.012 |
| 2 | -0.0876 | 2.112 | -0.052992 | 0.93104 |
| 3 | -0.170592 | 3.04304 | -0.076353 | 0.856557 |
| 5 | -0.404789 | 4.687629 | -0.117617 | 0.72499 |
| 10 | -1.3108 | 7.777159 | -0.195136 | 0.477827 |

The horizontal velocity entering tick n is 1.1 x 0.92^(n-1) (the move uses the velocity before that tick's drag), so the distance after n ticks is `1.1 x (1 - 0.92^n) / (1 - 0.92)` (7.777 at n = 10, matching the table) and the limit if nothing is hit is `1.1 / (1 - 0.92)` = 13.75 blocks (computed). This holds **for the worked example only** (pitch 0, random terms at their mean, horizontal travel, ignoring landing and the 0.3-block start offset behind the eye). In general the launch speed per component is `v_c x (0.6 / len + 0.5 +/- 0.0103365)` with `len = sqrt(1 + y^2)`, where `y` = `-(s2 / c2)` = tan of the look pitch (positive when looking up) clamped to [-5, 5] and the horizontal part of the unscaled launch vector always has length 1 (`len` is the length of the unscaled launch vector, read), and the reach along a horizontal launch component is its launch value divided by 0.08; the largest possible horizontal component for pitch 0 is `1.1103` (all three triangle terms at their maximum), giving an upper bound of about `1.1103 / 0.08` = 13.88 blocks (computed).

### 1.5 The bite dip and the biting term (answers 17 §3.11 "magnitude not decoded")

Two separate effects exist. The **bite dip** is not in `catchingFish` (no velocity write there): it is a one-time velocity set at the bite moment by the metadata handler. This corrects 17 §3.11 only in where it sits and how big it is (17 puts a negative vertical velocity at the bite moment without a magnitude), and it **partly corrects 44-8 §10.1 item 3**, which says the bite moment itself does not change the velocity and that the tug is only the BOBBING per-tick term: the bite does change the velocity, through the biting-flag handler, in addition to the per-tick **biting term** below. The dip is in `onSyncedDataUpdated`: whenever the synchronised flag `DATA_BITING` (entity metadata index 9, boolean, 21 entity metadata table) becomes true on a side (the server when it sets it, a client when the metadata arrives), that side sets the hook's velocity to `(vx, -0.4 x (0.6 + 0.4 f), vz)` with `f = nextFloat()` of the synchronised generator (`Mth.nextFloat(random, 0.6, 1.0)` is `nextFloat x 0.4 + 0.6`, read). So the bobber dips with an initial vertical speed in (-0.4, -0.24] blocks per tick (-0.24 for `f = 0`; `nextFloat` never reaches 1), then the BOBBING rule of 1.3 and the **biting term**, the extra `(0, -0.1 x r1 x r2, 0)` added every tick in water while `biting` stays true (two `nextFloat` of the synchronised generator), bring it back. The same method resolves `DATA_HOOKED_ENTITY` (index 8, VarInt metadata of the same 21 table): value `n > 0` finds the entity with id `n - 1` in the level, 0 or less means none.

### 1.6 Lifetime and range (summary)

There is no age counter in the air or the water. A hook disappears when: its owner is missing or not a player; the owner is farther than 32 blocks (squared 1024); the owner holds no rod in either hand (both server only); it has been on the ground for 1200 consecutive ticks; it is reeled in (`retrieve`); the entity is removed by chunk unload or the owner leaving (17). `shouldBounceOnWorldBorder` is true (the hook bounces off the world border like other projectiles; the bounce rule is the base entity's, not re-read).

---

## 2. Strongholds and the eye of ender

**Gap closed:** the stronghold ring table with its radii in chunks and blocks, the closure of 36-5 Open question 13 (the ring seed), and a read-again of the eye of ender's locate, flight and use sequence, with trajectory test vectors (T9750 part c).

### 2.1 What was verified

The ring list algorithm of 36-1 §4.6 was compared line by line with `ChunkGeneratorStructureState.generateRingPositions` and found exact: start angle `nextDouble x pi x 2`; per position the radius `(4 D + D x ring x 6) + (nextDouble - 0.5) x (D x 2.5)`; `round(cos(angle) x radius)` and `round(sin(angle) x radius)` with `Math.round`; `fork()` (a new legacy random seeded with `nextLong`) for the biome search; `angle += 2 pi / S`; on completing a ring: `ring += 1`, `S = S + (2 S) / (ring + 1)` (integer division, `ring` already incremented), `S = min(S, N - i)` (the current `i`, before its increment), `angle += nextDouble x pi x 2`. The generator is `RandomSource.create()` (a legacy-LCG source, `LegacyRandomSource`) reseeded with the ring seed; `count = 0` gives an empty list. The biome search (`BiomeSource.findBiomeHorizontal` with step 1, not closest-first, block centre `(rx x 16 + 8, 0, rz x 16 + 8)`, radius 112 blocks) matches 36-1 §4.6.1. The data row is read again: `worldgen/structure_set/strongholds.json` has placement `concentric_rings`, `count 128`, `distance 32`, `spread 3`, `salt 0`, `preferred_biomes #minecraft:stronghold_biased_to`, and one structure `stronghold` with weight 1; `stronghold` appears in no other structure set.

### 2.2 The ring table

With `D = 32`, `S_0 = 3`, `N = 128`. Radii are in **chunks** from the origin chunk (0, 0) (the dimension origin is the world origin for a normal generator, 36-1 §4.1); the jitter `(nextDouble - 0.5) x 80` is uniform in [-40, 40) chunks. Block distances are chunks x 16 (to the raw ring chunk; the biome snap of 2.4 moves a chunk by at most 7 chunks in each axis).

| Ring | Positions | Cumulative | Base radius (chunks) | Radius range (chunks) | Distance range (blocks) | Angle step inside the ring |
|---|---|---|---|---|---|---|
| 0 | 3 | 3 | 128 | 88 to 168 | 1408 to 2688 | 2 pi / 3 |
| 1 | 6 | 9 | 320 | 280 to 360 | 4480 to 5760 | 2 pi / 6 |
| 2 | 10 | 19 | 512 | 472 to 552 | 7552 to 8832 | 2 pi / 10 |
| 3 | 15 | 34 | 704 | 664 to 744 | 10624 to 11904 | 2 pi / 15 |
| 4 | 21 | 55 | 896 | 856 to 936 | 13696 to 14976 | 2 pi / 21 |
| 5 | 28 | 83 | 1088 | 1048 to 1128 | 16768 to 18048 | 2 pi / 28 |
| 6 | 36 | 119 | 1280 | 1240 to 1320 | 19840 to 21120 | 2 pi / 36 |
| 7 | 9 (cut) | 128 | 1472 | 1432 to 1512 | 22912 to 24192 | 2 pi / 10 |

Ring 7 would have 45 positions (`36 + 72 / 8`); the cap `min(45, 128 - 118)` sets `S = 10` when ring 6 completes at `i = 118`, and the loop stops after nine more positions (`i = 119 .. 127`) without completing the ring (so no extra angle draw follows). Total: **128 ring chunks**, in 8 rings, 7 of them complete. The generator `R` is drawn: `nextDouble` once for the start angle, then per position one `nextDouble` and one `nextLong`, then one `nextDouble` after each of the 7 completed rings: 136 `nextDouble` and 128 `nextLong` in all (computed from the loop structure). Each ring chunk is a **placement chunk**: the stronghold start is attempted there (36-5 §3.2); the list is the answer to "where can a stronghold be" and to the eye's locate.

### 2.3 The ring seed (closes 36-5 Open question 13)

`ChunkGeneratorStructureState.createForNormal(randomState, levelSeed, origin, biomeSource, sets)` passes the **same** `long` as both the level seed and `concentricRingsSeed`; `createForFlat` passes 0 as `concentricRingsSeed` (and the level seed as given). `ChunkGenerator.createState` is called by `ChunkMap` with `ServerLevel.getSeed()`, which is `MinecraftServer.getWorldGenSettings().options().seed()`, the world seed of `world_gen_settings` (07 §10.4.5). So for a normal generator the ring list is a function of the world seed; for a flat generator (56) of the constant 0. The computed vectors of 36-1 §12.3 and 36-5 §4.1 (which assumed this) therefore stand.

### 2.4 The biome adjustment

Unchanged from 36-1 §4.6.1 (verified). The preferred-biome tag `stronghold_biased_to` has 38 entries in the shipped data (`unzip -p` of `tags/worldgen/biome/stronghold_biased_to.json`; the tool of 22 copies it, no row is listed here). Reminder of the observable rule: of all 4-block cells within 112 blocks (a 57 x 57 cell square) of the raw ring chunk's centre, one qualifying cell is picked uniformly by reservoir sampling using the fork; the chunk of that cell is the ring chunk; with no qualifying cell the raw chunk stays. The biome is sampled at block y 0 (quart y 0) for every cell (read).

### 2.5 Locate (`EnderEyeItem.use`, `ServerLevel.findNearestMapStructure`, `ChunkGenerator.findNearestMapStructure`)

Verified against 36-1 §11 and 25-5 §6.3; precisions for an implementation:

1. The structure tag `#minecraft:eye_of_ender_located` (data file `data/minecraft/tags/worldgen/structure/eye_of_ender_located.json`; `structure/` is part of the file path, not of the tag id; the same holds for the mineshaft tags, see the header) holds only `stronghold` (read). The search origin is the player's block position; the search radius argument is 100 and `skipKnownStructures` is false.
2. The stronghold has one placement (`concentric_rings`), so only the rings loop of 36-1 §11 step 3 runs for it. That loop **ignores the radius argument**: it walks the whole ring list (all 128 chunks), at any distance. The radius 100 bounds only the random-spread rings of other structure sets, so it never limits the eye.
3. Inside the rings loop the distance used to rank candidates is the squared distance from the origin to `(chunkX x 16 + 8, 32, chunkZ x 16 + 8)` (the chunk centre at y 32), and a candidate is only tested while no hit has been found yet, and afterwards only when it is strictly closer than the best hit (the stored best distance is the chunk-centre distance of the best hit). The distance is three-dimensional: the origin is the player's block position at the player's own y, measured against y 32, so the y difference counts. The best is therefore the nearest (by that measure) ring chunk whose start is present; ties keep the earlier list entry.
4. The returned position is the locate position of the start's chunk: `(minBlockX, 0, minBlockZ)` of the chunk, the locate offset being zero for rings. Its **y is 0**.
5. If no ring chunk has a start (for example "generate structures" is off, or the world is flat, where a stronghold would need a start in a ring chunk), the item returns CONSUME and nothing is thrown or used up.
6. The search may force chunks to the `structure_starts` status (36-1 §11), so a first use can generate chunks around the ring chunks it tests.

### 2.6 The eye entity (`EyeOfEnder`): flight

All values of 25-5 §6.3a were re-read and are correct. The complete rule, for tests:

- **Creation** (item, server): entity at `(player.x, player.y + 0.5 x player height, player.z)`, holding a copy of the used stack with **count 1** (`copyWithCount(1)`), then `signalTo(Vec3.atLowerCornerOf(target))`, game event `projectile_shoot` at the entity with the player as source, `addFreshEntity`, the `used_ender_eye` trigger with the target block position, the launch sound, `consume(1, player)`, the `item_used` statistic.
- **`signalTo(t)`:** `d = t - position`, `h` = horizontal length. If `h > 12`: `target = position + (d.x / h x 12, 8, d.z / h x 12)`; else `target = t`. `life = 0`; `surviveAfterDeath = (nextInt(5) > 0)`. Because the located y is 0, the `h <= 12` branch aims at y 0 (the eye descends); the far branch aims at the start height + 8.
- **Tick:** no gravity, no block collision (the position is set directly), the initial velocity is 0. Server: `next = position + velocity`; velocity = steer(velocity, next, target); position = next; `life += 1`; at `life > 80` (the 81st tick) play `entity.ender_eye.death` (`Entity.playSound(event, 1, 1)`: nothing at all if the entity is silent, source NEUTRAL, no player excluded, sent to players within 16 blocks of the entity's exact position as in 3.2), discard, and then either add an item entity with the eye's stack at the entity's position (surviving, probability 4/5) or send level event 2003 at the block position (shattering, 1/5; a Level Event packet as in 3.2 with Data 0 and Global false, to players within a 64-block sphere of the block position in the same dimension, none excluded). The client never steers; it advances by the last velocity it was given and spawns the particles of 25-5.
- **steer(v, next, target):** as 25-5 §6.3a (`d = (t.x - next.x, 0, t.z - next.z)`, `len = |d|`, `speed = lerp(0.0025, horizontal speed of v, len)`, both `speed` and `vy` times 0.8 when `len < 1`, `dir = +1` when `next.y - v.y < t.y` else `-1`, new velocity `d x speed / len` horizontally and `vy + (dir - vy) x 0.015` vertically).
- **Edge case:** when the horizontal distance `len` to the target is exactly 0, the steer formula divides by zero (`speed / len`); in double arithmetic the horizontal components become NaN (`0 x infinity`) (inferred). The artifact has no guard; it needs an eye to land exactly on the target column, which the examples below approach (12.0 at tick 80) but do not hit exactly. See Open question 9.
- **Limits that follow:** the horizontal travel is bounded by the 12-block target (the eye overshoots it by about 0.05 blocks, example below), the hover height is the start height + 8 in the far case (the eye ends oscillating around it, vertical speed within a few hundredths of a block per tick, example below), and the lifetime is 81 ticks of `life`.

Worked examples (computed with the rules above; the eye starts at (0, 65.6, 0) with velocity 0):

Far structure at (100, 0, 0): `h = 100 > 12`, so `target = (12, 73.6, 0)`.

| Tick | Position after the tick | Velocity after steering |
|---|---|---|
| 1 | (0, 65.6, 0) | (0.03, 0.015, 0) |
| 2 | (0.03, 65.615, 0) | (0.0599, 0.0298, 0) |
| 10 | (1.3166, 66.2487, 0) | (0.2845, 0.1403, 0) |
| 20 | (5.1876, 68.2091, 0) | (0.4932, 0.2609, 0) |
| 40 | (12.0529, 73.2626, 0) | (-0.0614, 0.0979, 0) |
| 60 | (11.9993, 73.5345, 0) | (0.0007, 0.0402, 0) |
| 81 (removal) | (12.0, 73.675, 0) | (0, -0.0345, 0) |

Near structure at (5, 0, 0) (`h = 5 <= 12`, so `target = (5, 0, 0)`): tick 1 velocity (0.0125, -0.015, 0); tick 20 position (2.1615, 62.9909, 0); tick 40 (5.0163, 58.534, 0); tick 81 (5.0, 55.5589, 0): the eye dives toward y 0 and is removed after 81 ticks, about 10 blocks lower than its start.

### 2.7 The complete use sequence

1. The player uses an `ender_eye` (use duration 0). A hit on an `end_portal_frame` block returns PASS, so `useOn` (25-5 §6.3) handles it. A hit on any other block or none starts the use (`startUsingItem`, both sides).
2. Server only: locate (2.5). None found: CONSUME, stop.
3. Create the entity, signal it, game event, add it (2.6); trigger; the sound `entity.ender_eye.launch` (neutral, volume 1.0, pitch `0.33 + 0.17 x nextFloat`, played at the player's x, y, z with no excluded player); consume one eye (a creative player keeps it); award the statistic. Result SUCCESS_SERVER.
4. For 81 ticks the entity flies (2.6); then it drops as an item (4/5) or shatters (1/5).

---

## 3. Menu take sounds

**Gap closed:** the sound events, who plays them and with which volume and pitch when a result is taken out of the loom and the cartography table (40-4 Open question 9), plus the same facts for the stonecutter, grindstone, smithing table and anvil, so that 40-3 and 40-4 share one table.

### 3.1 Registry keys

`SoundEvents.register(name)` builds the key with `Identifier.withDefaultNamespace(name)` and registers a variable-range sound event; the ids in the last column are from 46 §14 (not re-derived here).

| Constant | Registry key | Id (46) |
|---|---|---|
| `UI_LOOM_SELECT_PATTERN` | `minecraft:ui.loom.select_pattern` | 1673 |
| `UI_LOOM_TAKE_RESULT` | `minecraft:ui.loom.take_result` | 1674 |
| `UI_CARTOGRAPHY_TABLE_TAKE_RESULT` | `minecraft:ui.cartography_table.take_result` | 1675 |
| `UI_STONECUTTER_TAKE_RESULT` | `minecraft:ui.stonecutter.take_result` | 1676 |
| `UI_STONECUTTER_SELECT_RECIPE` | `minecraft:ui.stonecutter.select_recipe` | 1677 |
| `ENCHANTMENT_TABLE_USE` | `minecraft:block.enchantment_table.use` | 586 |
| `GRINDSTONE_USE` | `minecraft:block.grindstone.use` | 769 |
| `SMITHING_TABLE_USE` | `minecraft:block.smithing_table.use` | 1554 |
| `ANVIL_USE` | `minecraft:block.anvil.use` | 53 |
| `ANVIL_DESTROY` | `minecraft:block.anvil.destroy` | 47 |

### 3.2 The take sounds

| Result taken from | Sound event | Played by | Call | Volume | Pitch | Throttle |
|---|---|---|---|---|---|---|
| Loom | `ui.loom.take_result` | **server** (the result slot's `onTake`, inside `ContainerLevelAccess.execute`, which does nothing on the client where the access is the null access) | `Level.playSound(null player, block position, event, source BLOCKS, 1.0, 1.0)` | 1.0 | 1.0 | once per game tick per menu (`lastSoundTime`) |
| Cartography table | `ui.cartography_table.take_result` | server, same | same | 1.0 | 1.0 | same |
| Stonecutter | `ui.stonecutter.take_result` | server, same | same | 1.0 | 1.0 | same |
| Grindstone | `block.grindstone.use` | server sends level event **1042** (data 0) from the result slot's `onTake`; the **client** plays it | client `LevelEventHandler`: source BLOCKS, volume 1.0, pitch `nextFloat x 0.1 + 0.9`, no distance delay | 1.0 | 0.9 to 1.0 | none |
| Smithing table | `block.smithing_table.use` | server sends level event **1044** (data 0) from the menu; client plays | same as the grindstone | 1.0 | 0.9 to 1.0 | none |
| Anvil, block survived or infinite materials | `block.anvil.use` | server level event **1030**; client plays | same | 1.0 | 0.9 to 1.0 | none |
| Anvil, block destroyed | `block.anvil.destroy` | server level event **1029**; client plays | same | 1.0 | 0.9 to 1.0 | none |

Details read for the first three rows (the three menus have identical code): the guard is "`level.getGameTime()` differs from the menu's stored `lastSoundTime`"; only then the sound is played and the time is stored (initial 0). The position is the block position moved to its centre (x + 0.5, y + 0.5, z + 0.5; `Level.playSound(Entity, BlockPos, ...)` adds 0.5 to each coordinate, read). Because the player argument is null, `ServerLevel.playSeededSound` excludes nobody: the packet **Clientbound Sound** (05b 0x77; it carries the sound, source BLOCKS, the block centre, volume, pitch and a seed taken from `Level.soundSeedGenerator`, a separate thread-safe generator, so playing sounds does not advance the level's own random) is broadcast to every player within the sound event's range in that dimension, **including the player who took the result**. The range of a variable-range event is 16 blocks at volume 1.0 (`SoundEvent.getRange`: 16 for volume up to 1, else 16 x volume). **How the range is tested** (`PlayerList.broadcast`, read; the same test serves sounds and level events): a player receives the packet when it is in the same dimension and `dx^2 + dy^2 + dz^2 < range^2` (a 3D sphere, strict less-than) measured from the player's own coordinates to the packet's point; for sounds the point is the block centre (x + 0.5, y + 0.5, z + 0.5), for level events (range 64) it is the integer block coordinates. So an implementation sends one Clientbound Sound packet per take under the throttle; it never sends a sound for a take that the menu refuses.

The level-event rows (grindstone, smithing, anvil) carry no volume or pitch on the wire; the numbers in the table are those the client uses for events 1029, 1030, 1042 and 1044 (one `nextFloat` of the client's random per event), as 40-3 §1 states. **What a server sends:** one **Clientbound Level Event** packet (05a 0x2F, id 47: Event type Int, Location Position, Data Int, Global Boolean) per take, with Event type 1029, 1030, 1042 or 1044, Location the block position of the table, **Data 0** (read: every call passes 0), and Global **false** (read: `ServerLevel.levelEvent` builds the packet with the flag false). `ServerLevel.levelEvent(entity, type, pos, data)` broadcasts it to the players within **64 blocks** (a 3D sphere, strict less-than, see the range test above) of the block position (the integer block coordinates, no +0.5) in the same dimension; the three-argument `levelEvent(type, pos, data)` the menus call passes no entity, so **no player is excluded** and the taking player receives it too (the four-argument form excludes the entity only when it is a player). The server sends nothing else for these four: the sound is produced by the client.

**Anvil: which of the two events** (already specified in 40-3 §3 step 6 on the take; stated again because it decides the sound). On taking the anvil result the server draws a number only when **both** hold: the player does not have infinite materials (creative) and the block at the position is in block tag `anvil`; then the damage chance is `nextFloat() < 0.12` (12 percent; `player.getRandom()`, read as the float constant 0.12). If that roll succeeds the block is damaged (`anvil` becomes `chipped_anvil`, `chipped_anvil` becomes `damaged_anvil`); a `damaged_anvil` has no further state, so it is removed (no drops) and event **1029** (`anvil.destroy`) is sent. A successful roll on a block that can still be damaged sets the damaged block state (flags 2, neighbours not updated; the new state keeps the anvil's `facing` property, `AnvilBlock.damage` copies it, read) and sends **1030** (`anvil.use`). In every other case (infinite materials, a failed roll, a block outside the tag) event **1030** is sent and the block is untouched; infinite materials therefore never draw the random number, never damage the anvil and never produce 1029. The item-level costs and the experience handling of the take are in 40-3.

The select sounds are client-side UI sounds, documented in 40-4: the stonecutter's `ui.stonecutter.select_recipe` is played by `SimpleSoundInstance.forUI(event, 1.0)` (pitch 1.0) when a recipe button click is accepted (read again in `StonecutterScreen`).

### 3.3 What the jar cannot answer

The jar contains no `sounds.json` and no `.ogg` files (checked: `unzip -Z1 | grep -c '\.ogg$'` gives 0, and no `assets/minecraft/sounds*` entry), so which audio files and which per-file volume, pitch and weight variations back these sound events are not in the artifact (they are in the separately downloaded asset index). A client that only needs the events and parameters above is fully specified by this section; the actual samples are an asset question for the resource pack tooling (08, 14).

---

## 4. Saved-map data files

**Gap closed:** the layout of the files that hold map contents and the map counter, as 26.3 saves them (T-lines on `map_<id>.dat` and `idcounts.dat`).

### 4.1 File names: the brief's names are the old ones

In 26.3 the two files are **`data/minecraft/maps/<id>.dat`** and **`data/minecraft/maps/last_id.dat`**, inside the world-wide saved-data folder (`<world>/data/`, 07 §10.3). The older names `data/map_<id>.dat` and `data/idcounts.dat` are legacy: the file fixer `DimensionStorageFileFix` renames them when it opens an older save (read: the pattern `idcounts.dat` becomes `minecraft/maps/last_id.dat`, and `map_(\d+).dat` becomes `minecraft/maps/$1.dat`, both under `data`; other renames it performs are in 07 §10.2). A writer for this version writes only the new names. The file name of a map is `MapId.key()` = the text `maps/` plus the decimal id, resolved with the default namespace by `Identifier.withDefaultNamespace` (read); a map's id is the `map_id` component of the item (54 §26).

Both files use the common saved-data container of 07 §10.3: gzip NBT, root compound with `data` and `DataVersion` (Int; a missing `DataVersion` is read as 1343 and the fixers run up to 5023), written only when the object was marked dirty (periodic and shutdown save).

### 4.2 `maps/last_id.dat` (`MapIndex`, replaces `idcounts.dat`)

| Path | NBT | Required | Default | Meaning |
|---|---|---|---|---|
| `data.map` | Int | optional | -1 | the last map id handed out |

`getNextMapId` increments the field and returns the new value, then marks the object dirty; with the default -1 the **first map gets id 0**, the next 1, and so on. `ServerLevel.getFreeMapId` obtains the counter with `computeIfAbsent` on this type (the file is created on first use). Example file content: root `{DataVersion: 5023, data: {map: 3}}` means the next new map is id 4.

### 4.3 `maps/<id>.dat` (`MapItemSavedData.CODEC`)

`data` is a compound with these members, in write order:

| Member | NBT | Required | Default | Notes |
|---|---|---|---|---|
| `dimension` | String | **required** | | the dimension key, for example `minecraft:overworld` (`Level.RESOURCE_KEY_CODEC`; the string form is inferred from the codec name, as elsewhere in 07) |
| `xCenter` | Int | **required** | | block x of the map's centre |
| `zCenter` | Int | **required** | | block z of the map's centre |
| `scale` | Byte | optional | 0 | clamped to 0 .. 4 on load (`Mth.clamp`, read); a block-per-pixel scale of `1 << scale` (25-5 §8) |
| `colors` | Byte Array | **required** | | `BYTE_BUFFER` codec (stored as a byte array, inferred); exactly **16384** bytes (128 x 128, index `x + z x 128`), each `(base colour id << 2) | brightness id` (25-5 §8.2). A byte array of any other length is **ignored without an error**: the map loads with 16384 zero bytes (all transparent) |
| `trackingPosition` | Byte (boolean) | optional | **1** (true) | whether player markers are kept |
| `unlimitedTracking` | Byte (boolean) | optional | 0 (false) | player markers beyond the map edge |
| `locked` | Byte (boolean) | optional | 0 (false) | a locked map is not refreshed by carrying it (25-5 §8.1) |
| `banners` | List of Compound | optional | empty | banner markers (4.4) |
| `frames` | List of Compound | optional | empty | item-frame markers (4.5) |

Both lists are written from hash maps, so the **order of their entries is unspecified** and a reader must not depend on it. There is no tag for the decorations list or the player markers: only banners and frames persist; player decorations are rebuilt from the carried map each time (25-5 §8.4), and the dirty-tracking, holder and update-packet state is never saved.

### 4.4 Banner marker compound (`MapBanner.CODEC`)

| Member | NBT | Required | Default | Notes |
|---|---|---|---|---|
| `pos` | Int Array of 3 | **required** | | the banner's block position `[x, y, z]` (`BlockPos.CODEC`, 45-1) |
| `color` | String | lenient optional | `white` | a dye colour name (`DyeColor.CODEC`, 31-3 section on dye colours); an unreadable value falls back to the default instead of failing |
| `name` | text component (String or Compound, per 45-1) | lenient optional | absent | the banner's custom name |

On load each entry creates the banner marker keyed `banner-<x>,<y>,<z>` and a map decoration of the banner type for that colour (`banner_<colour>`, 46 §5.6) at the block's x and z with rotation 180.0 and the name; the y is not used for the decoration.

### 4.5 Frame marker compound (`MapFrame.CODEC`)

| Member | NBT | Required | Notes |
|---|---|---|---|
| `pos` | Int Array of 3 | **required** | the item frame's block position |
| `rotation` | Int | **required** | the frame's marker rotation (degrees, `direction.get2DDataValue() x 90` when written, 25-5 §8.4) |
| `entity_id` | Int | **required** | the frame entity's id at the time of saving |

On load each entry is stored under the key `frame-<x>,<y>,<z>` (`MapFrame.frameId(pos)`) and creates a `frame` decoration keyed `frame-<entity_id>` (`getFrameKey`) at the position's x and z with the stored rotation. Note the two different keys: the marker map is keyed by position, the decoration by entity id (25-5 §8.4 describes the decoration key). A frame marker is removed when the frame leaves (`removedFromFrame`).

### 4.6 When a map file is written

The map object is marked dirty (so the file is rewritten at the next save) by: any pixel change (`setColorsDirty`, which `updateColor` and `setColor` reach), `toggleBanner` (adding or removing a marker, both branches), `checkBanners` when a stale banner marker is removed, `removedFromFrame`, and the item-frame branch of `tickCarriedBy` when a frame marker is added or replaced. Merely moving a player marker does not mark it dirty (the player marker is not saved). Creation also marks it: `SavedDataStorage.computeIfAbsent` builds a missing object with the type's constructor and passes it to `SavedDataStorage.set`, which calls `setDirty` (read), and `set` is the call `ServerLevel.setMapData` uses too; so a new, unchanged map and the freshly created `last_id` are written at the next save (this is why the 4.7 example shows the files with all-zero `colors`), and the copies made by `locked()` and `scaled()` reach disk the same way when they are stored.

### 4.7 Example

A fresh scale-0 overworld map created at (100, 200) with tracking on, no banners, as the first map of a world. The centre follows `createFresh` (re-read: `size = 128 << scale`, `centre = floor((v + 64.0) / size) x size + size / 2 - 64`, the formula of 25-5 §8.2): `centerX = floor(164 / 128) x 128 + 0 = 128`, `centerZ = floor(264 / 128) x 128 + 0 = 256` (computed). Files after the first save:

`data/minecraft/maps/0.dat` (gzip NBT) = `{DataVersion: 5023, data: {dimension: "minecraft:overworld", xCenter: 128, zCenter: 256, scale: 0b, colors: [B; 16384 bytes], trackingPosition: 1b, unlimitedTracking: 0b, locked: 0b, banners: [], frames: []}}` and `data/minecraft/maps/last_id.dat` = `{DataVersion: 5023, data: {map: 0}}`. The `colors` are all zero until the map has been carried and refreshed.

---

## 5. Brewing fuel

**Gap closed:** which items are brewing fuel, how many charges a unit gives, the fuel slot's behaviour, and whether the marker is a tag, a component or a hard-coded check in 26.3.

### 5.1 Answer

It is a **data component**, not a tag and not a hard-coded item check: the component type `brewing_fuel` (`DataComponents.BREWING_FUEL`, component id 86 in 46 §8.1; value `BrewingFuel` with the two fields `uses` and `speed_multiplier`, both `ResolvableInt` or `ResolvableFloat` references, 25-5 §2.4). Item registration sets it with the helper `Item$Properties.brewingFuel(key)`, and `Items` calls that helper **once**, for `blaze_powder` (item id 934 in 25-5): so `blaze_powder` is the **only** brewing fuel in 26.3. No item tag for brewing fuel exists in the jar (the item tags with "brew" or "fuel" in their name are `brewing_potion_inputs`, `furnace_fuel_bottom_takeable` and `furnace_minecart_fuel`, none of which marks brewing fuel). A client or server whose item table has no `brewing_fuel` column must either add the component to the prototype of `blaze_powder` (the standard world type gets it from the extracted data) or test the item id `blaze_powder`; both are equivalent for 26.3 content.

### 5.2 Charges and speed

The component's references resolve through the data files read here: `data/minecraft/context_int_provider/brewing/uses_default.json` is the constant **20** and `data/minecraft/context_float_provider/brewing/speed_default.json` is the constant **1.0**. `BrewingStandBlockEntity.getUses` and `getSpeedMultiplier` evaluate them with the block entity's loot context and the fallbacks 0 and 1.0. So one blaze powder gives **20 charges** (brews) at speed multiplier 1.0, with brew time `ceil(400.0f / speed)` = 400 ticks (a brew of 20 seconds, `BREWING_TIME_SECONDS`).

### 5.3 The fuel slot and the counters (verified against 31-2 §4 and 40-2 §4)

- Slot index 4 of the block entity (`FUEL_SLOT`). `canPlaceItem(4, stack)` and the menu's `FuelSlot.mayPlaceItem` both test only "the stack has the `brewing_fuel` component". The slot holds a normal stack (up to the item's stack size, 64 for blaze powder).
- Fields: `fuel` (charges left, default 0), `totalFuel` (default 20 when absent from a save), `speedMultiplier` (default 1.0), saved under `Fuel`, `total_fuel`, `speed_multiplier` (31-2 §4.2).
- Each server tick, first thing: when `fuel <= 0` and the slot holds a stack with the component, `fuel = uses`, `totalFuel = fuel`, `speedMultiplier = speed`, the stack shrinks by 1 (a crafting remainder, if any, replaces the emptied slot or is dropped at the block). A new item is therefore only consumed when the counter is exhausted, and the counter never exceeds one item's `uses`: the maximum is **20** (the gauge denominator is `totalFuel`).
- A brew starts only when something is brewable and `fuel > 0`; it then does `fuel -= 1` (one charge per brew start, not per potion) and sets `brewTime = ceil(400 / speed)` where a non-positive speed is replaced by 1 (31-2 §4.5 step 5).
- Hoppers: the fuel slot is in the side face list `[0, 1, 2, 4]` and never in the down list (31-2 §4.1).

Worked example (31-2 §12 item 7 and this section): 5 blaze powder in the fuel slot, three water bottles in the potion slots and nether wart in slot 3: tick 1 loads 20 charges and leaves 4 powder; the brew starts in the same tick (`fuel` 19, `brewTime` 400); after 19 more brews the counter reaches 0 and the next tick consumes the second powder.

---

## Open questions

1. **Fluid push and lava on the hook.** `Entity.tick`/`baseTick` effects on a hook (pushing by flowing water, lava contact, fire) are those of the base entity (18 §2) and were not re-read for `FishingHook`, which overrides none of them among its methods. Whether the hook is immune to fire was not read.
2. **Table-driven trigonometry.** The cast formulas of 1.4 use `Mth.sin` and `Mth.cos`; whether they are lookup tables or exact functions was not read (the worked example is computed with exact trigonometry; the difference is far below the tolerances of a velocity test).
3. **Ring chunk biome snap numbers.** The 2.2 table gives the raw ring chunk range; the final chunk after the biome search depends on the biome source and was not enumerated (a data question: the climate of 10 and 37).
4. **Eye client smoothing.** How the client interpolates the eye between the tracker updates (range 4, interval 4, 21 §8.12) was not read; the position is set directly on each side, and the steering is server-only.
5. **Sound samples.** The audio files and per-file variation behind the sound events of §3 are not in the jar (3.3).
6. **Legacy map key spellings.** `MapBannerBlockPosFormatFix` converts the old banner `Pos` value, and the 26.3 codec reads the lower-case members `pos`, `color`, `name`, `rotation`, `entity_id`; which fixer renames the old keys (`Color`, `Name`, `Rotation`, `EntityId`) was not traced, so an importer of pre-26.1 map files should rely on the game's own fixer chain rather than this document.
7. **Tag forms of the map codecs.** The NBT forms of `dimension` (String), `colors` (Byte Array), `scale` (Byte, from `Codec.BYTE`), `pos` (Int Array of 3) and `rotation` and `entity_id` (Int) are inferred from the codec names (`Level.RESOURCE_KEY_CODEC`, `Codec.BYTE_BUFFER`, `Codec.BYTE`, `BlockPos.CODEC`, `Codec.INT`); they were not confirmed by reading a written file. The booleans are Byte tags (`Codec.BOOL`, 07 §10.4 convention).
8. **Brewing fuel in a data pack.** The component is data-carrying, so a data pack could in principle give it to other items; the shipped jar sets it in code for `blaze_powder` only (5.1). Whether the jar contains item-component override data files that add it elsewhere was not enumerated (none was seen in the file names searched).
9. **Eye at exactly zero horizontal distance.** The result of the steer formula when `len` is exactly 0 (2.6) was not traced beyond the arithmetic; whether the entity's position then becomes NaN and is discarded by the engine's position checks was not read.
