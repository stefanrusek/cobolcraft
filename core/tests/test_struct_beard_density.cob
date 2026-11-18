*> Implementation test of the `beardifier` density node (core/src/density.cob node type 35; docs/protocol/36-structures-1-model-placement-starts.md sections 9.3 and 13.14) on the fixture tree
*> core/tests/fixtures/density (t/blend: blend_alpha + blend_offset + blend_density(t/arith) + beardifier): without a prepared beardifier the node is 0, so the function is the evaluator's value of test_density; with one record
*> (beard_box, box (0..4, 60..63, 0..4)) the function differs by exactly the beardifier's value at the position (single precision) near the box and not at all far away, the value is not memoised from the inactive
*> state once SBD-GEN changes (and back), and STRUCT-BASE-HEIGHT turns the beardifier off for its walk and back on after it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-BEARD-DENSITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTBEARD.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:t/blend".
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-R0                  FLOAT-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-SETUP" USING WS-SEED
     MOVE 0 TO SBD-ACTIVE SBD-RIGID-COUNT SBD-JUNC-COUNT
     MOVE 3 TO WS-X
     MOVE 66 TO WS-Y
     MOVE 2 TO WS-Z
     CALL "DENSITY-EVAL" USING WS-KEY WS-X WS-Y WS-Z WS-R0
*>   one record
     MOVE 1 TO SBR-MODE(1)
     MOVE 3 TO SBR-MODE(1)
     MOVE 0 TO SBR-X0(1) SBR-Z0(1) SBR-GROUND(1)
     MOVE 4 TO SBR-X1(1) SBR-Z1(1)
     MOVE 60 TO SBR-Y0(1)
     MOVE 63 TO SBR-Y1(1)
     MOVE 0 TO SBD-AX0 SBD-AZ0
     MOVE 60 TO SBD-AY0
     MOVE 4 TO SBD-AX1 SBD-AZ1
     MOVE 63 TO SBD-AY1
     MOVE 1 TO SBD-RIGID-COUNT
     MOVE 0 TO SBD-JUNC-COUNT
     MOVE 1 TO SBD-ACTIVE
     ADD 1 TO SBD-GEN
     CALL "DENSITY-EVAL" USING WS-KEY WS-X WS-Y WS-Z WS-R1
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-B
     COMPUTE WS-DIFF = WS-R1 - WS-R0 - WS-B
     MOVE "test struct beard density near the box the function differs from the inactive value by the beardifier's value (a nonzero one)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.00001 AND WS-DIFF > -0.00001 AND (WS-B > 0.001 OR WS-B < -0.001)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   far away (x 400): the affected box does not hold it, the function is its inactive value
     MOVE 400 TO WS-X
     MOVE 0 TO SBD-ACTIVE
     ADD 1 TO SBD-GEN
     CALL "DENSITY-EVAL" USING WS-KEY WS-X WS-Y WS-Z WS-R0
     MOVE 1 TO SBD-ACTIVE
     ADD 1 TO SBD-GEN
     CALL "DENSITY-EVAL" USING WS-KEY WS-X WS-Y WS-Z WS-R1
     COMPUTE WS-DIFF = WS-R1 - WS-R0
     MOVE "test struct beard density outside the affected box the beardifier adds nothing" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.0000001 AND WS-DIFF > -0.0000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   switching it off again (with a new SBD-GEN) gives the inactive value back at the near position
     MOVE 3 TO WS-X
     CALL "DENSITY-EVAL" USING WS-KEY WS-X WS-Y WS-Z WS-R1
     MOVE 0 TO SBD-ACTIVE
     ADD 1 TO SBD-GEN
     CALL "DENSITY-EVAL" USING WS-KEY WS-X WS-Y WS-Z WS-R2
     MOVE "test struct beard density off again: the near value is the inactive one (the memo does not keep the active value)" TO TL-CASE
     COMPUTE WS-DIFF = WS-R2 - WS-R1
     MOVE 0 TO TL-OBSERVED-N
     IF (WS-DIFF > 0.001 OR WS-DIFF < -0.001)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the sampler's range test follows a ground level delta: the layers of the record are y 60 - 5 = 55 to 63 (minus 13 below, plus 13 above), so at y 56 the record's own value is the sample and
*>   it is not zero, at y 40 (below 42) the record is left out and the sample is 0; with a delta of 30 the layers are 63 to 90 and the sample is the record's own value at y 80 and at y 100
     MOVE 3 TO SBR-MODE(1)
     MOVE 1 TO SBD-RIGID-COUNT
     MOVE 0 TO SBD-JUNC-COUNT
     MOVE 1 TO SBD-ACTIVE
     MOVE -5 TO SBR-GROUND(1)
     MOVE 2 TO WS-X
     MOVE 2 TO WS-Z
     MOVE 56 TO WS-Y
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-B
     CALL "STRUCT-BEARD-RIGID" USING SBR-MODE(1) SBR-X0(1) SBR-Y0(1) SBR-Z0(1) SBR-X1(1) SBR-Y1(1) SBR-Z1(1) SBR-GROUND(1) WS-X WS-Y WS-Z WS-R1
     COMPUTE WS-DIFF = WS-B - WS-R1
     MOVE "test struct beard density a negative ground level delta lowers the layers: at y 56 the sample is the record's own nonzero value" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.0000001 AND WS-DIFF > -0.0000001 AND (WS-B > 0.001 OR WS-B < -0.001)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-Y
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-B
     MOVE "test struct beard density a record 13 blocks below its lowered layers is left out: the sample at y 40 is 0" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-B < 0.0000001 AND WS-B > -0.0000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 30 TO SBR-GROUND(1)
     MOVE 80 TO WS-Y
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-B
     CALL "STRUCT-BEARD-RIGID" USING SBR-MODE(1) SBR-X0(1) SBR-Y0(1) SBR-Z0(1) SBR-X1(1) SBR-Y1(1) SBR-Z1(1) SBR-GROUND(1) WS-X WS-Y WS-Z WS-R1
     COMPUTE WS-DIFF = WS-B - WS-R1
     MOVE "test struct beard density a ground level delta above the box lifts the layers: at y 80 the sample is the record's own value" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.0000001 AND WS-DIFF > -0.0000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-Y
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-B
     CALL "STRUCT-BEARD-RIGID" USING SBR-MODE(1) SBR-X0(1) SBR-Y0(1) SBR-Z0(1) SBR-X1(1) SBR-Y1(1) SBR-Z1(1) SBR-GROUND(1) WS-X WS-Y WS-Z WS-R1
     COMPUTE WS-DIFF = WS-B - WS-R1
     MOVE "test struct beard density at y 100 inside the lifted range the sample is the record's own value" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.0000001 AND WS-DIFF > -0.0000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO SBR-GROUND(1) SBD-ACTIVE SBD-RIGID-COUNT
     STOP RUN.
 END PROGRAM TEST-STRUCT-BEARD-DENSITY.
