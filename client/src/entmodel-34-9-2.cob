*> Entity models part 9, section 2 conventions (docs/protocol/34-entity-models-9-non-living-entities.md); Mth.sin is PENG-MTH-SIN and Mth.cos EF9-MTH-COS (entmodel-34-9-7.cob):
*>   EF9-LIGHT-PACK IN(1 block, 2 sky) OUT(1 (block << 4) | (sky << 20)); EF9-LIGHT-UNPACK IN(1 packed) OUT(1 block = (l >> 4) and 15, 2 sky = (l >> 20) and 15): 2.5;
*>   EF9-OVERLAY IN(1 f, 2 hurt) OUT(1 u(f) = int(f x 15), 2 v(hurt) = 3 if hurt else 10, 3 pack(u, v) = u | (v << 16)): 2.5; EF9-OVERLAY-ALPHA IN(1 column u of a row 8 to 15) OUT(1 int((1 - (u / 15) x 0.75) x 255));
*>   EF9-UV-SCALE IN(1 pixel coordinate, 2 the layer's texture size, 3 the cuboid's texture scale) OUT(1 pixel / (size x scale)): 2.2 item 1 (addBox with uScale and vScale);
*>   EF9-POSE-SCALED IN(1 to 3 offset, 4 to 6 scale, 7 s) OUT(1 to 3 offset x s, 4 to 6 scale x s): PartPose.scaled(s); EF9-POSE-WITH-SCALE IN(1 to 3 offset, 4 to 6 rotation, 7 s) OUT(1 to 3 offset, 4 to 6 rotation kept, 7 to 9 the scale s).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-LIGHT-PACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * 16 + L-I(2) * 1048576
     GOBACK.
 END PROGRAM EF9-LIGHT-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-LIGHT-UNPACK.
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
     MOVE L-I(1) TO WS-L
     COMPUTE WS-Q = WS-L / 16
     COMPUTE L-O(1) = FUNCTION MOD(WS-Q, 16)
     COMPUTE WS-Q = WS-L / 1048576
     COMPUTE L-O(2) = FUNCTION MOD(WS-Q, 16)
     GOBACK.
 END PROGRAM EF9-LIGHT-UNPACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-OVERLAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION INTEGER-PART(L-I(1) * 15)
     MOVE 10 TO L-O(2)
     IF L-I(2) NOT = 0
         MOVE 3 TO L-O(2)
     END-IF
     COMPUTE L-O(3) = L-O(1) + L-O(2) * 65536
     GOBACK.
 END PROGRAM EF9-OVERLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-OVERLAY-ALPHA.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION INTEGER-PART((1 - (L-I(1) / 15) * 0.75) * 255)
     GOBACK.
 END PROGRAM EF9-OVERLAY-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-UV-SCALE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) / (L-I(2) * L-I(3))
     GOBACK.
 END PROGRAM EF9-UV-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-POSE-SCALED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * L-I(7)
     COMPUTE L-O(2) = L-I(2) * L-I(7)
     COMPUTE L-O(3) = L-I(3) * L-I(7)
     COMPUTE L-O(4) = L-I(4) * L-I(7)
     COMPUTE L-O(5) = L-I(5) * L-I(7)
     COMPUTE L-O(6) = L-I(6) * L-I(7)
     GOBACK.
 END PROGRAM EF9-POSE-SCALED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-POSE-WITH-SCALE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO L-O(1)
     MOVE L-I(2) TO L-O(2)
     MOVE L-I(3) TO L-O(3)
     MOVE L-I(4) TO L-O(4)
     MOVE L-I(5) TO L-O(5)
     MOVE L-I(6) TO L-O(6)
     MOVE L-I(7) TO L-O(7) L-O(8) L-O(9)
     GOBACK.
 END PROGRAM EF9-POSE-WITH-SCALE.
