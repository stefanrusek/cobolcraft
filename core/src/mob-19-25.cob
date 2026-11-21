*> The wandering trader spawner's roll (docs/protocol/19-mobs-land-friendly-and-neutral.md section 23, 45-entity-nbt-6 section 9; lane p49a).
*>   WT-CYCLE USING spawn delay (in/out), spawn chance (in/out), roll (nextInt(100)), attempt out   one cycle of the spawner (every 1200 ticks): the stored delay falls by
*>       1200; while it is above 0 nothing else happens; at 0 or below it is reset to 24000, the chance becomes clamp(old + 25, 25, 75) before the roll, and the spawn is
*>       attempted when the roll is at most the OLD chance (45-6: the comparison uses the old chance)
*>   WT-RESULT USING spawn chance (in/out), spawned (1/0)   a spawn attempt that returns true resets the chance to 25; a false one leaves the raised chance

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-CYCLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DELAY                BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-ATTEMPT              BINARY-LONG.
 PROCEDURE DIVISION USING L-DELAY L-CHANCE L-ROLL L-ATTEMPT.
     MOVE 0 TO L-ATTEMPT
     SUBTRACT 1200 FROM L-DELAY
     IF L-DELAY > 0
         GOBACK
     END-IF
     MOVE 24000 TO L-DELAY
     MOVE L-CHANCE TO WS-OLD
     COMPUTE L-CHANCE = FUNCTION MAX(25, FUNCTION MIN(75, WS-OLD + 25))
     IF L-ROLL <= WS-OLD
         MOVE 1 TO L-ATTEMPT
     END-IF
     GOBACK.
 END PROGRAM WT-CYCLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-RESULT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHANCE               BINARY-LONG.
 01 L-SPAWNED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANCE L-SPAWNED.
     IF L-SPAWNED = 1
         MOVE 25 TO L-CHANCE
     END-IF
     GOBACK.
 END PROGRAM WT-RESULT.
