*> Farmland turns to dirt when a living entity lands on it (docs/protocol/29b part 2 section 9: FarmlandBlock.fallOn, turnToBaseBlock, Block.pushEntitiesUp; CC-0012).
*>
*> GAME-EVENT-FALL (game-events-move.cob) is where an entity that lands on the ground with a fall distance above 0 reaches Block.fallOn; it notes the row and the distance (FARMLAND.cpy)
*> because the move is not stored yet. The callers of ENTITY-MOVE that can land on farmland (MOVE-PLAYER for players, MOB-PHYSICS for the standard mobs) call FARM-LANDED right after it:
*>   FARM-LANDED USING entity row
*>     when the row's landing was noted and the block under its feet (the cell of y - 0.2, the legacy cell of Entity.checkFallDamage) is farmland: one nextFloat draw of the level random,
*>     then GB2-FARM-TRAMPLE (the draw is less than d - 0.5, the entity is a LivingEntity, a player is outside spawn protection, any other entity needs the game rule mob_griefing, the box
*>     satisfies width x width x height > 0.512); on a trample the cell becomes dirt (BLOCK-CHANGE: flags 3, so the crop above loses its ground), the game event block_change is posted and every
*>     entity whose box overlaps the top 1/16 of the cell is lifted onto the dirt (pushEntitiesUp, 9.5; a player by a Player Position, CMD-MOVE-PLAYER).
*>   Gaps: spawn protection is not modelled in the core (as for the turtle egg, mob-44-t.cob): a player is never protected. The fall damage of the same landing is the caller's own.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FARM-LANDED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 COPY FARMLAND.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-LIVING              BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-WIDTH                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-GRIEF-RULE          PIC X(40) VALUE "mob_griefing".
 01 WS-GRIEF               BINARY-DOUBLE.
 01 WS-DIRT-KEY            PIC X(112) VALUE "dirt".
 01 WS-PAIRS               PIC X(160).
 01 WS-DIRT                BINARY-LONG.
 01 WS-EV-CHANGE           PIC X(32) VALUE "block_change".
 01 WS-IN.
    05 WS-IN-SERVER        BINARY-LONG VALUE 1.
    05 WS-IN-DRAW          BINARY-LONG.
    05 WS-IN-D             BINARY-LONG.
    05 WS-IN-LIVING        BINARY-LONG.
    05 WS-IN-PLAYER        BINARY-LONG.
    05 WS-IN-PROTECTED     BINARY-LONG VALUE 0.
    05 WS-IN-GRIEF         BINARY-LONG.
    05 WS-IN-W             BINARY-LONG.
    05 WS-IN-H             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 7 TIMES.
 01 WS-OUT.
    05 WS-OUT-TRAMPLED     BINARY-LONG.
    05 WS-OUT-DRAWN        BINARY-LONG.
    05 WS-OUT-DAMAGE       BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF FT-LAND-ROW NOT = L-ROW
         GOBACK
     END-IF
     MOVE FT-LAND-D TO WS-D
     MOVE 0 TO FT-LAND-ROW
     MOVE EN-DIM(L-ROW) TO WS-DIM
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW) - 0.2)
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "IP-BLOCK-KEY" USING WS-DIM WS-BX WS-BY WS-BZ WS-KEY WS-LENGTH
     IF WS-LENGTH NOT = 18 OR WS-KEY(1:18) NOT = "minecraft:farmland"
         GOBACK
     END-IF
*>   The draw first, then the entity tests (9.3).
     CALL "LEVEL-RANDOM-FLOAT" USING WS-F
     COMPUTE WS-IN-DRAW = WS-F * 1000000
     COMPUTE WS-IN-D ROUNDED = WS-D * 1000
     MOVE EN-PLAYER(L-ROW) TO WS-PLAYER
     MOVE 0 TO WS-IN-LIVING WS-IN-PLAYER WS-IN-GRIEF WS-BABY
     IF WS-PLAYER > 0
         MOVE 1 TO WS-IN-LIVING WS-IN-PLAYER
         CALL "MOVE-POSE-BOX" USING PL-POSE(WS-PLAYER) WS-WIDTH WS-HEIGHT
*>       MOVE-POSE-BOX gives the half width.
         COMPUTE WS-WIDTH = WS-WIDTH * 2
     ELSE
         CALL "ENTITY-IS-LIVING" USING L-ROW WS-LIVING
         IF WS-LIVING > 0
             MOVE 1 TO WS-IN-LIVING
         END-IF
         COMPUTE WS-WIDTH = ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) / 1000
         COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
*>       A baby has half the box: the animals by the baby flag (MOB-DATA-VALUES), the zombie family by its variant 1 (STDMOB-VARIANT-BUILD).
         CALL "MOB-DATA-VALUES" USING L-ROW WS-BABY WS-WOOL WS-NEEDED
         CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
         IF WS-M > 0 AND EN-VARIANT(L-ROW) = 1 AND (SM-KEY(WS-M) = "zombie" OR "zombie_villager" OR "husk")
             MOVE 1 TO WS-BABY
         END-IF
         IF WS-BABY = 1
             COMPUTE WS-WIDTH = WS-WIDTH / 2
             COMPUTE WS-HEIGHT = WS-HEIGHT / 2
         END-IF
     END-IF
     CALL "BR-RULE-GET" USING WS-GRIEF-RULE WS-GRIEF
     MOVE WS-GRIEF TO WS-IN-GRIEF
     COMPUTE WS-IN-W ROUNDED = WS-WIDTH * 100
     COMPUTE WS-IN-H ROUNDED = WS-HEIGHT * 100
     CALL "GB2-FARM-TRAMPLE" USING WS-IN WS-OUT
     IF WS-OUT-TRAMPLED = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-DIRT-KEY WS-PAIRS WS-DIRT
     CALL "BLOCK-CHANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-DIRT
     CALL "GAME-EVENT-CELL" USING WS-DIM WS-BX WS-BY WS-BZ WS-EV-CHANGE L-ROW WS-DIRT
     CALL "FARM-PUSH-UP" USING WS-DIM WS-BX WS-BY WS-BZ
     GOBACK.
 END PROGRAM FARM-LANDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FARM-PUSH-UP.
*> USING dimension row, cell x, y, z (BINARY-LONG): Block.pushEntitiesUp of the farmland that became dirt (29b part 2 section 9.5): the delta is the top 1/16 of the cell; every entity whose
*> box overlaps it is lifted onto the dirt (a player by Player Position). A box lies from its feet up the height of its type (a player: of its pose), centred on its position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-E                   BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-BOTTOM              FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-LAYER               FLOAT-LONG.
 01 WS-CEILING             FLOAT-LONG.
 01 WS-NEW-Y               FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     COMPUTE WS-LAYER = L-Y + 0.9375
     COMPUTE WS-CEILING = L-Y + 1
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = L-DIM
             MOVE EN-PLAYER(WS-E) TO WS-PLAYER
             IF WS-PLAYER > 0
                 CALL "MOVE-POSE-BOX" USING PL-POSE(WS-PLAYER) WS-HALF WS-HEIGHT
             ELSE
                 COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
                 COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
             END-IF
             MOVE EN-Y(WS-E) TO WS-BOTTOM
             COMPUTE WS-TOP = EN-Y(WS-E) + WS-HEIGHT
             IF EN-X(WS-E) + WS-HALF > L-X AND EN-X(WS-E) - WS-HALF < L-X + 1
                     AND EN-Z(WS-E) + WS-HALF > L-Z AND EN-Z(WS-E) - WS-HALF < L-Z + 1
                     AND WS-BOTTOM < WS-CEILING AND WS-TOP > WS-LAYER
                 MOVE WS-CEILING TO WS-NEW-Y
                 IF WS-PLAYER > 0
                     MOVE PL-X(WS-PLAYER) TO WS-FX
                     MOVE PL-Z(WS-PLAYER) TO WS-FZ
                     CALL "CMD-MOVE-PLAYER" USING WS-PLAYER PL-DIM(WS-PLAYER) WS-FX WS-NEW-Y WS-FZ
                 ELSE
                     MOVE WS-NEW-Y TO EN-Y(WS-E)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FARM-PUSH-UP.
