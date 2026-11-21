*> The anvil as a live station menu (docs/protocol/40-menus-3-anvil-grindstone-smithing.md section 3; lane itemcomp2, T10102): station kind 4, MN-CFAMILY 24; own slot 0 the left stack, 1 the right
*> stack, 2 the result (MN-WSLOT 1 and 2, MN-RESULT-*). The result is ANVIL-CREATE-RESULT over the two slots and the name the client typed (MN-WNAME); MN-WDATA(1) is the level cost, MN-WSEL the
*> repair units of the result, MN-WKEEP 1 when the result is only a rename. Taking the result needs the levels (mayPickup), pays them, uses up the right stack by its rule and empties the left slot.
*> Gaps: the 12 percent chance that an anvil chips, damages or breaks on a take (3.5 step 6) and the level events and sounds are not done; a name longer than 60 bytes is refused (the custom_name
*> patch holds 60 bytes), and the item's own name is not compared with the typed one.
*>   MENU-ANVIL-UPDATE USING row            slotsChanged: the result and the cost follow the inputs and the name
*>   MENU-ANVIL-MAYTAKE USING row, ok out   mayPickup of the result slot (3.4)
*>   MENU-ANVIL-TAKEN USING row             onTake (3.5 steps 1 to 5) after the result slot was emptied
*>   XP-TAKE-LEVELS USING player row, levels   giveExperienceLevels(-levels): the level drops, below 0 level, progress and total become 0; Set Experience is sent
*>   ANVIL-RENAME USING connection id, PLAY-SERVERBOUND   Rename Item (05c 0x31, PSB-MESSAGE): filterText, length 50, equal name, then the result is made again

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-ANVIL-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-INF                 BINARY-LONG.
 01 WS-LITEM               BINARY-LONG.
 01 WS-LCOUNT              BINARY-LONG.
 01 WS-LVAR                BINARY-LONG.
 01 WS-RITEM               BINARY-LONG.
 01 WS-RCOUNT              BINARY-LONG.
 01 WS-RVAR                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LEN            BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-UNITS               BINARY-LONG.
 01 WS-ONLY                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-INF
     IF PL-MODE(L-ROW) = 1
         MOVE 1 TO WS-INF
     END-IF
     MOVE MN-WSLOT-ITEM(L-ROW, 1) TO WS-LITEM
     MOVE MN-WSLOT-COUNT(L-ROW, 1) TO WS-LCOUNT
     MOVE MN-WSLOT-VAR(L-ROW, 1) TO WS-LVAR
     MOVE MN-WSLOT-ITEM(L-ROW, 2) TO WS-RITEM
     MOVE MN-WSLOT-COUNT(L-ROW, 2) TO WS-RCOUNT
     MOVE MN-WSLOT-VAR(L-ROW, 2) TO WS-RVAR
     MOVE MN-WNAME(L-ROW) TO WS-NAME
     MOVE MN-WNAME-LEN(L-ROW) TO WS-NAME-LEN
     CALL "ANVIL-CREATE-RESULT" USING WS-LITEM WS-LCOUNT WS-LVAR WS-RITEM WS-RCOUNT WS-RVAR WS-NAME WS-NAME-LEN WS-INF
         WS-ITEM WS-COUNT WS-VAR WS-COST WS-UNITS WS-ONLY
     MOVE WS-ITEM TO MN-RESULT-ITEM(L-ROW)
     MOVE WS-COUNT TO MN-RESULT-COUNT(L-ROW)
     MOVE WS-VAR TO MN-RESULT-VAR(L-ROW)
     MOVE WS-COST TO MN-WDATA(L-ROW, 1)
     MOVE WS-UNITS TO MN-WSEL(L-ROW)
     MOVE WS-ONLY TO MN-WKEEP(L-ROW)
     GOBACK.
 END PROGRAM MENU-ANVIL-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-ANVIL-MAYTAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OK.
     MOVE 0 TO L-OK
     IF MN-RESULT-COUNT(L-ROW) > 0 AND MN-WDATA(L-ROW, 1) > 0
             AND (PL-MODE(L-ROW) = 1 OR PL-XP-LEVEL(L-ROW) >= MN-WDATA(L-ROW, 1))
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MENU-ANVIL-MAYTAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-TAKE-LEVELS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-PROGRESS            FLOAT-SHORT.
 01 WS-LEVEL               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LEVELS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-LEVELS.
     COMPUTE WS-LEVEL = PL-XP-LEVEL(L-ROW) - L-LEVELS
     IF WS-LEVEL < 0
         MOVE 0 TO PL-XP-LEVEL(L-ROW) PL-XP-POINTS(L-ROW) PL-XP-TOTAL(L-ROW)
     ELSE
         MOVE WS-LEVEL TO PL-XP-LEVEL(L-ROW)
     END-IF
     CALL "XP-NEEDED" USING PL-XP-LEVEL(L-ROW) WS-NEEDED
     COMPUTE WS-PROGRESS = PL-XP-POINTS(L-ROW) / WS-NEEDED
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "SET-EXPERIENCE-BUILD" USING WS-PROGRESS PL-XP-LEVEL(L-ROW) PL-XP-TOTAL(L-ROW) PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM XP-TAKE-LEVELS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-ANVIL-TAKEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-COST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE MN-WDATA(L-ROW, 1) TO WS-COST
     IF PL-MODE(L-ROW) NOT = 1
         CALL "XP-TAKE-LEVELS" USING L-ROW WS-COST
     END-IF
*>   The right slot: the repair units come off it, an item-item or book merge uses it up, a pure rename leaves it.
     IF MN-WSEL(L-ROW) > 0
         IF MN-WSLOT-COUNT(L-ROW, 2) > MN-WSEL(L-ROW)
             SUBTRACT MN-WSEL(L-ROW) FROM MN-WSLOT-COUNT(L-ROW, 2)
         ELSE
             MOVE 0 TO MN-WSLOT-ITEM(L-ROW, 2) MN-WSLOT-COUNT(L-ROW, 2) MN-WSLOT-VAR(L-ROW, 2)
         END-IF
     ELSE
         IF MN-WKEEP(L-ROW) = 0
             MOVE 0 TO MN-WSLOT-ITEM(L-ROW, 2) MN-WSLOT-COUNT(L-ROW, 2) MN-WSLOT-VAR(L-ROW, 2)
         END-IF
     END-IF
     MOVE 0 TO MN-WDATA(L-ROW, 1)
     MOVE 0 TO MN-WSLOT-ITEM(L-ROW, 1) MN-WSLOT-COUNT(L-ROW, 1) MN-WSLOT-VAR(L-ROW, 1)
     CALL "MENU-STATION-UPDATE" USING L-ROW
*>   The take sound and the damage of the block (40-3 section 3 step 6; 57-client-closures-2 section 3.2): a survival player rolls 12 percent when the block is an anvil.
     CALL "ANVIL-USED" USING L-ROW
     GOBACK.
 END PROGRAM MENU-ANVIL-TAKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ANVIL-USED.
*> USING player row: onTake of the anvil result at the menu's block: with infinite materials (creative) or a block outside the tag anvil nothing is drawn and Level Event 1030 is sent;
*> else one draw (nextFloat < 0.12): the anvil becomes chipped_anvil, chipped_anvil damaged_anvil (the facing kept, event 1030), and a damaged_anvil is removed (event 1029).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-STAGE               BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-ROLL                FLOAT-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9300.
 01 WS-THOUSAND            BINARY-LONG VALUE 1000.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-NEXT-KEY            PIC X(48).
 01 WS-NEW-STATE           BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WORLD-GET-BLOCK" USING MN-BENCH-DIM(L-ROW) MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW) MN-BENCH-Z(L-ROW) WS-STATE
     CALL "MENU-STATION-KIND" USING WS-STATE WS-KIND
     MOVE 0 TO WS-TAG WS-STAGE WS-OFFSET
     IF WS-KIND = 4
         MOVE 1 TO WS-TAG
         MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
         CALL "KEY-BARE" USING WS-KEY WS-BARE
         EVALUATE WS-BARE
             WHEN "chipped_anvil"
                 MOVE 1 TO WS-STAGE
             WHEN "damaged_anvil"
                 MOVE 2 TO WS-STAGE
         END-EVALUATE
         COMPUTE WS-OFFSET = WS-STATE - CB-DEFAULT-STATE(CB-S-BLOCK(WS-STATE + 1) + 1)
     END-IF
     MOVE 0 TO WS-CREATIVE WS-ROLL
     IF PL-MODE(L-ROW) = 1
         MOVE 1 TO WS-CREATIVE
     END-IF
     IF WS-CREATIVE = 0 AND WS-TAG = 1
         CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-DRAW
         COMPUTE WS-ROLL = WS-DRAW / 1000
     END-IF
     CALL "MN3-ANVIL-DAMAGE" USING WS-CREATIVE WS-TAG WS-ROLL WS-STAGE WS-DRAWN WS-NEW WS-EVENT
     EVALUATE WS-NEW
         WHEN 1
             MOVE "minecraft:chipped_anvil" TO WS-NEXT-KEY
         WHEN 2
             MOVE "minecraft:damaged_anvil" TO WS-NEXT-KEY
     END-EVALUATE
     IF WS-NEW = 1 OR WS-NEW = 2
         CALL "GEN-BLOCK-STATE" USING WS-NEXT-KEY WS-NEW-STATE
         COMPUTE WS-NEW-STATE = WS-NEW-STATE + WS-OFFSET
         CALL "WORLD-SET-BLOCK" USING MN-BENCH-DIM(L-ROW) MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW) MN-BENCH-Z(L-ROW) WS-NEW-STATE
     END-IF
     IF WS-NEW = 3
         MOVE 0 TO WS-NEW-STATE
         CALL "WORLD-SET-BLOCK" USING MN-BENCH-DIM(L-ROW) MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW) MN-BENCH-Z(L-ROW) WS-NEW-STATE
     END-IF
     CALL "LEVEL-EVENT" USING MN-BENCH-DIM(L-ROW) WS-EVENT MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW) MN-BENCH-Z(L-ROW)
         WS-NONE WS-NONE2
     GOBACK.
 END PROGRAM ANVIL-USED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ANVIL-RENAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-CHARS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BEFORE-ITEM         BINARY-LONG.
 01 WS-BEFORE-COUNT        BINARY-LONG.
 01 WS-BEFORE-VAR          BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF MN-WINDOW(WS-ROW) = 0 OR MN-CFAMILY(WS-ROW) NOT = 24
         GOBACK
     END-IF
*>   filterText (3.7): a character is kept unless it is the section sign (C2 A7), below 32 or 127; more than 50 characters (or bytes the patch cannot hold) refuse the name.
     MOVE SPACES TO WS-NAME
     MOVE 0 TO WS-LEN WS-CHARS
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I > PSB-MESSAGE-LENGTH
         COMPUTE WS-BYTE = FUNCTION ORD(PSB-MESSAGE(WS-I:1)) - 1
         EVALUATE TRUE
             WHEN WS-BYTE = 194 AND WS-I < PSB-MESSAGE-LENGTH AND FUNCTION ORD(PSB-MESSAGE(WS-I + 1:1)) - 1 = 167
                 ADD 2 TO WS-I
             WHEN WS-BYTE < 32 OR WS-BYTE = 127
                 ADD 1 TO WS-I
             WHEN OTHER
                 IF WS-BYTE < 128 OR WS-BYTE >= 192
                     ADD 1 TO WS-CHARS
                 END-IF
                 IF WS-LEN < 60
                     ADD 1 TO WS-LEN
                     MOVE PSB-MESSAGE(WS-I:1) TO WS-NAME(WS-LEN:1)
                 ELSE
                     MOVE 99 TO WS-CHARS
                 END-IF
                 ADD 1 TO WS-I
         END-EVALUATE
     END-PERFORM
     IF WS-CHARS > 50
         GOBACK
     END-IF
     IF WS-LEN = MN-WNAME-LEN(WS-ROW) AND (WS-LEN = 0 OR WS-NAME(1:WS-LEN) = MN-WNAME(WS-ROW)(1:WS-LEN))
         GOBACK
     END-IF
     MOVE WS-NAME TO MN-WNAME(WS-ROW)
     MOVE WS-LEN TO MN-WNAME-LEN(WS-ROW)
     MOVE MN-WRES(WS-ROW) TO WS-SLOT
     CALL "MENU-GET-X" USING WS-ROW WS-SLOT WS-BEFORE-ITEM WS-BEFORE-COUNT WS-BEFORE-VAR
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     CALL "MENU-GET-X" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-ITEM NOT = WS-BEFORE-ITEM OR WS-COUNT NOT = WS-BEFORE-COUNT OR WS-VAR NOT = WS-BEFORE-VAR
         CALL "MENU-STATE-RAISE" USING WS-ROW WS-OLD WS-NEW
         CALL "MENU-SLOT-SEND" USING L-ID WS-SLOT
     END-IF
     CALL "MENU-STATION-SYNC" USING WS-ROW
     GOBACK.
 END PROGRAM ANVIL-RENAME.
