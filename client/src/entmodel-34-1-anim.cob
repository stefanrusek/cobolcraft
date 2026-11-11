*> Entity models part 1 section 5 (docs/protocol/34-entity-models-1-shared-model-and-framework.md): the keyframe animation engine. Records: client/copy/CLEM5.cpy
*> (the definition) and CLEM2.cpy (the mesh whose parts are animated).
*> Entry points for the integrator (inputs):
*>   EM5-POSVEC v(3 floats) out; EM5-DEGREEVEC v out; EM5-SCALEVEC v out: the authoring helpers of 5.1.
*>   EM5-EVAL-CHANNEL EM5-DEF channel(1..) t(seconds) scale out(3 floats): 5.2. EM5-WALK-TIME walk-pos walk-speed time-factor speed-factor ms(out) scale(out): 5.3.
*>   EM5-ALL-PARTS EM2-MESH order(64 binary-long, out) count: getAllParts order; EM5-FIND-PART EM2-MESH name index(out, 0 absent): the flat name map of 1.5.
*>   EM5-APPLY EM2-MESH EM5-DEF ms(binary-long) scale ok(out): bakes (every bone must exist: else ok 0 and nothing changes) and runs one animation, adding to the
*>     parts' current pose after the caller's own formulas. EM5-STATE op start-tick(in/out) IN(tick-or-age, flag-or-n, rate) result: AnimationState (5.5), ops
*>     1 start, 2 startIfStopped, 3 stop, 4 animateWhen, 5 fastForward, 6 getTimeInMillis (result in ms), 7 ifStarted (result 1 when started); result is
*>     also 1 or 0 for isStarted after ops 1 to 5.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM5-POSVEC.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V.
    05 L-VV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-O.
    05 L-OV                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-V L-O.
     MOVE L-VV(1) TO L-OV(1)
     COMPUTE L-OV(2) = -L-VV(2)
     MOVE L-VV(3) TO L-OV(3)
     GOBACK.
 END PROGRAM EM5-POSVEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM5-DEGREEVEC.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V.
    05 L-VV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-O.
    05 L-OV                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-V L-O.
     COMPUTE L-OV(1) = L-VV(1) * 0.017453292
     COMPUTE L-OV(2) = L-VV(2) * 0.017453292
     COMPUTE L-OV(3) = L-VV(3) * 0.017453292
     GOBACK.
 END PROGRAM EM5-DEGREEVEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM5-SCALEVEC.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V.
    05 L-VV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-O.
    05 L-OV                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-V L-O.
     COMPUTE L-OV(1) = L-VV(1) - 1
     COMPUTE L-OV(2) = L-VV(2) - 1
     COMPUTE L-OV(3) = L-VV(3) - 1
     GOBACK.
 END PROGRAM EM5-SCALEVEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM5-EVAL-CHANNEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-P0                  BINARY-LONG.
 01 WS-P3                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ALPHA               FLOAT-LONG.
 01 WS-C0                  FLOAT-LONG.
 01 WS-C1                  FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-C3                  FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEM5.
 01 L-CH                   BINARY-LONG.
 01 L-T                    FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING EM5-DEF L-CH L-T L-SCALE L-OUT.
     MOVE AC-KEYS(L-CH) TO WS-N
*>   f: the first keyframe (1-based) whose timestamp is >= t, n + 1 when none
     COMPUTE WS-F = WS-N + 1
     PERFORM VARYING WS-K FROM WS-N BY -1 UNTIL WS-K < 1
         IF AK-TS(L-CH, WS-K) >= L-T
             MOVE WS-K TO WS-F
         END-IF
     END-PERFORM
     COMPUTE WS-I = WS-F - 1
     IF WS-I < 1
         MOVE 1 TO WS-I
     END-IF
     COMPUTE WS-J = WS-I + 1
     IF WS-J > WS-N
         MOVE WS-N TO WS-J
     END-IF
     MOVE 0 TO WS-ALPHA
     IF WS-I NOT = WS-J
         COMPUTE WS-ALPHA = (L-T - AK-TS(L-CH, WS-I)) / (AK-TS(L-CH, WS-J) - AK-TS(L-CH, WS-I))
         IF WS-ALPHA < 0
             MOVE 0 TO WS-ALPHA
         END-IF
*>       the upper clamp of 5.2 step 2 never acts: ts[i] < t <= ts[j] by the choice of f
     END-IF
     COMPUTE WS-P0 = WS-I - 1
     IF WS-P0 < 1
         MOVE 1 TO WS-P0
     END-IF
     COMPUTE WS-P3 = WS-J + 1
     IF WS-P3 > WS-N
         MOVE WS-N TO WS-P3
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         IF AK-INTERP(L-CH, WS-J) = 2
             MOVE AK-POST(L-CH, WS-P0, WS-K) TO WS-C0
             MOVE AK-POST(L-CH, WS-I, WS-K) TO WS-C1
             MOVE AK-POST(L-CH, WS-J, WS-K) TO WS-C2
             MOVE AK-POST(L-CH, WS-P3, WS-K) TO WS-C3
             COMPUTE WS-V = 0.5 * (2 * WS-C1 + (WS-C2 - WS-C0) * WS-ALPHA
                 + (2 * WS-C0 - 5 * WS-C1 + 4 * WS-C2 - WS-C3) * WS-ALPHA * WS-ALPHA
                 + (3 * WS-C1 - WS-C0 - 3 * WS-C2 + WS-C3) * WS-ALPHA * WS-ALPHA * WS-ALPHA)
         ELSE
             COMPUTE WS-V = AK-POST(L-CH, WS-I, WS-K) + (AK-PRE(L-CH, WS-J, WS-K) - AK-POST(L-CH, WS-I, WS-K)) * WS-ALPHA
         END-IF
         COMPUTE L-O(WS-K) = WS-V * L-SCALE
     END-PERFORM
     GOBACK.
 END PROGRAM EM5-EVAL-CHANNEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM5-WALK-TIME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POS                  FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-TF                   FLOAT-LONG.
 01 L-SF                   FLOAT-LONG.
 01 L-MS                   BINARY-LONG.
 01 L-SCALE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-POS L-SPEED L-TF L-SF L-MS L-SCALE.
     COMPUTE L-MS = FUNCTION INTEGER-PART(L-POS * 50 * L-TF)
     COMPUTE L-SCALE = L-SPEED * L-SF
     IF L-SCALE > 1
         MOVE 1 TO L-SCALE
     END-IF
     GOBACK.
 END PROGRAM EM5-WALK-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM5-ALL-PARTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STACK               BINARY-LONG OCCURS 64 TIMES.
 01 WS-SP                  BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KIDS                BINARY-LONG OCCURS 64 TIMES.
 01 WS-NK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEM2.
 01 L-ORDER.
    05 L-ORD               BINARY-LONG OCCURS 64 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING EM2-MESH L-ORDER L-COUNT.
     MOVE 1 TO L-ORD(1)
     MOVE 1 TO L-COUNT
     MOVE 1 TO WS-SP
     MOVE 1 TO WS-STACK(1)
     PERFORM UNTIL WS-SP = 0
         MOVE WS-STACK(WS-SP) TO WS-NODE
         SUBTRACT 1 FROM WS-SP
         MOVE 0 TO WS-NK
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > MH-COUNT
             IF MH-PARENT(WS-I) = WS-NODE
                 ADD 1 TO L-COUNT
                 MOVE WS-I TO L-ORD(L-COUNT)
                 ADD 1 TO WS-NK
                 MOVE WS-I TO WS-KIDS(WS-NK)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM WS-NK BY -1 UNTIL WS-I < 1
             ADD 1 TO WS-SP
             MOVE WS-KIDS(WS-I) TO WS-STACK(WS-SP)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM EM5-ALL-PARTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM5-FIND-PART.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ORDER.
    05 WS-ORD              BINARY-LONG OCCURS 64 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEM2.
 01 L-NAME                 PIC X(24).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING EM2-MESH L-NAME L-INDEX.
     MOVE 0 TO L-INDEX
     CALL "EM5-ALL-PARTS" USING EM2-MESH WS-ORDER WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF MH-NAME(WS-ORD(WS-I)) = L-NAME
             MOVE WS-ORD(WS-I) TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM5-FIND-PART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM5-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-V.
    05 WS-VV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FLOOR               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEM2.
 COPY CLEM5.
 01 L-MS                   BINARY-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING EM2-MESH EM5-DEF L-MS L-SCALE L-OK.
     MOVE 1 TO L-OK
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > AD-CHANNELS
         CALL "EM5-FIND-PART" USING EM2-MESH AC-BONE(WS-C) WS-PART
         IF WS-PART = 0
             MOVE 0 TO L-OK
         END-IF
     END-PERFORM
     IF L-OK = 0
         GOBACK
     END-IF
     COMPUTE WS-S = L-MS / 1000
     IF AD-LOOP NOT = 0
         COMPUTE WS-FLOOR = FUNCTION INTEGER(WS-S / AD-LENGTH)
         COMPUTE WS-S = WS-S - AD-LENGTH * WS-FLOOR
     END-IF
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > AD-CHANNELS
         CALL "EM5-FIND-PART" USING EM2-MESH AC-BONE(WS-C) WS-PART
         CALL "EM5-EVAL-CHANNEL" USING EM5-DEF WS-C WS-S L-SCALE WS-V
         EVALUATE AC-TARGET(WS-C)
             WHEN 1
                 COMPUTE MH-X(WS-PART) = MH-X(WS-PART) + WS-VV(1)
                 COMPUTE MH-Y(WS-PART) = MH-Y(WS-PART) + WS-VV(2)
                 COMPUTE MH-Z(WS-PART) = MH-Z(WS-PART) + WS-VV(3)
             WHEN 2
                 COMPUTE MH-XROT(WS-PART) = MH-XROT(WS-PART) + WS-VV(1)
                 COMPUTE MH-YROT(WS-PART) = MH-YROT(WS-PART) + WS-VV(2)
                 COMPUTE MH-ZROT(WS-PART) = MH-ZROT(WS-PART) + WS-VV(3)
             WHEN OTHER
                 COMPUTE MH-XSCALE(WS-PART) = MH-XSCALE(WS-PART) + WS-VV(1)
                 COMPUTE MH-YSCALE(WS-PART) = MH-YSCALE(WS-PART) + WS-VV(2)
                 COMPUTE MH-ZSCALE(WS-PART) = MH-ZSCALE(WS-PART) + WS-VV(3)
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM EM5-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM5-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STOPPED             BINARY-LONG VALUE -2147483648.
 01 WS-TICK                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-OP                   BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 4 TIMES.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-OP L-START L-IN L-RESULT.
     COMPUTE WS-TICK = FUNCTION INTEGER-PART(L-I(1))
     EVALUATE L-OP
         WHEN 1
             MOVE WS-TICK TO L-START
         WHEN 2
             IF L-START = WS-STOPPED
                 MOVE WS-TICK TO L-START
             END-IF
         WHEN 3
             MOVE WS-STOPPED TO L-START
         WHEN 4
             IF L-I(2) NOT = 0
                 IF L-START = WS-STOPPED
                     MOVE WS-TICK TO L-START
                 END-IF
             ELSE
                 MOVE WS-STOPPED TO L-START
             END-IF
         WHEN 5
             IF L-START NOT = WS-STOPPED
                 COMPUTE WS-N = FUNCTION INTEGER-PART(L-I(2) * L-I(3))
                 SUBTRACT WS-N FROM L-START
             END-IF
         WHEN 6
             COMPUTE L-RESULT = FUNCTION INTEGER-PART((L-I(1) - L-START) * 50)
     END-EVALUATE
     IF L-OP NOT = 6
         MOVE 0 TO L-RESULT
         IF L-START NOT = WS-STOPPED
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EM5-STATE.
