*> Acceptance test (wrap agent B round 3, T29572; docs/protocol/31-block-entities-2 sections 5.4 to 5.8 and 7.2, 31-1 section 10.2): the containers a hopper moves items into and out of. A crafter takes items
*> slot by slot under the fairness rule (an emptier later slot first, a disabled slot never) and gives its first non-empty slot to a hopper below; a double chest is one container of 54 slots, the RIGHT half first;
*> a hopper with no container above it picks up the item entities of its column as whole stacks (partly when the hopper is nearly full), but not under a full block, a beehive excepted. The standard world of the
*> generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-HOPPER-MORE.
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
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-hopper-more-world".
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
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-NCOUNT              BINARY-LONG.
 01 WS-NROWS               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-SPAWNED             BINARY-LONG.
 01 WS-NUMBER              BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-COUNT               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb hopper more: no generated packs here, skipped" TO TL-CASE
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

*>   crafter cases first
     MOVE "stone" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-STONE
     MOVE "coal" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-COAL
     MOVE "cobblestone" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-COBBLE

*>   A. a hopper over a crafter puts 5 items one by one into 5 different slots (31-2 7.2: a slot with a later empty slot refuses)
     MOVE 0 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "crafter" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     PERFORM MAKE-HOPPER-DOWN-ABOVE
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 1) MOVE 5 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 45 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb hopper 31-2 7.2 a hopper over a crafter fills five slots with one item each" TO WS-CASE
     MOVE "111110000" TO WS-EXP
     PERFORM ASSERT-OBS
*>   B. a disabled slot refuses
     MOVE 2 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "crafter" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 0 TO WS-NUMBER MOVE 0 TO WS-COUNT
     CALL "BE2-CRAFTER-SET-STATE" USING WS-BE2 WS-NUMBER WS-COUNT
     PERFORM MAKE-HOPPER-DOWN-ABOVE
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 1) MOVE 3 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 30 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb hopper 31-2 7.2 a hopper over a crafter skips a disabled slot" TO WS-CASE
     MOVE "011100000" TO WS-EXP
     PERFORM ASSERT-OBS
*>   C. a slot holding 2 refuses a third while an empty enabled slot follows
     MOVE 4 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "crafter" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE2, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE2, 1)
     PERFORM MAKE-HOPPER-DOWN-ABOVE
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb hopper 31-2 7.2 a crafter slot with a later empty slot does not take the item" TO WS-CASE
     MOVE "210000000" TO WS-EXP
     PERFORM ASSERT-OBS
*>   D. a hopper beside a crafter uses the same flat slots
     MOVE 6 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "crafter" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     PERFORM MAKE-HOPPER-EAST
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb hopper 31-2 7.2 a hopper beside a crafter fills slots one and two" TO WS-CASE
     MOVE "110000000" TO WS-EXP
     PERFORM ASSERT-OBS
*>   E. a hopper under a crafter takes from its first non-empty slot (the flat list)
     MOVE 8 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "crafter" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE2, 3) MOVE 4 TO BE-SLOT-COUNT(WS-BE2, 3)
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE2, 7) MOVE 1 TO BE-SLOT-COUNT(WS-BE2, 7)
     MOVE 101 TO WS-Y MOVE "hopper" TO WS-K MOVE "facing" TO WS-PN MOVE "down" TO WS-PV
     PERFORM MAKE-DEF PERFORM SET-P PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 3) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE2, 7) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-C
     IF BE-SLOT-ITEM(WS-BE, 1) NOT = WS-COAL
         MOVE 99 TO WS-C
     END-IF
     MOVE "acceptance wrapb hopper 31-2 5.5 a hopper under a crafter takes one coal (not 99) from the first non-empty slot" TO WS-CASE
     MOVE "3 1 1" TO WS-EXP
     PERFORM ASSERT-ABC

*>   F. a double chest is one container: a hopper over the LEFT half (x 4) puts into the first free slot of the RIGHT half (x 3), whose slot 5 is the only free one
     MOVE 10 TO WS-Z
     PERFORM CLEAR-ROW
     PERFORM MAKE-DOUBLE
     PERFORM FILL-RIGHT-FULL
     MOVE 0 TO BE-SLOT-COUNT(WS-BE2, 5)
     MOVE 4 TO WS-X
     PERFORM MAKE-HOPPER-DOWN-ABOVE
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 5) TO WS-A
     MOVE BE-SLOT-COUNT(WS-NX, 1) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-C
     MOVE "acceptance wrapb hopper 31-1 10.2 a hopper over the left half fills the free slot of the right half first" TO WS-CASE
     MOVE "1 0 0" TO WS-EXP
     PERFORM ASSERT-ABC
*>   G. with the right half full the item goes to the left half
     MOVE 12 TO WS-Z
     PERFORM CLEAR-ROW
     PERFORM MAKE-DOUBLE
     PERFORM FILL-RIGHT-FULL
     MOVE 3 TO WS-X
     PERFORM MAKE-HOPPER-DOWN-ABOVE
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-NX, 1) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B
     MOVE 0 TO WS-C
     MOVE "acceptance wrapb hopper 31-1 10.2 a hopper over a full right half puts into the left half" TO WS-CASE
     MOVE "1 0 0" TO WS-EXP
     PERFORM ASSERT-ABC
*>   H. a hopper under the LEFT half takes from the RIGHT half first (the slots of the compound container)
     MOVE 14 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "chest" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X PERFORM PUT-DEF
     PERFORM MAKE-DOUBLE-AT-102
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-NX
     MOVE 3 TO WS-X
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE2, 27) MOVE 3 TO BE-SLOT-COUNT(WS-BE2, 27)
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-NX, 1) MOVE 2 TO BE-SLOT-COUNT(WS-NX, 1)
     MOVE 4 TO WS-X
     MOVE 101 TO WS-Y MOVE "hopper" TO WS-K MOVE "facing" TO WS-PN MOVE "down" TO WS-PV
     PERFORM MAKE-DEF PERFORM SET-P PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 27) TO WS-A
     MOVE BE-SLOT-COUNT(WS-NX, 1) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-C
     MOVE "acceptance wrapb hopper 31-1 10.2 a hopper under the left half takes coal from the right half first" TO WS-CASE
     MOVE "2 2 1" TO WS-EXP
     PERFORM ASSERT-ABC

*>   I. item entities: a hopper with nothing above it takes a whole stack from its column
     MOVE 16 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM MAKE-HOPPER-DOWN
     PERFORM SPAWN-STONE
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM COUNT-ITEM-ROWS
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-A
     MOVE WS-NROWS TO WS-B
     MOVE 0 TO WS-C
     MOVE "acceptance wrapb hopper 31-2 5.5 a hopper takes the whole stack of an item entity in its column" TO WS-CASE
     MOVE "5 0 0" TO WS-EXP
     PERFORM ASSERT-ABC
*>   J. a nearly full hopper takes part of the stack and the entity keeps the rest
     MOVE 17 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM MAKE-HOPPER-DOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-COBBLE TO BE-SLOT-ITEM(WS-BE, WS-I) MOVE 64 TO BE-SLOT-COUNT(WS-BE, WS-I)
     END-PERFORM
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 5) MOVE 60 TO BE-SLOT-COUNT(WS-BE, 5)
     PERFORM SPAWN-STONE
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM COUNT-ITEM-ROWS
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-A
     MOVE WS-NROWS TO WS-B
     MOVE EN-ITEM-COUNT(WS-SPAWNED) TO WS-C
     MOVE "acceptance wrapb hopper 31-2 5.6 a hopper with room for 4 of 5 takes 4 and leaves the entity with 1" TO WS-CASE
     MOVE "64 1 1" TO WS-EXP
     PERFORM ASSERT-ABC
*>   K. a full block above the hopper blocks the pickup
     MOVE 18 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM MAKE-HOPPER-DOWN
     MOVE 102 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     PERFORM SPAWN-STONE-LOW
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM COUNT-ITEM-ROWS
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-A
     MOVE WS-NROWS TO WS-B
     MOVE 0 TO WS-C
     MOVE "acceptance wrapb hopper 31-2 5.5 a hopper under a full block does not pick up the item entity" TO WS-CASE
     MOVE "0 1 0" TO WS-EXP
     PERFORM ASSERT-ABC
*>   L. a beehive above does not block it (does_not_block_hoppers)
     MOVE 20 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM MAKE-HOPPER-DOWN
     MOVE 102 TO WS-Y MOVE "beehive" TO WS-K PERFORM PUT-DEF
     PERFORM SPAWN-STONE-LOW
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM COUNT-ITEM-ROWS
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-A
     MOVE WS-NROWS TO WS-B
     MOVE 0 TO WS-C
     MOVE "acceptance wrapb hopper 31-2 5.5 a beehive above does not block the pickup" TO WS-CASE
     MOVE "5 0 0" TO WS-EXP
     PERFORM ASSERT-ABC
     STOP RUN.

 MAKE-HOPPER-DOWN.
*>   a hopper facing down at (WS-X, WS-Y, WS-Z), its block entity in WS-BE
     MOVE "hopper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "down" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE.

 MAKE-HOPPER-DOWN-ABOVE.
*>   a hopper facing down at (WS-X, 102, WS-Z), its block entity in WS-BE
     MOVE 102 TO WS-Y
     PERFORM MAKE-HOPPER-DOWN.

 MAKE-DOUBLE.
*>   a double chest at (3, 101, WS-Z) right and (4, 101, WS-Z) left facing south; WS-BE2 the right half's entity, WS-NX the left half's
     MOVE 101 TO WS-Y
     PERFORM MAKE-DOUBLE-AT-102.

 MAKE-DOUBLE-AT-102.
*>   the same at the height in WS-Y: plain chests first (flags 3 give them their block entities), then the double chest states with flags 18
     MOVE 3 TO WS-FLAGS
     MOVE 3 TO WS-X MOVE "chest" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X PERFORM PUT-DEF
     MOVE 18 TO WS-FLAGS
     MOVE 3 TO WS-X MOVE "chest" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "south" TO WS-PV PERFORM SET-P
     MOVE "type" TO WS-PN MOVE "right" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 4 TO WS-X MOVE "chest" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "south" TO WS-PV PERFORM SET-P
     MOVE "type" TO WS-PN MOVE "left" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 3 TO WS-FLAGS
     MOVE 3 TO WS-X
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 4 TO WS-X
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-NX.

 FILL-RIGHT-FULL.
*>   the 27 slots of the right half (WS-BE2) hold 64 cobblestone each
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE WS-COBBLE TO BE-SLOT-ITEM(WS-BE2, WS-I) MOVE 64 TO BE-SLOT-COUNT(WS-BE2, WS-I)
     END-PERFORM.

 SPAWN-STONE.
*>   5 stone as an item entity inside the hopper's column at (3.5, 102.4, WS-Z + 0.5), no pickup delay, at rest
     MOVE 3.5 TO WS-FX MOVE 102.4 TO WS-FY
     PERFORM SPAWN-AT.

 SPAWN-STONE-LOW.
*>   the same inside the cavity of the hopper cell (y 101.7: the box of 0.25 stays under the block of the cell above)
     MOVE 3.5 TO WS-FX MOVE 101.7 TO WS-FY
     PERFORM SPAWN-AT.

 SPAWN-AT.
     COMPUTE WS-FZ = WS-Z + 0.5
     MOVE 5 TO WS-NCOUNT
     MOVE 0 TO WS-DELAY
     CALL "GI-SPAWN" USING WS-DIM WS-FX WS-FY WS-FZ WS-ZERO WS-ZERO2 WS-ZERO3 WS-STONE WS-NCOUNT WS-DELAY WS-SPAWNED.

 COUNT-ITEM-ROWS.
*>   the item entities within the row WS-Z (each case has its own row)
     MOVE 0 TO WS-NROWS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-Z(WS-I) >= WS-Z AND EN-Z(WS-I) < WS-Z + 1
             ADD 1 TO WS-NROWS
         END-IF
     END-PERFORM.

 OBS-CRAFTER.
*>   the counts of the nine slots of the crafter WS-BE2 as nine digits in WS-OBS
     MOVE SPACES TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE BE-SLOT-COUNT(WS-BE2, WS-I) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-OBS(WS-I:1)
     END-PERFORM.

 ASSERT-OBS.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

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

 END PROGRAM ACC-WRAPB-HOPPER-MORE.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
