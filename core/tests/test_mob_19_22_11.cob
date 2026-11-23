*> Implementation test (wrap I3, T2408/T2409; docs/protocol/19 section 22.11 and 44-3 section 3.2): the server step of a villager broadcasts entity event 42 one tick in 100 (a draw of the villager's
*> hash below 0.01) when a raid at its position is active and not over. Not for a draw of 0.01 or more, a raid that is over, or no raid. Event 42 is Entity Event (0x22) to the viewers.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-22-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 COPY RAIDSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BABY                BINARY-LONG VALUE 0.
 01 WS-SALT                BINARY-LONG VALUE 4242.
 01 WS-R                   FLOAT-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-LOW-TIME            BINARY-LONG.
 01 WS-HIGH-TIME           BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     INITIALIZE RD-STATE
*>   The two ticks: one whose draw is below 0.01 and one whose draw is not.
     MOVE 0 TO WS-LOW-TIME WS-HIGH-TIME
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-LOW-TIME > 0 AND WS-HIGH-TIME > 0
         MOVE WS-T TO CW-TIME
         CALL "AQUA-RAND" USING WS-V WS-SALT WS-R
         IF WS-R < 0.01 AND WS-LOW-TIME = 0
             MOVE WS-T TO WS-LOW-TIME
         END-IF
         IF WS-R >= 0.01 AND WS-HIGH-TIME = 0
             MOVE WS-T TO WS-HIGH-TIME
         END-IF
     END-PERFORM
*>   No raid: nothing even on the low draw.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE WS-LOW-TIME TO CW-TIME
     CALL "VL-RAID-EVENT" USING WS-V
     PERFORM COUNT-EVENTS
     MOVE "implementation 19 22.11 no raid: no entity event 42" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TALLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An ongoing raid at the villager.
     MOVE 1 TO RD-USED(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE WS-DIM TO RD-DIM(1)
     MOVE WS-X0 TO RD-CX(1)
     MOVE WS-Y TO RD-CY(1)
     MOVE WS-Z0 TO RD-CZ(1)
     MOVE WS-HIGH-TIME TO CW-TIME
     CALL "VL-RAID-EVENT" USING WS-V
     PERFORM COUNT-EVENTS
     MOVE "implementation 19 22.11 a raid at the villager but a draw of 0.01 or more: no entity event 42" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TALLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-LOW-TIME TO CW-TIME
     CALL "VL-RAID-EVENT" USING WS-V
     PERFORM COUNT-EVENTS
     MOVE "implementation 19 22.11 a raid at the villager and a draw below 0.01: entity event 42 (Entity Event 0x22) goes to the viewers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-TALLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The villager's own server step calls it.
     MOVE WS-LOW-TIME TO CW-TIME
     CALL "VL-CORE-TICK" USING WS-V WS-S WS-BABY
     PERFORM COUNT-EVENTS
     MOVE "implementation 19 22.11 the villager's server step (VL-CORE-TICK) broadcasts event 42 on that draw" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-TALLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A raid that is over (victory) is not active.
     MOVE 2 TO RD-STATUS(1)
     MOVE WS-LOW-TIME TO CW-TIME
     CALL "VL-RAID-EVENT" USING WS-V
     PERFORM COUNT-EVENTS
     MOVE "implementation 19 22.11 a raid that is over: no entity event 42" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TALLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A raid too far away (centre 100 blocks off): none.
     MOVE 1 TO RD-STATUS(1)
     COMPUTE RD-CX(1) = WS-X0 + 100
     CALL "VL-RAID-EVENT" USING WS-V
     PERFORM COUNT-EVENTS
     MOVE "implementation 19 22.11 a raid 100 blocks away is not at the villager's position: no entity event 42" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TALLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COUNT-EVENTS.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-TALLY
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 34 " ALL " 34x".
 END PROGRAM TEST-MOB-19-22-11.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY VILLTEST.
