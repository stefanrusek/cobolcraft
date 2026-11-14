*> Implementation test (US1-core; 22 section 9.2): CORE-PACKS-STATUS USING generated directory (z-string,
*> PIC X(1100)), status out (BINARY-LONG, CT-PACKS-*), reason out (PIC X(128), English console wording).
*> It delegates to CONTENT-PACKS-CHECK; over contract/fixtures/content/ each of the five statuses is returned
*> with its reason (spaces for ok).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACKS-STATUS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 01 WS-WANT                PIC X(128).
 PROCEDURE DIVISION.
     MOVE "contract/fixtures/content/valid" TO WS-DIR
     MOVE SPACES TO WS-WANT
     MOVE "packs status ok" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     PERFORM RUN-CASE

     MOVE "contract/fixtures/content/no-such-dir" TO WS-DIR
     MOVE "Minecraft content is not set up. Run the extraction tool with your Minecraft 26.3 client jar to play standard worlds."
         TO WS-WANT
     MOVE "packs status absent" TO TL-CASE
     MOVE CT-PACKS-ABSENT TO TL-EXPECTED-N
     PERFORM RUN-CASE

     MOVE "contract/fixtures/content/incomplete" TO WS-DIR
     MOVE "The Minecraft content is incomplete. Run the extraction tool again." TO WS-WANT
     MOVE "packs status incomplete" TO TL-CASE
     MOVE CT-PACKS-INCOMPLETE TO TL-EXPECTED-N
     PERFORM RUN-CASE

     MOVE "contract/fixtures/content/stale" TO WS-DIR
     MOVE "The Minecraft content was made for another version. Run the extraction tool again." TO WS-WANT
     MOVE "packs status stale" TO TL-CASE
     MOVE CT-PACKS-STALE TO TL-EXPECTED-N
     PERFORM RUN-CASE

     MOVE "contract/fixtures/content/damaged" TO WS-DIR
     MOVE "The Minecraft content is damaged. Run the extraction tool with --force." TO WS-WANT
     MOVE "packs status damaged" TO TL-CASE
     MOVE CT-PACKS-DAMAGED TO TL-EXPECTED-N
     PERFORM RUN-CASE
     STOP RUN.

 RUN-CASE.
     MOVE SPACES TO WS-REASON
     MOVE -1 TO WS-STATUS
     CALL "CORE-PACKS-STATUS" USING WS-DIR WS-STATUS WS-REASON
     MOVE "N" TO TL-MODE
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE WS-WANT TO TL-EXPECTED
     MOVE WS-REASON TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
