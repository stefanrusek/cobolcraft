*> Acceptance test (T29540..T29559, US12-4; docs/protocol/31-block-entities-2 section 5, 30-redstone-7 sections 1 and 4.2, 30-redstone-8 sections 3, 4, 5 and 7, 30-redstone-2 section 5.3): the hopper moves one
*> item every 8 ticks into the container in front and out of the container above and does nothing while powered; the block sound names of doors, trapdoors, gates, plates, bulbs and hooks; a waterlogged
*> trapdoor schedules its water tick; the sculk sensors (vibration, travel time, strength, phases, calibrated filter, comparator); the comparator reading of command blocks, jukeboxes, copper golem statues,
*> creaking hearts and shelves; the tripwire's sides at placement and cutting it with shears. Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-BLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY PROJSTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/p46h-blocks-world".
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
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FKEY                PIC X(112).
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-FROW                BINARY-LONG.
 01 WS-FSLOT               BINARY-LONG.
 01 WS-FDIR                BINARY-LONG.
 01 WS-FKIND               BINARY-LONG.
 01 WS-K2                  PIC X(48).
 01 WS-P1N                 PIC X(16).
 01 WS-P1V                 PIC X(16).
 01 WS-P2N                 PIC X(16).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-BE3                 BINARY-LONG.
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-KEY112              PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-TNT-BEFORE          BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CODE                BINARY-LONG.
 01 WS-FACE-N              BINARY-LONG.
 01 WS-FLAG-N              BINARY-LONG.
 01 WS-TYPE-N              BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-KEYN                PIC X(48).
 01 WS-EXP-TMP             PIC X(160).
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY2                 FLOAT-LONG.
 01 WS-FZ2                 FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 01 WS-CART                BINARY-LONG.
 01 WS-BOLT                BINARY-LONG.
 01 WS-VISUAL              BINARY-LONG VALUE 0.
 01 WS-ANG-INT             BINARY-LONG.
 01 WS-LN                  PIC X(32).
 01 WS-EVT                 PIC X(24).
 01 WS-SNAME               PIC X(48).
 01 WS-SKEY                PIC X(48).
 01 WS-VOL                 BINARY-LONG.
 01 WS-PIT                 BINARY-LONG.
 01 WS-EVN                 BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KINDF               BINARY-LONG.
 01 WS-AMOUNTF             BINARY-LONG.
 01 WS-FALLF               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-VAL                 BINARY-LONG.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-T2                  BINARY-DOUBLE.
 01 WS-T3                  BINARY-DOUBLE.
 01 WS-FLUID-TYPE          BINARY-LONG VALUE 2.
 01 WS-STRIKE              BINARY-DOUBLE.
 01 WS-RELEASE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone blocks: no generated packs here, skipped" TO TL-CASE
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
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 16
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
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM DRAIN
*>   31-2 5.4: the hopper at x 3 facing east pushes one item into the chest at x 4 and then waits 8 ticks
     MOVE "stone" TO WS-K PERFORM FIND-ITEM
     MOVE 0 TO WS-Z
     PERFORM MAKE-HOPPER
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "chest" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 3 TO WS-X
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-P
     MOVE "acceptance US12-4 hopper 31-2 5.4 the hopper put one item into the container in front" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 hopper 31-2 5.4 and has one left" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-P
     MOVE "acceptance US12-4 hopper 31-2 5.2 on its cooldown of 8 it moves nothing 3 ticks later" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-P
     MOVE "acceptance US12-4 hopper 31-2 5.3 and the second item after the cooldown" TO WS-CASE
     MOVE "2" TO WS-EXP
     PERFORM ASSERT-POWER
*>   31-2 5.5: the hopper pulls one item from the container above and pushes it on
     MOVE 3 TO WS-Z
     PERFORM MAKE-HOPPER
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "chest" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE3
     MOVE "stone" TO WS-K PERFORM FIND-ITEM
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE3, 1) MOVE 3 TO BE-SLOT-COUNT(WS-BE3, 1)
     MOVE 101 TO WS-Y
     MOVE 4 TO WS-X MOVE "chest" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 3 TO WS-X
     MOVE 14 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 0 TO WS-P
     IF BE-SLOT-COUNT(WS-BE3, 1) < 3 AND BE-SLOT-COUNT(WS-BE2, 1) > 0
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 hopper 31-2 5.5 an item left the chest above and reached the chest in front" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   31-2 5.1 enabled: a powered hopper moves nothing
     MOVE 6 TO WS-Z
     PERFORM MAKE-HOPPER
     MOVE "stone" TO WS-K PERFORM FIND-ITEM
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "chest" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-P
     MOVE "acceptance US12-4 hopper 31-2 5.1 a hopper beside power is disabled: nothing moved" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
*>   30-7 section 1: the sound names
     MOVE "oak_door" TO WS-SKEY MOVE 1 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.wooden_door.open" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "iron_trapdoor" TO WS-SKEY MOVE 2 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.iron_trapdoor.close" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "cherry_fence_gate" TO WS-SKEY MOVE 1 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.cherry_wood_fence_gate.open" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "oak_fence_gate" TO WS-SKEY MOVE 2 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.fence_gate.close" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "waxed_exposed_copper_door" TO WS-SKEY MOVE 1 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.copper_door.open" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "crimson_trapdoor" TO WS-SKEY MOVE 1 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.nether_wood_trapdoor.open" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "bamboo_door" TO WS-SKEY MOVE 2 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.bamboo_wood_door.close" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "stone_pressure_plate" TO WS-SKEY MOVE 5 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.stone_pressure_plate.click_on" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "oak_pressure_plate" TO WS-SKEY MOVE 6 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.wooden_pressure_plate.click_off" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "heavy_weighted_pressure_plate" TO WS-SKEY MOVE 5 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.metal_pressure_plate.click_on" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "copper_bulb" TO WS-SKEY MOVE 3 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.copper_bulb.turn_on" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "copper_bulb" TO WS-SKEY MOVE 4 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.copper_bulb.turn_off" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "tripwire_hook" TO WS-SKEY MOVE 7 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.tripwire.click_on" TO WS-EXP PERFORM ASSERT-NAME
     MOVE WS-PIT TO WS-P
     MOVE "acceptance US12-4 sounds 30-8 7.4 the click-on pitch is 0.6" TO WS-CASE
     MOVE "600000" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE WS-VOL TO WS-P
     MOVE "acceptance US12-4 sounds 30-8 7.4 and the volume 0.4" TO WS-CASE
     MOVE "400000" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE "tripwire_hook" TO WS-SKEY MOVE 10 TO WS-EVN PERFORM CHECK-SOUND
     MOVE 0 TO WS-P
     IF WS-PIT >= 1090000 AND WS-PIT <= 1334000
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 sounds 30-8 7.4 the detach pitch lies between 1.09 and 1.33" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE "oak_trapdoor" TO WS-SKEY MOVE 1 TO WS-EVN PERFORM CHECK-SOUND
     MOVE 0 TO WS-P
     IF WS-PIT >= 900000 AND WS-PIT <= 1000000 AND WS-VOL = 1000000
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 sounds 30-7 1 a trapdoor plays at volume 1.0 and a pitch of 0.9 to 1.0" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   the sound reaches the viewers: a trapdoor opened by power sends a Sound Effect (119)
     MOVE 9 TO WS-Z
     MOVE 3 TO WS-X MOVE "oak_trapdoor" TO WS-K PERFORM PUT-DEF
     PERFORM DRAIN
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM DRAIN
     MOVE 0 TO WS-HITS
     INSPECT WS-IDS TALLYING WS-HITS FOR ALL "119"
     MOVE WS-HITS TO WS-P
     IF WS-P > 0
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 sounds 30-7 4.3 a trapdoor opened by power sends a Sound Effect" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   30-7 4.2: a waterlogged trapdoor opened by power schedules its water tick
     MOVE 12 TO WS-Z
     MOVE 3 TO WS-X MOVE "oak_trapdoor" TO WS-K PERFORM MAKE-DEF
     MOVE "waterlogged" TO WS-PN MOVE "true" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "FLUID-OF-STATE" USING WS-STATE WS-FLUID WS-KINDF WS-AMOUNTF WS-FALLF
     CALL "BT-HAS" USING WS-DIM WS-FLUID-TYPE WS-FLUID WS-X WS-Y WS-Z WS-FOUND
     MOVE WS-FOUND TO WS-P
     MOVE "acceptance US12-4 trapdoor 30-7 4.2 a waterlogged trapdoor opened by power has a water tick pending" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   30-8 4: a sculk sensor hears block_place two blocks away: strength 12, active after the travel time, the phases 30 and 10 ticks
     MOVE 15 TO WS-Z
     MOVE 3 TO WS-X MOVE "sculk_sensor" TO WS-K PERFORM PUT-DEF
     MOVE "block_place" TO WS-EVT
     MOVE 5 TO WS-X
     CALL "VIB-POST" USING WS-DIM WS-X WS-Y WS-Z WS-EVT
     MOVE 3 TO WS-X
     MOVE 0 TO WS-T1 WS-T2 WS-T3
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 70
         MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
         PERFORM READ-FULL
         IF WS-PROPS = "sculk_sensor:power=12,sculk_sensor_phase=active,waterlogged=false" AND WS-T1 = 0
             MOVE CW-TICKS TO WS-T1
         END-IF
         IF WS-PROPS = "sculk_sensor:power=0,sculk_sensor_phase=cooldown,waterlogged=false" AND WS-T2 = 0
             MOVE CW-TICKS TO WS-T2
         END-IF
         IF WS-PROPS = "sculk_sensor:power=0,sculk_sensor_phase=inactive,waterlogged=false" AND WS-T1 > 0 AND WS-T3 = 0
             MOVE CW-TICKS TO WS-T3
         END-IF
         IF WS-T1 > 0 AND WS-T2 = 0
             MOVE 0 TO WS-D
             CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
         END-IF
     END-PERFORM
     MOVE 0 TO WS-P
     IF WS-T1 > 0
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 sculk 30-8 4.2 the sensor became active with power 12 (distance 2 of radius 8)" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 sculk 30-8 4.7 while active the comparator reads the frequency (block_place 13)" TO WS-CASE
     MOVE "13" TO WS-EXP
     PERFORM ASSERT-POWER
     COMPUTE WS-P = WS-T2 - WS-T1
     MOVE "acceptance US12-4 sculk 30-8 4.3 active for 30 ticks" TO WS-CASE
     MOVE "30" TO WS-EXP
     PERFORM ASSERT-POWER
     COMPUTE WS-P = WS-T3 - WS-T2
     MOVE "acceptance US12-4 sculk 30-8 4.3 then 10 ticks of cooldown" TO WS-CASE
     MOVE "10" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 3 TO WS-X
     MOVE 0 TO WS-D
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 sculk 30-8 4.7 inactive again: the comparator reads 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
*>   30-8 5: a calibrated sensor with power 15 at its back takes only frequency 15: block_place (13) is refused; with nothing behind it, accepted (strength 14 at distance 2 of 16)
     MOVE 18 TO WS-Z
     MOVE 3 TO WS-X MOVE "calibrated_sculk_sensor" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-X
     CALL "VIB-POST" USING WS-DIM WS-X WS-Y WS-Z WS-EVT
     MOVE 3 TO WS-X
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sculk 30-8 5 a calibrated sensor with 15 behind it refuses frequency 13" TO WS-CASE
     MOVE "calibrated_sculk_sensor:facing=east,power=0,sculk_sensor_phase=inactive,waterlogged=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 21 TO WS-Z
     MOVE 3 TO WS-X MOVE "calibrated_sculk_sensor" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 5 TO WS-X
     CALL "VIB-POST" USING WS-DIM WS-X WS-Y WS-Z WS-EVT
     MOVE 3 TO WS-X
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sculk 30-8 5 with nothing behind it the calibrated sensor activates (power 14)" TO WS-CASE
     MOVE "calibrated_sculk_sensor:facing=east,power=14,sculk_sensor_phase=active,waterlogged=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   30-2 5.3: other analog outputs
     MOVE 24 TO WS-Z
     MOVE 3 TO WS-X MOVE "command_block" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 3 TO BE-XI(WS-BE, 4)
     PERFORM READ-ANALOG
     MOVE "acceptance US12-4 analog 30-2 5.3 a command block gives its success count" TO WS-CASE
     MOVE "3" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 26 TO WS-Z
     MOVE 3 TO WS-X MOVE "jukebox" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 9 TO BE-XI(WS-BE, 5)
     PERFORM READ-ANALOG
     MOVE "acceptance US12-4 analog 30-2 5.3 a jukebox gives the output of its song" TO WS-CASE
     MOVE "9" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 28 TO WS-Z
     MOVE 3 TO WS-X MOVE "copper_golem_statue" TO WS-K PERFORM MAKE-DEF
     PERFORM PUT-ST
     PERFORM READ-ANALOG
     MOVE "acceptance US12-4 analog 30-2 5.3 a standing copper golem statue gives 1" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE "copper_golem_pose" TO WS-LN MOVE "star" TO WS-PV
     CALL "SW-SET-PROP-L" USING WS-ST WS-LN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST
     PERFORM PUT-ST
     PERFORM READ-ANALOG
     MOVE "acceptance US12-4 analog 30-2 5.3 and the star pose gives 4" TO WS-CASE
     MOVE "4" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 30 TO WS-Z
     MOVE 3 TO WS-X MOVE "detector_rail" TO WS-K PERFORM PUT-DEF
     PERFORM READ-ANALOG
     MOVE "acceptance US12-4 analog 30-2 5.3 an unpowered detector rail gives 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 1 TO WS-Z
     MOVE 8 TO WS-X MOVE "oak_shelf" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 3) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 3)
     MOVE 3 TO WS-D
     MOVE 8 TO WS-X
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 analog 30-2 5.3 a north shelf read from the south gives its slots 1 and 3 as 5" TO WS-CASE
     MOVE "5" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 2 TO WS-D
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 analog 30-2 5.3 and read from the north gives 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 3 TO WS-Z
     MOVE 8 TO WS-X MOVE "creaking_heart" TO WS-K PERFORM MAKE-DEF
     MOVE "creaking_heart_state" TO WS-LN MOVE "awake" TO WS-PV
     CALL "SW-SET-PROP-L" USING WS-ST WS-LN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 7 TO BE-XI(WS-BE, 5)
     MOVE 8 TO WS-X
     MOVE 0 TO WS-D
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 analog 30-2 5.3 an awake creaking heart gives its output signal" TO WS-CASE
     MOVE "7" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE "uprooted" TO WS-PV
     CALL "SW-SET-PROP-L" USING WS-ST WS-LN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 7 TO BE-XI(WS-BE, 5)
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 analog 30-2 5.3 and an uprooted one gives 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
*>   30-8 7.1: the wire's sides at placement: a hook facing the wire at its west
     MOVE 5 TO WS-Z
     MOVE 2 TO WS-X MOVE "tripwire_hook" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 3 TO WS-X MOVE "tripwire" TO WS-K PERFORM MAKE-DEF
     CALL "REDSTONE-PLACE-STATE" USING WS-DIM WS-X WS-Y WS-Z WS-ST
     CALL "BLOCKS-STATE-PROPS" USING WS-ST WS-PROPS
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "west=true"
     MOVE WS-HITS TO WS-P
     MOVE "acceptance US12-4 tripwire 30-8 7.1 a wire placed beside a hook that faces it has west true" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "east=false"
     MOVE WS-HITS TO WS-P
     MOVE "acceptance US12-4 tripwire 30-8 7.1 and east false" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   more sound names (30-7 section 2 tables)
     MOVE "crimson_fence_gate" TO WS-SKEY MOVE 1 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.nether_wood_fence_gate.open" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "bamboo_fence_gate" TO WS-SKEY MOVE 2 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.bamboo_wood_fence_gate.close" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "cherry_door" TO WS-SKEY MOVE 1 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.cherry_wood_door.open" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "cherry_pressure_plate" TO WS-SKEY MOVE 5 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.cherry_wood_pressure_plate.click_on" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "crimson_pressure_plate" TO WS-SKEY MOVE 6 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.nether_wood_pressure_plate.click_off" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "bamboo_pressure_plate" TO WS-SKEY MOVE 5 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.bamboo_wood_pressure_plate.click_on" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "tripwire_hook" TO WS-SKEY MOVE 8 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.tripwire.click_off" TO WS-EXP PERFORM ASSERT-NAME
     MOVE "tripwire_hook" TO WS-SKEY MOVE 9 TO WS-EVN PERFORM CHECK-SOUND
     MOVE "block.tripwire.attach" TO WS-EXP PERFORM ASSERT-NAME
*>   30-8 3.1: resonate_n is frequency n, an event of frequency 0 is not heard
     MOVE "resonate_7" TO WS-EVT
     CALL "VIB-FREQUENCY" USING WS-EVT WS-VAL
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 sculk 30-8 3.1 resonate_7 has frequency 7" TO WS-CASE
     MOVE "7" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 16 TO WS-Z
     MOVE 3 TO WS-X MOVE "sculk_sensor" TO WS-K PERFORM PUT-DEF
     MOVE "shriek" TO WS-EVT
     MOVE 4 TO WS-X
     CALL "VIB-POST" USING WS-DIM WS-X WS-Y WS-Z WS-EVT
     MOVE 3 TO WS-X
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sculk 30-8 3.1 a frequency 0 event (shriek) is not heard" TO WS-CASE
     MOVE "sculk_sensor:power=0,sculk_sensor_phase=inactive,waterlogged=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   30-8 3.4 step 1: two events in one tick: the nearer one is kept, at equal distance the greater frequency
     MOVE "step" TO WS-EVT
     MOVE 8 TO WS-X
     CALL "VIB-POST" USING WS-DIM WS-X WS-Y WS-Z WS-EVT
     MOVE "block_place" TO WS-EVT
     MOVE 4 TO WS-X
     CALL "VIB-POST" USING WS-DIM WS-X WS-Y WS-Z WS-EVT
     MOVE 3 TO WS-X
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 0 TO WS-D
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 sculk 30-8 3.4 the nearer event (block_place, distance 1) replaced the far one" TO WS-CASE
     MOVE "13" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 17 TO WS-Z
     MOVE 3 TO WS-X MOVE "sculk_sensor" TO WS-K PERFORM PUT-DEF
     MOVE "step" TO WS-EVT
     MOVE 5 TO WS-X
     CALL "VIB-POST" USING WS-DIM WS-X WS-Y WS-Z WS-EVT
     MOVE "block_place" TO WS-EVT
     MOVE 1 TO WS-X
     CALL "VIB-POST" USING WS-DIM WS-X WS-Y WS-Z WS-EVT
     MOVE 3 TO WS-X
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 0 TO WS-D
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 sculk 30-8 3.4 at equal distance the greater frequency (13) is kept" TO WS-CASE
     MOVE "13" TO WS-EXP
     PERFORM ASSERT-POWER
*>   30-2 5.3 more: the sitting and running poses and the second slot of a shelf
     MOVE 28 TO WS-Z
     MOVE 3 TO WS-X MOVE "copper_golem_statue" TO WS-K PERFORM MAKE-DEF
     MOVE "copper_golem_pose" TO WS-LN MOVE "sitting" TO WS-PV
     CALL "SW-SET-PROP-L" USING WS-ST WS-LN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST
     PERFORM PUT-ST
     PERFORM READ-ANALOG
     MOVE "acceptance US12-4 analog 30-2 5.3 a sitting copper golem statue gives 2" TO WS-CASE
     MOVE "2" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE "running" TO WS-PV
     CALL "SW-SET-PROP-L" USING WS-ST WS-LN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST
     PERFORM PUT-ST
     PERFORM READ-ANALOG
     MOVE "acceptance US12-4 analog 30-2 5.3 a running one gives 3" TO WS-CASE
     MOVE "3" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 1 TO WS-Z
     MOVE 8 TO WS-X
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 2) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 2)
     MOVE 3 TO WS-D
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
     MOVE WS-VAL TO WS-P
     MOVE "acceptance US12-4 analog 30-2 5.3 slots 1, 2 and 3 of the shelf give 7" TO WS-CASE
     MOVE "7" TO WS-EXP
     PERFORM ASSERT-POWER
*>   31-2 5.6: a hopper that puts an item into an empty hopper sets its cooldown
     MOVE 9 TO WS-Z
     PERFORM MAKE-HOPPER
     MOVE "stone" TO WS-K PERFORM FIND-ITEM
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "hopper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 3 TO WS-X
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-P
     MOVE "acceptance US12-4 hopper 31-2 5.6 the item reached the empty hopper in front" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   31-2 5.6: the same, the empty hopper placed before the source (so it ticks no later than the source in a game tick: offset 1, cooldown 7); it holds 7 when the item arrives
     MOVE 10 TO WS-Z
     PERFORM MAKE-HOPPER
     MOVE 3 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X MOVE "hopper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 3 TO WS-X MOVE "hopper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE "stone" TO WS-K PERFORM FIND-ITEM
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 1 TO WS-TICKS
     MOVE 0 TO WS-N
     PERFORM UNTIL BE-SLOT-COUNT(WS-BE2, 1) > 0 OR WS-N > 12
         ADD 1 TO WS-N
         PERFORM RUN-TICKS
     END-PERFORM
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-P
     MOVE "acceptance US12-4 hopper 31-2 5.6 the item reached the empty hopper placed first" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-COOLDOWN(WS-BE2) TO WS-P
     MOVE "acceptance US12-4 hopper 31-2 5.6 and its cooldown is 7 when the item arrived" TO WS-CASE
     MOVE "7" TO WS-EXP
     PERFORM ASSERT-POWER
*>   30-5 7: lightning rods of other facings give the axis ordinals, a powered rod placed or removed
     MOVE 11 TO WS-Z
     MOVE 3 TO WS-X MOVE "lightning_rod" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "north" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "RL-ROD-STRUCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     CALL "RL-ROD-STRUCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST
     MOVE "powered" TO WS-PN MOVE "true" TO WS-PV PERFORM SET-P
     MOVE 13 TO WS-Z
     PERFORM PUT-ST
     MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sensors 30-5 7.2 a powered rod placed and removed leaves air" TO WS-CASE
     MOVE "air:" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   30-6 6.3: a check for a block that is no longer the rail does nothing
     MOVE 14 TO WS-Z
     MOVE 3 TO WS-X MOVE "detector_rail" TO WS-K PERFORM MAKE-DEF
     MOVE "stone" TO WS-K PERFORM PUT-DEF
     CALL "RL-DETECTOR-CHECK" USING WS-DIM WS-X WS-Y WS-Z WS-ST
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sensors 30-6 6.3 a check at a cell that is not the rail changes nothing" TO WS-CASE
     MOVE "stone:" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   30-8 7.5: cutting a wire of a line with shears does not pulse the hooks; hooks of side-by-side wires
     MOVE "shears" TO WS-K PERFORM FIND-ITEM
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-ROW, PL-HELD(WS-ROW) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1)
     MOVE 20 TO WS-Z
     PERFORM VARYING WS-NX FROM 0 BY 1 UNTIL WS-NX > 9
         MOVE WS-NX TO WS-X
         PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 103
             MOVE "air" TO WS-K
             PERFORM PUT-DEF
         END-PERFORM
     END-PERFORM
     MOVE 101 TO WS-Y
     MOVE 0 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-X MOVE "tripwire_hook" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "west" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 2 TO WS-X MOVE "tripwire" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE "tripwire" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X MOVE "tripwire" TO WS-K PERFORM PUT-DEF
     MOVE 1 TO WS-X MOVE "tripwire_hook" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "REDSTONE-PLACE-STATE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "east=true"
     MOVE WS-HITS TO WS-P
     MOVE "acceptance US12-4 tripwire 30-8 7.1 a wire beside another wire has that side true" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 3 TO WS-X MOVE 0 TO WS-FACE MOVE 9 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ZERO WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 tripwire 30-8 7.5 cutting the line with shears does not power the hook" TO WS-CASE
     MOVE "tripwire_hook:attached=false,facing=east,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     STOP RUN.

 MAKE-HOPPER.
*>   a hopper facing east at (3, 101, WS-Z) on a clean row, its block entity in WS-BE
     PERFORM VARYING WS-NX FROM 0 BY 1 UNTIL WS-NX > 9
         MOVE WS-NX TO WS-X
         PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 103
             MOVE "air" TO WS-K
             PERFORM PUT-DEF
         END-PERFORM
     END-PERFORM
     MOVE 101 TO WS-Y
     MOVE 3 TO WS-X MOVE "hopper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE.

 CHECK-SOUND.
     MOVE 0 TO WS-VOL
     CALL "RL-BLOCK-SOUND-NAME" USING WS-SKEY WS-EVN WS-SNAME WS-VOL WS-PIT.

 ASSERT-NAME.
     MOVE WS-SNAME TO WS-PROPS
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12-4 sounds name " FUNCTION TRIM(WS-EXP) DELIMITED BY SIZE INTO WS-CASE
     PERFORM ASSERT-PROPS.

 READ-ANALOG.
     MOVE 0 TO WS-D
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-HAS WS-VAL
     MOVE WS-VAL TO WS-P.

 READ-FULL.
*>   WS-PROPS = block key, ":" and the properties of the cell at (WS-X, WS-Y, WS-Z)
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     CALL "KEY-BARE" USING CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) WS-KEYN
     MOVE SPACES TO WS-EXP-TMP
     STRING FUNCTION TRIM(WS-KEYN) ":" FUNCTION TRIM(WS-PROPS) DELIMITED BY SIZE INTO WS-EXP-TMP
     MOVE WS-EXP-TMP TO WS-PROPS.

 DRAIN.
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS.

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

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

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

 END PROGRAM ACC-F2US12-REDSTONE-BLOCKS.

 COPY CORETEST.
 COPY PORTALTEST.
