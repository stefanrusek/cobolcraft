*> Implementation test (coverage lane A; docs/protocol/44 part 8 sections 2 and 4.6): a broken chest, hopper, furnace, TNT and command block cart drops its own item and a cart
*> pushed at carts in the same place (no direction) changes nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-MINECART44B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG VALUE 0.05.
 01 WS-DZ                  FLOAT-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-SLOT2               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 5.
 01 WS-NONE-ROW            BINARY-LONG VALUE 0.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-TYPE           BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 150 TO WS-Y
     MOVE 0 TO WS-Z
     PERFORM VARYING WS-KIND FROM 2 BY 1 UNTIL WS-KIND > 7
         COMPUTE WS-X = WS-KIND * 10
         CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
         MOVE 0 TO WS-BEFORE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ITEM-TYPE
                 ADD 1 TO WS-BEFORE
             END-IF
         END-PERFORM
         CALL "MINECART-HURT" USING WS-ROW WS-AMOUNT WS-NONE-ROW WS-HANDLED
         MOVE 0 TO WS-AFTER
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ITEM-TYPE
                 ADD 1 TO WS-AFTER
             END-IF
         END-PERFORM
         MOVE WS-KIND TO WS-DIGIT
         MOVE SPACES TO WS-CASE
         STRING "test cova minecart44b a broken cart of kind " WS-DIGIT " drops one item" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-E
         COMPUTE WS-O = WS-AFTER - WS-BEFORE
         CALL "CA-N" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   Two carts in the same place: pushOtherMinecart has no direction and leaves both speeds.
     MOVE 1 TO WS-KIND
     MOVE 5 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW2 WS-SLOT2
     MOVE 0.3 TO EN-VX(WS-ROW)
     MOVE 0.1 TO EN-VX(WS-ROW2)
     CALL "MINECART-PUSH-OTHER" USING WS-ROW WS-ROW2 WS-DX WS-DZ
     MOVE "test cova minecart44b carts in the same place keep their speeds (mm)" TO WS-CASE
     MOVE 400 TO WS-E
     COMPUTE WS-O ROUNDED = (EN-VX(WS-ROW) + EN-VX(WS-ROW2)) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-MINECART44B.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
