*> Walkable blocks and the goat's run-up (docs/protocol/18 section 5.1, 54 section 7.1, 44-x2 section 1.2; lane p70c, T23503): the world reading of the path types for a ground mob and the choice of the cell the goat
*> runs from before it rams.
*>   LIVE-BLOCK-KIND USING dim, x, y, z, kind out (PIC X(16))     the kind of BLOCK-PATH-TYPE (mob-18-5.cob) of the block at the cell, from its key: air, water, lava, fire (and soul fire), cactus, sweet berry bush,
*>        honey block, cocoa, wither rose, pointed dripstone, powder snow, lily pad and big dripleaf, the "_trapdoor", "_leaves", "_fence_gate", "_fence" and "_wall" blocks, the rails; any other block is solid
*>        (BLOCKED) when it has collision (CB-SOLID) and air (OPEN) when it has none. Gap: doors are read as the solid or open block they are by collision, not as DOOR_OPEN, DOOR_WOOD_CLOSED or DOOR_IRON_CLOSED.
*>   LIVE-STATIC-PATH-TYPE USING dim, x, y, z, type out            getPathTypeStatic: the type at the feet, an OPEN cell takes its type from the block below, a WALKABLE one from the 26 neighbours
*>   MOB-WALKABLE USING dim, x, y, z, ok out                       isWalkableBlock of the goat: the ground navigation's isStableDestination (the block below is a solid block) and the default malus of the static
*>        path type exactly 0
*>   M44-RAM-RUNUP USING dim, goat block x, y, z, target block x, y, z, found out, S x, y, z out              calculateRammingStartPosition (44-x2 section 1.2)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIVE-BLOCK-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 PIC X(16).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND.
     MOVE "air" TO L-KIND
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE CB-KEY(WS-BLOCK) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-BARE TRAILING))
     EVALUATE TRUE
         WHEN WS-BARE = "water"
             MOVE "water" TO L-KIND
         WHEN WS-BARE = "lava"
             MOVE "lava" TO L-KIND
         WHEN WS-BARE = "fire" OR WS-BARE = "soul_fire"
             MOVE "fire" TO L-KIND
         WHEN WS-BARE = "cactus"
             MOVE "cactus" TO L-KIND
         WHEN WS-BARE = "sweet_berry_bush"
             MOVE "sweet_berry_bush" TO L-KIND
         WHEN WS-BARE = "honey_block"
             MOVE "honey" TO L-KIND
         WHEN WS-BARE = "cocoa"
             MOVE "cocoa" TO L-KIND
         WHEN WS-BARE = "wither_rose" OR WS-BARE = "pointed_dripstone"
             MOVE "wither_rose" TO L-KIND
         WHEN WS-BARE = "powder_snow"
             MOVE "powder_snow" TO L-KIND
         WHEN WS-BARE = "lily_pad" OR WS-BARE = "big_dripleaf"
             MOVE "lily_pad" TO L-KIND
         WHEN OTHER
             MOVE "air" TO L-KIND
             IF CB-SOLID(WS-BLOCK) = 1
                 MOVE "solid" TO L-KIND
             END-IF
*>           The families by the end of the key; the longer ending first ("_fence_gate" before "_fence").
             IF WS-LEN >= 9
                 COMPUTE WS-START = WS-LEN - 8
                 IF WS-BARE(WS-START:9) = "_trapdoor"
                     MOVE "trapdoor" TO L-KIND
                 END-IF
             END-IF
             IF WS-LEN >= 7
                 COMPUTE WS-START = WS-LEN - 6
                 IF WS-BARE(WS-START:7) = "_leaves"
                     MOVE "leaves" TO L-KIND
                 END-IF
             END-IF
             IF WS-LEN >= 11
                 COMPUTE WS-START = WS-LEN - 10
                 IF WS-BARE(WS-START:11) = "_fence_gate"
                     MOVE "fence_gate" TO L-KIND
                 END-IF
             END-IF
             IF WS-LEN >= 6
                 COMPUTE WS-START = WS-LEN - 5
                 IF WS-BARE(WS-START:6) = "_fence"
                     MOVE "fence" TO L-KIND
                 END-IF
             END-IF
             IF WS-LEN >= 5
                 COMPUTE WS-START = WS-LEN - 4
                 IF WS-BARE(WS-START:5) = "_wall"
                     MOVE "wall" TO L-KIND
                 END-IF
             END-IF
             IF WS-LEN >= 4
                 COMPUTE WS-START = WS-LEN - 3
                 IF WS-BARE(WS-START:4) = "rail"
                     MOVE "rail" TO L-KIND
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM LIVE-BLOCK-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIVE-BLOCK-TYPE.
*> USING dim, x, y, z, type out: getPathTypeFromState of the block at the cell (BLOCK-PATH-TYPE of its kind).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                PIC X(16).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TYPE.
     CALL "LIVE-BLOCK-KIND" USING L-DIM L-X L-Y L-Z WS-KIND
     CALL "BLOCK-PATH-TYPE" USING WS-KIND L-TYPE
     GOBACK.
 END PROGRAM LIVE-BLOCK-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIVE-STATIC-PATH-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-AT                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NT                  BINARY-LONG.
 01 WS-DAMAGING            BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-CAUTIOUS            BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TYPE.
     CALL "LIVE-BLOCK-TYPE" USING L-DIM L-X L-Y L-Z WS-AT
     COMPUTE WS-YB = FUNCTION MAX(L-Y - 1, DM-MIN-Y(L-DIM))
     CALL "LIVE-BLOCK-TYPE" USING L-DIM L-X WS-YB L-Z WS-BELOW
     CALL "STATIC-PATH-TYPE" USING WS-AT WS-BELOW WS-TYPE
     MOVE WS-TYPE TO L-TYPE
     IF WS-TYPE = 2
         MOVE 0 TO WS-DAMAGING WS-FIRE WS-WATER WS-CAUTIOUS
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
                 PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                     COMPUTE WS-NX = L-X + WS-DX
                     COMPUTE WS-NY = L-Y + WS-DY
                     COMPUTE WS-NZ = L-Z + WS-DZ
                     CALL "LIVE-BLOCK-TYPE" USING L-DIM WS-NX WS-NY WS-NZ WS-NT
                     IF WS-NT = 16
                         MOVE 1 TO WS-DAMAGING
                     END-IF
                     IF WS-NT = 14 OR WS-NT = 8
                         MOVE 1 TO WS-FIRE
                     END-IF
                     IF WS-NT = 9
                         MOVE 1 TO WS-WATER
                     END-IF
                     IF WS-NT = 24
                         MOVE 1 TO WS-CAUTIOUS
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         CALL "NEIGHBOUR-ADJUST" USING WS-TYPE WS-DAMAGING WS-FIRE WS-WATER WS-CAUTIOUS L-TYPE
     END-IF
     GOBACK.
 END PROGRAM LIVE-STATIC-PATH-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-WALKABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CELL                BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MALUS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     COMPUTE WS-YB = L-Y - 1
     CALL "STDMOB-CELL" USING L-DIM L-X WS-YB L-Z WS-CELL
     IF WS-CELL NOT = 1
         GOBACK
     END-IF
     CALL "LIVE-STATIC-PATH-TYPE" USING L-DIM L-X L-Y L-Z WS-TYPE
     CALL "PATH-MALUS-DEFAULT" USING WS-TYPE WS-MALUS
     IF WS-MALUS = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MOB-WALKABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-RAM-RUNUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRX-DATA.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
 01 WS-DIRX REDEFINES WS-DIRX-DATA.
    05 WS-DX               BINARY-LONG OCCURS 4 TIMES.
 01 WS-DIRZ-DATA.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DIRZ REDEFINES WS-DIRZ-DATA.
    05 WS-DZ               BINARY-LONG OCCURS 4 TIMES.
 01 WS-CANDS.
    05 WS-CAND OCCURS 4 TIMES.
       10 WC-X             BINARY-LONG.
       10 WC-Z             BINARY-LONG.
       10 WC-D2            BINARY-LONG.
 01 WS-TMP.
    05 WT-X                BINARY-LONG.
    05 WT-Z                BINARY-LONG.
    05 WT-D2               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-MAN                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG VALUE 2.
 01 WS-BUDGET              BINARY-LONG VALUE 100.
 01 WS-PATH-TABLE.
    05 WS-PATH OCCURS 128 TIMES.
       10 WS-PX-OF         BINARY-LONG.
       10 WS-PY-OF         BINARY-LONG.
       10 WS-PZ-OF         BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-GX                   BINARY-LONG.
 01 L-GY                   BINARY-LONG.
 01 L-GZ                   BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-TZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-GX L-GY L-GZ L-TX L-TY L-TZ L-FOUND L-SX L-SY L-SZ.
     MOVE 0 TO L-FOUND L-SX L-SY L-SZ WS-N
     CALL "MOB-WALKABLE" USING L-DIM L-TX L-TY L-TZ WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
*>   Each horizontal direction (north, east, south, west) from T: up to 7 steps while the next block is walkable; a candidate at least 4 away (Manhattan) from T.
     PERFORM VARYING WS-DIR FROM 1 BY 1 UNTIL WS-DIR > 4
         MOVE L-TX TO WS-PX
         MOVE L-TZ TO WS-PZ
         MOVE 0 TO WS-STOP
         PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 7 OR WS-STOP = 1
             COMPUTE WS-NX = WS-PX + WS-DX(WS-DIR)
             COMPUTE WS-NZ = WS-PZ + WS-DZ(WS-DIR)
             CALL "MOB-WALKABLE" USING L-DIM WS-NX L-TY WS-NZ WS-OK
             IF WS-OK = 1
                 MOVE WS-NX TO WS-PX
                 MOVE WS-NZ TO WS-PZ
             ELSE
                 MOVE 1 TO WS-STOP
             END-IF
         END-PERFORM
         COMPUTE WS-MAN = FUNCTION ABS(WS-PX - L-TX) + FUNCTION ABS(WS-PZ - L-TZ)
         IF WS-MAN >= 4
             ADD 1 TO WS-N
             MOVE WS-PX TO WC-X(WS-N)
             MOVE WS-PZ TO WC-Z(WS-N)
             COMPUTE WC-D2(WS-N) = (WS-PX - L-GX) ** 2 + (L-TY - L-GY) ** 2 + (WS-PZ - L-GZ) ** 2
         END-IF
     END-PERFORM
*>   Sorted by the squared distance from the goat's block, a stable insertion sort.
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > WS-N
         MOVE WS-CAND(WS-I) TO WS-TMP
         COMPUTE WS-J = WS-I - 1
         PERFORM UNTIL WS-J < 1 OR WC-D2(WS-J) <= WT-D2
             MOVE WS-CAND(WS-J) TO WS-CAND(WS-J + 1)
             SUBTRACT 1 FROM WS-J
         END-PERFORM
         MOVE WS-TMP TO WS-CAND(WS-J + 1)
     END-PERFORM
*>   The first one with a path that reaches it (createPath of distance 0 and canReach).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR L-FOUND = 1
         CALL "STDMOB-PATH" USING L-DIM L-GX L-GY L-GZ WC-X(WS-I) L-TY WC-Z(WS-I) WS-HEIGHT WS-BUDGET
             WS-PATH-TABLE WS-COUNT WS-REACHED
         IF WS-COUNT > 0 AND WS-REACHED = 1
             MOVE 1 TO L-FOUND
             MOVE WC-X(WS-I) TO L-SX
             MOVE L-TY TO L-SY
             MOVE WC-Z(WS-I) TO L-SZ
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M44-RAM-RUNUP.
