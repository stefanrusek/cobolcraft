*> Implementation test (lane covB; docs/protocol/35-worldgen-features-5-water-and-surface.md section 9): an iceberg that meets snow layers (a plane of them at a height of the cut-out
*> region): when the cut removes an ice cell with a snow layer on top, that layer goes too. Over 300 seeds with the plane at heights from 66 to 76 at least one snow layer is removed
*> by a cut (a layer that was there at the start and is air at the end, beside a cell of the iceberg that went).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-ICEBERG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/water".
 01 WS-PTR                 USAGE POINTER.
 01 WS-AREA                PIC X(304640) BASED.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-FT                  BINARY-LONG.
 01 WS-FT-PACKED           BINARY-LONG.
 01 WS-FT-BLUE             BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
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
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-RESULT              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S-SNOW              BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG.
 01 WS-PLANE               BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
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
     MOVE "snow" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-SNOW
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     MOVE "minecraft:iceberg_packed" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-PACKED
     CALL "FD-ENSURE-FT" USING WS-FT-PACKED
     MOVE "minecraft:iceberg_blue" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-BLUE
     CALL "FD-ENSURE-FT" USING WS-FT-BLUE
     MOVE 0 TO WS-REMOVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         SET ADDRESS OF WS-AREA TO WS-PTR
         MOVE LOW-VALUES TO WS-AREA
         CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
         MOVE 16 TO WS-X0
         MOVE 31 TO WS-X1
         MOVE 32 TO WS-Z0
         MOVE 47 TO WS-Z1
         MOVE 10 TO WS-Y0
         MOVE 40 TO WS-Y1
         MOVE "stone" TO WS-KEY
         PERFORM FILL-BOX
         MOVE 41 TO WS-Y0
         MOVE 62 TO WS-Y1
         MOVE "water" TO WS-KEY
         PERFORM FILL-BOX
         COMPUTE WS-PLANE = 66 + FUNCTION MOD(WS-I, 11)
         PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
             PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
                 CALL "FL-SET-STATE" USING WS-X WS-PLANE WS-Z WS-S-SNOW WS-FLAGS WS-OK
             END-PERFORM
         END-PERFORM
         MOVE WS-I TO WS-SEED
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         MOVE 24 TO WS-X
         MOVE 80 TO WS-Y
         MOVE 40 TO WS-Z
         IF FUNCTION MOD(WS-I, 2) = 0
             MOVE WS-FT-BLUE TO WS-FT
         ELSE
             MOVE WS-FT-PACKED TO WS-FT
         END-IF
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         MOVE 0 TO WS-LEFT
         PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
             PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
                 CALL "FL-GET-STATE" USING WS-X WS-PLANE WS-Z WS-STATE
                 IF WS-STATE NOT = WS-S-SNOW
                     ADD 1 TO WS-LEFT
                 END-IF
             END-PERFORM
         END-PERFORM
         ADD WS-LEFT TO WS-REMOVED
     END-PERFORM
     MOVE "covB 35-5 9 over 300 seeds some snow layer on the cut level is removed or built over" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-REMOVED > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     STOP RUN.
 COPY FWTEST.
 END PROGRAM TEST-COVB-ICEBERG.
 COPY NOSPAWN.
 COPY CORETEST.
