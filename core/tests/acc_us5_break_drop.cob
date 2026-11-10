*> Acceptance test, US5-1 core half and the ground-item half of US4-3 (spec US5 scenario 1, US4
*> scenario 3; tasks T463; standin-content §1.3, docs/protocol/41 section 2.1; data-model §5): a block broken in
*> survival leaves one loose_item of the block's item (popResource: x and z within 0.25 of the block centre, y from
*> 0.125 to 0.625 above the block's y, pickup delay 10, the random motion of 41 section 1, so Add Entity is followed by
*> Set Entity Motion); it falls and comes to rest on the floor below, and every player in the same dimension within view
*> distance is sent it (Add Entity, Set Entity Data, Set Entity Motion, then Teleport Entity while it moves), a player
*> outside the view distance nothing. View distance 2; Alice (entity 1, survival, pry_bar in slot 8) breaks greystone at
*> (20, 100, 20) above a floor of greystone at y = 98 (x and z 18 to 22); Bob (entity 2) is at the spawn point, Carol
*> (entity 3) at (100.5, 100, 100.5). The item is entity 4. The random position is read from the entity.
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
 01 WS-ADD                 PIC X(80).
 01 WS-OK-X                PIC X(3).
 01 WS-OK-Y                PIC X(3).
 01 WS-OK-Z                PIC X(3).
 01 WS-FLOOR-X             BINARY-LONG.
 01 WS-FLOOR-Z             BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
*>   No mob spawns during the test: night (standin §4.8) with hostile mobs off.
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE "Carol" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CAROL
     CALL "TEST-MOVE" USING WS-CAROL WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 98 TO WS-Y
     PERFORM VARYING WS-FLOOR-X FROM 18 BY 1 UNTIL WS-FLOOR-X > 22
         PERFORM VARYING WS-FLOOR-Z FROM 18 BY 1 UNTIL WS-FLOOR-Z > 22
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FLOOR-X WS-Y WS-FLOOR-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 100 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     PERFORM DRAIN-ALL

     MOVE "acceptance US5-1 given survival when a block is broken then a viewer within view "
         & "distance is sent the break end, the block change and a loose_item of one greystone at its "
         & "random position, with its motion" TO TL-CASE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 7 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
     PERFORM DESCRIBE-ADD
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "5 8 49 " FUNCTION TRIM(WS-ADD) " 101(4=2x1) 103(4)" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-1 given survival when a block at (20, 100, 20) is broken then the item "
         & "is within 0.25 of the block centre in x and z, 0.125 to 0.625 above the block in y and "
         & "has pickup delay 10 (41 section 2.1)" TO TL-CASE
     MOVE "no" TO WS-OK-X WS-OK-Y WS-OK-Z
     IF EN-X(WS-ROW) >= 20.25 AND EN-X(WS-ROW) <= 20.75
         MOVE "yes" TO WS-OK-X
     END-IF
     IF EN-Y(WS-ROW) >= 100.125 AND EN-Y(WS-ROW) <= 100.625
         MOVE "yes" TO WS-OK-Y
     END-IF
     IF EN-Z(WS-ROW) >= 20.25 AND EN-Z(WS-ROW) <= 20.75
         MOVE "yes" TO WS-OK-Z
     END-IF
     MOVE EN-DELAY(WS-ROW) TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "x " FUNCTION TRIM(WS-OK-X) " y " FUNCTION TRIM(WS-OK-Y) " z " FUNCTION TRIM(WS-OK-Z)
         " delay " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "x yes y yes z yes delay 10" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-1 given survival when a block is broken then the breaking player sees "
         & "the same ground item between the Block Changed Acks of the start and the stop"
         TO TL-CASE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "5 4 5x8 8 49 " FUNCTION TRIM(WS-ADD) " 101(4=2x1) 103(4) 4" DELIMITED BY SIZE
         INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-1 given a player outside the view distance when the block is broken "
         & "then it is sent nothing of the ground item" TO TL-CASE
     CALL "TEST-DRAIN-ENTITIES" USING WS-CAROL WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-1 given a new ground item when ticks pass then it falls (Teleport "
         & "Entity to the viewers each tick it moves) and rests on the "
         & "floor below at y 99" TO TL-CASE
     MOVE 60 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
     MOVE EN-X(WS-ROW) TO WS-R1
     MOVE EN-Y(WS-ROW) TO WS-R2
     MOVE EN-Z(WS-ROW) TO WS-R3
     MOVE EN-ON-GROUND(WS-ROW) TO WS-E1
     MOVE EN-ITEM-COUNT(WS-ROW) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING WS-TEXT(1:6) " at y " FUNCTION TRIM(WS-R2)
         " resting " FUNCTION TRIM(WS-E1) " count " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE "128(4) at y 99.00 resting 1 count 1" TO TL-EXPECTED
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

*> WS-ADD: the Add Entity text "1(4,1@x,y,z)" of the item of tracker row WS-ROW, as TEST-DRAIN-ENTITIES prints it.
 DESCRIBE-ADD.
     COMPUTE WS-R1 ROUNDED = EN-X(WS-ROW)
     COMPUTE WS-R2 ROUNDED = EN-Y(WS-ROW)
     COMPUTE WS-R3 ROUNDED = EN-Z(WS-ROW)
     MOVE SPACES TO WS-ADD
     STRING "1(4,1@" FUNCTION TRIM(WS-R1) "," FUNCTION TRIM(WS-R2) "," FUNCTION TRIM(WS-R3) ")"
         DELIMITED BY SIZE INTO WS-ADD.

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
