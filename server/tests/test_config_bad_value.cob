*> Fatal-path test of the configuration values (server/src/config-file.cob; operator-surface §2,
*> research R14): an invalid value ends the server with "FATAL configuration: <key>: <problem>" and
*> exit status 1. One sub-case per key type (port range, game mode, text length, view distance 2 to
*> 32, boolean) runs in a forked child (SVT-FORK) whose exit status and standard error are checked;
*> the last sub-case (a bad allow-list boolean) runs in the program itself, for the runner's .expect
*> mechanism (test_config_bad_value.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIG-BAD-VALUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-config-bad".
 01 WS-CONF                PIC X(4096).
 01 WS-PORT                BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 01 WS-STDERR              PIC X(4096).
 01 WS-EDIT                PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-PORT-PROBLEM        PIC X(64) VALUE "must be a number from 1 to 65535".
 01 WS-VIEW-PROBLEM        PIC X(64) VALUE "must be a number from 2 to 32".
 01 WS-BOOLEAN-PROBLEM     PIC X(64) VALUE "must be true or false".
 01 WS-CASES.
    05 FILLER PIC X(64) VALUE "port=0".
    05 FILLER PIC X(64) VALUE "port".
    05 FILLER PIC X(64) VALUE "P".
    05 FILLER PIC X(64) VALUE "port=65536".
    05 FILLER PIC X(64) VALUE "port".
    05 FILLER PIC X(64) VALUE "P".
    05 FILLER PIC X(64) VALUE "port=25a65".
    05 FILLER PIC X(64) VALUE "port".
    05 FILLER PIC X(64) VALUE "P".
    05 FILLER PIC X(64) VALUE "port=".
    05 FILLER PIC X(64) VALUE "port".
    05 FILLER PIC X(64) VALUE "P".
    05 FILLER PIC X(64) VALUE "port=1234567890".
    05 FILLER PIC X(64) VALUE "port".
    05 FILLER PIC X(64) VALUE "P".
    05 FILLER PIC X(64) VALUE "default-game-mode=adventure".
    05 FILLER PIC X(64) VALUE "default-game-mode".
    05 FILLER PIC X(64) VALUE "must be creative or survival".
    05 FILLER PIC X(64) VALUE "default-game-mode=Creative".
    05 FILLER PIC X(64) VALUE "default-game-mode".
    05 FILLER PIC X(64) VALUE "must be creative or survival".
    05 FILLER PIC X(64) VALUE "description=".
    05 FILLER PIC X(64) VALUE "description".
    05 FILLER PIC X(64) VALUE "longer than 256 characters".
    05 FILLER PIC X(64) VALUE "view-distance=1".
    05 FILLER PIC X(64) VALUE "view-distance".
    05 FILLER PIC X(64) VALUE "V".
    05 FILLER PIC X(64) VALUE "view-distance=33".
    05 FILLER PIC X(64) VALUE "view-distance".
    05 FILLER PIC X(64) VALUE "V".
    05 FILLER PIC X(64) VALUE "view-distance=eight".
    05 FILLER PIC X(64) VALUE "view-distance".
    05 FILLER PIC X(64) VALUE "V".
    05 FILLER PIC X(64) VALUE "player-combat=yes".
    05 FILLER PIC X(64) VALUE "player-combat".
    05 FILLER PIC X(64) VALUE "B".
    05 FILLER PIC X(64) VALUE "hostile-mobs=1".
    05 FILLER PIC X(64) VALUE "hostile-mobs".
    05 FILLER PIC X(64) VALUE "B".
    05 FILLER PIC X(64) VALUE "weather-changes=TRUE".
    05 FILLER PIC X(64) VALUE "weather-changes".
    05 FILLER PIC X(64) VALUE "B".
    05 FILLER PIC X(64) VALUE "extra-dimensions=".
    05 FILLER PIC X(64) VALUE "extra-dimensions".
    05 FILLER PIC X(64) VALUE "B".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 15 TIMES.
       10 WS-LINE          PIC X(64).
       10 WS-KEY           PIC X(64).
       10 WS-PROBLEM       PIC X(64).
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         EVALUATE WS-PROBLEM(WS-I)
             WHEN "P"
                 MOVE WS-PORT-PROBLEM TO WS-PROBLEM(WS-I)
             WHEN "V"
                 MOVE WS-VIEW-PROBLEM TO WS-PROBLEM(WS-I)
             WHEN "B"
                 MOVE WS-BOOLEAN-PROBLEM TO WS-PROBLEM(WS-I)
         END-EVALUATE
         MOVE SPACES TO WS-CONF
         STRING "# sub-case||port=25565|" DELIMITED BY SIZE WS-LINE(WS-I) DELIMITED BY SPACE
             INTO WS-CONF
*>       The text-length sub-case: a description of 257 characters.
         IF WS-KEY(WS-I) = "description"
             MOVE ALL "d" TO WS-CONF(36:257)
         END-IF
         CALL "SVT-WRITE-CONF" USING WS-CONF
         CALL "SVT-FORK" USING WS-PID
         IF WS-PID = 0
             CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
             STOP RUN
         END-IF
         CALL "SVT-WAIT" USING WS-PID WS-EXIT WS-STDERR
         MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
         STRING "test config bad value " WS-LINE(WS-I) DELIMITED BY "  " " is fatal"
             DELIMITED BY SIZE INTO TL-CASE
         IF WS-KEY(WS-I) = "description"
             MOVE "test config bad value a description of 257 characters is fatal" TO TL-CASE
         END-IF
         MOVE "T" TO TL-MODE
         STRING "exit 1 FATAL configuration: " FUNCTION TRIM(WS-KEY(WS-I)) ": "
             FUNCTION TRIM(WS-PROBLEM(WS-I)) DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE WS-EXIT TO WS-EDIT
         STRING "exit " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-STDERR) DELIMITED BY SIZE
             INTO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   The last boolean sub-case, checked by the runner (exit 1 and its standard error).
     MOVE "port=25565|allow-list=maybe" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     STOP RUN.
 END PROGRAM TEST-CONFIG-BAD-VALUE.
 COPY SVTEST.
