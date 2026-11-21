*> Dispensers, droppers, hoppers and crafters (docs/protocol/30 part 4) as programs of plain numbers (RS2- prefix): each takes the facts the caller read from
*> the level (flags, counts, the random draws) and returns the decision, its level events and its scaled results (x 1e6 positions, x 1e7 velocities),
*> like the growth helpers (GC5-) do. They are helpers: nothing here is wired into the block-update hooks. Directions: 1 north, 2 east, 3 south, 4 west,
*> 5 up, 6 down. Behaviours of the registry of 3.2 are numbered 1 projectile, 2 armor stand, 3 chest, 4 boat, 5 filled bucket, 6 bucket, 7 wither skull,
*> 8 carved pumpkin, 9 equipment, 10 flint and steel, 11 spawn egg, 12 sulfur swallow, 13 bone meal, 14 TNT, 15 shulker box, 16 glass bottle,
*> 17 glowstone, 18 shears, 19 brush, 20 honeycomb, 21 potion, 22 minecart, 0 the default.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DIR-OPPOSITE.
*> USING direction, opposite out (directions 1 north, 2 east, 3 south, 4 west, 5 up, 6 down): the opposite direction.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-O.
     IF L-D < 5
         COMPUTE L-O = FUNCTION MOD(L-D + 1, 4) + 1
     ELSE
         COMPUTE L-O = 11 - L-D
     END-IF
     GOBACK.
 END PROGRAM RS2-DIR-OPPOSITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DISP-FACING.
*> USING the nearest looking direction, facing out (30-4 1.1): the block faces away from the way the placer looks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-F.
     CALL "RS2-DIR-OPPOSITE" USING L-N L-F
     GOBACK.
 END PROGRAM RS2-DISP-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DISP-STATE.
*> USING facing, triggered, TRIGGER_DURATION, slot count out (30-4 1.1): default state north, not triggered, 4, 9 slots.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-T L-D L-S.
     MOVE 1 TO L-F
     MOVE 0 TO L-T
     MOVE 4 TO L-D
     MOVE 9 TO L-S
     GOBACK.
 END PROGRAM RS2-DISP-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-USE-STAT.
*> USING kind (1 dispenser, 2 dropper, 3 hopper), statistic out (the inspect_dispenser, inspect_dropper, inspect_hopper kinds), result out (30-4 1.1, 5.1: the use is SUCCESS, 1, in every case).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-S L-R.
     MOVE L-K TO L-S
     MOVE 1 TO L-R
     GOBACK.
 END PROGRAM RS2-USE-STAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DISP-POWERED.
*> USING hasNeighborSignal at the position, hasNeighborSignal at the position above, powered out (30-4 1.2 step 1: quasi-connectivity).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-P.
     MOVE 0 TO L-P
     IF L-A = 1 OR L-B = 1
         MOVE 1 TO L-P
     END-IF
     GOBACK.
 END PROGRAM RS2-DISP-POWERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DISP-NEIGHBOR.
*> USING powered, triggered, schedule out, delay out, new triggered out, update flags out, action out (30-4 1.2 steps 2 to 4; action 1 rise, 2 fall, 0 none).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-T L-S L-D L-N L-F L-A.
     MOVE 0 TO L-S L-D L-F L-A
     MOVE L-T TO L-N
     IF L-P = 1 AND L-T = 0
         MOVE 1 TO L-S L-N L-A
         MOVE 4 TO L-D
         MOVE 2 TO L-F
     END-IF
     IF L-P = 0 AND L-T = 1
         MOVE 0 TO L-N
         MOVE 2 TO L-F L-A
     END-IF
     GOBACK.
 END PROGRAM RS2-DISP-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DISP-SIM.
*> USING the signal of ticks 0 to 11 (twelve BINARY-LONG), dispenses out, tick of the first dispense out or -1 (30-4 1.2 and worked example 1): each tick runs the neighbour change; every rising edge schedules a dispense 4 ticks later and the schedule is never cancelled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T BINARY-LONG.
 01 WS-K BINARY-LONG.
 01 WS-SCH BINARY-LONG.
 01 WS-DLY BINARY-LONG.
 01 WS-NEW BINARY-LONG.
 01 WS-FLG BINARY-LONG.
 01 WS-ACT BINARY-LONG.
 01 WS-SIGS.
    05 WS-SIG BINARY-LONG OCCURS 12 TIMES.
 LINKAGE SECTION.
 01 L-S1                   BINARY-LONG.
 01 L-S2                   BINARY-LONG.
 01 L-S3                   BINARY-LONG.
 01 L-S4                   BINARY-LONG.
 01 L-S5                   BINARY-LONG.
 01 L-S6                   BINARY-LONG.
 01 L-S7                   BINARY-LONG.
 01 L-S8                   BINARY-LONG.
 01 L-S9                   BINARY-LONG.
 01 L-S10                  BINARY-LONG.
 01 L-S11                  BINARY-LONG.
 01 L-S12                  BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S1 L-S2 L-S3 L-S4 L-S5 L-S6 L-S7 L-S8 L-S9 L-S10 L-S11 L-S12 L-C L-F.
     MOVE 0 TO L-C WS-T
     MOVE -1 TO L-F
     MOVE L-S1 TO WS-SIG(1)
     MOVE L-S2 TO WS-SIG(2)
     MOVE L-S3 TO WS-SIG(3)
     MOVE L-S4 TO WS-SIG(4)
     MOVE L-S5 TO WS-SIG(5)
     MOVE L-S6 TO WS-SIG(6)
     MOVE L-S7 TO WS-SIG(7)
     MOVE L-S8 TO WS-SIG(8)
     MOVE L-S9 TO WS-SIG(9)
     MOVE L-S10 TO WS-SIG(10)
     MOVE L-S11 TO WS-SIG(11)
     MOVE L-S12 TO WS-SIG(12)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
         CALL "RS2-DISP-NEIGHBOR" USING WS-SIG(WS-K) WS-T WS-SCH WS-DLY WS-NEW WS-FLG WS-ACT
         MOVE WS-NEW TO WS-T
         IF WS-SCH = 1
             ADD 1 TO L-C
             IF L-F < 0
                 COMPUTE L-F = WS-K - 1 + WS-DLY
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS2-DISP-SIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DISP-EMPTY.
*> USING slot choice (negative when empty), is dropper, proceed out, level event out, game event out (30-4 1.3 step 3, 1.4 step 2): an empty choice plays 1001, and the dispenser alone fires the game event block_activate (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-D L-P L-E L-G.
     MOVE 1 TO L-P
     MOVE 0 TO L-E L-G
     IF L-S < 0
         MOVE 0 TO L-P
         MOVE 1001 TO L-E
         IF L-D = 0
             MOVE 1 TO L-G
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-DISP-EMPTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DISP-APPLY.
*> USING behaviour is NOOP, slot is written out (30-4 1.3 step 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-W.
     MOVE 1 TO L-W
     IF L-N = 1
         MOVE 0 TO L-W
     END-IF
     GOBACK.
 END PROGRAM RS2-DISP-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DROPPER-RUN.
*> USING slot choice, stack is empty, a container is in front, addItem left nothing, stack count, outcome out (0 stop, 1 default behaviour, 2 container), level event out, new count out, slot written out (30-4 1.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-E L-C L-R L-N L-O L-V L-M L-W.
     MOVE 0 TO L-O L-V L-W
     MOVE L-N TO L-M
     EVALUATE TRUE
         WHEN L-S < 0
             MOVE 1001 TO L-V
         WHEN L-E = 1
             MOVE 0 TO L-O
         WHEN L-C = 0
             MOVE 1 TO L-O L-W
             COMPUTE L-M = L-N - 1
         WHEN OTHER
             MOVE 2 TO L-O
             MOVE 1 TO L-W
             IF L-R = 1
                 COMPUTE L-M = L-N - 1
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-DROPPER-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DROPPER-FACING.
*> USING the facing of the state passed to the tick, the facing of the block state in the world, facing used out (30-4 1.4 step 4: the world state wins).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-W L-F.
     MOVE L-W TO L-F
     GOBACK.
 END PROGRAM RS2-DROPPER-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-QUASI.
*> USING kind (1 dispenser, 2 crafter, 3 hopper), the offset of a power source from the block (dx, dy, dz), powered out (30-4 1.2, 6.1, 5.1): a source next to the block powers it; only the dispenser also counts a source next to the block above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D0 BINARY-LONG.
 01 WS-D1 BINARY-LONG.
 01 WS-Y1 BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-P.
     MOVE 0 TO L-P
     COMPUTE WS-D0 = FUNCTION ABS(L-X) + FUNCTION ABS(L-Y) + FUNCTION ABS(L-Z)
     COMPUTE WS-Y1 = L-Y - 1
     COMPUTE WS-D1 = FUNCTION ABS(L-X) + FUNCTION ABS(WS-Y1) + FUNCTION ABS(L-Z)
     IF WS-D0 = 1
         MOVE 1 TO L-P
     END-IF
     IF L-K = 1 AND WS-D1 = 1
         MOVE 1 TO L-P
     END-IF
     GOBACK.
 END PROGRAM RS2-QUASI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-FACING-DATA.
*> USING direction (1 north .. 6 down), 3D data value out (30-4 2): down 0, up 1, north 2, south 3, west 4, east 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-V.
     EVALUATE L-D
         WHEN 1
             MOVE 2 TO L-V
         WHEN 2
             MOVE 5 TO L-V
         WHEN 3
             MOVE 3 TO L-V
         WHEN 4
             MOVE 4 TO L-V
         WHEN 5
             MOVE 1 TO L-V
         WHEN OTHER
             MOVE 0 TO L-V
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-FACING-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DEF-PLAY.
*> USING kind (1 default, 2 Optional with success, 3 Optional failed), facing, sound event out, animation event out, animation data out (30-4 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-F L-S L-A L-D.
     MOVE 1000 TO L-S
     IF L-K = 3
         MOVE 1001 TO L-S
     END-IF
     MOVE 2000 TO L-A
     CALL "RS2-FACING-DATA" USING L-F L-D
     GOBACK.
 END PROGRAM RS2-DEF-PLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-LEVEL-SOUND.
*> USING level event id, r1, r2 (the client random draws), category out (0 unknown, 1 blocks, 2 neutral, 3 hostile), volume x 1000 out, pitch x 1e6 out (30-4 2 table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-C                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-R1 L-R2 L-C L-V L-P.
     MOVE 1 TO L-C
     MOVE 1000 TO L-V
     MOVE 1000000 TO L-P
     EVALUATE L-I
         WHEN 1000
             MOVE 1000000 TO L-P
         WHEN 1001
             MOVE 1200000 TO L-P
         WHEN 1002
             MOVE 1200000 TO L-P
         WHEN 1004
             MOVE 2 TO L-C
             MOVE 1200000 TO L-P
         WHEN 1018
             MOVE 3 TO L-C
             MOVE 2000 TO L-V
             COMPUTE L-P ROUNDED = ((L-R1 - L-R2) * 0.2 + 1.0) * 1000000
         WHEN 1049
             MOVE 1000000 TO L-P
         WHEN 1050
             MOVE 1000000 TO L-P
         WHEN 1051
             MOVE 500 TO L-V
             COMPUTE L-P ROUNDED = (0.4 / (L-R1 * 0.4 + 0.8)) * 1000000
         WHEN OTHER
             MOVE 0 TO L-C L-V L-P
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-LEVEL-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-TRIANGLE.
*> USING c, d, r1, r2 (FLOAT-LONG), value x 1e7 out (30-4 2): triangle(c, d) = c + d * (r1 - r2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    FLOAT-LONG.
 01 L-D                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-V                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-D L-A L-B L-V.
     COMPUTE L-V ROUNDED = (L-C + L-D * (L-A - L-B)) * 10000000
     GOBACK.
 END PROGRAM RS2-TRIANGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DISPENSE-POS.
*> USING the block x, y, z, the facing step x, y, z, offset, extra y (FLOAT-LONG), position x, y, z (x 1e6) out (30-4 2): centre + offset * step + extra.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-O                    FLOAT-LONG.
 01 L-E                    FLOAT-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-SX L-SY L-SZ L-O L-E L-PX L-PY L-PZ.
     COMPUTE L-PX ROUNDED = (L-X + 0.5 + L-O * L-SX) * 1000000
     COMPUTE L-PY ROUNDED = (L-Y + 0.5 + L-O * L-SY + L-E) * 1000000
     COMPUTE L-PZ ROUNDED = (L-Z + 0.5 + L-O * L-SZ) * 1000000
     GOBACK.
 END PROGRAM RS2-DISPENSE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SPAWN-POS.
*> USING the facing axis is Y, y of the position (FLOAT-LONG), y out x 1e6 (30-4 2): y - 0.125 on the Y axis, else y - 0.15625.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-Y L-R.
     IF L-A = 1
         COMPUTE L-R ROUNDED = (L-Y - 0.125) * 1000000
     ELSE
         COMPUTE L-R ROUNDED = (L-Y - 0.15625) * 1000000
     END-IF
     GOBACK.
 END PROGRAM RS2-SPAWN-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SPAWN-MOTION.
*> USING the facing step x, y, z, accuracy, the draws speed, x1, x2, y1, y2, z1, z2 (FLOAT-LONG), motion x, y, z (x 1e7) out (30-4 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SP FLOAT-LONG.
 01 WS-U FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-D                    FLOAT-LONG.
 01 L-X1                   FLOAT-LONG.
 01 L-X2                   FLOAT-LONG.
 01 L-Y1                   FLOAT-LONG.
 01 L-Y2                   FLOAT-LONG.
 01 L-Z1                   FLOAT-LONG.
 01 L-Z2                   FLOAT-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VY                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-A L-D L-X1 L-X2 L-Y1 L-Y2 L-Z1 L-Z2 L-VX L-VY L-VZ.
     COMPUTE WS-SP = L-D * 0.1 + 0.2
     COMPUTE WS-U = 0.0172275 * L-A
     COMPUTE L-VX ROUNDED = (L-SX * WS-SP + WS-U * (L-X1 - L-X2)) * 10000000
     COMPUTE L-VY ROUNDED = (0.2 + WS-U * (L-Y1 - L-Y2)) * 10000000
     COMPUTE L-VZ ROUNDED = (L-SZ * WS-SP + WS-U * (L-Z1 - L-Z2)) * 10000000
     GOBACK.
 END PROGRAM RS2-SPAWN-MOTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CONSUME.
*> USING the stack count before shrink, the remainder fits (insertItem leaves nothing), kind out (0 the remainder becomes the slot, 1 stack kept and remainder inserted, 2 stack kept and the leftover dropped), new count out, dropped out (30-4 2 consumeWithRemainder).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-F L-K L-N L-D.
     MOVE 0 TO L-K L-N L-D
     IF L-C > 1
         COMPUTE L-N = L-C - 1
         MOVE 1 TO L-K
         IF L-F = 0
             MOVE 2 TO L-K
             MOVE 1 TO L-D
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-CONSUME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DEFAULT-EXEC.
*> USING the stack count, new count out (30-4 2): one item is split off.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-N.
     COMPUTE L-N = L-C - 1
     GOBACK.
 END PROGRAM RS2-DEFAULT-EXEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-FALLBACK-EVENTS.
*> USING the fallback is a second default object, events 1000 out, events 2000 out (30-4 4 intro): the doubled click and smoke.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-A L-B.
     MOVE 1 TO L-A L-B
     IF L-D = 1
         MOVE 2 TO L-A L-B
     END-IF
     GOBACK.
 END PROGRAM RS2-FALLBACK-EVENTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-REG-CHOOSE.
*> USING the item is enabled, the registered behaviour (0 none), has equippable, is in the tag sulfur_cube_swallowable, is a spawn egg, has entity_data, behaviour out (30-4 3.1; 0 default, 9 equipment, 11 spawn egg, 12 sulfur swallow, otherwise the registered number of 3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-Q                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-R L-Q L-W L-G L-D L-B.
     EVALUATE TRUE
         WHEN L-N = 0
             MOVE 0 TO L-B
         WHEN L-R > 0
             MOVE L-R TO L-B
         WHEN L-Q = 1
             MOVE 9 TO L-B
         WHEN L-W = 1
             MOVE 12 TO L-B
         WHEN L-G = 1 AND L-D = 1
             MOVE 11 TO L-B
         WHEN OTHER
             MOVE 0 TO L-B
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-REG-CHOOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-REG-ITEM.
*> USING the item name (32 characters), behaviour out (0 not registered), projectile index out (the order of the projectile row of 30-4 3.2, 0 for the others): the registry of 3.2 by behaviour number: 1 projectile, 2 armor stand, 3 chest, 4 boat, 5 filled bucket, 6 bucket, 7 wither skull, 8 carved pumpkin, 10 flint and steel, 13 bone meal, 14 TNT, 15 shulker box, 16 glass bottle, 17 glowstone, 18 shears, 19 brush, 20 honeycomb, 21 potion, 22 minecart.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REG-DATA.
    05 FILLER PIC X(32) VALUE "arrow".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(32) VALUE "tipped_arrow".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(32) VALUE "spectral_arrow".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(32) VALUE "egg".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "blue_egg".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(32) VALUE "brown_egg".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(32) VALUE "snowball".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "experience_bottle".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(32) VALUE "splash_potion".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(32) VALUE "lingering_potion".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "firework_rocket".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(32) VALUE "fire_charge".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "wind_charge".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC X(32) VALUE "armor_stand".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "chest".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "oak_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "spruce_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "birch_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "jungle_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "dark_oak_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "acacia_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "cherry_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "mangrove_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "poplar_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "pale_oak_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "bamboo_raft".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "oak_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "spruce_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "birch_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "jungle_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "dark_oak_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "acacia_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "cherry_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "mangrove_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "poplar_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "pale_oak_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "bamboo_chest_raft".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "lava_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "water_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "powder_snow_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "salmon_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "cod_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "pufferfish_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "tropical_fish_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "axolotl_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "sulfur_cube_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "tadpole_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "bucket".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "flint_and_steel".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "bone_meal".
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "tnt".
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "wither_skeleton_skull".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "carved_pumpkin".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "white_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "orange_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "magenta_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "light_blue_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "yellow_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "lime_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "pink_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "gray_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "light_gray_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "cyan_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "purple_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "blue_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "brown_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "green_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "red_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "black_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "glass_bottle".
    05 FILLER PIC 99 VALUE 16.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "glowstone".
    05 FILLER PIC 99 VALUE 17.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "shears".
    05 FILLER PIC 99 VALUE 18.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "brush".
    05 FILLER PIC 99 VALUE 19.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "honeycomb".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "potion".
    05 FILLER PIC 99 VALUE 21.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "chest_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "furnace_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "tnt_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "hopper_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "command_block_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
 01 WS-REG REDEFINES WS-REG-DATA.
    05 WS-ROW OCCURS 82 TIMES.
       10 WS-NAME PIC X(32).
       10 WS-ID PIC 99.
       10 WS-SUB PIC 99.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    PIC X(32).
 01 L-B                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-B L-S.
     MOVE 0 TO L-B L-S
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 82
         IF WS-NAME(WS-I) = L-N
             MOVE WS-ID(WS-I) TO L-B
             MOVE WS-SUB(WS-I) TO L-S
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS2-REG-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-REG-COUNT.
*> USING a behaviour number (0 for all), the number of registered items with it out (30-4 3.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REG-DATA.
    05 FILLER PIC X(32) VALUE "arrow".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(32) VALUE "tipped_arrow".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(32) VALUE "spectral_arrow".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(32) VALUE "egg".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "blue_egg".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(32) VALUE "brown_egg".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(32) VALUE "snowball".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "experience_bottle".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(32) VALUE "splash_potion".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(32) VALUE "lingering_potion".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "firework_rocket".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(32) VALUE "fire_charge".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "wind_charge".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC X(32) VALUE "armor_stand".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "chest".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "oak_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "spruce_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "birch_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "jungle_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "dark_oak_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "acacia_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "cherry_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "mangrove_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "poplar_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "pale_oak_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "bamboo_raft".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "oak_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "spruce_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "birch_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "jungle_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "dark_oak_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "acacia_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "cherry_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "mangrove_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "poplar_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "pale_oak_chest_boat".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "bamboo_chest_raft".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "lava_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "water_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "powder_snow_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "salmon_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "cod_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "pufferfish_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "tropical_fish_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "axolotl_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "sulfur_cube_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "tadpole_bucket".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "bucket".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "flint_and_steel".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "bone_meal".
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "tnt".
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "wither_skeleton_skull".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "carved_pumpkin".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "white_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "orange_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "magenta_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "light_blue_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "yellow_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "lime_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "pink_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "gray_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "light_gray_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "cyan_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "purple_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "blue_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "brown_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "green_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "red_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "black_shulker_box".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "glass_bottle".
    05 FILLER PIC 99 VALUE 16.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "glowstone".
    05 FILLER PIC 99 VALUE 17.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "shears".
    05 FILLER PIC 99 VALUE 18.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "brush".
    05 FILLER PIC 99 VALUE 19.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "honeycomb".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "potion".
    05 FILLER PIC 99 VALUE 21.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "chest_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "furnace_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "tnt_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "hopper_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "command_block_minecart".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 0.
 01 WS-REG REDEFINES WS-REG-DATA.
    05 WS-ROW OCCURS 82 TIMES.
       10 WS-NAME PIC X(32).
       10 WS-ID PIC 99.
       10 WS-SUB PIC 99.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 PROCEDURE DIVISION USING L-B L-C.
     MOVE 0 TO L-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 82
         IF L-B = 0 OR WS-ID(WS-I) = L-B
             ADD 1 TO L-C
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS2-REG-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SWALLOWABLE.
*> USING an archetype name (32 characters), swallowable out (30-4 4.12): the item tag sulfur_cube_swallowable lists 12 tag references under sulfur_cube_archetype/.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SW-DATA.
    05 FILLER PIC X(32) VALUE "bouncy".
    05 FILLER PIC X(32) VALUE "regular".
    05 FILLER PIC X(32) VALUE "slow_flat".
    05 FILLER PIC X(32) VALUE "fast_flat".
    05 FILLER PIC X(32) VALUE "light".
    05 FILLER PIC X(32) VALUE "fast_sliding".
    05 FILLER PIC X(32) VALUE "slow_sliding".
    05 FILLER PIC X(32) VALUE "sticky".
    05 FILLER PIC X(32) VALUE "high_resistance".
    05 FILLER PIC X(32) VALUE "explosive".
    05 FILLER PIC X(32) VALUE "hot".
    05 FILLER PIC X(32) VALUE "slow_bouncy".
 01 WS-SWT REDEFINES WS-SW-DATA.
    05 WS-SWN PIC X(32) OCCURS 12 TIMES.
 01 WS-J BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    PIC X(32).
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-S.
     MOVE 0 TO L-S
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 12
         IF WS-SWN(WS-J) = L-N
             MOVE 1 TO L-S
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS2-SWALLOWABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PROJ-CONFIG.
*> USING the projectile index (the order of the projectile row of 30-4 3.2, 1 to 13), position kind out (0 centre + 0.7 step + y 0.1, 1 firework, 2 charge), uncertainty x 1e7 out,
*> power x 1e7 out, sound event out, level-random draws of asProjectile out, projectile draws of shoot out (30-4 4.1 table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-K L-U L-W L-E L-A L-S.
     MOVE 0 TO L-K
     MOVE 60000000 TO L-U
     MOVE 11000000 TO L-W
     MOVE 1002 TO L-E
     MOVE 0 TO L-A
     MOVE 6 TO L-S
     EVALUATE TRUE
         WHEN L-I >= 8 AND L-I <= 10
             MOVE 30000000 TO L-U
             MOVE 13750000 TO L-W
         WHEN L-I = 11
             MOVE 1 TO L-K
             MOVE 10000000 TO L-U
             MOVE 5000000 TO L-W
             MOVE 1004 TO L-E
         WHEN L-I = 12
             MOVE 2 TO L-K
             MOVE 66666665 TO L-U
             MOVE 10000000 TO L-W
             MOVE 1018 TO L-E
             MOVE 6 TO L-A
         WHEN L-I = 13
             MOVE 2 TO L-K
             MOVE 66666665 TO L-U
             MOVE 10000000 TO L-W
             MOVE 1051 TO L-E
             MOVE 6 TO L-A
         WHEN OTHER
             MOVE 0 TO L-K
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-PROJ-CONFIG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PROJ-POSITION.
*> USING position kind (0, 1, 2 of RS2-PROJ-CONFIG), the block x, y, z, the facing step x, y, z, position x, y, z (x 1e6) out (30-4 4.1): centre + 0.7 * step + (0, 0.1, 0),
*> centre + 0.5000099999997474 * step, centre + 1.0 * step.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-O07 FLOAT-LONG VALUE 0.7.
 01 WS-E01 FLOAT-LONG VALUE 0.1.
 01 WS-O05 FLOAT-LONG VALUE 0.5000099999997474.
 01 WS-E00 FLOAT-LONG VALUE 0.
 01 WS-O10 FLOAT-LONG VALUE 1.0.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-SX L-SY L-SZ L-PX L-PY L-PZ.
     EVALUATE L-K
         WHEN 0
             CALL "RS2-DISPENSE-POS" USING L-X L-Y L-Z L-SX L-SY L-SZ WS-O07 WS-E01 L-PX L-PY L-PZ
         WHEN 1
             CALL "RS2-DISPENSE-POS" USING L-X L-Y L-Z L-SX L-SY L-SZ WS-O05 WS-E00 L-PX L-PY L-PZ
         WHEN OTHER
             CALL "RS2-DISPENSE-POS" USING L-X L-Y L-Z L-SX L-SY L-SZ WS-O10 WS-E00 L-PX L-PY L-PZ
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-PROJ-POSITION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CHARGE-VELOCITY.
*> USING the facing step x, y, z, normalise (the fire charge 1, the wind charge 0), the six level draws x1, x2, y1, y2, z1, z2 (FLOAT-LONG), velocity x, y, z (x 1e7) out (30-4 4.1):
*> v = triangle(step, 0.11485000000000001) per axis.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X FLOAT-LONG.
 01 WS-Y FLOAT-LONG.
 01 WS-Z FLOAT-LONG.
 01 WS-LEN FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-A1                   FLOAT-LONG.
 01 L-A2                   FLOAT-LONG.
 01 L-B1                   FLOAT-LONG.
 01 L-B2                   FLOAT-LONG.
 01 L-C1                   FLOAT-LONG.
 01 L-C2                   FLOAT-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VY                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-N L-A1 L-A2 L-B1 L-B2 L-C1 L-C2 L-VX L-VY L-VZ.
     COMPUTE WS-X = L-SX + 0.11485000000000001 * (L-A1 - L-A2)
     COMPUTE WS-Y = L-SY + 0.11485000000000001 * (L-B1 - L-B2)
     COMPUTE WS-Z = L-SZ + 0.11485000000000001 * (L-C1 - L-C2)
     IF L-N = 1
         COMPUTE WS-LEN = FUNCTION SQRT(WS-X * WS-X + WS-Y * WS-Y + WS-Z * WS-Z)
         COMPUTE WS-X = WS-X / WS-LEN
         COMPUTE WS-Y = WS-Y / WS-LEN
         COMPUTE WS-Z = WS-Z / WS-LEN
     END-IF
     COMPUTE L-VX ROUNDED = WS-X * 10000000
     COMPUTE L-VY ROUNDED = WS-Y * 10000000
     COMPUTE L-VZ ROUNDED = WS-Z * 10000000
     GOBACK.
 END PROGRAM RS2-CHARGE-VELOCITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SHOOT-VELOCITY.
*> USING the direction x, y, z, power, uncertainty (FLOAT-LONG), the six projectile draws x1, x2, y1, y2, z1, z2 (FLOAT-LONG), velocity x, y, z (x 1e7) out (30-4 4.1 step 3):
*> (normalize(d) + triangle(0, 0.0172275 * uncertainty)) * power per axis.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN FLOAT-LONG.
 01 WS-K FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-W                    FLOAT-LONG.
 01 L-U                    FLOAT-LONG.
 01 L-A1                   FLOAT-LONG.
 01 L-A2                   FLOAT-LONG.
 01 L-B1                   FLOAT-LONG.
 01 L-B2                   FLOAT-LONG.
 01 L-C1                   FLOAT-LONG.
 01 L-C2                   FLOAT-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VY                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-W L-U L-A1 L-A2 L-B1 L-B2 L-C1 L-C2 L-VX L-VY L-VZ.
     COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ)
     COMPUTE WS-K = 0.0172275 * L-U
     COMPUTE L-VX ROUNDED = (L-DX / WS-LEN + WS-K * (L-A1 - L-A2)) * L-W * 10000000
     COMPUTE L-VY ROUNDED = (L-DY / WS-LEN + WS-K * (L-B1 - L-B2)) * L-W * 10000000
     COMPUTE L-VZ ROUNDED = (L-DZ / WS-LEN + WS-K * (L-C1 - L-C2)) * L-W * 10000000
     GOBACK.
 END PROGRAM RS2-SHOOT-VELOCITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ARMORSTAND.
*> USING a stand was spawned, the facing, the front block x, y, z, the stack count, new count out, yaw out, position x, y, z (x 1e6) out (30-4 4.2): the stand stands at the bottom centre of the front block and
*> looks the way the dispenser points (north 180, east 270, south 0, west 90, up and down 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-F L-X L-Y L-Z L-C L-N L-R L-PX L-PY L-PZ.
     COMPUTE L-N = L-C - L-S
     EVALUATE L-F
         WHEN 1
             MOVE 180 TO L-R
         WHEN 2
             MOVE 270 TO L-R
         WHEN 4
             MOVE 90 TO L-R
         WHEN OTHER
             MOVE 0 TO L-R
     END-EVALUATE
     COMPUTE L-PX = L-X * 1000000 + 500000
     COMPUTE L-PY = L-Y * 1000000
     COMPUTE L-PZ = L-Z * 1000000 + 500000
     GOBACK.
 END PROGRAM RS2-ARMORSTAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CHEST-TAKE.
*> USING the stack count, the number of horses (0 to 4), then for each horse: is tamed, slot 499 accepted the chest; taker index out (0 none), new count out, success out, dropped out (30-4 4.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I BINARY-LONG.
 01 WS-TT.
    05 WS-T BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-T1                   BINARY-LONG.
 01 L-S1                   BINARY-LONG.
 01 L-T2                   BINARY-LONG.
 01 L-S2                   BINARY-LONG.
 01 L-T3                   BINARY-LONG.
 01 L-S3                   BINARY-LONG.
 01 L-T4                   BINARY-LONG.
 01 L-S4                   BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-N L-T1 L-S1 L-T2 L-S2 L-T3 L-S3 L-T4 L-S4 L-K L-M L-U L-D.
     MOVE 0 TO L-K
     MOVE L-C TO L-M
     MOVE 0 TO L-U
     MOVE 0 TO WS-T(1) WS-T(2) WS-T(3) WS-T(4)
     IF L-T1 = 1 AND L-S1 = 1
         MOVE 1 TO WS-T(1)
     END-IF
     IF L-T2 = 1 AND L-S2 = 1
         MOVE 1 TO WS-T(2)
     END-IF
     IF L-T3 = 1 AND L-S3 = 1
         MOVE 1 TO WS-T(3)
     END-IF
     IF L-T4 = 1 AND L-S4 = 1
         MOVE 1 TO WS-T(4)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N OR L-K > 0
         IF WS-T(WS-I) = 1
             MOVE WS-I TO L-K
         END-IF
     END-PERFORM
     IF L-K > 0
         COMPUTE L-M = L-C - 1
         MOVE 1 TO L-U
         MOVE 0 TO L-D
     ELSE
         MOVE 1 TO L-D
     END-IF
     GOBACK.
 END PROGRAM RS2-CHEST-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BOAT.
*> USING the boat width (FLOAT-LONG), the dispenser x, y, z, the facing step x, y, z, water in front, air in front, water below the front block, placed out, x, y, z (x 1e6) out, doubled events out
*> (30-4 4.4): d = 0.5625 + width / 2; y gets stepY * 1.125 and yOffset 1.0 (water) or 0.0 (air above water); else the second default object.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFF FLOAT-LONG.
 01 WS-DIST FLOAT-LONG.
 LINKAGE SECTION.
 01 L-W                    FLOAT-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-X L-Y L-Z L-SX L-SY L-SZ L-A L-B L-C L-P L-PX L-PY L-PZ L-D.
     MOVE 1 TO L-P
     MOVE 0 TO L-D
     MOVE 0 TO L-PX L-PY L-PZ
     EVALUATE TRUE
         WHEN L-A = 1
             MOVE 1.0 TO WS-OFF
         WHEN L-B = 1 AND L-C = 1
             MOVE 0.0 TO WS-OFF
         WHEN OTHER
             MOVE 0 TO L-P
             MOVE 1 TO L-D
     END-EVALUATE
     IF L-P = 1
         COMPUTE WS-DIST = 0.5625 + L-W / 2
         COMPUTE L-PX ROUNDED = (L-X + 0.5 + L-SX * WS-DIST) * 1000000
         COMPUTE L-PY ROUNDED = (L-Y + 0.5 + L-SY * 1.125 + WS-OFF) * 1000000
         COMPUTE L-PZ ROUNDED = (L-Z + 0.5 + L-SZ * WS-DIST) * 1000000
     END-IF
     GOBACK.
 END PROGRAM RS2-BOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUCKET-FILLED.
*> USING emptyContents returned true, consume path out (1 consume with the empty bucket as remainder, 0 fallback), checkExtraContent runs out, doubled events out (30-4 4.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-E                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-E L-P L-X L-D.
     MOVE 0 TO L-P L-X
     MOVE 1 TO L-D
     IF L-E = 1
         MOVE 1 TO L-P L-X
         MOVE 0 TO L-D
     END-IF
     GOBACK.
 END PROGRAM RS2-BUCKET-FILLED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUCKET-EMPTY.
*> USING the front block is a BucketPickup, the pickup gave an empty stack, path out (1 pickup with remainder, 0 base execute once), game event fluid_pickup out (30-4 4.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-E L-P L-G.
     MOVE 0 TO L-P L-G
     IF L-K = 1 AND L-E = 0
         MOVE 1 TO L-P L-G
     END-IF
     GOBACK.
 END PROGRAM RS2-BUCKET-EMPTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HEAD-BLOCK.
*> USING kind (1 wither skull, 2 carved pumpkin), the front block is air, the pattern can spawn, dispenseEquipment succeeds, placed out, success out, shrink out, game event block_place out, checkSpawn runs out (30-4 4.7, 4.8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-A L-C L-E L-P L-S L-H L-G L-X.
     MOVE 0 TO L-P L-G L-X
     MOVE L-E TO L-S L-H
     IF L-A = 1 AND L-C = 1
         MOVE 1 TO L-P L-S L-H L-G
         IF L-K = 1
             MOVE 1 TO L-X
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-HEAD-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-EQUIP-CAN.
*> USING alive, spectator (1 when it is one; the test uses not-spectator as 1 here), equippable present, dispensable, canUseSlot, canBeEquippedBy, slot empty, canDispenserEquipIntoSlot, result out (30-4 4.9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-C L-D L-E L-F L-G L-H L-R.
     MOVE 0 TO L-R
     IF L-A = 1 AND L-B = 1 AND L-C = 1 AND L-D = 1 AND L-E = 1 AND L-F = 1 AND L-G = 1 AND L-H = 1
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-EQUIP-CAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-EQUIP-RULE.
*> USING the entity class (0 living, 1 mob, 2 horse, 3 sulfur cube), the slot (1 body, 2 saddle, 3 other), the mob can pick up loot, the horse is tamed, the animal's own rule, result out (30-4 4.9 canDispenserEquipIntoSlot).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-S L-P L-T L-O L-R.
     EVALUATE L-C
         WHEN 0
             MOVE 1 TO L-R
         WHEN 1
             MOVE L-P TO L-R
         WHEN 2
             IF L-S = 1 OR L-S = 2
                 MOVE L-T TO L-R
             ELSE
                 MOVE L-O TO L-R
             END-IF
         WHEN OTHER
             MOVE 0 TO L-R
             IF L-S = 1
                 MOVE 1 TO L-R
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-EQUIP-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-EQUIP-RUN.
*> USING the number of entities that can be equipped, the first is a Mob, success out, shrink out, guaranteed drop out, persistence out, dropped out (30-4 4.9 dispenseEquipment and execute).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-M                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-B L-S L-H L-G L-P L-D.
     MOVE 0 TO L-S L-H L-G L-P
     MOVE 1 TO L-D
     IF L-M > 0
         MOVE 1 TO L-S L-H
         MOVE 0 TO L-D
         IF L-B = 1
             MOVE 1 TO L-G L-P
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-EQUIP-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-FLINT.
*> USING a sulfur cube was primed, fire can be placed, the block can be lit, the block is TNT, TNT.prime returned true, rule out (1 to 5), success out, hurt out, game event out (1 block_place, 2 block_change),
*> block removed out, lit set out (30-4 4.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-L                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Q                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-F L-L L-T L-P L-R L-S L-H L-G L-X L-Q.
     MOVE 0 TO L-S L-G L-X L-Q
     EVALUATE TRUE
         WHEN L-C = 1
             MOVE 1 TO L-R L-S
         WHEN L-F = 1
             MOVE 2 TO L-R
             MOVE 1 TO L-S L-G
         WHEN L-L = 1
             MOVE 3 TO L-R
             MOVE 1 TO L-S L-Q
             MOVE 2 TO L-G
         WHEN L-T = 1
             MOVE 4 TO L-R
             IF L-P = 1
                 MOVE 1 TO L-S L-X
             END-IF
         WHEN OTHER
             MOVE 5 TO L-R
     END-EVALUATE
     MOVE L-S TO L-H
     GOBACK.
 END PROGRAM RS2-FLINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-EGG.
*> USING the egg has no entity type, the facing is up, the spawn returned null, an exception was raised, alignPosition out, result out (0 unchanged, 1 one item less, 2 empty stack), game event entity_place out (30-4 4.11).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-U L-S L-E L-A L-R L-G.
     MOVE 0 TO L-A L-R L-G
     IF L-N = 0
         MOVE 1 TO L-A
         IF L-U = 1
             MOVE 0 TO L-A
         END-IF
         EVALUATE TRUE
             WHEN L-E = 1
                 MOVE 2 TO L-R
             WHEN L-S = 1
                 MOVE 0 TO L-R
             WHEN OTHER
                 MOVE 1 TO L-R L-G
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM RS2-EGG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SULFUR-EQUIP.
*> USING the cube is a baby, the stack is the same item as the body, a body item exists, ok out, previous body spawned out (30-4 4.12 SulfurCube.equipItem).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-B                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-B L-S L-H L-O L-W.
     MOVE 0 TO L-O L-W
     IF L-B = 0 AND L-S = 0
         MOVE 1 TO L-O
         MOVE L-H TO L-W
     END-IF
     GOBACK.
 END PROGRAM RS2-SULFUR-EQUIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SULFUR-DISPENSE.
*> USING the equipItem results of up to four cubes in order, index of the first that took the item out (0 none), shrink out, result out (30-4 4.12 dispenseBlock).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-C L-D L-I L-S L-R.
     MOVE 0 TO L-I
     EVALUATE TRUE
         WHEN L-A = 1
             MOVE 1 TO L-I
         WHEN L-B = 1
             MOVE 2 TO L-I
         WHEN L-C = 1
             MOVE 3 TO L-I
         WHEN L-D = 1
             MOVE 4 TO L-I
         WHEN OTHER
             MOVE 0 TO L-I
     END-EVALUATE
     MOVE 0 TO L-S L-R
     IF L-I > 0
         MOVE 1 TO L-S L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-SULFUR-DISPENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BONEMEAL.
*> USING growCrop returned true, growWaterPlant returned true, the level is a client, success out, level event out (1505 or 0), event data out (30-4 4.13).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-W L-K L-S L-E L-D.
     MOVE 0 TO L-S L-E
     MOVE 15 TO L-D
     IF L-C = 1 OR L-W = 1
         MOVE 1 TO L-S
         IF L-K = 0
             MOVE 1505 TO L-E
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-BONEMEAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-TNT.
*> USING tnt_explodes, a sulfur cube swallowed the item, the shared success flag before, the front block x, y, z, path out (0 refused, 1 swallowed, 2 primed), success out, shrink out, TNT_PRIMED sound out, game event entity_place out,
*> primed position x, y, z (x 1e6) out (30-4 4.14).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-E                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-E L-W L-V L-X L-Y L-Z L-P L-S L-H L-N L-G L-PX L-PY L-PZ.
     MOVE 0 TO L-P L-S L-H L-N L-G L-PX L-PY L-PZ
     EVALUATE TRUE
         WHEN L-E = 0
             MOVE 0 TO L-S
         WHEN L-W = 1
             MOVE 1 TO L-P
             MOVE L-V TO L-S
         WHEN OTHER
             MOVE 2 TO L-P
             MOVE 1 TO L-S L-H L-N L-G
             COMPUTE L-PX = L-X * 1000000 + 500000
             COMPUTE L-PY = L-Y * 1000000
             COMPUTE L-PZ = L-Z * 1000000 + 500000
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-TNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SHULKER.
*> USING the item is a BlockItem, the block below the front block is empty, the facing, consumesAction, the up direction out, success out (30-4 4.15).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-B                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-B L-E L-F L-C L-U L-S.
     MOVE 5 TO L-U
     IF L-E = 1
         MOVE L-F TO L-U
     END-IF
     MOVE 0 TO L-S
     IF L-B = 1
         MOVE L-C TO L-S
     END-IF
     GOBACK.
 END PROGRAM RS2-SHULKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BOTTLE.
*> USING the front block is a beehive with honey_level 5 or more, the front fluid is water, path out (1 hive, 2 water, 3 drop), success out, remainder out (1 honey bottle, 2 water potion), game event fluid_pickup out, dropped out (30-4 4.16).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-H L-W L-P L-S L-R L-G L-D.
     MOVE 0 TO L-R L-G L-D L-S
     EVALUATE TRUE
         WHEN L-H = 1
             MOVE 1 TO L-P L-S L-R L-G
         WHEN L-W = 1
             MOVE 2 TO L-P
             MOVE 1 TO L-S L-G
             MOVE 2 TO L-R
         WHEN OTHER
             MOVE 3 TO L-P
             MOVE 1 TO L-D
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-BOTTLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-GLOWSTONE.
*> USING the front block is a respawn anchor, its charge, dropped out, shrink out, success out, charged out (30-4 4.17).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-C L-D L-H L-S L-G.
     MOVE 0 TO L-D L-H L-S L-G
     IF L-A = 0
         MOVE 1 TO L-D L-S
     END-IF
     IF L-A = 1 AND L-C NOT = 4
         MOVE 1 TO L-H L-S L-G
     END-IF
     GOBACK.
 END PROGRAM RS2-GLOWSTONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SHEARS.
*> USING the level is a client, the front block is a beehive with honey_level 5 or more, the first entity result (1 leash cut, 2 sheared, 0 none), success out, hurt out, which out (1 beehive, 2 leash, 3 shear) (30-4 4.18).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-B L-E L-S L-H L-W.
     MOVE 0 TO L-S L-H L-W
     EVALUATE TRUE
         WHEN L-C = 1
             MOVE 0 TO L-W
         WHEN L-B = 1
             MOVE 1 TO L-S L-H L-W
         WHEN L-E = 1
             MOVE 1 TO L-S L-H
             MOVE 2 TO L-W
         WHEN L-E = 2
             MOVE 1 TO L-S L-H
             MOVE 3 TO L-W
         WHEN OTHER
             MOVE 0 TO L-W
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-SHEARS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BRUSH.
*> USING the number of armadillos in the front box, the index of the first that gave a scute (0 none), the shared success flag before, new success out, durability out, click event out (30-4 4.19):
*> the flag is never set back to true.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-A L-P L-S L-H L-E.
     MOVE 0 TO L-S L-H
     MOVE 1001 TO L-E
     IF L-N > 0 AND L-A > 0
         MOVE L-P TO L-S
         MOVE 16 TO L-H
         IF L-S = 1
             MOVE 1000 TO L-E
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-BRUSH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HONEYCOMB.
*> USING a waxed state exists for the front block, wax written out, level event out, wax sound out, shrink out, success out, dropped out (30-4 4.20).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-X L-E L-S L-H L-C L-D.
     MOVE 0 TO L-X L-E L-S L-H L-D
     MOVE 1 TO L-C
     IF L-W = 1
         MOVE 1 TO L-X L-S L-H
         MOVE 3003 TO L-E
     ELSE
         MOVE 1 TO L-D
     END-IF
     GOBACK.
 END PROGRAM RS2-HONEYCOMB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-POTION.
*> USING the potion is the water potion, the front block is convertible_to_mud, path out (1 doubled fallback, 2 mud), splash particles out, BOTTLE_EMPTY sound out, game event fluid_place out, glass bottle remainder out (30-4 4.21).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-C L-P L-N L-S L-G L-B.
     MOVE 1 TO L-P
     MOVE 0 TO L-N L-S L-G L-B
     IF L-W = 1 AND L-C = 1
         MOVE 2 TO L-P
         MOVE 5 TO L-N
         MOVE 1 TO L-S L-G L-B
     END-IF
     GOBACK.
 END PROGRAM RS2-POTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-MINECART.
*> USING the dispenser block x, y, z, the facing step x, y, z, the front block is a rail, the front rail is a slope, the front is air, the block below it is a rail, that rail is a slope, placed out, x, y, z (x 1e6) out
*> (30-4 4.22): x and z are centre + step * 1.125, y is the block y + stepY + yOffset.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFF FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-FR                   BINARY-LONG.
 01 L-FS                   BINARY-LONG.
 01 L-FA                   BINARY-LONG.
 01 L-BR                   BINARY-LONG.
 01 L-BS                   BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-SX L-SY L-SZ L-FR L-FS L-FA L-BR L-BS L-P L-PX L-PY L-PZ.
     MOVE 1 TO L-P
     EVALUATE TRUE
         WHEN L-FR = 1 AND L-FS = 1
             MOVE 0.6 TO WS-OFF
         WHEN L-FR = 1
             MOVE 0.1 TO WS-OFF
         WHEN L-FA = 1 AND L-BR = 1 AND (L-SY = -1 OR L-BS = 0)
             MOVE -0.9 TO WS-OFF
         WHEN L-FA = 1 AND L-BR = 1
             MOVE -0.4 TO WS-OFF
         WHEN OTHER
             MOVE 0 TO L-P
     END-EVALUATE
     MOVE 0 TO L-PX L-PY L-PZ
     IF L-P = 1
         COMPUTE L-PX ROUNDED = (L-X + 0.5 + L-SX * 1.125) * 1000000
         COMPUTE L-PY ROUNDED = (L-Y + L-SY + WS-OFF) * 1000000
         COMPUTE L-PZ ROUNDED = (L-Z + 0.5 + L-SZ * 1.125) * 1000000
     END-IF
     GOBACK.
 END PROGRAM RS2-MINECART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SPAWN-YAW.
*> USING the level-random draw nextFloat (FLOAT-LONG), yaw x 1e6 out (30-4 4.2, 4.11): nextFloat * 360.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-Y.
     COMPUTE L-Y ROUNDED = L-R * 360 * 1000000
     GOBACK.
 END PROGRAM RS2-SPAWN-YAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HOPPER-FACING.
*> USING the clicked face, facing out (30-4 5.1): the opposite of the clicked face, a vertical result replaced by down.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-F.
     IF L-C >= 5
         MOVE 6 TO L-F
     ELSE
         CALL "RS2-DIR-OPPOSITE" USING L-C L-F
     END-IF
     GOBACK.
 END PROGRAM RS2-HOPPER-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HOPPER-STATE.
*> USING facing out, enabled out (30-4 5.1 defaults).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-E.
     MOVE 6 TO L-F
     MOVE 1 TO L-E
     GOBACK.
 END PROGRAM RS2-HOPPER-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HOPPER-ENABLE.
*> USING hasNeighborSignal at the hopper position, enabled, shouldEnable out, write out, update flags out (30-4 5.1 checkPoweredState: no quasi-connectivity).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-E L-N L-W L-F.
     COMPUTE L-N = 1 - L-S
     MOVE 0 TO L-W L-F
     IF L-N NOT = L-E
         MOVE 1 TO L-W
         MOVE 2 TO L-F
     END-IF
     GOBACK.
 END PROGRAM RS2-HOPPER-ENABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HOPPER-ACTIVE.
*> USING enabled, tryMoveItems runs out, item entity pickup out, pushes from containers accepted out (30-4 5.1 locked by signal).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-E                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 PROCEDURE DIVISION USING L-E L-M L-P L-A.
     MOVE L-E TO L-M L-P
     MOVE 1 TO L-A
     GOBACK.
 END PROGRAM RS2-HOPPER-ACTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HOPPER-SPOUT.
*> USING facing (1 to 4 or 6), the spout box x0, y0, z0, x1, y1, z1 in sixteenths out (30-4 5.2 step 2: boxZ(4, 4, 8, 0, 8) turned about (8, 6, 8) and clipped to the block).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     EVALUATE L-F
         WHEN 1
             MOVE 6 TO L-X0
             MOVE 4 TO L-Y0
             MOVE 0 TO L-Z0
             MOVE 10 TO L-X1
             MOVE 8 TO L-Y1
             MOVE 8 TO L-Z1
         WHEN 2
             MOVE 8 TO L-X0
             MOVE 4 TO L-Y0
             MOVE 6 TO L-Z0
             MOVE 16 TO L-X1
             MOVE 8 TO L-Y1
             MOVE 10 TO L-Z1
         WHEN 3
             MOVE 6 TO L-X0
             MOVE 4 TO L-Y0
             MOVE 8 TO L-Z0
             MOVE 10 TO L-X1
             MOVE 8 TO L-Y1
             MOVE 16 TO L-Z1
         WHEN 4
             MOVE 0 TO L-X0
             MOVE 4 TO L-Y0
             MOVE 6 TO L-Z0
             MOVE 8 TO L-X1
             MOVE 8 TO L-Y1
             MOVE 10 TO L-Z1
         WHEN OTHER
             MOVE 6 TO L-X0
             MOVE 0 TO L-Y0
             MOVE 6 TO L-Z0
             MOVE 10 TO L-X1
             MOVE 6 TO L-Y1
             MOVE 10 TO L-Z1
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-HOPPER-SPOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HOPPER-BOWL.
*> USING the part (1 ring, 2 neck, 3 removed cavity), the box x0, y0, z0, x1, y1, z1 in sixteenths out (30-4 5.2 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     EVALUATE L-P
         WHEN 1
             MOVE 0 TO L-X0 L-Z0
             MOVE 10 TO L-Y0
             MOVE 16 TO L-X1 L-Y1 L-Z1
         WHEN 2
             MOVE 4 TO L-X0 L-Y0 L-Z0
             MOVE 12 TO L-X1 L-Z1
             MOVE 10 TO L-Y1
         WHEN OTHER
             MOVE 2 TO L-X0 L-Z0
             MOVE 11 TO L-Y0
             MOVE 14 TO L-X1 L-Z1
             MOVE 16 TO L-Y1
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-HOPPER-BOWL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HOPPER-STUB.
*> USING facing (1 to 4 or 6), stub present out, the stub box x0, y0, z0, x1, y1, z1 in sixteenths out (30-4 5.2, interaction shape: boxZ(4, 8, 10, 0, 4) turned to a horizontal facing; down has none).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-P L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 1 TO L-P
     MOVE 8 TO L-Y0
     MOVE 10 TO L-Y1
     EVALUATE L-F
         WHEN 1
             MOVE 6 TO L-X0
             MOVE 0 TO L-Z0
             MOVE 10 TO L-X1
             MOVE 4 TO L-Z1
         WHEN 2
             MOVE 12 TO L-X0
             MOVE 6 TO L-Z0
             MOVE 16 TO L-X1
             MOVE 10 TO L-Z1
         WHEN 3
             MOVE 6 TO L-X0
             MOVE 12 TO L-Z0
             MOVE 10 TO L-X1
             MOVE 16 TO L-Z1
         WHEN 4
             MOVE 0 TO L-X0
             MOVE 6 TO L-Z0
             MOVE 4 TO L-X1
             MOVE 10 TO L-Z1
         WHEN OTHER
             MOVE 0 TO L-P L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-HOPPER-STUB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HOPPER-HANDOFF.
*> USING the item went into an empty destination, the destination is a hopper, it is on a custom cooldown, the source is a hopper, the destination's tickedGameTime, the source's, cooldown out (0 unchanged, 8 or 7)
*> (30-4 5.3 item 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-E                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-E L-H L-C L-S L-D L-T L-R.
     MOVE 0 TO L-R
     IF L-E = 1 AND L-H = 1 AND L-C = 0
         MOVE 8 TO L-R
         IF L-S = 1 AND L-D >= L-T
             MOVE 7 TO L-R
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-HOPPER-HANDOFF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-HOPPER-RATE.
*> USING ticks, items moved by a hopper line out, items per second x 10 out (30-4 5.3 item 1: one item per 8 ticks).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-I L-R.
     COMPUTE L-I = L-T / 8
     COMPUTE L-R = 20 * 10 / 8
     GOBACK.
 END PROGRAM RS2-HOPPER-RATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-CONST.
*> USING CRAFTING_TICK_DELAY, MAX_CRAFTING_TICKS, recipe cache entries, advancement box edge out (30-4 6.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-M L-C L-A.
     MOVE 4 TO L-D
     MOVE 6 TO L-M
     MOVE 10 TO L-C
     MOVE 17 TO L-A
     GOBACK.
 END PROGRAM RS2-CRAFTER-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-TOP.
*> USING the front, the horizontal direction of the placer, top out (30-4 6.1 placement).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-H L-T.
     EVALUATE L-F
         WHEN 6
             CALL "RS2-DIR-OPPOSITE" USING L-H L-T
         WHEN 5
             MOVE L-H TO L-T
         WHEN OTHER
             MOVE 5 TO L-T
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-CRAFTER-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-PLACE.
*> USING hasNeighborSignal at the clicked position, triggered out, tick scheduled out (30-4 6.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-T L-K.
     MOVE L-S TO L-T L-K
     GOBACK.
 END PROGRAM RS2-CRAFTER-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-NEIGHBOR.
*> USING the block entity exists, powered (no quasi-connectivity), triggered, crafting, schedule out, new triggered out, new crafting out, update flags out (30-4 6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-E                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-E L-P L-T L-C L-S L-N L-M L-F.
     MOVE 0 TO L-S L-F
     MOVE L-T TO L-N
     MOVE L-C TO L-M
     IF L-E = 1 AND L-P = 1 AND L-T = 0
         MOVE 1 TO L-S L-N
         MOVE 2 TO L-F
     END-IF
     IF L-E = 1 AND L-P = 0 AND L-T = 1
         MOVE 0 TO L-N L-M
         MOVE 2 TO L-F
     END-IF
     GOBACK.
 END PROGRAM RS2-CRAFTER-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-FROM.
*> USING the block entity exists, a recipe matches, assemble gave a non-empty result, outcome out (0 stop, 1 failed, 2 crafted), level event out, crafting ticks out, crafting out, onCraftedBySystem out (30-4 6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-E                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-E L-R L-A L-O L-V L-T L-C L-S.
     MOVE 0 TO L-O L-V L-T L-C L-S
     IF L-E = 1
         IF L-R = 0 OR L-A = 0
             MOVE 1 TO L-O
             MOVE 1050 TO L-V
         ELSE
             MOVE 2 TO L-O
             MOVE 6 TO L-T
             MOVE 1 TO L-C L-S
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-CRAFTER-FROM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-SHRINK.
*> USING a slot's count, new count out (30-4 6.3 step 6): every non-empty slot shrinks by exactly one.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-N.
     MOVE 0 TO L-N
     IF L-C > 0
         COMPUTE L-N = L-C - 1
     END-IF
     GOBACK.
 END PROGRAM RS2-CRAFTER-SHRINK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-PATH.
*> USING a target container exists, the target is a crafter, the stack count, the target's max stack size, path out (0 none, 1 one item at a time, 2 whole stack) (30-4 6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-R L-C L-M L-P.
     MOVE 0 TO L-P
     IF L-T = 1
         MOVE 2 TO L-P
         IF L-R = 1 OR L-C > L-M
             MOVE 1 TO L-P
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-CRAFTER-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-MOVE.
*> USING the path of RS2-CRAFTER-PATH, the count, the room of the target, the rest out (30-4 6.4 steps 1 to 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-C L-R L-N.
     MOVE L-C TO L-N
     IF L-P > 0
         COMPUTE L-N = L-C - L-R
         IF L-N < 0
             MOVE 0 TO L-N
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-CRAFTER-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-AFTER.
*> USING the rest, the front direction, spawn out, advancement trigger out, event 1049 out, event 2010 out, its data out (30-4 6.4 step 4): only a leftover is spawned and announced.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-F L-S L-A L-E L-G L-D.
     MOVE 0 TO L-S L-A L-E L-G L-D
     IF L-R > 0
         MOVE 1 TO L-S L-A
         MOVE 1049 TO L-E
         MOVE 2010 TO L-G
         CALL "RS2-FACING-DATA" USING L-F L-D
     END-IF
     GOBACK.
 END PROGRAM RS2-CRAFTER-AFTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-CRAFTER-DISPENSE.
*> USING a target exists, it is a crafter, the count, the target's max stack size, the room, the front, path out, rest out, spawn, advancement, 1049, 2010, data out (30-4 6.4 as a whole).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-R L-C L-M L-O L-F L-P L-N L-S L-A L-E L-G L-D.
     CALL "RS2-CRAFTER-PATH" USING L-T L-R L-C L-M L-P
     CALL "RS2-CRAFTER-MOVE" USING L-P L-C L-O L-N
     CALL "RS2-CRAFTER-AFTER" USING L-N L-F L-S L-A L-E L-G L-D
     GOBACK.
 END PROGRAM RS2-CRAFTER-DISPENSE.

