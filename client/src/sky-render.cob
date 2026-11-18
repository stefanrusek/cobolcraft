*> The sky of a dimension with sky light (12 section 3.2 the day timeline, 3.4c sun, moon and stars, 3.5 weather, 3.6 clouds; bug lane bugsky: the
*> render list had no draw of any of them, only the clear colour of SKY-UPDATE; the ticket CC-0007 had left them out of 002).
*>
*> SKY-ANGLES sets the attribute values the drawing reads from the clock (PL-TIME the time of day, PL-DAY-TICKS the clock's total ticks) and the
*> weather levels: the sun, moon and star angles (the same cubic bezier ease over one 24000-tick period from tick 6000: sun 0 to 360, moon 180 to
*> 540, stars 0 to 360), the star brightness (the day track's keyframes, driven to 0 by the rain level), the moon phase (one of 8 a day of the
*> clock), the modulator alpha 1 - rain of the sun and the moon, the cloud colour (white with alpha 0.8, times the day track towards #191926,
*> then the rain and thunder layers' blend_to_gray) and the cloud height 192.33 (the overworld's visual/cloud_height: the dimension type's attributes are
*> not sent by the core, 04 section 6, and the client reads none).
*> SKY-RENDER-BEHIND adds, first in the render list and before any terrain, the sun, the moon and the stars as meshes of their own (slots
*> MESH-SLOT-SUN, -MOON, -STARS) on the UI pipeline (no depth test, alpha blend: the closest the shim's pipelines come to the OVERLAY blend of 12 section 3.4c),
*> each with the matrix projection x view x (rotate Y by -90 degrees, rotate X by its angle). The sun and the moon quads are the atlas sprites
*> minecraft:sun and minecraft:moon/<phase> of the celestials atlas definition (ATLAS-BUILD reads it with the block atlas, so a pack's override is
*> found; a stack with no such sprite, the built-in pack, gets flat quads of the UI atlas swatch). The stars are 6 vertices each, a quad of
*> the swatch with the alpha of the brightness (rewritten when the brightness changes by a 64th).
*> SKY-RENDER-CLOUDS adds, after the translucent terrain, the clouds (slot MESH-SLOT-CLOUDS, translucent pipeline, depth test, the swatch of the UI atlas): the
*> image clouds.png of the stack (a cell is solid when its alpha is 10 or more; a procedural image when no pack has one) meshed as 12 x 4 x 12 block
*> boxes (fancy) or flat quads on the layer's bottom (fast) around the camera's cell, camera and layer by the faces' rules of 12 section 3.6, rebuilt only when the
*> camera changes cell or the layer's side; the draw's matrix carries the scroll and the camera's place in the cell. Two fog records around it (RL-D-SLOT
*> -2) give the clouds the fog of the cloud range: the fog colour, from half the meshed radius to all of it. Not done: the sunrise and sunset glow
*> fan (3.4b), the inside faces of the camera's own cell, the end flash and sky box; the meshed radius is at most SKY-CLOUD-RADIUS-MAX cells
*> (cloudRange 128 asks for 171, a mesh of a million vertices a rebuild).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-EASE.
*> USING u (FLOAT-LONG 0 to 1), y out (FLOAT-LONG): the track's ease cubic-bezier(0.362, 0.241, 0.638, 0.759) (12 section 3.2): the parameter t
*> with x(t) = u by bisection, then y(t).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-U                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-U L-Y.
     MOVE 0 TO WS-LO
     MOVE 1 TO WS-HI
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         COMPUTE WS-T = (WS-LO + WS-HI) / 2
         COMPUTE WS-M = 1 - WS-T
         COMPUTE WS-X = 3 * WS-M * WS-M * WS-T * 0.362 + 3 * WS-M * WS-T * WS-T * 0.638 + WS-T * WS-T * WS-T
         IF WS-X < L-U
             MOVE WS-T TO WS-LO
         ELSE
             MOVE WS-T TO WS-HI
         END-IF
     END-PERFORM
     COMPUTE WS-T = (WS-LO + WS-HI) / 2
     COMPUTE WS-M = 1 - WS-T
     COMPUTE L-Y = 3 * WS-M * WS-M * WS-T * 0.241 + 3 * WS-M * WS-T * WS-T * 0.759 + WS-T * WS-T * WS-T
     GOBACK.
 END PROGRAM SKY-EASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STAR-TRACK.
*> USING tick (BINARY-LONG 0 to 23999), brightness out (FLOAT-LONG): the star_brightness track of the day timeline (12 section 3.2: modifier maximum, so the
*> value of the track; linear between the keyframes, the last one wrapping to the first through the period).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEYS.
    05 FILLER PIC 9(5) VALUE 92.
    05 FILLER PIC 9(5) VALUE 627.
    05 FILLER PIC 9(5) VALUE 11373.
    05 FILLER PIC 9(5) VALUE 11732.
    05 FILLER PIC 9(5) VALUE 11959.
    05 FILLER PIC 9(5) VALUE 12399.
    05 FILLER PIC 9(5) VALUE 12729.
    05 FILLER PIC 9(5) VALUE 13228.
    05 FILLER PIC 9(5) VALUE 22772.
    05 FILLER PIC 9(5) VALUE 23032.
    05 FILLER PIC 9(5) VALUE 23356.
    05 FILLER PIC 9(5) VALUE 23758.
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC 9(5) OCCURS 12 TIMES.
*> The values in thousandths.
 01 WS-VALUES.
    05 FILLER PIC 9(3) VALUE 37.
    05 FILLER PIC 9(3) VALUE 0.
    05 FILLER PIC 9(3) VALUE 0.
    05 FILLER PIC 9(3) VALUE 16.
    05 FILLER PIC 9(3) VALUE 44.
    05 FILLER PIC 9(3) VALUE 143.
    05 FILLER PIC 9(3) VALUE 258.
    05 FILLER PIC 9(3) VALUE 500.
    05 FILLER PIC 9(3) VALUE 500.
    05 FILLER PIC 9(3) VALUE 364.
    05 FILLER PIC 9(3) VALUE 225.
    05 FILLER PIC 9(3) VALUE 101.
 01 WS-VALUE-TABLE REDEFINES WS-VALUES.
    05 WS-VAL              PIC 9(3) OCCURS 12 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-VF                  BINARY-LONG.
 01 WS-VT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-TICK                 BINARY-LONG.
 01 L-BRIGHT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-TICK L-BRIGHT.
*>   From the last keyframe of the day through the period to the first, unless a later segment holds the tick.
     COMPUTE WS-FROM = WS-KEY(12) - 24000
     COMPUTE WS-TO = WS-KEY(1)
     MOVE WS-VAL(12) TO WS-VF
     MOVE WS-VAL(1) TO WS-VT
     IF L-TICK >= WS-KEY(12)
         MOVE WS-KEY(12) TO WS-FROM
         COMPUTE WS-TO = WS-KEY(1) + 24000
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 11
         IF L-TICK >= WS-KEY(WS-K) AND L-TICK < WS-KEY(WS-K + 1)
             MOVE WS-KEY(WS-K) TO WS-FROM
             MOVE WS-KEY(WS-K + 1) TO WS-TO
             MOVE WS-VAL(WS-K) TO WS-VF
             MOVE WS-VAL(WS-K + 1) TO WS-VT
         END-IF
     END-PERFORM
     COMPUTE L-BRIGHT = (WS-VF + (WS-VT - WS-VF) * (L-TICK - WS-FROM) / (WS-TO - WS-FROM)) / 1000
     GOBACK.
 END PROGRAM SKY-STAR-TRACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-ANGLES.
*> USING CLIENT-STATE: sets SK-SUN-ANGLE, SK-MOON-ANGLE, SK-STAR-ANGLE, SK-STAR-BRIGHT, SK-MOON-PHASE, SK-BODY-ALPHA, SK-CLOUD-COLOUR and
*> SK-CLOUD-HEIGHT from PL-TIME, PL-DAY-TICKS, PL-RAIN and PL-THUNDER (see the head of this file).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-RAIN                FLOAT-LONG.
 01 WS-THUNDER             FLOAT-LONG.
 01 WS-DAYS                BINARY-DOUBLE.
 01 WS-F                   FLOAT-LONG.
 01 WS-DARK                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-LAYER               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE PL-TIME TO WS-T
     MOVE PL-RAIN TO WS-RAIN
     MOVE PL-THUNDER TO WS-THUNDER
*>   One period from tick 6000 (angle 0), eased; the moon starts half a turn on.
     COMPUTE WS-U = FUNCTION MOD(WS-T + 18000, 24000) / 24000
     CALL "SKY-EASE" USING WS-U WS-Y
     COMPUTE SK-SUN-ANGLE = 360 * WS-Y
     COMPUTE SK-MOON-ANGLE = 180 + 360 * WS-Y
     COMPUTE SK-STAR-ANGLE = 360 * WS-Y
     CALL "SKY-STAR-TRACK" USING WS-T WS-B
     COMPUTE SK-STAR-BRIGHT = WS-B * (1 - WS-RAIN)
     COMPUTE SK-BODY-ALPHA = 1 - WS-RAIN
     DIVIDE PL-DAY-TICKS BY 24000 GIVING WS-DAYS
     COMPUTE SK-MOON-PHASE = FUNCTION MOD(WS-DAYS, 8)
*>   The cloud colour: the day track (multiply) is 1 from tick 133 to 11867, falls to 0 by 13670, 0 to 22330 and rises to 1 by 24133.
     EVALUATE TRUE
         WHEN WS-T < 133
             COMPUTE WS-F = (WS-T + 1670) / 1803
         WHEN WS-T <= 11867
             MOVE 1 TO WS-F
         WHEN WS-T < 13670
             COMPUTE WS-F = (13670 - WS-T) / 1803
         WHEN WS-T <= 22330
             MOVE 0 TO WS-F
         WHEN OTHER
             COMPUTE WS-F = (WS-T - 22330) / 1803
     END-EVALUATE
     COMPUTE WS-DARK(1) = 25 / 255
     COMPUTE WS-DARK(2) = 25 / 255
     COMPUTE WS-DARK(3) = 38 / 255
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE SK-CLOUD-COLOUR(WS-I) = WS-DARK(WS-I) + (1 - WS-DARK(WS-I)) * WS-F
*>       The weather layers (12 section 3.5): blend_to_gray towards 0.24 by half the rain level, then towards 0.095 by 0.94 of the thunder level.
         COMPUTE WS-LAYER = 0.5 * WS-RAIN
         COMPUTE SK-CLOUD-COLOUR(WS-I) = SK-CLOUD-COLOUR(WS-I) + (0.24 - SK-CLOUD-COLOUR(WS-I)) * WS-LAYER
         COMPUTE WS-LAYER = 0.94 * WS-THUNDER
         COMPUTE SK-CLOUD-COLOUR(WS-I) = SK-CLOUD-COLOUR(WS-I) + (0.095 - SK-CLOUD-COLOUR(WS-I)) * WS-LAYER
     END-PERFORM
     MOVE 0.8 TO SK-CLOUD-COLOUR(4)
     MOVE 192.33 TO SK-CLOUD-HEIGHT
     GOBACK.
 END PROGRAM SKY-ANGLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-MATRIX.
*> USING projection x view (16 FLOAT-LONG, column-major), angle (FLOAT-LONG degrees), matrix out (16 FLOAT-LONG): projection x view x (rotate Y by -90 degrees,
*> then rotate X by the angle) (12 section 3.4c). The rotation's rows are (0, -s, -c), (0, c, -s), (1, 0, 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-COLUMN              FLOAT-LONG OCCURS 9 TIMES.
 01 WS-J                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PV-TABLE.
    05 L-PV                FLOAT-LONG OCCURS 16 TIMES.
 01 L-ANGLE                FLOAT-LONG.
 01 L-OUT-TABLE.
    05 L-OUT               FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING L-PV-TABLE L-ANGLE L-OUT-TABLE.
     COMPUTE WS-RAD = L-ANGLE * FUNCTION PI / 180
     COMPUTE WS-S = FUNCTION SIN(WS-RAD)
     COMPUTE WS-C = FUNCTION COS(WS-RAD)
*>   Columns 1 to 3 of the rotation, three entries each.
     MOVE 0 TO WS-COLUMN(1) WS-COLUMN(2)
     MOVE 1 TO WS-COLUMN(3)
     COMPUTE WS-COLUMN(4) = 0 - WS-S
     MOVE WS-C TO WS-COLUMN(5)
     MOVE 0 TO WS-COLUMN(6)
     COMPUTE WS-COLUMN(7) = 0 - WS-C
     COMPUTE WS-COLUMN(8) = 0 - WS-S
     MOVE 0 TO WS-COLUMN(9)
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
             MOVE 0 TO WS-SUM
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
                 COMPUTE WS-SUM = WS-SUM + L-PV(WS-K * 4 + WS-R) * WS-COLUMN(WS-J * 3 + WS-K + 1)
             END-PERFORM
             MOVE WS-SUM TO L-OUT(WS-J * 4 + WS-R)
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-R FROM 13 BY 1 UNTIL WS-R > 16
         MOVE L-PV(WS-R) TO L-OUT(WS-R)
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-MATRIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-QUAD.
*> USING vertices (POINTER), count (BINARY-LONG, in and out), quad (15 FLOAT-LONG: corner, first edge, second edge, r g b a, u, v): appends the quad's two
*> triangles (corner, corner + first, corner + first + second; corner, corner + first + second, corner + second) as 6 vertices of the shim's layout (brightness 1, sky 0);
*> nothing is added when they would not fit in SKY-CLOUD-VERTICES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-CORNERS             PIC X(6) VALUE "123134".
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 B-VERTEX BASED.
    05 B-V OCCURS 120000 TIMES.
       10 B-X              FLOAT-SHORT.
       10 B-Y              FLOAT-SHORT.
       10 B-Z              FLOAT-SHORT.
       10 B-U              FLOAT-SHORT.
       10 B-VV             FLOAT-SHORT.
       10 B-B              FLOAT-SHORT.
       10 B-A              FLOAT-SHORT.
       10 B-SKY            FLOAT-SHORT.
       10 B-R              FLOAT-SHORT.
       10 B-G              FLOAT-SHORT.
       10 B-BLUE           FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ADDR                 USAGE POINTER.
 01 L-COUNT                BINARY-LONG.
 01 L-QUAD-TABLE.
    05 L-Q                 FLOAT-LONG OCCURS 15 TIMES.
 PROCEDURE DIVISION USING L-ADDR L-COUNT L-QUAD-TABLE.
     IF L-COUNT + 6 > SKY-CLOUD-VERTICES
         GOBACK
     END-IF
     SET ADDRESS OF B-VERTEX TO L-ADDR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE FUNCTION NUMVAL(WS-CORNERS(WS-K:1)) TO WS-C
         MOVE 0 TO WS-A WS-B
         IF WS-C = 2 OR WS-C = 3
             MOVE 1 TO WS-A
         END-IF
         IF WS-C >= 3
             MOVE 1 TO WS-B
         END-IF
         ADD 1 TO L-COUNT
         COMPUTE B-X(L-COUNT) = L-Q(1) + L-Q(4) * WS-A + L-Q(7) * WS-B
         COMPUTE B-Y(L-COUNT) = L-Q(2) + L-Q(5) * WS-A + L-Q(8) * WS-B
         COMPUTE B-Z(L-COUNT) = L-Q(3) + L-Q(6) * WS-A + L-Q(9) * WS-B
         MOVE L-Q(14) TO B-U(L-COUNT)
         MOVE L-Q(15) TO B-VV(L-COUNT)
         MOVE 1 TO B-B(L-COUNT)
         MOVE L-Q(13) TO B-A(L-COUNT)
         MOVE 0 TO B-SKY(L-COUNT)
         MOVE L-Q(10) TO B-R(L-COUNT)
         MOVE L-Q(11) TO B-G(L-COUNT)
         MOVE L-Q(12) TO B-BLUE(L-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-BODIES-MESH.
*> USING CLIENT-STATE (SKY-ANGLES run): fills SK-BV rows 1 to 6 (the sun) and 7 to 12 (the moon of the phase SK-MOON-PHASE) and SK-SUN-TEX, SK-MOON-TEX (12 section 3.4c). The sun
*> quad has the corners (-30, 100, -30), (30, 100, -30), (30, 100, 30), (-30, 100, 30) and the sprite's corners (u0, v0), (u1, v0), (u1, v1), (u0, v1); the moon's
*> half-size is 20 and its sprite corners are turned half way round: (u1, v1), (u0, v1), (u0, v0), (u1, v0). The modulator is (1, 1, 1, SK-BODY-ALPHA). A body
*> whose sprite the atlas has is drawn from the block atlas (texture 0); otherwise from the white swatch of the UI atlas (texture 2) tinted
*> (1, 0.95, 0.6) for the sun and (0.85, 0.88, 0.95) for the moon.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PHASES.
    05 FILLER PIC X(16) VALUE "full_moon".
    05 FILLER PIC X(16) VALUE "waning_gibbous".
    05 FILLER PIC X(16) VALUE "third_quarter".
    05 FILLER PIC X(16) VALUE "waning_crescent".
    05 FILLER PIC X(16) VALUE "new_moon".
    05 FILLER PIC X(16) VALUE "waxing_crescent".
    05 FILLER PIC X(16) VALUE "first_quarter".
    05 FILLER PIC X(16) VALUE "waxing_gibbous".
 01 WS-PHASE-TABLE REDEFINES WS-PHASES.
    05 WS-PHASE            PIC X(16) OCCURS 8 TIMES.
 01 WS-CORNERS             PIC X(6) VALUE "123134".
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-CU                  FLOAT-SHORT.
 01 WS-CV                  FLOAT-SHORT.
 01 WS-TINT                FLOAT-SHORT OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-BODY FROM 1 BY 1 UNTIL WS-BODY > 2
         MOVE SPACES TO WS-ID
         IF WS-BODY = 1
             MOVE "minecraft:sun" TO WS-ID
             MOVE 13 TO WS-ID-LENGTH
             MOVE 30 TO WS-HALF
         ELSE
             STRING "minecraft:moon/" FUNCTION TRIM(WS-PHASE(SK-MOON-PHASE + 1)) DELIMITED BY SIZE INTO WS-ID
             COMPUTE WS-ID-LENGTH = 15 + FUNCTION LENGTH(FUNCTION TRIM(WS-PHASE(SK-MOON-PHASE + 1)))
             MOVE 20 TO WS-HALF
         END-IF
         CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SPRITE
*>       The sprite's rectangle, or the one texel of the swatch (the point the highlight uses) and the tint.
         MOVE 1 TO WS-TINT(1) WS-TINT(2) WS-TINT(3)
         IF WS-SPRITE > 0
             MOVE 0 TO WS-U16 WS-V16
             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-U0 WS-V0
             MOVE 16 TO WS-U16 WS-V16
             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-U1 WS-V1
             IF WS-BODY = 1
                 MOVE 0 TO SK-SUN-TEX
             ELSE
                 MOVE 0 TO SK-MOON-TEX
             END-IF
         ELSE
             COMPUTE WS-U0 = 4 / FUNCTION MAX(UA-W, 1)
             COMPUTE WS-V0 = (UA-H - 4) / FUNCTION MAX(UA-H, 1)
             MOVE WS-U0 TO WS-U1
             MOVE WS-V0 TO WS-V1
             IF WS-BODY = 1
                 MOVE 2 TO SK-SUN-TEX
                 MOVE 1 TO WS-TINT(1)
                 MOVE 0.95 TO WS-TINT(2)
                 MOVE 0.6 TO WS-TINT(3)
             ELSE
                 MOVE 2 TO SK-MOON-TEX
                 MOVE 0.85 TO WS-TINT(1)
                 MOVE 0.88 TO WS-TINT(2)
                 MOVE 0.95 TO WS-TINT(3)
             END-IF
         END-IF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             MOVE FUNCTION NUMVAL(WS-CORNERS(WS-K:1)) TO WS-C
             COMPUTE WS-ROW = (WS-BODY - 1) * 6 + WS-K
*>           Corner 1 (-1, -1), 2 (1, -1), 3 (1, 1), 4 (-1, 1) of the unit quad in x and z.
             MOVE WS-HALF TO WS-SX WS-SZ
             IF WS-C = 1 OR WS-C = 4
                 COMPUTE WS-SX = 0 - WS-HALF
             END-IF
             IF WS-C = 1 OR WS-C = 2
                 COMPUTE WS-SZ = 0 - WS-HALF
             END-IF
             MOVE WS-SX TO SK-BV-X(WS-ROW)
             MOVE 100 TO SK-BV-Y(WS-ROW)
             MOVE WS-SZ TO SK-BV-Z(WS-ROW)
*>           The sun's sprite corners; the moon's turned half way round.
             EVALUATE TRUE
                 WHEN WS-C = 1 AND WS-BODY = 1
                     MOVE WS-U0 TO WS-CU
                     MOVE WS-V0 TO WS-CV
                 WHEN WS-C = 2 AND WS-BODY = 1
                     MOVE WS-U1 TO WS-CU
                     MOVE WS-V0 TO WS-CV
                 WHEN WS-C = 3 AND WS-BODY = 1
                     MOVE WS-U1 TO WS-CU
                     MOVE WS-V1 TO WS-CV
                 WHEN WS-BODY = 1
                     MOVE WS-U0 TO WS-CU
                     MOVE WS-V1 TO WS-CV
                 WHEN WS-C = 1
                     MOVE WS-U1 TO WS-CU
                     MOVE WS-V1 TO WS-CV
                 WHEN WS-C = 2
                     MOVE WS-U0 TO WS-CU
                     MOVE WS-V1 TO WS-CV
                 WHEN WS-C = 3
                     MOVE WS-U0 TO WS-CU
                     MOVE WS-V0 TO WS-CV
                 WHEN OTHER
                     MOVE WS-U1 TO WS-CU
                     MOVE WS-V0 TO WS-CV
             END-EVALUATE
             MOVE WS-CU TO SK-BV-U(WS-ROW)
             MOVE WS-CV TO SK-BV-V(WS-ROW)
             MOVE 1 TO SK-BV-B(WS-ROW)
             MOVE SK-BODY-ALPHA TO SK-BV-A(WS-ROW)
             MOVE 0 TO SK-BV-SKY(WS-ROW)
             MOVE WS-TINT(1) TO SK-BV-R(WS-ROW)
             MOVE WS-TINT(2) TO SK-BV-G(WS-ROW)
             MOVE WS-TINT(3) TO SK-BV-BLUE(WS-ROW)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-BODIES-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STARS-MESH.
*> USING CLIENT-STATE, level (BINARY-LONG 1 to 64): the star mesh (12 section 3.4c): on the first call (SK-ST-ADDR NULL) the quads of the Java LCG seeded with 10842: for 1500
*> iterations three nextFloat for x, y, z (each 2 r - 1) and one for the size 0.15 + 0.1 r; a point whose squared length is not strictly between 0.01 and 1
*> is dropped, the others are put on the sphere of radius 100 with one nextDouble for the angle of the quad's turn about the line to the origin; the quad's corners
*> are p + (s, -s), (s, s), (-s, s), (-s, -s) in the plane across that line, the first axis of the plane being horizontal (the quads' turn is cosmetic, 12 section 3.4c).
*> Every call writes the texture coordinates (the swatch of the UI atlas) and the alpha (level / 64) of every vertex, and sets SK-ST-COUNT, SK-ST-LEVEL and the atlas size it was made for.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 10842.
 01 WS-R                   FLOAT-LONG OCCURS 4 TIMES.
 01 WS-P                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LEN2                FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-A                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-B                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-EX                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-EY                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-SIZE                FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-LO                  BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 WS-ALPHA               FLOAT-SHORT.
 01 WS-QUAD-TABLE.
    05 WS-Q                FLOAT-LONG OCCURS 15 TIMES.
 01 B-VERTEX BASED.
    05 B-V OCCURS 9000 TIMES.
       10 B-X              FLOAT-SHORT.
       10 B-Y              FLOAT-SHORT.
       10 B-Z              FLOAT-SHORT.
       10 B-U              FLOAT-SHORT.
       10 B-VV             FLOAT-SHORT.
       10 B-B              FLOAT-SHORT.
       10 B-A              FLOAT-SHORT.
       10 B-SKY            FLOAT-SHORT.
       10 B-R              FLOAT-SHORT.
       10 B-G              FLOAT-SHORT.
       10 B-BLUE           FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEVEL.
     COMPUTE WS-U = 4 / FUNCTION MAX(UA-W, 1)
     COMPUTE WS-V = (UA-H - 4) / FUNCTION MAX(UA-H, 1)
     COMPUTE WS-ALPHA = L-LEVEL / 64
     IF SK-ST-ADDR = NULL
         COMPUTE WS-BYTES = SKY-STAR-COUNT * 6 * 44
         ALLOCATE WS-BYTES CHARACTERS RETURNING SK-ST-ADDR
         SET ADDRESS OF B-VERTEX TO SK-ST-ADDR
         MOVE 0 TO SK-ST-COUNT
         CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SKY-STAR-COUNT
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R(WS-K)
             END-PERFORM
             COMPUTE WS-P(1) = 2 * WS-R(1) - 1
             COMPUTE WS-P(2) = 2 * WS-R(2) - 1
             COMPUTE WS-P(3) = 2 * WS-R(3) - 1
             COMPUTE WS-SIZE = 0.15 + 0.1 * WS-R(4)
             COMPUTE WS-LEN2 = WS-P(1) * WS-P(1) + WS-P(2) * WS-P(2) + WS-P(3) * WS-P(3)
             IF WS-LEN2 > 0.01 AND WS-LEN2 < 1
                 COMPUTE WS-LEN = FUNCTION SQRT(WS-LEN2)
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                     COMPUTE WS-P(WS-K) = WS-P(WS-K) / WS-LEN
                 END-PERFORM
*>               nextDouble: (next(26) x 2^27 + next(27)) / 2^53.
                 MOVE 26 TO WS-BITS
                 CALL "JRAND-NEXT" USING WS-STATE WS-BITS WS-HI
                 MOVE 27 TO WS-BITS
                 CALL "JRAND-NEXT" USING WS-STATE WS-BITS WS-LO
                 COMPUTE WS-ANGLE = (WS-HI * 134217728 + WS-LO) / 9007199254740992 * 2 * FUNCTION PI
*>               The plane across the line to the origin: a is horizontal (up x p, or x when p is vertical), b = p x a.
                 COMPUTE WS-A(1) = WS-P(3)
                 MOVE 0 TO WS-A(2)
                 COMPUTE WS-A(3) = 0 - WS-P(1)
                 COMPUTE WS-LEN = FUNCTION SQRT(WS-A(1) * WS-A(1) + WS-A(3) * WS-A(3))
                 IF WS-LEN < 0.000001
                     MOVE 1 TO WS-A(1)
                     MOVE 0 TO WS-A(3)
                     MOVE 1 TO WS-LEN
                 END-IF
                 COMPUTE WS-A(1) = WS-A(1) / WS-LEN
                 COMPUTE WS-A(3) = WS-A(3) / WS-LEN
                 COMPUTE WS-B(1) = WS-P(2) * WS-A(3) - WS-P(3) * WS-A(2)
                 COMPUTE WS-B(2) = WS-P(3) * WS-A(1) - WS-P(1) * WS-A(3)
                 COMPUTE WS-B(3) = WS-P(1) * WS-A(2) - WS-P(2) * WS-A(1)
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                     COMPUTE WS-EX(WS-K) = WS-A(WS-K) * FUNCTION COS(WS-ANGLE) + WS-B(WS-K) * FUNCTION SIN(WS-ANGLE)
                     COMPUTE WS-EY(WS-K) = WS-B(WS-K) * FUNCTION COS(WS-ANGLE) - WS-A(WS-K) * FUNCTION SIN(WS-ANGLE)
*>                   The corner (s, -s): p + s ex - s ey; the edges 2 s ey (to (s, s)) and -2 s ex (to (-s, s)) of the quad.
                     COMPUTE WS-Q(WS-K) = WS-P(WS-K) * 100 + WS-SIZE * (WS-EX(WS-K) - WS-EY(WS-K))
                     COMPUTE WS-Q(WS-K + 3) = 2 * WS-SIZE * WS-EY(WS-K)
                     COMPUTE WS-Q(WS-K + 6) = 0 - 2 * WS-SIZE * WS-EX(WS-K)
                 END-PERFORM
                 MOVE 1 TO WS-Q(10) WS-Q(11) WS-Q(12) WS-Q(13)
                 MOVE 0 TO WS-Q(14) WS-Q(15)
                 CALL "SKY-QUAD" USING SK-ST-ADDR SK-ST-COUNT WS-QUAD-TABLE
             END-IF
         END-PERFORM
     END-IF
     SET ADDRESS OF B-VERTEX TO SK-ST-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SK-ST-COUNT
         MOVE WS-U TO B-U(WS-I)
         MOVE WS-V TO B-VV(WS-I)
         MOVE WS-ALPHA TO B-A(WS-I)
     END-PERFORM
     MOVE L-LEVEL TO SK-ST-LEVEL
     MOVE UA-W TO SK-ST-UA-W
     MOVE UA-H TO SK-ST-UA-H
     GOBACK.
 END PROGRAM SKY-STARS-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-CLOUDS-LOAD.
*> USING CLIENT-STATE: SK-CI-CELLS, SK-CI-W, SK-CI-H from textures/environment/clouds.png of the top-most pack that has it (12 section 3.6: a cell is solid when the
*> pixel's alpha is 10 or more; at most 512 x 512 cells); with no such image (or one that is too large) the procedural image of 256 x 256 cells: 4 x 4 cell blocks,
*> each solid when a hash of its place is under 42 of 101 (the built-in recipe is an open question, faithful-pack-mapping 6.1). The mesh is made again.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(256) VALUE "assets/minecraft/textures/environment/clouds.png".
 01 WS-PATH-LENGTH         BINARY-LONG VALUE 48.
 01 WS-IMAGE               PIC X(1048576).
 01 WS-CAPACITY            BINARY-LONG VALUE 1048576.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-ALPHA               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-W WS-H WS-FOUND SK-CM-VALID
     CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMAGE WS-CAPACITY WS-W WS-H WS-FOUND
     IF WS-FOUND = 1 AND WS-W > 0 AND WS-H > 0 AND WS-W <= 512 AND WS-H <= 512
         MOVE WS-W TO SK-CI-W
         MOVE WS-H TO SK-CI-H
         MOVE SPACES TO SK-CI-CELLS
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-W * WS-H
             COMPUTE WS-POS = WS-I * 4 + 4
             COMPUTE WS-ALPHA = FUNCTION ORD(WS-IMAGE(WS-POS:1)) - 1
             COMPUTE WS-POS = WS-I + 1
             IF WS-ALPHA >= 10
                 MOVE "1" TO SK-CI-CELLS(WS-POS:1)
             ELSE
                 MOVE "0" TO SK-CI-CELLS(WS-POS:1)
             END-IF
         END-PERFORM
     ELSE
         MOVE 256 TO SK-CI-W SK-CI-H
         MOVE SPACES TO SK-CI-CELLS
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 255
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 255
                 COMPUTE WS-BX = WS-X / 4
                 COMPUTE WS-BY = WS-Y / 4
                 COMPUTE WS-HASH = WS-BX * 40503 + WS-BY * 9973 + FUNCTION MOD(WS-BX * WS-BY, 7) * 131
                 COMPUTE WS-POS = WS-Y * 256 + WS-X + 1
                 IF FUNCTION MOD(WS-HASH, 101) < 42
                     MOVE "1" TO SK-CI-CELLS(WS-POS:1)
                 ELSE
                     MOVE "0" TO SK-CI-CELLS(WS-POS:1)
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SKY-CLOUDS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-CLOUDS-MESH.
*> USING CLIENT-STATE, camera cell x, camera cell z, camera against the layer (1 below, 0 inside, -1 above), mode (1 fast, 2 fancy), radius in cells: SK-CM-ADDR,
*> SK-CM-COUNT: the mesh of the cells (dx, dz) with dx^2 + dz^2 <= radius^2 around the camera cell, the cell (dx, dz) being the image's cell ((x + dx) mod w,
*> (z + dz) mod h) (floor modulo), its box from (12 dx, 0, 12 dz) to (12 dx + 12, 4, 12 dz + 12) in the cell space whose origin is the corner of the camera's cell
*> (12 section 3.6). Fancy: UP unless the camera is below; DOWN unless it is above; NORTH (z side, towards -z) when the north neighbour cell is empty and dz > 0;
*> SOUTH when the south one is empty and dz < 0; WEST when the west one is empty and dx > 0; EAST when the east one is empty and dx < 0. Fast: the DOWN face of
*> every solid cell alone, at the top face's factor. Colours: the cloud colour times the face factor (bottom 0.7, top 1, north and south 0.8, west and east 0.9),
*> alpha the cloud alpha, faded out over the outer 30 % of the radius; the swatch of the UI atlas for the texture coordinates.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-FADE                FLOAT-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-FACTOR              FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-NORTH               BINARY-LONG.
 01 WS-SOUTH               BINARY-LONG.
 01 WS-WEST                BINARY-LONG.
 01 WS-EAST                BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-QUAD-TABLE.
    05 WS-Q                FLOAT-LONG OCCURS 15 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CELL-X               BINARY-LONG.
 01 L-CELL-Z               BINARY-LONG.
 01 L-REL                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CELL-X L-CELL-Z L-REL L-MODE L-RADIUS.
     IF SK-CM-ADDR = NULL
         COMPUTE WS-BYTES = SKY-CLOUD-VERTICES * 44
         ALLOCATE WS-BYTES CHARACTERS RETURNING SK-CM-ADDR
     END-IF
     MOVE 0 TO SK-CM-COUNT
     MOVE SK-CI-W TO WS-WIDTH
     MOVE SK-CI-H TO WS-HEIGHT
     COMPUTE WS-U = 4 / FUNCTION MAX(UA-W, 1)
     COMPUTE WS-V = (UA-H - 4) / FUNCTION MAX(UA-H, 1)
     MOVE WS-U TO WS-Q(14)
     MOVE WS-V TO WS-Q(15)
     COMPUTE WS-R2 = L-RADIUS * L-RADIUS
     COMPUTE WS-START = 0 - L-RADIUS
     PERFORM VARYING WS-DZ FROM WS-START BY 1 UNTIL WS-DZ > L-RADIUS
         PERFORM VARYING WS-DX FROM WS-START BY 1 UNTIL WS-DX > L-RADIUS
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
             IF WS-D2 <= WS-R2
                 COMPUTE WS-IX = FUNCTION MOD(L-CELL-X + WS-DX, WS-WIDTH)
                 COMPUTE WS-IZ = FUNCTION MOD(L-CELL-Z + WS-DZ, WS-HEIGHT)
                 COMPUTE WS-POS = WS-IZ * WS-WIDTH + WS-IX + 1
                 IF SK-CI-CELLS(WS-POS:1) = "1"
*>                   The neighbours (north is z - 1) of the image, wrapped.
                     COMPUTE WS-NZ = FUNCTION MOD(WS-IZ + WS-HEIGHT - 1, WS-HEIGHT) * WS-WIDTH + WS-IX + 1
                     MOVE 0 TO WS-NORTH
                     IF SK-CI-CELLS(WS-NZ:1) = "1"
                         MOVE 1 TO WS-NORTH
                     END-IF
                     COMPUTE WS-NZ = FUNCTION MOD(WS-IZ + 1, WS-HEIGHT) * WS-WIDTH + WS-IX + 1
                     MOVE 0 TO WS-SOUTH
                     IF SK-CI-CELLS(WS-NZ:1) = "1"
                         MOVE 1 TO WS-SOUTH
                     END-IF
                     COMPUTE WS-NX = WS-IZ * WS-WIDTH + FUNCTION MOD(WS-IX + WS-WIDTH - 1, WS-WIDTH) + 1
                     MOVE 0 TO WS-WEST
                     IF SK-CI-CELLS(WS-NX:1) = "1"
                         MOVE 1 TO WS-WEST
                     END-IF
                     COMPUTE WS-NX = WS-IZ * WS-WIDTH + FUNCTION MOD(WS-IX + 1, WS-WIDTH) + 1
                     MOVE 0 TO WS-EAST
                     IF SK-CI-CELLS(WS-NX:1) = "1"
                         MOVE 1 TO WS-EAST
                     END-IF
*>                   Alpha: the cloud colour's, faded over the outer 30 % of the radius.
                     COMPUTE WS-DIST = FUNCTION SQRT(WS-D2)
                     MOVE 1 TO WS-FADE
                     IF WS-DIST > 0.7 * L-RADIUS
                         COMPUTE WS-FADE = (L-RADIUS - WS-DIST) / (0.3 * L-RADIUS)
                     END-IF
                     COMPUTE WS-Q(13) = SK-CLOUD-COLOUR(4) * WS-FADE
                     COMPUTE WS-X0 = WS-DX * 12
                     COMPUTE WS-Z0 = WS-DZ * 12
                     PERFORM VARYING WS-FACE FROM 1 BY 1 UNTIL WS-FACE > 6
                         MOVE 0 TO WS-DRAW
                         MOVE 0 TO WS-Q(4) WS-Q(5) WS-Q(6) WS-Q(7) WS-Q(8) WS-Q(9)
                         MOVE WS-X0 TO WS-Q(1)
                         MOVE 0 TO WS-Q(2)
                         MOVE WS-Z0 TO WS-Q(3)
                         EVALUATE WS-FACE
*>                           Down: fancy unless the camera is above, fast always (then at the top factor).
                             WHEN 1
                                 MOVE 12 TO WS-Q(4)
                                 MOVE 12 TO WS-Q(9)
                                 MOVE 0.7 TO WS-FACTOR
                                 IF L-MODE = 1
                                     MOVE 1 TO WS-FACTOR
                                 END-IF
                                 IF L-MODE = 1 OR L-REL >= 0
                                     MOVE 1 TO WS-DRAW
                                 END-IF
*>                           Up: fancy unless the camera is below.
                             WHEN 2
                                 MOVE 4 TO WS-Q(2)
                                 MOVE 12 TO WS-Q(4)
                                 MOVE 12 TO WS-Q(9)
                                 MOVE 1 TO WS-FACTOR
                                 IF L-MODE = 2 AND L-REL <= 0
                                     MOVE 1 TO WS-DRAW
                                 END-IF
*>                           North (z side towards -z), south.
                             WHEN 3
                                 MOVE 12 TO WS-Q(4)
                                 MOVE 4 TO WS-Q(8)
                                 MOVE 0.8 TO WS-FACTOR
                                 IF L-MODE = 2 AND WS-NORTH = 0 AND WS-DZ > 0
                                     MOVE 1 TO WS-DRAW
                                 END-IF
                             WHEN 4
                                 COMPUTE WS-Q(3) = WS-Z0 + 12
                                 MOVE 12 TO WS-Q(4)
                                 MOVE 4 TO WS-Q(8)
                                 MOVE 0.8 TO WS-FACTOR
                                 IF L-MODE = 2 AND WS-SOUTH = 0 AND WS-DZ < 0
                                     MOVE 1 TO WS-DRAW
                                 END-IF
*>                           West (x side towards -x), east.
                             WHEN 5
                                 MOVE 12 TO WS-Q(6)
                                 MOVE 4 TO WS-Q(8)
                                 MOVE 0.9 TO WS-FACTOR
                                 IF L-MODE = 2 AND WS-WEST = 0 AND WS-DX > 0
                                     MOVE 1 TO WS-DRAW
                                 END-IF
                             WHEN OTHER
                                 COMPUTE WS-Q(1) = WS-X0 + 12
                                 MOVE 12 TO WS-Q(6)
                                 MOVE 4 TO WS-Q(8)
                                 MOVE 0.9 TO WS-FACTOR
                                 IF L-MODE = 2 AND WS-EAST = 0 AND WS-DX < 0
                                     MOVE 1 TO WS-DRAW
                                 END-IF
                         END-EVALUATE
                         IF WS-DRAW = 1
                             COMPUTE WS-Q(10) = SK-CLOUD-COLOUR(1) * WS-FACTOR
                             COMPUTE WS-Q(11) = SK-CLOUD-COLOUR(2) * WS-FACTOR
                             COMPUTE WS-Q(12) = SK-CLOUD-COLOUR(3) * WS-FACTOR
                             CALL "SKY-QUAD" USING SK-CM-ADDR SK-CM-COUNT WS-QUAD-TABLE
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-CLOUDS-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-RESET.
*> USING CLIENT-STATE: what the sky made from the packs is made again (the cloud image and mesh, the stars' texture coordinates): called when the stack reloads.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO SK-CI-W SK-CM-VALID SK-ST-LEVEL
     GOBACK.
 END PROGRAM SKY-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-RENDER-BEHIND.
*> USING CLIENT-STATE, projection x view (16 FLOAT-LONG): appends the sun, the moon and, with a brightness of a 64th or more, the stars to the render list (uploads
*> of their meshes, then their draws on the UI pipeline) when the dimension has sky light and no sky box of its own (DX-SKYBOX 0) and the eye is in no fluid;
*> RENDER-LIST-BUILD calls it before any terrain draw.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-BODY                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-OUT-TABLE.
    05 WS-OUT              FLOAT-LONG OCCURS 16 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PV-TABLE.
    05 L-PV                FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-PV-TABLE.
     IF PL-HAS-SKY = 0 OR DX-SKYBOX NOT = 0 OR PL-EYE-WATER = 1 OR PL-EYE-LAVA = 1
         GOBACK
     END-IF
     IF RL-DRAW-COUNT + 3 > CL-MAX-DRAWS - CL-DRAW-RESERVE OR RL-UPLOAD-COUNT + 3 > CL-MAX-UPLOADS - CL-UPLOAD-RESERVE
         GOBACK
     END-IF
     CALL "SKY-ANGLES" USING CLIENT-STATE
     CALL "SKY-BODIES-MESH" USING CLIENT-STATE
*>   The stars' brightness in 64ths; the mesh is made again (alpha and swatch) when it or the UI atlas changed.
     COMPUTE WS-LEVEL = FUNCTION INTEGER(SK-STAR-BRIGHT * 64 + 0.5)
     IF WS-LEVEL > 0 AND (WS-LEVEL NOT = SK-ST-LEVEL OR UA-W NOT = SK-ST-UA-W OR UA-H NOT = SK-ST-UA-H OR SK-ST-ADDR = NULL)
         CALL "SKY-STARS-MESH" USING CLIENT-STATE WS-LEVEL
         MOVE 1 TO SK-ST-UPLOAD
     END-IF
     PERFORM VARYING WS-BODY FROM 1 BY 1 UNTIL WS-BODY > 3
         IF WS-BODY < 3 OR WS-LEVEL > 0
             ADD 1 TO RL-DRAW-COUNT
             EVALUATE WS-BODY
                 WHEN 1
                     MOVE MESH-SLOT-SUN TO RL-D-SLOT(RL-DRAW-COUNT)
                     MOVE SK-SUN-TEX TO RL-D-TEX(RL-DRAW-COUNT)
                     MOVE SK-SUN-ANGLE TO WS-ANGLE
                     ADD 1 TO RL-UPLOAD-COUNT
                     MOVE MESH-SLOT-SUN TO RL-U-SLOT(RL-UPLOAD-COUNT)
                     SET RL-U-ADDR(RL-UPLOAD-COUNT) TO ADDRESS OF SK-BV(1)
                     MOVE 6 TO RL-U-COUNT(RL-UPLOAD-COUNT)
                 WHEN 2
                     MOVE MESH-SLOT-MOON TO RL-D-SLOT(RL-DRAW-COUNT)
                     MOVE SK-MOON-TEX TO RL-D-TEX(RL-DRAW-COUNT)
                     MOVE SK-MOON-ANGLE TO WS-ANGLE
                     ADD 1 TO RL-UPLOAD-COUNT
                     MOVE MESH-SLOT-MOON TO RL-U-SLOT(RL-UPLOAD-COUNT)
                     SET RL-U-ADDR(RL-UPLOAD-COUNT) TO ADDRESS OF SK-BV(7)
                     MOVE 6 TO RL-U-COUNT(RL-UPLOAD-COUNT)
                 WHEN OTHER
                     MOVE MESH-SLOT-STARS TO RL-D-SLOT(RL-DRAW-COUNT)
                     MOVE CC-TEX-UI TO RL-D-TEX(RL-DRAW-COUNT)
                     MOVE SK-STAR-ANGLE TO WS-ANGLE
                     IF SK-ST-UPLOAD = 1
                         ADD 1 TO RL-UPLOAD-COUNT
                         MOVE MESH-SLOT-STARS TO RL-U-SLOT(RL-UPLOAD-COUNT)
                         SET RL-U-ADDR(RL-UPLOAD-COUNT) TO SK-ST-ADDR
                         MOVE SK-ST-COUNT TO RL-U-COUNT(RL-UPLOAD-COUNT)
                         MOVE 0 TO SK-ST-UPLOAD
                     END-IF
             END-EVALUATE
             MOVE CC-PIPE-UI TO RL-D-PIPELINE(RL-DRAW-COUNT)
             CALL "SKY-MATRIX" USING L-PV-TABLE WS-ANGLE WS-OUT-TABLE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
                 MOVE WS-OUT(WS-I) TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-RENDER-BEHIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-RENDER-CLOUDS.
*> USING CLIENT-STATE, projection x view (16 FLOAT-LONG), eye (3 FLOAT-LONG): the clouds (see the head of this file) when the dimension has sky light and no sky box and the eye
*> is in no fluid: loads the image when it is not loaded, makes the mesh again when the camera's cloud cell, the side of the layer, the mode or the
*> radius changed, and appends the upload (once per mesh), the fog record of the cloud range, the draw and the record that puts the frame's fog back.
*> The options are renderClouds ("false" off, "fast", else fancy) and cloudRange (radius ceil(range x 16 / 12) cells, at most SKY-CLOUD-RADIUS-MAX).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-CELL-X              BINARY-LONG.
 01 WS-CELL-Z              BINARY-LONG.
 01 WS-REL                 BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-OFF                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BLOCKS              FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PV-TABLE.
    05 L-PV                FLOAT-LONG OCCURS 16 TIMES.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-PV-TABLE L-EYE-TABLE.
     IF PL-HAS-SKY = 0 OR DX-SKYBOX NOT = 0 OR PL-EYE-WATER = 1 OR PL-EYE-LAVA = 1
         GOBACK
     END-IF
     IF RL-DRAW-COUNT + 3 > CL-MAX-DRAWS - CL-DRAW-RESERVE OR RL-UPLOAD-COUNT + 1 > CL-MAX-UPLOADS - CL-UPLOAD-RESERVE
         GOBACK
     END-IF
     MOVE "renderClouds" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-FOUND
     MOVE 2 TO WS-MODE
     EVALUATE TRUE
         WHEN WS-VALUE = '"false"' OR WS-VALUE = "false"
             GOBACK
         WHEN WS-VALUE = '"fast"'
             MOVE 1 TO WS-MODE
     END-EVALUATE
     MOVE "cloudRange" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-FOUND
     MOVE 128 TO WS-RANGE
     IF WS-FOUND = 1 AND WS-LENGTH > 0
         COMPUTE WS-RANGE = FUNCTION NUMVAL(WS-VALUE(1:WS-LENGTH))
     END-IF
     COMPUTE WS-RADIUS = (WS-RANGE * 16 + 11) / 12
     IF WS-RADIUS > SKY-CLOUD-RADIUS-MAX
         MOVE SKY-CLOUD-RADIUS-MAX TO WS-RADIUS
     END-IF
     CALL "SKY-ANGLES" USING CLIENT-STATE
     IF SK-CI-W = 0
         CALL "SKY-CLOUDS-LOAD" USING CLIENT-STATE
     END-IF
*>   The camera in cloud space: the game time scrolls the layer by 0.03 blocks a tick, 3.96 blocks in z (12 section 3.6); a cell is 12 blocks.
     COMPUTE WS-T = FUNCTION MOD(PL-GAME-TIME, 102400)
     COMPUTE WS-CX = L-EYE(1) + WS-T * 0.03
     COMPUTE WS-CZ = L-EYE(3) + 3.96
     COMPUTE WS-CELL-X = FUNCTION INTEGER(WS-CX / 12)
     COMPUTE WS-CELL-Z = FUNCTION INTEGER(WS-CZ / 12)
     COMPUTE WS-D = SK-CLOUD-HEIGHT - L-EYE(2)
     EVALUATE TRUE
         WHEN WS-D > 0
             MOVE 1 TO WS-REL
         WHEN WS-D + 4 < 0
             MOVE -1 TO WS-REL
         WHEN OTHER
             MOVE 0 TO WS-REL
     END-EVALUATE
     IF SK-CM-VALID = 0 OR SK-CM-X NOT = WS-CELL-X OR SK-CM-Z NOT = WS-CELL-Z OR SK-CM-REL NOT = WS-REL
             OR SK-CM-MODE NOT = WS-MODE OR SK-CM-RADIUS NOT = WS-RADIUS
         CALL "SKY-CLOUDS-MESH" USING CLIENT-STATE WS-CELL-X WS-CELL-Z WS-REL WS-MODE WS-RADIUS
         MOVE 1 TO SK-CM-VALID SK-CM-UPLOAD
         MOVE WS-CELL-X TO SK-CM-X
         MOVE WS-CELL-Z TO SK-CM-Z
         MOVE WS-REL TO SK-CM-REL
         MOVE WS-MODE TO SK-CM-MODE
         MOVE WS-RADIUS TO SK-CM-RADIUS
     END-IF
     IF SK-CM-UPLOAD = 1
         ADD 1 TO RL-UPLOAD-COUNT
         MOVE MESH-SLOT-CLOUDS TO RL-U-SLOT(RL-UPLOAD-COUNT)
         SET RL-U-ADDR(RL-UPLOAD-COUNT) TO SK-CM-ADDR
         MOVE SK-CM-COUNT TO RL-U-COUNT(RL-UPLOAD-COUNT)
         MOVE 0 TO SK-CM-UPLOAD
     END-IF
     IF SK-CM-COUNT > 0
*>       The fog of the cloud range: the clear colour, strength 1, from half the meshed radius to all of it, no render-distance fog.
         COMPUTE WS-BLOCKS = WS-RADIUS * 12
         ADD 1 TO RL-DRAW-COUNT
         MOVE -2 TO RL-D-SLOT(RL-DRAW-COUNT)
         MOVE 0 TO RL-D-PIPELINE(RL-DRAW-COUNT) RL-D-TEX(RL-DRAW-COUNT)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE 0 TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
         END-PERFORM
         MOVE RL-CLEAR(1) TO RL-D-MATRIX(RL-DRAW-COUNT, 1)
         MOVE RL-CLEAR(2) TO RL-D-MATRIX(RL-DRAW-COUNT, 2)
         MOVE RL-CLEAR(3) TO RL-D-MATRIX(RL-DRAW-COUNT, 3)
         MOVE 1 TO RL-D-MATRIX(RL-DRAW-COUNT, 4)
         COMPUTE RL-D-MATRIX(RL-DRAW-COUNT, 5) = WS-BLOCKS / 2
         MOVE WS-BLOCKS TO RL-D-MATRIX(RL-DRAW-COUNT, 6)
         PERFORM VARYING WS-I FROM 7 BY 1 UNTIL WS-I > 11
             MOVE RL-FOG(WS-I) TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
         END-PERFORM
         MOVE 1000000000 TO RL-D-MATRIX(RL-DRAW-COUNT, 12)
         MOVE 2000000000 TO RL-D-MATRIX(RL-DRAW-COUNT, 13)
*>       The draw: the matrix is the projection x view x the translation by the layer's origin from the eye: minus the camera's place in its cell, the layer's bottom.
         COMPUTE WS-OFF(1) = WS-CELL-X * 12 - WS-CX
         COMPUTE WS-OFF(2) = SK-CLOUD-HEIGHT - L-EYE(2)
         COMPUTE WS-OFF(3) = WS-CELL-Z * 12 - WS-CZ
         ADD 1 TO RL-DRAW-COUNT
         MOVE MESH-SLOT-CLOUDS TO RL-D-SLOT(RL-DRAW-COUNT)
         MOVE CC-PIPE-TRANSLUCENT TO RL-D-PIPELINE(RL-DRAW-COUNT)
         MOVE CC-TEX-UI TO RL-D-TEX(RL-DRAW-COUNT)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
             MOVE L-PV(WS-I) TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
         END-PERFORM
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
             COMPUTE RL-D-MATRIX(RL-DRAW-COUNT, 12 + WS-R) = L-PV(WS-R) * WS-OFF(1) + L-PV(4 + WS-R) * WS-OFF(2)
                 + L-PV(8 + WS-R) * WS-OFF(3) + L-PV(12 + WS-R)
         END-PERFORM
*>       Back to the frame's fog.
         ADD 1 TO RL-DRAW-COUNT
         MOVE -2 TO RL-D-SLOT(RL-DRAW-COUNT)
         MOVE 0 TO RL-D-PIPELINE(RL-DRAW-COUNT) RL-D-TEX(RL-DRAW-COUNT)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE 0 TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
             MOVE RL-FOG(WS-I) TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SKY-RENDER-CLOUDS.
