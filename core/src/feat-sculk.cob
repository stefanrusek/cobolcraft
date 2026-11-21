*> The sculk patch (docs/protocol/35-worldgen-features-6-underground.md section 8; registry id 40, sculk_patch) and the sculk spreader it runs in world generation (8.3 to 8.6).
*> FD-SCULK-NODE compiles the configuration into a row of FD-WA: WA-I(1) the block sculk_vein (the multiface block of the vein programs of feat-multi.cob), WA-I(2) sculk, WA-I(3) charge_count,
*> WA-I(4) amount_per_charge, WA-I(5) spread_attempts, WA-I(6) growth_rounds, WA-I(7) spread_rounds, WA-I(8) sculk_sensor, WA-I(9) sculk_shrieker, WA-I(10) sculk_catalyst, WA-I(11) moving_piston;
*> the pools 1 the tag sculk_replaceable_world_gen, 2 sculk_replaceable, 3 sculk_growth_inhibitors, 4 fire. A block or tag the content set lacks makes the feature unsupported.
*> FR-SCULK places it: the cursors of FEATSCULK.cpy, the three behaviours (default, sculk, sculk_vein: FS-KIND 0, 1, 2) and the vein spreaders (FS-SPREAD-ALL with one spread type or three).
*>
*> Deviations: "has a full face / is sturdy" is the solid flag of the block (CB-SOLID), like every feature of the stage; the fluid of a cell is read from its block (water, lava) and the waterlogged
*> property of the vein only (a waterlogged slab counts as no fluid); the cells are written with flag 2; the discharge events, sounds and the entity push are not made.
*>
*> Entry points: FD-SCULK-NODE USING doc, node, row out (FD-BAD set when the feature cannot be placed whole); FR-SCULK USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-KIND.
*> USING row, state, kind out: the behaviour of the block of the state: 1 sculk, 2 sculk_vein, 0 any other (the default behaviour).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATE L-KIND.
     MOVE 0 TO L-KIND
     CALL "FL-BLOCK-OF" USING L-STATE WS-BLOCK
     EVALUATE TRUE
         WHEN WS-BLOCK = WA-I(L-ROW, 2)
             MOVE 1 TO L-KIND
         WHEN WS-BLOCK = WA-I(L-ROW, 1)
             MOVE 2 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM FS-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-MASK.
*> USING row, state, mask out (six characters by direction ordinal), waterlogged out: the faces of a sculk_vein state; "000000" and 0 for any other state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-KIND                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-OP2                 BINARY-LONG VALUE 2.
 01 WS-DUMMY               PIC X(6).
 01 WS-DUMMY-WL            BINARY-LONG.
 01 WS-DUMMY-STATE         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-MASK                 PIC X(6).
 01 L-WL                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATE L-MASK L-WL.
     MOVE "000000" TO L-MASK
     MOVE 0 TO L-WL
     CALL "FS-KIND" USING L-ROW L-STATE WS-KIND
     IF WS-KIND = 2
         MOVE WA-I(L-ROW, 1) TO WS-SLOT
         CALL "FM-TABLE" USING WS-OP1 WS-SLOT WS-DUMMY WS-DUMMY-WL WS-DUMMY-STATE
         CALL "FM-TABLE" USING WS-OP2 WS-SLOT L-MASK L-WL L-STATE
     END-IF
     GOBACK.
 END PROGRAM FS-MASK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-FLUID.
*> USING state, fluid out: 0 no fluid, 1 a water source (the default state of water), 2 another fluid (flowing water, lava). A waterlogged block counts as no fluid here.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATLEVEL.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FLUID.
     MOVE 0 TO L-FLUID
     CALL "FL-CLASS" USING L-STATE WS-CLASS
     EVALUATE WS-CLASS
         WHEN 2
             MOVE 2 TO L-FLUID
             IF L-STATE = CB-DEFAULT-STATE(FL-B-WATER)
                 MOVE 1 TO L-FLUID
             END-IF
         WHEN 3
             MOVE 2 TO L-FLUID
     END-EVALUATE
     GOBACK.
 END PROGRAM FS-FLUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-REPLACEABLE.
*> USING row, ax, ay, az (the source cell), bx, by, bz (the spread cell), face, flag out: stateCanBeReplaced (8.6): false when the cell beyond B in the direction of the face holds sculk, a
*> sculk catalyst or a moving piston; when A and B are two apart and the cell A + opposite(face) is solid; when the cell at B has a fluid that is not a water source or is a fire; else true
*> when the block can be replaced, or the cell is air, the vein block or a water source.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-F1                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-DIST                BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-O1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AX L-AY L-AZ L-BX L-BY L-BZ L-FACE L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE WS-F1 = L-FACE + 1
     COMPUTE WS-NX = L-BX + FDR-DX(WS-F1)
     COMPUTE WS-NY = L-BY + FDR-DY(WS-F1)
     COMPUTE WS-NZ = L-BZ + FDR-DZ(WS-F1)
     CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK = WA-I(L-ROW, 2) OR WS-BLOCK = WA-I(L-ROW, 10) OR WS-BLOCK = WA-I(L-ROW, 11)
         GOBACK
     END-IF
     COMPUTE WS-DIST = FUNCTION ABS(L-AX - L-BX) + FUNCTION ABS(L-AY - L-BY) + FUNCTION ABS(L-AZ - L-BZ)
     IF WS-DIST = 2
         COMPUTE WS-O1 = FDR-OPP(WS-F1) + 1
         COMPUTE WS-NX = L-AX + FDR-DX(WS-O1)
         COMPUTE WS-NY = L-AY + FDR-DY(WS-O1)
         COMPUTE WS-NZ = L-AZ + FDR-DZ(WS-O1)
         CALL "FM-SOLID" USING WS-NX WS-NY WS-NZ WS-SOLID
         IF WS-SOLID = 1
             GOBACK
         END-IF
     END-IF
     CALL "FL-GET-STATE" USING L-BX L-BY L-BZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FS-FLUID" USING WS-STATE WS-FLUID
     IF WS-FLUID = 2
         GOBACK
     END-IF
     CALL "FR-POOL-HAS" USING WA-START(L-ROW, 4) WA-N(L-ROW, 4) WS-BLOCK WS-FIRE
     IF WS-FIRE = 1
         GOBACK
     END-IF
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF CB-REPLACEABLE(WS-BLOCK) = 1 OR WS-CLASS = 1 OR WS-BLOCK = WA-I(L-ROW, 1) OR WS-FLUID = 1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM FS-REPLACEABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-SPREAD-DIR.
*> USING row, x, y, z (the cell the spread starts from), state (its state, fixed), face, dir, types (1 same position only, 3 all), placed out: spreadFromFaceTowardDirection and placeBlock
*> of the vein spreaders (8.6): nothing when the direction is on the axis of the face, or when the source is a vein that lacks the face or has the direction; else the first spread
*> type (same position, same plane, wrap around) whose cell can be spread into is the target, and the vein state for placement is written there (flag 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-AX1                 BINARY-LONG.
 01 WS-AX2                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-F1                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-TYPES                BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE L-FACE L-DIR L-TYPES L-PLACED.
     MOVE 0 TO L-PLACED
     COMPUTE WS-AX1 = L-FACE / 2
     COMPUTE WS-AX2 = L-DIR / 2
     IF WS-AX1 = WS-AX2
         GOBACK
     END-IF
     COMPUTE WS-F1 = L-FACE + 1
     COMPUTE WS-D1 = L-DIR + 1
     CALL "FS-KIND" USING L-ROW L-STATE WS-KIND
     IF WS-KIND = 2
         CALL "FS-MASK" USING L-ROW L-STATE WS-MASK WS-WL
         IF WS-MASK(WS-F1:1) = "0" OR WS-MASK(WS-D1:1) = "1"
             GOBACK
         END-IF
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > L-TYPES OR WS-DONE = 1
         EVALUATE WS-T
             WHEN 1
                 MOVE L-X TO WS-PX
                 MOVE L-Y TO WS-PY
                 MOVE L-Z TO WS-PZ
                 MOVE L-DIR TO WS-PF
             WHEN 2
                 COMPUTE WS-PX = L-X + FDR-DX(WS-D1)
                 COMPUTE WS-PY = L-Y + FDR-DY(WS-D1)
                 COMPUTE WS-PZ = L-Z + FDR-DZ(WS-D1)
                 MOVE L-FACE TO WS-PF
             WHEN OTHER
                 COMPUTE WS-PX = L-X + FDR-DX(WS-D1) + FDR-DX(WS-F1)
                 COMPUTE WS-PY = L-Y + FDR-DY(WS-D1) + FDR-DY(WS-F1)
                 COMPUTE WS-PZ = L-Z + FDR-DZ(WS-D1) + FDR-DZ(WS-F1)
                 MOVE FDR-OPP(WS-D1) TO WS-PF
         END-EVALUATE
         CALL "FS-REPLACEABLE" USING L-ROW L-X L-Y L-Z WS-PX WS-PY WS-PZ WS-PF WS-CAN
         IF WS-CAN = 1
             CALL "FM-VALID" USING L-ROW WS-PX WS-PY WS-PZ WS-PF WS-CAN
         END-IF
         IF WS-CAN = 1
             MOVE 1 TO WS-DONE
             CALL "FM-PLACE-STATE" USING L-ROW WS-PX WS-PY WS-PZ WS-PF WS-NEW WS-OK
             IF WS-OK = 1
                 CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-NEW WS-FLAGS WS-WRITTEN
                 MOVE 1 TO L-PLACED
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FS-SPREAD-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-SPREAD-ALL.
*> USING row, x, y, z, state (the source's state, fixed for the call), types (1 or 3), count out: spreadAll (8.6): for each face of the six (in order) the source can spread from (a source that is
*> not a vein, or a vein with that face), every direction of the six is tried; count is the number of blocks written.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-F1                  BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-TYPES                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE L-TYPES L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "FS-KIND" USING L-ROW L-STATE WS-KIND
     CALL "FS-MASK" USING L-ROW L-STATE WS-MASK WS-WL
     PERFORM VARYING WS-FACE FROM 0 BY 1 UNTIL WS-FACE > 5
         COMPUTE WS-F1 = WS-FACE + 1
         IF WS-KIND NOT = 2 OR WS-MASK(WS-F1:1) = "1"
             PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 5
                 CALL "FS-SPREAD-DIR" USING L-ROW L-X L-Y L-Z L-STATE WS-FACE WS-DIR L-TYPES WS-PLACED
                 ADD WS-PLACED TO L-COUNT
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FS-SPREAD-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-DISCHARGE.
*> USING row, x, y, z, state: SculkVeinBlock.onDischarged (8.5) for a vein state (nothing for any other): every face of the state whose neighbour is sculk is cleared; a vein with no face left
*> becomes air, or water when it was waterlogged; the result is written (flag 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY FEATDIR.
 COPY FEATLEVEL.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-OP3                 BINARY-LONG VALUE 3.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE.
     CALL "FS-KIND" USING L-ROW L-STATE WS-KIND
     IF WS-KIND NOT = 2
         GOBACK
     END-IF
     CALL "FS-MASK" USING L-ROW L-STATE WS-MASK WS-WL
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
         COMPUTE WS-D1 = WS-D + 1
         IF WS-MASK(WS-D1:1) = "1"
             COMPUTE WS-NX = L-X + FDR-DX(WS-D1)
             COMPUTE WS-NY = L-Y + FDR-DY(WS-D1)
             COMPUTE WS-NZ = L-Z + FDR-DZ(WS-D1)
             CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF WS-BLOCK = WA-I(L-ROW, 2)
                 MOVE "0" TO WS-MASK(WS-D1:1)
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-D1 FROM 1 BY 1 UNTIL WS-D1 > 6
         IF WS-MASK(WS-D1:1) = "1"
             MOVE 1 TO WS-ANY
         END-IF
     END-PERFORM
     IF WS-ANY = 1
         MOVE WA-I(L-ROW, 1) TO WS-SLOT
         CALL "FM-TABLE" USING WS-OP1 WS-SLOT WS-MASK WS-WL WS-NEW
         CALL "FM-TABLE" USING WS-OP3 WS-SLOT WS-MASK WS-WL WS-NEW
     ELSE
         IF WS-WL = 1
             MOVE CB-DEFAULT-STATE(FL-B-WATER) TO WS-NEW
         ELSE
             MOVE FL-S-AIR TO WS-NEW
         END-IF
     END-IF
     CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-NEW WS-FLAGS WS-WRITTEN
     GOBACK.
 END PROGRAM FS-DISCHARGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-REGROW.
*> USING row, x, y, z, facings (six characters), ok out: SculkVeinBlock.regrow (8.5): a vein state with each of the facings whose neighbour is solid (canAttachTo), waterlogged when the cell holds
*> water; false (ok 0) when none could be set. The state is written (flag 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-MASK                PIC X(6).
 01 WS-D1                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-WL                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-OP3                 BINARY-LONG VALUE 3.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACINGS              PIC X(6).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FACINGS L-OK.
     MOVE 0 TO L-OK WS-ANY
     MOVE "000000" TO WS-MASK
     PERFORM VARYING WS-D1 FROM 1 BY 1 UNTIL WS-D1 > 6
         IF L-FACINGS(WS-D1:1) = "1"
             COMPUTE WS-NX = L-X + FDR-DX(WS-D1)
             COMPUTE WS-NY = L-Y + FDR-DY(WS-D1)
             COMPUTE WS-NZ = L-Z + FDR-DZ(WS-D1)
             CALL "FM-SOLID" USING WS-NX WS-NY WS-NZ WS-SOLID
             IF WS-SOLID = 1
                 MOVE "1" TO WS-MASK(WS-D1:1)
                 MOVE 1 TO WS-ANY
             END-IF
         END-IF
     END-PERFORM
     IF WS-ANY = 0
         GOBACK
     END-IF
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     MOVE 0 TO WS-WL
     IF WS-CLASS = 2
         MOVE 1 TO WS-WL
     END-IF
     MOVE WA-I(L-ROW, 1) TO WS-SLOT
     CALL "FM-TABLE" USING WS-OP1 WS-SLOT WS-MASK WS-WL WS-NEW
     CALL "FM-TABLE" USING WS-OP3 WS-SLOT WS-MASK WS-WL WS-NEW
     CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-NEW WS-FLAGS WS-WRITTEN
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM FS-REGROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-ATTACH.
*> USING state, row, x, y, z, ok out: SculkVeinBlock.attemptPlaceSculk (8.5): the six directions shuffled; for the first one the vein at the cell has a face of, whose neighbour is in
*> sculk_replaceable_world_gen: sculk is written there, the vein spreader runs from it, and every vein around it (not the one it came from) is discharged; ok 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-LIST.
    05 WS-E                BINARY-LONG OCCURS 6 TIMES.
 01 WS-N                   BINARY-LONG VALUE 6.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-SCULK               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TYPES               BINARY-LONG VALUE 3.
 01 WS-KIND                BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK WS-DONE
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FS-MASK" USING L-ROW WS-STATE WS-MASK WS-WL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-E(WS-I) = WS-I - 1
     END-PERFORM
     CALL "FM-SHUFFLE" USING L-STATE WS-LIST WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-DONE = 1
         MOVE WS-E(WS-I) TO WS-D
         COMPUTE WS-D1 = WS-D + 1
         IF WS-MASK(WS-D1:1) = "1"
             COMPUTE WS-PX = L-X + FDR-DX(WS-D1)
             COMPUTE WS-PY = L-Y + FDR-DY(WS-D1)
             COMPUTE WS-PZ = L-Z + FDR-DZ(WS-D1)
             CALL "FL-GET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-BLOCK WS-IN
             IF WS-IN = 1
                 MOVE 1 TO WS-DONE
                 MOVE CB-DEFAULT-STATE(WA-I(L-ROW, 2)) TO WS-SCULK
                 CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-SCULK WS-FLAGS WS-WRITTEN
                 CALL "FS-SPREAD-ALL" USING L-ROW WS-PX WS-PY WS-PZ WS-SCULK WS-TYPES WS-COUNT
                 MOVE FDR-OPP(WS-D1) TO WS-OPP
                 PERFORM VARYING WS-D2 FROM 0 BY 1 UNTIL WS-D2 > 5
                     IF WS-D2 NOT = WS-OPP
                         COMPUTE WS-D1 = WS-D2 + 1
                         COMPUTE WS-QX = WS-PX + FDR-DX(WS-D1)
                         COMPUTE WS-QY = WS-PY + FDR-DY(WS-D1)
                         COMPUTE WS-QZ = WS-PZ + FDR-DZ(WS-D1)
                         CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                         CALL "FS-KIND" USING L-ROW WS-STATE WS-KIND
                         IF WS-KIND = 2
                             CALL "FS-DISCHARGE" USING L-ROW WS-QX WS-QY WS-QZ WS-STATE
                         END-IF
                     END-IF
                 END-PERFORM
                 MOVE 1 TO L-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FS-ATTACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-SHUFFLE18.
*> USING state, list (eighteen integers), count: Util.shuffle (nextInt(i) for i = count down to 2, swap i - 1 and the drawn index).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-LIST.
    05 L-E                 BINARY-LONG OCCURS 18 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-LIST L-COUNT.
     PERFORM VARYING WS-I FROM L-COUNT BY -1 UNTIL WS-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-I WS-J
         COMPUTE WS-K = WS-J + 1
         MOVE L-E(WS-K) TO WS-T
         MOVE L-E(WS-I) TO L-E(WS-K)
         MOVE WS-T TO L-E(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM FS-SHUFFLE18.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-UNOBSTRUCTED.
*> USING ax, ay, az, bx, by, bz, flag out: isMovementUnobstructed (8.4): true for neighbours; else, with dX, dY, dZ the directions toward B on each axis, the cell next to A in one of two
*> of those directions (the two that are not the axis in which B equals A, the first of x, y that is) must not be solid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDIR.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DIST                BINARY-LONG.
 01 WS-DA                  BINARY-LONG.
 01 WS-DB                  BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-DIRX                BINARY-LONG.
 01 WS-DIRY                BINARY-LONG.
 01 WS-DIRZ                BINARY-LONG.
 LINKAGE SECTION.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AX L-AY L-AZ L-BX L-BY L-BZ L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE WS-DX = L-BX - L-AX
     COMPUTE WS-DY = L-BY - L-AY
     COMPUTE WS-DZ = L-BZ - L-AZ
     COMPUTE WS-DIST = FUNCTION ABS(WS-DX) + FUNCTION ABS(WS-DY) + FUNCTION ABS(WS-DZ)
     IF WS-DIST = 1
         MOVE 1 TO L-FLAG
         GOBACK
     END-IF
     MOVE 5 TO WS-DIRX
     IF WS-DX < 0
         MOVE 4 TO WS-DIRX
     END-IF
     MOVE 1 TO WS-DIRY
     IF WS-DY < 0
         MOVE 0 TO WS-DIRY
     END-IF
     MOVE 3 TO WS-DIRZ
     IF WS-DZ < 0
         MOVE 2 TO WS-DIRZ
     END-IF
     EVALUATE TRUE
         WHEN WS-DX = 0
             MOVE WS-DIRY TO WS-DA
             MOVE WS-DIRZ TO WS-DB
         WHEN WS-DY = 0
             MOVE WS-DIRX TO WS-DA
             MOVE WS-DIRZ TO WS-DB
         WHEN OTHER
             MOVE WS-DIRX TO WS-DA
             MOVE WS-DIRY TO WS-DB
     END-EVALUATE
     COMPUTE WS-D1 = WS-DA + 1
     COMPUTE WS-NX = L-AX + FDR-DX(WS-D1)
     COMPUTE WS-NY = L-AY + FDR-DY(WS-D1)
     COMPUTE WS-NZ = L-AZ + FDR-DZ(WS-D1)
     CALL "FM-SOLID" USING WS-NX WS-NY WS-NZ WS-SOLID
     IF WS-SOLID = 0
         MOVE 1 TO L-FLAG
     END-IF
     COMPUTE WS-D1 = WS-DB + 1
     COMPUTE WS-NX = L-AX + FDR-DX(WS-D1)
     COMPUTE WS-NY = L-AY + FDR-DY(WS-D1)
     COMPUTE WS-NZ = L-AZ + FDR-DZ(WS-D1)
     CALL "FM-SOLID" USING WS-NX WS-NY WS-NZ WS-SOLID
     IF WS-SOLID = 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM FS-UNOBSTRUCTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-SUBSTRATE.
*> USING row, x, y, z, state, flag out: SculkVeinBlock.hasSubstrateAccess (8.4): the state is a vein with a face whose neighbour block is in the tag sculk_replaceable.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-KIND                BINARY-LONG.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "FS-KIND" USING L-ROW L-STATE WS-KIND
     IF WS-KIND = 2
         CALL "FS-MASK" USING L-ROW L-STATE WS-MASK WS-WL
         PERFORM VARYING WS-D1 FROM 1 BY 1 UNTIL WS-D1 > 6 OR L-FLAG = 1
             IF WS-MASK(WS-D1:1) = "1"
                 COMPUTE WS-NX = L-X + FDR-DX(WS-D1)
                 COMPUTE WS-NY = L-Y + FDR-DY(WS-D1)
                 COMPUTE WS-NZ = L-Z + FDR-DZ(WS-D1)
                 CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 CALL "FR-POOL-HAS" USING WA-START(L-ROW, 2) WA-N(L-ROW, 2) WS-BLOCK WS-IN
                 IF WS-IN = 1
                     MOVE 1 TO L-FLAG
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FS-SUBSTRATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-MOVE.
*> USING state, row, ox, oy, oz (the origin), x, y, z (the cursor), nx, ny, nz (out), found out: getValidMovementPos (8.4): the eighteen neighbours without a corner shuffled; a cell within 12
*> blocks of the origin (x and z) that holds sculk or a vein and is reached without a solid cell in the way becomes the result, and the search ends at the first vein with substrate access;
*> found 0 when the result is the cursor's own cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-OFFS.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 1.
 01 WS-OFF-T REDEFINES WS-OFFS.
    05 WS-OFF OCCURS 18 TIMES.
       10 WS-OX            BINARY-LONG.
       10 WS-OY            BINARY-LONG.
       10 WS-OZ            BINARY-LONG.
 01 WS-LIST.
    05 WS-E                BINARY-LONG OCCURS 18 TIMES.
 01 WS-N                   BINARY-LONG VALUE 18.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-NX                   BINARY-LONG.
 01 L-NY                   BINARY-LONG.
 01 L-NZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-OX L-OY L-OZ L-X L-Y L-Z L-NX L-NY L-NZ L-FOUND.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE WS-I TO WS-E(WS-I)
     END-PERFORM
     CALL "FS-SHUFFLE18" USING L-STATE WS-LIST WS-N
     MOVE L-X TO L-NX
     MOVE L-Y TO L-NY
     MOVE L-Z TO L-NZ
     MOVE 0 TO WS-STOP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18 OR WS-STOP = 1
         MOVE WS-E(WS-I) TO WS-K
         COMPUTE WS-CX = L-X + WS-OX(WS-K)
         COMPUTE WS-CY = L-Y + WS-OY(WS-K)
         COMPUTE WS-CZ = L-Z + WS-OZ(WS-K)
         COMPUTE WS-DX = WS-CX - L-OX
         COMPUTE WS-DZ = WS-CZ - L-OZ
         IF WS-DX * WS-DX + WS-DZ * WS-DZ <= 144
             CALL "FL-GET-STATE" USING WS-CX WS-CY WS-CZ WS-STATE
             CALL "FS-KIND" USING L-ROW WS-STATE WS-KIND
             IF WS-KIND > 0
                 CALL "FS-UNOBSTRUCTED" USING L-X L-Y L-Z WS-CX WS-CY WS-CZ WS-FREE
                 IF WS-FREE = 1
                     MOVE WS-CX TO L-NX
                     MOVE WS-CY TO L-NY
                     MOVE WS-CZ TO L-NZ
                     CALL "FS-SUBSTRATE" USING L-ROW WS-CX WS-CY WS-CZ WS-STATE WS-SUB
                     IF WS-SUB = 1
                         MOVE 1 TO WS-STOP
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO L-FOUND
     IF L-NX = L-X AND L-NY = L-Y AND L-NZ = L-Z
         MOVE 0 TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM FS-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-CHARGE-SCULK.
*> USING state, row, cursor index, ox, oy, oz (the origin), charge out: SculkBlock.attemptUseCharge (8.5) with the world generation spreader (growth cost 50, decay rates 5 and 10, no growth
*> radius 1). The draws: nextInt(5) (not for a charge of 0); then nextInt(10) when the cursor is on the origin or the cell above cannot take growth, else nextInt(50) and, when it is under the
*> charge, nextInt(11) for a shrieker (1 in 11, can_summon true) or a sensor, written above (waterlogged in water).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY FEATSCULK.
 01 WS-C                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-B10                 BINARY-LONG VALUE 10.
 01 WS-B11                 BINARY-LONG VALUE 11.
 01 WS-B50                 BINARY-LONG VALUE 50.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-ABOVE-CLASS         BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-INH                 BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-DS                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-PEN                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-NAME-SUMMON         PIC X(40) VALUE "can_summon".
 01 WS-NAME-WATER          PIC X(40) VALUE "waterlogged".
 01 WS-TRUE                PIC X(40) VALUE "true".
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-CHARGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-IDX L-OX L-OY L-OZ L-CHARGE.
     MOVE SC-CHARGE(L-IDX) TO WS-C
     MOVE WS-C TO L-CHARGE
*>   the draw happens only for a charge that is not 0 (a cursor in the list always has one); without the draw the charge is returned unchanged
     MOVE 1 TO WS-DRAW
     IF WS-C NOT = 0
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-DRAW
     END-IF
     IF WS-DRAW NOT = 0
         GOBACK
     END-IF
     MOVE SC-X(L-IDX) TO WS-X
     MOVE SC-Y(L-IDX) TO WS-Y
     MOVE SC-Z(L-IDX) TO WS-Z
     MOVE 0 TO WS-NEAR
     IF WS-X = L-OX AND WS-Y = L-OY AND WS-Z = L-OZ
         MOVE 1 TO WS-NEAR
     END-IF
*>   canPlaceGrowth: the cell above is air or a water source, and at most two inhibitors in the box of 9 x 3 x 9
     MOVE 0 TO WS-CAN
     COMPUTE WS-AY = WS-Y + 1
     CALL "FL-GET-STATE" USING WS-X WS-AY WS-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-ABOVE-CLASS
     CALL "FS-FLUID" USING WS-STATE WS-FLUID
     IF WS-ABOVE-CLASS = 1 OR WS-FLUID = 1
         MOVE 0 TO WS-INH
         PERFORM VARYING WS-BX FROM -4 BY 1 UNTIL WS-BX > 4
             PERFORM VARYING WS-BY FROM 0 BY 1 UNTIL WS-BY > 2
                 PERFORM VARYING WS-BZ FROM -4 BY 1 UNTIL WS-BZ > 4
                     COMPUTE WS-QX = WS-X + WS-BX
                     COMPUTE WS-QY = WS-Y + WS-BY
                     COMPUTE WS-QZ = WS-Z + WS-BZ
                     CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     CALL "FR-POOL-HAS" USING WA-START(L-ROW, 3) WA-N(L-ROW, 3) WS-BLOCK WS-IN
                     ADD WS-IN TO WS-INH
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         IF WS-INH <= 2
             MOVE 1 TO WS-CAN
         END-IF
     END-IF
     IF WS-NEAR = 1 OR WS-CAN = 0
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B10 WS-DRAW
         IF WS-DRAW NOT = 0
             GOBACK
         END-IF
         IF WS-NEAR = 1
             COMPUTE L-CHARGE = WS-C - 1
             GOBACK
         END-IF
*>       decayPenalty with the float arithmetic of the document: t = (sqrt(distSqr) - 1) squared, m = 23 squared, f = min(1, t / m), max(1, (int)(c * f * 0.5))
         COMPUTE WS-DS = (L-OX - WS-X) * (L-OX - WS-X) + (L-OY - WS-Y) * (L-OY - WS-Y) + (L-OZ - WS-Z) * (L-OZ - WS-Z)
         COMPUTE WS-F = FUNCTION SQRT(WS-DS)
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F WS-A
         COMPUTE WS-F = WS-A - 1
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F WS-A
         COMPUTE WS-F = WS-A * WS-A
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F WS-T
         COMPUTE WS-F = WS-T / 529
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F WS-Q
         COMPUTE WS-Q = FUNCTION MIN(WS-Q, WS-ONE)
         COMPUTE WS-F = WS-C * WS-Q
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F WS-R
         COMPUTE WS-PEN = WS-R * 0.5
         IF WS-PEN < 1
             MOVE 1 TO WS-PEN
         END-IF
         COMPUTE L-CHARGE = WS-C - WS-PEN
         GOBACK
     END-IF
*>   growth
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B50 WS-DRAW
     IF WS-DRAW < WS-C
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B11 WS-DRAW
         IF WS-DRAW = 0
             MOVE CB-DEFAULT-STATE(WA-I(L-ROW, 9)) TO WS-NEW
             CALL "FD-STATE-SET" USING WS-NEW WS-NAME-SUMMON WS-TRUE WS-SET WS-FOUND
             MOVE WS-SET TO WS-NEW
         ELSE
             MOVE CB-DEFAULT-STATE(WA-I(L-ROW, 8)) TO WS-NEW
         END-IF
         IF WS-ABOVE-CLASS = 2
             CALL "FD-STATE-SET" USING WS-NEW WS-NAME-WATER WS-TRUE WS-SET WS-FOUND
             MOVE WS-SET TO WS-NEW
         END-IF
         CALL "FL-SET-STATE" USING WS-X WS-AY WS-Z WS-NEW WS-FLAGS WS-WRITTEN
     END-IF
     COMPUTE L-CHARGE = WS-C - 50
     IF L-CHARGE < 0
         MOVE 0 TO L-CHARGE
     END-IF
     GOBACK.
 END PROGRAM FS-CHARGE-SCULK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-UPDATE.
*> USING state, row, cursor index, ox, oy, oz (the origin), spread flag: ChargeCursor.update (8.4): nothing for a spent cursor; a delay counts down; the behaviour of the block under the cursor
*> (default, sculk, vein) tries to spread veins (spread flag only; a block that may change then is read again), uses charge, and the cursor moves to a valid cell (or dies in world generation); the
*> facings, the decay delay and the update delay (1) are set from the behaviour of step 4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATSCULK.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TYPES               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-IDX L-OX L-OY L-OZ L-FLAG.
*>   step 1 (a cursor with no charge does nothing) is the caller's: the list holds only cursors with charge
     IF SC-UPD(L-IDX) > 0
         SUBTRACT 1 FROM SC-UPD(L-IDX)
         GOBACK
     END-IF
     MOVE SC-X(L-IDX) TO WS-X
     MOVE SC-Y(L-IDX) TO WS-Y
     MOVE SC-Z(L-IDX) TO WS-Z
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "FS-KIND" USING L-ROW WS-STATE WS-KIND
*>   step 4: the spread of veins, with the behaviour's own rule for the facings
     IF L-FLAG = 1
         MOVE 0 TO WS-SPREAD
         EVALUATE TRUE
             WHEN WS-KIND = 0 AND SC-HASF(L-IDX) = 0
                 MOVE 1 TO WS-TYPES
                 CALL "FS-SPREAD-ALL" USING L-ROW WS-X WS-Y WS-Z WS-STATE WS-TYPES WS-COUNT
                 IF WS-COUNT > 0
                     MOVE 1 TO WS-SPREAD
                 END-IF
             WHEN WS-KIND = 0 AND SC-FACES(L-IDX) NOT = "000000"
                 CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 CALL "FS-FLUID" USING WS-STATE WS-FLUID
                 IF WS-CLASS = 1 OR WS-FLUID = 1
                     CALL "FS-REGROW" USING L-ROW WS-X WS-Y WS-Z SC-FACES(L-IDX) WS-OK
                     MOVE WS-OK TO WS-SPREAD
                 END-IF
             WHEN OTHER
                 MOVE 3 TO WS-TYPES
                 CALL "FS-SPREAD-ALL" USING L-ROW WS-X WS-Y WS-Z WS-STATE WS-TYPES WS-COUNT
                 IF WS-COUNT > 0
                     MOVE 1 TO WS-SPREAD
                 END-IF
         END-EVALUATE
         IF WS-SPREAD = 1 AND WS-KIND NOT = 1
             CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
             CALL "FS-KIND" USING L-ROW WS-STATE WS-KIND
         END-IF
     END-IF
*>   step 5: the charge of the behaviour
     EVALUATE WS-KIND
         WHEN 0
             MOVE 0 TO WS-CHARGE
             IF SC-DECAY(L-IDX) > 0
                 MOVE SC-CHARGE(L-IDX) TO WS-CHARGE
             END-IF
         WHEN 1
             CALL "FS-CHARGE-SCULK" USING L-STATE L-ROW L-IDX L-OX L-OY L-OZ WS-CHARGE
         WHEN OTHER
             MOVE 0 TO WS-OK
             IF L-FLAG = 1
                 CALL "FS-ATTACH" USING L-STATE L-ROW WS-X WS-Y WS-Z WS-OK
             END-IF
             IF WS-OK = 1
                 COMPUTE WS-CHARGE = SC-CHARGE(L-IDX) - 1
             ELSE
                 MOVE SC-CHARGE(L-IDX) TO WS-CHARGE
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-DRAW
                 IF WS-DRAW = 0
                     COMPUTE WS-CHARGE = SC-CHARGE(L-IDX) / 2
                 END-IF
             END-IF
     END-EVALUATE
     MOVE WS-CHARGE TO SC-CHARGE(L-IDX)
*>   step 6: spent
     IF WS-CHARGE <= 0
         CALL "FS-DISCHARGE" USING L-ROW WS-X WS-Y WS-Z WS-STATE
         GOBACK
     END-IF
*>   step 7: a valid cell to move to, or the end of the cursor in world generation
     CALL "FS-MOVE" USING L-STATE L-ROW L-OX L-OY L-OZ WS-X WS-Y WS-Z WS-NX WS-NY WS-NZ WS-FOUND
     CALL "FS-DISCHARGE" USING L-ROW WS-X WS-Y WS-Z WS-STATE
     IF WS-FOUND = 0
         MOVE 0 TO SC-CHARGE(L-IDX)
         GOBACK
     END-IF
     MOVE WS-NX TO SC-X(L-IDX)
     MOVE WS-NY TO SC-Y(L-IDX)
     MOVE WS-NZ TO SC-Z(L-IDX)
     CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
*>   step 8: the facings of the block now under the cursor, when it is a sculk behaviour block
     CALL "FS-KIND" USING L-ROW WS-STATE WS-OK
     IF WS-OK > 0
         CALL "FS-MASK" USING L-ROW WS-STATE WS-MASK WS-WL
         MOVE 1 TO SC-HASF(L-IDX)
         MOVE WS-MASK TO SC-FACES(L-IDX)
     END-IF
*>   step 9: the delays of the step 4 behaviour
     IF WS-KIND = 0
         IF SC-DECAY(L-IDX) > 0
             SUBTRACT 1 FROM SC-DECAY(L-IDX)
         END-IF
     ELSE
         MOVE 1 TO SC-DECAY(L-IDX)
     END-IF
     MOVE 1 TO SC-UPD(L-IDX)
     GOBACK.
 END PROGRAM FS-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FS-UPDATE-ALL.
*> USING state, row, ox, oy, oz, spread flag: SculkSpreader.updateCursors (8.3): the cursors in list order; one more than 1024 blocks from the origin is dropped without an update; a cursor with
*> no charge left after its update is dropped; the others keep their order (no merging in world generation).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATSCULK.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CHEB                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-OX L-OY L-OZ L-FLAG.
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SC-N
         COMPUTE WS-DX = FUNCTION ABS(SC-X(WS-I) - L-OX)
         COMPUTE WS-DY = FUNCTION ABS(SC-Y(WS-I) - L-OY)
         COMPUTE WS-DZ = FUNCTION ABS(SC-Z(WS-I) - L-OZ)
         COMPUTE WS-CHEB = FUNCTION MAX(WS-DX, WS-DY, WS-DZ)
         IF WS-CHEB <= 1024 AND SC-CHARGE(WS-I) > 0
             CALL "FS-UPDATE" USING L-STATE L-ROW WS-I L-OX L-OY L-OZ L-FLAG
             IF SC-CHARGE(WS-I) > 0
                 ADD 1 TO WS-J
                 MOVE SC-CUR(WS-I) TO SC-CUR(WS-J)
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-J TO SC-N
     GOBACK.
 END PROGRAM FS-UPDATE-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-SCULK.
*> USING state, feature, x, y, z, result out (1 when the patch was run): 8.2. The origin must hold sculk or a vein, or be air or a water source next to a solid block; then for each round
*> (spread_rounds + growth_rounds) charge_count cursors of amount_per_charge are added (at most 32), the cursors are updated spread_attempts times (with the spread flag in the first
*> spread_rounds rounds) and cleared.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 COPY FEATSCULK.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-ROUNDS              BINARY-LONG.
 01 WS-ROUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-REMAIN              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FS-KIND" USING WS-ROW WS-STATE WS-KIND
     MOVE 0 TO WS-CAN
     IF WS-KIND > 0
         MOVE 1 TO WS-CAN
     ELSE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         CALL "FS-FLUID" USING WS-STATE WS-FLUID
         IF WS-CLASS = 1 OR WS-FLUID = 1
             PERFORM VARYING WS-D1 FROM 1 BY 1 UNTIL WS-D1 > 6 OR WS-CAN = 1
                 COMPUTE WS-NX = L-X + FDR-DX(WS-D1)
                 COMPUTE WS-NY = L-Y + FDR-DY(WS-D1)
                 COMPUTE WS-NZ = L-Z + FDR-DZ(WS-D1)
                 CALL "FM-SOLID" USING WS-NX WS-NY WS-NZ WS-SOLID
                 IF WS-SOLID = 1
                     MOVE 1 TO WS-CAN
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     IF WS-CAN = 0
         GOBACK
     END-IF
     COMPUTE WS-ROUNDS = WA-I(WS-ROW, 7) + WA-I(WS-ROW, 6)
     PERFORM VARYING WS-ROUND FROM 0 BY 1 UNTIL WS-ROUND >= WS-ROUNDS
         MOVE 0 TO SC-N
         PERFORM WA-I(WS-ROW, 3) TIMES
             MOVE WA-I(WS-ROW, 4) TO WS-REMAIN
             PERFORM UNTIL WS-REMAIN <= 0
                 IF SC-N < SC-MAX
                     ADD 1 TO SC-N
                     MOVE L-X TO SC-X(SC-N)
                     MOVE L-Y TO SC-Y(SC-N)
                     MOVE L-Z TO SC-Z(SC-N)
                     COMPUTE SC-CHARGE(SC-N) = FUNCTION MIN(1000, WS-REMAIN)
                     MOVE 0 TO SC-UPD(SC-N) SC-HASF(SC-N)
                     MOVE 1 TO SC-DECAY(SC-N)
                     MOVE "000000" TO SC-FACES(SC-N)
                 END-IF
                 SUBTRACT 1000 FROM WS-REMAIN
             END-PERFORM
         END-PERFORM
         MOVE 0 TO WS-FLAG
         IF WS-ROUND < WA-I(WS-ROW, 7)
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM WA-I(WS-ROW, 5) TIMES
             CALL "FS-UPDATE-ALL" USING L-STATE WS-ROW L-X L-Y L-Z WS-FLAG
         END-PERFORM
         MOVE 0 TO SC-N
     END-PERFORM
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-SCULK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-SCULK-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-TAG                 PIC X(112).
 01 WS-BLOCKS.
    05 FILLER PIC X(48) VALUE "minecraft:sculk_vein".
    05 FILLER PIC X(48) VALUE "minecraft:sculk".
    05 FILLER PIC X(48) VALUE "minecraft:sculk_sensor".
    05 FILLER PIC X(48) VALUE "minecraft:sculk_shrieker".
    05 FILLER PIC X(48) VALUE "minecraft:sculk_catalyst".
    05 FILLER PIC X(48) VALUE "minecraft:moving_piston".
 01 WS-BLOCK-T REDEFINES WS-BLOCKS.
    05 WS-BLOCK-KEY        PIC X(48) OCCURS 6 TIMES.
*> the slot of WA-I that holds each block above: 1, 2, 8, 9, 10, 11
 01 WS-SLOTS.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 11.
 01 WS-SLOT-T REDEFINES WS-SLOTS.
    05 WS-SLOT             BINARY-LONG OCCURS 6 TIMES.
 01 WS-TAGS.
    05 FILLER PIC X(112) VALUE "minecraft:sculk_replaceable_world_gen".
    05 FILLER PIC X(112) VALUE "minecraft:sculk_replaceable".
    05 FILLER PIC X(112) VALUE "minecraft:sculk_growth_inhibitors".
    05 FILLER PIC X(112) VALUE "minecraft:fire".
 01 WS-TAG-T REDEFINES WS-TAGS.
    05 WS-TAG-KEY          PIC X(112) OCCURS 4 TIMES.
 01 WS-INTS.
    05 FILLER PIC X(40) VALUE "charge_count".
    05 FILLER PIC X(40) VALUE "amount_per_charge".
    05 FILLER PIC X(40) VALUE "spread_attempts".
    05 FILLER PIC X(40) VALUE "growth_rounds".
    05 FILLER PIC X(40) VALUE "spread_rounds".
 01 WS-INT-T REDEFINES WS-INTS.
    05 WS-INT-KEY          PIC X(40) OCCURS 5 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
*>   the six blocks and the four tags
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-BLOCK-KEY(WS-I) TO WS-KEY48
         MOVE WS-SLOT(WS-I) TO WS-S
         CALL "FD-BLOCK-INDEX" USING WS-KEY48 WA-I(WS-ROW, WS-S)
         IF WA-I(WS-ROW, WS-S) = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-TAG-KEY(WS-I) TO WS-TAG
         COMPUTE WA-START(WS-ROW, WS-I) = FD-POOL-COUNT + 1
         CALL "FD-TAG-BLOCKS" USING WS-TAG WA-N(WS-ROW, WS-I)
     END-PERFORM
*>   the five integers go to WA-I 3 to 7 in the order of the document's field list
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-INT-KEY(WS-I) WS-E
         COMPUTE WS-S = WS-I + 2
         CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, WS-S) WS-OK
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FD-SCULK-NODE.
