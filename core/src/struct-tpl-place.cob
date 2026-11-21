*> Structure templates, part 2 (docs/protocol/36-structures-2 sections 3.2, 3.5, 5): the entity position transform, the filtered views, and placeInWorld, written into the
*> level of the feature stage (FEATLEVEL.cpy: the chunk being generated; a write outside its column is refused and the record skipped, as when placeInWorld's write fails).
*> Settings are STRUCT-SETTINGS (STRUCTSET.cpy), the work area STRUCT-PLACE-WORK (STRUCTPLACE.cpy). The template is a loaded cache row of STRUCT-TPL-LOAD.
*>
*> Entry points:
*>   STRUCT-TX-VEC USING x, y, z (FLOAT-LONG), mirror, rotation, pivot x, pivot z (BINARY-LONG), x out, y out, z out (FLOAT-LONG): 3.2
*>   STRUCT-FILTER-BLOCKS USING row, origin x, y, z, settings, block key (PIC X(48), with or without minecraft:), relative (BINARY-LONG): 3.5 filterBlocks into SF-REC (STRUCT-FILTER)
*>   STRUCT-PLACE USING row, origin x, y, z, anchor x, y, z, settings, flags, result out (1 when the placement ran, 0 for an early exit): 5.1 to 5.5
*>   STRUCT-PLACE-ENTITIES USING row, origin x, y, z, settings: 5.6, the entity records of the template as requests of the entity channel (GENT-ADD)
*>   STRUCT-FLUID-OF USING state, fluid out (0 none, 2 water, 3 lava), source out (1 when the fluid state is a source): the fluid state of a block state
*>   (STRUCT-PROCESS, processBlockInfos, is in struct-proc.cob)
*>   STRUCT-PLACE-BE USING x, y, z, state, tag: the block entity of 5.3 step 7 (a record with nbt was written): the loot seed draw and the request to the worldgen block entity channel
*>     (gen-be.cob) for a container with a loot table or a spawner; see the program.
*>   STRUCT-SHAPE-STATE USING x, y, z, direction (BinaryLong ordinal of 29 section 3: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east), neighbour state, state, state out: the
*>     updateShape hook of 5.5 (29 section 3.2). The per-block rules are written for the live world (blockupd-29.cob) and are not wired to the generation level, so this
*>     stub returns the state unchanged and records the call while SHT-ON is 1 (then it also maps SHT-FROM to SHT-TO, a test aid).
*> The entities of 5.6 are asked of the entity channel (STRUCT-PLACE-ENTITIES, gen-ent.cob). Not here: the barrier write of 5.3 step 4 (unobservable in the window), the fluid tick of
*> placeLiquid and Level.updateNeighborsAt of 5.5 step 2a (no ticking or neighbour updates in the generation window).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TX-VEC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-OX                   FLOAT-LONG.
 01 L-OY                   FLOAT-LONG.
 01 L-OZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-MIRROR L-ROT L-PX L-PZ L-OX L-OY L-OZ.
     MOVE L-X TO WS-X
     MOVE L-Z TO WS-Z
     MOVE L-PX TO WS-PX
     MOVE L-PZ TO WS-PZ
     EVALUATE L-MIRROR
         WHEN 1
             COMPUTE WS-Z = 1 - WS-Z
         WHEN 2
             COMPUTE WS-X = 1 - WS-X
     END-EVALUATE
     MOVE L-Y TO L-OY
     EVALUATE L-ROT
         WHEN 1
             COMPUTE L-OX = (WS-PX + WS-PZ + 1) - WS-Z
             COMPUTE L-OZ = (WS-PZ - WS-PX) + WS-X
         WHEN 2
             COMPUTE L-OX = (2 * WS-PX + 1) - WS-X
             COMPUTE L-OZ = (2 * WS-PZ + 1) - WS-Z
         WHEN 3
             COMPUTE L-OX = (WS-PX - WS-PZ) + WS-Z
             COMPUTE L-OZ = (WS-PX + WS-PZ + 1) - WS-X
         WHEN OTHER
             MOVE WS-X TO L-OX
             MOVE WS-Z TO L-OZ
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-TX-VEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-IN-BOX.
*> USING x, y, z, settings, flag out: 1 when the settings have no bounding box or the position is inside it.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 COPY STRUCTSET.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z STRUCT-SETTINGS L-FLAG.
     MOVE 1 TO L-FLAG
     IF PS-BOX-SET = 1
         IF L-X < PS-BOX(1) OR L-Y < PS-BOX(2) OR L-Z < PS-BOX(3) OR L-X > PS-BOX(4) OR L-Y > PS-BOX(5) OR L-Z > PS-BOX(6)
             MOVE 0 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-IN-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-FLUID-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-CLASS               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FLUID L-SOURCE.
     MOVE 0 TO L-FLUID L-SOURCE
     CALL "FL-CLASS" USING L-STATE WS-CLASS
     IF WS-CLASS = 2 OR WS-CLASS = 3
*>       A fluid block is a source at level 0 (29a section 1).
         MOVE WS-CLASS TO L-FLUID
         MOVE "level" TO WS-NAME
         CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-FOUND
         IF WS-FOUND = 1 AND WS-TEXT = "0"
             MOVE 1 TO L-SOURCE
         END-IF
         GOBACK
     END-IF
*>   A waterlogged block holds a water source; kelp, seagrass and the bubble column are always full of water (29a section 5).
     MOVE "waterlogged" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-FOUND
     IF WS-FOUND = 1 AND WS-TEXT = "true"
         MOVE 2 TO L-FLUID
         MOVE 1 TO L-SOURCE
         GOBACK
     END-IF
     IF L-STATE >= 0 AND L-STATE < CB-STATE-COUNT
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
         EVALUATE FUNCTION TRIM(CB-KEY(WS-BLOCK + 1))
             WHEN "kelp"
             WHEN "kelp_plant"
             WHEN "seagrass"
             WHEN "tall_seagrass"
             WHEN "bubble_column"
                 MOVE 2 TO L-FLUID
                 MOVE 1 TO L-SOURCE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM STRUCT-FLUID-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PLACE-BE.
*> USING x, y, z, state, tag (BINARY-LONG, the row in STRUCT-TPL-BE): 5.3 step 7 for a record with an nbt tag that was written. A randomizable container (kind 1) takes one
*> `nextLong` of the piece random (SP-XR of STRUCTPIECE.cpy, drawn for every container, with or without a loot table) as its LootTableSeed and, when it has a loot table, is requested
*> from the worldgen block-entity channel (GBE-ADD, kind 1) with that table and seed; a spawner (kind 2) is requested with its entity id (kind 2). Every other block entity (a sign,
*> a structure block, a jigsaw: the marker kinds are read by the piece, 6.2) is dropped: the chunk window and the channel carry containers and spawners only, and the items of a
*> container are not kept. SBH-* count the calls (a test aid). The barrier write of step 4 is not made: in the generation window it only discards a block entity that the window cannot hold.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPLACE.
 COPY STRUCTTPL.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 01 WS-LOOT                PIC X(48).
 01 WS-TEXT                PIC X(32).
 01 WS-NOTHING             PIC X(32) VALUE SPACES.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE L-TAG.
     ADD 1 TO SBH-CALLS
     MOVE L-X TO SBH-X
     MOVE L-Y TO SBH-Y
     MOVE L-Z TO SBH-Z
     MOVE L-STATE TO SBH-STATE
     EVALUATE TN-KIND(L-TAG)
         WHEN 1
             CALL "MSP-RNG-LONG" USING WS-SEED
*>           the request channel keeps loot keys of 48 bytes (GENBE.cpy): a longer key (trial_chambers/intersection_barrel, 51) cannot be asked for yet and its container is not requested
             IF TN-LOOT(L-TAG) NOT = SPACES AND TN-LOOT(L-TAG)(49:32) = SPACES
                 MOVE 1 TO WS-KIND
                 MOVE TN-LOOT(L-TAG) TO WS-LOOT
                 CALL "GBE-ADD" USING L-X L-Y L-Z WS-KIND WS-LOOT WS-SEED WS-NOTHING
             END-IF
         WHEN 2
             MOVE 2 TO WS-KIND
             MOVE 0 TO WS-SEED
             MOVE SPACES TO WS-LOOT
             MOVE TN-TEXT(L-TAG) TO WS-TEXT
             CALL "GBE-ADD" USING L-X L-Y L-Z WS-KIND WS-LOOT WS-SEED WS-TEXT
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-PLACE-BE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SHAPE-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPLACE.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-NSTATE               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-NSTATE L-STATE L-OUT.
     MOVE L-STATE TO L-OUT
     IF SHT-ON = 1 AND L-STATE = SHT-FROM
         MOVE SHT-TO TO L-OUT
     END-IF
     IF SHT-ON = 1 AND SHT-COUNT < SHT-MAX
         ADD 1 TO SHT-COUNT
         MOVE L-X TO SHT-X(SHT-COUNT)
         MOVE L-Y TO SHT-Y(SHT-COUNT)
         MOVE L-Z TO SHT-Z(SHT-COUNT)
         MOVE L-DIR TO SHT-DIR(SHT-COUNT)
         MOVE L-NSTATE TO SHT-NSTATE(SHT-COUNT)
     END-IF
     GOBACK.
 END PROGRAM STRUCT-SHAPE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-LIQUID-PLACE.
*> USING x, y, z, fluid (2 water, 3 lava, 0 none), source (BINARY-LONG): LiquidBlockContainer.placeLiquid (5.3 step 8, 11.10): a block with a waterlogged
*> property that is not waterlogged becomes waterlogged when the fluid is a water source (written with the default flags 3); nothing else changes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(24) VALUE "waterlogged".
 01 WS-TEXT                PIC X(32).
 01 WS-CHECK               BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLUID L-SOURCE.
     IF L-FLUID = 2 AND L-SOURCE = 1
         CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
         MOVE "false" TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-CHECK WS-STATE WS-NAME WS-TEXT WS-FOUND
         IF WS-FOUND = 1 AND WS-TEXT = "false"
             MOVE "true" TO WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-NEW
             CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-NEW WS-FLAGS WS-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-LIQUID-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PLACE-WRITE.
*> USING settings, flags: 5.3 over PW-REC (minus the barrier write and the loot seed, see the header).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPLACE.
 COPY STRUCTPROC.
 COPY FEATLEVEL.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-GLOOT               PIC X(48).
 01 WS-GSEED               BINARY-DOUBLE.
 01 WS-NOTHING             PIC X(32) VALUE SPACES.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-OLD-STATE           BINARY-LONG.
 01 WS-OLD-FLUID           BINARY-LONG.
 01 WS-OLD-SOURCE          BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TURNED              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(24) VALUE "waterlogged".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 COPY STRUCTSET.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING STRUCT-SETTINGS L-FLAGS.
     MOVE 0 TO PW-PLACED-COUNT PW-PEND-COUNT
     MOVE 0 TO PW-MIN-X PW-MIN-Y PW-MIN-Z PW-MAX-X PW-MAX-Y PW-MAX-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PW-COUNT
         MOVE PW-X(WS-I) TO WS-X
         MOVE PW-Y(WS-I) TO WS-Y
         MOVE PW-Z(WS-I) TO WS-Z
         CALL "STRUCT-IN-BOX" USING WS-X WS-Y WS-Z STRUCT-SETTINGS WS-INSIDE
         IF WS-INSIDE = 1
             MOVE 0 TO WS-OLD-FLUID WS-OLD-SOURCE
             IF PS-LIQUID = 0
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-OLD-STATE
                 CALL "STRUCT-FLUID-OF" USING WS-OLD-STATE WS-OLD-FLUID WS-OLD-SOURCE
             END-IF
             CALL "BLOCK-MIRROR-STATE" USING PW-STATE(WS-I) PS-MIRROR WS-TURNED
             CALL "BLOCK-ROTATE-STATE" USING WS-TURNED PS-ROTATION WS-STATE
             CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE L-FLAGS WS-OK
             IF WS-OK = 1
                 IF PW-PLACED-COUNT = 0
                     MOVE WS-X TO PW-MIN-X PW-MAX-X
                     MOVE WS-Y TO PW-MIN-Y PW-MAX-Y
                     MOVE WS-Z TO PW-MIN-Z PW-MAX-Z
                 END-IF
                 MOVE FUNCTION MIN(PW-MIN-X, WS-X) TO PW-MIN-X
                 MOVE FUNCTION MIN(PW-MIN-Y, WS-Y) TO PW-MIN-Y
                 MOVE FUNCTION MIN(PW-MIN-Z, WS-Z) TO PW-MIN-Z
                 MOVE FUNCTION MAX(PW-MAX-X, WS-X) TO PW-MAX-X
                 MOVE FUNCTION MAX(PW-MAX-Y, WS-Y) TO PW-MAX-Y
                 MOVE FUNCTION MAX(PW-MAX-Z, WS-Z) TO PW-MAX-Z
                 ADD 1 TO PW-PLACED-COUNT
                 MOVE WS-I TO PW-PLACED(PW-PLACED-COUNT)
                 MOVE WS-STATE TO PW-STATE(WS-I)
                 COMPUTE WS-CELL = (WS-Y - FL-MIN-Y) * 256 + (WS-Z - FL-CZ * 16) * 16 + (WS-X - FL-CX * 16) + 1
                 MOVE 1 TO PW-G-PLACED(WS-CELL)
                 IF PW-LOOT(WS-I) > 0
*>                   a tag made by an append_loot rule (the archaeology blocks): a brushable block with the table and the seed of the rule's source
                     MOVE SPR-LOOT(PW-LOOT(WS-I)) TO WS-GLOOT
                     MOVE PW-SEED(WS-I) TO WS-GSEED
                     CALL "GBE-ADD" USING WS-X WS-Y WS-Z WS-ONE WS-GLOOT WS-GSEED WS-NOTHING
                 ELSE
                     IF PW-NBT(WS-I) > 0
                         CALL "STRUCT-PLACE-BE" USING WS-X WS-Y WS-Z WS-STATE PW-NBT(WS-I)
                     END-IF
                 END-IF
                 IF PS-LIQUID = 0
                     CALL "STRUCT-FLUID-OF" USING WS-STATE WS-FLUID WS-SOURCE
                     IF WS-SOURCE = 1
                         MOVE 1 TO PW-G-DONE(WS-CELL)
                     ELSE
                         CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-FOUND
                         IF WS-FOUND = 1
                             CALL "STRUCT-LIQUID-PLACE" USING WS-X WS-Y WS-Z WS-OLD-FLUID WS-OLD-SOURCE
                             IF WS-OLD-SOURCE = 0
                                 ADD 1 TO PW-PEND-COUNT
                                 MOVE WS-I TO PW-PEND(PW-PEND-COUNT)
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PLACE-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PLACE-WATER.
*> USING settings: the waterlogging pass of 5.4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPLACE.
 COPY FEATLEVEL.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-NFLUID              BINARY-LONG.
 01 WS-NSOURCE             BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(24) VALUE "waterlogged".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-ORDER               PIC X(5) VALUE "12534".
 01 WS-DIGIT               PIC 9.
 LINKAGE SECTION.
 COPY STRUCTSET.
 PROCEDURE DIVISION USING STRUCT-SETTINGS.
     IF PS-LIQUID NOT = 0 OR PW-PEND-COUNT = 0
         GOBACK
     END-IF
     MOVE 1 TO WS-CHANGED
     PERFORM UNTIL WS-CHANGED = 0
         MOVE 0 TO WS-CHANGED
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PW-PEND-COUNT
             MOVE PW-PEND(WS-K) TO WS-R
             IF WS-R > 0
                 MOVE PW-X(WS-R) TO WS-X
                 MOVE PW-Y(WS-R) TO WS-Y
                 MOVE PW-Z(WS-R) TO WS-Z
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 CALL "STRUCT-FLUID-OF" USING WS-STATE WS-FLUID WS-SOURCE
*>               The neighbours in the order up, north, east, south, west (direction ordinals 1, 2, 5, 3, 4).
                 PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 5 OR WS-SOURCE = 1
                     MOVE WS-ORDER(WS-D:1) TO WS-DIGIT
                     MOVE WS-DIGIT TO WS-DIR
                     CALL "BU-DIRECTION" USING WS-DIR WS-DX WS-DY WS-DZ
                     COMPUTE WS-DX = WS-X + WS-DX
                     COMPUTE WS-DY = WS-Y + WS-DY
                     COMPUTE WS-DZ = WS-Z + WS-DZ
                     CALL "FL-GET-STATE" USING WS-DX WS-DY WS-DZ WS-STATE
                     CALL "STRUCT-FLUID-OF" USING WS-STATE WS-NFLUID WS-NSOURCE
                     MOVE 0 TO WS-DONE
                     COMPUTE WS-LX = WS-DX - FL-CX * 16
                     COMPUTE WS-LZ = WS-DZ - FL-CZ * 16
                     IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15 AND WS-DY >= FL-MIN-Y
                         AND WS-DY < FL-MIN-Y + FL-HEIGHT
                         COMPUTE WS-CELL = (WS-DY - FL-MIN-Y) * 256 + WS-LZ * 16 + WS-LX + 1
                         MOVE PW-G-DONE(WS-CELL) TO WS-DONE
                     END-IF
                     IF WS-NSOURCE = 1 AND WS-DONE = 0
                         MOVE WS-NFLUID TO WS-FLUID
                         MOVE 1 TO WS-SOURCE
                     END-IF
                 END-PERFORM
                 IF WS-SOURCE = 1
                     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-FOUND
                     IF WS-FOUND = 1
                         CALL "STRUCT-LIQUID-PLACE" USING WS-X WS-Y WS-Z WS-FLUID WS-SOURCE
                         MOVE 1 TO WS-CHANGED
                         MOVE 0 TO PW-PEND(WS-K)
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PLACE-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SHAPE-FACE.
*> USING x, y, z (the set cell, absolute), direction (ordinal towards the clear neighbour), flags: the consumer of 5.5.1 for one exposed face.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-OPPOSITE            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-FLAGS.
     CALL "BU-DIRECTION" USING L-DIR WS-DX WS-DY WS-DZ
     COMPUTE WS-NX = L-X + WS-DX
     COMPUTE WS-NY = L-Y + WS-DY
     COMPUTE WS-NZ = L-Z + WS-DZ
     COMPUTE WS-OPPOSITE = L-DIR + 1 - 2 * FUNCTION MOD(L-DIR, 2)
*>   flags AND NOT 1
     COMPUTE WS-FLAGS = L-FLAGS - FUNCTION MOD(L-FLAGS, 2)
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-S
     CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-N
     CALL "STRUCT-SHAPE-STATE" USING L-X L-Y L-Z L-DIR WS-N WS-S WS-S2
     IF WS-S2 NOT = WS-S
         CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-S2 WS-FLAGS WS-OK
     END-IF
*>   The neighbour sees the possibly updated state s2, which is not re-read.
     CALL "STRUCT-SHAPE-STATE" USING WS-NX WS-NY WS-NZ WS-OPPOSITE WS-S2 WS-N WS-N2
     IF WS-N2 NOT = WS-N
         CALL "FL-SET-STATE" USING WS-NX WS-NY WS-NZ WS-N2 WS-FLAGS WS-OK
     END-IF
     GOBACK.
 END PROGRAM STRUCT-SHAPE-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SHAPE-EDGE.
*> USING flags: updateShapeAtEdge (5.5.1) over the set cells PW-G-PLACED of the box PW-MIN to PW-MAX: the three passes of forAllFaces (lines along z, y, x), the faces
*> in the order they are met.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPLACE.
 COPY FEATLEVEL.
 01 WS-PASS                BINARY-LONG.
 01 WS-LINE                BINARY-LONG.
 01 WS-OUTER               BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-AXES                PIC X(9) VALUE "312" & "231" & "123".
 01 WS-DIGIT               PIC 9.
 01 WS-SIZES.
    05 WS-SIZE             BINARY-LONG OCCURS 3 TIMES.
 01 WS-MINS.
    05 WS-MIN              BINARY-LONG OCCURS 3 TIMES.
 01 WS-CELL.
    05 WS-C                BINARY-LONG OCCURS 3 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-NEGATIVE            PIC X(3) VALUE "402".
 01 WS-POSITIVE            PIC X(3) VALUE "513".
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS.
     COMPUTE WS-SIZE(1) = PW-MAX-X - PW-MIN-X + 1
     COMPUTE WS-SIZE(2) = PW-MAX-Y - PW-MIN-Y + 1
     COMPUTE WS-SIZE(3) = PW-MAX-Z - PW-MIN-Z + 1
     MOVE PW-MIN-X TO WS-MIN(1)
     MOVE PW-MIN-Y TO WS-MIN(2)
     MOVE PW-MIN-Z TO WS-MIN(3)
     PERFORM VARYING WS-PASS FROM 0 BY 1 UNTIL WS-PASS > 2
*>       Axis numbers 1 x, 2 y, 3 z: the line axis, then the outer and the inner axis of the pass (5.5.1).
         MOVE WS-AXES(WS-PASS * 3 + 1:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-LINE
         MOVE WS-AXES(WS-PASS * 3 + 2:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-OUTER
         MOVE WS-AXES(WS-PASS * 3 + 3:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-INNER
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-SIZE(WS-OUTER)
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-SIZE(WS-INNER)
                 MOVE WS-I TO WS-C(WS-OUTER)
                 MOVE WS-J TO WS-C(WS-INNER)
                 MOVE 0 TO WS-PREV
                 PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > WS-SIZE(WS-LINE)
                     MOVE 0 TO WS-CUR
                     IF WS-K < WS-SIZE(WS-LINE)
                         MOVE WS-K TO WS-C(WS-LINE)
                         COMPUTE WS-X = WS-MIN(1) + WS-C(1)
                         COMPUTE WS-Y = WS-MIN(2) + WS-C(2)
                         COMPUTE WS-Z = WS-MIN(3) + WS-C(3)
                         COMPUTE WS-INDEX = (WS-Y - FL-MIN-Y) * 256 + (WS-Z - FL-CZ * 16) * 16 + (WS-X - FL-CX * 16) + 1
                         MOVE PW-G-PLACED(WS-INDEX) TO WS-CUR
                     END-IF
                     IF WS-PREV = 0 AND WS-CUR = 1
                         MOVE WS-NEGATIVE(WS-LINE:1) TO WS-DIGIT
                         MOVE WS-DIGIT TO WS-DIR
                         CALL "STRUCT-SHAPE-FACE" USING WS-X WS-Y WS-Z WS-DIR L-FLAGS
                     END-IF
                     IF WS-PREV = 1 AND WS-CUR = 0
                         COMPUTE WS-C(WS-LINE) = WS-K - 1
                         COMPUTE WS-X = WS-MIN(1) + WS-C(1)
                         COMPUTE WS-Y = WS-MIN(2) + WS-C(2)
                         COMPUTE WS-Z = WS-MIN(3) + WS-C(3)
                         MOVE WS-POSITIVE(WS-LINE:1) TO WS-DIGIT
                         MOVE WS-DIGIT TO WS-DIR
                         CALL "STRUCT-SHAPE-FACE" USING WS-X WS-Y WS-Z WS-DIR L-FLAGS
                     END-IF
                     MOVE WS-CUR TO WS-PREV
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-SHAPE-EDGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PLACE-SHAPES.
*> USING settings, flags: 5.5 (the shape grid, then each placed position's update from the neighbour shapes), and the clearing of the work grids.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPLACE.
 COPY FEATLEVEL.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NSTATE              BINARY-LONG.
 01 WS-CURRENT             BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-QUOTIENT            BINARY-LONG.
 LINKAGE SECTION.
 COPY STRUCTSET.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING STRUCT-SETTINGS L-FLAGS.
     IF PW-PLACED-COUNT > 0 AND PS-KNOWN-SHAPE = 0
         CALL "STRUCT-SHAPE-EDGE" USING L-FLAGS
*>       (flags AND NOT 1) OR 16
         COMPUTE WS-FLAGS = L-FLAGS - FUNCTION MOD(L-FLAGS, 2)
         DIVIDE WS-FLAGS BY 16 GIVING WS-QUOTIENT
         IF FUNCTION MOD(WS-QUOTIENT, 2) < 1
             ADD 16 TO WS-FLAGS
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PW-PLACED-COUNT
             MOVE PW-PLACED(WS-I) TO WS-R
             MOVE PW-X(WS-R) TO WS-X
             MOVE PW-Y(WS-R) TO WS-Y
             MOVE PW-Z(WS-R) TO WS-Z
             CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
             MOVE WS-STATE TO WS-CURRENT
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
                 CALL "BU-ORDER" USING WS-KIND WS-D WS-DIR
                 CALL "BU-DIRECTION" USING WS-DIR WS-DX WS-DY WS-DZ
                 COMPUTE WS-NX = WS-X + WS-DX
                 COMPUTE WS-NY = WS-Y + WS-DY
                 COMPUTE WS-NZ = WS-Z + WS-DZ
                 CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-NSTATE
                 CALL "STRUCT-SHAPE-STATE" USING WS-X WS-Y WS-Z WS-DIR WS-NSTATE WS-CURRENT WS-NEXT
                 MOVE WS-NEXT TO WS-CURRENT
             END-PERFORM
             IF WS-CURRENT NOT = WS-STATE
                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-CURRENT WS-FLAGS WS-OK
             END-IF
         END-PERFORM
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PW-PLACED-COUNT
         MOVE PW-PLACED(WS-I) TO WS-R
         COMPUTE WS-CELL = (PW-Y(WS-R) - FL-MIN-Y) * 256 + (PW-Z(WS-R) - FL-CZ * 16) * 16 + (PW-X(WS-R) - FL-CX * 16) + 1
         MOVE 0 TO PW-G-PLACED(WS-CELL) PW-G-DONE(WS-CELL)
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PLACE-SHAPES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PLACE-ENTITIES.
*> USING row, origin x, y, z, settings: 5.6 for the template's entity records (kept by STRUCT-TPL-ENTITY) unless the settings ignore entities: the block position of each record is transformed
*> (mirror, rotation, pivot) and moved by the origin, and a record whose block is outside the settings' box is skipped (so the one pass whose box holds the block asks for it); the position is
*> transformed the same way (3.2); the yaw is the stored one turned by the rotation (0, 90, 180, 270 degrees) with the mirror applied to the stored yaw (left-right: 180 - yaw, front-back: -yaw,
*> from the geometry of the block transform: the document leaves Entity.rotate and Entity.mirror to 44 and 45, Open question 5). The compound goes to the entity channel (GENT-ADD) as stored:
*> the reader replaces Pos and Rotation and ignores UUID (a fresh one is assigned), which is step 3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-D                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 COPY STRUCTSET.
 PROCEDURE DIVISION USING L-ROW L-OX L-OY L-OZ STRUCT-SETTINGS.
     IF PS-IGNORE-ENTITIES = 1
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-ENT-N(L-ROW)
         COMPUTE WS-R = TP-ENT-BASE(L-ROW) + WS-I
         CALL "STRUCT-TX-POS" USING TE-BX(WS-R) TE-BY(WS-R) TE-BZ(WS-R) PS-MIRROR PS-ROTATION PS-PIVOT-X PS-PIVOT-Z WS-BX WS-BY WS-BZ
         COMPUTE WS-BX = WS-BX + L-OX
         COMPUTE WS-BY = WS-BY + L-OY
         COMPUTE WS-BZ = WS-BZ + L-OZ
         CALL "STRUCT-IN-BOX" USING WS-BX WS-BY WS-BZ STRUCT-SETTINGS WS-IN
         IF WS-IN = 1
             MOVE TE-PX(WS-R) TO WS-X
             MOVE TE-PY(WS-R) TO WS-Y
             MOVE TE-PZ(WS-R) TO WS-Z
             CALL "STRUCT-TX-VEC" USING WS-X WS-Y WS-Z PS-MIRROR PS-ROTATION PS-PIVOT-X PS-PIVOT-Z WS-TX WS-TY WS-TZ
             COMPUTE WS-TX = WS-TX + L-OX
             COMPUTE WS-TY = WS-TY + L-OY
             COMPUTE WS-TZ = WS-TZ + L-OZ
             MOVE TE-YAW(WS-R) TO WS-D
             EVALUATE PS-MIRROR
                 WHEN 1
                     COMPUTE WS-D = 180 - WS-D
                 WHEN 2
                     COMPUTE WS-D = 0 - WS-D
             END-EVALUATE
             COMPUTE WS-D = WS-D + 90 * PS-ROTATION
             COMPUTE WS-D = FUNCTION MOD(WS-D, 360)
             IF WS-D >= 180
                 COMPUTE WS-D = WS-D - 360
             END-IF
             MOVE WS-D TO WS-YAW
             CALL "GENT-ADD" USING WS-TX WS-TY WS-TZ WS-YAW TE-LEN(WS-R) TE-DATA(WS-R)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PLACE-ENTITIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY STRUCTPLACE.
 01 WS-PALETTE             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 COPY STRUCTSET.
 01 L-FLAGS                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OX L-OY L-OZ L-AX L-AY L-AZ STRUCT-SETTINGS L-FLAGS L-RESULT.
     MOVE 0 TO L-RESULT PW-COUNT PW-PLACED-COUNT PW-PEND-COUNT
     IF TP-STATUS(L-ROW) NOT = 1 OR TP-PALETTES(L-ROW) < 1
         GOBACK
     END-IF
     IF PS-RANDOM-SET = 1
         CALL "JRAND-NEXT-INT-BOUND" USING PS-RANDOM TP-PALETTES(L-ROW) WS-PALETTE
     ELSE
         CALL "STRUCT-PALETTE-PICK" USING TP-PALETTES(L-ROW) L-OX L-OY L-OZ WS-PALETTE
     END-IF
     IF TP-BLOCKS(L-ROW) = 0 AND (PS-IGNORE-ENTITIES = 1 OR TP-ENTITIES(L-ROW) = 0)
         GOBACK
     END-IF
     IF TP-SX(L-ROW) < 1 OR TP-SY(L-ROW) < 1 OR TP-SZ(L-ROW) < 1
         GOBACK
     END-IF
     CALL "STRUCT-PROCESS" USING L-ROW WS-PALETTE L-OX L-OY L-OZ L-AX L-AY L-AZ STRUCT-SETTINGS
     CALL "STRUCT-PLACE-WRITE" USING STRUCT-SETTINGS L-FLAGS
     CALL "STRUCT-PLACE-WATER" USING STRUCT-SETTINGS
     CALL "STRUCT-PLACE-SHAPES" USING STRUCT-SETTINGS L-FLAGS
     CALL "STRUCT-PLACE-ENTITIES" USING L-ROW L-OX L-OY L-OZ STRUCT-SETTINGS
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM STRUCT-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-FILTER-BLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY STRUCTPLACE.
 COPY CBLOCKS.
 01 WS-PALETTE             BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 COPY STRUCTSET.
 01 L-KEY                  PIC X(48).
 01 L-RELATIVE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OX L-OY L-OZ STRUCT-SETTINGS L-KEY L-RELATIVE.
     MOVE 0 TO SF-COUNT
     IF TP-STATUS(L-ROW) NOT = 1 OR TP-PALETTES(L-ROW) < 1
         GOBACK
     END-IF
     IF PS-RANDOM-SET = 1
         CALL "JRAND-NEXT-INT-BOUND" USING PS-RANDOM TP-PALETTES(L-ROW) WS-PALETTE
     ELSE
         CALL "STRUCT-PALETTE-PICK" USING TP-PALETTES(L-ROW) L-OX L-OY L-OZ WS-PALETTE
     END-IF
     MOVE L-KEY TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-WANT
     IF WS-WANT = 0
         GOBACK
     END-IF
     COMPUTE WS-BASE = TP-BASE(L-ROW, WS-PALETTE + 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(L-ROW)
         IF CB-S-BLOCK(TB-STATE(WS-BASE + WS-I) + 1) + 1 = WS-WANT AND SF-COUNT < 4096
             MOVE TB-X(WS-BASE + WS-I) TO WS-X
             MOVE TB-Y(WS-BASE + WS-I) TO WS-Y
             MOVE TB-Z(WS-BASE + WS-I) TO WS-Z
             MOVE WS-X TO WS-AX
             MOVE WS-Y TO WS-AY
             MOVE WS-Z TO WS-AZ
             IF L-RELATIVE = 1
                 CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z PS-MIRROR PS-ROTATION PS-PIVOT-X PS-PIVOT-Z WS-AX WS-AY WS-AZ
                 ADD L-OX TO WS-AX
                 ADD L-OY TO WS-AY
                 ADD L-OZ TO WS-AZ
             END-IF
             CALL "STRUCT-IN-BOX" USING WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-INSIDE
             IF WS-INSIDE = 1
                 ADD 1 TO SF-COUNT
                 MOVE WS-AX TO SF-X(SF-COUNT)
                 MOVE WS-AY TO SF-Y(SF-COUNT)
                 MOVE WS-AZ TO SF-Z(SF-COUNT)
                 MOVE TB-STATE(WS-BASE + WS-I) TO WS-STATE
                 CALL "BLOCK-ROTATE-STATE" USING WS-STATE PS-ROTATION SF-STATE(SF-COUNT)
                 MOVE TB-NBT(WS-BASE + WS-I) TO SF-NBT(SF-COUNT)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-FILTER-BLOCKS.
