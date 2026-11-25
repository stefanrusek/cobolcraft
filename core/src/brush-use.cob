*> Using a brush (docs/protocol/17-tools-weapons-and-combat.md section 3.5, 25-item-registry-8 section 7, 31-block-entities-4 section 7; lane bugbrush).
*> Use Item On with a brush in the main hand while the view ray hits a block starts the use (BRUSH-START: PL-BRUSH-ACTIVE, use duration 200); every
*> tick of the use (BRUSH-TICK, called by HEALTH-TICK) re-casts the view ray (a miss, another held slot or a release ends the use) and, on the used tick
*> whose number modulo 10 is 5, runs one brushing step (BRUSH-STEP): the brushing sound of the block, the block dust particles and, for a brushable
*> block with a block entity (suspicious sand or gravel), the brush of 31-4 section 7.4 (BE4-BRUSH): the loot is rolled with the archaeology parameter
*> set (BRUSH-UNPACK, 7.5), a counted brush schedules the 2-tick block tick and moves the block's dusted value (the Block Update), the tenth completes
*> (BRUSH-COMPLETE, 7.7): the buried item drops at the neighbouring cell's centre without motion, level event 3008, the block becomes sand or gravel and
*> the brush loses 1 durability. The block tick (BRUSH-BLOCK-TICK, BU-HOOK effect 11, registered by GB-RULES-OPEN) is checkReset (7.6) and the fall of
*> the block with cancelDrop. Breaking the block drops nothing from its block entity (BE-BLOCK-SET leaves a brushable block entity's item alone: it is not
*> a container).
*> Not done here (stand-ins): the dust particles and the brushing sounds are the client's cosmetic effects in vanilla (25 part 8 section 7.1); this client has no brush
*> state, so the core sends them to the players in range (Level Particles with the block state, Sound Effect) and the brushing player hears the sound too (17 section
*> 3.5 and 25 section 7.3 leave the exclusion of the own client open, open question 8).
*> Entry points:
*>   BRUSH-HIT USING player row, hit out, x, y, z out, face out (legacy direction id: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east)
*>   BRUSH-START USING connection id, PLAY-SERVERBOUND, started out
*>   BRUSH-TICK USING player row
*>   BRUSH-STEP USING player row, x, y, z, face
*>   BRUSH-UNPACK USING block entity index, player row
*>   BRUSH-COMPLETE USING player row, block entity index, dimension row, x, y, z
*>   BRUSH-BLOCK-TICK USING dimension row, x, y, z
*>   BRUSH-DUSTED-SET USING dimension row, x, y, z, dusted

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRUSH-HIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-HAVE-LAST           BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HIT L-X L-Y L-Z L-FACE.
     MOVE 0 TO L-HIT L-X L-Y L-Z
     MOVE 1 TO L-FACE
     MOVE PL-DIM(L-ROW) TO WS-DIM
*>   The ray of the bucket (core/src/bucket-29a.cob): the eye 1.6 above the feet along the look, 4.5 blocks (5.0 in creative), every 0.02.
     MOVE 4.5 TO WS-REACH
     IF PL-MODE(L-ROW) = 1
         MOVE 5.0 TO WS-REACH
     END-IF
     COMPUTE WS-EX = PL-X(L-ROW)
     COMPUTE WS-EY = PL-Y(L-ROW) + 1.6
     COMPUTE WS-EZ = PL-Z(L-ROW)
     COMPUTE WS-YAW = PL-YAW(L-ROW) * FUNCTION PI / 180
     COMPUTE WS-PITCH = PL-PITCH(L-ROW) * FUNCTION PI / 180
     COMPUTE WS-DX = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-DY = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-DZ = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     MOVE 0 TO WS-HAVE-LAST WS-T
     PERFORM UNTIL WS-T > WS-REACH OR L-HIT = 1
         COMPUTE WS-CX = FUNCTION INTEGER(WS-EX + WS-DX * WS-T)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-EY + WS-DY * WS-T)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-EZ + WS-DZ * WS-T)
         IF WS-HAVE-LAST = 0 OR WS-CX NOT = WS-LX OR WS-CY NOT = WS-LY OR WS-CZ NOT = WS-LZ
             CALL "FLUID-CELL" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
                 WS-SOLID WS-HOLDS
             IF WS-STATE NOT = 0 AND WS-FLUID = 0
                 MOVE 1 TO L-HIT
                 MOVE WS-CX TO L-X
                 MOVE WS-CY TO L-Y
                 MOVE WS-CZ TO L-Z
             ELSE
                 MOVE WS-CX TO WS-LX
                 MOVE WS-CY TO WS-LY
                 MOVE WS-CZ TO WS-LZ
                 MOVE 1 TO WS-HAVE-LAST
             END-IF
         END-IF
         ADD 0.02 TO WS-T
     END-PERFORM
*>   The face is the side of the hit cell the ray came through: from the last empty cell toward the hit cell (up when the ray starts inside it).
     IF L-HIT = 1 AND WS-HAVE-LAST = 1
         EVALUATE TRUE
             WHEN WS-LY > L-Y
                 MOVE 1 TO L-FACE
             WHEN WS-LY < L-Y
                 MOVE 0 TO L-FACE
             WHEN WS-LX > L-X
                 MOVE 5 TO L-FACE
             WHEN WS-LX < L-X
                 MOVE 4 TO L-FACE
             WHEN WS-LZ > L-Z
                 MOVE 3 TO L-FACE
             WHEN OTHER
                 MOVE 2 TO L-FACE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM BRUSH-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRUSH-START.
*> USING connection id, PLAY-SERVERBOUND (a decoded Use Item On), started out (1 when the brush of the main hand is now in use): BrushItem.useOn (25 part 8
*> section 7 item 1): with a block under the view ray the player starts using the item (use duration 200); the result is CONSUME either way.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-HIT                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-STARTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-STARTED.
     MOVE 0 TO L-STARTED
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     IF PSB-HAND NOT = 0 OR PL-STATE(WS-ROW) NOT = PS-ALIVE OR MN-WINDOW(WS-ROW) NOT = 0
             OR PL-SLOT-COUNT(WS-ROW, WS-SLOT) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, WS-SLOT) WS-KEY
     IF WS-KEY NOT = "brush"
         GOBACK
     END-IF
     CALL "BRUSH-HIT" USING WS-ROW WS-HIT WS-X WS-Y WS-Z WS-FACE
     IF WS-HIT = 1
         MOVE 1 TO PL-BRUSH-ACTIVE(WS-ROW)
         MOVE PL-HELD(WS-ROW) TO PL-BRUSH-SLOT(WS-ROW)
         MOVE 0 TO PL-BRUSH-USED(WS-ROW)
         MOVE 1 TO L-STARTED
     END-IF
     GOBACK.
 END PROGRAM BRUSH-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRUSH-TICK.
*> USING player row of an alive player: BrushItem.onUseTick (25 part 8 section 7 item 3) for a player using the brush: another held slot, a stack that is not the
*> brush, an open window or a view ray that misses every block releases the item; the used tick count rises (the first call is 1: elapsed = 200 - remaining + 1), more
*> than 201 releases it, and a tick whose elapsed time modulo 10 is 5 runs the brushing step on the block under the ray.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-REMAINING           BINARY-LONG.
 01 WS-BRUSH               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF PL-BRUSH-ACTIVE(L-ROW) = 0
         GOBACK
     END-IF
     COMPUTE WS-SLOT = PL-BRUSH-SLOT(L-ROW) + 1
     MOVE SPACES TO WS-KEY
     IF PL-HELD(L-ROW) = PL-BRUSH-SLOT(L-ROW) AND PL-SLOT-COUNT(L-ROW, WS-SLOT) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, WS-SLOT) WS-KEY
     END-IF
     IF WS-KEY NOT = "brush" OR MN-WINDOW(L-ROW) NOT = 0
         MOVE 0 TO PL-BRUSH-ACTIVE(L-ROW)
         GOBACK
     END-IF
     ADD 1 TO PL-BRUSH-USED(L-ROW)
     COMPUTE WS-REMAINING = 200 - PL-BRUSH-USED(L-ROW) + 1
     IF WS-REMAINING < 0
         MOVE 0 TO PL-BRUSH-ACTIVE(L-ROW)
         GOBACK
     END-IF
     CALL "BRUSH-HIT" USING L-ROW WS-HIT WS-X WS-Y WS-Z WS-FACE
     IF WS-HIT = 0
         MOVE 0 TO PL-BRUSH-ACTIVE(L-ROW)
         GOBACK
     END-IF
     CALL "TOOL-BRUSH-TICK" USING WS-REMAINING WS-BRUSH
     IF WS-BRUSH = 1
         CALL "BRUSH-STEP" USING L-ROW WS-X WS-Y WS-Z WS-FACE
     END-IF
     GOBACK.
 END PROGRAM BRUSH-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRUSH-SOUND.
*> USING dimension row, x, y, z (the block), sound event key (PIC X(48), with namespace): a Sound Effect (0x77) at the block centre, source blocks, volume 1.0
*> and pitch 1.0 (the four-argument Level.playSound overload, 31-4 section 7.4), to every player who has the chunk in view.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 119.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:sound_event".
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG VALUE 4.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-VOLUME              FLOAT-SHORT VALUE 1.0.
 01 WS-PITCH               FLOAT-SHORT VALUE 1.0.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SOUND                PIC X(48).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SOUND.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE L-SOUND TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     COMPUTE WS-HOLDER = WS-ID + 1
     COMPUTE WS-FX = L-X * 8 + 4
     COMPUTE WS-FY = L-Y * 8 + 4
     COMPUTE WS-FZ = L-Z * 8 + 4
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SOURCE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FY
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FZ
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-VOLUME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PITCH
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED
     CALL "VIEWERS-SEND" USING L-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
     GOBACK.
 END PROGRAM BRUSH-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRUSH-STEP.
*> USING player row, x, y, z (the block under the ray), face (legacy direction id): the brushing event of 25 part 8 section 7 item 3.4: the sound of the block
*> (a brushable block's own, else item.brush.brushing.generic), the dust particles (7.1: nextInt(7, 12) block particles of the block's state at the hit face),
*> and for a brushable block entity the brush (31-4 section 7.4) with its results: a completion (BRUSH-COMPLETE) wears the brush by 1, a counted brush
*> schedules the 2-tick block tick and a new dusted value is set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CBLOCKS.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-GRAVEL              BINARY-LONG.
 01 WS-SOUND               PIC X(48).
 01 WS-INDEX               BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-STEP-X              BINARY-LONG.
 01 WS-STEP-Y              BINARY-LONG.
 01 WS-STEP-Z              BINARY-LONG.
 01 WS-ANY-A               BINARY-LONG.
 01 WS-ANY-Y               BINARY-LONG.
 01 WS-ANY-C               BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG VALUE 1.
 01 WS-OVERRIDE            BINARY-LONG VALUE 0.
 01 WS-ALWAYS              BINARY-LONG VALUE 0.
 01 WS-RANDOM              BINARY-LONG VALUE 0.
 01 WS-SPREAD-TABLE.
    05 WS-SPREAD           FLOAT-SHORT OCCURS 6 TIMES.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-COMPLETED           BINARY-LONG.
 01 WS-SCHEDULE            BINARY-LONG.
 01 WS-DUSTED              BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-TICK-TYPE           BINARY-LONG VALUE 1.
 01 WS-NORMAL              BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 2.
 01 WS-RESULT              BINARY-LONG.
 01 WS-BROKE               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FACE.
     MOVE PL-DIM(L-ROW) TO WS-DIM
     CALL "WORLD-GET-BLOCK" USING WS-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "BE-BLOCK-TYPE" USING WS-BLOCK WS-TYPE
     MOVE "minecraft:item.brush.brushing.generic" TO WS-SOUND
     IF WS-TYPE = 40
         MOVE 0 TO WS-GRAVEL
         INSPECT CB-KEY(WS-BLOCK + 1) TALLYING WS-GRAVEL FOR ALL "gravel"
         MOVE "minecraft:item.brush.brushing.sand" TO WS-SOUND
         IF WS-GRAVEL > 0
             MOVE "minecraft:item.brush.brushing.gravel" TO WS-SOUND
         END-IF
     END-IF
     CALL "BRUSH-SOUND" USING WS-DIM L-X L-Y L-Z WS-SOUND
*>   The dust: 7 to 11 block particles at the hit face of the block.
     CALL "IP-LEVEL-DOUBLE" USING WS-D
     COMPUTE WS-COUNT = 7 + FUNCTION INTEGER(WS-D * 5)
     CALL "BE4-DIR-INFO" USING L-FACE WS-ANY-A WS-ANY-Y WS-ANY-C WS-STEP-X WS-STEP-Y WS-STEP-Z
     COMPUTE WS-PX = L-X + 0.5 + WS-STEP-X * 0.5
     COMPUTE WS-PY = L-Y + 0.5 + WS-STEP-Y * 0.5
     COMPUTE WS-PZ = L-Z + 0.5 + WS-STEP-Z * 0.5
     MOVE 0.25 TO WS-SPREAD(1) WS-SPREAD(2) WS-SPREAD(3)
     MOVE 0.05 TO WS-SPREAD(4) WS-SPREAD(5) WS-SPREAD(6)
     CALL "PARTICLE-SEND" USING WS-DIM WS-PTYPE WS-STATE WS-OVERRIDE WS-ALWAYS WS-PX WS-PY WS-PZ
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     IF WS-TYPE NOT = 40
         GOBACK
     END-IF
     CALL "BE-FIND" USING WS-DIM L-X L-Y L-Z WS-INDEX
     IF WS-INDEX = 0
         GOBACK
     END-IF
     MOVE BE-XI(WS-INDEX, 1) TO WS-BEFORE
     MOVE CW-TICKS TO WS-TIME
     CALL "BE4-BRUSH" USING WS-INDEX WS-TIME L-FACE WS-COMPLETED WS-SCHEDULE WS-DUSTED WS-CHANGED
*>   A brush the cooldown rejected counted nothing and rolls nothing (7.4 step 3 returns before step 5).
     IF BE-XI(WS-INDEX, 1) = WS-BEFORE
         GOBACK
     END-IF
     IF WS-COMPLETED = 1
         CALL "BRUSH-COMPLETE" USING L-ROW WS-INDEX WS-DIM L-X L-Y L-Z
         CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) PL-BRUSH-SLOT(L-ROW) WS-ONE WS-BROKE
         GOBACK
     END-IF
     CALL "BRUSH-UNPACK" USING WS-INDEX L-ROW
     CALL "BT-SCHEDULE" USING WS-DIM WS-TICK-TYPE WS-BLOCK L-X L-Y L-Z WS-DELAY WS-NORMAL WS-RESULT
     IF WS-CHANGED = 1
         CALL "BRUSH-DUSTED-SET" USING WS-DIM L-X L-Y L-Z WS-DUSTED
     END-IF
     GOBACK.
 END PROGRAM BRUSH-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRUSH-UNPACK.
*> USING block entity index, player row (0 none): BrushableBlockEntity.unpackLootTable (31-4 section 7.5): nothing without a loot table; else the table is rolled
*> in the archaeology parameter set (origin the block centre, this_entity the brusher, tool the brush in use, luck 0, seed the entity's seed) and the first stack
*> of the result (at most one is expected) becomes the buried item (an empty result leaves it empty); the table key is cleared.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY LOOTCTX.
 01 WS-TABLE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ROW.
     CALL "BE-LOOT-UNPACK" USING L-INDEX WS-TABLE WS-LENGTH WS-SEED WS-RESULT
     IF WS-RESULT = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE WS-TABLE(1:WS-LENGTH) TO WS-KEY
     INITIALIZE LOOT-CONTEXT
     MOVE 1 TO LC-ORIGIN-SET
     COMPUTE LC-X = BE-X(L-INDEX) + 0.5
     COMPUTE LC-Y = BE-Y(L-INDEX) + 0.5
     COMPUTE LC-Z = BE-Z(L-INDEX) + 0.5
     IF L-ROW > 0
         MOVE 1 TO LC-THIS-SET
         MOVE "minecraft:player" TO LC-THIS-TYPE
         COMPUTE WS-SLOT = PL-BRUSH-SLOT(L-ROW) + 1
         MOVE 1 TO LC-TOOL-SET
         MOVE PL-SLOT-ITEM(L-ROW, WS-SLOT) TO LC-TOOL-ITEM
         MOVE PL-SLOT-COUNT(L-ROW, WS-SLOT) TO LC-TOOL-COUNT
         MOVE PL-SLOT-VAR(L-ROW, WS-SLOT) TO LC-TOOL-HANDLE
     END-IF
     MOVE WS-SEED TO LC-SEED
     MOVE CW-SEED TO LC-WORLD-SEED
     CALL "LOOT-ROLL" USING WS-KEY LOOT-CONTEXT LOOT-RESULT
     MOVE 0 TO BE-SLOT-ITEM(L-INDEX, 1) BE-SLOT-COUNT(L-INDEX, 1) BE-SLOT-VAR(L-INDEX, 1)
     IF LR-STATUS = 0 AND LR-COUNT > 0
         MOVE LR-ITEM(1) TO BE-SLOT-ITEM(L-INDEX, 1)
         MOVE LR-AMOUNT(1) TO BE-SLOT-COUNT(L-INDEX, 1)
         MOVE LR-HANDLE(1) TO BE-SLOT-VAR(L-INDEX, 1)
     END-IF
     CALL "BE-MARK-CHUNK" USING L-INDEX
     GOBACK.
 END PROGRAM BRUSH-UNPACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRUSH-DUSTED-SET.
*> USING dimension row, x, y, z, dusted (0 to 3): the block's state with its dusted value set (setBlockAndUpdate: Block Update to the viewers).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24) VALUE "dusted".
 01 WS-TEXT                PIC X(32).
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DUSTED               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DUSTED.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE L-DUSTED TO WS-DIGIT
     MOVE SPACES TO WS-TEXT
     MOVE WS-DIGIT TO WS-TEXT(1:1)
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-NEW
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-NEW
     GOBACK.
 END PROGRAM BRUSH-DUSTED-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRUSH-COMPLETE.
*> USING player row, block entity index, dimension row, x, y, z: brushingCompleted and dropContent (31-4 section 7.7): the loot is unpacked once more, the buried item
*> is split to nextInt(21) + 10 at most and spawned at the centre of the cell on the brushed face (0.625 up, no motion, no pickup delay), level event 3008 carries
*> the block's current state id, and the block becomes the default state of the block it turns into (suspicious sand: sand, suspicious gravel: gravel).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CBLOCKS.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-ZERO-V              FLOAT-LONG VALUE 0.
 01 WS-ZERO-W              FLOAT-LONG VALUE 0.
 01 WS-ZERO-U              FLOAT-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 3008.
 01 WS-NO-PLAYER           BINARY-LONG VALUE 0.
 01 WS-BEFORE-SUSP         PIC X(48).
 01 WS-AFTER-SUSP          PIC X(48).
 01 WS-LONG-KEY            PIC X(112).
 01 WS-NEW-ID              BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-NEW-STATE           BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-INDEX L-DIM L-X L-Y L-Z.
     CALL "BRUSH-UNPACK" USING L-INDEX L-ROW
     IF BE-SLOT-COUNT(L-INDEX, 1) > 0
         CALL "BE4-BRUSH-DROP-POS" USING L-X L-Y L-Z BE-XI(L-INDEX, 4) WS-PX WS-PY WS-PZ
         CALL "IP-LEVEL-DOUBLE" USING WS-D
         COMPUTE WS-CHUNK = 10 + FUNCTION INTEGER(WS-D * 21)
         IF WS-CHUNK > BE-SLOT-COUNT(L-INDEX, 1)
             MOVE BE-SLOT-COUNT(L-INDEX, 1) TO WS-CHUNK
         END-IF
         CALL "GI-SPAWN-X" USING L-DIM WS-PX WS-PY WS-PZ WS-ZERO-V WS-ZERO-W WS-ZERO-U BE-SLOT-ITEM(L-INDEX, 1) WS-CHUNK
             WS-DELAY WS-ITEM-ROW BE-SLOT-VAR(L-INDEX, 1)
         MOVE 0 TO BE-SLOT-ITEM(L-INDEX, 1) BE-SLOT-COUNT(L-INDEX, 1) BE-SLOT-VAR(L-INDEX, 1)
         CALL "BE-MARK-CHUNK" USING L-INDEX
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "LEVEL-EVENT" USING L-DIM WS-EVENT L-X L-Y L-Z WS-STATE WS-NO-PLAYER
*>   turnsInto: the block's key without the "suspicious_" prefix.
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     MOVE SPACES TO WS-BEFORE-SUSP WS-AFTER-SUSP
     UNSTRING CB-KEY(WS-BLOCK + 1) DELIMITED BY "suspicious_" INTO WS-BEFORE-SUSP WS-AFTER-SUSP
     MOVE SPACES TO WS-LONG-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-AFTER-SUSP) DELIMITED BY SIZE INTO WS-LONG-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-LONG-KEY WS-NEW-ID WS-ROW-TEXT WS-STATUS
     MOVE 0 TO WS-NEW-STATE
     IF WS-STATUS = 0
         MOVE CB-DEFAULT-STATE(WS-NEW-ID + 1) TO WS-NEW-STATE
     END-IF
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-NEW-STATE
     GOBACK.
 END PROGRAM BRUSH-COMPLETE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRUSH-BLOCK-TICK.
*> USING dimension row, x, y, z: the scheduled block tick of a suspicious sand or gravel block (BU-HOOK effect 11; 31-4 section 7.6 and 29b part 1 section 3.5 ST): checkReset
*> (progress decays by 2 every 4 ticks from 40 ticks after the last brush, the dusted value follows, another 2-tick tick is scheduled while progress remains), then,
*> when the cell below is free, the block falls as a falling block entity with cancelDrop.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 01 WS-INDEX               BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-DUSTED              BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-SCHEDULE            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TICK-TYPE           BINARY-LONG VALUE 1.
 01 WS-NORMAL              BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 2.
 01 WS-RESULT              BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-FALLS               BINARY-LONG.
 01 WS-FALL-ROW            BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
     IF WS-INDEX > 0
         MOVE CW-TICKS TO WS-TIME
         CALL "BE4-BRUSH-RESET" USING WS-INDEX WS-TIME WS-DUSTED WS-CHANGED WS-SCHEDULE
         IF WS-CHANGED = 1
             CALL "BRUSH-DUSTED-SET" USING L-DIM L-X L-Y L-Z WS-DUSTED
         END-IF
         IF WS-SCHEDULE = 2
             CALL "BT-SCHEDULE" USING L-DIM WS-TICK-TYPE WS-BLOCK L-X L-Y L-Z WS-DELAY WS-NORMAL WS-RESULT
         END-IF
     END-IF
     COMPUTE WS-BELOW = L-Y - 1
     MOVE 0 TO WS-FREE
     IF WS-BELOW >= DM-MIN-Y(L-DIM)
         CALL "FLUID-CELL" USING L-DIM L-X WS-BELOW L-Z WS-STATE2 WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         MOVE WS-HOLDS TO WS-FREE
     END-IF
     CALL "GB-FALL-DECIDE" USING WS-FREE L-Y DM-MIN-Y(L-DIM) WS-FALLS
     IF WS-FALLS = 1
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
         CALL "FB-SPAWN" USING L-DIM L-X L-Y L-Z WS-STATE WS-FALL-ROW
         MOVE 1 TO EN-FB-CANCEL(WS-FALL-ROW)
     END-IF
     GOBACK.
 END PROGRAM BRUSH-BLOCK-TICK.
