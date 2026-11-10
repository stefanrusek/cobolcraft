*> Acceptance test of docs/protocol/42-particles-2-effects-fire-smoke-magic.md section 4 (rendering of
*> these particles): the fragment discard below alpha 0.1, the layer of each type (V14), the pipelines,
*> the particles atlas, camera-facing quads, the colour packing and the dolphin alpha on the opaque layer.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-2-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-TYPE                PIC X(24).
 01 WS-ALPHA               FLOAT-LONG.
 01 WS-TEXEL               FLOAT-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-ATLAS               PIC X(16).
 01 WS-PREFIX              PIC X(16).
 01 WS-FILE                PIC X(48).
 01 WS-THRESHOLD           FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-ARGB                BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0.09 TO WS-ALPHA
     MOVE 1.0 TO WS-TEXEL
     CALL "P2-FRAG-DISCARD" USING WS-ALPHA WS-TEXEL WS-FLAG
     MOVE "alpha 0.09 is discarded" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.1 TO WS-ALPHA
     CALL "P2-FRAG-DISCARD" USING WS-ALPHA WS-TEXEL WS-FLAG
     MOVE "alpha 0.1 is kept (the test is below 0.1)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.5 TO WS-ALPHA
     MOVE 0.15 TO WS-TEXEL
     CALL "P2-FRAG-DISCARD" USING WS-ALPHA WS-TEXEL WS-FLAG
     MOVE "vertex alpha 0.5 times texel alpha 0.15 = 0.075 is discarded" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.5 TO WS-ALPHA
     MOVE 0.5 TO WS-TEXEL
     CALL "P2-FRAG-DISCARD" USING WS-ALPHA WS-TEXEL WS-FLAG
     MOVE "vertex alpha 0.5 times texel alpha 0.5 = 0.25 is kept" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "P2-RENDER-FACTS" USING WS-MODE WS-ATLAS WS-PREFIX WS-FILE WS-THRESHOLD
     MOVE "every particle of this part is camera-facing (LOOKAT_XYZ, mode 0)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MODE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "both layers draw from the particles atlas" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "particles" TO TL-EXPECTED
     MOVE WS-ATLAS TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "the atlas sources the whole particle directory with an empty prefix" TO WS-NAME
     MOVE "particle|" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "particle|" FUNCTION TRIM(WS-PREFIX) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "the atlas definition file" TO WS-NAME
     MOVE "assets/minecraft/atlases/particles.json" TO TL-EXPECTED
     MOVE WS-FILE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "the discard threshold is 0.1 (hundredths)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 10
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-THRESHOLD * 100 + 0.5)
     MOVE "N" TO TL-MODE
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-LAYER
     CALL "P2-PIPELINE" USING WS-LAYER WS-FLAG
     MOVE "the OPAQUE layer uses the particle pipeline with no blending" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-LAYER
     CALL "P2-PIPELINE" USING WS-LAYER WS-FLAG
     MOVE "the TRANSLUCENT layer uses the standard translucent blend" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.5 TO WS-ALPHA
     MOVE 1.0 TO WS-R
     MOVE 0.0 TO WS-G
     MOVE 0.3 TO WS-B
     CALL "P2-QUAD-ARGB" USING WS-ALPHA WS-R WS-G WS-B WS-ARGB
     MOVE "quad colour is colorFromFloat(alpha, r, g, b) with truncation" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 127 * 16777216 + 255 * 65536 + 76
     MOVE WS-ARGB TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   V14 layers: translucent types, then a few opaque ones.
     MOVE 1 TO TL-EXPECTED-N
     MOVE "cloud" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "sneeze" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "effect" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "instant_effect" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "entity_effect" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "witch" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "infested" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "end_rod" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "totem_of_undying" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "firework" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "flash" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "soul" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "campfire_cosy_smoke" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "campfire_signal_smoke" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE 0 TO TL-EXPECTED-N
     MOVE "heart" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "dolphin" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "flame" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "smoke" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "lava" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "portal" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "no_such_particle" TO WS-TYPE
     MOVE 2 TO TL-EXPECTED-N
     PERFORM CHK-LAYER
     MOVE "explosion_emitter" TO WS-TYPE
     PERFORM CHK-LAYER
     MOVE "dolphin" TO WS-TYPE
     CALL "P2-ALPHA-ON-OPAQUE" USING WS-TYPE WS-FLAG
     MOVE "dolphin sets alpha 0.3 to 1.0 but is drawn on the opaque layer" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "sneeze" TO WS-TYPE
     CALL "P2-ALPHA-ON-OPAQUE" USING WS-TYPE WS-FLAG
     MOVE "sneeze (alpha 0.4) is translucent, not an alpha-on-opaque case" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 CHK-LAYER.
     CALL "P2-LAYER-OF" USING WS-TYPE WS-LAYER
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-TYPE) " layer (0 opaque, 1 translucent, 2 none)" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-LAYER TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-2§4 Rendering of these particles: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-2§4 Rendering of these particles: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE.
 END PROGRAM TEST-PARTICLES-42-2-4.
