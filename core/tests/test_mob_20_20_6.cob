*> Acceptance test (002-lane-p49b; docs/protocol/20 section 20.6): sunburn probability. Per tick, with B(l) = (l/15) / (4 - 3 l/15): the probability is (B - 0.4) x 2 / 30 for B above 0.5:
*> light 15 gives 0.04 (400 in ten thousand), 14 gives 0.0252 (252), 13 gives 0.0146 (146), light 12 (B = 0.5, not above 0.5) never burns. A zombie at full sky light at noon with
*> the sky visible ignites on about 4 ticks in 100; it then burns for 8 seconds (160 ticks).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-20-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-T                   BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-LD                  PIC 99.
 01 WS-B                   FLOAT-LONG.
 01 WS-P                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "N" TO TL-MODE
*>   The formula of the section, per light, against the table of the engine (ten-thousandths, rounded).
     PERFORM VARYING WS-L FROM 12 BY 1 UNTIL WS-L > 15
         COMPUTE WS-B = (WS-L / 15) / (4 - 3 * WS-L / 15)
         IF WS-B > 0.5
             COMPUTE WS-P ROUNDED = (WS-B - 0.4) * 2 / 30 * 10000
         ELSE
             MOVE 0 TO WS-P
         END-IF
         MOVE WS-L TO WS-LD
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 20§20.6 sunburn chance at light " WS-LD " in ten-thousandths" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-P TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-L > 12
             MOVE SM-BURN-CHANCE(WS-L - 12) TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   A zombie in the open at noon: about 4 ignitions per 100 ticks, each for 160 ticks.
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-X = WS-BX + 0.5
     MOVE WS-BY TO WS-Y
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE 6000 TO CW-TIME
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "STDMOB-INDEX" USING WS-ZOMBIE-TYPE WS-M
     MOVE 0 TO WS-HITS
     MOVE 0 TO WS-P
     PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T >= 4000
         COMPUTE CW-TIME = 3000 + WS-T
         MOVE 0 TO EN-BURN(WS-ROW)
         CALL "STDMOB-BURN" USING WS-ROW WS-M
         IF EN-BURN(WS-ROW) > 0
             ADD 1 TO WS-HITS
             MOVE EN-BURN(WS-ROW) TO WS-P
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§20.6 zombie at light 15, noon, open sky: about 160 ignitions in 4000 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS >= 110 AND WS-HITS <= 210
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§20.6 an ignition burns for 8 seconds (160 ticks)" TO TL-CASE
     MOVE 160 TO TL-EXPECTED-N
     MOVE WS-P TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-20-6.
 COPY CORETEST.
 COPY MOBSPTEST.
