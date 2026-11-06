*> Implementation test of the ground-item processing order (core/src/ground-items.cob
*> GROUND-ITEMS-TICK; tasks T477; standin-content §9.2 "in ascending network entity id order", §9.3):
*> tracker rows are reused, so a newer item can sit in an earlier row; items are still processed by
*> entity id. Alice (creative) at the spawn point has room for exactly one stack (slot 35 empty).
*> Item A is spawned and removed, item B (greystone x64) is spawned at her feet, then item C
*> (dump_shard x64) takes A's free, earlier row; both lie within her pickup range with no pickup
*> delay. B, the lower entity id, is taken; C stays.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM-ORDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 64.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ROW-C               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-PLAYER
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 35
         MOVE 3 TO PL-SLOT-ITEM(WS-PLAYER, WS-S)
         MOVE 64 TO PL-SLOT-COUNT(WS-PLAYER, WS-S)
     END-PERFORM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z

     MOVE "test ground item order a newer item in an earlier tracker row is processed after an "
         & "older one: the lower entity id is picked up first" TO TL-CASE
     MOVE 2 TO WS-ITEM
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY
         WS-ROW-A
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY
         WS-ROW-B
     CALL "ENTITY-REMOVE" USING WS-ROW-A
     MOVE 15 TO WS-ITEM
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY
         WS-ROW-C
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE PL-SLOT-ITEM(WS-PLAYER, 36) TO WS-E1
     MOVE EN-ITEM-COUNT(WS-ROW-C) TO WS-E2
     COMPUTE WS-E3 = WS-ROW-C - WS-ROW-B
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " slot 35 item " FUNCTION TRIM(WS-E1) " C left "
         FUNCTION TRIM(WS-E2) " row C - row B " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "127(3,1,64) 20(35=2x64) 78(3) slot 35 item 2 C left 64 row C - row B -1"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-GROUND-ITEM-ORDER.

 COPY CORETEST.
