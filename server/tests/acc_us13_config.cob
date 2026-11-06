*> Acceptance test, US13-2 server half: the configuration file (contracts/operator-surface.md §2,
*> FR-009, operator decision A2). Given ./cobolcraft-server.conf the server uses its settings; given
*> none it writes the file with every non-pack key's default, each preceded by a one-line comment,
*> and uses them; a missing key takes its default; comment and blank lines are ignored; allow-list
*> seeds the enforcement flag of a newly created world only. Runs in build/server-test-config*.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US13-CONFIG.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT CONF-FILE ASSIGN TO WS-CONF-PATH
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD CONF-FILE.
 01 CONF-LINE              PIC X(1024).
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY SVSTATE.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256).
 01 WS-CONF                PIC X(4096).
 01 WS-CONF-PATH           PIC X(256) VALUE "cobolcraft-server.conf".
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-STATUS              PIC XX.
 01 WS-EXPECTED            PIC X(1707).
 01 WS-SETTINGS            PIC X(1707).
 01 WS-SUMMARY             PIC X(1024).
 01 WS-PAIRS               PIC X(1024).
 01 WS-AT                  BINARY-LONG.
 01 WS-LINE-NO             BINARY-LONG.
 01 WS-UNCOMMENTED         BINARY-LONG.
 01 WS-PREVIOUS            PIC X.
 01 WS-SHOW                PIC X(64) VALUE Z"guestlist show".
 01 WS-STATE               PIC X(8).
 01 WS-COUNT               PIC Z(7)9.
 01 WS-OBSERVED            PIC X(256).
 01 WS-ON                  BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 PROCEDURE DIVISION.
*>   The operator-surface §2 defaults, written out from the table.
     INITIALIZE CORE-SETTINGS
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE "A CobolCraft server" TO CS-DESCRIPTION
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-PLAYER-COMBAT CS-HOSTILE-MOBS CS-WEATHER-CHANGES CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-ALLOW-LIST-ENFORCED CS-PACK-OFFERED CS-PACK-REQUIRED CS-HOST-KIND
     MOVE "world" TO CS-NEW-WORLD-NAME

*>   US13-2: a configuration file with every non-pack key set away from its default.
     MOVE "build/server-test-config" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "# test configuration||port=25571|default-game-mode=survival|description=Configured "
         & "server|view-distance=12|player-combat=false|hostile-mobs=false|weather-changes=fals"
         & "e|extra-dimensions=false|allow-list=true" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     MOVE CORE-SETTINGS TO WS-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE CS-PLAYER-COMBAT CS-HOSTILE-MOBS CS-WEATHER-CHANGES
         CS-EXTRA-DIMENSIONS
     MOVE 1 TO CS-ALLOW-LIST-ENFORCED
     MOVE "Configured server" TO CS-DESCRIPTION
     MOVE 12 TO CS-VIEW-DISTANCE
     MOVE CORE-SETTINGS TO WS-EXPECTED
     MOVE WS-SETTINGS TO CORE-SETTINGS
     CALL "SV-START"
     MOVE "acceptance US13-2 given a configuration file when the server starts then it uses its "
         & "settings" TO TL-CASE
     CALL "SUMMARIZE" USING WS-EXPECTED SV-SETTINGS WS-SUMMARY
     MOVE "T" TO TL-MODE
     MOVE "port 25571 bound 25571 same" TO TL-EXPECTED
     MOVE WS-SUMMARY TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"

*>   US13-2: no configuration file.
     CALL "SVT-HOME"
     MOVE "build/server-test-config-none" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SV-START"
     MOVE SPACES TO WS-PAIRS
     MOVE 1 TO WS-AT
     MOVE 0 TO WS-LINE-NO WS-UNCOMMENTED
     MOVE "#" TO WS-PREVIOUS
     OPEN INPUT CONF-FILE
     PERFORM UNTIL WS-STATUS NOT = "00"
         MOVE SPACES TO CONF-LINE
         READ CONF-FILE
         IF WS-STATUS = "00"
             ADD 1 TO WS-LINE-NO
             IF CONF-LINE(1:1) NOT = "#"
                 IF WS-PREVIOUS NOT = "#"
                     ADD 1 TO WS-UNCOMMENTED
                 END-IF
                 IF WS-AT > 1
                     STRING " | " DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-AT
                 END-IF
                 STRING FUNCTION TRIM(CONF-LINE TRAILING) DELIMITED BY SIZE INTO WS-PAIRS
                     WITH POINTER WS-AT
             END-IF
             MOVE CONF-LINE(1:1) TO WS-PREVIOUS
         END-IF
     END-PERFORM
     CLOSE CONF-FILE
     MOVE "acceptance US13-2 given no configuration file when the server starts then it writes "
         & "cobolcraft-server.conf with every non-pack key's default, each preceded by a one-line "
         & "comment" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "port=25565 | default-game-mode=creative | description=A CobolCraft server | view-dis"
         & "tance=8 | player-combat=true | hostile-mobs=true | weather-changes=true | extra-dimen"
         & "sions=true | allow-list=false lines 18 uncommented 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LINE-NO TO WS-COUNT
     STRING FUNCTION TRIM(WS-PAIRS) " lines " FUNCTION TRIM(WS-COUNT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE WS-UNCOMMENTED TO WS-COUNT
     STRING FUNCTION TRIM(TL-OBSERVED) " uncommented " FUNCTION TRIM(WS-COUNT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13-2 given no configuration file when the server starts then it uses the "
         & "defaults" TO TL-CASE
     CALL "SUMMARIZE" USING CORE-SETTINGS SV-SETTINGS WS-SUMMARY
     MOVE "port 25565 bound 25565 same" TO TL-EXPECTED
     MOVE WS-SUMMARY TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"

*>   A missing key takes its default.
     CALL "SVT-HOME"
     MOVE "build/server-test-config-missing" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "port=25572|description=Only two keys" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     MOVE CORE-SETTINGS TO WS-SETTINGS
     MOVE "Only two keys" TO CS-DESCRIPTION
     MOVE CORE-SETTINGS TO WS-EXPECTED
     MOVE WS-SETTINGS TO CORE-SETTINGS
     CALL "SV-START"
     MOVE "acceptance US13-2 given a configuration file without some keys when the server starts "
         & "then each missing key takes its default" TO TL-CASE
     CALL "SUMMARIZE" USING WS-EXPECTED SV-SETTINGS WS-SUMMARY
     MOVE "port 25572 bound 25572 same" TO TL-EXPECTED
     MOVE WS-SUMMARY TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"

*>   Comment and blank lines are ignored.
     CALL "SVT-HOME"
     MOVE "build/server-test-config-comments" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "#port=1|   ||# description=commented out|  # view-distance=40|view-distance=3|"
         TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     MOVE CORE-SETTINGS TO WS-SETTINGS
     MOVE 3 TO CS-VIEW-DISTANCE
     MOVE CORE-SETTINGS TO WS-EXPECTED
     MOVE WS-SETTINGS TO CORE-SETTINGS
     CALL "SV-START"
     MOVE "acceptance US13-2 given a configuration file with comment and blank lines when the "
         & "server starts then they are ignored" TO TL-CASE
     CALL "SUMMARIZE" USING WS-EXPECTED SV-SETTINGS WS-SUMMARY
     MOVE "port 25565 bound 25565 same" TO TL-EXPECTED
     MOVE WS-SUMMARY TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"

*>   allow-list seeds the enforcement flag of a newly created world only (A2): observed with the
*>   console command guestlist show (standin-content §16, "Guest list enforcement on|off; ...").
     MOVE SPACES TO WS-OBSERVED
     CALL "SVT-HOME"
     MOVE "build/server-test-config-allow-on" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "port=25573|allow-list=true" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-START"
     PERFORM SHOW-ENFORCEMENT
     STRING "new world with true " DELIMITED BY SIZE WS-STATE DELIMITED BY SPACE
         INTO WS-OBSERVED
     CALL "CORE-SAVE"
     CALL "SV-SHUTDOWN"
     MOVE "port=25573|allow-list=false" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-START"
     PERFORM SHOW-ENFORCEMENT
     STRING FUNCTION TRIM(WS-OBSERVED) ", reopened with false " WS-STATE DELIMITED BY SIZE
         INTO WS-OBSERVED
     CALL "SV-SHUTDOWN"
     CALL "SVT-HOME"
     MOVE "build/server-test-config-allow-off" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "port=25573|allow-list=false" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-START"
     PERFORM SHOW-ENFORCEMENT
     STRING FUNCTION TRIM(WS-OBSERVED) "; new world with false " WS-STATE DELIMITED BY SIZE
         INTO WS-OBSERVED
     CALL "CORE-SAVE"
     CALL "SV-SHUTDOWN"
     MOVE "port=25573|allow-list=true" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-START"
     PERFORM SHOW-ENFORCEMENT
     STRING FUNCTION TRIM(WS-OBSERVED) ", reopened with true " WS-STATE DELIMITED BY SIZE
         INTO WS-OBSERVED
     CALL "SV-SHUTDOWN"
     MOVE "acceptance US13-2 allow-list seeds the enforcement flag of a newly created world only "
         & "(an existing world keeps the flag in its access.dat, A2)" TO TL-CASE
     MOVE "new world with true on, reopened with false on; new world with false off, reopened "
         & "with true off" TO TL-EXPECTED
     MOVE WS-OBSERVED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SVT-HOME"
     STOP RUN.

 SHOW-ENFORCEMENT.
     CALL "CORE-CONSOLE" USING WS-SHOW
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-ITERATE"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     MOVE 0 TO WS-ON WS-OFF
     INSPECT WS-CAPTURED TALLYING WS-ON FOR ALL "Guest list enforcement on;"
         WS-OFF FOR ALL "Guest list enforcement off;"
     EVALUATE TRUE
         WHEN WS-ON = 1 AND WS-OFF = 0
             MOVE "on" TO WS-STATE
         WHEN WS-ON = 0 AND WS-OFF = 1
             MOVE "off" TO WS-STATE
         WHEN OTHER
             MOVE "unknown" TO WS-STATE
     END-EVALUATE.
 END PROGRAM ACC-US13-CONFIG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUMMARIZE.
*> USING expected settings, observed settings (PIC X(1707) each), summary out: "port <SV-PORT>
*> bound <SV-BOUND-PORT> same" when the records are equal, else the observed fields that differ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 LINKAGE SECTION.
 01 L-EXPECTED             PIC X(1707).
 COPY COREAPI.
 01 L-SUMMARY              PIC X(1024).
 PROCEDURE DIVISION USING L-EXPECTED CORE-SETTINGS L-SUMMARY.
     MOVE SPACES TO L-SUMMARY
     MOVE SV-PORT TO WS-EDIT
     MOVE SV-BOUND-PORT TO WS-EDIT2
     STRING "port " FUNCTION TRIM(WS-EDIT) " bound " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO L-SUMMARY
     IF CORE-SETTINGS = L-EXPECTED
         STRING FUNCTION TRIM(L-SUMMARY) " same" DELIMITED BY SIZE INTO L-SUMMARY
     ELSE
         MOVE CS-VIEW-DISTANCE TO WS-EDIT
         STRING FUNCTION TRIM(L-SUMMARY) " differs: mode " CS-DEFAULT-MODE " view "
             FUNCTION TRIM(WS-EDIT) " combat " CS-PLAYER-COMBAT " mobs " CS-HOSTILE-MOBS
             " weather " CS-WEATHER-CHANGES " dims " CS-EXTRA-DIMENSIONS " allow "
             CS-ALLOW-LIST-ENFORCED " pack " CS-PACK-OFFERED " host " CS-HOST-KIND
             " description " FUNCTION TRIM(CS-DESCRIPTION) " name " FUNCTION TRIM(CS-NEW-WORLD-NAME)
             DELIMITED BY SIZE INTO L-SUMMARY
     END-IF
     GOBACK.
 END PROGRAM SUMMARIZE.
 COPY SVTEST.
