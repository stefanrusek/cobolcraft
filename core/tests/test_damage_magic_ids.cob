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
 COPY PROTO.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-DIR                 PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
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
*>   The death messages of a standard world (message ids magic, indirectMagic, sonic_boom, mob): the caster's name is the second argument of the three with a causing entity.
     MOVE "Evoker" TO PL-KILLER-NAME(WS-ROW)
     MOVE 6 TO PL-KILLER-LENGTH(WS-ROW)
     MOVE 0 TO PL-KILLER-ITEM-LENGTH(WS-ROW)
     MOVE 0 TO PL-CREDIT-LENGTH(WS-ROW)
     MOVE "T" TO TL-MODE
     MOVE CAUSE-MAGIC TO WS-CAUSE
     CALL "DEATH-TEXT-STD" USING WS-ROW WS-CAUSE PB-TEXT
     MOVE "test damage magic ids: an owner-less bite kills with death.attack.magic" TO TL-CASE
     MOVE "death.attack.magic" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-INDIRECT-MAGIC TO WS-CAUSE
     CALL "DEATH-TEXT-STD" USING WS-ROW WS-CAUSE PB-TEXT
     MOVE "test damage magic ids: an owned bite kills with death.attack.indirectMagic" TO TL-CASE
     MOVE "death.attack.indirectMagic" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test damage magic ids: with the caster as the second argument" TO TL-CASE
     MOVE "Stefan|Evoker" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING PB-TX-ARG-VALUE(1)(1:PB-TX-ARG-LENGTH(1)) "|" PB-TX-ARG-VALUE(2)(1:PB-TX-ARG-LENGTH(2)) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-SONIC-BOOM TO WS-CAUSE
     CALL "DEATH-TEXT-STD" USING WS-ROW WS-CAUSE PB-TEXT
     MOVE "test damage magic ids: the sonic boom kills with death.attack.sonic_boom" TO TL-CASE
     MOVE "death.attack.sonic_boom" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-WIND-CHARGE TO WS-CAUSE
     CALL "DEATH-TEXT-STD" USING WS-ROW WS-CAUSE PB-TEXT
     MOVE "test damage magic ids: a wind charge kills with the message id mob" TO TL-CASE
     MOVE "death.attack.mob" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-WIND-CHARGE TO WS-CAUSE
     CALL "DAMAGE-TYPE-ID" USING WS-CAUSE WS-ID
     MOVE "N" TO TL-MODE
     MOVE "test damage magic ids: the registry without wind_charge gives generic (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-SONIC-BOOM WS-ID
     MOVE "test damage magic ids: nor sonic_boom (0)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DAMAGE-MAGIC-IDS.
 COPY CORETEST.
