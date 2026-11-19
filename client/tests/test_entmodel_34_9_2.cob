*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 2 (conventions): Mth.sin and Mth.cos through the 65536-entry table (the argument quantised to 2 pi / 65536, negative arguments wrapping), the packed light coordinates
*> (15728880, 15728850), the overlay texture (u(f), v(hurt), pack, the alpha of the white texels), the texture scale of addBox, PartPose.scaled and withScale.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-PFX                 PIC X(100).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.
 01 WS-LAYER              PIC X(32).
 01 WS-OK                 BINARY-LONG.
 01 WS-PARTS              BINARY-LONG.
 01 WS-CUBES              BINARY-LONG.
 01 WS-P                  BINARY-LONG.
 01 WS-PN                 PIC X(24).
 COPY EMCHKW.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 01 WS-X                 FLOAT-LONG.
 01 WS-R2                FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "acceptance US15 34-9§2 conventions" TO WS-PFX
     MOVE 0 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(0)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(0)" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(1)" TO WS-NAME
     MOVE 0.841451406 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(1)" TO WS-NAME
     MOVE 0.540332854 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(-1)" TO WS-NAME
     MOVE -0.841451406 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(-1)" TO WS-NAME
     MOVE 0.540252149 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(0.5)" TO WS-NAME
     MOVE 0.479409635 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(0.5)" TO WS-NAME
     MOVE 0.877591252 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.1415927 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(3.1415927)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(3.1415927)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE -3.1415927 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(-3.1415927)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(-3.1415927)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE 6.2831853 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(6.2831853)" TO WS-NAME
     MOVE -0.000095874 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(6.2831853)" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE 100.25 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(100.25)" TO WS-NAME
     MOVE -0.277322441 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(100.25)" TO WS-NAME
     MOVE 0.960776925 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE -77.7 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(-77.7)" TO WS-NAME
     MOVE -0.744545996 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(-77.7)" TO WS-NAME
     MOVE -0.667571187 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.00001 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(1e-05)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(1e-05)" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE 12345.678 TO WS-X
     CALL "PENG-MTH-SIN" USING WS-X WS-R2
     MOVE "2 Mth.sin(12345.678)" TO WS-NAME
     MOVE -0.704117596 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(12345.678)" TO WS-NAME
     MOVE 0.710083365 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-X
     CALL "EF9-MTH-COS" USING WS-X WS-R2
     MOVE "2 Mth.cos(0) is 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     CALL "EF9-LIGHT-PACK" USING WS-IN WS-OUT
     MOVE "2.5 pack(block 15, sky 15)" TO WS-NAME
     MOVE 15728880 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15728880 TO WS-IV(1)
     CALL "EF9-LIGHT-UNPACK" USING WS-IN WS-OUT
     MOVE "2.5 unpack of block 15, sky 15 [1]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 unpack of block 15, sky 15 [2]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 13 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     CALL "EF9-LIGHT-PACK" USING WS-IN WS-OUT
     MOVE "2.5 pack(block 13, sky 15)" TO WS-NAME
     MOVE 15728848 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15728848 TO WS-IV(1)
     CALL "EF9-LIGHT-UNPACK" USING WS-IN WS-OUT
     MOVE "2.5 unpack of block 13, sky 15 [1]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 unpack of block 13, sky 15 [2]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-LIGHT-PACK" USING WS-IN WS-OUT
     MOVE "2.5 pack(block 0, sky 0)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-LIGHT-UNPACK" USING WS-IN WS-OUT
     MOVE "2.5 unpack of block 0, sky 0 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 unpack of block 0, sky 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     CALL "EF9-LIGHT-PACK" USING WS-IN WS-OUT
     MOVE "2.5 pack(block 7, sky 3)" TO WS-NAME
     MOVE 3145840 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3145840 TO WS-IV(1)
     CALL "EF9-LIGHT-UNPACK" USING WS-IN WS-OUT
     MOVE "2.5 unpack of block 7, sky 3 [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 unpack of block 7, sky 3 [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15728850 TO WS-IV(1)
     CALL "EF9-LIGHT-UNPACK" USING WS-IN WS-OUT
     MOVE "2.5 15728850 is sky 15, block field 13 [1]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 15728850 is sky 15, block field 13 [2]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-OVERLAY" USING WS-IN WS-OUT
     MOVE "2.5 overlay f 0 hurt 0 (u, v, pack) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 0 hurt 0 (u, v, pack) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 0 hurt 0 (u, v, pack) [3]" TO WS-NAME
     MOVE 655360 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-OVERLAY" USING WS-IN WS-OUT
     MOVE "2.5 overlay f 1.0 hurt 0 (u, v, pack) [1]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 1.0 hurt 0 (u, v, pack) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 1.0 hurt 0 (u, v, pack) [3]" TO WS-NAME
     MOVE 655375 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-OVERLAY" USING WS-IN WS-OUT
     MOVE "2.5 overlay f 0.5 hurt 1 (u, v, pack) [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 0.5 hurt 1 (u, v, pack) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 0.5 hurt 1 (u, v, pack) [3]" TO WS-NAME
     MOVE 196615 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.99 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-OVERLAY" USING WS-IN WS-OUT
     MOVE "2.5 overlay f 0.99 hurt 0 (u, v, pack) [1]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 0.99 hurt 0 (u, v, pack) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 0.99 hurt 0 (u, v, pack) [3]" TO WS-NAME
     MOVE 655374 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.25 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-OVERLAY" USING WS-IN WS-OUT
     MOVE "2.5 overlay f 0.25 hurt 1 (u, v, pack) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 0.25 hurt 1 (u, v, pack) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 overlay f 0.25 hurt 1 (u, v, pack) [3]" TO WS-NAME
     MOVE 196611 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-OVERLAY" USING WS-IN WS-OUT
     MOVE "2.5 the TNT flash is pack(15, 10) [1]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 the TNT flash is pack(15, 10) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.5 the TNT flash is pack(15, 10) [3]" TO WS-NAME
     MOVE 655375 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 0" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 1" TO WS-NAME
     MOVE 242 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 2" TO WS-NAME
     MOVE 229 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 3" TO WS-NAME
     MOVE 216 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 4" TO WS-NAME
     MOVE 204 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 5" TO WS-NAME
     MOVE 191 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 6" TO WS-NAME
     MOVE 178 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 7" TO WS-NAME
     MOVE 165 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 8" TO WS-NAME
     MOVE 153 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 9" TO WS-NAME
     MOVE 140 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 10" TO WS-NAME
     MOVE 127 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 11 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 11" TO WS-NAME
     MOVE 114 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 12 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 12" TO WS-NAME
     MOVE 101 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 13 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 13" TO WS-NAME
     MOVE 89 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 14 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 14" TO WS-NAME
     MOVE 76 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 alpha of the white texel in column 15" TO WS-NAME
     MOVE 63 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 pixel (15, 10) has alpha 63" TO WS-NAME
     MOVE 63 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-OVERLAY-ALPHA" USING WS-IN WS-OUT
     MOVE "2.5 NO_OVERLAY is pixel (0, 10), alpha 255" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 32 TO WS-IV(2)
     MOVE 0.8 TO WS-IV(3)
     CALL "EF9-UV-SCALE" USING WS-IN WS-OUT
     MOVE "2.2 texture scale: pixel 0 of 32 at v scale 0.8" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 32 TO WS-IV(2)
     MOVE 0.8 TO WS-IV(3)
     CALL "EF9-UV-SCALE" USING WS-IN WS-OUT
     MOVE "2.2 texture scale: pixel 1 of 32 at v scale 0.8" TO WS-NAME
     MOVE 0.0390625 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 32 TO WS-IV(2)
     MOVE 0.8 TO WS-IV(3)
     CALL "EF9-UV-SCALE" USING WS-IN WS-OUT
     MOVE "2.2 texture scale: pixel 4 of 32 at v scale 0.8" TO WS-NAME
     MOVE 0.15625 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 32 TO WS-IV(2)
     MOVE 0.8 TO WS-IV(3)
     CALL "EF9-UV-SCALE" USING WS-IN WS-OUT
     MOVE "2.2 texture scale: pixel 5 of 32 at v scale 0.8" TO WS-NAME
     MOVE 0.1953125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 32 TO WS-IV(2)
     MOVE 0.8 TO WS-IV(3)
     CALL "EF9-UV-SCALE" USING WS-IN WS-OUT
     MOVE "2.2 texture scale: pixel 16 of 32 at v scale 0.8" TO WS-NAME
     MOVE 0.625 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 32 TO WS-IV(1)
     MOVE 32 TO WS-IV(2)
     MOVE 0.8 TO WS-IV(3)
     CALL "EF9-UV-SCALE" USING WS-IN WS-OUT
     MOVE "2.2 texture scale: pixel 32 of 32 at v scale 0.8" TO WS-NAME
     MOVE 1.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 32 TO WS-IV(2)
     MOVE 0.8 TO WS-IV(3)
     CALL "EF9-UV-SCALE" USING WS-IN WS-OUT
     MOVE "2.2 the arrow cross plane: row 4 of 25.6 is 0.15625" TO WS-NAME
     MOVE 0.15625 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE 64 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-UV-SCALE" USING WS-IN WS-OUT
     MOVE "2.2 scale 1 divides by the layer size" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -11 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0.9 TO WS-IV(7)
     CALL "EF9-POSE-SCALED" USING WS-IN WS-OUT
     MOVE "2.1 PartPose.scaled(0.9) multiplies offset and scale [1]" TO WS-NAME
     MOVE -9.9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 PartPose.scaled(0.9) multiplies offset and scale [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 PartPose.scaled(0.9) multiplies offset and scale [3]" TO WS-NAME
     MOVE 3.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 PartPose.scaled(0.9) multiplies offset and scale [4]" TO WS-NAME
     MOVE 0.9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 PartPose.scaled(0.9) multiplies offset and scale [5]" TO WS-NAME
     MOVE 0.9 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 PartPose.scaled(0.9) multiplies offset and scale [6]" TO WS-NAME
     MOVE 0.9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.75 TO WS-IV(7)
     CALL "EF9-POSE-WITH-SCALE" USING WS-IN WS-OUT
     MOVE "2.1 withScale(s) keeps offset and rotation and sets all three scales [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 withScale(s) keeps offset and rotation and sets all three scales [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 withScale(s) keeps offset and rotation and sets all three scales [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 withScale(s) keeps offset and rotation and sets all three scales [4]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 withScale(s) keeps offset and rotation and sets all three scales [5]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 withScale(s) keeps offset and rotation and sets all three scales [6]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 withScale(s) keeps offset and rotation and sets all three scales [7]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 withScale(s) keeps offset and rotation and sets all three scales [8]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 withScale(s) keeps offset and rotation and sets all three scales [9]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-PFX) ": " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-PFX) ": " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-2.
