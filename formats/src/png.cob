*> PNG decoder for pack textures (08 §7.1: a texture is a PNG file, decoded into an RGBA image; an
*> unreadable image is replaced by the missing texture). 08 places no restriction on the PNG, so
*> every colour type and bit depth of the PNG specification is read (grey 1/2/4/8/16, RGB 8/16,
*> palette 1/2/4/8, grey+alpha 8/16, RGBA 8/16), with tRNS for grey, RGB and palette images, the
*> five filter types, Adam7 interlacing and any number of IDAT chunks. The zlib stream is inflated
*> by cc_inflate mode CC_ZLIB (shim-abi.md §5) into a buffer of the size IHDR implies.
*> Decisions where the PNG specification leaves the reader a choice: chunk CRCs are not checked;
*> ancillary and unknown chunks are skipped; a PLTE in a non-palette image is accepted and unused.
*> Unreadable (status 1): wrong signature; a chunk running past the data; a first chunk that is not
*> a 13-byte IHDR, or a second IHDR; no IEND; no IDAT data; width or height 0 or above 2^31-1; a
*> colour type / bit depth pair the PNG specification does not define; compression, filter or
*> interlace method unknown; a palette image without PLTE; a PLTE not of 1 to 256 entries; a tRNS
*> of the wrong length for its colour type (or in an image with alpha), or longer than PLTE; filtered
*> data over 2^31-1 bytes; zlib data that is corrupt or does not inflate to exactly the size IHDR
*> implies; a row filter type above 4; a palette index beyond PLTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNG-DECODE.
*> USING data area (the PNG file), data length (BINARY-LONG), out area, capacity of the out area in
*> bytes (BINARY-LONG), width out, height out, status out (all BINARY-LONG). Status 0: the out
*> area holds the image as 8-bit RGBA, width * height * 4 bytes, rows top to bottom (16-bit samples
*> keep their high byte; samples below 8 bits are scaled to 0..255; colour types without alpha get
*> alpha 255, or 0 for the tRNS colour). Status 1: unreadable (width and height 0). Status 5: the
*> image (width * height * 4 bytes) is larger than the capacity; width and height are set and the
*> out area is untouched. The structure is checked before the capacity, the zlib data after it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-MODE                BINARY-LONG VALUE CC-ZLIB.
 01 WS-RC                  BINARY-LONG.
 01 WS-SIGNATURE           PIC X(8).
 01 WS-BX                  PIC X.
 01 WS-BN REDEFINES WS-BX  BINARY-CHAR UNSIGNED.
 01 WS-QX                  PIC X(4).
 01 WS-QN REDEFINES WS-QX.
    05 WS-Q                BINARY-CHAR UNSIGNED OCCURS 4 TIMES.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-CHUNKS              BINARY-LONG.
 01 WS-POS                 BINARY-DOUBLE.
 01 WS-LEN                 BINARY-DOUBLE.
 01 WS-TYPE                PIC X(4).
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-DOUBLE.
*> IHDR.
 01 WS-W                   BINARY-DOUBLE.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-CTYPE               BINARY-LONG.
 01 WS-COMP                BINARY-LONG.
 01 WS-FILT                BINARY-LONG.
 01 WS-INTERLACE           BINARY-LONG.
 01 WS-CH                  BINARY-LONG.
 01 WS-BPP                 BINARY-LONG.
 01 WS-MAXV                BINARY-LONG.
*> PLTE and tRNS: palette entries as R, G, B, A (A 255 unless tRNS gives it).
 01 WS-PLTE-N              BINARY-LONG.
 01 WS-PALETTE.
    05 WS-PAL              PIC X(4) OCCURS 256 TIMES.
 01 WS-TRNS                BINARY-LONG.
 01 WS-TRNS-N              BINARY-LONG.
 01 WS-TR                  BINARY-LONG OCCURS 3 TIMES.
*> Passes: Adam7 passes 1 to 7 (x start, y start, x step, y step), entry 8 the whole image.
 01 WS-ADAM7-TEXT          PIC X(32) VALUE "00884088044820440224102201120011".
 01 WS-ADAM7 REDEFINES WS-ADAM7-TEXT.
    05 WS-A7 OCCURS 8 TIMES.
       10 WS-A7-XS         PIC 9.
       10 WS-A7-YS         PIC 9.
       10 WS-A7-XD         PIC 9.
       10 WS-A7-YD         PIC 9.
 01 WS-PASSES.
    05 WS-PASS OCCURS 8 TIMES.
       10 WS-PASS-W        BINARY-DOUBLE.
       10 WS-PASS-H        BINARY-DOUBLE.
       10 WS-PASS-RB       BINARY-DOUBLE.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-PI                  BINARY-LONG.
 01 WS-XS                  BINARY-LONG.
 01 WS-YS                  BINARY-LONG.
 01 WS-XD                  BINARY-LONG.
 01 WS-YD                  BINARY-LONG.
 01 WS-PW                  BINARY-DOUBLE.
 01 WS-PH                  BINARY-DOUBLE.
 01 WS-RB                  BINARY-DOUBLE.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-RAW                 BINARY-DOUBLE.
 01 WS-RGBA                BINARY-DOUBLE.
*> Inflating.
 01 WS-IDAT-TOTAL          BINARY-DOUBLE.
 01 WS-Z-ADDR              USAGE POINTER.
 01 WS-R-ADDR              USAGE POINTER.
 01 WS-ZPOS                BINARY-DOUBLE.
 01 WS-IN-LEN              BINARY-LONG.
 01 WS-RAW-LEN             BINARY-LONG.
 01 WS-OUT-LEN             BINARY-LONG.
*> Unfiltering and expanding.
 01 WS-RP                  BINARY-DOUBLE.
 01 WS-D0                  BINARY-DOUBLE.
 01 WS-ROW                 BINARY-DOUBLE.
 01 WS-J                   BINARY-DOUBLE.
 01 WS-FT                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-PA                  BINARY-LONG.
 01 WS-PB                  BINARY-LONG.
 01 WS-PC                  BINARY-LONG.
 01 WS-PX                  BINARY-DOUBLE.
 01 WS-K                   BINARY-LONG.
 01 WS-BIT                 BINARY-DOUBLE.
 01 WS-SHIFT               BINARY-LONG.
 01 WS-POW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG OCCURS 4 TIMES.
 01 WS-S8                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-SV                  BINARY-LONG.
 01 WS-PIXEL.
    05 WS-PIX              BINARY-CHAR UNSIGNED OCCURS 4 TIMES.
 01 WS-DEST                BINARY-DOUBLE.
 01 B-DATA                 PIC X(1073741824) BASED.
 01 B-OUT                  PIC X(1073741824) BASED.
 01 B-Z                    PIC X(1073741824) BASED.
 01 B-R                    PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-DATA                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-OUT                  PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DATA L-LENGTH L-OUT L-CAPACITY L-WIDTH L-HEIGHT L-STATUS.
     SET ADDRESS OF B-DATA TO ADDRESS OF L-DATA
     SET ADDRESS OF B-OUT TO ADDRESS OF L-OUT
     MOVE FUNCTION HEX-TO-CHAR("89504E470D0A1A0A") TO WS-SIGNATURE
     MOVE 0 TO WS-BAD WS-DONE WS-CHUNKS WS-W WS-H WS-DEPTH WS-CTYPE WS-COMP WS-FILT
         WS-INTERLACE WS-PLTE-N WS-TRNS WS-TRNS-N WS-IDAT-TOTAL L-WIDTH L-HEIGHT
     MOVE 1 TO L-STATUS
     MOVE 255 TO WS-BN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE LOW-VALUES TO WS-PAL(WS-I)
         MOVE WS-BX TO WS-PAL(WS-I)(4:1)
     END-PERFORM
     EVALUATE TRUE
         WHEN L-LENGTH < 8
             MOVE 1 TO WS-BAD
         WHEN B-DATA(1:8) NOT = WS-SIGNATURE
             MOVE 1 TO WS-BAD
     END-EVALUATE
*>   Chunks: length, type, data, CRC (not checked), up to IEND.
     MOVE 9 TO WS-POS
     PERFORM UNTIL WS-BAD = 1 OR WS-DONE = 1
         IF WS-POS + 11 > L-LENGTH
             MOVE 1 TO WS-BAD
         ELSE
             MOVE B-DATA(WS-POS:4) TO WS-QX
             COMPUTE WS-LEN = WS-Q(1) * 16777216 + WS-Q(2) * 65536 + WS-Q(3) * 256 + WS-Q(4)
             MOVE B-DATA(WS-POS + 4:4) TO WS-TYPE
             EVALUATE TRUE
                 WHEN WS-POS + 11 + WS-LEN > L-LENGTH
                     MOVE 1 TO WS-BAD
                 WHEN WS-CHUNKS = 0 AND (WS-TYPE NOT = "IHDR" OR WS-LEN NOT = 13)
                     MOVE 1 TO WS-BAD
                 WHEN WS-TYPE = "IHDR" AND WS-CHUNKS > 0
                     MOVE 1 TO WS-BAD
                 WHEN WS-TYPE = "IHDR"
                     MOVE B-DATA(WS-POS + 8:4) TO WS-QX
                     COMPUTE WS-W = WS-Q(1) * 16777216 + WS-Q(2) * 65536 + WS-Q(3) * 256 + WS-Q(4)
                     MOVE B-DATA(WS-POS + 12:4) TO WS-QX
                     COMPUTE WS-H = WS-Q(1) * 16777216 + WS-Q(2) * 65536 + WS-Q(3) * 256 + WS-Q(4)
                     MOVE B-DATA(WS-POS + 16:4) TO WS-QX
                     MOVE WS-Q(1) TO WS-DEPTH
                     MOVE WS-Q(2) TO WS-CTYPE
                     MOVE WS-Q(3) TO WS-COMP
                     MOVE WS-Q(4) TO WS-FILT
                     MOVE B-DATA(WS-POS + 20:1) TO WS-BX
                     MOVE WS-BN TO WS-INTERLACE
                 WHEN WS-TYPE = "PLTE" AND (WS-LEN = 0 OR WS-LEN > 768
                         OR FUNCTION MOD(WS-LEN, 3) NOT = 0)
                     MOVE 1 TO WS-BAD
                 WHEN WS-TYPE = "PLTE"
                     DIVIDE WS-LEN BY 3 GIVING WS-PLTE-N
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-PLTE-N
                         COMPUTE WS-AT = WS-POS + 8 + (WS-I - 1) * 3
                         MOVE B-DATA(WS-AT:3) TO WS-PAL(WS-I)(1:3)
                     END-PERFORM
                 WHEN WS-TYPE = "tRNS" AND WS-CTYPE = 0 AND WS-LEN = 2
                     MOVE B-DATA(WS-POS + 8:2) TO WS-QX(1:2)
                     COMPUTE WS-TR(1) = WS-Q(1) * 256 + WS-Q(2)
                     MOVE 1 TO WS-TRNS
                 WHEN WS-TYPE = "tRNS" AND WS-CTYPE = 2 AND WS-LEN = 6
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                         COMPUTE WS-AT = WS-POS + 6 + WS-I * 2
                         MOVE B-DATA(WS-AT:2) TO WS-QX(1:2)
                         COMPUTE WS-TR(WS-I) = WS-Q(1) * 256 + WS-Q(2)
                     END-PERFORM
                     MOVE 1 TO WS-TRNS
                 WHEN WS-TYPE = "tRNS" AND WS-CTYPE = 3 AND WS-LEN <= 256
                     MOVE WS-LEN TO WS-TRNS-N
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TRNS-N
                         COMPUTE WS-AT = WS-POS + 7 + WS-I
                         MOVE B-DATA(WS-AT:1) TO WS-PAL(WS-I)(4:1)
                     END-PERFORM
                 WHEN WS-TYPE = "tRNS"
                     MOVE 1 TO WS-BAD
                 WHEN WS-TYPE = "IDAT"
                     ADD WS-LEN TO WS-IDAT-TOTAL
                 WHEN WS-TYPE = "IEND"
                     MOVE 1 TO WS-DONE
             END-EVALUATE
             COMPUTE WS-POS = WS-POS + 12 + WS-LEN
             ADD 1 TO WS-CHUNKS
         END-IF
     END-PERFORM
*>   Channels per pixel of each colour type with the bit depths it allows (0: undefined pair).
     EVALUATE WS-CTYPE ALSO WS-DEPTH
         WHEN 0 ALSO 1 WHEN 0 ALSO 2 WHEN 0 ALSO 4 WHEN 0 ALSO 8 WHEN 0 ALSO 16
         WHEN 3 ALSO 1 WHEN 3 ALSO 2 WHEN 3 ALSO 4 WHEN 3 ALSO 8
             MOVE 1 TO WS-CH
         WHEN 2 ALSO 8 WHEN 2 ALSO 16
             MOVE 3 TO WS-CH
         WHEN 4 ALSO 8 WHEN 4 ALSO 16
             MOVE 2 TO WS-CH
         WHEN 6 ALSO 8 WHEN 6 ALSO 16
             MOVE 4 TO WS-CH
         WHEN OTHER
             MOVE 0 TO WS-CH
     END-EVALUATE
     EVALUATE TRUE
         WHEN WS-BAD = 1
             CONTINUE
         WHEN WS-IDAT-TOTAL = 0
             MOVE 1 TO WS-BAD
         WHEN WS-W = 0 OR WS-H = 0 OR WS-W > 2147483647 OR WS-H > 2147483647
             MOVE 1 TO WS-BAD
         WHEN WS-CH = 0
             MOVE 1 TO WS-BAD
         WHEN WS-COMP NOT = 0 OR WS-FILT NOT = 0 OR WS-INTERLACE > 1
             MOVE 1 TO WS-BAD
         WHEN WS-CTYPE = 3 AND WS-PLTE-N = 0
             MOVE 1 TO WS-BAD
         WHEN WS-TRNS-N > WS-PLTE-N
             MOVE 1 TO WS-BAD
     END-EVALUATE
*>   Size of the filtered data: per pass, rows of one filter byte and the packed samples.
     IF WS-BAD = 0
         COMPUTE WS-BPP = WS-CH * WS-DEPTH / 8
         IF WS-BPP = 0
             MOVE 1 TO WS-BPP
         END-IF
         COMPUTE WS-MAXV = 2 ** WS-DEPTH - 1
         IF WS-INTERLACE = 1
             MOVE 1 TO WS-P1
             MOVE 7 TO WS-P2
         ELSE
             MOVE 8 TO WS-P1 WS-P2
         END-IF
         MOVE 0 TO WS-RAW
         PERFORM VARYING WS-PI FROM WS-P1 BY 1 UNTIL WS-PI > WS-P2
             MOVE WS-A7-XS(WS-PI) TO WS-XS
             MOVE WS-A7-YS(WS-PI) TO WS-YS
             MOVE WS-A7-XD(WS-PI) TO WS-XD
             MOVE WS-A7-YD(WS-PI) TO WS-YD
             MOVE 0 TO WS-PW WS-PH WS-RB
             IF WS-W > WS-XS AND WS-H > WS-YS
                 COMPUTE WS-T = WS-W - WS-XS + WS-XD - 1
                 DIVIDE WS-T BY WS-XD GIVING WS-PW
                 COMPUTE WS-T = WS-H - WS-YS + WS-YD - 1
                 DIVIDE WS-T BY WS-YD GIVING WS-PH
                 COMPUTE WS-T = WS-PW * WS-CH * WS-DEPTH + 7
                 DIVIDE WS-T BY 8 GIVING WS-RB
                 COMPUTE WS-RAW = WS-RAW + WS-PH * (WS-RB + 1)
             END-IF
             MOVE WS-PW TO WS-PASS-W(WS-PI)
             MOVE WS-PH TO WS-PASS-H(WS-PI)
             MOVE WS-RB TO WS-PASS-RB(WS-PI)
         END-PERFORM
         IF WS-RAW > 2147483647
             MOVE 1 TO WS-BAD
         END-IF
     END-IF
     COMPUTE WS-RGBA = WS-W * WS-H * 4
     EVALUATE TRUE
         WHEN WS-BAD = 1
             GOBACK
         WHEN WS-RGBA > L-CAPACITY
             MOVE WS-W TO L-WIDTH
             MOVE WS-H TO L-HEIGHT
             MOVE 5 TO L-STATUS
             GOBACK
     END-EVALUATE
*>   Collect the IDAT data (the walk above found the chunks well formed) and inflate it.
     ALLOCATE WS-IDAT-TOTAL CHARACTERS RETURNING WS-Z-ADDR
     SET ADDRESS OF B-Z TO WS-Z-ADDR
     MOVE 9 TO WS-POS
     MOVE 1 TO WS-ZPOS
     MOVE SPACES TO WS-TYPE
     PERFORM UNTIL WS-TYPE = "IEND"
         MOVE B-DATA(WS-POS:4) TO WS-QX
         COMPUTE WS-LEN = WS-Q(1) * 16777216 + WS-Q(2) * 65536 + WS-Q(3) * 256 + WS-Q(4)
         MOVE B-DATA(WS-POS + 4:4) TO WS-TYPE
         IF WS-TYPE = "IDAT" AND WS-LEN > 0
             MOVE B-DATA(WS-POS + 8:WS-LEN) TO B-Z(WS-ZPOS:WS-LEN)
             ADD WS-LEN TO WS-ZPOS
         END-IF
         COMPUTE WS-POS = WS-POS + 12 + WS-LEN
     END-PERFORM
     ALLOCATE WS-RAW CHARACTERS RETURNING WS-R-ADDR
     SET ADDRESS OF B-R TO WS-R-ADDR
     MOVE WS-IDAT-TOTAL TO WS-IN-LEN
     MOVE WS-RAW TO WS-RAW-LEN
     CALL STATIC "cc_inflate" USING BY VALUE WS-MODE BY VALUE WS-Z-ADDR BY VALUE WS-IN-LEN
         BY VALUE WS-R-ADDR BY VALUE WS-RAW-LEN BY REFERENCE WS-OUT-LEN RETURNING WS-RC
     IF WS-RC NOT = 0 OR WS-OUT-LEN NOT = WS-RAW-LEN
         MOVE 1 TO WS-BAD
     END-IF
*>   Each pass: undo each row's filter in place (the prior row is already reconstructed), then
*>   expand its pixels to RGBA at their place in the image.
     MOVE 1 TO WS-RP
     PERFORM VARYING WS-PI FROM WS-P1 BY 1 UNTIL WS-PI > WS-P2 OR WS-BAD = 1
         MOVE WS-A7-XS(WS-PI) TO WS-XS
         MOVE WS-A7-YS(WS-PI) TO WS-YS
         MOVE WS-A7-XD(WS-PI) TO WS-XD
         MOVE WS-A7-YD(WS-PI) TO WS-YD
         MOVE WS-PASS-W(WS-PI) TO WS-PW
         MOVE WS-PASS-H(WS-PI) TO WS-PH
         MOVE WS-PASS-RB(WS-PI) TO WS-RB
         PERFORM VARYING WS-ROW FROM 0 BY 1 UNTIL WS-ROW >= WS-PH OR WS-BAD = 1
             MOVE B-R(WS-RP:1) TO WS-BX
             MOVE WS-BN TO WS-FT
             COMPUTE WS-D0 = WS-RP + 1
             IF WS-FT > 4
                 MOVE 1 TO WS-BAD
             END-IF
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-RB OR WS-FT = 0 OR WS-BAD = 1
                 COMPUTE WS-AT = WS-D0 + WS-J
                 MOVE 0 TO WS-A WS-B WS-C
                 IF WS-J >= WS-BPP
                     MOVE B-R(WS-AT - WS-BPP:1) TO WS-BX
                     MOVE WS-BN TO WS-A
                 END-IF
                 IF WS-ROW > 0
                     MOVE B-R(WS-AT - WS-RB - 1:1) TO WS-BX
                     MOVE WS-BN TO WS-B
                 END-IF
                 IF WS-ROW > 0 AND WS-J >= WS-BPP
                     MOVE B-R(WS-AT - WS-RB - 1 - WS-BPP:1) TO WS-BX
                     MOVE WS-BN TO WS-C
                 END-IF
                 MOVE B-R(WS-AT:1) TO WS-BX
                 EVALUATE WS-FT
                     WHEN 1
                         COMPUTE WS-V = WS-BN + WS-A
                     WHEN 2
                         COMPUTE WS-V = WS-BN + WS-B
                     WHEN 3
                         COMPUTE WS-T = WS-A + WS-B
                         DIVIDE WS-T BY 2 GIVING WS-V
                         ADD WS-BN TO WS-V
                     WHEN OTHER
*>                       Paeth: the neighbour nearest a + b - c, ties to a, then b.
                         COMPUTE WS-PA = FUNCTION ABS(WS-B - WS-C)
                         COMPUTE WS-PB = FUNCTION ABS(WS-A - WS-C)
                         COMPUTE WS-PC = FUNCTION ABS(WS-A + WS-B - WS-C - WS-C)
                         EVALUATE TRUE
                             WHEN WS-PA <= WS-PB AND WS-PA <= WS-PC
                                 COMPUTE WS-V = WS-BN + WS-A
                             WHEN WS-PB <= WS-PC
                                 COMPUTE WS-V = WS-BN + WS-B
                             WHEN OTHER
                                 COMPUTE WS-V = WS-BN + WS-C
                         END-EVALUATE
                 END-EVALUATE
                 COMPUTE WS-BN = FUNCTION MOD(WS-V, 256)
                 MOVE WS-BX TO B-R(WS-AT:1)
             END-PERFORM
             PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX >= WS-PW OR WS-BAD = 1
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CH
                     EVALUATE WS-DEPTH
                         WHEN 16
                             COMPUTE WS-AT = WS-D0 + (WS-PX * WS-CH + WS-K - 1) * 2
                             MOVE B-R(WS-AT:2) TO WS-QX(1:2)
                             COMPUTE WS-S(WS-K) = WS-Q(1) * 256 + WS-Q(2)
                             MOVE WS-Q(1) TO WS-S8(WS-K)
                         WHEN 8
                             COMPUTE WS-AT = WS-D0 + WS-PX * WS-CH + WS-K - 1
                             MOVE B-R(WS-AT:1) TO WS-BX
                             MOVE WS-BN TO WS-S(WS-K) WS-S8(WS-K)
                         WHEN OTHER
*>                           One sample below 8 bits, most significant bits first.
                             COMPUTE WS-BIT = WS-PX * WS-DEPTH
                             DIVIDE WS-BIT BY 8 GIVING WS-AT
                             ADD WS-D0 TO WS-AT
                             COMPUTE WS-SHIFT = 8 - WS-DEPTH - FUNCTION MOD(WS-BIT, 8)
                             COMPUTE WS-POW = 2 ** WS-SHIFT
                             MOVE B-R(WS-AT:1) TO WS-BX
                             DIVIDE WS-BN BY WS-POW GIVING WS-SV
                             COMPUTE WS-S(WS-K) = FUNCTION MOD(WS-SV, WS-MAXV + 1)
                             COMPUTE WS-S8(WS-K) = WS-S(WS-K) * 255 / WS-MAXV
                     END-EVALUATE
                 END-PERFORM
                 EVALUATE WS-CTYPE
                     WHEN 0
                         MOVE WS-S8(1) TO WS-PIX(1) WS-PIX(2) WS-PIX(3)
                         MOVE 255 TO WS-PIX(4)
                         IF WS-TRNS = 1 AND WS-S(1) = WS-TR(1)
                             MOVE 0 TO WS-PIX(4)
                         END-IF
                     WHEN 2
                         MOVE WS-S8(1) TO WS-PIX(1)
                         MOVE WS-S8(2) TO WS-PIX(2)
                         MOVE WS-S8(3) TO WS-PIX(3)
                         MOVE 255 TO WS-PIX(4)
                         IF WS-TRNS = 1 AND WS-S(1) = WS-TR(1) AND WS-S(2) = WS-TR(2)
                                 AND WS-S(3) = WS-TR(3)
                             MOVE 0 TO WS-PIX(4)
                         END-IF
                     WHEN 3
                         MOVE WS-S(1) TO WS-SV
                         IF WS-SV >= WS-PLTE-N
                             MOVE 1 TO WS-BAD
                         ELSE
                             MOVE WS-PAL(WS-SV + 1) TO WS-PIXEL
                         END-IF
                     WHEN 4
                         MOVE WS-S8(1) TO WS-PIX(1) WS-PIX(2) WS-PIX(3)
                         MOVE WS-S8(2) TO WS-PIX(4)
                     WHEN OTHER
                         MOVE WS-S8(1) TO WS-PIX(1)
                         MOVE WS-S8(2) TO WS-PIX(2)
                         MOVE WS-S8(3) TO WS-PIX(3)
                         MOVE WS-S8(4) TO WS-PIX(4)
                 END-EVALUATE
                 COMPUTE WS-DEST = ((WS-YS + WS-ROW * WS-YD) * WS-W + WS-XS + WS-PX * WS-XD) * 4 + 1
                 MOVE WS-PIXEL TO B-OUT(WS-DEST:4)
             END-PERFORM
             COMPUTE WS-RP = WS-RP + WS-RB + 1
         END-PERFORM
     END-PERFORM
     FREE WS-Z-ADDR
     FREE WS-R-ADDR
     IF WS-BAD = 0
         MOVE WS-W TO L-WIDTH
         MOVE WS-H TO L-HEIGHT
         MOVE 0 TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM PNG-DECODE.
