*> Acceptance test of US3-formats (FR-007, FR-008, FR-009, FR-010; SC-001): the operator's real user pack
*> tmp/Faithful 32x - 26.3.zip (or COBOLCRAFT_INPUTS; git-ignored input, the test FAILS when it is absent).
*> Given that archive of 5300 entries (2225 stored, 3075 deflated, 234 empty, names up to 101 bytes),
*> When it is opened, every entry is listed by name, resolved by that name to its own number and read with
*> a CRC-32 equal to its central record (stored and deflated entries both), a stored and a deflated
*> entry read to the size and CRC-32 that an independent reader (Python zipfile) reports, and the name
*> lookups (5300 present, 5300 absent) take under a quarter of a second, which a scan of 5300 names of
*> a 13 MB archive per lookup does not. The stored and deflated entries of the committed fixture
*> contract/fixtures/formats/zip/entries.zip read with a matching CRC too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US3-USER-ZIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FORMATS.
 01 WS-INPUT               PIC X(64).
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-ZIP                 USAGE POINTER.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-NAME                PIC X(256).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-NUMBER              PIC 9(5).
 01 WS-UNLISTED            BINARY-LONG.
 01 WS-MISFOUND            BINARY-LONG.
 01 WS-BAD-CRC             BINARY-LONG.
 01 WS-PRESENT-FOUND       BINARY-LONG.
 01 WS-ABSENT-FOUND        BINARY-LONG.
 01 WS-AREA                PIC X(20000).
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CRC                 BINARY-LONG UNSIGNED.
 01 WS-CRC-D               PIC 9(10).
 01 WS-SHOWN               PIC -(9)9.
 01 WS-SHOWN2              PIC -(9)9.
 01 WS-CLOCK.
    05 FILLER              PIC X(8).
    05 WS-HH               PIC 99.
    05 WS-MM               PIC 99.
    05 WS-SS               PIC 99.
    05 WS-CC               PIC 99.
    05 FILLER              PIC X(5).
 01 WS-START-CS            BINARY-LONG.
 01 WS-NOW-CS              BINARY-LONG.
 01 WS-ELAPSED             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "Faithful 32x - 26.3.zip" TO WS-INPUT
     CALL "TEST-INPUT-PATH" USING WS-INPUT WS-PATH WS-PATH-LENGTH
     CALL "ZIP-OPEN" USING WS-PATH WS-PATH-LENGTH WS-ZIP WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE "acceptance US3-user-zip Given the real Faithful pack, When opened, Then status 0 (input present)"
         TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-STATUS NOT = 0
         DISPLAY "the real pack is absent or unreadable: " FUNCTION TRIM(WS-PATH)
         MOVE 1 TO RETURN-CODE
         STOP RUN
     END-IF
     CALL "ZIP-COUNT" USING WS-ZIP WS-COUNT
     MOVE "acceptance US3-user-zip Then it lists 5300 entries" TO TL-CASE
     MOVE 5300 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every entry: listed, resolved to its own number, CRC matches.
     MOVE 0 TO WS-UNLISTED WS-MISFOUND WS-BAD-CRC
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "ZIP-NAME" USING WS-ZIP WS-I WS-NAME WS-NAME-LENGTH
         IF WS-NAME-LENGTH < 1 OR WS-NAME-LENGTH > 256
             ADD 1 TO WS-UNLISTED
         ELSE
             CALL "ZIP-FIND" USING WS-ZIP WS-NAME WS-NAME-LENGTH WS-INDEX
             IF WS-INDEX NOT = WS-I
                 ADD 1 TO WS-MISFOUND
             END-IF
         END-IF
         CALL "ZIP-CRC-CHECK" USING WS-ZIP WS-I WS-STATUS
         IF WS-STATUS NOT = FM-ZIP-OK
             ADD 1 TO WS-BAD-CRC
         END-IF
     END-PERFORM
     MOVE "acceptance US3-user-zip Then every entry lists with a name of 1 to 256 bytes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-UNLISTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US3-user-zip Then every entry resolves by its name to its own number" TO TL-CASE
     MOVE WS-MISFOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US3-user-zip Then every entry (stored and deflated) reads with a matching CRC" TO TL-CASE
     MOVE WS-BAD-CRC TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Independent readings of one stored and one deflated entry (Python zipfile: size and CRC-32).
     MOVE "assets/minecraft/optifine/ctm/red_sandstone/0.png" TO WS-NAME
     MOVE 1292 TO WS-CAPACITY
     PERFORM READ-KNOWN
     MOVE "acceptance US3-user-zip Then a stored entry reads 1292 bytes with CRC 3802017519" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 1292 3802017519" TO TL-EXPECTED
     PERFORM SHOW-KNOWN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "assets/forge/textures/gui/icons.png" TO WS-NAME
     MOVE 18385 TO WS-CAPACITY
     PERFORM READ-KNOWN
     MOVE "acceptance US3-user-zip Then a deflated entry reads 18385 bytes with CRC 3484577885" TO TL-CASE
     MOVE "0 18385 3484577885" TO TL-EXPECTED
     PERFORM SHOW-KNOWN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Lookups do not scan: 5300 present and 5300 absent names.
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     COMPUTE WS-START-CS = WS-HH * 360000 + WS-MM * 6000 + WS-SS * 100 + WS-CC
     MOVE 0 TO WS-PRESENT-FOUND WS-ABSENT-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "ZIP-NAME" USING WS-ZIP WS-I WS-NAME WS-NAME-LENGTH
         CALL "ZIP-FIND" USING WS-ZIP WS-NAME WS-NAME-LENGTH WS-INDEX
         IF WS-INDEX = WS-I
             ADD 1 TO WS-PRESENT-FOUND
         END-IF
         MOVE WS-I TO WS-NUMBER
         MOVE "absent-" TO WS-NAME(WS-NAME-LENGTH + 1:7)
         MOVE WS-NUMBER TO WS-NAME(WS-NAME-LENGTH + 8:5)
         COMPUTE WS-LENGTH = WS-NAME-LENGTH + 12
         IF WS-LENGTH <= 256
             CALL "ZIP-FIND" USING WS-ZIP WS-NAME WS-LENGTH WS-INDEX
             IF WS-INDEX NOT = 0
                 ADD 1 TO WS-ABSENT-FOUND
             END-IF
         END-IF
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     COMPUTE WS-NOW-CS = WS-HH * 360000 + WS-MM * 6000 + WS-SS * 100 + WS-CC
     COMPUTE WS-ELAPSED = WS-NOW-CS - WS-START-CS
     IF WS-ELAPSED < 0
         ADD 8640000 TO WS-ELAPSED
     END-IF
     MOVE "N" TO TL-MODE
     MOVE "acceptance US3-user-zip Then 5300 present names are found and no absent name is" TO TL-CASE
     MOVE 5300 TO TL-EXPECTED-N
     MOVE WS-PRESENT-FOUND TO TL-OBSERVED-N
     ADD WS-ABSENT-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US3-user-zip Then 10600 lookups take under a quarter second (no scan)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ELAPSED < 25
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-ELAPSED TO WS-SHOWN
     DISPLAY "user zip lookups took " FUNCTION TRIM(WS-SHOWN) " centiseconds"
     CALL "ZIP-CLOSE" USING WS-ZIP

*>   The committed fixture's stored and deflated entries.
     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/formats/zip/entries.zip" TO WS-PATH
     MOVE 41 TO WS-PATH-LENGTH
     CALL "ZIP-OPEN" USING WS-PATH WS-PATH-LENGTH WS-ZIP WS-STATUS
     MOVE "stored.txt" TO WS-NAME
     MOVE 10 TO WS-NAME-LENGTH
     PERFORM CHECK-FIXTURE
     MOVE "acceptance US3-user-zip Then the fixture's stored entry has a matching CRC" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "deflated.txt" TO WS-NAME
     MOVE 12 TO WS-NAME-LENGTH
     PERFORM CHECK-FIXTURE
     MOVE "acceptance US3-user-zip Then the fixture's deflated entry has a matching CRC" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE 0 TO RETURN-CODE
     STOP RUN.

 READ-KNOWN.
     MOVE SPACES TO WS-AREA
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "ZIP-FIND" USING WS-ZIP WS-NAME WS-NAME-LENGTH WS-INDEX
     CALL "ZIP-READ-RANGE" USING WS-ZIP WS-INDEX WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     MOVE 0 TO WS-CRC
     IF WS-STATUS = 0
         CALL "CRC32" USING WS-AREA WS-LENGTH WS-CRC
     END-IF.

 SHOW-KNOWN.
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATUS TO WS-SHOWN
     MOVE WS-LENGTH TO WS-SHOWN2
     MOVE WS-CRC TO WS-CRC-D
     STRING FUNCTION TRIM(WS-SHOWN) " " FUNCTION TRIM(WS-SHOWN2) " " FUNCTION TRIM(WS-CRC-D LEADING)
         DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK-FIXTURE.
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     CALL "ZIP-FIND" USING WS-ZIP WS-NAME WS-NAME-LENGTH WS-INDEX
     CALL "ZIP-CRC-CHECK" USING WS-ZIP WS-INDEX WS-STATUS
     MOVE WS-STATUS TO TL-OBSERVED-N.
 END PROGRAM ACC-F2US3-USER-ZIP.
 COPY FMTEST.
