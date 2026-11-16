*> Entity models part 8, boats and rafts (docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 7): EF8-M-BOAT, EF8-M-BOAT-CHEST, EF8-M-RAFT and EF8-M-RAFT-CHEST
*> USING model build the layers of 7.1 (the ten wood layers of a kind are the same mesh, only the texture differs; the water patch is a depth-only mask and is not drawn),
*> EF8-BOAT-ANIM USING model, state (16 FLOAT-LONG: 3 rowing time left, 4 rowing time right) the paddle animation of 7.2, EF8-BOAT-SEQUENCE USING in (3 yaw degrees), out the
*> render sequence of 7.4 in the order of EF7-SETUP-ROTATIONS (count in out(1), then 4 values an operation from out(2): 1 translate, 2 scale, 3 rotate about Y in degrees; the
*> last listed acts first): translate (0, 0.375, 0), rotate Y by 180 - yaw, scale (-1, -1, 1), rotate Y by 90. The hurt tilt and the bubble column wobble of 7.4 steps 3 and 4 are
*> not drawn (the replica holds no hurt time or bubble angle).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-BOAT.
*> USING model: the boat (7.1, texture 128 x 64): bottom, four sides, two paddles of two boxes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P bottom root 0 3 1 1.5707964 0 0".
    05 FILLER PIC X(100) VALUE "C bottom 0 0 -14 -9 -3 28 16 3 0 0".
    05 FILLER PIC X(100) VALUE "P back root -15 4 4 0 4.712389 0".
    05 FILLER PIC X(100) VALUE "C back 0 19 -13 -7 -1 18 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P front root 15 4 0 0 1.5707964 0".
    05 FILLER PIC X(100) VALUE "C front 0 27 -8 -7 -1 16 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P right root 0 4 -9 0 3.1415927 0".
    05 FILLER PIC X(100) VALUE "C right 0 35 -14 -7 -1 28 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P left root 0 4 9 0 0 0".
    05 FILLER PIC X(100) VALUE "C left 0 43 -14 -7 -1 28 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_paddle root 3 -5 9 0 0 0.19634955".
    05 FILLER PIC X(100) VALUE "C left_paddle 62 0 -1 0 -5 2 2 18 0 0".
    05 FILLER PIC X(100) VALUE "C left_paddle 62 0 -1.001 -3 8 1 6 7 0 0".
    05 FILLER PIC X(100) VALUE "P right_paddle root 3 -5 -9 0 3.1415927 0.19634955".
    05 FILLER PIC X(100) VALUE "C right_paddle 62 20 -1 0 -5 2 2 18 0 0".
    05 FILLER PIC X(100) VALUE "C right_paddle 62 20 0.001 -3 8 1 6 7 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 64 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 16.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 128 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-BOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-BOAT-CHEST.
*> USING model: the chest boat (7.1, texture 128 x 128): the boat and its chest bottom, lid and lock.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P bottom root 0 3 1 1.5707964 0 0".
    05 FILLER PIC X(100) VALUE "C bottom 0 0 -14 -9 -3 28 16 3 0 0".
    05 FILLER PIC X(100) VALUE "P back root -15 4 4 0 4.712389 0".
    05 FILLER PIC X(100) VALUE "C back 0 19 -13 -7 -1 18 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P front root 15 4 0 0 1.5707964 0".
    05 FILLER PIC X(100) VALUE "C front 0 27 -8 -7 -1 16 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P right root 0 4 -9 0 3.1415927 0".
    05 FILLER PIC X(100) VALUE "C right 0 35 -14 -7 -1 28 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P left root 0 4 9 0 0 0".
    05 FILLER PIC X(100) VALUE "C left 0 43 -14 -7 -1 28 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_paddle root 3 -5 9 0 0 0.19634955".
    05 FILLER PIC X(100) VALUE "C left_paddle 62 0 -1 0 -5 2 2 18 0 0".
    05 FILLER PIC X(100) VALUE "C left_paddle 62 0 -1.001 -3 8 1 6 7 0 0".
    05 FILLER PIC X(100) VALUE "P right_paddle root 3 -5 -9 0 3.1415927 0.19634955".
    05 FILLER PIC X(100) VALUE "C right_paddle 62 20 -1 0 -5 2 2 18 0 0".
    05 FILLER PIC X(100) VALUE "C right_paddle 62 20 0.001 -3 8 1 6 7 0 0".
    05 FILLER PIC X(100) VALUE "P chest_bottom root -2 -5 -6 0 -1.5707964 0".
    05 FILLER PIC X(100) VALUE "C chest_bottom 0 76 0 0 0 12 8 12 0 0".
    05 FILLER PIC X(100) VALUE "P chest_lid root -2 -9 -6 0 -1.5707964 0".
    05 FILLER PIC X(100) VALUE "C chest_lid 0 59 0 0 0 12 4 12 0 0".
    05 FILLER PIC X(100) VALUE "P chest_lock root -1 -6 -1 0 -1.5707964 0".
    05 FILLER PIC X(100) VALUE "C chest_lock 0 59 0 0 0 2 4 1 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 58 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 22.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 128 TO MM-TEXW
     MOVE 128 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-BOAT-CHEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-RAFT.
*> USING model: the raft (7.1, texture 128 x 64): the bottom of two boxes and two paddles.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P bottom root 0 -2.1 1 1.5708 0 0".
    05 FILLER PIC X(100) VALUE "C bottom 0 0 -14 -11 -4 28 20 4 0 0".
    05 FILLER PIC X(100) VALUE "C bottom 0 0 -14 -9 -8 28 16 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_paddle root 3 -4 9 0 0 0.19634955".
    05 FILLER PIC X(100) VALUE "C left_paddle 0 24 -1 0 -5 2 2 18 0 0".
    05 FILLER PIC X(100) VALUE "C left_paddle 0 24 -1.001 -3 8 1 6 7 0 0".
    05 FILLER PIC X(100) VALUE "P right_paddle root 3 -4 -9 0 3.1415927 0.19634955".
    05 FILLER PIC X(100) VALUE "C right_paddle 40 24 -1 0 -5 2 2 18 0 0".
    05 FILLER PIC X(100) VALUE "C right_paddle 40 24 0.001 -3 8 1 6 7 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 71 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 9.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 128 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-RAFT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-RAFT-CHEST.
*> USING model: the chest raft (7.1, texture 128 x 128): the raft and its chest parts, 5.1 higher.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P bottom root 0 -2.1 1 1.5708 0 0".
    05 FILLER PIC X(100) VALUE "C bottom 0 0 -14 -11 -4 28 20 4 0 0".
    05 FILLER PIC X(100) VALUE "C bottom 0 0 -14 -9 -8 28 16 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_paddle root 3 -4 9 0 0 0.19634955".
    05 FILLER PIC X(100) VALUE "C left_paddle 0 24 -1 0 -5 2 2 18 0 0".
    05 FILLER PIC X(100) VALUE "C left_paddle 0 24 -1.001 -3 8 1 6 7 0 0".
    05 FILLER PIC X(100) VALUE "P right_paddle root 3 -4 -9 0 3.1415927 0.19634955".
    05 FILLER PIC X(100) VALUE "C right_paddle 40 24 -1 0 -5 2 2 18 0 0".
    05 FILLER PIC X(100) VALUE "C right_paddle 40 24 0.001 -3 8 1 6 7 0 0".
    05 FILLER PIC X(100) VALUE "P chest_bottom root -2 -10.1 -6 0 -1.5707964 0".
    05 FILLER PIC X(100) VALUE "C chest_bottom 0 76 0 0 0 12 8 12 0 0".
    05 FILLER PIC X(100) VALUE "P chest_lid root -2 -14.1 -6 0 -1.5707964 0".
    05 FILLER PIC X(100) VALUE "C chest_lid 0 59 0 0 0 12 4 12 0 0".
    05 FILLER PIC X(100) VALUE "P chest_lock root -1 -11.1 -1 0 -1.5707964 0".
    05 FILLER PIC X(100) VALUE "C chest_lock 0 59 0 0 0 2 4 1 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 65 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 15.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 128 TO MM-TEXW
     MOVE 128 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-RAFT-CHEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BOAT-ANIM.
*> USING model, state (16 FLOAT-LONG: 3 rowing time of the left paddle, 4 of the right): reset first, then each paddle is set (7.2): xRot = clampedLerp((sin(-t) + 1) / 2,
*> -1.0471976, -0.2617994), yRot = clampedLerp((sin(-t + 1) + 1) / 2, -0.7853982, 0.7853982), the right paddle's yRot = pi - yRot; the baked zRot stays.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-SIDE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 2
         IF WS-SIDE = 1
             MOVE "left_paddle" TO WS-NAME
             MOVE L-I(3) TO WS-T
         ELSE
             MOVE "right_paddle" TO WS-NAME
             MOVE L-I(4) TO WS-T
         END-IF
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         COMPUTE WS-F = FUNCTION MIN(FUNCTION MAX((FUNCTION SIN(0 - WS-T) + 1) / 2, 0), 1)
         COMPUTE MM-CXROT(WS-P) = -1.0471976 + (-0.2617994 + 1.0471976) * WS-F
         COMPUTE WS-F = FUNCTION MIN(FUNCTION MAX((FUNCTION SIN(1 - WS-T) + 1) / 2, 0), 1)
         COMPUTE MM-CYROT(WS-P) = -0.7853982 + 1.5707964 * WS-F
         IF WS-SIDE = 2
             COMPUTE MM-CYROT(WS-P) = 3.1415927 - MM-CYROT(WS-P)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EF8-BOAT-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BOAT-SEQUENCE.
*> USING in (16 FLOAT-LONG: 3 body yaw in degrees), out (64 FLOAT-LONG): the render sequence of 7.4, see the top of this file.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 4 TO L-O(1)
     MOVE 1 TO L-O(2)
     MOVE 0 TO L-O(3) L-O(5)
     MOVE 0.375 TO L-O(4)
     MOVE 3 TO L-O(6)
     COMPUTE L-O(7) = 180 - L-I(3)
     MOVE 0 TO L-O(8) L-O(9)
     MOVE 2 TO L-O(10)
     MOVE -1 TO L-O(11) L-O(12)
     MOVE 1 TO L-O(13)
     MOVE 3 TO L-O(14)
     MOVE 90 TO L-O(15)
     MOVE 0 TO L-O(16) L-O(17)
     GOBACK.
 END PROGRAM EF8-BOAT-SEQUENCE.
