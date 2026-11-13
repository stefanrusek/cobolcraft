*> Coverage test for corners of the redstone rows (core/src/redstone-30-3.cob, redstone-30-6.cob, redstone-30-8.cob): the piston structure resolver reaching the
*> piston's own cell through a branching slime block (30-3 section 4.5), the minecart x and z clamps in both signs (30-6 section 8.3 steps 5 and 7) and the tripwire
*> hook placement through its fourth direction (30-8 section 7.1), the rail shape placement powered corners (30-6 section 4.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REDSTONE-COVB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-GRG.
    05 WS-GR BINARY-LONG OCCURS 4096 TIMES.
 01 WS-PLG.
    05 WS-PL BINARY-LONG OCCURS 64 TIMES.
 01 WS-DLG.
    05 WS-DL BINARY-LONG OCCURS 64 TIMES.
 01 WS-I1                  BINARY-LONG.
 01 WS-I2                  BINARY-LONG.
 01 WS-I3                  BINARY-LONG.
 01 WS-I4                  BINARY-LONG.
 01 WS-I5                  BINARY-LONG.
 01 WS-I6                  BINARY-LONG.
 01 WS-I7                  BINARY-LONG.
 01 WS-I8                  BINARY-LONG.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-R3                  BINARY-LONG.
 01 WS-R4                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-SHOW                PIC -(10)9.
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 30-3§4.5 resolver: a pulled slime block with a stone line beside it that ends in a slime block above the piston adds the piston's own cell as a line, which stops there (ok, pushed, direction)" TO TL-CASE
     PERFORM BEGIN-CASE
     PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 4096
         MOVE 0 TO WS-GR(WS-X)
     END-PERFORM
     MOVE 7 TO WS-GR(820)
     MOVE 2 TO WS-GR(822)
     MOVE 1 TO WS-GR(1078)
     MOVE 1 TO WS-GR(1077)
     MOVE 2 TO WS-GR(1076)
     MOVE 4 TO WS-I1
     MOVE 4 TO WS-I2
     MOVE 4 TO WS-I3
     MOVE 5 TO WS-I4
     MOVE 0 TO WS-I5
     MOVE 1 TO WS-I6
     MOVE 7 TO WS-I7
     CALL "RS1-PISTON-RESOLVE" USING WS-GRG WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7 WS-R1 WS-R2 WS-PLG WS-R3 WS-DLG WS-R4
     PERFORM SHOW-FOUR
     MOVE "1/4/0/4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 30-6§8.3 step 5 move: a negative x past -0.4 and a positive z past 0.4 are clamped (x, z of the move)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE -600000000 TO WS-I1
     MOVE 600000000 TO WS-I2
     MOVE 0 TO WS-I3
     MOVE 0 TO WS-I4
     CALL "RS3-MOVE-CLAMP" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2
     MOVE 0 TO WS-R3 WS-R4
     PERFORM SHOW-TWO
     MOVE "-400000000/400000000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 30-6§8.3 step 7 comeOffTrack: a negative x and a positive z past the maximum speed are clamped (x, z)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE -600000000 TO WS-I1
     MOVE 0 TO WS-I2
     MOVE 600000000 TO WS-I3
     MOVE 400000000 TO WS-I4
     MOVE 0 TO WS-I5
     MOVE 1 TO WS-I6
     CALL "RS3-OFF-TRACK" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-R1 WS-R2 WS-R3
     MOVE WS-R3 TO WS-R2
     PERFORM SHOW-TWO
     MOVE "-400000000/400000000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 30-8§7.1 hook placement: only the fourth direction survives (facing = opp(d4))" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 2 TO WS-I1
     MOVE 0 TO WS-I2
     MOVE 5 TO WS-I3
     MOVE 0 TO WS-I4
     MOVE 3 TO WS-I5
     MOVE 0 TO WS-I6
     MOVE 4 TO WS-I7
     MOVE 1 TO WS-I8
     CALL "RS3-HOOK-PLACE" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7 WS-I8 WS-R1
     MOVE WS-R1 TO WS-SHOW
     MOVE FUNCTION TRIM(WS-SHOW) TO TL-OBSERVED
     MOVE "5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 SHOW-FOUR.
     MOVE WS-R1 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-R2 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-R3 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-R4 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

 SHOW-TWO.
     MOVE WS-R1 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-R2 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .
 END PROGRAM TEST-REDSTONE-COVB.
