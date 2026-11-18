*> Integration test (integrator, batch 11; docs/protocol/18-mob-framework.md sections 2.6 and 4.10, 20 section 3.8): the tick of a standard mob stops where the mob has
*> died or has been replaced. A cow with 1 health in powder snow takes its freezing damage on a tick that is a multiple of 40 once frozen for 140 ticks, and the environment tick
*> ends there (nothing else is applied to it); a skeleton whose conversion count is below 0 is replaced by a stray in the step, and the step ends with the old row.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GAP-ENV-DEATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-COW                BINARY-LONG.
 01 WS-SKELETON           BINARY-LONG.
 01 WS-STRAY              BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-I                  BINARY-LONG.
 01 WS-STRAYS             BINARY-LONG.
 01 WS-SKELETONS          BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:skeleton" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SKELETON WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stray" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-STRAY WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:powder_snow" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
*>   The cow: frozen for 139 ticks, 1 health, the tick count at a multiple of 40: the freezing damage kills it in the block effects and the environment tick ends.
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-HEALTH(WS-ROW)
     MOVE 139 TO EN-FROZEN(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 80 TO CW-TICKS
     CALL "M182-ENV-TICK" USING WS-ROW
     MOVE "integration US15 18§2.6 the environment tick of a cow that froze to death ends with its death (health 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "integration US15 18§2.6 it had been frozen for 140 ticks" TO WS-CASE
     MOVE 140 TO WS-E
     MOVE EN-FROZEN(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   The skeleton: converting with the count at 0, in powder snow: the step replaces it with one stray and ends there.
     CALL "MOB-SPAWN" USING WS-DIM WS-SKELETON WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-CONVERTING(WS-ROW)
     MOVE 0 TO EN-CONVERT-LEFT(WS-ROW)
     MOVE 81 TO CW-TICKS
     CALL "STDMOB-STEP" USING WS-ROW
     MOVE 0 TO WS-STRAYS WS-SKELETONS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-STRAY
             ADD 1 TO WS-STRAYS
         END-IF
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-SKELETON
             ADD 1 TO WS-SKELETONS
         END-IF
     END-PERFORM
     MOVE "integration US15 20§3.8 the step of a converting skeleton whose count ran out leaves one stray" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-STRAYS TO WS-O
     PERFORM CHECK-N
     MOVE "integration US15 20§3.8 and no skeleton is left" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SKELETONS TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-GAP-ENV-DEATH.
 COPY CORETEST.
 COPY MOBSPTEST.
