*> Implementation test of client/src/sky-render.cob (12 section 3.2 the day timeline's angle, star and cloud tracks, 3.4c the sun, moon and star
*> quads, 3.5 the weather layers, 3.6 the clouds): SKY-EASE (the cubic bezier of the angle tracks), SKY-ANGLES (the attribute values at a tick of
*> the clock and a weather), SKY-MATRIX (the frame of a body: rotate Y by -90 degrees, then X by the angle), SKY-BODIES-MESH, SKY-STARS-MESH,
*> SKY-CLOUDS-LOAD and SKY-CLOUDS-MESH (which faces of which cells). Expected values are computed here from the documented keyframes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SKY-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-U                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-N                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CELL-X              BINARY-LONG.
 01 WS-CELL-Z              BINARY-LONG.
 01 WS-REL                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-PV-TABLE.
    05 WS-PV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OUT-TABLE.
    05 WS-OUT              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-E                   PIC -9.999.
 01 WS-E1                  PIC -9.999.
 01 WS-E2                  PIC -9.999.
 01 WS-E3                  PIC -9.999.
 01 WS-E4                  PIC -9.999.
 01 WS-F1                  PIC -(3)9.999.
 01 WS-F2                  PIC -(3)9.999.
 01 WS-F3                  PIC -(3)9.999.
 01 WS-F4                  PIC -(3)9.999.
 01 B-VERTEX BASED.
    05 B-V OCCURS 120000 TIMES.
       10 B-X              FLOAT-SHORT.
       10 B-Y              FLOAT-SHORT.
       10 B-Z              FLOAT-SHORT.
       10 B-U              FLOAT-SHORT.
       10 B-V-TEX          FLOAT-SHORT.
       10 B-B              FLOAT-SHORT.
       10 B-A              FLOAT-SHORT.
       10 B-SKY            FLOAT-SHORT.
       10 B-R              FLOAT-SHORT.
       10 B-G              FLOAT-SHORT.
       10 B-BLUE           FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE

*>   The ease of the angle tracks: cubic-bezier(0.362, 0.241, 0.638, 0.759), point symmetric about (0.5, 0.5), a little slower than linear at the ends.
     MOVE 0 TO WS-U
     CALL "SKY-EASE" USING WS-U WS-Y
     COMPUTE WS-E1 ROUNDED = WS-Y
     MOVE 0.5 TO WS-U
     CALL "SKY-EASE" USING WS-U WS-Y
     COMPUTE WS-E2 ROUNDED = WS-Y
     MOVE 1 TO WS-U
     CALL "SKY-EASE" USING WS-U WS-Y
     COMPUTE WS-E3 ROUNDED = WS-Y
     MOVE 0.25 TO WS-U
     CALL "SKY-EASE" USING WS-U WS-Y
     COMPUTE WS-E4 ROUNDED = WS-Y
     MOVE "sky ease: bezier of the angle tracks at 0, 0.5, 1 and 0.25 (between 0.2 and 0.3)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE " 0.000  0.500  1.000 ok" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-Y > 0.2 AND WS-Y < 0.3
         STRING WS-E1 " " WS-E2 " " WS-E3 " ok" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING WS-E1 " " WS-E2 " " WS-E3 " " WS-E4 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The angles at noon (tick 6000: sun 0, moon 180, stars 0) and at midnight (18000: sun 180, moon 540, stars 360).
     MOVE 6000 TO PL-TIME
     MOVE 6000 TO PL-DAY-TICKS
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky angles: tick 6000 sun 0, moon 180, star 0 degrees (x 1000)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-SUN-ANGLE * 1000 + 0.5) * 1000000000 / 1000000000
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sky angles: tick 6000 moon 180 degrees (x 1000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-MOON-ANGLE * 1000 + 0.5)
     MOVE 180000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18000 TO PL-TIME
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky angles: tick 18000 sun 180 degrees (x 1000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-SUN-ANGLE * 1000 + 0.5)
     MOVE 180000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sky angles: tick 18000 moon 360 (halfway from 180 to 540) and star 180 degrees (x 1000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-MOON-ANGLE * 1000 + 0.5) * 1000000 + FUNCTION INTEGER(SK-STAR-ANGLE * 1000 + 0.5)
     COMPUTE TL-EXPECTED-N = 360000 * 1000000 + 180000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Tick 0: 0.75 of the way round from tick 6000: the sun is about 270 degrees (rising in the east).
     MOVE 0 TO PL-TIME
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky angles: tick 0 the sun is between 260 and 290 degrees (rising)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "rising" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF SK-SUN-ANGLE > 260 AND SK-SUN-ANGLE < 290
         MOVE "rising" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The star brightness track (maximum, linear between the keyframes, cyclic): 0 at noon, 0.5 at midnight, 0.143 at 12399, the middle of 11959
*>   (0.044) and 12399 (0.143) at 12179, and tick 0 on the segment from 23758 (0.101) to 92 + 24000 (0.037).
     MOVE "N" TO TL-MODE
     MOVE 6000 TO PL-TIME
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky stars: brightness at tick 6000 is 0 (x 10000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-STAR-BRIGHT * 10000 + 0.5)
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18000 TO PL-TIME
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky stars: brightness at tick 18000 is 0.5 (x 10000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-STAR-BRIGHT * 10000 + 0.5)
     MOVE 5000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12399 TO PL-TIME
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky stars: brightness at keyframe 12399 is 0.143 (x 10000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-STAR-BRIGHT * 10000 + 0.5)
     MOVE 1430 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12179 TO PL-TIME
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky stars: brightness at tick 12179 is the middle of 0.044 and 0.143, 0.0935 (x 10000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-STAR-BRIGHT * 10000 + 0.5)
     MOVE 935 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-TIME
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky stars: brightness at tick 0 is on the wrapped segment 23758 to 24092, 0.101 + (0.037 - 0.101) 242 / 334 (x 10000)" TO TL-CASE
     COMPUTE WS-Y = 0.101 + (0.037 - 0.101) * 242 / 334
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-STAR-BRIGHT * 10000 + 0.5)
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(WS-Y * 10000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18000 TO PL-TIME
     MOVE 1 TO PL-RAIN
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky stars: a full rain level sets the brightness towards 0, the sun and moon alpha to 0 (x 10000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-STAR-BRIGHT * 10000 + 0.5) * 100000 + FUNCTION INTEGER(SK-BODY-ALPHA * 10000 + 0.5)
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.25 TO PL-RAIN
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "sky stars: a rain level of 0.25 gives the sun and moon the alpha 0.75 (x 10000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-BODY-ALPHA * 10000 + 0.5)
     MOVE 7500 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-RAIN

*>   The moon phase: the moon timeline steps one phase per 24000 ticks of the clock, period 192000.
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-DAY-TICKS
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE SK-MOON-PHASE TO TL-OBSERVED-N
     MOVE 24000 TO PL-DAY-TICKS
     CALL "SKY-ANGLES" USING CLIENT-STATE
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + SK-MOON-PHASE
     MOVE 119999 TO PL-DAY-TICKS
     CALL "SKY-ANGLES" USING CLIENT-STATE
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + SK-MOON-PHASE
     MOVE 120000 TO PL-DAY-TICKS
     CALL "SKY-ANGLES" USING CLIENT-STATE
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + SK-MOON-PHASE
     MOVE 191999 TO PL-DAY-TICKS
     CALL "SKY-ANGLES" USING CLIENT-STATE
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + SK-MOON-PHASE
     MOVE 192000 TO PL-DAY-TICKS
     CALL "SKY-ANGLES" USING CLIENT-STATE
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + SK-MOON-PHASE
     MOVE "sky moon: the phase at clock 0, 24000, 119999, 120000, 191999, 192000 is 0 1 4 5 7 0" TO TL-CASE
     MOVE 014570 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cloud colour: #ccffffff by day (alpha 0.8), times the day track's #191926 by night (25, 25, 38 of 255), then the weather layers
*>   blend_to_gray: the rain's (0.24, 0.5) and the thunder's (0.095, 0.94) towards the grey.
     MOVE 6000 TO PL-TIME
     CALL "SKY-ANGLES" USING CLIENT-STATE
     PERFORM CLOUD-COLOUR-TEXT
     MOVE "sky clouds: the colour at noon is white, alpha 0.8" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE " 1.000  1.000  1.000  0.800" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18000 TO PL-TIME
     CALL "SKY-ANGLES" USING CLIENT-STATE
     PERFORM CLOUD-COLOUR-TEXT
     MOVE "sky clouds: the colour at midnight is #191926, alpha 0.8" TO TL-CASE
     COMPUTE WS-E1 = 25 / 255
     COMPUTE WS-E3 = 38 / 255
     MOVE SPACES TO TL-EXPECTED
     STRING WS-E1 " " WS-E1 " " WS-E3 "  0.800" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6000 TO PL-TIME
     MOVE 1 TO PL-RAIN
     CALL "SKY-ANGLES" USING CLIENT-STATE
     PERFORM CLOUD-COLOUR-TEXT
     MOVE "sky clouds: full rain at noon blends the colour half way to the grey 0.24: 0.62" TO TL-CASE
     MOVE " 0.620  0.620  0.620  0.800" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO PL-THUNDER
     CALL "SKY-ANGLES" USING CLIENT-STATE
     PERFORM CLOUD-COLOUR-TEXT
     MOVE "sky clouds: full rain and a thunder level of 0.5 at noon: 0.62, then 0.47 of the way to the grey 0.095: 0.373" TO TL-CASE
     COMPUTE WS-Y = 0.62 + (0.095 - 0.62) * 0.47
     COMPUTE WS-E1 ROUNDED = WS-Y
     MOVE SPACES TO TL-EXPECTED
     STRING WS-E1 " " WS-E1 " " WS-E1 "  0.800" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-RAIN PL-THUNDER
     CALL "SKY-ANGLES" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "sky clouds: the layer's bottom is at visual/cloud_height 192.33 (x 100)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(SK-CLOUD-HEIGHT * 100 + 0.5)
     MOVE 19233 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The body frame: with the identity as projection x view and angle 0 the quad of the sun (0, 100, 0) stays overhead; rotate Y by -90 degrees
*>   then X by the angle: column j of the matrix is R's column j (R rows (0, -s, -c), (0, c, -s), (1, 0, 0)).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO WS-PV(WS-I)
     END-PERFORM
     MOVE 1 TO WS-PV(1) WS-PV(6) WS-PV(11) WS-PV(16)
     MOVE 0 TO WS-ANGLE
     CALL "SKY-MATRIX" USING WS-PV-TABLE WS-ANGLE WS-OUT-TABLE
     MOVE "T" TO TL-MODE
     MOVE "sky matrix: angle 0, identity: columns (0 0 1) (0 1 0) (-1 0 0) and the translation 0" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     PERFORM MATRIX-TEXT
     MOVE "0.000 0.000 1.000 0.000 1.000 0.000 -1.000 0.000 0.000 0.000 0.000 0.000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 90 TO WS-ANGLE
     CALL "SKY-MATRIX" USING WS-PV-TABLE WS-ANGLE WS-OUT-TABLE
     MOVE "sky matrix: angle 90, identity: columns (0 0 1) (-1 0 0) (0 -1 0)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     PERFORM MATRIX-TEXT
     MOVE "0.000 0.000 1.000 -1.000 0.000 0.000 0.000 -1.000 0.000 0.000 0.000 0.000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The sun and the moon quads with a sprite in the atlas (the sprite at (16, 32), 32 x 32 of a 128 x 128 atlas): the sun's corners
*>   (-30, 100, -30) (30, 100, -30) (30, 100, 30) (-30, 100, 30) with the UVs (u0, v0) (u1, v0) (u1, v1) (u0, v1); the moon's half-size 20 and the
*>   UVs turned half way round: (u1, v1) (u0, v1) (u0, v0) (u1, v0). Modulator alpha 1 - rain, on the block atlas (texture 0).
     MOVE 128 TO AT-W AT-H
     MOVE 3 TO AT-SPRITE-COUNT
     MOVE "minecraft:sun" TO AT-NAME(2)
     MOVE 13 TO AT-NAME-LENGTH(2)
     MOVE 16 TO AT-X(2)
     MOVE 32 TO AT-Y(2)
     MOVE 32 TO AT-SW(2) AT-SH(2)
     MOVE "minecraft:moon/waning_gibbous" TO AT-NAME(3)
     MOVE 29 TO AT-NAME-LENGTH(3)
     MOVE 64 TO AT-X(3)
     MOVE 96 TO AT-Y(3)
     MOVE 32 TO AT-SW(3) AT-SH(3)
     MOVE 6000 TO PL-TIME
     MOVE 24000 TO PL-DAY-TICKS
     MOVE 0.25 TO PL-RAIN
     CALL "SKY-ANGLES" USING CLIENT-STATE
     CALL "SKY-BODIES-MESH" USING CLIENT-STATE
     MOVE "sky bodies: with the sprites in the atlas the sun and the moon (waning_gibbous, day 1) are drawn from texture 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE SK-SUN-TEX TO TL-OBSERVED-N
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + SK-MOON-TEX
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "sky bodies: the sun's six vertices: the corners, UV of the sprite (0.125 0.25) to (0.375 0.5), alpha 0.75" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-F1 ROUNDED = SK-BV-X(WS-I)
         COMPUTE WS-F2 ROUNDED = SK-BV-Z(WS-I)
         COMPUTE WS-F3 ROUNDED = SK-BV-U(WS-I)
         COMPUTE WS-F4 ROUNDED = SK-BV-V(WS-I)
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-F1) "," FUNCTION TRIM(WS-F2) "," FUNCTION TRIM(WS-F3) ","
             FUNCTION TRIM(WS-F4) DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     COMPUTE WS-F1 ROUNDED = SK-BV-Y(1)
     COMPUTE WS-F2 ROUNDED = SK-BV-A(1)
     STRING FUNCTION TRIM(TL-OBSERVED) " y " FUNCTION TRIM(WS-F1) " a " FUNCTION TRIM(WS-F2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "-30.000,-30.000,0.125,0.250 30.000,-30.000,0.375,0.250 30.000,30.000,0.375,0.500 -30.000,-30.000,0.125,0.250 "
         & "30.000,30.000,0.375,0.500 -30.000,30.000,0.125,0.500 y 100.000 a 0.750" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sky bodies: the moon's six vertices: half-size 20, the UVs of the waning_gibbous sprite turned half way round" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     PERFORM VARYING WS-I FROM 7 BY 1 UNTIL WS-I > 12
         COMPUTE WS-F1 ROUNDED = SK-BV-X(WS-I)
         COMPUTE WS-F2 ROUNDED = SK-BV-Z(WS-I)
         COMPUTE WS-F3 ROUNDED = SK-BV-U(WS-I)
         COMPUTE WS-F4 ROUNDED = SK-BV-V(WS-I)
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-F1) "," FUNCTION TRIM(WS-F2) "," FUNCTION TRIM(WS-F3) ","
             FUNCTION TRIM(WS-F4) DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     MOVE "-20.000,-20.000,0.750,1.000 20.000,-20.000,0.500,1.000 20.000,20.000,0.500,0.750 -20.000,-20.000,0.750,1.000 "
         & "20.000,20.000,0.500,0.750 -20.000,20.000,0.750,0.750" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without the sprites (a built-in pack has none): flat quads of the white swatch of the UI atlas (texture 2).
     MOVE 1 TO AT-SPRITE-COUNT
     MOVE 64 TO UA-W
     MOVE 64 TO UA-H
     CALL "SKY-BODIES-MESH" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "sky bodies: with no sprite in the atlas both bodies are flat quads of the UI atlas swatch (texture 2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SK-SUN-TEX * 10 + SK-MOON-TEX
     MOVE 22 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-RAIN

*>   The stars: 1500 draws, those inside the unit ball's shell kept (about half): a quad of 6 vertices each, each corner about 100 away, alpha the
*>   level; a new level rewrites the alpha only.
     MOVE 32 TO WS-LEVEL
     CALL "SKY-STARS-MESH" USING CLIENT-STATE WS-LEVEL
     MOVE "N" TO TL-MODE
     MOVE "sky stars: the mesh has 6 vertices a star, between 400 and 1500 stars" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION MOD(SK-ST-COUNT, 6) = 0 AND SK-ST-COUNT >= 2400 AND SK-ST-COUNT <= 9000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SET ADDRESS OF B-VERTEX TO SK-ST-ADDR
     MOVE 0 TO WS-K
     MOVE 1000 TO WS-MIN
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SK-ST-COUNT
         COMPUTE WS-LEN = FUNCTION SQRT(B-X(WS-I) ** 2 + B-Y(WS-I) ** 2 + B-Z(WS-I) ** 2)
         MOVE FUNCTION MIN(WS-MIN, WS-LEN) TO WS-MIN
         MOVE FUNCTION MAX(WS-MAX, WS-LEN) TO WS-MAX
         IF B-A(WS-I) NOT = 0.5
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     MOVE "sky stars: every corner lies 99.5 to 100.5 from the origin, alpha 0.5 at level 32 of 64" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MIN > 99.5 AND WS-MAX < 100.5 AND WS-K = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SK-ST-COUNT TO WS-I
     MOVE 64 TO WS-LEVEL
     CALL "SKY-STARS-MESH" USING CLIENT-STATE WS-LEVEL
     MOVE "sky stars: a new level keeps the stars and rewrites the alpha (1.0 at level 64)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SK-ST-COUNT = WS-I AND B-A(1) = 1 AND B-A(SK-ST-COUNT) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cloud image of a built-in pack stack (no clouds.png): the procedural image, 256 x 256 cells with a fifth to two thirds of them solid.
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "SKY-CLOUDS-LOAD" USING CLIENT-STATE
     MOVE 0 TO WS-SOLID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 65536
         IF SK-CI-CELLS(WS-I:1) = "1"
             ADD 1 TO WS-SOLID
         END-IF
     END-PERFORM
     MOVE "sky clouds: with no clouds.png in the stack the image is 256 x 256 cells, a fifth to two thirds of them solid" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SK-CI-W = 256 AND SK-CI-H = 256 AND WS-SOLID > 13000 AND WS-SOLID < 44000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cloud mesh of an 8 x 8 image with one solid cell (index 1, 2) around the camera cell (0, 0), radius 3 cells, cells of 12 x 4 x 12 blocks.
     MOVE 8 TO SK-CI-W SK-CI-H
     MOVE ALL "0" TO SK-CI-CELLS(1:64)
     MOVE "1" TO SK-CI-CELLS(2 * 8 + 1 + 1:1)
     MOVE 3 TO WS-RADIUS
*>   The cell at dx = 1, dz = 2 (index (1, 2)), fancy, camera below the layer: the down face, the north face (dz > 0) and no west face (dx > 0 and the west
*>   neighbour empty: yes), so the faces DOWN, NORTH and WEST: 3 quads. Up is left out below the layer.
     MOVE 0 TO WS-CELL-X WS-CELL-Z
     MOVE 1 TO WS-REL
     MOVE 2 TO WS-MODE
     CALL "SKY-CLOUDS-MESH" USING CLIENT-STATE WS-CELL-X WS-CELL-Z WS-REL WS-MODE WS-RADIUS
     MOVE "N" TO TL-MODE
     MOVE "sky clouds: one fancy cell at dx 1, dz 2 under the layer has 3 faces (down, north, west) of 6 vertices" TO TL-CASE
     MOVE SK-CM-COUNT TO TL-OBSERVED-N
     MOVE 18 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The same above the layer: up, north, west.
     MOVE -1 TO WS-REL
     CALL "SKY-CLOUDS-MESH" USING CLIENT-STATE WS-CELL-X WS-CELL-Z WS-REL WS-MODE WS-RADIUS
     MOVE "sky clouds: the same cell above the layer has up, north and west faces (18 vertices)" TO TL-CASE
     MOVE SK-CM-COUNT TO TL-OBSERVED-N
     MOVE 18 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Inside the layer: up and down and the two sides.
     MOVE 0 TO WS-REL
     CALL "SKY-CLOUDS-MESH" USING CLIENT-STATE WS-CELL-X WS-CELL-Z WS-REL WS-MODE WS-RADIUS
     MOVE "sky clouds: the same cell with the camera inside the layer has up, down, north and west faces (24 vertices)" TO TL-CASE
     MOVE SK-CM-COUNT TO TL-OBSERVED-N
     MOVE 24 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Fast: one flat quad at the bottom of the layer (y 0, 12 x 12 at x 12 to 24, z 24 to 36).
     MOVE 1 TO WS-REL
     MOVE 1 TO WS-MODE
     CALL "SKY-CLOUDS-MESH" USING CLIENT-STATE WS-CELL-X WS-CELL-Z WS-REL WS-MODE WS-RADIUS
     SET ADDRESS OF B-VERTEX TO SK-CM-ADDR
     MOVE "T" TO TL-MODE
     MOVE "sky clouds: fast is one quad of 6 vertices on the bottom of the layer, x 12 to 24, z 24 to 36" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE 1000 TO WS-MIN
     MOVE -1000 TO WS-MAX
     MOVE 1000 TO WS-LEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SK-CM-COUNT
         MOVE FUNCTION MIN(WS-MIN, B-X(WS-I)) TO WS-MIN
         MOVE FUNCTION MAX(WS-MAX, B-X(WS-I)) TO WS-MAX
         IF B-Y(WS-I) < WS-LEN
             MOVE B-Y(WS-I) TO WS-LEN
         END-IF
     END-PERFORM
     MOVE "ok" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF SK-CM-COUNT = 6 AND WS-MIN = 12 AND WS-MAX = 24 AND WS-LEN = 0 AND B-Z(1) = 24
         MOVE "ok" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The radius: a cell at distance 2.24 cells is out of a radius of 2 and in a radius of 3.
     MOVE 2 TO WS-RADIUS
     MOVE 2 TO WS-MODE
     MOVE 1 TO WS-REL
     CALL "SKY-CLOUDS-MESH" USING CLIENT-STATE WS-CELL-X WS-CELL-Z WS-REL WS-MODE WS-RADIUS
     MOVE "N" TO TL-MODE
     MOVE "sky clouds: the cell at dx 1, dz 2 (distance 2.24 cells) is not meshed within a radius of 2 cells" TO TL-CASE
     MOVE SK-CM-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-RADIUS
     CALL "SKY-CLOUDS-MESH" USING CLIENT-STATE WS-CELL-X WS-CELL-Z WS-REL WS-MODE WS-RADIUS
     MOVE "sky clouds: the cell at dx 1, dz 2 is meshed within a radius of 3 cells (18 vertices)" TO TL-CASE
     MOVE SK-CM-COUNT TO TL-OBSERVED-N
     MOVE 18 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The image wraps: the camera cell (8, 16) is the cell (0, 0) of the image, so the cell at dx 1, dz 2 is the same one, and the disc of radius 8 holds copies.
     MOVE 8 TO WS-CELL-X
     MOVE 16 TO WS-CELL-Z
     MOVE 8 TO WS-RADIUS
     CALL "SKY-CLOUDS-MESH" USING CLIENT-STATE WS-CELL-X WS-CELL-Z WS-REL WS-MODE WS-RADIUS
     MOVE "sky clouds: the image wraps every 8 cells: a camera cell shifted by 8 and 16 still sees the cell (1, 2) and the disc of radius 8 holds more copies"
         TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SK-CM-COUNT > 18 AND FUNCTION MOD(SK-CM-COUNT, 6) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Negative cells wrap the same way (floor modulo): camera cell (-8, -8).
     MOVE -8 TO WS-CELL-X WS-CELL-Z
     MOVE 3 TO WS-RADIUS
     CALL "SKY-CLOUDS-MESH" USING CLIENT-STATE WS-CELL-X WS-CELL-Z WS-REL WS-MODE WS-RADIUS
     MOVE "sky clouds: negative camera cells wrap like positive ones (the same 18 vertices)" TO TL-CASE
     MOVE SK-CM-COUNT TO TL-OBSERVED-N
     MOVE 18 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CLOUD-COLOUR-TEXT.
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-E1 ROUNDED = SK-CLOUD-COLOUR(1)
     COMPUTE WS-E2 ROUNDED = SK-CLOUD-COLOUR(2)
     COMPUTE WS-E3 ROUNDED = SK-CLOUD-COLOUR(3)
     COMPUTE WS-E4 ROUNDED = SK-CLOUD-COLOUR(4)
     STRING WS-E1 " " WS-E2 " " WS-E3 " " WS-E4 DELIMITED BY SIZE INTO TL-OBSERVED.

 MATRIX-TEXT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-I NOT = 4 AND WS-I NOT = 8 AND WS-I NOT = 12 AND WS-I NOT = 16
             COMPUTE WS-E1 ROUNDED = WS-OUT(WS-I) + 0.0001
             STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED.

 END PROGRAM TEST-SKY-RENDER.
 COPY CLTEST.
