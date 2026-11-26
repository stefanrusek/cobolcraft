*> Measurement program (lane spproc, stage D; docs/design/singleplayer-process.md): the client frame CPU of a single-player world with the core
*> in the client's process against the core in a child process, in a village. One standard world (real generated chunks of CC_GENERATED_DIR, seed
*> VB_SEED, default 12345, view distance VB_VIEW, default 4) is opened, the player is teleported to the village of that seed (VB_X VB_Y VB_Z, default
*> -136 120 -824) and the world is stepped until every chunk has arrived and is meshed. Then VB_FRAMES frames (default 300) are measured: the user CPU
*> time of this process (C clock()) per CV-STEP (the core tick in process mode 0 only, the packets, the client tick, the mesh queue, the screen model, the
*> render list), each followed by a sleep of VB_SLEEP_MS (default 50) so that the child ticks at its own pace; a frame costs the same CPU whether it
*> sleeps or not, and the sleep is the same in both modes. Prints `SPB ...` lines: mean, median, p99 and max in microseconds, the load average
*> (getloadavg) before and after, and in process mode the child's CPU time (ps).
*>   VB_PROCESS 1  the child process mode (needs CC_SERVER_BIN)    VB_FRAMES  VB_VIEW  VB_SEED  VB_X VB_Y VB_Z  VB_SLEEP_MS  VB_DIR (folder under build/)
*> Not an acceptance test: the file is not named acc_ and is built by hand (scratchpad/spproc/mkbench.sh).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BENCH-SPPROC-FRAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-spb".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 14.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "FrameBench".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 10.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-ENV                 PIC X(64).
 01 WS-VIEW                BINARY-LONG VALUE 4.
 01 WS-FRAMES              BINARY-LONG VALUE 300.
 01 WS-SLEEP-MS            BINARY-LONG VALUE 50.
 01 WS-US-SLEEP            BINARY-LONG.
 01 WS-PROCESS             BINARY-LONG VALUE 0.
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
 01 WS-RC                  BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-SUM                 BINARY-DOUBLE VALUE 0.
 01 WS-MEAN                BINARY-DOUBLE.
 01 WS-MEDIAN              BINARY-DOUBLE.
 01 WS-P99                 BINARY-DOUBLE.
 01 WS-MAX                 BINARY-DOUBLE.
 01 WS-SWAP                BINARY-DOUBLE.
 01 WS-TABLE.
    05 WS-FRAME-US         BINARY-DOUBLE OCCURS 3000 TIMES.
 01 WS-LOAD-BEFORE.
    05 WS-LOAD-B           FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LOAD-AFTER.
    05 WS-LOAD-A           FLOAT-LONG OCCURS 3 TIMES.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-PCX                 BINARY-LONG.
 01 WS-PCZ                 BINARY-LONG.
 01 WS-COMMAND             PIC X(256).
 01 WS-PID-EDIT            PIC Z(9)9.
 01 WS-D9                  PIC -(8)9.
 01 WS-D9B                 PIC -(8)9.
 01 WS-D9C                 PIC -(8)9.
 01 WS-D9D                 PIC -(8)9.
 01 WS-XE                  PIC -(8)9.
 01 WS-YE                  PIC -(8)9.
 01 WS-ZE                  PIC -(8)9.
 01 WS-LE1                 PIC -(3)9.99.
 01 WS-LE2                 PIC -(3)9.99.
 01 WS-LE3                 PIC -(3)9.99.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_PROCESS"
     IF WS-ENV = "1"
         MOVE 1 TO WS-PROCESS
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_VIEW"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-VIEW = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_FRAMES"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-FRAMES = FUNCTION MIN(3000, FUNCTION NUMVAL(WS-ENV))
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "VB_SLEEP_MS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-SLEEP-MS = FUNCTION NUMVAL(WS-ENV)
     END-IF
     COMPUTE WS-US-SLEEP = WS-SLEEP-MS * 1000
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
     MOVE WS-PROCESS TO SP-PROCESS-PREF
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     DISPLAY "SPB mode " SP-PROCESS " (1 = the core in a child process)"
     MOVE 0 TO WS-JOINED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 20000 OR WS-JOINED = 1
         CALL "BS-STEP" USING CONVH WS-US-SLEEP
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         IF CN-PHASE(CONN-GAME) = PH-PLAY AND PL-LOADED = 1
             MOVE 1 TO WS-JOINED
         END-IF
     END-PERFORM
     MOVE "/time set 6000" TO WS-TEXT
     MOVE 14 TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     PERFORM WS-N TIMES
         CALL "BS-STEP" USING CONVH WS-US-SLEEP
     END-PERFORM
     MOVE "/gamerule advance_time false" TO WS-TEXT
     MOVE 28 TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     PERFORM WS-N TIMES
         CALL "BS-STEP" USING CONVH WS-US-SLEEP
     END-PERFORM
     MOVE WS-TX TO WS-XE
     MOVE WS-TY TO WS-YE
     MOVE WS-TZ TO WS-ZE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     STRING "/tp @s " DELIMITED BY SIZE FUNCTION TRIM(WS-XE) DELIMITED BY SIZE " " DELIMITED BY SIZE FUNCTION TRIM(WS-YE) DELIMITED BY SIZE
         " " DELIMITED BY SIZE FUNCTION TRIM(WS-ZE) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     COMPUTE WS-TEXT-LENGTH = WS-PTR - 1
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
*>   Every chunk arrived and every section with blocks meshed, and the player landed.
     MOVE 0 TO WS-QUIET
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 60000 OR WS-QUIET >= 200
         CALL "BS-STEP" USING CONVH WS-US-SLEEP
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
         IF WS-DIRTY = 0 AND WS-CHUNKS >= (2 * WS-VIEW + 1) * (2 * WS-VIEW + 1) - 4 * WS-VIEW AND PL-Y < WS-TY - 1
             ADD 1 TO WS-QUIET
         ELSE
             MOVE 0 TO WS-QUIET
         END-IF
     END-PERFORM
     MOVE WS-F TO WS-D9
     MOVE WS-CHUNKS TO WS-D9B
     DISPLAY "SPB world complete after " WS-D9 " frames, chunks " WS-D9B
     MOVE PL-X TO WS-D9
     MOVE PL-Y TO WS-D9B
     MOVE PL-Z TO WS-D9C
     DISPLAY "SPB player at " WS-D9 " " WS-D9B " " WS-D9C
     MOVE 100 TO WS-N
     PERFORM WS-N TIMES
         CALL "BS-STEP" USING CONVH WS-US-SLEEP
     END-PERFORM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     IF SP-PROCESS = 1
         MOVE SP-CHILD-PID TO WS-PID-EDIT
         MOVE LOW-VALUES TO WS-COMMAND
         STRING "echo 'SPB child cpu before:' $(ps -o cputime= -p " FUNCTION TRIM(WS-PID-EDIT) ")" DELIMITED BY SIZE INTO WS-COMMAND
         CALL "SYSTEM" USING WS-COMMAND
     END-IF
     CALL STATIC "getloadavg" USING BY REFERENCE WS-LOAD-BEFORE BY VALUE WS-THREE RETURNING WS-RC
*>   The measured frames.
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-FRAMES
         CALL STATIC "clock" RETURNING WS-T0
         CALL "CV-STEP" USING CONVH
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US = WS-T1 - WS-T0
         MOVE WS-US TO WS-FRAME-US(WS-F)
         ADD WS-US TO WS-SUM
         IF WS-US > WS-MAX
             MOVE WS-US TO WS-MAX
         END-IF
         CALL STATIC "usleep" USING BY VALUE WS-US-SLEEP RETURNING WS-RC
     END-PERFORM
     CALL STATIC "getloadavg" USING BY REFERENCE WS-LOAD-AFTER BY VALUE WS-THREE RETURNING WS-RC
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     IF SP-PROCESS = 1
         MOVE LOW-VALUES TO WS-COMMAND
         STRING "echo 'SPB child cpu after:' $(ps -o cputime= -p " FUNCTION TRIM(WS-PID-EDIT) ")" DELIMITED BY SIZE INTO WS-COMMAND
         CALL "SYSTEM" USING WS-COMMAND
     END-IF
*>   Sorted ascending (insertion sort), then the statistics.
     PERFORM VARYING WS-F FROM 2 BY 1 UNTIL WS-F > WS-FRAMES
         MOVE WS-FRAME-US(WS-F) TO WS-SWAP
         COMPUTE WS-K = WS-F - 1
         PERFORM UNTIL WS-K < 1 OR WS-FRAME-US(WS-K) <= WS-SWAP
             MOVE WS-FRAME-US(WS-K) TO WS-FRAME-US(WS-K + 1)
             SUBTRACT 1 FROM WS-K
         END-PERFORM
         MOVE WS-SWAP TO WS-FRAME-US(WS-K + 1)
     END-PERFORM
     COMPUTE WS-MEAN = WS-SUM / WS-FRAMES
     COMPUTE WS-K = (WS-FRAMES + 1) / 2
     MOVE WS-FRAME-US(WS-K) TO WS-MEDIAN
     COMPUTE WS-K = FUNCTION INTEGER((WS-FRAMES * 99 + 99) / 100)
     MOVE WS-FRAME-US(WS-K) TO WS-P99
     MOVE WS-MEAN TO WS-D9
     MOVE WS-MEDIAN TO WS-D9B
     MOVE WS-P99 TO WS-D9C
     MOVE WS-MAX TO WS-D9D
     DISPLAY "SPB mode " SP-PROCESS " view " WS-VIEW " frames " WS-FRAMES " client-cpu-us mean " WS-D9 " median " WS-D9B " p99 " WS-D9C
         " max " WS-D9D
     COMPUTE WS-LE1 = WS-LOAD-B(1)
     COMPUTE WS-LE2 = WS-LOAD-A(1)
     COMPUTE WS-LE3 = WS-LOAD-A(2)
     DISPLAY "SPB load average 1 min: before " WS-LE1 " after " WS-LE2 " (5 min after " WS-LE3 ")"
     MOVE "T" TO TL-MODE
     MOVE "bench spproc frame the frames were measured" TO TL-CASE
     MOVE "measured" TO TL-EXPECTED
     MOVE "measured" TO TL-OBSERVED
     IF WS-JOINED NOT = 1
         MOVE "not joined" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     STOP RUN.
 END PROGRAM BENCH-SPPROC-FRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BS-STEP.
*> USING CONVH, microseconds: one frame and that much sleep (the child ticks in real time).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-US                   BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-US.
     CALL "CV-STEP" USING CONVH
     CALL STATIC "usleep" USING BY VALUE L-US RETURNING WS-RC
     GOBACK.
 END PROGRAM BS-STEP.
