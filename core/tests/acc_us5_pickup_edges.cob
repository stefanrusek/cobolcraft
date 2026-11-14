*> Acceptance test of the US5 pickup edge cases (spec US5 edge cases, SC-011; tasks T469;
*> standin-content §9.3; data-model §5 exactly-once rule): two players reaching a ground item in the
*> same tick, exactly one gets it (the one who entered the world first); a player with room for
*> part of the stack takes what fits and the rest stays (Set Entity Data with the reduced count); a
*> full inventory leaves the item on the ground. View distance 2, survival. Carol joins first
*> (player row 1) and leaves; then Bob joins and gets player row 1, so Alice (row 2, entity 2)
*> entered the world before Bob (row 1, entity 3) although Bob's row comes first.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US5-PICKUP-EDGES.
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
 01 WS-X                   BINARY-LONG VALUE 22.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-ROT                 BINARY-LONG VALUE 32.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG VALUE 101.0.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-FLOOR-X             BINARY-LONG.
 01 WS-FLOOR-Z             BINARY-LONG VALUE 20.
 01 WS-FLOOR-Y             BINARY-LONG VALUE 100.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Carol" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CAROL
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "CORE-CONN-CLOSED" USING WS-CAROL
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE 100 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
*>   Greystone under the players: a break by a player in the air is five times slower (13 section 2.1).
     PERFORM VARYING WS-FLOOR-X FROM 20 BY 1 UNTIL WS-FLOOR-X > 26
         PERFORM VARYING WS-FLOOR-Z FROM 19 BY 1 UNTIL WS-FLOOR-Z > 21
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FLOOR-X WS-FLOOR-Y WS-FLOOR-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 21 TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 22 TO WS-X
     MOVE 22.0 TO WS-FX
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 23.0 TO WS-FX
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 8 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT

     MOVE "acceptance US5 edge given two players within pickup range of the same ground item in "
         & "the same tick when its pickup delay ends then exactly one gets it: Alice, who "
         & "entered the world first (Bob, player row 1, gets nothing)" TO TL-CASE
     MOVE 101 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 7 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE 11 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     CALL "TEST-DROP-MOVES" USING WS-TEXT
     MOVE 10 TO WS-S
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     PERFORM ADD-SLOT
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     PERFORM ADD-SLOT
     MOVE "127(4,2,1) 78(4) row 2 slot 10 2x1 row 1 slot 10 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5 edge given an inventory with room for 10 of a 64 stack when it is within pickup range "
         & "then it takes 10, the rest stays, no Take Item Entity is sent (41 §4.2) and Set Entity Data says 54" TO TL-CASE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         MOVE 3 TO PL-SLOT-ITEM(WS-ROW, WS-S)
         MOVE 64 TO PL-SLOT-COUNT(WS-ROW, WS-S)
     END-PERFORM
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 54 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 90 TO WS-PITCH
     CALL "TEST-MOVE" USING WS-ALICE WS-ROT WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 4 TO WS-ACTION
     MOVE 0 TO WS-X WS-Y WS-Z WS-FACE
     PERFORM ACT
     MOVE 40.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 22.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
*>   A thrown item has pickup delay 40: it can be touched from the 41st tick.
     MOVE 45 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     CALL "TEST-DROP-MOVES" USING WS-TEXT
     MOVE 0 TO WS-S
     PERFORM ADD-SLOT
     MOVE 5 TO WS-ENTITY
     PERFORM ADD-ITEM
     MOVE "20(36=2x64) 101(5=2x54) row 1 slot 0 2x64 item 5 2x54"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5 edge given a player whose inventory is full when it stays within "
         & "pickup range then the ground item stays and nothing is sent (SC-011)" TO TL-CASE
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     PERFORM ADD-SLOT
     PERFORM ADD-ITEM
     MOVE "row 1 slot 0 2x64 item 5 2x54" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

*> Appends " row <WS-ROW> slot <WS-S> <item>x<count>" to WS-TEXT.
 ADD-SLOT.
     MOVE WS-ROW TO WS-E1
     MOVE WS-S TO WS-E2
     MOVE PL-SLOT-ITEM(WS-ROW, WS-S + 1) TO WS-E3
     MOVE PL-SLOT-COUNT(WS-ROW, WS-S + 1) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " row " FUNCTION TRIM(WS-E1) " slot " FUNCTION TRIM(WS-E2)
         " " FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO WS-TEXT.

*> Appends " item <WS-ENTITY> <item>x<count>" of that ground item to WS-TEXT.
 ADD-ITEM.
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ITEM-ROW
     MOVE WS-ENTITY TO WS-E1
     MOVE EN-ITEM(WS-ITEM-ROW) TO WS-E3
     MOVE EN-ITEM-COUNT(WS-ITEM-ROW) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " item " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E3) "x"
         FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US5-PICKUP-EDGES.

 COPY CORETEST.
