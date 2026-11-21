*> Entity models part 7 section 9 (Dragon fireball): the camera facing quad, the pose scale, the outline pass, texture, shadow and block light level.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF7-FIREBALL-QUAD IN() OUT(four vertices x y z u v); EF7-FIREBALL-POSE IN() OUT(op count 1, code 2 scale, 2 2 2: the camera orientation quaternion is applied by the caller);
*>   EF7-FIREBALL-PASSES IN(outline colour) OUT(main pass, outline pass, outline vertex colour); EF7-FIREBALL-TEXTURE IN() path(out X(120)); EF7-FIREBALL-RENDER IN() OUT(shadow radius 0, block light level 15).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-FIREBALL-QUAD.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE -0.5 TO L-O(1)
     MOVE -0.25 TO L-O(2)
     MOVE 0 TO L-O(3) L-O(4)
     MOVE 1 TO L-O(5)
     MOVE 0.5 TO L-O(6)
     MOVE -0.25 TO L-O(7)
     MOVE 0 TO L-O(8)
     MOVE 1 TO L-O(9) L-O(10)
     MOVE 0.5 TO L-O(11)
     MOVE 0.75 TO L-O(12)
     MOVE 0 TO L-O(13)
     MOVE 1 TO L-O(14)
     MOVE 0 TO L-O(15)
     MOVE -0.5 TO L-O(16)
     MOVE 0.75 TO L-O(17)
     MOVE 0 TO L-O(18) L-O(19) L-O(20)
     GOBACK.
 END PROGRAM EF7-FIREBALL-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-FIREBALL-POSE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     MOVE 2 TO L-O(2) L-O(3) L-O(4) L-O(5)
     GOBACK.
 END PROGRAM EF7-FIREBALL-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-FIREBALL-PASSES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     MOVE 0 TO L-O(2) L-O(3)
     IF L-I(1) NOT = 0
         MOVE 1 TO L-O(2)
         MOVE L-I(1) TO L-O(3)
     END-IF
     GOBACK.
 END PROGRAM EF7-FIREBALL-PASSES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-FIREBALL-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/enderdragon/dragon_fireball.png" TO L-PATH
     GOBACK.
 END PROGRAM EF7-FIREBALL-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-FIREBALL-RENDER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     MOVE 15 TO L-O(2)
     GOBACK.
 END PROGRAM EF7-FIREBALL-RENDER.

