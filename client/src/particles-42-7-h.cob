*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md), section 8: level events (partial: only the events whose particles have a closed formula, and the
*> classification of the event ids). Conventions of particles-42-7.cob (draws in EM-DRAW, particles and sounds out in the rows of client/copy/CLP6EM.cpy).
*> Entry points for the integrator (inputs):
*>   P7-LEVEL site(X(24)) IN(16 floats) P6-EMITS: ev1501 IN(block x y z) lava extinguished; ev1502 redstone torch burnout; ev1503 end portal frame filled; ev2003 eye of ender breaks (the ring of
*>     portal particles is 40 steps of pi/20); ev2004 mob spawner spawn; ev2006 IN(block, data) dragon fireball breath (EM-SCALE is the power option p, the sound dragon_fireball_breath when data is 1);
*>     ev2008 explosion at the block centre; ev2009 sponge dried; ev3000 IN(block) end gateway spawn (always visible and forced: the sound row always_visible_forced marks it); ev3007 IN(block,
*>     top y of the shrieker) sculk shriek (EM-STATE is the delay i * 5); ev3018 cobweb placed.
*>   P7-LEVEL-KIND IN(id) OUT(0 not handled, 1 sound only (or no client particle), 2 particles or block effects, 3 the global switch): the 89 + 3 ids of LevelEventHandler.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40).
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-ANG                 FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SITE                 PIC X(24).
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-SITE L-IN P6-EMITS.
     EVALUATE L-SITE
         WHEN "ev1501" PERFORM EV1501
         WHEN "ev1502" PERFORM EV1502
         WHEN "ev1503" PERFORM EV1503
         WHEN "ev2003" PERFORM EV2003
         WHEN "ev2004" PERFORM EV2004
         WHEN "ev2006" PERFORM EV2006
         WHEN "ev2008" PERFORM EV2008
         WHEN "ev2009" PERFORM EV2009
         WHEN "ev3000" PERFORM EV3000
         WHEN "ev3007" PERFORM EV3007
         WHEN "ev3018" PERFORM EV3018
     END-EVALUATE
     GOBACK.

 EV1501.
     MOVE "large_smoke" TO WS-N
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM 8 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         COMPUTE WS-V(1) = L-I(1) + WS-A
         COMPUTE WS-V(2) = L-I(2) + 1.2
         COMPUTE WS-V(3) = L-I(3) + WS-B
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 EV1502.
     MOVE "smoke" TO WS-N
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM 5 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(1) + 0.6 * WS-A + 0.2
         COMPUTE WS-V(2) = L-I(2) + 0.6 * WS-B + 0.2
         COMPUTE WS-V(3) = L-I(3) + 0.6 * WS-C + 0.2
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 EV1503.
     MOVE "smoke" TO WS-N
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM 16 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         COMPUTE WS-V(1) = L-I(1) + (5 + 6 * WS-A) / 16
         COMPUTE WS-V(2) = L-I(2) + 0.8125
         COMPUTE WS-V(3) = L-I(3) + (5 + 6 * WS-B) / 16
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 EV2003.
     MOVE "item" TO WS-N
     PERFORM 8 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(1) + 0.5
         MOVE L-I(2) TO WS-V(2)
         COMPUTE WS-V(3) = L-I(3) + 0.5
         COMPUTE WS-V(4) = WS-A * 0.15
         COMPUTE WS-V(5) = WS-B * 0.2
         COMPUTE WS-V(6) = WS-C * 0.15
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM
     MOVE "portal" TO WS-N
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 39
         COMPUTE WS-ANG = WS-I * 0.15707963267948966
         COMPUTE WS-V(1) = L-I(1) + 0.5 + FUNCTION COS(WS-ANG) * 5
         COMPUTE WS-V(2) = L-I(2) - 0.4
         COMPUTE WS-V(3) = L-I(3) + 0.5 + FUNCTION SIN(WS-ANG) * 5
         COMPUTE WS-V(4) = -5 * FUNCTION COS(WS-ANG)
         MOVE 0 TO WS-V(5)
         COMPUTE WS-V(6) = -5 * FUNCTION SIN(WS-ANG)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         COMPUTE WS-V(4) = -7 * FUNCTION COS(WS-ANG)
         COMPUTE WS-V(6) = -7 * FUNCTION SIN(WS-ANG)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 EV2004.
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM 20 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(1) + 0.5 + (WS-A - 0.5) * 2
         COMPUTE WS-V(2) = L-I(2) + 0.5 + (WS-B - 0.5) * 2
         COMPUTE WS-V(3) = L-I(3) + 0.5 + (WS-C - 0.5) * 2
         MOVE "smoke" TO WS-N
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         MOVE "flame" TO WS-N
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 EV2006.
     MOVE "dragon_breath" TO WS-N
     PERFORM 200 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-P = WS-A * 4
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-ANG = WS-A * 6.283185307179586
         CALL "P6-DRAW" USING P6-EMITS WS-B
         COMPUTE WS-V(4) = FUNCTION COS(WS-ANG) * WS-P
         COMPUTE WS-V(5) = 0.01 + WS-B * 0.5
         COMPUTE WS-V(6) = FUNCTION SIN(WS-ANG) * WS-P
         COMPUTE WS-V(1) = L-I(1) + WS-V(4) * 0.1
         COMPUTE WS-V(2) = L-I(2) + 0.3
         COMPUTE WS-V(3) = L-I(3) + WS-V(6) * 0.1
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         MOVE WS-P TO EM-SCALE(EM-COUNT)
     END-PERFORM
     IF L-I(4) = 1
         ADD 1 TO EM-SOUND-COUNT
         MOVE "dragon_fireball_breath" TO EM-SOUND(EM-SOUND-COUNT)
     END-IF.

 EV2008.
     MOVE "explosion" TO WS-N
     COMPUTE WS-V(1) = L-I(1) + 0.5
     COMPUTE WS-V(2) = L-I(2) + 0.5
     COMPUTE WS-V(3) = L-I(3) + 0.5
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV.

 EV2009.
     MOVE "cloud" TO WS-N
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM 8 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         COMPUTE WS-V(1) = L-I(1) + WS-A
         COMPUTE WS-V(2) = L-I(2) + 1.2
         COMPUTE WS-V(3) = L-I(3) + WS-B
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 EV3000.
     PERFORM EV2008
     MOVE "explosion_emitter" TO EM-NAME(EM-COUNT)
     ADD 1 TO EM-SOUND-COUNT
     MOVE "always_visible_forced" TO EM-SOUND(EM-SOUND-COUNT).

 EV3007.
     MOVE "shriek" TO WS-N
     COMPUTE WS-V(1) = L-I(1) + 0.5
     COMPUTE WS-V(2) = L-I(2) + L-I(4)
     COMPUTE WS-V(3) = L-I(3) + 0.5
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 9
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         COMPUTE EM-STATE(EM-COUNT) = WS-I * 5
     END-PERFORM.

 EV3018.
     MOVE "poof" TO WS-N
     PERFORM 10 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(4) = WS-A * 0.02
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(5) = WS-A * 0.02
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(6) = WS-A * 0.02
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(1) + WS-A
         COMPUTE WS-V(2) = L-I(2) + WS-B
         COMPUTE WS-V(3) = L-I(3) + WS-C
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.
 END PROGRAM P7-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-LEVEL-KIND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     EVALUATE TRUE
         WHEN L-I(1) = 1023 OR L-I(1) = 1028 OR L-I(1) = 1038
             MOVE 3 TO L-O(1)
         WHEN L-I(1) >= 1000 AND L-I(1) <= 1002
             MOVE 1 TO L-O(1)
         WHEN L-I(1) = 1004 OR (L-I(1) >= 1009 AND L-I(1) <= 1011)
             MOVE 1 TO L-O(1)
         WHEN L-I(1) >= 1015 AND L-I(1) <= 1022
             MOVE 1 TO L-O(1)
         WHEN L-I(1) >= 1024 AND L-I(1) <= 1027
             MOVE 1 TO L-O(1)
         WHEN L-I(1) >= 1029 AND L-I(1) <= 1035
             MOVE 1 TO L-O(1)
         WHEN L-I(1) >= 1039 AND L-I(1) <= 1054
             MOVE 1 TO L-O(1)
         WHEN L-I(1) = 3001
             MOVE 1 TO L-O(1)
         WHEN L-I(1) >= 1500 AND L-I(1) <= 1505
             MOVE 2 TO L-O(1)
         WHEN L-I(1) >= 2000 AND L-I(1) <= 2004
             MOVE 2 TO L-O(1)
         WHEN L-I(1) >= 2006 AND L-I(1) <= 2020
             MOVE 2 TO L-O(1)
         WHEN L-I(1) >= 3000 AND L-I(1) <= 3009
             MOVE 2 TO L-O(1)
         WHEN L-I(1) >= 3011 AND L-I(1) <= 3021
             MOVE 2 TO L-O(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM P7-LEVEL-KIND.
