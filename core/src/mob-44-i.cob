*> Cat relaxing on a sleeping owner and the morning gift (002-lane-mobsa3; docs/protocol/19 section 5.1 "Morning gift", 44 part 4 section 6, 33 section 5).
*> M44-CAT-GIFT-CHANCE USING day tick (0 to 23999), chance in thousandths out: the day-timeline track cat_waking_up_gift_chance, 0.7 from tick 23667 and 0.0 from tick 362 (constant easing).
*> M44-CAT-GIFT-PICK USING draw (0 to 61), item key out (PIC X(24)): the table gameplay/cat_morning_gift: rabbit_hide, rabbit_foot, chicken, feather, rotten_flesh, string (10 each) and
*>   phantom_membrane (2), one roll.
*> CAT-RELAX USING row, owner player row, walk out: CatRelaxOnOwnerGoal for a tame cat that is not ordered to sit. Usable when the owner sleeps (W2-SLEEPING, 33 section 5) within 10 blocks
*>   (squared distance at most 100) and the block at the owner's position is a bed (the tag cats_can_lie_on is #beds); the cat then stays still (walk 2) and EN-CAT-RELAX is 1, 2 once the
*>   owner's sleep counter has reached 100. When the goal stops (the owner wakes or leaves) at EN-CAT-RELAX 2 (the owner's sleep timer is at least 100: the counter is reset on waking, so the
*>   cat remembers it) and nextFloat is below the chance, the cat gives a gift: it teleports to the block of its position + (nextInt(11) - 5, nextInt(5) - 2, nextInt(11) - 5) when the
*>   cell and the one above are air and the one below is not (the tag cat_does_not_teleport_to is not in the docs: gap) and drops one item of the table there.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-CAT-GIFT-CHANCE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICK                 BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-TICK L-CHANCE.
     MOVE 0 TO L-CHANCE
     IF L-TICK >= 23667 OR L-TICK < 362
         MOVE 700 TO L-CHANCE
     END-IF
     GOBACK.
 END PROGRAM M44-CAT-GIFT-CHANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-CAT-GIFT-PICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-DRAW L-KEY.
     EVALUATE TRUE
         WHEN L-DRAW < 10 MOVE "rabbit_hide" TO L-KEY
         WHEN L-DRAW < 20 MOVE "rabbit_foot" TO L-KEY
         WHEN L-DRAW < 30 MOVE "chicken" TO L-KEY
         WHEN L-DRAW < 40 MOVE "feather" TO L-KEY
         WHEN L-DRAW < 50 MOVE "rotten_flesh" TO L-KEY
         WHEN L-DRAW < 60 MOVE "string" TO L-KEY
         WHEN OTHER MOVE "phantom_membrane" TO L-KEY
     END-EVALUATE
     GOBACK.
 END PROGRAM M44-CAT-GIFT-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAT-RELAX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WSIM2.
 01 WS-D2                  FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BED                 BINARY-LONG.
 01 WS-SLEEPING            BINARY-LONG.
 01 WS-DAYTICK             BINARY-LONG.
 01 WS-CHANCE              BINARY-LONG.
 01 WS-SALT-F              BINARY-LONG VALUE 95.
 01 WS-BOUND-F             BINARY-LONG VALUE 1000.
 01 WS-DRAW-F              BINARY-LONG.
 01 WS-SALT-X              BINARY-LONG VALUE 96.
 01 WS-SALT-Y              BINARY-LONG VALUE 97.
 01 WS-SALT-Z              BINARY-LONG VALUE 98.
 01 WS-BOUND-X             BINARY-LONG VALUE 11.
 01 WS-BOUND-Y             BINARY-LONG VALUE 5.
 01 WS-DRAW-X              BINARY-LONG.
 01 WS-DRAW-Y              BINARY-LONG.
 01 WS-DRAW-Z              BINARY-LONG.
 01 WS-SALT-G              BINARY-LONG VALUE 99.
 01 WS-BOUND-G             BINARY-LONG VALUE 62.
 01 WS-DRAW-G              BINARY-LONG.
 01 WS-GIFT                PIC X(24).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-STATE-FEET          BINARY-LONG.
 01 WS-STATE-HEAD          BINARY-LONG.
 01 WS-STATE-FLOOR         BINARY-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-GROUND              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OWNER L-WALK.
     MOVE 0 TO L-WALK
     MOVE 0 TO WS-SLEEPING WS-BED
     IF L-OWNER > 0
         CALL "WORLDSIM-ENSURE2"
         IF W2-SLEEPING(L-OWNER) = 1
             COMPUTE WS-D2 = (PL-X(L-OWNER) - EN-X(L-ROW)) ** 2 + (PL-Y(L-OWNER) - EN-Y(L-ROW)) ** 2
                 + (PL-Z(L-OWNER) - EN-Z(L-ROW)) ** 2
             COMPUTE WS-X = FUNCTION INTEGER(PL-X(L-OWNER))
             COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(L-OWNER))
             COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(L-OWNER))
             CALL "IP-BLOCK-KEY" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KEY WS-LENGTH
             IF WS-LENGTH > 4 AND WS-KEY(WS-LENGTH - 3:4) = "_bed"
                 MOVE 1 TO WS-BED
             END-IF
             IF WS-D2 <= 100 AND WS-BED = 1
                 MOVE 1 TO WS-SLEEPING
             END-IF
         END-IF
     END-IF
     IF WS-SLEEPING = 1
         IF EN-CAT-RELAX(L-ROW) = 0
             MOVE 1 TO EN-CAT-RELAX(L-ROW)
         END-IF
         IF W2-SLEEP-COUNTER(L-OWNER) >= 100
             MOVE 2 TO EN-CAT-RELAX(L-ROW)
         END-IF
         MOVE 2 TO L-WALK
         GOBACK
     END-IF
     IF EN-CAT-RELAX(L-ROW) > 0
         PERFORM STOP-RELAX
     END-IF
     GOBACK.

 STOP-RELAX.
     IF EN-CAT-RELAX(L-ROW) = 2
         COMPUTE WS-DAYTICK = FUNCTION MOD(CW-TIME, 24000)
         CALL "M44-CAT-GIFT-CHANCE" USING WS-DAYTICK WS-CHANCE
         CALL "XP-RANDOM" USING WS-SALT-F WS-BOUND-F WS-DRAW-F
         IF WS-DRAW-F < WS-CHANCE
             PERFORM GIVE-GIFT
         END-IF
     END-IF
     MOVE 0 TO EN-CAT-RELAX(L-ROW).

 GIVE-GIFT.
     CALL "XP-RANDOM" USING WS-SALT-X WS-BOUND-X WS-DRAW-X
     CALL "XP-RANDOM" USING WS-SALT-Y WS-BOUND-Y WS-DRAW-Y
     CALL "XP-RANDOM" USING WS-SALT-Z WS-BOUND-X WS-DRAW-Z
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW)) + WS-DRAW-X - 5
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW)) + WS-DRAW-Y - 2
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW)) + WS-DRAW-Z - 5
     COMPUTE WS-UP = WS-Y + 1
     COMPUTE WS-DOWN = WS-Y - 1
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE-FEET
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-UP WS-Z WS-STATE-HEAD
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-DOWN WS-Z WS-STATE-FLOOR
     IF WS-STATE-FEET = 0 AND WS-STATE-HEAD = 0 AND WS-STATE-FLOOR NOT = 0
         COMPUTE WS-NX = WS-X + 0.5
         COMPUTE WS-NZ = WS-Z + 0.5
         MOVE WS-Y TO WS-NY
         MOVE EN-YAW(L-ROW) TO WS-YAW
         MOVE EN-PITCH(L-ROW) TO WS-PITCH
         CALL "ENTITY-MOVE" USING L-ROW WS-NX WS-NY WS-NZ WS-YAW WS-PITCH WS-GROUND
     END-IF
     CALL "XP-RANDOM" USING WS-SALT-G WS-BOUND-G WS-DRAW-G
     CALL "M44-CAT-GIFT-PICK" USING WS-DRAW-G WS-GIFT
     CALL "MOB-DROP-ITEMS" USING L-ROW WS-GIFT WS-ONE.
 END PROGRAM CAT-RELAX.
