from mesh8 import *
from prog6 import *
hdr='''*> Entity models part 8 (docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md): aquatic mobs, nautilus family and boats. Section 0 here (conventions and engine facts); the models in client/src/entmodel-34-8-<n>.cob.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)): ops lists are count, then code (1 translate, 2 scale, 3 rotate Y degrees, 6 rotate X degrees, 7 rotationZYX z y x radians) and three values per op.
*>   EF8-PART-OPS IN(x y z texels, rotation x y z, scale x y z) OUT(ops); EF8-BOX-EXTENT IN(origin, size, grow) OUT(from, to); EF8-ROOT-POSE IN(s) OUT(scale, y = 24.016 x (1 - s)); EF8-MTH-SIN, EF8-MTH-COS IN(x) OUT(table value, via EF5-MTH-SIN and EF5-MTH-COS);
*>   EF8-ANIM-MS IN(ageInTicks, start tick) OUT(milliseconds, truncated); EF8-WALK IN(pos, speed, factor a, factor b) OUT(ms, strength min(speed x b, 1)); EF8-AGEABLE-MODEL IN(baby) OUT(1 when the baby model is drawn);
*>   EF8-SHADOW IN(base radius, scale, ageScale) OUT(base x scale, with ageScale); EF8-RENDER-TYPE IN() name(out X(120)): the default render type of a model (entityCutout).
'''
extra=prog('EF8-PART-OPS','''     MOVE 1 TO L-O(2)
     COMPUTE L-O(3) = L-I(1) / 16
     COMPUTE L-O(4) = L-I(2) / 16
     COMPUTE L-O(5) = L-I(3) / 16
     MOVE 1 TO WS-N
     IF L-I(4) NOT = 0 OR L-I(5) NOT = 0 OR L-I(6) NOT = 0
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 7 TO L-O(WS-K)
         MOVE L-I(6) TO L-O(WS-K + 1)
         MOVE L-I(5) TO L-O(WS-K + 2)
         MOVE L-I(4) TO L-O(WS-K + 3)
     END-IF
     IF L-I(7) NOT = 1 OR L-I(8) NOT = 1 OR L-I(9) NOT = 1
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 2 TO L-O(WS-K)
         MOVE L-I(7) TO L-O(WS-K + 1)
         MOVE L-I(8) TO L-O(WS-K + 2)
         MOVE L-I(9) TO L-O(WS-K + 3)
     END-IF
     MOVE WS-N TO L-O(1)
''',' 01 WS-N                   BINARY-LONG.\n 01 WS-K                   BINARY-LONG.\n')
extra+=prog('EF8-BOX-EXTENT','     COMPUTE L-O(1) = L-I(1) - L-I(3)\n     COMPUTE L-O(2) = L-I(1) + L-I(2) + L-I(3)\n')
extra+=prog('EF8-ROOT-POSE','     MOVE L-I(1) TO L-O(1)\n     COMPUTE L-O(2) = 24.016 * (1 - L-I(1))\n')
extra+=prog('EF8-MTH-SIN','     CALL "EF5-MTH-SIN" USING L-IN L-OUT\n')
extra+=prog('EF8-MTH-COS','     CALL "EF5-MTH-COS" USING L-IN L-OUT\n')
extra+=prog('EF8-ANIM-MS','     COMPUTE L-O(1) = FUNCTION INTEGER-PART((L-I(1) - L-I(2)) * 50)\n')
extra+=prog('EF8-WALK','''     COMPUTE L-O(1) = FUNCTION INTEGER-PART(L-I(1) * 50 * L-I(3))
     COMPUTE L-O(2) = L-I(2) * L-I(4)
     IF L-O(2) > 1
         MOVE 1 TO L-O(2)
     END-IF
''')
extra+=prog('EF8-AGEABLE-MODEL','     MOVE 0 TO L-O(1)\n     IF L-I(1) NOT = 0\n         MOVE 1 TO L-O(1)\n     END-IF\n')
extra+=prog('EF8-SHADOW','     COMPUTE L-O(1) = L-I(1) * L-I(2)\n     COMPUTE L-O(2) = L-I(1) * L-I(2) * L-I(3)\n')
extra+=' IDENTIFICATION DIVISION.\n PROGRAM-ID. EF8-RENDER-TYPE.\n DATA DIVISION.\n LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-PATH                 PIC X(120).\n PROCEDURE DIVISION USING L-IN L-PATH.\n     MOVE "entityCutout" TO L-PATH\n     GOBACK.\n END PROGRAM EF8-RENDER-TYPE.\n\n'
write_section_src(0,hdr,[],extra)
