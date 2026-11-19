*> Frame-stall bench of the world load and the respawn (lane bugstall; operator report: the frame rate is 0 for the first minute or so after loading a world or respawning). One
*> single-player world (the host's in-process core, real generated chunks of CC_GENERATED_DIR, fixed seed) is opened and stepped frame by frame from the first frame, each CV-STEP (the whole of
*> CL-STEP with the core tick: the client is one thread) timed in CPU time (C clock(); the generation workers are forked processes and are not in it) and in wall time, and the frames after
*> a death and the Respawn click are timed the same way. A frame stands for ST_PACE_MS (default 16) of real time: the frame clock advances by that and the loop waits out what a quick frame
*> leaves, since the core's generation workers run in real time. The meshing is paid for from the credit as in the running client (MB-CREDIT-ON). Each phase prints the longest frame, the number of
*> frames over 100 ms of CPU, the CPU of all its frames and the frame at which the replica first held every chunk of the view with nothing to mesh; ST_TRACE=1 prints every frame over 100 ms
*> (CPU or wall), 2 also the progress every 100 frames. ST_TYPE standard (default) or superflat, ST_VIEW (default 4), ST_FRAMES (default 1200: the most frames of a phase; a phase ends 100
*> frames after the world is complete), ST_LIMIT_MS (default 150: the cases' budget of the longest frame), ST_DIR (folder under build/, default conv-stall-bench).
*> Not an acceptance test: the file is not named acc_ and is built by hand (the release libraries, scratchpad lane scripts); it prints `STALL ...` lines.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BENCH-STALL-CLIENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-stall-bench".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 22.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "StallBench".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 10.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-ENV                 PIC X(64).
 01 WS-VIEW                BINARY-LONG VALUE 4.
 01 WS-FRAMES              BINARY-LONG VALUE 1200.
 01 WS-TRACE               BINARY-LONG VALUE 0.
 01 WS-LIMIT-US            BINARY-DOUBLE VALUE 150000.
 01 WS-LIMIT-MS            BINARY-DOUBLE.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-OPEN-US             BINARY-DOUBLE.
 01 WS-D9                  PIC 9(9).
 01 WS-D9B                 PIC 9(9).
 01 WS-D9C                 PIC 9(9).
 01 WS-D9D                 PIC 9(9).
 01 WS-D9E                 PIC 9(9).
 01 WS-LABEL               PIC X(8).
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-STATS.
    05 ST-MAX              BINARY-DOUBLE.
    05 ST-MAX-AT           BINARY-LONG.
    05 ST-OVER             BINARY-LONG.
    05 ST-SUM              BINARY-DOUBLE.
    05 ST-FULL-AT          BINARY-LONG.
    05 ST-FULL-US          BINARY-DOUBLE.
    05 ST-QUIET-AT         BINARY-LONG.
    05 ST-QUIET-US         BINARY-DOUBLE.
 01 WS-LOAD-MAX            BINARY-DOUBLE.
 01 WS-LOAD-OVER           BINARY-LONG.
 01 WS-LOAD-FULL-AT        BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "ST_VIEW"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-VIEW = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "ST_FRAMES"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-FRAMES = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "ST_TRACE"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TRACE = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "ST_LIMIT_MS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-LIMIT-US = FUNCTION NUMVAL(WS-ENV) * 1000
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "ST_DIR"
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
*>   The meshing is paid for from a credit that each frame refills, as the running client does (CL-RUN).
     MOVE 1 TO MB-CREDIT-ON
     MOVE CL-MESH-CREDIT-US TO MB-CREDIT
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE SCR-CREATE-WORLD TO SM-SCREEN
     MOVE "stallbench" TO SM-EDIT-SEED
     MOVE 10 TO SM-EDIT-SEED-LENGTH
     MOVE WS-VIEW TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE CORE-SETTINGS TO SP-SETTINGS
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "ST_TYPE"
     IF WS-ENV = "superflat"
         MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     END-IF
     CALL STATIC "clock" RETURNING WS-T0
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL STATIC "clock" RETURNING WS-T1
     COMPUTE WS-OPEN-US = WS-T1 - WS-T0
     MOVE WS-OPEN-US TO WS-D9
     DISPLAY "STALL open-us " WS-D9

*>   The world load: every frame from the first, the screen and the core as the game runs them.
     MOVE "load" TO WS-LABEL
     CALL "STALL-FRAMES" USING CONVH WS-ALICE WS-VIEW WS-FRAMES WS-TRACE WS-LIMIT-US WS-LABEL WS-STATS
     MOVE ST-MAX TO WS-LOAD-MAX
     MOVE ST-OVER TO WS-LOAD-OVER
     MOVE ST-FULL-AT TO WS-LOAD-FULL-AT

*>   Death, then the Respawn button: the frames after the click.
     MOVE "/damage Alice 1000" TO WS-TEXT
     MOVE 18 TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE SCR-DEATH TO WS-SCREEN
     CALL "CV-UNTIL-SCREEN" USING CONVH WS-ALICE WS-SCREEN WS-REACHED
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE ACT-RESPAWN TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE "respawn" TO WS-LABEL
     CALL "STALL-FRAMES" USING CONVH WS-ALICE WS-VIEW WS-FRAMES WS-TRACE WS-LIMIT-US WS-LABEL WS-STATS

     COMPUTE WS-LIMIT-MS = WS-LIMIT-US / 1000
     MOVE "N" TO TL-MODE
     MOVE "acceptance stall given a world loading then no frame of the load exceeds the CPU budget" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LOAD-MAX <= WS-LIMIT-US
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance stall given a Respawn then no frame after it exceeds the CPU budget" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF ST-MAX <= WS-LIMIT-US
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance stall given a world loading then it is complete within the frames measured" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LOAD-FULL-AT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM BENCH-STALL-CLIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STALL-FRAMES.
*> USING CONVH client view frames trace limit label stats: steps `frames` frames from now, timing each in CPU microseconds, and fills the stats
*> (longest frame and its number, frames over 100 ms, CPU sum, the frame and CPU sum at which the replica first held every chunk of the view with no
*> dirty section) and prints the summary line.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CELLS.
 01 WS-F                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-W0                  BINARY-DOUBLE.
 01 WS-W1                  BINARY-DOUBLE.
 01 WS-WALL                BINARY-DOUBLE.
 01 WS-WALL-MAX            BINARY-DOUBLE.
 01 WS-WALL-OVER           BINARY-LONG.
 01 WS-CHUNKS              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-D9                  PIC 9(9).
 01 WS-D9B                 PIC 9(9).
 01 WS-D9C                 PIC 9(9).
 01 WS-D9D                 PIC 9(9).
 01 WS-D9E                 PIC 9(9).
 01 WS-NAP                 BINARY-DOUBLE.
 01 WS-PACE-MS             BINARY-LONG VALUE 16.
 01 WS-PACE-ENV            PIC X(16).
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-VIEW                 BINARY-LONG.
 01 L-FRAMES               BINARY-LONG.
 01 L-TRACE                BINARY-LONG.
 01 L-LIMIT                BINARY-DOUBLE.
 01 L-LABEL                PIC X(8).
 01 L-STATS.
    05 L-MAX               BINARY-DOUBLE.
    05 L-MAX-AT            BINARY-LONG.
    05 L-OVER              BINARY-LONG.
    05 L-SUM               BINARY-DOUBLE.
    05 L-FULL-AT           BINARY-LONG.
    05 L-FULL-US           BINARY-DOUBLE.
    05 L-QUIET-AT          BINARY-LONG.
    05 L-QUIET-US          BINARY-DOUBLE.
 PROCEDURE DIVISION USING CONVH L-INDEX L-VIEW L-FRAMES L-TRACE L-LIMIT L-LABEL L-STATS.
     MOVE 0 TO L-MAX L-MAX-AT L-OVER L-SUM L-FULL-AT L-FULL-US L-QUIET-AT L-QUIET-US WS-WALL-MAX WS-WALL-OVER
     COMPUTE WS-WANT = (2 * L-VIEW + 1) * (2 * L-VIEW + 1)
     MOVE SPACES TO WS-PACE-ENV
     ACCEPT WS-PACE-ENV FROM ENVIRONMENT "ST_PACE_MS"
     IF WS-PACE-ENV NOT = SPACES
         COMPUTE WS-PACE-MS = FUNCTION NUMVAL(WS-PACE-ENV)
     END-IF
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > L-FRAMES OR (L-QUIET-AT > 0 AND WS-F > L-QUIET-AT + 50)
*>       A frame stands for WS-PACE-MS of real time (a window at about 60 frames a second): the frame clock advances by that, the core
*>       ticks once per 50 ms of it, and the loop waits out what a quick frame leaves (the core's generation workers run in real time).
         CALL "SV-NOW-MS" USING WS-W0
         SUBTRACT 50 FROM CV-NOW
         ADD WS-PACE-MS TO CV-NOW
         CALL STATIC "clock" RETURNING WS-T0
         CALL "CV-STEP" USING CONVH
         CALL STATIC "clock" RETURNING WS-T1
         CALL "SV-NOW-MS" USING WS-W1
         COMPUTE WS-US = WS-T1 - WS-T0
         COMPUTE WS-WALL = WS-W1 - WS-W0
         IF WS-WALL > WS-WALL-MAX
             MOVE WS-WALL TO WS-WALL-MAX
         END-IF
         IF WS-WALL < WS-PACE-MS
             COMPUTE WS-NAP = (WS-PACE-MS - WS-WALL) * 1000000
             CALL "CBL_GC_NANOSLEEP" USING WS-NAP
         END-IF
         IF WS-WALL > 100
             ADD 1 TO WS-WALL-OVER
         END-IF
         ADD WS-US TO L-SUM
         IF WS-US > L-MAX
             MOVE WS-US TO L-MAX
             MOVE WS-F TO L-MAX-AT
         END-IF
         IF WS-US > 100000
             ADD 1 TO L-OVER
         END-IF
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
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
         IF L-FULL-AT = 0 AND WS-CHUNKS >= WS-WANT AND PL-LOADED = 1
             MOVE WS-F TO L-FULL-AT
             MOVE L-SUM TO L-FULL-US
         END-IF
         IF L-FULL-AT > 0 AND L-QUIET-AT = 0 AND WS-DIRTY = 0
             MOVE WS-F TO L-QUIET-AT
             MOVE L-SUM TO L-QUIET-US
         END-IF
         IF L-TRACE = 2 AND FUNCTION MOD(WS-F, 100) = 0
             MOVE WS-F TO WS-D9
             MOVE WS-CHUNKS TO WS-D9C
             MOVE WS-DIRTY TO WS-D9D
             MOVE PL-LOADED TO WS-D9E
             DISPLAY "STALL " FUNCTION TRIM(L-LABEL) " progress frame " WS-D9 " chunks " WS-D9C " dirty " WS-D9D " loaded " WS-D9E
         END-IF
         IF L-TRACE >= 1 AND (WS-US > 100000 OR WS-WALL > 100)
             MOVE WS-F TO WS-D9
             MOVE WS-US TO WS-D9B
             MOVE WS-CHUNKS TO WS-D9C
             MOVE WS-DIRTY TO WS-D9D
             DISPLAY "STALL " FUNCTION TRIM(L-LABEL) " frame " WS-D9 " cpu-us " WS-D9B " wall-ms " WS-WALL " chunks " WS-D9C " dirty " WS-D9D
         END-IF
     END-PERFORM
     MOVE L-MAX TO WS-D9
     MOVE L-MAX-AT TO WS-D9B
     MOVE L-OVER TO WS-D9C
     MOVE L-FULL-AT TO WS-D9D
     MOVE L-FULL-US TO WS-D9E
     DISPLAY "STALL " FUNCTION TRIM(L-LABEL) " frames " L-FRAMES " max-us " WS-D9 " at " WS-D9B " over-100ms " WS-D9C
         " chunks-complete-at-frame " WS-D9D " cpu-us-to-there " WS-D9E
     MOVE L-QUIET-AT TO WS-D9
     MOVE L-QUIET-US TO WS-D9B
     DISPLAY "STALL " FUNCTION TRIM(L-LABEL) " nothing-left-to-mesh-at-frame " WS-D9 " cpu-us-to-there " WS-D9B
     MOVE L-SUM TO WS-D9
     DISPLAY "STALL " FUNCTION TRIM(L-LABEL) " cpu-us-total " WS-D9 " wall-ms-max " WS-WALL-MAX " wall-frames-over-100ms " WS-WALL-OVER
     MOVE WS-CHUNKS TO WS-D9
     DISPLAY "STALL " FUNCTION TRIM(L-LABEL) " chunks-at-end " WS-D9
     GOBACK.
 END PROGRAM STALL-FRAMES.
