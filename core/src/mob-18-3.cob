*> The block effects and freezing of a standard mob (docs/protocol/18-mob-framework.md sections 2.6 step 11 and 3.3; lane p49a).
*>
*>   M183-SCAN USING dim, x, y, z, half width, height (FLOAT-LONG), cactus, web, berry, magma, powder out (BINARY-LONG)   the blocks of the entity's box: a cactus or a
*>       cobweb in it, a sweet berry bush (1 young, 2 grown), a magma block under its feet and powder snow in the cell of its feet
*>   M183-FREEZE USING tracker row, in powder snow (BINARY-LONG)   ticksFrozen: +1 in powder snow, -2 otherwise (never below 0); fully frozen (140) takes 1.0 freeze damage
*>       (5.0 for blaze, strider and magma cube) on every 40th tick; polar bear, stray, snow golem and wither cannot freeze
*>   M183-ARROWS-TICK USING tracker row   the stuck-arrow counter (18 section 2.3 step 3): above 0 a timer of 20 x (30 - count) ticks counts down and at 0 the count drops by one;
*>       a changed count is sent to the viewers as metadata 12 (INT)
*>   M183-CONVERT USING tracker row, converted out (1 when the row was replaced)   the conversion tracker of a skeleton in powder snow (20 section 3.8, 18 section 4.10): afflicted for 140 ticks it starts converting,
*>       300 ticks later (the count below 0) it is replaced by a stray with its equipment; the counters reset when the condition stops
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M183-CONVERT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-CACTUS              BINARY-LONG.
 01 WS-WEB                 BINARY-LONG.
 01 WS-BERRY               BINARY-LONG.
 01 WS-MAGMA               BINARY-LONG.
 01 WS-POWDER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-DIM                 BINARY-LONG.
 01 WS-EQUIP               BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-WEAR                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DONE.
     MOVE 0 TO L-DONE
     IF EN-NO-AI(L-ROW) = 1
         GOBACK
     END-IF
     COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
     CALL "M183-SCAN" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-HALF WS-HEIGHT WS-CACTUS WS-WEB WS-BERRY WS-MAGMA
         WS-POWDER
     IF WS-POWDER = 0
         IF EN-CONVERTING(L-ROW) = 1
             MOVE 2 TO EN-CONVERTING(L-ROW)
             CALL "STDMOB-VARIANT-SEND" USING L-ROW
         END-IF
         MOVE 0 TO EN-AFFLICT(L-ROW) EN-CONVERTING(L-ROW) EN-CONVERT-LEFT(L-ROW)
         GOBACK
     END-IF
     IF EN-CONVERTING(L-ROW) = 0
         ADD 1 TO EN-AFFLICT(L-ROW)
         IF EN-AFFLICT(L-ROW) >= 140
             MOVE 1 TO EN-CONVERTING(L-ROW)
             MOVE 300 TO EN-CONVERT-LEFT(L-ROW)
             CALL "STDMOB-VARIANT-SEND" USING L-ROW
         END-IF
         GOBACK
     END-IF
     SUBTRACT 1 FROM EN-CONVERT-LEFT(L-ROW)
     IF EN-CONVERT-LEFT(L-ROW) >= 0
         GOBACK
     END-IF
*>   convertTo: a stray at the same place and rotation, the equipment kept.
     MOVE "minecraft:stray" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE EN-YAW(L-ROW) TO WS-YAW
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-EQUIP(L-ROW) TO WS-EQUIP
     MOVE EN-HAND(L-ROW) TO WS-HAND
     MOVE EN-HEAD-WEAR(L-ROW) TO WS-WEAR
     CALL "ENTITY-REMOVE" USING L-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
     MOVE WS-EQUIP TO EN-EQUIP(WS-NEW)
     MOVE WS-HAND TO EN-HAND(WS-NEW)
     MOVE WS-WEAR TO EN-HEAD-WEAR(WS-NEW)
     CALL "STDMOB-EQUIP-SEND" USING WS-NEW
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM M183-CONVERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M183-ARROWS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-ARROWS(L-ROW) > 0
         IF EN-ARROW-TIMER(L-ROW) <= 0
             COMPUTE EN-ARROW-TIMER(L-ROW) = 20 * (30 - EN-ARROWS(L-ROW))
         END-IF
         SUBTRACT 1 FROM EN-ARROW-TIMER(L-ROW)
         IF EN-ARROW-TIMER(L-ROW) <= 0
             SUBTRACT 1 FROM EN-ARROWS(L-ROW)
         END-IF
     END-IF
     IF EN-ARROWS(L-ROW) NOT = EN-ARROWS-SENT(L-ROW)
         MOVE EN-ARROWS(L-ROW) TO EN-ARROWS-SENT(L-ROW)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
         INITIALIZE MD-METADATA-ENTRY
         MOVE 12 TO MD-MD-INDEX
         MOVE MD-MDS-INT TO MD-MD-SERIALIZER
         MOVE EN-ARROWS(L-ROW) TO MD-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
         MOVE MD-MD-END TO MD-MD-INDEX
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM M183-ARROWS-TICK.
