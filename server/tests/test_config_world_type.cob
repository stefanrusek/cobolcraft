*> Test of the world-type key (server/src/config-file.cob; docs/design/world-types.md section 3.1, WT-2, WT-20): the
*> default is auto (also written to a new configuration file), standard and cobolcraft are accepted, any other value
*> (the match is exact and case-sensitive) is fatal with "world-type: must be auto, standard or cobolcraft (got
*> '<value>')" and exit status 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIG-WORLD-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-config-wtype".
 01 WS-CONF                PIC X(4096).
 01 WS-PORT                BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 01 WS-STDERR              PIC X(4096).
 01 WS-LINES               PIC X(4096).
 01 WS-I                   BINARY-LONG.
 01 WS-CONF-PATH           PIC X(256) VALUE "cobolcraft-server.conf".
 01 WS-VALUES.
    05 FILLER PIC X(12) VALUE "auto".
    05 FILLER PIC X(12) VALUE "standard".
    05 FILLER PIC X(12) VALUE "cobolcraft".
 01 WS-VALUE-TABLE REDEFINES WS-VALUES.
    05 WS-VALUE            PIC X(12) OCCURS 3 TIMES.
 01 WS-BADS.
    05 FILLER PIC X(12) VALUE "Standard".
    05 FILLER PIC X(12) VALUE "debug".
    05 FILLER PIC X(12) VALUE "x".
 01 WS-BAD-TABLE REDEFINES WS-BADS.
    05 WS-BAD              PIC X(12) OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
*>   No file: the defaults are written, with world-type=auto, and the setting is auto.
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     MOVE "test config world-type missing key defaults to auto" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "auto" TO TL-EXPECTED
     MOVE CS-WORLD-TYPE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SVT-READ-LINES" USING WS-CONF-PATH WS-LINES
     MOVE "test config the written default file holds world-type=auto" TO TL-CASE
     MOVE 0 TO WS-I
     INSPECT WS-LINES TALLYING WS-I FOR ALL " | world-type=auto | "
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE SPACES TO WS-CONF
         STRING "world-type=" FUNCTION TRIM(WS-VALUE(WS-I)) DELIMITED BY SIZE INTO WS-CONF
         CALL "SVT-WRITE-CONF" USING WS-CONF
         CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
         MOVE SPACES TO TL-CASE
         STRING "test config world-type " FUNCTION TRIM(WS-VALUE(WS-I)) " is accepted"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-VALUE(WS-I) TO TL-EXPECTED
         MOVE CS-WORLD-TYPE TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE SPACES TO WS-CONF
         STRING "world-type=" FUNCTION TRIM(WS-BAD(WS-I)) DELIMITED BY SIZE INTO WS-CONF
         CALL "SVT-WRITE-CONF" USING WS-CONF
         CALL "SVT-FORK" USING WS-PID
         IF WS-PID = 0
             CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
             STOP RUN
         END-IF
         CALL "SVT-WAIT" USING WS-PID WS-EXIT WS-STDERR
         MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
         STRING "test config world-type " FUNCTION TRIM(WS-BAD(WS-I)) " is fatal"
             DELIMITED BY SIZE INTO TL-CASE
         STRING "exit 1 FATAL configuration: world-type: must be auto, standard or cobolcraft (got '"
             FUNCTION TRIM(WS-BAD(WS-I)) "')" DELIMITED BY SIZE INTO TL-EXPECTED
         IF WS-EXIT = 1
             STRING "exit 1 " FUNCTION TRIM(WS-STDERR) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "SVT-HOME"
     STOP RUN.
 END PROGRAM TEST-CONFIG-WORLD-TYPE.
 COPY SVTEST.
