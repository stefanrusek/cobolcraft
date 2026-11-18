*> Implementation test of the End and void features as data-driven types (docs/protocol/35-worldgen-features-7-nether-end-misc.md sections 8, 9, 10; core/src/feat-end.cob, registry ids 15, 6, 12, 13, 11, 55):
*> the data features compile (a custom spike list, a missing list, a gateway without a boolean exact make it unsupported) and, for two seeds each, FR-PLACE-FT writes exactly the cells, and leaves exactly the
*> random state, that the engine of end-38c.cob (END-SPIKE-PLACE, END-CHORUS-PLACE, END-ISLAND-PLACE, END-PLATFORM-PLACE, END-GATEWAY-PLACE) does when called directly with the same seed (those engines are
*> checked against the document's numbers by test_end_38_8.cob). void_start_platform (10.5) is checked against the cell counts the section gives: chunk (0, 0) 255 stone and one cobblestone at (8, 3, 8),
*> chunk (1, 0) 9 columns of 16 within distance 16 of the centre, chunk (-1, 0) 8 columns, chunk (2, 0) and chunk (0, -2) nothing, and the y of the platform is origin.y + 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-7-END.
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
 COPY STRUCTDATA.
 COPY ENDSPIKE.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/endfeat".
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
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MIN                 BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-WSEED               BINARY-DOUBLE.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-CASENO              BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-DIGITS              PIC 99.
 01 WS-RUNTXT              PIC 9.
 01 WS-CASETXT             PIC 9.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-SNAP.
    05 WS-OS               BINARY-LONG OCCURS 32768 TIMES.
 01 WS-S-ENDSTONE          BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-COBBLE            BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-DROP                BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-N-STONE             BINARY-LONG.
 01 WS-N-COBBLE            BINARY-LONG.
 01 WS-N-OTHER             BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-FILL                BINARY-LONG VALUE 1.
 01 WS-XLO                 BINARY-LONG.
 01 WS-XHI                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-ZHI                 BINARY-LONG.
 01 WS-CHUNKS.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE 255.
    05 FILLER              PIC S9(3) VALUE 1.
    05 FILLER              PIC S9(3) VALUE 1.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE 144.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE -1.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE 128.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE 2.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE -2.
    05 FILLER              PIC S9(3) VALUE 0.
    05 FILLER              PIC S9(3) VALUE 0.
 01 WS-CHUNK-TABLE REDEFINES WS-CHUNKS.
    05 WS-CHK OCCURS 5 TIMES.
       10 WS-CHK-X         PIC S9(3).
       10 WS-CHK-Z         PIC S9(3).
       10 WS-CHK-STONE     PIC S9(3).
       10 WS-CHK-COBBLE    PIC S9(3).
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
     MOVE "end_stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-ENDSTONE
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "cobblestone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-COBBLE
     MOVE CW-SEED TO WS-WSEED

*>   compile: ids and the unsupported shapes
     PERFORM VARYING WS-CASENO FROM 1 BY 1 UNTIL WS-CASENO > 10
         EVALUATE WS-CASENO
             WHEN 1
                 MOVE "minecraft:spike_t" TO WS-FTKEY
                 MOVE 15 TO WS-EXP
                 MOVE "an end_spike with an empty list" TO WS-NAME
             WHEN 2
                 MOVE "minecraft:chorus_t" TO WS-FTKEY
                 MOVE 6 TO WS-EXP
                 MOVE "a chorus_plant" TO WS-NAME
             WHEN 3
                 MOVE "minecraft:island_t" TO WS-FTKEY
                 MOVE 12 TO WS-EXP
                 MOVE "an end_island" TO WS-NAME
             WHEN 4
                 MOVE "minecraft:platform_t" TO WS-FTKEY
                 MOVE 13 TO WS-EXP
                 MOVE "an end_platform" TO WS-NAME
             WHEN 5
                 MOVE "minecraft:gate_t" TO WS-FTKEY
                 MOVE 11 TO WS-EXP
                 MOVE "an end_gateway with exact and exit" TO WS-NAME
             WHEN 6
                 MOVE "minecraft:void_t" TO WS-FTKEY
                 MOVE 55 TO WS-EXP
                 MOVE "a void_start_platform" TO WS-NAME
             WHEN 7
                 MOVE "minecraft:spike_custom" TO WS-FTKEY
                 MOVE -1 TO WS-EXP
                 MOVE "a custom spike list (unsupported)" TO WS-NAME
             WHEN 8
                 MOVE "minecraft:spike_nolist" TO WS-FTKEY
                 MOVE -1 TO WS-EXP
                 MOVE "an end_spike without a list (unsupported)" TO WS-NAME
             WHEN 9
                 MOVE "minecraft:gate_noexact" TO WS-FTKEY
                 MOVE -1 TO WS-EXP
                 MOVE "an end_gateway without exact (unsupported)" TO WS-NAME
             WHEN OTHER
                 MOVE "minecraft:gate_badexact" TO WS-FTKEY
                 MOVE -1 TO WS-EXP
                 MOVE "a gateway with a numeric exact (unsupported)" TO WS-NAME
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-FTKEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-7§8-10: " FUNCTION TRIM(WS-NAME) " compiles to its type" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         PERFORM ASSERT-N
     END-PERFORM

*>   the data path equals the engine: cases 1 island, 2 platform, 3 gateway, 4 chorus plant, 5 end spike (chunk (2, 0): the centre (42, 0) of the first spike), two seeds each
     PERFORM VARYING WS-CASENO FROM 1 BY 1 UNTIL WS-CASENO > 5
         PERFORM VARYING WS-RUN FROM 1 BY 1 UNTIL WS-RUN > 2
             COMPUTE WS-SEED = WS-CASENO * 100 + WS-RUN * 7
             EVALUATE WS-CASENO
                 WHEN 1
                     MOVE "minecraft:island_t" TO WS-FTKEY
                     MOVE 1 TO WS-CX
                     MOVE 2 TO WS-CZ
                     MOVE 24 TO WS-X
                     MOVE 70 TO WS-Y
                     MOVE 40 TO WS-Z
                 WHEN 2
                     MOVE "minecraft:platform_t" TO WS-FTKEY
                     MOVE 6 TO WS-CX
                     MOVE 0 TO WS-CZ
                     MOVE 100 TO WS-X
                     MOVE 49 TO WS-Y
                     MOVE 0 TO WS-Z
                 WHEN 3
                     MOVE "minecraft:gate_t" TO WS-FTKEY
                     MOVE 1 TO WS-CX
                     MOVE 2 TO WS-CZ
                     MOVE 24 TO WS-X
                     MOVE 70 TO WS-Y
                     MOVE 40 TO WS-Z
                 WHEN 4
                     MOVE "minecraft:chorus_t" TO WS-FTKEY
                     MOVE 1 TO WS-CX
                     MOVE 2 TO WS-CZ
                     MOVE 24 TO WS-X
                     MOVE 61 TO WS-Y
                     MOVE 40 TO WS-Z
                 WHEN OTHER
                     MOVE "minecraft:spike_t" TO WS-FTKEY
                     MOVE 2 TO WS-CX
                     MOVE 0 TO WS-CZ
                     MOVE 32 TO WS-X
                     MOVE 0 TO WS-Y
                     MOVE 0 TO WS-Z
             END-EVALUATE
             CALL "FD-GET-FT" USING WS-FTKEY WS-FT
             CALL "FD-ENSURE-FT" USING WS-FT
             PERFORM NEW-WORLD
             CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
             MOVE 1000 TO WS-DRAW
             CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-FIRST
             PERFORM SAVE-WORLD
             PERFORM NEW-WORLD
             PERFORM ENGINE-RUN
             PERFORM COMPARE-WORLD
             MOVE SPACES TO WS-CASE
             MOVE WS-CASENO TO WS-DIGITS
             MOVE WS-RUN TO WS-RUNTXT
             STRING "35-7§8-10: case " WS-DIGITS " run " WS-RUNTXT " the cells equal the engine's" DELIMITED BY SIZE INTO WS-CASE
             MOVE WS-BAD TO WS-OBS
             MOVE 0 TO WS-EXP
             PERFORM ASSERT-N
             MOVE SPACES TO WS-CASE
             STRING "35-7§8-10: case " WS-DIGITS " run " WS-RUNTXT " the engine changed the world and the random state equals" DELIMITED BY SIZE INTO WS-CASE
             MOVE 1000 TO WS-DRAW
             MOVE WS-FIRST TO WS-OBS
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
             ADD 1000 TO WS-EXP
             IF WS-CHANGED > 0
                 ADD 1000 TO WS-OBS
             END-IF
             PERFORM ASSERT-N
         END-PERFORM
     END-PERFORM

*>   void_start_platform (10.5): the cell counts of the section
     MOVE "minecraft:void_t" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE 0 TO WS-FILL
     PERFORM VARYING WS-CASENO FROM 1 BY 1 UNTIL WS-CASENO > 5
         MOVE WS-CHK-X(WS-CASENO) TO WS-CX
         MOVE WS-CHK-Z(WS-CASENO) TO WS-CZ
         MOVE 0 TO WS-SEED
         PERFORM NEW-WORLD
         COMPUTE WS-X = WS-CX * 16
         COMPUTE WS-Z = WS-CZ * 16
         MOVE 20 TO WS-Y
         MOVE WS-Y TO WS-OY
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         MOVE 0 TO WS-N-STONE WS-N-COBBLE WS-N-OTHER
         PERFORM VARYING WS-QZ FROM WS-ZLO BY 1 UNTIL WS-QZ > WS-ZHI
             PERFORM VARYING WS-QX FROM WS-XLO BY 1 UNTIL WS-QX > WS-XHI
                 PERFORM VARYING WS-QY FROM 0 BY 1 UNTIL WS-QY > 40
                     CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                     EVALUATE TRUE
                         WHEN WS-QY = WS-OY + 3 AND WS-STATE = WS-S-STONE
                             ADD 1 TO WS-N-STONE
                         WHEN WS-QY = WS-OY + 3 AND WS-STATE = WS-S-COBBLE
                             ADD 1 TO WS-N-COBBLE
                             IF WS-QX NOT = 8 OR WS-QZ NOT = 8
                                 ADD 1 TO WS-N-OTHER
                             END-IF
                         WHEN WS-STATE NOT = 0
                             ADD 1 TO WS-N-OTHER
                     END-EVALUATE
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         MOVE WS-CASENO TO WS-CASETXT
         MOVE SPACES TO WS-CASE
         STRING "35-7§10.5: void platform chunk " WS-CASETXT " stone count" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-N-STONE TO WS-OBS
         MOVE WS-CHK-STONE(WS-CASENO) TO WS-EXP
         PERFORM ASSERT-N
         MOVE WS-CASENO TO WS-CASETXT
         MOVE SPACES TO WS-CASE
         STRING "35-7§10.5: void platform chunk " WS-CASETXT " cobblestone count" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-N-COBBLE TO WS-OBS
         MOVE WS-CHK-COBBLE(WS-CASENO) TO WS-EXP
         PERFORM ASSERT-N
         MOVE WS-CASENO TO WS-CASETXT
         MOVE SPACES TO WS-CASE
         STRING "35-7§10.5: void platform chunk " WS-CASETXT " writes nothing else" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-N-OTHER TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     STOP RUN
     .
 SET-BOUNDS.
     COMPUTE WS-XLO = WS-CX * 16
     COMPUTE WS-XHI = WS-XLO + 15
     COMPUTE WS-ZLO = WS-CZ * 16
     COMPUTE WS-ZHI = WS-ZLO + 15
     .
 ENGINE-RUN.
     EVALUATE WS-CASENO
         WHEN 1
             CALL "END-ISLAND-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z XR2-STATE
         WHEN 2
             CALL "END-PLATFORM-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-DROP WS-DROPPED
         WHEN 3
             CALL "END-GATEWAY-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z
         WHEN 4
             CALL "END-CHORUS-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z XR2-STATE WS-RESULT
         WHEN OTHER
             CALL "END-SPIKE-PLACE" USING WS-MODE WS-DIM WS-X WS-Z WS-WSEED XR2-STATE CRYSTAL-LIST
     END-EVALUATE
     .
 SAVE-WORLD.
     PERFORM SET-BOUNDS
     MOVE 0 TO WS-IDX
     PERFORM VARYING WS-QZ FROM WS-ZLO BY 1 UNTIL WS-QZ > WS-ZHI
         PERFORM VARYING WS-QX FROM WS-XLO BY 1 UNTIL WS-QX > WS-XHI
             PERFORM VARYING WS-QY FROM 0 BY 1 UNTIL WS-QY > 127
                 ADD 1 TO WS-IDX
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 MOVE WS-STATE TO WS-OS(WS-IDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COMPARE-WORLD.
     PERFORM SET-BOUNDS
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-CHANGED
     MOVE 0 TO WS-IDX
     PERFORM VARYING WS-QZ FROM WS-ZLO BY 1 UNTIL WS-QZ > WS-ZHI
         PERFORM VARYING WS-QX FROM WS-XLO BY 1 UNTIL WS-QX > WS-XHI
             PERFORM VARYING WS-QY FROM 0 BY 1 UNTIL WS-QY > 127
                 ADD 1 TO WS-IDX
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 IF WS-STATE NOT = WS-OS(WS-IDX)
                     ADD 1 TO WS-BAD
                 END-IF
                 IF WS-QY <= 60
                     MOVE WS-S-ENDSTONE TO WS-WANT
                 ELSE
                     MOVE 0 TO WS-WANT
                 END-IF
                 IF WS-STATE NOT = WS-WANT
                     ADD 1 TO WS-CHANGED
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: the chunk (WS-CX, WS-CZ) of the End level (min y 0, 256 high): end stone up to y 60, air above; both random sources seeded
 NEW-WORLD.
     PERFORM SET-BOUNDS
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     IF WS-FILL = 1
         PERFORM VARYING WS-QX FROM WS-XLO BY 1 UNTIL WS-QX > WS-XHI
             PERFORM VARYING WS-QY FROM 0 BY 1 UNTIL WS-QY > 60
                 PERFORM VARYING WS-QZ FROM WS-ZLO BY 1 UNTIL WS-QZ > WS-ZHI
                     CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-S-ENDSTONE WS-FLAGS WS-OK
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-7-END.
 COPY NOSPAWN.
 COPY CORETEST.
