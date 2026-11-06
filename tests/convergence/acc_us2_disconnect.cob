*> Convergence acceptance test of US2-5 and the US2 duplicate-name edge case (spec.md US2; standin
*> §17 cobolcraft.disconnect.replaced): the server program runs on loopback in process. Alice in the
*> world opens the pause menu (Escape) and presses Disconnect: she is back on the server list and the
*> server no longer counts her online. She joins again; a second client logging in with the same name
*> takes over: the first client returns to the server list showing "Disconnected: Someone joined
*> elsewhere under your name", the second is in play, and one player is online.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US2-DISCONNECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us2-disconnect".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-CONF                PIC X(1024) VALUE "view-distance=2|hostile-mobs=false".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FIRST               BINARY-LONG.
 01 WS-SECOND              BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-JOINED2             BINARY-LONG.
 01 WS-KEY                 BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-SERVER-LIST.
 01 WS-REACHED             BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-COUNT               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-FIRST
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-SECOND
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     CALL "CV-JOIN" USING CONVH WS-FIRST CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-FIRST WS-JOINED

*>   US2-5: the pause menu's Disconnect.
     CALL "CV-KEY" USING CONVH WS-FIRST WS-KEY
     MOVE ACT-DISCONNECT TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-FIRST WS-ACTION WS-ARG WS-FOUND
     CALL "CV-STEPS" USING CONVH WS-FIVE
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-FIRST)
     MOVE "acceptance US2-5 given the Player is in the world when they press the disconnect "
         & "control then they return to the server list" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "joined 1 button 1 screen 2 connection 0 online 0" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE WS-FOUND TO WS-E2
     MOVE SM-SCREEN TO WS-E3
     MOVE CN-PHASE(CONN-GAME) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " button " FUNCTION TRIM(WS-E2) " screen "
         FUNCTION TRIM(WS-E3) " connection " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE CST-PLAYERS-ONLINE TO WS-E1
     STRING " online " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED(
         FUNCTION LENGTH(FUNCTION TRIM(TL-OBSERVED)) + 1:)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The edge case: the same name logs in again from another client.
     CALL "CV-JOIN" USING CONVH WS-FIRST CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-FIRST WS-JOINED
     CALL "CV-JOIN" USING CONVH WS-SECOND CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-SECOND WS-JOINED2
     CALL "CV-UNTIL-SCREEN" USING CONVH WS-FIRST WS-SCREEN WS-REACHED
     CALL "CV-STEP" USING CONVH
     CALL "CV-TEXTS" USING CONVH WS-FIRST WS-TEXT
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT
         FOR ALL "Disconnected: Someone joined elsewhere under your name"
     MOVE "acceptance US2 edge given a Player in the world when a second login with the same name "
         & "joins then the first Player is disconnected and sees the message" TO TL-CASE
     MOVE "first joined 1 back on the list 1 message 1 second in play 1 online 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE WS-REACHED TO WS-E2
     MOVE WS-COUNT TO WS-E3
     MOVE WS-JOINED2 TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "first joined " FUNCTION TRIM(WS-E1) " back on the list " FUNCTION TRIM(WS-E2)
         " message " FUNCTION TRIM(WS-E3) " second in play " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE CST-PLAYERS-ONLINE TO WS-E1
     STRING " online " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED(
         FUNCTION LENGTH(FUNCTION TRIM(TL-OBSERVED)) + 1:)
     IF WS-COUNT NOT = 1
         MOVE WS-TEXT TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CV-SERVER-STOP" USING CONVH
     STOP RUN.
 END PROGRAM ACC-US2-DISCONNECT.
