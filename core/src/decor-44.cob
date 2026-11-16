*> Armor stands (docs/protocol/44 part 9 section 4; lane 002-lane-mobsb6, T9009), PJ-KIND 11: PJ-I1 the client flags (1 small, 4 show arms, 8 no base plate, 16 marker), PJ-I2 disabledSlots
*> (bit id disables, id + 8 taking, id + 16 putting), PJ-I3 lastHit (game ticks), PJ-I4 invisible, PJ-POSE the six poses (head, body, left arm, right arm, left leg, right leg: x y z each, degrees),
*> PJ-EQ the equipment by slot id + 1 (0 main hand, 1 feet, 2 legs, 3 chest, 4 head, 5 off hand; an item id, 0 empty). The tracker row has EN-HEALTH 1 (a marker as for boats).
*> Gaps: the pose and flags metadata (15 to 21) are not sent, equipment is not shown to the viewers (no equipment packet), items carry no components (the slot of an item comes from its key: _helmet,
*> _chestplate, _leggings, _boots, everything else the main hand), name tags and leashes, the mob_griefing rule for mob attackers, fire and explosion damage, the pickable marker box, poses
*> from NBT and the commands, drops pop at the stand's position (Block.popResource's random offset is not modelled), the break sound and particles.
*>
*>   ARMOR-STAND-SPAWN USING dim, x, y, z, yaw (FLOAT-LONG), row out
*>   ARMOR-STAND-YAW USING player yaw, placed yaw out (FLOAT-LONG)
*>   DECOR-ITEM-SLOT USING item id, slot out (equipment slot id of the item)
*>   ARMOR-STAND-SLOT USING stand row, hit y (FLOAT-LONG, relative to the stand), slot out (getClickedSlot)
*>   ARMOR-STAND-INTERACT USING stand row, player row, hit y, done out (1 when it did something or refused)
*>   ARMOR-STAND-HIT USING stand row, player row, done out
*>   DECOR-DROP USING dim, x, y, z (FLOAT-LONG), item id

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMOR-STAND-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:armor_stand".
 01 WS-KIND                BINARY-LONG VALUE 11.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-YAW L-ROW.
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-NONE L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     MOVE 1 TO EN-HEALTH(L-ROW)
     MOVE L-YAW TO EN-YAW(L-ROW)
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE 0 TO PJ-POSE(WS-SLOT, WS-I)
     END-PERFORM
     MOVE -10 TO PJ-POSE(WS-SLOT, 7)
     MOVE -10 TO PJ-POSE(WS-SLOT, 9)
     MOVE -15 TO PJ-POSE(WS-SLOT, 10)
     MOVE 10 TO PJ-POSE(WS-SLOT, 12)
     MOVE -1 TO PJ-POSE(WS-SLOT, 13)
     MOVE -1 TO PJ-POSE(WS-SLOT, 15)
     MOVE 1 TO PJ-POSE(WS-SLOT, 16)
     MOVE 1 TO PJ-POSE(WS-SLOT, 18)
     GOBACK.
 END PROGRAM ARMOR-STAND-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMOR-STAND-YAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-YAW L-OUT.
     COMPUTE WS-W = FUNCTION MOD(L-YAW - 180 + 180, 360) - 180
     COMPUTE WS-Q = (WS-W + 22.5) / 45
     COMPUTE L-OUT = FUNCTION INTEGER(WS-Q) * 45
     GOBACK.
 END PROGRAM ARMOR-STAND-YAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-ITEM-SLOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-TAIL                PIC X(12).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-SLOT.
     MOVE 0 TO L-SLOT
     IF L-ITEM = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING L-ITEM WS-KEY
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY))
     IF WS-LEN >= 7
         COMPUTE WS-START = WS-LEN - 6
         MOVE WS-KEY(WS-START:7) TO WS-TAIL
         IF WS-TAIL = "_helmet"
             MOVE 4 TO L-SLOT
         END-IF
         IF WS-TAIL = "_boots"
             MOVE 1 TO L-SLOT
         END-IF
     END-IF
     IF WS-LEN >= 11
         COMPUTE WS-START = WS-LEN - 10
         MOVE WS-KEY(WS-START:11) TO WS-TAIL
         IF WS-TAIL = "_chestplate"
             MOVE 3 TO L-SLOT
         END-IF
     END-IF
     IF WS-LEN >= 9
         COMPUTE WS-START = WS-LEN - 8
         MOVE WS-KEY(WS-START:9) TO WS-TAIL
         IF WS-TAIL = "_leggings"
             MOVE 2 TO L-SLOT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM DECOR-ITEM-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMOR-STAND-SLOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-SMALL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HITY                 FLOAT-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HITY L-SLOT.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-P
     MOVE 0 TO L-SLOT
     MOVE 0 TO WS-SMALL
     IF FUNCTION MOD(PJ-I1(WS-P), 2) = 1
         MOVE 1 TO WS-SMALL
     END-IF
     IF WS-SMALL = 1
         COMPUTE WS-Y = L-HITY / 0.5
     ELSE
         MOVE L-HITY TO WS-Y
     END-IF
     EVALUATE TRUE
         WHEN PJ-EQ(WS-P, 2) > 0 AND WS-Y >= 0.1 AND WS-Y < 0.1 + 0.45 + WS-SMALL * 0.35
             MOVE 1 TO L-SLOT
         WHEN PJ-EQ(WS-P, 4) > 0 AND WS-Y >= 0.9 + WS-SMALL * 0.3 AND WS-Y < 0.9 + 0.7 + WS-SMALL * 0.3
             MOVE 3 TO L-SLOT
         WHEN PJ-EQ(WS-P, 3) > 0 AND WS-Y >= 0.4 AND WS-Y < 0.4 + 0.8 + WS-SMALL * 0.2
             MOVE 2 TO L-SLOT
         WHEN PJ-EQ(WS-P, 5) > 0 AND WS-Y >= 1.6
             MOVE 4 TO L-SLOT
         WHEN PJ-EQ(WS-P, 1) = 0 AND PJ-EQ(WS-P, 6) > 0
             MOVE 5 TO L-SLOT
     END-EVALUATE
     GOBACK.
 END PROGRAM ARMOR-STAND-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-BIT.
*> USING value, bit number, result out (1 when the bit is set).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-BIT                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-BIT L-RESULT.
     COMPUTE WS-Q = FUNCTION INTEGER(L-VALUE / 2 ** L-BIT)
     COMPUTE L-RESULT = FUNCTION MOD(WS-Q, 2)
     GOBACK.
 END PROGRAM DECOR-BIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ITEM.
     IF L-ITEM > 0
         CALL "GI-SPAWN" USING L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 L-ITEM WS-ONE WS-DELAY WS-ROW
     END-IF
     GOBACK.
 END PROGRAM DECOR-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMOR-STAND-SWAP.
*> USING stand row, slot id, player row, ok out: swapItem (4.3) with the held stack of the player's main hand.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-PLAYER L-OK.
     MOVE 0 TO L-OK
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-P
     MOVE PJ-EQ(WS-P, L-SLOT + 1) TO WS-CUR
     COMPUTE WS-HELD = PL-HELD(L-PLAYER) + 1
     MOVE 0 TO WS-ITEM WS-COUNT
     IF PL-SLOT-COUNT(L-PLAYER, WS-HELD) > 0
         MOVE PL-SLOT-ITEM(L-PLAYER, WS-HELD) TO WS-ITEM
         MOVE PL-SLOT-COUNT(L-PLAYER, WS-HELD) TO WS-COUNT
     END-IF
     COMPUTE WS-BIT = L-SLOT + 8
     CALL "DECOR-BIT" USING PJ-I2(WS-P) WS-BIT WS-SET
     IF WS-CUR > 0 AND WS-SET = 1
         GOBACK
     END-IF
     COMPUTE WS-BIT = L-SLOT + 16
     CALL "DECOR-BIT" USING PJ-I2(WS-P) WS-BIT WS-SET
     IF WS-CUR = 0 AND WS-SET = 1
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN PL-MODE(L-PLAYER) = 1 AND WS-CUR = 0 AND WS-COUNT > 0
             MOVE WS-ITEM TO PJ-EQ(WS-P, L-SLOT + 1)
             MOVE 1 TO L-OK
         WHEN WS-COUNT > 1
             IF WS-CUR = 0
                 MOVE WS-ITEM TO PJ-EQ(WS-P, L-SLOT + 1)
                 CALL "INV-REMOVE" USING L-PLAYER PL-HELD(L-PLAYER) WS-ONE WS-SET
                 CALL "INV-SLOT-SEND" USING PL-CONN(L-PLAYER) PL-HELD(L-PLAYER)
                 MOVE 1 TO L-OK
             END-IF
         WHEN OTHER
             MOVE WS-ITEM TO PJ-EQ(WS-P, L-SLOT + 1)
             MOVE WS-CUR TO PL-SLOT-ITEM(L-PLAYER, WS-HELD)
             IF WS-CUR > 0
                 MOVE 1 TO PL-SLOT-COUNT(L-PLAYER, WS-HELD)
             ELSE
                 MOVE 0 TO PL-SLOT-COUNT(L-PLAYER, WS-HELD)
             END-IF
             CALL "INV-SLOT-SEND" USING PL-CONN(L-PLAYER) PL-HELD(L-PLAYER)
             MOVE 1 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM ARMOR-STAND-SWAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMOR-STAND-INTERACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-SLOT           BINARY-LONG.
 01 WS-CLICKED             BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DISABLED            BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ARMS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-HITY                 FLOAT-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-HITY L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-P
     IF WS-P = 0 OR FUNCTION MOD(FUNCTION INTEGER(PJ-I1(WS-P) / 16), 2) = 1 OR PL-MODE(L-PLAYER) = 3
         GOBACK
     END-IF
     MOVE 0 TO WS-ARMS
     IF FUNCTION MOD(FUNCTION INTEGER(PJ-I1(WS-P) / 4), 2) = 1
         MOVE 1 TO WS-ARMS
     END-IF
     COMPUTE WS-HELD = PL-HELD(L-PLAYER) + 1
     MOVE 0 TO WS-ITEM
     IF PL-SLOT-COUNT(L-PLAYER, WS-HELD) > 0
         MOVE PL-SLOT-ITEM(L-PLAYER, WS-HELD) TO WS-ITEM
     END-IF
     CALL "DECOR-ITEM-SLOT" USING WS-ITEM WS-ITEM-SLOT
*>   An item whose slot is disabled (or a hand slot with the arms hidden) falls back to the main hand.
     CALL "DECOR-BIT" USING PJ-I2(WS-P) WS-ITEM-SLOT WS-DISABLED
     IF WS-DISABLED = 1
         MOVE 0 TO WS-ITEM-SLOT
     END-IF
     IF WS-ITEM = 0
         CALL "ARMOR-STAND-SLOT" USING L-ROW L-HITY WS-CLICKED
         CALL "DECOR-BIT" USING PJ-I2(WS-P) WS-CLICKED WS-DISABLED
         IF WS-DISABLED = 1 OR (WS-CLICKED = 0 AND WS-ARMS = 0) OR (WS-CLICKED = 5 AND WS-ARMS = 0)
             MOVE WS-ITEM-SLOT TO WS-SLOT
         ELSE
             MOVE WS-CLICKED TO WS-SLOT
         END-IF
         IF PJ-EQ(WS-P, WS-SLOT + 1) > 0
             CALL "ARMOR-STAND-SWAP" USING L-ROW WS-SLOT L-PLAYER WS-OK
             MOVE WS-OK TO L-DONE
         END-IF
         GOBACK
     END-IF
     CALL "DECOR-BIT" USING PJ-I2(WS-P) WS-ITEM-SLOT WS-DISABLED
     IF WS-DISABLED = 1 OR ((WS-ITEM-SLOT = 0 OR WS-ITEM-SLOT = 5) AND WS-ARMS = 0)
         MOVE 1 TO L-DONE
         GOBACK
     END-IF
     CALL "ARMOR-STAND-SWAP" USING L-ROW WS-ITEM-SLOT L-PLAYER WS-OK
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM ARMOR-STAND-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMOR-STAND-BREAK.
*> USING stand row, drop the stand item (1) or not (0): brokenByAnything drops every worn item; the stand is removed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:armor_stand".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SELF                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SELF.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-P
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     COMPUTE WS-Y1 = WS-Y + 1
     IF L-SELF = 1
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         CALL "DECOR-DROP" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM
     END-IF
     IF L-SELF NOT = 2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
             CALL "DECOR-DROP" USING WS-DIM WS-X WS-Y1 WS-Z PJ-EQ(WS-P, WS-I)
         END-PERFORM
     END-IF
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM ARMOR-STAND-BREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMOR-STAND-HIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY PROTO.
 01 WS-P                   BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 32.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-SELF                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-P
     IF WS-P = 0 OR FUNCTION MOD(FUNCTION INTEGER(PJ-I1(WS-P) / 16), 2) = 1 OR PJ-I4(WS-P) = 1
         GOBACK
     END-IF
     MOVE 1 TO L-DONE
     IF PL-MODE(L-PLAYER) = 1
         MOVE 2 TO WS-SELF
         CALL "ARMOR-STAND-BREAK" USING L-ROW WS-SELF
         GOBACK
     END-IF
     COMPUTE WS-DIFF = CW-TICKS - PJ-I3(WS-P)
     IF WS-DIFF <= 5
         MOVE 1 TO WS-SELF
         CALL "ARMOR-STAND-BREAK" USING L-ROW WS-SELF
         GOBACK
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
     CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE CW-TICKS TO PJ-I3(WS-P)
     GOBACK.
 END PROGRAM ARMOR-STAND-HIT.
