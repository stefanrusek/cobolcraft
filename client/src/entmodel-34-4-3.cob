*> Entity models part 4 section 3 (Mooshroom): the layers are the cow meshes of section 2 (3.1), the variant, texture and mushroom layer rules (3.1, 3.2).
*> Entry points for the integrator (inputs): EF4-MOOSHROOM-VARIANT IN(id) OUT(ordinal, 0 red 1 brown, ids clamp); EF4-MOOSHROOM-TEXTURE IN(ordinal, baby) path(out X(120));
*>   EF4-MOOSHROOM-BLOCK IN(ordinal) block-name(out X(120)); EF4-MUSHROOM-DRAW IN(baby, model not empty, invisible, glowing) OUT(draw, outline only);
*>   EF4-MUSHROOM-OPS IN(copy 1..3) OUT(count, then per operation: code 1 translate 2 rotate about Y in degrees 3 scale 4 the head part's own transform, three values). Setup: EF4-COW-ANIM.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-MOOSHROOM-VARIANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO L-O(1)
     IF L-I(1) < 0
         MOVE 0 TO L-O(1)
     END-IF
     IF L-I(1) > 1
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF4-MOOSHROOM-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-MOOSHROOM-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     IF L-I(1) = 0
         MOVE "textures/entity/cow/mooshroom_red" TO L-PATH
     ELSE
         MOVE "textures/entity/cow/mooshroom_brown" TO L-PATH
     END-IF
     IF L-I(2) NOT = 0
         STRING FUNCTION TRIM(L-PATH) "_baby.png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING FUNCTION TRIM(L-PATH) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-MOOSHROOM-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-MOOSHROOM-BLOCK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-NAME                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-NAME.
     MOVE "red_mushroom_block" TO L-NAME
     IF L-I(1) NOT = 0
         MOVE "brown_mushroom_block" TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM EF4-MOOSHROOM-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-MUSHROOM-DRAW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     IF L-I(1) = 0 AND L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
         IF L-I(3) NOT = 0 AND L-I(4) NOT = 0
             MOVE 1 TO L-O(2)
         END-IF
         IF L-I(3) NOT = 0 AND L-I(4) = 0
             MOVE 0 TO L-O(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF4-MUSHROOM-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-MUSHROOM-OPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER PIC X(60) VALUE "1 0.2 -0.35 0.5".
    05 FILLER PIC X(60) VALUE "2 -48 0 0".
    05 FILLER PIC X(60) VALUE "3 -1 -1 1".
    05 FILLER PIC X(60) VALUE "1 -0.5 -0.5 -0.5".
    05 FILLER PIC X(60) VALUE "1 0.2 -0.35 0.5".
    05 FILLER PIC X(60) VALUE "2 42 0 0".
    05 FILLER PIC X(60) VALUE "1 0.1 0 -0.6".
    05 FILLER PIC X(60) VALUE "2 -48 0 0".
    05 FILLER PIC X(60) VALUE "3 -1 -1 1".
    05 FILLER PIC X(60) VALUE "1 -0.5 -0.5 -0.5".
    05 FILLER PIC X(60) VALUE "4 0 0 0".
    05 FILLER PIC X(60) VALUE "1 0 -0.7 -0.2".
    05 FILLER PIC X(60) VALUE "2 -78 0 0".
    05 FILLER PIC X(60) VALUE "3 -1 -1 1".
    05 FILLER PIC X(60) VALUE "1 -0.5 -0.5 -0.5".
 01 WS-OPS-R REDEFINES WS-OPS.
    05 WS-OP               PIC X(60) OCCURS 15 TIMES.
 01 WS-FIRST               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   PIC X(12).
 01 WS-B                   PIC X(12).
 01 WS-C                   PIC X(12).
 01 WS-D                   PIC X(12).
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     EVALUATE L-I(1)
         WHEN 1 MOVE 1 TO WS-FIRST MOVE 4 TO WS-N
         WHEN 2 MOVE 5 TO WS-FIRST MOVE 6 TO WS-N
         WHEN 3 MOVE 11 TO WS-FIRST MOVE 5 TO WS-N
         WHEN OTHER GOBACK
     END-EVALUATE
     MOVE WS-N TO L-O(1)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
         UNSTRING WS-OP(WS-FIRST + WS-K - 1) DELIMITED BY ALL SPACE INTO WS-A WS-B WS-C WS-D
         COMPUTE L-O(2 + (WS-K - 1) * 4) = FUNCTION NUMVAL(WS-A)
         COMPUTE L-O(3 + (WS-K - 1) * 4) = FUNCTION NUMVAL(WS-B)
         COMPUTE L-O(4 + (WS-K - 1) * 4) = FUNCTION NUMVAL(WS-C)
         COMPUTE L-O(5 + (WS-K - 1) * 4) = FUNCTION NUMVAL(WS-D)
     END-PERFORM
     GOBACK.
 END PROGRAM EF4-MUSHROOM-OPS.
