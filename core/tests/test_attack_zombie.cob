*> Implementation test (002-lane-play2 defect 1, server half; docs/protocol/17 sections 4.2 and 4.6, 18 section 7.3): a player's Attack on a zombie of a standard world
*> hurts it (bare hand 1.0, a full-strength hit), a second hit inside the hurt window does not add damage, a hit pushes the zombie away from the attacker
*> (0.4 blocks per tick along the line from the attacker, decaying), the attacker's hit after the window and the cooldown hurts again, and enough hits
*> defeat it (health 0, MOB-DEFEAT).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ATTACK-ZOMBIE.
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
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SHOW                PIC -(5)9.9(3).
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
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 18000 TO CW-TIME
     COMPUTE WS-X0 = WS-X + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-ZOMBIE
     MOVE EN-ID(WS-ZOMBIE) TO WS-ID
     MOVE "N" TO TL-MODE

     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "test attack zombie: a bare-hand hit on a zombie 1.5 blocks away takes 1 health (20 to 19)" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ZOMBIE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "test attack zombie: a second hit inside the hurt window adds nothing" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ZOMBIE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test attack zombie: the hit pushes the zombie away from the attacker (motion x above 0.2)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VX(WS-ZOMBIE) > 0.2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 25 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM PLACE-ZOMBIE
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "test attack zombie: a hit after the window and the cooldown hurts again" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ZOMBIE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A sprinting player on the very spot of a zombie standing on the ground: the push follows the player's facing and the zombie rises.
     MOVE 25 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 20 TO EN-HEALTH(WS-ZOMBIE)
     MOVE 0 TO EN-HURT(WS-ZOMBIE) EN-VX(WS-ZOMBIE) EN-VZ(WS-ZOMBIE) EN-VY(WS-ZOMBIE)
     MOVE 1 TO EN-ON-GROUND(WS-ZOMBIE) PL-SPRINTING(WS-PLAYER)
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-ZOMBIE)
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-ZOMBIE)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-ZOMBIE)
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "test attack zombie: a hit from a sprinting player on the same spot pushes the zombie up (vertical speed 0.4) and 0.5 along the facing (yaw -90, east: 0.4 + 0.5)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VY(WS-ZOMBIE) > 0.39 AND EN-VX(WS-ZOMBIE) > 0.89
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)

*>   A zombie with 1 health left is defeated by the next hit after the window.
     MOVE 25 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO EN-HEALTH(WS-ZOMBIE)
     PERFORM PLACE-ZOMBIE
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "test attack zombie: the hit that takes the last health defeats the zombie (health 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ZOMBIE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 PLACE-ZOMBIE.
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE EN-X(WS-ZOMBIE) = WS-X + 1.5
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-ZOMBIE)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-ZOMBIE).
 END PROGRAM TEST-ATTACK-ZOMBIE.

 COPY CORETEST.
