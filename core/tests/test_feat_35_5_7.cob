*> Implementation test of replace blobs, netherrack_replace_blobs (docs/protocol/35-worldgen-features-5-water-and-surface.md section 7; core/src/feat-blob.cob): the data feature compiles (type 29; an unknown
*> target or a missing radius makes it unsupported); the origin y is clamped to [minY + 1, maxY] and walks down to the first target block (the cell at minY + 1 is never tested); three radius draws, m = max,
*> every target cell of the box within Manhattan distance m of the hit takes the state; compared cell by cell with an independent model with a second random source.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-7.
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

 01 WS-M                   BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-B-NETH              BINARY-LONG.
 01 WS-S-BAS               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-HITY                BINARY-LONG.
 01 WS-ORIG-STATE          BINARY-LONG.
 01 WS-ORIG-TABLE.
    05 WS-OS               BINARY-LONG OCCURS 12288 TIMES.
 01 WS-B8                  BINARY-LONG VALUE 5.
 01 WS-STARTY              BINARY-LONG.
 01 WS-MODEL-RESULT        BINARY-LONG.
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
     MOVE "netherrack" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-NETH
     MOVE "basalt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-BAS
     MOVE "minecraft:rb_basalt" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§7: the data feature compiles as netherrack_replace_blobs (29)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 29 TO WS-EXP
     PERFORM ASSERT-N

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 10
         COMPUTE WS-SEED = WS-SEEDNO * 7717
         MOVE WS-SEEDNO TO WS-SEEDTXT
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 40 TO WS-Z
         MOVE 45 TO WS-Y
         MOVE 45 TO WS-STARTY
         IF WS-SEEDNO > 5
             MOVE 90 TO WS-Y
             MOVE 90 TO WS-STARTY
         END-IF
         IF WS-SEEDNO > 8
             MOVE 500 TO WS-Y
             MOVE 500 TO WS-STARTY
         END-IF
         PERFORM SAVE-WORLD
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM MODEL-RUN
         MOVE SPACES TO WS-CASE
         STRING "35-5§7: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§7: seed " WS-SEEDTXT " some cells changed, the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000000 + WS-EXP
         IF WS-CHANGED < 5
             ADD 1 TO WS-OBS
         END-IF
         PERFORM ASSERT-N
     END-PERFORM

*>   no target: false, no draw; y below minY + 1: false
     MOVE 5 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 20 TO WS-Y0
     MOVE 60 TO WS-Y1
     MOVE "air" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 24 TO WS-X
     MOVE 40 TO WS-Z
     MOVE 45 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§7: no target block in the column gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM NEW-WORLD
     MOVE -100 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§7: y clamped to minY + 1 never tests that cell: false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

     MOVE "minecraft:rb_bad" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§7: an unknown target makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:rb_noradius" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§7: a missing radius makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:rb_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§7: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:basalt_blobs" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§7: the gate admits basalt_blobs" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:blackstone_blobs" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§7: the gate admits blackstone_blobs" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     PERFORM ASSERT-N
     STOP RUN
     .
 SAVE-WORLD.
     PERFORM VARYING WS-Y0 FROM 0 BY 1 UNTIL WS-Y0 > 47
         PERFORM VARYING WS-Z0 FROM 32 BY 1 UNTIL WS-Z0 > 47
             PERFORM VARYING WS-X0 FROM 16 BY 1 UNTIL WS-X0 > 31
                 COMPUTE WS-MIDX = WS-Y0 * 256 + (WS-Z0 - 32) * 16 + (WS-X0 - 16) + 1
                 COMPUTE WS-LY = WS-Y0 + 20
                 CALL "FL-GET-STATE" USING WS-X0 WS-LY WS-Z0 WS-STATE
                 MOVE WS-STATE TO WS-OS(WS-MIDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> MODEL-RUN: the model on a second random source over the saved states (y 20 to 67); sets WS-BAD, WS-CHANGED, WS-MODEL-RESULT
 MODEL-RUN.
     MOVE 0 TO WS-BAD WS-CHANGED WS-MODEL-RESULT
     MOVE WS-STARTY TO WS-HITY
     IF WS-HITY > 319
         MOVE 319 TO WS-HITY
     END-IF
     PERFORM UNTIL WS-HITY <= -63
         IF WS-HITY < 20 OR WS-HITY > 67
             MOVE 0 TO WS-ORIG-STATE
         ELSE
             COMPUTE WS-MIDX = (WS-HITY - 20) * 256 + 8 * 16 + 8 + 1
             MOVE WS-OS(WS-MIDX) TO WS-ORIG-STATE
         END-IF
         CALL "FL-BLOCK-OF" USING WS-ORIG-STATE WS-BLOCK
         IF WS-BLOCK = WS-B-NETH
             EXIT PERFORM
         END-IF
         SUBTRACT 1 FROM WS-HITY
     END-PERFORM
     IF WS-HITY <= -63
         EXIT PARAGRAPH
     END-IF
     MOVE 5 TO WS-B8
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B8 WS-RX
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B8 WS-RY
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B8 WS-RZ
     ADD 3 TO WS-RX WS-RY WS-RZ
     MOVE WS-RX TO WS-M
     IF WS-RY > WS-M
         MOVE WS-RY TO WS-M
     END-IF
     IF WS-RZ > WS-M
         MOVE WS-RZ TO WS-M
     END-IF
     PERFORM VARYING WS-X0 FROM 16 BY 1 UNTIL WS-X0 > 31
         PERFORM VARYING WS-Z0 FROM 32 BY 1 UNTIL WS-Z0 > 47
             PERFORM VARYING WS-Y0 FROM 20 BY 1 UNTIL WS-Y0 > 67
                 COMPUTE WS-MIDX = (WS-Y0 - 20) * 256 + (WS-Z0 - 32) * 16 + (WS-X0 - 16) + 1
                 MOVE WS-OS(WS-MIDX) TO WS-WANT
                 CALL "FL-BLOCK-OF" USING WS-WANT WS-BLOCK
                 COMPUTE WS-DX = FUNCTION ABS(WS-X0 - 24)
                 COMPUTE WS-DY = FUNCTION ABS(WS-Y0 - WS-HITY)
                 COMPUTE WS-DZ = FUNCTION ABS(WS-Z0 - 40)
                 IF WS-DX <= WS-RX AND WS-DY <= WS-RY AND WS-DZ <= WS-RZ AND WS-DX + WS-DY + WS-DZ <= WS-M AND WS-BLOCK = WS-B-NETH
                     MOVE WS-S-BAS TO WS-WANT
                     MOVE 1 TO WS-MODEL-RESULT
                 END-IF
                 CALL "FL-GET-STATE" USING WS-X0 WS-Y0 WS-Z0 WS-STATE
                 IF WS-STATE NOT = WS-WANT
                     ADD 1 TO WS-BAD
                 END-IF
                 IF WS-STATE NOT = WS-OS(WS-MIDX)
                     ADD 1 TO WS-CHANGED
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): netherrack from y 20 to 60 (a stone cell stays at (24, 50, 40) to cut the blob), air above; both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 20 TO WS-Y0
     MOVE 60 TO WS-Y1
     MOVE "netherrack" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 24 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-7.
 COPY CORETEST.
