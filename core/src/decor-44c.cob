*> The hooks of the decoration and vehicle entities into the play path (lane 002-lane-mobsb6, T9011).
*>   DECOR-ITEM-USE USING connection id, PLAY-SERVERBOUND (Use Item On), held item, handled out: BLOCK-USE-ON's hook for armor_stand (4.2: not on a down face, the cell and the one above free, yaw
*>     snapped to 45 degrees), item_frame and glow_item_frame (5.3), painting (5.4; the variant list is the stand-in 1 x 1 because the variant registry has no accessor in the core: the standard
*>     variants are open) and the minecart items on a rail (44 part 8 section 4: at the rail height 0.0625, 0.5 higher on a slope; the spawner cart has no item); one item is used up.
*>   DECOR-INTERACT USING player row, entity row, hit y (FLOAT-LONG), done out: MOB-INTERACT's hook: armor stand, item frame, and coal or charcoal on a furnace minecart (MINECART-FUEL; boarding a
*>     plain minecart is open).
*>   DECOR-ATTACK USING player row, entity row, done out: HEALTH-ATTACK's hook: armor stand (ARMOR-STAND-HIT), item frame (ITEM-FRAME-HURT), painting (PAINTING-HURT), interaction (INTERACTION-ATTACK, mob-21-8-9.cob), cushion (CUSHION-HURT, mob-21-8-16.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-ITEM-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EV-PLACE            PIC X(32) VALUE "entity_place".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 01 WS-BELOW               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KIND                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-TY1                 BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-SOLID2              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PLACED              FLOAT-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-RAIL                BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-POWERED             BINARY-LONG.
 01 WS-PLACED-FLAG         BINARY-LONG.
 01 WS-CUSHION             BINARY-LONG.
 01 WS-MC                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-WIDTHS.
    05 WS-W                BINARY-LONG OCCURS 64 TIMES VALUE 1.
 01 WS-HEIGHTS.
    05 WS-H                BINARY-LONG OCCURS 64 TIMES VALUE 1.
 01 WS-IDS.
    05 WS-VID              BINARY-LONG OCCURS 64 TIMES VALUE 0.
 01 WS-VCOUNT              BINARY-LONG.
 01 WS-PSLOT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-ITEM L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF L-ITEM = 0 OR PSB-HAND NOT = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING L-ITEM WS-KEY
     MOVE 0 TO WS-KIND WS-MC WS-GLOW
     EVALUATE WS-KEY
         WHEN "armor_stand"
             MOVE 1 TO WS-KIND
         WHEN "item_frame"
             MOVE 2 TO WS-KIND
         WHEN "glow_item_frame"
             MOVE 2 TO WS-KIND
             MOVE 1 TO WS-GLOW
         WHEN "painting"
             MOVE 3 TO WS-KIND
         WHEN "end_crystal"
             MOVE 5 TO WS-KIND
         WHEN "minecart"
             MOVE 4 TO WS-KIND
             MOVE 1 TO WS-MC
         WHEN "chest_minecart"
             MOVE 4 TO WS-KIND
             MOVE 2 TO WS-MC
         WHEN "hopper_minecart"
             MOVE 4 TO WS-KIND
             MOVE 3 TO WS-MC
         WHEN "furnace_minecart"
             MOVE 4 TO WS-KIND
             MOVE 4 TO WS-MC
         WHEN "tnt_minecart"
             MOVE 4 TO WS-KIND
             MOVE 5 TO WS-MC
         WHEN "command_block_minecart"
             MOVE 4 TO WS-KIND
             MOVE 7 TO WS-MC
     END-EVALUATE
     IF WS-KIND = 0
*>       A cushion item (21 section 8.16.1; the dye colour of the item, -1 for any other item) is used by CUSHION-ITEM-USE.
         CALL "CUSHION-KIND" USING L-ITEM WS-CUSHION
         IF WS-CUSHION >= 0
             MOVE 1 TO L-HANDLED
             MOVE CN-PLAYER(L-ID) TO WS-ROW
             CALL "CUSHION-ITEM-USE" USING WS-ROW PLAY-SERVERBOUND L-ITEM WS-PLACED-FLAG
         END-IF
         GOBACK
     END-IF
     MOVE 1 TO L-HANDLED
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     EVALUATE WS-KIND
         WHEN 1
             IF PSB-FACE NOT = 0
                 CALL "DECOR-STEP" USING PSB-FACE WS-DX WS-DY WS-DZ
                 COMPUTE WS-TX = PSB-BX + WS-DX
                 COMPUTE WS-TY = PSB-BY + WS-DY
                 COMPUTE WS-TZ = PSB-BZ + WS-DZ
                 COMPUTE WS-TY1 = WS-TY + 1
                 CALL "GI-SOLID-CELL" USING PL-DIM(WS-ROW) WS-TX WS-TY WS-TZ WS-SOLID
                 CALL "GI-SOLID-CELL" USING PL-DIM(WS-ROW) WS-TX WS-TY1 WS-TZ WS-SOLID2
                 IF WS-SOLID = 0 AND WS-SOLID2 = 0
                     COMPUTE WS-X = WS-TX + 0.5
                     MOVE WS-TY TO WS-Y
                     COMPUTE WS-Z = WS-TZ + 0.5
                     MOVE PL-YAW(WS-ROW) TO WS-YAW
                     CALL "ARMOR-STAND-YAW" USING WS-YAW WS-PLACED
                     CALL "ARMOR-STAND-SPAWN" USING PL-DIM(WS-ROW) WS-X WS-Y WS-Z WS-PLACED WS-NEW
                     IF WS-NEW > 0
                         CALL "MOB-TAKE" USING WS-ROW
*>                       ArmorStandItem.useOn: entity_place at the stand's position, the player as the source (30-8 14.3.3)
                         CALL "GAME-EVENT-BY" USING WS-EV-PLACE WS-NEW PL-ENTITY-ROW(WS-ROW)
                     END-IF
                 END-IF
             END-IF
         WHEN 2
             CALL "ITEM-FRAME-PLACE" USING WS-ROW PSB-BX PSB-BY PSB-BZ PSB-FACE WS-GLOW WS-NEW
             IF WS-NEW > 0
                 CALL "GAME-EVENT-BY" USING WS-EV-PLACE WS-NEW PL-ENTITY-ROW(WS-ROW)
             END-IF
         WHEN 5
             IF PSB-FACE = 1
                 CALL "CRYSTAL-PLACE" USING WS-ROW PSB-BX PSB-BY PSB-BZ WS-PLACED-FLAG
                 IF WS-PLACED-FLAG = 1
*>                   EndCrystalItem.useOn: entity_place at the centre of the cell above the clicked block
                     COMPUTE WS-TY = PSB-BY + 1
                     CALL "GAME-EVENT-CELL" USING PL-DIM(WS-ROW) PSB-BX WS-TY PSB-BZ WS-EV-PLACE PL-ENTITY-ROW(WS-ROW) WS-NO-STATE
                 END-IF
             END-IF
         WHEN 3
             CALL "PAINTING-VARIANTS" USING WS-VCOUNT WS-IDS WS-WIDTHS WS-HEIGHTS
             IF WS-VCOUNT = 0
                 MOVE 1 TO WS-COUNT
                 MOVE 1 TO WS-W(1) WS-H(1)
             ELSE
                 MOVE WS-VCOUNT TO WS-COUNT
             END-IF
             CALL "PAINTING-PLACE" USING PL-DIM(WS-ROW) PSB-BX PSB-BY PSB-BZ PSB-FACE WS-COUNT WS-WIDTHS WS-HEIGHTS WS-NEW
             IF WS-NEW > 0
                 IF WS-VCOUNT > 0
                     CALL "PJ-FIND" USING EN-ID(WS-NEW) WS-PSLOT
                     MOVE WS-VID(PJ-I4(WS-PSLOT)) TO PJ-I4(WS-PSLOT)
                 END-IF
                 CALL "GAME-EVENT-BY" USING WS-EV-PLACE WS-NEW PL-ENTITY-ROW(WS-ROW)
                 CALL "MOB-TAKE" USING WS-ROW
             END-IF
         WHEN OTHER
             CALL "MC-RAIL" USING PL-DIM(WS-ROW) PSB-BX PSB-BY PSB-BZ WS-RAIL WS-SHAPE WS-POWERED
             IF WS-RAIL > 0
                 COMPUTE WS-X = PSB-BX + 0.5
                 COMPUTE WS-Y = PSB-BY + 0.0625
                 IF WS-SHAPE >= 2 AND WS-SHAPE <= 5
                     COMPUTE WS-Y = WS-Y + 0.5
                 END-IF
                 COMPUTE WS-Z = PSB-BZ + 0.5
                 CALL "MINECART-SPAWN" USING WS-MC PL-DIM(WS-ROW) WS-X WS-Y WS-Z WS-NEW
                 IF WS-NEW > 0
*>                   MinecartItem.useOn: entity_place at the centre of the rail cell, the player as the source, the block below the rail as the affected state
                     COMPUTE WS-TY = PSB-BY - 1
                     CALL "WORLD-GET-BLOCK" USING PL-DIM(WS-ROW) PSB-BX WS-TY PSB-BZ WS-BELOW
                     CALL "GAME-EVENT-CELL" USING PL-DIM(WS-ROW) PSB-BX PSB-BY PSB-BZ WS-EV-PLACE PL-ENTITY-ROW(WS-ROW) WS-BELOW
                     CALL "MOB-TAKE" USING WS-ROW
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM DECOR-ITEM-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-INTERACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ADDED               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-HITY                 FLOAT-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-HITY L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     EVALUATE PJ-KIND(WS-SLOT)
         WHEN 11
             CALL "ARMOR-STAND-INTERACT" USING L-ROW L-PLAYER L-HITY L-DONE
         WHEN 12
             CALL "ITEM-FRAME-INTERACT" USING L-ROW L-PLAYER L-DONE
         WHEN 44
             CALL "INTERACTION-USE" USING L-PLAYER L-ROW L-DONE
         WHEN 10
             MOVE SPACES TO WS-KEY
             COMPUTE WS-HELD = PL-HELD(L-PLAYER) + 1
             IF PL-SLOT-COUNT(L-PLAYER, WS-HELD) > 0
                 CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-PLAYER, WS-HELD) WS-KEY
             END-IF
             IF PJ-I1(WS-SLOT) = 4 AND (WS-KEY = "coal" OR WS-KEY = "charcoal")
                 MOVE PL-X(L-PLAYER) TO WS-PX
                 MOVE PL-Z(L-PLAYER) TO WS-PZ
                 CALL "MINECART-FUEL" USING L-ROW WS-PX WS-PZ WS-ADDED
                 IF WS-ADDED = 1
                     CALL "MOB-TAKE" USING L-PLAYER
                 END-IF
                 MOVE 1 TO L-DONE
             END-IF
             IF L-DONE = 0
                 CALL "MINECART-USE" USING L-PLAYER L-ROW L-DONE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM DECOR-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-ATTACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-NO2                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     EVALUATE PJ-KIND(WS-SLOT)
         WHEN 11
             CALL "ARMOR-STAND-HIT" USING L-ROW L-PLAYER L-DONE
             MOVE 1 TO L-DONE
         WHEN 12
             CALL "ITEM-FRAME-HURT" USING L-ROW L-PLAYER WS-NO L-DONE
             MOVE 1 TO L-DONE
         WHEN 13
             CALL "PAINTING-HURT" USING L-ROW L-PLAYER L-DONE
             MOVE 1 TO L-DONE
         WHEN 16
             CALL "CRYSTAL-HURT" USING L-ROW WS-NO WS-NO2 L-PLAYER L-DONE
             MOVE 1 TO L-DONE
         WHEN 44
             CALL "INTERACTION-ATTACK" USING L-PLAYER L-ROW L-DONE
         WHEN 45
             CALL "CUSHION-HURT" USING L-ROW L-PLAYER L-DONE
     END-EVALUATE
     GOBACK.
 END PROGRAM DECOR-ATTACK.
