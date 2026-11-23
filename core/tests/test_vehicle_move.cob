*> Implementation test (wrap I2 round 5, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md section 10.4.1 steps 1 to 6, 05c 0x22 Move Vehicle): the rest of the vehicle-move handler beyond the
*> speed test. NaN or infinite coordinates or rotations disconnect the player with multiplayer.disconnect.invalid_vehicle_movement; a report is ignored while the player's teleport is awaited; the
*> coordinates are clamped (x and z to plus or minus 3.0E7, y to plus or minus 2.0E7) and the rotations wrapped to degrees; a report whose box would collide with a block that the vehicle's own box
*> did not collide with is not applied and the player gets a corrective Move Vehicle, while a vehicle that already collides moves on. The 0.0625 position-error log, the out-of-range limits of
*> containsInvalidValues and the floating counter are not in the documents (the log text, the limits) or need a physics step the core does not run.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VEHICLE-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROTO.
 COPY PLAYPKT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 20.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAU                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET-ID           BINARY-LONG VALUE 34.
 01 WS-MV-X                FLOAT-LONG.
 01 WS-MV-Y                FLOAT-LONG.
 01 WS-MV-Z                FLOAT-LONG.
 01 WS-MV-YAW              FLOAT-SHORT VALUE 0.
 01 WS-MV-PITCH            FLOAT-SHORT VALUE 0.
 01 WS-MV-FLAGS            BINARY-LONG VALUE 1.
 01 WS-NAN-BYTES           PIC X(8).
 01 WS-NAN REDEFINES WS-NAN-BYTES FLOAT-LONG.
 01 WS-INF-BYTES           PIC X(8).
 01 WS-INF REDEFINES WS-INF-BYTES FLOAT-LONG.
 01 WS-FNAN-BYTES          PIC X(4).
 01 WS-FNAN REDEFINES WS-FNAN-BYTES FLOAT-SHORT.
 01 WS-BIG-X               FLOAT-LONG.
 01 WS-BIG-Y               FLOAT-LONG.
 01 WS-BIG-Z               FLOAT-LONG.
 01 WS-BIG-YAW             FLOAT-SHORT.
 01 WS-BIG-PITCH           FLOAT-SHORT.
 01 WS-STONE               BINARY-LONG.
 01 WS-STONE-KEY           PIC X(112) VALUE "minecraft:stone".
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-CLOSED              BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HAYSTACK            PIC X(1026).
 01 WS-HITS                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-DOUBLE SIGNED.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-DOUBLE SIGNED.
 01 WS-OBSERVE             BINARY-DOUBLE SIGNED.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE 0 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     CALL "MS-TEST-STATE" USING WS-STONE-KEY WS-STONE
     MOVE LOW-VALUES TO WS-NAN-BYTES WS-INF-BYTES WS-FNAN-BYTES
     MOVE FUNCTION CHAR(249) TO WS-NAN-BYTES(7:1)
     MOVE FUNCTION CHAR(128) TO WS-NAN-BYTES(8:1)
     MOVE FUNCTION CHAR(241) TO WS-INF-BYTES(7:1)
     MOVE FUNCTION CHAR(128) TO WS-INF-BYTES(8:1)
     MOVE FUNCTION CHAR(129) TO WS-FNAN-BYTES(3:1)
     MOVE FUNCTION CHAR(128) TO WS-FNAN-BYTES(4:1)

*>   Steps 3: the clamps and the wrap of the degrees (a unit of the handler).
     MOVE 50000000 TO WS-BIG-X
     MOVE -30000000 TO WS-BIG-Y
     MOVE -40000000 TO WS-BIG-Z
     MOVE 370 TO WS-BIG-YAW
     MOVE -190 TO WS-BIG-PITCH
     CALL "MOB-RIDE-CLAMP" USING WS-BIG-X WS-BIG-Y WS-BIG-Z WS-BIG-YAW WS-BIG-PITCH
     MOVE "implementation 44-7 10.4.1 step 3: x is clamped to 3.0E7" TO WS-CASE
     MOVE 30000000 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-BIG-X
     PERFORM CHECK
     MOVE "implementation 44-7 10.4.1 step 3: y is clamped to -2.0E7" TO WS-CASE
     MOVE -20000000 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-BIG-Y
     PERFORM CHECK
     MOVE "implementation 44-7 10.4.1 step 3: z is clamped to -3.0E7" TO WS-CASE
     MOVE -30000000 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-BIG-Z
     PERFORM CHECK
     MOVE "implementation 44-7 10.4.1 step 3: yaw 370 wraps to 10" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(WS-BIG-YAW + 0.5)
     PERFORM CHECK
     MOVE "implementation 44-7 10.4.1 step 3: pitch -190 wraps to 170" TO WS-CASE
     MOVE 170 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(WS-BIG-PITCH + 0.5)
     PERFORM CHECK
     MOVE 29999999 TO WS-BIG-X
     MOVE 19999999 TO WS-BIG-Y
     MOVE -29999999 TO WS-BIG-Z
     MOVE 180 TO WS-BIG-YAW
     MOVE -180 TO WS-BIG-PITCH
     CALL "MOB-RIDE-CLAMP" USING WS-BIG-X WS-BIG-Y WS-BIG-Z WS-BIG-YAW WS-BIG-PITCH
     MOVE "implementation 44-7 10.4.1 step 3: values inside the limits stay" TO WS-CASE
     MOVE 29999999 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-BIG-X
     PERFORM CHECK
     MOVE "implementation 44-7 10.4.1 step 3: wrapDegrees(180) is -180" TO WS-CASE
     MOVE -180 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(WS-BIG-YAW + 0.5)
     PERFORM CHECK
     MOVE "implementation 44-7 10.4.1 step 3: wrapDegrees(-180) stays -180" TO WS-CASE
     MOVE -180 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(WS-BIG-PITCH + 0.5)
     PERFORM CHECK

*>   A saddled tame nautilus carries the player.
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     MOVE "minecraft:nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NAU
     MOVE 1 TO EN-TAMED(WS-NAU) EN-SADDLE(WS-NAU)
     MOVE 0 TO EN-MOBAGE(WS-NAU)
     MOVE EN-ID(WS-NAU) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.4.1 setup: the player rides the nautilus" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-RIDER(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK

*>   A report while the player's teleport is awaited is ignored (no move, no correction).
     MOVE 0 TO CN-TELEPORT-ACKED(WS-CONN)
     COMPUTE WS-MV-X = EN-X(WS-NAU) + 1
     MOVE EN-Y(WS-NAU) TO WS-MV-Y
     MOVE EN-Z(WS-NAU) TO WS-MV-Z
     MOVE EN-X(WS-NAU) TO WS-N
     COMPUTE WS-EXPECT = EN-X(WS-NAU) * 1000
     PERFORM FEED-VEHICLE
     MOVE "implementation 44-7 10.4.1 step 2: a report while a teleport is awaited moves nothing" TO WS-CASE
     COMPUTE WS-OBSERVE = EN-X(WS-NAU) * 1000
     PERFORM CHECK
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM COUNT-CORRECTIONS
     MOVE "implementation 44-7 10.4.1 step 2: and sends no correction" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK
     MOVE 1 TO CN-TELEPORT-ACKED(WS-CONN)

*>   A report within the bounds moves the vehicle; its rotation is wrapped (370 is 10 degrees).
     COMPUTE WS-MV-X = EN-X(WS-NAU) + 1
     MOVE 370 TO WS-MV-YAW
     MOVE -190 TO WS-MV-PITCH
     PERFORM FEED-VEHICLE
     MOVE "implementation 44-7 10.4.1 step 5: a free report moves the vehicle (thousandths)" TO WS-CASE
     COMPUTE WS-EXPECT = WS-MV-X * 1000
     COMPUTE WS-OBSERVE = EN-X(WS-NAU) * 1000
     PERFORM CHECK
     MOVE "implementation 44-7 10.4.1 step 3: the vehicle's yaw is the wrapped 10" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(EN-YAW(WS-NAU) + 0.5)
     PERFORM CHECK
     MOVE 0 TO WS-MV-YAW WS-MV-PITCH

*>   Step 6: a block in the way (the box at the reported place meets stone that the box at the vehicle's place does not touch): not applied, a corrective Move Vehicle goes out.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-NAU) + 1)
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-NAU))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-NAU))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE EN-X(WS-NAU) TO WS-X
     COMPUTE WS-MV-X = EN-X(WS-NAU) + 1
     COMPUTE WS-EXPECT = EN-X(WS-NAU) * 1000
     PERFORM FEED-VEHICLE
     MOVE "implementation 44-7 10.4.1 step 6: a report into a block is snapped back (the vehicle stays)" TO WS-CASE
     COMPUTE WS-OBSERVE = EN-X(WS-NAU) * 1000
     PERFORM CHECK
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM COUNT-CORRECTIONS
     MOVE "implementation 44-7 10.4.1 step 6: the player gets a corrective Move Vehicle" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK

*>   A vehicle that already collides (it sits in the block) is not stopped by a new collision: the report is applied.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-NAU))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-MV-X = EN-X(WS-NAU) + 0.1
     PERFORM FEED-VEHICLE
     MOVE "implementation 44-7 10.4.1 step 6: a vehicle that already collides is moved on" TO WS-CASE
     COMPUTE WS-EXPECT = WS-MV-X * 1000
     COMPUTE WS-OBSERVE = EN-X(WS-NAU) * 1000
     PERFORM CHECK

*>   Step 4, the speed test: a report 20 blocks away (moved2 - v2 = 400) is not applied and gets a corrective Move Vehicle.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     COMPUTE WS-MV-X = EN-X(WS-NAU) + 20
     COMPUTE WS-EXPECT = EN-X(WS-NAU) * 1000
     PERFORM FEED-VEHICLE
     MOVE "implementation 44-7 10.4.1 step 4: a report 20 blocks away is not applied" TO WS-CASE
     COMPUTE WS-OBSERVE = EN-X(WS-NAU) * 1000
     PERFORM CHECK
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM COUNT-CORRECTIONS
     MOVE "implementation 44-7 10.4.1 step 4: and the player gets a corrective Move Vehicle" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK

*>   Step 1 (units): NaN and infinite values of each field disconnect the player; the vehicle does not move and the disconnect is the one translation key.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE EN-X(WS-NAU) TO PSB-X
         MOVE EN-Y(WS-NAU) TO PSB-Y
         MOVE EN-Z(WS-NAU) TO PSB-Z
         MOVE 0 TO PSB-YAW PSB-PITCH PSB-FLAGS
         EVALUATE WS-I
             WHEN 1
                 MOVE WS-INF TO PSB-Y
             WHEN 2
                 MOVE WS-NAN TO PSB-Z
             WHEN 3
                 MOVE WS-FNAN TO PSB-YAW
             WHEN 4
                 MOVE WS-FNAN TO PSB-PITCH
             WHEN 5
                 MOVE WS-NAN TO PSB-X
         END-EVALUATE
         MOVE 0 TO CN-CLOSE(WS-CONN)
         MOVE EN-X(WS-NAU) TO WS-X
         CALL "MOB-RIDE-MOVE" USING WS-CONN PLAY-SERVERBOUND
         MOVE "implementation 44-7 10.4.1 step 1: an invalid value (inf y, NaN z, NaN yaw, NaN pitch, NaN x) closes the connection" TO WS-CASE
         MOVE 1 TO WS-EXPECT
         MOVE CN-CLOSE(WS-CONN) TO WS-OBSERVE
         PERFORM CHECK
     END-PERFORM
     COMPUTE WS-EXPECT = WS-X * 1000
     COMPUTE WS-OBSERVE = EN-X(WS-NAU) * 1000
     MOVE "implementation 44-7 10.4.1 step 1: the vehicle did not move" TO WS-CASE
     PERFORM CHECK
     CALL "TEST-DRAIN-DISCONNECT" USING WS-CONN WS-TEXT WS-CLOSED
     MOVE "implementation 44-7 10.4.1 step 1: the Disconnect text is multiplayer.disconnect.invalid_vehicle_movement" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-TEXT(1:49) = "multiplayer.disconnect.invalid_vehicle_movement()"
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     STOP RUN.
*> FEED-VEHICLE: a Move Vehicle packet (0x22) with WS-MV-X, -Y, -Z, the wrapped-test rotation and the on-ground flag through the wire
 FEED-VEHICLE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-MV-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-MV-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-MV-Z
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-MV-YAW
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-MV-PITCH
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-MV-FLAGS
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER.
*> COUNT-CORRECTIONS: how many Move Vehicle packets (clientbound 0x3A = 58) the drained ids WS-IDS hold, in WS-HITS
 COUNT-CORRECTIONS.
     MOVE SPACES TO WS-HAYSTACK
     STRING " " DELIMITED BY SIZE WS-IDS DELIMITED BY SIZE INTO WS-HAYSTACK
     MOVE 0 TO WS-HITS
     INSPECT WS-HAYSTACK TALLYING WS-HITS FOR ALL " 58".
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-VEHICLE-MOVE.
 COPY CORETEST.
 COPY CMDTEST.
 COPY MOBSPTEST.
