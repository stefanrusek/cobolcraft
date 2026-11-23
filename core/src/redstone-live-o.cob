*> Live redstone, the equipment behaviours of the dispenser (docs/protocol/30-redstone-4 sections 4.7, 4.8 and 4.9; 44 part 7 section 10.3.1), reached from RL-DISP-MORE.
*> Equipment (4.9, the default rule of an item with the `equippable` component): the first living entity whose box meets the front cell, that may wear the item and has nothing in the slot, gets one
*> item in that slot; with none, the item is dropped as by the default behaviour. The item table carries no components, so the slot of an item comes from its key (MENU-EQUIP-KIND: boots, leggings, chestplate,
*> elytra, helmet; the carved pumpkin and the wither skeleton skull go on the head). Entities that can wear it: an armor stand whose slot is not disabled (its box: 0.5 wide and 1.975 high, half of that
*> when small, none when a marker) and a player who is not a spectator (0.6 wide, 1.8 high, 1.5 crouching). Rows of the entity table are asked before the players.
*> Wither skeleton skull (4.7) and carved pumpkin (4.8): an air cell in front where the wither pattern (WITHER-CAN-SPAWN) or a golem pattern (GOLEM-CAN-BUILD) is complete takes the block (the skull with the
*> rotation segment of the facing: south 0, west 4, north 8, east 12, 0 up or down) and the build runs (WITHER-BUILD, GOLEM-BUILD); otherwise the item is worn as equipment and, when nobody can wear it, it stays
*> in the dispenser with the failure click, never dropped.
*> Not done: mobs (they take dispenser equipment only when they can pick up loot, and the core does not model that), saddles, horse armor, wolf armor, carpets, harnesses and the mob heads other than the wither
*> skeleton skull (their equippable data is not in the item table), the shield, the entity order of the level (an armor stand beats a player here), the swimming box of a player, the equipment packet to the
*> other viewers (an armor stand's equipment is not shown to anyone yet), the game event block_place.
*> Entry points:
*>   RL-EQUIP-SLOT USING item, slot out                                       1 boots, 2 leggings, 3 chestplate (and elytra), 4 head, 0 not worn
*>   RL-BOX-IN-CELL USING feet x, y, z, half width, height (FLOAT-LONG), cell x, y, z, hit out    1 when the box has a volume in common with the cell (a point inside counts)
*>   RL-DISP-EQUIP USING dim, front x, y, z, item, ok out                     1 when one entity took one item
*>   RL-DISP-HEAD USING dim, front x, y, z, facing, item bare key (PIC X(48)), item, handled out, consumed out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-EQUIP-SLOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-SLOT.
     CALL "MENU-EQUIP-KIND" USING L-ITEM L-SLOT
     IF L-SLOT = 5
         MOVE 0 TO L-SLOT
     END-IF
     IF L-SLOT = 0 AND L-ITEM > 0 AND L-ITEM < IT-COUNT
         MOVE IT-KEY(L-ITEM + 1) TO WS-KEY
         CALL "KEY-BARE" USING WS-KEY WS-BARE
         IF WS-BARE = "carved_pumpkin" OR WS-BARE = "wither_skeleton_skull"
             MOVE 4 TO L-SLOT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RL-EQUIP-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-BOX-IN-CELL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HALF                 FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-HALF L-HEIGHT L-CX L-CY L-CZ L-HIT.
     MOVE 1 TO L-HIT
     COMPUTE WS-LO = L-X - L-HALF
     COMPUTE WS-HI = L-X + L-HALF
     COMPUTE WS-CELL = L-CX + 1
     IF WS-LO >= WS-CELL OR WS-HI <= L-CX
         MOVE 0 TO L-HIT
     END-IF
     COMPUTE WS-LO = L-Z - L-HALF
     COMPUTE WS-HI = L-Z + L-HALF
     COMPUTE WS-CELL = L-CZ + 1
     IF WS-LO >= WS-CELL OR WS-HI <= L-CZ
         MOVE 0 TO L-HIT
     END-IF
     COMPUTE WS-HI = L-Y + L-HEIGHT
     COMPUTE WS-CELL = L-CY + 1
     IF L-Y >= WS-CELL OR WS-HI <= L-CY
         MOVE 0 TO L-HIT
     END-IF
     GOBACK.
 END PROGRAM RL-BOX-IN-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DISP-EQUIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CMENU.
 COPY PROJSTATE.
 LOCAL-STORAGE SECTION.
 01 LS-SLOT                BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-P                   BINARY-LONG.
 01 LS-BIT                 BINARY-LONG.
 01 LS-DISABLED            BINARY-LONG.
 01 LS-SMALL               BINARY-LONG.
 01 LS-MARKER              BINARY-LONG.
 01 LS-HALF                FLOAT-LONG.
 01 LS-HEIGHT              FLOAT-LONG.
 01 LS-HIT                 BINARY-LONG.
 01 LS-CONTAINER           BINARY-LONG.
 01 LS-MENU-SLOT           BINARY-LONG.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ITEM L-OK.
     MOVE 0 TO L-OK
     CALL "RL-EQUIP-SLOT" USING L-ITEM LS-SLOT
     IF LS-SLOT = 0
         GOBACK
     END-IF
*>   the armor stands of the entity table
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > EN-COUNT OR L-OK = 1
         IF EN-USED(LS-I) = 1 AND EN-DIM(LS-I) = L-DIM AND EN-HEALTH(LS-I) > 0
             CALL "PJ-FIND" USING EN-ID(LS-I) LS-P
             IF LS-P > 0 AND PJ-KIND(LS-P) = 11
                 MOVE 0 TO LS-BIT
                 CALL "DECOR-BIT" USING PJ-I1(LS-P) LS-BIT LS-SMALL
                 MOVE 4 TO LS-BIT
                 CALL "DECOR-BIT" USING PJ-I1(LS-P) LS-BIT LS-MARKER
                 CALL "DECOR-BIT" USING PJ-I2(LS-P) LS-SLOT LS-DISABLED
                 COMPUTE LS-HALF = ET-WIDTH-MILLI(EN-TYPE(LS-I) + 1) / 2000
                 COMPUTE LS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(LS-I) + 1) / 1000
                 IF LS-SMALL = 1
                     COMPUTE LS-HALF = LS-HALF / 2
                     COMPUTE LS-HEIGHT = LS-HEIGHT / 2
                 END-IF
                 IF LS-MARKER = 1
                     MOVE 0 TO LS-HALF LS-HEIGHT
                 END-IF
                 CALL "RL-BOX-IN-CELL" USING EN-X(LS-I) EN-Y(LS-I) EN-Z(LS-I) LS-HALF LS-HEIGHT L-X L-Y L-Z LS-HIT
                 IF LS-HIT = 1 AND LS-DISABLED = 0 AND PJ-EQ(LS-P, LS-SLOT + 1) = 0
                     MOVE L-ITEM TO PJ-EQ(LS-P, LS-SLOT + 1)
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   the players: alive, not a spectator, the slot empty
     COMPUTE LS-CONTAINER = 35 + LS-SLOT
     MOVE 0.3 TO LS-HALF
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 64 OR L-OK = 1
         IF PL-USED(LS-I) = 1 AND PL-STATE(LS-I) = PS-ALIVE AND PL-DIM(LS-I) = L-DIM AND PL-MODE(LS-I) NOT = 3
                 AND PL-HEALTH(LS-I) > 0 AND MN-EQUIP-COUNT(LS-I, LS-SLOT) = 0
             MOVE 1.8 TO LS-HEIGHT
             IF PL-POSE(LS-I) = 5
                 MOVE 1.5 TO LS-HEIGHT
             END-IF
             CALL "RL-BOX-IN-CELL" USING PL-X(LS-I) PL-Y(LS-I) PL-Z(LS-I) LS-HALF LS-HEIGHT L-X L-Y L-Z LS-HIT
             IF LS-HIT = 1
                 CALL "MENU-PLAYER-SET-X" USING LS-I LS-CONTAINER L-ITEM LS-ONE LS-ZERO
                 CALL "MENU-CONTAINER-SLOT" USING LS-I LS-CONTAINER LS-MENU-SLOT
                 IF LS-MENU-SLOT >= 0
                     CALL "MENU-SLOT-SEND" USING PL-CONN(LS-I) LS-MENU-SLOT
                 END-IF
                 MOVE 1 TO L-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-DISP-EQUIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DISP-HEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SKULL               PIC X(48) VALUE "minecraft:wither_skeleton_skull".
 01 WS-PUMPKIN             PIC X(48) VALUE "minecraft:carved_pumpkin".
 01 WS-ROTATION            PIC X(24) VALUE "rotation".
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 LOCAL-STORAGE SECTION.
 01 LS-STATE               BINARY-LONG.
 01 LS-CAN                 BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-SEGMENT             BINARY-LONG.
 01 LS-TEXT                PIC X(32).
 01 LS-SEG-ED              PIC Z9.
 01 LS-RESULT              BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-BARE                 PIC X(48).
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-BARE L-ITEM L-HANDLED L-CONSUMED.
     MOVE 1 TO L-HANDLED
     MOVE 0 TO L-CONSUMED LS-CAN
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-STATE
     IF LS-STATE = 0
         IF L-BARE = "wither_skeleton_skull"
             CALL "WITHER-CAN-SPAWN" USING L-DIM L-X L-Y L-Z LS-CAN
         ELSE
             CALL "GOLEM-CAN-BUILD" USING L-DIM L-X L-Y L-Z LS-CAN
         END-IF
     END-IF
     IF LS-CAN = 1
         IF L-BARE = "wither_skeleton_skull"
             CALL "WORLDSIM-FIND-BLOCK" USING WS-SKULL LS-NEW
*>           RotationSegment.convertToSegment(facing): the 2D data value (south 0, west 1, north 2, east 3) times 4, 0 for up and down
             EVALUATE L-FACING
                 WHEN 4
                     MOVE 4 TO LS-SEGMENT
                 WHEN 2
                     MOVE 8 TO LS-SEGMENT
                 WHEN 5
                     MOVE 12 TO LS-SEGMENT
                 WHEN OTHER
                     MOVE 0 TO LS-SEGMENT
             END-EVALUATE
             MOVE LS-SEGMENT TO LS-SEG-ED
             MOVE FUNCTION TRIM(LS-SEG-ED) TO LS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE-SET LS-NEW WS-ROTATION LS-TEXT LS-RESULT
             MOVE LS-RESULT TO LS-NEW
         ELSE
             CALL "WORLDSIM-FIND-BLOCK" USING WS-PUMPKIN LS-NEW
         END-IF
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
         IF L-BARE = "wither_skeleton_skull"
             CALL "WITHER-BUILD" USING L-DIM L-X L-Y L-Z
         ELSE
             CALL "GOLEM-BUILD" USING L-DIM L-X L-Y L-Z
         END-IF
         MOVE 1 TO L-CONSUMED
     ELSE
         CALL "RL-DISP-EQUIP" USING L-DIM L-X L-Y L-Z L-ITEM LS-OK
         MOVE LS-OK TO L-CONSUMED
     END-IF
     GOBACK.
 END PROGRAM RL-DISP-HEAD.
