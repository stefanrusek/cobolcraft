*> contract_wire_server.cob dimension cases (test infrastructure; task T579;
*> docs/protocol/09-cobolcraft-profile.md §3.2 Login rows, §3.3 Dimensions rows; standin-content
*> §5.1, §15.1, §15.5). Clientbound Respawn to every extra dimension (data to keep 0x03, survival)
*> equals its fixture play-s2c-54-respawn-<dimension path>.hex, and the Login of entity 1 in
*> survival in cobolcraft:main of a world with every dimension enabled (extra-dimensions on) equals
*> play-s2c-32-login-all-dimensions.hex.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-DIM-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-MODE                PIC 9 VALUE 0.
 01 WS-KEEP                BINARY-LONG VALUE 3.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

     PERFORM VARYING WS-DIM FROM 1 BY 1 UNTIL WS-DIM > DIM-TABLE-ROWS
         IF DM-EXTRA(WS-DIM) = 1
             MOVE SPACES TO TL-CASE WS-PATH
             STRING "contract wire server Respawn to " DM-KEY(WS-DIM)(1:DM-KEY-LENGTH(WS-DIM))
                 " (survival, data to keep 0x03) equals its fixture" DELIMITED BY SIZE INTO TL-CASE
             STRING "contract/fixtures/wire/play-s2c-54-respawn-"
                 DM-KEY(WS-DIM)(12:DM-KEY-LENGTH(WS-DIM) - 11) ".hex" DELIMITED BY SIZE
                 INTO WS-PATH
             CALL "PB-RESET" USING PB-BUFFER
             CALL "PLAY-RESPAWN-BUILD" USING WS-DIM WS-MODE WS-KEEP PB-BUFFER
             CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
         END-IF
     END-PERFORM

     MOVE "contract wire server play-s2c-32-login-all-dimensions equals the core's Login for entity "
         & "id 1, survival, cobolcraft:main, view distance 8, extra-dimensions on" TO TL-CASE
     INITIALIZE PL-ENTRY(1)
     MOVE 1 TO PL-ENTITY-ID(1)
     MOVE 0 TO PL-MODE(1)
     MOVE DIM-MAIN TO PL-DIM(1)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-LOGIN-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-32-login-all-dimensions.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-DIM-CASES.
