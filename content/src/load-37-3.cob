*> The loader of docs/protocol/37-nether-3...md (37-nether-3 sections 2.1 and 6.1): the Nether biome source preset and
*> the five biome definitions. LOAD-37-3 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-
*> BAD-DATA when any file is rejected; every error is printed on standard error as 'ERROR registry: <registry> <key>:
*> <detail>' and nothing of the part stays loaded).
*> The files of worldgen/biome, worldgen/multi_noise_biome_source_parameter_list are read through the registry loader and
*> JSON-STRICT (SHAPE-LOAD, shapes.cob) and checked against the type rows below (the field list forms of CTSHAPE.cpy).
*> Files of the registries that phase 22 already loads are also loaded by BIOMES-LOAD, BIOME-SOURCES-LOAD
*> (worldgen-*.cob, dimensions.cob), whose errors count for this loader; their store (CTWORLDGEN.cpy) is put back when
*> the part fails. Constraints the shape forms cannot state are noted in the test.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-37-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTLOAD.
 COPY CTWORLDGEN.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "biome".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "N temperature;N downfall;B has_precipitation;e temperature_modifier=none|frozen;T effects=biome_effe".
    05 FILLER PIC X(100) VALUE "cts;o attributes;H carvers=carver;A features                                                        ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "biome_effects".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "X water_color;x foliage_color;x dry_foliage_color;x grass_color;e grass_color_modifier=none|dark_for".
    05 FILLER PIC X(100) VALUE "est|swamp                                                                                           ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "biome_source_preset".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "E preset=overworld|nether                                                                           ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 3.
 01 WS-REG-1              PIC X(48) VALUE "worldgen/biome".
 01 WS-GROUP-1            PIC X(24) VALUE "biome".
 01 WS-REG-2              PIC X(48) VALUE "worldgen/multi_noise_biome_source_parameter_list".
 01 WS-GROUP-2            PIC X(24) VALUE "biome_source_preset".
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
     CALL "BIOMES-LOAD" USING L-DIR WS-S
     ADD RS-ERRORS TO WS-ACC
     CALL "BIOME-SOURCES-LOAD" USING L-DIR WS-S
     ADD RS-ERRORS TO WS-ACC
     MOVE WS-ACC TO RS-ERRORS
     CALL "SHAPE-END" USING L-STATUS
     MOVE WG-COUNTS TO WS-CHOICE(1)
     COMPUTE WS-IX = 1 + FUNCTION MIN(L-STATUS, 1)
     MOVE WS-CHOICE(WS-IX) TO WG-COUNTS
     GOBACK.
 END PROGRAM LOAD-37-3.
