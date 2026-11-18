*> Sky colour and daylight factor (standin-content §4.8, §15.3): SKY-UPDATE derives the daylight u
*> (thousandths) from the time of day of the 24000-tick day (12 section 3.2): 1000 by day, falling linearly
*> from tick 11867 to 200 at 13670, 200 by night, rising again from 22330 to 1000 at 24133; and the clear colour, each channel
*> N + trunc((D - N) (u - 200) / 800) between night #0E1222 and day #8FB8E6. A dimension without sky
*> light has the fixed sky #100C12 (its faces have no sky light to scale) and no weather. Weather
*> (§14.5), with sky light only: the colour is tinted, each channel (c x 60 + t x 40) div 100 with
*> t from #7A7F88 in drizzle, (c x 45 + t x 55) div 100 with t from #5A5E68 in a hailstorm, and
*> then u becomes (u x 85) div 100 or (u x 70) div 100.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-HORIZON-HEIGHT.
*> USING CLIENT-STATE, height out (BINARY-LONG): the horizon height of the level (12 section 3.4d, 56 5.3): the
*> dimension's minY on a superflat world (the Is flat flag of the spawn info, PL-FLAT), else 63.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-HEIGHT.
     MOVE 63 TO L-HEIGHT
     IF PL-FLAT = 1
         MOVE PL-MIN-Y TO L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM SKY-HORIZON-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-VOID-ONSET.
*> USING CLIENT-STATE, onset out (BINARY-LONG): the void darkness onset range (12 section 3.3 item 2, 56 5.3): 1 on a
*> superflat world, else 32.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ONSET                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ONSET.
     MOVE 32 TO L-ONSET
     IF PL-FLAT = 1
         MOVE 1 TO L-ONSET
     END-IF
     GOBACK.
 END PROGRAM SKY-VOID-ONSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-VOID-DARKNESS.
*> USING CLIENT-STATE, camera y (FLOAT-LONG), v out (BINARY-LONG, thousandths): v = clamp((onset + minY - cameraY) /
*> onset, 0, 1) of 12 section 3.3 item 2 with the onset of SKY-VOID-ONSET and the dimension's minY (PL-MIN-Y).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONSET               BINARY-LONG.
 01 WS-RAW                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CAMERA-Y             FLOAT-LONG.
 01 L-V                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CAMERA-Y L-V.
     CALL "SKY-VOID-ONSET" USING CLIENT-STATE WS-ONSET
     COMPUTE WS-RAW = (WS-ONSET + PL-MIN-Y - L-CAMERA-Y) / WS-ONSET
     EVALUATE TRUE
         WHEN WS-RAW <= 0
             MOVE 0 TO L-V
         WHEN WS-RAW >= 1
             MOVE 1000 TO L-V
         WHEN OTHER
             COMPUTE L-V = FUNCTION INTEGER-PART(WS-RAW * 1000)
     END-EVALUATE
     GOBACK.
 END PROGRAM SKY-VOID-DARKNESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-DARK-DISC.
*> USING CLIENT-STATE, eye y (FLOAT-LONG), shown out (PIC 9): 1 when the dark disc of the void horizon is drawn (12
*> section 3.4d): the eye is below the horizon height (SKY-HORIZON-HEIGHT) and the camera is not under water.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HORIZON             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-Y                FLOAT-LONG.
 01 L-SHOWN                PIC 9.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-Y L-SHOWN.
     CALL "SKY-HORIZON-HEIGHT" USING CLIENT-STATE WS-HORIZON
     MOVE 0 TO L-SHOWN
     IF L-EYE-Y - WS-HORIZON < 0 AND PL-EYE-WATER = 0
         MOVE 1 TO L-SHOWN
     END-IF
     GOBACK.
 END PROGRAM SKY-DARK-DISC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-UPDATE.
*> USING CLIENT-STATE: sets SK-U and SK-R, SK-G, SK-B (0 to 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-T                   BINARY-LONG.
 01 WS-DAY                 BINARY-LONG OCCURS 3 TIMES.
 01 WS-NIGHT               BINARY-LONG OCCURS 3 TIMES.
 01 WS-C                   BINARY-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-TINT                BINARY-LONG OCCURS 3 TIMES.
 01 WS-KEEP                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CAMERA              FLOAT-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-FACTOR              FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 143 TO WS-DAY(1)
     MOVE 184 TO WS-DAY(2)
     MOVE 230 TO WS-DAY(3)
     MOVE 14 TO WS-NIGHT(1)
     MOVE 18 TO WS-NIGHT(2)
     MOVE 34 TO WS-NIGHT(3)
     MOVE PL-TIME TO WS-T
*>   The sky_color track of the overworld timeline (12 section 3.2, 24000-tick day): factor 1 from tick 133 to 11867, linear to 0 at 13670, 0
*>   to 22330, linear back to 1 at 24133 (the wrap); u = 200 + trunc(800 f).
     EVALUATE TRUE
         WHEN WS-T < 133
             COMPUTE WS-STEP = (WS-T + 1670) * 800
             DIVIDE WS-STEP BY 1803 GIVING WS-STEP
             COMPUTE SK-U = 200 + WS-STEP
         WHEN WS-T <= 11867
             MOVE 1000 TO SK-U
         WHEN WS-T < 13670
             COMPUTE WS-STEP = (13670 - WS-T) * 800
             DIVIDE WS-STEP BY 1803 GIVING WS-STEP
             COMPUTE SK-U = 200 + WS-STEP
         WHEN WS-T <= 22330
             MOVE 200 TO SK-U
         WHEN OTHER
             COMPUTE WS-STEP = (WS-T - 22330) * 800
             DIVIDE WS-STEP BY 1803 GIVING WS-STEP
             COMPUTE SK-U = 200 + WS-STEP
     END-EVALUATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-C(WS-I) = WS-NIGHT(WS-I)
             + FUNCTION INTEGER-PART((WS-DAY(WS-I) - WS-NIGHT(WS-I)) * (SK-U - 200) / 800)
     END-PERFORM
     IF PL-HAS-SKY = 1 AND PL-WEATHER NOT = WX-CLEAR
         MOVE 122 TO WS-TINT(1)
         MOVE 127 TO WS-TINT(2)
         MOVE 136 TO WS-TINT(3)
         MOVE 60 TO WS-KEEP
         MOVE 85 TO WS-DIM
         IF PL-WEATHER = WX-HAILSTORM
             MOVE 90 TO WS-TINT(1)
             MOVE 94 TO WS-TINT(2)
             MOVE 104 TO WS-TINT(3)
             MOVE 45 TO WS-KEEP
             MOVE 70 TO WS-DIM
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             COMPUTE WS-STEP = WS-C(WS-I) * WS-KEEP + WS-TINT(WS-I) * (100 - WS-KEEP)
             DIVIDE WS-STEP BY 100 GIVING WS-C(WS-I)
         END-PERFORM
         COMPUTE WS-STEP = SK-U * WS-DIM
         DIVIDE WS-STEP BY 100 GIVING SK-U
     END-IF
     IF PL-HAS-SKY = 0
         MOVE 16 TO WS-C(1)
         MOVE 12 TO WS-C(2)
         MOVE 18 TO WS-C(3)
     END-IF
     COMPUTE SK-R = WS-C(1) / 255
     COMPUTE SK-G = WS-C(2) / 255
     COMPUTE SK-B = WS-C(3) / 255
*>   The void darkness of a superflat world (12 section 3.3 item 2, 56 5.3): the colour times (1 - v) squared, v from the
*>   camera height (the eye height of the pose, 1.62 when none is set). Other worlds keep their colour.
     IF PL-FLAT = 1
         COMPUTE WS-CAMERA = PL-Y + 1.62
         IF PL-EYE > 0
             COMPUTE WS-CAMERA = PL-Y + PL-EYE
         END-IF
         CALL "SKY-VOID-DARKNESS" USING CLIENT-STATE WS-CAMERA WS-DARK
         COMPUTE WS-FACTOR = (1000 - WS-DARK) / 1000
         COMPUTE WS-FACTOR = WS-FACTOR * WS-FACTOR
         COMPUTE SK-R = SK-R * WS-FACTOR
         COMPUTE SK-G = SK-G * WS-FACTOR
         COMPUTE SK-B = SK-B * WS-FACTOR
     END-IF
     GOBACK.
 END PROGRAM SKY-UPDATE.
