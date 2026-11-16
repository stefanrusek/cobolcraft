*> The ender dragon's phases (docs/protocol/21 section 6.4.3, 44 part 9 section 1; lane 002-lane-mobsb8, T9702): setPhase and the begin rules, the eleven phase ticks, the strafe, the fireball and the
*> breath cloud. The phase ids: 0 holding pattern, 1 strafe player, 2 landing approach, 3 landing, 4 takeoff, 5 sitting flaming, 6 sitting scanning, 7 sitting attacking, 8 charging player, 9 dying,
*> 10 hovering. The state is DRAGSTATE.cpy. Gaps: the phase id is not sent as entity data 16, the sounds, particles and world events 1017 (fireball) and 2006 are sent where the event exists.
*>
*>   DRAGON-SET-PHASE USING row, phase
*>   DRAGON-PLAYER-NEAR USING x, y, z (FLOAT-LONG), maximum distance (FLOAT-LONG), player row out: the nearest living survival or adventure player of the dragon's dimension (DG-FIGHT 0: any)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-SET-PHASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DRAGSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PHASE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PHASE.
     IF L-PHASE = DG-PHASE
         GOBACK
     END-IF
     MOVE L-PHASE TO DG-PHASE
     EVALUATE L-PHASE
         WHEN 0 WHEN 2 WHEN 4
             MOVE 0 TO DG-HAS-PATH DG-HAS-TARGET DG-CHARGE-T
         WHEN 1
             MOVE 0 TO DG-CHARGE DG-HAS-TARGET DG-HAS-PATH DG-PROW
         WHEN 5
             ADD 1 TO DG-FLAMES
             MOVE 0 TO DG-FLAME-T
         WHEN 6
             MOVE 0 TO DG-SCAN
         WHEN 7
             MOVE 0 TO DG-ROAR
         WHEN 8
             MOVE 0 TO DG-CHARGE-T DG-HAS-TARGET
         WHEN 9
             MOVE 0 TO DG-HAS-TARGET DG-DEATH-T
         WHEN 10
             MOVE 0 TO DG-HAS-TARGET
     END-EVALUATE
     GOBACK.
 END PROGRAM DRAGON-SET-PHASE.
