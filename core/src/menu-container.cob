*> The container menus of the chest family in the live window of a player (docs/protocol/40-menus-1-model-and-containers.md sections 3 to 8,
*> 31-1 sections 8 to 13; US12): chest, trapped chest, double chest (generic_9x3 and generic_9x6), ender chest, barrel (generic_9x3) and
*> shulker box (shulker_box), over the block entities of CORE-BE. A container menu is the player's menu when MN-WINDOW > 0 and
*> MN-CSIZE > 0 (CMENU.cpy; also the hopper menu with 5 slots, type 16, and the dispenser and dropper menu with 9, type 6, which count no openers): menu slots 0 to MN-CSIZE - 1 are the container's, then the 27 main inventory slots and the 9 hotbar slots
*> (the slot table M2 of 40-1 section 7.2 and 8.2); MENU-LOCATE names a container slot with the kind 6 and the index slot + 1. A double chest
*> is the first half's 27 slots then the second half's, the right half of the pair first (31-1 section 10.2: BE-CHEST-MERGE).
*>
*> Opening (Use Item On a container block, BLOCK-USE-ON): a chest with a conductor block above it, or a double chest with either half so,
*> does not open; a menu already open is closed first; the container id is the next of the cycle 1 to 100 (40-1 section 4.1); startOpen
*> counts an opener on every entity and runs the effects of BEFX.cpy (Block Event 1 with the opener count to the viewers of the chunk, the
*> open property of a barrel, the sound); Open Screen (the entity's custom name as a literal text, else its default name or container.chestDouble) and
*> Container Set Content follow. The open and close sounds of BEFX.cpy are sent as Sound packets (BE-SOUND-SEND); its game events are not.
*> The menu is checked every tick (MENU-STILL-VALID): its block entities must still be there and the player within 4.5 + 4.0 blocks.
*>
*> Entry points:
*>   MENU-SLOT-COUNT USING player row, count out        46 for the inventory menu and the bench, own slots + 36 for a container menu
*>   MENU-IS-CONT USING block state, family out         0 none, 1 chest or trapped chest, 2 ender chest, 3 barrel, 4 shulker box
*>   MENU-CONT-GET USING row, own slot (0-based), item out, count out, patch handle out
*>   MENU-CONT-SET USING row, own slot, item, count, patch handle      (count 0 empties; the entity and its chunk are marked unsaved)
*>   MENU-CONT-OPEN USING connection id, x, y, z, opened out           the open rules above
*>   MENU-CONT-STOP USING player row                                   stopOpen on every entity, the menu stops being a container menu
*>   MENU-CONT-VALID USING player row, valid out                       the entities are still there (the reach is MENU-STILL-VALID's)
*>   MENU-CONT-QUICK-MOVE USING row, menu slot, item out, count out    quickMoveStack of 40-1 section 7.3 and 8.3
*>   MENU-CONT-FX USING index, dim, BE-FX                                      sends the effects of a change of the opener count

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SLOT-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-COUNT.
     MOVE 46 TO L-COUNT
     IF MN-WINDOW(L-ROW) > 0 AND MN-CSIZE(L-ROW) > 0
         COMPUTE L-COUNT = MN-CSIZE(L-ROW) + 36
     END-IF
     GOBACK.
 END PROGRAM MENU-SLOT-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-IS-CONT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FAMILY.
     CALL "BE-STATE-FIELDS" USING L-STATE L-FAMILY WS-DIR WS-TYPE WS-FLAG
     IF L-FAMILY = 7
         MOVE 0 TO L-FAMILY
     END-IF
     GOBACK.
 END PROGRAM MENU-IS-CONT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CONT-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 COPY BESTATE.
 01 WS-BE                  BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE MN-CBE1(L-ROW) TO WS-BE
     MOVE L-SLOT TO WS-LOCAL
     IF MN-CBE2(L-ROW) > 0
         CALL "BE-DOUBLE-SLOT" USING L-SLOT WS-HALF WS-LOCAL
         IF WS-HALF = 2
             MOVE MN-CBE2(L-ROW) TO WS-BE
         END-IF
     END-IF
     MOVE BE-SLOT-ITEM(WS-BE, WS-LOCAL + 1) TO L-ITEM
     MOVE BE-SLOT-COUNT(WS-BE, WS-LOCAL + 1) TO L-COUNT
     MOVE BE-SLOT-VAR(WS-BE, WS-LOCAL + 1) TO L-VAR
     GOBACK.
 END PROGRAM MENU-CONT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CONT-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 COPY BESTATE.
 01 WS-BE                  BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE MN-CBE1(L-ROW) TO WS-BE
     MOVE L-SLOT TO WS-LOCAL
     IF MN-CBE2(L-ROW) > 0
         CALL "BE-DOUBLE-SLOT" USING L-SLOT WS-HALF WS-LOCAL
         IF WS-HALF = 2
             MOVE MN-CBE2(L-ROW) TO WS-BE
         END-IF
     END-IF
     MOVE L-ITEM TO BE-SLOT-ITEM(WS-BE, WS-LOCAL + 1)
     MOVE L-COUNT TO BE-SLOT-COUNT(WS-BE, WS-LOCAL + 1)
     MOVE L-VAR TO BE-SLOT-VAR(WS-BE, WS-LOCAL + 1)
     CALL "BE-MARK-CHUNK" USING WS-BE
     GOBACK.
 END PROGRAM MENU-CONT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CONT-FX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 7.
 01 WS-EVENT               BINARY-LONG VALUE 1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 COPY BEFX.
 PROCEDURE DIVISION USING L-INDEX L-DIM BE-FX.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     IF FX-BLOCK-EVENT >= 0
         CALL "BE-TRIGGER-EVENT" USING L-INDEX WS-EVENT FX-BLOCK-EVENT WS-HANDLED
         COMPUTE WS-CX = (BE-X(L-INDEX) - FUNCTION MOD(BE-X(L-INDEX), 16)) / 16
         COMPUTE WS-CZ = (BE-Z(L-INDEX) - FUNCTION MOD(BE-Z(L-INDEX), 16)) / 16
         CALL "PB-RESET" USING PB-BUFFER
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-BLOCK-EVENT" USING PB-BUFFER BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-EVENT
             FX-BLOCK-EVENT WS-BLOCK
         CALL "VIEWERS-SEND" USING L-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
     END-IF
     IF FX-SOUND > 0
         CALL "BE-SOUND-SEND" USING L-DIM BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) FX-SOUND BE-TYPE(L-INDEX)
     END-IF
     IF FX-PROP >= 0
         CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAMILY WS-DIR WS-TYPE WS-FLAG
         IF WS-FLAG NOT = FX-PROP
             CALL "BE-STATE-MAKE" USING WS-BLOCK WS-DIR WS-TYPE FX-PROP WS-NEW
             CALL "BLOCK-CHANGE" USING L-DIM BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-NEW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MENU-CONT-FX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CONT-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY BEFX.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-PACKET-ID           BINARY-LONG VALUE 60.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-SECOND              BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-CONDUCTOR           BINARY-LONG.
 01 WS-NO-CAT              BINARY-LONG VALUE 0.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-NOTIFY              BINARY-LONG.
 01 WS-SPECTATOR           BINARY-LONG.
 01 WS-RANGE               BINARY-LONG VALUE 4500.
 01 WS-MENU-TYPE           BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-DEFAULT             PIC X(32).
 01 WS-KEY                 PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-YES                BINARY-LONG VALUE 1.
 01 WS-STORE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OPENED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z L-OPENED.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE 0 TO L-OPENED WS-BE WS-BE2 WS-BLOCKED
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     CALL "WORLD-GET-BLOCK" USING WS-DIM L-X L-Y L-Z WS-STATE
     CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAMILY WS-DIR WS-TYPE WS-FLAG
     IF WS-FAMILY = 0
         GOBACK
     END-IF
     CALL "BE-FIND" USING WS-DIM L-X L-Y L-Z WS-BE
     IF WS-BE = 0
         GOBACK
     END-IF
     MOVE WS-BE TO WS-STORE
     IF WS-FAMILY = 2
         CALL "BE-ENDER-GET" USING PL-UUID(WS-ROW) WS-YES WS-STORE
         IF WS-STORE = 0
             GOBACK
         END-IF
     END-IF
*>   A conductor block above a chest or an ender chest keeps it closed (a double chest: either half).
     IF WS-FAMILY = 1 OR WS-FAMILY = 2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 1
             MOVE 0 TO WS-CONDUCTOR
             COMPUTE WS-Y1 = L-Y + 1
             MOVE L-X TO WS-PX
             MOVE L-Z TO WS-PZ
             IF WS-I = 1 AND WS-FAMILY = 1 AND WS-TYPE NOT = 0
                 CALL "BE-CHEST-CONNECTED" USING WS-DIR WS-TYPE WS-DX WS-DZ
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PZ = L-Z + WS-DZ
             END-IF
             IF WS-I = 0 OR (WS-FAMILY = 1 AND WS-TYPE NOT = 0)
                 CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y1 WS-PZ WS-ABOVE
                 IF CB-SOLID(CB-S-BLOCK(WS-ABOVE + 1) + 1) = 1 AND CB-OPAQUE(CB-S-BLOCK(WS-ABOVE + 1) + 1) = 1
                     MOVE 1 TO WS-CONDUCTOR
                 END-IF
                 CALL "BE-CHEST-BLOCKED" USING WS-CONDUCTOR WS-NO-CAT WS-CAN
                 IF WS-CAN = 1
                     MOVE 1 TO WS-BLOCKED
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     IF WS-BLOCKED = 1
         GOBACK
     END-IF
     MOVE WS-STORE TO WS-FIRST
     MOVE 0 TO WS-SECOND
     IF WS-FAMILY = 1 AND WS-TYPE NOT = 0
         CALL "BE-CHEST-CONNECTED" USING WS-DIR WS-TYPE WS-DX WS-DZ
         COMPUTE WS-PX = L-X + WS-DX
         COMPUTE WS-PZ = L-Z + WS-DZ
         CALL "BE-FIND" USING WS-DIM WS-PX L-Y WS-PZ WS-BE2
         IF WS-BE2 > 0
             MOVE WS-BE2 TO WS-SECOND
             IF WS-TYPE = 1
                 MOVE WS-BE2 TO WS-FIRST
                 MOVE WS-BE TO WS-SECOND
             END-IF
         END-IF
     END-IF
     MOVE 0 TO WS-SPECTATOR
     IF PL-MODE(WS-ROW) = 3
         MOVE 1 TO WS-SPECTATOR
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE 0 TO WS-KEY-LENGTH
     IF PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) > 0
         MOVE IT-KEY(PL-SLOT-ITEM(WS-ROW, PL-HELD(WS-ROW) + 1) + 1) TO WS-KEY
         MOVE IT-KEY-LENGTH(PL-SLOT-ITEM(WS-ROW, PL-HELD(WS-ROW) + 1) + 1) TO WS-KEY-LENGTH
     END-IF
     CALL "BE-CAN-OPEN" USING WS-FIRST WS-SPECTATOR WS-KEY WS-KEY-LENGTH WS-CAN WS-NOTIFY
     IF WS-CAN = 0
         GOBACK
     END-IF
     IF MN-WINDOW(WS-ROW) > 0
         CALL "MENU-CLOSE" USING L-ID
     END-IF
     COMPUTE MN-COUNTER(WS-ROW) = FUNCTION MOD(MN-COUNTER(WS-ROW), 100) + 1
     MOVE MN-COUNTER(WS-ROW) TO MN-WINDOW(WS-ROW)
     MOVE 27 TO MN-CSIZE(WS-ROW)
     MOVE 2 TO WS-MENU-TYPE
     IF WS-SECOND > 0
         MOVE 54 TO MN-CSIZE(WS-ROW)
         MOVE 5 TO WS-MENU-TYPE
     END-IF
     IF WS-FAMILY = 4
         MOVE 20 TO WS-MENU-TYPE
     END-IF
     IF WS-FAMILY = 5
         MOVE 5 TO MN-CSIZE(WS-ROW)
         MOVE 16 TO WS-MENU-TYPE
     END-IF
     IF WS-FAMILY = 6
         MOVE 9 TO MN-CSIZE(WS-ROW)
         MOVE 6 TO WS-MENU-TYPE
     END-IF
     MOVE WS-MENU-TYPE TO MN-TYPE(WS-ROW)
     MOVE WS-FAMILY TO MN-CFAMILY(WS-ROW)
     MOVE WS-FIRST TO MN-CBE1(WS-ROW) MN-COPEN(WS-ROW, 1)
     MOVE WS-SECOND TO MN-CBE2(WS-ROW) MN-COPEN(WS-ROW, 2)
     IF WS-FAMILY = 2
         MOVE WS-BE TO MN-COPEN(WS-ROW, 1)
         MOVE 0 TO MN-COPEN(WS-ROW, 2)
     END-IF
*>   A hopper, dispenser or dropper has no opener counter.
     IF WS-FAMILY > 4
         MOVE 0 TO MN-COPEN(WS-ROW, 1) MN-COPEN(WS-ROW, 2)
     END-IF
     MOVE 1 TO MN-STATE-ID(WS-ROW)
     MOVE WS-DIM TO MN-BENCH-DIM(WS-ROW)
     MOVE L-X TO MN-BENCH-X(WS-ROW)
     MOVE L-Y TO MN-BENCH-Y(WS-ROW)
     MOVE L-Z TO MN-BENCH-Z(WS-ROW)
*>   startOpen on every entity.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE MN-COPEN(WS-ROW, WS-I) TO WS-BE
         IF WS-BE > 0
             IF WS-FAMILY = 4
                 CALL "BE-SHULKER-START" USING WS-BE WS-SPECTATOR BE-FX
             ELSE
                 CALL "BE-OPEN-INC" USING WS-BE WS-RANGE WS-SPECTATOR BE-FX
             END-IF
             CALL "MENU-CONT-FX" USING WS-BE WS-DIM BE-FX
         END-IF
     END-PERFORM
*>   The title: a custom name as text, else the default name; a double chest the name of 31-1 section 10.2.
     IF WS-SECOND > 0
         CALL "BE-DOUBLE-NAME" USING WS-FIRST WS-SECOND WS-NAME WS-NAME-LENGTH
     ELSE
         MOVE SPACES TO WS-NAME
         MOVE BE-NAME-LENGTH(WS-FIRST) TO WS-NAME-LENGTH
         IF WS-NAME-LENGTH > 0
             MOVE BE-NAME(WS-FIRST) TO WS-NAME
         ELSE
             CALL "BE-DEFAULT-NAME" USING BE-TYPE(WS-FIRST) WS-DEFAULT WS-NAME-LENGTH
             MOVE WS-DEFAULT TO WS-NAME
         END-IF
     END-IF
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     IF WS-NAME(1:10) NOT = "container."
         MOVE PB-TEXT-LITERAL TO PB-TX-KIND
     END-IF
     MOVE WS-NAME TO PB-TX-VALUE
     MOVE WS-NAME-LENGTH TO PB-TX-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-OPEN-SCREEN" USING PB-BUFFER MN-WINDOW(WS-ROW) WS-MENU-TYPE PB-TEXT
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     MOVE 1 TO L-OPENED
     GOBACK.
 END PROGRAM MENU-CONT-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CONT-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY BESTATE.
 COPY BEFX.
 01 WS-BE                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SPECTATOR           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF MN-CSIZE(L-ROW) = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-SPECTATOR
     IF PL-MODE(L-ROW) = 3
         MOVE 1 TO WS-SPECTATOR
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE MN-COPEN(L-ROW, WS-I) TO WS-BE
         IF WS-BE > 0
             IF BE-USED(WS-BE) = 1 AND BE-DIM(WS-BE) = MN-BENCH-DIM(L-ROW) AND BE-Y(WS-BE) = MN-BENCH-Y(L-ROW)
                 IF MN-CFAMILY(L-ROW) = 4
                     CALL "BE-SHULKER-STOP" USING WS-BE WS-SPECTATOR BE-FX
                 ELSE
                     CALL "BE-OPEN-DEC" USING WS-BE WS-SPECTATOR BE-FX
                 END-IF
                 CALL "MENU-CONT-FX" USING WS-BE MN-BENCH-DIM(L-ROW) BE-FX
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO MN-CSIZE(L-ROW) MN-CFAMILY(L-ROW) MN-CBE1(L-ROW) MN-CBE2(L-ROW) MN-COPEN(L-ROW, 1) MN-COPEN(L-ROW, 2)
     GOBACK.
 END PROGRAM MENU-CONT-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CONT-VALID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 COPY BESTATE.
 01 WS-STATE               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-VALID.
     MOVE 1 TO L-VALID
     CALL "WORLD-GET-BLOCK" USING MN-BENCH-DIM(L-ROW) MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW) MN-BENCH-Z(L-ROW) WS-STATE
     CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAMILY WS-DIR WS-TYPE WS-FLAG
     IF WS-FAMILY NOT = MN-CFAMILY(L-ROW)
         MOVE 0 TO L-VALID
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1
                 MOVE MN-CBE1(L-ROW) TO WS-BE
             WHEN 2
                 MOVE MN-CBE2(L-ROW) TO WS-BE
             WHEN 3
                 MOVE MN-COPEN(L-ROW, 1) TO WS-BE
             WHEN OTHER
                 MOVE MN-COPEN(L-ROW, 2) TO WS-BE
         END-EVALUATE
         IF WS-BE > 0 AND (BE-USED(WS-BE) = 0 OR BE-REMOVED(WS-BE) = 1)
             MOVE 0 TO L-VALID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-CONT-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CONT-QUICK-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REVERSE             BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
     MOVE MN-CSIZE(L-ROW) TO WS-OWN
     COMPUTE WS-TOTAL = WS-OWN + 36
     MOVE WS-COUNT TO WS-LEFT
     MOVE 0 TO WS-MOVED
     IF L-SLOT < WS-OWN
         MOVE WS-OWN TO WS-FIRST
         MOVE WS-TOTAL TO WS-END
         MOVE 1 TO WS-REVERSE
     ELSE
         MOVE 0 TO WS-FIRST
         MOVE WS-OWN TO WS-END
         MOVE 0 TO WS-REVERSE
     END-IF
     CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REVERSE WS-MOVED WS-VAR
     CALL "MENU-QUICK-FINISH" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-LEFT WS-MOVED L-RET-ITEM L-RET-COUNT
     GOBACK.
 END PROGRAM MENU-CONT-QUICK-MOVE.
