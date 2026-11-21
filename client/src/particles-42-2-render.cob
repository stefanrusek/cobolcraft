*> Particles part 2, section 4 (docs/protocol/42-particles-2-effects-fire-smoke-magic.md): rendering of
*> these particles: the fragment discard, the layers, the pipelines and the atlas, the quad colour.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FRAG-DISCARD.
*> Section 4 particle.fsh: USING vertex alpha, texel alpha, discard out: a fragment whose alpha (vertex alpha
*> times texel alpha) is below 0.1 is discarded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ALPHA                FLOAT-LONG.
 01 L-TEXEL                FLOAT-LONG.
 01 L-DISCARD              BINARY-LONG.
 PROCEDURE DIVISION USING L-ALPHA L-TEXEL L-DISCARD.
     COMPUTE WS-A = L-ALPHA * L-TEXEL
     MOVE 0 TO L-DISCARD
     IF WS-A < 0.1
         MOVE 1 TO L-DISCARD
     END-IF
     GOBACK.
 END PROGRAM P2-FRAG-DISCARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-RENDER-FACTS.
*> Section 4: USING facing mode out (0 LOOKAT_XYZ for every particle of this part), atlas name out, atlas
*> source directory out (the whole `particle` directory, empty prefix), atlas definition file out, discard
*> threshold out (0.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-ATLAS                PIC X(16).
 01 L-PREFIX               PIC X(16).
 01 L-FILE                 PIC X(48).
 01 L-THRESHOLD            FLOAT-LONG.
 PROCEDURE DIVISION USING L-MODE L-ATLAS L-PREFIX L-FILE L-THRESHOLD.
     MOVE 0 TO L-MODE
     MOVE "particles" TO L-ATLAS
     MOVE SPACES TO L-PREFIX
     MOVE "assets/minecraft/atlases/particles.json" TO L-FILE
     MOVE 0.1 TO L-THRESHOLD
     GOBACK.
 END PROGRAM P2-RENDER-FACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-PIPELINE.
*> Section 4: USING layer (0 OPAQUE, 1 TRANSLUCENT), blending out: the opaque pipeline does not blend (0), the
*> translucent pipeline uses the standard translucent blend function (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LAYER                BINARY-LONG.
 01 L-BLEND                BINARY-LONG.
 PROCEDURE DIVISION USING L-LAYER L-BLEND.
     MOVE 0 TO L-BLEND
     IF L-LAYER = 1
         MOVE 1 TO L-BLEND
     END-IF
     GOBACK.
 END PROGRAM P2-PIPELINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-QUAD-ARGB.
*> Section 4: USING alpha, red, green, blue, ARGB out: colorFromFloat(alpha, r, g, b) of section 2.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-ARGB                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-A L-R L-G L-B L-ARGB.
     CALL "PART-COLOR-PACK" USING L-A L-R L-G L-B L-ARGB
     GOBACK.
 END PROGRAM P2-QUAD-ARGB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-LAYER-OF.
*> Section 4 and V14: USING type name, layer out (0 OPAQUE, 1 TRANSLUCENT, 2 no particle layer: an unknown
*> type, the no-render emitter and the elder guardian group).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP2IX.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-LAYER                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-LAYER.
     CALL "P2-INDEX" USING L-TYPE P2IX
     IF P2-FOUND = 0
         MOVE 2 TO L-LAYER
     ELSE
         MOVE P2-LAYER TO L-LAYER
     END-IF
     GOBACK.
 END PROGRAM P2-LAYER-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-ALPHA-ON-OPAQUE.
*> Section 4: USING type name, flag out: 1 for dolphin, whose alpha 0.3 to 1.0 is set on an OPAQUE-layer class
*> (every other class here that sets an alpha below 1 is translucent).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-TYPE = "dolphin"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM P2-ALPHA-ON-OPAQUE.
