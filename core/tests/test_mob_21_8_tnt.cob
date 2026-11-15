*> Implementation test (002-lane-mobsfull-h22; docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md section 8.3, primed TNT): flint and steel or a fire charge on a
*> TNT block turns it into a primed TNT entity (fuse 80 in EN-SWELL, velocity (-sin a x 0.02, 0.2, -cos a x 0.02)); each tick (TNT-TICK) it takes gravity 0.04, moves, drags by 0.98,
*> on the ground (0.7, -0.5, 0.7), the fuse falls by 1 and at 0 it vanishes with an explosion of power 4 at y + 0.0625 when the rule tnt_explodes holds.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-TNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PLAYPKT.
 01 WS-CASE                PIC X(120).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-TNT-STATE           BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-H                   FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-HP                  FLOAT-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-STONE              BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:tnt" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TNT-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MS-TEST-STATE" USING WS-KEY WS-TNT-STATE
     MOVE PL-HELD(WS-PLAYER) TO WS-HELD
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 7
     COMPUTE WS-BY = WS-FY + 1
     MOVE FUNCTION INTEGER(PL-Z(WS-PLAYER)) TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-TNT-STATE
     MOVE WS-BX TO PSB-BX
     MOVE WS-BY TO PSB-BY
     MOVE WS-BZ TO PSB-BZ
     MOVE 1 TO PSB-FACE
     MOVE 0 TO PSB-HAND
     MOVE "minecraft:fire_charge" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD + 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM FIND-TNT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "implementation 21§8.3 a fire charge on a TNT block is handled" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-DONE TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the TNT block is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATE TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 one primed TNT entity exists" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the fire charge is used up" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the fuse is 80" TO WS-CASE
     MOVE 80 TO WS-E
     MOVE EN-SWELL(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 it starts at the block's bottom centre (x, tenths)" TO WS-CASE
     COMPUTE WS-E = WS-BX * 10 + 5
     COMPUTE WS-O = FUNCTION INTEGER(EN-X(WS-ROW) * 10 + 0.5)
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the upward speed is 0.2 (thousandths)" TO WS-CASE
     MOVE 200 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VY(WS-ROW) * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the horizontal speed is 0.02 (ten-thousandths)" TO WS-CASE
     MOVE 200 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(FUNCTION SQRT(EN-VX(WS-ROW) * EN-VX(WS-ROW) + EN-VZ(WS-ROW) * EN-VZ(WS-ROW)) * 10000 + 0.5)
     PERFORM CHECK-N
     MOVE EN-Y(WS-ROW) TO WS-Y0
     CALL "TNT-TICK"
     MOVE "implementation 21§8.3 a tick lowers the fuse by 1" TO WS-CASE
     MOVE 79 TO WS-E
     MOVE EN-SWELL(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the first tick rises by (0.2 - 0.04) (thousandths)" TO WS-CASE
     MOVE 160 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((EN-Y(WS-ROW) - WS-Y0) * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the velocity after the first tick is 0.16 x 0.98 (ten-thousandths)" TO WS-CASE
     MOVE 1568 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VY(WS-ROW) * 10000 + 0.5)
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "TNT-TICK"
     END-PERFORM
     COMPUTE WS-H = EN-Y(WS-ROW) - WS-BY
     MOVE "implementation 21§8.3 after 41 ticks it rests on the floor (height above the floor, thousandths)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(WS-H * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 and is on the ground" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-ON-GROUND(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the fuse is 39 after 41 ticks" TO WS-CASE
     MOVE 39 TO WS-E
     MOVE EN-SWELL(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 38
         CALL "TNT-TICK"
     END-PERFORM
     PERFORM FIND-TNT
     MOVE "implementation 21§8.3 one tick before the end it still exists" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     CALL "TNT-TICK"
     PERFORM FIND-TNT
     MOVE "implementation 21§8.3 at fuse 0 the entity is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the explosion hurt the player 7 blocks away" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PL-HEALTH(WS-PLAYER) < WS-HP
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO WS-AIR
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         PERFORM VARYING WS-J FROM -1 BY 1 UNTIL WS-J > 1
             COMPUTE WS-FX = WS-BX + WS-I
             COMPUTE WS-FZ = WS-BZ + WS-J
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
             IF WS-STATE = 0
                 ADD 1 TO WS-AIR
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "implementation 21§8.3 the explosion blew a hole in the floor under it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-AIR > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   With tnt_explodes false the entity ends without an explosion.
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     COMPUTE WS-BX = WS-BX - 14
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-TNT-STATE
     MOVE WS-BX TO PSB-BX
     MOVE "minecraft:flint_and_steel" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1)
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM FIND-TNT
     MOVE "implementation 21§8.3 flint and steel primes a TNT block as well" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 flint and steel is kept (it only loses durability)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-O
     PERFORM CHECK-N
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         CALL "TNT-TICK"
     END-PERFORM
     PERFORM FIND-TNT
     MOVE "implementation 21§8.3 tnt_explodes false: the entity is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 tnt_explodes false: nobody is hurt" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PL-HEALTH(WS-PLAYER) = WS-HP
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   Walls: a TNT pushed into a stone block on its east or south side stops on that axis; under a stone ceiling it does not rise into it.
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 8
     COMPUTE WS-BY = WS-FY + 1
     COMPUTE WS-I = WS-FX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-BY WS-FZ WS-STONE
     COMPUTE WS-J = WS-FZ + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-J WS-STONE
     COMPUTE WS-I = WS-FX - 5
     COMPUTE WS-J = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-J WS-FZ WS-STONE
     COMPUTE WS-PX = WS-FX + 0.5
     MOVE WS-BY TO WS-PY
     COMPUTE WS-PZ = WS-FZ + 0.5
     CALL "TNT-PRIME" USING WS-DIM WS-PX WS-PY WS-PZ WS-ROW
     MOVE 0.3 TO EN-VX(WS-ROW)
     MOVE 0 TO EN-VY(WS-ROW)
     MOVE 0.3 TO EN-VZ(WS-ROW)
     CALL "TNT-STEP" USING WS-ROW
     MOVE "implementation 21§8.3 a stone block to the east stops the TNT (x kept)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-ROW) = WS-PX AND EN-VX(WS-ROW) = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "implementation 21§8.3 the same for the south side" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-Z(WS-ROW) = WS-PZ AND EN-VZ(WS-ROW) = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-PX = WS-FX - 4.5
     CALL "TNT-PRIME" USING WS-DIM WS-PX WS-PY WS-PZ WS-ROW
     MOVE 0 TO EN-VX(WS-ROW) EN-VZ(WS-ROW)
     MOVE 0.5 TO EN-VY(WS-ROW)
     CALL "TNT-STEP" USING WS-ROW
     MOVE "implementation 21§8.3 a stone ceiling keeps the rising TNT where it was" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-Y(WS-ROW) = WS-PY
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     STOP RUN.
 FIND-TNT.
     MOVE 0 TO WS-COUNT WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TNT-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-TNT.
 COPY CORETEST.
 COPY MOBSPTEST.
