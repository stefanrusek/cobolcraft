*> Convergence acceptance test of the operator report "movement across block height differences that should not cause problems blocks
*> movement and the screen shakes, like 2 pieces of logic are fighting; it hits a lot in villages" (try16 play; bug lane bugstep; docs/protocol/13
*> section 1.3 and 1.4, 51 section 6). One superflat survival world made through the client's single-player host from the generated packs
*> (CC_GENERATED_DIR; a pass without them). The core sets a village-like feature on the floor (a full block ledge, a slab, stairs, a carpet, a
*> dirt path, farmland, soul sand, snow, a trapdoor, a campfire, a chest, a flower pot) in front of the Player, who walks into it with W held (and
*> in a second run also Space held, the jump) through the real controls. The client moves by its own physics and tells the core with Move Player;
*> the core refuses a position it finds wrong with Player Position (a teleport: the shake). Counted per run: the teleports the core sent
*> (expected 0), the frames where the Player's z went backwards (expected 0) and whether the Player got over the feature (a step of at most 0.6
*> by walking; a higher one by jumping). BS_FEATURE=n runs only that feature, BS_TRACE=1 prints every frame.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGSTEP-VILLAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugstep-village".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "StepFlat".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 8.
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
 01 WS-KEY-SPACE           BINARY-LONG VALUE CC-KEY-SPACE.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-TP0                 BINARY-LONG.
 01 WS-TP1                 BINARY-LONG.
 01 WS-TELEPORTS           BINARY-LONG.
 01 WS-LAST-Z              FLOAT-LONG.
 01 WS-LAST-Y              FLOAT-LONG.
 01 WS-BACK                BINARY-LONG.
 01 WS-PASSED              BINARY-LONG.
 01 WS-END-Z               FLOAT-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-NEEDS-JUMP          BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-D1                  PIC -(3)9.
 01 WS-D2                  PIC -(3)9.
 01 WS-D3                  PIC -(3)9.
 01 WS-D4                  PIC -(3)9.
 01 WS-D5                  PIC -(3)9.
 01 WS-F1                  PIC -(4)9.99.
 01 WS-F2                  PIC -(4)9.99.
 01 WS-TX                 BINARY-LONG.
 01 WS-TY                 BINARY-LONG.
 01 WS-TZ                 BINARY-LONG.
 01 WS-SHAPE-C            BINARY-LONG.
 01 WS-SHAPE-S            BINARY-LONG.
 01 WS-STATE-C            BINARY-LONG.
 01 WS-STATE-S            BINARY-LONG.
 01 WS-SKY-C              BINARY-LONG.
 01 WS-BLOCK-C            BINARY-LONG.
 01 WS-NAME-OF             PIC X(16).
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
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_FEATURE"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-ONLY = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_TRACE"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TRACE = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugstep: no generated packs here, skipped" TO TL-CASE
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
     PERFORM VARYING WS-FEATURE FROM 1 BY 1 UNTIL WS-FEATURE > 12
         PERFORM VARYING WS-RUN FROM 0 BY 1 UNTIL WS-RUN > 1
             IF WS-ONLY = 0 OR WS-ONLY = WS-FEATURE
                 PERFORM RUN-FEATURE
             END-IF
         END-PERFORM
     END-PERFORM
     STOP RUN.

 RUN-FEATURE.
     CALL "BS-BUILD" USING WS-FEATURE WS-ZS WS-DEPTH WS-NEEDS-JUMP WS-NAME-OF
*>   Put the Player 3 blocks before the feature, facing +Z (yaw 0), on the floor.
     MOVE SPACES TO WS-LINE
     COMPUTE WS-F1 = WS-ZS - 3 + 0.5
     STRING "/tp Alice 4.5 -60 " FUNCTION TRIM(WS-F1) " 0 0" DELIMITED BY SIZE INTO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-N
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-N
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 1 TO IN-CAPTURED
     MOVE 0 TO PL-YAW PL-PITCH
     CALL "BS-TELEPORTS" USING WS-TP0
     MOVE PL-Z TO WS-LAST-Z
     MOVE PL-Y TO WS-LAST-Y
     MOVE 0 TO WS-BACK
     IF WS-TRACE = 1
         MOVE 4 TO WS-TX
         MOVE -60 TO WS-TY
         MOVE WS-ZS TO WS-TZ
         CALL "PHYS-CELL-SHAPE" USING CLIENT-STATE WS-TX WS-TY WS-TZ WS-SHAPE-C
         CALL "WORLD-CELL" USING CLIENT-STATE WS-TX WS-TY WS-TZ WS-STATE-C WS-SKY-C WS-BLOCK-C
         CALL "BS-CORE-SHAPE" USING WS-TX WS-TY WS-TZ WS-SHAPE-S WS-STATE-S
         DISPLAY "  cell client state " WS-STATE-C " shape " WS-SHAPE-C " core state " WS-STATE-S " shape " WS-SHAPE-S
     END-IF
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY-W WS-DOWN
     IF WS-RUN = 1
         CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY-SPACE WS-DOWN
     END-IF
     PERFORM VARYING WS-FRAME FROM 1 BY 1 UNTIL WS-FRAME > 80
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         IF PL-Z < WS-LAST-Z - 0.001
             ADD 1 TO WS-BACK
         END-IF
         IF WS-TRACE = 1
             COMPUTE WS-F1 = PL-Y
             COMPUTE WS-F2 = PL-Z
             MOVE PL-ON-GROUND TO WS-D1
             DISPLAY "  frame " WS-FRAME " y " WS-F1 " z " WS-F2 " ground " WS-D1
         END-IF
         MOVE PL-Z TO WS-LAST-Z
     END-PERFORM
     MOVE PL-Z TO WS-END-Z
     CALL "BS-TELEPORTS" USING WS-TP1
     COMPUTE WS-TELEPORTS = WS-TP1 - WS-TP0
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY-W WS-UP
     IF WS-RUN = 1
         CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY-SPACE WS-UP
     END-IF
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO WS-PASSED
     IF WS-END-Z > WS-ZS + WS-DEPTH + 0.5
         MOVE 1 TO WS-PASSED
     END-IF
*>   Walking alone gets over a step of at most 0.6; a higher one needs the jump. With the jump held everything gets over.
     MOVE 1 TO WS-WANT
     IF WS-RUN = 0 AND WS-NEEDS-JUMP = 1
         MOVE 0 TO WS-WANT
     END-IF
     MOVE WS-TELEPORTS TO WS-D1
     MOVE WS-BACK TO WS-D2
     MOVE WS-PASSED TO WS-D3
     MOVE WS-RUN TO WS-D4
     MOVE WS-WANT TO WS-D5
     COMPUTE WS-F1 = WS-END-Z
     DISPLAY "bugstep " FUNCTION TRIM(WS-NAME-OF) " jump " WS-RUN " teleports " FUNCTION TRIM(WS-D1)
         " backward " FUNCTION TRIM(WS-D2) " passed " FUNCTION TRIM(WS-D3) " end z " WS-F1
     MOVE SPACES TO TL-CASE
     STRING "acceptance bugstep given a " FUNCTION TRIM(WS-NAME-OF) " in front of the Player when W is held (jump held: "
         FUNCTION TRIM(WS-D4) ") then the core sends no teleport, the Player never moves backwards and gets over it as vanilla allows"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "teleports 0 backward 0 passed ok" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-TELEPORTS = 0 AND WS-BACK = 0 AND WS-PASSED = WS-WANT
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         STRING "teleports " FUNCTION TRIM(WS-D1) " backward " FUNCTION TRIM(WS-D2) " passed " FUNCTION TRIM(WS-D3)
             " wanted " FUNCTION TRIM(WS-D5) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGSTEP-VILLAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BS-TELEPORTS.
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
 END PROGRAM BS-TELEPORTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BS-BUILD.
*> USING feature (1 to 12), first z of the feature (BINARY-LONG), depth out (cells along z), needs jump out (1 when the highest step is more than 0.6),
*> name out (PIC X(16)): the floor of the core world (feet at y -60) cleared of the earlier feature in x 2 to 7, z first to first + 5, y -60 to -57, then
*> the feature set across x 2 to 7 on the floor from the first z on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-P                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FLOORY              BINARY-LONG.
 01 WS-FX                  BINARY-LONG VALUE 4.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 LINKAGE SECTION.
 01 L-FEATURE             BINARY-LONG.
 01 L-ZS                   BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-JUMP                 BINARY-LONG.
 01 L-NAME                 PIC X(16).
 PROCEDURE DIVISION USING L-FEATURE L-ZS L-DEPTH L-JUMP L-NAME.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1
             MOVE PL-DIM(WS-P) TO WS-DIM
         END-IF
     END-PERFORM
     MOVE -61 TO WS-FY
     COMPUTE WS-FZ = L-ZS - 2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-FLOOR
     PERFORM VARYING WS-Z FROM L-ZS BY 1 UNTIL WS-Z > L-ZS + 5
         PERFORM VARYING WS-X FROM 2 BY 1 UNTIL WS-X > 7
             CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-FY WS-Z WS-FLOOR
         END-PERFORM
         PERFORM VARYING WS-Y FROM -60 BY 1 UNTIL WS-Y > -57
             PERFORM VARYING WS-X FROM 2 BY 1 UNTIL WS-X > 7
                 CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE 2 TO L-DEPTH
     MOVE 0 TO L-JUMP
     MOVE SPACES TO WS-PAIRS
     EVALUATE L-FEATURE
         WHEN 1
             MOVE "stone" TO WS-KEY
             MOVE "full block" TO L-NAME
             MOVE 1 TO L-JUMP
         WHEN 2
             MOVE "oak_slab" TO WS-KEY
             MOVE "type=bottom" TO WS-PAIRS
             MOVE "bottom slab" TO L-NAME
         WHEN 3
             MOVE "oak_stairs" TO WS-KEY
             MOVE "facing=south,half=bottom,shape=straight,waterlogged=false" TO WS-PAIRS
             MOVE "stairs" TO L-NAME
         WHEN 4
             MOVE "white_carpet" TO WS-KEY
             MOVE "carpet" TO L-NAME
         WHEN 5
             MOVE "dirt_path" TO WS-KEY
             MOVE "dirt path" TO L-NAME
         WHEN 6
             MOVE "farmland" TO WS-KEY
             MOVE "farmland" TO L-NAME
         WHEN 7
             MOVE "soul_sand" TO WS-KEY
             MOVE "soul sand" TO L-NAME
         WHEN 8
             MOVE "snow" TO WS-KEY
             MOVE "layers=3" TO WS-PAIRS
             MOVE "snow layers" TO L-NAME
         WHEN 9
             MOVE "oak_trapdoor" TO WS-KEY
             MOVE "half=bottom,open=false,facing=north" TO WS-PAIRS
             MOVE "trapdoor" TO L-NAME
         WHEN 10
             MOVE "campfire" TO WS-KEY
             MOVE "campfire" TO L-NAME
         WHEN 11
             MOVE "chest" TO WS-KEY
             MOVE "chest" TO L-NAME
             MOVE 1 TO L-JUMP
         WHEN OTHER
             MOVE "flower_pot" TO WS-KEY
             MOVE "flower pot" TO L-NAME
     END-EVALUATE
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE -60 TO WS-FLOORY
     IF L-FEATURE >= 5 AND L-FEATURE <= 7
         MOVE -61 TO WS-FLOORY
     END-IF
*>   The stairs are a staircase of two steps then a flat top: stair, stone under a stair, stone and stone.
     IF L-FEATURE = 3
         MOVE 3 TO L-DEPTH
     END-IF
     PERFORM VARYING WS-Z FROM L-ZS BY 1 UNTIL WS-Z >= L-ZS + L-DEPTH
         PERFORM VARYING WS-X FROM 2 BY 1 UNTIL WS-X > 7
             MOVE WS-FLOORY TO WS-Y
             IF L-FEATURE = 3 AND WS-Z > L-ZS
                 CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
                 MOVE -59 TO WS-Y
             END-IF
             IF L-FEATURE = 3 AND WS-Z = L-ZS + 2
                 CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
             ELSE
                 CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BS-CORE-SHAPE.
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
 END PROGRAM BS-CORE-SHAPE.
