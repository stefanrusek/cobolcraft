*> Test of the Nether's structure definitions (core/src/nether-37-6c.cob; T1705; docs/protocol/37-nether-6 section 3): the common settings of the four instances (step, terrain adaptation, spawn
*> overrides), the stub position of each structure (3.0), the fortress start and the vertical shift rule (3.1), the bastion's jigsaw fields and Y_SIZE (3.2), the ruined portal setup (3.3) and
*> the fossil height (3.4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-6-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-S                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-EXPECT              BINARY-DOUBLE SIGNED.
 01 WS-CASE                PIC X(200).
 01 WS-N                   PIC -(8)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM COMMON-CASES
     PERFORM STUB-CASES
     PERFORM FORTRESS-CASES
     PERFORM BASTION-CASES
     PERFORM PORTAL-CASES
     PERFORM FOSSIL-CASES
     GOBACK.

 CHECK-V.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§3 Structure definitions: fields, defaults and the four Nether instances: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 DEF-CASE.
     CALL "NETHER-STRUCTURE-DEF" USING WS-S WS-CODE WS-V
     PERFORM CHECK-V.

 COMMON-CASES.
*>   codes: 1 step (1 underground_decoration, 2 surface_structures), 2 terrain adaptation (0 none, 1 beard_thin), 3 spawn override entries, 4 override box (1 piece, 0 none)
     MOVE 1 TO WS-CODE
     MOVE 1 TO WS-S
     MOVE 1 TO WS-EXPECT
     MOVE "fortress step is underground_decoration" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 2 TO WS-S
     MOVE 2 TO WS-EXPECT
     MOVE "bastion_remnant step is surface_structures" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 3 TO WS-S
     MOVE "ruined_portal_nether step is surface_structures" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 4 TO WS-S
     MOVE 1 TO WS-EXPECT
     MOVE "nether_fossil step is underground_decoration" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 2 TO WS-CODE
     MOVE 0 TO WS-EXPECT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
         MOVE "terrain adaptation is none (the default) for the fortress, bastion and ruined portal" TO WS-CASE
         PERFORM DEF-CASE
     END-PERFORM
     MOVE 4 TO WS-S
     MOVE 1 TO WS-EXPECT
     MOVE "nether_fossil terrain adaptation is beard_thin" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 3 TO WS-CODE
     MOVE 1 TO WS-S
     MOVE 5 TO WS-EXPECT
     MOVE "fortress has five monster spawn override entries" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 4 TO WS-CODE
     MOVE 1 TO WS-EXPECT
     MOVE "fortress override bounding box is piece" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 0 TO WS-EXPECT
     PERFORM VARYING WS-S FROM 2 BY 1 UNTIL WS-S > 4
         MOVE 3 TO WS-CODE
         MOVE "the other three structures have empty spawn overrides (no entries)" TO WS-CASE
         PERFORM DEF-CASE
         MOVE 4 TO WS-CODE
         MOVE "the other three structures have no override bounding box" TO WS-CASE
         PERFORM DEF-CASE
     END-PERFORM
     MOVE 99 TO WS-CODE
     MOVE 1 TO WS-S
     MOVE -1 TO WS-EXPECT
     MOVE "an unknown field code gives -1" TO WS-CASE
     PERFORM DEF-CASE.

 STUB-CASES.
*>   USING structure, x1, z1 (chunk min, or box min), x2, z2 (box max), y (given), stub out
     MOVE 1 TO WS-S
     MOVE 32 TO WS-X1
     MOVE -48 TO WS-Z1
     MOVE 0 TO WS-X2 WS-Z2
     MOVE 99 TO WS-Y
     CALL "NETHER-STUB" USING WS-S WS-X1 WS-Z1 WS-X2 WS-Z2 WS-Y WS-SX WS-SY WS-SZ
     COMPUTE WS-V = WS-SX * 1000000 + WS-SY * 1000 + WS-SZ + 100000
     MOVE "fortress stub is (chunk min x, 64, chunk min z): (32, 64, -48)" TO WS-CASE
     COMPUTE WS-EXPECT = 32 * 1000000 + 64 * 1000 - 48 + 100000
     PERFORM CHECK-V
     MOVE 2 TO WS-S
     MOVE -40 TO WS-X1
     MOVE -9 TO WS-Z1
     MOVE 25 TO WS-X2
     MOVE 40 TO WS-Z2
     CALL "NETHER-STUB" USING WS-S WS-X1 WS-Z1 WS-X2 WS-Z2 WS-Y WS-SX WS-SY WS-SZ
     MOVE WS-SX TO WS-V
     MOVE -7 TO WS-EXPECT
     MOVE "bastion stub x is (maxX + minX) / 2 in integer division: (25 - 40) / 2 = -7 (truncated toward zero)" TO WS-CASE
     PERFORM CHECK-V
     MOVE WS-SZ TO WS-V
     MOVE 15 TO WS-EXPECT
     MOVE "bastion stub z is (maxZ + minZ) / 2: (40 - 9) / 2 = 15" TO WS-CASE
     PERFORM CHECK-V
     MOVE WS-SY TO WS-V
     MOVE 33 TO WS-EXPECT
     MOVE "bastion stub y is the sampled start height 33" TO WS-CASE
     PERFORM CHECK-V
     MOVE 3 TO WS-S
     MOVE 16 TO WS-X1
     MOVE 64 TO WS-Z1
     MOVE 29 TO WS-Y
     CALL "NETHER-STUB" USING WS-S WS-X1 WS-Z1 WS-X2 WS-Z2 WS-Y WS-SX WS-SY WS-SZ
     COMPUTE WS-V = WS-SX * 1000000 + WS-SY * 1000 + WS-SZ
     MOVE "ruined portal stub is (chunk min x, the final y, chunk min z): (16, 29, 64)" TO WS-CASE
     COMPUTE WS-EXPECT = 16 * 1000000 + 29 * 1000 + 64
     PERFORM CHECK-V
     MOVE 4 TO WS-S
     MOVE 5 TO WS-X1
     MOVE 7 TO WS-Z1
     MOVE 61 TO WS-Y
     CALL "NETHER-STUB" USING WS-S WS-X1 WS-Z1 WS-X2 WS-Z2 WS-Y WS-SX WS-SY WS-SZ
     COMPUTE WS-V = WS-SX * 1000000 + WS-SY * 1000 + WS-SZ
     MOVE "fossil stub is (the drawn x, the found y, the drawn z): (5, 61, 7)" TO WS-CASE
     COMPUTE WS-EXPECT = 5 * 1000000 + 61 * 1000 + 7
     PERFORM CHECK-V
     MOVE 9 TO WS-S
     CALL "NETHER-STUB" USING WS-S WS-X1 WS-Z1 WS-X2 WS-Z2 WS-Y WS-SX WS-SY WS-SZ
     MOVE WS-SY TO WS-V
     MOVE -1 TO WS-EXPECT
     MOVE "an unknown structure has no stub (y -1)" TO WS-CASE
     PERFORM CHECK-V
*>   the biome of a stub is read at QuartPos.fromBlock (floor division by 4)
     MOVE 64 TO WS-A
     CALL "NETHER-QUART" USING WS-A WS-V
     MOVE 16 TO WS-EXPECT
     MOVE "QuartPos.fromBlock(64) = 16" TO WS-CASE
     PERFORM CHECK-V
     MOVE -1 TO WS-A
     CALL "NETHER-QUART" USING WS-A WS-V
     MOVE -1 TO WS-EXPECT
     MOVE "QuartPos.fromBlock(-1) = -1 (floor)" TO WS-CASE
     PERFORM CHECK-V
     MOVE 33 TO WS-A
     CALL "NETHER-QUART" USING WS-A WS-V
     MOVE 8 TO WS-EXPECT
     MOVE "QuartPos.fromBlock(33) = 8: the bastion's y 33 and the fortress's 64 are different quart rows (8, 16)" TO WS-CASE
     PERFORM CHECK-V.

 FORTRESS-CASES.
*>   USING y span, draw, draw needed out, new minimum y out: room = 23 - span; the new minimum is 48 + nextInt(room) when room > 1, else 48 with no draw
     MOVE 10 TO WS-A
     MOVE 5 TO WS-B
     CALL "NETHER-FORTRESS-SHIFT" USING WS-A WS-B WS-C WS-D
     MOVE WS-C TO WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "span 10: room 13 > 1, a draw is needed" TO WS-CASE
     PERFORM CHECK-V
     MOVE WS-D TO WS-V
     MOVE 53 TO WS-EXPECT
     MOVE "span 10, draw 5: the new minimum y is 48 + 5 = 53" TO WS-CASE
     PERFORM CHECK-V
     MOVE 21 TO WS-A
     CALL "NETHER-FORTRESS-SHIFT" USING WS-A WS-B WS-C WS-D
     MOVE WS-C TO WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "span 21: room 2 > 1, a draw is needed" TO WS-CASE
     PERFORM CHECK-V
     MOVE 22 TO WS-A
     CALL "NETHER-FORTRESS-SHIFT" USING WS-A WS-B WS-C WS-D
     MOVE WS-C TO WS-V
     MOVE 0 TO WS-EXPECT
     MOVE "span 22: room 1, no draw" TO WS-CASE
     PERFORM CHECK-V
     MOVE WS-D TO WS-V
     MOVE 48 TO WS-EXPECT
     MOVE "span 22: the new minimum y is 48" TO WS-CASE
     PERFORM CHECK-V
     MOVE 30 TO WS-A
     CALL "NETHER-FORTRESS-SHIFT" USING WS-A WS-B WS-C WS-D
     MOVE WS-D TO WS-V
     MOVE 48 TO WS-EXPECT
     MOVE "span 30: room negative, the new minimum y is 48" TO WS-CASE
     PERFORM CHECK-V
*>   the shift of each piece is the new minimum less the box minimum
     MOVE 64 TO WS-A
     MOVE 53 TO WS-B
     CALL "NETHER-FORTRESS-MOVE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-V
     MOVE -11 TO WS-EXPECT
     MOVE "a union box with minimum y 64 moved to 53 moves every piece by -11" TO WS-CASE
     PERFORM CHECK-V.

 BASTION-CASES.
*>   codes: 5 size, 6 start height, 7 max distance horizontal, 8 vertical, 9 use_expansion_hack, 10 project_start_to_heightmap present, 11 pool aliases, 12 dimension padding
     MOVE 2 TO WS-S
     MOVE 5 TO WS-CODE
     MOVE 6 TO WS-EXPECT
     MOVE "bastion size is 6" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 6 TO WS-CODE
     MOVE 33 TO WS-EXPECT
     MOVE "bastion start_height is absolute 33" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 7 TO WS-CODE
     MOVE 80 TO WS-EXPECT
     MOVE "bastion max_distance_from_center horizontal is 80" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 8 TO WS-CODE
     MOVE 4064 TO WS-EXPECT
     MOVE "bastion vertical reach is Y_SIZE 4064" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 0 TO WS-EXPECT
     PERFORM VARYING WS-CODE FROM 9 BY 1 UNTIL WS-CODE > 12
         MOVE "use_expansion_hack false, no heightmap projection, no pool aliases, zero dimension padding" TO WS-CASE
         PERFORM DEF-CASE
     END-PERFORM
     MOVE 13 TO WS-CODE
     MOVE 1 TO WS-EXPECT
     MOVE "bastion liquid settings are apply_waterlogging (1)" TO WS-CASE
     PERFORM DEF-CASE
*>   Y_SIZE from BITS_FOR_Y: PACKED_HORIZONTAL_LENGTH = 1 + log2(33554432) = 26, PACKED_Y_LENGTH = 64 - 52 = 12, Y_SIZE = 4096 - 32, MAX_Y = 2031, MIN_Y = -2032
     MOVE 1 TO WS-CODE
     CALL "NETHER-Y-SIZE" USING WS-CODE WS-V
     MOVE 26 TO WS-EXPECT
     MOVE "PACKED_HORIZONTAL_LENGTH is 1 + log2(smallestEncompassingPowerOfTwo(30000000)) = 26" TO WS-CASE
     PERFORM CHECK-V
     MOVE 2 TO WS-CODE
     CALL "NETHER-Y-SIZE" USING WS-CODE WS-V
     MOVE 12 TO WS-EXPECT
     MOVE "PACKED_Y_LENGTH is 64 - 2 * 26 = 12" TO WS-CASE
     PERFORM CHECK-V
     MOVE 3 TO WS-CODE
     CALL "NETHER-Y-SIZE" USING WS-CODE WS-V
     MOVE 4064 TO WS-EXPECT
     MOVE "Y_SIZE is (1 << 12) - 32 = 4064" TO WS-CASE
     PERFORM CHECK-V
     MOVE 4 TO WS-CODE
     CALL "NETHER-Y-SIZE" USING WS-CODE WS-V
     MOVE 2031 TO WS-EXPECT
     MOVE "MAX_Y is (Y_SIZE >> 1) - 1 = 2031" TO WS-CASE
     PERFORM CHECK-V
     MOVE 5 TO WS-CODE
     CALL "NETHER-Y-SIZE" USING WS-CODE WS-V
     MOVE -2032 TO WS-EXPECT
     MOVE "MIN_Y is MAX_Y - Y_SIZE + 1 = -2032" TO WS-CASE
     PERFORM CHECK-V
     MOVE 9 TO WS-CODE
     CALL "NETHER-Y-SIZE" USING WS-CODE WS-V
     MOVE -1 TO WS-EXPECT
     MOVE "an unknown Y_SIZE code gives -1" TO WS-CASE
     PERFORM CHECK-V
*>   the codec rejects a horizontal reach above 128 (and below 1)
     MOVE 80 TO WS-A
     CALL "NETHER-JIGSAW-RANGE" USING WS-A WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "horizontal reach 80 is accepted" TO WS-CASE
     PERFORM CHECK-V
     MOVE 128 TO WS-A
     CALL "NETHER-JIGSAW-RANGE" USING WS-A WS-V
     MOVE "horizontal reach 128 is accepted" TO WS-CASE
     PERFORM CHECK-V
     MOVE 129 TO WS-A
     CALL "NETHER-JIGSAW-RANGE" USING WS-A WS-V
     MOVE 0 TO WS-EXPECT
     MOVE "horizontal reach 129 is rejected (MAX_TOTAL_STRUCTURE_RANGE)" TO WS-CASE
     PERFORM CHECK-V
     MOVE 0 TO WS-A
     CALL "NETHER-JIGSAW-RANGE" USING WS-A WS-V
     MOVE "horizontal reach 0 is rejected (the range is 1 to 128)" TO WS-CASE
     PERFORM CHECK-V.

 PORTAL-CASES.
*>   codes: 14 setup count, 15 placement (6 in_nether in the order on_land_surface, partly_buried, on_ocean_floor, in_mountain, underground, in_nether), 16 air pocket probability x100,
*>   17 mossiness x100, 18 overgrown, 19 vines, 20 can_be_cold, 21 replace_with_blackstone, 22 weight x100
     MOVE 3 TO WS-S
     MOVE 14 TO WS-CODE
     MOVE 1 TO WS-EXPECT
     MOVE "the Nether ruined portal has exactly one setup" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 15 TO WS-CODE
     MOVE 6 TO WS-EXPECT
     MOVE "its placement is in_nether" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 0 TO WS-EXPECT
     PERFORM VARYING WS-CODE FROM 16 BY 1 UNTIL WS-CODE > 20
         MOVE "air pocket probability 0.0, mossiness 0.0, not overgrown, no vines, cannot be cold" TO WS-CASE
         PERFORM DEF-CASE
     END-PERFORM
     MOVE 21 TO WS-CODE
     MOVE 1 TO WS-EXPECT
     MOVE "replace_with_blackstone is true" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 22 TO WS-CODE
     MOVE 100 TO WS-EXPECT
     MOVE "setup weight is 1.0" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 1 TO WS-S
     MOVE 14 TO WS-CODE
     MOVE -1 TO WS-EXPECT
     MOVE "the fortress has no ruined portal setup (-1)" TO WS-CASE
     PERFORM DEF-CASE.

 FOSSIL-CASES.
*>   codes: 23 height minimum y (absolute 32), 24 below_top offset (2), 25 the height provider is uniform (1)
     MOVE 4 TO WS-S
     MOVE 23 TO WS-CODE
     MOVE 32 TO WS-EXPECT
     MOVE "fossil height starts at absolute 32" TO WS-CASE
     PERFORM DEF-CASE
     MOVE 24 TO WS-CODE
     MOVE 2 TO WS-EXPECT
     MOVE "fossil height ends at below_top 2" TO WS-CASE
     PERFORM DEF-CASE
*>   USING level min y, generator min y, level height, generator gen depth, offset, resolved y out
     MOVE 0 TO WS-A WS-B
     MOVE 256 TO WS-C
     MOVE 128 TO WS-D
     MOVE 2 TO WS-E
     CALL "NETHER-BELOW-TOP" USING WS-A WS-B WS-C WS-D WS-E WS-V
     MOVE 125 TO WS-EXPECT
     MOVE "below_top 2 in the Nether is 0 + 128 - 1 - 2 = 125" TO WS-CASE
     PERFORM CHECK-V
     MOVE -64 TO WS-A
     MOVE 0 TO WS-B
     MOVE 384 TO WS-C
     MOVE 128 TO WS-D
     CALL "NETHER-BELOW-TOP" USING WS-A WS-B WS-C WS-D WS-E WS-V
     MOVE "minGenY is the larger of the level's and the generator's minimum, genDepth the smaller height: still 125" TO WS-CASE
     PERFORM CHECK-V
     MOVE 0 TO WS-A
     MOVE -64 TO WS-B
     MOVE 64 TO WS-C
     MOVE 128 TO WS-D
     CALL "NETHER-BELOW-TOP" USING WS-A WS-B WS-C WS-D WS-E WS-V
     MOVE 61 TO WS-EXPECT
     MOVE "a level of height 64 limits genDepth to 64: 0 + 64 - 1 - 2 = 61" TO WS-CASE
     PERFORM CHECK-V.
 END PROGRAM TEST-NETHER-37-6-3.
