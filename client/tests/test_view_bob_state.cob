*> Implementation test of lane bugviewbob (T62410-T62414; docs/protocol/53 section 15.2, 12 section 6.1): the state view bobbing runs on, kept by the client tick. walkDist
*> grows by 0.6 x the horizontal distance moved in a tick (SMOOTH-WALK, any pose, no teleports); the bob amount b eases 0.4 of the way to its target a tick (SMOOTH-STORE:
*> 0 in the air, dead or swimming, else the smaller of 0.1 and the speed left over from the tick before, the step x 0.546); deathTime counts to 20 while dying; a Hurt
*> Animation of the local player sets the direction of the hurt tilt; a respawn or login starts from zero. The numbers come from the document's rules worked by hand
*> (b after n ticks of walking at 0.2 a tick is 0.1 x (1 - 0.6 ^ (n - 1)), the first tick still reading the standstill before it).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VIEW-BOB-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ID                  BINARY-LONG VALUE 43.
 01 WS-YAW                 FLOAT-SHORT VALUE 90.
 01 WS-X                   FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
*>   Walking: W held for five ticks on the flat floor.
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 4 TO WS-I
     CALL "TEST-TICKS" USING CLIENT-STATE WS-I
     MOVE "view bob state: five ticks at 0.2 blocks: walkDist is 0.6 x 1 block (millionths)" TO TL-CASE
     MOVE 600000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-WALK * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "view bob state: walkDistO is the value one tick ago, 0.6 x 0.8 (millionths)" TO TL-CASE
     MOVE 480000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-WALK-O * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "view bob state: b after five ticks of walking: 0.1 x (1 - 0.6 ^ 4) (millionths)" TO TL-CASE
     MOVE 87040 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "view bob state: bobO is b one tick ago, 0.1 x (1 - 0.6 ^ 3) (millionths)" TO TL-CASE
     MOVE 78400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB-O * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The key is released: the tick after still reads the speed left over from the one before (the target is still 0.1), the walkDist stops growing, then b dies away.
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "view bob state: the tick after the key is released: b moves 0.4 toward 0.1 (0.087040 to 0.092224, millionths)" TO TL-CASE
     MOVE 92224 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "view bob state: the walkDist stops growing with the standstill (millionths)" TO TL-CASE
     MOVE 600000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-WALK * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-I
     CALL "TEST-TICKS" USING CLIENT-STATE WS-I
     MOVE "view bob state: the next tick at a standstill: b moves 0.4 toward 0 (0.092224 x 0.6, millionths)" TO TL-CASE
     MOVE 55334 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A position correction between ticks is no walking.
     COMPUTE PL-X = PL-X + 20
     MOVE 1 TO WS-I
     CALL "TEST-TICKS" USING CLIENT-STATE WS-I
     MOVE "view bob state: a position correction of 20 blocks does not add to walkDist (millionths)" TO TL-CASE
     MOVE 600000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-WALK * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The targets of SMOOTH-STORE called directly: ground, air, dying, swimming, a crouching step (0.06 a tick).
     MOVE 30 TO PL-HEALTH
     MOVE 1 TO PL-ON-GROUND
     MOVE 0 TO PL-SWIMMING PL-BOB
     MOVE 0.2 TO PL-MOVE-X
     MOVE 0 TO PL-MOVE-Z
     CALL "SMOOTH-STORE" USING CLIENT-STATE
     MOVE "view bob state: on the ground at 0.2 a tick the target is 0.1 (the step x 0.546 is over the cap): b is 0.04 (millionths)" TO TL-CASE
     MOVE 40000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-ON-GROUND
     CALL "SMOOTH-STORE" USING CLIENT-STATE
     MOVE "view bob state: in the air the target is 0: b loses 40 percent (0.024, millionths)" TO TL-CASE
     MOVE 24000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-ON-GROUND PL-SWIMMING
     CALL "SMOOTH-STORE" USING CLIENT-STATE
     MOVE "view bob state: with the swimming flag the target is 0 (0.0144, millionths)" TO TL-CASE
     MOVE 14400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SWIMMING
     MOVE 0 TO PL-HEALTH
     CALL "SMOOTH-STORE" USING CLIENT-STATE
     MOVE "view bob state: a dying player's target is 0 (0.00864, millionths)" TO TL-CASE
     MOVE 8640 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 30 TO PL-HEALTH
     MOVE 0.06 TO PL-MOVE-X
     PERFORM 60 TIMES
         CALL "SMOOTH-STORE" USING CLIENT-STATE
     END-PERFORM
     MOVE "view bob state: crouching steps of 0.06 a tick settle b at 0.06 x 0.546 = 0.03276 (millionths)" TO TL-CASE
     MOVE 32760 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.2 TO PL-MOVE-X
     MOVE 0.2 TO PL-MOVE-Z
     MOVE 0 TO PL-BOB
     CALL "SMOOTH-STORE" USING CLIENT-STATE
     MOVE "view bob state: the speed is the horizontal length of the step: 0.2 and 0.2 is over the cap too (millionths)" TO TL-CASE
     MOVE 40000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-BOB * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   SMOOTH-WALK: the horizontal distance only.
     MOVE 0 TO PL-WALK
     MOVE 1 TO PL-OX PL-OZ
     MOVE 5 TO PL-OY
     MOVE 1.3 TO PL-X
     MOVE 1.4 TO PL-Z
     MOVE 9 TO PL-Y
     CALL "SMOOTH-WALK" USING CLIENT-STATE
     MOVE "view bob state: a move of 0.3 and 0.4 (and a fall of 4) adds 0.6 x 0.5 to walkDist (millionths)" TO TL-CASE
     MOVE 300000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-WALK * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   deathTime counts to 20 while dying and is 0 while alive.
     MOVE 0 TO PL-HEALTH PL-DEATH-TIME
     PERFORM 5 TIMES
         CALL "SMOOTH-STORE" USING CLIENT-STATE
     END-PERFORM
     MOVE "view bob state: five ticks while dying: deathTime 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PL-DEATH-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 40 TIMES
         CALL "SMOOTH-STORE" USING CLIENT-STATE
     END-PERFORM
     MOVE "view bob state: deathTime stops at 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-DEATH-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO PL-HEALTH
     CALL "SMOOTH-STORE" USING CLIENT-STATE
     MOVE "view bob state: alive again: deathTime 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-DEATH-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A Hurt Animation of the local player carries the direction of the tilt; one for another entity does not.
     MOVE 7 TO PL-ENTITY-ID
     MOVE 0 TO PL-HURT-DIR PL-HURT-UNTIL
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER PL-ENTITY-ID
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-YAW
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "view bob state: Hurt Animation for the local player with yaw 90: the tilt turns about 90 degrees" TO TL-CASE
     MOVE 90 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HURT-DIR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "view bob state: and the hurt indication runs" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HURT-UNTIL > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-HURT-DIR PL-HURT-UNTIL
     MOVE 8 TO PL-ENTITY-ID
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 7 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-YAW
     MOVE 43 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "view bob state: Hurt Animation for another entity leaves the direction alone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HURT-DIR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A respawn (and a login) starts the bobbing from zero.
     MOVE 5 TO PL-WALK PL-WALK-O
     MOVE 0.1 TO PL-BOB PL-BOB-O
     MOVE 40 TO PL-HURT-DIR
     MOVE 12 TO PL-DEATH-TIME
     CALL "DIMENSION-ENTER" USING CLIENT-STATE
     MOVE "view bob state: entering a dimension resets walkDist, b, the hurt direction and deathTime" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-WALK + PL-WALK-O + PL-BOB + PL-BOB-O + PL-HURT-DIR + PL-DEATH-TIME
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-VIEW-BOB-STATE.
 COPY CLTEST.
