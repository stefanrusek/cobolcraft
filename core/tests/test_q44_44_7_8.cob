*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 8 and worked cases 13.5 to 13.8, lane 002-lane-p49j-a): the axolotl rules that
*> are deterministic functions of their inputs: the play-dead damage test (8.3, with its draw short-circuit), the pack and baby rule (8.1), the rare variant (8.2), the air
*> handler and rehydration (8.4), the supporting effects (8.5), the speeds, the hunting cooldown and the TryFindLiquid scan order (8.6). The core has no axolotl mob row, so
*> these are not wired into a tick (gap listed in the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-AI                  BINARY-LONG VALUE 1.
 01 WS-DA                  BINARY-LONG.
 01 WS-DB                  BINARY-LONG.
 01 WS-DMG                 FLOAT-LONG.
 01 WS-HEALTH              FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG VALUE 14.
 01 WS-INWATER             BINARY-LONG VALUE 1.
 01 WS-SOURCE              BINARY-LONG VALUE 1.
 01 WS-ALREADY             BINARY-LONG VALUE 0.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-RARE                BINARY-LONG.
 01 WS-COIN                BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-PARTNER             BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-APPLY               BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-DEAD                BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-COOL                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-LASTD               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SEEN.
    05 WS-CELL             BINARY-LONG OCCURS 2197 TIMES.
 01 WS-POS                 BINARY-LONG.
 01 WS-DISTINCT            BINARY-LONG.
 01 WS-ERASED              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   13.5: 14/14, hit for 4, draw A 0, draw B anything below 4.
     MOVE 4 TO WS-DMG
     MOVE 14 TO WS-HEALTH
     MOVE 0 TO WS-DA
     MOVE 2 TO WS-DB
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 13.5 a hit of 4 at 14/14 in water by an entity: play dead (PLAY_DEAD_TICKS 200)" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§8.3 both draws were made (A then B)" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE WS-DRAWS TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-DMG
     MOVE 0 TO WS-DB
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 13.5 a hit of 1: draw B 0 is below 1, so step 3 holds" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-DB
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 13.5 a hit of 1 with draw B 1 at full health fails (ratio not below 0.5)" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 6 TO WS-HEALTH
     MOVE 2 TO WS-DMG
     MOVE 2 TO WS-DB
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 13.5 at 6/14 (ratio 0.43) a hit of 2 passes step 3 whatever draw B is" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 6 TO WS-DMG
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 13.5 a hit of 6 at health 6 fails step 4 (6 < 6 is false)" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 14 TO WS-HEALTH
     MOVE 4 TO WS-DMG
     MOVE 0 TO WS-AI
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 step 1: with AI off no draw is made and the test fails" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§8.3 step 1 draws: 0" TO WS-NAME
     MOVE WS-DRAWS TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-AI
     MOVE 1 TO WS-DA
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 step 2: draw A not 0 fails after exactly one draw" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-DRAWS TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-DA
     MOVE 0 TO WS-INWATER
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 step 5: out of water (rain does not count) fails" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-INWATER
     MOVE 0 TO WS-SOURCE
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 step 6: an environmental source (no entity) fails" TO WS-NAME
     PERFORM EXPECT
     MOVE 1 TO WS-SOURCE
     MOVE 1 TO WS-ALREADY
     PERFORM PLAYDEAD
     MOVE "acceptance US15 44-7§8.3 step 7: an axolotl already playing dead fails" TO WS-NAME
     PERFORM EXPECT
*>   ValidatePlayDead: 200 ticks.
     MOVE 200 TO WS-TICKS
     MOVE 0 TO WS-I
     MOVE 0 TO WS-ERASED
     PERFORM UNTIL WS-ERASED = 1
         CALL "Q7-AXO-VALIDATE" USING WS-TICKS WS-ERASED
         IF WS-ERASED = 0
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-7§8.3 the memory counts down from 200: 200 ticks, then it is erased" TO WS-NAME
     MOVE 200 TO WS-EXP
     MOVE WS-I TO WS-OBS
     PERFORM EXPECT
*>   8.1 babies by group size, 13.6: a pack of 5.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SIZE FROM 0 BY 1 UNTIL WS-SIZE > 4
         CALL "Q7-AXO-GROUP-BABY" USING WS-SIZE WS-OBS
         IF (WS-SIZE < 2 AND WS-OBS = 1) OR (WS-SIZE >= 2 AND WS-OBS = 0)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-7§8.1 13.6 a pack of 5: members 1 and 2 adults, 3 to 5 babies (group size at least 2)" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-BAD TO WS-OBS
     PERFORM EXPECT
*>   8.2 offspring variant.
     MOVE 0 TO WS-RARE
     MOVE 1 TO WS-COIN
     MOVE 2 TO WS-OWN
     MOVE 3 TO WS-PARTNER
     CALL "Q7-AXO-OFFSPRING" USING WS-RARE WS-COIN WS-OWN WS-PARTNER WS-OBS
     MOVE "acceptance US15 44-7§8.2 nextInt(1200) == 0: the child is blue (id 4) whatever the parents" TO WS-NAME
     MOVE 4 TO WS-EXP
     PERFORM EXPECT
     MOVE 1199 TO WS-RARE
     CALL "Q7-AXO-OFFSPRING" USING WS-RARE WS-COIN WS-OWN WS-PARTNER WS-OBS
     MOVE "acceptance US15 44-7§8.2 otherwise coin true: this parent's variant (gold 2)" TO WS-NAME
     MOVE 2 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-COIN
     CALL "Q7-AXO-OFFSPRING" USING WS-RARE WS-COIN WS-OWN WS-PARTNER WS-OBS
     MOVE "acceptance US15 44-7§8.2 coin false: the partner's variant (cyan 3)" TO WS-NAME
     MOVE 3 TO WS-EXP
     PERFORM EXPECT
*>   8.4 air and rehydration (13.7).
     MOVE 2000 TO WS-AIR
     CALL "Q7-AXO-REHYDRATE" USING WS-AIR
     MOVE "acceptance US15 44-7§8.4 13.7 air 2000 + 1800 = 3800" TO WS-NAME
     MOVE 3800 TO WS-EXP
     MOVE WS-AIR TO WS-OBS
     PERFORM EXPECT
     MOVE 5000 TO WS-AIR
     CALL "Q7-AXO-REHYDRATE" USING WS-AIR
     MOVE "acceptance US15 44-7§8.4 13.7 air 5000 is capped at 6000" TO WS-NAME
     MOVE 6000 TO WS-EXP
     MOVE WS-AIR TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-WET
     MOVE 1 TO WS-AIR
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-DAMAGE = 2
         CALL "Q7-AXO-AIR" USING WS-AIR WS-WET WS-DAMAGE
         ADD 1 TO WS-I
     END-PERFORM
     MOVE "acceptance US15 44-7§8.4 out of water the air falls by 1 a tick and at -20 the axolotl takes 2 (21 ticks from air 1)" TO WS-NAME
     MOVE 21 TO WS-EXP
     MOVE WS-I TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§8.4 and the air is reset to 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-AIR TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-WET
     CALL "Q7-AXO-AIR" USING WS-AIR WS-WET WS-DAMAGE
     MOVE "acceptance US15 44-7§8.4 in water (or rain) the air is the maximum 6000" TO WS-NAME
     MOVE 6000 TO WS-EXP
     MOVE WS-AIR TO WS-OBS
     PERFORM EXPECT
*>   8.5 supporting effects (13.8).
     MOVE 1 TO WS-HAS
     MOVE 1000 TO WS-DUR
     CALL "Q7-AXO-SUPPORT" USING WS-HAS WS-DUR WS-NEW WS-APPLY
     MOVE "acceptance US15 44-7§8.5 13.8 Regeneration with 1000 left: new duration min(2400, 1100) = 1100" TO WS-NAME
     MOVE 1100 TO WS-EXP
     MOVE WS-NEW TO WS-OBS
     PERFORM EXPECT
     MOVE 2399 TO WS-DUR
     CALL "Q7-AXO-SUPPORT" USING WS-HAS WS-DUR WS-NEW WS-APPLY
     MOVE "acceptance US15 44-7§8.5 2399 left: capped at 2400" TO WS-NAME
     MOVE 2400 TO WS-EXP
     MOVE WS-NEW TO WS-OBS
     PERFORM EXPECT
     MOVE 2400 TO WS-DUR
     CALL "Q7-AXO-SUPPORT" USING WS-HAS WS-DUR WS-NEW WS-APPLY
     MOVE "acceptance US15 44-7§8.5 13.8 2400 left: endsWithin(2399) is false, nothing is granted" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-APPLY TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-HAS
     CALL "Q7-AXO-SUPPORT" USING WS-HAS WS-DUR WS-NEW WS-APPLY
     MOVE "acceptance US15 44-7§8.5 no Regeneration: 100 ticks" TO WS-NAME
     MOVE 100 TO WS-EXP
     MOVE WS-NEW TO WS-OBS
     PERFORM EXPECT
*>   8.3 updateActivity and the hunting cooldown.
     MOVE 1 TO WS-ACTIVE
     MOVE 0 TO WS-DEAD
     MOVE 0 TO WS-TARGET
     MOVE 0 TO WS-COOL
     CALL "Q7-AXO-ACTIVITY" USING WS-ACTIVE WS-DEAD WS-TARGET WS-COOL
     MOVE "acceptance US15 44-7§8.3 a fight that ends sets HAS_HUNTING_COOLDOWN for 2400 ticks" TO WS-NAME
     MOVE 2400 TO WS-EXP
     MOVE WS-COOL TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§8.3 and the activity is IDLE (0)" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-ACTIVE TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-ACTIVE
     MOVE 1 TO WS-TARGET
     CALL "Q7-AXO-ACTIVITY" USING WS-ACTIVE WS-DEAD WS-TARGET WS-COOL
     MOVE "acceptance US15 44-7§8.3 with an attack target the first valid activity is FIGHT (1)" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-ACTIVE TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-DEAD
     CALL "Q7-AXO-ACTIVITY" USING WS-ACTIVE WS-DEAD WS-TARGET WS-COOL
     MOVE "acceptance US15 44-7§8.3 PLAY_DEAD comes before FIGHT (2); leaving FIGHT that way also sets the cooldown" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE WS-ACTIVE TO WS-OBS
     PERFORM EXPECT
     MOVE 2400 TO WS-EXP
     MOVE WS-COOL TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-DEAD
     MOVE 1 TO WS-TARGET
     CALL "Q7-AXO-ACTIVITY" USING WS-ACTIVE WS-DEAD WS-TARGET WS-COOL
     MOVE "acceptance US15 44-7§8.3 while PLAY_DEAD is active the activity is not re-chosen" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE WS-ACTIVE TO WS-OBS
     PERFORM EXPECT
*>   8.6 speeds.
     MOVE 1 TO WS-KIND
     MOVE 1 TO WS-INWATER
     CALL "Q7-AXO-SPEED" USING WS-KIND WS-INWATER WS-SPEED
     MOVE "acceptance US15 44-7§8.6 chasing in water 0.6 (x100)" TO WS-NAME
     MOVE 60 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 100
     PERFORM EXPECT
     MOVE 2 TO WS-KIND
     CALL "Q7-AXO-SPEED" USING WS-KIND WS-INWATER WS-SPEED
     MOVE "acceptance US15 44-7§8.6 following an adult in water 0.6 (x100)" TO WS-NAME
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 100
     PERFORM EXPECT
     MOVE 3 TO WS-KIND
     CALL "Q7-AXO-SPEED" USING WS-KIND WS-INWATER WS-SPEED
     MOVE "acceptance US15 44-7§8.6 idling in water 0.5 (x100)" TO WS-NAME
     MOVE 50 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 100
     PERFORM EXPECT
     MOVE 4 TO WS-KIND
     CALL "Q7-AXO-SPEED" USING WS-KIND WS-INWATER WS-SPEED
     MOVE "acceptance US15 44-7§8.6 making love 0.2 (x100)" TO WS-NAME
     MOVE 20 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 100
     PERFORM EXPECT
     MOVE 0 TO WS-INWATER
     MOVE 1 TO WS-KIND
     CALL "Q7-AXO-SPEED" USING WS-KIND WS-INWATER WS-SPEED
     MOVE "acceptance US15 44-7§8.6 on land the chasing speed falls to 0.15 (x100)" TO WS-NAME
     MOVE 15 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 100
     PERFORM EXPECT
     MOVE 3 TO WS-KIND
     CALL "Q7-AXO-SPEED" USING WS-KIND WS-INWATER WS-SPEED
     MOVE "acceptance US15 44-7§8.6 and the idle speed too (x100)" TO WS-NAME
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 100
     PERFORM EXPECT
*>   8.6 scan order.
     MOVE 0 TO WS-I
     CALL "Q7-SCAN-ORDER" USING WS-I WS-X WS-Y WS-Z
     MOVE "acceptance US15 44-7§8.6 the first position emitted is the origin" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION ABS(WS-X) + FUNCTION ABS(WS-Y) + FUNCTION ABS(WS-Z)
     PERFORM EXPECT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "Q7-SCAN-ORDER" USING WS-I WS-X WS-Y WS-Z
         EVALUATE WS-I
             WHEN 1
                 IF NOT (WS-X = -1 AND WS-Y = 0 AND WS-Z = 0)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 2
                 IF NOT (WS-X = 0 AND WS-Y = -1 AND WS-Z = 0)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 3
                 IF NOT (WS-X = 0 AND WS-Y = 0 AND WS-Z = 1)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 4
                 IF NOT (WS-X = 0 AND WS-Y = 0 AND WS-Z = -1)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 5
                 IF NOT (WS-X = 0 AND WS-Y = 1 AND WS-Z = 0)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 6
                 IF NOT (WS-X = 1 AND WS-Y = 0 AND WS-Z = 0)
                     ADD 1 TO WS-BAD
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US15 44-7§8.6 the worked example: depth 1 is (-1,0,0) (0,-1,0) (0,0,+1) (0,0,-1) (0,+1,0) (+1,0,0)" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-BAD TO WS-OBS
     PERFORM EXPECT
*>   The whole sequence: 13 x 13 x 13 offsets, each once, depth never falling, all within 6.
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-LASTD
     MOVE 0 TO WS-DISTINCT
     INITIALIZE WS-SEEN
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2196
         CALL "Q7-SCAN-ORDER" USING WS-I WS-X WS-Y WS-Z
         IF FUNCTION ABS(WS-X) > 6 OR FUNCTION ABS(WS-Y) > 6 OR FUNCTION ABS(WS-Z) > 6
             ADD 1 TO WS-BAD
         ELSE
             COMPUTE WS-D = FUNCTION ABS(WS-X) + FUNCTION ABS(WS-Y) + FUNCTION ABS(WS-Z)
             IF WS-D < WS-LASTD
                 ADD 1 TO WS-BAD
             END-IF
             MOVE WS-D TO WS-LASTD
             COMPUTE WS-POS = (WS-X + 6) * 169 + (WS-Y + 6) * 13 + WS-Z + 6 + 1
             IF WS-CELL(WS-POS) = 0
                 ADD 1 TO WS-DISTINCT
             END-IF
             MOVE 1 TO WS-CELL(WS-POS)
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-7§8.6 the 2197 emitted offsets are all inside the 13 x 13 x 13 box with non-decreasing depth" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-BAD TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§8.6 and all 2197 are distinct (a box, not a diamond)" TO WS-NAME
     MOVE 2197 TO WS-EXP
     MOVE WS-DISTINCT TO WS-OBS
     PERFORM EXPECT
     MOVE 2197 TO WS-I
     CALL "Q7-SCAN-ORDER" USING WS-I WS-X WS-Y WS-Z
     MOVE "acceptance US15 44-7§8.6 there is no 2198th position" TO WS-NAME
     MOVE 99 TO WS-EXP
     MOVE WS-X TO WS-OBS
     PERFORM EXPECT
     MOVE 18 TO WS-D
     MOVE 2196 TO WS-I
     CALL "Q7-SCAN-ORDER" USING WS-I WS-X WS-Y WS-Z
     MOVE "acceptance US15 44-7§8.6 the last position is (6,6,-6): depth 18, dx and dy last, the mirrored negative z after the positive one (sum 6)" TO WS-NAME
     MOVE 6 TO WS-EXP
     COMPUTE WS-OBS = WS-X + WS-Y + WS-Z
     PERFORM EXPECT
     STOP RUN.
 PLAYDEAD.
     CALL "Q7-AXO-PLAYDEAD" USING WS-AI WS-DA WS-DB WS-DMG WS-HEALTH WS-MAX WS-INWATER WS-SOURCE WS-ALREADY WS-OBS WS-DRAWS.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-7-8.
