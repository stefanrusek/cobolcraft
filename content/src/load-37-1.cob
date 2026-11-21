*> The loader of docs/protocol/37-nether-1...md (37-nether-1 sections 1, 2 and 6.9): the Nether shared model and
*> dimension rules (dimension_type with its attributes map, the world preset wiring). LOAD-37-1 USING root (PIC X(1100):
*> the folder that holds data/), status out (CT-OK, or CT-BAD-DATA when any file is rejected; every error is printed on
*> standard error as 'ERROR registry: <registry> <key>: <detail>' and nothing of the part stays loaded).
*> The files of dimension_type, worldgen/world_preset are read through the registry loader and JSON-STRICT (SHAPE-LOAD,
*> shapes.cob) and checked against the type rows below (the field list forms of CTSHAPE.cpy). Files of the registries
*> that phase 22 already loads are also loaded by DIMENSION-TYPES-LOAD (worldgen-*.cob, dimensions.cob), whose errors
*> count for this loader; their store (CTWORLDGEN.cpy) is put back when the part fails. Constraints the shape forms
*> cannot state are noted in the test.
*> 48 2.7: a worldgen/world_preset file is an object with the required member dimensions (an object keyed by level key, each
*> value a typed object: 48 3.23); a dimension_type file requires the members of 48 2.7 as the rows below name them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-37-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTLOAD.
 COPY CTWORLDGEN.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "dimension_type".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "B has_skylight;B has_ceiling;B has_ender_dragon_fight;b has_fixed_time;N coordinate_scale=0.00001..3".
    05 FILLER PIC X(100) VALUE "0000000;I min_y=-2032..2031;I height=16..4064;I logical_height=0..4064;s infiniburn;N ambient_light;".
    05 FILLER PIC X(100) VALUE "V monster_spawn_light_level=int_provider;I monster_spawn_block_light_limit=0..15;e skybox=overworld|".
    05 FILLER PIC X(100) VALUE "none|end;e cardinal_light=default|nether;d default_clock;s timelines;o attributes                   ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "world_preset".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "O dimensions                                                                                        ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 2.
 01 WS-REG-1              PIC X(48) VALUE "dimension_type".
 01 WS-GROUP-1            PIC X(24) VALUE "dimension_type".
 01 WS-REG-2              PIC X(48) VALUE "worldgen/world_preset".
 01 WS-GROUP-2            PIC X(24) VALUE "world_preset".
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
     CALL "DIMENSION-TYPES-LOAD" USING L-DIR WS-S
     ADD RS-ERRORS TO WS-ACC
     MOVE WS-ACC TO RS-ERRORS
     CALL "SHAPE-END" USING L-STATUS
     MOVE WG-COUNTS TO WS-CHOICE(1)
     COMPUTE WS-IX = 1 + FUNCTION MIN(L-STATUS, 1)
     MOVE WS-CHOICE(WS-IX) TO WG-COUNTS
     GOBACK.
 END PROGRAM LOAD-37-1.
