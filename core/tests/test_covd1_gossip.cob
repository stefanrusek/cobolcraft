*> Implementation test (coverage lane D1): the villager killed gossip event (docs/protocol/19 section 22.5, VG-EVENT event 4): major_negative + 25 (cap 100, weight -5), so the
*> reputation of the target with the villager is -125; a second kill adds up to 50 (-250) and the other types stay 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVD1-GOSSIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY VILGOSSIP.
 01 WS-VID                 BINARY-LONG VALUE 7001.
 01 WS-PID                 BINARY-LONG VALUE 7002.
 01 WS-EVENT               BINARY-LONG VALUE 4.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-REP                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "VG-EVENT" USING WS-VID WS-PID WS-EVENT
     CALL "VG-FIND" USING WS-VID WS-PID WS-NO WS-SLOT
     MOVE "covd1 gossip: a villager killed event creates the pair" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLOT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covd1 gossip: villager killed stores major_negative 25" TO TL-CASE
     MOVE 25 TO TL-EXPECTED-N
     MOVE GS-V(WS-SLOT, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covd1 gossip: the other four values stay 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GS-V(WS-SLOT, 2) + GS-V(WS-SLOT, 3) + GS-V(WS-SLOT, 4) + GS-V(WS-SLOT, 5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VG-REP" USING WS-VID WS-PID WS-REP
     MOVE "covd1 gossip: the reputation is 25 x -5 = -125" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-REP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VG-EVENT" USING WS-VID WS-PID WS-EVENT
     MOVE "covd1 gossip: a second kill stores 50" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE GS-V(WS-SLOT, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVD1-GOSSIP.
