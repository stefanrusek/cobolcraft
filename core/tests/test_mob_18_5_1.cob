*> Implementation test (002-lane-mobsfull-h2, T2236; docs/protocol/18 section 5.1 Path types and the malus table): the PathType malus table and its overrides, block to path type, static type, neighbour types and the mob aware type of a footprint.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-5-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBPATH.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-D                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-J                 BINARY-LONG.
 01 WS-K                 BINARY-LONG.
 01 WS-L                 BINARY-LONG.
 01 WS-M                 BINARY-LONG.
 01 WS-N                 BINARY-LONG.
 01 WS-O                 BINARY-LONG.
 01 WS-P                 BINARY-LONG.
 01 WS-O1                BINARY-LONG.
 01 WS-O2                BINARY-LONG.
 01 WS-O3                BINARY-LONG.
 01 WS-O4                BINARY-LONG.
 01 WS-O5                BINARY-LONG.
 01 WS-O6                BINARY-LONG.
 01 WS-O7                BINARY-LONG.
 01 WS-O8                BINARY-LONG.
 01 WS-F1                FLOAT-LONG.
 01 WS-F2                FLOAT-LONG.
 01 WS-F3                FLOAT-LONG.
 01 WS-F4                FLOAT-LONG.
 01 WS-F5                FLOAT-LONG.
 01 WS-F6                FLOAT-LONG.
 01 WS-F7                FLOAT-LONG.
 01 WS-F8                FLOAT-LONG.
 01 WS-G1                FLOAT-LONG.
 01 WS-G2                FLOAT-LONG.
 01 WS-G3                FLOAT-LONG.
 01 WS-G4                FLOAT-LONG.
 01 WS-T                 PIC X(80).
 01 WS-U                 PIC X(80).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 0 BLOCKED is -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 1 OPEN is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 2 WALKABLE is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 3 WALKABLE_DOOR is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 4 TRAPDOOR is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 5 POWDER_SNOW is -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 6 ON_TOP_OF_POWDER_SNOW is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 7 FENCE is -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 8 LAVA is -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 9 WATER is 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 10 WATER_BORDER is 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 11 RAIL is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 12 UNPASSABLE_RAIL is -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 13 FIRE_IN_NEIGHBOR is 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 14 FIRE is 16" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 16 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 15 DAMAGING_IN_NEIGHBOR is 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 16 DAMAGING is -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 17 DOOR_OPEN is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 18 DOOR_WOOD_CLOSED is -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 19 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 19 DOOR_IRON_CLOSED is -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 20 BREACH is 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 21 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 21 LEAVES is -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 22 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 22 STICKY_HONEY is 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 23 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 23 COCOA is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 24 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 24 DAMAGE_CAUTIOUS is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 25 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 25 ON_TOP_OF_TRAPDOOR is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 26 TO WS-A
     CALL "PATH-MALUS-DEFAULT" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table default malus of 26 BIG_MOBS_CLOSE_TO_DANGER is 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table a mob without an override uses the default (WATER 8)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     MOVE 0 TO WS-B
     CALL "PATH-MALUS-SET" USING PF-MALUS-TABLE WS-A WS-B
     MOVE "acceptance US15 18§5.1 Path types and the malus table setPathfindingMalus overrides one type" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PF-MALUS-VAL(10)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table getPathfindingMalus returns the override" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-A
     CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-A WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table an override does not touch other types" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE -1 TO WS-B
     CALL "PATH-MALUS-SET" USING PF-MALUS-TABLE WS-A WS-B
     MOVE "acceptance US15 18§5.1 Path types and the malus table an override can be negative" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PF-MALUS-VAL(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "air" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind air is path type 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "trapdoor" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind trapdoor is path type 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "lily_pad" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind lily_pad is path type 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "big_dripleaf" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind big_dripleaf is path type 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "powder_snow" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind powder_snow is path type 5" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cactus" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind cactus is path type 16" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 16 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sweet_berry_bush" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind sweet_berry_bush is path type 16" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 16 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "honey" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind honey is path type 22" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 22 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cocoa" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind cocoa is path type 23" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 23 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wither_rose" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind wither_rose is path type 24" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 24 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "speleothem" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind speleothem is path type 24" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 24 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "lava" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind lava is path type 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fire" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind fire is path type 14" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 14 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "door_open" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind door_open is path type 17" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 17 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "door_wood_closed" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind door_wood_closed is path type 18" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 18 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "door_iron_closed" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind door_iron_closed is path type 19" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 19 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "rail" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind rail is path type 11" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "leaves" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind leaves is path type 21" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 21 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fence" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind fence is path type 7" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 7 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wall" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind wall is path type 7" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 7 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fence_gate" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind fence_gate is path type 7" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 7 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "water" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind water is path type 9" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "solid" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind solid is path type 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "other" TO WS-T
     CALL "BLOCK-PATH-TYPE" USING WS-T WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table block kind other is path type 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 9 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 9 is 9" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 8 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 8 is 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 14 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 14 is 14" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 14 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 16 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 16 is 16" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 16 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 22 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 22 is 22" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 22 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 5 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 5 is 6" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 24 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 24 is 24" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 24 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 4 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 4 is 25" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 25 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 0 is 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 2 is 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 1 is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     MOVE 0 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 9 above 0 is 9" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 0 above 0 is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 21 TO WS-B
     CALL "STATIC-PATH-TYPE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table static type: feet 1 above 21 is 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 2, damaging 0 fire 0 water 0 cautious 0 gives 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 2, damaging 1 fire 0 water 0 cautious 0 gives 15" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 15 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 2, damaging 0 fire 1 water 0 cautious 0 gives 13" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 13 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 2, damaging 0 fire 0 water 1 cautious 0 gives 10" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 2, damaging 0 fire 0 water 0 cautious 1 gives 24" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 24 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 2, damaging 1 fire 1 water 1 cautious 1 gives 15" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 15 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 2, damaging 0 fire 1 water 1 cautious 0 gives 13" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 13 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 2, damaging 0 fire 0 water 1 cautious 1 gives 10" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 1, damaging 1 fire 1 water 1 cautious 1 gives 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NEIGHBOUR-ADJUST" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table neighbour check: type 0, damaging 1 fire 0 water 0 cautious 0 gives 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM RESET-MALUS
     MOVE 1 TO PT-COUNT
     MOVE 9 TO PT-TYPE(1)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table mob type of a one-type footprint is that type" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PT-COUNT
     MOVE 2 TO PT-TYPE(1)
     MOVE 7 TO PT-TYPE(2)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table mob type with a fence in the footprint is FENCE" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 7 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PT-COUNT
     MOVE 1 TO PT-TYPE(1)
     MOVE 12 TO PT-TYPE(2)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table mob type with an unpassable rail is UNPASSABLE_RAIL" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 12 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PT-COUNT
     MOVE 2 TO PT-TYPE(1)
     MOVE 8 TO PT-TYPE(2)
     MOVE 9 TO PT-TYPE(3)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table mob type returns the first type with a negative malus at once" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PT-COUNT
     MOVE 2 TO PT-TYPE(1)
     MOVE 9 TO PT-TYPE(2)
     MOVE 17 TO PT-TYPE(3)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table mob type is the type with the highest malus" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PT-COUNT
     MOVE 9 TO PT-TYPE(1)
     MOVE 10 TO PT-TYPE(2)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table mob type ties go to the later type" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PT-COUNT
     MOVE 2 TO PT-TYPE(1)
     MOVE 10 TO PT-TYPE(2)
     MOVE 2 TO WS-A
     MOVE 2 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table a wide mob near danger gets BIG_MOBS_CLOSE_TO_DANGER" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 26 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PT-COUNT
     MOVE 1 TO PT-TYPE(1)
     MOVE 2 TO PT-TYPE(2)
     MOVE 1 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table a width 1 mob in open air with a free neighbour type stays OPEN" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PT-COUNT
     MOVE 1 TO PT-TYPE(1)
     MOVE 2 TO PT-TYPE(2)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table a width 1 mob standing on walkable ground keeps WALKABLE" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PT-COUNT
     MOVE 2 TO PT-TYPE(1)
     MOVE 10 TO PT-TYPE(2)
     MOVE 1 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table a width 1 mob next to water keeps the water border type" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 26 TO WS-A
     MOVE 10 TO WS-B
     CALL "PATH-MALUS-SET" USING PF-MALUS-TABLE WS-A WS-B
     MOVE "acceptance US15 18§5.1 Path types and the malus table BIG_MOBS malus override equal to the max does not apply" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PF-MALUS-VAL(27)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PT-COUNT
     MOVE 2 TO PT-TYPE(1)
     MOVE 10 TO PT-TYPE(2)
     MOVE 2 TO WS-A
     MOVE 2 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table so a wide mob keeps the result type" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PT-COUNT
     MOVE 2 TO PT-TYPE(1)
     MOVE 10 TO PT-TYPE(2)
     MOVE 10 TO WS-A
     MOVE 2 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table a wide mob whose origin malus is not below the max keeps the result" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     MOVE -1 TO WS-B
     CALL "PATH-MALUS-SET" USING PF-MALUS-TABLE WS-A WS-B
     MOVE "acceptance US15 18§5.1 Path types and the malus table a WATER malus override of -1 makes water the first negative type" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PF-MALUS-VAL(10)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PT-COUNT
     MOVE 2 TO PT-TYPE(1)
     MOVE 9 TO PT-TYPE(2)
     MOVE 17 TO PT-TYPE(3)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-F1
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE PF-TYPESET WS-A WS-F1 WS-O1
     MOVE "acceptance US15 18§5.1 Path types and the malus table so a footprint with water returns WATER" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 RESET-MALUS.
     INITIALIZE PF-MALUS-TABLE.
 END PROGRAM TEST-MOB-18-5-1.
