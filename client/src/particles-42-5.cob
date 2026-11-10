*> Particles part 5 (docs/protocol/42-particles-5-sculk-trial-wind-geyser.md), section 1: the table of types and the shared
*> helpers (light, colour, Mth and Vec3 steps, the face emission with an offset). Draws are passed in as tables (a
*> nextFloat as a FLOAT-LONG in [0, 1), a nextInt(n) as floor(r * n)); see particles-42-2.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-TYPE-COUNT.
*> Section 1.2: USING count out (the 29 types of the table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 29 TO L-COUNT
     GOBACK.
 END PROGRAM P5-TYPE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-TYPE-ID.
*> Section 1.2: USING row (1 to 29, the order of the table), registry id out (0 out of range).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IDS                 PIC X(87) VALUE
     "004005006007008009010024031032033034035047048049058059060061115117118119120122123124127".
 01 WS-TABLE REDEFINES WS-IDS.
    05 WS-ID               PIC 999 OCCURS 29 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ID.
     IF L-ROW < 1 OR L-ROW > 29
         MOVE 0 TO L-ID
     ELSE
         MOVE WS-ID(L-ROW) TO L-ID
     END-IF
     GOBACK.
 END PROGRAM P5-TYPE-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-TYPE-SECTION.
*> Section 1.2: USING registry id, section out (PIC X(8): the section of this document, "42-1 5.9" for elder_guardian,
*> spaces for an id that is not in the table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(11) VALUE "0042.17    ".
    05 FILLER PIC X(11) VALUE "0052.14    ".
    05 FILLER PIC X(11) VALUE "0062.15    ".
    05 FILLER PIC X(11) VALUE "0072.16    ".
    05 FILLER PIC X(11) VALUE "0082.16    ".
    05 FILLER PIC X(11) VALUE "0092.16    ".
    05 FILLER PIC X(11) VALUE "0102.16    ".
    05 FILLER PIC X(11) VALUE "02442-1 5.9".
    05 FILLER PIC X(11) VALUE "0312.8     ".
    05 FILLER PIC X(11) VALUE "0322.8     ".
    05 FILLER PIC X(11) VALUE "0332.9     ".
    05 FILLER PIC X(11) VALUE "0342.9     ".
    05 FILLER PIC X(11) VALUE "0352.5     ".
    05 FILLER PIC X(11) VALUE "0472.1     ".
    05 FILLER PIC X(11) VALUE "0482.2     ".
    05 FILLER PIC X(11) VALUE "0492.3     ".
    05 FILLER PIC X(11) VALUE "0582.6     ".
    05 FILLER PIC X(11) VALUE "0592.7     ".
    05 FILLER PIC X(11) VALUE "0602.18    ".
    05 FILLER PIC X(11) VALUE "0612.18    ".
    05 FILLER PIC X(11) VALUE "1152.4     ".
    05 FILLER PIC X(11) VALUE "1172.10    ".
    05 FILLER PIC X(11) VALUE "1182.11    ".
    05 FILLER PIC X(11) VALUE "1192.11    ".
    05 FILLER PIC X(11) VALUE "1202.12    ".
    05 FILLER PIC X(11) VALUE "1222.13    ".
    05 FILLER PIC X(11) VALUE "1232.19    ".
    05 FILLER PIC X(11) VALUE "1242.19    ".
    05 FILLER PIC X(11) VALUE "1272.20    ".
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 29 TIMES.
       10 WS-RID           PIC 999.
       10 WS-RSEC          PIC X(8).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SECTION              PIC X(8).
 PROCEDURE DIVISION USING L-ID L-SECTION.
     MOVE SPACES TO L-SECTION
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 29
         IF WS-RID(WS-I) = L-ID
             MOVE WS-RSEC(WS-I) TO L-SECTION
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P5-TYPE-SECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-LIGHT-WITH-BLOCK.
*> Section 1.3 withBlock: USING packed light, block level, light out: bits 16 to 23 of the light are kept (mask 0xFF0000)
*> and the block level << 4 is set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SKY                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-LEVEL L-OUT.
     COMPUTE WS-SKY = FUNCTION MOD(FUNCTION INTEGER-PART(L-LIGHT / 65536), 256)
     COMPUTE L-OUT = WS-SKY * 65536 + L-LEVEL * 16
     GOBACK.
 END PROGRAM P5-LIGHT-WITH-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SCALE-RGB.
*> Section 1.3 ARGB.scaleRGB: USING colour (ARGB, 0 to 4294967295), factors red, green, blue, colour out: each of the three
*> bytes times its factor, truncated and clamped to 255; the alpha byte is kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-G                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-COLOR                BINARY-DOUBLE.
 01 L-FR                   FLOAT-LONG.
 01 L-FG                   FLOAT-LONG.
 01 L-FB                   FLOAT-LONG.
 01 L-OUT                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-COLOR L-FR L-FG L-FB L-OUT.
     COMPUTE WS-A = FUNCTION INTEGER-PART(L-COLOR / 16777216)
     COMPUTE WS-R = FUNCTION INTEGER-PART(FUNCTION MOD(FUNCTION INTEGER-PART(L-COLOR / 65536), 256) * L-FR)
     COMPUTE WS-G = FUNCTION INTEGER-PART(FUNCTION MOD(FUNCTION INTEGER-PART(L-COLOR / 256), 256) * L-FG)
     COMPUTE WS-B = FUNCTION INTEGER-PART(FUNCTION MOD(L-COLOR, 256) * L-FB)
     IF WS-R > 255
         MOVE 255 TO WS-R
     END-IF
     IF WS-G > 255
         MOVE 255 TO WS-G
     END-IF
     IF WS-B > 255
         MOVE 255 TO WS-B
     END-IF
     COMPUTE L-OUT = WS-A * 16777216 + WS-R * 65536 + WS-G * 256 + WS-B
     GOBACK.
 END PROGRAM P5-SCALE-RGB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SRGB-LERP.
*> Section 1.3 ARGB.srgbLerp: USING t, colour a, colour b, colour out: each of the four bytes as a + floor(t * (b - a))
*> (Mth.lerpInt; no gamma conversion).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-C                   BINARY-DOUBLE.
 01 WS-SCALE               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-T                    FLOAT-LONG.
 01 L-A                    BINARY-DOUBLE.
 01 L-B                    BINARY-DOUBLE.
 01 L-OUT                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-T L-A L-B L-OUT.
     MOVE 0 TO L-OUT
     MOVE 1 TO WS-SCALE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-A = FUNCTION MOD(FUNCTION INTEGER-PART(L-A / WS-SCALE), 256)
         COMPUTE WS-B = FUNCTION MOD(FUNCTION INTEGER-PART(L-B / WS-SCALE), 256)
         COMPUTE WS-C = WS-A + FUNCTION INTEGER(L-T * (WS-B - WS-A))
         COMPUTE L-OUT = L-OUT + WS-C * WS-SCALE
         COMPUTE WS-SCALE = WS-SCALE * 256
     END-PERFORM
     GOBACK.
 END PROGRAM P5-SRGB-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-NEXT-INT.
*> Section 1.3 Mth.nextInt(rng, a, b) and randomBetweenInclusive: USING a, b, draw r (nextInt(b - a + 1) as r), value out =
*> a + floor(r * (b - a + 1)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-R L-VALUE.
     COMPUTE L-VALUE = L-A + FUNCTION INTEGER-PART(L-R * (L-B - L-A + 1))
     GOBACK.
 END PROGRAM P5-NEXT-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-NEXT-DOUBLE.
*> Section 1.3 Mth.nextDouble(rng, a, b): USING a, b, draw r, value out: a when a >= b, else a + r * (b - a).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-A L-B L-R L-VALUE.
     IF L-A >= L-B
         MOVE L-A TO L-VALUE
     ELSE
         COMPUTE L-VALUE = L-A + L-R * (L-B - L-A)
     END-IF
     GOBACK.
 END PROGRAM P5-NEXT-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CLAMPED-LERP.
*> Section 1.3 Mth.clampedLerp(t, a, b): USING t, a, b, value out: a when t < 0, b when t > 1, else a + t * (b - a).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-T L-A L-B L-VALUE.
     EVALUATE TRUE
         WHEN L-T < 0
             MOVE L-A TO L-VALUE
         WHEN L-T > 1
             MOVE L-B TO L-VALUE
         WHEN OTHER
             COMPUTE L-VALUE = L-A + L-T * (L-B - L-A)
     END-EVALUATE
     GOBACK.
 END PROGRAM P5-CLAMPED-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-INVERSE-LERP.
*> Section 1.3 Mth.inverseLerp(v, a, b): USING v, a, b, value out = (v - a) / (b - a).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-V L-A L-B L-VALUE.
     COMPUTE L-VALUE = (L-V - L-A) / (L-B - L-A)
     GOBACK.
 END PROGRAM P5-INVERSE-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-OFFSET-RANDOM.
*> Section 1.3 Vec3.offsetRandom(rng, s): USING vector (x, y, z), s, draws (three nextFloat x, y, z), vector out: each
*> component plus (draw - 0.5) * s.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V.
    05 L-VV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-S                    FLOAT-LONG.
 01 L-U.
    05 L-UU                FLOAT-LONG OCCURS 3 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-V L-S L-U L-OUT.
     COMPUTE L-O(1) = L-VV(1) + (L-UU(1) - 0.5) * L-S
     COMPUTE L-O(2) = L-VV(2) + (L-UU(2) - 0.5) * L-S
     COMPUTE L-O(3) = L-VV(3) + (L-UU(3) - 0.5) * L-S
     GOBACK.
 END PROGRAM P5-OFFSET-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-FACE-POS.
*> Section 1.3 spawnParticleOnFace: USING block position (three integers), face (0 DOWN, 1 UP, 2 NORTH, 3 SOUTH, 4 WEST,
*> 5 EAST), offset, speed draws (three Mth.nextDouble(-0.5, 0.5) values), position draws (nextDouble, consumed in the
*> order x, y, z only on the axes whose step is 0), position out, velocity out: the block centre plus (-0.5 + draw)
*> on the free axes, step * offset on the face axis; the speed on the free axes only.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP.
    05 WS-S                BINARY-LONG OCCURS 3 TIMES.
 01 WS-A                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                BINARY-LONG OCCURS 3 TIMES.
 01 L-FACE                 BINARY-LONG.
 01 L-OFFSET               FLOAT-LONG.
 01 L-SPEED.
    05 L-SD                FLOAT-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-UU                FLOAT-LONG OCCURS 3 TIMES.
 01 L-POS.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-VEL.
    05 L-V                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-FACE L-OFFSET L-SPEED L-U L-POS L-VEL.
     CALL "P4-FACE-STEP" USING L-FACE WS-STEP
     MOVE 0 TO WS-K
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         IF WS-S(WS-A) = 0
             ADD 1 TO WS-K
             COMPUTE L-O(WS-A) = L-PP(WS-A) + 0.5 + (L-UU(WS-K) - 0.5)
             COMPUTE L-V(WS-A) = L-SD(WS-A) - 0.5
         ELSE
             COMPUTE L-O(WS-A) = L-PP(WS-A) + 0.5 + WS-S(WS-A) * L-OFFSET
             MOVE 0 TO L-V(WS-A)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P5-FACE-POS.
