 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SIGNTEXT-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CLSIGN.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-signtext-render".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "SignText".
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

 01 WS-AREA.
    05 WS-V                OCCURS 8000 TIMES.
       10 WS-VX            FLOAT-SHORT.
       10 WS-VY            FLOAT-SHORT.
       10 WS-VZ            FLOAT-SHORT.
       10 WS-VU            FLOAT-SHORT.
       10 WS-VV            FLOAT-SHORT.
       10 WS-VB            FLOAT-SHORT.
       10 WS-VA            FLOAT-SHORT.
       10 WS-VSKY          FLOAT-SHORT.
       10 WS-VR            FLOAT-SHORT.
       10 WS-VG            FLOAT-SHORT.
       10 WS-VBLUE         FLOAT-SHORT.
 01 WS-CAPACITY            BINARY-LONG VALUE 8000.
 01 WS-COUNT               BINARY-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DRAW-SLOT           BINARY-LONG.
 01 WS-DRAW-COUNT          BINARY-LONG.
 01 WS-SCALED              BINARY-DOUBLE.
 01 WS-M1                  PIC -(8)9.
 01 WS-M2                  PIC -(8)9.
 01 WS-M3                  PIC -(8)9.
 01 WS-M4                  PIC -(8)9.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
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
         MOVE "acceptance signtext render: no generated packs here, skipped" TO TL-CASE
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

*>   The sign goes on the ground three cells in front (the placer's yaw faces +x, so the rotation is round((yaw + 180) / 22.5) = 4: the front looks west, at her); she types Hello and World.
     MOVE "oak_sign" TO WS-KEY112
     PERFORM HOLD-ITEM
     COMPUTE WS-SX = WS-BX + 3
     COMPUTE WS-SZ = WS-BZ
     COMPUTE WS-TX = WS-BX + 3.5
     COMPUTE WS-TY = WS-BY - 0.1
     COMPUTE WS-TZ = WS-BZ + 0.5
     PERFORM CLICK-AT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
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

*>   The kind and rotation the client reads from the state of the cell.
     CALL "WORLD-CELL" USING CLIENT-STATE WS-SX WS-BY WS-SZ WS-STATE WS-SKY WS-BLOCK
     CALL "SGR-KIND" USING CLIENT-STATE WS-STATE WS-KIND WS-KEY
     MOVE "acceptance signtext render: the placed sign is a standing sign (family 1) of rotation 4, front toward the placer" TO TL-CASE
     MOVE "1 4" TO TL-EXPECTED
     MOVE WS-KIND TO WS-M1
     MOVE WS-KEY TO WS-M2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-M1) " " FUNCTION TRIM(WS-M2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The frame the client just built draws the text: the sign slot with the UI atlas on the opaque pipeline, 10 glyph quads of 6 vertices (Hello and World, the front only).
     PERFORM FIND-DRAW
     MOVE "acceptance signtext render: the render list draws the sign text mesh (opaque pipeline, UI atlas) with 60 vertices after the editor is done" TO TL-CASE
     MOVE "draw 1 setup 2 vertices 60" TO TL-EXPECTED
     MOVE WS-DRAW TO WS-M1
     MOVE WS-DRAW-SLOT TO WS-M2
     MOVE WS-DRAW-COUNT TO WS-M4
     MOVE SPACES TO TL-OBSERVED
     STRING "draw " FUNCTION TRIM(WS-M1) " setup " FUNCTION TRIM(WS-M2) " vertices " FUNCTION TRIM(WS-M4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The geometry: the mesh from the live replica (SN rows, the state of the cell, the font).
     MOVE PL-X TO WS-EYE(1)
     COMPUTE WS-EYE(2) = PL-Y + 1.6
     MOVE PL-Z TO WS-EYE(3)
     PERFORM BUILD-MESH
     MOVE "acceptance signtext render: SGR-MESH makes ten glyph quads (60 vertices) for Hello and World on the front, none for the empty back" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 60 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CHECK-WORLD-BOX
     MOVE "acceptance signtext render: every vertex lies on the front plane x = sign + 0.4533 (rotation 4), z within the board, y within the four lines" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-SCALED ROUNDED = (WS-VR(1) + WS-VG(1) + WS-VBLUE(1)) * 1000
     MOVE "acceptance signtext render: black text not glowing is drawn black (tint 0) and lit by the cell's light (brightness above 0)" TO TL-CASE
     MOVE "0 lit" TO TL-EXPECTED
     MOVE WS-SCALED TO WS-M1
     MOVE SPACES TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     IF WS-VB(1) > 0 OR WS-VSKY(1) > 0
         STRING FUNCTION TRIM(WS-M1) " lit" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The 64 block rule: the centre of the block 63.9 away is still drawn, exactly 64 away is not.
     COMPUTE WS-EYE(1) = WS-SX + 0.5 + 63.9
     MOVE WS-BY TO WS-EYE(2)
     MOVE WS-SZ TO WS-EYE(3)
     PERFORM BUILD-MESH
     MOVE WS-COUNT TO WS-M1
     COMPUTE WS-EYE(1) = WS-SX + 0.5 + 64
     PERFORM BUILD-MESH
     MOVE WS-COUNT TO WS-M2
     MOVE "acceptance signtext render: a sign whose centre is 63.9 blocks from the camera is drawn (60 vertices), one 64 away is not (0)" TO TL-CASE
     MOVE "60 0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-M1) " " FUNCTION TRIM(WS-M2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A glow ink sac on the front: the text glows (full light, black text with the cream outline always: 9 passes of 10 quads = 540 vertices).
     MOVE "glow_ink_sac" TO WS-KEY112
     PERFORM HOLD-ITEM
     COMPUTE WS-TX = WS-BX + 3.5
     COMPUTE WS-TY = WS-BY + 0.4
     COMPUTE WS-TZ = WS-BZ + 0.5
     PERFORM CLICK-AT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-X TO WS-EYE(1)
     COMPUTE WS-EYE(2) = PL-Y + 1.6
     MOVE PL-Z TO WS-EYE(3)
     PERFORM BUILD-MESH
     MOVE "acceptance signtext render: after a glow ink sac the black text has its outline: 8 outline passes and the fill of ten quads, 540 vertices" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 540 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-SCALED ROUNDED = WS-VR(1) * 255
     MOVE WS-SCALED TO WS-M1
     COMPUTE WS-SCALED ROUNDED = WS-VG(1) * 255
     MOVE WS-SCALED TO WS-M2
     COMPUTE WS-SCALED ROUNDED = WS-VBLUE(1) * 255
     MOVE WS-SCALED TO WS-M3
     COMPUTE WS-SCALED ROUNDED = WS-VB(540) * 255
     MOVE WS-SCALED TO WS-M4
     MOVE "acceptance signtext render: the outline of glowing black text is cream 0xF0EBCC (240 235 204), the fill black at full brightness" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "240 235 204 fill 255" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-SCALED ROUNDED = (WS-VR(540) + WS-VG(540) + WS-VBLUE(540)) * 1000
     IF WS-SCALED = 0
         STRING FUNCTION TRIM(WS-M1) " " FUNCTION TRIM(WS-M2) " " FUNCTION TRIM(WS-M3) " fill " FUNCTION TRIM(WS-M4) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIND-DRAW
     MOVE "acceptance signtext render: the render list now draws 540 vertices of sign text" TO TL-CASE
     MOVE "540" TO TL-EXPECTED
     MOVE WS-DRAW-COUNT TO WS-M1
     MOVE FUNCTION TRIM(WS-M1) TO TL-OBSERVED
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

*> Puts five of the item WS-KEY112 in the first hotbar slot of Alice's core inventory and selects it.
 HOLD-ITEM.
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     CALL "SIGN-CORE-HOLD" USING WS-ROW WS-ITEM-ID WS-HOLD-COUNT.

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

*> WS-COUNT, WS-V: SGR-MESH of the live client state for the eye WS-EYE (eye-relative vertices).
 BUILD-MESH.
     CALL "SGR-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-V(1) WS-CAPACITY WS-COUNT.

*> WS-DRAW 1 when the last render list draws MESH-SLOT-SIGNS (WS-DRAW-SLOT its pipeline-texture check as 2 = UI atlas on the opaque pipeline), WS-DRAW-COUNT its uploaded vertices.
 FIND-DRAW.
     MOVE 0 TO WS-DRAW WS-DRAW-SLOT WS-DRAW-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-SIGNS
             MOVE 1 TO WS-DRAW
             IF RL-D-PIPELINE(WS-I) = CC-PIPE-OPAQUE AND RL-D-TEX(WS-I) = CC-TEX-UI
                 MOVE 2 TO WS-DRAW-SLOT
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) = MESH-SLOT-SIGNS
             MOVE RL-U-COUNT(WS-I) TO WS-DRAW-COUNT
         END-IF
     END-PERFORM.

*> WS-BAD = the number of vertices of WS-V (WS-COUNT of them, eye-relative) that are not on the front plane of the sign (WS-SX, WS-BY, WS-SZ, rotation 4): world x within 0.004 of
*> sign x + 0.4533333 (the pull toward the eye is at most 0.0004 of the 3 to 4 blocks), z within 0.30 to 0.70 of the cell (the glyph boxes are 8 wide, wider than the advances), y within 0.64 to 1.05.
 CHECK-WORLD-BOX.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         COMPUTE WS-RX = WS-VX(WS-I) + WS-EYE(1) - WS-SX
         COMPUTE WS-RY = WS-VY(WS-I) + WS-EYE(2) - WS-BY
         COMPUTE WS-RZ = WS-VZ(WS-I) + WS-EYE(3) - WS-SZ
         IF WS-RX < 0.4493333 OR WS-RX > 0.4573333 OR WS-RZ < 0.30 OR WS-RZ > 0.70 OR WS-RY < 0.64 OR WS-RY > 1.05
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM.
 END PROGRAM ACC-SIGNTEXT-RENDER.

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
