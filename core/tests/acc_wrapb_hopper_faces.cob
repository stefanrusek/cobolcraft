*> Acceptance test (wrap agent B, T29572; docs/protocol/31-block-entities-2 sections 3.1 and 5.4 to 5.6): the slot rules by face of the furnace under the hopper's item transfer. A hopper over a
*> furnace puts into the input slot (face UP), a hopper beside it puts into the fuel slot (a fuel or an empty bucket only), a hopper under it takes the result and the spent buckets of the fuel
*> slot, never real fuel. The standard world of the generated packs (a pass without them); the brewing stand has its own test (acc_wrapb_hopper_brew, the stand-in recipes).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-HOPPER-FACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-hopper-faces-world".
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
 01 WS-ST2                 BINARY-LONG.
 01 WS-PN                  PIC X(16).
 01 WS-PV                  PIC X(16).
 01 WS-OLD                 PIC X(16).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXP                 PIC X(160).
 01 WS-NX                  BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OBS                 PIC X(160).
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-D                   PIC -(9)9.
 01 WS-STONE               BINARY-LONG.
 01 WS-COAL                BINARY-LONG.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-IRON                BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb hopper faces: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 20
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
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
     MOVE "stone" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-STONE
     MOVE "coal" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-COAL
     MOVE "bucket" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-BUCKET
     MOVE "iron_ingot" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-IRON

*>   A. a hopper facing down over a furnace puts into the input slot (31-2 3.1 UP gives [0])
     MOVE 0 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "furnace" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 102 TO WS-Y MOVE "hopper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "down" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE2, 2) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE2, 3) TO WS-C
     MOVE "acceptance wrapb hopper 31-2 3.1 a hopper over a furnace puts one item into the input slot only" TO WS-CASE
     MOVE "1 0 0" TO WS-EXP
     PERFORM ASSERT-ABC
*>   B. a hopper beside a furnace puts a fuel into the fuel slot (face side gives [1])
     MOVE 2 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "furnace" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     PERFORM MAKE-HOPPER-EAST
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE2, 2) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE2, 3) TO WS-C
     MOVE "acceptance wrapb hopper 31-2 3.1 a hopper beside a furnace puts coal into the fuel slot" TO WS-CASE
     MOVE "0 1 0" TO WS-EXP
     PERFORM ASSERT-ABC
*>   C. the same hopper holding stone: the fuel slot refuses it, so the item stays in the hopper
     MOVE 4 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "furnace" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     PERFORM MAKE-HOPPER-EAST
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE2, 2) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-C
     MOVE "acceptance wrapb hopper 31-2 3.1 a hopper beside a furnace cannot put stone into the fuel slot" TO WS-CASE
     MOVE "0 0 2" TO WS-EXP
     PERFORM ASSERT-ABC
*>   D. a hopper under a furnace takes the result, and never the fuel (31-2 3.1 DOWN gives [2, 1])
     MOVE 6 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "furnace" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE2, 2) MOVE 5 TO BE-SLOT-COUNT(WS-BE2, 2)
     MOVE WS-IRON TO BE-SLOT-ITEM(WS-BE2, 3) MOVE 2 TO BE-SLOT-COUNT(WS-BE2, 3)
     MOVE 101 TO WS-Y MOVE "hopper" TO WS-K MOVE "facing" TO WS-PN MOVE "down" TO WS-PV
     PERFORM MAKE-DEF PERFORM SET-P PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 30 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 3) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE2, 2) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-C
     MOVE "acceptance wrapb hopper 31-2 3.1 a hopper under a furnace takes the result and leaves the fuel" TO WS-CASE
     MOVE "0 5 2" TO WS-EXP
     PERFORM ASSERT-ABC
*>   E. a hopper under a furnace takes a spent bucket of the fuel slot (furnace_fuel_bottom_takeable)
     MOVE 8 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "furnace" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-BUCKET TO BE-SLOT-ITEM(WS-BE2, 2) MOVE 1 TO BE-SLOT-COUNT(WS-BE2, 2)
     MOVE 101 TO WS-Y MOVE "hopper" TO WS-K MOVE "facing" TO WS-PN MOVE "down" TO WS-PV
     PERFORM MAKE-DEF PERFORM SET-P PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 2) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B
     MOVE "acceptance wrapb hopper 31-2 3.1 a hopper under a furnace takes the bucket of the fuel slot" TO WS-CASE
     MOVE "0 1 0" TO WS-EXP
     MOVE 0 TO WS-C
     PERFORM ASSERT-ABC
*>   F. a dropper under a furnace, facing up, puts through the DOWN face [result, fuel] (30-4 1.4 addItem with facing.getOpposite()): the result slot never, coal into the fuel slot
     MOVE 10 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "furnace" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 101 TO WS-Y MOVE "dropper" TO WS-K MOVE "facing" TO WS-PN MOVE "up" TO WS-PV
     PERFORM MAKE-DEF PERFORM SET-P PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 2) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE2, 3) TO WS-C
     MOVE "acceptance wrapb hopper 30-4 1.4 a dropper facing up puts coal into the fuel slot of the furnace above, not into the result slot" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-ABC
*>   G. a dropper above a furnace, facing down, puts through the UP face [input]
     MOVE 12 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "furnace" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 102 TO WS-Y MOVE "dropper" TO WS-K MOVE "facing" TO WS-PN MOVE "down" TO WS-PV
     PERFORM MAKE-DEF PERFORM SET-P PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE2, 2) TO WS-C
     MOVE "acceptance wrapb hopper 30-4 1.4 a dropper facing down puts stone into the input slot of the furnace below" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-ABC
*>   H. a hopper beside a furnace whose fuel slot holds a bucket does not put a second bucket there (31-2 3.1 slot 1 rule)
     MOVE 14 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "furnace" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-BUCKET TO BE-SLOT-ITEM(WS-BE2, 2) MOVE 1 TO BE-SLOT-COUNT(WS-BE2, 2)
     PERFORM MAKE-HOPPER-EAST
     MOVE WS-BUCKET TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 2) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-C
     MOVE "acceptance wrapb hopper 31-2 3.1 a hopper beside a furnace does not put a bucket into a fuel slot that holds one" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-ABC
     STOP RUN.

 CLEAR-ROW.
*>   air on x 0 to 8 at heights 101 to 104 of row WS-Z
     PERFORM VARYING WS-NX FROM 0 BY 1 UNTIL WS-NX > 8
         MOVE WS-NX TO WS-X
         PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
             MOVE "air" TO WS-K
             PERFORM PUT-DEF
         END-PERFORM
     END-PERFORM.

 MAKE-HOPPER-EAST.
*>   a hopper facing east at (3, 101, WS-Z), its block entity in WS-BE
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "hopper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE.

 ASSERT-ABC.
*>   WS-A, WS-B and WS-C as "a b c" against WS-EXP
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBS
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 MAKE-DEF.
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 SET-P.
     CALL "SW-SET-PROP" USING WS-ST WS-PN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-HOPPER-FACES.

 COPY CORETEST.
 COPY PORTALTEST.
