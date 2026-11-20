*> Using and editing signs in the live world (docs/protocol/31-block-entities-3-signs-banners-skulls-pots-shelves.md sections 2.4 to 2.9; 05a 0x3D Open Sign Editor,
*> 0x06 Block Entity Data; 05c 0x3E Sign Update): the wiring of the sign rules of core/src/be-31-3.cob into Use Item On, block placement, the serverbound Sign Update and the
*> tick. A sign is any block whose block entity type is 7 (sign) or 8 (hanging sign).
*>
*>   SIGN-USE USING connection id, PLAY-SERVERBOUND (Use Item On), block state, handled out    BLOCK-USE-ON: a sign takes the click (2.5, 2.6); a sneaking player holding an item
*>        places it instead (handled 0). An applicator (dye, ink sac, glow ink sac, honeycomb) is tried first (BE3-SIGN-USE-ITEM), then the empty hand (BE3-SIGN-USE-EMPTY):
*>        the editor opens for the side the player faces. The sounds and level event 3003 of the applicators are not sent.
*>   SIGN-PLACED USING connection id, dimension row, x, y, z, state    BLOCK-PLACE: the placer's editor opens for the front side (2.6, setPlacedBy)
*>   SIGN-OPEN-EDITOR USING connection id, x, y, z, side (0 back, 1 front)    Block Update of the sign to the player, then Open Sign Editor
*>   SIGN-UPDATE-PACKET USING connection id, PLAY-SERVERBOUND (Sign Update)    2.8: the lines are stored when the player holds the editor lock, then Block Entity Data goes out
*>   SIGN-SEND USING block entity index    Block Entity Data of the sign (its update tag) to the players who have the chunk in view
*>   SIGN-LOCK-TICK USING block entity index    2.9: the editor lock ends when its player is gone or farther than 4.0 from the sign (BE-TICK-ALL)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-PACKET-ID           BINARY-LONG VALUE 6.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "BE-DATA-PACKET" USING L-INDEX PB-BUFFER WS-WRITTEN
     IF WS-WRITTEN = 1 AND PB-ERROR = 0 AND BE-DIM(L-INDEX) > 0
         COMPUTE WS-CX = FUNCTION INTEGER(BE-X(L-INDEX) / 16)
         COMPUTE WS-CZ = FUNCTION INTEGER(BE-Z(L-INDEX) / 16)
         CALL "VIEWERS-SEND" USING BE-DIM(L-INDEX) WS-CX WS-CZ WS-NONE PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM SIGN-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-OPEN-EDITOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 61.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z L-SIDE.
     CALL "BLOCK-TELL" USING L-ID L-X L-Y L-Z
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SIDE
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM SIGN-OPEN-EDITOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-PLACED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY BESTATE.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-SIDE                BINARY-LONG VALUE 1.
 01 WS-MAY-BUILD           BINARY-LONG VALUE 1.
 01 WS-RAN                 BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-UUID                PIC X(16).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-DIM L-X L-Y L-Z L-STATE.
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     CALL "BE-BLOCK-TYPE" USING WS-BLOCK WS-TYPE
     IF WS-TYPE NOT = 7 AND WS-TYPE NOT = 8
         GOBACK
     END-IF
     CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-BE
     IF WS-BE = 0
         GOBACK
     END-IF
     MOVE PL-UUID(CN-PLAYER(L-ID)) TO WS-UUID
     CALL "BE3-SIGN-USE-EMPTY" USING WS-BE WS-SIDE WS-UUID WS-MAY-BUILD WS-RAN WS-RESULT WS-ACTION
     IF WS-ACTION = 2
         CALL "SIGN-OPEN-EDITOR" USING L-ID L-X L-Y L-Z WS-SIDE
     END-IF
     GOBACK.
 END PROGRAM SIGN-PLACED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-UPDATE-PACKET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-UUID                PIC X(16).
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "BE-FIND" USING PL-DIM(WS-ROW) PSB-BX PSB-BY PSB-BZ WS-BE
     IF WS-BE = 0
         GOBACK
     END-IF
     IF BE-TYPE(WS-BE) NOT = 7 AND BE-TYPE(WS-BE) NOT = 8
         GOBACK
     END-IF
     CALL "BE3-SLOT-DECODE" USING PSB-DATA WS-SIDE
     MOVE PL-UUID(WS-ROW) TO WS-UUID
     CALL "BE3-SIGN-UPDATE" USING WS-BE WS-SIDE WS-UUID PSB-SIGN-LINES WS-RESULT
     IF WS-RESULT = 1
         CALL "SIGN-SEND" USING WS-BE
     END-IF
     GOBACK.
 END PROGRAM SIGN-UPDATE-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-ITEM-KIND.
*> USING item id, kind out (1 dye, 2 ink sac, 3 glow ink sac, 4 honeycomb, 0 no applicator), dye id out (-1 none): the sign applicators of 2.5 by the item's key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-KIND L-DYE.
     MOVE 0 TO L-KIND
     MOVE -1 TO L-DYE
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE IT-KEY(L-ITEM + 1) TO WS-KEY
     MOVE IT-KEY-LENGTH(L-ITEM + 1) TO WS-LENGTH
     IF WS-LENGTH > 10 AND WS-KEY(1:10) = "minecraft:"
         COMPUTE WS-LENGTH = WS-LENGTH - 10
         MOVE WS-KEY(11:WS-LENGTH) TO WS-NAME
         MOVE SPACES TO WS-KEY
         MOVE WS-NAME(1:WS-LENGTH) TO WS-KEY
     END-IF
     EVALUATE TRUE
         WHEN WS-KEY = "honeycomb"
             MOVE 4 TO L-KIND
         WHEN WS-KEY = "ink_sac"
             MOVE 2 TO L-KIND
         WHEN WS-KEY = "glow_ink_sac"
             MOVE 3 TO L-KIND
         WHEN WS-LENGTH > 4 AND WS-KEY(WS-LENGTH - 3:4) = "_dye"
             COMPUTE WS-NAME-LENGTH = WS-LENGTH - 4
             MOVE SPACES TO WS-NAME
             MOVE WS-KEY(1:WS-NAME-LENGTH) TO WS-NAME
             CALL "BE3-DYE-ID" USING WS-NAME WS-NAME-LENGTH L-DYE
             IF L-DYE >= 0
                 MOVE 1 TO L-KIND
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SIGN-ITEM-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-FACE-SIDE.
*> USING connection id, block state, x, y, z, side out (0 back, 1 front): 2.4 getSlotPlayerIsFacing. The yaw of a sign is its rotation property times 22.5 degrees (standing signs, ceiling
*> hanging signs) or the yaw of its facing (south 0, west 90, north 180, east 270); a wall sign's hitbox centre is the middle of its plate, against the wall opposite its facing
*> (0.9375 from the facing side's opposite edge for a facing of north or west, 0.0625 for south or east; the other coordinate 0.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-BI                  BINARY-LONG.
 01 WS-HANGING             BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-SIGN                BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-ROT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-STATE L-X L-Y L-Z L-SIDE.
     MOVE 1 TO L-SIDE
     MOVE 0 TO WS-SIGN
     MOVE 0.5 TO WS-CX WS-CZ
     MOVE 0 TO WS-YAW
     MOVE "rotation" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-SIGN
         COMPUTE WS-ROT = FUNCTION NUMVAL(WS-TEXT)
         COMPUTE WS-YAW = WS-ROT * 22.5
     ELSE
         MOVE "facing" TO WS-NAME
         CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-FOUND
         IF WS-FOUND = 1
             MOVE 1 TO WS-SIGN
             EVALUATE WS-TEXT
                 WHEN "west"
                     MOVE 90 TO WS-YAW
                     MOVE 0.9375 TO WS-CX
                 WHEN "north"
                     MOVE 180 TO WS-YAW
                     MOVE 0.9375 TO WS-CZ
                 WHEN "east"
                     MOVE 270 TO WS-YAW
                     MOVE 0.0625 TO WS-CX
                 WHEN OTHER
                     MOVE 0.0625 TO WS-CZ
             END-EVALUATE
*>           A wall hanging sign has no plate: the centre of its cell.
             COMPUTE WS-BI = CB-S-BLOCK(L-STATE + 1) + 1
             MOVE 0 TO WS-HANGING
             INSPECT CB-KEY(WS-BI) TALLYING WS-HANGING FOR ALL "hanging"
             IF WS-HANGING > 0
                 MOVE 0.5 TO WS-CX WS-CZ
             END-IF
         END-IF
     END-IF
     MOVE PL-X(CN-PLAYER(L-ID)) TO WS-PX
     MOVE PL-Z(CN-PLAYER(L-ID)) TO WS-PZ
     CALL "BE3-SIGN-FACING" USING WS-SIGN WS-PX WS-PZ L-X L-Z WS-CX WS-CZ WS-YAW L-SIDE
     GOBACK.
 END PROGRAM SIGN-FACE-SIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-MAY-BUILD           BINARY-LONG VALUE 1.
 01 WS-RAN                 BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-UUID                PIC X(16).
 01 WS-ITEM-KEY            PIC X(48).
 01 WS-CHAIN-SUFFIX        PIC X(24) VALUE "hanging_sign".
 01 WS-CHAIN               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-STATE L-HANDLED.
     MOVE 0 TO L-HANDLED
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     CALL "BE-BLOCK-TYPE" USING WS-BLOCK WS-TYPE
     IF WS-TYPE NOT = 7 AND WS-TYPE NOT = 8
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     CALL "BE-FIND" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-BE
     IF WS-BE = 0
         GOBACK
     END-IF
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     MOVE 0 TO WS-ITEM
     IF PSB-HAND = 0 AND PL-SLOT-COUNT(WS-ROW, WS-HELD + 1) > 0
         MOVE PL-SLOT-ITEM(WS-ROW, WS-HELD + 1) TO WS-ITEM
     END-IF
*>   A sneaking player holding an item uses the item on the block instead (31-1 section 10.2).
     IF PL-SNEAKING(WS-ROW) = 1 AND WS-ITEM > 0
         GOBACK
     END-IF
*>   A hanging sign item used on the underside of a hanging sign chains another one instead of opening the editor (24 part 3, shouldTryToChainAnotherHangingSign: the clicked
*>   face is DOWN and the item is a hanging sign item; the click commands of the side are not modelled).
     IF WS-TYPE = 8 AND PSB-FACE = 0 AND WS-ITEM > 0
         MOVE IT-KEY(WS-ITEM + 1) TO WS-ITEM-KEY
         CALL "PS-ENDS" USING WS-ITEM-KEY WS-CHAIN-SUFFIX WS-CHAIN
         IF WS-CHAIN = 1
             GOBACK
         END-IF
     END-IF
     MOVE 1 TO L-HANDLED
     MOVE PL-UUID(WS-ROW) TO WS-UUID
     CALL "SIGN-FACE-SIDE" USING L-ID L-STATE PSB-BX PSB-BY PSB-BZ WS-SIDE
     CALL "SIGN-ITEM-KIND" USING WS-ITEM WS-KIND WS-DYE
     IF WS-KIND > 0
         CALL "BE3-SIGN-USE-ITEM" USING WS-BE WS-KIND WS-DYE WS-SIDE WS-MAY-BUILD WS-UUID WS-RESULT WS-EVENT
         IF WS-RESULT = 1
             IF PL-MODE(WS-ROW) NOT = 1
                 CALL "INV-REMOVE" USING WS-ROW WS-HELD WS-ONE
                 COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
                 CALL "INV-SLOT-SEND" USING L-ID WS-HELD
             END-IF
             CALL "SIGN-SEND" USING WS-BE
             GOBACK
         END-IF
     END-IF
     CALL "BE3-SIGN-USE-EMPTY" USING WS-BE WS-SIDE WS-UUID WS-MAY-BUILD WS-RAN WS-RESULT WS-ACTION
     IF WS-ACTION = 2
         CALL "SIGN-OPEN-EDITOR" USING L-ID PSB-BX PSB-BY PSB-BZ WS-SIDE
     END-IF
     GOBACK.
 END PROGRAM SIGN-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-LOCK-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-WITHIN              BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     IF BE-XI(L-INDEX, 3) NOT = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-PRESENT WS-WITHIN
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-UUID(WS-P) = BE-XT(L-INDEX, 17)(1:16) AND PL-DIM(WS-P) = BE-DIM(L-INDEX)
             MOVE 1 TO WS-PRESENT
             COMPUTE WS-EYE = PL-Y(WS-P) + 1.62
             MOVE PL-X(WS-P) TO WS-PX
             MOVE PL-Z(WS-P) TO WS-PZ
             MOVE BE-X(L-INDEX) TO WS-BX
             MOVE BE-Y(L-INDEX) TO WS-BY
             MOVE BE-Z(L-INDEX) TO WS-BZ
             MOVE 0 TO WS-DX WS-DY WS-DZ
             IF WS-PX < WS-BX
                 COMPUTE WS-DX = WS-BX - WS-PX
             END-IF
             IF WS-PX > WS-BX + 1
                 COMPUTE WS-DX = WS-PX - WS-BX - 1
             END-IF
             IF WS-EYE < WS-BY
                 COMPUTE WS-DY = WS-BY - WS-EYE
             END-IF
             IF WS-EYE > WS-BY + 1
                 COMPUTE WS-DY = WS-EYE - WS-BY - 1
             END-IF
             IF WS-PZ < WS-BZ
                 COMPUTE WS-DZ = WS-BZ - WS-PZ
             END-IF
             IF WS-PZ > WS-BZ + 1
                 COMPUTE WS-DZ = WS-PZ - WS-BZ - 1
             END-IF
             COMPUTE WS-LOW = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-LOW <= 16
                 MOVE 1 TO WS-WITHIN
             END-IF
         END-IF
     END-PERFORM
     CALL "BE3-SIGN-TICK" USING L-INDEX WS-PRESENT WS-WITHIN
     GOBACK.
 END PROGRAM SIGN-LOCK-TICK.
