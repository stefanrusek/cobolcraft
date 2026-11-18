 *> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 6 and 44-residual-mob-questions-3-villagers-poi-raids.md section 1.6): the
 *> custom spawner list of the Overworld and the cat spawner. Nothing of the list runs when spawn_mobs is false; with it on the cat spawner needs no game rule and no hostile-mob flag. Its
 *> counter is set to 1200 by an attempt (the first call runs at once) and counts down while above 0. An attempt picks a spot 8 to 31 blocks away in x and in z from a random player's block (the
 *> player's y); in a village (a point of interest within two sections) it spawns one cat that is not persistent when more than 4 occupied homes lie within 48 blocks and fewer than 5 cats are in
 *> the box inflated by (48, 8, 48); inside a swamp hut piece it spawns a persistent cat when none is in the box inflated by (16, 8, 16); anywhere else nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-2-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY VILPOI.
 COPY VILPOIX.
 COPY STRUCTOVR.
 COPY CUSTOMSP.
 COPY PATROL.
 COPY TRADERSP.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 112.
 01 WS-GRASS-KIND          BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CAT-TYPE            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-CATS                BINARY-LONG.
 01 WS-CAT-ROW             BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-HOMES               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-HUT-KIND            BINARY-LONG VALUE 4.
 01 WS-RULE-MOBS           PIC X(40) VALUE "spawn_mobs".
 01 WS-RULE-MONSTERS       PIC X(40) VALUE "spawn_monsters".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-PX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-PY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-PZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-FX = WS-PX - 56
     COMPUTE WS-FZ = WS-PZ - 56
     COMPUTE WS-FY = WS-PY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-GRASS-KIND
     MOVE "minecraft:cat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CAT-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO CSP-CAT-NEXT
     PERFORM CLEAR-ALL

*>   spawn_mobs false: the list is not ticked at all
     MOVE 0 TO WS-RULE-VALUE
     PERFORM SET-SPAWN-MOBS
     CALL "CUSTOM-SPAWNERS-TICK"
     MOVE "acceptance US15 44-2§6 spawn_mobs false: no custom spawner runs, the cat spawner's counter is untouched" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE CSP-CAT-NEXT TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-RULE-VALUE
     PERFORM SET-SPAWN-MOBS

*>   the first call runs at once and sets the counter to 1200 (set, not added), the next calls count down
     CALL "CUSTOM-SPAWNERS-TICK"
     MOVE "acceptance US15 44-2§6 the cat spawner needs no hostile-mob flag: the first call sets the counter to 1200" TO WS-CASE
     MOVE 1200 TO WS-E
     MOVE CSP-CAT-NEXT TO WS-O
     PERFORM CHECK-N
     CALL "CUSTOM-SPAWNERS-TICK"
     CALL "CUSTOM-SPAWNERS-TICK"
     MOVE "acceptance US15 44-2§6 and 44-3§1.6 step 1: later calls decrement it" TO WS-CASE
     MOVE 1198 TO WS-E
     MOVE CSP-CAT-NEXT TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO CSP-CAT-NEXT
     CALL "CUSTOM-SPAWNERS-TICK"
     MOVE "acceptance US15 44-3§1.6 step 1: a counter that reaches 0 runs the attempt and is set to 1200" TO WS-CASE
     MOVE 1200 TO WS-E
     MOVE CSP-CAT-NEXT TO WS-O
     PERFORM CHECK-N

*>   the flag of the enemy spawners: the patrol spawner (its counter PT-NEXT counts down) runs only with spawn_mobs and spawn_monsters, the wandering trader (TS-DELAY
*>   drops by 1200 on a tick that is a multiple of 1200) and the siege reset need no more than spawn_mobs and the flag respectively
     MOVE 1 TO TS-INIT
     MOVE 24000 TO TS-DELAY
     MOVE 1200 TO CW-TICKS
     MOVE 5 TO PT-NEXT
     MOVE 1 TO CSP-SG-STATE
     MOVE 18001 TO CW-TIME
     MOVE 0 TO WS-RULE-VALUE
     PERFORM SET-SPAWN-MONSTERS
     CALL "CUSTOM-SPAWNERS-TICK"
     MOVE "acceptance US15 44-2§6 spawn_monsters false: the patrol spawner is not ticked (counter stays 5)" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE PT-NEXT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§6 spawn_monsters false: the siege is called with false and resets" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE CSP-SG-STATE TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§6 spawn_monsters false: the wandering trader has no flag test and ticks (delay 24000 - 1200)" TO WS-CASE
     MOVE 22800 TO WS-E
     MOVE TS-DELAY TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-RULE-VALUE
     PERFORM SET-SPAWN-MONSTERS
     CALL "CUSTOM-SPAWNERS-TICK"
     MOVE "acceptance US15 44-2§6 spawn_monsters true: the patrol spawner is ticked (counter 4)" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE PT-NEXT TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-RULE-VALUE
     PERFORM SET-SPAWN-MOBS
     MOVE 1 TO CW-TICKS
     CALL "CUSTOM-SPAWNERS-TICK"
     MOVE "acceptance US15 44-2§6 spawn_mobs false (spawn_monsters true): the patrol counter stays 4" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE PT-NEXT TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-RULE-VALUE
     PERFORM SET-SPAWN-MOBS
     MOVE 0 TO PT-NEXT

*>   no point of interest, no hut: forty attempts spawn nothing
     PERFORM CLEAR-ALL
     PERFORM ATTEMPTS
     MOVE "acceptance US15 44-3§1.6 step 4: outside a village and a swamp hut no cat spawns" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CATS TO WS-O
     PERFORM CHECK-N

*>   a village (a bed within two sections) with four occupied homes: not above 4, nothing
     MOVE 1 TO PX-KIND(1)
     MOVE WS-DIM TO PX-DIM(1)
     MOVE WS-PX TO PX-X(1)
     MOVE WS-PY TO PX-Y(1)
     MOVE WS-PZ TO PX-Z(1)
     MOVE 4 TO WS-HOMES
     PERFORM SET-HOMES
     PERFORM ATTEMPTS
     MOVE "acceptance US15 44-3§1.6 village case: four occupied homes within 48 are not above 4: no cat" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CATS TO WS-O
     PERFORM CHECK-N

*>   a free home bed (owner 0) does not count: five entries of which one is free
     MOVE 5 TO WS-HOMES
     PERFORM SET-HOMES
     MOVE 0 TO PO-OWNER(5)
     PERFORM ATTEMPTS
     MOVE "acceptance US15 44-3§1.6 village case: only occupied homes count (four occupied, one free): no cat" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CATS TO WS-O
     PERFORM CHECK-N

*>   five occupied homes: a cat spawns, not persistent, 8 to 31 blocks away in x and z at the player's y, yaw 0
     MOVE 5 TO WS-HOMES
     PERFORM SET-HOMES
     PERFORM ATTEMPTS
     MOVE "acceptance US15 44-3§1.6 village case: five occupied homes within 48 and no cat near: one cat spawns" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CATS TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-3§1.6 village case: the cat is not persistent" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-PERSISTENT(WS-CAT-ROW) TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-DX = FUNCTION INTEGER(EN-X(WS-CAT-ROW)) - WS-PX
     COMPUTE WS-DZ = FUNCTION INTEGER(EN-Z(WS-CAT-ROW)) - WS-PZ
     COMPUTE WS-DY = FUNCTION INTEGER(EN-Y(WS-CAT-ROW)) - WS-PY
     MOVE "acceptance US15 44-3§1.6 step 3: 8 + nextInt(24) blocks away in x and in z (8 to 31), the player's y" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF FUNCTION ABS(WS-DX) >= 8 AND FUNCTION ABS(WS-DX) <= 31 AND FUNCTION ABS(WS-DZ) >= 8 AND FUNCTION ABS(WS-DZ) <= 31 AND WS-DY = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 44-3§1.6 step 5: the cat is on the block centre with yaw 0" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     COMPUTE WS-X = EN-X(WS-CAT-ROW) - FUNCTION INTEGER(EN-X(WS-CAT-ROW))
     IF WS-X > 0.4999 AND WS-X < 0.5001 AND EN-YAW(WS-CAT-ROW) = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N

*>   five cats already in the box: the village case needs fewer than 5
     PERFORM CLEAR-ALL
     MOVE WS-PX TO WS-X
     MOVE WS-PY TO WS-Y
     MOVE WS-PZ TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "MOB-SPAWN" USING WS-DIM WS-CAT-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
     END-PERFORM
     PERFORM ATTEMPTS
     MOVE "acceptance US15 44-3§1.6 village case: five cats in the (48, 8, 48) box already: no sixth" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-CATS TO WS-O
     PERFORM CHECK-N

*>   the hut case: no point of interest, a swamp hut piece box around the area
     PERFORM CLEAR-ALL
     MOVE 0 TO PX-KIND(1)
     MOVE 0 TO WS-HOMES
     PERFORM SET-HOMES
     PERFORM REGISTER-HUT
     PERFORM ATTEMPTS
     MOVE "acceptance US15 44-3§1.6 hut case: inside a swamp hut piece with no cat near one cat spawns" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CATS TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-3§1.6 hut case: the cat is made persistent" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-PERSISTENT(WS-CAT-ROW) TO WS-O
     PERFORM CHECK-N
*>   more attempts: a new cat appears only where no cat lies within (16, 8, 16) of its block, so every pair differs by 17 or more in x or in z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         MOVE 0 TO CSP-CAT-NEXT
         CALL "CAT-SPAWNER-TICK"
     END-PERFORM
     PERFORM COUNT-CATS
     MOVE "acceptance US15 44-3§1.6 hut case: a new cat never lies within (16, 8, 16) of another (every pair is farther than 16 in x or z)" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM PAIRS-FAR
     PERFORM CHECK-N
     STOP RUN.
 SET-SPAWN-MOBS.
     CALL "BR-RULE-FIND" USING WS-RULE-MOBS WS-RULE-INDEX
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE.
 SET-SPAWN-MONSTERS.
     CALL "BR-RULE-FIND" USING WS-RULE-MONSTERS WS-RULE-INDEX
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CLEAR-ALL.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-IF
     END-PERFORM.
 SET-HOMES.
*>   WS-HOMES occupied homes at the player's block (and clear the rest of the claim table)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX
         MOVE 0 TO PO-OWNER(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-HOMES
         MOVE 1 TO PO-OWNER(WS-I)
         MOVE WS-DIM TO PO-DIM(WS-I)
         MOVE WS-PX TO PO-X(WS-I)
         MOVE WS-PY TO PO-Y(WS-I)
         MOVE WS-PZ TO PO-Z(WS-I)
         MOVE 2 TO PO-KIND(WS-I)
     END-PERFORM.
 COUNT-CATS.
     MOVE 0 TO WS-CATS WS-CAT-ROW
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = WS-CAT-TYPE AND EN-PLAYER(WS-ROW) = 0
             ADD 1 TO WS-CATS
             MOVE WS-ROW TO WS-CAT-ROW
         END-IF
     END-PERFORM.
 ATTEMPTS.
*>   up to 60 attempts, each as the counter reaches 0; stops when a cat has been added (a spot may fall in an unloaded chunk: the attempt then does nothing)
     PERFORM COUNT-CATS
     MOVE WS-CATS TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR WS-CATS > WS-FOUND
         MOVE 0 TO CSP-CAT-NEXT
         CALL "CAT-SPAWNER-TICK"
         PERFORM COUNT-CATS
     END-PERFORM.
 PAIRS-FAR.
*>   WS-O stays 1 unless two cats lie within 16 of each other in both x and z
     MOVE 1 TO WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
             IF WS-I NOT = WS-ROW AND EN-USED(WS-I) = 1 AND EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-I) = WS-CAT-TYPE AND EN-TYPE(WS-ROW) = WS-CAT-TYPE
                 COMPUTE WS-X = EN-X(WS-I) - EN-X(WS-ROW)
                 COMPUTE WS-Z = EN-Z(WS-I) - EN-Z(WS-ROW)
                 IF FUNCTION ABS(WS-X) <= 16 AND FUNCTION ABS(WS-Z) <= 16
                     MOVE 0 TO WS-O
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM.
 REGISTER-HUT.
*>   a swamp hut piece box (kind 4) over each chunk around the player's, tall enough to hold the spots
     COMPUTE WS-CX = FUNCTION INTEGER(WS-PX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-PZ / 16)
     PERFORM VARYING WS-DX FROM -4 BY 1 UNTIL WS-DX > 4
         PERFORM VARYING WS-DZ FROM -4 BY 1 UNTIL WS-DZ > 4
             COMPUTE WS-RX = WS-CX + WS-DX
             COMPUTE WS-RZ = WS-CZ + WS-DZ
             COMPUTE WS-X0 = WS-RX * 16
             COMPUTE WS-Z0 = WS-RZ * 16
             COMPUTE WS-X1 = WS-X0 + 15
             COMPUTE WS-Z1 = WS-Z0 + 15
             COMPUTE WS-Y0 = WS-PY - 10
             COMPUTE WS-Y1 = WS-PY + 10
             CALL "SO-REGISTER" USING WS-DIM WS-RX WS-RZ WS-HUT-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-Q44-44-2-6.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY NOSPAWN.
