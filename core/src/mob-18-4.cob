*> The mob AI system (docs/protocol/18-mob-framework.md section 4), table driven: goal selector (4.1), goal catalogue (4.2),
*> target selection (4.3), controls (4.4), brain (4.5), sensors and behaviours (4.6, 4.7), NeutralMob (4.8), Monster (4.9),
*> conversion (4.10) and Bucketable (4.11). The programs are pure: world facts come in as arguments filled by the caller.

*> GOAL-SELECTOR-RESET USING GS-STATE (MOBGOALS.cpy): no goals, no locks, nothing disabled.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOAL-SELECTOR-RESET.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBGOALS.
 PROCEDURE DIVISION USING GS-STATE.
     INITIALIZE GS-STATE
     GOBACK.
 END PROGRAM GOAL-SELECTOR-RESET.

*> GOAL-ADD USING GS-STATE, priority (BINARY-LONG), spec (PIC X(6): the four flags MOVE LOOK JUMP TARGET as 0/1, then
*> interruptable, then requires-update-every-tick), index out (BINARY-LONG, 0 when the table is full).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOAL-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBGOALS.
 01 LK-PRIORITY            BINARY-LONG.
 01 LK-SPEC                PIC X(6).
 01 LK-INDEX               BINARY-LONG.
 PROCEDURE DIVISION USING GS-STATE LK-PRIORITY LK-SPEC LK-INDEX.
     MOVE 0 TO LK-INDEX
     IF GS-COUNT < 24
         ADD 1 TO GS-COUNT
         MOVE GS-COUNT TO LK-INDEX
         MOVE LK-PRIORITY TO GS-PRIORITY(LK-INDEX)
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 4
             MOVE LK-SPEC(WS-F:1) TO GS-FLAG(LK-INDEX, WS-F)
         END-PERFORM
         MOVE LK-SPEC(5:1) TO GS-INTERRUPTABLE(LK-INDEX)
         MOVE LK-SPEC(6:1) TO GS-EVERY-TICK(LK-INDEX)
         MOVE 0 TO GS-RUNNING(LK-INDEX)
     END-IF
     GOBACK.
 END PROGRAM GOAL-ADD.

*> ADJUSTED-TICK-DELAY USING n (BINARY-LONG), every-tick (PIC 9), result (BINARY-LONG): ceil(n / 2) unless the goal updates
*> every tick (section 4.1 tick-delay scaling).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ADJUSTED-TICK-DELAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-N                   BINARY-LONG.
 01 LK-EVERY               PIC 9.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-N LK-EVERY LK-RESULT.
     IF LK-EVERY = 1
         MOVE LK-N TO LK-RESULT
     ELSE
         COMPUTE LK-RESULT = (LK-N + 1) / 2
     END-IF
     GOBACK.
 END PROGRAM ADJUSTED-TICK-DELAY.

*> GOAL-SELECTOR-TICK USING GS-STATE, mode (BINARY-LONG: 1 full evaluation, 0 odd tick). Appends start, stop and tick actions to
*> GS-LOG (GS-LOG-COUNT is zeroed first). Order of a full evaluation: cleanup, lock release, update, tick of the running goals.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOAL-SELECTOR-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-STOP                PIC 9.
 01 WS-OK                  PIC 9.
 LINKAGE SECTION.
 COPY MOBGOALS.
 01 LK-MODE                BINARY-LONG.
 PROCEDURE DIVISION USING GS-STATE LK-MODE.
     MOVE 0 TO GS-LOG-COUNT
     IF LK-MODE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-COUNT
             IF GS-RUNNING(WS-I) = 1
                 MOVE 0 TO WS-STOP
                 IF GS-CAN-CONTINUE(WS-I) = 0
                     MOVE 1 TO WS-STOP
                 END-IF
                 PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 4
                     IF GS-FLAG(WS-I, WS-F) = 1 AND GS-DISABLED(WS-F) = 1
                         MOVE 1 TO WS-STOP
                     END-IF
                 END-PERFORM
                 IF WS-STOP = 1
                     MOVE 0 TO GS-RUNNING(WS-I)
                     ADD 1 TO GS-LOG-COUNT
                     MOVE 2 TO GS-LOG-ACTION(GS-LOG-COUNT)
                     MOVE WS-I TO GS-LOG-GOAL(GS-LOG-COUNT)
                 END-IF
             END-IF
         END-PERFORM
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 4
             IF GS-LOCK(WS-F) > 0
                 MOVE GS-LOCK(WS-F) TO WS-H
                 IF GS-RUNNING(WS-H) = 0
                     MOVE 0 TO GS-LOCK(WS-F)
                 END-IF
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-COUNT
             IF GS-RUNNING(WS-I) = 0
                 MOVE 1 TO WS-OK
                 PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 4
                     IF GS-FLAG(WS-I, WS-F) = 1
                         IF GS-DISABLED(WS-F) = 1
                             MOVE 0 TO WS-OK
                         END-IF
                         MOVE GS-LOCK(WS-F) TO WS-H
                         IF WS-H > 0
                             IF GS-INTERRUPTABLE(WS-H) = 0 OR GS-PRIORITY(WS-I) NOT < GS-PRIORITY(WS-H)
                                 MOVE 0 TO WS-OK
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
                 IF WS-OK = 1 AND GS-CAN-USE(WS-I) = 1
                     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 4
                         IF GS-FLAG(WS-I, WS-F) = 1
                             MOVE GS-LOCK(WS-F) TO WS-H
                             IF WS-H > 0 AND GS-RUNNING(WS-H) = 1
                                 MOVE 0 TO GS-RUNNING(WS-H)
                                 ADD 1 TO GS-LOG-COUNT
                                 MOVE 2 TO GS-LOG-ACTION(GS-LOG-COUNT)
                                 MOVE WS-H TO GS-LOG-GOAL(GS-LOG-COUNT)
                             END-IF
                             MOVE WS-I TO GS-LOCK(WS-F)
                         END-IF
                     END-PERFORM
                     MOVE 1 TO GS-RUNNING(WS-I)
                     ADD 1 TO GS-LOG-COUNT
                     MOVE 1 TO GS-LOG-ACTION(GS-LOG-COUNT)
                     MOVE WS-I TO GS-LOG-GOAL(GS-LOG-COUNT)
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-COUNT
         IF GS-RUNNING(WS-I) = 1 AND (LK-MODE = 1 OR GS-EVERY-TICK(WS-I) = 1)
             ADD 1 TO GS-LOG-COUNT
             MOVE 3 TO GS-LOG-ACTION(GS-LOG-COUNT)
             MOVE WS-I TO GS-LOG-GOAL(GS-LOG-COUNT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GOAL-SELECTOR-TICK.

*> ---- 4.2 Shared goal catalogue -------------------------------------------------------------------------------------------

*> GOAL-CATALOGUE USING name (PIC X(32)), spec out (PIC X(6), as GOAL-ADD takes it: MOVE LOOK JUMP TARGET flags, interruptable,
*> every tick), found out (BINARY-LONG 1/0). The flags of each goal class of section 4.2 and 44 x2 section 10.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOAL-CATALOGUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CATALOGUE.
       05 FILLER PIC X(38) VALUE "FloatGoal                       001011".
       05 FILLER PIC X(38) VALUE "PanicGoal                       100010".
       05 FILLER PIC X(38) VALUE "MeleeAttackGoal                 110011".
       05 FILLER PIC X(38) VALUE "ZombieAttackGoal                110011".
       05 FILLER PIC X(38) VALUE "RangedAttackGoal                110011".
       05 FILLER PIC X(38) VALUE "RangedBowAttackGoal             110011".
       05 FILLER PIC X(38) VALUE "RangedCrossbowAttackGoal        110011".
       05 FILLER PIC X(38) VALUE "RandomStrollGoal                100010".
       05 FILLER PIC X(38) VALUE "WaterAvoidingRandomStrollGoal   100010".
       05 FILLER PIC X(38) VALUE "LookAtPlayerGoal                010010".
       05 FILLER PIC X(38) VALUE "InteractGoal                    110010".
       05 FILLER PIC X(38) VALUE "RandomLookAroundGoal            110011".
       05 FILLER PIC X(38) VALUE "AvoidEntityGoal                 100010".
       05 FILLER PIC X(38) VALUE "BreedGoal                       110010".
       05 FILLER PIC X(38) VALUE "TemptGoal                       110010".
       05 FILLER PIC X(38) VALUE "FollowParentGoal                000010".
       05 FILLER PIC X(38) VALUE "FollowOwnerGoal                 110010".
       05 FILLER PIC X(38) VALUE "SitWhenOrderedToGoal            101010".
       05 FILLER PIC X(38) VALUE "BegGoal                         010010".
       05 FILLER PIC X(38) VALUE "FollowMobGoal                   110010".
       05 FILLER PIC X(38) VALUE "OpenDoorGoal                    000011".
       05 FILLER PIC X(38) VALUE "BreakDoorGoal                   000011".
       05 FILLER PIC X(38) VALUE "RestrictSunGoal                 000010".
       05 FILLER PIC X(38) VALUE "FleeSunGoal                     100010".
       05 FILLER PIC X(38) VALUE "EatBlockGoal                    111010".
       05 FILLER PIC X(38) VALUE "MoveToBlockGoal                 101011".
       05 FILLER PIC X(38) VALUE "MoveTowardsRestrictionGoal      100010".
       05 FILLER PIC X(38) VALUE "MoveTowardsTargetGoal           100010".
       05 FILLER PIC X(38) VALUE "LeapAtTargetGoal                101010".
       05 FILLER PIC X(38) VALUE "BreathAirGoal                   110000".
       05 FILLER PIC X(38) VALUE "ClimbOnTopOfPowderSnowGoal      001011".
       05 FILLER PIC X(38) VALUE "SwellGoal                       100011".
       05 FILLER PIC X(38) VALUE "OcelotAttackGoal                110011".
       05 FILLER PIC X(38) VALUE "TargetGoal                      000110".
       05 FILLER PIC X(38) VALUE "NearestAttackableTargetGoal     000110".
       05 FILLER PIC X(38) VALUE "HurtByTargetGoal                000110".
 01 WS-TABLE REDEFINES WS-CATALOGUE.
    05 WS-ENTRY OCCURS 36 TIMES.
       10 WS-ENTRY-NAME     PIC X(32).
       10 WS-ENTRY-SPEC     PIC X(6).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 LK-NAME                PIC X(32).
 01 LK-SPEC                PIC X(6).
 01 LK-FOUND               BINARY-LONG.
 PROCEDURE DIVISION USING LK-NAME LK-SPEC LK-FOUND.
     MOVE 0 TO LK-FOUND
     MOVE SPACES TO LK-SPEC
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36 OR LK-FOUND = 1
         IF WS-ENTRY-NAME(WS-I) = LK-NAME
             MOVE WS-ENTRY-SPEC(WS-I) TO LK-SPEC
             MOVE 1 TO LK-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GOAL-CATALOGUE.

*> MELEE-RECALC-DELAY USING roll (nextInt(7), BINARY-LONG), squared distance to the target (FLOAT-LONG), moveTo succeeded
*> (BINARY-LONG 1/0), delay out (BINARY-LONG). MeleeAttackGoal updates every tick, so adjustedTickDelay leaves it unchanged.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MELEE-RECALC-DELAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-ROLL                BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-MOVED               BINARY-LONG.
 01 LK-DELAY               BINARY-LONG.
 PROCEDURE DIVISION USING LK-ROLL LK-DIST LK-MOVED LK-DELAY.
     COMPUTE LK-DELAY = 4 + LK-ROLL
     EVALUATE TRUE
         WHEN LK-DIST > 1024
             ADD 10 TO LK-DELAY
         WHEN LK-DIST > 256
             ADD 5 TO LK-DELAY
     END-EVALUATE
     IF LK-MOVED = 0
         ADD 15 TO LK-DELAY
     END-IF
     GOBACK.
 END PROGRAM MELEE-RECALC-DELAY.

*> MELEE-RECALC-DUE USING timer (BINARY-LONG), can see (1/0), no stored target position (1/0), squared movement of the target from
*> the stored position (FLOAT-LONG), roll (nextFloat, FLOAT-LONG), due out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MELEE-RECALC-DUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TIMER               BINARY-LONG.
 01 LK-SEEN                BINARY-LONG.
 01 LK-NOSTORED            BINARY-LONG.
 01 LK-MOVED               FLOAT-LONG.
 01 LK-ROLL                FLOAT-LONG.
 01 LK-DUE                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-TIMER LK-SEEN LK-NOSTORED LK-MOVED LK-ROLL LK-DUE.
     MOVE 0 TO LK-DUE
     IF LK-TIMER = 0 AND LK-SEEN = 1
         IF LK-NOSTORED = 1 OR LK-MOVED NOT < 1.0 OR LK-ROLL < 0.05
             MOVE 1 TO LK-DUE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MELEE-RECALC-DUE.

*> MELEE-RANGE USING range out (FLOAT-LONG): sqrt(2.0399999618530273) - 0.6000000238418579.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MELEE-RANGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-RANGE               FLOAT-LONG.
 PROCEDURE DIVISION USING LK-RANGE.
     COMPUTE LK-RANGE = FUNCTION SQRT(2.0399999618530273) - 0.6000000238418579
     GOBACK.
 END PROGRAM MELEE-RANGE.

*> ZOMBIE-ARMS USING raiseArmTicks, ticksUntilNextAttack (BINARY-LONG), aggressive out (1/0): the interval is
*> adjustedTickDelay(20) = 20 for this every-tick goal, so the threshold is 10.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZOMBIE-ARMS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-RAISE               BINARY-LONG.
 01 LK-NEXT                BINARY-LONG.
 01 LK-AGGRESSIVE          BINARY-LONG.
 PROCEDURE DIVISION USING LK-RAISE LK-NEXT LK-AGGRESSIVE.
     MOVE 0 TO LK-AGGRESSIVE
     IF LK-RAISE NOT < 5 AND LK-NEXT < 10
         MOVE 1 TO LK-AGGRESSIVE
     END-IF
     GOBACK.
 END PROGRAM ZOMBIE-ARMS.

*> RANGED-ATTACK-SHOT USING distance, attack radius (FLOAT-LONG), min interval, max interval (BINARY-LONG), power out
*> (FLOAT-LONG), timer out (BINARY-LONG): power = clamp(d / r, 0.1, 1), timer = floor(d / r x (max - min) + min).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-ATTACK-SHOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RATIO               FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-DIST                FLOAT-LONG.
 01 LK-RADIUS              FLOAT-LONG.
 01 LK-MIN                 BINARY-LONG.
 01 LK-MAX                 BINARY-LONG.
 01 LK-POWER               FLOAT-LONG.
 01 LK-TIMER               BINARY-LONG.
 PROCEDURE DIVISION USING LK-DIST LK-RADIUS LK-MIN LK-MAX LK-POWER LK-TIMER.
     COMPUTE WS-RATIO = LK-DIST / LK-RADIUS
     COMPUTE LK-TIMER = FUNCTION INTEGER(WS-RATIO * (LK-MAX - LK-MIN) + LK-MIN)
     EVALUATE TRUE
         WHEN WS-RATIO < 0.1
             MOVE 0.1 TO LK-POWER
         WHEN WS-RATIO > 1.0
             MOVE 1.0 TO LK-POWER
         WHEN OTHER
             MOVE WS-RATIO TO LK-POWER
     END-EVALUATE
     GOBACK.
 END PROGRAM RANGED-ATTACK-SHOT.

*> STROLL-TRIGGER USING interval (BINARY-LONG), roll (nextInt(reducedTickDelay(interval)), BINARY-LONG), has controlling passenger
*> (1/0), noActionTime (BINARY-LONG), trigger out (1/0). The roll must be 0, the mob must have no controlling passenger and
*> noActionTime below 100.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. STROLL-TRIGGER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-INTERVAL            BINARY-LONG.
 01 LK-ROLL                BINARY-LONG.
 01 LK-PASSENGER           BINARY-LONG.
 01 LK-NOACTION            BINARY-LONG.
 01 LK-TRIGGER             BINARY-LONG.
 PROCEDURE DIVISION USING LK-INTERVAL LK-ROLL LK-PASSENGER LK-NOACTION LK-TRIGGER.
     MOVE 0 TO LK-TRIGGER
     IF LK-PASSENGER = 0 AND LK-NOACTION < 100 AND LK-ROLL = 0
         MOVE 1 TO LK-TRIGGER
     END-IF
     GOBACK.
 END PROGRAM STROLL-TRIGGER.

*> LEAP-CAN-USE USING controlling passenger (1/0), squared distance to the target (FLOAT-LONG), on ground (1/0), roll
*> (nextInt(reducedTickDelay(5)) = nextInt(3)), usable out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAP-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-PASSENGER           BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-GROUND              BINARY-LONG.
 01 LK-ROLL                BINARY-LONG.
 01 LK-USABLE              BINARY-LONG.
 PROCEDURE DIVISION USING LK-PASSENGER LK-DIST LK-GROUND LK-ROLL LK-USABLE.
     MOVE 0 TO LK-USABLE
     IF LK-PASSENGER = 0 AND LK-DIST > 4.0 AND LK-DIST < 16.0 AND LK-GROUND = 1 AND LK-ROLL = 0
         MOVE 1 TO LK-USABLE
     END-IF
     GOBACK.
 END PROGRAM LEAP-CAN-USE.

*> SWELL-DIRECTION USING has target, target dead (1/0), squared distance (FLOAT-LONG), line of sight (1/0), direction out
*> (-1 or +1): +1 only with a live visible target within 7 blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SWELL-DIRECTION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-HAS                 BINARY-LONG.
 01 LK-DEAD                BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-SIGHT               BINARY-LONG.
 01 LK-DIRECTION           BINARY-LONG.
 PROCEDURE DIVISION USING LK-HAS LK-DEAD LK-DIST LK-SIGHT LK-DIRECTION.
     MOVE -1 TO LK-DIRECTION
     IF LK-HAS = 1 AND LK-DEAD = 0 AND LK-DIST NOT > 49.0 AND LK-SIGHT = 1
         MOVE 1 TO LK-DIRECTION
     END-IF
     GOBACK.
 END PROGRAM SWELL-DIRECTION.

*> SWELL-CAN-USE USING swell direction (BINARY-LONG), has target (1/0), squared distance (FLOAT-LONG), usable out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SWELL-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DIRECTION           BINARY-LONG.
 01 LK-HAS                 BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-USABLE              BINARY-LONG.
 PROCEDURE DIVISION USING LK-DIRECTION LK-HAS LK-DIST LK-USABLE.
     MOVE 0 TO LK-USABLE
     IF LK-DIRECTION > 0 OR (LK-HAS = 1 AND LK-DIST < 9.0)
         MOVE 1 TO LK-USABLE
     END-IF
     GOBACK.
 END PROGRAM SWELL-CAN-USE.

*> OCELOT-SPEED USING squared distance, bbWidth (FLOAT-LONG), speed out (FLOAT-LONG): 1.33 when the squared distance is above
*> (2 x width)^2 and below 16, else 0.6 below 225, else 0.8.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. OCELOT-SPEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REACH               FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-DIST                FLOAT-LONG.
 01 LK-WIDTH               FLOAT-LONG.
 01 LK-SPEED               FLOAT-LONG.
 PROCEDURE DIVISION USING LK-DIST LK-WIDTH LK-SPEED.
     COMPUTE WS-REACH = (2.0 * LK-WIDTH) * (2.0 * LK-WIDTH)
     EVALUATE TRUE
         WHEN LK-DIST > WS-REACH AND LK-DIST < 16.0
             MOVE 1.33 TO LK-SPEED
         WHEN LK-DIST < 225.0
             MOVE 0.6 TO LK-SPEED
         WHEN OTHER
             MOVE 0.8 TO LK-SPEED
     END-EVALUATE
     GOBACK.
 END PROGRAM OCELOT-SPEED.

*> SIT-CAN-USE USING ordered to sit, tame, in water, on ground, owner present in this level (all 1/0), squared distance to the
*> owner (FLOAT-LONG), owner has a last-hurt-by mob (1/0), usable out (1/0): the six checks of 44 x2 section 10.1 in order.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIT-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-ORDERED             BINARY-LONG.
 01 LK-TAME                BINARY-LONG.
 01 LK-WATER               BINARY-LONG.
 01 LK-GROUND              BINARY-LONG.
 01 LK-OWNER               BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-HURT                BINARY-LONG.
 01 LK-USABLE              BINARY-LONG.
 PROCEDURE DIVISION USING LK-ORDERED LK-TAME LK-WATER LK-GROUND LK-OWNER LK-DIST LK-HURT LK-USABLE.
     EVALUATE TRUE
         WHEN LK-ORDERED = 0 AND LK-TAME = 0
             MOVE 0 TO LK-USABLE
         WHEN LK-WATER = 1
             MOVE 0 TO LK-USABLE
         WHEN LK-GROUND = 0
             MOVE 0 TO LK-USABLE
         WHEN LK-OWNER = 0
             MOVE 1 TO LK-USABLE
         WHEN LK-DIST < 144.0 AND LK-HURT = 1
             MOVE 0 TO LK-USABLE
         WHEN OTHER
             MOVE LK-ORDERED TO LK-USABLE
     END-EVALUATE
     GOBACK.
 END PROGRAM SIT-CAN-USE.

*> BREED-SPAWN-DUE USING counter (BINARY-LONG), squared distance to the partner (FLOAT-LONG), due out (1/0): the counter has
*> reached adjustedTickDelay(60) = 30 and the partner is within 3 blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREED-SPAWN-DUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-COUNTER             BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-DUE                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-COUNTER LK-DIST LK-DUE.
     MOVE 0 TO LK-DUE
     IF LK-COUNTER NOT < 30 AND LK-DIST < 9.0
         MOVE 1 TO LK-DUE
     END-IF
     GOBACK.
 END PROGRAM BREED-SPAWN-DUE.

*> FOLLOW-PARENT-CAN-USE USING age (BINARY-LONG), squared distance to the closest adult (FLOAT-LONG), usable out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOLLOW-PARENT-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-AGE                 BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-USABLE              BINARY-LONG.
 PROCEDURE DIVISION USING LK-AGE LK-DIST LK-USABLE.
     MOVE 0 TO LK-USABLE
     IF LK-AGE < 0 AND LK-DIST NOT < 9.0
         MOVE 1 TO LK-USABLE
     END-IF
     GOBACK.
 END PROGRAM FOLLOW-PARENT-CAN-USE.

*> FOLLOW-PARENT-KEEP USING squared distance to the parent (FLOAT-LONG), keep out (1/0): between 3 and 16 blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOLLOW-PARENT-KEEP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DIST                FLOAT-LONG.
 01 LK-KEEP                BINARY-LONG.
 PROCEDURE DIVISION USING LK-DIST LK-KEEP.
     MOVE 0 TO LK-KEEP
     IF LK-DIST NOT < 9.0 AND LK-DIST NOT > 256.0
         MOVE 1 TO LK-KEEP
     END-IF
     GOBACK.
 END PROGRAM FOLLOW-PARENT-KEEP.

*> TEMPT-SCARED USING squared distance to the player, squared movement since the last check, rotation change in degrees
*> (FLOAT-LONG), scared out (1/0): within 6 blocks and moved more than 0.1 blocks or turned more than 5 degrees.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEMPT-SCARED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DIST                FLOAT-LONG.
 01 LK-MOVED               FLOAT-LONG.
 01 LK-ROTATION            FLOAT-LONG.
 01 LK-SCARED              BINARY-LONG.
 PROCEDURE DIVISION USING LK-DIST LK-MOVED LK-ROTATION LK-SCARED.
     MOVE 0 TO LK-SCARED
     IF LK-DIST < 36.0 AND (LK-MOVED > 0.01 OR LK-ROTATION > 5.0)
         MOVE 1 TO LK-SCARED
     END-IF
     GOBACK.
 END PROGRAM TEMPT-SCARED.

*> SEQUENCE-NEXT USING v, next out (BINARY-LONG): the search sequence 0, 1, -1, 2, -2, ...: 1 - v when v <= 0, else -v.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SEQUENCE-NEXT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-V                   BINARY-LONG.
 01 LK-NEXT                BINARY-LONG.
 PROCEDURE DIVISION USING LK-V LK-NEXT.
     IF LK-V NOT > 0
         COMPUTE LK-NEXT = 1 - LK-V
     ELSE
         COMPUTE LK-NEXT = 0 - LK-V
     END-IF
     GOBACK.
 END PROGRAM SEQUENCE-NEXT.

*> RANDOM-DIRECTION USING h, v, draws rx = nextInt(2h+1), ry = nextInt(2v+1), rz = nextInt(2h+1), then x, y, z out (BINARY-LONG).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANDOM-DIRECTION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-H                   BINARY-LONG.
 01 LK-V                   BINARY-LONG.
 01 LK-RX                  BINARY-LONG.
 01 LK-RY                  BINARY-LONG.
 01 LK-RZ                  BINARY-LONG.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 PROCEDURE DIVISION USING LK-H LK-V LK-RX LK-RY LK-RZ LK-X LK-Y LK-Z.
     COMPUTE LK-X = LK-RX - LK-H
     COMPUTE LK-Y = LK-RY - LK-V
     COMPUTE LK-Z = LK-RZ - LK-H
     GOBACK.
 END PROGRAM RANDOM-DIRECTION.

*> MOB-RESTRICTED USING has home (1/0), squared distance to the home centre (FLOAT-LONG), home radius, hRange (BINARY-LONG),
*> restricted out (1/0): true when the mob has a home and is not closer than radius + hRange + 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RESTRICTED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-HOME                BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-RADIUS              BINARY-LONG.
 01 LK-RANGE               BINARY-LONG.
 01 LK-RESTRICTED          BINARY-LONG.
 PROCEDURE DIVISION USING LK-HOME LK-DIST LK-RADIUS LK-RANGE LK-RESTRICTED.
     MOVE 0 TO LK-RESTRICTED
     COMPUTE WS-LIMIT = (LK-RADIUS + LK-RANGE + 1) * (LK-RADIUS + LK-RANGE + 1)
     IF LK-HOME = 1 AND LK-DIST NOT < WS-LIMIT
         MOVE 1 TO LK-RESTRICTED
     END-IF
     GOBACK.
 END PROGRAM MOB-RESTRICTED.

*> DOOR-PASSED USING dx, dz (offset to the door centre now), start dx, dz (offset when the goal started) (FLOAT-LONG), passed out
*> (1/0): the dot product of the two offsets is negative once the mob crossed the door plane (44 x2 section 10.4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOOR-PASSED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DX                  FLOAT-LONG.
 01 LK-DZ                  FLOAT-LONG.
 01 LK-SX                  FLOAT-LONG.
 01 LK-SZ                  FLOAT-LONG.
 01 LK-PASSED              BINARY-LONG.
 PROCEDURE DIVISION USING LK-DX LK-DZ LK-SX LK-SZ LK-PASSED.
     MOVE 0 TO LK-PASSED
     IF LK-DX * LK-SX + LK-DZ * LK-SZ < 0
         MOVE 1 TO LK-PASSED
     END-IF
     GOBACK.
 END PROGRAM DOOR-PASSED.

*> ---- 4.3 Target selection ------------------------------------------------------------------------------------------------

*> TARGETING-TEST USING TC-RECORD (MOBTARGET.cpy), result out (BINARY-LONG 1/0): the seven rules of TargetingConditions.test in order.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TARGETING-TEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EFFECTIVE           FLOAT-LONG.
 LINKAGE SECTION.
 COPY MOBTARGET.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING TC-RECORD LK-RESULT.
     MOVE 1 TO LK-RESULT
     EVALUATE TRUE
         WHEN TC-SAME = 1
             MOVE 0 TO LK-RESULT
         WHEN TC-VISIBLE-ANYONE = 0
             MOVE 0 TO LK-RESULT
         WHEN TC-HAS-SELECTOR = 1 AND TC-SELECTOR-OK = 0
             MOVE 0 TO LK-RESULT
         WHEN TC-HAS-ATTACKER = 0
             IF TC-COMBAT = 1 AND (TC-INVULNERABLE = 1 OR TC-PEACEFUL = 1)
                 MOVE 0 TO LK-RESULT
             END-IF
         WHEN TC-COMBAT = 1 AND (TC-CAN-ATTACK = 0 OR TC-ALLIED = 1)
             MOVE 0 TO LK-RESULT
         WHEN OTHER
             IF TC-RANGE > 0
                 COMPUTE WS-EFFECTIVE = TC-RANGE * TC-VISIBILITY
                 IF WS-EFFECTIVE < 2.0
                     MOVE 2.0 TO WS-EFFECTIVE
                 END-IF
                 IF TC-DIST-SQ > WS-EFFECTIVE * WS-EFFECTIVE
                     MOVE 0 TO LK-RESULT
                 END-IF
             END-IF
             IF TC-IGNORE-LOS = 0 AND TC-ATTACKER-IS-MOB = 1 AND TC-LINE-OF-SIGHT = 0
                 MOVE 0 TO LK-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM TARGETING-TEST.

*> VISIBILITY-PERCENT USING crouching (1/0), invisible (1/0), armor cover percentage (FLOAT-LONG 0..1), product of the matching
*> mob_visibility item factors (FLOAT-LONG), result out (FLOAT-LONG clamped to 0..10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. VISIBILITY-PERCENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COVER               FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-CROUCH              BINARY-LONG.
 01 LK-INVISIBLE           BINARY-LONG.
 01 LK-COVER               FLOAT-LONG.
 01 LK-ITEMS               FLOAT-LONG.
 01 LK-RESULT              FLOAT-LONG.
 PROCEDURE DIVISION USING LK-CROUCH LK-INVISIBLE LK-COVER LK-ITEMS LK-RESULT.
     MOVE 1.0 TO LK-RESULT
     IF LK-CROUCH = 1
         COMPUTE LK-RESULT = LK-RESULT * 0.8
     END-IF
     IF LK-INVISIBLE = 1
         MOVE LK-COVER TO WS-COVER
         IF WS-COVER < 0.1
             MOVE 0.1 TO WS-COVER
         END-IF
         COMPUTE LK-RESULT = LK-RESULT * WS-COVER * 0.7
     END-IF
     COMPUTE LK-RESULT = LK-RESULT * LK-ITEMS
     EVALUATE TRUE
         WHEN LK-RESULT < 0
             MOVE 0 TO LK-RESULT
         WHEN LK-RESULT > 10
             MOVE 10 TO LK-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM VISIBILITY-PERCENT.

*> MOB-CAN-ATTACK USING target is a ghast, target is a player, difficulty is Peaceful, target invulnerable, target spectator,
*> target alive (all 1/0), result out (1/0): Mob.canAttack of section 4.3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-CAN-ATTACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-GHAST               BINARY-LONG.
 01 LK-PLAYER              BINARY-LONG.
 01 LK-PEACEFUL            BINARY-LONG.
 01 LK-INVULNERABLE        BINARY-LONG.
 01 LK-SPECTATOR           BINARY-LONG.
 01 LK-ALIVE               BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-GHAST LK-PLAYER LK-PEACEFUL LK-INVULNERABLE LK-SPECTATOR LK-ALIVE LK-RESULT.
     MOVE 1 TO LK-RESULT
     EVALUATE TRUE
         WHEN LK-GHAST = 1
             MOVE 0 TO LK-RESULT
         WHEN LK-PLAYER = 1 AND LK-PEACEFUL = 1
             MOVE 0 TO LK-RESULT
         WHEN LK-INVULNERABLE = 1 OR LK-SPECTATOR = 1 OR LK-ALIVE = 0
             MOVE 0 TO LK-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-CAN-ATTACK.

*> TARGET-CONTINUE USING has target, can attack, same team (1/0), squared distance, follow distance (FLOAT-LONG), must see,
*> line of sight (1/0), unseen ticks (BINARY-LONG, in and out), unseen memory ticks (BINARY-LONG), result out (1/0): the
*> canContinueToUse of TargetGoal. With mustSee the unseen count rises while the target is not visible and resets when it is.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TARGET-CONTINUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-HAS                 BINARY-LONG.
 01 LK-CANATTACK           BINARY-LONG.
 01 LK-TEAM                BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-FOLLOW              FLOAT-LONG.
 01 LK-MUSTSEE             BINARY-LONG.
 01 LK-SIGHT               BINARY-LONG.
 01 LK-UNSEEN              BINARY-LONG.
 01 LK-MEMORY              BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-HAS LK-CANATTACK LK-TEAM LK-DIST LK-FOLLOW LK-MUSTSEE LK-SIGHT LK-UNSEEN LK-MEMORY LK-RESULT.
     MOVE 1 TO LK-RESULT
     EVALUATE TRUE
         WHEN LK-HAS = 0 OR LK-CANATTACK = 0 OR LK-TEAM = 1
             MOVE 0 TO LK-RESULT
         WHEN LK-DIST > LK-FOLLOW * LK-FOLLOW
             MOVE 0 TO LK-RESULT
         WHEN LK-MUSTSEE = 1 AND LK-SIGHT = 0
             ADD 1 TO LK-UNSEEN
             IF LK-UNSEEN > LK-MEMORY
                 MOVE 0 TO LK-RESULT
             END-IF
         WHEN LK-MUSTSEE = 1
             MOVE 0 TO LK-UNSEEN
     END-EVALUATE
     GOBACK.
 END PROGRAM TARGET-CONTINUE.

*> TARGET-REACH-CHECK USING timer, failures (BINARY-LONG, in and out), roll (nextInt(5)), squared distance of the path end node
*> from the target (FLOAT-LONG), result out (1/0): every 10 + roll ticks the path end is checked against 1.5 blocks; two
*> consecutive failures disqualify the target.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TARGET-REACH-CHECK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TIMER               BINARY-LONG.
 01 LK-FAILURES            BINARY-LONG.
 01 LK-ROLL                BINARY-LONG.
 01 LK-END                 FLOAT-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-TIMER LK-FAILURES LK-ROLL LK-END LK-RESULT.
     SUBTRACT 1 FROM LK-TIMER
     IF LK-TIMER NOT > 0
         COMPUTE LK-TIMER = 10 + LK-ROLL
         IF LK-END NOT > 2.25
             MOVE 0 TO LK-FAILURES
         ELSE
             ADD 1 TO LK-FAILURES
         END-IF
     END-IF
     IF LK-FAILURES < 2
         MOVE 1 TO LK-RESULT
     ELSE
         MOVE 0 TO LK-RESULT
     END-IF
     GOBACK.
 END PROGRAM TARGET-REACH-CHECK.

*> NEAREST-TARGET-CAN-USE USING random interval, roll (nextInt(interval)) (BINARY-LONG), runs out (1/0): the pre-check of
*> NearestAttackableTargetGoal.canUse (the search itself is the caller's).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NEAREST-TARGET-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-INTERVAL            BINARY-LONG.
 01 LK-ROLL                BINARY-LONG.
 01 LK-RUNS                BINARY-LONG.
 PROCEDURE DIVISION USING LK-INTERVAL LK-ROLL LK-RUNS.
     MOVE 1 TO LK-RUNS
     IF LK-INTERVAL > 0 AND LK-ROLL NOT = 0
         MOVE 0 TO LK-RUNS
     END-IF
     GOBACK.
 END PROGRAM NEAREST-TARGET-CAN-USE.

*> HURT-BY-CAN-USE USING has attacker, new hit (timestamp differs), attacker is a player, universal_anger on, attacker class
*> ignored, passes HURT_BY_TARGETING conditions (all 1/0), result out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. HURT-BY-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-HAS                 BINARY-LONG.
 01 LK-NEW                 BINARY-LONG.
 01 LK-PLAYER              BINARY-LONG.
 01 LK-UNIVERSAL           BINARY-LONG.
 01 LK-IGNORED             BINARY-LONG.
 01 LK-CONDITIONS          BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-HAS LK-NEW LK-PLAYER LK-UNIVERSAL LK-IGNORED LK-CONDITIONS LK-RESULT.
     MOVE 0 TO LK-RESULT
     IF LK-HAS = 1 AND LK-NEW = 1 AND LK-IGNORED = 0 AND LK-CONDITIONS = 1
        AND NOT (LK-PLAYER = 1 AND LK-UNIVERSAL = 1)
         MOVE 1 TO LK-RESULT
     END-IF
     GOBACK.
 END PROGRAM HURT-BY-CAN-USE.

*> HURT-BY-ALERT USING same class as the alerting mob, has a target, tamable with a different owner, allied to the attacker,
*> exact class excluded by setAlertOthers (all 1/0), alert out (1/0): whether a nearby mob gets the attacker as target.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. HURT-BY-ALERT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-SAME                BINARY-LONG.
 01 LK-TARGET              BINARY-LONG.
 01 LK-OWNER               BINARY-LONG.
 01 LK-ALLIED              BINARY-LONG.
 01 LK-EXCLUDED            BINARY-LONG.
 01 LK-ALERT               BINARY-LONG.
 PROCEDURE DIVISION USING LK-SAME LK-TARGET LK-OWNER LK-ALLIED LK-EXCLUDED LK-ALERT.
     MOVE 0 TO LK-ALERT
     IF LK-SAME = 1 AND LK-TARGET = 0 AND LK-OWNER = 0 AND LK-ALLIED = 0 AND LK-EXCLUDED = 0
         MOVE 1 TO LK-ALERT
     END-IF
     GOBACK.
 END PROGRAM HURT-BY-ALERT.

*> OWNER-HURT-BY-CAN-USE USING tame, ordered to sit, owner present, age in ticks of the owner's last damage source (-1 none),
*> source in NO_WOLF_RETALIATION, hurt-by timestamp differs, canAttack, wantsToAttack (1/0), result out (1/0) (44 x2 10.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. OWNER-HURT-BY-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TAME                BINARY-LONG.
 01 LK-SIT                 BINARY-LONG.
 01 LK-OWNER               BINARY-LONG.
 01 LK-AGE                 BINARY-LONG.
 01 LK-TAGGED              BINARY-LONG.
 01 LK-NEW                 BINARY-LONG.
 01 LK-CANATTACK           BINARY-LONG.
 01 LK-WANTS               BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-TAME LK-SIT LK-OWNER LK-AGE LK-TAGGED LK-NEW LK-CANATTACK LK-WANTS LK-RESULT.
     MOVE 0 TO LK-RESULT
     IF LK-TAME = 1 AND LK-SIT = 0 AND LK-OWNER = 1 AND LK-AGE NOT < 0 AND LK-AGE NOT > 100
        AND LK-TAGGED = 0 AND LK-NEW = 1 AND LK-CANATTACK = 1 AND LK-WANTS = 1
         MOVE 1 TO LK-RESULT
     END-IF
     GOBACK.
 END PROGRAM OWNER-HURT-BY-CAN-USE.

*> OWNER-HURT-TARGET-CAN-USE USING tame, ordered to sit, owner present, last-hurt-mob timestamp differs, canAttack,
*> wantsToAttack (1/0), result out (1/0): no damage source check (44 x2 10.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. OWNER-HURT-TARGET-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TAME                BINARY-LONG.
 01 LK-SIT                 BINARY-LONG.
 01 LK-OWNER               BINARY-LONG.
 01 LK-NEW                 BINARY-LONG.
 01 LK-CANATTACK           BINARY-LONG.
 01 LK-WANTS               BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-TAME LK-SIT LK-OWNER LK-NEW LK-CANATTACK LK-WANTS LK-RESULT.
     MOVE 0 TO LK-RESULT
     IF LK-TAME = 1 AND LK-SIT = 0 AND LK-OWNER = 1 AND LK-NEW = 1 AND LK-CANATTACK = 1 AND LK-WANTS = 1
         MOVE 1 TO LK-RESULT
     END-IF
     GOBACK.
 END PROGRAM OWNER-HURT-TARGET-CAN-USE.

*> NONTAME-TARGET-CAN-USE USING tame (1/0), base canUse (1/0), result out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NONTAME-TARGET-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TAME                BINARY-LONG.
 01 LK-BASE                BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-TAME LK-BASE LK-RESULT.
     MOVE 0 TO LK-RESULT
     IF LK-TAME = 0 AND LK-BASE = 1
         MOVE 1 TO LK-RESULT
     END-IF
     GOBACK.
 END PROGRAM NONTAME-TARGET-CAN-USE.

*> ---- 4.4 Controls --------------------------------------------------------------------------------------------------------

*> WRAP-DEGREES USING angle, result out (FLOAT-LONG): Mth.wrapDegrees, the angle brought into [-180, 180).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WRAP-DEGREES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-ANGLE               FLOAT-LONG.
 01 LK-RESULT              FLOAT-LONG.
 PROCEDURE DIVISION USING LK-ANGLE LK-RESULT.
     COMPUTE LK-RESULT = FUNCTION REM(LK-ANGLE, 360)
     EVALUATE TRUE
         WHEN LK-RESULT NOT < 180
             SUBTRACT 360 FROM LK-RESULT
         WHEN LK-RESULT < -180
             ADD 360 TO LK-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM WRAP-DEGREES.

*> ROTLERP USING from, to, max (FLOAT-LONG), result out (FLOAT-LONG): the wrapped difference limited to [-max, max], added to
*> from and normalised into 0..360 (section 4.4 rotlerp).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ROTLERP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-WRAPPED             FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-FROM                FLOAT-LONG.
 01 LK-TO                  FLOAT-LONG.
 01 LK-MAX                 FLOAT-LONG.
 01 LK-RESULT              FLOAT-LONG.
 PROCEDURE DIVISION USING LK-FROM LK-TO LK-MAX LK-RESULT.
     COMPUTE WS-DIFF = LK-TO - LK-FROM
     CALL "WRAP-DEGREES" USING WS-DIFF WS-WRAPPED
     EVALUATE TRUE
         WHEN WS-WRAPPED > LK-MAX
             MOVE LK-MAX TO WS-WRAPPED
         WHEN WS-WRAPPED < 0 - LK-MAX
             COMPUTE WS-WRAPPED = 0 - LK-MAX
     END-EVALUATE
     COMPUTE LK-RESULT = LK-FROM + WS-WRAPPED
     EVALUATE TRUE
         WHEN LK-RESULT < 0
             ADD 360 TO LK-RESULT
         WHEN LK-RESULT NOT < 360
             SUBTRACT 360 FROM LK-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM ROTLERP.

*> ROTATE-TOWARDS USING from, to, max (FLOAT-LONG), result out (FLOAT-LONG): from + the wrapped difference limited to
*> [-max, max], without normalising (LookControl.rotateTowards).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ROTATE-TOWARDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-WRAPPED             FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-FROM                FLOAT-LONG.
 01 LK-TO                  FLOAT-LONG.
 01 LK-MAX                 FLOAT-LONG.
 01 LK-RESULT              FLOAT-LONG.
 PROCEDURE DIVISION USING LK-FROM LK-TO LK-MAX LK-RESULT.
     COMPUTE WS-DIFF = LK-TO - LK-FROM
     CALL "WRAP-DEGREES" USING WS-DIFF WS-WRAPPED
     EVALUATE TRUE
         WHEN WS-WRAPPED > LK-MAX
             MOVE LK-MAX TO WS-WRAPPED
         WHEN WS-WRAPPED < 0 - LK-MAX
             COMPUTE WS-WRAPPED = 0 - LK-MAX
     END-EVALUATE
     COMPUTE LK-RESULT = LK-FROM + WS-WRAPPED
     GOBACK.
 END PROGRAM ROTATE-TOWARDS.

*> ATAN2-DEGREES USING y, x (FLOAT-LONG), result out (FLOAT-LONG): atan2(y, x) in degrees, 0 for (0, 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ATAN2-DEGREES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-Y                   FLOAT-LONG.
 01 LK-X                   FLOAT-LONG.
 01 LK-RESULT              FLOAT-LONG.
 PROCEDURE DIVISION USING LK-Y LK-X LK-RESULT.
     EVALUATE TRUE
         WHEN LK-X > 0
             COMPUTE LK-RESULT = FUNCTION ATAN(LK-Y / LK-X) * 180 / FUNCTION PI
         WHEN LK-X < 0 AND LK-Y NOT < 0
             COMPUTE LK-RESULT = FUNCTION ATAN(LK-Y / LK-X) * 180 / FUNCTION PI + 180
         WHEN LK-X < 0
             COMPUTE LK-RESULT = FUNCTION ATAN(LK-Y / LK-X) * 180 / FUNCTION PI - 180
         WHEN LK-Y > 0
             MOVE 90 TO LK-RESULT
         WHEN LK-Y < 0
             MOVE -90 TO LK-RESULT
         WHEN OTHER
             MOVE 0 TO LK-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM ATAN2-DEGREES.

*> MOVE-CONTROL-WANT USING MC-RECORD (MOBCTL.cpy): setWantedPosition, MOVE_TO unless the control is JUMPING.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-CONTROL-WANT.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBCTL.
 PROCEDURE DIVISION USING MC-RECORD.
     IF MC-OPERATION NOT = 4
         MOVE 2 TO MC-OPERATION
     END-IF
     GOBACK.
 END PROGRAM MOVE-CONTROL-WANT.

*> MOVE-CONTROL-STRAFE USING MC-RECORD: strafe(forward, right) sets STRAFE with speedModifier 0.25.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-CONTROL-STRAFE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBCTL.
 PROCEDURE DIVISION USING MC-RECORD.
     MOVE 3 TO MC-OPERATION
     MOVE 0.25 TO MC-SPEED-MOD
     GOBACK.
 END PROGRAM MOVE-CONTROL-STRAFE.

*> MOVE-CONTROL-TICK USING MC-RECORD: MoveControl.tick of a ground mob (STRAFE, MOVE_TO, JUMPING, WAIT).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-CONTROL-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIST                FLOAT-LONG.
 01 WS-HORIZONTAL          FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-ATAN                FLOAT-LONG.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-TURN                FLOAT-LONG VALUE 90.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-YDX                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY MOBCTL.
 PROCEDURE DIVISION USING MC-RECORD.
     EVALUATE MC-OPERATION
         WHEN 3
             COMPUTE MC-OUT-SPEED = MC-MOVEMENT-SPEED * MC-SPEED-MOD
             IF MC-WALKABLE = 0
                 MOVE 1 TO MC-OUT-ZZA
                 MOVE 0 TO MC-OUT-XXA
             ELSE
                 MOVE MC-FORWARD TO MC-OUT-ZZA
                 MOVE MC-RIGHT TO MC-OUT-XXA
             END-IF
             MOVE 1 TO MC-OPERATION
         WHEN 2
             MOVE 1 TO MC-OPERATION
             MOVE 0 TO MC-OUT-JUMP
             COMPUTE WS-HORIZONTAL = MC-DX * MC-DX + MC-DZ * MC-DZ
             COMPUTE WS-DIST = WS-HORIZONTAL + MC-DY * MC-DY
             IF WS-DIST < 2.5000002779052011E-7
                 MOVE 0 TO MC-OUT-ZZA
             ELSE
                 CALL "ATAN2-DEGREES" USING MC-DZ MC-DX WS-ATAN
                 COMPUTE WS-TARGET = WS-ATAN - 90
                 CALL "ROTLERP" USING MC-YAW WS-TARGET WS-TURN WS-YAW
                 MOVE WS-YAW TO MC-YAW
                 COMPUTE MC-OUT-SPEED = MC-SPEED-MOD * MC-MOVEMENT-SPEED
                 MOVE 1.0 TO WS-LIMIT
                 IF MC-BB-WIDTH > WS-LIMIT
                     MOVE MC-BB-WIDTH TO WS-LIMIT
                 END-IF
                 IF (MC-DY > MC-STEP-HEIGHT AND WS-HORIZONTAL < WS-LIMIT) OR MC-BLOCKING = 1
                     MOVE 1 TO MC-OUT-JUMP
                     MOVE 4 TO MC-OPERATION
                 END-IF
             END-IF
         WHEN 4
             COMPUTE MC-OUT-SPEED = MC-SPEED-MOD * MC-MOVEMENT-SPEED
             IF MC-ON-GROUND = 1 OR MC-IN-LIQUID = 1
                 MOVE 1 TO MC-OPERATION
             END-IF
         WHEN OTHER
             MOVE 0 TO MC-OUT-ZZA
     END-EVALUATE
     GOBACK.
 END PROGRAM MOVE-CONTROL-TICK.

*> FLYING-MOVE-TICK USING MC-RECORD: FlyingMoveControl.tick (MC-MAX-TURN is maxTurn, MC-HOVERS is hoversInPlace).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLYING-MOVE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIST                FLOAT-LONG.
 01 WS-HORIZONTAL          FLOAT-LONG.
 01 WS-ATAN                FLOAT-LONG.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-RESULT              FLOAT-LONG.
 01 WS-ABS-DY              FLOAT-LONG.
 LINKAGE SECTION.
 COPY MOBCTL.
 PROCEDURE DIVISION USING MC-RECORD.
     IF MC-OPERATION = 2
         MOVE 1 TO MC-OPERATION
         MOVE 1 TO MC-NO-GRAVITY
         COMPUTE WS-HORIZONTAL = MC-DX * MC-DX + MC-DZ * MC-DZ
         COMPUTE WS-DIST = WS-HORIZONTAL + MC-DY * MC-DY
         IF WS-DIST < 2.5E-7
             MOVE 0 TO MC-OUT-YYA
             MOVE 0 TO MC-OUT-ZZA
         ELSE
             CALL "ATAN2-DEGREES" USING MC-DZ MC-DX WS-ATAN
             COMPUTE WS-TARGET = WS-ATAN - 90
             CALL "ROTLERP" USING MC-YAW WS-TARGET MC-MAX-TURN WS-RESULT
             MOVE WS-RESULT TO MC-YAW
             IF MC-AIRBORNE = 1
                 COMPUTE MC-OUT-SPEED = MC-SPEED-MOD * MC-FLYING-SPEED
             ELSE
                 COMPUTE MC-OUT-SPEED = MC-SPEED-MOD * MC-MOVEMENT-SPEED
             END-IF
             COMPUTE WS-HORIZONTAL = FUNCTION SQRT(WS-HORIZONTAL)
             COMPUTE WS-ABS-DY = FUNCTION ABS(MC-DY)
             IF WS-ABS-DY > 1.0E-5 OR WS-HORIZONTAL > 1.0E-5
                 CALL "ATAN2-DEGREES" USING MC-DY WS-HORIZONTAL WS-ATAN
                 COMPUTE WS-ANGLE = 0 - WS-ATAN
                 CALL "ROTLERP" USING MC-PITCH WS-ANGLE MC-MAX-TURN WS-RESULT
                 MOVE WS-RESULT TO MC-PITCH
             END-IF
             IF MC-DY > 0
                 MOVE MC-OUT-SPEED TO MC-OUT-YYA
             ELSE
                 COMPUTE MC-OUT-YYA = 0 - MC-OUT-SPEED
             END-IF
         END-IF
     ELSE
         IF MC-HOVERS = 0
             MOVE 0 TO MC-NO-GRAVITY
         END-IF
         MOVE 0 TO MC-OUT-YYA
         MOVE 0 TO MC-OUT-ZZA
     END-IF
     GOBACK.
 END PROGRAM FLYING-MOVE-TICK.

*> LOOK-CONTROL-SET USING LC-RECORD: setLookAt arms the look cooldown (the caller stores the wanted offset in LC-DX/DY/DZ).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOK-CONTROL-SET.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBCTL.
 PROCEDURE DIVISION USING LC-RECORD.
     MOVE 2 TO LC-COOLDOWN
     GOBACK.
 END PROGRAM LOOK-CONTROL-SET.

*> LOOK-CONTROL-TICK USING LC-RECORD: LookControl.tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOK-CONTROL-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HORIZONTAL          FLOAT-LONG.
 01 WS-ATAN                FLOAT-LONG.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-RESULT              FLOAT-LONG.
 01 WS-ABS-DX              FLOAT-LONG.
 01 WS-ABS-DY              FLOAT-LONG.
 01 WS-ABS-DZ              FLOAT-LONG.
 01 WS-EASE                FLOAT-LONG VALUE 10.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-WRAPPED             FLOAT-LONG.
 01 WS-CLAMPED             FLOAT-LONG.
 01 WS-NEGATIVE-MAX        FLOAT-LONG.
 LINKAGE SECTION.
 COPY MOBCTL.
 PROCEDURE DIVISION USING LC-RECORD.
     MOVE 0 TO LC-X-ROT
     IF LC-COOLDOWN > 0
         SUBTRACT 1 FROM LC-COOLDOWN
         COMPUTE WS-ABS-DX = FUNCTION ABS(LC-DX)
         COMPUTE WS-ABS-DY = FUNCTION ABS(LC-DY)
         COMPUTE WS-ABS-DZ = FUNCTION ABS(LC-DZ)
         COMPUTE WS-HORIZONTAL = FUNCTION SQRT(LC-DX * LC-DX + LC-DZ * LC-DZ)
         IF WS-ABS-DX NOT < 1.0E-5 OR WS-ABS-DZ NOT < 1.0E-5
             CALL "ATAN2-DEGREES" USING LC-DZ LC-DX WS-ATAN
             COMPUTE WS-TARGET = WS-ATAN - 90
             CALL "ROTATE-TOWARDS" USING LC-Y-HEAD WS-TARGET LC-Y-MAX-SPEED WS-RESULT
             MOVE WS-RESULT TO LC-Y-HEAD
         END-IF
         IF WS-ABS-DY NOT < 1.0E-5 OR WS-HORIZONTAL NOT < 1.0E-5
             CALL "ATAN2-DEGREES" USING LC-DY WS-HORIZONTAL WS-ATAN
             COMPUTE WS-TARGET = 0 - WS-ATAN
             CALL "ROTATE-TOWARDS" USING LC-X-ROT WS-TARGET LC-X-MAX-ANGLE WS-RESULT
             MOVE WS-RESULT TO LC-X-ROT
         END-IF
     ELSE
         CALL "ROTATE-TOWARDS" USING LC-Y-HEAD LC-Y-BODY WS-EASE WS-RESULT
         MOVE WS-RESULT TO LC-Y-HEAD
     END-IF
     IF LC-NAV-DONE = 0
         COMPUTE WS-DIFF = LC-Y-HEAD - LC-Y-BODY
         CALL "WRAP-DEGREES" USING WS-DIFF WS-WRAPPED
         MOVE WS-WRAPPED TO WS-CLAMPED
         COMPUTE WS-NEGATIVE-MAX = 0 - LC-MAX-HEAD-Y
         EVALUATE TRUE
             WHEN WS-WRAPPED > LC-MAX-HEAD-Y
                 MOVE LC-MAX-HEAD-Y TO WS-CLAMPED
             WHEN WS-WRAPPED < WS-NEGATIVE-MAX
                 MOVE WS-NEGATIVE-MAX TO WS-CLAMPED
         END-EVALUATE
         COMPUTE LC-Y-HEAD = LC-Y-HEAD - WS-WRAPPED + WS-CLAMPED
     END-IF
     GOBACK.
 END PROGRAM LOOK-CONTROL-TICK.

*> JUMP-CONTROL USING action (BINARY-LONG: 1 jump() request, 2 tick), request flag (BINARY-LONG, in and out), jumping out
*> (BINARY-LONG): JumpControl.jump() sets the flag, tick hands it to the mob for one tick and clears it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. JUMP-CONTROL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-ACTION              BINARY-LONG.
 01 LK-FLAG                BINARY-LONG.
 01 LK-JUMPING             BINARY-LONG.
 PROCEDURE DIVISION USING LK-ACTION LK-FLAG LK-JUMPING.
     IF LK-ACTION = 1
         MOVE 1 TO LK-FLAG
     ELSE
         MOVE LK-FLAG TO LK-JUMPING
         MOVE 0 TO LK-FLAG
     END-IF
     GOBACK.
 END PROGRAM JUMP-CONTROL.

*> BODY-ROTATION-MOVING USING entity yaw, head yaw, max head yaw (FLOAT-LONG), body yaw out, head yaw out (FLOAT-LONG): the
*> branch of BodyRotationControl for a mob that moves: the body follows the yaw, the head stays within the limit of the body.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BODY-ROTATION-MOVING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-WRAPPED             FLOAT-LONG.
 01 WS-NEGATIVE-MAX        FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-YAW                 FLOAT-LONG.
 01 LK-HEAD                FLOAT-LONG.
 01 LK-MAX                 FLOAT-LONG.
 01 LK-BODY-OUT            FLOAT-LONG.
 01 LK-HEAD-OUT            FLOAT-LONG.
 PROCEDURE DIVISION USING LK-YAW LK-HEAD LK-MAX LK-BODY-OUT LK-HEAD-OUT.
     MOVE LK-YAW TO LK-BODY-OUT
     COMPUTE WS-DIFF = LK-HEAD - LK-BODY-OUT
     CALL "WRAP-DEGREES" USING WS-DIFF WS-WRAPPED
     COMPUTE WS-NEGATIVE-MAX = 0 - LK-MAX
     EVALUATE TRUE
         WHEN WS-WRAPPED > LK-MAX
             COMPUTE LK-HEAD-OUT = LK-BODY-OUT + LK-MAX
         WHEN WS-WRAPPED < WS-NEGATIVE-MAX
             COMPUTE LK-HEAD-OUT = LK-BODY-OUT - LK-MAX
         WHEN OTHER
             MOVE LK-HEAD TO LK-HEAD-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM BODY-ROTATION-MOVING.

*> SWIM-MOVE-TICK USING SW-RECORD: SmoothSwimmingMoveControl.tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SWIM-MOVE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HORIZONTAL          FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-ATAN                FLOAT-LONG.
 01 WS-TARGET-YAW          FLOAT-LONG.
 01 WS-TARGET-PITCH        FLOAT-LONG.
 01 WS-RESULT              FLOAT-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-ABS-DY              FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-WRAPPED             FLOAT-LONG.
 01 WS-NEGATIVE-MAX        FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-FACTOR              FLOAT-LONG.
 01 WS-PITCH-STEP          FLOAT-LONG VALUE 5.
 LINKAGE SECTION.
 COPY MOBCTL.
 PROCEDURE DIVISION USING SW-RECORD.
     MOVE 0 TO SW-VY-ADD
     IF SW-APPLY-GRAVITY = 1 AND SW-IN-WATER = 1
         MOVE 0.005 TO SW-VY-ADD
     END-IF
     IF SW-OPERATION NOT = 2 OR SW-NAV-DONE = 1
         MOVE 0 TO SW-OUT-SPEED
         MOVE 0 TO SW-OUT-XXA
         MOVE 0 TO SW-OUT-YYA
         MOVE 0 TO SW-OUT-ZZA
     ELSE
         COMPUTE WS-HORIZONTAL = SW-DX * SW-DX + SW-DZ * SW-DZ
         COMPUTE WS-DIST = WS-HORIZONTAL + SW-DY * SW-DY
         IF WS-DIST < 2.5E-7
             MOVE 0 TO SW-OUT-ZZA
         ELSE
             CALL "ATAN2-DEGREES" USING SW-DZ SW-DX WS-ATAN
             COMPUTE WS-TARGET-YAW = WS-ATAN - 90
             CALL "ROTLERP" USING SW-Y-ROT WS-TARGET-YAW SW-MAX-TURN-Y WS-RESULT
             MOVE WS-RESULT TO SW-Y-ROT
             MOVE WS-RESULT TO SW-Y-HEAD
             MOVE WS-RESULT TO SW-Y-BODY
             COMPUTE WS-BASE = SW-SPEED-MOD * SW-MOVEMENT-SPEED
             IF SW-IN-WATER = 1
                 COMPUTE SW-OUT-SPEED = WS-BASE * SW-IN-MOD
                 COMPUTE WS-HORIZONTAL = FUNCTION SQRT(WS-HORIZONTAL)
                 COMPUTE WS-ABS-DY = FUNCTION ABS(SW-DY)
                 IF WS-ABS-DY > 1.0E-5 OR WS-HORIZONTAL > 1.0E-5
                     CALL "ATAN2-DEGREES" USING SW-DY WS-HORIZONTAL WS-ATAN
                     COMPUTE WS-DIFF = 0 - WS-ATAN
                     CALL "WRAP-DEGREES" USING WS-DIFF WS-WRAPPED
                     COMPUTE WS-NEGATIVE-MAX = 0 - SW-MAX-TURN-X
                     EVALUATE TRUE
                         WHEN WS-WRAPPED > SW-MAX-TURN-X
                             MOVE SW-MAX-TURN-X TO WS-TARGET-PITCH
                         WHEN WS-WRAPPED < WS-NEGATIVE-MAX
                             MOVE WS-NEGATIVE-MAX TO WS-TARGET-PITCH
                         WHEN OTHER
                             MOVE WS-WRAPPED TO WS-TARGET-PITCH
                     END-EVALUATE
                     CALL "ROTATE-TOWARDS" USING SW-X-ROT WS-TARGET-PITCH WS-PITCH-STEP WS-RESULT
                     MOVE WS-RESULT TO SW-X-ROT
                 END-IF
                 COMPUTE WS-RADIANS = SW-X-ROT * FUNCTION PI / 180
                 COMPUTE SW-OUT-ZZA = FUNCTION COS(WS-RADIANS) * WS-BASE
                 COMPUTE SW-OUT-YYA = 0 - FUNCTION SIN(WS-RADIANS) * WS-BASE
             ELSE
                 COMPUTE WS-DIFF = SW-Y-ROT - WS-TARGET-YAW
                 CALL "WRAP-DEGREES" USING WS-DIFF WS-WRAPPED
                 COMPUTE WS-FACTOR = (FUNCTION ABS(WS-WRAPPED) - 10) / 50
                 EVALUATE TRUE
                     WHEN WS-FACTOR < 0
                         MOVE 0 TO WS-FACTOR
                     WHEN WS-FACTOR > 1
                         MOVE 1 TO WS-FACTOR
                 END-EVALUATE
                 COMPUTE SW-OUT-SPEED = WS-BASE * SW-OUT-MOD * (1 - WS-FACTOR)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SWIM-MOVE-TICK.

*> ---- 4.5 Brain system ----------------------------------------------------------------------------------------------------

*> BRAIN-SET USING BR-STATE (MOBBRAIN.cpy), memory index, value, ttl (BINARY-LONG; -1 for no expiry).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRAIN-SET.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBBRAIN.
 01 LK-INDEX               BINARY-LONG.
 01 LK-VALUE               BINARY-LONG.
 01 LK-TTL                 BINARY-LONG.
 PROCEDURE DIVISION USING BR-STATE LK-INDEX LK-VALUE LK-TTL.
     MOVE 1 TO BR-PRESENT(LK-INDEX)
     MOVE LK-VALUE TO BR-VALUE(LK-INDEX)
     MOVE LK-TTL TO BR-TTL(LK-INDEX)
     GOBACK.
 END PROGRAM BRAIN-SET.

*> BRAIN-ERASE USING BR-STATE, memory index: eraseMemory.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRAIN-ERASE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBBRAIN.
 01 LK-INDEX               BINARY-LONG.
 PROCEDURE DIVISION USING BR-STATE LK-INDEX.
     MOVE 0 TO BR-PRESENT(LK-INDEX)
     MOVE 0 TO BR-VALUE(LK-INDEX)
     MOVE -1 TO BR-TTL(LK-INDEX)
     GOBACK.
 END PROGRAM BRAIN-ERASE.

*> BRAIN-TICK USING BR-STATE: every expiring memory loses one tick and is erased when it reaches 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRAIN-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBBRAIN.
 PROCEDURE DIVISION USING BR-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         IF BR-PRESENT(WS-I) = 1 AND BR-TTL(WS-I) > 0
             SUBTRACT 1 FROM BR-TTL(WS-I)
             IF BR-TTL(WS-I) = 0
                 CALL "BRAIN-ERASE" USING BR-STATE WS-I
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BRAIN-TICK.

*> BRAIN-FIRST-ACTIVITY USING BR-STATE, chosen out (BINARY-LONG): the index of the first activity whose required memories (0 =
*> no requirement) are all present, 0 when none is (the default activity).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BRAIN-FIRST-ACTIVITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBBRAIN.
 01 LK-CHOSEN              BINARY-LONG.
 PROCEDURE DIVISION USING BR-STATE LK-CHOSEN.
     MOVE 0 TO LK-CHOSEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-ACT-COUNT OR LK-CHOSEN > 0
         MOVE 1 TO WS-OK
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
             MOVE BR-ACT-REQ(WS-I, WS-R) TO WS-M
             IF WS-M > 0 AND BR-PRESENT(WS-M) = 0
                 MOVE 0 TO WS-OK
             END-IF
         END-PERFORM
         IF WS-OK = 1
             MOVE WS-I TO LK-CHOSEN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BRAIN-FIRST-ACTIVITY.

*> BEHAVIOR-TRY-START USING BHV-RECORD: a stopped behaviour whose memory and extra conditions hold becomes RUNNING with end
*> time = time + min + roll (roll = nextInt(max - min + 1) drawn by the caller); BHV-ACTION is 1 when it started, else 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BEHAVIOR-TRY-START.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBBRAIN.
 PROCEDURE DIVISION USING BHV-RECORD.
     MOVE 0 TO BHV-ACTION
     IF BHV-STATUS = 0 AND BHV-MEMORY-OK = 1 AND BHV-EXTRA-OK = 1
         MOVE 1 TO BHV-STATUS
         COMPUTE BHV-END-TIME = BHV-TIME + BHV-MIN + BHV-ROLL
         MOVE 1 TO BHV-ACTION
     END-IF
     GOBACK.
 END PROGRAM BEHAVIOR-TRY-START.

*> BEHAVIOR-TICK USING BHV-RECORD: tickOrStop of a running behaviour. BHV-ACTION is 2 (tick), 3 (stopped) or 0 (was stopped).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BEHAVIOR-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBBRAIN.
 PROCEDURE DIVISION USING BHV-RECORD.
     MOVE 0 TO BHV-ACTION
     IF BHV-STATUS = 1
         IF BHV-CAN-STILL-USE = 1 AND BHV-TIME NOT > BHV-END-TIME
             MOVE 2 TO BHV-ACTION
         ELSE
             MOVE 0 TO BHV-STATUS
             MOVE 3 TO BHV-ACTION
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BEHAVIOR-TICK.

*> ---- 4.6 Shared sensors and behaviours -----------------------------------------------------------------------------------

*> BEHAVIOR-DEFAULT-DURATION USING min, max (BINARY-LONG): the default duration range 60 to 60.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BEHAVIOR-DEFAULT-DURATION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-MIN                 BINARY-LONG.
 01 LK-MAX                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-MIN LK-MAX.
     MOVE 60 TO LK-MIN
     MOVE 60 TO LK-MAX
     GOBACK.
 END PROGRAM BEHAVIOR-DEFAULT-DURATION.

*> SENSOR-INIT USING timer out, scan rate, roll (nextInt(scanRate)): the random initial delay.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SENSOR-INIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TIMER               BINARY-LONG.
 01 LK-RATE                BINARY-LONG.
 01 LK-ROLL                BINARY-LONG.
 PROCEDURE DIVISION USING LK-TIMER LK-RATE LK-ROLL.
     MOVE LK-ROLL TO LK-TIMER
     GOBACK.
 END PROGRAM SENSOR-INIT.

*> SENSOR-TICK USING timer (in and out), scan rate, due out (1/0): a sensor runs every scan rate ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SENSOR-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TIMER               BINARY-LONG.
 01 LK-RATE                BINARY-LONG.
 01 LK-DUE                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-TIMER LK-RATE LK-DUE.
     MOVE 0 TO LK-DUE
     SUBTRACT 1 FROM LK-TIMER
     IF LK-TIMER NOT > 0
         MOVE LK-RATE TO LK-TIMER
         MOVE 1 TO LK-DUE
     END-IF
     GOBACK.
 END PROGRAM SENSOR-TICK.

*> MOVE-SINK-REACHED USING Manhattan distance to the walk target block, close-enough distance, reached out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-SINK-REACHED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DISTANCE            BINARY-LONG.
 01 LK-CLOSE               BINARY-LONG.
 01 LK-REACHED             BINARY-LONG.
 PROCEDURE DIVISION USING LK-DISTANCE LK-CLOSE LK-REACHED.
     MOVE 0 TO LK-REACHED
     IF LK-DISTANCE NOT > LK-CLOSE
         MOVE 1 TO LK-REACHED
     END-IF
     GOBACK.
 END PROGRAM MOVE-SINK-REACHED.

*> MOVE-SINK-REPATH USING squared distance the walk target moved (FLOAT-LONG), repath out (1/0): more than 2 blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-SINK-REPATH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-MOVED               FLOAT-LONG.
 01 LK-REPATH              BINARY-LONG.
 PROCEDURE DIVISION USING LK-MOVED LK-REPATH.
     MOVE 0 TO LK-REPATH
     IF LK-MOVED > 4.0
         MOVE 1 TO LK-REPATH
     END-IF
     GOBACK.
 END PROGRAM MOVE-SINK-REPATH.

*> SENSOR-BOX USING follow range, mob box size (FLOAT-LONG), box size out (FLOAT-LONG): the mob box inflated by the follow range.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SENSOR-BOX.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-RANGE               FLOAT-LONG.
 01 LK-SIZE                FLOAT-LONG.
 01 LK-RESULT              FLOAT-LONG.
 PROCEDURE DIVISION USING LK-RANGE LK-SIZE LK-RESULT.
     COMPUTE LK-RESULT = LK-SIZE + 2 * LK-RANGE
     GOBACK.
 END PROGRAM SENSOR-BOX.

*> TEMPTING-SENSOR USING player within tempt_range, player not spectator, player rides the mob, player holds a tempting item
*> (all 1/0), tempting player found out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEMPTING-SENSOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-RANGE               BINARY-LONG.
 01 LK-ACTIVE              BINARY-LONG.
 01 LK-RIDES               BINARY-LONG.
 01 LK-HOLDS               BINARY-LONG.
 01 LK-FOUND               BINARY-LONG.
 PROCEDURE DIVISION USING LK-RANGE LK-ACTIVE LK-RIDES LK-HOLDS LK-FOUND.
     MOVE 0 TO LK-FOUND
     IF LK-RANGE = 1 AND LK-ACTIVE = 1 AND LK-RIDES = 0 AND LK-HOLDS = 1
         MOVE 1 TO LK-FOUND
     END-IF
     GOBACK.
 END PROGRAM TEMPTING-SENSOR.

*> ---- 4.7 Shared behaviours cited by the mob documents --------------------------------------------------------------------

*> COUNTDOWN-COOLDOWN USING value (in and out), keep running out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. COUNTDOWN-COOLDOWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-VALUE               BINARY-LONG.
 01 LK-KEEP                BINARY-LONG.
 PROCEDURE DIVISION USING LK-VALUE LK-KEEP.
     SUBTRACT 1 FROM LK-VALUE
     MOVE 0 TO LK-KEEP
     IF LK-VALUE > 0
         MOVE 1 TO LK-KEEP
     END-IF
     GOBACK.
 END PROGRAM COUNTDOWN-COOLDOWN.

*> DO-NOTHING-DURATION USING min, max, roll (nextInt(max - min + 1)), duration out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. DO-NOTHING-DURATION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-MIN                 BINARY-LONG.
 01 LK-MAX                 BINARY-LONG.
 01 LK-ROLL                BINARY-LONG.
 01 LK-DURATION            BINARY-LONG.
 PROCEDURE DIVISION USING LK-MIN LK-MAX LK-ROLL LK-DURATION.
     COMPUTE LK-DURATION = LK-MIN + LK-ROLL
     GOBACK.
 END PROGRAM DO-NOTHING-DURATION.

*> STOP-ATTACKING-DECISION USING target in another level, mob can attack, target dead (1/0), age of cant_reach_walk_target_since
*> (ticks, 0 when absent), stop condition (1/0), erase out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. STOP-ATTACKING-DECISION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-OTHER               BINARY-LONG.
 01 LK-CANATTACK           BINARY-LONG.
 01 LK-DEAD                BINARY-LONG.
 01 LK-AGE                 BINARY-LONG.
 01 LK-STOP                BINARY-LONG.
 01 LK-ERASE               BINARY-LONG.
 PROCEDURE DIVISION USING LK-OTHER LK-CANATTACK LK-DEAD LK-AGE LK-STOP LK-ERASE.
     MOVE 0 TO LK-ERASE
     IF LK-OTHER = 1 OR LK-CANATTACK = 0 OR LK-DEAD = 1 OR LK-AGE > 200 OR LK-STOP = 1
         MOVE 1 TO LK-ERASE
     END-IF
     GOBACK.
 END PROGRAM STOP-ATTACKING-DECISION.

*> TRY-FIND-TIMER USING outcome (0 nothing found, 1 starts moving, other not run), unused, timer out: 40, 2 or 20.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRY-FIND-TIMER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-OUTCOME             BINARY-LONG.
 01 LK-UNUSED              BINARY-LONG.
 01 LK-TIMER               BINARY-LONG.
 PROCEDURE DIVISION USING LK-OUTCOME LK-UNUSED LK-TIMER.
     EVALUATE LK-OUTCOME
         WHEN 0
             MOVE 40 TO LK-TIMER
         WHEN 1
             MOVE 2 TO LK-TIMER
         WHEN OTHER
             MOVE 20 TO LK-TIMER
     END-EVALUATE
     GOBACK.
 END PROGRAM TRY-FIND-TIMER.

*> WALK-AWAY-NEEDED USING squared distance to the remembered position, distance (FLOAT-LONG), already walking away (1/0), out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WALK-AWAY-NEEDED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DIST                FLOAT-LONG.
 01 LK-LIMIT               FLOAT-LONG.
 01 LK-AWAY                BINARY-LONG.
 01 LK-NEEDED              BINARY-LONG.
 PROCEDURE DIVISION USING LK-DIST LK-LIMIT LK-AWAY LK-NEEDED.
     MOVE 0 TO LK-NEEDED
     IF LK-DIST < LK-LIMIT * LK-LIMIT AND LK-AWAY = 0
         MOVE 1 TO LK-NEEDED
     END-IF
     GOBACK.
 END PROGRAM WALK-AWAY-NEEDED.

*> TEMPTATION-WALK USING squared distance to the player, close-enough distance (FLOAT-LONG), walk out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEMPTATION-WALK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DIST                FLOAT-LONG.
 01 LK-CLOSE               FLOAT-LONG.
 01 LK-WALK                BINARY-LONG.
 PROCEDURE DIVISION USING LK-DIST LK-CLOSE LK-WALK.
     MOVE 0 TO LK-WALK
     IF LK-DIST > LK-CLOSE * LK-CLOSE
         MOVE 1 TO LK-WALK
     END-IF
     GOBACK.
 END PROGRAM TEMPTATION-WALK.

*> CELEBRATE-DECISION USING target dead, predicate holds, celebration active, dead players forgiven (1/0), celebrate out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CELEBRATE-DECISION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DEAD                BINARY-LONG.
 01 LK-PREDICATE           BINARY-LONG.
 01 LK-ACTIVE              BINARY-LONG.
 01 LK-FORGIVE             BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-DEAD LK-PREDICATE LK-ACTIVE LK-FORGIVE LK-RESULT.
     MOVE 0 TO LK-RESULT
     IF LK-DEAD = 1 AND LK-PREDICATE = 1 AND LK-ACTIVE = 0 AND LK-FORGIVE = 1
         MOVE 1 TO LK-RESULT
     END-IF
     GOBACK.
 END PROGRAM CELEBRATE-DECISION.

*> ---- 4.8 NeutralMob ------------------------------------------------------------------------------------------------------

*> NEUTRAL-IS-ANGRY USING end time, game time (BINARY-LONG), angry out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NEUTRAL-IS-ANGRY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-END                 BINARY-LONG.
 01 LK-GAME                BINARY-LONG.
 01 LK-ANGRY               BINARY-LONG.
 PROCEDURE DIVISION USING LK-END LK-GAME LK-ANGRY.
     MOVE 0 TO LK-ANGRY
     IF LK-END > 0 AND LK-END - LK-GAME > 0
         MOVE 1 TO LK-ANGRY
     END-IF
     GOBACK.
 END PROGRAM NEUTRAL-IS-ANGRY.

*> NEUTRAL-SET-TIME USING game time, ticks, end time out: setTimeToRemainAngry.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NEUTRAL-SET-TIME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-GAME                BINARY-LONG.
 01 LK-TICKS               BINARY-LONG.
 01 LK-END                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-GAME LK-TICKS LK-END.
     COMPUTE LK-END = LK-GAME + LK-TICKS
     GOBACK.
 END PROGRAM NEUTRAL-SET-TIME.

*> NEUTRAL-STOP USING last hurt by, target, anger target (ids, set to 0), end time (set to -1): stopBeingAngry.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NEUTRAL-STOP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-HURT                BINARY-LONG.
 01 LK-TARGET              BINARY-LONG.
 01 LK-ANGER               BINARY-LONG.
 01 LK-END                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-HURT LK-TARGET LK-ANGER LK-END.
     MOVE 0 TO LK-HURT
     MOVE 0 TO LK-TARGET
     MOVE 0 TO LK-ANGER
     MOVE -1 TO LK-END
     GOBACK.
 END PROGRAM NEUTRAL-STOP.

*> NEUTRAL-LOAD-TIME USING has anger_end_time (1/0), anger_end_time, legacy AngerTime, game time, end time out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NEUTRAL-LOAD-TIME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-HAS                 BINARY-LONG.
 01 LK-STORED              BINARY-LONG.
 01 LK-LEGACY              BINARY-LONG.
 01 LK-GAME                BINARY-LONG.
 01 LK-END                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-HAS LK-STORED LK-LEGACY LK-GAME LK-END.
     IF LK-HAS = 1
         MOVE LK-STORED TO LK-END
     ELSE
         COMPUTE LK-END = LK-GAME + LK-LEGACY
     END-IF
     GOBACK.
 END PROGRAM NEUTRAL-LOAD-TIME.

*> NEUTRAL-ANGRY-AT USING can attack, entity is a valid player target, universal_anger on, mob angry, has an anger target,
*> entity is the anger target (all 1/0), angry-at out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NEUTRAL-ANGRY-AT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-CAN                 BINARY-LONG.
 01 LK-PLAYER              BINARY-LONG.
 01 LK-UNIVERSAL           BINARY-LONG.
 01 LK-ANGRY               BINARY-LONG.
 01 LK-HAS                 BINARY-LONG.
 01 LK-MATCH               BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-CAN LK-PLAYER LK-UNIVERSAL LK-ANGRY LK-HAS LK-MATCH LK-RESULT.
     MOVE 0 TO LK-RESULT
     EVALUATE TRUE
         WHEN LK-CAN = 0
             CONTINUE
         WHEN LK-PLAYER = 1 AND LK-UNIVERSAL = 1 AND LK-ANGRY = 1 AND LK-HAS = 0
             MOVE 1 TO LK-RESULT
         WHEN LK-MATCH = 1
             MOVE 1 TO LK-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM NEUTRAL-ANGRY-AT.

*> NEUTRAL-UPDATE USING has anger target, anger target dead, it matches the persistent target, dead one is a Mob, has a valid
*> target, target differs from the anger target, canTrackTarget, target is a valid player target, mob is angry, anger target
*> is a creative or spectator player or the difficulty is Peaceful (all 1/0); stop out, start timer out, set anger target
*> out (1/0): updatePersistentAnger in the order of section 4.8.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NEUTRAL-UPDATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-HAS                 BINARY-LONG.
 01 LK-DEAD                BINARY-LONG.
 01 LK-MATCH               BINARY-LONG.
 01 LK-MOB                 BINARY-LONG.
 01 LK-VALID               BINARY-LONG.
 01 LK-DIFFERS             BINARY-LONG.
 01 LK-TRACK               BINARY-LONG.
 01 LK-PLAYER              BINARY-LONG.
 01 LK-ANGRY               BINARY-LONG.
 01 LK-EXEMPT              BINARY-LONG.
 01 LK-STOP                BINARY-LONG.
 01 LK-TIMER               BINARY-LONG.
 01 LK-SET                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-HAS LK-DEAD LK-MATCH LK-MOB LK-VALID LK-DIFFERS LK-TRACK LK-PLAYER LK-ANGRY LK-EXEMPT
                          LK-STOP LK-TIMER LK-SET.
     MOVE 0 TO LK-STOP
     MOVE 0 TO LK-TIMER
     MOVE 0 TO LK-SET
     IF LK-HAS = 1 AND LK-DEAD = 1 AND LK-MATCH = 1 AND LK-MOB = 1
         MOVE 1 TO LK-STOP
     ELSE
         IF LK-VALID = 1 AND LK-DIFFERS = 1
             MOVE 1 TO LK-SET
             MOVE 1 TO LK-TIMER
         END-IF
         IF LK-HAS = 1 AND LK-ANGRY = 0 AND NOT (LK-PLAYER = 1 AND LK-TRACK = 1)
             MOVE 1 TO LK-STOP
         END-IF
         IF LK-HAS = 1 AND LK-EXEMPT = 1
             MOVE 1 TO LK-STOP
         END-IF
     END-IF
     GOBACK.
 END PROGRAM NEUTRAL-UPDATE.

*> NEUTRAL-PLAYER-DIED USING forgive_dead_players on, the dead player is the anger target (1/0), stop out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NEUTRAL-PLAYER-DIED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-FORGIVE             BINARY-LONG.
 01 LK-TARGET              BINARY-LONG.
 01 LK-STOP                BINARY-LONG.
 PROCEDURE DIVISION USING LK-FORGIVE LK-TARGET LK-STOP.
     MOVE 0 TO LK-STOP
     IF LK-FORGIVE = 1 AND LK-TARGET = 1
         MOVE 1 TO LK-STOP
     END-IF
     GOBACK.
 END PROGRAM NEUTRAL-PLAYER-DIED.

*> UNIVERSAL-ANGER-RESET-CAN-USE USING universal_anger on, hurt anew by a player (1/0), runs out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. UNIVERSAL-ANGER-RESET-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-UNIVERSAL           BINARY-LONG.
 01 LK-HURT                BINARY-LONG.
 01 LK-RUNS                BINARY-LONG.
 PROCEDURE DIVISION USING LK-UNIVERSAL LK-HURT LK-RUNS.
     MOVE 0 TO LK-RUNS
     IF LK-UNIVERSAL = 1 AND LK-HURT = 1
         MOVE 1 TO LK-RUNS
     END-IF
     GOBACK.
 END PROGRAM UNIVERSAL-ANGER-RESET-CAN-USE.

*> ---- 4.9 Monster base class ----------------------------------------------------------------------------------------------

*> LIGHT-MAGIC USING raw brightness 0..15 (BINARY-LONG), ambient light (FLOAT-LONG), value out (FLOAT-LONG):
*> b = brightness / 15, v = b / (4 - 3b), result v + ambient x (1 - v).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-MAGIC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-BRIGHTNESS          BINARY-LONG.
 01 LK-AMBIENT             FLOAT-LONG.
 01 LK-VALUE               FLOAT-LONG.
 PROCEDURE DIVISION USING LK-BRIGHTNESS LK-AMBIENT LK-VALUE.
     COMPUTE WS-B = LK-BRIGHTNESS / 15
     COMPUTE WS-V = WS-B / (4 - 3 * WS-B)
     COMPUTE LK-VALUE = WS-V + LK-AMBIENT * (1 - WS-V)
     GOBACK.
 END PROGRAM LIGHT-MAGIC.

*> MONSTER-WALK-VALUE USING magic value, walk target value out (FLOAT-LONG): magic value - 0.5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONSTER-WALK-VALUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-MAGIC               FLOAT-LONG.
 01 LK-VALUE               FLOAT-LONG.
 PROCEDURE DIVISION USING LK-MAGIC LK-VALUE.
     COMPUTE LK-VALUE = LK-MAGIC - 0.5
     GOBACK.
 END PROGRAM MONSTER-WALK-VALUE.

*> MONSTER-NO-ACTION USING magic value (FLOAT-LONG), noActionTime (BINARY-LONG, in and out): +2 above 0.5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONSTER-NO-ACTION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-MAGIC               FLOAT-LONG.
 01 LK-NOACTION            BINARY-LONG.
 PROCEDURE DIVISION USING LK-MAGIC LK-NOACTION.
     IF LK-MAGIC > 0.5
         ADD 2 TO LK-NOACTION
     END-IF
     GOBACK.
 END PROGRAM MONSTER-NO-ACTION.

*> MONSTER-DEFAULTS USING attack_damage default (FLOAT-LONG), experience reward (BINARY-LONG).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONSTER-DEFAULTS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DAMAGE              FLOAT-LONG.
 01 LK-XP                  BINARY-LONG.
 PROCEDURE DIVISION USING LK-DAMAGE LK-XP.
     MOVE 2.0 TO LK-DAMAGE
     MOVE 5 TO LK-XP
     GOBACK.
 END PROGRAM MONSTER-DEFAULTS.

*> ---- 4.10 Conversion -----------------------------------------------------------------------------------------------------

*> CONVERT-PLAN USING conversion type (1 SINGLE, 2 SPLIT_ON_DEATH), old mob removed, new mob can be created, level is a
*> ServerLevel, keepEquipment (1/0), flags out (PIC X(5) of 0/1): created, add the new entity, discard the old mob, move
*> equipment, copy position / velocity / vehicle / first passenger (the last three only for SINGLE).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONVERT-PLAN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TYPE                BINARY-LONG.
 01 LK-REMOVED             BINARY-LONG.
 01 LK-CREATE              BINARY-LONG.
 01 LK-SERVER              BINARY-LONG.
 01 LK-KEEP                BINARY-LONG.
 01 LK-FLAGS               PIC X(5).
 PROCEDURE DIVISION USING LK-TYPE LK-REMOVED LK-CREATE LK-SERVER LK-KEEP LK-FLAGS.
     MOVE "00000" TO LK-FLAGS
     IF LK-REMOVED = 0 AND LK-CREATE = 1
         MOVE "1" TO LK-FLAGS(1:1)
         IF LK-SERVER = 1
             MOVE "1" TO LK-FLAGS(2:1)
         END-IF
         IF LK-TYPE = 1
             MOVE "1" TO LK-FLAGS(3:1)
             MOVE "1" TO LK-FLAGS(5:1)
             IF LK-KEEP = 1
                 MOVE "1" TO LK-FLAGS(4:1)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CONVERT-PLAN.

*> ---- 4.11 Bucketable -----------------------------------------------------------------------------------------------------

*> BUCKET-PICKUP USING holds a water bucket, mob alive (1/0), pickup allowed out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUCKET-PICKUP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-BUCKET              BINARY-LONG.
 01 LK-ALIVE               BINARY-LONG.
 01 LK-OK                  BINARY-LONG.
 PROCEDURE DIVISION USING LK-BUCKET LK-ALIVE LK-OK.
     MOVE 0 TO LK-OK
     IF LK-BUCKET = 1 AND LK-ALIVE = 1
         MOVE 1 TO LK-OK
     END-IF
     GOBACK.
 END PROGRAM BUCKET-PICKUP.

*> BUCKET-KEYS USING NoAI, Silent, NoGravity, Glowing, Invulnerable, PersistenceRequired (1/0), keys out (PIC X(80)): the keys
*> of bucket_entity_data: Health always, the booleans only when true, in that order.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUCKET-KEYS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER              PIC X(19) VALUE "NoAI".
    05 FILLER              PIC X(19) VALUE "Silent".
    05 FILLER              PIC X(19) VALUE "NoGravity".
    05 FILLER              PIC X(19) VALUE "Glowing".
    05 FILLER              PIC X(19) VALUE "Invulnerable".
    05 FILLER              PIC X(19) VALUE "PersistenceRequired".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(19) OCCURS 6 TIMES.
 01 WS-FLAGS.
    05 WS-FLAG             BINARY-LONG OCCURS 6 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 LK-NOAI                BINARY-LONG.
 01 LK-SILENT              BINARY-LONG.
 01 LK-NOGRAVITY           BINARY-LONG.
 01 LK-GLOWING             BINARY-LONG.
 01 LK-INVULNERABLE        BINARY-LONG.
 01 LK-PERSISTENCE         BINARY-LONG.
 01 LK-KEYS                PIC X(80).
 PROCEDURE DIVISION USING LK-NOAI LK-SILENT LK-NOGRAVITY LK-GLOWING LK-INVULNERABLE LK-PERSISTENCE LK-KEYS.
     MOVE LK-NOAI TO WS-FLAG(1)
     MOVE LK-SILENT TO WS-FLAG(2)
     MOVE LK-NOGRAVITY TO WS-FLAG(3)
     MOVE LK-GLOWING TO WS-FLAG(4)
     MOVE LK-INVULNERABLE TO WS-FLAG(5)
     MOVE LK-PERSISTENCE TO WS-FLAG(6)
     MOVE SPACES TO LK-KEYS
     MOVE "Health" TO LK-KEYS
     MOVE 7 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF WS-FLAG(WS-I) = 1
             ADD 1 TO WS-POS
             MOVE FUNCTION TRIM(WS-NAME(WS-I)) TO LK-KEYS(WS-POS:)
             ADD FUNCTION LENGTH(FUNCTION TRIM(WS-NAME(WS-I))) TO WS-POS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BUCKET-KEYS.

*> BUCKET-LOAD-PERSISTENCE USING stored PersistenceRequired (1/0), set persistence out (1/0): only when the stored value is true.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUCKET-LOAD-PERSISTENCE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-STORED              BINARY-LONG.
 01 LK-SET                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-STORED LK-SET.
     MOVE LK-STORED TO LK-SET
     GOBACK.
 END PROGRAM BUCKET-LOAD-PERSISTENCE.
