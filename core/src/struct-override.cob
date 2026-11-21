 *> Structure spawn overrides (docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 8; STRUCTOVR.cpy): inside the box of a structure that has an override, the natural
 *> spawner draws from the override's list in place of the biome's (8.1 step 2b), an empty list drawing nothing.
 *>
 *> Entry points:
 *>   SO-REGISTER USING dimension, chunk x, chunk z, kind, min x, y, z, max x, y, z (BINARY-LONG): remembers a box that intersects the chunk (an identical record is kept once; a full registry
 *>     overwrites the oldest)
 *>   SO-LOOKUP USING dimension, x, y, z, category (1 to 7), list out (BINARY-LONG: a row of SO-LIST, 0 when no registered box holds the position for a kind that has a list for the category):
 *>     the first qualifying record in registration order wins (8.1); kind 7 (the whole fortress box) applies to the monster category on nether bricks only (8.1 step 1)
 *>   SO-PICK USING state (XORO), list row, entry out (BINARY-LONG: a row of SO-ENTRY, 0 for an empty list, which draws nothing): WeightedList.getRandom (7.1): nextInt(total), then the first
 *>     entry whose cumulative weight exceeds the roll
 *>   SO-PACK-SIZE USING state, entry row, n out: the pack size of 6.5 step 3 from the entry's count (a constant draws nothing)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SO-REGISTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTOVR.
 01 WS-I                   BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-KIND L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 0 TO WS-SAME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SO-COUNT
         IF SO-DIM(WS-I) = L-DIM AND SO-CX(WS-I) = L-CX AND SO-CZ(WS-I) = L-CZ AND SO-KIND(WS-I) = L-KIND
                 AND SO-BOX(WS-I, 1) = L-X0 AND SO-BOX(WS-I, 2) = L-Y0 AND SO-BOX(WS-I, 3) = L-Z0
                 AND SO-BOX(WS-I, 4) = L-X1 AND SO-BOX(WS-I, 5) = L-Y1 AND SO-BOX(WS-I, 6) = L-Z1
             MOVE 1 TO WS-SAME
         END-IF
     END-PERFORM
     IF WS-SAME = 1
         GOBACK
     END-IF
     IF SO-COUNT < SO-MAX
         ADD 1 TO SO-COUNT
         MOVE SO-COUNT TO WS-I
     ELSE
         COMPUTE WS-I = FUNCTION MOD(SO-NEXT, SO-MAX) + 1
         ADD 1 TO SO-NEXT
     END-IF
     MOVE L-DIM TO SO-DIM(WS-I)
     MOVE L-CX TO SO-CX(WS-I)
     MOVE L-CZ TO SO-CZ(WS-I)
     MOVE L-KIND TO SO-KIND(WS-I)
     MOVE L-X0 TO SO-BOX(WS-I, 1)
     MOVE L-Y0 TO SO-BOX(WS-I, 2)
     MOVE L-Z0 TO SO-BOX(WS-I, 3)
     MOVE L-X1 TO SO-BOX(WS-I, 4)
     MOVE L-Y1 TO SO-BOX(WS-I, 5)
     MOVE L-Z1 TO SO-BOX(WS-I, 6)
     GOBACK.
 END PROGRAM SO-REGISTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SO-LOOKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTOVR.
 COPY CBLOCKS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 01 L-LIST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-CAT L-LIST.
     MOVE 0 TO L-LIST
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SO-COUNT OR L-LIST > 0
         IF SO-DIM(WS-I) = L-DIM AND SO-CX(WS-I) = WS-CX AND SO-CZ(WS-I) = WS-CZ
                 AND L-X >= SO-BOX(WS-I, 1) AND L-X <= SO-BOX(WS-I, 4)
                 AND L-Y >= SO-BOX(WS-I, 2) AND L-Y <= SO-BOX(WS-I, 5)
                 AND L-Z >= SO-BOX(WS-I, 3) AND L-Z <= SO-BOX(WS-I, 6)
             PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > SO-LISTS OR L-LIST > 0
                 IF SO-L-KIND(WS-L) = SO-KIND(WS-I) AND (SO-L-CAT(WS-L) = L-CAT OR SO-L-CAT(WS-L) = 0)
                     MOVE WS-L TO L-LIST
                     IF SO-KIND(WS-I) = 7
*>                       the hardcoded fortress rule: the block below must be nether bricks
                         COMPUTE WS-BELOW = L-Y - 1
                         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-BELOW L-Z WS-STATE
                         IF CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) NOT = "nether_bricks"
                             MOVE 0 TO L-LIST
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SO-LOOKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SO-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTOVR.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-LIST                 BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-LIST L-ENTRY.
     MOVE 0 TO L-ENTRY WS-TOTAL
     COMPUTE WS-LAST = SO-L-FIRST(L-LIST) + SO-L-COUNT(L-LIST)
     PERFORM VARYING WS-I FROM SO-L-FIRST(L-LIST) BY 1 UNTIL WS-I >= WS-LAST
         ADD SO-E-WEIGHT(WS-I + 1) TO WS-TOTAL
     END-PERFORM
     IF WS-TOTAL = 0
         GOBACK
     END-IF
     CALL "XORO-NEXT-INT" USING L-STATE WS-TOTAL WS-ROLL
     PERFORM VARYING WS-I FROM SO-L-FIRST(L-LIST) BY 1 UNTIL WS-I >= WS-LAST OR L-ENTRY > 0
         SUBTRACT SO-E-WEIGHT(WS-I + 1) FROM WS-ROLL
         IF WS-ROLL < 0
             COMPUTE L-ENTRY = WS-I + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SO-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SO-PACK-SIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTOVR.
 01 WS-SPAN                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ENTRY                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ENTRY L-N.
     MOVE SO-E-MIN(L-ENTRY) TO L-N
     IF SO-E-MAX(L-ENTRY) > SO-E-MIN(L-ENTRY)
         COMPUTE WS-SPAN = SO-E-MAX(L-ENTRY) - SO-E-MIN(L-ENTRY) + 1
         CALL "XORO-NEXT-INT" USING L-STATE WS-SPAN WS-A
         ADD WS-A TO L-N
     END-IF
     GOBACK.
 END PROGRAM SO-PACK-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-OVR-NOTE.
*> USING structure key (PIC X(80), "minecraft:swamp_hut"), chunk x, chunk z, overall box (six BINARY-LONG: min x y z, max x y z), pieces (the builder of STRUCTPIECE.cpy holds the start): for a
*> structure that overrides the spawn lists (44-2 8.3) the boxes that intersect the chunk are asked of the entity channel (GENT-ADD-BOX): a `full` structure (monument, pillager outpost, ancient
*> city) its overall box once, a `piece` structure (fortress, swamp hut, trial chambers) every piece box that intersects the chunk column, and for the fortress also the overall box as kind 7 (the
*> hardcoded rule of 8.1 step 1). Any other structure asks for nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-KIND                BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-BOX.
    05 L-BX0               BINARY-LONG.
    05 L-BY0               BINARY-LONG.
    05 L-BZ0               BINARY-LONG.
    05 L-BX1               BINARY-LONG.
    05 L-BY1               BINARY-LONG.
    05 L-BZ1               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CX L-CZ L-BOX.
     MOVE 0 TO WS-KIND WS-FULL
     EVALUATE L-KEY
         WHEN "minecraft:fortress"
             MOVE 1 TO WS-KIND
         WHEN "minecraft:monument"
             MOVE 2 TO WS-KIND
             MOVE 1 TO WS-FULL
         WHEN "minecraft:pillager_outpost"
             MOVE 3 TO WS-KIND
             MOVE 1 TO WS-FULL
         WHEN "minecraft:swamp_hut"
             MOVE 4 TO WS-KIND
         WHEN "minecraft:ancient_city"
             MOVE 5 TO WS-KIND
             MOVE 1 TO WS-FULL
         WHEN "minecraft:trial_chambers"
             MOVE 6 TO WS-KIND
         WHEN OTHER
             GOBACK
     END-EVALUATE
     COMPUTE WS-X0 = L-CX * 16
     COMPUTE WS-Z0 = L-CZ * 16
     COMPUTE WS-X1 = WS-X0 + 15
     COMPUTE WS-Z1 = WS-Z0 + 15
     IF L-BX1 < WS-X0 OR L-BX0 > WS-X1 OR L-BZ1 < WS-Z0 OR L-BZ0 > WS-Z1
         GOBACK
     END-IF
     IF WS-FULL = 1
         CALL "GENT-ADD-BOX" USING WS-KIND L-BX0 L-BY0 L-BZ0 L-BX1 L-BY1 L-BZ1
         GOBACK
     END-IF
     IF WS-KIND = 1
         CALL "GENT-ADD-BOX" USING WS-SEVEN L-BX0 L-BY0 L-BZ0 L-BX1 L-BY1 L-BZ1
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         IF SP-X1(WS-I) >= WS-X0 AND SP-X0(WS-I) <= WS-X1 AND SP-Z1(WS-I) >= WS-Z0 AND SP-Z0(WS-I) <= WS-Z1
             CALL "GENT-ADD-BOX" USING WS-KIND SP-X0(WS-I) SP-Y0(WS-I) SP-Z0(WS-I) SP-X1(WS-I) SP-Y1(WS-I) SP-Z1(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-OVR-NOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-OVR-NOTE-ADAPT.
*> USING structure key (PIC X(80)), chunk x, chunk z, overall box (six BINARY-LONG: the union of the pieces), adapt (BINARY-LONG: 0 when the structure's terrain_adaptation is none, else 1): the
*> overall box of a start is the union of its pieces inflated by 12 on every face when the terrain adaptation is not none (44-2 section 8.2, StructureStart.getBoundingBox through
*> Structure.adjustBoundingBox), and that adjusted box is the one that decides which chunks carry the start's reference (8.5 createReferences) and the one a `full` test uses (pillager
*> outpost beard_thin and ancient city beard_box: 12 blocks of margin in every direction; the monument none). The piece boxes of a `piece` structure are never inflated. Then STRUCT-OVR-NOTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BOX.
    05 WS-B                BINARY-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-BOX.
    05 L-B                 BINARY-LONG OCCURS 6 TIMES.
 01 L-ADAPT                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CX L-CZ L-BOX L-ADAPT.
     MOVE L-BOX TO WS-BOX
     IF L-ADAPT NOT = 0
         SUBTRACT 12 FROM WS-B(1) WS-B(2) WS-B(3)
         ADD 12 TO WS-B(4) WS-B(5) WS-B(6)
     END-IF
     CALL "STRUCT-OVR-NOTE" USING L-KEY L-CX L-CZ WS-BOX
     GOBACK.
 END PROGRAM STRUCT-OVR-NOTE-ADAPT.
