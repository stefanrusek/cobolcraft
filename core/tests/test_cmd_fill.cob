*> Acceptance test of docs/protocol/16-commands-catalog.md §7.2 `fill` (permission level 2): the box of the two corners is filled (replace, with a filter on the
*> block, keep over air, outline on the faces only, hollow with air inside, destroy), commands.fill.success [count] is broadcast and the result is the count; nothing
*> changed is commands.fill.failed; a volume above max_block_modifications is commands.fill.toobig [max, volume]; a corner in a chunk that is not loaded is
*> argument.pos.unloaded. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-FILL.
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
     MOVE "acceptance US13 /fill fill a 3 x 3 x 3 box: Successfully fil" & "led 27 block(s)" TO TL-CASE
     MOVE "fill 0 70 0 2 72 2 cobolcraft:greystone" TO WS-LINE
     MOVE "commands.fill.success(27)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill the middle is filled" TO TL-CASE
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 1 71 1 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /fill the same fill again changes nothing: N" & "o blocks were filled" TO TL-CASE
     MOVE "fill 0 70 0 2 72 2 cobolcraft:greystone" TO WS-LINE
     MOVE "commands.fill.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill the corners in either order: the resul" & "t is the count" TO TL-CASE
     MOVE "fill 2 72 2 0 70 0 cobolcraft:loam" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 27 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /fill replace with a filter that no block ma" & "tches" TO TL-CASE
     MOVE "fill 0 70 0 2 72 2 cobolcraft:turf replace cobolcraft:greyst" & "one" TO WS-LINE
     MOVE "commands.fill.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill replace with a filter on loam" TO TL-CASE
     MOVE "fill 0 70 0 2 72 2 cobolcraft:turf replace cobolcraft:loam" TO WS-LINE
     MOVE "commands.fill.success(27)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill the middle is turf" TO TL-CASE
     MOVE "cobolcraft:turf" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 1 71 1 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /fill replace without a filter" TO TL-CASE
     MOVE "fill 0 70 0 2 72 2 cobolcraft:grit replace" TO WS-LINE
     MOVE "commands.fill.success(27)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill outline: the 26 blocks of the faces" TO TL-CASE
     MOVE "fill 0 74 0 2 76 2 cobolcraft:loam outline" TO WS-LINE
     MOVE "commands.fill.success(26)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill a corner is filled" TO TL-CASE
     MOVE "cobolcraft:loam" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 0 74 0 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /fill the middle is not" TO TL-CASE
     MOVE 0 TO WS-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 1 75 1 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /fill hollow: the faces change, the inside b" & "ecomes air (it was air)" TO TL-CASE
     MOVE "fill 0 74 0 2 76 2 cobolcraft:turf hollow" TO WS-LINE
     MOVE "commands.fill.success(26)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill the inside is air" TO TL-CASE
     MOVE 0 TO WS-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 1 75 1 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /fill keep over air" TO TL-CASE
     MOVE "fill 0 78 0 2 78 2 cobolcraft:loam keep" TO WS-LINE
     MOVE "commands.fill.success(9)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill keep over blocks changes nothing" TO TL-CASE
     MOVE "fill 0 78 0 2 78 2 cobolcraft:turf keep" TO WS-LINE
     MOVE "commands.fill.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill destroy counts the destroyed blocks" TO TL-CASE
     MOVE "fill 0 78 0 2 78 2 cobolcraft:grit destroy" TO WS-LINE
     MOVE "commands.fill.success(9)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill the blocks are grit" TO TL-CASE
     MOVE "cobolcraft:grit" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 1 78 1 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /fill strict" TO TL-CASE
     MOVE "fill 0 78 0 2 78 2 cobolcraft:loam strict" TO WS-LINE
     MOVE "commands.fill.success(9)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill only one mode literal follows the bloc" & "k (the grammar of 7.2)" TO TL-CASE
     MOVE "fill 0 78 0 2 78 2 cobolcraft:loam outline strict" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill a small limit" TO TL-CASE
     MOVE "gamerule max_block_modifications 10" TO WS-LINE
     MOVE "commands.gamerule.set(max_block_modifications,10)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill a volume above the limit: Too many blo" & "cks in the specified area (maximum 10, but specified 27)" TO TL-CASE
     MOVE "fill 0 70 0 2 72 2 cobolcraft:loam" TO WS-LINE
     MOVE "commands.fill.toobig(10,27)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill a corner in a chunk that is not loaded" TO TL-CASE
     MOVE "fill 0 70 0 1000000 72 2 cobolcraft:loam" TO WS-LINE
     MOVE "argument.pos.unloaded()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill the second corner needs three coordina" & "tes" TO TL-CASE
     MOVE "fill 0 70 0 2 72 cobolcraft:loam" TO WS-LINE
     MOVE "parsing.int.expected() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill a player below level 2 does not know t" & "he command" TO TL-CASE
     MOVE "fill 0 70 0 1 70 1 cobolcraft:loam" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fill the console prints the English text" TO TL-CASE
     MOVE "fill 8 70 8 8 70 8 cobolcraft:loam" TO WS-LINE
     MOVE "Successfully filled 1 block(s)" TO WS-EXPECTED
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
 END PROGRAM TEST-CMD-FILL.

 COPY CORETEST.
 COPY CMDTEST.
