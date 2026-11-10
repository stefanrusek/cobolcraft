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
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-KEY                  PIC X(48).
 PROCEDURE DIVISION USING L-ITEM L-KEY.
     MOVE SPACES TO L-KEY
     IF L-ITEM > 0 AND L-ITEM < IT-COUNT
         MOVE IT-KEY(L-ITEM + 1) TO L-KEY
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
     IF WS-KEY = "flint_and_steel" OR "fire_charge"
         CALL "TOOLUSE-FIRE" USING L-ID PLAY-SERVERBOUND WS-KEY L-DONE
         GOBACK
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
     MOVE CB-KEY(CB-S-BLOCK(WS-OLD + 1) + 1) TO WS-BLOCK-KEY
     CALL "TOOL-TRANSFORM" USING WS-KIND WS-BLOCK-KEY PSB-FACE WS-AIR WS-FOUND WS-NEW WS-SOUND WS-PARTICLE WS-LOOT
         WS-UPDATE WS-COPY
     IF WS-FOUND NOT = 1
         GOBACK
     END-IF
     MOVE SPACES TO WS-LONG-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-NEW) DELIMITED BY SIZE INTO WS-LONG-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-LONG-KEY WS-NEW-ID WS-ROW-TEXT WS-STATUS
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
 01 WS-OFF-KEY             PIC X(48).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF MN-WINDOW(WS-ROW) NOT = 0
         GOBACK
     END-IF
*>   An empty main hand with a shield in the off-hand raises that shield (17 section 3.6); a shield in the main hand is raised, not worn.
     IF PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) = 0
         MOVE SPACES TO WS-OFF-KEY
         IF MN-EQUIP-COUNT(WS-ROW, 5) > 0
             CALL "TOOLUSE-KEY" USING MN-EQUIP-ITEM(WS-ROW, 5) WS-OFF-KEY
         END-IF
         IF WS-OFF-KEY = "shield"
             CALL "COMBAT-BLOCK-RAISE" USING WS-ROW WS-ONE
             MOVE 1 TO L-DONE
         END-IF
         GOBACK
     END-IF
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     CALL "MENU-EQUIP-KIND" USING PL-SLOT-ITEM(WS-ROW, WS-HELD + 1) WS-KIND
     IF WS-KIND < 1 OR WS-KIND > 5
         GOBACK
     END-IF
     IF WS-KIND = 5
         CALL "COMBAT-BLOCK-RAISE" USING WS-ROW WS-ZERO
         MOVE 1 TO L-DONE
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
     COMPUTE WS-MENU-SLOT = 9 - WS-KIND
     CALL "MENU-SLOT-SEND" USING L-ID WS-MENU-SLOT
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM TOOLUSE-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOLUSE-FIRE.
*> USING connection id, PLAY-SERVERBOUND (Use Item On), item key (PIC X(48): flint_and_steel or fire_charge), done out: 17 section 3.3. Fire
*> goes into the air block beside the clicked face when the block below it is solid, a neighbour of it is flammable (TOOL-FLAMMABILITY) or it
*> is a soul fire base (soul_sand, soul_soil: soul_fire). Flint and steel loses 1 durability, a fire charge is used up (neither in creative).
*> Not done: lighting a candle or campfire (the lit property), sounds, and the clicked block being replaceable.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK-KEY           PIC X(48).
 01 WS-AIR                 BINARY-LONG.
 01 WS-SUPPORT             BINARY-LONG.
 01 WS-FLAMMABLE           BINARY-LONG.
 01 WS-SOUL                BINARY-LONG.
 01 WS-LIT                 BINARY-LONG VALUE 1.
 01 WS-WATERLOGGED         BINARY-LONG VALUE 0.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-NEW                 PIC X(48).
 01 WS-SOUND               PIC X(32).
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-CONSUME             BINARY-LONG.
 01 WS-IGNITE              BINARY-LONG.
 01 WS-BURN                BINARY-LONG.
 01 WS-ITEM16              PIC X(16).
 01 WS-HITS                BINARY-LONG.
 01 WS-LONG-KEY            PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FIRE-STATE          BINARY-LONG.
 01 WS-BROKE               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-HELD                BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-KEY L-DONE.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-BLOCK-KEY
     MOVE 0 TO WS-HITS
     INSPECT WS-BLOCK-KEY TALLYING WS-HITS FOR ALL "candle" ALL "campfire"
     IF WS-HITS > 0
         GOBACK
     END-IF
     MOVE PSB-BX TO WS-TX
     MOVE PSB-BY TO WS-TY
     MOVE PSB-BZ TO WS-TZ
     EVALUATE PSB-FACE
         WHEN 0
             SUBTRACT 1 FROM WS-TY
         WHEN 1
             ADD 1 TO WS-TY
         WHEN 2
             SUBTRACT 1 FROM WS-TZ
         WHEN 3
             ADD 1 TO WS-TZ
         WHEN 4
             SUBTRACT 1 FROM WS-TX
         WHEN OTHER
             ADD 1 TO WS-TX
     END-EVALUATE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-TX WS-TY WS-TZ WS-STATE
     MOVE 0 TO WS-AIR WS-SUPPORT WS-FLAMMABLE WS-SOUL
     IF WS-STATE = 0
         MOVE 1 TO WS-AIR
     END-IF
     COMPUTE WS-NY = WS-TY - 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-TX WS-NY WS-TZ WS-STATE
     IF CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
         MOVE 1 TO WS-SUPPORT
     END-IF
     IF CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) = "soul_sand" OR "soul_soil"
         MOVE 1 TO WS-SOUL
     END-IF
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
         MOVE WS-TX TO WS-NX
         MOVE WS-TY TO WS-NY
         MOVE WS-TZ TO WS-NZ
         EVALUATE WS-D
             WHEN 0
                 SUBTRACT 1 FROM WS-NY
             WHEN 1
                 ADD 1 TO WS-NY
             WHEN 2
                 SUBTRACT 1 FROM WS-NZ
             WHEN 3
                 ADD 1 TO WS-NZ
             WHEN 4
                 SUBTRACT 1 FROM WS-NX
             WHEN OTHER
                 ADD 1 TO WS-NX
         END-EVALUATE
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-NX WS-NY WS-NZ WS-STATE
         MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-BLOCK-KEY
         CALL "TOOL-FLAMMABILITY" USING WS-BLOCK-KEY WS-IGNITE WS-BURN
         IF WS-IGNITE > 0
             MOVE 1 TO WS-FLAMMABLE
         END-IF
     END-PERFORM
     MOVE PL-MODE(WS-ROW) TO WS-CREATIVE
     MOVE L-KEY TO WS-ITEM16
     MOVE SPACES TO WS-BLOCK-KEY
     CALL "TOOL-FIRE-USE" USING WS-ITEM16 WS-BLOCK-KEY WS-LIT WS-WATERLOGGED WS-AIR WS-SUPPORT WS-FLAMMABLE WS-SOUL
         WS-CREATIVE WS-ACTION WS-NEW WS-SOUND WS-DAMAGE WS-CONSUME
     IF WS-ACTION NOT = 2
         GOBACK
     END-IF
     MOVE SPACES TO WS-LONG-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-NEW) DELIMITED BY SIZE INTO WS-LONG-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-LONG-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-FIRE-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-TX WS-TY WS-TZ WS-FIRE-STATE
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     IF WS-DAMAGE > 0
         CALL "TOOL-HURT-STACK" USING L-ID WS-HELD WS-DAMAGE WS-BROKE
     END-IF
     IF WS-CONSUME > 0
         CALL "INV-REMOVE" USING WS-ROW WS-HELD WS-ONE
         COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
         CALL "INV-SLOT-SEND" USING L-ID WS-HELD
     END-IF
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM TOOLUSE-FIRE.
