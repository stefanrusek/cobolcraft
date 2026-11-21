*> Implementation test (T6001; operator play of try3: "fall damage after slowly descending in a water stream"; 29a 8.3 step 2 resetFallDistance, 17 section
*> 4.11): a survival player whose box is in water (a source or a flowing cell, a falling stream or a waterlogged block) has no fall, so landing after
*> sinking 20 blocks through a column of flowing water costs nothing, whatever the column the box is over; a drop of the same height through air
*> still costs health. Standard block tables, stone at y 100 under every case.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FALL-WATER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-CASE                BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-WX                  FLOAT-LONG VALUE 30.5.
 01 WS-WY                  FLOAT-LONG VALUE 101.
 01 WS-WZ                  FLOAT-LONG VALUE 20.5.
 01 WS-EDIT                PIC 9.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-STANDARD-TABLES"
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "water" TO WS-KEY
     MOVE "level=8" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WATER
     MOVE "T" TO TL-MODE
     MOVE 17 TO PL-FOOD(CN-PLAYER(WS-ALICE))
     MOVE 0 TO PL-SATURATION(CN-PLAYER(WS-ALICE))
     MOVE 20 TO WS-X
     MOVE 100 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 21 TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 20 TO WS-X
     PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 121
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     END-PERFORM
     MOVE 12 TO WS-TICKS
*>   Case 0: a drop through air, away from the water, hurts (stone at (24, 100, 20)).
     MOVE 24 TO WS-X
     MOVE 100 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 24.5 TO WS-FX
     MOVE "test fall water: the same drop through air costs 18 health" TO TL-CASE
     PERFORM DESCEND
     MOVE "damage 1 type 1 source 0 | hurt 1 | health 2 food 17" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO PL-HEALTH(CN-PLAYER(WS-ALICE))
*>   Case 1: the box is over the water column.
     MOVE 20.5 TO WS-FX
     MOVE "test fall water: landing after sinking 20 blocks through a column of flowing water costs no health" TO TL-CASE
     PERFORM DESCEND
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Case 2: the feet are in the dry column beside it, the box (0.6 wide) reaches into the water.
     MOVE 21.1 TO WS-FX
     MOVE "test fall water: sinking beside the column with the box reaching into it costs no health" TO TL-CASE
     PERFORM DESCEND
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A waterlogged slab and a bubble column count as water for the box; a dry slab does not (cells (30, 101, 20), (32, 101, 20), (34, 101, 20)).
     MOVE "oak_slab" TO WS-KEY
     MOVE "type=bottom,waterlogged=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE 30 TO WS-X
     MOVE 101 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "bubble_column" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE 32 TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "oak_slab" TO WS-KEY
     MOVE "type=bottom,waterlogged=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE 34 TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE 30.5 TO WS-WX
     CALL "FLUID-TOUCHES-WATER" USING WS-DIM WS-WX WS-WY WS-WZ WS-WET
     MOVE WS-WET TO WS-EDIT
     STRING FUNCTION TRIM(TL-OBSERVED) WS-EDIT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 32.5 TO WS-WX
     CALL "FLUID-TOUCHES-WATER" USING WS-DIM WS-WX WS-WY WS-WZ WS-WET
     MOVE WS-WET TO WS-EDIT
     STRING FUNCTION TRIM(TL-OBSERVED) WS-EDIT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 34.5 TO WS-WX
     CALL "FLUID-TOUCHES-WATER" USING WS-DIM WS-WX WS-WY WS-WZ WS-WET
     MOVE WS-WET TO WS-EDIT
     STRING FUNCTION TRIM(TL-OBSERVED) WS-EDIT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "test fall water: a waterlogged slab and a bubble column touch the box, a dry slab does not" TO TL-CASE
     MOVE "110" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> From y 122 down to the floor in steps of a tenth of a block (a slow sink), then the claim of the ground at y 101; the health packets are read.
 DESCEND.
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 122 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     PERFORM UNTIL WS-FY <= 101.05
         COMPUTE WS-FY = WS-FY - 0.1
         CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     END-PERFORM
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT.
 END PROGRAM TEST-FALL-WATER.

 COPY CORETEST.
