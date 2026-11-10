*> Test of block drops from loot tables (core/src/block-drops.cob; docs/protocol/26-loot-and-predicates.md section 11.1 and 11.2, 5.1): the table of a
*> block is blocks/<name> of its namespace (cobolcraft:blocks/turf for cobolcraft:turf), rolled with the table's random sequence
*> (the world seed 12345 here) and spawned at (x + 0.5, y + 0.25, z + 0.5) as ground items through GI-SPAWN; a block with no
*> table reports found 0 and spawns nothing (the caller keeps the stand-in yield). The tool of the context is the stack given (an
*> empty hand is item 0, count 0); an explosion radius makes survives_explosion and explosion_decay draw (11.2). The expected
*> counts come from an independent Python implementation of the Xoroshiro128++ sequence of 26 section 4 (10 2.3, MD5 seed of 10 2.4)
*> and of the rules of the sections: turf rolled 8 times under radius 2.0 (survives_explosion, then four explosion_decay draws)
*> keeps 3, 0, 0, 0, 1, 2, 3, 2 loam; greystone with an efficiency-3 tool (the stand-in for Fortune) 4, 3, 3 dump shards.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-DROPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY CSTACK.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot-blocks".
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 7.
 01 WS-Y                   BINARY-LONG VALUE 64.
 01 WS-Z                   BINARY-LONG VALUE 9.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(64) VALUE SPACES.
 01 WS-STATE               BINARY-LONG.
 01 WS-TOOL                BINARY-LONG.
 01 WS-TOOL-COUNT          BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-RADIUS-SET          BINARY-LONG.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 0.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-TEXT                PIC X(300).
 01 WS-BLOCK-ROW           BINARY-LONG.
 01 WS-SAVED-KEY           PIC X(48).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-R1                  PIC -(6)9.99.
 01 WS-R2                  PIC -(6)9.99.
 01 WS-R3                  PIC -(6)9.99.
 01 WS-EXPECTED-TURF.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC 9 VALUE 0.
    05 FILLER              PIC 9 VALUE 0.
    05 FILLER              PIC 9 VALUE 0.
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC 9 VALUE 2.
 01 WS-TURF-TABLE REDEFINES WS-EXPECTED-TURF.
    05 WS-TURF-COUNT       PIC 9 OCCURS 8 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 12345 TO CW-SEED
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "test block drops the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM CHECK-NUM

     MOVE "cobolcraft:turf" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE 0 TO WS-TOOL WS-TOOL-COUNT WS-HANDLE WS-RADIUS-SET
     MOVE 0 TO WS-RADIUS
     PERFORM SPAWN
     MOVE "test block drops a block with a table drops its loot at (x + 0.5, y + 0.25, z + 0.5): turf, no explosion, 4 loam" TO TL-CASE
     MOVE "3x4@7.50,64.25,9.50" TO TL-EXPECTED
     PERFORM CHECK-DROPS
     MOVE "test block drops a block with a table reports found 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK-NUM

     MOVE 1 TO WS-RADIUS-SET
     MOVE 2.0 TO WS-RADIUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         PERFORM SPAWN
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-EDIT
         STRING "test block drops explosion radius 2.0 roll " FUNCTION TRIM(WS-EDIT)
             " keeps the survivors of survives_explosion and explosion_decay" DELIMITED BY SIZE INTO TL-CASE
         IF WS-TURF-COUNT(WS-I) = 0
             MOVE "-" TO TL-EXPECTED
         ELSE
             MOVE WS-TURF-COUNT(WS-I) TO WS-EDIT
             MOVE SPACES TO TL-EXPECTED
             STRING "3x" FUNCTION TRIM(WS-EDIT) "@7.50,64.25,9.50" DELIMITED BY SIZE INTO TL-EXPECTED
         END-IF
         PERFORM CHECK-DROPS
     END-PERFORM

     MOVE "cobolcraft:loam" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE 0 TO WS-RADIUS-SET
     PERFORM SPAWN
     MOVE "test block drops a block with no table spawns nothing and reports found 0" TO TL-CASE
     MOVE "-" TO TL-EXPECTED
     PERFORM CHECK-DROPS
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     MOVE "test block drops a block with no table reports found 0" TO TL-CASE
     PERFORM CHECK-NUM

     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     PERFORM SPAWN
     MOVE "test block drops greystone with an empty hand: ore_drops without a level draws nothing, one dump shard" TO TL-CASE
     MOVE "15x1@7.50,64.25,9.50" TO TL-EXPECTED
     PERFORM CHECK-DROPS

     MOVE "cobolcraft:pry_bar" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TOOL WS-ROW WS-STATUS
     MOVE 1 TO WS-TOOL-COUNT
     MOVE 0 TO WS-HANDLE
     MOVE 3 TO WS-LEVEL
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ID WS-LEVEL
     MOVE "4 3 3" TO WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         PERFORM SPAWN
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-EDIT
         STRING "test block drops greystone with an efficiency 3 tool (ore_drops bonus), roll " FUNCTION TRIM(WS-EDIT)
             DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1
                 MOVE "15x4@7.50,64.25,9.50" TO TL-EXPECTED
             WHEN OTHER
                 MOVE "15x3@7.50,64.25,9.50" TO TL-EXPECTED
         END-EVALUATE
         PERFORM CHECK-DROPS
     END-PERFORM

     MOVE 0 TO WS-HANDLE
     MOVE 5 TO WS-LEVEL
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ID WS-LEVEL
     PERFORM SPAWN
     MOVE "test block drops greystone with an efficiency 5 tool takes the first alternative (loam)" TO TL-CASE
     MOVE "3x1@7.50,64.25,9.50" TO TL-EXPECTED
     PERFORM CHECK-DROPS

     MOVE "cobolcraft:turf" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     COMPUTE WS-BLOCK-ROW = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE CB-KEY(WS-BLOCK-ROW) TO WS-SAVED-KEY
     MOVE "pseudo_stone" TO CB-KEY(WS-BLOCK-ROW)
     PERFORM SPAWN
     MOVE WS-SAVED-KEY TO CB-KEY(WS-BLOCK-ROW)
     MOVE "test block drops a block key without namespace (pseudo_stone) has the table minecraft:blocks/pseudo_stone" TO TL-CASE
     MOVE "3x1@7.50,64.25,9.50" TO TL-EXPECTED
     PERFORM CHECK-DROPS
     GOBACK.

 SPAWN.
     CALL "BLOCK-DROPS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-TOOL WS-TOOL-COUNT WS-HANDLE
         WS-RADIUS-SET WS-RADIUS WS-FOUND.

*> Describes the ground items (item id x count @ position) in tracker order, then frees them.
 CHECK-DROPS.
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-F
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM
             MOVE EN-ITEM(WS-E) TO WS-EDIT
             MOVE EN-ITEM-COUNT(WS-E) TO WS-EDIT2
             MOVE EN-X(WS-E) TO WS-R1
             MOVE EN-Y(WS-E) TO WS-R2
             MOVE EN-Z(WS-E) TO WS-R3
             IF WS-F > 0
                 STRING FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO WS-TEXT
             END-IF
             STRING FUNCTION TRIM(WS-TEXT) FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) "@"
                 FUNCTION TRIM(WS-R1) "," FUNCTION TRIM(WS-R2) "," FUNCTION TRIM(WS-R3)
                 DELIMITED BY SIZE INTO WS-TEXT
             ADD 1 TO WS-F
             MOVE 0 TO EN-USED(WS-E)
         END-IF
     END-PERFORM
     IF WS-F = 0
         MOVE "-" TO WS-TEXT
     END-IF
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BLOCK-DROPS.
 COPY CORETEST.
