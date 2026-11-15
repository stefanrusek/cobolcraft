*> Implementation test (002-lane-mobsfull-h19; docs/protocol/19 section 20 Snow golem, ranged attack, with 44 part 8 section 6.5 and 10.4): the snow golem throws a snowball
*> at the nearest monster within 10 blocks that it sees: the attack timer starts at 20 on the first tick with a target and a snowball leaves when it runs out, then every
*> 20 ticks; the snowball starts at the eyes - 0.1 (y + 1.6), aimed at the target's eyes - 1.1 with the arc term sqrt(dx^2 + dz^2) x 0.2 added to dy, speed 1.6, owner
*> the golem; no target (nothing hostile within 10 blocks, a passive mob, no line of sight) means no snowball.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-20.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-GOLEM-TYPE          BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-SB-TYPE             BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-M                   BINARY-LONG.
 01 WS-GOLEM               BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-GX                  FLOAT-LONG.
 01 WS-ZX                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-STONE-KIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:snow_golem" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GOLEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "PROJ-TYPE" USING WS-KIND WS-SB-TYPE
     CALL "STDMOB-INDEX" USING WS-GOLEM-TYPE WS-M
     MOVE 2 TO BW-DIFFICULTY
*>   The player is moved far away so that only the zombie is a target.
     COMPUTE PL-X(WS-PLAYER) = WS-X + 19
     COMPUTE WS-GX = WS-X - 10
     COMPUTE WS-ZX = WS-X - 4
     CALL "MOB-SPAWN" USING WS-DIM WS-GOLEM-TYPE WS-GX WS-Y WS-Z WS-YAW WS-GOLEM
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-ZX WS-Y WS-Z WS-YAW WS-ZOMBIE

     CALL "SNOW-GOLEM-TICK" USING WS-GOLEM WS-M
     MOVE "acceptance US15 19§20 snow golem: tick 1 with a target starts the attack timer at 20" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE EN-PET-CD(WS-GOLEM) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 20
         CALL "SNOW-GOLEM-TICK" USING WS-GOLEM WS-M
     END-PERFORM
     PERFORM COUNT-SNOWBALLS
     MOVE "acceptance US15 19§20 snow golem: no snowball before the timer runs out" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "SNOW-GOLEM-TICK" USING WS-GOLEM WS-M
     PERFORM COUNT-SNOWBALLS
     MOVE "acceptance US15 19§20 snow golem: a snowball when the timer runs out" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 19§20 snow golem: the timer restarts at 20" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE EN-PET-CD(WS-GOLEM) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 19§20 snow golem: the snowball starts at the eyes - 0.1 (y + 1.6)" TO WS-CASE
     MOVE 16 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER((EN-Y(WS-SB) - EN-Y(WS-GOLEM)) * 10 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 19§20 snow golem: the snowball flies at speed 1.6 (x 10)" TO WS-CASE
     MOVE 16 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(FUNCTION SQRT(EN-VX(WS-SB) ** 2 + EN-VY(WS-SB) ** 2 + EN-VZ(WS-SB) ** 2) * 10 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 19§20 snow golem: it flies toward the zombie (vx > 0)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-VX(WS-SB) > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 19§20 snow golem: at 6 blocks the arc term lifts the aim (vy > 0)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-VY(WS-SB) > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 19§20 snow golem: the golem owns the snowball" TO WS-CASE
     MOVE EN-ID(WS-GOLEM) TO WS-EXP
     MOVE EN-TARGET-ID(WS-SB) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-SB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         CALL "SNOW-GOLEM-TICK" USING WS-GOLEM WS-M
     END-PERFORM
     PERFORM COUNT-SNOWBALLS
     MOVE "acceptance US15 19§20 snow golem: no second snowball 19 ticks later" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "SNOW-GOLEM-TICK" USING WS-GOLEM WS-M
     PERFORM COUNT-SNOWBALLS
     MOVE "acceptance US15 19§20 snow golem: the second snowball 20 ticks later" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-SB
*>   The zombie 12 blocks away is out of the 10 block range: no target, no throw.
     MOVE 0 TO EN-PET-CD(WS-GOLEM)
     COMPUTE WS-ZX = WS-X + 2
     MOVE WS-ZX TO EN-X(WS-ZOMBIE)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "SNOW-GOLEM-TICK" USING WS-GOLEM WS-M
     END-PERFORM
     PERFORM COUNT-SNOWBALLS
     MOVE "acceptance US15 19§20 snow golem: nothing hostile within 10 blocks, no snowball" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 19§20 snow golem: no target, the timer stays unset" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-PET-CD(WS-GOLEM) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A cow (not a monster) in range is no target either.
     COMPUTE WS-ZX = WS-X - 4
     MOVE WS-ZX TO EN-X(WS-ZOMBIE)
     CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-ZX WS-Y WS-Z WS-YAW WS-COW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "SNOW-GOLEM-TICK" USING WS-GOLEM WS-M
     END-PERFORM
     PERFORM COUNT-SNOWBALLS
     MOVE "acceptance US15 19§20 snow golem: a cow is no target" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-COW
*>   No line of sight: a wall between golem and zombie.
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-ZX WS-Y WS-Z WS-YAW WS-ZOMBIE
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 7
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) + WS-I
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 3
             COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "SNOW-GOLEM-TICK" USING WS-GOLEM WS-M
     END-PERFORM
     PERFORM COUNT-SNOWBALLS
     MOVE "acceptance US15 19§20 snow golem: no line of sight, no snowball" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) + WS-I
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 3
             COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
         END-PERFORM
     END-PERFORM
*>   Through MOB-STEP: the golem stands (no stroll) and throws on the 21st tick.
     MOVE 0 TO EN-PET-CD(WS-GOLEM)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 21
         CALL "MOB-STEP" USING WS-GOLEM
     END-PERFORM
     PERFORM COUNT-SNOWBALLS
     MOVE "acceptance US15 19§20 snow golem: MOB-STEP throws a snowball on tick 21" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 COUNT-SNOWBALLS.
     MOVE 0 TO WS-COUNT WS-SB
     PERFORM VARYING WS-OK FROM 1 BY 1 UNTIL WS-OK > EN-COUNT
         IF EN-USED(WS-OK) = 1 AND EN-TYPE(WS-OK) = WS-SB-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-OK TO WS-SB
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-19-20.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
