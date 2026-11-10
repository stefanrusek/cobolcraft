*> The tool rules that the play path calls (docs/protocol/17 sections 3.1, 5.1 and 3.16; US14): block transformers of axes, shovels and hoes on
*> Use Item On, the durability of the held tool when a block breaks, and wearing armor with Use Item. The decisions are the programs of
*> tools-use.cob (TOOL-TRANSFORM), tools-durability.cob (TOOL-HURT-STACK) and menus.cob (MENU-EQUIP-KIND); these programs read the world and the
*> player rows and send the packets.
*>   TOOLUSE-KEY USING item id, short key out (PIC X(48), no namespace; blank for no item)
*>   COMBAT-BREAK-WEAR USING player row: the held tool pays the durability of a broken block (5.1: 1 for a pickaxe, axe, shovel, hoe or shears, 2 for
*>     a sword, mace or trident), Container Set Slot of the slot; called by BREAK-FINISH
*>   TOOLUSE-ON USING connection id, PLAY-SERVERBOUND (Use Item On), done out (1 when the held tool changed the block): the axe strips and
*>     scrapes and waxes off, the shovel makes a path, the hoe tills (3.1); one durability, the new block keeps the state offset of the old one when
*>     both blocks have the same number of states, else the default state. Block Changed Ack is the caller's. Sounds and particles are not sent
*>     (no sound packet builder in the core yet)
*>   TOOLUSE-ITEM USING connection id, done out (1 when the held item is armor, an elytra or a shield and was worn): Use Item swaps the held stack
*>     with the worn one of its slot (MN-EQUIP) and sends both slots

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOLUSE-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-LONG                PIC X(48).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-KEY                  PIC X(48).
 PROCEDURE DIVISION USING L-ITEM L-KEY.
     MOVE SPACES TO L-KEY
     IF L-ITEM > 0 AND L-ITEM < IT-COUNT
         MOVE IT-KEY(L-ITEM + 1) TO WS-LONG
         IF WS-LONG(1:10) = "minecraft:"
             MOVE WS-LONG(11:38) TO L-KEY
         ELSE
             MOVE WS-LONG TO L-KEY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOLUSE-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. COMBAT-BREAK-WEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-BROKE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) WS-KEY
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY))
     MOVE 0 TO WS-COST
     IF WS-KEY = "shears" OR "mace" OR "trident"
         MOVE 1 TO WS-COST
         IF WS-KEY NOT = "shears"
             MOVE 2 TO WS-COST
         END-IF
     END-IF
     IF WS-LEN >= 6
         IF WS-KEY(WS-LEN - 5:6) = "_sword"
             MOVE 2 TO WS-COST
         END-IF
     END-IF
     IF WS-LEN >= 4
         IF WS-KEY(WS-LEN - 3:4) = "_axe" OR "_hoe"
             MOVE 1 TO WS-COST
         END-IF
     END-IF
     IF WS-LEN >= 8
         IF WS-KEY(WS-LEN - 7:8) = "_pickaxe"
             MOVE 1 TO WS-COST
         END-IF
     END-IF
     IF WS-LEN >= 7
         IF WS-KEY(WS-LEN - 6:7) = "_shovel"
             MOVE 1 TO WS-COST
         END-IF
     END-IF
     IF WS-COST > 0
         CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) PL-HELD(L-ROW) WS-COST WS-BROKE
     END-IF
     GOBACK.
 END PROGRAM COMBAT-BREAK-WEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOLUSE-ON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KIND                PIC X(8).
 01 WS-STATE               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-BLOCK-KEY           PIC X(48).
 01 WS-AIR                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NEW                 PIC X(48).
 01 WS-SOUND               PIC X(32).
 01 WS-PARTICLE            PIC X(16).
 01 WS-LOOT                PIC X(32).
 01 WS-UPDATE              BINARY-LONG.
 01 WS-COPY                BINARY-LONG.
 01 WS-LONG-KEY            PIC X(112).
 01 WS-NEW-ID              BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-NEW-STATE           BINARY-LONG.
 01 WS-COST                BINARY-LONG VALUE 1.
 01 WS-BROKE               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     IF PSB-HAND NOT = 0 OR PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, PL-HELD(WS-ROW) + 1) WS-KEY
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY))
     MOVE SPACES TO WS-KIND
     IF WS-LEN >= 4
         IF WS-KEY(WS-LEN - 3:4) = "_axe"
             MOVE "axe" TO WS-KIND
         END-IF
         IF WS-KEY(WS-LEN - 3:4) = "_hoe"
             MOVE "hoe" TO WS-KIND
         END-IF
     END-IF
     IF WS-LEN >= 7
         IF WS-KEY(WS-LEN - 6:7) = "_shovel"
             MOVE "shovel" TO WS-KIND
         END-IF
     END-IF
     IF WS-KIND = SPACES
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-OLD
     COMPUTE WS-Y = PSB-BY + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX WS-Y PSB-BZ WS-ABOVE
     MOVE 0 TO WS-AIR
     IF WS-ABOVE = 0
         MOVE 1 TO WS-AIR
     END-IF
     MOVE SPACES TO WS-BLOCK-KEY
     IF CB-KEY(CB-S-BLOCK(WS-OLD + 1) + 1)(1:10) = "minecraft:"
         MOVE CB-KEY(CB-S-BLOCK(WS-OLD + 1) + 1)(11:38) TO WS-BLOCK-KEY
     ELSE
         MOVE CB-KEY(CB-S-BLOCK(WS-OLD + 1) + 1) TO WS-BLOCK-KEY
     END-IF
     CALL "TOOL-TRANSFORM" USING WS-KIND WS-BLOCK-KEY PSB-FACE WS-AIR WS-FOUND WS-NEW WS-SOUND WS-PARTICLE WS-LOOT
         WS-UPDATE WS-COPY
     IF WS-FOUND NOT = 1
         GOBACK
     END-IF
     MOVE SPACES TO WS-LONG-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-NEW) DELIMITED BY SIZE INTO WS-LONG-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-LONG-KEY WS-NEW-ID WS-ROW-TEXT WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     IF CB-STATES(WS-NEW-ID + 1) = CB-STATES(CB-S-BLOCK(WS-OLD + 1) + 1)
         COMPUTE WS-NEW-STATE = CB-FIRST-STATE(WS-NEW-ID + 1) + WS-OLD - CB-FIRST-STATE(CB-S-BLOCK(WS-OLD + 1) + 1)
     ELSE
         MOVE CB-DEFAULT-STATE(WS-NEW-ID + 1) TO WS-NEW-STATE
     END-IF
     CALL "BLOCK-CHANGE" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-NEW-STATE
     CALL "TOOL-HURT-STACK" USING L-ID PL-HELD(WS-ROW) WS-COST WS-BROKE
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM TOOLUSE-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOLUSE-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-MENU-SLOT           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF MN-WINDOW(WS-ROW) NOT = 0 OR PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) = 0
         GOBACK
     END-IF
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     CALL "MENU-EQUIP-KIND" USING PL-SLOT-ITEM(WS-ROW, WS-HELD + 1) WS-KIND
     IF WS-KIND < 1 OR WS-KIND > 5
         GOBACK
     END-IF
     MOVE MN-EQUIP-ITEM(WS-ROW, WS-KIND) TO WS-ITEM
     MOVE MN-EQUIP-COUNT(WS-ROW, WS-KIND) TO WS-COUNT
     MOVE MN-EQUIP-VAR(WS-ROW, WS-KIND) TO WS-VAR
     MOVE PL-SLOT-ITEM(WS-ROW, WS-HELD + 1) TO MN-EQUIP-ITEM(WS-ROW, WS-KIND)
     MOVE PL-SLOT-COUNT(WS-ROW, WS-HELD + 1) TO MN-EQUIP-COUNT(WS-ROW, WS-KIND)
     MOVE PL-SLOT-VAR(WS-ROW, WS-HELD + 1) TO MN-EQUIP-VAR(WS-ROW, WS-KIND)
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-ROW, WS-HELD + 1)
     MOVE WS-COUNT TO PL-SLOT-COUNT(WS-ROW, WS-HELD + 1)
     MOVE WS-VAR TO PL-SLOT-VAR(WS-ROW, WS-HELD + 1)
     COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
     CALL "INV-SLOT-SEND" USING L-ID WS-HELD
     IF WS-KIND = 5
         MOVE 45 TO WS-MENU-SLOT
     ELSE
         COMPUTE WS-MENU-SLOT = 9 - WS-KIND
     END-IF
     CALL "MENU-SLOT-SEND" USING L-ID WS-MENU-SLOT
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM TOOLUSE-ITEM.
