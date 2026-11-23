*> Acceptance test (wrap agent B, T40210; docs/protocol/29-block-updates-and-placement.md section 9.6): the entities that set blocksBuilding obstruct a block placement. BLOCK-OVERLAPS-BODY (the
*> check of BLOCK-PLACE) is asked about a stone block in a cell that holds the box of one entity: a boat or raft (any wood, with or without a chest), a minecart of any kind, an end crystal, a
*> primed TNT, a falling block and an armor stand obstruct (UI-BLOCKS-BUILDING classes 2 to 7); a ground item, an area effect cloud and a boat in the next cell do not. The standard world of the
*> generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-PLACE-ENTITIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-place-entities-world".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG VALUE 101.
 01 WS-Z                   BINARY-LONG VALUE 5.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-BARE                PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXP-N               BINARY-DOUBLE SIGNED.
 01 WS-OBS-N               BINARY-DOUBLE SIGNED.
 01 WS-EX                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb place entities: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "stone" TO WS-K
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     MOVE 1 TO WS-EXP-N
     MOVE "oak_boat" TO WS-K PERFORM CHECK-KEY
     MOVE "bamboo_raft" TO WS-K PERFORM CHECK-KEY
     MOVE "oak_chest_boat" TO WS-K PERFORM CHECK-KEY
     MOVE "bamboo_chest_raft" TO WS-K PERFORM CHECK-KEY
     MOVE "minecart" TO WS-K PERFORM CHECK-KEY
     MOVE "chest_minecart" TO WS-K PERFORM CHECK-KEY
     MOVE "tnt_minecart" TO WS-K PERFORM CHECK-KEY
     MOVE "end_crystal" TO WS-K PERFORM CHECK-KEY
     MOVE "tnt" TO WS-K PERFORM CHECK-KEY
     MOVE "falling_block" TO WS-K PERFORM CHECK-KEY
     MOVE "armor_stand" TO WS-K PERFORM CHECK-KEY
     MOVE 0 TO WS-EXP-N
     MOVE "item" TO WS-K PERFORM CHECK-KEY
     MOVE "area_effect_cloud" TO WS-K PERFORM CHECK-KEY
*>   a boat in the next cell does not meet the cell (its box is 1.375 wide: x 6.0 to 7.375 at x 6.6875 is outside the cell 5)
     MOVE 8.5 TO WS-EX
     MOVE "oak_boat" TO WS-K PERFORM CHECK-KEY-AT
     STOP RUN.

 CHECK-KEY.
     MOVE 5.5 TO WS-EX
     PERFORM CHECK-KEY-AT.

 CHECK-KEY-AT.
*>   the entity type of the bare key WS-K at x WS-EX, y 101, z 5.5: does BLOCK-OVERLAPS-BODY say stone in cell (5, 101, 5) is obstructed (WS-EXP-N 1 or 0)?
     MOVE 0 TO WS-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ET-COUNT
         CALL "KEY-BARE" USING ET-KEY(WS-I) WS-BARE
         IF WS-BARE = WS-K
             COMPUTE WS-TYPE = WS-I - 1
         END-IF
     END-PERFORM
     MOVE WS-TYPE TO WS-OBS-N
     IF WS-OBS-N > 0
         MOVE 1 TO WS-OBS-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-CASE
     STRING "acceptance wrapb place 29 9.6 the entity type " FUNCTION TRIM(WS-K) " exists" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-ALLOC" USING WS-ROW
     MOVE WS-TYPE TO EN-TYPE(WS-ROW)
     MOVE WS-DIM TO EN-DIM(WS-ROW)
     MOVE WS-EX TO EN-X(WS-ROW)
     MOVE 101.0 TO EN-Y(WS-ROW)
     MOVE 5.5 TO EN-Z(WS-ROW)
     CALL "BLOCK-OVERLAPS-BODY" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-HIT
     MOVE 0 TO EN-USED(WS-ROW)
     MOVE WS-HIT TO WS-OBS-N
     MOVE WS-EXP-N TO TL-EXPECTED-N
     MOVE SPACES TO WS-CASE
     IF WS-EXP-N = 1
         STRING "acceptance wrapb place 29 9.6 " FUNCTION TRIM(WS-K) " obstructs a block placed in its cell" DELIMITED BY SIZE INTO WS-CASE
     ELSE
         STRING "acceptance wrapb place 29 9.6 " FUNCTION TRIM(WS-K) " does not obstruct a block placed in the cell" DELIMITED BY SIZE INTO WS-CASE
     END-IF
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-WRAPB-PLACE-ENTITIES.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
