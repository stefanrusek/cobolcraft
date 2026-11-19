*> Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 4 (axolotl): 4.1 the adult mesh (21 boxes of parts including the six grown boxes G = 0.001), 4.3 the baby mesh (texture 32 x 32, the part root is baby_root here),
*> 4.4 the variant textures (ids 0 to 4, an id outside the range gives lucy). The adult setupAnim and the binary animators (4.2, 4.5) and the seven baby keyframe animations (4.4, Appendix A.1) are proved by test_entmodel_axolotl of lane p70e (T28700, T28701).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-8-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
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
 01 WS-X60               PIC X(60).
 PROCEDURE DIVISION.
     MOVE "AXOLOTL" TO WS-LAYER
     CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer AXOLOTL is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-8§4 Axolotl 4 AXOLOTL" TO CK-PREFIX
     MOVE "P body root 0 19.5 5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 11 -4 -2 -9 8 4 10 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 2 17 0 -3 -8 0 5 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head body 0 0 -9 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 1 -4 -3 -5 8 5 5 0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P top_gills head 0 -3 -1 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C top_gills 3 37 -4 -3 0 8 3 0 0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_gills head -4 0 -1 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_gills 0 40 -3 -5 0 3 7 0 0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_gills head 4 0 -1 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_gills 11 40 0 -5 0 3 7 0 0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg body -3.5 1 -1 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 2 13 -2 0 0 3 5 0 0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg body 3.5 1 -1 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 2 13 -1 0 0 3 5 0 0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg body -3.5 1 -8 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 2 13 -2 0 0 3 5 0 0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg body 3.5 1 -8 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 2 13 -1 0 0 3 5 0 0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 0 1 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 2 19 0 -3 0 0 5 12 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "4 AXOLOTL: parts below the root" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 AXOLOTL: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 AXOLOTL: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 AXOLOTL: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "AXOLOTL_BABY" TO WS-LAYER
     CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer AXOLOTL_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-8§4 Axolotl 4 AXOLOTL_BABY" TO CK-PREFIX
     MOVE "P baby_root root 0 24 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body baby_root 0 -1.25 1.75 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 0 -2 -0.75 -2.75 4 2 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 12 0 -1.75 -2.75 0 3 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg body -2 0.25 -1.25 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 20 16 -3 0 -0.5 3 0 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg body -2 0.25 1.75 0 1.5708 1.5708" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg_r1 right_hind_leg 0 0 0 -1.5708 0 1.5708" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg_r1 20 14 0 0 -0.5 3 0 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg body 2 0.25 -1.25 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 20 13 0 0 -0.5 3 0 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg body 2 0.25 1.75 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 20 14 0 0 -0.5 3 0 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -0.25 3.25 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 10 9 0 -1.5 -1 0 3 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head body 0 0.25 -2.75 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 8 -3 -2 -4 6 3 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_gills head 3 -0.5 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_gills 20 8 0 -3.5 0 3 5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_gills head -3 -0.5 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_gills 20 3 -3 -3.5 0 3 5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P top_gills head 0 -2 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C top_gills 20 0 -3 -3 0 6 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "4 AXOLOTL_BABY: parts below the root" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 AXOLOTL_BABY: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 AXOLOTL_BABY: texture width" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 AXOLOTL_BABY: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 1 baby 0 texture" TO WS-NAME
     MOVE "axolotl/axolotl_lucy.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 1 baby 1 texture" TO WS-NAME
     MOVE "axolotl/axolotl_lucy_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 2 baby 0 texture" TO WS-NAME
     MOVE "axolotl/axolotl_wild.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 2 baby 1 texture" TO WS-NAME
     MOVE "axolotl/axolotl_wild_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 3 baby 0 texture" TO WS-NAME
     MOVE "axolotl/axolotl_gold.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 3 baby 1 texture" TO WS-NAME
     MOVE "axolotl/axolotl_gold_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 4 baby 0 texture" TO WS-NAME
     MOVE "axolotl/axolotl_cyan.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 4 baby 1 texture" TO WS-NAME
     MOVE "axolotl/axolotl_cyan_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 5 baby 0 texture" TO WS-NAME
     MOVE "axolotl/axolotl_blue.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 5 baby 1 texture" TO WS-NAME
     MOVE "axolotl/axolotl_blue_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 9 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 9 baby 0 texture" TO WS-NAME
     MOVE "axolotl/axolotl_lucy.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 9 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 9 baby 1 texture" TO WS-NAME
     MOVE "axolotl/axolotl_lucy_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 0 baby 0 texture" TO WS-NAME
     MOVE "axolotl/axolotl_lucy.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "4.4 variant slot 0 baby 1 texture" TO WS-NAME
     MOVE "axolotl/axolotl_lucy_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-8§4 Axolotl: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-8§4 Axolotl: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-8-4.
