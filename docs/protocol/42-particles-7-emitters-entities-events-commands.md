# 42. Particles, part 7: emitters for entities, entity events, level events, explosions, game events, commands and packets

| | |
|---|---|
| Covers | Every particle emission outside block classes: the server routing helpers (`ServerLevel.sendParticles`), the `/particle` command, explosion particles, rain and the animate-tick driver (as pointers to 42-3 section 9.1 and 42-6 section 1, section 9.5), entity base emissions (sprint, splash, fall, effects, poof, drown, item particles), per-entity emissions, entity events, level events 1000 and up, tracking emitters (crit, enchanted hit, totem), block-entity emitters (trial spawner, vault, conduit, bell, campfire, creaking heart, sculk catalyst, sulfur), vibration particles |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. A scan of all 10,737 `net/minecraft` classes for the strings `addParticle`, `sendParticles`, `addAlwaysVisibleParticle` and `ParticleTypes` gave the list of emitting classes (153 classes, 48 of them block classes, left to 42-6). Arithmetic examples were recomputed outside the artifact. A second pass (review fixes) re-read `LivingEntity.tickEffects`, `Entity.doWaterSplashEffect`, `LivingEntity.spawnItemParticles`, `LevelEventHandler`, `Vec3Argument` and `WorldCoordinate`, `Bee`, `AbstractBoat`, `BrushItem`, `Arrow`, `ThrownEnderpearl`, `Ravager`, `Breeze`, `Allay`, `Warden`, `Sniffer`, `Mob`, `Options` and `ClientLevel`. A third pass (RS24 fixer) re-read `ClientLevel.doAnimateTick`, `doAddParticle`, `calculateParticleLevel` and `createFireworks`. A fourth pass (RS24 fixer, second round) re-read, as compact opcode and constant listings of the emitting methods, `GustSeedParticle`, `AbstractCubeMob.tick`, `Wolf.tick`, `AreaEffectCloud.clientTick`, the projectile classes of rows 6.1b to 6.12, `SpellcasterIllager`, `Witch`, `Villager`, `AbstractVillager`, `Dolphin`, `Fox`, `Panda`, `Squid` (ink and flee goal), `GlowSquid`, `Guardian`, `Endermite`, `Enderman`, `Blaze`, `Phantom`, `Illusioner`, `WitherBoss`, `EnderDragon` and its three phases, the minecarts, `PrimedTnt`, `AbstractNautilus`, `AbstractHorse`, `Camel`, `Tadpole`, `OminousItemSpawner`, `BaseSpawner.clientTick`, `Mob.spawnAnim`, and the `sendParticles` sites of `AgeableMob`, `ArmorStand`, `Cushion`, `Creaking`, `BucketItem`, `Player`, `MushroomCow`, `RemoveBlockGoal` and `SonicBoom`. Rows still carried from the first pass are named in the verification note below section 6 and in Open question 8. |
| Round | RS24 (GAP-15 of `../design/README.md` Part 5), sibling 7 |
| Data versus code | Particle sprite files, enchantment `spawn_particles` entries, biome `ambient_particles` attribute values, explosion enchantment entries and jukebox songs are DATA (the tool extracts them, 22). This document specifies the engines that read them and every emission that is code. |

Conventions are those of 42-particles-1 §1 (emitter record §1.3, random conventions §1.1). Section references: "42-1 §7.1" is the entry paths, "42-1 §7.2" the Level Particles packet handler, "42-1 §3" the options and their JSON forms, "42-1 §5.7" the tracking emitter, "42-1 §2" the particle ids. Particle names are registry names (42-1 §2). "Read" means read in the artifact this round; "(inferred)" marks deduction; "(recalled, not verified)" marks recall and is listed in the Open questions. `nextGaussian`, `nextDouble`, `nextFloat`, `nextInt(n)` are as in 42-1 §1.1. Entity helpers used throughout:

| Helper | Value (read) |
|---|---|
| `getX(s)`, `getZ(s)` | position + bounding-box width * s |
| `getY(s)` | position y + bounding-box height * s |
| `getRandomX(s)`, `getRandomZ(s)` | `getX((2 r - 1) s)` with one `nextDouble` r |
| `getRandomY()` | `getY(r)` with one `nextDouble` (a point anywhere in the height) |
| `getRandomY(s)` | `getY((2 r - 1) s)` |
| `Mth.nextDouble(rand, a, b)` | a if a >= b, else a + nextDouble * (b - a) (same for float) |
| `randomBetween(rand, a, b)` | nextFloat * (b - a) + a |
| `nextInt(rand, a, b)` (Mth) | a + nextInt(b - a + 1) (inclusive upper); `RandomSource.nextInt(a, b)` is exclusive upper |
| `triangle(c, w)` | c + w * (nextDouble - nextDouble) (first draw minus second) |
| `Vec3.offsetRandom(rand, s)` | adds (nextFloat - 0.5) * s to x, then y, then z (three draws in order) |

Server code that calls `Level.addParticle` or `addAlwaysVisibleParticle` does nothing: the four base `Level` methods are empty and `ServerLevel` does not override them (read). Only `sendParticles` reaches clients. Entity tick code that calls `addParticle` therefore produces particles only on the client copy of the entity.

## 0. Reader's map

| Question | Section |
|---|---|
| Server routing, packet fields, distance, count and speed semantics | 1 |
| `/particle` command | 2 |
| Explosion packet, small and large selection, block particles | 3 |
| Entity base emissions (Entity, LivingEntity, Player) | 4 |
| Mob effect particles, ambient and hidden rules | 5 |
| Per-entity emissions | 6 |
| Entity events that spawn particles | 7 |
| Level events | 8 |
| Block-entity emitters, ambient environment particles, rain, fireworks | 9 |
| Vibrations and game events | 10 |
| Worked examples, validation, Open questions | 11, 12, 13 |

## 1. Server routing: `ServerLevel.sendParticles` and the packet

### 1.1 Overloads and packet fields

All overloads end in one core routine that builds a Level Particles packet (05a 0x30) once and offers it to every player of the level.

| Overload | Override limiter | Always show | Distances (x,y,z) | Max speeds (x,y,z) | Randomisation |
|---|---|---|---|---|---|
| (options, x, y, z, count, dx, dy, dz, speed) | false | false | dx, dy, dz | speed, speed, speed | DEFAULT |
| same plus a randomisation argument | false | false | dx, dy, dz | speed (x3) | the argument |
| (options, x, y, z, count, dx, dy, dz, sx, sy, sz) | false | false | dx, dy, dz | sx, sy, sz | DEFAULT |
| (options, flagA, flagB, x, y, z, count, dx, dy, dz, speed) | flagA | flagB | dx, dy, dz | speed (x3) | DEFAULT |
| full form (flagA, flagB, six spreads, count, randomisation) | flagA | flagB | as given | as given | as given |
| single player form (player, options, flagA, flagB, x, y, z, count, dx, dy, dz, speed) | flagA | flagB | dx, dy, dz | speed (x3) | DEFAULT (11-argument packet constructor) |

The spreads and speeds are narrowed to 32-bit floats in the packet. The core returns the number of players that received the packet.

### 1.2 Per-player test

For each player in the level's player list the packet is sent only if (1) the player is in this level, and (2) the player's block position is closer than a radius to the particle position, tested with the block-position-to-point-centre routine (`closerToCenterThan`: the distance from the block centre to the point). The radius is **512 blocks when the first flag (override limiter) is true, otherwise 32 blocks**. The second flag (always show) does not affect the server test; it travels in the packet and selects the client's status rule (42-1 §7.1). (Read: the first boolean after the options feeds both the packet's override field and the radius.)

### 1.3 Client semantics of count, spread and speed (summary; 42-1 §7.2 holds the full text)

| count | Randomisation | Position of each particle | Velocity of each particle |
|---|---|---|---|
| 0 | any | exactly (x, y, z) | (maxSpeedX * distX, maxSpeedY * distY, maxSpeedZ * distZ); the distance fields act as a direction |
| > 0 | DEFAULT | + gaussian * dist per axis (3 draws) | gaussian * maxSpeed per axis (3 draws after the position draws) |
| > 0 | ALTERNATIVE | + nextDouble * dist per axis (uniform in [0, dist), not centred) | maxSpeed exactly |
| > 0 | ALTERNATIVE_WITH_SPEED | as ALTERNATIVE | maxSpeed * nextDouble per axis (3 more draws) |

Each spawn uses the packet entry of `ClientLevel.addParticle` with the packet's two flags (42-1 §7.1). That routine: forced when type-override or override-limiter; status test (`alwaysShow` upgrades MINIMAL to DECREASED with probability 1/10, then DECREASED becomes MINIMAL with probability 1/3); camera distance cut at 32 blocks (squared 1024) when not forced. Draw order (read again in `ClientLevel.doAddParticle` and `calculateParticleLevel`): the status level is computed BEFORE the force flag is tested, so the level random is consumed even for a forced particle: one `nextInt(10)` when `alwaysShow` is true and the setting is MINIMAL, then one `nextInt(3)` when the (possibly upgraded) setting is DECREASED. A forced particle skips only the camera-distance cut and the MINIMAL rejection; it does not skip those draws. Full text and the draw table: 42-1 section 7.1.

Consequence for emitters below: a call with count 1 and zero spread and speed gives one particle at the point with zero velocity; count 0 with a direction in the distance fields and speed 1 gives a particle with velocity equal to that direction (used by fishing, jukebox, sweep, squid ink, enchantment particles).

### 1.4 Emission sites that use `sendParticles`

These are the server-side emitters (all other emitters in sections 4 to 9 are client-side `addParticle` calls). Each row: source, trigger, particle, count, position, spread (dx, dy, dz), speed, randomisation. A blank randomisation means DEFAULT.

| Source | Trigger | Particle | Count | Position | Spread | Speed |
|---|---|---|---|---|---|---|
| `LivingEntity.checkFallDamage` | landing (on ground, fall distance > 0) in a ServerLevel, block under not air, fall power floor(calculateFallPower) > 0 | block (the block state landed on) | (int) (150 * min(0.2 + power/15, 2.5)), a truncating double-to-int conversion; the 0.2 is a FLOAT constant widened to double (0.20000000298...), so results at exact thresholds differ from a decimal 0.2 (all values are non-negative, so truncation equals floor) | entity (x, y, z); if the entity block column differs from the landed-on column the x and z are pulled to the landed block: offset from centre = (pos - blockcentre) normalised by its larger absolute component, times 0.5, added to the block centre | 0, 0, 0 | 0.15 |
| `ServerPlayer.checkFallDamage` | the player flag "spawn extra particles on fall" set, landing with fall distance > 0 (flag then cleared) | block (landed-on state) | (int) clamp(50 * fall distance, 0, 200) | centre of the landed block + (0, 0.5, 0) | 0.3, 0.3, 0.3 | 0.15 |
| `Entity.sendBubbleColumnParticles` | an entity or boat in a bubble column (called by the entity's bubble column handler after it clamps vertical velocity) | two repetitions, each: splash then bubble | 1 each | splash: (blockX + r1, blockY + 1, blockZ + r2), bubble: (blockX + r3, blockY + 1, blockZ + r4), four `nextDouble` of the level random in the order splash x, splash z, bubble x, bubble z | splash 0,0,0; bubble 0, 0.01, 0 | splash 1; bubble 0.2 |
| `AgeableMob.aiStep` | server, `forcedAgeTimer` > 0 and timer % 4 == 0 (timer then decremented each tick) | happy_villager | 1 | (getRandomX(1), getRandomY() + 0.5, getRandomZ(1)) | 0 | 0 |
| `AgeableMob.makeAgeLockedParticle` | counter > 0, counter even, ServerLevel; counter decremented each call | pause_mob_growth if the mob is age locked, else reset_mob_growth | 1 | (getRandomX(1), getRandomY(0.2) + height + (0.2 if locked else 0), getRandomZ(1)) | 0 | 0 |
| `Player.damageStatsAndHearts` (attack that damaged a living target) | health lost > 2 (in half hearts of 1.0 each) | damage_indicator | (int)(lost * 0.5) | (target x, target y at 0.5 height, target z) | 0.1, 0, 0.1 | 0.2 |
| `Player.doSweepAttack` | sword sweep attack | sweep_attack | 0 (velocity mode) | (x - sin(yaw), y at 0.5 height, z + cos(yaw)) with yaw in radians of the player rotation | dx = -sin(yaw), dy 0, dz = cos(yaw) (read) | 0, so the client velocity (max speed times distance) is (0, 0, 0) |
| `ArmorStand.showBreakingParticles`, `Cushion.showBreakingParticles` | broken | block of oak planks (armor stand) or the wool of the cushion colour | 10 | (x, getY(2/3), z) | width/4, height/4, width/4 | 0.05 |
| `Creaking.tearDown` | the creaking is torn down (ServerLevel) | block_crumble of pale oak wood; then block_crumble of an awake creaking heart | 100; 10 | bounding box centre | 0.3 of box size per axis | 0 |
| `FishingHook.catchingFish` | see 6.51 | bubble, fishing, splash | see 6.51 | | | |
| `Squid.spawnInk` | squirt | the squid's ink particle (squid_ink or glow_squid_ink) | 30, one packet each | ink origin + (0, 0.5, 0) | direction in distance fields, count 0 | 0.1 |
| `MushroomCow.mobInteract` (brown variant, not a baby) | the branch where the stored stew-effects field is non-null (the earlier branch tests the effects obtainable from the held item; the full branch conditions were not traced) | smoke | 2 | (x, getY(0.5), z) | distances 0.5, 0, 0.5; the per-axis max speeds are (0, 0.2, 0) (read: the constants after the distances are 0, 0.2, 0; the earlier text 0.2, 0, 0.2 was wrong) | randomisation ALTERNATIVE_WITH_SPEED (velocity = (0, 0.2 r, 0), r one `nextDouble` per axis) |
| `MushroomCow.mobInteract` (same method, other branch) | the branch that emits the spell particle (`effect` with `SpellParticleOption`, colour -1, power 1 as previously recorded; those two constants were not re-read) | effect | 4 | same | same (distances 0.5, 0, 0.5; max speeds 0, 0.2, 0) | ALTERNATIVE_WITH_SPEED |
| `MushroomCow` shear | lambda | explosion | 1 | (x, getY(0.5), z) | 0 | 0 |
| `BucketItem.emptyContents` | water poured where water evaporates | large_smoke | 8 | block corner (x, y, z) | 1, 1, 1 | speed 0, randomisation ALTERNATIVE |
| `DispenseItemBehavior` water bottle, `PotionItem.useOn` | water bottle on a block convertible to mud | splash | 5 | (blockX + r, blockY + 1, blockZ + r) | 0 | 1 |
| `JukeboxSongPlayer.spawnMusicParticles` | each emission while a song plays | note | 0 | block bottom centre + (0, 1.2, 0) | dx = nextInt(4) / 24 (a note colour), 0, 0 | 1 |
| `RemoveBlockGoal.tick` (egg-eating mobs) | reached the block and the counter `ticksSinceReachedGoal` > 0 (read; so every tick after the first at the block) | item (egg) | 3 | (block x + 0.5, y + 0.7, z + 0.5) | (nextFloat - 0.5) * 0.08 per axis | 0.15 |
| same, block removed | when the counter exceeds 60 (the test is `> 60`, so on the 61st tick; server only, after `removeBlock`) | poof, 20 separate packets | 1 | (x + 0.5, y, z + 0.5) | gaussian * 0.02 per axis (the distances, count 1 uses them as spread) | 0.15 |
| `Wolf.actuallyHurt` | armor crack stage changes | item (armadillo scute) | 20 | (x, y + 1, z) | 0.2, 0.1, 0.2 | 0.1 |
| `ShulkerBullet.onHitBlock` | hit | explosion | 2 | position | 0.2 | 0 |
| `ShulkerBullet.hurtServer` | shot down | crit | 15 | position | 0.2 | 0 |
| `SonicBoom` (warden, tick lambda) | attack | sonic_boom | 1 per step | from the chest point (warden position + the warden-chest attachment rotated by the yaw) toward the target eye, step i = 1 to floor(distance) + 6 inclusive (loop bound floor(distance) + 7, exclusive) times the unit direction; then the sound and 10 damage | 0 | 0 |
| `SpawnParticlesEffect` (enchantment) | the enchantment effect | the effect's particle | 0 | see 6.52 | velocity as direction | the effect's speed sample |
| `VibrationSystem` | see 10 | vibration | 1 | see 10 | 0 | 0 |
| `CreakingHeartBlockEntity.emitParticles` | see 9.6 | trail | see 9.6 | see 9.6 | 0 | 0 (flags true, true) |
| `SculkCatalyst` listener | a mob dies near | sculk_soul | 2 | (x + 0.5, y + 1.15, z + 0.5) | 0.2, 0, 0.2 | 0 |

Verification of this section: the rows for `LivingEntity.checkFallDamage` (constants 150, 15, 2.5, 0.15, 0.5 pull-in), `ServerPlayer.checkFallDamage` and the Wolf scute row were confirmed by the reviewer; the rows for `AgeableMob`, `ArmorStand`, `Cushion`, `Creaking.tearDown`, `BucketItem.emptyContents`, `Player.damageStatsAndHearts`, `Player.doSweepAttack`, `Squid.spawnInk`, `ShulkerBullet`, `MushroomCow`, `RemoveBlockGoal` and `SonicBoom` were re-read in the fourth pass. Rows carried from the first pass and NOT re-read (read once, not cross-checked; Open question 8): `Entity.sendBubbleColumnParticles`, the dispenser and `PotionItem.useOn` water bottle row, the `JukeboxSongPlayer` row (only the constants 1.2 and 24 were seen; its emission cadence was not read), the `SculkCatalyst` listener row, and the trigger conditions of the two `MushroomCow` branches.

(Client-side emitters are not in this table: the Tadpole feed, the Sniffer and Warden digging and the rest are only in section 6, rows 6.41, 6.36 and 6.37.)

## 2. The `/particle` command

Syntax and keys are in 16 §7.8 and 15 §6.5; this section adds the semantics read this round.

1. Permission level 2 (`hasPermission(LEVEL_GAMEMASTERS)`).
2. Argument `name` is a particle: an identifier (default namespace `minecraft`) read by the identifier reader; if no particle type has that key the error is `particle.notFound` with the identifier (a dynamic exception with context). Registry key lookup is exact.
3. After the identifier, if the next character is `{` the reader parses an SNBT compound (the whole compound, a standard tag parser over NBT); otherwise the options are an empty compound. The compound is decoded with **that type's own map codec** (the fields of 42-1 §3, no `type` key), in the registry-aware serialization context. A decode failure is `particle.invalidOptions` with the failure message. Examples that the command lists: `foo`, `foo:bar`, `particle{foo:bar}`. Consequences by options class (field names from 42-1 §3):
   - simple types: `{}` or nothing; extra fields are ignored by the unit codec (inferred from the codec being a unit codec).
   - `block`, `block_marker`, `falling_dust`, `dust_pillar`, `block_crumble`: `{block_state: ...}` required (a block state compound or a block name).
   - `item`: `{item: {...}}` required.
   - `dust`: `color` and `scale` (scale in [0.01, 4]); `dust_color_transition`: `from_color`, `to_color`, `scale`.
   - `entity_effect`, `tinted_leaves`, `flash`: `color` ARGB (int or four floats).
   - `effect`, `instant_effect`: `color` optional (default -1), `power` optional (default 1).
   - `dragon_breath`: `power` optional. `sculk_charge`: `roll`. `shriek`: `delay`. `vibration`: `destination` (block only) and `arrival_in_ticks`. `trail`: `target`, `color`, `duration`. `geyser`, `geyser_plume`: `water_blocks`. `geyser_base`, `geyser_poof`: `water_blocks`, `burst_impulse_base`.
4. Optional `pos` (vec3, default the source position), `delta` (a vec3 built by `Vec3Argument.vec3(false)`; the class has one boolean field, `centerCorrect`, so the argument is not a minimum-0 or no-negative type and `delta` accepts negative numbers. With the flag false a whole-number x or z is not shifted; the `pos` argument uses `vec3()`, whose flag is true; see the paragraph below), `speed` (float >= 0), `count` (integer >= 0), `force` or `normal` (default normal), optional `viewers` (players selector, default all online players).
5. Short forms: `particle <name>` and `particle <name> <pos>` send delta (0,0,0), speed 0, count 0, normal, to every player: one particle at the position with zero velocity.
6. For every viewer the command calls the per-player `sendParticles` (1.1 last row) with: overrideLimiter = (force), alwaysShow = false, position, count, delta as the three distances, speed as all three max speeds, randomisation DEFAULT. So `force` raises the server radius from 32 to 512 and makes the client skip its distance and status tests; `normal` keeps both.
7. Result: the count of viewers that were sent a packet. If it is 0 the command fails with `commands.particle.failed`; otherwise it sends the success message `commands.particle.success` with the registry key text of the type (not the options) and returns the count.

Centre correction (read in `Vec3Argument.parse`, `WorldCoordinates.parseDouble` and `WorldCoordinate.parseDouble`): a vec3 argument that does not start with `^` (local coordinates, a separate form) reads three coordinates, the first and the third with the argument's flag and the second (y) always with the flag false. A coordinate that is absolute (no leading `~`), whose text contains no `.` and is not empty, and whose flag is true, gets 0.5 added. So `particle flame 0 64 0` (`pos` is flag-true) spawns at x = 0.5, y = 64, z = 0.5, while the same numbers in `delta` stay 0, 64, 0 and `0.0` in `pos` stays 0. 16 section 7.8 describes this argument with a "minimum 0" flag, which the jar does not support; it should cross-reference this paragraph.

Worked: `particle minecraft:flame 0 64 0 0.5 0.5 0.5 0.01 20 force` sends one packet (count 20, spreads 0.5, speed 0.01) to each online player, at any distance up to 512 blocks; each client spawns 20 flames at gaussian offsets of standard deviation 0.5 per axis with velocity components of standard deviation 0.01.

## 3. Explosions

### 3.1 Server side (`ServerLevel.explode`)

1. A server explosion object is built from the level, source entity, damage source, damage calculator, centre, radius, fire flag and block-interaction (the interaction enumeration is mapped by game rules: none keeps blocks; block, mob, tnt choose destroy-with-decay or destroy by the corresponding drop-decay rule, mob also needs `mob_griefing`; trigger is the fifth case; details belong to the explosion engine, not read here).
2. The explosion runs and returns the number of blocks affected (`blockCount`).
3. **Particle selection:** the explosion is **small** when its radius is less than 2 or when it does not interact with blocks (interaction equals keep); otherwise large. The small particle and the large particle are parameters of `explode`. Defaults (the overloads without particle arguments): small = `explosion`, large = `explosion_emitter`, block particles = the default weighted list (3.3), sound `generic_explode`.
4. For every player of the level whose squared distance to the centre is below 4096 (64 blocks) a Explode packet (05a Explosion) is sent with: centre, radius, block count, optional knockback of that player, the chosen particle, the sound, the weighted block particle list, and the "play sound" flag (true unless the source entity is silent).

Known callers with non-default particles (read): wind charge radius 1.2, interaction trigger, small `gust_emitter_small`, large `gust_emitter_large`, empty block particle list, sound wind charge burst; breeze wind charge radius 3, same particles; wind-charged effect on death radius 3 + 2 * nextFloat at the entity centre, same particles; the enchantment `explode` effect takes small, large, block particles, sound and radius from the data. An empty block-particle list is ignored by the client tracker (3.2).

### 3.2 Client side (`handleExplosion`, `ClientExplosionTracker`)

On receiving the packet (05a section 0x24, Clientbound Explode, id 36):
1. If the play-sound flag is set, a local sound at the centre (volume 4, pitch (1 + (nextFloat - nextFloat) * 0.2) * 0.7); sound is out of scope.
2. `addParticle(packet particle, centre, velocity (1, 0, 0))` once, through the normal entry (42-1 §7.1). For `explosion` the velocity x is the particle's size parameter; for `explosion_emitter` the spawned seed particle uses its own rules (42-2 section 3.12 for the particle classes).
3. The tracker records (centre, radius, block count, weighted block particles) unless the weighted list is empty.
4. The knockback optional is applied to the local player.

`ClientExplosionTracker.tick`, called once per client level tick (after the sky flash, before the chunk source tick), first clears everything if the player's particle setting is not ALL (decreased and minimal show no block-explosion particles). Otherwise:
- total weight W = sum of block counts of all recorded explosions; the number of particles N = min(W, 512) (**512 per tick maximum**);
- N times: pick one explosion with probability proportional to its block count (`nextInt(W)` then walk the list subtracting each block count until the value goes below zero), then spawn one particle for it (below);
- clear the list.

One block-explosion particle for explosion E (radius R, centre C), all draws from the level random in this order:
1. a direction: three `nextFloat`, each 2 f - 1, normalised (a zero vector is not special-cased: unread).
2. a distance d = cbrt(nextFloat) * R (uniform in volume).
3. the point P = C + direction * d. If the block at P is **not air** the attempt is discarded (no particle, no retry).
4. a speed factor s = (0.5 / (d / R + 0.1)) * nextFloat * nextFloat + 0.3.
5. one entry of the weighted list, by `nextInt(totalWeight)`.
6. position = C + (P - C) * entry.scaling; velocity = direction * (s * entry.speed); spawn with the normal entry.

### 3.3 Default block-particle list

Two entries of weight 1 each: `poof` (scaling 0.5, speed 1.0) and `smoke` (scaling 1.0, speed 1.0) (read in `Level`'s static data). Wire form of the entries: 05a Explosion (`WeightedExplosionParticle`). The data form: `particle`, `scaling` (default 1), `speed` (default 1).

### 3.4 Seed particles

`explosion_emitter` creates `HugeExplosionSeedParticle` (class read in 42-2 section 3.12, which owns the numbers: lifetime 8, six `explosion` particles per tick over ages 0 to 7, 48 in all, offsets from two `nextDouble` per axis, velocity x = age / lifetime). They are cited there and not restated here. `gust_emitter_small` and `gust_emitter_large` create `GustSeedParticle` (class read this round). Its constructor takes a scale (double), a lifetime and a tick delay between bursts; the values for the small and large emitters come from their providers and are 42-5's (not read here, Open question 10). Per client tick, with age counted from 0: (1) if age mod (delay + 1) is 0, three `gust` particles are spawned through the normal `ClientLevel.addParticle` entry, each at x + (r1 - r2) * scale, y + (r3 - r4) * scale, z + (r5 - r6) * scale (six `nextDouble` per particle, in that order: two for x, two for y, two for z), with velocity (age / lifetime as float division, 0, 0), so the first velocity component grows from 0 toward 1 over the life and the other two are 0; (2) age is incremented; (3) when age equals lifetime the particle is removed. The seed itself is not rendered. Worked value: lifetime 6, delay 0 gives bursts at ages 0 to 5, 18 `gust` particles in all, velocity x = 0, 1/6, ... 5/6.

## 4. Entity base emissions

All client side (`addParticle`, normal entry) unless marked.

| Source | Trigger | Particle | Count | Position | Velocity | Draws |
|---|---|---|---|---|---|---|
| `Entity.spawnSprintParticle` (called from `baseTick` when sprinting, not in water, not spectator, not crouching, not in lava, alive) | every tick | block (state of the block under, via `getOnPos(0.2)`), unless the block's render shape is invisible | 1 | x = entity x + (nextDouble - 0.5) * width, z likewise, each clamped into the supporting block's column when the entity's block column differs from the supporting block's; y = entity y + 0.1 | (-4 vx, 1.5, -4 vz) with the entity velocity | x draw then z draw |
| `Entity.doWaterSplashEffect` (first tick touching water, not the first tick of the entity) | enter water | bubble loop, then splash loop (all bubbles first) | each loop runs for i = 0, 1, ... while i < 1 + width * 20 (float arithmetic), so 13 per loop for width 0.6 | x = entity x + (2 r - 1) * width, z likewise, y = floor(y) + 1 | with V = the unscaled delta movement of the controlling passenger, or of the entity itself when it has none: bubble (Vx, Vy - 0.2 r, Vz), splash (Vx, Vy, Vz) | order: first the sound (below), then every bubble (x draw, z draw, one more `nextDouble` for the bubble velocity), then every splash (x draw, z draw); then the game event `splash`. The 0.2 and 0.9 factors do not touch the particles: they scale the sound volume only. Volume = min(sqrt(0.2 Vx^2 + Vy^2 + 0.2 Vz^2) * k, 1) with k = 0.2 when the controlling entity is the entity itself, 0.9 when it is a passenger; volume < 0.25 selects the quiet swim-splash sound, else the high-speed one; pitch 1 + (nextFloat - nextFloat) * 0.4 (two draws, before the particle draws) |
| `LivingEntity.makePoofParticles` (also `Mob.spawnAnim`, events 20 and 60) | event | poof | 20 | (getRandomX(1) - 10 vx, getRandomY() - 10 vy, getRandomZ(1) - 10 vz) | (vx, vy, vz) = gaussian * 0.02 each | draws: vx, vy, vz first, then the three randoms |
| `LivingEntity.makeDrownParticles` (event 67) | event | bubble | 8 | entity position + `triangle(0, 1)` per axis | the entity velocity | |
| `LivingEntity.spawnItemParticles(stack, count)` | break item events, eating (5 per emission, 16 on completion) | item (the stack); nothing for an empty stack | count | per particle, in this draw order: (1) `nextFloat` r1: velocity x = (r1 - 0.5) * 0.1; (2) `nextFloat` r2: velocity y = r2 * 0.1 + 0.1; velocity z = 0; this vector is rotated about the x axis by -pitch, then about the y axis by -yaw (angles in radians, factor 0.017453292). (3) `nextFloat` r3: origin y = -r3 * 0.6 - 0.3; (4) `nextFloat` r4: origin x = (r4 - 0.5) * 0.3; origin z = 0.6; this vector gets the same two rotations, then (x, eye y, z) of the entity is added | the rotated velocity vector + (0, 0.05, 0) (the 0.05 is added to y after the rotation) | four `nextFloat` per particle in the order r1, r2, r3, r4 (read) |
| `LivingEntity.tickEffects` (client) | every tick when the synchronised list of effect particles is non-empty | one random entry of the list | 1 per accepted tick | (getRandomX(0.5), getRandomY(), getRandomZ(0.5)), evaluated in that order: x, y, z | (1, 1, 1) | one test `nextInt(a * b) == 0` with a = 15 when the entity IS invisible and 4 when it is visible, and b = 5 when the ambient flag is true, else 1 (so a visible entity emits on 1 tick in 4, an invisible one on 1 in 15, and all-ambient multiplies the denominator by 5); on success one `Util.getRandom` pick of the list (one draw), then the x, y, z position draws |
| `LivingEntity` event 46 (teleport) | event | portal | 128 | for i in 0..127, t = i / 127: lerp(t, old pos, new pos) + (nextDouble - 0.5) * width * 2 on x and z, + nextDouble * height on y | ((nextFloat - 0.5) * 0.2) per axis | draws per particle: three floats first, then x, y, z doubles |
| `AbstractVillager.addParticlesAroundSelf(p)` (events) | event | p | 5 | (getRandomX(1), getRandomY() + 1, getRandomZ(1)) | gaussian * 0.02 per axis | velocities drawn first |
| `Animal.aiStep` | server and client ticks: `inLove` > 0, decremented each tick, when the new value % 10 == 0 | heart | 1 | (getRandomX(1), getRandomY() + 0.5, getRandomZ(1)) | gaussian * 0.02 per axis | velocities first |
| `TamableAnimal`, `AbstractHorse.spawnTamingParticles(ok)`, `Ocelot.spawnTrustingParticles(ok)` | events 6/7, 40/41 | heart if ok, else smoke | 7 | as the row above | as above | |

Notes: the number of splash and bubble particles at a water entry for a width-0.6 entity: loop while i < 1 + 0.6 * 20 = 13, so 13 of each. In `tickEffects` the chance test is a single `nextInt(a * b)` that must be 0 (row above for a and b).

## 5. Mob effect particles

### 5.1 What the server synchronises
`updateSynchronizedMobEffectParticles` (called by `updateInvisibilityStatus` whenever the active effects change): the list `DATA_EFFECT_PARTICLES` is the particle options of every active effect whose **visible** flag is true (hidden effects, those with `showParticles` false, are excluded), each obtained from the effect's particle factory; the flag `DATA_EFFECT_AMBIENCE_ID` is true when **every visible effect is ambient** (an empty set of visible effects gives true; the list is then empty anyway). With no active effects the list is cleared and the entity is not invisible. Packet: entity data (05b); both are ordinary synchronised fields.

### 5.2 Per-effect particle factory
The default factory builds `entity_effect` with colour = ARGB(alpha, effect colour) where alpha is 255, or **38** (= floor of 38.25) for an ambient effect (beacon and conduit effects). Four effect classes and two data entries override the particle: `infested` uses `infested`, `oozing` uses `item_slime`, `weaving` uses `item_cobweb`, `wind_charged` uses `small_gust`, `trial_omen` uses `trial_omen`, `raid_omen` uses `raid_omen` (these take a constant particle, ignoring ambient). Effect colours (RGB, the second constructor argument, read): speed 3402751, slowness 9154528, haste 14270531, mining_fatigue 4866583, strength 16762624, instant_health 16262179, instant_damage 11101546, jump_boost 16646020, nausea 5578058, regeneration 13458603, resistance 9520880, fire_resistance 16750848, water_breathing 10017472, invisibility 16185078, blindness 2039587, night_vision 12779366, hunger 5797459, weakness 4738376, poison 8889187, wither 7561558, health_boost 16284963, absorption 2445989, saturation 16262179, glowing 9740385, levitation 13565951, luck 5882118, unluck 12624973, slow_falling 15978425, conduit_power 1950417, dolphins_grace 8954814, bad_omen 745784, hero_of_the_village 4521796, darkness 2696993, trial_omen 1484454, raid_omen 14565464, wind_charged 12438015, weaving 7891290, oozing 10092451, infested 9214860, breath_of_the_nautilus 65518. (Registry order is as listed; the mob effect registry ids belong to 46.)

### 5.3 Client emission
Each client tick `tickEffects` ticks the effect durations and then: if the synchronised list is non-empty, let a = 15 when the entity is invisible and 4 when it is visible (read: the bytecode pushes 15 on the invisible branch), and b = 5 when the ambient flag is true, else 1. Draw `nextInt(a * b)`; if it is 0, pick one entry of the list with a uniform pick (`Util.getRandom`, one draw, taken before the position draws) and spawn it at (getRandomX(0.5), getRandomY(), getRandomZ(0.5)) with velocity (1, 1, 1) through the normal entry. The position draws are evaluated in the order x, y, z (one `nextDouble` each). A visible entity therefore emits on average once per 4 ticks, an invisible one once per 15 ticks (3.75 times LESS often than a visible one), and all-ambient effects multiply the interval by 5 (once per 20 ticks visible, once per 75 invisible).

### 5.4 Other consumers of the same particle
Arrow (colour), area effect cloud, spectral arrow, bell: sections 6.1, 6.2. The potion splash level events 2002 and 2007: section 8.

## 6. Per-entity emissions

Client unless a `sendParticles` pointer is given (section 1.4). "per tick" means every client tick of the entity.

| # | Entity or class | Trigger | Particle | Count | Position | Velocity | Notes |
|---|---|---|---|---|---|---|---|
| 6.1 | `Arrow` (tipped, `Arrow.tick` then `makeParticle(n)`) | client tick only, after the base arrow tick: when the arrow is in the ground, `makeParticle(1)` on ticks where `inGroundTime % 5 == 0`; when it is not in the ground, `makeParticle(2)` every tick. `makeParticle` returns without spawning when the colour is -1 (no potion contents) or n <= 0. Server side, an in-ground arrow with non-empty potion contents and `inGroundTime` >= 600 broadcasts entity event 0 and its pickup item becomes a plain arrow | entity_effect with the arrow colour (`ColorParticleOption` from the int colour) | n per call | (getRandomX(0.5), getRandomY(), getRandomZ(0.5)), draw order x, y, z | 0 | Event 0 (client): if the colour is not -1, 20 entity_effect particles with the colour channels as floats r = (c >> 16 & 255) / 255, g = (c >> 8 & 255) / 255, b = (c & 255) / 255, same position rule |
| 6.1b | AbstractArrow | each tick in flight: in water | bubble | 4 | pos - velocity * 0.25 | the arrow velocity | |
| | | crit arrow | crit | 4, i = 0..3 | pos + velocity * i / 4 | (-vx, -vy + 0.2, -vz) | |
| 6.1c | SpectralArrow | each tick, client, not in ground | effect (colour -1, power 1) | 1 | arrow position | 0 | |
| 6.2 | AreaEffectCloud (client tick) | each tick; skipped on half the ticks (`nextBoolean`) while waiting | the cloud's particle; for entity_effect while waiting, 50% replaced by the default particle | if waiting: 2 positions in radius 0.2; else ceil(pi * r * r) positions in radius r | angle 2 pi nextFloat, distance sqrt(nextFloat) * radius; x = cloud x + cos * d, y = cloud y, z + sin * d | waiting: 0; otherwise ((0.5 - nextDouble) * 0.15, 0.01, (0.5 - nextDouble) * 0.15), except entity_effect and waiting emissions which use 0 | **always visible** entry (`addAlwaysVisibleParticle`) |
| 6.3 | Thrown projectiles (`ThrowableProjectile`, `AbstractHurtingProjectile`) | in water | bubble | 4 | pos - velocity * 0.25 | velocity | |
| 6.4 | Hurting projectile trail (`createParticleTrail`) | each tick | `getTrailParticle()` of the class (null: none) | 1 | (x, y + 0.5, z) | 0 | dragon fireball trail: dragon_breath power 1 |
| 6.5 | Snowball event 3 | event | the item particle of the thrown item (`getParticle`) | 8 | position | 0 | |
| 6.6 | ThrownEgg event 3 | event, item not empty | item (the thrown stack) | 8 | position | (nextFloat - 0.5) * 0.08 per axis | |
| 6.7 | `ThrownEnderpearl.onHit` | the hit; `ThrowableProjectile.tick` runs the hit test and calls `onHit` with no client or server test in between (read: no side test appears in the call sequence), so both the client copy and the server copy run this part | portal | 32, the first statement of `onHit` after the base call | (x, y + 2 * nextDouble, z): the x and z are the projectile position unmodified | (gaussian, 0, gaussian) | draws per particle: one `nextDouble` (y), then two `nextGaussian` (vx, vz). The rest of `onHit` returns immediately on the client (it needs a `ServerLevel`). The teleported entity's own particles are event 46 and level event 2018 |
| 6.8 | EyeOfEnder `spawnParticles(pos, velocity)` | each tick | in water: bubble x4 at pos with the velocity; else portal x1 at (pos.x + 0.6 r - 0.3, pos.y - 0.5, pos.z + 0.6 r' - 0.3) | | | the velocity | |
| 6.9 | FireworkRocketEntity | each tick, client (`life % 2 < 2`, always true) | firework | 1 | position | (gaussian * 0.05, -vy * 0.5, gaussian * 0.05) | draws x then z |
| 6.10 | ShulkerBullet tick (client) | each tick | end_rod | 1 | (x - vx, y - vy + 0.15, z - vz) | 0 | server hit emissions in 1.4 |
| 6.11 | LlamaSpit `recreateFromPacket` | spawn | spit | 7, i = 0..6 | position | (vx * (0.4 + 0.1 i), vy, vz * (0.4 + 0.1 i)) | |
| 6.12 | EvokerFangs tick | client, attack started, when lifeTicks reaches 14 | crit | 12 | (x + (2 r - 1) * width * 0.5, y + 0.05 + r', z ...) then y + 1 | ((2 r - 1) * 0.3, 0.3 + 0.3 r, (2 r - 1) * 0.3) | draws: x, y, z position then vx, vy, vz |
| 6.13 | SpellcasterIllager tick | client, casting | entity_effect with the spell colour (float channels of the spell) | 2 per tick | angle a = yBodyRot rad + cos(tick * 0.6662) * 0.25; offsets +- (cos a * 0.6 scale, , sin a * 0.6 scale) at y + 1.8 scale | 0 | one on each side |
| 6.14 | Witch event 15 | event | witch | nextInt(35) + 10 (evaluated each loop test) | (x + gaussian * 0.13, box max y + 0.5 + gaussian * 0.13, z + gaussian * 0.13) | 0 | the loop bound re-draws `nextInt(35)` every iteration (read), so the count is stochastic |
| 6.15 | Villager event 12, 13, 14, 42 | event | heart, angry_villager, happy_villager, splash | 5 | 4 row 'addParticlesAroundSelf' | | |
| 6.16 | Dolphin tick (client) | in water and squared speed > 0.03 | dolphin | 2 iterations, each spawning one particle on each side (4 per tick) | one distance f = 1.2 - 0.7 r (one `nextFloat`, drawn once per tick BEFORE the loop, not per iteration); particle A at (x - view.x f + 0.3 cos(yaw), y - view.y f, z - view.z f + 0.3 sin(yaw)), particle B at (x - view.x f - 0.3 cos(yaw), y - view.y f, z - view.z f - 0.3 sin(yaw)); the iterations do not redraw f | 0 | no draws inside the loop (read) |
| 6.17 | Dolphin event 38 | event | happy_villager | 7 | (getRandomX(1), getRandomY() + 0.2, getRandomZ(1)) | gaussian * 0.01 | |
| 6.18 | Fox event 45 | eating, held item | item | 8 | (x + look.x / 2, y, z + look.z / 2) | (( r1 - 0.5) * 0.1, r2 * 0.1 + 0.1, 0) rotated by -pitch, -yaw, y + 0.05 | |
| 6.19 | Panda eating (client) | every 5th eat tick | item (held) | 6 | local offset (( r - 0.5) * 0.8, -r * 0.6 - 0.3, 1 + (r - 0.5) * 0.4) rotated by -body yaw, added to (x, eye y + 1, z) | local velocity (( r - 0.5) * 0.1, r * 0.1 + 0.1, (r - 0.5) * 0.1) rotated, y + 0.05 | |
| 6.19b | Panda sneeze | sneeze | sneeze | 1 | (x - (width + 1) * 0.5 sin(body yaw), eye y - 0.1, z + (width + 1) * 0.5 cos(body yaw)) | (vx, 0, vz) | |
| 6.20 | FishingHook | server tick states | see 6.51 | | | | |
| 6.21 | Squid (client flee goal) | every 10th flee tick (`fleeTicks % 10 == 5`) | bubble | 1 | the squid position | 0 | ink in 1.4 |
| 6.22 | Glow squid aiStep | each tick | glow | 1 | (getRandomX(0.6), getRandomY(), getRandomZ(0.6)) | 0 | |
| 6.23 | Guardian aiStep | moving in water | bubble | 2 | (getRandomX(0.5) - view.x * 1.5, getRandomY() - view.y * 1.5, getRandomZ(0.5) - view.z * 1.5) | 0 | |
| | | beam to the target | bubble | along the beam | t starts at nextDouble; repeat: t += (1.8 - a) + nextDouble * (1.7 - a), spawn at eye + unit direction * t while t < distance, a = attack animation scale | 0 | `a` is `getAttackAnimationScale(0)` |
| 6.24 | Endermite, Enderman aiStep (client) | each tick | portal | 2 | (getRandomX(0.5), getRandomY() [- 0.25 for the enderman], getRandomZ(0.5)) | ((r - 0.5) * 2, -r', (r - 0.5) * 2) | |
| 6.25 | Blaze aiStep (client) | each tick | large_smoke | 2 | (getRandomX(0.5), getRandomY(), getRandomZ(0.5)) | 0 | |
| 6.26 | Phantom tick (client) | each tick | mycelium | 2 mirrored | a = (uniqueFlapOffset + tick) * 7.448451 deg + 180 deg; f = cos(a); sideways d = width * 1.48 (cos yaw, sin yaw); height (0.3 + f * 0.45) * height * 2.5; +- d | 0 | |
| 6.27 | Illusioner aiStep | invisible, on hurt time 1 or every 1200 ticks | cloud | 16 | (getRandomX(0.5), getRandomY(), getZ(0.5)) | 0 | |
| 6.28 | WitherBoss aiStep | each tick | per head (3): smoke at head + gaussian * 0.3 scale; if powered and `nextInt(4) == 0` also entity_effect (0.7, 0.7, 0.5) | | | 0 | invulnerable (spawning): 3 entity_effect (0.7, 0.7, 0.9) at (x + gaussian, y + nextFloat * 3.3 scale, z + gaussian) |
| 6.29 | EnderDragon | dying (`aiStep`) | explosion | 1 per tick | (x + (r - 0.5) * 8, y + 2 + (r' - 0.5) * 4, z + (r'' - 0.5) * 8) | 0 | `tickDeath` ticks 180 to 200: explosion_emitter at the same offsets, one per tick |
| 6.30 | `DragonDeathPhase.doClientTick` | death phase client tick every 10th tick | explosion_emitter | 1 | same offsets | 0 | |
| | `DragonLandingPhase.doClientTick` | each tick | dragon_breath power 1 | 8 | head (x, y at 0.5, z) + gaussian / 2 per axis | (-d.x * 0.08 + vx, -d.y * 0.3 + vy, -d.z * 0.08 + vz) with d the normalised head look rotated by -45 deg then +11.25 deg (pi/16) after each particle | |
| | `DragonSittingFlamingPhase.doClientTick` | every 2nd tick while flame ticks < 10 | dragon_breath | 8 x 6 | as above | (-d.x * 0.08 * i, -d.y * 0.6, -d.z * 0.08 * i), i = 0..5 | |
| 6.31 | `Creaking` | the class has no client-side emission; its only particle code is `tearDown` (server `sendParticles`, two calls: 100 `block_crumble` of pale oak wood, then 10 `block_crumble` of an awake creaking heart, record in section 1.4) | | | | | the creaking heart block entity's `trail` emitter is 9.6 |
| 6.32 | MinecartFurnace | fuel, `nextInt(4) == 0` | large_smoke | 1 | (x, y + 0.8, z) | 0 | |
| 6.33 | MinecartTNT, PrimedTnt | fuse running (client for TNT) | smoke | 1 per tick | (x, y + 0.5, z) | 0 | |
| 6.34 | Slime, MagmaCube, SulfurCube (`AbstractCubeMob.tick`, client copy; the server call of `addParticle` does nothing) | landing: on ground now and not on ground at the previous tick | `getParticleType()`: item_slime, flame, sulfur_cube_goo; a null result still consumes the draws and spawns nothing | Count rule (read): s = (float) dimension width of the current pose * 2; the loop runs for integer i = 0, 1, ... while (float) i < s * 16 (a float comparison, no truncation), so the count is ceil(32 * width) in float arithmetic. Worked values: width 0.5 gives s = 1.0, bound 16.0, 16 particles; width 1.0 gives 32; width 0.52 (a size-1 slime's width, recalled, not verified) gives 1.04 * 16 = 16.64, so 17 | per iteration, in this order: r1 = `nextFloat` (angle = r1 * 6.2831855), r2 = `nextFloat` (factor = r2 * 0.5 + 0.5); offset x = sin(angle) * (s / 2) * factor, z = cos(angle) * (s / 2) * factor with s / 2 = width (float); position (x + offset x, y, z + offset z) | 0 | after the loop: the squish sound (two `nextFloat` for pitch) and target squish -0.5 |
| 6.35 | `Ravager` | (a) stun: `stunnedTick` is set to 40 by entity event 39 and decremented once per `aiStep` (both sides); `stunEffect` runs on every `aiStep` while it is above 0, and emits only when `nextInt(6) == 0`. (b) roar: entity event 69 (`addRoarParticleEffects`) | (a) entity_effect with float colour (0.49803922, 0.5137255, 0.57254905); (b) poof | (a) 1; (b) 40 | (a) x = entity x - width * sin(yBodyRot in radians) + (0.6 * nextDouble - 0.3); y = entity y + height - 0.3; z = entity z + width * cos(yBodyRot) + (0.6 * nextDouble - 0.3); (b) the bounding box centre | (a) 0; (b) gaussian * 0.2 per axis | (a) draws: `nextInt(6)`, then the x offset, then the z offset; (b) per particle three gaussians in order x, y, z. The roar event also applies a client knockback (not a particle) |
| 6.36 | `Warden` (client `tick`) | pose EMERGING uses the emerge animation state, pose DIGGING the digging animation state; each tick, if that animation's elapsed time is under 4500 ms (float compare) and the block under the warden (`getBlockStateOn`) has a render shape other than invisible | block (that state) | 30 per tick | x = entity x + `randomBetween(-0.7, 0.7)`, y = entity y (no offset), z = entity z + `randomBetween(-0.7, 0.7)`; draws: x then z per particle | 0 | |
| 6.37 | `Sniffer` (`tick`, state DIGGING, ordinal 5 of IDLING, FEELING_HAPPY, SCENTING, SNIFFING, SEARCHING, DIGGING, RISING) | every tick in the DIGGING state (`emitDiggingParticles` with the digging animation state), when that animation's time is above 1700 ms and below 6000 ms and the block under the head block has a render shape other than invisible; then `dropSeed` | block (the state of the block below the head block) | 30 per tick | centre of the head block + (0, -0.65, 0) (float 0.65) | 0 | on ticks where `tickCount % 10 == 0` inside the window: that block's hit sound at volume 0.5, pitch 0.5; independently `tickCount % 10 == 0` also sends a game event. In state SEARCHING the tick plays the searching sound only |
| 6.38 | `Breeze` (`tick`, client copy; pose switch) | pose SLIDING: `emitGroundParticles(20)`. Poses SHOOTING, INHALING, STANDING: reset the jump trail counter, then `emitGroundParticles(1 + nextInt(1))` (always 1; `nextInt(1)` is 0). Pose LONG_JUMPING: `emitJumpTrailParticles` (a counter incremented per call; nothing once it exceeds 5, so 5 calls) | block, state = the in-block state, or the state of the block under when the in-block state is air | ground: n as above; jump trail: 3 per call | ground: x and z of the bounding box centre, y = entity position y; skipped when the entity is a passenger or the state's render shape is invisible. Jump trail: entity position + delta movement + (0, 0.1, 0) (float 0.1) | 0 | no random draws except the `nextInt(1)` |
| 6.39 | AbstractNautilus `spawnBubbles` | moving | bubble | 1 when one `nextFloat` < p, p = clamp(2 * speed, 0.15, 1) with speed = length of the delta movement | view = the view vector from pitch clamped to -10..10 and the yaw; position (x - view.x * 1.1, y - view.y + 0.25, z - view.z * 1.1) (the y term is not multiplied by 1.1) | m = `nextDouble` * 0.8 * (1 + speed), then per axis (`nextFloat` - 0.5) * m (x, y, z in that order) | draws: the test float, the `nextDouble`, three floats |
| 6.40 | Camel / Horse / Llama `handleEating` | feeding a baby or food | happy_villager | 1 | (getRandomX(1), getRandomY() + 0.5, getRandomZ(1)) | 0 | |
| 6.41 | Tadpole feed | feed | happy_villager | 1 | same | 0 | |
| 6.42 | `Mob.spawnAnim` and entity event 20 | on a client level `spawnAnim` calls `makePoofParticles` directly; on a server level it broadcasts entity event 20, which a `Mob` client handles by calling `spawnAnim` | poof | 20 | row `LivingEntity.makePoofParticles` of section 4 | gaussian * 0.02 per axis | |
| 6.43 | OminousItemSpawner (`tickClient`, `addParticles`) | when the level game time is a multiple of 5 (client) | ominous_spawning | `nextIntBetweenInclusive(1, 3)` (1 to 3), drawn once before the loop | position = the entity position (the origin) | velocity = P - origin, where P = origin + 0.4 * (g1 - g2) per axis, with six `nextGaussian` per particle (x pair, y pair, z pair) | the velocity therefore equals 0.4 * (g1 - g2) per axis |
| 6.44 | `animal.wolf.Wolf.tick` (shake; the shake counter advances by 0.05 per tick and the shake ends when the previous value reaches 2) | wet, shaking, shake counter > 0.4 | splash | n = (int) (sin((shake - 0.4) * pi) * 7) in FLOAT arithmetic (pi = 3.1415927, 0.4 and 7 float constants, `Mth.sin` of the widened value), truncated toward zero; nothing spawns once shake > 1.4 (the sine goes below 0); n peaks at 7 near shake = 0.9 | per particle: x offset = (2 r1 - 1) * width * 0.5 and z offset = (2 r2 - 1) * width * 0.5 (floats, r1 then r2 `nextFloat`), position (x + x offset, (float) y + 0.8, z + z offset) | the entity delta movement (all three axes) | the shake sound plays when the counter is 0 on the first tick; event 56 (server, when the wolf is in water or rain while shaking) cancels; the start event (8) was not re-read |
| 6.45 | TrackingEmitter | animate action 1, 2 and entity event 35 | crit, enchanted_hit, totem_of_undying (lifetime 30) | 42-1 §5.7 | | | the client handles animate actions: 1 crit, 2 magic crit |
| 6.46 | Spawner (`BaseSpawner.clientTick`) | a player is near (`isNearPlayer`) AND the display entity is not null (read) | smoke then flame at the same point | 1 each per tick | block position + `nextDouble` per axis (three draws x, y, z, shared by both particles) | 0 | |
| 6.47 | `Allay` (`spawnHeartParticle`, entity event 18) | the server sends event 18 when a dancing allay is duplicated with an item of the `duplicates_allays` tag; an `Allay` client handles event 18 by calling the heart routine 3 times (other animals: 7 hearts, section 7 row 18) | heart | 3 | (getRandomX(1), getRandomY() + 0.5, getRandomZ(1)) | gaussian * 0.02 per axis | per particle the three gaussians (x, y, z) are drawn first, then the position draws x, y, z |
| 6.48 | `Bee` (`tick`, client copy) | each tick when the bee has nectar and its crops-grown-since-pollination counter is below 10, and `nextFloat() < 0.05` | falling_nectar | loop `i < nextInt(2) + 1`: the bound is re-drawn at every iteration test (as in the witch row); the test at i = 0 always passes and the test at i = 1 passes when the new draw is 1, so the count is 1 or 2 with equal probability | x = lerp(nextDouble, entity x - 0.3, entity x + 0.3) (float 0.3), z = lerp(nextDouble, z - 0.3, z + 0.3), y = `getY(0.5)` | 0 | draws per particle: x lerp then z lerp (the position draws come after each loop-bound draw) |
| 6.49 | `AbstractBoat.onAboveBubbleColumn` (called by `BubbleColumnBlock` for an entity above a column, read; the boolean is the column direction) | the boat is not under water and `nextInt(100) == 0` (the same method also sets server-side bubble state on a `ServerLevel`) | splash | 1, with a local swim-splash sound (volume 1, pitch 0.8 + 0.4 * nextFloat, played before the particle) and a `splash` game event | (x + nextFloat, y + 0.7, z + nextFloat) with the boat position | 0 | draws: `nextInt(100)`, the sound pitch float, the x float, the z float |
| 6.50 | `BrushItem.spawnDustParticles` (via `onUseTick`) | while the brush is used on a block hit, on ticks where (use duration - remaining use ticks + 1) % 10 == 5, the block state `shouldSpawnTerrainParticles` and its render shape is not invisible; the hand used decides the arm (main hand: the player's main arm, off hand: the opposite arm) | block (the brushed state) | `nextInt(7, 12)` (exclusive upper, so 7 to 11), drawn once before the particles | the hit location, with x reduced by 0.000001 when the hit face is WEST and z reduced by 0.000001 when it is NORTH; y unchanged | (dx * sgn * 3 * nextDouble, 0, dz * sgn * 3 * nextDouble) with sgn = +1 for the RIGHT arm and -1 for the LEFT and (dx, dz) the `DustParticlesDelta` of the hit face, below | draws per particle: x velocity then z velocity |

Verification status of section 6: the rows for `Arrow` (6.1), `Ravager` (6.35), `Warden` (6.36), `Sniffer` (6.37), `Breeze` (6.38), `Allay` (6.47), `Bee` (6.48), `AbstractBoat` (6.49), `BrushItem` (6.50), `ThrownEnderpearl` (6.7) and the fishing hook (6.51) were read in the second pass. In the fourth pass the emitting methods of rows 6.1b, 6.1c, 6.3 to 6.6, 6.8 to 6.19b, 6.21 to 6.30 (including the three dragon phase sub-rows), 6.32 to 6.34, 6.39 to 6.44 and 6.46 were re-read, with partial reads of 6.2 (the `clientTick` skip, the 2 versus `ceil(pi r^2)` count, the 50% default swap and the velocity constants were seen; the waiting radius value and the angle and distance draw order were not individually confirmed) and 6.23 (the moving-in-water pair and the beam loop `t += (1.8 - a) + r (1.7 - a)` were seen). The rows matched except for the corrections made in this pass (6.16 f drawn once per tick, 6.34 count rule, 6.39 formula, 6.43 position and velocity, 6.44 float arithmetic, 6.46 display-entity condition, and the `MushroomCow` speeds in section 1.4). Row 6.20 is 6.51. Still NOT re-read: row 6.45 (`TrackingEmitter`; its numbers are 42-1 section 5.7's), the triggers of 6.40 and 6.41 (Open question 6), and the start event of 6.44. The entity particle classes that those rows spawn are specified in 42-2 and 42-3.

`BrushItem$DustParticlesDelta.fromDirection(view, face)` (view = the user's view vector at partial tick 0): DOWN and UP (dx, dy, dz) = (view.z, 0, -view.x); NORTH (1, 0, -0.1); SOUTH (-1, 0, 0.1); WEST (-0.1, 0, -1); EAST (0.1, 0, 1). The y component is not used for the velocity (the velocity y is 0).

### 6.51 Fishing hook (server, `catchingFish`, detail of row 6.20)
Let w = bobber width.
1. A speed factor f = 1; with probability 0.25 and rain at the block above, f += 1; with probability 0.5 and no sky view above, f -= 1.
2. If `nibble` > 0: decrement; at 0 reset lure state and clear the biting flag.
3. Else if `timeUntilHooked` > 0: reduce by f; while still > 0: fishAngle += triangle(0, 9.188) degrees; (sx, sz) = sine and cosine of that angle; point = (x + sx * timeUntilHooked * 0.1, floor(y) + 1, z + sz * timeUntilHooked * 0.1); if the block below the point is water: with probability 0.15 one `bubble` at y - 0.1 (count 1, spread (sx, 0.1, sz), speed 0); then two `fishing` packets with count 0 at the point, direction (sz * 0.04, 0.01, -sx * 0.04) and (-sz * 0.04, 0.01, sx * 0.04), speed 1. When it reaches 0: splash sound, one `bubble` and one `fishing` packet each with count (int)(1 + w * 20), spread (w, 0, w) at y + 0.5, speed 0.2; nibble = 20..40; biting flag true.
4. Else if `timeUntilLured` > 0: reduce by f; probability p = 0.15 plus 0.05 * (20 - t) below 20, else 0.02 * (40 - t) below 40, else 0.01 * (60 - t) below 60; with probability p a `splash` packet (count 2 + nextInt(2), spread (0.1, 0, 0.1), speed 0) at a point 25 to 60 units (/10) from the bobber at a random angle if the block below is water; when it reaches 0 set `fishAngle` random 0..360 and `timeUntilHooked` 20..80.
5. Else set `timeUntilLured` = 100..600 minus the lure speed.

### 6.52 Enchantment `spawn_particles` effect (`SpawnParticlesEffect`)
Data fields: `particle`, `horizontal_position`, `vertical_position` (each: type `entity_position` or `in_bounding_box`, `offset`, `scale`), `horizontal_velocity`, `vertical_velocity` (each: `movement_scale`, `base` float provider), `speed` (float provider, default 0). Per application: x = coordinate(h; entity x, entity x), y = coordinate(v; entity y, entity y + height/2), z = coordinate(h) where entity_position returns the first value and in_bounding_box returns second + (nextDouble - 0.5) * (size * scale); the offset is then added; velocity component = known movement * movement_scale + base sample; speed = one sample. Draw order: x, y, z coordinates, then x, y, z velocities, then speed. Emitted with one `sendParticles` call, count 0 (velocity mode), so the client velocity is velocity * speed.

## 7. Entity events that spawn particles

Packet: Entity Event (05a), event id byte; the client routes id 21 (guardian beam sound), 35 (totem) and 63 (sniffer sound) in the packet handler, every other id to the entity's `handleEntityEvent`.

| Id | Entities | Result |
|---|---|---|
| 0 | arrow | 20 `entity_effect` of the arrow colour (6.1) |
| 3 | thrown snowball, egg; living entity (death handling) | snowball 8 particles, egg 8 particles; for a living entity the death sound and, for non-players, health 0 and die |
| 6 / 7 | tamable animals, horses | taming smoke (6) / hearts (7), 7 particles |
| 8 / 56 | wolf | start / cancel the shake |
| 12, 13, 14, 42 | villagers | heart, angry_villager, happy_villager, splash (5 particles each, section 4 row) |
| 15 | witch | witch particles (6.14) |
| 18 | animals | heart x 7 at (getRandomX(1), getRandomY() + 0.5, getRandomZ(1)), gaussian * 0.02 velocity |
| 20 | mobs | spawn poof (4) |
| 35 | any (packet handler) | totem tracking emitter lifetime 30 plus sound; local player shows the item |
| 38 | dolphin | happy_villager x 7 |
| 40 / 41 | ocelot | trusting smoke / hearts |
| 45 | fox | eating item particles x 8 |
| 46 | living | portal x 128 (4) |
| 47, 48, 49, 50, 51, 52, 65, 68 | living | break item of main hand, off hand, head, chest, legs, feet, body, saddle: item particles x 5 and a break sound if the item has one |
| 54 | living | honey jump particles (block class method, 42-6 section 3) |
| 55 | living | hand swap, no particle |
| 60 | living | death poof x 20 (4) |
| 67 | living | drown bubbles x 8 (4) |

## 8. Level events (Level Event packet, 05a; `LevelEventHandler.levelEvent`)

Data is the event's int. Positions are block positions; `r` is the client level random. Sound-only events are omitted. "block break effect" means `addDestroyBlockEffect` (8.2).

| Id | Meaning (inferred from sound and effect) | Particles |
|---|---|---|
| 1500 | composter fill | `ComposterBlock.handleFill(level, pos, data > 0)` (42-6 section 6) |
| 1501 | lava extinguished | 8 `large_smoke` at (x + r, y + 1.2, z + r') (two draws per particle), velocity 0 |
| 1502 | redstone torch burnout | 5 `smoke` at (x + 0.6 r + 0.2, y + 0.6 r + 0.2, z + 0.6 r + 0.2), velocity 0 |
| 1503 | end portal frame filled | 16 `smoke` at (x + (5 + 6 r)/16, y + 0.8125, z + (5 + 6 r')/16) |
| 1504 | pointed dripstone drip | `PointedDripstoneBlock.spawnDripParticle` (42-6 section 3.5) |
| 1505 | bone meal | `BoneMealItem.addGrowthParticles(level, pos, data)` (8.3) |
| 2000 | dispenser shoot (smoke) | `shootParticles(data as direction index, smoke)` (8.1) |
| 2010 | dispenser shoot (white smoke) | `shootParticles(data, white_smoke)` |
| 2001 | block break | sound of the block state `data`, then block break effect |
| 2014 | block break, no sound | block break effect |
| 2019, 2020 | breaking effects on a face: direction = `Direction.values()[clamp(data, 0, 5)]`, the flag is true for 2020 | `addBreakingBlockEffects` (8.2) |
| 3008 | brush completed | brush-completed sound for brushable blocks, then block break effect |
| 2002 | splash potion | 8.4 with `effect` |
| 2007 | instant splash potion | 8.4 with `instant_effect` |
| 2003 | eye of ender breaks | 8 `item` (ender eye) at (x + 0.5, y, z + 0.5) velocity (gaussian * 0.15, nextDouble * 0.2, gaussian * 0.15); then for angle a from 0 to 2 pi in steps of 0.15707963267948966 (pi/20): two `portal` at (x + 0.5 + cos a * 5, y - 0.4, z + 0.5 + sin a * 5), velocities (-5 cos a, 0, -5 sin a) and (-7 cos a, 0, -7 sin a) |
| 2004 | mob spawner spawn | 20 times: point = block centre + (r - 0.5) * 2 per axis; `smoke` then `flame` at it, velocity 0 |
| 2006 | dragon fireball breath | 200 `dragon_breath`: p = nextFloat * 4, angle = nextFloat * 2 pi; v = (cos * p, 0.01 + nextDouble * 0.5, sin * p); position = (x + v.x * 0.1, y + 0.3, z + v.z * 0.1); the power option is p; data 1 adds a sound |
| 2008 | explosion at block | one `explosion` at the block centre |
| 2009 | sponge dried | 8 `cloud` at (x + r, y + 1.2, z + r') |
| 2011, 2012 | bee/honey and similar growth | `spawnParticleInBlock(pos, data, happy_villager)` (8.5) |
| 2013 | mace smash attack | smash particles (`spawnSmashAttackParticles`, 8.5), data = fall height count |
| 2015 | teleport (small range) | 8.6 with the offset unpacked as (16, 8, 16) |
| 2016 | teleport (medium) | unpacked (8, 8, 8) |
| 2017 | teleport (large) | unpacked (127, 127, 127) |
| 2018 | enderman-style teleport | 128 `portal` along the line from the unpacked position (radii 127, 127, 127, 8.6) to the block, with the enderman width and height: t = nextDouble; v = ((r - 0.5) * 0.2) per axis (three floats first); x = lerp(t, ox, bx) + (r - 0.5) * width * 2, y = lerp(t, oy, by) + r * height, z likewise |
| 3000 | end gateway spawn | one `explosion_emitter`, **always visible, forced** (`addAlwaysVisibleParticle(options, true, ...)`) at the block centre |
| 3002 | electric spark | if data is a valid axis index: 10 to 19 particles `electric_spark` along that axis with radius 0.125 (`spawnParticlesAlongAxis`, 8.5); else 3 to 5 per face (`spawnParticlesOnBlockFaces`, 8.5) |
| 3003, 3004, 3005 | wax on, wax off, scrape | `wax_on`, `wax_off`, `scrape`: 3 to 5 per face (`spawnParticlesOnBlockFaces`, 8.5) |
| 3006 | sculk charge | 8.7 |
| 3007 | sculk shriek | 10 `shriek` particles with delay i * 5 (i = 0..9) at (x + 0.5, y + top y of the shrieker, z + 0.5), velocity 0 |
| 3009 | turtle egg cracked | 3 to 6 `egg_crack` per face (`spawnParticlesOnBlockFaces`, 8.5) |
| 3011 | trial spawner: spawn (silent) | 9.1 `addSpawnParticles` with flame kind decoded from data |
| 3012 | trial spawner: spawn mob | sound then `addSpawnParticles` |
| 3021 | trial spawner: spawn item | sound then `addSpawnParticles` |
| 3013 | detect player | `addDetectPlayerParticles(count = data, trial_spawner_detection)` |
| 3019 | detect player, ominous | same with `trial_spawner_detection_ominous` |
| 3020 | ominous activate (data 0 selects volume 0.3, else 1) | detect particles (count 0, ominous) then become-ominous particles |
| 3014, 3017 | eject item | `addEjectItemParticles` |
| 3015 | vault activate (data 0: soul or flame choice) | vault activation particles (9.2), small_flame (data 0) or soul_fire_flame |
| 3016 | vault deactivate | vault deactivation particles |
| 3018 | cobweb placed | 10 `poof` at (x + r, y + r', z + r'') with velocity gaussian * 0.02 per axis (velocities drawn before positions) |
| 1010 | jukebox song | start playback (no particles from the client; notes come from the server, 1.4) |
| 2005 (data) | not in the switch | none |

The second `lookupswitch` of `LevelEventHandler.levelEvent` has **89** entries (read, counted), which are exactly: 1000 to 1002, 1004, 1009 to 1011, 1015 to 1022, 1024 to 1027, 1029 to 1035, 1039 to 1054, 1500 to 1505, 2000 to 2004, 2006 to 2020, 3000 to 3009, 3011 to 3021. A separate `globalLevelEvent` switch holds 3 more ids: 1023, 1028, 1038. Ids that only play sound: 1000, 1001, 1002, 1004, 1009, 1011, the 1015 to 1054 range and 3001. The ids 2005 and 3010 are in neither switch (no behaviour).

### 8.1 `shootParticles(data, pos, rand, particle)` (events 2000, 2010)
Direction d = `Direction.from3DDataValue(data)` with step (sx, sy, sz). Repeat 10 times; per particle draws in this order: s = nextDouble * 0.2 + 0.01; position components: x = pos.x + sx * 0.6 + 0.5 + sx * 0.01 + (nextDouble - 0.5) * sz * 0.5; y = pos.y + sy * 0.6 + 0.5 + sy * 0.01 + (nextDouble - 0.5) * sy * 0.5; z = pos.z + sz * 0.6 + 0.5 + sz * 0.01 + (nextDouble - 0.5) * sx * 0.5 (so the sideways jitter is in the direction of the other horizontal axis; y jitters with its own step, which is zero for horizontal dispensers: the formula uses sy for y and sz for x, sx for z, read exactly as given); velocity = step * s + gaussian * 0.01 per axis (three gaussians after the three position draws).

### 8.2 Block break effects (`ClientLevel`)
`addDestroyBlockEffect(pos, state)`: nothing if the state is air or does not spawn terrain particles. For each box of the state's shape: sizes clipped to 1; counts nx = max(2, ceil(size / 0.25)) per axis; for every cell (i, j, k) the fraction f = (i + 0.5) / nx etc.; position = block corner + box min + f * size; the `TerrainParticle` is created directly with velocity (fx - 0.5, fy - 0.5, fz - 0.5) and added to the engine (bypasses the status and distance tests). `addBreakingBlockEffects(pos, face, withSound)`: nothing for air; the breaking sound if the flag; when the render shape is not invisible and the state spawns terrain particles, `addBreakingParticles`: one `TerrainParticle` at a point inside the shape box inset 0.1 (offset (nextDouble * (size - 0.2) + 0.1 + min) per axis, then the coordinate on the hit face replaced by min - 0.1 or max + 0.1), velocity 0, then `setPower(0.2)` and `scale(0.6)`. Per-step progress breaking uses the same function.

### 8.3 Bone meal growth particles
By the block under `pos`: if it is a bonemealable block, the particle position block is the block's `getParticlePos`; neighbour-spreader type: `spawnParticles(pos, count * 3, 3.0, 1.0, false, happy_villager)`; grower type: `spawnParticleInBlock(pos, count, happy_villager)`; otherwise for water: `spawnParticles(pos, count * 3, 3, 1, false, happy_villager)`. `count` is the event data.

### 8.4 Potion splash (events 2002, 2007)
Data is the colour (RGB). Centre = bottom centre of the block. 8 `item` particles of a splash potion at the centre with velocity (gaussian * 0.15, nextDouble * 0.2, gaussian * 0.15); then 100 particles of the given type: p = nextDouble * 4, angle = nextDouble * 2 pi; velocity (cos * p, 0.01 + nextDouble * 0.5, sin * p); colour channels = (byte / 255) * (0.75 + nextFloat * 0.25) (one float draw shared by the three channels); the option's power = p; position = (cx + vx * 0.1, cy + 0.3, cz + vz * 0.1). Order of draws per particle: p, angle, vy, shade.

### 8.5 Helper `ParticleUtils` (shared; used by block classes too)
| Method | Behaviour |
|---|---|
| `spawnParticleInBlock(level, pos, count, particle)` | height h = 1 for air, else the shape's top; then `spawnParticles(pos, count, 0.5, h, true, particle)` |
| `spawnParticles(level, pos, count, xzSpread, ySpread, allowInAir, particle)` | per particle: velocity gaussian * 0.02 per axis first; then x = pos.x + (0.5 - xzSpread) + nextDouble * xzSpread * 2, y = pos.y + nextDouble * ySpread, z likewise; skipped (draws spent) when `allowInAir` is false and the block below the point is air |
| `spawnParticlesOnBlockFaces(level, pos, particle, countProvider)` | for each of the six faces, `spawnParticlesOnBlockFace` with offset 0.55 and velocity uniform in [-0.5, 0.5] per axis (a new vector per particle) |
| `spawnParticlesOnBlockFace(level, pos, particle, countProvider, face, velocitySupplier, offset)` | n = count sample; n times `spawnParticleOnFace` |
| `spawnParticleOnFace` | centre of the block; per axis: if the face step is zero the coordinate is centre + uniform [-0.5, 0.5], else centre + step * offset; the velocity component is the supplied one on step-zero axes and 0 on the face axis; draws: x, y, z coordinates in order, only for step-zero axes |
| `spawnParticlesAlongAxis(axis, level, pos, radius, particle, countProvider)` | n = sample; per particle: x, y, z = centre + uniform(-1, 1) * (0.5 on the chosen axis, radius on the others); then velocity = uniform(-1, 1) on the chosen axis only (0 elsewhere); draw order: x, y, z, then the one velocity |
| `spawnParticleBelow(level, pos, rand, particle)` | (x + r, y - 0.05, z + r') velocity 0 |
| `spawnSmashAttackParticles(level, pos, count)` | centre + (0, 0.5, 0) with the block state's `dust_pillar`; floor(count / 3) (loop while i < count / 3.0 as float) particles with x, z = centre + gaussian / 2, y = centre y, velocity gaussian * 0.2 per axis; then while i < count / 1.5: ring at radius 3.5 around the centre: (cx + 3.5 cos i + gaussian / 2, cy, cz + 3.5 sin i + gaussian / 2), velocity gaussian * 0.05 per axis (here i is the loop index used as radians) |

Per-particle counts in 3002: electric spark along axis `UniformInt(10, 19)`; per face `UniformInt(3, 5)`. 3009 egg crack per face `UniformInt(3, 6)`; 3003 to 3005 `UniformInt(3, 5)`.

### 8.6 Teleport events (2015 to 2017)
`BlockUtil.unpackDifferenceInPosition(pos, data, rx, ry, rz)` (read) fails with an illegal-argument error if any radius exceeds 127; otherwise the second block position is pos + (((data >> 16) & 255) - rx, ((data >> 8) & 255) - ry, (data & 255) - rz), i.e. three bytes of `data`, each biased by its radius. The radii used are (16, 8, 16) for 2015, (8, 8, 8) for 2016 and (127, 127, 127) for 2017 and 2018. 128 `portal` particles: t = nextDouble; velocity ((r - 0.5) * 0.2 per axis, three floats drawn first); x = lerp(t, other.x, pos.x) + (nextDouble - 0.5) + 0.5; y = lerp(t, other.y, pos.y) + nextDouble - 0.5; z likewise.

### 8.7 Sculk charge (event 3006)
Data d: charge c = d >> 6 (signed shift), face mask m = d & 63.
- If c > 0: with probability 0.3 + c * 0.1 (one `nextFloat`) a sound plays (its pitch and volume use two more floats). Then particles `sculk_charge` with roll option, count `UniformInt(0, c)` per face, velocity uniform in [-0.005, 0.005] per axis, offset 0.65 on Y-axis faces and 0.57 on the others, roll = pi for DOWN and 0 otherwise, for all six directions when m is 0; for the faces in the multiface mask otherwise with offset 0.35 and roll pi for UP, 0 otherwise.
- If c == 0 (pop): sound, then a count of 40 and radius 0.45 when the block's collision shape is a full block, else 20 and 0.25: particle `sculk_charge_pop` at the centre + (2 f - 1) * radius per axis (three floats), velocity (2 f - 1) * 0.07.

## 9. Block-entity and environment emitters

### 9.1 Trial spawner (client tick, `ominous` flag)
Per state, by `ParticleEmission`:
| State emission | Per client tick |
|---|---|
| none (inactive) | nothing |
| small flames (waiting for players, waiting for reward, ejecting) | with probability 1/2 (`nextInt(2) == 0`): one particle `small_flame` (`soul_fire_flame` when ominous) at centre + offsetRandom(0.9) |
| flames and smoke (active) | one `smoke` at centre + offsetRandom(1.0), and one `flame` (`soul_fire_flame` if ominous) at the same point |
| smoke inside and top face (cooldown) | with probability 1/3 one `smoke` at centre + offsetRandom(0.9); when the game time is a multiple of 20: 20 + nextInt(4) `smoke` at centre + (0, 0.5, 0) |
Event helper particles: `addSpawnParticles`: 20 times, point = centre + (r - 0.5) * 2 per axis; `smoke` and the flame kind (normal `flame`, ominous `soul_fire_flame`, decoded from data with out-of-range values giving normal). `addBecomeOminousParticles`: 20 times, same point rule, velocity gaussian * 0.02 per axis (positions first, then velocities): `trial_omen` and `soul_fire_flame`. `addDetectPlayerParticles(count n, particle)`: 30 + min(n, 10) * 5 particles at (x + 0.5 + (2 f - 1) * 0.65, y + 0.1 + f' * 0.8, z + 0.5 + (2 f - 1) * 0.65), velocity 0 (draw order x, z, y). `addEjectItemParticles`: 20 times at (x + 0.4 + 0.2 r, y + 0.4 + 0.2 r, z + 0.4 + 0.2 r), velocity gaussian * 0.02 per axis (x, y, z); `small_flame` with z velocity * 0.25 and `smoke` with the full velocity.

### 9.2 Vault
Client tick: every 20 game ticks, connection particles; every tick `emitIdleParticles`: with probability 0.5 one `smoke` at a random point inside the cage and, if the vault shows a display item, one flame particle (`small_flame`, or `soul_fire_flame` when ominous). Cage point: corner + (uniform 0.1..0.9, uniform 0.25..0.75, uniform 0.1..0.9). Activation (level event 3015): connection particles then 20 times a smoke and a flame at a cage point. Deactivation (3016): 20 flame particles at points corner + uniform 0.4..0.6 per axis with velocity gaussian * 0.02 per axis. Connection particles for each connected player inside the vault's range: `vault_connection`, 2 to 5 (`Mth.nextInt`), at the keyhole point (block bottom centre + (0.5 * step x, 1.75, 0.5 * step z) for the vault facing), velocity = (player position + half height - keyhole) with offsetRandom(1.0).

### 9.3 Conduit
Client tick animation: bob b = (s^2 + s) * 0.3 with s = sin((tick + 35) * 0.1) / 2 + 0.5; source (x + 0.5, y + 1.5 + b, z + 0.5). For every block of the conduit frame, with probability 1/50 (`nextInt(50) == 0`): `nautilus` at the source with velocity (frame offset x - 0.5 + nextFloat, offset y - 2 + nextFloat, offset z - 0.5 + nextFloat). If the destroy target exists: `nautilus` at its eye point with velocity ((nextFloat - 0.5) * (3 + width), -1 + nextFloat * height, (nextFloat - 0.5) * (3 + width)).

### 9.4 Bell, campfire, sulfur, catalyst
- Bell ringing near raiders within 48 blocks (client): per raider within range, n = clamp((count - 21) / -2, 3, 15) particles `entity_effect` at 0.5 above the block centre displaced one block toward the raider (horizontal), colour starting at 16700985 and incremented by 5 per particle for the whole bell (the first particle uses start + 5).
- Campfire block entity: each tick with probability 0.11, 2 + nextInt(2) cosy or signal smoke via the block helper; for each non-empty item slot with probability 0.2: 4 `smoke` at the slot's position (block centre offset 0.3125 toward the slot's direction and clockwise) with velocity (0, 0.0005, 0).
- Potent sulfur: `spawnGeyserParticle` emits `geyser` with `water_blocks` = (source y - block y - 1) at (x + 0.5, source y, z + 0.5), when the (game time - eruption tick) is a multiple of 20; the noxious gas spawner emits `noxious_gas` always visible.
- Sculk catalyst: the `sculk_soul` emission is a server `sendParticles` call, recorded in section 1.4 (row `SculkCatalyst` listener); nothing is emitted client-side.

### 9.5 Rain and the animate-tick driver (pointer only)

Ownership: this document does not carry a second copy of these rules, to avoid drift. The authoritative texts are:
- **Rain** (`ClientLevel.tickWeatherEffects`: weather radius option, count formula, column pick, height window, MINIMAL stop, `rain` versus `smoke`, position): 42-3 section 9.1. Worked value: radius 10, rain level 1 gives floor(0.225 * 441) = 99 repetitions (ALL), 49 with DECREASED.
- **The animate-tick driver** (`ClientLevel.animateTick` and `doAnimateTick`: 667 samples at each of radius 16 and 32, the triangular offset, the three random sources): 42-6 section 1.2, with the fluid drip placement in 42-6 sections 1.5 and 1.6 and in 42-3 section 4.4, the `ambient_particles` entry in 42-6 section 1.3 and the marker target in 42-6 section 1.4.
- Per sampled point the order, re-read in `ClientLevel.doAnimateTick` this round, is: (1) the block's `animateTick`; (2) when the cell has a fluid, the fluid's `animateTick`; (3) the fluid drip step (draw `nextInt(10)`, on 0 call `trySpawnDripParticles` with the fluid's drip particle and the face-sturdy flag; see 42-6 section 1.2 step 3); (4) the marker step, only when a marker target is set and the sampled block equals it (one `block_marker` at the cell centre, velocity 0); (5) the ambient step, which is NOT part of the marker branch: it runs for every sampled point whose state is not a full-collision block, whether or not a marker is active. For each `AmbientParticle` entry of the attribute `visual/ambient_particles` it draws one `nextFloat` (true when <= probability) and on success spawns the particle at the point + (`nextDouble`, `nextDouble`, `nextDouble`) with velocity 0.
- Block-class `animateTick` overrides: 42-6 sections 3 to 5. Fluid emitters: 42-3.

The server-side routing of these particles does not exist: all of the above is client-only (see the note under the helper table).

### 9.6 Creaking heart
Server tick: while the emitter counter > 0: when it is above 50, one packet pair per tick (a `trail` towards the heart and one from the heart); each `trail` goes from a random point in the creaking's box to a random point in the heart block (or the reverse for the other flag), colour 16545810 for the flag true and 6250335 otherwise, duration 10 + nextInt(40); all packets use override limiter and always show true, count 1. On a hurt event 20 trails of the second kind.

### 9.7 Fireworks (`ClientLevel.createFireworks`)
With an empty explosion list the entry spawns `poof` puffs; the count is not a fixed 2 + nextInt(3): the loop bound `nextInt(3) + 2` is re-drawn on every loop test (confirmed again in the `createFireworks` bytecode this round, which corrects an earlier statement in this document); position, velocity (gaussian * 0.05, 0.005, gaussian * 0.05) and draw order are in 42-2 section 3.13 (entry paragraph), which owns them. Otherwise a `FireworkParticles$Starter` is added to the engine; its behaviour is specified in 42-2 section 3.13 (starter construction and tick).

## 10. Game events and vibrations

The `vibration` particle is emitted by the server when a vibration is scheduled (`trySelectAndScheduleVibration` callback): one packet, count 1, spread 0, at the vibration origin, option = (the listener's position source, travel time in ticks), then each tick while a vibration is travelling `tryReloadVibrationParticle` re-sends the particle at the interpolated position (origin to destination by 1 - remaining / total) with the remaining ticks, only when the "reload" flag was set (after a chunk or entity reload); once at least one player received it the flag is cleared. The client uses the particle's position source to move. The Game Event packet's elder-guardian effect (event) spawns `elder_guardian` at the local player (forced to the engine through `addParticle`) and plays a curse sound when the parameter rounds to 1.

## 11. Worked examples

1. Packet count 0: a fishing bite near a hook uses a `fishing` packet with distances (0.04 * sz, 0.01, -0.04 * sx) = (0.04, 0.01, 0) for sx = 0, sz = 1, speed 1: velocity (0.04, 0.01, 0).
2. Wolf shake (`animal.wolf.Wolf.tick`, row 6.44), float arithmetic: the counter advances in steps of 0.05, so it takes values near 0.45, 0.5, ... (accumulated in float, near but not exactly these decimals). For shake near 0.9 the sine argument is about 0.5 pi and n = (int) (about 7.0) = 7 splash particles per tick (a sine that came out as 0.99999994 would truncate to 6, so do not rely on the exact tick). For shake 0.65: sin(0.25 pi) = 0.7071, 7 * 0.7071 = 4.95, n = 4. For shake 1.5: sin(1.1 pi) < 0, so no particles. Formula read in the bytecode in the fourth pass.
3. Water entry of a width 0.6 sprinting entity: 13 bubbles and 13 splashes.
4. Explosion: radius 4, TNT interaction, 200 blocks. Large (`explosion_emitter`) because radius >= 2 and the interaction is not keep. Tracker: W = 200, N = 200, each particle at P = C + dir * cbrt(r) * 4; if a point is at d = 2, s = 0.5 / (0.5 + 0.1) * r * r' + 0.3 = 0.833 r r' + 0.3.
5. `particle minecraft:dust{color:16711680,scale:2}` parses (dust fields) and fails with `particle.invalidOptions` for `scale:10` (above 4).
6. Totem: tracking emitter life 30: the constructor and 29 ticks give 30 batches of up to 16 particles each.

## 12. Validation

| Check | Expected |
|---|---|
| Server radius | 32 blocks without the first flag, 512 with it |
| Count 0 | velocity = max speed * distance per axis, no draws |
| ALTERNATIVE offsets | uniform in [0, dist), never negative |
| Explosion small selection | radius < 2 or keep interaction |
| Tracker cap | 512 per tick, cleared every tick, nothing when the setting is not ALL |
| Default block particles | poof (0.5, 1) weight 1, smoke (1, 1) weight 1 |
| Ambient effect alpha | 38 |
| Water entry particles | width 0.6: 13 bubbles then 13 splashes; sound volume uses 0.2 or 0.9, particles do not |
| Brush dust | 7 to 11 particles, every 10th use tick starting at 5 |
| Effect particle chance | 1 in 4 when visible, 1 in 15 when invisible, denominator times 5 when all ambient |
| Level event table | the 89 ids of the second switch of `LevelEventHandler.levelEvent` (plus 1023, 1028, 1038 in `globalLevelEvent`); those with particles are 1500 to 1505, 2000 to 2004, 2006 to 2020 (no 2005), 3000 to 3009 (3001 is sound only), 3011 to 3021 (no 3010) (subsets as the table) |
| Rain count | radius 10 (the default option value, read; range 3 to 10), rain 1: floor(0.225 * 441) = 99 |

## 13. Open questions

1. Level event ids are named from behaviour (sounds and effects), not from constant names; the constant names of `LevelEvent` were not read.
2. The entity classes that never call a particle method (parrot, snow golem, iron golem, axolotl, armadillo, turtle, vex, camel dash, ghast, evoker body) were checked only by the absence of `addParticle`, `sendParticles` and `ParticleTypes` references in their classes, not by reading them. (The bee body is not in this list: `Bee` has a particle emission, row 6.48; the earlier statement that it had none was wrong. `AbstractBoat` and `BrushItem` were also found only after the first draft, rows 6.49 and 6.50, so the list of emitting classes in the Method line was incomplete in the draft; a fresh full scan was not repeated.)
3. `ParticleLimit` effects on emitted counts (42-1 §5.4) were not combined with the emitters.
4. `ServerLevel.explode` block-interaction mapping for the trigger case and the explosion engine itself are not in this document.
5. The randomisation of ordinary `RandomSource` implementations is not read (as 42-1 Open question 6).
6. The triggers of rows 6.40 (horse, camel, llama `handleEating`) and 6.41 (Tadpole feed) were not traced to their call sites; the particle code is read, the trigger frequency is not.
7. 16 section 7.8 still says "a vec3 with minimum 0 flag" for the `/particle` `delta` argument; the jar has a `centerCorrect` flag only (section 2). That document's owner should replace the sentence with a cross-reference to 42-7 section 2 (this review pass does not edit it).
8. After the fourth pass the rows still not re-read are those named in the verification notes below section 1.4 and below section 6 (`Entity.sendBubbleColumnParticles`, the water-bottle dispenser and `PotionItem` row, the `JukeboxSongPlayer` cadence, the `SculkCatalyst` listener, the `MushroomCow` branch conditions, `TrackingEmitter`, and the Wolf start event). A fresh read of those classes is still needed. Searched this pass: a compact constant and call listing of every other class named in sections 1.4 and 6.
9. Ownership of the rain, marker, ambient and drip emitters is split across 42-1 section 7, 42-3 sections 4.4 and 9.1, 42-4, 42-6 section 1 and this document. This document now points to 42-3 section 9.1 (rain) and 42-6 section 1 (animate-tick driver). 42-6 line 8 still says weather belongs to 42-7; its owner should change that to a pointer to 42-3 section 9.1.
10. `GustSeedParticle`'s tick behaviour is now read (section 3.4); the scale, lifetime and tick-delay values passed by the two providers belong to 42-5 and were not read here.
11. The width of a size-1 slime, magma cube and sulfur cube (used for the count in row 6.34) was not read; only the formula is read.
