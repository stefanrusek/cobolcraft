*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 6.2): the shulker's armour and arrow immunity while closed, its peek goal and the shulker bullet's destruction by a hit. Closed
*> (peek 0) it has +20 armour (a player's 10 damage costs 4: 20 - 10 / 2 = 15 of 25 absorbed), open it has none; an arrow hit is ignored while it is closed and lands when it is open; with no target
*> it opens by 30 on a 1 in 40 tick and closes after 20 x (1 + nextInt(3)) ticks (an episode of 20, 40 or 60); a player's attack discards a shulker bullet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-6-2-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-SHULKER             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-EPISODES            BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-MAXPEEK             BINARY-LONG.
 01 WS-BULLET              BINARY-LONG.
 01 WS-DX                  FLOAT-LONG VALUE 0.
 01 WS-DY                  FLOAT-LONG VALUE 1.
 01 WS-DZ                  FLOAT-LONG VALUE 0.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-KIND-BULLET         BINARY-LONG VALUE 4.
 01 WS-DONE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:shulker" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SHULKER WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 1.0
     COMPUTE WS-Z = WS-Z0 + 4.5
*>   Armour: closed (peek 0) a player's hit of 10 costs 4; open (peek 100) it costs 10.
     CALL "MOB-SPAWN" USING WS-DIM WS-SHULKER WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 10 TO WS-DAMAGE
     MOVE 3 TO WS-CAUSE
     MOVE 0 TO EN-VARIANT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 21§6.2 a closed shulker has +20 armour: a hit of 10 costs 4 (30 to 26)" TO TL-CASE
     MOVE 26 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-SHULKER WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 100 TO EN-VARIANT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 21§6.2 an open shulker has no armour: a hit of 10 costs 10 (30 to 20)" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Arrows: ignored while closed, taken (no armour) when open.
     CALL "MOB-SPAWN" USING WS-DIM WS-SHULKER WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 5 TO WS-DAMAGE
     MOVE 10 TO WS-CAUSE
     MOVE 0 TO EN-VARIANT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 21§6.2 an arrow hit on a closed shulker is ignored (health 30)" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 100 TO EN-VARIANT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 21§6.2 an arrow hit on an open shulker lands (30 to 25)" TO TL-CASE
     MOVE 25 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   The peek goal: 1500 ticks without a target on the dry block beside the tank; every peek is an episode of 20, 40 or 60 ticks at raw peek 30.
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Z = WS-Z0 + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SHULKER WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO WS-RUN WS-EPISODES WS-BAD WS-MAXPEEK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         IF EN-VARIANT(WS-ROW) = 30
             ADD 1 TO WS-RUN
         ELSE
             IF EN-VARIANT(WS-ROW) NOT = 0
                 ADD 1 TO WS-BAD
             END-IF
             IF WS-RUN > 0
                 ADD 1 TO WS-EPISODES
                 IF WS-RUN NOT = 20 AND WS-RUN NOT = 40 AND WS-RUN NOT = 60
                     ADD 1 TO WS-BAD
                 END-IF
                 MOVE 0 TO WS-RUN
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§6.2 with no target the peek goal opens it 1 tick in 40 (1500 ticks: at least 10 peeks)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-EPISODES >= 10
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§6.2 every peek is raw peek 30 for 20, 40 or 60 ticks, and the lid is otherwise shut" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A shulker bullet is discarded by a player's attack.
     CALL "PROJ-SPAWN" USING WS-KIND-BULLET WS-DIM WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER PL-ENTITY-ID(WS-PLAYER) WS-BULLET
     CALL "PROJ-REDIRECT" USING WS-PLAYER WS-BULLET WS-DONE
     MOVE "acceptance US15 21§6.2 a hit on a shulker bullet destroys it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-BULLET) TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-6-2-OPEN.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
