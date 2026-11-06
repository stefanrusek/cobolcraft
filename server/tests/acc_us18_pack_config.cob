*> Acceptance test, US18-6 server half: the pack-* keys of the configuration file
*> (contracts/operator-surface.md §2, FR-009). Given pack-url, pack-sha1, pack-id, pack-required and
*> pack-prompt the started server's CORE-SETTINGS offer that pack; an empty pack-url means no offer;
*> the default file lists the pack keys, each preceded by a one-line comment, with their defaults.
*> Runs in build/server-test-pack-config*.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-PACK-CONFIG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY SVSTATE.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256).
 01 WS-CONF                PIC X(4096).
 01 WS-CONF-PATH           PIC X(256) VALUE "cobolcraft-server.conf".
 01 WS-LINES               PIC X(4096).
 01 WS-DEFAULTS            PIC X(1707).
 01 WS-EXPECTED            PIC X(1707).
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-LINE                PIC X(1024).
 01 WS-PREVIOUS            PIC X(1024).
 01 WS-PACK-LINES          PIC X(1024).
 01 WS-PACK-AT             BINARY-LONG.
 01 WS-UNCOMMENTED         BINARY-LONG.
 01 WS-COUNT               PIC Z(7)9.
 PROCEDURE DIVISION.
*>   The operator-surface §2 defaults, written out from the table.
     INITIALIZE CORE-SETTINGS
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE "A CobolCraft server" TO CS-DESCRIPTION
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-PLAYER-COMBAT CS-HOSTILE-MOBS CS-WEATHER-CHANGES CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-ALLOW-LIST-ENFORCED CS-PACK-OFFERED CS-PACK-REQUIRED CS-HOST-KIND
     MOVE "world" TO CS-NEW-WORLD-NAME
     MOVE CORE-SETTINGS TO WS-DEFAULTS

*>   US18-6: every pack key set.
     MOVE "build/server-test-pack-config" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "port=25579|pack-url=https://packs.example.test/cobolcraft/test.zip|pack-sha1=0123456789"
         & "abcdefABCDEF0123456789abcdef01|pack-id=6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b|pack-req"
         & "uired=true|pack-prompt=Please use the server look" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     MOVE 1 TO CS-PACK-OFFERED CS-PACK-REQUIRED
     MOVE "https://packs.example.test/cobolcraft/test.zip" TO CS-PACK-URL
     MOVE "0123456789abcdefABCDEF0123456789abcdef01" TO CS-PACK-SHA1
     MOVE "6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b" TO CS-PACK-ID
     MOVE "Please use the server look" TO CS-PACK-PROMPT
     MOVE CORE-SETTINGS TO WS-EXPECTED
     MOVE WS-DEFAULTS TO CORE-SETTINGS
     CALL "SV-START"
     MOVE "acceptance US18-6 given pack-url, pack-sha1, pack-id, pack-required and pack-prompt "
         & "when the server starts then CORE-SETTINGS offers that pack" TO TL-CASE
     PERFORM COMPARE-SETTINGS
     CALL "SV-SHUTDOWN"

*>   An empty pack-url means no offer (the other pack keys are kept but unused).
     CALL "SVT-HOME"
     MOVE "build/server-test-pack-config-none" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "port=25579|pack-url=|pack-sha1=0123456789abcdef0123456789abcdef01234567|pack-requir"
         & "ed=true" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     MOVE 1 TO CS-PACK-REQUIRED
     MOVE "0123456789abcdef0123456789abcdef01234567" TO CS-PACK-SHA1
     MOVE CORE-SETTINGS TO WS-EXPECTED
     MOVE WS-DEFAULTS TO CORE-SETTINGS
     CALL "SV-START"
     MOVE "acceptance US18-6 given an empty pack-url when the server starts then CORE-SETTINGS "
         & "offers no pack" TO TL-CASE
     PERFORM COMPARE-SETTINGS
     CALL "SV-SHUTDOWN"

*>   The default file lists the pack keys, each after a comment line.
     CALL "SVT-HOME"
     MOVE "build/server-test-pack-config-default" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SV-START"
     CALL "SVT-READ-LINES" USING WS-CONF-PATH WS-LINES
     MOVE SPACES TO WS-PACK-LINES WS-PREVIOUS
     MOVE 1 TO WS-START WS-PACK-AT
     MOVE 0 TO WS-UNCOMMENTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4094
         IF WS-LINES(WS-I:3) = " | " OR WS-I = 4094
             MOVE SPACES TO WS-LINE
             IF WS-I > WS-START
                 COMPUTE WS-AT = WS-I - WS-START
                 MOVE WS-LINES(WS-START:WS-AT) TO WS-LINE
             END-IF
             IF WS-LINE(1:5) = "pack-"
                 IF WS-PREVIOUS(1:1) NOT = "#"
                     ADD 1 TO WS-UNCOMMENTED
                 END-IF
                 IF WS-PACK-AT > 1
                     STRING " | " DELIMITED BY SIZE INTO WS-PACK-LINES WITH POINTER WS-PACK-AT
                 END-IF
                 STRING FUNCTION TRIM(WS-LINE) DELIMITED BY SIZE INTO WS-PACK-LINES
                     WITH POINTER WS-PACK-AT
             END-IF
             MOVE WS-LINE TO WS-PREVIOUS
             COMPUTE WS-START = WS-I + 3
         END-IF
     END-PERFORM
     MOVE "acceptance US18-6 given no configuration file when the server starts then the default "
         & "file lists the pack keys, each preceded by a one-line comment" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "pack-url= | pack-sha1= | pack-id= | pack-required=false | pack-prompt= uncommented 0"
         TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-UNCOMMENTED TO WS-COUNT
     STRING FUNCTION TRIM(WS-PACK-LINES) " uncommented " FUNCTION TRIM(WS-COUNT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US18-6 given the default file when the server starts then it offers no pack"
         TO TL-CASE
     MOVE WS-DEFAULTS TO WS-EXPECTED
     PERFORM COMPARE-SETTINGS
     CALL "SV-SHUTDOWN"
     CALL "SVT-HOME"
     STOP RUN.

 COMPARE-SETTINGS.
     MOVE "T" TO TL-MODE
     MOVE "same" TO TL-EXPECTED
     IF SV-SETTINGS = WS-EXPECTED
         MOVE "same" TO TL-OBSERVED
     ELSE
         MOVE SV-SETTINGS TO CORE-SETTINGS
         MOVE SPACES TO TL-OBSERVED
         STRING "differs: offered " CS-PACK-OFFERED " required " CS-PACK-REQUIRED " url "
             FUNCTION TRIM(CS-PACK-URL) " sha1 " FUNCTION TRIM(CS-PACK-SHA1) " id "
             FUNCTION TRIM(CS-PACK-ID) " prompt " FUNCTION TRIM(CS-PACK-PROMPT)
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE WS-DEFAULTS TO CORE-SETTINGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US18-PACK-CONFIG.
 COPY SVTEST.
