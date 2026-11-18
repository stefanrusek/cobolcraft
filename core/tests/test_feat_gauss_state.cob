*> Test of the spare of nextGaussian (docs/protocol/35-worldgen-features-1-model-and-placement.md section 5.3): the flag and the spare belong to the random source object the
*> Gaussian was drawn from, so a spare left by one state is not returned to a draw on another state, and each state's next draw is its own spare; a reseed of the same state keeps it.
*> The reference values come from the same program after F351-GAUSSIAN-RESET, one state at a time.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-GAUSS-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-STATES.
    05 WS-ST OCCURS 140 TIMES.
       10 WS-ST-LO         BINARY-DOUBLE UNSIGNED.
       10 WS-ST-HI         BINARY-DOUBLE UNSIGNED.
 01 WS-SEED-A              BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-SEED-B              BINARY-DOUBLE UNSIGNED VALUE 9.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-A1                  FLOAT-LONG.
 01 WS-A2                  FLOAT-LONG.
 01 WS-B1                  FLOAT-LONG.
 01 WS-B2                  FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-R1.
    05 WS-R1-V             FLOAT-LONG OCCURS 140 TIMES.
 01 WS-R2.
    05 WS-R2-V             FLOAT-LONG OCCURS 140 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   references: the pairs of the two seeds, drawn alone
     CALL "F351-GAUSSIAN-RESET"
     CALL "WGR-SET-SEED" USING WS-ST(1) WS-SEED-A
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(1) WS-A1
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(1) WS-A2
     CALL "F351-GAUSSIAN-RESET"
     CALL "WGR-SET-SEED" USING WS-ST(2) WS-SEED-B
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(2) WS-B1
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(2) WS-B2
*>   interleaved: A, B, A, B
     CALL "F351-GAUSSIAN-RESET"
     CALL "WGR-SET-SEED" USING WS-ST(1) WS-SEED-A
     CALL "WGR-SET-SEED" USING WS-ST(2) WS-SEED-B
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(1) WS-G
     MOVE "acceptance 35-1§5.3 interleaved states: the first draw of A is the first of its pair" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-G = WS-A1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 2 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(2) WS-G
     MOVE "acceptance 35-1§5.3 a spare left by state A is not returned to state B: B draws the first of its own pair" TO TL-CASE
     IF WS-G = WS-B1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 2 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(1) WS-G
     MOVE "acceptance 35-1§5.3 A's next draw is A's own spare" TO TL-CASE
     IF WS-G = WS-A2
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 2 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(2) WS-G
     MOVE "acceptance 35-1§5.3 B's next draw is B's own spare" TO TL-CASE
     IF WS-G = WS-B2
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 2 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a reseed of the same state keeps its spare
     CALL "F351-GAUSSIAN-RESET"
     CALL "WGR-SET-SEED" USING WS-ST(1) WS-SEED-A
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(1) WS-G
     CALL "WGR-SET-SEED" USING WS-ST(1) WS-SEED-B
     CALL "F351-NEXT-GAUSSIAN" USING WS-ST(1) WS-G
     MOVE "acceptance 35-1§5.3 the spare survives a reseed of the same state" TO TL-CASE
     IF WS-G = WS-A2
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 2 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   many states: 140 states each with a pending spare; the first draw of every state is the first of its own pair, also past the table's size
     CALL "F351-GAUSSIAN-RESET"
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 140
         COMPUTE WS-SEED = 100 + WS-I
         CALL "WGR-SET-SEED" USING WS-ST(WS-I) WS-SEED
         CALL "F351-NEXT-GAUSSIAN" USING WS-ST(WS-I) WS-R1-V(WS-I)
     END-PERFORM
     CALL "F351-GAUSSIAN-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 140
         COMPUTE WS-SEED = 100 + WS-I
         CALL "WGR-SET-SEED" USING WS-ST(WS-I) WS-SEED
         CALL "F351-NEXT-GAUSSIAN" USING WS-ST(WS-I) WS-R2-V(WS-I)
         CALL "F351-GAUSSIAN-RESET"
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 140
         IF WS-R1-V(WS-I) NOT = WS-R2-V(WS-I)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance 35-1§5.3 140 states with pending spares: every first draw is the first of its own pair" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-GAUSS-STATE.
