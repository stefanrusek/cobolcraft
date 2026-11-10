*> The built-in GUI art (docs/design/builtin-ui-art.md sections 3, 4.1 to 4.9): the sprites of the `gui`
*> atlas, the menu tiles, the pack icon and the crack overlays, drawn from the step table CLBGUI.cpy.
*> BGUI-DRAW runs the steps of one sprite (BGUI-OP: fill, rectangle, ring, frame, bevel, triangle, line, pixel,
*> character art, noise, alpha, crack, pack icon; CP runs the steps of another sprite first). The generated files
*> are numbered after the hand-listed ones of builtin.cob: first every image, then the .mcmeta of each nine-slice
*> sprite (BGUI-KIND, BGUI-PATH, BGUI-FIND, BGUI-META).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BGUI-KIND.
*> USING generated file number (1-based), kind out (0 = past the last file, 1 = image, 2 = .mcmeta), sprite out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLBGUI.
 01 WS-I                   BINARY-LONG.
 01 WS-RANK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-KIND L-SPRITE.
     MOVE 0 TO L-KIND L-SPRITE
     EVALUATE TRUE
         WHEN L-NUMBER >= 1 AND L-NUMBER <= BG-SPRITE-COUNT
             MOVE 1 TO L-KIND
             MOVE L-NUMBER TO L-SPRITE
         WHEN L-NUMBER > BG-SPRITE-COUNT
             COMPUTE WS-RANK = L-NUMBER - BG-SPRITE-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BG-SPRITE-COUNT OR L-KIND = 2
                 IF BG-B(WS-I) > 0
                     SUBTRACT 1 FROM WS-RANK
                     IF WS-RANK = 0
                         MOVE 2 TO L-KIND
                         MOVE WS-I TO L-SPRITE
                     END-IF
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM BGUI-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BGUI-PATH.
*> USING generated file number, path out (PIC X(256)), length out, found out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLBGUI.
 01 WS-KIND                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-PATH L-LENGTH L-FOUND.
     MOVE SPACES TO L-PATH
     MOVE 0 TO L-LENGTH L-FOUND
     CALL "BGUI-KIND" USING L-NUMBER WS-KIND WS-SPRITE
     IF WS-KIND > 0
         MOVE 1 TO L-FOUND
         MOVE FUNCTION LENGTH(FUNCTION TRIM(BG-PATH(WS-SPRITE))) TO L-LENGTH
         MOVE BG-PATH(WS-SPRITE) TO L-PATH
         IF WS-KIND = 2
             MOVE ".mcmeta" TO L-PATH(L-LENGTH + 1:7)
             ADD 7 TO L-LENGTH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BGUI-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BGUI-FIND.
*> USING path (PIC X(256)), path length, generated file number out (0 = none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-NUMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-LENGTH L-NUMBER.
     MOVE 0 TO L-NUMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL L-NUMBER > 0
         CALL "BGUI-PATH" USING WS-I WS-PATH WS-LENGTH WS-FOUND
         IF WS-FOUND = 0
             EXIT PERFORM
         END-IF
         IF WS-LENGTH = L-LENGTH AND WS-PATH(1:WS-LENGTH) = L-PATH(1:L-LENGTH)
             MOVE WS-I TO L-NUMBER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BGUI-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BGUI-META.
*> USING generated file number, text out (PIC X(128)), length out (0 when the file is no .mcmeta): the
*> nine-slice metadata of section 3: {"gui":{"scaling":{"type":"nine_slice","width":W,"height":H,"border":B}}}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLBGUI.
 01 WS-KIND                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-W                   PIC Z(2)9.
 01 WS-H                   PIC Z(2)9.
 01 WS-B                   PIC Z9.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-TEXT                 PIC X(128).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-LENGTH
     CALL "BGUI-KIND" USING L-NUMBER WS-KIND WS-SPRITE
     IF WS-KIND = 2
         MOVE BG-W(WS-SPRITE) TO WS-W
         MOVE BG-H(WS-SPRITE) TO WS-H
         MOVE BG-B(WS-SPRITE) TO WS-B
         MOVE 1 TO WS-PTR
         STRING '{"gui":{"scaling":{"type":"nine_slice","width":' FUNCTION TRIM(WS-W)
             ',"height":' FUNCTION TRIM(WS-H) ',"border":' FUNCTION TRIM(WS-B) '}}}'
             DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         COMPUTE L-LENGTH = WS-PTR - 1
     END-IF
     GOBACK.
 END PROGRAM BGUI-META.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BGUI-DRAW.
*> USING generated file number (an image), RGBA out (PIC X(40000)), width out, height out, found out: the image of
*> the sprite, transparent where no step draws.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLBGUI.
 01 WS-KIND                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-RGBA                 PIC X(40000).
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-RGBA L-W L-H L-FOUND.
     MOVE 0 TO L-W L-H L-FOUND
     CALL "BGUI-KIND" USING L-NUMBER WS-KIND WS-SPRITE
     IF WS-KIND = 1
         MOVE 1 TO L-FOUND
         MOVE BG-W(WS-SPRITE) TO L-W
         MOVE BG-H(WS-SPRITE) TO L-H
         COMPUTE WS-BYTES = L-W * L-H * 4
         MOVE LOW-VALUES TO L-RGBA(1:WS-BYTES)
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > BG-OP-COUNT
             IF BG-O-SPRITE(WS-R) = WS-SPRITE
                 IF BG-O-OP(WS-R) = "CP"
                     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BG-OP-COUNT
                         IF BG-O-SPRITE(WS-Q) = BG-O-ARG(WS-R)
                             CALL "BGUI-OP" USING BG-OPROW(WS-Q) L-RGBA L-W L-H
                         END-IF
                     END-PERFORM
                 ELSE
                     CALL "BGUI-OP" USING BG-OPROW(WS-R) L-RGBA L-W L-H
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BGUI-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BGUI-OP.
*> USING one step row (BG-OPROW), RGBA (PIC X(40000)), width, height: draws the step into the image
*> (section 2 of builtin-ui-art.md and standin-content 1.4.1: a later step overwrites, nothing blends).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLBGUI.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-E1                  BINARY-LONG.
 01 WS-E2                  BINARY-LONG.
 01 WS-E3                  BINARY-LONG.
 01 WS-COL.
    05 WS-C                PIC X(4) OCCURS 4 TIMES.
 01 WS-HAS.
    05 WS-HAS-C            PIC 9 OCCURS 4 TIMES.
 01 WS-NAME                PIC X(32).
 01 WS-HASH                BINARY-DOUBLE UNSIGNED.
 01 WS-V                   BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-KEYPOS              BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(16).
 01 WS-ART                 BINARY-LONG.
 01 WS-N6.
    05 WS-NUM              BINARY-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-OP.
    05 L-O-SPRITE          PIC 999.
    05 L-O-OP              PIC XX.
    05 L-O-N               PIC 999 OCCURS 6 TIMES.
    05 L-O-C               PIC X(8) OCCURS 4 TIMES.
    05 L-O-ARG             PIC 999.
 01 L-RGBA                 PIC X(40000).
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-OP L-RGBA L-W L-H.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE 0 TO WS-HAS-C(WS-K)
         MOVE LOW-VALUES TO WS-C(WS-K)
         IF L-O-C(WS-K)(1:1) NOT = "-"
             MOVE 1 TO WS-HAS-C(WS-K)
             MOVE FUNCTION HEX-TO-CHAR(L-O-C(WS-K)) TO WS-C(WS-K)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE L-O-N(WS-K) TO WS-NUM(WS-K)
     END-PERFORM
     MOVE L-O-ARG TO WS-ART
     EVALUATE L-O-OP
         WHEN "FL"
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P >= L-W * L-H
                 MOVE WS-C(1) TO L-RGBA(WS-P * 4 + 1:4)
             END-PERFORM
         WHEN "RC"
*>           R(x0, y0, x1, y1) in colour 1.
             PERFORM VARYING WS-Y FROM WS-NUM(2) BY 1 UNTIL WS-Y > WS-NUM(4)
                 PERFORM VARYING WS-X FROM WS-NUM(1) BY 1 UNTIL WS-X > WS-NUM(3)
                     MOVE WS-C(1) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                 END-PERFORM
             END-PERFORM
         WHEN "RG"
*>           Ring(x0, y0, x1, y1, t, C).
             PERFORM VARYING WS-Y FROM WS-NUM(2) BY 1 UNTIL WS-Y > WS-NUM(4)
                 PERFORM VARYING WS-X FROM WS-NUM(1) BY 1 UNTIL WS-X > WS-NUM(3)
                     IF WS-X < WS-NUM(1) + WS-NUM(5) OR WS-X > WS-NUM(3) - WS-NUM(5)
                             OR WS-Y < WS-NUM(2) + WS-NUM(5) OR WS-Y > WS-NUM(4) - WS-NUM(5)
                         MOVE WS-C(1) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN "FR"
*>           Paste(Frame(W, H, TL, BR, F, t), x, y): fill, top rows and left columns TL, bottom rows and right columns BR.
             PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY >= WS-NUM(4)
                 PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX >= WS-NUM(3)
                     COMPUTE WS-X = WS-NUM(1) + WS-DX
                     COMPUTE WS-Y = WS-NUM(2) + WS-DY
                     MOVE WS-C(3) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                     IF WS-DY < WS-NUM(5) OR WS-DX < WS-NUM(5)
                         MOVE WS-C(1) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                     END-IF
                     IF WS-DY >= WS-NUM(4) - WS-NUM(5) OR WS-DX >= WS-NUM(3) - WS-NUM(5)
                         MOVE WS-C(2) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN "BV"
*>           Bevel(W, H, O, HI, LO, F, b, r): outline, fill, highlight rows and columns, shade (which wins), corners.
             MOVE WS-NUM(3) TO WS-B
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= L-H
                 PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= L-W
                     MOVE WS-C(1) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                     IF WS-X >= 1 AND WS-X <= L-W - 2 AND WS-Y >= 1 AND WS-Y <= L-H - 2
                         MOVE WS-C(4) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                         IF WS-Y <= WS-B OR WS-X <= WS-B
                             MOVE WS-C(2) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                         END-IF
                         IF WS-Y >= L-H - 1 - WS-B OR WS-X >= L-W - 1 - WS-B
                             MOVE WS-C(3) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
             IF WS-NUM(4) = 1
                 MOVE LOW-VALUES TO L-RGBA(1:4)
                 MOVE LOW-VALUES TO L-RGBA((L-W - 1) * 4 + 1:4)
                 MOVE LOW-VALUES TO L-RGBA((L-H - 1) * L-W * 4 + 1:4)
                 MOVE LOW-VALUES TO L-RGBA(((L-H - 1) * L-W + L-W - 1) * 4 + 1:4)
             END-IF
         WHEN "TR"
*>           T(A, B, C): the three edge values all >= 0 or all <= 0 (inclusive).
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= L-H
                 PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= L-W
                     COMPUTE WS-E1 = (WS-NUM(3) - WS-NUM(1)) * (WS-Y - WS-NUM(2))
                         - (WS-NUM(4) - WS-NUM(2)) * (WS-X - WS-NUM(1))
                     COMPUTE WS-E2 = (WS-NUM(5) - WS-NUM(3)) * (WS-Y - WS-NUM(4))
                         - (WS-NUM(6) - WS-NUM(4)) * (WS-X - WS-NUM(3))
                     COMPUTE WS-E3 = (WS-NUM(1) - WS-NUM(5)) * (WS-Y - WS-NUM(6))
                         - (WS-NUM(2) - WS-NUM(6)) * (WS-X - WS-NUM(5))
                     IF (WS-E1 >= 0 AND WS-E2 >= 0 AND WS-E3 >= 0)
                             OR (WS-E1 <= 0 AND WS-E2 <= 0 AND WS-E3 <= 0)
                         MOVE WS-C(1) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN "LN"
*>           L(x0, y0, x1, y1, w): n centre pixels, thickened downward (shallow) or to the right (steep).
             COMPUTE WS-DX = WS-NUM(3) - WS-NUM(1)
             COMPUTE WS-DY = WS-NUM(4) - WS-NUM(2)
             COMPUTE WS-AX = FUNCTION ABS(WS-DX)
             COMPUTE WS-AY = FUNCTION ABS(WS-DY)
             COMPUTE WS-N = FUNCTION MAX(WS-AX, WS-AY)
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-N
                 MOVE WS-NUM(1) TO WS-X
                 MOVE WS-NUM(2) TO WS-Y
                 IF WS-N > 0
                     COMPUTE WS-Q = (2 * WS-I * WS-AX + WS-N) / (2 * WS-N)
                     COMPUTE WS-X = WS-NUM(1) + FUNCTION SIGN(WS-DX) * WS-Q
                     COMPUTE WS-Q = (2 * WS-I * WS-AY + WS-N) / (2 * WS-N)
                     COMPUTE WS-Y = WS-NUM(2) + FUNCTION SIGN(WS-DY) * WS-Q
                 END-IF
                 PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= WS-NUM(5)
                     MOVE WS-X TO WS-PX
                     MOVE WS-Y TO WS-PY
                     IF WS-AX > WS-AY
                         ADD WS-K TO WS-PY
                     ELSE
                         ADD WS-K TO WS-PX
                     END-IF
                     IF WS-PX >= 0 AND WS-PX < L-W AND WS-PY >= 0 AND WS-PY < L-H
                         MOVE WS-C(1) TO L-RGBA((WS-PY * L-W + WS-PX) * 4 + 1:4)
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN "PX"
             MOVE WS-C(1) TO L-RGBA((WS-NUM(2) * L-W + WS-NUM(1)) * 4 + 1:4)
         WHEN "AR"
*>           Art rows drawn in the columns xmin to xmax; the colour of a key letter is that of its place in the key.
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 15
                 MOVE BG-ART-LINE(WS-ART, WS-Y + 1) TO WS-ROW-TEXT
                 PERFORM VARYING WS-X FROM WS-NUM(1) BY 1 UNTIL WS-X > WS-NUM(2)
                     MOVE WS-ROW-TEXT(WS-X + 1:1) TO WS-CH
                     MOVE 0 TO WS-KEYPOS
                     IF WS-CH NOT = "." AND WS-CH NOT = SPACE
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                             IF BG-ART-KEY(WS-ART)(WS-K:1) = WS-CH
                                 MOVE WS-K TO WS-KEYPOS
                             END-IF
                         END-PERFORM
                     END-IF
                     IF WS-KEYPOS > 0
                         IF WS-HAS-C(WS-KEYPOS) = 1
                             MOVE WS-C(WS-KEYPOS) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN "NZ"
*>           Noise: n = H(name bytes, x, y) mod 100; colour 2 below p1, colour 3 below p1 + p2, else the fill.
             MOVE BG-NAME(L-O-SPRITE) TO WS-NAME
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= L-H
                 PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= L-W
                     CALL "TEX-NAME-HASH" USING WS-NAME WS-X WS-Y WS-HASH
                     COMPUTE WS-N = FUNCTION MOD(WS-HASH, 100)
                     EVALUATE TRUE
                         WHEN WS-N < WS-NUM(1)
                             MOVE WS-C(2) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                         WHEN WS-N < WS-NUM(1) + WS-NUM(2)
                             MOVE WS-C(3) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                         WHEN OTHER
                             MOVE WS-C(1) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                     END-EVALUATE
                 END-PERFORM
             END-PERFORM
         WHEN "AA"
*>           Every pixel that is not transparent gets alpha n1.
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P >= L-W * L-H
                 IF L-RGBA(WS-P * 4 + 4:1) NOT = LOW-VALUE
                     MOVE FUNCTION CHAR(WS-NUM(1) + 1) TO L-RGBA(WS-P * 4 + 4:1)
                 END-IF
             END-PERFORM
         WHEN "CR"
*>           Crack stage N: #404040 where H("destroy", x, y) mod 100 < 8 + 9 N (section 4.9).
             MOVE "destroy" TO WS-NAME
             MOVE FUNCTION HEX-TO-CHAR("404040FF") TO WS-C(1)
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= L-H
                 PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= L-W
                     CALL "TEX-NAME-HASH" USING WS-NAME WS-X WS-Y WS-HASH
                     COMPUTE WS-N = FUNCTION MOD(WS-HASH, 100)
                     IF WS-N < 8 + 9 * WS-NUM(1)
                         MOVE WS-C(1) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN "UP"
*>           The unknown-pack icon: rings of q = min(x, y, 63 - x, 63 - y) div 4 (section 4.8).
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= L-H
                 PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= L-W
                     COMPUTE WS-V = FUNCTION MIN(WS-X, WS-Y, 63 - WS-X, 63 - WS-Y)
                     DIVIDE WS-V BY 4 GIVING WS-Q
                     EVALUATE TRUE
                         WHEN WS-Q = 0
                             MOVE FUNCTION HEX-TO-CHAR("3B2F5CFF") TO WS-C(1)
                         WHEN WS-Q = 1 OR WS-Q = 3 OR WS-Q = 5
                             MOVE FUNCTION HEX-TO-CHAR("1F1B2EFF") TO WS-C(1)
                         WHEN WS-Q = 2 OR WS-Q = 4
                             MOVE FUNCTION HEX-TO-CHAR("6A4FB3FF") TO WS-C(1)
                         WHEN OTHER
                             MOVE FUNCTION HEX-TO-CHAR("C9B8FFFF") TO WS-C(1)
                     END-EVALUATE
                     MOVE WS-C(1) TO L-RGBA((WS-Y * L-W + WS-X) * 4 + 1:4)
                 END-PERFORM
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM BGUI-OP.
