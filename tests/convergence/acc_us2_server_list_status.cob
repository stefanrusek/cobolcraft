*> Convergence acceptance test of US2-2 and the US2 protocol edge case (spec.md US2; 09 §2 status
*> JSON; 08 §10.8.6 server_list texts): the server program runs on loopback in process with the
*> description "Convergence world" and one Player (Bobby) in play; Alice's server list asks it for its
*> status over the client's status connection and shows the description and "1 of 20 online". A
*> second entry points at a loopback peer that answers the status exchange as a server of another
*> protocol version (999) would; the list marks that entry incompatible with its version name.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US2-SERVER-LIST-STATUS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us2-server-list-status".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 33.
 01 WS-CONF                PIC X(1024)
     VALUE "view-distance=2|hostile-mobs=false|description=Convergence world".
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-SERVER-LIST.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LISTENER            BINARY-LONG.
 01 WS-OTHER-PORT          BINARY-LONG.
 01 WS-PEER                BINARY-LONG VALUE 0.
 01 WS-ANSWERED            BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-SENT                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-AREA                PIC X(4096).
 01 WS-JSON                PIC X(120) VALUE
     '{"version":{"name":"Other 2.0","protocol":999},"players":{"max":5,"online":0},'
     & '"description":"elsewhere"}'.
 01 WS-JSON-LENGTH         BINARY-LONG.
 01 WS-REPLY               PIC X(160).
 01 WS-REPLY-LENGTH        BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC Z(5)9.
 01 WS-TEXT                PIC X(1024).
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     CALL "CV-JOIN" USING CONVH WS-BOBBY CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED

*>   The peer of another protocol version: Status Response (id 0, the JSON) then Pong (id 1).
     CALL STATIC "cc_net_listen" USING BY VALUE WS-ZERO BY REFERENCE WS-LISTENER
         BY REFERENCE WS-OTHER-PORT RETURNING WS-RC
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-JSON-LENGTH
     MOVE LOW-VALUES TO WS-REPLY
     MOVE FUNCTION CHAR(WS-JSON-LENGTH + 3) TO WS-REPLY(1:1)
     MOVE FUNCTION CHAR(1) TO WS-REPLY(2:1)
     MOVE FUNCTION CHAR(WS-JSON-LENGTH + 1) TO WS-REPLY(3:1)
     MOVE WS-JSON(1:WS-JSON-LENGTH) TO WS-REPLY(4:WS-JSON-LENGTH)
     COMPUTE WS-I = WS-JSON-LENGTH + 4
     MOVE FUNCTION CHAR(10) TO WS-REPLY(WS-I:1)
     MOVE FUNCTION CHAR(2) TO WS-REPLY(WS-I + 1:1)
     COMPUTE WS-REPLY-LENGTH = WS-I + 9

*>   Alice's server list: the running server first, the other server second.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 2 TO SL-COUNT
     INITIALIZE SL-ENTRY(1) SL-ENTRY(2)
     MOVE "Convergence" TO SL-NAME(1)
     MOVE 11 TO SL-NAME-LENGTH(1)
     MOVE CV-PORT TO WS-EDIT
     STRING "127.0.0.1:" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO SL-ADDR(1)
     COMPUTE SL-ADDR-LENGTH(1) = 10 + FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
     MOVE "Other" TO SL-NAME(2)
     MOVE 5 TO SL-NAME-LENGTH(2)
     MOVE WS-OTHER-PORT TO WS-EDIT
     STRING "127.0.0.1:" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO SL-ADDR(2)
     COMPUTE SL-ADDR-LENGTH(2) = 10 + FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
             OR (SL-STATUS(1) = SLS-ANSWERED AND SL-STATUS(2) = SLS-ANSWERED)
         CALL "CV-STEP" USING CONVH
         IF WS-PEER = 0
             CALL STATIC "cc_net_accept" USING BY VALUE WS-LISTENER BY REFERENCE WS-PEER
                 RETURNING WS-RC
             IF WS-RC NOT = 0
                 MOVE 0 TO WS-PEER
             END-IF
         END-IF
         IF WS-PEER > 0 AND WS-ANSWERED = 0
             CALL STATIC "cc_net_recv" USING BY VALUE WS-PEER BY REFERENCE WS-AREA
                 BY VALUE WS-CAPACITY BY REFERENCE WS-GOT RETURNING WS-RC
             IF WS-RC = 0 AND WS-GOT > 0
                 CALL STATIC "cc_net_send" USING BY VALUE WS-PEER BY REFERENCE WS-REPLY
                     BY VALUE WS-REPLY-LENGTH BY REFERENCE WS-SENT RETURNING WS-RC
                 MOVE 1 TO WS-ANSWERED
             END-IF
         END-IF
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     END-PERFORM
     CALL "CV-STEP" USING CONVH
     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXT

     MOVE "acceptance US2-2 given a running CobolCraft server in the server list when the Player "
         & "views the list then the entry shows the server's description and players online"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Convergence|Convergence world|1 of 20 online" TO TL-EXPECTED
     MOVE 0 TO WS-FOUND
     INSPECT WS-TEXT TALLYING WS-FOUND FOR ALL "Convergence|Convergence world|1 of 20 online"
     MOVE WS-TEXT TO TL-OBSERVED
     IF WS-FOUND = 1
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US2 edge given a server of another protocol version in the server list when "
         & "the Player views the list then its entry is shown as incompatible" TO TL-CASE
     MOVE "Other|elsewhere|Incompatible version: Other 2.0" TO TL-EXPECTED
     MOVE 0 TO WS-FOUND
     INSPECT WS-TEXT TALLYING WS-FOUND FOR ALL "Other|elsewhere|Incompatible version: Other 2.0"
     MOVE WS-TEXT TO TL-OBSERVED
     IF WS-FOUND = 1
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     IF WS-PEER > 0
         CALL STATIC "cc_net_close" USING BY VALUE WS-PEER
     END-IF
     CALL STATIC "cc_net_close" USING BY VALUE WS-LISTENER
     CALL "CV-SERVER-STOP" USING CONVH
     STOP RUN.
 END PROGRAM ACC-US2-SERVER-LIST-STATUS.
