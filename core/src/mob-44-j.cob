*> Allay item pickup, delivery and the liked note block (002-lane-mobsa4; docs/protocol/18-mob-framework.md GoToWantedItem, 19 section 15, 44 part 4 section 14).
*> - M44-ALLAY-BRAIN USING row (called by ALLAY-TICK): the two cooldown memories count down (EN-ALLAY-CD, EN-ALLAY-NB-CD). The liked note block position is kept only while its cooldown runs, the
*>   dimension is the allay's and the block there is a note block (stand-in for shouldDepositItemsAtLikedNoteblock, whose test is not in the docs: gap), else it is erased.
*>   GoToWantedItem (first in the idle list): an allay that holds an item (EN-ALLAY-ITEM, the main hand copy) with no pickup cooldown flies (modifier 1.75) to the nearest ground item of the same
*>   item id within 32 blocks when its inventory has room; within 1 block on each axis (the pickup box is not in the docs: gap) it takes as many as fit (EN-ALLAY-COUNT, at most 64: the size of the
*>   small inventory is not in the docs: gap) and the viewers get Take Item Entity. Visibility of the item and mob griefing are not tested (gap).
*>   GoAndGiveItemsToTarget: an allay with items goes (modifier 2.25) to the liked note block when one is stored, else to the liked player (survival or creative, same dimension, closer than 64
*>   blocks); when the distance from its eyes (0.36 above the feet) to the target (the player's position or the centre of the block) is below 3.0 it throws the whole inventory stack toward
*>   the target + (0, 1, 0), the velocity being that direction (unit) x (0.2, 0.3, 0.2) (the use of the throwItem arguments is not in the docs: stand-in), and sets the pickup cooldown 60.
*>   The throw sound and the ALLAY_DROP_ITEM_ON_BLOCK trigger are not made (gap).
*> - ALLAY-NOTE-EVENT USING dim, block x, y, z, allays that heard out: a NOTE_BLOCK_PLAY game event: every allay of the dimension within the listener radius 16 of the block centre hears it
*>   (M44-ALLAY-HEAR). No program plays a note block yet (the note block rules are tables only), so nothing calls it in the server.
*> - M44-ALLAY-HEAR USING row, dim, x, y, z, heard out: an allay with a stored position within 1024 (chessboard distance, same dimension) receives no vibration; hearing the stored block again, or
*>   a first block, stores it and sets the cooldown 600.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-ALLAY-HEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEARD                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIM L-X L-Y L-Z L-HEARD.
     MOVE 0 TO L-HEARD WS-CLOSE
     IF EN-ALLAY-NB-ON(L-ROW) = 1 AND EN-ALLAY-NB-DIM(L-ROW) = L-DIM
         COMPUTE WS-DX = FUNCTION ABS(EN-ALLAY-NB-X(L-ROW) - L-X)
         COMPUTE WS-DY = FUNCTION ABS(EN-ALLAY-NB-Y(L-ROW) - L-Y)
         COMPUTE WS-DZ = FUNCTION ABS(EN-ALLAY-NB-Z(L-ROW) - L-Z)
         IF WS-DX <= 1024 AND WS-DY <= 1024 AND WS-DZ <= 1024
             MOVE 1 TO WS-CLOSE
         END-IF
     END-IF
     IF WS-CLOSE = 1
         IF EN-ALLAY-NB-X(L-ROW) = L-X AND EN-ALLAY-NB-Y(L-ROW) = L-Y AND EN-ALLAY-NB-Z(L-ROW) = L-Z
             MOVE 600 TO EN-ALLAY-NB-CD(L-ROW)
         END-IF
     ELSE
         MOVE 1 TO EN-ALLAY-NB-ON(L-ROW)
         MOVE L-DIM TO EN-ALLAY-NB-DIM(L-ROW)
         MOVE L-X TO EN-ALLAY-NB-X(L-ROW)
         MOVE L-Y TO EN-ALLAY-NB-Y(L-ROW)
         MOVE L-Z TO EN-ALLAY-NB-Z(L-ROW)
         MOVE 600 TO EN-ALLAY-NB-CD(L-ROW)
         MOVE 1 TO L-HEARD
     END-IF
     GOBACK.
 END PROGRAM M44-ALLAY-HEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ALLAY-NOTE-EVENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-D2                  FLOAT-LONG.
 01 WS-ONE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEARD                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HEARD.
     MOVE 0 TO L-HEARD
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM AND EN-HEALTH(WS-ROW) > 0
             CALL "MOB-SPECIES-KEY" USING WS-ROW WS-KEY
             IF WS-KEY = "allay"
                 COMPUTE WS-D2 = (EN-X(WS-ROW) - L-X - 0.5) ** 2 + (EN-Y(WS-ROW) - L-Y - 0.5) ** 2
                     + (EN-Z(WS-ROW) - L-Z - 0.5) ** 2
                 IF WS-D2 <= 256
                     CALL "M44-ALLAY-HEAR" USING WS-ROW L-DIM L-X L-Y L-Z WS-ONE
                     ADD WS-ONE TO L-HEARD
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ALLAY-NOTE-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-ALLAY-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-E                   BINARY-LONG.
 01 WS-ID-ITEM             BINARY-LONG.
 01 WS-ID-ME               BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-TAKE                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-HAS-TARGET          BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-NEW                 BINARY-LONG.
 01 WS-PLAYER-OK           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-ALLAY-CD(L-ROW) > 0
         SUBTRACT 1 FROM EN-ALLAY-CD(L-ROW)
     END-IF
     IF EN-ALLAY-NB-CD(L-ROW) > 0
         SUBTRACT 1 FROM EN-ALLAY-NB-CD(L-ROW)
     END-IF
     IF EN-ALLAY-NB-ON(L-ROW) = 1
         PERFORM CHECK-NOTE-BLOCK
     END-IF
     IF EN-ALLAY-ITEM(L-ROW) > 0 AND EN-ALLAY-CD(L-ROW) = 0 AND EN-ALLAY-COUNT(L-ROW) < 64
         PERFORM FIND-ITEM
         IF WS-BEST > 0
             PERFORM GO-TO-ITEM
             GOBACK
         END-IF
     END-IF
     IF EN-ALLAY-COUNT(L-ROW) > 0
         PERFORM FIND-TARGET
         IF WS-HAS-TARGET = 1
             PERFORM GO-AND-GIVE
         END-IF
     END-IF
     GOBACK.

 CHECK-NOTE-BLOCK.
     MOVE 0 TO WS-LENGTH
     IF EN-ALLAY-NB-CD(L-ROW) > 0 AND EN-ALLAY-NB-DIM(L-ROW) = EN-DIM(L-ROW)
         CALL "IP-BLOCK-KEY" USING EN-DIM(L-ROW) EN-ALLAY-NB-X(L-ROW) EN-ALLAY-NB-Y(L-ROW) EN-ALLAY-NB-Z(L-ROW) WS-KEY WS-LENGTH
     END-IF
     IF NOT (WS-LENGTH = 20 AND WS-KEY(1:20) = "minecraft:note_block")
         MOVE 0 TO EN-ALLAY-NB-ON(L-ROW)
     END-IF.

 FIND-ITEM.
     MOVE 0 TO WS-BEST
     MOVE 1025 TO WS-BEST-D2
     COMPUTE WS-ROOM = 64 - EN-ALLAY-COUNT(L-ROW)
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-ITEM(WS-E) = EN-ALLAY-ITEM(L-ROW) AND EN-ITEM-COUNT(WS-E) > 0
                 AND EN-DIM(WS-E) = EN-DIM(L-ROW)
             COMPUTE WS-D2 = (EN-X(WS-E) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-E) - EN-Y(L-ROW)) ** 2
                 + (EN-Z(WS-E) - EN-Z(L-ROW)) ** 2
             IF WS-D2 <= 1024 AND WS-D2 < WS-BEST-D2
                 MOVE WS-D2 TO WS-BEST-D2
                 MOVE WS-E TO WS-BEST
             END-IF
         END-IF
     END-PERFORM.

 GO-TO-ITEM.
     MOVE EN-X(WS-BEST) TO EN-FLY-X(L-ROW)
     MOVE EN-Y(WS-BEST) TO EN-FLY-Y(L-ROW)
     MOVE EN-Z(WS-BEST) TO EN-FLY-Z(L-ROW)
     MOVE 1.75 TO EN-FLY-MOD(L-ROW)
     MOVE 1 TO EN-FLY-ON(L-ROW)
     IF FUNCTION ABS(EN-X(WS-BEST) - EN-X(L-ROW)) <= 1 AND FUNCTION ABS(EN-Z(WS-BEST) - EN-Z(L-ROW)) <= 1
             AND FUNCTION ABS(EN-Y(WS-BEST) - EN-Y(L-ROW)) <= 1.5
         MOVE EN-ITEM-COUNT(WS-BEST) TO WS-TAKE
         IF WS-TAKE > WS-ROOM
             MOVE WS-ROOM TO WS-TAKE
         END-IF
         ADD WS-TAKE TO EN-ALLAY-COUNT(L-ROW)
         MOVE EN-ID(WS-BEST) TO WS-ID-ITEM
         MOVE EN-ID(L-ROW) TO WS-ID-ME
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "TAKE-ITEM-ENTITY-BUILD" USING WS-ID-ITEM WS-ID-ME WS-TAKE PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING WS-BEST PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
         SUBTRACT WS-TAKE FROM EN-ITEM-COUNT(WS-BEST)
         IF EN-ITEM-COUNT(WS-BEST) <= 0
             CALL "ENTITY-REMOVE" USING WS-BEST
         END-IF
     END-IF.

 FIND-TARGET.
     MOVE 0 TO WS-HAS-TARGET
     IF EN-ALLAY-NB-ON(L-ROW) = 1
         COMPUTE WS-TX = EN-ALLAY-NB-X(L-ROW) + 0.5
         COMPUTE WS-TY = EN-ALLAY-NB-Y(L-ROW) + 0.5
         COMPUTE WS-TZ = EN-ALLAY-NB-Z(L-ROW) + 0.5
         MOVE 1 TO WS-HAS-TARGET
     ELSE
         IF EN-ALLAY-LIKED(L-ROW) NOT = SPACES
             PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR WS-HAS-TARGET = 1
                 IF PL-USED(WS-P) = 1 AND PL-UUID(WS-P) = EN-ALLAY-LIKED(L-ROW) AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                         AND PL-MODE(WS-P) < 2
                     COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2
                         + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
                     IF WS-D2 < 4096
                         MOVE PL-X(WS-P) TO WS-TX
                         MOVE PL-Y(WS-P) TO WS-TY
                         MOVE PL-Z(WS-P) TO WS-TZ
                         MOVE 1 TO WS-HAS-TARGET
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-IF.

 GO-AND-GIVE.
     MOVE EN-X(L-ROW) TO WS-OX
     COMPUTE WS-OY = EN-Y(L-ROW) + 0.36
     MOVE EN-Z(L-ROW) TO WS-OZ
     COMPUTE WS-D2 = (WS-TX - WS-OX) ** 2 + (WS-TY - WS-OY) ** 2 + (WS-TZ - WS-OZ) ** 2
     IF WS-D2 < 9
         COMPUTE WS-DX = WS-TX - WS-OX
         COMPUTE WS-DY = WS-TY + 1 - WS-OY
         COMPUTE WS-DZ = WS-TZ - WS-OZ
         COMPUTE WS-LEN = FUNCTION SQRT(WS-DX ** 2 + WS-DY ** 2 + WS-DZ ** 2)
         MOVE 0 TO WS-VX WS-VY WS-VZ
         IF WS-LEN > 0
             COMPUTE WS-VX = WS-DX / WS-LEN * 0.2
             COMPUTE WS-VY = WS-DY / WS-LEN * 0.3
             COMPUTE WS-VZ = WS-DZ / WS-LEN * 0.2
         END-IF
         CALL "GI-SPAWN" USING EN-DIM(L-ROW) WS-OX WS-OY WS-OZ WS-VX WS-VY WS-VZ EN-ALLAY-ITEM(L-ROW) EN-ALLAY-COUNT(L-ROW)
             WS-DELAY WS-NEW
         MOVE 0 TO EN-ALLAY-COUNT(L-ROW)
         MOVE 60 TO EN-ALLAY-CD(L-ROW)
     ELSE
         MOVE WS-TX TO EN-FLY-X(L-ROW)
         MOVE WS-TY TO EN-FLY-Y(L-ROW)
         MOVE WS-TZ TO EN-FLY-Z(L-ROW)
         MOVE 2.25 TO EN-FLY-MOD(L-ROW)
         MOVE 1 TO EN-FLY-ON(L-ROW)
     END-IF.
 END PROGRAM M44-ALLAY-BRAIN.
