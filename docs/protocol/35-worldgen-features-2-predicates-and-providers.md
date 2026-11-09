# 35 World generation features, part 2: block predicates and block state providers

| Item | Value |
|---|---|
| Covers | The 16 block predicate types (`net.minecraft.world.level.levelgen.blockpredicates.*`): codec shape, offset handling, evaluation semantics, the engine queries each one makes, and the helper constants. The 10 block state provider types (`net.minecraft.world.level.levelgen.feature.stateproviders.*`): codec shape, the exact random draws and their order, `getState` versus `getOptionalState`, the property-identity rule of `rotated`, `randomized_int` and `copy_properties`, and the shared noise setup and seeding of `noise`, `dual_noise` and `noise_threshold`. |
| Does not cover | The feature size rules (`featuresize.*`: `two_layers_feature_size`, `three_layers_feature_size`, minimum size computation, `min_clipped_height`), specified in 35-3 §3 and §2.3 with the tree feature that consumes them. The features, placement modifiers, tree placers and decorators that use predicates and providers (siblings: part 1 framework and placement modifiers, part 3 tree placers, part 4 decorators and vegetation, part 5 water and surface, part 6 underground, part 7 nether, end and misc). The `RuleTest` family of ore and structure targets (`structure.templatesystem`, see section 8). Registry-file loading, tag resolution and `HolderSet` forms (23 §5, §6). The weighted-list, int-provider and height-provider engines (23 §7). The noise primitives (10 §3) and the Java LCG (10 §2.6). Data rows: the 240 configured features, 273 placed features and 8 named provider elements in the pack are extracted by the tool (22), not tabulated. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for bootstrap methods and constant strings) and of the data files under `data/minecraft/` in the jar, with no execution. Worked examples marked "(computed)" were produced by applying this document's text with a throwaway reference script written for the round; they were not observed from the artifact. |
| Round | RS19 (GAP-12a of [../design/README.md](../design/README.md)), scope "Part 2" |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and
"(recalled, not verified)" marks something not read; both are listed in the Open questions. Section references "10 §n",
"11 §n", "23 §n", "24-1 §n" and "29 §n" are to the documents of this directory (24-1 is
`24-block-registry-1-model-and-foundation.md`). Float means IEEE single precision, double means IEEE double precision.

## Contents

1. Reader's map and what the two engines are
2. The environment a predicate or provider sees
3. Block predicates
4. Block state providers
5. Noise-based providers: shared setup and seeding
6. Worked examples
7. Corrections and additions to earlier documents
8. RuleTest helpers (cross-reference)
9. Validation
10. Open questions

---

## 1. Reader's map and what the two engines are

A **block predicate** is a pure test `test(level, origin)` over a position. It reads the world, draws no random number,
and changes nothing. Predicates are data (JSON objects with a `type`), evaluated by the 16 classes of section 3. They
appear in placement modifiers, in feature configs, in `rule_based` providers, in structure processors and in several
helpers.

A **block state provider** is a function `getState(level, random, pos)` that returns the block state to place at `pos`.
It may read the world at `pos`, may consume numbers from the `random` it is given, and (the noise family) owns a private
noise generator that does not use that `random` at all. Providers are data too: 10 `type`s, section 4. A provider may
nest other providers and predicates.

Data versus code (operator decision, design map R7). The set of types, their fields and every draw are code and are
specified here. The configured features, the placed features, the 8 named provider elements
(`worldgen/block_state_provider/*`: `cave_vines_body`, `cave_vines_head`, `flower_flower_forest`, `flower_meadow`,
`flower_plain`, `mangrove_propagule`, `podzol_beneath_tree`, `soil_beneath_tree`) and the tags are rows of the pack.

Where the artifact uses a name for the same idea in two places, this document keeps them apart: `BlockPredicate` here is
the **worldgen** predicate (`levelgen.blockpredicates`), not the loot and advancement `BlockPredicate` of 26 §10.3 (a
different class with fields `blocks`, `state`, `nbt`).

## 2. The environment a predicate or provider sees

| Item | Rule (read) |
|---|---|
| Level argument | `LevelAccessor`. During world generation it is a `WorldGenRegion` (a `WorldGenLevel`); for a feature placed by command or by a game mechanism it is the `ServerLevel`. Both answer the same queries below. |
| Position arithmetic | `BlockPos.offset(Vec3i)` is component-wise addition. `origin` is the position the caller passes: the feature's origin, a scanned position, or the provider's `pos`. |
| `getBlockState(pos)` | Delegates to the chunk at `pos`. A `y` outside the build height (`minY <= y <= maxY`, `maxY = minY + height - 1`) reads as `void_air` (`ProtoChunk.getBlockState`, read: `isOutsideBuildHeight` then `Blocks.VOID_AIR`). A section that has only air reads as the default state of air (read: the `hasOnlyAir` branch returns the default state of `air`). Reads inside a `WorldGenRegion` go through `warnIfReadOutsideWriteZone` (a log warning only, the read still happens; the zone rules are the framework's, sibling part 1). |
| `isInsideBuildHeight(pos)` | `minY <= pos.y <= maxY` of the level (`LevelHeightAccessor`, read). |
| `getBiome(pos)` | The biome holder at the position; the lookup resolution and the generation-status limits are the framework's (sibling part 1). |
| `isUnobstructed(entity, shape)` | Default of `EntityGetter` (the one `CommonLevelAccessor` delegates to): true when the shape is empty; otherwise the entities returned by `getEntities(null, shape.bounds())` are scanned and the answer is false when one of them is not removed, has `blocksBuilding` set, and has a bounding box that intersects the shape (`Shapes.joinIsNotEmpty` with AND). `WorldGenRegion.getEntities` returns the empty list (read), so during generation the answer is always true. On a `ServerLevel` the scan sees real entities. |
| Level queries by block state | `isSolid`, `canBeReplaced`, `isFaceSturdy(.., FULL)` and `canSurvive` are the state queries of 24-1 §5.2 (the `legacySolid` rule and the replaceable flag), §6.6 (support types) and §10.2 (the `canSurvive` columns; the default is true). |
| Membership | `BlockState.is(TagKey)`, `is(HolderSet)` and `FluidState.is(HolderSet)` are the `TypedInstance` defaults (read): the block's (fluid's) registry holder is tested against the tag or set. `is(HolderSet)` is `HolderSet.contains(holder)`. Tags resolve as in 23 §6. |
| `WorldGenerationContext.of(level)` | For a `WorldGenLevel`: `minY = max(level.minY, generator.minY)`, `height = min(level.height, generator.genDepth)`, `seaLevel = generator.seaLevel`. For any other `LevelAccessor`: the level's `minY`, `height`, `seaLevel`. Used by `height_range` (section 3.4). |
| Random source | Providers take the caller's `RandomSource`. Which source and how it is seeded for decoration is 11 §4 (`WorldgenRandom` over Xoroshiro, `setDecorationSeed`, `setFeatureSeed`); that wrapper's `nextInt`, `nextFloat` and `nextDouble` are the Java-LCG formulas on its `next(bits)` (11 §4). The numbers in this document are called `nextInt(n)`, `nextFloat()` as defined there. |

---

## 3. Block predicates

### 3.1 Codec

`BlockPredicate.CODEC` dispatches on the field `type`, whose value is a name in the `block_predicate_type` registry
(`BuiltInRegistries.BLOCK_PREDICATE_TYPE.byNameCodec().dispatch(type, codec)`). The remaining fields of the object are
read by that type's `MapCodec`. There is no shorthand: a bare string or a bare array is not a predicate. The type names
are registered in this order (registry order; the registry is not sent on the wire, so the position is only the
registration order, as in 46 §2; the order itself was read from both the static initialiser and the bootstrap and matches the tables, only the wire-id rule is (inferred) for these two registries):

| # | `type` | Class | # | `type` | Class |
|---|---|---|---|---|---|
| 0 | `matching_blocks` | `MatchingBlocksPredicate` | 8 | `inside_world_bounds` | `InsideWorldBoundsPredicate` |
| 1 | `matching_block_tag` | `MatchingBlockTagPredicate` | 9 | `any_of` | `AnyOfPredicate` |
| 2 | `matching_fluids` | `MatchingFluidsPredicate` | 10 | `all_of` | `AllOfPredicate` |
| 3 | `matching_biomes` | `MatchingBiomesPredicate` | 11 | `not` | `NotPredicate` |
| 4 | `has_sturdy_face` | `HasSturdyFacePredicate` | 12 | `true` | `TrueBlockPredicate` |
| 5 | `solid` | `SolidPredicate` | 13 | `unobstructed` | `UnobstructedPredicate` |
| 6 | `replaceable` | `ReplaceablePredicate` | 14 | `height_range` | `HeightRangePredicate` |
| 7 | `would_survive` | `WouldSurvivePredicate` | 15 | `volume_match` | `VolumeMatchPredicate` |

Names are written with the `minecraft:` namespace in JSON (`"type": "minecraft:solid"`).

**The offset codec.** Eight of the 16 types carry a field `offset`: `matching_blocks`, `matching_block_tag`,
`matching_fluids`, `has_sturdy_face`, `solid`, `replaceable`, `would_survive` and `inside_world_bounds`. In all eight it
is optional, defaults to `[0, 0, 0]`, and is a list of exactly three ints `[x, y, z]` (`Vec3i.CODEC`: an int array of
length 3; any other length is an error). It is read through `Vec3i.offsetCodec(16)`, which rejects a vector with any
component whose absolute value is above 16 with the message "Position out of range, expected at most 16: <vector>".
The same `offsetCodec(16)` validates `min` and `max` of `volume_match`. `unobstructed` has an `offset` field too but with
the plain `Vec3i.CODEC` (no limit), and its evaluation never reads it (section 3.3).

**Fields that hold block, fluid or biome sets.** `blocks`, `fluids` and `biomes` are `HolderSet` fields in the default
(non-homogeneous) form of 23 §5.1: a bare id, a `#tag`, or a list of ids. `tag` of `matching_block_tag` is different:
it is a bare `TagKey` (`TagKey.codec`: an Identifier string such as `"minecraft:air"`, **no leading `#`**). Writing
`"#minecraft:air"` there is an Identifier error. In the pack's data (feature, placed_feature, structure, template_pool and processor_list), every one of the 110 `matching_blocks`
occurrences uses a plain id or a list of ids; the tag form (`#tag`) of `matching_blocks` does not occur in this pack's data.
The `#minecraft:corals` and `#minecraft:wall_corals` strings that do occur are `random_block` `blocks` fields, not
`matching_blocks`. (`matching_blocks`: 57 files / 110 occurrences; `matching_block_tag`: 110 files / 160 occurrences; section 9.2.)

### 3.2 State-testing predicates (one block read at `origin + offset`)

Common rule (`StateTestingPredicate.test`): `state = level.getBlockState(origin.offset(offset))`, then the type's own test
on that state. Exactly one read, no random draw.

| `type` | Fields | Test on the state |
|---|---|---|
| `matching_blocks` | `offset`, `blocks` (block `HolderSet`, required) | `state.is(blocks)`: the state's block is in the set. |
| `matching_block_tag` | `offset`, `tag` (block `TagKey`, required) | `state.is(tag)`. |
| `matching_fluids` | `offset`, `fluids` (fluid `HolderSet`, required) | `state.getFluidState().is(fluids)`: the fluid state of the block at the position is a fluid of the set. A waterlogged block has a water fluid state (24-1 §5.2), so `matching_fluids [water]` is true for it; `minecraft:empty` matches every block with no fluid (this is the helper `noFluid`). |
| `solid` | `offset` | `state.isSolid()`: the `legacySolid` flag of 24-1 §5.2 (its row table decides: force flags, no shape, empty collision shape, the 35/48 average-extent rule, the full-height rule). It is **not** the plain collision-shape test and not a tag. |
| `replaceable` | `offset` | `state.canBeReplaced()`: the builder's replaceable flag of the block (24-1 §10.1). It is the block flag, **not** membership of the `replaceable` block tag (the two lists differ; the tag is data). |

### 3.3 Other leaf predicates

| `type` | Fields | Evaluation |
|---|---|---|
| `has_sturdy_face` | `offset`, `direction` (required, a `Direction` serialized name: `down`, `up`, `north`, `south`, `west`, `east`) | `state = getBlockState(origin + offset)`; true when `state.isFaceSturdy(level, origin + offset, direction)`, i.e. `SupportType.FULL` on that face (24-1 §6.6). Note the position passed to the support test is the **offset** position. |
| `would_survive` | `offset`, `state` (a `BlockState`, `BlockState.CODEC`: a bare block id for its default state, or `{"id": .., "properties": {..}}`; required) | `state.canSurvive(level, origin + offset)`: the block's `canSurvive` hook for the **given** state evaluated at the offset position, as if it were placed there. The block currently at the position is not read. For a block whose `canSurvive` is the default the answer is true. |
| `inside_world_bounds` | `offset` (default `BlockPos.ZERO`, same value as `[0,0,0]`) | `level.isInsideBuildHeight(origin + offset)`. Only the **y** component matters; x and z are never tested. |
| `matching_biomes` | `biomes` (biome `HolderSet`, required); **no `offset`** | `biomes.contains(level.getBiome(origin))`. |
| `unobstructed` | `offset` (accepted, **ignored**) | `level.isUnobstructed(null, Shapes.block().move(origin))`: the unit cube at `origin` itself (the field `offset` is stored but the test reads only `origin`; read: the test loads `pos` and never the offset). True when no entity that blocks building intersects the cube (section 2: always true while generating). |
| `true` | none | always true. Decodes from `{"type": "minecraft:true"}` (a unit codec). |
| `height_range` | `min_inclusive`, `max_inclusive` (both `VerticalAnchor`, required, 23 §7.3.1); no offset | resolves both anchors with `WorldGenerationContext.of(level)` **at each test** (section 2) and returns `min <= origin.y <= max`. x and z are ignored. A `min` above `max` is not an error; the test is then always false. (Not to be confused with the placement modifier of the same name, `height_range`, which draws a height; it lives in a different registry and is part 1's.) |
| `volume_match` | `min` (`[x,y,z]` offsetCodec 16), `max` (same), `match` (a predicate); all required | Checked on decode: each component of `min` must be `<=` the matching component of `max` (else "min bound cannot be larger than max bound"). Evaluation: true when `match` is true at **every** position `origin + (dx, dy, dz)` for `dx` from `min.x` to `max.x`, `dz` from `min.z` to `max.z` and `dy` from `min.y` to `max.y` inclusive (outer loop x, middle loop z, inner loop y). It stops at the first false (a short circuit with no side effect, so the order is only a cost). The box is relative to `origin`; `match` is tested at the shifted position and is itself allowed to have an offset, which then adds to the shift. |

### 3.4 Combinators

| `type` | Field | Evaluation |
|---|---|---|
| `any_of` | `predicates` (list of predicates, required; the list may be empty) | iterates the list in order and returns true at the first true child; the empty list is **false**. Children after the first true one are not evaluated. |
| `all_of` | `predicates` (list, required; may be empty) | returns false at the first false child; the empty list is **true**. |
| `not` | `predicate` (one predicate, required) | the negation of the child. |

All three evaluate every child at the same `origin`; there is no offset on a combinator. Because predicates are pure, short-circuiting has no visible effect other than cost.

### 3.5 Helper constants and builders (code-side uses)

Two shared predicates are built in code and referenced by features: `ONLY_IN_AIR_PREDICATE` = `matching_block_tag` with tag
`minecraft:air` (offset 0), and `ONLY_IN_AIR_OR_WATER_PREDICATE` = `any_of(ONLY_IN_AIR_PREDICATE, matching_blocks [water])`
(the **block** `water`, not the fluid; so flowing water states of the block match too, since all water block states
are the one block). The tag `minecraft:air` of this pack contains `air`, `void_air`, `cave_air` (`tags/block/air.json`).
The directional builders (`matchesBlocks(Directional, ..)`, `matchesTag(Directional, ..)`, `hasSturdyFace(Directional,
dir)`, `matchesFluids(Directional, ..)` (reads `Directional.getStep`), `solid(Directional)`) only set `offset` to the step vector of the direction; the other builders (`noFluid`,
`replaceable`, `wouldSurvive(block)` = default state of the block, `unobstructed`, `heightRange`,
`volumeMatch`, `alwaysTrue`, `not`, `allOf`, `anyOf`) construct the types above with offset zero; `insideWorld(Vec3i)` is the
exception and takes an explicit offset. These builders are only
a convenience for code that is written in the artifact; the data uses the JSON forms.

### 3.6 Evaluation order and cost notes for implementers

1. A predicate never writes the level and never draws a random number, so an engine may memoize or reorder child tests
   as long as the logical result is the same. An engine that caches block reads must invalidate on writes made by the
   same feature (features write blocks between predicate calls).
2. Positions outside the build height read as `void_air`, which is in the tag `minecraft:air`; so `matching_block_tag air`
   is true above the top and below the bottom, and `solid` is false there.
3. `offset` is applied to a position, not to a direction; a negative y offset is the usual way to test the block below.

---

## 4. Block state providers

### 4.1 Codec and registries

`BlockStateProvider.DIRECT_CODEC` accepts **exactly one** of two shapes (the jar shows the call `Codec.xor(BlockState.FULL_CODEC, TYPED_CODEC)`; the rule "if both or neither decode, the
whole value fails" is DFU library behaviour, (recalled, not verified), Open question 11):

1. A full block state object `{"id": <block id>, "properties": {..}}` (`BlockState.FULL_CODEC`, 23 §7.4). It becomes a
   `simple` provider. Writing a bare block id String here is **not** the full form; it is read as the registry-name form
   below.
2. A typed object `{"type": <provider type>, ...fields}` dispatched over the `worldgen/block_state_provider_type`
   registry (`TYPED_CODEC`).

`BlockStateProvider.CODEC` (every field that says "a block state provider": `source`, `state`, `then`, `fallback`,
`to_place`, `state_provider`, `below_trunk_provider`, and so on) is **Id-or-inline** (23 §5.1): a String names an element
of the registry `worldgen/block_state_provider` (the 8 named elements), an object is the direct form above. The nested
holder's value is read at use time. A `simple` provider encodes back as the bare block state object.

Where a field is documented below as a *block state* (not a provider), it uses `BlockState.CODEC`, which accepts a bare
block id (that block's default state) or the full object. That is the case for `weighted.entries[].data`,
`noise.states`, `noise_threshold.default_state`, `low_states`, `high_states`, `simple.state`.

Registration order of the types (`BlockStateProviderTypes.bootstrap`; the registry order): `copy_properties`,
`dual_noise`, `noise`, `noise_threshold`, `random_block`, `randomized_int`, `rotated`, `rule_based`, `simple`,
`weighted`.

### 4.2 The two entry points

`getState(level, random, pos)` always returns a state. `getOptionalState(level, random, pos)` may return nothing
("null"). The default `getOptionalState` is `getState`. Two providers override it: `random_block` and `rule_based`. A
caller that is able to skip placement (a tree placer that places a block below the trunk, a feature that places only if
something is chosen) calls `getOptionalState`; the rest call `getState`. **Which one each caller uses is the caller's
document.** Nested providers (`rotated.state`, `copy_properties.source`, `randomized_int.source`) are always asked with
`getState`, even when the outer one was reached through `getOptionalState`.

| `type` | `getState` | `getOptionalState` |
|---|---|---|
| `simple`, `weighted`, `noise`, `dual_noise`, `noise_threshold`, `rotated`, `copy_properties`, `randomized_int` | as in 4.3 | same as `getState` |
| `random_block` | a random block's default state; the state **already at `pos`** when the set is empty | the same, but nothing when the set is empty |
| `rule_based` | the optional result, else the state **already at `pos`** (`level.getBlockState(pos)`) | the first non-null result of the matching rules, else the fallback's `getOptionalState`, else nothing |

### 4.3 The ten types

Draws are given in order. `r` is the caller's random source, `nextInt(n)` etc. as in section 2.

| `type` | Fields (all `Req` unless noted) | Result and random draws |
|---|---|---|
| `simple` | `state` (BlockState) | the stored state; **no draw**. |
| `weighted` | `entries`: a non-empty weighted list of block states (list of `{"data": <BlockState>, "weight": <int >= 0>}`, 23 §7.5) | `getRandomOrThrow(r)`: **one draw**, `r.nextInt(totalWeight)`, resolved to an entry by the flat or compact selector of 23 §7.5. The codec refuses a list whose total weight is 0. The code-side constructor throws "Weighted list must have at least one entry" for an empty list (not reachable from data). |
| `random_block` | `blocks`: a block `HolderSet` (a bare id, a `#tag` or a list of ids; **block ids, not states**) | `HolderSet.getRandomElement(r)`: when the set's list is empty **no draw** and no element; otherwise **one draw** `r.nextInt(size)` into the list (declared order for a direct set; the tag's resolved order, 23 §6.4, for a tag; `Util.getRandom` = `list.get(r.nextInt(list.size()))`) and the element's **default state** (`Block.defaultBlockState`). No element: `getState` returns the state at `pos`, `getOptionalState` returns nothing. |
| `rotated` | `state` (provider, Id-or-inline), `direction` (`Direction` serialized name, optional, no default) | 1. `d` = the given direction, or when absent **one draw** `Direction.getRandom(r)` = `VALUES[r.nextInt(6)]` with `VALUES` = `down, up, north, south, west, east` (the enum order). **This draw is made before the inner provider is asked**, and only when `direction` is absent. 2. `s` = `state.getState(level, r, pos)` (its own draws, after the direction's). 3. `s = s.trySetValue(AXIS, d.axis)`. 4. `s = s.trySetValue(FACING, d)`. 5. When `d.axis` is horizontal (x or z): `s = s.trySetValue(HORIZONTAL_FACING, d)`. Result `s`. Property lookup is by object identity, section 4.4. |
| `copy_properties` | `source` (provider, Id-or-inline); no other field | 1. `s = source.getState(level, r, pos)` (its own draws). 2. For each property in the state definition of the block **currently at `pos`** (in definition order): `s = s.trySetValue(p, levelState.getValue(p))`. A property the source's block lacks (identity, 4.4) is skipped. The result keeps `s`'s block. The level block is read once (`level.getBlockState(pos)`). |
| `randomized_int` | `source` (provider), `property` (String), `values` (IntProvider, 23 §7.1) | 1. `s = source.getState(level, r, pos)`. 2. Find the integer property: use the cached property when it exists and `s` has it; otherwise look through `s`'s properties (a stream filter: name equals `property`, then is an `IntegerProperty`, taking any match) for the (only) property of that name that is an `IntegerProperty`, and cache it. A state cannot hold two properties of one name, so which match is taken does not change behaviour. 3. When none exists, return `s` **unchanged** (no sample drawn). 4. Otherwise `s.setValue(prop, values.sample(r))`: **one sample** (the draws of that IntProvider), after the source's draws. A sampled value outside the property's range throws `IllegalArgumentException` at run time; the data codec does not check the range. (The code-side constructor taking a ready property checks that every integer from `values.minInclusive` to `values.maxInclusive` is a possible value of the property, and throws otherwise.) |
| `rule_based` | `fallback` (provider, Id-or-inline, **optional**), `rules`: list of `{"if_true": <BlockPredicate>, "then": <provider>}` | `getOptionalState`: for each rule in list order: when `if_true` is true at `(level, pos)`, ask `then.getOptionalState(level, r, pos)`; **when that is non-null return it, otherwise continue with the next rule** (a matching rule whose `then` yields nothing does not stop the scan). After the last rule: with a fallback, `fallback.getOptionalState(level, r, pos)`; with none, nothing. The predicates are evaluated at `pos` (origin = `pos`), before the matching `then` draws; predicates draw nothing. `getState` = the optional result or the block state at `pos`. |
| `noise` | `seed` (Long), `noise` (NormalNoise parameters, section 5.1), `scale` (float, **> 0**), `states` (non-empty list of BlockState) | **No draw.** `v = noise(x*scale, y*scale, z*scale)` (5.3), index `floor(clamp((1 + v)/2, 0, 0.9999) * size)` in float arithmetic (5.4), result `states[index]`. |
| `dual_noise` | `variety` (inclusive int range, section 4.5), `slow_noise` (NormalNoise parameters), `slow_scale` (float, > 0), and the four fields of `noise` (`seed`, `noise`, `scale`, `states`) | **No draw.** Section 5.5. |
| `noise_threshold` | `seed`, `noise`, `scale` (as `noise`), `threshold` (float in [-1, 1]), `high_chance` (float in [0, 1]), `default_state` (BlockState), `low_states` (non-empty list), `high_states` (non-empty list) | Section 5.6: the only noise provider that draws from `r`. |

### 4.4 Property identity (`rotated`, `copy_properties`, `randomized_int`)

`trySetValue(p, v)` returns the state unchanged when the state does not have the property `p`; "has" is decided by
**object identity** of the `Property` (`StateHolder.valueIndex` compares references), not by name. Block states share
the static `BlockStateProperties` instances, so the rule is: a block is affected only when its definition includes that
very property. The three properties `rotated` touches are three distinct instances:

| Constant | Name | Value set (declared order) | Notes |
|---|---|---|---|
| `AXIS` | `axis` | `x`, `y`, `z` (the `Direction.Axis` enum) | the blocks whose definition uses this instance (the pack's `hay_block` for one, Example 5). |
| `HORIZONTAL_AXIS` | `axis` | `x`, `z` (created with these two values given explicitly) | **not** touched by `rotated` although it is called `axis` (a different instance). |
| `FACING` | `facing` | `north`, `east`, `south`, `west`, `up`, `down` (read from the static initialiser) | the six-way instance. |
| `FACING_HOPPER` | `facing` | `down`, `north`, `south`, `west`, `east` (created with a filter lambda whose body was read: true unless the direction is `up`, in `Direction` enum order) | **not** touched by `rotated`. |
| `HORIZONTAL_FACING` | `facing` | the four horizontal directions (created over `Direction$Plane.HORIZONTAL`, read from the static initialiser; the order is that of the Plane, not of the `Direction` enum: `Direction$Plane.<clinit>` builds HORIZONTAL from `north`, `east`, `south`, `west` in that order, read; whether the property keeps that order was not read, (inferred)) | touched only when the direction is horizontal. |

An implementation that stores properties by name must therefore tag each property with its value set (or a kind) and
treat `axis` with set `{x,z}` and `facing` with sets other than the six-way and the horizontal ones as different
properties. For `copy_properties` the same identity rule applies per property of the level block: the source state
receives a copy only for a property that is **the same instance** in its block (for instance `waterlogged`, `facing`,
`axis` of the same kind); a copied value that is not allowed in the target throws (does not occur with shared instances).
A property of the level block that the source lacks is skipped without error.

### 4.5 `InclusiveRange` (the `variety` field)

`variety` is `InclusiveRange.codec(Codec.INT, 1, 64)`. The base codec (`ExtraCodecs.intervalCodec`) is a composition of `Codec.either` and `withAlternative` over the three shapes below (composition read; the shape semantics are library behaviour, (recalled, not verified), Open question 11), and accepts:
a single int `n` (the range `[n, n]`), a list of two ints `[min, max]`, or an object `{"min_inclusive": a,
"max_inclusive": b}`; and requires `min <= max` (message "min_inclusive must be less than or equal to max_inclusive"). The
wrapping `codec(.., 1, 64)` then requires both bounds in `[1, 64]` (the message names the offending bound and the range).
The pack writes it as a list (`"variety": [1, 3]`). (This corrects the object-only description in 23 §7.4.)

---

## 5. Noise-based providers: shared setup and seeding

`noise`, `dual_noise` and `noise_threshold` extend `NoiseBasedStateProvider`. Their value does not depend on the
caller's random source; it depends only on the provider's fields and the **absolute block position**.

### 5.1 Fields and parameter codec

| Field | Codec | Notes |
|---|---|---|
| `seed` | Long (64-bit, required) | any value, including negative. |
| `scale` | `ExtraCodecs.POSITIVE_FLOAT` (required) | float; zero and negative values are refused. Stored as a float. |
| `noise` (and `slow_noise`) | `NormalNoise.DIRECT_CODEC`, which is `NormalNoise$Parameters.CODEC` turned into a `NormalNoise` | the same object shape as a `worldgen/noise` element (10 §3.3). |

`NormalNoise$Parameters` fields, as read here (this extends 10 §3.3 with the exact bounds and defaults):

| Field | Type | Default | Constraint |
|---|---|---|---|
| `base_octave` | int | required | `-32 <= v <= 32` |
| `base_amplitude` | double | `1.0` | `9.999999747378752E-6 <= v <= 1000000.0` (the lower bound is the float 1.0E-5 widened) |
| `octave_count` | int | `1` | `1 <= v <= 32` |
| `normalize` | `true`, `false` or the string `"legacy"` | `true` | `true` is `enabled`, `false` is `disabled`; any other string is an error |
| `amplitude_modifiers` | list of doubles | empty | 0 to 32 entries, each in `[0, 1000000]`; the list must be empty or have exactly `octave_count` entries (else a validation error) |

The pack's provider noises write only `base_octave` and `base_amplitude` (`octave_count` 1, `normalize` enabled, no
modifiers). The `legacy` normalization is not used by any pack file; its rule, read from `NormalNoise` (constructor,
`buildOctaves`, `computeParityNormalizationFactor`, `parityExpectedDeviation`), is section 5.1.1.

### 5.1.1 Normalization modes (read from `NormalNoise`)

`Normalization` has three values in the order `DISABLED`, `ENABLED`, `LEGACY`. Let `n` = `octave_count`, `b` =
`base_octave`, `A` = `base_amplitude`, `m[i]` = the modifier of octave `i` (1.0 for every `i` when the list is empty).

1. **Octave list.** The starting amplitude is `A` for `DISABLED`; for `ENABLED` **and `LEGACY`** it is
   `A * 0.5^-(n-1) / (0.5^-n - 1)` (= `A * 2^(n-1) / (2^n - 1)`). Octave `i` (0 to n-1) has input factor `2^(b+i)` and
   amplitude = start * `0.5^i` * `m[i]`; an octave with `m[i]` = 0 is left out (its factor and halving still advance).
2. **Normal factor.** `sum` = the sum of the listed amplitudes; `dev` = sqrt of the sum of `(0.2702247831245211 * amp)^2`;
   `nf0` = `(A * 1/3) / (dev * sqrt 2)`, or 0 when `dev` = 0. (The `A` here is the raw `base_amplitude`.)
3. **LEGACY only, and only when `nf0` is not 0.** `p = (A * 0.5 * 1/3) / E(hi - lo)` where `lo` and `hi` are the smallest
   and largest octave index `i` in 0..n-1 whose `m[i]` is not 0 (all indices count when the list is empty, so `hi - lo` =
   n-1), and `E(k) = 0.1 * (1 + 1/(k+1))`. Then `sum = sum * p / nf0` and `nf = p`. With no nonzero modifier the min/max
   start at the int extremes and `hi - lo` is a wrapped int difference (not examined; the pack never has all-zero lists).
4. **Range.** The reported range is symmetric, half-width `float(sum * 1/3 * 6)`.

Worked example: `n` = 1, `b` = -7, `A` = 1: start amplitude `1 * 2^0 / (2^1 - 1)` = 1; `dev` = 0.2702247831245211;
`nf0` = (1/3) / (0.2702247831245211 * 1.4142136) = 0.872245 (0.8722451644522289, as in Example 7). LEGACY: `E(0)` = 0.2;
`p` = (0.5/3)/0.2 = 0.833333; `sum` = 0.833333/0.872245 = 0.955389 (0.955388882960065, the same value as the `base_amplitude`
the pack's flower noises use: a cross-check); range half-width = `sum` * 1/3 * 6 = 1.910778 (computed, not observed). (`createParity(b, list)` is the
programmatic route to the same: base amplitude = `p(1.0, size, list) / nf0(of the n-octave list built at A = 1,
normalized)`, 1.0 when that factor is 0; code-only, not used by the pack.)

### 5.2 Setup at construction (what `NoiseBasedStateProvider` does once)

Inputs: `seed`, the decoded `NormalNoise` `N` (octave list and normalization factor `nf` per 10 §3.3: octave list from
`buildOctaves`, `nf = (Σ amplitude * 1/3) / (dev * sqrt 2)` with `dev = sqrt Σ (0.2702247831245211 * |amp|)^2`).

1. `w = LegacyRandomSource(seed)`, wrapped as `WorldgenRandom(w)`. (`LegacyRandomSource(seed)` scrambles the seed:
   state `(seed xor 0x5DEECE66D) and (2^48 - 1)`, 10 §2.6. A `WorldgenRandom` over a legacy source delegates
   `forkPositional` to the wrapped source and does not advance itself.)
2. `N.create(random)` is called with that wrapper:
   1. `A = random.forkPositional()`: a **legacy positional factory** whose key is `kA = w.nextLong()` (the first
      `nextLong` of the wrapped source: `(next(32) << 32) + next(32)`, with the two ints sign-extended and added as
      signed 64-bit numbers, 10 §2.6).
   2. `B = random.forkPositional()`: the factory with `kB = w.nextLong()` (the second `nextLong`).
   3. For each octave `o` of `N`'s octave list, in list order, with index `i` (`o.index = base_octave + slot`), name
      `s = "octave_" + i` (decimal, signed: `octave_-3`):
      * `pa = PerlinNoise(A.fromHashOf(s))` and `pb = PerlinNoise(B.fromHashOf(s))`.
      * `A.fromHashOf(s)` = a new `LegacyRandomSource` with seed `(long) hash(s) xor kA`, where `hash` is the
        32-bit Java string hash (`h = 31*h + char`, over the UTF-16 code units, wrapping 32-bit; the artifact calls
        `String.hashCode`, the formula is the JDK's: recalled, not verified, Open question 1) widened with sign to 64
        bits; likewise with `kB` for `B`. The new source is seeded (scrambled) as in step 1.
      * `PerlinNoise(r)` is the single-octave gradient noise of 10 §3.1: `offsetX = r.nextDouble()*256`, `offsetY`, `offsetZ`
        (three draws in that order), then the permutation table (identity, then for `i` in 0..255 swap `perm[i]` with
        `perm[i + r.nextInt(256 - i)]`). (Re-read in this round: `GradientNoise(RandomSource, 256.0)`; the table and the
        sampling are as in 10 §3.1.)
      * `a = (float)(nf * o.amplitude)`.
      * Layers added in this order: `(pa, o.frequency, a)` then `(pb, o.frequency * 1.0181268882175227, a)`.
3. The result is a `NoiseStack` of those layers; the provider keeps it for its lifetime. `dual_noise` builds a second
   one the same way from `slow_noise`, **with the same `seed`**, so the two share `kA`, `kB` and the per-octave random
   sources (they differ only through their octave lists and parameters).

Two providers with the same `seed` and parameters therefore return identical values at every position, and the value
never depends on `r`, on the chunk, or on call order. The setup is done when the provider object is constructed (when the
registry element or the feature config is decoded), not per call.

### 5.3 Noise value at a position

`getNoiseValue(pos, scale)` (`scale` as a double; the stored float scale is widened first):
`noise.get((double) x * scale, (double) y * scale, (double) z * scale)` → float. `NoiseStack.get(x, y, z)` (10 §3.2): `acc = 0f`; for each layer in
order, `acc = acc + amplitude * layer.noise.get(x * frequency, y * frequency, z * frequency)`; the product and the sum are
float operations and the multiplications `x * frequency` are double. The Perlin `get` is the one of 10 §3.1. The value
range is about `[-1, 1]` but not strictly bounded (`range()` is advisory); the index formula clamps.

### 5.4 The index formula (`NoiseProvider.getRandomState(list, v)`)

Float arithmetic throughout: `t = clamp((1.0f + v) / 2.0f, 0.0f, 0.9999f)`; `index = (int)(t * (float) size)`
(truncation toward zero). Properties: `v <= -1` gives index 0; `v >= 1` gives `floor(0.9999 * size)`, which is `size - 1`
for any `size` up to 10000. NaN is not considered (the noise never produces it).

### 5.5 `dual_noise`

Fields as in the table of 4.3. No draw. Let `slow(P)` be the slow noise at block position `P`, with coordinates
**multiplied in float** by `slow_scale` and then widened: `slow(P) = slowNoise.get((double)((float) P.x * slowScale),
(double)((float) P.y * slowScale), (double)((float) P.z * slowScale))` (each product is a float product; compare 5.3
where the product is in double).

1. `s = slow(pos)` (float, widened to double).
2. `n = (int) clampedMap(s, -1.0, 1.0, variety.min, variety.max + 1)` (all double), with `clampedMap(v, a, b, c, d) =
   c + t*(d - c)`, `t = clamp((v - a)/(b - a), 0, 1)` (`Mth.clampedMap`), cast truncating. So `n` is in
   `[variety.min, variety.max + 1]`, and equals `variety.max + 1` only when `s >= 1`.
3. Build a list `L` of `n` states. For `i = 0 .. n-1`: `L[i] = states[ index(slow(pos + (i*54545, 0, i*34234)), states.size) ]`,
   with `index` the formula of 5.4 (`pos + (dx, 0, dz)` is `BlockPos.offset(int, int, int)`, 32-bit ints; the offsets are
   added to the block position before the float conversion).
4. The result is `L[ index(mainNoiseValue, n) ]`, where `mainNoiseValue = getNoiseValue(pos, scale)` (5.3) and the list
   size in the formula is `n`, **not** `states.size`.

So the slow noise chooses a small sub-palette of `n` entries (a window made of different positions of the slow noise, so
that nearby `pos` get the same palette) and the main noise picks within it.

### 5.6 `noise_threshold`

`v = getNoiseValue(pos, scale)` (float) widened to double; `threshold` widened likewise.

1. If `v < threshold` (strict): `d = r.nextInt(lowStates.size)` (`Util.getRandom`); result `lowStates[d]`. One draw.
2. Otherwise: `f = r.nextFloat()`; if `f < highChance` (strict, both floats): `d = r.nextInt(highStates.size)`;
   result `highStates[d]` (two draws: the float, then the int).
3. Otherwise result `defaultState` (one draw: the float).

`high_chance` 0 never takes the high branch (`nextFloat` is in `[0, 1)` so `f < 0` is false) but still consumes the float;
`high_chance` 1 always does (`f < 1`).

---

## 6. Worked examples

All numbers marked (computed) were produced by a throwaway reference program that applies sections 5.2 to 5.6 and the
float rules of 10 §3.1 to §3.3; they were not observed from the artifact. The Java LCG was checked against the reference
values of 11 §4 (seed 0: `next(32)` = -1155484576, `nextLong()` = -4962768465676381896, `nextFloat()` = 0.7309678).

**Example 1: block predicate arithmetic (the desert well filter).** The pack's `desert_well` placed feature has six placement modifiers (`rarity_filter` 1000, `in_square`, `heightmap` MOTION_BLOCKING, `offset` y -1,
`block_predicate_filter`, `biome`); the `block_predicate_filter` is the fifth, and its predicate is
`all_of [ matching_blocks {blocks: "minecraft:sand"}, volume_match {min [-2,-2,-2], max [2,-1,2], match: not(matching_block_tag
{tag: "minecraft:air"})} ]`, applied to a position that an earlier `offset` modifier moved one block down. At origin
`(10, 70, 20)`: `all_of` first reads the block at `(10, 70, 20)` and requires `sand`. Then `volume_match` visits
`dx` in -2..2, `dz` in -2..2, `dy` in -2..-1: 5 x 5 x 2 = 50 positions from `(8, 68, 18)` to `(12, 69, 22)`; the first
of them is `(8, 68, 18)`, and it is true at a position only if the block there is **not** in the air tag. One air block
anywhere in the box makes the whole predicate false; a `void_air` block counts as air.

**Example 2: offsets that do not compose.** `has_sturdy_face {direction: "up", offset: [0,-1,0]}` at origin `(5, 64, 5)`
tests whether the block at `(5, 63, 5)` has a full upward face (a full block, a slab in its top half, and so on per
24-1 §6.6). `unobstructed {offset: [0,-1,0]}` at the same origin tests the cube at `(5, 64, 5)`, not `(5, 63, 5)`.
`matching_biomes` has no offset and tests the biome at `(5, 64, 5)`. `height_range {min_inclusive {absolute: 0},
max_inclusive {above_bottom: 10}}` at origin `y = -54` with `minY = -64`: `max` resolves to `-54` (true for the upper bound) but
`min` resolves to `0`, and `0 <= -54` fails, so the result is **false** (the test is `min <= y <= max`). With `min_inclusive
{above_bottom: 0}` (resolving to `-64`) and the same max the result is true.

**Example 3: `any_of`/`all_of` identities.** `any_of []` is false at every position; `all_of []` is true; `not(any_of [])`
is true. `any_of [A, B]` at a position where `A` is true never evaluates `B`.

**Example 4: `rule_based` fall-through (the pack's `soil_beneath_tree`).** `rules` = one rule: `if_true` = `not(matching_block_tag
{tag: "minecraft:cannot_replace_below_tree_trunk"})`, `then` = the state `dirt`; no `fallback`. At a position whose
current block is in that tag, the rule's predicate is false, the scan ends, and: `getOptionalState` returns nothing
(the caller does not place dirt there), while `getState` returns the block currently at the position (so a caller that
uses `getState` would "place" the same block back). At a position whose block is not in the tag, both return `dirt`. If a
rule matched but its `then` were a `random_block` over an empty set, `getOptionalState` would go on to the next rule.

**Example 5: `rotated` draws (the pack's `pile_hay`).** `rotated` with `state` = `hay_block[axis=y]`, no `direction`. The
random source is asked first: say `r.nextInt(6) = 3`, which is `south`. The inner `simple` provider returns
`hay_block[axis=y]` (no draw). `AXIS` is a property of the hay block: `axis = south.axis = z` (`north` and `south` are
the z axis). `FACING` and `HORIZONTAL_FACING` are not properties of hay, so they are ignored. Result `hay_block[axis=z]`. The
six outcomes for draw 0 to 5: `down` y, `up` y, `north` z, `south` z, `west` x, `east` x. With `direction: "up"` fixed
no draw is made at all. For a block that has only `HORIZONTAL_AXIS` (`axis` with `x` and `z`) the state is unchanged
whatever the direction, because that property is a different instance (4.4).

**Example 6: `randomized_int` with a weighted source (the pack's `cave_vines_head`).** `source` = weighted
`[cave_vines weight 4, cave_vines{age=0,berries=true} weight 1]` (total weight 5, below 64, so the flat selector of
23 §7.5), `property` = `age`, `values` = uniform 23 to 25. Draw 1 is `r.nextInt(5)`: values 0 to 3 pick the plain
`cave_vines`, value 4 picks the berry state. Then the IntProvider draws (uniform: `23 + r.nextInt(3)`, 23 §7.1). If
`nextInt(5) = 4` and `nextInt(3) = 2`: result `cave_vines{age=25, berries=true}`. If the source had been a block without
an integer property named `age`, the source state would come back unchanged and the second draw would not happen.

**Example 7: `noise` provider (the pack's `flower_flower_forest`; computed).** Fields: `seed` 2345, `noise`
`{base_octave: 0, base_amplitude: 0.955388882960065}`, `scale` 0.020833334, 11 `states` in the order dandelion, poppy,
allium, azure_bluet, red_tulip, orange_tulip, white_tulip, pink_tulip, oxeye_daisy, cornflower, lily_of_the_valley.
Setup (computed): one octave, `nf = 0.8722451644522289`, layer amplitude `(float)(nf * 0.955388882960065) = 0.8333333`
(5/6) for both layers; `LegacyRandomSource(2345)`: `kA = -1223197305642693068`, `kB = -8087649459364435462`;
`hash("octave_0") = 1261148513`; the seed of the first octave's source is `1261148513 xor kA =
-1223197304453310635` and for the second noise `1261148513 xor kB = -8087649458443489125`; the first Perlin has
`offsetX = 194.48694237469968`, `offsetY = 162.67908262575148`, `offsetZ = 181.1821062694335`, first permutation entries 133, 15,
31, 153, 13, 119, 73, 111; the second has `offsetX = 253.42363124452393`, `offsetY = 215.92054525757948`,
`offsetZ = 28.676999837367106`, first entries 250, 128, 186, 9, 5, 13, 64, 209. The widened scale is
`0.02083333395421505`. Values:

| `pos` | noise value `v` | `(1+v)/2 * 11` | index | state |
|---|---|---|---|---|
| (0, 64, 0) | -0.0683039128780365 | 5.12 | 5 | orange_tulip |
| (100, 70, -50) | 0.4049070477485657 | 7.73 | 7 | pink_tulip |
| (-37, 65, 812) | 0.22272339463233948 | 6.72 | 6 | white_tulip |
| (12, 63, 12) | 0.048405203968286514 | 5.77 | 5 | orange_tulip |
| (1000, 80, -1000) | 0.10368889570236206 | 6.07 | 6 | white_tulip |

Index edge cases with 11 states: `v = -1.0` gives 0, `v = 0.0` gives 5, `v >= 1.0` gives 10.

**Example 8: `dual_noise` window sizes.** With `variety [1, 3]`: slow value `s = -1` gives `n = (int) 1.0 = 1`;
`s = 0` gives `1 + 0.5*3 = 2.5`, `n = 2`; `s = 0.5` gives `3.25`, `n = 3`; `s = 0.9999` gives `n = 3`; `s >= 1` gives
`n = 4` (one more than `variety.max`, intended or not: the formula reads `max + 1` as the upper output). With 8 `states` and
`n = 2`: `L = [states[idx(slow(pos))], states[idx(slow(pos + (54545, 0, 34234)))]]`, and the main noise value `v`
chooses `L[(int)(clamp((1+v)/2, 0, 0.9999) * 2)]`. For the pack's `flower_meadow` (seed 2345, `noise` octave -3 and
`slow_noise` octave -10, both scales 1.0, `variety [1, 3]`, 8 states) the computed slow values at `(0, 64, 0)`,
`(100, 70, -50)` and `(-37, 65, 812)` are 0.0908, 0.0540 and 0.0364 (so `n = 2` at all three), which shows that the
slow octave -10 varies by very little over hundreds of blocks (computed).

**Example 9: `noise_threshold` draws (the pack's `flower_plain`).** `threshold -0.8`, `high_chance 0.33333334`,
`low_states` 4 tulips, `high_states` 4 flowers, `default_state` dandelion, `scale 0.005`, `seed 2345`. The computed
noise values at `(0, 64, 0)` and `(100, 70, -50)` are -0.4586 and 0.2101: both are `>= -0.8`, so the high branch
is tried: `f = r.nextFloat()`; if `f = 0.2` (< 0.33333334) then `d = r.nextInt(4)`, say 2, giving `oxeye_daisy`
(`high_states[2]`); if `f = 0.5` the result is `dandelion` with only one draw consumed. With `v = -0.9` (below the
threshold) the result is `low_states[r.nextInt(4)]`: one draw and no float.

**Example 10: `random_block` over a tag.** `blocks` = `#minecraft:corals` (a tag that includes another tag, 23 §6),
list order per 23 §6.4. One draw `r.nextInt(size)` selects an element, the default state of that block is returned. If
the tag resolved to zero blocks (for instance a pack that empties it), no draw is made and `getState` returns the block
currently at the position.

---

## 7. Corrections and additions to earlier documents

| Document | Statement | Correction or addition |
|---|---|---|
| 23 §7.4, row `rule_based` | "the first rule whose predicate holds at the position gives the state (`then`); no match uses `fallback`" | The scan **continues** to later rules when a matching rule's `then.getOptionalState` is null (section 4.3). `getState` falls back to the block at `pos`, not to nothing. |
| 23 §7.4, row `dual_noise` | `variety` "`InclusiveRange<Int>` with `min_inclusive` and `max_inclusive`" | Three shapes are accepted: an int, a 2-list, and the object (4.5); the pack uses the list. |
| 23 §7.4.1 | `noise` "(fields of `NormalNoise$Parameters`, ... `firstOctave` and `amplitudes`)" | The artifact's `Parameters` fields are `base_octave`, `base_amplitude`, `octave_count`, `normalize`, `amplitude_modifiers` (5.1), as in 10 §3.3. No fields named `firstOctave` or `amplitudes` exist in this artifact. |
| 23 §7.4.1 | "created from `WorldgenRandom(LegacyRandomSource(seed))`" | Complete setup, including the two `forkPositional` keys and the `hashCode`-based octave sources, is section 5.2. |
| 10 §3.3 | `normalize` "`enabled`, `disabled` or `legacy`" | The written form is `true`, `false` or the string `"legacy"` (5.1); `base_amplitude` is optional with default 1.0 and `base_octave` is bounded to [-32, 32]. |
| 10 §3.3 | "Instantiation ... `r = P.fromHashOf(identifier)`" with Xoroshiro positional factories | `NormalNoise.create` takes any `RandomSource`. With a legacy source (these providers) `forkPositional` and `fromHashOf` are the legacy forms of 10 §2.6 (`fromHashOf(name)` = seed `hashCode(name) xor key`), not the MD5 form. |

---

## 8. RuleTest helpers (cross-reference)

`RuleTest` (`structure.templatesystem`; `RuleTestType` registers 10 names in this order: `all_of`, `always_true`, `any_of`,
`block_match`, `blockstate_match`, `not`, `tag_match`, `height_match`, `random_block_match`, `random_blockstate_match`;
the sibling `PosRuleTestType` registers `always_true`, `linear_pos`, `axis_aligned_linear_pos`) is the *target* test of ore and structure rules. It is
not used by predicates or providers in this document (providers use `BlockPredicate`). The ore target use, `tag_match`,
`block_match` and the logical combinators, is in 11 §7.3. The other kinds were read only as to their class list in this
round and are specified with the structure processors in RS20 (Open question 6).

---

## 9. Validation

### 9.1 Checks an implementation must pass

1. **Type tables.** 16 predicate type names with the registration order of 3.1; 10 provider type names with the order
   of 4.1; the offset-carrying set of eight in 3.1.
2. **Offset codec.** `[16, -16, 0]` decodes; `[17, 0, 0]` fails with "Position out of range, expected at most 16: ...";
   a list of two ints fails; an object `{"x":0}` fails.
3. **Pure predicates.** For every position of a test world, `any_of []` is false, `all_of []` is true, `true` is true.
4. **Tag keys.** `matching_block_tag {"tag": "minecraft:air"}` decodes; `{"tag": "#minecraft:air"}` fails.
   `matching_blocks {"blocks": "#minecraft:air"}` decodes and tests the same set.
5. **Unobstructed ignores the offset.** In a generation context it is true everywhere, with any `offset`.
6. **`volume_match` bounds.** `min [1,0,0]`, `max [0,0,0]` fails to decode with the stated message.
7. **Provider codec.** `{"id": "minecraft:stone"}` decodes as a provider (a `simple`); `"minecraft:stone"` as a provider
   field is a registry-name lookup and fails when no such element exists; as a `weighted.entries[].data` it is a state.
8. **Draw counts.** `simple`, `noise`, `dual_noise`: 0 draws. `weighted`, `random_block` (non-empty): 1.
   `rotated` without direction: 1 (before the inner provider's). `rotated` with direction: 0 plus the inner's.
   `noise_threshold`: 1 (below), 2 (high branch), 1 (default). `randomized_int`: the inner's plus the IntProvider's, or just
   the inner's when no integer property of that name exists. `rule_based` and `copy_properties`: the inner's only.
9. **Property identity.** `rotated` leaves `HORIZONTAL_AXIS`-only and `FACING_HOPPER`-only blocks unchanged.
10. **Noise determinism.** The same provider returns the same state for the same `pos` regardless of `r` and of call
    order; two providers with equal `seed` and parameters agree everywhere; changing only `seed` changes values.
11. **Seed vector.** With `seed 2345` the two factory keys are those of Example 7 (computed), assuming the LCG matches the
    11 §4 reference values.

### 9.2 What the data pack uses (counts read from the jar)

The pack has 240 files under `worldgen/feature`, 273 under `worldgen/placed_feature`, 8 under
`worldgen/block_state_provider`, 40 under `processor_list`, 245 under `template_pool`, 52 under `structure` (each counted
with `unzip -Z1 | grep -v '/$'`). Files (and occurrences) in which a predicate type appears, counting
`"type": "minecraft:<name>"` in `feature`, `placed_feature`, `structure`, `template_pool` and `processor_list`. The 8 files of
`block_state_provider` are excluded from these counts; they contain `matching_block_tag` in 2 files (soil_beneath_tree,
podzol_beneath_tree) and `not` in 1 (soil_beneath_tree), so the totals are not pack-wide:

| Predicate type | Files | Occurrences | Predicate type | Files | Occurrences |
|---|---|---|---|---|---|
| `matching_blocks` | 57 | 110 | `would_survive` | 63 | 63 |
| `matching_block_tag` | 110 | 160 | `inside_world_bounds` | 1 | 1 |
| `matching_fluids` | 13 | 31 | `any_of` | 14 | 35 |
| `matching_biomes` | 0 | 0 | `all_of` | 38 | 56 |
| `has_sturdy_face` | 5 | 6 | `not` | 15 | 18 |
| `solid` | 12 | 21 | `true` | 1 | 1 |
| `replaceable` | 2 | 2 | `unobstructed` | 0 | 0 |
| `volume_match` | 1 | 1 | `height_range` | (not counted: the placement modifier shares the name) | |

The `height_range` count is deliberately omitted because the string also names a placement modifier. Provider types
used by the pack, in the five directories feature, placed_feature, structure, template_pool and processor_list: `weighted` (31
files), `randomized_int` (5), `rule_based` (3), `rotated` (2), `random_block` (1); and in the `block_state_provider`
directory: `weighted` 2 (cave_vines_body, cave_vines_head), `randomized_int` 2 (cave_vines_head, mangrove_propagule),
`rule_based` 2 (soil_beneath_tree, podzol_beneath_tree), and one each of `noise`, `dual_noise` and `noise_threshold`. A bare
`"type": "minecraft:simple"` never appears (a single state is written as a state object, 4.1) and `copy_properties`
does not appear in the data of this jar (the type exists for code and for other packs).

### 9.3 Cross-checks done in this round

* Registration order of both type registries read from `BlockPredicateType.<clinit>` and
  `BlockStateProviderTypes.bootstrap`.
* Every provider's draw sequence was read from its `getState` body (offsets, `nextInt`, `nextFloat`, `sample`), and
  agrees with 23 §7.4 except for the four statements corrected in section 7.
* The Java LCG reference values quoted from 11 §4 were reproduced by the reference program; the Perlin sampling steps
  (`wrap`, floor, `smoothstep`, `lerp3`, gradient dot) were re-read in `PerlinNoise.get`, `sampleAndLerp`,
  `Mth.lerp`, `Mth.smoothstep` and `GradientNoise$Gradient.dot` and agree with 10 §3.1.

---

## 10. Open questions

1. **`String.hashCode` is a JDK definition.** `LegacyPositionalRandomFactory.fromHashOf` calls `String.hashCode`, widens to
   long and XORs with the factory key (read). The polynomial `h = 31*h + code unit` is JDK behaviour not in the jar
   (recalled, not verified); the value `hash("octave_0")` = 1261148513 was confirmed by an independent computation, and
   the downstream kA/kB and Perlin offsets of Example 7 agree with it.
2. **Worked examples are computed.** Examples 7 to 9 (noise values, factory keys, Perlin offsets) come from a reference
   program built from this and earlier documents; none was observed from the artifact. They check the internal
   consistency of 10 §3 and section 5, not vanilla values.
3. **Callers of `getOptionalState` (closed).** Read from the jar: `DiskFeature`, `SimpleBlockFeature`,
   `ProjectedRandomPatchySquare`, `AlterGroundDecorator` (tree decorator), `TrunkPlacer` (below-trunk placement) and
   `net.minecraft.core.component.BlockTransformer`. `RuleBasedStateProvider` and `RandomBlockProvider` are the overriders;
   every other consumer uses `getState`.
4. **Block states outside the pack's providers.** `copy_properties` and the `simple` type are not used by any file of
   the pack; their behaviour is specified from the bytecode only.
5. **`normalize: "legacy"` (closed).** Read and written in 5.1.1. Residual: the all-zero modifier list case (wrapped int
   difference) was not examined; `createForLegacyNetherBiome` was not read (not needed by providers).
6. **RuleTest kinds other than the ore ones.** Section 8: the registration list is read; the behaviour of `blockstate_match`,
   `random_block_match`, `random_blockstate_match`, `height_match`, `all_of`, `any_of`, `not` and the three `PosRuleTest`
   kinds was not read here.
7. **Reads outside the writable region of a `WorldGenRegion`.** Section 2 notes that reads outside the write zone log
   a warning and still read. What `getChunk` returns for a chunk outside the region's loaded window (an exception
   or a lower-status chunk) was not read; it is the framework's question (sibling part 1) and matters for predicates
   with offsets near a chunk-window edge.
8. **`Property` instance identity (closed).** Checked in the jar: no class under `net.minecraft.world.level.block` creates its
   own `axis` or `facing` property; the only property-creating uses of those strings are in `BlockStateProperties`
   (`PistonMovingBlockEntity` holds `facing` only as NBT). The assumption of 4.4 holds for every block class.
9. **Unobstructed on a live level.** The `blocksBuilding` flag of each entity type (which entities block a
   `unobstructed` predicate on a `ServerLevel`) belongs to the entity documents (18, 21, 45) and was not tabulated.
10. **`Codec.xor` error text.** The error text produced when a provider object matches both or neither of the two
    alternatives in 4.1 was not read; only the rule "exactly one" is stated.
11. **Library semantics assumed.** `Codec.xor` (both or neither decoding fails), `Codec.either` and `withAlternative` (a
    single int `n` read as `[n, n]` in 4.5) are DFU library behaviour; the jar shows only the compositions. Marked
    (recalled, not verified).
12. **Order of `HORIZONTAL_FACING` values.** `Direction$Plane.HORIZONTAL` is read (north, east, south, west); how `EnumProperty.create` with a Plane orders the values was not read. Not observable from data.
