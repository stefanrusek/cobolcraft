*> The coral features (docs/protocol/35-worldgen-features-5-water-and-surface.md section 14; registry ids 8 coral_tree and 7 coral_claw): FD-CORAL-NODE reads the config member feature (a placed
*> feature, inline or by name) into FT-A (0 with FD-BAD when it is missing); the coral block itself and its decoration are data (overlay, simple_block, weighted selectors, wall fans).
*> FR-CORAL-TREE (14.1): a stem of nextInt(3) + 1 blocks (the first failing placement ends the feature, as success), then nextInt(3) + 2 branches in the order of the shuffled horizontal
*> directions (Util.shuffle: nextInt(4), nextInt(3), nextInt(2)), each of nextInt(5) + 2 steps that rise, and bend after the first block or, from the second placed block on, when nextFloat() < 0.25
*> (the 24 bit draw below 2^22). FR-CORAL-CLAW (14.2): false when the first placement fails; else d0 = HORIZONTAL[nextInt(4)], nextInt(2) + 2 claws taken from the shuffled [d0, clockwise,
*> counter-clockwise] (nextInt(3), nextInt(2)), each with its own lengths and draws as in the document. place(c) is the placed feature with its modifiers (FR-PLACE-PF).
*>
*> Entry points: FD-CORAL-NODE USING doc, node, placed feature out; FR-CORAL-TREE and FR-CORAL-CLAW USING state, feature, x, y, z, result out (1 for the tree always).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-CORAL-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-E                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-PF                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-PF.
     MOVE 0 TO L-PF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FEATURE WS-E
     CALL "FD-PFREF-NODE" USING JSON-DOC WS-E L-PF
     GOBACK.
 END PROGRAM FD-CORAL-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-CORAL-TREE.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-B4                  BINARY-LONG VALUE 4.
 01 WS-B2                  BINARY-LONG VALUE 2.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-BITS24              BINARY-LONG VALUE 24.
 01 WS-DRAW                BINARY-LONG.
 01 WS-KW                  BINARY-DOUBLE.
 01 WS-PF                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-STEM                BINARY-LONG.
 01 WS-BRANCHES            BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SWAP                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-DIRS.
    05 WS-DIR              BINARY-LONG OCCURS 4 TIMES.
*> horizontal directions N, E, S, W: dx, dz
 01 WS-STEPS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-STEP-TABLE REDEFINES WS-STEPS.
    05 WS-STEP OCCURS 4 TIMES.
       10 WS-SDX           BINARY-LONG.
       10 WS-SDZ           BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-PF
     MOVE L-X TO WS-CX
     MOVE L-Y TO WS-CY
     MOVE L-Z TO WS-CZ
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B3 WS-STEM
     ADD 1 TO WS-STEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-STEM
         CALL "FR-PLACE-PF" USING L-STATE WS-PF WS-ZERO WS-CX WS-CY WS-CZ WS-R
         IF WS-R = 0
             GOBACK
         END-IF
         ADD 1 TO WS-CY
     END-PERFORM
     MOVE WS-CX TO WS-TX
     MOVE WS-CY TO WS-TY
     MOVE WS-CZ TO WS-TZ
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B3 WS-BRANCHES
     ADD 2 TO WS-BRANCHES
*>   Util.shuffle of [N, E, S, W]: for i = 4 down to 2, j = nextInt(i), swap(i - 1, j)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-I TO WS-DIR(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 4 BY -1 UNTIL WS-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-I WS-J
         COMPUTE WS-K = WS-I - 1
         ADD 1 TO WS-J
         MOVE WS-DIR(WS-K + 1) TO WS-SWAP
         MOVE WS-DIR(WS-J) TO WS-DIR(WS-K + 1)
         MOVE WS-SWAP TO WS-DIR(WS-J)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-BRANCHES
         MOVE WS-DIR(WS-I) TO WS-K
         COMPUTE WS-CX = WS-TX + WS-SDX(WS-K)
         MOVE WS-TY TO WS-CY
         COMPUTE WS-CZ = WS-TZ + WS-SDZ(WS-K)
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-LEN
         ADD 2 TO WS-LEN
         MOVE 0 TO WS-PLACED WS-STOP
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-LEN OR WS-STOP = 1
             CALL "FR-PLACE-PF" USING L-STATE WS-PF WS-ZERO WS-CX WS-CY WS-CZ WS-R
             IF WS-R = 0
                 MOVE 1 TO WS-STOP
             ELSE
                 ADD 1 TO WS-PLACED
                 ADD 1 TO WS-CY
                 MOVE 0 TO WS-R
                 IF WS-J = 0
                     MOVE 1 TO WS-R
                 ELSE
                     IF WS-PLACED >= 2
                         CALL "WGR-NEXT" USING L-STATE WS-BITS24 WS-KW
                         IF WS-KW < 4194304
                             MOVE 1 TO WS-R
                         END-IF
                     END-IF
                 END-IF
                 IF WS-R = 1
                     ADD WS-SDX(WS-K) TO WS-CX
                     ADD WS-SDZ(WS-K) TO WS-CZ
                     MOVE 0 TO WS-PLACED
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-CORAL-TREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-CORAL-CLAW.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-B2                  BINARY-LONG VALUE 2.
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-B4                  BINARY-LONG VALUE 4.
 01 WS-BITS24              BINARY-LONG VALUE 24.
 01 WS-KW                  BINARY-DOUBLE.
 01 WS-PF                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-D0                  BINARY-LONG.
 01 WS-CLAWS               BINARY-LONG.
 01 WS-LEN1                BINARY-LONG.
 01 WS-LEN2                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SWAP                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 3 TIMES.
*> directions 1 to 4 are N, E, S, W, 5 is up: dx, dy, dz
 01 WS-STEPS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-STEP-TABLE REDEFINES WS-STEPS.
    05 WS-STEP OCCURS 5 TIMES.
       10 WS-SDX           BINARY-LONG.
       10 WS-SDY           BINARY-LONG.
       10 WS-SDZ           BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-PF
     CALL "FR-PLACE-PF" USING L-STATE WS-PF WS-ZERO L-X L-Y L-Z WS-R
     IF WS-R = 0
         GOBACK
     END-IF
     MOVE 1 TO L-RESULT
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B4 WS-DRAW
     COMPUTE WS-D0 = WS-DRAW + 1
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B2 WS-CLAWS
     ADD 2 TO WS-CLAWS
*>   [d0, clockwise, counter-clockwise] (N E S W are 1 to 4: clockwise is the next, counter-clockwise the previous)
     MOVE WS-D0 TO WS-L(1)
     COMPUTE WS-L(2) = FUNCTION MOD(WS-D0, 4) + 1
     COMPUTE WS-L(3) = FUNCTION MOD(WS-D0 + 2, 4) + 1
*>   Util.shuffle of the list: for i = 3 down to 2, j = nextInt(i), swap(i - 1, j)
     PERFORM VARYING WS-I FROM 3 BY -1 UNTIL WS-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-I WS-J
         COMPUTE WS-K = WS-I - 1
         ADD 1 TO WS-J
         MOVE WS-L(WS-K + 1) TO WS-SWAP
         MOVE WS-L(WS-J) TO WS-L(WS-K + 1)
         MOVE WS-SWAP TO WS-L(WS-J)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CLAWS
         MOVE WS-L(WS-I) TO WS-D
         MOVE L-X TO WS-CX
         MOVE L-Y TO WS-CY
         MOVE L-Z TO WS-CZ
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B2 WS-LEN1
         ADD 1 TO WS-LEN1
         ADD WS-SDX(WS-D) TO WS-CX
         ADD WS-SDZ(WS-D) TO WS-CZ
         IF WS-D = WS-D0
             MOVE WS-D0 TO WS-D2
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B3 WS-LEN2
             ADD 2 TO WS-LEN2
         ELSE
             ADD 1 TO WS-CY
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B2 WS-DRAW
             IF WS-DRAW = 0
                 MOVE WS-D TO WS-D2
             ELSE
                 MOVE 5 TO WS-D2
             END-IF
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B3 WS-LEN2
             ADD 3 TO WS-LEN2
         END-IF
         MOVE 0 TO WS-STOP
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-LEN1 OR WS-STOP = 1
             CALL "FR-PLACE-PF" USING L-STATE WS-PF WS-ZERO WS-CX WS-CY WS-CZ WS-R
             IF WS-R = 0
                 MOVE 1 TO WS-STOP
             ELSE
                 ADD WS-SDX(WS-D2) TO WS-CX
                 ADD WS-SDY(WS-D2) TO WS-CY
                 ADD WS-SDZ(WS-D2) TO WS-CZ
             END-IF
         END-PERFORM
*>       one step in the opposite of dir2 and one up
         SUBTRACT WS-SDX(WS-D2) FROM WS-CX
         SUBTRACT WS-SDY(WS-D2) FROM WS-CY
         SUBTRACT WS-SDZ(WS-D2) FROM WS-CZ
         ADD 1 TO WS-CY
         MOVE 0 TO WS-STOP
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-LEN2 OR WS-STOP = 1
             ADD WS-SDX(WS-D0) TO WS-CX
             ADD WS-SDZ(WS-D0) TO WS-CZ
             CALL "FR-PLACE-PF" USING L-STATE WS-PF WS-ZERO WS-CX WS-CY WS-CZ WS-R
             IF WS-R = 0
                 MOVE 1 TO WS-STOP
             ELSE
                 CALL "WGR-NEXT" USING L-STATE WS-BITS24 WS-KW
                 IF WS-KW < 4194304
                     ADD 1 TO WS-CY
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-CORAL-CLAW.
