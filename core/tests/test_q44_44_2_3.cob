*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 3, with 18 section 6.12 step 3): custom spawn rules of a spawner's spawn data.
*> With the rules set the spawner applies them in place of the placement check of the type: the block light and the effective sky brightness (the sky light less the night's darkening, or 10
*> in a thunderstorm) must lie in the inclusive ranges, and a type that is not friendly is refused on Peaceful. Without rules the monster light rule and the grass rule of an animal apply.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-2-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CONTENT.
 COPY BRWORLD.
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
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-STATE               BINARY-LONG.
 01 WS-MOBS                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SET-ID              PIC X(64).
 01 WS-SET-LEN             BINARY-LONG.
 01 WS-SPECIES             PIC X(24).
 01 WS-BMIN                BINARY-LONG.
 01 WS-BMAX                BINARY-LONG.
 01 WS-SMIN                BINARY-LONG.
 01 WS-SMAX                BINARY-LONG.
 01 WS-RSET                BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
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
*>   no rules, a zombie in daylight on stone: the monster light rule refuses it
     MOVE 6000 TO CW-TIME
     MOVE "zombie" TO WS-SPECIES
     MOVE 0 TO WS-BMIN WS-SMIN
     MOVE 15 TO WS-BMAX WS-SMAX
     PERFORM RUN-SPAWNER
     MOVE "acceptance US15 44-2§3 Spawn data: without custom rules a zombie spawner makes nothing in daylight (the light rule of the type)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MOBS TO WS-O
     PERFORM CHECK-N
*>   the rules 0 to 15 and 0 to 15 apply in place of it: the zombie appears in daylight
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: custom spawn rules (0 to 15, 0 to 15) replace the type's placement check, so the zombie spawns in daylight" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-MOBS, 1) TO WS-O
     PERFORM CHECK-N
*>   the effective sky brightness in full daylight is 15: a limit 0 to 7 refuses, 8 to 15 allows
     MOVE 0 TO WS-SMIN
     MOVE 7 TO WS-SMAX
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: a sky_light_limit of 0 to 7 refuses a position with sky brightness 15" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MOBS TO WS-O
     PERFORM CHECK-N
     MOVE 8 TO WS-SMIN
     MOVE 15 TO WS-SMAX
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: a sky_light_limit of 8 to 15 allows it (inclusive range)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-MOBS, 1) TO WS-O
     PERFORM CHECK-N
     MOVE 15 TO WS-SMIN
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: a sky_light_limit of 15 to 15 allows brightness 15 (both limits inclusive)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-MOBS, 1) TO WS-O
     PERFORM CHECK-N
*>   the block light at the spawn cells is 0
     MOVE 0 TO WS-SMIN
     MOVE 15 TO WS-SMAX
     MOVE 1 TO WS-BMIN
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: a block_light_limit of 1 to 15 refuses a position with block light 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MOBS TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-BMIN
     MOVE 0 TO WS-BMAX
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: a block_light_limit of 0 to 0 allows block light 0" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-MOBS, 1) TO WS-O
     PERFORM CHECK-N
*>   at midnight the sky is darkened: the effective sky brightness is the sky light less the darkening
     MOVE 0 TO WS-BMIN
     MOVE 15 TO WS-BMAX
     MOVE 18000 TO CW-TIME
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARKEN
     MOVE 15 TO WS-SMIN
     MOVE 15 TO WS-SMAX
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: at midnight the effective sky brightness is below 15, so a limit of 15 to 15 refuses" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MOBS TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-SMAX = 15 - WS-DARKEN
     MOVE 0 TO WS-SMIN
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: and the limit 0 to (15 - darkening) allows exactly that brightness" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-MOBS, 1) TO WS-O
     PERFORM CHECK-N
*>   a thunderstorm reduces the sky by 10 at any hour: daylight 15 becomes 5
     MOVE 6000 TO CW-TIME
     MOVE 1 TO CW-RAIN-LEVEL(WS-DIM) CW-THUNDER-LEVEL(WS-DIM)
     MOVE 6 TO WS-SMIN
     MOVE 15 TO WS-SMAX
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: in a thunderstorm the effective sky brightness is 5, so a limit of 6 to 15 refuses" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MOBS TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-SMIN
     MOVE 5 TO WS-SMAX
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: and a limit of 0 to 5 allows it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-MOBS, 1) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO CW-RAIN-LEVEL(WS-DIM) CW-THUNDER-LEVEL(WS-DIM)
*>   Peaceful: a type that is not friendly fails, a friendly one does not
     MOVE 0 TO BW-DIFFICULTY
     MOVE 0 TO WS-SMIN
     MOVE 15 TO WS-SMAX
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: with custom rules a monster spawner makes nothing on Peaceful" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MOBS TO WS-O
     PERFORM CHECK-N
     MOVE "cow" TO WS-SPECIES
     PERFORM RUN-SPAWNER-RULES
     MOVE "acceptance US15 44-2§3 Spawn data: with custom rules a cow (friendly) spawns on Peaceful, on stone (no grass rule)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FUNCTION MIN(WS-MOBS, 1) TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO BW-DIFFICULTY
*>   without rules the same cow on stone does not spawn (grass rule)
     PERFORM RUN-SPAWNER
     MOVE "acceptance US15 44-2§3 Spawn data: without custom rules a cow spawner makes nothing on stone (the animal rule needs grass)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MOBS TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 RUN-SPAWNER.
     MOVE 0 TO WS-RSET
     PERFORM RUN-ONE.
 RUN-SPAWNER-RULES.
     MOVE 1 TO WS-RSET
     PERFORM RUN-ONE.
 RUN-ONE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     MOVE 0 TO BE-XI(WS-BE, 1)
     MOVE 200 TO BE-XI(WS-BE, 2)
     MOVE 800 TO BE-XI(WS-BE, 3)
     MOVE 64 TO BE-XI(WS-BE, 4)
     MOVE 100 TO BE-XI(WS-BE, 5)
     MOVE 16 TO BE-XI(WS-BE, 6)
     MOVE 6 TO BE-XI(WS-BE, 7)
     MOVE 0 TO BE-XI(WS-BE, 15)
     MOVE WS-RSET TO BE-XI(WS-BE, 14)
     MOVE WS-BMIN TO BE-XI(WS-BE, 10)
     MOVE WS-BMAX TO BE-XI(WS-BE, 11)
     MOVE WS-SMIN TO BE-XI(WS-BE, 12)
     MOVE WS-SMAX TO BE-XI(WS-BE, 13)
     MOVE SPACES TO WS-SET-ID
     STRING "minecraft:" DELIMITED BY SIZE WS-SPECIES DELIMITED BY SPACE INTO WS-SET-ID
     COMPUTE WS-SET-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-SET-ID))
     CALL "BE7-SET-ENTITY-ID" USING WS-BE WS-SET-ID WS-SET-LEN
     CALL "BE-TICK-ALL"
     MOVE 0 TO WS-MOBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             ADD 1 TO WS-MOBS
         END-IF
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-2-3.
 COPY CORETEST.
 COPY MOBSPTEST.
