*> Acceptance test (wrap agent B, T29574; docs/protocol/30-redstone-4 sections 4.1, 4.2, 4.4 and 4.20): more behaviours of a dispenser. An armor stand appears at the bottom centre of the front cell; a boat
*> goes onto water in front (x = centre + 0.5625 + width / 2 along the facing, 1.0 above the centre of the dispenser) and, on dry land, is dropped as an item; honeycomb waxes a copper block in front
*> (the block becomes its waxed form and one honeycomb is spent) and is dropped in front of stone; an egg leaves through the dispenser path and is spent (event 1002); an egg, a snowball and an
*> experience bottle shot by RL-DISP-BEHAVE leave from 0.7 in front of the centre and 0.1 above it with a speed near 1.1 along the facing (1.375 for the bottle) within the noise of 6 (3 for the bottle).
*> The standard world of the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-DISPENSE-MORE.
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
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-dispense-more-world".
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
 01 WS-BE                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-OBS-N               BINARY-DOUBLE SIGNED.
 01 WS-EXP-N               BINARY-DOUBLE SIGNED.
 01 WS-BARE                PIC X(48).
 01 WS-ENT-KEY             PIC X(48).
 01 WS-ECOUNT              BINARY-LONG.
 01 WS-EROW                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-CONSUMED            BINARY-LONG.
 01 WS-REMAINDER           BINARY-LONG.
 01 WS-VAR                 BINARY-LONG VALUE 0.
 01 WS-FACING              BINARY-LONG VALUE 5.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(48).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb dispense more: no generated packs here, skipped" TO TL-CASE
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
     MOVE "mob" TO WS-K

*>   A. an armor stand dispensed east appears at the bottom centre of the front cell (4.5, 101, z + 0.5) and is spent
     MOVE 0 TO WS-Z
     MOVE "armor_stand" TO WS-K PERFORM FIND-ITEM
     PERFORM SETUP-DISPENSER
     PERFORM LOAD-ONE
     PERFORM POWER-ON
     MOVE "armor_stand" TO WS-ENT-KEY PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.2 an armor stand appears in front of the dispenser" TO WS-CASE
     PERFORM ASSERT-N
     IF WS-EROW > 0
         COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-X(WS-EROW) * 1000 + 0.5)
     ELSE
         MOVE -1 TO WS-OBS-N
     END-IF
     MOVE 4500 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.2 at the centre x of the front cell" TO WS-CASE
     PERFORM ASSERT-N
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-OBS-N MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.2 and the item is spent" TO WS-CASE
     PERFORM ASSERT-N

*>   B. a boat in front of a dispenser with water in the front cell goes to x 3.5 + 0.5625 + 1.375 / 2 = 4.75, y 101.5 + 1.0 (4.4)
     MOVE 3 TO WS-Z
     MOVE "oak_boat" TO WS-K PERFORM FIND-ITEM
     PERFORM SETUP-DISPENSER
     MOVE 4 TO WS-X MOVE "water" TO WS-K PERFORM PUT-DEF
     MOVE "oak_boat" TO WS-K PERFORM FIND-ITEM
     PERFORM LOAD-ONE
     PERFORM POWER-ON
     MOVE "oak_boat" TO WS-ENT-KEY PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.4 a boat is dispensed onto water" TO WS-CASE
     PERFORM ASSERT-N
     IF WS-EROW > 0
         COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-X(WS-EROW) * 1000 + 0.5)
     ELSE
         MOVE -1 TO WS-OBS-N
     END-IF
     MOVE 4750 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.4 at 0.5625 plus half its width in front of the centre" TO WS-CASE
     PERFORM ASSERT-N
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-OBS-N MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.4 and the boat item is spent" TO WS-CASE
     PERFORM ASSERT-N

*>   C. a boat in front of dry land is dropped as an item and no boat appears
     MOVE 6 TO WS-Z
     MOVE "oak_boat" TO WS-K PERFORM FIND-ITEM
     PERFORM SETUP-DISPENSER
     PERFORM LOAD-ONE
     PERFORM POWER-ON
     MOVE "item" TO WS-ENT-KEY PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.4 a boat in front of dry land is dropped as one item" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "oak_boat" TO WS-ENT-KEY PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.4 and no second boat entity appears (still the one of case B)" TO WS-CASE
     PERFORM ASSERT-N

*>   D. honeycomb in front of a copper block waxes it and is spent; the next one in front of stone is dropped
     MOVE 9 TO WS-Z
     MOVE "honeycomb" TO WS-K PERFORM FIND-ITEM
     PERFORM SETUP-DISPENSER
     MOVE 4 TO WS-X MOVE "copper_block" TO WS-K PERFORM PUT-DEF
     MOVE "honeycomb" TO WS-K PERFORM FIND-ITEM
     PERFORM LOAD-ONE
     PERFORM POWER-ON
     MOVE 4 TO WS-X
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     MOVE 0 TO WS-OBS-N
     IF CB-KEY(WS-BLOCK + 1) = "minecraft:waxed_copper_block" OR CB-KEY(WS-BLOCK + 1) = "waxed_copper_block"
         MOVE 1 TO WS-OBS-N
     END-IF
     MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.20 honeycomb waxes the copper block in front" TO WS-CASE
     PERFORM ASSERT-N
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-OBS-N MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.20 and one honeycomb is spent" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 12 TO WS-Z
     MOVE "honeycomb" TO WS-K PERFORM FIND-ITEM
     PERFORM SETUP-DISPENSER
     MOVE 4 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE "honeycomb" TO WS-K PERFORM FIND-ITEM
     PERFORM LOAD-ONE
     PERFORM POWER-ON
     MOVE 4 TO WS-X
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     MOVE 0 TO WS-OBS-N
     IF CB-KEY(WS-BLOCK + 1) = "minecraft:stone" OR CB-KEY(WS-BLOCK + 1) = "stone"
         MOVE 1 TO WS-OBS-N
     END-IF
     MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.20 honeycomb in front of stone leaves the stone" TO WS-CASE
     PERFORM ASSERT-N

*>   E. an egg through the dispenser path is spent
     MOVE 15 TO WS-Z
     MOVE "egg" TO WS-K PERFORM FIND-ITEM
     PERFORM SETUP-DISPENSER
     PERFORM LOAD-ONE
     PERFORM POWER-ON
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-OBS-N MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 an egg is shot and the item is spent" TO WS-CASE
     PERFORM ASSERT-N

*>   F. the thrown items by RL-DISP-BEHAVE at the dispenser (3, 101, 20) facing east: the front cell (4, 101, 20)
     MOVE 4 TO WS-FX MOVE 101 TO WS-FY MOVE 20 TO WS-FZ
     MOVE "snowball" TO WS-K PERFORM FIND-ITEM
     MOVE "snowball" TO WS-ENT-KEY PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     MOVE WS-HANDLED TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 a snowball is handled by a registered behaviour" TO WS-CASE
     PERFORM ASSERT-N
     MOVE WS-CONSUMED TO WS-OBS-N MOVE 3 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 and spent with the launch sound" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "snowball" TO WS-ENT-KEY PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 the snowball entity exists" TO WS-CASE
     PERFORM ASSERT-N
     PERFORM CHECK-FLIGHT-1-1
     MOVE "egg" TO WS-K PERFORM FIND-ITEM
     MOVE "egg" TO WS-ENT-KEY PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     MOVE "egg" TO WS-ENT-KEY PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 the egg entity exists" TO WS-CASE
     PERFORM ASSERT-N
     PERFORM CHECK-FLIGHT-1-1
     MOVE "experience_bottle" TO WS-K PERFORM FIND-ITEM
     MOVE "experience_bottle" TO WS-ENT-KEY PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     MOVE "experience_bottle" TO WS-ENT-KEY PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 the experience bottle entity exists" TO WS-CASE
     PERFORM ASSERT-N
     PERFORM CHECK-FLIGHT-1-375
*>   F2. arrows (4.1): an arrow, a spectral arrow and a tipped arrow leave as arrow entities at power 1.1 with the noise of 6 and are spent with the launch sound
     MOVE "arrow" TO WS-K PERFORM FIND-ITEM
     MOVE "arrow" TO WS-ENT-KEY PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     MOVE WS-CONSUMED TO WS-OBS-N MOVE 3 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 an arrow is spent with the launch sound" TO WS-CASE
     PERFORM ASSERT-N
     PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 the arrow entity exists" TO WS-CASE
     PERFORM ASSERT-N
     PERFORM CHECK-FLIGHT-1-1
     MOVE "tipped_arrow" TO WS-K PERFORM FIND-ITEM
     MOVE "arrow" TO WS-ENT-KEY PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 a tipped arrow is shot as an arrow entity" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "spectral_arrow" TO WS-K PERFORM FIND-ITEM
     MOVE "spectral_arrow" TO WS-ENT-KEY PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     PERFORM FIND-ENTITY
     MOVE WS-ECOUNT TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 a spectral arrow is shot as a spectral arrow entity" TO WS-CASE
     PERFORM ASSERT-N
     PERFORM CHECK-FLIGHT-1-1
*>   G. the boat of 4.4 by RL-DISP-BEHAVE at once (no tick lets it float): water in the front cell (4, 101, 25): y 101.5 + 1.0 = 102.5, x 4.75
     MOVE 25 TO WS-Z
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "water" TO WS-K PERFORM PUT-DEF
     MOVE "oak_boat" TO WS-K PERFORM FIND-ITEM
     MOVE "oak_boat" TO WS-ENT-KEY PERFORM CLEAR-ENTITIES
     MOVE 4 TO WS-FX MOVE 101 TO WS-FY MOVE 25 TO WS-FZ
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     PERFORM FIND-ENTITY
     IF WS-EROW > 0
         COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-Y(WS-EROW) * 1000 + 0.5)
     ELSE
         MOVE -1 TO WS-OBS-N
     END-IF
     MOVE 102500 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.4 a boat leaves 1.0 above the centre height of the dispenser when the front cell holds water" TO WS-CASE
     PERFORM ASSERT-N
*>   H. the yaw of an armor stand is facing.toYRot: north 180, west 90, south 0 (east 270 is case A's); the front cell (4, 101, 28)
     MOVE 4 TO WS-FX MOVE 101 TO WS-FY MOVE 28 TO WS-FZ
     MOVE "armor_stand" TO WS-K PERFORM FIND-ITEM
     MOVE "armor_stand" TO WS-ENT-KEY
     MOVE 2 TO WS-FACING PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     PERFORM FIND-ENTITY
     COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-YAW(WS-EROW) + 0.5)
     MOVE 180 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.2 an armor stand dispensed north looks north (180)" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 4 TO WS-FACING PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     PERFORM FIND-ENTITY
     COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-YAW(WS-EROW) + 0.5)
     MOVE 90 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.2 an armor stand dispensed west looks west (90)" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 3 TO WS-FACING PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     PERFORM FIND-ENTITY
     COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-YAW(WS-EROW) + 0.5)
     MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.2 an armor stand dispensed south looks south (0)" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 5 TO WS-FACING

*>   I. a boat in front of air above water (the front cell (4, 101, 26) is air, the cell below holds water): offset 0, so y 101.5
     MOVE 26 TO WS-Z
     MOVE 4 TO WS-X MOVE 100 TO WS-Y MOVE "water" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE "oak_boat" TO WS-K PERFORM FIND-ITEM
     MOVE "oak_boat" TO WS-ENT-KEY PERFORM CLEAR-ENTITIES
     MOVE 4 TO WS-FX MOVE 101 TO WS-FY MOVE 26 TO WS-FZ
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     PERFORM FIND-ENTITY
     IF WS-EROW > 0
         COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-Y(WS-EROW) * 1000 + 0.5)
     ELSE
         MOVE -1 TO WS-OBS-N
     END-IF
     MOVE 101500 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.4 a boat in front of air above water leaves at the centre height of the dispenser" TO WS-CASE
     PERFORM ASSERT-N
     STOP RUN.

 CHECK-FLIGHT-1-1.
*>   the shot's speed along x is the power 1.1 within the noise of uncertainty 6 (+- 0.103 of the unit direction): 0.98 to 1.22; the other components within +- 0.12
     MOVE 0 TO WS-OBS-N
     IF WS-EROW > 0
         IF EN-VX(WS-EROW) > 0.98 AND EN-VX(WS-EROW) < 1.22 AND EN-VY(WS-EROW) > -0.12 AND EN-VY(WS-EROW) < 0.12
                 AND EN-VZ(WS-EROW) > -0.12 AND EN-VZ(WS-EROW) < 0.12
             MOVE 1 TO WS-OBS-N
         END-IF
     END-IF
     MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 shot along the facing at about 1.1 with the noise of 6" TO WS-CASE
     PERFORM ASSERT-N.

 CHECK-FLIGHT-1-375.
*>   power 1.375, uncertainty 3 (+- 0.052): 1.375 * (1 +- 0.052) is 1.30 to 1.45
     MOVE 0 TO WS-OBS-N
     IF WS-EROW > 0
         IF EN-VX(WS-EROW) > 1.30 AND EN-VX(WS-EROW) < 1.45 AND EN-VY(WS-EROW) > -0.08 AND EN-VY(WS-EROW) < 0.08
                 AND EN-VZ(WS-EROW) > -0.08 AND EN-VZ(WS-EROW) < 0.08
             MOVE 1 TO WS-OBS-N
         END-IF
     END-IF
     MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 the experience bottle at about 1.375 with the noise of 3" TO WS-CASE
     PERFORM ASSERT-N.

 CLEAR-ENTITIES.
*>   removes the entities of the standard type with the bare key WS-ENT-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-DIM(WS-I) = WS-DIM
             CALL "KEY-BARE" USING ET-KEY(EN-TYPE(WS-I) + 1) WS-BARE
             IF WS-BARE = WS-ENT-KEY
                 CALL "ENTITY-REMOVE" USING WS-I
             END-IF
         END-IF
     END-PERFORM.

 FIND-ENTITY.
*>   the entities of the standard type with the bare key WS-ENT-KEY in the dimension: their number in WS-ECOUNT and the last one's row in WS-EROW
     MOVE 0 TO WS-ECOUNT WS-EROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-DIM(WS-I) = WS-DIM
             CALL "KEY-BARE" USING ET-KEY(EN-TYPE(WS-I) + 1) WS-BARE
             IF WS-BARE = WS-ENT-KEY
                 ADD 1 TO WS-ECOUNT
                 MOVE WS-I TO WS-EROW
             END-IF
         END-IF
     END-PERFORM.

 SETUP-DISPENSER.
*>   a dispenser facing east at (3, 101, WS-Z), air in front at x 4 over stone (y 100), nothing at x 2
     MOVE 4 TO WS-X MOVE 100 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE "dispenser" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE.

 LOAD-ONE.
*>   one of the item WS-ITEM in slot 1 of the dispenser WS-BE
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1).

 POWER-ON.
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 101 TO WS-Y.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP-N TO TL-EXPECTED-N
     MOVE WS-OBS-N TO TL-OBSERVED-N
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
*>   the item id of the bare key WS-K (the id of the key it is asked for in WS-ITEM)
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         CALL "KEY-BARE" USING IT-KEY(WS-I) WS-ITEM-KEY
         IF WS-ITEM-KEY = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-DISPENSE-MORE.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
