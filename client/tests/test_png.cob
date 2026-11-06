*> Implementation test of client/src/png.cob (PNG-DECODE; 08 §7.1): a texture is a PNG file of any
*> kind the PNG specification allows, decoded to 8-bit RGBA, rows top to bottom. Covered: every
*> colour type and bit depth (grey 1/2/4/8/16, RGB 8/16, palette 1/2/4/8, grey+alpha 8/16, RGBA
*> 8/16), tRNS for grey, RGB and palette images, the five filter types alone (whole-byte and
*> sub-byte pixels, 16-bit samples), Adam7 interlacing (including images with empty passes),
*> several IDAT chunks and ancillary chunks, sizes that are not powers of two, the capacity outcome
*> (status 5 with width and height set), and rejection of unreadable files (status 1). CRCs are not
*> checked: a file whose only fault is a wrong CRC decodes.
*> Fixtures: client/tests/fixtures/png/<name>.png with the expected RGBA bytes in <name>.rgba, both
*> written by the independent encoder client/tests/fixtures/gen_png.py (make -C client fixtures).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PNG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-GOOD.
    05 FILLER PIC X(30) VALUE "g1                      013011".
    05 FILLER PIC X(30) VALUE "g2                      013011".
    05 FILLER PIC X(30) VALUE "g4                      013011".
    05 FILLER PIC X(30) VALUE "g8                      013011".
    05 FILLER PIC X(30) VALUE "g16                     013011".
    05 FILLER PIC X(30) VALUE "rgb8                    013011".
    05 FILLER PIC X(30) VALUE "rgb16                   013011".
    05 FILLER PIC X(30) VALUE "p1                      013011".
    05 FILLER PIC X(30) VALUE "p2                      013011".
    05 FILLER PIC X(30) VALUE "p4                      013011".
    05 FILLER PIC X(30) VALUE "p8                      013011".
    05 FILLER PIC X(30) VALUE "ga8                     013011".
    05 FILLER PIC X(30) VALUE "ga16                    013011".
    05 FILLER PIC X(30) VALUE "rgba8                   013011".
    05 FILLER PIC X(30) VALUE "rgba16                  013011".
    05 FILLER PIC X(30) VALUE "g1_trns                 013011".
    05 FILLER PIC X(30) VALUE "g2_trns                 013011".
    05 FILLER PIC X(30) VALUE "g4_trns                 013011".
    05 FILLER PIC X(30) VALUE "g8_trns                 013011".
    05 FILLER PIC X(30) VALUE "g16_trns                013011".
    05 FILLER PIC X(30) VALUE "rgb8_trns               013011".
    05 FILLER PIC X(30) VALUE "rgb16_trns              013011".
    05 FILLER PIC X(30) VALUE "p4_trns                 013011".
    05 FILLER PIC X(30) VALUE "p8_trns                 013011".
    05 FILLER PIC X(30) VALUE "f_none                  009007".
    05 FILLER PIC X(30) VALUE "f_none_g2               021007".
    05 FILLER PIC X(30) VALUE "f_none_rgb16            009007".
    05 FILLER PIC X(30) VALUE "f_sub                   009007".
    05 FILLER PIC X(30) VALUE "f_sub_g2                021007".
    05 FILLER PIC X(30) VALUE "f_sub_rgb16             009007".
    05 FILLER PIC X(30) VALUE "f_up                    009007".
    05 FILLER PIC X(30) VALUE "f_up_g2                 021007".
    05 FILLER PIC X(30) VALUE "f_up_rgb16              009007".
    05 FILLER PIC X(30) VALUE "f_average               009007".
    05 FILLER PIC X(30) VALUE "f_average_g2            021007".
    05 FILLER PIC X(30) VALUE "f_average_rgb16         009007".
    05 FILLER PIC X(30) VALUE "f_paeth                 009007".
    05 FILLER PIC X(30) VALUE "f_paeth_g2              021007".
    05 FILLER PIC X(30) VALUE "f_paeth_rgb16           009007".
    05 FILLER PIC X(30) VALUE "i_g1                    037029".
    05 FILLER PIC X(30) VALUE "i_g4                    037029".
    05 FILLER PIC X(30) VALUE "i_g16                   037029".
    05 FILLER PIC X(30) VALUE "i_rgb8                  037029".
    05 FILLER PIC X(30) VALUE "i_p2                    037029".
    05 FILLER PIC X(30) VALUE "i_ga16                  037029".
    05 FILLER PIC X(30) VALUE "i_rgba8                 037029".
    05 FILLER PIC X(30) VALUE "i_rgba16                037029".
    05 FILLER PIC X(30) VALUE "i_rgb8_trns             037029".
    05 FILLER PIC X(30) VALUE "i_1x1                   001001".
    05 FILLER PIC X(30) VALUE "i_3x2                   003002".
    05 FILLER PIC X(30) VALUE "i_5x9                   005009".
    05 FILLER PIC X(30) VALUE "multi_idat              023019".
    05 FILLER PIC X(30) VALUE "multi_idat_i            023019".
    05 FILLER PIC X(30) VALUE "size_1x1                001001".
    05 FILLER PIC X(30) VALUE "size_1x17               001017".
    05 FILLER PIC X(30) VALUE "size_17x1               017001".
    05 FILLER PIC X(30) VALUE "size_255x3              255003".
    05 FILLER PIC X(30) VALUE "size_64x64              064064".
    05 FILLER PIC X(30) VALUE "bad_crc                 007005".
 01 WS-GOOD-TABLE REDEFINES WS-GOOD.
    05 WS-GOOD-ENTRY OCCURS 59 TIMES.
       10 WS-GOOD-NAME     PIC X(24).
       10 WS-GOOD-W        PIC 9(3).
       10 WS-GOOD-H        PIC 9(3).
 01 WS-BAD.
    05 FILLER PIC X(24) VALUE "bad_signature".
    05 FILLER PIC X(24) VALUE "too_short".
    05 FILLER PIC X(24) VALUE "truncated_header".
    05 FILLER PIC X(24) VALUE "truncated_chunk".
    05 FILLER PIC X(24) VALUE "corrupt_zlib".
    05 FILLER PIC X(24) VALUE "missing_ihdr".
    05 FILLER PIC X(24) VALUE "ihdr_not_first".
    05 FILLER PIC X(24) VALUE "ihdr_twice".
    05 FILLER PIC X(24) VALUE "ihdr_length".
    05 FILLER PIC X(24) VALUE "missing_idat".
    05 FILLER PIC X(24) VALUE "missing_iend".
    05 FILLER PIC X(24) VALUE "zero_width".
    05 FILLER PIC X(24) VALUE "zero_height".
    05 FILLER PIC X(24) VALUE "huge_width".
    05 FILLER PIC X(24) VALUE "bad_rgb_depth".
    05 FILLER PIC X(24) VALUE "bad_grey_depth".
    05 FILLER PIC X(24) VALUE "bad_palette_depth".
    05 FILLER PIC X(24) VALUE "bad_colour_type".
    05 FILLER PIC X(24) VALUE "bad_compression".
    05 FILLER PIC X(24) VALUE "bad_filter_method".
    05 FILLER PIC X(24) VALUE "bad_interlace".
    05 FILLER PIC X(24) VALUE "bad_filter_type".
    05 FILLER PIC X(24) VALUE "short_data".
    05 FILLER PIC X(24) VALUE "long_data".
    05 FILLER PIC X(24) VALUE "raw_too_big".
    05 FILLER PIC X(24) VALUE "palette_missing".
    05 FILLER PIC X(24) VALUE "palette_index".
    05 FILLER PIC X(24) VALUE "palette_length".
    05 FILLER PIC X(24) VALUE "palette_empty".
    05 FILLER PIC X(24) VALUE "palette_too_long".
    05 FILLER PIC X(24) VALUE "trns_length".
    05 FILLER PIC X(24) VALUE "trns_alpha_type".
    05 FILLER PIC X(24) VALUE "trns_long_palette".
 01 WS-BAD-TABLE REDEFINES WS-BAD.
    05 WS-BAD-NAME         PIC X(24) OCCURS 33 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-PATH                PIC X(256).
 01 WS-PNG                 PIC X(65536).
 01 WS-PNG-CAPACITY        BINARY-LONG VALUE 65536.
 01 WS-PNG-LENGTH          BINARY-LONG.
 01 WS-EXPECT              PIC X(65536).
 01 WS-EXPECT-CAPACITY     BINARY-LONG VALUE 65536.
 01 WS-EXPECT-LENGTH       BINARY-LONG.
 01 WS-OUT                 PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-W                   PIC 9(5).
 01 WS-H                   PIC 9(5).
 01 WS-N                   PIC 9(6).
 01 WS-S                   PIC 9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
*>   Images that decode: status 0, the size of the IHDR and exactly the expected RGBA bytes.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 59
         MOVE WS-GOOD-NAME(WS-I) TO WS-NAME
         PERFORM LOAD-PNG
         MOVE SPACES TO WS-PATH
         STRING "client/tests/fixtures/png/" DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE
             ".rgba" DELIMITED BY SIZE INTO WS-PATH
         CALL "TEST-READ-FILE" USING WS-PATH WS-EXPECT WS-EXPECT-CAPACITY WS-EXPECT-LENGTH
         MOVE 65536 TO WS-CAPACITY
         PERFORM DECODE
         MOVE SPACES TO TL-CASE TL-EXPECTED
         STRING "png " DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE
             " decodes to the RGBA bytes of the reference" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-GOOD-W(WS-I) TO WS-W
         MOVE WS-GOOD-H(WS-I) TO WS-H
         STRING "status 0 size " WS-W "x" WS-H " rgba same" DELIMITED BY SIZE INTO TL-EXPECTED
         PERFORM DESCRIBE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   Unreadable files: status 1.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 33
         MOVE WS-BAD-NAME(WS-I) TO WS-NAME
         PERFORM LOAD-PNG
         MOVE 2147483647 TO WS-CAPACITY
         PERFORM DECODE
         MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
         STRING "png " DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE
             " is rejected as unreadable" DELIMITED BY SIZE INTO TL-CASE
         MOVE "status 1" TO TL-EXPECTED
         MOVE WS-STATUS TO WS-S
         STRING "status " WS-S DELIMITED BY SIZE INTO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   Capacity: one byte too small gives status 5 with the size set; exactly enough decodes.
     MOVE "rgba8" TO WS-NAME
     PERFORM LOAD-PNG
     MOVE 571 TO WS-CAPACITY
     PERFORM DECODE
     MOVE SPACES TO TL-OBSERVED
     MOVE "png capacity one byte below width*height*4 gives status 5 with the size set"
         TO TL-CASE
     MOVE "status 5 size 00013x00011" TO TL-EXPECTED
     MOVE WS-STATUS TO WS-S
     MOVE WS-WIDTH TO WS-W
     MOVE WS-HEIGHT TO WS-H
     STRING "status " WS-S " size " WS-W "x" WS-H DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "client/tests/fixtures/png/rgba8.rgba" TO WS-PATH
     CALL "TEST-READ-FILE" USING WS-PATH WS-EXPECT WS-EXPECT-CAPACITY WS-EXPECT-LENGTH
     MOVE 572 TO WS-CAPACITY
     PERFORM DECODE
     MOVE "png capacity of exactly width*height*4 decodes" TO TL-CASE
     MOVE "status 0 size 00013x00011 rgba same" TO TL-EXPECTED
     PERFORM DESCRIBE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 LOAD-PNG.
     MOVE SPACES TO WS-PATH
     STRING "client/tests/fixtures/png/" DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE
         ".png" DELIMITED BY SIZE INTO WS-PATH
     CALL "TEST-READ-FILE" USING WS-PATH WS-PNG WS-PNG-CAPACITY WS-PNG-LENGTH.

 DECODE.
     MOVE LOW-VALUES TO WS-OUT
     MOVE -1 TO WS-WIDTH WS-HEIGHT WS-STATUS
     CALL "PNG-DECODE" USING WS-PNG WS-PNG-LENGTH WS-OUT WS-CAPACITY WS-WIDTH WS-HEIGHT
         WS-STATUS.

*> Observed text "status <s> size <w>x<h> rgba same" or "... rgba differs at <offset> of <n>".
 DESCRIBE.
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATUS TO WS-S
     MOVE WS-WIDTH TO WS-W
     MOVE WS-HEIGHT TO WS-H
     MOVE 0 TO WS-DIFF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-EXPECT-LENGTH OR WS-DIFF > 0
         IF WS-OUT(WS-K:1) NOT = WS-EXPECT(WS-K:1)
             MOVE WS-K TO WS-DIFF
         END-IF
     END-PERFORM
     IF WS-DIFF = 0 AND WS-EXPECT-LENGTH > 0
         STRING "status " WS-S " size " WS-W "x" WS-H " rgba same" DELIMITED BY SIZE
             INTO TL-OBSERVED
     ELSE
         MOVE WS-DIFF TO WS-N
         STRING "status " WS-S " size " WS-W "x" WS-H " rgba differs at byte " WS-N
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.
 END PROGRAM TEST-PNG.
 COPY CLTEST.
