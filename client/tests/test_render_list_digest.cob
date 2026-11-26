*> Taken again for CC-0013 (4748648f): the section opaque draws use the pipeline CC-PIPE-OPAQUE-CULL (6, back faces culled) instead of CC-PIPE-OPAQUE. With the pipeline of those draws (37172 of the 50078 draw records) put back to CC-PIPE-OPAQUE before the CRC, the code of this test made the previous digest 7402413475844806013 again: nothing else of the render list (slots, textures, matrices, draw counts, uploads, projection, view, fog) moved.
*> Equivalence and cost test of RENDER-LIST-BUILD (lane perfframe): a replica of 625 chunk rows (view distance 12) whose 24 sections each hold, by a fixed hash, an opaque
*> mesh, a translucent mesh, both or none, is drawn from 60 eyes (position, yaw, pitch over the whole turn, one eye under the surface), and the draw records of every frame
*> (slot, pipeline, texture and the 16 floats of the matrix; the draw count) and the upload slots and counts are digested (CRC-32, summed with the frame as weight).
*> The digest was taken from the code before the lane's changes and must stay the same byte for byte: the render list is the same list. The cost of a frame is shown
*> (PERF) and has to stay within a bound the code before the changes did not keep.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RENDER-LIST-DIGEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CLTINT.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-F                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG VALUE 60.
 01 WS-ENV                 PIC X(16).
 01 WS-REPEAT              BINARY-LONG VALUE 1.
 01 WS-REP                 BINARY-LONG.
 01 WS-ZERO                BINARY-DOUBLE VALUE 0.
 01 WS-L64                 BINARY-DOUBLE VALUE 64.
 01 WS-L52                 BINARY-DOUBLE VALUE 52.
 01 WS-BYTES               BINARY-DOUBLE.
 01 WS-CRC                 BINARY-DOUBLE UNSIGNED.
 01 WS-DIGEST              BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-UPLOADS             BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-WEIGHT              BINARY-DOUBLE.
 01 WS-DRAWS               BINARY-DOUBLE VALUE 0.
 01 WS-MAX-DRAWS           BINARY-LONG VALUE 0.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE VALUE 0.
 01 WS-D19                 PIC Z(18)9.
 01 WS-D9                  PIC Z(8)9.
 01 WS-D9B                 PIC Z(8)9.
 01 WS-DUMMY               PIC X(64).
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 800 TO IN-WIN-W
     MOVE 600 TO IN-WIN-H
     MOVE 256 TO PL-HEIGHT
     MOVE -64 TO PL-MIN-Y
     MOVE SCR-WORLD TO SM-SCREEN
*>   A spectator has no hand (53 section 15.1): the digest is of the world's render list, not of the hand drawn over it (the empty hand's arm of lane p70).
     MOVE 3 TO PL-MODE
     MOVE 0 TO PL-HAS-SKY
     MOVE 6000 TO PL-TIME
     MOVE 12 TO PL-VIEW-DISTANCE
     MOVE 0 TO WR-COUNT
     PERFORM VARYING WS-CX FROM -12 BY 1 UNTIL WS-CX > 12
         PERFORM VARYING WS-CZ FROM -12 BY 1 UNTIL WS-CZ > 12
             ADD 1 TO WR-COUNT
             MOVE WR-COUNT TO WS-R
             MOVE 1 TO WR-USED(WS-R)
             MOVE WS-CX TO WR-CX(WS-R)
             MOVE WS-CZ TO WR-CZ(WS-R)
             MOVE 0 TO WR-RELEASE(WS-R)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 MOVE 0 TO WR-OP-COUNT(WS-R, WS-S) WR-TR-COUNT(WS-R, WS-S) WR-UPLOAD(WS-R, WS-S)
                 COMPUTE WS-H = FUNCTION MOD(WS-R * 7919 + WS-S * 104729 + WS-CX * 31 + WS-CZ * 17, 11)
                 EVALUATE TRUE
                     WHEN WS-H < 3 AND WS-S > 3 AND WS-S < 12
                         MOVE 600 TO WR-OP-COUNT(WS-R, WS-S)
                     WHEN WS-H = 3 AND WS-S > 3 AND WS-S < 9
                         MOVE 120 TO WR-TR-COUNT(WS-R, WS-S)
                     WHEN WS-H = 4 AND WS-S > 4 AND WS-S < 10
                         MOVE 480 TO WR-OP-COUNT(WS-R, WS-S)
                         MOVE 60 TO WR-TR-COUNT(WS-R, WS-S)
                     WHEN OTHER
                         CONTINUE
                 END-EVALUATE
                 IF WR-OP-COUNT(WS-R, WS-S) + WR-TR-COUNT(WS-R, WS-S) > 0 AND FUNCTION MOD(WS-R + WS-S, 13) = 0
                     MOVE 1 TO WR-UPLOAD(WS-R, WS-S)
                 END-IF
                 SET WR-OP-ADDR(WS-R, WS-S) TO ADDRESS OF WS-DUMMY
                 SET WR-TR-ADDR(WS-R, WS-S) TO ADDRESS OF WS-DUMMY
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-FRAMES
         COMPUTE PL-X = 3.5 + FUNCTION MOD(WS-F * 5, 16) + 0.25 * WS-F
         COMPUTE PL-Z = -2.5 + FUNCTION MOD(WS-F * 11, 16) - 0.125 * WS-F
         COMPUTE PL-Y = 60.5 + FUNCTION MOD(WS-F, 7)
         COMPUTE PL-YAW = FUNCTION MOD(WS-F * 37, 360) + 0.5
         COMPUTE PL-PITCH = FUNCTION MOD(WS-F * 13, 120) - 60
         MOVE 0 TO PL-EYE-WATER
         IF WS-F = 7
             MOVE 1 TO PL-EYE-LAVA
         ELSE
             MOVE 0 TO PL-EYE-LAVA
         END-IF
         IF FUNCTION MOD(WS-F, 4) = 0
             PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                     IF WR-OP-COUNT(WS-R, WS-S) + WR-TR-COUNT(WS-R, WS-S) > 0 AND FUNCTION MOD(WS-R + WS-S + WS-F, 9) = 0
                         MOVE 1 TO WR-UPLOAD(WS-R, WS-S)
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
         CALL STATIC "clock" RETURNING WS-T0
         CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US = WS-US + WS-T1 - WS-T0
         COMPUTE WS-BYTES = RL-DRAW-COUNT * 76
         ADD RL-DRAW-COUNT TO WS-DRAWS
         IF RL-DRAW-COUNT > WS-MAX-DRAWS
             MOVE RL-DRAW-COUNT TO WS-MAX-DRAWS
         END-IF
         CALL STATIC "crc32" USING BY VALUE WS-ZERO BY REFERENCE RL-DRAW(1) BY VALUE WS-BYTES RETURNING WS-CRC
         COMPUTE WS-WEIGHT = WS-F * 1000003
         COMPUTE WS-DIGEST = FUNCTION MOD(WS-DIGEST + WS-CRC * WS-WEIGHT, 9223372036854775783)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
             COMPUTE WS-UPLOADS = FUNCTION MOD(WS-UPLOADS + (RL-U-SLOT(WS-I) * 31 + RL-U-COUNT(WS-I)) * WS-F, 9223372036854775783)
         END-PERFORM
         CALL STATIC "crc32" USING BY VALUE WS-ZERO BY REFERENCE RL-PROJ(1) BY VALUE WS-L64 RETURNING WS-CRC
         COMPUTE WS-DIGEST = FUNCTION MOD(WS-DIGEST + WS-CRC * WS-WEIGHT, 9223372036854775783)
         CALL STATIC "crc32" USING BY VALUE WS-ZERO BY REFERENCE RL-VIEW(1) BY VALUE WS-L64 RETURNING WS-CRC
         COMPUTE WS-DIGEST = FUNCTION MOD(WS-DIGEST + WS-CRC * WS-WEIGHT, 9223372036854775783)
         CALL STATIC "crc32" USING BY VALUE WS-ZERO BY REFERENCE RL-FOG(1) BY VALUE WS-L52 RETURNING WS-CRC
         COMPUTE WS-DIGEST = FUNCTION MOD(WS-DIGEST + WS-CRC * WS-WEIGHT, 9223372036854775783)
     END-PERFORM
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "RLD_REPEAT"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-REPEAT = FUNCTION NUMVAL(WS-ENV)
     END-IF
     PERFORM VARYING WS-REP FROM 2 BY 1 UNTIL WS-REP > WS-REPEAT
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-FRAMES
             COMPUTE PL-X = 3.5 + FUNCTION MOD(WS-F * 5, 16) + 0.25 * WS-F
             COMPUTE PL-Z = -2.5 + FUNCTION MOD(WS-F * 11, 16) - 0.125 * WS-F
             COMPUTE PL-YAW = FUNCTION MOD(WS-F * 37, 360) + 0.5
             COMPUTE PL-PITCH = FUNCTION MOD(WS-F * 13, 120) - 60
             CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
         END-PERFORM
     END-PERFORM
     MOVE WS-US TO WS-D19
     MOVE WS-FRAMES TO WS-D9
     DISPLAY "PERF render-list us for " WS-D9 " frames: " WS-D19
     MOVE WS-DRAWS TO WS-D19
     DISPLAY "draw records " WS-D19
     MOVE WS-DIGEST TO WS-D19
     DISPLAY "DIGEST render list " WS-D19
     MOVE WS-UPLOADS TO WS-D19
     DISPLAY "DIGEST uploads " WS-D19
     MOVE "T" TO TL-MODE
     MOVE "test render list digest: the draw records of 60 views of a 625-chunk replica have the digest taken before the optimisations" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "6945433695109576613" TO TL-EXPECTED
     MOVE WS-DIGEST TO WS-D19
     MOVE FUNCTION TRIM(WS-D19) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test render list digest: the upload slots and counts have the digest taken before the optimisations" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "95926626320" TO TL-EXPECTED
     MOVE WS-UPLOADS TO WS-D19
     MOVE FUNCTION TRIM(WS-D19) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test render list digest: 60 frames of 625 chunk rows take less than 250 ms of CPU time (6.6 ms a frame before the optimisations)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-US < 250000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test render list digest: the views draw sections (the digest is not of an empty list)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAX-DRAWS > 200 AND WS-DRAWS > 5000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-RENDER-LIST-DIGEST.
 COPY CLTEST.
