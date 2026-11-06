*> Acceptance test, US5-1 core half and the ground-item half of US4-3 (spec US5 scenario 1, US4
*> scenario 3; tasks T463; standin-content §1.3, §9.1, §9.2; data-model §5): a block broken in
*> survival leaves one loose_item of the block's item at (x + 0.5, y + 0.25, z + 0.5); it falls and
*> comes to rest on the block below, and every player in the same dimension within view distance is
*> sent it (Add Entity, Set Entity Data, then Teleport Entity while it falls), a player outside the
*> view distance nothing. View distance 2; Alice (entity 1, survival, pry_bar in slot 8) breaks
*> greystone at (20, 100, 20) above a greystone block at (20, 98, 20); Bob (entity 2) is at the
*> spawn point, Carol (entity 3) at (100.5, 100, 100.5). The item is entity 4.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US5-BREAK-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-CAROL               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG VALUE 8.
 01 WS-TICKS               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 100.5.
 01 WS-FY                  FLOAT-LONG VALUE 100.0.
 01 WS-FZ                  FLOAT-LONG VALUE 100.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-ENTITY              BINARY-LONG VALUE 4.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-R1                  PIC -(6)9.99.
 01 WS-R2                  PIC -(6)9.99.
 01 WS-R3                  PIC -(6)9.99.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE "Carol" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CAROL
     CALL "TEST-MOVE" USING WS-CAROL WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 98 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 100 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     PERFORM DRAIN-ALL

     MOVE "acceptance US5-1 given survival when a block is broken then a viewer within view "
         & "distance is sent the end of the break overlay, the block change and a loose_item (type 1) holding one greystone at "
         & "(x + 0.5, y + 0.25, z + 0.5)" TO TL-CASE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 7 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE "5 8 49 1(4,1@20.50,100.25,20.50) 101(4=2x1)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-1 given survival when a block is broken then the breaking player sees "
         & "the same ground item between the Block Changed Acks of the start and the stop"
         TO TL-CASE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "4 8 49 1(4,1@20.50,100.25,20.50) 101(4=2x1) 4" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-1 given a player outside the view distance when the block is broken "
         & "then it is sent nothing of the ground item" TO TL-CASE
     CALL "TEST-DRAIN-ENTITIES" USING WS-CAROL WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-1 given a new ground item when ticks pass then it falls (Teleport "
         & "Entity to the viewers each tick it moves: 9 ticks from y 100.25) and rests on the "
         & "block below at y 99" TO TL-CASE
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
     MOVE EN-X(WS-ROW) TO WS-R1
     MOVE EN-Y(WS-ROW) TO WS-R2
     MOVE EN-Z(WS-ROW) TO WS-R3
     MOVE EN-ON-GROUND(WS-ROW) TO WS-E1
     MOVE EN-ITEM-COUNT(WS-ROW) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " at " FUNCTION TRIM(WS-R1) "," FUNCTION TRIM(WS-R2) ","
         FUNCTION TRIM(WS-R3) " resting " FUNCTION TRIM(WS-E1) " count " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE "128(4)x9 at 20.50,99.00,20.50 resting 1 count 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-1 given a resting ground item when more ticks pass then nothing more "
         & "is sent" TO TL-CASE
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 DRAIN-ALL.
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     CALL "TEST-DRAIN-ENTITIES" USING WS-CAROL WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US5-BREAK-DROP.

 COPY CORETEST.
