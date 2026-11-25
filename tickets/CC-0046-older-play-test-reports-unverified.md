---
spile: ticket
id: CC-0046
type: bug
status: unverified
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0009]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
  pr:
---

# CC-0046: Play-test reports of try8 to try11 are checked against a current build

## Summary

The operator's play-test reports from builds try8 to try11 (from 2026-11-16) were queued as next-run work. Many were
handled by lanes since; each is checked on a current build and either closed or turned into its own bug ticket.

## User Stories

### As a Player, I want the problems I reported to be fixed or answered

- Given each report below, when it is tried on a current build, then it is confirmed fixed (with the lane or commit),
  or it becomes a bug ticket with the corrected behaviour.

## Functional Requirements

- FR-001: Nothing here is assumed fixed or broken: each item is verified in the game, or by a test through the real
  path, before anything is written.

## Open Questions

- try8: a torch under a falling gravel block is deleted and the user expected the gravel to break it; gravel above a
  placed torch did not place (CC-0009 and the falling-block landing rules).
- try8: no sulfur cubes spawned in a sulfur cave under spawn on seed 4 (T2504 unchecked).
- try9: leaf_litter had no texture (later reported correct); spiders and zombies spawn in daylight in a well-lit
  forest; /locate structure village and stronghold found nothing.
- try10: villager arm and leg skins upside down; spawn-egg villagers never take a profession; trading dialog does not
  open; /execute run tp into the nether does nothing; hostile mobs appear at once in a new world; STDMOB-AGGRO reads
  raw stored light (T6803); pink_petals, glow_lichen and other decals z-fight with the block they sit on; leaf_litter
  and pink_petals should stack in one block.
- try10 performance profile (release build): about 110 s on Loading terrain, ENTITY-MODEL-EMIT 53 percent of the main
  thread in play, WORLD-FIND 15, M182-ENV-TICK 7; a profiling pass with symbols comes first. Unreproduced: /locate or
  an eye of ender before the main process has generated a chunk may use an un-initialised generator state.
- try11: villagers render without profession clothing; a dirt_path in front of a door stops the player (door collision
  against the 1/16 drop); the later lanes bugvillage, buglocate, doorpath, villlook, bugvlag and bugleaves handled
  parts of these.
- Idea (operator, 2026-11-17): extend the hidden debug world (docs/design/debug-world.md says no mobs and nothing
  ticks) with a frozen mob area of every type and variant, a redstone gallery, and the vanilla test blocks as a place
  for automated checks, as new hidden world types or regions of the debug world.

## State at the end of the polish run (2026-11-23)

- Source: scratchpad/next-run-bugs.md of the orchestrating session (git-ignored, not in the repository); the items
  above are copied from it without re-testing.

## Verdicts (bug wave, 2026-11-25, agent C round 2)

Every item was checked on the merged tip of 003-play-test-bugs by a test through the real code path (no game window was launched). The proving tests below
were run on that tip: core `passed 431 failed 0` (16 programs, with CC_GENERATED_DIR set), client `passed 88 failed 0` (5 programs). Convergence tests
were not run by this agent (the orchestrator runs them at the end of the wave); they are named where they are part of the evidence. What a headless test
cannot show (shader and texture appearance) is marked "look: operator".

| Report | Verdict | Evidence |
|---|---|---|
| try8 torch under falling gravel is deleted, gravel should break instead | confirmed fixed | 958845ec: a falling block lands only in a replaceable cell (a torch is not), the block is discarded and its item drops, the torch stays. `core/tests/test_falling_block_standard.cob` cases 1, 5 and 6 (sand onto a standing torch, an anvil onto a wall torch, a wall torch on a falling sand block pops with its item), run green. |
| try8 gravel placed directly above a torch did not place | not reproduced, regression test added | New `core/tests/acc_gravel_on_torch.cob` (real Use Item On packet on the top of a standing torch in survival): gravel is placed in the cell above, one item is used up, it rests there after 60 ticks and the torch stays (4 of 4, green on the first run: the placement path was already right; related fixes 4040d7a5, 958845ec, 2c6f0049). |
| try8 no sulfur cubes in a sulfur cave | confirmed working, regression test added | New `core/tests/acc_sulfur_natural_spawn.cob` drives the real pack spawner (MS6-PACK with the sulfur_caves list, rule code 17, placement and cost checks, MOB-SPAWN): cubes spawn by day, in groups of 2 to 4, none within 24 blocks of the player, plains spawns none (6 of 6; with the biome swapped for plains the two spawn cases fail, so the test discriminates). The natural spawn chooses the biome of the 4 x 4 x 4 cell of the spawn cell (MS6-BIOME-AT), so cave cells count. T2504 is ticked (`test_mob_20_18_2`). Not shown: that seed 4 generates a sulfur cave with an open air pocket near the spawn (a play check). |
| try9 leaf_litter without texture | no action | The ticket itself records it as reported correct later (try10); the decal quads and the stacking were reworked by lane decals (63d1527a). look: operator |
| try9/try10 spiders, zombies and creepers in daylight in a lit forest; hostile mobs at once in a new world | confirmed fixed | `core/tests/test_mob_18_6_light.cob` (no hostile pack by day under open sky, with grass in the cell or under a leaf canopy; none within 24 blocks of the world spawn; still spawns in a cave and at night), `test_mob_18_6_spread.cob` (sky light spreads sideways: nothing spawns under eaves by day), `acc_bugvillage_spawns.cob` (village census by day and night), run green. Commits ed91ebb1, spawnfix lane. Open and out of scope here: the stand-in sky light policy (T30205, the L32 engine is not wired). |
| try9 `/locate structure village` and `stronghold` found nothing | confirmed fixed | buglocate lanes: `core/tests/test_cmd_locate_gen.cob` (real command on standard worlds of five seeds: the village tag, the five villages, mineshaft, ruined portals, outpost, igloo are found and equal the first start of the search) and `test_cmd_locate_names.cob`, run green; stronghold ring search fixed in `STRUCT-NEAREST-RING` (T32501, T32502); the plain name `village` (T43401) in `tests/convergence/acc_buglocate3_names.cob` (convergence, not run here). |
| try10 villager arm and leg skins upside down | confirmed fixed, villager case added | 1995d133 (mirrored cuboids keep each corner's texel). `client/tests/test_entity_uv.cob` now also checks the villager (flat parts like the hat rim are skipped): red with that fix taken out (cuboids 8, 11, 19, 22 = the mirrored arm and leg and their layer copies, as are the zombie, skeleton, golem and enderman), green with it (6 of 6). look: operator |
| try10 spawn-egg villagers never take a profession | confirmed fixed | Lane villagers (T12100, 4c061f04): the POI index and the claim walk. A spawn egg ends in `MOB-SPAWN` (`MS6-EGG-SPAWN`), the call `core/tests/acc_us15_villager_job_chain.cob` spawns its villagers with; a composter placed next to one makes it a farmer through CORE-TICK only (run green). No separate egg test. |
| try10 trading dialog does not open (villager, wandering trader) | confirmed fixed | Lane villagers T12101, T12102: the client never sent Interact (0x1A). `client/tests/acc_us15_villager_interact.cob` (right click sends Interact), `core/tests/acc_us15_merchant_interact.cob`, `acc_us15_wandering_trader.cob`; later bugtrade, bugnighttrade, bugtradestop lanes (`acc_bugtrade_village`, `acc_bugnighttrade_interact`), run green. |
| try10 `/execute ... run tp` into the nether does nothing | confirmed fixed | Lane cmdfix: `core/tests/test_cmd_execute_in_dim.cob` (`execute in minecraft:the_nether run tp @s ...`, bare ids, relative coordinates, `as @a`, the Respawn packet of the dimension change), run green; the single-player host sets CS-EXTRA-DIMENSIONS (client/src/sp-host.cob); the client replica swap is in `tests/convergence/acc_f2us12_dimensions.cob` (`execute in minecraft:overworld run tp`, convergence, not run here). |
| try10 STDMOB-AGGRO reads raw stored light (T6803) | confirmed fixed | T16000 (a8c5c713): the spider's neutrality reads `LIGHT-RAW`, and `LIGHT-SKY-SPREAD` under eaves (T30201). `core/tests/test_stdmob_spider.cob` (under glass, under the eaves) run green. |
| try10 pink_petals, glow_lichen and other decals z-fight | confirmed fixed (headless part) | Lane decals: `client/tests/test_decal_faces.cob` (the two quads of one flat element are 0.004 apart, each toward its own side), run green. The picture on the GPU cannot be checked headless: look: operator |
| try10 leaf_litter and pink_petals should stack in one block | confirmed fixed | Lane decals: `core/tests/acc_segment_stack.cob` (each use on the same block adds one segment, 1 to 4, the 5th does nothing, through the real Use Item On), run green. |
| try11 villagers render without profession clothing | confirmed fixed (headless part) | Lane villlook: the core sends VILLAGER_DATA (`core/tests/test_villager_look.cob`, `test_villager_data_once.cob`), the client gives a new villager the default look (`client/tests/test_entity_overlays.cob` "spawned without data"), run green. The layers' look: operator |
| try11 dirt_path in front of a door stops the player | confirmed fixed | Lane doorpath (T6900): the step-up under a lintel. `client/tests/test_physics_doorpath.cob` (stone and dirt_path floors, door open and closed), run green. |
| try10 performance profile (release build) | untouched | Skipped by the brief (needs a profiling pass with symbols on a quiet machine). The unreproduced question (locate or eye of ender before the main process generated a chunk) was not reproduced either: buglocate3 T43400 (`test_eye_real`, new and reloaded world) found the core correct. |
| Idea: extend the hidden debug world | untouched | Skipped by the brief; needs a design doc update and a decision on hidden world types. |

No new bug ticket was needed: nothing was found broken. The three tests were pushed with 80cec10e. Coverage: no production
code changed, so cover-changed does not apply; lint of the three touched test files is clean and `gen_tables.py --check` reports 0 differing files.
