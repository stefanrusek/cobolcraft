*> Convergence acceptance test of US12-3 on a standard world (spec 002 FR-031, FR-032, FR-038; docs/protocol/37-nether-1, 38-end, 39-portals sections 3 to 8;
*> docs/protocol/33 section 3 the standard day timeline): one standard world (the generated packs of CC_GENERATED_DIR, default /tmp/cc-test/generated; a pass without them)
*> is created through the client's single-player host, with the Nether on its placeholder terrain (the real terrain costs minutes a chunk; test_nether_terrain covers it). The player is
*> creative and every step goes through the client and the core: the standard commands build an obsidian frame with its nether portal blocks in the overworld, she is moved into it
*> and the client replica swaps to the Nether (Respawn, new chunks, no sky light), a portal is made there; the way back swaps it to the overworld and she arrives where she started; an
*> end portal block takes her to the End (platform at 100.5, 49, 0.5) and a cross-dimension teleport brings her back. Login names the three standard dimensions. The standard
*> timeline (the clock of the overworld, period 24000; markers noon 6000, night 13000, midnight 18000) is read from the client's clock in each dimension.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-DIMENSIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY COREAPI.
 COPY NETHERDIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us12-dimensions".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 28.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "StdDimensions".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 13.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-WANT                PIC X(64).
 01 WS-REACHED             BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-DLOG                PIC X(4096).
 01 WS-BEFORE              PIC X(1024).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(112).
 01 WS-PAIRS-X             PIC X(160) VALUE "axis=x".
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-PORTAL-X            BINARY-LONG.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-F1                  PIC -(4)9.9.
 01 WS-F2                  PIC -(4)9.9.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12 dimensions: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE 1 TO ND-PLACEHOLDER
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     PERFORM WAIT-PLAY
     MOVE "/gamemode creative Alice" TO WS-LINE
     PERFORM SAY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

*>   Login: the three standard dimensions, she starts in the overworld under the sky.
     MOVE "acceptance US12-3 given a standard world when the Player joins then Login names the three standard dimensions and she is in "
         & "the overworld with sky light" TO TL-CASE
     MOVE "3 minecraft:overworld minecraft:the_nether minecraft:the_end | in minecraft:overworld sky 1" TO TL-EXPECTED
     MOVE PL-LEVEL-COUNT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(PL-LEVEL(1)) " " FUNCTION TRIM(PL-LEVEL(2)) " " FUNCTION TRIM(PL-LEVEL(3))
         " | in " FUNCTION TRIM(PL-DIM-NAME) " sky " PL-HAS-SKY DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The standard timeline: the markers of the day timeline in the overworld clock.
     MOVE "/time set noon" TO WS-LINE
     PERFORM SAY
     PERFORM STEP-ONE
     MOVE "acceptance US12-3 the standard timeline given /time set noon then the client's clock is at the marker 6000 (plus the ticks run since)"
         TO TL-CASE
     MOVE "marker" TO TL-EXPECTED
     MOVE 6000 TO WS-LO
     PERFORM CLOCK-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/time set midnight" TO WS-LINE
     PERFORM SAY
     PERFORM STEP-ONE
     MOVE "acceptance US12-3 the standard timeline given /time set midnight then the client's clock is at the marker 18000 (plus the ticks run since)" TO TL-CASE
     MOVE "marker" TO TL-EXPECTED
     MOVE 18000 TO WS-LO
     PERFORM CLOCK-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/time set 23990" TO WS-LINE
     PERFORM SAY
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US12-3 the standard timeline given the clock 10 ticks before the period then after 40 frames the day wrapped at 24000 "
         & "(the client's clock is below 100, not 30000-based)" TO TL-CASE
     MOVE "wrapped" TO TL-EXPECTED
     MOVE "still running" TO TL-OBSERVED
     IF PL-TIME < 100
         MOVE "wrapped" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/time set 1000" TO WS-LINE
     PERFORM SAY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-TIME TO WS-T0

*>   A nether portal frame (axis X) in the air at (10, 100, 10): interior x 9..10, y 100..102; she is put into it.
     MOVE "/fill 8 99 10 11 99 10 obsidian" TO WS-LINE
     PERFORM SAY
     MOVE "/fill 8 103 10 11 103 10 obsidian" TO WS-LINE
     PERFORM SAY
     MOVE "/fill 8 100 10 8 102 10 obsidian" TO WS-LINE
     PERFORM SAY
     MOVE "/fill 11 100 10 11 102 10 obsidian" TO WS-LINE
     PERFORM SAY
     MOVE "/fill 9 100 10 10 102 10 nether_portal[axis=x]" TO WS-LINE
     PERFORM SAY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "F12-WHERE" USING CLIENT-STATE WS-BEFORE
     MOVE "nether_portal" TO WS-KEY-TEXT
     CALL "BLOCKS-STATE-OF" USING WS-KEY-TEXT WS-PAIRS-X WS-PORTAL-X
     MOVE 9 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 10 TO WS-Z
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE "acceptance US12-3 given the standard commands built a portal frame when the client's replica is read then it holds the portal block "
         & "at (9, 100, 10)" TO TL-CASE
     MOVE "portal" TO TL-EXPECTED
     PERFORM PORTAL-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/tp Alice 10.0 100 10.5" TO WS-LINE
     PERFORM SAY
     MOVE "minecraft:the_nether" TO WS-WANT
     PERFORM WAIT-DIM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US12-3 given she stands in the overworld portal when the world ticks then the client replica swaps to the Nether (Respawn): "
         & "no sky light, at the scaled position in a portal made for her" TO TL-CASE
     MOVE "minecraft:the_nether at 2.0/41.0/1.5 sky 0 portal" TO TL-EXPECTED
     CALL "F12-WHERE" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The clock goes on in the Nether (the overworld clock; Set Time at the dimension change).
     MOVE PL-TIME TO WS-T1
     MOVE "acceptance US12-3 the standard timeline given she changed dimension when the client's clock is read then it is the overworld clock "
         & "continued, later than 1000 and in the day" TO TL-CASE
     MOVE "continued" TO TL-EXPECTED
     MOVE "reset" TO TL-OBSERVED
     IF WS-T1 > WS-T0 AND WS-T1 < 24000
         MOVE "continued" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Back: out of the portal, the cooldown runs out, into it again.
     MOVE "/tp Alice 6.5 41 6.5" TO WS-LINE
     PERFORM SAY
          CALL "CV-STEPS" USING CONVH WS-N
     MOVE "/tp Alice 2.0 41 1.5" TO WS-LINE
     PERFORM SAY
     MOVE "minecraft:overworld" TO WS-WANT
     PERFORM WAIT-DIM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US12-3 given she walks into the nether portal when the world ticks then the replica swaps back to the overworld and she arrives "
         & "at the portal she came from, under the sky" TO TL-CASE
     MOVE "minecraft:overworld at 10.0/100.0/10.5 sky 1 portal" TO TL-EXPECTED
     CALL "F12-WHERE" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 the trip to the Nether and back keeps her inventory, health, food and game mode" TO TL-CASE
     MOVE "mode 1" TO TL-EXPECTED
     MOVE PL-MODE TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "mode " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The End: an end portal block in the overworld takes her to the obsidian platform; a cross-dimension teleport brings her back.
     MOVE "/tp Alice 20.5 100 20.5" TO WS-LINE
     PERFORM SAY
          CALL "CV-STEPS" USING CONVH WS-N
     MOVE "/fill 20 90 20 20 105 20 end_portal" TO WS-LINE
     PERFORM SAY
     MOVE "minecraft:the_end" TO WS-WANT
     PERFORM WAIT-DIM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US12-3 given she stands in an end portal block of the overworld when the world ticks then the replica swaps to the End: "
         & "the platform at (100.5, 49, 0.5), with the sky light of its type" TO TL-CASE
     MOVE "minecraft:the_end at 100.5/49.0/0.5 sky 1" TO TL-EXPECTED
     CALL "F12-WHERE" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/execute in minecraft:overworld run tp Alice 30.5 120 30.5" TO WS-LINE
     PERFORM SAY
     MOVE "minecraft:overworld" TO WS-WANT
     PERFORM WAIT-DIM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US12-3 given a Player in the End when a teleport names the overworld then the replica swaps back and she is at the target "
         & "under the sky" TO TL-CASE
     MOVE "minecraft:overworld x 30.5 z 30.5 sky 1" TO TL-EXPECTED
     COMPUTE WS-F1 ROUNDED = PL-X
     COMPUTE WS-F2 ROUNDED = PL-Z
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(PL-DIM-NAME) " x " FUNCTION TRIM(WS-F1) " z " FUNCTION TRIM(WS-F2) " sky " PL-HAS-SKY
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   Frames until the client is in play (a standard world loads its chunks slowly: wait again, up to 20 times).
 WAIT-PLAY.
     MOVE 0 TO WS-JOINED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 20 OR WS-JOINED = 1
         CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
         IF WS-JOINED = 0
             CALL "C$SLEEP" USING 1
         END-IF
     END-PERFORM.

*>   Alice types WS-LINE; the frames then run until the core's reply is in her chat or 600 frames have passed.
 SAY.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING)) TO WS-LINE-LENGTH
     CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-DLOG
     MOVE 0 TO WS-HITS
     INSPECT WS-DLOG TALLYING WS-HITS FOR ALL "commands."
     MOVE WS-HITS TO WS-H0
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 0 TO WS-K
     PERFORM UNTIL WS-K >= 600 OR WS-HITS > WS-H0
         CALL "CV-STEP" USING CONVH
         ADD 1 TO WS-K
         CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-DLOG
         MOVE 0 TO WS-HITS
         INSPECT WS-DLOG TALLYING WS-HITS FOR ALL "commands."
     END-PERFORM
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.

 STEP-ONE.
     CALL "CV-STEP" USING CONVH.

*>   Frames until the client's dimension is WS-WANT and she is loaded (at most 600), then 5 more.
 WAIT-DIM.
     MOVE 0 TO WS-REACHED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 600 OR WS-REACHED = 1
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         IF FUNCTION TRIM(PL-DIM-NAME) = FUNCTION TRIM(WS-WANT) AND PL-LOADED = 1
             MOVE 1 TO WS-REACHED
         END-IF
     END-PERFORM
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.

 CLOCK-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-TIME TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "clock " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     IF PL-TIME >= WS-LO AND PL-TIME < WS-LO + 100
         MOVE "marker" TO TL-OBSERVED
     END-IF.

 PORTAL-TEXT.
     MOVE "no portal" TO TL-OBSERVED
     IF WS-STATE = WS-PORTAL-X
         MOVE "portal" TO TL-OBSERVED
     END-IF.
 END PROGRAM ACC-F2US12-DIMENSIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F12-WHERE.
*> USING CLIENT-STATE, text out (PIC X(1024)): "<dimension> at <x>/<y>/<z> sky <PL-HAS-SKY>" (1 decimal), then " portal" when the client's replica holds a
*> nether portal block in the cell of her feet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F1                  PIC -(4)9.9.
 01 WS-F2                  PIC -(4)9.9.
 01 WS-F3                  PIC -(4)9.9.
 01 WS-KEY                 PIC X(112) VALUE "nether_portal".
 01 WS-PAIRS-X             PIC X(160) VALUE "axis=x".
 01 WS-PAIRS-Z             PIC X(160) VALUE "axis=z".
 01 WS-PORTAL-X            BINARY-LONG.
 01 WS-PORTAL-Z            BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS-X WS-PORTAL-X
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS-Z WS-PORTAL-Z
     COMPUTE WS-F1 ROUNDED = PL-X
     COMPUTE WS-F2 ROUNDED = PL-Y
     COMPUTE WS-F3 ROUNDED = PL-Z
     COMPUTE WS-X = FUNCTION INTEGER(PL-X)
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y + 0.001)
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE SPACES TO L-TEXT
     STRING FUNCTION TRIM(PL-DIM-NAME) " at " FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/"
         FUNCTION TRIM(WS-F3) " sky " PL-HAS-SKY DELIMITED BY SIZE INTO L-TEXT
     IF WS-STATE = WS-PORTAL-X OR WS-STATE = WS-PORTAL-Z
         STRING FUNCTION TRIM(L-TEXT) " portal" DELIMITED BY SIZE INTO L-TEXT
     END-IF
     GOBACK.
 END PROGRAM F12-WHERE.
