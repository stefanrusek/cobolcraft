*> The spring feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 4; registry id 48, spring_feature): FD-SPRING-NODE compiles the configuration into a row of FD-WA
*> (WA-I(1) requires_block_below 1 or 0, WA-I(2) rock_count, WA-I(3) hole_count, WA-I(4) the fluid block index; the pool 1 the valid blocks), FR-SPRING places it. The fluid state of the
*> data carries falling = true, but the block written is the legacy block of a source, which is level 0: the default state of the fluid block. No random draw is made. The fluid tick of
*> the document (scheduleTick) is not run: the generator keeps no tick queue, so a spring starts to flow when a neighbouring block next updates in the running game.
*>
*> Entry points: FD-SPRING-NODE USING doc, node, row out (FD-BAD set when the feature cannot be placed whole); FR-SPRING USING feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-SPRING-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDCONST.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY48               PIC X(48).
 01 WS-OK                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
*>   state: only the fluid matters (the legacy block of a source is level 0)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-STATE WS-E
     CALL "FD-J-STRING" USING JSON-DOC FK-ID WS-E WS-TEXT WS-LEN
     CALL "FD-KEY" USING WS-TEXT WS-KEY
     MOVE WS-KEY TO WS-KEY48
     CALL "FD-BLOCK-INDEX" USING WS-KEY48 WA-I(WS-ROW, 4)
     IF WA-I(WS-ROW, 4) = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-VALID-BLOCKS WS-E
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-E FC-N1 WA-START(WS-ROW, 1) WA-N(WS-ROW, 1)
     MOVE 1 TO WA-I(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-REQUIRES-BELOW WS-E
     IF WS-E > 0
         IF JN-TYPE(WS-E) = JT-FALSE
             MOVE 0 TO WA-I(WS-ROW, 1)
         END-IF
     END-IF
     MOVE 4 TO WA-I(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-ROCK-COUNT WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WS-V WS-OK
     IF WS-OK = 1
         MOVE WS-V TO WA-I(WS-ROW, 2)
     END-IF
     MOVE 1 TO WA-I(WS-ROW, 3)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-HOLE-COUNT WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WS-V WS-OK
     IF WS-OK = 1
         MOVE WS-V TO WA-I(WS-ROW, 3)
     END-IF
     GOBACK.
 END PROGRAM FD-SPRING-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-SPRING.
*> USING feature, x, y, z, result out (1 when the fluid block was written).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ROCKS               BINARY-LONG.
 01 WS-HOLES               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-STATE-OUT           BINARY-LONG.
*> the five neighbours west, east, north, south and below as offsets
 01 WS-OFFSETS.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
 01 WS-OFFSET-TABLE REDEFINES WS-OFFSETS.
    05 WS-OFFSET OCCURS 5 TIMES.
       10 WS-DX            BINARY-LONG.
       10 WS-DY            BINARY-LONG.
       10 WS-DZ            BINARY-LONG.
 LINKAGE SECTION.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
*>   1. the block above must be valid
     COMPUTE WS-Y = L-Y + 1
     CALL "FL-GET-STATE" USING L-X WS-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 1) WA-N(WS-ROW, 1) WS-BLOCK WS-VALID
     IF WS-VALID = 0
         GOBACK
     END-IF
*>   2. and the block below when it is required
     IF WA-I(WS-ROW, 1) = 1
         COMPUTE WS-Y = L-Y - 1
         CALL "FL-GET-STATE" USING L-X WS-Y L-Z WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 1) WA-N(WS-ROW, 1) WS-BLOCK WS-VALID
         IF WS-VALID = 0
             GOBACK
         END-IF
     END-IF
*>   3. the origin is air or valid
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 1) WA-N(WS-ROW, 1) WS-BLOCK WS-VALID
     IF WS-VALID = 0 AND WS-CLASS NOT = 1
         GOBACK
     END-IF
*>   4. the rocks and holes among west, east, north, south and below
     MOVE 0 TO WS-ROCKS WS-HOLES
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         COMPUTE WS-X = L-X + WS-DX(WS-K)
         COMPUTE WS-Y = L-Y + WS-DY(WS-K)
         COMPUTE WS-Z = L-Z + WS-DZ(WS-K)
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 1) WA-N(WS-ROW, 1) WS-BLOCK WS-VALID
         IF WS-VALID = 1
             ADD 1 TO WS-ROCKS
         END-IF
         IF WS-CLASS = 1
             ADD 1 TO WS-HOLES
         END-IF
     END-PERFORM
     IF WS-ROCKS = WA-I(WS-ROW, 2) AND WS-HOLES = WA-I(WS-ROW, 3)
         MOVE WA-I(WS-ROW, 4) TO WS-BLOCK
         MOVE CB-DEFAULT-STATE(WS-BLOCK) TO WS-STATE-OUT
         CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-STATE-OUT WS-FLAGS WS-OK
         IF WS-OK = 1
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-SPRING.
