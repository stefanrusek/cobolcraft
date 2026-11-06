*> Implementation test of ground-item movement (core/src/ground-items.cob GI-MOVE, GI-STEP,
*> ENTITY-BOX-HITS, GI-SOLID-CELL; tasks T466; standin-content §9.2 step 3; data-model §5 state machine):
*> gravity and drag per tick, coming to rest on a solid block, being pushed up out of a block placed
*> into the item, falling again when the block below is removed, horizontal moves blocked by walls,
*> an upward move blocked by a ceiling, a cell of an unloaded chunk counting as solid, an item in an
*> unloaded chunk not being processed, and Teleport Entity to the viewers after each tick in which
*> the position changed. Items are spawned with GI-SPAWN in chunk (1, 1) of cobolcraft:main (view
*> distance 2); Alice (entity 1, creative) at the spawn point sees them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM-PHYSICS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 6.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-R1                  PIC -(4)9.9(5).
 01 WS-R2                  PIC -(4)9.9(5).
 01 WS-R3                  PIC -(4)9.9(5).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE 2 TO WS-STATE
     MOVE 20 TO WS-BX WS-BZ
     MOVE 98 TO WS-BY
     PERFORM SET-BLOCK

     MOVE "test ground item physics a new item is sent to the viewer (Add Entity, Set Entity "
         & "Data) and after one tick has fallen by the gravity 0.035, its vertical motion then "
         & "multiplied by the drag 0.97, and the viewer is sent Teleport Entity" TO TL-CASE
     MOVE 20.5 TO WS-X WS-Z
     MOVE 100.25 TO WS-Y
     MOVE 0 TO WS-VX WS-VY WS-VZ
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "1(2,1@20.50,100.25,20.50) 101(2=2x1) 128(2) 20.50000,100.21500,20.50000 "
         & "0.00000,-0.03395,0.00000 resting 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics a falling item comes to rest on the solid block below "
         & "(y = its top), its motion becomes 0" TO TL-CASE
     MOVE 20 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "128(2)x8 20.50000,99.00000,20.50000 0.00000,0.00000,0.00000 resting 1"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics a resting item does not move and nothing is sent"
         TO TL-CASE
     PERFORM TICK-AND-DESCRIBE
     MOVE "20.50000,99.00000,20.50000 0.00000,0.00000,0.00000 resting 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics a block placed into a resting item pushes it up onto that "
         & "block (y = the block's top) and it stays resting" TO TL-CASE
     MOVE 99 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 1 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "128(2) 20.50000,100.00000,20.50000 0.00000,0.00000,0.00000 resting 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics a resting item falls again when the block below it is "
         & "removed and rests on the next solid block" TO TL-CASE
     MOVE 0 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 1 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "128(2) 20.50000,99.96500,20.50000 0.00000,-0.03395,0.00000 resting 0"
         TO TL-EXPECTED
     PERFORM CHECK
     MOVE 20 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "128(2)x7 20.50000,99.00000,20.50000 0.00000,0.00000,0.00000 resting 1"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics moves along X and Z into walls are blocked: the coordinate "
         & "stays and that motion becomes 0 while the item keeps falling" TO TL-CASE
     MOVE 2 TO WS-STATE
     MOVE 23 TO WS-BX
     MOVE 100 TO WS-BY
     MOVE 20 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 22 TO WS-BX
     MOVE 21 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 22.5 TO WS-X
     MOVE 100.5 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0.5 TO WS-VX WS-VZ
     MOVE 0 TO WS-VY
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "1(3,1@22.50,100.50,20.50) 101(3=2x1) 103(3) 128(3) 22.50000,100.46500,20.50000 "
         & "0.00000,-0.03395,0.00000 resting 0" TO TL-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT

     MOVE "test ground item physics an upward move into a ceiling is blocked: y stays and the "
         & "vertical motion becomes 0" TO TL-CASE
     MOVE 24 TO WS-BX
     MOVE 101 TO WS-BY
     MOVE 20 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 24.5 TO WS-X
     MOVE 100.6 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0 TO WS-VX WS-VZ
     MOVE 0.5 TO WS-VY
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "1(4,1@24.50,100.60,20.50) 101(4=2x1) 103(4) 24.50000,100.60000,20.50000 "
         & "0.00000,0.00000,0.00000 resting 0" TO TL-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT

     MOVE "test ground item physics a cell of an unloaded chunk counts as solid: a move from "
         & "loaded chunk 3 (outside Alice's view: nothing is sent) into unloaded chunk 4 is blocked"
         TO TL-CASE
     MOVE 63.5 TO WS-X
     MOVE 100.5 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0.5 TO WS-VX
     MOVE 0 TO WS-VY WS-VZ
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE 4 TO WS-BX
     MOVE 1 TO WS-BZ
     CALL "WORLD-FIND" USING WS-DIM WS-BX WS-BZ WS-CHUNK
     MOVE WS-CHUNK TO WS-E1
     STRING " chunk row " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
         POINTER WS-PTR
     MOVE "63.50000,100.46500,20.50000 "
         & "0.00000,-0.03395,0.00000 resting 0 chunk row 0" TO TL-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT

     MOVE "test ground item physics an item whose chunk is not loaded is not processed: no "
         & "move, its pickup delay stays" TO TL-CASE
     MOVE 1000.5 TO WS-X WS-Z
     MOVE 100.5 TO WS-Y
     MOVE 0 TO WS-VX WS-VY WS-VZ
     PERFORM SPAWN
     MOVE 5 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE EN-DELAY(WS-ROW) TO WS-E1
     STRING " delay " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE "1000.50000,100.50000,1000.50000 0.00000,0.00000,0.00000 resting 0 delay 6"
         TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 SET-BLOCK.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE.

 SPAWN.
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY
         WS-ROW.

*> Runs WS-TICKS ticks, drains Alice into WS-TEXT and appends the item's position, motion and
*> resting flag; WS-PTR is left as the STRING pointer after the text.
 TICK-AND-DESCRIBE.
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     COMPUTE WS-R1 ROUNDED = EN-X(WS-ROW)
     COMPUTE WS-R2 ROUNDED = EN-Y(WS-ROW)
     COMPUTE WS-R3 ROUNDED = EN-Z(WS-ROW)
     MOVE EN-ON-GROUND(WS-ROW) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     IF WS-TEXT NOT = SPACES
         STRING FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-IF
     STRING FUNCTION TRIM(WS-R1) "," FUNCTION TRIM(WS-R2) "," FUNCTION TRIM(WS-R3) " "
         DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     COMPUTE WS-R1 ROUNDED = EN-VX(WS-ROW)
     COMPUTE WS-R2 ROUNDED = EN-VY(WS-ROW)
     COMPUTE WS-R3 ROUNDED = EN-VZ(WS-ROW)
     STRING FUNCTION TRIM(WS-R1) "," FUNCTION TRIM(WS-R2) "," FUNCTION TRIM(WS-R3)
         " resting " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE TL-OBSERVED TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-GROUND-ITEM-PHYSICS.

 COPY CORETEST.
