*> Test US14-client (spec 002 T3335/T3336; docs/protocol/49 section 1, 5.1, 5.6; 05b 0x87, 0x4F, 0x86, 0x6D, 0x65, 0x19): the packets behind the status HUD, read with
*> proto's codecs: Update Mob Effect and Remove Mob Effect of the local player (the fixtures of the contract), Update Attributes with its modifiers (armor 1 and
*> max_health 23 of the local player, max_health of the vehicle: add, add multiplied base, add multiplied total), Set Passengers (the vehicle), Set Entity Data (air supply
*> slot 1, ticks frozen slot 7 of the local player, health slot 9 of the vehicle), the Damage Event cooldown, Login (hardcore, a new player) and Respawn (the flash armed
*> again); and the rows they make in the world HUD: armour, hearts, food, air, the mount's hearts (the food row gone, the air row above them), adventure mode, creative.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HUD-PACKETS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY PBATTR.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PACKET              BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-ENTITY              BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ID                  PIC X(64) VALUE "minecraft:test".
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "T" TO TL-MODE

*>   Update Mob Effect of the contract: entity 300, haste (2), amplifier 1, 600 ticks, flags 0x07; for entity 5 it is not ours.
     MOVE 300 TO PL-ENTITY-ID
     MOVE "contract/fixtures/wire/play-s2c-87-update-mob-effect.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE EF-COUNT TO WS-E1
     MOVE EF-ID(1) TO WS-E2
     MOVE EF-AMP(1) TO WS-E3
     MOVE EF-FLAGS(1) TO WS-E4
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US14 49§1 the contract's Update Mob Effect (entity 300): haste amplifier 1 flags 7, one effect" TO TL-CASE
     MOVE "1 2 1 7" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US14 49§1 its duration after the packet and the ticks of TEST-STEP is at most 600" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EF-DUR(1) > 500 AND EF-DUR(1) <= 600
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   Update Attributes of the contract (entity 300): max_health 20, movement_speed ignored; max health 20 stays.
     MOVE 33 TO PL-MAX-HEALTH
     MOVE "contract/fixtures/wire/play-s2c-86-update-attributes.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US14 49§5.2 the contract's Update Attributes (max_health base 20.0) sets the max health of the local player" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-MAX-HEALTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With modifiers: armor base 2 + add 4, times 1.5 (operation 2) = 9; max_health 20 + 20 x 0.5 (operation 1) = 30.
     MOVE 300 TO PB-AT-ENTITY
     MOVE 2 TO PB-AT-COUNT
     MOVE 1 TO PB-AT-ATTRIBUTE(1)
     MOVE 2 TO PB-AT-BASE(1)
     MOVE 2 TO PB-AT-MOD-COUNT(1)
     MOVE 14 TO PB-AT-MOD-ID-LENGTH(1, 1) PB-AT-MOD-ID-LENGTH(1, 2)
     MOVE WS-ID TO PB-AT-MOD-ID(1, 1) PB-AT-MOD-ID(1, 2)
     MOVE 4 TO PB-AT-MOD-AMOUNT(1, 1)
     MOVE 0 TO PB-AT-MOD-OPERATION(1, 1)
     MOVE 0.5 TO PB-AT-MOD-AMOUNT(1, 2)
     MOVE 2 TO PB-AT-MOD-OPERATION(1, 2)
     MOVE 23 TO PB-AT-ATTRIBUTE(2)
     MOVE 20 TO PB-AT-BASE(2)
     MOVE 1 TO PB-AT-MOD-COUNT(2)
     MOVE 14 TO PB-AT-MOD-ID-LENGTH(2, 1)
     MOVE WS-ID TO PB-AT-MOD-ID(2, 1)
     MOVE 0.5 TO PB-AT-MOD-AMOUNT(2, 1)
     MOVE 1 TO PB-AT-MOD-OPERATION(2, 1)
     PERFORM SEND-ATTRIBUTES
     MOVE "acceptance US14 49§5.3 armor 2 + 4, times 1.5: 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE PL-ARMOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US14 49§5.2 max_health 20 + 20 x 0.5: 30" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE PL-MAX-HEALTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Another entity's attributes are not ours.
     MOVE 5 TO PB-AT-ENTITY
     MOVE 1 TO PB-AT-COUNT
     MOVE 1 TO PB-AT-ATTRIBUTE(1)
     MOVE 100 TO PB-AT-BASE(1)
     MOVE 0 TO PB-AT-MOD-COUNT(1)
     PERFORM SEND-ATTRIBUTES
     MOVE "acceptance US14 49§5.3 the attributes of another entity leave the armor at 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE PL-ARMOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Set Passengers: vehicle 9 carries the local player (300); its max_health 40 gives 20 hearts, a health of 17.5 gives 18; 40 hearts are capped at 30.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 2 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 7 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER PL-ENTITY-ID
     MOVE 109 TO WS-PACKET
     PERFORM SEND-BUFFER
     MOVE "acceptance US14 49§5.6 Set Passengers with the local player: vehicle 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE PL-VEHICLE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO PB-AT-ENTITY
     MOVE 1 TO PB-AT-COUNT
     MOVE 23 TO PB-AT-ATTRIBUTE(1)
     MOVE 40 TO PB-AT-BASE(1)
     MOVE 0 TO PB-AT-MOD-COUNT(1)
     PERFORM SEND-ATTRIBUTES
     MOVE "acceptance US14 49§5.6 the vehicle's max_health 40: 20 mount hearts" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-MOUNT-HEARTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 90 TO PB-AT-BASE(1)
     PERFORM SEND-ATTRIBUTES
     MOVE "acceptance US14 49§5.6 a max_health of 90 is capped at 30 hearts" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE PL-MOUNT-HEARTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO PB-AT-BASE(1)
     PERFORM SEND-ATTRIBUTES
*>   Set Entity Data of the vehicle (slot 9, FLOAT 17.5) and of the local player (slot 1 INT air 120, slot 7 INT frozen 100, slot 0 BYTE ignored).
     MOVE 9 TO WS-ENTITY
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ENTITY
     MOVE 9 TO PB-MD-INDEX
     MOVE PB-MDS-FLOAT TO PB-MD-SERIALIZER
     MOVE 17.5 TO PB-MD-FLOAT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER PB-METADATA-ENTRY
     MOVE PB-MD-END TO PB-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER PB-METADATA-ENTRY
     MOVE 101 TO WS-PACKET
     PERFORM SEND-BUFFER
     MOVE "acceptance US14 49§5.6 the vehicle's health 17.5 is 18 for the mount row" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE PL-MOUNT-HEALTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER PL-ENTITY-ID
     MOVE 1 TO PB-MD-INDEX
     MOVE PB-MDS-INT TO PB-MD-SERIALIZER
     MOVE 120 TO PB-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER PB-METADATA-ENTRY
     MOVE 7 TO PB-MD-INDEX
     MOVE 100 TO PB-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER PB-METADATA-ENTRY
     MOVE 0 TO PB-MD-INDEX
     MOVE PB-MDS-BYTE TO PB-MD-SERIALIZER
     MOVE 3 TO PB-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER PB-METADATA-ENTRY
     MOVE PB-MD-END TO PB-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER PB-METADATA-ENTRY
     PERFORM SEND-BUFFER
     MOVE SPACES TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE PL-AIR TO WS-E1
     MOVE PL-TICKS-FROZEN TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US14 49§5.5 Set Entity Data of the local player: air supply 120 (slot 1), ticks frozen 100 (slot 7)" TO TL-CASE
     MOVE "120 100" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The world HUD at GUI 320 x 240 in survival, health 17, food 18, armor 9, air 120 of 300, riding 20 hearts at health 18: no food row, the air row at 240 - 49 - 10.
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO PL-MODE CL-CAMERA PL-OFFHAND-COUNT PL-HELD
     MOVE 17 TO PL-HEALTH
     MOVE 18 TO PL-FOOD
     MOVE 20 TO PL-MAX-HEALTH
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM METERS-TEXT
     MOVE "acceptance US14 49§5 survival riding 20 hearts: armour (69, 191), hearts (69, 201), air (242, 181), mount (242, 201); no food" TO TL-CASE
     MOVE "3:69:191:20:9 1:69:201:20:17 4:242:181:20:120 5:242:201:40:18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The same frame rendered (an absorption of 4.5 adds 3 hearts; the mount row and the air row draw too).
     MOVE 4.5 TO PL-ABSORPTION
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US14 49§5 the rows render quads (more than the 18 of the crosshair, hotbar and selection)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-UI-COUNT > 18
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-ABSORPTION
     MOVE "T" TO TL-MODE
*>   Adventure mode shows the same rows; creative only the mount's hearts.
     MOVE 2 TO PL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM METERS-TEXT
     MOVE "acceptance US14 49§5 adventure mode shows the same rows" TO TL-CASE
     MOVE "3:69:191:20:9 1:69:201:20:17 4:242:181:20:120 5:242:201:40:18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM METERS-TEXT
     MOVE "acceptance US14 49§5.6 creative: only the mount's hearts" TO TL-CASE
     MOVE "5:242:201:40:18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Not riding: Set Passengers without the local player ends the ride; the food row and the air row at 240 - 49 come back.
     MOVE 0 TO PL-MODE
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 0 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 109 TO WS-PACKET
     PERFORM SEND-BUFFER
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM METERS-TEXT
     MOVE "acceptance US14 49§5.4 after the ride: food (242, 201) back, the air row at (242, 191), no mount row" TO TL-CASE
     MOVE "3:69:191:20:9 1:69:201:20:17 2:242:201:20:18 4:242:191:20:120" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A Set Passengers of another vehicle does not end ours; one of ours without us does.
     MOVE 9 TO PL-VEHICLE
     MOVE 11 TO WS-VALUE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 0 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     PERFORM SEND-BUFFER
     MOVE "N" TO TL-MODE
     MOVE "acceptance US14 49§5.6 the passengers of another vehicle (11) leave our ride on vehicle 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE PL-VEHICLE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An Update Attributes packet that is cut short is ignored.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 300 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 3 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 134 TO WS-PACKET
     PERFORM SEND-BUFFER
     MOVE "N" TO TL-MODE
     MOVE "acceptance US14 49§5.3 a truncated Update Attributes changes nothing (armor stays 9)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE PL-ARMOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The Damage Event fixture (entity 1) sets the cooldown 20 when it is the local player; a Remove Mob Effect removes haste.
     MOVE 1 TO PL-ENTITY-ID
     MOVE "contract/fixtures/wire/play-s2c-19-damage-event.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US14 49§5.1 a Damage Event for the local player sets the damage cooldown to 20 (the ticks of TEST-STEP lower it by a few)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF HB-COOLDOWN >= 15 AND HB-COOLDOWN <= 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-VALUE
     MOVE 0 TO WS-ENTITY
     MOVE 11 TO WS-EFFECT
     MOVE 50 TO WS-DUR
     MOVE 6 TO WS-FLAGS
     CALL "EFFECT-SET" USING CLIENT-STATE WS-EFFECT WS-ENTITY WS-DUR WS-FLAGS
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 11 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 79 TO WS-PACKET
     PERFORM SEND-BUFFER
     MOVE "acceptance US14 49§1 Remove Mob Effect of fire resistance (11) drops it, haste stays" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EFFECTS-CLEAR" USING CLIENT-STATE

*>   Set Health: the first one only arms; Login and Respawn make a new player: the flash is armed again, no cooldown, hardcore from Login.
     MOVE 17 TO WS-HEALTH
     CALL "HEALTH-HURT-TO" USING CLIENT-STATE WS-HEALTH
     MOVE 5 TO WS-HEALTH
     CALL "HEALTH-HURT-TO" USING CLIENT-STATE WS-HEALTH
     MOVE "contract/fixtures/wire/play-s2c-32-login-main.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE HB-COOLDOWN TO WS-E1
     MOVE HB-FLASH-ARMED TO WS-E2
     MOVE PL-HARDCORE TO WS-E3
     MOVE PL-VEHICLE TO WS-E4
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US14 49§5.1 Login makes a new player: cooldown 0 (the tick of TEST-STEP leaves it 0), not armed, not hardcore, no vehicle" TO TL-CASE
     MOVE "0 0 0 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-HEALTH
     CALL "HEALTH-HURT-TO" USING CLIENT-STATE WS-HEALTH
     MOVE 5 TO WS-HEALTH
     CALL "HEALTH-HURT-TO" USING CLIENT-STATE WS-HEALTH
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-subroutine.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE SPACES TO TL-OBSERVED
     MOVE HB-COOLDOWN TO WS-E1
     MOVE HB-FLASH-ARMED TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US14 49§5.1 Respawn arms the flash again and clears the cooldown (39 section 8.4)" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Update Attributes of the PB-ATTRIBUTES record, handed to the client.
 SEND-ATTRIBUTES.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-UPDATE-ATTRIBUTES" USING PB-BUFFER PB-ATTRIBUTES
     MOVE 134 TO WS-PACKET
     PERFORM SEND-BUFFER
     .

 SEND-BUFFER.
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     .

*> "kind:x:y:action:state" of every meter widget, space separated.
 METERS-TEXT.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-METER
             MOVE SM-W-ARG(WS-I) TO WS-E1
             MOVE SM-W-X(WS-I) TO WS-E2
             MOVE SM-W-Y(WS-I) TO WS-E3
             MOVE SM-W-ACTION(WS-I) TO WS-E4
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
             MOVE SM-W-STATE(WS-I) TO WS-VALUE
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) ":" FUNCTION TRIM(WS-E4)
                 ":" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             MOVE WS-VALUE TO WS-E1
             STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     .
 END PROGRAM TEST-HUD-PACKETS.

 COPY CLTEST.
