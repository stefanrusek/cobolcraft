*> Acceptance test (T29010..T29030, US12-4; docs/protocol/30-redstone-2 section 6, 30-redstone-5 sections 4 to 7, 30-redstone-6 section 4, 30-redstone-8 sections 4 and 5, 31-block-entities-4
*> section 3 over the signal model of 30-redstone-1 section 2.3): the signal sources beyond torches, levers and diodes. An observer pulses 2 ticks after the cell it watches changed (6.3, 6.4)
*> and never for a change behind it, a freshly placed powered observer is reset (6.5), a removed pulsing observer tells its back at once (6.5); a pressure plate presses when an entity
*> stands in its touch box, powers the wire beside it and releases 20 ticks after the last entity left (4.1, 4.2); weighted plates give the count scaled by their maximum weight (4.3).
*> The own and the strong outputs of the lightning rod, the tripwire hook, the lectern, the detector rail, the daylight detector, the target block and the sculk sensors read through the
*> level queries RL-SIGNAL as the documents give them. Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-SOURCES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 01 WS-SKIP                BINARY-LONG.
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
 01 WS-STATE               BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-EXP                 PIC X(160).
 01 WS-CASE                PIC X(240).
 01 WS-WIRE-BLOCK          BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-SIG                 BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-PX                  FLOAT-LONG.
 01 WS-ER                  BINARY-LONG VALUE 0.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-ESTATUS             BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-KEY112              PIC X(112).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone sources: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CB-BLOCK-COUNT
         IF CB-KEY(WS-ID) = "redstone_wire"
             COMPUTE WS-WIRE-BLOCK = WS-ID
         END-IF
     END-PERFORM
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 30
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 6
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 103
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     PERFORM PLAYER-AWAY

*>   A. observer (z 0) facing east watches x 4 and feeds the wire at x 2
     MOVE 0 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE "observer" TO WS-K PERFORM PUT-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 4 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 6.3 a change on the watched side: the observer has not pulsed yet, the wire at its back is 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 6.4 one tick later it is still off: 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 6.2 and 6.4 two ticks after the change the observer is on and strongly powers its back: the wire there is 15" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 6.4 the pulse lasts 2 ticks: the observer is off again and the wire is 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
*>   a change behind the observer (z 2) does nothing
     MOVE 2 TO WS-Z
     MOVE 3 TO WS-X MOVE "observer" TO WS-K PERFORM PUT-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 2 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-2 6.3 a change behind the observer (not in its facing direction) starts no pulse" TO WS-CASE
     MOVE "facing=east,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   a powered observer that is placed is reset (z 4)
     MOVE 4 TO WS-Z
     MOVE 3 TO WS-X MOVE "observer" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     MOVE "powered" TO WS-PN MOVE "true" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-2 6.5 a powered observer placed with no tick pending is reset to unpowered" TO WS-CASE
     MOVE "facing=east,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   removing an observer that is on tells its back at once (z 6)
     MOVE 6 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE "observer" TO WS-K PERFORM PUT-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 4 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 6.5 set-up: the observer of row 6 is on and the wire is 15" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 3 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 6.5 the observer removed while on (a tick pending): its back is told and the wire is 0 at once" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER

*>   B. stone pressure plate (z 8) with the wire at x 4
     MOVE 8 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "stone_pressure_plate" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X MOVE "redstone_wire" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 4 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-5 4.1 an unpressed plate gives no power: the wire beside it is 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     PERFORM PLAYER-ON-PLATE
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.2 a player standing on a stone plate presses it" TO WS-CASE
     MOVE "powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-5 4.1 the pressed plate powers the wire beside it: 15" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 30 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 the plate re-checks every 20 ticks and stays pressed while the player stands on it" TO WS-CASE
     MOVE "powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     PERFORM PLAYER-AWAY
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 the player left: the plate is still pressed until its tick" TO WS-CASE
     MOVE "powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 15 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 within 20 ticks of the last re-check the plate releases" TO WS-CASE
     MOVE "powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-5 4.1 and the wire beside it falls back to 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
*>   a spectator does not press it
     MOVE 3 TO PL-MODE(WS-ROW)
     MOVE 3 TO WS-X
     PERFORM PLAYER-ON-PLATE
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 a player in spectator mode is not counted: the plate stays unpressed" TO WS-CASE
     MOVE "powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM PLAYER-AWAY

*>   C. weighted plates (z 10 light, z 12 heavy): one player gives power 1
     MOVE 10 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "light_weighted_pressure_plate" TO WS-K PERFORM PUT-DEF
     PERFORM PLAYER-ON-PLATE
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.3 one entity on a light weighted plate: power 1" TO WS-CASE
     MOVE "power=1" TO WS-EXP
     PERFORM ASSERT-PROPS
     PERFORM PLAYER-AWAY
     MOVE 12 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "heavy_weighted_pressure_plate" TO WS-K PERFORM PUT-DEF
     PERFORM PLAYER-ON-PLATE
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.3 one entity on a heavy weighted plate (maxWeight 150): power 1" TO WS-CASE
     MOVE "power=1" TO WS-EXP
     PERFORM ASSERT-PROPS
     PERFORM PLAYER-AWAY
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.3 the weighted plate releases 10 ticks after the last check: power 0" TO WS-CASE
     MOVE "power=0" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   removing a pressed plate tells its neighbours (4.1 after removal)
     PERFORM PLAYER-ON-PLATE
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 4 TO WS-X MOVE "redstone_wire" TO WS-K PERFORM PUT-DEF
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-5 4.3 set-up: wire beside the pressed heavy plate carries its power 1" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 3 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-5 4.1 a pressed plate removed from the world: the wire it fed is 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     PERFORM PLAYER-AWAY

*>   D. the outputs read through RL-SIGNAL (z 14 and up): the stone at x 2 beside the source at x 3, the floor below it, the source itself
     MOVE 14 TO WS-Z
     MOVE "lightning_rod" TO WS-K
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV
     MOVE "powered" TO WS-PN
     PERFORM PUT-SOURCE-ROD
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE 2 TO WS-D
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-5 7 a powered lightning rod gives 15 weakly towards every side" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-SIGNAL
     MOVE 2 TO WS-X
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-5 7 and strongly towards its facing: the block it hangs on (behind it) is powered 15" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-SIGNAL
     MOVE 4 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-5 7 the block in front of the rod is not strongly powered: 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-SIGNAL
*>   daylight detector (z 15) and target block (z 16): the power every way, never strong
     MOVE 15 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "daylight_detector" TO WS-K PERFORM MAKE-DEF
     MOVE "power" TO WS-PN MOVE "7" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 2 TO WS-D
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-5 5 a daylight detector gives its power weakly: 7" TO WS-CASE
     MOVE "7" TO WS-EXP
     PERFORM ASSERT-SIGNAL
     MOVE 100 TO WS-Y
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-5 5 and gives no strong power to the block below it: 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-SIGNAL
     MOVE 16 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "target" TO WS-K PERFORM PUT-DEF
     MOVE "power" TO WS-PN MOVE "9" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-5 6 a target block gives its power weakly: 9" TO WS-CASE
     MOVE "9" TO WS-EXP
     PERFORM ASSERT-SIGNAL
*>   sculk sensor (z 17), calibrated sculk sensor (z 18): the power weakly, strongly upwards; the calibrated one nothing towards its facing
     MOVE 17 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "sculk_sensor" TO WS-K
     MOVE "power=5,sculk_sensor_phase=inactive,waterlogged=false" TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     PERFORM PUT-ST
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-8 4.6 a sculk sensor gives its power weakly: 5" TO WS-CASE
     MOVE "5" TO WS-EXP
     PERFORM ASSERT-SIGNAL
     MOVE 100 TO WS-Y
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-8 4.6 and strongly to the block below it: 5" TO WS-CASE
     MOVE "5" TO WS-EXP
     PERFORM ASSERT-SIGNAL
     MOVE 18 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "calibrated_sculk_sensor" TO WS-K
     MOVE "facing=north,power=6,sculk_sensor_phase=inactive,waterlogged=false" TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     PERFORM PUT-ST
     MOVE 2 TO WS-D
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-8 5 a calibrated sculk sensor gives nothing towards its facing: 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-SIGNAL
     MOVE 5 TO WS-D
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-8 5 and its power towards the other sides: 6" TO WS-CASE
     MOVE "6" TO WS-EXP
     PERFORM ASSERT-SIGNAL
     MOVE 100 TO WS-Y
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-8 5 and strongly to the block below it: 6" TO WS-CASE
     MOVE "6" TO WS-EXP
     PERFORM ASSERT-SIGNAL
*>   lectern (z 19) and detector rail (z 20): powered gives 15 weakly and strongly to the block below
     MOVE 19 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "lectern" TO WS-K PERFORM MAKE-DEF
     MOVE "powered" TO WS-PN MOVE "true" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 100 TO WS-Y
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 31-4 3 a powered lectern strongly powers the block below it: 15" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-SIGNAL
     MOVE 20 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "detector_rail" TO WS-K PERFORM MAKE-DEF
     MOVE "powered" TO WS-PN MOVE "true" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 100 TO WS-Y
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-6 4.1 a powered detector rail strongly powers the block it lies on: 15" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-SIGNAL

*>   entities that never press a plate (z 24): a display, an interaction, a marker, a bat, an ominous item spawner; an armor stand does
     MOVE 24 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "stone_pressure_plate" TO WS-K PERFORM PUT-DEF
     MOVE "text_display" TO WS-K PERFORM SPAWN-ENT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 a display entity does not press a plate" TO WS-CASE
     MOVE "powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE "interaction" TO WS-K PERFORM SPAWN-ENT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 an interaction entity does not press a plate" TO WS-CASE
     MOVE "powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE "marker" TO WS-K PERFORM SPAWN-ENT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 a marker entity does not press a plate" TO WS-CASE
     MOVE "powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE "ominous_item_spawner" TO WS-K PERFORM SPAWN-ENT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 an ominous item spawner does not press a plate" TO WS-CASE
     MOVE "powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE "bat" TO WS-K PERFORM SPAWN-ENT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 a bat does not press a plate" TO WS-CASE
     MOVE "powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE "armor_stand" TO WS-K PERFORM SPAWN-ENT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 4.1 an armor stand (not a marker) is a living entity that presses a stone plate" TO WS-CASE
     MOVE "powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     STOP RUN.

 SPAWN-ENT.
*>   an entity of the type of key WS-K standing on the plate at (3, 101, WS-Z); the one made before is dropped
     IF WS-ER > 0
         MOVE 0 TO EN-USED(WS-ER)
     END-IF
     MOVE SPACES TO WS-KEY112
     STRING "minecraft:" FUNCTION TRIM(WS-K) DELIMITED BY SIZE INTO WS-KEY112
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY112 WS-ETYPE WS-ENTITY-ROW WS-ESTATUS
     CALL "ENTITY-ALLOC" USING WS-ER
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ER)
     MOVE WS-ETYPE TO EN-TYPE(WS-ER)
     MOVE WS-DIM TO EN-DIM(WS-ER)
     MOVE 3.5 TO EN-X(WS-ER)
     MOVE 101.0 TO EN-Y(WS-ER)
     COMPUTE EN-Z(WS-ER) = WS-Z + 0.5.

 PUT-SOURCE-ROD.
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     MOVE "lightning_rod" TO WS-K PERFORM PUT-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     MOVE "powered" TO WS-PN MOVE "true" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 2 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF.

 MAKE-DEF.
*>   the default state of the block of key WS-K into WS-ST
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
*>   the default state of the block of key WS-K at (WS-X, WS-Y, WS-Z) into WS-ST and the world
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 SET-P.
*>   property WS-PN of WS-ST set to WS-PV
     CALL "SW-SET-PROP" USING WS-ST WS-PN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 PLAYER-AWAY.
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 104.0 TO PL-Y(WS-ROW)
     MOVE 28.5 TO PL-Z(WS-ROW).

 PLAYER-ON-PLATE.
*>   the player stands on the plate of row WS-Z at x 3 (feet at the floor of the cell)
     MOVE 3.5 TO PL-X(WS-ROW)
     MOVE 101.0 TO PL-Y(WS-ROW)
     COMPUTE WS-PX = WS-Z + 0.5
     MOVE WS-PX TO PL-Z(WS-ROW).

 READ-PROPS.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS.

 READ-WIRE.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N WS-E WS-S WS-W WS-P
     IF CB-S-BLOCK(WS-STATE + 1) = WS-WIRE-BLOCK - 1
         COMPUTE WS-ID = WS-STATE - CB-FIRST-STATE(WS-WIRE-BLOCK) + 5567
         CALL "RS1-WIRE-DECODE" USING WS-ID WS-N WS-E WS-S WS-W WS-P
     ELSE
         MOVE -1 TO WS-P
     END-IF.

 READ-SIGNAL.
*>   level.getSignal at (WS-X, WS-Y, WS-Z) asked with direction WS-D
     CALL "RL-SIGNAL" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-SIG
     MOVE WS-SIG TO WS-P.

 ASSERT-POWER.
     MOVE WS-P TO WS-ED
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SIGNAL.
     PERFORM ASSERT-POWER.

 ASSERT-PROPS.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-F2US12-REDSTONE-SOURCES.

 COPY CORETEST.
 COPY PORTALTEST.
