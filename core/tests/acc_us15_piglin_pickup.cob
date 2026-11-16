*> Acceptance test, piglins picking up loved items (docs/protocol/21 section 5.5.1, 44 section 3.2 and 3.4, 54 section 4.4; lane 002-lane-mobsb2, T7103): an adult piglin that is
*> not admiring takes one loved item lying within reach (the item entity shrinks), admires it for 119 ticks; a gold ingot then barters, any other loved item is kept (no throw);
*> items that are not loved stay, and a piglin whose admiring is disabled takes nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-PIGLIN-PICKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM-TYPE           BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-INGOT               BINARY-LONG.
 01 WS-APPLE               BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "gold_ingot" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-INGOT
     MOVE "golden_apple" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-APPLE
     MOVE "stick" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-STICK
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PROW
     MOVE "T" TO TL-MODE
*>   A stick lies there: not loved, stays.
     CALL "GI-SPAWN-RANDOM" USING PL-DIM(WS-ROW) WS-X WS-Y WS-Z WS-STICK WS-ONE WS-ZERO WS-ZERO WS-DROP
     CALL "PIGLIN-TICK" USING WS-PROW
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 44§3.2 an item that is not loved is left alone" TO TL-CASE
     MOVE "1 0" TO TL-EXPECTED
     MOVE WS-N TO WS-E1
     MOVE EN-ADMIRE(WS-PROW) TO WS-E2
     PERFORM CHECK-2
*>   A gold ingot with a pick-up delay is not taken yet.
     CALL "GI-SPAWN-RANDOM" USING PL-DIM(WS-ROW) WS-X WS-Y WS-Z WS-INGOT WS-ONE WS-ZERO WS-ONE WS-DROP
     MOVE 40 TO EN-DELAY(WS-DROP)
     CALL "PIGLIN-TICK" USING WS-PROW
     MOVE "acceptance US15 44§3.2 an item with a pick-up delay is not taken" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE EN-ADMIRE(WS-PROW) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
     MOVE 0 TO EN-DELAY(WS-DROP)
     CALL "PIGLIN-TICK" USING WS-PROW
     MOVE "acceptance US15 44§3.2 the ingot is taken: one admiring started, the item gone" TO TL-CASE
     MOVE "1 0" TO TL-EXPECTED
     MOVE 0 TO WS-E1
     IF EN-ADMIRE(WS-PROW) > 100
         MOVE 1 TO WS-E1
     END-IF
     MOVE EN-USED(WS-DROP) TO WS-E2
     PERFORM CHECK-2
*>   The ingot barters after the admiring (a drop is thrown).
     PERFORM COUNT-ITEMS
     MOVE WS-N TO WS-B
     PERFORM 120 TIMES
         CALL "PIGLIN-TICK" USING WS-PROW
     END-PERFORM
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 54§4.4 the picked up ingot barters: one drop is thrown" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE "0" TO TL-OBSERVED
     IF WS-N > WS-B
         MOVE "1" TO TL-OBSERVED
     END-IF
     PERFORM CHECK
*>   A golden apple is admired and kept: no throw.
     CALL "GI-SPAWN-RANDOM" USING PL-DIM(WS-ROW) WS-X WS-Y WS-Z WS-APPLE WS-ONE WS-ZERO WS-ZERO WS-DROP
     CALL "PIGLIN-TICK" USING WS-PROW
     MOVE EN-USED(WS-DROP) TO WS-E1
     MOVE EN-ADMIRE(WS-PROW) TO WS-A
     PERFORM COUNT-ITEMS
     MOVE WS-N TO WS-B
     PERFORM 120 TIMES
         CALL "PIGLIN-TICK" USING WS-PROW
     END-PERFORM
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 44§3.4 a golden apple is taken and kept, nothing is thrown" TO TL-CASE
     MOVE "0 1 1" TO TL-EXPECTED
     MOVE 0 TO WS-C
     IF WS-A > 100
         MOVE 1 TO WS-C
     END-IF
     MOVE 0 TO WS-STATUS
     IF WS-N = WS-B
         MOVE 1 TO WS-STATUS
     END-IF
     MOVE WS-C TO WS-E2
     MOVE WS-STATUS TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK
     STOP RUN.

 COUNT-ITEMS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ITEM-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.

 CHECK-2.
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-PIGLIN-PICKUP.
 COPY CORETEST.
 COPY BETEST.
