*> Convergence acceptance test of US10-1 to US10-4 (spec.md US10; standin-content §13 recipes, §2
*> starting inventory; client-surface §3 C; 09 §3.3 Recipe Book Add, Place Recipe): a first-time
*> survival Player in a single-player world (the client's in-process core) opens the crafting
*> screen, sees every recipe with its ingredients, result and mark, crafts through the screen's
*> Craft control, and the core's outcome comes back to the client's inventory replica and marks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US10-CRAFTING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us10-crafting".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 24.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Crafting".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 8.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE ACT-CRAFT.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-BEFORE              PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "CV-STEPS" USING CONVH WS-TEN
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

*>   US10-1: the crafting screen (C) lists the nine recipes of §13 with ingredients, result and
*>   mark; the starting inventory makes recipes 0, 1, 2, 3, 5 and 8 (enabled Craft controls).
     MOVE CC-KEY-C TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     CALL "CV-STEP" USING CONVH
     MOVE "acceptance US10-1 given a first-time survival Player when they open the crafting "
         & "screen then every recipe is shown with a Craft control enabled exactly for the "
         & "recipes their inventory can make" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "screen 7 0:0 1:0 2:0 3:0 4:2 5:0 6:2 7:2 8:0" TO TL-EXPECTED
     CALL "U10-MARKS" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXT
     MOVE "acceptance US10-1 the crafting screen shows each recipe's ingredients in order and its "
         & "result, e.g. recipe 7 (4 ledger_tile, 2 dump_shard, 1 glowtube makes 1 goto_pad) and "
         & "recipe 8" TO TL-CASE
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL
         "4 x Ledger Tile, 2 x Dump Shard, 1 x Glowtube|Makes 1 x GOTO Pad"
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "2 x Cardstack, 2 x Lucite|Makes 1 x Dump Shard"
     MOVE "both shown" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     IF WS-HITS = 2
         MOVE "both shown" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US10-2: Craft on recipe 8 (2 cardstack + 2 lucite -> 1 dump_shard).
     CALL "U10-INVENTORY" USING CLIENT-STATE WS-BEFORE
     MOVE 8 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-STEPS" USING CONVH WS-TEN
     MOVE "acceptance US10-2 given the Player has a recipe's ingredients when they craft it then "
         & "the ingredients leave their inventory and the result is added" TO TL-CASE
     MOVE "0:64x2 1:64x3 2:64x4 3:64x5 4:62x6 5:62x7 6:64x8 7:64x9 8:1x10 9:1x11 10:1x15"
         TO TL-EXPECTED
     CALL "U10-INVENTORY" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US10-2 after crafting the marks follow the new inventory: recipe 4 "
         & "(lucite + dump_shard) is now craftable" TO TL-CASE
     MOVE "screen 7 0:0 1:0 2:0 3:0 4:0 5:0 6:2 7:2 8:0" TO TL-EXPECTED
     CALL "U10-MARKS" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US10-3: recipe 6 needs 2 grazer_flank, which the Player lacks: its control is disabled, and a
*>   Place Recipe sent anyway (the screen's craft action) changes nothing.
     CALL "U10-INVENTORY" USING CLIENT-STATE WS-BEFORE
     MOVE 6 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CRAFTING-CRAFT" USING CLIENT-STATE WS-ARG
     CALL "CV-STEPS" USING CONVH WS-TEN
     MOVE "acceptance US10-3 given the Player lacks a recipe's ingredients when they try to craft "
         & "it then nothing is crafted and their inventory is unchanged" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED
     CALL "U10-INVENTORY" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US10-4: the inventory filled with greystone (25 empty slots of 64, by the supply command), so
*>   recipe 0's 2 ledger_tile (whose stack is full) has no room. C closes the crafting screen first.
     MOVE CC-KEY-C TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE "/supply Alice greystone 1600" TO WS-LINE
     MOVE 28 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     CALL "CV-STEPS" USING CONVH WS-TEN
     MOVE CC-KEY-C TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     CALL "CV-STEP" USING CONVH
     CALL "U10-INVENTORY" USING CLIENT-STATE WS-BEFORE
     MOVE "acceptance US10-4 given a full inventory then a recipe whose result has no room after "
         & "its ingredients are removed is not marked craftable (only 1, 4 and 8 still fit)"
         TO TL-CASE
     MOVE "screen 7 0:2 1:0 2:2 3:2 4:0 5:2 6:2 7:2 8:0" TO TL-EXPECTED
     CALL "U10-MARKS" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-ARG
     CALL "CRAFTING-CRAFT" USING CLIENT-STATE WS-ARG
     CALL "CV-STEPS" USING CONVH WS-TEN
     MOVE "acceptance US10-4 given the Player crafts a result for which their inventory has no "
         & "room when they craft then nothing is crafted and their inventory is unchanged"
         TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED
     CALL "U10-INVENTORY" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "US10-4 the full inventory holds 36 occupied slots" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 36 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-COUNT(WS-I) > 0
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US10-CRAFTING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U10-MARKS.
*> USING CLIENT-STATE, text out (PIC X(1024)): "screen <n>" then " <recipe>:<state>" of every Craft
*> control of the screen model (state 0 enabled, 2 disabled).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     MOVE SM-SCREEN TO WS-E1
     STRING "screen " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-ACTION(WS-I) = ACT-CRAFT
             MOVE SM-W-ARG(WS-I) TO WS-E1
             MOVE SM-W-STATE(WS-I) TO WS-E2
             STRING " " FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
                 INTO L-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM U10-MARKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U10-INVENTORY.
*> USING CLIENT-STATE, text out (PIC X(1024)): " <slot>:<count>x<item>" of every non-empty slot of
*> the client's inventory replica (slots 0 to 35), trimmed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-COUNT(WS-I) > 0
             COMPUTE WS-E1 = WS-I - 1
             MOVE PL-SLOT-COUNT(WS-I) TO WS-E2
             MOVE PL-SLOT-ITEM(WS-I) TO WS-E3
             STRING " " FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
                 DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE FUNCTION TRIM(WS-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM U10-INVENTORY.
