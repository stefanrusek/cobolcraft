*> Entity models part 1 section 6 (docs/protocol/34-entity-models-1-shared-model-and-framework.md): the entity renderer framework numbers. Every table entry
*> point below takes IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG); the others are listed with their arguments.
*>   EM6-WRAP IN(x) OUT(1); EM6-ROTLERP IN(t a b); EM6-SOLVE-BODY IN(vehicle-is-living partial yBodyRotO yBodyRot head-yaw) OUT(bodyRot);
*>   EM6-HEAD-ANGLES IN(head-yaw body-rot pitch upside-down) OUT(yRot xRot); EM6-SPEED-VALUE IN(fall-flying |deltaMovement|^2) OUT(speed);
*>   EM6-CUBE-SCALE IN(size squish) OUT(sx sy sz shadow-radius); EM6-LIGHT-PACK IN(block sky) OUT(coords); EM6-LIGHT-WITH-BLOCK IN(coords block);
*>   EM6-OVERLAY IN(white-progress has-red-overlay) OUT(coords); EM6-OVERLAY-ALPHA IN(column) OUT(alpha byte of the white rows);
*>   EM6-POSE-CHAIN IN(sleeping has-bed bed-step-x bed-step-z bed-yaw standing-eye-height scale body-rot death-time flip-degrees auto-spin x-rot
*>     age-in-ticks upside-down bbox-height shaking) OUT(op count, then 4 numbers per op: kind 1 translate, 2 scale, 3 rotate about Y, 4 about Z, 5 about
*>     X, then three values): the matrix operations of 6.5 in the order listed (the last acts first on a vertex);
*>   EM6-CULL-BOX IN(box min xyz, max xyz, dragon-head, has-NaN, entity x y z) OUT(box min xyz, max xyz) (6.8).
*>   EM6-AGE-SCALE type(X(24)) baby ageScale; EM6-RED-OVERLAY hurtTime deathTime flag; EM6-DEATH-TIME deathTime partial state;
*>   EM6-TRANSLUCENT body-visible invisible-to-player flag; EM6-RENDER-TYPE body-visible translucent glowing code (1 entityTranslucentCull, 2 the
*>   model's own function, 3 outline, 0 none); EM6-COLOUR-MULTIPLY a b out (ARGB ints as BINARY-DOUBLE, Java signed); EM6-OVERLAY-TEX row column
*>   argb(out); EM6-PIPELINE name(X(32)) OUT(alpha-cutout per-face-lighting culling blend(0 none 1 translucent 2 additive) depth-GEQ depth-write
*>   no-overlay no-lightmap dissolve; OUT(1) -1 for a pipeline the document did not read); EM6-RENDERER-EXEMPT type flag (6.2).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-WRAP-F.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y.
     COMPUTE WS-Q = FUNCTION INTEGER-PART(L-X / 360)
     COMPUTE L-Y = L-X - 360 * WS-Q
     IF L-Y >= 180
         COMPUTE L-Y = L-Y - 360
     END-IF
     IF L-Y < -180
         COMPUTE L-Y = L-Y + 360
     END-IF
     GOBACK.
 END PROGRAM EM6-WRAP-F.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-WRAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-X
     CALL "EM6-WRAP-F" USING WS-X WS-Y
     MOVE WS-Y TO L-O(1)
     GOBACK.
 END PROGRAM EM6-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-ROTLERP-F.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-T                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-T L-A L-B L-Y.
     COMPUTE WS-D = L-B - L-A
     CALL "EM6-WRAP-F" USING WS-D WS-W
     COMPUTE L-Y = L-A + L-T * WS-W
     GOBACK.
 END PROGRAM EM6-ROTLERP-F.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-ROTLERP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-T
     MOVE L-I(2) TO WS-A
     MOVE L-I(3) TO WS-B
     CALL "EM6-ROTLERP-F" USING WS-T WS-A WS-B WS-Y
     MOVE WS-Y TO L-O(1)
     GOBACK.
 END PROGRAM EM6-ROTLERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-SOLVE-BODY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-BODY                FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(2) TO WS-T
     MOVE L-I(3) TO WS-A
     MOVE L-I(4) TO WS-B
     CALL "EM6-ROTLERP-F" USING WS-T WS-A WS-B WS-BODY
     MOVE WS-BODY TO L-O(1)
     IF L-I(1) NOT = 0
         COMPUTE WS-X = L-I(5) - WS-BODY
         CALL "EM6-WRAP-F" USING WS-X WS-D
         IF WS-D < -85
             MOVE -85 TO WS-D
         END-IF
         IF WS-D > 85
             MOVE 85 TO WS-D
         END-IF
         COMPUTE L-O(1) = L-I(5) - WS-D
         IF WS-D > 50 OR WS-D < -50
             COMPUTE L-O(1) = L-O(1) + WS-D * 0.2
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EM6-SOLVE-BODY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-HEAD-ANGLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-X = L-I(1) - L-I(2)
     CALL "EM6-WRAP-F" USING WS-X WS-Y
     MOVE WS-Y TO L-O(1)
     MOVE L-I(3) TO L-O(2)
     IF L-I(4) NOT = 0
         COMPUTE L-O(1) = -L-O(1)
         COMPUTE L-O(2) = -L-O(2)
     END-IF
     GOBACK.
 END PROGRAM EM6-HEAD-ANGLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-SPEED-VALUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     IF L-I(1) NOT = 0
         COMPUTE WS-V = L-I(2) / 0.2
         COMPUTE WS-V = WS-V * WS-V * WS-V
         IF WS-V < 1
             MOVE 1 TO WS-V
         END-IF
         MOVE WS-V TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EM6-SPEED-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-CUBE-SCALE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-Q = L-I(2) / (L-I(1) * 0.5 + 1)
     COMPUTE WS-R = 1 / (WS-Q + 1)
     COMPUTE L-O(1) = WS-R * L-I(1)
     COMPUTE L-O(2) = L-I(1) / WS-R
     COMPUTE L-O(3) = WS-R * L-I(1)
     COMPUTE L-O(4) = L-I(1) * 0.25
     GOBACK.
 END PROGRAM EM6-CUBE-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-LIGHT-PACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * 16 + L-I(2) * 1048576
     GOBACK.
 END PROGRAM EM6-LIGHT-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-LIGHT-WITH-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SKY                 BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-SKY = FUNCTION MOD(FUNCTION INTEGER-PART(L-I(1) / 65536), 256)
     COMPUTE L-O(1) = WS-SKY * 65536 + L-I(2) * 16
     GOBACK.
 END PROGRAM EM6-LIGHT-WITH-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-OVERLAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-U                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-U = FUNCTION INTEGER-PART(L-I(1) * 15)
     MOVE 10 TO WS-V
     IF L-I(2) NOT = 0
         MOVE 3 TO WS-V
     END-IF
     COMPUTE L-O(1) = WS-U + WS-V * 65536
     GOBACK.
 END PROGRAM EM6-OVERLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-OVERLAY-ALPHA.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION INTEGER((1 - L-I(1) / 15 * 0.75) * 255)
     GOBACK.
 END PROGRAM EM6-OVERLAY-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-OVERLAY-TEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ALPHA               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-ARGB                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-ROW L-COL L-ARGB.
     IF L-ROW < 8
         COMPUTE L-ARGB = 178 * 16777216 + 255 * 65536
     ELSE
         COMPUTE WS-ALPHA = FUNCTION INTEGER((1 - L-COL / 15 * 0.75) * 255)
         COMPUTE L-ARGB = WS-ALPHA * 16777216 + 16777215
     END-IF
     GOBACK.
 END PROGRAM EM6-OVERLAY-TEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-POSE-CHAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-BODY                FLOAT-LONG.
 01 WS-KIND                FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO WS-N
     IF L-I(1) NOT = 0 AND L-I(2) NOT = 0
         COMPUTE WS-K = L-I(6) - 0.1
         COMPUTE WS-A = -L-I(3) * WS-K
         COMPUTE WS-C = -L-I(4) * WS-K
         MOVE 1 TO WS-KIND
         MOVE 0 TO WS-B
         CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
     END-IF
     MOVE 2 TO WS-KIND
     MOVE L-I(7) TO WS-A WS-B WS-C
     CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
     MOVE L-I(8) TO WS-BODY
     IF L-I(16) NOT = 0
         COMPUTE WS-BODY = WS-BODY + FUNCTION COS(FUNCTION INTEGER(L-I(13)) * 3.25) * 3.141592653589793 * 0.4000000059604645
     END-IF
     IF L-I(1) = 0
         MOVE 3 TO WS-KIND
         COMPUTE WS-A = 180 - WS-BODY
         MOVE 0 TO WS-B WS-C
         CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
     END-IF
     EVALUATE TRUE
         WHEN L-I(9) > 0
             COMPUTE WS-F = (L-I(9) - 1) / 20 * 1.6
             COMPUTE WS-F = FUNCTION SQRT(WS-F)
             IF WS-F > 1
                 MOVE 1 TO WS-F
             END-IF
             MOVE 4 TO WS-KIND
             COMPUTE WS-A = WS-F * L-I(10)
             MOVE 0 TO WS-B WS-C
             CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
         WHEN L-I(11) NOT = 0
             MOVE 5 TO WS-KIND
             COMPUTE WS-A = -90 - L-I(12)
             MOVE 0 TO WS-B WS-C
             CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
             MOVE 3 TO WS-KIND
             COMPUTE WS-A = L-I(13) * -75
             CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
         WHEN L-I(1) NOT = 0
             MOVE 3 TO WS-KIND
             MOVE L-I(5) TO WS-A
             IF L-I(2) = 0
                 MOVE WS-BODY TO WS-A
             END-IF
             MOVE 0 TO WS-B WS-C
             CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
             MOVE 4 TO WS-KIND
             MOVE L-I(10) TO WS-A
             CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
             MOVE 3 TO WS-KIND
             MOVE 270 TO WS-A
             CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
         WHEN L-I(14) NOT = 0
             MOVE 1 TO WS-KIND
             MOVE 0 TO WS-A WS-C
             COMPUTE WS-B = (L-I(15) + 0.1) / L-I(7)
             CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
             MOVE 4 TO WS-KIND
             MOVE 180 TO WS-A
             MOVE 0 TO WS-B
             CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
     END-EVALUATE
     MOVE 2 TO WS-KIND
     MOVE -1 TO WS-A WS-B
     MOVE 1 TO WS-C
     CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
     MOVE 1 TO WS-KIND
     MOVE 0 TO WS-A WS-C
     MOVE -1.501 TO WS-B
     CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EM6-POSE-CHAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-ADD-OP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 01 L-N                    BINARY-LONG.
 01 L-KIND                 FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-C                    FLOAT-LONG.
*> USING out count kind a b c: appends one operation (4 numbers) to the operation list of EM6-POSE-CHAIN.
 PROCEDURE DIVISION USING L-OUT L-N L-KIND L-A L-B L-C.
     ADD 1 TO L-N
     MOVE L-KIND TO L-O(L-N * 4 - 2)
     MOVE L-A TO L-O(L-N * 4 - 1)
     MOVE L-B TO L-O(L-N * 4)
     MOVE L-C TO L-O(L-N * 4 + 1)
     GOBACK.
 END PROGRAM EM6-ADD-OP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-CULL-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INF                 FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SIZE                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0.5 TO WS-INF
     IF L-I(7) NOT = 0
         MOVE 1 TO WS-INF
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE L-O(WS-I) = L-I(WS-I) - WS-INF
         COMPUTE L-O(WS-I + 3) = L-I(WS-I + 3) + WS-INF
     END-PERFORM
     COMPUTE WS-SIZE = ((L-O(4) - L-O(1)) + (L-O(5) - L-O(2)) + (L-O(6) - L-O(3))) / 3
     IF L-I(8) NOT = 0 OR WS-SIZE = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             COMPUTE L-O(WS-I) = L-I(WS-I + 8) - 2
             COMPUTE L-O(WS-I + 3) = L-I(WS-I + 8) + 2
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM EM6-CULL-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-AGE-SCALE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-BABY                 BINARY-LONG.
 01 L-AGE                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-TYPE L-BABY L-AGE.
     MOVE 1 TO L-AGE
     IF L-BABY NOT = 0
         EVALUATE L-TYPE
             WHEN "turtle" MOVE 0.3 TO L-AGE
             WHEN "dolphin" MOVE 0.65 TO L-AGE
             WHEN "camel" MOVE 0.6 TO L-AGE
             WHEN "goat" MOVE 0.55 TO L-AGE
             WHEN "happy_ghast" MOVE 0.2375 TO L-AGE
             WHEN "armadillo" MOVE 0.6 TO L-AGE
             WHEN OTHER MOVE 0.5 TO L-AGE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM EM6-AGE-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-RED-OVERLAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HURT                 FLOAT-LONG.
 01 L-DEATH                FLOAT-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HURT L-DEATH L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-HURT > 0 OR L-DEATH > 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM EM6-RED-OVERLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-DEATH-TIME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DEATH                FLOAT-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-STATE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-DEATH L-PARTIAL L-STATE.
     MOVE 0 TO L-STATE
     IF L-DEATH > 0
         COMPUTE L-STATE = L-DEATH + L-PARTIAL
     END-IF
     GOBACK.
 END PROGRAM EM6-DEATH-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-TRANSLUCENT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VISIBLE              BINARY-LONG.
 01 L-INVIS-TO-PLAYER      BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-VISIBLE L-INVIS-TO-PLAYER L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-VISIBLE = 0 AND L-INVIS-TO-PLAYER = 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM EM6-TRANSLUCENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-RENDER-TYPE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VISIBLE              BINARY-LONG.
 01 L-TRANSLUCENT          BINARY-LONG.
 01 L-GLOWING              BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-VISIBLE L-TRANSLUCENT L-GLOWING L-CODE.
     EVALUATE TRUE
         WHEN L-TRANSLUCENT NOT = 0
             MOVE 1 TO L-CODE
         WHEN L-VISIBLE NOT = 0
             MOVE 2 TO L-CODE
         WHEN L-GLOWING NOT = 0
             MOVE 3 TO L-CODE
         WHEN OTHER
             MOVE 0 TO L-CODE
     END-EVALUATE
     GOBACK.
 END PROGRAM EM6-RENDER-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-COLOUR-MULTIPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-SH                  BINARY-LONG.
 01 WS-CA                  BINARY-DOUBLE.
 01 WS-CB                  BINARY-DOUBLE.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-DIV                 BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-A                    BINARY-DOUBLE.
 01 L-B                    BINARY-DOUBLE.
 01 L-OUT                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-A L-B L-OUT.
     MOVE L-A TO WS-A
     MOVE L-B TO WS-B
     IF WS-A < 0
         ADD 4294967296 TO WS-A
     END-IF
     IF WS-B < 0
         ADD 4294967296 TO WS-B
     END-IF
     MOVE 0 TO WS-R
     MOVE 1 TO WS-DIV
     PERFORM VARYING WS-SH FROM 0 BY 1 UNTIL WS-SH > 3
         COMPUTE WS-CA = FUNCTION MOD(FUNCTION INTEGER-PART(WS-A / WS-DIV), 256)
         COMPUTE WS-CB = FUNCTION MOD(FUNCTION INTEGER-PART(WS-B / WS-DIV), 256)
         COMPUTE WS-R = WS-R + FUNCTION INTEGER-PART(WS-CA * WS-CB / 255) * WS-DIV
         COMPUTE WS-DIV = WS-DIV * 256
     END-PERFORM
     IF WS-R >= 2147483648
         SUBTRACT 4294967296 FROM WS-R
     END-IF
     MOVE WS-R TO L-OUT
     GOBACK.
 END PROGRAM EM6-COLOUR-MULTIPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-PIPELINE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-NAME L-OUT.
*>   defaults: cutout 0.1, per-face lighting, culling off, no blend, depth write on
     MOVE 0.1 TO L-O(1)
     MOVE 1 TO L-O(2) L-O(6)
     MOVE 0 TO L-O(3) L-O(4) L-O(5) L-O(7) L-O(8) L-O(9)
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "entityCutout"
             CONTINUE
         WHEN "entity_cutout_z_offset"
             CONTINUE
         WHEN "entityCutoutCull"
             MOVE 0 TO L-O(2)
             MOVE 1 TO L-O(3)
         WHEN "entityTranslucent"
             MOVE 1 TO L-O(4)
         WHEN "entityTranslucentCull"
             MOVE 0 TO L-O(2)
             MOVE 1 TO L-O(3) L-O(4)
         WHEN "entity_cutout_dissolve"
             MOVE 1 TO L-O(9)
         WHEN "armorCutoutNoCull"
             MOVE 1 TO L-O(7)
         WHEN "eyes"
             MOVE 0 TO L-O(1) L-O(2) L-O(6)
             MOVE 1 TO L-O(3) L-O(4) L-O(5) L-O(8)
         WHEN "energySwirl"
             MOVE 0 TO L-O(1) L-O(2)
             MOVE 1 TO L-O(3)
             MOVE 2 TO L-O(4)
         WHEN "entity_translucent_emissive"
             MOVE 1 TO L-O(4) L-O(5) L-O(8)
             MOVE 0 TO L-O(6)
         WHEN "entityShadow"
             MOVE 0 TO L-O(1) L-O(2)
             MOVE 1 TO L-O(3) L-O(4)
         WHEN OTHER
             MOVE -1 TO L-O(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM EM6-PIPELINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM6-RENDERER-EXEMPT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(32).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-TYPE = "player" OR L-TYPE = "mannequin"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM EM6-RENDERER-EXEMPT.
