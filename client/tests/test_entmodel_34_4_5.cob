*> Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 5 (Sheep): 5.1 the texture paths and the undercoat and wool layer rules, 5.2 setupAnim (quadruped, head y offset, head pitch replaced),
*> 5.3 wool layers (which model, sub-order, the outline-only case), 5.4 the geometry of sheep, sheep_wool, sheep_baby (and the undercoat and baby wool ids), 5.5 the dye table (each sheep colour re-derived from the diffuse colour by
*> the formula and compared with the table), 5.6 the jeb colour cycle. Mesh rows are the tables of the document; formula values were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-4-5.
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
 PROCEDURE DIVISION.
     MOVE "SHEEP" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SHEEP is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§5 Sheep 5.4 SHEEP" TO CK-PREFIX
     MOVE "P head root 0 6 -8 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3 -4 -6 6 6 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 5 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 28 8 -4 -10 -7 8 16 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "5.4 SHEEP: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP: cuboids" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_WOOL" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SHEEP_WOOL is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§5 Sheep 5.4 SHEEP_WOOL" TO CK-PREFIX
     MOVE "P head root 0 6 -8 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3 -4 -4 6 6 6 0.6 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 5 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 28 8 -4 -10 -7 8 16 6 1.75 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 16 -2 0 -2 4 6 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 16 -2 0 -2 4 6 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 16 -2 0 -2 4 6 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 16 -2 0 -2 4 6 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "5.4 SHEEP_WOOL: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_WOOL: cuboids" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_WOOL: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_WOOL: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SHEEP_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§5 Sheep 5.4 SHEEP_BABY" TO CK-PREFIX
     MOVE "P body root 0 17 0.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 10 -3 -2 -4.5 6 4 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head root 0 15.5 -2.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -2.5 -4.5 -3.5 5 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2 19 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 23 -1 0 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2 19 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 24 12 -1 0 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2 19 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 8 23 -1 0 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2 19 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 24 5 -1 0 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "5.4 SHEEP_BABY: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_BABY: cuboids" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_BABY: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_WOOL_UNDERCOAT" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SHEEP_WOOL_UNDERCOAT is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§5 Sheep 5.4 SHEEP_WOOL_UNDERCOAT" TO CK-PREFIX
     MOVE "P head root 0 6 -8 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3 -4 -6 6 6 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 5 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 28 8 -4 -10 -7 8 16 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "5.4 SHEEP_WOOL_UNDERCOAT: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_WOOL_UNDERCOAT: cuboids" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_WOOL_UNDERCOAT: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_WOOL_UNDERCOAT: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_BABY_WOOL" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SHEEP_BABY_WOOL is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§5 Sheep 5.4 SHEEP_BABY_WOOL" TO CK-PREFIX
     MOVE "P body root 0 17 0.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 10 -3 -2 -4.5 6 4 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head root 0 15.5 -2.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -2.5 -4.5 -3.5 5 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2 19 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 23 -1 0 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2 19 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 24 12 -1 0 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2 19 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 8 23 -1 0 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2 19 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 24 5 -1 0 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "5.4 SHEEP_BABY_WOOL: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_BABY_WOOL: cuboids" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_BABY_WOOL: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 SHEEP_BABY_WOOL: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF4-SHEEP-TEXTURE" USING WS-IN WS-X120
     MOVE "5.1 texture baby 0" TO WS-NAME
     MOVE "textures/entity/sheep/sheep.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     CALL "EF4-SHEEP-TEXTURE" USING WS-IN WS-X120
     MOVE "5.1 texture baby 1" TO WS-NAME
     MOVE "textures/entity/sheep/sheep_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 0 jeb 0 colour not white 0 baby 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 0 jeb 0 colour not white 0 baby 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 0 jeb 0 colour not white 1 baby 0 drawn" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 0 jeb 0 colour not white 1 baby 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 0 jeb 1 colour not white 0 baby 0 drawn" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 0 jeb 1 colour not white 0 baby 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 0 jeb 1 colour not white 1 baby 0 drawn" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 0 jeb 1 colour not white 1 baby 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 1 jeb 0 colour not white 0 baby 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 1 jeb 0 colour not white 0 baby 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 1 jeb 0 colour not white 1 baby 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 1 jeb 0 colour not white 1 baby 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 1 jeb 1 colour not white 0 baby 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 1 jeb 1 colour not white 0 baby 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 1 jeb 1 colour not white 1 baby 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-UNDERCOAT-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 undercoat invisible 1 jeb 1 colour not white 1 baby 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 0 baby 0 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 0 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 0 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 0 baby 0 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 0 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 0 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 0 baby 0 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 0 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 0 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 0 baby 0 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 0 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 0 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 0 baby 1 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 1 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 1 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 0 baby 1 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 1 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 1 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 0 baby 1 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 1 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 1 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 0 baby 1 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 1 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 0 baby 1 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 1 baby 0 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 0 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 0 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 1 baby 0 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 0 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 0 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 1 baby 0 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 0 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 0 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 1 baby 0 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 0 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 0 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 1 baby 1 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 1 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 1 invisible 0 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 1 baby 1 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 1 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 1 invisible 0 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 1 baby 1 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 1 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 1 invisible 1 glowing 0: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-WOOL-DRAW" USING WS-IN WS-OUT
     MOVE "5.3 wool sheared 1 baby 1 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 1 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 wool sheared 1 baby 1 invisible 1 glowing 1: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 16383998 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 0 white: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4294574078 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 0 white: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4293322470 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 16351261 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 1 orange: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4294541341 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 1 orange: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4290404373 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 13061821 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 2 magenta: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4291251901 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 2 magenta: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4287969933 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 3847130 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 3 light_blue: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4282037210 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 3 light_blue: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4281042595 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 16701501 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 4 yellow: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4294891581 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 4 yellow: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4290683437 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 8439583 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 5 lime: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4286629663 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 5 lime: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4284519703 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     MOVE 15961002 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 6 pink: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4294151082 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 6 pink: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4290144383 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 4673362 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 7 gray: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4282863442 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 7 gray: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4281678653 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE 10329495 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 8 light_gray: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4288519575 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 8 light_gray: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4285887857 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     MOVE 1481884 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 9 cyan: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4279671964 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 9 cyan: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4279268725 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     MOVE 8991416 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 10 purple: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4287181496 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 10 purple: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4284884362 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 11 TO WS-IV(1)
     MOVE 3949738 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 11 blue: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4282139818 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 11 blue: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4281152383 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 12 TO WS-IV(1)
     MOVE 8606770 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 12 brown: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4286796850 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 12 brown: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4284628773 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 13 TO WS-IV(1)
     MOVE 6192150 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 13 green: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4284382230 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 13 green: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4282801424 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 14 TO WS-IV(1)
     MOVE 11546150 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 14 red: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4289736230 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 14 red: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4286849564 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     MOVE 1908001 TO WS-IV(2)
     CALL "EF4-DYE-COLOUR" USING WS-IN WS-OUT
     MOVE "5.5 dye 15 black: opaque diffuse colour and sheep colour [1]" TO WS-NAME
     MOVE 4280098081 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.5 dye 15 black: opaque diffuse colour and sheep colour [2]" TO WS-NAME
     MOVE 4279571736 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 0 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 0 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 230 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 0 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 230 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 0 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 230 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 0 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4293322470 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.5 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 3.5 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 3.5 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 223 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 3.5 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 211 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 3.5 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 200 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 3.5 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4292858824 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 12.3 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 12.3 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 12.3 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 208 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 12.3 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 164 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 12.3 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 127 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 12.3 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4291863679 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24.9 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 24.9 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 24.9 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 186 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 24.9 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 96 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 24.9 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 24.9 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4290404373 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 25 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 25 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 25 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 186 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 25 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 96 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 25 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 25 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4290404373 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 37.7 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 37.7 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 37.7 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 167 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 37.7 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 76 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 37.7 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 81 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 37.7 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4289154129 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100.25 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 100.25 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 100.25 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 189 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 100.25 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 161 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 100.25 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 44 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 100.25 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4290617644 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 399.6 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 399.6 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 399.6 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 226 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 399.6 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 226 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 399.6 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 226 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 399.6 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4293059298 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 401.25 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 401.25 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 401.25 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 227 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 401.25 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 223 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 401.25 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 219 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 401.25 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4293124059 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 812.75 TO WS-IV(1)
     CALL "EF4-JEB-COLOUR" USING WS-IN WS-OUT
     MOVE "5.6 jeb colour at ageInTicks 812.75 (alpha, red, green, blue, packed ARGB) [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 812.75 (alpha, red, green, blue, packed ARGB) [2]" TO WS-NAME
     MOVE 207 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 812.75 (alpha, red, green, blue, packed ARGB) [3]" TO WS-NAME
     MOVE 161 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 812.75 (alpha, red, green, blue, packed ARGB) [4]" TO WS-NAME
     MOVE 123 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.6 jeb colour at ageInTicks 812.75 (alpha, red, green, blue, packed ARGB) [5]" TO WS-NAME
     MOVE 4291797371 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 12 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.6 TO WS-IV(4)
     MOVE 0.8 TO WS-IV(5)
     MOVE 0.35 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 2.5 eat 0.8 ageScale 1 head.y" TO WS-NAME
     MOVE 13.2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 2.5 eat 0.8 ageScale 1 head.xrot" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 2.5 eat 0.8 ageScale 1 head.yrot" TO WS-NAME
     MOVE -0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 2.5 eat 0.8 ageScale 1 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 2.5 eat 0.8 ageScale 1 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 2.5 eat 0.8 ageScale 1 right_front_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 2.5 eat 0.8 ageScale 1 left_front_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.9 TO WS-IV(6)
     MOVE 0.5 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 0 eat 0 ageScale 0.5 head.y" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 0 eat 0 ageScale 0.5 head.xrot" TO WS-NAME
     MOVE 0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 0 eat 0 ageScale 0.5 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 0 eat 0 ageScale 0.5 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 0 eat 0 ageScale 0.5 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 0 eat 0 ageScale 0.5 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 0 eat 0 ageScale 0.5 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 30 TO WS-IV(1)
     MOVE 20 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0.8 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0.5 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 4 eat 0.8 ageScale 0.5 head.y" TO WS-NAME
     MOVE 9.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 4 eat 0.8 ageScale 0.5 head.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 4 eat 0.8 ageScale 0.5 head.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 4 eat 0.8 ageScale 0.5 right_hind_leg.xrot" TO WS-NAME
     MOVE -1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 4 eat 0.8 ageScale 0.5 left_hind_leg.xrot" TO WS-NAME
     MOVE 1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 4 eat 0.8 ageScale 0.5 right_front_leg.xrot" TO WS-NAME
     MOVE 1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 4 eat 0.8 ageScale 0.5 left_front_leg.xrot" TO WS-NAME
     MOVE -1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.3 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 1 eat 0 ageScale 1 head.y" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 1 eat 0 ageScale 1 head.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 1 eat 0 ageScale 1 head.yrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 1 eat 0 ageScale 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 1 eat 0 ageScale 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 1 eat 0 ageScale 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP pos 1 eat 0 ageScale 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_WOOL" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 12 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.6 TO WS-IV(4)
     MOVE 0.8 TO WS-IV(5)
     MOVE 0.35 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 2.5 eat 0.8 ageScale 1 head.y" TO WS-NAME
     MOVE 13.2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 2.5 eat 0.8 ageScale 1 head.xrot" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 2.5 eat 0.8 ageScale 1 head.yrot" TO WS-NAME
     MOVE -0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 2.5 eat 0.8 ageScale 1 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 2.5 eat 0.8 ageScale 1 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 2.5 eat 0.8 ageScale 1 right_front_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 2.5 eat 0.8 ageScale 1 left_front_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_WOOL" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.9 TO WS-IV(6)
     MOVE 0.5 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 0 eat 0 ageScale 0.5 head.y" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 0 eat 0 ageScale 0.5 head.xrot" TO WS-NAME
     MOVE 0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 0 eat 0 ageScale 0.5 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 0 eat 0 ageScale 0.5 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 0 eat 0 ageScale 0.5 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 0 eat 0 ageScale 0.5 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 0 eat 0 ageScale 0.5 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_WOOL" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 30 TO WS-IV(1)
     MOVE 20 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0.8 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0.5 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 4 eat 0.8 ageScale 0.5 head.y" TO WS-NAME
     MOVE 9.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 4 eat 0.8 ageScale 0.5 head.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 4 eat 0.8 ageScale 0.5 head.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 4 eat 0.8 ageScale 0.5 right_hind_leg.xrot" TO WS-NAME
     MOVE -1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 4 eat 0.8 ageScale 0.5 left_hind_leg.xrot" TO WS-NAME
     MOVE 1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 4 eat 0.8 ageScale 0.5 right_front_leg.xrot" TO WS-NAME
     MOVE 1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 4 eat 0.8 ageScale 0.5 left_front_leg.xrot" TO WS-NAME
     MOVE -1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_WOOL" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.3 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 1 eat 0 ageScale 1 head.y" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 1 eat 0 ageScale 1 head.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 1 eat 0 ageScale 1 head.yrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 1 eat 0 ageScale 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 1 eat 0 ageScale 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 1 eat 0 ageScale 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_WOOL pos 1 eat 0 ageScale 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 12 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.6 TO WS-IV(4)
     MOVE 0.8 TO WS-IV(5)
     MOVE 0.35 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 2.5 eat 0.8 ageScale 1 head.y" TO WS-NAME
     MOVE 22.7 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 2.5 eat 0.8 ageScale 1 head.xrot" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 2.5 eat 0.8 ageScale 1 head.yrot" TO WS-NAME
     MOVE -0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 2.5 eat 0.8 ageScale 1 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 2.5 eat 0.8 ageScale 1 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 2.5 eat 0.8 ageScale 1 right_front_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 2.5 eat 0.8 ageScale 1 left_front_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.9 TO WS-IV(6)
     MOVE 0.5 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 0 eat 0 ageScale 0.5 head.y" TO WS-NAME
     MOVE 15.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 0 eat 0 ageScale 0.5 head.xrot" TO WS-NAME
     MOVE 0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 0 eat 0 ageScale 0.5 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 0 eat 0 ageScale 0.5 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 0 eat 0 ageScale 0.5 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 0 eat 0 ageScale 0.5 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 0 eat 0 ageScale 0.5 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 30 TO WS-IV(1)
     MOVE 20 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0.8 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0.5 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 4 eat 0.8 ageScale 0.5 head.y" TO WS-NAME
     MOVE 19.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 4 eat 0.8 ageScale 0.5 head.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 4 eat 0.8 ageScale 0.5 head.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 4 eat 0.8 ageScale 0.5 right_hind_leg.xrot" TO WS-NAME
     MOVE -1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 4 eat 0.8 ageScale 0.5 left_hind_leg.xrot" TO WS-NAME
     MOVE 1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 4 eat 0.8 ageScale 0.5 right_front_leg.xrot" TO WS-NAME
     MOVE 1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 4 eat 0.8 ageScale 0.5 left_front_leg.xrot" TO WS-NAME
     MOVE -1.243860021 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHEEP_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.3 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 1 eat 0 ageScale 1 head.y" TO WS-NAME
     MOVE 15.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 1 eat 0 ageScale 1 head.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 1 eat 0 ageScale 1 head.yrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 1 eat 0 ageScale 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 1 eat 0 ageScale 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 1 eat 0 ageScale 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "5.2 SHEEP_BABY pos 1 eat 0 ageScale 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.330193814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§5 Sheep: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§5 Sheep: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-4-5.
