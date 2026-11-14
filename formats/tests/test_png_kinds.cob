*> Implementation test of formats/src/png.cob (PNG-DECODE; docs/protocol/22-extraction-tool.md §2.8 and the
*> "minimum decoder contract", Open question 7 closed by Round PNG): every kind of PNG that Round PNG lists
*> decodes to the reference RGBA, rows top to bottom, 8 bits a channel: gray 1, 2, 4, 8 bits; gray with alpha
*> 8 bits; palette 1, 2, 4, 8 bits (also interlaced); RGB 8 and 16 bits; RGBA 8 bits (also interlaced and 1x1);
*> a colour key (tRNS) for gray (1, 2, 8 bits) and RGB; a palette tRNS (full and partial); all five row filters
*> (8-bit RGBA, 2-bit gray, 16-bit RGB); several IDAT chunks cut at odd places; ancillary chunks before, between
*> and after the data. Every file Round PNG says is outside the set (bad signature, header, depth, colour type,
*> methods, filter byte, palette, chunk order, truncation) is refused with status 1 and width and height 0. The
*> files are those of contract/fixtures/formats/png (the reference <name>.rgba is made by an independent
*> encoder, tools/make_format_fixtures.py); the folder is listed with cc_fs_list so a new file the test does
*> not name fails the count.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PNG-KINDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-GOOD.
    05 FILLER PIC X(40) VALUE "ancillary-palette".
    05 FILLER PIC X(40) VALUE "ancillary".
    05 FILLER PIC X(40) VALUE "filters-gray2".
    05 FILLER PIC X(40) VALUE "filters-rgb16".
    05 FILLER PIC X(40) VALUE "filters".
    05 FILLER PIC X(40) VALUE "gray-alpha8".
    05 FILLER PIC X(40) VALUE "gray1".
    05 FILLER PIC X(40) VALUE "gray2".
    05 FILLER PIC X(40) VALUE "gray4".
    05 FILLER PIC X(40) VALUE "gray8".
    05 FILLER PIC X(40) VALUE "multi-idat".
    05 FILLER PIC X(40) VALUE "palette1".
    05 FILLER PIC X(40) VALUE "palette2".
    05 FILLER PIC X(40) VALUE "palette4".
    05 FILLER PIC X(40) VALUE "palette8-adam7".
    05 FILLER PIC X(40) VALUE "palette8".
    05 FILLER PIC X(40) VALUE "rgb16".
    05 FILLER PIC X(40) VALUE "rgb8".
    05 FILLER PIC X(40) VALUE "rgba8-1x1".
    05 FILLER PIC X(40) VALUE "rgba8-adam7-small".
    05 FILLER PIC X(40) VALUE "rgba8-adam7".
    05 FILLER PIC X(40) VALUE "rgba8".
    05 FILLER PIC X(40) VALUE "trns-gray-key-1bit".
    05 FILLER PIC X(40) VALUE "trns-gray-key-2bit".
    05 FILLER PIC X(40) VALUE "trns-gray-key".
    05 FILLER PIC X(40) VALUE "trns-palette-partial".
    05 FILLER PIC X(40) VALUE "trns-palette".
    05 FILLER PIC X(40) VALUE "trns-rgb-key".
 01 WS-GOOD-TABLE REDEFINES WS-GOOD.
    05 WS-GOOD-NAME        PIC X(40) OCCURS 28 TIMES.
 01 WS-BAD.
    05 FILLER PIC X(40) VALUE "reject-bad-bit-depth".
    05 FILLER PIC X(40) VALUE "reject-bad-colour-type".
    05 FILLER PIC X(40) VALUE "reject-bad-signature".
    05 FILLER PIC X(40) VALUE "reject-compression-method-1".
    05 FILLER PIC X(40) VALUE "reject-filter-byte-5".
    05 FILLER PIC X(40) VALUE "reject-filter-method-1".
    05 FILLER PIC X(40) VALUE "reject-first-chunk-not-ihdr".
    05 FILLER PIC X(40) VALUE "reject-ihdr-length-12".
    05 FILLER PIC X(40) VALUE "reject-inflated-too-short".
    05 FILLER PIC X(40) VALUE "reject-interlace-method-2".
    05 FILLER PIC X(40) VALUE "reject-missing-iend".
    05 FILLER PIC X(40) VALUE "reject-not-zlib".
    05 FILLER PIC X(40) VALUE "reject-palette-depth-16".
    05 FILLER PIC X(40) VALUE "reject-palette-without-plte".
    05 FILLER PIC X(40) VALUE "reject-rgb-depth-1".
    05 FILLER PIC X(40) VALUE "reject-too-short".
    05 FILLER PIC X(40) VALUE "reject-truncated-data".
 01 WS-BAD-TABLE REDEFINES WS-BAD.
    05 WS-BAD-NAME         PIC X(40) OCCURS 17 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-DIRECTORY           PIC X(64).
 01 WS-LIST                PIC X(8192).
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 8192.
 01 WS-LIST-RC             BINARY-LONG.
 01 WS-PNGS                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PNG                 PIC X(4096).
 01 WS-PNG-CAPACITY        BINARY-LONG VALUE 4096.
 01 WS-PNG-LENGTH          BINARY-LONG.
 01 WS-EXPECT              PIC X(4096).
 01 WS-EXPECT-LENGTH       BINARY-LONG.
 01 WS-OUT                 PIC X(4096).
 01 WS-OUT-CAPACITY        BINARY-LONG VALUE 4096.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-READ-STATUS         BINARY-LONG.
 01 WS-HEADER-WIDTH        BINARY-LONG.
 01 WS-HEADER-HEIGHT       BINARY-LONG.
 01 WS-BYTE                BINARY-CHAR UNSIGNED.
 01 WS-STATUS-D            PIC 9.
 01 WS-SHOWN               PIC -(9)9.
 01 WS-SHOWN2              PIC -(9)9.
 PROCEDURE DIVISION.
*>   The folder holds exactly the files named here: 28 decoding images, 17 refused ones.
     MOVE LOW-VALUES TO WS-DIRECTORY
     STRING "contract/fixtures/formats/png" X"00" DELIMITED BY SIZE INTO WS-DIRECTORY
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRECTORY BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-LIST-RC
     MOVE 0 TO WS-PNGS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8189
         IF WS-LIST(WS-K:4) = ".png"
             IF WS-LIST(WS-K + 4:1) = X"0A"
                 ADD 1 TO WS-PNGS
             END-IF
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "png kinds the fixture folder holds every PNG this test names (and no other)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 28 + 17
     MOVE WS-PNGS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The kinds that decode: status 0, the size of the IHDR, exactly the reference bytes.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 28
         MOVE WS-GOOD-NAME(WS-I) TO WS-NAME
         PERFORM READ-PNG
         MOVE WS-OUT-CAPACITY TO WS-K
         CALL "PNG-DECODE" USING WS-PNG WS-PNG-LENGTH WS-OUT WS-OUT-CAPACITY WS-WIDTH WS-HEIGHT WS-STATUS
         MOVE SPACES TO WS-PATH
         STRING FUNCTION TRIM(WS-NAME) ".rgba" DELIMITED BY SIZE INTO WS-PATH
         MOVE SPACES TO TL-CASE
         STRING "png kinds " FUNCTION TRIM(WS-NAME) " decodes to the reference RGBA" DELIMITED BY SIZE INTO TL-CASE
         PERFORM READ-REFERENCE
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         MOVE WS-HEADER-WIDTH TO WS-SHOWN
         MOVE WS-HEADER-HEIGHT TO WS-SHOWN2
         STRING "0 " FUNCTION TRIM(WS-SHOWN) "x" FUNCTION TRIM(WS-SHOWN2) " same" DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE WS-WIDTH TO WS-SHOWN
         MOVE WS-HEIGHT TO WS-SHOWN2
         MOVE WS-STATUS TO WS-STATUS-D
         IF WS-STATUS = 0 AND WS-EXPECT-LENGTH = WS-WIDTH * WS-HEIGHT * 4
                 AND WS-OUT(1:WS-EXPECT-LENGTH) = WS-EXPECT(1:WS-EXPECT-LENGTH)
             STRING "0 " FUNCTION TRIM(WS-SHOWN) "x" FUNCTION TRIM(WS-SHOWN2) " same" DELIMITED BY SIZE INTO TL-OBSERVED
         ELSE
             STRING WS-STATUS-D " " FUNCTION TRIM(WS-SHOWN) "x" FUNCTION TRIM(WS-SHOWN2) " differs"
                 DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   The files outside the set: status 1, width and height 0.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 17
         MOVE WS-BAD-NAME(WS-I) TO WS-NAME
         PERFORM READ-PNG
         MOVE 7 TO WS-WIDTH
         MOVE 7 TO WS-HEIGHT
         CALL "PNG-DECODE" USING WS-PNG WS-PNG-LENGTH WS-OUT WS-OUT-CAPACITY WS-WIDTH WS-HEIGHT WS-STATUS
         MOVE SPACES TO TL-CASE TL-OBSERVED
         STRING "png kinds " FUNCTION TRIM(WS-NAME) " is refused (status 1, size 0x0)" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE "1 0x0" TO TL-EXPECTED
         MOVE WS-STATUS TO WS-STATUS-D
         MOVE WS-WIDTH TO WS-SHOWN
         MOVE WS-HEIGHT TO WS-SHOWN2
         STRING WS-STATUS-D " " FUNCTION TRIM(WS-SHOWN) "x" FUNCTION TRIM(WS-SHOWN2) DELIMITED BY SIZE INTO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

*> The file contract/fixtures/formats/png/<WS-NAME>.png into WS-PNG; the width and height of its IHDR.
 READ-PNG.
     MOVE SPACES TO WS-PATH
     STRING "contract/fixtures/formats/png/" FUNCTION TRIM(WS-NAME) ".png" DELIMITED BY SIZE INTO WS-PATH
     COMPUTE WS-PATH-LENGTH = 34 + FUNCTION LENGTH(FUNCTION TRIM(WS-NAME))
     MOVE SPACES TO WS-PNG
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-PNG WS-PNG-CAPACITY WS-PNG-LENGTH WS-READ-STATUS
     MOVE 0 TO WS-HEADER-WIDTH WS-HEADER-HEIGHT
     PERFORM VARYING WS-K FROM 17 BY 1 UNTIL WS-K > 20
         COMPUTE WS-BYTE = FUNCTION ORD(WS-PNG(WS-K:1)) - 1
         COMPUTE WS-HEADER-WIDTH = WS-HEADER-WIDTH * 256 + WS-BYTE
         COMPUTE WS-BYTE = FUNCTION ORD(WS-PNG(WS-K + 4:1)) - 1
         COMPUTE WS-HEADER-HEIGHT = WS-HEADER-HEIGHT * 256 + WS-BYTE
     END-PERFORM.

*> The reference RGBA of the file, from the sibling .rgba file.
 READ-REFERENCE.
     MOVE SPACES TO WS-PATH
     STRING "contract/fixtures/formats/png/" FUNCTION TRIM(WS-NAME) ".rgba" DELIMITED BY SIZE INTO WS-PATH
     COMPUTE WS-PATH-LENGTH = 35 + FUNCTION LENGTH(FUNCTION TRIM(WS-NAME))
     MOVE SPACES TO WS-EXPECT
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-EXPECT WS-PNG-CAPACITY WS-EXPECT-LENGTH WS-READ-STATUS.
 END PROGRAM TEST-PNG-KINDS.
