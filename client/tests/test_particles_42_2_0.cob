*> Acceptance test of docs/protocol/42-particles-2-effects-fire-smoke-magic.md section 0 (resolved rules
*> that apply to both world types): the shared standard rule, and the nine types specified by more than
*> one document with the document that also specifies them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-2-0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-TYPE                PIC X(24).
 01 WS-FLAG                BINARY-LONG.
 01 WS-OTHER               PIC X(24).
 01 WS-WANT                PIC X(24).
 01 WS-WORLD               BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 PROCEDURE DIVISION.
*>   The rule is the same in both world types: the particle's behaviour does not depend on the world type.
     MOVE 0 TO WS-WORLD
     CALL "P2-WORLD-RULE" USING WS-WORLD WS-SAME
     MOVE "world type 0 (standard): the particle rules apply unchanged" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-WORLD
     CALL "P2-WORLD-RULE" USING WS-WORLD WS-SAME
     MOVE "world type 1 (the other world type): the same rules apply" TO WS-NAME
     MOVE WS-SAME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   The nine multiply specified types and the other documents.
     MOVE "lava" TO WS-TYPE
     MOVE 1 TO TL-EXPECTED-N
     MOVE "42-3" TO WS-WANT
     PERFORM CHK-OWNER
     MOVE "campfire_cosy_smoke" TO WS-TYPE
     MOVE "42-4" TO WS-WANT
     PERFORM CHK-OWNER
     MOVE "campfire_signal_smoke" TO WS-TYPE
     PERFORM CHK-OWNER
     MOVE "elder_guardian" TO WS-TYPE
     MOVE "42-5" TO WS-WANT
     PERFORM CHK-OWNER
     MOVE "dolphin" TO WS-TYPE
     MOVE "42-3" TO WS-WANT
     PERFORM CHK-OWNER
     MOVE "nautilus" TO WS-TYPE
     PERFORM CHK-OWNER
     MOVE "glow" TO WS-TYPE
     PERFORM CHK-OWNER
     MOVE "pause_mob_growth" TO WS-TYPE
     MOVE "42-5" TO WS-WANT
     PERFORM CHK-OWNER
     MOVE "reset_mob_growth" TO WS-TYPE
     PERFORM CHK-OWNER
     MOVE "egg_crack" TO WS-TYPE
     MOVE "42-4" TO WS-WANT
     PERFORM CHK-OWNER
*>   Types owned by this part only.
     MOVE "heart" TO WS-TYPE
     CALL "P2-MULTI-OWNER" USING WS-TYPE WS-FLAG WS-OTHER
     MOVE "heart is specified here only" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "flame" TO WS-TYPE
     CALL "P2-MULTI-OWNER" USING WS-TYPE WS-FLAG WS-OTHER
     MOVE "flame is specified here only" TO WS-NAME
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "P2-MULTI-COUNT" USING WS-FLAG
     MOVE "nine types are specified by more than one document" TO WS-NAME
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 CHK-OWNER.
     CALL "P2-MULTI-OWNER" USING WS-TYPE WS-FLAG WS-OTHER
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-TYPE) " is also specified in another document"
         DELIMITED BY SIZE INTO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-TYPE) " other document is " FUNCTION TRIM(WS-WANT)
         DELIMITED BY SIZE INTO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-2§0 Resolved: rules that apply to both world types: "
         FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE FUNCTION TRIM(WS-WANT) TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OTHER) TO TL-OBSERVED
     PERFORM CHK-TEXT
     MOVE "N" TO TL-MODE.

 CHK-TEXT.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-2§0 Resolved: rules that apply to both world types: "
         FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-2-0.
