*> T6600 (lane 002-lane-fixb, B1): the render layer of a sprite follows 08 section 5.3 (SpriteContents.computeTransparency): fully opaque,
*> cut out (some pixels have alpha 0, all others 255) or translucent (some pixel has an alpha that is neither 0 nor 255). Only the translucent
*> sprites go to the translucent mesh; a cut-out sprite (oak leaves, doors, trapdoors, panes, plants) goes to the opaque mesh, where the
*> shader drops the clear texels and the depth buffer orders the faces. Before this every sprite with a pixel below alpha 255 was translucent:
*> the leaves, doors and trapdoors were drawn without depth writes, in cell order, blended over each other.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ATLAS-LAYER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-OUT                 PIC 9.
 01 WS-OPAQUE              PIC X(16).
 01 WS-CUTOUT              PIC X(16).
 01 WS-PARTIAL             PIC X(16).
 01 WS-LAST                PIC X(16).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   Four opaque pixels (alpha FF).
     MOVE X"102030FF" & X"102030FF" & X"102030FF" & X"102030FF" TO WS-OPAQUE
     CALL "ATLAS-TRANSLUCENT" USING WS-OPAQUE WS-COUNT WS-OUT
     MOVE "T6600 layer: a sprite with every alpha 255 is not translucent" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Cut out: two clear pixels (alpha 0), two opaque.
     MOVE X"10203000" & X"102030FF" & X"00000000" & X"102030FF" TO WS-CUTOUT
     CALL "ATLAS-TRANSLUCENT" USING WS-CUTOUT WS-COUNT WS-OUT
     MOVE "T6600 layer: a cut-out sprite (alpha 0 and 255 only: leaves, doors, trapdoors) is not translucent" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Translucent: one pixel of alpha 0xB0, the others opaque (ice, water, stained glass).
     MOVE X"102030FF" & X"102030B0" & X"102030FF" & X"102030FF" TO WS-PARTIAL
     CALL "ATLAS-TRANSLUCENT" USING WS-PARTIAL WS-COUNT WS-OUT
     MOVE "T6600 layer: a sprite with a partial alpha (ice) is translucent" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The last pixel counts too, and alpha 1 is partial.
     MOVE X"102030FF" & X"102030FF" & X"102030FF" & X"10203001" TO WS-LAST
     CALL "ATLAS-TRANSLUCENT" USING WS-LAST WS-COUNT WS-OUT
     MOVE "T6600 layer: alpha 1 in the last pixel is partial: translucent" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
