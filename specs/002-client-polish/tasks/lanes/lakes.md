## Lane 002-lane-lakes (T16500+)

- [x] T16500 Test first: `core/tests/test_feat_35_5_lake.cob` cases "chunk border" (a pool that reaches the chunk border is placed, whole inside the chunk, no overflow entry) and real-data `core/tests/acc_lakes_standard.cob` (seed 12345, chunk (-2, -3) holds an underground lava lake, deterministic); both failed before the fix
- [x] T16501 `FR-LAKE` (core/src/feat-lake.cob): cells outside the chunk are not tested in the validity pass, not written in the fill pass and draw nothing in the barrier pass (the pool is cut at the chunk border; the neighbour's terrain is unknown); `docs/design/world-types.md` "Chunk borders" `lake_` row updated
