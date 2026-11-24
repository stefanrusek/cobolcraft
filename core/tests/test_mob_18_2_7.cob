*> Acceptance test (lane p49a; docs/protocol/18-mob-framework.md section 2.7 Mob.aiStep and Mob.serverAiStep): the goal selector's full evaluation runs on the
*> ticks where (tickCount + entity id) mod 2 = 0 and on tick 1 or less; the stroll goal's roll is nextInt(60) per evaluation. So a standing mob never starts a
*> stroll on a tick of the other parity (the movement controls still run every tick), and it does start one on evaluation ticks. Also mobs in the burn_in_daylight
*> tag are ignited for 8 seconds in the sun (covered by test_mob_18_2_5 and test_stdmob_*).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-2-7.
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
 01 WS-PIG                BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-FX                 BINARY-LONG.
 01 WS-FZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 9.
 01 WS-KIND               BINARY-LONG VALUE 1.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-T                  BINARY-LONG.
 01 WS-PARITY             BINARY-LONG.
 01 WS-ODD-STARTS         BINARY-LONG.
 01 WS-EVEN-STARTS        BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 6000 TO CW-TIME
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO WS-ODD-STARTS WS-EVEN-STARTS
     PERFORM VARYING WS-T FROM 10 BY 1 UNTIL WS-T > 1209
         COMPUTE CW-TICKS = WS-T
         COMPUTE CW-TIME = 6000 + WS-T
         COMPUTE WS-PARITY = FUNCTION MOD(CW-TICKS + EN-ID(WS-ROW), 2)
         MOVE 0 TO EN-COOLDOWN(WS-ROW) EN-LOVE(WS-ROW) EN-HURT(WS-ROW)
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         CALL "STDMOB-STEP" USING WS-ROW
         IF EN-COOLDOWN(WS-ROW) > 0
             IF WS-PARITY = 0
                 ADD 1 TO WS-EVEN-STARTS
             ELSE
                 ADD 1 TO WS-ODD-STARTS
             END-IF
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§2.7 Mob.serverAiStep: no stroll starts on a tick where (tickCount + id) is odd" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ODD-STARTS TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.7 Mob.serverAiStep: strolls start on evaluation ticks (1200 ticks, roll 1 in 60 per evaluation)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-EVEN-STARTS >= 3
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-2-7.
 COPY CORETEST.
 COPY MOBSPTEST.
