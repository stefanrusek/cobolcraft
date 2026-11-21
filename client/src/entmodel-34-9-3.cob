*> Entity models part 9, section 3 minecarts (docs/protocol/34-entity-models-9-non-living-entities.md):
*>   EF9-M-MINECART model (3.1: five parts, texture 64 x 32, shared by the seven minecart layers);
*>   EF9-MINECART-OFFSET IN(entity id) OUT(1 to 3 the shifts x, y, z in blocks, 4 the low 27 bits of offsetSeed): 3.2 step 4 and the submit's step 2: the three
*>     3-bit fields of offsetSeed at shifts 16, 20 and 24 depend on the low 27 bits only, so the 64-bit wrapping arithmetic is done modulo 2 ** 27;
*>   EF9-MINECART-OPS IN(1 yRot deg, 2 xRot deg, 3 hurtTime, 4 hurtDir, 5 damageTime, 6 to 8 the shift) OUT(ops: count, then code and three values per op;
*>     1 translate, 2 scale, 3 rotate Y degrees, 5 rotate X, 7 rotate Z): the submit of 3.2 for the new movement behaviour (steps 2, 3, 4 and 6; the
*>     hurt tilt only while hurtTime > 0; step 5 the display block is EF9-MINECART-CONTENTS);
*>   EF9-MINECART-CONTENTS IN(1 displayOffset) OUT(ops of step 5: scale 0.75, translate (-0.5, (displayOffset - 8) / 16, 0.5), rotate Y 90);
*>   EF9-MINECART-CULL IN(1 displayOffset, 2 display state is not air) OUT(1 the box's growth toward +y);
*>   EF9-MINECART-DISPLAY key(X(24)) block(out X(24), spaces for air) offset(out BINARY-LONG default display offset);
*>   EF9-MINECART-PASSENGER IN(1 the passenger is a villager or a wandering trader) OUT(1 to 3 the attachment point);
*>   EF9-TNT-SWELL IN(f) OUT(swell(f)); EF9-TNT-LIT IN(f) OUT(1 or 0): 13.2 (also the TNT minecart's contents);
*>   EF9-TNT-CART-OPS IN(f) OUT(ops of the TNT minecart's contents: nothing for f <= -1 or f >= 10, else translate (-a x 0.5, 0, -a x 0.5), scale 1 + a).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-M-MINECART.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P bottom root 0 4 0 1.5707964 0 0".
    05 FILLER PIC X(100) VALUE "C bottom 0 10 -10 -8 -1 20 16 2 0 0".
    05 FILLER PIC X(100) VALUE "P front root -9 4 0 0 4.712389 0".
    05 FILLER PIC X(100) VALUE "C front 0 0 -8 -9 -1 16 8 2 0 0".
    05 FILLER PIC X(100) VALUE "P back root 9 4 0 0 1.5707964 0".
    05 FILLER PIC X(100) VALUE "C back 0 0 -8 -9 -1 16 8 2 0 0".
    05 FILLER PIC X(100) VALUE "P left root 0 4 -7 0 3.1415927 0".
    05 FILLER PIC X(100) VALUE "C left 0 0 -8 -9 -1 16 8 2 0 0".
    05 FILLER PIC X(100) VALUE "P right root 0 4 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C right 0 0 -8 -9 -1 16 8 2 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 70 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 10.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF9-M-MINECART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-MINECART-OFFSET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M27                 BINARY-DOUBLE VALUE 134217728.
 01 WS-K27                 BINARY-DOUBLE VALUE 97199825.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-S                   BINARY-DOUBLE.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-A
     COMPUTE WS-S = WS-A * 493286711
     COMPUTE WS-S = FUNCTION MOD(WS-S, WS-M27)
     COMPUTE WS-T = WS-S * WS-S
     COMPUTE WS-T = FUNCTION MOD(WS-T, WS-M27)
     COMPUTE WS-T = WS-T * WS-K27
     COMPUTE WS-T = FUNCTION MOD(WS-T, WS-M27)
     COMPUTE WS-Q = WS-S * 98761
     COMPUTE WS-Q = FUNCTION MOD(WS-Q, WS-M27)
     COMPUTE WS-SEED = FUNCTION MOD(WS-T + WS-Q, WS-M27)
     MOVE WS-SEED TO L-O(4)
     MOVE 65536 TO WS-Q
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         COMPUTE WS-T = WS-SEED / WS-Q
         COMPUTE WS-F = FUNCTION MOD(WS-T, 8)
         COMPUTE L-O(WS-K) = ((WS-F + 0.5) / 8 - 0.5) * 0.004
         COMPUTE WS-Q = WS-Q * 16
     END-PERFORM
     GOBACK.
 END PROGRAM EF9-MINECART-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-MINECART-OPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(2)
     MOVE L-I(6) TO L-O(3)
     MOVE L-I(7) TO L-O(4)
     MOVE L-I(8) TO L-O(5)
     MOVE 3 TO L-O(6)
     MOVE L-I(1) TO L-O(7)
     MOVE 0 TO L-O(8) L-O(9)
     MOVE 7 TO L-O(10)
     COMPUTE L-O(11) = 0 - L-I(2)
     MOVE 0 TO L-O(12) L-O(13)
     MOVE 1 TO L-O(14)
     MOVE 0 TO L-O(15) L-O(17)
     MOVE 0.375 TO L-O(16)
     MOVE 4 TO WS-N
     IF L-I(3) > 0
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 5 TO L-O(WS-K)
         COMPUTE L-O(WS-K + 1) = FUNCTION SIN(L-I(3)) * L-I(3) * L-I(5) / 10 * L-I(4)
         MOVE 0 TO L-O(WS-K + 2) L-O(WS-K + 3)
     END-IF
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 2 TO L-O(WS-K)
     MOVE -1 TO L-O(WS-K + 1) L-O(WS-K + 2)
     MOVE 1 TO L-O(WS-K + 3)
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EF9-MINECART-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-MINECART-CONTENTS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 3 TO L-O(1)
     MOVE 2 TO L-O(2)
     MOVE 0.75 TO L-O(3) L-O(4) L-O(5)
     MOVE 1 TO L-O(6)
     MOVE -0.5 TO L-O(7)
     COMPUTE L-O(8) = (L-I(1) - 8) / 16
     MOVE 0.5 TO L-O(9)
     MOVE 3 TO L-O(10)
     MOVE 90 TO L-O(11)
     MOVE 0 TO L-O(12) L-O(13)
     GOBACK.
 END PROGRAM EF9-MINECART-CONTENTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-MINECART-CULL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(2) NOT = 0
         COMPUTE L-O(1) = L-I(1) * 0.75 / 16
     END-IF
     GOBACK.
 END PROGRAM EF9-MINECART-CULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-MINECART-DISPLAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-BLOCK                PIC X(24).
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-BLOCK L-OFFSET.
     MOVE SPACES TO L-BLOCK
     MOVE 6 TO L-OFFSET
     EVALUATE L-KEY
         WHEN "chest_minecart"
             MOVE "chest" TO L-BLOCK
             MOVE 8 TO L-OFFSET
         WHEN "furnace_minecart"
             MOVE "furnace" TO L-BLOCK
         WHEN "hopper_minecart"
             MOVE "hopper" TO L-BLOCK
             MOVE 1 TO L-OFFSET
         WHEN "spawner_minecart"
             MOVE "spawner" TO L-BLOCK
         WHEN "command_block_minecart"
             MOVE "command_block" TO L-BLOCK
         WHEN "tnt_minecart"
             MOVE "tnt" TO L-BLOCK
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-MINECART-DISPLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-MINECART-PASSENGER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     IF L-I(1) = 0
         MOVE 0.1875 TO L-O(2)
     END-IF
     GOBACK.
 END PROGRAM EF9-MINECART-PASSENGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-TNT-SWELL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-S = FUNCTION MAX(0, FUNCTION MIN(1, 1 - L-I(1) / 10))
     COMPUTE WS-S = WS-S * WS-S
     COMPUTE WS-S = WS-S * WS-S
     COMPUTE L-O(1) = WS-S * 0.3
     GOBACK.
 END PROGRAM EF9-TNT-SWELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-TNT-LIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) >= 0
         COMPUTE WS-Q = L-I(1) / 5
         IF FUNCTION MOD(WS-Q, 2) = 0
             MOVE 1 TO L-O(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF9-TNT-LIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-TNT-CART-OPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 32 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) > -1 AND L-I(1) < 10
         MOVE L-I(1) TO WS-IV(1)
         CALL "EF9-TNT-SWELL" USING WS-I WS-O
         MOVE WS-OV(1) TO WS-A
         MOVE 2 TO L-O(1)
         MOVE 1 TO L-O(2)
         COMPUTE L-O(3) = 0 - WS-A * 0.5
         MOVE 0 TO L-O(4)
         COMPUTE L-O(5) = 0 - WS-A * 0.5
         MOVE 2 TO L-O(6)
         COMPUTE L-O(7) = 1 + WS-A
         MOVE L-O(7) TO L-O(8) L-O(9)
     END-IF
     GOBACK.
 END PROGRAM EF9-TNT-CART-OPS.
