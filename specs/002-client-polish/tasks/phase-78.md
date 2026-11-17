## Phase 78: Vanilla world format (lane vanfmt, operator request: open a real 26.3 save and save it back without loss)

- [x] T3790 [P] Round SAVEFMT, reader: the vanilla 26.3 world folder as the game writes it (`level.dat` `Data`, saved-data files, player files, dimension folders, poi, load and round-trip rules), written as `docs/protocol/07-nbt-and-anvil.md` §10
- [x] T3791 Round SAVEFMT, reviewer (two rounds): contamination, completeness and accuracy review of 07 §10
- [x] T3792 [US12-core] Write test `core/tests/test_state_props_wide.cob` (block property text is not cut at 64 characters; every standard state round-trips through its property text) and widen the property buffers to 160
- [x] T3793 [US12-core] Write tests `core/tests/test_chunk_biomes.cob` and `test_chunk_biomes_real.cob`; save the chunk's own biome cells and read them back (07 §7.2 widths)
- [x] T3794 [US12-core] Write test `core/tests/test_save_keys_real.cob`; item and entity ids of the player file and of ground items are stored with `minecraft:` and read whole, bare or namespaced
- [x] T3795 [US12-core] Write test `core/tests/acc_vanfmt_save.cob` with fixture `core/tests/fixtures/gen_vanfmt.py`; implement `core/src/level-vanilla.cob`: a 26.3 world is read from and saved to `level.dat` `Data` (unmodelled keys kept, `level.dat_old`), `weather.dat`, `world_clocks.dat` and `game_rules.dat`
- [x] T3796 [US12-core] Write test `core/tests/test_player_dat_vanilla.cob`; player files of a 26.3 world are `players/data/<uuid>.dat` (the old place is still read)
- [x] T3797 [US12-core] Write test `core/tests/test_chunk_merge.cob`; a chunk saved in a 26.3 world keeps the keys the core does not model
- [x] T3798 [US12-core] Write test `core/tests/test_entity_merge.cob`; entities of types the core does not know are kept when an `entities/` chunk is saved in a 26.3 world (07 §10.6, §10.7; the keys of known entities that the core does not model are still lost, see T3801)
- [x] T3799 [US12-core] Block entities of types the core does not know are kept when a chunk is saved (test_chunk_merge.cob); `poi/` regions are neither read nor written, so the files stay as they are
- [x] T3801 [US12-core] Keep the keys of known entities and known block entities that the core does not model across a save (`core/src/extras.cob`, tests `test_entity_merge`, `test_be_extras_real`); poi sections of saved chunks are marked not valid (`core/src/poi.cob`, `test_poi_invalidate`) so the game rescans them. Not done: writing poi records from the blocks
- [x] T3800 Gate: run `make gate-core` and record the command and real output. Recorded at 9563b74: exit 0, `passed 6327 failed 0`, `coverage: 169 objects, 0 uncovered lines`. After the merges of genthread and fluids and the later lane work: `passed 6416 failed 0`, 3 uncovered lines in `growth-29b-1b.cob` (a random-dependent test, fixed by seeding the level random in `acc_us12_growth_crops`, coverage of those lines re-checked with a targeted coverage run); a final full `make gate-core` is left to the integrator
- [x] T3802 [US12-core] New standard worlds are created in the 26.3 layout (`acc_vanfmt_new_world`); `test_real_vanilla_roundtrip` (needs `CC_REAL_SAVE`) opens, saves and reopens a real 26.3 snapshot save
### Block shapes (operator feedback: hit boxes)

- [x] T4500 [US7-docs] docs/protocol/51-block-shapes.md: per-state collision and outline shapes consolidated from the registry documents (24 parts 1 to 8, 29, 30, 31), rules by class and property; open questions listed
- [x] T4501 [US7-content] contract/copy/CTBSHAPE.cpy, content/src/block-shapes.cob (BSH-BUILD and the queries BSH-COLL-ID, BSH-OUT-ID, BSH-OVERLAPS, BSH-CLIP, BSH-RAY), content/copy/CTBSDATA.cpy rule rows; test_block_shapes first observed red (the builder absent)
- [x] T4502 [US7-client] Player collision by collision shape: PHYS-SOLID, PHYS-COLLIDES, PHYS-MOVE through the shape tables, step-up 0.6 (slabs, stairs), ground check on slab tops; tests first
- [x] T4503 [US7-client] Targeting by outline shape: RAYCAST tests the boxes of the cell's outline, so torches, buttons, ladders, slabs and stairs are targeted where they are; tests first
- [x] T4504 [US7-core] Server movement check by collision shape: MOVE-COLLIDES, MOVE-SUPPORTED, MOVE-CLIMBING agree with the client; BLOCKS-OPEN builds the shape tables; tests first
- [ ] T4506 [US7-client] Shapes not yet in the tables (51 open questions and rule rows still to add): cauldron, hopper, bell, scaffolding, piston and head, chest joins, bed legs, skull variants, shulker box, offset plants (outline drawn without the XZ offset), stem width; mobs and ground items still read CB-SOLID (full cubes)
- [ ] T4505 [US7-docs] Open questions of 51 (offset plants, tall plants, hopper, cauldron, bell, scaffolding, shulker box, piston, chest joins, bed legs, skull variants): clean-room round when the operator reports a block that is still wrong

---
