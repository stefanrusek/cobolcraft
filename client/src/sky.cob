*> Sky colour and daylight factor (standin-content §4.8, §15.3): SKY-UPDATE derives the daylight u
*> (thousandths) from the time of day: 1000 by day, falling by 4/5 per tick from 15000 to 200 at
*> 16000, 200 by night, rising again from 29000; and the clear colour, each channel
*> N + trunc((D - N) (u - 200) / 800) between night #0E1222 and day #8FB8E6. A dimension without sky
*> light has the fixed sky #100C12 (its faces have no sky light to scale).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-UPDATE.
*> USING CLIENT-STATE: sets SK-U and SK-R, SK-G, SK-B (0 to 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   BINARY-LONG.
 01 WS-DAY                 BINARY-LONG OCCURS 3 TIMES.
 01 WS-NIGHT               BINARY-LONG OCCURS 3 TIMES.
 01 WS-C                   BINARY-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
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
     EVALUATE TRUE
         WHEN WS-T < 15000
             MOVE 1000 TO SK-U
         WHEN WS-T < 16000
             COMPUTE WS-STEP = (WS-T - 15000) * 4
             DIVIDE WS-STEP BY 5 GIVING WS-STEP
             COMPUTE SK-U = 1000 - WS-STEP
         WHEN WS-T < 29000
             MOVE 200 TO SK-U
         WHEN OTHER
             COMPUTE WS-STEP = (WS-T - 29000) * 4
             DIVIDE WS-STEP BY 5 GIVING WS-STEP
             COMPUTE SK-U = 200 + WS-STEP
     END-EVALUATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-C(WS-I) = WS-NIGHT(WS-I)
             + FUNCTION INTEGER-PART((WS-DAY(WS-I) - WS-NIGHT(WS-I)) * (SK-U - 200) / 800)
     END-PERFORM
     IF PL-HAS-SKY = 0
         MOVE 16 TO WS-C(1)
         MOVE 12 TO WS-C(2)
         MOVE 18 TO WS-C(3)
     END-IF
     COMPUTE SK-R = WS-C(1) / 255
     COMPUTE SK-G = WS-C(2) / 255
     COMPUTE SK-B = WS-C(3) / 255
     GOBACK.
 END PROGRAM SKY-UPDATE.
