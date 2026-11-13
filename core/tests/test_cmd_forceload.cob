*> Acceptance test of docs/protocol/16-commands-catalog.md §7.6 `forceload` (permission level 2): add and remove mark and unmark the chunks of the box of the two
*> column positions (at most 256, else commands.forceload.toobig [256, count]; x and z inside [-30000000, 30000000), else argument.pos.outofworld), the result is the
*> number of chunks changed and none changed is commands.forceload.added.failure or .removed.failure; remove all unmarks every chunk (result 0); query tells whether one
*> chunk is marked (success is quiet, a chunk not marked is commands.forceload.query.failure) or lists the marked chunks (list.single, list.multiple; none is the
*> failure message commands.forceload.added.none, result 0). Chunk positions are shown as [x, z]. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-FORCELOAD.
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
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SUGGESTION-ID       BINARY-LONG VALUE 1.
 01 WS-LENGTH              BINARY-LONG.
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
*>   Nothing is marked yet.
     MOVE "acceptance US13 /forceload query without a position and nothing marked: No force loaded chunks were found" TO TL-CASE
     MOVE "forceload query" TO WS-LINE
     MOVE "commands.forceload.added.none(cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload query with nothing marked: the result is 0" TO TL-CASE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   add.
     MOVE "acceptance US13 /forceload add one chunk: Marked chunk [0, 0] in cobolcraft:main to be force loaded" TO TL-CASE
     MOVE "forceload add 0 0" TO WS-LINE
     MOVE "commands.forceload.added.single([0, 0],cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload add a chunk that is marked: No chunks were marked for force loading" TO TL-CASE
     MOVE "commands.forceload.added.failure()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload add a box: the 8 chunks not yet marked are counted" TO TL-CASE
     MOVE "forceload add 0 0 40 40" TO WS-LINE
     MOVE "commands.forceload.added.multiple(8,cobolcraft:main,[0, 0],[2, 2])" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload add with the corners in the other order" TO TL-CASE
     MOVE "forceload add 48 48 -16 -16" TO WS-LINE
     MOVE "commands.forceload.added.multiple(16,cobolcraft:main,[-1, -1],[3, 3])" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload add: the result is the number of chunks changed" TO TL-CASE
     MOVE "forceload add 64 0" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   A chunk that is not loaded is loaded by the mark.
     MOVE "acceptance US13 /forceload the chunk of 320 320 is not loaded before the mark" TO TL-CASE
     MOVE 20 TO WS-CX WS-CZ
     ADD 1 TO WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE WS-ROW TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "forceload add 320 336" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /forceload the marked chunk is loaded" TO TL-CASE
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 0 TO WS-NUM
     IF WS-ROW > 0
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
*>   query.
     MOVE "acceptance US13 /forceload query a marked chunk: Chunk at [1, 1] in cobolcraft:main is marked for force loading" TO TL-CASE
     MOVE "forceload query 20 20" TO WS-LINE
     MOVE "commands.forceload.query.success([1, 1],cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload query a chunk that is not marked: Chunk at [12, 12] in cobolcraft:main is not marked" TO TL-CASE
     MOVE "forceload query 200 200" TO WS-LINE
     MOVE "commands.forceload.query.failure([12, 12],cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload query a marked chunk: the result is 1" TO TL-CASE
     MOVE "forceload query 0 0" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /forceload query a position that is the same chunk in the other half (block -1 is chunk -1)" TO TL-CASE
     MOVE "forceload query -1 -1" TO WS-LINE
     MOVE "commands.forceload.query.success([-1, -1],cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   remove.
     MOVE "acceptance US13 /forceload remove one chunk: Unmarked chunk [64, 0]... (block 64 is chunk 4)" TO TL-CASE
     MOVE "forceload remove 64 0" TO WS-LINE
     MOVE "commands.forceload.removed.single([4, 0],cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload remove a chunk that is not marked: No chunks were removed from force loading" TO TL-CASE
     MOVE "commands.forceload.removed.failure()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload remove a box" TO TL-CASE
     MOVE "forceload remove 0 0 40 40" TO WS-LINE
     MOVE "commands.forceload.removed.multiple(9,cobolcraft:main,[0, 0],[2, 2])" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload remove: the result is the number of chunks changed" TO TL-CASE
     MOVE "forceload remove -16 -16 48 48" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 16 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   list.
     MOVE "acceptance US13 /forceload query lists the marked chunk: A force loaded chunk was found in cobolcraft:main at: [20, 21]" TO TL-CASE
     MOVE "forceload query" TO WS-LINE
     MOVE "commands.forceload.list.single(cobolcraft:main,[20, 21])" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "forceload add 0 0 16 0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /forceload query lists the chunks in the order they were marked" TO TL-CASE
     MOVE "forceload query" TO WS-LINE
     MOVE "commands.forceload.list.multiple(3,cobolcraft:main,[20, 21], [0, 0], [1, 0])" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload query listing: the result is the number of marked chunks" TO TL-CASE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   remove all.
     MOVE "acceptance US13 /forceload remove all: Unmarked all force loaded chunks in cobolcraft:main" TO TL-CASE
     MOVE "forceload remove all" TO WS-LINE
     MOVE "commands.forceload.removed.all(cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload remove all: the result is 0" TO TL-CASE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /forceload remove all unmarked every chunk" TO TL-CASE
     MOVE "forceload query" TO WS-LINE
     MOVE "commands.forceload.added.none(cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   Limits.
     MOVE "acceptance US13 /forceload at most 256 chunks: Too many chunks in the specified area (maximum 256, but specified 361)" TO TL-CASE
     MOVE "forceload add 0 0 300 300" TO WS-LINE
     MOVE "commands.forceload.toobig(256,361)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload remove has the same limit" TO TL-CASE
     MOVE "forceload remove 0 0 300 300" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload 256 chunks are allowed" TO TL-CASE
     MOVE "forceload add -128 -128 127 127" TO WS-LINE
     MOVE "commands.forceload.added.multiple(256,cobolcraft:main,[-8, -8],[7, 7])" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "forceload remove all" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /forceload a position outside the world: That position is out of this world!" TO TL-CASE
     MOVE "forceload add 30000000 0" TO WS-LINE
     MOVE "argument.pos.outofworld()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload the second corner outside the world" TO TL-CASE
     MOVE "forceload add 0 0 0 -30000001" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload query outside the world" TO TL-CASE
     MOVE "forceload query -30000001 0" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload the last column inside the world" TO TL-CASE
     MOVE "forceload query -30000000 29999999" TO WS-LINE
     MOVE "commands.forceload.query.failure([-1875000, 1874999],cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   Relative positions are the source's block coordinates plus the offset.
     MOVE "acceptance US13 /forceload query ~ ~: the chunk of the source (Opal stands in chunk 0, 0)" TO TL-CASE
     MOVE "forceload query ~ ~" TO WS-LINE
     MOVE "commands.forceload.query.failure([0, 0],cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload query ~16 ~-16: one chunk east and one north" TO TL-CASE
     MOVE "forceload query ~16 ~-16" TO WS-LINE
     MOVE "commands.forceload.query.failure([1, -1],cobolcraft:main)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload add with relative corners" TO TL-CASE
     MOVE "forceload add ~ ~ ~16 ~16" TO WS-LINE
     MOVE "commands.forceload.added.multiple(4,cobolcraft:main,[0, 0],[1, 1])" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "forceload remove all" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
*>   Syntax, permission and the console.
     MOVE "acceptance US13 /forceload remove needs a position or all" TO TL-CASE
     MOVE "forceload remove" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /forceload a player below level 2 does not know the command" TO TL-CASE
     MOVE "forceload query" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /forceload the console prints the English text" TO TL-CASE
     MOVE "forceload add 100 100" TO WS-LINE
     MOVE "Marked chunk [6, 6] in cobolcraft:main to be force loaded" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
*>   Completion.
     MOVE "acceptance US13 /forceload completion offers the three actions" TO TL-CASE
     MOVE "/forceload " TO WS-LINE
     MOVE 11 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "1 11 0 [add,query,remove]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "forceload add 0 0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "execute in cobolcraft:subroutine run forceload add 0 0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "forceload remove all" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /forceload remove all unmarks only the chunks of the dimension of the source" TO TL-CASE
     MOVE "execute in cobolcraft:subroutine run forceload query 0 0" TO WS-LINE
     MOVE "commands.forceload.query.success([0, 0],cobolcraft:subroutine)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     GOBACK.

*> The line is run by Opal and the replies are compared with WS-EXPECTED.
 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.
 END PROGRAM TEST-CMD-FORCELOAD.

 COPY CORETEST.
 COPY CMDTEST.
