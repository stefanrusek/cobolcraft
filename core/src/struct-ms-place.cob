*> The mineshaft, part 2: the blocks of its pieces (docs/protocol/36-structures-5-mineshaft-stronghold.md sections 2.5 to 2.12; 36-1 6.5), the postProcess of every piece type. The random is
*> the decoration random SP-XR of 36-1 8 (Xoroshiro, setFeatureSeed). Every directional state is written as in the north oriented frame and passes the piece's mirror and rotation (SPB-DIR-XFORM).
*> Deviations: the chest minecart of 2.10 makes its rail and draws (the shape and the loot seed) but the minecart entity is not made (worldgen has an entity channel for neither
*> structure entities nor minecarts); the spawner's entity id goes through the block-entity channel (GENBE.cpy) and its setEntityId makes no draw (31 section 7 is not built); a chain
*> hangs only from a cell more than one above the post (the document does not say what a block directly above does); shape-check marks are not made.
*>
*> Entry points: MS-POST USING row (postProcess by the piece type); MSP-INTERIOR USING row, local x y z, flag out (isInterior); MSP-INVALID USING row, flag out (isInInvalidLocation).
*> The random wrappers MSP-RNG-INT USING bound, value out; MSP-RNG-BOOL USING value out; MSP-RNG-LONG USING value out (BINARY-DOUBLE) work on SP-XR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-RNG-INT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 LINKAGE SECTION.
 01 L-BOUND                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-BOUND L-VALUE.
     MOVE SP-XR-LO TO WX-LO
     MOVE SP-XR-HI TO WX-HI
     CALL "WGR-NEXT-INT-BOUND" USING WS-XR L-BOUND L-VALUE
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     GOBACK.
 END PROGRAM MSP-RNG-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-RNG-BOOL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     MOVE SP-XR-LO TO WX-LO
     MOVE SP-XR-HI TO WX-HI
     CALL "F351-NEXT-BOOLEAN" USING WS-XR L-VALUE
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     GOBACK.
 END PROGRAM MSP-RNG-BOOL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-RNG-LONG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-M63                 PIC 9(20) VALUE 9223372036854775808.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-VALUE.
     MOVE SP-XR-LO TO WX-LO
     MOVE SP-XR-HI TO WX-HI
     CALL "WGR-NEXT-LONG" USING WS-XR WS-U
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     COMPUTE L-VALUE = FUNCTION MOD(WS-U + WS-M63, WS-M64) - WS-M63
     GOBACK.
 END PROGRAM MSP-RNG-LONG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-INTERIOR.
*> isInterior (6.5): the world position of (x, y + 1, z) is inside the write box and below the OCEAN_FLOOR_WG height of its column.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-LY                  BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-ORD                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE WS-LY = L-Y + 1
     CALL "SPB-WORLD" USING L-ROW L-X WS-LY L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 1
         CALL "FL-HEIGHT-OF" USING WS-ORD WS-WX WS-WZ WS-H
         IF WS-WY < WS-H
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MSP-INTERIOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-LIQUID.
*> USING x y z (world), flag out: 1 when the block is water or lava.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     MOVE 0 TO L-FLAG
     IF WS-CLASS = 2 OR WS-CLASS = 3
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM MSP-LIQUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-INVALID.
*> isInInvalidLocation (2.9): the box grown by one and clipped to the write box; invalid when the biome at its integer midpoint is in mineshaft_blocking, or a block on any of its six faces is
*> a liquid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTDATA.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-LIQ                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE WS-X0 = FUNCTION MAX(SP-X0(L-ROW) - 1, SW-X0)
     COMPUTE WS-Y0 = FUNCTION MAX(SP-Y0(L-ROW) - 1, SW-Y0)
     COMPUTE WS-Z0 = FUNCTION MAX(SP-Z0(L-ROW) - 1, SW-Z0)
     COMPUTE WS-X1 = FUNCTION MIN(SP-X1(L-ROW) + 1, SW-X1)
     COMPUTE WS-Y1 = FUNCTION MIN(SP-Y1(L-ROW) + 1, SW-Y1)
     COMPUTE WS-Z1 = FUNCTION MIN(SP-Z1(L-ROW) + 1, SW-Z1)
     COMPUTE WS-SUM = WS-X0 + WS-X1
     DIVIDE WS-SUM BY 2 GIVING WS-MX
     COMPUTE WS-SUM = WS-Y0 + WS-Y1
     DIVIDE WS-SUM BY 2 GIVING WS-MY
     COMPUTE WS-SUM = WS-Z0 + WS-Z1
     DIVIDE WS-SUM BY 2 GIVING WS-MZ
     CALL "FL-BIOME-AT" USING WS-MX WS-MY WS-MZ WS-BIOME
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= SD-BLOCK-COUNT
         IF SD-BIOME(SD-BLOCK-FIRST + WS-I) = WS-BIOME
             MOVE 1 TO L-FLAG
         END-IF
     END-PERFORM
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             CALL "MSP-LIQUID" USING WS-X WS-Y0 WS-Z WS-LIQ
             IF WS-LIQ = 1
                 MOVE 1 TO L-FLAG
             END-IF
             CALL "MSP-LIQUID" USING WS-X WS-Y1 WS-Z WS-LIQ
             IF WS-LIQ = 1
                 MOVE 1 TO L-FLAG
             END-IF
         END-PERFORM
         PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
             CALL "MSP-LIQUID" USING WS-X WS-Y WS-Z0 WS-LIQ
             IF WS-LIQ = 1
                 MOVE 1 TO L-FLAG
             END-IF
             CALL "MSP-LIQUID" USING WS-X WS-Y WS-Z1 WS-LIQ
             IF WS-LIQ = 1
                 MOVE 1 TO L-FLAG
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             CALL "MSP-LIQUID" USING WS-X0 WS-Y WS-Z WS-LIQ
             IF WS-LIQ = 1
                 MOVE 1 TO L-FLAG
             END-IF
             CALL "MSP-LIQUID" USING WS-X1 WS-Y WS-Z WS-LIQ
             IF WS-LIQ = 1
                 MOVE 1 TO L-FLAG
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MSP-INVALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-SET-PLANKS.
*> setPlanksBlock (2.7): nothing unless the cell is interior; the state is set (flags 2) when the block there is not a full cube (its up face is not sturdy).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INT                 BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATE L-X L-Y L-Z.
     CALL "MSP-INTERIOR" USING L-ROW L-X L-Y L-Z WS-INT
     IF WS-INT = 1
         CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
         CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
         CALL "MSP-FULL" USING WS-STATE WS-FULL
         IF WS-FULL = 0
             CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ L-STATE WS-FLAGS WS-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MSP-SET-PLANKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-PILLAR.
*> fillPillarDownOrChainUp (2.7): from the post cell look down up to 20 cells (not below min y + 2) through free cells (replaceable by structures, not lava): a full cube at the first
*> other cell gets a pillar of the state above it up to the cell below the start; else look up up to 50 cells (not reaching the top) and hang a fence and a chain from a full, not falling block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY FEATLEVEL.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATE L-X L-Y L-Z.
     CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE
*>   down: free cells, then a full cube
     MOVE 1 TO WS-FREE
     MOVE 0 TO WS-K
     PERFORM UNTIL WS-FREE = 0 OR WS-K >= 20
         ADD 1 TO WS-K
         COMPUTE WS-Y = WS-WY - WS-K
         IF WS-Y < FL-MIN-Y + 2
             MOVE 0 TO WS-FREE
             MOVE 21 TO WS-K
         ELSE
             CALL "FL-GET-STATE" USING WS-WX WS-Y WS-WZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             CALL "FL-BLOCK-OF" USING WS-STATE WS-B
             MOVE 0 TO WS-FREE
             IF WS-CLASS = 1 OR WS-CLASS = 2
                 MOVE 1 TO WS-FREE
             END-IF
             IF WS-B > 0
                 IF WS-CLASS NOT = 3 AND (SBK-FLAGS(WS-B) = 2 OR SBK-FLAGS(WS-B) = 3)
                     MOVE 1 TO WS-FREE
                 END-IF
             END-IF
             IF WS-FREE = 0
                 CALL "MSP-FULL" USING WS-STATE WS-FULL
                 IF WS-FULL = 1
                     MOVE 1 TO WS-DONE
                     PERFORM VARYING WS-T FROM WS-Y BY 1 UNTIL WS-T >= WS-WY - 1
                         COMPUTE WS-LIMIT = WS-T + 1
                         CALL "FL-SET-STATE" USING WS-WX WS-LIMIT WS-WZ L-STATE WS-FLAGS WS-OK
                     END-PERFORM
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   up: free cells, then a full cube that is not a falling block: a fence above the post and a chain below the cell
     IF WS-DONE = 0
         MOVE 1 TO WS-FREE
         MOVE 0 TO WS-K
         PERFORM UNTIL WS-FREE = 0 OR WS-K >= 50
             ADD 1 TO WS-K
             COMPUTE WS-Y = WS-WY + WS-K
             IF WS-Y >= FL-MIN-Y + FL-HEIGHT - 1
                 MOVE 0 TO WS-FREE
                 MOVE 51 TO WS-K
             ELSE
                 CALL "FL-GET-STATE" USING WS-WX WS-Y WS-WZ WS-STATE
                 CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-B
                 MOVE 0 TO WS-FREE
                 IF WS-CLASS = 1 OR WS-CLASS = 2
                     MOVE 1 TO WS-FREE
                 END-IF
                 IF WS-B > 0
                     IF WS-CLASS NOT = 3 AND (SBK-FLAGS(WS-B) = 2 OR SBK-FLAGS(WS-B) = 3)
                         MOVE 1 TO WS-FREE
                     END-IF
                 END-IF
                 IF WS-FREE = 0 AND WS-K > 1
                     CALL "MSP-FULL" USING WS-STATE WS-FULL
                     IF WS-FULL = 1 AND WS-B > 0 AND SBK-FLAGS(WS-B) NOT = 1 AND SBK-FLAGS(WS-B) NOT = 3
                         COMPUTE WS-T = SP-MST(L-ROW) + 1
                         COMPUTE WS-LIMIT = WS-WY + 1
                         CALL "FL-SET-STATE" USING WS-WX WS-LIMIT WS-WZ SBK-FENCE-P(WS-T) WS-FLAGS WS-OK
                         PERFORM VARYING WS-T FROM WS-WY BY 1 UNTIL WS-T + 2 >= WS-Y
                             COMPUTE WS-LIMIT = WS-T + 2
                             CALL "FL-SET-STATE" USING WS-WX WS-LIMIT WS-WZ SBK-S-CHAIN WS-FLAGS WS-OK
                         END-PERFORM
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM MSP-PILLAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-COBWEB.
*> maybePlaceCobWeb (2.8): at an interior cell, a nextFloat below the chance (drawn only for an interior cell) and two full neighbours among the six (down, up, north, south, west, east of
*> the world position, inside the write box) place a cobweb.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-INT                 BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CHANCE L-X L-Y L-Z.
     CALL "MSP-INTERIOR" USING L-ROW L-X L-Y L-Z WS-INT
     IF WS-INT = 0
         GOBACK
     END-IF
     MOVE SP-XR-LO TO WX-LO
     MOVE SP-XR-HI TO WX-HI
     CALL "WGR-NEXT-FLOAT" USING WS-XR WS-DRAW
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     IF WS-DRAW >= L-CHANCE
         GOBACK
     END-IF
     CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     MOVE 0 TO WS-COUNT
*>   down, up, north, south, west, east
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
         MOVE 0 TO WS-NX WS-NY WS-NZ
         EVALUATE WS-D
             WHEN 1
                 MOVE -1 TO WS-NY
             WHEN 2
                 MOVE 1 TO WS-NY
             WHEN 3
                 MOVE -1 TO WS-NZ
             WHEN 4
                 MOVE 1 TO WS-NZ
             WHEN 5
                 MOVE -1 TO WS-NX
             WHEN OTHER
                 MOVE 1 TO WS-NX
         END-EVALUATE
         COMPUTE WS-NX = WS-WX + WS-NX
         COMPUTE WS-NY = WS-WY + WS-NY
         COMPUTE WS-NZ = WS-WZ + WS-NZ
         CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-NX WS-NY WS-NZ WS-IN
         IF WS-IN = 1
             CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
             CALL "MSP-FULL" USING WS-STATE WS-FULL
             IF WS-FULL = 1
                 ADD 1 TO WS-COUNT
             END-IF
         END-IF
     END-PERFORM
     IF WS-COUNT >= 2
         CALL "MSP-PLACE" USING L-ROW L-X L-Y L-Z SBK-S-COBWEB
     END-IF
     GOBACK.
 END PROGRAM MSP-COBWEB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-SUPPORT.
*> placeSupport(0, 0, z, 2, 2) (2.7) of a corridor section: only under a ceiling (the three cells above the beam are not air); a fence post on each wall (west and east connections of
*> the north frame), then nextInt(4): 0 two separate planks, else a plank beam and two torches at 5 percent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 01 WS-X                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DW                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 4.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-SKIP                BINARY-LONG VALUE 0.
 01 WS-CHANCE              FLOAT-LONG VALUE 0.0500000007450580596923828125.
 01 WS-DIR-W               BINARY-LONG VALUE 1.
 01 WS-DIR-E               BINARY-LONG VALUE 3.
 01 WS-DIR-S               BINARY-LONG VALUE 0.
 01 WS-DIR-N               BINARY-LONG VALUE 2.
 01 WS-Z0                  BINARY-LONG VALUE 0.
 01 WS-Y1                  BINARY-LONG VALUE 1.
 01 WS-Y2                  BINARY-LONG VALUE 2.
 01 WS-X2                  BINARY-LONG VALUE 2.
 01 WS-X1                  BINARY-LONG VALUE 1.
 01 WS-X0                  BINARY-LONG VALUE 0.
 01 WS-Y3                  BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-Z.
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 2
         CALL "MSP-GET" USING L-ROW WS-X WS-Y3 L-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS = 1
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     IF WS-OK = 0
         GOBACK
     END-IF
     COMPUTE WS-T = SP-MST(L-ROW) + 1
     CALL "SPB-DIR-XFORM" USING L-ROW WS-DIR-W WS-D
     COMPUTE WS-DW = WS-D + 1
     CALL "MSP-BOX" USING L-ROW WS-X0 WS-Z0 L-Z BY CONTENT WS-X0 BY REFERENCE WS-Y1 BY CONTENT L-Z BY REFERENCE SBK-FENCE-S(WS-T, WS-DW) SBK-S-CAVE-AIR WS-SKIP
     CALL "SPB-DIR-XFORM" USING L-ROW WS-DIR-E WS-D
     COMPUTE WS-DW = WS-D + 1
     CALL "MSP-BOX" USING L-ROW WS-X2 WS-Z0 L-Z BY CONTENT WS-X2 BY REFERENCE WS-Y1 BY CONTENT L-Z BY REFERENCE SBK-FENCE-S(WS-T, WS-DW) SBK-S-CAVE-AIR WS-SKIP
     CALL "MSP-RNG-INT" USING WS-BOUND WS-DRAW
     IF WS-DRAW = 0
         CALL "MSP-PLACE" USING L-ROW WS-X0 WS-Y2 L-Z SBK-PLANKS-S(WS-T)
         CALL "MSP-PLACE" USING L-ROW WS-X2 WS-Y2 L-Z SBK-PLANKS-S(WS-T)
     ELSE
         CALL "MSP-BOX" USING L-ROW WS-X0 WS-Y2 L-Z WS-X2 BY CONTENT WS-Y2 BY CONTENT L-Z BY REFERENCE SBK-PLANKS-S(WS-T) BY CONTENT SBK-PLANKS-S(WS-T) BY REFERENCE WS-SKIP
         COMPUTE WS-Z1 = L-Z - 1
         COMPUTE WS-Z2 = L-Z + 1
         CALL "SPB-DIR-XFORM" USING L-ROW WS-DIR-S WS-D
         COMPUTE WS-DW = WS-D + 1
         CALL "MSP-MAYBE-BLOCK" USING L-ROW WS-CHANCE WS-X1 WS-Y2 WS-Z1 SBK-S-TORCH(WS-DW)
         CALL "SPB-DIR-XFORM" USING L-ROW WS-DIR-N WS-D
         COMPUTE WS-DW = WS-D + 1
         CALL "MSP-MAYBE-BLOCK" USING L-ROW WS-CHANCE WS-X1 WS-Y2 WS-Z2 SBK-S-TORCH(WS-DW)
     END-IF
     GOBACK.
 END PROGRAM MSP-SUPPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-CART.
*> createChest of a corridor (2.10): at a free cell with a block below, nextBoolean picks the rail shape (true north_south in the north frame) and the rail is placed; the loot seed is the
*> next nextLong (the minecart entity itself is not made, see the file header).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 0
         GOBACK
     END-IF
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS NOT = 1
         GOBACK
     END-IF
     COMPUTE WS-BELOW = WS-WY - 1
     CALL "FL-GET-STATE" USING WS-WX WS-BELOW WS-WZ WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS = 1
         GOBACK
     END-IF
     CALL "MSP-RNG-BOOL" USING WS-BOOL
     MOVE 2 TO WS-IDX
     IF WS-BOOL = 1
         MOVE 1 TO WS-IDX
     END-IF
*>   an east or west piece turns the shape a quarter
     IF SP-ORIENT(L-ROW) = 1 OR SP-ORIENT(L-ROW) = 3
         COMPUTE WS-IDX = 3 - WS-IDX
     END-IF
     CALL "MSP-PLACE" USING L-ROW L-X L-Y L-Z SBK-S-RAIL(WS-IDX)
     CALL "MSP-RNG-LONG" USING WS-SEED
     GOBACK.
 END PROGRAM MSP-CART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-POST-ROOM.
*> The room (2.5): air from the second layer up three layers, the entrances opened to the head, then an upper half sphere; none of it where the location is invalid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 01 WS-AIR                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SBK-S-CAVE-AIR TO WS-AIR
     COMPUTE WS-Y = FUNCTION MIN(SP-Y0(L-ROW) + 3, SP-Y1(L-ROW))
     COMPUTE WS-N = SP-Y0(L-ROW) + 1
     CALL "MSP-BOX" USING L-ROW SP-X0(L-ROW) WS-N SP-Z0(L-ROW) SP-X1(L-ROW) WS-Y SP-Z1(L-ROW) WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
     PERFORM VARYING WS-I FROM SP-ENT-FIRST(L-ROW) BY 1 UNTIL WS-I >= SP-ENT-FIRST(L-ROW) + SP-ENT-N(L-ROW)
         COMPUTE WS-N = SE-Y1(WS-I) - 2
         CALL "MSP-BOX" USING L-ROW SE-X0(WS-I) WS-N SE-Z0(WS-I) SE-X1(WS-I) SE-Y1(WS-I) SE-Z1(WS-I) WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
     END-PERFORM
     COMPUTE WS-N = SP-Y0(L-ROW) + 4
     CALL "MSP-SPHERE" USING L-ROW SP-X0(L-ROW) WS-N SP-Z0(L-ROW) SP-X1(L-ROW) SP-Y1(L-ROW) SP-Z1(L-ROW) WS-AIR WS-NO
     GOBACK.
 END PROGRAM MS-POST-ROOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-POST-CROSSING.
*> The crossing (2.11): one box pair of air, or five when two floored, four support pillars at the inner corners (planks when there is a block above the top), the plank floor.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 01 WS-AIR                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-T                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SBK-S-CAVE-AIR TO WS-AIR
     COMPUTE WS-T = SP-MST(L-ROW) + 1
     COMPUTE WS-A = SP-X0(L-ROW) + 1
     COMPUTE WS-B = SP-X1(L-ROW) - 1
     COMPUTE WS-C = SP-Z0(L-ROW) + 1
     COMPUTE WS-D = SP-Z1(L-ROW) - 1
     IF SP-F1(L-ROW) = 1
         COMPUTE WS-E = SP-Y0(L-ROW) + 2
         CALL "MSP-BOX" USING L-ROW WS-A SP-Y0(L-ROW) SP-Z0(L-ROW) WS-B WS-E SP-Z1(L-ROW) WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
         CALL "MSP-BOX" USING L-ROW SP-X0(L-ROW) SP-Y0(L-ROW) WS-C SP-X1(L-ROW) WS-E WS-D WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
         COMPUTE WS-E = SP-Y1(L-ROW) - 2
         CALL "MSP-BOX" USING L-ROW WS-A WS-E SP-Z0(L-ROW) WS-B SP-Y1(L-ROW) SP-Z1(L-ROW) WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
         CALL "MSP-BOX" USING L-ROW SP-X0(L-ROW) WS-E WS-C SP-X1(L-ROW) SP-Y1(L-ROW) WS-D WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
         COMPUTE WS-E = SP-Y0(L-ROW) + 3
         CALL "MSP-BOX" USING L-ROW WS-A WS-E WS-C WS-B BY CONTENT WS-E BY REFERENCE WS-D WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
     ELSE
         CALL "MSP-BOX" USING L-ROW WS-A SP-Y0(L-ROW) SP-Z0(L-ROW) WS-B SP-Y1(L-ROW) SP-Z1(L-ROW) WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
         CALL "MSP-BOX" USING L-ROW SP-X0(L-ROW) SP-Y0(L-ROW) WS-C SP-X1(L-ROW) SP-Y1(L-ROW) WS-D WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
     END-IF
     COMPUTE WS-Y = SP-Y1(L-ROW) + 1
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         EVALUATE WS-K
             WHEN 1
                 MOVE WS-A TO WS-X
                 MOVE WS-C TO WS-Z
             WHEN 2
                 MOVE WS-A TO WS-X
                 MOVE WS-D TO WS-Z
             WHEN 3
                 MOVE WS-B TO WS-X
                 MOVE WS-C TO WS-Z
             WHEN OTHER
                 MOVE WS-B TO WS-X
                 MOVE WS-D TO WS-Z
         END-EVALUATE
         CALL "MSP-GET" USING L-ROW WS-X WS-Y WS-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS NOT = 1
             CALL "MSP-BOX" USING L-ROW WS-X SP-Y0(L-ROW) WS-Z BY CONTENT WS-X BY REFERENCE SP-Y1(L-ROW) BY CONTENT WS-Z BY REFERENCE SBK-PLANKS-S(WS-T) WS-AIR WS-NO
         END-IF
     END-PERFORM
     COMPUTE WS-Y = SP-Y0(L-ROW) - 1
     PERFORM VARYING WS-X FROM SP-X0(L-ROW) BY 1 UNTIL WS-X > SP-X1(L-ROW)
         PERFORM VARYING WS-Z FROM SP-Z0(L-ROW) BY 1 UNTIL WS-Z > SP-Z1(L-ROW)
             CALL "MSP-SET-PLANKS" USING L-ROW SBK-PLANKS-S(WS-T) WS-X WS-Y WS-Z
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MS-POST-CROSSING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-POST-STAIRS.
*> The stairs (2.12): a diagonal air tunnel, in the piece's own frame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTBLK.
 01 WS-AIR                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG VALUE 0.
 01 WS-X2                  BINARY-LONG VALUE 2.
 01 WS-V0                  BINARY-LONG VALUE 0.
 01 WS-V1                  BINARY-LONG VALUE 1.
 01 WS-V5                  BINARY-LONG VALUE 5.
 01 WS-V7                  BINARY-LONG VALUE 7.
 01 WS-V8                  BINARY-LONG VALUE 8.
 01 WS-V2                  BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SBK-S-CAVE-AIR TO WS-AIR
     CALL "MSP-BOX" USING L-ROW WS-X0 WS-V5 WS-V0 WS-X2 WS-V7 WS-V1 WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
     CALL "MSP-BOX" USING L-ROW WS-X0 WS-V0 WS-V7 WS-X2 WS-V2 WS-V8 WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         COMPUTE WS-A = 5 - WS-I
         IF WS-I < 4
             SUBTRACT 1 FROM WS-A
         END-IF
         COMPUTE WS-B = 2 + WS-I
         COMPUTE WS-C = 7 - WS-I
         CALL "MSP-BOX" USING L-ROW WS-X0 WS-A WS-B WS-X2 WS-C BY CONTENT WS-B BY REFERENCE WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
     END-PERFORM
     GOBACK.
 END PROGRAM MS-POST-STAIRS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-POST-CORRIDOR.
*> The corridor (2.6) in its local frame: the shaft cleared, the ceiling opened in 80 percent, cobwebs for a spider corridor, per section the support, eight cobwebs, two chest minecart
*> rails (1 in 100 each) and the spider spawner once; then the plank floor, two double supports and the rails.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 01 WS-AIR                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-T                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ZA                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-B100                BINARY-LONG VALUE 100.
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-V0                  BINARY-LONG VALUE 0.
 01 WS-V1                  BINARY-LONG VALUE 1.
 01 WS-V2                  BINARY-LONG VALUE 2.
 01 WS-VM1                 BINARY-LONG VALUE -1.
 01 WS-SZ                  BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-GET-Y               BINARY-LONG.
 01 WS-RAIL                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-NOLOOT              PIC X(48) VALUE SPACES.
 01 WS-SPIDER              PIC X(32) VALUE "minecraft:cave_spider".
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-C08                 FLOAT-LONG VALUE 0.800000011920928955078125.
 01 WS-C06                 FLOAT-LONG VALUE 0.60000002384185791015625.
 01 WS-C07                 FLOAT-LONG VALUE 0.699999988079071044921875.
 01 WS-C09                 FLOAT-LONG VALUE 0.89999997615814208984375.
 01 WS-C01                 FLOAT-LONG VALUE 0.100000001490116119384765625.
 01 WS-C005                FLOAT-LONG VALUE 0.0500000007450580596923828125.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-X2                  BINARY-LONG VALUE 2.
 01 WS-X0                  BINARY-LONG VALUE 0.
 01 WS-XM                  BINARY-LONG VALUE 1.
 01 WS-Y2                  BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SBK-S-CAVE-AIR TO WS-AIR
     COMPUTE WS-T = SP-MST(L-ROW) + 1
     COMPUTE WS-LEN = 5 * SP-F4(L-ROW) - 1
     CALL "MSP-BOX" USING L-ROW WS-X0 WS-V0 BY CONTENT WS-V0 BY REFERENCE WS-X2 WS-V1 WS-LEN WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO
     CALL "MSP-MAYBE-BOX" USING L-ROW WS-C08 WS-X0 WS-Y2 WS-V0 WS-X2 BY CONTENT WS-Y2 BY REFERENCE WS-LEN WS-AIR BY CONTENT WS-AIR BY REFERENCE WS-NO BY CONTENT WS-NO
     IF SP-F2(L-ROW) = 1
         CALL "MSP-MAYBE-BOX" USING L-ROW WS-C06 WS-X0 WS-V0 BY CONTENT WS-V0 BY REFERENCE WS-X2 WS-V1 WS-LEN SBK-S-COBWEB WS-AIR WS-NO WS-YES
     END-IF
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SP-F4(L-ROW)
         COMPUTE WS-Z = 2 + 5 * WS-K
         CALL "MSP-SUPPORT" USING L-ROW WS-Z
         COMPUTE WS-ZA = WS-Z - 1
         CALL "MSP-COBWEB" USING L-ROW WS-C01 WS-X0 WS-Y2 WS-ZA
         CALL "MSP-COBWEB" USING L-ROW WS-C01 WS-X2 WS-Y2 WS-ZA
         COMPUTE WS-ZA = WS-Z + 1
         CALL "MSP-COBWEB" USING L-ROW WS-C01 WS-X0 WS-Y2 WS-ZA
         CALL "MSP-COBWEB" USING L-ROW WS-C01 WS-X2 WS-Y2 WS-ZA
         COMPUTE WS-ZA = WS-Z - 2
         CALL "MSP-COBWEB" USING L-ROW WS-C005 WS-X0 WS-Y2 WS-ZA
         CALL "MSP-COBWEB" USING L-ROW WS-C005 WS-X2 WS-Y2 WS-ZA
         COMPUTE WS-ZA = WS-Z + 2
         CALL "MSP-COBWEB" USING L-ROW WS-C005 WS-X0 WS-Y2 WS-ZA
         CALL "MSP-COBWEB" USING L-ROW WS-C005 WS-X2 WS-Y2 WS-ZA
         CALL "MSP-RNG-INT" USING WS-B100 WS-DRAW
         IF WS-DRAW = 0
             COMPUTE WS-ZA = WS-Z - 1
             CALL "MSP-CART" USING L-ROW WS-X2 WS-V0 WS-ZA
         END-IF
         CALL "MSP-RNG-INT" USING WS-B100 WS-DRAW
         IF WS-DRAW = 0
             COMPUTE WS-ZA = WS-Z + 1
             CALL "MSP-CART" USING L-ROW WS-X0 WS-V0 WS-ZA
         END-IF
         IF SP-F2(L-ROW) = 1 AND SP-F3(L-ROW) = 0
             CALL "MSP-RNG-INT" USING WS-B3 WS-DRAW
             COMPUTE WS-SZ = WS-Z - 1 + WS-DRAW
             CALL "SPB-WORLD" USING L-ROW WS-XM WS-V0 WS-SZ WS-WX WS-WY WS-WZ
             CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
             CALL "MSP-INTERIOR" USING L-ROW WS-XM WS-V0 WS-SZ WS-INT
             IF WS-IN = 1 AND WS-INT = 1
                 MOVE 1 TO SP-F3(L-ROW)
                 CALL "MSP-PLACE-RAW" USING WS-WX WS-WY WS-WZ SBK-S-SPAWNER
                 CALL "GBE-ADD" USING WS-WX WS-WY WS-WZ WS-KIND WS-NOLOOT WS-SEED WS-SPIDER
             END-IF
         END-IF
     END-PERFORM
     MOVE -1 TO WS-Y
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 2
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > WS-LEN
             CALL "MSP-SET-PLANKS" USING L-ROW SBK-PLANKS-S(WS-T) WS-X WS-Y WS-Z
         END-PERFORM
     END-PERFORM
     MOVE 2 TO WS-Z
     CALL "MSP-DOUBLE" USING L-ROW WS-X0 WS-Y WS-Z
     IF SP-F4(L-ROW) > 1
         COMPUTE WS-Z = WS-LEN - 2
         CALL "MSP-DOUBLE" USING L-ROW WS-X0 WS-Y WS-Z
     END-IF
     IF SP-F1(L-ROW) = 1
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > WS-LEN
             CALL "MSP-GET" USING L-ROW WS-XM WS-VM1 WS-Z WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             CALL "MSP-FULL" USING WS-STATE WS-FULL
             IF WS-CLASS NOT = 1 AND WS-FULL = 1
                 CALL "MSP-INTERIOR" USING L-ROW WS-XM WS-V0 WS-Z WS-INT
                 MOVE WS-C09 TO WS-CHANCE
                 IF WS-INT = 1
                     MOVE WS-C07 TO WS-CHANCE
                 END-IF
                 MOVE 1 TO WS-RAIL
                 IF SP-ORIENT(L-ROW) = 1 OR SP-ORIENT(L-ROW) = 3
                     MOVE 2 TO WS-RAIL
                 END-IF
                 CALL "MSP-MAYBE-BLOCK" USING L-ROW WS-CHANCE WS-XM WS-V0 WS-Z SBK-S-RAIL(WS-RAIL)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM MS-POST-CORRIDOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-PLACE-RAW.
*> USING world x y z, state: sets the state (flags 2) of a cell known to be inside the write box, without the replace test.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     CALL "FL-SET-STATE" USING L-X L-Y L-Z L-STATE WS-FLAGS WS-OK
     GOBACK.
 END PROGRAM MSP-PLACE-RAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-DOUBLE.
*> placeDoubleLowerOrUpperSupport (2.7): a pillar from each of the two cells x and x + 2 that hold the planks of the piece's wood type.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 01 WS-STATE               BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     COMPUTE WS-T = SP-MST(L-ROW) + 1
     CALL "MSP-GET" USING L-ROW L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-B
     IF WS-B = SBK-PLANKS-B(WS-T)
         CALL "MSP-PILLAR" USING L-ROW SBK-LOG-S(WS-T) L-X L-Y L-Z
     END-IF
     COMPUTE WS-X2 = L-X + 2
     CALL "MSP-GET" USING L-ROW WS-X2 L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-B
     IF WS-B = SBK-PLANKS-B(WS-T)
         CALL "MSP-PILLAR" USING L-ROW SBK-LOG-S(WS-T) WS-X2 L-Y L-Z
     END-IF
     GOBACK.
 END PROGRAM MSP-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-POST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-INVALID             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MSP-INVALID" USING L-ROW WS-INVALID
     IF WS-INVALID = 1
         GOBACK
     END-IF
     EVALUATE SP-TYPE(L-ROW)
         WHEN 0
             CALL "MS-POST-CORRIDOR" USING L-ROW
         WHEN 1
             CALL "MS-POST-CROSSING" USING L-ROW
         WHEN 2
             CALL "MS-POST-ROOM" USING L-ROW
         WHEN OTHER
             CALL "MS-POST-STAIRS" USING L-ROW
     END-EVALUATE
     GOBACK.
 END PROGRAM MS-POST.
