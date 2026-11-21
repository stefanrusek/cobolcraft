*> Acceptance test of docs/protocol/34-entity-models-1-shared-model-and-framework.md section 5 (Keyframe animation engine): 5.1 the authoring helpers
*> and additive targets, 5.2 channel evaluation (linear, Catmull-Rom, the end rules), 5.3 running (walk time, looping, bake errors), 5.4 the worked
*> example and V9, 5.5 the animation state.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-1-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEM2.
 COPY CLEM5.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-V.
    05 WS-VV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-W.
    05 WS-WV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CH                  BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PARENT              BINARY-LONG.
 01 WS-PNAME               PIC X(24).
 01 WS-CUBES               BINARY-LONG.
 01 WS-POSE.
    05 WS-P                FLOAT-LONG OCCURS 9 TIMES.
 01 WS-HEAD                BINARY-LONG.
 01 WS-ARM1                BINARY-LONG.
 01 WS-ARM2                BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-SCALE-OUT           FLOAT-LONG.
 01 WS-WALK-POS            FLOAT-LONG.
 01 WS-WALK-SPEED          FLOAT-LONG.
 01 WS-TF                  FLOAT-LONG.
 01 WS-SF                  FLOAT-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-IN.
    05 WS-I                FLOAT-LONG OCCURS 4 TIMES.
 01 WS-RES                 FLOAT-LONG.
 01 WS-ORDER.
    05 WS-ORD              BINARY-LONG OCCURS 64 TIMES.
 01 WS-ORDN                BINARY-LONG.
 01 WS-TXT                 PIC X(80).
 01 WS-K                   BINARY-LONG.
 PROCEDURE DIVISION.
*> 5.1 authoring helpers.
     MOVE 1 TO WS-VV(1)
     MOVE 2 TO WS-VV(2)
     MOVE 3 TO WS-VV(3)
     CALL "EM5-POSVEC" USING WS-V WS-W
     MOVE "posVec negates y" TO WS-NAME
     COMPUTE WS-O = WS-WV(1) * 100 + WS-WV(2) * 10 + WS-WV(3)
     COMPUTE WS-E = 100 - 20 + 3
     PERFORM CHECK-NUM
     MOVE 90 TO WS-VV(1)
     MOVE 180 TO WS-VV(2)
     MOVE 0 TO WS-VV(3)
     CALL "EM5-DEGREEVEC" USING WS-V WS-W
     MOVE "degreeVec converts with 0.017453292" TO WS-NAME
     COMPUTE WS-O = WS-WV(1) * 10 + WS-WV(2)
     COMPUTE WS-E = 90 * 0.017453292 * 10 + 180 * 0.017453292
     PERFORM CHECK-NUM
     MOVE 2 TO WS-VV(1)
     MOVE 1 TO WS-VV(2)
     MOVE 0.5 TO WS-VV(3)
     CALL "EM5-SCALEVEC" USING WS-V WS-W
     MOVE "scaleVec subtracts one" TO WS-NAME
     COMPUTE WS-O = WS-WV(1) * 100 + WS-WV(2) * 10 + WS-WV(3)
     COMPUTE WS-E = 100 + 0 - 0.5
     PERFORM CHECK-NUM
*> 5.4 worked example: rotation channel on yRot, k0 (0, 0), k1 (1, 1.5707964), linear.
     PERFORM BUILD-LINEAR
     MOVE 0.25 TO WS-T
     PERFORM EVAL-ROT
     MOVE "5.4 t = 0.25 gives 0.3926991" TO WS-NAME
     MOVE 0.3926991 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.5 TO WS-T
     PERFORM EVAL-ROT
     MOVE "V9 past the end gives the last post value" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-T
     PERFORM EVAL-ROT
     MOVE "V9 before the start gives the first post value" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-T
     PERFORM EVAL-ROT
     MOVE "t equal to the first timestamp gives post[0]" TO WS-NAME
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-T
     PERFORM EVAL-ROT
     MOVE "t equal to the last timestamp gives alpha 1" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
*>   a jump keyframe: at the last timestamp the value is pre[n-1], after it post[n-1].
     MOVE 3 TO AK-PRE(1, 1, 2)
     MOVE 7 TO AK-POST(1, 2, 2)
     MOVE 4 TO AK-PRE(1, 2, 2)
     MOVE 1 TO WS-T
     PERFORM EVAL-ROT
     MOVE "at the last timestamp the pre target of the last key" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.0001 TO WS-T
     PERFORM EVAL-ROT
     MOVE "after the last timestamp the post target" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
*>   scale multiplies the interpolated offset.
     PERFORM BUILD-LINEAR
     MOVE 0.5 TO WS-T
     MOVE 0.5 TO WS-SCALE
     PERFORM EVAL-ROT-SCALED
     MOVE "scale multiplies the value" TO WS-NAME
     MOVE 0.3926991 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
*>   a single keyframe: i = j = 0.
     MOVE 1 TO AC-KEYS(1)
     MOVE 5 TO AK-POST(1, 1, 2)
     MOVE 9 TO WS-T
     MOVE 1 TO WS-SCALE
     PERFORM EVAL-ROT-SCALED
     MOVE "a single keyframe gives its post target" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
*> V9 Catmull-Rom: post values 0, 0, 1, 1 at 0..3, segment k1 to k2; the interpolation of key j (k2).
     PERFORM BUILD-CATMULL
     MOVE 1.5 TO WS-T
     PERFORM EVAL-ROT
     MOVE "V9 Catmull-Rom alpha 0.5 gives 0.5" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.25 TO WS-T
     PERFORM EVAL-ROT
     MOVE "V9 Catmull-Rom alpha 0.25 gives 0.203125" TO WS-NAME
     MOVE 0.203125 TO WS-E
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-T
     PERFORM EVAL-ROT
     MOVE "Catmull-Rom at the first segment uses the first key twice" TO WS-NAME
     COMPUTE WS-E = 0.5 * (2 * 0 + (0 - 0) * 0.5 + (2 * 0 - 5 * 0 + 4 * 0 - 1) * 0.25 + (3 * 0 - 0 - 3 * 0 + 1) * 0.125)
     MOVE WS-WV(2) TO WS-O
     PERFORM CHECK-NUM
*> 5.3 running: time bases.
     MOVE 10 TO WS-WALK-POS
     MOVE 0.5 TO WS-WALK-SPEED
     MOVE 1 TO WS-TF
     MOVE 1 TO WS-SF
     CALL "EM5-WALK-TIME" USING WS-WALK-POS WS-WALK-SPEED WS-TF WS-SF WS-MS WS-SCALE-OUT
     MOVE "applyWalk(10, 0.5, 1, 1) time is 500 ms" TO WS-NAME
     MOVE 500 TO WS-E
     MOVE WS-MS TO WS-O
     PERFORM CHECK-NUM
     MOVE "applyWalk scale is 0.5" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SCALE-OUT TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-WALK-SPEED
     MOVE 2 TO WS-SF
     MOVE 2 TO WS-TF
     CALL "EM5-WALK-TIME" USING WS-WALK-POS WS-WALK-SPEED WS-TF WS-SF WS-MS WS-SCALE-OUT
     MOVE "walk scale is clamped to 1 and time takes the time factor" TO WS-NAME
     COMPUTE WS-O = WS-MS * 10 + WS-SCALE-OUT
     COMPUTE WS-E = 1000 * 10 + 1
     PERFORM CHECK-NUM
     MOVE 10.0399 TO WS-WALK-POS
     MOVE 1 TO WS-TF
     CALL "EM5-WALK-TIME" USING WS-WALK-POS WS-WALK-SPEED WS-TF WS-SF WS-MS WS-SCALE-OUT
     MOVE "walk time truncates" TO WS-NAME
     MOVE 501 TO WS-E
     MOVE WS-MS TO WS-O
     PERFORM CHECK-NUM
*>   mesh and bone lookup
     PERFORM BUILD-MESH
*>   5.3: apply a rotation channel on head through a mesh at 500 ms with scale 0.5 (the 5.4 example).
     PERFORM BUILD-LINEAR
     MOVE "head" TO AC-BONE(1)
     MOVE 500 TO WS-MS
     MOVE 0.5 TO WS-SCALE
     CALL "EM5-APPLY" USING EM2-MESH EM5-DEF WS-MS WS-SCALE WS-OK
     MOVE "5.4 apply through the flat name map adds to yRot" TO WS-NAME
     MOVE 0.3926991 TO WS-E
     MOVE MH-YROT(WS-HEAD) TO WS-O
     PERFORM CHECK-NUM
     MOVE "apply reports success" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EM5-APPLY" USING EM2-MESH EM5-DEF WS-MS WS-SCALE WS-OK
     MOVE "targets are additive: a second run adds again" TO WS-NAME
     COMPUTE WS-E = 0.3926991 * 2
     MOVE MH-YROT(WS-HEAD) TO WS-O
     PERFORM CHECK-NUM
*>   position and scale targets add to x y z and the scales.
     MOVE 1 TO AC-TARGET(1)
     MOVE 1 TO AK-POST(1, 1, 1)
     MOVE 2 TO AK-POST(1, 2, 1)
     MOVE 2 TO AK-PRE(1, 2, 1)
     MOVE 1 TO WS-SCALE
     MOVE 1000 TO WS-MS
     CALL "EM5-APPLY" USING EM2-MESH EM5-DEF WS-MS WS-SCALE WS-OK
     MOVE "position target adds to x" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE MH-X(WS-HEAD) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO AC-TARGET(1)
     MOVE 1000 TO WS-MS
     CALL "EM5-APPLY" USING EM2-MESH EM5-DEF WS-MS WS-SCALE WS-OK
     MOVE "scale target adds to the scale (1 + 2)" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE MH-XSCALE(WS-HEAD) TO WS-O
     PERFORM CHECK-NUM
*>   a missing bone makes the bake fail and nothing is applied.
     MOVE "wing" TO AC-BONE(1)
     MOVE 0 TO MH-X(WS-HEAD)
     MOVE 2 TO AC-TARGET(1)
     CALL "EM5-APPLY" USING EM2-MESH EM5-DEF WS-MS WS-SCALE WS-OK
     MOVE "a missing bone fails the bake" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
*>   looping: length 2 s at 5500 ms evaluates at 1.5 s; a non-looping run clamps at the last keyframe.
     PERFORM BUILD-LOOP
     MOVE "head" TO AC-BONE(1)
     MOVE 0 TO MH-YROT(WS-HEAD)
     MOVE 5500 TO WS-MS
     MOVE 1 TO WS-SCALE
     CALL "EM5-APPLY" USING EM2-MESH EM5-DEF WS-MS WS-SCALE WS-OK
     MOVE "looping animation evaluates at 1.5 s" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE MH-YROT(WS-HEAD) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO AD-LOOP
     MOVE 0 TO MH-YROT(WS-HEAD)
     CALL "EM5-APPLY" USING EM2-MESH EM5-DEF WS-MS WS-SCALE WS-OK
     MOVE "non-looping animation clamps at the last keyframe" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE MH-YROT(WS-HEAD) TO WS-O
     PERFORM CHECK-NUM
*>   flat names: the last visited part with a name wins; the root is "root".
     PERFORM BUILD-MESH
     MOVE "arm" TO WS-PNAME
     CALL "EM5-FIND-PART" USING EM2-MESH WS-PNAME WS-IDX
     MOVE "duplicate names: the one visited last wins" TO WS-NAME
     MOVE WS-ARM2 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-NUM
     MOVE "root" TO WS-PNAME
     CALL "EM5-FIND-PART" USING EM2-MESH WS-PNAME WS-IDX
     MOVE "the key root is the root part" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PNAME
     CALL "EM5-FIND-PART" USING EM2-MESH WS-PNAME WS-IDX
     MOVE "an absent name finds nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-NUM
     CALL "EM5-ALL-PARTS" USING EM2-MESH WS-ORDER WS-ORDN
     MOVE "getAllParts order: root, children, then descendants of each child" TO WS-NAME
     MOVE SPACES TO WS-TXT
     MOVE 1 TO WS-K
     PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > WS-ORDN
         STRING FUNCTION TRIM(MH-NAME(WS-ORD(WS-IDX))) "," DELIMITED BY SIZE INTO WS-TXT WITH POINTER WS-K
     END-PERFORM
     MOVE "root,head,body,arm,sleeve,arm,glove," TO TL-EXPECTED
     MOVE WS-TXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
*> 5.5 AnimationState.
     MOVE -2147483648 TO WS-START
     MOVE 5 TO WS-I(1)
     MOVE 1 TO WS-OP
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "start sets the start tick" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-START TO WS-O
     PERFORM CHECK-NUM
     MOVE "isStarted after start" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-I(1)
     MOVE 2 TO WS-OP
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "startIfStopped keeps a running state" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-START TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-OP
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "stop restores the sentinel" TO WS-NAME
     MOVE -2147483648 TO WS-E
     MOVE WS-START TO WS-O
     PERFORM CHECK-NUM
     MOVE "isStarted after stop" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-OP
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "startIfStopped starts a stopped state" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-START TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-I(2)
     MOVE 4 TO WS-OP
     MOVE 12 TO WS-I(1)
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "animateWhen true keeps a started state" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-START TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-I(2)
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "animateWhen false stops" TO WS-NAME
     MOVE -2147483648 TO WS-E
     MOVE WS-START TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-I(2)
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "animateWhen true starts a stopped state" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-START TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-OP
     MOVE 3.5 TO WS-I(2)
     MOVE 2 TO WS-I(3)
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "fastForward subtracts trunc(n x rate)" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-START TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-OP
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE 5 TO WS-OP
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "fastForward on a stopped state does nothing" TO WS-NAME
     MOVE -2147483648 TO WS-E
     MOVE WS-START TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-OP
     MOVE 10 TO WS-START
     MOVE 12.5 TO WS-I(1)
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "getTimeInMillis = trunc((age - start) x 50)" TO WS-NAME
     MOVE 125 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.99 TO WS-I(1)
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "getTimeInMillis truncates toward zero" TO WS-NAME
     MOVE -300 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-I(2)
     MOVE 1 TO WS-OP
     MOVE 77 TO WS-I(1)
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE 7 TO WS-OP
     CALL "EM5-STATE" USING WS-OP WS-START WS-IN WS-RES
     MOVE "ifStarted runs for a started state" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 BUILD-LINEAR.
     INITIALIZE EM5-DEF
     MOVE 1 TO AD-CHANNELS
     MOVE "head" TO AC-BONE(1)
     MOVE 2 TO AC-TARGET(1)
     MOVE 2 TO AC-KEYS(1)
     MOVE 0 TO AK-TS(1, 1)
     MOVE 1 TO AK-INTERP(1, 1)
     MOVE 1 TO AK-TS(1, 2)
     MOVE 1.5707964 TO AK-PRE(1, 2, 2) AK-POST(1, 2, 2)
     MOVE 1 TO AK-INTERP(1, 2).

 BUILD-CATMULL.
     INITIALIZE EM5-DEF
     MOVE 1 TO AD-CHANNELS
     MOVE "head" TO AC-BONE(1)
     MOVE 2 TO AC-TARGET(1)
     MOVE 4 TO AC-KEYS(1)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE AK-TS(1, WS-K) = WS-K - 1
         MOVE 2 TO AK-INTERP(1, WS-K)
     END-PERFORM
     MOVE 1 TO AK-PRE(1, 3, 2) AK-POST(1, 3, 2) AK-PRE(1, 4, 2) AK-POST(1, 4, 2).

 BUILD-LOOP.
     INITIALIZE EM5-DEF
     MOVE 2 TO AD-LENGTH
     MOVE 1 TO AD-LOOP
     MOVE 1 TO AD-CHANNELS
     MOVE "head" TO AC-BONE(1)
     MOVE 2 TO AC-TARGET(1)
     MOVE 2 TO AC-KEYS(1)
     MOVE 0 TO AK-TS(1, 1)
     MOVE 1 TO AK-INTERP(1, 1)
     MOVE 2 TO AK-TS(1, 2)
     MOVE 2 TO AK-PRE(1, 2, 2) AK-POST(1, 2, 2)
     MOVE 1 TO AK-INTERP(1, 2).

 BUILD-MESH.
     CALL "EM2-MESH-INIT" USING EM2-MESH
     MOVE 1 TO WS-PARENT
     MOVE 1 TO WS-CUBES
     MOVE 0 TO WS-P(1) WS-P(2) WS-P(3) WS-P(4) WS-P(5) WS-P(6)
     MOVE 1 TO WS-P(7) WS-P(8) WS-P(9)
     MOVE "head" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-CUBES WS-POSE WS-HEAD
     MOVE "body" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-CUBES WS-POSE WS-BODY
     MOVE "arm" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-HEAD WS-PNAME WS-CUBES WS-POSE WS-ARM1
     MOVE "arm" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-BODY WS-PNAME WS-CUBES WS-POSE WS-ARM2
     MOVE "sleeve" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-ARM1 WS-PNAME WS-CUBES WS-POSE WS-IDX
     MOVE "glove" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-ARM2 WS-PNAME WS-CUBES WS-POSE WS-IDX.

 EVAL-ROT.
     MOVE 1 TO WS-SCALE
     PERFORM EVAL-ROT-SCALED.

 EVAL-ROT-SCALED.
     MOVE 1 TO WS-CH
     CALL "EM5-EVAL-CHANNEL" USING EM5-DEF WS-CH WS-T WS-SCALE WS-W.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§5 Keyframe animation engine: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§5 Keyframe animation engine: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-1-5.
