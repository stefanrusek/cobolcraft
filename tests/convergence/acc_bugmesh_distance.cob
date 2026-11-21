*> Convergence acceptance test of the operator report "lots of blocks aren't rendering: logs, leaf litter, oak leaves, crafting bench, path blocks"
*> (try14 play, render distance 12; bug lane bugmesh): the picture is incomplete for a long time because the sections of the chunks received are
*> meshed too slowly, not because a block state bakes nothing. One standard single-player world (the host's in-process core, real generated chunks
*> of CC_GENERATED_DIR, view distance BM_VIEW, the running client's mesh credit on, as CL-RUN does) is stepped frame by frame: after the frames this
*> test allows, every section whose cells expose a face (an opaque cell with a non-opaque neighbour inside the chunk) has been meshed, its mesh has
*> been listed as an upload and it is in the draw list of the render lists of four views (north, east, south, west); no section is left dirty
*> and no section a chunk received left out of the queue.
*> BM_VIEW (default 8; the report was 12) is the view distance, BM_FRAMES (default 9000: the standard generator's chunks arrive at most one a tick since lane perfsteady, the world of view 8 is complete at about 6200 frames) the frames allowed after the join, BM_SEED the seed text, BM_CREDIT (default
*> 1) the credit switch; BM_TRACE=1 prints progress lines (every 25 frames) and the per-frame cost.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGMESH-DISTANCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugmesh-distance".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "BugMesh".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 7.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-ENV                 PIC X(64).
 01 WS-VIEW                BINARY-LONG VALUE 8.
 01 WS-FRAMES              BINARY-LONG VALUE 9000.
 01 WS-CREDIT              BINARY-LONG VALUE 1.
 01 WS-TRACE               BINARY-LONG VALUE 0.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-STEP-US             BINARY-DOUBLE.
 01 WS-STEP-MAX            BINARY-DOUBLE VALUE 0.
 01 WS-STEP-SUM            BINARY-DOUBLE VALUE 0.
 01 WS-MESH-SUM            BINARY-DOUBLE VALUE 0.
 01 WS-MESH-MAX            BINARY-DOUBLE VALUE 0.
 01 WS-MESHED-SUM          BINARY-LONG VALUE 0.
 01 WS-CHUNKS              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-DIRTY-CONTENT       BINARY-LONG.
 01 WS-NEVER               BINARY-LONG.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-DONE-AT             BINARY-LONG VALUE 0.
 01 WS-BASE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DRAWN.
    05 WS-DRAW-FLAG        PIC 9 OCCURS 52300 TIMES.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-NSTATE              BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-EXPOSED             BINARY-LONG.
 01 WS-SECTIONS-EXPOSED    BINARY-LONG VALUE 0.
 01 WS-NOMESH              BINARY-LONG VALUE 0.
 01 WS-NOUPLOAD            BINARY-LONG VALUE 0.
 01 WS-NODRAW              BINARY-LONG VALUE 0.
 01 WS-STILL-DIRTY         BINARY-LONG VALUE 0.
 01 WS-MESHES              BINARY-LONG VALUE 0.
 01 WS-VIEW-N              BINARY-LONG.
 01 WS-MAX-DRAWS           BINARY-LONG VALUE 0.
 01 WS-MAX-UPLOADS         BINARY-LONG VALUE 0.
 01 WS-D3                  PIC 9(7).
 01 WS-D3B                 PIC 9(7).
 01 WS-D3C                 PIC 9(7).
 01 WS-D3D                 PIC 9(7).
 01 WS-US7                 PIC 9(9).
 01 WS-US7B                PIC 9(9).
 01 WS-US7C                PIC 9(9).
 01 WS-US7D                PIC 9(9).
 01 B-CELLS                PIC X(196608) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BM_VIEW"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-VIEW = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BM_FRAMES"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-FRAMES = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BM_CREDIT"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-CREDIT = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BM_TRACE"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TRACE = FUNCTION NUMVAL(WS-ENV)
     END-IF
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BM_SEED"
     MOVE WS-ENV TO CS-SEED-TEXT
     MOVE WS-VIEW TO CS-VIEW-DISTANCE
     MOVE CORE-SETTINGS TO SP-SETTINGS
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     MOVE 0 TO WS-JOINED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 20 OR WS-JOINED = 1
         CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
         IF WS-JOINED = 0
             CALL "C$SLEEP" USING 1
         END-IF
     END-PERFORM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
*>   The running client's frame: the credit on (CL-RUN), every section in the render list (no frustum culling of the entity figures; the section draws
*>   are collected over four views below).
     IF WS-CREDIT = 1
         MOVE 1 TO MB-CREDIT-ON
         MOVE CL-MESH-CREDIT-US TO MB-CREDIT
     END-IF
     MOVE 0 TO WS-QUIET WS-DONE-AT
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-FRAMES OR WS-QUIET >= 10
         CALL "MESH-CLOCK" USING CLIENT-STATE WS-T0
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         CALL "MESH-CLOCK" USING CLIENT-STATE WS-T1
         COMPUTE WS-STEP-US = WS-T1 - WS-T0
         ADD WS-STEP-US TO WS-STEP-SUM
         IF WS-STEP-US > WS-STEP-MAX
             MOVE WS-STEP-US TO WS-STEP-MAX
         END-IF
         ADD MB-LAST-US TO WS-MESH-SUM
         IF MB-LAST-US > WS-MESH-MAX
             MOVE MB-LAST-US TO WS-MESH-MAX
         END-IF
         ADD MB-MESHED TO WS-MESHED-SUM
         MOVE 0 TO WS-DIRTY WS-DIRTY-CONTENT WS-CHUNKS WS-NEVER
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
             IF WR-USED(WS-R) = 1
                 ADD 1 TO WS-CHUNKS
                 SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-R)
                 SET ADDRESS OF B-CELLS TO ADDRESS OF CE-CHUNK
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                     IF WR-DIRTY(WS-R, WS-S) = 1
                         ADD 1 TO WS-DIRTY
                         COMPUTE WS-BASE = (WS-S - 1) * 4096
                         IF B-CELLS(WS-BASE * 2 + 1:8192) NOT = LOW-VALUES
                             ADD 1 TO WS-DIRTY-CONTENT
                             IF WR-MESHED(WS-R, WS-S) = 0
                                 ADD 1 TO WS-NEVER
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
         IF WS-TRACE = 1 AND FUNCTION MOD(WS-F, 25) = 0
             MOVE WS-CHUNKS TO WS-D3
             MOVE WS-DIRTY TO WS-D3B
             MOVE WS-DIRTY-CONTENT TO WS-D3C
             MOVE WS-MESHED-SUM TO WS-D3D
             COMPUTE WS-US7 = WS-STEP-SUM / WS-F
             COMPUTE WS-US7B = WS-MESH-SUM / WS-F
             COMPUTE WS-US7C = WS-MESH-MAX
             MOVE BM-NEXT TO WS-US7D
             DISPLAY "frame " WS-F " chunks " WS-D3 " dirty " WS-D3B " dirty-with-cells " WS-D3C " never-meshed " WS-NEVER " meshed " WS-D3D
                 " mean-step-us " WS-US7 " mean-mesh-us " WS-US7B " max-mesh-us " WS-US7C " bm-next " WS-US7D
         END-IF
         IF WS-NEVER = 0 AND WS-CHUNKS >= (2 * WS-VIEW + 1) * (2 * WS-VIEW + 1) - 4 * WS-VIEW
             ADD 1 TO WS-QUIET
             IF WS-DONE-AT = 0
                 MOVE WS-F TO WS-DONE-AT
             END-IF
         ELSE
             MOVE 0 TO WS-QUIET
             MOVE 0 TO WS-DONE-AT
         END-IF
     END-PERFORM
     MOVE WS-DONE-AT TO WS-D3
     MOVE WS-CHUNKS TO WS-D3B
     MOVE WS-NEVER TO WS-D3C
     COMPUTE WS-US7 = WS-STEP-SUM / (WS-F - 1)
     COMPUTE WS-US7B = WS-MESH-SUM / (WS-F - 1)
     COMPUTE WS-US7C = WS-STEP-MAX
     DISPLAY "view " WS-VIEW " frames run " WS-F " complete at " WS-D3 " chunks " WS-D3B " never-meshed " WS-D3C
         " mean-step-us " WS-US7 " mean-mesh-us " WS-US7B " max-step-us " WS-US7C
     MOVE BM-NEXT TO WS-US7D
     DISPLAY "baked rows used (BM-NEXT) " WS-US7D " of " CL-MAX-ROWS " mode " BM-MODE

*>   The render lists of four views: the draws of every section with vertices.
     INITIALIZE WS-DRAWN
     MOVE 0 TO WS-MAX-DRAWS WS-MAX-UPLOADS
     PERFORM VARYING WS-VIEW-N FROM 0 BY 1 UNTIL WS-VIEW-N > 3
         COMPUTE PL-YAW = WS-VIEW-N * 90
         MOVE 0 TO PL-PITCH
         CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
         IF RL-DRAW-COUNT > WS-MAX-DRAWS
             MOVE RL-DRAW-COUNT TO WS-MAX-DRAWS
         END-IF
         IF RL-UPLOAD-COUNT > WS-MAX-UPLOADS
             MOVE RL-UPLOAD-COUNT TO WS-MAX-UPLOADS
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
             IF RL-D-SLOT(WS-I) >= MESH-SLOT-BASE AND RL-D-SLOT(WS-I) < MESH-SLOT-ENTITIES
                 COMPUTE WS-SLOT = RL-D-SLOT(WS-I) - MESH-SLOT-BASE + 1
                 MOVE 1 TO WS-DRAW-FLAG(WS-SLOT)
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-MAX-DRAWS TO WS-D3
     MOVE WS-MAX-UPLOADS TO WS-D3B
     DISPLAY "max draws in one list " WS-D3 " max uploads in one list " WS-D3B

*>   Every section whose cells expose a face.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-R)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 MOVE 0 TO WS-EXPOSED
                 PERFORM VARYING WS-LY FROM 1 BY 1 UNTIL WS-LY > 14
                  PERFORM VARYING WS-LZ FROM 1 BY 1 UNTIL WS-LZ > 14
                   PERFORM VARYING WS-LX FROM 1 BY 1 UNTIL WS-LX > 14 OR WS-EXPOSED > 0
                     COMPUTE WS-CELL = (WS-S - 1) * 4096 + WS-LY * 256 + WS-LZ * 16 + WS-LX + 1
                     MOVE CE-STATE(WS-CELL) TO WS-STATE
                     IF WS-STATE > 0 AND ST-OPAQUE(WS-STATE + 1) = 1
                         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
                             EVALUATE WS-D
                                 WHEN 1 COMPUTE WS-NB = WS-CELL - 256
                                 WHEN 2 COMPUTE WS-NB = WS-CELL + 256
                                 WHEN 3 COMPUTE WS-NB = WS-CELL - 16
                                 WHEN 4 COMPUTE WS-NB = WS-CELL + 16
                                 WHEN 5 COMPUTE WS-NB = WS-CELL - 1
                                 WHEN 6 COMPUTE WS-NB = WS-CELL + 1
                             END-EVALUATE
                             MOVE CE-STATE(WS-NB) TO WS-NSTATE
                             IF WS-NSTATE = 0 OR ST-OPAQUE(WS-NSTATE + 1) = 0
                                 ADD 1 TO WS-EXPOSED
                             END-IF
                         END-PERFORM
                     END-IF
                   END-PERFORM
                  END-PERFORM
                 END-PERFORM
                 IF WS-EXPOSED > 0
                     ADD 1 TO WS-SECTIONS-EXPOSED
                     COMPUTE WS-SLOT = (WS-R - 1) * CL-MAX-SECTIONS * 2 + (WS-S - 1) * 2 + 1
                     IF WR-OP-COUNT(WS-R, WS-S) + WR-TR-COUNT(WS-R, WS-S) = 0
                         ADD 1 TO WS-NOMESH
                     END-IF
                     IF WR-DIRTY(WS-R, WS-S) = 1
                         ADD 1 TO WS-STILL-DIRTY
                     END-IF
                     IF WR-UPLOAD(WS-R, WS-S) = 1
                         ADD 1 TO WS-NOUPLOAD
                     END-IF
                     IF WR-OP-COUNT(WS-R, WS-S) > 0 AND WS-DRAW-FLAG(WS-SLOT) = 0
                         ADD 1 TO WS-NODRAW
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE WS-SECTIONS-EXPOSED TO WS-D3
     MOVE WS-NOMESH TO WS-D3B
     MOVE WS-STILL-DIRTY TO WS-D3C
     DISPLAY "sections with an exposed face " WS-D3 " without mesh " WS-D3B " still dirty " WS-D3C

     MOVE "acceptance bugmesh: given a single-player world when the player has joined then chunks were received (the cases below are not vacuous)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "joined 1 sections with faces more than 100" TO TL-EXPECTED
     IF WS-JOINED = 1 AND WS-SECTIONS-EXPOSED > 100
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE WS-SECTIONS-EXPOSED TO WS-D3
         MOVE WS-JOINED TO WS-D3B
         STRING "joined " WS-D3B " sections with faces " WS-D3 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance bugmesh: given a single-player world at the view distance when the frames the picture is allowed have run then every section "
         & "with an exposed face has a mesh" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "without mesh 0" TO TL-EXPECTED
     MOVE WS-NOMESH TO WS-D3
     MOVE WS-SECTIONS-EXPOSED TO WS-D3B
     IF WS-NOMESH = 0
         MOVE "without mesh 0" TO TL-OBSERVED
     ELSE
         STRING "without mesh " WS-D3 " of " WS-D3B DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance bugmesh: given the same world then every section with an exposed face is in the draw list of a view and none is left to upload"
         TO TL-CASE
     MOVE "no draw, no upload 0 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-NODRAW = 0 AND WS-NOUPLOAD = 0
         MOVE "no draw, no upload 0 0" TO TL-OBSERVED
     ELSE
         MOVE WS-NODRAW TO WS-D3
         MOVE WS-NOUPLOAD TO WS-D3B
         STRING "no draw, no upload " WS-D3 " " WS-D3B DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance bugmesh: given the same world then it is complete at the frame the picture is allowed (no section waits that was never meshed; one dirty only to be meshed again keeps the mesh it has)"
         TO TL-CASE
     MOVE "dirty 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-NEVER = 0 AND WS-DONE-AT > 0
         MOVE "dirty 0" TO TL-OBSERVED
     ELSE
         MOVE WS-NEVER TO WS-D3
         STRING "dirty " WS-D3 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGMESH-DISTANCE.
