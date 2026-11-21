*> Acceptance test (lane p49u; docs/protocol/20 section 16.1 and 16.3): the breeze in a standard world. /summon makes a breeze (health 30; none in Peaceful: notInPeaceful), the IDLE
*> StartAttacking finder of the hurt_by memory (priority 1: the player that hit it in the last 100 ticks becomes the attack target when the breeze can attack it, a survival or adventure
*> player, whatever its distance; the stop rule then drops a target out of the follow range at its first check), and the end of a wind charge above level.maxY + 30 (it bursts there and is
*> discarded; the block y maxY + 30 itself still flies), the owner leaving it (discarded with no burst).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-16-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 COPY DIMENSIONS.
 COPY BRWORLD.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-FIND-X              FLOAT-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-SOURCE              BINARY-LONG VALUE 0.
 01 WS-OWNER0              BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG VALUE 6.
 01 WS-MAX-Y               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE

*>   /summon: a breeze by its namespaced key, with the row's health 30; not in Peaceful.
     MOVE "acceptance US15 20§16 /summon a breeze (Normal difficulty)" TO TL-CASE
     MOVE "summon minecraft:breeze 5.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(minecraft:breeze)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "N" TO TL-MODE
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US15 20§16 /summon one breeze stands at x 5 with 30 health" TO TL-CASE
     MOVE "breeze" TO WS-KEY-TEXT
     MOVE 5.0 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US15 20§16 /summon the breeze's health is the row's 30" TO TL-CASE
     MOVE 30 TO WS-EXPECTED-N
     MOVE WS-HEALTH TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE 0 TO BW-DIFFICULTY
     MOVE "acceptance US15 20§16 /summon a breeze in Peaceful is refused" TO TL-CASE
     MOVE "summon minecraft:breeze 6.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.failed.peaceful()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE 2 TO BW-DIFFICULTY
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM

*>   The hurt_by finder. The breeze stands 30 blocks from the player (out of the nearest-attackable range 24).
     MOVE "minecraft:breeze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-DX = WS-X + 30
     CALL "MOB-SPAWN" USING WS-DIM WS-BTYPE WS-DX WS-Y WS-Z WS-YAW WS-MOB
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-MOB) WS-M
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "STDMOB-AGGRO" USING WS-MOB WS-M
     MOVE "acceptance US15 20§16.1 no hit and nobody in range: no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PLAYER TO EN-KILLER(WS-MOB)
     MOVE 0 TO EN-KILLER-AGE(WS-MOB)
     CALL "STDMOB-AGGRO" USING WS-MOB WS-M
     MOVE "acceptance US15 20§16.1 a hit whose memory has run out (age 0): no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO EN-KILLER-AGE(WS-MOB)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "STDMOB-AGGRO" USING WS-MOB WS-M
     MOVE "acceptance US15 20§16.1 a creative attacker cannot be attacked: no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "STDMOB-AGGRO" USING WS-MOB WS-M
     MOVE "acceptance US15 20§16.1 a survival player that hit it 30 blocks away becomes the target" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 and the target id is the player's entity id" TO TL-CASE
     MOVE PL-ENTITY-ID(WS-PLAYER) TO TL-EXPECTED-N
     MOVE EN-TARGET-ID(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BREEZE-STOP-CHECK" USING WS-MOB
     MOVE "acceptance US15 20§16.1 a target out of the follow range is dropped by the stop rule's first check" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An adventure player (the nearest-attackable scan of this core takes survival players only) that hit the breeze.
     MOVE 2 TO PL-MODE(WS-PLAYER)
     CALL "STDMOB-AGGRO" USING WS-MOB WS-M
     MOVE "acceptance US15 20§16.1 an adventure player that hit it becomes the target" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   A breeze that is not the one hit keeps the finder to itself: a zombie never takes this path (its row is not a breeze).
     COMPUTE WS-DX = WS-X + 40
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-DX WS-Y WS-Z WS-YAW WS-ZOMBIE
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ZOMBIE) WS-M
     MOVE WS-PLAYER TO EN-KILLER(WS-ZOMBIE)
     MOVE 50 TO EN-KILLER-AGE(WS-ZOMBIE)
     CALL "STDMOB-AGGRO" USING WS-ZOMBIE WS-M
     MOVE "acceptance US15 20§16.1 a zombie hit from 40 blocks (beyond its follow range 35) takes no target (the finder is the breeze's)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-ZOMBIE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ZOMBIE

*>   A wind charge ends above level.maxY + 30 (the highest block y of the dimension plus 30): at block y maxY + 30 it flies on, at maxY + 31 it bursts and is gone.
     COMPUTE WS-MAX-Y = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM) - 1
     PERFORM VARYING WS-I FROM 30 BY 1 UNTIL WS-I > 31
         COMPUTE WS-Y = WS-MAX-Y + WS-I + 0.5
         MOVE WS-X TO WS-DX
         COMPUTE WS-DZ = WS-Z + 1
         CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-DX WS-Y WS-DZ WS-YAW WS-ZOMBIE
         MOVE 0 TO EN-VX(WS-ZOMBIE) EN-VY(WS-ZOMBIE) EN-VZ(WS-ZOMBIE)
         MOVE 1 TO WS-DX
         MOVE 0 TO WS-DY WS-DZ
         MOVE PL-X(WS-PLAYER) TO WS-X
         CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ WS-SOURCE WS-OWNER0 WS-CHARGE
         CALL "PROJ-STEP" USING WS-CHARGE
         MOVE SPACES TO TL-CASE
         IF WS-I = 30
             MOVE "acceptance US15 20§16.3 a charge at block y maxY + 30 still flies" TO TL-CASE
             MOVE 1 TO TL-EXPECTED-N
         ELSE
             MOVE "acceptance US15 20§16.3 a charge at block y maxY + 31 is discarded" TO TL-CASE
             MOVE 0 TO TL-EXPECTED-N
         END-IF
         MOVE EN-USED(WS-CHARGE) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         IF WS-I = 30
             MOVE "acceptance US15 20§16.3 and bursts nothing: the zombie 1 block away is not pushed" TO TL-CASE
             MOVE 0 TO TL-EXPECTED-N
         ELSE
             MOVE "acceptance US15 20§16.3 it bursts where it ended: the zombie 1 block away is pushed" TO TL-CASE
             MOVE 1 TO TL-EXPECTED-N
         END-IF
         MOVE 0 TO TL-OBSERVED-N
         IF EN-VX(WS-ZOMBIE) NOT = 0 OR EN-VY(WS-ZOMBIE) NOT = 0 OR EN-VZ(WS-ZOMBIE) NOT = 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF EN-USED(WS-CHARGE) = 1
             CALL "ENTITY-REMOVE" USING WS-CHARGE
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ZOMBIE
         MOVE PL-X(WS-PLAYER) TO WS-X
     END-PERFORM

*>   The owner leaving: a charge whose owner entity is gone is discarded by the tick with no burst; with a live owner it flies.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-DX = WS-X + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-BTYPE WS-DX WS-Y WS-Z WS-YAW WS-MOB
     COMPUTE WS-DX = WS-X + 5
     COMPUTE WS-DZ = WS-Z + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-DX WS-Y WS-DZ WS-YAW WS-ZOMBIE
     MOVE 0 TO EN-VX(WS-ZOMBIE) EN-VY(WS-ZOMBIE) EN-VZ(WS-ZOMBIE)
     MOVE 1 TO WS-DX
     MOVE 0 TO WS-DY WS-DZ
     COMPUTE WS-X = WS-X + 5
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ WS-SOURCE EN-ID(WS-MOB) WS-CHARGE
     CALL "PROJECTILES-TICK"
     MOVE "acceptance US15 20§16.3 a charge with its owner alive flies on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-CHARGE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "PROJECTILES-TICK"
     MOVE "acceptance US15 20§16.3 the owner gone: the charge is discarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-CHARGE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.3 and bursts nothing: the zombie beside it is not pushed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VX(WS-ZOMBIE) NOT = 0 OR EN-VY(WS-ZOMBIE) NOT = 0 OR EN-VZ(WS-ZOMBIE) NOT = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COUNT-MOBS.
     MOVE 0 TO WS-NUM WS-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-X(WS-I) = WS-FIND-X
             COMPUTE WS-KEEP = EN-TYPE(WS-I) + 1
             IF ET-KEY(WS-KEEP) = WS-KEY-TEXT
                 ADD 1 TO WS-NUM
                 MOVE EN-HEALTH(WS-I) TO WS-HEALTH
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-20-16-8.

 COPY CORETEST.
 COPY CMDTEST.
