## Lane 002-lane-buglocate2 (T32700-T32899; /locate structure of a rare structure searched out to radius 100 and froze the game frame: a desert pyramid 34 s, a mansion 13 s, village_desert minutes, on the debug build)

CPU seconds of the real command `locate structure <id>` (C clock(), user + system of the process, `core/tests/test_cmd_locate_cost.cob` via `CC_COST_*`; serial; seed 424242 from the world spawn unless noted; debug build; machine load average 20 to 50 while measuring, noted per run in scratchpad/integ2/bl2-bench-*.log):

| want | before (bbfae6ae) | after the cell test (T32701) |
|---|---|---|
| #minecraft:village | 3.896 | 0.576 |
| minecraft:desert_pyramid | 13.454 | 2.845 |
| minecraft:mansion | 6.045 | 3.245 |
| minecraft:village_desert from (4100,-2700) | 94.910 | 3.420 |
| minecraft:stronghold | 0.814 | 0.780 |
| eye of ender (STRUCT-NEAREST-NAMED "strongholds") | 0.859 | 0.748 |

Every reply of the after run equals the before reply (same position and distance).

- [x] T32700 [buglocate2] Measurement program `core/tests/test_cmd_locate_cost.cob` (prints `COST ...` lines with the CPU seconds of the cell filter alone and of the command; the wants and spots come from CC_COST_WANT, CC_COST_SEED, CC_COST_X, CC_COST_Z; `eye` times the eye of ender's search; passes without them) and the findings of the baseline: the cell filter (STRUCT-POTENTIAL, STRUCT-IS-CHUNK over all 40401 cells) costs 0.4 to 0.8 s, so the time is in the start made for every cell that passes it (STRUCT-CHUNK-STARTS: entry order, STRUCT-FIND-POINT with the pieces built, the jigsaw assembly of a village that is not even the structure asked for)
- [x] T32701 [buglocate2] Cheap cell test: `CXC-STRUCT-CELL-HIT` (core/src/cmd-locate.cob) answers "is the start of the set in this structure chunk a wanted structure" from the validity of the entries only: `STRUCT-STUB-OK` (core/src/struct-place.cob: STRUCT-FIND-POINT with `SD-STUB-ONLY` 1 then STRUCT-VALID-AT) where the jigsaw assembly (JIG-ASSEMBLE returns after the stub biome), the scattered pieces (the stub biome before the four corner heights; no piece) and the mansion (no layout, no pieces) are skipped; the first wanted entry in the chooser's order that is valid is looked for first, the entries before it that are not wanted are asked only then (an entry of a wrong biome costs a height and a biome lookup). 36-1 sections 5.3 and 11: the start is the first valid entry, a locate hit is a chunk whose start is wanted, the stub biome is the only validity test beyond the generator's own
- [x] T32702 [buglocate2] Test `core/tests/test_cmd_locate_equiv.cob` (50 cases; red by mutation: with the entries-before-the-wanted check turned off the overlap case fails with 9 cells differing): the cell test equals the start list (STRUCT-CHUNK-STARTS, the slow path) in every cell of the ring walk from the spot to the answer ring for 15 runs (five seeds, a tag, the five village types, desert_pyramid, jungle_pyramid, swamp_hut, mansion, igloo, mineshaft, ruined portals, pillager outpost, shipwreck), the stub of every structure of the sets met equals STRUCT-FIND-POINT + STRUCT-VALID-AT, SD-STUB-ONLY is 0 afterwards, a village made in full after stub tests has pieces; and with the biomes of village_desert set to those of village_plains (data of the game has no overlapping entries) both orders of the chooser are met and equal
