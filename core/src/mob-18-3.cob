*> The block effects and freezing of a standard mob (docs/protocol/18-mob-framework.md sections 2.6 step 11 and 3.3; lane p49a).
*>
*>   M183-SCAN USING dim, x, y, z, half width, height (FLOAT-LONG), cactus, web, berry, magma, powder out (BINARY-LONG)   the blocks of the entity's box: a cactus or a
*>       cobweb in it, a sweet berry bush (1 young, 2 grown), a magma block under its feet and powder snow in the cell of its feet
*>   M183-FREEZE USING tracker row, in powder snow (BINARY-LONG)   ticksFrozen: +1 in powder snow, -2 otherwise (never below 0); fully frozen (140) takes 1.0 freeze damage
*>       (5.0 for blaze, strider and magma cube) on every 40th tick; polar bear, stray, snow golem and wither cannot freeze
*>   M183-TICK USING tracker row   the block effects of the box after the move (cactus 1.0, magma block 1.0 on the ground, a sweet berry bush 1.0 when the mob moved more than
*>       0.003 and the bush is grown) and the freezing

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M183-SCAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-PROPS               PIC X(160).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HALF                 FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-CACTUS               BINARY-LONG.
 01 L-WEB                  BINARY-LONG.
 01 L-BERRY                BINARY-LONG.
 01 L-MAGMA                BINARY-LONG.
 01 L-POWDER               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HALF L-HEIGHT L-CACTUS L-WEB L-BERRY L-MAGMA L-POWDER.
     MOVE 0 TO L-CACTUS L-WEB L-BERRY L-MAGMA L-POWDER
     COMPUTE WS-LOW = L-X - L-HALF
     COMPUTE WS-HIGH = L-X + L-HALF
     COMPUTE WS-X0 = FUNCTION INTEGER(WS-LOW)
     COMPUTE WS-X1 = FUNCTION INTEGER(WS-HIGH)
     COMPUTE WS-LOW = L-Z - L-HALF
     COMPUTE WS-HIGH = L-Z + L-HALF
     COMPUTE WS-Z0 = FUNCTION INTEGER(WS-LOW)
     COMPUTE WS-Z1 = FUNCTION INTEGER(WS-HIGH)
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y)
     COMPUTE WS-HIGH = L-Y + L-HEIGHT - 0.01
     COMPUTE WS-Y1 = FUNCTION INTEGER(WS-HIGH)
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = 0
                     EVALUATE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)
                         WHEN "cactus"
                             MOVE 1 TO L-CACTUS
                         WHEN "cobweb"
                             MOVE 1 TO L-WEB
                         WHEN "sweet_berry_bush"
                             CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
                             IF WS-PROPS(1:5) = "age=0"
                                 MOVE FUNCTION MAX(L-BERRY, 1) TO L-BERRY
                             ELSE
                                 MOVE 2 TO L-BERRY
                             END-IF
                     END-EVALUATE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   The block under the feet (getBlockPosBelowThatAffectsMyMovement: y - 0.500001) and the cell of the feet.
     COMPUTE WS-LOW = L-Y - 0.500001
     COMPUTE WS-Y = FUNCTION INTEGER(WS-LOW)
     COMPUTE WS-X = FUNCTION INTEGER(L-X)
     COMPUTE WS-Z = FUNCTION INTEGER(L-Z)
     CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
     IF WS-STATE NOT = 0 AND CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) = "magma_block"
         MOVE 1 TO L-MAGMA
     END-IF
     COMPUTE WS-Y = FUNCTION INTEGER(L-Y)
     CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
     IF WS-STATE NOT = 0 AND CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) = "powder_snow"
         MOVE 1 TO L-POWDER
     END-IF
     GOBACK.
 END PROGRAM M183-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M183-FREEZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-KEY                 PIC X(24).
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-PHASE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-POWDER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-POWDER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "polar_bear" OR "stray" OR "snow_golem" OR "wither"
         MOVE 0 TO EN-FROZEN(L-ROW)
         GOBACK
     END-IF
     IF L-POWDER = 1
         ADD 1 TO EN-FROZEN(L-ROW)
     ELSE
         COMPUTE EN-FROZEN(L-ROW) = FUNCTION MAX(0, EN-FROZEN(L-ROW) - 2)
     END-IF
     COMPUTE WS-PHASE = FUNCTION MOD(CW-TICKS, 40)
     IF EN-FROZEN(L-ROW) >= 140 AND WS-PHASE = 0
         MOVE 1 TO WS-AMOUNT
         IF WS-KEY = "blaze" OR "strider" OR "magma_cube"
             MOVE 5 TO WS-AMOUNT
         END-IF
         MOVE CAUSE-FREEZE TO WS-CAUSE
         CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
     END-IF
     GOBACK.
 END PROGRAM M183-FREEZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M183-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY RULES.
 01 WS-M                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-CACTUS              BINARY-LONG.
 01 WS-WEB                 BINARY-LONG.
 01 WS-BERRY               BINARY-LONG.
 01 WS-MAGMA               BINARY-LONG.
 01 WS-POWDER              BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
     CALL "M183-SCAN" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-HALF WS-HEIGHT WS-CACTUS WS-WEB WS-BERRY WS-MAGMA
         WS-POWDER
     CALL "M183-FREEZE" USING L-ROW WS-POWDER
     IF EN-HEALTH(L-ROW) = 0
         GOBACK
     END-IF
     IF WS-CACTUS = 1
         MOVE 1 TO WS-AMOUNT
         MOVE CAUSE-CACTUS TO WS-CAUSE
         CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
     END-IF
     IF EN-HEALTH(L-ROW) > 0 AND WS-MAGMA = 1 AND EN-ON-GROUND(L-ROW) = 1
         MOVE 1 TO WS-AMOUNT
         MOVE CAUSE-HOT-FLOOR TO WS-CAUSE
         CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
     END-IF
     IF EN-PREV-X(L-ROW) = 0 AND EN-PREV-Z(L-ROW) = 0
         MOVE EN-X(L-ROW) TO EN-PREV-X(L-ROW)
         MOVE EN-Z(L-ROW) TO EN-PREV-Z(L-ROW)
     END-IF
     COMPUTE WS-DX = FUNCTION ABS(EN-X(L-ROW) - EN-PREV-X(L-ROW))
     COMPUTE WS-DZ = FUNCTION ABS(EN-Z(L-ROW) - EN-PREV-Z(L-ROW))
     IF EN-HEALTH(L-ROW) > 0 AND WS-BERRY = 2 AND (WS-DX > 0.003 OR WS-DZ > 0.003)
         MOVE 1 TO WS-AMOUNT
         MOVE CAUSE-BERRY TO WS-CAUSE
         CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
     END-IF
     MOVE EN-X(L-ROW) TO EN-PREV-X(L-ROW)
     MOVE EN-Z(L-ROW) TO EN-PREV-Z(L-ROW)
     GOBACK.
 END PROGRAM M183-TICK.
