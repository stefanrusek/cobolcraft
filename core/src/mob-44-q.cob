*> Fox melee, sleep, faceplant, berries and item search (002-lane-mobsa5; docs/protocol/44 part 4 section 4, 44-x1 section 8.7, 19 section 7).
*> - M44-FOX-MELEE (FoxMeleeAttack(1.2), attack_damage 2): the prey (EN-FOE) is hit for 2 when its position is within the reach (2 x the fox's width)^2 + the prey's width = 1.44 + w (squared distance
*>   of the positions) and the attack cooldown EN-FOX-ATK (20 ticks after a hit) is 0. M44-FOX-HUNT calls it after the stalk; its walk at 1.2 is not written (see mob-44-a.cob).
*> - M44-FOX-SLEEP (SleepGoal): countdown nextInt(140) (rolled at the first call, EN-FOX-SLP = remaining + 1); at 0 it sleeps (flag 32; sitting, crouching and interested cleared) when it is not bright outside
*>   (the sky darkening of the day clock is 4 or more) or has a shelter (its cell does not see the sky; the walk-target value of the doc is not known: treated as above 0), no alertable entity within
*>   (12, 6, 12) (a standard mob other than a fox, a player who is not sneaking, creative or spectator) and is not in powder snow (not modelled). A sleeping fox wakes with a target, in water (not modelled:
*>   no water flag for mobs here) or in thunder; the countdown is then rolled again.
*> - M44-FOX-FACEPLANT (FaceplantGoal): flag 64: the countdown starts at 40, counts down, at 0 the flag is cleared. Who sets the flag is the pounce code and no doc gives the rule (gap): nothing sets it
*>   but the entry points; the fox stands still while it is faceplanted or asleep.
*> - M44-FOX-BERRIES (FoxEatBerriesGoal(1.2, 12, 1)): every 100 ticks (the cadence of the MoveToBlockGoal start is not in the docs: gap; 100 is the path recalculation interval) with an empty or any hand
*>   the nearest sweet berry bush of age 2 or more in the box 12 x 1 x 12 is the target; the fox walks to within 2 blocks, waits 40 ticks, and with the game rule mob_griefing on sets the bush to age 1;
*>   berries 1 + nextInt(2) (+ 1 when the age was 3): with an empty hand one goes into the hand and the rest is popped as an item at the bush, else all of them are popped. Cave vines with glow berries: the
*>   vine's pick routine is not in the docs (gap); the sniff sound is not sent.
*> - M44-FOX-ITEMS (FoxSearchForItemsGoal): an empty hand, no prey and no player who hit it, a 1 in 10 roll a tick: the first listed ground item without pickup delay within 8 blocks on each axis is walked
*>   to at 1.2 x 0.3; within 1 block the fox takes one (the rest of the stack is dropped again), Take Item Entity goes to the viewers and the item is in the hand (EN-FOX-HELD).
*> - M44-FOX-IDLE USING row, hx out, hz out, walk out (called by FOX-TICK when nothing hunted): faceplant, sleep, berries, item search in that order; walk 2 stands still.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-DRAW.
*> USING row, salt, bound, draw out: a deterministic draw 0 to bound - 1 from the entity id, the game time and the salt.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SALT                 BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SALT L-BOUND L-DRAW.
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE L-SALT TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE L-DRAW = FUNCTION MOD(WS-R, L-BOUND)
     GOBACK.
 END PROGRAM M44-FOX-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-FLAG.
*> USING row, bit (1, 4, 8, 16, 32, 64, 128), on out (1 when the flag is set).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BIT                  BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BIT L-ON.
     COMPUTE L-ON = FUNCTION MOD(FUNCTION INTEGER(EN-FOX-FLAGS(L-ROW) / L-BIT), 2)
     GOBACK.
 END PROGRAM M44-FOX-FLAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-SETFLAG.
*> USING row, bit, on (1 set, 0 cleared).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-NOW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BIT                  BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BIT L-ON.
     CALL "M44-FOX-FLAG" USING L-ROW L-BIT WS-NOW
     IF WS-NOW = 0 AND L-ON = 1
         ADD L-BIT TO EN-FOX-FLAGS(L-ROW)
     END-IF
     IF WS-NOW = 1 AND L-ON = 0
         SUBTRACT L-BIT FROM EN-FOX-FLAGS(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-SETFLAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-MELEE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY RULES.
 01 WS-PREY                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-REACH2              FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 2.
 01 WS-NO-PLAYER           BINARY-LONG VALUE 0.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-MOB.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HIT.
     MOVE 0 TO L-HIT
     IF EN-FOX-ATK(L-ROW) > 0
         SUBTRACT 1 FROM EN-FOX-ATK(L-ROW)
     END-IF
     MOVE EN-FOE(L-ROW) TO WS-PREY
     IF WS-PREY > 0 AND EN-FOX-ATK(L-ROW) = 0
         COMPUTE WS-TYPE = EN-TYPE(WS-PREY) + 1
         COMPUTE WS-REACH2 = 1.44 + ET-WIDTH-MILLI(WS-TYPE) / 1000
         COMPUTE WS-D2 = (EN-X(WS-PREY) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-PREY) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-PREY) - EN-Z(L-ROW)) ** 2
         IF WS-D2 <= WS-REACH2
             CALL "HEALTH-MOB-DAMAGE" USING WS-PREY WS-DAMAGE WS-CAUSE WS-NO-PLAYER
             MOVE 20 TO EN-FOX-ATK(L-ROW)
             MOVE 1 TO L-HIT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-MELEE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-ALERT.
*> USING row, alert out: an entity that keeps the fox awake within (12, 6, 12): a standard mob other than a fox, or a player who is not sneaking, creative or spectator (trust: FOX-TRUSTS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-TRUSTS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ALERT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ALERT.
     MOVE 0 TO L-ALERT
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-ALERT = 1
         IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
                 AND FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= 12 AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= 12
                 AND FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-ROW)) <= 6
             CALL "MOB-SPECIES-KEY" USING WS-E WS-KEY
             IF WS-KEY NOT = SPACES AND WS-KEY NOT = "fox"
                 MOVE 1 TO L-ALERT
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR L-ALERT = 1
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-SNEAKING(WS-P) = 0
                 AND PL-MODE(WS-P) NOT = 1 AND PL-MODE(WS-P) NOT = 3
                 AND FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW)) <= 12 AND FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW)) <= 12
                 AND FUNCTION ABS(PL-Y(WS-P) - EN-Y(L-ROW)) <= 6
             CALL "FOX-TRUSTS" USING L-ROW WS-P WS-TRUSTS
             IF WS-TRUSTS = 0
                 MOVE 1 TO L-ALERT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M44-FOX-ALERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-SLEEP.
*> USING row, asleep out (1 while the fox sleeps after this call).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 150.
 01 WS-BOUND               BINARY-LONG VALUE 140.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 01 WS-OFF                 BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLEEP-BIT           BINARY-LONG VALUE 32.
 01 WS-SIT-BIT             BINARY-LONG VALUE 1.
 01 WS-CROUCH-BIT          BINARY-LONG VALUE 4.
 01 WS-INTEREST-BIT        BINARY-LONG VALUE 8.
 01 WS-DARK                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ALERT               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ASLEEP               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ASLEEP.
     CALL "M44-FOX-FLAG" USING L-ROW WS-SLEEP-BIT WS-ON
     IF WS-ON = 1
*>       Wake with a target (prey) or in thunder; the countdown is rolled again.
         IF EN-FOE(L-ROW) > 0 OR CW-THUNDERING = 1
             CALL "M44-FOX-SETFLAG" USING L-ROW WS-SLEEP-BIT WS-OFF
             CALL "M44-FOX-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
             COMPUTE EN-FOX-SLP(L-ROW) = WS-DRAW + 1
             MOVE 0 TO L-ASLEEP
         ELSE
             MOVE 1 TO L-ASLEEP
         END-IF
         GOBACK
     END-IF
     MOVE 0 TO L-ASLEEP
     IF EN-FOX-SLP(L-ROW) = 0
         CALL "M44-FOX-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
         COMPUTE EN-FOX-SLP(L-ROW) = WS-DRAW + 1
     END-IF
     IF EN-FOX-SLP(L-ROW) > 1
         SUBTRACT 1 FROM EN-FOX-SLP(L-ROW)
         GOBACK
     END-IF
     MOVE CW-TIME TO WS-TIME
     CALL "STDMOB-DARKEN" USING WS-TIME WS-DARK
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "STDMOB-LIGHTS" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-SKY WS-BLOCK
     CALL "M44-FOX-ALERT" USING L-ROW WS-ALERT
     MOVE 0 TO WS-OK
     IF WS-DARK >= 4 OR (WS-SKY < 15 AND WS-ALERT = 0)
         MOVE 1 TO WS-OK
     END-IF
     IF WS-OK = 1
         CALL "M44-FOX-SETFLAG" USING L-ROW WS-SLEEP-BIT WS-ONE
         CALL "M44-FOX-SETFLAG" USING L-ROW WS-SIT-BIT WS-OFF
         CALL "M44-FOX-SETFLAG" USING L-ROW WS-CROUCH-BIT WS-OFF
         CALL "M44-FOX-SETFLAG" USING L-ROW WS-INTEREST-BIT WS-OFF
         MOVE 0 TO EN-FOX-CROUCH(L-ROW)
         MOVE 1 TO L-ASLEEP
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-SLEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-FACEPLANT.
*> USING row, planted out (1 while the fox is faceplanted after this call).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-BIT                 BINARY-LONG VALUE 64.
 01 WS-ON                  BINARY-LONG.
 01 WS-OFF                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLANTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLANTED.
     MOVE 0 TO L-PLANTED
     CALL "M44-FOX-FLAG" USING L-ROW WS-BIT WS-ON
     IF WS-ON = 1
         IF EN-FOX-FP(L-ROW) = 0
             MOVE 40 TO EN-FOX-FP(L-ROW)
         END-IF
         SUBTRACT 1 FROM EN-FOX-FP(L-ROW)
         IF EN-FOX-FP(L-ROW) > 0
             MOVE 1 TO L-PLANTED
         ELSE
             CALL "M44-FOX-SETFLAG" USING L-ROW WS-BIT WS-OFF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-FACEPLANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-BERRIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BUSH-KEY            PIC X(26) VALUE "minecraft:sweet_berry_bush".
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-PROP                PIC X(24) VALUE "age".
 01 WS-MODE-READ           BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-ONE-TEXT            PIC X(32) VALUE "1".
 01 WS-RULE                PIC X(40) VALUE "mob_griefing".
 01 WS-GRIEF               BINARY-DOUBLE.
 01 WS-SALT                BINARY-LONG VALUE 151.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BERRIES             BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112) VALUE "minecraft:sweet_berries".
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-HOR2                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     GO TO MAIN-LINE.
 READ-BUSH.
*>   WS-FOUND 1 when the cell holds a sweet berry bush of age 2 or more; WS-AGE its age, WS-STATE its state.
     MOVE 0 TO WS-FOUND WS-AGE
     CALL "IP-BLOCK-KEY" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KEY WS-LENGTH
     IF WS-LENGTH = 26 AND WS-KEY(1:26) = WS-BUSH-KEY
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
         CALL "BLOCK-STATE-PROP" USING WS-MODE-READ WS-STATE WS-PROP WS-TEXT WS-RESULT
         IF WS-RESULT = 1
             COMPUTE WS-AGE = FUNCTION NUMVAL(WS-TEXT)
             IF WS-AGE >= 2
                 MOVE 1 TO WS-FOUND
             END-IF
         END-IF
     END-IF.

 SEARCH-BUSH.
     MOVE 1000000 TO WS-BEST-D2
     PERFORM VARYING WS-DX FROM -12 BY 1 UNTIL WS-DX > 12
         PERFORM VARYING WS-DZ FROM -12 BY 1 UNTIL WS-DZ > 12
             PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
                 COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW)) + WS-DX
                 COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW)) + WS-DY
                 COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW)) + WS-DZ
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ + WS-DY * WS-DY
                 IF WS-D2 < WS-BEST-D2
                     PERFORM READ-BUSH
                     IF WS-FOUND = 1
                         MOVE WS-D2 TO WS-BEST-D2
                         MOVE 1 TO EN-FOX-BON(L-ROW)
                         MOVE WS-X TO EN-FOX-BX(L-ROW)
                         MOVE WS-Y TO EN-FOX-BY(L-ROW)
                         MOVE WS-Z TO EN-FOX-BZ(L-ROW)
                         MOVE 0 TO EN-FOX-BT(L-ROW)
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 PICK.
     CALL "BR-RULE-GET" USING WS-RULE WS-GRIEF
     IF WS-GRIEF = 1
         CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-PROP WS-ONE-TEXT WS-NEW
         CALL "BLOCK-CHANGE" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-NEW
         CALL "M44-FOX-DRAW" USING L-ROW WS-SALT WS-TWO WS-DRAW
         COMPUTE WS-BERRIES = 1 + WS-DRAW
         IF WS-AGE = 3
             ADD 1 TO WS-BERRIES
         END-IF
         CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         IF EN-FOX-HELD(L-ROW) = 0
             MOVE WS-ITEM TO EN-FOX-HELD(L-ROW)
             SUBTRACT 1 FROM WS-BERRIES
         END-IF
         IF WS-BERRIES > 0
             COMPUTE WS-PX = WS-X + 0.5
             COMPUTE WS-PY = WS-Y
             COMPUTE WS-PZ = WS-Z + 0.5
             CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-OFFSET WS-ITEM WS-BERRIES WS-PATCH WS-DROPPED
         END-IF
     END-IF
     MOVE 0 TO EN-FOX-BON(L-ROW) EN-FOX-BT(L-ROW).
 MAIN-LINE.
     MOVE 0 TO L-HX L-HZ L-WALK
     IF EN-FOX-BON(L-ROW) = 0
         IF EN-FOX-BCD(L-ROW) > 0
             SUBTRACT 1 FROM EN-FOX-BCD(L-ROW)
         ELSE
             MOVE 100 TO EN-FOX-BCD(L-ROW)
             PERFORM SEARCH-BUSH
         END-IF
     END-IF
     IF EN-FOX-BON(L-ROW) = 1
         MOVE EN-FOX-BX(L-ROW) TO WS-X
         MOVE EN-FOX-BY(L-ROW) TO WS-Y
         MOVE EN-FOX-BZ(L-ROW) TO WS-Z
         PERFORM READ-BUSH
         IF WS-FOUND = 0
             MOVE 0 TO EN-FOX-BON(L-ROW) EN-FOX-BT(L-ROW)
         ELSE
             COMPUTE WS-HOR2 = (EN-X(L-ROW) - (WS-X + 0.5)) ** 2 + (EN-Z(L-ROW) - (WS-Z + 0.5)) ** 2
             IF WS-HOR2 <= 4 AND FUNCTION ABS(EN-Y(L-ROW) - WS-Y) <= 2
                 MOVE 1 TO L-WALK
                 ADD 1 TO EN-FOX-BT(L-ROW)
                 IF EN-FOX-BT(L-ROW) >= 40
                     PERFORM PICK
                 END-IF
             ELSE
                 MOVE 1 TO L-WALK
                 CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
                 CALL "STDMOB-HEAD" USING L-ROW WS-M WS-X WS-Y WS-Z L-HX L-HZ WS-ARRIVED
                 COMPUTE L-HX = L-HX * 1.2
                 COMPUTE L-HZ = L-HZ * 1.2
             END-IF
         END-IF
     END-IF
     CONTINUE.
 END PROGRAM M44-FOX-BERRIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-ITEMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-SALT                BINARY-LONG VALUE 152.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-DRAW                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-TAKE                BINARY-LONG VALUE 1.
 01 WS-ID-ITEM             BINARY-LONG.
 01 WS-ID-ME               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK WS-FOUND
     IF EN-FOX-HELD(L-ROW) = 0 AND EN-FOE(L-ROW) = 0 AND EN-KILLER(L-ROW) = 0
         MOVE 0 TO WS-E
         IF EN-FOX-ITEM(L-ROW) = 0
             CALL "M44-FOX-DRAW" USING L-ROW WS-SALT WS-TEN WS-DRAW
         ELSE
             MOVE 0 TO WS-DRAW
         END-IF
         IF WS-DRAW = 0
             *>   The item it walks to already (EN-FOX-ITEM) stays the one; else the first listed allowed item in the box.
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-FOUND > 0
                 IF EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-ITEM-COUNT(WS-E) > 0 AND EN-DELAY(WS-E) = 0
                         AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-ITEM(WS-E) > 0
                         AND FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= 8 AND FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-ROW)) <= 8
                         AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= 8
                     MOVE WS-E TO WS-FOUND
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0 AND EN-FOX-ITEM(L-ROW) > 0
                 PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-FOUND > 0
                     IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = EN-FOX-ITEM(L-ROW) AND EN-ITEM-COUNT(WS-E) > 0
                         MOVE WS-E TO WS-FOUND
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
         IF WS-FOUND = 0
             MOVE 0 TO EN-FOX-ITEM(L-ROW)
         ELSE
             MOVE EN-ID(WS-FOUND) TO EN-FOX-ITEM(L-ROW)
             COMPUTE WS-DX = EN-X(WS-FOUND) - EN-X(L-ROW)
             COMPUTE WS-DZ = EN-Z(WS-FOUND) - EN-Z(L-ROW)
             IF FUNCTION ABS(WS-DX) <= 1 AND FUNCTION ABS(WS-DZ) <= 1 AND FUNCTION ABS(EN-Y(WS-FOUND) - EN-Y(L-ROW)) <= 1.5
                 *>   One item goes into the hand, the rest of the stack is dropped again; Take Item Entity for the viewers.
                 MOVE EN-ITEM(WS-FOUND) TO WS-ITEM
                 MOVE EN-ITEM-COUNT(WS-FOUND) TO WS-COUNT
                 MOVE EN-ID(WS-FOUND) TO WS-ID-ITEM
                 MOVE EN-ID(L-ROW) TO WS-ID-ME
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "TAKE-ITEM-ENTITY-BUILD" USING WS-ID-ITEM WS-ID-ME WS-TAKE PB-BUFFER
                 CALL "GI-VIEWERS-SEND" USING WS-FOUND PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
                 CALL "ENTITY-REMOVE" USING WS-FOUND
                 MOVE WS-ITEM TO EN-FOX-HELD(L-ROW)
                 MOVE 0 TO EN-FOX-ITEM(L-ROW)
                 SUBTRACT 1 FROM WS-COUNT
                 IF WS-COUNT > 0
                     CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET WS-ITEM WS-COUNT WS-PATCH WS-DROPPED
                 END-IF
             ELSE
                 MOVE 1 TO L-WALK
                 COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
                 IF WS-H > 0
                     COMPUTE L-HX = WS-DX / WS-H * 0.36
                     COMPUTE L-HZ = WS-DZ / WS-H * 0.36
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-ITEMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-IDLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "M44-FOX-FACEPLANT" USING L-ROW WS-STATE
     IF WS-STATE = 1
         MOVE 2 TO L-WALK
         GOBACK
     END-IF
     CALL "M44-FOX-SLEEP" USING L-ROW WS-STATE
     IF WS-STATE = 1
         MOVE 2 TO L-WALK
         GOBACK
     END-IF
     CALL "M44-FOX-BERRIES" USING L-ROW L-HX L-HZ L-WALK
     IF L-WALK = 0
         CALL "M44-FOX-ITEMS" USING L-ROW L-HX L-HZ L-WALK
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-IDLE.
