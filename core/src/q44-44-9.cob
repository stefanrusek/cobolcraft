*> Rule functions of docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md (lane 002-lane-p49j-a, tasks T24100 to T24199) for the sections whose entities the core does
*> not have (display entities, interaction, cushion, mannequin, dried ghast and happy ghast) or whose arithmetic the earlier lanes left untested: each program is one deterministic
*> rule with its inputs passed in. Sections 1, 3 (loop), 4, 5.3, 5.4, 10 and 11 are built and tested by acc_us16_* (decor-44*.cob, dragon-44*.cob, thrown, crystal).
*>   Q9-STRAFE-YOFFSET dist out (1.2 step 5)         Q9-THUNDER-FIRE counter (2.1)            Q9-INSTANT amp harm inverted scale (3 instant effect arithmetic)
*>   Q9-CHECK-TICK (5.1)  Q9-HANG-CONFLICT (5.2)    Q9-FRAME-YAW (5.3 rendered yaw)         Q9-DISPLAY-* and Q9-TELEPORT-STEP (6)   Q9-TEXT-ALIGN (6.3)
*>   Q9-INTERACT-* (7)    Q9-MAN-DIM (8.2)          Q9-DRIED-* (9.1)                        Q9-FEED-SECONDS and Q9-AGE-UP (9.2)

*> 1.2 step 5: yOffset = min(0.4000000059604645 + dist / 80 - 1, 10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-STRAFE-YOFFSET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIST                 FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIST L-OUT.
     COMPUTE L-OUT = FUNCTION MIN(0.4000000059604645 + L-DIST / 80 - 1, 10)
     GOBACK.
 END PROGRAM Q9-STRAFE-YOFFSET.

*> 2.1 thunderHit default: the counter + 1; ignition (160 ticks) only when the new value is exactly 0; then 5.0 damage (ignite out 1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-THUNDER-FIRE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTER              BINARY-LONG.
 01 L-IGNITE               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTER L-IGNITE.
     ADD 1 TO L-COUNTER
     MOVE 0 TO L-IGNITE
     IF L-COUNTER = 0
         MOVE 1 TO L-IGNITE
         MOVE 160 TO L-COUNTER
     END-IF
     GOBACK.
 END PROGRAM Q9-THUNDER-FIRE.

*> 2.1 baseTick: while the counter is above 0 the entity burns (damage when counter mod 20 = 0 and not in lava) and the counter falls by 1; otherwise clearFire = min(0, counter).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-FIRE-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTER              BINARY-LONG.
 01 L-INLAVA               BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTER L-INLAVA L-DAMAGE.
     MOVE 0 TO L-DAMAGE
     IF L-COUNTER > 0
         IF FUNCTION MOD(L-COUNTER, 20) = 0 AND L-INLAVA = 0
             MOVE 1 TO L-DAMAGE
         END-IF
         SUBTRACT 1 FROM L-COUNTER
     ELSE
         COMPUTE L-COUNTER = FUNCTION MIN(0, L-COUNTER)
     END-IF
     GOBACK.
 END PROGRAM Q9-FIRE-TICK.

*> 3 HealOrHarmMobEffect.applyInstantaneousEffect: harm == inverted heals int(scale x (4 << amp) + 0.5), else damages int(scale x (6 << amp) + 0.5). USING amp, harm (1/0), inverted (1/0),
*> scale, amount out, kind out (1 heal, 2 damage).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-INSTANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-AMP                  BINARY-LONG.
 01 L-HARM                 BINARY-LONG.
 01 L-INVERTED             BINARY-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AMP L-HARM L-INVERTED L-SCALE L-AMOUNT L-KIND.
     IF L-HARM = L-INVERTED
         COMPUTE WS-BASE = 4 * 2 ** L-AMP
         MOVE 1 TO L-KIND
     ELSE
         COMPUTE WS-BASE = 6 * 2 ** L-AMP
         MOVE 2 TO L-KIND
     END-IF
     COMPUTE L-AMOUNT = FUNCTION INTEGER-PART(L-SCALE * WS-BASE + 0.5)
     GOBACK.
 END PROGRAM Q9-INSTANT.

*> 5.1: every server tick the check counter rises by 1; at 100 it is reset to 0 and the survival check is due (due out 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-CHECK-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-DUE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKS L-DUE.
     MOVE 0 TO L-DUE
     ADD 1 TO L-TICKS
     IF L-TICKS >= 100
         MOVE 0 TO L-TICKS
         MOVE 1 TO L-DUE
     END-IF
     GOBACK.
 END PROGRAM Q9-CHECK-TICK.

*> 5.2 canCoexist: another hanging entity conflicts when (same type and ignoreType is false) or same direction. USING same type, same direction, ignoreType, conflict out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-HANG-CONFLICT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAMETYPE             BINARY-LONG.
 01 L-SAMEDIR              BINARY-LONG.
 01 L-IGNORE               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SAMETYPE L-SAMEDIR L-IGNORE L-OUT.
     MOVE 0 TO L-OUT
     IF (L-SAMETYPE = 1 AND L-IGNORE = 0) OR L-SAMEDIR = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q9-HANG-CONFLICT.

*> 5.3 rendered yaw: wrapDegrees(180 + 90 x d2 + 45 x rotation + v); d2 SOUTH 0, WEST 1, NORTH 2, EAST 3, UP and DOWN -1; v 0, UP +90, DOWN -90. USING d2, vertical step (0, 1, -1), rotation, yaw out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-FRAME-YAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SUM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-D2                   BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-STEP L-ROT L-OUT.
     COMPUTE WS-SUM = 180 + 90 * L-D2 + 45 * L-ROT + 90 * L-STEP
     COMPUTE L-OUT = FUNCTION MOD(WS-SUM, 360)
     IF L-OUT >= 180
         SUBTRACT 360 FROM L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q9-FRAME-YAW.

*> 6.2 calculateInterpolationProgress: 1.0 when the duration is 0 or less, else clamp((tickCount - start + partial) / duration, 0, 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-DISPLAY-PROGRESS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICK                 BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-DURATION             BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-TICK L-START L-DURATION L-PARTIAL L-OUT.
     IF L-DURATION <= 0
         MOVE 1 TO L-OUT
     ELSE
         COMPUTE L-OUT = FUNCTION MIN(FUNCTION MAX((L-TICK - L-START + L-PARTIAL) / L-DURATION, 0), 1)
     END-IF
     GOBACK.
 END PROGRAM Q9-DISPLAY-PROGRESS.

*> 6.1 culling: noCulling when width or height is 0. Visible within (viewRange x 64 x viewScale)^2. teleport_duration is read back clamped to 0 to 59.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-DISPLAY-CULL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WIDTH                FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WIDTH L-HEIGHT L-OUT.
     MOVE 0 TO L-OUT
     IF L-WIDTH = 0 OR L-HEIGHT = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q9-DISPLAY-CULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-DISPLAY-RANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VIEW                 FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VIEW L-SCALE L-D2 L-OUT.
     COMPUTE WS-R = L-VIEW * 64 * L-SCALE
     MOVE 0 TO L-OUT
     IF L-D2 < WS-R * WS-R
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q9-DISPLAY-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-TELEPORT-CLAMP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     COMPUTE L-VALUE = FUNCTION MIN(FUNCTION MAX(L-VALUE, 0), 59)
     GOBACK.
 END PROGRAM Q9-TELEPORT-CLAMP.

*> 6.2.1 one client tick of the position interpolation: x becomes lerp(x, target, 1 / remaining); remaining falls by 1 (at 0 the entity sits on the target).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-TELEPORT-STEP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-TARGET               FLOAT-LONG.
 01 L-REMAINING            BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-TARGET L-REMAINING.
     IF L-REMAINING > 0
         COMPUTE L-X = L-X + (L-TARGET - L-X) / L-REMAINING
         SUBTRACT 1 FROM L-REMAINING
     END-IF
     GOBACK.
 END PROGRAM Q9-TELEPORT-STEP.

*> 6.3 text style flags: bit 8 left, then bit 16 right, neither centre. USING flags, align out (0 centre, 1 left, 2 right).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-TEXT-ALIGN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLAGS                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS L-OUT.
     MOVE 0 TO L-OUT
     EVALUATE TRUE
         WHEN FUNCTION MOD(FUNCTION INTEGER(L-FLAGS / 8), 2) = 1
             MOVE 1 TO L-OUT
         WHEN FUNCTION MOD(FUNCTION INTEGER(L-FLAGS / 16), 2) = 1
             MOVE 2 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q9-TEXT-ALIGN.

*> 7 attack: for a player the attack is recorded and the normal attack is skipped when response is false (skip out 1 = true); a non-player gives false.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-INTERACT-ATTACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-RESPONSE             BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-RESPONSE L-SKIP.
     MOVE 0 TO L-SKIP
     IF L-PLAYER = 1 AND L-RESPONSE = 0
         MOVE 1 TO L-SKIP
     END-IF
     GOBACK.
 END PROGRAM Q9-INTERACT-ATTACK.

*> 7 use: client SUCCESS (1) when response else CONSUME (2); the server always CONSUME (2) and records the interaction.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-INTERACT-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLIENT               BINARY-LONG.
 01 L-RESPONSE             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLIENT L-RESPONSE L-RESULT.
     MOVE 2 TO L-RESULT
     IF L-CLIENT = 1 AND L-RESPONSE = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM Q9-INTERACT-USE.

*> 8.2 mannequin dimensions by pose (0 standing, 1 crouching, 2 swimming, 3 fall_flying, 4 sleeping, 5 spin attack, 6 dying; other poses stand): width, height, eye height.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-MAN-DIM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POSE                 BINARY-LONG.
 01 L-W                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-EYE                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-POSE L-W L-H L-EYE.
     EVALUATE L-POSE
         WHEN 1
             MOVE 0.6 TO L-W
             MOVE 1.5 TO L-H
             MOVE 1.27 TO L-EYE
         WHEN 2 WHEN 3 WHEN 5
             MOVE 0.6 TO L-W
             MOVE 0.6 TO L-H
             MOVE 0.4 TO L-EYE
         WHEN 4
             MOVE 0.2 TO L-W
             MOVE 0.2 TO L-H
             MOVE 0.2 TO L-EYE
         WHEN 6
             MOVE 0.2 TO L-W
             MOVE 0.2 TO L-H
             MOVE 1.62 TO L-EYE
         WHEN OTHER
             MOVE 0.6 TO L-W
             MOVE 1.8 TO L-H
             MOVE 1.62 TO L-EYE
     END-EVALUATE
     GOBACK.
 END PROGRAM Q9-MAN-DIM.

*> 9.1 random tick: a block tick is scheduled in 5000 ticks when waterlogged or hydrated and none is scheduled (out 5000, else 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-DRIED-RANDOM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-HYDRATION            BINARY-LONG.
 01 L-SCHEDULED            BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-HYDRATION L-SCHEDULED L-DELAY.
     MOVE 0 TO L-DELAY
     IF (L-WATERLOGGED = 1 OR L-HYDRATION > 0) AND L-SCHEDULED = 0
         MOVE 5000 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM Q9-DRIED-RANDOM.

*> 9.1 block tick: not waterlogged: hydration falls by 1 when above 0. Waterlogged: below 3 it rises by 1 (transition sound), at 3 the block hatches (hatch out 1, the block is removed).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-DRIED-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-HYDRATION            BINARY-LONG.
 01 L-HATCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-HYDRATION L-HATCH.
     MOVE 0 TO L-HATCH
     IF L-WATERLOGGED = 0
         IF L-HYDRATION > 0
             SUBTRACT 1 FROM L-HYDRATION
         END-IF
     ELSE
         IF L-HYDRATION NOT = 3
             ADD 1 TO L-HYDRATION
         ELSE
             MOVE 1 TO L-HATCH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q9-DRIED-TICK.

*> 9.2 getSpeedUpSecondsWhenFeeding(a) = int(float(a / 20) x 0.1) with the integer division by 20 first. USING a, seconds out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-FEED-SECONDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-SECONDS.
     DIVIDE L-A BY 20 GIVING WS-Q
     COMPUTE WS-F = WS-Q * 0.1
     COMPUTE L-SECONDS = FUNCTION INTEGER-PART(WS-F)
     GOBACK.
 END PROGRAM Q9-FEED-SECONDS.

*> 9.2 AgeableMob.ageUp(seconds, forced): newAge = min(age + seconds x 20, 0); forced adds (newAge - oldAge) to forcedAge and sets forcedAgeTimer to 40 when it is 0; an age of exactly 0
*> becomes setAge(forcedAge). USING age, seconds, forced, forcedAge, forcedAgeTimer (all inout but seconds and forced).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-AGE-UP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 01 L-FORCED               BINARY-LONG.
 01 L-FORCEDAGE            BINARY-LONG.
 01 L-TIMER                BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-SECONDS L-FORCED L-FORCEDAGE L-TIMER.
     MOVE L-AGE TO WS-OLD
     COMPUTE L-AGE = FUNCTION MIN(L-AGE + L-SECONDS * 20, 0)
     IF L-FORCED = 1
         COMPUTE L-FORCEDAGE = L-FORCEDAGE + L-AGE - WS-OLD
         IF L-TIMER = 0
             MOVE 40 TO L-TIMER
         END-IF
     END-IF
     IF L-AGE = 0
         MOVE L-FORCEDAGE TO L-AGE
     END-IF
     GOBACK.
 END PROGRAM Q9-AGE-UP.

*> 9.3 canUseSlot(BODY): alive and not a baby. USING alive, baby, out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-GHAST-SLOT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALIVE                BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ALIVE L-BABY L-OUT.
     MOVE 0 TO L-OUT
     IF L-ALIVE = 1 AND L-BABY = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q9-GHAST-SLOT.

*> 9.6 restriction radius 64 (adult, empty BODY slot) else 32.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-GHAST-RADIUS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ADULT                BINARY-LONG.
 01 L-HARNESSED            BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ADULT L-HARNESSED L-OUT.
     MOVE 32 TO L-OUT
     IF L-ADULT = 1 AND L-HARNESSED = 0
         MOVE 64 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q9-GHAST-RADIUS.

*> 9.6 continuousHeal: 1.0 health when tickCount mod period = 0, period 20 in clouds or rain else 600. USING wet, tick, heal out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-GHAST-HEAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PERIOD              BINARY-LONG.
 LINKAGE SECTION.
 01 L-WET                  BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WET L-TICK L-OUT.
     MOVE 600 TO WS-PERIOD
     IF L-WET = 1
         MOVE 20 TO WS-PERIOD
     END-IF
     MOVE 0 TO L-OUT
     IF FUNCTION MOD(L-TICK, WS-PERIOD) = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q9-GHAST-HEAL.

*> 9.6 isInClouds (vertical part): y + height >= cloud height and y <= cloud height + 4.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-IN-CLOUDS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-CLOUD                FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-H L-CLOUD L-OUT.
     MOVE 0 TO L-OUT
     IF L-Y + L-H >= L-CLOUD AND L-Y <= L-CLOUD + 4
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q9-IN-CLOUDS.

*> 9.7 getRiddenInput: (strafe, vertical, forward) x (3.9000000953674316 x flying speed); f = cos(pitch), v = -sin(pitch), both x -0.5 when zza < 0; jumping adds 0.5 to v.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-GHAST-INPUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-XXA                  FLOAT-LONG.
 01 L-ZZA                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-JUMP                 BINARY-LONG.
 01 L-FLY                  FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-XXA L-ZZA L-PITCH L-JUMP L-FLY L-X L-Y L-Z.
     MOVE 0 TO WS-F WS-V
     IF L-ZZA NOT = 0
         COMPUTE WS-RAD = L-PITCH * 0.017453292
         COMPUTE WS-F = FUNCTION COS(WS-RAD)
         COMPUTE WS-V = 0 - FUNCTION SIN(WS-RAD)
         IF L-ZZA < 0
             COMPUTE WS-F = WS-F * -0.5
             COMPUTE WS-V = WS-V * -0.5
         END-IF
     END-IF
     IF L-JUMP = 1
         COMPUTE WS-V = WS-V + 0.5
     END-IF
     COMPUTE WS-K = 3.9000000953674316 * L-FLY
     COMPUTE L-X = L-XXA * WS-K
     COMPUTE L-Y = WS-V * WS-K
     COMPUTE L-Z = WS-F * WS-K
     GOBACK.
 END PROGRAM Q9-GHAST-INPUT.

*> 9.7 tickRidden: the yaw moves 8 percent of wrapDegrees(rider yaw - yaw) toward the rider.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-GHAST-YAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-RIDER                FLOAT-LONG.
 PROCEDURE DIVISION USING L-YAW L-RIDER.
     COMPUTE WS-D = L-RIDER - L-YAW
     COMPUTE WS-D = WS-D - 360 * FUNCTION INTEGER((WS-D + 180) / 360)
     COMPUTE L-YAW = L-YAW + WS-D * 0.08
     GOBACK.
 END PROGRAM Q9-GHAST-YAW.

*> 9.7 canBeCollidedWith: false for a baby or dead ghast; a player at or above its top (client) true; passengers and another happy ghast true; otherwise the still timeout.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-GHAST-COLLIDE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABYDEAD             BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-PASSENGERS           BINARY-LONG.
 01 L-OTHERGHAST           BINARY-LONG.
 01 L-STILL                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BABYDEAD L-ABOVE L-PASSENGERS L-OTHERGHAST L-STILL L-OUT.
     MOVE 0 TO L-OUT
     EVALUATE TRUE
         WHEN L-BABYDEAD = 1
             CONTINUE
         WHEN L-ABOVE = 1
             MOVE 1 TO L-OUT
         WHEN L-PASSENGERS > 0 AND L-OTHERGHAST = 1
             MOVE 1 TO L-OUT
         WHEN OTHER
             MOVE L-STILL TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q9-GHAST-COLLIDE.

*> 9.8 quad leash offsets: USING index 1 to 4, bounding width, height, x, y, z out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-GHAST-LEASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-W                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-INDEX L-W L-H L-X L-Y L-Z.
     COMPUTE WS-A = -0.03125 * L-W
     COMPUTE WS-B = 0.4375 * L-W
     COMPUTE WS-C = 0.46875 * L-W
     COMPUTE L-Y = 0.03125 * L-H
     EVALUATE L-INDEX
         WHEN 1
             COMPUTE L-X = 0 - WS-C
             COMPUTE L-Z = WS-B + WS-A
         WHEN 2
             COMPUTE L-X = 0 - WS-C
             COMPUTE L-Z = 0 - WS-B + WS-A
         WHEN 3
             MOVE WS-C TO L-X
             COMPUTE L-Z = 0 - WS-B + WS-A
         WHEN OTHER
             MOVE WS-C TO L-X
             COMPUTE L-Z = WS-B + WS-A
     END-EVALUATE
     GOBACK.
 END PROGRAM Q9-GHAST-LEASH.

*> 10 ServerBossEvent setters: USING field (1 progress, 2 name, 3 colour, 4 overlay, 5 darken, 6 music, 7 fog), changed, visible, operation out (0 none or 2 to 5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-BOSS-OP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIELD                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 01 L-OP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FIELD L-CHANGED L-VISIBLE L-OP.
     MOVE 0 TO L-OP
     IF L-CHANGED = 1 AND L-VISIBLE = 1
         EVALUATE L-FIELD
             WHEN 1
                 MOVE 2 TO L-OP
             WHEN 2
                 MOVE 3 TO L-OP
             WHEN 3 WHEN 4
                 MOVE 4 TO L-OP
             WHEN OTHER
                 MOVE 5 TO L-OP
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM Q9-BOSS-OP.

*> 10 makeInvulnerable: 220 invulnerable ticks, health maxHealth / 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-WITHER-INVULN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAX                  FLOAT-LONG.
 01 L-HEALTH               FLOAT-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX L-HEALTH L-TICKS.
     COMPUTE L-HEALTH = L-MAX / 3
     MOVE 220 TO L-TICKS
     GOBACK.
 END PROGRAM Q9-WITHER-INVULN.

*> 11.2 split: needs the shulker open and a successful teleport; p = (n - 1) / 5; a split when the draw is below p.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-SHULKER-SPLIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLOSED               BINARY-LONG.
 01 L-TELEPORTED           BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CLOSED L-TELEPORTED L-N L-DRAW L-OUT.
     MOVE 0 TO L-OUT
     IF L-CLOSED = 0 AND L-TELEPORTED = 1 AND L-DRAW < (L-N - 1) / 5
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q9-SHULKER-SPLIT.

*> 11.2 updatePeekAmount: target = raw x 0.01; the peek moves 0.05 per tick toward it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-SHULKER-PEEK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-OLD                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CUR                  FLOAT-LONG.
 01 L-RAW                  BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CUR L-RAW L-CHANGED.
     COMPUTE WS-T = L-RAW * 0.01
     MOVE L-CUR TO WS-OLD
     IF L-CUR > WS-T
         COMPUTE L-CUR = FUNCTION MIN(FUNCTION MAX(L-CUR - 0.05, WS-T), 1.0)
     ELSE
         IF L-CUR < WS-T
             COMPUTE L-CUR = FUNCTION MAX(FUNCTION MIN(L-CUR + 0.05, WS-T), 0)
         END-IF
     END-IF
     MOVE 0 TO L-CHANGED
     IF L-CUR NOT = WS-OLD
         MOVE 1 TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM Q9-SHULKER-PEEK.

*> 11.2 physicalPeek(p) = 0.5 - sin((0.5 + p) x pi) x 0.5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-SHULKER-PHYS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ANGLE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PEEK                 FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-PEEK L-OUT.
     COMPUTE WS-ANGLE = (0.5 + L-PEEK) * 3.141592653589793
     COMPUTE L-OUT = 0.5 - FUNCTION SIN(WS-ANGLE) * 0.5
     GOBACK.
 END PROGRAM Q9-SHULKER-PHYS.

*> 11.2 bullet: flightSteps = 10 + nextInt(5) x 10.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-BULLET-STEPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-OUT.
     COMPUTE L-OUT = 10 + L-DRAW * 10
     GOBACK.
 END PROGRAM Q9-BULLET-STEPS.

*> 11.2 bullet: the target delta grows x 1.025 clamped to -1..1 and the velocity moves a fifth of the way to it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q9-BULLET-VEL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DELTA                FLOAT-LONG.
 01 L-VEL                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DELTA L-VEL.
     COMPUTE L-DELTA = FUNCTION MIN(FUNCTION MAX(L-DELTA * 1.025, -1), 1)
     COMPUTE L-VEL = L-VEL + (L-DELTA - L-VEL) * 0.2
     GOBACK.
 END PROGRAM Q9-BULLET-VEL.
