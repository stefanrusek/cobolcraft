*> Rule functions of docs/protocol/44-residual-mob-questions-7-aquatic.md (lane 002-lane-p49j-a, tasks T24000 to T24099). Each program is one deterministic rule of the document with its
*> random draws and world facts passed in; the aquatic species the document describes beyond the water animals of mob-21-4.cob (axolotl, nautilus, zombie nautilus, elder guardian)
*> have no mob rows yet, so these functions are proven by tests but not called by a mob tick (see the lane task list).
*>   Q7-GROUP-BABY size draw chance out: 2.1 (size > 0 and draw <= chance).     Q7-GROUP-CHANCE key out: 6.3 chance of a squid, glow squid, dolphin (0.05, 0.05, 0.1).
*>   Q7-AGE-LOCK locked age timer: 2.2 the toggle.   Q7-RANGE-PASS range visibility dist2 out: 2.7 step 6.   Q7-TARGET-TEST: 2.7 steps 1 to 8.
*>   Q7-ELDER-DUE tick id out, Q7-ELDER-FILTER, Q7-ELDER-VALUE: 5.   Q7-XP-WATER draw out: 6.1.   Q7-DOLPHIN-FEED baby locked out: 6.4.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-GROUP-BABY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-DRAW L-CHANCE L-OUT.
     MOVE 0 TO L-OUT
     IF L-SIZE > 0 AND L-DRAW <= L-CHANCE
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-GROUP-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-GROUP-CHANCE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-KEY L-OUT.
     EVALUATE L-KEY
         WHEN "dolphin"
             MOVE 0.1 TO L-OUT
         WHEN "axolotl"
             MOVE 0 TO L-OUT
         WHEN OTHER
             MOVE 0.05 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-GROUP-CHANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AGE-LOCK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOCKED               BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-TIMER                BINARY-LONG.
 PROCEDURE DIVISION USING L-LOCKED L-AGE L-TIMER.
     COMPUTE L-LOCKED = 1 - L-LOCKED
     MOVE -24000 TO L-AGE
     MOVE 40 TO L-TIMER
     GOBACK.
 END PROGRAM Q7-AGE-LOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-RANGE-PASS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-RANGE                FLOAT-LONG.
 01 L-VIS                  FLOAT-LONG.
 01 L-DIST2                FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-RANGE L-VIS L-DIST2 L-OUT.
     MOVE 1 TO L-OUT
     IF L-RANGE > 0
         COMPUTE WS-R = FUNCTION MAX(L-RANGE * L-VIS, 2.0)
         IF L-DIST2 > WS-R * WS-R
             MOVE 0 TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q7-RANGE-PASS.

*> 2.7: flags are 1 or 0. USING null-attacker combat same-entity unseen selector-fails cannot-attack allied range vis dist2 los-wanted attacker-mob has-los seen-as-enemy peaceful out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-TARGET-TEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PASS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NULL                 BINARY-LONG.
 01 L-COMBAT               BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-UNSEEN               BINARY-LONG.
 01 L-SELFAIL              BINARY-LONG.
 01 L-NOATTACK             BINARY-LONG.
 01 L-ALLIED               BINARY-LONG.
 01 L-RANGE                FLOAT-LONG.
 01 L-VIS                  FLOAT-LONG.
 01 L-DIST2                FLOAT-LONG.
 01 L-LOS                  BINARY-LONG.
 01 L-MOB                  BINARY-LONG.
 01 L-HASLOS               BINARY-LONG.
 01 L-ENEMY                BINARY-LONG.
 01 L-PEACE                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NULL L-COMBAT L-SAME L-UNSEEN L-SELFAIL L-NOATTACK L-ALLIED L-RANGE L-VIS L-DIST2 L-LOS L-MOB L-HASLOS L-ENEMY L-PEACE L-OUT.
     MOVE 0 TO L-OUT
     EVALUATE TRUE
         WHEN L-SAME = 1
             GOBACK
         WHEN L-UNSEEN = 1
             GOBACK
         WHEN L-SELFAIL = 1
             GOBACK
         WHEN L-NULL = 1 AND L-COMBAT = 0
             MOVE 1 TO L-OUT
             GOBACK
         WHEN L-NULL = 1
             IF L-ENEMY = 1 AND L-PEACE = 0
                 MOVE 1 TO L-OUT
             END-IF
             GOBACK
     END-EVALUATE
     IF L-COMBAT = 1 AND (L-NOATTACK = 1 OR L-ALLIED = 1)
         GOBACK
     END-IF
     CALL "Q7-RANGE-PASS" USING L-RANGE L-VIS L-DIST2 WS-PASS
     IF WS-PASS = 0
         GOBACK
     END-IF
     IF L-LOS = 1 AND L-MOB = 1 AND L-HASLOS = 0
         GOBACK
     END-IF
     MOVE 1 TO L-OUT
     GOBACK.
 END PROGRAM Q7-TARGET-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-ELDER-DUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICK                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TICK L-ID L-OUT.
     MOVE 0 TO L-OUT
     IF FUNCTION MOD(L-TICK + L-ID, 1200) = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-ELDER-DUE.

*> USING game mode (0 survival, 1 creative, 2 adventure, 3 spectator), allied (1/0), dist2, has effect, current amplifier, current duration (-1 infinite), new amplifier, out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-ELDER-FILTER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-ALLIED               BINARY-LONG.
 01 L-DIST2                FLOAT-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-CURAMP               BINARY-LONG.
 01 L-CURDUR               BINARY-LONG.
 01 L-NEWAMP               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-ALLIED L-DIST2 L-HAS L-CURAMP L-CURDUR L-NEWAMP L-OUT.
     MOVE 0 TO L-OUT
     IF L-MODE NOT = 0 AND L-MODE NOT = 2
         GOBACK
     END-IF
     IF L-ALLIED = 1
         GOBACK
     END-IF
     IF L-DIST2 >= 2500
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN L-HAS = 0
             MOVE 1 TO L-OUT
         WHEN L-CURAMP < L-NEWAMP
             MOVE 1 TO L-OUT
         WHEN L-CURDUR >= 0 AND L-CURDUR <= 1199
             MOVE 1 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-ELDER-FILTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-ELDER-VALUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SILENT               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SILENT L-OUT.
     MOVE 1 TO L-OUT
     IF L-SILENT = 1
         MOVE 0 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-ELDER-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-XP-WATER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-OUT.
     COMPUTE L-OUT = 1 + FUNCTION MOD(L-DRAW, 3)
     GOBACK.
 END PROGRAM Q7-XP-WATER.

*> 6.4: out 1 = the baby ages up (item consumed), 2 = gotFish is set (item consumed). canAgeUp = a baby that is not age-locked.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-DOLPHIN-FEED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                 BINARY-LONG.
 01 L-LOCKED               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-LOCKED L-OUT.
     MOVE 2 TO L-OUT
     IF L-BABY = 1 AND L-LOCKED = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-DOLPHIN-FEED.

*> 7: the dolphin jump goal. Offsets of STEPS_TO_CHECK are 0, 1, 4, 5, 6, 7: W, A1 and A2 are strings of 8 flags (offset 0 to 7) for "water and not blocks_dolphin_jump",
*> "air at +1" and "air at +2". USING draw (the nextInt(5) result), W, A1, A2, out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-JUMP-CAN-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEPS               PIC X(6) VALUE X"000104050607".
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-W                    PIC X(8).
 01 L-A1                   PIC X(8).
 01 L-A2                   PIC X(8).
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-W L-A1 L-A2 L-OUT.
     MOVE 0 TO L-OUT
     IF L-DRAW NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-S = FUNCTION ORD(WS-STEPS(WS-I:1)) - 1 + 1
         IF L-W(WS-S:1) NOT = "1" OR L-A1(WS-S:1) NOT = "1" OR L-A2(WS-S:1) NOT = "1"
             GOBACK
         END-IF
     END-PERFORM
     MOVE 1 TO L-OUT
     GOBACK.
 END PROGRAM Q7-JUMP-CAN-USE.

*> canContinueToUse: not on the ground and not (vy^2 < 0.03 and xRot not 0 and |xRot| < 10 and in water).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-JUMP-CONTINUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ONGROUND             BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-XROT                 FLOAT-LONG.
 01 L-INWATER              BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ONGROUND L-VY L-XROT L-INWATER L-OUT.
     MOVE 1 TO L-OUT
     IF L-ONGROUND = 1
         MOVE 0 TO L-OUT
         GOBACK
     END-IF
     IF L-VY * L-VY < 0.03 AND L-XROT NOT = 0 AND FUNCTION ABS(L-XROT) < 10 AND L-INWATER = 1
         MOVE 0 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-JUMP-CONTINUE.

*> tick step 2: the pitch (inout). Level velocity with a nonzero pitch: 20% of the way to 0; otherwise along the velocity (57.2957763671875 x atan2(-vy, horizontal speed)).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-JUMP-PITCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HS                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-XROT                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-VX L-VY L-VZ L-XROT.
     COMPUTE WS-HS = FUNCTION SQRT(L-VX * L-VX + L-VZ * L-VZ)
     COMPUTE WS-LEN = FUNCTION SQRT(L-VX * L-VX + L-VY * L-VY + L-VZ * L-VZ)
     IF L-VY * L-VY < 0.03 AND L-XROT NOT = 0
         COMPUTE L-XROT = L-XROT - L-XROT * 0.2
     ELSE
         IF WS-LEN > 0.00001
             COMPUTE L-XROT = FUNCTION ATAN(-L-VY / WS-HS) * 57.2957763671875
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q7-JUMP-PITCH.

*> start: velocity += (dx x 0.6, 0.7, dz x 0.6); the facing (Direction.fromYRot: yaw 0 south +z, 90 west -x, 180 north, 270 east) is Q7-JUMP-FACING.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-JUMP-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DX L-DZ L-VX L-VY L-VZ.
     COMPUTE L-VX = L-VX + L-DX * 0.6
     COMPUTE L-VY = L-VY + 0.7
     COMPUTE L-VZ = L-VZ + L-DZ * 0.6
     GOBACK.
 END PROGRAM Q7-JUMP-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-JUMP-FACING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-YAW L-DX L-DZ.
     COMPUTE WS-Q = FUNCTION MOD(FUNCTION INTEGER(L-YAW / 90 + 0.5), 4)
     EVALUATE WS-Q
         WHEN 0
             MOVE 0 TO L-DX
             MOVE 1 TO L-DZ
         WHEN 1
             MOVE -1 TO L-DX
             MOVE 0 TO L-DZ
         WHEN 2
             MOVE 0 TO L-DX
             MOVE -1 TO L-DZ
         WHEN OTHER
             MOVE 1 TO L-DX
             MOVE 0 TO L-DZ
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-JUMP-FACING.

*> 8.3: the play-dead test. draw-a is nextInt(3), draw-b nextInt(3) (drawn only when the earlier steps pass); draws out is how many were made (0, 1 or 2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-PLAYDEAD.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AI                   BINARY-LONG.
 01 L-DA                   BINARY-LONG.
 01 L-DB                   BINARY-LONG.
 01 L-DMG                  FLOAT-LONG.
 01 L-HEALTH               FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-INWATER              BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-ALREADY              BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-AI L-DA L-DB L-DMG L-HEALTH L-MAX L-INWATER L-SOURCE L-ALREADY L-OUT L-DRAWS.
     MOVE 0 TO L-OUT
     MOVE 0 TO L-DRAWS
     IF L-AI = 0
         GOBACK
     END-IF
     MOVE 1 TO L-DRAWS
     IF L-DA NOT = 0
         GOBACK
     END-IF
     MOVE 2 TO L-DRAWS
     IF NOT (L-DB < L-DMG OR L-HEALTH / L-MAX < 0.5)
         GOBACK
     END-IF
     IF L-DMG >= L-HEALTH OR L-INWATER = 0 OR L-SOURCE = 0 OR L-ALREADY = 1
         GOBACK
     END-IF
     MOVE 1 TO L-OUT
     GOBACK.
 END PROGRAM Q7-AXO-PLAYDEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-OFFSPRING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RARE                 BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-PARTNER              BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-RARE L-COIN L-OWN L-PARTNER L-OUT.
     EVALUATE TRUE
         WHEN L-RARE = 0
             MOVE 4 TO L-OUT
         WHEN L-COIN = 1
             MOVE L-OWN TO L-OUT
         WHEN OTHER
             MOVE L-PARTNER TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-AXO-OFFSPRING.

*> 8.1 USING group size, out: 1 when this axolotl is a baby (the group size is at least 2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-GROUP-BABY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-OUT.
     MOVE 0 TO L-OUT
     IF L-SIZE >= 2
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-AXO-GROUP-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-REHYDRATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR.
     COMPUTE L-AIR = FUNCTION MIN(L-AIR + 1800, 6000)
     GOBACK.
 END PROGRAM Q7-AXO-REHYDRATE.

*> 8.4 air handler: USING air (inout), in water or rain, damage out (2 when the air ran to -20 and was reset to 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-AIR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-WET L-DAMAGE.
     MOVE 0 TO L-DAMAGE
     IF L-WET = 1
         MOVE 6000 TO L-AIR
     ELSE
         SUBTRACT 1 FROM L-AIR
         IF L-AIR <= -20
             MOVE 0 TO L-AIR
             MOVE 2 TO L-DAMAGE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q7-AXO-AIR.

*> 8.5 applySupportingEffects: USING has Regeneration, its duration, new duration out, applies out (1 when the grant happens). Mining Fatigue is always removed (the caller's job).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-SUPPORT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-APPLY                BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-DUR L-NEW L-APPLY.
     MOVE 0 TO L-APPLY
     MOVE L-DUR TO L-NEW
     IF L-HAS = 0 OR (L-DUR >= 0 AND L-DUR <= 2399)
         MOVE 1 TO L-APPLY
         IF L-HAS = 0
             MOVE 100 TO L-NEW
         ELSE
             COMPUTE L-NEW = FUNCTION MIN(2400, 100 + L-DUR)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q7-AXO-SUPPORT.

*> 8.3 updateActivity: activities 0 IDLE, 1 FIGHT, 2 PLAY_DEAD. USING previous activity (inout), play-dead memory present, attack target present, hunting cooldown out (2400 or unchanged 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-ACTIVITY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE               BINARY-LONG.
 01 L-DEAD                 BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-DEAD L-TARGET L-COOLDOWN.
     IF L-ACTIVE = 2
         GOBACK
     END-IF
     MOVE 0 TO L-COOLDOWN
     EVALUATE TRUE
         WHEN L-DEAD = 1
             IF L-ACTIVE = 1
                 MOVE 2400 TO L-COOLDOWN
             END-IF
             MOVE 2 TO L-ACTIVE
         WHEN L-TARGET = 1
             MOVE 1 TO L-ACTIVE
         WHEN OTHER
             IF L-ACTIVE = 1
                 MOVE 2400 TO L-COOLDOWN
             END-IF
             MOVE 0 TO L-ACTIVE
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-AXO-ACTIVITY.

*> 8.6 speeds. USING kind (1 chasing, 2 following an adult, 3 idling, 4 making love), in water, out: the first three fall to 0.15 on land.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-SPEED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-INWATER              BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-INWATER L-OUT.
     EVALUATE TRUE
         WHEN L-KIND = 4
             MOVE 0.2 TO L-OUT
         WHEN L-INWATER = 0
             MOVE 0.15 TO L-OUT
         WHEN L-KIND = 3
             MOVE 0.5 TO L-OUT
         WHEN OTHER
             MOVE 0.6 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-AXO-SPEED.

*> 8.6 scan order of BlockPos.withinBoxByManhattanDistance(pos, 6, 6, 6): USING index (0 based), dx, dy, dz out (all 0 and index too large: dx 99). 2197 offsets in all.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-SCAN-ORDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-LIMX                BINARY-LONG.
 01 WS-LIMY                BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-X L-Y L-Z.
     MOVE 0 TO WS-N
     MOVE 99 TO L-X
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 18
         COMPUTE WS-LIMX = FUNCTION MIN(6, WS-D)
         COMPUTE WS-START = 0 - WS-LIMX
         PERFORM VARYING WS-DX FROM WS-START BY 1 UNTIL WS-DX > WS-LIMX
             COMPUTE WS-REST = WS-D - FUNCTION ABS(WS-DX)
             COMPUTE WS-LIMY = FUNCTION MIN(6, WS-REST)
             COMPUTE WS-START = 0 - WS-LIMY
             PERFORM VARYING WS-DY FROM WS-START BY 1 UNTIL WS-DY > WS-LIMY
                 COMPUTE WS-Z = WS-REST - FUNCTION ABS(WS-DY)
                 IF WS-Z <= 6
                     IF WS-N = L-INDEX
                         MOVE WS-DX TO L-X
                         MOVE WS-DY TO L-Y
                         MOVE WS-Z TO L-Z
                         GOBACK
                     END-IF
                     ADD 1 TO WS-N
                     IF WS-Z NOT = 0
                         IF WS-N = L-INDEX
                             MOVE WS-DX TO L-X
                             MOVE WS-DY TO L-Y
                             COMPUTE L-Z = 0 - WS-Z
                             GOBACK
                         END-IF
                         ADD 1 TO WS-N
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM Q7-SCAN-ORDER.

*> 9.1 USING dist2, in water, hostile type, has hunting cooldown, hunt-target type, isEntityAttackable, out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-ATTACKABLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D2                   FLOAT-LONG.
 01 L-INWATER              BINARY-LONG.
 01 L-HOSTILE              BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-HUNT                 BINARY-LONG.
 01 L-ATTACKABLE           BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-INWATER L-HOSTILE L-COOLDOWN L-HUNT L-ATTACKABLE L-OUT.
     MOVE 0 TO L-OUT
     IF L-D2 > 64 OR L-INWATER = 0
         GOBACK
     END-IF
     IF L-HOSTILE = 0 AND (L-COOLDOWN = 1 OR L-HUNT = 0)
         GOBACK
     END-IF
     IF L-ATTACKABLE = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-AXO-ATTACKABLE.

*> 9.1 type tags. USING entity key (no namespace), out: 1 axolotl_always_hostiles, 2 axolotl_hunt_targets, else 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-TAG.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-OUT.
     EVALUATE L-KEY
         WHEN "drowned" WHEN "guardian" WHEN "elder_guardian"
             MOVE 1 TO L-OUT
         WHEN "tropical_fish" WHEN "pufferfish" WHEN "salmon" WHEN "cod" WHEN "squid" WHEN "glow_squid" WHEN "tadpole"
             MOVE 2 TO L-OUT
         WHEN OTHER
             MOVE 0 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-AXO-TAG.

*> 9.2 USING isEntityAttackable, other is a cube mob, its size, key in frog_food (1/0), UUID in the unreachable memory, dist2, out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-FROG-ATTACKABLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACKABLE           BINARY-LONG.
 01 L-CUBE                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-FOOD                 BINARY-LONG.
 01 L-UNREACHABLE          BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACKABLE L-CUBE L-SIZE L-FOOD L-UNREACHABLE L-D2 L-OUT.
     MOVE 0 TO L-OUT
     IF L-ATTACKABLE = 0 OR L-FOOD = 0 OR L-UNREACHABLE = 1
         GOBACK
     END-IF
     IF L-CUBE = 1 AND L-SIZE NOT = 1
         GOBACK
     END-IF
     IF L-D2 < 100
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-FROG-ATTACKABLE.

*> 9.2 addUnreachableTargetToMemory: the list of up to 5 ids (count inout), the new id, the expiry out (100 each addition).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-FROG-UNREACH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIST.
    05 L-ID                BINARY-LONG OCCURS 5 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-EXPIRY               BINARY-LONG.
 PROCEDURE DIVISION USING L-LIST L-COUNT L-NEW L-EXPIRY.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         IF L-ID(WS-I) = L-NEW
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         IF L-COUNT = 5
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE L-ID(WS-I + 1) TO L-ID(WS-I)
             END-PERFORM
             MOVE 4 TO L-COUNT
         END-IF
         ADD 1 TO L-COUNT
         MOVE L-NEW TO L-ID(L-COUNT)
     END-IF
     MOVE 100 TO L-EXPIRY
     GOBACK.
 END PROGRAM Q7-FROG-UNREACH.

*> 9.3 item tags of the nautilus. USING item key (no namespace), out: 1 fishes, 2 nautilus_bucket_food, 3 nautilus_taming_items only (pufferfish bucket is also 2), 0 none; taming out: 1 for pufferfish and pufferfish_bucket.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-FOOD.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-FOOD                 BINARY-LONG.
 01 L-TAMING               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FOOD L-TAMING.
     MOVE 0 TO L-FOOD
     MOVE 0 TO L-TAMING
     EVALUATE L-KEY
         WHEN "cod" WHEN "cooked_cod" WHEN "salmon" WHEN "cooked_salmon" WHEN "pufferfish" WHEN "tropical_fish"
             MOVE 1 TO L-FOOD
         WHEN "pufferfish_bucket" WHEN "cod_bucket" WHEN "salmon_bucket" WHEN "tropical_fish_bucket"
             MOVE 2 TO L-FOOD
     END-EVALUATE
     IF L-KEY = "pufferfish" OR L-KEY = "pufferfish_bucket"
         MOVE 1 TO L-TAMING
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-FOOD.
