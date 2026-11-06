*> Acceptance test US18-8 (spec.md User Story 18; 08 §9.4; client/src/packs/cache.cob, download.cob):
*> a downloaded pack is kept under downloads/<pack id>/<sha1>; offered again unchanged (same id and
*> hash), it is applied from there without a second download, still answered accepted, downloaded,
*> successfully loaded. A cached file whose content no longer has the hash is fetched again. The
*> cache keeps at most 20 files (the oldest go first).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-CACHE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-cache".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAMES               PIC X(256) VALUE SPACES.
 01 WS-WWW                 PIC X(256) VALUE "build/client-test-cache-www".
 01 WS-OPTIONS             PIC X(256)
     VALUE "--request-log build/client-test-cache-www.log".
 01 WS-COMMAND             PIC X(512).
 01 WS-HTTP                BINARY-LONG.
 01 WS-HTTPS               BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PUSH                BINARY-LONG VALUE 9.
 01 WS-LAST                BINARY-LONG VALUE 1.
 01 WS-URL                 PIC X(256).
 01 WS-URL-LENGTH          BINARY-LONG.
 01 WS-HASH                PIC X(40).
 01 WS-REQUIRED            BINARY-LONG VALUE 0.
 01 WS-NO-PROMPT           PIC X(64) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-FILE                PIC X(256).
 01 WS-AREA                PIC X(4096).
 01 WS-CAP                 BINARY-LONG VALUE 4096.
 01 WS-LOG                 PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-READ                PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-REQUESTS            BINARY-LONG.
 01 WS-E1                  PIC Z9.
 01 WS-E2                  PIC Z9.
 01 WS-INFO                PIC X(16).
 01 WS-GREY                PIC X(80) VALUE "cobolcraft:block/greystone".
 01 WS-GREY-LENGTH         BINARY-LONG VALUE 26.
 01 WS-PIXEL               PIC X(32).
 01 WS-CACHED              PIC X(256).
 PROCEDURE DIVISION.
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "rm -rf build/client-test-cache-www build/client-test-cache-www.log && mkdir -p "
         "build/client-test-cache-www && cp client/tests/fixtures/packs/server.zip build/client-"
         "test-cache-www/" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
*>   An old cache with 21 files (one per pack id, a minute apart, the last listed the oldest).
     CALL "TEST-PACK-DIR" USING WS-DIR WS-DIR-LENGTH WS-NAMES
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21; do d=build/"
         "client-test-cache/downloads/000000$i; mkdir -p $d; echo x > $d/old; touch -t 202601"
         "0110`expr 59 - $i`.00 $d/old; done" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE WS-DIR TO CL-GAME-DIR
     MOVE WS-DIR-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     MOVE "build/client-test-cache/downloads/00000021/old" TO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     MOVE RETURN-CODE TO WS-K
     MOVE "build/client-test-cache/downloads/00000020/old" TO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     MOVE RETURN-CODE TO WS-E2
     MOVE 0 TO RETURN-CODE
     MOVE "acceptance US18-8 the download cache keeps at most 20 files at start-up, the oldest "
         & "removed first" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "kept" TO TL-OBSERVED
     IF WS-K NOT = 0
         MOVE "gone" TO TL-OBSERVED
     END-IF
     STRING TL-OBSERVED DELIMITED BY SPACE " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO WS-READ
     MOVE WS-READ TO TL-OBSERVED
     MOVE "gone 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-TESTSRV-START" USING WS-WWW WS-OPTIONS WS-HTTP WS-HTTPS
     MOVE "client/tests/fixtures/packs/server.zip.sha1" TO WS-FILE
     CALL "TEST-READ-FILE" USING WS-FILE WS-AREA WS-CAP WS-LENGTH
     MOVE WS-AREA(1:40) TO WS-HASH
     MOVE SPACES TO WS-URL
     MOVE 1 TO WS-PTR
     STRING "http://127.0.0.1:" DELIMITED BY SIZE INTO WS-URL WITH POINTER WS-PTR
     CALL "TEST-PORT-TEXT" USING WS-HTTP WS-URL WS-PTR
     STRING "/server.zip" DELIMITED BY SIZE INTO WS-URL WITH POINTER WS-PTR
     COMPUTE WS-URL-LENGTH = WS-PTR - 1
     MOVE 1 TO SL-COUNT
     MOVE 1 TO SL-POLICY(1)
     MOVE 9 TO SL-ADDR-LENGTH(1)
     MOVE "127.0.0.1" TO SL-ADDR(1)

*>   First join: downloaded and cached.
     PERFORM JOIN
     MOVE SPACES TO WS-CACHED
     STRING "build/client-test-cache/downloads/00112233-4455-6677-8899-aabbccddee01/" WS-HASH
         DELIMITED BY SIZE INTO WS-CACHED
     CALL "CBL_CHECK_FILE_EXIST" USING WS-CACHED WS-INFO
     MOVE RETURN-CODE TO WS-E2
     MOVE 0 TO RETURN-CODE
     MOVE "acceptance US18-8 a downloaded pack is kept as downloads/<pack id>/<sha1>" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM COUNT-REQUESTS
     MOVE WS-REQUESTS TO WS-E1
     MOVE SPACES TO WS-AREA
     STRING WS-READ DELIMITED BY "  " " requests " FUNCTION TRIM(WS-E1) " cached "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-AREA
     MOVE WS-AREA(1:1024) TO TL-OBSERVED
     MOVE "0600112233445566778899aabbccddee0103 0600112233445566778899aabbccddee0104 06001122334"
         & "45566778899aabbccddee0100 requests 1 cached 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Second join: the same pack (id and hash) comes from the cache.
     PERFORM JOIN
     MOVE "acceptance US18-8 Given the Player has the server's pack When they rejoin and the "
         & "server offers the same pack unchanged Then it is applied without downloading it again"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM COUNT-REQUESTS
     MOVE WS-REQUESTS TO WS-E1
     MOVE SPACES TO WS-AREA
     STRING WS-READ DELIMITED BY "  " " requests " FUNCTION TRIM(WS-E1) " " WS-PIXEL
         DELIMITED BY SIZE INTO WS-AREA
     MOVE WS-AREA(1:1024) TO TL-OBSERVED
     MOVE "0600112233445566778899aabbccddee0103 0600112233445566778899aabbccddee0104 06001122334"
         & "45566778899aabbccddee0100 requests 1 0,250,250,255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A cached file that no longer has the hash is fetched again.
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "echo changed > " DELIMITED BY SIZE WS-CACHED DELIMITED BY SPACE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     PERFORM JOIN
     PERFORM COUNT-REQUESTS
     MOVE "acceptance US18-8 a cached file whose content does not have the hash is downloaded "
         & "again" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-REQUESTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TESTSRV-STOP"
     STOP RUN.

 JOIN.
     MOVE 1 TO RP-ENTRY-JOINED
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     CALL "TEST-LOOPBACK" USING CLIENT-STATE WS-CONN WS-SERVER
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE SCR-CONNECTING TO SM-SCREEN
     CALL "TEST-PUSH" USING CLIENT-STATE WS-CONN WS-PUSH WS-LAST WS-URL WS-URL-LENGTH WS-HASH
         WS-REQUIRED WS-NO-PROMPT WS-ZERO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000
         CALL "TEST-STEP" USING CLIENT-STATE
         IF RP-COUNT > 0 AND RP-STEP(1) = RPS-ACTIVE
             MOVE 1000 TO WS-I
         ELSE
             CALL "TEST-SLEEP"
         END-IF
     END-PERFORM
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-READ WS-THRESHOLD
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-GREY WS-GREY-LENGTH WS-PIXEL
     CALL "NET-CLOSE" USING CLIENT-STATE WS-CONN
     CALL STATIC "cc_net_close" USING BY VALUE WS-SERVER.

*>   GET lines in the server's request log.
 COUNT-REQUESTS.
     MOVE "build/client-test-cache-www.log" TO WS-FILE
     MOVE SPACES TO WS-LOG
     CALL "TEST-READ-FILE" USING WS-FILE WS-LOG WS-CAP WS-LENGTH
     MOVE 0 TO WS-REQUESTS
     INSPECT WS-LOG TALLYING WS-REQUESTS FOR ALL "GET /"
     .
 END PROGRAM ACC-US18-CACHE.

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
