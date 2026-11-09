# 36 Structures, part 9: villages, the zombie variant, the pillager outpost and their points of interest

| Item | Value |
|---|---|
| Covers | The jigsaw structure family of the overworld village and illager groups: the five village variants (plains, desert, savanna, snowy, taiga) and the pillager outpost as instances of the `jigsaw` structure type (the fields they use, their limits, the structure sets and biome tags that place them); the pool graph that builds a village (town centers, streets, terminators, houses, decor, trees, villagers, animals, cats, golem, well bottoms, camel) and its data profile; the zombie variant and how far it reaches; terrain matching as the villages use it; the processor lists the family uses (by reference to 36-2); decor and tree features, farm pieces; the chest and entity content of the templates; what is placed at generation (villagers, golem, animals) and what is not (professions, village state); the registration of points of interest while a village is generated; the outpost graph, its loot, its pillager spawn rule and its interplay with patrols and raids |
| Does not cover | The jigsaw assembly algorithm itself (36-3), the template system and processor engines (36-2), placement and starts (36-1), terrain adaptation numbers (36-1 section 9), placed-feature engines (35), loot-table evaluation (26), the villager brain and trades (19, 44-3), raids and patrols (20 section 14). Those are cited by section and not repeated; only the parts of them that this family exercises are restated, as values or consequences |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `JigsawStructure`, `JigsawPlacement` and its `Placer`, the pool element classes, `StructureTemplatePool`, `PoiTypes`, `PoiType`, `PoiManager`, `PoiSection`, `WorldGenRegion`, `ServerLevel`, `PatrollingMonster`, `Raider`, `Pillager`, `AgeableMob`, `Villager`; and of the JSON data and structure NBT inside the jar (read with a small read-only NBT parser, no execution of the artifact). A value is read from the artifact unless it is marked "(inferred)" or "(recalled, not verified)"; every mark is listed in the Open questions |
| Round | RS20, part 9 (GAP-12b and the structure part of GAP-18 of [../design/README.md](../design/README.md)) |
| Operator decisions | Standard Minecraft content is the target. A tool extracts the data pack and resource pack from the user's jar, so data rows (structure JSON, structure sets, template pools, processor lists, biome tags, loot tables, structure NBT) are **not** tabulated here: this document gives the schema use, the semantics, the engines' consequences and aggregate profiles for validation (counts and weight sums, never the rows). Code-defined content is given completely. Ticket CC-0001, Decisions "World scope" and "Vanilla assets and data" |

Class names in backticks say where a fact was read; they are not the design. References: "36-n section m" is part n of the structures
document ([36-structures-1-model-placement-starts.md](36-structures-1-model-placement-starts.md),
[36-structures-2-templates-and-processors.md](36-structures-2-templates-and-processors.md),
[36-structures-3-jigsaw-assembly.md](36-structures-3-jigsaw-assembly.md)); "44-3 section m" is
[44-residual-mob-questions-3-villagers-poi-raids.md](44-residual-mob-questions-3-villagers-poi-raids.md); "44-2 section m" is
[44-residual-mob-questions-2-spawning-structures.md](44-residual-mob-questions-2-spawning-structures.md); "45-6" is
[45-entity-nbt-6-villagers-illagers-piglins.md](45-entity-nbt-6-villagers-illagers-piglins.md); "19", "20", "26", "31", "35" are the
documents of those numbers. "Template" means a structure NBT file, "pool" a `worldgen/template_pool` element, "element" one weighted
entry of a pool. Counts of templates, blocks and jigsaws are over the whole jar (all variants together) unless a row says otherwise; they
are profile numbers for validating an extraction, not per-structure quantities.

## Contents

1. What is data and what is engine in this family
2. The six structure definitions and what places them
3. The village pool graph
4. The zombie variant
5. The start piece, with numbers
6. Terrain matching as villages and the outpost use it
7. Processor lists of the family (by reference to 36-2)
8. Decor, trees, farm pieces
9. What the templates carry: entities, chests, markers; bookkeeping at generation
10. Points of interest while a village is generated
11. The pillager outpost
12. Worked examples
13. Validation
14. Open questions

---

## 1. What is data and what is engine in this family

| Question | Answer | Where |
|---|---|---|
| Is there a village-specific generator class? | No. The five villages and the outpost are plain `jigsaw` structures (`JigsawStructure`); there is no per-structure piece class. Everything village-shaped is the pool graph (data) interpreted by the jigsaw engine (code) | section 2, 36-3 |
| Is there a village object, a "zombie village" flag or a village id in the structure start? | No. A start holds the ordered pieces; each piece stores its element (template, processors, projection), position, rotation, ground level delta, liquid settings and junctions (36-3 section 14.2). "Village" in the game rules is derived from points of interest at run time (44-3 section 1.1); "zombie village" is only a property of which templates and processor lists were chosen (section 4) | sections 4, 10 |
| Code-defined content specific to this family | The pillager outpost's spawn rule and leader roll (section 11.3), the registration path of points of interest during generation (section 10.1), the fixed behaviours of the five pool element kinds as the family uses them (section 3.4). Everything else is data | |
| Data the tool copies | `worldgen/structure/{village_*,pillager_outpost}.json`, structure sets `villages` and `pillager_outposts`, the 66 template pools below `village/` and `pillager_outpost/`, processor lists, biome tags `has_structure/village_*` and `has_structure/pillager_outpost`, structure tags, the 494 templates, the chest loot tables | 22, 23 |

Rule for implementers (36-1 section 1): never hard-code a pool name, a weight, a salt or a template. The numbers of this document that
come from data are quoted to define the validation profile (section 13) and the worked examples (section 12); an implementation reads them
from the loaded registries.

---

## 2. The six structure definitions and what places them

### 2.1 Field use (data, read from `worldgen/structure/*.json`)

All six elements have `type = minecraft:jigsaw` and the common settings of 36-1 section 3.1. The jigsaw-specific fields (schema and defaults:
36-3 section 3.1; engine: 36-3 sections 8 to 10) take these values:

| Field | Five villages | Pillager outpost |
|---|---|---|
| `start_pool` | `village/<variant>/town_centers` (variant = plains, desert, savanna, snowy, taiga) | `pillager_outpost/base_plates` |
| `size` (the depth limit `D`) | 6 | 7 |
| `start_height` | `{absolute: 0}` (provider, no draw) | the same |
| `project_start_to_heightmap` | `WORLD_SURFACE_WG` | the same |
| `max_distance_from_center` | the integer 80 | the same |
| `use_expansion_hack` | true | true |
| `start_jigsaw_name` | absent | absent |
| `pool_aliases` | absent (empty list) | absent |
| `dimension_padding`, `liquid_settings` | absent (defaults: zero padding; apply waterlogging) | absent |
| common `step` | `surface_structures` | the same |
| common `terrain_adaptation` | `beard_thin` | the same |
| common `spawn_overrides` | `{}` (no override: villages alter no spawn list) | `monster`, bounding box `full`, one entry: pillager, weight 1, count 1 to 1 (section 11.3) |

Consequences of the absent fields: no named start jigsaw, so the start piece's origin is the start position itself (36-3 section 9.3 step 2);
no aliasing, so every pool reference is literal; the start height is 0 before projection, so the start piece's y is purely the projected
surface (section 5).

### 2.2 The integer form of `max_distance_from_center` means a cube, not a tall prism (read this round)

`JigsawStructure$MaxDistance` is a record `(horizontal, vertical)`. Its codec reads either an integer or an object `{horizontal, vertical}`.
The integer form constructs the record with **both components equal to the integer** (the one-argument constructor passes the value twice,
and the encoder writes the integer form exactly when the two components are equal). Only the object form takes a `vertical` default
(`DimensionType.Y_SIZE`, 4064, 36-3 section 2.4). The six definitions here use the integer form, so their limit volume is
**80 blocks horizontally and 80 blocks vertically** around the stub position (section 5 gives the box).

> Discrepancy with 36-3: 36-3 section 3.1 (field table), section 13.2 and worked example 18.2 treat the integer form as horizontal 80 with
> vertical 4064. The bytecode (constructor `MaxDistance(int)` calls the two-argument constructor with the same value twice; the integer-form
> decoder is that constructor) says vertical = 80 for the integer form. Effect: a piece whose box leaves `[stub.y - 80, stub.y + 80 + 1)`
> cannot be placed. For villages (pieces are at most 10 blocks above the surface plus a few below) the effect is invisible on normal terrain
> and matters on steep ground and for the outpost's 30-tall base plate on mountains. Listed in Open question 1 for the 36-3 owner.

The validation in the codec (`verifyRange`) is satisfied: horizontal 80 plus the extra range 12 that any adaptation other than `none` adds
gives 92, below the limit 128.

### 2.3 Structure sets and biome tags (data; shown because the engines read them)

| Element | Value read | Engine |
|---|---|---|
| structure set `villages` | placement `random_spread`, `spacing 34`, `separation 8`, `salt 10387312`; five entries (plains, desert, savanna, snowy, taiga), each weight 1 | 36-1 sections 4.3, 5.2 |
| structure set `pillager_outposts` | placement `random_spread`, `spacing 32`, `separation 8`, `salt 165745296`, `frequency 0.2` with `frequency_reduction_method legacy_type_1`, `exclusion_zone {other_set: villages, chunk_count: 10}`; one entry, weight 1 | 36-1 sections 4.3 to 4.5 |
| biome tag `has_structure/village_plains` | the biomes `plains` and `meadow` (not `sunflower_plains`) | 36-1 section 5.3 |
| biome tag `has_structure/village_desert` / `_savanna` / `_snowy` / `_taiga` | `desert` / `savanna` / `snowy_plains` / `taiga` (one biome each) | |
| biome tag `has_structure/pillager_outpost` | `desert`, `plains`, `savanna`, `snowy_plains`, `taiga`, `grove` and the tag `is_mountain` | |
| structure tag `village` | the five village structures; the tags `on_<variant>_village_maps` each hold the one matching village (their use for maps is 19, inferred from the names) | 36-1 section 11 |
| structure tag `cats_spawn_in` | `swamp_hut` only: villages are not in it; the cat spawner's village case uses points of interest instead (44-3 section 1.6) | |

Reading of the exclusion zone (engine: 36-1 section 4.5): an outpost chunk is rejected when a `villages`-set candidate chunk (the placement's `isStructureChunk` test, whether or not a village results there) lies within 10 chunks. The check loops x and z over [c-10, c+10] (read this round in `ChunkGeneratorStructureState.hasStructureChunkInRange`), so the zone is a 21 x 21 chunk square (Chebyshev distance). It asks only whether the chunk is a candidate of the `villages` placement, not whether a village was generated: a candidate chunk whose biome or start check fails still excludes outposts. 36-1 section 4.5 states it the same way. The frequency reduction then keeps one
outpost chunk in five (36-1 section 4.4, `nextInt(trunc(1.0 / 0.2)) == 0`, i.e. `nextInt(5)`).

---

## 3. The village pool graph

### 3.1 Roles of the pools (data profile, read from all 66 pools and from the jigsaw blocks of the 494 templates)

A village is grown from one town-center template through jigsaw connections. Which pool a jigsaw asks for is stored in the template's
jigsaw block (`pool`), the connection names are the jigsaw `name` and `target` (the attach rule is 36-3 section 4.1: the parent's `target`
equals the candidate's `name`, fronts opposite, tops equal unless the parent's joint is `rollable`).

| Pool family (per variant unless noted) | Element kind and projection | What references it | What it contributes |
|---|---|---|---|
| `town_centers` | `legacy_single_pool_element`, `rigid` | the structure's start pool | the start piece: the bell and meeting point, with jigsaws for streets, villagers, cats, iron golem, well bottom (and, in the desert, camels) |
| `streets` | `legacy_single_pool_element`, `terrain_matching` | `street` jigsaws of centers and of streets; houses' `building_entrance` jigsaws point back into `streets` | road segments (corners, straights, crossroads, a turn); each carries `street` jigsaws onward, `building_entrance` jigsaws for houses and `bottom` jigsaws for decor |
| `terminators` | `legacy_single_pool_element`, `terrain_matching` | the fallback of `streets` and of `houses` | the end caps used when the depth limit is reached or nothing else fits (section 3.3) |
| `houses` | `legacy_single_pool_element`, `rigid`, plus one `empty_pool_element` | `building_entrance` jigsaws of streets and centers | houses, workshops, temples, farms, animal pens, stables, extra meeting points |
| `decor` | single elements (lamps) and `feature_pool_element` (section 8), `rigid`, plus `empty_pool_element` | `bottom` jigsaws on streets, houses and terminators | lamps, hay, trees, cacti, piles; many entries are empty |
| `trees` (plains, savanna, snowy) | one `feature_pool_element`, `rigid` | `bottom` jigsaws of some houses | one tree |
| `villagers` | `legacy_single_pool_element`, `rigid` | `bottom` jigsaws of houses and of **normal** centers only (zombie town centers carry no `villagers` jigsaw, section 4.1) | one villager template (section 9) |
| `common/animals`, `common/butcher_animals`, `common/sheep`, `common/cats` | single elements, `rigid` (animals and cats also hold an empty element) | `bottom` jigsaws of houses, centers and animal pens | livestock, horses, cats |
| `common/iron_golem` | one single element, fallback `empty` | `bottom` jigsaws of **normal** town centers only | one iron golem |
| `common/well_bottoms` | one single element | the well in the centers and in `common` | the shaft under the well |
| `desert/camel` | one single element | desert centers | the camel |

Every pool uses the fallback `minecraft:empty` except the `streets` and `houses` pools (fallback: the variant's `terminators`) and the
`zombie` copies of them (section 4). Pool elements are one of `legacy_single_pool_element` (all template elements of this family),
`feature_pool_element`, `list_pool_element` (outpost towers only) and `empty_pool_element`; no `single_pool_element` and no pool alias
appears. The legacy single element differs from the plain one only in its block-ignore processor (it skips structure blocks and air:
36-3 section 5.2).

### 3.2 Profile of the pools per variant (aggregates for validation; each cell is element count / weight sum, with the empty element's weight in brackets when present)

| Variant | town_centers | streets | terminators | houses (fallback terminators) | decor | villagers |
|---|---|---|---|---|---|---|
| plains | 8 / 204 | 16 / 49 | 4 / 4 | 37 / 87 (empty 10) | 5 / 7 (empty 2) | 3 / 12 |
| desert | 6 / 250 | 11 / 35 | 2 / 2 | 29 / 72 (empty 5) | 4 / 28 (empty 10) | 3 / 12 |
| savanna | 8 / 459 | 19 / 56 | 5 / 5 | 32 / 81 (empty 5) | 5 / 17 (empty 4) | 3 / 12 |
| snowy | 6 / 306 | 16 / 47 | 4 / 4 | 31 / 68 (empty 6) | 7 / 27 (empty 9) | 3 / 12 |
| taiga | 4 / 100 | 16 / 49 | 4 / 4 | 28 / 76 (empty 6) | 13 / 39 (empty 4) | 3 / 12 |

The element counts include the zombie town centers inside `town_centers` (plains 4 of 8, desert 3 of 6, savanna 4 of 8, snowy 3 of 6, taiga 2
of 4). The `zombie` pools are separate sets of the same shape (section 4). Other pools: `common/animals` 10 elements / weight 26 (empty 5),
`common/cats` 11 / 13 (empty 3), `common/butcher_animals` 4 / 8, `common/sheep` 2 / 2, `common/iron_golem` 1 / 1, `common/well_bottoms` 1 / 1,
`desert/camel` 1 / 1, `trees` (plains, savanna, snowy) 1 / 1. Total: 66 pools (62 below `village/`, 4 below `pillager_outpost/`).

### 3.3 How the graph descends (consequences of 36-3 sections 10 and 11 for these pools)

1. **Depth.** Villages have `D = 6`: the start piece is depth 0 and every connection adds one. A street served at depth 6 receives only the
   **fallback** of its pool (36-3 section 10.2 step 5): `terminators` for `streets` and `houses`, `empty` for everything else. Every
   terminator template carries a `street` jigsaw whose pool is `minecraft:empty` (the pool-less end of the road); the plains terminators and desert `terminator_01` carry nothing else, while desert `terminator_02` and the savanna `terminator_05` also carry `bottom` jigsaws that ask the variant's `decor` pool (the savanna one also a `building_entrance` jigsaw asking `houses`), so the road ends there but decor can still be drawn. A village therefore spans at most 6 road
   segments from the center, and its horizontal reach is bounded additionally by the 80 block limit (section 2.2).
2. **The empty element is a stop sign, not a miss.** In the candidate loop the first candidate that is the empty element ends the loop for
   that jigsaw (36-3 section 10.2 step 7). Because the candidates are a shuffled copy of the pool's expanded list (each element repeated
   `weight` times), the empty element ends the search at the position at which it is drawn: the elements shuffled before it that cannot be
   placed are tried, the elements after it never are, and the fallback is never reached when the empty element is present in the pool.
   For a jigsaw whose first drawn candidate fits, the chance that nothing is attached equals the empty weight over the pool weight: plains
   houses 10/87, desert 5/72, savanna 5/81, snowy 6/68, taiga 6/76; decor pools 2/7, 10/28, 4/17, 9/27, 4/39 (same order). (Arithmetic on
   the read weights; first-fit behaviour from 36-3.)
3. **Streets and houses compete for the same free volume.** A street's `building_entrance` jigsaws offer `houses` (so a house's own
   `building_entrance` goes back to `streets`, and that street's streets continue the road); a house whose box collides is skipped, other
   candidates and rotations are tried in shuffled order, so an entry never forces a house into occupied space.
4. **Interior connections.** Jigsaws pointing into their own template (the golem, cats, villagers and decor on town centers and houses) have
   target cells inside the parent's box; they are served against the parent's own box and not against the global free volume (36-3 section
   10.5). That is why a town center places its golem, cats and villagers even when the surroundings are crowded: they only compete with each
   other inside the center's box. The expansion hack (`use_expansion_hack: true`) reserves above a short template the height its inward
   jigsaws could bring (36-3 section 10.4); for villages this is what keeps decor and trees (up to the tree feature's reserve) from being
   walled in by a neighbouring house roof.

### 3.4 The pool element kinds as this family uses them (read; 36-3 section 5 is the authority)

| Kind | Facts read this round that the family depends on |
|---|---|
| `legacy_single_pool_element` | Template placed with the settings of 36-3 section 5.1: structure-block-ignoring processor replaced by the structure-and-air one, jigsaw replacement unless jigsaws are kept, then the element's processor list, then the projection's processors (`terrain_matching`: one `gravity` processor with `WORLD_SURFACE_WG` and offset -1; `rigid`: none); `ignoreEntities` false, entities finalised (reason `STRUCTURE`), known shape true, flags 18 |
| `feature_pool_element` | Size zero, so its box is the single block at its origin; exactly one jigsaw, at its origin, pointing `down` with top `south`, joint `rollable`, name absent (null), target `empty`, pool `empty`. A null name matches any parent whose front is opposite (36-3 section 4.1). Placing it runs the element's placed feature once, at the piece's position, with the generation random source and the world-generation level; the result is the feature's own success flag |
| `list_pool_element` | Takes its jigsaws from the **first** element only; its box is the union of the boxes of its non-empty elements; size is the component-wise maximum; places its elements in list order and returns false at the first failure; imposes its own projection on every element |
| `empty_pool_element` | Size zero, no jigsaws, no box (asking for its box is an error), placing it succeeds trivially; its own projection is `terrain_matching` (irrelevant: it is never built into a piece) |
| ground level delta | Every element of this family has the default delta of 1 (`StructurePoolElement.getGroundLevelDelta`) |

### 3.5 Data quirks that change behaviour (read; all in the shipped data)

| Finding | Effect |
|---|---|
| The snowy shepherd's house template (`village/snowy/houses/snowy_shepherds_house_1`) names its entrance jigsaw `minecraft:buidling_entrance` (sic), both `name` and `target`. Every parent's `target` is `minecraft:building_entrance` | The attach rule can never match (parent target must equal the candidate's name), so this house can be drawn (weight 3 in `snowy/houses`, weight 2 in the zombie pool) but is **never placed**; every draw of it consumes the shuffles of 36-3 section 17 and fails. An implementation must reproduce this by following the rule, not by "fixing" the name. (Computed from the attach rule and the data.) |
| `village/decays` holds 3 templates (`grass_9x9`, `grass_11x13`, `grass_16x16`) and no pool, structure or code path read in this round refers to them | Dead data in this version (Open question 2) |
| Three town centers of the desert and the camel template use jigsaws named `minecraft:empty` (name and target both empty) | They attach to each other by the ordinary rule (target equals name); that is how the camel is attached |
| `taiga_masons_house_1` (2 jigsaws, normal only), `taiga_temple_1` (1, normal) and the zombie `taiga_temple_1` (1) carry `minecraft:empty`-named jigsaws with pool `empty` (4 in all; with the camel template and the three desert centers that is the 8 of section 13; the zombie masons house has none) | They never produce anything |
| Zombie pools reuse normal templates (section 4.2) | Partial infection |

---

## 4. The zombie variant

### 4.1 How a zombie village is chosen

There is no separate zombie structure. The start pool `town_centers` of each variant contains both the normal centers and their zombie
copies (templates under `village/<variant>/zombie/town_centers/`). Their processor list: plains (4 of 4 zombie centers), desert (3 of 3), savanna (4 of 4) and taiga (2 of 2) use `zombie_<variant>`; **snowy does not**: all six snowy `town_centers` elements, normal and zombie, use an inline empty processor list, and `zombie_snowy` is referenced only by the `snowy/zombie/houses` pool (30 elements) and the `snowy/zombie/decor` pool (3). The start piece is one uniform draw
from the expanded element list (36-3 section 9.2 step 2), so the chance that a village is zombie is the zombie weight over the pool weight:

| Variant | Zombie weight / pool weight | Probability |
|---|---|---|
| plains | 4 / 204 (four centers, weight 1 each, against four of weight 50) | 1/51 = 1.96% |
| desert | 5 / 250 (weights 2, 2, 1 against 98, 98, 49) | 2.00% |
| savanna | 9 / 459 (2, 1, 3, 3 against 100, 50, 150, 150) | 1/51 = 1.96% |
| snowy | 6 / 306 (2, 1, 3 against 100, 50, 150) | 1/51 = 1.96% |
| taiga | 2 / 100 (1, 1 against 49, 49) | 2.00% |

The choice is made once per village at the start piece; everything below follows from which templates the zombie center and the zombie pools
reference. A zombie center does not reference any villagers pool: across all five variants the zombie town-center templates carry no `villagers` jigsaw. Their jigsaws point only at `<variant>/zombie/streets`, `common/cats` and, in some variants, `zombie/decor`, `zombie/houses` and `common/well_bottoms`. A normal center's `bottom` jigsaws ask the normal `villagers` pool.

### 4.2 How far the infection reaches (read from the pools and the template jigsaws)

1. **Streets are fully zombie** (every element of every `<variant>/zombie/streets` pool uses a `zombie/` template and, in four variants, the
   street processor list; the desert zombie streets use an inline empty list with no street processor). The zombie street pools reference zombie
   decor, zombie houses and zombie streets.
2. **Houses are partly zombie.** A `zombie/houses` pool lists, per variant, some templates under `zombie/houses/` and other templates that are
   the **normal** templates reused with the zombie processor list. Elements using normal templates, over the non-empty elements of the
   zombie `houses` pool: plains 17 of 35 (weight 35 of 83 including the empty weight), desert 18 of 28 (44 of 68), savanna 18 of 31 (39 of
   72), snowy 19 of 30 (38 of 65), taiga 9 of 26 (20 of 74). Such a house gets the zombie block rules (webs, missing doors and torches) but
   keeps the jigsaws of the normal template: its villagers jigsaw asks the **normal** villagers pool (living villagers), its entrance and decor
   jigsaws ask the normal pools, so a street attached through it continues as a **normal** street. Zombie decor pools have the same mix
   (non-zombie templates: plains 1 of 4, desert 1 of 3, savanna 1 of 4, snowy 3 of 6, taiga 4 of 9).
3. **Animals, cats, sheep and trees are shared.** Zombie templates reference the common pools (`common/animals`, `common/cats`,
   `common/butcher_animals`, `common/sheep`, and the variant's `trees`): a zombie village still has livestock and cats (cat jigsaws appear in
   the zombie centers: plains zombie centers 9, desert 5).
4. **No iron golem.** All 16 jigsaws that reference `common/iron_golem` (one in each normal town-center template: plains 4, desert 3, savanna
   4, snowy 3, taiga 2) are in normal centers. A zombie center and the rest of a zombie village never place a golem.
5. **Terminators.** The zombie `streets` pool of plains, snowy and taiga names the **normal** `terminators` pool as its fallback, and so do the
   zombie `houses` pools of plains, snowy and taiga; desert and savanna have zombie `terminators` pools: the savanna ones (5 elements) use `street_savanna`, the desert ones (2 elements, fallback `empty`) use an inline empty list.
6. **Zombie villagers.** The zombie villagers pool is referenced only by the `villagers` jigsaws of the templates in the `zombie/houses` folders (17 plains, 13 snowy, 12 savanna, 11 desert, 8 taiga; none of them asks the normal pool); zombie centers have none (section 4.1). It has two elements (unemployed 10, nitwit 1; no baby element), each a `zombie_villager`
   template with `PersistenceRequired` 1 (44-2 section 10.5), against the normal pool's three (unemployed 10, nitwit 1, baby 1; 12 in all). A
   zombie village has no sleeping or working villagers except those that come from the reused normal houses (item 2).

### 4.3 The state a zombie village keeps

None beyond its pieces. The generated blocks and the placed entities are the whole effect. A zombie village's bells, beds and workstations
become points of interest exactly as in a normal village (section 10), so a zombie village counts for `isVillage` once something claims
them; the zombie villagers are persistent mobs and claim nothing. Converting a zombie villager back to a villager is the mob's own
behaviour (19), not a structure rule.

---

## 5. The start piece, with numbers

The sequence is 36-3 sections 8 and 9; this section applies it to the village constants.

1. Start position `pos = (chunk.minX, start_height sample = 0, chunk.minZ)`. No random draw for the `absolute` provider.
2. `rotation = Rotation.getRandom(random)` (first draw, `nextInt(4)`; the order of `Rotation` is none, clockwise 90, clockwise 180,
   counterclockwise 90), then the center `element = startPool.getRandomTemplate(random)` (second draw, `nextInt(expanded size)`: 204 for plains).
3. The origin is `pos` (no start jigsaw name). The start piece's ground level delta is 1.
4. Let `box` be the piece's bounding box at the origin and rotation, `cx = (box.maxX + box.minX) / 2` and `cz = (box.maxZ + box.minZ) / 2` (integer
   division). Because `project_start_to_heightmap` is present, the structure first asks whether any valid biome exists in that column
   (`couldStructureExistInColumn`; no structure if not), then `y = pos.y + getFirstFreeHeight(cx, cz, WORLD_SURFACE_WG)`, and the piece is moved
   by `y - (box.minY + 1)`. In words: the bottom layer of the center template (template y = 0, the ground layer) sits one block below the first
   free height at the center column, i.e. on the top solid block.
5. The stub position is `(cx, y + offsetY, cz)` with `offsetY = 0` here; the biome of the structure is tested at the quart cells of that
   position (36-1 section 5.3). Because the centre of the center piece is what is tested, a village whose first piece straddles a biome border
   is accepted or rejected by the biome at its middle column only.
6. The free volume for the other pieces is the box `x in [cx - 80, cx + 80 + 1)`, `z in [cz - 80, cz + 80 + 1)`,
   `y in [max(y - 80, min_y + padding.bottom), min(y + 80 + 1, max_y + 1 - padding.top))` minus the start piece's box (section 2.2: the vertical component is 80). The six structures here declare no padding (bottom and top are 0, the default; `dimension_padding` is not set in the six definitions, section 2.1), so the formula reduces to `max(y - 80, min_y)` and `min(y + 81, max_y + 1)`.

Worked numbers are in section 12.1.

---

## 6. Terrain matching as villages and the outpost use it

Roads (`streets`, `terminators`) and the outpost's `feature_plates` are `terrain_matching`; everything else is `rigid`. For this family the
rules of 36-3 section 12 mean:

| Parent to child | Where the child is put vertically | Consequence in a village |
|---|---|---|
| rigid to terrain_matching (a center or house to a street) | the child's connecting jigsaw cell is put at the first free height above the surface at the parent's jigsaw column (`getFirstFreeHeight` with `WORLD_SURFACE_WG`, regardless of the structure's own projection setting) | roads leave a house at the local ground height |
| terrain_matching to terrain_matching (street to street) | the same, at the next column | a road follows the terrain segment by segment |
| terrain_matching to rigid (a street to a house) | the house origin is set from the surface at the street's jigsaw column, `surfaceY - qy` (`qy` = the house jigsaw's local y), and the house keeps that height | houses are level and step up and down between segments |
| rigid to rigid (center to well bottom, house to decor, interior jigsaws) | pure alignment, no vertical shift | wells, lamps and animals stay on their template floor |

Blocks of a `terrain_matching` piece are additionally moved one by one when they are written: the `gravity` processor (`WORLD_SURFACE_WG`,
offset -1, 36-2 section 9.5) puts each template block at `height(x, z) - 1 + templateY`, so a road slab follows the exact terrain per column
(and a road crossing water is repaired by the street processor lists, section 7). The beardifier treats `rigid` pieces by their ground level
and the junctions by their ground height (36-1 section 9); `terrain_adaptation: beard_thin` is the village setting (36-1 section 9.1).

The height used is the noise generator's column query for the start and connection columns (the generic noise column query shared with the Nether, 37-2 section 6.5, 36-1 section 5.4; for the overworld terrain that the villages and outposts sit on, see 10); the `gravity` processor reads the level's heightmap (36-2 section 9.5).

---

## 7. Processor lists of the family (by reference to 36-2)

The family uses 17 processor lists (data, read from `worldgen/processor_list`). Processor engines: 36-2 sections 7 to 9; rule evaluation:
36-2 section 8 (first matching rule wins; one fresh random source per block seeded from the block's absolute position, shared by the rule
tests in order).

| List (count) | Content | Used by |
|---|---|---|
| `mossify_10_percent`, `mossify_20_percent`, `mossify_70_percent` | one `rule` processor: template cobblestone becomes mossy cobblestone with probability 0.1 / 0.2 / 0.7 (`random_block_match` input test, `always_true` location test) | most plains and taiga houses (10%), two plains centers (20%), one plains center and one meeting point (70%), taiga centers (10%) |
| `street_plains`, `street_savanna`, `street_snowy_or_taiga` | one `rule` processor with 4, 4 and 5 rules (read from the three lists): dirt path over water becomes planks (oak for plains, acacia for savanna, spruce for snowy and taiga); the snowy and taiga list has a second planks rule, dirt path over `ice` becomes spruce planks, which is why it has 5 rules; a path block becomes grass with probability 0.1 for plains and 0.2 for savanna, snowy and taiga; grass blocks and dirt over water become water | the `streets` and `terminators` pools (normal and zombie) of plains, savanna, snowy and taiga; the desert `streets`, `terminators`, `zombie/streets` and `zombie/terminators` pools use an inline empty list and no street list |
| `farm_plains`, `farm_desert`, `farm_savanna`, `farm_snowy`, `farm_taiga` | one `rule` processor with 3, 2, 1, 2 and 2 rules: template wheat is replaced by other crops by probability (section 8.3) | farm templates |
| `zombie_plains`, `zombie_desert`, `zombie_savanna`, `zombie_snowy`, `zombie_taiga` | one `rule` processor with 17, 10, 14, 13 and 12 rules, all with the `always_true` location test: doors (block tag `doors`) become air, torches and wall torches become air, cobblestone becomes mossy cobblestone (0.8, plains) and several template blocks become cobwebs with small probabilities (plains: cobblestone 0.07, mossy cobblestone 0.07, white terracotta 0.07, oak log 0.05, oak planks 0.1, oak stairs 0.1, stripped oak log 0.02, glass pane 0.5), two glass-pane states become brown stained glass panes (plains, savanna, snowy, taiga), and the farm crop replacements | zombie centers of plains, desert, savanna and taiga (the snowy centers, normal and zombie, use an inline empty list), zombie houses and decor (`zombie_snowy`: only the 30 zombie house and 3 zombie decor elements) |
| `outpost_rot` | one `block_rot` processor, `integrity 0.05` (36-2 section 9.2): each block is dropped with probability 0.05 | the overgrown watchtower |

All rule lists use the processor-rule fields of 36-2 section 8.2 (`input_predicate`, `location_predicate`, `output_state`, defaulted
`position_predicate` and `block_entity_modifier`); the predicate kinds used are `random_block_match`, `block_match`, `blockstate_match`,
`tag_match` (input) and `always_true`, `block_match` (location). The pool elements with `{"processors": []}` (an inline empty list) use no
processor of their own; the engine still adds the structure-block/air ignore and jigsaw replacement of 36-3 section 5.

The jigsaw replacement matters for this family: the blocks that replace the connecting jigsaws are the templates' `final_state` (data;
across the village and outpost templates 1972 jigsaw blocks: `structure_void` 1124, `grass_block` 373, `dirt` 66, `air` 62, `dirt_path` 53,
`smooth_sandstone` 49, `sand` 47, `cobblestone` 36, planks and stairs of the variant's wood, a few others). Road connection jigsaws carry the
ground block of the variant, `bottom` jigsaws mostly `structure_void` (leave the world as it is). 36-2 section 9.6 specifies the replacement.

---

## 8. Decor, trees, farm pieces

### 8.1 Features in pools (`feature_pool_element`)

The family's feature elements reference placed features by id (data in `worldgen/placed_feature`, engine in 35 section 1). Feature elements
occur in the `decor` pools (all variants) and the `trees` pools (plains, savanna, snowy):

| Pool | Placed features (weights; the empty element is separate) |
|---|---|
| plains decor | `oak` 1, `flower_plain` 1, `pile_hay` 1 |
| plains / savanna / snowy `trees` | `oak` / `acacia` / `spruce`, 1 each |
| desert decor | `patch_cactus` 4, `pile_hay` 4 |
| savanna decor | `acacia` 4, `pile_hay` 4, `pile_melon` 1 |
| snowy decor | `spruce` 4, `pile_snow` 4, `pile_ice` 1 |
| taiga decor | `spruce` 4, `pine` 4, `pile_pumpkin` 2, `patch_taiga_grass` 4, `patch_berry_bush` 1 |

The zombie decor pools (`<variant>/zombie/decor`) are not copies of the normal ones; the weights differ (read from the 10 pools; each cell is element count including the empty element / weight sum, then the empty chance):

| Variant | Normal decor | Zombie decor | Difference |
|---|---|---|---|
| plains | 5 / 7, empty 2/7 | 5 / 6, empty 2/6 | lamp weight 1 (normal 2); the three features are unchanged |
| desert | 4 / 28, empty 10/28 | 4 / 28, empty 10/28 | none (the lamp uses `zombie_desert`) |
| savanna | 5 / 17, empty 4/17 | 5 / 17, empty 4/17 | none (the lamp uses `zombie_savanna`) |
| snowy | 7 / 27, empty 9/27 | 7 / 22, empty 7/22 | three lamp posts weight 1 each (normal 4, 4, 1); `pile_ice` weight 4 (normal 1); empty 7 (normal 9) |
| taiga | 13 / 39 (weights include empty 4) | 10 / 26, empty 4/26 | no `taiga_lamp_post_1` (normal weight 10), no `taiga_decoration_5` or `_6`; decorations 1 to 4 and the five features keep their weights |

The empty chances of section 3.3 item 2 (decor 2/7, 10/28, 4/17, 9/27, 4/39) hold for the normal pools only; the zombie ones are plains 2/6, desert 10/28, savanna 4/17, snowy 7/22 and taiga 4/26. (The review that prompted this table gave 2/5, 7/27 and 4/24; the sums of the read weights give the values here.) The 3.2 row for taiga decor is the normal pool. The feature ids repeat.

How a feature piece behaves is fixed by the element (section 3.4): a 1 x 1 x 1 box at the jigsaw cell (the `bottom` jigsaw of a street, house or
terminator, cell above the road), placed after the template blocks of the whole piece list in piece order, running the placed feature once at that
position. If the feature fails (for example a tree with no room) nothing is placed and nothing is retried; the piece stays in the start and
its box stays reserved. Because the piece box is one block, decor neither blocks neighbouring pieces nor is blocked by them except at its
own cell.

### 8.2 Lamps and decor templates

The single-template decor elements are lamp templates (`plains_lamp_1`, `desert_lamp_1`, and others of the variant) and some taiga and snowy
decor pieces; they follow the rules of any legacy single element. Their weights and the empty weight are in section 3.2.

### 8.3 Farm pieces

Farm templates (`*_large_farm_*`, `*_small_farm_*`, `*_animal_pen_*` are not farms) use a `farm_<variant>` list. Crops are rules on the template's
wheat; the rules are tried in order for each wheat block and the first match wins (36-2 section 8.1), each rule test drawing once from the
block's own random source when its input block matches. So the replacement chances are sequential:

| `farm_plains` (3 rules: carrots 0.3, potatoes 0.2, beetroots 0.1) | Probability per template wheat block |
|---|---|
| becomes carrots | 0.3 |
| becomes potatoes | 0.7 x 0.2 = 0.14 |
| becomes beetroots | 0.7 x 0.8 x 0.1 = 0.056 |
| stays wheat | 0.7 x 0.8 x 0.9 = 0.504 |

Other variants use the same method with their own rule lists (desert: wheat to beetroots 0.2 then melon stems 0.1, so beetroots 0.2 and melon
stem 0.8 x 0.1 = 0.08 with wheat remaining 0.72; the savanna, snowy and taiga lists are one to two rules of the same kind). The zombie lists
include the same crop rules (plains zombie: the same three) after the decay rules. Because each block's random source is seeded from its
absolute position (36-2 section 8.1), the pattern of a farm is a function of its position and the template, not of the generation random.

---

## 9. What the templates carry: entities, chests, markers; bookkeeping at generation

### 9.1 Structure blocks (data markers)

None. No template of the village or outpost families contains a structure block (profile: 0 of 494). The structure-block ignore processor is
therefore a no-op here, and no `handleDataMarker` logic applies to villages or outposts (44-2 section 10 lists the families that have
markers).

### 9.2 Entities placed by templates (reference: 44-2 section 10.5 for the placement mechanism and the full entity list)

Villages place entities only through template entities of the `villagers`, `animals`, `cats`, `sheep`, `butcher_animals`, `iron_golem` and
`camel` pools. Additions read this round, not in 44-2:

| Fact | Value |
|---|---|
| One jigsaw, one entity | Each cat, villager, golem and camel template holds one entity; the 9 livestock templates (cows, pigs, 5 horse templates, 2 sheep templates) hold 15 entities between them (cows 2, pigs 2, horses 7, sheep 4), so some hold more than one; a pool that contains the empty element makes the spot optional (section 3.3 item 2) |
| Iron golem | `common/iron_golem` has one element (weight 1, no empty element), so every golem jigsaw that is served and fits yields exactly one golem. The 16 golem jigsaws are the 16 normal town-center templates' (section 4.2 item 4); each is an interior jigsaw (section 3.3 item 4), so a normal village gets one golem at generation unless its cell is occupied by another interior piece of the same center (inferred from the interior-volume rule; the golem cell is a free 1 x 3 x 1 above the center floor in the samples read). The template stores `PersistenceRequired` 1 (44-2), `PlayerCreated` 0, default attributes (max health 100) |
| Villager templates | Three normal templates per variant (15 in all, matching the entity total of section 13 item 8): `baby` (`Age -21359`, `ForcedAge 0`, no `food_level`), `nitwit` and `unemployed` (`Age 0`). All have `VillagerData.level 1` and `Xp 0`; profession `none` (unemployed, baby) or `nitwit`; empty `Gossips`, `Inventory` and attributes lists; `CanPickUpLoot` 1; `PersistenceRequired` 0 (they can despawn like any mob far from players, 44-2 section 10.5). The stored `VillagerData.type` is per variant (`plains`, `desert`, `savanna`, `snow`, `taiga`; read in the plains and snowy templates), but see 9.3 |
| Zombie villager templates | the same with `zombie_villager` ids, `PersistenceRequired` 1; no baby |
| Cats | Ten coat templates (black, british, calico, persian, ragdoll, red, siamese, tabby, white, jellie) of the `cats` pool, each `PersistenceRequired` 1 with its `variant` fixed (the `jellie` template stores `all_black`) and `CollarColor` 14 |
| Armor stands | the taiga armorer house holds two (head iron helmet, chest iron chestplate); not mobs, no finalisation |

### 9.3 Villager finalisation at generation (cross-reference)

A template villager goes through `finalizeSpawn(difficulty, STRUCTURE, no group data)` after its tag is loaded (44-2 section 10.5).
`Villager.finalizeSpawn` calls `finalizeVillagerType` **unconditionally**, for every spawn reason: the stored `VillagerData.type` is replaced
by the type of the biome at the villager's block (`VillagerType.byBiome`; the biome-to-type table is in 19 (villager type by biome at spawn) and 44-1 (the spawn-finalise table, row `Villager`)). So a village built across a biome border has
villagers of the type of the biome at each villager's block, not the variant's; the biome tag `has_structure/village_plains` includes
`meadow`, which is not in the type table (inferred from the table of 19), so its villagers take the table's default as 19 specifies. Only the reset of the profession to `none` is conditional on `BREEDING`. `AgeableMob.finalizeSpawn` makes
no random draw here: it rolls for a baby only when the group size is above zero, and the first mob created with no group data starts at group
size zero, so a template villager's `Age` is exactly the stored one (the `baby` template stays a baby; no adult becomes a baby).

### 9.4 Professions are not assigned by the village pool

The villagers pools place only `none` and `nitwit` villagers. A profession appears later: the villager brain acquires a free job-site point
of interest of tag `acquirable_job_site` (44-3 sections 1.2 and 2; 19 section 22), which sets the profession from the site's type. The
village's workstation blocks are inside the house templates (section 10.3), so a village is generated with as many professions available as
its houses have free workstations, and the number of villagers placed (section 9.2: one per villager jigsaw) is independent of it.
The same pools therefore give a fresh village its initial villager count. Villager jigsaws in the plains templates (data profile):

| Group | Villager jigsaws |
|---|---|
| fountain center | 3 |
| meeting point 1 | 2 |
| meeting point 2 | 3 |
| meeting point 3 | 2 |
| the four normal plains centers, total | 10 |
| plains houses (all house templates) | 17 |
| zombie plains houses folder | 17 (these ask the zombie villagers pool, section 4.2 item 6) |

### 9.5 Chests and loot

Chest block entities in the templates carry only the key `LootTable` (no `LootTableSeed`, no items). Over all village templates there are 62
loot chests, by loot table: `village_armorer` 1, `village_butcher` 1, `village_cartographer` 5, `village_desert_house` 8, `village_fisher` 1,
`village_fletcher` 1, `village_mason` 1, `village_plains_house` 6, `village_savanna_house` 10, `village_shepherd` 1, `village_snowy_house` 4,
`village_taiga_house` 10, `village_tannery` 4, `village_temple` 1, `village_toolsmith` 3, `village_weaponsmith` 5 (all
`minecraft:chests/village/<name>`, the table files exist in the jar; their content is loot data, 26). There is no loot rule in code for villages:
the chest is placed with the template (36-2 section 5.3) and the table is rolled when the chest is first opened, with the seed assignment of
the container (31 section 1; the template stores no seed). The outpost has 2 chests (section 11.2).

### 9.6 Spawning around villages (not structure code; pointers)

No spawn list changes inside a village (empty overrides, section 2.1). The mobs tied to villages are: cats by the cat spawner (44-3 section
1.6), golems from villager panic and gossip (19 section 22.10, 44-2 section 13), zombie sieges (44-3 section 1.7), raids (20 section 14).
They read points of interest, not the structure start.

---

## 10. Points of interest while a village is generated

### 10.1 The registration path (read this round)

Structure templates are written during the features stage through `WorldGenRegion.setBlock`. That method, after the chunk accepts the new
state and when the replaced state is not null, calls `ServerLevel.updatePOIOnBlockStateChange(pos, oldState, newState)` on the owning
`ServerLevel`. That call is the one specified in 44-3 section 1.4a: when the two states map to different point-of-interest types (the lookup
is by block state, `PoiTypes.forState`), a remove task (for the old type) and then an add task (for the new type) are queued on the server's
main-thread task queue (`MinecraftServer.execute`), not run on the generation thread. Consequences:

1. Every bed head, bell, job-site block and cauldron variant that a template writes becomes a record when the queued task runs on the main
   thread, shortly after the writing chunk stage, with all tickets free (44-3 section 1.3). Replacing a block by another of the same POI type
   (a bed by a bed) queues nothing.
2. The queue is the only link between generation and the point-of-interest data: the block scan (`PoiManager.checkConsistencyWithBlocks`,
   `PoiSection.refresh`) runs only when a chunk is **read from disk** (`SerializableChunkData.read` calls it for each chunk section; among the packages searched, `ensureLoadedAndValid` is called only by the portal forcer, and the range queries of 44-3 section 1.3 read the sections already in memory). A freshly generated village is thus registered by the queue, a reloaded one by the scan plus the saved sections (45-6 section 8.4
   for the saved layout, 07 section 8 for the `poi/` folder).
3. Worldgen block changes that replace a POI block (the street processors turning grass into water, a processor dropping a block with
   `block_rot`, the zombie rules removing doors and torches) go through the same method, so a processor that removes a workstation removes
   its record. In this family only the zombie lists and `block_rot` remove blocks, and none of them targets a POI block (their inputs are
   doors, torches, cobblestone, logs, planks, stairs, glass panes and crops).
4. Newly added records are unclaimed. A POI is "occupied" only when a ticket is taken (44-3 section 1.3), and a village centre section needs an
   occupied POI of the `village` tag (44-3 section 1.4 rule 1). So immediately after generation `isVillage` is false everywhere in the
   village, and becomes true only when a villager claims a bed, a workstation or a bell ticket. Everything that tests `isVillage`
   (patrol spawn gating uses `isCloseToVillage`, zombie sieges, raids, villager panic) therefore needs the first claim.

### 10.2 POI types and the family (verified this round; the table is 44-3 section 1.2)

`PoiTypes.bootstrap` registers 21 types in the order of 44-3 section 1.2: fourteen with one ticket and valid range 1 (the thirteen job sites
and `home`), `meeting` with 32 tickets and range 6, and six with zero tickets (beehive, bee nest, nether portal, lodestone, test instance,
lightning rod). The register call arguments read here confirm (tickets, range) = (1, 1) for the first 14, (32, 6) for the bell and (0, 1) for
the last six. `PoiType` holds the matching states, `maxTickets` and `validRange`; the type tag `acquirable_job_site` (the thirteen job
sites), `village` (job sites, `home`, `meeting`) and `bee_home` are 44-3 section 1.2.

### 10.3 Census of what the templates place (data profile)

Blocks that make POIs, counted over all village templates (normal and zombie variants, once per template occurrence in the files; not per village):

| Block | Count | POI type |
|---|---|---|
| bell | 39 | meeting (32 tickets) |
| bed (head part) | plains 32, desert 24, savanna 24, snowy 28, taiga 26 (134 in all) | home |
| composter, barrel | 18 each | farmer, fisherman |
| loom | 13 | shepherd |
| water cauldron | 11 (no plain or lava cauldron appears) | leatherworker |
| grindstone | 11 | weaponsmith |
| smoker, brewing stand | 9 each | butcher, cleric |
| blast furnace, lectern | 8 each | armorer, librarian |
| cartography table, fletching table, stonecutter, smithing table | 6 each | cartographer, fletcher, mason, toolsmith |

By variant the bell count is plains 14, desert 6, savanna 10, snowy 6, taiga 3. No beehive, bee nest, lightning rod or lodestone appears in a
village template. The plains town-center templates read contain one or two bells (fountain 1, meeting point 1: 1, meeting point 2: 1, meeting point 3: 2) and the desert meeting point 1 one; the other variants' centers were not counted individually. A village with several extra meeting-point houses therefore has several `meeting` POIs; the
raid-centre and cat-spawner rules sum over them (44-3 sections 1.5, 1.6).

### 10.4 What a village needs to be live

Following 44-3 section 1.4: a village is counted when a section (16 cubic) holds an occupied POI of the `village` tag; the section's
Chebyshev neighbours up to distance 1 satisfy `isVillage`. The templates supply the POIs; villagers supply the claims (a sleeping villager
claims its `home` bed; a villager with a profession claims its job site; the bell's tickets are taken by villagers gathering at the meeting
point, 44-3 section 2). With no villager (the zombie variant, or villagers killed or despawned), the records stay unclaimed and the area is
never a village in the game's sense.

---

## 11. The pillager outpost

### 11.1 The pool graph (data profile, 11 templates, 4 pools)

| Pool | Elements | Referenced by |
|---|---|---|
| `base_plates` (start) | one `legacy_single_pool_element` `base_plate`, `rigid`, no processors | the structure |
| `feature_plates` | one `legacy_single_pool_element` `feature_plate`, `terrain_matching` | 3 `plate_entry` jigsaws of the base plate (west, south, east faces, at local (0,0,7), (7,0,15), (15,0,8)) |
| `features` | seven `legacy_single_pool_element` (`feature_cage1`, `feature_cage2`, `feature_cage_with_allays`, `feature_logs`, `feature_tent1`, `feature_tent2`, `feature_targets`), weight 1 each, `rigid`; plus the empty element, weight 6; total weight 13 | 15 jigsaws of the feature plate (named `feature`, facing up) |
| `towers` | one `list_pool_element` of `watchtower` (no processors) and `watchtower_overgrown` (`outpost_rot`), `rigid` | 2 `entrance` jigsaws of the base plate (local (7,1,14) and (8,1,14), north-up, adjacent) |

Templates: `base_plate` 16 x 30 x 16 (the 30 blocks of height are a ground column), `feature_plate` 16 x 4 x 32, `watchtower` 15 x 21 x 15,
`watchtower_overgrown` 15 x 23 x 15, the seven feature templates 3 to 7 blocks on a side and 3 to 4 tall (cages 7 x 4 x 7, logs 6 x 3 x 7, targets 3 x 3 x 7, tents 6 x 4 x 7), plus the plate-entry connections. The feature plate also carries its own `plate_entry` jigsaw at local (15,0,7), facing east-up, pool `empty`: its connector to the base plate (the base plate's three entries are the ones above). All
fallbacks are `minecraft:empty`. Jigsaw names: `plate_entry`, `entrance`, `feature`. The feature templates' own jigsaws (`feature`, pool `empty`)
and the tower's `entrance` jigsaw (pool `empty`) end the graph.

Because the pools end there, the generation never reaches the depth limit `D = 7`: base (0), plates and tower (1), features (2). The final extent
is set by collisions, not by depth.

Consequences (computed from the data and 36-3):

1. **Towers.** The two adjacent `entrance` jigsaws of the base plate both ask `towers`; whichever is served first places the tower list element;
   the second would need the same 15 x 21 x 15 box shifted by one block, which overlaps the first tower, so it is rejected (inferred from
   geometry; the second jigsaw stays open and generates nothing). One watchtower per outpost; the list element places `watchtower`, then
   `watchtower_overgrown` over the same box (the list's box is the union; the second element's `block_rot` can remove 5% of its own blocks).
   Hence whether the **overgrown** variant's blocks overlay the plain tower's blocks is by placement order: both templates are written, the
   overgrown one second, so it overrides (inferred from list order; 36-3 section 5.3).
2. **Feature slots.** Each of the up to three plates (rigid base plate, `terrain_matching` plates) offers 15 feature jigsaws. For one free
   jigsaw the first drawn candidate is empty with probability 6/13 (nothing placed); otherwise the drawn template is tried in shuffled
   rotations and kept if its box fits. Features are 6 to 7 blocks wide (`feature_targets` only 3) and the jigsaws 2 to 4 blocks apart, so most slots collide with an earlier
   feature: the expected number of features is well below 15 per plate (not computed).
3. **The golem and the allays.** `feature_cage1` stores one iron golem (not persistent), `feature_cage_with_allays` stores two allays
   (persistent): they are the only mobs the outpost's templates place (44-2 section 10.5). They exist only if the drawn cage is placed.

### 11.2 Loot

Two chests, one in each watchtower template (`watchtower`, `watchtower_overgrown`, at local (9, 14, 10), facing west, not waterlogged),
both with `LootTable minecraft:chests/pillager_outpost` and no seed. The tables' data and the datapack variant of the file (a
`trade_rebalance` pack carries its own copy) are loot data (26).

### 11.3 Pillager spawning and patrols (code)

1. **Spawn override.** Inside the structure's `full` bounding box (the union of all pieces), the `monster` list of the position is replaced by
   one entry: pillager, weight 1, count 1 to 1 (44-2 section 8, 36-1 section 10). So the only natural monster inside the box is the pillager,
   in groups of one, with the weight of the entry irrelevant (only entry).
2. **Spawn predicate.** The pillager's placement rule is `PatrollingMonster.checkPatrollingMonsterSpawnRules`: block light at the position
   above 8 returns false; otherwise the any-light monster rule applies (18 section 6.8; 20 section 14.1 lists the patrol spawner's own gating).
   Placement type on ground, heightmap `MOTION_BLOCKING_NO_LEAVES` (18 appendix).
3. **Leader roll.** `PatrollingMonster.finalizeSpawn` skips the leader roll for the reasons PATROL, EVENT and STRUCTURE only. A natural
   spawn (reason NATURAL) therefore draws `nextFloat() < 0.06` (after the reason test, so the draw happens only for non-skipped reasons) and
   if it passes and `canBeLeader` holds the pillager becomes a patrol leader: it wears the ominous banner on its head with drop chance 2.0.
   No other effect (it is **not** `patrolling`: that flag is set only for reason PATROL). So roughly 6% of outpost pillagers are captains
   without a patrol. `Raider.finalizeSpawn` sets `canJoinRaid` true for every spawn except a natural witch (20 section 14).
4. **Despawn.** A non-patrolling raider with no raid has the plain far-away despawn rule: `PatrollingMonster.removeWhenFarAway` returns true
   when the monster is not `patrolling` (a patrolling one only beyond squared distance 16384, 128 blocks), and `Raider.removeWhenFarAway`
   returns false whenever the raider has a raid, and otherwise defers to the `PatrollingMonster` rule (`Raider.requiresCustomPersistence` is also overridden: true when the patrolling-monster rule holds or the raider has a current raid, so a pillager in a raid is custom-persistent in that sense; an outpost NATURAL pillager is in no raid, so the conclusion below stands). Outpost pillagers, being NATURAL spawns, are (inferred) not persistent and despawn like other hostile mobs (18); their count at an outpost is kept up by the spawn cycle (18 section 6).
5. **Patrols and raids do not see the outpost.** Every class of the patrol spawner, raid and raider code (`PatrolSpawner`, `Raid`, `Raids`,
   `Raider`, `PatrollingMonster`, `Pillager`, the illager classes) was searched for references to structures, the outpost key and structure
   tags: none (only `ServerLevel` and `NaturalSpawner` use the structure manager, for spawn lists). The patrol spawner (20 section 14.1)
   decides from the player, the time and `isCloseToVillage(pos, 2)`; it has no relation to an outpost. Conversely a patrol leader's loot and Bad Omen effect (20 section 14, 44-2 section 6) apply equally to an outpost
   captain.

### 11.4 Terrain and biome

The outpost has the village terrain settings (`beard_thin`, `surface_structures`, `WORLD_SURFACE_WG` projection), a start biome test at the
base plate's center, and a **vertical limit of 80** around the stub (section 2.2). The base plate's 30-block height with that limit means
the whole box lies within 80 blocks of the stub y, which is the projected surface y (section 5); the plate's lower part is buried.

---

## 12. Worked examples

### 12.1 A plains village center in chunk (5, 7)

Start position `pos = (80, 0, 112)`. Suppose the draws give rotation none and the element `plains_meeting_point_2` (template size 8 x 5 x 15:
`x` 0 to 7, `y` 0 to 4, `z` 0 to 14). Box at the origin: `x 80..87`, `y 0..4`, `z 112..126`. `cx = (87 + 80) / 2 = 83`, `cz = (126 + 112) / 2 = 119`.
Suppose the world-generation heightmap at (83, 119) gives `getFirstFreeHeight = 70`. Then `y = 0 + 70 = 70`; the piece moves by
`70 - (0 + 1) = 69`, so its box becomes `y 69..73` and its origin is `(80, 69, 112)`. The stub position is `(83, 70, 119)`; the biome is tested at quart cells
`(20, 17, 29)`. The free volume (section 5) is `x [3, 164)`, `y [max(-10, -64), min(151, 320)) = [-10, 151)`, `z [39, 200)` minus the piece's box. With the 36-3 reading
(vertical 4064) the y range would be `[-64, 320)`; the two differ only for pieces below -10 or above 150 at this stub.

### 12.2 One draw from a pool list

`village/plains/houses` has weights summing to 87: the expanded list has 87 entries (`plains_library_1`, weight 5, appears five times; the
empty element ten times). A jigsaw that asks this pool at depth below 6 gets a Fisher-Yates shuffle of those 87 entries (`nextInt(i)` for `i`
from 87 down to 2, swapping position `i - 1` with the drawn one) followed by the shuffled terminators; candidates are tried in that order
until one fits, the empty element ends the loop. The chance that the first entry is the empty element is `10 / 87 = 11.5%`.

### 12.3 Zombie probability for a village in a desert chunk

The desert `town_centers` list has 250 entries; five are zombie (weights 2 + 2 + 1), so one village in 50 is a zombie village (`5/250`).

### 12.4 Farm crops

A plains farm with 40 wheat blocks yields about 12 carrot, 5.6 potato, 2.2 beetroot and 20.2 wheat blocks on average (section 8.3 arithmetic). Per
block the outcome is a function of its absolute position.

### 12.5 A fresh village is not a village

A plains village is generated with beds, a bell, a composter and others. After the queued add tasks have run, the POI records exist (bell
with 32 free tickets, beds with 1, composter with 1). Nothing is occupied, so `sectionsToVillage` is 7 everywhere in the village and
`isVillage` is false. The first villager that claims a bed (reason: it sleeps; 19 section 22) makes that bed's section a centre: the
3 x 3 x 3 sections around it become `isVillage`, the 5 x 5 x 5 sections `isCloseToVillage(.., 2)` (the patrol spawner's veto, 20 section 14.1).

### 12.6 A natural outpost pillager

At a spawn position inside the outpost box with block light 6 and reason NATURAL: allowed (6 is not above 8), the `monster` list is `[pillager]`,
`finalizeSpawn` first sets the default equipment and equipment enchantments (`populateDefaultEquipmentSlots`, `populateDefaultEquipmentEnchantments`, which draw from the level random), then the patrol chain: the leader roll draws one `nextFloat`, among the other draws made for equipment; 6% chance of the ominous banner and the leader flag; not patrolling, not persistent (inferred, section 11.3 item 4).

---

## 13. Validation (checkable facts for the extraction and for tests)

1. Structure elements: `village_plains`, `village_desert`, `village_savanna`, `village_snowy`, `village_taiga` have `size 6`; `pillager_outpost` has
   `size 7`; all six have `max_distance_from_center` the integer 80 and `use_expansion_hack` true, step `surface_structures`, adaptation `beard_thin`.
2. Decoding the integer form of `max_distance_from_center` yields horizontal = vertical = the integer.
3. Pool counts: 66 pools below `village/` and `pillager_outpost/` (62 and 4); element types in them: `legacy_single_pool_element`,
   `feature_pool_element`, `list_pool_element` (1, in `pillager_outpost/towers`), `empty_pool_element`.
4. Template counts: 494 NBT files below `structure/village/` (483, of which 3 are `village/decays`) and `structure/pillager_outpost/` (11); 1972 jigsaw blocks in
   them; jigsaw `name` counts: `bottom` 759, `building_entrance` 616, `street` 533, `feature` 47, `empty` 8, `entrance` 4, `plate_entry` 4,
   `buidling_entrance` 1; joints `aligned` 1164, `rollable` 808; no jigsaw with a nonzero `placement_priority` or `selection_priority`.
5. Palette entries of structure NBT in this version carry the block id under `id` (and `properties`), not under `Name` (36-2 section 1.2).
6. Zombie probabilities of section 4.1; zombie weights in the town-center pools: plains 4/204, desert 5/250, savanna 9/459, snowy 6/306, taiga 2/100.
7. Golem jigsaws: 16, one in each normal town-center template, none elsewhere; no golem jigsaw in any zombie template.
8. Entities in templates (44-2 section 10.5 totals): villager 15, zombie_villager 10, cat 10, horse 7, sheep 4, cow 2, pig 2, iron_golem 2 (one village, one
   outpost cage), camel 1, armor_stand 2, allay 2. No structure blocks.
9. Village loot chests 62 (distribution in section 9.5); outpost chests 2.
10. POI bookkeeping: 21 POI types, tickets (1, 1) x 14, (32, 6), (0, 1) x 6; the POI remove/add tasks run from `ServerLevel.updatePOIOnBlockStateChange`, which
    `WorldGenRegion.setBlock` calls.
11. Pillager: leader roll draws one `nextFloat` only for reasons other than PATROL, EVENT, STRUCTURE; block light above 8 rejects the spawn.
12. Processor lists: 17 in this family (3 mossify, 3 street, 5 farm, 5 zombie, `outpost_rot`).
13. `snowy_shepherds_house_1` is never attached (typo in its jigsaw name and target).

---

## 14. Open questions

1. **Vertical limit for the integer form of `max_distance_from_center`.** Read here as `vertical = horizontal` (section 2.2); 36-3 (sections 3.1,
   13.2, 18.2) says 4064. Confirmed from bytecode this round: `MaxDistance(int)` calls `MaxDistance(int,int)` with the same value twice, the decoder maps the integer branch through that constructor and the encoder writes the integer form only when both are equal, so vertical is 80 for these six structures and the 36-3 value 4064 is wrong (36-3 needs the correction; this document stands). 36-3 also contradicts itself: its field description of the integer form ("a single integer gives both") agrees with this document, while its limit value and the later sections use 4064; the correction is not yet applied there (not edited from this document). The padding terms of the box are given in section 5 item 6 (zero for these structures).
2. **`village/decays` templates.** Three templates are referenced by no pool, structure or tag found in the jar; a use in code (a feature or a
   command) was not searched beyond the worldgen JSON and the class constant pools of the packages read. Probably dead data (inferred).
3. **Interior-jigsaw golem placement.** That each normal village gets exactly one golem is inferred from the single-element pool and the interior
   volume rule (section 9.2); no full simulation was done.
4. **POI task timing.** The add and remove tasks are queued on the main-thread executor (read); whether a server tick can run before the generated
   chunk becomes visible to villager brains, and the order relative to chunk saving, was not traced (inferred: after the tick that finishes the stage).
5. **Expected feature count of an outpost plate** (section 11.1 item 2) was not computed; it depends on the shuffle outcomes and the geometry of
   the feature templates.
6. **Overgrown watchtower overlay** (section 11.1 item 1): that the second list element overrides the first where both write a block is inferred from list order
   and 36-2 section 5.3 (later writes overwrite).
7. **Villager type for biomes outside the type table** (meadow): 19 section 22.1 holds the table; the default is not restated here.
8. **Placed feature ids** used by `feature_pool_element` (`oak`, `pile_hay`, `patch_taiga_grass` and the others of section 8.1) are data in `worldgen/placed_feature`;
   their engines are 35; their generated shapes were not read in this part.
9. **Loot seeds.** Chest templates store no `LootTableSeed`; the seed assignment at first open is the container's (31 section 1); not re-read here.
10. **Variants of the zombie processor lists** other than plains and desert (section 7) are summarised by rule counts only, not by rule.
11. **Biome tag `has_structure/village_plains` omits `sunflower_plains`** (read); no rule in code compensates for it that was found (inferred).
12. **Whether `jigsaw` placement draws are consumed when a start is rejected after a biome failure** is 36-1's (section 5.2); not re-derived here.
13. **Map tags and locate.** The `on_<variant>_village_maps` tags and the `village` structure tag are listed by name here; their use by explorer maps (19 section 22) and by `locate` (16) was not re-read in this part.
14. **Trade-rebalance copy of the outpost loot** (section 11.2) is cited, not described; its content is loot data (26) and was not compared with the base table here.
15. **Custom persistence of raiders in a raid**: `Raider.removeWhenFarAway` returns false with a raid, and `Raider.requiresCustomPersistence` is overridden to return true when the patrolling-monster rule holds or a current raid exists (section 11.3 item 4). How the persistence-required flag, the despawn check and the save path combine for raid members was not traced here.
