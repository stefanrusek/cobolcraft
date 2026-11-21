*> Acceptance test, lane bugsw (operator report: item drops do not merge; 41 section 4.4): in a standard world opened from the generated vanilla data pack
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it, keys without namespace) two ground stacks of cobblestone (3 and 4) dropped at the same
*> spot 20 blocks from the player merge into one stack of 7 within 60 ticks, and a stack dropped 3 blocks away stays separate.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-ITEM-MERGE-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-IID                 BINARY-LONG.
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 200.
 01 WS-SPAWNED             BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 60.
 01 WS-I                   BINARY-LONG.
 01 WS-STACKS              BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-BIGGEST             BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance item merge standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Merge" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "cobblestone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-ROW) + 20.5
     COMPUTE WS-Y = PL-Y(WS-ROW) + 2
     MOVE PL-Z(WS-ROW) TO WS-Z
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z / 16)
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-CHUNK
     MOVE 3 TO WS-COUNT
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-VY WS-VZ WS-IID WS-COUNT WS-DELAY WS-SPAWNED
     MOVE 4 TO WS-COUNT
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-VY WS-VZ WS-IID WS-COUNT WS-DELAY WS-SPAWNED
     COMPUTE WS-X = WS-X - 3
     MOVE 5 TO WS-COUNT
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-VY WS-VZ WS-IID WS-COUNT WS-DELAY WS-SPAWNED
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 0 TO WS-STACKS WS-TOTAL WS-BIGGEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-STACKS
             ADD EN-ITEM-COUNT(WS-I) TO WS-TOTAL
             IF EN-ITEM-COUNT(WS-I) > WS-BIGGEST
                 MOVE EN-ITEM-COUNT(WS-I) TO WS-BIGGEST
             END-IF
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance item merge standard: three dropped stacks (3, 4 at one spot, 5 three blocks away) are two stacks after 60 ticks" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-STACKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance item merge standard: nothing is lost, 12 items in all" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance item merge standard: the biggest stack is the 7 of the merge" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-BIGGEST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-ITEM-MERGE-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
