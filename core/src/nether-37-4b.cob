*> The Nether cave carver (docs/protocol/37-nether-4 sections 6 to 8; T1683 to T1688): minecraft:nether_cave is the cave carver of 11 section 5.3 with the
*> Nether's numbers (probability 0.2, y 0 to 126, count very_biased_to_bottom 0 to 9, floor -0.7, radius multipliers 1.0, room vertical radius 0.5,
*> start vertical radius multiplier 5.0, thickness trapezoid 0 to 6 plateau 2, no weird thickness bias), the ellipsoid of 11 section 5.5 over the mask
*> y 1 to 120, and a mask application that skips only bedrock and puts what the disabled aquifer says: lava below y 32, air from y 32 (7.2). Every
*> source chunk within 8 chunks is seeded with setLargeFeatureSeed(seed + 0, x, z) (the one-entry carver list: the biome does not matter, 6.1).
*> The float32 steps are those of carvers.cob (CV-FADD, CV-FMUL ...), the Java LCG that of rng-java.cob.
*>
*> Entry points (state in NETHERCV.cpy, NETHER.cpy):
*>   NETHER-CV-SETUP: the constants.
*>   NETHER-CV-HEAD USING random state (u64), source chunk x, z: one cave's draws (6.3 items 2 and 3) into NC-CAVE-*.
*>   NETHER-CV-TUNNEL USING random state: one tunnel's draws (6.3 item 4) into NC-TUN-*.
*>   NETHER-CV-ELLIPSOID USING centre x, y, z, horizontal radius, vertical radius (FLOAT-LONG): carveEllipsoid into the mask of the target chunk.
*>   NETHER-CV-SOURCE USING source chunk x, z: the caves of one source chunk (isStartChunk, count, caves, rooms, tunnels).
*>   NETHER-CARVE USING chunk memory, chunk x, chunk z: the 17 x 17 source chunks, then the mask applied to the chunk.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CV-SETUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERCV.
 COPY CARVER.
 01 WS-TEXT                PIC X(16).
 01 WS-ZERO-SEED           BINARY-DOUBLE UNSIGNED VALUE 0.
 PROCEDURE DIVISION.
*>   the float helpers of carvers.cob (CV-TRAPEZOID) read the constants of the classic carvers
     IF CV-READY = 0
         CALL "CARVER-SETUP" USING WS-ZERO-SEED
     END-IF
     MOVE Z"3.1415927" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-PI
     MOVE Z"6.2831855" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-TWO-PI
     MOVE Z"1.5707964" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-HALF-PI
     MOVE Z"0.92" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-K092
     MOVE Z"0.7" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-K07
     MOVE Z"0.1" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-K01
     MOVE Z"0.9" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-K09
     MOVE Z"0.75" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-K075
     MOVE Z"-0.7" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-FLOOR
     MOVE Z"0.2" TO WS-TEXT
     CALL "CV-CONST" USING WS-TEXT NC-PROB
     MOVE 0.5 TO NC-ROOMV
     MOVE 0.5 TO NC-HALF
     MOVE 1 TO NC-ONE
     MOVE 2 TO NC-TWO
     MOVE 3 TO NC-THREE
     MOVE 4 TO NC-FOUR
     MOVE 5 TO NC-FIVE
     MOVE 6 TO NC-SIX
     MOVE 16 TO NC-SIXTEEN
     MOVE 1.5 TO NC-ONE-HALF
     MOVE 0 TO NC-ZERO
     MOVE 1 TO NC-READY
     GOBACK.
 END PROGRAM NETHER-CV-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CV-HEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERCV.
 01 WS-BOUND               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SX L-SZ.
     MOVE 16 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D
     COMPUTE NC-CAVE-X = L-SX * 16 + WS-D
     MOVE 127 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND NC-CAVE-Y
     MOVE 16 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D
     COMPUTE NC-CAVE-Z = L-SZ * 16 + WS-D
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D
     MOVE 1 TO NC-CAVE-TUNNELS
     MOVE 0 TO NC-CAVE-ROOM
     IF WS-D = 0
         MOVE 1 TO NC-CAVE-ROOM
         CALL "JRAND-NEXT-FLOAT" USING L-STATE WS-F
         CALL "CV-FMUL" USING WS-F NC-SIX WS-T
         CALL "CV-FADD" USING NC-ONE WS-T NC-CAVE-ROOMR
         CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D
         ADD WS-D TO NC-CAVE-TUNNELS
     END-IF
     GOBACK.
 END PROGRAM NETHER-CV-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CV-TUNNEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERCV.
 01 WS-BOUND               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-PLATEAU             FLOAT-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-STATE.
     CALL "JRAND-NEXT-FLOAT" USING L-STATE WS-F
     CALL "CV-FMUL" USING WS-F NC-TWO-PI NC-TUN-YAW
     CALL "JRAND-NEXT-FLOAT" USING L-STATE WS-F
     CALL "CV-FSUB" USING WS-F NC-HALF WS-T
     CALL "CV-FDIV" USING WS-T NC-FOUR NC-TUN-PITCH
     CALL "CV-TRAPEZOID" USING L-STATE NC-ZERO NC-SIX WS-PLATEAU NC-TUN-THICK
     MOVE 28 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D
     COMPUTE NC-TUN-STEPS = 112 - WS-D
     CALL "JRAND-NEXT-LONG" USING L-STATE NC-TUN-SEED
     GOBACK.
 END PROGRAM NETHER-CV-TUNNEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CV-ELLIPSOID.
*> carveEllipsoid (11 section 5.5) with the Nether's mask (y 1 to 120) and the cave skip test: a block is skipped when yd <= floor or
*> xd * xd + yd * yd + zd * zd >= 1, with the normalised offsets of the block's centre.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERCV.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-SIXTEEN             FLOAT-LONG VALUE 16.
 01 WS-MID                 FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-LIM                 FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-XHI                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-ZHI                 BINARY-LONG.
 01 WS-YLO                 BINARY-LONG.
 01 WS-YHI                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-XD                  FLOAT-LONG.
 01 WS-XD2                 FLOAT-LONG.
 01 WS-ZD2                 FLOAT-LONG.
 01 WS-YD                  FLOAT-LONG.
 01 WS-YD2                 FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-IDX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   FLOAT-LONG.
 01 L-CY                   FLOAT-LONG.
 01 L-CZ                   FLOAT-LONG.
 01 L-HR                   FLOAT-LONG.
 01 L-VR                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-CX L-CY L-CZ L-HR L-VR.
     COMPUTE WS-MINX = NC-CX * 16
     COMPUTE WS-MINZ = NC-CZ * 16
*>   too far from the chunk's middle: nothing of the chunk is reached
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-HR WS-TWO WS-T
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T WS-SIXTEEN WS-LIM
     COMPUTE WS-D = WS-MINX + 8
     MOVE WS-D TO WS-MID
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-CX WS-MID WS-T
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-T WS-D
     IF WS-D > WS-LIM
         GOBACK
     END-IF
     COMPUTE WS-D = WS-MINZ + 8
     MOVE WS-D TO WS-MID
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-CZ WS-MID WS-T
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-T WS-D
     IF WS-D > WS-LIM
         GOBACK
     END-IF
*>   the bounds
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-CX L-HR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-XLO = WS-A - WS-MINX - 1
     IF WS-XLO < 0
         MOVE 0 TO WS-XLO
     END-IF
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-CX L-HR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-XHI = WS-A - WS-MINX
     IF WS-XHI > 15
         MOVE 15 TO WS-XHI
     END-IF
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-CZ L-HR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-ZLO = WS-A - WS-MINZ - 1
     IF WS-ZLO < 0
         MOVE 0 TO WS-ZLO
     END-IF
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-CZ L-HR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-ZHI = WS-A - WS-MINZ
     IF WS-ZHI > 15
         MOVE 15 TO WS-ZHI
     END-IF
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-CY L-VR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-YLO = WS-A - 1
     IF WS-YLO < 1
         MOVE 1 TO WS-YLO
     END-IF
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-CY L-VR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-YHI = WS-A + 1
     IF WS-YHI > 120
         MOVE 120 TO WS-YHI
     END-IF
     PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
         COMPUTE WS-BX = WS-MINX + WS-X
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-BX WS-HALF WS-T
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T L-CX WS-A
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A L-HR WS-XD
         MOVE WS-XD TO WS-C
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-XD WS-C WS-XD2
         PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
             COMPUTE WS-BZ = WS-MINZ + WS-Z
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-BZ WS-HALF WS-T
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T L-CZ WS-A
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A L-HR WS-XD
             MOVE WS-XD TO WS-C
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-XD WS-C WS-ZD2
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-XD2 WS-ZD2 WS-S
             IF WS-S < 1
                 PERFORM VARYING WS-Y FROM WS-YHI BY -1 UNTIL WS-Y <= WS-YLO
                     MOVE WS-Y TO WS-BY
                     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-BY WS-HALF WS-T
                     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T L-CY WS-A
                     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A L-VR WS-YD
                     MOVE WS-YD TO WS-C
                     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-YD WS-C WS-YD2
                     IF WS-YD > NC-FLOOR
                         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-XD2 WS-YD2 WS-T
                         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T WS-ZD2 WS-A
                         IF WS-A < 1
                             COMPUTE WS-IDX = (WS-Y - 1) + (WS-Z + 16 * WS-X) * 120 + 1
                             MOVE "1" TO NC-MASK(WS-IDX:1)
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-CV-ELLIPSOID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CV-REACH.
*> USING x, z (FLOAT-LONG), step, max steps (BINARY-LONG), thickness (FLOAT-LONG), flag out: 11 section 5.3.1 canReach for the target chunk NC-CX, NC-CZ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERCV.
 01 WS-MID                 FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEFT                FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-THICK                FLOAT-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-STEP L-MAX L-THICK L-FLAG.
     COMPUTE WS-M = NC-CX * 16 + 8
     MOVE WS-M TO WS-MID
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-X WS-MID WS-DX
     COMPUTE WS-M = NC-CZ * 16 + 8
     MOVE WS-M TO WS-MID
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-Z WS-MID WS-DZ
     COMPUTE WS-M = L-MAX - L-STEP
     MOVE WS-M TO WS-LEFT
     CALL "CV-FADD" USING L-THICK NC-TWO WS-T
     CALL "CV-FADD" USING WS-T NC-SIXTEEN WS-REACH
     MOVE WS-DX TO WS-C
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DX WS-C WS-A
     MOVE WS-DZ TO WS-C
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DZ WS-C WS-B
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-A WS-B WS-T
     MOVE WS-LEFT TO WS-C
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-LEFT WS-C WS-U
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T WS-U WS-A
     MOVE WS-REACH TO WS-C
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-REACH WS-C WS-B
     MOVE 1 TO L-FLAG
     IF WS-A > WS-B
         MOVE 0 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM NETHER-CV-REACH.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CV-WALK RECURSIVE.
*> USING walker (CVWALK.cpy): the tunnel walker of 5.3.1 (a branch is the same walker called again).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERCV.
 LOCAL-STORAGE SECTION.
 01 LS-RND                 BINARY-DOUBLE UNSIGNED.
 01 LS-BOUND               BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-BRANCH              BINARY-LONG.
 01 LS-STEEP               BINARY-LONG.
 01 LS-STEP                BINARY-LONG.
 01 LS-LEAVE               BINARY-LONG.
 01 LS-FLAG                BINARY-LONG.
 01 LS-DPITCH              FLOAT-LONG.
 01 LS-DYAW                FLOAT-LONG.
 01 LS-X                   FLOAT-LONG.
 01 LS-Y                   FLOAT-LONG.
 01 LS-Z                   FLOAT-LONG.
 01 LS-YAW                 FLOAT-LONG.
 01 LS-PITCH               FLOAT-LONG.
 01 LS-F                   FLOAT-LONG.
 01 LS-G                   FLOAT-LONG.
 01 LS-H                   FLOAT-LONG.
 01 LS-T                   FLOAT-LONG.
 01 LS-A                   FLOAT-LONG.
 01 LS-S                   FLOAT-LONG.
 01 LS-R                   FLOAT-LONG.
 01 LS-RV                  FLOAT-LONG.
 01 LS-HR                  FLOAT-LONG.
 01 LS-VR                  FLOAT-LONG.
 01 LS-CP                  FLOAT-LONG.
 01 LS-CHILD.
    COPY CVWALK REPLACING LEADING ==CVK-== BY ==LC-==.
 LINKAGE SECTION.
 01 L-WALK.
    COPY CVWALK REPLACING LEADING ==CVK-== BY ==L-==.
 PROCEDURE DIVISION USING L-WALK.
     CALL "JRAND-SET-SEED" USING LS-RND L-SEED
     DIVIDE L-MAX BY 2 GIVING LS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING LS-RND LS-BOUND LS-BRANCH
     DIVIDE L-MAX BY 4 GIVING LS-D
     ADD LS-D TO LS-BRANCH
     MOVE 6 TO LS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING LS-RND LS-BOUND LS-D
     MOVE 0 TO LS-STEEP
     IF LS-D = 0
         MOVE 1 TO LS-STEEP
     END-IF
     MOVE 0 TO LS-DPITCH LS-DYAW
     MOVE L-X TO LS-X
     MOVE L-Y TO LS-Y
     MOVE L-Z TO LS-Z
     MOVE L-YAW TO LS-YAW
     MOVE L-PITCH TO LS-PITCH
     MOVE 0 TO LS-LEAVE
     MOVE L-START TO LS-STEP
     PERFORM UNTIL LS-STEP >= L-MAX OR LS-LEAVE = 1
*>       r = 1.5 + sin(pi * step / maxSteps) * thickness
         MOVE LS-STEP TO LS-F
         CALL "CV-FMUL" USING LS-F NC-PI LS-G
         MOVE L-MAX TO LS-F
         CALL "CV-FDIV" USING LS-G LS-F LS-A
         CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE LS-A LS-S
         CALL "CV-FMUL" USING LS-S L-THICK LS-T
         CALL STATIC "cc_f64_add" USING BY REFERENCE NC-ONE-HALF LS-T LS-R
         CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-R L-YSCALE LS-RV
*>       move
         CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE LS-PITCH LS-CP
         CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE LS-YAW LS-F
         CALL "CV-FMUL" USING LS-F LS-CP LS-T
         CALL STATIC "cc_f64_add" USING BY REFERENCE LS-X LS-T LS-G
         MOVE LS-G TO LS-X
         CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE LS-PITCH LS-T
         CALL STATIC "cc_f64_add" USING BY REFERENCE LS-Y LS-T LS-G
         MOVE LS-G TO LS-Y
         CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE LS-YAW LS-F
         CALL "CV-FMUL" USING LS-F LS-CP LS-T
         CALL STATIC "cc_f64_add" USING BY REFERENCE LS-Z LS-T LS-G
         MOVE LS-G TO LS-Z
*>       the angles
         IF LS-STEEP = 1
             CALL "CV-FMUL" USING LS-PITCH NC-K092 LS-T
         ELSE
             CALL "CV-FMUL" USING LS-PITCH NC-K07 LS-T
         END-IF
         CALL "CV-FMUL" USING LS-DPITCH NC-K01 LS-F
         CALL "CV-FADD" USING LS-T LS-F LS-PITCH
         CALL "CV-FMUL" USING LS-DYAW NC-K01 LS-F
         CALL "CV-FADD" USING LS-YAW LS-F LS-G
         MOVE LS-G TO LS-YAW
         CALL "CV-FMUL" USING LS-DPITCH NC-K09 LS-T
         MOVE LS-T TO LS-DPITCH
         CALL "CV-FMUL" USING LS-DYAW NC-K075 LS-T
         MOVE LS-T TO LS-DYAW
         CALL "JRAND-NEXT-FLOAT" USING LS-RND LS-F
         CALL "JRAND-NEXT-FLOAT" USING LS-RND LS-G
         CALL "JRAND-NEXT-FLOAT" USING LS-RND LS-H
         CALL "CV-FSUB" USING LS-F LS-G LS-T
         CALL "CV-FMUL" USING LS-T LS-H LS-A
         CALL "CV-FMUL" USING LS-A NC-TWO LS-T
         CALL "CV-FADD" USING LS-DPITCH LS-T LS-F
         MOVE LS-F TO LS-DPITCH
         CALL "JRAND-NEXT-FLOAT" USING LS-RND LS-F
         CALL "JRAND-NEXT-FLOAT" USING LS-RND LS-G
         CALL "JRAND-NEXT-FLOAT" USING LS-RND LS-H
         CALL "CV-FSUB" USING LS-F LS-G LS-T
         CALL "CV-FMUL" USING LS-T LS-H LS-A
         CALL "CV-FMUL" USING LS-A NC-FOUR LS-T
         CALL "CV-FADD" USING LS-DYAW LS-T LS-F
         MOVE LS-F TO LS-DYAW
         IF LS-STEP = LS-BRANCH AND L-THICK > 1
*>           two branches, then this walker ends
             CALL "JRAND-NEXT-LONG" USING LS-RND LC-SEED
             CALL "JRAND-NEXT-FLOAT" USING LS-RND LS-F
             CALL "CV-FMUL" USING LS-F NC-HALF LS-T
             CALL "CV-FADD" USING LS-T NC-HALF LC-THICK
             MOVE LS-X TO LC-X
             MOVE LS-Y TO LC-Y
             MOVE LS-Z TO LC-Z
             MOVE L-HMUL TO LC-HMUL
             MOVE L-VMUL TO LC-VMUL
             CALL "CV-FSUB" USING LS-YAW NC-HALF-PI LC-YAW
             CALL "CV-FDIV" USING LS-PITCH NC-THREE LC-PITCH
             MOVE 1 TO LC-YSCALE
             MOVE LS-STEP TO LC-START
             MOVE L-MAX TO LC-MAX
             CALL "NETHER-CV-WALK" USING LS-CHILD
             CALL "JRAND-NEXT-LONG" USING LS-RND LC-SEED
             CALL "JRAND-NEXT-FLOAT" USING LS-RND LS-F
             CALL "CV-FMUL" USING LS-F NC-HALF LS-T
             CALL "CV-FADD" USING LS-T NC-HALF LC-THICK
             MOVE LS-X TO LC-X
             MOVE LS-Y TO LC-Y
             MOVE LS-Z TO LC-Z
             CALL "CV-FADD" USING LS-YAW NC-HALF-PI LC-YAW
             CALL "CV-FDIV" USING LS-PITCH NC-THREE LC-PITCH
             CALL "NETHER-CV-WALK" USING LS-CHILD
             MOVE 1 TO LS-LEAVE
         ELSE
             MOVE 4 TO LS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING LS-RND LS-BOUND LS-D
             IF LS-D NOT = 0
                 CALL "NETHER-CV-REACH" USING LS-X LS-Z LS-STEP L-MAX L-THICK LS-FLAG
                 IF LS-FLAG = 0
                     MOVE 1 TO LS-LEAVE
                 ELSE
                     CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-R L-HMUL LS-HR
                     CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-RV L-VMUL LS-VR
                     CALL "NETHER-CV-ELLIPSOID" USING LS-X LS-Y LS-Z LS-HR LS-VR
                 END-IF
             END-IF
         END-IF
         ADD 1 TO LS-STEP
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-CV-WALK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CV-SOURCE.
*> USING source chunk x, z: seeds setLargeFeatureSeed(seed + 0, x, z), isStartChunk (nextFloat() <= 0.2), then count (very_biased_to_bottom 0 to 9),
*> the caves with their optional room (ellipsoid at x + 1, horizontal radius 1.5 + roomR, vertical half of it) and tunnels (yScale 5.0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 COPY NETHERCV.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-F                   FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-HR                  FLOAT-LONG.
 01 WS-VR                  FLOAT-LONG.
 01 WS-WALK.
    COPY CVWALK REPLACING LEADING ==CVK-== BY ==WK-==.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SZ.
     MOVE NH-SEED TO WS-SEED
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-R WS-SEED L-SX L-SZ
     CALL "JRAND-NEXT-FLOAT" USING WS-R WS-F
     CALL "FCMP-GT" USING WS-F NC-PROB WS-GT
     IF WS-GT = 1
         GOBACK
     END-IF
     MOVE 10 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-R WS-BOUND WS-A
     COMPUTE WS-BOUND = WS-A + 1
     CALL "JRAND-NEXT-INT-BOUND" USING WS-R WS-BOUND WS-B
     COMPUTE WS-BOUND = WS-B + 1
     CALL "JRAND-NEXT-INT-BOUND" USING WS-R WS-BOUND WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "NETHER-CV-HEAD" USING WS-R L-SX L-SZ
         MOVE NC-CAVE-X TO WS-X
         MOVE NC-CAVE-Y TO WS-Y
         MOVE NC-CAVE-Z TO WS-Z
         IF NC-CAVE-ROOM = 1
             CALL "CV-FADD" USING NC-ONE-HALF NC-CAVE-ROOMR WS-HR
             CALL "CV-FMUL" USING WS-HR NC-ROOMV WS-VR
             CALL "CV-FADD" USING WS-X NC-ONE WS-S
             CALL "NETHER-CV-ELLIPSOID" USING WS-S WS-Y WS-Z WS-HR WS-VR
         END-IF
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > NC-CAVE-TUNNELS
             CALL "NETHER-CV-TUNNEL" USING WS-R
             MOVE NC-TUN-SEED TO WK-SEED
             MOVE WS-X TO WK-X
             MOVE WS-Y TO WK-Y
             MOVE WS-Z TO WK-Z
             MOVE NC-ONE TO WK-HMUL
             MOVE NC-ONE TO WK-VMUL
             MOVE NC-TUN-THICK TO WK-THICK
             MOVE NC-TUN-YAW TO WK-YAW
             MOVE NC-TUN-PITCH TO WK-PITCH
             MOVE NC-FIVE TO WK-YSCALE
             MOVE 0 TO WK-START
             MOVE NC-TUN-STEPS TO WK-MAX
             CALL "NETHER-CV-WALK" USING WS-WALK
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-CV-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CARVE-APPLY-ONLY.
*> USING chunk memory: applies NC-MASK (7.2: lava below y 32, air from y 32, bedrock kept).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY NETHER.
 COPY NETHERCV.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                PIC X.
 PROCEDURE DIVISION USING L-CHUNK.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 120
                 COMPUTE WS-IDX = (WS-Y - 1) + (WS-Z + 16 * WS-X) * 120 + 1
                 IF NC-MASK(WS-IDX:1) = "1"
                     COMPUTE WS-CELL = WS-Y * 256 + WS-Z * 16 + WS-X + 1
                     IF CE-STATE(WS-CELL) NOT = NH-S-BEDROCK
                         IF WS-Y < 32
                             MOVE NH-S-LAVA TO CE-STATE(WS-CELL)
                         ELSE
                             MOVE 0 TO CE-STATE(WS-CELL)
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-CARVE-APPLY-ONLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CARVE.
*> The 17 x 17 source chunks (dx outer, dz inner, -8 to 8) mark the mask of the chunk; every marked block that is not bedrock (the tag
*> uncarvable) becomes what the disabled aquifer gives: lava below y 32, air from y 32.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY NETHER.
 COPY NETHERCV.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                PIC X.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CHUNK L-CX L-CZ.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     IF NC-READY = 0
         CALL "NETHER-CV-SETUP"
     END-IF
     MOVE L-CX TO NC-CX
     MOVE L-CZ TO NC-CZ
     MOVE LOW-VALUES TO NC-MASK
     PERFORM VARYING WS-DX FROM -8 BY 1 UNTIL WS-DX > 8
         PERFORM VARYING WS-DZ FROM -8 BY 1 UNTIL WS-DZ > 8
             COMPUTE WS-SX = L-CX + WS-DX
             COMPUTE WS-SZ = L-CZ + WS-DZ
             CALL "NETHER-CV-SOURCE" USING WS-SX WS-SZ
         END-PERFORM
     END-PERFORM
     CALL "NETHER-CARVE-APPLY-ONLY" USING L-CHUNK
     GOBACK.
 END PROGRAM NETHER-CARVE.
