*> The loader of docs/protocol/37-nether-2...md (37-nether-2 sections 2, 4.3, 5.2 and 11): the Nether noise settings,
*> noise definitions and density functions. LOAD-37-2 USING root (PIC X(1100): the folder that holds data/), status out
*> (CT-OK, or CT-BAD-DATA when any file is rejected; every error is printed on standard error as 'ERROR registry:
*> <registry> <key>: <detail>' and nothing of the part stays loaded).
*> The files of worldgen/noise_settings, worldgen/noise are read through the registry loader and JSON-STRICT (SHAPE-LOAD,
*> shapes.cob) and checked against the type rows below (the field list forms of CTSHAPE.cpy). Files of the registries
*> that phase 22 already loads are also loaded by NOISE-SETTINGS-LOAD, NOISES-LOAD, DENSITY-FUNCTIONS-LOAD
*> (worldgen-*.cob, dimensions.cob), whose errors count for this loader; their store (CTWORLDGEN.cpy) is put back when
*> the part fails. Constraints the shape forms cannot state are noted in the test.
*> ASSUMPTION: noise_settings member debug_functions is an array (the document says three labelled entries N, T, V; the
*> member names of an entry are not stated, so entries are not checked).
*> ASSUMPTION: the noise_router members are the eight keys of section 6.9, each a number, a reference string or an object
*> (form X, not checked further).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-37-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTLOAD.
 COPY CTWORLDGEN.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "noise_settings".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "I sea_level;B legacy_random_source;b disable_mob_generation;T noise=noise_bounds;T default_block=blo".
    05 FILLER PIC X(100) VALUE "ck_state;T default_fluid=block_state;R material_rule=material_rule;T noise_router=noise_router;a spa".
    05 FILLER PIC X(100) VALUE "wn_target;a debug_functions;o aquifers                                                              ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "noise_bounds".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "I min_y=-2032..2031;I height=0..4064                                                                ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "block_state".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "S Name;o Properties                                                                                 ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "noise_router".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "X temperature;X vegetation;X continents;X erosion;X depth;X ridges;X chunk_surface_level;X final_den".
    05 FILLER PIC X(100) VALUE "sity                                                                                                ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "noise".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "I base_octave;i octave_count=1..32;N base_amplitude;a amplitude_modifiers;e normalize=enabled|disabl".
    05 FILLER PIC X(100) VALUE "ed|legacy                                                                                           ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 5.
 01 WS-REG-1              PIC X(48) VALUE "worldgen/noise_settings".
 01 WS-GROUP-1            PIC X(24) VALUE "noise_settings".
 01 WS-REG-2              PIC X(48) VALUE "worldgen/noise".
 01 WS-GROUP-2            PIC X(24) VALUE "noise".
 01 WS-STRICT              BINARY-LONG VALUE 0.
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
     CALL "SHAPE-LOAD" USING L-DIR WS-REG-2 WS-GROUP-2 WS-STRICT
*>   Each loader of phase 22 clears the error count: add them up and hand the sum to SHAPE-END.
     MOVE RS-ERRORS TO WS-ACC
     CALL "NOISE-SETTINGS-LOAD" USING L-DIR WS-S
     ADD RS-ERRORS TO WS-ACC
     CALL "NOISES-LOAD" USING L-DIR WS-S
     ADD RS-ERRORS TO WS-ACC
     CALL "DENSITY-FUNCTIONS-LOAD" USING L-DIR WS-S
     ADD RS-ERRORS TO WS-ACC
     MOVE WS-ACC TO RS-ERRORS
     CALL "SHAPE-END" USING L-STATUS
     MOVE WG-COUNTS TO WS-CHOICE(1)
     COMPUTE WS-IX = 1 + FUNCTION MIN(L-STATUS, 1)
     MOVE WS-CHOICE(WS-IX) TO WG-COUNTS
     GOBACK.
 END PROGRAM LOAD-37-2.
