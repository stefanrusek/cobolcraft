*> The loader of docs/protocol/37-nether-4...md (37-nether-4 sections 5 and 6.1): the Nether surface rules and the
*> nether_cave carver. LOAD-37-4 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA
*> when any file is rejected; every error is printed on standard error as 'ERROR registry: <registry> <key>: <detail>'
*> and nothing of the part stays loaded).
*> The files of worldgen/carver are read through the registry loader and JSON-STRICT (SHAPE-LOAD, shapes.cob) and checked
*> against the type rows below (the field list forms of CTSHAPE.cpy). Files of the registries that phase 22 already loads
*> are also loaded by MATERIAL-RULES-LOAD, CARVERS-LOAD (worldgen-*.cob, dimensions.cob), whose errors count for this
*> loader; their store (CTWORLDGEN.cpy) is put back when the part fails. Constraints the shape forms cannot state are
*> noted in the test.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-37-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTLOAD.
 COPY CTWORLDGEN.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "carver".
    05 FILLER PIC X(48) VALUE "cave".
    05 FILLER PIC X(100) VALUE "N probability=0..1;V y=height_provider;V count=int_provider;V floor_level=float_provider;V horizonta".
    05 FILLER PIC X(100) VALUE "l_radius_multiplier=float_provider;V vertical_radius_multiplier=float_provider;V room_vertical_radiu".
    05 FILLER PIC X(100) VALUE "s_multiplier=float_provider;V thickness=float_provider;b weird_thickness_bias;v start_vertical_radiu".
    05 FILLER PIC X(100) VALUE "s_multiplier=float_provider                                                                         ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "carver".
    05 FILLER PIC X(48) VALUE "canyon".
    05 FILLER PIC X(100) VALUE "N probability=0..1;V y=height_provider;V vertical_rotation=float_provider;T shape=canyon_shape      ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "canyon_shape".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "V distance_factor=float_provider;V horizontal_radius_factor=float_provider;V thickness=float_provide".
    05 FILLER PIC X(100) VALUE "r;V vertical_radius_center_factor=float_provider;V vertical_radius_default_factor=float_provider;I w".
    05 FILLER PIC X(100) VALUE "idth_smoothness;V y_scale=float_provider                                                            ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 3.
 01 WS-REG-1              PIC X(48) VALUE "worldgen/carver".
 01 WS-GROUP-1            PIC X(24) VALUE "carver".
 01 WS-STRICT              BINARY-LONG VALUE 1.
 01 WS-CHOICES.
    05 WS-CHOICE OCCURS 2 TIMES.
       10 WS-CHOICE-COUNT   BINARY-LONG OCCURS 4 TIMES.
 01 WS-IX                 BINARY-LONG.
 01 WS-ACC                BINARY-LONG.
 01 WS-S                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
*>   The store of phase 22 as it was, to put back when the part fails.
     MOVE WG-COUNTS TO WS-CHOICE(2)
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REG-1 WS-GROUP-1 WS-STRICT
*>   Each loader of phase 22 clears the error count: add them up and hand the sum to SHAPE-END.
     MOVE RS-ERRORS TO WS-ACC
     CALL "MATERIAL-RULES-LOAD" USING L-DIR WS-S
     ADD RS-ERRORS TO WS-ACC
     CALL "CARVERS-LOAD" USING L-DIR WS-S
     ADD RS-ERRORS TO WS-ACC
     MOVE WS-ACC TO RS-ERRORS
     CALL "SHAPE-END" USING L-STATUS
     MOVE WG-COUNTS TO WS-CHOICE(1)
     COMPUTE WS-IX = 1 + FUNCTION MIN(L-STATUS, 1)
     MOVE WS-CHOICE(WS-IX) TO WG-COUNTS
     GOBACK.
 END PROGRAM LOAD-37-4.
