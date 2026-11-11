*> Implementation test of ground-item movement (core/src/ground-items.cob GI-STEP, itemphys-41.cob IP-ITEM-MOVE,
*> ENTITY-BOX-HITS, GI-SOLID-CELL; tasks T466; docs/protocol/41 section 3, rewritten from the stand-in numbers of standin-content §9.2):
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
 01 WS-FLAG-A              PIC X(3).
 01 WS-FLAG-B              PIC X(3).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
*>   No mob spawns during the test (night with hostile mobs off, standin §12.4).
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
*>   A floor of 5 x 5 blocks at y = 98 and another at y = 96 under chunk (1, 1): nothing else of the test world is solid there.
     MOVE 2 TO WS-STATE
     PERFORM VARYING WS-BX FROM 18 BY 1 UNTIL WS-BX > 22
         PERFORM VARYING WS-BZ FROM 18 BY 1 UNTIL WS-BZ > 22
             MOVE 98 TO WS-BY
             PERFORM SET-BLOCK
             MOVE 96 TO WS-BY
             PERFORM SET-BLOCK
         END-PERFORM
     END-PERFORM
     MOVE 20 TO WS-BX WS-BZ
     MOVE 98 TO WS-BY

     MOVE "test ground item physics a new item is sent to the viewer (Add Entity, Set Entity "
         & "Data) and after one tick has fallen by the gravity 0.04, its vy then times the drag 0.98 "
         & "(41 §3.1), and the viewer is sent Teleport Entity" TO TL-CASE
     MOVE 20.5 TO WS-X WS-Z
     MOVE 100.25 TO WS-Y
     MOVE 0 TO WS-VX WS-VY WS-VZ
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "1(2,1@20.50,100.25,20.50) 101(2=2x1) 128(2) 20.50000,100.21000,20.50000 "
         & "0.00000,-0.03920,0.00000 resting 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics a falling item comes to rest on the solid block below "
         & "(y = its top): the vertical motion is zeroed by the landing (3.3) and then grows by the "
         & "gravity on the ticks that do not move (3.1: -0.12 after three of them)" TO TL-CASE
     MOVE 20 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "128(2)x7 20.50000,99.00000,20.50000 0.00000,-0.12000,0.00000 resting 1"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics a resting item does not move and nothing is sent (it only "
         & "moves one tick in four, and a move that stays on the ground changes nothing)"
         TO TL-CASE
     MOVE 20 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "20.50000,99.00000,20.50000 0.00000,-0.12000,0.00000 resting 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics a block placed into a resting item pushes it out through "
         & "the nearest free side (3.4: north, the first candidate of the ties at 0.5): in the "
         & "next tick x stays, z decreases and the motion on z is negative" TO TL-CASE
     MOVE 99 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 1 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE SPACES TO TL-OBSERVED
     MOVE "no" TO WS-FLAG-A WS-FLAG-B
     IF EN-X(WS-ROW) = 20.5 AND EN-Z(WS-ROW) < 20.5
         MOVE "yes" TO WS-FLAG-A
     END-IF
     IF EN-VZ(WS-ROW) < 0
         MOVE "yes" TO WS-FLAG-B
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "north " FUNCTION TRIM(WS-FLAG-A) " vz negative " FUNCTION TRIM(WS-FLAG-B)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "north yes vz negative yes" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics an item pushed into the floor leaves the block column and "
         & "rests on the floor beside it, outside the block (y = 99, z below 19.875)" TO TL-CASE
     MOVE 80 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "no" TO WS-FLAG-A WS-FLAG-B
     IF EN-ON-GROUND(WS-ROW) = 1 AND EN-Y(WS-ROW) = 99
         MOVE "yes" TO WS-FLAG-A
     END-IF
     IF EN-Z(WS-ROW) < 19.875
         MOVE "yes" TO WS-FLAG-B
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "resting at 99 " FUNCTION TRIM(WS-FLAG-A) " outside the block " FUNCTION TRIM(WS-FLAG-B)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "resting at 99 yes outside the block yes" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item physics a resting item falls again when the block below it is "
         & "removed and rests on the next solid block (the floor at y = 96: y = 97)" TO TL-CASE
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     MOVE 98 TO WS-BY
     MOVE 0 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 40 TO WS-TICKS
     PERFORM TICK-AND-DESCRIBE
     MOVE "no" TO WS-FLAG-A WS-FLAG-B
     IF EN-ON-GROUND(WS-ROW) = 1 AND EN-Y(WS-ROW) = 97
         MOVE "yes" TO WS-FLAG-A
     END-IF
     IF WS-TEXT(1:6) = "128(2)"
         MOVE "yes" TO WS-FLAG-B
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "resting at 97 " FUNCTION TRIM(WS-FLAG-A) " teleports sent " FUNCTION TRIM(WS-FLAG-B)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "resting at 97 yes teleports sent yes" TO TL-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE 2 TO WS-STATE

     MOVE "test ground item physics moves along X and Z into walls are blocked: the item stops "
         & "flush against the wall (box half width 0.125) and that motion becomes 0 while the item keeps falling" TO TL-CASE
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
     MOVE "1(3,1@22.50,100.50,20.50) 101(3=2x1) 103(3) 128(3) 22.87500,100.46000,20.87500 "
         & "0.00000,-0.03920,0.00000 resting 0" TO TL-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT

     MOVE "test ground item physics an upward move into a ceiling is blocked: the item stops flush "
         & "under it (y = 101 - 0.25) and the vertical motion becomes 0" TO TL-CASE
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
     MOVE "1(4,1@24.50,100.60,20.50) 101(4=2x1) 103(4) 128(4) 24.50000,100.75000,20.50000 "
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
     MOVE "63.87500,100.46000,20.50000 "
         & "0.00000,-0.03920,0.00000 resting 0 chunk row 0" TO TL-EXPECTED
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
