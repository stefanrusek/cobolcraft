*> Implementation test of the coral features, types coral_tree and coral_claw (docs/protocol/35-worldgen-features-5-water-and-surface.md section 14; core/src/feat-coral.cob): the data features compile
*> (types 8 and 7; a missing placed feature makes one unsupported), the gate-free runs equal an independent model over 40 seeds on a shadow array with a second random source: the tree (stem, the
*> shuffle of the four directions, branches that rise and bend after the first block or on nextFloat() < 0.25), the claw (d0, the shuffled claws, the two length loops), the early end of a tree
*> (reported as success) and the claw that fails at once (no draw). The placed feature of the fixtures is a simple_block of a coral block behind the section 14.3 predicate (water or the coral
*> block here, water above); obstacles of stone scattered in the water make the placements fail at varied places.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-14.
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
 01 WS-FT-TREE             BINARY-LONG.
 01 WS-FT-CLAW             BINARY-LONG.
 01 WS-CUR-FT              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
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
 01 WS-DRAW                BINARY-LONG.
 01 WS-SEEDNO              BINARY-LONG.
 01 WS-SEEDTXT             PIC 99.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-MIDX                BINARY-LONG.
 01 WS-SH.
    05 WS-OS               BINARY-LONG OCCURS 10496 TIMES.
 01 WS-S-BRAIN             BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-WATER             BINARY-LONG.
 01 WS-S-TUBE              BINARY-LONG.
 01 WS-S-CORAL             BINARY-LONG.
 01 WS-B-WATER             BINARY-LONG.
 01 WS-B-BRAIN             BINARY-LONG.
 01 WS-B-TUBE              BINARY-LONG.
 01 WS-B-CORAL             BINARY-LONG.
 01 WS-N-PLACED            BINARY-LONG VALUE 0.
 01 WS-N-BLOCKS            BINARY-LONG VALUE 0.
 01 WS-N-SHORT             BINARY-LONG VALUE 0.
 01 WS-N-FAIL              BINARY-LONG VALUE 0.
 01 WS-LCG                 BINARY-DOUBLE.
 01 WS-K                   BINARY-LONG.
 01 WS-MODEL-RESULT        BINARY-LONG.
*> model state
 01 M-CX                   BINARY-LONG.
 01 M-CY                   BINARY-LONG.
 01 M-CZ                   BINARY-LONG.
 01 M-TX                   BINARY-LONG.
 01 M-TY                   BINARY-LONG.
 01 M-TZ                   BINARY-LONG.
 01 M-OK                   BINARY-LONG.
 01 M-ST                   BINARY-LONG.
 01 M-BL                   BINARY-LONG.
 01 M-QX                   BINARY-LONG.
 01 M-QY                   BINARY-LONG.
 01 M-QZ                   BINARY-LONG.
 01 M-STEM                 BINARY-LONG.
 01 M-BRANCHES             BINARY-LONG.
 01 M-LEN                  BINARY-LONG.
 01 M-PLACED               BINARY-LONG.
 01 M-I                    BINARY-LONG.
 01 M-J                    BINARY-LONG.
 01 M-D                    BINARY-LONG.
 01 M-D0                   BINARY-LONG.
 01 M-D2                   BINARY-LONG.
 01 M-STOP                 BINARY-LONG.
 01 M-DR                   BINARY-LONG.
 01 M-B2                   BINARY-LONG VALUE 2.
 01 M-B3                   BINARY-LONG VALUE 3.
 01 M-B4                   BINARY-LONG VALUE 4.
 01 M-B5                   BINARY-LONG VALUE 5.
 01 M-F                    FLOAT-LONG.
 01 M-QUARTER              FLOAT-LONG VALUE 0.25.
 01 M-LEN1                 BINARY-LONG.
 01 M-LEN2                 BINARY-LONG.
 01 M-NCLAWS               BINARY-LONG.
 01 M-SWAP                 BINARY-LONG.
 01 M-DIRS.
    05 M-DIR               BINARY-LONG OCCURS 4 TIMES.
 01 M-LIST.
    05 M-L                 BINARY-LONG OCCURS 3 TIMES.
*> N, E, S, W as dx / dz, in this order
 01 M-DXS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
 01 M-DX-TAB REDEFINES M-DXS.
    05 M-DX                BINARY-LONG OCCURS 4 TIMES.
 01 M-DZS.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 M-DZ-TAB REDEFINES M-DZS.
    05 M-DZ                BINARY-LONG OCCURS 4 TIMES.
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
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-WATER
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "brain_coral_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BRAIN
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-BRAIN
     MOVE "tube_coral_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-TUBE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-TUBE
     MOVE "minecraft:coral_tree_t" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-TREE
     CALL "FD-ENSURE-FT" USING WS-FT-TREE
     MOVE "minecraft:coral_claw_t" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-CLAW
     CALL "FD-ENSURE-FT" USING WS-FT-CLAW
     MOVE "35-5§14: the data feature compiles as a coral_tree (8)" TO WS-CASE
     MOVE FT-TYPE(WS-FT-TREE) TO WS-OBS
     MOVE 8 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§14: the data feature compiles as a coral_claw (7)" TO WS-CASE
     MOVE FT-TYPE(WS-FT-CLAW) TO WS-OBS
     MOVE 7 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§14: the coral block exists in the block table" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-B-BRAIN > 0 AND WS-B-TUBE > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

     MOVE 17 TO WS-LCG
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 40
         COMPUTE WS-SEED = WS-SEEDNO * 6007
         MOVE WS-SEEDNO TO WS-SEEDTXT
         IF FUNCTION MOD(WS-SEEDNO, 2) = 0
             MOVE WS-FT-CLAW TO WS-CUR-FT
             MOVE WS-S-TUBE TO WS-S-CORAL
             MOVE WS-B-TUBE TO WS-B-CORAL
         ELSE
             MOVE WS-FT-TREE TO WS-CUR-FT
             MOVE WS-S-BRAIN TO WS-S-CORAL
             MOVE WS-B-BRAIN TO WS-B-CORAL
         END-IF
         PERFORM NEW-WORLD
         PERFORM SCATTER-STONE
         IF FUNCTION MOD(WS-SEEDNO, 7) = 0
             MOVE 24 TO WS-X
             MOVE 46 TO WS-Y
             MOVE 40 TO WS-Z
             MOVE "stone" TO WS-KEY
             PERFORM PUT-AT
         END-IF
         MOVE 24 TO WS-X
         MOVE 46 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM SAVE-WORLD
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-CUR-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-WORLD
         MOVE SPACES TO WS-CASE
         STRING "35-5§14: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§14: seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-5§14: the runs placed coral blocks" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-BLOCKS > 300
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§14: a tree ended early by a failing placement" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-SHORT > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "35-5§14: a claw failed at once" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-FAIL > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N

*>   a claw whose first placement fails gives false and draws nothing (stone at the origin)
     MOVE 3 TO WS-SEEDNO
     MOVE WS-FT-CLAW TO WS-CUR-FT
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 46 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     CALL "FR-PLACE-FT" USING XR-STATE WS-CUR-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§14: a claw whose placement fails gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1000 TO WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
     MOVE "35-5§14: and makes no draw" TO WS-CASE
     PERFORM ASSERT-N
*>   a tree whose first placement fails gives true (the document's early return) and draws only the stem length
     MOVE WS-FT-TREE TO WS-CUR-FT
     PERFORM NEW-WORLD
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     CALL "FR-PLACE-FT" USING XR-STATE WS-CUR-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§14: a tree whose placement fails gives true" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 WS-DRAW
     MOVE 1000 TO WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
     MOVE "35-5§14: and made exactly the stem draw" TO WS-CASE
     PERFORM ASSERT-N

     MOVE "minecraft:coral_tree_bad" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§14: a coral feature without its placed feature is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
*>   overlay (35-5 section 1.3, the form the coral blocks and their decoration take): every member from the same position, the result the OR of theirs, no draw
     MOVE "minecraft:overlay_t" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§14: the overlay compiles (32)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 32 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 5 TO WS-SEEDNO
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§14: an overlay places both members and gives true" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM BLOCK-NOW
     MOVE WS-BLOCK TO WS-OBS
     MOVE WS-B-BRAIN TO WS-EXP
     MOVE "35-5§14: the first member wrote its block at the origin" TO WS-CASE
     PERFORM ASSERT-N
     ADD 1 TO WS-X
     PERFORM BLOCK-NOW
     MOVE WS-BLOCK TO WS-OBS
     MOVE WS-B-TUBE TO WS-EXP
     MOVE "35-5§14: the second member wrote its block one east" TO WS-CASE
     PERFORM ASSERT-N
*>   the first member fails (stone at the origin), the second still runs: the result is the OR
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§14: a failing member does not stop the others" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     ADD 1 TO WS-X
     PERFORM BLOCK-NOW
     MOVE WS-BLOCK TO WS-OBS
     MOVE WS-B-TUBE TO WS-EXP
     MOVE "35-5§14: and the later member wrote its block" TO WS-CASE
     PERFORM ASSERT-N
*>   both fail: false, and no draw
     PERFORM NEW-WORLD
     MOVE 25 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     SUBTRACT 1 FROM WS-X
     PERFORM PUT-AT
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§14: an overlay whose members all fail gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1000 TO WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
     MOVE "35-5§14: and an overlay draws nothing itself" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:warm_ocean_vegetation" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§14: the gate admits warm_ocean_vegetation" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
 SAVE-WORLD.
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 80
                 COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 MOVE WS-STATE TO WS-OS(WS-MIDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COMPARE-WORLD.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 80
                 COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 IF WS-STATE NOT = WS-OS(WS-MIDX)
                     ADD 1 TO WS-BAD
                 END-IF
                 IF WS-STATE = WS-S-CORAL
                     ADD 1 TO WS-N-BLOCKS
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone to y 45, water 46 to 70, air above; both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 30 TO WS-Y0
     MOVE 45 TO WS-Y1
     MOVE WS-S-STONE TO WS-STATE
     PERFORM FILL-FAST
     MOVE 46 TO WS-Y0
     MOVE 70 TO WS-Y1
     MOVE WS-S-WATER TO WS-STATE
     PERFORM FILL-FAST
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
*> SCATTER-STONE: stone blocks in the water around the origin, 10 * (seed mod 5) of them, from a linear congruential sequence of the test
 FILL-FAST.
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
             PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 SCATTER-STONE.
     COMPUTE WS-K = FUNCTION MOD(WS-SEEDNO, 5) * 10
     PERFORM WS-K TIMES
         COMPUTE WS-LCG = FUNCTION MOD(WS-LCG * 1103515245 + 12345, 2147483648)
         COMPUTE WS-X = 21 + FUNCTION MOD(WS-LCG / 65536, 7)
         COMPUTE WS-LCG = FUNCTION MOD(WS-LCG * 1103515245 + 12345, 2147483648)
         COMPUTE WS-Y = 46 + FUNCTION MOD(WS-LCG / 65536, 9)
         COMPUTE WS-LCG = FUNCTION MOD(WS-LCG * 1103515245 + 12345, 2147483648)
         COMPUTE WS-Z = 37 + FUNCTION MOD(WS-LCG / 65536, 7)
         IF WS-X NOT = 24 OR WS-Z NOT = 40 OR WS-Y > 46
             MOVE "stone" TO WS-KEY
             PERFORM PUT-AT
         END-IF
     END-PERFORM
     .
*> ---- the model
 M-GET.
     MOVE 0 TO M-ST
     IF M-QX >= 16 AND M-QX <= 31 AND M-QZ >= 32 AND M-QZ <= 47 AND M-QY >= 40 AND M-QY <= 80
         COMPUTE WS-MIDX = (M-QY - 40) * 256 + (M-QZ - 32) * 16 + (M-QX - 16) + 1
         MOVE WS-OS(WS-MIDX) TO M-ST
     END-IF
     CALL "FL-BLOCK-OF" USING M-ST M-BL
     .
*> M-PLACE: the placed feature at (M-CX, M-CY, M-CZ): M-OK 1 when it placed the coral block (water or the coral block here, water above, a block that is not air below)
 M-PLACE.
     MOVE 0 TO M-OK
     MOVE M-CX TO M-QX
     MOVE M-CY TO M-QY
     MOVE M-CZ TO M-QZ
     PERFORM M-GET
     IF M-BL = WS-B-WATER OR M-BL = WS-B-CORAL
         COMPUTE M-QY = M-CY + 1
         PERFORM M-GET
         IF M-BL = WS-B-WATER
             COMPUTE M-QY = M-CY - 1
             PERFORM M-GET
             IF M-ST NOT = 0
                 MOVE 1 TO M-OK
                 MOVE M-CX TO M-QX
                 MOVE M-CY TO M-QY
                 MOVE M-CZ TO M-QZ
                 IF M-QX >= 16 AND M-QX <= 31 AND M-QZ >= 32 AND M-QZ <= 47 AND M-QY >= 40 AND M-QY <= 80
                     COMPUTE WS-MIDX = (M-QY - 40) * 256 + (M-QZ - 32) * 16 + (M-QX - 16) + 1
                     MOVE WS-S-CORAL TO WS-OS(WS-MIDX)
                 END-IF
             END-IF
         END-IF
     END-IF
     .
 MODEL-RUN.
     IF WS-CUR-FT = WS-FT-TREE
         PERFORM MODEL-TREE
     ELSE
         PERFORM MODEL-CLAW
     END-IF
     .
 MODEL-TREE.
     MOVE 1 TO WS-MODEL-RESULT
     MOVE WS-X TO M-CX
     MOVE WS-Y TO M-CY
     MOVE WS-Z TO M-CZ
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-STEM
     ADD 1 TO M-STEM
     MOVE 1 TO M-I
     MOVE 0 TO M-STOP
     PERFORM UNTIL M-I > M-STEM OR M-STOP = 1
         PERFORM M-PLACE
         IF M-OK = 0
             MOVE 1 TO M-STOP
             ADD 1 TO WS-N-SHORT
         ELSE
             ADD 1 TO M-CY
             ADD 1 TO M-I
         END-IF
     END-PERFORM
     IF M-STOP = 1
         EXIT PARAGRAPH
     END-IF
     MOVE M-CX TO M-TX
     MOVE M-CY TO M-TY
     MOVE M-CZ TO M-TZ
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-BRANCHES
     ADD 2 TO M-BRANCHES
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 4
         MOVE M-I TO M-DIR(M-I)
     END-PERFORM
     MOVE 4 TO M-I
     PERFORM UNTIL M-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-I M-J
         MOVE M-DIR(M-I) TO M-SWAP
         MOVE M-DIR(M-J + 1) TO M-DIR(M-I)
         MOVE M-SWAP TO M-DIR(M-J + 1)
         SUBTRACT 1 FROM M-I
     END-PERFORM
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > M-BRANCHES
         MOVE M-DIR(M-I) TO M-D
         COMPUTE M-CX = M-TX + M-DX(M-D)
         MOVE M-TY TO M-CY
         COMPUTE M-CZ = M-TZ + M-DZ(M-D)
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B5 M-LEN
         ADD 2 TO M-LEN
         MOVE 0 TO M-PLACED
         MOVE 0 TO M-J
         MOVE 0 TO M-STOP
         PERFORM UNTIL M-J >= M-LEN OR M-STOP = 1
             PERFORM M-PLACE
             IF M-OK = 0
                 MOVE 1 TO M-STOP
             ELSE
                 ADD 1 TO M-PLACED
                 ADD 1 TO M-CY
                 MOVE 0 TO M-DR
                 IF M-J = 0
                     MOVE 1 TO M-DR
                 ELSE
                     IF M-PLACED >= 2
                         CALL "WGR-NEXT-FLOAT" USING XR2-STATE M-F
                         IF M-F < M-QUARTER
                             MOVE 1 TO M-DR
                         END-IF
                     END-IF
                 END-IF
                 IF M-DR = 1
                     ADD M-DX(M-D) TO M-CX
                     ADD M-DZ(M-D) TO M-CZ
                     MOVE 0 TO M-PLACED
                 END-IF
                 ADD 1 TO M-J
             END-IF
         END-PERFORM
     END-PERFORM
     .
 MODEL-CLAW.
     MOVE 0 TO WS-MODEL-RESULT
     MOVE WS-X TO M-CX
     MOVE WS-Y TO M-CY
     MOVE WS-Z TO M-CZ
     PERFORM M-PLACE
     IF M-OK = 0
         ADD 1 TO WS-N-FAIL
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-MODEL-RESULT
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B4 M-DR
     COMPUTE M-D0 = M-DR + 1
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B2 M-NCLAWS
     ADD 2 TO M-NCLAWS
     MOVE M-D0 TO M-L(1)
*>   clockwise and counter-clockwise by the cyclic order N E S W
     IF M-D0 = 4
         MOVE 1 TO M-L(2)
     ELSE
         COMPUTE M-L(2) = M-D0 + 1
     END-IF
     IF M-D0 = 1
         MOVE 4 TO M-L(3)
     ELSE
         COMPUTE M-L(3) = M-D0 - 1
     END-IF
     MOVE 3 TO M-I
     PERFORM UNTIL M-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-I M-J
         MOVE M-L(M-I) TO M-SWAP
         MOVE M-L(M-J + 1) TO M-L(M-I)
         MOVE M-SWAP TO M-L(M-J + 1)
         SUBTRACT 1 FROM M-I
     END-PERFORM
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > M-NCLAWS
         MOVE M-L(M-I) TO M-D
         MOVE WS-X TO M-CX
         MOVE WS-Y TO M-CY
         MOVE WS-Z TO M-CZ
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B2 M-LEN1
         ADD 1 TO M-LEN1
         ADD M-DX(M-D) TO M-CX
         ADD M-DZ(M-D) TO M-CZ
         MOVE 0 TO M-DR
         IF M-D = M-D0
             MOVE M-D0 TO M-D2
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-LEN2
             ADD 2 TO M-LEN2
         ELSE
             ADD 1 TO M-CY
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B2 M-DR
             IF M-DR = 0
                 MOVE M-D TO M-D2
             ELSE
                 MOVE 0 TO M-D2
             END-IF
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-LEN2
             ADD 3 TO M-LEN2
         END-IF
*>       dir2 is a horizontal direction (1 to 4) or up (0)
         MOVE 0 TO M-J
         MOVE 0 TO M-STOP
         PERFORM UNTIL M-J >= M-LEN1 OR M-STOP = 1
             PERFORM M-PLACE
             IF M-OK = 0
                 MOVE 1 TO M-STOP
             ELSE
                 IF M-D2 = 0
                     ADD 1 TO M-CY
                 ELSE
                     ADD M-DX(M-D2) TO M-CX
                     ADD M-DZ(M-D2) TO M-CZ
                 END-IF
                 ADD 1 TO M-J
             END-IF
         END-PERFORM
         IF M-D2 = 0
             SUBTRACT 1 FROM M-CY
         ELSE
             SUBTRACT M-DX(M-D2) FROM M-CX
             SUBTRACT M-DZ(M-D2) FROM M-CZ
         END-IF
         ADD 1 TO M-CY
         MOVE 0 TO M-J
         MOVE 0 TO M-STOP
         PERFORM UNTIL M-J >= M-LEN2 OR M-STOP = 1
             ADD M-DX(M-D0) TO M-CX
             ADD M-DZ(M-D0) TO M-CZ
             PERFORM M-PLACE
             IF M-OK = 0
                 MOVE 1 TO M-STOP
             ELSE
                 CALL "WGR-NEXT-FLOAT" USING XR2-STATE M-F
                 IF M-F < M-QUARTER
                     ADD 1 TO M-CY
                 END-IF
                 ADD 1 TO M-J
             END-IF
         END-PERFORM
     END-PERFORM
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-14.
 COPY CORETEST.
