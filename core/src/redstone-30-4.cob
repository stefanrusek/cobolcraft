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

