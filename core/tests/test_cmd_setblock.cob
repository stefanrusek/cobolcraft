*> Acceptance test of docs/protocol/16-commands-catalog.md §7.1 `setblock` (permission level 2): the block state is placed at the position, destroy first destroys the
*> old block, keep places only over air, strict uses the other update flags; a position that already holds the state is commands.setblock.failed; a chunk that is not
*> loaded is argument.pos.unloaded; commands.setblock.success [x, y, z] is broadcast; the result is 1. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SETBLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 COPY CBLOCKS.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-STATE               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /setblock setblock: Changed the block at 2, " & "70, 2" TO TL-CASE
     MOVE "setblock 2 70 2 cobolcraft:greystone" TO WS-LINE
     MOVE "commands.setblock.success(2,70,2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock the block is placed" TO TL-CASE
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 2 70 2 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setblock the same state again: Could not se" & "t the block" TO TL-CASE
     MOVE "setblock 2 70 2 cobolcraft:greystone" TO WS-LINE
     MOVE "commands.setblock.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock keep over a block that is not air " & "fails" TO TL-CASE
     MOVE "setblock 2 70 2 cobolcraft:loam keep" TO WS-LINE
     MOVE "commands.setblock.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock and nothing changed" TO TL-CASE
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 2 70 2 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setblock keep over air places" TO TL-CASE
     MOVE "setblock 3 70 2 cobolcraft:loam keep" TO WS-LINE
     MOVE "commands.setblock.success(3,70,2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock the block is loam" TO TL-CASE
     MOVE "cobolcraft:loam" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 3 70 2 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setblock replace over another block" TO TL-CASE
     MOVE "setblock 2 70 2 cobolcraft:loam replace" TO WS-LINE
     MOVE "commands.setblock.success(2,70,2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock the block is loam now" TO TL-CASE
     MOVE "cobolcraft:loam" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 2 70 2 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setblock destroy first destroys the old blo" & "ck" TO TL-CASE
     MOVE "setblock 2 70 2 cobolcraft:turf destroy" TO WS-LINE
     MOVE "commands.setblock.success(2,70,2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock the block is turf" TO TL-CASE
     MOVE "cobolcraft:turf" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 2 70 2 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setblock strict" TO TL-CASE
     MOVE "setblock 4 70 2 cobolcraft:grit strict" TO WS-LINE
     MOVE "commands.setblock.success(4,70,2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock the block is grit" TO TL-CASE
     MOVE "cobolcraft:grit" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 4 70 2 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setblock destroy over air still places" TO TL-CASE
     MOVE "setblock 5 70 2 cobolcraft:loam destroy" TO WS-LINE
     MOVE "commands.setblock.success(5,70,2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock a chunk that is not loaded: That p" & "osition is not loaded" TO TL-CASE
     MOVE "setblock 1000000 70 0 cobolcraft:loam" TO WS-LINE
     MOVE "argument.pos.unloaded()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock a height outside the world is not " & "placed: Could not set the block" TO TL-CASE
     MOVE "setblock 2 100000 2 cobolcraft:loam" TO WS-LINE
     MOVE "commands.setblock.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock an unknown block" TO TL-CASE
     MOVE "setblock 2 70 2 cobolcraft:nothing" TO WS-LINE
     MOVE "argument.block.id.invalid(cobolcraft:nothing) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock a position needs three coordinates" TO TL-CASE
     MOVE "setblock 2 70" TO WS-LINE
     MOVE "argument.pos3d.incomplete() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock a player below level 2 does not kn" & "ow the command" TO TL-CASE
     MOVE "setblock 2 70 2 cobolcraft:loam" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setblock the console prints the English tex" & "t" TO TL-CASE
     MOVE "setblock 6 70 2 cobolcraft:loam" TO WS-LINE
     MOVE "Changed the block at 6, 70, 2" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> WS-STATE: the default state of the block key WS-KEY-TEXT.
 FIND-STATE.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF CB-KEY(WS-I) = WS-KEY-TEXT
             MOVE CB-DEFAULT-STATE(WS-I) TO WS-STATE
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-SETBLOCK.

 COPY CORETEST.
 COPY CMDTEST.
