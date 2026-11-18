*> Acceptance test (US14; docs/protocol/17 section 3.13 elytra and fireworks, 05c Player Command 0x2A START_FALL_FLYING, 18 section 1.4 flag 7): gliding and firework rockets through the real
*> play path. Player Command START_FALL_FLYING starts gliding when an elytra that the next point of damage would not break is worn, the player is not gliding already, not in water and
*> without Levitation (the pose becomes fall flying and the shared flag 0x80 is set); every 20 ticks of flight the elytra takes 1 durability (the glide counter n at 10 and 20: n / 10 even),
*> landing (the on-ground flag) or taking the elytra off ends the flight. Use Item with a firework rocket while gliding launches it attached to the player and uses one up; each tick it
*> pushes the glider by look x 0.1 + (look x 1.5 - velocity) x 0.5 (Set Entity Motion); Use Item On a block puts the rocket at the click point 0.15 off the face.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-ELYTRA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY CMENU.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ROCKET-TYPE         BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-LEVITATION          BINARY-LONG VALUE 24.
 01 WS-C71                 BINARY-LONG VALUE 71.
 01 WS-FIREWORKS           PIC X(64).
 01 WS-FIREWORKS-LENGTH    BINARY-LONG VALUE 2.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-FACES-OK            BINARY-LONG.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 200.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-WATER-KEY           PIC X(112) VALUE "minecraft:water".
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     MOVE "firework_rocket" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-ROCKET-TYPE
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     PERFORM FRESH
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   Without an elytra nothing starts.
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 3)
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     MOVE "acceptance US14 17 3.13 START_FALL_FLYING without an elytra worn starts nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE TS-GLIDE-TICKS(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N

*>   With one: gliding, the fall flying pose and the flag 0x80.
     PERFORM FRESH
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     MOVE "acceptance US14 17 3.13 START_FALL_FLYING with an elytra worn starts the glide (glide counter 1)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE TS-GLIDE-TICKS(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US14 18 1.4 the glider is in the fall flying pose (1) with the shared flag 0x80 (128)" TO WS-CASE
     MOVE 129 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-POSE(WS-PLAYER) + PL-POSE-FLAGS(WS-PLAYER)
     PERFORM CHECK-N

*>   Durability: 1 point per 20 ticks.
     MOVE 19 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-EQUIP-DAMAGE" USING WS-PLAYER WS-DAMAGE
     MOVE "acceptance US14 17 3.13 after 19 ticks of flight the elytra is unworn" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-EQUIP-DAMAGE" USING WS-PLAYER WS-DAMAGE
     MOVE "acceptance US14 17 3.13 at the 20th tick (n = 20, n / 10 even) the elytra loses 1 durability" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-EQUIP-DAMAGE" USING WS-PLAYER WS-DAMAGE
     MOVE "acceptance US14 17 3.13 at the 40th tick it has lost 2" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N

*>   Landing ends the flight and the pose.
     MOVE 1 TO PL-ON-GROUND(WS-PLAYER)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US14 17 3.13 touching the ground ends the glide: counter 0, standing pose, no flag" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = TS-GLIDE-TICKS(WS-PLAYER) + PL-POSE(WS-PLAYER) + PL-POSE-FLAGS(WS-PLAYER)
     PERFORM CHECK-N

*>   Taking the elytra off ends it too.
     PERFORM FRESH
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 3)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US14 17 3.13 without the elytra the glide ends at the next tick" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE TS-GLIDE-TICKS(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N

*>   An elytra that the next damage would break cannot be used; Levitation and water forbid it too; a glider cannot start twice.
     PERFORM FRESH
     MOVE 431 TO WS-DAMAGE
     MOVE MN-EQUIP-VAR(WS-PLAYER, 3) TO WS-HANDLE
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE
     MOVE WS-HANDLE TO MN-EQUIP-VAR(WS-PLAYER, 3)
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     MOVE "acceptance US14 17 3.13 an elytra with 431 of 432 damage cannot be used to glide (the next point would break it)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE TS-GLIDE-TICKS(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM FRESH
     CALL "EFFECT-ADD" USING WS-PLAYER WS-LEVITATION WS-AMPLIFIER WS-DURATION WS-FLAGS
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     MOVE "acceptance US14 17 3.13 Levitation forbids gliding" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE TS-GLIDE-TICKS(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "EFFECT-CLEAR-ALL" USING WS-PLAYER
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-WATER-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING PL-DIM(WS-PLAYER) WS-CX WS-Y WS-CZ WS-STATE
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     MOVE "acceptance US14 17 3.13 a player standing in water cannot start gliding" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE TS-GLIDE-TICKS(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING PL-DIM(WS-PLAYER) WS-CX WS-Y WS-CZ WS-AIR
     PERFORM FRESH
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     MOVE "acceptance US14 17 3.13 START_FALL_FLYING while gliding does not restart the counter (11 after 10 ticks)" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     MOVE TS-GLIDE-TICKS(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N

*>   Rockets: Use Item while gliding launches one, attached to the player, and uses it up; not gliding it does nothing.
     PERFORM FRESH
     MOVE "firework_rocket" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-THREE
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "RT-COUNT" USING WS-ROCKET-TYPE WS-COUNT WS-ROW
     MOVE "acceptance US14 17 3.13 Use Item with a rocket while not gliding does nothing: no rocket entity, three in the hand" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) + WS-COUNT * 10
     PERFORM CHECK-N
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "RT-COUNT" USING WS-ROCKET-TYPE WS-COUNT WS-ROW
     MOVE 0 TO WS-SLOT
     IF WS-COUNT = 1
         CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     END-IF
     MOVE "acceptance US14 17 3.13 Use Item with a rocket while gliding launches one rocket attached to the player and uses one up" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 1 AND WS-SLOT > 0 AND PL-SLOT-COUNT(WS-PLAYER, 1) = 2
         IF PJ-I4(WS-SLOT) = PL-ENTITY-ID(WS-PLAYER) AND PJ-OWNER(WS-SLOT) = PL-ENTITY-ID(WS-PLAYER)
             MOVE 1 TO WS-OBSERVE
         END-IF
     END-IF
     PERFORM CHECK-N
*>   The boost of the next tick: the glider was at rest (the step from the last tick's position is 0), so it gets look x 0.1 + look x 1.5 x 0.5 = 0.85 along +z.
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-MOTION" USING WS-CONN WS-FOUND WS-VX WS-VY WS-VZ
     MOVE "acceptance US14 17 3.13 the attached rocket pushes the glider: Set Entity Motion of 0.85 along the look (millis 840 to 860)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-FOUND = 1 AND WS-VZ > 0.84 AND WS-VZ < 0.86 AND WS-VX > -0.01 AND WS-VX < 0.01 AND WS-VY > -0.01 AND WS-VY < 0.01
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N

*>   Use Item On a block: the rocket at the click point, 0.15 off the face (up), not attached; one is used up.
     PERFORM FRESH
     MOVE "firework_rocket" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-THREE
     MOVE WS-CX TO WS-BX
     MOVE WS-FLOOR TO WS-BY
     MOVE WS-CZ TO WS-BZ
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-BY WS-BZ WS-FACE WS-ONE
     CALL "RT-COUNT" USING WS-ROCKET-TYPE WS-COUNT WS-ROW
     MOVE 0 TO WS-SLOT
     IF WS-COUNT = 1
         CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     END-IF
     MOVE "acceptance US14 17 3.13 Use Item On the floor puts one rocket 0.65 above the block (cursor 0.5 + 0.15 off the face), not attached, one used up" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 1 AND WS-SLOT > 0 AND PL-SLOT-COUNT(WS-PLAYER, 1) = 2 AND PJ-I4(WS-SLOT) = 0
         IF EN-Y(WS-ROW) > WS-FLOOR + 0.64 AND EN-Y(WS-ROW) < WS-FLOOR + 0.66 AND EN-X(WS-ROW) > WS-CX + 0.49 AND EN-X(WS-ROW) < WS-CX + 0.51
             MOVE 1 TO WS-OBSERVE
         END-IF
     END-IF
     PERFORM CHECK-N

*>   The fireworks component of the stack (type 71: flight duration 3, one explosion) sets the rocket's lifetime (at least 10 x (3 + 1)) and its stars.
     PERFORM FRESH
     MOVE "firework_rocket" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-THREE
     MOVE X"0301" TO WS-FIREWORKS
     MOVE 0 TO WS-HANDLE
     CALL "SP-SET-COMPONENT" USING WS-HANDLE WS-C71 WS-FIREWORKS WS-FIREWORKS-LENGTH
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-SIX
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "RT-COUNT" USING WS-ROCKET-TYPE WS-COUNT WS-ROW
     MOVE 0 TO WS-SLOT
     IF WS-COUNT = 1
         CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     END-IF
     MOVE "acceptance US14 17 3.13 a rocket with flight duration 3 and one explosion lives at least 40 ticks and has 1 star" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 1 AND WS-SLOT > 0
         IF PJ-I2(WS-SLOT) >= 40 AND PJ-I2(WS-SLOT) <= 51 AND PJ-I3(WS-SLOT) = 1
             MOVE 1 TO WS-OBSERVE
         END-IF
     END-IF
     PERFORM CHECK-N

*>   An attached rocket whose player is no longer gliding rides along without pushing; one attached to nobody does nothing.
     MOVE PL-X(WS-PLAYER) TO TS-GLIDE-LAST-X(WS-PLAYER)
     MOVE 1 TO PL-ON-GROUND(WS-PLAYER)
     MOVE 1 TO WS-TICKS
*>   The tick in which the glide ends still pushes (the rocket moves before the glide is checked); the next ones do not.
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-MOTION" USING WS-CONN WS-FOUND WS-VX WS-VY WS-VZ
     MOVE "acceptance US14 17 3.13 a landed glider (counter 0) is no longer pushed by its rocket: no Set Entity Motion in the next ticks" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 999999 TO PJ-I4(WS-SLOT)
     CALL "TEST-TICKS" USING WS-ONE
     CALL "RT-MOTION" USING WS-CONN WS-FOUND WS-VX WS-VY WS-VZ
     MOVE "acceptance US14 17 3.13 a rocket attached to an entity that is no player pushes nobody" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N

*>   Use Item On each face: the click point (cursor 0.5, 0.5, 0.5) moved 0.15 along the face's normal.
     MOVE 1 TO WS-FACES-OK
     PERFORM VARYING WS-FACE FROM 0 BY 1 UNTIL WS-FACE > 5
         PERFORM FRESH
         MOVE "firework_rocket" TO WS-KEY
         CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-THREE
         MOVE WS-CX TO WS-BX
         MOVE WS-FLOOR TO WS-BY
         MOVE WS-CZ TO WS-BZ
         CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-BY WS-BZ WS-FACE WS-ONE
         CALL "RT-COUNT" USING WS-ROCKET-TYPE WS-COUNT WS-ROW
         COMPUTE WS-EX = WS-BX + 0.5
         COMPUTE WS-EY = WS-BY + 0.5
         COMPUTE WS-EZ = WS-BZ + 0.5
         EVALUATE WS-FACE
             WHEN 0
                 COMPUTE WS-EY = WS-EY - 0.15
             WHEN 1
                 COMPUTE WS-EY = WS-EY + 0.15
             WHEN 2
                 COMPUTE WS-EZ = WS-EZ - 0.15
             WHEN 3
                 COMPUTE WS-EZ = WS-EZ + 0.15
             WHEN 4
                 COMPUTE WS-EX = WS-EX - 0.15
             WHEN OTHER
                 COMPUTE WS-EX = WS-EX + 0.15
         END-EVALUATE
         IF WS-COUNT NOT = 1
             MOVE 0 TO WS-FACES-OK
         ELSE
             IF FUNCTION ABS(EN-X(WS-ROW) - WS-EX) > 0.01 OR FUNCTION ABS(EN-Y(WS-ROW) - WS-EY) > 0.01
                     OR FUNCTION ABS(EN-Z(WS-ROW) - WS-EZ) > 0.01
                 MOVE 0 TO WS-FACES-OK
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US14 17 3.13 Use Item On each of the six faces puts the rocket 0.15 off that face of the click point" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FACES-OK TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

*> An elytra in the chest slot (fresh, no damage); the player airborne in survival, not gliding, nothing in the hands.
 FRESH.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     MOVE "elytra" TO WS-KEY
     CALL "RT-ITEM-ID" USING WS-KEY MN-EQUIP-ITEM(WS-PLAYER, 3)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 3)
     MOVE 0 TO MN-EQUIP-VAR(WS-PLAYER, 3)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO PL-ON-GROUND(WS-PLAYER)
     MOVE 0 TO TS-GLIDE-TICKS(WS-PLAYER)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     CALL "RT-CLEAR-TYPE" USING WS-ROCKET-TYPE.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-ELYTRA.
 COPY CORETEST.
 COPY RANGEDTEST.
