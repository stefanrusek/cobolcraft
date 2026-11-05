*> Acceptance test, the US4 edge case of placing into a mob (spec US4 edge "where it would overlap any
*> player or mob"; tasks T543; standin-content §1.3, §3, §12.1; data-model §3): a block is not
*> placed at a position whose cell overlaps a mob's collision box with positive volume; the player gets Block Update of the real state and Block Changed Ack, and
*> in survival the held item is not used up. Alice is a first-time survival player holding the
*> starting greystone (slot 0, 64) at the spawn point; the ground of columns x = 6, z = 8 to 12 has
*> its top at 53 (§5.2). A sodgrazer (0.9 wide) stands at (6.5, 54, 8.5), an abend (0.75 wide) at
*> (6.5, 54, 12.5). No tick runs, so the mobs stay where they are.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US9-PLACE-OVERLAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY ENTITYTYPES.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-FX                  FLOAT-LONG VALUE 6.5.
 01 WS-FY                  FLOAT-LONG VALUE 54.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-P                   BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE ET-SODGRAZER TO WS-TYPE
     MOVE 8.5 TO WS-FZ
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-MOB
     MOVE ET-ABEND TO WS-TYPE
     MOVE 12.5 TO WS-FZ
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-MOB
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT

     MOVE "US4 edge given a sodgrazer standing at (6.5, 54, 8.5) when Alice places greystone at "
         & "(6, 54, 8) then nothing is placed, she gets the real block (void) and the ack, and her "
         & "stack is not used up" TO TL-CASE
     MOVE 6 TO WS-X
     MOVE 8 TO WS-Z
     PERFORM PLACE-ON-TOP
     MOVE "8(6,54,8=0) 4(1) | state 0 slot 0 2x64" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US4 edge given an abend standing at (6.5, 54, 12.5) when Alice places greystone at "
         & "(6, 54, 12) then nothing is placed and her stack is not used up" TO TL-CASE
     MOVE 12 TO WS-Z
     PERFORM PLACE-ON-TOP
     MOVE "8(6,54,12=0) 4(2) | state 0 slot 0 2x64" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US4 edge given the cell (6, 54, 9) next to the sodgrazer's box (z 8.05 to 8.95) when "
         & "Alice places greystone there then it is placed and one item is used up" TO TL-CASE
     MOVE 6 TO WS-X
     MOVE 9 TO WS-Z
     PERFORM PLACE-ON-TOP
     MOVE 0 TO WS-P
     INSPECT WS-TEXT TALLYING WS-P FOR CHARACTERS BEFORE INITIAL "|"
     MOVE WS-TEXT(WS-P + 1:) TO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE "| state 2 slot 0 2x63" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Use Item On the top face of (WS-X, 53, WS-Z) with the next sequence, which targets (WS-X, 54,
*> WS-Z); WS-TEXT gets the drained packets, then " | state <s> slot 0 <item>x<count>".
 PLACE-ON-TOP.
     ADD 1 TO WS-SEQ
     MOVE 53 TO WS-Y
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE 54 TO WS-Y
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-E1
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO WS-E2
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-E3
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " | state " FUNCTION TRIM(WS-E1) " slot 0 "
         FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US9-PLACE-OVERLAP.

 COPY CORETEST.
