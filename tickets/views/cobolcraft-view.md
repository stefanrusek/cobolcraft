---
spile: view
project: CobolCraft
---

# CobolCraft view

> Generated, do not hand-edit. Built from the tickets in `tickets/` by `.claude/skills/spile/scripts/view.py`.

## Needs Attention

| ID | Title | Type | Owner | Blocked | PR |
|---|---|---|---|---|---|
| [CC-0001](../CC-0001-client-polish.md) | Client polish: visuals, controls and missing gameplay | feature | stefanrusek |  | 2 |
| [CC-0009](../CC-0009-block-placement-orientation-attachment.md) | Block placement honours orientation and attachment | bug | stefanrusek |  |  |
| [CC-0010](../CC-0010-swim-crawl-mining-target.md) | Mining, placing and attacking while swimming or crawling hit the block in front | bug | stefanrusek |  |  |
| [CC-0011](../CC-0011-stairs-fall-damage.md) | Walking down stairs or an incline fast deals no fall damage | bug | stefanrusek |  |  |
| [CC-0012](../CC-0012-farmland-trample.md) | Farmland turns to dirt when an entity lands on it | bug | stefanrusek |  |  |
| [CC-0013](../CC-0013-tree-flicker.md) | A tree does not flicker while the camera moves | bug | stefanrusek |  |  |
| [CC-0014](../CC-0014-goat-horn-in-hand.md) | A goat horn in the hand is raised to the mouth when used | bug | stefanrusek |  |  |
| [CC-0015](../CC-0015-player-model-scale.md) | Other players and the third-person figure have the vanilla height | bug | stefanrusek |  |  |
| [CC-0016](../CC-0016-item-icon-3d-shading.md) | 3D block icons in slots are shaded per face | bug | stefanrusek |  |  |
| [CC-0017](../CC-0017-use-item-in-air.md) | Boats, bows, shields and other held items start their use from the real window | bug | stefanrusek |  | --- |
| [CC-0018](../CC-0018-skyblock-world-stays-void.md) | A void world stays void around its saved island | bug | stefanrusek |  |  |
| [CC-0021](../CC-0021-block-and-fluid-fixes-on-lanes.md) | Block placement, update and fluid fixes saved on lanes reach the tree | bug | stefanrusek |  | --- |
| [CC-0022](../CC-0022-container-tool-and-ui-fixes-on-lanes.md) | Furnace, brush, recipe book and F3 fixes saved on lanes reach the tree | bug | stefanrusek |  | --- |
| [CC-0023](../CC-0023-superflat-spawn-rates.md) | Superflat worlds spawn slimes and hostile mobs at the standard rates | bug | stefanrusek |  | --- |
| [CC-0046](../CC-0046-older-play-test-reports-unverified.md) | Play-test reports of try8 to try11 are checked against a current build | bug | stefanrusek |  | --- |
| [CC-0047](../CC-0047-first-chunk-fill-step-within-tick-budget.md) | The first fill step of a freshly loaded chunk stays inside the per-tick step budget | bug | stefanrusek |  |  |
| [CC-0052](../CC-0052-mob-tick-within-tick-cpu-budget.md) | A mob tick stays inside the per-tick CPU budget however many chunks are loaded | bug | stefanrusek |  |  |

## Board

### draft

| ID | Title | Type | Owner | Blocked | PR |
|---|---|---|---|---|---|
| [CC-0002](../CC-0002-chunk-meshing-performance.md) | Chunk mesh building fast enough to play | feature | stefanrusek |  |  |
| [CC-0004](../CC-0004-shutdown-disconnect-delivery.md) | Players reliably see why the server shut down | bug | stefanrusek |  |  |
| [CC-0007](../CC-0007-lighting-sky-and-clouds.md) | Lighting, sky, fog and clouds | feature | stefanrusek |  |  |
| [CC-0019](../CC-0019-sleeping-on-the-client.md) | Sleeping in a bed works on the client and with villagers | feature | stefanrusek |  |  |
| [CC-0020](../CC-0020-ci-workflow.md) | Continuous integration builds and tests the packages that need no client jar | feature | stefanrusek |  |  |
| [CC-0024](../CC-0024-block-shapes-doc-51-round-4.md) | Block shapes follow doc 51 round 4: offset rule, scaffolding, shulker lid, light data, step-up | feature | stefanrusek |  |  |
| [CC-0025](../CC-0025-client-closures-doc-57-hud.md) | Chat, title, boss bar and scoreboard HUD, particle options and piglin crossbow pose | feature | stefanrusek |  |  |
| [CC-0026](../CC-0026-single-player-second-process.md) | The single-player world runs in a second process | feature | stefanrusek |  |  |
| [CC-0027](../CC-0027-jigsaw-memo-redesign.md) | A jigsaw structure start is not assembled again after an unrelated start | feature | stefanrusek |  |  |
| [CC-0028](../CC-0028-mob-travel-input.md) | Mob movement uses the travel input of the doc (zza and xxa) | feature | stefanrusek |  |  |
| [CC-0029](../CC-0029-piston-sculk-crafter-leftovers.md) | Pistons stick to honey, sculk occlusion and the shrieker work, and the redstone leftovers of lane p46h | feature | stefanrusek |  |  |
| [CC-0030](../CC-0030-lectern-and-written-books.md) | A lectern opens a window and holds a book with pages | feature | stefanrusek |  |  |
| [CC-0031](../CC-0031-scaffolding-stack-placement.md) | Placing scaffolding on scaffolding builds a column up to the limit | feature | stefanrusek |  |  |
| [CC-0032](../CC-0032-dispenser-leftovers.md) | Dispensers use shears and brushes and the remaining doc 30-4 behaviours | feature | stefanrusek |  |  |
| [CC-0033](../CC-0033-shim-depth-only-pipeline.md) | A depth-only pipeline gives the boat water patch and the painting back depth bias | feature | stefanrusek |  |  |
| [CC-0034](../CC-0034-glint-and-held-items-rest.md) | Compass and clock glint, fox and panda held items and the creeper swirl | feature | stefanrusek |  |  |
| [CC-0035](../CC-0035-player-appearance-cape-and-options.md) | Players show their cape, ears and elytra, and the skin options screen exists | feature | stefanrusek |  |  |
| [CC-0036](../CC-0036-doc-round-mobs-and-entities.md) | Reference docs state the mob and entity behaviour that code had to skip | feature | stefanrusek |  |  |
| [CC-0037](../CC-0037-doc-round-client-and-rendering.md) | Reference docs state the client rendering and HUD rules that code had to skip | feature | stefanrusek |  |  |
| [CC-0038](../CC-0038-doc-round-blocks-items-and-worldgen.md) | Reference docs settle the block, container, item and worldgen conflicts and gaps | feature | stefanrusek |  |  |
| [CC-0039](../CC-0039-wire-uncalled-mob-rule-libraries.md) | The built mob rule functions are called by the tick | feature | stefanrusek |  |  |
| [CC-0040](../CC-0040-mob-behaviour-long-tail.md) | The remaining mob behaviours of docs 44 and 19 to 21 are built | feature | stefanrusek |  |  |
| [CC-0041](../CC-0041-game-event-emitters.md) | Game events and vibrations are emitted by the actions that cause them | feature | stefanrusek |  |  |
| [CC-0042](../CC-0042-entity-persistence-leftovers.md) | Saved entities and players keep the values the docs list and act on them | feature | stefanrusek |  |  |
| [CC-0043](../CC-0043-structure-generation-leftovers.md) | Structure generation leftovers: mineshaft loot, test bookkeeping and the cut families | feature | stefanrusek |  |  |
| [CC-0044](../CC-0044-client-small-leftovers.md) | Small client leftovers: slot counts, sign editor, bed item, heads, slime bounce | feature | stefanrusek |  |  |
| [CC-0045](../CC-0045-polish-run-closing-inventory.md) | The open task lines of the polish run are decided: build, cut or keep as tickets | feature | stefanrusek |  |  |
| [CC-0048](../CC-0048-mob-tick-dimension-zero.md) | A standard world keeps running while its mobs move | bug | stefanrusek |  |  |
| [CC-0049](../CC-0049-standard-registry-data-for-clients-without-core-pack.md) | A standard world sends NBT Registry Data to a client without the core pack | bug | stefanrusek |  |  |
| [CC-0050](../CC-0050-real-player-skins.md) | A player's own skin is shown to the others | feature | stefanrusek |  |  |
| [CC-0051](../CC-0051-vanilla-client-actions-ignored.md) | The actions of a vanilla client that the server discards take effect | feature | stefanrusek |  |  |
| [CC-0053](../CC-0053-other-players-see-held-items-and-armour.md) | Other players see what a player holds and wears at all times | bug | stefanrusek |  |  |
| [CC-0057](../CC-0057-entity-and-hook-pushes.md) | Crowding entities, boats, minecarts and fishing hooks push the Player | feature | stefanrusek |  |  |
| [CC-0058](../CC-0058-auto-jump-option.md) | The Auto-Jump option makes the Player jump up obstacles | feature | stefanrusek |  |  |
| [CC-0059](../CC-0059-spectator-passes-through-blocks.md) | A spectator flies through blocks | bug | stefanrusek |  |  |
| [CC-0060](../CC-0060-movement-and-fall-sources-outside-003.md) | Weapons, commands and teleports change movement and fall damage as in Minecraft | feature | stefanrusek |  |  |
| [CC-0061](../CC-0061-client-ticks-at-low-frame-rate.md) | The Player moves at full speed when the frame rate is low | bug | stefanrusek |  |  |
| [CC-0062](../CC-0062-non-player-pushes-by-moving-blocks.md) | Mobs, items and other entities are moved by pistons, shulker boxes and growing blocks as in Minecraft | bug | stefanrusek |  |  |
| [CC-0063](../CC-0063-moving-piston-blocks-drawn.md) | The Player sees pistons and the blocks they push move | feature | stefanrusek |  |  |
| [CC-0065](../CC-0065-blocks-that-grow-taller.md) | Farmland, paths, mud, snow and sculk change into taller blocks as in Minecraft | bug | stefanrusek |  |  |

### unverified

| ID | Title | Type | Owner | Blocked | PR |
|---|---|---|---|---|---|
| [CC-0001](../CC-0001-client-polish.md) | Client polish: visuals, controls and missing gameplay | feature | stefanrusek |  | 2 |
| [CC-0009](../CC-0009-block-placement-orientation-attachment.md) | Block placement honours orientation and attachment | bug | stefanrusek |  |  |
| [CC-0010](../CC-0010-swim-crawl-mining-target.md) | Mining, placing and attacking while swimming or crawling hit the block in front | bug | stefanrusek |  |  |
| [CC-0011](../CC-0011-stairs-fall-damage.md) | Walking down stairs or an incline fast deals no fall damage | bug | stefanrusek |  |  |
| [CC-0012](../CC-0012-farmland-trample.md) | Farmland turns to dirt when an entity lands on it | bug | stefanrusek |  |  |
| [CC-0013](../CC-0013-tree-flicker.md) | A tree does not flicker while the camera moves | bug | stefanrusek |  |  |
| [CC-0014](../CC-0014-goat-horn-in-hand.md) | A goat horn in the hand is raised to the mouth when used | bug | stefanrusek |  |  |
| [CC-0015](../CC-0015-player-model-scale.md) | Other players and the third-person figure have the vanilla height | bug | stefanrusek |  |  |
| [CC-0016](../CC-0016-item-icon-3d-shading.md) | 3D block icons in slots are shaded per face | bug | stefanrusek |  |  |
| [CC-0017](../CC-0017-use-item-in-air.md) | Boats, bows, shields and other held items start their use from the real window | bug | stefanrusek |  | --- |
| [CC-0018](../CC-0018-skyblock-world-stays-void.md) | A void world stays void around its saved island | bug | stefanrusek |  |  |
| [CC-0021](../CC-0021-block-and-fluid-fixes-on-lanes.md) | Block placement, update and fluid fixes saved on lanes reach the tree | bug | stefanrusek |  | --- |
| [CC-0022](../CC-0022-container-tool-and-ui-fixes-on-lanes.md) | Furnace, brush, recipe book and F3 fixes saved on lanes reach the tree | bug | stefanrusek |  | --- |
| [CC-0023](../CC-0023-superflat-spawn-rates.md) | Superflat worlds spawn slimes and hostile mobs at the standard rates | bug | stefanrusek |  | --- |
| [CC-0046](../CC-0046-older-play-test-reports-unverified.md) | Play-test reports of try8 to try11 are checked against a current build | bug | stefanrusek |  | --- |
| [CC-0047](../CC-0047-first-chunk-fill-step-within-tick-budget.md) | The first fill step of a freshly loaded chunk stays inside the per-tick step budget | bug | stefanrusek |  |  |
| [CC-0052](../CC-0052-mob-tick-within-tick-cpu-budget.md) | A mob tick stays inside the per-tick CPU budget however many chunks are loaded | bug | stefanrusek |  |  |

## Recently Closed

| ID | Title | Resolution |
|---|---|---|
| [CC-0008](../CC-0008-gravity-blocks-fall.md) | Gravity blocks fall when the block beneath them is broken | done |
| [CC-0006](../CC-0006-creative-cursor-throws.md) | A creative player's carried stack can be thrown out of the inventory window | done |
| [CC-0005](../CC-0005-tests-free-port.md) | Server tests do not depend on port 25565 being free | done |
| [CC-0003](../CC-0003-weather-atlas-size.md) | Weather atlas stays small with any pack image sizes | done |
