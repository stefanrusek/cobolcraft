*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 2, with 18 section 6.12): the mob spawner block in the live world.
*> The delay -1 of step 2 rolls a delay and falls through to the count down and the attempt round of the same tick, an attempt that meets an unknown type or a full count box rolls a delay
*> and ends the round at once, attempts that only fail their rule leave the delay at 0, and every rolled delay is followed by the weighted pick of the next spawn data from SpawnPotentials
*> (an empty list or weights that add up to 0 change nothing). The worked example of 14.1 (a delay of 2: two counting ticks, the round, the rolled delay) closes it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-2-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CONTENT.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 60.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112).
 01 WS-STATE               BINARY-LONG.
 01 WS-COWS                BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SET-ID              PIC X(64).
 01 WS-SET-LEN             BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-NEW                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 30
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 30
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-SZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3
     MOVE "minecraft:spawner" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-FY WS-SZ WS-STATE
     CALL "BE-FIND" USING WS-DIM WS-SX WS-FY WS-SZ WS-BE
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
*>   a delay of -1 with min = max = 300: rolled, then counted down once in the same tick
     PERFORM RESET-SPAWNER
     MOVE -1 TO BE-XI(WS-BE, 1)
     MOVE 300 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§2 Spawner block: a delay of -1 is rolled and counted down once in the same tick (300 becomes 299)" TO WS-CASE
     MOVE 299 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
*>   max not above min: the roll is the minimum
     PERFORM RESET-SPAWNER
     MOVE -1 TO BE-XI(WS-BE, 1)
     MOVE 300 TO BE-XI(WS-BE, 2)
     MOVE 100 TO BE-XI(WS-BE, 3)
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§2 Spawner block: a maximum not above the minimum rolls the minimum (then 299 after the count down)" TO WS-CASE
     MOVE 299 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
*>   a delay of -1 rolled to 0 makes the attempt round of the same tick
     PERFORM RESET-SPAWNER
     MOVE -1 TO BE-XI(WS-BE, 1)
     MOVE 0 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     MOVE 64 TO BE-XI(WS-BE, 4)
     MOVE 100 TO BE-XI(WS-BE, 5)
     MOVE 7 TO BE-XI(WS-BE, 7)
     CALL "BE-TICK-ALL"
     PERFORM COUNT-COWS
     MOVE "acceptance US15 44-2§2 Spawner block: a delay of -1 rolled to 0 falls through to the attempt round of the same tick (a cow stands)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-COWS, 1) TO WS-O
     PERFORM CHECK-N
*>   attempts that only fail their rule: no mob, no roll, the delay stays 0
     PERFORM RESET-SPAWNER
     PERFORM CLEAR-COWS
     MOVE 0 TO BE-XI(WS-BE, 1)
     MOVE 500 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     MOVE 0 TO BE-XI(WS-BE, 7)
     CALL "BE-TICK-ALL"
     PERFORM COUNT-COWS
     MOVE "acceptance US15 44-2§2 Spawner block: attempts that fail the spawn rule (no grass under the spawner column) make no mob" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COWS TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§2 Spawner block: and a round without a success rolls no delay (it stays 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
*>   a full count box: the first attempt that passes the rule rolls a delay and ends the round
     PERFORM RESET-SPAWNER
     PERFORM CLEAR-COWS
     COMPUTE WS-PX = WS-SX + 0.5
     COMPUTE WS-PY = WS-FY + 1
     COMPUTE WS-PZ = WS-SZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-NEW
     MOVE 0 TO BE-XI(WS-BE, 1)
     MOVE 500 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     MOVE 64 TO BE-XI(WS-BE, 4)
     MOVE 1 TO BE-XI(WS-BE, 5)
     CALL "BE-TICK-ALL"
     PERFORM COUNT-COWS
     MOVE "acceptance US15 44-2§2 Spawner block: with MaxNearbyEntities reached the round rolls a delay and stops (500)" TO WS-CASE
     MOVE 500 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§2 Spawner block: and no cow was added to the one that stood" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COWS TO WS-O
     PERFORM CHECK-N
*>   an entity type that has no mob row (the wither; the bat has a row since lane p49f): the round rolls a delay and stops
     PERFORM RESET-SPAWNER
     MOVE "minecraft:wither" TO WS-SET-ID
     MOVE 16 TO WS-SET-LEN
     CALL "BE7-SET-ENTITY-ID" USING WS-BE WS-SET-ID WS-SET-LEN
     MOVE 0 TO BE-XI(WS-BE, 1)
     MOVE 500 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§2 Spawner block: an entity type that cannot be made rolls a delay and ends the round (500)" TO WS-CASE
     MOVE 500 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
*>   SpawnPotentials: [cow weight 0, pig weight 4]: the pig is always picked, the entity id becomes the spawn data
     PERFORM RESET-SPAWNER
     PERFORM POTENTIALS-TWO
     MOVE -1 TO BE-XI(WS-BE, 1)
     MOVE 300 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§2 Spawner block: after a rolled delay the next spawn data is the weighted pick of SpawnPotentials (pig, the cow has weight 0)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XT(WS-BE, 1) = "minecraft:pig" AND BE-XI(WS-BE, 9) = 13 AND BE-XI(WS-BE, 8) = 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   the pick clears custom rules of the former spawn data
     PERFORM RESET-SPAWNER
     PERFORM POTENTIALS-TWO
     MOVE 1 TO BE-XI(WS-BE, 14)
     MOVE 3 TO BE-XI(WS-BE, 10)
     MOVE 5 TO BE-XI(WS-BE, 12)
     MOVE 9 TO BE-XI(WS-BE, 11)
     MOVE 7 TO BE-XI(WS-BE, 13)
     MOVE -1 TO BE-XI(WS-BE, 1)
     MOVE 300 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§2 Spawner block: the picked entry carries no custom spawn rules (set 0, the ranges 0 to 15)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XI(WS-BE, 14) = 0 AND BE-XI(WS-BE, 10) = 0 AND BE-XI(WS-BE, 11) = 15 AND BE-XI(WS-BE, 12) = 0 AND BE-XI(WS-BE, 13) = 15
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   an empty list changes nothing
     PERFORM RESET-SPAWNER
     MOVE -1 TO BE-XI(WS-BE, 1)
     MOVE 300 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§2 Spawner block: an empty SpawnPotentials list leaves the spawn data as it was (cow)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XT(WS-BE, 1) = "minecraft:cow" AND BE-XI(WS-BE, 9) = 13
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   a list whose weights add up to 0 changes nothing
     PERFORM RESET-SPAWNER
     MOVE 1 TO BE-XI(WS-BE, 15)
     MOVE "minecraft:pig" TO BE-XT(WS-BE, 2)
     MOVE 13 TO BE-XI(WS-BE, 20)
     MOVE 0 TO BE-XI(WS-BE, 30)
     MOVE -1 TO BE-XI(WS-BE, 1)
     MOVE 300 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     CALL "BE-TICK-ALL"
     MOVE "acceptance US15 44-2§2 Spawner block: a list whose weights add up to 0 leaves the spawn data as it was (cow)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XT(WS-BE, 1) = "minecraft:cow"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   14.1: a delay of 2 counts two ticks, the third tick runs the round, the rolled delay is the minimum
     PERFORM RESET-SPAWNER
     PERFORM CLEAR-COWS
     MOVE 2 TO BE-XI(WS-BE, 1)
     MOVE 100 TO BE-XI(WS-BE, 2) BE-XI(WS-BE, 3)
     MOVE 64 TO BE-XI(WS-BE, 4)
     MOVE 100 TO BE-XI(WS-BE, 5)
     MOVE 7 TO BE-XI(WS-BE, 7)
     CALL "BE-TICK-ALL"
     CALL "BE-TICK-ALL"
     PERFORM COUNT-COWS
     MOVE "acceptance US15 44-2§2 Spawner block: 14.1 a delay of 2 counts down on two ticks and spawns nothing (delay 0, no cow)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = BE-XI(WS-BE, 1) + WS-COWS
     PERFORM CHECK-N
     CALL "BE-TICK-ALL"
     PERFORM COUNT-COWS
     MOVE "acceptance US15 44-2§2 Spawner block: 14.1 the third tick runs the round (a cow stands) and rolls the delay 100" TO WS-CASE
     MOVE 101 TO WS-E
     COMPUTE WS-O = BE-XI(WS-BE, 1) + FUNCTION MIN(WS-COWS, 1)
     PERFORM CHECK-N
     STOP RUN.
 RESET-SPAWNER.
     MOVE 20 TO BE-XI(WS-BE, 1)
     MOVE 200 TO BE-XI(WS-BE, 2)
     MOVE 800 TO BE-XI(WS-BE, 3)
     MOVE 4 TO BE-XI(WS-BE, 4)
     MOVE 6 TO BE-XI(WS-BE, 5)
     MOVE 16 TO BE-XI(WS-BE, 6)
     MOVE 4 TO BE-XI(WS-BE, 7)
     MOVE 0 TO BE-XI(WS-BE, 14) BE-XI(WS-BE, 15)
     MOVE 0 TO BE-XI(WS-BE, 10) BE-XI(WS-BE, 12)
     MOVE 15 TO BE-XI(WS-BE, 11) BE-XI(WS-BE, 13)
     MOVE "minecraft:cow" TO WS-SET-ID
     MOVE 13 TO WS-SET-LEN
     CALL "BE7-SET-ENTITY-ID" USING WS-BE WS-SET-ID WS-SET-LEN.
 POTENTIALS-TWO.
     MOVE 2 TO BE-XI(WS-BE, 15)
     MOVE "minecraft:cow" TO BE-XT(WS-BE, 2)
     MOVE 13 TO BE-XI(WS-BE, 20)
     MOVE 0 TO BE-XI(WS-BE, 30)
     MOVE "minecraft:pig" TO BE-XT(WS-BE, 3)
     MOVE 13 TO BE-XI(WS-BE, 21)
     MOVE 4 TO BE-XI(WS-BE, 31).
 COUNT-COWS.
     MOVE 0 TO WS-COWS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-COW-TYPE
             ADD 1 TO WS-COWS
         END-IF
     END-PERFORM.
 CLEAR-COWS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-COW-TYPE
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-2-2.
 COPY CORETEST.
 COPY MOBSPTEST.
