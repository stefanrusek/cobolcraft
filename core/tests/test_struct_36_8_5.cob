*> Acceptance test of the nether fortress piece geometry (docs/protocol/36-structures-8-nether-and-end.md section 5 and 1.2; core/src/struct-fortress-post.cob, struct-fortress-gen.cob; T13509):
*> representative cells of each of the 14 piece lists (the later rows overwrite the earlier ones, the columns under the piece, the clipping to the write box), the facing and fence sides turned
*> for the four orientations, the bridge end filler's 27 draws against a reference random, the throne's spawner once and the turn pieces' chest once, and the roll of the chest flag.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY GENBE.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-NAME                PIC X(60).
 01 WS-REST                PIC X(60).
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ORIENT              BINARY-LONG.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BADC                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG VALUE 4.
 01 WS-BY                  BINARY-LONG VALUE 60.
 01 WS-BZ                  BINARY-LONG VALUE 4.
 01 WS-LAST-CASE           BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-SEEDS               BINARY-DOUBLE UNSIGNED.
 01 WS-N                   BINARY-LONG.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-SEEN                PIC X(240).
 01 WS-NB                  BINARY-LONG.
 01 WS-AIRS                BINARY-LONG VALUE 0.
 01 WS-STRIPS.
    05 WS-STRIP OCCURS 27 TIMES.
       10 WS-ST-X          BINARY-LONG.
       10 WS-ST-Y          BINARY-LONG.
       10 WS-ST-N          BINARY-LONG.
 01 WS-NSTRIP              BINARY-LONG.
 01 WS-COVER               BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-CHEST-STATE         BINARY-LONG.
 01 WS-SPAWNER-STATE       BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-CASES.
    05 FILLER PIC X(6) VALUE "042   ".
    05 FILLER PIC X(6) VALUE "062   ".
    05 FILLER PIC X(6) VALUE "063   ".
    05 FILLER PIC X(6) VALUE "060   ".
    05 FILLER PIC X(6) VALUE "061   ".
    05 FILLER PIC X(6) VALUE "162   ".
    05 FILLER PIC X(6) VALUE "172   ".
    05 FILLER PIC X(6) VALUE "152   ".
    05 FILLER PIC X(6) VALUE "092   ".
    05 FILLER PIC X(6) VALUE "142   ".
    05 FILLER PIC X(6) VALUE "122   ".
    05 FILLER PIC X(6) VALUE "102   ".
    05 FILLER PIC X(6) VALUE "112   ".
    05 FILLER PIC X(6) VALUE "132   ".
    05 FILLER PIC X(6) VALUE "072   ".
    05 FILLER PIC X(6) VALUE "082   ".
 01 WS-CT REDEFINES WS-CASES.
    05 WS-CASE OCCURS 16 TIMES.
       10 WS-C-TYPE        PIC 99.
       10 WS-C-ORIENT      PIC 9.
       10 FILLER           PIC X(3).
 01 WS-CELLS.
    05 FILLER PIC X(74) VALUE "01+009+003+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "01+009+006+009air                                                         ".
    05 FILLER PIC X(74) VALUE "01+007+005+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "01+009+000+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "01+009-001+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "01+009-030+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "01+009+000+009air                                                         ".
    05 FILLER PIC X(74) VALUE "01+003+005+009air                                                         ".
    05 FILLER PIC X(74) VALUE "01+000+003+009nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "01+009-001+009air                                                         ".
    05 FILLER PIC X(74) VALUE "02+002+003+005nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "02+002+005+005air                                                         ".
    05 FILLER PIC X(74) VALUE "02+000+005+005nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "02+000+001+001nether_brick_fence[north=true,east=true,south=true]         ".
    05 FILLER PIC X(74) VALUE "02+004+003+004nether_brick_fence[north=true,south=true,west=true]         ".
    05 FILLER PIC X(74) VALUE "02+002+002+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "02+002+002+010air                                                         ".
    05 FILLER PIC X(74) VALUE "02+002-001+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "02+002-001+009air                                                         ".
    05 FILLER PIC X(74) VALUE "03+000+001+001nether_brick_fence[east=true,south=true,west=true]          ".
    05 FILLER PIC X(74) VALUE "03+004+001+001nether_brick_fence[north=true,east=true,west=true]          ".
    05 FILLER PIC X(74) VALUE "04+000+001+001nether_brick_fence[north=true,east=true,south=true]         ".
    05 FILLER PIC X(74) VALUE "04+004+003+004nether_brick_fence[north=true,south=true,west=true]         ".
    05 FILLER PIC X(74) VALUE "05+000+001+001nether_brick_fence[east=true,south=true,west=true]          ".
    05 FILLER PIC X(74) VALUE "05+004+001+001nether_brick_fence[north=true,east=true,west=true]          ".
    05 FILLER PIC X(74) VALUE "06+003+002+003air                                                         ".
    05 FILLER PIC X(74) VALUE "06+000+002+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "06+003+006+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "06+003+005+000nether_brick_fence[east=true,west=true]                     ".
    05 FILLER PIC X(74) VALUE "06+000+005+003nether_brick_fence[north=true,south=true]                   ".
    05 FILLER PIC X(74) VALUE "06+003+000+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "06+003-001+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "06+006+006+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "06+003+007+003air                                                         ".
    05 FILLER PIC X(74) VALUE "07+003+003+005nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "07+003+006+005air                                                         ".
    05 FILLER PIC X(74) VALUE "07+005+002+005nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "07+003+007+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "07+006+008+003air                                                         ".
    05 FILLER PIC X(74) VALUE "07+000+003+003nether_brick_fence[north=true,south=true]                   ".
    05 FILLER PIC X(74) VALUE "07+003+000+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "07+003+005+003air                                                         ".
    05 FILLER PIC X(74) VALUE "07+003-001+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "08+003+003+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "08+003+004+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "08+003+005+004air                                                         ".
    05 FILLER PIC X(74) VALUE "08+001+006+003nether_brick_fence[west=true]                               ".
    05 FILLER PIC X(74) VALUE "08+000+006+003nether_brick_fence[north=true,east=true]                    ".
    05 FILLER PIC X(74) VALUE "08+003+008+008nether_brick_fence[east=true,west=true]                     ".
    05 FILLER PIC X(74) VALUE "08+003+007+008nether_brick_fence[east=true,west=true]                     ".
    05 FILLER PIC X(74) VALUE "08+003+000+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "08+003-001+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "08+003+002+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "09+006+005+006lava                                                        ".
    05 FILLER PIC X(74) VALUE "09+006+000+006nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "09+006+003+006air                                                         ".
    05 FILLER PIC X(74) VALUE "09+005+005+005nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "09+005+008+000nether_brick_fence                                          ".
    05 FILLER PIC X(74) VALUE "09+000+013+000nether_brick_fence[north=true,east=true]                    ".
    05 FILLER PIC X(74) VALUE "09+001+010+000nether_brick_fence[east=true,west=true]                     ".
    05 FILLER PIC X(74) VALUE "09+006+002+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "09+006-001+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "09+001+007+003nether_brick_fence[north=true,south=true,west=true]         ".
    05 FILLER PIC X(74) VALUE "09+011+007+003nether_brick_fence[north=true,east=true,south=true]         ".
    05 FILLER PIC X(74) VALUE "09+002+008+006air                                                         ".
    05 FILLER PIC X(74) VALUE "10+006+005+004nether_brick_stairs[facing=north]                           ".
    05 FILLER PIC X(74) VALUE "10+006+006+005nether_brick_stairs[facing=north]                           ".
    05 FILLER PIC X(74) VALUE "10+006+005+005nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "10+006+007+005air                                                         ".
    05 FILLER PIC X(74) VALUE "10+003+004+004soul_sand                                                   ".
    05 FILLER PIC X(74) VALUE "10+003+005+004nether_wart                                                 ".
    05 FILLER PIC X(74) VALUE "10+004+005+002nether_brick_stairs[facing=west]                            ".
    05 FILLER PIC X(74) VALUE "10+008+005+002nether_brick_stairs[facing=east]                            ".
    05 FILLER PIC X(74) VALUE "10+006+012+011nether_brick_stairs[facing=north]                           ".
    05 FILLER PIC X(74) VALUE "10+006+013+012air                                                         ".
    05 FILLER PIC X(74) VALUE "10+000+013+000nether_brick_fence[north=true,east=true]                    ".
    05 FILLER PIC X(74) VALUE "10+005+006+007nether_brick_fence[north=true,east=true,south=true]         ".
    05 FILLER PIC X(74) VALUE "11+002+002+002air                                                         ".
    05 FILLER PIC X(74) VALUE "11+000+003+001nether_brick_fence[north=true,south=true]                   ".
    05 FILLER PIC X(74) VALUE "11+004+003+003nether_brick_fence[north=true,south=true]                   ".
    05 FILLER PIC X(74) VALUE "11+002+006+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "11+000+002+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "11+002+000+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "11+002-001+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "12+000+002+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "12+002+002+000air                                                         ".
    05 FILLER PIC X(74) VALUE "12+002+002+002air                                                         ".
    05 FILLER PIC X(74) VALUE "12+004+005+004nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "12+002+006+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "12+000+002+002air                                                         ".
    05 FILLER PIC X(74) VALUE "13+004+003+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "13+004+003+001nether_brick_fence[north=true,south=true]                   ".
    05 FILLER PIC X(74) VALUE "13+001+003+004nether_brick_fence[east=true,west=true]                     ".
    05 FILLER PIC X(74) VALUE "13+000+002+002air                                                         ".
    05 FILLER PIC X(74) VALUE "13+002+002+002air                                                         ".
    05 FILLER PIC X(74) VALUE "13+002+006+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "13+002-001+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "14+000+003+001nether_brick_fence[north=true,south=true]                   ".
    05 FILLER PIC X(74) VALUE "14+001+003+004nether_brick_fence[east=true,west=true]                     ".
    05 FILLER PIC X(74) VALUE "14+004+002+002air                                                         ".
    05 FILLER PIC X(74) VALUE "14+000+002+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "14+002+006+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "15+002+005+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "15+002+009+000air                                                         ".
    05 FILLER PIC X(74) VALUE "15+001+008+000nether_brick_stairs[facing=south]                           ".
    05 FILLER PIC X(74) VALUE "15+002+013+000nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "15+000+009+000nether_brick_fence[north=true,south=true]                   ".
    05 FILLER PIC X(74) VALUE "15+002+001+009nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "15+002+003+009air                                                         ".
    05 FILLER PIC X(74) VALUE "15+002+006+009nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "15+000+003+009nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "15+002+000+007nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "15+001+002+007air                                                         ".
    05 FILLER PIC X(74) VALUE "15+002-001+005nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "16+004+006+002nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "16+004+003+002air                                                         ".
    05 FILLER PIC X(74) VALUE "16+001+003+000nether_brick_fence[east=true,west=true]                     ".
    05 FILLER PIC X(74) VALUE "16+000+003+008nether_brick_fence[east=true,south=true]                    ".
    05 FILLER PIC X(74) VALUE "16+008+003+008nether_brick_fence[south=true,west=true]                    ".
    05 FILLER PIC X(74) VALUE "16+004+002+006nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "16+001+001+004air                                                         ".
    05 FILLER PIC X(74) VALUE "16+000+003+006nether_brick_fence[north=true,south=true]                   ".
    05 FILLER PIC X(74) VALUE "16+000+004+004nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "16+001+004+005nether_brick_fence[east=true,west=true]                     ".
    05 FILLER PIC X(74) VALUE "16+004-001+003nether_bricks                                               ".
    05 FILLER PIC X(74) VALUE "16+004-001+007air                                                         ".
 01 WS-CL REDEFINES WS-CELLS.
    05 WS-CELL OCCURS 126 TIMES.
       10 WS-CE-CASE       PIC 99.
       10 WS-CE-X          PIC S999 SIGN LEADING SEPARATE.
       10 WS-CE-Y          PIC S999 SIGN LEADING SEPARATE.
       10 WS-CE-Z          PIC S999 SIGN LEADING SEPARATE.
       10 WS-CE-SPEC       PIC X(60).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "SPB-RESET"
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 0 TO SW-X0
     MOVE -63 TO SW-Y0
     MOVE 0 TO SW-Z0
     MOVE 15 TO SW-X1
     MOVE 319 TO SW-Y1
     MOVE 15 TO SW-Z1
     MOVE 0 TO WS-BADC
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 16
         PERFORM CLEAR-WORLD
         PERFORM ADD-PIECE
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 126
             IF WS-CE-CASE(WS-I) = WS-C
                 PERFORM CHECK-CELL
             END-IF
         END-PERFORM
         MOVE WS-C TO WS-ED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-8§5 A. Piece geometry: case " FUNCTION TRIM(WS-ED) " (piece " WS-C-TYPE(WS-C) " facing " WS-C-ORIENT(WS-C) ") cells" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     PERFORM FILLER-TEST
     PERFORM SPAWNER-TEST
     PERFORM CHEST-TEST
     PERFORM CLIP-TEST
     PERFORM LAVA-TICK-TEST
     PERFORM ROLL-TEST
     STOP RUN.
 CLEAR-WORLD.
     MOVE LOW-VALUES TO CE-CHUNK
     CALL "SPB-RESET"
     EXIT.
 ADD-PIECE.
     MOVE WS-C-TYPE(WS-C) TO WS-TYPE
     MOVE WS-C-ORIENT(WS-C) TO WS-ORIENT
     PERFORM ADD-PIECE-BOX
     EXIT.
 ADD-PIECE-BOX.
     CALL "FORT-SIZE" USING WS-TYPE WS-OX WS-OY WS-OZ WS-W WS-H WS-D
*>   the box is placed so that the cells next to the piece's local origin fall in the window 0 to 15 for every orientation
     MOVE 0 TO WS-BX
     MOVE 0 TO WS-BZ
     IF WS-ORIENT = 2
         COMPUTE WS-BZ = 16 - WS-D
     END-IF
     IF WS-ORIENT = 1
         COMPUTE WS-BX = 16 - WS-D
     END-IF
     MOVE WS-BX TO A-X0
     MOVE WS-BY TO A-Y0
     MOVE WS-BZ TO A-Z0
     COMPUTE A-Y1 = WS-BY + WS-H - 1
     IF WS-ORIENT = 0 OR WS-ORIENT = 2
         COMPUTE A-X1 = WS-BX + WS-W - 1
         COMPUTE A-Z1 = WS-BZ + WS-D - 1
     ELSE
         COMPUTE A-X1 = WS-BX + WS-D - 1
         COMPUTE A-Z1 = WS-BZ + WS-W - 1
     END-IF
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEP WS-MST WS-BOX WS-ROW
     CALL "FORT-POST" USING WS-ROW
     EXIT.
 CHECK-CELL.
     MOVE WS-CE-X(WS-I) TO WS-X
     MOVE WS-CE-Y(WS-I) TO WS-Y
     MOVE WS-CE-Z(WS-I) TO WS-Z
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE SPACES TO WS-NAME WS-REST WS-PAIRS WS-KEY
     UNSTRING WS-CE-SPEC(WS-I) DELIMITED BY "[" INTO WS-NAME WS-REST
     UNSTRING WS-REST DELIMITED BY "]" INTO WS-PAIRS
     STRING "minecraft:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
     IF WS-NAME = "air"
         MOVE 0 TO WS-WANT
     ELSE
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-WANT
     END-IF
     IF WS-STATE NOT = WS-WANT
         ADD 1 TO WS-BAD
         DISPLAY "PROBE case " WS-C " cell " WS-X " " WS-Y " " WS-Z " " FUNCTION TRIM(WS-CE-SPEC(WS-I)) " got " WS-STATE " want " WS-WANT
     END-IF
     EXIT.
 FILLER-TEST.
     PERFORM CLEAR-WORLD
     MOVE 5 TO WS-TYPE
     MOVE 2 TO WS-ORIENT
     PERFORM ADD-PIECE-BOX-NOPOST
     MOVE 98765 TO SP-F1(WS-ROW)
     CALL "FORT-POST" USING WS-ROW
*>   the reference: the same 27 draws, the cells they cover
     CALL "JRAND-SET-SEED" USING WS-RNG WS-SEEDS
     MOVE 98765 TO WS-SEEDS
     CALL "JRAND-SET-SEED" USING WS-RNG WS-SEEDS
     MOVE 0 TO WS-NSTRIP
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Y FROM 3 BY 1 UNTIL WS-Y > 4
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-EIGHT WS-N
             PERFORM NOTE-STRIP
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-X
     MOVE 5 TO WS-Y
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-EIGHT WS-N
     PERFORM NOTE-STRIP
     MOVE 4 TO WS-X
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-EIGHT WS-N
     PERFORM NOTE-STRIP
     MOVE 2 TO WS-Y
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-FIVE WS-N
         PERFORM NOTE-STRIP
     END-PERFORM
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 1
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-THREE WS-N
             PERFORM NOTE-STRIP
         END-PERFORM
     END-PERFORM
     MOVE "minecraft:nether_bricks" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-NB
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 5
             PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 7
                 MOVE 0 TO WS-COVER
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-NSTRIP
                     IF WS-ST-X(WS-K) = WS-X AND WS-ST-Y(WS-K) = WS-Y AND WS-Z <= WS-ST-N(WS-K)
                         MOVE 1 TO WS-COVER
                     END-IF
                 END-PERFORM
                 CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
                 CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
                 IF WS-COVER = 1
                     ADD 1 TO WS-NB
                     IF WS-STATE NOT = WS-WANT
                         ADD 1 TO WS-BAD
                     END-IF
                 ELSE
                     IF WS-STATE NOT = 0
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-8§5 A. Piece geometry: the bridge end filler's strips follow the 27 draws of its seed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§5 A. Piece geometry: the filler is a ragged stub (some, not all, of its cells)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NB > 20 AND WS-NB < 5 * 6 * 8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a negative seed (the draw is a 32 bit int sign extended)
     PERFORM CLEAR-WORLD
     MOVE 5 TO WS-TYPE
     PERFORM ADD-PIECE-BOX-NOPOST
     MOVE -5 TO SP-F1(WS-ROW)
     CALL "FORT-POST" USING WS-ROW
     MOVE 0 TO WS-NB
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         MOVE 0 TO WS-Z
         MOVE 0 TO WS-Y
         CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
         CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
         IF WS-STATE = WS-WANT
             ADD 1 TO WS-NB
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§5 A. Piece geometry: a negative seed also builds the first row of the stub" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-NB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     EXIT.
 ADD-PIECE-BOX-NOPOST.
     CALL "FORT-SIZE" USING WS-TYPE WS-OX WS-OY WS-OZ WS-W WS-H WS-D
     MOVE WS-BX TO A-X0
     MOVE WS-BY TO A-Y0
     MOVE WS-BZ TO A-Z0
     COMPUTE A-Y1 = WS-BY + WS-H - 1
     COMPUTE A-X1 = WS-BX + WS-W - 1
     COMPUTE A-Z1 = WS-BZ + WS-D - 1
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEP WS-MST WS-BOX WS-ROW
     EXIT.
 NOTE-STRIP.
     ADD 1 TO WS-NSTRIP
     MOVE WS-X TO WS-ST-X(WS-NSTRIP)
     MOVE WS-Y TO WS-ST-Y(WS-NSTRIP)
     MOVE WS-N TO WS-ST-N(WS-NSTRIP)
     EXIT.
 SPAWNER-TEST.
     PERFORM CLEAR-WORLD
     MOVE 0 TO GBL-COUNT
     MOVE 15 TO WS-TYPE
     MOVE 2 TO WS-ORIENT
     PERFORM ADD-PIECE-BOX
     MOVE "minecraft:spawner" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE 3 TO WS-X
     MOVE 5 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "acceptance US12 36-8§5 A. Piece geometry: the throne's spawner stands at local (3, 5, 5)" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: the spawner asks the block entity channel for a blaze once" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GBL-COUNT = 1 AND GBL-KIND(1) = 2 AND GBL-TEXT(1) = "minecraft:blaze" AND SP-F1(WS-ROW) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FORT-POST" USING WS-ROW
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: the Mob flag keeps a second pass from placing it again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE GBL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     EXIT.
 CHEST-TEST.
     PERFORM CLEAR-WORLD
     MOVE 0 TO GBL-COUNT
     MOVE 11 TO WS-TYPE
     MOVE 2 TO WS-ORIENT
     MOVE 1 TO WS-LOCAL
     PERFORM ADD-PIECE-BOX-NOPOST
     MOVE 1 TO SP-F2(WS-ROW)
     CALL "FORT-POST" USING WS-ROW
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: a pending chest of the left turn piece is made once with chests/nether_bridge" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GBL-COUNT = 1 AND GBL-KIND(1) = 1 AND GBL-LOOT(1) = "minecraft:chests/nether_bridge" AND SP-F2(WS-ROW) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FORT-POST" USING WS-ROW
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: the cleared flag makes no second chest" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE GBL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CLEAR-WORLD
     MOVE 0 TO GBL-COUNT
     MOVE 13 TO WS-TYPE
     PERFORM ADD-PIECE-BOX-NOPOST
     MOVE 1 TO SP-F2(WS-ROW)
     CALL "FORT-POST" USING WS-ROW
     MOVE 1 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "minecraft:chest" TO WS-KEY
     CALL "BLOCK-STATE-PROP" USING WS-LOCAL WS-STATE WS-KEY WS-REST WS-OK
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: the right turn piece's chest is at local (1, 2, 3)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE GBL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     EXIT.
 CLIP-TEST.
*>   a window of x 0 to 2 only: the cells of a piece beyond it are not written
     PERFORM CLEAR-WORLD
     MOVE 2 TO SW-X1
     MOVE 6 TO WS-TYPE
     MOVE 2 TO WS-ORIENT
     PERFORM ADD-PIECE-BOX
     MOVE 3 TO WS-X
     MOVE 3 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "acceptance US12 36-8§5 A. Piece geometry: a cell outside the write box stays untouched" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-X
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "acceptance US12 36-8§5 A. Piece geometry: a cell inside the write box of the same piece is written" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STATE NOT = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO SW-X1
     EXIT.
 LAVA-TICK-TEST.
*>   the castle entrance's lava well (5.7): the lava source at local (6, 5, 6) asks for a scheduled fluid tick (delay 0) once, when that cell is inside the write box
     PERFORM CLEAR-WORLD
     MOVE 0 TO GBL-COUNT
     MOVE 9 TO WS-TYPE
     MOVE 2 TO WS-ORIENT
     PERFORM ADD-PIECE-BOX
     MOVE 6 TO WS-X
     MOVE 5 TO WS-Y
     MOVE 6 TO WS-Z
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     MOVE "acceptance US12 36-8§5.7 A. CastleEntrance: the lava source's fluid tick is asked for once at the world cell of local (6, 5, 6)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GBL-COUNT = 1 AND GBL-KIND(1) = 5 AND GBL-X(1) = WS-WX AND GBL-Y(1) = WS-WY AND GBL-Z(1) = WS-WZ
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CLEAR-WORLD
     MOVE 0 TO GBL-COUNT
     MOVE 2 TO SW-X1
     PERFORM ADD-PIECE-BOX
     MOVE "acceptance US12 36-8§5.7 A. CastleEntrance: with the lava cell outside the write box no tick is asked for" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GBL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO SW-X1
     EXIT.
 ROLL-TEST.
*>   the chest flag of a turn piece: set when the constructor's nextInt(3) is 0
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-NB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "SPB-RESET"
         MOVE WS-I TO SP-RNG
         MOVE 100 TO WS-OX
         MOVE 70 TO WS-OY
         MOVE 100 TO WS-OZ
         MOVE 0 TO WS-D
         MOVE 11 TO WS-TYPE
         CALL "FORT-MAKE" USING WS-TYPE WS-OX WS-OY WS-OZ WS-D WS-DEP WS-ROW
         IF SP-F2(WS-ROW) NOT = 0 AND SP-F2(WS-ROW) NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         IF (SP-F1(WS-ROW) = 0 AND SP-F2(WS-ROW) NOT = 1) OR (SP-F1(WS-ROW) NOT = 0 AND SP-F2(WS-ROW) NOT = 0)
             ADD 1 TO WS-BAD
         END-IF
         ADD SP-F2(WS-ROW) TO WS-NB
     END-PERFORM
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: the chest is pending exactly when the roll is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: about one turn piece in three holds a chest" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NB >= 5 AND WS-NB <= 25
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     EXIT.
 END PROGRAM TEST-STRUCT-36-8-5.

 COPY NOSPAWN.
 COPY CORETEST.
