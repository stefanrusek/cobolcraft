*> Cushion placement, survival and breaking (docs/protocol/21 section 8.16.1, 44-9 section 8.1; task T39200, T2648/T2649): CUSHION-ITEM-USE (the UP face, the seat origin at the
*> cell centre and the exact click height, canBePlacedAt = anchor below and not covered and not buried, one cushion per box, the click re-clipped against the collision shape
*> of a hopper, yaw snapped to four directions, one item used), CUSHION-STEP (the survival check every 100 ticks), CUSHION-HURT (the break drops the item of the colour).
*> The block shapes are the real ones (BSH-BUILD); the expected numbers come from the document (hopper cavity floor 11/16 of doc 51 R-E6; slab top 0.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-16.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROJSTATE.
 COPY PLAYPKT.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-CUSHION-ITEM        BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-HELD-SLOT           BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW1                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-DROPS0              BINARY-LONG.
 01 WS-DROPS1              BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 12.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-FLOOR-Y             BINARY-LONG VALUE 150.
 01 WS-TICKS               BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "entity_drops".
 01 WS-RULE-ON             BINARY-DOUBLE.
 01 WS-RULE-OFF            BINARY-DOUBLE VALUE 0.
 01 WS-RULE-ROW            BINARY-LONG.
 01 WS-MILLI               BINARY-DOUBLE.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-COUNT           BINARY-LONG.
 01 WS-TAG-KEYS.
    05 WS-TAG-KEY          PIC X(112) OCCURS 8 TIMES.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 8 TIMES.
 01 WS-N1                  BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-VISUAL              BINARY-LONG VALUE 1.
 01 WS-BOLT                BINARY-LONG.
 01 WS-DIAMOND             BINARY-LONG.
 01 WS-YAW-F               FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-FILL-ID             BINARY-LONG.
 01 WS-FILL-KIND           BINARY-LONG VALUE 1.
 01 WS-FILL-SLOT           BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "BSH-BUILD"
     MOVE "N" TO TL-MODE
*>   The block tags the document names (a standard set built from the generated rows carries no tag data): members by key.
     MOVE "minecraft:causes_suffocation" TO WS-TAG
     MOVE 1 TO WS-TAG-COUNT
     MOVE "minecraft:stone" TO WS-TAG-KEY(1)
     PERFORM PUT-TAG
     MOVE "minecraft:fire" TO WS-TAG
     MOVE 2 TO WS-TAG-COUNT
     MOVE "minecraft:fire" TO WS-TAG-KEY(1)
     MOVE "minecraft:soul_fire" TO WS-TAG-KEY(2)
     PERFORM PUT-TAG
     MOVE "minecraft:cushion_uses_collision_shape" TO WS-TAG
     MOVE 6 TO WS-TAG-COUNT
     MOVE "minecraft:cauldron" TO WS-TAG-KEY(1)
     MOVE "minecraft:water_cauldron" TO WS-TAG-KEY(2)
     MOVE "minecraft:lava_cauldron" TO WS-TAG-KEY(3)
     MOVE "minecraft:powder_snow_cauldron" TO WS-TAG-KEY(4)
     MOVE "minecraft:hopper" TO WS-TAG-KEY(5)
     MOVE "minecraft:composter" TO WS-TAG-KEY(6)
     PERFORM PUT-TAG
     MOVE "minecraft:replaceable" TO WS-TAG
     MOVE 2 TO WS-TAG-COUNT
     MOVE "minecraft:short_grass" TO WS-TAG-KEY(1)
     MOVE "minecraft:snow" TO WS-TAG-KEY(2)
     PERFORM PUT-TAG
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 2
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 2
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR-Y WS-STONE-KIND
     MOVE "minecraft:blue_cushion" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CUSHION-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-HELD-SLOT = PL-HELD(WS-PLAYER) + 1
     MOVE WS-CUSHION-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD-SLOT)
     MOVE 30 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT)
     MOVE 100 TO PL-YAW(WS-PLAYER)
     INITIALIZE PLAY-SERVERBOUND
     MOVE 0 TO PSB-HAND
     MOVE 0.5 TO PSB-CURSOR-X
     MOVE 0.5 TO PSB-CURSOR-Z
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-ON
*>   The item is blue_cushion: its registry index is the first cushion (white) plus the dye id 11.
     MOVE "acceptance US15 21§8.16.1 the held item is a cushion of the registry" TO WS-CASE
     MOVE 1 TO WS-E
     IF WS-CUSHION-ITEM > 0
         MOVE 1 TO WS-O
     ELSE
         MOVE 0 TO WS-O
     END-IF
     PERFORM CHECK-N

*>   1. The top of a full block: seat origin = cell centre, exact click height; colour, yaw snapped to 90 (100 degrees), one item used.
     COMPUTE WS-CX = WS-X0 + 1
     MOVE WS-FLOOR-Y TO WS-CY
     COMPUTE WS-CZ = WS-Z0 + 1
     MOVE 1.0 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a click on the top face of stone places one cushion" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the item use is handled" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 one cushion item is used up (30 to 29)" TO WS-CASE
     MOVE 29 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-O
     PERFORM CHECK-N
     MOVE WS-ROW TO WS-ROW1
     MOVE "acceptance US15 21§8.16.1 x is the centre of the cell above the click (millis)" TO WS-CASE
     COMPUTE WS-E = (WS-X0 + 1) * 1000 + 500
     COMPUTE WS-O = EN-X(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 z is the centre of the cell above the click (millis)" TO WS-CASE
     COMPUTE WS-E = (WS-Z0 + 1) * 1000 + 500
     COMPUTE WS-O = EN-Z(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 y is the exact click height 151.0 (millis)" TO WS-CASE
     MOVE 151000 TO WS-E
     COMPUTE WS-O = EN-Y(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the colour is the dye of the item (blue, 11)" TO WS-CASE
     MOVE 11 TO WS-E
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-J
     MOVE PJ-I1(WS-J) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the yaw 100 snaps to the nearest of four directions, 90" TO WS-CASE
     MOVE 90 TO WS-E
     COMPUTE WS-O = EN-YAW(WS-ROW) + 0.5
     PERFORM CHECK-N

*>   2. A side face fails; the item is kept.
     MOVE 2 TO PSB-FACE
     COMPUTE WS-CX = WS-X0 + 3
     PERFORM CLICK-FACE
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a click on a side face fails: still one cushion" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 a failed use keeps the item (29)" TO WS-CASE
     MOVE 29 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-O
     PERFORM CHECK-N

*>   3. The same place again: a cushion already overlaps the box.
     COMPUTE WS-CX = WS-X0 + 1
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a second cushion in the same box is refused" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the refused use keeps the item (29)" TO WS-CASE
     MOVE 29 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-O
     PERFORM CHECK-N

*>   4. A bottom slab: its outline is half a block, the click height is 150.5 and the cushion sits there.
     MOVE "minecraft:stone_slab" TO WS-KEY
     PERFORM BLOCK-STATE
     COMPUTE WS-CX = WS-X0 + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE 0.5 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 the top of a bottom slab takes a cushion (two in all)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the slab cushion is at the click height 150.5 (millis)" TO WS-CASE
     MOVE 150500 TO WS-E
     COMPUTE WS-O = EN-Y(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N

*>   5. Sunk into a full block: the click height 150.9 leaves the bottom 1/64 of the box inside stone (isAnchorBuried).
     COMPUTE WS-CX = WS-X0 + 7
     MOVE 0.9 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a box whose base is buried in a full block is refused" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N

*>   6. Nothing below: a click on an air cell two above the floor has no anchor.
     COMPUTE WS-CX = WS-X0 + 9
     COMPUTE WS-CY = WS-FLOOR-Y + 2
     MOVE 1.0 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a cushion with no block below its base is refused (hasAnchorBelow)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N

*>   7. Covered: the cell the cushion would fill is stone (every block of its box suffocates).
     MOVE WS-FLOOR-Y TO WS-CY
     COMPUTE WS-CX = WS-X0 + 10
     MOVE "minecraft:stone" TO WS-KEY
     PERFORM BLOCK-STATE
     COMPUTE WS-CY = WS-FLOOR-Y + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE WS-FLOOR-Y TO WS-CY
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a box fully inside suffocating blocks is refused (isCoveredBySuffocatingBlocks)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N

*>   8. A hopper (tag cushion_uses_collision_shape): the click 0.0004 above the cavity floor (11/16) is re-clipped against the collision shape: the height becomes 150.6875.
     MOVE "minecraft:hopper" TO WS-KEY
     PERFORM BLOCK-STATE
     COMPUTE WS-CX = WS-X0 + 1
     COMPUTE WS-CZ = WS-Z0 + 5
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR-Y + 5
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     MOVE 0.6879 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a cushion on a hopper's cavity floor is placed (three in all)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the click is re-clipped to the collision shape: y = 150 + 11/16 (ten-thousandths)" TO WS-CASE
     MOVE 1506875 TO WS-E
     COMPUTE WS-O = EN-Y(WS-ROW) * 10000 + 0.5
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 x is the centre of the cell above the hopper (millis)" TO WS-CASE
     COMPUTE WS-E = (WS-X0 + 1) * 1000 + 500
     COMPUTE WS-O = EN-X(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N
*>   The same hopper, a click on the rim height 1.0 over the cavity: the clip ends 1 mm past the click and misses, so the original click height stays.
     MOVE 1.0 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a click at the top of a hopper that the clip misses keeps its height (four in all)" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the kept click height is 151.0 (millis)" TO WS-CASE
     MOVE 151000 TO WS-E
     COMPUTE WS-O = EN-Y(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N

*>   9. Survival: the check runs on every 100th tick. With the floor present it survives; after the floor is removed nothing happens until the 100th step.
     MOVE WS-ROW1 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         CALL "CUSHION-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§8.16.1 with its floor in place the cushion survives the check" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-CX = WS-X0 + 1
     MOVE WS-FLOOR-Y TO WS-CY
     COMPUTE WS-CZ = WS-Z0 + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     PERFORM COUNT-DROPS
     MOVE WS-DROPS1 TO WS-DROPS0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 99
         CALL "CUSHION-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§8.16.1 99 ticks after the last check the cushion without a floor still stands" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "CUSHION-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.16.1 the 100th tick finds no anchor: the cushion is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     PERFORM COUNT-DROPS
     MOVE "acceptance US15 21§8.16.1 the discarded cushion drops its item (one more item entity)" TO WS-CASE
     COMPUTE WS-E = WS-DROPS0 + 1
     MOVE WS-DROPS1 TO WS-O
     PERFORM CHECK-N

*>   10. Fire in the box at placement: the cushion is placed, burns at once and its item drops.
     COMPUTE WS-CX = WS-X0 + 10
     COMPUTE WS-CZ = WS-Z0 + 8
     MOVE "minecraft:fire" TO WS-KEY
     PERFORM BLOCK-STATE
     COMPUTE WS-CY = WS-FLOOR-Y + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE WS-FLOOR-Y TO WS-CY
     PERFORM FIND-CUSHIONS
     MOVE WS-COUNT TO WS-N1
     PERFORM COUNT-DROPS
     MOVE WS-DROPS1 TO WS-DROPS0
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-N2
     MOVE 1.0 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a cushion placed into fire does not stay (destroyIfInFire)" TO WS-CASE
     MOVE WS-N1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the placement used one item" TO WS-CASE
     COMPUTE WS-E = WS-N2 - 1
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-O
     PERFORM CHECK-N
     PERFORM COUNT-DROPS
     MOVE "acceptance US15 21§8.16.1 the burnt cushion dropped its item" TO WS-CASE
     COMPUTE WS-E = WS-DROPS0 + 1
     MOVE WS-DROPS1 TO WS-O
     PERFORM CHECK-N

*>   11. Breaking by a survival player drops the item of its colour; creative drops nothing; entity_drops off drops nothing; adventure may not build.
     COMPUTE WS-CX = WS-X0 + 3
     MOVE WS-FLOOR-Y TO WS-CY
     COMPUTE WS-CZ = WS-Z0 + 3
     MOVE 1.0 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE WS-ROW TO WS-ROW1
     PERFORM COUNT-DROPS
     MOVE WS-DROPS1 TO WS-DROPS0
     MOVE 2 TO PL-MODE(WS-PLAYER)
     CALL "CUSHION-HURT" USING WS-ROW1 WS-PLAYER WS-DONE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance US15 21§8.16 a player who may not build cannot break it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW1) TO WS-O
     PERFORM CHECK-N
     CALL "CUSHION-HURT" USING WS-ROW1 WS-PLAYER WS-DONE
     MOVE "acceptance US15 21§8.16 a survival hit breaks the cushion: handled" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-DONE TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16 the broken cushion is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW1) TO WS-O
     PERFORM CHECK-N
     PERFORM COUNT-DROPS
     MOVE "acceptance US15 21§8.16 it dropped the cushion item of its colour" TO WS-CASE
     COMPUTE WS-E = WS-DROPS0 + 1
     MOVE WS-DROPS1 TO WS-O
     PERFORM CHECK-N
*>   Creative: broken, no drop.
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE WS-ROW TO WS-ROW1
     PERFORM COUNT-DROPS
     MOVE WS-DROPS1 TO WS-DROPS0
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "CUSHION-HURT" USING WS-ROW1 WS-PLAYER WS-DONE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM COUNT-DROPS
     MOVE "acceptance US15 21§8.16 a creative player breaks it and nothing drops" TO WS-CASE
     MOVE WS-DROPS0 TO WS-E
     MOVE WS-DROPS1 TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16 the creative break removed the cushion" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW1) TO WS-O
     PERFORM CHECK-N
*>   The entity_drops rule off: broken, no drop.
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE WS-ROW TO WS-ROW1
     PERFORM COUNT-DROPS
     MOVE WS-DROPS1 TO WS-DROPS0
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-ROW
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-OFF
     CALL "CUSHION-HURT" USING WS-ROW1 WS-PLAYER WS-DONE
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-ON
     PERFORM COUNT-DROPS
     MOVE "acceptance US15 21§8.16 with the entity_drops rule off nothing drops" TO WS-CASE
     MOVE WS-DROPS0 TO WS-E
     MOVE WS-DROPS1 TO WS-O
     PERFORM CHECK-N
*>   A row that is not a cushion is not handled.
     CALL "CUSHION-HURT" USING PL-ENTITY-ROW(WS-PLAYER) WS-PLAYER WS-DONE
     MOVE "acceptance US15 21§8.16 a row that is no cushion is not handled" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-DONE TO WS-O
     PERFORM CHECK-N

*>   12. The play path: Use Item On a bottom slab (cursor 0.5: the click is at 150.5) places a cushion, an attack packet breaks it, a new one falls with its floor in 100 ticks.
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:stone_slab" TO WS-KEY
     PERFORM BLOCK-STATE
     COMPUTE WS-CX = WS-X0 + 8
     MOVE WS-FLOOR-Y TO WS-CY
     COMPUTE WS-CZ = WS-Z0 + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     PERFORM FIND-CUSHIONS
     MOVE WS-COUNT TO WS-N1
     PERFORM COUNT-DROPS
     MOVE WS-DROPS1 TO WS-DROPS0
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-N2
     MOVE 1 TO WS-FACE
     MOVE 5 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-CZ WS-FACE WS-SEQ
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 Use Item On with a cushion in hand places a cushion" TO WS-CASE
     COMPUTE WS-E = WS-N1 + 1
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the packet placement used one item" TO WS-CASE
     COMPUTE WS-E = WS-N2 - 1
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the packet placement is at the slab top 150.5 (millis)" TO WS-CASE
     MOVE 150500 TO WS-E
     COMPUTE WS-O = EN-Y(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR-Y + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 1.5
     CALL "TEST-ATTACK" USING WS-CONN EN-ID(WS-ROW)
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16 an attack packet breaks the cushion" TO WS-CASE
     MOVE WS-N1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     PERFORM COUNT-DROPS
     MOVE "acceptance US15 21§8.16 the attack packet's break dropped the cushion item" TO WS-CASE
     COMPUTE WS-E = WS-DROPS0 + 1
     MOVE WS-DROPS1 TO WS-O
     PERFORM CHECK-N
     MOVE 6 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-CZ WS-FACE WS-SEQ
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a second packet placement on the freed slab works" TO WS-CASE
     COMPUTE WS-E = WS-N1 + 1
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     PERFORM COUNT-DROPS
     MOVE WS-DROPS1 TO WS-DROPS0
     PERFORM VARYING WS-TICKS FROM 1 BY 1 UNTIL WS-TICKS > 100
         CALL "THROWN-TICK"
     END-PERFORM
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 the entity tick checks survival on the 100th tick: the cushion over air is gone" TO WS-CASE
     MOVE WS-N1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     PERFORM COUNT-DROPS
     MOVE "acceptance US15 21§8.16.1 and its item dropped" TO WS-CASE
     COMPUTE WS-E = WS-DROPS0 + 1
     MOVE WS-DROPS1 TO WS-O
     PERFORM CHECK-N

*>   13. Fire that arrives later: the 100th tick burns the cushion (tickAtCheckInterval, destroyIfInFire).
     COMPUTE WS-CX = WS-X0 + 11
     COMPUTE WS-CZ = WS-Z0 + 3
     MOVE 1.0 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE WS-ROW TO WS-ROW1
     MOVE WS-COUNT TO WS-N1
     MOVE "minecraft:soul_fire" TO WS-KEY
     PERFORM BLOCK-STATE
     COMPUTE WS-CY = WS-FLOOR-Y + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     PERFORM COUNT-DROPS
     MOVE WS-DROPS1 TO WS-DROPS0
     PERFORM VARYING WS-TICKS FROM 1 BY 1 UNTIL WS-TICKS > 100
         CALL "CUSHION-STEP" USING WS-ROW1
     END-PERFORM
     MOVE "acceptance US15 21§8.16.1 soul fire in its box burns the cushion on the 100th tick" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW1) TO WS-O
     PERFORM CHECK-N
     PERFORM COUNT-DROPS
     MOVE "acceptance US15 21§8.16.1 the burnt cushion dropped its item" TO WS-CASE
     COMPUTE WS-E = WS-DROPS0 + 1
     MOVE WS-DROPS1 TO WS-O
     PERFORM CHECK-N

*>   14. The hopper's collision shape clips the click from any side: the new face is not UP, so the use fails (the packet said UP). Doc 51 R-E6: walls 2 pixels thick up to 16, spout at the bottom.
     COMPUTE WS-CX = WS-X0 + 1
     MOVE WS-FLOOR-Y TO WS-CY
     COMPUTE WS-CZ = WS-Z0 + 5
     PERFORM FIND-CUSHIONS
     MOVE WS-COUNT TO WS-N1
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-N2
*>   From the west towards the west wall: the segment enters through its west face.
     COMPUTE PL-X(WS-PLAYER) = WS-CX - 3
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR-Y + 0.8 - 1.62
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     MOVE 0.0 TO PSB-CURSOR-X
     MOVE 0.8 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a click re-clipped onto the west face of the hopper wall fails" TO WS-CASE
     MOVE WS-N1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
*>   From the east: the east face.
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 4
     MOVE 1.0 TO PSB-CURSOR-X
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a click re-clipped onto the east face of the hopper wall fails" TO WS-CASE
     MOVE WS-N1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
*>   From the north: the north face.
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ - 3
     MOVE 0.5 TO PSB-CURSOR-X
     MOVE 0.0 TO PSB-CURSOR-Z
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a click re-clipped onto the north face of the hopper wall fails" TO WS-CASE
     MOVE WS-N1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
*>   From the south: the south face.
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 4
     MOVE 1.0 TO PSB-CURSOR-Z
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a click re-clipped onto the south face of the hopper wall fails" TO WS-CASE
     MOVE WS-N1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
*>   From below: the bottom of the spout (facing down) is a down face.
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR-Y - 3 - 1.62
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     MOVE 0.5 TO PSB-CURSOR-Z
     MOVE 0.0 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE "acceptance US15 21§8.16.1 a click re-clipped onto the bottom of the hopper spout fails" TO WS-CASE
     MOVE WS-N1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the refused clicks kept every item" TO WS-CASE
     MOVE WS-N2 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-O
     PERFORM CHECK-N
     MOVE 0.5 TO PSB-CURSOR-X
     MOVE 0.5 TO PSB-CURSOR-Z

*>   15. Not a cushion: another item, another entity, a row without state.
     MOVE "minecraft:diamond" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DIAMOND WS-ITEM-ROW WS-STATUS
     MOVE 1.0 TO PSB-CURSOR-Y
     MOVE WS-FLOOR-Y TO WS-CY
     COMPUTE WS-CX = WS-X0 + 6
     COMPUTE WS-CZ = WS-Z0 + 9
     MOVE WS-CX TO PSB-BX
     MOVE WS-CY TO PSB-BY
     MOVE WS-CZ TO PSB-BZ
     MOVE 1 TO PSB-FACE
     CALL "CUSHION-ITEM-USE" USING WS-PLAYER PLAY-SERVERBOUND WS-DIAMOND WS-USED
     MOVE "acceptance US15 21§8.16.1 an item that is no cushion places nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-YAW-F
     MOVE PL-X(WS-PLAYER) TO WS-FX
     COMPUTE WS-FY = WS-FLOOR-Y + 30
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-FX WS-FY WS-FZ WS-YAW-F WS-ROW
     CALL "CUSHION-HURT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE "acceptance US15 21§8.16 an armor stand is no cushion: the hit is not handled" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-DONE TO WS-O
     PERFORM CHECK-N
     CALL "CUSHION-STEP" USING PL-ENTITY-ROW(WS-PLAYER)
     MOVE "acceptance US15 21§8.16.1 a step of a row without state changes nothing" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(PL-ENTITY-ROW(WS-PLAYER)) TO WS-O
     PERFORM CHECK-N

*>   17. The seat: the rider's feet are 0.35 below the cushion's y (0.25 passenger point less the player's vehicle attachment 0.6), at its x and z; every tick puts the rider back.
     COMPUTE WS-CX = WS-X0 + 2
     MOVE WS-FLOOR-Y TO WS-CY
     COMPUTE WS-CZ = WS-Z0 + 9
     MOVE 1.0 TO PSB-CURSOR-Y
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE WS-ROW TO WS-ROW1
     CALL "CUSHION-USE" USING WS-PLAYER WS-ROW1 WS-USED
     MOVE "acceptance US15 21§8.16.1 a right-click sits the player on the cushion" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the seated player's feet are at the cushion's y less 0.35 (millis: 150650)" TO WS-CASE
     MOVE 150650 TO WS-E
     COMPUTE WS-O = PL-Y(WS-PLAYER) * 1000 + 0.5
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the seated player's x is the cushion's (millis)" TO WS-CASE
     COMPUTE WS-E = (WS-X0 + 2) * 1000 + 500
     COMPUTE WS-O = PL-X(WS-PLAYER) * 1000 + 0.5
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 the seated player's z is the cushion's (millis)" TO WS-CASE
     COMPUTE WS-E = (WS-Z0 + 9) * 1000 + 500
     COMPUTE WS-O = PL-Z(WS-PLAYER) * 1000 + 0.5
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = PL-X(WS-PLAYER) + 5
     CALL "CUSHION-STEP" USING WS-ROW1
     MOVE "acceptance US15 21§8.16.1 a tick puts the rider back on the cushion" TO WS-CASE
     COMPUTE WS-E = (WS-X0 + 2) * 1000 + 500
     COMPUTE WS-O = PL-X(WS-PLAYER) * 1000 + 0.5
     PERFORM CHECK-N
     MOVE 0 TO EN-RIDER(WS-ROW1)
     MOVE 0 TO EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER))

*>   18. A lightning bolt kills the cushions in its box (+-3 around, -3 to +9) and they drop their items; one 4 blocks away stays.
     COMPUTE WS-CX = WS-X0 + 2
     COMPUTE WS-CZ = WS-Z0 + 2
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE WS-ROW TO WS-ROW1
     COMPUTE WS-CZ = WS-Z0 + 4
     PERFORM CLICK-UP
     PERFORM FIND-CUSHIONS
     MOVE WS-ROW TO WS-ROW2
     COMPUTE WS-FX = WS-X0 + 2.5
     COMPUTE WS-FY = WS-FLOOR-Y + 1
     COMPUTE WS-FZ = WS-Z0 + 0.5
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-FX WS-FY WS-FZ WS-VISUAL WS-BOLT
     CALL "PJ-FIND" USING EN-ID(WS-BOLT) WS-J
     PERFORM COUNT-DROPS
     MOVE WS-DROPS1 TO WS-DROPS0
     CALL "LIGHTNING-STRIKE" USING WS-BOLT WS-J
     MOVE "acceptance US15 21§8.16 a lightning bolt kills the cushion 2 blocks from it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW1) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16 the cushion 4 blocks from the bolt is not in its box" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW2) TO WS-O
     PERFORM CHECK-N
     PERFORM COUNT-DROPS
*>   Two cushions are in the box: the new one and the slab cushion of case 4 (2 east, 1 south of the bolt).
     MOVE "acceptance US15 21§8.16 both struck cushions dropped their item (2 more item entities)" TO WS-CASE
     COMPUTE WS-E = WS-DROPS0 + 2
     MOVE WS-DROPS1 TO WS-O
     PERFORM CHECK-N

*>   16. With the state table full no cushion can be made: the use fails and keeps its item (last, it uses up the table).
     PERFORM FIND-CUSHIONS
     MOVE WS-COUNT TO WS-N1
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-N2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         COMPUTE WS-FILL-ID = 900000 + WS-I
         CALL "PJ-ALLOC" USING WS-FILL-ID WS-FILL-KIND WS-FILL-SLOT
     END-PERFORM
     COMPUTE WS-CX = WS-X0 + 6
     MOVE WS-FLOOR-Y TO WS-CY
     COMPUTE WS-CZ = WS-Z0 + 9
     PERFORM CLICK-UP
     MOVE "acceptance US15 21§8.16.1 with the state table full no cushion is made" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.16.1 and the item is kept" TO WS-CASE
     MOVE WS-N2 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CLICK-UP.
     MOVE 1 TO PSB-FACE
     PERFORM CLICK-FACE.

 CLICK-FACE.
     MOVE WS-CX TO PSB-BX
     MOVE WS-CY TO PSB-BY
     MOVE WS-CZ TO PSB-BZ
     CALL "CUSHION-ITEM-USE" USING WS-PLAYER PLAY-SERVERBOUND WS-CUSHION-ITEM WS-USED.

 PUT-TAG.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TAG-COUNT
         MOVE WS-TAG-KEY(WS-I) TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
         MOVE WS-BLOCK TO WS-TAG-ID(WS-I)
     END-PERFORM
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-TAG-COUNT WS-TAG-IDS WS-STATUS.

 BLOCK-STATE.
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT).

*> WS-COUNT = the cushion entities in the table, WS-ROW = the tracker row of the last one.
 FIND-CUSHIONS.
     MOVE 0 TO WS-COUNT WS-ROW WS-BEST
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PJ-MAX
         IF PJ-ENT(WS-J) > 0 AND PJ-KIND(WS-J) = 45
             ADD 1 TO WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
                 IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = PJ-ENT(WS-J) AND EN-ID(WS-I) > WS-BEST
                     MOVE EN-ID(WS-I) TO WS-BEST
                     MOVE WS-I TO WS-ROW
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM.

*> WS-DROPS1 = the item entities of the cushion item.
 COUNT-DROPS.
     MOVE 0 TO WS-DROPS1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0 AND EN-ITEM(WS-I) = WS-CUSHION-ITEM
             ADD 1 TO WS-DROPS1
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-16.
 COPY CORETEST.
 COPY MOBSPTEST.
