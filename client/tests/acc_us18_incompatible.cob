*> Acceptance test US18-4 (spec.md User Story 18; 08 §2.3; client/src/screens/pack-select.cob,
*> pack-confirm.cob): enabling a too old, too new or unknown pack asks for confirmation first, and
*> enables it on confirmation.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-INCOMPATIBLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-incompatible".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-NAMES               PIC X(256) VALUE "mystery newer old.zip".
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-ANY                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-E1                  PIC Z9.
 01 WS-E2                  PIC Z9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE "T" TO TL-MODE

*>   old.zip (entry 3): too old.
     MOVE 3 TO WS-ARG
     PERFORM ASK
     MOVE "acceptance US18-4 Given a pack made for an older version When the Pack creator enables "
         & "it Then the game asks for confirmation first" TO TL-CASE
     MOVE "12 Enable This Pack?|old.zip was made for an older version and may look wrong|Enable "
         & "Anyway|Cancel" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE "acceptance US18-4 Given the confirmation When the Pack creator cancels Then the pack "
         & "stays disabled" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     MOVE OP-COUNT TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "11 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3 TO WS-ARG
     PERFORM ASK
     MOVE ACT-PACK-CONFIRM TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US18-4 Given the confirmation When the Pack creator confirms Then the pack "
         & "is enabled" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " OP-ID(1)(1:OP-ID-LENGTH(1)) " " WS-TEXT(1:80)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "11 file/old.zip Resource Packs|Selected|old.zip|Old pack|Made for an older version|B"
         & "uilt-in pack" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   newer (entry 2): too new; Escape leaves the confirmation.
     MOVE 2 TO WS-ARG
     PERFORM ASK
     MOVE "acceptance US18-4 Given a pack made for a newer version When the Pack creator enables "
         & "it Then the game asks for confirmation first" TO TL-CASE
     MOVE "12 Enable This Pack?|newer was made for a newer version and may look wrong|Enable "
         & "Anyway|Cancel" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY

*>   mystery (entry 1): unknown.
     MOVE 1 TO WS-ARG
     PERFORM ASK
     MOVE "acceptance US18-4 Given a pack of unknown version When the Pack creator enables it Then"
         & " the game asks for confirmation first" TO TL-CASE
     MOVE "12 Enable This Pack?|The version of mystery is unknown and it may look wrong|Enable "
         & "Anyway|Cancel" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-PACK-CONFIRM TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE "acceptance US18-4 the confirmed pack goes on top of the enabled ones" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE OP-COUNT TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " OP-ID(1)(1:OP-ID-LENGTH(1)) " "
         OP-ID(2)(1:OP-ID-LENGTH(2)) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 file/mystery file/old.zip" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ASK.
     MOVE ACT-SELECT TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-ENABLE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " WS-TEXT DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM ACC-US18-INCOMPATIBLE.
 COPY CLTEST.
 COPY PACKTEST.
