*> Acceptance test of US3-6 on the client (standin-content §4.8 day length, daylight factor and sky
*> colour; 09 §3.2 Set Time; client/src/sky.cob): Set Time packets over a whole 24000-tick day
*> make the clear colour go from the day sky #8FB8E6 through dusk to the night sky #0E1222 and back,
*> with the daylight factor u following the sky_color track of the overworld timeline (12 §3.2: 1 from 133 to 11867, linear to 0 at 13670, 0 to 22330, linear to 1 at 24133) as u = 200 + 800 f (expected values computed here from the formulas).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US3-SKY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-ID                  BINARY-LONG VALUE 115.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-T                   BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PARTIAL             FLOAT-SHORT VALUE 0.
 01 WS-RATE                FLOAT-SHORT VALUE 1.0.
 01 WS-DAY.
    05 WS-D                BINARY-LONG OCCURS 3 TIMES.
 01 WS-NIGHT.
    05 WS-N                BINARY-LONG OCCURS 3 TIMES.
 01 WS-EU                  PIC 9(4).
 01 WS-ET                  PIC 9(5).
 01 WS-BYTE                PIC X.
 01 WS-EXPECTED            PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-HEX                 PIC X(6).
 PROCEDURE DIVISION.
     MOVE 143 TO WS-D(1)
     MOVE 184 TO WS-D(2)
     MOVE 230 TO WS-D(3)
     MOVE 14 TO WS-N(1)
     MOVE 18 TO WS-N(2)
     MOVE 34 TO WS-N(3)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE 1 TO PL-HAS-SKY
     MOVE SPACES TO WS-EXPECTED WS-OBSERVED
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 13
*>       Every 2000 ticks, plus points inside dusk (12700) and dawn (23200).
         EVALUATE WS-K
             WHEN 12
                 MOVE 12700 TO WS-T
             WHEN 13
                 MOVE 23200 TO WS-T
             WHEN OTHER
                 COMPUTE WS-T = WS-K * 2000 + 1000
         END-EVALUATE
*>       Set Time: the game time, one clock update (world_clock 0, total ticks a whole day later).
         CALL "PB-RESET" USING PB-BUFFER
         MOVE WS-T TO WS-TIME
         CALL "PB-PUT-LONG" USING PB-BUFFER WS-TIME
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         COMPUTE WS-TIME = WS-T + 24000
         CALL "PB-PUT-VARLONG" USING PB-BUFFER WS-TIME
         CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PARTIAL
         CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-RATE
         MOVE 0 TO PB-POS
         CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
         CALL "SKY-UPDATE" USING CLIENT-STATE
*>       Expected: the factor f of the sky_color track in ticks over 1803, u = 200 + trunc(800 f).
         EVALUATE TRUE
             WHEN WS-T < 133
                 COMPUTE WS-U = 200 + FUNCTION INTEGER-PART(800 * (WS-T + 1670) / 1803)
             WHEN WS-T <= 11867
                 MOVE 1000 TO WS-U
             WHEN WS-T < 13670
                 COMPUTE WS-U = 200 + FUNCTION INTEGER-PART(800 * (13670 - WS-T) / 1803)
             WHEN WS-T <= 22330
                 MOVE 200 TO WS-U
             WHEN OTHER
                 COMPUTE WS-U = 200 + FUNCTION INTEGER-PART(800 * (WS-T - 22330) / 1803)
         END-EVALUATE
         MOVE WS-T TO WS-ET
         MOVE WS-U TO WS-EU
         MOVE SPACES TO WS-HEX
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             COMPUTE WS-C = WS-N(WS-I)
                 + FUNCTION INTEGER-PART((WS-D(WS-I) - WS-N(WS-I)) * (WS-U - 200) / 800)
             MOVE FUNCTION CHAR(WS-C + 1) TO WS-BYTE
             MOVE FUNCTION HEX-OF(WS-BYTE) TO WS-HEX(WS-I * 2 - 1:2)
         END-PERFORM
         STRING FUNCTION TRIM(WS-EXPECTED) " " WS-ET ":" WS-EU ":" WS-HEX DELIMITED BY SIZE
             INTO WS-EXPECTED
         MOVE PL-TIME TO WS-ET
         MOVE SK-U TO WS-EU
         MOVE SPACES TO WS-HEX
         COMPUTE WS-C ROUNDED = SK-R * 255
         MOVE FUNCTION CHAR(WS-C + 1) TO WS-BYTE
         MOVE FUNCTION HEX-OF(WS-BYTE) TO WS-HEX(1:2)
         COMPUTE WS-C ROUNDED = SK-G * 255
         MOVE FUNCTION CHAR(WS-C + 1) TO WS-BYTE
         MOVE FUNCTION HEX-OF(WS-BYTE) TO WS-HEX(3:2)
         COMPUTE WS-C ROUNDED = SK-B * 255
         MOVE FUNCTION CHAR(WS-C + 1) TO WS-BYTE
         MOVE FUNCTION HEX-OF(WS-BYTE) TO WS-HEX(5:2)
         STRING FUNCTION TRIM(WS-OBSERVED) " " WS-ET ":" WS-EU ":" WS-HEX DELIMITED BY SIZE
             INTO WS-OBSERVED
     END-PERFORM
     MOVE "acceptance US3-6 given Set Time over a full 24000-tick day then the sky goes from day "
         & "(#8FB8E6) through dusk to night (#0E1222) and back through dawn, and the daylight factor "
         & "follows the sky_color track of 12 §3.2" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE WS-OBSERVED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US3-SKY.
 COPY CLTEST.
