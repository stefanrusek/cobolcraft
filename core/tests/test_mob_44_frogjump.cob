*> Implementation test (002-lane-mobsa4; 44 part 4 sections 1.1 and 10): the frog's long jump: the jump vector of the worked example (section 19 example 1), the collision check of the arc, the frog landing
*> test, the 40 tick preparation, the launch, the mid-jump landing with the cooldown U(100, 140), and a frog on a flat floor that jumps and lands by itself.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-FROGJUMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-PAD                 BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-G                   FLOAT-LONG VALUE 0.08.
 01 WS-MAX                 FLOAT-LONG VALUE 1.5.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-ANGLE               BINARY-LONG VALUE 65.
 01 WS-COLLIDE             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-STATE-MAX           BINARY-LONG.
 01 WS-LANDED              BINARY-LONG.
 01 WS-ZA                  BINARY-LONG.
 01 WS-YA                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 2.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 2.5
     MOVE "N" TO TL-MODE
     MOVE 2 TO BW-DIFFICULTY
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:frog" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:lily_pad" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-PAD

*>   The worked example: frog at (0, 64, 0), target block (4, 64, 0), angle 65 degrees.
     MOVE 0 TO WS-PX WS-PY WS-PZ
     MOVE 64 TO WS-PY
     MOVE 4.5 TO WS-TX
     MOVE 64.5 TO WS-TY
     MOVE 0.5 TO WS-TZ
     MOVE 0 TO WS-COLLIDE
     CALL "M44-JUMP-VECTOR" USING WS-DIM WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE WS-COLLIDE WS-VX WS-VY WS-VZ WS-FOUND
     MOVE "acceptance US15 44-4§19 Frog long jump: the worked example has a vector at 65 degrees" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§19 Frog long jump: the launch vector is 0.95 x (vh cos phi, vy, vh sin phi) = (0.2666, 0.5753, 0.0296)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-VX - 0.2666) < 0.002 AND FUNCTION ABS(WS-VY - 0.5753) < 0.002 AND FUNCTION ABS(WS-VZ - 0.0296) < 0.002
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 30.5 TO WS-TX
     CALL "M44-JUMP-VECTOR" USING WS-DIM WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE WS-COLLIDE WS-VX WS-VY WS-VZ WS-FOUND
     MOVE "acceptance US15 44-4§19 Frog long jump: a target 30 blocks away needs more than the maximum speed 1.5, no vector" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4.5 TO WS-TX
     MOVE 90.5 TO WS-TY
     CALL "M44-JUMP-VECTOR" USING WS-DIM WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE WS-COLLIDE WS-VX WS-VY WS-VZ WS-FOUND
     MOVE "acceptance US15 44-4§19 Frog long jump: a target far above the arc (negative v squared) has no vector" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The collision check: a wall across the arc stops it, a free floor does not.
     COMPUTE WS-PX = WS-X0 + 10.5
     COMPUTE WS-PY = WS-FLOOR + 1
     COMPUTE WS-PZ = WS-Z0 + 10.5
     COMPUTE WS-TX = WS-X0 + 14.5
     COMPUTE WS-TY = WS-FLOOR + 1.5
     COMPUTE WS-TZ = WS-Z0 + 10.5
     MOVE 1 TO WS-COLLIDE
     CALL "M44-JUMP-VECTOR" USING WS-DIM WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE WS-COLLIDE WS-VX WS-VY WS-VZ WS-FOUND
     MOVE "acceptance US15 44-4§19 Frog long jump: over a free floor the arc is clear" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BX = WS-X0 + 12
     COMPUTE WS-ZA = WS-Z0 + 7
     PERFORM VARYING WS-BZ FROM WS-ZA BY 1 UNTIL WS-BZ > WS-Z0 + 14
         PERFORM VARYING WS-BY FROM WS-FLOOR BY 1 UNTIL WS-BY > WS-FLOOR + 12
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
         END-PERFORM
     END-PERFORM
     CALL "M44-JUMP-VECTOR" USING WS-DIM WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE WS-COLLIDE WS-VX WS-VY WS-VZ WS-FOUND
     MOVE "acceptance US15 44-4§19 Frog long jump: a wall across the arc leaves no vector" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-YA = WS-FLOOR + 1
     PERFORM VARYING WS-BZ FROM WS-ZA BY 1 UNTIL WS-BZ > WS-Z0 + 14
         PERFORM VARYING WS-BY FROM WS-YA BY 1 UNTIL WS-BY > WS-FLOOR + 12
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
         END-PERFORM
     END-PERFORM

*>   The landing test.
     COMPUTE WS-BX = WS-X0 + 20
     COMPUTE WS-BZ = WS-Z0 + 20
     COMPUTE WS-BY = WS-FLOOR + 1
     CALL "M44-FROG-LANDING" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     MOVE "acceptance US15 44-4§10 Frog landing: air above a solid floor is acceptable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-FLOOR + 4
     CALL "M44-FROG-LANDING" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     MOVE "acceptance US15 44-4§10 Frog landing: air above air is not (the block below is not solid)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     CALL "M44-FROG-LANDING" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     MOVE "acceptance US15 44-4§10 Frog landing: a water cell is not acceptable (the fluid of the block must be empty)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-FLOOR + 2
     CALL "M44-FROG-LANDING" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     MOVE "acceptance US15 44-4§10 Frog landing: the cell above water, the block below holds fluid, not acceptable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-PAD
     COMPUTE WS-BY = WS-FLOOR + 2
     CALL "M44-FROG-LANDING" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     MOVE "acceptance US15 44-4§10 Frog landing: the cell above a lily pad (frog_prefer_jump_to) is acceptable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR

*>   Preparation, launch and landing of a chosen jump.
     COMPUTE WS-X = WS-X0 + 30.5
     COMPUTE WS-Z = WS-Z0 + 30.5
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-A
     CALL "MOB-STEP" USING WS-A
     MOVE 1 TO EN-FROG-JS(WS-A)
     MOVE 1 TO EN-FROG-CH(WS-A)
     MOVE 0 TO EN-FROG-JT(WS-A)
     MOVE 20 TO EN-FROG-TRIES(WS-A)
     COMPUTE EN-FROG-SX(WS-A) = FUNCTION INTEGER(EN-X(WS-A))
     COMPUTE EN-FROG-SY(WS-A) = FUNCTION INTEGER(EN-Y(WS-A))
     COMPUTE EN-FROG-SZ(WS-A) = FUNCTION INTEGER(EN-Z(WS-A))
     MOVE 0.2666 TO EN-FROG-JVX(WS-A)
     MOVE 0.5753 TO EN-FROG-JVY(WS-A)
     MOVE 0.0296 TO EN-FROG-JVZ(WS-A)
     MOVE 0 TO EN-FROG-CD(WS-A)
     PERFORM 38 TIMES
         CALL "M44-FROG-JUMP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§1.1 Frog long jump: during the 40 tick preparation the frog is not launched" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FROG-JS(WS-A) = 1 AND EN-VY(WS-A) < 0.3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 3 TIMES
         CALL "M44-FROG-JUMP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§1.1 Frog long jump: after 40 ticks it is launched (mid-jump, vertical speed 0.5753, horizontal 0.2666)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FROG-JS(WS-A) = 3 AND FUNCTION ABS(EN-VY(WS-A) - 0.5753) < 0.001 AND FUNCTION ABS(EN-VX(WS-A) - 0.2666) < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Landing: back on the ground the horizontal motion is multiplied by 0.1, the cooldown is U(100, 140).
     MOVE 1 TO EN-ON-GROUND(WS-A)
     MOVE 5 TO EN-FROG-MIDT(WS-A)
     MOVE 0.2666 TO EN-VX(WS-A)
     CALL "M44-FROG-JUMP" USING WS-A
     MOVE "acceptance US15 44-4§1.1 Frog long jump: landing ends the jump, horizontal motion x 0.1, cooldown 100 to 140" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FROG-JS(WS-A) = 0 AND FUNCTION ABS(EN-VX(WS-A) - 0.02666) < 0.0005 AND EN-FROG-CD(WS-A) >= 100 AND EN-FROG-CD(WS-A) <= 140
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-FROG-JUMP" USING WS-A
     MOVE "acceptance US15 44-4§1.1 Frog long jump: the cooldown counts down by one a tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FROG-CD(WS-A) >= 99 AND EN-FROG-CD(WS-A) <= 139 AND EN-FROG-JS(WS-A) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A chosen jump is dropped when the frog leaves its start block (the behaviour ends, cooldown set to half a sample).
     MOVE 1 TO EN-FROG-JS(WS-A)
     MOVE 1 TO EN-FROG-CH(WS-A)
     MOVE 0 TO EN-FROG-JT(WS-A)
     MOVE 20 TO EN-FROG-TRIES(WS-A)
     COMPUTE EN-FROG-SX(WS-A) = FUNCTION INTEGER(EN-X(WS-A)) + 3
     MOVE 0 TO EN-FROG-CD(WS-A)
     CALL "M44-FROG-JUMP" USING WS-A
     MOVE "acceptance US15 44-4§1.1 Frog long jump: moved off its start block the behaviour ends with a cooldown of 50 to 70" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FROG-JS(WS-A) = 0 AND EN-FROG-CD(WS-A) >= 50 AND EN-FROG-CD(WS-A) <= 70
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A

*>   Degenerate and refused starts.
     MOVE WS-PX TO WS-TX
     MOVE WS-PZ TO WS-TZ
     CALL "M44-JUMP-VECTOR" USING WS-DIM WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE WS-COLLIDE WS-VX WS-VY WS-VZ WS-FOUND
     MOVE "acceptance US15 44-4§19 Frog long jump: a target in the frog's own column has no vector" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-X0 + 36.5
     COMPUTE WS-Z = WS-Z0 + 36.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-A
     MOVE 0 TO EN-FROG-CD(WS-A) EN-ON-GROUND(WS-A) EN-FROG-JS(WS-A)
     CALL "M44-FROG-JUMP" USING WS-A
     MOVE "acceptance US15 44-4§1.1 Frog long jump: in the air the behaviour does not start, the cooldown is 50 to 70" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FROG-JS(WS-A) = 0 AND EN-FROG-CD(WS-A) >= 50 AND EN-FROG-CD(WS-A) <= 70
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FROG-CD(WS-A)
     MOVE 1 TO EN-ON-GROUND(WS-A) EN-LOVE(WS-A)
     CALL "M44-FROG-JUMP" USING WS-A
     MOVE "acceptance US15 44-4§1.1 Frog long jump: a frog in love does not start (no breed target allowed)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FROG-JS(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-LOVE(WS-A)
     CALL "M44-FROG-JUMP" USING WS-A
     MOVE "acceptance US15 44-4§1.1 Frog long jump: on the ground and dry it starts (20 tries, the start block)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FROG-JS(WS-A) = 1 AND EN-FROG-TRIES(WS-A) = 20 AND EN-FROG-SX(WS-A) = FUNCTION INTEGER(EN-X(WS-A))
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Water at its feet ends the preparation; a mid-jump that never lands ends after 100 ticks.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-A))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-A))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-A))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     CALL "M44-FROG-JUMP" USING WS-A
     MOVE "acceptance US15 44-4§1.1 Frog long jump: in water the preparation ends (cooldown 50 to 70)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FROG-JS(WS-A) = 0 AND EN-FROG-CD(WS-A) >= 50 AND EN-FROG-CD(WS-A) <= 70
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 3 TO EN-FROG-JS(WS-A)
     MOVE 99 TO EN-FROG-MIDT(WS-A)
     MOVE 0 TO EN-ON-GROUND(WS-A)
     CALL "M44-FROG-JUMP" USING WS-A
     MOVE "acceptance US15 44-4§1.1 Frog long jump: a mid-jump times out after 100 ticks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FROG-JS(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A

*>   On its own: a frog on a flat floor starts, chooses a target, jumps and lands within 3000 ticks.
     COMPUTE WS-X = WS-X0 + 24.5
     COMPUTE WS-Z = WS-Z0 + 24.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-A
     MOVE 0 TO EN-FROG-CD(WS-A)
     MOVE 0 TO WS-STATE-MAX WS-LANDED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR WS-LANDED = 1
         ADD 1 TO CW-TIME
         ADD 1 TO CW-TICKS
         CALL "MOB-STEP" USING WS-A
         IF EN-FROG-JS(WS-A) = 3
             MOVE 3 TO WS-STATE-MAX
         END-IF
         IF WS-STATE-MAX = 3 AND EN-FROG-JS(WS-A) = 0
             MOVE 1 TO WS-LANDED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§10 Frog: on a flat floor it jumps (mid-jump) and lands again by itself" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LANDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-FROGJUMP.
 COPY CORETEST.
 COPY MOBSPTEST.
