*> Implementation test of fill layer (docs/protocol/35-worldgen-features-5-water-and-surface.md section 11; core/src/feat-fill.cob): the data features compile (type 17; an unknown state or a missing
*> height makes it unsupported); placed at a chunk corner it turns every air block of the 16 x 16 layer y = minY + height into the state and leaves other blocks, returns true, and makes no draw.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-11.
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
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/water".
 01 WS-PTR                 USAGE POINTER.
 01 WS-AREA                PIC X(304640) BASED.
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
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 2.
 01 WS-DRAW                BINARY-LONG.
 01 WS-S-MOSSY             BINARY-LONG.
 01 WS-SEEDNO              BINARY-LONG.
 01 WS-SEEDTXT             PIC 99.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-ORIGIN-Y            BINARY-LONG.
 01 WS-MPX                 BINARY-LONG.
 01 WS-MPY                 BINARY-LONG.
 01 WS-MPZ                 BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-REP                 BINARY-LONG.
 01 WS-CX2                 BINARY-LONG.
 01 WS-CY2                 BINARY-LONG.
 01 WS-CZ2                 BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-FF                  FLOAT-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-OBSERVED-CELLS      BINARY-LONG.
 01 WS-MODEL.
    05 WS-MODEL-CELL       PIC 9 OCCURS 6144 TIMES.

 01 WS-S-GLASS             BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
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
     MOVE "glass" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GLASS
     MOVE "minecraft:fill_glass" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§11: the data feature compiles as a fill_layer (17)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 17 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM NEW-WORLD
     MOVE 16 TO WS-X
     MOVE 0 TO WS-Y
     MOVE 32 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§11: it returns true" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-BAD WS-CHANGED
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             MOVE 6 TO WS-Y
             CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
             IF WS-X = 20 AND WS-Z = 33
                 IF WS-STATE NOT = WS-S-STONE
                     ADD 1 TO WS-BAD
                 END-IF
             ELSE
                 IF WS-STATE NOT = WS-S-GLASS
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
             MOVE 7 TO WS-Y
             CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE NOT = 0
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "35-5§11: every air cell of the layer y = -64 + 70 became glass, the stone cell and the layer above did not" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1000 TO WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
     MOVE "35-5§11: no random draw was made" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:fill_bad" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§11: an unknown state makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:fill_noheight" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§11: a missing height makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:fill_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§11: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
*> NEW-WORLD: chunk (1, 2): stone to y 5 (layer y = -64 + 70 = 6 is air except one stone cell at (20, 6, 33)); both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE -10 TO WS-Y0
     MOVE 5 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 20 TO WS-X
     MOVE 6 TO WS-Y
     MOVE 33 TO WS-Z
     PERFORM PUT-AT
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-S-STONE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-11.
 COPY NOSPAWN.
 COPY CORETEST.
