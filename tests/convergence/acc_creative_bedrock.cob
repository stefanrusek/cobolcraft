*> Convergence acceptance test, lane bugcreative (operator report of try15 "creative mode can't break bedrock"; docs/protocol/13 sections 2.2 and 2.5):
*> one standard superflat world (the generated packs of CC_GENERATED_DIR, default /tmp/cc-test/generated; a pass without them) is created through the client's
*> single-player host. The player holds nothing and aims the look ray at an unbreakable block (hardness -1: bedrock, barrier, end portal frame, structure block)
*> and holds the break button: in creative the block is gone from the core and from the client's replica (the controls send Start Destroy Block whatever the
*> hardness, and the server breaks at once), in survival it stays in both. Every step goes through the client's controls (CL-STEP, RAYCAST, CONTROLS-INPUT),
*> the memory connection and the core.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-CREATIVE-BEDROCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-creative-bedrock".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "CreativeBedrock".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 15.
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
 01 WS-I                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-DLOG                PIC X(4096).
 01 WS-HITS                BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CORE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-LEFT.
 01 WS-DOWN                BINARY-LONG.
 01 WS-OFFSET              PIC -9.
 01 WS-TAKE                PIC X(64).
 01 WS-BEFORE              BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-BLOCKS.
    05 FILLER              PIC X(60) VALUE "minecraft:bedrock".
    05 FILLER              PIC X(60) VALUE "minecraft:barrier".
    05 FILLER              PIC X(60) VALUE "minecraft:end_portal_frame".
    05 FILLER              PIC X(60) VALUE "minecraft:structure_block".
 01 WS-BLOCK-TABLE REDEFINES WS-BLOCKS.
    05 WS-BLOCK-TEXT       PIC X(60) OCCURS 4 TIMES.
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
         MOVE "acceptance creative bedrock: no generated packs here, skipped" TO TL-CASE
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
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     PERFORM WAIT-PLAY
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X)
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z)
*>   The core's dimension row of the player (the overworld of a standard world is not row 1 of the table).
     CALL "CORE-DIM-OF" USING WS-NAME WS-DIM

     PERFORM VARYING WS-M FROM 0 BY 1 UNTIL WS-M > 1
         IF WS-M = 0
             MOVE "/gamemode survival Alice" TO WS-LINE
         ELSE
             MOVE "/gamemode creative Alice" TO WS-LINE
         END-IF
         PERFORM SAY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             PERFORM BREAK-ONE
         END-PERFORM
     END-PERFORM
     STOP RUN.

 WAIT-PLAY.
     MOVE 0 TO WS-JOINED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 20 OR WS-JOINED = 1
         CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
         IF WS-JOINED = 0
             CALL "C$SLEEP" USING 1
         END-IF
     END-PERFORM.

*> Alice types WS-LINE; the frames then run until the core's reply is in her chat or 600 frames have passed.
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

*> Block WS-I of the table is set three cells in front of the player (x + 3; the wall torches have stone at x + 4), aimed at and broken with the left button held for 20 frames.
 BREAK-ONE.
     MOVE SPACES TO WS-LINE
     MOVE "/setblock ~4 ~ ~ minecraft:stone" TO WS-LINE
     PERFORM SAY
     MOVE SPACES TO WS-LINE
     STRING "/setblock ~3 ~ ~ " FUNCTION TRIM(WS-BLOCK-TEXT(WS-I)) DELIMITED BY SIZE INTO WS-LINE
     PERFORM SAY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-X = WS-BX + 3
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-BEFORE
     COMPUTE WS-TX = WS-BX + 3.5
     COMPUTE WS-TY = WS-BY + 0.4
     COMPUTE WS-TZ = WS-BZ + 0.5
     CALL "AIM-AT-CELL" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-CORE
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-BY WS-BZ WS-STATE WS-SKY WS-LIGHT
     MOVE SPACES TO TL-CASE
     IF WS-M = 0
         STRING "acceptance creative bedrock: in survival holding the break button on " FUNCTION TRIM(WS-BLOCK-TEXT(WS-I))
             " leaves it in the core and the client's replica" DELIMITED BY SIZE INTO TL-CASE
         MOVE "was there, core stays client stays" TO TL-EXPECTED
     ELSE
         STRING "acceptance creative bedrock: in creative holding the break button on " FUNCTION TRIM(WS-BLOCK-TEXT(WS-I))
             " removes it from the core and the client's replica" DELIMITED BY SIZE INTO TL-CASE
         MOVE "was there, core 0 client 0" TO TL-EXPECTED
     END-IF
     MOVE SPACES TO TL-OBSERVED
     IF WS-BEFORE = 0
         MOVE "was NOT there, " TO TL-OBSERVED(1:15)
         MOVE 16 TO WS-PTR
     ELSE
         MOVE "was there, " TO TL-OBSERVED(1:11)
         MOVE 12 TO WS-PTR
     END-IF
     IF WS-M = 0
         MOVE "core stays client stays" TO WS-TAKE
         IF WS-CORE = 0
             MOVE "core 0 client" TO WS-TAKE
         END-IF
         IF WS-CORE NOT = 0 AND WS-STATE = 0
             MOVE "core stays client 0" TO WS-TAKE
         END-IF
         STRING FUNCTION TRIM(WS-TAKE) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         MOVE WS-CORE TO WS-E1
         MOVE WS-STATE TO WS-E2
         STRING "core " FUNCTION TRIM(WS-E1) " client " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/setblock ~4 ~ ~ minecraft:air" TO WS-LINE
     PERFORM SAY.
 END PROGRAM ACC-CREATIVE-BEDROCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AIM-AT-CELL.
*> USING CLIENT-STATE, target x, y, z (FLOAT-LONG): the local player looks from the eye (feet + 1.6) at that point (yaw 0 faces +Z, 90 faces -X; positive pitch looks down).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     COMPUTE WS-DX = L-X - PL-X
     COMPUTE WS-DY = L-Y - PL-Y - 1.6
     COMPUTE WS-DZ = L-Z - PL-Z
     COMPUTE WS-NX = 0 - WS-DX
     CALL "ATAN2-DEG-CELL" USING WS-NX WS-DZ WS-A
     MOVE WS-A TO PL-YAW
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     CALL "ATAN2-DEG-CELL" USING WS-DY WS-H WS-A
     COMPUTE PL-PITCH = 0 - WS-A
     GOBACK.
 END PROGRAM AIM-AT-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ATAN2-DEG-CELL.
*> USING y, x, angle out (FLOAT-LONG, degrees, -180 to 180).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-X L-A.
     EVALUATE TRUE
         WHEN L-X > 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X)
         WHEN L-X < 0 AND L-Y >= 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) + FUNCTION PI
         WHEN L-X < 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) - FUNCTION PI
         WHEN L-Y > 0
             COMPUTE WS-A = FUNCTION PI / 2
         WHEN L-Y < 0
             COMPUTE WS-A = 0 - FUNCTION PI / 2
         WHEN OTHER
             MOVE 0 TO WS-A
     END-EVALUATE
     COMPUTE L-A = WS-A * 180 / FUNCTION PI
     GOBACK.
 END PROGRAM ATAN2-DEG-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-DIM-OF.
*> USING name (PIC X(16)), dimension row out: the core's dimension row of that online player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-DIM.
     MOVE 1 TO L-DIM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = L-NAME
             MOVE PL-DIM(WS-R) TO L-DIM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CORE-DIM-OF.
