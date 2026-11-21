# Feature Specification: Client polish: visuals, controls and missing gameplay

**Feature Branch**: `002-client-polish`

**Created**: 2026-11-09

**Status**: Draft

**Input**: Spile ticket CC-0001 "Client polish: visuals, controls and missing gameplay" (`tickets/CC-0001-client-polish.md`) as a whole, in one feature: its Summary, User Stories, Functional Requirements and Decisions. CC-0007 (lighting, sky, fog, clouds) is out of scope. The standard Minecraft 26.3 behaviour and content is specified in `docs/protocol/` (documents 10 to 47, indexed in `docs/protocol/README.md`) and `docs/design/` (`README.md` is the source-of-truth map and status log; `world-types.md`, `cobolcraft-standard-core.md`, `builtin-ui-art.md`, `standin-content.md` for the cobolcraft world type, `faithful-pack-mapping.md`).

**How to read this spec.** It states what the Player (and the Server operator, who hosts a world) can do and see, not how. Every value (sizes, speeds, counts, timings, colours, ids, formulas) is in the documents named in the Requirements; this spec does not repeat or invent them (constitution Principle II). Where a document leaves an Open question, it is listed under Clarifications or Assumptions, not decided here. Feature 001 (`specs/001-cobolcraft-complete/spec.md`) stays valid for what it describes, with the supersessions of FR-040.

## Clarifications

### Session 2026-11-09

Three decisions needed the operator before tasks are generated (constitution Principle 1.3); all are answered and recorded below.

- Q: While the generated vanilla packs are missing or invalid, should the standard world type on the world-creation screen be disabled, or selectable with an explanation shown when the Player presses Create? → A: B: The standard choice stays selectable; Create is refused with an explanation of how to build the packs (builtin-ui-art.md §7.2).
- Q: Does the operator confirm adding one `cobolcraft:crafting_bench` block and item to the cobolcraft world type, or must that type craft 3x3 recipes some other way? → A: Confirmed, and any other cobolcraft content this feature needs to work in the cobolcraft type may be added; CC-0001's "unchanged" wording does not forbid necessary additions.
- Q: Does CC-0001's "`minecraft:` for anything with a vanilla equivalent" leave the invented cobolcraft content (greystone, operator, loose_item and the rest) in `cobolcraft:`, with the two world types holding none of each other's content (`world-types.md` Decision WT-25, Open question 17)? → A: Yes, confirmed: invented content stays in `cobolcraft:`, the standard world uses only `minecraft:` content, and the two world types share no content.

## User Scenarios & Testing *(mandatory)*

Stories are sequenced by dependency: the assets and data come first (everything draws from them), then world types and packs, then how things look, then controls and screens, then gameplay and the world itself, then validation with a reference client.

### User Story 1 - As a Player, I want the game to build the vanilla assets and data from my own Minecraft jar (Priority: P1)

The Player (or Server operator) points the game at their own Minecraft 26.3 client jar. A tool reads it and writes a vanilla resource pack and a vanilla data pack into the game directory. The client and the server then load them. Nothing from the jar is ever in the repository.

**Why this priority**: The standard world type, the pack look, recipes, loot, tags, registries and world generation data all come from these packs (README C2, C8). Without them only the cobolcraft world type can run.

**Independent Test**: Run the tool against the jar whose SHA-256 is recorded in `docs/protocol/README.md`, then start the client and a server; both load the packs and report no loader errors. Run it with a missing, wrong or unrecognised jar and the standard type is unavailable with a clear reason.

**Acceptance Scenarios**:

1. **Given** the supported jar in the game directory, **When** the tool runs, **Then** a vanilla resource pack (models, block states, item definitions, atlases, language, textures with their animation files, fonts, colormaps, particle definitions, equipment definitions) and a vanilla data pack (recipes, loot tables, tags, registry data, worldgen JSON) exist in the game directory, in the layout of `docs/protocol/22-extraction-tool.md`.
2. **Given** generated packs and an unchanged jar, **When** the tool runs again, **Then** it does not rebuild them; **When** the jar's SHA-256 differs from the recorded one, **Then** it is rejected (README Part 7 decision 11; accepting an unknown jar is 22 Open question 1).
3. **Given** no valid jar, **When** the game starts, **Then** the cobolcraft world type still works with nothing generated, and the game states why a standard world cannot be created or opened (README C10).
4. **Given** the generated packs, **When** the server and the client load them, **Then** registries, tags, recipes, loot and worldgen data are read through the loaders of `docs/protocol/23-registry-loading.md`, and neither the packs nor the jar appear in any commit.

---

### User Story 2 - As a Player, I want to choose between the standard world and the cobolcraft world (Priority: P1)

When creating a world, the Player picks a world type. The standard type is Minecraft 26.3 content; the cobolcraft type is the invented content that runs with no jar and no packs. Standard gameplay rules apply to both.

**Why this priority**: It is the mechanism that keeps the cobolcraft content demoable while the standard content arrives (`docs/design/world-types.md`).

**Independent Test**: Create one world of each type; each opens, remembers its type after a restart, and behaves by the shared rules (day length, health, crafting screens).

**Acceptance Scenarios**:

1. **Given** the generated packs are present, **When** the Player creates a world, **Then** both types are offered and the default is standard (README Part 7 decision 2).
2. **Given** the generated packs are missing or invalid, **When** the Player opens the creation screen, **Then** the standard choice stays selectable and pressing Create is refused with an explanation of how to build the packs (FR-003, decided in Clarifications), and the cobolcraft type works.
3. **Given** a saved world of either type, **When** it is reopened, **Then** it opens as the same type; a standard world on a machine with no valid packs is not opened and the game says why (`world-types.md` §8.2).
4. **Given** a world of either type, **When** the Player plays, **Then** health, hunger, damage, the hit window, day length, movement, commands, crafting screens and ground items follow the shared standard rules of documents 10 to 21, not the retired stand-in values.

---

### User Story 3 - As a Player, I want the game to load and use my resource pack, Faithful 32x (Priority: P1)

The Faithful 32x pack for 26.3 (`Faithful 32x - 26.3.zip`, `minecraft:` namespace, textures only) is in the game directory's `resourcepacks/` folder. The Player enables it on the resource pack screen and the whole game is drawn with it.

**Why this priority**: The operator supplied the pack as the visual target; it is the main way the game stops looking like a debug renderer.

**Independent Test**: Put the pack in the folder, enable it, and look at blocks, items, mobs, HUD, inventory, crack overlay, particles, weather and text; they use the pack at 32x. Disable it or restart and the look reverts or persists accordingly.

**Acceptance Scenarios**:

1. **Given** the pack in `resourcepacks/`, **When** the Player opens the resource pack screen, **Then** it is listed, and can be enabled and moved up or down the stack (`docs/protocol/13-client-gameplay-and-controls.md` §8).
2. **Given** the pack is enabled, **When** the Player looks at the world, **Then** blocks, items, mobs, the HUD, the inventory and crafting screens, the crack overlay, particles, weather and text are drawn with the pack's textures at 32x wherever the pack supplies one; the built-in and generated packs fill every gap, and nothing the pack covers is drawn with the missing-texture stripes (README Part 7 decision 12).
3. **Given** the pack's texture animation files and its connected-texture rules, **When** the pack is enabled, **Then** animations play, and a rule the client does not support is ignored without error (`docs/protocol/14-texture-only-packs.md`).
4. **Given** the pack is enabled and the game restarts, **Then** it is still enabled; **Given** it is disabled, **Then** the stand-in or generated look returns.
5. **Given** the pack stack, **Then** the order is: built-in pack, generated vanilla pack, the user's packs in the user's order, server-pushed packs (README C7); the pack's `minecraft:` textures replace the generated ones by path and do not affect `cobolcraft:` content unless the optional skin is on (FR-006).
6. **Given** the pack is in the `minecraft:` namespace, **When** the client loads packs, **Then** the client uses `minecraft:` for anything with a vanilla equivalent so the pack applies directly by path, and `cobolcraft:` only where CobolCraft extends or diverges (`docs/protocol/08-resource-packs.md` §1.6).

---

### User Story 4 - As a Player on the resource pack screen, I want an Open Pack Folder button (Priority: P3)

**Why this priority**: Convenience; packs can be copied in by hand without it.

**Independent Test**: Press the button; the system file browser shows the `resourcepacks/` folder. Copy a pack in, return, and see it listed.

**Acceptance Scenarios**:

1. **Given** the resource pack screen, **When** the Player presses Open Pack Folder, **Then** the system's file browser opens the game directory's `resourcepacks/` folder (created if missing).
2. **Given** a pack was copied in, **When** the Player returns to the screen and it refreshes, **Then** the new pack is listed.

---

### User Story 5 - As a Player, I want the world's textures to look finished (Priority: P1)

**Why this priority**: The first manual run looked like a debug renderer; this is the headline defect.

**Independent Test**: Walk past and fly over textured terrain at near and far distances; look for seams, shimmering and bleeding between neighbouring textures.

**Acceptance Scenarios**:

1. **Given** any stand-in or pack texture, **When** drawn at any distance, **Then** it looks as its author intended, with no seams, shimmering or bleeding between atlas cells (`docs/protocol/12-client-rendering.md`).
2. **Given** the texture path of every block, item and mob of the cobolcraft world type, **Then** each is written in `docs/design/` (`faithful-pack-mapping.md`) before implementation; an unmapped one shows the missing-texture look rather than an invented one.

---

### User Story 6 - As a Player, I want the HUD and screens to look deliberate (Priority: P1)

**Why this priority**: Second half of the "debug renderer" complaint; every screen is affected.

**Independent Test**: Open the HUD, inventory, bench screen and menus at several window sizes with and without the pack; check alignment, spacing, readability and the count rule.

**Acceptance Scenarios**:

1. **Given** the HUD, inventory and menus, **When** shown, **Then** text, slots and buttons are aligned, consistently spaced and readable at the window's size (`docs/protocol/12-client-rendering.md` §5).
2. **Given** a stack of 1 item, **When** its slot is drawn, **Then** no count is shown; counts appear from 2 up.
3. **Given** the Faithful 32x pack, **When** the HUD, inventory, crafting and menu screens are drawn, **Then** their layout, sprites, nine-slice scaling and font follow the pack's GUI textures (12 §5, `docs/protocol/14-texture-only-packs.md` §6).
4. **Given** the cobolcraft world type with no pack, **When** these screens are drawn, **Then** original built-in art, font and language are used so nothing is blank (`docs/design/builtin-ui-art.md`, README C11).

---

### User Story 7 - As a Player, I want double Space to fly only in creative, and no endless climb in survival (Priority: P1)

**Why this priority**: Survival currently allows flight and endless climbing, which breaks the game.

**Independent Test**: In creative double-tap Space to toggle flight; in survival double-tap and mash Space in the air and confirm no flight and no rise above one jump.

**Acceptance Scenarios**:

1. **Given** creative mode, **When** Space is pressed twice quickly, **Then** flying turns on, or off if flying (`13` §1.4).
2. **Given** survival mode, **When** Space is pressed twice quickly, **Then** the Player does not fly.
3. **Given** survival and in the air, **When** Space is pressed again, **Then** no new jump starts; the Player never rises above the height of one jump from the ground.

---

### User Story 8 - As a Player in survival, I want to see a block breaking (Priority: P2)

**Independent Test**: Hold the break button on a block; watch the crack grow in stages and the block break; release and see it vanish; watch a second player break a block.

**Acceptance Scenarios**:

1. **Given** the break button held on a block in survival, **When** breaking progresses, **Then** a crack overlay grows in stages until the block breaks (`13` §2.4).
2. **Given** release or looking away, **Then** the overlay disappears.
3. **Given** another player breaks a block I can see, **Then** I see their crack overlay too.
4. **Given** the pack is enabled, **Then** the overlay uses the pack's break-stage textures (`faithful-pack-mapping.md`).

---

### User Story 9 - As a Player, I want to craft from the inventory screen and use the recipe book (Priority: P1)

**Independent Test**: Open the inventory, place ingredients in the 2x2 grid, take the result; open the recipe book, see known and craftable recipes, choose one and see the grid filled.

**Acceptance Scenarios**:

1. **Given** the inventory screen, **When** ingredients are placed in the small grid, **Then** the result slot shows what they make and taking it uses up the ingredients (`13` §3).
2. **Given** the inventory screen, **When** the recipe book is opened, **Then** the known recipes are listed with those makeable now marked, and choosing one fills the grid from the inventory (`13` §3.8, §3.9).
3. **Given** the inventory screen, **Then** it is the 46-slot inventory menu, including the off-hand slot (`12` §5.6a).
4. **Given** the new grids, **Then** feature 001's single crafting screen (US10, the C key) is removed; crafting happens only in the inventory and bench screens.

---

### User Story 10 - As a Player, I want to craft a crafting bench and use it (Priority: P1)

**Independent Test**: Craft the bench, place it, use it, make a recipe that needs the large grid.

**Acceptance Scenarios**:

1. **Given** the ingredients, **When** the Player crafts a crafting bench and places it, **Then** it stands in the world as a block.
2. **Given** a placed bench, **When** used, **Then** a crafting screen opens with the large grid, a result slot and the recipe book (`12` §5.6b, `13` §3.5).
3. **Given** a recipe that needs the large grid, **Then** it can be made only at a bench.
4. **Given** the cobolcraft world type, **Then** the bench is the `cobolcraft:crafting_bench` block and item (FR-027, decided in Clarifications).

---

### User Story 11 - As a Player, I want worlds generated like vanilla's (Priority: P1)

**Independent Test**: Create a standard world with a fixed seed, explore terrain, caves and ore; compare against the documented algorithm's tests (worked examples in documents 10 and 11).

**Acceptance Scenarios**:

1. **Given** a new standard world, **When** the Player explores, **Then** terrain is built the way vanilla builds it: climate-driven biomes, 3D density terrain with hills, mountains, rivers and oceans, aquifers, and three kinds of caves (large caverns, long winding tunnels, thin noodle passages) (`docs/protocol/10-world-generation-terrain.md`, `11-world-generation-caves-and-ores.md`).
2. **Given** ores, **When** the Player digs, **Then** each ore is spread through its depth range as vanilla spreads it: uniform or triangle height distributions, a vein size and a count per chunk; some ores occur only at certain depths or in certain biomes (`11`).
3. **Given** ore blocks broken in survival, **Then** they drop their items as other blocks do (`11` §9).
4. **Given** this feature, **Then** it supersedes feature 001's FR-015 for the standard world type; the cobolcraft type keeps its own generator (standin §5.2).

---

### User Story 12 - As a Player, I want the rest of the standard world: trees, vegetation, lakes, the Nether, the End, structures and redstone (Priority: P2)

**Why this priority**: Operator decision "World scope": these are in this run, not deferred.

**Independent Test**: Explore a standard world for trees, flowers, lakes, a village or other structure; build a portal to the Nether and travel on; reach the End; build a redstone circuit.

**Acceptance Scenarios**:

1. **Given** a standard world, **When** the Player explores the overworld, **Then** trees, vegetation and lakes appear with the feature rules of `docs/protocol/35-*`.
2. **Given** the standard structures, **Then** they generate by the rules of `docs/protocol/36-*` and `44-residual-mob-questions-2-spawning-structures.md`.
3. **Given** a portal, **When** used, **Then** the Player travels to the Nether and the End by the rules of `37-*`, `38-end.md` and `39-portals.md`.
4. **Given** redstone components, fluids, falling blocks, growth, fire and block updates, **Then** they behave by `29-*`, `29a-fluids.md`, `29b-*` and `30-*`, and block entities by `31-*`.

---

### User Story 13 - As a Player, I want all the standard Minecraft commands to work (Priority: P2)

**Independent Test**: Run `/give`, `/tp`, `/gamemode` and others from the catalog with and without permission; compare arguments, completions and messages with `docs/protocol/16-commands-catalog.md`.

**Acceptance Scenarios**:

1. **Given** the permission, **When** the Player types a standard command, **Then** it works as in Minecraft with the same arguments, completions and messages (`15`, `15a`, `16`).
2. **Given** a standard command not named here, **Then** it works too; the full catalog is the goal.
3. **Given** permission levels 0 to 4, **Then** commands are gated by level (README Part 7 decision 8).
4. **Given** the cobolcraft world type, **Then** commands run against cobolcraft registries; a bare name means `minecraft:` (`world-types.md` §6.3).

---

### User Story 14 - As a Player, I want all the tools and weapons to work (Priority: P2)

**Acceptance Scenarios**:

1. **Given** a standard tool or weapon in hand, **When** used, **Then** it breaks blocks at its speed and tier, deals its damage, loses durability and has its special uses (`docs/protocol/17-tools-weapons-and-combat.md`).
2. **Given** armour, enchantments and the combat rules (hit window, knockback), **Then** they follow `17` and `28`.

---

### User Story 15 - As a Player, I want all the standard mobs to exist and behave as they do (Priority: P2)

**Acceptance Scenarios**:

1. **Given** a standard mob, **When** met, **Then** it has its standard appearance, health, drops, spawning rules and behaviour (`18` to `21`, `34-*`, `44-*`).
2. **Given** the standard rules, **Then** where they differ from stand-in content the standard rule wins (FR-041).

---

### User Story 16 - As a Player, I want to configure the game (Priority: P2)

**Independent Test**: Open Options from the title screen and the pause menu, change values, restart, confirm they persist.

**Acceptance Scenarios**:

1. **Given** the title screen or the pause menu, **When** Options is opened, **Then** at least view distance, mouse sensitivity, field of view and GUI scale can be changed, plus the options documented in `13` §7.
2. **Given** a changed option, **When** the game restarts, **Then** it is still set (`13` §7.1).

---

### User Story 17 - As a Player, I want an F3 debug overlay (Priority: P3)

**Acceptance Scenarios**:

1. **Given** a world, **When** F3 is pressed, **Then** an overlay shows position (x, y, z), the block and chunk, facing, dimension, frame rate and the other diagnostics of `13` §5.
2. **Given** the overlay shown, **When** F3 is pressed again, **Then** it hides.

---

### User Story 18 - As a Player, I want F5 to switch the camera view (Priority: P3)

**Acceptance Scenarios**:

1. **Given** a world, **When** F5 is pressed repeatedly, **Then** the view cycles first person, third person from behind, third person from in front, first person (`13` §6).
2. **Given** a third-person view, **Then** the Player's model is drawn and the camera does not pass through blocks.

---

### User Story 19 - As a Player, I want F to swap an item into my off hand (Priority: P2)

**Acceptance Scenarios**:

1. **Given** no screen is open, **When** F is pressed, **Then** the held hotbar item and the off-hand item swap (`13` §4).
2. **Given** the inventory screen with the mouse over a slot, **When** F is pressed, **Then** that slot's item and the off-hand item swap.
3. **Given** an item in the off hand, **Then** the off-hand slot is shown beside the hotbar.

---

### User Story 20 - As a Player, I want to see my hand and what I am holding (Priority: P2)

**Acceptance Scenarios**:

1. **Given** first person, **Then** the main hand is drawn at the lower right of the view, holding the selected item or block as a small 3D model (`12`).
2. **Given** breaking, placing or attacking, **Then** the hand plays a swing animation.

---

### User Story 21 - As a Contributor, I want a vanilla client to be usable for validating the standard world type (Priority: P3)

Operator decision "Vanilla client": a vanilla client playing on our server is a current or future goal for validating the implementation; its exact scope is left to planning.

**Acceptance Scenarios**:

1. **Given** the standard world type, **Then** its block, item and entity ids, registry contents and chunk encodings match vanilla's (README R8, C1, C14), so a reference client can validate them.
2. **Given** a vanilla client against a cobolcraft-type server, **Then** it passes configuration only (`docs/protocol/04-registry-sync.md` §5); whether it is refused at login is open (`world-types.md` Open question 8).

---

### Edge Cases

- A pack has a texture the client cannot decode, an animation file that is malformed, or a connected-texture rule the client does not support: the rest of the pack still loads, nothing crashes, and the affected item falls back to the pack below it.
- The pack zip is removed or renamed while enabled: the stack falls back and the screen says so.
- Two packs supply the same path: the higher pack in the stack wins.
- A stack of 1, 2, 64 and a count too wide for the slot: the count rule and alignment hold.
- Window sizes at and below the smallest supported size and every GUI scale: nothing overlaps or is cut off (builtin-ui-art Open question on the minimum window size).
- Jump key held on the ground in survival: repeats jumps as before, never exceeds one jump height from the ground in the air.
- Break progress interrupted by changing the held item, the target block changing, or the block being broken by another player.
- Crack overlay while several players break different blocks at once.
- Recipe book with no known recipes, with a recipe that needs the bench opened in the inventory, and with a full inventory when filling the grid.
- A standard world opened after the generated packs were deleted or rebuilt from another jar (`world-types.md` Open question 4).
- The jar changes between runs: the packs are regenerated; stale loaders do not read half-written output.
- F5 camera inside a one-block-high space: the camera shortens rather than passing through blocks.
- Options file missing, unreadable or holding an out-of-range value: defaults apply and the game starts.
- F pressed with an empty hand or an empty off hand.
- Ore exposed in a cave or aquifer; a vein crossing a chunk border.
- Command argument with an unknown namespace, or a standard item name inside a cobolcraft world.

## Requirements *(mandatory)*

Values come from the named documents only (FR-042). "The standard" means documents 10 to 47 of `docs/protocol/`.

### Functional Requirements

**Assets, data and world types**

- **FR-001**: The system MUST provide a tool, written in COBOL, that reads the user's own Minecraft 26.3 client jar and writes a vanilla resource pack and a vanilla data pack into the user's game directory, as specified in `docs/protocol/22-extraction-tool.md`; the jar and the generated packs MUST NOT be committed.
- **FR-002**: The client and the server MUST load the generated packs through the loaders of `docs/protocol/23-registry-loading.md`; the standard world type's registries, tags, recipes, loot and worldgen data MUST come from them, unaltered.
- **FR-003**: The world-creation screen MUST offer the standard and the cobolcraft world types, default standard when valid packs exist; when the packs are invalid the standard choice MUST stay selectable, and pressing Create MUST be refused with an explanation of how to build the packs (`builtin-ui-art.md` §7.2; this supersedes the disabled reading of `docs/protocol/22-extraction-tool.md` §9.2).
- **FR-004**: A world MUST record its type and reopen as that type; a standard world MUST NOT open without valid packs, and the game MUST state why.
- **FR-005**: The standard type MUST use `minecraft:` for everything with a vanilla equivalent; the cobolcraft type MUST keep its invented `cobolcraft:` content, runnable with no jar and no packs, with the standard core of `docs/design/cobolcraft-standard-core.md`. Namespace reading (`world-types.md` Decision WT-25, confirmed): invented content stays in `cobolcraft:`, the standard world uses only `minecraft:` content, and the two world types share no content.
- **FR-006**: The optional Faithful skin for the cobolcraft type (README Part 7 decision 10) is off by default and, when on, covers blocks and items only; its placement in the pack stack is `world-types.md` Open question 14.

**Resource packs and look**

- **FR-007**: The client MUST load a pack in the `minecraft:` namespace in the format of `docs/protocol/08-resource-packs.md` and `docs/protocol/14-texture-only-packs.md`, and the Faithful 32x pack for 26.3 MUST load and apply by path.
- **FR-008**: The resource pack screen MUST list the packs in `resourcepacks/`, enable, disable and reorder them, persist the choice, and have an Open Pack Folder button that opens that folder in the system file browser and shows new packs after a refresh (`13` §8).
- **FR-009**: With a pack enabled, blocks, items, mobs, HUD, inventory and crafting screens, the crack overlay, particles, weather and text MUST be drawn with the pack's textures at the pack's resolution wherever supplied; the pack stack order MUST be built-in, generated, user packs, server packs (README C7). Sky, fog and clouds are out of scope (FR-043).
- **FR-010**: Texture animations MUST play and unsupported connected-texture rules MUST be ignored without error.
- **FR-011**: Textures MUST be drawn without seams, shimmering or bleeding between atlas cells at any distance.
- **FR-012**: The texture path each cobolcraft block, item and mob uses MUST be written in `docs/design/` before implementation.
- **FR-013**: The HUD, inventory, bench and menus MUST be aligned, consistently spaced and readable at the window's size; their layout, sprites, nine-slice scaling and font MUST follow the enabled pack's GUI textures, and the cobolcraft type MUST carry original built-in UI art, font and language (`builtin-ui-art.md`).
- **FR-014**: A slot holding 1 item MUST show no count; 2 or more MUST show it.
- **FR-015**: The missing-texture look (orange and black stripes) MUST remain for content no pack covers.

**Controls**

- **FR-016**: Double Space MUST toggle flight only where the server has granted flight (creative, spectator); in survival it MUST NOT fly (`13` §1.4).
- **FR-017**: In survival, pressing Space in the air MUST NOT start a new jump; the Player MUST NOT rise above one jump height from the ground.
- **FR-018**: F3 MUST toggle the debug overlay showing the entries of `13` §5.
- **FR-019**: F5 MUST cycle first person, third person from behind, third person from in front (`13` §6); the Player model MUST be drawn in third person and the camera MUST NOT pass through blocks.
- **FR-020**: F MUST swap the held hotbar item with the off-hand item with no screen open, and a hovered slot's item with the off-hand item in the inventory screen (`13` §4); the off-hand slot MUST show beside the hotbar.
- **FR-021**: In first person the main hand MUST be drawn at the lower right holding the selected item or block as a small 3D model, with a swing animation on break, place and attack.
- **FR-022**: The Options screen, reachable from the title screen and the pause menu, MUST allow at least view distance, mouse sensitivity, field of view and GUI scale, plus the options documented in `13` §7, and MUST persist them (`13` §7.1). Texts for options the documents do not supply are `builtin-ui-art.md` Open question 13.

**Breaking and crafting**

- **FR-023**: In survival a crack overlay MUST grow in stages while a block is held in breaking, vanish when breaking stops, and be shown for other players' breaking (`13` §2.4).
- **FR-024**: The inventory screen MUST contain a 2x2 crafting grid, a result slot, and the recipe book; the recipe book MUST list known recipes, mark those makeable now, and fill the grid from the inventory on selection (`13` §3.5, §3.8, §3.9).
- **FR-025**: Taking the crafted result MUST use up the ingredients (`13` §3.6).
- **FR-026**: A crafting bench MUST be craftable, placeable as a block, and open a screen with the 3x3 grid, a result slot and the recipe book; recipes needing the large grid MUST be makeable only there.
- **FR-027**: In the cobolcraft type the bench is the `cobolcraft:crafting_bench` block and item of `cobolcraft-standard-core.md` §5; any further cobolcraft content this feature needs to work in that type MAY be added, and each addition MUST be recorded in the design documents before it is implemented.
- **FR-028**: Feature 001's crafting screen (US10, the C key) MUST be removed.

**World**

- **FR-029**: Standard overworld terrain, climate, biomes, aquifers and the three cave kinds MUST be generated as `docs/protocol/10` and `11` specify, including the standard world geometry (README C4).
- **FR-030**: Ores MUST be placed by the distributions, vein sizes and counts of `11`, and ore blocks MUST drop their items when broken in survival.
- **FR-031**: Trees, vegetation and lakes, structures, the Nether, the End and portals MUST follow `35` to `39` and `44`.
- **FR-032**: Redstone, fluids, falling blocks, growth, fire, block updates and block entities MUST follow `29` to `31`.
- **FR-033**: The cobolcraft type MUST keep its own generators (standin §5.2, §15.2).

**Gameplay shared by both types**

- **FR-034**: The standard command set MUST work with its arguments, completions, messages and permission levels 0 to 4 (`15` to `16`).
- **FR-035**: Standard tools and weapons MUST work (speed, tier, damage, durability, special uses) per `17`.
- **FR-036**: Standard mobs MUST exist with their appearance, health, drops, spawning and behaviour per `18` to `21`, `34` and `44`.
- **FR-037**: Health, hunger, hit window, fall damage, day length, ground items and weather mechanism MUST follow the shared standard rules in both types (README R2, C5, C6).
- **FR-038**: Menus, block entities and item entities MUST follow `40`, `31` and `41`; particles `42`; tints `43`; the default skin `47`.

**Cross-cutting**

- **FR-039**: The standard type's block, item and entity ids, registry contents and chunk encodings MUST match vanilla's so a reference client can validate them; the validation scope is decided in planning (CC-0001 "Vanilla client", README Part 7 decision 1).
- **FR-040**: This feature supersedes feature 001's stand-in rules for both types as README Part 7 decision 13 lists: FR-002, FR-015, FR-016, US7, US8, US10, US11 and SC-008, for world generation (standard type), commands, crafting, and shared rules.
- **FR-041**: Where the standard behaviour (`docs/protocol/` 10 to 21) and the stand-in content differ, the standard one wins, for example in health, the hurt cooldown, fall damage, day length and the stand-in blocks, items and mobs.
- **FR-042**: Every visual or gameplay value MUST come from `docs/protocol/` or `docs/design/`, never from a constant invented in code. Where a document has an Open question, the implementation MUST NOT guess; the question goes back to a clean-room round (constitution Principle II).
- **FR-043**: Lighting, sky, fog and clouds are out of scope (CC-0007); sounds are out of scope (README Part 7 decision 17).

### Key Entities

- **World type**: standard or cobolcraft; chosen at creation, recorded with the world, selects the content set while rules are shared.
- **Generated packs**: the vanilla resource pack and the vanilla data pack built from the user's jar; live in the game directory, never committed.
- **Pack stack**: the ordered list of enabled packs (built-in, generated, user, server) that decides which texture a path resolves to.
- **Resource pack (user)**: a zip in `resourcepacks/`, for example Faithful 32x; has an enabled flag and an order.
- **Crafting grid / recipe book**: the 2x2 inventory grid and 3x3 bench grid, a result slot, and the player's known recipes.
- **Break progress**: per-block, per-player stage from 0 to 9 shown as the crack overlay.
- **Option**: a named setting with a default and range, persisted across restarts.
- **Camera mode**: first person, third person back, third person front; not persisted.
- **Off-hand slot**: a single slot beside the hotbar, swappable with the main hand.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: With the Faithful 32x pack enabled, 100% of the blocks, items, mobs, GUI sprites, particles and text the pack covers are drawn from the pack with no missing-texture stripes, in a review of a defined checklist walk of the game.
- **SC-002**: In a fly-over and walk-through of terrain at three distances, no seams, shimmering or bleeding are visible between textures.
- **SC-003**: A Player can open the HUD, inventory, bench and menus at every supported GUI scale and the smallest supported window with no overlapping, clipped or misaligned elements, and a stack of 1 never shows a count.
- **SC-004**: In survival, 100% of double-Space attempts in 20 trials do not start flight, and no height beyond one jump is reached by repeated Space in the air; in creative, 20 of 20 double-Space attempts toggle flight.
- **SC-005**: A Player can craft a crafting bench from raw materials, place it, and make a large-grid recipe within one play session without leaving the game, using only the inventory and bench screens.
- **SC-006**: The crack overlay passes through every stage of the documented range on a block that takes at least one second to break, and is visible to a second connected player.
- **SC-007**: For a fixed seed, the standard overworld's terrain, caves and ore placement match the documents' worked examples and tests, with every listed ore found within its documented depth range.
- **SC-008**: Every command in `docs/protocol/16-commands-catalog.md` can be run by a Player of sufficient level and produces the documented result or message; each standard tool, weapon and mob has at least one passing behaviour test.
- **SC-009**: A changed option survives a restart in 100% of the options the Options screen lists.
- **SC-010**: Opening the pack folder shows `resourcepacks/` and a pack copied in appears in the list after one refresh, with no restart.
- **SC-011**: The cobolcraft world type is created, played and reopened with no jar and no generated packs present.
- **SC-012**: Running the extraction tool against the supported jar produces both packs, and the client and server load them with zero loader errors; no jar, pack or generated file appears in version control.
- **SC-013**: A reference vanilla client can pass configuration against a standard-type server in the scope the plan sets.

## Assumptions

- The adopted defaults of `docs/design/README.md` Part 7 are used unless the operator overrules them: world type stored with the world and defaulting to standard when the packs are valid (2); the cobolcraft starting kit stays only in the cobolcraft type (6); standard player chat in both types (7); standard permission levels 0 to 4 in `access.dat` (8); CobolCraft's world folder schemas kept, vanilla-loadable saves not a goal (9); generated packs in a git-ignored folder under the game directory, rebuilt when the jar's SHA-256 changes (11); missing-texture stripes kept (12); CobolCraft settings `hostile-mobs`, `weather-changes`, `extra-dimensions`, `player-combat` kept and mapped to the standard rules, view-distance default 8 (16).
- The vanilla-client validation scope is the planner's (CC-0001); this spec only requires that ids, registries and chunk encodings match vanilla for the standard type.
- The operator keeps the Faithful pack and the 26.3 jar in the git-ignored `tmp/` folder as inputs for clean-room rounds; neither is ever committed.
- Documents 10 to 47 are taken as complete for implementation, with their Open questions recorded in `docs/design/README.md` Part 8; the open ones that bear on this feature and are not decided here are: options screen texts (`builtin-ui-art.md` 13), sprite sizes and sheet regions not yet read, tooltip frame and recipe-book tabs and toasts, per-biome grass tint, entity geometry for the cobolcraft skin, save layout of 07 versus 33 (`world-types.md` 12), seed text hash (11), a vanilla client against a cobolcraft server (8), a single-player world opened to others (10), `TestInstanceBlockEditScreen` (`40-menus-9` Open question 1), sound event helpers (`46` Open question 14), unknown jar (22 Open question 1). Each is resolved by a clean-room round before any implementation that needs it, never guessed.
- A single-player world opened to others keeps the types and rules above; guests need valid packs for a standard world or see the missing-texture look.
- The cobolcraft type's content is unchanged except for the bench, the standard core and any other content this feature needs to work in that type (operator-confirmed); extending it to cover more of what the vanilla pack covers is future work.
- Sounds, lighting, sky, fog and clouds (CC-0007) and `server.properties` are out of scope.
- The feature is implemented as a whole in one run; the ticket is not split.
- A hidden third `WorldType`, `debug`, exists only as a test tool added by operator decision after planning (plan "Operator addition: debug world"): it is not a user story, it is not shown in the normal UI, and it is not part of the "two world types" of FR-003 to FR-005, which count only the standard and cobolcraft types.
