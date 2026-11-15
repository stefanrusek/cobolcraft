*> Turtle egg and sniffer egg of docs/protocol/29b part 7 (sections 3 and 4) as programs of plain numbers (GC7- prefix).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-SHAPE.
*> USING the eggs (1 to 4), the box x0 y0 z0 x1 y1 z1 in pixels out (3): one egg box(3, 0, 3, 12, 7, 12), more column(14, 0, 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EGGS                 BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-EGGS L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 0 TO L-Y0
     MOVE 7 TO L-Y1
     IF L-EGGS = 1
         MOVE 3 TO L-X0 L-Z0
         MOVE 12 TO L-X1 L-Z1
     ELSE
         MOVE 1 TO L-X0 L-Z0
         MOVE 15 TO L-X1 L-Z1
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-PLACE.
*> USING the clicked position holds a turtle egg, its eggs, the eggs of the placed state out (3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLICKED              BINARY-LONG.
 01 L-EGGS                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLICKED L-EGGS L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-CLICKED = 1
         COMPUTE L-RESULT = FUNCTION MIN(4, L-EGGS + 1)
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-REPLACEABLE.
*> USING secondary use, the held item is the egg, the eggs, replaceable out (1; 0 leaves the default rule) (3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SECONDARY            BINARY-LONG.
 01 L-HELD                 BINARY-LONG.
 01 L-EGGS                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SECONDARY L-HELD L-EGGS L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-SECONDARY = 0 AND L-HELD = 1 AND L-EGGS < 4
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-REPLACEABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-ONPLACE.
*> USING sand below, server level, the level event, its data out (3.1 PL: 2012 with data 15).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAND                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SAND L-SERVER L-EVENT L-DATA.
     MOVE 0 TO L-EVENT L-DATA
     IF L-SAND = 1 AND L-SERVER = 1
         MOVE 2012 TO L-EVENT
         MOVE 15 TO L-DATA
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-ONPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-ATTR.
*> USING the day tick (BINARY-LONG), turtle_egg_hatch_chance x 1e6 out (3.2): 1.0 from tick 21062 to 21904 of the day, 0.002 otherwise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TICK                 BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-TICK L-CHANCE.
     COMPUTE WS-T = FUNCTION MOD(L-TICK, 24000)
     MOVE 2000 TO L-CHANCE
     IF WS-T >= 21062 AND WS-T <= 21904
         MOVE 1000000 TO L-CHANCE
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-ATTR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-GATE.
*> USING the chance x 1e6 (BINARY-LONG), the nextFloat (FLOAT-LONG), the gate, the float was drawn out (3.2 step 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALED              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CHANCE               BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-GATE                 BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANCE L-DRAW L-GATE L-DREW.
     MOVE 0 TO L-GATE L-DREW
     IF L-CHANCE > 0
         MOVE 1 TO L-DREW
         COMPUTE WS-SCALED = L-DRAW * 1000000
         IF WS-SCALED < L-CHANCE
             MOVE 1 TO L-GATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-RT.
*> USING the gate, sand below, hatch, eggs, the action (0 none, 1 crack, 2 hatch), the new hatch, the babies, onPlace runs again, the game event (1 block_change, 2 block_destroy),
*> the level events 2001 out (3.2 steps 2 to 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GATE                 BINARY-LONG.
 01 L-SAND                 BINARY-LONG.
 01 L-HATCH                BINARY-LONG.
 01 L-EGGS                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-NEW-HATCH            BINARY-LONG.
 01 L-BABIES               BINARY-LONG.
 01 L-AGAIN                BINARY-LONG.
 01 L-GAME-EVENT           BINARY-LONG.
 01 L-EVENTS               BINARY-LONG.
 PROCEDURE DIVISION USING L-GATE L-SAND L-HATCH L-EGGS L-ACTION L-NEW-HATCH L-BABIES L-AGAIN L-GAME-EVENT L-EVENTS.
     MOVE 0 TO L-ACTION L-BABIES L-AGAIN L-GAME-EVENT L-EVENTS
     MOVE L-HATCH TO L-NEW-HATCH
     IF L-GATE = 1 AND L-SAND = 1
         IF L-HATCH < 2
             MOVE 1 TO L-ACTION L-AGAIN L-GAME-EVENT
             COMPUTE L-NEW-HATCH = L-HATCH + 1
         ELSE
             MOVE 2 TO L-ACTION L-GAME-EVENT
             MOVE L-EGGS TO L-BABIES L-EVENTS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-RT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-PITCH.
*> USING a nextFloat (FLOAT-LONG), the volume x 100, the pitch x 1e6 out (3.2, 3.3: volume 0.7, pitch 0.9 + nextFloat x 0.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-VOLUME L-PITCH.
     MOVE 70 TO L-VOLUME
     COMPUTE L-PITCH ROUNDED = (0.9 + L-DRAW * 0.2) * 1000000
     GOBACK.
 END PROGRAM GC7-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-BABY.
*> USING the egg index i (0 to 3), the spawn x offset x 1000 (0.3 + i x 0.2), z offset x 1000 (0.3), the age out (3.2 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-X L-Z L-AGE.
     COMPUTE L-X = 300 + 200 * L-INDEX
     MOVE 300 TO L-Z
     MOVE -24000 TO L-AGE
     GOBACK.
 END PROGRAM GC7-EGG-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-CAN.
*> USING the entity kind (1 turtle, 2 bat, 3 player, 4 other living, 5 other), under spawn protection, mob_griefing, canDestroyEgg out (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-PROTECTED            BINARY-LONG.
 01 L-GRIEFING             BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-PROTECTED L-GRIEFING L-CAN.
     MOVE 0 TO L-CAN
     EVALUATE L-KIND
         WHEN 3
             IF L-PROTECTED = 0
                 MOVE 1 TO L-CAN
             END-IF
         WHEN 4
             MOVE L-GRIEFING TO L-CAN
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-EGG-CAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-DESTROY.
*> USING the state is a turtle egg, server level, canDestroyEgg, the chance, the draw nextInt(chance), destroyed, the draw was made out (3.3 destroyEgg).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EGG                  BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-DESTROYED            BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EGG L-SERVER L-CAN L-CHANCE L-DRAW L-DESTROYED L-DREW.
     MOVE 0 TO L-DESTROYED L-DREW
     IF L-EGG = 1 AND L-SERVER = 1 AND L-CAN = 1
         MOVE 1 TO L-DREW
         IF L-DRAW = 0
             MOVE 1 TO L-DESTROYED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-CHANCE.
*> USING the trigger (1 stepOn, 2 fallOn), stepping carefully, the entity is a zombie, the chance out (0 when the call does nothing) (3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRIGGER              BINARY-LONG.
 01 L-CAREFUL              BINARY-LONG.
 01 L-ZOMBIE               BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGER L-CAREFUL L-ZOMBIE L-CHANCE.
     MOVE 0 TO L-CHANCE
     IF L-TRIGGER = 1 AND L-CAREFUL = 0
         MOVE 100 TO L-CHANCE
     END-IF
     IF L-TRIGGER = 2 AND L-ZOMBIE = 0
         MOVE 3 TO L-CHANCE
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-CHANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-EGG-DECREASE.
*> USING the eggs, the block is destroyed, the eggs left, the level event 2001, the game event block_destroy out (3.3 decreaseEggs).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EGGS                 BINARY-LONG.
 01 L-DESTROYED            BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-GAME-EVENT           BINARY-LONG.
 PROCEDURE DIVISION USING L-EGGS L-DESTROYED L-LEFT L-EVENT L-GAME-EVENT.
     MOVE 1 TO L-EVENT
     IF L-EGGS <= 1
         MOVE 1 TO L-DESTROYED
         MOVE 0 TO L-LEFT L-GAME-EVENT
     ELSE
         MOVE 0 TO L-DESTROYED
         MOVE 1 TO L-GAME-EVENT
         COMPUTE L-LEFT = L-EGGS - 1
     END-IF
     GOBACK.
 END PROGRAM GC7-EGG-DECREASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-SNIFFER-CONST.
*> USING the selector (1 regular hatch ticks, 2 boosted, 3 random offset), the value out (4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 24000.
    05 FILLER              BINARY-LONG VALUE 12000.
    05 FILLER              BINARY-LONG VALUE 300.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC7-SNIFFER-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-SNIFFER-SHAPE.
*> USING the box x0 y0 z0 x1 y1 z1 in pixels out (4): column(14, 12, 0, 16).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 1 TO L-X0
     MOVE 0 TO L-Y0
     MOVE 2 TO L-Z0
     MOVE 15 TO L-X1
     MOVE 16 TO L-Y1
     MOVE 14 TO L-Z1
     GOBACK.
 END PROGRAM GC7-SNIFFER-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-SNIFFER-PLACE.
*> USING a moss block below (boost), server level, the draw nextInt(300), the level event 3009, the total ticks, the stage, the delay of the next tick, the game event block_place out (4 PL).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOOST                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-GAME-EVENT           BINARY-LONG.
 PROCEDURE DIVISION USING L-BOOST L-SERVER L-DRAW L-EVENT L-TOTAL L-STAGE L-DELAY L-GAME-EVENT.
     MOVE 0 TO L-EVENT
     MOVE 24000 TO L-TOTAL
     IF L-BOOST = 1
         MOVE 12000 TO L-TOTAL
         IF L-SERVER = 1
             MOVE 3009 TO L-EVENT
         END-IF
     END-IF
     COMPUTE L-STAGE = L-TOTAL / 3
     COMPUTE L-DELAY = L-STAGE + L-DRAW
     MOVE 1 TO L-GAME-EVENT
     GOBACK.
 END PROGRAM GC7-SNIFFER-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-SNIFFER-TICK.
*> USING hatch, the action (1 crack, 2 hatch), the new hatch, onPlace runs again (schedules the next stage), a baby sniffer is created out (4 BT).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HATCH                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-NEW-HATCH            BINARY-LONG.
 01 L-AGAIN                BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HATCH L-ACTION L-NEW-HATCH L-AGAIN L-BABY.
     MOVE L-HATCH TO L-NEW-HATCH
     IF L-HATCH NOT = 2
         MOVE 1 TO L-ACTION L-AGAIN
         MOVE 0 TO L-BABY
         COMPUTE L-NEW-HATCH = L-HATCH + 1
     ELSE
         MOVE 2 TO L-ACTION
         MOVE 0 TO L-AGAIN
         MOVE 1 TO L-BABY
     END-IF
     GOBACK.
 END PROGRAM GC7-SNIFFER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-SNIFFER-YAW.
*> USING a nextFloat (FLOAT-LONG), the yaw x 1000 out (4): wrapDegrees(nextFloat x 360), in [-180, 180).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DEGREES             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-YAW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-YAW.
     COMPUTE WS-DEGREES = L-DRAW * 360
     IF WS-DEGREES >= 180
         COMPUTE WS-DEGREES = WS-DEGREES - 360
     END-IF
     COMPUTE L-YAW ROUNDED = WS-DEGREES * 1000
     GOBACK.
 END PROGRAM GC7-SNIFFER-YAW.
