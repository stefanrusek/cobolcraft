*> Acceptance test of the server side of the particles (docs/protocol/42-particles-7 sections 1.1, 1.2, 1.4;
*> 42-particles-6 section 8.2; 05a 0x30): PARTICLE-SEND builds one Level Particles packet and sends it to the
*> players of the dimension whose block position is closer than 32 blocks to the point (512 with the override
*> limiter); a player who damages another player or a mob by more than 2 sends damage_indicator (type 14,
*> count = damage x 0.5 truncated, at the target's x, y + half its 1.8 height, z; spread 0.1, 0, 0.1; speed
*> 0.2) to everyone in range; a survival player who lands after a fall of power floor(D + 1e-6 - 3) > 0
*> sends block (type 1, the landed-on state) particles: count (int)(150 * min(0.2f + power / 15, 2.5)),
*> at the player's position, no spread, speed 0.15.
*> Alice (entity 1) and Bobby (entity 2) are survival; Alice stands on greystone at (20, 100, 20).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-PARTICLES-SERVER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY MOBS.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-TYPE                BINARY-LONG VALUE 13.
 01 WS-NO-OPTION           BINARY-LONG VALUE -1.
 01 WS-OVERRIDE            BINARY-LONG VALUE 0.
 01 WS-ALWAYS              BINARY-LONG VALUE 0.
 01 WS-PX                  FLOAT-LONG VALUE 20.5.
 01 WS-PY                  FLOAT-LONG VALUE 101.
 01 WS-PZ                  FLOAT-LONG VALUE 20.5.
 01 WS-SPREAD-TABLE.
    05 WS-SPREAD           FLOAT-SHORT OCCURS 6 TIMES.
 01 WS-COUNT               BINARY-LONG VALUE 5.
 01 WS-RANDOM              BINARY-LONG VALUE 0.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE 3.
 01 WS-NO-ENTITY           BINARY-LONG VALUE 0.
 01 WS-ALICE-ROW           BINARY-LONG.
 01 WS-BOB-ROW             BINARY-LONG.
 01 WS-MOB-TYPE            BINARY-LONG VALUE 2.
 01 WS-MOB-X               FLOAT-LONG VALUE 22.5.
 01 WS-MOB-Y               FLOAT-LONG VALUE 101.
 01 WS-MOB-Z               FLOAT-LONG VALUE 20.5.
 01 WS-MOB-ROW             BINARY-LONG.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-ALICE) TO WS-ALICE-ROW
     MOVE CN-PLAYER(WS-BOB) TO WS-BOB-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 20.5 TO PL-X(WS-BOB-ROW)
     MOVE 101 TO PL-Y(WS-BOB-ROW)
     MOVE 22.5 TO PL-Z(WS-BOB-ROW)
     MOVE 17 TO PL-FOOD(WS-ALICE-ROW)
     MOVE 0 TO PL-SATURATION(WS-ALICE-ROW)
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-PARTICLES" USING WS-BOB WS-TEXT
     MOVE "T" TO TL-MODE

*>   PARTICLE-SEND: a crit, count 5, spread 0.5 and speed 1 to the players within 32 blocks.
     MOVE 0.5 TO WS-SPREAD(1) WS-SPREAD(2) WS-SPREAD(3)
     MOVE 1.0 TO WS-SPREAD(4) WS-SPREAD(5) WS-SPREAD(6)
     MOVE "acceptance particles-server given two players within 32 blocks when a crit packet is sent "
         & "then both receive it with its fields" TO TL-CASE
     CALL "PARTICLE-SEND" USING WS-DIM WS-TYPE WS-NO-OPTION WS-OVERRIDE WS-ALWAYS WS-PX WS-PY WS-PZ
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE "type 13 flags 00 pos 20.50 101.00 20.50 spread 0.50 0.50 0.50 speed 1.00 1.00 1.00 count 5 random 0"
         TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-DRAIN-PARTICLES" USING WS-BOB WS-TEXT
     PERFORM CHECK

*>   Bobby 100 blocks away: not sent without the override limiter, sent with it (flags 10).
     MOVE 120.5 TO PL-X(WS-BOB-ROW)
     MOVE "acceptance particles-server given a player 100 blocks away when the packet is sent then only "
         & "the near player receives it" TO TL-CASE
     CALL "PARTICLE-SEND" USING WS-DIM WS-TYPE WS-NO-OPTION WS-OVERRIDE WS-ALWAYS WS-PX WS-PY WS-PZ
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     CALL "TEST-DRAIN-PARTICLES" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE "acceptance particles-server given the override limiter when the packet is sent then the "
         & "player 100 blocks away receives it too, with the flag set" TO TL-CASE
     MOVE 1 TO WS-OVERRIDE
     CALL "PARTICLE-SEND" USING WS-DIM WS-TYPE WS-NO-OPTION WS-OVERRIDE WS-ALWAYS WS-PX WS-PY WS-PZ
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     CALL "TEST-DRAIN-PARTICLES" USING WS-BOB WS-TEXT
     MOVE "type 13 flags 10 pos 20.50 101.00 20.50 spread 0.50 0.50 0.50 speed 1.00 1.00 1.00 count 5 random 0"
         TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO WS-OVERRIDE
     MOVE 22.5 TO PL-X(WS-BOB-ROW)
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE "acceptance particles-server given a player in another dimension when the packet is sent then "
         & "that player receives nothing" TO TL-CASE
     MOVE 2 TO PL-DIM(WS-BOB-ROW)
     CALL "PARTICLE-SEND" USING WS-DIM WS-TYPE WS-NO-OPTION WS-OVERRIDE WS-ALWAYS WS-PX WS-PY WS-PZ
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     CALL "TEST-DRAIN-PARTICLES" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     MOVE 1 TO PL-DIM(WS-BOB-ROW)
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT

*>   damage_indicator: Alice (player row) damages Bobby by 6: count 3 at Bobby's x, y + 0.9, z.
     MOVE 6 TO WS-AMOUNT
     MOVE "acceptance particles-server given a player who damages another by 6 when the hit lands then "
         & "damage_indicator, count 3, spread 0.1 0 0.1, speed 0.2 is sent at half the target's height"
         TO TL-CASE
     CALL "HEALTH-DAMAGE" USING WS-BOB-ROW WS-AMOUNT WS-CAUSE WS-NO-ENTITY WS-ALICE-ROW
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE "type 14 flags 00 pos 22.50 101.90 22.50 spread 0.10 0.00 0.10 speed 0.20 0.20 0.20 count 3 random 0"
         TO TL-EXPECTED
     PERFORM CHECK
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-PARTICLES" USING WS-BOB WS-TEXT
     MOVE "acceptance particles-server given a hit of only 2 when it lands then no indicator is sent"
         TO TL-CASE
     MOVE 2 TO WS-AMOUNT
     CALL "HEALTH-DAMAGE" USING WS-BOB-ROW WS-AMOUNT WS-CAUSE WS-NO-ENTITY WS-ALICE-ROW
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

*>   The same for a mob: a sodgrazer at (22.5, 101, 20.5) hit by 5 gives count 2 at y + half its height.
     CALL "MOB-SPAWN" USING WS-DIM WS-MOB-TYPE WS-MOB-X WS-MOB-Y WS-MOB-Z WS-YAW WS-MOB-ROW
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE 5 TO WS-AMOUNT
     MOVE "acceptance particles-server given a mob hit by a player for 5 when the hit lands then "
         & "damage_indicator with count 2 is sent" TO TL-CASE
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB-ROW WS-AMOUNT WS-CAUSE WS-ALICE-ROW
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE "type 14 flags 00 pos 22.50 101.45 20.50 spread 0.10 0.00 0.10 speed 0.20 0.20 0.20 count 2 random 0"
         TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance particles-server given a mob hit with no attacking player when the hit lands then "
         & "nothing is sent" TO TL-CASE
     CALL "MOB-SPAWN" USING WS-DIM WS-MOB-TYPE WS-MOB-X WS-MOB-Y WS-MOB-Z WS-YAW WS-MOB-ROW
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE 6 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

*>   Landing: Alice falls 10 blocks onto the greystone: power 7, count 100 block particles of state 2.
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE 111 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     MOVE "acceptance particles-server given a survival player who falls 10 blocks onto greystone when "
         & "they land then 100 block particles of that state are sent at their position" TO TL-CASE
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE "type 1 state 2 flags 00 pos 20.50 101.00 20.50 spread 0.00 0.00 0.00 speed 0.15 0.15 0.15 count 100 random 0"
         TO TL-EXPECTED
     PERFORM CHECK
*>   A fall of 5 blocks (power 2: count 150 * (0.2 + 2/15) = 50) onto the same block.
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE 106 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     MOVE "acceptance particles-server given a fall of 5 blocks when they land then 50 particles are sent"
         TO TL-CASE
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE "type 1 state 2 flags 00 pos 20.50 101.00 20.50 spread 0.00 0.00 0.00 speed 0.15 0.15 0.15 count 50 random 0"
         TO TL-EXPECTED
     PERFORM CHECK
*>   A fall within the safe height sends nothing.
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE 104.9 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     MOVE "acceptance particles-server given a fall of 3.9 blocks when they land then nothing is sent"
         TO TL-CASE
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
*>   Landing on air (the block under the feet removed after the fall started): no block particles.
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE 111 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     MOVE "acceptance particles-server given the block under the feet is air when they land then no "
         & "block particles are sent" TO TL-CASE
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-PARTICLES" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-PARTICLES-SERVER.

 COPY CORETEST.
