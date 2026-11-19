*> Entity models part 8, renderer facts of the dolphin (docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md 3.2, 3.3) that are not mesh rows.
*>   EF8-DOLPHIN-MOVING IN(delta movement x, z) OUT(1 when the horizontal squared length is above 1.0E-7: isMoving);
*>   EF8-DOLPHIN-CARRY IN(xRot degrees) OUT(x, y, z of the translate of DolphinCarryingItemLayer, p = |xRot| / 60).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-DOLPHIN-MOVING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-LEN = L-I(1) * L-I(1) + L-I(2) * L-I(2)
     MOVE 0 TO L-O(1)
     IF WS-LEN > 0.0000001
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF8-DOLPHIN-MOVING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-DOLPHIN-CARRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-P = FUNCTION ABS(L-I(1)) / 60
     MOVE 0 TO L-O(1)
     IF L-I(1) < 0
         COMPUTE L-O(2) = 1 - 0.5 * WS-P
         COMPUTE L-O(3) = -1 + 0.5 * WS-P
     ELSE
         COMPUTE L-O(2) = 1 + 0.8 * WS-P
         COMPUTE L-O(3) = -1 + 0.2 * WS-P
     END-IF
     GOBACK.
 END PROGRAM EF8-DOLPHIN-CARRY.

*> Fish facts of 34-8 section 5 that are not mesh rows:
*>   EF8-SALMON-SIZE IN(variant id) OUT(0 small, 1 medium, 2 large): the id map is continuous with out-of-bounds strategy CLAMP (5.2);
*>   EF8-PUFFER-MODEL IN(puff state) OUT(0 small, 1 medium, 2 big for any other value) and EF8-PUFFER-SHADOW IN(puff state) OUT(0.1 + 0.1 x puff state) (5.3);
*>   EF8-TROPICAL-DECODE IN(packed variant) OUT(1 pattern ordinal 0 to 11, 2 base 0 small or 1 large, 3 pattern index 0 to 5, 4 base colour id, 5 pattern colour id, 6 base RGB, 7 pattern RGB) (5.4):
*>   Pattern.byId is a sparse map of the 12 packed ids (low 16 bits) with default kob, DyeColor.byId a continuous map whose out-of-bounds strategy is ZERO (white).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-SALMON-SIZE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     EVALUATE TRUE
         WHEN L-I(1) < 0
             MOVE 0 TO L-O(1)
         WHEN L-I(1) > 2
             MOVE 2 TO L-O(1)
         WHEN OTHER
             MOVE L-I(1) TO L-O(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF8-SALMON-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-PUFFER-MODEL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     EVALUATE L-I(1)
         WHEN 0
             MOVE 0 TO L-O(1)
         WHEN 1
             MOVE 1 TO L-O(1)
         WHEN OTHER
             MOVE 2 TO L-O(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF8-PUFFER-MODEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-PUFFER-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = 0.1 + 0.1 * L-I(1)
     GOBACK.
 END PROGRAM EF8-PUFFER-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-TROPICAL-DECODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DYE-DATA.
    05 FILLER PIC 9(8) VALUE 16383998.
    05 FILLER PIC 9(8) VALUE 16351261.
    05 FILLER PIC 9(8) VALUE 13061821.
    05 FILLER PIC 9(8) VALUE 3847130.
    05 FILLER PIC 9(8) VALUE 16701501.
    05 FILLER PIC 9(8) VALUE 8439583.
    05 FILLER PIC 9(8) VALUE 15961002.
    05 FILLER PIC 9(8) VALUE 4673362.
    05 FILLER PIC 9(8) VALUE 10329495.
    05 FILLER PIC 9(8) VALUE 1481884.
    05 FILLER PIC 9(8) VALUE 8991416.
    05 FILLER PIC 9(8) VALUE 3949738.
    05 FILLER PIC 9(8) VALUE 8606770.
    05 FILLER PIC 9(8) VALUE 6192150.
    05 FILLER PIC 9(8) VALUE 11546150.
    05 FILLER PIC 9(8) VALUE 1908001.
 01 WS-DYE REDEFINES WS-DYE-DATA.
    05 WS-DF               PIC 9(8) OCCURS 16 TIMES.
 01 WS-PACKED              BINARY-DOUBLE.
 01 WS-LOW                 BINARY-LONG.
 01 WS-BASE-COLOUR         BINARY-LONG.
 01 WS-PATTERN-COLOUR      BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-PACKED = L-I(1)
     COMPUTE WS-LOW = FUNCTION MOD(WS-PACKED, 65536)
     COMPUTE WS-BASE-COLOUR = FUNCTION MOD(FUNCTION INTEGER(WS-PACKED / 65536), 256)
     COMPUTE WS-PATTERN-COLOUR = FUNCTION MOD(FUNCTION INTEGER(WS-PACKED / 16777216), 256)
     IF WS-BASE-COLOUR > 15
         MOVE 0 TO WS-BASE-COLOUR
     END-IF
     IF WS-PATTERN-COLOUR > 15
         MOVE 0 TO WS-PATTERN-COLOUR
     END-IF
*>   The twelve packed ids are base | (index << 8); anything else is kob (small, index 0).
     COMPUTE WS-KIND = FUNCTION MOD(WS-LOW, 256)
     COMPUTE WS-INDEX = FUNCTION INTEGER(WS-LOW / 256)
     IF WS-KIND > 1 OR WS-INDEX > 5
         MOVE 0 TO WS-KIND WS-INDEX
     END-IF
     COMPUTE L-O(1) = WS-KIND * 6 + WS-INDEX
     MOVE WS-KIND TO L-O(2)
     MOVE WS-INDEX TO L-O(3)
     MOVE WS-BASE-COLOUR TO L-O(4)
     MOVE WS-PATTERN-COLOUR TO L-O(5)
     MOVE WS-DF(WS-BASE-COLOUR + 1) TO L-O(6)
     MOVE WS-DF(WS-PATTERN-COLOUR + 1) TO L-O(7)
     GOBACK.
 END PROGRAM EF8-TROPICAL-DECODE.

*> Boats of 34-8 section 7 that are not mesh rows:
*>   EF8-M-BOAT-PATCH USING model: the water patch layer boat#water_patch (7.1, texture 0 x 0), a depth-only mask that is never textured;
*>   EF8-BOAT-SEAT IN(raft 1 or boat 0, chest 1 or 0, passenger count, index of this passenger, passenger is an animal) OUT(x, y, z of the seat before the rotation about Y,
*>   maximum passengers) (7.5); EF8-BOAT-LEASH IN(box width, box height) OUT(x, y, z of the leash offset) (7.5);
*>   EF8-BOAT-PATCH-DRAWN IN(raft, under water) OUT(1 when the water patch is submitted: a boat that is not under water; a raft has none) (7.4 step 7).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-BOAT-PATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P water_patch root 0 -3 1 1.5707964 0 0".
    05 FILLER PIC X(100) VALUE "C water_patch 0 0 -14 -9 -3 28 16 3 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 78 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 2.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 0 TO MM-TEXW
     MOVE 0 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-BOAT-PATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BOAT-SEAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-XO                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(1) = 1
         COMPUTE L-O(2) = 0.5625 * 0.8888889
     ELSE
         COMPUTE L-O(2) = 0.5625 / 3
     END-IF
     MOVE 0 TO WS-XO
     IF L-I(3) <= 1
         IF L-I(2) = 1
             MOVE 0.15 TO WS-XO
         END-IF
     ELSE
         IF L-I(4) = 0
             MOVE 0.2 TO WS-XO
         ELSE
             MOVE -0.6 TO WS-XO
         END-IF
         IF L-I(5) = 1
             ADD 0.2 TO WS-XO
         END-IF
     END-IF
     MOVE 0 TO L-O(1)
     MOVE WS-XO TO L-O(3)
     MOVE 2 TO L-O(4)
     IF L-I(2) = 1
         MOVE 1 TO L-O(4)
     END-IF
     GOBACK.
 END PROGRAM EF8-BOAT-SEAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BOAT-LEASH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     COMPUTE L-O(2) = 0.88 * L-I(2)
     COMPUTE L-O(3) = 0.64 * L-I(1)
     GOBACK.
 END PROGRAM EF8-BOAT-LEASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BOAT-PATCH-DRAWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) = 0 AND L-I(2) = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF8-BOAT-PATCH-DRAWN.
