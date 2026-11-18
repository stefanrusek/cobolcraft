*> T32200 (lane 002-lane-bugcelestial): ATLAS-ADDITIVE turns the RGBA pixels of a celestial sprite (the sun, the moon phases, the end flash) into
*> straight-alpha pixels that alpha-blend like vanilla's additive OVERLAY blend (12 section 3.4c: source SRC_ALPHA, destination ONE, so black adds
*> nothing). The shim has no additive pipeline, so the sky draws the sprites with SRC_ALPHA / ONE_MINUS_SRC_ALPHA and the sprite's opaque black
*> background showed as a black square (operator, try14 play). Each pixel becomes colour = rgb x 255 / max(r, g, b) (rounded) and alpha = max(r, g, b) x
*> alpha / 255 (rounded): the blend then adds the pixel's rgb x alpha and keeps the sky under it by 1 - that brightness. A black or clear pixel
*> gets alpha 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ATLAS-ADDITIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-COUNT               BINARY-LONG VALUE 7.
 01 WS-IMAGE               PIC X(28).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-HEX                 PIC X(8).
 01 WS-K                   BINARY-LONG.
*> The seven pixels as decimal bytes (3 digits each): 0 0 0 255; 255 255 217 255; 14 14 5 255; 255 255 255 128; 0 0 0 0; 200 100 0 255; 255 255 255 0.
 01 WS-BYTES               PIC X(84) VALUE "000000000255255255217255014014005255255255255128000000000000200100000255255255255000".
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
*>   0 opaque black, 1 the sun's centre (255 255 217 alpha 255), 2 a dark glow pixel (14 14 5), 3 half-clear white, 4 clear black,
*>   5 colour (200 100 0 alpha 255), 6 a pixel of alpha 0 whose rgb is bright.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 28
         MOVE FUNCTION CHAR(FUNCTION NUMVAL(WS-BYTES(WS-K * 3 - 2:3)) + 1) TO WS-IMAGE(WS-K:1)
     END-PERFORM
     CALL "ATLAS-ADDITIVE" USING WS-IMAGE WS-COUNT
     MOVE "T32200 additive: an opaque black pixel becomes clear (alpha 0), black" TO TL-CASE
     MOVE "00000000" TO TL-EXPECTED
     CALL "TEST-HEX-OF-IMAGE" USING WS-IMAGE WS-ONE WS-HEX
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T32200 additive: the sun's centre pixel keeps its colour and stays opaque" TO TL-CASE
     MOVE "FFFFD9FF" TO TL-EXPECTED
     MOVE 2 TO WS-ONE
     CALL "TEST-HEX-OF-IMAGE" USING WS-IMAGE WS-ONE WS-HEX
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T32200 additive: a dark glow pixel gets the full-brightness hue and its brightness as alpha" TO TL-CASE
     MOVE "FFFF5B0E" TO TL-EXPECTED
     MOVE 3 TO WS-ONE
     CALL "TEST-HEX-OF-IMAGE" USING WS-IMAGE WS-ONE WS-HEX
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T32200 additive: the pixel's own alpha scales the brightness (white at alpha 128)" TO TL-CASE
     MOVE "FFFFFF80" TO TL-EXPECTED
     MOVE 4 TO WS-ONE
     CALL "TEST-HEX-OF-IMAGE" USING WS-IMAGE WS-ONE WS-HEX
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T32200 additive: a clear black pixel stays clear" TO TL-CASE
     MOVE "00000000" TO TL-EXPECTED
     MOVE 5 TO WS-ONE
     CALL "TEST-HEX-OF-IMAGE" USING WS-IMAGE WS-ONE WS-HEX
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T32200 additive: colour (200 100 0) becomes (255 128 0) with alpha 200" TO TL-CASE
     MOVE "FF8000C8" TO TL-EXPECTED
     MOVE 6 TO WS-ONE
     CALL "TEST-HEX-OF-IMAGE" USING WS-IMAGE WS-ONE WS-HEX
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T32200 additive: a bright pixel of alpha 0 stays clear (alpha 0)" TO TL-CASE
     MOVE "FFFFFF00" TO TL-EXPECTED
     MOVE 7 TO WS-ONE
     CALL "TEST-HEX-OF-IMAGE" USING WS-IMAGE WS-ONE WS-HEX
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ATLAS-ADDITIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HEX-OF-IMAGE.
*> USING image (28 bytes), pixel number (1-based), text out: the pixel's four bytes as 8 hex digits.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIGITS              PIC X(16) VALUE "0123456789ABCDEF".
 01 WS-K                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-IMAGE                PIC X(28).
 01 L-PIXEL                BINARY-LONG.
 01 L-TEXT                PIC X(8).
 PROCEDURE DIVISION USING L-IMAGE L-PIXEL L-TEXT.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-B = FUNCTION ORD(L-IMAGE((L-PIXEL - 1) * 4 + WS-K:1)) - 1
         COMPUTE WS-HI = WS-B / 16
         COMPUTE WS-LO = WS-B - WS-HI * 16
         MOVE WS-DIGITS(WS-HI + 1:1) TO L-TEXT(WS-K * 2 - 1:1)
         MOVE WS-DIGITS(WS-LO + 1:1) TO L-TEXT(WS-K * 2:1)
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-HEX-OF-IMAGE.
