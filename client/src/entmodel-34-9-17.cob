*> Entity models part 9, section 17 display entities (docs/protocol/34-entity-models-9-non-living-entities.md): the rules of the renderers. The display entities are not drawn yet (no replica of the
*> display entity data of 44 part 9 section 6, no block model in the entity pass, no world-space text); these programs state the arithmetic.
*>   EF9-DISPLAY-ORIENT IN(1 billboard constraint 0 fixed, 1 vertical, 2 horizontal, 3 center, 2 entityYRot, 3 entityXRot, 4 cameraYRot, 5 cameraXRot, degrees) OUT(1 yaw, 2 pitch in radians): 17.1 table
*>     (D = 0.017453292; the quaternion is rotationYXZ(yaw, pitch, 0));
*>   EF9-DISPLAY-LIGHT IN(1 brightness override packed or -1, 2 level block, 3 level sky) OUT(1 block, 2 sky): 17.1 (the override unpacked: block = (l >> 4) and 15, sky = (l >> 20) and 15);
*>   EF9-DISPLAY-BLOCK-OPS, EF9-DISPLAY-ITEM-OPS OUT(ops): the item display rotates Y by 180 degrees (pi) before the item; the block display adds none;
*>   EF9-TEXT-FLAGS IN(1 style flags byte) OUT(1 see-through (mode SEE_THROUGH), 2 shadow, 3 default background, 4 alignment 0 left, 1 right, 2 centre);
*>   EF9-TEXT-LAYOUT IN(1 flags, 2 number of lines, 3 the widest line's width) OUT(1 lh = 10, 2 height = lines x lh - 1, 3 translate x = 1 - width / 2, 4 translate y = -height, 5 the default background's
*>     alpha int(0.25 x 255) when the default background flag is set else 0);
*>   EF9-TEXT-LINE IN(1 flags, 2 width, 3 lineWidth, 4 line index) OUT(1 x, 2 y = index x 10): left 0, right width - lineWidth, centre width / 2 - lineWidth / 2 (left tested first, then right);
*>   EF9-TEXT-COLOR IN(1 opacity) OUT(1 (opacity << 24) or 0xFFFFFF as the byte-narrowed opacity's ARGB, 2 the narrowed opacity): 17.4 step 3 and 8.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-DISPLAY-ORIENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-C
     EVALUATE WS-C
         WHEN 0
             COMPUTE L-O(1) = 0 - 0.017453292 * L-I(2)
             COMPUTE L-O(2) = 0.017453292 * L-I(3)
         WHEN 1
             COMPUTE L-O(1) = 0 - 0.017453292 * (L-I(4) - 180)
             COMPUTE L-O(2) = 0.017453292 * L-I(3)
         WHEN 2
             COMPUTE L-O(1) = 0 - 0.017453292 * L-I(2)
             COMPUTE L-O(2) = 0.017453292 * (0 - L-I(5))
         WHEN OTHER
             COMPUTE L-O(1) = 0 - 0.017453292 * (L-I(4) - 180)
             COMPUTE L-O(2) = 0.017453292 * (0 - L-I(5))
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-DISPLAY-ORIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-DISPLAY-LIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-L                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(1) = -1
         MOVE L-I(2) TO L-O(1)
         MOVE L-I(3) TO L-O(2)
     ELSE
         MOVE L-I(1) TO WS-L
         COMPUTE WS-Q = WS-L / 16
         COMPUTE L-O(1) = FUNCTION MOD(WS-Q, 16)
         COMPUTE WS-Q = WS-L / 1048576
         COMPUTE L-O(2) = FUNCTION MOD(WS-Q, 16)
     END-IF
     GOBACK.
 END PROGRAM EF9-DISPLAY-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-DISPLAY-ITEM-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     MOVE 3 TO L-O(2)
     MOVE 180 TO L-O(3)
     MOVE 0 TO L-O(4) L-O(5)
     GOBACK.
 END PROGRAM EF9-DISPLAY-ITEM-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-DISPLAY-BLOCK-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     GOBACK.
 END PROGRAM EF9-DISPLAY-BLOCK-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-TEXT-FLAGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-F
     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     COMPUTE WS-Q = WS-F / 2
     IF FUNCTION MOD(WS-Q, 2) = 1
         MOVE 1 TO L-O(1)
     END-IF
     IF FUNCTION MOD(WS-F, 2) = 1
         MOVE 1 TO L-O(2)
     END-IF
     COMPUTE WS-Q = WS-F / 4
     IF FUNCTION MOD(WS-Q, 2) = 1
         MOVE 1 TO L-O(3)
     END-IF
     MOVE 2 TO L-O(4)
     COMPUTE WS-Q = WS-F / 16
     IF FUNCTION MOD(WS-Q, 2) = 1
         MOVE 1 TO L-O(4)
     END-IF
     COMPUTE WS-Q = WS-F / 8
     IF FUNCTION MOD(WS-Q, 2) = 1
         MOVE 0 TO L-O(4)
     END-IF
     GOBACK.
 END PROGRAM EF9-TEXT-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-TEXT-LAYOUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-F
     MOVE 10 TO L-O(1)
     COMPUTE L-O(2) = L-I(2) * L-O(1) - 1
     COMPUTE L-O(3) = 1 - L-I(3) / 2
     COMPUTE L-O(4) = 0 - L-O(2)
     MOVE 0 TO L-O(5)
     COMPUTE WS-Q = WS-F / 4
     IF FUNCTION MOD(WS-Q, 2) = 1
         COMPUTE L-O(5) = FUNCTION INTEGER-PART(0.25 * 255)
     END-IF
     GOBACK.
 END PROGRAM EF9-TEXT-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-TEXT-LINE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-Q2                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-F
     COMPUTE WS-Q = WS-F / 8
     COMPUTE WS-Q2 = WS-F / 16
     EVALUATE TRUE
         WHEN FUNCTION MOD(WS-Q, 2) = 1
             MOVE 0 TO L-O(1)
         WHEN FUNCTION MOD(WS-Q2, 2) = 1
             COMPUTE L-O(1) = L-I(2) - L-I(3)
         WHEN OTHER
             COMPUTE L-O(1) = L-I(2) / 2 - L-I(3) / 2
     END-EVALUATE
     COMPUTE L-O(2) = L-I(4) * 10
     GOBACK.
 END PROGRAM EF9-TEXT-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-TEXT-COLOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-B
     COMPUTE WS-B = FUNCTION MOD(WS-B, 256)
     IF WS-B >= 128
         SUBTRACT 256 FROM WS-B
     END-IF
     MOVE WS-B TO L-O(2)
     COMPUTE L-O(1) = FUNCTION MOD(WS-B, 256) * 16777216 + 16777215
     GOBACK.
 END PROGRAM EF9-TEXT-COLOR.
