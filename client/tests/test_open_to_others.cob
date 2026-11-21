*> Implementation test of client/src/screens/open-to-others.cob and the opening rule of
*> client/src/sp-host.cob (US17-1, US17-3; core-host-api §2 CORE-OPEN-TO-OTHERS; shim-abi §3
*> cc_net_listen, cc_net_local_addresses; 08 §10.8.6 open_to_others texts): the pause menu of a
*> hosted world offers Open to Others; its screen takes the guest game mode and the guest-operator
*> choice, Open the World calls CORE-OPEN-TO-OTHERS (host kind 2), listens with cc_net_listen(0)
*> and shows "<address>:<port>" for each address of cc_net_local_addresses; afterwards the pause
*> menu no longer stops ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPEN-TO-OTHERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-open-others".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-FOLDER              PIC X(80) VALUE "Shared".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-NAME                PIC X(64) VALUE "Shared".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-ADDR-EXPECTED       PIC X(1024).
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-ADDRS               PIC X(128).
 01 WS-ADDRS-CAP           BINARY-LONG VALUE 128.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-PORT-EDIT           PIC Z(4)9.
 01 WS-HOST                PIC X(16) VALUE Z"127.0.0.1".
 01 WS-GUEST               BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED

*>   The pause menu of a hosted world offers Open to Others.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "open to others the pause menu of a hosted world offers Open to Others" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Game Menu|Back to the World|Options|Open to Others|Save and Leave the World" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Its screen: the guest game mode (survival first), the guest-operator choice (No first), Open
*>   the World and Cancel; the game stays paused while it is open and the world is not opened.
     MOVE ACT-OPEN-TO-OTHERS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-TICKS TO WS-TICKS
     PERFORM 10 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "open to others the screen shows the guest mode, the guest-operator choice, Open the "
         & "World and Cancel; still paused" TO TL-CASE
     MOVE "found 1 screen 16 ticks 0 Open to Others|Guest game mode: Survival|Guests may use "
         & "operator commands: No|Open the World|Cancel" TO TL-EXPECTED
     MOVE WS-FOUND TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     COMPUTE WS-E3 = SP-TICKS - WS-TICKS
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) " ticks "
         FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-GUEST-MODE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-GUEST-OPERATOR TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "open to others a click switches the guest mode to creative and the guest-operator "
         & "choice to Yes" TO TL-CASE
     MOVE "Open to Others|Guest game mode: Creative|Guests may use operator commands: Yes|Open "
         & "the World|Cancel" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Cancel returns to the pause menu; Escape too; opening the screen again starts from the first
*>   choices.
     MOVE ACT-PAUSE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SM-SCREEN TO WS-E1
     MOVE ACT-OPEN-TO-OTHERS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE SM-SCREEN TO WS-E2
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "open to others Cancel and Escape return to the pause menu; the screen opens again with "
         & "survival and No" TO TL-CASE
     MOVE "cancel 9 escape 9 Open to Others|Guest game mode: Survival|Guests may use operator "
         & "commands: No|Open the World|Cancel" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "cancel " FUNCTION TRIM(WS-E1) " escape " FUNCTION TRIM(WS-E2) " "
         FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Open the World (creative guests, operators): CORE-OPEN-TO-OTHERS, a listener on a
*>   system-chosen port, the addresses others can join at.
     MOVE ACT-GUEST-MODE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-GUEST-OPERATOR TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-OPEN-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE "acceptance US17-1 given a single-player world when the Player opens it to others from "
         & "the pause menu then the chosen guest mode and operator choice are applied (host kind "
         & "2) and a listener runs on a system-chosen port" TO TL-CASE
     MOVE "found 1 kind 2 guest mode 1 operator 1 listening 1 port 1" TO TL-EXPECTED
     MOVE WS-FOUND TO WS-E1
     MOVE 0 TO WS-E2 WS-E3
     IF SP-LISTENER > 0
         MOVE 1 TO WS-E2
     END-IF
     IF SP-PORT > 0
         MOVE 1 TO WS-E3
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " kind " CS-HOST-KIND " guest mode " CS-GUEST-MODE
         " operator " CS-GUEST-OPERATOR " listening " FUNCTION TRIM(WS-E2) " port "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The expected address lines, from cc_net_local_addresses itself.
     MOVE LOW-VALUES TO WS-ADDRS
     CALL STATIC "cc_net_local_addresses" USING BY REFERENCE WS-ADDRS BY VALUE WS-ADDRS-CAP
         RETURNING WS-COUNT
     MOVE SP-PORT TO WS-PORT-EDIT
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     STRING "Open to Others|" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
     MOVE 1 TO WS-FROM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         IF WS-ADDRS(WS-I:1) = X"0A"
             COMPUTE WS-LEN = WS-I - WS-FROM
             STRING "Others can join at " WS-ADDRS(WS-FROM:WS-LEN) ":"
                 FUNCTION TRIM(WS-PORT-EDIT) "|" DELIMITED BY SIZE INTO TL-EXPECTED
                 WITH POINTER WS-PTR
             COMPUTE WS-FROM = WS-I + 1
         END-IF
     END-PERFORM
     STRING "Back to the World" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US17-1 the game shows the address others can join at: <address>:<port> for "
         & "each local address" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE TL-EXPECTED TO WS-ADDR-EXPECTED

*>   The listener takes connections: one from the loopback address becomes a guest connection.
     CALL STATIC "cc_net_connect" USING BY REFERENCE WS-HOST BY VALUE SP-PORT
         BY REFERENCE WS-GUEST RETURNING WS-RC
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50 OR GH-HANDLE(1) > 0
         CALL "TEST-SLEEP"
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     MOVE "open to others the listener accepts a connection to <port>" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GH-HANDLE(1) > 0 AND GH-CORE-ID(1) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-GUEST

*>   Back to the World, then the pause menu: it no longer stops ticks (US17-3).
     MOVE ACT-RESUME TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SM-SCREEN TO WS-E1
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE SP-TICKS TO WS-TICKS
     PERFORM 10 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     MOVE "acceptance US17-3 given a world opened to others when the host opens the pause menu "
         & "then the game does not pause: 4 ticks in 200 ms" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "resume 5 screen 9 paused 0 ticks 4" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-PAUSED TO WS-E3
     COMPUTE WS-E4 = SP-TICKS - WS-TICKS
     MOVE SPACES TO TL-OBSERVED
     STRING "resume " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) " paused "
         FUNCTION TRIM(WS-E3) " ticks " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The open-to-others screen of an opened world shows the addresses again (not the choices), and
*>   does not stop ticks either.
     MOVE ACT-OPEN-TO-OTHERS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-TICKS TO WS-TICKS
     PERFORM 10 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "open to others reopened after opening the screen shows the addresses and ticks go on"
         TO TL-CASE
     COMPUTE WS-E1 = SP-TICKS - WS-TICKS
     MOVE SPACES TO TL-EXPECTED
     STRING "ticks 4 " WS-ADDR-EXPECTED(1:1000) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "ticks " FUNCTION TRIM(WS-E1) " " WS-TEXT(1:1000) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Quitting closes the listener.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE ACT-QUIT-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE "open to others quitting the world closes the listener" TO TL-CASE
     MOVE "found 1 active 0 listener 0 screen 1" TO TL-EXPECTED
     MOVE WS-FOUND TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE SP-LISTENER TO WS-E3
     MOVE SM-SCREEN TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " active " FUNCTION TRIM(WS-E2) " listener "
         FUNCTION TRIM(WS-E3) " screen " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OPEN-TO-OTHERS.
 COPY CLTEST.
