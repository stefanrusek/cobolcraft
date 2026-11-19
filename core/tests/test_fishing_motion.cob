*> Test of the motion of the fishing hook (docs/protocol/57-client-closures-2 section 1; 17 section 3.11; 44 part 8 section 10.1): the flight in air is the worked example of
*> 1.4 (gravity 0.03 first, then the move, then the drag 0.92 on all three components: offsets after ticks 1, 2, 3, 5 and 10), a flying hook that finds water
*> gets (0.3, 0.2, 0.3) on its velocity and ends the tick there (1.1 table), a bobbing hook keeps no gravity in water and takes the drag 0.92 after the move, and
*> falls with gravity and counts outOfWaterTime up to 10 once its block holds no water (1.3, 1.3a), the bite dip sets a vertical velocity in (-0.4, -0.24]
*> when the fish bites (1.5), a hook on the ground for 1200 ticks and one 33 blocks from its owner are discarded (1.6), the open-water rule of 17 section 3.11
*> (four 5 x 5 layers at -1 to +2: water below, air or lily pads above, nothing else) and the flag of 1.3a (lowered only during a bite, true again between bites)
*> and the treasure table that only an open-water hook may roll.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FISHING-MOTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PLAYPKT.
 COPY PROJSTATE.
 COPY CITEMS.
 COPY COREAPI.
 COPY PROTO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROD-ITEM            BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-LILY                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PJ                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-WK                  BINARY-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-PITCH               FLOAT-LONG VALUE 0.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-MODE                BINARY-LONG.
 01 WS-TREASURE            BINARY-LONG.
 01 WS-NAME-TAG            BINARY-LONG.
 01 WS-SADDLE              BINARY-LONG.
 01 WS-NAUTILUS            BINARY-LONG.
 01 WS-DY-TABLE.
    05 FILLER              BINARY-LONG VALUE -300.
    05 FILLER              BINARY-LONG VALUE -876.
    05 FILLER              BINARY-LONG VALUE -1706.
    05 FILLER              BINARY-LONG VALUE -4048.
    05 FILLER              BINARY-LONG VALUE -13108.
 01 WS-DYS REDEFINES WS-DY-TABLE.
    05 WS-DY-EXPECT        BINARY-LONG OCCURS 5 TIMES.
 01 WS-DZ-TABLE.
    05 FILLER              BINARY-LONG VALUE 11000.
    05 FILLER              BINARY-LONG VALUE 21120.
    05 FILLER              BINARY-LONG VALUE 30430.
    05 FILLER              BINARY-LONG VALUE 46876.
    05 FILLER              BINARY-LONG VALUE 77772.
 01 WS-DZS REDEFINES WS-DZ-TABLE.
    05 WS-DZ-EXPECT        BINARY-LONG OCCURS 5 TIMES.
 01 WS-TICK-TABLE.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 10.
 01 WS-TICKS REDEFINES WS-TICK-TABLE.
    05 WS-TICK-AT          BINARY-LONG OCCURS 5 TIMES.
 01 WS-NEXT                BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 48
     COMPUTE WS-FZ = WS-Z0 - 48
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-KIND
     MOVE "minecraft:fishing_rod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ROD-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:lily_pad" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LILY
     MOVE "minecraft:name_tag" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-NAME-TAG WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:saddle" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SADDLE WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:nautilus_shell" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-NAUTILUS WS-ITEM-ROW WS-STATUS
     COMPUTE WS-SLOT = PL-HELD(WS-PLAYER) + 1
     MOVE WS-ROD-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-SLOT)
     COMPUTE WS-WX = WS-X0 + 4
     MOVE WS-Y0 TO WS-WY
     COMPUTE WS-WZ = WS-Z0 + 6

*>   Flight in air: the worked example of 57-2 1.4 (yaw 0, pitch 0: velocity (0, 0, 1.1)).
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     MOVE EN-X(WS-ROW) TO WS-SX
     MOVE EN-Y(WS-ROW) TO WS-SY
     MOVE EN-Z(WS-ROW) TO WS-SZ
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         PERFORM UNTIL WS-N >= WS-TICK-AT(WS-I)
             CALL "BOBBER-STEP" USING WS-ROW
             ADD 1 TO WS-N
         END-PERFORM
         MOVE WS-TICK-AT(WS-I) TO WS-EDIT
         MOVE SPACES TO TL-CASE
         STRING "fishing motion 57-2 1.4 flying hook after tick " FUNCTION TRIM(WS-EDIT) " is "
             "0 sideways" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N ROUNDED = (EN-X(WS-ROW) - WS-SX) * 10000
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "fishing motion 57-2 1.4 flying hook after tick " FUNCTION TRIM(WS-EDIT) " has fallen by the table (1/10000 block)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-DY-EXPECT(WS-I) TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N ROUNDED = (EN-Y(WS-ROW) - WS-SY) * 10000
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "fishing motion 57-2 1.4 flying hook after tick " FUNCTION TRIM(WS-EDIT) " has flown by the table (1/10000 block)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-DZ-EXPECT(WS-I) TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N ROUNDED = (EN-Z(WS-ROW) - WS-SZ) * 10000
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "fishing motion 57-2 1.4 the vertical velocity after tick 10 is -0.195136 after the drag 0.92 (1/1000000)" TO TL-CASE
     MOVE -195136 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.4 the horizontal velocity after tick 10 is 0.477827 (1/1000000)" TO TL-CASE
     MOVE 477827 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VZ(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW

*>   Water entry: velocity x (0.3, 0.2, 0.3), bobbing, and the tick ends there (no gravity, no move, no drag).
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-WATER
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     COMPUTE EN-X(WS-ROW) = WS-WX + 0.5
     COMPUTE EN-Y(WS-ROW) = WS-WY + 0.2
     COMPUTE EN-Z(WS-ROW) = WS-WZ + 0.5
     MOVE 1.0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.1 a flying hook that finds water gets velocity (0.3, 0.2, 0.3) and the state bobbing (1/1000: 300, 200, 300)" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-ROW) * 1000 * 1000000 + EN-VY(WS-ROW) * 1000 * 1000 + EN-VZ(WS-ROW) * 1000
     COMPUTE TL-EXPECTED-N = 300 * 1000000 + 200 * 1000 + 300
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.1 the water entry tick moves nothing (y stays 0.2 above the cell floor, millimetres)" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-Y(WS-ROW) - WS-WY) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.1 and sets the state to bobbing (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PJ-I1(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Bobbing in water at the surface: no gravity, horizontal damping 0.9, the move, then the drag 0.92 (vx 1 gives 0.828 and a move of 0.9).
     CALL "BOAT-FLUID" USING WS-DIM WS-WX WS-WY WS-WZ WS-H WS-WK
     COMPUTE EN-X(WS-ROW) = WS-WX + 0.5
     COMPUTE EN-Y(WS-ROW) = WS-WY + WS-H
     COMPUTE EN-Z(WS-ROW) = WS-WZ + 0.5
     MOVE 1.0 TO EN-VX(WS-ROW) EN-VZ(WS-ROW)
     MOVE 0 TO EN-VY(WS-ROW)
     MOVE 0 TO PJ-I5(WS-PJ) PJ-I3(WS-PJ) PJ-I4(WS-PJ)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.3 a bobbing hook moves 0.9 along x (velocity 1 times 0.9; millimetres)" TO TL-CASE
     MOVE 900 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-X(WS-ROW) - WS-WX - 0.5) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.3 and keeps 0.828 of its x velocity (0.9 then the drag 0.92; 1/1000)" TO TL-CASE
     MOVE 828 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.1 a bobbing hook in water takes no gravity (|vy| at most 0.02 x 0.92 from the surface spring; 1/1000 below 19)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(EN-VY(WS-ROW)) < 0.019
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.3a a hook in water keeps outOfWaterTime at 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I10(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW

*>   Bobbing with no water in its block: gravity 0.03 applies and outOfWaterTime counts up to 10.
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     COMPUTE EN-X(WS-ROW) = WS-X0 + 2.5
     COMPUTE EN-Y(WS-ROW) = WS-Y0 + 5.005
     COMPUTE EN-Z(WS-ROW) = WS-Z0 + 2.5
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     MOVE 2 TO PJ-I1(WS-PJ)
     MOVE 5 TO PJ-I5(WS-PJ)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.3a a bobbing hook out of water counts outOfWaterTime 1 after one tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I10(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.3 and falls (gravity 0.03 times the drag 0.92 at least: vy at most -0.0276)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VY(WS-ROW) <= -0.0276
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.3a out of water the fish is not counted down (nibble stays 5)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PJ-I5(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         CALL "BOBBER-STEP" USING WS-ROW
     END-PERFORM
     MOVE "fishing motion 57-2 1.3a outOfWaterTime stops at 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE PJ-I10(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW

*>   The bite dip: when the nibble starts the vertical velocity is -0.4 x (0.6 + 0.4 f), in (-0.4, -0.24].
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     MOVE 0 TO EN-VY(WS-ROW)
     MOVE 0 TO PJ-I3(WS-PJ) PJ-I5(WS-PJ)
     MOVE 1 TO PJ-I4(WS-PJ)
     CALL "BOBBER-FISH" USING WS-ROW WS-PJ WS-AMOUNT
     MOVE "fishing motion 57-2 1.5 when the fish bites a nibble of 20 to 40 ticks starts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I5(WS-PJ) >= 20 AND PJ-I5(WS-PJ) < 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.5 and the hook dips: vy in (-0.4, -0.24]" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VY(WS-ROW) > -0.4 AND EN-VY(WS-ROW) <= -0.24
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW

*>   Lifetime: a bobbing hook resting on the ground is discarded at 1200 ticks; one 33 blocks from its owner at once.
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     COMPUTE EN-X(WS-ROW) = WS-X0 + 2.5
     COMPUTE EN-Y(WS-ROW) = WS-Y0 + 0.3
     COMPUTE EN-Z(WS-ROW) = WS-Z0 + 2.5
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     MOVE 2 TO PJ-I1(WS-PJ)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         CALL "BOBBER-STEP" USING WS-ROW
     END-PERFORM
     MOVE "fishing motion 57-2 1.6 a bobbing hook that fell onto the floor counts ticks on the ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I6(WS-PJ) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1199 TO PJ-I6(WS-PJ)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.6 and is discarded at 1200" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     COMPUTE EN-X(WS-ROW) = PL-X(WS-PLAYER) + 33
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.6 a hook 33 blocks from its owner is discarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The open-water rule: four 5 x 5 layers at -1 to +2 around the hook's block.
     MOVE WS-WX TO WS-BX
     MOVE WS-WY TO WS-BY
     MOVE WS-WZ TO WS-BZ
     MOVE WS-WATER TO WS-FILL
     PERFORM POND-WATER-AIR
     MOVE "fishing motion 17 3.11 water at -1 and 0, air at +1 and +2 is open water" TO TL-CASE
     PERFORM OPEN-CASE-YES
     MOVE WS-STONE TO WS-FILL
     MOVE 1 TO WS-LAYER
     PERFORM SET-ONE-CELL
     MOVE "fishing motion 17 3.11 one stone block in a layer makes it invalid: not open water" TO TL-CASE
     PERFORM OPEN-CASE-NO
     PERFORM POND-WATER-AIR
     MOVE 0 TO WS-FILL
     MOVE -1 TO WS-LAYER
     PERFORM FILL-LAYER
     MOVE "fishing motion 17 3.11 air in the first layer (no water below) is not open water" TO TL-CASE
     PERFORM OPEN-CASE-NO
     PERFORM POND-WATER-AIR
     MOVE WS-WATER TO WS-FILL
     MOVE 1 TO WS-LAYER
     PERFORM FILL-LAYER
     MOVE 0 TO WS-FILL
     MOVE 0 TO WS-LAYER
     PERFORM FILL-LAYER
     MOVE "fishing motion 17 3.11 water above air (-1 water, 0 air, +1 water) is not open water" TO TL-CASE
     PERFORM OPEN-CASE-NO
     PERFORM POND-WATER-AIR
     MOVE WS-LILY TO WS-FILL
     MOVE 1 TO WS-LAYER
     PERFORM FILL-LAYER
     MOVE "fishing motion 17 3.11 lily pads count as air above the water: open water" TO TL-CASE
     PERFORM OPEN-CASE-YES
     MOVE WS-WATER TO WS-FILL
     MOVE 1 TO WS-LAYER
     PERFORM FILL-LAYER
     MOVE 2 TO WS-LAYER
     PERFORM FILL-LAYER
     MOVE "fishing motion 17 3.11 water in all four layers is open water" TO TL-CASE
     PERFORM OPEN-CASE-YES

*>   The flag of 1.3a on a hook bobbing in the pond (layers water, water, air, air at the hook's block).
     PERFORM POND-WATER-AIR
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     CALL "BOAT-FLUID" USING WS-DIM WS-WX WS-WY WS-WZ WS-H WS-WK
     MOVE 2 TO PJ-I1(WS-PJ)
     MOVE 5 TO PJ-I5(WS-PJ)
     MOVE 0 TO PJ-I9(WS-PJ) PJ-I10(WS-PJ)
     PERFORM PLACE-AT-SURFACE
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.3a during a bite in open water the flag stays open (PJ-I9 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I9(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PJ-I9(WS-PJ)
     MOVE 5 TO PJ-I5(WS-PJ)
     PERFORM PLACE-AT-SURFACE
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.3a a flag that went false stays false during the bite" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I9(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PJ-I5(WS-PJ) PJ-I4(WS-PJ) PJ-I3(WS-PJ)
     MOVE 1 TO PJ-I3(WS-PJ)
     MOVE 1 TO PJ-I9(WS-PJ)
     PERFORM PLACE-AT-SURFACE
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.3a with a fish only lured (no nibble, no timeUntilHooked yet) the flag is true again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I9(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-STONE TO WS-FILL
     MOVE 2 TO WS-LAYER
     PERFORM SET-ONE-CELL
     MOVE 0 TO PJ-I9(WS-PJ)
     MOVE 5 TO PJ-I5(WS-PJ)
     PERFORM PLACE-AT-SURFACE
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.3a during a bite with an obstruction above the pond the flag goes false" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I9(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PJ-I5(WS-PJ) PJ-I4(WS-PJ) PJ-I3(WS-PJ)
     PERFORM PLACE-AT-SURFACE
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.3a between bites the flag is true again even with the obstruction" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I9(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM POND-WATER-AIR
     MOVE 0 TO PJ-I9(WS-PJ)
     MOVE 10 TO PJ-I10(WS-PJ)
     MOVE 5 TO PJ-I5(WS-PJ)
     PERFORM PLACE-AT-SURFACE
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "fishing motion 57-2 1.3a during a bite a hook out of the water for 10 ticks loses the open-water flag" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I9(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fishing motion 57-2 1.3a and back in the water outOfWaterTime counts down by one (10 to 9)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE PJ-I10(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW

*>   The treasure table needs open water: 100 biting catches with luck 10 give no name tag, saddle or nautilus shell when closed, some when open.
     PERFORM VARYING WS-MODE FROM 1 BY 1 UNTIL WS-MODE > 2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
             CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
             CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
             MOVE 5 TO PJ-I5(WS-PJ)
             MOVE 10 TO PJ-I8(WS-PJ)
             IF WS-MODE = 1
                 MOVE 1 TO PJ-I9(WS-PJ)
             ELSE
                 MOVE 0 TO PJ-I9(WS-PJ)
             END-IF
             CALL "BOBBER-RETRIEVE" USING WS-PLAYER WS-ROW WS-COST
         END-PERFORM
         MOVE 0 TO WS-TREASURE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1 AND EN-ITEM-COUNT(WS-I) > 0
                 IF EN-ITEM(WS-I) = WS-NAME-TAG OR EN-ITEM(WS-I) = WS-SADDLE OR EN-ITEM(WS-I) = WS-NAUTILUS
                     ADD 1 TO WS-TREASURE
                 END-IF
             END-IF
         END-PERFORM
         IF WS-MODE = 1
             MOVE "fishing motion 17 3.11 100 catches of a hook that is not in open water roll no treasure" TO TL-CASE
             MOVE 0 TO TL-EXPECTED-N
             MOVE WS-TREASURE TO TL-OBSERVED-N
         ELSE
             MOVE "fishing motion 17 3.11 100 catches of an open-water hook with luck 10 roll some treasure" TO TL-CASE
             MOVE 1 TO TL-EXPECTED-N
             MOVE 0 TO TL-OBSERVED-N
             IF WS-TREASURE > 0
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

*>   Layers dy -1 and 0 of the 5 x 5 area around (WS-BX, WS-BY, WS-BZ) water, +1 and +2 air.
 POND-WATER-AIR.
     MOVE WS-WATER TO WS-FILL
     MOVE -1 TO WS-LAYER
     PERFORM FILL-LAYER
     MOVE 0 TO WS-LAYER
     PERFORM FILL-LAYER
     MOVE 0 TO WS-FILL
     MOVE 1 TO WS-LAYER
     PERFORM FILL-LAYER
     MOVE 2 TO WS-LAYER
     PERFORM FILL-LAYER.

 FILL-LAYER.
     PERFORM VARYING WS-N FROM -2 BY 1 UNTIL WS-N > 2
         PERFORM VARYING WS-NEXT FROM -2 BY 1 UNTIL WS-NEXT > 2
             COMPUTE WS-FX = WS-BX + WS-N
             COMPUTE WS-GY = WS-BY + WS-LAYER
             COMPUTE WS-FZ = WS-BZ + WS-NEXT
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-GY WS-FZ WS-FILL
         END-PERFORM
     END-PERFORM.

 SET-ONE-CELL.
     COMPUTE WS-FX = WS-BX + 2
     COMPUTE WS-GY = WS-BY + WS-LAYER
     COMPUTE WS-FZ = WS-BZ - 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-GY WS-FZ WS-FILL.

 PLACE-AT-SURFACE.
     COMPUTE EN-X(WS-ROW) = WS-WX + 0.5
     COMPUTE EN-Y(WS-ROW) = WS-WY + WS-H
     COMPUTE EN-Z(WS-ROW) = WS-WZ + 0.5
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW).

 OPEN-CASE-YES.
     CALL "BOBBER-OPEN-WATER" USING WS-DIM WS-BX WS-BY WS-BZ WS-OPEN
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OPEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 OPEN-CASE-NO.
     CALL "BOBBER-OPEN-WATER" USING WS-DIM WS-BX WS-BY WS-BZ WS-OPEN
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OPEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-FISHING-MOTION.
 COPY CORETEST.
 COPY MOBSPTEST.
