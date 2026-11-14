# Contract: client surface additions (`client` <-> Player, Pack creator)

**Status**: frozen at plan time; amends `specs/001-cobolcraft-complete/contracts/client-surface.md`. This is the
Player's vantage; the values are the documents named.

| Surface | Contract |
|---|---|
| Controls | Double Space toggles flight only where the server's abilities allow it (13 §1.4); F3 toggles the overlay (13 §5); F5 cycles the camera (13 §6, 12 §7); F swaps main hand and off hand, and a hovered slot with the off hand in the inventory screen (13 §4); E, number keys, Q, Shift and the other defaults of 13 §7.3; the C key crafting screen is removed (FR-028). Key codes: `CCSHIM.cpy`. |
| Screens | Title, world list, create-world (type choice, FR-003 refusal text), pause, options (FR-022), resource packs (FR-008 with Open Pack Folder), inventory (46 slots, 2x2 grid, recipe book), crafting bench (3x3), HUD with off-hand slot and counts from 2 up (FR-014), death, chat, and every container screen of 40. Layout, sprite names, nine-slice rules and texts: 12 §5, `builtin-ui-art.md`. |
| Options file | `options.txt` in the game directory, the format of 13 §7.1, every option listed on the Options screen persisted (SC-009); missing, unreadable or out-of-range -> defaults. |
| Resource packs | The pack stack of 22 §8.1; `resourcepacks/` listing and refresh; enable, disable, reorder persisted; a pack error is shown on the screen and never fatal. |
| Banners and messages | The texts of `cobolcraft.packs.*` and `cobolcraft.world_type.*` (22 §9.2, world-types.md §8, `builtin-ui-art.md` §7.2) from the built-in language. |
| Command line | `--game-dir`, `--name`, the 001 arguments, plus `--generated-dir` (22 §5.1). |

**Contract tests.** Surface-level checks are `acc_` tests on the screen model and render list (001 data-model §13),
plus `contract_client_surface.cob` asserting the documented key to action table and the `options.txt` round trip
against `contract/fixtures/client/options-*.txt`.
