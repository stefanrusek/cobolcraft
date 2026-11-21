*> Fungi, moss and weathering copper (docs/protocol/29b part 5, sections 1 to 4) as programs of plain numbers (GC5- prefix): the decisions of each section take the
*> facts the caller read from the level (flags, light values, the random draws) and return the decision, as the part 1 and part 3 helpers do. Like those they are helpers:
*> nothing here is wired into the block-update hooks. Directions of the six-face blocks are numbered 1 north, 2 east, 3 south, 4 west, 5 up, 6 down.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-MUSH-SURVIVE.
*> USING the state below is in tag overrides_mushroom_light_requirement, the raw brightness at the position (darken 0), the block below is a full opaque cube (BINARY-LONG),
*> mayPlaceOn, canSurvive out (1.1): the override tag survives at any light; else light below 13 and a solid support.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OVERRIDE             BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-MAYPLACE             BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-OVERRIDE L-LIGHT L-SOLID L-MAYPLACE L-SURVIVE.
     MOVE L-SOLID TO L-MAYPLACE
     MOVE 0 TO L-SURVIVE
     IF L-OVERRIDE = 1
         MOVE 1 TO L-SURVIVE
     END-IF
     IF L-OVERRIDE = 0 AND L-LIGHT < 13 AND L-SOLID = 1
         MOVE 1 TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM GC5-MUSH-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-MUSH-GATE.
*> USING the draw nextInt(25), the count of this block in the box (x - 4, y - 1, z - 4) to (x + 4, y + 1, z + 4) including itself (BINARY-LONG), the gate passed, spread
*> allowed, the draws made out (1.2 steps 1 and 2): spread needs a draw of 0 and a count of at most 4; the whole tick then makes 1 + 4 + 16 = 21 draws.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-PASSED               BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-COUNT L-PASSED L-ALLOWED L-DRAWS.
     MOVE 0 TO L-PASSED L-ALLOWED
     MOVE 1 TO L-DRAWS
     IF L-DRAW = 0
         MOVE 1 TO L-PASSED
     END-IF
     IF L-PASSED = 1 AND L-COUNT <= 4
         MOVE 1 TO L-ALLOWED
         MOVE 21 TO L-DRAWS
     END-IF
     GOBACK.
 END PROGRAM GC5-MUSH-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-MUSH-OFFSET.
*> USING the four draws nextInt(3), nextInt(2), nextInt(2), nextInt(3) in that order (BINARY-LONG), dx, dy, dz out (1.2 step 3): dx = a - 1, dy = b - c, dz = d - 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-C L-D L-DX L-DY L-DZ.
     COMPUTE L-DX = L-A - 1
     COMPUTE L-DY = L-B - L-C
     COMPUTE L-DZ = L-D - 1
     GOBACK.
 END PROGRAM GC5-MUSH-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-MUSH-TARGET.
*> USING the target is air, the mushroom state can survive there (BINARY-LONG), ok out (1.2 steps 4 and 5): the walking position moves in the loop, and the final place
*> happens, only when both hold.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-SURVIVES L-OK.
     MOVE 0 TO L-OK
     IF L-EMPTY = 1 AND L-SURVIVES = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM GC5-MUSH-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-BONE-SUCCESS.
*> USING the draw nextFloat() widened to double (FLOAT-LONG), success out (1.3, 3.1): success when the double value is below 0.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-SUCCESS.
     MOVE 0 TO L-SUCCESS
     IF L-DRAW < 0.4
         MOVE 1 TO L-SUCCESS
     END-IF
     GOBACK.
 END PROGRAM GC5-BONE-SUCCESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-MUSH-BONE.
*> USING server level, the feature exists, it is a huge mushroom feature, the y of the position, the foliageRadius, the minimum and maximum build height (BINARY-LONG; the
*> maximum is exclusive), valid out (1.3): valid needs pos.above(4 + foliageRadius) inside the build height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-EXISTS               BINARY-LONG.
 01 L-HUGE                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-MINY                 BINARY-LONG.
 01 L-MAXY                 BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-EXISTS L-HUGE L-Y L-RADIUS L-MINY L-MAXY L-VALID.
     MOVE 0 TO L-VALID
     COMPUTE WS-TOP = L-Y + 4 + L-RADIUS
     IF L-SERVER = 1 AND L-EXISTS = 1 AND L-HUGE = 1 AND WS-TOP >= L-MINY AND WS-TOP < L-MAXY
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC5-MUSH-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-MUSH-GROW.
*> USING the feature exists, its place succeeded (BINARY-LONG), the mushroom removed, the original state restored, the return value out (1.3 growMushroom): without the feature
*> nothing changes and false is returned; else the block is removed, and restored when the placement fails.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EXISTS               BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-RESTORED             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-EXISTS L-PLACED L-REMOVED L-RESTORED L-RESULT.
     MOVE 0 TO L-REMOVED L-RESTORED L-RESULT
     IF L-EXISTS = 1
         MOVE 1 TO L-REMOVED
         IF L-PLACED = 1
             MOVE 1 TO L-RESULT
         ELSE
             MOVE 1 TO L-RESTORED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC5-MUSH-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-HUGE-PLACE.
*> USING for each direction (north, east, south, west, up, down) the block there is the same block (BINARY-LONG x 6), the six faces out (2.1 placement): a face is true when the
*> neighbour is NOT the same block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SAME.
    05 L-S                 BINARY-LONG OCCURS 6 TIMES.
 01 L-FACES.
    05 L-F                 BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-SAME L-FACES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 1 TO L-F(WS-I)
         IF L-S(WS-I) = 1
             MOVE 0 TO L-F(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC5-HUGE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-HUGE-SU.
*> USING the six faces, the direction of the update (1 to 6), the neighbour there is the same block (BINARY-LONG), the six faces out (2.1 SU): the face of that direction is set
*> false when the neighbour is the same block; a face is never set back to true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACES.
    05 L-F                 BINARY-LONG OCCURS 6 TIMES.
 01 L-DIR                  BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-OUT.
    05 L-O                 BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-FACES L-DIR L-SAME L-OUT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE L-F(WS-I) TO L-O(WS-I)
     END-PERFORM
     IF L-SAME = 1
         MOVE 0 TO L-O(L-DIR)
     END-IF
     GOBACK.
 END PROGRAM GC5-HUGE-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-HUGE-ROTATE.
*> USING the six faces, the rotation (0 none, 1 clockwise 90, 2 180, 3 counterclockwise 90) (BINARY-LONG), the six faces out (2.1 rotation): the face of the rotated direction takes
*> the value of the original direction; up and down map to themselves.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACES.
    05 L-F                 BINARY-LONG OCCURS 6 TIMES.
 01 L-ROT                  BINARY-LONG.
 01 L-OUT.
    05 L-O                 BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-FACES L-ROT L-OUT.
     MOVE L-F(5) TO L-O(5)
     MOVE L-F(6) TO L-O(6)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-J = FUNCTION MOD(WS-I - 1 + L-ROT, 4) + 1
         MOVE L-F(WS-I) TO L-O(WS-J)
     END-PERFORM
     GOBACK.
 END PROGRAM GC5-HUGE-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-HUGE-MIRROR.
*> USING the six faces, the mirror (0 none, 1 left-right, 2 front-back) (BINARY-LONG), the six faces out (2.1 mirror): every direction passes through Mirror.mirror: left-right
*> swaps north and south, front-back swaps east and west; up and down never change.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACES.
    05 L-F                 BINARY-LONG OCCURS 6 TIMES.
 01 L-MIRROR               BINARY-LONG.
 01 L-OUT.
    05 L-O                 BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-FACES L-MIRROR L-OUT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-I TO WS-J
         IF L-MIRROR = 1 AND (WS-I = 1 OR WS-I = 3)
             COMPUTE WS-J = 4 - WS-I
         END-IF
         IF L-MIRROR = 2 AND (WS-I = 2 OR WS-I = 4)
             COMPUTE WS-J = 6 - WS-I
         END-IF
         MOVE L-F(WS-I) TO L-O(WS-J)
     END-PERFORM
     GOBACK.
 END PROGRAM GC5-HUGE-MIRROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-SHELF-SURVIVE.
*> USING the block opposite to facing has a sturdy face towards facing (BINARY-LONG), canSurvive out (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STURDY               BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-STURDY L-SURVIVE.
     MOVE L-STURDY TO L-SURVIVE
     GOBACK.
 END PROGRAM GC5-SHELF-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-SHELF-PLACE.
*> USING for each of up to 6 nearest looking directions in order the pair horizontal, canSurvive (BINARY-LONG x 12), the index (1 to 6) of the direction used, 0 for no placement
*> out (2.2 placement): the first direction that is horizontal and gives a state that can survive.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIRS.
    05 L-D                 OCCURS 6 TIMES.
       10 L-HORIZONTAL     BINARY-LONG.
       10 L-CAN            BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRS L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR L-INDEX > 0
         IF L-HORIZONTAL(WS-I) = 1 AND L-CAN(WS-I) = 1
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC5-SHELF-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-SHELF-SU.
*> USING the update direction is the opposite of facing, the state can survive (BINARY-LONG), the result is air out (2.2 SU); otherwise the horizontal-directional default.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OPPOSITE             BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OPPOSITE L-SURVIVES L-AIR.
     MOVE 0 TO L-AIR
     IF L-OPPOSITE = 1 AND L-SURVIVES = 0
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM GC5-SHELF-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-SHELF-BONE.
*> USING age (BINARY-LONG), valid, success, the new age out (2.2 bone meal): valid while age is below 1, the test always succeeds, performBonemeal sets age + 1 (flags 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-VALID L-SUCCESS L-NEW.
     MOVE 0 TO L-VALID
     MOVE 1 TO L-SUCCESS
     COMPUTE L-NEW = L-AGE + 1
     IF L-AGE < 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC5-SHELF-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-SHELF-BOUNCE.
*> USING the entity (0 other, 1 item entity, 2 primed TNT) (BINARY-LONG), the sound shelf_mushroom_bounce plays, volume x 100, pitch x 100, restitution x 100 out (2.2 bounceOn): the
*> sound plays unless the entity is an item entity or a primed TNT; restitution 0.75.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-PLAYS                BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 01 L-RESTITUTION          BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-PLAYS L-VOLUME L-PITCH L-RESTITUTION.
     MOVE 0 TO L-PLAYS
     MOVE 100 TO L-VOLUME L-PITCH
     MOVE 75 TO L-RESTITUTION
     IF L-ENTITY = 0
         MOVE 1 TO L-PLAYS
     END-IF
     GOBACK.
 END PROGRAM GC5-SHELF-BOUNCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-FUNGUS-TABLE.
*> USING the block (1 crimson_fungus, 2 warped_fungus, 3 crimson_roots, 4 warped_roots, 5 nether_sprouts) (BINARY-LONG), support tag (1 supports_crimson_fungus, 2 supports_warped_fungus,
*> 3 supports_crimson_roots, 4 supports_warped_roots, 5 supports_nether_sprouts), required block (1 crimson_nylium, 2 warped_nylium, 0 none), feature (1 crimson_fungus_planted,
*> 2 warped_fungus_planted, 0 none), shape width, shape height, bone meal capable out (3.1, 3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-REQUIRED             BINARY-LONG.
 01 L-FEATURE              BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-BONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-TAG L-REQUIRED L-FEATURE L-WIDTH L-HEIGHT L-BONE.
     MOVE L-BLOCK TO L-TAG
     MOVE 0 TO L-REQUIRED L-FEATURE L-BONE
     MOVE 12 TO L-WIDTH
     MOVE 13 TO L-HEIGHT
     IF L-BLOCK <= 2
         MOVE L-BLOCK TO L-REQUIRED L-FEATURE
         MOVE 1 TO L-BONE
         MOVE 8 TO L-WIDTH
         MOVE 9 TO L-HEIGHT
     END-IF
     IF L-BLOCK = 5
         MOVE 3 TO L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM GC5-FUNGUS-TABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-FUNGUS-BONE.
*> USING the block below is the required nylium, pos.above() is inside the build height, the feature exists (BINARY-LONG), valid, place, fungus removed first out (3.1): valid needs
*> the nylium and the height; performBonemeal places the feature when it exists and never removes the fungus or restores anything.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REQUIRED             BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 01 L-FEATURE              BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 PROCEDURE DIVISION USING L-REQUIRED L-INSIDE L-FEATURE L-VALID L-PLACE L-REMOVED.
     MOVE 0 TO L-VALID L-PLACE L-REMOVED
     IF L-REQUIRED = 1 AND L-INSIDE = 1
         MOVE 1 TO L-VALID
     END-IF
     IF L-FEATURE = 1
         MOVE 1 TO L-PLACE
     END-IF
     GOBACK.
 END PROGRAM GC5-FUNGUS-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-MOSS-BONE.
*> USING the block at pos.above() is air, the feature exists (BINARY-LONG), valid, success, type (1 NEIGHBOR_SPREADER), place at pos.above(), particle y offset out (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-FEATURE              BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-FEATURE L-VALID L-SUCCESS L-TYPE L-PLACE L-OFFSET.
     MOVE L-AIR TO L-VALID
     MOVE L-FEATURE TO L-PLACE
     MOVE 1 TO L-SUCCESS L-TYPE L-OFFSET
     GOBACK.
 END PROGRAM GC5-MOSS-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-MOSS-FEATURE.
*> USING the block (1 moss_block, 2 pale_moss_block) (BINARY-LONG), the feature (1 moss_patch_bonemeal, 2 pale_moss_patch_bonemeal) out (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-FEATURE              BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-FEATURE.
     MOVE L-BLOCK TO L-FEATURE
     GOBACK.
 END PROGRAM GC5-MOSS-FEATURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-CARPET-SIDE.
*> USING the side can be attached to (canSupportAtFace), the cell above A holds a pale moss carpet whose same side is not none and whose base is false, the candidate base,
*> the cell below A holds a pale moss carpet whose same side is none (BINARY-LONG), the side (0 none, 1 low, 2 tall) out (3.4 step 2, force-low true): a supported side is low
*> and tall when the cell above has the side; with the candidate base false a side is none when the carpet below has none there.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACH               BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACH L-ABOVE L-BASE L-BELOW L-SIDE.
     MOVE 0 TO L-SIDE
     IF L-ATTACH = 1
         MOVE 1 TO L-SIDE
         IF L-ABOVE = 1
             MOVE 2 TO L-SIDE
         END-IF
     END-IF
     IF L-BASE = 0 AND L-BELOW = 1
         MOVE 0 TO L-SIDE
     END-IF
     GOBACK.
 END PROGRAM GC5-CARPET-SIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-CARPET-TOPPER.
*> USING A holds a pale moss carpet whose base is true, A holds a block that is not a carpet and cannot be replaced, the four sides north east south west (0 none, 1 low, 2 tall),
*> the state differs from the state at A (BINARY-LONG), the result is not air out (3.4 createTopperWithSideChance with the constant true supplier: no side is removed, no draw).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ABASE                BINARY-LONG.
 01 L-ABLOCKED             BINARY-LONG.
 01 L-SIDES.
    05 L-S                 BINARY-LONG OCCURS 4 TIMES.
 01 L-DIFFERS              BINARY-LONG.
 01 L-NONAIR               BINARY-LONG.
 PROCEDURE DIVISION USING L-ABASE L-ABLOCKED L-SIDES L-DIFFERS L-NONAIR.
     MOVE 0 TO L-NONAIR
     IF L-ABASE = 0 AND L-ABLOCKED = 0 AND L-DIFFERS = 1 AND (L-S(1) > 0 OR L-S(2) > 0 OR L-S(3) > 0 OR L-S(4) > 0)
         MOVE 1 TO L-NONAIR
     END-IF
     GOBACK.
 END PROGRAM GC5-CARPET-TOPPER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-CARPET-BONE.
*> USING base, the topper is not air (BINARY-LONG), valid, success, the block set at pos.above() out (3.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-NONAIR               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-NONAIR L-VALID L-SUCCESS L-SET.
     MOVE 0 TO L-VALID L-SET
     MOVE 1 TO L-SUCCESS
     IF L-BASE = 1 AND L-NONAIR = 1
         MOVE 1 TO L-VALID
         MOVE 1 TO L-SET
     END-IF
     GOBACK.
 END PROGRAM GC5-CARPET-BONE.
