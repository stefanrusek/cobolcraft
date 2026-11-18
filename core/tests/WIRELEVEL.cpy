*> contract_wire_server.cob level event and particle cases (test infrastructure; task T1765; docs/protocol/05a 0x2F and 0x30, 42 part 4 section 13.3, 42 part 7 section 1.2). The Level Event
*> the core broadcasts for event 2001 at (-3, 12, 9) with data 88 equals play-s2c-2f-level-event, and the block Level Particles the core sends (state 35722, override limiter, at
*> (-1.5, 3.0, 8.25), count 0) equal play-s2c-30-level-particles. Not compared, and why: play-s2c-30-level-particles-dust (the core has no emitter of a dust particle: PARTICLE-BUILD
*> writes the option of a block particle only, the redstone dust of the documents is drawn by the client) and play-s2c-32-login-all-dimensions-standard (the core's Login always has hashed
*> seed 0, no previous game mode and no last death location, the fixture has values the core cannot produce); both stay codec fixtures of proto/tests/contract_wire_provider.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-LEVEL-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-DIM                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 2001.
 01 WS-X                   BINARY-LONG VALUE -3.
 01 WS-Y                   BINARY-LONG VALUE 12.
 01 WS-Z                   BINARY-LONG VALUE 9.
 01 WS-DATA                BINARY-LONG VALUE 88.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-OPTION              BINARY-LONG VALUE 35722.
 01 WS-OVERRIDE            BINARY-LONG VALUE 1.
 01 WS-ALWAYS              BINARY-LONG VALUE 0.
 01 WS-PX                  FLOAT-LONG VALUE -1.5.
 01 WS-PY                  FLOAT-LONG VALUE 3.0.
 01 WS-PZ                  FLOAT-LONG VALUE 8.25.
 01 WS-SPREAD-TABLE.
    05 WS-SPREAD           FLOAT-SHORT OCCURS 6 TIMES VALUE 0.
 01 WS-COUNT               BINARY-LONG VALUE 0.
 01 WS-RANDOM              BINARY-LONG VALUE 0.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE CN-PLAYER(WS-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE 0.0 TO PL-X(WS-ROW)
     MOVE 12.0 TO PL-Y(WS-ROW)
     MOVE 0.0 TO PL-Z(WS-ROW)

     MOVE "contract wire server play-s2c-2f-level-event equals the core's Level Event 2001 at "
         & "(-3, 12, 9), data 88, not global" TO TL-CASE
     CALL "LEVEL-EVENT" USING WS-DIM WS-EVENT WS-X WS-Y WS-Z WS-DATA WS-NONE
     MOVE 47 TO WS-PACKET-ID
     CALL "TEST-DRAIN-PACKET" USING WS-ID WS-PACKET-ID PB-BUFFER WS-FOUND
     MOVE "contract/fixtures/wire/play-s2c-2f-level-event.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-30-level-particles equals the core's block Level "
         & "Particles of state 35722 with the override limiter at (-1.5, 3.0, 8.25)" TO TL-CASE
     CALL "PARTICLE-SEND" USING WS-DIM WS-TYPE WS-OPTION WS-OVERRIDE WS-ALWAYS WS-PX WS-PY WS-PZ
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     MOVE 48 TO WS-PACKET-ID
     CALL "TEST-DRAIN-PACKET" USING WS-ID WS-PACKET-ID PB-BUFFER WS-FOUND
     MOVE "contract/fixtures/wire/play-s2c-30-level-particles.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-LEVEL-CASES.
