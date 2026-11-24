*> Implementation test closing the line gaps of the Nether generator files (core/src/nether-37-2.cob, nether-37-4.cob, nether-37-4b.cob):
*> a negative world seed (the unsigned value of the 64 bits), the clamped gradient with the anchors the other way round, both bedrock
*> gradients at their true edge, the carving ellipsoid reaching the top of the carvable rows (y 120), the soul-sand-valley and basalt-deltas
*> gravel patch and basalt selector, and the nether_wart noise at its threshold (the wart noise value is placed in the column cache,
*> because a column of seed 0 with wart >= 1.17 and netherrack < 0.54 is not found within 6000 blocks: the largest value there is 1.1256).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-COV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY NETHER.
 COPY NETHERCV.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-NEG                 BINARY-DOUBLE SIGNED VALUE -1.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-Y                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 1.
 01 WS-R                   FLOAT-LONG.
 01 WS-SCALED              FLOAT-LONG.
 01 WS-WHICH               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-SDA                 BINARY-LONG.
 01 WS-SDB                 BINARY-LONG.
 01 WS-SD                  BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-HR                  FLOAT-LONG.
 01 WS-VR                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM NETHER-TABLES
     CALL "NETHER-SETUP" USING WS-NEG
     COMPUTE WS-DIFF = NH-SEED - 18446744073709551616
     MOVE "acceptance US12 37-2§4 world seed -1 is the unsigned 64 bits 2^64 - 1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-DIFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "NETHER-SETUP" USING WS-SEED
*>   the clamped gradient with from > to: from_v + (clamp(y) - from_c) * ((to_v - from_v) / (to_c - from_c)), anchors 100 and 0
     MOVE 100 TO WS-FROM
     MOVE 0 TO WS-TO
     MOVE 25 TO WS-Y
     PERFORM GRADIENT-CASE
     MOVE "acceptance US12 37-2§5 gradient anchors 100 to 0, values 0 to 1, y 25: 0.75" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 200 TO WS-Y
     PERFORM GRADIENT-CASE
     MOVE "acceptance US12 37-2§5 gradient anchors 100 to 0, y 200 clamps to the from anchor: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -5 TO WS-Y
     PERFORM GRADIENT-CASE
     MOVE "acceptance US12 37-2§5 gradient anchors 100 to 0, y -5 clamps to the to anchor: 1" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the vertical_gradient condition at its true edges: floor y 0, roof y 122
     MOVE 1 TO WS-WHICH
     MOVE 0 TO WS-X WS-Z WS-Y
     CALL "NETHER-GRADIENT-AT" USING WS-WHICH WS-X WS-Y WS-Z WS-G
     MOVE "acceptance US12 37-4§5 5.2 floor gradient is true at y 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-WHICH
     MOVE 122 TO WS-Y
     CALL "NETHER-GRADIENT-AT" USING WS-WHICH WS-X WS-Y WS-Z WS-G
     MOVE "acceptance US12 37-4§5 5.2 roof gradient is true at y 122" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the ellipsoid reaches the top carvable row y 120 (cy 118, vertical radius 18.5: upper bound 136 clamps to 120)
     CALL "NETHER-CV-SETUP"
     MOVE 3.5 TO WS-CX
     MOVE 3.5 TO WS-CZ
     MOVE 118 TO WS-CY
     MOVE 3.7 TO WS-HR
     MOVE 18.5 TO WS-VR
     MOVE LOW-VALUES TO NC-MASK
     MOVE 0 TO NC-CX NC-CZ
     CALL "NETHER-CV-ELLIPSOID" USING WS-CX WS-CY WS-CZ WS-HR WS-VR
     COMPUTE WS-IDX = (120 - 1) + (3 + 16 * 3) * 120 + 1
     MOVE "acceptance US12 37-4§7 an ellipsoid at cy 118 carves the axis column up to y 120" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF NC-MASK(WS-IDX:1) = "1"
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   rules 4 and 5 at a column with the soul sand valley (2) and the deltas (5): the gravel patch at (0, 0) (patch >= -0.012), the selector at (49, 0)
     MOVE 5 TO WS-BIOME
     MOVE 0 TO WS-X WS-Z
     MOVE 1 TO WS-SDA
     MOVE 20 TO WS-SDB
     MOVE 3 TO WS-SD
     MOVE 33 TO WS-Y
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§5 5.1 4: deltas top block in the gravel band where patch >= -0.012: gravel" TO TL-CASE
     MOVE 103 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 49 TO WS-X
     MOVE 90 TO WS-Y
     MOVE 11 TO WS-SDB
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.8 deltas top block y 90 where the selector >= 0 (column 49, 0): basalt" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the wart block of the forests: wart noise 1.2 and netherrack noise 0.1 in the column cache
     MOVE 31 TO WS-Y
     MOVE 3 TO WS-BIOME
     MOVE 2 TO WS-SD
     PERFORM WART-RULE
     MOVE "acceptance US12 37-4§5 6c crimson forest with wart noise 1.2 at y 31: nether wart block" TO TL-CASE
     MOVE 109 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-BIOME
     PERFORM WART-RULE
     MOVE "acceptance US12 37-4§5 6b warped forest with wart noise 1.2 at y 31: warped wart block" TO TL-CASE
     MOVE 107 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 GRADIENT-CASE.
     CALL "NETHER-GRADIENT" USING WS-Y WS-FROM WS-TO WS-V0 WS-V1 WS-R
     COMPUTE WS-SCALED = WS-R * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCALED.

 SET-RING.
     COMPUTE WS-QX = FUNCTION INTEGER((WS-X - 2) / 4) - 1
     COMPUTE WS-QZ = FUNCTION INTEGER((WS-Z - 2) / 4) - 1
     MOVE WS-QX TO NH-RING-QX
     MOVE WS-QZ TO NH-RING-QZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-BIOME TO NH-RING(WS-I)
     END-PERFORM.

 RULE-AT.
     PERFORM SET-RING
     CALL "NETHER-RULE" USING WS-X WS-Y WS-Z WS-SDA WS-SDB WS-SD WS-OUT.

 WART-RULE.
     MOVE 1 TO WS-SDA
     MOVE 30 TO WS-SDB
     MOVE 0 TO WS-X WS-Z
     MOVE 0 TO NH-CC-X NH-CC-Z
     MOVE 0 TO NH-CC-HAVE(1) NH-CC-HAVE(2) NH-CC-HAVE(5) NH-CC-HAVE(6) NH-CC-HAVE(7)
     MOVE 1 TO NH-CC-HAVE(3) NH-CC-HAVE(4)
     MOVE 0.1 TO NH-CC-VAL(3)
     MOVE 1.2 TO NH-CC-VAL(4)
     PERFORM SET-RING
     CALL "NETHER-RULE" USING WS-X WS-Y WS-Z WS-SDA WS-SDB WS-SD WS-OUT.
 COPY NETHERTEST.
 END PROGRAM TEST-NETHER-COV.
