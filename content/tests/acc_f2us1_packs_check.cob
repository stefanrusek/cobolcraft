*> Acceptance test (US1-content; FR-001, FR-002, SC-012; 22 §8.2): CONTENT-PACKS-CHECK USING generated
*> directory (z-string, PIC X(1100)), status out (CT-PACKS-*), reason text out (PIC X(128), the English
*> wording of 22 §9.2, empty for ok). Over contract/fixtures/content/ and a scratch copy.
*> Given the fixture trees, When the check runs, Then valid is ok, a missing directory absent, a missing
*> manifest with the marker incomplete, a tampered digest stale, a missing sentinel damaged and a manifest
*> with its keys out of order damaged. The check reads no jar and hashes nothing: it passes with no
*> resources of any kind besides the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US1-PACKS-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR
     MOVE "contract/fixtures/content/valid" TO WS-DIR
     PERFORM RUN-CHECK
     MOVE "acceptance US1-valid tree: Given a valid tree When checked Then ok, no reason" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US1-valid tree reason is empty" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-REASON TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-DIR
     MOVE "contract/fixtures/content/valid/" TO WS-DIR
     PERFORM RUN-CHECK
     MOVE "acceptance US1-valid tree with a trailing slash: ok" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

     MOVE SPACES TO WS-DIR
     MOVE "contract/fixtures/content/no-such-dir" TO WS-DIR
     PERFORM RUN-CHECK
     MOVE "acceptance US1-missing directory: absent" TO TL-CASE
     MOVE CT-PACKS-ABSENT TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US1-absent reason" TO TL-CASE
     MOVE "Minecraft content is not set up. Run the extraction tool with your Minecraft 26.3 client jar to play standard worlds."
         TO TL-EXPECTED
     MOVE WS-REASON TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-DIR
     MOVE "contract/fixtures/content/valid/manifest.txt" TO WS-DIR
     PERFORM RUN-CHECK
     MOVE "acceptance US1-a file instead of a directory: absent" TO TL-CASE
     MOVE CT-PACKS-ABSENT TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

     MOVE SPACES TO WS-DIR
     MOVE "contract/fixtures/content/incomplete" TO WS-DIR
     PERFORM RUN-CHECK
     MOVE "acceptance US1-no manifest, marker present: incomplete" TO TL-CASE
     MOVE CT-PACKS-INCOMPLETE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US1-incomplete reason" TO TL-CASE
     MOVE "The Minecraft content is incomplete. Run the extraction tool again." TO TL-EXPECTED
     MOVE WS-REASON TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-DIR
     MOVE "contract/fixtures/content/stale" TO WS-DIR
     PERFORM RUN-CHECK
     MOVE "acceptance US1-tampered digest: stale" TO TL-CASE
     MOVE CT-PACKS-STALE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US1-stale reason" TO TL-CASE
     MOVE "The Minecraft content was made for another version. Run the extraction tool again." TO TL-EXPECTED
     MOVE WS-REASON TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-DIR
     MOVE "contract/fixtures/content/damaged" TO WS-DIR
     PERFORM RUN-CHECK
     MOVE "acceptance US1-missing sentinel: damaged" TO TL-CASE
     MOVE CT-PACKS-DAMAGED TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US1-damaged reason" TO TL-CASE
     MOVE "The Minecraft content is damaged. Run the extraction tool with --force." TO TL-EXPECTED
     MOVE WS-REASON TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-DIR
     MOVE "contract/fixtures/content/damaged-manifest" TO WS-DIR
     PERFORM RUN-CHECK
     MOVE "acceptance US1-manifest keys out of order: damaged" TO TL-CASE
     MOVE CT-PACKS-DAMAGED TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   A trailing-space path of the NUL-terminated kind works too.
     MOVE LOW-VALUES TO WS-DIR
     MOVE "contract/fixtures/content/valid" TO WS-DIR(1:31)
     PERFORM RUN-CHECK
     MOVE "acceptance US1-NUL terminated path: ok" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     STOP RUN.

 RUN-CHECK.
     MOVE SPACES TO WS-REASON
     MOVE -1 TO WS-STATUS
     CALL "CONTENT-PACKS-CHECK" USING WS-DIR WS-STATUS WS-REASON.

 ASSERT-STATUS.
     MOVE "N" TO TL-MODE
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
