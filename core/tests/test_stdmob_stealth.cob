 *> Implementation test of the stealth of a crouching player (T6203; docs/protocol/18 section 4.3 getVisibilityPercent: crouching x 0.8):
*> a hostile mob takes a player as its target within its follow range times 0.8 when the player is crouching (pose 5), so a zombie (follow range 35)
*> 30 blocks away targets a standing player and not a crouching one, and drops a crouching target that it kept while the player stood.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-STEALTH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 COPY RULES.
 COPY BRWORLD.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/stdmob-loot".
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-SPAWNS              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STONE-STATE         BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-AMOUNT              BINARY-LONG VALUE 3.
 01 WS-HEALTH-TENTHS       BINARY-LONG.
 01 WS-DIR                PIC X(1100).
 01 WS-TYPE               BINARY-LONG.
 01 WS-TIME-ARG           BINARY-DOUBLE.
 01 WS-DAY                 BINARY-DOUBLE VALUE 6000.
 01 WS-NIGHT               BINARY-DOUBLE VALUE 18000.
  PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     CALL "BR-WORLD-READY"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z

     MOVE "T" TO TL-MODE
     CALL "STDMOB-INDEX" USING WS-ZOMBIE-TYPE WS-INDEX
     COMPUTE WS-X0 = WS-X + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-ZOMBIE
     COMPUTE EN-X(WS-ZOMBIE) = WS-X + 30
     MOVE WS-Y TO EN-Y(WS-ZOMBIE)
     MOVE WS-Z TO EN-Z(WS-ZOMBIE)
     MOVE 0 TO EN-TARGET(WS-ZOMBIE) EN-TARGET-ID(WS-ZOMBIE)
     MOVE 0 TO PL-POSE(WS-PLAYER)
     CALL "STDMOB-TARGET" USING WS-ZOMBIE WS-INDEX
     MOVE "test stdmob stealth: a zombie targets a standing player 30 blocks away (follow range 35)" TO TL-CASE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF EN-TARGET(WS-ZOMBIE) > 0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-POSE(WS-PLAYER)
     CALL "STDMOB-TARGET" USING WS-ZOMBIE WS-INDEX
     MOVE "test stdmob stealth: the zombie drops the target when the player crouches and takes no new one (range 28)" TO TL-CASE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF EN-TARGET(WS-ZOMBIE) = 0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-ZOMBIE) = WS-X + 20
     CALL "STDMOB-TARGET" USING WS-ZOMBIE WS-INDEX
     MOVE "test stdmob stealth: a crouching player 20 blocks away is a target" TO TL-CASE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF EN-TARGET(WS-ZOMBIE) > 0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STDMOB-STEALTH.

 COPY CORETEST.
