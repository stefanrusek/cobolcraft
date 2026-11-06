*> Implementation test of client/src/protocol-client.cob disconnect handling (CLIENT-DISCONNECT;
*> 02 Login Disconnect, 03 and 05a Disconnect; 08 §10.8.4; 09 §1 message rule): a login Disconnect
*> (JSON text) and a play Disconnect (NBT text), and a configuration one, each close the
*> connection, return to the server list and show the message rendered from its translate key
*> through the en_us lang (with its arguments); the server list keeps showing that last disconnect
*> message.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DISCONNECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-SERVER              BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-I                   BINARY-LONG.
 01 WS-SHOWN               PIC X(256).
 01 WS-CASES.
    05 FILLER PIC X(16) VALUE "login".
    05 FILLER PIC X(64) VALUE "login-s2c-00-login-disconnect-banned".
    05 FILLER PIC X(64) VALUE "You are barred from this world".
    05 FILLER PIC X(16) VALUE "configuration".
    05 FILLER PIC X(64) VALUE "config-s2c-02-disconnect-pack-required".
    05 FILLER PIC X(64) VALUE "This server requires its resource pack".
    05 FILLER PIC X(16) VALUE "play".
    05 FILLER PIC X(64) VALUE "play-s2c-20-disconnect-stopping".
    05 FILLER PIC X(64) VALUE "The server is shutting down".
    05 FILLER PIC X(16) VALUE "login".
    05 FILLER PIC X(64) VALUE "login-s2c-00-login-disconnect-name-in-use".
    05 FILLER PIC X(64) VALUE "The name Alice belongs to the host of this world".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 4 TIMES.
       10 WS-C-PHASE       PIC X(16).
       10 WS-C-FIXTURE     PIC X(64).
       10 WS-C-MESSAGE     PIC X(64).
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
         CALL "TEST-LOOPBACK" USING CLIENT-STATE WS-CONN WS-SERVER
         MOVE SCR-CONNECTING TO SM-SCREEN
         EVALUATE WS-I
             WHEN 1
             WHEN 4
                 MOVE PH-LOGIN TO CN-PHASE(WS-CONN)
             WHEN 2
                 MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
             WHEN 3
                 MOVE PH-PLAY TO CN-PHASE(WS-CONN)
                 MOVE SCR-WORLD TO SM-SCREEN
         END-EVALUATE
         MOVE SPACES TO WS-PATH
         STRING "contract/fixtures/wire/" FUNCTION TRIM(WS-C-FIXTURE(WS-I)) ".hex"
             DELIMITED BY SIZE INTO WS-PATH
         CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
         CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
         CALL STATIC "cc_net_close" USING BY VALUE WS-SERVER
         MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
         STRING "disconnect a " FUNCTION TRIM(WS-C-PHASE(WS-I)) " Disconnect ("
             FUNCTION TRIM(WS-C-FIXTURE(WS-I)) ") closes the connection and shows the server "
             "list with its text" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         STRING "closed 0 2 " FUNCTION TRIM(WS-C-MESSAGE(WS-I)) DELIMITED BY SIZE
             INTO TL-EXPECTED
         STRING FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
         IF CN-PHASE(WS-CONN) = PH-NONE AND CN-HANDLE(WS-CONN) = 0
             STRING FUNCTION TRIM(TL-OBSERVED) " 0" DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
         IF SM-SCREEN = SCR-SERVER-LIST
             STRING FUNCTION TRIM(TL-OBSERVED) " 2" DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
         STRING FUNCTION TRIM(TL-OBSERVED) " " SM-MESSAGE(1:SM-MESSAGE-LENGTH)
             DELIMITED BY SIZE INTO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE "missing" TO WS-SHOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-TEXT(WS-I) = "Disconnected: The name Alice belongs to the host of this world"
             MOVE "shown" TO WS-SHOWN
         END-IF
     END-PERFORM
     MOVE "disconnect the server list shows the last disconnect message (server_list.disconnected)"
         TO TL-CASE
     MOVE "shown" TO TL-EXPECTED
     MOVE WS-SHOWN TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DISCONNECT.
 COPY CLTEST.
