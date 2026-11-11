*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md) section 3: `animateTick` of block classes. One entry point,
*> P6-BLOCK-TICK, runs the rules of one sampled block of a class; the rules take their random draws from EM-DRAW in the documented
*> order (see client/copy/CLP6EM.cpy for the draw conventions and the output rows). The caller (the level sampler of section 1.2)
*> fills the block position, the class and the block's property integers and reads the emitted particles and sounds.
*>
*> Entry point for the integrator (inputs):
*>   P6-BLOCK-TICK class(PIC X(24)) P(3 integers: X Y Z) PROPS(12 integers) P6-EMITS(CLP6EM; draws in, rows out)
*>   P6-WIRE-COLOR power(0-15) colour(ARGB out): the redstone wire colour table of 3.3.
*> PROPS per class (unlisted entries are ignored; (ox, oz) is the horizontal step of the direction opposite the `facing`):
*>   torch                  1 flame kind (0 flame, 1 soul_fire_flame, 2 copper_fire_flame)
*>   wall_torch             1 flame kind, 2 ox, 3 oz
*>   redstone_torch         1 lit (0/1)
*>   redstone_wall_torch    1 lit, 2 ox, 3 oz
*>   end_rod                1-3 step of `facing` (x, y, z)
*>   fire                   1 the floor test (canBurn(below) or its top face is sturdy), 2-6 canBurn of the west, east, north,
*>                          south and up neighbours
*>   campfire               1 lit, 2 the spawnParticles flag (campfire 1, soul campfire 0)
*>   candle                 1 lit, 2 candle count 1-4 (0 for a candle cake)
*>   furnace, blast_furnace 1 lit, 2 axis of `facing` (0 x, 1 z), 3 the step of `facing` on that axis (-1 or 1)
*>   smoker                 1 lit
*>   redstone_wire          1 power, 2-5 the connection of north, east, south, west (0 none, 1 side, 2 up)
*>   repeater               1 powered, 2-3 step of `facing` (x, z), 4 delay (1-4)
*>   redstone_ore           1 lit, 2-7 the neighbour at down, up, north, south, west, east renders solid (0/1)
*>   lever                  1 powered, 2-4 step of the opposite of `facing`, 5-7 step of the opposite of the connected direction
*>   sculk_sensor           1 phase (1 active)
*>   lightning_rod          1 thundering, 2 game time, 3 Y equals the heightmap surface minus one (0/1), 4 axis of `facing` (0 x, 1 y, 2 z)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-DRAW.
*> Next draw: USING emits, r out (EM-CUR advances).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING P6-EMITS L-R.
     ADD 1 TO EM-CUR
     MOVE EM-DRAW(EM-CUR) TO L-R
     GOBACK.
 END PROGRAM P6-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EMIT.
*> Append a particle: USING emits, name (PIC X(40)), six floats (x, y, z, vx, vy, vz); colour and scale are zeroed.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-NAME                 PIC X(40).
 01 L-PV.
    05 L-V                 FLOAT-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING P6-EMITS L-NAME L-PV.
     ADD 1 TO EM-COUNT
     MOVE L-NAME TO EM-NAME(EM-COUNT)
     MOVE L-V(1) TO EM-X(EM-COUNT)
     MOVE L-V(2) TO EM-Y(EM-COUNT)
     MOVE L-V(3) TO EM-Z(EM-COUNT)
     MOVE L-V(4) TO EM-VX(EM-COUNT)
     MOVE L-V(5) TO EM-VY(EM-COUNT)
     MOVE L-V(6) TO EM-VZ(EM-COUNT)
     MOVE 0 TO EM-COLOR(EM-COUNT)
     MOVE 0 TO EM-SCALE(EM-COUNT)
     MOVE 0 TO EM-STATE(EM-COUNT)
     GOBACK.
 END PROGRAM P6-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EMIT-OPTION.
*> Set the option of the last emitted particle: USING emits, colour, scale, block state.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-COLOR                BINARY-DOUBLE.
 01 L-SCALE                FLOAT-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING P6-EMITS L-COLOR L-SCALE L-STATE.
     MOVE L-COLOR TO EM-COLOR(EM-COUNT)
     MOVE L-SCALE TO EM-SCALE(EM-COUNT)
     MOVE L-STATE TO EM-STATE(EM-COUNT)
     GOBACK.
 END PROGRAM P6-EMIT-OPTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EMIT-SOUND.
*> Append a sound event: USING emits, name (PIC X(40)).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-NAME                 PIC X(40).
 PROCEDURE DIVISION USING P6-EMITS L-NAME.
     ADD 1 TO EM-SOUND-COUNT
     MOVE L-NAME TO EM-SOUND(EM-SOUND-COUNT)
     GOBACK.
 END PROGRAM P6-EMIT-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EMIT-REDSTONE.
*> Append a `dust` particle with the REDSTONE option: USING emits, six floats, scale.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "dust".
 01 WS-C                   BINARY-DOUBLE VALUE 16711680.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-PV.
    05 L-V                 FLOAT-LONG OCCURS 6 TIMES.
 01 L-SCALE                FLOAT-LONG.
 PROCEDURE DIVISION USING P6-EMITS L-PV L-SCALE.
     CALL "P6-EMIT" USING P6-EMITS WS-N L-PV
     CALL "P6-EMIT-OPTION" USING P6-EMITS WS-C L-SCALE WS-ZERO
     GOBACK.
 END PROGRAM P6-EMIT-REDSTONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-WIRE-COLOR.
*> Section 3.3 wire colour table: USING power (0-15), colour out (ARGB): f = p / 15; r = f * 0.6 + (f > 0 ? 0.4 : 0.3);
*> g = clamp(f * f * 0.7 - 0.5, 0, 1); b = clamp(f * f * 0.6 - 0.7, 0, 1); colorFromFloat(1, r, g, b) truncates each channel * 255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-COLOR                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-POWER L-COLOR.
     COMPUTE WS-F = L-POWER / 15
     IF WS-F > 0
         COMPUTE WS-R = WS-F * 0.6 + 0.4
     ELSE
         COMPUTE WS-R = 0.3
     END-IF
     COMPUTE WS-G = WS-F * WS-F * 0.7 - 0.5
     IF WS-G < 0
         MOVE 0 TO WS-G
     END-IF
     COMPUTE WS-B = WS-F * WS-F * 0.6 - 0.7
     IF WS-B < 0
         MOVE 0 TO WS-B
     END-IF
     COMPUTE L-COLOR = 4278190080 + FUNCTION INTEGER-PART(WS-R * 255) * 65536
         + FUNCTION INTEGER-PART(WS-G * 255) * 256 + FUNCTION INTEGER-PART(WS-B * 255)
     GOBACK.
 END PROGRAM P6-WIRE-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-FLAME-NAME.
*> The flame particle of a torch: USING kind (0 flame, 1 soul_fire_flame, 2 copper_fire_flame), name out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X(40).
 PROCEDURE DIVISION USING L-KIND L-NAME.
     EVALUATE L-KIND
         WHEN 1
             MOVE "soul_fire_flame" TO L-NAME
         WHEN 2
             MOVE "copper_fire_flame" TO L-NAME
         WHEN OTHER
             MOVE "flame" TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-FLAME-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-TORCH.
*> 3.1 TorchBlock and WallTorchBlock (PROPS 2, 3 = ox, oz; zero for the standing torch): smoke then the flame at
*> (X + 0.5 + 0.27 ox, Y + 0.7 (+ 0.22 on a wall), Z + 0.5 + 0.27 oz); no draws.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               PIC X(40) VALUE "smoke".
 01 WS-FLAME               PIC X(40).
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-WALL                 BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS L-WALL P6-EMITS.
     INITIALIZE WS-PV
     COMPUTE WS-V(1) = L-PP(1) + 0.5 + 0.27 * L-PR(2) * L-WALL
     COMPUTE WS-V(2) = L-PP(2) + 0.7 + 0.22 * L-WALL
     COMPUTE WS-V(3) = L-PP(3) + 0.5 + 0.27 * L-PR(3) * L-WALL
     CALL "P6-FLAME-NAME" USING L-PR(1) WS-FLAME
     CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
     CALL "P6-EMIT" USING P6-EMITS WS-FLAME WS-PV
     GOBACK.
 END PROGRAM P6-B-TORCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-REDSTONE-TORCH.
*> 3.1 RedstoneTorchBlock / RedstoneWallTorchBlock (PROPS 1 lit, 2 ox, 3 oz; wall flag 1 for the wall variant): when lit, `dust` REDSTONE
*> at (X + 0.5 + (rd - 0.5) * 0.2 + 0.27 ox, Y + 0.7 + (rd - 0.5) * 0.2 + 0.22, Z + 0.5 + (rd - 0.5) * 0.2 + 0.27 oz); draws x, y, z.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-WALL                 BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS L-WALL P6-EMITS.
     IF L-PR(1) NOT = 0
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(1) = L-PP(1) + 0.5 + (WS-R - 0.5) * 0.2 + 0.27 * L-PR(2) * L-WALL
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(2) = L-PP(2) + 0.7 + (WS-R - 0.5) * 0.2 + 0.22 * L-WALL
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(3) = L-PP(3) + 0.5 + (WS-R - 0.5) * 0.2 + 0.27 * L-PR(3) * L-WALL
         CALL "P6-EMIT-REDSTONE" USING P6-EMITS WS-PV WS-ONE
     END-IF
     GOBACK.
 END PROGRAM P6-B-REDSTONE-TORCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-END-ROD.
*> 3.1 EndRodBlock (PROPS 1-3 step of facing): draws base x, y, z (base = P + 0.55 - rf * 0.1), two for s = 0.4 - (rf + rf) * 0.4, then
*> ri(5); on 0 the `end_rod` at base + step * s with velocity (rg * 0.005) from three Gaussian draws.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "end_rod".
 01 WS-R                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-BASE.
    05 WS-B                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-B(WS-A) = L-PP(WS-A) + 0.55 - WS-R * 0.1
     END-PERFORM
     CALL "P6-DRAW" USING P6-EMITS WS-R
     MOVE WS-R TO WS-S
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-S = 0.4 - (WS-S + WS-R) * 0.4
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF WS-R < 0.2
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-V(WS-A) = WS-B(WS-A) + L-PR(WS-A) * WS-S
         END-PERFORM
         PERFORM VARYING WS-A FROM 4 BY 1 UNTIL WS-A > 6
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A) = WS-R * 0.005
         END-PERFORM
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF
     GOBACK.
 END PROGRAM P6-B-END-ROD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-FIRE.
*> 3.2 BaseFireBlock: draw ri(24) (r < 1/24: the `fire.ambient` sound and its two volume and pitch draws), then the smoke: the floor test
*> (PROPS 1) true gives three `large_smoke` at (X + rd, Y + rd * 0.5 + 0.5, Z + rd); false gives, for each burnable neighbour (PROPS 2-6:
*> west, east, north, south, up), two `large_smoke` with the side's formula; draws x, y, z per particle.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "large_smoke".
 01 WS-SOUND               PIC X(40) VALUE "fire.ambient".
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF WS-R < 0.041666666666666664
         CALL "P6-DRAW" USING P6-EMITS WS-R
         CALL "P6-DRAW" USING P6-EMITS WS-R
         CALL "P6-EMIT-SOUND" USING P6-EMITS WS-SOUND
     END-IF
     INITIALIZE WS-PV
     IF L-PR(1) NOT = 0
         PERFORM 3 TIMES
             CALL "P6-DRAW" USING P6-EMITS WS-A
             CALL "P6-DRAW" USING P6-EMITS WS-B
             CALL "P6-DRAW" USING P6-EMITS WS-C
             COMPUTE WS-V(1) = L-PP(1) + WS-A
             COMPUTE WS-V(2) = L-PP(2) + WS-B * 0.5 + 0.5
             COMPUTE WS-V(3) = L-PP(3) + WS-C
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-PERFORM
     ELSE
         PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 5
             COMPUTE WS-K = WS-SIDE + 1
             IF L-PR(WS-K) NOT = 0
                 PERFORM 2 TIMES
                     CALL "P6-DRAW" USING P6-EMITS WS-A
                     CALL "P6-DRAW" USING P6-EMITS WS-B
                     CALL "P6-DRAW" USING P6-EMITS WS-C
                     EVALUATE WS-SIDE
                         WHEN 1
                             COMPUTE WS-V(1) = L-PP(1) + WS-A * 0.10000000149011612
                             COMPUTE WS-V(2) = L-PP(2) + WS-B
                             COMPUTE WS-V(3) = L-PP(3) + WS-C
                         WHEN 2
                             COMPUTE WS-V(1) = L-PP(1) + 1 - WS-A * 0.10000000149011612
                             COMPUTE WS-V(2) = L-PP(2) + WS-B
                             COMPUTE WS-V(3) = L-PP(3) + WS-C
                         WHEN 3
                             COMPUTE WS-V(1) = L-PP(1) + WS-A
                             COMPUTE WS-V(2) = L-PP(2) + WS-B
                             COMPUTE WS-V(3) = L-PP(3) + WS-C * 0.10000000149011612
                         WHEN 4
                             COMPUTE WS-V(1) = L-PP(1) + WS-A
                             COMPUTE WS-V(2) = L-PP(2) + WS-B
                             COMPUTE WS-V(3) = L-PP(3) + 1 - WS-C * 0.10000000149011612
                         WHEN OTHER
                             COMPUTE WS-V(1) = L-PP(1) + WS-A
                             COMPUTE WS-V(2) = L-PP(2) + 1 - WS-B * 0.10000000149011612
                             COMPUTE WS-V(3) = L-PP(3) + WS-C
                     END-EVALUATE
                     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
                 END-PERFORM
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM P6-B-FIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-CAMPFIRE.
*> 3.2 CampfireBlock (PROPS 1 lit, 2 spawnParticles): lit: draw ri(10) (r < 0.1: the `campfire.crackle` sound and two draws); with the flag:
*> draw ri(5) (r < 0.2: one `lava` at the centre with velocity (rf / 2, 0.00005, rf / 2), draws vx then vz).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "lava".
 01 WS-SOUND               PIC X(40) VALUE "campfire.crackle".
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R < 0.1
             CALL "P6-DRAW" USING P6-EMITS WS-R
             CALL "P6-DRAW" USING P6-EMITS WS-R
             CALL "P6-EMIT-SOUND" USING P6-EMITS WS-SOUND
         END-IF
         IF L-PR(2) NOT = 0
             CALL "P6-DRAW" USING P6-EMITS WS-R
             IF WS-R < 0.2
                 COMPUTE WS-V(1) = L-PP(1) + 0.5
                 COMPUTE WS-V(2) = L-PP(2) + 0.5
                 COMPUTE WS-V(3) = L-PP(3) + 0.5
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(4) = WS-R / 2
                 MOVE 0.00005 TO WS-V(5)
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(6) = WS-R / 2
                 CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-B-CAMPFIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-CANDLE.
*> 3.2 AbstractCandleBlock (PROPS 1 lit, 2 candle count 1-4, 0 for the candle cake): per offset (the table of the section, in sixteenths)
*> draw f; f < 0.3: `smoke` at P + offset, and f < 0.17 also the `candle.ambient` sound with two draws (volume, pitch); always `small_flame`.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               PIC X(40) VALUE "smoke".
 01 WS-FLAME               PIC X(40) VALUE "small_flame".
 01 WS-SOUND               PIC X(40) VALUE "candle.ambient".
 01 WS-TABLE               PIC X(60) VALUE "080808060708100807080510060708090807070509100709060706090806".
 01 WS-OFFSETS REDEFINES WS-TABLE.
    05 WS-OFF              PIC 99 OCCURS 30 TIMES.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         EVALUATE L-PR(2)
             WHEN 2
                 MOVE 2 TO WS-FIRST
                 MOVE 3 TO WS-LAST
             WHEN 3
                 MOVE 4 TO WS-FIRST
                 MOVE 6 TO WS-LAST
             WHEN 4
                 MOVE 7 TO WS-FIRST
                 MOVE 10 TO WS-LAST
             WHEN OTHER
                 MOVE 1 TO WS-FIRST
                 MOVE 1 TO WS-LAST
         END-EVALUATE
         PERFORM VARYING WS-I FROM WS-FIRST BY 1 UNTIL WS-I > WS-LAST
             INITIALIZE WS-PV
             COMPUTE WS-K = (WS-I - 1) * 3
             COMPUTE WS-V(1) = L-PP(1) + WS-OFF(WS-K + 1) / 16
             COMPUTE WS-V(2) = L-PP(2) + WS-OFF(WS-K + 2) / 16
             COMPUTE WS-V(3) = L-PP(3) + WS-OFF(WS-K + 3) / 16
             IF L-PR(2) = 0
                 COMPUTE WS-V(1) = L-PP(1) + 0.5
                 COMPUTE WS-V(2) = L-PP(2) + 1
                 COMPUTE WS-V(3) = L-PP(3) + 0.5
             END-IF
             CALL "P6-DRAW" USING P6-EMITS WS-R
             IF WS-R < 0.3
                 CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
                 IF WS-R < 0.17
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     CALL "P6-EMIT-SOUND" USING P6-EMITS WS-SOUND
                 END-IF
             END-IF
             CALL "P6-EMIT" USING P6-EMITS WS-FLAME WS-PV
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM P6-B-CANDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-FURNACE.
*> 3.2 FurnaceBlock and BlastFurnaceBlock (PROPS 1 lit, 2 axis of facing, 3 its step; kind 0 furnace, 1 blast furnace): lit: draw (r < 0.1: the
*> sound), draw r (r * 0.6 - 0.3 for the free horizontal axis), draw for y (6/16, blast 9/16 of it); `smoke` then (furnace only) `flame` at
*> (X + 0.5 + x-off, Y + y-off, Z + 0.5 + z-off), the facing axis offset being step * 0.52.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               PIC X(40) VALUE "smoke".
 01 WS-FLAME               PIC X(40) VALUE "flame".
 01 WS-SOUND               PIC X(40).
 01 WS-R                   FLOAT-LONG.
 01 WS-FREE                FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-KIND                 BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS L-KIND P6-EMITS.
     IF L-PR(1) NOT = 0
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R < 0.1
             IF L-KIND = 0
                 MOVE "furnace.fire_crackle" TO WS-SOUND
             ELSE
                 MOVE "blast_furnace.fire_crackle" TO WS-SOUND
             END-IF
             CALL "P6-EMIT-SOUND" USING P6-EMITS WS-SOUND
         END-IF
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-FREE = WS-R * 0.6 - 0.3
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF L-KIND = 0
             COMPUTE WS-V(2) = L-PP(2) + WS-R * 6 / 16
         ELSE
             COMPUTE WS-V(2) = L-PP(2) + WS-R * 9 / 16
         END-IF
         IF L-PR(2) = 0
             COMPUTE WS-V(1) = L-PP(1) + 0.5 + L-PR(3) * 0.52
             COMPUTE WS-V(3) = L-PP(3) + 0.5 + WS-FREE
         ELSE
             COMPUTE WS-V(1) = L-PP(1) + 0.5 + WS-FREE
             COMPUTE WS-V(3) = L-PP(3) + 0.5 + L-PR(3) * 0.52
         END-IF
         CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
         IF L-KIND = 0
             CALL "P6-EMIT" USING P6-EMITS WS-FLAME WS-PV
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-B-FURNACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-SMOKER.
*> 3.2 SmokerBlock (PROPS 1 lit): lit: draw (r < 0.1: the `smoker.smoke` sound), one `smoke` at (X + 0.5, Y + 1.1, Z + 0.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               PIC X(40) VALUE "smoke".
 01 WS-SOUND               PIC X(40) VALUE "smoker.smoke".
 01 WS-R                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R < 0.1
             CALL "P6-EMIT-SOUND" USING P6-EMITS WS-SOUND
         END-IF
         COMPUTE WS-V(1) = L-PP(1) + 0.5
         COMPUTE WS-V(2) = L-PP(2) + 1.1
         COMPUTE WS-V(3) = L-PP(3) + 0.5
         CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
     END-IF
     GOBACK.
 END PROGRAM P6-B-SMOKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-DIRECTION-STEP.
*> The step of a Direction.values() index (0 down, 1 up, 2 north, 3 south, 4 west, 5 east): USING index, step out (x, y, z).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-STEP.
    05 L-S                 BINARY-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-INDEX L-STEP.
     MOVE 0 TO L-S(1) L-S(2) L-S(3)
     EVALUATE L-INDEX
         WHEN 0
             MOVE -1 TO L-S(2)
         WHEN 1
             MOVE 1 TO L-S(2)
         WHEN 2
             MOVE -1 TO L-S(3)
         WHEN 3
             MOVE 1 TO L-S(3)
         WHEN 4
             MOVE -1 TO L-S(1)
         WHEN 5
             MOVE 1 TO L-S(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-DIRECTION-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-WIRE-LINE.
*> 3.3 RedstoneWireBlock line(a, b, from, to): USING block, colour, direction index a, direction index b (Direction.values() order: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east), from, to, emits. len = to - from; draw r;
*> r >= 0.2 * len stops; else draw for t = from + len * rf2; `dust` (colour, scale 1) at P + 0.5 + 0.4375 * step(a) + t * step(b).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "dust".
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-R                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-SA.
    05 WS-SAA              BINARY-LONG OCCURS 3 TIMES.
 01 WS-SB.
    05 WS-SBB              BINARY-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-COLOR                BINARY-DOUBLE.
 01 L-DA                   BINARY-LONG.
 01 L-DB                   BINARY-LONG.
 01 L-FROM                 FLOAT-LONG.
 01 L-TO                   FLOAT-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-COLOR L-DA L-DB L-FROM L-TO P6-EMITS.
     COMPUTE WS-LEN = L-TO - L-FROM
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF WS-R < 0.2 * WS-LEN
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-T = L-FROM + WS-LEN * WS-R
         CALL "P6-DIRECTION-STEP" USING L-DA WS-SA
         CALL "P6-DIRECTION-STEP" USING L-DB WS-SB
         INITIALIZE WS-PV
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + 0.4375 * WS-SAA(WS-A) + WS-T * WS-SBB(WS-A)
         END-PERFORM
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         CALL "P6-EMIT-OPTION" USING P6-EMITS L-COLOR WS-ONE WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM P6-WIRE-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-WIRE.
*> 3.3 RedstoneWireBlock (PROPS 1 power, 2-5 connection of north, east, south, west: 0 none, 1 side, 2 up): power > 0; per direction (north, east,
*> south, west): up: line(d, UP, -0.5, 0.5) then line(DOWN, d, 0, 0.5); side: line(DOWN, d, 0, 0.5); none: line(DOWN, d, 0, 0.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLOR               BINARY-DOUBLE.
 01 WS-D                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE 0.
 01 WS-UP                  BINARY-LONG VALUE 1.
 01 WS-K                   BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-NHALF               FLOAT-LONG VALUE -0.5.
 01 WS-THREE               FLOAT-LONG VALUE 0.3.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) > 0
         CALL "P6-WIRE-COLOR" USING L-PR(1) WS-COLOR
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
             EVALUATE WS-D
                 WHEN 1
                     MOVE 2 TO WS-DIR
                 WHEN 2
                     MOVE 5 TO WS-DIR
                 WHEN 3
                     MOVE 3 TO WS-DIR
                 WHEN OTHER
                     MOVE 4 TO WS-DIR
             END-EVALUATE
             COMPUTE WS-K = WS-D + 1
             EVALUATE L-PR(WS-K)
                 WHEN 2
                     CALL "P6-WIRE-LINE" USING L-P WS-COLOR WS-DIR WS-UP WS-NHALF WS-HALF P6-EMITS
                     CALL "P6-WIRE-LINE" USING L-P WS-COLOR WS-DOWN WS-DIR WS-ZERO WS-HALF P6-EMITS
                 WHEN 1
                     CALL "P6-WIRE-LINE" USING L-P WS-COLOR WS-DOWN WS-DIR WS-ZERO WS-HALF P6-EMITS
                 WHEN OTHER
                     CALL "P6-WIRE-LINE" USING L-P WS-COLOR WS-DOWN WS-DIR WS-ZERO WS-THREE P6-EMITS
             END-EVALUATE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM P6-B-WIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-REPEATER.
*> 3.3 RepeaterBlock (PROPS 1 powered, 2-3 step of facing (x, z), 4 delay): three draws for the centre (X + 0.5 + (rd - 0.5) * 0.2, Y + 0.4 + ..., Z + 0.5 + ...),
*> then rb: s = -5 (false) or 2 * delay - 1 (true), divided by 16, offset along facing; `dust` REDSTONE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-R                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(1) = L-PP(1) + 0.5 + (WS-R - 0.5) * 0.2
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(2) = L-PP(2) + 0.4 + (WS-R - 0.5) * 0.2
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(3) = L-PP(3) + 0.5 + (WS-R - 0.5) * 0.2
         CALL "P6-DRAW" USING P6-EMITS WS-R
         MOVE -5 TO WS-S
         IF WS-R >= 0.5
             COMPUTE WS-S = L-PR(4) * 2 - 1
         END-IF
         COMPUTE WS-S = WS-S / 16
         COMPUTE WS-V(1) = WS-V(1) + WS-S * L-PR(2)
         COMPUTE WS-V(3) = WS-V(3) + WS-S * L-PR(3)
         CALL "P6-EMIT-REDSTONE" USING P6-EMITS WS-PV WS-ONE
     END-IF
     GOBACK.
 END PROGRAM P6-B-REPEATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-REDSTONE-ORE.
*> 3.3 RedStoneOreBlock (PROPS 1 lit, 2-7 the neighbour at down, up, north, south, west, east renders solid): lit; per direction whose neighbour is not
*> solid: the coordinate on the face axis is 0.5 + 0.5625 * step, each other axis one draw (x, y, z order); `dust` REDSTONE at P + that.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-R                   FLOAT-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-STEP.
    05 WS-S                BINARY-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 5
             COMPUTE WS-K = WS-DIR + 2
             IF L-PR(WS-K) = 0
                 CALL "P6-DIRECTION-STEP" USING WS-DIR WS-STEP
                 INITIALIZE WS-PV
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     IF WS-S(WS-A) NOT = 0
                         COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + 0.5625 * WS-S(WS-A)
                     ELSE
                         CALL "P6-DRAW" USING P6-EMITS WS-R
                         COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R
                     END-IF
                 END-PERFORM
                 CALL "P6-EMIT-REDSTONE" USING P6-EMITS WS-PV WS-ONE
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM P6-B-REDSTONE-ORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-LEVER.
*> 3.3 LeverBlock (PROPS 1 powered, 2-4 step of the opposite of facing, 5-7 step of the opposite of the connected direction): powered and draw
*> rf < 0.25: `dust` colour 0xFF0000 scale 0.5 at P + 0.5 + 0.1 * step1 + 0.2 * step2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R < 0.25
             INITIALIZE WS-PV
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 COMPUTE WS-K = WS-A + 4
                 COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + 0.1 * L-PR(WS-A + 1) + 0.2 * L-PR(WS-K)
             END-PERFORM
             CALL "P6-EMIT-REDSTONE" USING P6-EMITS WS-PV WS-HALF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-B-LEVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-SCULK-SENSOR.
*> 3.3 SculkSensorBlock (PROPS 1 phase, 1 = ACTIVE): draw d = getRandom (ri(6)); UP or DOWN stops; x and z: P + 0.5 + (step != 0 ? step * 0.6 : 0.5 - rd)
*> (a draw for each free axis, x first), y = Y + 0.25, then a draw for vy = rf * 0.04; `dust_color_transition` (the SCULK_TO_REDSTONE option is data).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "dust_color_transition".
 01 WS-R                   FLOAT-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-STEP.
    05 WS-S                BINARY-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) = 1
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-DIR = FUNCTION INTEGER-PART(WS-R * 6)
         IF WS-DIR > 1
             CALL "P6-DIRECTION-STEP" USING WS-DIR WS-STEP
             INITIALIZE WS-PV
             IF WS-S(1) NOT = 0
                 COMPUTE WS-V(1) = L-PP(1) + 0.5 + WS-S(1) * 0.6
             ELSE
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(1) = L-PP(1) + 0.5 + (0.5 - WS-R)
             END-IF
             IF WS-S(3) NOT = 0
                 COMPUTE WS-V(3) = L-PP(3) + 0.5 + WS-S(3) * 0.6
             ELSE
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(3) = L-PP(3) + 0.5 + (0.5 - WS-R)
             END-IF
             COMPUTE WS-V(2) = L-PP(2) + 0.25
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(5) = WS-R * 0.04
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-B-SCULK-SENSOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-B-LIGHTNING-ROD.
*> 3.3 LightningRodBlock (PROPS 1 thundering, 2 game time, 3 at the surface (Y = heightmap - 1), 4 axis of facing 0 x, 1 y, 2 z): thundering, draw
*> ri(200) <= game time mod 200, then the surface test; spawnParticlesAlongAxis(axis, P, 0.125, electric_spark, UniformInt(1, 2)): a count draw
*> (1 + floor(r * 2)), then per particle three position draws and one velocity draw (Mth.nextDouble(-1, 1) = 2 r - 1; spread 0.5 on the axis).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "electric_spark".
 01 WS-R                   FLOAT-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-DRAW = FUNCTION INTEGER-PART(WS-R * 200)
         COMPUTE WS-LIMIT = FUNCTION MOD(L-PR(2), 200)
         IF WS-DRAW <= WS-LIMIT AND L-PR(3) NOT = 0
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-COUNT = 1 + FUNCTION INTEGER-PART(WS-R * 2)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 INITIALIZE WS-PV
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     MOVE 0.125 TO WS-K
                     IF WS-A = L-PR(4) + 1
                         MOVE 0.5 TO WS-K
                     END-IF
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + (2 * WS-R - 1) * WS-K
                 END-PERFORM
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-A = L-PR(4) + 4
                 COMPUTE WS-V(WS-A) = 2 * WS-R - 1
                 CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-B-LIGHTNING-ROD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-BLOCK-TICK.
*> Section 3: USING class (PIC X(24): torch, wall_torch, redstone_torch, redstone_wall_torch, end_rod, fire, campfire, candle, furnace,
*> blast_furnace, smoker, redstone_wire, repeater, redstone_ore, lever, sculk_sensor, lightning_rod, and the classes of particles-42-6-c.cob), block position, PROPS, emits. The
*> emission record is cleared first; an unknown class emits nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-CLASS                PIC X(24).
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-CLASS L-P L-PROPS P6-EMITS.
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     EVALUATE L-CLASS
         WHEN "torch"
             CALL "P6-B-TORCH" USING L-P L-PROPS WS-ZERO P6-EMITS
         WHEN "wall_torch"
             CALL "P6-B-TORCH" USING L-P L-PROPS WS-ONE P6-EMITS
         WHEN "redstone_torch"
             CALL "P6-B-REDSTONE-TORCH" USING L-P L-PROPS WS-ZERO P6-EMITS
         WHEN "redstone_wall_torch"
             CALL "P6-B-REDSTONE-TORCH" USING L-P L-PROPS WS-ONE P6-EMITS
         WHEN "end_rod"
             CALL "P6-B-END-ROD" USING L-P L-PROPS P6-EMITS
         WHEN "fire"
             CALL "P6-B-FIRE" USING L-P L-PROPS P6-EMITS
         WHEN "campfire"
             CALL "P6-B-CAMPFIRE" USING L-P L-PROPS P6-EMITS
         WHEN "candle"
             CALL "P6-B-CANDLE" USING L-P L-PROPS P6-EMITS
         WHEN "furnace"
             CALL "P6-B-FURNACE" USING L-P L-PROPS WS-ZERO P6-EMITS
         WHEN "blast_furnace"
             CALL "P6-B-FURNACE" USING L-P L-PROPS WS-ONE P6-EMITS
         WHEN "smoker"
             CALL "P6-B-SMOKER" USING L-P L-PROPS P6-EMITS
         WHEN "redstone_wire"
             CALL "P6-B-WIRE" USING L-P L-PROPS P6-EMITS
         WHEN "repeater"
             CALL "P6-B-REPEATER" USING L-P L-PROPS P6-EMITS
         WHEN "redstone_ore"
             CALL "P6-B-REDSTONE-ORE" USING L-P L-PROPS P6-EMITS
         WHEN "lever"
             CALL "P6-B-LEVER" USING L-P L-PROPS P6-EMITS
         WHEN "sculk_sensor"
             CALL "P6-B-SCULK-SENSOR" USING L-P L-PROPS P6-EMITS
         WHEN "lightning_rod"
             CALL "P6-B-LIGHTNING-ROD" USING L-P L-PROPS P6-EMITS
         WHEN "leaves"
             CALL "P6-C-LEAVES" USING L-P L-PROPS P6-EMITS
         WHEN "falling_leaves"
             CALL "P6-C-FALLING-LEAVES" USING L-P L-PROPS P6-EMITS
         WHEN "mycelium"
             CALL "P6-C-MYCELIUM" USING L-P L-PROPS P6-EMITS
         WHEN "spore_blossom"
             CALL "P6-C-SPORE-BLOSSOM" USING L-P L-PROPS P6-EMITS
         WHEN "firefly_bush"
             CALL "P6-C-FIREFLY-BUSH" USING L-P L-PROPS P6-EMITS
         WHEN "wither_rose"
             CALL "P6-C-WITHER-ROSE" USING L-P L-PROPS P6-EMITS
         WHEN "falling_block"
             CALL "P6-C-FALLING-BLOCK" USING L-P L-PROPS P6-EMITS
         WHEN "brushable_block"
             CALL "P6-C-FALLING-BLOCK" USING L-P L-PROPS P6-EMITS
         WHEN "wet_sponge"
             CALL "P6-C-SPONGE" USING L-P L-PROPS WS-ZERO P6-EMITS
         WHEN "crying_obsidian"
             CALL "P6-C-SPONGE" USING L-P L-PROPS WS-ONE P6-EMITS
         WHEN "pointed_dripstone"
             CALL "P6-C-DRIPSTONE" USING L-P L-PROPS P6-EMITS
         WHEN "nether_portal"
             CALL "P6-C-PORTAL" USING L-P L-PROPS WS-ZERO P6-EMITS
         WHEN "end_gateway"
             CALL "P6-C-PORTAL" USING L-P L-PROPS WS-ONE P6-EMITS
         WHEN "end_portal"
             CALL "P6-C-END-PORTAL" USING L-P L-PROPS WS-ZERO P6-EMITS
         WHEN "brewing_stand"
             CALL "P6-C-END-PORTAL" USING L-P L-PROPS WS-ONE P6-EMITS
         WHEN "ender_chest"
             CALL "P6-C-ENDER-CHEST" USING L-P L-PROPS P6-EMITS
         WHEN "note_block"
             CALL "P6-C-NOTE-BLOCK" USING L-P L-PROPS P6-EMITS
         WHEN "enchanting_table"
             CALL "P6-C-ENCHANTING-TABLE" USING L-P L-PROPS P6-EMITS
         WHEN "respawn_anchor"
             CALL "P6-C-RESPAWN-ANCHOR" USING L-P L-PROPS P6-EMITS
         WHEN "beehive"
             CALL "P6-C-BEEHIVE" USING L-P L-PROPS P6-EMITS
         WHEN "bubble_column"
             CALL "P6-C-BUBBLE-COLUMN" USING L-P L-PROPS P6-EMITS
         WHEN "potent_sulfur"
             CALL "P6-C-POTENT-SULFUR" USING L-P L-PROPS P6-EMITS
         WHEN "dried_ghast"
             CALL "P6-C-DRIED-GHAST" USING L-P L-PROPS P6-EMITS
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-BLOCK-TICK.
