*> Test of 31 section 1 (Scope and reading guide; docs/protocol/31-block-entities-1-shared-model-and-containers.md; T0841):
*> the scope facts the module fixes: the container block event id is 1 (EVENT_SET_OPEN_COUNT) and the registry has 49 types.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-1-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TYPE10              BINARY-LONG VALUE 10.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "acceptance US12 31-1§1 Scope and reading guide: container block event id 1, 49 block entity types" TO TL-CASE
     CALL "BE-SCOPE" USING WS-A WS-B
     MOVE WS-A TO WS-EDIT
     MOVE WS-B TO WS-EDIT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1 49" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-31-1-1.

 COPY CORETEST.
