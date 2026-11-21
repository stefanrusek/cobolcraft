*> Test helpers of the extract package (test infrastructure, excluded from coverage). COPY after the END PROGRAM of
*> a test program.
*>   EXT-INPUT-PATH   file name (PIC X(64)), path out (PIC X(1100)): the operator's input folder is the
*>                    environment variable COBOLCRAFT_INPUTS, or tmp when it is not set.
*>   EXT-SCRATCH      name (PIC X(64)), path out (PIC X(1100)): <COBOLCRAFT_BUILD or build>/extract-test/<name>.
*>   EXT-SHELL        command (PIC X(1100)): runs it through the shell, returns its exit status in the second
*>                    parameter (BINARY-LONG).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXT-INPUT-PATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRECTORY           PIC X(1000).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(64).
 01 L-PATH                 PIC X(1100).
 PROCEDURE DIVISION USING L-NAME L-PATH.
     MOVE SPACES TO WS-DIRECTORY L-PATH
     ACCEPT WS-DIRECTORY FROM ENVIRONMENT "COBOLCRAFT_INPUTS"
     IF WS-DIRECTORY = SPACES
         MOVE "tmp" TO WS-DIRECTORY
     END-IF
     STRING FUNCTION TRIM(WS-DIRECTORY) "/" FUNCTION TRIM(L-NAME) DELIMITED BY SIZE INTO L-PATH
     GOBACK.
 END PROGRAM EXT-INPUT-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXT-SCRATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRECTORY           PIC X(1000).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(64).
 01 L-PATH                 PIC X(1100).
 PROCEDURE DIVISION USING L-NAME L-PATH.
     MOVE SPACES TO WS-DIRECTORY L-PATH
     ACCEPT WS-DIRECTORY FROM ENVIRONMENT "COBOLCRAFT_BUILD"
     IF WS-DIRECTORY = SPACES
         MOVE "build" TO WS-DIRECTORY
     END-IF
     STRING FUNCTION TRIM(WS-DIRECTORY) "/extract-test/" FUNCTION TRIM(L-NAME) DELIMITED BY SIZE INTO L-PATH
     GOBACK.
 END PROGRAM EXT-SCRATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXT-SHELL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COMMAND              PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-COMMAND L-STATUS.
     CALL "SYSTEM" USING FUNCTION TRIM(L-COMMAND)
     COMPUTE L-STATUS = RETURN-CODE / 256
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM EXT-SHELL.

*>   EXT-RUN          arguments (PIC X(4000), separated by "|"), exit status out (BINARY-LONG): EX-RUN with the
*>                    arguments of one command line.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXT-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-LINE                 PIC X(4000).
 01 L-EXIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LINE L-EXIT.
     INSPECT L-LINE REPLACING ALL "|" BY X"0A"
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-LINE TRAILING)) TO WS-LENGTH
     IF L-LINE = SPACES
         MOVE 0 TO WS-LENGTH
     END-IF
     CALL "EX-RUN" USING L-LINE WS-LENGTH L-EXIT
     GOBACK.
 END PROGRAM EXT-RUN.

*>   EXT-OUTPUT       name (PIC X(64)), generated directory out (PIC X(1100)), exit status out (BINARY-LONG): the tool's
*>                    output for the operator's real jar below the scratch folder <name>: the run is idempotent, so the
*>                    first test that needs it builds it and the others find it up to date.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXT-OUTPUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INPUT               PIC X(64) VALUE "minecraft-26.3-client.jar".
 01 WS-JAR                 PIC X(1100).
 01 WS-ROOT                PIC X(1100).
 01 WS-LINE                PIC X(4000).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(64).
 01 L-GEN                  PIC X(1100).
 01 L-EXIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-GEN L-EXIT.
     CALL "EXT-INPUT-PATH" USING WS-INPUT WS-JAR
     CALL "EXT-SCRATCH" USING L-NAME WS-ROOT
     MOVE SPACES TO L-GEN WS-LINE
     STRING FUNCTION TRIM(WS-ROOT) "/generated" DELIMITED BY SIZE INTO L-GEN
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(L-GEN) "|--quiet" DELIMITED BY SIZE
         INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE L-EXIT
     GOBACK.
 END PROGRAM EXT-OUTPUT.

*>   EXT-COUNT        command (PIC X(1100): a shell pipeline that prints one number), number out (BINARY-DOUBLE; -1
*>                    when it printed nothing): runs it into a scratch file and reads the file back.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXT-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(64) VALUE "count.txt".
 01 WS-FILE                PIC X(1100).
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-COMMAND              PIC X(1100).
 01 L-NUMBER               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-COMMAND L-NUMBER.
     CALL "EXT-SCRATCH" USING WS-NAME WS-FILE
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p $(dirname " FUNCTION TRIM(WS-FILE) ") && ( " FUNCTION TRIM(L-COMMAND) " ) > "
         FUNCTION TRIM(WS-FILE) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE SPACES TO WS-TEXT
     MOVE 63 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-FILE WS-OFFSET WS-TEXT WS-LENGTH WS-STATUS
     MOVE -1 TO L-NUMBER
     IF WS-LENGTH > 0
         COMPUTE L-NUMBER = FUNCTION NUMVAL(WS-TEXT)
     END-IF
     GOBACK.
 END PROGRAM EXT-COUNT.
