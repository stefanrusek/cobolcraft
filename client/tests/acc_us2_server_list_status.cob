*> Acceptance test of US2-2 on the client (02 Status; 09 §2; 08 §10.8.6 server_list texts): a
*> server-list entry is asked for its status over a real loopback connection while the server list
*> is shown; the Status Response (status-s2c-00-status-response.hex) puts its description and its
*> online count in the screen model; a Status Response with a protocol other than 777 marks the
*> entry incompatible (US2 edge case).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US2-SERVER-LIST-STATUS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-WAIT                BINARY-LONG VALUE 20.
 01 WS-LISTENER            BINARY-LONG.
 01 WS-SERVER              BINARY-LONG.
 01 WS-PORT                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HANDLES.
    05 WS-HANDLE           BINARY-LONG.
 01 WS-READY               PIC X(2).
 01 WS-EDIT                PIC Z(5)9.
 01 WS-PATH                PIC X(256).
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-TEXTS               PIC X(1024).
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-JSON                PIC X(200).
 01 WS-JSON-LENGTH         BINARY-LONG.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-FRAME-BUFFER.
    05 FR-ADDR             USAGE POINTER.
    05 FR-CAPACITY         BINARY-LONG.
    05 FR-LENGTH           BINARY-LONG.
    05 FR-POS              BINARY-LONG.
    05 FR-ERROR            PIC 9.
 01 B-FRAME                PIC X(512) BASED.
 01 WS-COUNT               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-us2-status"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-us2-status" TO CL-GAME-DIR
     MOVE 28 TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     CALL STATIC "cc_net_listen" USING BY VALUE WS-ZERO BY REFERENCE WS-LISTENER
         BY REFERENCE WS-PORT RETURNING WS-RC
     MOVE WS-PORT TO WS-EDIT
     MOVE 2 TO SL-COUNT
     MOVE "Local" TO SL-NAME(1) SL-NAME(2)
     MOVE 5 TO SL-NAME-LENGTH(1) SL-NAME-LENGTH(2)
     MOVE SPACES TO SL-ADDR(1)
     STRING "127.0.0.1:" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO SL-ADDR(1)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(SL-ADDR(1))) TO SL-ADDR-LENGTH(1)
     MOVE SL-ADDR(1) TO SL-ADDR(2)
     MOVE SL-ADDR-LENGTH(1) TO SL-ADDR-LENGTH(2)
     MOVE SCR-SERVER-LIST TO WS-I
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-I

*>   Entry 1: the fixture Status Response.
     PERFORM SERVE-ONE
     MOVE "contract/fixtures/wire/status-s2c-00-status-response.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-SERVER WS-PATH WS-THRESHOLD
     PERFORM STEP-UNTIL-ANSWERED
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXTS
     MOVE "acceptance US2-2 given a running server in the server list when the Player views the "
         & "list then the entry shows its description and how many players are online" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "description and count shown" TO TL-EXPECTED
     MOVE WS-TEXTS TO TL-OBSERVED
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXTS TALLYING WS-COUNT FOR ALL "|A CobolCraft server|0 of 20 online|"
     IF WS-COUNT = 1
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Entry 2: a Status Response of protocol 700.
     PERFORM SERVE-ONE
     MOVE '{"version":{"name":"Elder","protocol":700},"players":{"max":5,"online":1},'
         & '"description":{"text":"Old server"}}' TO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-JSON-LENGTH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-JSON WS-JSON-LENGTH WS-MAX
     CALL "PB-INIT" USING WS-FRAME-BUFFER WS-CAPACITY
     CALL "PB-FRAME-ENCODE" USING WS-FRAME-BUFFER PB-BUFFER WS-THRESHOLD
     SET ADDRESS OF B-FRAME TO FR-ADDR
     CALL "TEST-SERVE-BYTES" USING WS-SERVER B-FRAME FR-LENGTH
     PERFORM STEP-UNTIL-ANSWERED
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXTS
     MOVE "acceptance US2 edge case given a server of another protocol version when the Player "
         & "views the list then its entry is marked incompatible" TO TL-CASE
     MOVE "incompatible shown" TO TL-EXPECTED
     MOVE WS-TEXTS TO TL-OBSERVED
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXTS TALLYING WS-COUNT FOR ALL "|Old server|Incompatible version: Elder"
     IF WS-COUNT = 1
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Steps until the client has connected for the next entry; accepts it; reads its requests.
 SERVE-ONE.
     MOVE WS-LISTENER TO WS-HANDLE
     MOVE LOW-VALUES TO WS-READY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-READY(1:1) = X"01" OR WS-I > 200
         CALL "TEST-STEP" USING CLIENT-STATE
         CALL STATIC "cc_net_poll" USING BY VALUE WS-WAIT BY REFERENCE WS-HANDLES
             BY VALUE WS-ONE BY VALUE WS-ZERO BY REFERENCE WS-READY RETURNING WS-RC
     END-PERFORM
     CALL STATIC "cc_net_accept" USING BY VALUE WS-LISTENER BY REFERENCE WS-SERVER
         RETURNING WS-RC
     PERFORM 5 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD.

*> Steps until the client has answered with Ping Request; serves the Pong.
 STEP-UNTIL-ANSWERED.
     PERFORM 5 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
         CALL "TEST-SLEEP"
     END-PERFORM
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "contract/fixtures/wire/status-s2c-01-pong-response.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-SERVER WS-PATH WS-THRESHOLD
     PERFORM 5 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
         CALL "TEST-SLEEP"
     END-PERFORM
     CALL STATIC "cc_net_close" USING BY VALUE WS-SERVER.
 END PROGRAM ACC-US2-SERVER-LIST-STATUS.

 COPY CLTEST.
