*> Implementation test (002-lane-mobsfull-h2, T2232; docs/protocol/18 section 4.10 Conversion): the outcome flags of Mob.convertTo.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-4-10.
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
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     CALL "CONVERT-PLAN" USING WS-A WS-B WS-C WS-D WS-E WS-T
     MOVE "acceptance US15 18§4.10 Conversion convertTo SINGLE on a server level creates, adds, discards the old mob, keeps equipment and copies position" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "11111" TO TL-EXPECTED
     MOVE WS-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     CALL "CONVERT-PLAN" USING WS-A WS-B WS-C WS-D WS-E WS-T
     MOVE "acceptance US15 18§4.10 Conversion convertTo SPLIT_ON_DEATH adds the new mob and keeps the old one" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "11000" TO TL-EXPECTED
     MOVE WS-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     CALL "CONVERT-PLAN" USING WS-A WS-B WS-C WS-D WS-E WS-T
     MOVE "acceptance US15 18§4.10 Conversion convertTo on a client level does not add the new entity" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "10111" TO TL-EXPECTED
     MOVE WS-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     CALL "CONVERT-PLAN" USING WS-A WS-B WS-C WS-D WS-E WS-T
     MOVE "acceptance US15 18§4.10 Conversion convertTo returns null when the old mob is removed" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "00000" TO TL-EXPECTED
     MOVE WS-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     CALL "CONVERT-PLAN" USING WS-A WS-B WS-C WS-D WS-E WS-T
     MOVE "acceptance US15 18§4.10 Conversion convertTo returns null when the new mob cannot be created" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "00000" TO TL-EXPECTED
     MOVE WS-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     CALL "CONVERT-PLAN" USING WS-A WS-B WS-C WS-D WS-E WS-T
     MOVE "acceptance US15 18§4.10 Conversion convertTo SINGLE without keepEquipment does not move equipment" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "11101" TO TL-EXPECTED
     MOVE WS-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-4-10.
