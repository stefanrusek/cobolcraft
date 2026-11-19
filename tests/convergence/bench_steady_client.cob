*> Measurement program (002-lane-perfsteady; operator report on try16: "really bad" performance in a village, a stronghold, and over height changes). What the operator does, headless:
*> a single-player world (standard or superflat, the host's in-process core, real generated chunks of CC_GENERATED_DIR) at the default render distance of 12 (the simulation distance is the
*> view distance: play.cob), a SURVIVAL player at night with the clock stopped (natural spawning on), teleported to a place (a village, a stronghold), mobs of every kind round the
*> player, then BS_FRAMES frames standing and BS_WALK_FRAMES frames walking (W held), each frame the whole of CL-STEP with the core tick (CV-STEP at BS_FRAME_MS, default 25: a tick every
*> other frame, a game at 40 frames a second; CL-MAX-PUMP-TICKS ticks at most a frame). Reported in user CPU time (C clock(), so the machine load moves it little; the load average is printed):
*>   mean, p50, p99 and max frame, the mean of the frames that carried a tick and of those that did not, the 10 longest frames (with the ticks and sections meshed in them),
*>   the core tick alone (CORE-TICK called by the program BS_CORE_TICKS times, timed one by one: mean, p99, max, the ten longest),
*>   and the client phases run again on the same state (RENDER-LIST-BUILD, ENTITIES-MESH, MESH-DIRTY idle, SCREEN-BUILD with UI-RENDER).
*>   BS_TYPE std (default) or flat   BS_SEED (12345)   BS_X BS_Y BS_Z the block to teleport to   BS_VIEW (12)   BS_MOBS (14)   BS_FRAMES (600)   BS_WALK_FRAMES (600)
*>   BS_CORE_TICKS (200)   BS_NIGHT (1)   BS_LABEL   BS_DIR (folder under build/)   BS_LOCATE (a structure id or tag: prints the /locate reply and the position, then ends)
*>   BS_SETTLE (frames after the summons, default 200)   BS_MAXWAIT (frames to wait for the chunks, default 30000)
*> Not an acceptance test: the file is not named acc_ and is built by hand (scratchpad/perfsteady/mkbench.sh); it prints `BS ...` lines.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BENCH-STEADY-CLIENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY CELLS.
 COPY TESTLIB.
 COPY CCSHIM.
 COPY BLOCKTICK.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bs".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 13.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "SteadyBench".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 11.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-ENV                 PIC X(64).
 01 WS-LABEL               PIC X(40) VALUE "scenario".
 01 WS-TYPE                PIC X(8) VALUE "std".
 01 WS-VIEW                BINARY-LONG VALUE 12.
 01 WS-MOBS                BINARY-LONG VALUE 14.
 01 WS-FRAMES              BINARY-LONG VALUE 600.
 01 WS-WALK-FRAMES         BINARY-LONG VALUE 600.
 01 WS-CORE-TICKS          BINARY-LONG VALUE 200.
 01 WS-NIGHT               BINARY-LONG VALUE 1.
 01 WS-SETTLE              BINARY-LONG VALUE 200.
 01 WS-MAXWAIT             BINARY-LONG VALUE 30000.
 01 WS-FRAME-MS            BINARY-LONG VALUE 25.
 01 WS-BACK                BINARY-LONG VALUE 25.
 01 WS-TX                  BINARY-LONG VALUE -136.
 01 WS-TY                  BINARY-LONG VALUE 120.
 01 WS-TZ                  BINARY-LONG VALUE -824.
 01 WS-LOCATE              PIC X(60).
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-CHUNKS              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-TK0                 BINARY-DOUBLE.
 01 WS-SUM-RLB             BINARY-DOUBLE VALUE 0.
 01 WS-SUM-EM              BINARY-DOUBLE VALUE 0.
 01 WS-SUM-MD              BINARY-DOUBLE VALUE 0.
 01 WS-SUM-UI              BINARY-DOUBLE VALUE 0.
 01 WS-SUM-ENT             BINARY-DOUBLE VALUE 0.
 01 WS-MEAN                BINARY-DOUBLE.
 01 WS-D9                  PIC -(8)9.
 01 WS-D9B                 PIC -(8)9.
 01 WS-D9C                 PIC -(8)9.
 01 WS-D9D                 PIC -(8)9.
 01 WS-D9E                 PIC -(8)9.
 01 WS-D9F                 PIC -(8)9.
 01 WS-D9G                 PIC -(8)9.
 01 WS-LOAD.
    05 WS-LOAD-AVG         FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LOAD-1              PIC -(3)9.99.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-VIEW-YAW            FLOAT-LONG.
 01 WS-VIEW-PITCH          FLOAT-LONG.
 01 WS-TEXT                PIC X(96).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-CHAT                PIC X(4096).
 01 WS-PTR                 BINARY-LONG.
 01 WS-XE                  PIC -(8)9.
 01 WS-YE                  PIC -(8)9.
 01 WS-ZE                  PIC -(8)9.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-MOB-NAMES.
    05 FILLER PIC X(12) VALUE "iron_golem".
    05 FILLER PIC X(12) VALUE "cat".
    05 FILLER PIC X(12) VALUE "cow".
    05 FILLER PIC X(12) VALUE "zombie".
    05 FILLER PIC X(12) VALUE "pig".
    05 FILLER PIC X(12) VALUE "skeleton".
    05 FILLER PIC X(12) VALUE "sheep".
    05 FILLER PIC X(12) VALUE "creeper".
    05 FILLER PIC X(12) VALUE "chicken".
    05 FILLER PIC X(12) VALUE "spider".
    05 FILLER PIC X(12) VALUE "villager".
    05 FILLER PIC X(12) VALUE "zombie".
    05 FILLER PIC X(12) VALUE "cow".
    05 FILLER PIC X(12) VALUE "wolf".
 01 WS-MOB-TABLE REDEFINES WS-MOB-NAMES.
    05 WS-MOB              PIC X(12) OCCURS 14 TIMES.
*> the frames of the phase being measured
 01 WS-FRAME-TABLE.
    05 WS-FR OCCURS 4000 TIMES.
       10 WS-FR-US         BINARY-LONG.
       10 WS-FR-TK         BINARY-LONG.
       10 WS-FR-MS         BINARY-LONG.
       10 WS-FR-ENT        BINARY-LONG.
       10 WS-FR-USED       BINARY-LONG.
 01 WS-PHASE               PIC X(24).
 01 WS-COUNT               BINARY-LONG.
 01 WS-SUM-ALL             BINARY-DOUBLE.
 01 WS-SUM-TK              BINARY-DOUBLE.
 01 WS-SUM-NT              BINARY-DOUBLE.
 01 WS-N-TK                BINARY-LONG.
 01 WS-N-NT                BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-US             BINARY-LONG.
 01 WS-RANK-99             BINARY-LONG.
 01 WS-RANK-50             BINARY-LONG.
 01 WS-P99                 BINARY-LONG.
 01 WS-P50                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TOP-N               BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-KEY                 BINARY-LONG.
 01 WS-AUTOY               BINARY-LONG VALUE 0.
 01 WS-CLOCK               BINARY-LONG VALUE 0.
 01 WS-DEBUG               BINARY-LONG VALUE 0.
 01 WS-KIND                PIC X(12) VALUE "structure".
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-B0                  BINARY-LONG.
 01 WS-B1                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-AIRN                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_VIEW"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-VIEW = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_MOBS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-MOBS = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_FRAMES"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-FRAMES = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_WALK_FRAMES"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-WALK-FRAMES = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_CORE_TICKS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-CORE-TICKS = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_NIGHT"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-NIGHT = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_SETTLE"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-SETTLE = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_MAXWAIT"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-MAXWAIT = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_FRAME_MS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-FRAME-MS = FUNCTION NUMVAL(WS-ENV)
     END-IF
     COMPUTE WS-BACK = 50 - WS-FRAME-MS
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_X"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TX = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_Y"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TY = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_Z"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TZ = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_TYPE"
     IF WS-ENV NOT = SPACES
         MOVE WS-ENV TO WS-TYPE
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_LABEL"
     IF WS-ENV NOT = SPACES
         MOVE WS-ENV TO WS-LABEL
     END-IF
     MOVE SPACES TO WS-LOCATE
     ACCEPT WS-LOCATE FROM ENVIRONMENT "BS_LOCATE"
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_AUTOY"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-AUTOY = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_CLOCK"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-CLOCK = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_DEBUG"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-DEBUG = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_LOCATE_KIND"
     IF WS-ENV NOT = SPACES
         MOVE WS-ENV TO WS-KIND
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_DIM"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-DIM = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_DIR"
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
     ACCEPT WS-ENV FROM ENVIRONMENT "BS_SEED"
     IF WS-ENV = SPACES
         MOVE "12345" TO WS-ENV
     END-IF
     MOVE SCR-CREATE-WORLD TO SM-SCREEN
     MOVE WS-ENV TO SM-EDIT-SEED
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ENV TRAILING)) TO SM-EDIT-SEED-LENGTH
     MOVE WS-VIEW TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
     MOVE CORE-SETTINGS TO SP-SETTINGS
     IF WS-TYPE = "flat"
         MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     ELSE
         MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     END-IF
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     MOVE 0 TO WS-JOINED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 20 OR WS-JOINED = 1
         CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
         IF WS-JOINED = 0
             CALL "C$SLEEP" USING 1
         END-IF
     END-PERFORM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

     IF WS-LOCATE NOT = SPACES
         MOVE SPACES TO WS-TEXT
         MOVE 1 TO WS-PTR
         STRING "/locate " DELIMITED BY SIZE FUNCTION TRIM(WS-KIND) DELIMITED BY SIZE " " DELIMITED BY SIZE
             FUNCTION TRIM(WS-LOCATE) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         COMPUTE WS-TEXT-LENGTH = WS-PTR - 1
         CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
         MOVE 10 TO WS-N
         CALL "CV-STEPS" USING CONVH WS-N
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6000 OR CH-COUNT > 0
             CALL "CV-STEP" USING CONVH
             SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         END-PERFORM
         CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-CHAT
         DISPLAY "BS locate chat: " FUNCTION TRIM(WS-CHAT TRAILING)
         STOP RUN
     END-IF

*>   Night with the clock stopped (natural spawning stays on: the spawner is part of the cost), a survival player who cannot be hurt, then the teleport.
     IF WS-NIGHT = 1
         MOVE "/time set 18000" TO WS-TEXT
         MOVE 15 TO WS-TEXT-LENGTH
     ELSE
         MOVE "/time set 6000" TO WS-TEXT
         MOVE 14 TO WS-TEXT-LENGTH
     END-IF
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     IF WS-CLOCK = 0
         MOVE "/gamerule advance_time false" TO WS-TEXT
         MOVE 28 TO WS-TEXT-LENGTH
         CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
         MOVE 3 TO WS-N
         CALL "CV-STEPS" USING CONVH WS-N
     END-IF
     MOVE "/effect give @s minecraft:resistance infinite 4 true" TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-TEXT-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-CHAT
     DISPLAY "BS chat: " FUNCTION TRIM(WS-CHAT TRAILING)
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
*>   Every chunk arrived and every section with blocks meshed (in the order the game would: the frames run as they come).
     MOVE 0 TO WS-QUIET
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-MAXWAIT OR WS-QUIET >= 100
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         MOVE 0 TO WS-DIRTY WS-CHUNKS
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
             IF WR-USED(WS-R) = 1
                 ADD 1 TO WS-CHUNKS
                 IF WS-QUIET < 100
                     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                         IF WR-DIRTY(WS-R, WS-S) = 1
                             ADD 1 TO WS-DIRTY
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
         END-PERFORM
         IF FUNCTION MOD(WS-F, 200) = 0
             MOVE WS-F TO WS-D9
             MOVE WS-CHUNKS TO WS-D9B
             MOVE BT-COUNT TO WS-D9C
             CALL STATIC "clock" RETURNING WS-T0
             MOVE WS-T0 TO WS-D9D
             DISPLAY "BS loading frame " WS-D9 " chunks " WS-D9B " scheduled ticks " WS-D9C " cpu-us " WS-D9D
         END-IF
         IF WS-DIRTY = 0 AND WS-CHUNKS >= (2 * WS-VIEW + 1) * (2 * WS-VIEW + 1) - 4 * WS-VIEW AND PL-Y < WS-TY - 1
             ADD 1 TO WS-QUIET
         ELSE
             MOVE 0 TO WS-QUIET
         END-IF
     END-PERFORM
     MOVE WS-F TO WS-D9
     MOVE WS-CHUNKS TO WS-D9B
     DISPLAY "BS world complete after " WS-D9 " frames, chunks " WS-D9B
     MOVE PL-X TO WS-D9
     MOVE PL-Y TO WS-D9B
     MOVE PL-Z TO WS-D9C
     DISPLAY "BS player at " WS-D9 " " WS-D9B " " WS-D9C
*>   BS_AUTOY 1: the nearest cavity (2 air cells over a floor, 30 or more air cells in the 5 x 5 x 3 box about it) below y 50 to the block (BS_X, BS_Z) - a stronghold corridor or a cave -,
*>   the player is teleported into it and the world is waited for again.
     IF WS-AUTOY = 1
         PERFORM FIND-POCKET
         IF WS-FOUND = 1
             MOVE WS-QX TO WS-XE
             MOVE WS-QY TO WS-YE
             MOVE WS-QZ TO WS-ZE
             MOVE SPACES TO WS-TEXT
             MOVE 1 TO WS-PTR
             STRING "/tp @s " DELIMITED BY SIZE FUNCTION TRIM(WS-XE) DELIMITED BY SIZE " " DELIMITED BY SIZE FUNCTION TRIM(WS-YE) DELIMITED BY SIZE
                 " " DELIMITED BY SIZE FUNCTION TRIM(WS-ZE) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             COMPUTE WS-TEXT-LENGTH = WS-PTR - 1
             DISPLAY "BS cavity at " FUNCTION TRIM(WS-XE) " " FUNCTION TRIM(WS-YE) " " FUNCTION TRIM(WS-ZE) " air " WS-AIRN
             CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
             MOVE 600 TO WS-N
             CALL "CV-STEPS" USING CONVH WS-N
             SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
             MOVE PL-X TO WS-D9
             MOVE PL-Y TO WS-D9B
             MOVE PL-Z TO WS-D9C
             DISPLAY "BS player now at " WS-D9 " " WS-D9B " " WS-D9C
         ELSE
             DISPLAY "BS no cavity found"
         END-IF
     END-IF

*>   The mobs: a ring round the player (4 to 16 blocks), from summon commands, above the ground.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-MOBS
         COMPUTE WS-ANGLE = WS-I * 2.399963
         COMPUTE WS-DIST = 4 + FUNCTION MOD(WS-I * 5, 13)
         COMPUTE WS-MX = FUNCTION INTEGER(PL-X + WS-DIST * FUNCTION COS(WS-ANGLE))
         COMPUTE WS-MZ = FUNCTION INTEGER(PL-Z + WS-DIST * FUNCTION SIN(WS-ANGLE))
         COMPUTE WS-MY = FUNCTION INTEGER(PL-Y) + 2
         MOVE WS-MX TO WS-XE
         MOVE WS-MY TO WS-YE
         MOVE WS-MZ TO WS-ZE
         MOVE SPACES TO WS-TEXT
         MOVE 1 TO WS-PTR
         COMPUTE WS-K = FUNCTION MOD(WS-I, 14) + 1
         STRING "/summon minecraft:" DELIMITED BY SIZE WS-MOB(WS-K) DELIMITED BY SPACE " " DELIMITED BY SIZE
             FUNCTION TRIM(WS-XE) DELIMITED BY SIZE " " DELIMITED BY SIZE FUNCTION TRIM(WS-YE) DELIMITED BY SIZE
             " " DELIMITED BY SIZE FUNCTION TRIM(WS-ZE) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         COMPUTE WS-TEXT-LENGTH = WS-PTR - 1
         CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-TEXT-LENGTH
         MOVE 3 TO WS-N
         CALL "CV-STEPS" USING CONVH WS-N
     END-PERFORM
     MOVE WS-SETTLE TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE EN-COUNT TO WS-D9
     DISPLAY "BS entity rows after the summons " WS-D9

*>   BS_DEBUG 1: the F3 overlay on while the frames are measured (HUD-BUILD with DEBUG-OVERLAY-ADD).
     IF WS-DEBUG = 1
         MOVE CC-KEY-F3 TO WS-KEY
         CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     END-IF
     MOVE "stand" TO WS-PHASE
     MOVE WS-FRAMES TO WS-COUNT
     PERFORM MEASURE-FRAMES
     PERFORM REPORT-FRAMES

*>   The client phases run again on the same state.
     MOVE 0 TO WS-SUM-RLB WS-SUM-EM WS-SUM-MD WS-SUM-UI WS-SUM-ENT
     MOVE 100 TO WS-N
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-N
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
         MOVE 64 TO WS-K
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-K
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
     COMPUTE WS-MEAN = WS-SUM-RLB / WS-N
     MOVE WS-MEAN TO WS-D9
     COMPUTE WS-MEAN = WS-SUM-EM / WS-N
     MOVE WS-MEAN TO WS-D9B
     COMPUTE WS-MEAN = WS-SUM-MD / WS-N
     MOVE WS-MEAN TO WS-D9C
     COMPUTE WS-MEAN = WS-SUM-UI / WS-N
     MOVE WS-MEAN TO WS-D9D
     COMPUTE WS-MEAN = WS-SUM-ENT / WS-N
     MOVE WS-MEAN TO WS-D9E
     MOVE EN-COUNT TO WS-D9F
     DISPLAY "BS " FUNCTION TRIM(WS-LABEL) " client phases mean-us: render-list " WS-D9 " entities-mesh " WS-D9B " mesh-dirty-idle " WS-D9C
         " screen+ui " WS-D9D " entity-vertices " WS-D9E " entity-rows " WS-D9F

*>   The core tick alone: CORE-TICK called here and timed (the clock of the client held, so no tick runs in its steps), one client step after each to take the packets.
     MOVE "core-tick" TO WS-PHASE
     MOVE WS-CORE-TICKS TO WS-COUNT
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-COUNT
         CALL STATIC "clock" RETURNING WS-T0
         CALL "CORE-TICK"
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US = WS-T1 - WS-T0
         MOVE WS-US TO WS-FR-US(WS-F)
         MOVE 1 TO WS-FR-TK(WS-F)
         MOVE 0 TO WS-FR-MS(WS-F)
         MOVE 0 TO WS-FR-ENT(WS-F)
         MOVE 0 TO WS-FR-USED(WS-F)
         SUBTRACT 50 FROM CV-NOW
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     END-PERFORM
     PERFORM REPORT-FRAMES

*>   Walking: W held, the world streaming in front of the player.
     IF WS-WALK-FRAMES > 0
         MOVE PL-X TO WS-X0
         MOVE PL-Z TO WS-Z0
         MOVE CC-KEY-W TO WS-KEY
         CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-DOWN
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         MOVE "walk" TO WS-PHASE
         MOVE WS-WALK-FRAMES TO WS-COUNT
         PERFORM MEASURE-FRAMES
         CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-UP
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         COMPUTE WS-MOVED = FUNCTION SQRT((PL-X - WS-X0) ** 2 + (PL-Z - WS-Z0) ** 2)
         MOVE WS-MOVED TO WS-D9
         DISPLAY "BS " FUNCTION TRIM(WS-LABEL) " walked " WS-D9 " blocks"
         PERFORM REPORT-FRAMES
     END-IF

     MOVE "T" TO TL-MODE
     MOVE "bench steady client the frames were measured" TO TL-CASE
     MOVE "measured" TO TL-EXPECTED
     MOVE "measured" TO TL-OBSERVED
     IF WS-JOINED NOT = 1
         MOVE "not joined" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIND-POCKET.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 24 OR WS-FOUND = 1
         PERFORM VARYING WS-DX FROM -24 BY 1 UNTIL WS-DX > 24 OR WS-FOUND = 1
             PERFORM VARYING WS-DZ FROM -24 BY 1 UNTIL WS-DZ > 24 OR WS-FOUND = 1
                 IF (WS-DX = WS-D OR WS-DX = 0 - WS-D OR WS-DZ = WS-D OR WS-DZ = 0 - WS-D)
                     AND WS-DX <= WS-D AND WS-DX >= 0 - WS-D AND WS-DZ <= WS-D AND WS-DZ >= 0 - WS-D
                     COMPUTE WS-PX = WS-TX + WS-DX
                     COMPUTE WS-PZ = WS-TZ + WS-DZ
                     PERFORM VARYING WS-Y FROM 48 BY -1 UNTIL WS-Y < -40 OR WS-FOUND = 1
                         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-B0
                         COMPUTE WS-QY = WS-Y + 1
                         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-QY WS-PZ WS-B1
                         COMPUTE WS-QY = WS-Y - 1
                         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-QY WS-PZ WS-B2
                         IF WS-B0 = 0 AND WS-B1 = 0 AND WS-B2 NOT = 0
                             MOVE 0 TO WS-AIRN
                             PERFORM VARYING WS-AX FROM -2 BY 1 UNTIL WS-AX > 2
                                 PERFORM VARYING WS-AZ FROM -2 BY 1 UNTIL WS-AZ > 2
                                     COMPUTE WS-QX = WS-PX + WS-AX
                                     COMPUTE WS-QZ = WS-PZ + WS-AZ
                                     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-QX WS-Y WS-QZ WS-B0
                                     IF WS-B0 = 0
                                         ADD 1 TO WS-AIRN
                                     END-IF
                                     COMPUTE WS-QY = WS-Y + 1
                                     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-QX WS-QY WS-QZ WS-B0
                                     IF WS-B0 = 0
                                         ADD 1 TO WS-AIRN
                                     END-IF
                                     COMPUTE WS-QY = WS-Y + 2
                                     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-QX WS-QY WS-QZ WS-B0
                                     IF WS-B0 = 0
                                         ADD 1 TO WS-AIRN
                                     END-IF
                                 END-PERFORM
                             END-PERFORM
                             IF WS-AIRN >= 30
                                 MOVE 1 TO WS-FOUND
                                 MOVE WS-PX TO WS-QX
                                 MOVE WS-Y TO WS-QY
                                 MOVE WS-PZ TO WS-QZ
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 MEASURE-FRAMES.
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-COUNT
         MOVE SP-TICKS TO WS-TK0
         SUBTRACT WS-BACK FROM CV-NOW
         CALL STATIC "clock" RETURNING WS-T0
         CALL "CV-STEP" USING CONVH
         CALL STATIC "clock" RETURNING WS-T1
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         COMPUTE WS-US = WS-T1 - WS-T0
         MOVE WS-US TO WS-FR-US(WS-F)
         COMPUTE WS-FR-TK(WS-F) = SP-TICKS - WS-TK0
         MOVE MB-MESHED TO WS-FR-MS(WS-F)
         MOVE EN-COUNT TO WS-FR-ENT(WS-F)
         MOVE 0 TO WS-FR-USED(WS-F)
     END-PERFORM.

 REPORT-FRAMES.
     MOVE 0 TO WS-SUM-ALL WS-SUM-TK WS-SUM-NT WS-N-TK WS-N-NT WS-MAX
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-COUNT
         ADD WS-FR-US(WS-F) TO WS-SUM-ALL
         IF WS-FR-TK(WS-F) > 0
             ADD WS-FR-US(WS-F) TO WS-SUM-TK
             ADD 1 TO WS-N-TK
         ELSE
             ADD WS-FR-US(WS-F) TO WS-SUM-NT
             ADD 1 TO WS-N-NT
         END-IF
         IF WS-FR-US(WS-F) > WS-MAX
             MOVE WS-FR-US(WS-F) TO WS-MAX
         END-IF
         MOVE 0 TO WS-FR-USED(WS-F)
     END-PERFORM
     COMPUTE WS-RANK-99 = WS-COUNT / 100 + 1
     COMPUTE WS-RANK-50 = WS-COUNT / 2
     MOVE 10 TO WS-TOP-N
     MOVE 0 TO WS-P99 WS-P50
     CALL STATIC "getloadavg" USING WS-LOAD BY VALUE 3
     COMPUTE WS-LOAD-1 = WS-LOAD-AVG(1)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-RANK-50 AND WS-K > WS-RANK-99 AND WS-K > WS-TOP-N
         MOVE 0 TO WS-BEST WS-BEST-US
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-COUNT
             IF WS-FR-USED(WS-F) = 0 AND WS-FR-US(WS-F) >= WS-BEST-US
                 MOVE WS-F TO WS-BEST
                 MOVE WS-FR-US(WS-F) TO WS-BEST-US
             END-IF
         END-PERFORM
         IF WS-BEST > 0
             MOVE 1 TO WS-FR-USED(WS-BEST)
             IF WS-K = WS-RANK-99
                 MOVE WS-BEST-US TO WS-P99
             END-IF
             IF WS-K = WS-RANK-50
                 MOVE WS-BEST-US TO WS-P50
             END-IF
             IF WS-K <= WS-TOP-N
                 MOVE WS-K TO WS-D9
                 MOVE WS-BEST TO WS-D9B
                 MOVE WS-BEST-US TO WS-D9C
                 MOVE WS-FR-TK(WS-BEST) TO WS-D9D
                 MOVE WS-FR-MS(WS-BEST) TO WS-D9E
                 MOVE WS-FR-ENT(WS-BEST) TO WS-D9F
                 DISPLAY "BS " FUNCTION TRIM(WS-LABEL) " " FUNCTION TRIM(WS-PHASE) " longest " WS-D9 ": frame " WS-D9B " us " WS-D9C
                     " ticks " WS-D9D " meshed " WS-D9E " entity-rows " WS-D9F
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-MEAN = WS-SUM-ALL / WS-COUNT
     MOVE WS-MEAN TO WS-D9
     MOVE WS-P50 TO WS-D9B
     MOVE WS-P99 TO WS-D9C
     MOVE WS-MAX TO WS-D9D
     MOVE 0 TO WS-D9E WS-D9F
     IF WS-N-TK > 0
         COMPUTE WS-MEAN = WS-SUM-TK / WS-N-TK
         MOVE WS-MEAN TO WS-D9E
     END-IF
     IF WS-N-NT > 0
         COMPUTE WS-MEAN = WS-SUM-NT / WS-N-NT
         MOVE WS-MEAN TO WS-D9F
     END-IF
     MOVE WS-COUNT TO WS-D9G
     DISPLAY "BS " FUNCTION TRIM(WS-LABEL) " " FUNCTION TRIM(WS-PHASE) " frames " WS-D9G " us: mean " WS-D9 " p50 " WS-D9B " p99 " WS-D9C
         " max " WS-D9D " mean-tick-frames " WS-D9E " mean-other-frames " WS-D9F " load " WS-LOAD-1.
 END PROGRAM BENCH-STEADY-CLIENT.
