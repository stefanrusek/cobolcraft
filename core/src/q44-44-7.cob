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
 01 WS-ANG                 FLOAT-LONG.
 01 WS-HALFPI              FLOAT-LONG VALUE 1.5707963267948966.
 01 WS-DEG                 FLOAT-LONG VALUE 57.2957763671875.
 01 WS-HS2                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-XROT                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-VX L-VY L-VZ L-XROT.
     COMPUTE WS-HS2 = L-VX * L-VX + L-VZ * L-VZ
     MOVE 0 TO WS-HS
     IF WS-HS2 > 0.000000000001
         COMPUTE WS-HS = FUNCTION SQRT(WS-HS2)
     END-IF
     COMPUTE WS-LEN = FUNCTION SQRT(L-VX * L-VX + L-VY * L-VY + L-VZ * L-VZ)
     IF L-VY * L-VY < 0.03 AND L-XROT NOT = 0
         COMPUTE L-XROT = L-XROT - L-XROT * 0.2
     ELSE
         EVALUATE TRUE
             WHEN WS-LEN <= 0.00001
                 CONTINUE
             WHEN WS-HS2 <= 0.000000000001 AND L-VY > 0
                 COMPUTE WS-ANG = WS-HALFPI * WS-DEG
                 COMPUTE L-XROT = 0 - WS-ANG
             WHEN WS-HS2 <= 0.000000000001
                 COMPUTE WS-ANG = WS-HALFPI * WS-DEG
                 MOVE WS-ANG TO L-XROT
             WHEN OTHER
                 COMPUTE WS-ANG = FUNCTION ATAN(-L-VY / WS-HS)
                 COMPUTE L-XROT = WS-ANG * WS-DEG
         END-EVALUATE
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

*> 8.3 ValidatePlayDead: USING the PLAY_DEAD_TICKS value (inout), erased out: at 0 or below the memory (and HURT_BY_ENTITY) is erased, otherwise the value falls by 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-AXO-VALIDATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-ERASED               BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKS L-ERASED.
     MOVE 0 TO L-ERASED
     IF L-TICKS <= 0
         MOVE 1 TO L-ERASED
     ELSE
         SUBTRACT 1 FROM L-TICKS
     END-IF
     GOBACK.
 END PROGRAM Q7-AXO-VALIDATE.

*> 10.2 food. USING item key (no namespace), tame, baby, out: an untamed adult takes only nautilus_taming_items, a tame adult or any baby nautilus_food.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-IS-FOOD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOOD                BINARY-LONG.
 01 WS-TAMING              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-TAME                 BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TAME L-BABY L-OUT.
     CALL "Q7-NAU-FOOD" USING L-KEY WS-FOOD WS-TAMING
     MOVE 0 TO L-OUT
     IF L-TAME = 0 AND L-BABY = 0
         MOVE WS-TAMING TO L-OUT
     ELSE
         IF WS-FOOD > 0
             MOVE 1 TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-IS-FOOD.

*> 10.2 tryToTame: draw = nextInt(3); 0 tames (event 7), else event 6.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-TAME-ROLL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-TAMED                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-TAMED L-EVENT.
     MOVE 0 TO L-TAMED
     MOVE 6 TO L-EVENT
     IF L-DRAW = 0
         MOVE 1 TO L-TAMED
         MOVE 7 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-TAME-ROLL.

*> 10.3 canUseSlot(SADDLE or BODY): alive, not a baby and tame.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-SLOT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALIVE                BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-TAME                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ALIVE L-BABY L-TAME L-OUT.
     MOVE 0 TO L-OUT
     IF L-ALIVE = 1 AND L-BABY = 0 AND L-TAME = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-SLOT.

*> 10.3 armor table. USING material (copper, iron, golden, diamond, netherite), armor, toughness, knockback resistance in thousandths.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-ARMOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-ARMOR                BINARY-LONG.
 01 L-TOUGH                BINARY-LONG.
 01 L-KB                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ARMOR L-TOUGH L-KB.
     MOVE 0 TO L-ARMOR L-TOUGH L-KB
     EVALUATE L-KEY
         WHEN "copper"
             MOVE 4 TO L-ARMOR
         WHEN "iron"
             MOVE 5 TO L-ARMOR
         WHEN "golden"
             MOVE 7 TO L-ARMOR
         WHEN "diamond"
             MOVE 11 TO L-ARMOR
             MOVE 2 TO L-TOUGH
         WHEN "netherite"
             MOVE 19 TO L-ARMOR
             MOVE 3 TO L-TOUGH
             MOVE 100 TO L-KB
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-NAU-ARMOR.

*> 10.3.1 shearing: USING passengers present, BODY worn, SADDLE worn, slot out (1 BODY, 2 SADDLE, 0 none). A ridden nautilus cannot be sheared.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-SHEAR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PASS                 BINARY-LONG.
 01 L-BODY                 BINARY-LONG.
 01 L-SADDLE               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PASS L-BODY L-SADDLE L-OUT.
     MOVE 0 TO L-OUT
     IF L-PASS = 0
         EVALUATE TRUE
             WHEN L-BODY = 1
                 MOVE 1 TO L-OUT
             WHEN L-SADDLE = 1
                 MOVE 2 TO L-OUT
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-SHEAR.

*> 10.4 getRiddenInput: USING xxa, zza, player pitch (degrees), x, y, z out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-RIDDEN-INPUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-XXA                  FLOAT-LONG.
 01 L-ZZA                  FLOAT-LONG.
 01 L-XROT                 FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-XXA L-ZZA L-XROT L-X L-Y L-Z.
     MOVE L-XXA TO L-X
     MOVE 0 TO L-Y L-Z
     IF L-ZZA NOT = 0
         COMPUTE WS-RAD = L-XROT * 0.017453292
         COMPUTE WS-C = FUNCTION COS(WS-RAD)
         COMPUTE WS-S = 0 - FUNCTION SIN(WS-RAD)
         IF L-ZZA < 0
             COMPUTE WS-C = WS-C * -0.5
             COMPUTE WS-S = WS-S * -0.5
         END-IF
         MOVE WS-S TO L-Y
         MOVE WS-C TO L-Z
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-RIDDEN-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-RIDDEN-SPEED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INWATER              BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-INWATER L-SPEED L-OUT.
     IF L-INWATER = 1
         COMPUTE L-OUT = 0.0325 * L-SPEED
     ELSE
         COMPUTE L-OUT = 0.02 * L-SPEED
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-RIDDEN-SPEED.

*> 10.4 getPlayerJumpPendingScale: 1.0 from strength 90, else 0.4 + 0.4 x strength / 90.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-JUMP-SCALE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STRENGTH             BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-STRENGTH L-OUT.
     IF L-STRENGTH >= 90
         MOVE 1.0 TO L-OUT
     ELSE
         COMPUTE L-OUT = 0.4 + 0.4 * L-STRENGTH / 90
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-JUMP-SCALE.

*> 10.4 executeRidersJump: the impulse length m x scale x movement speed x block speed factor, m 1.2 in water and 0.5 on land.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-DASH-IMPULSE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCALE                FLOAT-LONG.
 01 L-INWATER              BINARY-LONG.
 01 L-MOVE                 FLOAT-LONG.
 01 L-BLOCK                FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-SCALE L-INWATER L-MOVE L-BLOCK L-OUT.
     IF L-INWATER = 1
         COMPUTE L-OUT = 1.2 * L-SCALE * L-MOVE * L-BLOCK
     ELSE
         COMPUTE L-OUT = 0.5 * L-SCALE * L-MOVE * L-BLOCK
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-DASH-IMPULSE.

*> 10.4 tick: if dashing and the cooldown is below 35 the flag clears; then a positive cooldown falls by 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-DASH-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-DASH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COOLDOWN L-DASH.
     IF L-DASH = 1 AND L-COOLDOWN < 35
         MOVE 0 TO L-DASH
     END-IF
     IF L-COOLDOWN > 0
         SUBTRACT 1 FROM L-COOLDOWN
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-DASH-TICK.

*> 10.4 applyEffects: Breath of the Nautilus (60 ticks) when the first passenger lacks it or gameTime mod 40 = 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-RIDER-FX.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-TIME                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-TIME L-OUT.
     MOVE 0 TO L-OUT
     IF L-HAS = 0 OR FUNCTION MOD(L-TIME, 40) = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-RIDER-FX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-RADIUS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ADULT                BINARY-LONG.
 01 L-SADDLED              BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ADULT L-SADDLED L-OUT.
     MOVE 16 TO L-OUT
     IF L-ADULT = 1 AND L-SADDLED = 0
         MOVE 32 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-RADIUS.

*> 10.4.1 USING squared distance moved, squared velocity length, out: 0 when moved2 - v2 > 100.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-VEHICLE-OK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOVED2               FLOAT-LONG.
 01 L-V2                   FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MOVED2 L-V2 L-OUT.
     MOVE 1 TO L-OUT
     IF L-MOVED2 - L-V2 > 100
         MOVE 0 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-VEHICLE-OK.

*> 10.4.2 p = clamp(s x 2.0, 0.15, 1.0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-BUBBLE-P.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPEED                FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-SPEED L-OUT.
     COMPUTE L-OUT = FUNCTION MIN(FUNCTION MAX(L-SPEED * 2.0, 0.15), 1.0)
     GOBACK.
 END PROGRAM Q7-NAU-BUBBLE-P.

*> 10.5 findNearestValidAttackTarget: USING breeding, in water, baby, tame, ANGRY_AT target valid (in water, attackable), cooldown present, roll (1 when nextFloat < 0.5: no target),
*> pufferfish in water visible, target out (1/0), new ATTACK_TARGET_COOLDOWN stored out (1/0; the value is uniform(2400, 3600)).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-TARGET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BREEDING             BINARY-LONG.
 01 L-INWATER              BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-TAME                 BINARY-LONG.
 01 L-ANGRY                BINARY-LONG.
 01 L-CDPRESENT            BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-HOSTILE              BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-SETCD                BINARY-LONG.
 PROCEDURE DIVISION USING L-BREEDING L-INWATER L-BABY L-TAME L-ANGRY L-CDPRESENT L-ROLL L-HOSTILE L-TARGET L-SETCD.
     MOVE 0 TO L-TARGET
     MOVE 0 TO L-SETCD
     IF L-BREEDING = 1 OR L-INWATER = 0 OR L-BABY = 1 OR L-TAME = 1
         GOBACK
     END-IF
     IF L-ANGRY = 1
         MOVE 1 TO L-TARGET
         GOBACK
     END-IF
     IF L-CDPRESENT = 1
         GOBACK
     END-IF
     MOVE 1 TO L-SETCD
     IF L-ROLL = 0 AND L-HOSTILE = 1
         MOVE 1 TO L-TARGET
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-TARGET.

*> 10.6 canStillUse: USING ATTACK_TARGET present, tame, squared distance from the start, squared distance to the target, line of sight, CHARGE_COOLDOWN present, out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-CHARGE-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TARGETP              BINARY-LONG.
 01 L-TAME                 BINARY-LONG.
 01 L-D2S                  FLOAT-LONG.
 01 L-D2T                  FLOAT-LONG.
 01 L-LOS                  BINARY-LONG.
 01 L-CCD                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TARGETP L-TAME L-D2S L-D2T L-LOS L-CCD L-OUT.
     MOVE 0 TO L-OUT
     IF L-TARGETP = 1 AND L-TAME = 0 AND L-D2S < 144 AND L-D2T < 121 AND L-LOS = 1 AND L-CCD = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-CHARGE-USE.

*> 10.6 start: chargeVelocity = normalize(target - own) x speed. USING dx dy dz speed, vx, vz, vy out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-CHARGE-VEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-SPEED L-VX L-VZ L-VY.
     MOVE 0 TO L-VX L-VY L-VZ
     COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ)
     IF WS-LEN > 0
         COMPUTE L-VX = L-DX / WS-LEN * L-SPEED
         COMPUTE L-VY = L-DY / WS-LEN * L-SPEED
         COMPUTE L-VZ = L-DZ / WS-LEN * L-SPEED
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-CHARGE-VEL.

*> 10.6 dealKnockBack: strength = clamp(speed x movement speed, 0.2, 2.0) + 0.25 x (speed amp + 1 - (slow amp + 1)); the force is strength x 2.0 (amps are 0 without the effect, else amplifier + 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-KNOCKBACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STRENGTH            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SPEED                FLOAT-LONG.
 01 L-ATTR                 FLOAT-LONG.
 01 L-SPEEDAMP             BINARY-LONG.
 01 L-SLOWAMP              BINARY-LONG.
 01 L-FORCE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-SPEED L-ATTR L-SPEEDAMP L-SLOWAMP L-FORCE.
     COMPUTE WS-STRENGTH = FUNCTION MIN(FUNCTION MAX(L-SPEED * L-ATTR, 0.2), 2.0) + 0.25 * (L-SPEEDAMP - L-SLOWAMP)
     COMPUTE L-FORCE = WS-STRENGTH * 2.0
     GOBACK.
 END PROGRAM Q7-NAU-KNOCKBACK.

*> 10.1 zombie nautilus variant: warm (1, priority 1, in tag spawns_coral_variant_zombie_nautilus) beats temperate (0, priority 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-NAU-VARIANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WARM                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WARM L-OUT.
     MOVE 0 TO L-OUT
     IF L-WARM = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-NAU-VARIANT.

*> 11 per-mob water controls. USING mob key, max turn x, max turn y, in-water modifier, outside modifier, applyGravity, look control yaw limit, breaching navigation.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-CTRL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-MAXX                 BINARY-LONG.
 01 L-MAXY                 BINARY-LONG.
 01 L-INW                  FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 01 L-GRAV                 BINARY-LONG.
 01 L-LOOK                 BINARY-LONG.
 01 L-BREACH               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-MAXX L-MAXY L-INW L-OUT L-GRAV L-LOOK L-BREACH.
     MOVE 85 TO L-MAXX
     MOVE 10 TO L-MAXY
     MOVE 0 TO L-BREACH
     EVALUATE L-KEY
         WHEN "dolphin"
             MOVE 0.02 TO L-INW
             MOVE 0.1 TO L-OUT
             MOVE 1 TO L-GRAV
             MOVE 10 TO L-LOOK
             MOVE 1 TO L-BREACH
         WHEN "axolotl"
             MOVE 0.1 TO L-INW
             MOVE 0.5 TO L-OUT
             MOVE 0 TO L-GRAV
             MOVE 20 TO L-LOOK
         WHEN OTHER
             MOVE 0.011 TO L-INW
             MOVE 0 TO L-OUT
             MOVE 1 TO L-GRAV
             MOVE 10 TO L-LOOK
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-CTRL.

*> 11 getTurningSpeedFactor = 1 - clamp((angle - 10) / 50, 0, 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-TURN-FACTOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ANGLE                FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-ANGLE L-OUT.
     COMPUTE L-OUT = 1 - FUNCTION MIN(FUNCTION MAX((L-ANGLE - 10) / 50, 0), 1)
     GOBACK.
 END PROGRAM Q7-TURN-FACTOR.

*> 11 look control: USING wrapDegrees(head - body), the limit, the body yaw change out (-4, 0 or +4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-BODY-TURN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFF                 FLOAT-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFF L-MAX L-OUT.
     MOVE 0 TO L-OUT
     EVALUATE TRUE
         WHEN L-DIFF < 0 - L-MAX
             MOVE -4 TO L-OUT
         WHEN L-DIFF > L-MAX
             MOVE 4 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q7-BODY-TURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-CAN-UPDATE-PATH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BREACH               BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BREACH L-LIQUID L-OUT.
     MOVE 0 TO L-OUT
     IF L-BREACH = 1 OR L-LIQUID = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q7-CAN-UPDATE-PATH.

*> 4.2 the dolphin's vertical drift: the control's +0.005 in water, travelInWater's -0.005 only without an attack target.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q7-DOLPHIN-VY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TARGET               BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-TARGET L-OUT.
     MOVE 0.005 TO L-OUT
     IF L-TARGET = 0
         COMPUTE L-OUT = L-OUT - 0.005
     END-IF
     GOBACK.
 END PROGRAM Q7-DOLPHIN-VY.
