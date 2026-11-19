 *> Blocks whose sides connect to their neighbours: walls, fences, glass panes and bars (lane bugfluidwalls, operator report try19 "walls don't connect"; docs/protocol/24-block-registry-7
*> section 8 (walls: 8.3 the connection rule, 8.4 the sides none, low and tall and the post), 24-block-registry-3 section 9.1 (fences), 24-block-registry-4 section 5.2 and 24-block-registry-5
*> section 7.14 (panes and bars)). The core computed none of it: a placed wall, fence or pane kept the default state (a post, no arms) and never changed when a neighbour did.
*> The cell is read from the level (WORLD-GET-BLOCK); the face of a neighbour is sturdy when its collision shape (BSH-COLL, 51-block-shapes) covers the whole face, and the arms of a wall are tall
*> when the down face of the collision shape of the block above covers the test shape of the side (WallBlock.updateShape).
*>
*> Entry points:
*>   CONN-KIND USING name (PIC X(48), bare), kind out (0 none, 1 wall, 2 fence, 3 bars and panes, 4 fence gate), wooden out (1 for a fence that is not the nether brick one)
*>   CONN-EXCEPTION USING name, flag out: Block.isExceptionForConnection (leaves, barrier, carved pumpkin, jack o'lantern, melon, pumpkin, shulker boxes)
*>   CONN-FACE-GRID USING state, face (0 down, 1 up, 2 north, 3 south, 4 west, 5 east), grid out (PIC X(256), "1" for each sixteenth of the face the collision shape covers)
*>   CONN-GRID-COVERS USING grid, first a, last a, first b, last b, flag out: every sixteenth of the rectangle is covered
*>   CONN-CONNECTS USING dimension row, x, y, z of the neighbour, side (direction from the block to the neighbour, 2 to 5), kind, wooden, connects out
*>   CONN-COMPUTE USING dimension row, x, y, z, kind, connections north, east, south, west (0 or 1), state in and out: the sides and, for a wall, the post
*>   CONN-PLACE USING dimension row, x, y, z, state in and out: getStateForPlacement of the four kinds; any other state is left as it is
*>   CONN-SHAPE USING dimension row, x, y, z, state, direction towards the changed neighbour, state out: updateShape (BU-HOOK kind 4)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONN-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GATE                PIC X(24) VALUE "_fence_gate".
 01 WS-FENCE               PIC X(24) VALUE "_fence".
 01 WS-WALL                PIC X(24) VALUE "_wall".
 01 WS-BARS                PIC X(24) VALUE "_bars".
 01 WS-PANE                PIC X(24) VALUE "_pane".
 01 WS-NETHER              PIC X(24) VALUE "nether_brick_fence".
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-KIND                 BINARY-LONG.
 01 L-WOODEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-KIND L-WOODEN.
     MOVE 0 TO L-KIND L-WOODEN
     CALL "PS-ENDS" USING L-NAME WS-GATE WS-FLAG
     IF WS-FLAG = 1
         MOVE 4 TO L-KIND
         GOBACK
     END-IF
     CALL "PS-ENDS" USING L-NAME WS-FENCE WS-FLAG
     IF WS-FLAG = 1
         MOVE 2 TO L-KIND
         MOVE 1 TO L-WOODEN
         IF L-NAME = WS-NETHER
             MOVE 0 TO L-WOODEN
         END-IF
         GOBACK
     END-IF
     CALL "PS-ENDS" USING L-NAME WS-WALL WS-FLAG
     IF WS-FLAG = 1
         MOVE 1 TO L-KIND
     END-IF
     CALL "PS-ENDS" USING L-NAME WS-BARS WS-FLAG
     IF WS-FLAG = 1
         MOVE 3 TO L-KIND
     END-IF
     CALL "PS-ENDS" USING L-NAME WS-PANE WS-FLAG
     IF WS-FLAG = 1
         MOVE 3 TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM CONN-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONN-EXCEPTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEAVES              PIC X(24) VALUE "_leaves".
 01 WS-SHULKER             PIC X(24) VALUE "shulker_box".
 01 WS-NAMES.
    05 FILLER PIC X(48) VALUE "barrier".
    05 FILLER PIC X(48) VALUE "carved_pumpkin".
    05 FILLER PIC X(48) VALUE "jack_o_lantern".
    05 FILLER PIC X(48) VALUE "melon".
    05 FILLER PIC X(48) VALUE "pumpkin".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-LISTED           PIC X(48) OCCURS 5 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-FLAG.
     MOVE 0 TO L-FLAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         IF L-NAME = WS-LISTED(WS-I)
             MOVE 1 TO L-FLAG
         END-IF
     END-PERFORM
     CALL "PS-ENDS" USING L-NAME WS-LEAVES WS-FLAG
     IF WS-FLAG = 1
         MOVE 1 TO L-FLAG
     END-IF
     CALL "PS-ENDS" USING L-NAME WS-SHULKER WS-FLAG
     IF WS-FLAG = 1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM CONN-EXCEPTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONN-FACE-GRID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 01 WS-BOX.
    05 WS-V                BINARY-LONG OCCURS 6 TIMES.
 01 WS-PLANE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-A-LO                BINARY-LONG.
 01 WS-A-HI                BINARY-LONG.
 01 WS-B-LO                BINARY-LONG.
 01 WS-B-HI                BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
*> per face: the box value that must lie on the plane of the face (1 x1, 2 y1, 3 z1, 4 x2, 5 y2, 6 z2), the plane (0 or 16000), the box values of the first axis (low, high) and of the second axis
 01 WS-FACES.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 6.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 16000.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 6.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 6.
    05 FILLER BINARY-LONG VALUE 16000.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 6.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 16000.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 6.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 5.
 01 WS-FACE-TABLE REDEFINES WS-FACES.
    05 WS-F OCCURS 6 TIMES.
       10 WS-F-VALUE       BINARY-LONG.
       10 WS-F-PLANE       BINARY-LONG.
       10 WS-F-A-LO        BINARY-LONG.
       10 WS-F-A-HI        BINARY-LONG.
       10 WS-F-B-LO        BINARY-LONG.
       10 WS-F-B-HI        BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-GRID                 PIC X(256).
 PROCEDURE DIVISION USING L-STATE L-FACE L-GRID.
     MOVE ALL "0" TO L-GRID
     CALL "BSH-COLL-ID" USING L-STATE WS-SHAPE
     IF WS-SHAPE = 0
         GOBACK
     END-IF
     COMPUTE WS-AT = L-FACE + 1
     MOVE WS-F-VALUE(WS-AT) TO WS-WANT
     MOVE WS-F-PLANE(WS-AT) TO WS-PLANE
     MOVE WS-F-A-LO(WS-AT) TO WS-A-LO
     MOVE WS-F-A-HI(WS-AT) TO WS-A-HI
     MOVE WS-F-B-LO(WS-AT) TO WS-B-LO
     MOVE WS-F-B-HI(WS-AT) TO WS-B-HI
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > BSH-N(WS-SHAPE + 1)
         MOVE BSH-BOX(WS-SHAPE + 1, WS-K) TO WS-BOX
         IF WS-V(WS-WANT) = WS-PLANE
             PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > 15
                 PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > 15
                     MOVE 0 TO WS-ON
                     IF WS-V(WS-A-LO) <= WS-A * 1000 AND WS-V(WS-A-HI) >= WS-A * 1000 + 1000
                             AND WS-V(WS-B-LO) <= WS-B * 1000 AND WS-V(WS-B-HI) >= WS-B * 1000 + 1000
                         MOVE 1 TO WS-ON
                     END-IF
                     IF WS-ON = 1
                         COMPUTE WS-AT = WS-A * 16 + WS-B + 1
                         MOVE "1" TO L-GRID(WS-AT:1)
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CONN-FACE-GRID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONN-GRID-COVERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-GRID                 PIC X(256).
 01 L-A-LO                 BINARY-LONG.
 01 L-A-HI                 BINARY-LONG.
 01 L-B-LO                 BINARY-LONG.
 01 L-B-HI                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-GRID L-A-LO L-A-HI L-B-LO L-B-HI L-FLAG.
     MOVE 1 TO L-FLAG
     PERFORM VARYING WS-A FROM L-A-LO BY 1 UNTIL WS-A > L-A-HI
         PERFORM VARYING WS-B FROM L-B-LO BY 1 UNTIL WS-B > L-B-HI
             COMPUTE WS-AT = WS-A * 16 + WS-B + 1
             IF L-GRID(WS-AT:1) NOT = "1"
                 MOVE 0 TO L-FLAG
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CONN-GRID-COVERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONN-CONNECTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-KIND                BINARY-LONG.
 01 WS-WOODEN              BINARY-LONG.
 01 WS-EXCEPTION           BINARY-LONG.
 01 WS-STURDY              BINARY-LONG.
 01 WS-GATE                BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-GRID                PIC X(256).
 01 WS-FIRST-A             BINARY-LONG VALUE 0.
 01 WS-LAST-A              BINARY-LONG VALUE 15.
 01 WS-FIRST-B             BINARY-LONG VALUE 0.
 01 WS-LAST-B              BINARY-LONG VALUE 15.
 01 WS-FACING-NAME         PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-TURNED              BINARY-LONG.
 01 WS-AXIS-A              BINARY-LONG.
 01 WS-AXIS-B              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-WOODEN               BINARY-LONG.
 01 L-CONNECTS             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SIDE L-KIND L-WOODEN L-CONNECTS.
     MOVE 0 TO L-CONNECTS
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "PS-NAME-OF" USING WS-STATE WS-NAME
     CALL "CONN-KIND" USING WS-NAME WS-KIND WS-WOODEN
     CALL "CONN-EXCEPTION" USING WS-NAME WS-EXCEPTION
*>   The face of the neighbour towards the block is sturdy when its collision shape covers all of it.
     CALL "PS-OPP" USING L-SIDE WS-OPP
     CALL "CONN-FACE-GRID" USING WS-STATE WS-OPP WS-GRID
     CALL "CONN-GRID-COVERS" USING WS-GRID WS-FIRST-A WS-LAST-A WS-FIRST-B WS-LAST-B WS-STURDY
*>   A fence gate connects when its facing turned a quarter lies on the axis of the side (FenceGateBlock.connectsToDirection).
     MOVE 0 TO WS-GATE
     IF WS-KIND = 4
         CALL "PS-GET" USING WS-STATE WS-FACING-NAME WS-TEXT WS-FOUND
         CALL "PS-DIR-OF" USING WS-TEXT WS-FACING
         CALL "PS-CW" USING WS-FACING WS-TURNED
         COMPUTE WS-AXIS-A = (WS-TURNED - 2) / 2
         COMPUTE WS-AXIS-B = (L-SIDE - 2) / 2
         IF WS-AXIS-A = WS-AXIS-B
             MOVE 1 TO WS-GATE
         END-IF
     END-IF
     EVALUATE L-KIND
*>       A wall (8.3): a wall, a block with a sturdy face that is not an exception, bars or a pane, a gate across.
         WHEN 1
             IF WS-KIND = 1 OR WS-KIND = 3 OR WS-GATE = 1 OR (WS-EXCEPTION = 0 AND WS-STURDY = 1)
                 MOVE 1 TO L-CONNECTS
             END-IF
*>       A fence (24-3 9.1): a fence of the same wood class, a gate across, a block with a sturdy face that is not an exception.
         WHEN 2
             IF (WS-KIND = 2 AND WS-WOODEN = L-WOODEN) OR WS-GATE = 1 OR (WS-EXCEPTION = 0 AND WS-STURDY = 1)
                 MOVE 1 TO L-CONNECTS
             END-IF
*>       Bars and panes (24-4 5.2): a block with a sturdy face that is not an exception, bars or a pane, a wall.
         WHEN OTHER
             IF WS-KIND = 1 OR WS-KIND = 3 OR (WS-EXCEPTION = 0 AND WS-STURDY = 1)
                 MOVE 1 TO L-CONNECTS
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM CONN-CONNECTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONN-COMPUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-SIDE-NAMES.
    05 FILLER PIC X(24) VALUE "north".
    05 FILLER PIC X(24) VALUE "east".
    05 FILLER PIC X(24) VALUE "south".
    05 FILLER PIC X(24) VALUE "west".
 01 WS-SIDE-TABLE REDEFINES WS-SIDE-NAMES.
    05 WS-SIDE-NAME        PIC X(24) OCCURS 4 TIMES.
*> the rectangle of the test shape of a side on the down face of the block above (first and last sixteenth along x, along z): TEST_SHAPES_WALL north, east, south, west
 01 WS-TESTS.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 15.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 15.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 8.
 01 WS-TEST-TABLE REDEFINES WS-TESTS.
    05 WS-T OCCURS 4 TIMES.
       10 WS-T-X-LO        BINARY-LONG.
       10 WS-T-X-HI        BINARY-LONG.
       10 WS-T-Z-LO        BINARY-LONG.
       10 WS-T-Z-HI        BINARY-LONG.
 01 WS-CONNECTED.
    05 WS-C                BINARY-LONG OCCURS 4 TIMES.
 01 WS-SIDES.
    05 WS-V                BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-ABOVE-Y             BINARY-LONG.
 01 WS-ABOVE-NAME          PIC X(48).
 01 WS-ABOVE-KIND          BINARY-LONG.
 01 WS-ABOVE-WOODEN        BINARY-LONG.
 01 WS-GRID                PIC X(256).
 01 WS-DOWN                BINARY-LONG VALUE 0.
 01 WS-COVERS              BINARY-LONG.
 01 WS-POST                BINARY-LONG.
 01 WS-POST-COVERED        BINARY-LONG.
 01 WS-POST-X-LO          BINARY-LONG VALUE 7.
 01 WS-POST-X-HI          BINARY-LONG VALUE 8.
 01 WS-POST-Z-LO          BINARY-LONG VALUE 7.
 01 WS-POST-Z-HI          BINARY-LONG VALUE 8.
 01 WS-N-NONE              BINARY-LONG.
 01 WS-E-NONE              BINARY-LONG.
 01 WS-S-NONE              BINARY-LONG.
 01 WS-W-NONE              BINARY-LONG.
 01 WS-UP-NAME             PIC X(24) VALUE "up".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:wall_post_override".
 01 WS-NONE                BINARY-LONG.
 01 WS-LOW-TEXT            PIC X(32) VALUE "low".
 01 WS-TALL-TEXT           PIC X(32) VALUE "tall".
 01 WS-NONE-TEXT           PIC X(32) VALUE "none".
 01 WS-TRUE-TEXT           PIC X(32) VALUE "true".
 01 WS-FALSE-TEXT          PIC X(32) VALUE "false".
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-N L-E L-S L-W L-STATE.
     MOVE L-N TO WS-C(1)
     MOVE L-E TO WS-C(2)
     MOVE L-S TO WS-C(3)
     MOVE L-W TO WS-C(4)
*>   A fence, a pane or bars: each side is true when it connects.
     IF L-KIND NOT = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE WS-FALSE-TEXT TO WS-TEXT
             IF WS-C(WS-I) = 1
                 MOVE WS-TRUE-TEXT TO WS-TEXT
             END-IF
             CALL "PS-PUT" USING L-STATE WS-SIDE-NAME(WS-I) WS-TEXT
         END-PERFORM
         GOBACK
     END-IF
*>   A wall (8.4): the shape of the block above decides low or tall and the post.
     COMPUTE WS-ABOVE-Y = L-Y + 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-ABOVE-Y L-Z WS-ABOVE
     CALL "CONN-FACE-GRID" USING WS-ABOVE WS-DOWN WS-GRID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-NONE-TEXT TO WS-TEXT
         MOVE 0 TO WS-V(WS-I)
         IF WS-C(WS-I) = 1
             CALL "CONN-GRID-COVERS" USING WS-GRID WS-T-X-LO(WS-I) WS-T-X-HI(WS-I) WS-T-Z-LO(WS-I) WS-T-Z-HI(WS-I) WS-COVERS
             MOVE WS-LOW-TEXT TO WS-TEXT
             MOVE 1 TO WS-V(WS-I)
             IF WS-COVERS = 1
                 MOVE WS-TALL-TEXT TO WS-TEXT
                 MOVE 2 TO WS-V(WS-I)
             END-IF
         END-IF
         CALL "PS-PUT" USING L-STATE WS-SIDE-NAME(WS-I) WS-TEXT
     END-PERFORM
*>   shouldRaisePost: a wall above with a post; a corner, an end or a junction; two tall arms in a line; else the shape above (or its tag) holds a post up.
     CALL "PS-NAME-OF" USING WS-ABOVE WS-ABOVE-NAME
     CALL "CONN-KIND" USING WS-ABOVE-NAME WS-ABOVE-KIND WS-ABOVE-WOODEN
     MOVE 0 TO WS-POST
     MOVE 0 TO WS-OVERRIDE
     IF WS-ABOVE > 0
         MOVE CB-S-BLOCK(WS-ABOVE + 1) TO WS-BLOCK
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-OVERRIDE
     END-IF
     CALL "CONN-GRID-COVERS" USING WS-GRID WS-POST-X-LO WS-POST-X-HI WS-POST-Z-LO WS-POST-Z-HI WS-POST-COVERED
     MOVE 0 TO WS-N-NONE WS-E-NONE WS-S-NONE WS-W-NONE
     IF WS-V(1) = 0
         MOVE 1 TO WS-N-NONE
     END-IF
     IF WS-V(2) = 0
         MOVE 1 TO WS-E-NONE
     END-IF
     IF WS-V(3) = 0
         MOVE 1 TO WS-S-NONE
     END-IF
     IF WS-V(4) = 0
         MOVE 1 TO WS-W-NONE
     END-IF
     MOVE 0 TO WS-NONE
     IF WS-N-NONE = 1 AND WS-E-NONE = 1 AND WS-S-NONE = 1 AND WS-W-NONE = 1
         MOVE 1 TO WS-NONE
     END-IF
     MOVE SPACES TO WS-TEXT
     IF WS-ABOVE-KIND = 1
         CALL "PS-GET" USING WS-ABOVE WS-UP-NAME WS-TEXT WS-FOUND
     END-IF
     EVALUATE TRUE
         WHEN WS-ABOVE-KIND = 1 AND WS-TEXT = WS-TRUE-TEXT
             MOVE 1 TO WS-POST
         WHEN WS-NONE = 1
             MOVE 1 TO WS-POST
         WHEN WS-N-NONE NOT = WS-S-NONE
             MOVE 1 TO WS-POST
         WHEN WS-W-NONE NOT = WS-E-NONE
             MOVE 1 TO WS-POST
         WHEN (WS-V(1) = 2 AND WS-V(3) = 2) OR (WS-V(2) = 2 AND WS-V(4) = 2)
             MOVE 0 TO WS-POST
         WHEN OTHER
             IF WS-OVERRIDE = 1 OR WS-POST-COVERED = 1
                 MOVE 1 TO WS-POST
             END-IF
     END-EVALUATE
     MOVE WS-FALSE-TEXT TO WS-TEXT
     IF WS-POST = 1
         MOVE WS-TRUE-TEXT TO WS-TEXT
     END-IF
     CALL "PS-PUT" USING L-STATE WS-UP-NAME WS-TEXT
     GOBACK.
 END PROGRAM CONN-COMPUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONN-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(48).
 01 WS-KIND                BINARY-LONG.
 01 WS-WOODEN              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIRS                PIC X(4) VALUE "2534".
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR              PIC 9 OCCURS 4 TIMES.
 01 WS-SIDE                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-CONNECTED.
    05 WS-C                BINARY-LONG OCCURS 4 TIMES.
 01 WS-CN                 BINARY-LONG.
 01 WS-CE                 BINARY-LONG.
 01 WS-CS                 BINARY-LONG.
 01 WS-CW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "PS-NAME-OF" USING L-STATE WS-NAME
     CALL "CONN-KIND" USING WS-NAME WS-KIND WS-WOODEN
     IF WS-KIND = 0 OR WS-KIND = 4
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-DIR(WS-I) TO WS-SIDE
         CALL "PS-DIR-STEP" USING WS-SIDE WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NY = L-Y + WS-DY
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "CONN-CONNECTS" USING L-DIM WS-NX WS-NY WS-NZ WS-SIDE WS-KIND WS-WOODEN WS-C(WS-I)
     END-PERFORM
     MOVE WS-C(1) TO WS-CN
     MOVE WS-C(2) TO WS-CE
     MOVE WS-C(3) TO WS-CS
     MOVE WS-C(4) TO WS-CW
     CALL "CONN-COMPUTE" USING L-DIM L-X L-Y L-Z WS-KIND WS-CN WS-CE WS-CS WS-CW L-STATE
     GOBACK.
 END PROGRAM CONN-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONN-SHAPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(48).
 01 WS-KIND                BINARY-LONG.
 01 WS-WOODEN              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SIDE-NAMES.
    05 FILLER PIC X(24) VALUE "north".
    05 FILLER PIC X(24) VALUE "east".
    05 FILLER PIC X(24) VALUE "south".
    05 FILLER PIC X(24) VALUE "west".
 01 WS-SIDE-TABLE REDEFINES WS-SIDE-NAMES.
    05 WS-SIDE-NAME        PIC X(24) OCCURS 4 TIMES.
 01 WS-SIDE-OF             PIC X(4) VALUE "1342".
 01 WS-SIDE-MAP REDEFINES WS-SIDE-OF.
    05 WS-SIDE-AT          PIC 9 OCCURS 4 TIMES.
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-CONNECTED.
    05 WS-C                BINARY-LONG OCCURS 4 TIMES.
 01 WS-CN                 BINARY-LONG.
 01 WS-CE                 BINARY-LONG.
 01 WS-CS                 BINARY-LONG.
 01 WS-CW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-DIR L-OUT.
     MOVE L-STATE TO L-OUT
     CALL "PS-NAME-OF" USING L-STATE WS-NAME
     CALL "CONN-KIND" USING WS-NAME WS-KIND WS-WOODEN
     IF WS-KIND = 0 OR WS-KIND = 4
         GOBACK
     END-IF
*>   Below, nothing changes; above, only a wall looks at it (topUpdate).
     IF L-DIR = 0 OR (L-DIR = 1 AND WS-KIND NOT = 1)
         GOBACK
     END-IF
*>   The sides now: a side that is not none (wall) or not false (fence, pane, bars) is connected.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "PS-GET" USING L-STATE WS-SIDE-NAME(WS-I) WS-TEXT WS-FOUND
         MOVE 1 TO WS-C(WS-I)
         IF WS-TEXT = "none" OR WS-TEXT = "false"
             MOVE 0 TO WS-C(WS-I)
         END-IF
     END-PERFORM
*>   A horizontal change recomputes the side of that direction from the neighbour that changed.
     IF L-DIR > 1
         MOVE WS-SIDE-AT(L-DIR - 1) TO WS-AT
         CALL "PS-DIR-STEP" USING L-DIR WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NY = L-Y + WS-DY
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "CONN-CONNECTS" USING L-DIM WS-NX WS-NY WS-NZ L-DIR WS-KIND WS-WOODEN WS-C(WS-AT)
     END-IF
     MOVE WS-C(1) TO WS-CN
     MOVE WS-C(2) TO WS-CE
     MOVE WS-C(3) TO WS-CS
     MOVE WS-C(4) TO WS-CW
     CALL "CONN-COMPUTE" USING L-DIM L-X L-Y L-Z WS-KIND WS-CN WS-CE WS-CS WS-CW L-OUT
     GOBACK.
 END PROGRAM CONN-SHAPE.
