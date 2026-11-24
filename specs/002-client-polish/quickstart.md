# Quickstart: validating Client polish

**Feature**: `002-client-polish` | **Plan**: [plan.md](plan.md)

Runnable validation scenarios on the supported platform (macOS, Apple silicon). Commands are those of
[contracts/test-harness-delta.md](contracts/test-harness-delta.md) and the 001 harness; surfaces are
[contracts/extract-cli.md](contracts/extract-cli.md) and [contracts/client-surface-delta.md](contracts/client-surface-delta.md).
Section numbers name the user story they prove. Values to compare against are in the documents the stories cite.

## 0. Prerequisites and inputs

```sh
make bootstrap            # exit 0
ls tmp/minecraft-26.3-client.jar "tmp/Faithful 32x - 26.3.zip"     # the operator's git-ignored inputs
make                      # build/bin/cobolcraft, cobolcraft-server, cobolcraft-extract
```

## 1. Build the vanilla packs (US1, SC-012)

```sh
mkdir -p tmp/game && build/bin/cobolcraft-extract --jar tmp/minecraft-26.3-client.jar --game-dir tmp/game
build/bin/cobolcraft-extract --game-dir tmp/game              # second run: CCX-100, nothing rebuilt
build/bin/cobolcraft-extract --game-dir tmp/game --verify     # full integrity check, exit 0
build/bin/cobolcraft-extract --jar tmp/Faithful\ 32x\ -\ 26.3.zip --game-dir tmp/other   # CCX-030 or CCX-031, nothing written
git status --short | grep -E 'generated|\.jar|\.zip' ; echo $?   # expect no lines (exit 1): nothing to commit
```

Expected: counts of 22 §12 T5 (11,605 resource files, 9,779 data files, 106 feature files); `tmp/game/generated/`
holds `manifest.txt`, `vanilla-resources/`, `vanilla-data/`.

## 2. World types (US2, SC-011)

1. With `tmp/game/generated` valid: start `build/bin/cobolcraft --game-dir tmp/game`, New World: both types are
   offered, standard is the default. Create one of each; leave and reopen each: the same type opens.
2. Rename `tmp/game/generated` to `generated.off`: the title banner explains; New World still offers both,
   choosing standard and pressing Create shows the explanation of how to build the packs (FR-003); the cobolcraft
   type creates and plays. Reopening the standard world is refused with a reason (FR-004).
3. Standard rules in both types: 20 health, hit window, day length 24,000 ticks (shown by `/time query daytime`
   wrapping), crafting screens, ground items.

## 3. Faithful 32x and pack screen (US3, US4, US5, US6, SC-001, SC-002, SC-003, SC-010)

1. Resource Packs screen: press Open Pack Folder (Finder shows `tmp/game/resourcepacks/`, created if missing); copy
   `Faithful 32x - 26.3.zip` in; return: it is listed after one refresh without a restart (SC-010).
2. Enable it, move it up and down, restart: still enabled. Disable: the generated look returns.
3. Walk and fly over terrain at three distances: no seams, shimmer or bleeding (SC-002); animated blocks (water,
   lava, fire) animate; open HUD, inventory, bench, menus at each GUI scale and the smallest window: no overlap or
   clipping, stacks of 1 show no count (SC-003).
4. Checklist walk for SC-001: blocks, items, mobs, GUI sprites, particles, weather and text come from the pack;
   a cobolcraft-type world with the pack on keeps its own content (the optional skin is off by default, FR-006).

## 4. Controls and screens (US7 to US10, US16 to US20; SC-004 to SC-006, SC-009)

- Creative: double Space toggles flight 20 of 20 times; survival: 0 of 20; mash Space in the air: no rise above one
  jump (SC-004).
- Hold the break button on a block that takes over a second: the crack overlay passes stages 0 to 9 and the block
  breaks; release: it vanishes; a second client sees it (SC-006).
- Inventory: 2x2 grid, result slot, recipe book (known recipes, craftable marked, click fills the grid); craft a
  crafting bench (`cobolcraft:crafting_bench` in the cobolcraft type), place it, open it, make a 3x3 recipe (SC-005).
- Options (title screen and pause menu): change view distance, sensitivity, FOV, GUI scale and the rest of 13 §7;
  restart: all persisted (SC-009). F3 shows and hides the overlay; F5 cycles the views and draws the player model;
  F swaps the held item and a hovered slot's item with the off hand; the hand and its swing are drawn.

## 5. The standard world (US11, US12, SC-007)

Create a standard world with a fixed seed; run the worked examples and tests of documents 10 and 11 through the
core's acceptance tests (`make gate-core` runs them); explore terrain, caves and ores by hand; find trees,
vegetation and lakes, a structure, build a Nether portal and an End route, build a redstone circuit.

## 6. Commands, tools, mobs (US13 to US15, SC-008)

Run commands from `docs/protocol/16-commands-catalog.md` at levels 0 to 4 (a level-0 player is refused the
level-2 command); the per-command, per-tool and per-mob behaviour tests run in `make gate-core`.

## 7. Contributor gates (SC-012, constitution 5.4)

```sh
make gate-tables      # generated registry copybooks equal a fresh generation
make gate-core        # and gate-formats, gate-content, gate-extract, gate-proto, gate-shim, gate-server, gate-client
make gate             # terminal aggregate: lint + build + 100 % coverage
```

## 8. A cobolcraft world with nothing generated (SC-011)

Remove `generated/` and `resourcepacks/*`: create, play and reopen a cobolcraft world; every texture, glyph and
text is the built-in pack (22 T8).

## 9. Vanilla client (US21, SC-013; the manual half of research R10; runs once at the terminal phase)

Prerequisite: the operator's own Minecraft launcher with a 26.3 profile.

1. Start `build/bin/cobolcraft-server` in a directory with `world-type=standard` and the generated packs.
2. Connect the vanilla client in offline mode to `localhost`.
3. Expected: configuration completes (no registry, tag or known-packs error), the client enters play and renders
   the spawn chunks. Record the server console lines and the client's reached state in `specs/002-client-polish/vanilla-client-evidence.md`
   (written at run time with the real output). Against a cobolcraft-type server the client passes configuration
   only (04 §5).
