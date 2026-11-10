*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md), section 9: block-entity and environment emitters (partial: the trial spawner, the conduit, the bell,
*> the creaking heart trail and the geyser rule; the vault, the campfire slot positions, the catalyst and the pointers of 9.5 and 9.7 are not here). Conventions of particles-42-7.cob.
*> Entry points for the integrator (inputs):
*>   P7-BLOCK site(X(24)) IN(16 floats) P6-EMITS: trial_small IN(ominous, block x y z) one state emission of 9.1 (the block centre is block + 0.5); trial_active IN(ominous, block);
*>     trial_cooldown IN(game time, block); trial_spawn IN(ominous, block) addSpawnParticles; trial_ominous IN(block) addBecomeOminousParticles; trial_detect IN(n, ominous, block)
*>     addDetectPlayerParticles; conduit IN(tick, block, frame offset x y z) one frame block of 9.3; bell IN(block, step toward the raider x z, particle count, index of the last particle
*>     of the earlier raiders) the raider particles of 9.4 (EM-COLOR 16700985 + 5 per particle of the whole bell).
*>   P7-BELL-COUNT IN(raiders in range) OUT(particles per raider, clamp((count - 21) / -2, 3, 15)); P7-HEART-TRAIL IN(flag, r) OUT(colour, duration 10 + nextInt(40) from the draw r) (9.6);
*>     P7-GEYSER IN(source y, block y, game time, eruption tick) OUT(emits, water_blocks) (9.4).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40).
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CNT                 BINARY-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SITE                 PIC X(24).
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-SITE L-IN P6-EMITS.
     EVALUATE L-SITE
         WHEN "trial_small" PERFORM TRIAL-SMALL
         WHEN "trial_active" PERFORM TRIAL-ACTIVE
         WHEN "trial_cooldown" PERFORM TRIAL-COOLDOWN
         WHEN "trial_spawn" PERFORM TRIAL-SPAWN
         WHEN "trial_ominous" PERFORM TRIAL-OMINOUS
         WHEN "trial_detect" PERFORM TRIAL-DETECT
         WHEN "conduit" PERFORM CONDUIT
         WHEN "bell" PERFORM BELL
     END-EVALUATE
     GOBACK.

 TRIAL-SMALL.
     COMPUTE WS-CX = L-I(2) + 0.5
     COMPUTE WS-CY = L-I(3) + 0.5
     COMPUTE WS-CZ = L-I(4) + 0.5
     CALL "P6-DRAW" USING P6-EMITS WS-A
     IF FUNCTION INTEGER-PART(WS-A * 2) = 0
         MOVE 0.9 TO WS-S
         PERFORM OFFSET-RANDOM
         MOVE "small_flame" TO WS-N
         IF L-I(1) NOT = 0
             MOVE "soul_fire_flame" TO WS-N
         END-IF
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF.

 TRIAL-ACTIVE.
     COMPUTE WS-CX = L-I(2) + 0.5
     COMPUTE WS-CY = L-I(3) + 0.5
     COMPUTE WS-CZ = L-I(4) + 0.5
     MOVE 1 TO WS-S
     PERFORM OFFSET-RANDOM
     MOVE "smoke" TO WS-N
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     MOVE "flame" TO WS-N
     IF L-I(1) NOT = 0
         MOVE "soul_fire_flame" TO WS-N
     END-IF
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV.

 TRIAL-COOLDOWN.
     COMPUTE WS-CX = L-I(2) + 0.5
     COMPUTE WS-CY = L-I(3) + 0.5
     COMPUTE WS-CZ = L-I(4) + 0.5
     CALL "P6-DRAW" USING P6-EMITS WS-A
     IF FUNCTION INTEGER-PART(WS-A * 3) = 0
         MOVE 0.9 TO WS-S
         PERFORM OFFSET-RANDOM
         MOVE "smoke" TO WS-N
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF
     IF L-I(1) = 20 * FUNCTION INTEGER-PART(L-I(1) / 20)
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-CNT = 20 + FUNCTION INTEGER-PART(WS-A * 4)
         MOVE "smoke" TO WS-N
         MOVE WS-CX TO WS-V(1)
         COMPUTE WS-V(2) = WS-CY + 0.5
         MOVE WS-CZ TO WS-V(3)
         MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
         PERFORM WS-CNT TIMES
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-PERFORM
     END-IF.

 TRIAL-SPAWN.
     COMPUTE WS-CX = L-I(2) + 0.5
     COMPUTE WS-CY = L-I(3) + 0.5
     COMPUTE WS-CZ = L-I(4) + 0.5
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM 20 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = WS-CX + (WS-A - 0.5) * 2
         COMPUTE WS-V(2) = WS-CY + (WS-B - 0.5) * 2
         COMPUTE WS-V(3) = WS-CZ + (WS-C - 0.5) * 2
         MOVE "smoke" TO WS-N
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         MOVE "flame" TO WS-N
         IF L-I(1) NOT = 0
             MOVE "soul_fire_flame" TO WS-N
         END-IF
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 TRIAL-OMINOUS.
     COMPUTE WS-CX = L-I(1) + 0.5
     COMPUTE WS-CY = L-I(2) + 0.5
     COMPUTE WS-CZ = L-I(3) + 0.5
     PERFORM 20 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = WS-CX + (WS-A - 0.5) * 2
         COMPUTE WS-V(2) = WS-CY + (WS-B - 0.5) * 2
         COMPUTE WS-V(3) = WS-CZ + (WS-C - 0.5) * 2
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(4) = WS-A * 0.02
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(5) = WS-A * 0.02
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(6) = WS-A * 0.02
         MOVE "trial_omen" TO WS-N
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         MOVE "soul_fire_flame" TO WS-N
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 TRIAL-DETECT.
     MOVE L-I(1) TO WS-S
     IF WS-S > 10
         MOVE 10 TO WS-S
     END-IF
     COMPUTE WS-CNT = 30 + WS-S * 5
     MOVE "trial_spawner_detection" TO WS-N
     IF L-I(2) NOT = 0
         MOVE "trial_spawner_detection_ominous" TO WS-N
     END-IF
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM WS-CNT TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(3) + 0.5 + (2 * WS-A - 1) * 0.65
         COMPUTE WS-V(2) = L-I(4) + 0.1 + WS-C * 0.8
         COMPUTE WS-V(3) = L-I(5) + 0.5 + (2 * WS-B - 1) * 0.65
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 CONDUIT.
     COMPUTE WS-S = FUNCTION SIN((L-I(1) + 35) * 0.1) / 2 + 0.5
     COMPUTE WS-S = (WS-S * WS-S + WS-S) * 0.3
     CALL "P6-DRAW" USING P6-EMITS WS-A
     IF FUNCTION INTEGER-PART(WS-A * 50) = 0
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         MOVE "nautilus" TO WS-N
         COMPUTE WS-V(1) = L-I(2) + 0.5
         COMPUTE WS-V(2) = L-I(3) + 1.5 + WS-S
         COMPUTE WS-V(3) = L-I(4) + 0.5
         COMPUTE WS-V(4) = L-I(5) - 0.5 + WS-A
         COMPUTE WS-V(5) = L-I(6) - 2 + WS-B
         COMPUTE WS-V(6) = L-I(7) - 0.5 + WS-C
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF.

 BELL.
     MOVE "entity_effect" TO WS-N
     COMPUTE WS-V(1) = L-I(1) + 0.5 + L-I(4)
     COMPUTE WS-V(2) = L-I(2) + 0.5 + 0.5
     COMPUTE WS-V(3) = L-I(3) + 0.5 + L-I(5)
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     COMPUTE WS-CNT = L-I(6)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CNT
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         COMPUTE EM-COLOR(EM-COUNT) = 16700985 + 5 * (L-I(7) + WS-I)
     END-PERFORM.

 OFFSET-RANDOM.
     CALL "P6-DRAW" USING P6-EMITS WS-A
     CALL "P6-DRAW" USING P6-EMITS WS-B
     CALL "P6-DRAW" USING P6-EMITS WS-C
     COMPUTE WS-V(1) = WS-CX + (WS-A - 0.5) * WS-S
     COMPUTE WS-V(2) = WS-CY + (WS-B - 0.5) * WS-S
     COMPUTE WS-V(3) = WS-CZ + (WS-C - 0.5) * WS-S
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6).
 END PROGRAM P7-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-BELL-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-Q = FUNCTION INTEGER-PART((L-I(1) - 21) / -2)
     IF WS-Q < 3
         MOVE 3 TO WS-Q
     END-IF
     IF WS-Q > 15
         MOVE 15 TO WS-Q
     END-IF
     MOVE WS-Q TO L-O(1)
     GOBACK.
 END PROGRAM P7-BELL-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-HEART-TRAIL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 6250335 TO L-O(1)
     IF L-I(1) NOT = 0
         MOVE 16545810 TO L-O(1)
     END-IF
     COMPUTE L-O(2) = 10 + FUNCTION INTEGER-PART(L-I(2) * 40)
     GOBACK.
 END PROGRAM P7-HEART-TRAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-GEYSER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(3) - L-I(4) = 20 * FUNCTION INTEGER-PART((L-I(3) - L-I(4)) / 20)
         MOVE 1 TO L-O(1)
     END-IF
     COMPUTE L-O(2) = L-I(1) - L-I(2) - 1
     GOBACK.
 END PROGRAM P7-GEYSER.
