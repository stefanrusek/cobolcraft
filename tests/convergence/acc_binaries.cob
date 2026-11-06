*> Convergence acceptance test of US1-1 (spec.md US1; contracts/test-harness.md §2; plan 4.2): the
*> built programs run. The instrumented build/.../convergence/bin/cobolcraft-server (the server's
*> src/main.cob, a single CALL of SV-MAIN, + libserver.a) started in a scratch directory with the
*> shutdown command on its standard input prints its ready line (operator-surface §3) and exits 0;
*> build/.../convergence/bin/cobolcraft (the client's src/main.cob + libclient.a) without --name
*> prints "FATAL arguments: --name <name> is required" (client-surface §1) and exits 1. So the one
*> line of each main.cob runs under coverage. The build root comes from COBOLCRAFT_BUILD
*> (tools/runtests.py), "build" when unset.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BINARIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-BUILD               PIC X(512).
 01 WS-PORT                BINARY-LONG.
 01 WS-EDIT                PIC Z(5)9.
 01 WS-COMMAND             PIC X(2048).
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(4096).
 01 WS-STATUS              PIC X(4096).
 01 WS-LINE                PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-BUILD
     ACCEPT WS-BUILD FROM ENVIRONMENT "COBOLCRAFT_BUILD"
     IF WS-BUILD = SPACES
         MOVE "build" TO WS-BUILD
     END-IF
     CALL "CV-FREE-PORT" USING WS-PORT
     MOVE WS-PORT TO WS-EDIT

*>   The server program: a fresh scratch directory holding only a configuration with a free port.
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "rm -rf build/conv-binaries && mkdir -p build/conv-binaries && cd build/conv-binaries"
         " && printf 'port=" FUNCTION TRIM(WS-EDIT) "\nview-distance=2\n' > cobolcraft-server.conf"
         " && printf 'shutdown\n' > stdin.txt && '" FUNCTION TRIM(WS-BUILD)
         "/convergence/bin/cobolcraft-server' < stdin.txt > out.txt 2> err.txt;"
         " echo $? > status.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND

     MOVE "build/conv-binaries/out.txt" TO WS-PATH
     CALL "BIN-READ-LINES" USING WS-PATH WS-TEXT
     MOVE "build/conv-binaries/status.txt" TO WS-PATH
     CALL "BIN-READ-LINES" USING WS-PATH WS-STATUS
     MOVE SPACES TO WS-LINE
     STRING "Ready: accepting players on 0.0.0.0:" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-LINE
     MOVE 0 TO WS-FOUND
     INSPECT WS-TEXT TALLYING WS-FOUND FOR ALL WS-LINE(1:FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)))
     MOVE "acceptance US1-1 given a built checkout when the built server program runs then it "
         & "prints its ready line and, told to shut down on its console, exits 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ready 1 status 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-FOUND = 1 AND WS-STATUS = "0"
         MOVE "ready 1 status 0" TO TL-OBSERVED
     ELSE
         STRING "status " FUNCTION TRIM(WS-STATUS) " output " FUNCTION TRIM(WS-TEXT)
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The client program without --name.
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "cd build/conv-binaries && '" FUNCTION TRIM(WS-BUILD)
         "/convergence/bin/cobolcraft' < /dev/null > client-out.txt 2>&1;"
         " echo $? > client-status.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/conv-binaries/client-out.txt" TO WS-PATH
     CALL "BIN-READ-LINES" USING WS-PATH WS-TEXT
     MOVE "build/conv-binaries/client-status.txt" TO WS-PATH
     CALL "BIN-READ-LINES" USING WS-PATH WS-STATUS
     MOVE "acceptance US1-1 given a built checkout when the built client program runs without "
         & "--name then it prints its FATAL arguments line and exits 1" TO TL-CASE
     MOVE "status 1 output FATAL arguments: --name <name> is required" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "status " FUNCTION TRIM(WS-STATUS) " output " FUNCTION TRIM(WS-TEXT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BINARIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIN-READ-LINES.
*> USING path (PIC X(256)), text out (PIC X(4096)): the file's lines joined by " | " (spaces when
*> the file cannot be opened).
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT IN-FILE ASSIGN TO WS-PATH
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD IN-FILE.
 01 IN-LINE                PIC X(1024).
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(256).
 01 WS-STATUS              PIC XX.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-PATH L-TEXT.
     MOVE L-PATH TO WS-PATH
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     OPEN INPUT IN-FILE
     IF WS-STATUS = "00"
         PERFORM UNTIL WS-STATUS NOT = "00"
             READ IN-FILE
                 AT END MOVE "10" TO WS-STATUS
                 NOT AT END
                     IF WS-PTR > 1
                         STRING " | " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
                     END-IF
                     STRING FUNCTION TRIM(IN-LINE TRAILING) DELIMITED BY SIZE
                         INTO L-TEXT WITH POINTER WS-PTR
             END-READ
         END-PERFORM
         CLOSE IN-FILE
     END-IF
     GOBACK.
 END PROGRAM BIN-READ-LINES.
