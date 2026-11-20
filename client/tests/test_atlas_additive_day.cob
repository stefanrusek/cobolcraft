*> Lane bugsunchest (T62201): ATLAS-ADDITIVE-DAY bakes the pixels of the sun sprite for the shim's alpha blend (12 section 3.4c: vanilla adds the sprite to the day sky, and the
*> sum saturates, so the gold rim and the pale centre are white over the sky colour #78a7ff and the halo only lightens it). Every pixel becomes white; its alpha is the mean of
*> the red share r x 255 / 135 and the green share g x 255 / 88 (each at most 255), times the pixel's own alpha / 255, rounded down at the end.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ATLAS-ADDITIVE-DAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-COUNT               BINARY-LONG VALUE 7.
 01 WS-IMAGE               PIC X(28).
*> The seven pixels as decimal bytes: 0 0 0 255; 255 255 217 255; 14 14 5 255; 255 213 74 255; 255 255 255 128; 255 0 0 255; 255 255 255 0.
 01 WS-BYTES               PIC X(84) VALUE "000000000255255255217255014014005255255213074255255255255128255000000255255255255000".
 01 WS-WANT-DATA           PIC X(56) VALUE "FFFFFF00FFFFFFFFFFFFFF22FFFFFFFFFFFFFF80FFFFFF80FFFFFF00".
 01 WS-WANT REDEFINES WS-WANT-DATA.
    05 WS-WANT-PIXEL       PIC X(8) OCCURS 7 TIMES.
 01 WS-HEX                 PIC X(8).
 01 WS-DIGITS              PIC X(16) VALUE "0123456789ABCDEF".
 01 WS-K                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-EDIT                PIC 9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 28
         MOVE FUNCTION CHAR(FUNCTION NUMVAL(WS-BYTES(WS-K * 3 - 2:3)) + 1) TO WS-IMAGE(WS-K:1)
     END-PERFORM
     CALL "ATLAS-ADDITIVE-DAY" USING WS-IMAGE WS-COUNT
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 7
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             COMPUTE WS-B = FUNCTION ORD(WS-IMAGE((WS-P - 1) * 4 + WS-K:1)) - 1
             COMPUTE WS-HI = WS-B / 16
             COMPUTE WS-LO = WS-B - WS-HI * 16
             MOVE WS-DIGITS(WS-HI + 1:1) TO WS-HEX(WS-K * 2 - 1:1)
             MOVE WS-DIGITS(WS-LO + 1:1) TO WS-HEX(WS-K * 2:1)
         END-PERFORM
         MOVE WS-P TO WS-EDIT
         MOVE SPACES TO TL-CASE
         STRING "T62201 day additive: pixel " WS-EDIT " (black, centre, halo, rim, half alpha, red, clear white) is white with its share of the way to white as alpha"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-WANT-PIXEL(WS-P) TO TL-EXPECTED
         MOVE WS-HEX TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-ATLAS-ADDITIVE-DAY.
