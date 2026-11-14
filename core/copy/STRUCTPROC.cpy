*> The compiled structure processor lists (core/src/struct-proc-load.cob compiles worldgen/processor_list elements, docs/protocol/36-structures-2 sections 7 to 9; core/src/struct-proc.cob
*> runs them). EXTERNAL, core-private. A list (SPL) has its processors in SP-PROC rows SPL-FIRST on, SPL-N of them; SPL-STATUS 1 compiled, 2 absent or unsupported (the loader gives index 0 for it).
*> A processor (SPP) has a type (the SPP-T constants) and parameters:
*>   1 rule                 SPP-A first rule row (SP-RULE), SPP-N number of rules
*>   2 protected_blocks     SPP-POOL, SPP-N: a block set (pool entries are 1-based block numbers of CORE-BLOCKS)
*>   3 block_rot            SPP-F integrity (float32), SPP-A 1 when rottable_blocks is given (then the set SPP-POOL, SPP-N)
*>   4 capped               SPP-A the delegate row, SPP-B to SPP-E the int provider (type 1 constant a, 2 uniform a..b, 3 biased_to_bottom a..b, 4 very_biased_to_bottom a..b, 5 trapezoid min a max b plateau c)
*>   5 gravity              SPP-A heightmap ordinal of FL-HEIGHT-OF (0 WORLD_SURFACE_WG, 1 WORLD_SURFACE, 2 OCEAN_FLOOR_WG, 3 OCEAN_FLOOR, 4 MOTION_BLOCKING, 5 MOTION_BLOCKING_NO_LEAVES), SPP-B offset
*>   8 nop
*>   9 block_ignore         SPP-POOL, SPP-N the blocks
*>   10 blackstone_replace
*>   11 block_age           SPP-F mossiness (float32); the pool holds the tags stairs, slabs, walls: SPP-POOL the first entry, SPP-A, SPP-B, SPP-C their sizes
*> jigsaw_replacement (6) and lava_submerged_block (7) are not compiled: the list that holds one is unsupported (the template cache keeps no block entity tag and the block tables carry no collision shapes).
*> A rule (SPR): the tests SPR-IN, SPR-LOC, SPR-POS (SP-TEST rows; 0 for always true), the output state SPR-STATE, the block entity modifier SPR-MOD (0 passthrough, 1 clear, 2 append_static, 3 append_loot), SPR-LOOT the loot table key of an append_loot.
*> A test (SPT): SPT-TYPE 1 always_true, 2 block_match (SPT-A the block number), 3 blockstate_match (SPT-A the state), 4 tag_match (SPT-POOL, SPT-N), 5 random_block_match (SPT-A block, SPT-F
*> probability float32), 6 random_blockstate_match (SPT-A state, SPT-F), 7 height_match (SPT-B min, SPT-C max), 8 all_of, 9 any_of, 10 not (children from SPT-CHILD along SPT-NEXT); position tests: 21 always_true,
*> 22 linear_pos, 23 axis_aligned_linear_pos (SPT-F min_chance, SPT-F2 max_chance float32, SPT-B min_dist, SPT-C max_dist, SPT-D the axis 0 x, 1 y, 2 z).
 78 SP-MAX-LISTS         VALUE 64.
 78 SP-MAX-PROCS         VALUE 1024.
 78 SP-MAX-RULES         VALUE 2048.
 78 SP-MAX-TESTS         VALUE 4096.
 78 SP-MAX-POOL          VALUE 32768.
 01 STRUCT-PROC EXTERNAL.
    05 SP-LIST-COUNT        BINARY-LONG.
    05 SP-PROC-COUNT        BINARY-LONG.
    05 SP-RULE-COUNT        BINARY-LONG.
    05 SP-TEST-COUNT        BINARY-LONG.
    05 SP-POOL-COUNT        BINARY-LONG.
    05 SP-BAD               BINARY-LONG.
    05 SP-LIST OCCURS 64 TIMES.
       10 SPL-KEY           PIC X(80).
       10 SPL-STATUS        BINARY-LONG.
       10 SPL-FIRST         BINARY-LONG.
       10 SPL-N             BINARY-LONG.
    05 SP-PROC OCCURS 1024 TIMES.
       10 SPP-TYPE          BINARY-LONG.
       10 SPP-A             BINARY-LONG.
       10 SPP-B             BINARY-LONG.
       10 SPP-C             BINARY-LONG.
       10 SPP-D             BINARY-LONG.
       10 SPP-E             BINARY-LONG.
       10 SPP-POOL          BINARY-LONG.
       10 SPP-N             BINARY-LONG.
       10 SPP-F             FLOAT-SHORT.
    05 SP-RULE OCCURS 2048 TIMES.
       10 SPR-IN            BINARY-LONG.
       10 SPR-LOC           BINARY-LONG.
       10 SPR-POS           BINARY-LONG.
       10 SPR-STATE         BINARY-LONG.
       10 SPR-MOD           BINARY-LONG.
       10 SPR-LOOT          PIC X(48).
    05 SP-TEST OCCURS 4096 TIMES.
       10 SPT-TYPE          BINARY-LONG.
       10 SPT-A             BINARY-LONG.
       10 SPT-B             BINARY-LONG.
       10 SPT-C             BINARY-LONG.
       10 SPT-D             BINARY-LONG.
       10 SPT-POOL          BINARY-LONG.
       10 SPT-N             BINARY-LONG.
       10 SPT-CHILD         BINARY-LONG.
       10 SPT-NEXT          BINARY-LONG.
       10 SPT-F             FLOAT-SHORT.
       10 SPT-F2            FLOAT-SHORT.
    05 SP-POOL              BINARY-LONG OCCURS 32768 TIMES.
