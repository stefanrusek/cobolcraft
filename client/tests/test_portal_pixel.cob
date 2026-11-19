*> Implementation test of PORTAL-TEXELS-LOAD and PORTAL-COLOUR (client/src/portal-render.cob, T54011; docs/protocol/52 section 8.7, 8.8, 8.11, E7, E8): the two
*> textures are read from the generated vanilla pack (CC_GENERATED_DIR; 128 x 128 end_sky, 256 x 256 end_portal, the texels the worked example 8.7.6 names), the
*> colour of the worked example (arbitrary screen position (0.525, 0.8625), game time 1000, partial 0.5) is (3, 8, 16) after the output rounding (E8), and other
*> pixels, portal and gateway, equal the sums computed by an independent decoder (a throwaway script over the same PNG files). With no pack the flat colour of
*> 8.11 is given: (6, 15, 24) for the portal, (6, 16, 26) for the gateway.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-PIXEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-portal-pixel".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-GEN                 PIC X(1024).
 01 WS-LAYERS              BINARY-LONG.
 01 WS-U0                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-GT                  FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-R8                  BINARY-LONG.
 01 WS-G8                  BINARY-LONG.
 01 WS-B8                  BINARY-LONG.
 01 WS-N1                  PIC 9(3).
 01 WS-N2                  PIC 9(3).
 01 WS-N3                  PIC 9(3).
 01 WS-EXP                 FLOAT-LONG.
 01 WS-VAL                 FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-EDIT                PIC -(4)9.9(7).
 01 WS-AT                  BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-TEXT                PIC X(40).
 01 WS-D1                  PIC 9(3).
 01 WS-D2                  PIC 9(3).
 01 WS-D3                  PIC 9(3).
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-GEN TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-GEN)) TO CL-GENERATED-DIR-LENGTH
     MOVE "T" TO TL-MODE

*>   Before any pack is read: the flat colour (8.11), the gateway's a little brighter.
     MOVE 0 TO EP-TEX
     MOVE 15 TO WS-LAYERS
     MOVE 0.5 TO WS-U0 WS-V0
     MOVE 0 TO WS-GT
     CALL "PORTAL-COLOUR" USING CLIENT-STATE WS-LAYERS WS-U0 WS-V0 WS-GT WS-R WS-G WS-B
     CALL "PORTAL-RGB8" USING WS-R WS-G WS-B WS-R8 WS-G8 WS-B8
     MOVE "portal pixel without textures the portal is the flat (6, 15, 24) (8.11)" TO TL-CASE
     PERFORM TEXT-BYTES
     MOVE "006 015 024" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-LAYERS
     CALL "PORTAL-COLOUR" USING CLIENT-STATE WS-LAYERS WS-U0 WS-V0 WS-GT WS-R WS-G WS-B
     CALL "PORTAL-RGB8" USING WS-R WS-G WS-B WS-R8 WS-G8 WS-B8
     MOVE "portal pixel without textures the gateway is the flat (6, 16, 26) (8.11)" TO TL-CASE
     PERFORM TEXT-BYTES
     MOVE "006 016 026" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The pack is read: no pack with the textures, the state says missing.
     CALL "PORTAL-TEXELS-LOAD" USING CLIENT-STATE
     MOVE "portal pixel a stack without the two images leaves EP-TEX 2 (missing)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EP-TEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE "portal pixel a pack reload makes the textures be read again (EP-TEX 0)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EP-TEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     CALL "PORTAL-TEXELS-LOAD" USING CLIENT-STATE
     IF EP-TEX NOT = 1
         MOVE "portal pixel: no generated vanilla pack here (CC_GENERATED_DIR), the real-texture cases are skipped" TO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF

*>   8.8: the sizes and the texels the worked example names.
     MOVE "portal pixel end_sky is 128 x 128 and end_portal 256 x 256" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE EP-SKY-W TO WS-D1
     MOVE EP-SKY-H TO WS-D2
     MOVE EP-PTX-W TO WS-D3
     STRING WS-D1 " " WS-D2 " " WS-D3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "128 128 256" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-AT = (110 * 128 + 67) * 4 + 1
     MOVE "portal pixel end_sky texel (67, 110) is (94, 68, 131)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-D1 = FUNCTION ORD(EP-SKY(WS-AT:1)) - 1
     COMPUTE WS-D2 = FUNCTION ORD(EP-SKY(WS-AT + 1:1)) - 1
     COMPUTE WS-D3 = FUNCTION ORD(EP-SKY(WS-AT + 2:1)) - 1
     STRING WS-D1 " " WS-D2 " " WS-D3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "094 068 131" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-AT = (63 * 256 + 157) * 4 + 1
     MOVE "portal pixel end_portal texel (157, 63) is 4 and (151, 138) is 0" TO TL-CASE
     COMPUTE WS-D1 = FUNCTION ORD(EP-PTX(WS-AT:1)) - 1
     COMPUTE WS-AT = (138 * 256 + 151) * 4 + 1
     COMPUTE WS-D2 = FUNCTION ORD(EP-PTX(WS-AT:1)) - 1
     MOVE SPACES TO TL-OBSERVED
     STRING WS-D1 " " WS-D2 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "004 000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   E8: the worked example, 15 layers: the sum (0.011917, 0.030539, 0.062253) and the bytes (3, 8, 16).
     MOVE 15 TO WS-LAYERS
     MOVE 0.525 TO WS-U0
     MOVE 0.8625 TO WS-V0
     COMPUTE WS-GT = 1000.5 / 24000
     CALL "PORTAL-COLOUR" USING CLIENT-STATE WS-LAYERS WS-U0 WS-V0 WS-GT WS-R WS-G WS-B
     MOVE "portal pixel worked example 8.7.6 red sum is 0.0119164" TO TL-CASE
     MOVE WS-R TO WS-VAL
     MOVE 0.0119164 TO WS-EXP
     PERFORM CHECK-FLOAT
     MOVE "portal pixel worked example 8.7.6 green sum is 0.0305380" TO TL-CASE
     MOVE WS-G TO WS-VAL
     MOVE 0.0305380 TO WS-EXP
     PERFORM CHECK-FLOAT
     MOVE "portal pixel worked example 8.7.6 blue sum is 0.0622527" TO TL-CASE
     MOVE WS-B TO WS-VAL
     MOVE 0.0622527 TO WS-EXP
     PERFORM CHECK-FLOAT
     CALL "PORTAL-RGB8" USING WS-R WS-G WS-B WS-R8 WS-G8 WS-B8
     MOVE "portal pixel worked example 8.7.6 is (3, 8, 16) (E8)" TO TL-CASE
     PERFORM TEXT-BYTES
     MOVE "003 008 016" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The gateway's 16th layer hits a dark texel at that pixel: the same bytes.
     MOVE 16 TO WS-LAYERS
     CALL "PORTAL-COLOUR" USING CLIENT-STATE WS-LAYERS WS-U0 WS-V0 WS-GT WS-R WS-G WS-B
     CALL "PORTAL-RGB8" USING WS-R WS-G WS-B WS-R8 WS-G8 WS-B8
     MOVE "portal pixel gateway at the worked example pixel is (3, 8, 16)" TO TL-CASE
     PERFORM TEXT-BYTES
     MOVE "003 008 016" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A pixel where a bright star is hit (independent decoder): (33, 64, 63) for both layer counts.
     MOVE 15 TO WS-LAYERS
     MOVE 0.3 TO WS-U0
     MOVE 0.4 TO WS-V0
     MOVE 0.2 TO WS-GT
     CALL "PORTAL-COLOUR" USING CLIENT-STATE WS-LAYERS WS-U0 WS-V0 WS-GT WS-R WS-G WS-B
     CALL "PORTAL-RGB8" USING WS-R WS-G WS-B WS-R8 WS-G8 WS-B8
     MOVE "portal pixel (0.3, 0.4) at GameTime 0.2 hits a star: (33, 64, 63)" TO TL-CASE
     PERFORM TEXT-BYTES
     MOVE "033 064 063" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO WS-LAYERS
     MOVE 0.91 TO WS-U0
     MOVE 0.12 TO WS-V0
     MOVE 0.75 TO WS-GT
     CALL "PORTAL-COLOUR" USING CLIENT-STATE WS-LAYERS WS-U0 WS-V0 WS-GT WS-R WS-G WS-B
     CALL "PORTAL-RGB8" USING WS-R WS-G WS-B WS-R8 WS-G8 WS-B8
     MOVE "portal pixel (0.91, 0.12) at GameTime 0.75 is (4, 11, 20)" TO TL-CASE
     PERFORM TEXT-BYTES
     MOVE "004 011 020" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-LAYERS
     MOVE 0.08 TO WS-U0
     MOVE 0.77 TO WS-V0
     MOVE 0.5 TO WS-GT
     CALL "PORTAL-COLOUR" USING CLIENT-STATE WS-LAYERS WS-U0 WS-V0 WS-GT WS-R WS-G WS-B
     CALL "PORTAL-RGB8" USING WS-R WS-G WS-B WS-R8 WS-G8 WS-B8
     MOVE "gateway pixel (0.08, 0.77) at GameTime 0.5 is (4, 14, 29)" TO TL-CASE
     PERFORM TEXT-BYTES
     MOVE "004 014 029" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO WS-U0 WS-V0
     MOVE 0 TO WS-GT
     CALL "PORTAL-COLOUR" USING CLIENT-STATE WS-LAYERS WS-U0 WS-V0 WS-GT WS-R WS-G WS-B
     CALL "PORTAL-RGB8" USING WS-R WS-G WS-B WS-R8 WS-G8 WS-B8
     MOVE "gateway pixel (0.5, 0.5) at GameTime 0 is (3, 10, 19)" TO TL-CASE
     PERFORM TEXT-BYTES
     MOVE "003 010 019" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 TEXT-BYTES.
     MOVE WS-R8 TO WS-N1
     MOVE WS-G8 TO WS-N2
     MOVE WS-B8 TO WS-N3
     MOVE SPACES TO TL-OBSERVED
     STRING WS-N1 " " WS-N2 " " WS-N3 DELIMITED BY SIZE INTO TL-OBSERVED.

*> CHECK-FLOAT: WS-VAL against WS-EXP within 0.0000006 as "ok".
 CHECK-FLOAT.
     COMPUTE WS-DIFF = FUNCTION ABS(WS-VAL - WS-EXP)
     MOVE "ok" TO TL-EXPECTED
     MOVE "ok" TO TL-OBSERVED
     IF WS-DIFF > 0.0000006
         COMPUTE WS-EDIT ROUNDED = WS-VAL
         MOVE WS-EDIT TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PORTAL-PIXEL.
 COPY CLTEST.
