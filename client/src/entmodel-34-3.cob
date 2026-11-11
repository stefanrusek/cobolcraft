*> Entity models part 3 (docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md) section 0: the engine pieces these models rely on.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EM3-SCALED-LAYER field(X(28), the ModelLayers field name) flag(out BINARY-LONG): 1 for the eight layers of 0.1 item 7 that carry the 0.9375 root.
*>   EM3-ENTITY-Y IN(scaled, model y) OUT(height above the entity origin in blocks, 0.1 item 8).
*>   EM3-PLANE-FACES IN(w h d) OUT(number of the six faces of a cuboid that have a non-zero area, 0.1 item 4).
*>   EM3-TRIANGLE IN(x, period) OUT(Mth.triangleWave, section 5 and 7 and the validation item 6).
*>   EM3-STATE-TIME IN(age, startTick, speed) OUT(getTimeInMillis scaled by the speed with the two truncations of 0.2, 1 when the state is started).
*>   EM3-STATE-FF IN(startTick, ticks, speed) OUT(new startTick after fastForward, 0.2).
*>   EM3-RENDER-MODEL-TYPE field(X(28)) type(X(24), out): the model's own render type (0.3 item 3). EM3-BODY-VISIBLE IN(invisible, illusioner) OUT(isBodyVisible).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-SCALED-LAYER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIELD                PIC X(28).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FIELD L-FLAG.
     MOVE 0 TO L-FLAG
     EVALUATE L-FIELD
         WHEN "VILLAGER" WHEN "VILLAGER_NO_HAT" WHEN "WANDERING_TRADER" WHEN "PILLAGER" WHEN "VINDICATOR" WHEN "EVOKER" WHEN "ILLUSIONER" WHEN "WITCH"
             MOVE 1 TO L-FLAG
     END-EVALUATE
     GOBACK.
 END PROGRAM EM3-SCALED-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ENTITY-Y.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(1) NOT = 0
         COMPUTE L-O(1) = 1.4071875 - 0.05859375 * L-I(2)
     ELSE
         COMPUTE L-O(1) = 1.501 - L-I(2) / 16
     END-IF
     GOBACK.
 END PROGRAM EM3-ENTITY-Y.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-PLANE-FACES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) * L-I(3) NOT = 0
         ADD 2 TO L-O(1)
     END-IF
     IF L-I(3) * L-I(2) NOT = 0
         ADD 2 TO L-O(1)
     END-IF
     IF L-I(1) * L-I(2) NOT = 0
         ADD 2 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EM3-PLANE-FACES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-TRIANGLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) - L-I(2) * FUNCTION INTEGER-PART(L-I(1) / L-I(2))
     COMPUTE L-O(1) = (FUNCTION ABS(L-O(1) - L-I(2) / 2) - L-I(2) / 4) / (L-I(2) / 4)
     GOBACK.
 END PROGRAM EM3-TRIANGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-STATE-TIME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MS                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     IF L-I(2) NOT = -2147483648
         MOVE 1 TO L-O(2)
         COMPUTE WS-MS = FUNCTION INTEGER-PART((L-I(1) - L-I(2)) * 50)
         COMPUTE L-O(1) = FUNCTION INTEGER-PART(WS-MS * L-I(3))
     END-IF
     GOBACK.
 END PROGRAM EM3-STATE-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-STATE-FF.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO L-O(1)
     IF L-I(1) NOT = -2147483648
         COMPUTE L-O(1) = L-I(1) - FUNCTION INTEGER-PART(L-I(2) * L-I(3))
     END-IF
     GOBACK.
 END PROGRAM EM3-STATE-FF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-RENDER-MODEL-TYPE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIELD                PIC X(28).
 01 L-TYPE                 PIC X(24).
 PROCEDURE DIVISION USING L-FIELD L-TYPE.
     MOVE "entityCutout" TO L-TYPE
     IF L-FIELD = "VEX" OR L-FIELD = "ALLAY"
         MOVE "entityTranslucent" TO L-TYPE
     END-IF
     GOBACK.
 END PROGRAM EM3-RENDER-MODEL-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-BODY-VISIBLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     IF L-I(1) NOT = 0 AND L-I(2) = 0
         MOVE 0 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EM3-BODY-VISIBLE.
