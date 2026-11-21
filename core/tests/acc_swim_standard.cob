*> Acceptance test, lane mining (operator report: dug down into water and could neither place nor break blocks while in it; 13 section 2.1
*> and 2.4, 29a, 29 section 9): a standard world from the generated data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped
*> as a pass without it). Alice stands in a pool (water at her feet and eyes) beside a stone wall. A block put against the wall face is
*> placed over the water cell (water is replaceable); a block of the wall is broken with a wooden pickaxe: the client's finish packet
*> comes after the time the client computes (CONTROLS-BREAK-TIME) and the server must accept it, whether or not the ground flag is set.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SWIM-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-IID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-PICK                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
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
         MOVE "acceptance swim standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "Swim" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STONE
     MOVE "water" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-WATER
     MOVE "cobblestone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE "wooden_pickaxe" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PICK WS-IROW WS-STATUS
*>   A pool 5 x 5 x 4 (x 18 to 22, y 99 to 102, z 18 to 22) on a stone floor (y 98), a stone wall at x 23.
     PERFORM VARYING WS-X FROM 17 BY 1 UNTIL WS-X > 24
         PERFORM VARYING WS-Z FROM 17 BY 1 UNTIL WS-Z > 23
             MOVE 98 TO WS-Y
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
             PERFORM VARYING WS-Y FROM 99 BY 1 UNTIL WS-Y > 103
                 IF WS-X >= 18 AND WS-X <= 22 AND WS-Z >= 18 AND WS-Z <= 22 AND WS-Y <= 102
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
                 ELSE
                     IF WS-X = 23
                         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
                     ELSE
                         MOVE 0 TO WS-STATE
                         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 20.5 TO PL-X(WS-ROW)
     MOVE 99 TO PL-Y(WS-ROW)
     MOVE 20.5 TO PL-Z(WS-ROW)
     MOVE 0 TO PL-ON-GROUND(WS-ROW)
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-IID TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE 0 TO PL-HELD(WS-ROW)

     MOVE "acceptance swim place: cobblestone put against the wall face from inside the pool (feet and eyes in water, not on the "
         & "ground) replaces the water cell" TO TL-CASE
     MOVE 23 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 21 TO WS-Z
     MOVE 4 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 22 TO WS-GX
     MOVE 100 TO WS-GY
     MOVE 21 TO WS-GZ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-GX WS-GY WS-GZ WS-STATE
     MOVE "cobblestone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-E1
     MOVE WS-BID TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-E2 TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-E2) TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance swim place: the same with the ground flag set, one cell higher (eyes in water)" TO TL-CASE
     MOVE 1 TO PL-ON-GROUND(WS-ROW)
     MOVE 22 TO WS-GX
     MOVE 101 TO WS-GY
     MOVE 21 TO WS-GZ
     MOVE 22 TO WS-X
     MOVE 101 TO WS-Y
     MOVE 21 TO WS-Z
     MOVE 23 TO WS-X
     MOVE 101 TO WS-Y
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-GX WS-GY WS-GZ WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE WS-BID TO WS-E2
     MOVE FUNCTION TRIM(WS-E2) TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance swim break: a stone of the wall broken with a wooden pickaxe from inside the pool on the ground: eyes in water "
         & "(speed x 0.2) 113 ticks, the finish is accepted and the block goes" TO TL-CASE
     MOVE WS-PICK TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 2)
     MOVE 1 TO PL-HELD(WS-ROW)
     MOVE 1 TO PL-ON-GROUND(WS-ROW)
     MOVE 23 TO WS-X
     MOVE 99 TO WS-Y
     MOVE 21 TO WS-Z
     PERFORM BREAK-IT
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance swim break: airborne (the ground flag false, eyes in the air) the speed is a fifth: 113 ticks, the finish "
         & "at that time is accepted too" TO TL-CASE
     MOVE 0 TO PL-ON-GROUND(WS-ROW)
     MOVE 103 TO PL-Y(WS-ROW)
     MOVE 103 TO WS-Y
     MOVE 113 TO WS-TICKS
     PERFORM BREAK-RUN
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BREAK-IT.
     MOVE 113 TO WS-TICKS
     PERFORM BREAK-RUN.

 BREAK-RUN.
     MOVE 0 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-E1.
 END PROGRAM ACC-SWIM-STANDARD.

 COPY CORETEST.
