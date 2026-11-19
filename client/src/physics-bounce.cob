*> The landing bounce of the local player (lane bugbounce, T61211; docs/protocol/44-residual-mob-questions-5 section 4.3, 24-5 slime_block, 24-2 beds): after a vertical move
*> stopped by a floor with downward speed, the vertical speed becomes the restitution of the block under the feet (slime 1.0, a bed 0.75, shelf_mushroom 0.75; core/src/fall-rules.cob)
*> instead of 0, unless the shift key is down or the landing is slower than the gravity 0.08. The server needs nothing: Move Player carries the position and the core's fall
*> damage follows the landed-on block (FALL-LANDING-RULE).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-BOUNCE.
*> USING CLIENT-STATE, v (FLOAT-LONG: the vertical speed of the move, before the collision), moved (FLOAT-LONG: the distance the move completed), sneak (1 when the sneak key is down),
*> vy out (FLOAT-LONG: the vertical speed after the landing, 0 without a bounce). The block is the one 0.2 below the feet (getOnPosLegacy), named through the open content set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-KEY                 PIC X(48).
 01 WS-RESTITUTION         FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-V                    FLOAT-LONG.
 01 L-MOVED                FLOAT-LONG.
 01 L-SNEAK                BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-V L-MOVED L-SNEAK L-VY.
     MOVE 0 TO L-VY WS-RESTITUTION
     IF CT-OPEN = 1 AND L-SNEAK = 0 AND 0 - L-V > 0.08
         COMPUTE WS-X = FUNCTION INTEGER(PL-X)
         COMPUTE WS-Y = FUNCTION INTEGER(PL-Y - 0.2)
         COMPUTE WS-Z = FUNCTION INTEGER(PL-Z)
         CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
         IF WS-STATE > 0
             CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-BLOCK WS-INDEX WS-ROW WS-STATUS
             MOVE WS-ROW TO CT-BLOCK-ROW
             MOVE SPACES TO WS-KEY
             MOVE CT-BR-KEY TO WS-KEY
             CALL "BOUNCE-OF-KEY" USING WS-KEY WS-RESTITUTION
         END-IF
     END-IF
     CALL "LV-RESTITUTE" USING L-V L-MOVED WS-RESTITUTION L-SNEAK L-VY
     GOBACK.
 END PROGRAM PHYS-BOUNCE.
