---
spile: ticket
id: CC-0018
type: bug
status: unverified
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
---

# CC-0018: A void world stays void around its saved island

## Summary

A world whose level data declares a flat-void, mod or noise generator keeps its empty chunks empty and is not
rewritten with generated terrain; the core uses the generator the world declares for chunks missing from the region
files.

## User Stories

### As a Player, I want my skyblock world to stay a skyblock

- Given a world with one saved island and a void generator declared in world_gen_settings.dat, when I join and play
  for a while, then no chunk other than the saved island holds non-air blocks and the world files hold no generated
  terrain.

## Functional Requirements

- FR-001: The world type is decided from level data and world_gen_settings.dat (docs/protocol 25 and 35 flat settings,
  38 dimension types): an unknown or custom generator gives void chunks, never the standard generator.

## Notes

> [!NOTE]
> Operator report (try19, 2026-11-19): my skyblock world bugged out and started generating chunks.

## Root cause and fix (bug wave, 2026-11-25)

- Root cause, core: `WORLD-TYPE-DECIDE` (core/src/api.cob) turned every level.dat of a real 26.3 game (compound Data, no
  WorldType) into a `standard` world, so a skyblock world whose `data/minecraft/world_gen_settings.dat` declares a flat void
  preset, a generator of a mod or another noise settings id got the noise generator for every chunk missing from the region
  files: terrain grew around the saved island and the autosave wrote it. No shim or client part.
- Fix (core): new program `LEVEL-PEEK-GENERATOR` (core/src/level-data.cob) reads the overworld stem of
  world_gen_settings.dat (docs/protocol 07 section 10.4.5, 56 sections 2.5 and 5.1): `minecraft:flat` gives a superflat
  world, `minecraft:debug` the debug world, `minecraft:noise` with the `minecraft:` settings id the standard world, a
  generator type this core cannot make (a mod's type, noise with settings of another namespace or written out as a
  compound) gives a superflat world with `FS-FALLBACK` 1, whose chunks are the void preset (core/src/flat-settings.cob,
  the file is kept as the game wrote it for a 26.3 layout). No file, an unreadable file, no dimensions map or a generator
  without a type keep the standard world as before. Files: core/src/api.cob, core/src/level-data.cob,
  core/src/flat-settings.cob, core/copy/FLATSET.cpy (FS-FALLBACK).
- Red first: core/tests/acc_skyblock_void.cob with the fixtures core/tests/fixtures/skyblock-* (generator
  core/tests/fixtures/gen_skyblock.py) failed 15 of 18 cases before the fix (the type decided standard for flat, mod and noise
  worlds; 274 solid blocks in the nine chunks around the island for the flat, modgen and modnoise worlds, before and after
  reopening), green 19 of 19 after (a noise-with-compound-settings case was added for coverage of the compound branch).
- Checks: `CC_GENERATED_DIR=.../scratchpad/integ2/gen JOBS=3 python3 tools/runtests.py --build build --jobs 2 --only
  acc_skyblock_void core` passed 19 failed 0; `make cover-changed SINCE=origin/003-play-test-bugs ONLY=acc_skyblock_void`
  0 uncovered changed lines; `make -C core lint` 0 failed; `gen_tables.py --check` clean.
- Not verified: the operator's own world (folder Banclam's Dappled Skyblock World under /tmp/cc-test/saves) now holds no
  files (level.dat, region files and data are gone, sizes 0), so what it declared could not be read; the fix is proven on
  synthetic worlds with the key set of a real modded 26.3 level.dat. The operator verifies by playing the world.
- Doc gap (recorded, not guessed): the docs do not say what a custom or unknown generator must do for chunks missing from
  the region files; the lane chose void chunks (an empty world around what is saved), which is the behaviour the ticket
  asks for.
