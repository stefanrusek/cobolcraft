*> Acceptance test of Where items come from at death and break (T0352; docs/protocol/41-item-entity-physics.md section 6; FR-037): a
*> block break rolls its yield through Block.popResource, a mob drop through Entity.spawnAtLocation, and a dying player's inventory
*> through Inventory.dropAll with the stack patch kept; every one is an item entity of this document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEMPHYS-41-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMPHYS.
 COPY CITEMS.
 COPY RULES.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-C                   PIC X(16).
 01 WS-D                   PIC X(16).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BLOCK               BINARY-LONG VALUE 2.
 01 WS-X                   BINARY-LONG VALUE 30.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 30.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 100.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG VALUE 100.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.5.
 01 WS-ITEM                BINARY-LONG VALUE 3.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-VAR                 BINARY-LONG VALUE 6.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-PLAYER

*>   A block break (the yield of the block through popResource): one item, delay 10, inside the block's cell.
     CALL "GI-BLOCK-YIELD" USING WS-DIM WS-X WS-Y WS-Z WS-BLOCK
     PERFORM FIND-LAST
     MOVE "acceptance US2 41§6 Where items come from at death and break a broken block yields one item of its yield at pos + 0.5 "
         & "within 0.25, y within 0.125 to 0.625 of the block floor, with pickup delay 10 and motion y 0.2" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE "ok" TO WS-A
     IF EN-X(WS-ROW) < 30.25 OR EN-X(WS-ROW) > 30.75 OR EN-Z(WS-ROW) < 30.25 OR EN-Z(WS-ROW) > 30.75
             OR EN-Y(WS-ROW) < 70.125 OR EN-Y(WS-ROW) > 70.625
         MOVE "out" TO WS-A
     END-IF
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-B
     CALL "ITT-I" USING EN-ITEM-COUNT(WS-ROW) WS-C
     CALL "ITT-F" USING EN-VY(WS-ROW) WS-D
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "ok 10 1 0.20000" TO WS-EXPECTED
     PERFORM CHECK
     MOVE RULE-YIELD-ITEM(WS-BLOCK + 1) TO WS-I
     MOVE "acceptance US2 41§6 Where items come from at death and break the yielded item is the block's yield item" TO WS-CASE
     CALL "ITT-I" USING EN-ITEM(WS-ROW) WS-OBSERVED
     CALL "ITT-I" USING WS-I WS-EXPECTED

*>   A mob drop: spawnAtLocation with the entity's position and a y offset, delay 10, random motion.
     CALL "IP-AT-LOCATION" USING WS-DIM WS-FX WS-FY WS-FZ WS-OFFSET WS-ITEM WS-COUNT WS-NONE WS-ROW
     MOVE "acceptance US2 41§6 Where items come from at death and break a mob drop is placed at the entity position plus the offset "
         & "with delay 10" TO WS-CASE
     CALL "ITT-F" USING EN-Y(WS-ROW) WS-A
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "100.50000 10" TO WS-EXPECTED
     PERFORM CHECK

*>   The inventory of a dying player: every non-empty slot becomes an item entity (delay 40, no thrower, the patch kept) and the slots
*>   are emptied.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-ITEM(WS-PLAYER, WS-I) PL-SLOT-COUNT(WS-PLAYER, WS-I) PL-SLOT-VAR(WS-PLAYER, WS-I)
     END-PERFORM
     MOVE 3 TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 4 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 6 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 2 TO PL-SLOT-ITEM(WS-PLAYER, 10)
     MOVE 7 TO PL-SLOT-COUNT(WS-PLAYER, 10)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE CAUSE-ABEND TO WS-CAUSE
     PERFORM COUNT-ITEMS
     MOVE WS-I TO WS-N
     CALL "HEALTH-DAMAGE" USING WS-PLAYER WS-AMOUNT WS-CAUSE WS-NONE WS-NONE2
     PERFORM COUNT-ITEMS
     COMPUTE WS-N = WS-I - WS-N
     CALL "ITT-I" USING WS-N WS-A
     PERFORM FIND-LAST
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-B
     CALL "ITT-I" USING IP-I-THROWER(WS-ROW) WS-C
     MOVE "acceptance US2 41§6 Where items come from at death and break a dying player drops one entity per non-empty slot, with "
         & "delay 40 and no thrower, and the slots are emptied" TO WS-CASE
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 10) WS-D
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "2 40 0 0" TO WS-EXPECTED
     PERFORM CHECK
*>   The entity of slot 0 (the first dropped) keeps the patch handle.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM AND EN-ITEM(WS-ROW) = 3 AND EN-ITEM-COUNT(WS-ROW) = 4
                 AND EN-DELAY(WS-ROW) = 40
             MOVE IP-I-VAR(WS-ROW) TO WS-I
         END-IF
     END-PERFORM
     MOVE "acceptance US2 41§6 Where items come from at death and break the death drop keeps the stack's patch handle" TO WS-CASE
     CALL "ITT-I" USING WS-I WS-OBSERVED
     MOVE "6" TO WS-EXPECTED
     PERFORM CHECK
     STOP RUN.

 FIND-LAST.
     MOVE EN-COUNT TO WS-ROW
     PERFORM UNTIL EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM
         SUBTRACT 1 FROM WS-ROW
     END-PERFORM.

 COUNT-ITEMS.
     MOVE 0 TO WS-I
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM
             ADD 1 TO WS-I
         END-IF
     END-PERFORM.

 CHECK.
     CALL "ITT-CHECK" USING WS-CASE WS-EXPECTED WS-OBSERVED.
 END PROGRAM TEST-ITEMPHYS-41-6.

 COPY CORETEST.
 COPY ITEMTEST.
