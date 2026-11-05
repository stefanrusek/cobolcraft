*> Implementation test of the deterministic pseudo-random source (core/src/rng.cob; tasks T526;
*> standin-content §1.4.1 integer hash H, used by §12.3, §12.4 and §14.3). Reference values: the
*> check values printed in §1.4.1 (mix(0), mix(1), H(0), H(1, 2), H(-1) and the greystone noise
*> value), and further values computed from the §1.4.1 definition (a 4-argument H as the mob rules
*> use it, the extremes of a 32-bit input, the largest mix input).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RNG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-NAME                PIC X(9) VALUE "greystone".
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE

     MOVE "test rng mix(0) = 0 (§1.4.1 check value)" TO TL-CASE
     MOVE 0 TO WS-V
     CALL "RNG-MIX" USING WS-V WS-R
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK

     MOVE "test rng mix(1) = 4052846564 (§1.4.1 check value)" TO TL-CASE
     MOVE 1 TO WS-V
     CALL "RNG-MIX" USING WS-V WS-R
     MOVE 4052846564 TO TL-EXPECTED-N
     PERFORM CHECK

     MOVE "test rng mix(4294967295) = 1140374694 (largest input; products need 64 bits)"
         TO TL-CASE
     MOVE 4294967295 TO WS-V
     CALL "RNG-MIX" USING WS-V WS-R
     MOVE 1140374694 TO TL-EXPECTED-N
     PERFORM CHECK

     MOVE "test rng H(0) = 652388419 (§1.4.1 check value)" TO TL-CASE
     MOVE 1 TO WS-COUNT
     MOVE 0 TO WS-ARG(1)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     MOVE 652388419 TO TL-EXPECTED-N
     PERFORM CHECK

     MOVE "test rng H(1, 2) = 1898060780 (§1.4.1 check value)" TO TL-CASE
     MOVE 2 TO WS-COUNT
     MOVE 1 TO WS-ARG(1)
     MOVE 2 TO WS-ARG(2)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     MOVE 1898060780 TO TL-EXPECTED-N
     PERFORM CHECK

     MOVE "test rng H(-1) = 1792697577 (§1.4.1 check value: -1 mod 2^32 = 4294967295)" TO TL-CASE
     MOVE 1 TO WS-COUNT
     MOVE -1 TO WS-ARG(1)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     MOVE 1792697577 TO TL-EXPECTED-N
     PERFORM CHECK

     MOVE "test rng H(greystone bytes, 0, 0) = 1030435555 (§1.4.1 noise check value, 11 "
         & "arguments)" TO TL-CASE
     MOVE 11 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         COMPUTE WS-ARG(WS-I) = FUNCTION ORD(WS-NAME(WS-I:1)) - 1
     END-PERFORM
     MOVE 0 TO WS-ARG(10) WS-ARG(11)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     MOVE 1030435555 TO TL-EXPECTED-N
     PERFORM CHECK

     MOVE "test rng H(12, 56, 3, 400) = 2035548027 (a mob wander decision, §12.3)" TO TL-CASE
     MOVE 4 TO WS-COUNT
     MOVE 12 TO WS-ARG(1)
     MOVE 56 TO WS-ARG(2)
     MOVE 3 TO WS-ARG(3)
     MOVE 400 TO WS-ARG(4)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     MOVE 2035548027 TO TL-EXPECTED-N
     PERFORM CHECK

     MOVE "test rng H(-2147483648, 2147483647) = 1018356186 (32-bit extremes)" TO TL-CASE
     MOVE 2 TO WS-COUNT
     MOVE -2147483648 TO WS-ARG(1)
     MOVE 2147483647 TO WS-ARG(2)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     MOVE 1018356186 TO TL-EXPECTED-N
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-RNG.
