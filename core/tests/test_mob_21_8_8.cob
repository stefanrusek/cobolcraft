*> Acceptance test of 21 section 8.8, boats (44 part 8 section 3 and 2): the kinds of the 22 boat types, BOAT-SPAWN, the status of 3.3 (in water, in air), floatBoat of 3.4 (the
*> boat settles where the waterline is 0.65 x 0.5625 above its origin, falls in air with the gravity term -0.04 and re-enters the water at the level above), the out-of-control eject
*> after 60 ticks under water, boarding (3.9: reach, sneaking, one passenger) with the seat of 3.6, a ridden boat left to its rider's client, and hurt and destroy (2: damage 10 x
*> amount, destroyed above 40, a creative attacker removes it without a drop, hurt time and damage decay by 1 a tick).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY RULES.
 COPY PLAYPKT.
 COPY PROTO.
 01 WS-CASE                PIC X(200).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BOAT-ITEM           BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-LEVEL               FLOAT-LONG.
 01 WS-BSTATUS             BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-PLAYER.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-IDS                 PIC X(1024).
 01 WS-OLD                 BINARY-LONG.
 01 WS-FLOW                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-HAND0               BINARY-LONG.
 01 WS-SNEAK0              BINARY-LONG.
 01 WS-MV-ID               BINARY-LONG VALUE 34.
 01 WS-MV-X                FLOAT-LONG.
 01 WS-MV-Y                FLOAT-LONG.
 01 WS-MV-Z                FLOAT-LONG.
 01 WS-MV-ANGLE            FLOAT-SHORT VALUE 0.
 01 WS-MV-FLAGS            BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-Y0                  FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-FKIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:oak_boat" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BOAT-ITEM WS-ITEM-ROW WS-STATUS
*>   Kinds of the boat types.
     MOVE "minecraft:oak_boat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "BOAT-KIND" USING WS-TYPE WS-KIND
     MOVE "acceptance US15 minecraft:oak_boat 21§8.8 a boat is kind 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-KIND TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:oak_chest_boat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "BOAT-KIND" USING WS-TYPE WS-KIND
     MOVE "acceptance US15 minecraft:oak_chest_boat 21§8.8 a chest boat is kind 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-KIND TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:bamboo_raft" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "BOAT-KIND" USING WS-TYPE WS-KIND
     MOVE "acceptance US15 minecraft:bamboo_raft 21§8.8 a raft is kind 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-KIND TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:bamboo_chest_raft" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "BOAT-KIND" USING WS-TYPE WS-KIND
     MOVE "acceptance US15 minecraft:bamboo_chest_raft 21§8.8 a chest raft is kind 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-KIND TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "BOAT-KIND" USING WS-TYPE WS-KIND
     MOVE "acceptance US15 21§8.8 a pig is no boat" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-KIND TO WS-O
     PERFORM CHECK-N
*>   A pool of 3 cells of water (surface 8/9 of the third cell) at BX, BZ.
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 12
     MOVE FUNCTION INTEGER(PL-Z(WS-PLAYER)) TO WS-BZ
     PERFORM VARYING WS-CX FROM -3 BY 1 UNTIL WS-CX > 3
         PERFORM VARYING WS-CZ FROM -3 BY 1 UNTIL WS-CZ > 3
             PERFORM VARYING WS-CY FROM 1 BY 1 UNTIL WS-CY > 3
                 COMPUTE WS-I = WS-BX + WS-CX
                 COMPUTE WS-J = WS-BZ + WS-CZ
                 COMPUTE WS-FX = WS-FY + WS-CY
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-FX WS-J WS-WATER
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     COMPUTE WS-PX = WS-BX + 0.5
     COMPUTE WS-PY = WS-FY + 3.5
     COMPUTE WS-PZ = WS-BZ + 0.5
     MOVE 90 TO WS-YAW
     MOVE "minecraft:oak_boat" TO WS-KEY
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE "acceptance US15 minecraft:oak_boat 21§8.8 BOAT-SPAWN makes a boat row of kind 1, health marker 1, hurt direction 1" TO WS-CASE
     MOVE 111 TO WS-E
     COMPUTE WS-O = EN-BT-KIND(WS-ROW) * 100 + EN-HEALTH(WS-ROW) * 10 + EN-BT-HDIR(WS-ROW)
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 minecraft:oak_boat 21§8.8 the viewer gets Add Entity" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-IDS = "1"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "minecraft:pig" TO WS-KEY
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW2
     MOVE "acceptance US15 21§8.8 BOAT-SPAWN of a key that is no boat makes nothing (row 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ROW2 TO WS-O
     PERFORM CHECK-N
*>   Status in water.
     CALL "BOAT-STATUS" USING WS-ROW WS-BSTATUS
     MOVE "acceptance US15 21§8.8 3.3 a boat whose bottom is in the water is IN_WATER (0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BSTATUS TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.8 3.3 the water level is the surface of the water cell: 8/9 above its floor (ten-thousandths)" TO WS-CASE
     COMPUTE WS-E = 38889
     COMPUTE WS-O = FUNCTION INTEGER((EN-BT-WLEVEL(WS-ROW) - WS-FY) * 10000 + 0.5)
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         CALL "BOAT-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§8.8 3.4 the boat settles with the waterline 0.65 x 0.5625 above its origin (millimetres off, at most 1)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-AMOUNT = FUNCTION INTEGER((EN-Y(WS-ROW) - (WS-FY + 3.888889 - 0.365625)) * 1000 + 0.5)
     MOVE FUNCTION ABS(WS-AMOUNT) TO WS-O
     IF WS-O <= 1
         MOVE 0 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   In the air: the first tick falls by the gravity term and drags x and z by 0.9.
     COMPUTE WS-PY = WS-FY + 6.5
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW2
     MOVE "minecraft:oak_boat" TO WS-KEY
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE 1 TO EN-VX(WS-ROW)
     CALL "BOAT-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.8 3.4 in the air the first tick: status 4, vy -0.04, vx x 0.9" TO WS-CASE
     MOVE 4409 TO WS-E
     COMPUTE WS-O = EN-BT-STATUS(WS-ROW) * 1000 + FUNCTION INTEGER(0 - EN-VY(WS-ROW) * 100 + 0.5) * 100 + FUNCTION INTEGER(EN-VX(WS-ROW) * 10 + 0.5)
     PERFORM CHECK-N
     MOVE 0 TO EN-VX(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         CALL "BOAT-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§8.8 3.4 after falling into the water it floats at the same height again (millimetres off, at most 1)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-AMOUNT = FUNCTION INTEGER((EN-Y(WS-ROW) - (WS-FY + 3.888889 - 0.365625)) * 1000 + 0.5)
     MOVE FUNCTION ABS(WS-AMOUNT) TO WS-O
     IF WS-O <= 1
         MOVE 0 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.8 3.3 and its status is IN_WATER (0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-BT-STATUS(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   The re-entry: repositioned to the level above - 0.5625 + 0.101 with vy 0; a stone in the way keeps the boat and its velocity.
     COMPUTE WS-PY = WS-FY + 3.5
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE -0.3 TO EN-VY(WS-ROW)
     CALL "BOAT-STATUS" USING WS-ROW WS-BSTATUS
     MOVE 4 TO WS-OLD
     CALL "BOAT-FLOAT" USING WS-ROW WS-OLD WS-BSTATUS
     MOVE "acceptance US15 21§8.8 3.4 the re-entry puts the boat at level - 0.5625 + 0.101 (ten-thousandths above the floor cell)" TO WS-CASE
     MOVE 35385 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((EN-Y(WS-ROW) - WS-FY) * 10000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.8 3.4 the re-entry leaves no vertical speed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-VY(WS-ROW) TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-CX = WS-BX - 1
     COMPUTE WS-CY = WS-FY + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-STONE
     COMPUTE EN-Y(WS-ROW) = WS-FY + 3.5
     MOVE -0.3 TO EN-VY(WS-ROW)
     CALL "BOAT-FLOAT" USING WS-ROW WS-OLD WS-BSTATUS
     MOVE "acceptance US15 21§8.8 3.4 a stone in the way of the re-entry keeps the boat's place (ten-thousandths above the floor cell)" TO WS-CASE
     MOVE 35000 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((EN-Y(WS-ROW) - WS-FY) * 10000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.8 3.4 and its speed (thousandths)" TO WS-CASE
     MOVE -300 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VY(WS-ROW) * 1000 - 0.5) + 1
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-NONE
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Re-entering from the air while the boat's top is below the surface: the level above is the surface of the cell (3.3).
     MOVE "minecraft:oak_boat" TO WS-KEY
     COMPUTE WS-PX = WS-BX + 0.5
     COMPUTE WS-PY = WS-FY + 2.9
     COMPUTE WS-PZ = WS-BZ + 0.5
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-STATUS" USING WS-ROW WS-BSTATUS
     MOVE "acceptance US15 21§8.8 3.3 a boat whose top is below the surface is UNDER_WATER (1) and the water level is its top" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-BSTATUS TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-OLD
     CALL "BOAT-FLOAT" USING WS-ROW WS-OLD WS-BSTATUS
     MOVE "acceptance US15 21§8.8 3.4 re-entry below the surface: y = surface - 0.5625 + 0.101 (ten-thousandths above the floor cell)" TO WS-CASE
     MOVE 34274 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((EN-Y(WS-ROW) - WS-FY) * 10000 + 0.5)
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Under flowing water: status 2 and the gravity term -0.0007.
     MOVE WS-WATER TO WS-FLOW
     ADD 1 TO WS-FLOW
     COMPUTE WS-CY = WS-FY + 1
     PERFORM VARYING WS-CX FROM -1 BY 1 UNTIL WS-CX > 1
         PERFORM VARYING WS-CZ FROM 7 BY 1 UNTIL WS-CZ > 9
             COMPUTE WS-I = WS-BX + WS-CX
             COMPUTE WS-J = WS-BZ + WS-CZ
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-CY WS-J WS-FLOW
         END-PERFORM
     END-PERFORM
     COMPUTE WS-PY = WS-FY + 1.1
     COMPUTE WS-PZ = WS-BZ + 8.5
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-STATUS" USING WS-ROW WS-BSTATUS
     MOVE "acceptance US15 21§8.8 3.3 a boat under flowing water is UNDER_FLOWING_WATER (2)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-BSTATUS TO WS-O
     PERFORM CHECK-N
     CALL "BOAT-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.8 3.4 under flowing water the gravity term is -0.0007 (ten-thousandths)" TO WS-CASE
     MOVE 7 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(0 - EN-VY(WS-ROW) * 10000 + 0.5)
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Moving into walls and a ceiling.
     COMPUTE WS-PX = WS-BX + 0.5
     COMPUTE WS-PY = WS-FY + 1
     COMPUTE WS-PZ = WS-BZ - 8.5
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     COMPUTE WS-I = WS-BX + 2
     COMPUTE WS-J = WS-BZ - 8
     COMPUTE WS-CY = WS-FY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-CY WS-J WS-STONE
     COMPUTE WS-I = WS-BX
     COMPUTE WS-J = WS-BZ - 7
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-CY WS-J WS-STONE
     COMPUTE WS-I = WS-BX
     COMPUTE WS-J = WS-BZ - 9
     COMPUTE WS-CY = WS-FY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-CY WS-J WS-STONE
     MOVE 0.9 TO EN-VX(WS-ROW)
     MOVE 0.9 TO EN-VZ(WS-ROW)
     MOVE 0 TO EN-VY(WS-ROW)
     CALL "BOAT-MOVE" USING WS-ROW
     MOVE "acceptance US15 21§8.8 3.2 stone blocks to the east and south stop the boat's sideways speed" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VX(WS-ROW) * 1000) + FUNCTION INTEGER(EN-VZ(WS-ROW) * 1000)
     PERFORM CHECK-N
     MOVE 0.5 TO EN-VY(WS-ROW)
     MOVE 0 TO EN-VX(WS-ROW) EN-VZ(WS-ROW)
     COMPUTE WS-Y0 = EN-Y(WS-ROW)
     CALL "BOAT-MOVE" USING WS-ROW
     MOVE "acceptance US15 21§8.8 3.2 a ceiling keeps the rising boat where it was and stops its speed" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(FUNCTION ABS(EN-Y(WS-ROW) - WS-Y0) * 1000) + FUNCTION INTEGER(EN-VY(WS-ROW) * 1000)
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Boarding: beside the player, on the floor.
     MOVE "minecraft:oak_boat" TO WS-KEY
     COMPUTE WS-PX = PL-X(WS-PLAYER) + 1.5
     COMPUTE WS-PY = WS-FY + 1
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     MOVE 0 TO WS-YAW
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "BOAT-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 21§8.8 3.9 a sneaking player does not board" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-USED + EN-RIDER(WS-ROW)
     PERFORM CHECK-N
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     CALL "BOAT-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 21§8.8 3.9 boarding: the player is the rider and the boat is its vehicle" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-USED = 1 AND EN-RIDER(WS-ROW) = WS-PLAYER AND EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER)) = WS-ROW
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.8 3.6 the rider sits 0.1875 - 0.6 above the boat's origin (ten-thousandths)" TO WS-CASE
     MOVE -4125 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((PL-Y(WS-PLAYER) - EN-Y(WS-ROW)) * 10000 - 0.5) + 1
     PERFORM CHECK-N
     CALL "BOAT-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 21§8.8 3.9 a rider cannot board again and a full boat takes no one" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE EN-Y(WS-ROW) TO WS-Y0
     MOVE 1 TO EN-VX(WS-ROW)
     CALL "BOAT-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.8 3.2 a ridden boat is left to its rider's client: no move, no speed" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(FUNCTION ABS(EN-Y(WS-ROW) - WS-Y0) * 10000) + FUNCTION INTEGER(FUNCTION ABS(EN-VX(WS-ROW)) * 10000)
     PERFORM CHECK-N
     CALL "MOB-RIDE-STOP" USING WS-ROW
*>   A boat too far away.
     COMPUTE EN-X(WS-ROW) = PL-X(WS-PLAYER) + 8
     CALL "BOAT-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 21§8.8 3.9 a boat out of reach is not boarded" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   The packet paths: Interact boards, Move Vehicle moves the boat and its rider follows, Use Item with a boat item.
     MOVE "minecraft:oak_boat" TO WS-KEY
     COMPUTE WS-PX = PL-X(WS-PLAYER) + 1.5
     COMPUTE WS-PY = WS-FY + 1
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     MOVE 0 TO WS-YAW
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-TARGET
     MOVE 0 TO WS-HAND0 WS-SNEAK0
     CALL "TEST-INTERACT" USING WS-CONN WS-TARGET WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 21§8.8 3.9 an Interact packet on a boat boards the player" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-RIDER(WS-ROW) = WS-PLAYER
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     COMPUTE WS-MV-X = EN-X(WS-ROW) + 1.5
     MOVE EN-Y(WS-ROW) TO WS-MV-Y
     MOVE EN-Z(WS-ROW) TO WS-MV-Z
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-MV-ID
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-MV-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-MV-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-MV-Z
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-MV-ANGLE
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-MV-ANGLE
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-MV-FLAGS
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "acceptance US15 21§8.8 3.2 Move Vehicle from the rider's client moves the boat and the rider follows (thousandths)" TO WS-CASE
     COMPUTE WS-E = WS-MV-X * 1000 * 2
     COMPUTE WS-O = EN-X(WS-ROW) * 1000 + PL-X(WS-PLAYER) * 1000
     PERFORM CHECK-N
     CALL "MOB-RIDE-STOP" USING WS-ROW
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-BOAT-ITEM TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM FIND-BOATS
     MOVE "acceptance US15 21§8.8 3.10 a Use Item packet with a boat item looking at nothing places no boat" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
*>   A chest boat turned 90 degrees: the seat is 0.15 aft-offset rotated about the vertical axis.
     MOVE "minecraft:oak_chest_boat" TO WS-KEY
     COMPUTE WS-PX = PL-X(WS-PLAYER) + 1.5
     MOVE 90 TO WS-YAW
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 21§8.8 3.6 a chest boat at yaw 90: the seat is 0.15 along the turned bow (x - 0.15; hundredths)" TO WS-CASE
     MOVE -15 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((PL-X(WS-PLAYER) - EN-X(WS-ROW)) * 100 - 0.5) + 1
     PERFORM CHECK-N
     CALL "MOB-RIDE-STOP" USING WS-ROW
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE "minecraft:bamboo_raft" TO WS-KEY
     MOVE 0 TO WS-YAW
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 21§8.8 3.6 a raft seat is 0.5 - 0.6 above the origin (hundredths)" TO WS-CASE
     MOVE -10 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((PL-Y(WS-PLAYER) - EN-Y(WS-ROW)) * 100 - 0.5) + 1
     PERFORM CHECK-N
     CALL "MOB-RIDE-STOP" USING WS-ROW
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Under water for 60 ticks ejects the rider.
     PERFORM VARYING WS-CX FROM -3 BY 1 UNTIL WS-CX > 3
         PERFORM VARYING WS-CZ FROM -3 BY 1 UNTIL WS-CZ > 3
             PERFORM VARYING WS-CY FROM 4 BY 1 UNTIL WS-CY > 12
                 COMPUTE WS-I = WS-BX + WS-CX
                 COMPUTE WS-J = WS-BZ + WS-CZ
                 COMPUTE WS-FX = WS-FY + WS-CY
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-FX WS-J WS-WATER
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "minecraft:oak_boat" TO WS-KEY
     COMPUTE WS-PX = WS-BX + 0.5
     COMPUTE WS-PY = WS-FY + 8.5
     COMPUTE WS-PZ = WS-BZ + 0.5
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE WS-PLAYER TO EN-RIDER(WS-ROW)
     MOVE WS-ROW TO EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER))
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 59
         CALL "BOAT-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§8.8 3.3 a boat under water is UNDER_WATER (1) and out of control for 59 ticks keeps its rider" TO WS-CASE
     MOVE 1159 TO WS-E
     COMPUTE WS-O = EN-BT-STATUS(WS-ROW) * 1000 + EN-BT-OOC(WS-ROW) + EN-RIDER(WS-ROW) / WS-PLAYER * 100
     PERFORM CHECK-N
     CALL "BOAT-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.8 3.2 on the 60th tick under water the passengers are ejected" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = EN-RIDER(WS-ROW) + EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER))
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   BOAT-USE on something that is no boat, BOAT-TICK (CORE-TICK's entry) on a boat in the air.
     COMPUTE WS-PX = PL-X(WS-PLAYER) + 1
     MOVE WS-FY TO WS-PY
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     CALL "TNT-PRIME" USING WS-DIM WS-PX WS-PY WS-PZ WS-ROW
     CALL "BOAT-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 21§8.8 3.9 BOAT-USE leaves a primed TNT alone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-PY = WS-FY + 5
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-TICK"
     MOVE "acceptance US15 21§8.8 3.2 BOAT-TICK steps every boat: the boat in the air fell by the gravity term (ten-thousandths)" TO WS-CASE
     MOVE 400 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(0 - EN-VY(WS-ROW) * 10000 + 0.5)
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Hurt and destroy.
     MOVE "minecraft:oak_boat" TO WS-KEY
     COMPUTE WS-PY = WS-FY + 1
     COMPUTE WS-PX = PL-X(WS-PLAYER) + 1.5
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE 3 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NONE
     MOVE "acceptance US15 21§8.8 2 a hit of 3: hurt direction flips to -1, hurt time 10, damage 30" TO WS-CASE
     MOVE -8970 TO WS-E
     COMPUTE WS-O = EN-BT-HDIR(WS-ROW) * 10000 + EN-BT-HURT(WS-ROW) * 100 + EN-BT-DAMAGE(WS-ROW)
     PERFORM CHECK-N
     CALL "BOAT-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.8 2 hurt time and damage fall by 1 a tick" TO WS-CASE
     MOVE 929 TO WS-E
     COMPUTE WS-O = EN-BT-HURT(WS-ROW) * 100 + EN-BT-DAMAGE(WS-ROW)
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NONE
     PERFORM FIND-BOATS
     MOVE "acceptance US15 21§8.8 2 the damage 29 + 30 is above 40: the boat is destroyed and drops one oak boat item" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-COUNT = 0 AND WS-ITEMS = 1
         MOVE 1 TO WS-O
     ELSE
         MOVE 0 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "minecraft:oak_boat" TO WS-KEY
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM FIND-BOATS
     MOVE "acceptance US15 21§8.8 2 a creative attacker removes the boat without a drop" TO WS-CASE
     MOVE 1 TO WS-E
     IF WS-COUNT = 0 AND WS-ITEMS = 1
         MOVE 1 TO WS-O
     ELSE
         MOVE 0 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
*>   The boat item: a ray down onto a one-cell pool beside the player.
     COMPUTE WS-CY = WS-FY + 1
     PERFORM VARYING WS-CX FROM 1 BY 1 UNTIL WS-CX > 4
         COMPUTE WS-I = FUNCTION INTEGER(PL-X(WS-PLAYER)) + WS-CX
         MOVE FUNCTION INTEGER(PL-Z(WS-PLAYER)) TO WS-J
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-CY WS-J WS-WATER
     END-PERFORM
     MOVE WS-BOAT-ITEM TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 270 TO PSB-YAW
     MOVE 45 TO PSB-PITCH
     MOVE 0 TO PSB-HAND
     MOVE 270 TO PL-YAW(WS-PLAYER)
     CALL "BOAT-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM FIND-BOATS
     MOVE "acceptance US15 21§8.8 3.10 a boat item aimed at water puts a boat on the water surface and uses one item" TO WS-CASE
     MOVE 1111 TO WS-E
     MOVE 0 TO WS-O
     IF WS-COUNT = 1
         COMPUTE WS-O = 1000 + 100 + PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1) * 10 + WS-DONE * 1
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-BT-KIND(WS-I) > 0
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§8.8 3.10 the boat sits on the surface of the water cell (1.86 to 1.89 above the floor)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     COMPUTE WS-AMOUNT = FUNCTION INTEGER((EN-Y(WS-ROW) - WS-FY) * 100)
     IF WS-AMOUNT >= 186 AND WS-AMOUNT <= 188
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.8 3.10 the boat faces the player's yaw" TO WS-CASE
     MOVE 270 TO WS-E
     COMPUTE WS-O = EN-YAW(WS-ROW)
     PERFORM CHECK-N
     MOVE -90 TO PSB-PITCH
     CALL "BOAT-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM FIND-BOATS
     MOVE "acceptance US15 21§8.8 3.10 a ray into the sky places nothing and keeps the stack" TO WS-CASE
     MOVE 1111 TO WS-E
     COMPUTE WS-O = 1000 + WS-COUNT * 100 + PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1) * 10 + WS-DONE
     PERFORM CHECK-N
     MOVE 45 TO PSB-PITCH
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "BOAT-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance US15 21§8.8 3.10 a creative player keeps the stack" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1) = 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 1 TO PSB-HAND
     CALL "BOAT-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US15 21§8.8 3.10 the off hand is not handled" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-DONE TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PSB-HAND
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     CALL "BOAT-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US15 21§8.8 3.10 an empty hand is not handled" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-DONE TO WS-O
     PERFORM CHECK-N
     MOVE WS-BOAT-ITEM TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 270 TO PSB-YAW
     MOVE 80 TO PSB-PITCH
     CALL "BOAT-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM FIND-BOATS
*>   The ray ends in the floor: the boat is created at the surface where it meets it (44 section 8, the hit location; T63305), its box rests on the floor and does not collide:
*>   a second boat, one more item used.
     MOVE "acceptance US15 21§8.8 3.10 aimed at the floor the boat is put at the surface where the ray meets it and one item is used" TO WS-CASE
     MOVE 20 TO WS-E
     COMPUTE WS-O = WS-COUNT * 10 + PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     PERFORM CHECK-N
*>   Aimed level at a wall the hit location is on the wall's face and the boat's box (1.375 wide) reaches into it: it collides, no boat, the stack is kept (44 section 8).
     MOVE WS-BOAT-ITEM TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 3
     COMPUTE WS-CY = WS-FY + 2
     MOVE FUNCTION INTEGER(PL-Z(WS-PLAYER)) TO WS-J
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-J WS-STONE
     MOVE 0 TO PSB-PITCH
     CALL "BOAT-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM FIND-BOATS
     MOVE "acceptance US15 21§8.8 3.10 aimed at a wall the boat's box would collide: no boat, the stack is kept" TO WS-CASE
     MOVE 21 TO WS-E
     COMPUTE WS-O = WS-COUNT * 10 + PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     PERFORM CHECK-N
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I WS-ITEM-ROW WS-STATUS
     MOVE WS-I TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     CALL "BOAT-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US15 21§8.8 3.10 another item is not handled" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-DONE TO WS-O
     PERFORM CHECK-N
*>   A ridden boat that is destroyed, or removed by a creative attacker, puts its rider off first.
     MOVE "minecraft:oak_boat" TO WS-KEY
     COMPUTE WS-PX = PL-X(WS-PLAYER) + 1.5
     COMPUTE WS-PY = WS-FY + 1
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE 5 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NONE
     MOVE "acceptance US15 21§8.8 2 a destroyed boat puts its rider off" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER)) TO WS-O
     PERFORM CHECK-N
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance US15 21§8.8 2 a boat removed by a creative attacker puts its rider off" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER)) TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 FIND-BOATS.
     MOVE 0 TO WS-COUNT WS-ITEMS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-BT-KIND(WS-I) > 0
             ADD 1 TO WS-COUNT
         END-IF
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-BOAT-ITEM
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-8.
 COPY CORETEST.
 COPY MOBSPTEST.
