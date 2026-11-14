*> Entity models part 6 section 5 (Silverfish): the seven segments and three layer boxes (5.1), the age wave of setupAnim and the layers that copy their segments (5.2), texture.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-SILVERFISH-ANIM EMM-MODEL state(1 ageInTicks): reset first, then yRot and pivot x of segment0 to segment6, then layer0 (yRot of segment2), layer1 and layer2 (yRot and x of segment4 and segment1);
*>   EF6-SILVERFISH-TEXTURE IN() path(out X(120)).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-M-SILVERFISH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P segment0 root 0 22 -3.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C segment0 0 0 -1.5 0 -1 3 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P segment1 root 0 21 -1.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C segment1 0 4 -2 0 -1 4 3 2 0 0".
    05 FILLER PIC X(100) VALUE "P segment2 root 0 20 1 0 0 0".
    05 FILLER PIC X(100) VALUE "C segment2 0 9 -3 0 -1.5 6 4 3 0 0".
    05 FILLER PIC X(100) VALUE "P segment3 root 0 21 4 0 0 0".
    05 FILLER PIC X(100) VALUE "C segment3 0 16 -1.5 0 -1.5 3 3 3 0 0".
    05 FILLER PIC X(100) VALUE "P segment4 root 0 22 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C segment4 0 22 -1 0 -1.5 2 2 3 0 0".
    05 FILLER PIC X(100) VALUE "P segment5 root 0 23 9.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C segment5 11 0 -1 0 -1 2 1 2 0 0".
    05 FILLER PIC X(100) VALUE "P segment6 root 0 23 11.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C segment6 13 4 -0.5 0 -1 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "P layer0 root 0 16 1 0 0 0".
    05 FILLER PIC X(100) VALUE "C layer0 20 0 -5 0 -1.5 10 8 3 0 0".
    05 FILLER PIC X(100) VALUE "P layer1 root 0 20 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C layer1 20 11 -3 0 -1.5 6 4 3 0 0".
    05 FILLER PIC X(100) VALUE "P layer2 root 0 19 -1.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C layer2 20 18 -3 0 -1.5 6 5 2 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 60 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 20.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF6-M-SILVERFISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SILVERFISH-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIG                 PIC 9.
 01 WS-A                   FLOAT-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-S4                  BINARY-LONG.
 01 WS-L0                  BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-NAME
         MOVE WS-I TO WS-DIG
         STRING "segment" WS-DIG DELIMITED BY SIZE INTO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         COMPUTE WS-A = L-I(1) * 0.9 + WS-I * 0.15 * 3.1415927
         COMPUTE WS-D = FUNCTION ABS(WS-I - 2)
         COMPUTE MM-CYROT(WS-P) = FUNCTION COS(WS-A) * 3.1415927 * 0.05 * (1 + WS-D)
         COMPUTE MM-CX(WS-P) = FUNCTION SIN(WS-A) * 3.1415927 * 0.2 * WS-D
         EVALUATE WS-I
             WHEN 1
                 MOVE WS-P TO WS-S1
             WHEN 2
                 MOVE WS-P TO WS-S2
             WHEN 4
                 MOVE WS-P TO WS-S4
         END-EVALUATE
     END-PERFORM
     MOVE "layer0" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-L0
     MOVE "layer1" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-L1
     MOVE "layer2" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-L2
     MOVE MM-CYROT(WS-S2) TO MM-CYROT(WS-L0)
     MOVE MM-CYROT(WS-S4) TO MM-CYROT(WS-L1)
     MOVE MM-CX(WS-S4) TO MM-CX(WS-L1)
     MOVE MM-CYROT(WS-S1) TO MM-CYROT(WS-L2)
     MOVE MM-CX(WS-S1) TO MM-CX(WS-L2)
     GOBACK.
 END PROGRAM EF6-SILVERFISH-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SILVERFISH-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/silverfish/silverfish.png" TO L-PATH
     GOBACK.
 END PROGRAM EF6-SILVERFISH-TEXTURE.
