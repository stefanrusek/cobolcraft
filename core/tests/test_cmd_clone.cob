*> Acceptance test of docs/protocol/16-commands-catalog.md §7.4 `clone` (permission level 2): the source box is copied to the destination (replace, masked,
*> filtered <predicate>; normal, force and move modes, which follow replace, masked or filtered (57-client-closures-4 section 7.7); strict; from and to dimensions), commands.clone.success [count] is broadcast and the result is the number of
*> blocks written; the same dimension with intersecting boxes in normal mode is commands.clone.overlap, a volume above max_block_modifications is
*> commands.clone.toobig [max, volume], a box in a chunk that is not loaded is argument.pos.unloaded, nothing written is commands.clone.failed. Opal holds operator
*> status; the world has the extra dimension (cobolcraft:subroutine). Blocks are read back with WORLD-GET-BLOCK.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-CLONE.
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
 01 WS-ROW                 BINARY-LONG.
 01 WS-SUGGESTION-ID       BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 COPY CBLOCKS.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-STATE               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE 1 TO WS-DIM
*>   A 2 x 1 x 2 source of greystone.
     MOVE "fill 0 100 0 1 100 1 cobolcraft:greystone" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /clone a box is copied: Successfully cloned 4 block(s)" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 4 100 0" TO WS-LINE
     MOVE "commands.clone.success(4)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone the first destination block is greystone" TO TL-CASE
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     MOVE 4 TO WS-BX
     MOVE 100 TO WS-BY
     MOVE 0 TO WS-BZ
     PERFORM ASSERT-BLOCK
     MOVE "acceptance US13 /clone the last destination block is greystone" TO TL-CASE
     MOVE 5 TO WS-BX
     MOVE 1 TO WS-BZ
     PERFORM ASSERT-BLOCK
     MOVE "acceptance US13 /clone beside the destination box nothing was written" TO TL-CASE
     MOVE SPACES TO WS-KEY-TEXT
     MOVE 3 TO WS-BX
     MOVE 0 TO WS-BZ
     PERFORM ASSERT-BLOCK
     MOVE "acceptance US13 /clone the source box is untouched" TO TL-CASE
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     MOVE 1 TO WS-BX
     MOVE 1 TO WS-BZ
     PERFORM ASSERT-BLOCK
     MOVE "acceptance US13 /clone the corners in any order (all three axes reversed)" TO TL-CASE
     MOVE "clone 1 101 1 0 100 0 18 100 0" TO WS-LINE
     MOVE "commands.clone.success(4)" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   Overlap.
     MOVE "acceptance US13 /clone normal mode with intersecting boxes: The source and destination areas cannot overlap" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 1 100 1" TO WS-LINE
     MOVE "commands.clone.overlap()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone replace without a move mode is normal too" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 1 100 1 replace" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone strict does not change the overlap rule" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 1 100 1 strict replace normal" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone the overlap error is not the toobig error" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 1 100 1 masked" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone force allows the boxes to intersect: only the 3 changed blocks count" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 1 100 1 replace force" TO WS-LINE
     MOVE "commands.clone.success(3)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone force wrote the far corner of the destination" TO TL-CASE
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     MOVE 2 TO WS-BX
     MOVE 2 TO WS-BZ
     PERFORM ASSERT-BLOCK
*>   Move mode.
     MOVE "fill 0 100 10 1 100 10 cobolcraft:loam" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /clone move: the blocks are written" TO TL-CASE
     MOVE "clone 0 100 10 1 100 10 4 100 10 replace move" TO WS-LINE
     MOVE "commands.clone.success(2)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone move: the source is air afterwards" TO TL-CASE
     MOVE SPACES TO WS-KEY-TEXT
     MOVE 0 TO WS-BX
     MOVE 10 TO WS-BZ
     PERFORM ASSERT-BLOCK
     MOVE "acceptance US13 /clone move: the destination holds the blocks" TO TL-CASE
     MOVE "cobolcraft:loam" TO WS-KEY-TEXT
     MOVE 5 TO WS-BX
     PERFORM ASSERT-BLOCK
     MOVE "acceptance US13 /clone move may overlap" TO TL-CASE
     MOVE "clone 4 100 10 5 100 10 5 100 10 replace move" TO WS-LINE
     MOVE "commands.clone.success(2)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone move with overlap: the vacated block is air" TO TL-CASE
     MOVE SPACES TO WS-KEY-TEXT
     MOVE 4 TO WS-BX
     PERFORM ASSERT-BLOCK
*>   Masked and filtered.
     MOVE "setblock 0 100 20 cobolcraft:greystone" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "setblock 2 100 20 cobolcraft:greystone" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /clone masked leaves out the air block" TO TL-CASE
     MOVE "clone 0 100 20 2 100 20 0 102 20 masked" TO WS-LINE
     MOVE "commands.clone.success(2)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone masked: the air of the source did not overwrite" TO TL-CASE
     MOVE "cobolcraft:loam" TO WS-KEY-TEXT
     MOVE "setblock 1 102 20 cobolcraft:loam" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "clone 0 100 20 2 100 20 0 102 20 masked force" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE 1 TO WS-BX
     MOVE 102 TO WS-BY
     MOVE 20 TO WS-BZ
     PERFORM ASSERT-BLOCK
     MOVE "acceptance US13 /clone replace takes the air too" TO TL-CASE
     MOVE "clone 0 100 20 2 100 20 0 102 20 replace force" TO WS-LINE
     MOVE "commands.clone.success(1)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone filtered with a block that is there" TO TL-CASE
     MOVE "clone 0 100 20 2 100 20 0 104 20 filtered cobolcraft:greystone" TO WS-LINE
     MOVE "commands.clone.success(2)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone filtered with a block that is not there: No blocks were cloned" TO TL-CASE
     MOVE "clone 0 100 20 2 100 20 0 106 20 filtered cobolcraft:loam" TO WS-LINE
     MOVE "commands.clone.failed()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone filtered with a move mode" TO TL-CASE
     MOVE "clone 0 100 20 2 100 20 0 108 20 filtered cobolcraft:greystone normal" TO WS-LINE
     MOVE "commands.clone.success(2)" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   Nothing written, strict, result value.
     MOVE "acceptance US13 /clone a box of air onto air changes nothing: No blocks were cloned" TO TL-CASE
     MOVE "clone 0 110 0 1 110 1 0 112 0" TO WS-LINE
     MOVE "commands.clone.failed()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone strict: the result is the number of blocks written" TO TL-CASE
     MOVE "clone 0 100 0 0 100 0 8 100 0 strict" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /clone strict with a filter and a mode" TO TL-CASE
     MOVE "clone 0 100 0 0 100 0 9 100 0 strict masked force" TO WS-LINE
     MOVE "commands.clone.success(1)" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   Limits and loaded chunks.
     MOVE "acceptance US13 /clone the limit is the gamerule" TO TL-CASE
     MOVE "gamerule max_block_modifications 10" TO WS-LINE
     MOVE "commands.gamerule.set(max_block_modifications,10)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone a volume above the limit: Too many blocks in the specified area (maximum 10, but specified 27)" TO TL-CASE
     MOVE "clone 0 100 0 2 102 2 20 100 0" TO WS-LINE
     MOVE "commands.clone.toobig(10,27)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "gamerule max_block_modifications 32768" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /clone a destination in a chunk that is not loaded" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 1000000 100 0" TO WS-LINE
     MOVE "argument.pos.unloaded()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone a position beyond 30000000 blocks is not loaded either" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 99999999 100 0" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone a source in a chunk that is not loaded" TO TL-CASE
     MOVE "clone 1000000 100 0 1000001 100 0 0 100 0" TO WS-LINE
     PERFORM RUN-TEXT
*>   The dimensions.
     MOVE "acceptance US13 /clone from and to name the same dimension" TO TL-CASE
     MOVE "clone from cobolcraft:main 0 100 0 0 100 0 to cobolcraft:main 12 100 12" TO WS-LINE
     MOVE "commands.clone.success(1)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone an unknown source dimension" TO TL-CASE
     MOVE "clone from nowhere:x 0 100 0 0 100 0 5 100 5" TO WS-LINE
     MOVE "argument.dimension.invalid(nowhere:x)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone an unknown target dimension" TO TL-CASE
     MOVE "clone 0 100 0 0 100 0 to nowhere:y 5 100 5" TO WS-LINE
     MOVE "argument.dimension.invalid(nowhere:y)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE 2 TO WS-DIM
     MOVE 0 TO WS-BX WS-BZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-BX WS-BZ WS-ROW
     MOVE 1 TO WS-DIM
     MOVE "acceptance US13 /clone into another dimension (same coordinates: no overlap)" TO TL-CASE
     MOVE "clone 0 100 0 0 100 0 to cobolcraft:subroutine 0 100 0" TO WS-LINE
     MOVE "commands.clone.success(1)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone the other dimension holds the block" TO TL-CASE
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     MOVE 2 TO WS-DIM
     MOVE 0 TO WS-BX
     MOVE 100 TO WS-BY
     MOVE 0 TO WS-BZ
     PERFORM ASSERT-BLOCK
     MOVE "acceptance US13 /clone out of another dimension" TO TL-CASE
     MOVE "clone from cobolcraft:subroutine 0 100 0 0 100 0 7 101 7" TO WS-LINE
     MOVE "commands.clone.success(1)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE 1 TO WS-DIM
     MOVE "acceptance US13 /clone the block arrived in the main dimension" TO TL-CASE
     MOVE 7 TO WS-BX
     MOVE 101 TO WS-BY
     MOVE 7 TO WS-BZ
     PERFORM ASSERT-BLOCK
     MOVE "acceptance US13 /clone a chunk of the other dimension that is not loaded" TO TL-CASE
     MOVE "clone from cobolcraft:subroutine 1000000 100 0 1000000 100 0 7 101 7" TO WS-LINE
     MOVE "argument.pos.unloaded()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone completion after the last argument offers the next words" TO TL-CASE
     MOVE "/clone 0 100 0 1 100 1 20 100 0 " TO WS-LINE
     MOVE 32 TO WS-LENGTH
     MOVE 1 TO WS-SUGGESTION-ID
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "1 32 0 [filtered,masked,replace,strict]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
*>   Syntax.
     MOVE "acceptance US13 /clone the destination is required" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone strict goes before the filter mode" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 20 100 0 masked strict" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /clone a player below level 2 does not know the command" TO TL-CASE
     MOVE "clone 0 100 0 1 100 1 20 100 0" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clone the console prints the English text" TO TL-CASE
     MOVE "clone 0 100 0 0 100 0 14 100 14" TO WS-LINE
     MOVE "Successfully cloned 1 block(s)" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The line is run by Opal and the replies are compared with WS-EXPECTED.
 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.

*> The block at (WS-BX, WS-BY, WS-BZ) of dimension WS-DIM is the block key WS-KEY-TEXT (spaces: air).
 ASSERT-BLOCK.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF WS-KEY-TEXT NOT = SPACES AND CB-KEY(WS-I) = WS-KEY-TEXT
             MOVE CB-DEFAULT-STATE(WS-I) TO WS-STATE
         END-IF
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM.
 END PROGRAM TEST-CMD-CLONE.

 COPY CORETEST.
 COPY CMDTEST.
