*> Implementation test of the desert well parts (docs/protocol/35-worldgen-features-5-water-and-surface.md section 17; core/src/feat-template.cob, the randomly_selected placement of
*> 35-1 section 7.17 in feat-data.cob / feat-run.cob): the template feature compiles (type 50; a missing template file, no templates, an unknown rotation, a zero total weight and a processor
*> list that does not compile make it unsupported) and, over 40 seeds on a shadow array with a second random source, places the chosen template: nextInt(total weight) picks it, nextInt of the
*> rotation list the rotation, then one palette draw; the origin is pos + unit(rotate(WEST)) * (x / 2) + unit(rotate(NORTH)) * (z / 2) and every block is the template block rotated about the
*> origin (clockwise 90 degrees (x, z) to (-z, x), 180 degrees (-x, -z), counter-clockwise 90 degrees (z, -x)); with an inline rule processor the gold block becomes emerald. The randomly_selected
*> placement is compared the same way (one nextInt(n), nested lists too). Templates come from core/tests/fixtures/gen_featpl.py (a: 3 x 1 x 5 with four blocks, b: 1 x 2 x 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-17.
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
 01 WS-FT-TWO              BINARY-LONG.
 01 WS-FT-PROC             BINARY-LONG.
 01 WS-FT-ROT              BINARY-LONG.
 01 WS-CUR-FT              BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
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
    05 WS-OS               BINARY-LONG OCCURS 3072 TIMES.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-GOLD              BINARY-LONG.
 01 WS-S-IRON              BINARY-LONG.
 01 WS-S-DIAMOND           BINARY-LONG.
 01 WS-S-EMERALD           BINARY-LONG.
 01 WS-N-ROT               BINARY-LONG OCCURS 4 TIMES.
 01 WS-N-B                 BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-ZERO-TOP            BINARY-LONG VALUE 0.
 01 WS-N-RSEL              BINARY-LONG VALUE 0.
 01 WS-MODEL-RESULT        BINARY-LONG.
*> model state
 01 M-OX                   BINARY-LONG.
 01 M-OY                   BINARY-LONG.
 01 M-OZ                   BINARY-LONG.
 01 M-ROT                  BINARY-LONG.
 01 M-TPL                  BINARY-LONG.
 01 M-LX                   BINARY-LONG.
 01 M-LY                   BINARY-LONG.
 01 M-LZ                   BINARY-LONG.
 01 M-RX                   BINARY-LONG.
 01 M-RZ                   BINARY-LONG.
 01 M-ST                   BINARY-LONG.
 01 M-I                    BINARY-LONG.
 01 M-V                    BINARY-LONG.
 01 M-N                    BINARY-LONG.
 01 M-B1                   BINARY-LONG VALUE 1.
 01 M-B2                   BINARY-LONG VALUE 2.
 01 M-B4                   BINARY-LONG VALUE 4.
 01 M-B5                   BINARY-LONG VALUE 5.
 01 M-B3                   BINARY-LONG VALUE 3.
 01 M-DX                   BINARY-LONG.
 01 M-DZ                   BINARY-LONG.
 01 M-KIND                 BINARY-LONG.
*> template a: 3 x 1 x 5, blocks (x, z, palette): gold (0,0), iron (2,0), diamond (0,4), gold (1,2); template b: 1 x 2 x 1: iron at y 0, diamond at y 1
 01 M-A-BLOCKS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 0.
 01 M-A-TABLE REDEFINES M-A-BLOCKS.
    05 M-A OCCURS 4 TIMES.
       10 M-AX             BINARY-LONG.
       10 M-AZ             BINARY-LONG.
       10 M-AK             BINARY-LONG.
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
     MOVE "core/tests/fixtures/featpl" TO SD-DIR
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "gold_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GOLD
     MOVE "iron_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-IRON
     MOVE "diamond_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-DIAMOND
     MOVE "emerald_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-EMERALD
     MOVE "minecraft:templ_two" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-TWO
     CALL "FD-ENSURE-FT" USING WS-FT-TWO
     MOVE "minecraft:templ_proc" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-PROC
     CALL "FD-ENSURE-FT" USING WS-FT-PROC
     MOVE "minecraft:templ_rot" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-ROT
     CALL "FD-ENSURE-FT" USING WS-FT-ROT
     MOVE "35-5§17: the data feature compiles as a template (50)" TO WS-CASE
     MOVE FT-TYPE(WS-FT-TWO) TO WS-OBS
     MOVE 50 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§17: a template with an inline processor list compiles" TO WS-CASE
     MOVE FT-TYPE(WS-FT-PROC) TO WS-OBS
     PERFORM ASSERT-N
     MOVE "35-5§17: a template with a rotation list compiles" TO WS-CASE
     MOVE FT-TYPE(WS-FT-ROT) TO WS-OBS
     PERFORM ASSERT-N

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 40
         COMPUTE WS-SEED = WS-SEEDNO * 4001
         MOVE WS-SEEDNO TO WS-SEEDTXT
         EVALUATE TRUE
             WHEN WS-SEEDNO <= 24
                 MOVE WS-FT-TWO TO WS-CUR-FT
             WHEN WS-SEEDNO <= 32
                 MOVE WS-FT-PROC TO WS-CUR-FT
             WHEN OTHER
                 MOVE WS-FT-ROT TO WS-CUR-FT
         END-EVALUATE
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 64 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM SAVE-WORLD
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-CUR-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-WORLD
         MOVE SPACES TO WS-CASE
         STRING "35-5§17: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§17: seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 4
         MOVE SPACES TO WS-CASE
         MOVE M-I TO WS-DIGIT
         STRING "35-5§17: rotation code " WS-DIGIT " (1 = none) was drawn" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-OBS
         IF WS-N-ROT(M-I) > 0
             MOVE 1 TO WS-OBS
         END-IF
         MOVE 1 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-5§17: the weighted pick chose template b at least once" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-B > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N

*>   randomly_selected: one nextInt(n) picks the offset; nested lists draw again
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 20
         COMPUTE WS-SEED = WS-SEEDNO * 977
         MOVE WS-SEEDNO TO WS-SEEDTXT
         IF WS-SEEDNO <= 10
             MOVE "minecraft:rsel" TO WS-FTKEY
             MOVE 1 TO M-KIND
         ELSE
             MOVE "minecraft:rsel2" TO WS-FTKEY
             MOVE 2 TO M-KIND
         END-IF
         CALL "FD-GET-PF" USING WS-FTKEY WS-PF
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 64 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM SAVE-WORLD
         PERFORM MODEL-RSEL
         CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-ZERO-TOP WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-WORLD
         MOVE SPACES TO WS-CASE
         STRING "35-5§17: randomly_selected run " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§17: randomly_selected run " WS-SEEDTXT " the random state equals the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-5§17: randomly_selected placed a block in every run" TO WS-CASE
     MOVE WS-N-RSEL TO WS-OBS
     MOVE 20 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:rsel_bad" TO WS-FTKEY
     CALL "FD-GET-PF" USING WS-FTKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "35-5§17: randomly_selected without placements is unsupported" TO WS-CASE
     MOVE PF-STATUS(WS-PF) TO WS-OBS
     MOVE 2 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:rsel_empty" TO WS-FTKEY
     CALL "FD-GET-PF" USING WS-FTKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "35-5§17: randomly_selected with an empty list is unsupported" TO WS-CASE
     MOVE PF-STATUS(WS-PF) TO WS-OBS
     PERFORM ASSERT-N

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:templ_missing" TO WS-FTKEY
                 MOVE "a missing template file" TO WS-NAME
             WHEN 2
                 MOVE "minecraft:templ_bad" TO WS-FTKEY
                 MOVE "no templates" TO WS-NAME
             WHEN 3
                 MOVE "minecraft:templ_badrot" TO WS-FTKEY
                 MOVE "an unknown rotation" TO WS-NAME
             WHEN 4
                 MOVE "minecraft:templ_badproc" TO WS-FTKEY
                 MOVE "a processor that does not compile" TO WS-NAME
             WHEN OTHER
                 MOVE "minecraft:templ_zero" TO WS-FTKEY
                 MOVE "a zero total weight" TO WS-NAME
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-FTKEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-5§17: " FUNCTION TRIM(WS-NAME) " makes the feature unsupported" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE -1 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:templ_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§17: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
*>   without the structure data folder the template root is the folder of FD-SET-DIR
     MOVE SPACES TO SD-DIR
     MOVE "core/tests/fixtures/featpl" TO WS-DIR
     CALL "FD-SET-DIR" USING WS-DIR
     MOVE "minecraft:templ_two" TO WS-FTKEY
     CALL "FD-RESET"
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§17: a template feature without an open structure folder finds no file here" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:desert_well" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§17: the gate admits desert_well" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
 SAVE-WORLD.
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 60 BY 1 UNTIL WS-QY > 71
                 COMPUTE WS-MIDX = (WS-QY - 60) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
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
             PERFORM VARYING WS-QY FROM 60 BY 1 UNTIL WS-QY > 71
                 COMPUTE WS-MIDX = (WS-QY - 60) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 IF WS-STATE NOT = WS-OS(WS-MIDX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone to y 63, air above; both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 60 TO WS-Y0
     MOVE 63 TO WS-Y1
     MOVE WS-S-STONE TO WS-STATE
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
             PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
*> ---- the model
 M-PUT.
     IF M-RX >= 16 AND M-RX <= 31 AND M-RZ >= 32 AND M-RZ <= 47 AND M-LY >= 60 AND M-LY <= 71
         COMPUTE WS-MIDX = (M-LY - 60) * 256 + (M-RZ - 32) * 16 + (M-RX - 16) + 1
         MOVE M-ST TO WS-OS(WS-MIDX)
     END-IF
     .
*> M-ROTATE: M-LX, M-LZ (the template's local x and z) turned by the rotation code M-ROT (0 none, 1 clockwise 90, 2 clockwise 180, 3 counter-clockwise 90) into M-DX, M-DZ
 M-ROTATE.
     EVALUATE M-ROT
         WHEN 0
             MOVE M-LX TO M-DX
             MOVE M-LZ TO M-DZ
         WHEN 1
             COMPUTE M-DX = 0 - M-LZ
             MOVE M-LX TO M-DZ
         WHEN 2
             COMPUTE M-DX = 0 - M-LX
             COMPUTE M-DZ = 0 - M-LZ
         WHEN OTHER
             MOVE M-LZ TO M-DX
             COMPUTE M-DZ = 0 - M-LX
     END-EVALUATE
     .
 MODEL-RUN.
     MOVE 1 TO WS-MODEL-RESULT
     IF WS-CUR-FT = WS-FT-TWO
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B4 M-V
         IF M-V < 3
             MOVE 1 TO M-TPL
         ELSE
             MOVE 2 TO M-TPL
             ADD 1 TO WS-N-B
         END-IF
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B4 M-ROT
     ELSE
         MOVE 1 TO M-TPL
         IF WS-CUR-FT = WS-FT-PROC
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B1 M-V
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B4 M-ROT
         ELSE
*>           the rotation list of the fixture: counter-clockwise 90, then 180
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B1 M-V
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B2 M-V
             IF M-V = 0
                 MOVE 3 TO M-ROT
             ELSE
                 MOVE 2 TO M-ROT
             END-IF
         END-IF
     END-IF
     ADD 1 TO WS-N-ROT(M-ROT + 1)
*>   the palette draw (one palette)
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B1 M-V
*>   the origin: pos + unit(rotate(WEST)) * (x / 2) + unit(rotate(NORTH)) * (z / 2), the template sizes being a (3, 5) and b (1, 1)
     IF M-TPL = 1
         MOVE 1 TO M-DX
         MOVE 2 TO M-DZ
     ELSE
         MOVE 0 TO M-DX
         MOVE 0 TO M-DZ
     END-IF
     EVALUATE M-ROT
         WHEN 0
             COMPUTE M-OX = WS-X - M-DX
             COMPUTE M-OZ = WS-Z - M-DZ
         WHEN 1
             COMPUTE M-OX = WS-X + M-DZ
             COMPUTE M-OZ = WS-Z - M-DX
         WHEN 2
             COMPUTE M-OX = WS-X + M-DX
             COMPUTE M-OZ = WS-Z + M-DZ
         WHEN OTHER
             COMPUTE M-OX = WS-X - M-DZ
             COMPUTE M-OZ = WS-Z + M-DX
     END-EVALUATE
     MOVE WS-Y TO M-OY
     IF M-TPL = 1
         PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 4
             MOVE M-AX(M-I) TO M-LX
             MOVE M-AZ(M-I) TO M-LZ
             PERFORM M-ROTATE
             COMPUTE M-RX = M-OX + M-DX
             COMPUTE M-RZ = M-OZ + M-DZ
             MOVE M-OY TO M-LY
             EVALUATE M-AK(M-I)
                 WHEN 0
                     IF WS-CUR-FT = WS-FT-PROC
                         MOVE WS-S-EMERALD TO M-ST
                     ELSE
                         MOVE WS-S-GOLD TO M-ST
                     END-IF
                 WHEN 1
                     MOVE WS-S-IRON TO M-ST
                 WHEN OTHER
                     MOVE WS-S-DIAMOND TO M-ST
             END-EVALUATE
             PERFORM M-PUT
         END-PERFORM
     ELSE
         MOVE M-OX TO M-RX
         MOVE M-OZ TO M-RZ
         MOVE M-OY TO M-LY
         MOVE WS-S-IRON TO M-ST
         PERFORM M-PUT
         COMPUTE M-LY = M-OY + 1
         MOVE WS-S-DIAMOND TO M-ST
         PERFORM M-PUT
     END-IF
     .
*> MODEL-RSEL: the placed feature rsel (M-KIND 1: one of five offsets) or rsel2 (M-KIND 2: nextInt(2): a nested pick of three offsets, or the offset (0, 3)), a gold block at the result
 MODEL-RSEL.
     IF M-KIND = 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B5 M-V
         EVALUATE M-V
             WHEN 0
                 MOVE 0 TO M-DX
                 MOVE 0 TO M-DZ
             WHEN 1
                 MOVE -1 TO M-DX
                 MOVE 0 TO M-DZ
             WHEN 2
                 MOVE 0 TO M-DX
                 MOVE 1 TO M-DZ
             WHEN 3
                 MOVE 1 TO M-DX
                 MOVE 0 TO M-DZ
             WHEN OTHER
                 MOVE 0 TO M-DX
                 MOVE -1 TO M-DZ
         END-EVALUATE
     ELSE
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B2 M-V
         IF M-V = 0
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-V
             EVALUATE M-V
                 WHEN 0
                     MOVE 2 TO M-DX
                     MOVE 2 TO M-DZ
                 WHEN 1
                     MOVE -2 TO M-DX
                     MOVE 2 TO M-DZ
                 WHEN OTHER
                     MOVE 2 TO M-DX
                     MOVE -2 TO M-DZ
             END-EVALUATE
         ELSE
             MOVE 0 TO M-DX
             MOVE 3 TO M-DZ
         END-IF
     END-IF
     COMPUTE M-RX = WS-X + M-DX
     COMPUTE M-RZ = WS-Z + M-DZ
     MOVE WS-Y TO M-LY
     MOVE WS-S-GOLD TO M-ST
     PERFORM M-PUT
     ADD 1 TO WS-N-RSEL
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-17.
 COPY NOSPAWN.
 COPY CORETEST.
