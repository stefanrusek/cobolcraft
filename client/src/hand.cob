*> The hand in first person (US20; 12 §6; FR-021). HAND-INPUT: breaking (the left button pressed or held once the last swing is over), placing (the right
*> button pressed on a target) or attacking starts the swing (CL-SWING-AT). HAND-MESH builds the held item as a small 3D model in view space at
*> the lower right: a block item (CL-IT-STATE > 0) is a cube of 0.4 blocks, any other item a flat 0.5 x 0.5 icon of the thickness 0.02, both with
*> the item's icon (the block and item atlas) on every face, shaded like entity faces; nothing in an empty hand, in third person or off the
*> world screen. The swing moves the model forward and down by sin(pi t) over 300 ms (CL-SWING-MS). RENDER-LIST-BUILD draws it with the projection
*> alone, after a depth clear (a draw record with slot -1; SUBMIT-FRAME calls cc_vk_clear_depth), so it is never inside a block.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-INPUT.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF SM-SCREEN = SCR-WORLD
         IF IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1) = 1
                 OR (IN-BUTTON-DOWN(CC-BUTTON-LEFT + 1) = 1 AND CL-NOW-MS - CL-SWING-AT >= CL-SWING-MS)
                 OR (IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND TG-HIT = 1)
             MOVE CL-NOW-MS TO CL-SWING-AT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HAND-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-MESH.
*> USING CLIENT-STATE: RL-HAND-VERTEX and RL-HAND-COUNT for this frame (36 vertices or none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-CORNER-DATA.
    05 FILLER PIC X(12) VALUE "011111101001".
    05 FILLER PIC X(12) VALUE "110010000100".
    05 FILLER PIC X(12) VALUE "111110100101".
    05 FILLER PIC X(12) VALUE "010011001000".
    05 FILLER PIC X(12) VALUE "010110111011".
    05 FILLER PIC X(12) VALUE "100000001101".
 01 WS-CORNER-TABLE REDEFINES WS-CORNER-DATA.
    05 WS-FACE OCCURS 6 TIMES.
       10 WS-PICK            PIC 9 OCCURS 12 TIMES.
 01 WS-FACTOR-DATA.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 1.0.
    05 FILLER PIC 9V9 VALUE 0.5.
 01 WS-FACTOR-TABLE REDEFINES WS-FACTOR-DATA.
    05 WS-FACTOR           PIC 9V9 OCCURS 6 TIMES.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-HBLOCK              BINARY-LONG.
 01 WS-HTOOL               PIC X.
 01 WS-HFOOD               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-SWING               FLOAT-LONG.
 01 WS-CENTRE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HALF                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LO                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HI                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-U16                 BINARY-LONG OCCURS 4 TIMES.
 01 WS-V16                 BINARY-LONG OCCURS 4 TIMES.
 01 WS-CU                  FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-CV                  FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-CP                  FLOAT-LONG OCCURS 12 TIMES.
 01 WS-X                   FLOAT-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-SIXTEEN2            BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO RL-HAND-COUNT
     IF SM-SCREEN = SCR-WORLD AND CL-CAMERA = 0 AND PL-SLOT-COUNT(PL-HELD + 1) > 0
         MOVE PL-SLOT-ITEM(PL-HELD + 1) TO WS-ITEM
         MOVE 0 TO WS-SPRITE
         IF WS-ITEM >= 0 AND WS-ITEM < CL-ITEM-COUNT
             MOVE IT-SPRITE(WS-ITEM + 1) TO WS-SPRITE
         END-IF
         IF WS-SPRITE > 0
*>           The swing: forward and down by sin(pi t) while t = (now - start) / 300 ms is below 1.
             MOVE 0 TO WS-SWING
             IF CL-SWING-AT > 0 AND CL-NOW-MS - CL-SWING-AT < CL-SWING-MS
                 COMPUTE WS-T = (CL-NOW-MS - CL-SWING-AT) / CL-SWING-MS
                 COMPUTE WS-SWING = FUNCTION SIN(WS-T * FUNCTION PI)
             END-IF
             COMPUTE WS-CENTRE(1) = 0.45 - 0.1 * WS-SWING
             COMPUTE WS-CENTRE(2) = -0.35 - 0.15 * WS-SWING
             COMPUTE WS-CENTRE(3) = -0.8 - 0.2 * WS-SWING
             CALL "CL-ITEM-FLAGS" USING CLIENT-STATE WS-ITEM WS-HBLOCK WS-HTOOL WS-HFOOD
             IF WS-HBLOCK = 1
                 MOVE 0.2 TO WS-HALF(1) WS-HALF(2) WS-HALF(3)
             ELSE
                 MOVE 0.25 TO WS-HALF(1) WS-HALF(2)
                 MOVE 0.01 TO WS-HALF(3)
             END-IF
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 COMPUTE WS-LO(WS-A) = WS-CENTRE(WS-A) - WS-HALF(WS-A)
                 COMPUTE WS-HI(WS-A) = WS-CENTRE(WS-A) + WS-HALF(WS-A)
             END-PERFORM
*>           Corner texels of the icon: top-left, top-right, bottom-right, bottom-left.
             MOVE 0 TO WS-U16(1) WS-V16(1) WS-V16(2) WS-U16(4)
             MOVE 16 TO WS-U16(2) WS-U16(3) WS-V16(3) WS-V16(4)
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16(WS-K) WS-V16(WS-K) WS-CU(WS-K)
                     WS-CV(WS-K)
             END-PERFORM
             PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                         COMPUTE WS-C = (WS-K - 1) * 3 + WS-A
                         IF WS-PICK(WS-F, WS-C) = 0
                             MOVE WS-LO(WS-A) TO WS-CP(WS-C)
                         ELSE
                             MOVE WS-HI(WS-A) TO WS-CP(WS-C)
                         END-IF
                     END-PERFORM
                 END-PERFORM
                 PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 6
                     MOVE WS-ORD(WS-V) TO WS-K
                     ADD 1 TO RL-HAND-COUNT
                     COMPUTE WS-C = (WS-K - 1) * 3
                     MOVE WS-CP(WS-C + 1) TO RL-HAND-X(RL-HAND-COUNT)
                     MOVE WS-CP(WS-C + 2) TO RL-HAND-Y(RL-HAND-COUNT)
                     MOVE WS-CP(WS-C + 3) TO RL-HAND-Z(RL-HAND-COUNT)
                     MOVE WS-CU(WS-K) TO RL-HAND-U(RL-HAND-COUNT)
                     MOVE WS-CV(WS-K) TO RL-HAND-V(RL-HAND-COUNT)
                     MOVE WS-FACTOR(WS-F) TO RL-HAND-B(RL-HAND-COUNT)
                     MOVE 1 TO RL-HAND-A(RL-HAND-COUNT)
                     MOVE 0 TO RL-HAND-SKY(RL-HAND-COUNT)
                     MOVE 1 TO RL-HAND-R(RL-HAND-COUNT) RL-HAND-G(RL-HAND-COUNT)
                         RL-HAND-BLUE(RL-HAND-COUNT)
                 END-PERFORM
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HAND-MESH.
