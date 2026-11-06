*> Acceptance test US18-6 client half (spec.md User Story 18 and its edge cases; 08 §9.1, §9.2, §9.3,
*> §9.5, §9.6; client/src/packs/download.cob, screens/pack-prompt.cob): a pushed pack prompts the
*> Player (unless the server's policy is always or never), is downloaded on accept over HTTP from
*> tools/testsrv/testsrv.py, its SHA-1 checked, and the responses accepted, downloaded,
*> successfully loaded are sent in order; it is drawn above the local packs until disconnect; the
*> pack offered last is on top; a failed download, a failed hash check and a failed reload send the
*> 08 §9.2 responses and leave the pack out; an invalid URL is answered at once; another pack of a
*> batch with a failed one is discarded; a popped pack drops out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-SERVER-PACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-server-pack".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-NAMES               PIC X(256) VALUE "alpha".
 01 WS-IDS                 PIC X(256) VALUE "file/alpha".
 01 WS-WWW                 PIC X(256) VALUE "build/client-test-www".
 01 WS-OPTIONS             PIC X(256) VALUE SPACES.
 01 WS-COMMAND             PIC X(256).
 01 WS-HTTP                BINARY-LONG.
 01 WS-HTTPS               BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CONFIG-PUSH         BINARY-LONG VALUE 9.
 01 WS-PLAY-PUSH           BINARY-LONG VALUE 82.
 01 WS-PLAY-POP            BINARY-LONG VALUE 81.
 01 WS-LAST                BINARY-LONG.
 01 WS-URL                 PIC X(256).
 01 WS-URL-LENGTH          BINARY-LONG.
 01 WS-HASH                PIC X(40).
 01 WS-HASH1               PIC X(40).
 01 WS-HASH2               PIC X(40).
 01 WS-NO-HASH             PIC X(40) VALUE SPACES.
 01 WS-BAD-HASH            PIC X(40) VALUE ALL "0".
 01 WS-REQUIRED            BINARY-LONG VALUE 0.
 01 WS-PROMPT              PIC X(64).
 01 WS-CAPTURE             PIC X(256) VALUE "build/client-test-server-pack-console.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-PROMPT-LENGTH       BINARY-LONG.
 01 WS-NO-PROMPT           PIC X(64) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-FILE                PIC X(256).
 01 WS-AREA                PIC X(64).
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ANY                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-READ                PIC X(1024).
 01 WS-SUMMARY             PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-TOKEN               PIC X(64).
 01 WS-TOKEN-LENGTH        BINARY-LONG.
 01 WS-GREY                PIC X(80) VALUE "cobolcraft:block/greystone".
 01 WS-GREY-LENGTH         BINARY-LONG VALUE 26.
 01 WS-PIXEL               PIC X(32).
 01 WS-E1                  PIC Z9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "rm -rf build/client-test-www && mkdir -p build/client-test-www && cd client/tests/"
         "fixtures/packs && cp server.zip server2.zip nometa.zip broken.zip badzip.zip ../../../../"
         "build/client-test-www/"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-TESTSRV-START" USING WS-WWW WS-OPTIONS WS-HTTP WS-HTTPS
     MOVE "client/tests/fixtures/packs/server.zip.sha1" TO WS-FILE
     CALL "TEST-READ-FILE" USING WS-FILE WS-AREA WS-CAP WS-LENGTH
     MOVE WS-AREA(1:40) TO WS-HASH1
     MOVE "client/tests/fixtures/packs/server2.zip.sha1" TO WS-FILE
     CALL "TEST-READ-FILE" USING WS-FILE WS-AREA WS-CAP WS-LENGTH
     MOVE WS-AREA(1:40) TO WS-HASH2

*>   A joined server-list entry with the prompt policy; the connection in configuration.
     MOVE 1 TO SL-COUNT
     MOVE "Test" TO SL-NAME(1)
     MOVE 4 TO SL-NAME-LENGTH(1)
     MOVE "127.0.0.1" TO SL-ADDR(1)
     MOVE 9 TO SL-ADDR-LENGTH(1)
     MOVE 0 TO SL-POLICY(1)
     MOVE 1 TO RP-ENTRY-JOINED
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     CALL "TEST-LOOPBACK" USING CLIENT-STATE WS-CONN WS-SERVER
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE SCR-CONNECTING TO SM-SCREEN

     MOVE 1 TO WS-LAST
     MOVE "server.zip" TO WS-TOKEN
     MOVE WS-HASH1 TO WS-HASH
     MOVE "Use it" TO WS-PROMPT
     MOVE 6 TO WS-PROMPT-LENGTH
     PERFORM MAKE-URL
     CALL "TEST-PUSH" USING CLIENT-STATE WS-CONN WS-CONFIG-PUSH WS-LAST WS-URL WS-URL-LENGTH
         WS-HASH WS-REQUIRED WS-PROMPT WS-PROMPT-LENGTH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US18-6 Given a server offering a pack When the Player joins Then they are "
         & "asked whether to accept it (with the server's prompt)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " WS-TEXT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "17 Server Resource Pack|This server offers a resource pack|The server says: Use it|"
         & "Your answer is kept for this server|Accept|Decline" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-PACK-ACCEPT TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     PERFORM SETTLE
     PERFORM READ-RESPONSES
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-GREY WS-GREY-LENGTH WS-PIXEL
     MOVE "acceptance US18-6 Given the prompt When the Player accepts Then the pack is downloaded,"
         & " checked and applied above the local packs, and accepted, downloaded, successfully "
         & "loaded are sent in order" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING WS-SUMMARY DELIMITED BY "  " " / " FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE
         WS-PIXEL DELIMITED BY SPACE
         " " PK-ID(3)(1:PK-ID-LENGTH(3)) " " PK-ID(2)(1:PK-ID-LENGTH(2)) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "01:3 01:4 01:0 / 4 0,250,250,255 server/00000001/00112233-4455-6677-8899-aabbccddee"
         & "01 file/alpha" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US18-6 the Player's answer is kept for the server (PackPolicy 1 in "
         & "servers.dat)" TO TL-CASE
     MOVE 0 TO SL-POLICY(1)
     CALL "SERVERS-LOAD" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SL-POLICY(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   A second pack (the policy is now "always accept"): no prompt, on top.
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE 2 TO WS-LAST
     MOVE "server2.zip" TO WS-TOKEN
     MOVE WS-HASH2 TO WS-HASH
     PERFORM MAKE-URL
     CALL "TEST-PUSH" USING CLIENT-STATE WS-CONN WS-PLAY-PUSH WS-LAST WS-URL WS-URL-LENGTH
         WS-HASH WS-REQUIRED WS-NO-PROMPT WS-ZERO
     PERFORM SETTLE
     PERFORM READ-RESPONSES
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-GREY WS-GREY-LENGTH WS-PIXEL
     MOVE "acceptance US18 edge Given two pushed packs When both are applied Then the one offered"
         & " last is on top (no prompt once the server's packs are always accepted)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-SUMMARY DELIMITED BY "  " " / " DELIMITED BY SIZE WS-PIXEL DELIMITED BY SPACE
         " "
         PK-ID(4)(1:16) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "02:3 02:4 02:0 / 250,250,0,255 server/00000002/" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2 TO WS-LAST
     CALL "TEST-POP" USING CLIENT-STATE WS-CONN WS-PLAY-POP WS-LAST
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-GREY WS-GREY-LENGTH WS-PIXEL
     MOVE "acceptance US18 Resource Pack Pop (play) with a pack id removes that pack (no response)"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE PK-COUNT TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " WS-PIXEL DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "3 0,250,250,255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Failures (08 §9.2).
     MOVE 3 TO WS-LAST
     MOVE "server.zip" TO WS-TOKEN
     MOVE WS-BAD-HASH TO WS-HASH
     PERFORM PUSH-AND-SETTLE
     MOVE "acceptance US18 edge Given a pushed pack whose hash does not match When it is fetched "
         & "Then accepted, failed download are sent and it is not applied" TO TL-CASE
     PERFORM EXPECT-STILL
     MOVE "03:3 03:2 / 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 4 TO WS-LAST
     MOVE "missing.zip" TO WS-TOKEN
     MOVE WS-NO-HASH TO WS-HASH
     PERFORM PUSH-AND-SETTLE
     MOVE "acceptance US18 edge Given a pushed pack the server cannot deliver (HTTP 404) When it "
         & "is fetched Then accepted, failed download are sent and it is not applied" TO TL-CASE
     PERFORM EXPECT-STILL
     MOVE "04:3 04:2 / 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 5 TO WS-LAST
     MOVE "ftp://127.0.0.1/x.zip" TO WS-URL
     MOVE 21 TO WS-URL-LENGTH
     CALL "TEST-PUSH" USING CLIENT-STATE WS-CONN WS-PLAY-PUSH WS-LAST WS-URL WS-URL-LENGTH
         WS-HASH WS-REQUIRED WS-NO-PROMPT WS-ZERO
     PERFORM SETTLE
     PERFORM READ-RESPONSES
     MOVE "acceptance US18 Given a pushed pack with a URL that is not http or https Then invalid "
         & "URL is sent at once" TO TL-CASE
     PERFORM EXPECT-STILL
     MOVE "05:5 / 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 6 TO WS-LAST
     MOVE "nometa.zip" TO WS-TOKEN
     PERFORM PUSH-AND-SETTLE
     MOVE "acceptance US18 edge Given a pushed pack that cannot be loaded (no pack.mcmeta) When it "
         & "is applied Then accepted, downloaded, failed reload are sent and it is left out"
         TO TL-CASE
     PERFORM EXPECT-STILL
     MOVE "06:3 06:4 06:6 / 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   One batch of two: the failing one gets failed download, the other is discarded.
     MOVE 7 TO WS-LAST
     MOVE "missing.zip" TO WS-TOKEN
     PERFORM MAKE-URL
     CALL "TEST-PUSH" USING CLIENT-STATE WS-CONN WS-PLAY-PUSH WS-LAST WS-URL WS-URL-LENGTH
         WS-HASH WS-REQUIRED WS-NO-PROMPT WS-ZERO
     MOVE 8 TO WS-LAST
     MOVE "server2.zip" TO WS-TOKEN
     MOVE WS-HASH2 TO WS-HASH
     PERFORM MAKE-URL
     CALL "TEST-PUSH" USING CLIENT-STATE WS-CONN WS-PLAY-PUSH WS-LAST WS-URL WS-URL-LENGTH
         WS-HASH WS-REQUIRED WS-NO-PROMPT WS-ZERO
     PERFORM SETTLE
     PERFORM READ-RESPONSES
     MOVE "acceptance US18 edge Given two pushed packs fetched together When one fails Then it "
         & "gets failed download and the other is discarded" TO TL-CASE
     PERFORM EXPECT-STILL
     IF WS-SUMMARY(1:24) = "07:3 08:3 08:4 07:2 08:7"
         MOVE "07:3 08:3 07:2 08:7" TO WS-SUMMARY
         MOVE SPACES TO TL-OBSERVED
         STRING WS-SUMMARY DELIMITED BY "  " " / 3" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "07:3 08:3 07:2 08:7 / 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 9 TO WS-LAST
     MOVE "broken.zip" TO WS-TOKEN
     MOVE WS-NO-HASH TO WS-HASH
     PERFORM PUSH-AND-SETTLE
     MOVE "acceptance US18 edge Given a pushed pack that is not a zip archive When it is applied "
         & "Then accepted, downloaded, failed reload are sent" TO TL-CASE
     PERFORM EXPECT-STILL
     MOVE "09:3 09:4 09:6 / 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 10 TO WS-LAST
     MOVE "badzip.zip" TO WS-TOKEN
     PERFORM PUSH-AND-SETTLE
     MOVE "acceptance US18 edge Given a pushed pack with invalid metadata When it is applied Then "
         & "accepted, downloaded, failed reload are sent" TO TL-CASE
     PERFORM EXPECT-STILL
     MOVE "0a:3 0a:4 0a:6 / 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Pop without a pack id removes every server pack.
     MOVE 11 TO WS-LAST
     MOVE "server.zip" TO WS-TOKEN
     MOVE WS-HASH1 TO WS-HASH
     PERFORM PUSH-AND-SETTLE
     MOVE -1 TO WS-LAST
     CALL "TEST-POP" USING CLIENT-STATE WS-CONN WS-PLAY-POP WS-LAST
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-GREY WS-GREY-LENGTH WS-PIXEL
     MOVE "acceptance US18 Resource Pack Pop without a pack id removes every server pack" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE PK-COUNT TO WS-E1
     STRING WS-SUMMARY DELIMITED BY "  " " / " FUNCTION TRIM(WS-E1) " " WS-PIXEL
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0b:3 0b:4 0b:0 / 2 10,200,10,255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   No server-list entry and no answer yet: each push waits for the prompt (one screen for all);
*>   at most 8 wait; Decline answers each one.
     MOVE 0 TO RP-ENTRY-JOINED RP-DECISION
     MOVE WS-NO-HASH TO WS-HASH
*>   The ninth push finds no room: dropped with one console line naming its id (FR-012).
     CALL "TEST-CAPTURE-START" USING WS-CAPTURE
     PERFORM VARYING WS-LAST FROM 12 BY 1 UNTIL WS-LAST > 20
         PERFORM MAKE-URL
         CALL "TEST-PUSH" USING CLIENT-STATE WS-CONN WS-PLAY-PUSH WS-LAST WS-URL WS-URL-LENGTH
             WS-HASH WS-REQUIRED WS-NO-PROMPT WS-ZERO
     END-PERFORM
     CALL "TEST-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     MOVE "acceptance US18-6 Given 8 server packs waiting When a ninth is pushed Then it is "
         & "dropped with one console line naming its id" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ERROR server pack: 00112233-4455-6677-8899-aabbccddee14 dropped, 8 packs already "
         & "pending" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US18-6 pushes while the prompt is open share it (at most 8 wait; no server "
         & "entry: nothing to keep)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE RP-COUNT TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " WS-TEXT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "8 Server Resource Pack|This server offers a resource pack|Accept|Decline"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-PACK-DECLINE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     PERFORM SETTLE
     PERFORM READ-RESPONSES
     MOVE "acceptance US18-6 Given the prompt When the Player declines Then each waiting pack is "
         & "answered declined" TO TL-CASE
     PERFORM EXPECT-STILL
     MOVE "13:1 12:1 11:1 10:1 0f:1 0e:1 0d:1 0c:1 / 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Disconnect: the server packs are removed.
     CALL "NET-CLOSE" USING CLIENT-STATE WS-CONN
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-GREY WS-GREY-LENGTH WS-PIXEL
     MOVE "acceptance US18-6 Given applied server packs When the Player disconnects Then they are "
         & "removed and the local packs show again" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE PK-COUNT TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " WS-PIXEL DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE RP-COUNT TO WS-E1
     MOVE TL-OBSERVED TO WS-TEXT
     STRING WS-TEXT DELIMITED BY "  " " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 10,200,10,255 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-SERVER
     CALL "TEST-TESTSRV-STOP"
     STOP RUN.

 MAKE-URL.
     MOVE SPACES TO WS-URL
     MOVE 1 TO WS-PTR
     STRING "http://127.0.0.1:" DELIMITED BY SIZE INTO WS-URL WITH POINTER WS-PTR
     CALL "TEST-PORT-TEXT" USING WS-HTTP WS-URL WS-PTR
     STRING "/" WS-TOKEN DELIMITED BY SPACE INTO WS-URL WITH POINTER WS-PTR
     COMPUTE WS-URL-LENGTH = WS-PTR - 1.

 PUSH-AND-SETTLE.
     PERFORM MAKE-URL
     CALL "TEST-PUSH" USING CLIENT-STATE WS-CONN WS-PLAY-PUSH WS-LAST WS-URL WS-URL-LENGTH
         WS-HASH WS-REQUIRED WS-NO-PROMPT WS-ZERO
     PERFORM SETTLE
     PERFORM READ-RESPONSES.

*>   Frames until no pushed pack waits for its download or its activation (at most 10 s).
 SETTLE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000
         CALL "TEST-STEP" USING CLIENT-STATE
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-OUT FROM 1 BY 1 UNTIL WS-OUT > RP-COUNT
             IF RP-STEP(WS-OUT) NOT = RPS-ACTIVE
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             MOVE 1000 TO WS-I
         ELSE
             CALL "TEST-SLEEP"
         END-IF
     END-PERFORM
     CALL "TEST-STEP" USING CLIENT-STATE.

*>   The Resource Pack Responses the server received, as "<pack id's last byte>:<action>".
 READ-RESPONSES.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-READ WS-THRESHOLD
     MOVE SPACES TO WS-SUMMARY
     MOVE 1 TO WS-PTR WS-OUT
     PERFORM UNTIL WS-PTR > 1024
         MOVE SPACES TO WS-TOKEN
         UNSTRING WS-READ DELIMITED BY ALL SPACE INTO WS-TOKEN COUNT IN WS-TOKEN-LENGTH
             WITH POINTER WS-PTR
         IF WS-TOKEN-LENGTH = 36
             IF WS-OUT > 1
                 STRING " " DELIMITED BY SIZE INTO WS-SUMMARY WITH POINTER WS-OUT
             END-IF
             STRING WS-TOKEN(33:2) ":" WS-TOKEN(36:1) DELIMITED BY SIZE INTO WS-SUMMARY
                 WITH POINTER WS-OUT
         END-IF
     END-PERFORM.

 EXPECT-STILL.
     MOVE SPACES TO TL-OBSERVED
     MOVE PK-COUNT TO WS-E1
     STRING WS-SUMMARY DELIMITED BY "  " " / " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO TL-OBSERVED.
 END PROGRAM ACC-US18-SERVER-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORT-TEXT.
*> USING port, text (appended at the pointer), pointer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-E                   PIC Z(5)9.
 LINKAGE SECTION.
 01 L-PORT                 BINARY-LONG.
 01 L-TEXT                 PIC X(256).
 01 L-PTR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PORT L-TEXT L-PTR.
     MOVE L-PORT TO WS-E
     STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO L-TEXT WITH POINTER L-PTR
     GOBACK.
 END PROGRAM TEST-PORT-TEXT.
 COPY CLTEST.
 COPY PACKTEST.
