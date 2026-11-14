*> Server-side checks of a client's ground claim (docs/protocol/13 §1.3 "The jump rule": a server may
*> validate that vertical movement is consistent with it; US7-2, the endless survival climb).
*> A Move Player flag on-ground = 1 is a claim of the client, not a fact: it counts only when the
*> player box has support, a solid block directly below the feet (MOVE-SUPPORTED, the box lowered by
*> 0.01 block collides). A move that rises while claiming the ground in the air is refused by
*> MOVE-PLAYER (core/src/movement.cob) unless the box is inside a climbable block (tag
*> minecraft:climbable: ladders, vines, scaffolding; MOVE-CLIMBING). A step up of a block or a
*> stair, a jump onto a ledge (on-ground 0 while rising) and a climb are therefore never corrected.
*>
*> Entry points:
*>   MOVE-SUPPORTED USING dim, x, y, z (FLOAT-LONG feet position), result out (BINARY-LONG 1 or 0)
*>   MOVE-CLIMBING USING dim, x, y, z (FLOAT-LONG), result out: 1 when the player box at that position
*>     overlaps a block of the tag minecraft:climbable

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-SUPPORTED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-RESULT.
     COMPUTE WS-LOW = L-Y - 0.01
     CALL "MOVE-COLLIDES" USING L-DIM L-X WS-LOW L-Z WS-HIT
     MOVE WS-HIT TO L-RESULT
     GOBACK.
 END PROGRAM MOVE-SUPPORTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-CLIMBING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:climbable".
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TAGGED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     COMPUTE WS-HALF = ET-WIDTH-MILLI(CR-OPERATOR + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(CR-OPERATOR + 1) / 1000
*>   The cells the box overlaps with positive volume (the 1e-7 tolerance of MOVE-COLLIDES).
     COMPUTE WS-X0 = FUNCTION INTEGER(L-X - WS-HALF + 0.0000001)
     COMPUTE WS-X1 = - FUNCTION INTEGER(0.0000001 - (L-X + WS-HALF)) - 1
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y + 0.0000001)
     COMPUTE WS-Y1 = - FUNCTION INTEGER(0.0000001 - (L-Y + WS-HEIGHT)) - 1
     COMPUTE WS-Z0 = FUNCTION INTEGER(L-Z - WS-HALF + 0.0000001)
     COMPUTE WS-Z1 = - FUNCTION INTEGER(0.0000001 - (L-Z + WS-HALF)) - 1
     PERFORM VARYING WS-BY FROM WS-Y0 BY 1 UNTIL WS-BY > WS-Y1 OR L-RESULT = 1
         PERFORM VARYING WS-BZ FROM WS-Z0 BY 1 UNTIL WS-BZ > WS-Z1 OR L-RESULT = 1
             PERFORM VARYING WS-BX FROM WS-X0 BY 1 UNTIL WS-BX > WS-X1 OR L-RESULT = 1
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-BX WS-BY WS-BZ WS-STATE
                 IF WS-STATE > 0
                     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
                     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-TAGGED
                     MOVE WS-TAGGED TO L-RESULT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MOVE-CLIMBING.
