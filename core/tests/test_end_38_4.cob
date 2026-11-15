*> Implementation test of the End's density functions (core/src/end-38.cob; T1727, T1728; docs/protocol/38-end.md section 4 and the worked values
*> 13.2): the central island cone (4.2), the island simplex noise (4.3, SimplexNoise(r, true) after 17292 skipped draws), the outer-island
*> field at the block points of the table, the larger of both (end/islands, independent of y), and the vertical profile A_blend (5.1 table).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY END.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-SEED2               BINARY-DOUBLE SIGNED VALUE 12345.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-TOL                 BINARY-LONG VALUE 20.
 01 WS-SEED3               BINARY-DOUBLE SIGNED VALUE -5.
 01 WS-ED                  PIC -(5)9.
 01 WS-ED2                 PIC -(5)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM END-TABLES
     CALL "END-SETUP" USING WS-SEED
*>   4.2 the central island: (clamp(100 - d, -100, 80) - 8) / 128
     MOVE 0 TO WS-X WS-Z
     PERFORM CHECK-CENTRAL-0
     MOVE 16 TO WS-X
     MOVE 0 TO WS-Z
     MOVE 5625000 TO WS-WANT
     PERFORM CHECK-CENTRAL
     MOVE 3 TO WS-X
     MOVE 4 TO WS-Z
     MOVE 5625000 TO WS-WANT
     PERFORM CHECK-CENTRAL
     MOVE 100 TO WS-X
     MOVE 0 TO WS-Z
     MOVE -625000 TO WS-WANT
     PERFORM CHECK-CENTRAL
     MOVE 0 TO WS-X
     MOVE -160 TO WS-Z
     MOVE -5312500 TO WS-WANT
     PERFORM CHECK-CENTRAL
     MOVE 200 TO WS-X
     MOVE 0 TO WS-Z
     MOVE -8437500 TO WS-WANT
     PERFORM CHECK-CENTRAL
     MOVE 1500 TO WS-X
     MOVE 700 TO WS-Z
     MOVE -8437500 TO WS-WANT
     PERFORM CHECK-CENTRAL
*>   4.3 the simplex noise of the island field, seed 0 (offsets 0: N.get(0, 0) = 0) and seed 12345
     MOVE 0 TO WS-X WS-Z
     CALL "END-SIMPLEX" USING WS-X WS-Z WS-V
     MOVE "acceptance US12 38§4 The density functions simplex N.get(0, 0) = 0 (zero offsets)" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     MOVE 70 TO WS-X
     MOVE 3 TO WS-Z
     CALL "END-SIMPLEX" USING WS-X WS-Z WS-V
     MOVE "acceptance US12 38§4 The density functions simplex N.get(70, 3) seed 0 = 0.4381723" TO TL-CASE
     MOVE 4381723 TO WS-WANT
     PERFORM CHECK-V
     MOVE -66 TO WS-X
     MOVE -70 TO WS-Z
     CALL "END-SIMPLEX" USING WS-X WS-Z WS-V
     MOVE "acceptance US12 38§4 The density functions simplex N.get(-66, -70) seed 0 = 0.4260233" TO TL-CASE
     MOVE 4260233 TO WS-WANT
     PERFORM CHECK-V
*>   4.3 H and the outer field at block points (seed 0)
     MOVE 1500 TO WS-X
     MOVE 0 TO WS-Z
     MOVE -1279246 TO WS-WANT
     PERFORM CHECK-OUTER
     MOVE -1200 TO WS-X
     MOVE 900 TO WS-Z
     MOVE 1752335 TO WS-WANT
     PERFORM CHECK-OUTER
     MOVE 3000 TO WS-X
     MOVE -1000 TO WS-Z
     MOVE 3602252 TO WS-WANT
     PERFORM CHECK-OUTER
     MOVE 2000 TO WS-X
     MOVE 2000 TO WS-Z
     MOVE -6070752 TO WS-WANT
     PERFORM CHECK-OUTER
     MOVE 0 TO WS-X WS-Z
     MOVE -8437500 TO WS-WANT
     PERFORM CHECK-OUTER
     MOVE 160 TO WS-X
     MOVE 0 TO WS-Z
     MOVE -8437500 TO WS-WANT
     PERFORM CHECK-OUTER
*>   4.2 end/islands is the larger of both
     MOVE 0 TO WS-X WS-Z
     CALL "END-ISLANDS" USING WS-X WS-Z WS-V
     MOVE "acceptance US12 38§4 The density functions islands (0, 0) is the central value 0.5625" TO TL-CASE
     MOVE 5625000 TO WS-WANT
     PERFORM CHECK-V
     MOVE 3000 TO WS-X
     MOVE -1000 TO WS-Z
     CALL "END-ISLANDS" USING WS-X WS-Z WS-V
     MOVE "acceptance US12 38§4 The density functions islands (3000, -1000) is the outer value 0.3602252" TO TL-CASE
     MOVE 3602252 TO WS-WANT
     PERFORM CHECK-V
     MOVE 160 TO WS-X
     MOVE 0 TO WS-Z
     CALL "END-ISLANDS" USING WS-X WS-Z WS-V
     MOVE "acceptance US12 38§4 The density functions islands (160, 0) is the central slope -0.53125" TO TL-CASE
     MOVE -5312500 TO WS-WANT
     PERFORM CHECK-V
*>   the seed changes the permutation: N.get(65, 0) at seed 12345 is -0.8321315 (an island centre candidate, below -0.9 is rarer)
     CALL "END-SETUP" USING WS-SEED2
     MOVE 65 TO WS-X
     MOVE 0 TO WS-Z
     CALL "END-SIMPLEX" USING WS-X WS-Z WS-V
     MOVE "acceptance US12 38§4 The density functions simplex N.get(65, 0) seed 12345 = -0.8321315" TO TL-CASE
     MOVE -8321315 TO WS-WANT
     PERFORM CHECK-V
*>   a negative seed is the unsigned 64 bit word of its bits; the same seed again changes nothing (the memo stays)
     CALL "END-SETUP" USING WS-SEED2
     CALL "END-SIMPLEX" USING WS-X WS-Z WS-V
     MOVE "acceptance US12 38§4 The density functions setting up the same seed again keeps N.get(65, 0)" TO TL-CASE
     MOVE -8321315 TO WS-WANT
     PERFORM CHECK-V
     CALL "END-SETUP" USING WS-SEED3
     CALL "END-SIMPLEX" USING WS-X WS-Z WS-V
     MOVE "acceptance US12 38§4 The density functions seed -5 gives a simplex value in [-1, 1] other than seed 12345's" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     COMPUTE WS-GOT ROUNDED = WS-V * 10000000
     IF WS-GOT >= -10000000 AND WS-GOT <= 10000000 AND WS-GOT NOT = -8321315
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   5.1 the vertical profile with S = 0.5625 (13.1 table)
     MOVE 5625000 TO WS-WANT
     MOVE 0.5625 TO WS-S
     MOVE 0 TO WS-Y
     MOVE -2343750 TO WS-WANT
     PERFORM CHECK-PROFILE
     MOVE 4 TO WS-Y
     MOVE -2343750 TO WS-WANT
     PERFORM CHECK-PROFILE
     MOVE 18 TO WS-Y
     MOVE 1640625 TO WS-WANT
     PERFORM CHECK-PROFILE
     MOVE 32 TO WS-Y
     MOVE 5625000 TO WS-WANT
     PERFORM CHECK-PROFILE
     MOVE 56 TO WS-Y
     MOVE 5625000 TO WS-WANT
     PERFORM CHECK-PROFILE
     MOVE 60 TO WS-Y
     MOVE 1875000 TO WS-WANT
     PERFORM CHECK-PROFILE
     MOVE 62 TO WS-Y
     MOVE 0 TO WS-WANT
     PERFORM CHECK-PROFILE
     MOVE 64 TO WS-Y
     MOVE -1875000 TO WS-WANT
     PERFORM CHECK-PROFILE
     MOVE 312 TO WS-Y
     MOVE -234375000 TO WS-WANT
     PERFORM CHECK-PROFILE
     STOP RUN.
 CHECK-CENTRAL-0.
     MOVE 5625000 TO WS-WANT
     PERFORM CHECK-CENTRAL.
 CHECK-CENTRAL.
     CALL "END-CENTRAL" USING WS-X WS-Z WS-V
     MOVE WS-X TO WS-ED
     MOVE WS-Z TO WS-ED2
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 38§4 The density functions central island (" FUNCTION TRIM(WS-ED) ", "
         FUNCTION TRIM(WS-ED2) ")" DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-V.
 CHECK-OUTER.
     CALL "END-OUTER" USING WS-X WS-Z WS-V
     MOVE WS-X TO WS-ED
     MOVE WS-Z TO WS-ED2
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 38§4 The density functions outer islands (" FUNCTION TRIM(WS-ED) ", "
         FUNCTION TRIM(WS-ED2) ") seed 0" DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-V.
 CHECK-PROFILE.
     CALL "END-PROFILE" USING WS-Y WS-S WS-V
     MOVE WS-Y TO WS-ED
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 38§4 The density functions A_blend at y " FUNCTION TRIM(WS-ED) " for S 0.5625"
         DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-V.
 COPY ENDTEST.
