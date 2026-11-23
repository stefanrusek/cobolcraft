*> Acceptance test (wrap agent B round 6, T29574; docs/protocol/30-redstone-4 sections 3.1 rule 2 and 4.12): a dispenser feeds an item of the tag sulfur_cube_swallowable to a sulfur cube in its front cell: the
*> first cube whose box meets the cell and that is not a baby and does not already hold that item takes it into its BODY slot and the dispenser spends it; the item the cube held before is dropped as an item
*> entity; a baby cube, a cube outside the cell, a cube that holds the same item and an item that is not swallowable leave the item to the default drop. The swallowable items are found by the tag lookup
*> (SULFUR-ARCH-MASK) over the item table, never named here. The standard world of the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-DISPENSE-SULFUR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY P49NSTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-dispense-sulfur-world".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-A              BINARY-LONG.
 01 WS-ITEM-B              BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(48).
 01 WS-PX                  FLOAT-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-CONSUMED            BINARY-LONG.
 01 WS-REMAINDER           BINARY-LONG.
 01 WS-VAR                 BINARY-LONG VALUE 0.
 01 WS-FACING              BINARY-LONG VALUE 5.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG VALUE 101.
 01 WS-FZ                  BINARY-LONG.
 01 WS-CUBE-KEY            PIC X(112) VALUE "minecraft:sulfur_cube".
 01 WS-CUBE-TYPE           BINARY-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CROW                BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-BODY-A-ED           PIC -(9)9.
 01 WS-BODY-B-ED           PIC -(9)9.
 01 WS-SUM                 BINARY-LONG.
 01 WS-A-ED                PIC -(9)9.
 01 WS-B-ED                PIC -(9)9.
 01 WS-C-ED                PIC -(9)9.
 01 WS-D-ED                PIC -(9)9.
 01 WS-CASE                PIC X(240).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb dispense sulfur: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 30
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 12
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 106.0 TO PL-Y(WS-ROW)
     MOVE 28.5 TO PL-Z(WS-ROW)
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     CALL "THROWN-TYPE" USING WS-CUBE-KEY WS-CUBE-TYPE
*>   the first two swallowable items of the table (by the tag lookup) and a stick that is not
     MOVE 0 TO WS-ITEM-A WS-ITEM-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         COMPUTE WS-ITEM = WS-I - 1
         CALL "SULFUR-ARCH-MASK" USING WS-ITEM WS-MASK
         IF WS-MASK > 0
             IF WS-ITEM-A = 0
                 MOVE WS-ITEM TO WS-ITEM-A
             ELSE
                 IF WS-ITEM-B = 0
                     MOVE WS-ITEM TO WS-ITEM-B
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-J = WS-ITEM-A + 1
     MOVE WS-J TO WS-BODY-A-ED
     COMPUTE WS-J = WS-ITEM-B + 1
     MOVE WS-J TO WS-BODY-B-ED
     MOVE "stick" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-STICK
     CALL "SULFUR-ARCH-MASK" USING WS-STICK WS-MASK
     MOVE "acceptance wrapb dispense 30-4 4.12 precondition: two different swallowable items in the table" TO WS-CASE
     MOVE WS-MASK TO WS-A-ED
     IF WS-ITEM-A > 0 AND WS-ITEM-B > 0 AND WS-ITEM-A NOT = WS-ITEM-B
         MOVE "1" TO TL-OBSERVED
     ELSE
         MOVE "0" TO TL-OBSERVED
     END-IF
     MOVE "1" TO TL-EXPECTED
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance wrapb dispense 30-4 4.12 precondition: a stick is not swallowable (mask 0)" TO TL-CASE
     MOVE FUNCTION TRIM(WS-A-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A. a cube (size 2) in the front cell (4, 101, 5) takes the first swallowable item: handled, consumed 1, BODY = the item, nothing dropped
     MOVE 4 TO WS-FX MOVE 5 TO WS-FZ MOVE 2 TO WS-SIZE
     MOVE 4.5 TO WS-CX MOVE 5.5 TO WS-CZ
     PERFORM SPAWN-CUBE
     MOVE WS-ITEM-A TO WS-ITEM
     PERFORM DISPENSE
     PERFORM OBSERVE
     MOVE "acceptance wrapb dispense 30-4 4.12 a sulfur cube in the front cell takes a swallowable item: handled, spent, BODY set, none dropped" TO WS-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "1 1 " FUNCTION TRIM(WS-BODY-A-ED) " 0" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

*>   B. the same item again: the cube holds it already, so the item takes the default drop
     MOVE WS-ITEM-A TO WS-ITEM
     PERFORM DISPENSE
     PERFORM OBSERVE
     MOVE "acceptance wrapb dispense 30-4 4.12 a cube that holds the same item refuses it: not handled, BODY kept" TO WS-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "0 0 " FUNCTION TRIM(WS-BODY-A-ED) " 0" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

*>   C. another swallowable item replaces it and the old one is dropped at the cube
     MOVE WS-ITEM-B TO WS-ITEM
     PERFORM DISPENSE
     PERFORM OBSERVE
     MOVE "acceptance wrapb dispense 30-4 4.12 another item replaces the BODY item and the old one is dropped as an item entity" TO WS-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "1 1 " FUNCTION TRIM(WS-BODY-B-ED) " 0" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK
     MOVE WS-ITEM-A TO WS-ITEM
     PERFORM SUM-DROPS
     MOVE WS-SUM TO TL-OBSERVED-N MOVE 1 TO TL-EXPECTED-N MOVE "N" TO TL-MODE
     MOVE "acceptance wrapb dispense 30-4 4.12 and exactly one item of the previous BODY lies at the cube" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   D. a baby cube (size 1) at the front cell (4, 101, 8) does not take it
     MOVE 8 TO WS-FZ MOVE 1 TO WS-SIZE
     MOVE 8.5 TO WS-CZ
     PERFORM SPAWN-CUBE
     MOVE WS-ITEM-A TO WS-ITEM
     PERFORM DISPENSE
     PERFORM OBSERVE
     MOVE "acceptance wrapb dispense 30-4 4.12 a baby cube refuses: not handled, BODY empty" TO WS-CASE
     MOVE "0 0 0 0" TO TL-EXPECTED
     PERFORM CHECK

*>   E. a cube 3 blocks east of the front cell (4, 101, 11) is not in its box
     MOVE 11 TO WS-FZ MOVE 2 TO WS-SIZE
     MOVE 7.5 TO WS-CX MOVE 11.5 TO WS-CZ
     PERFORM SPAWN-CUBE
     MOVE WS-ITEM-A TO WS-ITEM
     PERFORM DISPENSE
     PERFORM OBSERVE
     MOVE "acceptance wrapb dispense 30-4 4.12 a cube outside the front cell refuses: not handled, BODY empty" TO WS-CASE
     MOVE "0 0 0 0" TO TL-EXPECTED
     PERFORM CHECK

*>   F. a stick (not swallowable) in front of a cube at (4, 101, 14) is not given to it
     MOVE 14 TO WS-FZ MOVE 2 TO WS-SIZE
     MOVE 4.5 TO WS-CX MOVE 14.5 TO WS-CZ
     PERFORM SPAWN-CUBE
     MOVE WS-STICK TO WS-ITEM
     PERFORM DISPENSE
     PERFORM OBSERVE
     MOVE "acceptance wrapb dispense 30-4 4.12 an item that is not swallowable is not given to the cube: not handled, BODY empty" TO WS-CASE
     MOVE "0 0 0 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 SPAWN-CUBE.
*>   a sulfur cube of size WS-SIZE at the feet (WS-CX, 101, WS-CZ); its row in WS-CROW
     MOVE 101.0 TO WS-CY
     MOVE 0 TO WS-CROW
     CALL "MOB-SPAWN" USING WS-DIM WS-CUBE-TYPE WS-CX WS-CY WS-CZ WS-YAW WS-CROW
     MOVE WS-SIZE TO EN-VARIANT(WS-CROW).

 DISPENSE.
*>   RL-DISP-BEHAVE at the front cell (WS-FX, 101, WS-FZ) facing east with the item WS-ITEM
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER.

 OBSERVE.
*>   TL-OBSERVED = "<handled> <consumed> <BODY of the cube WS-CROW as item id + 1> <items of WS-ITEM dropped in the row WS-FZ>"
     CALL "PN-ROW-OPEN" USING WS-CROW
     MOVE WS-HANDLED TO WS-A-ED
     MOVE WS-CONSUMED TO WS-B-ED
     MOVE PN-BODY(WS-CROW) TO WS-C-ED
     PERFORM SUM-DROPS
     MOVE WS-SUM TO WS-D-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-C-ED) " " FUNCTION TRIM(WS-D-ED)
         DELIMITED BY SIZE INTO TL-OBSERVED.

 SUM-DROPS.
*>   the item entities of item WS-ITEM within the row WS-FZ: the count in WS-SUM
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-ITEM
                 AND EN-Z(WS-I) >= WS-FZ AND EN-Z(WS-I) < WS-FZ + 1
             ADD EN-ITEM-COUNT(WS-I) TO WS-SUM
         END-IF
     END-PERFORM.

 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 MAKE-DEF.
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
*>   the item id of the bare key WS-K in WS-ITEM
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         CALL "KEY-BARE" USING IT-KEY(WS-I) WS-ITEM-KEY
         IF WS-ITEM-KEY = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-DISPENSE-SULFUR.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
