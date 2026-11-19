*> Implementation test (lane p49r; docs/protocol/20 section 13.3.1, 17 section 4.13.4): the damage types of an evoker fang's bite. A standard set whose damage_type registry holds generic (0),
*> indirect_magic (1), magic (2) and mob_attack (3) gives CAUSE-MAGIC the position of `magic` and CAUSE-INDIRECT-MAGIC that of `indirect_magic`; the set of the other fixture (no such entry)
*> and the cobolcraft set give them the id 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DAMAGE-MAGIC-IDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY RULES.
 01 WS-DIR                 PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "N" TO TL-MODE
     CALL "DAMAGE-TYPE-ID" USING CAUSE-MAGIC WS-ID
     MOVE "test damage magic ids: the cobolcraft set has no such types, id 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     MOVE SPACES TO WS-DIR
     MOVE "core/tests/fixtures/magic-content" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "DAMAGE-TYPE-ID" USING CAUSE-MAGIC WS-ID
     MOVE "test damage magic ids: a standard set finds magic by key (position 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-INDIRECT-MAGIC WS-ID
     MOVE "test damage magic ids: and indirect_magic (position 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-MOB WS-ID
     MOVE "test damage magic ids: mob_attack moved to position 3 in this registry" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     MOVE SPACES TO WS-DIR
     MOVE "core/tests/fixtures/stdmob-content" TO WS-DIR
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "DAMAGE-TYPE-ID" USING CAUSE-INDIRECT-MAGIC WS-ID
     MOVE "test damage magic ids: a registry without the entry gives generic (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DAMAGE-MAGIC-IDS.
 COPY CORETEST.
