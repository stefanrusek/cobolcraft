*> The player's skin rules of docs/protocol/47-default-skin.md that need no network:
*>   PLAYER-SKIN-FOR-UUID uuid(X(16)) index(out BINARY-LONG 0 to 17) texture(out X(40), the id path under textures/, e.g. entity/player/slim/alex) slim(out 1 slim, 0 wide) (2.2):
*>     UUID.hashCode is the low 32 bits of x XOR (x >>> 32) with x = the two halves XORed, a signed 32-bit integer; the index is floorMod(hashCode, 18);
*>   PLAYER-SKIN-ENTRY index texture slim: entry `index` of the table of 2.1 (nine slim names then the nine wide ones, in alphabetical order; an index outside 0 to 17 is entry 6);
*>   PLAYER-SKIN-DEFAULT texture slim: getDefaultSkin, entry 6 (slim steve), the skin of a head without a profile (2.2);
*>   PLAYER-PART-MASK part(0 cape, 1 jacket, 2 left sleeve, 3 right sleeve, 4 left pants leg, 5 right pants leg, 6 hat) mask(out) (5.1; an unknown part has mask 0);
*>   PLAYER-PART-SHOWN flags(the customisation byte of entity entry 16) part shown(out 1 when (flags and mask) = mask) (5.3);
*>   PLAYER-PARTS-OPTIONS CLIENT-STATE parts(out): the skin parts byte of the options modelPart_* (47 5.2; 127 by default);
*>   PLAYER-SKIN-LEGACY pixels(X(16384): a 64 x 64 RGBA image, rows of 256 bytes; a legacy skin has its 64 x 32 rows first) width height status(out 0, or -1 for a size
*>     other than 64 x 32 and 64 x 64, the image then untouched): the conversion of 4 (the twelve mirrored copies of a legacy skin, the hat transparency hack, the opaque
*>     base regions).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-SKIN-ENTRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(8) VALUE "alex".
    05 FILLER PIC X(8) VALUE "ari".
    05 FILLER PIC X(8) VALUE "efe".
    05 FILLER PIC X(8) VALUE "kai".
    05 FILLER PIC X(8) VALUE "makena".
    05 FILLER PIC X(8) VALUE "noor".
    05 FILLER PIC X(8) VALUE "steve".
    05 FILLER PIC X(8) VALUE "sunny".
    05 FILLER PIC X(8) VALUE "zuri".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-NAME             PIC X(8) OCCURS 9 TIMES.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXTURE              PIC X(40).
 01 L-SLIM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TEXTURE L-SLIM.
     MOVE L-INDEX TO WS-INDEX
     IF WS-INDEX < 0 OR WS-INDEX > 17
         MOVE 6 TO WS-INDEX
     END-IF
     MOVE SPACES TO L-TEXTURE
     IF WS-INDEX < 9
         MOVE 1 TO L-SLIM
         STRING "entity/player/slim/" FUNCTION TRIM(WS-NAME(WS-INDEX + 1)) DELIMITED BY SIZE INTO L-TEXTURE
     ELSE
         MOVE 0 TO L-SLIM
         STRING "entity/player/wide/" FUNCTION TRIM(WS-NAME(WS-INDEX - 8)) DELIMITED BY SIZE INTO L-TEXTURE
     END-IF
     GOBACK.
 END PROGRAM PLAYER-SKIN-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-SKIN-DEFAULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 01 L-TEXTURE              PIC X(40).
 01 L-SLIM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXTURE L-SLIM.
     CALL "PLAYER-SKIN-ENTRY" USING WS-SIX L-TEXTURE L-SLIM
     GOBACK.
 END PROGRAM PLAYER-SKIN-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-SKIN-FOR-UUID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GROUP               PIC X(4).
 01 WS-HASH-BYTES          PIC X(4).
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-U                   BINARY-DOUBLE.
 01 WS-H                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-UUID                 PIC X(16).
 01 L-INDEX                BINARY-LONG.
 01 L-TEXTURE              PIC X(40).
 01 L-SLIM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-UUID L-INDEX L-TEXTURE L-SLIM.
*>   x = most XOR least significant bits, then x XOR (x >>> 32), low 32 bits: the four 4-byte groups of the UUID XORed together.
     MOVE L-UUID(1:4) TO WS-HASH-BYTES
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE L-UUID(WS-K * 4 + 1:4) TO WS-GROUP
         CALL "CBL_XOR" USING WS-GROUP WS-HASH-BYTES BY VALUE 4
     END-PERFORM
     MOVE 0 TO WS-U
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-N = FUNCTION ORD(WS-HASH-BYTES(WS-K:1)) - 1
         COMPUTE WS-U = WS-U * 256 + WS-N
     END-PERFORM
     MOVE WS-U TO WS-H
     IF WS-U >= 2147483648
         COMPUTE WS-H = WS-U - 4294967296
     END-IF
     COMPUTE L-INDEX = FUNCTION MOD(WS-H, 18)
     CALL "PLAYER-SKIN-ENTRY" USING L-INDEX L-TEXTURE L-SLIM
     GOBACK.
 END PROGRAM PLAYER-SKIN-FOR-UUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-PART-MASK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PART                 BINARY-LONG.
 01 L-MASK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PART L-MASK.
     MOVE 0 TO L-MASK
     IF L-PART >= 0 AND L-PART <= 6
         COMPUTE L-MASK = 2 ** L-PART
     END-IF
     GOBACK.
 END PROGRAM PLAYER-PART-MASK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-PART-SHOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MASK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAGS                BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-SHOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS L-PART L-SHOWN.
     CALL "PLAYER-PART-MASK" USING L-PART WS-MASK
     MOVE 0 TO L-SHOWN
     IF WS-MASK > 0 AND FUNCTION MOD(FUNCTION INTEGER(L-FLAGS / WS-MASK), 2) = 1
         MOVE 1 TO L-SHOWN
     END-IF
     GOBACK.
 END PROGRAM PLAYER-PART-SHOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-SKIN-LEGACY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
*>   The twelve copies of 4 step 3: source x, source y, destination x, destination y, width, height.
 01 WS-COPY-DATA.
    05 FILLER PIC X(24) VALUE "004016020048004004".
    05 FILLER PIC X(24) VALUE "008016024048004004".
    05 FILLER PIC X(24) VALUE "000020024052004012".
    05 FILLER PIC X(24) VALUE "004020020052004012".
    05 FILLER PIC X(24) VALUE "008020016052004012".
    05 FILLER PIC X(24) VALUE "012020028052004012".
    05 FILLER PIC X(24) VALUE "044016036048004004".
    05 FILLER PIC X(24) VALUE "048016040048004004".
    05 FILLER PIC X(24) VALUE "040020040052004012".
    05 FILLER PIC X(24) VALUE "044020036052004012".
    05 FILLER PIC X(24) VALUE "048020032052004012".
    05 FILLER PIC X(24) VALUE "052020044052004012".
 01 WS-COPIES REDEFINES WS-COPY-DATA.
    05 WS-COPY OCCURS 12 TIMES.
       10 WS-SX            PIC 999.
       10 WS-SY            PIC 999.
       10 WS-DX            PIC 999.
       10 WS-DY            PIC 999.
       10 WS-W             PIC 999.
       10 WS-H             PIC 999.
       10 FILLER           PIC X(6).
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-LEGACY              BINARY-LONG.
 01 WS-SEE-THROUGH         BINARY-LONG.
 01 WS-ALPHA               BINARY-LONG.
 01 WS-OPAQUE              PIC X.
 01 WS-CLEAR               PIC X VALUE LOW-VALUE.
 LINKAGE SECTION.
 01 L-PIXELS               PIC X(16384).
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PIXELS L-WIDTH L-HEIGHT L-STATUS.
     MOVE 0 TO L-STATUS
     IF L-WIDTH NOT = 64 OR (L-HEIGHT NOT = 32 AND L-HEIGHT NOT = 64)
         MOVE -1 TO L-STATUS
         GOBACK
     END-IF
     MOVE 0 TO WS-LEGACY
     MOVE FUNCTION CHAR(256) TO WS-OPAQUE
     IF L-HEIGHT = 32
         MOVE 1 TO WS-LEGACY
*>       The new rows 32 to 63 start as transparent black, then the twelve mirrored copies.
         MOVE LOW-VALUES TO L-PIXELS(8193:8192)
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 12
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-H(WS-C)
                 PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-W(WS-C)
                     COMPUTE WS-FROM = ((WS-SY(WS-C) + WS-J) * 64 + WS-SX(WS-C) + WS-I) * 4 + 1
                     COMPUTE WS-TO = ((WS-DY(WS-C) + WS-J) * 64 + WS-DX(WS-C) + WS-W(WS-C) - 1 - WS-I) * 4 + 1
                     MOVE L-PIXELS(WS-FROM:4) TO L-PIXELS(WS-TO:4)
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
*>   4a: the head base layer (x 0 to 31, y 0 to 15) is opaque.
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 15
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 31
             MOVE WS-OPAQUE TO L-PIXELS((WS-Y * 64 + WS-X) * 4 + 4:1)
         END-PERFORM
     END-PERFORM
*>   4b: a legacy skin whose hat rectangle (x 32 to 63, y 0 to 31) is nowhere transparent (every alpha 128 or more) has no hat: alpha cleared, colour kept.
     IF WS-LEGACY = 1
         MOVE 0 TO WS-SEE-THROUGH
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 31
             PERFORM VARYING WS-X FROM 32 BY 1 UNTIL WS-X > 63
                 COMPUTE WS-ALPHA = FUNCTION ORD(L-PIXELS((WS-Y * 64 + WS-X) * 4 + 4:1)) - 1
                 IF WS-ALPHA < 128
                     MOVE 1 TO WS-SEE-THROUGH
                 END-IF
             END-PERFORM
         END-PERFORM
         IF WS-SEE-THROUGH = 0
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 31
                 PERFORM VARYING WS-X FROM 32 BY 1 UNTIL WS-X > 63
                     MOVE WS-CLEAR TO L-PIXELS((WS-Y * 64 + WS-X) * 4 + 4:1)
                 END-PERFORM
             END-PERFORM
         END-IF
     END-IF
*>   4c: body, right leg and right arm base (x 0 to 63, y 16 to 31); 4d: left leg and left arm base (x 16 to 47, y 48 to 63).
     PERFORM VARYING WS-Y FROM 16 BY 1 UNTIL WS-Y > 31
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 63
             MOVE WS-OPAQUE TO L-PIXELS((WS-Y * 64 + WS-X) * 4 + 4:1)
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-Y FROM 48 BY 1 UNTIL WS-Y > 63
         PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 47
             MOVE WS-OPAQUE TO L-PIXELS((WS-Y * 64 + WS-X) * 4 + 4:1)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PLAYER-SKIN-LEGACY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-PARTS-OPTIONS.
*> USING CLIENT-STATE, parts out (BINARY-LONG): the skin parts byte of the options (47 section 5.2): the masks (PLAYER-PART-MASK) of the parts whose option modelPart_<id>
*> (cape, jacket, left_sleeve, right_sleeve, left_pants_leg, right_pants_leg, hat) is not false; all seven on (127) by default.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(40) VALUE "modelPart_cape".
    05 FILLER PIC X(40) VALUE "modelPart_jacket".
    05 FILLER PIC X(40) VALUE "modelPart_left_sleeve".
    05 FILLER PIC X(40) VALUE "modelPart_right_sleeve".
    05 FILLER PIC X(40) VALUE "modelPart_left_pants_leg".
    05 FILLER PIC X(40) VALUE "modelPart_right_pants_leg".
    05 FILLER PIC X(40) VALUE "modelPart_hat".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-OPTION-NAME      PIC X(40) OCCURS 7 TIMES.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PARTS                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PARTS.
     MOVE 0 TO L-PARTS
     PERFORM VARYING WS-PART FROM 0 BY 1 UNTIL WS-PART > 6
         MOVE WS-OPTION-NAME(WS-PART + 1) TO WS-NAME
         CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-FOUND
         IF WS-FOUND = 0 OR WS-VALUE(1:5) NOT = "false"
             CALL "PLAYER-PART-MASK" USING WS-PART WS-MASK
             ADD WS-MASK TO L-PARTS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PLAYER-PARTS-OPTIONS.
