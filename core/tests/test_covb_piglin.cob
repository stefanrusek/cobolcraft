*> Implementation test (lane covB; docs/protocol/44-residual-mob-questions-6-nether.md, 20 section 12): the piglin's upkeep and brain paths the acceptance tests leave out: the admiring cool-down
*> counting down, the throw vector at the player's own spot, a loved item whose key carries the namespace (picked up and walked to), repellents (a lit soul campfire, a soul torch keyed with the
*> namespace), a baby's celebration, rows that are no piglin, a baby's step, a hoglin's repellent scan, an avoid point right under the piglin and a full brain table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-PIGLIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY PGBRAIN.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PIGLIN-T            BINARY-LONG.
 01 WS-HOGLIN-T            BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-HOG                 BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-GOLD                BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ZA                  FLOAT-LONG VALUE 0.
 01 WS-ZB                  FLOAT-LONG VALUE 0.
 01 WS-ZC                  FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-CAMPFIRE            BINARY-LONG.
 01 WS-TORCH               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SAVED-KEY           PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DRAW                BINARY-LONG VALUE 0.
 01 WS-SAVED-IKEY          PIC X(48).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-BX = WS-X0 - 24
     COMPUTE WS-BZ = WS-Z0 - 24
     COMPUTE WS-BY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 48 WS-BY 1
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIGLIN-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:hoglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HOGLIN-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:gold_ingot" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-GOLD WS-ITEM-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 8
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-PIGLIN-T WS-X WS-Y WS-Z WS-YAW WS-PIG
     CALL "MOB-SPAWN" USING WS-DIM WS-PIGLIN-T WS-X WS-Y WS-Z WS-YAW WS-BABY
     MOVE -1000 TO EN-MOBAGE(WS-BABY)
     CALL "MOB-SPAWN" USING WS-DIM WS-HOGLIN-T WS-X WS-Y WS-Z WS-YAW WS-HOG
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-X WS-Y WS-Z WS-YAW WS-COW
*>   The admiring cool-down counts down in the piglin's tick.
     MOVE 5 TO EN-ADMIRE-OFF(WS-PIG)
     CALL "PIGLIN-TICK" USING WS-PIG
     MOVE "covB 44-6 3 the admiring cool-down goes down by one a tick" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-ADMIRE-OFF(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The throw vector from a piglin standing exactly on the spot the throw aims at has no direction.
     MOVE WS-PLAYER TO EN-ADMIRE-PL(WS-PIG)
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-PIG)
     COMPUTE EN-Y(WS-PIG) = PL-Y(WS-PLAYER) + 1
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-PIG)
     MOVE 0.5 TO WS-VX
     CALL "PIGLIN-THROW-VEC" USING WS-PIG WS-VX WS-VY WS-VZ
     MOVE "covB 44-6 3.4 a throw at its own spot has no direction" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (FUNCTION ABS(WS-VX) + FUNCTION ABS(WS-VY) + FUNCTION ABS(WS-VZ)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Items keyed with the namespace: a gold ingot on the ground at the piglin is picked up for admiring.
     MOVE 0 TO EN-ADMIRE(WS-PIG) EN-ADMIRE-OFF(WS-PIG) EN-ADMIRE-PL(WS-PIG)
     MOVE IT-KEY(WS-GOLD + 1) TO WS-SAVED-IKEY
     MOVE "minecraft:gold_ingot" TO IT-KEY(WS-GOLD + 1)
     MOVE EN-X(WS-PIG) TO WS-X
     MOVE EN-Y(WS-PIG) TO WS-Y
     MOVE EN-Z(WS-PIG) TO WS-Z
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ZA WS-ZB WS-ZC WS-GOLD WS-ONE WS-ZERO WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-PIG
     MOVE "covB 44-6 3.4 an item whose key carries the namespace is read as the bare key (picked up)" TO TL-CASE
     MOVE 119 TO TL-EXPECTED-N
     MOVE EN-ADMIRE(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-ADMIRE(WS-PIG) TO WS-I
*>   An adult with a loved item ground within 9 blocks walks to it (the key with the namespace again).
     MOVE 0 TO EN-ADMIRE(WS-PIG) EN-ADMIRE-OFF(WS-PIG)
     MOVE 0 TO EN-TARGET(WS-PIG)
     COMPUTE EN-X(WS-PIG) = PL-X(WS-PLAYER) + 8
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-PIG)
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-PIG)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ZA WS-ZB WS-ZC WS-GOLD WS-ONE WS-ZERO WS-DROP
     MOVE 0 TO WS-HX WS-HZ
     CALL "PGB-STEP" USING WS-PIG WS-HX WS-HZ WS-WALK
     MOVE IT-KEY(WS-GOLD + 1) TO WS-SAVED-KEY
     MOVE WS-SAVED-IKEY TO IT-KEY(WS-GOLD + 1)
     MOVE "covB 44-6 4 a piglin walks toward a loved item on the ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Repellents: a lit soul campfire, and a soul torch whose block key carries the namespace.
     MOVE "soul_campfire" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-CAMPFIRE
     MOVE "soul_torch" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-TORCH
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-PIG)) - 3
     MOVE WS-Y0 TO WS-BY
     MOVE WS-Z0 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-CAMPFIRE
     CALL "PGB-REPEL" USING WS-PIG WS-ONE WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "covB 44-6 4 a lit soul campfire repels a piglin" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-ZERO
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-TORCH
     MOVE 0 TO WS-INDEX
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CB-BLOCK-COUNT OR WS-INDEX > 0
         IF CB-KEY(WS-J) = "soul_torch"
             MOVE WS-J TO WS-INDEX
         END-IF
     END-PERFORM
     MOVE CB-KEY(WS-INDEX) TO WS-SAVED-KEY
     MOVE "minecraft:soul_torch" TO CB-KEY(WS-INDEX)
     CALL "PGB-REPEL" USING WS-PIG WS-ONE WS-FOUND WS-RX WS-RY WS-RZ
     MOVE WS-SAVED-KEY TO CB-KEY(WS-INDEX)
     MOVE "covB 44-6 4 a soul torch with a namespaced block key repels too" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-ZERO
*>   A baby piglin does not celebrate.
     CALL "PGB-CELEBRATE" USING WS-BABY WS-COW WS-DRAW
     CALL "PGB-SLOT" USING EN-ID(WS-BABY) WS-ZERO WS-SLOT
     MOVE "covB 44-6 4 a baby piglin keeps no celebration" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Rows that are no piglin or hoglin do not step.
     MOVE 9 TO WS-HX
     CALL "PGB-STEP" USING PL-ENTITY-ROW(WS-PLAYER) WS-HX WS-HZ WS-WALK
     CALL "PGB-STEP" USING WS-COW WS-HX WS-HZ WS-WALK
     MOVE "covB 44-6 4 a cow and a player's row take no brain step" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby piglin and a hoglin on a sensor tick (time + id a multiple of 20).
     COMPUTE CW-TIME = 24000 - FUNCTION MOD(EN-ID(WS-BABY), 20)
     CALL "PGB-STEP" USING WS-BABY WS-HX WS-HZ WS-WALK
     COMPUTE CW-TIME = 24000 - FUNCTION MOD(EN-ID(WS-HOG), 20)
     CALL "PGB-STEP" USING WS-HOG WS-HX WS-HZ WS-WALK
*>   An avoid point right under the piglin: it walks off along +x.
     CALL "PGB-SLOT" USING EN-ID(WS-PIG) WS-ONE WS-SLOT
     MOVE 5 TO PG-AVOID(WS-SLOT)
     MOVE 1 TO PG-AVOID-KIND(WS-SLOT)
     MOVE EN-X(WS-PIG) TO PG-AX(WS-SLOT)
     MOVE EN-Z(WS-PIG) TO PG-AZ(WS-SLOT)
     MOVE 1001 TO CW-TIME
     CALL "PGB-STEP" USING WS-PIG WS-HX WS-HZ WS-WALK
     MOVE "covB 44-6 4 a piglin on its own avoid point walks away along +x" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A full brain table: a new piglin keeps no brain.
     MOVE 1 TO WS-SLOT
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-SLOT = 0
         ADD 1 TO WS-I
         COMPUTE WS-J = 900000 + WS-I
         CALL "PGB-SLOT" USING WS-J WS-ONE WS-SLOT
     END-PERFORM
     COMPUTE WS-X = PL-X(WS-PLAYER) + 9
     CALL "MOB-SPAWN" USING WS-DIM WS-PIGLIN-T WS-X WS-Y WS-Z WS-YAW WS-PIG
     MOVE 9 TO WS-HX
     CALL "PGB-STEP" USING WS-PIG WS-HX WS-HZ WS-WALK
     CALL "PGB-CELEBRATE" USING WS-PIG WS-COW WS-DRAW
     MOVE "covB 44-6 4 with the brain table full a new piglin has no walk" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-PIGLIN.
 COPY CORETEST.
 COPY MOBSPTEST.
