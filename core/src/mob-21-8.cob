*> Non-mob entities of document 21 section 8 (002-lane-mobsfull-h22). Implemented: 8.3 primed TNT. Everything else of section 8 (falling blocks, area effect clouds,
*> lightning, fireworks, boats and minecarts, eye of ender, thrown bottles, llama spit, leash knots, ...) is open, see specs/002-client-polish/tasks.md.
*>
*> Primed TNT (8.3): a tracker row of the standard entity type tnt (0.98 x 0.98). EN-SWELL holds the fuse (80 at the start; the field is the creeper's counter and unused by this
*> type). Created by TNT-IGNITE (flint and steel or a fire charge on a TNT block: the block becomes air) with the velocity (-sin a x 0.02, 0.2, -cos a x 0.02) for a random angle a.
*> Each tick (TNT-TICK -> TNT-STEP): gravity 0.04 on the vertical speed, the move, the drag 0.98 on all three speeds, on the ground (0.7, -0.5, 0.7) of the speed, then
*> the fuse falls by 1; at 0 the entity is removed and, with the game rule tnt_explodes, an explosion of power 4 happens at (x, y + 0.0625, z) destroying blocks (EXPLODE-RUN).
*> Approximations (open): the move tests the entity box per axis against solid cells (no stepping or friction of the block below: the drag stays 0.98 on all axes, no block
*> friction), no portals, fluids or Set Entity Data (the client counts the default fuse of 80 itself), chain ignition by other explosions, fire or redstone, the
*> explosion_power NBT key, saving (a primed TNT is not saved) and the TNT interaction's own block decay rule.
*>
*> Entry points:
*>   TNT-PRIME USING dim, x, y, z (FLOAT-LONG), row out        a primed TNT at the position with fuse 80 and the random start velocity
*>   TNT-IGNITE USING dim, block x, y, z (BINARY-LONG)         the block becomes air and a TNT is primed at its bottom centre
*>   TNT-STEP USING row                                        one tick of a primed TNT
*>   TNT-TICK                                                  every primed TNT (CORE-TICK, after the projectiles)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-PRIME-FUSE.
*> USING dim, x, y, z (FLOAT-LONG), fuse (BINARY-LONG), row out: TNT-PRIME with a given fuse (30 part 7 section 8.2 step 4, 8.5: the literal 2 pi of the float and 0.2f widened).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260803.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:tnt".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-FUSE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FUSE L-ROW.
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     MOVE WS-TYPE TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW)
     CALL "XORO-NEXT-DOUBLE" USING WS-STATE WS-D
     COMPUTE WS-A = WS-D * 6.2831854820251465
     COMPUTE EN-VX(WS-ROW) = 0 - FUNCTION SIN(WS-A) * 0.02
     MOVE 0.20000000298023224 TO EN-VY(WS-ROW)
     COMPUTE EN-VZ(WS-ROW) = 0 - FUNCTION COS(WS-A) * 0.02
     MOVE 0 TO EN-ON-GROUND(WS-ROW)
     MOVE L-FUSE TO EN-SWELL(WS-ROW)
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM TNT-PRIME-FUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-PRIME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FUSE                BINARY-LONG VALUE 80.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     CALL "TNT-PRIME-FUSE" USING L-DIM L-X L-Y L-Z WS-FUSE L-ROW
     GOBACK.
 END PROGRAM TNT-PRIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-TYPE.
*> USING type out (BINARY-LONG): the entity type id of minecraft:tnt (0 when the set has none: an unknown key is id 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:tnt".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY L-TYPE WS-ENTITY-ROW WS-STATUS
     GOBACK.
 END PROGRAM TNT-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SET-ENTITY-DATA-FUSE-BUILD.
*> USING entity id, fuse (BINARY-LONG), PB-BUFFER: Set Entity Data 0x65 of a primed TNT: entry 8 (the fuse, VarInt; 21 section 8.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-FUSE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-FUSE PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE 8 TO MD-MD-INDEX
     MOVE MD-MDS-INT TO MD-MD-SERIALIZER
     MOVE L-FUSE TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM SET-ENTITY-DATA-FUSE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-BLOCK-IS.
*> USING block state, is out (BINARY-LONG): 1 when the state is a minecraft:tnt block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FULL                PIC X(48).
 01 WS-KEY48               PIC X(48).
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-IS                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-IS.
     MOVE 0 TO L-IS
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     MOVE CB-KEY(WS-BLOCK + 1) TO WS-KEY48
     CALL "KEY-NAMESPACED" USING WS-KEY48 WS-FULL
     IF WS-FULL = "minecraft:tnt"
         MOVE 1 TO L-IS
     END-IF
     GOBACK.
 END PROGRAM TNT-BLOCK-IS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-CENTRE.
*> USING y in, y out (FLOAT-LONG): the explosion centre of a primed TNT at y: y + 0.0625 x 0.98f (0.9800000190734863, 30 part 7 section 8.5) = y + 0.0612500011920929.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-OUT.
     COMPUTE L-OUT = L-Y + 0.0612500011920929
     GOBACK.
 END PROGRAM TNT-CENTRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-WAS-EXPLODED.
*> USING dim, block x, y, z (BINARY-LONG): TntBlock.wasExploded (30 part 7 section 8.3): with the rule tnt_explodes a primed TNT appears at the block centre with the fuse
*> nextInt(20) + 10 (getRandomShortFuse of 80); no sound, no drop (the caller skips the drops of the block).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-SALT                BINARY-LONG VALUE 21.
 01 WS-BOUND               BINARY-LONG VALUE 20.
 01 WS-R                   BINARY-LONG.
 01 WS-FUSE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EV-PRIME            PIC X(32) VALUE "prime_fuse".
 01 WS-NO-SOURCE           BINARY-LONG VALUE 0.
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE NOT = 0
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
         COMPUTE WS-FUSE = WS-R + 10
         COMPUTE WS-X = L-X + 0.5
         MOVE L-Y TO WS-Y
         COMPUTE WS-Z = L-Z + 0.5
         CALL "TNT-PRIME-FUSE" USING L-DIM WS-X WS-Y WS-Z WS-FUSE WS-ROW
*>       An explosion chain primes the block with no igniter: prime_fuse at the block centre with no source (30-8 14.3.1 and 14.3.10)
         CALL "GAME-EVENT-CELL" USING L-DIM L-X L-Y L-Z WS-EV-PRIME WS-NO-SOURCE WS-NO-STATE
     END-IF
     GOBACK.
 END PROGRAM TNT-WAS-EXPLODED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-DISPENSE.
*> USING dim, front block x, y, z (BINARY-LONG), success out (BINARY-LONG): the dispenser's TNT behaviour (44 x2 section 4.10): with tnt_explodes false nothing happens (success 0); else a
*> primed TNT without igniter appears at (x + 0.5, y, z + 0.5) (success 1). The dispenser takes the item itself; the sulfur cube step is not in this world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE NOT = 0
         COMPUTE WS-X = L-X + 0.5
         MOVE L-Y TO WS-Y
         COMPUTE WS-Z = L-Z + 0.5
         CALL "TNT-PRIME" USING L-DIM WS-X WS-Y WS-Z WS-ROW
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM TNT-DISPENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-IGNITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NO-IGNITER          BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "TNT-IGNITE-BY" USING L-DIM L-X L-Y L-Z WS-NO-IGNITER
     GOBACK.
 END PROGRAM TNT-IGNITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-IGNITE-BY.
*> USING dim, block x, y, z, igniter entity row (0 none): TntBlock.prime: the block becomes air, a TNT is primed at its bottom centre and prime_fuse is posted at the block centre with the igniter as the source (30-8 14.3.10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EV-PRIME            PIC X(32) VALUE "prime_fuse".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-IGNITER              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-IGNITER.
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-AIR
     COMPUTE WS-X = L-X + 0.5
     MOVE L-Y TO WS-Y
     COMPUTE WS-Z = L-Z + 0.5
     CALL "TNT-PRIME" USING L-DIM WS-X WS-Y WS-Z WS-ROW
     CALL "GAME-EVENT-CELL" USING L-DIM L-X L-Y L-Z WS-EV-PRIME L-IGNITER WS-NO-STATE
     GOBACK.
 END PROGRAM TNT-IGNITE-BY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-TOP-Y               FLOAT-LONG.
 01 WS-SURF                FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 4.
 01 WS-DESTROY             BINARY-LONG VALUE 1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-TNT-SOURCE          BINARY-LONG VALUE -1.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-TYPE(L-ROW) TO WS-TYPE
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.04
     MOVE 0 TO EN-ON-GROUND(L-ROW)
     COMPUTE WS-X = EN-X(L-ROW) + EN-VX(L-ROW)
     CALL "ENTITY-BOX-SURFACE" USING WS-DIM WS-TYPE WS-X EN-Y(L-ROW) EN-Z(L-ROW) WS-HIT WS-SURF
     IF WS-HIT = 1
         MOVE EN-X(L-ROW) TO WS-X
         MOVE 0 TO EN-VX(L-ROW)
     END-IF
     COMPUTE WS-Z = EN-Z(L-ROW) + EN-VZ(L-ROW)
     CALL "ENTITY-BOX-SURFACE" USING WS-DIM WS-TYPE WS-X EN-Y(L-ROW) WS-Z WS-HIT WS-SURF
     IF WS-HIT = 1
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE 0 TO EN-VZ(L-ROW)
     END-IF
     COMPUTE WS-Y = EN-Y(L-ROW) + EN-VY(L-ROW)
     CALL "ENTITY-BOX-HITS-Y" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-HIT WS-TOP WS-TOP-Y
     IF WS-HIT = 1
         IF EN-VY(L-ROW) < 0
             MOVE 1 TO EN-ON-GROUND(L-ROW)
             MOVE WS-TOP-Y TO WS-Y
         ELSE
             MOVE EN-Y(L-ROW) TO WS-Y
         END-IF
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.7
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.7
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * -0.5
     END-IF
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.98
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.98
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.98
     CALL "IP-ENSURE" USING L-ROW
     CALL "GI-SEND-MOVE" USING L-ROW WS-X WS-Y WS-Z
     SUBTRACT 1 FROM EN-SWELL(L-ROW)
     IF EN-SWELL(L-ROW) <= 0
         MOVE EN-X(L-ROW) TO WS-X
         CALL "TNT-CENTRE" USING EN-Y(L-ROW) WS-Y
         MOVE EN-Z(L-ROW) TO WS-Z
         CALL "ENTITY-REMOVE" USING L-ROW
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
         IF WS-RULE NOT = 0
             CALL "EXPLODE-RUN" USING WS-DIM WS-X WS-Y WS-Z WS-POWER WS-DESTROY WS-TNT-SOURCE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TNT-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:tnt".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     IF WS-STATUS NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE
             CALL "TNT-STEP" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TNT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-TYPE.
*> USING type out (BINARY-LONG): the entity type id of minecraft:falling_block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:falling_block".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY L-TYPE WS-ENTITY-ROW WS-STATUS
     GOBACK.
 END PROGRAM FB-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-SPAWN.
*> USING dim, block x, y, z, state (BINARY-LONG), row out: FallingBlockEntity.fall (29b part 1 section 4.1): a falling_block entity at (x + 0.5, y, z + 0.5) with zero velocity
*> carrying the state (the Add Entity Data), the block's cell replaced by air (flags 3), the entity announced to its viewers. (The waterlogged water of a state is not left behind: open.)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-ROW.
     CALL "FB-TYPE" USING WS-TYPE
     CALL "ENTITY-ALLOC" USING L-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(L-ROW)
     MOVE WS-TYPE TO EN-TYPE(L-ROW)
     CALL "ENTITY-SET-UUID" USING L-ROW
     MOVE L-DIM TO EN-DIM(L-ROW)
     COMPUTE EN-X(L-ROW) = L-X + 0.5
     MOVE L-Y TO EN-Y(L-ROW)
     COMPUTE EN-Z(L-ROW) = L-Z + 0.5
     MOVE L-STATE TO EN-FB-STATE(L-ROW)
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-AIR WS-FLAGS WS-BUDGET WS-RESULT
     CALL "ENTITY-TRACK" USING L-ROW
     GOBACK.
 END PROGRAM FB-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-CELL-FREE.
*> USING dimension row, x, y, z (BINARY-LONG), replaceable out, free out: the two questions a falling block asks of a cell (29b part 1 sections 3.1 and 4.3). Replaceable is
*> BlockState.canBeReplaced (the registry flag, 24 part 1 section 10.1: air, short grass, water, lava, fire, snow ... and not a torch, a flower or a slab); a liquid block counts too.
*> Free is FallingBlock.isFree: air, fire (the block tag fire: fire and soul fire), a liquid block or a replaceable block. A cell that merely has no collision (a torch) is neither.
*> Snow layers override the context rule (24 part 3 section 7, snow): without a snow item in hand a snow layer is replaceable only when layers is 1, so the replaceable answer of a
*> deeper layer is false while isFree (the flag alone) stays true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-LAYERS-NAME         PIC X(24) VALUE "layers".
 01 WS-LAYERS              PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-WATER-FIRST         BINARY-LONG.
 01 WS-LAVA-FIRST          BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-LIQUID              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-REPLACEABLE          BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-REPLACEABLE L-FREE.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     CALL "FLUID-ROLES" USING WS-WATER WS-LAVA WS-WATER-FIRST WS-LAVA-FIRST
     MOVE 0 TO WS-AIR WS-FIRE WS-LIQUID
     IF WS-STATE = 0
         MOVE 1 TO WS-AIR
     END-IF
     IF CB-KEY(WS-BLOCK) = "fire" OR CB-KEY(WS-BLOCK) = "soul_fire" OR CB-KEY(WS-BLOCK) = "minecraft:fire" OR CB-KEY(WS-BLOCK) = "minecraft:soul_fire"
         MOVE 1 TO WS-FIRE
     END-IF
     IF WS-WATER >= 0 AND WS-BLOCK = WS-WATER + 1
         MOVE 1 TO WS-LIQUID
     END-IF
     IF WS-LAVA >= 0 AND WS-BLOCK = WS-LAVA + 1
         MOVE 1 TO WS-LIQUID
     END-IF
     MOVE 0 TO L-REPLACEABLE
     IF WS-AIR = 1 OR WS-LIQUID = 1 OR CB-REPLACEABLE(WS-BLOCK) = 1
         MOVE 1 TO L-REPLACEABLE
     END-IF
     CALL "GB-IS-FREE" USING WS-AIR WS-FIRE WS-LIQUID L-REPLACEABLE L-FREE
     IF CB-KEY(WS-BLOCK) = "snow" OR CB-KEY(WS-BLOCK) = "minecraft:snow"
         CALL "PS-GET" USING WS-STATE WS-LAYERS-NAME WS-LAYERS WS-FOUND
         IF WS-LAYERS NOT = "1"
             MOVE 0 TO L-REPLACEABLE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FB-CELL-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-DROP-ITEM.
*> USING row: spawnAtLocation of the block's item (29b part 1 section 4.5): one item of the falling block's block at the entity's position, offset 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-FULL                PIC X(48).
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ONE-B               BINARY-LONG VALUE 1.
 01 WS-ZERO-D              FLOAT-LONG VALUE 0.
 01 WS-ZERO-E              FLOAT-LONG VALUE 0.
 01 WS-ZERO-F              FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE CB-S-BLOCK(EN-FB-STATE(L-ROW) + 1) TO WS-BLOCK
     MOVE CB-KEY(WS-BLOCK + 1) TO WS-KEY48
     CALL "KEY-NAMESPACED" USING WS-KEY48 WS-FULL
     MOVE WS-FULL TO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "GI-SPAWN" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-ZERO-D WS-ZERO-E WS-ZERO-F
         WS-ITEM WS-ONE WS-ONE-B WS-ITEM-ENTITY
     GOBACK.
 END PROGRAM FB-DROP-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-BOX-HITS.
*> USING dimension row, entity type (BINARY-LONG), x, y, z (FLOAT-LONG entity position), hit out (BINARY-LONG), top out (FLOAT-LONG): the collision of a falling block against the
*> collision SHAPES of the cells (docs/protocol/51-block-shapes.md, the tables of BSH-BUILD; the stand-in set's blocks are full cubes by CB-SOLID), not against whole cells: hit is 1 when
*> the entity's box at that position overlaps a box of a shape with positive volume, faces within 1e-7 block touching; top is then the highest top of the boxes it overlaps, as a y
*> coordinate (a lantern 9 pixels high gives cell + 0.5625, a full block cell + 1). The cell below the box is scanned too (a fence's shape reaches 1.5 blocks high). A block without a
*> collision shape (a torch, a sign, a flower) never hits, so the entity passes into its cell (29b part 1 section 4.2 steps 2 and 4: the landing cell is the one the entity ends in).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY CTBSHAPE.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-OVER                FLOAT-LONG.
 01 WS-CELL                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-BOX.
    05 WS-B                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 01 L-TOP                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-X L-Y L-Z L-HIT L-TOP.
     MOVE 0 TO L-HIT L-TOP
     COMPUTE WS-HALF = ET-WIDTH-MILLI(L-TYPE + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(L-TYPE + 1) / 1000
     COMPUTE WS-X0 = FUNCTION INTEGER(L-X - WS-HALF + WS-EPSILON)
     COMPUTE WS-X1 = - FUNCTION INTEGER(WS-EPSILON - (L-X + WS-HALF)) - 1
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y + WS-EPSILON) - 1
     COMPUTE WS-Y1 = - FUNCTION INTEGER(WS-EPSILON - (L-Y + WS-HEIGHT)) - 1
     COMPUTE WS-Z0 = FUNCTION INTEGER(L-Z - WS-HALF + WS-EPSILON)
     COMPUTE WS-Z1 = - FUNCTION INTEGER(WS-EPSILON - (L-Z + WS-HALF)) - 1
     COMPUTE WS-B(1) = L-X - WS-HALF
     MOVE L-Y TO WS-B(2)
     COMPUTE WS-B(3) = L-Z - WS-HALF
     COMPUTE WS-B(4) = L-X + WS-HALF
     COMPUTE WS-B(5) = L-Y + WS-HEIGHT
     COMPUTE WS-B(6) = L-Z + WS-HALF
     PERFORM VARYING WS-BY FROM WS-Y0 BY 1 UNTIL WS-BY > WS-Y1
         PERFORM VARYING WS-BZ FROM WS-Z0 BY 1 UNTIL WS-BZ > WS-Z1
             PERFORM VARYING WS-BX FROM WS-X0 BY 1 UNTIL WS-BX > WS-X1
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-BX WS-BY WS-BZ WS-STATE
                 MOVE 0 TO WS-SHAPE
                 IF WS-STATE NOT = 0
*>                   The cobolcraft stand-in set has no shapes: its states are full cubes or empty by CB-SOLID (as movement.cob).
                     IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
                         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLK
                         MOVE CB-SOLID(WS-BLK + 1) TO WS-SHAPE
                         IF WS-SHAPE = 1
                             CALL "BSH-ENSURE-CUBE"
                         END-IF
                     ELSE
                         CALL "BSH-COLL-ID" USING WS-STATE WS-SHAPE
                     END-IF
                 END-IF
                 MOVE WS-BX TO WS-CELL(1)
                 MOVE WS-BY TO WS-CELL(2)
                 MOVE WS-BZ TO WS-CELL(3)
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSH-N(WS-SHAPE + 1)
                     MOVE 1 TO WS-INSIDE
                     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                         COMPUTE WS-LO = WS-CELL(WS-A) + BSH-V(WS-SHAPE + 1, WS-I, WS-A) / 16000
                         COMPUTE WS-HI = WS-CELL(WS-A) + BSH-V(WS-SHAPE + 1, WS-I, WS-A + 3) / 16000
                         COMPUTE WS-OVER = FUNCTION MIN(WS-B(WS-A + 3), WS-HI) - FUNCTION MAX(WS-B(WS-A), WS-LO)
                         IF WS-OVER <= WS-EPSILON
                             MOVE 0 TO WS-INSIDE
                         END-IF
                     END-PERFORM
                     IF WS-INSIDE = 1
                         COMPUTE WS-HI = WS-BY + BSH-V(WS-SHAPE + 1, WS-I, 5) / 16000
                         IF L-HIT = 0 OR WS-HI > L-TOP
                             MOVE WS-HI TO L-TOP
                         END-IF
                         MOVE 1 TO L-HIT
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FB-BOX-HITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-STEP.
*> USING row: one server tick of a falling block (29b part 1 section 4.2): time + 1; gravity 0.04, the move (the box against solid cells per axis as TNT-STEP); on the ground
*> (4.3) the velocity takes (0.7, -0.5, 0.7) and, unless cancelDrop, the block is placed in the entity's cell (the cell is replaceable and the cell below is not free) and the entity ends; in the air
*> the expiry of 4.4 (time above 100 outside the height range, or above 600) drops the block's item with the rule entity_drops and ends the entity; the drag 0.98f follows.
*> The block is placed only when the block in the landing cell is replaceable (the registry flag: FB-CELL-FREE) and the cell below is not free; otherwise the entity ends and, with
*> the rule entity_drops, the block's item drops (4.3 step 6) while the block in the cell stays.
*> The move collides with the collision shapes of the cells (FB-BOX-HITS), so a block lands on top of a lantern or a carpet inside that cell, where the replace test refuses it.
*> Open: concrete powder reaching water, the damage to entities (anvils), Add Transient Block, block entity data.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 01 WS-RULE-NAME           PIC X(40) VALUE "entity_drops".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-HOLDS-B             BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-BELOW-FREE          BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-ACTION              BINARY-LONG.
 01 WS-WRITE               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-MAX-Y               BINARY-LONG.
 01 WS-EXPIRED             BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 01 WS-YES-B               BINARY-LONG VALUE 1.
 01 WS-ENDED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-TYPE(L-ROW) TO WS-TYPE
     ADD 1 TO EN-FB-TIME(L-ROW)
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.04
     MOVE 0 TO EN-ON-GROUND(L-ROW)
     COMPUTE WS-X = EN-X(L-ROW) + EN-VX(L-ROW)
     CALL "FB-BOX-HITS" USING WS-DIM WS-TYPE WS-X EN-Y(L-ROW) EN-Z(L-ROW) WS-HIT WS-SURF
     IF WS-HIT = 1
         MOVE EN-X(L-ROW) TO WS-X
         MOVE 0 TO EN-VX(L-ROW)
     END-IF
     COMPUTE WS-Z = EN-Z(L-ROW) + EN-VZ(L-ROW)
     CALL "FB-BOX-HITS" USING WS-DIM WS-TYPE WS-X EN-Y(L-ROW) WS-Z WS-HIT WS-SURF
     IF WS-HIT = 1
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE 0 TO EN-VZ(L-ROW)
     END-IF
     COMPUTE WS-Y = EN-Y(L-ROW) + EN-VY(L-ROW)
     CALL "FB-BOX-HITS" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-HIT WS-TOP
     IF WS-HIT = 1
         MOVE 1 TO EN-ON-GROUND(L-ROW)
         MOVE WS-TOP TO WS-Y
     END-IF
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-MIN-Y = DM-MIN-Y(WS-DIM)
     COMPUTE WS-MAX-Y = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM) - 1
     MOVE 0 TO WS-ENDED
     IF EN-ON-GROUND(L-ROW) = 1
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.7
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.7
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * -0.5
*>       canReplace: the block in the landing cell is replaceable (a torch, a flower, a slab is not); the cell below must not be free (29b part 1 section 4.3 steps 4 to 6).
         CALL "FB-CELL-FREE" USING WS-DIM WS-BX WS-BY WS-BZ WS-HOLDS WS-FREE
         COMPUTE WS-BELOW = WS-BY - 1
         CALL "FB-CELL-FREE" USING WS-DIM WS-BX WS-BELOW WS-BZ WS-HOLDS-B WS-BELOW-FREE
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
         MOVE WS-RULE TO WS-DROP
         MOVE 1 TO WS-WRITE
         CALL "GB-LAND" USING WS-NO EN-FB-CANCEL(L-ROW) WS-HOLDS WS-YES WS-BELOW-FREE WS-YES-B WS-DROP WS-WRITE WS-ACTION
         EVALUATE WS-ACTION
             WHEN 2
                 CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ EN-FB-STATE(L-ROW) WS-FLAGS WS-BUDGET WS-WRITE
             WHEN 5
*>               Cannot be placed: the falling block is discarded and its own item drops, the block in the cell stays (4.3 step 6, 4.5). The item appears at the entity's
*>               position after the move (the top of what it landed on), not where the tick began.
                 MOVE WS-X TO EN-X(L-ROW)
                 MOVE WS-Y TO EN-Y(L-ROW)
                 MOVE WS-Z TO EN-Z(L-ROW)
                 CALL "FB-DROP-ITEM" USING L-ROW
         END-EVALUATE
         MOVE 1 TO WS-ENDED
         CALL "ENTITY-REMOVE" USING L-ROW
     ELSE
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
         MOVE WS-RULE TO WS-DROP
         CALL "GB-EXPIRY" USING EN-FB-TIME(L-ROW) WS-BY WS-MIN-Y WS-MAX-Y WS-YES WS-DROP WS-EXPIRED WS-ITEM-ENTITY
         IF WS-EXPIRED = 1
             IF WS-ITEM-ENTITY = 1
                 CALL "FB-DROP-ITEM" USING L-ROW
             END-IF
             MOVE 1 TO WS-ENDED
             CALL "ENTITY-REMOVE" USING L-ROW
         END-IF
     END-IF
     IF WS-ENDED = 0
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.9800000190734863
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.9800000190734863
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.9800000190734863
         CALL "IP-ENSURE" USING L-ROW
         CALL "GI-SEND-MOVE" USING L-ROW WS-X WS-Y WS-Z
     END-IF
     GOBACK.
 END PROGRAM FB-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-TICK.
*> No parameters: FB-STEP of every falling block entity (CORE-TICK, after the primed TNT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-FB-STATE(WS-I) > 0
             CALL "FB-STEP" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FB-TICK.
