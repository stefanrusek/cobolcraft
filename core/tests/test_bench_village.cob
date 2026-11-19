*> Measurement program (002-lane-bugvlag; operator report: "much smoother, but not in the village, wow that is laggy"): the CPU cost of the core's tick phases
*> with a player standing in a village, against the same world in an empty field. Without CC_VB_BENCH it only checks that a village scene runs 20 ticks (a pass, so the
*> test list stays green); with it, it prints `VB ...` lines: for each phase of CORE-TICK the mean and the longest CPU time in microseconds over CC_VB_TICKS ticks, the
*> entity census and (CC_VB_MOBS=1) the cost of MOB-STEP summed by species.
*>   CC_VB_BENCH      any value: measure
*>   CC_VB_WORLD      superflat (default; the flat preset) or standard
*>   CC_VB_SEED       seed text (default 12345)
*>   CC_VB_AT         village (default: the first village start of the scan) or field (that start moved 60 chunks away)
*>   CC_VB_VIEW       view distance (default 8)
*>   CC_VB_TICKS      measured ticks (default 200)
*>   CC_VB_SETTLE     ticks run after the warm-up and before the measured ones (default 30)
*>   CC_VB_MOBS       1: per-species MOB-STEP table in place of the MOBS-TICK phase
*>   CC_VB_FOLDER     world folder kept between runs (default build/bvw-<world>-<seed>-<at>); the chunks made by the warm-up are saved there and loaded on the next run
*>   CC_GENERATED_DIR the generated packs (as every real-data test)
*> The clock is the process CPU time (C clock()), so a loaded machine moves it little. The tick is CORE-TICK's own sequence, called phase by phase, without SESSION-TICK (the bench's player answers no keep-alive and would be kicked after about 600 ticks).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BENCH-VILLAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY FLATSET.
 COPY STRUCTDATA.
 COPY PROTO.
 COPY STDMOBS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-VILLAGES            BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-KEY80               PIC X(80).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BENCH               PIC X(8).
 01 WS-WORLD               PIC X(10).
 01 WS-SEED-TEXT           PIC X(64).
 01 WS-AT                  PIC X(8).
 01 WS-VIEW                BINARY-LONG VALUE 8.
 01 WS-TICKS               BINARY-LONG VALUE 200.
 01 WS-SETTLE              BINARY-LONG VALUE 30.
 01 WS-MOBS                PIC X(8).
 01 WS-FOLDER              PIC X(1024).
 01 WS-FOLDER-Z            PIC X(1025).
 01 WS-CREATED             BINARY-LONG.
 01 WS-TICK                BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-DT                  BINARY-DOUBLE.
 01 WS-U0                  BINARY-DOUBLE.
 01 WS-U1                  BINARY-DOUBLE.
 01 WS-UDT                 BINARY-DOUBLE.
 01 WS-LAST-CHUNKS         BINARY-LONG.
 01 WS-STABLE              BINARY-LONG.
 01 WS-WARM                BINARY-LONG.
 01 WS-DRAINED             BINARY-DOUBLE.
 01 WS-DRAIN-MAX           BINARY-LONG.
 01 WS-TICK-TOTAL          BINARY-DOUBLE.
 01 WS-TICK-TOTAL-ONE      BINARY-DOUBLE.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FOUND-VILLAGE       BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GSTATE              BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-TICK-MAX            BINARY-DOUBLE.
 01 WS-MEAN                BINARY-DOUBLE.
 01 WS-N1                  PIC -(8)9.
 01 WS-N2                  PIC -(8)9.
 01 WS-N3                  PIC -(8)9.
 01 WS-PHASES.
    05 WS-PHASE-ENTRY OCCURS 40 TIMES.
       10 PH-NAME          PIC X(24).
       10 PH-SUM           BINARY-DOUBLE.
       10 PH-MAX           BINARY-DOUBLE.
 01 WS-SPECIES.
    05 WS-SP-ENTRY OCCURS 200 TIMES.
       10 SP-SUM           BINARY-DOUBLE.
       10 SP-MAX           BINARY-DOUBLE.
       10 SP-STEPS         BINARY-DOUBLE.
       10 SP-LIVE          BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-MOB-INDEX           BINARY-LONG.
 01 WS-STD-INDEX           BINARY-LONG.
 01 WS-ROWS-ORDER.
    05 WS-ORDER            BINARY-LONG OCCURS 1024 TIMES.
 01 WS-ORDERED             BINARY-LONG.
 01 WS-DEBUG               BINARY-LONG.
 01 WS-HOSTILE             BINARY-LONG.
 01 WS-ENTS                BINARY-LONG.
 01 WS-STOPPED             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV WS-BENCH
     ACCEPT WS-BENCH FROM ENVIRONMENT "CC_VB_BENCH"
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "bench village no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "superflat" TO WS-WORLD
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_VB_WORLD"
     IF WS-ENV NOT = SPACES
         MOVE WS-ENV TO WS-WORLD
     END-IF
     MOVE "12345" TO WS-SEED-TEXT
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_VB_SEED"
     IF WS-ENV NOT = SPACES
         MOVE WS-ENV TO WS-SEED-TEXT
     END-IF
     MOVE "village" TO WS-AT
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_VB_AT"
     IF WS-ENV NOT = SPACES
         MOVE WS-ENV TO WS-AT
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_VB_VIEW"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-VIEW = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_VB_TICKS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TICKS = FUNCTION NUMVAL(WS-ENV)
     END-IF
     MOVE SPACES TO WS-MOBS
     ACCEPT WS-MOBS FROM ENVIRONMENT "CC_VB_MOBS"
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_VB_SETTLE"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-SETTLE = FUNCTION NUMVAL(WS-ENV)
     END-IF
     IF WS-BENCH = SPACES
         MOVE 2 TO WS-VIEW
         MOVE 20 TO WS-TICKS
         MOVE SPACES TO WS-MOBS
     END-IF
     MOVE SPACES TO WS-FOLDER
     ACCEPT WS-FOLDER FROM ENVIRONMENT "CC_VB_FOLDER"
     IF WS-FOLDER = SPACES
         IF WS-BENCH = SPACES
             MOVE "build/bvw-smoke" TO WS-FOLDER
         ELSE
             STRING "build/bvw-" FUNCTION TRIM(WS-WORLD) "-" FUNCTION TRIM(WS-SEED-TEXT) "-" FUNCTION TRIM(WS-AT)
                 DELIMITED BY SIZE INTO WS-FOLDER
         END-IF
     END-IF
     IF WS-BENCH = SPACES
         MOVE SPACES TO WS-FILE
         STRING "rm -rf " FUNCTION TRIM(WS-FOLDER) DELIMITED BY SIZE INTO WS-FILE
         CALL "SYSTEM" USING WS-FILE
     END-IF
     MOVE SPACES TO WS-FOLDER-Z
     STRING FUNCTION TRIM(WS-FOLDER) X"00" DELIMITED BY SIZE INTO WS-FOLDER-Z
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE WS-WORLD TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE WS-VIEW TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
     MOVE WS-SEED-TEXT TO CS-SEED-TEXT
     MOVE "Bench" TO CS-NEW-WORLD-NAME
     MOVE 0 TO FS-PENDING
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER-Z CORE-SETTINGS WS-CREATED
     MOVE CW-SEED TO WS-SEED
     PERFORM SCAN-STARTS
     IF WS-AT = "field"
         PERFORM FIND-FIELD
     END-IF
     DISPLAY "VB world " FUNCTION TRIM(WS-WORLD) " seed " FUNCTION TRIM(WS-SEED-TEXT) " at " FUNCTION TRIM(WS-AT)
         " chunk " WS-VX " " WS-VZ " view " WS-VIEW " created " WS-CREATED
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-VX * 16 + 8.5
     COMPUTE PL-Z(WS-PLAYER) = WS-VZ * 16 + 8.5
     IF WS-WORLD = "superflat"
         MOVE -60 TO PL-Y(WS-PLAYER)
     ELSE
         MOVE 150 TO PL-Y(WS-PLAYER)
     END-IF
     CALL "CHUNKS-FOLLOW" USING WS-CONN
     PERFORM DRAIN
*>   warm-up: tick until the chunk count has not changed for 60 ticks (the queue makes a few chunks a tick), at most 6000 ticks
     MOVE 0 TO WS-LAST-CHUNKS WS-STABLE WS-WARM
     PERFORM UNTIL WS-STABLE >= 60 OR WS-WARM >= 6000
         CALL "TEST-TICKS" USING WS-ONE
         PERFORM DRAIN
         ADD 1 TO WS-WARM
         IF CK-COUNT = WS-LAST-CHUNKS
             ADD 1 TO WS-STABLE
         ELSE
             MOVE 0 TO WS-STABLE
             MOVE CK-COUNT TO WS-LAST-CHUNKS
         END-IF
     END-PERFORM
     DISPLAY "VB warm-up ticks " WS-WARM " chunks " CK-COUNT
     IF WS-BENCH NOT = SPACES
         CALL "CORE-SAVE"
     END-IF
     PERFORM CENSUS
*>   the player stands on the topmost block of the village chunk's centre column (mobs more than 32 blocks away, in 3D, are not stepped)
     COMPUTE WS-GX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-GZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 0 TO WS-GSTATE
     PERFORM VARYING WS-GY FROM 300 BY -1 UNTIL WS-GY < -64 OR WS-GSTATE NOT = 0
         CALL "WORLD-GET-BLOCK" USING PL-DIM(WS-PLAYER) WS-GX WS-GY WS-GZ WS-GSTATE
     END-PERFORM
     COMPUTE PL-Y(WS-PLAYER) = WS-GY + 2
     DISPLAY "VB player at " WS-GX " " PL-Y(WS-PLAYER) " " WS-GZ
     PERFORM VARYING WS-TICK FROM 1 BY 1 UNTIL WS-TICK > WS-SETTLE
         PERFORM ONE-TICK
         PERFORM DRAIN
     END-PERFORM
     DISPLAY "VB measuring"
     MOVE SPACES TO WS-PHASES
     PERFORM VARYING WS-PHASE FROM 1 BY 1 UNTIL WS-PHASE > 40
         MOVE 0 TO PH-SUM(WS-PHASE) PH-MAX(WS-PHASE)
     END-PERFORM
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 200
         MOVE 0 TO SP-SUM(WS-S) SP-MAX(WS-S) SP-STEPS(WS-S) SP-LIVE(WS-S)
     END-PERFORM
     MOVE 0 TO WS-TICK-TOTAL WS-TICK-MAX WS-DRAINED WS-DRAIN-MAX
     PERFORM VARYING WS-TICK FROM 1 BY 1 UNTIL WS-TICK > WS-TICKS
         PERFORM ONE-TICK
         PERFORM DRAIN-COUNT
     END-PERFORM
     PERFORM REPORT-PHASES
     MOVE "N" TO TL-MODE
     MOVE "bench village the scene ran its ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TICK-TOTAL > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 DRAIN.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     CALL "PB-FREE" USING PB-BUFFER.

 DRAIN-COUNT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     ADD PB-LENGTH TO WS-DRAINED
     IF PB-LENGTH > WS-DRAIN-MAX
         MOVE PB-LENGTH TO WS-DRAIN-MAX
     END-IF
     CALL "PB-FREE" USING PB-BUFFER.

*> One CORE-TICK (core/src/api.cob), phase by phase with the CPU clock round each. Phase 8 (MOBS-TICK) is MOBS-TICK itself unless CC_VB_MOBS is set.
 ONE-TICK.
     ADD 1 TO CW-TICKS
     CALL "CMD-SUGGEST-FLUSH"
     MOVE 0 TO WS-TICK-TOTAL-ONE
     PERFORM VARYING WS-PHASE FROM 1 BY 1 UNTIL WS-PHASE > 22
         CALL "COST-CLOCK" USING WS-T0
         EVALUATE WS-PHASE
             WHEN 1
                 MOVE "WORLDSIM-SLEEP-TICK" TO PH-NAME(1)
                 CALL "WORLDSIM-SLEEP-TICK"
             WHEN 2
                 MOVE "WORLD-TIME-TICK" TO PH-NAME(2)
                 CALL "WORLD-TIME-TICK"
             WHEN 3
                 MOVE "WEATHER-TICK" TO PH-NAME(3)
                 CALL "WEATHER-TICK"
             WHEN 4
                 MOVE "WORLDSIM-TICK" TO PH-NAME(4)
                 CALL "WORLDSIM-TICK"
             WHEN 5
                 MOVE "BLOCKS-TICK" TO PH-NAME(5)
                 CALL "BLOCKS-TICK"
             WHEN 6
                 MOVE "HEALTH-TICK" TO PH-NAME(6)
                 CALL "HEALTH-TICK"
             WHEN 7
                 MOVE "PORTAL+END-TRAVEL" TO PH-NAME(7)
                 CALL "PORTAL-TICK"
                 CALL "END-TRAVEL-TICK"
             WHEN 8
                 MOVE "MOBS-SPAWN-TICK" TO PH-NAME(8)
                 CALL "MOBS-SPAWN-TICK"
             WHEN 9
                 MOVE "MOBS-TICK" TO PH-NAME(9)
                 IF WS-MOBS = SPACES
                     CALL "MOBS-TICK"
                 ELSE
                     PERFORM MOBS-BY-SPECIES
                 END-IF
             WHEN 10
                 MOVE "GROUND-ITEMS+XP-ORBS" TO PH-NAME(10)
                 CALL "GROUND-ITEMS-TICK"
                 CALL "XP-ORBS-TICK"
             WHEN 11
                 MOVE "ARROWS+PROJ+THROWN" TO PH-NAME(11)
                 CALL "ARROWS-TICK"
                 CALL "PROJECTILES-TICK"
                 CALL "THROWN-TICK"
             WHEN 12
                 MOVE "FIGHT+LIGHTNING+TNT+FB" TO PH-NAME(12)
                 CALL "FIGHT-TICK"
                 CALL "LIGHTNING-WEATHER-TICK"
                 CALL "TNT-TICK"
                 CALL "FB-TICK"
             WHEN 13
                 MOVE "BOAT-TICK" TO PH-NAME(13)
                 CALL "BOAT-TICK"
             WHEN 14
                 MOVE "BE-TICK-ALL" TO PH-NAME(14)
                 CALL "BE-TICK-ALL"
             WHEN 15
                 MOVE "MENU-DATA-TICK" TO PH-NAME(15)
                 CALL "MENU-DATA-TICK"
             WHEN 16
                 MOVE "GEN-QUEUE+SPAWN" TO PH-NAME(16)
                 CALL "GEN-QUEUE-TICK"
                 CALL "GEN-SPAWN-TICK"
             WHEN 17
                 MOVE "CHUNK-FEED-TICK" TO PH-NAME(17)
                 CALL "CHUNK-FEED-TICK"
             WHEN 18
                 MOVE "CRAFT-REFRESH-ALL" TO PH-NAME(18)
                 CALL "CRAFT-REFRESH-ALL"
             WHEN 19
                 MOVE "MENU-TICK" TO PH-NAME(19)
                 CALL "MENU-TICK"
             WHEN 20
                 MOVE "WORLDSIM-ACKS" TO PH-NAME(20)
                 CALL "WORLDSIM-ACKS"
             WHEN 21
                 MOVE "AUTOSAVE" TO PH-NAME(21)
                 CALL "WORLD-AUTOSAVE-TICK"
             WHEN 22
                 MOVE "SESSION-TICK (not run)" TO PH-NAME(22)
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
         CALL "COST-CLOCK" USING WS-T1
         COMPUTE WS-DT = WS-T1 - WS-T0
         ADD WS-DT TO PH-SUM(WS-PHASE)
         ADD WS-DT TO WS-TICK-TOTAL-ONE
         IF WS-DT > PH-MAX(WS-PHASE)
             MOVE WS-DT TO PH-MAX(WS-PHASE)
         END-IF
     END-PERFORM
     ADD WS-TICK-TOTAL-ONE TO WS-TICK-TOTAL
     IF WS-TICK-TOTAL-ONE > WS-TICK-MAX
         MOVE WS-TICK-TOTAL-ONE TO WS-TICK-MAX
     END-IF.

*> MOBS-TICK of core/src/mobs.cob with a clock round each MOB-STEP, summed by species (the order is the row order, not the entity id order: a cost view only).
 MOBS-BY-SPECIES.
     CALL "BEE-HIVES-TICK"
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         MOVE 0 TO WS-MOB-INDEX WS-STD-INDEX
         IF EN-USED(WS-ROW) = 1
             CALL "MOB-INDEX" USING EN-TYPE(WS-ROW) WS-MOB-INDEX
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-STD-INDEX
         END-IF
         MOVE 1 TO WS-ACTIVE
         IF (WS-MOB-INDEX > 0 OR WS-STD-INDEX > 0) AND EN-USED(WS-ROW) = 1
             CALL "MOB-ACTIVE" USING WS-ROW WS-ACTIVE
         END-IF
         IF (WS-MOB-INDEX > 0 OR WS-STD-INDEX > 0) AND EN-USED(WS-ROW) = 1 AND WS-ACTIVE = 1
             IF WS-STD-INDEX > 0
                 MOVE WS-STD-INDEX TO WS-S
             ELSE
                 MOVE 200 TO WS-S
             END-IF
             CALL "COST-CLOCK" USING WS-U0
             CALL "MS6-DESPAWN-TICK" USING WS-ROW
             IF EN-USED(WS-ROW) = 1
                 CALL "MOB-STEP" USING WS-ROW
             END-IF
             CALL "COST-CLOCK" USING WS-U1
             COMPUTE WS-UDT = WS-U1 - WS-U0
             ADD WS-UDT TO SP-SUM(WS-S)
             ADD 1 TO SP-STEPS(WS-S)
             IF WS-UDT > SP-MAX(WS-S)
                 MOVE WS-UDT TO SP-MAX(WS-S)
             END-IF
         END-IF
     END-PERFORM.

 REPORT-PHASES.
     COMPUTE WS-MEAN = WS-TICK-TOTAL / WS-TICKS
     MOVE WS-MEAN TO WS-N1
     MOVE WS-TICK-MAX TO WS-N2
     DISPLAY "VB tick us mean " WS-N1 " max " WS-N2 " over " WS-TICKS " ticks"
     COMPUTE WS-MEAN = WS-DRAINED / WS-TICKS
     MOVE WS-MEAN TO WS-N1
     MOVE WS-DRAIN-MAX TO WS-N2
     DISPLAY "VB packets bytes a tick mean " WS-N1 " max " WS-N2 " (to the one player)"
     PERFORM VARYING WS-PHASE FROM 1 BY 1 UNTIL WS-PHASE > 22
         COMPUTE WS-MEAN = PH-SUM(WS-PHASE) / WS-TICKS
         MOVE WS-MEAN TO WS-N1
         MOVE PH-MAX(WS-PHASE) TO WS-N2
         DISPLAY "VB phase " PH-NAME(WS-PHASE) " us mean " WS-N1 " max " WS-N2
     END-PERFORM
     IF WS-MOBS NOT = SPACES
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 200
             IF SP-STEPS(WS-S) > 0
                 COMPUTE WS-MEAN = SP-SUM(WS-S) / WS-TICKS
                 MOVE WS-MEAN TO WS-N1
                 COMPUTE WS-MEAN = SP-SUM(WS-S) / SP-STEPS(WS-S)
                 MOVE WS-MEAN TO WS-N2
                 MOVE SP-MAX(WS-S) TO WS-N3
                 IF WS-S = 200
                     DISPLAY "VB species (older mob table) us a tick " WS-N1 " a step " WS-N2 " max step " WS-N3
                 ELSE
                     DISPLAY "VB species " SM-KEY(WS-S) " us a tick " WS-N1 " a step " WS-N2 " max step " WS-N3
                 END-IF
             END-IF
         END-PERFORM
     END-IF.

 CENSUS.
     MOVE 0 TO WS-ENTS
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND WS-ROW NOT = PL-ENTITY-ROW(WS-PLAYER)
             ADD 1 TO WS-ENTS
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0
                 ADD 1 TO SP-LIVE(WS-S)
             END-IF
         END-IF
     END-PERFORM
     DISPLAY "VB entities " WS-ENTS " chunks " CK-COUNT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 200
         IF SP-LIVE(WS-S) > 0
             MOVE SP-LIVE(WS-S) TO WS-N1
             DISPLAY "VB   census " SM-KEY(WS-S) WS-N1
         END-IF
     END-PERFORM.

 FIND-FIELD.
*>   the first of a walk of centres from the village with no village start within 14 chunks of it on either axis
     MOVE WS-VX TO WS-FX
     MOVE WS-VZ TO WS-FZ
     MOVE 1 TO WS-FOUND-VILLAGE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 60 OR WS-FOUND-VILLAGE = 0
         COMPUTE WS-FX = WS-VX + 9 * WS-K
         COMPUTE WS-FZ = WS-VZ - 13 * WS-K
         MOVE 0 TO WS-FOUND-VILLAGE
         PERFORM VARYING WS-CX FROM -14 BY 1 UNTIL WS-CX > 14
             PERFORM VARYING WS-CZ FROM -14 BY 1 UNTIL WS-CZ > 14
                 COMPUTE WS-QX = WS-FX + WS-CX
                 COMPUTE WS-QZ = WS-FZ + WS-CZ
                 CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-QX WS-QZ WS-COUNT
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
                     MOVE SDT-KEY(SC-STRUCT(WS-J)) TO WS-KEY80
                     IF WS-KEY80(1:18) = "minecraft:village_"
                         MOVE 1 TO WS-FOUND-VILLAGE
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-FX TO WS-VX
     MOVE WS-FZ TO WS-VZ.

 SCAN-STARTS.
     MOVE 0 TO WS-VILLAGES WS-VX WS-VZ
     IF SD-POSS-DONE = 0
         CALL "STRUCT-POSSIBLE-BUILD"
     END-IF
     PERFORM VARYING WS-CX FROM -30 BY 1 UNTIL WS-CX > 30
         PERFORM VARYING WS-CZ FROM -30 BY 1 UNTIL WS-CZ > 30
             CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-CX WS-CZ WS-COUNT
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
                 MOVE SDT-KEY(SC-STRUCT(WS-J)) TO WS-KEY80
                 IF WS-KEY80(1:18) = "minecraft:village_" AND WS-VILLAGES = 0
                     MOVE WS-CX TO WS-VX
                     MOVE WS-CZ TO WS-VZ
                     ADD 1 TO WS-VILLAGES
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-BENCH-VILLAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. COST-CLOCK.
*> USING microseconds out: the CPU time of the process (C clock(), CLOCKS_PER_SEC is 1000000 on this platform).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-US                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-US.
     CALL STATIC "clock" RETURNING L-US
     GOBACK.
 END PROGRAM COST-CLOCK.

 COPY NOSPAWN.
 COPY CORETEST.
