# 42. Particles, part 4: block, item, dust and ambient particles

| | |
|---|---|
| Covers | The behaviour of 33 particle types and the classes that build them: terrain particles (`block`, `block_crumble`, `dust_pillar`), the block marker, falling dust, the dust family (`dust`, `dust_color_transition`), item break particles (`item`, `item_slime`, `item_cobweb`, `item_snowball`, `sulfur_cube_goo`), the falling-leaf family (`cherry_leaves`, `pale_oak_leaves`, three poplar types, `tinted_leaves`), ash and white ash, the suspended particles (`mycelium`, `egg_crack`, `crimson_spore`, `warped_spore`, `spore_blossom_air`), `snowflake`, `firefly`, and the glow family (`glow`, `wax_on`, `wax_off`, `electric_spark`, `scrape`). Also the emission paths that live in `ClientLevel` and `ParticleUtils` and feed these classes: block-break and hit-crack spawning, marker spawning, the ambient-particle environment attribute, falling-dust and leaf emission. `infested` (registry id 40) only names its provider here. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `net.minecraft.client.particle.{TerrainParticle, BlockMarker, FallingDustParticle, DustParticleBase, DustParticle, DustColorTransitionParticle, BreakingItemParticle, FallingParticle, FallingLeavesParticle, AshParticle, WhiteAshParticle, BaseAshSmokeParticle, SuspendedTownParticle, SuspendedParticle, SnowflakeParticle, FireflyParticle, GlowParticle, SingleQuadParticle, Particle}` with every nested provider, `net.minecraft.core.particles.{ParticleTypes, BlockParticleOption, DustParticleOptions, DustColorTransitionOptions, ScalableParticleOptionsBase, ColorParticleOption, ItemParticleOption}`, `net.minecraft.util.{ParticleUtils, LightCoordsUtil}`, `net.minecraft.client.multiplayer.ClientLevel` (animate tick, destroy and hit effects), `net.minecraft.client.renderer.LevelEventHandler` (the wax, scrape, spark and egg-crack events, including its case labels), `net.minecraft.client.renderer.item.ItemStackRenderState`, `net.minecraft.client.resources.sounds.SimpleSoundInstance`, the four nether biome data files (`data/minecraft/worldgen/biome/`), `net.minecraft.world.level.block.{BrushableBlock, FallingBlock, ColoredFallingBlock, ConcretePowderBlock, AnvilBlock, DragonEggBlock, FallingParticlesLeavesBlock, TintedParticleLeavesBlock, Blocks}`, `net.minecraft.world.attribute.AmbientParticle`, `net.minecraft.data.worldgen.biome.NetherBiomes`, `net.minecraft.client.color.block.{BlockTintSource, BlockTintSources$4, $9}`, `net.minecraft.client.Minecraft` (the call of the animate tick). |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001, design README Parts 0, 1, 4; GAP-15, round RS24). Particle definition files (the sprite lists of each type) are data that the extraction tool copies (22 section on the extraction tool, 42-1 §9); this part specifies the engines that use them and every code-defined number. Sprite counts are not repeated: 42-1 §2 has them. Per-leaf-block emission numbers (chance per animate tick) are code constants of `Blocks` and are given in §8.4 because the particle behaviour cannot be tested without them. Emitters that belong to the block-emitter and other-emitter parts (42-6, 42-7) are only cross-referenced (§15). **Ownership:** 42-1 §2 assigns this part 27 types (including both campfire smoke types, covered by 42-2 §3.17, and excluding the glow family); this document's 33 count differs because it also specifies `egg_crack`, `glow`, `wax_on`, `wax_off`, `electric_spark` and `scrape` (assigned to part 2, where 42-2 §3.23 gives the same material) and `sulfur_cube_goo` (assigned to part 5, whose 42-5 §2.20 delegates to §7.4 here), and names `infested` as a pointer only. It omits the campfire types (42-2 §3.17). Where 42-2 §3.23 and §13 here overlap they are the same numbers; on any disagreement, 42-2 §3.23 wins for the glow family and this part wins for `sulfur_cube_goo`. The counts of 42-1 §2 (27) and here (33) should be reconciled in 42-1 (Open question 11). |
| Cross-references | 05a (Level Particles, packet 0x30, the wire form of every particle sent by the server; option payloads are in 42-1 §3), 42-1 (shared model: `Particle`, `SingleQuadParticle`, movement, engine, entry paths, options, `FallingParticle` and `BaseAshSmokeParticle` physics), 42-2 (effects: the provider of `infested`), 43 (tint sources and the terrain-particle colour), 12 (client rendering), 06 (chunk format, block state ids), 42-6 (block emitters), 42-7 (entity emitters, level-event table, `/particle`). Section references written `42-N §M`; a bare `§M` is this part. The sprite lists are data of the particle definition files (42-1 §6, 22). |

## 1. Conventions used in this part

All conventions of 42-1 §1 hold (no particle uses a seeded generator, so tests inject draws; each class lists its draw order; floats are f32, velocities and positions are doubles). Three base behaviours are used by nearly every class below; they are defined in 42-1 and only named here:

- **`Particle` with a velocity bias** (42-1 §4.1): lifetime draw `lifetime0 = (int)(4 / (r*0.9 + 0.1))`; three draws a, b, c giving `v + (u*2-1)*0.4` per axis; two draws d, e giving speed `s = (d+e+1)*0.15`; the vector is normalised to length `s*0.4000000059604645` and `yd` gets `+0.10000000149011612`. Call this **the normalised burst**; it has 6 draws and is applied by every constructor that passes a velocity (even zeros) to the base. A constructor that passes no velocity (the position-only `Particle` or `SingleQuadParticle` constructors) has no burst and zero velocity.
- **`SingleQuadParticle` construction** (42-1 §4.3): `quadSize = 0.1 * (r*0.5 + 0.5) * 2` (0.1 to 0.2), colours and alpha 1.0, one draw r; the rendered side of the quad is twice `quadSize`.
- **Tick** (42-1 §4.2): `age` compared before incrementing; `yd -= 0.04 * gravity`; move; speed-up; multiply by `friction`; ground damping 0.699999988079071 on x and z.

In this part "tick" without qualification means that base tick. A class that replaces the tick says so.

## 2. The 33 types of this part

Ids, option classes and the override flag come from `ParticleTypes` (registration order = id; they agree with 42-1 §2). "Layer" is the `SingleQuadParticle$Layer` (42-1 §4.3); `bySprite` means chosen from the sprite's atlas and transparency.

| Id | Name | Options | Override | Provider (artifact class) | Particle class | Layer | Section |
|---|---|---|---|---|---|---|---|
| 1 | `block` | block state | no | `TerrainParticle$Provider` | `TerrainParticle` | bySprite | 3 |
| 2 | `block_marker` | block state | yes | `BlockMarker$Provider` | `BlockMarker` | bySprite | 4 |
| 21 | `dust` | dust | no | `DustParticle$Provider` | `DustParticle` | OPAQUE | 6 |
| 22 | `dust_color_transition` | dust transition | no | `DustColorTransitionParticle$Provider` | `DustColorTransitionParticle` | OPAQUE | 6 |
| 36 | `falling_dust` | block state | no | `FallingDustParticle$Provider` | `FallingDustParticle` | OPAQUE | 5 |
| 40 | `infested` | none | no | `SpellParticle$Provider` | `SpellParticle` (42-2) | see 42-2 | - |
| 41 | `cherry_leaves` | none | no | `FallingLeavesParticle$CherryProvider` | `FallingLeavesParticle` (= `FallingParticle`) | OPAQUE | 8 |
| 42 | `pale_oak_leaves` | none | no | `FallingLeavesParticle$PaleOakProvider` | same | OPAQUE | 8 |
| 43 | `red_poplar_leaves` | none | no | `FallingLeavesParticle$PoplarProvider` | same | OPAQUE | 8 |
| 44 | `orange_poplar_leaves` | none | no | `FallingLeavesParticle$PoplarProvider` | same | OPAQUE | 8 |
| 45 | `yellow_poplar_leaves` | none | no | `FallingLeavesParticle$PoplarProvider` | same | OPAQUE | 8 |
| 46 | `tinted_leaves` | colour (ARGB int) | no | `FallingLeavesParticle$TintedLeavesProvider` | same | OPAQUE | 8 |
| 57 | `item` | item stack template | no | `BreakingItemParticle$Provider` | `BreakingItemParticle` | bySprite | 7 |
| 62 | `item_slime` | none | no | `BreakingItemParticle$SlimeProvider` | same | bySprite | 7 |
| 63 | `item_cobweb` | none | no | `BreakingItemParticle$CobwebProvider` | same | bySprite | 7 |
| 64 | `item_snowball` | none | no | `BreakingItemParticle$SnowballProvider` | same | bySprite | 7 |
| 127 | `sulfur_cube_goo` | none | no | `BreakingItemParticle$SulfurCubeProvider` | same | bySprite | 7 |
| 67 | `mycelium` | none | no | `SuspendedTownParticle$Provider` | `SuspendedTownParticle` | OPAQUE | 10.1 |
| 116 | `egg_crack` | none | no | `SuspendedTownParticle$EggCrackProvider` | same | OPAQUE | 10.1 |
| 94 | `ash` | none | no | `AshParticle$Provider` | `AshParticle` (`BaseAshSmokeParticle`) | OPAQUE | 9 |
| 102 | `white_ash` | none | no | `WhiteAshParticle$Provider` | `WhiteAshParticle` (`BaseAshSmokeParticle`) | OPAQUE | 9 |
| 95 | `crimson_spore` | none | no | `SuspendedParticle$CrimsonSporeProvider` | `SuspendedParticle` | OPAQUE | 10.2 |
| 96 | `warped_spore` | none | no | `SuspendedParticle$WarpedSporeProvider` | same | OPAQUE | 10.2 |
| 97 | `spore_blossom_air` | none | no | `SuspendedParticle$SporeBlossomAirProvider` | anonymous subclass of `SuspendedParticle` | OPAQUE | 10.2 |
| 104 | `snowflake` | none | no | `SnowflakeParticle$Provider` | `SnowflakeParticle` | OPAQUE | 11 |
| 126 | `firefly` | none | no | `FireflyParticle$FireflyProvider` | `FireflyParticle` | TRANSLUCENT | 12 |
| 110 | `glow` | none | yes | `GlowParticle$GlowSquidProvider` | `GlowParticle` | OPAQUE | 13 |
| 111 | `wax_on` | none | yes | `GlowParticle$WaxOnProvider` | same | OPAQUE | 13 |
| 112 | `wax_off` | none | yes | `GlowParticle$WaxOffProvider` | same | OPAQUE | 13 |
| 113 | `electric_spark` | none | yes | `GlowParticle$ElectricSparkProvider` | same | OPAQUE | 13 |
| 114 | `scrape` | none | yes | `GlowParticle$ScrapeProvider` | same | OPAQUE | 13 |
| 121 | `dust_pillar` | block state | no | `TerrainParticle$DustPillarProvider` | `TerrainParticle` | bySprite | 3.5 |
| 125 | `block_crumble` | block state | no | `TerrainParticle$CrumblingProvider` | `TerrainParticle` | bySprite | 3.4 |

Notes: the "plain" providers (`block`, `block_marker`, `item*`, `dust_pillar`, `block_crumble`) take no particle sprite set, because their sprite comes from a block model or an item model (§3.1, §7.2); every other row takes a sprite set from its particle definition (42-1 §6). `sulfur_cube_goo` is the only item-family type with a sprite set: it uses the first sprite of its set (§7.4). The wire form of every option class is in 42-1 §3 and of the packet that carries it in 05a (Level Particles) (block state: VarInt state id; dust: Int colour and Float scale; transition: two Ints and a Float; colour: Int ARGB; item: item stack template); the scale of a dust option is clamped to [0.01, 4.0] on construction (`ScalableParticleOptionsBase`).

## 3. Terrain particles (`TerrainParticle`)

### 3.1 Construction

Input: level, position (x, y, z), a velocity bias (vx, vy, vz), a block state and, optionally, a block position (default `BlockPos.containing(x, y, z)`, i.e. the floor of the coordinates).

1. Base: `SingleQuadParticle` constructor with a velocity (so the normalised burst of §1 and the quad size draw; 7 draws: lifetime, a, b, c, d, e, quad size). The sprite is the **particle material of the block state's model** (`BlockStateModelSet.getParticleMaterial(state).sprite()`): the sprite the block model names as its particle texture (a data lookup of the block model, 14).
2. `gravity = 1.0`; `rCol = gCol = bCol = 0.6`.
3. Tint: the block state's tint source of index 0 (`BlockColors.getTintSource(state, 0)`, 43). When one exists, take `c = colorAsTerrainParticle(state, level, pos)` and multiply each channel: `rCol *= ((c >> 16) & 255) / 255`, `gCol *= ((c >> 8) & 255) / 255`, `bCol *= (c & 255) / 255`. 43 §2.4 lists the sources: the default is the in-world colour, except grass blocks (source 4 of `BlockTintSources`: terrain colour -1, i.e. white, so the particle stays 0.6 grey) and water (`BlockTintSources$9`: the average biome water colour at the block, for the in-world/terrain case only). With no tint source the colours stay 0.6.
4. `quadSize = quadSize / 2` (so 0.05 to 0.1 and a side of 0.1 to 0.2 blocks).
5. Two more draws: `uo = nextFloat * 3.0`, then `vo = nextFloat * 3.0` (draw 8 and 9 of the construction).
6. `layer = Layer.bySprite(sprite)`: `OPAQUE_TERRAIN` or `TRANSLUCENT_TERRAIN` for sprites of the block atlas, by whether the sprite has translucent pixels (42-1 §4.3).

Defaults inherited: `lifetime0` of the base (4 to 40 ticks), `friction 0.98`, `hasPhysics true`, bounding box 0.2 by 0.2.

### 3.2 Sprite window

Instead of the whole sprite the particle draws a quarter-size window. With `getU(f) = u0 + (u1 - u0) * f` and `getV` likewise (the sprite's own corners):

- `U0 = getU((uo + 1) / 4)`, `U1 = getU(uo / 4)`, `V0 = getV(vo / 4)`, `V1 = getV((vo + 1) / 4)`.

`uo` and `vo` are floats in [0, 3), so the window is a continuous offset, 1/4 of the sprite wide and high, starting at `uo/4` of the sprite and ending at most at 1. Because `U0 > U1` here (the reverse of the default `getU0 < getU1` of `SingleQuadParticle`), the texture is drawn horizontally mirrored; the vertical order is the default. `BreakingItemParticle` uses the same window (§7.1).

### 3.3 `block` (`TerrainParticle$Provider`) and the creation guard

All three terrain providers go through one guard. Given the options' block state S: return **no particle** when S is air, when S is the moving piston block, or when `S.shouldSpawnTerrainParticles()` is false. That flag is true for every block except those built with `noTerrainParticles()`; in `Blocks` exactly two blocks set it: `barrier` and `structure_void` (each call read in the static initialiser). Otherwise construct `TerrainParticle(level, x, y, z, vx, vy, vz, S)` (default block position) with the velocity arguments of the call, no further changes. So a `block` particle spawned through the packet or by an emitter has: velocity = normalised burst biased by (vx, vy, vz), lifetime 4 to 40, gravity 1.

### 3.4 `block_crumble` (`TerrainParticle$CrumblingProvider`)

Same guard and construction, then `setParticleSpeed(0, 0, 0)` (the burst is discarded; velocity becomes exactly zero) and `lifetime = nextInt(10) + 1` (1 to 10, one draw of the provider's random after the construction draws). Gravity 1 still acts, so the piece falls straight down from rest. Emitted by the creaking mob (part 7).

### 3.5 `dust_pillar` (`TerrainParticle$DustPillarProvider`)

Same guard and construction, then, with the provider's random, in this order: `g1 = nextGaussian`, `g2 = nextGaussian`, `g3 = nextGaussian`; `setParticleSpeed(g1 / 30.0, vy + g2 / 2.0, g3 / 30.0)` where vy is the call's y velocity argument; then `lifetime = 20 + nextInt(20)` (20 to 39). Gravity 1 acts afterwards. The only emitter is `ParticleUtils.spawnSmashAttackParticles` (the handler of level event 2013, the mace smash; 42-7 §8.5, which describes it fully; `ParticleUtils.spawnParticles` never creates this particle). That emitter sends gaussian * 0.2 per axis as velocity arguments for its first loop (centre burst) and gaussian * 0.05 per axis for its second loop (ring of radius 3.5), so after the provider the horizontal speed is `g/30` (the argument's x and z are discarded) and the vertical speed is `vy + g2/2` with vy = 0.2 g or 0.05 g respectively.

### 3.6 Block-break burst (`ClientLevel.addDestroyBlockEffect`)

Input: block position P and the block state S that was there. Nothing happens when S is air or `shouldSpawnTerrainParticles()` is false. Otherwise the state's **collision-and-selection `getShape(level, P)`** (the voxel shape) is walked box by box (`forAllBoxes`, box coordinates relative to the block, with a granularity argument 0.25), and for each box (x0, y0, z0, x1, y1, z1):

1. `sx = min(1, x1 - x0)`, `sy = min(1, y1 - y0)`, `sz = min(1, z1 - z0)`.
2. Counts: `nx = max(2, ceil(sx / 0.25))`, `ny = max(2, ceil(sy / 0.25))`, `nz = max(2, ceil(sz / 0.25))` (`Mth.ceil`, so a full cube gives 4).
3. For `i` in `[0, nx)`, `j` in `[0, ny)`, `k` in `[0, nz)`, in the nesting order i (outer), j, k (inner): `fx = (i + 0.5) / nx`, `fy = (j + 0.5) / ny`, `fz = (k + 0.5) / nz`; the particle position is `(P.x + fx*sx + x0, P.y + fy*sy + y0, P.z + fz*sz + z0)`; the velocity bias is `(fx - 0.5, fy - 0.5, fz - 0.5)`; the particle is `new TerrainParticle(level, position, bias, S, P)` (the block position P is passed explicitly, for the tint lookup of 3.1 step 3) and is added to the engine directly (`ParticleEngine.add`; this path does not go through `addParticle`, so the 32-block distance test, the particle status and the override rules of 42-1 §7.1 do **not** apply, only the engine's own group limits of 42-1 §5.4).

Total per block = sum over boxes of `nx*ny*nz`. A full cube is one box: 4 x 4 x 4 = 64 particles. This is the direct effect of a destroyed block; when the sound and the break are triggered (level event 2001 and the client break path) is in §13.3 (the wax, scrape, spark and egg-crack events) and 42-7 §8 (the full level-event table, event 2001 and the client break path).

### 3.7 Hit-crack particles (`ClientLevel.addBreakingBlockEffects` and `addBreakingParticles`)

Called while the player mines a block: input block position P, the face being hit (direction `F`) and a flag `playSound`.

1. `S = getBlockState(P)`. Air: nothing.
2. If `playSound`: play the block sound type's *hit* sound in the BLOCKS source category with volume `(soundType.volume + 1.0) / 8.0` and pitch `soundType.pitch * 0.5` (`playBreakingSound`; the sound instance is built with an unseeded random and the block position, and that constructor places the sound at the **block centre**, `(P.x + 0.5, P.y + 0.5, P.z + 0.5)`; read from `SimpleSoundInstance`).
3. If the render shape of S is not `INVISIBLE` and `shouldSpawnTerrainParticles()`: spawn one particle (below).

**One crack particle.** Let `B = S.getShape(level, P).bounds()` (the shape's overall box, relative to the block). For each axis with the order x, y, z, draw one `nextDouble` u and compute `coord = P.axis + u * (B.max - B.min - 0.2) + 0.1 + B.min`, where 0.2 and 0.1 are f32 constants widened to double (0.20000000298023224 and 0.10000000149011612, read from the constant pool). Then the coordinate on the axis of the hit face is replaced: `DOWN`: `y = P.y + B.minY - 0.1`; `UP`: `y = P.y + B.maxY + 0.1`; `NORTH`: `z = P.z + B.minZ - 0.1`; `SOUTH`: `z = P.z + B.maxZ + 0.1`; `WEST`: `x = P.x + B.minX - 0.1`; `EAST`: `x = P.x + B.maxX + 0.1`. The face offsets of 0.1 are the same widened value 0.10000000149011612. (The x, y, z draws are consumed in this order whichever face is hit.) The particle is `new TerrainParticle(level, x, y, z, 0, 0, 0, S, P)`, then `setPower(0.2)` (the argument is the f32 0.2f; 42-1 §4.1: `xd *= 0.2`, `yd = (yd - 0.1)*0.2 + 0.1`, `zd *= 0.2`), then `scale(0.6)` (the argument is the f32 0.6f, widened 0.6000000238418579 when multiplied in double arithmetic (recalled arithmetic, not read); `quadSize *= 0.6` and the box becomes 0.12 by 0.12), then it is added to the engine directly (no distance or status test).

Resulting numbers: side 0.06 to 0.12 blocks, horizontal velocity magnitude at most about 0.2 * 0.18 (inferred: arithmetic from the burst bound of 42-1 §4.1 and `setPower(0.2)`; not read as a constant).

### 3.8 Not to be confused with the crack overlay

The progressive crack texture drawn on the block face while mining is not a particle (12, crack overlay); the hit-crack particles of 3.7 are separate.

## 4. `BlockMarker` and its emission

`BlockMarker(level, x, y, z, state)`: base `SingleQuadParticle` position-only constructor with the sprite of the block state's particle material (as 3.1), then `gravity = 0`, `lifetime = 80`, `hasPhysics = false`, `layer = Layer.bySprite(sprite)`. `getQuadSize` returns the constant 0.5 whatever the age, so the drawn square is 1.0 block on a side centred on the position, with colour 1, 1, 1 and alpha 1. Velocity is zero; with gravity 0, friction 0.98 and no physics it never moves. There is no guard in the provider (barrier and light blocks are the intended inputs).

**Emission (`ClientLevel.animateTick`, `doAnimateTick`, `getMarkerParticleTarget`).** The marker is an editor aid. Each client tick, when the game is not paused and the level is running normally (`Minecraft.tick`), `animateTick(px, py, pz)` is called with the local player's block coordinates. Then:

1. `target` = the block of the player's main-hand item when the game mode is creative and the item is one of the two items in `MARKER_PARTICLE_ITEMS` (`barrier` and `light`) and is a block item; else none.
2. Loop `i` from 0 to 666 (667 iterations); each iteration calls `doAnimateTick(px, py, pz, 16, ...)` and then `doAnimateTick(px, py, pz, 32, ...)`.
3. `doAnimateTick(x, y, z, r, ...)`: choose a block `(x + nextInt(r) - nextInt(r), y + nextInt(r) - nextInt(r), z + nextInt(r) - nextInt(r))` (six `nextInt(r)` draws of the **level's** random, in the order +x, -x, +y, -y, +z, -z; the offsets are triangular in [-(r-1), r-1]). Read the block state and fluid state there.
4. Call the block's `animateTick(state, level, pos, random)` (the per-block emitters of 42-6; the `random` passed is a thread-local source made once per `animateTick` call).
5. If the fluid is not empty: call the fluid's `animateTick`; and when the fluid has a drip particle and `nextInt(10) == 0` and the face below is sturdy, try the drip particles (42-3).
6. If `target` equals the block there: spawn `BLOCK_MARKER` with the block's state at the **centre** of the block (pos + 0.5 on each axis), velocity (0, 0, 0), through `addParticle` (so the override flag of the type, "yes", makes it ignore distance and the status; 42-1 §7.1).
7. If the block's collision shape is **not** a full block: apply the ambient-particle attribute (§14).

Expected cost: 1334 sample positions per client tick, 667 within 15 blocks and 667 within 31 blocks on each axis.

## 5. `FallingDustParticle`

**Provider (colour choice).** For options with block state S: return no particle when S is air or its render shape is `INVISIBLE`. Let `pos = BlockPos.containing(x, y, z)`. The colour int `c` is, in order of preference:
1. if S's block is a `FallingBlock`: `getDustColor(S, level, pos)`;
2. else if S has a tint source of index 0: `colorAsTerrainParticle(S, level, pos)` (43);
3. else the map colour of S at `pos` (`getMapColor(level, pos).col`).
Then `r = ((c >> 16) & 255) / 255`, `g = ((c >> 8) & 255) / 255`, `b = (c & 255) / 255`. The particle is built with (x, y, z) only: **the velocity arguments are ignored** and the particle starts at rest.

**Dust colours of the falling blocks** (`FallingBlock.getDustColor` subclasses read):

| Block class | Colour used |
|---|---|
| `ColoredFallingBlock` / `SandBlock` | the `ColorRGBA` given at construction. In `Blocks`: `sand` 14406560 (`0xDBD3A0`), `red_sand` 11098145 (`0xA95821`), `gravel` -8356741 (`0xFF807C7B`; the alpha byte is dropped by the channel split) |
| `ConcretePowderBlock` | the block's map colour (`MapColor.col`) |
| `AnvilBlock` | the block's map colour |
| `DragonEggBlock` | -16777216 (`0xFF000000`): black |
| `BrushableBlock` | **not a `FallingBlock`**: the class extends `BaseEntityBlock` and implements `Fallable`, and defines no dust-colour method. The provider's first branch therefore never applies to it; a `falling_dust` particle for a brushable state takes branch 2 (tint source of index 0) or else branch 3 (map colour). Whether those blocks have a tint source was not read (Open question 6). Its own emission is described below |

**Constructor `(level, x, y, z, r, g, b, sprites)`.** Base `SingleQuadParticle` position-only constructor with `sprites.first()` (2 draws: lifetime, quad size). Then: `rCol, gCol, bCol = r, g, b` (no per-particle brightness variation); `quadSize *= 0.67499995`; one draw `f = nextFloat`: `base = (int)(32.0 / (f * 0.8 + 0.2))` (double arithmetic, truncated); `lifetime = (int) max(base * 0.9f, 1.0f)` (so 32/1 = 32*0.9 = 28 at f = 1, and 160 * 0.9 = 144 at f = 0); the sprite is set from age 0; `rotSpeed = (nextFloat - 0.5) * 0.1`; `roll = nextFloat * 6.2831855`. Draw order: lifetime(base), quad size, f, rotSpeed, roll. Layer OPAQUE.

`getQuadSize(partial)`: `quadSize * clamp((age + partial) / lifetime * 32, 0, 1)`: it grows from nothing to full size over the first 1/32 of its life.

**Tick (replaces the base tick; no gravity field, no friction):**
1. `xo, yo, zo` = position; if `age++ >= lifetime` (old age) remove and end.
2. Sprite from age (`age * (n - 1) / lifetime`, 42-1 §6.3).
3. `oRoll = roll`; `roll += 3.1415927 * rotSpeed * 2`; if `onGround` then `roll = 0` and `oRoll = 0`.
4. `move(xd, yd, zd)` (42-1 §4.4).
5. `yd -= 0.003000000026077032` (float 0.003); `yd = max(yd, -0.14000000059604645)`. `xd` and `zd` stay 0 (nothing changes them; collision cannot add motion).

Terminal fall speed 0.14 blocks per tick after about 47 ticks of acceleration (arithmetic: 0.14 / 0.003 = 46.7).

**Emission of ordinary falling blocks** (`FallingBlock.animateTick`): each animate tick of a falling block (the sampling of §4 steps 3 and 4), if `nextInt(16) == 0` and the block below is "free" (`FallingBlock.isFree`: the same test that lets the block fall) then `ParticleUtils.spawnParticleBelow(level, pos, random, BlockParticleOption(FALLING_DUST, state))` (§15.2): a particle at `(pos.x + nextDouble, pos.y - 0.05, pos.z + nextDouble)` with velocity 0. **`BrushableBlock` (suspicious sand and gravel) has its own `animateTick`**, which is not inherited from `FallingBlock` but has the same shape. Draw order: one `nextInt(16)` of the level's random; when it is 0 and the block below is free (the static `FallingBlock.isFree` test), a `falling_dust` particle with the block's own state at `(pos.x + nextDouble, pos.y - 0.05, pos.z + nextDouble)`, velocity 0, through `Level.addParticle` (the draws are x first, then z; y is fixed). That is the same position rule as §15.2.

## 6. Dust family

### 6.1 `DustParticleBase` (shared constructor)

Input: level, position, velocity bias (vx, vy, vz), options `T` (a scalable option: `getScale()`), sprites.

1. Base `SingleQuadParticle` constructor with velocity and `sprites.first()` (the normalised burst, 7 draws).
2. `friction = 0.96`; `speedUpWhenYMotionIsBlocked = true` (so after a tick whose y did not change, `xd` and `zd` are multiplied by 1.1 before friction).
3. `xd, yd, zd` each multiplied by 0.10000000149011612 (the burst is scaled to a tenth).
4. `quadSize *= 0.75 * scale` (f32).
5. One `nextDouble` d (not a float): `base = (int)(8.0 / (d * 0.8 + 0.2))`; `lifetime = (int) max((float) base * scale, 1.0f)`. For scale 1 this is 8 to 40 ticks; scale 4 multiplies it (a base of 13 gives 52).
6. Sprite set from age 0. `getLayer` = OPAQUE.

`randomizeColor(a, b)` = `(nextFloat * 0.2 + 0.8) * a * b`, with a fresh draw each call.

`getQuadSize(partial)` = `quadSize * clamp((age + partial) / lifetime * 32, 0, 1)` (grow-in over the first 1/32 of life). `tick` = base tick, then the sprite from age.

### 6.2 `DustParticle` (`dust`)

After 6.1 (with the provider passing the call's position and velocity and the options), one draw `f = nextFloat * 0.4 + 0.6`; then three draws in order for the channels: `rCol = randomizeColor(color.x, f)`, `gCol = randomizeColor(color.y, f)`, `bCol = randomizeColor(color.z, f)`, where `color` is the option's colour split from RGB24 into three floats (each byte / 255). Each channel is therefore the option colour scaled by a factor in [0.48, 1.0] (0.8 to 1.0 times 0.6 to 1.0). Alpha stays 1.

Total draw order: lifetime(1), a, b, c, d, e (burst), quad size, d-double (lifetime), f, then the three channel draws.

### 6.3 `DustColorTransitionParticle` (`dust_color_transition`)

After 6.1: one draw `f = nextFloat * 0.4 + 0.6`; `fromColor = (randomizeColor(from.x, f), randomizeColor(from.y, f), randomizeColor(from.z, f))` (three draws), then `toColor` likewise from the option's `to` colour (three more draws). The colour fields are **not** set at construction; they are recomputed each time the particle is extracted for drawing (before the quad is built): `t = (age + partial) / (lifetime + 1)`; `colour = fromColor + (toColor - fromColor) * t` per channel; `rCol, gCol, bCol` take the three components. So the colour animates smoothly with the partial tick and never quite reaches `toColor`.

Option constants (42-1 §3): `REDSTONE` = RGB 0xFF0000 scale 1.0; `SCULK_TO_REDSTONE` from 0x39D6E0 to 0xFF0000 scale 1.0.

## 7. Item break particles (`BreakingItemParticle`)

### 7.1 Constructors

**Core constructor `(level, x, y, z, sprite)`** (no velocity argument): base `SingleQuadParticle` constructor **with a zero velocity bias** (normalised burst of §1, 7 draws), `gravity = 1.0`, `quadSize = quadSize / 2` (0.05 to 0.1), then `uo = nextFloat * 3.0` and `vo = nextFloat * 3.0`, `layer = Layer.bySprite(sprite)`. The quarter-size texture window is the same as 3.2 (`U0 = getU((uo+1)/4)`, `U1 = getU(uo/4)`, `V0 = getV(vo/4)`, `V1 = getV((vo+1)/4)`). Friction 0.98, physics on, lifetime 4 to 40.

**Velocity constructor `(level, x, y, z, vx, vy, vz, sprite)`**: the core constructor, then `xd = xd * 0.10000000149011612 + vx`, `yd = yd * 0.10000000149011612 + vy`, `zd = zd * 0.10000000149011612 + vz`. The burst is tenfold smaller than the zero-velocity form, and the caller's velocity is added exactly.

### 7.2 `item` (`BreakingItemParticle$Provider`)

Provider: take the option's item stack template, resolve a sprite, and build with the **velocity constructor** with the call's velocity. Sprite resolution (shared `ItemParticleProvider.getSprite(template, level, random)`): create the stack from the template, ask the item model resolver for the render state in display context `GROUND` (`updateForTopItem`), then `ItemStackRenderState.pickParticleMaterial(random)`; if that gives a material, its sprite; otherwise the **missing sprite of the items atlas**. The pick (read): when the render state has **no active layer** it returns nothing and **consumes no draw**; otherwise it makes **exactly one** `nextInt(activeLayerCount)` draw of the provider's random (also when the count is 1, so a single-layer item still consumes one draw) and returns the particle material of the layer at that index. This draw happens before the particle constructor's draws. The particle material of a layer is the sprite its item model designates for particles (data of the item model definition, 14; Open question 7). The item break path of 42-7 uses this same provider.

### 7.3 `item_slime`, `item_cobweb`, `item_snowball` (plain providers)

Each builds the template of one item (`slime_ball`, `cobweb`, `snowball`), resolves the sprite exactly as 7.2, and uses the **core constructor** (no velocity argument): the call's velocity is **ignored**, the particle has the full-size burst (magnitude `s*0.4` with s in [0.15, 0.45] and an upward `+0.1` on y) and not the tenth-size burst of the velocity constructor.

### 7.4 `sulfur_cube_goo` (`BreakingItemParticle$SulfurCubeProvider`)

A sprite-set provider: the sprite is `sprites.first()` of the type's particle definition (not an item model); the core constructor is used (velocity argument ignored), so it is the same as 7.3 with a different sprite source.

### 7.5 Emission

`item_slime`: slime and oozing effect; `item_cobweb`: weaving effect; `item_snowball`: snowball hit; `sulfur_cube_goo`: sulfur cube (all in 42-7; found in `Slime`, `OozingMobEffect`, `WeavingMobEffect`, `Snowball`, `SulfurCube`). The `item` particle is emitted for breaking tools, eating and similar (part 7).

## 8. Falling leaves

### 8.1 Class

`FallingLeavesParticle` has no behaviour of its own: its constructor `(level, x, y, z, sprite, gravityScale, windBig, swirl, flowAway, sizeScale, fallSpeed)` is the `FallingParticle` constructor, whose full behaviour (constants, the three booleans, wind, swirl, roll, removal) is 42-1 §8.4 and is not repeated. One check of that text against the artifact: `FallingParticle.tick` reads `lifetime`, decrements it in place and tests the **old** value (`<= 0` removes), as 42-1 states.

### 8.2 Providers and their numbers

Every provider draws the sprite first with `sprites.get(random)` (one `nextInt(n)` of the provider's random; n is the number of sprites of the type, 42-1 §2: 12 for cherry, pale oak and tinted, 4 for each poplar) and then constructs `FallingLeavesParticle(level, x, y, z, sprite, ...)` with the call's position (the velocity arguments are ignored).

| Type | gravityScale | windBig | swirl | flowAway | sizeScale | fallSpeed |
|---|---|---|---|---|---|---|
| `cherry_leaves` | 0.25 | 2.0 | false | true | 1.0 | 0.0 |
| `pale_oak_leaves` | 0.07 | 10.0 | true | false | 2.0 | 0.021 |
| `red_poplar_leaves`, `orange_poplar_leaves`, `yellow_poplar_leaves` (same provider class) | 0.07 | 10.0 | true | false | 2.0 | 0.021 |
| `tinted_leaves` | 0.07 | 10.0 | true | false | 2.0 | 0.021 |

`tinted_leaves` additionally calls `setColor(option.getRed(), option.getGreen(), option.getBlue())` after the construction, where each is the option's ARGB byte divided by 255.0 (alpha ignored). The other types keep colour 1, 1, 1 (the sprite carries the colour).

Derived values (arithmetic from 42-1 §8.4's formulas): the per-tick gravity is `gravityScale * 1.2 * 0.0025` = 0.00075 for cherry and 0.00021 for the others; the quad size is `sizeScale * 0.05` or `sizeScale * 0.075` (one boolean draw): cherry 0.05 or 0.075, the others 0.10 or 0.15 (a drawn side of twice that); the initial `yd` is `-fallSpeed`: 0 for cherry and -0.021 for the others; `windBig` and the flow draw give the cherry petals a one-way drift of strength up to 2.0 and the others a swirl of strength up to 10.0.

### 8.3 Colour of a tinted leaf

Emission of `tinted_leaves` (class `TintedParticleLeavesBlock.spawnFallingLeavesParticle`) passes `ColorParticleOption.create(TINTED_LEAVES, level.getClientLeafTintColor(pos))`. On the client `getClientLeafTintColor(pos)` is: the block state at `pos`; its tint source of index 0; if present, `colorInWorld(state, level, pos)`, otherwise -1 (white). The in-world colour of foliage is the biome foliage colour (43). On a server-side level the same method returns 0, which gives an ARGB of 0 (black, alpha 0); leaf emission only runs in the client animate tick, so that case does not occur.

### 8.4 Emission numbers (code constants of `Blocks`)

`FallingParticlesLeavesBlock.animateTick` (after the leaves' own animate tick): draw `nextFloat`; when it is `>= leafParticleChance` stop. Then read the block state below; when the **up face of its collision shape is full** (`isFaceFull(shape, UP)`) stop. Otherwise call the subclass's spawn method, which for `UntintedParticleLeavesBlock` is `ParticleUtils.spawnParticleBelow(level, pos, random, particleOption)` (§15.2: position `(x + nextDouble, y - 0.05, z + nextDouble)`, zero velocity) and for `TintedParticleLeavesBlock` the same call with the colour option of 8.3. The chance and the particle per block (from the constructors in `Blocks`):

| Block | Class | Chance per sampled animate tick | Particle |
|---|---|---|---|
| `oak_leaves`, `birch_leaves`, `jungle_leaves`, `acacia_leaves`, `dark_oak_leaves` | `TintedParticleLeavesBlock` | 0.01 | `tinted_leaves` with the client leaf tint |
| `mangrove_leaves` | `MangroveLeavesBlock` (a subclass of `TintedParticleLeavesBlock` that overrides no particle code; constructed with the float 0.01) | 0.01 | `tinted_leaves` with the client leaf tint |
| `cherry_leaves` | `UntintedParticleLeavesBlock` | 0.1 | `cherry_leaves` |
| `pale_oak_leaves` | `UntintedParticleLeavesBlock` | 0.02 | `pale_oak_leaves` |
| `red_poplar_leaves`, `orange_poplar_leaves`, `yellow_poplar_leaves` | `UntintedParticleLeavesBlock` | 0.01 | the matching poplar particle |
| `azalea_leaves`, `flowering_azalea_leaves` | `UntintedParticleLeavesBlock` | 0.01 | `tinted_leaves` with the **fixed** colour int -9399763 (`0xFF70922D`: red 112, green 146, blue 45) |

(Spruce leaves are a plain `LeavesBlock`, not constructed with these classes, so they emit nothing; the same holds for any other leaf block not in the table. Mangrove leaves emit exactly like oak.) The poplar leaf blocks also take an ambient-sound argument and a tag; those belong to the sound part.

## 9. Ash particles

Both are `BaseAshSmokeParticle` (42-1 §8.5: constructor, growth, sprite-from-age, light default). Constructor arguments `(level, x, y, z, vxMul, vyMul, vzMul, ax, ay, az, scale, sprites, colourMul, lifetimeBase, gravity, hasPhysics)`:

| Type | vxMul, vyMul, vzMul | ax, ay, az | scale | colourMul | lifetimeBase | gravity | hasPhysics |
|---|---|---|---|---|---|---|---|
| `ash` | 0.1, -0.1, 0.1 | the call's velocity | 1.0 (from the provider) | 0.5 | 20 | 0.1 | false |
| `white_ash` | 0.1, -0.1, 0.1 | provider-drawn (below) | 1.0 | 0.0 (colour overwritten) | 20 | 0.0125 | false |

**`ash`.** The provider passes position (x, y, z), velocity (0, 0, 0) and scale 1.0 (the call's own velocity is **not** used). Result: the burst's x and z are damped to a tenth and **y is inverted and damped** (`yd = yd_burst * -0.1`, where `yd_burst` already contains the burst's `+0.1`; so a burst that goes up gives a downward start), grey colour `nextFloat * 0.5` (0 to 0.5 on all three channels), lifetime `(int)(20 / (r*0.8 + 0.2))` (20 to 100), gravity 0.1 so `yd -= 0.004` per tick, friction 0.96, no collision. Draws: base lifetime, burst (5), quad size, colour draw, lifetime draw.

**`white_ash` (`WhiteAshParticle$Provider`).** The provider draws six floats in this order (provider random): `ax = (r1 * -1.9) * r2 * 0.1`, `ay = ((r3 * -0.5) * r4 * 0.1) * 5.0`, `az = (r5 * -1.9) * r6 * 0.1`. So `ax` and `az` are in [-0.19, 0] and `ay` in [-0.25, 0]. It then builds the particle at the call's position (the call's velocity is ignored) with those add-ons and scale 1.0. After the base constructor, the colour is set from the constant RGB24 12235202 (`0xBAB1C2`): `rCol = 186/255`, `gCol = 177/255`, `bCol = 194/255` (about 0.729, 0.694, 0.761). Otherwise as ash (lifetime 20 to 100, friction 0.96, no collision) except gravity 0.0125 (`yd -= 0.0005` per tick). The white ash therefore drifts mostly sideways in the negative-x and negative-z direction and slightly down.

**Emission:** both are produced by the biome ambient-particle attribute (§14): basalt deltas `white_ash` probability 0.118093334 and soul sand valley `ash` probability 0.00625 are the constants in `NetherBiomes` (data-generator constants; the shipped data pack carries them; the extraction tool reads the biome files).

## 10. Suspended particles

### 10.1 `SuspendedTownParticle` (`mycelium`, `egg_crack`)

Constructor `(level, x, y, z, vx, vy, vz, sprite)`:
1. Base `SingleQuadParticle` constructor with a velocity (burst; 7 draws).
2. One draw `f`: `grey = f * 0.1 + 0.2`; `rCol = gCol = bCol = grey` (0.2 to 0.3).
3. `setSize(0.02, 0.02)`.
4. `quadSize *= (nextFloat * 0.6 + 0.5)` (one draw).
5. `xd, yd, zd *= 0.019999999552965164` (float 0.02).
6. One draw: `lifetime = (int)(20.0 / (nextFloat * 0.8 + 0.2))` (20 to 100; not clamped, never 0).
`getLayer` = OPAQUE. The sprite is picked once by the provider with `sprite.get(random)` (one `nextInt(n)` before the constructor) and never changes.

**Movement.** `move(dx, dy, dz)` is overridden: it only translates the bounding box and recomputes the position (**no collision**, `hasPhysics` is irrelevant). **Tick (replaces the base tick):** `xo, yo, zo` = position; `lifetime -= 1` and remove if the **old** value was `<= 0` (so the particle is alive for `lifetime + 1` ticks counting the removal tick), then `move(xd, yd, zd)`, then `xd, yd, zd *= 0.99`. No gravity. The sprite never changes. `age` is not used.

`egg_crack` (`EggCrackProvider`): identical, then `setColor(1, 1, 1)` after the constructor, so it is white (the grey of step 2 is overwritten). Provider call position and velocity are passed through unchanged by both providers. The emission of `egg_crack` is level event 3009 handled by `LevelEventHandler` with `spawnParticlesOnBlockFaces` and `UniformInt(3, 6)` per face (§13.3, §15.4). The emission of `mycelium` is `MyceliumBlock.animateTick` and the entity classes `MushroomCow` and `Phantom` (42-6, 42-7).

### 10.2 `SuspendedParticle` (`crimson_spore`, `warped_spore`, `spore_blossom_air`)

Two constructors, both starting at **`y - 0.125`** (the spawn y is lowered by 0.125):
- **Without velocity** `(level, x, y, z, sprite)`: position-only base (2 draws), `setSize(0.01, 0.01)`, `quadSize *= (nextFloat * 0.6 + 0.2)`, `lifetime = (int)(16.0 / (nextFloat * 0.8 + 0.2))` (16 to 80), `hasPhysics = false`, `friction = 1.0`, `gravity = 0`. (No provider of this part uses it; the underwater provider of 42-3 does, not read here.)
- **With velocity** `(level, x, y, z, vx, vy, vz, sprite)`: base with a velocity (burst, 7 draws), `setSize(0.01, 0.01)`, `quadSize *= (nextFloat * 0.6 + 0.6)`, `lifetime` as above, `hasPhysics = false`, `friction = 1.0`, `gravity = 0`.
Layer OPAQUE; the base tick is used (age against lifetime, then move without collision, `friction 1`, so velocity is constant apart from gravity). The sprite is fixed at construction from the provider's `get(random)`.

**Providers:**

| Type | Velocity argument (x, y, z) | After construction | Draw order in the provider |
|---|---|---|---|
| `crimson_spore` | `(g1 * 9.999999974752427e-7, g2 * 9.999999747378752e-5, g3 * 9.999999974752427e-7)` (float 1e-6, 1e-4, 1e-6) of three `nextGaussian` | `setColor(0.9, 0.4, 0.5)` | g1, g2, g3, then the sprite `nextInt` |
| `warped_spore` | `(0, (r1 * -1.9) * r2 * 0.1, 0)` (two floats; a value in [-0.19, 0]) | `setColor(0.1, 0.1, 0.3)` and `setSize(0.001, 0.001)` | r1, r2, then the sprite `nextInt` |
| `spore_blossom_air` | `(0, -0.800000011920929, 0)` (float -0.8) | `lifetime = Mth.randomBetweenInclusive(random, 500, 1000)` (500 to 1000, provider random), `gravity = 0.01`, `setColor(0.32, 0.5, 0.22)` | sprite `nextInt` then lifetime draw |

All three use the velocity constructor; the supplied velocity is only a **bias** for the burst (the burst's `s*0.4` magnitude of 0.06 to 0.18 dominates the crimson and warped cases, so these drift in a random direction with a small upward `0.1` added to `yd`; see 42-1 §4.1 for the burst). For `spore_blossom_air` the bias is down, so with `-0.8` the burst direction is mostly down: with zero horizontal jitter the direction is exactly (0, -1, 0) and `yd = -s*0.4 + 0.1`, in [-0.08, 0.04] (inferred: arithmetic from 42-1 §4.1 with s in [0.15, 0.45], not read as a constant; the jitter terms of the burst make the real directions vary).

`spore_blossom_air` is a **limited** type: the anonymous subclass overrides `getParticleLimit` to return `ParticleLimit.SPORE_BLOSSOM` (limit 1000 live particles; 42-1 §5.4). Emission by `SporeBlossomBlock.animateTick` (42-6); crimson and warped spores by the biome ambient attribute (§14) with the `NetherBiomes` constants `crimson_forest` 0.025 and `warped_forest` 0.01428.

## 11. `SnowflakeParticle`

Constructor `(level, x, y, z, vx, vy, vz, sprites)`: base `SingleQuadParticle` constructor **without velocity** (position-only: 2 draws: lifetime, quad size, no burst), `gravity = 0.225`, `friction = 1.0`, then velocity set directly: `xd = vx + (nextFloat * 2 - 1) * 0.05`, `yd = vy + (nextFloat * 2 - 1) * 0.05`, `zd = vz + (nextFloat * 2 - 1) * 0.05` (three draws, x, y, z), then `quadSize = 0.1 * (r1 * r2 * 1.0 + 1.0)` (two draws, r1 then r2: **assigned**, not multiplied: 0.1 to 0.2), `lifetime = (int)(16.0 / (nextFloat * 0.8 + 0.2)) + 2` (18 to 82; one draw), sprite set from age 0. Layer OPAQUE.

`tick`: base tick (gravity `yd -= 0.04 * 0.225` = 0.009 per tick, friction 1, collision on), then the sprite from age, then `xd *= 0.949999988079071`, `yd *= 0.8999999761581421`, `zd *= 0.949999988079071` (a drag applied after each move). The provider builds the particle with the call's position and velocity and then `setColor(0.923, 0.964, 0.999)` (a pale blue-white). The sprite is chosen from age across the 8 sprites of the type (42-1 §2). Emission: `PowderSnowBlock` (42-6).

## 12. `FireflyParticle`

Constructor `(level, x, y, z, vx, vy, vz, sprite)`: base with a velocity (burst); `speedUpWhenYMotionIsBlocked = true`; `friction = 0.96`; `quadSize *= 0.75`; `yd, xd, zd *= 0.800000011920929` (the order read was y, x, z; the result is the same). Layer **TRANSLUCENT**. Alpha starts at 1.0 in the base but the provider sets 0 (below).

**Provider** (`FireflyProvider`), with the provider's random, in order:
1. `xArg = 0.5 - nextDouble`;
2. `b = nextBoolean`; `yArg = b ? vy : -vy` (the call's y velocity, sign flipped half the time);
3. `zArg = 0.5 - nextDouble`;
4. the sprite `sprite.get(random)` (one `nextInt`);
5. construct with (x, y, z, xArg, yArg, zArg);
6. `setLifetime(nextIntBetweenInclusive(200, 300))` (200 to 300 ticks, one draw);
7. `scale(1.5)`: `quadSize *= 1.5`, bounding box 0.3;
8. `setAlpha(0)`.

**Light.** `getLightCoords(partial) = (int)(255 * fade(progress, 0.1, 0.3))` where `progress = clamp((age + partial) / lifetime, 0, 1)` and the result is used as the light coordinate directly (block light only: no sky component; the block nibble of this value is `value >> 4`, so 255 is block light 15; 42-1 §4.3 gives the packing).

**The fade helper** `fade(p, a, b)`: `p >= 1 - a` gives `(1 - p) / a`; otherwise `p <= b` gives `p / b`; otherwise 1.0.

**Tick** (after the base tick, which uses `speedUp`, friction 0.96 and collision):
1. If the block at `BlockPos.containing(x, y, z)` is **not air**, remove and end.
2. `setAlpha(fade(age / lifetime, 0.3, 0.5))`, with `age` as an integer converted to float (no partial tick): the particle fades in over the first **50%** of its life (`p <= 0.5` gives `p / 0.5`) and out over the last **30%** (`p >= 0.7` gives `(1 - p) / 0.3`); the middle 20% is fully opaque.
3. One draw `nextFloat`; if it is `> 0.95` **or** `age == 1`, set the velocity to `(-0.05 + 0.1 * nextFloat, -0.05 + 0.1 * nextFloat, -0.05 + 0.1 * nextFloat)` (three more draws in x, y, z order). When the first test fails and `age != 1` the draw is the only draw of the tick.

So a firefly hovers with a new random drift (each component in [-0.05, 0.05)) about every 20 ticks on average (probability 0.05 per tick), damped by 0.96 per tick.

Emission: `FireflyBushBlock.animateTick` only (42-6). The one `EnvironmentAttributes` entry with firefly in its name, `FIREFLY_BUSH_SOUNDS` (`audio/firefly_bush_sounds`), is a boolean for the ambient sound and not a particle emitter; the ambient-particle biome data (§14) does not use `firefly` either.

## 13. `GlowParticle` family

### 13.1 Class

Constructor `(level, x, y, z, vx, vy, vz, sprites)`: base with a velocity and `sprites.first()` (the burst), `friction = 0.96`, `speedUpWhenYMotionIsBlocked = true`, `quadSize *= 0.75`, `hasPhysics = false`, sprite set from age 0. Layer OPAQUE. Every provider below overwrites the velocity afterwards with `setParticleSpeed` or by scaling, so the burst's draws are consumed but its values are mostly discarded.

`tick` = base tick, then the sprite from age. **Light:** `getLightCoords(partial) = LightCoordsUtil.addSmoothBlockEmission(baseLight, (age + partial) / lifetime)` where `baseLight` is the default light of 42-1 §4.3. `addSmoothBlockEmission(light, f)`: `f' = clamp(f, 0, 1)`; `emission = (int)(f' * 240.0)`; the block part is `min(smoothBlock(light) + emission, 240)` where `smoothBlock(l) = l & 255` and `smoothSky(l) = (l >> 16) & 255` (read: `smoothBlock`, `smoothSky` and `smoothPack` were all read; `pack(block, sky) = (block << 4) | (sky << 20)` and `block(l) = (l >> 4) & 15`, so a smooth block value of 255 maps to level 15 under `>> 4`); the result is `smoothPack(block, sky) = (block & 255) | ((sky & 255) << 16)`. In words: the particle's own light grows linearly from the cell's block light to 240 (full) over its life, with the sky part unchanged. (The 240 is the block-light value 15 times 16, the same units as `pack`'s `block << 4`.)

### 13.2 Providers

All use the provider's random (called `R` below) and the call's velocity (vx, vy, vz).

| Type | Colour (r, g, b) | Velocity set | Lifetime | Notes |
|---|---|---|---|---|
| `wax_on` | (0.91, 0.55, 0.08) | `(vx * 0.01 / 2, vy * 0.01, vz * 0.01 / 2)` | `R.nextInt(30) + 10` (10 to 39) | constructed with velocity bias (0, 0, 0) |
| `wax_off` | (1.0, 0.9, 1.0) | `(vx * 0.01 / 2, vy * 0.01, vz * 0.01 / 2)` | `R.nextInt(30) + 10` | bias (0, 0, 0) |
| `scrape` | `R.nextBoolean` true: (0.29, 0.58, 0.51); false: (0.43, 0.77, 0.62) | `(vx * 0.01, vy * 0.01, vz * 0.01)` | `R.nextInt(30) + 10` | bias (0, 0, 0); the boolean is drawn right after the construction draws |
| `electric_spark` | (1.0, 0.9, 1.0) | `(vx * 0.25, vy * 0.25, vz * 0.25)` | `R.nextInt(2) + 2` (2 to 3 ticks) | bias (0, 0, 0) |
| `glow` (glow squid) | `R.nextBoolean` true: (0.6, 1.0, 0.8); false: (0.08, 0.4, 0.4) | see below | `(int)(8.0 / (R.nextDouble * 0.8 + 0.2))` (8 to 40) | sprite = the set's first |

The colour setter is applied after the construction; for `wax_on`/`wax_off`/`electric_spark` it comes first and the velocity second, then the lifetime. The two sprite sets used by these particles are their definitions (a single sprite each, 42-1 §2; the sprite changes by age if the set has more than one).

**`glow` provider details.** Construction arguments, evaluated in this order: `x, y, z`, then `vxArg = 0.5 - R.nextDouble`, `vyArg = vy`, `vzArg = 0.5 - R.nextDouble` (two provider draws before the construction draws), then the construction. After: `R.nextBoolean` chooses the colour; `yd *= 0.20000000298023224`; and when the call's `vx == 0` **and** `vz == 0` (the arguments of the call, exact comparison to zero), `xd *= 0.1` and `zd *= 0.1`; then `setLifetime(...)` from one `R.nextDouble`. (The wax, scrape and spark providers do not re-read the burst; `glow` keeps its burst, biased by the random horizontal arguments, scaled as stated.) Emission: glow squid (42-7).

### 13.3 What feeds the providers (level events of `LevelEventHandler`)

The five block events call `ParticleUtils` (§15.4). Level-event ids are the case labels of `LevelEventHandler.levelEvent` (`lookupswitch`), matched to the handler bodies by their jump targets (the event id is the `Level Event` packet's event field, 05a; 42-7 §8 repeats these ids in its table):

| Event id | Particle | Event handling | Count per face |
|---|---|---|---|
| 3003 | `wax_on` | `spawnParticlesOnBlockFaces(level, pos, wax_on, UniformInt(3, 5))` | 3 to 5 for each of the six faces |
| 3004 | `wax_off` | same with `wax_off` | 3 to 5 |
| 3005 | `scrape` | same with `scrape` | 3 to 5 |
| 3002 | `electric_spark` | event data `d` with `0 <= d < 3` (the length of the axis table, index into x, y, z): `spawnParticlesAlongAxis(axis[d], level, pos, 0.125, electric_spark, UniformInt(10, 19))`; any other data value: `spawnParticlesOnBlockFaces(..., UniformInt(3, 5))` | see the middle column |
| 3009 | `egg_crack` | `spawnParticlesOnBlockFaces(level, pos, egg_crack, UniformInt(3, 6))` | 3 to 6 |

(The senders of these events, such as `LightningRodBlock`, are in 42-6 and 42-7.) The `lookupswitch` of `levelEvent` has 89 case labels in this artifact; 42-7 §8 states 83 handled ids: the difference is left to 42-7 (Open question 8). Only the particle calls of these five handlers were read here, not their sounds.

## 14. The ambient-particle environment attribute

`ClientLevel.doAnimateTick` (§4 step 7), for every sampled block position `pos` whose `isCollisionShapeFullBlock` is **false** (air, plants, slabs and the like): read the environment attribute `AMBIENT_PARTICLES` at `pos` (a list of `AmbientParticle`; the attribute system resolves the value from the biome and the other layers, 44 / the environment attribute document), and for each entry in list order:

1. `canSpawn`: one `nextFloat` of the level's random; true when `r <= probability` (note `<=`).
2. When true: `addParticle(entry.particle, pos.x + nextDouble, pos.y + nextDouble, pos.z + nextDouble, 0, 0, 0)` (three draws x, y, z, zero velocity; the normal entry point of 42-1 §7.1).

`AmbientParticle` is a record `(particle options, probability float)`; its record fields are `particle` and `probability` (the data-codec keys are the two strings `particle` and `probability`, read from the codec's constants). **Attribute identity and data form (read from `EnvironmentAttributes` and the biome files).** The attribute id is `minecraft:visual/ambient_particles`; its value type is a list of `AmbientParticle`, its default is the empty list and it is marked syncable (sent to the client with the other synchronised attributes, 44 / the environment-attribute document). In a biome file it sits under `attributes` as an object with an `argument` (the list) and a `modifier` of `append`, so biome layers add entries to the list rather than replacing it. Each entry is `{"particle": {"type": "minecraft:<name>"}, "probability": <float>}`.

**Complete list of users in the shipped data.** A scan of every data file of the jar for `ambient_particles` found exactly four files, all biomes (the same four are the ones `NetherBiomes` builds; no dimension-type, timeline or other data file sets the attribute). Exact values read from the files:

| Biome | Particle | Probability |
|---|---|---|
| `soul_sand_valley` | `ash` | 0.00625 |
| `basalt_deltas` | `white_ash` | 0.118093334 |
| `crimson_forest` | `crimson_spore` | 0.025 |
| `warped_forest` | `warped_spore` | 0.01428 |

`nether_wastes` carries **no** ambient-particle entry (its attribute list has only fog colour, ambient sounds, background music and spawn data). Because the attribute is data, a data pack can add more; the code spawns whatever the resolved list says. Every other biome resolves to the default empty list and spawns nothing here.

Rate: with all 1334 sample positions per tick in non-full cells, the expected spawns per tick for probability p are `1334 * p` (arithmetic): `white_ash` in basalt deltas about 157 per tick, `ash` about 8.3, `crimson_spore` about 33, `warped_spore` about 19. In practice a fraction of the samples falls on full blocks and spawns nothing.

## 15. Emission paths used by this part

### 15.1 Summary of who emits what (owned by 42-6 and 42-7 unless marked read here)

| Particle | Emitter (class) | Read here |
|---|---|---|
| `block` | break burst (3.6), hit crack (3.7); also `Entity`, `LivingEntity`, `ArmorStand`, `Cushion`, `Sniffer`, `Breeze`, `Warden`, `HoneyBlock`, `BrushItem`, `BrushableBlock`, `ServerPlayer` (42-6, 42-7) | 3.6, 3.7 only |
| `block_marker` | `ClientLevel.doAnimateTick` | yes (§4) |
| `block_crumble` | `Creaking` | no |
| `dust_pillar` | `ParticleUtils.spawnSmashAttackParticles` (level event 2013, mace smash; 42-7 §8.5) | provider only (3.5); emitter in 42-7 |
| `falling_dust` | `FallingBlock.animateTick`, `BrushableBlock.animateTick` (a separate method, not a `FallingBlock`) | both yes (§5) |
| `dust`, `dust_color_transition` | redstone-style users, sculk | no (42-1 §3 constants) |
| leaf particles | leaf blocks | yes (§8.4) |
| `item_slime`, `item_cobweb`, `item_snowball`, `sulfur_cube_goo` | `Slime`, `OozingMobEffect`, `WeavingMobEffect`, `Snowball`, `SulfurCube` | no |
| `mycelium` | `MyceliumBlock`, `MushroomCow`, `Phantom` | no |
| `snowflake` | `PowderSnowBlock` | no |
| `firefly` | `FireflyBushBlock` only (42-6; chance 0.7 per tick, horizontal range 10, vertical range 5, max brightness 13). `EnvironmentAttributes` has only `FIREFLY_BUSH_SOUNDS` (a boolean gating the ambient sound), not a particle attribute | no |
| `spore_blossom_air` | `SporeBlossomBlock` | no |
| `egg_crack`, `wax_on`, `wax_off`, `scrape`, `electric_spark` | `LevelEventHandler` events 3009, 3003, 3004, 3005, 3002; `electric_spark` also `LightningRodBlock` | events yes (13.3) |
| `glow` | glow squid | no |
| `ash`, `white_ash`, `crimson_spore`, `warped_spore` | biome ambient attribute | yes (§14) |
| `infested` | `LivingEntity`, `InfestedMobEffect` | no (42-2) |
| `tinted_leaves` | `TintedParticleLeavesBlock`, azalea leaves | yes (§8) |

### 15.2 `ParticleUtils.spawnParticleBelow(level, pos, random, options)`

One call to `Level.addParticle(options, pos.x + random.nextDouble, pos.y - 0.05, pos.z + random.nextDouble, 0, 0, 0)`: the x draw is first, the z draw second, y is fixed (0.05 below the block's lower face).

### 15.3 `ParticleUtils.spawnParticles(level, pos, count, spread, yExtent, allowInAir, options)` and `spawnParticleInBlock`

For each of `count` particles, with the level's random:
1. `vx = nextGaussian * 0.02`, `vy = nextGaussian * 0.02`, `vz = nextGaussian * 0.02` (draws in that order);
2. `inset = 0.5 - spread`;
3. `x = pos.x + inset + nextDouble * spread * 2.0`; `y = pos.y + nextDouble * yExtent`; `z = pos.z + inset + nextDouble * spread * 2.0` (draws x, y, z);
4. when `allowInAir` is false and the block below `containing(x, y, z)` is air, **skip** this particle (the draws were taken); otherwise `addParticle(options, x, y, z, vx, vy, vz)`.

`spawnParticleInBlock(level, pos, count, options)` calls it with spread 0.5, `yExtent` = 1.0 when the block at `pos` is air else the maximum y of the block's shape (`VoxelShape.max(Y)`), and `allowInAir = true`. (Callers such as bone meal, the redstone ore and campfires and the eye of ender use `spawnParticles`; they are not mapped to particle types here.)

### 15.4 `ParticleUtils.spawnParticlesOnBlockFaces`, `spawnParticlesOnBlockFace`, `spawnParticleOnFace`, `spawnParticlesAlongAxis`

- **On all faces:** for each of the six directions (`Direction.values()` order), call `spawnParticlesOnBlockFace(level, pos, options, count provider, faceDirection, speedSupplier, 0.55)`. Each face call samples its **own** count from the provider (`IntProvider.sample(level.random)`), so counts differ per face.
- **Per particle:** `speed = (Mth.nextDouble(rand, -0.5, 0.5) x3)` (three draws) from the default supplier, then `spawnParticleOnFace(level, pos, face, options, speed, 0.55)`.
- **On one face:** the particle position starts at the block centre; for each axis with face step `s` (the face's `getStepX/Y/Z`): if `s == 0` the offset is `Mth.nextDouble(rand, -0.5, 0.5)` (a draw), else `s * 0.55`; the velocity on that axis is `speed.axis` when `s == 0` and 0 otherwise. The draw order is the axes x, y, z. Then `addParticle(options, position, velocity)`.
- **Along an axis** (`spawnParticlesAlongAxis(axis, level, pos, spread, options, countProvider)`; the electric-spark event passes spread 0.125 and `UniformInt(10, 19)`). Let the block centre be `C = pos + 0.5` on each axis and let the "chosen axis" be the one given. With the level's random, in this order:
  1. `n = countProvider.sample(random)` (one draw, 10 to 19 for the spark).
  2. For each of the `n` particles: three position draws, one per axis in the order x, y, z, each `u = Mth.nextDouble(random, -1.0, 1.0)` (one draw, uniform in [-1, 1]); the coordinate is `C.axis + u * k` where `k = 0.5` on the chosen axis and `k = spread` (0.125) on the other two. Then the velocity: on the chosen axis only, one more `Mth.nextDouble(random, -1.0, 1.0)` draw gives the velocity component; the other two components are exactly 0 and consume **no** draw (so the order of velocity draws is only the chosen axis's one, after the three position draws).
  3. `addParticle(options, x, y, z, vx, vy, vz)` through the normal entry (42-1 §7.1).
  So the spark is a thin column of side 0.25 running along the whole block on the chosen axis (offset up to 0.5 from the centre, i.e. the block's own extent), with a velocity along that axis in [-1, 1]; the `electric_spark` provider then multiplies the velocity by 0.25 (§13.2), giving up to 0.25 blocks per tick along the axis over a 2 to 3 tick life.

## 16. Worked examples

**Example 1: the break burst of a full stone cube.** One box 0..1 in each axis: `sx = sy = sz = 1`, `n = max(2, ceil(1 / 0.25)) = 4` per axis, so 64 particles. The first one (i = j = k = 0): `f = (0 + 0.5)/4 = 0.125`; position `(P.x + 0.125, P.y + 0.125, P.z + 0.125)`; bias `(-0.375, -0.375, -0.375)`. With the five burst draws a = b = c = 0.5 (no jitter) and d = e = 0.5, the speed factor is `s = (0.5 + 0.5 + 1) * 0.15 = 0.3`; length of the bias = 0.6495; `xd = -0.375 / 0.6495 * 0.3 * 0.4 = -0.0693`; `yd` the same plus 0.1 = 0.0307; `zd = -0.0693`. The last one (i = j = k = 3) is at 0.875 with bias +0.375 and velocity (+0.0693, +0.1693, +0.0693).

**Example 2: a bottom slab.** Shape box (0, 0, 0, 1, 0.5, 1): `sy = 0.5`, `ny = max(2, ceil(0.5 / 0.25)) = 2`; counts 4 x 2 x 4 = 32 particles. A fence post (box width 0.25): `nx = max(2, ceil(0.25/0.25)) = max(2, 1) = 2`, so even thin boxes get at least 2 per axis.

**Example 3: a hit crack on top of a full block** at P = (10, 64, -3): the y coordinate is `64 + 1 + 0.1 = 65.1`; x is `10 + u * 0.8 + 0.1 + 0` (in [10.1, 10.9)), z likewise. Size: base 0.05 to 0.1, times 0.6, a side of 0.06 to 0.12; velocity after `setPower(0.2)`: horizontal at most 0.2 times the burst, vertical `(yd - 0.1)*0.2 + 0.1`.

**Example 4: a red dust particle of scale 2.** `base = (int)(8 / (d*0.8 + 0.2))` with d = 0.5 gives 13; `lifetime = (int) max(13 * 2.0, 1) = 26`; `quadSize = base_quad * 0.75 * 2`. For colour RGB 0xFF0000: channel red = `(u*0.2 + 0.8) * 1.0 * f` with f in [0.6, 1.0].

**Example 5: falling dust lifetime.** f = 0.5: `32 / (0.5*0.8 + 0.2) = 53.33`, `(int) = 53`, `53 * 0.9 = 47.7`, `lifetime = 47` (truncation by the float-to-int conversion). Quad size reaches full at age 47/32 = 1.47 ticks.

**Example 6: a cherry petal.** `gravity = 0.25 * 1.2 * 0.0025 = 0.00075`; draw `f = 0.5`: `xaFlowScale = cos(30 degrees) * 2.0 = 1.7321`, `zaFlowScale = sin(30 degrees) * 2.0 = 1.0`. At the tick where `lifetime` is 150 (t = 0.5): `t^1.25 = 0.4204`; the wind added is `1.7321 * 0.4204 = 0.7282` in x and `0.4204` in z, so `xd += 0.7282 * 0.0025 = 0.00182` and `zd += 0.00105` that tick. A pale oak leaf has swirl period `radians(1000 + f * 3000)` radians (for f = 0.5 about 43.63); at `lifetime` 0 (t = 1) the wind is `dx = 1 * cos(period) * 10`, `dz = 1 * sin(period) * 10`; tests compute the cosine with their own library.

**Example 7: a firefly's alpha and light.** At `age / lifetime = 0.25`: alpha `0.25/0.5 = 0.5`; at 0.6: 1.0; at 0.85: `(1 - 0.85)/0.3 = 0.5`. Light at progress 0.05 (with partial 0): `0.05/0.3 = 0.1667` and `(int)(255 * 0.1667) = 42`; at progress 0.95: `(1 - 0.95)/0.1 = 0.5`, `(int)(127.5) = 127`; between 0.3 and 0.9: 255.

**Example 8: a snowflake.** r-draws (lifetime) 0.5: `(int)(16/0.6) + 2 = 28`; per tick `yd -= 0.009`, then after the move `xd *= 0.95`, `yd *= 0.9`, `zd *= 0.95`: starting with `yd = 0`: tick 1: -0.009 then x0.9 = -0.0081; tick 2: -0.0171 then -0.01539.

**Example 9: wax on.** Face event on a block: for the up face (step (0, 1, 0)): the horizontal offsets are uniform in [-0.5, 0.5] and y is `+0.55`; the speed supplier gives (sx, sy, sz) each in [-0.5, 0.5], but only the in-plane components (x and z) are passed (y is replaced by 0 because the step on y is nonzero). The particle's velocity is `(sx * 0.01 / 2, 0, sz * 0.01 / 2)`, so at most 0.0025 blocks per tick; lifetime 10 to 39; its block light rises from the cell value to 240 over the life.

**Example 10: ambient ash in a soul sand valley.** p = 0.00625: the probability that a sampled air cell spawns an ash particle is 0.625% (`nextFloat <= 0.00625`); the particle's own spawn: position anywhere in the cell, velocity zero before the burst.

## 17. Validation

An implementation of this part passes when it reproduces, with injected draws, the following checks (each derives from a number read above).

1. **Break burst counts:** a full cube gives exactly 64 terrain particles; a slab 32; a thin box (width 0.25) gives at least 2 per axis; air, `barrier` and `structure_void` give 0.
2. **Terrain colour:** a grass-top block gives colour (0.6, 0.6, 0.6) (tint -1 for terrain particles); a block with no tint gives 0.6; a tinted block with `c = 0xFF80C040` gives (0.6 * 128/255, 0.6 * 192/255, 0.6 * 64/255).
3. **Quarter window:** with `uo = 1.5`, `vo = 0.5` the window is `u in [0.375, 0.625]`, `v in [0.125, 0.375]` of the sprite, with `U0 = getU(0.625)` and `U1 = getU(0.375)` (so `U0 > U1`).
4. **Crumble and pillar:** `block_crumble` speed is exactly 0 and lifetime in [1, 10]; `dust_pillar` lifetime in [20, 39] and `yd` has the added `g/2` term.
5. **Marker:** quad size is constantly 0.5 and lifetime 80; the marker target is only set in creative mode with barrier or light in the hand.
6. **Dust:** lifetime formula with the double draw and the scale; the three channel draws are independent; the transition colour at `age = 0, partial = 0` is `from` and moves linearly to `to` with `t = (age + partial)/(lifetime + 1)`.
7. **Falling dust:** zero horizontal velocity, `yd` is never below -0.14, the roll is reset while on the ground, the lifetime of Example 5.
8. **Item particles:** a velocity-constructor particle (`item`) has the burst scaled by 0.1 plus the supplied velocity; `item_slime`, `item_cobweb`, `item_snowball`, `sulfur_cube_goo` ignore the supplied velocity and use the full burst.
9. **Leaves:** the table of 8.2 (derived gravity 0.00075 and 0.00021, sizes, initial `yd`), the removal rule of 42-1 §8.4, the azalea fixed colour 112, 146, 45 and the chances of 8.4 (cherry 0.1, pale oak 0.02, others 0.01, including mangrove, which is tinted like oak; spruce emits nothing).
10. **Ash:** `ash` colour grey in [0, 0.5], lifetime 20 to 100, `yd` sign inverted by the -0.1 multiplier; `white_ash` colour exactly (186, 177, 194)/255 and the add-on ranges of §9.
11. **Suspended:** `mycelium` and `egg_crack` pass through unchanged velocity into the burst, are removed on the tick where the old `lifetime <= 0`, and never collide; `egg_crack` is white; `spore_blossom_air` lifetime in [500, 1000], gravity 0.01, limit 1000.
12. **Snowflake:** the drag after the move (0.95, 0.9, 0.95), gravity 0.225, colour (0.923, 0.964, 0.999), lifetime in [18, 82].
13. **Firefly:** alpha is 0 at creation, fades in over 50% and out over 30%, light is `(int)(255 * f)`, removal when the block at the position is not air, and the new velocity draw rule (> 0.95 or age 1).
14. **Glow family:** velocities of 13.2, lifetimes (spark 2 to 3, wax and scrape 10 to 39, glow squid 8 to 40), the light formula (rises to 240).
15. **Ambient:** an entry spawns when `nextFloat <= probability`, only in non-full-collision cells, with a zero velocity and a uniform position in the cell; the animate tick samples 667 positions at radius 16 and 667 at radius 32 per client tick.

## Open questions

1. `FallingDustParticle` fallback colour: `getMapColor(level, pos).col` (used when a block is neither a `FallingBlock` nor tinted) was not followed into `MapColor`; the map colour table is outside this round.
2. `Block.animateTick` bodies are the per-block emitters of 42-6; this part states only that `doAnimateTick` calls them first and where the marker and ambient steps sit relative to them. The `FallingBlock` and `BrushableBlock` emissions were read here (§5); the mycelium, snowflake, firefly, spore blossom, creaking, glow squid, slime and similar emitters were not read here (15.1 lists them).
3. The rule `Transparency.hasTranslucent()` deciding opaque against translucent layers for terrain and item particles: only its use was read (42-1 Open question 4).
4. The sprite counts and any animated sprite behaviour of the particle definitions are data (42-1 §2, §6); the age-indexed selection is described but a definition with more than one sprite for `ash`, `glow` and the other single-sprite types was not inspected.
5. Example 6 leaves the numeric cosine of the pale oak swirl phase to the implementation; only the formula (42-1 §8.4) is claimed.
6. A `falling_dust` particle for a `BrushableBlock` state: `BrushableBlock` extends `BaseEntityBlock` and implements `Fallable`, so it never takes the `FallingBlock.getDustColor` branch (read); it takes the tint-source or map-colour branch of §5. Whether those two blocks have a tint source was not searched in the artifact, nor their map colours.
7. The particle material of each layer of an item model (what `pickParticleMaterial` returns) is data of the item model definitions (14); the selection rule itself is read (§7.2).
8. `LevelEventHandler.levelEvent` has exactly 89 case labels; 42-7 §8 states 83 handled ids. Ids 3002, 3003, 3004, 3005 and 3009 were verified to map to the stated handlers and counts (3 to 5 per face for wax on, wax off, scrape and the electric-spark fallback; 3 to 6 for egg crack; 10 to 19 along an axis with spread 0.125 for 3002 when 0 <= d < 3). The 89 against 83 count difference (labels against distinct bodies) was not reconciled.
9. Statements derived by arithmetic or by symmetry and not read as constants, tagged "(inferred)" in the text: the `spore_blossom_air` initial vertical speed range (§10.2), the hit-crack velocity bound (§3.7), the widened value of 0.6f in §3.7, and the derived totals of §14 (expected spawns per tick), §3.6 and the worked examples.
10. The attribute layering of `AMBIENT_PARTICLES` (biome, dimension, weather, time layers, 44 / the environment-attribute document) was not read; the four biome entries are all that the shipped data sets (searched: every data file of the jar for `ambient_particles`). Class-side users of the attribute other than `ClientLevel.doAnimateTick` were not searched exhaustively (a text search of the extracted classes for the constant name returned no hit, which is not conclusive).
11. Part ownership: the counts of 42-1 §2 (27 types) and this document (33 types) disagree as described in the Scope decisions; 42-1 should be reconciled. This document does not edit 42-1.
