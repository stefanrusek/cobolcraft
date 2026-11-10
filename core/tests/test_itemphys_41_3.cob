*> Acceptance test of Tick behaviour (T0346; docs/protocol/41-item-entity-physics.md section 3; FR-037): gravity 0.04 and drag 0.98
*> (the fall table of 3.1), the pickup delay and age counters, the lifetime, block friction (stone, ice, packed ice, frosted ice,
*> slime, blue ice), the move cadence of a resting item, fluids (water and lava heights, the movement forces, lava hurt and
*> fire), the restitution of 3.3 (stone, slime, a slow landing, a wall, a ceiling), the push out of blocks of 3.4 and the merge
*> cadence. The world is cobolcraft:main: Alice (creative) at (4.5, 54, 8.5) is far from the items, which are in chunk (1, 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEMPHYS-41-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMPHYS.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-T1                  PIC X(64).
 01 WS-T2                  PIC X(64).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-C                   PIC X(16).
 01 WS-D                   PIC X(16).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 777.
 01 WS-RS                  BINARY-DOUBLE.
 01 WS-NAMES.
    05 FILLER              PIC X(24) VALUE "minecraft:ice".
    05 FILLER              PIC X(24) VALUE "minecraft:packed_ice".
    05 FILLER              PIC X(24) VALUE "minecraft:frosted_ice".
    05 FILLER              PIC X(24) VALUE "minecraft:slime_block".
    05 FILLER              PIC X(24) VALUE "minecraft:blue_ice".
    05 FILLER              PIC X(24) VALUE "minecraft:stone".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-FRICTION-NAME    PIC X(24) OCCURS 6 TIMES.
 01 WS-STATES.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 12.
    05 FILLER              BINARY-LONG VALUE 15.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 2.
 01 WS-STATE-TABLE REDEFINES WS-STATES.
    05 WS-FRICTION-STATE   BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
*>   Names of block states used as the special blocks of 41: the content set has no ice, water or lava.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-FRICTION-STATE(WS-I) TO WS-STATE
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
         MOVE WS-FRICTION-NAME(WS-I) TO CB-KEY(WS-BLOCK + 1)
         MOVE FUNCTION STORED-CHAR-LENGTH(WS-FRICTION-NAME(WS-I)) TO CB-KEY-LENGTH(WS-BLOCK + 1)
     END-PERFORM
     MOVE CB-S-BLOCK(7) TO WS-BLOCK
     MOVE "minecraft:water" TO CB-KEY(WS-BLOCK + 1)
     MOVE 15 TO CB-KEY-LENGTH(WS-BLOCK + 1)
     MOVE 0 TO CB-SOLID(WS-BLOCK + 1)
     MOVE CB-S-BLOCK(15) TO WS-BLOCK
     MOVE "minecraft:lava" TO CB-KEY(WS-BLOCK + 1)
     MOVE 14 TO CB-KEY-LENGTH(WS-BLOCK + 1)
     MOVE 0 TO CB-SOLID(WS-BLOCK + 1)

*>   Floors at y = 98 (top 99): stone at x 20, the friction blocks at x 17, 19, 21, 23, 25 and 27 (z 20).
     MOVE 98 TO WS-BY
     MOVE 20 TO WS-BZ
     MOVE 2 TO WS-STATE
     MOVE 20 TO WS-BX
     PERFORM SET-BLOCK

*>   3.1 the fall from rest in air (gravity 0.04 before the move, drag 0.98 after): displacements -0.04, -0.0792, -0.117616.
     MOVE 20.5 TO WS-X WS-Z
     MOVE 105.5 TO WS-Y
     MOVE 0 TO WS-VX WS-VY WS-VZ
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour falling from rest moves -0.04 in the first tick and leaves vy -0.0392" TO WS-CASE
     MOVE "20.50000,105.46000,20.50000 v 0.00000,-0.03920,0.00000 g 0" TO WS-EXPECTED
     PERFORM OBSERVE
     PERFORM CHECK
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour the second tick of a fall moves -0.0792 and leaves vy -0.077616" TO WS-CASE
     MOVE "20.50000,105.38080,20.50000 v 0.00000,-0.07762,0.00000 g 0" TO WS-EXPECTED
     PERFORM OBSERVE
     PERFORM CHECK
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour the third tick of a fall moves -0.117616 and leaves vy -0.11526368" TO WS-CASE
     MOVE "20.50000,105.26318,20.50000 v 0.00000,-0.11526,0.00000 g 0" TO WS-EXPECTED
     PERFORM OBSERVE
     PERFORM CHECK

*>   Air drag 0.98 on x and z after the move (the move used the velocity before drag).
     MOVE 105.5 TO WS-Y
     MOVE 0.5 TO WS-VX
     MOVE -0.25 TO WS-VZ
     PERFORM SPAWN
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour in the air x and z move by their velocity and are then multiplied by 0.98" TO WS-CASE
     MOVE "21.00000,105.46000,20.25000 v 0.49000,-0.03920,-0.24500 g 0" TO WS-EXPECTED
     PERFORM OBSERVE
     PERFORM CHECK

*>   Counters: the pickup delay decreases by 1 per tick (0 and 32767 stay), the age rises by 1 per tick (-32768 stays), an item with
*>   age 5999 is discarded in the tick that makes it 6000, -6000 lives on, an empty stack is discarded at once.
     MOVE 105.5 TO WS-Y
     MOVE 0 TO WS-VX WS-VZ
     MOVE 10 TO WS-DELAY
     PERFORM SPAWN
     MOVE 3 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour the pickup delay falls by 1 per tick and the age rises by 1 per tick" TO WS-CASE
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-A
     CALL "ITT-I" USING EN-AGE(WS-ROW) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "7 3" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 32767 TO EN-DELAY(WS-ROW)
     MOVE -32768 TO EN-AGE(WS-ROW)
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour a pickup delay of 32767 never falls and an age of -32768 never rises" TO WS-CASE
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-A
     CALL "ITT-I" USING EN-AGE(WS-ROW) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "32767 -32768" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 5998 TO EN-AGE(WS-ROW)
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE EN-USED(WS-ROW) TO WS-I
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item is discarded when its age reaches 6000, with no player near" TO WS-CASE
     CALL "ITT-I" USING WS-I WS-A
     MOVE EN-USED(WS-ROW) TO WS-N
     CALL "ITT-I" USING WS-N WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "1 0" TO WS-EXPECTED
     PERFORM CHECK
     PERFORM SPAWN
     MOVE -6000 TO EN-AGE(WS-ROW)
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item of age -6000 is not discarded (extended lifetime)" TO WS-CASE
     MOVE EN-USED(WS-ROW) TO WS-N
     CALL "ITT-I" USING WS-N WS-A
     CALL "ITT-I" USING EN-AGE(WS-ROW) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "1 -5999" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 0 TO EN-ITEM-COUNT(WS-ROW)
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item with an empty stack is discarded" TO WS-CASE
     MOVE EN-USED(WS-ROW) TO WS-N
     CALL "ITT-I" USING WS-N WS-A
     MOVE WS-A TO WS-OBSERVED
     MOVE "0" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 0 TO WS-DELAY
     PERFORM CLEAR-ITEMS

*>   Landing on stone: the move stops at the top, the restitution step zeroes vy, the item rests (on ground).
     MOVE 20.5 TO WS-X WS-Z
     MOVE 100 TO WS-Y
     PERFORM SPAWN
     MOVE 20 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item falling on stone comes to rest at the block top with vy 0 and on-ground set"
         TO WS-CASE
     MOVE "20.50000,99.00000,20.50000 g 1" TO WS-EXPECTED
     PERFORM OBSERVE-POS
     PERFORM CHECK

*>   A resting item moves only on every 4th tick of (tickCount + entity id): removing its floor, it falls on the first such tick
*>   with the gravity of the ticks in between added to vy.
     MOVE EN-VY(WS-ROW) TO WS-F2
     MOVE 0 TO WS-STATE
     MOVE 20 TO WS-BX
     PERFORM SET-BLOCK
     MOVE 0 TO WS-N
     MOVE IP-I-TICKS(WS-ROW) TO WS-I
     PERFORM UNTIL WS-N > 0
         ADD 1 TO WS-I
         ADD 1 TO WS-TICKS
         IF FUNCTION MOD(WS-I + EN-ID(WS-ROW), 4) = 0
             COMPUTE WS-N = WS-I - IP-I-TICKS(WS-ROW)
         END-IF
     END-PERFORM
     MOVE 1 TO WS-TICKS
     PERFORM WS-N TIMES
         PERFORM TICK
     END-PERFORM
     MOVE "acceptance US2 41§3 Tick behaviour a resting item whose floor is removed first moves on the next tick with (tickCount + "
         & "id) mod 4 = 0, by the gravity added in each tick up to it" TO WS-CASE
     COMPUTE WS-F1 = 99 + WS-F2 - 0.04 * WS-N
     CALL "ITT-F" USING WS-F1 WS-A
     MOVE SPACES TO WS-EXPECTED
     STRING "20.50000," FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "ITT-F" USING EN-Y(WS-ROW) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING "20.50000," FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK
     MOVE 2 TO WS-STATE
     PERFORM SET-BLOCK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Block friction: an item on the ground moving at 0.2 is multiplied horizontally by 0.98 * friction of the block below.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-BX = 15 + WS-I * 2
         MOVE WS-FRICTION-STATE(WS-I) TO WS-STATE
         PERFORM SET-BLOCK
         COMPUTE WS-X = WS-BX + 0.5
         MOVE 99 TO WS-Y
         MOVE 20.5 TO WS-Z
         MOVE 0.2 TO WS-VX
         MOVE 0 TO WS-VZ
         PERFORM SPAWN
         MOVE 1 TO EN-ON-GROUND(WS-ROW)
         MOVE 1 TO WS-TICKS
         PERFORM TICK
         MOVE SPACES TO WS-CASE
         STRING "acceptance US2 41§3 Tick behaviour on " FUNCTION TRIM(WS-FRICTION-NAME(WS-I)) " a moving item keeps "
             "0.98 * friction of its horizontal velocity" DELIMITED BY SIZE INTO WS-CASE
         EVALUATE WS-I
             WHEN 1 MOVE "0.19208" TO WS-EXPECTED
             WHEN 2 MOVE "0.19208" TO WS-EXPECTED
             WHEN 3 MOVE "0.19208" TO WS-EXPECTED
             WHEN 4 MOVE "0.15680" TO WS-EXPECTED
             WHEN 5 MOVE "0.19384" TO WS-EXPECTED
             WHEN 6 MOVE "0.11760" TO WS-EXPECTED
         END-EVALUATE
         CALL "ITT-F" USING EN-VX(WS-ROW) WS-A
         MOVE WS-A TO WS-OBSERVED
         PERFORM CHECK
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE 3 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-BX = 15 + WS-I * 2
         MOVE 0 TO WS-STATE
         PERFORM SET-BLOCK
     END-PERFORM

*>   A resting item whose speed is below 1e-5 (squared) and not on its cadence tick does not move and is not slowed.
     MOVE 20.5 TO WS-X
     MOVE 99 TO WS-Y
     MOVE 0.001 TO WS-VX
     MOVE 0 TO WS-VZ
     PERFORM SPAWN
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     MOVE 2 TO WS-STATE
     MOVE 20 TO WS-BX
     PERFORM SET-BLOCK
     PERFORM FIND-OFF-CADENCE
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour a resting item slower than 1e-5 squared stays put and keeps its velocity on a tick off "
         & "the cadence" TO WS-CASE
     MOVE "20.50000,99.00000,20.50000 g 1 vx 0.00100" TO WS-EXPECTED
     PERFORM OBSERVE-POS
     CALL "ITT-F" USING EN-VX(WS-ROW) WS-B
     MOVE WS-OBSERVED TO WS-T1
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-T1) " vx " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Water: with the previous-tick flag set and a height above 0.1 the item is underwater: x and z * 0.99, vy + 0.0005 (below
*>   0.06), no gravity, then the drag 0.98 (validation case 4).
     MOVE 15 TO WS-BX
     MOVE 105 TO WS-BY
     MOVE 6 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 15.5 TO WS-X WS-Z
     MOVE 105.1 TO WS-Y
     MOVE 20 TO WS-BZ
     MOVE 0.5 TO WS-VX
     MOVE -0.5 TO WS-VY
     MOVE 0 TO WS-VZ
     MOVE 20.5 TO WS-Z
     MOVE 20 TO WS-BZ
     MOVE 105 TO WS-BY
     MOVE 15 TO WS-BX
     PERFORM SET-BLOCK
     MOVE 104 TO WS-BY
     PERFORM SET-BLOCK
     PERFORM SPAWN
     MOVE 1 TO IP-I-WET(WS-ROW)
     MOVE 0.5 TO IP-I-WATER-H(WS-ROW)
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour underwater x and z are multiplied by 0.99 and vy gets + 0.0005 without gravity "
         & "(vy -0.5 gives -0.48951 after the drag)" TO WS-CASE
     MOVE "0.48510,-0.48951,0.00000" TO WS-EXPECTED
     CALL "ITT-V3" USING EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW) WS-OBSERVED
     PERFORM CHECK
     MOVE "acceptance US2 41§3 Tick behaviour the fluid scan after the move sets the water height (the top of the water column - "
         & "the box bottom, 1 for a cell with water above) and the flag" TO WS-CASE
     COMPUTE WS-F1 = 105 - EN-Y(WS-ROW)
     CALL "ITT-F" USING WS-F1 WS-A
     CALL "ITT-F" USING IP-I-WATER-H(WS-ROW) WS-B
     CALL "ITT-I" USING IP-I-WET(WS-ROW) WS-C
     MOVE SPACES TO WS-EXPECTED WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " 1" DELIMITED BY SIZE INTO WS-EXPECTED
     STRING FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Lava movement (x and z * 0.95, vy + 0.0005 below 0.06, no gravity) with the stored lava height above 0.1 after the first tick.
     MOVE 105.5 TO WS-Y
     MOVE 0.5 TO WS-VX
     MOVE 0.2 TO WS-VY
     MOVE 20.5 TO WS-X
     PERFORM SPAWN
     MOVE 5 TO IP-I-TICKS(WS-ROW)
     MOVE 0.5 TO IP-I-LAVA-H(WS-ROW)
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour in lava x and z are multiplied by 0.95 and vy gets + 0.0005 below 0.06, no gravity"
         TO WS-CASE
     MOVE "0.46550,0.19600,0.00000" TO WS-EXPECTED
     CALL "ITT-V3" USING EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW) WS-OBSERVED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO WS-STATE
     MOVE 15 TO WS-BX
     MOVE 105 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 104 TO WS-BY
     PERFORM SET-BLOCK

*>   A normal item in a lava cell: ignited for 15 seconds and hurt by 4.0 each tick: dead after the second hit.
     MOVE 22 TO WS-BX
     MOVE 105 TO WS-BY
     MOVE 20 TO WS-BZ
     MOVE 14 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 22.5 TO WS-X
     MOVE 105.1 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0 TO WS-VX
     MOVE 0 TO WS-VY
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item in lava is set alight for 15 seconds and hurt by 4.0: health 1 after the first "
         & "tick" TO WS-CASE
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-A
     CALL "ITT-I" USING IP-I-FIRE(WS-ROW) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "1 300" TO WS-EXPECTED
     PERFORM CHECK
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour the second lava hit destroys the item" TO WS-CASE
     MOVE EN-USED(WS-ROW) TO WS-N
     CALL "ITT-I" USING WS-N WS-A
     MOVE WS-A TO WS-OBSERVED
     MOVE "0" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 0 TO WS-STATE
     PERFORM SET-BLOCK

*>   Restitution (3.3): stone zeroes vy, slime gives 0.8 * 1.0 of the landing speed, a landing slower than the gravity does not bounce,
*>   the bed value is 0.6 for an item.
     MOVE "acceptance US2 41§3 Tick behaviour restitution: slime gives vy 0.4141696 for vy -0.5 stopped after -0.3, stone and a "
         & "slow landing (-0.03) give 0, a bed 0.75 * 0.8" TO WS-CASE
     MOVE -0.5 TO WS-VY
     MOVE -0.3 TO WS-F1
     MOVE 1 TO WS-F2
     CALL "IP-RESTITUTE" USING WS-VY WS-F1 WS-F2 WS-X
     CALL "ITT-F" USING WS-X WS-A
     MOVE 0 TO WS-F2
     CALL "IP-RESTITUTE" USING WS-VY WS-F1 WS-F2 WS-X
     CALL "ITT-F" USING WS-X WS-B
     MOVE -0.03 TO WS-VY
     MOVE 1 TO WS-F2
     CALL "IP-RESTITUTE" USING WS-VY WS-F1 WS-F2 WS-X
     CALL "ITT-F" USING WS-X WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "0.41417 0.00000 0.00000" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 6 TO WS-STATE
     MOVE 4 TO WS-STATE
     MOVE 25 TO WS-BX
     MOVE 98 TO WS-BY
     MOVE 20 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 25.5 TO WS-X
     MOVE 99.4 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0 TO WS-VX WS-VZ
     MOVE -0.46 TO WS-VY
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item landing on slime at post-gravity vy -0.5 leaves with 0.5 * ... = 0.41041 after "
         & "the drag, at the contact height" TO WS-CASE
     MOVE "25.50000,99.00000,20.50000 v 0.00000,0.41041,0.00000 g 1" TO WS-EXPECTED
     PERFORM OBSERVE
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Horizontal wall: the colliding component is lost and the item stops flush at the wall; a ceiling zeroes vy.
     MOVE 23 TO WS-BX
     MOVE 105 TO WS-BY
     MOVE 20 TO WS-BZ
     MOVE 2 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 22.5 TO WS-X
     MOVE 105.5 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0.5 TO WS-VX
     MOVE 0.3 TO WS-VZ
     MOVE 0 TO WS-VY
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item hitting a wall stops flush at it and loses that horizontal velocity entirely"
         TO WS-CASE
     MOVE "22.87500,105.46000,20.80000 v 0.00000,-0.03920,0.29400 g 0" TO WS-EXPECTED
     PERFORM OBSERVE
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 2 TO WS-STATE
     MOVE 26 TO WS-BX
     MOVE 107 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 26.5 TO WS-X
     MOVE 106.5 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0 TO WS-VX WS-VZ
     MOVE 0.6 TO WS-VY
     PERFORM SPAWN
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item moving up into a ceiling stops at it and loses its vertical velocity" TO WS-CASE
     MOVE "26.50000,106.75000,20.50000 v 0.00000,0.00000,0.00000 g 0" TO WS-EXPECTED
     PERFORM OBSERVE
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO WS-STATE
     PERFORM SET-BLOCK

*>   A cell of an unloaded chunk counts as solid: blocked at the chunk border.
     MOVE 63.5 TO WS-X
     MOVE 105.5 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0.5 TO WS-VX
     MOVE 0 TO WS-VY WS-VZ
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour a cell of an unloaded chunk blocks the move: the item stops flush at the chunk border"
         TO WS-CASE
     MOVE "63.87500,105.46000,20.50000 v 0.00000,-0.03920,0.00000 g 0" TO WS-EXPECTED
     PERFORM OBSERVE
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   3.4 push out of blocks: an item inside a solid block moves towards the nearest free neighbour (north first on a tie) with the
*>   speed k * (nextFloat * 0.2 + 0.1) drawn from its own source; the velocity (after gravity) is scaled by 0.75 first.
     MOVE 20 TO WS-BX
     MOVE 105 TO WS-BY
     MOVE 20 TO WS-BZ
     MOVE 2 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 20.5 TO WS-X
     MOVE 105.0 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0 TO WS-VX WS-VY WS-VZ
     PERFORM SPAWN
     CALL "IP-RNG-SEED" USING IP-I-RNG(WS-ROW) WS-SEED
     CALL "IP-RNG-SEED" USING WS-RS WS-SEED
     CALL "IP-RNG-FLOAT" USING WS-RS WS-F1
     COMPUTE WS-F1 = WS-F1 * 0.2 + 0.1
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item inside a block with all neighbours free is pushed north (the first of equal "
         & "distances) at -(r * 0.2 + 0.1) and moves through the block that tick" TO WS-CASE
     COMPUTE WS-F2 = 20.5 - WS-F1
     CALL "ITT-F" USING WS-F2 WS-A
     COMPUTE WS-F2 = 0 - WS-F1 * 0.98
     CALL "ITT-F" USING WS-F2 WS-B
     MOVE SPACES TO WS-EXPECTED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "ITT-F" USING EN-Z(WS-ROW) WS-A
     CALL "ITT-F" USING EN-VZ(WS-ROW) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   North blocked: south wins the tie among south, west and east (distance 0.5 each).
     MOVE 19 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 20 TO WS-BZ
     MOVE 20.5 TO WS-Z
     PERFORM SPAWN
     CALL "IP-RNG-SEED" USING IP-I-RNG(WS-ROW) WS-SEED
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour with north solid the item is pushed south (+(r * 0.2 + 0.1))" TO WS-CASE
     COMPUTE WS-F2 = 20.5 + WS-F1
     CALL "ITT-F" USING WS-F2 WS-A
     CALL "ITT-F" USING EN-Z(WS-ROW) WS-B
     MOVE WS-A TO WS-EXPECTED
     MOVE WS-B TO WS-OBSERVED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   All five candidates solid: the direction stays UP.
     MOVE 21 TO WS-BX
     PERFORM SET-BLOCK
     MOVE 20 TO WS-BX
     MOVE 21 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 19 TO WS-BX
     MOVE 20 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 20 TO WS-BX
     MOVE 106 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 20.5 TO WS-X
     MOVE 105 TO WS-Y
     PERFORM SPAWN
     CALL "IP-RNG-SEED" USING IP-I-RNG(WS-ROW) WS-SEED
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour with every neighbour solid the push direction stays up: vy = +(r * 0.2 + 0.1) * 0.98 "
         & "after the drag" TO WS-CASE
     COMPUTE WS-F2 = WS-F1 * 0.98
     CALL "ITT-F" USING WS-F2 WS-A
     CALL "ITT-F" USING EN-VY(WS-ROW) WS-B
     MOVE WS-A TO WS-EXPECTED
     MOVE WS-B TO WS-OBSERVED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   The merge cadence: a settled item tries to merge when its tick count is a multiple of 40, an item that changed block cell
*>   in the tick every 2 ticks (the merge itself is 4.4).
     MOVE 0 TO WS-STATE
     MOVE 19 TO WS-BX
     MOVE 105 TO WS-BY
     MOVE 20 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 21 TO WS-BX
     PERFORM SET-BLOCK
     MOVE 20 TO WS-BX
     MOVE 106 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 21 TO WS-BZ
     MOVE 105 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 20 TO WS-BX
     PERFORM SET-BLOCK
     MOVE 19 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 20 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 20.5 TO WS-X WS-Z
     MOVE 99 TO WS-Y
     MOVE 0 TO WS-VX WS-VY WS-VZ
     MOVE 20 TO WS-COUNT
     PERFORM SPAWN
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     MOVE WS-ROW TO WS-ROW2
     MOVE 21.0 TO WS-X
     MOVE 30 TO WS-COUNT
     PERFORM SPAWN
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     MOVE 2 TO WS-STATE
     MOVE 21 TO WS-BX
     MOVE 98 TO WS-BY
     MOVE 20 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 37 TO IP-I-TICKS(WS-ROW)
     MOVE 37 TO IP-I-TICKS(WS-ROW2)
     MOVE 2 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour a settled item does not try to merge at tick count 39 (the cadence is 40)" TO WS-CASE
     MOVE EN-USED(WS-ROW) TO WS-N
     CALL "ITT-I" USING WS-N WS-A
     MOVE EN-USED(WS-ROW2) TO WS-N
     CALL "ITT-I" USING WS-N WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "11" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour a settled item tries to merge when its tick count reaches a multiple of 40" TO WS-CASE
     MOVE EN-USED(WS-ROW) TO WS-N
     CALL "ITT-I" USING WS-N WS-A
     MOVE EN-USED(WS-ROW2) TO WS-N
     CALL "ITT-I" USING WS-N WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "10" TO WS-EXPECTED
     PERFORM CHECK

*>   3.2 the fluid height of a cell: 1 when the same fluid is above (lava as well as water), 8/9 for a lone source.
     MOVE 14 TO WS-STATE
     MOVE 30 TO WS-BX
     MOVE 98 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 99 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 6 TO WS-STATE
     MOVE 31 TO WS-BX
     MOVE 98 TO WS-BY
     PERFORM SET-BLOCK
     MOVE 30 TO WS-BX
     MOVE 98 TO WS-BY
     CALL "IP-FLUID-CELL" USING WS-DIM WS-BX WS-BY WS-BZ WS-N WS-F1
     CALL "ITT-I" USING WS-N WS-A
     CALL "ITT-F" USING WS-F1 WS-B
     MOVE 31 TO WS-BX
     CALL "IP-FLUID-CELL" USING WS-DIM WS-BX WS-BY WS-BZ WS-N WS-F1
     CALL "ITT-I" USING WS-N WS-C
     CALL "ITT-F" USING WS-F1 WS-D
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance US2 41§3 Tick behaviour fluid cells: lava under lava is kind 2 height 1, a lone water source kind 1 height 8/9"
         TO WS-CASE
     MOVE "2 1.00000 1 0.88889" TO WS-EXPECTED
     PERFORM CHECK

*>   3.3 block restitution values: a bed (any key ending in _bed) and shelf_mushroom 0.75, slime 1.0 (tested above), others 0.
     MOVE CB-S-BLOCK(101) TO WS-BLOCK
     MOVE "minecraft:shelf_mushroom" TO CB-KEY(WS-BLOCK + 1)
     MOVE 24 TO CB-KEY-LENGTH(WS-BLOCK + 1)
     MOVE CB-S-BLOCK(10) TO WS-BLOCK
     MOVE "minecraft:white_bed" TO CB-KEY(WS-BLOCK + 1)
     MOVE 19 TO CB-KEY-LENGTH(WS-BLOCK + 1)
     MOVE 100 TO WS-STATE
     MOVE 28 TO WS-BX
     MOVE 98 TO WS-BY
     MOVE 20 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 9 TO WS-STATE
     MOVE 29 TO WS-BX
     PERFORM SET-BLOCK
     MOVE 28.5 TO WS-X
     MOVE 99 TO WS-Y
     MOVE 20.5 TO WS-Z
     CALL "IP-BOUNCINESS" USING WS-DIM WS-X WS-Y WS-Z WS-F1
     MOVE 29.5 TO WS-X
     CALL "IP-BOUNCINESS" USING WS-DIM WS-X WS-Y WS-Z WS-F2
     MOVE "acceptance US2 41§3 Tick behaviour the bounce restitution of shelf_mushroom and of a bed is 0.75" TO WS-CASE
     MOVE WS-F1 TO WS-VX
     CALL "ITT-V3" USING WS-F1 WS-F2 WS-VX WS-OBSERVED
     IF CB-S-BLOCK(101) = CB-S-BLOCK(10)
         MOVE "same block" TO WS-OBSERVED
     END-IF
     MOVE "0.75000,0.75000,0.75000" TO WS-EXPECTED
     PERFORM CHECK

*>   A wall to the north (z decreasing): the item stops flush at it and loses vz.
     MOVE 2 TO WS-STATE
     MOVE 29 TO WS-BX
     MOVE 110 TO WS-BY
     MOVE 19 TO WS-BZ
     PERFORM SET-BLOCK
     MOVE 29.5 TO WS-X
     MOVE 110.5 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0 TO WS-VX WS-VY
     MOVE -0.5 TO WS-VZ
     PERFORM SPAWN
     MOVE 1 TO WS-TICKS
     PERFORM TICK
     MOVE "acceptance US2 41§3 Tick behaviour an item moving north into a wall stops flush at it (z = 20.125) and loses vz" TO WS-CASE
     MOVE "29.50000,110.46000,20.12500 v 0.00000,-0.03920,0.00000 g 0" TO WS-EXPECTED
     PERFORM OBSERVE
     PERFORM CHECK
     STOP RUN.

 SET-BLOCK.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE.

 SPAWN.
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-ROW.

 TICK.
     CALL "TEST-TICKS" USING WS-TICKS.

*> Removes every ground item from the tracker.
 CLEAR-ITEMS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.

*> WS-ROW: "x,y,z v vx,vy,vz g ground".
 OBSERVE.
     CALL "ITT-V3" USING EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-T1
     CALL "ITT-V3" USING EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW) WS-T2
     CALL "ITT-I" USING EN-ON-GROUND(WS-ROW) WS-A
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-T1) " v " FUNCTION TRIM(WS-T2) " g " FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED.

*> WS-ROW: "x,y,z g ground".
 OBSERVE-POS.
     CALL "ITT-V3" USING EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-T1
     CALL "ITT-I" USING EN-ON-GROUND(WS-ROW) WS-A
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-T1) " g " FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED.

*> Runs ticks until the next tick of WS-ROW is not on its (tickCount + id) mod 4 cadence.
 FIND-OFF-CADENCE.
     PERFORM UNTIL FUNCTION MOD(IP-I-TICKS(WS-ROW) + 1 + EN-ID(WS-ROW), 4) NOT = 0
         MOVE 1 TO WS-TICKS
         PERFORM TICK
     END-PERFORM
     MOVE 1 TO WS-TICKS.

 CHECK.
     CALL "ITT-CHECK" USING WS-CASE WS-EXPECTED WS-OBSERVED.
 END PROGRAM TEST-ITEMPHYS-41-3.

 COPY CORETEST.
 COPY ITEMTEST.
