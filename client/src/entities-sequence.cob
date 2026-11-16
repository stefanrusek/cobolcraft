*> The render sequences (setupRotations) of the mobs that replace or extend the default one (34-1 6.5, EF7-SETUP-ROTATIONS) in the list ENTITY-MODEL-EMIT applies: the count in
*> entry 1, then four numbers per operation (code, three values; the last listed acts first on a vertex): code 1 translate (x, y, z), 2 scale, 3 rotate about Y by the first value
*> in degrees, 5 about X, 7 about Z. Both end with the pipeline's scale (-1, -1, 1) and translate (0, -1.501, 0).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SQUID-SEQUENCE.
*> USING CLIENT-STATE, replica row of a squid or glow squid, ops out (64 FLOAT-LONG): 34-8 2.2: translate (0, 0.5, 0) (baby 0.25), rotate Y by 180 - bodyRot (the yaw), rotate X by xBodyRot,
*> rotate Y by zBodyRot (the field named z turns about Y), translate (0, -1.2, 0) (baby -0.6): EF8-SQUID-ROT-OPS, whose code 6 (rotate X) is 5 here.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-OPS.
    05 L-OP                FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-OPS.
     MOVE EN-YAW(L-ROW) TO WS-IV(1)
     MOVE EN-XR(L-ROW) TO WS-IV(2)
     MOVE EN-ZR(L-ROW) TO WS-IV(3)
     MOVE EN-BABY(L-ROW) TO WS-IV(4)
     CALL "EF8-SQUID-ROT-OPS" USING WS-I WS-O
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 21
         MOVE WS-OV(WS-K) TO L-OP(WS-K)
     END-PERFORM
     MOVE 7 TO L-OP(1)
     MOVE 5 TO L-OP(10)
     MOVE 2 TO L-OP(22)
     MOVE -1 TO L-OP(23) L-OP(24)
     MOVE 1 TO L-OP(25)
     MOVE 1 TO L-OP(26)
     MOVE 0 TO L-OP(27) L-OP(29)
     MOVE -1.501 TO L-OP(28)
     GOBACK.
 END PROGRAM ENTITY-SQUID-SEQUENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FISH-SEQUENCE.
*> USING CLIENT-STATE, replica row of a cod, salmon, tropical fish or pufferfish, ops out (64 FLOAT-LONG): 34-8 5: the pufferfish first translates (0, cos(0.05 age) x 0.08, 0), every fish
*> then turns about Y by 180 - bodyRot; the others add a rotation about Y by (a x 4.3) x sin(b x 0.6 x age) (a, b = 1 in water, the salmon 1.3 and 1.7 out of it) and, out of water,
*> lie on the side: translate (0.1, 0.1, -0.1) (cod) or (0.2, 0.1, 0) (salmon and tropical fish), rotate about Z by 90.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-OPS.
    05 L-OP                FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-OPS.
     MOVE 0 TO WS-N
     IF EN-KEY(L-ROW) = "pufferfish"
         MOVE 1 TO L-OP(2)
         MOVE 0 TO L-OP(3) L-OP(5)
         COMPUTE L-OP(4) = FUNCTION COS(0.05 * EN-AGE(L-ROW)) * 0.08
         MOVE 1 TO WS-N
     END-IF
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 3 TO L-OP(WS-K)
     COMPUTE L-OP(WS-K + 1) = 180 - EN-YAW(L-ROW)
     MOVE 0 TO L-OP(WS-K + 2) L-OP(WS-K + 3)
     IF EN-KEY(L-ROW) NOT = "pufferfish"
         MOVE 1 TO WS-A WS-B
         IF EN-KEY(L-ROW) = "salmon" AND EN-DRY(L-ROW) = 1
             MOVE 1.3 TO WS-A
             MOVE 1.7 TO WS-B
         END-IF
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 3 TO L-OP(WS-K)
         COMPUTE L-OP(WS-K + 1) = WS-A * 4.3 * FUNCTION SIN(WS-B * 0.6 * EN-AGE(L-ROW))
         MOVE 0 TO L-OP(WS-K + 2) L-OP(WS-K + 3)
         IF EN-DRY(L-ROW) = 1
             ADD 1 TO WS-N
             COMPUTE WS-K = WS-N * 4 - 2
             MOVE 1 TO L-OP(WS-K)
             MOVE 0.2 TO L-OP(WS-K + 1)
             MOVE 0.1 TO L-OP(WS-K + 2)
             MOVE 0 TO L-OP(WS-K + 3)
             IF EN-KEY(L-ROW) = "cod"
                 MOVE 0.1 TO L-OP(WS-K + 1)
                 MOVE -0.1 TO L-OP(WS-K + 3)
             END-IF
             ADD 1 TO WS-N
             COMPUTE WS-K = WS-N * 4 - 2
             MOVE 7 TO L-OP(WS-K)
             MOVE 90 TO L-OP(WS-K + 1)
             MOVE 0 TO L-OP(WS-K + 2) L-OP(WS-K + 3)
         END-IF
     END-IF
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 2 TO L-OP(WS-K)
     MOVE -1 TO L-OP(WS-K + 1) L-OP(WS-K + 2)
     MOVE 1 TO L-OP(WS-K + 3)
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 1 TO L-OP(WS-K)
     MOVE 0 TO L-OP(WS-K + 1) L-OP(WS-K + 3)
     MOVE -1.501 TO L-OP(WS-K + 2)
     MOVE WS-N TO L-OP(1)
     GOBACK.
 END PROGRAM ENTITY-FISH-SEQUENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FANGS-SEQUENCE.
*> USING CLIENT-STATE, replica row of evoker fangs, ops out (64 FLOAT-LONG): 34-3 4.8: rotate Y by 90 - yaw, scale (-1, -1, 1), translate (0, -1.501, 0) (EM3-FANGS-OPS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-OPS.
    05 L-OP                FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-OPS.
     MOVE EN-YAW(L-ROW) TO WS-IV(1)
     CALL "ENTITY-FANGS-PROGRESS" USING CLIENT-STATE L-ROW WS-IV(2)
     CALL "EM3-FANGS-OPS" USING WS-I WS-O
     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 14
         MOVE WS-OV(WS-K) TO L-OP(WS-K - 1)
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-FANGS-SEQUENCE.
