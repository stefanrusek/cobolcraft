*> Implementation test (wrap I2, T2450 and T2506; docs/protocol/20-mobs-overworld-hostile.md sections 4.3, 4.4 and 18.3, 19-mobs-land-friendly-and-neutral.md sections 3.6 and 3.8): the rows of the camel husk,
*> the zombie horse and the skeleton horse (health, the spawn genes of 3.2 and 3.6, the surface-monster rule), the camel husk's spawn box, the natural husk that rides a camel husk (one attempt per
*> group, iron spear, probability 0.1), the zombie horse's zombie jockey, a player's mount of each (an untamed skeleton horse refuses), and the interaction of a hostile-category mount.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-MOUNT-ROWS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY WCSTATE.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 24.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-HUSK-TYPE           BINARY-LONG.
 01 WS-CAMEL-TYPE          BINARY-LONG.
 01 WS-ZH-TYPE             BINARY-LONG.
 01 WS-SH-TYPE             BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-HUSK                BINARY-LONG.
 01 WS-CAMEL               BINARY-LONG.
 01 WS-ZH                  BINARY-LONG.
 01 WS-SH                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-STARTED             BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-EMPTY               PIC X(24) VALUE SPACES.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-JUMP                FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-IN-PACK             BINARY-LONG.
 01 WS-FEED-FOUND          BINARY-LONG.
 01 WS-FEED-SECONDS        BINARY-LONG.
 01 WS-FEED-LOVE           BINARY-LONG.
 01 WS-FEED-TAME           BINARY-LONG.
 01 WS-SPECIES             PIC X(24).
 01 WS-ITEM                PIC X(24).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE 0 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 12
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "minecraft:husk" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HUSK-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:camel_husk" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CAMEL-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie_horse" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZH-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:skeleton_horse" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SH-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 3

*>   The rows: a mount of each kind has a table row with the document's health.
     CALL "MOB-SPAWN" USING WS-DIM WS-CAMEL-TYPE WS-X WS-Y WS-Z WS-YAW WS-CAMEL
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-CAMEL) WS-M
     MOVE "acceptance US15 minecraft:camel_husk 20 4.4 the row has max health 32, the monster kind and the surface-monster rule 5" TO TL-CASE
     MOVE 32115 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-M) * 1000 + SM-KIND(WS-M) * 100 + SM-SPAWN(WS-M) * 3 - 0
     IF WS-M = 0
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-SPAWN" USING WS-DIM WS-ZH-TYPE WS-X WS-Y WS-Z WS-YAW WS-ZH
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ZH) WS-M
     MOVE "acceptance US15 minecraft:zombie_horse 19 3.6 the row has max health 25 and the monster kind" TO TL-CASE
     MOVE 25100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-M) * 1000 + SM-KIND(WS-M) * 100
     IF WS-M = 0
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-SPAWN" USING WS-DIM WS-SH-TYPE WS-X WS-Y WS-Z WS-YAW WS-SH
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-SH) WS-M
     MOVE "acceptance US15 minecraft:skeleton_horse 19 3.6 the row has max health 15 and the creature kind" TO TL-CASE
     MOVE 15000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-M) * 1000 + SM-KIND(WS-M) * 100
     IF WS-M = 0
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The genes: the zombie horse jump 0.5 to 0.7 and speed 0.2134 to 0.2845 (3.6), the skeleton horse jump 0.4 to 1.0 (3.2).
     CALL "WC-ROW-OPEN" USING WS-ZH
     MOVE "acceptance US15 minecraft:zombie_horse 19 3.6 the spawn genes: jump 0.5 to 0.7, speed 0.2134 to 0.2845" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HORSE-JUMP(WS-ZH) >= 0.5 AND EN-HORSE-JUMP(WS-ZH) <= 0.7
         ADD 1 TO TL-OBSERVED-N
     END-IF
     IF WC-ZH-SPEED(WS-ZH) >= 213000 AND WC-ZH-SPEED(WS-ZH) <= 285000
         ADD 10 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 minecraft:skeleton_horse 19 3.2 the jump gene is 0.4 to 1.0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HORSE-JUMP(WS-SH) >= 0.4 AND EN-HORSE-JUMP(WS-SH) <= 1.0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A player mounts a zombie horse with an empty hand (a hostile-category mount takes the interaction) and a camel husk; an untamed skeleton horse refuses.
     MOVE EN-ID(WS-ZH) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 minecraft:zombie_horse 19 3.6 an empty hand mounts the zombie horse" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-RIDER(WS-ZH) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-RIDE-STOP" USING WS-ZH
     CALL "MOB-RIDE-START" USING WS-PLAYER WS-SH WS-STARTED
     MOVE "acceptance US15 minecraft:skeleton_horse 19 3.6 an untamed skeleton horse cannot be mounted" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STARTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-TAMED(WS-SH)
     CALL "MOB-RIDE-START" USING WS-PLAYER WS-SH WS-STARTED
     MOVE "acceptance US15 minecraft:skeleton_horse 19 3.6 a tamed skeleton horse is mounted" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STARTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-RIDE-STOP" USING WS-SH
     CALL "MOB-RIDE-START" USING WS-PLAYER WS-CAMEL WS-STARTED
     MOVE "acceptance US15 minecraft:camel_husk 19 3.8 the player is the camel husk's first rider" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-RIDER(WS-CAMEL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-RIDE-STOP" USING WS-CAMEL

*>   The camel husk's spawn box (1.7 x 2.375 at the husk's cell centre): free in the open, blocked by a full block in a cell of the box.
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 10
     MOVE WS-FY TO WS-BY
     ADD 1 TO WS-BY
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "HUSK-CAMEL-BOX" USING WS-DIM WS-BX WS-BY WS-BZ WS-FREE
     MOVE "acceptance US15 20§4.3 the camel husk's box over open ground holds no block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FREE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-STONE
     COMPUTE WS-FX = WS-BX + 1
     COMPUTE WS-FZ = WS-BY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FZ WS-BZ WS-STONE
     CALL "HUSK-CAMEL-BOX" USING WS-DIM WS-BX WS-BY WS-BZ WS-FREE
     MOVE "acceptance US15 20§4.3 a full block at the box's top corner makes it collide" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FREE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STONE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FZ WS-BZ WS-STONE

*>   A natural husk: with probability 0.1 it holds an iron spear (hand 2) and rides a camel husk; a seed that does is found among the first 400.
     MOVE "minecraft:husk" TO WS-KEY
     MOVE 0 TO WS-FOUND
     COMPUTE WS-X = FUNCTION INTEGER(WS-X) + 10.5
     COMPUTE WS-Z = FUNCTION INTEGER(WS-Z) + 0.5
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-FOUND = 1
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MOB-SPAWN" USING WS-DIM WS-HUSK-TYPE WS-X WS-Y WS-Z WS-YAW WS-HUSK
         CALL "HUSK-CAMEL" USING XR-STATE WS-HUSK
         IF EN-MOUNT(WS-HUSK) > 0
             MOVE 1 TO WS-FOUND
         ELSE
             CALL "ENTITY-REMOVE" USING WS-HUSK
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§4.3 a natural husk can ride a camel husk (probability 0.1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-MOUNT(WS-HUSK) TO WS-CAMEL
     MOVE "acceptance US15 20§4.3 the husk's mount is a camel husk and its main hand an iron spear" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-CAMEL-TYPE * 10 + 2
     COMPUTE TL-OBSERVED-N = EN-TYPE(WS-CAMEL) * 10 + EN-HAND(WS-HUSK)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A zombie horse's jockey: a zombie with an iron spear rides it.
     CALL "ZOMBIE-HORSE-JOCKEY" USING XR-STATE WS-ZH
     MOVE "acceptance US15 19§3.6 a natural zombie horse carries a zombie with an iron spear" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-ZOMBIE-TYPE * 10 + 2
     COMPUTE TL-OBSERVED-N = EN-TYPE(EN-PASS(WS-ZH)) * 10 + EN-HAND(EN-PASS(WS-ZH))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The extras of a natural spawn (MS6-PACK-EXTRA): a zombie horse takes its jockey, a later member of a husk group none, a first husk may.
     CALL "MOB-SPAWN" USING WS-DIM WS-ZH-TYPE WS-X WS-Y WS-Z WS-YAW WS-SH
     MOVE 0 TO WS-IN-PACK
     CALL "MS6-PACK-EXTRA" USING XR-STATE WS-SH WS-IN-PACK
     MOVE "acceptance US15 19§3.6 MS6-PACK-EXTRA gives a new zombie horse its zombie" TO TL-CASE
     MOVE WS-ZOMBIE-TYPE TO TL-EXPECTED-N
     MOVE EN-TYPE(EN-PASS(WS-SH)) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-FOUND = 1
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MOB-SPAWN" USING WS-DIM WS-HUSK-TYPE WS-X WS-Y WS-Z WS-YAW WS-HUSK
         MOVE 1 TO WS-IN-PACK
         CALL "MS6-PACK-EXTRA" USING XR-STATE WS-HUSK WS-IN-PACK
         IF EN-MOUNT(WS-HUSK) > 0
             MOVE 2 TO WS-FOUND
         END-IF
         MOVE 0 TO WS-IN-PACK
         CALL "MS6-PACK-EXTRA" USING XR-STATE WS-HUSK WS-IN-PACK
         IF EN-MOUNT(WS-HUSK) > 0 AND WS-FOUND = 0
             MOVE 1 TO WS-FOUND
         END-IF
         IF WS-FOUND = 0
             CALL "ENTITY-REMOVE" USING WS-HUSK
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§4.3 only the first husk of a group tries a camel husk (a later member never does)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The speed gene is the walk speed (STDMOB-SPEED: (gene x 0.7) squared / 0.454) and the zombie horse eats a red mushroom (3.4).
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ZH) WS-M
     CALL "STDMOB-SPEED" USING WS-ZH WS-M WS-SPEED
     MOVE "acceptance US15 19§3.6 the zombie horse walks at its drawn speed gene" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SPEED >= 0.0480 AND WS-SPEED <= 0.0885
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zombie_horse" TO WS-SPECIES
     MOVE "red_mushroom" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FEED-FOUND WS-FEED-SECONDS WS-FEED-LOVE WS-FEED-TAME
     MOVE "acceptance US15 19§3.4 a red mushroom is the zombie horse's food" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FEED-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-MOUNT-ROWS.
 COPY CORETEST.
 COPY MOBSPTEST.
