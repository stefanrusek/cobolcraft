*> Implementation test (lane covB; docs/protocol/35-worldgen-features-7-nether-end-misc.md section 8 and 31-5 section 4): an end_gateway feature without an exit (and without the exact flag)
*> places the gateway block; its block entity gets no exit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-ENDGATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/covb-end".
 01 WS-PTR                 USAGE POINTER.
 01 WS-AREA                PIC X(304640) BASED.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-FT                  BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 24.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 40.
01 WS-X0                 BINARY-LONG.
 01 WS-X1                 BINARY-LONG.
 01 WS-Y0                 BINARY-LONG.
 01 WS-Y1                 BINARY-LONG.
 01 WS-Z0                 BINARY-LONG.
 01 WS-Z1                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 3.
 01 WS-RESULT              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE "minecraft:gate_noexit" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "covB 35-7 8 an end_gateway with exact false and no exit compiles (type 11)" TO WS-CASE
     MOVE 11 TO WS-EXP
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     PERFORM ASSERT-N
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "covB 35-7 8 and places the gateway block" TO WS-CASE
     MOVE "end_gateway" TO WS-KEY
     PERFORM ASSERT-BLOCK
     STOP RUN.
 COPY FWTEST.
 END PROGRAM TEST-COVB-ENDGATE.
 COPY NOSPAWN.
 COPY CORETEST.
