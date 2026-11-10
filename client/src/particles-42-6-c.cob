*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md) sections 3.4 and 3.5: `animateTick` of nature, fluid-like and portal
*> blocks, pointed dripstone. Dispatched by P6-BLOCK-TICK (particles-42-6-b.cob, which documents the draw and output conventions).
*> Sound-only branches (leaves, firefly bush, portals, dried ghast, respawn anchor, bubble column, potent sulfur) are not emitted: the
*> section gives no draw formula for them. `ri(1)` is not drawn (always 0).
*>
*> Entry points for the integrator (inputs): P6-BLOCK-TICK with these classes and PROPS (1-based; unlisted entries are ignored):
*>   leaves               1 raining at P above, 2 the block below can occlude and has a sturdy top
*>   falling_leaves       as leaves, 3 the block below has a full top face, 4 chance in ten-thousandths (0.01 is 100), 5 particle (0
*>                        tinted_leaves, 1 cherry_leaves, 2 pale_oak_leaves, 3 red_poplar_leaves, 4 orange_poplar_leaves, 5
*>                        yellow_poplar_leaves), 6 the colour int of tinted_leaves (stored as EM-COLOR)
*>   mycelium, end_portal, brewing_stand   none
*>   spore_blossom        1 bit mask of the 14 tries (bit k is set when the cell of try k+1 is a full collision block)
*>   firefly_bush         1 raw brightness at P
*>   wither_rose          1-2 centre x and z of the shape bounds in thousandths
*>   falling_block, brushable_block   1 the block below is free, 2 the block state (stored as EM-STATE)
*>   wet_sponge, crying_obsidian      1 the block can occlude, 2-7 the neighbour at down, up, north, south, west, east has a sturdy face
*>                        towards the block
*>   pointed_dripstone    1 free-hanging stalactite, 2 fluid above (0 empty, 1 water, 2 lava; see P6-FLUID-ABOVE), 3-4 offset x and z
*>                        in thousandths (an empty fluid emits default_dripstone_particle: the integrator resolves the attribute)
*>   nether_portal        1 a west or east neighbour is a portal block
*>   end_gateway          1 the number of rendered faces
*>   ender_chest          none; note_block 1 the instrument is tunable, 2 the note 0..24
*>   enchanting_table     1-2 validity of the 32 BOOKSHELF_OFFSETS (bit i of 1 + 65536 * 2 is entry i + 1)
*>   respawn_anchor       1 charge; beehive 1 honey level, 2 the hive has a fluid, 3 shape maximum y and 4 minimum y in thousandths, 5
*>                        impermeable, 6 the block below is open (collision max y below 1 or not a full block), 7 the block below has a fluid
*>   bubble_column        1 drag_down; potent_sulfur 1 not DRY and a water source above; dried_ghast 1 waterlogged
*>   P6-FLUID-ABOVE count root-found above-kind evaporates: fluid out (3.5)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-BELOW.
*> ParticleUtils.spawnParticleBelow: USING block, name (PIC X(32)), emits: draws x then z, emits at (X + rd, Y - 0.05, Z + rd).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-NAME                 PIC X(32).
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-NAME P6-EMITS.
     INITIALIZE WS-PV
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-V(1) = L-PP(1) + WS-R
     COMPUTE WS-V(2) = L-PP(2) - 0.05
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-V(3) = L-PP(3) + WS-R
     CALL "P6-EMIT" USING P6-EMITS L-NAME WS-PV
     GOBACK.
 END PROGRAM P6-BELOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-LEAVES.
*> 3.4 LeavesBlock: raining (PROPS 1): draw ri(15) == 1 and the block below is not (can occlude and sturdy top) (PROPS 2): `dripping_water` below.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "dripping_water".
 01 WS-R                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-I = FUNCTION INTEGER-PART(WS-R * 15)
         IF WS-I = 1 AND L-PR(2) = 0
             CALL "P6-BELOW" USING L-P WS-N P6-EMITS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-C-LEAVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-FALLING-LEAVES.
*> 3.4 FallingParticlesLeavesBlock: the leaves behaviour, then draw rf < chance (PROPS 4 / 10000) and the block below does not have a full top face
*> (PROPS 3): the leaf particle (PROPS 5) below; the tinted one carries the colour int PROPS 6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32).
 01 WS-R                   FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-COLOR               BINARY-DOUBLE.
 01 WS-ZERO-S              FLOAT-LONG VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     CALL "P6-C-LEAVES" USING L-P L-PROPS P6-EMITS
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-CHANCE = L-PR(4) / 10000
     IF WS-R < WS-CHANCE AND L-PR(3) = 0
         MOVE 0 TO WS-COLOR
         EVALUATE L-PR(5)
             WHEN 1
                 MOVE "cherry_leaves" TO WS-N
             WHEN 2
                 MOVE "pale_oak_leaves" TO WS-N
             WHEN 3
                 MOVE "red_poplar_leaves" TO WS-N
             WHEN 4
                 MOVE "orange_poplar_leaves" TO WS-N
             WHEN 5
                 MOVE "yellow_poplar_leaves" TO WS-N
             WHEN OTHER
                 MOVE "tinted_leaves" TO WS-N
                 MOVE L-PR(6) TO WS-COLOR
         END-EVALUATE
         CALL "P6-BELOW" USING L-P WS-N P6-EMITS
         CALL "P6-EMIT-OPTION" USING P6-EMITS WS-COLOR WS-ZERO-S WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM P6-C-FALLING-LEAVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-MYCELIUM.
*> 3.4 MyceliumBlock: draw ri(10) == 0, then `mycelium` at (X + rd, Y + 1.1, Z + rd) (draws x, z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "mycelium".
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF WS-R < 0.1
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(1) = L-PP(1) + WS-R
         COMPUTE WS-V(2) = L-PP(2) + 1.1
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(3) = L-PP(3) + WS-R
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF
     GOBACK.
 END PROGRAM P6-C-MYCELIUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-SPORE-BLOSSOM.
*> 3.4 SporeBlossomBlock: `falling_spore_blossom` at (X + rd, Y + 0.7, Z + rd); then 14 tries: draws ri(21) - 10 for x, ri(10) for y, ri(21) - 10 for z;
*> when the cell is not a full collision block (bit k of PROPS 1 clear): `spore_blossom_air` at (p + rd) per axis (draws x, y, z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N1                  PIC X(32) VALUE "falling_spore_blossom".
 01 WS-N2                  PIC X(32) VALUE "spore_blossom_air".
 01 WS-R                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MASK                BINARY-DOUBLE.
 01 WS-BIT                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     INITIALIZE WS-PV
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-V(1) = L-PP(1) + WS-R
     COMPUTE WS-V(2) = L-PP(2) + 0.7
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-V(3) = L-PP(3) + WS-R
     CALL "P6-EMIT" USING P6-EMITS WS-N1 WS-PV
     MOVE L-PR(1) TO WS-MASK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-DX = FUNCTION INTEGER-PART(WS-R * 21) - 10
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-DY = FUNCTION INTEGER-PART(WS-R * 10)
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-DZ = FUNCTION INTEGER-PART(WS-R * 21) - 10
         COMPUTE WS-BIT = FUNCTION MOD(WS-MASK, 2)
         COMPUTE WS-MASK = FUNCTION INTEGER-PART(WS-MASK / 2)
         IF WS-BIT = 0
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(1) = L-PP(1) + WS-DX + WS-R
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(2) = L-PP(2) - WS-DY + WS-R
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(3) = L-PP(3) + WS-DZ + WS-R
             CALL "P6-EMIT" USING P6-EMITS WS-N2 WS-PV
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P6-C-SPORE-BLOSSOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-FIREFLY-BUSH.
*> 3.4 FireflyBushBlock: raw brightness (PROPS 1) <= 13, then draw rd <= 0.7: `firefly` at (X + rd * 10 - 5, Y + rd * 5, Z + rd * 10 - 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "firefly".
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) <= 13
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R <= 0.7
             INITIALIZE WS-PV
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(1) = L-PP(1) + WS-R * 10 - 5
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(2) = L-PP(2) + WS-R * 5
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(3) = L-PP(3) + WS-R * 10 - 5
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-C-FIREFLY-BUSH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-WITHER-ROSE.
*> 3.4 WitherRoseBlock: three trials, each a draw rb (true at r >= 0.5), then `smoke` at (X + cx + rd / 5, Y + 0.5 - rd, Z + cz + rd / 5) (draws x, y, z;
*> cx, cz the centre of the shape bounds: PROPS 1-2 in thousandths).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "smoke".
 01 WS-R                   FLOAT-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 3
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R >= 0.5
             INITIALIZE WS-PV
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(1) = L-PP(1) + L-PR(1) / 1000 + WS-R / 5
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(2) = L-PP(2) + 0.5 - WS-R
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(3) = L-PP(3) + L-PR(2) / 1000 + WS-R / 5
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P6-C-WITHER-ROSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-FALLING-BLOCK.
*> 3.4 FallingBlock and BrushableBlock: draw ri(16) == 0, then (when the block below is free: PROPS 1) `falling_dust` with the block state PROPS 2
*> at (X + rd, Y - 0.05, Z + rd).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "falling_dust".
 01 WS-R                   FLOAT-LONG.
 01 WS-ZERO-C              BINARY-DOUBLE VALUE 0.
 01 WS-ZERO-S              FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF WS-R < 0.0625 AND L-PR(1) NOT = 0
         CALL "P6-BELOW" USING L-P WS-N P6-EMITS
         CALL "P6-EMIT-OPTION" USING P6-EMITS WS-ZERO-C WS-ZERO-S L-PR(2)
     END-IF
     GOBACK.
 END PROGRAM P6-C-FALLING-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-SPONGE.
*> 3.4 WetSpongeBlock (kind 0, `dripping_water`) and CryingObsidianBlock (kind 1, `dripping_obsidian_tear`): crying obsidian first draws ri(5) == 0; both
*> draw d = getRandom (ri(6)); UP stops; the block can occlude (PROPS 1) and the neighbour at d is sturdy (PROPS 2 + d) stops. Sponge: DOWN
*> y = Y - 0.05 with draws x, z; horizontal y = Y + rd * 0.8 (draw first), then the free axis draw, the facing axis at +1.1 (EAST, SOUTH) or +0.05.
*> Crying obsidian: per axis step != 0 ? 0.5 + step * 0.6 : rd (draws in axis order).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32).
 01 WS-R                   FLOAT-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-STEP.
    05 WS-S                BINARY-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-KIND                 BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS L-KIND P6-EMITS.
     MOVE 1 TO WS-K
     IF L-KIND = 1
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R >= 0.2
             MOVE 0 TO WS-K
         END-IF
     END-IF
     IF WS-K = 1
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-DIR = FUNCTION INTEGER-PART(WS-R * 6)
         COMPUTE WS-A = WS-DIR + 2
         IF WS-DIR = 1 OR (L-PR(1) NOT = 0 AND L-PR(WS-A) NOT = 0)
             MOVE 0 TO WS-K
         END-IF
     END-IF
     IF WS-K = 1
         INITIALIZE WS-PV
         CALL "P6-DIRECTION-STEP" USING WS-DIR WS-STEP
         IF L-KIND = 1
             MOVE "dripping_obsidian_tear" TO WS-N
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 IF WS-S(WS-A) NOT = 0
                     COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + WS-S(WS-A) * 0.6
                 ELSE
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R
                 END-IF
             END-PERFORM
         ELSE
             MOVE "dripping_water" TO WS-N
             IF WS-DIR = 0
                 COMPUTE WS-V(2) = L-PP(2) - 0.05
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(1) = L-PP(1) + WS-R
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(3) = L-PP(3) + WS-R
             ELSE
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(2) = L-PP(2) + WS-R * 0.8
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 IF WS-S(1) NOT = 0
                     COMPUTE WS-V(3) = L-PP(3) + WS-R
                     COMPUTE WS-V(1) = L-PP(1) + 0.05
                     IF WS-S(1) > 0
                         COMPUTE WS-V(1) = L-PP(1) + 1.1
                     END-IF
                 ELSE
                     COMPUTE WS-V(1) = L-PP(1) + WS-R
                     COMPUTE WS-V(3) = L-PP(3) + 0.05
                     IF WS-S(3) > 0
                         COMPUTE WS-V(3) = L-PP(3) + 1.1
                     END-IF
                 END-IF
             END-IF
         END-IF
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF
     GOBACK.
 END PROGRAM P6-C-SPONGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-FLUID-ABOVE.
*> 3.5 getFluidAbove of a stalactite: USING the number of same-direction pointed dripstone blocks above the tip before the root, root found (0 when
*> the walk left the build height), kind of the cell above the root (0 empty, 1 water, 2 lava, 3 mud, 4 other), the `water_evaporates` attribute
*> there (0/1), fluid out (0 empty, 1 water, 2 lava). The walk takes at most 10 steps, so the root is found when the count is 9 or less; mud
*> without evaporation counts as water.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-EVAP                 BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-ROOT L-KIND L-EVAP L-FLUID.
     MOVE 0 TO L-FLUID
     IF L-ROOT NOT = 0 AND L-COUNT <= 9
         EVALUATE TRUE
             WHEN L-KIND = 3 AND L-EVAP = 0
                 MOVE 1 TO L-FLUID
             WHEN L-KIND = 1 OR L-KIND = 2
                 MOVE L-KIND TO L-FLUID
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM P6-FLUID-ABOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-DRIPSTONE.
*> 3.4/3.5 PointedDripstoneBlock: a free-hanging stalactite (PROPS 1); draw f; f > 0.12 stops; kept when f < 0.02 or the fluid above (PROPS 2) is water or lava;
*> one drip at (X + 0.5 + ox, Y + 0.25, Z + 0.5 + oz) (PROPS 3-4 in thousandths): `dripping_dripstone_lava`, `dripping_dripstone_water`, or the
*> attribute particle for an empty fluid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32).
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R <= 0.12 AND (WS-R < 0.02 OR L-PR(2) = 1 OR L-PR(2) = 2)
             INITIALIZE WS-PV
             EVALUATE L-PR(2)
                 WHEN 1
                     MOVE "dripping_dripstone_water" TO WS-N
                 WHEN 2
                     MOVE "dripping_dripstone_lava" TO WS-N
                 WHEN OTHER
                     MOVE "default_dripstone_particle" TO WS-N
             END-EVALUATE
             COMPUTE WS-V(1) = L-PP(1) + 0.5 + L-PR(3) / 1000
             COMPUTE WS-V(2) = L-PP(2) + 0.25
             COMPUTE WS-V(3) = L-PP(3) + 0.5 + L-PR(4) / 1000
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-C-DRIPSTONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-PORTAL.
*> 3.4 NetherPortalBlock (kind 0; PROPS 1 a west or east neighbour is a portal) and EndGatewayBlock (kind 1; PROPS 1 the face count; the nether portal
*> runs four times): per particle draws x, y, z (X + rd), vx, vy, vz ((rf - 0.5) * 0.5), s = ri(2) * 2 - 1 (the portal's own draw; the gateway
*> a draw s and then a draw rb: true at r >= 0.5), then the axis choice: z = Z + 0.5 + 0.25 s and vz = rf * 2 s (a draw), else x and vx. `portal`.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "portal".
 01 WS-R                   FLOAT-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ZAXIS               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-KIND                 BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS L-KIND P6-EMITS.
     IF L-KIND = 0
         MOVE 4 TO WS-COUNT
     ELSE
         MOVE L-PR(1) TO WS-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         INITIALIZE WS-PV
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R
         END-PERFORM
         PERFORM VARYING WS-A FROM 4 BY 1 UNTIL WS-A > 6
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A) = (WS-R - 0.5) * 0.5
         END-PERFORM
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R >= 0.5
             MOVE 1 TO WS-S
         ELSE
             MOVE -1 TO WS-S
         END-IF
         IF L-KIND = 0
             MOVE L-PR(1) TO WS-ZAXIS
         ELSE
             CALL "P6-DRAW" USING P6-EMITS WS-R
             MOVE 0 TO WS-ZAXIS
             IF WS-R >= 0.5
                 MOVE 1 TO WS-ZAXIS
             END-IF
         END-IF
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-ZAXIS NOT = 0
             COMPUTE WS-V(3) = L-PP(3) + 0.5 + 0.25 * WS-S
             COMPUTE WS-V(6) = WS-R * 2 * WS-S
         ELSE
             COMPUTE WS-V(1) = L-PP(1) + 0.5 + 0.25 * WS-S
             COMPUTE WS-V(4) = WS-R * 2 * WS-S
         END-IF
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM
     GOBACK.
 END PROGRAM P6-C-PORTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-END-PORTAL.
*> 3.4 EndPortalBlock: one `smoke` at (X + rd, Y + 0.8, Z + rd) (draws x, z); BrewingStandBlock (kind 1): `smoke` at (X + 0.4 + rf * 0.2, Y + 0.7 + rf * 0.3,
*> Z + 0.4 + rf * 0.2) (draws x, y, z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "smoke".
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-KIND                 BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS L-KIND P6-EMITS.
     INITIALIZE WS-PV
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF L-KIND = 0
         COMPUTE WS-V(1) = L-PP(1) + WS-R
         COMPUTE WS-V(2) = L-PP(2) + 0.8
     ELSE
         COMPUTE WS-V(1) = L-PP(1) + 0.4 + WS-R * 0.2
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(2) = L-PP(2) + 0.7 + WS-R * 0.3
     END-IF
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF L-KIND = 0
         COMPUTE WS-V(3) = L-PP(3) + WS-R
     ELSE
         COMPUTE WS-V(3) = L-PP(3) + 0.4 + WS-R * 0.2
     END-IF
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     GOBACK.
 END PROGRAM P6-C-END-PORTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-ENDER-CHEST.
*> 3.4 EnderChestBlock: three particles, each draws a = ri(2) * 2 - 1, b likewise (true at r >= 0.5 for +1), y = Y + rf, then velocity (rf * a,
*> (rf - 0.5) * 0.125, rf * b); `portal` at (X + 0.5 + 0.25 a, y, Z + 0.5 + 0.25 b).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "portal".
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     PERFORM 3 TIMES
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         MOVE -1 TO WS-A
         IF WS-R >= 0.5
             MOVE 1 TO WS-A
         END-IF
         CALL "P6-DRAW" USING P6-EMITS WS-R
         MOVE -1 TO WS-B
         IF WS-R >= 0.5
             MOVE 1 TO WS-B
         END-IF
         COMPUTE WS-V(1) = L-PP(1) + 0.5 + 0.25 * WS-A
         COMPUTE WS-V(3) = L-PP(3) + 0.5 + 0.25 * WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(2) = L-PP(2) + WS-R
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(4) = WS-R * WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(5) = (WS-R - 0.5) * 0.125
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(6) = WS-R * WS-B
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM
     GOBACK.
 END PROGRAM P6-C-ENDER-CHEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-NOTE-BLOCK.
*> 3.4 NoteBlock client event: a tunable instrument (PROPS 1): one `note` at (X + 0.5, Y + 1.2, Z + 0.5), velocity (note / 24, 0, 0), note PROPS 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "note".
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         INITIALIZE WS-PV
         COMPUTE WS-V(1) = L-PP(1) + 0.5
         COMPUTE WS-V(2) = L-PP(2) + 1.2
         COMPUTE WS-V(3) = L-PP(3) + 0.5
         COMPUTE WS-V(4) = L-PR(2) / 24
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF
     GOBACK.
 END PROGRAM P6-C-NOTE-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-ENCHANTING-TABLE.
*> 3.4 EnchantingTableBlock: for each of the 32 BOOKSHELF_OFFSETS (x -2..2 fastest, y 0..1, z -2..2 slowest, kept when |x| = 2 or |z| = 2): draw ri(16)
*> == 0 and the entry valid (bit i of PROPS 1 + 65536 * PROPS 2): `enchant` at (X + 0.5, Y + 2, Z + 0.5) with velocity (off.x + rf - 0.5, off.y - rf - 1,
*> off.z + rf - 0.5) (draws x, y, z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "enchant".
 01 WS-R                   FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-MASK                BINARY-DOUBLE.
 01 WS-BIT                 BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     COMPUTE WS-MASK = L-PR(1) + L-PR(2) * 65536
     PERFORM VARYING WS-Z FROM -2 BY 1 UNTIL WS-Z > 2
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 1
             PERFORM VARYING WS-X FROM -2 BY 1 UNTIL WS-X > 2
                 IF WS-X = 2 OR WS-X = -2 OR WS-Z = 2 OR WS-Z = -2
                     COMPUTE WS-BIT = FUNCTION MOD(WS-MASK, 2)
                     COMPUTE WS-MASK = FUNCTION INTEGER-PART(WS-MASK / 2)
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     IF WS-R < 0.0625 AND WS-BIT NOT = 0
                         INITIALIZE WS-PV
                         COMPUTE WS-V(1) = L-PP(1) + 0.5
                         COMPUTE WS-V(2) = L-PP(2) + 2
                         COMPUTE WS-V(3) = L-PP(3) + 0.5
                         CALL "P6-DRAW" USING P6-EMITS WS-R
                         COMPUTE WS-V(4) = WS-X + WS-R - 0.5
                         CALL "P6-DRAW" USING P6-EMITS WS-R
                         COMPUTE WS-V(5) = WS-Y - WS-R - 1
                         CALL "P6-DRAW" USING P6-EMITS WS-R
                         COMPUTE WS-V(6) = WS-Z + WS-R - 0.5
                         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM P6-C-ENCHANTING-TABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-RESPAWN-ANCHOR.
*> 3.4 RespawnAnchorBlock: charge > 0 (PROPS 1): one `reverse_portal` at (X + 0.5 + (0.5 - rd), Y + 1, Z + 0.5 + (0.5 - rd)), velocity (0, rf * 0.04, 0);
*> draws x, z, vy.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "reverse_portal".
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) > 0
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(1) = L-PP(1) + 0.5 + (0.5 - WS-R)
         COMPUTE WS-V(2) = L-PP(2) + 1
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(3) = L-PP(3) + 0.5 + (0.5 - WS-R)
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(5) = WS-R * 0.04
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF
     GOBACK.
 END PROGRAM P6-C-RESPAWN-ANCHOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-BEEHIVE.
*> 3.4 BeehiveBlock (PROPS in the header): honey level >= 5, the hive has no fluid, a draw rf < 0.3; then with the shape max y >= 1 and not impermeable: a
*> shape min y above 0 drips at Y + min y - 0.05; else when the block below is open and has no fluid at Y - 0.05; `dripping_honey` at
*> (X + lerp(rd, 0, 1), y, Z + lerp(rd, 0, 1)) (draws x, z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "dripping_honey".
 01 WS-R                   FLOAT-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-YOFF                FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     MOVE 0 TO WS-GO
     IF L-PR(1) >= 5 AND L-PR(2) = 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R < 0.3 AND L-PR(3) >= 1000 AND L-PR(5) = 0
             EVALUATE TRUE
                 WHEN L-PR(4) > 0
                     COMPUTE WS-YOFF = L-PR(4) / 1000 - 0.05
                     MOVE 1 TO WS-GO
                 WHEN L-PR(6) NOT = 0 AND L-PR(7) = 0
                     MOVE -0.05 TO WS-YOFF
                     MOVE 1 TO WS-GO
             END-EVALUATE
         END-IF
     END-IF
     IF WS-GO = 1
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(1) = L-PP(1) + WS-R
         COMPUTE WS-V(2) = L-PP(2) + WS-YOFF
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(3) = L-PP(3) + WS-R
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF
     GOBACK.
 END PROGRAM P6-C-BEEHIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-BUBBLE-COLUMN.
*> 3.4 BubbleColumnBlock (PROPS 1 drag_down): `current_down` at (X + 0.5, Y + 0.8, Z); else `bubble_column_up` at (X + 0.5, Y, Z + 0.5) with velocity
*> (0, 0.04, 0) and another at (X + rf, Y + rf, Z + rf) (draws x, y, z). The particles are always visible (a flag of the particle options).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N1                  PIC X(32) VALUE "current_down".
 01 WS-N2                  PIC X(32) VALUE "bubble_column_up".
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     INITIALIZE WS-PV
     IF L-PR(1) NOT = 0
         COMPUTE WS-V(1) = L-PP(1) + 0.5
         COMPUTE WS-V(2) = L-PP(2) + 0.8
         COMPUTE WS-V(3) = L-PP(3)
         CALL "P6-EMIT" USING P6-EMITS WS-N1 WS-PV
     ELSE
         COMPUTE WS-V(1) = L-PP(1) + 0.5
         COMPUTE WS-V(2) = L-PP(2)
         COMPUTE WS-V(3) = L-PP(3) + 0.5
         MOVE 0.04 TO WS-V(5)
         CALL "P6-EMIT" USING P6-EMITS WS-N2 WS-PV
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R
         END-PERFORM
         CALL "P6-EMIT" USING P6-EMITS WS-N2 WS-PV
     END-IF
     GOBACK.
 END PROGRAM P6-C-BUBBLE-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-POTENT-SULFUR.
*> 3.4 PotentSulfurBlock (PROPS 1: not DRY and a water source above): two `sulfur_bubbles` at (X + rf, Y + 1 + rf, Z + rf), three draws each.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(32) VALUE "sulfur_bubbles".
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         PERFORM 2 TIMES
             INITIALIZE WS-PV
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R
             END-PERFORM
             COMPUTE WS-V(2) = WS-V(2) + 1
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM P6-C-POTENT-SULFUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-C-DRIED-GHAST.
*> 3.4 DriedGhastBlock (PROPS 1 waterlogged): draw ri(6) == 0; dry: `white_smoke` at the centre, velocity (0, 0.02, 0); waterlogged: `happy_villager` at
*> (cx + (rf * 2 - 1) / 3, cy + 0.4, cz + (rf * 2 - 1) / 3), velocity (0, rf, 0) (draws x, z, vy).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N1                  PIC X(32) VALUE "white_smoke".
 01 WS-N2                  PIC X(32) VALUE "happy_villager".
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF WS-R < 0.16666666666666666
         INITIALIZE WS-PV
         COMPUTE WS-V(1) = L-PP(1) + 0.5
         COMPUTE WS-V(2) = L-PP(2) + 0.5
         COMPUTE WS-V(3) = L-PP(3) + 0.5
         IF L-PR(1) = 0
             MOVE 0.02 TO WS-V(5)
             CALL "P6-EMIT" USING P6-EMITS WS-N1 WS-PV
         ELSE
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(1) = WS-V(1) + (WS-R * 2 - 1) / 3
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(3) = WS-V(3) + (WS-R * 2 - 1) / 3
             COMPUTE WS-V(2) = WS-V(2) + 0.4
             CALL "P6-DRAW" USING P6-EMITS WS-R
             MOVE WS-R TO WS-V(5)
             CALL "P6-EMIT" USING P6-EMITS WS-N2 WS-PV
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-C-DRIED-GHAST.
