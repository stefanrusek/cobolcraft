*> The loader of docs/protocol/37-nether-2...md (37-nether-2 sections 2, 4.3, 5.2 and 11): the Nether noise settings,
*> noise definitions and density functions. LOAD-37-2 USING root (PIC X(1100): the folder that holds data/), status out
*> (CT-OK, or CT-BAD-DATA when any file is rejected; every error is printed on standard error as 'ERROR registry:
*> <registry> <key>: <detail>' and nothing of the part stays loaded).
*> The files of worldgen/noise_settings, worldgen/noise are read through the registry loader and JSON-STRICT (SHAPE-LOAD,
*> shapes.cob) and checked against the type rows below (the field list forms of CTSHAPE.cpy). Files of the registries
*> that phase 22 already loads are also loaded by NOISE-SETTINGS-LOAD, NOISES-LOAD, DENSITY-FUNCTIONS-LOAD
*> (worldgen-*.cob, dimensions.cob), whose errors count for this loader; their store (CTWORLDGEN.cpy) is put back when
*> the part fails. Constraints the shape forms cannot state are noted in the test.
*> 48 2.7 and 2.8: noise_settings requires debug_functions (an array of {function, label}, both required, function an id or a
*> density function object), default_block and default_fluid (block states: a block id or {id, properties?}, form Q), and the eight
*> noise_router members (each a number, a reference id or an object, form X); the spawn_target boxes are read by NOISE-SETTINGS-LOAD.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-37-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTLOAD.
 COPY CTWORLDGEN.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "noise_settings".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "I sea_level;B legacy_random_source;B disable_mob_generation;T noise=noise_boun" &
        "ds;Q default_block;Q default_fluid;R material_rule=material_rule;T noise_route" &
        "r=noise_router;A spawn_target;L debug_functions=debug_function;o aquifers".
    05 FILLER PIC X(24) VALUE "noise_bounds".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "I min_y=-2032..2031;I height=0..4064".
    05 FILLER PIC X(24) VALUE "debug_function".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "X function;S label".
    05 FILLER PIC X(24) VALUE "noise_router".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "X temperature;X vegetation;X continents;X erosion;X depth;X ridges;X chunk_sur" &
        "face_level;X final_density".
    05 FILLER PIC X(24) VALUE "noise".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "I base_octave;i octave_count=1..32;N base_amplitude;a amplitude_modifiers;e no" &
        "rmalize=enabled|disabled|legacy".
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
