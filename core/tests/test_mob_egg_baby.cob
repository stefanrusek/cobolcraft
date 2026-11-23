*> Implementation test (wrap I2 round 6, T24090; docs/protocol/18-mob-framework.md section 6.12, 25-item-registry-6 section 3.9, 44-residual-mob-questions-7-aquatic.md sections 6.2, 8.2 and 10.1, 44-7 10.3.1
*> step 1a): a spawn egg used (Interact 0x1A, main hand) on a mob of its own type makes a baby of an ageable mob: the baby of getBreedOffspring with the clicked mob as both parents, age -24000, at the
*> mob's position with yaw 0; one egg is used (not in creative); the clicked mob is left alone (no cooldown, no love). A nautilus's baby copies owner and tame flag; a zombie nautilus gives nothing (null
*> offspring) and the egg stays; an egg of another type, a mob that is not ageable (a creeper) and any other item do nothing special. The axolotl's baby is blue with probability 1/1200 (8.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-EGG-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB-KEY             PIC X(40).
 01 WS-EGG-KEY             PIC X(40).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PARENT              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-BABY-ROW            BINARY-LONG.
 01 WS-HAS-BABY            BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SPECIES             PIC X(24).
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-OWNER-A             PIC X(16) VALUE "aaaaaaaa00000001".
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE 0 TO PL-HELD(WS-PLAYER)

*>   The table: which species have an offspring (kind 1 land, 2 water, 3 nautilus, 0 none).
     MOVE "pig" TO WS-SPECIES
     CALL "MOB-EGG-KIND" USING WS-SPECIES WS-KIND
     MOVE "implementation 18 6.12 a pig is an ageable land animal" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-KIND TO WS-OBSERVE
     PERFORM CHECK
     MOVE "squid" TO WS-SPECIES
     CALL "MOB-EGG-KIND" USING WS-SPECIES WS-KIND
     MOVE "implementation 44-7 6.2 a squid is an ageable water creature" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-KIND TO WS-OBSERVE
     PERFORM CHECK
     MOVE "nautilus" TO WS-SPECIES
     CALL "MOB-EGG-KIND" USING WS-SPECIES WS-KIND
     MOVE "implementation 44-7 10.1 a nautilus has an offspring that copies owner and tame" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-KIND TO WS-OBSERVE
     PERFORM CHECK
     MOVE "zombie_nautilus" TO WS-SPECIES
     CALL "MOB-EGG-KIND" USING WS-SPECIES WS-KIND
     MOVE "implementation 44-7 10.1 a zombie nautilus has no offspring (null)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-KIND TO WS-OBSERVE
     PERFORM CHECK
     MOVE "creeper" TO WS-SPECIES
     CALL "MOB-EGG-KIND" USING WS-SPECIES WS-KIND
     MOVE "implementation 18 6.12 a creeper is not an ageable mob" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-KIND TO WS-OBSERVE
     PERFORM CHECK
     MOVE "parrot" TO WS-SPECIES
     CALL "MOB-EGG-KIND" USING WS-SPECIES WS-KIND
     MOVE "implementation 19 parrots do not breed: getBreedOffspring is null" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-KIND TO WS-OBSERVE
     PERFORM CHECK

*>   The axolotl's rare variant (8.2): nextInt(1200) = 0 gives blue (the variant 4, EN-VARIANT 5), else the clicked axolotl's own variant.
     MOVE 0 TO WS-DRAW
     MOVE 3 TO WS-PARENT
     CALL "EGG-AXOLOTL-VARIANT" USING WS-DRAW WS-PARENT WS-CHILD
     MOVE "implementation 44-7 8.2 draw 0 of 1200 is the rare blue variant" TO WS-CASE
     MOVE 5 TO WS-EXPECT
     MOVE WS-CHILD TO WS-OBSERVE
     PERFORM CHECK
     MOVE 1199 TO WS-DRAW
     CALL "EGG-AXOLOTL-VARIANT" USING WS-DRAW WS-PARENT WS-CHILD
     MOVE "implementation 44-7 8.2 any other draw keeps the parent's variant (the coin picks one of two copies)" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-CHILD TO WS-OBSERVE
     PERFORM CHECK

*>   A pig egg on a pig: a baby pig at the pig's position, one egg used, the pig unchanged.
     MOVE "pig" TO WS-MOB-KEY
     PERFORM SPAWN-MOB
     MOVE WS-PARENT TO WS-ID
     MOVE "pig_spawn_egg" TO WS-EGG-KEY
     PERFORM GIVE-EGG
     PERFORM COUNT-MOBS
     MOVE WS-COUNT TO WS-BEFORE
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-PARENT) WS-HAND0 WS-SNEAK0
     PERFORM COUNT-MOBS
     MOVE "implementation 18 6.12 a pig egg on a pig makes one more pig" TO WS-CASE
     COMPUTE WS-EXPECT = WS-BEFORE + 1
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK
     PERFORM FIND-BABY
     MOVE "implementation 44-7 6.2 the child is a baby of age -24000" TO WS-CASE
     MOVE -24000 TO WS-EXPECT
     MOVE EN-MOBAGE(WS-BABY-ROW) TO WS-OBSERVE
     PERFORM CHECK
     CALL "MOB-DATA-VALUES" USING WS-BABY-ROW WS-BABY WS-WOOL WS-NEEDED
     MOVE "implementation 44-7 6.2 the child sends the baby flag" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-BABY TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 6.2 the child is placed at the clicked mob's position" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-X(WS-BABY-ROW) = EN-X(WS-PARENT) AND EN-Y(WS-BABY-ROW) = EN-Y(WS-PARENT) AND EN-Z(WS-BABY-ROW) = EN-Z(WS-PARENT)
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 44-7 6.2 one egg is used" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 6.2 the clicked pig is not bred: no cooldown age, no love" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-MOBAGE(WS-PARENT) + EN-LOVE(WS-PARENT)
     PERFORM CHECK
     IF WS-HAS-BABY = 1
         CALL "ENTITY-REMOVE" USING WS-BABY-ROW
     END-IF

*>   A pig egg on a cow (another type), and on a pig with another item in hand: nothing is born, the egg stays.
     CALL "ENTITY-REMOVE" USING WS-PARENT
     MOVE "cow" TO WS-MOB-KEY
     PERFORM SPAWN-MOB
     MOVE "pig_spawn_egg" TO WS-EGG-KEY
     PERFORM GIVE-EGG
     PERFORM COUNT-ALL
     MOVE WS-COUNT TO WS-BEFORE
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-PARENT) WS-HAND0 WS-SNEAK0
     PERFORM COUNT-ALL
     MOVE "implementation 25-6 3.9 an egg of another type makes no baby" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 25-6 3.9 and the egg stays" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-PARENT

*>   A sheep egg on a sheep: the baby has the sheep's colour (both parents are the sheep).
     MOVE "sheep" TO WS-MOB-KEY
     PERFORM SPAWN-MOB
     MOVE 5 TO EN-WOOL(WS-PARENT)
     MOVE "sheep_spawn_egg" TO WS-EGG-KEY
     PERFORM GIVE-EGG
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-PARENT) WS-HAND0 WS-SNEAK0
     PERFORM FIND-BABY
     MOVE "implementation 18 6.12 a sheep egg on a sheep makes a baby sheep of the same colour" TO WS-CASE
     MOVE -240005 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-MOBAGE(WS-BABY-ROW) * 10 - EN-WOOL(WS-BABY-ROW)
     PERFORM CHECK
     IF WS-HAS-BABY = 1
         CALL "ENTITY-REMOVE" USING WS-BABY-ROW
     END-IF
     CALL "ENTITY-REMOVE" USING WS-PARENT

*>   A nautilus egg on a tame nautilus: a baby with the owner and the tame flag.
     MOVE "nautilus" TO WS-MOB-KEY
     PERFORM SPAWN-MOB
     MOVE 1 TO EN-TAMED(WS-PARENT)
     MOVE WS-OWNER-A TO EN-OWNER-UUID(WS-PARENT)
     MOVE "nautilus_spawn_egg" TO WS-EGG-KEY
     PERFORM GIVE-EGG
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-PARENT) WS-HAND0 WS-SNEAK0
     PERFORM FIND-BABY
     MOVE "implementation 44-7 6.2 a nautilus egg on a nautilus makes a baby nautilus" TO WS-CASE
     MOVE -24000 TO WS-EXPECT
     MOVE EN-MOBAGE(WS-BABY-ROW) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 6.2 the nautilus child copies the tame flag and the owner" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-TAMED(WS-BABY-ROW) = 1
         ADD 1 TO WS-OBSERVE
     END-IF
     IF EN-OWNER-UUID(WS-BABY-ROW) = WS-OWNER-A
         ADD 10 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     IF WS-HAS-BABY = 1
         CALL "ENTITY-REMOVE" USING WS-BABY-ROW
     END-IF
     CALL "ENTITY-REMOVE" USING WS-PARENT

*>   A zombie nautilus egg on a zombie nautilus: nothing is spawned and the egg stays.
     MOVE "zombie_nautilus" TO WS-MOB-KEY
     PERFORM SPAWN-MOB
     MOVE "zombie_nautilus_spawn_egg" TO WS-EGG-KEY
     PERFORM GIVE-EGG
     PERFORM COUNT-ALL
     MOVE WS-COUNT TO WS-BEFORE
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-PARENT) WS-HAND0 WS-SNEAK0
     PERFORM COUNT-ALL
     MOVE "implementation 44-7 6.2 a zombie nautilus gives no offspring: nothing is spawned" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 6.2 and no egg is used" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-PARENT

*>   A squid egg on a squid: a baby squid (a water creature, the baby flag goes to the viewers).
     MOVE "squid" TO WS-MOB-KEY
     PERFORM SPAWN-MOB
     MOVE "squid_spawn_egg" TO WS-EGG-KEY
     PERFORM GIVE-EGG
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-PARENT) WS-HAND0 WS-SNEAK0
     PERFORM FIND-BABY
     MOVE "implementation 44-7 6.2 a squid egg on a squid makes a baby squid of age -24000" TO WS-CASE
     MOVE -24000 TO WS-EXPECT
     MOVE EN-MOBAGE(WS-BABY-ROW) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 6.2 and one egg is used" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK
     IF WS-HAS-BABY = 1
         CALL "ENTITY-REMOVE" USING WS-BABY-ROW
     END-IF
     CALL "ENTITY-REMOVE" USING WS-PARENT

*>   An axolotl egg on a cyan axolotl: a baby axolotl that is cyan (or, 1 in 1200, blue), persistent.
     MOVE "axolotl" TO WS-MOB-KEY
     PERFORM SPAWN-MOB
     MOVE 4 TO EN-VARIANT(WS-PARENT)
     MOVE "axolotl_spawn_egg" TO WS-EGG-KEY
     PERFORM GIVE-EGG
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-PARENT) WS-HAND0 WS-SNEAK0
     PERFORM FIND-BABY
     MOVE "implementation 44-7 8.2 an axolotl egg on an axolotl makes a baby axolotl of age -24000" TO WS-CASE
     MOVE -24000 TO WS-EXPECT
     MOVE EN-MOBAGE(WS-BABY-ROW) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 8.2 its variant is the parent's (cyan, EN-VARIANT 4) or blue (EN-VARIANT 5)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-HAS-BABY = 1 AND (EN-VARIANT(WS-BABY-ROW) = 4 OR EN-VARIANT(WS-BABY-ROW) = 5)
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 44-7 8.2 the child is made persistent" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-PERSISTENT(WS-BABY-ROW) TO WS-OBSERVE
     PERFORM CHECK
     IF WS-HAS-BABY = 1
         CALL "ENTITY-REMOVE" USING WS-BABY-ROW
     END-IF
     CALL "ENTITY-REMOVE" USING WS-PARENT

*>   A creeper egg on a creeper: not an ageable mob, nothing happens to the egg here.
     MOVE "creeper" TO WS-MOB-KEY
     PERFORM SPAWN-MOB
     MOVE "creeper_spawn_egg" TO WS-EGG-KEY
     PERFORM GIVE-EGG
     PERFORM COUNT-ALL
     MOVE WS-COUNT TO WS-BEFORE
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-PARENT) WS-HAND0 WS-SNEAK0
     PERFORM COUNT-ALL
     MOVE "implementation 18 6.12 a creeper egg on a creeper spawns nothing" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 18 6.12 and the egg stays" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-PARENT

*>   A creative player keeps the egg stack.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "pig" TO WS-MOB-KEY
     PERFORM SPAWN-MOB
     MOVE "pig_spawn_egg" TO WS-EGG-KEY
     PERFORM GIVE-EGG
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-PARENT) WS-HAND0 WS-SNEAK0
     PERFORM FIND-BABY
     MOVE "implementation 18 6.12 in creative mode the baby is born and the egg stack stays" TO WS-CASE
     MOVE 13 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HAS-BABY * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK
     STOP RUN.
*> SPAWN-MOB: a mob of WS-MOB-KEY two blocks in front of the player (the reach); its row in WS-PARENT
 SPAWN-MOB.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE WS-MOB-KEY DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PARENT.
*> GIVE-EGG: three of the item <WS-EGG-KEY> in the first hotbar slot
 GIVE-EGG.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE WS-EGG-KEY DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I WS-ITEM-ROW WS-STATUS
     MOVE WS-I TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 1).
*> COUNT-MOBS: the number of mobs of the type of WS-PARENT (WS-COUNT)
 COUNT-MOBS.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = EN-TYPE(WS-PARENT)
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
*> COUNT-ALL: the number of used rows that are no player (WS-COUNT)
 COUNT-ALL.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
*> FIND-BABY: the row of the same type that is not WS-PARENT (WS-HAS-BABY 1); without one WS-BABY-ROW is WS-PARENT so that the checks read a real row and fail by their values
 FIND-BABY.
     MOVE 0 TO WS-HAS-BABY
     MOVE WS-PARENT TO WS-BABY-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = EN-TYPE(WS-PARENT) AND WS-I NOT = WS-PARENT
             MOVE WS-I TO WS-BABY-ROW
             MOVE 1 TO WS-HAS-BABY
         END-IF
     END-PERFORM.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-EGG-BABY.
 COPY CORETEST.
 COPY MOBSPTEST.
