*> Real-data test (skipped as a pass without the generated packs; lane buglocate2 T32710, operator report: the single-player host runs /locate in its game frame and the game froze for the whole search).
*> A player's own `locate structure` line must give control back at once and be carried on by the game ticks (cmd-locate-async.cob): the command call returns within a small amount of CPU time
*> (the search of a desert pyramid from the spawn of seed 424242 is 2.8 s of CPU on the debug build, so it cannot have run inside the call), the reply is not there yet, every tick that carries the
*> search on spends a bounded amount of CPU time (the slice of 10 ms plus the unit of work it ends in), the world keeps ticking meanwhile (CW-TICKS counts every tick), the reply comes after more than one
*> tick, and it equals the answer of the whole search in one call (CXC-STRUCT-NEAREST: the position and the distance). A line nested in execute and the console answer at once as before; a player
*> who leaves drops the search (nothing is sent to the player that takes the row); a search that finds nothing within the radius ends with the not_found failure.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LOCATE-TICKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY LOCATEQ.
 COPY GENQUEUE.
 COPY STRUCTDATA.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-S                   BINARY-LONG.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-BERYL            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-ROW                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-WANT-ID             PIC X(80).
 01 WS-SHOWN               PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BD2                 BINARY-DOUBLE.
 01 WS-DISTANCE            BINARY-LONG.
 01 WS-EXPECTED            PIC X(300).
 01 WS-NUM-A               PIC -(9)9.
 01 WS-NUM-B               PIC -(9)9.
 01 WS-NUM-D               PIC -(9)9.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-MAX-US              BINARY-DOUBLE.
 01 WS-CALL-US             BINARY-DOUBLE.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TICKS-BEFORE        BINARY-LONG.
 01 WS-PENDING             BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-SECONDS             PIC -(6)9.999.
 01 WS-BOUND-US            BINARY-DOUBLE.
 01 WS-MIN-TICKS           BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
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
         MOVE "acceptance US13 /locate is carried on by the ticks: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "424242" TO CS-SEED-TEXT
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW
     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-SZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE 10000 TO LQ-SLICE
*>   the first tick after the join queues the chunks of the view: the ticks that generate them are not the search's, and the first fill step of a chunk prepares the beardifier from cold structure
*>   data (more than 0.6 s of CPU in one step, 36-1 9), so they are run before the searches are timed: what the bound below measures is the search's own work in a tick. The generation takes
*>   more ticks than the keep-alive allows an unanswered player, so the check is put far away like the other long-running tests do.
     MOVE 999999999 TO CN-KA-DEADLINE(WS-ID-OPAL)
     MOVE 0 TO WS-TICKS
     PERFORM WITH TEST AFTER UNTIL (GQ-COUNT = 0 AND GJ-ACTIVE = 0) OR WS-TICKS > 20000
         CALL "CORE-TICK"
         ADD 1 TO WS-TICKS
     END-PERFORM
     MOVE "acceptance US13 /locate the generation of the chunks of the view is finished before the searches are timed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GQ-COUNT = 0 AND GJ-ACTIVE = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the want: a desert pyramid (a rare single structure), the village tag, a mansion
     MOVE 1 TO WS-KIND
     MOVE "minecraft:desert_pyramid" TO WS-WANT-ID
     MOVE 300000 TO WS-BOUND-US
     MOVE 2 TO WS-MIN-TICKS
     PERFORM CHECK-WANT
*>   the village tag is near the spawn: the cell tests it needs are cheap after the one made for the expected answer, so it may take a single tick
     MOVE 2 TO WS-KIND
     MOVE "minecraft:village" TO WS-WANT-ID
     MOVE 1 TO WS-MIN-TICKS
     PERFORM CHECK-WANT
     MOVE 1 TO WS-KIND
     MOVE "minecraft:mansion" TO WS-WANT-ID
     MOVE 2 TO WS-MIN-TICKS
     PERFORM CHECK-WANT
     MOVE 1 TO WS-KIND
     MOVE "minecraft:stronghold" TO WS-WANT-ID
     MOVE 1 TO WS-MIN-TICKS
     PERFORM CHECK-WANT
     PERFORM CHECK-NESTED
     PERFORM CHECK-NOT-FOUND
     PERFORM CHECK-LEAVE
     PERFORM CHECK-FULL
     STOP RUN.

*> The want WS-KIND, WS-WANT-ID from the spawn: the command returns at once, the ticks carry the search on within the bound, the reply is the answer of CXC-STRUCT-NEAREST.
 CHECK-WANT.
     MOVE SPACES TO WS-LINE WS-SHOWN
     IF WS-KIND = 2
         STRING "locate structure #" FUNCTION TRIM(WS-WANT-ID) DELIMITED BY SIZE INTO WS-LINE
         STRING "#" FUNCTION TRIM(WS-WANT-ID) DELIMITED BY SIZE INTO WS-SHOWN
     ELSE
         STRING "locate structure " FUNCTION TRIM(WS-WANT-ID) DELIMITED BY SIZE INTO WS-LINE
         MOVE WS-WANT-ID TO WS-SHOWN
     END-IF
     CALL "CXC-STRUCT-NEAREST" USING WS-KIND WS-WANT-ID WS-SX WS-SZ CW-SEED WS-FOUND WS-BX WS-BZ WS-BD2
     COMPUTE WS-DISTANCE = FUNCTION INTEGER(FUNCTION SQRT(WS-BD2))
*>   the concentric rings have their positions snapped by the answer above: a fresh list, so the ticks do the snapping (3249 biome lookups a position)
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         IF SS-KIND(WS-S) = 0
             MOVE CW-SEED TO WS-SEED
             CALL "STRUCT-RINGS-PREP" USING WS-S WS-SEED
         END-IF
     END-PERFORM
     CALL "COST-CLOCK" USING WS-T0
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "COST-CLOCK" USING WS-T1
     COMPUTE WS-CALL-US = WS-T1 - WS-T0
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate " FUNCTION TRIM(WS-SHOWN) " the command returns control within 0.25 s of CPU and has no reply yet" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CALL-US < 250000 AND WS-TEXT = SPACES
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-PENDING
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate " FUNCTION TRIM(WS-SHOWN) " the search waits in the queue" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-TICKS WS-MAX-US
     MOVE CW-TICKS TO WS-TICKS-BEFORE
     PERFORM UNTIL WS-PENDING = 0 OR WS-TICKS > 20000
         CALL "COST-CLOCK" USING WS-T0
         CALL "CORE-TICK"
         CALL "COST-CLOCK" USING WS-T1
         ADD 1 TO WS-TICKS
         IF WS-T1 - WS-T0 > WS-MAX-US
             COMPUTE WS-MAX-US = WS-T1 - WS-T0
         END-IF
         PERFORM COUNT-PENDING
     END-PERFORM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     COMPUTE WS-SECONDS = WS-MAX-US / 1000000
     DISPLAY "LOCATE " FUNCTION TRIM(WS-SHOWN) " ticks=" WS-TICKS " max tick cpu=" WS-SECONDS " s"
     MOVE WS-BX TO WS-NUM-A
     MOVE WS-BZ TO WS-NUM-B
     MOVE WS-DISTANCE TO WS-NUM-D
     MOVE SPACES TO WS-EXPECTED
     STRING "commands.locate.structure.success(" FUNCTION TRIM(WS-SHOWN) ",[" FUNCTION TRIM(WS-NUM-A) ", ~, " FUNCTION TRIM(WS-NUM-B) "]," FUNCTION TRIM(WS-NUM-D) ")"
         DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate " FUNCTION TRIM(WS-SHOWN) " the reply after the ticks is the answer of the whole search" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate " FUNCTION TRIM(WS-SHOWN) " took its ticks and the world ticked each of them" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TICKS >= WS-MIN-TICKS AND CW-TICKS - WS-TICKS-BEFORE = WS-TICKS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate " FUNCTION TRIM(WS-SHOWN) " no tick spent more than 0.3 s of CPU" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAX-US < WS-BOUND-US
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 COUNT-PENDING.
     MOVE 0 TO WS-PENDING
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > LQ-MAX
         ADD LQ-USED(WS-E) TO WS-PENDING
     END-PERFORM.

*> A line nested in execute is answered at once (the answer of a function or a command's result can not wait), and so is the console's.
 CHECK-NESTED.
     MOVE "execute as Opal run locate structure #minecraft:village" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TEXT(1:34) = "commands.locate.structure.success("
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "acceptance US13 /locate a line nested in execute is answered at once" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "locate structure #minecraft:village" TO WS-LINE
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TEXT(1:5) NOT = SPACES
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "acceptance US13 /locate the console's line is answered at once" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> A structure no biome of the overworld can hold (the end city) finds nothing within the radius: the search ends after its ticks with the not_found failure.
 CHECK-NOT-FOUND.
     MOVE "locate structure minecraft:end_city" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "commands.locate.structure.not_found(minecraft:end_city)" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "acceptance US13 /locate a search that finds nothing ends with not_found" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE.

*> A player who leaves drops the search: the one who takes the row is told nothing.
 CHECK-LEAVE.
     MOVE "locate structure minecraft:desert_pyramid" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     PERFORM COUNT-PENDING
     MOVE "acceptance US13 /locate the search of the player who leaves was queued" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW
     CALL "PLAYER-LEAVE" USING WS-ROW
     MOVE "Beryl" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-BERYL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BERYL WS-DISCARD
     MOVE 1000000 TO LQ-SLICE
     MOVE 0 TO WS-TICKS
     PERFORM 3 TIMES
         CALL "CORE-TICK"
     END-PERFORM
     PERFORM COUNT-PENDING
     MOVE "acceptance US13 /locate the search of a player who left is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BERYL WS-TEXT
     MOVE "acceptance US13 /locate the player who took the row is sent nothing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TEXT = SPACES
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> A full queue (eight searches waiting) answers the ninth at once, as a line the queue cannot take; the player who leaves drops all eight.
 CHECK-FULL.
     MOVE CN-PLAYER(WS-ID-BERYL) TO WS-ROW
     MOVE "locate structure minecraft:desert_pyramid" TO WS-LINE
     PERFORM 8 TIMES
         CALL "TEST-COMMAND" USING WS-ID-BERYL WS-LINE
     END-PERFORM
     PERFORM COUNT-PENDING
     MOVE "acceptance US13 /locate eight searches wait in the queue" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BERYL WS-DISCARD
     MOVE "locate structure #minecraft:village" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-BERYL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BERYL WS-TEXT
     MOVE "acceptance US13 /locate a ninth search with a full queue is answered at once" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TEXT(1:34) = "commands.locate.structure.success("
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PLAYER-LEAVE" USING WS-ROW
     CALL "CORE-TICK"
     PERFORM COUNT-PENDING
     MOVE "acceptance US13 /locate the queue is empty when its player left" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CMD-LOCATE-TICKS.

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
 COPY CMDTEST.
