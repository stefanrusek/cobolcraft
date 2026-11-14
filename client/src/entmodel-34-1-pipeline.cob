*> Entity models part 1 section 7 (docs/protocol/34-entity-models-1-shared-model-and-framework.md): the generic pipeline pieces the entity renderers submit.
*> Every entry point takes IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG) unless noted.
*>   EM7-RADIUS IN(kind 0 living 1 mob 2 cube, base radius, scale, ageScale, cube size) OUT(R capped at 32); EM7-STRENGTH IN(distance^2, strength)
*>     OUT(s); EM7-RANGE IN(x y z R s) OUT(min x, max x, min z, max z, m, min y, max y); EM7-BRIGHTNESS IN(ambient, light level) OUT(b);
*>     EM7-ALPHA IN(s, entity y, cell y, brightness) OUT(f, alpha); EM7-SKIP IN(below-invisible, brightness, below-full-block, below-shape-empty)
*>     OUT(skip); EM7-QUAD IN(rel x, rel y, rel z, bounds min x, max x, min y, min z, max z, R, alpha) OUT(4 vertices of x y z u v, alpha byte) (7.1).
*>   EM7-NAME-LIVING IN(d^2, discrete, invisible-to-player, is-local-player, has-team, team visibility 0 always 1 never 2 hide other teams 3 hide own
*>     team, local-has-team, allied, can-see-friendly-invisibles, hud-hidden, is-camera, is-vehicle) OUT(show); EM7-NAME-GATE IN(d^2, name distance,
*>     always-show, has-custom-name, under-crosshair, is-mob, living-rule) OUT(show); EM7-SCORE-GATE IN(d^2, score distance) OUT(show);
*>     EM7-NAME-ALPHA IN(background opacity) OUT(text alpha, background alpha byte) (7.2).
*>   EM7-LEASH-VERTEX IN(dx dy dz, i, backward pass, slack, start block, end block, start sky, end sky) OUT(shade, colour r g b, block, sky, vertex A
*>     xyz, vertex B xyz) (7.3). EM7-FIRE IN(width, height) OUT(quad count, scale, height / scale, z translate, then per quad: half width, y rise,
*>     z shift, mirror u, sprite 0 FIRE_0 or 1 FIRE_1) (7.4). EM7-HITBOX-COLOUR name(X(24): box, vehicle, eye, local) argb(BINARY-DOUBLE, Java signed) (7.5).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-RADIUS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(1) = 2
         COMPUTE L-O(1) = L-I(5) * 0.25
     ELSE
         COMPUTE L-O(1) = L-I(2) * L-I(3)
         IF L-I(1) = 1
             COMPUTE L-O(1) = L-O(1) * L-I(4)
         END-IF
     END-IF
     IF L-O(1) > 32
         MOVE 32 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EM7-RADIUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-STRENGTH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = (1 - L-I(1) / 256) * L-I(2)
     GOBACK.
 END PROGRAM EM7-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-RANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION INTEGER(L-I(1) - L-I(4))
     COMPUTE L-O(2) = FUNCTION INTEGER(L-I(1) + L-I(4))
     COMPUTE L-O(3) = FUNCTION INTEGER(L-I(3) - L-I(4))
     COMPUTE L-O(4) = FUNCTION INTEGER(L-I(3) + L-I(4))
     COMPUTE L-O(5) = L-I(5) / 0.5 - 1
     IF L-O(5) > L-I(4)
         MOVE L-I(4) TO L-O(5)
     END-IF
     MOVE L-O(5) TO WS-T
     COMPUTE L-O(6) = FUNCTION INTEGER(L-I(2) - WS-T)
     COMPUTE L-O(7) = FUNCTION INTEGER(L-I(2))
     GOBACK.
 END PROGRAM EM7-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-BRIGHTNESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-A = L-I(2) / 15
     COMPUTE WS-B = WS-A / (4 - 3 * WS-A)
     COMPUTE L-O(1) = WS-B + L-I(1) * (1 - WS-B)
     GOBACK.
 END PROGRAM EM7-BRIGHTNESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-ALPHA.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) - (L-I(2) - L-I(3)) * 0.5
     COMPUTE L-O(2) = L-O(1) * 0.5 * L-I(4)
     IF L-O(2) < 0
         MOVE 0 TO L-O(2)
     END-IF
     IF L-O(2) > 1
         MOVE 1 TO L-O(2)
     END-IF
     GOBACK.
 END PROGRAM EM7-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-SKIP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0 OR L-I(2) <= 3 OR L-I(3) = 0 OR L-I(4) NOT = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EM7-SKIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-QUAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-X0 = L-I(1) + L-I(4)
     COMPUTE WS-X1 = L-I(1) + L-I(5)
     COMPUTE WS-Y = L-I(2) + L-I(6)
     COMPUTE WS-Z0 = L-I(3) + L-I(7)
     COMPUTE WS-Z1 = L-I(3) + L-I(8)
*>   vertices in order (x0 z0) (x0 z1) (x1 z1) (x1 z0); u = -x / 2 / R + 0.5, v = -z / 2 / R + 0.5
     MOVE WS-X0 TO L-O(1)
     MOVE WS-Y TO L-O(2)
     MOVE WS-Z0 TO L-O(3)
     COMPUTE L-O(4) = -WS-X0 / 2 / L-I(9) + 0.5
     COMPUTE L-O(5) = -WS-Z0 / 2 / L-I(9) + 0.5
     MOVE WS-X0 TO L-O(6)
     MOVE WS-Y TO L-O(7)
     MOVE WS-Z1 TO L-O(8)
     COMPUTE L-O(9) = -WS-X0 / 2 / L-I(9) + 0.5
     COMPUTE L-O(10) = -WS-Z1 / 2 / L-I(9) + 0.5
     MOVE WS-X1 TO L-O(11)
     MOVE WS-Y TO L-O(12)
     MOVE WS-Z1 TO L-O(13)
     COMPUTE L-O(14) = -WS-X1 / 2 / L-I(9) + 0.5
     COMPUTE L-O(15) = -WS-Z1 / 2 / L-I(9) + 0.5
     MOVE WS-X1 TO L-O(16)
     MOVE WS-Y TO L-O(17)
     MOVE WS-Z0 TO L-O(18)
     COMPUTE L-O(19) = -WS-X1 / 2 / L-I(9) + 0.5
     COMPUTE L-O(20) = -WS-Z0 / 2 / L-I(9) + 0.5
     COMPUTE L-O(21) = FUNCTION INTEGER(L-I(10) * 255)
     GOBACK.
 END PROGRAM EM7-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-NAME-LIVING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(2) NOT = 0 AND L-I(1) >= 1024
         GOBACK
     END-IF
     MOVE 1 TO WS-V
     IF L-I(3) NOT = 0
         MOVE 0 TO WS-V
     END-IF
     IF L-I(4) = 0 AND L-I(5) NOT = 0
         EVALUATE L-I(6)
             WHEN 0
                 MOVE WS-V TO L-O(1)
             WHEN 1
                 MOVE 0 TO L-O(1)
             WHEN 2
                 IF L-I(7) = 0
                     MOVE WS-V TO L-O(1)
                 ELSE
                     IF L-I(8) NOT = 0 AND (L-I(9) NOT = 0 OR WS-V = 1)
                         MOVE 1 TO L-O(1)
                     END-IF
                 END-IF
             WHEN OTHER
                 IF L-I(7) = 0
                     MOVE WS-V TO L-O(1)
                 ELSE
                     IF L-I(8) = 0 AND WS-V = 1
                         MOVE 1 TO L-O(1)
                     END-IF
                 END-IF
         END-EVALUATE
     ELSE
         IF L-I(10) = 0 AND L-I(11) = 0 AND WS-V = 1 AND L-I(12) = 0
             MOVE 1 TO L-O(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EM7-NAME-LIVING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-NAME-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) < L-I(2) * L-I(2) AND L-I(7) NOT = 0
         MOVE 1 TO L-O(1)
         IF L-I(6) NOT = 0 AND L-I(3) = 0 AND (L-I(4) = 0 OR L-I(5) = 0)
             MOVE 0 TO L-O(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EM7-NAME-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-SCORE-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) < L-I(2) * L-I(2)
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EM7-SCORE-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-NAME-ALPHA.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = (L-I(1) + 0.75) * 0.5
     IF L-O(1) < 0.5
         MOVE 0.5 TO L-O(1)
     END-IF
     COMPUTE L-O(2) = FUNCTION INTEGER(L-I(1) * 255)
     GOBACK.
 END PROGRAM EM7-NAME-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-LEASH-VERTEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-SH                  FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-PARITY              BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-T = L-I(4) / 24
     COMPUTE WS-PARITY = FUNCTION MOD(FUNCTION INTEGER-PART(L-I(4)), 2)
     MOVE 0 TO WS-WANT
     MOVE 0.05 TO WS-W
     IF L-I(5) NOT = 0
         MOVE 1 TO WS-WANT
         MOVE 0 TO WS-W
     END-IF
     MOVE 1 TO WS-SH
     IF WS-PARITY = WS-WANT
         MOVE 0.7 TO WS-SH
     END-IF
     COMPUTE WS-PX = L-I(1) * WS-T
     COMPUTE WS-PZ = L-I(3) * WS-T
     COMPUTE WS-PY = L-I(2) * WS-T
     IF L-I(6) NOT = 0
         IF L-I(2) > 0
             COMPUTE WS-PY = L-I(2) * WS-T * WS-T
         ELSE
             COMPUTE WS-PY = L-I(2) - L-I(2) * (1 - WS-T) * (1 - WS-T)
         END-IF
     END-IF
     COMPUTE WS-K = (1 / FUNCTION SQRT(L-I(1) * L-I(1) + L-I(3) * L-I(3))) * 0.05 / 2
     COMPUTE WS-SX = L-I(3) * WS-K
     COMPUTE WS-SZ = L-I(1) * WS-K
     MOVE WS-SH TO L-O(1)
     COMPUTE L-O(2) = 0.5 * WS-SH
     COMPUTE L-O(3) = 0.4 * WS-SH
     COMPUTE L-O(4) = 0.3 * WS-SH
     COMPUTE L-O(5) = FUNCTION INTEGER-PART(L-I(7) + (L-I(8) - L-I(7)) * WS-T)
     COMPUTE L-O(6) = FUNCTION INTEGER-PART(L-I(9) + (L-I(10) - L-I(9)) * WS-T)
     COMPUTE L-O(7) = WS-PX - WS-SX
     COMPUTE L-O(8) = WS-PY + WS-W
     COMPUTE L-O(9) = WS-PZ + WS-SZ
     COMPUTE L-O(10) = WS-PX + WS-SX
     COMPUTE L-O(11) = WS-PY + 0.05 - WS-W
     COMPUTE L-O(12) = WS-PZ - WS-SZ
     GOBACK.
 END PROGRAM EM7-LEASH-VERTEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-FIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-ZS                  FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(2) = L-I(1) * 1.4
     COMPUTE WS-H = L-I(2) / L-O(2)
     MOVE WS-H TO L-O(3)
     COMPUTE L-O(4) = 0.3 - FUNCTION INTEGER-PART(WS-H) * 0.02
     MOVE 0.5 TO WS-W
     MOVE 0 TO WS-ZS WS-M WS-N
     PERFORM UNTIL WS-H <= 0 OR WS-N >= 12
         COMPUTE WS-BASE = 5 + WS-N * 5
         MOVE WS-W TO L-O(WS-BASE)
         COMPUTE L-O(WS-BASE + 1) = 0 - WS-M
         MOVE WS-ZS TO L-O(WS-BASE + 2)
         COMPUTE WS-Q = FUNCTION MOD(FUNCTION INTEGER-PART(WS-N / 2), 2)
         MOVE 0 TO L-O(WS-BASE + 3)
         IF WS-Q = 0
             MOVE 1 TO L-O(WS-BASE + 3)
         END-IF
         COMPUTE L-O(WS-BASE + 4) = FUNCTION MOD(WS-N, 2)
         COMPUTE WS-H = WS-H - 0.45
         COMPUTE WS-M = WS-M - 0.45
         COMPUTE WS-W = WS-W * 0.9
         COMPUTE WS-ZS = WS-ZS - 0.03
         ADD 1 TO WS-N
     END-PERFORM
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EM7-FIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM7-HITBOX-COLOUR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-ARGB                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-NAME L-ARGB.
     MOVE 0 TO L-ARGB
     EVALUATE L-NAME
         WHEN "box"
             MOVE -1 TO L-ARGB
         WHEN "vehicle"
             COMPUTE L-ARGB = 255 * 16777216 + 255 * 65536 + 255 * 256 - 4294967296
         WHEN "eye"
             COMPUTE L-ARGB = 255 * 16777216 + 255 * 65536 - 4294967296
         WHEN "local"
             COMPUTE L-ARGB = 255 * 16777216 + 255 * 256 - 4294967296
     END-EVALUATE
     GOBACK.
 END PROGRAM EM7-HITBOX-COLOUR.
