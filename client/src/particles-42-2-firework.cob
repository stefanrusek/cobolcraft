*> Particles part 2, section 3.13 (docs/protocol/42-particles-2-effects-fire-smoke-magic.md): fireworks:
*> the entry for an empty explosion list, the starter, the spark, the flash, the shape generators and
*> their tables. Random draws are passed in by the caller (see particles-42-2.cob); gaussians are passed
*> as already drawn values.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-PUFF-COUNT.
*> 3.13 entry, empty list: USING draws (the nextInt(3) bound draw of each loop test, in order), count out:
*> the loop runs while i < nextInt(3) + 2 with the draw repeated on every test.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAWS L-COUNT.
     MOVE 0 TO L-COUNT
     MOVE 1 TO WS-K
     MOVE 1 TO WS-GO
     PERFORM UNTIL WS-GO = 0 OR WS-K > 16
         COMPUTE WS-BOUND = FUNCTION INTEGER-PART(L-DRAW(WS-K) * 3) + 2
         IF L-COUNT < WS-BOUND
             ADD 1 TO L-COUNT
             ADD 1 TO WS-K
         ELSE
             MOVE 0 TO WS-GO
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P2-FW-PUFF-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-PUFF-VEL.
*> 3.13 entry: USING gaussian x, gaussian z, vx, vy, vz out: (g * 0.05, 0.005, g * 0.05) for a poof puff.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GX                   FLOAT-LONG.
 01 L-GZ                   FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-GX L-GZ L-VX L-VY L-VZ.
     COMPUTE L-VX = L-GX * 0.05
     MOVE 0.005 TO L-VY
     COMPUTE L-VZ = L-GZ * 0.05
     GOBACK.
 END PROGRAM P2-FW-PUFF-VEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-SHAPE-NAME.
*> 3.13 FireworkExplosion.Shape: USING ordinal (0 to 4), name out (the enum constant).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-NAME                 PIC X(12).
 PROCEDURE DIVISION USING L-ORD L-NAME.
     EVALUATE L-ORD
         WHEN 0 MOVE "SMALL_BALL" TO L-NAME
         WHEN 1 MOVE "LARGE_BALL" TO L-NAME
         WHEN 2 MOVE "STAR" TO L-NAME
         WHEN 3 MOVE "CREEPER" TO L-NAME
         WHEN 4 MOVE "BURST" TO L-NAME
         WHEN OTHER MOVE SPACES TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM P2-FW-SHAPE-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-DEFAULT-COLOR.
*> 3.13: USING colour out: the colour of an empty colour list, the black dye's firework colour 1973019.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COLOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-COLOR.
     MOVE 1973019 TO L-COLOR
     GOBACK.
 END PROGRAM P2-FW-DEFAULT-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-STARTER-NEW.
*> 3.13 starter construction: USING explosion count, any explosion twinkles (1/0), lifetime out, twinkleDelay
*> out, error out (1 for an empty list): lifetime 2 * count - 1, plus 15 when one twinkles.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-TWINKLE              BINARY-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-ERR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-TWINKLE L-LIFETIME L-DELAY L-ERR.
     MOVE 0 TO L-LIFETIME L-DELAY L-ERR
     IF L-N <= 0
         MOVE 1 TO L-ERR
     ELSE
         COMPUTE L-LIFETIME = 2 * L-N - 1
         IF L-TWINKLE NOT = 0
             MOVE 1 TO L-DELAY
             ADD 15 TO L-LIFETIME
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P2-FW-STARTER-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-LARGE.
*> 3.13 starter tick step 1: USING explosion count, any LARGE_BALL (1/0), large out: 3 or more explosions,
*> or any large ball.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-ANY                  BINARY-LONG.
 01 L-LARGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-ANY L-LARGE.
     MOVE 0 TO L-LARGE
     IF L-N >= 3 OR L-ANY NOT = 0
         MOVE 1 TO L-LARGE
     END-IF
     GOBACK.
 END PROGRAM P2-FW-LARGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-FAR.
*> 3.13: USING squared distance from the camera, far out: 256 or more.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIST2                FLOAT-LONG.
 01 L-FAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIST2 L-FAR.
     MOVE 0 TO L-FAR
     IF L-DIST2 >= 256
         MOVE 1 TO L-FAR
     END-IF
     GOBACK.
 END PROGRAM P2-FW-FAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-LAUNCH-SOUND.
*> 3.13 starter tick step 1: USING large, far, sound out: 1 FIREWORK_ROCKET_LARGE_BLAST_FAR, 2 LARGE_BLAST,
*> 3 BLAST_FAR, 4 BLAST (AMBIENT, volume 20.0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LARGE                BINARY-LONG.
 01 L-FAR                  BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-LARGE L-FAR L-SOUND.
     EVALUATE TRUE
         WHEN L-LARGE NOT = 0 AND L-FAR NOT = 0
             MOVE 1 TO L-SOUND
         WHEN L-LARGE NOT = 0
             MOVE 2 TO L-SOUND
         WHEN L-FAR NOT = 0
             MOVE 3 TO L-SOUND
         WHEN OTHER
             MOVE 4 TO L-SOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM P2-FW-LAUNCH-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-TWINKLE-SOUND.
*> 3.13 starter tick step 4: USING far, sound out: 5 FIREWORK_ROCKET_TWINKLE_FAR, 6 FIREWORK_ROCKET_TWINKLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAR                  BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-FAR L-SOUND.
     IF L-FAR NOT = 0
         MOVE 5 TO L-SOUND
     ELSE
         MOVE 6 TO L-SOUND
     END-IF
     GOBACK.
 END PROGRAM P2-FW-TWINKLE-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-PITCH.
*> 3.13 sound pitch: USING kind (0 launch, 1 twinkle), draw, pitch out: 0.95 + r * 0.1 or 0.9 + r * 0.15.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-DRAW L-PITCH.
     IF L-KIND = 0
         COMPUTE L-PITCH = 0.95 + L-DRAW * 0.1
     ELSE
         COMPUTE L-PITCH = 0.9 + L-DRAW * 0.15
     END-IF
     GOBACK.
 END PROGRAM P2-FW-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-STARTER-TICK.
*> 3.13 starter tick steps 2 to 4: USING life (in and out), lifetime, explosion count, explosion index out (-1
*> for none: life even and life / 2 < count gives life / 2), remove out (life > lifetime after the increment).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIFE                 BINARY-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-REMOVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-LIFE L-LIFETIME L-N L-INDEX L-REMOVE.
     MOVE -1 TO L-INDEX
     IF FUNCTION MOD(L-LIFE, 2) = 0 AND L-LIFE / 2 < L-N
         COMPUTE L-INDEX = FUNCTION INTEGER-PART(L-LIFE / 2)
     END-IF
     ADD 1 TO L-LIFE
     MOVE 0 TO L-REMOVE
     IF L-LIFE > L-LIFETIME
         MOVE 1 TO L-REMOVE
     END-IF
     GOBACK.
 END PROGRAM P2-FW-STARTER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-SPARK-NEW.
*> 3.13 SparkParticle and the starter's creation call: USING PCL, PCLX, P2X, x, y, z, vx, vy, vz, trail, twinkle,
*> draws (1-2 the animated base, 3 nextInt(12)): gravity 0.1, velocity exact, quadSize * 0.75, lifetime 48 +
*> n, alpha 0.99. The colour and fade picks follow (P2-FW-PICK, PSA-SET-COLOR, PSA-SET-FADE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.1.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY CLP2X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-TRAIL                BINARY-LONG.
 01 L-TWINKLE              BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL PCLX P2X L-X L-Y L-Z L-VX L-VY L-VZ L-TRAIL L-TWINKLE L-DRAWS.
     CALL "PSA-NEW" USING PCL PCLX L-X L-Y L-Z WS-GRAVITY L-DRAWS
     INITIALIZE P2X
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75
     COMPUTE PC-LIFETIME = 48 + FUNCTION INTEGER-PART(L-DRAW(3) * 12)
     MOVE 0 TO PC-SPRITE
     MOVE L-TRAIL TO X2-TRAIL
     MOVE L-TWINKLE TO X2-TWINKLE
     MOVE 0.99 TO PC-ALPHA
     GOBACK.
 END PROGRAM P2-FW-SPARK-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-PICK.
*> 3.13 Util.getRandom: USING draw, list size, index out = nextInt(size) (one draw even for one element).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-SIZE L-INDEX.
     CALL "PSET-RANDOM" USING L-SIZE L-DRAW L-INDEX
     GOBACK.
 END PROGRAM P2-FW-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPARK-TICK.
*> 3.13 SparkParticle tick: USING PCL, PCLX, P2X, PCL-COLLIDERS, trail out: the animated tick (8 sprites),
*> then a trail spark is wanted when trail is set, age < lifetime / 2 (integer) and age + lifetime is even.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 8.
 01 WS-HALF                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY CLP2X.
 01 L-TRAIL-OUT            BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCLX P2X PCL-COLLIDERS L-TRAIL-OUT.
     CALL "PSA-TICK" USING PCL PCLX PCL-COLLIDERS WS-N
     MOVE 0 TO L-TRAIL-OUT
     COMPUTE WS-HALF = FUNCTION INTEGER-PART(PC-LIFETIME / 2)
     IF X2-TRAIL NOT = 0 AND PC-AGE < WS-HALF AND FUNCTION MOD(PC-AGE + PC-LIFETIME, 2) = 0
         MOVE 1 TO L-TRAIL-OUT
     END-IF
     GOBACK.
 END PROGRAM P2-SPARK-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPARK-TRAIL-NEW.
*> 3.13 trail spark: USING PCL, PCLX, P2X, x, y, z (the parent's position), red, green, blue (the parent's
*> colour), twinkle, draws (as P2-FW-SPARK-NEW): a spark with zero velocity, alpha 0.99, the parent's colour,
*> age = lifetime / 2, no fade colour (the copy of the fade is a no-op).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-2              FLOAT-LONG VALUE 0.
 01 WS-ZERO-3              FLOAT-LONG VALUE 0.
 01 WS-NO-TRAIL            BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY CLP2X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-TWINKLE              BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL PCLX P2X L-X L-Y L-Z L-R L-G L-B L-TWINKLE L-DRAWS.
     CALL "P2-FW-SPARK-NEW" USING PCL PCLX P2X L-X L-Y L-Z WS-ZERO WS-ZERO-2 WS-ZERO-3
         WS-NO-TRAIL L-TWINKLE L-DRAWS
     CALL "PCL-SET-COLOR" USING PCL L-R L-G L-B
     COMPUTE PC-AGE = FUNCTION INTEGER-PART(PC-LIFETIME / 2)
     GOBACK.
 END PROGRAM P2-SPARK-TRAIL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPARK-VISIBLE.
*> 3.13 twinkle blink (E9): USING age, lifetime, twinkle, visible out: hidden when twinkle is set, age >=
*> lifetime / 3 (integer) and ((age + lifetime) / 3, integer) is odd.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-THIRD               BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-TWINKLE              BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-LIFETIME L-TWINKLE L-VISIBLE.
     MOVE 1 TO L-VISIBLE
     COMPUTE WS-THIRD = FUNCTION INTEGER-PART(L-LIFETIME / 3)
     COMPUTE WS-PHASE = FUNCTION INTEGER-PART((L-AGE + L-LIFETIME) / 3)
     IF L-TWINKLE NOT = 0 AND L-AGE >= WS-THIRD AND FUNCTION MOD(WS-PHASE, 2) = 1
         MOVE 0 TO L-VISIBLE
     END-IF
     GOBACK.
 END PROGRAM P2-SPARK-VISIBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FLASH-NEW.
*> 3.13 OverlayParticle (flash): USING PCL, x, y, z, draws (Base2 2): lifetime 4.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAWS.
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE 4 TO PC-LIFETIME
     GOBACK.
 END PROGRAM P2-FLASH-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FLASH-RENDER.
*> 3.13 flash extract step: USING age, partial, alpha out, half size out: u = (age + partial - 1) * 0.25,
*> alpha = 0.6 - u * 0.5, size = 7.1 * Mth.sin(u * pi).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-U                   FLOAT-LONG.
 01 WS-ARG                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-ALPHA                FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-AGE L-PARTIAL L-ALPHA L-SIZE.
     COMPUTE WS-U = (L-AGE + L-PARTIAL - 1) * 0.25
     COMPUTE L-ALPHA = 0.6 - WS-U * 0.5
     COMPUTE WS-ARG = WS-U * 3.1415927
     CALL "PENG-MTH-SIN" USING WS-ARG WS-SIN
     COMPUTE L-SIZE = 7.1 * WS-SIN
     GOBACK.
 END PROGRAM P2-FLASH-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-BALL-USED.
*> 3.13 ball cells: USING a, b, c, count, used out: when a and b are both strictly between -count and count
*> only c = -count and c = +count are used; else every c.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-C L-COUNT L-USED.
     MOVE 1 TO L-USED
     IF FUNCTION ABS(L-A) < L-COUNT AND FUNCTION ABS(L-B) < L-COUNT AND FUNCTION ABS(L-C) NOT = L-COUNT
         MOVE 0 TO L-USED
     END-IF
     GOBACK.
 END PROGRAM P2-FW-BALL-USED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-BALL-CELLS.
*> 3.13 and E7: USING count, cells out: the used cells of the three nested loops (98 for 2, 386 for 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-NEG                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-CELLS                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-CELLS.
     MOVE 0 TO L-CELLS
     COMPUTE WS-NEG = 0 - L-COUNT
     PERFORM VARYING WS-A FROM WS-NEG BY 1 UNTIL WS-A > L-COUNT
         PERFORM VARYING WS-B FROM WS-NEG BY 1 UNTIL WS-B > L-COUNT
             PERFORM VARYING WS-C FROM WS-NEG BY 1 UNTIL WS-C > L-COUNT
                 CALL "P2-FW-BALL-USED" USING WS-A WS-B WS-C L-COUNT WS-USED
                 ADD WS-USED TO L-CELLS
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM P2-FW-BALL-CELLS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-BALL-VEL.
*> 3.13 ball spark velocity: USING a, b, c, size, draws (6 nextDouble), gaussian, vx, vy, vz out: vx = b +
*> (d1 - d2) * 0.5, vy = a + (d3 - d4) * 0.5, vz = c + (d5 - d6) * 0.5; len = |v| / size + gaussian * 0.05;
*> the velocity is v / len (a zero len gives zero: the document read no guard).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-SIZE                 FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-GAUSS                FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-A L-B L-C L-SIZE L-DRAWS L-GAUSS L-VX L-VY L-VZ.
     COMPUTE WS-X = L-B + (L-DRAW(1) - L-DRAW(2)) * 0.5
     COMPUTE WS-Y = L-A + (L-DRAW(3) - L-DRAW(4)) * 0.5
     COMPUTE WS-Z = L-C + (L-DRAW(5) - L-DRAW(6)) * 0.5
     COMPUTE WS-LEN = FUNCTION SQRT(WS-X * WS-X + WS-Y * WS-Y + WS-Z * WS-Z) / L-SIZE + L-GAUSS * 0.05
     IF WS-LEN = 0
         MOVE 0 TO L-VX L-VY L-VZ
     ELSE
         COMPUTE L-VX = WS-X / WS-LEN
         COMPUTE L-VY = WS-Y / WS-LEN
         COMPUTE L-VZ = WS-Z / WS-LEN
     END-IF
     GOBACK.
 END PROGRAM P2-FW-BALL-VEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-SPARK-COUNT.
*> 3.13 and V10: USING shape ordinal, sparks out: small ball 98, large ball 386, star 121, creeper 265, burst 70.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-COUNT.
     EVALUATE L-SHAPE
         WHEN 0 MOVE 98 TO L-COUNT
         WHEN 1 MOVE 386 TO L-COUNT
         WHEN 2 MOVE 121 TO L-COUNT
         WHEN 3 MOVE 265 TO L-COUNT
         WHEN OTHER MOVE 70 TO L-COUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM P2-FW-SPARK-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-TABLE-ROWS.
*> 3.13: USING shape (2 star, 3 creeper), rows out (6 and 12).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-ROWS.
     IF L-SHAPE = 2
         MOVE 6 TO L-ROWS
     ELSE
         MOVE 12 TO L-ROWS
     END-IF
     GOBACK.
 END PROGRAM P2-FW-TABLE-ROWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-TABLE.
*> 3.13 shape tables: USING shape (2 star, 3 creeper), row (0-based), x out, y out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STAR-DATA.
    05 FILLER              FLOAT-LONG VALUE 0.0.
    05 FILLER              FLOAT-LONG VALUE 1.0.
    05 FILLER              FLOAT-LONG VALUE 0.3455.
    05 FILLER              FLOAT-LONG VALUE 0.309.
    05 FILLER              FLOAT-LONG VALUE 0.9511.
    05 FILLER              FLOAT-LONG VALUE 0.309.
    05 FILLER              FLOAT-LONG VALUE 0.3795918367346939.
    05 FILLER              FLOAT-LONG VALUE -0.12653061224489795.
    05 FILLER              FLOAT-LONG VALUE 0.6122448979591837.
    05 FILLER              FLOAT-LONG VALUE -0.8040816326530612.
    05 FILLER              FLOAT-LONG VALUE 0.0.
    05 FILLER              FLOAT-LONG VALUE -0.35918367346938773.
 01 WS-STAR REDEFINES WS-STAR-DATA.
    05 WS-STAR-ROW         OCCURS 6 TIMES.
       10 WS-STAR-X        FLOAT-LONG.
       10 WS-STAR-Y        FLOAT-LONG.
 01 WS-CREEPER-DATA.
    05 FILLER              FLOAT-LONG VALUE 0.0.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.6.
    05 FILLER              FLOAT-LONG VALUE 0.6.
    05 FILLER              FLOAT-LONG VALUE 0.6.
    05 FILLER              FLOAT-LONG VALUE 0.6.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.0.
    05 FILLER              FLOAT-LONG VALUE 0.4.
    05 FILLER              FLOAT-LONG VALUE 0.0.
    05 FILLER              FLOAT-LONG VALUE 0.4.
    05 FILLER              FLOAT-LONG VALUE -0.6.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE -0.6.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE -0.4.
    05 FILLER              FLOAT-LONG VALUE 0.0.
    05 FILLER              FLOAT-LONG VALUE -0.4.
 01 WS-CREEPER REDEFINES WS-CREEPER-DATA.
    05 WS-CREEPER-ROW      OCCURS 12 TIMES.
       10 WS-CREEPER-X     FLOAT-LONG.
       10 WS-CREEPER-Y     FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-ROW L-X L-Y.
     COMPUTE WS-I = L-ROW + 1
     IF L-SHAPE = 2
         MOVE WS-STAR-X(WS-I) TO L-X
         MOVE WS-STAR-Y(WS-I) TO L-Y
     ELSE
         MOVE WS-CREEPER-X(WS-I) TO L-X
         MOVE WS-CREEPER-Y(WS-I) TO L-Y
     END-IF
     GOBACK.
 END PROGRAM P2-FW-TABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-STAR-FIRST.
*> 3.13 star and creeper: USING shape, vx, vy, vz out: the first spark at (row 0 x * 0.5, row 0 y * 0.5, 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-VX L-VY L-VZ.
     CALL "P2-FW-TABLE" USING L-SHAPE WS-ROW WS-X WS-Y
     COMPUTE L-VX = WS-X * 0.5
     COMPUTE L-VY = WS-Y * 0.5
     MOVE 0 TO L-VZ
     GOBACK.
 END PROGRAM P2-FW-STAR-FIRST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-STAR-ANG0.
*> 3.13: USING draw, ang0 out = r * pi (the float 3.1415927).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-ANG                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DRAW L-ANG.
     COMPUTE L-ANG = L-DRAW * 3.1415927
     GOBACK.
 END PROGRAM P2-FW-STAR-ANG0.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-STAR-VEL.
*> 3.13 star and creeper spark: USING shape, m (0 to 2), segment i (1 to rows - 1), step j (1 to 4: s = j *
*> 0.25), dir (-1 or +1), ang0, vx, vy, vz out: P = 0.5 * (row[i-1] + s * (row[i] - row[i-1])), ang = ang0 +
*> m * pi * k (k 0.34 star, 0.034 creeper), v = (P.x * cos(ang) * dir, P.y, P.x * sin(ang) * dir) with the
*> standard sine and cosine.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R0                  BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-ANG                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-J                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ANG0                 FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-M L-I L-J L-DIR L-ANG0 L-VX L-VY L-VZ.
     COMPUTE WS-R0 = L-I - 1
     CALL "P2-FW-TABLE" USING L-SHAPE WS-R0 WS-X0 WS-Y0
     CALL "P2-FW-TABLE" USING L-SHAPE L-I WS-X1 WS-Y1
     COMPUTE WS-S = L-J * 0.25
     COMPUTE WS-PX = 0.5 * (WS-X0 + WS-S * (WS-X1 - WS-X0))
     COMPUTE WS-PY = 0.5 * (WS-Y0 + WS-S * (WS-Y1 - WS-Y0))
     MOVE 0.34 TO WS-K
     IF L-SHAPE = 3
         MOVE 0.034 TO WS-K
     END-IF
     COMPUTE WS-ANG = L-ANG0 + L-M * 3.1415927 * WS-K
     COMPUTE L-VX = WS-PX * FUNCTION COS(WS-ANG) * L-DIR
     MOVE WS-PY TO L-VY
     COMPUTE L-VZ = WS-PX * FUNCTION SIN(WS-ANG) * L-DIR
     GOBACK.
 END PROGRAM P2-FW-STAR-VEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FW-BURST-VEL.
*> 3.13 burst spark: USING the starter velocity xd, yd, zd, g1, g2 (the two 0.05-scaled gaussians), gaussian x,
*> gaussian z, the nextDouble for y, then vx, vy, vz out: vx = xd * 0.5 + gx * 0.15 + g1, vz = zd * 0.5 +
*> gz * 0.15 + g2, vy = yd * 0.5 + d * 0.5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-XD                   FLOAT-LONG.
 01 L-YD                   FLOAT-LONG.
 01 L-ZD                   FLOAT-LONG.
 01 L-G1                   FLOAT-LONG.
 01 L-G2                   FLOAT-LONG.
 01 L-GX                   FLOAT-LONG.
 01 L-GZ                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-XD L-YD L-ZD L-G1 L-G2 L-GX L-GZ L-DY L-VX L-VY L-VZ.
     COMPUTE L-VX = L-XD * 0.5 + L-GX * 0.15 + L-G1
     COMPUTE L-VZ = L-ZD * 0.5 + L-GZ * 0.15 + L-G2
     COMPUTE L-VY = L-YD * 0.5 + L-DY * 0.5
     GOBACK.
 END PROGRAM P2-FW-BURST-VEL.
