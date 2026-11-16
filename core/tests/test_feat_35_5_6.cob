*> Implementation test of forest rock, the block_blob feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 6; core/src/feat-blob.cob): the data feature compiles (type 1;
*> an unknown block or a missing can_place_on makes it unsupported); the origin walks down to the first position whose block below is a can_place_on block; no ground above minY + 3 gives
*> false and writes nothing; otherwise three blobs are drawn (rx, ry, rz of nextInt(2), then the move x, y, z) and every cell of the box with squared distance at most f * f, f = (rx + ry + rz) * 0.333 + 0.5,
*> becomes mossy cobblestone, cell by cell against an independent model (a second random source, floats for f); the worked examples (19 cells for 1 1 1, one cell for 0 0 0) are checked on the model.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-6.
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
 01 WS-A                   PIC X(304640) BASED.
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
    05 WS-MODEL-CELL       PIC 9 OCCURS 4096 TIMES.
 01 WS-MIDX                BINARY-LONG.
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
     MOVE "mossy_cobblestone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-MOSSY

     MOVE "minecraft:forest_rock" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§6: the data feature forest_rock compiles as a block_blob (1)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   ground: the top dirt block at y 63, the origin 70 walks down to 64
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 12
         COMPUTE WS-SEED = WS-SEEDNO * 7919
         MOVE WS-SEEDNO TO WS-SEEDTXT
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 70 TO WS-Y
         MOVE 40 TO WS-Z
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM BUILD-MODEL
         PERFORM COMPARE-MODEL
         MOVE SPACES TO WS-CASE
         STRING "35-5§6: seed " WS-SEEDTXT " the blobs equal the model, cell by cell" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§6: seed " WS-SEEDTXT " returns true and the random state equals the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 10000 + WS-OBS
         COMPUTE WS-EXP = 10000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM

*>   worked examples on the model: 1 1 1 keeps 19 cells, 0 0 0 one cell
     MOVE 1 TO WS-RX WS-RY WS-RZ
     PERFORM COUNT-BLOB
     MOVE "35-5§6: worked example rx = ry = rz = 1 has 19 cells" TO WS-CASE
     MOVE WS-CELLS TO WS-OBS
     MOVE 19 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-RX WS-RY WS-RZ
     PERFORM COUNT-BLOB
     MOVE "35-5§6: worked example rx = ry = rz = 0 has one cell" TO WS-CASE
     MOVE WS-CELLS TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   no ground: false, nothing written
     PERFORM NEW-WORLD
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 40 TO WS-Y0
     MOVE 120 TO WS-Y1
     MOVE "air" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 0 TO FL-WRITES
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§6: no can_place_on block below minY + 3 gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§6: and writes nothing" TO WS-CASE
     MOVE FL-WRITES TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

     MOVE "minecraft:forest_rock_bad" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§6: an unknown block makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:forest_rock_nopred" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§6: a missing can_place_on makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:forest_rock_str" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§6: a state given as a plain string and a solid predicate compile as a block_blob" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:forest_rock_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§6: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:forest_rock" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§6: the gate admits the forest_rock placed feature" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
*> COUNT-BLOB: WS-CELLS = cells of a blob of radii WS-RX, WS-RY, WS-RZ by the document's rule (floats)
 COUNT-BLOB.
     COMPUTE WS-F = (WS-RX + WS-RY + WS-RZ) * 0.333 + 0.5
     COMPUTE WS-FF = WS-F * WS-F
     COMPUTE WS-LX = 0 - WS-RX
     COMPUTE WS-LY = 0 - WS-RY
     COMPUTE WS-LZ = 0 - WS-RZ
     MOVE 0 TO WS-CELLS
     PERFORM VARYING WS-CX2 FROM WS-LX BY 1 UNTIL WS-CX2 > WS-RX
         PERFORM VARYING WS-CY2 FROM WS-LY BY 1 UNTIL WS-CY2 > WS-RY
             PERFORM VARYING WS-CZ2 FROM WS-LZ BY 1 UNTIL WS-CZ2 > WS-RZ
                 COMPUTE WS-D2 = WS-CX2 * WS-CX2 + WS-CY2 * WS-CY2 + WS-CZ2 * WS-CZ2
                 IF WS-D2 <= WS-FF
                     ADD 1 TO WS-CELLS
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> BUILD-MODEL: replay the draws on the second source; WS-MODEL-CELL(index of x 16..31, y 60..75 as 0..15, z 32..47) = 1 for a blob cell
 BUILD-MODEL.
     MOVE ALL "0" TO WS-MODEL
     MOVE WS-X TO WS-MPX
     MOVE 64 TO WS-MPY
     MOVE WS-Z TO WS-MPZ
     PERFORM 3 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-RX
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-RY
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-RZ
         COMPUTE WS-F = (WS-RX + WS-RY + WS-RZ) * 0.333 + 0.5
         COMPUTE WS-FF = WS-F * WS-F
         COMPUTE WS-LX = 0 - WS-RX
         COMPUTE WS-LY = 0 - WS-RY
         COMPUTE WS-LZ = 0 - WS-RZ
         PERFORM VARYING WS-CX2 FROM WS-LX BY 1 UNTIL WS-CX2 > WS-RX
             PERFORM VARYING WS-CY2 FROM WS-LY BY 1 UNTIL WS-CY2 > WS-RY
                 PERFORM VARYING WS-CZ2 FROM WS-LZ BY 1 UNTIL WS-CZ2 > WS-RZ
                     COMPUTE WS-D2 = WS-CX2 * WS-CX2 + WS-CY2 * WS-CY2 + WS-CZ2 * WS-CZ2
                     IF WS-D2 <= WS-FF
                         COMPUTE WS-MIDX = (WS-MPY + WS-CY2 - 60) * 256 + (WS-MPZ + WS-CZ2 - 32) * 16 + (WS-MPX + WS-CX2 - 16) + 1
                         MOVE 1 TO WS-MODEL-CELL(WS-MIDX)
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-DRAW
         COMPUTE WS-MPX = WS-MPX - 1 + WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-DRAW
         COMPUTE WS-MPY = WS-MPY - WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-DRAW
         COMPUTE WS-MPZ = WS-MPZ - 1 + WS-DRAW
     END-PERFORM
     .
 COMPARE-MODEL.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 60 BY 1 UNTIL WS-Y > 75
                 COMPUTE WS-MIDX = (WS-Y - 60) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-MODEL-CELL(WS-MIDX) = 1
                     IF WS-STATE NOT = WS-S-MOSSY
                         ADD 1 TO WS-BAD
                     END-IF
                 ELSE
                     IF WS-STATE = WS-S-MOSSY
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone to y 59, dirt 60 to 63 air above; both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 40 TO WS-Y0
     MOVE 59 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 60 TO WS-Y0
     MOVE 63 TO WS-Y1
     MOVE "dirt" TO WS-KEY
     PERFORM FILL-BOX
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-6.
 COPY CORETEST.
