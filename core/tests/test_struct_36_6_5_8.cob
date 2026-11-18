*> Acceptance test of the geometry of the ocean monument's room, wing and penthouse pieces (docs/protocol/36-structures-6-ocean.md section 5.8, with the helpers of 5.6; core/src/struct-mon-room.cob, struct-mon-geo.cob):
*> every piece kind (entry, core, simple with the three designs, simple top with the sponge draws, double X, Y, Z, XY, YZ, both wings, the penthouse) is drawn in each of the four directions with openings of the
*> cells all closed, all open and scattered, with and without up links and on the bottom and the upper layers, over the four chunk windows around it, and every window is compared (by checksum) with the model of
*> core/tests/fixtures/gen_monument.py, which reads the rows of the document's tables and writes the passes the text describes (core/tests/MONCASES.cpy). The placement random of every window is the Xoroshiro
*> stream of a fixed seed. Elder guardians (the wings and the penthouse) are requested from the entity channel at the cells of the model.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-5-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 COPY MTDATA.
 COPY GENENT.
 COPY MONCASES.
 01 WS-KINDS.
    05 FILLER              PIC X(10) VALUE "entry     ".
    05 FILLER              PIC X(10) VALUE "core      ".
    05 FILLER              PIC X(10) VALUE "simple    ".
    05 FILLER              PIC X(10) VALUE "simple top".
    05 FILLER              PIC X(10) VALUE "double X  ".
    05 FILLER              PIC X(10) VALUE "double Y  ".
    05 FILLER              PIC X(10) VALUE "double Z  ".
    05 FILLER              PIC X(10) VALUE "double XY ".
    05 FILLER              PIC X(10) VALUE "double YZ ".
    05 FILLER              PIC X(10) VALUE "wing      ".
    05 FILLER              PIC X(10) VALUE "penthouse ".
 01 WS-KIND-TAB REDEFINES WS-KINDS.
    05 WS-KIND-NAME        PIC X(10) OCCURS 11 TIMES.
 01 WS-CASE                BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-OK                  BINARY-LONG.
 01 WS-EH                  BINARY-DOUBLE.
 01 WS-EN                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-ORIENT              BINARY-LONG.
 01 WS-BW                  BINARY-LONG.
 01 WS-BH                  BINARY-LONG.
 01 WS-BD                  BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 2.
 01 WS-Y                   BINARY-LONG VALUE 40.
 01 WS-Z                   BINARY-LONG VALUE 2.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-NAME                PIC X(120).
 01 WS-D                   PIC 9.
 01 WS-DS                  PIC 9.
 01 WS-MASKS               PIC X(8).
 01 WS-G                   PIC 9.
 01 WS-DIMS.
    05 FILLER              PIC X(6) VALUE "080408".
    05 FILLER              PIC X(6) VALUE "160816".
    05 FILLER              PIC X(6) VALUE "080408".
    05 FILLER              PIC X(6) VALUE "080408".
    05 FILLER              PIC X(6) VALUE "160408".
    05 FILLER              PIC X(6) VALUE "080808".
    05 FILLER              PIC X(6) VALUE "080416".
    05 FILLER              PIC X(6) VALUE "160808".
    05 FILLER              PIC X(6) VALUE "081616".
    05 FILLER              PIC X(6) VALUE "230821".
    05 FILLER              PIC X(6) VALUE "140514".
 01 WS-DIM-TAB REDEFINES WS-DIMS.
    05 WS-DIM OCCURS 11 TIMES.
       10 WS-DIM-W         PIC 99.
       10 WS-DIM-H         PIC 99.
       10 WS-DIM-D         PIC 99.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "MT-SETUP"
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > MC-PIECES
         PERFORM RUN-CASE
     END-PERFORM
     PERFORM CELL-CASES
     GOBACK.

*> 5.8: the cells of a double room: B east of A for X and XY, north of A for Z and YZ, C above A, D above B; the wings and the penthouse are the slots 76 to 78
 CELL-CASES.
     MOVE 12 TO MD-CONN(11, 6)
     MOVE 13 TO MD-CONN(11, 3)
     MOVE 14 TO MD-CONN(11, 2)
     MOVE 15 TO MD-CONN(12, 2)
     MOVE 16 TO MD-CONN(13, 2)
     MOVE 10 TO MC-INDEX(1)
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 7
         EVALUATE WS-CASE
             WHEN 1 MOVE 5 TO MC-KIND(1)
             WHEN 2 MOVE 7 TO MC-KIND(1)
             WHEN 3 MOVE 6 TO MC-KIND(1)
             WHEN 4 MOVE 8 TO MC-KIND(1)
             WHEN 5 MOVE 9 TO MC-KIND(1)
             WHEN 6 MOVE 3 TO MC-KIND(1)
             WHEN OTHER MOVE 10 TO MC-KIND(1)
         END-EVALUATE
         IF WS-CASE = 7
             MOVE 1002 TO MC-INDEX(1)
         END-IF
         MOVE 1 TO WS-I
         CALL "MONP-CELLS" USING WS-I
         MOVE 0 TO WS-OK
         EVALUATE WS-CASE
             WHEN 1
                 IF MP-CELL(1) = 11 AND MP-CELL(2) = 12 AND MP-CELL(3) = 0 AND MP-CELL(4) = 0
                     MOVE 1 TO WS-OK
                 END-IF
             WHEN 2
                 IF MP-CELL(1) = 11 AND MP-CELL(2) = 13 AND MP-CELL(3) = 0 AND MP-CELL(4) = 0
                     MOVE 1 TO WS-OK
                 END-IF
             WHEN 3
                 IF MP-CELL(1) = 11 AND MP-CELL(2) = 0 AND MP-CELL(3) = 14 AND MP-CELL(4) = 0
                     MOVE 1 TO WS-OK
                 END-IF
             WHEN 4
                 IF MP-CELL(1) = 11 AND MP-CELL(2) = 12 AND MP-CELL(3) = 14 AND MP-CELL(4) = 15
                     MOVE 1 TO WS-OK
                 END-IF
             WHEN 5
                 IF MP-CELL(1) = 11 AND MP-CELL(2) = 13 AND MP-CELL(3) = 14 AND MP-CELL(4) = 16
                     MOVE 1 TO WS-OK
                 END-IF
             WHEN 6
                 IF MP-CELL(1) = 11 AND MP-CELL(2) = 0 AND MP-CELL(3) = 0 AND MP-CELL(4) = 0
                     MOVE 1 TO WS-OK
                 END-IF
             WHEN OTHER
                 IF MP-CELL(1) = 77 AND MP-CELL(2) = 0 AND MP-CELL(3) = 0 AND MP-CELL(4) = 0
                     MOVE 1 TO WS-OK
                 END-IF
         END-EVALUATE
         MOVE WS-CASE TO WS-D
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§5.8 Geometry of the room, wing and penthouse pieces: the cells A to D of child kind case " WS-D " are those of the document" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-OK TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM.

*> one case: the cells' slots 60 to 63 get the open flags and up links of the case, the piece row is the scratch row SP-MAX with the box of the case
 RUN-CASE.
     MOVE MC-P-KIND(WS-CASE) TO WS-KIND
     MOVE MC-P-DIR(WS-CASE) TO WS-DIR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-J = 59 + WS-I
         MOVE MC-P-MASK(WS-CASE, WS-I) TO WS-M
         PERFORM VARYING WS-BIT FROM 1 BY 1 UNTIL WS-BIT > 6
             MOVE FUNCTION MOD(WS-M, 2) TO MD-OPEN(WS-J, WS-BIT)
             COMPUTE WS-M = WS-M / 2
         END-PERFORM
         MOVE 0 TO MD-CONN(WS-J, 2)
         COMPUTE WS-M = MC-P-UP(WS-CASE)
         PERFORM VARYING WS-BIT FROM 2 BY 1 UNTIL WS-BIT > WS-I
             COMPUTE WS-M = WS-M / 2
         END-PERFORM
         IF FUNCTION MOD(WS-M, 2) = 1
             MOVE 64 TO MD-CONN(WS-J, 2)
         END-IF
         MOVE 0 TO MD-INDEX(WS-J)
         IF MC-P-GRIDY(WS-CASE) = 1
             MOVE 25 TO MD-INDEX(WS-J)
         END-IF
     END-PERFORM
     EVALUATE WS-KIND
         WHEN 1 WHEN 2 WHEN 3 WHEN 4
             MOVE 1 TO WS-USED
         WHEN 5 WHEN 7
             MOVE 2 TO WS-USED
         WHEN 6
             MOVE 3 TO WS-USED
         WHEN 8 WHEN 9
             MOVE 4 TO WS-USED
         WHEN OTHER
             MOVE 0 TO WS-USED
     END-EVALUATE
     MOVE 0 TO MP-CELL(1) MP-CELL(2) MP-CELL(3) MP-CELL(4)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-USED
         COMPUTE MP-CELL(WS-I) = 59 + WS-I
     END-PERFORM
     IF WS-KIND = 6
         MOVE 0 TO MP-CELL(2)
     END-IF
     MOVE MC-P-DESIGN(WS-CASE) TO MP-DESIGN
     MOVE 0 TO MP-PILLAR
     MOVE WS-DIM-W(WS-KIND) TO WS-BW
     MOVE WS-DIM-H(WS-KIND) TO WS-BH
     MOVE WS-DIM-D(WS-KIND) TO WS-BD
     COMPUTE WS-ORIENT = FUNCTION MOD(WS-DIR + 2, 4)
     CALL "SPB-MAKE-BOX" USING WS-X WS-Y WS-Z WS-ORIENT WS-BW WS-BH WS-BD WS-BOX
     MOVE SP-MAX TO MP-ROW
     MOVE WS-ORIENT TO SP-ORIENT(SP-MAX)
     MOVE B-X0 TO SP-X0(SP-MAX)
     MOVE B-Y0 TO SP-Y0(SP-MAX)
     MOVE B-Z0 TO SP-Z0(SP-MAX)
     MOVE B-X1 TO SP-X1(SP-MAX)
     MOVE B-Y1 TO SP-Y1(SP-MAX)
     MOVE B-Z1 TO SP-Z1(SP-MAX)
     MOVE 0 TO WS-OK WS-EH WS-EN
     PERFORM VARYING WS-W FROM 0 BY 1 UNTIL WS-W > 3
         COMPUTE WS-CX = FUNCTION MOD(WS-W, 2)
         COMPUTE WS-CZ = WS-W / 2
         COMPUTE WS-SEED = 1000 + WS-W
         CALL "MT-WINDOW" USING WS-CX WS-CZ
         CALL "MT-SEED" USING WS-SEED
         MOVE 0 TO GEL-COUNT GEL-LOST
         CALL "MONP-PIECE" USING WS-KIND
         CALL "MT-HASH" USING WS-CX WS-CZ WS-HASH
         CALL "MT-ELDER-HASH" USING WS-EH WS-EN
         COMPUTE WS-J = WS-W + 1
         MOVE MC-P-HASH(WS-CASE, WS-J) TO WS-WANT
         IF WS-HASH = WS-WANT
             ADD 1 TO WS-OK
         END-IF
     END-PERFORM
     MOVE WS-DIR TO WS-D
     MOVE MC-P-DESIGN(WS-CASE) TO WS-DS
     MOVE MC-P-GRIDY(WS-CASE) TO WS-G
     MOVE SPACES TO WS-NAME
     STRING "acceptance US12 36-6§5.8 " FUNCTION TRIM(WS-KIND-NAME(WS-KIND)) " direction " WS-D " design " WS-DS " upper layer " WS-G " masks " MC-P-MASK(WS-CASE, 1) "," MC-P-MASK(WS-CASE, 2)
         "," MC-P-MASK(WS-CASE, 3) "," MC-P-MASK(WS-CASE, 4) " up " MC-P-UP(WS-CASE) ": the four windows are the model's" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-KIND >= 10
         MOVE MC-P-ELDER-HASH(WS-CASE) TO WS-WANT
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§5.10 " FUNCTION TRIM(WS-KIND-NAME(WS-KIND)) " direction " WS-D " design " WS-DS ": the elder guardian is asked for at the model's cell" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         IF WS-EH NOT = WS-WANT OR WS-EN NOT = MC-P-ELDERS(WS-CASE)
             MOVE 1 TO TL-OBSERVED-N
         ELSE
             MOVE 0 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF.

 END PROGRAM TEST-STRUCT-36-6-5-8.
 COPY MONTEST.
 COPY NOSPAWN.
 COPY CORETEST.
