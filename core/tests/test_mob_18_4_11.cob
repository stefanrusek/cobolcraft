*> Implementation test (002-lane-mobsfull-h2, T2234; docs/protocol/18 section 4.11 Bucketable): bucket pickup and the keys saved to and restored from the bucket data.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-4-11.
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
     MOVE 1 TO WS-B
     CALL "BUCKET-PICKUP" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.11 Bucketable bucketMobPickup works with a water bucket on a living mob" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "BUCKET-PICKUP" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.11 Bucketable bucketMobPickup needs a water bucket" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "BUCKET-PICKUP" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.11 Bucketable bucketMobPickup needs a living mob" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     CALL "BUCKET-KEYS" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-T
     MOVE "acceptance US15 18§4.11 Bucketable saveDefaultDataToBucketTag always writes Health" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Health" TO TL-EXPECTED
     MOVE WS-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 1 TO WS-F
     CALL "BUCKET-KEYS" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-T
     MOVE "acceptance US15 18§4.11 Bucketable the boolean keys are written only when true, in order" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Health NoAI NoGravity Invulnerable PersistenceRequired" TO TL-EXPECTED
     MOVE WS-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     MOVE 1 TO WS-D
     CALL "BUCKET-KEYS" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-T
     MOVE "acceptance US15 18§4.11 Bucketable every key when all are true" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Health NoAI Silent NoGravity Glowing Invulnerable PersistenceRequired" TO TL-EXPECTED
     MOVE WS-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "BUCKET-LOAD-PERSISTENCE" USING WS-A WS-O1
     MOVE "acceptance US15 18§4.11 Bucketable loading sets persistence only when the stored value is true" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "BUCKET-LOAD-PERSISTENCE" USING WS-A WS-O1
     MOVE "acceptance US15 18§4.11 Bucketable loading does not touch persistence for a stored false" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-4-11.
