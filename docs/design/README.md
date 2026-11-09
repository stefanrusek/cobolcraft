# Design documents: reconciliation map for two world types

Status: analysis and edit plan, revised after the operator's decisions "World scope", "Vanilla client", "Vanilla assets
and data" and "Own world type" (tickets/CC-0001-client-polish.md, Decisions). This file is the map that tells the
document editors what to change and tells the planner of the next engineering run which document to trust. It contains no
game content of its own. Section references use the forms "standin §10.2" (docs/design/standin-content.md), "17 §4.4"
(docs/protocol/17-...), "faithful §3" (docs/design/faithful-pack-mapping.md), "spec FR-015"
(specs/001-cobolcraft-complete/spec.md) and "CC-0001" (tickets/CC-0001-client-polish.md).

The model in one paragraph. The game has two **world types**. The **standard** world type is Minecraft 26.3 content: its
registries, blocks, items, mobs, recipes, loot, tags, worldgen and dimensions come from a vanilla resource pack and a
vanilla data pack that a COBOL **extraction tool** builds from the user's own client jar, plus the engines (code) that the
documents 10 to 21 and the new research documents specify. The **cobolcraft** world type is the invented `cobolcraft:`
content of `standin-content.md`, kept unchanged as content, demoable with no jar and no packs. **Gameplay rules are shared**:
health, hunger, damage, hurt window, day length, movement, commands, crafting screens, ground items and the like are the
standard rules of documents 10 to 21 in both world types. The world type selects the content set only.

Scope of this map: docs/design/standin-content.md, docs/design/faithful-pack-mapping.md, docs/protocol/04, 07 §9, 08, 09,
12, 13, 14, 16, 17, 19 and the protocol README (where they mention stand-in content or the `cobolcraft:` namespace), the
stand-in citations of spec 001 and the tickets CC-0001 and CC-0007. The other files under `specs/001-cobolcraft-complete/`
(`data-model.md`, `contracts/*.md`, `plan.md`, `tasks.md`, `research.md`, `quickstart.md`) also cite stand-in values; they
describe the cobolcraft world type well but are superseded by the shared rules wherever they disagree (Part 7, decision 13).

## 0. Rules that every disposition below applies

| # | Rule | Source |
|---|---|---|
| R1 | Namespace: the standard world type uses `minecraft:` for everything (registry keys, texture paths, language keys, tags, dimension keys); packs written for it, such as Faithful, apply by path. The cobolcraft world type uses `cobolcraft:` for its own content and `minecraft:` for protocol vocabulary and for the standard entries the shared rules need (Part 4, C3). `cobolcraft:` is where CobolCraft extends or diverges. | CC-0001 Decisions, Namespace; Own world type |
| R2 | Standard gameplay rules are shared: where the standard behaviour (docs 10 to 21) and `standin-content.md` differ on a rule (health, hurt cooldown, fall damage, hunger, day length, movement, damage, commands, crafting, ground items, weather mechanism), the standard rule applies in **both** world types. Stand-in values for those rules are retired. What stays in `standin-content.md` is content: the blocks, items, mobs, recipes, biomes, dimensions and textures of the cobolcraft world type. | CC-0001 Decisions, Stand-in content; Own world type |
| R3 | Standard commands, tools, weapons and mobs are the target of the standard world type. In the cobolcraft world type the standard commands run against the cobolcraft registries (items, entity types, dimensions named by their `cobolcraft:` keys); the stand-in command set is retired. | same |
| R4 | The standard world type's world generation is nearly identical to vanilla's (10, 11 and the feature, structure, Nether and End rounds). The cobolcraft world type keeps its own generators (standin §5.2, §15.2). | CC-0001 Decisions, World generation |
| R5 | The Faithful 32x pack (`minecraft:` namespace, textures only) is loaded and used. It layers on top of the generated vanilla resource pack (Part 4, C7 gives the pack order). | CC-0001 Decisions, Resource pack |
| R6 | Feature 001's crafting screen (US10, the C key) is removed. Crafting is the inventory 2x2 grid and the bench 3x3 grid (13 §3.5, 12 §5.6a, 12 §5.6b) in both world types. | CC-0001 Decisions, Crafting screen |
| R7 | Data versus code. Content that is data in the vanilla artifact (recipes, loot tables, tags, registry entries, worldgen JSON, structure NBT, villager trades; models, block states, item definitions, atlases, language, textures, fonts) is **extracted by the tool**: the documents specify the tool, the loaders and the packs' layout, and do not list rows. Content that is code (block registry and its properties, item registry and default components, entity models, light engine, placement and update rules, fluids, falling blocks, fire and growth, redstone, block entities and menus, worldgen feature and structure algorithms, Nether and End generation algorithms, and the engines that interpret data: loot functions, conditions and number providers, predicates, recipe types, enchantment effect components, tag resolution, registry loading and codecs) is specified by clean-room research documents. | CC-0001 Decisions, Vanilla assets and data |
| R8 | The vanilla client is a validation goal: for the standard world type, block, item and entity ids, registry contents and chunk encodings match vanilla so a reference client can validate. Scope is the planner's (Part 7, decision 1). The cobolcraft world type is not playable by a vanilla client. | CC-0001 Decisions, Vanilla client |
| R9 | Silence rule: where no standard document specifies a rule (a GAP in Part 5), the stand-in value is an interim value only, marked "interim until GAP-n". | this map |
| R10 | Documents are the source of truth and implementers read documents only (Principle II). A GAP of kind "engine" is closed by a clean-room round that writes prose and tables, never by an implementer reading the artifact. The extraction tool reads the jar at run time on the user's machine; that is not an implementer reading it. | `.claude/skills/clean-room/SKILL.md`, CC-0001 |

## 1. Purpose and source of truth

The next engineering run's planner works from documents that tell one story. This part states which document is
authoritative for each area after the edits of Part 6, per world type, or GAP when no document yet specifies the behaviour.
World type: **S** standard, **C** cobolcraft, **both** shared rule. The last column says where the content comes from:
**Doc** (specified in a document now), **Tool** (data rows extracted by the tool; the tool and its loaders are GAP-32),
**Engine GAP** (code in the artifact; research needed), **Tool + engine** (rows by the tool, interpreter needing research).
"Partial" means some of the area is specified; Part 5 lists the rest.

| # | Area | World type | Authoritative document(s) after reconciliation | Source and status |
|---|---|---|---|---|
| 1 | Block registry and block states | S | Id rules 04 §5.1 to 5.3; chunk palettes 06 §5; hardness, tool, tier for the table of 13 §2.6; `mineable/*` 17 App A; ore blocks 11 §8. The registry (ids, properties and value order, default state, light, shape class, flags) is code. | Engine GAP-1 (partial) |
| 1c | Block registry | C | standin §1.1, §1.2 (12 blocks, 18 states) | Doc |
| 2 | Item registry and default components | S | Id rule 04 §5.1; component model 17 §1; tools, weapons, armor, utility items 17 §2; wire 00 §12. Other items' ids, stack sizes, default components are code. | Engine GAP-2 (partial) |
| 2c | Item registry | C | standin §2 (18 items; tool and food values re-expressed as components, S21) | Doc |
| 3 | Entity types and mobs | S | 21 §2 (161 types, ids, sizes), framework 18, mobs 19, 20, 21; player 13 §1, 12 §7. Ids are "inferred" (19 Open question 31, 20 Open question 25). Entity model geometry is code. | Doc; models Engine GAP-25 |
| 3c | Entity types and mobs | C | standin §3, §12 (operator, loose_item, sodgrazer, abend) | Doc |
| 4 | Recipes | S | Schema, matching, menus, recipe book 13 §3. Rows by the data pack. Other recipe types and the unlock engine are code. | Tool + engine GAP-5, GAP-5b |
| 4c | Recipes | C | standin §13 (9 recipes, shapeless) | Doc |
| 5 | Loot | S | Ore blocks 11 §9; loot conditions 17 §3.16; entity loot rolling 18 §7.6; per-mob loot 19 to 21; trades 19 §24. Rows by the data pack; loot functions, conditions, number providers are code. | Tool + engine GAP-4 |
| 5c | Loot | C | standin §1.3 (block yields), §12.5 | Doc |
| 6 | Tags | S | Wire 04 §1, §3.3, §5.3. Rows by the data pack. Tag resolution and loading are code. | Tool + engine GAP-6 |
| 6c | Tags | C | standin §6 (optional own tags); shared rules need standard tags such as `mineable/*` (S42) | Doc |
| 7 | Synchronized registries and what the server sends | S | Packet, order, ids, validators 04 §2 to §4, §3.2; schemas 04 §6. Entry data by the data pack; registry loading and codecs are code. | Tool + engine GAP-7 |
| 7c | Synchronized registries | C | standin §4 as re-scoped (S30 to S39), 09 §3.1 | Doc |
| 8 | Dimensions and world generation | S | Overworld terrain, climate, biomes, aquifers, surface rules 10; caves, carvers, ore veins, ore and blob features, decoration seeding 11. Worldgen JSON by the data pack. Feature algorithms (trees, vegetation, lakes), structures, Nether, End, portals are code. | Doc for overworld terrain, caves, ores; Tool + engine GAP-12, GAP-13 |
| 8c | Dimensions and world generation | C | standin §5, §15 (main, subroutine, goto_pad travel) | Doc |
| 9 | Weather | both | Mechanism: 12 §3.5, 12 §3.3, 14 §8.2, wire Game Event, 16 §4.10. Server schedule is code. Kinds in C: drizzle and hailstorm are skins of rain and thunder (Part 7, decision 5). | Engine GAP-11 (partial) |
| 10 | Day, time, sky | both | 12 §3.1 to 3.4, 3.6; 24000-tick day 12 §3.2; `time` 16 §4.5; schemas 04 §6. Server clock is code. | Engine GAP-11 (partial) |
| 11 | Ground items | both | 18 §6.11 (lifetime 6000, delay 10, merge); 12 §8; motion and pickup box not read | Engine GAP-26 (partial) |
| 12 | Health, damage, hunger | both | 17 §1.5, §4.1 to §4.12; 18 §7; HUD 12 §5.4 | Doc |
| 13 | Movement | both | 13 §1; mobs 18 §3; camera and model 12 §7 | Doc |
| 14 | Commands | both | 15, 15a, 16 | Doc |
| 15 | System messages and language | S | Lookup rules 08 §10.8; framework and command keys 15 §5, 16. The language file comes from the generated resource pack. | Tool (GAP-32); doc for the keys the server composes |
| 15c | System messages and language | C | standin §10.7 keys retired in favour of the shared keys (S59, S72); built-in pack `en_us` for names | Doc |
| 16 | Fonts | both | 14 §10, 12 §5.10; fallback glyphs standin §18 | Doc |
| 17 | Rendering and lighting | both | 12 §1 to §4, §6 to §8; CC-0007; light data 06 §7; light propagation (server) is code | Doc; light engine Engine GAP-24 |
| 18 | GUI | both | HUD 12 §5; inventory (46 slots) and crafting table 12 §5.6a, 5.6b, 13 §3.5; recipe book 13 §3.9; options 13 §7; F3 13 §5; F5 13 §6; pack screen 13 §8; sprites 14 §6. Other menus are code. | Doc; menus Engine GAP-19 |
| 19 | Resource packs and the built-in default pack | S | Format 08 §1 to 9; pack facts 14, faithful §2; generated vanilla resource pack: GAP-32. | Tool (GAP-32) |
| 19c | Resource packs and the built-in default pack | C | 08 §10 (the built-in pack, retained and re-scoped) | Doc |
| 20 | Vanilla assets and data tool; loaders; pack discovery and order | both | `docs/protocol/22-extraction-tool.md`, `23-registry-loading.md` | Closed (GAP-32) |
| 21 | World types: selection, what each selects, shared rules, fallback without packs | both | `docs/design/world-types.md` | Closed (GAP-33) |
| 22 | Protocol packets and profile | both | 00 to 05c, 09 (rewritten for two world types, Part 3.2) | Doc; 09 to be rewritten |
| 23 | World folder and persistence | both | 07 §9, edited as in Part 3.6, with a world type key | Retain with edits; entity and block-entity NBT GAP-8 |
| 24 | Permissions and operator status | both | 15 §2, 16 §11 | Doc; storage 07 §9.2 to be edited |
| 25 | Game rules | both | 16 §13 | Engine GAP-21 (partial) |
| 26 | Server and host configuration (FR-009) | both | spec FR-009, `contracts/operator-surface.md`; adds `world-type` (Part 7, decision 9) | Retained |
| 27 | Namespace rule and world-type rule | both | R1, R2 of Part 0 until 08 intro and the world-type document state them | `docs/design/world-types.md`, `docs/protocol/08-resource-packs.md` §1.6 | Closed (T07, GAP-33) |
| 28 | Block behaviour (fluids, falling blocks, growth, fire, redstone, block updates), block entities, particles | S | 17 §3.3a fire constants, 10 §9 aquifer fluids; the rest is code | Engine GAP-8, 9, 10, 15 |
| 29 | Sounds | both | out of scope (spec 001 Assumptions) | none |

## 2. Status log

This part replaces the former Part 2 (disposition of `standin-content.md`, rows S00 to S73) and Part 3 (disposition of the
other documents, rows P04, P08, P09, P12 to P19, P07, PR, F and K). Those rows were the edit lists of tasks T01 to T23. The
edits are made in the documents named below; the row ids no longer exist, and references elsewhere to "Part 3.5", "Part 3.7"
or "Part 6" now point to this log. Status words: **done** (the target document exists and holds the result), **partial**
(the document records unread or unresolved items in its Open questions that bear on the task). Every file named was
checked to exist in `docs/protocol/` or `docs/design/`. Open questions are counted in Part 8.

### 2.1 Edit tasks T01 to T25

| Task | Status | Where the result is |
|---|---|---|
| T01 | done | `docs/protocol/12-client-rendering.md` §0 "Resolved: the rules apply to both world types" |
| T02 | done | `docs/protocol/13-client-gameplay-and-controls.md` (header override clause removed) |
| T03 | done | `docs/protocol/17-tools-weapons-and-combat.md` (header, `max_health` row, §4.7: "both world types") |
| T04 | done | `docs/protocol/14-texture-only-packs.md`, `16-commands-catalog.md`, `19-mobs-land-friendly-and-neutral.md` |
| T05 | done | `docs/protocol/04-registry-sync.md` (§5 states both world types) |
| T06 | done | `docs/protocol/08-resource-packs.md` (atlas list, colormap rows, Q10 requirement) |
| T07 | done | `docs/protocol/08-resource-packs.md` §1.6 "Namespaces and world types"; `docs/design/world-types.md` |
| T08 | done | `docs/protocol/08-resource-packs.md` §10 (built-in pack of the cobolcraft world type) |
| T09 | done | `docs/protocol/08-resource-packs.md` §11 "Generated resource pack and pack order" |
| T10 to T14 | done | `docs/protocol/09-cobolcraft-profile.md` (rewritten for two world types; its Open questions remain) |
| T15 | done | `docs/protocol/07-nbt-and-anvil.md` §9.2 (`WorldType` key, per-dimension folders) |
| T16 | done | `docs/protocol/07-nbt-and-anvil.md` §9.2 (`access.dat` with `Level` 1 to 4, `players/`) |
| T17 | done | `docs/protocol/07-nbt-and-anvil.md` §9.3, §9.4 (entity storage cites `45-entity-nbt-*`) |
| T18, T19 | done | `docs/design/faithful-pack-mapping.md` (skin only for the cobolcraft world type; pack order in its §9) |
| T20 | done | `docs/protocol/README.md` (Documents table lists 150 files, 22 to 47 included) |
| T21 to T23 | done | `docs/design/standin-content.md` ("Content of the cobolcraft world type"). §9 ground items and the §14.3 timing remain as the two interim row sets (its Open question 21) |
| T24 | done | this file |
| T25 | not an editor task | recorded in Part 7, decisions 13 and 15 |

### 2.2 Research rounds RS1 to RS31

| Round | Status | Document that holds it |
|---|---|---|
| RS1 | done | `docs/protocol/22-extraction-tool.md` |
| RS2 | done | `docs/design/world-types.md` |
| RS3 | done | `docs/protocol/23-registry-loading.md` |
| RS4 | done | `docs/protocol/24-block-registry-1-model-and-foundation.md` to `24-block-registry-8-blackstone-copper-deepslate-modern.md` |
| RS5 | done | `docs/protocol/25-item-registry-1-model-and-blocks-a.md` to `25-item-registry-8-late-items-templates-sherds-trial.md`, `25-item-registry-x1-continuation.md` |
| RS6 | done | `docs/protocol/26-loot-and-predicates.md` |
| RS7 | done | `docs/protocol/27-recipes-and-unlocks.md` |
| RS8 | done | `docs/protocol/28-enchantment-effects.md` |
| RS9 | done | `docs/protocol/29-block-updates-and-placement.md` |
| RS10 | done | `docs/protocol/29a-fluids.md` |
| RS11 | done | `docs/protocol/29b-falling-growth-fire-1-model-gravity-bonemeal.md` to `29b-falling-growth-fire-8-fire-tnt-residual.md` |
| RS12 | done | `docs/protocol/30-redstone-1-model-signal-and-wire.md` to `30-redstone-8-tripwire-sculk-bells-vibration.md` |
| RS13 | done | `docs/protocol/31-block-entities-1-shared-model-and-containers.md` to `31-block-entities-8-sculk-and-remaining-types.md` |
| RS14 | partial | `docs/protocol/40-menus-1-model-and-containers.md` to `40-menus-9-block-editor-screens.md`, `40-menus-x1-continuation.md`. `40-menus-9` Open question 1: `TestInstanceBlockEditScreen` was not re-read in that round |
| RS15 | done | `docs/protocol/32-light-engine.md` |
| RS16 | done | `docs/protocol/33-world-simulation.md` |
| RS17 | done | `docs/protocol/34-entity-models-1-shared-model-and-framework.md` to `34-entity-models-9-non-living-entities.md` |
| RS18 | done | `docs/protocol/41-item-entity-physics.md` |
| RS19 | done | `docs/protocol/35-worldgen-features-1-model-and-placement.md` to `35-worldgen-features-7-nether-end-misc.md` |
| RS20 | done | `docs/protocol/36-structures-1-model-placement-starts.md` to `36-structures-10-ancient-city-trial-chambers-trail-ruins.md` |
| RS21 | done | `docs/protocol/37-nether-1-model-and-dimension-rules.md` to `37-nether-6-structures-spawns-hooks.md` |
| RS22 | done | `docs/protocol/38-end.md` |
| RS23 | done | `docs/protocol/39-portals.md` |
| RS24 | done | `docs/protocol/42-particles-1-shared-model-engine.md` to `42-particles-7-emitters-entities-events-commands.md` |
| RS25 | done | `docs/protocol/43-tint-sources.md` |
| RS26 | done | `docs/protocol/44-residual-mob-questions-1-shared-model-framework.md` to `44-residual-mob-questions-9-end-bosses-decorations.md`, `44-residual-mob-questions-x1-continuation.md`, `44-residual-mob-questions-x2-continuation.md` |
| RS27 | done | `docs/protocol/45-entity-nbt-1-shared-model-and-entity-base.md` to `45-entity-nbt-9-bosses-and-decorations.md` |
| RS28 | partial | `docs/protocol/46-registry-ids.md` (all 95 static registries classified; its Open question 14: sound event helper methods and pattern-C registries not scanned for other registering classes); entity-type id check in `docs/protocol/44-residual-mob-questions-5-overworld-hostile.md` §5 |
| RS29 | partial | `docs/design/builtin-ui-art.md` (its status line: options screen texts not supplied, Open question 13) |
| RS30 | done | `docs/design/cobolcraft-standard-core.md` |
| RS31 | done | `docs/protocol/47-default-skin.md` |

## 4. Consequences

What follows from two world types, shared rules and the extraction tool. Each item names the documents it touches.

| # | Consequence |
|---|---|
| C1 | **Two registry worlds.** The standard world type uses the vanilla numbering of every static registry (04 §5.1: blocks, block states, items, entity types, menu types, data component types and the rest), so a reference client can validate ids, registry contents and chunk encodings (R8). The cobolcraft world type keeps its own numbering (standin §1.2, §2, §3). The old tier model maps onto world types: tier B (vanilla client passes configuration) is what the cobolcraft world type still offers; the standard world type aims at full play. The statement "original static content and a playable vanilla client are mutually exclusive" (standin §0) stays true for the cobolcraft world type only. 04 §5 states both. |
| C2 | **Standard world type: registries and tags come from the data pack.** The server (and the single-player host) loads the generated vanilla data pack through the registry loader and sends Registry Data in the order of 04 §3 and Update Tags from the loaded tag sets (04 §1, §3.3, §5.3). Which registries, how many entries and what they hold is whatever the pack holds; the documents specify the loader, the codecs (04 §6 plus the sub-schemas 04 Open question 7 leaves unexpanded), the validators and the mandatory keys (04 §3.2), not the rows. The `dimension_type` of the overworld is `min_y -64`, `height 384`, sea level 63 (10 §5), with `attributes` and `timelines` (12 §3.1) and a day of 24000 ticks. |
| C3 | **The cobolcraft world type carries a small standard core.** Shared rules use standard vocabulary even where the content is original, so this world type's registries also hold: the standard `damage_type` keys with their standard values (17 §4.12; the 25 compat keys already exist, with placeholder values to be corrected), the standard `chat_type` entries that standard commands use (16 §8), a `world_clock` and the standard `timeline` (12 §3.2), minimal `enchantment` and `block_transformer` entries (17 §3.1, §6), and the standard tags the shared mining rules read (`mineable/*`, tier tags) with cobolcraft blocks and tools added to them. It is authored by hand in the documents (GAP-35). |
| C4 | **World geometry per world type.** Standard overworld: Y -64 to 319, 24 block sections, 26 light sections, heightmap entries of `ceillog2(385)` bits, seeded generation, the Login hashed seed from 10 §7.7. Cobolcraft world: Y 0 to 255 (standin §4.6) and its own generator. The block palette's Global kind is reachable in the standard type. |
| C5 | **Time, sky, weather and screens are shared.** A day is 24000 ticks in both world types (12 §3.2), with the standard attributes and timeline; the standard `time` command and `advance_time` rule apply. Weather is the standard server-level mechanism with clear, rain and thunder levels (16 §4.10, 12 §3.5); in the cobolcraft world type `drizzle` and `hailstorm` are skins of rain and thunder (decision 5). Container 0 is the 46-slot inventory menu and the bench is the 46-slot crafting menu (12 §5.6a, 5.6b, 13 §3.5) in both. Feature 001's crafting screen is removed. |
| C6 | **Combat, survival and commands are shared** (17 §4, 13 §1, 15, 16): 20 health, 20 food, saturation, the 10-tick hit window, standard exhaustion, regeneration, starvation, armor, knockback; ground items live 6000 ticks, delay 10, merge (18 §6.11); the standard command set with permission levels 0 to 4 (15 §2), selectors and chat types. In the cobolcraft world type the commands resolve `cobolcraft:` items, entity types and dimensions through the same argument parsers. The stand-in command table, health 30, food 24, hurt cooldown 12 and fall rule are retired in both world types. |
| C7 | **Pack stack, bottom to top.** (1) The built-in pack of the cobolcraft world type (08 §10), required and fixed at the bottom; (2) the generated vanilla resource pack (when the tool has produced it); (3) the user's packs in the user's order, including Faithful 32x (`resourcepacks/` folder, 13 §8); (4) server-pushed packs (08 §9.6). Faithful's `minecraft:` textures replace the generated pack's textures by the same path; they have no effect on `cobolcraft:` content unless the optional skin (Part 3.5) is on. Data packs: the cobolcraft world type's data is part of the game; the standard world type's data pack is the generated one. |
| C8 | **The extraction tool replaces the hand-written standard content.** A COBOL tool reads the user's vanilla 26.3 client jar (a zip; the zlib in the C shim inflates entries) and writes, into the user's game directory and never into the repository: (a) a vanilla **resource pack**: `pack.mcmeta`, models, block states, item definitions, atlas definitions, language, textures with their `.mcmeta`, font definitions and images, colormaps, particle definitions, equipment definitions, and sounds only if decision 17 says so; (b) a vanilla **data pack**: `pack.mcmeta`, recipes, loot tables, tags, registry data (biomes, damage types, dimension types, enchantments, variants, trims, banner patterns, instruments, jukebox songs, timelines, world clocks, chat types, painting variants and the rest), worldgen JSON (density functions, noise, noise settings, carvers, configured and placed features, structures, structure sets, template pools, processor lists), structure NBT and trades. The documents specify: what is read and written, folder layout, version and SHA check, `pack.mcmeta` content, how server and client find the packs, what happens with a missing or wrong jar, and the loaders (GAP-32). In multiplayer the client gets registries and tags over the network (04 §2, §3, §5.3), so it needs the resource pack only (to be confirmed in RS1); the server and the single-player host load both. |
| C9 | **What remains code, with clean-room research.** Block registry (ids, states, properties, hardness, light, shapes), item registry and default components, entity model geometry for 161 entity types, the light engine, placement and update rules, fluids, falling blocks, fire and growth, redstone, block entities and menus, worldgen feature and structure algorithms, Nether and End generation algorithms and the node types their noise routers use, and the engines that interpret data: loot functions, conditions and number providers, predicates, recipe types, enchantment effect components, tag resolution, registry loading and codecs. The data pack supplies only the rows these engines read. |
| C10 | **Behaviour without the jar.** Without a valid jar (missing, wrong version or SHA, tool not yet run) the game offers only the cobolcraft world type, which needs nothing generated: it runs on the built-in pack and the hand-authored core (C3). A standard world cannot be created or opened and the game says why. The generated packs are regenerated when the jar changes and are never committed (CC-0001 Decisions, Resource pack). |
| C11 | **The cobolcraft world type needs its own UI art.** Because it runs with no vanilla pack and the UI (HUD, inventory, bench, recipe book, menus, options) is shared, the built-in pack must draw that UI with original art and a fallback font and language set (faithful §6.4 "About 96 sprites need original built-in recipes"; GAP-34). |
| C12 | **Documents that cite stand-in sections are re-pointed, not broken.** `standin-content.md` stays; ten documents cite it (07 §9, 08 §10, 09, 12, 13, 14, 16, 17, 19, protocol README). Citations of shared-rule sections (§9 to §17) are re-pointed to the standard documents; citations of content sections stay. |
| C13 | **Spec 001 stays largely valid for the cobolcraft world type** (Part 3.7). The items that cite shared-rule values are superseded by documents 10 to 21 (decision 13). |
| C14 | **Vanilla-client validation constraints** (R8, decision 1 records that the planner decides scope): ids, registry contents and chunk encodings of the standard world type match vanilla; the generated data and the registries must therefore not be altered by CobolCraft. |


## 5. Gaps

Each former gap (GAP-1 to GAP-35) is mapped to the document that now specifies it. The kind, size and artifact source columns
of the former table are dropped. "Residual" says where unresolved items of that area are recorded; the per-document counts are
in Part 8. No gap is without a document. Out of scope by decision: GAP-14 (sounds, decision 17) and GAP-22 (`server.properties`).

| GAP | Area | Closed by | Residual open questions recorded in |
|---|---|---|---|
| GAP-1 | Block registry | `docs/protocol/24-block-registry-1-...` to `24-block-registry-8-...`; ids in `46-registry-ids.md` | Open questions of each `24-*` file |
| GAP-2 | Item registry and default components | `docs/protocol/25-item-registry-1-...` to `25-item-registry-8-...`, `25-item-registry-x1-continuation.md` | Open questions of each `25-*` file |
| GAP-3 | Resource pack formats, generated resource pack | `docs/protocol/22-extraction-tool.md`, `08-resource-packs.md` §11 | 08 Open questions 3, 5, 7 to 9 (engine remainder as named in the former table); 22 Open questions |
| GAP-4 | Loot tables and loot engine | `docs/protocol/26-loot-and-predicates.md` | 26 Open questions |
| GAP-5 | Recipes | `docs/protocol/27-recipes-and-unlocks.md` | 27 Open questions |
| GAP-5b | Recipe unlock | `docs/protocol/27-recipes-and-unlocks.md` | 27 Open questions |
| GAP-6 | Tags | `docs/protocol/23-registry-loading.md` | 23 Open questions |
| GAP-7 | Registry data, loading, codecs | `docs/protocol/23-registry-loading.md` (§11 lists the resolutions of 04 Open questions) | 23 Open questions; 04 Open questions |
| GAP-7a | Biome effects and attributes | `docs/protocol/23-registry-loading.md` | 23 Open questions |
| GAP-7b | `dimension_type`, `timeline`, `world_clock` | rows by the tool (`22-extraction-tool.md`); cobolcraft world type in `docs/design/cobolcraft-standard-core.md` | core Open questions 6, 22, 26 |
| GAP-7c | Variants, chat type, damage type, other rows | rows by the tool (`22-extraction-tool.md`); cobolcraft world type in `cobolcraft-standard-core.md` | core Open questions 1 to 3 |
| GAP-7g | Enchantment effect components | `docs/protocol/28-enchantment-effects.md` | 28 Open questions |
| GAP-7h | `dialog`, `test_environment`, `test_instance`, `block_state_provider` | generic loader of `23-registry-loading.md` | none recorded |
| GAP-8 | Block entities and entity NBT | `docs/protocol/31-block-entities-1-...` to `31-block-entities-8-...`; `45-entity-nbt-1-...` to `45-entity-nbt-9-...`; `07-nbt-and-anvil.md` §9.3 | Open questions of `31-*` and `45-*` |
| GAP-9 | Fluids | `docs/protocol/29a-fluids.md` | 29a Open questions |
| GAP-10a | Block updates | `docs/protocol/29-block-updates-and-placement.md` | 29 Open questions |
| GAP-10b | Falling blocks, growth, fire | `docs/protocol/29b-falling-growth-fire-1-...` to `29b-falling-growth-fire-8-...` | Open questions of each `29b-*` file |
| GAP-10c | Redstone | `docs/protocol/30-redstone-1-...` to `30-redstone-8-...` | Open questions of each `30-*` file |
| GAP-11 | Weather, day-night, sleeping | `docs/protocol/33-world-simulation.md` | 33 Open questions |
| GAP-12a | Worldgen features | `docs/protocol/35-worldgen-features-1-...` to `35-worldgen-features-7-...` | Open questions of each `35-*` file |
| GAP-12b | Structures | `docs/protocol/36-structures-1-...` to `36-structures-10-...`; `44-residual-mob-questions-2-spawning-structures.md` | Open questions of each `36-*` file |
| GAP-13a | Nether generation | `docs/protocol/37-nether-1-...` to `37-nether-6-...` | Open questions of each `37-*` file |
| GAP-13b | End generation | `docs/protocol/38-end.md` | 38 Open questions |
| GAP-13c | Portals and travel | `docs/protocol/39-portals.md` | 39 Open questions |
| GAP-14 | Sounds | out of scope (decision 17) | none |
| GAP-15 | Particles | `docs/protocol/42-particles-1-...` to `42-particles-7-...` | Open questions of each `42-*` file |
| GAP-16 | Advancements | `docs/protocol/27-recipes-and-unlocks.md` | 27 Open questions |
| GAP-17 | Chest, fishing, archaeology, gift, trial loot | `docs/protocol/26-loot-and-predicates.md` (engine); rows by the tool | 26 Open questions |
| GAP-18 | Trades, POI, villages | `docs/protocol/36-structures-9-villages-outposts.md`, `44-residual-mob-questions-3-villagers-poi-raids.md` | 36-9 and 44-3 Open questions |
| GAP-19 | Menus and screens | `docs/protocol/40-menus-1-...` to `40-menus-9-...`, `40-menus-x1-continuation.md` | Open questions of each `40-*` file |
| GAP-20 | Default skin | `docs/protocol/47-default-skin.md` | 47 Open questions |
| GAP-21 | Game rule effects | `docs/protocol/33-world-simulation.md` | 33 Open questions |
| GAP-22 | `server.properties` | out of scope | none |
| GAP-23 | Namespace and world-type rule as text | `docs/design/world-types.md`, `docs/protocol/08-resource-packs.md` §1.6 | world-types Open question 17 (operator confirmation of the namespace reading) |
| GAP-24 | Light engine | `docs/protocol/32-light-engine.md` | 32 Open questions |
| GAP-25 | Entity models | `docs/protocol/34-entity-models-1-...` to `34-entity-models-9-...` | Open questions of each `34-*` file |
| GAP-26 | Item entity physics | `docs/protocol/41-item-entity-physics.md`; interim values remain in `standin-content.md` §9 | 41 Open questions; standin Open question 21 |
| GAP-27 | Language texts | rows by the tool (`22-extraction-tool.md`); lookup `08-resource-packs.md` §10.8 | 22 Open question 3 |
| GAP-28 | World spawn, respawn | `docs/protocol/33-world-simulation.md` | 33 Open questions |
| GAP-29 | Block tint sources | `docs/protocol/43-tint-sources.md` | 43 Open questions |
| GAP-30 | Placement and interaction | `docs/protocol/29-block-updates-and-placement.md`; block columns in `24-*` | 29 Open questions |
| GAP-31 | Residual mob questions | `docs/protocol/44-residual-mob-questions-1-...` to `44-residual-mob-questions-9-...`, `-x1-continuation`, `-x2-continuation` | Open questions of each `44-*` file |
| GAP-32 | Extraction tool and loaders | `docs/protocol/22-extraction-tool.md` | 22 Open questions 1 to 3 (unknown jar, jar at run time, stack order and language keys) |
| GAP-33 | World types | `docs/design/world-types.md` | world-types Open questions 1 to 17 |
| GAP-34 | Built-in UI art | `docs/design/builtin-ui-art.md` | builtin-ui-art Open questions 13 (options texts) and 20 (selectable or disabled standard choice) |
| GAP-35 | Cobolcraft standard core | `docs/design/cobolcraft-standard-core.md` | core Open questions 1 to 26 |

## 6. Edit plan

The edit plan (tasks T01 to T25 and research rounds RS1 to RS31) is carried out; its status is in Part 2, the status log.

## 7. Decisions for the operator

Decided by the operator (CC-0001 Decisions, 2026-11-06), no longer open: the cobolcraft content stays as a world type; the
Nether, End, structures, trees, vegetation, lakes, redstone and block updates are in this run; the vanilla assets and data
come from a tool and loaders (the documents specify the tool, the loaders and the engines, not the rows).

Recorded, planner decides: **Vanilla client** (decision 1 below). The scope is the planner's; the constraint is R8.

Every other decision below carries an **adopted default**. The default is what the editors and the planner use unless the
operator overrules it; it is a recommendation made with the reconciliation, not an operator ruling.

| # | Question | Adopted default (operator may overrule) | Why | Affects |
|---|---|---|---|---|
| 1 | Scope of vanilla-client validation (recorded, planner decides). | The planner chooses what to validate (configuration, chunk and registry decoding, then play of the standard world type). Constraint: ids, registry contents and chunk encodings of the standard world type match vanilla. | The operator left the scope to the planner. | R8, C1, C14, P04-6 |
| 2 | World type selection and defaults: how is a type chosen (creation screen, server setting `world-type`), which is the default, what when the jar or packs are missing. | `world-type` setting and creation-screen choice, stored in `level.dat` (`WorldType`); default `standard` when the generated packs are present, otherwise `cobolcraft`; a missing or wrong jar disables the standard type (C10). | The cobolcraft type must be demoable with nothing generated. | GAP-33, T15, spec FR-009 |
| 3 | Crafting bench in the cobolcraft world type. Recipe 7 has seven ingredients and R6 requires the bench for 3x3. | Add one `cobolcraft:crafting_bench` block and item, with a recipe from the inventory grid, as the only addition to the cobolcraft content; the other recipes stay shapeless. | R6 applies to both types; the content is otherwise unchanged. | S65, S10, S21 |
| 4 | Break time of the cobolcraft blocks under the shared formula and tags. | Express each cobolcraft block as standard properties (hardness, mineable tag, tier), starting from the nearest standard block of S10 (greystone like stone, loam like dirt, turf like grass_block, grit like sand, lucite like glass, slag like netherrack) and, for the others, from the stand-in times; the two tools become pickaxe-like and shovel-like components; `cobolcraft:hard` and `cobolcraft:soft` retire. | Standard rules apply to both types. | S11, S21, S42 |
| 5 | Cobolcraft player size, weather and death texts under shared rules. | The player-equivalent uses the standard player box in gameplay; `drizzle` is rain and `hailstorm` is thunder with `cobolcraft:hail` as an extra damage source; deaths use the standard death keys with the generic mob message for the abend. | Shared rules, minimum content change. | S24, S59, S66 |
| 6 | First-join state of the cobolcraft world type. | The stand-in starting kit stays in the cobolcraft type; the standard type starts empty. | The kit is content. | S23, spec US4-8 |
| 7 | Player chat: standard Player Chat and Disguised Chat with standard chat types, or CobolCraft's System Chat. | Standard, in both world types. | The standard commands need chat types (16 §8). | S34, P09-3, P09-14 |
| 8 | Operator status and bans: standard permission levels 0 to 4 and list semantics, or a binary operator. | Standard levels stored in `access.dat`. | Standard commands test levels (15 §2). | P07-4, spec FR-016, US14, US17 |
| 9 | World folder and configuration: keep CobolCraft's schemas (07 §9) and add `WorldType`; configuration key `world-type`. | Keep CobolCraft schemas; vanilla-loadable saves are not a goal. | The vanilla schemas are not documented and no decision asks for them. | P07-1, P07-3, spec FR-009 |
| 10 | Optional Faithful skin for the cobolcraft world type (Part 3.5). | An extra built-in pack, off by default, covering blocks and items only; entities keep their strips; turf is left out. | Cheap, reversible, keeps faithful §3 and §4 useful. | F-6, F-7, F-10 |
| 11 | Where the generated packs live and when they are rebuilt. | In the user's game directory under a git-ignored folder; rebuilt when the jar's SHA-256 differs from the recorded one; only a jar with the SHA-256 recorded in docs/protocol/README.md is accepted. | CC-0001: pack and jar are never committed; format risk. | GAP-32, C8, C10 |
| 12 | Missing-texture look. | Keep the orange and black stripes. | Engine-generated, tested. | S18, S20 |
| 13 | Handling of spec 001. | The next run's spec delta states that, for both world types, the shared rules of documents 10 to 21 supersede the stand-in rules cited in FR-002, FR-015, FR-016, US7, US8, US10, US11, SC-008 and that the spec's content items describe the cobolcraft world type. | Keeps the planner from reading FR-015 against R2. | Part 3.7 |
| 14 | Interim policy while a needed GAP is open. | Interim stand-in values only for the small gaps (GAP-26 ground items, GAP-11 weather timing, GAP-5b "all recipes known" in the cobolcraft type); wait for the others. | Registries and engines cannot be guessed. | S50, S66, R9 |
| 15 | Ticket text: CC-0001 (Summary "The stand-in content stays the source of the values"; Functional Requirements "its values come from `docs/design/standin-content.md` or `docs/protocol/`") and CC-0007's open questions. | Operator edits them; the answers are 24000 ticks and the standard timeline, both world types. | Operator's files. | K-1, K-3 |
| 16 | FR-009 settings `hostile-mobs`, `weather-changes`, `extra-dimensions`, `player-combat`, view-distance default 8. | Keep as CobolCraft settings mapped to difficulty, the gamerules `spawn_monsters` and `advance_weather`, and `pvp`; `extra-dimensions` applies to both types (Nether and End in the standard type). | Own configuration surface. | spec FR-009, US7, US9, US11, US12 |
| 17 | Sounds in the extraction tool. | The tool does not extract sounds; sounds stay out of scope. | Spec 001 Assumptions. | GAP-14 |
| 18 | The cobolcraft standard core (C3): is the small set of standard entries authored by hand. | Yes, authored in the documents (RS30), with the values of 17 §4.12, 17 §6.2 and 12 §3.2. | Shared rules need them; the type must run with no pack. | GAP-35, S37, S39, S42 |
| 19 | Order of the large research rounds (RS4, RS5, RS12, RS13, RS17, RS19 to RS22). | Order: RS1, RS2, RS3, RS4, RS5, then RS6 to RS11, RS15, RS16, RS18, RS19, then RS12 to RS14, RS17, RS20 to RS24. The planner may reorder. | Dependencies of Phase 2. | Part 6 |

## 8. Remaining open items for the planner

Counts are of the numbered items under each document's "Open questions" heading, counted by script over the numbered list
(`1.`, `2.`, ...) of that section. The third column counts those items whose text contains "operator", "planner" or
"decision" (a word match, not a classification). Items marked closed or resolved inside the section are included in the
count. Each item states in its own text whether it needs a decision, an implementation-time check or a later read; this part
does not restate them.

### 8.1 Design documents: topics of the open questions

- `docs/design/world-types.md` (17): standard choice disabled versus selectable while packs are invalid; jar versus generated
  directory at run time; type detection on the wire; opening a world made with another accepted jar; language collision; bare
  names in the cobolcraft world; vanilla client against a cobolcraft server; moving a world folder between machines; opened
  single-player worlds; seed text hash; save layout of 07 and 33; other roles for shared engines; skin pack placement; crafting
  bench values and operator confirmation; operator confirmation of the namespace reading.
- `docs/design/cobolcraft-standard-core.md` (26): `out_of_world` key; death message keys; chat type keys; enchantment effect
  shape; inferred block tags; completeness of the `day` timeline; dark horizon; food defaults; experience; mob tags; language
  keys; recipes 5 and 7 and the bench; tool requirement and break times; C3 departure; `cobolcraft:say`; vanilla-client
  configuration check; tool attack speed; starting kit location; `minecraft:` vocabulary beyond the core; spawn light
  fields; fixed-time dimension with no clock; spawn-cycle meanings; `/summon` of the abend; server-side mining acceptance; sea
  level for the weather engine.
- `docs/design/builtin-ui-art.md` (31): unread sprite sizes; sheet regions; attack indicator; recipe-book tabs and toasts;
  other sprite ids; boss bar and locator bar families; effect icon names; world-type naming and the 22 versus README C10
  conflict; title screen layout; options screen texts; label colours; font definitions; tooltip frame; existing screen layouts;
  banner focus; button borders; selectable or disabled standard choice; status-effect HUD layout; language keys the core lacks;
  world list rows; seed field texts; hardcore hearts; misc textures; minimum window size; recipe-book panel origin; contrast
  values.
- `docs/design/faithful-pack-mapping.md` (14): entity geometry; turf tolerance; wire-id implication; per-biome grass tint;
  inferred equivalents; built-in GUI art (about 96 sprites); break-stage set; rain and snow period; skin pack placement and
  toggle; built-in sky art; weather skin mechanism; GUI id list.
- `docs/design/standin-content.md` (15): other hard-coded vanilla keys; default variant lookups; item default components;
  empty-list HolderSet; fixed-time dimension type; `Time` of the §12 and §14 rules; bench texture and recipes; rendering of
  the two role entities; `block_transformer`; `cobolcraft:say`; tier tags; break times; interim rows; hail; subroutine clock.
- `docs/protocol/22-extraction-tool.md` (16): accepting an unknown jar; jar needed at run time; stack order and language
  keys; move tests of fixed entries; feature packs; shaders and unused assets; PNG decoder coverage (items 1 to 7; items 8 to
  16 are in the file).

### 8.2 Every document with an Open questions section

| Document | Open questions | Items naming operator, planner or decision | Subject (title of the document) |
|---|---|---|---|
| [builtin-ui-art.md](builtin-ui-art.md) | 31 | 9 | Built-in UI art, fallback UI texts, world type selection and missin... |
| [cobolcraft-standard-core.md](cobolcraft-standard-core.md) | 26 | 12 | The cobolcraft world type's standard core |
| [faithful-pack-mapping.md](faithful-pack-mapping.md) | 14 | 2 | Faithful 32x pack mapping and the cobolcraft skin (design) |
| [standin-content.md](standin-content.md) | 15 | 8 | Content of the cobolcraft world type |
| [world-types.md](world-types.md) | 17 | 12 | World types: the standard and the cobolcraft world type |
| [07-nbt-and-anvil.md](../protocol/07-nbt-and-anvil.md) | 13 | 1 | 07 — NBT binary format and Anvil region files |
| [08-resource-packs.md](../protocol/08-resource-packs.md) | 13 | 0 | 08 Resource packs |
| [09-cobolcraft-profile.md](../protocol/09-cobolcraft-profile.md) | 12 | 1 | 09 — CobolCraft protocol profile |
| [22-extraction-tool.md](../protocol/22-extraction-tool.md) | 16 | 3 | 22 Extraction tool and pack loaders |
| [23-registry-loading.md](../protocol/23-registry-loading.md) | 23 | 0 | 23 Registry loading, codecs and tag resolution |
| [24-block-registry-1-model-and-foundation.md](../protocol/24-block-registry-1-model-and-foundation.md) | 19 | 0 | Block registry, part 1: shared model and the foundation blocks (Blo... |
| [24-block-registry-2-leaves-flora-signs.md](../protocol/24-block-registry-2-leaves-flora-signs.md) | 21 | 0 | 24 — Block registry, part 2: leaves, flora, signs (ordinals 105 to ... |
| [24-block-registry-3-signs-doors-redstone.md](../protocol/24-block-registry-3-signs-doors-redstone.md) | 18 | 0 | Block registry, part 3: wall signs to huge mushroom blocks |
| [24-block-registry-4-stems-glass-skulls.md](../protocol/24-block-registry-4-stems-glass-skulls.md) | 13 | 0 | Block registry, part 4: stems, glass panes, vines, cauldrons, the E... |
| [24-block-registry-5-quartz-concrete-gates.md](../protocol/24-block-registry-5-quartz-concrete-gates.md) | 15 | 0 | Block registry, part 5: heads to fence gates (Blocks fields 420 to ... |
| [24-block-registry-6-gates-end-concrete-potted.md](../protocol/24-block-registry-6-gates-end-concrete-potted.md) | 15 | 0 | Block registry, part 6: gates, fences, doors, the End, concrete, th... |
| [24-block-registry-7-stairs-slabs-walls-workstations.md](../protocol/24-block-registry-7-stairs-slabs-walls-workstations.md) | 24 | 1 | Block registry, part 7: stairs, slabs, walls, workstations and the ... |
| [24-block-registry-8-blackstone-copper-deepslate-modern.md](../protocol/24-block-registry-8-blackstone-copper-deepslate-modern.md) | 26 | 0 | Block registry, part 8: cracked nether bricks to firefly bush (Bloc... |
| [25-item-registry-1-model-and-blocks-a.md](../protocol/25-item-registry-1-model-and-blocks-a.md) | 9 | 0 | Item registry, part 1: shared model and the block items of ids 0 to... |
| [25-item-registry-2-blocks-b.md](../protocol/25-item-registry-2-blocks-b.md) | 9 | 0 | Item registry, part 2: block items of ids 228 to 455 |
| [25-item-registry-3-blocks-c-and-utility.md](../protocol/25-item-registry-3-blocks-c-and-utility.md) | 10 | 1 | Item registry, part 3: block items from `polished_deepslate_wall` t... |
| [25-item-registry-4-boats-food-armor-signs.md](../protocol/25-item-registry-4-boats-food-armor-signs.md) | 13 | 1 | Item registry, part 4: boats, technical blocks, materials, tools, f... |
| [25-item-registry-5-buckets-maps-potions-misc.md](../protocol/25-item-registry-5-buckets-maps-potions-misc.md) | 6 | 0 | Item registry, part 5: buckets, maps, bottles, potions and miscella... |
| [25-item-registry-6-spawn-eggs-and-specials.md](../protocol/25-item-registry-6-spawn-eggs-and-specials.md) | 18 | 0 | Item registry, part 6: spawn eggs and special items (statements 940... |
| [25-item-registry-7-discs-ranged-patterns-horns.md](../protocol/25-item-registry-7-discs-ranged-patterns-horns.md) | 18 | 0 | Item registry, part 7: music discs, trident, nautilus items, crossb... |
| [25-item-registry-8-late-items-templates-sherds-trial.md](../protocol/25-item-registry-8-late-items-templates-sherds-trial.md) | 17 | 0 | Item registry, part 8: composter to ominous bottle (`Items` fields ... |
| [25-item-registry-x1-continuation.md](../protocol/25-item-registry-x1-continuation.md) | 4 | 1 | Item registry, continuation x1: the block items of ids 456 to 549 (... |
| [26-loot-and-predicates.md](../protocol/26-loot-and-predicates.md) | 17 | 0 | 26 Loot tables and predicates: the engine |
| [27-recipes-and-unlocks.md](../protocol/27-recipes-and-unlocks.md) | 13 | 0 | 27. Recipes, recipe book unlocks and the advancement engine |
| [28-enchantment-effects.md](../protocol/28-enchantment-effects.md) | 20 | 0 | Enchantment effect components: schema and engine |
| [29-block-updates-and-placement.md](../protocol/29-block-updates-and-placement.md) | 23 | 0 | 29. Block updates, ticking, block placement and block breaking |
| [29a-fluids.md](../protocol/29a-fluids.md) | 14 | 0 | 29a. Fluids: flow, states, waterlogging, buckets, bubble columns, e... |
| [29b-falling-growth-fire-1-model-gravity-bonemeal.md](../protocol/29b-falling-growth-fire-1-model-gravity-bonemeal.md) | 12 | 0 | 29b. Falling blocks, growth, fire and similar block behaviours, par... |
| [29b-falling-growth-fire-2-crops-and-stems.md](../protocol/29b-falling-growth-fire-2-crops-and-stems.md) | 8 | 0 | 29b. Falling blocks, growth, fire and similar block behaviours, par... |
| [29b-falling-growth-fire-3-spread-decay-snow-ice.md](../protocol/29b-falling-growth-fire-3-spread-decay-snow-ice.md) | 9 | 0 | 29b. Falling blocks, growth, fire and similar block behaviours, par... |
| [29b-falling-growth-fire-4-growing-plants.md](../protocol/29b-falling-growth-fire-4-growing-plants.md) | 13 | 0 | 29b. Falling blocks, growth, fire and similar block behaviours, par... |
| [29b-falling-growth-fire-5-fungi-moss-copper.md](../protocol/29b-falling-growth-fire-5-fungi-moss-copper.md) | 14 | 0 | 29b. Falling blocks, growth, fire and similar block behaviours, par... |
| [29b-falling-growth-fire-6-sculk-amethyst-dripstone.md](../protocol/29b-falling-growth-fire-6-sculk-amethyst-dripstone.md) | 11 | 0 | 29b. Falling blocks, growth, fire and similar block behaviours, par... |
| [29b-falling-growth-fire-7-aquatic-eggs-honey-cauldron.md](../protocol/29b-falling-growth-fire-7-aquatic-eggs-honey-cauldron.md) | 13 | 0 | 29b. Falling blocks, growth, fire and similar block behaviours, par... |
| [29b-falling-growth-fire-8-fire-tnt-residual.md](../protocol/29b-falling-growth-fire-8-fire-tnt-residual.md) | 14 | 0 | 29b. Falling blocks, growth, fire and similar block behaviours, par... |
| [30-redstone-1-model-signal-and-wire.md](../protocol/30-redstone-1-model-signal-and-wire.md) | 10 | 0 | 30 (part 1). Redstone: shared model, the signal queries, redstone w... |
| [30-redstone-2-repeaters-comparators-observers.md](../protocol/30-redstone-2-repeaters-comparators-observers.md) | 10 | 0 | 30-2 Redstone: repeaters, comparators, observers and analog output |
| [30-redstone-3-pistons.md](../protocol/30-redstone-3-pistons.md) | 9 | 0 | 30-3 Redstone: pistons |
| [30-redstone-4-dispensing-hoppers-crafters.md](../protocol/30-redstone-4-dispensing-hoppers-crafters.md) | 9 | 0 | 30-4 Redstone: dispensers, droppers, hoppers and crafters |
| [30-redstone-5-switches-plates-sensors-notes.md](../protocol/30-redstone-5-switches-plates-sensors-notes.md) | 12 | 0 | Redstone, part 5: levers, buttons, pressure plates, daylight detect... |
| [30-redstone-6-rails.md](../protocol/30-redstone-6-rails.md) | 10 | 0 | 30 Redstone, part 6: rails |
| [30-redstone-7-doors-lamps-bulbs-tnt.md](../protocol/30-redstone-7-doors-lamps-bulbs-tnt.md) | 15 | 0 | 30 (part 7). Redstone: power-driven openable blocks, lamps, copper ... |
| [30-redstone-8-tripwire-sculk-bells-vibration.md](../protocol/30-redstone-8-tripwire-sculk-bells-vibration.md) | 14 | 0 | 30 (part 8). Redstone: tripwire, sculk sensors, sculk shrieker, bel... |
| [31-block-entities-1-shared-model-and-containers.md](../protocol/31-block-entities-1-shared-model-and-containers.md) | 11 | 0 | 31-1 Block entities, part 1: shared model and plain containers |
| [31-block-entities-2-processing-and-redstone-containers.md](../protocol/31-block-entities-2-processing-and-redstone-containers.md) | 13 | 0 | 31-2 Block entities: processing and redstone containers |
| [31-block-entities-3-signs-banners-skulls-pots-shelves.md](../protocol/31-block-entities-3-signs-banners-skulls-pots-shelves.md) | 19 | 0 | 31. Block entities, part 3: signs, banners, skulls, decorated pots,... |
| [31-block-entities-4-jukebox-lectern-bell-campfire-brushable-beehive.md](../protocol/31-block-entities-4-jukebox-lectern-bell-campfire-brushable-beehive.md) | 17 | 0 | Block entities, part 4: jukebox, lectern, bell, campfire, enchantin... |
| [31-block-entities-5-beacon-conduit-end-piston-creaking.md](../protocol/31-block-entities-5-beacon-conduit-end-piston-creaking.md) | 7 | 0 | 31-5 Block entities, part 5: beacon, conduit, end portal, end gatew... |
| [31-block-entities-6-command-structure-jigsaw-test.md](../protocol/31-block-entities-6-command-structure-jigsaw-test.md) | 14 | 0 | 31-6 Block entities, part 6: command block, structure block, jigsaw... |
| [31-block-entities-7-spawners-trial-vaults.md](../protocol/31-block-entities-7-spawners-trial-vaults.md) | 12 | 0 | 31-7 Block entities, part 7: mob spawner, trial spawner and vault |
| [31-block-entities-8-sculk-and-remaining-types.md](../protocol/31-block-entities-8-sculk-and-remaining-types.md) | 15 | 0 | 31 Block entities, part 8: sculk family, statue, potent sulfur, tes... |
| [32-light-engine.md](../protocol/32-light-engine.md) | 13 | 0 | 32 — Light engine |
| [33-world-simulation.md](../protocol/33-world-simulation.md) | 19 | 1 | World simulation: server and level tick order, clocks and time, wea... |
| [34-entity-models-1-shared-model-and-framework.md](../protocol/34-entity-models-1-shared-model-and-framework.md) | 26 | 0 | Entity models and renderers, part 1: shared model, framework classe... |
| [34-entity-models-2-humanoids-zombies-skeletons-piglins.md](../protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md) | 10 | 0 | 34-2. Entity models and renderers: humanoid-base mobs (zombies, ske... |
| [34-entity-models-3-villagers-illagers-golems-misc.md](../protocol/34-entity-models-3-villagers-illagers-golems-misc.md) | 12 | 0 | 34 Entity models and renderers, part 3: villagers, illagers, golems... |
| [34-entity-models-4-farm-animals-equines.md](../protocol/34-entity-models-4-farm-animals-equines.md) | 18 | 0 | 34 Entity models and renderers, part 4: farm and ridable land animals |
| [34-entity-models-5-wild-companion-animals-small-creatures.md](../protocol/34-entity-models-5-wild-companion-animals-small-creatures.md) | 7 | 0 | 34 part 5. Entity models and renderers: wild and companion animals ... |
| [34-entity-models-6-overworld-hostiles-arthropods-slimes.md](../protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md) | 18 | 0 | Entity models and renderers, part 6: creeper, enderman, endermite, ... |
| [34-entity-models-7-nether-end-bosses.md](../protocol/34-entity-models-7-nether-end-bosses.md) | 11 | 0 | 34 part 7. Entity models and renderers: Nether and End mobs and bosses |
| [34-entity-models-8-aquatic-nautilus-boats.md](../protocol/34-entity-models-8-aquatic-nautilus-boats.md) | 15 | 0 | 34 Entity models and renderers, part 8: aquatic mobs, nautilus fami... |
| [34-entity-models-9-non-living-entities.md](../protocol/34-entity-models-9-non-living-entities.md) | 22 | 0 | 34 Entity models and renderers, part 9: entities without a living-m... |
| [35-worldgen-features-1-model-and-placement.md](../protocol/35-worldgen-features-1-model-and-placement.md) | 18 | 0 | 35 Worldgen features, part 1: shared model, generic features and pl... |
| [35-worldgen-features-2-predicates-and-providers.md](../protocol/35-worldgen-features-2-predicates-and-providers.md) | 12 | 0 | 35 World generation features, part 2: block predicates and block st... |
| [35-worldgen-features-3-tree-placers.md](../protocol/35-worldgen-features-3-tree-placers.md) | 9 | 0 | 35 World generation features, part 3: the tree feature and its placers |
| [35-worldgen-features-4-decorators-and-vegetation.md](../protocol/35-worldgen-features-4-decorators-and-vegetation.md) | 14 | 0 | World generation features, part 4: tree decorators and vegetation f... |
| [35-worldgen-features-5-water-and-surface.md](../protocol/35-worldgen-features-5-water-and-surface.md) | 10 | 0 | World generation features, part 5: water, ice, disks, blobs, corals... |
| [35-worldgen-features-6-underground.md](../protocol/35-worldgen-features-6-underground.md) | 17 | 0 | 35 World generation features, part 6: underground features (geodes,... |
| [35-worldgen-features-7-nether-end-misc.md](../protocol/35-worldgen-features-7-nether-end-misc.md) | 7 | 0 | 35 World generation features, part 7: nether, end and miscellaneous... |
| [36-structures-1-model-placement-starts.md](../protocol/36-structures-1-model-placement-starts.md) | 13 | 1 | 36 Structures, part 1: shared model, placement, starts, pieces base... |
| [36-structures-10-ancient-city-trial-chambers-trail-ruins.md](../protocol/36-structures-10-ancient-city-trial-chambers-trail-ruins.md) | 13 | 0 | 36 Structures, part 10: ancient city, trial chambers, trail ruins, ... |
| [36-structures-2-templates-and-processors.md](../protocol/36-structures-2-templates-and-processors.md) | 13 | 0 | 36 Structures, part 2: structure templates (structure NBT), placeme... |
| [36-structures-3-jigsaw-assembly.md](../protocol/36-structures-3-jigsaw-assembly.md) | 16 | 0 | 36-3 Structures, part 3: jigsaw assembly |
| [36-structures-4-scattered-and-small.md](../protocol/36-structures-4-scattered-and-small.md) | 17 | 0 | 36 Structures, part 4: scattered and small overworld structures (de... |
| [36-structures-5-mineshaft-stronghold.md](../protocol/36-structures-5-mineshaft-stronghold.md) | 16 | 0 | 36 Structures, part 5: mineshaft and stronghold (the recursive code... |
| [36-structures-6-ocean.md](../protocol/36-structures-6-ocean.md) | 15 | 0 | 36 Structures, part 6: ocean ruins, shipwrecks and the ocean monument |
| [36-structures-7-woodland-mansion.md](../protocol/36-structures-7-woodland-mansion.md) | 14 | 0 | 36 Structures, part 7: the woodland mansion |
| [36-structures-8-nether-and-end.md](../protocol/36-structures-8-nether-and-end.md) | 11 | 0 | 36 Structures, part 8: Nether fortress, End city and bastion remnant |
| [36-structures-9-villages-outposts.md](../protocol/36-structures-9-villages-outposts.md) | 15 | 0 | 36 Structures, part 9: villages, the zombie variant, the pillager o... |
| [37-nether-1-model-and-dimension-rules.md](../protocol/37-nether-1-model-and-dimension-rules.md) | 15 | 0 | 37-1 The Nether: shared model and dimension rules |
| [37-nether-2-noise-settings-and-density.md](../protocol/37-nether-2-noise-settings-and-density.md) | 14 | 0 | 37-2 The Nether: noise settings, density pipeline, legacy seeding, ... |
| [37-nether-3-biome-source-and-climate.md](../protocol/37-nether-3-biome-source-and-climate.md) | 11 | 0 | 37-3 The Nether: biome source, climate sampling and the five biome ... |
| [37-nether-4-surface-rules-and-carvers.md](../protocol/37-nether-4-surface-rules-and-carvers.md) | 13 | 0 | 37-4 The Nether: surface rules and carvers |
| [37-nether-5-features-and-decoration.md](../protocol/37-nether-5-features-and-decoration.md) | 11 | 0 | 37 The Nether, part 5: features and decoration |
| [37-nether-6-structures-spawns-hooks.md](../protocol/37-nether-6-structures-spawns-hooks.md) | 20 | 0 | 37 The Nether, part 6: structures, spawns and hooks |
| [38-end.md](../protocol/38-end.md) | 14 | 0 | 38 The End: generation and mechanics |
| [39-portals.md](../protocol/39-portals.md) | 14 | 0 | 39 Portals and dimension travel: nether portals, end portals, gatew... |
| [40-menus-1-model-and-containers.md](../protocol/40-menus-1-model-and-containers.md) | 14 | 0 | 40-1 Menus and screens, part 1: shared model and container menus |
| [40-menus-2-furnaces-brewing-crafter.md](../protocol/40-menus-2-furnaces-brewing-crafter.md) | 8 | 0 | 40-2 Menus, part 2: furnaces, brewing stand and crafter |
| [40-menus-3-anvil-grindstone-smithing.md](../protocol/40-menus-3-anvil-grindstone-smithing.md) | 14 | 0 | 40-3 Menus and screens, part 3: item combiner base, anvil, grindsto... |
| [40-menus-4-enchanting-loom-stonecutter-cartography.md](../protocol/40-menus-4-enchanting-loom-stonecutter-cartography.md) | 13 | 0 | 40-4 Menus and screens, part 4: enchanting table, loom, stonecutter... |
| [40-menus-5-merchant-beacon-lectern.md](../protocol/40-menus-5-merchant-beacon-lectern.md) | 12 | 0 | 40-5 Menus, part 5: merchant, beacon and lectern |
| [40-menus-6-mount-inventories.md](../protocol/40-menus-6-mount-inventories.md) | 8 | 0 | 40-6 Menus, part 6: mount inventories (horse, donkey, mule, llama, ... |
| [40-menus-7-creative-inventory.md](../protocol/40-menus-7-creative-inventory.md) | 17 | 0 | 40-7 Menus and screens, part 7: the creative inventory screen |
| [40-menus-8-book-and-sign-editors.md](../protocol/40-menus-8-book-and-sign-editors.md) | 17 | 0 | 40. Menus and screens, part 8: book and sign editors |
| [40-menus-9-block-editor-screens.md](../protocol/40-menus-9-block-editor-screens.md) | 9 | 0 | 40-9 Menus and screens, part 9: block editor screens (command block... |
| [40-menus-x1-continuation.md](../protocol/40-menus-x1-continuation.md) | 18 | 0 | 40. Menus and screens, continuation x1: the block editor screens |
| [41-item-entity-physics.md](../protocol/41-item-entity-physics.md) | 20 | 0 | 41. Item entity physics, drops and pickup |
| [42-particles-1-shared-model-engine.md](../protocol/42-particles-1-shared-model-engine.md) | 18 | 0 | 42. Particles, part 1: shared model, registry, options and engine core |
| [42-particles-2-effects-fire-smoke-magic.md](../protocol/42-particles-2-effects-fire-smoke-magic.md) | 15 | 0 | 42. Particles, part 2: effects, fire, smoke, magic, explosions, fir... |
| [42-particles-3-fluid-drip-water.md](../protocol/42-particles-3-fluid-drip-water.md) | 14 | 0 | 42. Particles, part 3: fluid drips, bubbles, water, ink and their e... |
| [42-particles-4-block-item-dust-ambient.md](../protocol/42-particles-4-block-item-dust-ambient.md) | 11 | 1 | 42. Particles, part 4: block, item, dust and ambient particles |
| [42-particles-5-sculk-trial-wind-geyser.md](../protocol/42-particles-5-sculk-trial-wind-geyser.md) | 15 | 0 | 42. Particles, part 5: sculk, trial, wind, vault, sulfur and geyser... |
| [42-particles-6-emitters-blocks.md](../protocol/42-particles-6-emitters-blocks.md) | 6 | 0 | 42. Particles, part 6: emitters driven by blocks |
| [42-particles-7-emitters-entities-events-commands.md](../protocol/42-particles-7-emitters-entities-events-commands.md) | 11 | 0 | 42. Particles, part 7: emitters for entities, entity events, level ... |
| [43-tint-sources.md](../protocol/43-tint-sources.md) | 13 | 0 | 43 Tint sources |
| [44-residual-mob-questions-1-shared-model-framework.md](../protocol/44-residual-mob-questions-1-shared-model-framework.md) | 17 | 0 | Residual mob questions, part 1: shared model and framework answers ... |
| [44-residual-mob-questions-2-spawning-structures.md](../protocol/44-residual-mob-questions-2-spawning-structures.md) | 4 | 0 | Residual mob questions, part 2: spawner blocks, trial spawners, cus... |
| [44-residual-mob-questions-3-villagers-poi-raids.md](../protocol/44-residual-mob-questions-3-villagers-poi-raids.md) | 31 | 0 | 44. Residual mob questions, part 3: villages, villagers, points of ... |
| [44-residual-mob-questions-4-land-animals.md](../protocol/44-residual-mob-questions-4-land-animals.md) | 13 | 0 | 44. Residual mob questions, part 4: land animals |
| [44-residual-mob-questions-5-overworld-hostile.md](../protocol/44-residual-mob-questions-5-overworld-hostile.md) | 18 | 0 | 44 — Residual mob questions, part 5: overworld hostile mobs (round ... |
| [44-residual-mob-questions-6-nether.md](../protocol/44-residual-mob-questions-6-nether.md) | 12 | 0 | Residual mob questions 6: piglin and hoglin engines, strider, Nethe... |
| [44-residual-mob-questions-7-aquatic.md](../protocol/44-residual-mob-questions-7-aquatic.md) | 10 | 0 | Residual mob questions, part 7: aquatic mobs, nautilus family, amph... |
| [44-residual-mob-questions-8-vehicles-and-projectiles.md](../protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md) | 20 | 0 | Residual mob questions, part 8: vehicles and projectiles |
| [44-residual-mob-questions-9-end-bosses-decorations.md](../protocol/44-residual-mob-questions-9-end-bosses-decorations.md) | 7 | 0 | 44-9. Residual mob questions, part 9: End bosses, decoration entiti... |
| [44-residual-mob-questions-x1-continuation.md](../protocol/44-residual-mob-questions-x1-continuation.md) | 7 | 0 | 44 — Residual mob questions, continuation x1 (round RS26) |
| [44-residual-mob-questions-x2-continuation.md](../protocol/44-residual-mob-questions-x2-continuation.md) | 24 | 0 | 44 — Residual mob questions, continuation x2 (round RS26) |
| [45-entity-nbt-1-shared-model-and-entity-base.md](../protocol/45-entity-nbt-1-shared-model-and-entity-base.md) | 18 | 1 | 45. Entity NBT, part 1: shared model and the Entity base |
| [45-entity-nbt-2-living-entity-mob-animal.md](../protocol/45-entity-nbt-2-living-entity-mob-animal.md) | 22 | 0 | 45. Entity NBT, part 2: LivingEntity, Mob, Animal and the shared Br... |
| [45-entity-nbt-3-player-and-player-data.md](../protocol/45-entity-nbt-3-player-and-player-data.md) | 22 | 0 | 45-3 Entity and player NBT: the player, its data file, advancements... |
| [45-entity-nbt-4-land-animals.md](../protocol/45-entity-nbt-4-land-animals.md) | 14 | 0 | 45. Entity NBT, part 4: land animals |
| [45-entity-nbt-5-hostile-mobs.md](../protocol/45-entity-nbt-5-hostile-mobs.md) | 15 | 0 | 45 — Entity NBT, part 5: hostile mobs (round RS27) |
| [45-entity-nbt-6-villagers-illagers-piglins.md](../protocol/45-entity-nbt-6-villagers-illagers-piglins.md) | 18 | 0 | 45. Entity NBT, part 6: villagers, wandering trader, illagers and r... |
| [45-entity-nbt-7-aquatic-and-misc-mobs.md](../protocol/45-entity-nbt-7-aquatic-and-misc-mobs.md) | 16 | 0 | Entity NBT, part 7: aquatic mobs, nautilus family, strider, buckete... |
| [45-entity-nbt-8-vehicles-projectiles-items.md](../protocol/45-entity-nbt-8-vehicles-projectiles-items.md) | 16 | 0 | Entity NBT, part 8: items, orbs, blocks, clouds, displays, vehicles... |
| [45-entity-nbt-9-bosses-and-decorations.md](../protocol/45-entity-nbt-9-bosses-and-decorations.md) | 15 | 2 | 45. Entity NBT, part 9: bosses, decorations, boss-bar and dragon-fi... |
| [46-registry-ids.md](../protocol/46-registry-ids.md) | 15 | 0 | Static registry ids on the wire |
| [47-default-skin.md](../protocol/47-default-skin.md) | 13 | 1 | Default player skin and skin handling |
| Total (133 documents) | 1926 | 59 | |
