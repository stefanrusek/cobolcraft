*> Convergence acceptance test, lane bugsign (operator report of try15 "can't edit sign text"; docs/protocol/31 part 3 sections 2.5 to 2.8, 40 part 8 sections 1.2 and 6, 05a 0x3D, 0x06, 05c 0x3E):
*> one standard superflat world (the generated packs of CC_GENERATED_DIR, default /tmp/cc-test/generated; a pass without them) is created through the client's single-player host. Every step goes
*> through the client's controls (CL-STEP, RAYCAST, CONTROLS-INPUT), the memory connection and the core. The player holds an oak sign and right-clicks the ground: the sign stands and the editor
*> screen opens; she types two lines and presses Done: the core's sign block entity holds them and the client's replica shows the same text; right-clicking the sign again opens the editor with the
*> text on it (the first line, cursor at its end); Escape closes it and sends the lines again; holding honeycomb on the sign waxes it (core and replica) and a click then opens no editor.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGSIGN-EDIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugsign-edit".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "SignEdit".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 8.
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
 01 WS-DLOG                PIC X(4096).
 01 WS-HITS                BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-RIGHT.
 01 WS-DOWN                BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE-TYPE             BINARY-LONG.
 01 WS-BE-WAXED            BINARY-LONG.
 01 WS-BE-LINE-1           PIC X(8).
 01 WS-BE-LINE-2           PIC X(8).
 01 WS-HOLD-COUNT          BINARY-LONG VALUE 5.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-COUNT          BINARY-LONG VALUE 0.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE ACT-SIGN-DONE.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-KEY-ENTER           BINARY-LONG VALUE CC-KEY-ENTER.
 01 WS-KEY-ESCAPE          BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-CROW                BINARY-LONG.
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
         MOVE "acceptance bugsign edit: no generated packs here, skipped" TO TL-CASE
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
     CALL "SIGN-CORE-ROW" USING WS-NAME WS-DIM WS-ROW
     MOVE "/gamemode creative Alice" TO WS-LINE
     PERFORM SAY

*>   The sign goes on the ground three cells in front: the right button held for one frame.
     MOVE "oak_sign" TO WS-KEY112
     PERFORM HOLD-ITEM
     COMPUTE WS-SX = WS-BX + 3
     COMPUTE WS-SZ = WS-BZ
     COMPUTE WS-TX = WS-BX + 3.5
     COMPUTE WS-TY = WS-BY - 0.1
     COMPUTE WS-TZ = WS-BZ + 0.5
     PERFORM CLICK-AT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     PERFORM READ-SIGN
     MOVE "acceptance bugsign edit: right-clicking the ground with an oak sign places a sign (sign block entity at the cell above) and opens the editor screen" TO TL-CASE
     MOVE "entity 7 screen sign" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-BE > 0
         IF WS-BE-TYPE = 7 AND SM-SCREEN = SCR-SIGN
             MOVE "entity 7 screen sign" TO TL-OBSERVED
         ELSE
             MOVE WS-BE-TYPE TO WS-E1
             MOVE SM-SCREEN TO WS-E2
             STRING "entity " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     ELSE
         MOVE "no sign entity" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Typing: line 1, Enter, line 2, Done.
     MOVE "Hello" TO WS-TEXT
     MOVE 5 TO WS-TEXT-LENGTH
     CALL "CV-TYPE" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY-ENTER
     MOVE "World" TO WS-TEXT
     CALL "CV-TYPE" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     PERFORM READ-SIGN
     MOVE "acceptance bugsign edit: after typing two lines and pressing Done the core's sign holds Hello and World and the world screen is back" TO TL-CASE
     MOVE "Hello|World screen world" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-BE > 0 AND SM-SCREEN = SCR-WORLD
         STRING WS-BE-LINE-1(1:5) "|" WS-BE-LINE-2(1:5) " screen world" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-SX WS-BY WS-SZ WS-NO WS-CROW
     MOVE "acceptance bugsign edit: the client's replica of the sign shows the same two lines on its front (Block Entity Data)" TO TL-CASE
     MOVE "Hello|World" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-CROW > 0
         IF SN-LEN(WS-CROW, 2, 1) = 5 AND SN-LEN(WS-CROW, 2, 2) = 5
             STRING SN-TEXT(WS-CROW, 2, 1)(1:5) "|" SN-TEXT(WS-CROW, 2, 2)(1:5) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Right-click the sign: the editor opens with the text, the cursor at the end of line 1.
     CALL "SIGN-CORE-HOLD" USING WS-ROW WS-ZERO WS-ZERO-COUNT
     COMPUTE WS-TX = WS-BX + 3.5
     COMPUTE WS-TY = WS-BY + 0.4
     COMPUTE WS-TZ = WS-BZ + 0.5
     PERFORM CLICK-AT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance bugsign edit: right-clicking the sign again opens the editor with Hello on line 1 and World on line 2, the cursor after Hello" TO TL-CASE
     MOVE "screen sign Hello|World cursor 5" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF SM-SCREEN = SCR-SIGN AND SG-LEN(1) = 5 AND SG-LEN(2) = 5
         MOVE SG-CURSOR TO WS-E1
         STRING "screen sign " SG-LINE-TEXT(1)(1:5) "|" SG-LINE-TEXT(2)(1:5) " cursor " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         MOVE SM-SCREEN TO WS-E1
         STRING "screen " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Escape closes it and sends the lines (the text stays).
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY-ESCAPE
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     PERFORM READ-SIGN
     MOVE "acceptance bugsign edit: Escape closes the editor and the text on the sign is kept (the lines are sent again)" TO TL-CASE
     MOVE "Hello|World screen world" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF SM-SCREEN = SCR-WORLD
         STRING WS-BE-LINE-1(1:5) "|" WS-BE-LINE-2(1:5) " screen world" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Honeycomb: waxed in the core and in the replica; a click then opens no editor.
     MOVE "honeycomb" TO WS-KEY112
     PERFORM HOLD-ITEM
     PERFORM CLICK-AT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     PERFORM READ-SIGN
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-SX WS-BY WS-SZ WS-NO WS-CROW
     MOVE "acceptance bugsign edit: honeycomb on the sign waxes it in the core and in the client's replica, and no editor opens" TO TL-CASE
     MOVE "core 1 replica 1 screen world" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-BE-WAXED TO WS-E1
     MOVE 0 TO WS-E2
     IF WS-CROW > 0
         MOVE SN-WAXED(WS-CROW) TO WS-E2
     END-IF
     IF SM-SCREEN = SCR-WORLD
         STRING "core " FUNCTION TRIM(WS-E1) " replica " FUNCTION TRIM(WS-E2) " screen world" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SIGN-CORE-HOLD" USING WS-ROW WS-ZERO WS-ZERO-COUNT
     PERFORM CLICK-AT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance bugsign edit: an empty-hand click on the waxed sign opens no editor" TO TL-CASE
     MOVE "screen world" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF SM-SCREEN = SCR-WORLD
         MOVE "screen world" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
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

*> Puts five of the item WS-KEY112 in the first hotbar slot of Alice's core inventory (the core decides what Use Item On does with it) and selects it.
 HOLD-ITEM.
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     CALL "SIGN-CORE-HOLD" USING WS-ROW WS-ITEM-ID WS-HOLD-COUNT.

*> The core's sign at WS-SX, WS-BY, WS-SZ: WS-BE (0 none), its type, waxed flag and first two front lines.
 READ-SIGN.
     CALL "SIGN-CORE-READ" USING WS-DIM WS-SX WS-BY WS-SZ WS-BE WS-BE-TYPE WS-BE-WAXED WS-BE-LINE-1 WS-BE-LINE-2.

*> Aims at WS-TX, WS-TY, WS-TZ, presses the right button for a frame and lets the frames run.
 CLICK-AT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "AIM-AT-CELL" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.
 END PROGRAM ACC-BUGSIGN-EDIT.

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
 PROGRAM-ID. SIGN-CORE-ROW.
*> USING name (PIC X(16)), dimension row out, player row out: the core's player row and dimension row of that online player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-DIM L-ROW.
     MOVE 1 TO L-DIM
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = L-NAME
             MOVE PL-DIM(WS-R) TO L-DIM
             MOVE WS-R TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SIGN-CORE-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-CORE-HOLD.
*> USING player row, item id, count: the first hotbar slot of that player's core inventory holds the stack and is selected.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT.
     MOVE L-ITEM TO PL-SLOT-ITEM(L-ROW, 1)
     MOVE L-COUNT TO PL-SLOT-COUNT(L-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(L-ROW, 1)
     MOVE 0 TO PL-HELD(L-ROW)
     GOBACK.
 END PROGRAM SIGN-CORE-HOLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-CORE-READ.
*> USING dimension row, x, y, z, entity index out (0 none), type out, waxed out, line 1 out (X(8)), line 2 out (X(8)): the core's block entity at that position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BE                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-WAXED                BINARY-LONG.
 01 L-LINE-1               PIC X(8).
 01 L-LINE-2               PIC X(8).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BE L-TYPE L-WAXED L-LINE-1 L-LINE-2.
     MOVE 0 TO L-TYPE L-WAXED
     MOVE SPACES TO L-LINE-1 L-LINE-2
     CALL "BE-FIND" USING L-DIM L-X L-Y L-Z L-BE
     IF L-BE > 0
         MOVE BE-TYPE(L-BE) TO L-TYPE
         MOVE BE-XI(L-BE, 1) TO L-WAXED
         MOVE BE-XT(L-BE, 1)(1:8) TO L-LINE-1
         MOVE BE-XT(L-BE, 2)(1:8) TO L-LINE-2
     END-IF
     GOBACK.
 END PROGRAM SIGN-CORE-READ.
