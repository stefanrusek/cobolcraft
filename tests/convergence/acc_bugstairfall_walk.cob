*> Convergence acceptance test of the operator report "travelling down stairs or an incline too fast causes the player to take fall damage despite never leaving
*> the ground" (try19 play; CC-0011; docs/protocol/13 section 1.3, 17 section 4.11 fall damage). One superflat survival world made through the client's single-player
*> host from the generated packs (CC_GENERATED_DIR; a pass without them). The core builds a platform with a descent of eight steps behind it (stairs: 0.5 down
*> each half block; a staircase of full blocks: 1 down each block; a half block slope: bottom slabs 0.5 down each block) and the Player, standing on the
*> platform, walks (run 0) or sprints (run 1) down it with W held through the real controls. The client moves by its own physics and tells the core with Move
*> Player. Counted per run: the health the Player lost (expected 0), the teleports the core sent (expected 0) and the frames the client was off the ground.
*> BF_FEATURE=n runs only that feature, BF_TRACE=1 prints every frame.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGSTAIRFALL-WALK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugstairfall-walk".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 28.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "StairFall".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 9.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-ENV                 PIC X(16).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-LINE                PIC X(64).
 01 WS-N                   BINARY-LONG.
 01 WS-FEATURE             BINARY-LONG.
 01 WS-ONLY                BINARY-LONG VALUE 0.
 01 WS-TRACE               BINARY-LONG VALUE 0.
 01 WS-RUN                 BINARY-LONG.
 01 WS-FRAME               BINARY-LONG.
 01 WS-ZS                  BINARY-LONG VALUE 12.
 01 WS-KEY-W               BINARY-LONG VALUE CC-KEY-W.
 01 WS-KEY-SPRINT          BINARY-LONG VALUE CC-KEY-LEFT-CONTROL.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-TP0                 BINARY-LONG.
 01 WS-TP1                 BINARY-LONG.
 01 WS-TELEPORTS           BINARY-LONG.
 01 WS-HEALTH0             FLOAT-LONG.
 01 WS-LOST                FLOAT-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-END-Z               FLOAT-LONG.
 01 WS-END-Y               FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-SHAPE-C             BINARY-LONG.
 01 WS-SHAPE-S             BINARY-LONG.
 01 WS-STATE-C             BINARY-LONG.
 01 WS-STATE-S             BINARY-LONG.
 01 WS-SKY-C               BINARY-LONG.
 01 WS-BLOCK-C             BINARY-LONG.
 01 WS-NAME-OF             PIC X(24).
 01 WS-D1                  PIC -(3)9.
 01 WS-D2                  PIC -(3)9.
 01 WS-D3                  PIC -(3)9.
 01 WS-F1                  PIC -(4)9.99.
 01 WS-F2                  PIC -(4)9.99.
 01 WS-F3                  PIC -(4)9.99.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BF_FEATURE"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-ONLY = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BF_TRACE"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TRACE = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugstairfall: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM VARYING WS-FEATURE FROM 1 BY 1 UNTIL WS-FEATURE > 3
         PERFORM VARYING WS-RUN FROM 0 BY 1 UNTIL WS-RUN > 1
             IF WS-ONLY = 0 OR WS-ONLY = WS-FEATURE
                 PERFORM RUN-FEATURE
             END-IF
         END-PERFORM
     END-PERFORM
     STOP RUN.

 RUN-FEATURE.
     CALL "BF-BUILD" USING WS-FEATURE WS-ZS WS-NAME-OF
*>   The Player on the platform (feet at y -52), three blocks before the first step, facing +Z (yaw 0), health full.
     MOVE SPACES TO WS-LINE
     COMPUTE WS-F1 = WS-ZS - 2 + 0.5
     STRING "/tp Alice 4.5 -52 " FUNCTION TRIM(WS-F1) " 0 0" DELIMITED BY SIZE INTO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-N
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-N
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 1 TO IN-CAPTURED
     MOVE 0 TO PL-YAW PL-PITCH
     CALL "BF-TELEPORTS" USING WS-TP0
     MOVE PL-HEALTH TO WS-HEALTH0
     MOVE 0 TO WS-AIR
     IF WS-TRACE = 1
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
             MOVE 4 TO WS-TX
             COMPUTE WS-TY = -53 - WS-K
             COMPUTE WS-TZ = WS-ZS + WS-K
             CALL "PHYS-CELL-SHAPE" USING CLIENT-STATE WS-TX WS-TY WS-TZ WS-SHAPE-C
             CALL "WORLD-CELL" USING CLIENT-STATE WS-TX WS-TY WS-TZ WS-STATE-C WS-SKY-C WS-BLOCK-C
             CALL "BF-CORE-SHAPE" USING WS-TX WS-TY WS-TZ WS-SHAPE-S WS-STATE-S
             DISPLAY "  cell y " WS-TY " z " WS-TZ " client state " WS-STATE-C " shape " WS-SHAPE-C " core state " WS-STATE-S " shape " WS-SHAPE-S
         END-PERFORM
     END-IF
     IF WS-RUN = 1
         CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY-SPRINT WS-DOWN
     END-IF
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY-W WS-DOWN
     PERFORM VARYING WS-FRAME FROM 1 BY 1 UNTIL WS-FRAME > 130
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         IF PL-ON-GROUND = 0
             ADD 1 TO WS-AIR
         END-IF
         IF WS-TRACE = 1
             COMPUTE WS-F1 = PL-Y
             COMPUTE WS-F2 = PL-Z
             COMPUTE WS-F3 = PL-HEALTH
             MOVE PL-ON-GROUND TO WS-D1
             DISPLAY "  frame " WS-FRAME " y " WS-F1 " z " WS-F2 " ground " WS-D1 " health " WS-F3
         END-IF
     END-PERFORM
     MOVE PL-Z TO WS-END-Z
     MOVE PL-Y TO WS-END-Y
     COMPUTE WS-LOST = WS-HEALTH0 - PL-HEALTH
     CALL "BF-TELEPORTS" USING WS-TP1
     COMPUTE WS-TELEPORTS = WS-TP1 - WS-TP0
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY-W WS-UP
     IF WS-RUN = 1
         CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY-SPRINT WS-UP
     END-IF
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE WS-TELEPORTS TO WS-D1
     MOVE WS-AIR TO WS-D2
     COMPUTE WS-F1 = WS-LOST
     COMPUTE WS-F2 = WS-END-Z
     COMPUTE WS-F3 = WS-END-Y
     MOVE WS-RUN TO WS-D3
     DISPLAY "bugstairfall " FUNCTION TRIM(WS-NAME-OF) " run " FUNCTION TRIM(WS-D3) " lost " WS-F1 " teleports " FUNCTION TRIM(WS-D1)
         " off the ground " FUNCTION TRIM(WS-D2) " end z " WS-F2 " y " WS-F3
     MOVE SPACES TO TL-CASE
     STRING "acceptance bugstairfall given a descent of " FUNCTION TRIM(WS-NAME-OF) " in front of the Player when W is held (run 0 walk, 1 sprint: "
         FUNCTION TRIM(WS-D3) ") then the Player loses no health and the core sends no teleport"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "lost 0 teleports 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-LOST = 0 AND WS-TELEPORTS = 0
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         STRING "lost " FUNCTION TRIM(WS-F1) " teleports " FUNCTION TRIM(WS-D1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGSTAIRFALL-WALK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BF-TELEPORTS.
*> USING count out (BINARY-LONG): the sum of the teleport ids the core has sent over its used connections (one for the single player).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-USED(WS-I) = 1
             ADD CN-TELEPORT-ID(WS-I) TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BF-TELEPORTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BF-BUILD.
*> USING feature (1 stairs, 2 full blocks, 3 bottom slabs), first z of the descent (BINARY-LONG), name out (PIC X(24)): the cells x 2 to 7, z first - 3 to first + 20,
*> y -60 to -48 cleared to air, then a platform of stone (cells y -53, top -52) over z first - 3 to first - 1 and eight steps (sixteen slabs) from z first: step k (0 to 7) is a
*> column of stone up to y -53 - k (stone from the floor of y -61 up) with, on top, a stair facing north (high side to the north), a stone block or a bottom slab,
*> so that the stairs fall 0.5 a half block, the full blocks 1 a block and the slabs 0.5 a block. Beyond the eighth step the floor of the world (feet at y -60).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-P                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-ON-TOP              BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-HALF-K              BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 LINKAGE SECTION.
 01 L-FEATURE              BINARY-LONG.
 01 L-ZS                   BINARY-LONG.
 01 L-NAME                 PIC X(24).
 PROCEDURE DIVISION USING L-FEATURE L-ZS L-NAME.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1
             MOVE PL-DIM(WS-P) TO WS-DIM
         END-IF
     END-PERFORM
     COMPUTE WS-Z0 = L-ZS - 3
     COMPUTE WS-Z1 = L-ZS + 20
     PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
         PERFORM VARYING WS-Y FROM -60 BY 1 UNTIL WS-Y > -48
             PERFORM VARYING WS-X FROM 2 BY 1 UNTIL WS-X > 7
                 CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE SPACES TO WS-PAIRS
     EVALUATE L-FEATURE
         WHEN 1
             MOVE "oak_stairs" TO WS-KEY
             MOVE "facing=north,half=bottom,shape=straight,waterlogged=false" TO WS-PAIRS
             MOVE "stairs" TO L-NAME
         WHEN 2
             MOVE "stone" TO WS-KEY
             MOVE "full blocks" TO L-NAME
         WHEN OTHER
             MOVE "oak_slab" TO WS-KEY
             MOVE "type=bottom,waterlogged=false" TO WS-PAIRS
             MOVE "bottom slabs" TO L-NAME
     END-EVALUATE
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STEP
*>   The platform and the columns under the steps.
     PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z >= L-ZS
         PERFORM VARYING WS-X FROM 2 BY 1 UNTIL WS-X > 7
             PERFORM VARYING WS-Y FROM -60 BY 1 UNTIL WS-Y > -53
                 CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 7 TO WS-LAST
     IF L-FEATURE = 3
         MOVE 15 TO WS-LAST
     END-IF
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > WS-LAST
         COMPUTE WS-Z = L-ZS + WS-K
*>       Stairs and blocks: the step falls one cell per step. Slabs: an even step is a bottom slab (surface half a block above its cell), an odd one a
*>       full block (the cell under the last slab), so the surface falls 0.5 a block.
         COMPUTE WS-TOP = -53 - WS-K
         MOVE WS-STEP TO WS-ON-TOP
         IF L-FEATURE = 3
             COMPUTE WS-HALF-K = WS-K / 2
             COMPUTE WS-TOP = -53 - WS-HALF-K
             IF FUNCTION MOD(WS-K, 2) = 1
                 COMPUTE WS-TOP = WS-TOP - 1
                 MOVE WS-STONE TO WS-ON-TOP
             END-IF
         END-IF
         PERFORM VARYING WS-X FROM 2 BY 1 UNTIL WS-X > 7
             PERFORM VARYING WS-Y FROM -60 BY 1 UNTIL WS-Y >= WS-TOP
                 CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
             END-PERFORM
             CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-TOP WS-Z WS-ON-TOP
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BF-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BF-CORE-SHAPE.
*> USING x, y, z (BINARY-LONG), collision shape out, state out: what the core holds in the cell of the first player's dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-SHAPE L-STATE.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1
             MOVE PL-DIM(WS-P) TO WS-DIM
         END-IF
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM L-X L-Y L-Z L-STATE
     CALL "BSH-COLL-ID" USING L-STATE L-SHAPE
     GOBACK.
 END PROGRAM BF-CORE-SHAPE.
