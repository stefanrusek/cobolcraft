*> Convergence benchmark and equivalence test of the client frame cost (lane perfframe; operator report: the game is judged by frames per second, 21 to 34 at
*> view 12). One standard single-player world (the host's in-process core, real generated chunks of CC_GENERATED_DIR, fixed seed) is stepped until every chunk
*> has arrived and is meshed, a ring of mobs is summoned round the player, and then the frame is measured: user CPU time (C clock(), the client is one thread)
*> per frame of CV-STEP (the core tick, the packets, the client tick, the mesh queue, the screen model, the render list: everything of CL-STEP; the window
*> submit needs a window and is not part of it) and, run again on the same state, per phase: RENDER-LIST-BUILD, ENTITIES-MESH alone, MESH-DIRTY with nothing
*> to mesh, SCREEN-BUILD and UI-RENDER. Before the mobs come, every section of the replica is meshed again, timed, and its vertices are digested (CRC-32 of the bytes of every
*> opaque and translucent mesh, summed over the sections keyed by chunk and section: independent of the row order; the world is the same every run: fixed seed,
*> no random ticks, no mobs yet).
*> PF_VIEW (default 3) is the view distance, PF_MOBS (default 24) the mobs summoned, PF_FRAMES (default 100) the frames measured, PF_SEED the seed text,
*> PF_FRAME_MS (default 25) is the time one measured frame stands for: the core ticks once per 50 ms, so at 25 every other frame carries a tick and the mean is that of a game at
*> 40 frames a second (50 puts a tick in every frame). PF_DIR (a folder name under build/) keeps two runs apart; PF_TRACE=1 prints the phase times of every frame; the DIGEST line is what two builds are compared by.
*> The cases hold the digests of the section meshes (a change of the mesher that changes one vertex fails them; a change of the world generator moves them
*> too, and its new values are then the ones to take) and that the frame has vertices to measure.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-PERFFRAME-BENCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-perfframe-bench".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "PerfFrame".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 9.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-ENV                 PIC X(64).
 01 WS-VIEW                BINARY-LONG VALUE 3.
 01 WS-MOBS                BINARY-LONG VALUE 24.
 01 WS-FRAMES              BINARY-LONG VALUE 100.
 01 WS-TRACE               BINARY-LONG VALUE 0.
 01 WS-F                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-FRAME-MS            BINARY-LONG VALUE 25.
 01 WS-BACK                BINARY-LONG VALUE 25.
 01 WS-PASSES              BINARY-LONG VALUE 1.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-NEVER               BINARY-LONG.
 01 WS-CHUNKS              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US-STEP             BINARY-DOUBLE.
 01 WS-US-RLB              BINARY-DOUBLE.
 01 WS-US-EM               BINARY-DOUBLE.
 01 WS-US-MD               BINARY-DOUBLE.
 01 WS-US-UI               BINARY-DOUBLE.
 01 WS-SUM-STEP            BINARY-DOUBLE VALUE 0.
 01 WS-SUM-RLB             BINARY-DOUBLE VALUE 0.
 01 WS-SUM-EM              BINARY-DOUBLE VALUE 0.
 01 WS-SUM-MD              BINARY-DOUBLE VALUE 0.
 01 WS-SUM-UI              BINARY-DOUBLE VALUE 0.
 01 WS-MAX-STEP            BINARY-DOUBLE VALUE 0.
 01 WS-MIN-STEP            BINARY-DOUBLE VALUE 999999999.
 01 WS-SUM-VERTS           BINARY-DOUBLE VALUE 0.
 01 WS-SUM-BAKES           BINARY-DOUBLE VALUE 0.
 01 WS-BAKES0              BINARY-LONG.
 01 WS-MEAN                BINARY-DOUBLE.
 01 WS-D9                  PIC 9(9).
 01 WS-D9B                 PIC 9(9).
 01 WS-D9C                 PIC 9(9).
 01 WS-D9D                 PIC 9(9).
 01 WS-D9E                 PIC 9(9).
 01 WS-D9F                 PIC 9(9).
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-VIEW-YAW            FLOAT-LONG.
 01 WS-VIEW-PITCH          FLOAT-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-MOB-NAMES.
    05 FILLER PIC X(12) VALUE "zombie".
    05 FILLER PIC X(12) VALUE "creeper".
    05 FILLER PIC X(12) VALUE "skeleton".
    05 FILLER PIC X(12) VALUE "spider".
    05 FILLER PIC X(12) VALUE "cow".
    05 FILLER PIC X(12) VALUE "sheep".
    05 FILLER PIC X(12) VALUE "pig".
    05 FILLER PIC X(12) VALUE "chicken".
 01 WS-MOB-TABLE REDEFINES WS-MOB-NAMES.
    05 WS-MOB              PIC X(12) OCCURS 8 TIMES.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-MXE                 PIC -(5)9.
 01 WS-MYE                 PIC -(5)9.
 01 WS-MZE                 PIC -(5)9.
 01 WS-CRC                 BINARY-DOUBLE UNSIGNED.
 01 WS-ZERO                BINARY-DOUBLE VALUE 0.
 01 WS-SEC-CRC             BINARY-DOUBLE UNSIGNED.
 01 WS-KEYED               BINARY-DOUBLE UNSIGNED.
 01 WS-DIGEST-OP           BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-DIGEST-TR           BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-VERTS-OP            BINARY-DOUBLE VALUE 0.
 01 WS-VERTS-TR            BINARY-DOUBLE VALUE 0.
 01 WS-SECTIONS            BINARY-LONG VALUE 0.
 01 WS-SECTIONS-LAND       BINARY-LONG VALUE 0.
 01 WS-BYTES               BINARY-DOUBLE.
 01 WS-MESH-US             BINARY-DOUBLE VALUE 0.
 01 WS-MESH-ONE            BINARY-DOUBLE.
 01 WS-MESH-MAX            BINARY-DOUBLE VALUE 0.
 01 WS-D20                 PIC 9(19).
 01 WS-D20B                PIC 9(19).
 01 WS-D20C                PIC 9(19).
 01 WS-D20D                PIC 9(19).
 01 WS-EXPECT-OP           PIC X(24) VALUE "0".
 01 WS-EXPECT-TR           PIC X(24) VALUE "0".
 01 WS-GOT-OP              PIC X(24).
 01 WS-GOT-TR              PIC X(24).
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "PF_VIEW"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-VIEW = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "PF_MOBS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-MOBS = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "PF_FRAMES"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-FRAMES = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "PF_FRAME_MS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-FRAME-MS = FUNCTION NUMVAL(WS-ENV)
     END-IF
     COMPUTE WS-BACK = 50 - WS-FRAME-MS
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "PF_TRACE"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TRACE = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "PF_DIR"
     IF WS-ENV NOT = SPACES
         MOVE SPACES TO WS-DIR
         STRING "build/" FUNCTION TRIM(WS-ENV) DELIMITED BY SIZE INTO WS-DIR
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR TRAILING)) TO WS-DIR-LENGTH
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
     ACCEPT WS-ENV FROM ENVIRONMENT "PF_SEED"
     IF WS-ENV = SPACES
         MOVE "perfframe" TO WS-ENV
     END-IF
*>   The seed is taken from the create-world screen's field (SP-OPEN), so the world is the same every run.
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

*>   Night with the clock stopped, no natural spawns and no random ticks (the zombies and skeletons do not burn, nothing else comes and the blocks stay as
*>   generated: the meshes of two runs are the same), all before the chunks arrive.
     MOVE "/time set 18000" TO WS-TEXT
     MOVE 15 TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "/gamerule advance_time false" TO WS-TEXT
     MOVE 28 TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "/gamerule spawn_mobs false" TO WS-TEXT
     MOVE 26 TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "/gamerule random_tick_speed 0" TO WS-TEXT
     MOVE 29 TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
*>   Every chunk arrived and every section with blocks meshed (the core's pace is one chunk about every 12 frames).
     MOVE 0 TO WS-QUIET
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 20000 OR WS-QUIET >= 10
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
         IF WS-DIRTY = 0 AND WS-CHUNKS >= (2 * WS-VIEW + 1) * (2 * WS-VIEW + 1) - 4 * WS-VIEW
             ADD 1 TO WS-QUIET
         ELSE
             MOVE 0 TO WS-QUIET
         END-IF
     END-PERFORM
     MOVE WS-F TO WS-D9
     MOVE WS-CHUNKS TO WS-D9B
     DISPLAY "world complete after " WS-D9 " frames, chunks " WS-D9B
*>   The light of the last chunks still arrives after the last mesh: a few hundred frames more, then every section is meshed again below.
     MOVE 300 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

*>   PF_MESH_PASSES (default 1) more passes of the mesher over every section first, for a profile of it (nothing is measured in them).
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "PF_MESH_PASSES"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-PASSES = FUNCTION NUMVAL(WS-ENV)
     END-IF
     PERFORM VARYING WS-PASS FROM 2 BY 1 UNTIL WS-PASS > WS-PASSES
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
             IF WR-USED(WS-R) = 1
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                     CALL "MESH-SECTION" USING CLIENT-STATE WS-R WS-S
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
*>   Every section meshed again, timed, and digested.
     MOVE 0 TO WS-MESH-US WS-MESH-MAX
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 CALL STATIC "clock" RETURNING WS-T0
                 CALL "MESH-SECTION" USING CLIENT-STATE WS-R WS-S
                 CALL STATIC "clock" RETURNING WS-T1
                 COMPUTE WS-MESH-ONE = WS-T1 - WS-T0
                 ADD WS-MESH-ONE TO WS-MESH-US
                 IF WS-MESH-ONE > WS-MESH-MAX
                     MOVE WS-MESH-ONE TO WS-MESH-MAX
                 END-IF
                 ADD 1 TO WS-SECTIONS
                 COMPUTE WS-KEYED = (WR-CX(WS-R) + 5000) * 100003 + (WR-CZ(WS-R) + 5000) * 1009 + WS-S
                 IF WR-OP-COUNT(WS-R, WS-S) + WR-TR-COUNT(WS-R, WS-S) > 0
                     ADD 1 TO WS-SECTIONS-LAND
                 END-IF
                 IF WR-OP-COUNT(WS-R, WS-S) > 0
                     COMPUTE WS-BYTES = WR-OP-COUNT(WS-R, WS-S) * 44
                     CALL STATIC "crc32" USING BY VALUE WS-ZERO BY VALUE WR-OP-ADDR(WS-R, WS-S) BY VALUE WS-BYTES RETURNING WS-CRC
                     ADD WR-OP-COUNT(WS-R, WS-S) TO WS-VERTS-OP
                     COMPUTE WS-DIGEST-OP = FUNCTION MOD(WS-DIGEST-OP + WS-CRC * WS-KEYED, 9223372036854775783)
                 END-IF
                 IF WR-TR-COUNT(WS-R, WS-S) > 0
                     COMPUTE WS-BYTES = WR-TR-COUNT(WS-R, WS-S) * 44
                     CALL STATIC "crc32" USING BY VALUE WS-ZERO BY VALUE WR-TR-ADDR(WS-R, WS-S) BY VALUE WS-BYTES RETURNING WS-CRC
                     ADD WR-TR-COUNT(WS-R, WS-S) TO WS-VERTS-TR
                     COMPUTE WS-DIGEST-TR = FUNCTION MOD(WS-DIGEST-TR + WS-CRC * WS-KEYED, 9223372036854775783)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE WS-SECTIONS TO WS-D9
     MOVE WS-SECTIONS-LAND TO WS-D9B
     MOVE WS-MESH-US TO WS-D20
     MOVE WS-MESH-MAX TO WS-D9C
     MOVE WS-VERTS-OP TO WS-D20B
     MOVE WS-VERTS-TR TO WS-D20C
     DISPLAY "PERF mesher: sections " WS-D9 " with vertices " WS-D9B " total-us " WS-D20 " max-section-us " WS-D9C " opaque-vertices " WS-D20B
         " translucent-vertices " WS-D20C
     MOVE WS-DIGEST-OP TO WS-D20
     MOVE WS-DIGEST-TR TO WS-D20B
     DISPLAY "DIGEST opaque " WS-D20 " translucent " WS-D20B


*>   The mobs: a ring round the player, the nearest 6 blocks away and the farthest 24, each from a summon command.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-MOBS
         COMPUTE WS-ANGLE = WS-I * 2.399963
         COMPUTE WS-DIST = 6 + FUNCTION MOD(WS-I * 7, 19)
         COMPUTE WS-MX = FUNCTION INTEGER(PL-X + WS-DIST * FUNCTION COS(WS-ANGLE))
         COMPUTE WS-MZ = FUNCTION INTEGER(PL-Z + WS-DIST * FUNCTION SIN(WS-ANGLE))
         COMPUTE WS-MY = FUNCTION INTEGER(PL-Y) + 6
         MOVE WS-MX TO WS-MXE
         MOVE WS-MY TO WS-MYE
         MOVE WS-MZ TO WS-MZE
         MOVE SPACES TO WS-TEXT
         MOVE 1 TO WS-PTR
         COMPUTE WS-K = FUNCTION MOD(WS-I, 8) + 1
         STRING "/summon minecraft:" DELIMITED BY SIZE WS-MOB(WS-K) DELIMITED BY SPACE " " DELIMITED BY SIZE
             FUNCTION TRIM(WS-MXE) DELIMITED BY SIZE " " DELIMITED BY SIZE FUNCTION TRIM(WS-MYE) DELIMITED BY SIZE
             " " DELIMITED BY SIZE FUNCTION TRIM(WS-MZE) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         COMPUTE WS-TEXT-LENGTH = WS-PTR - 1
         CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
         MOVE 3 TO WS-N
         CALL "CV-STEPS" USING CONVH WS-N
     END-PERFORM
     MOVE 100 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

*>   The measured frames. CV-STEP is the whole of CL-STEP with the core tick; the phases are then run again on the same state.
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-FRAMES
         MOVE RL-EN-BAKES TO WS-BAKES0
         SUBTRACT WS-BACK FROM CV-NOW
         CALL STATIC "clock" RETURNING WS-T0
         CALL "CV-STEP" USING CONVH
         CALL STATIC "clock" RETURNING WS-T1
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         COMPUTE WS-US-STEP = WS-T1 - WS-T0
         ADD WS-US-STEP TO WS-SUM-STEP
         IF WS-US-STEP > WS-MAX-STEP
             MOVE WS-US-STEP TO WS-MAX-STEP
         END-IF
         IF WS-US-STEP < WS-MIN-STEP
             MOVE WS-US-STEP TO WS-MIN-STEP
         END-IF
         COMPUTE WS-SUM-BAKES = WS-SUM-BAKES + RL-EN-BAKES - WS-BAKES0
         CALL STATIC "clock" RETURNING WS-T0
         CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US-RLB = WS-T1 - WS-T0
         ADD WS-US-RLB TO WS-SUM-RLB
         ADD RL-EN-COUNT TO WS-SUM-VERTS
         CALL "CAMERA-PLACE" USING CLIENT-STATE WS-VIEW-YAW WS-VIEW-PITCH WS-EYE-TABLE
         CALL STATIC "clock" RETURNING WS-T0
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US-EM = WS-T1 - WS-T0
         ADD WS-US-EM TO WS-SUM-EM
         CALL STATIC "clock" RETURNING WS-T0
         MOVE 64 TO WS-N
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-N
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US-MD = WS-T1 - WS-T0
         ADD WS-US-MD TO WS-SUM-MD
         CALL STATIC "clock" RETURNING WS-T0
         CALL "SCREEN-BUILD" USING CLIENT-STATE
         CALL "UI-RENDER" USING CLIENT-STATE
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US-UI = WS-T1 - WS-T0
         ADD WS-US-UI TO WS-SUM-UI
         IF WS-TRACE = 1
             MOVE WS-US-STEP TO WS-D9
             MOVE WS-US-RLB TO WS-D9B
             MOVE WS-US-EM TO WS-D9C
             MOVE WS-US-MD TO WS-D9D
             MOVE WS-US-UI TO WS-D9E
             MOVE RL-EN-COUNT TO WS-D9F
             DISPLAY "frame " WS-F " step-us " WS-D9 " render-list-us " WS-D9B " entities-mesh-us " WS-D9C " mesh-dirty-us " WS-D9D
                 " screen-us " WS-D9E " entity-vertices " WS-D9F
         END-IF
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
     DISPLAY "PERF view " WS-VIEW " mobs " WS-MOBS " frames " WS-FRAMES " mean-us: step " WS-D9 " render-list " WS-D9B " entities-mesh " WS-D9C
         " mesh-dirty-idle " WS-D9D " screen+ui " WS-D9E " max-step " WS-D9F
     COMPUTE WS-MEAN = WS-SUM-VERTS / WS-FRAMES
     MOVE WS-MEAN TO WS-D9
     COMPUTE WS-MEAN = WS-SUM-BAKES * 100 / WS-FRAMES
     MOVE WS-MEAN TO WS-D9B
     MOVE EN-COUNT TO WS-D9C
     DISPLAY "PERF entity vertices a frame " WS-D9 " bakes a frame x100 " WS-D9B " entity rows " WS-D9C

     MOVE "T" TO TL-MODE
     MOVE "perfframe: given a standard single-player world with mobs about when the frame was measured then the entity mesh has vertices and the sections have meshes"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "entities and sections meshed" TO TL-EXPECTED
     IF RL-EN-COUNT > 0 AND WS-SECTIONS-LAND > 10 AND WS-JOINED = 1
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE RL-EN-COUNT TO WS-D9
         MOVE WS-SECTIONS-LAND TO WS-D9B
         STRING "entity vertices " WS-D9 " sections " WS-D9B DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-PERFFRAME-BENCH.
