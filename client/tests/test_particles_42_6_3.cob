*> Acceptance test of docs/protocol/42-particles-6-emitters-blocks.md section 3: the block classes' animateTick rules.
*> Expected texts are computed independently by a script from the document's formulas; each case injects the draws in the documented order and
*> compares the emission list (5 decimals), the sounds and the count of draws consumed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-6-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP6EM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-CLASS               PIC X(24).
 01 WS-PT                  PIC X(80).
 01 WS-PRT                 PIC X(80).
 01 WS-DRT                 PIC X(1500).
 01 WS-EXP                 PIC X(2000).
 01 WS-OBS                 PIC X(2000).
 01 WS-BLOCK.
    05 WS-BP               BINARY-LONG OCCURS 3 TIMES.
 01 WS-PROPS.
    05 WS-PR               BINARY-LONG OCCURS 12 TIMES.
 01 WS-LIST.
    05 WS-NUM              FLOAT-LONG OCCURS 140 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(1500).
 01 WS-TOK                 PIC X(40).
 01 WS-PTR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR2                BINARY-LONG.
 01 WS-ED                  PIC -(5)9.99999.
 01 WS-EDC                 PIC -(10)9.
 01 WS-EDS                 PIC 9.99.
 01 WS-V                   FLOAT-LONG.
 01 WS-PW                 BINARY-LONG.
 01 WS-COL                BINARY-DOUBLE.
 01 WS-FA-COUNT           BINARY-LONG.
 01 WS-FA-ROOT            BINARY-LONG.
 01 WS-FA-KIND            BINARY-LONG.
 01 WS-FA-EVAP            BINARY-LONG.
 01 WS-FA-OUT             BINARY-LONG.
 01 WS-DI                 BINARY-LONG.
 01 WS-STEP3.
    05 WS-ST              BINARY-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     MOVE "torch" TO WS-NAME
     MOVE "torch" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE "smoke 10.50000 64.70000 -2.50000 0.00000 0.00000 0.00000 | flame 10.50000 64.70000 -2.5000"
         & "0 0.00000 0.00000 0.00000 (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "soul" TO WS-NAME
     MOVE "torch" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE "smoke 10.50000 64.70000 -2.50000 0.00000 0.00000 0.00000 | soul_fire_flame 10.50000 64.700"
         & "00 -2.50000 0.00000 0.00000 0.00000 (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "copper" TO WS-NAME
     MOVE "torch" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "2" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE "smoke 10.50000 64.70000 -2.50000 0.00000 0.00000 0.00000 | copper_fire_flame 10.50000 64.7"
         & "0000 -2.50000 0.00000 0.00000 0.00000 (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "wall" TO WS-NAME
     MOVE "wall_torch" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 1 0" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE "smoke 10.77000 64.92000 -2.50000 0.00000 0.00000 0.00000 | flame 10.77000 64.92000 -2.5000"
         & "0 0.00000 0.00000 0.00000 (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "wall copper" TO WS-NAME
     MOVE "wall_torch" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "2 0 -1" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE "smoke 10.50000 64.92000 -2.77000 0.00000 0.00000 0.00000 | copper_fire_flame 10.50000 64.9"
         & "2000 -2.77000 0.00000 0.00000 0.00000 (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rt lit" TO WS-NAME
     MOVE "redstone_torch" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.5 0.75 0.25" TO WS-DRT
     MOVE "dust 10.50000 64.75000 -2.55000 0.00000 0.00000 0.00000 c=16711680 s=1.00 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rt unlit" TO WS-NAME
     MOVE "redstone_torch" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rwt" TO WS-NAME
     MOVE "redstone_wall_torch" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 -1" TO WS-PRT
     MOVE "0.1 0.2 0.3" TO WS-DRT
     MOVE "dust 10.42000 64.86000 -2.81000 0.00000 0.00000 0.00000 c=16711680 s=1.00 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rwt unlit" TO WS-NAME
     MOVE "redstone_wall_torch" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 -1" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "end rod hit" TO WS-NAME
     MOVE "end_rod" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 1 0" TO WS-PRT
     MOVE "0.2 0.4 0.6 0.1 0.3 0.1 1.0 -2.0 3.0" TO WS-DRT
     MOVE "end_rod 10.53000 64.75000 -2.51000 0.00500 -0.01000 0.01500 (9)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "end rod miss" TO WS-NAME
     MOVE "end_rod" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 1 0" TO WS-PRT
     MOVE "0.2 0.4 0.6 0.1 0.3 0.5" TO WS-DRT
     MOVE " (6)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "fire floor" TO WS-NAME
     MOVE "fire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 0 0 0 0" TO WS-PRT
     MOVE "0.5 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.1" TO WS-DRT
     MOVE "large_smoke 10.10000 64.60000 -2.70000 0.00000 0.00000 0.00000 | large_smoke 10.40000 64.7"
         & "5000 -2.40000 0.00000 0.00000 0.00000 | large_smoke 10.70000 64.90000 -2.10000 0.00000 0.0"
         & "0000 0.00000 (10)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "fire sound floor" TO WS-NAME
     MOVE "fire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 0 0 0 0" TO WS-PRT
     MOVE "0.01 0.5 0.25 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.1 0.2 0.3" TO WS-DRT
     MOVE "large_smoke 10.10000 64.60000 -2.70000 0.00000 0.00000 0.00000 | large_smoke 10.40000 64.7"
         & "5000 -2.40000 0.00000 0.00000 0.00000 | large_smoke 10.70000 64.90000 -2.10000 0.00000 0.0"
         & "0000 0.00000 # fire.ambient (12)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "fire sides" TO WS-NAME
     MOVE "fire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 1 1 1 1 1" TO WS-PRT
     MOVE "0.5 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.1 0.2 0.3 0."
         & "4 0.5 0.6 0.7 0.8 0.9 0.1 0.2 0.3" TO WS-DRT
     MOVE "large_smoke 10.01000 64.20000 -2.70000 0.00000 0.00000 0.00000 | large_smoke 10.04000 64.5"
         & "0000 -2.40000 0.00000 0.00000 0.00000 | large_smoke 10.93000 64.80000 -2.10000 0.00000 0.0"
         & "0000 0.00000 | large_smoke 10.99000 64.20000 -2.70000 0.00000 0.00000 0.00000 | large_smok"
         & "e 10.40000 64.50000 -2.94000 0.00000 0.00000 0.00000 | large_smoke 10.70000 64.80000 -2.91"
         & "000 0.00000 0.00000 0.00000 | large_smoke 10.10000 64.20000 -2.03000 0.00000 0.00000 0.000"
         & "00 | large_smoke 10.40000 64.50000 -2.06000 0.00000 0.00000 0.00000 | large_smoke 10.70000"
         & " 64.92000 -2.10000 0.00000 0.00000 0.00000 | large_smoke 10.10000 64.98000 -2.70000 0.0000"
         & "0 0.00000 0.00000 (31)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "fire none" TO WS-NAME
     MOVE "fire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "campfire hit" TO WS-NAME
     MOVE "campfire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 1" TO WS-PRT
     MOVE "0.05 0.3 0.4 0.1 0.6 0.2" TO WS-DRT
     MOVE "lava 10.50000 64.50000 -2.50000 0.30000 0.00005 0.10000 # campfire.crackle (6)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "campfire miss" TO WS-NAME
     MOVE "campfire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 1" TO WS-PRT
     MOVE "0.5 0.5" TO WS-DRT
     MOVE " (2)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "campfire flag off" TO WS-NAME
     MOVE "campfire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "campfire unlit" TO WS-NAME
     MOVE "campfire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 1" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "candle 2" TO WS-NAME
     MOVE "candle" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 2" TO WS-PRT
     MOVE "0.1 0.5 0.5 0.5" TO WS-DRT
     MOVE "smoke 10.37500 64.43750 -2.50000 0.00000 0.00000 0.00000 | small_flame 10.37500 64.43750 -"
         & "2.50000 0.00000 0.00000 0.00000 | small_flame 10.62500 64.50000 -2.56250 0.00000 0.00000 0"
         & ".00000 # candle.ambient (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "candle cake" TO WS-NAME
     MOVE "candle" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0" TO WS-PRT
     MOVE "0.2" TO WS-DRT
     MOVE "smoke 10.50000 65.00000 -2.50000 0.00000 0.00000 0.00000 | small_flame 10.50000 65.00000 -"
         & "2.50000 0.00000 0.00000 0.00000 (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "candle unlit" TO WS-NAME
     MOVE "candle" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 3" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "candle 4" TO WS-NAME
     MOVE "candle" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 4" TO WS-PRT
     MOVE "0.9 0.9 0.9 0.9" TO WS-DRT
     MOVE "small_flame 10.43750 64.31250 -2.43750 0.00000 0.00000 0.00000 | small_flame 10.62500 64.4"
         & "3750 -2.43750 0.00000 0.00000 0.00000 | small_flame 10.37500 64.43750 -2.62500 0.00000 0.0"
         & "0000 0.00000 | small_flame 10.56250 64.50000 -2.62500 0.00000 0.00000 0.00000 (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "candle 1" TO WS-NAME
     MOVE "candle" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 1" TO WS-PRT
     MOVE "0.9" TO WS-DRT
     MOVE "small_flame 10.50000 64.50000 -2.50000 0.00000 0.00000 0.00000 (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "candle 3" TO WS-NAME
     MOVE "candle" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 3" TO WS-PRT
     MOVE "0.9 0.9 0.9" TO WS-DRT
     MOVE "small_flame 10.50000 64.31250 -2.37500 0.00000 0.00000 0.00000 | small_flame 10.37500 64.4"
         & "3750 -2.50000 0.00000 0.00000 0.00000 | small_flame 10.56250 64.50000 -2.56250 0.00000 0.0"
         & "0000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "furnace x" TO WS-NAME
     MOVE "furnace" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 1" TO WS-PRT
     MOVE "0.5 0.75 0.5" TO WS-DRT
     MOVE "smoke 11.02000 64.18750 -2.35000 0.00000 0.00000 0.00000 | flame 11.02000 64.18750 -2.3500"
         & "0 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "furnace z sound" TO WS-NAME
     MOVE "furnace" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 1 -1" TO WS-PRT
     MOVE "0.05 0.25 0.5" TO WS-DRT
     MOVE "smoke 10.35000 64.18750 -3.02000 0.00000 0.00000 0.00000 | flame 10.35000 64.18750 -3.0200"
         & "0 0.00000 0.00000 0.00000 # furnace.fire_crackle (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "furnace unlit" TO WS-NAME
     MOVE "furnace" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 1" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "blast" TO WS-NAME
     MOVE "blast_furnace" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 -1" TO WS-PRT
     MOVE "0.5 0.75 0.5" TO WS-DRT
     MOVE "smoke 9.98000 64.28125 -2.35000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "smoker sound" TO WS-NAME
     MOVE "smoker" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.05" TO WS-DRT
     MOVE "smoke 10.50000 65.10000 -2.50000 0.00000 0.00000 0.00000 # smoker.smoke (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "smoker" TO WS-NAME
     MOVE "smoker" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE "smoke 10.50000 65.10000 -2.50000 0.00000 0.00000 0.00000 (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "smoker unlit" TO WS-NAME
     MOVE "smoker" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "wire 8" TO WS-NAME
     MOVE "redstone_wire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "8 2 1 0 0" TO WS-PRT
     MOVE "0.05 0.5 0.05 0.25 0.5 0.05 0.5 0.9" TO WS-DRT
     MOVE "dust 10.50000 64.50000 -2.93750 0.00000 0.00000 0.00000 c=4290183168 s=1.00 | dust 10.5000"
         & "0 64.06250 -2.62500 0.00000 0.00000 0.00000 c=4290183168 s=1.00 | dust 10.50000 64.06250 -"
         & "2.35000 0.00000 0.00000 0.00000 c=4290183168 s=1.00 (8)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "wire 3" TO WS-NAME
     MOVE "redstone_wire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "3 0 2 1 0" TO WS-PRT
     MOVE "0.01 0.5 0.01 0.5 0.01 0.5 0.01 0.5 0.9 0.01 0.5 0.5" TO WS-DRT
     MOVE "dust 10.50000 64.06250 -2.65000 0.00000 0.00000 0.00000 c=4286840832 s=1.00 | dust 10.9375"
         & "0 64.50000 -2.50000 0.00000 0.00000 0.00000 c=4286840832 s=1.00 | dust 10.75000 64.06250 -"
         & "2.50000 0.00000 0.00000 0.00000 c=4286840832 s=1.00 | dust 10.50000 64.06250 -2.25000 0.00"
         & "000 0.00000 0.00000 c=4286840832 s=1.00 (9)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "wire off" TO WS-NAME
     MOVE "redstone_wire" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 2 2 2 2" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "repeater true" TO WS-NAME
     MOVE "repeater" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 1 3" TO WS-PRT
     MOVE "0.6 0.7 0.8 0.75" TO WS-DRT
     MOVE "dust 10.52000 64.44000 -2.12750 0.00000 0.00000 0.00000 c=16711680 s=1.00 (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "repeater false" TO WS-NAME
     MOVE "repeater" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 1 0 3" TO WS-PRT
     MOVE "0.6 0.7 0.8 0.25" TO WS-DRT
     MOVE "dust 10.20750 64.44000 -2.44000 0.00000 0.00000 0.00000 c=16711680 s=1.00 (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "repeater off" TO WS-NAME
     MOVE "repeater" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 1 0 3" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "ore" TO WS-NAME
     MOVE "redstone_ore" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 1 0 1 1 0 1" TO WS-PRT
     MOVE "0.1 0.2 0.3 0.4" TO WS-DRT
     MOVE "dust 10.10000 65.06250 -2.80000 0.00000 0.00000 0.00000 c=16711680 s=1.00 | dust 9.93750 6"
         & "4.30000 -2.60000 0.00000 0.00000 0.00000 c=16711680 s=1.00 (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "ore unlit" TO WS-NAME
     MOVE "redstone_ore" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "lever" TO WS-NAME
     MOVE "lever" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 1 0 1 0 0" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE "dust 10.70000 64.60000 -2.50000 0.00000 0.00000 0.00000 c=16711680 s=0.50 (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "lever miss" TO WS-NAME
     MOVE "lever" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 1 0 1 0 0" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "lever off" TO WS-NAME
     MOVE "lever" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 1 0 1 0 0" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sculk south" TO WS-NAME
     MOVE "sculk_sensor" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.5 0.25 0.5" TO WS-DRT
     MOVE "dust_color_transition 10.75000 64.25000 -1.90000 0.00000 0.02000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sculk west" TO WS-NAME
     MOVE "sculk_sensor" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.7 0.25 0.5" TO WS-DRT
     MOVE "dust_color_transition 9.90000 64.25000 -2.25000 0.00000 0.02000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sculk up" TO WS-NAME
     MOVE "sculk_sensor" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.2" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sculk down" TO WS-NAME
     MOVE "sculk_sensor" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.05" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sculk north" TO WS-NAME
     MOVE "sculk_sensor" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.35 0.25 0.5" TO WS-DRT
     MOVE "dust_color_transition 10.75000 64.25000 -3.10000 0.00000 0.02000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sculk east" TO WS-NAME
     MOVE "sculk_sensor" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.9 0.25 0.5" TO WS-DRT
     MOVE "dust_color_transition 11.10000 64.25000 -2.25000 0.00000 0.02000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sculk idle" TO WS-NAME
     MOVE "sculk_sensor" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rod" TO WS-NAME
     MOVE "lightning_rod" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 450 1 1" TO WS-PRT
     MOVE "0.1 0.6 0.5 0.5 0.5 0.75 0.25 0.75 0.5 0.125" TO WS-DRT
     MOVE "electric_spark 10.50000 64.50000 -2.50000 0.00000 0.50000 0.00000 | electric_spark 10.4375"
         & "0 64.75000 -2.50000 0.00000 -0.75000 0.00000 (10)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rod x axis" TO WS-NAME
     MOVE "lightning_rod" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 450 1 0" TO WS-PRT
     MOVE "0.1 0.1 0.2 0.3 0.4" TO WS-DRT
     MOVE "electric_spark 10.20000 64.45000 -2.52500 0.00000 0.00000 0.00000 (6)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rod late" TO WS-NAME
     MOVE "lightning_rod" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 450 1 1" TO WS-PRT
     MOVE "0.9" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rod below surface" TO WS-NAME
     MOVE "lightning_rod" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 450 0 1" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rod dry" TO WS-NAME
     MOVE "lightning_rod" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 450 1 1" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "leaves rain drip" TO WS-NAME
     MOVE "leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0" TO WS-PRT
     MOVE "0.1 0.3 0.6" TO WS-DRT
     MOVE "dripping_water 10.30000 63.95000 -2.40000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "leaves rain below solid" TO WS-NAME
     MOVE "leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 1" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "leaves rain miss" TO WS-NAME
     MOVE "leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "leaves dry" TO WS-NAME
     MOVE "leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "tinted leaves azalea chance" TO WS-NAME
     MOVE "falling_leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 100 0 -9399763" TO WS-PRT
     MOVE "0.005 0.3 0.6" TO WS-DRT
     MOVE "tinted_leaves 10.30000 63.95000 -2.40000 0.00000 0.00000 0.00000 c=-9399763 s=0.00 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "cherry leaves" TO WS-NAME
     MOVE "falling_leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 1000 1" TO WS-PRT
     MOVE "0.05 0.25 0.75" TO WS-DRT
     MOVE "cherry_leaves 10.25000 63.95000 -2.25000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "rain miss then pale oak miss" TO WS-NAME
     MOVE "falling_leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 0 200 2" TO WS-PRT
     MOVE "0.5 0.1 0.3 0.6 0.9" TO WS-DRT
     MOVE " (2)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "pale oak" TO WS-NAME
     MOVE "falling_leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 200 2" TO WS-PRT
     MOVE "0.01 0.4 0.8" TO WS-DRT
     MOVE "pale_oak_leaves 10.40000 63.95000 -2.20000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "leaves full top below" TO WS-NAME
     MOVE "falling_leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 1 100 3" TO WS-PRT
     MOVE "0.001" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "orange poplar" TO WS-NAME
     MOVE "falling_leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 100 4" TO WS-PRT
     MOVE "0.005 0.1 0.2" TO WS-DRT
     MOVE "orange_poplar_leaves 10.10000 63.95000 -2.80000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "yellow poplar" TO WS-NAME
     MOVE "falling_leaves" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 100 5" TO WS-PRT
     MOVE "0.005 0.1 0.2" TO WS-DRT
     MOVE "yellow_poplar_leaves 10.10000 63.95000 -2.80000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "mycelium" TO WS-NAME
     MOVE "mycelium" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE SPACES TO WS-PRT
     MOVE "0.05 0.3 0.6" TO WS-DRT
     MOVE "mycelium 10.30000 65.10000 -2.40000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "mycelium miss" TO WS-NAME
     MOVE "mycelium" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE SPACES TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "spore all air" TO WS-NAME
     MOVE "spore_blossom" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE "0.1 0.2 0.5 0.5 0.5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0.3 0.5 0.5 0."
         & "5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0.3 0.5 "
         & "0.5 0.5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0."
         & "3 0.5 0.5 0.5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0.3 0.5 0.5 0.5 0.1 0.2 0.3" TO WS-DRT
     MOVE "falling_spore_blossom 10.10000 64.70000 -2.80000 0.00000 0.00000 0.00000 | spore_blossom_a"
         & "ir 10.10000 59.20000 -2.70000 0.00000 0.00000 0.00000 | spore_blossom_air 10.10000 59.2000"
         & "0 -2.70000 0.00000 0.00000 0.00000 | spore_blossom_air 10.10000 59.20000 -2.70000 0.00000 "
         & "0.00000 0.00000 | spore_blossom_air 10.10000 59.20000 -2.70000 0.00000 0.00000 0.00000 | s"
         & "pore_blossom_air 10.10000 59.20000 -2.70000 0.00000 0.00000 0.00000 | spore_blossom_air 10"
         & ".10000 59.20000 -2.70000 0.00000 0.00000 0.00000 | spore_blossom_air 10.10000 59.20000 -2."
         & "70000 0.00000 0.00000 0.00000 | spore_blossom_air 10.10000 59.20000 -2.70000 0.00000 0.000"
         & "00 0.00000 | spore_blossom_air 10.10000 59.20000 -2.70000 0.00000 0.00000 0.00000 | spore_"
         & "blossom_air 10.10000 59.20000 -2.70000 0.00000 0.00000 0.00000 | spore_blossom_air 10.1000"
         & "0 59.20000 -2.70000 0.00000 0.00000 0.00000 | spore_blossom_air 10.10000 59.20000 -2.70000"
         & " 0.00000 0.00000 0.00000 | spore_blossom_air 10.10000 59.20000 -2.70000 0.00000 0.00000 0."
         & "00000 | spore_blossom_air 10.10000 59.20000 -2.70000 0.00000 0.00000 0.00000 (86)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "spore all full" TO WS-NAME
     MOVE "spore_blossom" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "16383" TO WS-PRT
     MOVE "0.1 0.2 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0."
         & "5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5" TO WS-DRT
     MOVE "falling_spore_blossom 10.10000 64.70000 -2.80000 0.00000 0.00000 0.00000 (44)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "spore mixed" TO WS-NAME
     MOVE "spore_blossom" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "10922" TO WS-PRT
     MOVE "0.1 0.2 0.25 0.35 0.45 0.15 0.23 0.31 0.25 0.35 0.45 0.15 0.23 0.31 0.25 0.35 0.45 0.15 0."
         & "23 0.31 0.25 0.35 0.45 0.15 0.23 0.31 0.25 0.35 0.45 0.15 0.23 0.31 0.25 0.35 0.45 0.15 0."
         & "23 0.31 0.25 0.35 0.45 0.15 0.23 0.31 0.25 0.35 0.45 0.15 0.23 0.31 0.25 0.35 0.45 0.15 0."
         & "23 0.31 0.25 0.35 0.45 0.15 0.23 0.31 0.25 0.35 0.45 0.15 0.23 0.31 0.25 0.35 0.45 0.15 0."
         & "23 0.31 0.25 0.35 0.45 0.15 0.23 0.31 0.25 0.35 0.45 0.15 0.23 0.31" TO WS-DRT
     MOVE "falling_spore_blossom 10.10000 64.70000 -2.80000 0.00000 0.00000 0.00000 | spore_blossom_a"
         & "ir 5.15000 61.23000 -3.69000 0.00000 0.00000 0.00000 | spore_blossom_air 3.25000 62.35000 "
         & "-6.55000 0.00000 0.00000 0.00000 | spore_blossom_air 5.15000 61.23000 -3.69000 0.00000 0.0"
         & "0000 0.00000 | spore_blossom_air 3.25000 62.35000 -6.55000 0.00000 0.00000 0.00000 | spore"
         & "_blossom_air 5.15000 61.23000 -3.69000 0.00000 0.00000 0.00000 | spore_blossom_air 3.25000"
         & " 62.35000 -6.55000 0.00000 0.00000 0.00000 | spore_blossom_air 5.15000 61.23000 -3.69000 0"
         & ".00000 0.00000 0.00000 (65)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "firefly" TO WS-NAME
     MOVE "firefly_bush" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "13" TO WS-PRT
     MOVE "0.5 0.1 0.2 0.3" TO WS-DRT
     MOVE "firefly 6.00000 65.00000 -5.00000 0.00000 0.00000 0.00000 (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "firefly bright" TO WS-NAME
     MOVE "firefly_bush" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "14" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "firefly miss" TO WS-NAME
     MOVE "firefly_bush" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE "0.9" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "wither rose" TO WS-NAME
     MOVE "wither_rose" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "500 500" TO WS-PRT
     MOVE "0.6 0.1 0.2 0.3 0.1 0.7 0.4 0.5 0.6" TO WS-DRT
     MOVE "smoke 10.52000 64.30000 -2.44000 0.00000 0.00000 0.00000 | smoke 10.58000 64.00000 -2.3800"
         & "0 0.00000 0.00000 0.00000 (9)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sand" TO WS-NAME
     MOVE "falling_block" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 2057" TO WS-PRT
     MOVE "0.03 0.1 0.2" TO WS-DRT
     MOVE "falling_dust 10.10000 63.95000 -2.80000 0.00000 0.00000 0.00000 st=2057 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sand not free" TO WS-NAME
     MOVE "falling_block" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 2057" TO WS-PRT
     MOVE "0.03" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sand miss" TO WS-NAME
     MOVE "falling_block" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 2057" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "brushable" TO WS-NAME
     MOVE "brushable_block" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 77" TO WS-PRT
     MOVE "0.03 0.4 0.6" TO WS-DRT
     MOVE "falling_dust 10.40000 63.95000 -2.40000 0.00000 0.00000 0.00000 st=77 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sponge down" TO WS-NAME
     MOVE "wet_sponge" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.1 0.25 0.75" TO WS-DRT
     MOVE "dripping_water 10.25000 63.95000 -2.25000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sponge up" TO WS-NAME
     MOVE "wet_sponge" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.2" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sponge north" TO WS-NAME
     MOVE "wet_sponge" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.4 0.5 0.25 0.75" TO WS-DRT
     MOVE "dripping_water 10.25000 64.40000 -2.95000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sponge south" TO WS-NAME
     MOVE "wet_sponge" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.55 0.5 0.25" TO WS-DRT
     MOVE "dripping_water 10.25000 64.40000 -1.90000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sponge west" TO WS-NAME
     MOVE "wet_sponge" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.7 0.5 0.25" TO WS-DRT
     MOVE "dripping_water 10.05000 64.40000 -2.75000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sponge east" TO WS-NAME
     MOVE "wet_sponge" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.9 0.5 0.25" TO WS-DRT
     MOVE "dripping_water 11.10000 64.40000 -2.75000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sponge east sturdy" TO WS-NAME
     MOVE "wet_sponge" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 0 0 0 0 1" TO WS-PRT
     MOVE "0.9" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sponge east occlude not sturdy-other" TO WS-NAME
     MOVE "wet_sponge" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 0 0 0 1 0" TO WS-PRT
     MOVE "0.9 0.5 0.25" TO WS-DRT
     MOVE "dripping_water 11.10000 64.40000 -2.75000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "crying miss" TO WS-NAME
     MOVE "crying_obsidian" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "crying up" TO WS-NAME
     MOVE "crying_obsidian" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.1 0.2" TO WS-DRT
     MOVE " (2)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "crying down" TO WS-NAME
     MOVE "crying_obsidian" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.1 0.1 0.3 0.6" TO WS-DRT
     MOVE "dripping_obsidian_tear 10.30000 63.90000 -2.40000 0.00000 0.00000 0.00000 (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "crying north" TO WS-NAME
     MOVE "crying_obsidian" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.1 0.4 0.3 0.6" TO WS-DRT
     MOVE "dripping_obsidian_tear 10.30000 64.60000 -3.10000 0.00000 0.00000 0.00000 (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "crying east" TO WS-NAME
     MOVE "crying_obsidian" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0 0 0 0 0 0" TO WS-PRT
     MOVE "0.1 0.9 0.3 0.6" TO WS-DRT
     MOVE "dripping_obsidian_tear 11.10000 64.30000 -2.40000 0.00000 0.00000 0.00000 (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "crying sturdy" TO WS-NAME
     MOVE "crying_obsidian" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 0 0 0 0 1" TO WS-PRT
     MOVE "0.1 0.9" TO WS-DRT
     MOVE " (2)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "dripstone water" TO WS-NAME
     MOVE "pointed_dripstone" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 1 250 -250" TO WS-PRT
     MOVE "0.01" TO WS-DRT
     MOVE "dripping_dripstone_water 10.75000 64.25000 -2.75000 0.00000 0.00000 0.00000 (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "dripstone lava" TO WS-NAME
     MOVE "pointed_dripstone" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 2 0 0" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE "dripping_dripstone_lava 10.50000 64.25000 -2.50000 0.00000 0.00000 0.00000 (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "dripstone default" TO WS-NAME
     MOVE "pointed_dripstone" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 0 0" TO WS-PRT
     MOVE "0.01" TO WS-DRT
     MOVE "default_dripstone_particle 10.50000 64.25000 -2.50000 0.00000 0.00000 0.00000 (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "dripstone empty no" TO WS-NAME
     MOVE "pointed_dripstone" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 0 0 0" TO WS-PRT
     MOVE "0.05" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "dripstone late" TO WS-NAME
     MOVE "pointed_dripstone" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 1 0 0" TO WS-PRT
     MOVE "0.13" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "dripstone not hanging" TO WS-NAME
     MOVE "pointed_dripstone" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 1 0 0" TO WS-PRT
     MOVE "0.01" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "nether portal z" TO WS-NAME
     MOVE "nether_portal" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.1 0.2 0.3 0.4 0.5 0.6 0."
         & "7 0.8 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8" TO WS-DRT
     MOVE "portal 10.10000 64.20000 -2.25000 -0.05000 0.00000 1.60000 | portal 10.10000 64.20000 -2.2"
         & "5000 -0.05000 0.00000 1.60000 | portal 10.10000 64.20000 -2.25000 -0.05000 0.00000 1.60000"
         & " | portal 10.10000 64.20000 -2.25000 -0.05000 0.00000 1.60000 (32)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "nether portal x" TO WS-NAME
     MOVE "nether_portal" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE "0.1 0.2 0.3 0.4 0.5 0.6 0.2 0.8 0.1 0.2 0.3 0.4 0.5 0.6 0.2 0.8 0.1 0.2 0.3 0.4 0.5 0.6 0."
         & "2 0.8 0.1 0.2 0.3 0.4 0.5 0.6 0.2 0.8" TO WS-DRT
     MOVE "portal 10.25000 64.20000 -2.70000 -1.60000 0.00000 0.05000 | portal 10.25000 64.20000 -2.7"
         & "0000 -1.60000 0.00000 0.05000 | portal 10.25000 64.20000 -2.70000 -1.60000 0.00000 0.05000"
         & " | portal 10.25000 64.20000 -2.70000 -1.60000 0.00000 0.05000 (32)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "end portal" TO WS-NAME
     MOVE "end_portal" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE SPACES TO WS-PRT
     MOVE "0.3 0.7" TO WS-DRT
     MOVE "smoke 10.30000 64.80000 -2.30000 0.00000 0.00000 0.00000 (2)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "gateway" TO WS-NAME
     MOVE "end_gateway" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "2" TO WS-PRT
     MOVE "0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.6 0.5 0.4 0.3 0.2 0.1 0.8 0.2 0.7" TO WS-DRT
     MOVE "portal 10.10000 64.20000 -2.25000 -0.05000 0.00000 1.80000 | portal 10.75000 64.50000 -2.6"
         & "0000 1.40000 -0.15000 -0.20000 (18)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "gateway no faces" TO WS-NAME
     MOVE "end_gateway" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "ender chest" TO WS-NAME
     MOVE "ender_chest" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE SPACES TO WS-PRT
     MOVE "0.7 0.2 0.5 0.6 0.5 0.4 0.7 0.2 0.5 0.6 0.5 0.4 0.7 0.2 0.5 0.6 0.5 0.4" TO WS-DRT
     MOVE "portal 10.75000 64.50000 -2.75000 0.60000 0.00000 -0.40000 | portal 10.75000 64.50000 -2.7"
         & "5000 0.60000 0.00000 -0.40000 | portal 10.75000 64.50000 -2.75000 0.60000 0.00000 -0.40000"
         & " (18)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "note" TO WS-NAME
     MOVE "note_block" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1 12" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE "note 10.50000 65.20000 -2.50000 0.50000 0.00000 0.00000 (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "note not tunable" TO WS-NAME
     MOVE "note_block" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 12" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "enchant none valid" TO WS-NAME
     MOVE "enchanting_table" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 0" TO WS-PRT
     MOVE "0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 "
         & "0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01" TO WS-DRT
     MOVE " (32)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "enchant first and third" TO WS-NAME
     MOVE "enchanting_table" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "5 0" TO WS-PRT
     MOVE "0.01 0.5 0.9 0.1 0.2 0.3 0.01 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 "
         & "0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5" TO WS-DRT
     MOVE "enchant 10.50000 66.00000 -2.50000 -2.00000 -1.90000 -2.40000 (35)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "enchant last" TO WS-NAME
     MOVE "enchanting_table" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0 32768" TO WS-PRT
     MOVE "0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0."
         & "5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.01 0.1 0.2 0.3" TO WS-DRT
     MOVE "enchant 10.50000 66.00000 -2.50000 1.60000 -0.20000 1.80000 (35)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "anchor" TO WS-NAME
     MOVE "respawn_anchor" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.1 0.2 0.5" TO WS-DRT
     MOVE "reverse_portal 10.90000 65.00000 -2.20000 0.00000 0.02000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "anchor empty" TO WS-NAME
     MOVE "respawn_anchor" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "brewing" TO WS-NAME
     MOVE "brewing_stand" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE SPACES TO WS-PRT
     MOVE "0.5 0.5 0.5" TO WS-DRT
     MOVE "smoke 10.50000 64.85000 -2.50000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "beehive min zero below open" TO WS-NAME
     MOVE "beehive" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "5 0 1000 0 0 0 0" TO WS-PRT
     MOVE "0.1 0.3 0.6" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "beehive below open" TO WS-NAME
     MOVE "beehive" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "5 0 1000 0 0 1 0" TO WS-PRT
     MOVE "0.1 0.3 0.6" TO WS-DRT
     MOVE "dripping_honey 10.30000 63.95000 -2.40000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "beehive min above" TO WS-NAME
     MOVE "beehive" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "5 0 1000 250 0 0 0" TO WS-PRT
     MOVE "0.1 0.3 0.6" TO WS-DRT
     MOVE "dripping_honey 10.30000 64.20000 -2.40000 0.00000 0.00000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "beehive miss" TO WS-NAME
     MOVE "beehive" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "5 0 1000 0 0 0 0" TO WS-PRT
     MOVE "0.5" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "beehive fluid" TO WS-NAME
     MOVE "beehive" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "5 1 1000 0 0 1 0" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "beehive low" TO WS-NAME
     MOVE "beehive" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "4 0 1000 0 0 1 0" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "beehive impermeable" TO WS-NAME
     MOVE "beehive" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "5 0 1000 0 1 1 0" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "beehive shape short" TO WS-NAME
     MOVE "beehive" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "5 0 900 0 0 1 0" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "beehive below fluid" TO WS-NAME
     MOVE "beehive" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "5 0 1000 0 0 1 1" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "bubble down" TO WS-NAME
     MOVE "bubble_column" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE "current_down 10.50000 64.80000 -3.00000 0.00000 0.00000 0.00000 (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "bubble up" TO WS-NAME
     MOVE "bubble_column" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE "0.2 0.4 0.6" TO WS-DRT
     MOVE "bubble_column_up 10.50000 64.00000 -2.50000 0.00000 0.04000 0.00000 | bubble_column_up 10."
         & "20000 64.40000 -2.40000 0.00000 0.04000 0.00000 (3)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sulfur" TO WS-NAME
     MOVE "potent_sulfur" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.1 0.2 0.3 0.4 0.5 0.6" TO WS-DRT
     MOVE "sulfur_bubbles 10.10000 65.20000 -2.70000 0.00000 0.00000 0.00000 | sulfur_bubbles 10.4000"
         & "0 65.50000 -2.40000 0.00000 0.00000 0.00000 (6)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "sulfur dry" TO WS-NAME
     MOVE "potent_sulfur" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE SPACES TO WS-DRT
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "ghast dry" TO WS-NAME
     MOVE "dried_ghast" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE "0.1" TO WS-DRT
     MOVE "white_smoke 10.50000 64.50000 -2.50000 0.00000 0.02000 0.00000 (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "ghast wet" TO WS-NAME
     MOVE "dried_ghast" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "1" TO WS-PRT
     MOVE "0.1 0.75 0.25 0.5" TO WS-DRT
     MOVE "happy_villager 10.66667 64.90000 -2.66667 0.00000 0.50000 0.00000 (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "ghast miss" TO WS-NAME
     MOVE "dried_ghast" TO WS-CLASS
     MOVE "10 64 -3" TO WS-PT
     MOVE "0" TO WS-PRT
     MOVE "0.9" TO WS-DRT
     MOVE " (1)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE 0 TO WS-PW
     CALL "P6-WIRE-COLOR" USING WS-PW WS-COL
     MOVE "wire colour power 0 is 0xFF4C0000" TO WS-NAME
     MOVE 4283170816 TO TL-EXPECTED-N
     MOVE WS-COL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 15 TO WS-PW
     CALL "P6-WIRE-COLOR" USING WS-PW WS-COL
     MOVE "wire colour power 15 is 0xFFFF3200 (green 0.2 truncates to 50)" TO WS-NAME
     MOVE 4294914560 TO TL-EXPECTED-N
     MOVE WS-COL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-FA-COUNT
     MOVE 1 TO WS-FA-ROOT
     MOVE 1 TO WS-FA-KIND
     MOVE 0 TO WS-FA-EVAP
     CALL "P6-FLUID-ABOVE" USING WS-FA-COUNT WS-FA-ROOT WS-FA-KIND WS-FA-EVAP WS-FA-OUT
     MOVE "fluid above: water above the root is water" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FA-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 2 TO WS-FA-KIND
     CALL "P6-FLUID-ABOVE" USING WS-FA-COUNT WS-FA-ROOT WS-FA-KIND WS-FA-EVAP WS-FA-OUT
     MOVE "fluid above: lava above the root is lava" TO WS-NAME
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-FA-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 3 TO WS-FA-KIND
     CALL "P6-FLUID-ABOVE" USING WS-FA-COUNT WS-FA-ROOT WS-FA-KIND WS-FA-EVAP WS-FA-OUT
     MOVE "fluid above: mud that does not evaporate water is water" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FA-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-FA-EVAP
     CALL "P6-FLUID-ABOVE" USING WS-FA-COUNT WS-FA-ROOT WS-FA-KIND WS-FA-EVAP WS-FA-OUT
     MOVE "fluid above: mud where water evaporates is empty" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FA-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 4 TO WS-FA-KIND
     CALL "P6-FLUID-ABOVE" USING WS-FA-COUNT WS-FA-ROOT WS-FA-KIND WS-FA-EVAP WS-FA-OUT
     MOVE "fluid above: another cell kind is empty" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FA-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 9 TO WS-FA-COUNT
     MOVE 1 TO WS-FA-KIND
     CALL "P6-FLUID-ABOVE" USING WS-FA-COUNT WS-FA-ROOT WS-FA-KIND WS-FA-EVAP WS-FA-OUT
     MOVE "fluid above: nine dripstone blocks still reach the root" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FA-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 10 TO WS-FA-COUNT
     CALL "P6-FLUID-ABOVE" USING WS-FA-COUNT WS-FA-ROOT WS-FA-KIND WS-FA-EVAP WS-FA-OUT
     MOVE "fluid above: ten blocks exhaust the walk" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FA-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 2 TO WS-FA-COUNT
     MOVE 0 TO WS-FA-ROOT
     CALL "P6-FLUID-ABOVE" USING WS-FA-COUNT WS-FA-ROOT WS-FA-KIND WS-FA-EVAP WS-FA-OUT
     MOVE "fluid above: leaving the build height gives none" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FA-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-DI
     CALL "P6-DIRECTION-STEP" USING WS-DI WS-STEP3
     MOVE "direction step 0 (down) is (0, -1, 0)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = -1
     COMPUTE TL-OBSERVED-N = WS-ST(2)
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-DI
     CALL "P6-DIRECTION-STEP" USING WS-DI WS-STEP3
     MOVE "direction step 1 (up) y is 1" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1
     COMPUTE TL-OBSERVED-N = WS-ST(2)
     PERFORM ASSERT-NUMBER
     MOVE 6 TO WS-DI
     CALL "P6-DIRECTION-STEP" USING WS-DI WS-STEP3
     MOVE "direction step out of range is zero" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 0
     COMPUTE TL-OBSERVED-N = WS-ST(1) + WS-ST(2) + WS-ST(3)
     PERFORM ASSERT-NUMBER
     MOVE "no_such_class" TO WS-CLASS
     MOVE 1 TO EM-COUNT
     MOVE 0 TO WS-PR(1)
     CALL "P6-BLOCK-TICK" USING WS-CLASS WS-BLOCK WS-PROPS P6-EMITS
     MOVE "an unknown class emits nothing" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 0
     COMPUTE TL-OBSERVED-N = EM-COUNT
     PERFORM ASSERT-NUMBER
     STOP RUN.

 RUN-CASE.
     MOVE WS-PT TO WS-TEXT
     PERFORM PARSE-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-NUM(WS-I) TO WS-BP(WS-I)
     END-PERFORM
     MOVE WS-PRT TO WS-TEXT
     PERFORM PARSE-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE 0 TO WS-PR(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-NUM(WS-I) TO WS-PR(WS-I)
     END-PERFORM
     MOVE WS-DRT TO WS-TEXT
     PERFORM PARSE-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         MOVE 0.5 TO EM-DRAW(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-NUM(WS-I) TO EM-DRAW(WS-I)
     END-PERFORM
     CALL "P6-BLOCK-TICK" USING WS-CLASS WS-BLOCK WS-PROPS P6-EMITS
     PERFORM RENDER
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-6§3 `animateTick` of block classes: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-6§3 `animateTick` of block classes: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 PARSE-LIST.
     MOVE 0 TO WS-COUNT
     MOVE 1 TO WS-PTR
     PERFORM UNTIL WS-PTR > 1500 OR WS-TEXT(WS-PTR:) = SPACES
         MOVE SPACES TO WS-TOK
         UNSTRING WS-TEXT DELIMITED BY ALL SPACE INTO WS-TOK WITH POINTER WS-PTR
         IF WS-TOK NOT = SPACES
             ADD 1 TO WS-COUNT
             COMPUTE WS-NUM(WS-COUNT) = FUNCTION NUMVAL(WS-TOK)
         END-IF
     END-PERFORM.

 RENDER.
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EM-COUNT
         IF WS-I > 1
             STRING " | " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
         STRING FUNCTION TRIM(EM-NAME(WS-I)) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         MOVE EM-X(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-Y(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-Z(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-VX(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-VY(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-VZ(WS-I) TO WS-V
         PERFORM ADD-LAST-NUMBER
         IF EM-COLOR(WS-I) NOT = 0
             MOVE EM-COLOR(WS-I) TO WS-EDC
             MOVE EM-SCALE(WS-I) TO WS-EDS
             STRING " c=" FUNCTION TRIM(WS-EDC) " s=" WS-EDS DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
         IF EM-STATE(WS-I) NOT = 0
             MOVE EM-STATE(WS-I) TO WS-EDC
             STRING " st=" FUNCTION TRIM(WS-EDC) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EM-SOUND-COUNT
         STRING " # " FUNCTION TRIM(EM-SOUND(WS-I)) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
     END-PERFORM
     MOVE EM-CUR TO WS-EDC
     STRING " (" FUNCTION TRIM(WS-EDC) ")" DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2.

 ADD-NUMBER.
     PERFORM ADD-LAST-NUMBER
     STRING " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2.

 ADD-LAST-NUMBER.
     COMPUTE WS-ED ROUNDED = WS-V
     STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2.
 END PROGRAM TEST-PARTICLES-42-6-3.
