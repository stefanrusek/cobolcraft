*> Implementation test (wrap I2 round 4, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md sections 10.1, 10.3, 10.3.1, 10.4): the nautilus and the zombie nautilus as mounts. A tame adult
*> equips nautilus armor from the main hand (one item, BODY, only when the slot is empty; the saddle goes through the saddle slot) and an untamed or baby one does not; a tame one is ridden by an empty
*> hand or by an item that is no equippable and no food (10.2 step 3); the rider sits at the seat y 1.1375 less the player's 0.6; the first passenger gets BREATH_OF_THE_NAUTILUS (60 ticks, refreshed
*> when absent or on a tick with the game time a multiple of 40); a saddled one dashes on START_RIDING_JUMP (cooldown 40, the flag stays through 6 ticks and is cleared on the 7th); the zombie
*> nautilus burns in daylight unless its BODY slot is filled (20 section 3.5 with 44-7 section 10.1, sunProtectionSlot BODY).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-NAUTILUS-RIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY WCSTATE.
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
 01 WS-SADDLE              BINARY-LONG.
 01 WS-ARMOR               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-NAU                 BINARY-LONG.
 01 WS-ZOM                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-HELD-SLOT           BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG VALUE 39.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 3.
 01 WS-DATA                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SEATED              BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
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
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     MOVE "saddle" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-SADDLE
     MOVE "iron_nautilus_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-ARMOR
     MOVE "cobblestone" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-STONE
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 1 TO WS-HELD-SLOT

*>   An untamed nautilus: armor in the hand is neither equipped nor does it start a ride (10.3.1: canUseSlot is false for an untamed one, 10.2 step 3 needs a tame one).
     MOVE "nautilus" TO WS-KEY24
     PERFORM SPAWN-NAUTILUS
     MOVE WS-M TO WS-NAU
     MOVE 0 TO EN-TAMED(WS-NAU)
     PERFORM HOLD-ARMOR
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     CALL "WC-ROW-OPEN" USING WS-NAU
     MOVE "implementation 44-7 10.3.1 an untamed nautilus does not equip the armor in the hand" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-BODY(WS-NAU) + EN-RIDER(WS-NAU)
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 the armor stays in the hand of the player" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 1 TO EN-TAMED(WS-NAU)
     MOVE -24000 TO EN-MOBAGE(WS-NAU)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.3 a tame baby nautilus is not equipped (canUseSlot needs an adult)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-BODY(WS-NAU) + EN-RIDER(WS-NAU)
     PERFORM CHECK

*>   A tame adult: the armor goes to BODY, one item (a stack of 1 is used up).
     MOVE 0 TO EN-MOBAGE(WS-NAU)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.3.1 a tame adult nautilus puts the armor of the hand into BODY" TO WS-CASE
     MOVE WS-ARMOR TO WS-EXPECT
     MOVE WC-BODY(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 the equipped stack is split from the hand (count 1 to 0)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 equipping does not start a ride" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-RIDER(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK

*>   BODY full: the equip step passes and, the item being no food, 10.2 step 3 makes the player ride.
     PERFORM HOLD-ARMOR
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.3.1 with BODY full the armor in the hand passes and the player rides (10.2 step 3)" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-RIDER(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 the armor stays in the hand when BODY is full" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-18 8.4 the rider sits at the seat y 1.1375 less 0.6 (thousandths above the nautilus)" TO WS-CASE
     MOVE 538 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER((PL-Y(WS-PLAYER) - EN-Y(WS-NAU)) * 1000 + 0.5)
     PERFORM CHECK

*>   The first passenger gets BREATH_OF_THE_NAUTILUS for 60 ticks, saddled or not.
     CALL "TEST-TICKS" USING WS-ONE
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-EFFECT WS-LEVEL WS-LEFT
     MOVE "implementation 44-7 10.4 a rider of an unsaddled nautilus gets the effect (amplifier 0, level 1)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-LEVEL TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.4 the effect lasts 60 ticks (59 or 60 left after the tick)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-LEFT >= 59 AND WS-LEFT <= 60
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-EFFECT
     CALL "TEST-TICKS" USING WS-ONE
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-EFFECT WS-LEVEL WS-LEFT
     MOVE "implementation 44-7 10.4 the effect is granted again when the rider lacks it" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-LEVEL TO WS-OBSERVE
     PERFORM CHECK

*>   No saddle, no dash: START_RIDING_JUMP does nothing (canJump is isSaddled).
     MOVE 100 TO WS-DATA
     CALL "TEST-NAU-COMMAND" USING WS-CONN WS-ACTION WS-DATA
     CALL "WC-ROW-OPEN" USING WS-NAU
     MOVE "implementation 44-7 10.4 an unsaddled nautilus does not dash" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-NAU-DASH(WS-NAU) + WC-NAU-DASH-CD(WS-NAU)
     PERFORM CHECK

*>   Dismount, then a saddle in the hand goes into the saddle slot of the tame adult (not a ride).
     CALL "MOB-RIDE-STOP" USING WS-NAU
     MOVE WS-SADDLE TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.3.1 a saddle in the hand of a tame adult goes into the saddle slot" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-NAU) * 10 + EN-RIDER(WS-NAU)
     PERFORM CHECK
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 step 3 an empty hand on a tame nautilus rides it" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-RIDER(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK

*>   The dash (10.4): flag and cooldown 40 at the command, kept through 6 ticks, cleared on the 7th; the next dash after the cooldown is over.
     MOVE 0 TO WS-DATA
     CALL "TEST-NAU-COMMAND" USING WS-CONN WS-ACTION WS-DATA
     CALL "WC-ROW-OPEN" USING WS-NAU
     MOVE "implementation 44-7 10.4 a jump strength of 0 does not dash" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-NAU-DASH(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 100 TO WS-DATA
     CALL "TEST-NAU-COMMAND" USING WS-CONN WS-ACTION WS-DATA
     MOVE "implementation 44-7 10.4 a saddled ridden nautilus dashes: flag 1 and cooldown 40" TO WS-CASE
     MOVE 140 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-NAU-DASH(WS-NAU) * 100 + WC-NAU-DASH-CD(WS-NAU)
     PERFORM CHECK
     MOVE 6 TO WS-I
     CALL "TEST-TICKS" USING WS-I
     MOVE "implementation 44-7 10.4 after 6 ticks the flag is still set and the cooldown reads 34" TO WS-CASE
     MOVE 134 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-NAU-DASH(WS-NAU) * 100 + WC-NAU-DASH-CD(WS-NAU)
     PERFORM CHECK
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "implementation 44-7 10.4 the 7th tick clears the flag (cooldown 33)" TO WS-CASE
     MOVE 33 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-NAU-DASH(WS-NAU) * 100 + WC-NAU-DASH-CD(WS-NAU)
     PERFORM CHECK
     MOVE 33 TO WS-I
     CALL "TEST-TICKS" USING WS-I
     MOVE "implementation 44-7 10.4 the cooldown reaches 0 forty ticks after the dash" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-NAU-DASH-CD(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     CALL "TEST-NAU-COMMAND" USING WS-CONN WS-ACTION WS-DATA
     MOVE "implementation 44-7 10.4 the next dash is possible once the cooldown is over" TO WS-CASE
     MOVE 140 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-NAU-DASH(WS-NAU) * 100 + WC-NAU-DASH-CD(WS-NAU)
     PERFORM CHECK

*>   The zombie nautilus burns in daylight; the BODY slot is its sun protection (20 section 3.5, 44-7 section 10.1).
     CALL "MOB-RIDE-STOP" USING WS-NAU
     MOVE "zombie_nautilus" TO WS-KEY24
     PERFORM SPAWN-NAUTILUS
     MOVE WS-M TO WS-ZOM
     MOVE 0 TO EN-TAMED(WS-ZOM)
     MOVE 0 TO WS-SEATED
     MOVE 6000 TO CW-TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR EN-BURN(WS-ZOM) > 0
         CALL "TEST-TICKS" USING WS-ONE
     END-PERFORM
     MOVE "implementation 20 3.5 a zombie nautilus under the open sky in daylight catches fire" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-BURN(WS-ZOM) > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE 1 TO WS-EXPECT
     MOVE EN-HEALTH(WS-ZOM) TO WS-SEATED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "TEST-TICKS" USING WS-ONE
     END-PERFORM
     MOVE "implementation 20 3.5 the burning zombie nautilus takes fire damage (on_fire, 1 every 20 ticks)" TO WS-CASE
     MOVE 0 TO WS-OBSERVE
     IF EN-HEALTH(WS-ZOM) < WS-SEATED
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE 0 TO EN-HEALTH(WS-ZOM)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "zombie_nautilus" TO WS-KEY24
     PERFORM SPAWN-NAUTILUS
     MOVE WS-M TO WS-ZOM
     CALL "WC-ROW-OPEN" USING WS-ZOM
     MOVE WS-ARMOR TO WC-BODY(WS-ZOM)
     MOVE 6000 TO CW-TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         CALL "TEST-TICKS" USING WS-ONE
     END-PERFORM
     MOVE "implementation 44-7 10.1 a zombie nautilus wearing BODY armor does not ignite (sunProtectionSlot BODY)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-BURN(WS-ZOM) TO WS-OBSERVE
     PERFORM CHECK
*>   A zombie nautilus that burns down to nothing dies (the fire tick, 1 point every 20 ticks): the step ends there.
     MOVE "zombie_nautilus" TO WS-KEY24
     PERFORM SPAWN-NAUTILUS
     MOVE WS-M TO WS-ZOM
     MOVE WS-ARMOR TO WC-BODY(WS-ZOM)
     MOVE 1 TO EN-HEALTH(WS-ZOM)
     MOVE 200 TO EN-BURN(WS-ZOM)
     MOVE 25 TO WS-I
     CALL "TEST-TICKS" USING WS-I
     MOVE "implementation 20 3.5 a burning zombie nautilus with 1 health is dead after the next fire tick" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-USED(WS-ZOM) = 0 OR EN-HEALTH(WS-ZOM) = 0 OR EN-ID(WS-ZOM) NOT = WS-ID
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     STOP RUN.
*> ITEM-ID: the item id of minecraft:<WS-IDKEY> in WS-IDOUT
 ITEM-ID.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-IDKEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IDOUT WS-ITEM-ROW WS-STATUS.
*> SPAWN-NAUTILUS: a tame adult mob of the key WS-KEY24 two blocks in front of the player, its row in WS-M and its id in WS-ID
 SPAWN-NAUTILUS.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY24) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-M
     MOVE 1 TO EN-TAMED(WS-M)
     MOVE 0 TO EN-MOBAGE(WS-M)
     MOVE EN-ID(WS-M) TO WS-ID.
*> HOLD-ARMOR: one iron nautilus armor in the main hand
 HOLD-ARMOR.
     MOVE WS-ARMOR TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT).
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-NAUTILUS-RIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NAU-COMMAND.
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
 END PROGRAM TEST-NAU-COMMAND.
 COPY CORETEST.
 COPY MOBSPTEST.
