*> Acceptance test (lane p49a; docs/protocol/18-mob-framework.md section 7.6 Entity loot tables, the zombie example: rotten_flesh with set_count uniform(0, 2)): the table is
*> rolled when a mob dies and the stacks land as item entities at its position; over 80 kills of a zombie by a player the number of rotten flesh dropped by one kill is 0, 1 or 2
*> and every value occurs (a uniform integer provider is inclusive of both ends); the engine's conditions, functions and providers are asserted by test_loot_*.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-7-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/stdmob-loot".
 01 WS-REG-DIR             PIC X(1100) VALUE "core/tests/fixtures/mobs2-registry".
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-SPIDER-TYPE         BINARY-LONG.
 01 WS-FLESH               BINARY-LONG.
 01 WS-SWORD               BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-AMOUNT              BINARY-LONG VALUE 100.
 01 WS-CAUSE               BINARY-LONG VALUE 1.
 01 WS-NO-PLAYER           BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ENCH                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-HELD-SLOT           BINARY-LONG.
 01 WS-ZEROS               BINARY-LONG VALUE 0.
 01 WS-ONES                BINARY-LONG VALUE 0.
 01 WS-TWOS                BINARY-LONG VALUE 0.
 01 WS-OTHERS              BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "REGISTRY-LOAD-ALL" USING WS-REG-DIR WS-STATUS
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:experience_orb" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ORB-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:spider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SPIDER-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:rotten_flesh" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-FLESH WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:iron_sword" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SWORD WS-ITEM-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 3
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE "N" TO TL-MODE

     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-I
     MOVE 0 TO WS-SUM WS-COUNT
     PERFORM 80 TIMES
         CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
         MOVE 0 TO EN-EQUIP(WS-MOB) EN-HAND(WS-MOB) EN-VARIANT(WS-MOB) EN-HURT(WS-MOB)
         CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE WS-PLAYER
         PERFORM FLESH-SUM
         EVALUATE WS-COUNT
             WHEN 0 ADD 1 TO WS-ZEROS
             WHEN 1 ADD 1 TO WS-ONES
             WHEN 2 ADD 1 TO WS-TWOS
             WHEN OTHER ADD 1 TO WS-OTHERS
         END-EVALUATE
         PERFORM CLEAR-FLESH
         PERFORM CLEAR-ORBS
         CALL "ENTITY-REMOVE" USING WS-MOB
     END-PERFORM
     MOVE "acceptance US15 18§7.6 Entity loot tables: no kill drops more than 2 rotten flesh (uniform 0 to 2)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OTHERS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§7.6 Entity loot tables: 0, 1 and 2 all occur in 80 kills (inclusive provider)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ZEROS > 0 AND WS-ONES > 0 AND WS-TWOS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§7.6 Entity loot tables: the average is about 1 (between 0.6 and 1.4 per kill)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     COMPUTE WS-SUM = WS-ONES + 2 * WS-TWOS
     IF WS-SUM >= 48 AND WS-SUM <= 112
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 ORB-SUM.
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             COMPUTE WS-SUM = WS-SUM + EN-ITEM(WS-I) * EN-ITEM-COUNT(WS-I)
         END-IF
     END-PERFORM.
 CLEAR-ORBS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.
 FLESH-SUM.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ITEM(WS-I) = WS-FLESH AND EN-TYPE(WS-I) NOT = WS-ORB-TYPE
             ADD EN-ITEM-COUNT(WS-I) TO WS-COUNT
         END-IF
     END-PERFORM.
 CLEAR-FLESH.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ITEM(WS-I) = WS-FLESH AND EN-TYPE(WS-I) NOT = WS-ORB-TYPE AND EN-ITEM-COUNT(WS-I) > 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-18-7-6.
 COPY CORETEST.
