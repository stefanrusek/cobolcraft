*> Acceptance test of the operator report "sun and moon have a big black square around them" (try14 play, screenshots 13.30.07 and 13.30.15; bug lane
*> bugcelestial; 12 section 3.4c): vanilla draws the sun, moon and star sprites with the additive OVERLAY blend, so the opaque black background of the
*> sprite adds nothing. The shim has no additive pipeline, so the client alpha-blends them (the UI pipeline) and the black showed. The block atlas the sprites
*> are drawn from therefore holds the celestials atlas sprites (minecraft:sun, minecraft:moon/<phase>, minecraft:end_flash) as straight-alpha pixels: the black
*> background has alpha 0, the sun's bright centre stays opaque with its colour, the moon's centre keeps its hue at its brightness; the sprites of the other
*> atlas definitions (a block texture) are untouched. Reads the generated vanilla pack's real sprites (CC_GENERATED_DIR; the sprites come out missing without it
*> and the test fails).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SKY-CELESTIAL-ALPHA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-sky-celestial".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-GEN                 PIC X(1024).
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-HEX                 PIC X(8).
 01 WS-DIGITS              PIC X(16) VALUE "0123456789ABCDEF".
 01 WS-K                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-OPAQUE              BINARY-LONG.
 01 WS-CLEAR               BINARY-LONG.
 01 WS-ED1                 PIC Z(5)9.
 01 WS-ED2                 PIC Z(5)9.
 01 WS-ED3                 PIC Z(5)9.
 01 B-ATLAS                PIC X(1073741824) BASED.
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
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE "T" TO TL-MODE

*>   The sun (lane bugsunchest: vanilla's sun is a white square with a pale blue halo, ours was gold with an orange rim): the sprite is added over the day sky, where
*>   its gold rim (255 213 74) and pale centre (255 255 217) saturate to white, so the baked pixels are white with the share of the way to white as alpha. The corner
*>   (black background) is white and clear, the centre and the rim white and opaque, a halo pixel (14 14 5) white with a low alpha (34: the mean of the red share
*>   14 / 135 and the green share 14 / 88).
     MOVE "minecraft:sun" TO WS-ID
     MOVE 13 TO WS-ID-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SPRITE
     MOVE 0 TO WS-PX WS-PY
     PERFORM READ-PIXEL
     MOVE "acceptance sky: given the vanilla sun sprite when it is on the block atlas then its black corner pixel is clear (alpha 0)" TO TL-CASE
     MOVE "FFFFFF00" TO TL-EXPECTED
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-PX WS-PY
     PERFORM READ-PIXEL
     MOVE "acceptance sky: given the vanilla sun sprite when it is on the block atlas then its centre is white and opaque, not the sprite's pale yellow" TO TL-CASE
     MOVE "FFFFFFFF" TO TL-EXPECTED
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-PX WS-PY
     PERFORM READ-PIXEL
     MOVE "acceptance sky: given the vanilla sun sprite when it is on the block atlas then its gold rim (255 213 74) is white and opaque (it saturates over the sky)" TO TL-CASE
     MOVE "FFFFFFFF" TO TL-EXPECTED
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A pixel of the glow (14 14 5) is white with the share of the way to white that the addition reaches as its alpha.
     MOVE 8 TO WS-PX WS-PY
     PERFORM READ-PIXEL
     MOVE "acceptance sky: given the vanilla sun sprite when it is on the block atlas then a dark glow pixel is white with a low alpha (a pale blue halo over the sky)" TO TL-CASE
     MOVE "FFFFFF22" TO TL-EXPECTED
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The full moon: the corner is clear, the centre (175 184 204) is 204 bright: its hue at full brightness, alpha 204.
     MOVE "minecraft:moon/full_moon" TO WS-ID
     MOVE 24 TO WS-ID-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SPRITE
     MOVE 0 TO WS-PX WS-PY
     PERFORM READ-PIXEL
     MOVE "acceptance sky: given the vanilla full moon sprite when it is on the block atlas then its black corner pixel is clear (alpha 0)" TO TL-CASE
     MOVE "00000000" TO TL-EXPECTED
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-PX WS-PY
     PERFORM READ-PIXEL
     MOVE "acceptance sky: given the vanilla full moon sprite when it is on the block atlas then its centre keeps its hue at its brightness as alpha" TO TL-CASE
     MOVE "DBE6FFCC" TO TL-EXPECTED
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The new moon sprite is nearly all dark: its corner is clear too.
     MOVE "minecraft:moon/new_moon" TO WS-ID
     MOVE 23 TO WS-ID-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SPRITE
     MOVE 31 TO WS-PX WS-PY
     PERFORM READ-PIXEL
     MOVE "acceptance sky: given the vanilla new moon sprite when it is on the block atlas then its far corner pixel is clear" TO TL-CASE
     MOVE "00000000" TO TL-EXPECTED
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A block texture is not touched: every pixel of stone keeps alpha 255.
     MOVE "minecraft:block/stone" TO WS-ID
     MOVE 21 TO WS-ID-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SPRITE
     MOVE 0 TO WS-OPAQUE WS-CLEAR
     IF WS-SPRITE > 0
         SET ADDRESS OF B-ATLAS TO AT-ADDR
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= AT-SH(WS-SPRITE)
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= AT-SW(WS-SPRITE)
                 COMPUTE WS-I = ((AT-Y(WS-SPRITE) + WS-Y) * AT-W + AT-X(WS-SPRITE) + WS-X) * 4 + 4
                 IF FUNCTION ORD(B-ATLAS(WS-I:1)) = 256
                     ADD 1 TO WS-OPAQUE
                 ELSE
                     ADD 1 TO WS-CLEAR
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF
     MOVE "acceptance sky: given a block sprite (stone) when the atlas is built then none of its pixels is made clear" TO TL-CASE
     MOVE "found 1 opaque 256 other 0" TO TL-EXPECTED
     MOVE WS-OPAQUE TO WS-ED1
     MOVE WS-CLEAR TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     IF WS-SPRITE > 0 AND WS-OPAQUE = 256 AND WS-CLEAR = 0
         MOVE "found 1 opaque 256 other 0" TO TL-OBSERVED
     ELSE
         MOVE WS-SPRITE TO WS-ED3
         STRING "sprite " WS-ED3 " opaque " WS-ED1 " other " WS-ED2 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> READ-PIXEL: the pixel (WS-PX, WS-PY) of sprite WS-SPRITE of the block atlas as 8 hex digits in WS-HEX (00000000 when the sprite is unresolved).
 READ-PIXEL.
     MOVE "00000000" TO WS-HEX
     IF WS-SPRITE = 0
         MOVE "NOSPRITE" TO WS-HEX
     ELSE
         SET ADDRESS OF B-ATLAS TO AT-ADDR
         COMPUTE WS-I = ((AT-Y(WS-SPRITE) + WS-PY) * AT-W + AT-X(WS-SPRITE) + WS-PX) * 4
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             COMPUTE WS-B = FUNCTION ORD(B-ATLAS(WS-I + WS-K:1)) - 1
             COMPUTE WS-HI = WS-B / 16
             COMPUTE WS-LO = WS-B - WS-HI * 16
             MOVE WS-DIGITS(WS-HI + 1:1) TO WS-HEX(WS-K * 2 - 1:1)
             MOVE WS-DIGITS(WS-LO + 1:1) TO WS-HEX(WS-K * 2:1)
         END-PERFORM
     END-IF.
 END PROGRAM ACC-SKY-CELESTIAL-ALPHA.
 COPY CLTEST.
