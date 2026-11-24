*> Implementation test (002-lane-mobsfull-h2, T2230; docs/protocol/18 section 4.9 Monster base class): the light dependent magic value, walk target value, no-action time and defaults of Monster.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-4-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-D                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-J                 BINARY-LONG.
 01 WS-K                 BINARY-LONG.
 01 WS-L                 BINARY-LONG.
 01 WS-M                 BINARY-LONG.
 01 WS-N                 BINARY-LONG.
 01 WS-O                 BINARY-LONG.
 01 WS-P                 BINARY-LONG.
 01 WS-O1                BINARY-LONG.
 01 WS-O2                BINARY-LONG.
 01 WS-O3                BINARY-LONG.
 01 WS-O4                BINARY-LONG.
 01 WS-O5                BINARY-LONG.
 01 WS-O6                BINARY-LONG.
 01 WS-O7                BINARY-LONG.
 01 WS-O8                BINARY-LONG.
 01 WS-F1                FLOAT-LONG.
 01 WS-F2                FLOAT-LONG.
 01 WS-F3                FLOAT-LONG.
 01 WS-F4                FLOAT-LONG.
 01 WS-F5                FLOAT-LONG.
 01 WS-F6                FLOAT-LONG.
 01 WS-F7                FLOAT-LONG.
 01 WS-F8                FLOAT-LONG.
 01 WS-G1                FLOAT-LONG.
 01 WS-G2                FLOAT-LONG.
 01 WS-G3                FLOAT-LONG.
 01 WS-G4                FLOAT-LONG.
 01 WS-T                 PIC X(80).
 01 WS-U                 PIC X(80).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 15 TO WS-A
     MOVE 0 TO WS-F1
     CALL "LIGHT-MAGIC" USING WS-A WS-F1 WS-G1
     MOVE "acceptance US15 18§4.9 Monster base class light-dependent magic value of full light in the overworld is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "LIGHT-MAGIC" USING WS-A WS-F1 WS-G1
     MOVE "acceptance US15 18§4.9 Monster base class light-dependent magic value of darkness in the overworld is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-A
     MOVE 0.1 TO WS-F1
     CALL "LIGHT-MAGIC" USING WS-A WS-F1 WS-G1
     MOVE "acceptance US15 18§4.9 Monster base class light level 7 with ambient light 0.1 (nether) is 0.2615" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2615 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0.25 TO WS-F1
     CALL "LIGHT-MAGIC" USING WS-A WS-F1 WS-G1
     MOVE "acceptance US15 18§4.9 Monster base class darkness with the end ambient light 0.25 is 0.25" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 250 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-F1
     CALL "MONSTER-WALK-VALUE" USING WS-F1 WS-G1
     MOVE "acceptance US15 18§4.9 Monster base class getWalkTargetValue = magic value - 0.5 (dark)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-F1
     CALL "MONSTER-WALK-VALUE" USING WS-F1 WS-G1
     MOVE "acceptance US15 18§4.9 Monster base class getWalkTargetValue of full light is 0.5" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.6 TO WS-F1
     MOVE 10 TO WS-A
     CALL "MONSTER-NO-ACTION" USING WS-F1 WS-A
     MOVE "acceptance US15 18§4.9 Monster base class updateNoActionTime adds 2 in bright light (above 0.5)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 12 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO WS-F1
     CALL "MONSTER-NO-ACTION" USING WS-F1 WS-A
     MOVE "acceptance US15 18§4.9 Monster base class updateNoActionTime adds nothing at 0.5" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 12 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MONSTER-DEFAULTS" USING WS-F1 WS-A
     MOVE "acceptance US15 18§4.9 Monster base class Monster attack_damage default is 2.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-F1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.9 Monster base class Monster experience reward is 5" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-4-9.
