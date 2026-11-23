*> Implementation test (wrap I2 round 4, T2451; docs/protocol/19-mobs-land-friendly-and-neutral.md section 3.8, 44-4 section 2.3, 20 sections 4.3 and 4.4): the rest of the camel husk. The camel brain
*> runs for the husk too (the dash cooldown counts down, RandomSitting, the rider's dash); it cannot be leashed while mob-controlled (its first passenger is a mob); a spear-holding rider approaching a
*> far target is carried at the vehicle's chargeSpeedModifier 4.0 (MOB-CHARGE-MODIFIER; 20 section 3.x SpearUseGoal); and the parched jockey is a second mob passenger at the rear seat
*> (WC-PASS2, 44-8 section 12.8 z -0.7), taking the front seat when the husk leaves.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-HUSK-JOCKEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY WCSTATE.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 20.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY24               PIC X(24).
 01 WS-IDKEY               PIC X(112).
 01 WS-IDOUT               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LEAD                BINARY-LONG.
 01 WS-HUSK-ROW            BINARY-LONG.
 01 WS-CAMEL               BINARY-LONG.
 01 WS-HUSK                BINARY-LONG.
 01 WS-PARCHED             BINARY-LONG.
 01 WS-PARCHED2            BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ACTION              BINARY-LONG VALUE 3.
 01 WS-DATA                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-DRIVEN              BINARY-LONG.
 01 WS-MOD                 BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE 0 TO PL-YAW(WS-PLAYER)
     MOVE 6000 TO CW-TIME
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "lead" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-LEAD
     COMPUTE WS-Y = WS-FY + 1
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2

*>   The camel brain for the husk: the dash cooldown counts down and RandomSitting changes the pose of an idle one.
     MOVE "camel_husk" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-CAMEL
     MOVE 1 TO EN-PERSISTENT(WS-CAMEL)
     MOVE 10 TO EN-CAMEL-DASH(WS-CAMEL)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "implementation 54 6.3 the dash cooldown of a camel husk counts down by 1 a tick" TO WS-CASE
     MOVE 9 TO WS-EXPECT
     MOVE EN-CAMEL-DASH(WS-CAMEL) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR WS-FOUND = 1
         CALL "TEST-TICKS" USING WS-ONE
         IF EN-CAMEL-POSE(WS-CAMEL) = 1
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "implementation 44-4 2.3 RandomSitting: an idle camel husk sits down within 3000 ticks" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK

*>   A saddled husk under a player dashes on START_RIDING_JUMP (like the camel: cooldown 55).
     MOVE 0 TO EN-CAMEL-POSE(WS-CAMEL)
     MOVE 0 TO EN-CAMEL-POSE-T(WS-CAMEL)
     MOVE 0 TO EN-CAMEL-DASH(WS-CAMEL)
     MOVE 1 TO EN-SADDLE(WS-CAMEL)
     MOVE WS-X TO EN-X(WS-CAMEL)
     MOVE WS-Y TO EN-Y(WS-CAMEL)
     MOVE WS-Z TO EN-Z(WS-CAMEL)
     MOVE 0 TO EN-VX(WS-CAMEL) EN-VZ(WS-CAMEL)
     MOVE EN-ID(WS-CAMEL) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE 100 TO WS-DATA
     CALL "TEST-HJ-COMMAND" USING WS-CONN WS-ACTION WS-DATA
     MOVE "implementation 54 6.3 the rider of a saddled camel husk dashes (cooldown 55)" TO WS-CASE
     MOVE 55 TO WS-EXPECT
     MOVE EN-CAMEL-DASH(WS-CAMEL) TO WS-OBSERVE
     PERFORM CHECK
     CALL "MOB-RIDE-STOP" USING WS-CAMEL
     MOVE 0 TO EN-SADDLE(WS-CAMEL)

*>   Leash: a lead attaches to a husk with no mob on it and is refused while its first passenger is a mob (20 4.4, 44-4 2.3).
     MOVE WS-LEAD TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-4 2.3 a camel husk without a mob rider can be leashed" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-LEASH(WS-CAMEL) TO WS-OBSERVE
     PERFORM CHECK
     CALL "MOB-LEASH-DROP" USING WS-CAMEL
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE "husk" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-HUSK
     CALL "MOB-MOUNT" USING WS-HUSK WS-CAMEL WS-MOUNTED
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-4 2.3 a camel husk whose first passenger is a mob cannot be leashed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LEASH(WS-CAMEL) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-4 2.3 the lead stays in the hand" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1) TO WS-OBSERVE
     PERFORM CHECK

*>   The parched jockey is a second mob passenger at the rear seat (z -0.7 of the front seat 0.5).
     MOVE "parched" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-PARCHED
     CALL "MOB-MOUNT" USING WS-PARCHED WS-CAMEL WS-MOUNTED
     CALL "WC-ROW-OPEN" USING WS-CAMEL
     MOVE "implementation 19 3.8 a second mob mounts a camel husk as WC-PASS2 and is carried" TO WS-CASE
     COMPUTE WS-EXPECT = WS-PARCHED * 10 + 1
     COMPUTE WS-OBSERVE = WC-PASS2(WS-CAMEL) * 10 + WS-MOUNTED
     PERFORM CHECK
     MOVE "implementation 19 3.8 the front rider is still the first passenger" TO WS-CASE
     MOVE WS-HUSK TO WS-EXPECT
     MOVE EN-PASS(WS-CAMEL) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-8 12.8 the rear rider sits 0.7 behind the camel's position" TO WS-CASE
     MOVE -700 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER((EN-Z(WS-PARCHED) - EN-Z(WS-CAMEL)) * 1000 + 0.5)
     PERFORM CHECK
     MOVE "implementation 44-8 12.8 the front rider sits 0.5 ahead" TO WS-CASE
     MOVE 500 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER((EN-Z(WS-HUSK) - EN-Z(WS-CAMEL)) * 1000 + 0.5)
     PERFORM CHECK
     MOVE "parched" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-PARCHED2
     CALL "MOB-MOUNT" USING WS-PARCHED2 WS-CAMEL WS-MOUNTED
     MOVE "implementation 19 3.8 a camel husk carries two passengers at most" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-MOUNTED TO WS-OBSERVE
     PERFORM CHECK
     MOVE "spider" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-DRIVEN
     CALL "MOB-MOUNT" USING WS-PARCHED2 WS-DRIVEN WS-MOUNTED
     MOVE "parched" TO WS-KEY24
     PERFORM SPAWN-MOB
     CALL "MOB-MOUNT" USING WS-M WS-DRIVEN WS-MOUNTED
     MOVE "implementation 19 3.8 only the camel husk takes a second passenger (a spider carries one)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-MOUNTED TO WS-OBSERVE
     PERFORM CHECK

*>   The front rider leaves: the rear one takes the front seat; the last one leaving empties the vehicle.
     CALL "MOB-MOUNT-DROP" USING WS-HUSK
     CALL "WC-ROW-OPEN" USING WS-CAMEL
     MOVE "implementation 19 3.8 when the first passenger leaves the second becomes the first" TO WS-CASE
     COMPUTE WS-EXPECT = WS-PARCHED * 10
     COMPUTE WS-OBSERVE = EN-PASS(WS-CAMEL) * 10 + WC-PASS2(WS-CAMEL)
     PERFORM CHECK
     CALL "MOB-MOUNT-DROP" USING WS-PARCHED
     MOVE "implementation 19 3.8 the vehicle is empty after the last passenger leaves" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-PASS(WS-CAMEL) + WC-PASS2(WS-CAMEL)
     PERFORM CHECK
     CALL "MOB-MOUNT" USING WS-HUSK WS-CAMEL WS-MOUNTED
     CALL "MOB-MOUNT" USING WS-PARCHED WS-CAMEL WS-MOUNTED
     CALL "MOB-MOUNT-DROP" USING WS-PARCHED
     MOVE "implementation 19 3.8 the second passenger leaving first empties only its seat" TO WS-CASE
     COMPUTE WS-EXPECT = WS-HUSK * 10
     CALL "WC-ROW-OPEN" USING WS-CAMEL
     COMPUTE WS-OBSERVE = EN-PASS(WS-CAMEL) * 10 + WC-PASS2(WS-CAMEL)
     PERFORM CHECK
     CALL "MOB-MOUNT" USING WS-PARCHED WS-CAMEL WS-MOUNTED
     CALL "MOB-MOUNT-GONE" USING WS-CAMEL
     MOVE "implementation 19 3.8 a vehicle that goes leaves both passengers standing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-MOUNT(WS-HUSK) + EN-MOUNT(WS-PARCHED)
     PERFORM CHECK

*>   A passenger that is removed (death, despawn) leaves its seat: the first one hands the front seat to the second, the second just empties its own.
     MOVE "camel_husk" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-CAMEL
     MOVE "husk" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-HUSK
     CALL "MOB-MOUNT" USING WS-HUSK WS-CAMEL WS-MOUNTED
     MOVE "parched" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-PARCHED
     CALL "MOB-MOUNT" USING WS-PARCHED WS-CAMEL WS-MOUNTED
     CALL "ENTITY-REMOVE" USING WS-HUSK
     CALL "WC-ROW-OPEN" USING WS-CAMEL
     MOVE "implementation 19 3.8 a removed first passenger hands the front seat to the second" TO WS-CASE
     COMPUTE WS-EXPECT = WS-PARCHED * 10
     COMPUTE WS-OBSERVE = EN-PASS(WS-CAMEL) * 10 + WC-PASS2(WS-CAMEL)
     PERFORM CHECK
     MOVE "husk" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-HUSK
     CALL "MOB-MOUNT" USING WS-HUSK WS-CAMEL WS-MOUNTED
     CALL "ENTITY-REMOVE" USING WS-HUSK
     CALL "WC-ROW-OPEN" USING WS-CAMEL
     MOVE "implementation 19 3.8 a removed second passenger empties only the rear seat" TO WS-CASE
     COMPUTE WS-EXPECT = WS-PARCHED * 10
     COMPUTE WS-OBSERVE = EN-PASS(WS-CAMEL) * 10 + WC-PASS2(WS-CAMEL)
     PERFORM CHECK
     CALL "MOB-MOUNT-DROP" USING WS-PARCHED

*>   chargeSpeedModifier 4.0 of the camel husk (44-4 2.3); 1.0 for every other vehicle.
     CALL "MOB-CHARGE-MODIFIER" USING WS-CAMEL WS-MOD
     MOVE "implementation 44-4 2.3 the camel husk's charge speed modifier is 4.0" TO WS-CASE
     MOVE 4000 TO WS-EXPECT
     MOVE WS-MOD TO WS-OBSERVE
     PERFORM CHECK
     CALL "MOB-CHARGE-MODIFIER" USING WS-DRIVEN WS-MOD
     MOVE "implementation 44-4 2.3 any other vehicle's charge speed modifier is 1.0" TO WS-CASE
     MOVE 1000 TO WS-EXPECT
     MOVE WS-MOD TO WS-OBSERVE
     PERFORM CHECK

*>   A rider that holds a spear and approaches a target farther than 10 blocks is carried at 4 times the walk (the spear goal's approach path x the vehicle's modifier).
     COMPUTE WS-X = PL-X(WS-PLAYER) - 9
     COMPUTE WS-Z = PL-Z(WS-PLAYER) - 9
     MOVE "camel_husk" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-CAMEL
     MOVE "husk" TO WS-KEY24
     PERFORM SPAWN-MOB
     MOVE WS-M TO WS-HUSK
     CALL "MOB-MOUNT" USING WS-HUSK WS-CAMEL WS-MOUNTED
     MOVE WS-PLAYER TO EN-TARGET(WS-HUSK)
     MOVE 2 TO EN-HAND(WS-HUSK)
     MOVE EN-X(WS-CAMEL) TO WS-X0
     MOVE EN-Z(WS-CAMEL) TO WS-Z0
     CALL "MOB-MOUNT-DRIVE" USING WS-CAMEL WS-DRIVEN
     COMPUTE WS-D1 = FUNCTION SQRT((EN-X(WS-CAMEL) - WS-X0) ** 2 + (EN-Z(WS-CAMEL) - WS-Z0) ** 2)
     MOVE 0 TO EN-HAND(WS-HUSK)
     MOVE WS-X0 TO EN-X(WS-CAMEL)
     MOVE WS-Z0 TO EN-Z(WS-CAMEL)
     MOVE 0 TO EN-VX(WS-CAMEL) EN-VZ(WS-CAMEL)
     CALL "MOB-MOUNT-DRIVE" USING WS-CAMEL WS-DRIVEN
     COMPUTE WS-D2 = FUNCTION SQRT((EN-X(WS-CAMEL) - WS-X0) ** 2 + (EN-Z(WS-CAMEL) - WS-Z0) ** 2)
     MOVE "implementation 44-4 2.3 a spear rider's approach moves the husk at least 3 times as far as an unarmed rider's walk" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-D2 > 0 AND WS-D1 > WS-D2 * 3
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK

*>   A natural husk that rides a camel husk brings the parched as the second passenger (HUSK-CAMEL).
     MOVE "husk" TO WS-KEY24
     MOVE 0 TO WS-FOUND
     COMPUTE WS-X = PL-X(WS-PLAYER) + 8.5
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 6.5
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-FOUND = 1
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         PERFORM SPAWN-MOB
         MOVE WS-M TO WS-HUSK
         CALL "HUSK-CAMEL" USING XR-STATE WS-HUSK
         IF EN-MOUNT(WS-HUSK) > 0
             MOVE 1 TO WS-FOUND
         ELSE
             CALL "ENTITY-REMOVE" USING WS-HUSK
         END-IF
     END-PERFORM
     MOVE EN-MOUNT(WS-HUSK) TO WS-CAMEL
     CALL "WC-ROW-OPEN" USING WS-CAMEL
     MOVE WC-PASS2(WS-CAMEL) TO WS-PARCHED
     MOVE "implementation 20 4.3 the parched jockey rides the camel husk behind the husk" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-FOUND = 1 AND WS-PARCHED > 0
         IF EN-MOUNT(WS-PARCHED) = WS-CAMEL
             MOVE 1 TO WS-OBSERVE
         END-IF
     END-IF
     PERFORM CHECK
     STOP RUN.
*> ITEM-ID: the item id of minecraft:<WS-IDKEY> in WS-IDOUT
 ITEM-ID.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-IDKEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IDOUT WS-ITEM-ROW WS-STATUS.
*> SPAWN-MOB: a mob of the key WS-KEY24 at (WS-X, WS-Y, WS-Z), its row in WS-M
 SPAWN-MOB.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY24) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-M
     MOVE 0 TO EN-MOBAGE(WS-M).
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-HUSK-JOCKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HJ-COMMAND.
*> USING connection id, action, data: feeds Player Command (05c 0x2A) with the player's own entity id and that data.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 42.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ACTION L-DATA.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER PL-ENTITY-ID(CN-PLAYER(L-ID))
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ACTION
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-DATA
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-HJ-COMMAND.
 COPY CORETEST.
 COPY MOBSPTEST.
