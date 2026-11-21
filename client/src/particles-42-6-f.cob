*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md) section 6: block-driven level events (the particle effects of
*> `LevelEventHandler.levelEvent`). Draws and output rows are those of client/copy/CLP6EM.cpy (see particles-42-6-b.cob). Sounds are not
*> emitted, except the sculk charge sound (a draw decides it). Destroy and crack events (7.1, 7.2) and the events assigned to part 7 are routed,
*> not emitted here.
*>
*> Entry points for the integrator (inputs):
*>   P6-EVENT-ROUTE event kind: 0 no particle effect here (sound only or no case), 1 emitted by P6-LEVEL-EVENT, 2 the destroy effect (2001,
*>     2014, 3008; section 7.1), 3 the crack (2019, 2020; section 7.2), 4 part 42-7 (2002, 2003, 2006-2008, 2013, 2015-2018, 3000).
*>   P6-LEVEL-EVENT event data P(3 integers) PROPS(12 integers) P6-EMITS: PROPS by event:
*>     1500 composter fill   1 collision shape max y at (0.5, 0.5) in thousandths (500 when absent)
*>     1504 dripstone drip   2 fluid (0 empty, 1 water, 2 lava), 3-4 the block offset x and z in thousandths
*>     1505 bone meal        1 kind (0 grower: spawnParticleInBlock, 1 spreader or water: 3 * count particles), 3 shape max y in thousandths
*>                           (1000 for air; used by the grower); spreader particles carry EM-STATE 1: skip when the cell below the position is air
*>     2011, 2012            3 shape max y in thousandths (1000 for air)
*>     3006 sculk charge pop 1 the collision shape is a full block
*>     3015, 3016 vault      none (data 0 normal, other ominous)
*>   data: the direction index (0 down, 1 up, 2 north, 3 south, 4 west, 5 east) for 2000 and 2010; the particle count for 1505, 2011 and 2012;
*>     the axis (0 x, 1 y, 2 z, else all faces) for 3002; the charge * 64 + face mask for 3006; the flame (0 flame, else soul_fire_flame) for 3011,
*>     3012 and 3021; the detected player count for 3013 and 3019.
*>   P6-FACE-BURST P mask name min max side-offset y-offset half-speed roll-down roll-up P6-EMITS: spawnParticlesOnBlockFaces for the directions
*>     of the bit mask (bit i = Direction.values() index i): per direction a count draw (min + floor(r * (max - min + 1))), per particle three
*>     speed draws Mth.nextDouble(-half, half) and one position draw for each axis other than the face axis (nextDouble(-0.5, 0.5)); the
*>     option roll goes to EM-SCALE.
*>   P6-SPAWN-PARTICLES P count spread height ignore-floor name P6-EMITS: ParticleUtils.spawnParticles (42-6 section 2.1).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EVENT-ROUTE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-KIND.
     EVALUATE TRUE
         WHEN L-EVENT = 2001 OR L-EVENT = 2014 OR L-EVENT = 3008
             MOVE 2 TO L-KIND
         WHEN L-EVENT = 2019 OR L-EVENT = 2020
             MOVE 3 TO L-KIND
         WHEN L-EVENT = 2002 OR L-EVENT = 2003 OR (L-EVENT >= 2006 AND L-EVENT <= 2008)
             OR L-EVENT = 2013 OR (L-EVENT >= 2015 AND L-EVENT <= 2018) OR L-EVENT = 3000
             MOVE 4 TO L-KIND
         WHEN (L-EVENT >= 1500 AND L-EVENT <= 1505) OR L-EVENT = 2000 OR L-EVENT = 2004
             OR L-EVENT = 2009 OR L-EVENT = 2010 OR L-EVENT = 2011 OR L-EVENT = 2012
             OR (L-EVENT >= 3002 AND L-EVENT <= 3007) OR L-EVENT = 3009
             OR (L-EVENT >= 3011 AND L-EVENT <= 3021)
             MOVE 1 TO L-KIND
         WHEN OTHER
             MOVE 0 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-EVENT-ROUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-FACE-BURST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-OFF                 FLOAT-LONG.
 01 WS-ROLL                FLOAT-LONG.
 01 WS-STEP.
    05 WS-S                BINARY-LONG OCCURS 3 TIMES.
 01 WS-SPEED.
    05 WS-SP               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-ZERO-C              BINARY-DOUBLE VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-MASK                 BINARY-LONG.
 01 L-NAME                 PIC X(40).
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-SIDE                 FLOAT-LONG.
 01 L-YOFF                 FLOAT-LONG.
 01 L-HALF                 FLOAT-LONG.
 01 L-RDOWN                FLOAT-LONG.
 01 L-RUP                  FLOAT-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-MASK L-NAME L-MIN L-MAX L-SIDE L-YOFF L-HALF L-RDOWN L-RUP P6-EMITS.
     MOVE L-MASK TO WS-MASK
     PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 5
         COMPUTE WS-BIT = FUNCTION MOD(WS-MASK, 2)
         COMPUTE WS-MASK = WS-MASK / 2
         IF WS-BIT NOT = 0
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-N = L-MIN + FUNCTION INTEGER-PART(WS-R * (L-MAX - L-MIN + 1))
             CALL "P6-DIRECTION-STEP" USING WS-DIR WS-STEP
             MOVE 0 TO WS-ROLL
             IF WS-DIR = 0
                 MOVE L-RDOWN TO WS-ROLL
             END-IF
             IF WS-DIR = 1
                 MOVE L-RUP TO WS-ROLL
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
                 INITIALIZE WS-PV
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-SP(WS-A) = WS-R * 2 * L-HALF - L-HALF
                 END-PERFORM
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     IF WS-S(WS-A) NOT = 0
                         MOVE L-SIDE TO WS-OFF
                         IF WS-A = 2
                             MOVE L-YOFF TO WS-OFF
                         END-IF
                         COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + WS-S(WS-A) * WS-OFF
                     ELSE
                         CALL "P6-DRAW" USING P6-EMITS WS-R
                         COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + (WS-R - 0.5)
                         MOVE WS-SP(WS-A) TO WS-V(WS-A + 3)
                     END-IF
                 END-PERFORM
                 CALL "P6-EMIT" USING P6-EMITS L-NAME WS-PV
                 CALL "P6-EMIT-OPTION" USING P6-EMITS WS-ZERO-C WS-ROLL WS-ZERO
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P6-FACE-BURST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-SPAWN-PARTICLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-ZERO-C              BINARY-DOUBLE VALUE 0.
 01 WS-ZERO-S              FLOAT-LONG VALUE 0.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-COUNT                BINARY-LONG.
 01 L-SPREAD               FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-IGNORE               BINARY-LONG.
 01 L-NAME                 PIC X(40).
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-COUNT L-SPREAD L-HEIGHT L-IGNORE L-NAME P6-EMITS.
     MOVE 0 TO WS-FLOOR
     IF L-IGNORE = 0
         MOVE 1 TO WS-FLOOR
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         INITIALIZE WS-PV
         PERFORM VARYING WS-A FROM 4 BY 1 UNTIL WS-A > 6
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A) = WS-R * 0.02
         END-PERFORM
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(1) = L-PP(1) + (0.5 - L-SPREAD) + WS-R * L-SPREAD * 2
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(2) = L-PP(2) + WS-R * L-HEIGHT
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(3) = L-PP(3) + (0.5 - L-SPREAD) + WS-R * L-SPREAD * 2
         CALL "P6-EMIT" USING P6-EMITS L-NAME WS-PV
         CALL "P6-EMIT-OPTION" USING P6-EMITS WS-ZERO-C WS-ZERO-S WS-FLOOR
     END-PERFORM
     GOBACK.
 END PROGRAM P6-SPAWN-PARTICLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EV-SPAWN-FX.
*> Spawn particles of 3011 / 3012 / 3021 (flame by data) and the 3020 omen: USING block, kind (0 smoke and flame, 1 trial_omen and soul_fire_flame
*> with velocity rg * 0.02), flame name, emits: 20 times p = centre + (rd - 0.5) * 2 per axis (three draws), then (kind 1) three Gaussian draws.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               PIC X(40) VALUE "smoke".
 01 WS-OMEN                PIC X(40) VALUE "trial_omen".
 01 WS-R                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-KIND                 BINARY-LONG.
 01 L-FLAME                PIC X(40).
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-KIND L-FLAME P6-EMITS.
     PERFORM 20 TIMES
         INITIALIZE WS-PV
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + (WS-R - 0.5) * 2
         END-PERFORM
         IF L-KIND = 0
             CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
         ELSE
             PERFORM VARYING WS-A FROM 4 BY 1 UNTIL WS-A > 6
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(WS-A) = WS-R * 0.02
             END-PERFORM
             CALL "P6-EMIT" USING P6-EMITS WS-OMEN WS-PV
         END-IF
         CALL "P6-EMIT" USING P6-EMITS L-FLAME WS-PV
     END-PERFORM
     GOBACK.
 END PROGRAM P6-EV-SPAWN-FX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EV-XZ.
*> Position (X + rd, Y + 1.2, Z + rd) with the x then z draws: USING block, emits, six floats out (position part).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 01 L-PV.
    05 L-V                 FLOAT-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-P P6-EMITS L-PV.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE L-V(1) = L-PP(1) + WS-R
     COMPUTE L-V(2) = L-PP(2) + 1.2
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE L-V(3) = L-PP(3) + WS-R
     GOBACK.
 END PROGRAM P6-EV-XZ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EV-GAUSS.
*> Velocity rg * 0.02 on each axis from three Gaussian draws: USING emits, six floats (entries 4 to 6 set).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-PV.
    05 L-V                 FLOAT-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING P6-EMITS L-PV.
     PERFORM VARYING WS-A FROM 4 BY 1 UNTIL WS-A > 6
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE L-V(WS-A) = WS-R * 0.02
     END-PERFORM
     GOBACK.
 END PROGRAM P6-EV-GAUSS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EV-SCATTER.
*> Repeated scatter emissions: USING block, kind, count, emits. Kind 1 (large_smoke) and 2 (cloud): (X + rd, Y + 1.2, Z + rd), draws x, z; kind 3
*> (smoke, 1502): (X + rd * 0.6 + 0.2, ...) on all axes; kind 4 (smoke, 1503): (X + (5 + rd * 6) / 16, Y + 0.8125, Z + (5 + rd * 6) / 16);
*> kind 5 (poof, 3018): (X + rd, Y + rd, Z + rd) with velocity rg * 0.02 (three Gaussian draws after the position); kind 6 (small_flame then
*> smoke, 3014 / 3017): P + 0.4 + rd * 0.2 with velocity rg * 0.02, the flame's vz times 0.25.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N1                  PIC X(40).
 01 WS-N2                  PIC X(40) VALUE "smoke".
 01 WS-R                   FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-KIND                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-KIND L-COUNT P6-EMITS.
     EVALUATE L-KIND
         WHEN 1
             MOVE "large_smoke" TO WS-N1
         WHEN 2
             MOVE "cloud" TO WS-N1
         WHEN 5
             MOVE "poof" TO WS-N1
         WHEN 6
             MOVE "small_flame" TO WS-N1
         WHEN OTHER
             MOVE "smoke" TO WS-N1
     END-EVALUATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         INITIALIZE WS-PV
         EVALUATE L-KIND
             WHEN 1
                 CALL "P6-EV-XZ" USING L-P P6-EMITS WS-PV
             WHEN 2
                 CALL "P6-EV-XZ" USING L-P P6-EMITS WS-PV
             WHEN 3
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R * 0.6 + 0.2
                 END-PERFORM
             WHEN 4
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(1) = L-PP(1) + (5 + WS-R * 6) / 16
                 COMPUTE WS-V(2) = L-PP(2) + 0.8125
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(3) = L-PP(3) + (5 + WS-R * 6) / 16
             WHEN 5
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R
                 END-PERFORM
                 CALL "P6-EV-GAUSS" USING P6-EMITS WS-PV
             WHEN OTHER
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.4 + WS-R * 0.2
                 END-PERFORM
                 CALL "P6-EV-GAUSS" USING P6-EMITS WS-PV
         END-EVALUATE
         IF L-KIND = 6
             MOVE WS-V(6) TO WS-VZ
             COMPUTE WS-V(6) = WS-VZ * 0.25
             CALL "P6-EMIT" USING P6-EMITS WS-N1 WS-PV
             MOVE WS-VZ TO WS-V(6)
             CALL "P6-EMIT" USING P6-EMITS WS-N2 WS-PV
         ELSE
             CALL "P6-EMIT" USING P6-EMITS WS-N1 WS-PV
         END-IF
     END-PERFORM
     GOBACK.

 END PROGRAM P6-EV-SCATTER.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EV-DISPENSER.
*> 2000 / 2010 shootParticles: USING block, direction index, name (PIC X(40)), emits: 10 times s = rd * 0.2 + 0.01 (a draw first), then the axis draws
*> x, y, z: x = P.x + step.x * 0.6 + 0.5 + step.x * 0.01 + (rd - 0.5) * step.z * 0.5, y likewise with step.y on both terms, z with step.x; then the
*> velocity step * s + rg * 0.01 (three Gaussian draws).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-STEP.
    05 WS-ST               BINARY-LONG OCCURS 3 TIMES.
 01 WS-U.
    05 WS-UU               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-DIR                  BINARY-LONG.
 01 L-NAME                 PIC X(40).
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-DIR L-NAME P6-EMITS.
     CALL "P6-DIRECTION-STEP" USING L-DIR WS-STEP
     PERFORM 10 TIMES
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-S = WS-R * 0.2 + 0.01
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             CALL "P6-DRAW" USING P6-EMITS WS-R
             MOVE WS-R TO WS-UU(WS-A)
         END-PERFORM
         COMPUTE WS-V(1) = L-PP(1) + WS-ST(1) * 0.6 + 0.5 + WS-ST(1) * 0.01 + (WS-UU(1) - 0.5) * WS-ST(3) * 0.5
         COMPUTE WS-V(2) = L-PP(2) + WS-ST(2) * 0.6 + 0.5 + WS-ST(2) * 0.01 + (WS-UU(2) - 0.5) * WS-ST(2) * 0.5
         COMPUTE WS-V(3) = L-PP(3) + WS-ST(3) * 0.6 + 0.5 + WS-ST(3) * 0.01 + (WS-UU(3) - 0.5) * WS-ST(1) * 0.5
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A + 3) = WS-ST(WS-A) * WS-S + WS-R * 0.01
         END-PERFORM
         CALL "P6-EMIT" USING P6-EMITS L-NAME WS-PV
     END-PERFORM
     GOBACK.
 END PROGRAM P6-EV-DISPENSER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EV-ALONG-AXIS.
*> 3002 with a valid axis: spawnParticlesAlongAxis(axis, P, 0.125, electric_spark, UniformInt(10, 19)): USING block, axis, emits: a count draw, per
*> particle three position draws (Mth.nextDouble(-1, 1), spread 0.5 on the axis) and one velocity draw on the axis.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "electric_spark".
 01 WS-R                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-AXIS                 BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-AXIS P6-EMITS.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-COUNT = 10 + FUNCTION INTEGER-PART(WS-R * 10)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         INITIALIZE WS-PV
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             MOVE 0.125 TO WS-K
             IF WS-A = L-AXIS + 1
                 MOVE 0.5 TO WS-K
             END-IF
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + (2 * WS-R - 1) * WS-K
         END-PERFORM
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-A = L-AXIS + 4
         COMPUTE WS-V(WS-A) = 2 * WS-R - 1
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM
     GOBACK.
 END PROGRAM P6-EV-ALONG-AXIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EV-SCULK.
*> 3006: USING block, data (charge * 64 + face mask), full block flag, emits. charge > 0: a draw rf < 0.3 + charge * 0.1 (the `sculk_charge` sound); no
*> mask: the six faces, count UniformInt(0, charge), offset 0.57 (0.65 on Y), roll pi on DOWN; else the faces of the mask, offset 0.35, roll pi on UP;
*> speed Mth.nextDouble(-0.005, 0.005). charge 0 (a pop): 40 particles at spread 0.45 on a full block, else 20 at 0.25: v = 2 rf - 1 per axis;
*> `sculk_charge_pop` at P + 0.5 + v * spread, velocity v * 0.07.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "sculk_charge".
 01 WS-POP                 PIC X(40) VALUE "sculk_charge_pop".
 01 WS-SOUND               PIC X(40) VALUE "sculk_charge".
 01 WS-R                   FLOAT-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-ALL                 BINARY-LONG VALUE 63.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-YOFF                FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.005.
 01 WS-PI                  FLOAT-LONG VALUE 3.141592653589793.
 01 WS-NOROLL              FLOAT-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SPREAD              FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-DATA                 BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-DATA L-FULL P6-EMITS.
     COMPUTE WS-CHARGE = L-DATA / 64
     COMPUTE WS-MASK = FUNCTION MOD(L-DATA, 64)
     IF WS-CHARGE > 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         IF WS-R < 0.3 + WS-CHARGE * 0.1
             CALL "P6-EMIT-SOUND" USING P6-EMITS WS-SOUND
         END-IF
         IF WS-MASK = 0
             MOVE 0.57 TO WS-SIDE
             MOVE 0.65 TO WS-YOFF
             CALL "P6-FACE-BURST" USING L-P WS-ALL WS-N WS-ZERO WS-CHARGE WS-SIDE WS-YOFF WS-HALF WS-PI WS-NOROLL P6-EMITS
         ELSE
             MOVE 0.35 TO WS-SIDE
             MOVE 0.35 TO WS-YOFF
             CALL "P6-FACE-BURST" USING L-P WS-MASK WS-N WS-ZERO WS-CHARGE WS-SIDE WS-YOFF WS-HALF WS-NOROLL WS-PI P6-EMITS
         END-IF
     ELSE
         MOVE 20 TO WS-COUNT
         MOVE 0.25 TO WS-SPREAD
         IF L-FULL NOT = 0
             MOVE 40 TO WS-COUNT
             MOVE 0.45 TO WS-SPREAD
         END-IF
         PERFORM WS-COUNT TIMES
             INITIALIZE WS-PV
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(WS-A + 3) = (2 * WS-R - 1) * 0.07
                 COMPUTE WS-V(WS-A) = L-PP(WS-A) + 0.5 + (2 * WS-R - 1) * WS-SPREAD
             END-PERFORM
             CALL "P6-EMIT" USING P6-EMITS WS-POP WS-PV
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM P6-EV-SCULK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EV-DETECT.
*> 3013 / 3019 / 3020 addDetectPlayerParticles: USING block, count of detected players (0 for 3020), name, emits: 30 + min(count, 10) * 5 times dx =
*> (2 rf - 1) * 0.65, dz likewise, then a draw for y: the particle at (X + 0.5 + dx, Y + 0.1 + rf * 0.8, Z + 0.5 + dz).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-COUNT                BINARY-LONG.
 01 L-NAME                 PIC X(40).
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-COUNT L-NAME P6-EMITS.
     MOVE L-COUNT TO WS-N
     IF WS-N > 10
         MOVE 10 TO WS-N
     END-IF
     COMPUTE WS-N = 30 + WS-N * 5
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         INITIALIZE WS-PV
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(1) = L-PP(1) + 0.5 + (2 * WS-R - 1) * 0.65
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(3) = L-PP(3) + 0.5 + (2 * WS-R - 1) * 0.65
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(2) = L-PP(2) + 0.1 + WS-R * 0.8
         CALL "P6-EMIT" USING P6-EMITS L-NAME WS-PV
     END-PERFORM
     GOBACK.
 END PROGRAM P6-EV-DETECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-LEVEL-EVENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40).
 01 WS-FLAME               PIC X(40).
 01 WS-R                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SPREAD              FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IGNORE              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ALL                 BINARY-LONG VALUE 63.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SIDE                FLOAT-LONG VALUE 0.55.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-NOROLL              FLOAT-LONG VALUE 0.
 01 WS-NOROLL2             FLOAT-LONG VALUE 0.
 01 WS-YOFF                FLOAT-LONG VALUE 0.55.
 01 WS-ZERO-C              BINARY-DOUBLE VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-VAULT-PROPS.
    05 WS-VP               BINARY-LONG OCCURS 12 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-EVENT L-DATA L-P L-PROPS P6-EMITS.
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     INITIALIZE WS-PV
     EVALUATE L-EVENT
         WHEN 1500
             COMPUTE WS-H = L-PR(1) / 1000 + 0.03125
             PERFORM 10 TIMES
                 PERFORM VARYING WS-A FROM 4 BY 1 UNTIL WS-A > 6
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A) = WS-R * 0.02
                 END-PERFORM
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(1) = L-PP(1) + 0.1875 + 0.625 * WS-R
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(2) = L-PP(2) + WS-H + WS-R * (1 - WS-H)
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(3) = L-PP(3) + 0.1875 + 0.625 * WS-R
                 MOVE "composter" TO WS-N
                 CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
             END-PERFORM
         WHEN 1501
             MOVE 1 TO WS-KIND
             MOVE 8 TO WS-COUNT
             CALL "P6-EV-SCATTER" USING L-P WS-KIND WS-COUNT P6-EMITS
         WHEN 1502
             MOVE 3 TO WS-KIND
             MOVE 5 TO WS-COUNT
             CALL "P6-EV-SCATTER" USING L-P WS-KIND WS-COUNT P6-EMITS
         WHEN 1503
             MOVE 4 TO WS-KIND
             MOVE 16 TO WS-COUNT
             CALL "P6-EV-SCATTER" USING L-P WS-KIND WS-COUNT P6-EMITS
         WHEN 1504
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
         WHEN 1505
             MOVE L-DATA TO WS-COUNT
             MOVE 0.5 TO WS-SPREAD
             COMPUTE WS-HEIGHT = L-PR(3) / 1000
             MOVE 1 TO WS-IGNORE
             IF L-PR(1) NOT = 0
                 COMPUTE WS-COUNT = L-DATA * 3
                 MOVE 3.0 TO WS-SPREAD
                 MOVE 1.0 TO WS-HEIGHT
                 MOVE 0 TO WS-IGNORE
             END-IF
             MOVE "happy_villager" TO WS-N
             CALL "P6-SPAWN-PARTICLES" USING L-P WS-COUNT WS-SPREAD WS-HEIGHT WS-IGNORE WS-N P6-EMITS
         WHEN 2000
             MOVE "smoke" TO WS-N
             CALL "P6-EV-DISPENSER" USING L-P L-DATA WS-N P6-EMITS
         WHEN 2010
             MOVE "white_smoke" TO WS-N
             CALL "P6-EV-DISPENSER" USING L-P L-DATA WS-N P6-EMITS
         WHEN 2004
             MOVE "flame" TO WS-FLAME
             MOVE 0 TO WS-KIND
             CALL "P6-EV-SPAWN-FX" USING L-P WS-KIND WS-FLAME P6-EMITS
         WHEN 2009
             MOVE 2 TO WS-KIND
             MOVE 8 TO WS-COUNT
             CALL "P6-EV-SCATTER" USING L-P WS-KIND WS-COUNT P6-EMITS
         WHEN 2011
             MOVE "happy_villager" TO WS-N
             MOVE 0.5 TO WS-SPREAD
             COMPUTE WS-HEIGHT = L-PR(3) / 1000
             MOVE 1 TO WS-IGNORE
             CALL "P6-SPAWN-PARTICLES" USING L-P L-DATA WS-SPREAD WS-HEIGHT WS-IGNORE WS-N P6-EMITS
         WHEN 2012
             MOVE "happy_villager" TO WS-N
             MOVE 0.5 TO WS-SPREAD
             COMPUTE WS-HEIGHT = L-PR(3) / 1000
             MOVE 1 TO WS-IGNORE
             CALL "P6-SPAWN-PARTICLES" USING L-P L-DATA WS-SPREAD WS-HEIGHT WS-IGNORE WS-N P6-EMITS
         WHEN 3002
             IF L-DATA >= 0 AND L-DATA <= 2
                 CALL "P6-EV-ALONG-AXIS" USING L-P L-DATA P6-EMITS
             ELSE
                 MOVE "electric_spark" TO WS-N
                 MOVE 3 TO WS-MIN
                 MOVE 5 TO WS-MAX
                 CALL "P6-FACE-BURST" USING L-P WS-ALL WS-N WS-MIN WS-MAX WS-SIDE WS-YOFF WS-HALF WS-NOROLL WS-NOROLL2 P6-EMITS
             END-IF
         WHEN 3003
             MOVE "wax_on" TO WS-N
             MOVE 3 TO WS-MIN
             MOVE 5 TO WS-MAX
             CALL "P6-FACE-BURST" USING L-P WS-ALL WS-N WS-MIN WS-MAX WS-SIDE WS-YOFF WS-HALF WS-NOROLL WS-NOROLL2 P6-EMITS
         WHEN 3004
             MOVE "wax_off" TO WS-N
             MOVE 3 TO WS-MIN
             MOVE 5 TO WS-MAX
             CALL "P6-FACE-BURST" USING L-P WS-ALL WS-N WS-MIN WS-MAX WS-SIDE WS-YOFF WS-HALF WS-NOROLL WS-NOROLL2 P6-EMITS
         WHEN 3005
             MOVE "scrape" TO WS-N
             MOVE 3 TO WS-MIN
             MOVE 5 TO WS-MAX
             CALL "P6-FACE-BURST" USING L-P WS-ALL WS-N WS-MIN WS-MAX WS-SIDE WS-YOFF WS-HALF WS-NOROLL WS-NOROLL2 P6-EMITS
         WHEN 3006
             CALL "P6-EV-SCULK" USING L-P L-DATA L-PR(1) P6-EMITS
         WHEN 3007
             MOVE "shriek" TO WS-N
             COMPUTE WS-V(1) = L-PP(1) + 0.5
             COMPUTE WS-V(2) = L-PP(2) + 0.5
             COMPUTE WS-V(3) = L-PP(3) + 0.5
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 9
                 COMPUTE WS-STATE = WS-I * 5
                 CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
                 CALL "P6-EMIT-OPTION" USING P6-EMITS WS-ZERO-C WS-NOROLL WS-STATE
             END-PERFORM
         WHEN 3009
             MOVE "egg_crack" TO WS-N
             MOVE 3 TO WS-MIN
             MOVE 6 TO WS-MAX
             CALL "P6-FACE-BURST" USING L-P WS-ALL WS-N WS-MIN WS-MAX WS-SIDE WS-YOFF WS-HALF WS-NOROLL WS-NOROLL2 P6-EMITS
         WHEN 3011
         WHEN 3012
         WHEN 3021
             MOVE "flame" TO WS-FLAME
             IF L-DATA NOT = 0
                 MOVE "soul_fire_flame" TO WS-FLAME
             END-IF
             MOVE 0 TO WS-KIND
             CALL "P6-EV-SPAWN-FX" USING L-P WS-KIND WS-FLAME P6-EMITS
         WHEN 3013
             MOVE "trial_spawner_detected_player" TO WS-N
             CALL "P6-EV-DETECT" USING L-P L-DATA WS-N P6-EMITS
         WHEN 3019
             MOVE "trial_spawner_detected_player_ominous" TO WS-N
             CALL "P6-EV-DETECT" USING L-P L-DATA WS-N P6-EMITS
         WHEN 3020
             MOVE "trial_spawner_detected_player_ominous" TO WS-N
             CALL "P6-EV-DETECT" USING L-P WS-ZERO WS-N P6-EMITS
             MOVE "soul_fire_flame" TO WS-FLAME
             MOVE 1 TO WS-KIND
             CALL "P6-EV-SPAWN-FX" USING L-P WS-KIND WS-FLAME P6-EMITS
         WHEN 3014
         WHEN 3017
             MOVE 6 TO WS-KIND
             MOVE 20 TO WS-COUNT
             CALL "P6-EV-SCATTER" USING L-P WS-KIND WS-COUNT P6-EMITS
         WHEN 3018
             MOVE 5 TO WS-KIND
             MOVE 10 TO WS-COUNT
             CALL "P6-EV-SCATTER" USING L-P WS-KIND WS-COUNT P6-EMITS
         WHEN 3015
             INITIALIZE WS-VAULT-PROPS
             MOVE 1 TO WS-VP(1)
             IF L-DATA NOT = 0
                 MOVE 1 TO WS-VP(3)
             END-IF
             CALL "P6-D-VAULT" USING L-P WS-VAULT-PROPS P6-EMITS
         WHEN 3016
             INITIALIZE WS-VAULT-PROPS
             MOVE 2 TO WS-VP(1)
             IF L-DATA NOT = 0
                 MOVE 1 TO WS-VP(3)
             END-IF
             CALL "P6-D-VAULT" USING L-P WS-VAULT-PROPS P6-EMITS
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-LEVEL-EVENT.
