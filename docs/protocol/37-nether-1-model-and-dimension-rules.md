# 37-1 The Nether: shared model and dimension rules

| Item | Value |
|---|---|
| Covers | Part 1 of the Nether round (RS21, GAP-13a of [../design/README.md](../design/README.md)): the reading conventions and table schemas shared by parts 2 to 6, id and name assignment, a glossary, the cross-reference map, the delegation list, and the Nether **dimension type** with every dimension-driven behaviour (water, lava, fire, beds and anchors, light, time, maps, spawn, portal scaling, border, generator wiring) |
| Does not cover | Part 2 noise router and terrain, part 3 biomes and the climate preset, part 4 surface rules and carvers, part 5 features by biome, part 6 structure hooks and mob spawns (siblings 37-2 to 37-6). Portals (RS23), structures (GAP-12b) and the End ([38-end.md](38-end.md)) are cross-referenced only |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `DimensionType`, `DimensionTypes`, `EnvironmentAttributes`, `MultiNoiseBiomeSourceParameterList$Preset$1` and the consumer classes named per row, and of the JSON under `data/minecraft/` in the jar (`dimension_type`, `worldgen/noise_settings/nether.json`, `worldgen/world_preset/normal.json`, `tags/block/infiniburn_*`, `tags/timeline`). No execution. Examples marked "(computed)" are arithmetic from the text, not observed |
| Operator decisions | Standard Minecraft content is the target; the extraction tool supplies data rows (22, 23); engines and code-defined content are specified completely (ticket CC-0001, Decisions "World scope", "Vanilla assets and data") |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction, "(recalled, not verified)" a
statement not read; both are listed in the Open questions. Section references "NN section" are to documents in this directory.

---

## 1. What the Nether is in this version

The Nether is an ordinary noise-generated dimension (read in `worldgen/world_preset/normal.json`): level key `minecraft:the_nether`, dimension type
`minecraft:the_nether`, generator `minecraft:noise`, biome source `multi_noise` with preset `minecraft:nether`, noise settings `minecraft:nether`.
Everything that older versions stored as dimension-type flags such as "ultra warm" is, in 26.3, an **environment attribute** of the dimension type
(`attributes` map, 04 section dimension_type, 23 section on attributes). There is **no** `ultra_warm`, `natural`, `piglin_safe`, `bed_works`,
`respawn_anchor_works` (as a flag), `has_raids` or `effects` field in the dimension type of this artifact; the record fields are exactly those of
04 (`has_fixed_time`, `has_skylight`, `has_ceiling`, `has_ender_dragon_fight`, `coordinate_scale`, `min_y`, `height`, `logical_height`, `infiniburn`,
`ambient_light`, monster settings, `skybox`, `cardinal_light`, `attributes`, `timelines`, `default_clock`). Any older document wording that names an
"ultra warm" flag means the attribute rows of section 3.2.

The dimension-type JSON files equal what `DimensionTypes.bootstrap` builds in code (the constants below were read in both places and agree), so a
data pack that ships the JSON and an implementation that builds the same values are interchangeable.

---

## 2. The dimension type `minecraft:the_nether` (`data/minecraft/dimension_type/the_nether.json`)

### 2.1 Scalar fields

| Field | Nether | Overworld | End | Meaning for the Nether |
|---|---|---|---|---|
| `coordinate_scale` | **8.0** | 1.0 | 1.0 | portal travel multiplies or divides x and z (section 6.3); a command source that changes level scales its position the same way (`CommandSourceStack.withLevel`, section 6.3); no other reader found |
| `has_skylight` | **false** | true | true | no sky light engine, no sky light stored (32 section 1.1) |
| `has_ceiling` | **true** | false | false | no weather (32), map pixel rule (section 6.4), spawn-height search (section 6.5), respawn search |
| `has_fixed_time` | **true** | false | true | `isBrightOutside` and `isDarkOutside` both false (33 section 3.5) |
| `has_ender_dragon_fight` | false | false | true | read by the `ServerLevel` constructor only; the Nether never creates a fight (38) |
| `min_y` | 0 | -64 | 0 | |
| `height` | 256 | 384 | 256 | block y 0 to 255; 16 sections |
| `logical_height` | **128** | 384 | 256 | the playable height: portals, chorus-style random teleport (section 6.6); the bedrock roof is a ragged band at the top of the 128-high noise range, not a flat layer (section 6.9, bedrock rules) |
| `infiniburn` | `#minecraft:infiniburn_nether` | `#minecraft:infiniburn_overworld` | `#minecraft:infiniburn_end` | tag contents in section 4.1 |
| `ambient_light` | 0.1 | 0.0 | 0.25 | brightness curve (section 5.2) |
| `monster_spawn_light_level` | constant 7 | uniform 0..7 | constant 15 | spawn light test (18 section 6.8) |
| `monster_spawn_block_light_limit` | 15 | 0 | 0 | |
| `skybox` | `none` | `overworld` | `end` | no sky dome is drawn (12 section on sky) |
| `cardinal_light` | `nether` | `default` | `default` | face shading table (12 section 1; Nether: down and up 0.9, north and south 0.8, west and east 0.6) |
| `default_clock` | absent | `minecraft:overworld` | `minecraft:the_end` | the Nether has no default clock (section 5.3) |
| `timelines` | `#minecraft:in_nether` | `#minecraft:in_overworld` | `#minecraft:in_end` | `in_nether` holds only `#minecraft:universal`; `universal` supplies the `villager_schedule` timeline (33 section 3.4) |

Constructor checks (`DimensionType` constructor, read): `height >= 16`, `min_y + height <= MAX_Y + 1` (2032), `logical_height <= height`, `height`
a multiple of 16, `min_y` a multiple of 16. The Nether values pass all five (256, 0, 128). Note the derived constants of 10 section 5.

Codec ranges (read in `DimensionType`): `coordinate_scale` is a double range from 9.999999747378752E-6 (the float 1.0E-5 widened to double) to 3.0E7;
`min_y` is an int range `MIN_Y` to `MAX_Y`; `height` is 16 to `Y_SIZE`; `logical_height` is 0 to `Y_SIZE`. The constants were read in the static
initialisers: `BlockPos.PACKED_HORIZONTAL_LENGTH` = 1 + log2(smallest power of two not below 30000000) = 1 + 25 = 26, `PACKED_Y_LENGTH` = 64 - 2 x 26 = 12,
`Y_SIZE` = (1 shl 12) - 32 = 4064, `MAX_Y` = (Y_SIZE shr 1) - 1 = 2031, `MIN_Y` = MAX_Y - Y_SIZE + 1 = -2032, so `MAX_Y + 1` = 2032 (computed from the
bytecode arithmetic; the log2 step of 30000000 giving 25 is computed, not executed). Allowed `min_y` is therefore -2032 to 2031.

### 2.2 Attribute map (the `attributes` object, read from the JSON and from `DimensionTypes.bootstrap`)

| Attribute | Nether value | Default when unset (read in the `EnvironmentAttributes` static initialiser) | Consumer section |
|---|---|---|---|
| `gameplay/bed_rule` | `can_set_spawn never`, `can_sleep never`, `destroy_on_use true` | not read | 3.6 |
| `gameplay/straw_bed_rule` | the same three values | not read | 3.6 |
| `gameplay/can_start_raid` | false | true | 3.8 |
| `gameplay/fast_lava` | true | false (registered not positional, so read as a dimension-wide value) | 3.3 |
| `gameplay/piglins_zombify` | false | true | 3.7 |
| `gameplay/respawn_anchor_works` | true | false | 3.6 |
| `gameplay/sky_light_level` | 4.0 | not read | 5.1 |
| `gameplay/snow_golem_melts` | true | false | 3.9 |
| `gameplay/water_evaporates` | true | false | 3.1 |
| `visual/ambient_light_color` | `#302821` | not read | 5.4, 12 |
| `visual/default_dripstone_particle` | `{type: dripping_dripstone_lava}` | not read | 3.10 |
| `visual/fog_start_distance` | 10.0 | 0.0 | 5.4, 12 |
| `visual/fog_end_distance` | 96.0 | 1024.0 | 5.4, 12 |
| `visual/sky_light_color` | `#7a7aff` (the constant `Timelines.NIGHT_SKY_LIGHT_COLOR`) | not read | 12 |
| `visual/sky_light_factor` | 0.0 | not read | 12 |

Defaults of the attributes the Nether leaves unset (read in the same initialiser): `gameplay/nether_portal_spawns_piglin` false,
`gameplay/increased_fire_burnout` false.

Attributes the Nether does **not** set (so the attribute default or a biome or timeline layer applies): `gameplay/nether_portal_spawns_piglin` (the
overworld and caves types set it true, the Nether does not, so it is the default false there), `increased_fire_burnout` (set by biomes, not by this
type), `visual/fog_color`, `visual/sky_color`, cloud attributes, `audio/*` (the Nether biomes carry their music and ambience, part 3). Differences
from the other types: the Nether has no `default_clock`, no cloud attributes and no `ambient_sounds`/`background_music` at dimension level.
The JSON key order in the file is alphabetical; the bootstrap code adds them in the order fog start, fog end, sky light colour, sky light level, sky
light factor, ambient light colour, dripstone particle, bed rules, anchor, evaporation, fast lava, zombify, raid, snow golem (order is not significant:
the map is a set of keys).

The attribute system that combines these with biome, timeline and weather layers is 33 section 3.4 and 23; the Nether adds only the dimension layer
plus `universal` timeline layers and the biome layers of part 3 (no weather layer: `canHaveWeather` is false, section 5.5).

---

## 3. Dimension-driven behaviours

For each behaviour: the attribute or flag, the jar class where it is read, and the owning document where the full rule is. Rows marked "read here"
are specified in this section; the others are indexed so that an implementer finds one place.

### 3.1 Water evaporates (`gameplay/water_evaporates`, positional)

| Where | Rule | Owner |
|---|---|---|
| `BucketItem.emptyContents` | for a water bucket (fluid in tag `water`) the position `T` is sampled; when true no water is placed, `fire.extinguish` plays (volume 0.5, pitch `2.6 + (r1 - r2) x 0.8`), a server sends 8 `large_smoke` particles, the bucket is spent. The particle call (read): position the block x, y, z as integer corner coordinates (not centred), count 8, spread 1.0 on each of x, y and z, speed 0.0, randomization type `ALTERNATIVE`; the sound source is `BLOCKS`; the two random floats are consecutive `nextFloat` calls on the level random. Order of the checks in `BucketItem.emptyContents`: (1) the replaceability test of the target cell, (2) the air/replaceable gate, (3) the `water_evaporates` read, (4) otherwise the placement | 25-5 section buckets, 29a section 7.2, 42-3 |
| `IceBlock.melt`, `IceBlock.playerDestroy` | removed instead of becoming water | 29b-3 section on ice |
| `WetSpongeBlock.onPlace` | becomes `sponge`, level event 2009, sound `wet_sponge_dries` | 29b-3 section on sponge |
| `PointedDripstoneBlock.getFluidAboveStalactite` | the mud-above-root rule yields water only when the attribute is **false** | 29b-6, 29b-7 |
| `FrostedIceBlock` melt | no class of its own reads the attribute: `FrostedIceBlock` extends `IceBlock` and inherits the `IceBlock.melt` rule (removal instead of water) | 29b-3 |

The attribute is positional (`EnvironmentAttributeSystem.getValue(attribute, BlockPos)` in `BucketItem`): a biome layer may override it. None of the vanilla Nether biomes does: `NetherBiomes` has no reference to `water_evaporates`, `snow_golem_melts` or `increased_fire_burnout` (only `DimensionTypes` and `OverworldBiomes` set them), and the five Nether biome JSON files (`worldgen/biome/`) carry only the attribute keys `audio/ambient_sounds`, `audio/background_music`, `gameplay/natural_mob_spawns`, `visual/fog_color` and (not in `nether_wastes`) `visual/ambient_particles`. A cell in the Nether
therefore always evaporates water. Water can still exist in the Nether from other sources that do not consult the attribute: world generation fluids
(the default fluid is lava), commands, flowing water entering from `setblock`, cauldrons and potions. Whether such water flows is the fluid engine
of 29a and is not restricted by the attribute (the attribute is not read by `WaterFluid`: the classes that reference `EnvironmentAttributes.WATER_EVAPORATES` are `BucketItem`, `IceBlock` (inherited by `FrostedIceBlock`),
`WetSpongeBlock`, `PointedDripstoneBlock`, `DimensionTypes` and `EnvironmentAttributes` itself).

### 3.2 Powder snow, snow and cauldron rain

No attribute: precipitation is biome-driven and there is no weather in the Nether (section 5.5). Snow layers and ice melt by block light (29b-3).

### 3.3 Fast lava (`gameplay/fast_lava`, dimension-wide value)

Read through `getDimensionValue`, never positionally, at two places. Classes referencing `EnvironmentAttributes.FAST_LAVA`: `Entity`, `LavaFluid`, `DimensionTypes`.

1. `LavaFluid` through `isFastLava` (three methods, `getTickDelay`, `getSlopeFindDistance`, `getDropOff`):

   | Value | fast lava true | false |
   |---|---|---|
   | tick delay | 10 | 30 |
   | slope-find distance | 4 | 2 |
   | drop-off | 1 | 2 |

   `LavaFluid` also has `getSpreadDelay` (the base tick delay, multiplied by 4 when both states are non-empty, neither is falling, the new state is higher
   and `nextInt(4)` is not 0) and a random tick with a flammable-neighbour fire rule (`hasFlammableNeighbours`); both are specified in 29a section 2.2
   and section 4.1 and are not repeated here. Flow reach in rings: a source has amount 8, each ring loses the drop-off, so fast lava reaches
   7 rings (amounts 7 down to 1) and normal lava 3 (amounts 6, 4, 2); this is arithmetic from the table (computed), as in 29a example E5.
2. `Entity.updateFluidInteraction`: an entity in lava that is pushed by fluids receives the lava current with strength **0.007** when the value is true
   and **0.0023333333333333335** (0.007 / 3) otherwise; the water current strength is 0.014 in both. Also in 29a.

Worked example (computed): a non-flying entity standing in a lava current with flow vector of length 1 gets `0.007` added per tick in the Nether and
`0.0023333` in the overworld.

### 3.4 Fire, soul fire and infiniburn

| Rule | Where | Value |
|---|---|---|
| fire above an `infiniburn` block never burns out by age | `FireBlock.tick` reads `level.dimensionType().infiniburn()` and tests the block below | the tag `infiniburn_nether` is `#minecraft:infiniburn_overworld`, which is `netherrack` and `magma_block` (read from the tag files) |
| `increased_fire_burnout` (positional) | `FireBlock.tick`, per biome | not set by the dimension type nor by any Nether biome (section 3.1 data check), so the attribute default false applies in the Nether; the value is read as `getValue(attribute, BlockPos)`; classes referencing it: `FireBlock`, `OverworldBiomes` |
| soul fire | block rules and placement: 29b-8 | same infiniburn rule (the check is on the block below, not on the fire kind, inferred from the single call site) |

Consequence: in the End the same tag plus `bedrock` burns forever. Full fire spreading, ageing and the portal-lighting hook are 29b-8 (the hook
that calls `PortalShape.findEmptyPortalShape` in the Overworld or the Nether is 29b-8 and RS23).

### 3.5 Light and brightness

The Nether has no sky engine; block light works as everywhere (32). The brightness curve is `f + ambient_light x (1 - f)` with `f = r / (4 - 3r)`,
`r = level / 15` (32 section 1.2). With `ambient_light` 0.1 and level 0: `0.1`; level 15: `1.0`; level 7 (computed): `r = 0.4667`,
`f = 0.4667 / 2.6 = 0.17949`, result `0.17949 + 0.1 x 0.82051 = 0.26154`. The lightmap colours (`#302821` ambient, sky factor 0) are 12.

### 3.6 Beds and respawn anchors

| Attribute | Behaviour | Owner |
|---|---|---|
| `bed_rule` and `straw_bed_rule` with `can_set_spawn never`, `can_sleep never`, `destroy_on_use true` | using a bed: no message, the bed explodes. The explosion parameters are those of the bed block explosion (33 section 5.2 and the block-explosion rules of 33 section 8.3; 33 section 5.3 is the sleep counter and waking) | 33 section 5, 17 section 4.10 |
| `respawn_anchor_works` true | `RespawnAnchorBlock.canSetSpawn(level, pos)` is true; a charged anchor sets the respawn point and in the Overworld or the End (attribute false) it explodes instead | 17 section 4.10, 33 section 6 |

The attribute is read through the positional system (default false); the overworld, caves and End types set `respawn_anchor_works` false. Classes referencing `RESPAWN_ANCHOR_WORKS`: `RespawnAnchorBlock`, `DimensionTypes`.

### 3.7 Piglins and hoglins (`gameplay/piglins_zombify`)

Value false in the Nether, so `AbstractPiglin.isConverting` and `Hoglin.isConverting` never start the zombification timer there. Default true
(section 2.2), so elsewhere the timer starts. Both methods behave the same way:

1. The mob is converting only when it is not immune to zombification, does not have no-AI, and
2. the attribute `piglins_zombify` read **positionally at the mob's `Vec3` position** (`EnvironmentAttributeSystem.getValue(attribute, Vec3)`) is true.

The conversion timer, immunity and the result are 21 section on piglins and 44-6.

### 3.8 Raids (`gameplay/can_start_raid`)

False (default true): `Raids.createOrExtendRaid` returns without creating a raid (33 section 3.4). Classes referencing `CAN_START_RAID`: `Raids`, `DimensionTypes`.

### 3.9 Snow golems (`gameplay/snow_golem_melts`, positional on the entity position)

`SnowGolem.aiStep` (server side), every tick:

1. If `snow_golem_melts` read positionally at the golem's `Vec3` position is true, the golem takes 1.0 damage of type `on_fire` (the hurt window of
   17 section 4.7 limits how often it lands).
2. If the rule `mob_griefing` is false, stop. Otherwise try the four cells of the table below, in order, using the golem's position `(gx, gy, gz)`:

   | i | x cell | y cell | z cell |
   |---|---|---|---|
   | 0 | floor(gx - 0.25) | floor(gy) | floor(gz - 0.25) |
   | 1 | floor(gx + 0.25) | floor(gy) | floor(gz - 0.25) |
   | 2 | floor(gx - 0.25) | floor(gy) | floor(gz + 0.25) |
   | 3 | floor(gx + 0.25) | floor(gy) | floor(gz + 0.25) |

3. For each cell: when it is air and the `snow` default state can survive there, set it (with a block update) and fire game event `block_place`.

The snow trail runs even when the golem melts. `DimensionTypes` sets the attribute true for the Nether dimension type; of the biome factories only the `OverworldBiomes` desert, savanna and badlands
set it (classes referencing `SNOW_GOLEM_MELTS`: `SnowGolem`, `DimensionTypes`, `OverworldBiomes`). The Nether therefore gets it from the dimension type, not from a biome factory, and no Nether biome overrides it (section 3.1), so a golem in the
Nether melts, as does one in those three overworld biomes.

### 3.10 Dripstone particle (`visual/default_dripstone_particle`)

The Nether value is a dripping-lava particle: `PointedDripstoneBlock.getDripParticle` falls back to it when the fluid above is empty
(42-3, 42-6). Particles are client side.

### 3.11 Other consumers of the dimension type (index)

| Field | All callers found (jar search) | Rule |
|---|---|---|
| `has_skylight` | `ClientChunkCache` ctor, `ChunkMap` ctor, `Level.canHaveWeather`, `DaylightDetectorBlock.getTicker`, `PhantomSpawner.tick`, `SerializableChunkData.read` | engines (32), weather, phantoms (no spawn), daylight detector has no ticker effect (inferred from the gated `getTicker`), stored sky layers ignored |
| `has_ceiling` | `Level.canHaveWeather`, `MapItem.update`, `NaturalSpawner.getTopNonCollidingPos`, `PlayerSpawnFinder.getLevelRespawnPos` | sections 5.5, 6.4, 6.5 |
| `has_fixed_time` | `Level.isBrightOutside`, `Level.isDarkOutside` | 33 section 3.5 |
| `logical_height` | `ServerLevel.getLogicalHeight` (called by `TeleportRandomlyConsumeEffect.apply` and `PortalForcer.createPortal`) | section 6.6 |
| `coordinate_scale` | `DimensionType.getTeleportationScale`, called by `NetherPortalBlock.getPortalDestination` and by `CommandSourceStack.withLevel` | section 6.3 |
| `infiniburn` | `FireBlock.tick` | section 3.4 |
| `ambient_light` | `LevelReader.getLightLevelDependentMagicValue`, `Lightmap.getBrightness` | section 3.5 |
| `has_ender_dragon_fight` | `ServerLevel` constructor | 38 |
| `monster_spawn_*` | `Monster.isDarkEnoughToSpawn` | 18 section 6.8 |
| `skybox`, `cardinal_light` | `SkyRenderer`, `ClientLevel.cardinalLighting` | 12 |

---

## 4. Tags the dimension type names

### 4.1 `infiniburn_nether`

`data/minecraft/tags/block/infiniburn_nether.json` is `{"values": ["#minecraft:infiniburn_overworld"]}`; `infiniburn_overworld` holds `netherrack`
and `magma_block`; `infiniburn_end` holds `#minecraft:infiniburn_overworld` and `bedrock`.

### 4.2 Timelines

`tags/timeline/in_nether.json` is `{"values": ["#minecraft:universal"]}`; the sibling tags are `in_end`, `in_overworld`, `universal`
(four files in the folder). The Nether clock rules are section 5.3.

---

## 5. Time, sky, weather, clocks and fog in the Nether

### 5.1 Sky light level 4.0

`gameplay/sky_light_level` 4.0 gives `skyDarken = (int)(15.0f - 4.0f) = 11` every tick (33 section 3.5). It has no visible effect: the dimension has no sky
layer, fixed time makes both outside-predicates false, and `getEffectiveSkyBrightness` of a position with sky level 0 is `max(0, 0 - 11) = 0`.

### 5.2 Brightness

Section 3.5.

### 5.3 Clocks

The Nether has no `default_clock`, so `Level.getDefaultClockTime` has no clock to read. Its only caller found is `ClientLevel.tick`. What that
method returns without a default clock (0 inferred) and what the client does with it is Open question 5. Moon phase, day timeline and sleeping are
not driven here; the world clock `minecraft:overworld` still ticks by the server rule 33 section 3.2.

### 5.4 Fog

`fog_start_distance` 10 and `fog_end_distance` 96 are the Nether's fog attributes (12 section 3.3 gives the renderer fog rule; 12 section 3.4 is the sky drawing order; the fog colour comes from
the biome layer, part 3).

### 5.5 Weather

`Level.canHaveWeather` = `has_skylight` and not `has_ceiling` and key is not the End (32 section 1.1): false. No rain, snow, thunder or lightning
in the Nether; cauldrons never fill from weather (29b-7).

---

## 6. Other dimension rules

### 6.1 Spawning and mobs by dimension

`monster_spawn_light_level` constant 7 and block-light limit 15: the spawn test of 18 section 6.8 uses these two numbers. Mob lists per Nether biome and
the fortress and bastion lists are part 6.

### 6.2 Piglin-safe, natural and compass

None of these exist as dimension flags in this artifact (section 1). Compasses and the recovery compass use the target dimension key of the
item and not a dimension flag; see 25 for the item components. (Whether a plain compass spins randomly outside the Overworld is an item-model rule
of the client; Open question 6.)

### 6.3 Portal coordinate scaling

`DimensionType.getTeleportationScale(from, to) = from.coordinate_scale / to.coordinate_scale` (a double division). In `NetherPortalBlock.getPortalDestination`
(read): the destination level is the Nether when the source is the Overworld, the Overworld when the source is the Nether, otherwise no destination;
the scaled entry position is the entity position clamped by the **destination level's world border** (`WorldBorder.clampToBounds(x x scale, y, z x scale)` with
the destination border) and the exit-portal search follows (RS23, planned document `39-portals`, not yet present).

| From | To | Scale | Example (computed) |
|---|---|---|---|
| Overworld (1.0) | Nether (8.0) | 1.0 / 8.0 = 0.125 | (800, 64, -160) becomes x 100, z -20 |
| Nether | Overworld | 8.0 / 1.0 = 8.0 | (100, 70, -20) becomes x 800, z -160 |

`CommandSourceStack.withLevel(level)` (read) is a second caller. When the new level is the same object it returns the source unchanged; otherwise it
computes `scale = getTeleportationScale(old type, new type)` and builds a source whose world position is `(x x scale, y, z x scale)` (y unchanged, no
border clamp); everything else is copied. The `/execute in` family presumably uses it (the command wiring was not traced; inferred). Example (computed):
a source at (800, 64, -160) moved from the Overworld to the Nether is at (100, 64, -20); the reverse multiplies by 8.

The `lunge` enchantment effect does not read `coordinate_scale`: `ApplyEntityImpulse` has its own `coordinateScale` vector field, a per-effect parameter,
and the only other class with a field or string of that name is `DimensionType`.

### 6.4 Maps

`MapItem.update` (read): the update runs only when the level key equals the map's dimension key. The window half-extent is `r = 128 / (1 shl map scale)`
(integer division); with `has_ceiling` true it is halved again (integer division). The scan covers pixel columns and rows from the player's pixel minus `r`
plus 1 (read) up to the player's pixel plus `r` (the standard upper bound, not re-read). In the ceiling case each pixel does not read the surface: the hash
input is the **pixel loop coordinates** `x` and `z`, not world coordinates: `h = x + z x 231871`, then `h = h x h x 31287121 + h x 11` (32-bit wrap).
When bit 20 of `h` is 0 the colour of `dirt` is added to the pixel's multiset with weight 10, otherwise the colour of `stone` with weight 100; the
shade value for the pixel is set to 100.0 on this path (constants read). Worked example: 25-5 example 9. A Nether map therefore shows noise, never terrain.

### 6.5 World spawn and respawn

`PlayerSpawnFinder.getLevelRespawnPos` (read): with `has_ceiling` the search column height comes from `ChunkGenerator.getSpawnHeight`, otherwise from
the `MOTION_BLOCKING` heightmap; then the loop scans from `minY` upward over `WORLD_SURFACE` / `OCEAN_FLOOR`
heights looking for a cell with an empty fluid and a full upper face. `NaturalSpawner.getTopNonCollidingPos` (read): with a ceiling the
start position is moved **down** while the cell is air and then again while it is not, so the result is the highest floor under the ceiling
column (18 section 6). The nether noise settings have `spawn_target` empty (section 7), so the noise spawn finder of 33 section 6.3 yields
the generator origin. Players cannot sleep or set spawn in the Nether without an anchor (section 3.6).

### 6.6 Logical height

`ServerLevel.getLogicalHeight` returns `logical_height` (128 in the Nether). It is the upper limit for the random-teleport consume effect
(chorus fruit) and for `PortalForcer.createPortal`; the buildable height stays 256 (`height`). What fills the cells above the 128-high noise range is not stated by any file read (the material rule only places bedrock in the bands of section 6.9, netherrack from the `y_above below_top 5` rule inside the noise range, and biome-specific blocks); (inferred) they stay air; Open question 14.

### 6.7 World border

Each level owns its own border data (33 section 7); there is no scaling between the Overworld and Nether borders in 26.3: the only coordinate
scaling read is the portal clamp of section 6.3. A `worldborder` command affects the level it runs in.

### 6.8 Storage

`DimensionType.getStorageFolder(levelKey, root)` returns `<root>/dimensions/<namespace>/<path>` (read): the Nether data lives in
`dimensions/minecraft/the_nether` (07 section 9 for the folder layout, `DIM-1` is the legacy name, recalled, not verified).

### 6.9 Generator wiring of the nether level stem

| Piece | Value (read) |
|---|---|
| level stem | type `the_nether`, generator `noise` with `NoiseBasedChunkGenerator` |
| biome source | `multi_noise`, preset `minecraft:nether` (`multi_noise_biome_source_parameter_list/nether.json` is `{"preset": "minecraft:nether"}`) |
| noise settings | `minecraft:nether`: `sea_level` 32, `noise.min_y` 0, `noise.height` 128, `default_block` `netherrack`, `default_fluid` `lava`, `legacy_random_source` **true** (the legacy generator, 10 section 2.6), `disable_mob_generation` false, `material_rule` `minecraft:nether`, `spawn_target` empty, no `aquifers` field, `ore_veins_enabled` not present |
| router | eight keys (part 2): `final_density`; `temperature` and `vegetation` (the `nether/temperature` and `nether/vegetation` noises, `xz_scale` 0.25, `y_scale` 0.0); `continents`, `erosion`, `depth`, `ridges` and `chunk_surface_level` as constant 0.0. No barrier, floodedness, lava, vein or other aquifer entry |
| `debug_functions` | the file also lists labelled functions N, T, V for the debug screen (data, not behaviour) |

The `noise.height` 128 (with `noise.min_y` 0) is the noise grid, not the dimension height (256). The material rule `minecraft:nether`
(`worldgen/material_rule/nether.json`) is a sequence whose first two entries are the files below, in this order (the later entries, the netherrack
`y_above` rule with anchor `below_top 5` and the `basalt_deltas` and `soul_sand_valley` branches, belong to 37-4):

| Rule file | Condition | Result |
|---|---|---|
| `bedrock_floor` | `vertical_gradient` (random name `minecraft:bedrock_floor`) with `true_at_and_below` = `above_bottom 0` and `false_at_and_above` = `above_bottom 5` | bedrock |
| `bedrock_roof` | NOT of a `vertical_gradient` (random name `minecraft:bedrock_roof`) with `true_at_and_below` = `below_top 5` and `false_at_and_above` = `below_top 0` | bedrock |

Consequences: the floor places bedrock at the bottom anchor (y 0) with certainty and in the four cells above it by a random gradient, decreasing
from certain to never over the five-cell span (exact probability ramp: 10 section 10.4, vertical gradient condition). The roof is the mirror
image, a ragged band at the top of the noise range, with the top cell certain and the cells just below it random; it is not a flat layer from y 127
upward. The anchors resolve against the noise bounds 0 to 128 (inferred, not verified), so the top of the band is at the top of the noise range
and not at the top of the 256-high column. Whether anything is generated above y 128 is Open question 14.

---

## 7. Shared model for parts 2 to 6

### 7.1 Reading conventions

1. Section references use "37-N section S". Numbers are exact: floats are written as read (`0.375`, `0.175`), and doubles are IEEE double.
2. Anything that is data in the jar (JSON) is cited by file path and not tabulated unless it is the only place a value is defined and the engine
   needs it to be reproduced (the five climate points are code, so part 3 tabulates them).
3. Coordinates: block `(x, y, z)`, quart `(x/4, y/4, z/4)`, cell for the noise grid `4 x 8 x 4` (xz 4, y 8 as in the router, read in section 6.9).

### 7.2 Table schemas

| Schema | Columns | Used by | Example (read) |
|---|---|---|---|
| **Climate point row** | `T, H, C, E, D, W` (parameter intervals or points), `offset`, `biome` | part 3 | the preset has 5 rows, all points: nether_wastes (0,0,0,0,0,0, off 0); soul_sand_valley (T 0, H -0.5, off 0); crimson_forest (T 0.4, off 0); warped_forest (T 0, H 0.5, off 0.375); basalt_deltas (T -0.5, off 0.175); unlisted components are 0 (argument order of `Climate.parameters` assumed T, H, C, E, D, W, offset; the T and H labels were not re-read, Open question 15) |
| **Surface-rule row** | `order`, `condition tree` (types of 10 section 10.4), `result` (rule type of 10 section 10.5), `block state` | part 4 | per the material rule `minecraft:nether` |
| **Feature-by-biome row** | `biome`, `decoration step 0..10`, `placed feature id` in list order | part 5 | order rule 11 section 6 and 35-1 section 6 |
| **Carver row** | `carver id`, `biome list`, `probability`, `config` | part 4 | one carver file `worldgen/carver/nether_cave.json` |
| **Structure-hook row** | `structure id`, `biome tag`, `step`, `spawn overrides` | part 6 | four tags under `tags/worldgen/biome/has_structure/` (read): `nether_fortress` = [`#minecraft:is_nether`]; `nether_fossil` = [`soul_sand_valley`]; `ruined_portal_nether` = [`#minecraft:is_nether`]; `bastion_remnant` = [`crimson_forest`, `nether_wastes`, `soul_sand_valley`, `warped_forest`] in that order. The tag `is_nether` lists `nether_wastes`, `soul_sand_valley`, `crimson_forest`, `warped_forest`, `basalt_deltas` in that order |
| **Dimension-rule row** | `attribute or flag`, `value`, `consumer class`, `owner` | this part | section 2.2 and 3 |

Climate fitness is computed with the quantised distance rule of 10 section 7.2 (the Nether uses it unchanged: offset enters squared).

### 7.3 Id and name assignment

The Nether adds no registry of its own. Ids follow 04 section 5.1 and 46. The jar's `dimension_type` folder holds four files, in the listing order
`overworld_caves`, `overworld`, `the_end`, `the_nether`; the wire id order of the dimension type registry is data-pack-load dependent and not read
(Open question 8). Names:
blocks and biomes keep `minecraft:` names (`netherrack`, `nether_wastes`). Level key `minecraft:the_nether` selects `dimensions/minecraft/the_nether`.

### 7.4 Glossary

| Term | Meaning |
|---|---|
| ceiling, roof | the ragged bedrock band at the top of the 128-high noise range (section 6.9) |
| logical height | `logical_height`, the playable height (128) |
| fixed time | `has_fixed_time`: no day cycle for brightness predicates |
| coordinate scale | the multiplier of portal travel (8) |
| fast lava | the attribute that speeds lava (section 3.3) |
| ultra warm | the old name of the group of attributes in section 2.2 (not a field in 26.3) |
| preset | `multi_noise_biome_source_parameter_list` entry that names a code-built parameter list |
| fortress, bastion | Nether structures, part 6 and GAP-12b |

### 7.5 Cross-reference map

| Topic | Owner |
|---|---|
| dimension type codec and field list | 04 section dimension_type, 23 |
| noise settings and router, biomes, surface rules, features, structures of the Nether | 37-2 to 37-6 (files exist alongside this one) |
| noise primitives, density nodes, climate sampling, legacy random | 10 sections 2 to 4, 7 |
| surface rule condition and rule types | 10 section 10 |
| carvers, decoration order, ore | 11 |
| features and placement modifiers | 35-1 to 35-7 (Nether features: 35-7) |
| structures | GAP-12b (36-structures-1-model-placement-starts.md; later 36 parts planned) |
| light, brightness | 32 |
| time, border, spawn, sleeping, rules | 33 |
| fluids, fire, growth | 29a, 29b |
| particles | 42 |
| lightmap and sky rendering | 12 |
| portals | RS23 (planned `39-portals`, not yet present) |
| the End | 38-end.md |

### 7.6 Delegated

Part 2: router nodes `nether/base_3d_noise`, `blend_density`, `beardifier`, `squeeze`, `interpolated`, noises `nether/temperature`, `nether/vegetation`.
Part 3: the biome list and the climate rows. Part 4: `minecraft:nether` material rule and the nether cave carver. Part 5: features by biome. Part 6:
structure sets and mob spawn costs. RS23: portal frames, travel, `PortalForcer`.

Items in the artifact for this scope that this part does not cover, to be checked in the siblings (37-2 to 37-6):

- The `final_density` tree, read in `worldgen/noise_settings/nether.json`: `squeeze` of `interpolated` (cell 4 by 8) of `mul` 0.64 of `blend_density` of two nested lerps (y gradient -8 to 24 giving 2.5 first, then y gradient 104 to 128 giving 0.9375 first, then `nether/base_3d_noise`), plus `beardifier`.
- The `nether_cave` carver, read in `worldgen/carver/nether_cave.json`: count `very_biased_to_bottom` 0 to 9, probability 0.2, y uniform from absolute 0 to below_top 1, floor_level -0.7, horizontal and vertical radius multipliers 1.0, room vertical multiplier 0.5, start vertical multiplier 5.0, thickness trapezoid min 0, max 6, plateau 2.
- Per-biome `natural_mob_spawns`, `spawn_costs`, `ambient_particles` and `fog_color` values; the surface rule and feature lists.

## 8. Worked examples (computed)

1. **Portal scaling.** Overworld (-1000, 70, 400) to the Nether: `scale = 1/8`; target `x = -125.0`, `z = 50.0`, clamped to the Nether border, then the exit search.
2. **Brightness.** Block light 0 and 15 in the Nether: 0.1 and 1.0 (section 3.5).
3. **Snow golem.** A golem at (10.5, 70, 3.5) in the Nether: damage 1.0 (`on_fire`) each tick that the hurt window allows; snow cells:
   the x offsets are -0.25, +0.25, -0.25, +0.25 and the z offsets -0.25, -0.25, +0.25, +0.25 for i = 0..3, so every i gives `floor(10.25 or 10.75)` = 10 and
   `floor(3.25 or 3.75)` = 3: all four cells are the same cell (10, 70, 3).
4. **Skylight.** `skyDarken` = 11, effective sky brightness 0.
5. **Lava current.** 0.007 per tick in the Nether.

## 9. Validation (checkable facts)

| # | Check | Expected |
|---|---|---|
| V1 | `the_nether.json` scalars | scale 8.0, ceiling true, skylight false, fixed time true, min_y 0, height 256, logical 128, ambient 0.1, spawn light 7, block light limit 15, skybox none, cardinal_light nether |
| V2 | attribute map | 15 entries as in section 2.2 |
| V3 | infiniburn | resolves to `netherrack`, `magma_block` |
| V4 | `getTeleportationScale` | Overworld to Nether 0.125 |
| V5 | noise settings | sea level 32, height 128, default block netherrack, default fluid lava, legacy random true, spawn_target empty |
| V6 | preset | five points, offsets 0, 0, 0, 0.375, 0.175 in the order nether_wastes, soul_sand_valley, crimson_forest, warped_forest, basalt_deltas |
| V7 | no `ultra_warm` field in the record | the codec has 16 fields |
| V8 | weather | `canHaveWeather` false |

## Open questions

1. Closed: no Nether biome overrides `water_evaporates`, `snow_golem_melts` or `increased_fire_burnout` (searched `NetherBiomes` bytecode and the five biome JSON attribute key lists, section 3.1).
2. Water placed by means other than buckets (commands, flowing sources) is not restricted by the attribute as far as callers show; the exact behaviour
   is 29a's, not re-traced.
3. Closed: `increased_fire_burnout` is not set by any Nether biome nor the dimension type, so it is false (default) in the Nether (section 3.4).
4. Closed: `piglins_zombify` is read positionally with the mob `Vec3` in both `AbstractPiglin.isConverting` and `Hoglin.isConverting` (section 3.7); `snow_golem_melts` is read with the `Vec3` position, `water_evaporates` and `increased_fire_burnout` with a `BlockPos`.
5. `Level.getDefaultClockTime` with no default clock and its use in `ClientLevel.tick` were not traced.
6. Compass behaviour outside the Overworld (item model property) was not traced.
7. The legacy folder name `DIM-1` is (recalled, not verified).
8. The wire id order of `dimension_type` entries (section 7.3) depends on pack order, not read.
9. Closed (section 6.4); only the upper scan bound (player pixel plus `r`) was not re-read.
10. Closed: the snow golem offsets were re-read (section 3.9).
11. The `/execute in` wiring of `CommandSourceStack.withLevel` was not traced (inferred caller).
12. The ring counts of fast and normal lava (7 and 3) are computed from drop-off and source amount, not read as a constant (section 3.3, matching 29a E5).
13. Closed: the `nether_cave` carver and `final_density` values of section 7.6 were read in `worldgen/carver/nether_cave.json` and `noise_settings/nether.json`.
14. What the generator places in the cells of the 256-high column above the 128-high noise range (y 128 to 255), and whether the bedrock anchors
    resolve against the noise bounds rather than the dimension bounds, were not read. Searched: `nether.json` noise settings, the `bedrock_floor`, `bedrock_roof` and `nether` material rule files. The surface-rule evaluator that resolves `above_bottom` and `below_top` was not read in this part.
15. The parameter order (T, H, C, E, D, W, offset) of `Climate.parameters`, and so the T and H labels of the five climate rows (section 7.2), were not re-read; the five rows themselves match the preset code.
