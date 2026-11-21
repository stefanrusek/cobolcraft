*> Measurement program (002-lane-bugvlag; operator report "much smoother, but not in the village, wow that is laggy"): the CPU cost of the client frame with the player standing in a village against
*> the same world in an empty field, per phase. One standard single-player world (the host's in-process core, real generated chunks of CC_GENERATED_DIR, seed VB_SEED, default 12345) is opened, the player
*> is teleported (`/tp`) to the block (VB_X, VB_Y, VB_Z) and the world is stepped until every chunk has arrived and is meshed. Then every section of the replica is meshed again and timed (the sections
*> within 3 chunks of the player, which hold the village, against all the others, and the five dearest), and VB_FRAMES (default 100) frames are measured: user CPU time (C clock()) per CV-STEP (the core
*> tick, the packets, the client tick, the mesh queue, the screen model, the render list) and, run again on the same state, per phase: RENDER-LIST-BUILD, ENTITIES-MESH, MESH-DIRTY with nothing to mesh,
*> SCREEN-BUILD and UI-RENDER. The window's submit needs a window and is not part of it.
*>   VB_X VB_Y VB_Z   the block to teleport to (default: -136 120 -824, the village of seed 12345 at chunk (-9, -52) found by test_bench_village)
*>   VB_VIEW          the view distance (default 4)    VB_FRAMES  the frames measured (default 100)    VB_SEED  the seed text    VB_DIR  folder under build/ (default conv-vb)
*> Not an acceptance test: the file is not named acc_ and is built by hand (scratchpad/bugvlag/mkclientbench.sh); it prints `VBC ...` lines.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BENCH-VILLAGE-CLIENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-vb".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 13.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "VillageBench".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 12.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-ENV                 PIC X(64).
 01 WS-VIEW                BINARY-LONG VALUE 4.
 01 WS-FRAMES              BINARY-LONG VALUE 100.
 01 WS-TX                  BINARY-LONG VALUE -136.
 01 WS-TY                  BINARY-LONG VALUE 120.
 01 WS-TZ                  BINARY-LONG VALUE -824.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-CHUNKS              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-SUM-STEP            BINARY-DOUBLE VALUE 0.
 01 WS-SUM-RLB             BINARY-DOUBLE VALUE 0.
 01 WS-SUM-EM              BINARY-DOUBLE VALUE 0.
 01 WS-SUM-MD              BINARY-DOUBLE VALUE 0.
 01 WS-SUM-UI              BINARY-DOUBLE VALUE 0.
 01 WS-MAX-STEP            BINARY-DOUBLE VALUE 0.
 01 WS-SUM-ENT             BINARY-DOUBLE VALUE 0.
 01 WS-MEAN                BINARY-DOUBLE.
 01 WS-D9                  PIC -(8)9.
 01 WS-D9B                 PIC -(8)9.
 01 WS-D9C                 PIC -(8)9.
 01 WS-D9D                 PIC -(8)9.
 01 WS-D9E                 PIC -(8)9.
 01 WS-D9F                 PIC -(8)9.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-VIEW-YAW            FLOAT-LONG.
 01 WS-VIEW-PITCH          FLOAT-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-PCX                 BINARY-LONG.
 01 WS-PCZ                 BINARY-LONG.
 01 WS-NEAR-US             BINARY-DOUBLE VALUE 0.
 01 WS-FAR-US              BINARY-DOUBLE VALUE 0.
 01 WS-NEAR-N              BINARY-LONG VALUE 0.
 01 WS-FAR-N               BINARY-LONG VALUE 0.
 01 WS-NEAR-V              BINARY-DOUBLE VALUE 0.
 01 WS-FAR-V               BINARY-DOUBLE VALUE 0.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-TOP.
    05 WS-TOP-ENTRY OCCURS 5 TIMES.
       10 WS-TOP-US        BINARY-DOUBLE VALUE 0.
       10 WS-TOP-CX        BINARY-LONG.
       10 WS-TOP-CZ        BINARY-LONG.
       10 WS-TOP-S         BINARY-LONG.
       10 WS-TOP-V         BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DIRTY-NOW           BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-SUM-MESHED          BINARY-LONG VALUE 0.
 01 WS-SUM-MESH-US         BINARY-DOUBLE VALUE 0.
 01 WS-FRAMES-MESHED       BINARY-LONG VALUE 0.
 01 WS-VERTS               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-XE                  PIC -(8)9.
 01 WS-YE                  PIC -(8)9.
 01 WS-ZE                  PIC -(8)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_VIEW"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-VIEW = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_FRAMES"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-FRAMES = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_X"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TX = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_Y"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TY = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_Z"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TZ = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_DIR"
     IF WS-ENV NOT = SPACES
         MOVE SPACES TO WS-DIR
         STRING "build/" FUNCTION TRIM(WS-ENV) DELIMITED BY SIZE INTO WS-DIR
         COMPUTE WS-DIR-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-DIR))
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
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_SEED"
     IF WS-ENV = SPACES
         MOVE "12345" TO WS-ENV
     END-IF
     MOVE SCR-CREATE-WORLD TO SM-SCREEN
     MOVE WS-ENV TO SM-EDIT-SEED
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ENV TRAILING)) TO SM-EDIT-SEED-LENGTH
     MOVE WS-VIEW TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
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
*>   Day with the clock stopped (the mobs of the day only, no burning), then the teleport to the place measured.
     MOVE "/time set 6000" TO WS-TEXT
     MOVE 14 TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "/gamerule advance_time false" TO WS-TEXT
     MOVE 28 TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE WS-TX TO WS-XE
     MOVE WS-TY TO WS-YE
     MOVE WS-TZ TO WS-ZE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     STRING "/tp @s " DELIMITED BY SIZE FUNCTION TRIM(WS-XE) DELIMITED BY SIZE " " DELIMITED BY SIZE FUNCTION TRIM(WS-YE) DELIMITED BY SIZE
         " " DELIMITED BY SIZE FUNCTION TRIM(WS-ZE) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     COMPUTE WS-TEXT-LENGTH = WS-PTR - 1
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
*>   Every chunk arrived and every section with blocks meshed.
     MOVE 0 TO WS-QUIET
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 60000 OR WS-QUIET >= 200
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         MOVE 0 TO WS-DIRTY WS-CHUNKS
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
             IF WR-USED(WS-R) = 1
                 ADD 1 TO WS-CHUNKS
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                     IF WR-DIRTY(WS-R, WS-S) = 1
                         ADD 1 TO WS-DIRTY
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
         COMPUTE WS-PCX = FUNCTION INTEGER(PL-X / 16)
         COMPUTE WS-PCZ = FUNCTION INTEGER(PL-Z / 16)
         IF WS-DIRTY = 0 AND WS-CHUNKS >= (2 * WS-VIEW + 1) * (2 * WS-VIEW + 1) - 4 * WS-VIEW AND PL-Y < WS-TY - 1
             ADD 1 TO WS-QUIET
         ELSE
             MOVE 0 TO WS-QUIET
         END-IF
     END-PERFORM
     MOVE WS-F TO WS-D9
     MOVE WS-CHUNKS TO WS-D9B
     DISPLAY "VBC world complete after " WS-D9 " frames, chunks " WS-D9B
     COMPUTE WS-PCX = FUNCTION INTEGER(PL-X / 16)
     COMPUTE WS-PCZ = FUNCTION INTEGER(PL-Z / 16)
     MOVE PL-X TO WS-D9
     MOVE PL-Y TO WS-D9B
     MOVE PL-Z TO WS-D9C
     DISPLAY "VBC player at " WS-D9 " " WS-D9B " " WS-D9C
*>   Every section meshed again and timed: near the player (3 chunks) against the rest, and the five dearest.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 CALL STATIC "clock" RETURNING WS-T0
                 CALL "MESH-SECTION" USING CLIENT-STATE WS-R WS-S
                 CALL STATIC "clock" RETURNING WS-T1
                 COMPUTE WS-US = WS-T1 - WS-T0
                 COMPUTE WS-VERTS = WR-OP-COUNT(WS-R, WS-S) + WR-TR-COUNT(WS-R, WS-S)
                 COMPUTE WS-QX = WR-CX(WS-R) - WS-PCX
                 COMPUTE WS-QZ = WR-CZ(WS-R) - WS-PCZ
                 IF WS-QX >= -3 AND WS-QX <= 3 AND WS-QZ >= -3 AND WS-QZ <= 3
                     ADD WS-US TO WS-NEAR-US
                     ADD 1 TO WS-NEAR-N
                     ADD WS-VERTS TO WS-NEAR-V
                 ELSE
                     ADD WS-US TO WS-FAR-US
                     ADD 1 TO WS-FAR-N
                     ADD WS-VERTS TO WS-FAR-V
                 END-IF
                 MOVE 0 TO WS-SLOT
                 PERFORM VARYING WS-K FROM 5 BY -1 UNTIL WS-K < 1
                     IF WS-US > WS-TOP-US(WS-K)
                         MOVE WS-K TO WS-SLOT
                     END-IF
                 END-PERFORM
                 IF WS-SLOT > 0
                     PERFORM VARYING WS-K FROM 5 BY -1 UNTIL WS-K <= WS-SLOT
                         MOVE WS-TOP-ENTRY(WS-K - 1) TO WS-TOP-ENTRY(WS-K)
                     END-PERFORM
                     MOVE WS-US TO WS-TOP-US(WS-SLOT)
                     MOVE WR-CX(WS-R) TO WS-TOP-CX(WS-SLOT)
                     MOVE WR-CZ(WS-R) TO WS-TOP-CZ(WS-SLOT)
                     MOVE WS-S TO WS-TOP-S(WS-SLOT)
                     MOVE WS-VERTS TO WS-TOP-V(WS-SLOT)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE WS-NEAR-N TO WS-D9
     MOVE WS-NEAR-US TO WS-D9B
     MOVE WS-NEAR-V TO WS-D9C
     DISPLAY "VBC mesher near sections " WS-D9 " total-us " WS-D9B " vertices " WS-D9C
     MOVE WS-FAR-N TO WS-D9
     MOVE WS-FAR-US TO WS-D9B
     MOVE WS-FAR-V TO WS-D9C
     DISPLAY "VBC mesher far sections " WS-D9 " total-us " WS-D9B " vertices " WS-D9C
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE WS-TOP-US(WS-K) TO WS-D9
         MOVE WS-TOP-CX(WS-K) TO WS-D9B
         MOVE WS-TOP-CZ(WS-K) TO WS-D9C
         MOVE WS-TOP-S(WS-K) TO WS-D9D
         MOVE WS-TOP-V(WS-K) TO WS-D9E
         DISPLAY "VBC dearest section us " WS-D9 " chunk " WS-D9B " " WS-D9C " section " WS-D9D " vertices " WS-D9E
     END-PERFORM
     MOVE 100 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO WS-SHOWN
*>   The measured frames. CV-STEP is the whole of CL-STEP with the core tick; the phases are then run again on the same state.
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-FRAMES
         CALL STATIC "clock" RETURNING WS-T0
         CALL "CV-STEP" USING CONVH
         CALL STATIC "clock" RETURNING WS-T1
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         COMPUTE WS-US = WS-T1 - WS-T0
         ADD WS-US TO WS-SUM-STEP
         IF WS-US > WS-MAX-STEP
             MOVE WS-US TO WS-MAX-STEP
         END-IF
         ADD MB-MESHED TO WS-SUM-MESHED
         IF MB-MESHED > 0
             ADD 1 TO WS-FRAMES-MESHED
             ADD MB-LAST-US TO WS-SUM-MESH-US
         END-IF
*>       the sections still dirty after the frame (what the idle MESH-DIRTY below will mesh): the first few frames list where they are
         MOVE 0 TO WS-DIRTY-NOW
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
             IF WR-USED(WS-R) = 1
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                     IF WR-DIRTY(WS-R, WS-S) = 1
                         ADD 1 TO WS-DIRTY-NOW
                         IF WS-F <= 12 AND WS-SHOWN < 24
                             ADD 1 TO WS-SHOWN
                             MOVE WS-F TO WS-D9
                             MOVE WR-CX(WS-R) TO WS-D9B
                             MOVE WR-CZ(WS-R) TO WS-D9C
                             MOVE WS-S TO WS-D9D
                             DISPLAY "VBC frame " WS-D9 " dirty section chunk " WS-D9B " " WS-D9C " section " WS-D9D
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
         CALL STATIC "clock" RETURNING WS-T0
         CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US = WS-T1 - WS-T0
         ADD WS-US TO WS-SUM-RLB
         ADD RL-EN-COUNT TO WS-SUM-ENT
         CALL "CAMERA-PLACE" USING CLIENT-STATE WS-VIEW-YAW WS-VIEW-PITCH WS-EYE-TABLE
         CALL STATIC "clock" RETURNING WS-T0
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US = WS-T1 - WS-T0
         ADD WS-US TO WS-SUM-EM
         CALL STATIC "clock" RETURNING WS-T0
         MOVE 64 TO WS-N
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-N
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US = WS-T1 - WS-T0
         ADD WS-US TO WS-SUM-MD
         CALL STATIC "clock" RETURNING WS-T0
         CALL "SCREEN-BUILD" USING CLIENT-STATE
         CALL "UI-RENDER" USING CLIENT-STATE
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US = WS-T1 - WS-T0
         ADD WS-US TO WS-SUM-UI
     END-PERFORM
     COMPUTE WS-MEAN = WS-SUM-STEP / WS-FRAMES
     MOVE WS-MEAN TO WS-D9
     COMPUTE WS-MEAN = WS-SUM-RLB / WS-FRAMES
     MOVE WS-MEAN TO WS-D9B
     COMPUTE WS-MEAN = WS-SUM-EM / WS-FRAMES
     MOVE WS-MEAN TO WS-D9C
     COMPUTE WS-MEAN = WS-SUM-MD / WS-FRAMES
     MOVE WS-MEAN TO WS-D9D
     COMPUTE WS-MEAN = WS-SUM-UI / WS-FRAMES
     MOVE WS-MEAN TO WS-D9E
     MOVE WS-MAX-STEP TO WS-D9F
     DISPLAY "VBC view " WS-VIEW " frames " WS-FRAMES " mean-us: step " WS-D9 " render-list " WS-D9B " entities-mesh " WS-D9C " mesh-dirty-idle " WS-D9D
         " screen+ui " WS-D9E " max-step " WS-D9F
     COMPUTE WS-MEAN = WS-SUM-ENT / WS-FRAMES
     MOVE WS-MEAN TO WS-D9
     MOVE EN-COUNT TO WS-D9B
     DISPLAY "VBC entity vertices a frame " WS-D9 " entity rows " WS-D9B
     MOVE WS-FRAMES-MESHED TO WS-D9
     MOVE WS-SUM-MESHED TO WS-D9B
     MOVE WS-SUM-MESH-US TO WS-D9C
     DISPLAY "VBC frames that meshed " WS-D9 " sections meshed " WS-D9B " mesh us (MB-LAST-US) " WS-D9C
     MOVE "T" TO TL-MODE
     MOVE "bench village client the frames were measured" TO TL-CASE
     MOVE "measured" TO TL-EXPECTED
     MOVE "measured" TO TL-OBSERVED
     IF WS-JOINED NOT = 1
         MOVE "not joined" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM BENCH-VILLAGE-CLIENT.
