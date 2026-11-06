*> Convergence acceptance test of US15-2 (spec.md US15; operator-surface §3, §4; standin §16 row 29,
*> §17 cobolcraft.disconnect.shutdown): the server program runs on loopback in process with two
*> Players in play; the operator types the shutdown command at the console. The world is saved
*> (level.dat in ./world), the server stops, and both clients return to the server list showing
*> "Disconnected: The server is shutting down".
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-STOP.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT LEVEL-FILE ASSIGN TO WS-LEVEL
         ORGANIZATION SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD LEVEL-FILE.
 01 LEVEL-RECORD           PIC X.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us15-stop".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 20.
 01 WS-CONF                PIC X(1024) VALUE "view-distance=2|hostile-mobs=false".
 01 WS-LEVEL               PIC X(64) VALUE "build/conv-us15-stop/server/world/level.dat".
 01 WS-STATUS              PIC XX.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-J1                  BINARY-LONG.
 01 WS-J2                  BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-SERVER-LIST.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-M1                  BINARY-LONG.
 01 WS-M2                  BINARY-LONG.
 01 WS-SAVED               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E                   PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     CALL "CV-JOIN" USING CONVH WS-ALICE CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-J1
     CALL "CV-JOIN" USING CONVH WS-BOBBY CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-J2

*>   The shutdown command at the console (CV-SERVER-STOP), then the clients take in their Disconnect.
     CALL "CV-SERVER-STOP" USING CONVH
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     CALL "CV-UNTIL-SCREEN" USING CONVH WS-ALICE WS-SCREEN WS-R1
     CALL "CV-UNTIL-SCREEN" USING CONVH WS-BOBBY WS-SCREEN WS-R2
     CALL "CV-STEP" USING CONVH
     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXT
     MOVE 0 TO WS-M1 WS-M2
     INSPECT WS-TEXT TALLYING WS-M1 FOR ALL "Disconnected: The server is shutting down"
     CALL "CV-TEXTS" USING CONVH WS-BOBBY WS-TEXT
     INSPECT WS-TEXT TALLYING WS-M2 FOR ALL "Disconnected: The server is shutting down"
     MOVE 0 TO WS-SAVED
     OPEN INPUT LEVEL-FILE
     IF WS-STATUS = "00"
         MOVE 1 TO WS-SAVED
         CLOSE LEVEL-FILE
     END-IF

     MOVE "acceptance US15-2 given Players in the world when the operator runs the stop command "
         & "then the server saves the world, stops, and the Players return to the server list with "
         & "the stopping message" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "joined 1 1 stopped 2 saved 1 Alice list 1 message 1 Bobby list 1 message 1"
         TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-J1 TO WS-E
     STRING "joined " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-J2 TO WS-E
     STRING " " FUNCTION TRIM(WS-E) " stopped " CST-RUN-STATE DELIMITED BY SIZE
         INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-SAVED TO WS-E
     STRING " saved " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-R1 TO WS-E
     STRING " Alice list " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE WS-M1 TO WS-E
     STRING " message " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE WS-R2 TO WS-E
     STRING " Bobby list " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE WS-M2 TO WS-E
     STRING " message " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-STOP.
