*> Acceptance test of docs/protocol/42-particles-1-shared-model-engine.md section 9 (files the extraction
*> tool must write): the 115 definition files (114 sprite-registered names plus ambient_entity_effect),
*> the atlas definition and texture paths, the language keys of the Particles option.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-1-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-I                   BINARY-LONG.
 01 WS-PATH                PIC X(96).
 01 WS-LISTING.
    05 WS-L-COUNT          BINARY-LONG.
    05 WS-L-FILE           PIC X(96) OCCURS 128 TIMES.
 01 WS-MISSING             BINARY-LONG.
 01 WS-REDUNDANT           BINARY-LONG.
 01 WS-EXPECTED            BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ATLAS               PIC X(96).
 01 WS-DIR                 PIC X(96).
 01 WS-PNG                 BINARY-LONG.
 01 WS-META                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 PROCEDURE DIVISION.
     CALL "PFILES-COUNT" USING WS-EXPECTED
     MOVE "114 sprite-registered types need a definition file" TO WS-NAME
     MOVE 114 TO TL-EXPECTED-N
     MOVE WS-EXPECTED TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-I
     CALL "PFILES-PATH" USING WS-I WS-PATH
     MOVE "definition path of the first sprite type (angry_villager)" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "assets/minecraft/particles/angry_villager.json" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 114 TO WS-I
     CALL "PFILES-PATH" USING WS-I WS-PATH
     MOVE "definition path of the last sprite type (sulfur_cube_goo)" TO WS-NAME
     MOVE "assets/minecraft/particles/sulfur_cube_goo.json" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 2 TO WS-I
     CALL "PFILES-PATH" USING WS-I WS-PATH
     MOVE "the plain provider block (id 1) has no file, so index 2 is bubble" TO WS-NAME
     MOVE "assets/minecraft/particles/bubble.json" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 115 TO WS-I
     CALL "PFILES-PATH" USING WS-I WS-PATH
     MOVE "an index past 114 has no path" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     PERFORM ASSERT-TEXT
*>   A complete listing (114 files + ambient_entity_effect): nothing missing, one redundant.
     MOVE 115 TO WS-L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 114
         CALL "PFILES-PATH" USING WS-I WS-L-FILE(WS-I)
     END-PERFORM
     MOVE "assets/minecraft/particles/ambient_entity_effect.json" TO WS-L-FILE(115)
     CALL "PFILES-CHECK" USING WS-LISTING WS-MISSING WS-REDUNDANT
     MOVE "115 files: none missing, ambient_entity_effect redundant" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 0 * 10 + 1
     COMPUTE TL-OBSERVED-N = WS-MISSING * 10 + WS-REDUNDANT
     PERFORM ASSERT-NUMBER
*>   Drop ambient_entity_effect (allowed) and one real file: one missing, nothing redundant.
     MOVE 113 TO WS-L-COUNT
     CALL "PFILES-CHECK" USING WS-LISTING WS-MISSING WS-REDUNDANT
     MOVE "113 files: the file dropped from the list of 114 is missing, nothing redundant" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1 * 10 + 0
     COMPUTE TL-OBSERVED-N = WS-MISSING * 10 + WS-REDUNDANT
     PERFORM ASSERT-NUMBER
     MOVE 114 TO WS-L-COUNT
     CALL "PFILES-CHECK" USING WS-LISTING WS-MISSING WS-REDUNDANT
     MOVE "114 files: the standard pack without ambient_entity_effect is complete" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MISSING * 10 + WS-REDUNDANT
     PERFORM ASSERT-NUMBER
     CALL "PFILES-ATLAS" USING WS-ATLAS WS-DIR WS-PNG WS-META
     MOVE "atlas definition path" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "assets/minecraft/atlases/particles.json" TO TL-EXPECTED
     MOVE WS-ATLAS TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "particle texture directory" TO WS-NAME
     MOVE "assets/minecraft/textures/particle/" TO TL-EXPECTED
     MOVE WS-DIR TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "vanilla validation numbers: 300 PNG and 1 mcmeta under textures/particle" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 300 * 10 + 1
     COMPUTE TL-OBSERVED-N = WS-PNG * 10 + WS-META
     PERFORM ASSERT-NUMBER
     PERFORM VARYING WS-STATUS FROM 0 BY 1 UNTIL WS-STATUS > 3
         CALL "PFILES-LANG-KEY" USING WS-STATUS WS-KEY
         MOVE "language key of the Particles option and its three values" TO WS-NAME
         MOVE "T" TO TL-MODE
         EVALUATE WS-STATUS
             WHEN 0
                 MOVE "options.particles.all" TO TL-EXPECTED
             WHEN 1
                 MOVE "options.particles.decreased" TO TL-EXPECTED
             WHEN 2
                 MOVE "options.particles.minimal" TO TL-EXPECTED
             WHEN OTHER
                 MOVE "options.particles" TO TL-EXPECTED
         END-EVALUATE
         MOVE WS-KEY TO TL-OBSERVED
         PERFORM ASSERT-TEXT
     END-PERFORM
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-1§9 Files the extraction tool must write: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-1§9 Files the extraction tool must write: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-1-9.
