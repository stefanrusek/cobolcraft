*> Acceptance test (US14; docs/protocol/17 section 3.10 trident, 25 part 7 section 7): the trident through the real play path. Use Item starts the use unless the next point of damage
*> would break the trident (or Riptide is on it and the player is dry); Player Action 6 after at least 10 ticks throws it at velocity 2.5 (the trident takes 1 durability and leaves
*> the hand, a creative player keeps it and the thrown one can only be picked up in creative mode); the thrown trident hurts what it hits by 8.0 once and is deflected, sticks in a
*> block, is picked up again with its damage, or with Loyalty flies back to its owner; Riptide in water launches the player (Set Entity Motion) and the spin of 20 ticks hurts what
*> the player touches by 8.0 instead of a throw.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-TRIDENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY CITEMS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-TRIDENT-TYPE        BINARY-LONG.
 01 WS-TRIDENT-ITEM        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-ENCH-KEY            PIC X(112).
 01 WS-HANDLE              BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HAYSTACK            PIC X(1026).
 01 WS-HITS                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG VALUE 0.
 01 WS-DZ                  FLOAT-LONG VALUE 3.
 01 WS-DZ1                 FLOAT-LONG VALUE 0.7.
 01 WS-WATER-KEY           PIC X(112) VALUE "minecraft:water".
 01 WS-WATER               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-LOSS                BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     MOVE "trident" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-TRIDENT-TYPE
     CALL "RT-ITEM-ID" USING WS-KEY WS-TRIDENT-ITEM
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     PERFORM FRESH
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   A use shorter than 10 ticks throws nothing.
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 9 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-ACTION" USING WS-CONN WS-SIX WS-ZERO WS-ZERO WS-ZERO WS-ZERO WS-ZERO
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     MOVE "acceptance US14 17 3.10 released after 9 ticks the trident is not thrown: no entity, still in the hand" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) - WS-COUNT
     PERFORM CHECK-N

*>   A throw after 10 ticks.
     PERFORM THROW-10
     COMPUTE WS-SPEED = FUNCTION INTEGER(FUNCTION SQRT(EN-VX(WS-ROW) * EN-VX(WS-ROW) + EN-VY(WS-ROW) * EN-VY(WS-ROW)
         + EN-VZ(WS-ROW) * EN-VZ(WS-ROW)) * 1000)
     MOVE "acceptance US14 17 3.10 a trident released after 10 ticks flies at 2.5 (millis 2400 to 2600), owned by the thrower, pickup mode 1" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 1 AND WS-SPEED >= 2400 AND WS-SPEED <= 2600 AND EN-TARGET-ID(WS-ROW) = PL-ENTITY-ID(WS-PLAYER)
             AND EN-ARR-PICKUP(WS-ROW) = 1 AND EN-IS-TRIDENT(WS-ROW) = 1
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US14 17 3.10 the thrown trident leaves the hand (survival)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "SP-SWEEP"
     MOVE "acceptance US14 17 3.10 the thrown stack keeps its 1 durability damage through a sweep of the patch pool" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     CALL "SP-GET-DAMAGE" USING WS-TRIDENT-ITEM EN-TR-VAR(WS-ROW) WS-DAMAGE
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N

*>   Creative keeps the trident, the thrown one is for creative players only.
     PERFORM FRESH
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM THROW-10
     MOVE "acceptance US14 17 3.10 a creative player keeps the trident, the thrown one has pickup mode 2 and the held one no damage" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 1 AND EN-ARR-PICKUP(WS-ROW) = 2 AND PL-SLOT-COUNT(WS-PLAYER, 1) = 1 AND WS-DAMAGE = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N

*>   A hit: 8 points, once, and the trident is deflected backwards.
     PERFORM FRESH
     MOVE "cow" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW
     MOVE 100 TO EN-HEALTH(WS-COW)
     MOVE 5 TO PL-PITCH(WS-PLAYER)
     PERFORM THROW-10
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     COMPUTE WS-LOSS = 100 - EN-HEALTH(WS-COW)
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     MOVE "acceptance US14 17 3.10 the thrown trident hurts the cow by 8.0 (8 points), has dealt its damage and is deflected back (vz below 0)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-LOSS = 8 AND WS-COUNT = 1 AND EN-TR-DEALT(WS-ROW) = 1 AND EN-VZ(WS-ROW) < 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     COMPUTE WS-LOSS = 100 - EN-HEALTH(WS-COW)
     MOVE "acceptance US14 17 3.10 it deals its damage once: five ticks later the cow has still lost 8" TO WS-CASE
     MOVE 8 TO WS-EXPECT
     MOVE WS-LOSS TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-COW
     MOVE 0 TO PL-PITCH(WS-PLAYER)

*>   A trident that sticks in the floor is picked up again with its damage.
     PERFORM FRESH
     MOVE 60 TO PL-PITCH(WS-PLAYER)
     PERFORM THROW-10
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     CALL "SP-SWEEP"
     MOVE 0 TO WS-DAMAGE
     IF PL-SLOT-COUNT(WS-PLAYER, 1) = 1
         CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     END-IF
     MOVE "acceptance US14 17 3.10 a trident stuck in the floor next to its owner is picked up after the shake time: back in the hand with 1 damage, entity gone" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + WS-DAMAGE + WS-COUNT * 100
     PERFORM CHECK-N
     MOVE 0 TO PL-PITCH(WS-PLAYER)

*>   Loyalty I: after the hit the trident comes back to the owner by itself.
     PERFORM FRESH
     MOVE "minecraft:loyalty" TO WS-ENCH-KEY
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-ONE
     MOVE "cow" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW
     MOVE 100 TO EN-HEALTH(WS-COW)
     MOVE 5 TO PL-PITCH(WS-PLAYER)
     PERFORM THROW-10
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     MOVE "acceptance US14 17 3.10 Loyalty I: after the hit the trident is flying home (no physics, state 2)" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 1
         MOVE EN-ON-GROUND(WS-ROW) TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE 80 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     MOVE "acceptance US14 17 3.10 Loyalty I: it reaches the player, who has the trident back in the hand with its damage and the entity is gone" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     IF WS-COUNT = 0 AND PL-SLOT-COUNT(WS-PLAYER, 1) = 1 AND WS-DAMAGE = 1
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-COW

*>   Impaling III adds 7.5 against an aquatic mob (a cod): 8 + 7.5 = 15.5, 16 points.
     PERFORM FRESH
     MOVE "minecraft:impaling" TO WS-ENCH-KEY
     MOVE 3 TO WS-THREE
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-THREE
     MOVE "cod" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW
     MOVE 100 TO EN-HEALTH(WS-COW)
*>   The cod hops about on dry land, so the hit is fed to TRIDENT-HIT directly with a trident thrown by TRIDENT-SPAWN (the flight is covered above).
     CALL "TRIDENT-SPAWN" USING WS-PLAYER WS-TRIDENT-ITEM PL-SLOT-VAR(WS-PLAYER, 1) WS-ROW
     MOVE 0 TO WS-ZERO
     CALL "TRIDENT-HIT" USING WS-ROW WS-COW WS-ZERO
     COMPUTE WS-LOSS = 100 - EN-HEALTH(WS-COW)
     MOVE "acceptance US14 17 6.3 Impaling III: a thrown trident hurts a cod by 8 + 7.5, 16 points" TO WS-CASE
     MOVE 16 TO WS-EXPECT
     MOVE WS-LOSS TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-COW
     MOVE 0 TO PL-PITCH(WS-PLAYER)

*>   A trident that flies home to an owner who is gone drops as an item.
     PERFORM FRESH
     MOVE "minecraft:loyalty" TO WS-ENCH-KEY
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-ONE
     PERFORM THROW-10
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     IF WS-COUNT = 0
         MOVE 1 TO WS-ROW
     END-IF
     MOVE 0 TO EN-TARGET-ID(WS-ROW)
     MOVE 2 TO EN-ON-GROUND(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     MOVE 0 TO WS-LOSS
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM AND EN-ITEM(WS-ROW) = WS-TRIDENT-ITEM
             ADD 1 TO WS-LOSS
         END-IF
     END-PERFORM
     MOVE "acceptance US14 17 3.10 a returning trident whose owner is gone is discarded and drops its item" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-LOSS - WS-COUNT
     PERFORM CHECK-N
     MOVE 0 TO PL-PITCH(WS-PLAYER)

*>   A trident that would break with the next point of damage cannot be used.
     PERFORM FRESH
     MOVE 249 TO WS-DAMAGE
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-ACTION" USING WS-CONN WS-SIX WS-ZERO WS-ZERO WS-ZERO WS-ZERO WS-ZERO
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     MOVE "acceptance US14 17 3.10 a trident with 249 of 250 damage cannot be thrown (the next point would break it)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) - WS-COUNT
     PERFORM CHECK-N

*>   Riptide I needs water: dry, the use does not even start.
     PERFORM FRESH
     MOVE "minecraft:riptide" TO WS-ENCH-KEY
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-ONE
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-ACTION" USING WS-CONN WS-SIX WS-ZERO WS-ZERO WS-ZERO WS-ZERO WS-ZERO
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 17 3.10 Riptide on dry land: nothing is thrown, nothing worn" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + WS-COUNT + WS-DAMAGE
     PERFORM CHECK-N

*>   In water: launched along the look vector by 1.5, the trident stays, 1 durability, the spin hurts a cow touched by 8.
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-WATER-KEY WS-WATER WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING PL-DIM(WS-PLAYER) WS-CX WS-Y WS-CZ WS-STATE
     MOVE "cow" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ1 WS-COW
     MOVE 100 TO EN-HEALTH(WS-COW)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-ACTION" USING WS-CONN WS-SIX WS-ZERO WS-ZERO WS-ZERO WS-ZERO WS-ZERO
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE SPACES TO WS-HAYSTACK
     STRING " " WS-IDS " " DELIMITED BY SIZE INTO WS-HAYSTACK
     MOVE 0 TO WS-HITS
     INSPECT WS-HAYSTACK TALLYING WS-HITS FOR ALL " 103 "
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 17 3.10 Riptide in water: no trident entity, the trident stays in the hand with 1 damage, the player gets Set Entity Motion (0x67)" TO WS-CASE
     MOVE 1101 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HITS * 1000 + PL-SLOT-COUNT(WS-PLAYER, 1) * 100 + WS-COUNT * 10 + WS-DAMAGE
     PERFORM CHECK-N
     MOVE "acceptance US14 17 3.10 Riptide starts a spin of 20 ticks" TO WS-CASE
     MOVE 20 TO WS-EXPECT
     MOVE TS-SPIN-TICKS(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     COMPUTE WS-LOSS = 100 - EN-HEALTH(WS-COW)
     MOVE "acceptance US14 17 3.10 the spin hurts the cow the player touches by 8.0" TO WS-CASE
     MOVE 8 TO WS-EXPECT
     MOVE WS-LOSS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 25 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US14 17 3.10 after 25 ticks the spin is over" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE TS-SPIN-TICKS(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

*> A fresh trident in slot 1 and the player in survival; no tridents in the world.
 FRESH.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     MOVE "trident" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "RT-CLEAR-TYPE" USING WS-TRIDENT-TYPE.

*> Use Item, 10 ticks, release; WS-COUNT tridents exist and WS-ROW is the last (row 1 when there is none).
 THROW-10.
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-ACTION" USING WS-CONN WS-SIX WS-ZERO WS-ZERO WS-ZERO WS-ZERO WS-ZERO
     CALL "RT-COUNT" USING WS-TRIDENT-TYPE WS-COUNT WS-ROW
     IF WS-COUNT = 0
         MOVE 1 TO WS-ROW
     END-IF.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-TRIDENT.
 COPY CORETEST.
 COPY RANGEDTEST.
