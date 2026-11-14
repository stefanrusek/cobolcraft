*> Implementation test (002-lane-mobsfull-h2, T2224; docs/protocol/18 section 4.6 Shared sensors and behaviours): behaviour defaults, sensor scheduling and the MoveToTargetSink and TemptingSensor rules.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-4-6.
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
     CALL "BEHAVIOR-DEFAULT-DURATION" USING WS-A WS-B
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours a behaviour without explicit durations lasts 60 ticks" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 60060 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A * 1000 + WS-B
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 20 TO WS-B
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours the first run of a sensor is delayed by a random 0..scanRate-1 (timer 5 runs on tick 5)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SENSOR-TICK" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours a sensor not yet due does not run" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours the timer counts down" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "SENSOR-TICK" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours a sensor runs when its timer reaches 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours a sensor rearms with its scan rate (20)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-B
     MOVE 13 TO WS-C
     CALL "SENSOR-INIT" USING WS-A WS-B WS-C
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours sensor initial delay is the roll" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 13 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 2 TO WS-B
     CALL "MOVE-SINK-REACHED" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours MoveToTargetSink has reached a target within the close-enough Manhattan distance" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "MOVE-SINK-REACHED" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours MoveToTargetSink has not reached a farther target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4.5 TO WS-F1
     CALL "MOVE-SINK-REPATH" USING WS-F1 WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours MoveToTargetSink re-paths when the target moved more than 2 blocks (squared 4)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-F1
     CALL "MOVE-SINK-REPATH" USING WS-F1 WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours MoveToTargetSink keeps the path for a smaller move" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-F1
     MOVE 2 TO WS-F2
     CALL "SENSOR-BOX" USING WS-F1 WS-F2 WS-G1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours NearestLivingEntitySensor inflates the mob box by the follow range on every side (size 2 + 2 x 16)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 34 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     CALL "TEMPTING-SENSOR" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours TemptingSensor finds a player holding a tempting item within the tempt range" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-C
     CALL "TEMPTING-SENSOR" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours TemptingSensor ignores a player that rides the mob" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "TEMPTING-SENSOR" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours TemptingSensor ignores a player not holding food" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-D
     MOVE 0 TO WS-A
     CALL "TEMPTING-SENSOR" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours TemptingSensor ignores a player out of range" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "TEMPTING-SENSOR" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.6 Shared sensors and behaviours TemptingSensor ignores a spectator" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-4-6.
