*> Convergence acceptance test of US18-6 to US18-8 (spec.md US18; 08 §9; operator-surface §2 pack
*> keys): the server program (in process, loopback) offers a pack that tools/testsrv/testsrv.py
*> serves over HTTP; a client joining through its server list is asked, accepts, downloads and
*> applies it above its local packs until it disconnects; rejoining with the same pack unchanged
*> applies it from the download cache without a second download (the test server's request log
*> holds one request); with the pack required, declining it disconnects the Player back to the
*> server list with the required-pack message. The pack is client/tests/fixtures/packs/server.zip
*> (written by gen_packs.py); its SHA-1 comes from shasum, independently of the client.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-SERVER-PACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us18-server-pack".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-WWW                 PIC X(256) VALUE "build/conv-us18-server-pack/www".
 01 WS-OPTIONS             PIC X(256)
     VALUE "--request-log build/conv-us18-server-pack/requests.log".
 01 WS-HTTP                BINARY-LONG.
 01 WS-HTTPS               BINARY-LONG.
 01 WS-HASH                PIC X(40).
 01 WS-CONF                PIC X(1024).
 01 WS-EDIT                PIC Z(5)9.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LINE                PIC X(256).
 01 WS-PATH                PIC X(256).
 01 WS-PTR                 BINARY-LONG.
 01 WS-REQUIRED            PIC X(5).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "SYSTEM" USING "python3 client/tests/fixtures/gen_packs.py >/dev/null && mkdir -p "
         & "build/conv-us18-server-pack/www && cp client/tests/fixtures/packs/server.zip "
         & "build/conv-us18-server-pack/www/ && shasum -a 1 build/conv-us18-server-pack/www/"
         & "server.zip | cut -c1-40 > build/conv-us18-server-pack/sha1.txt"
     MOVE "build/conv-us18-server-pack/sha1.txt" TO WS-PATH
     CALL "READ-FIRST-LINE" USING WS-PATH WS-LINE
     MOVE WS-LINE(1:40) TO WS-HASH
     CALL "TESTSRV-START" USING WS-WWW WS-OPTIONS WS-HTTP WS-HTTPS
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-ALICE
     MOVE "false" TO WS-REQUIRED
     PERFORM START-SERVER

*>   US18-6: join, the prompt, accept; the pack downloaded and applied on top.
     CALL "CV-JOIN" USING CONVH WS-ALICE CV-PORT
     MOVE SCR-PACK-PROMPT TO WS-SCREEN
     CALL "CV-UNTIL-SCREEN" USING CONVH WS-ALICE WS-SCREEN WS-REACHED
     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXT
     MOVE "acceptance US18-6 given a server configured to offer a pack when the Player joins then "
         & "they are asked whether to accept it" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL "Convergence pack"
     MOVE "prompt 1 message 1" TO TL-EXPECTED
     MOVE WS-REACHED TO WS-E1
     MOVE FUNCTION MIN(WS-COUNT, 1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "prompt " FUNCTION TRIM(WS-E1) " message " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-COUNT = 0
         STRING TL-OBSERVED(1:18) " " WS-TEXT DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-PACK-ACCEPT TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "PACK-TOP" USING CONVH WS-ALICE WS-LINE
     MOVE "acceptance US18-6 when the Player accepts then the pack is downloaded and the game is "
         & "shown with it above all local packs" TO TL-CASE
     MOVE "joined 1 top server" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " top " FUNCTION TRIM(WS-LINE)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Disconnect: the pack drops out of the stack.
     PERFORM DISCONNECT
     CALL "PACK-TOP" USING CONVH WS-ALICE WS-LINE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US18-6 when the Player disconnects then the server's pack is no longer "
         & "applied" TO TL-CASE
     MOVE "screen 2 top builtin" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " top " FUNCTION TRIM(WS-LINE)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US18-8: rejoin (the accept was stored for this server, 08 §9.1 step 4: no prompt this time);
*>   the same pack is applied from the cache, one download in all.
     MOVE ACT-JOIN TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "PACK-TOP" USING CONVH WS-ALICE WS-LINE
     CALL "SYSTEM" USING "grep -c '^GET /server.zip' build/conv-us18-server-pack/requests.log"
         & " > build/conv-us18-server-pack/count.txt"
     MOVE "build/conv-us18-server-pack/count.txt" TO WS-PATH
     CALL "READ-FIRST-LINE" USING WS-PATH WS-TEXT
     MOVE "acceptance US18-8 given the Player has downloaded the server's pack when they rejoin "
         & "and it is offered unchanged then it is applied without downloading it again" TO TL-CASE
     MOVE "joined 1 top server downloads 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " top " FUNCTION TRIM(WS-LINE) " downloads "
         FUNCTION TRIM(WS-TEXT(1:16)) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DISCONNECT
     CALL "CV-SERVER-STOP" USING CONVH

*>   US18-7: a required pack declined.
     MOVE "true" TO WS-REQUIRED
     PERFORM START-SERVER
     CALL "CV-JOIN" USING CONVH WS-ALICE CV-PORT
     MOVE SCR-PACK-PROMPT TO WS-SCREEN
     CALL "CV-UNTIL-SCREEN" USING CONVH WS-ALICE WS-SCREEN WS-REACHED
     MOVE ACT-PACK-DECLINE TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 20 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US18-7 given a server that marks its pack as required when the Player "
         & "declines it then they are disconnected with a message that the server requires its pack"
         TO TL-CASE
     MOVE "prompt 1 screen 2 This server requires its resource pack" TO TL-EXPECTED
     MOVE WS-REACHED TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "prompt " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) " "
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     IF SM-MESSAGE-LENGTH > 0
         STRING SM-MESSAGE(1:SM-MESSAGE-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CV-SERVER-STOP" USING CONVH
     CALL "TESTSRV-STOP"
     STOP RUN.

*> The server program with the pack offer (WS-REQUIRED "true" or "false").
 START-SERVER.
     MOVE WS-HTTP TO WS-EDIT
     MOVE SPACES TO WS-CONF
     STRING "view-distance=2|hostile-mobs=false|default-game-mode=survival|pack-url=http://"
         "127.0.0.1:" FUNCTION TRIM(WS-EDIT) "/server.zip|pack-sha1=" WS-HASH
         "|pack-id=00112233-4455-6677-8899-aabbccddeeff|pack-prompt=Convergence pack"
         "|pack-required=" FUNCTION TRIM(WS-REQUIRED) DELIMITED BY SIZE INTO WS-CONF
     CALL "CV-SERVER-START" USING CONVH WS-CONF.

*> Escape, then the pause menu's Disconnect; a few frames.
 DISCONNECT.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE ACT-DISCONNECT TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 5 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT.
 END PROGRAM ACC-US18-SERVER-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-TOP.
*> USING CONVH, index, text out (PIC X(256)): "server" when the top pack of the client's stack is a
*> server pack (id server/...), "builtin" when it is the built-in pack, else its id.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(256).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE SPACES TO L-TEXT
     EVALUATE TRUE
         WHEN PK-KIND(PK-COUNT) = 0
             MOVE "builtin" TO L-TEXT
         WHEN PK-SERVER(PK-COUNT) > 0 AND PK-ID(PK-COUNT)(1:7) = "server/"
             MOVE "server" TO L-TEXT
         WHEN OTHER
             MOVE PK-ID(PK-COUNT) TO L-TEXT
     END-EVALUATE
     GOBACK.
 END PROGRAM PACK-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. READ-FIRST-LINE.
*> USING path (PIC X(256)), line out (PIC X(256)): the file's first line (spaces when unreadable).
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT IN-FILE ASSIGN TO WS-PATH
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD IN-FILE.
 01 IN-LINE                PIC X(256).
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(256).
 01 WS-STATUS              PIC XX.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-LINE                 PIC X(256).
 PROCEDURE DIVISION USING L-PATH L-LINE.
     MOVE L-PATH TO WS-PATH
     MOVE SPACES TO L-LINE
     OPEN INPUT IN-FILE
     IF WS-STATUS = "00"
         READ IN-FILE
             NOT AT END
                 MOVE IN-LINE TO L-LINE
         END-READ
         CLOSE IN-FILE
     END-IF
     GOBACK.
 END PROGRAM READ-FIRST-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TESTSRV-START.
*> USING directory (PIC X(256)), options (PIC X(256)), http port out, https port out: runs
*> tools/testsrv/testsrv.py serving that directory on free 127.0.0.1 ports (the test CA created
*> when absent, SSL_CERT_FILE set to it) and waits until it listens (client/tests/CLTEST.cpy
*> TEST-TESTSRV-START, copied: test infrastructure). Ends the program (status 2) when it does not
*> start.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 TESTSRV-PID            BINARY-LONG EXTERNAL.
 01 WS-SELF                BINARY-LONG.
 01 WS-SELF-TEXT           PIC 9(9).
 01 WS-CA                  PIC X(64) VALUE Z"build/testsrv/ca.pem".
 01 WS-CA-ABS              PIC X(1024).
 01 WS-CA-PTR              USAGE POINTER.
 01 WS-READY               PIC X(256).
 01 WS-PID-FILE            PIC X(256).
 01 WS-COMMAND             PIC X(2048).
 01 WS-TEXT                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-MICROS              BINARY-LONG VALUE 50000.
 01 WS-WORDS.
    05 WS-WORD             PIC X(32) OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(256).
 01 L-OPTIONS              PIC X(256).
 01 L-HTTP                 BINARY-LONG.
 01 L-HTTPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-OPTIONS L-HTTP L-HTTPS.
     CALL "SYSTEM" USING "mkdir -p build/testsrv && (test -f build/testsrv/ca.pem"
         & " || sh tools/testsrv/make-ca.sh >/dev/null)"
     MOVE LOW-VALUES TO WS-CA-ABS
     CALL STATIC "realpath" USING BY REFERENCE WS-CA BY REFERENCE WS-CA-ABS
         RETURNING WS-CA-PTR
     MOVE 0 TO WS-LENGTH
     INSPECT WS-CA-ABS TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL LOW-VALUE
     SET ENVIRONMENT "SSL_CERT_FILE" TO WS-CA-ABS(1:WS-LENGTH)
     CALL STATIC "getpid" RETURNING WS-SELF
     MOVE WS-SELF TO WS-SELF-TEXT
     MOVE SPACES TO WS-READY WS-PID-FILE WS-COMMAND
     STRING "build/testsrv/ready-" WS-SELF-TEXT DELIMITED BY SIZE INTO WS-READY
     STRING "build/testsrv/pid-" WS-SELF-TEXT DELIMITED BY SIZE INTO WS-PID-FILE
     STRING "rm -f " FUNCTION TRIM(WS-READY) " " FUNCTION TRIM(WS-PID-FILE)
         "; python3 tools/testsrv/testsrv.py --dir " FUNCTION TRIM(L-DIR)
         " --http-port 0 --https-port 0 " FUNCTION TRIM(L-OPTIONS)
         " --ready-file " FUNCTION TRIM(WS-READY) " >/dev/null 2>&1 & echo $! > "
         FUNCTION TRIM(WS-PID-FILE) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-TRIES FROM 1 BY 1 UNTIL WS-TRIES > 200 OR WS-TEXT NOT = SPACES
         CALL STATIC "usleep" USING BY VALUE WS-MICROS
         CALL "READ-FIRST-LINE" USING WS-READY WS-TEXT
     END-PERFORM
     MOVE SPACES TO WS-WORDS
     UNSTRING WS-TEXT DELIMITED BY "=" OR " " INTO WS-WORD(1) WS-WORD(2) WS-WORD(3) WS-WORD(4)
     MOVE FUNCTION NUMVAL(WS-WORD(2)) TO L-HTTP
     MOVE FUNCTION NUMVAL(WS-WORD(4)) TO L-HTTPS
     CALL "READ-FIRST-LINE" USING WS-PID-FILE WS-TEXT
     MOVE FUNCTION NUMVAL(WS-TEXT) TO TESTSRV-PID
     MOVE SPACES TO WS-COMMAND
     STRING "rm -f " FUNCTION TRIM(WS-READY) " " FUNCTION TRIM(WS-PID-FILE)
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     IF L-HTTP = 0
         DISPLAY "TESTSRV-START: testsrv.py did not start"
         CALL "TESTSRV-STOP"
         STOP RUN RETURNING 2
     END-IF
     GOBACK.
 END PROGRAM TESTSRV-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TESTSRV-STOP.
*> Stops the server of TESTSRV-START (SIGTERM, waits until it has gone).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 TESTSRV-PID            BINARY-LONG EXTERNAL.
 01 WS-TERM                BINARY-LONG VALUE 15.
 01 WS-PROBE               BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-MICROS              BINARY-LONG VALUE 50000.
 PROCEDURE DIVISION.
     IF TESTSRV-PID > 0
         CALL STATIC "kill" USING BY VALUE TESTSRV-PID BY VALUE WS-TERM RETURNING WS-RC
         MOVE 0 TO WS-RC
         PERFORM VARYING WS-TRIES FROM 1 BY 1 UNTIL WS-TRIES > 100 OR WS-RC NOT = 0
             CALL STATIC "usleep" USING BY VALUE WS-MICROS
             CALL STATIC "kill" USING BY VALUE TESTSRV-PID BY VALUE WS-PROBE
                 RETURNING WS-RC
         END-PERFORM
         MOVE 0 TO TESTSRV-PID
     END-IF
     GOBACK.
 END PROGRAM TESTSRV-STOP.
