*> Residual mob questions, part 5 (docs/protocol/44-residual-mob-questions-5-overworld-hostile.md; lane 002-lane-p49i, T22520 and following): the pure rules of
*> section 2 (the enchantment value engine and the crossbow and arrow arithmetic). The programs take every random draw and every world fact as an argument, so
*> the rule is exact and a test feeds the values the document names. Floats are FLOAT-LONG; a comparison with a draw goes through millionths (FLOAT-LONG compares
*> are fuzzy).
*>   Q5-LEVEL-VALUE USING kind, a, b, level, out      LevelBasedValue: 1 constant a; 2 linear base a, per level above the first b; 3 levels_squared (level x level + a);
*>                                                    4 exponent (a ^ b); 5 fraction (a / b, 0 when b is 0)
*>   Q5-CLAMP-VALUE USING value, min, max, out        the clamped level-based value
*>   Q5-LOOKUP-VALUE USING table, size, fallback, level, out
*>   Q5-VALUE-EFFECT USING op, v1, v2, current, out   1 add (current + v1), 2 multiply, 3 set (v1), 4 scale_exponentially (current x v1 ^ v2)
*>   Q5-REMOVE-BINOMIAL USING current, chance, draws, gaussian, out
*>   Q5-RESULT USING kind, value, out                 the clamps after the walk of the enchantments: 1 count, 2 spread, 3 piercing, 4 charge time, 5 ammo use
*>   Q5-CHARGE-TICKS USING quick charge level, ticks out
*>   Q5-CHARGE-PHASE USING elapsed, duration, phase out
*>   Q5-DRAW-COUNT USING projectile_count value, server, n out
*>   Q5-USE-AMMO USING forced free, infinite materials, server, cost, ammo count, result out, taken out
*>   Q5-SHOOT-ANGLE USING n, spread, i, angle out
*>   Q5-SHOT-PITCH USING i, r, pitch out
*>   Q5-CROSSBOW-POWER USING player use, firework, power out, durability out
*>   Q5-MONSTER-AMMO USING off hand fits, main hand fits, source out
*>   Q5-CROSSBOW-CRIT USING shooter is a player, crit out
*>   Q5-PIERCE-HIT USING pierce level, struck count, hit out, discard out
*>   Q5-ARROW-DAMAGE USING speed, base damage, damage out;  Q5-CRIT-BOUND USING damage, bound out
*>   Q5-AIM-DY USING target y at one third, projectile y, horizontal distance, dy out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-LEVEL-VALUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-A L-B L-LEVEL L-OUT.
     MOVE 0 TO L-OUT
     EVALUATE L-KIND
         WHEN 1
             MOVE L-A TO L-OUT
         WHEN 2
             COMPUTE L-OUT = L-A + L-B * (L-LEVEL - 1)
         WHEN 3
             COMPUTE L-OUT = L-LEVEL * L-LEVEL + L-A
         WHEN 4
             COMPUTE L-OUT = L-A ** L-B
         WHEN 5
             IF L-B NOT = 0
                 COMPUTE L-OUT = L-A / L-B
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-LEVEL-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-CLAMP-VALUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-MIN                  FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE L-MIN L-MAX L-OUT.
     MOVE L-VALUE TO L-OUT
     IF L-VALUE < L-MIN
         MOVE L-MIN TO L-OUT
     END-IF
     IF L-VALUE > L-MAX
         MOVE L-MAX TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q5-CLAMP-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-LOOKUP-VALUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TABLE.
    05 L-ENTRY             FLOAT-LONG OCCURS 16 TIMES.
 01 L-SIZE                 BINARY-LONG.
 01 L-FALLBACK             FLOAT-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-TABLE L-SIZE L-FALLBACK L-LEVEL L-OUT.
     MOVE L-FALLBACK TO L-OUT
     IF L-LEVEL >= 1 AND L-LEVEL <= L-SIZE
         MOVE L-ENTRY(L-LEVEL) TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q5-LOOKUP-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-VALUE-EFFECT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OP                   BINARY-LONG.
 01 L-V1                   FLOAT-LONG.
 01 L-V2                   FLOAT-LONG.
 01 L-CURRENT              FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-OP L-V1 L-V2 L-CURRENT L-OUT.
     MOVE L-CURRENT TO L-OUT
     EVALUATE L-OP
         WHEN 1
             COMPUTE L-OUT = L-CURRENT + L-V1
         WHEN 2
             COMPUTE L-OUT = L-CURRENT * L-V1
         WHEN 3
             MOVE L-V1 TO L-OUT
         WHEN 4
             COMPUTE L-OUT = L-CURRENT * (L-V1 ** L-V2)
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-VALUE-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-REMOVE-BINOMIAL.
*> USING current (c), chance (p), draws (one nextFloat per iteration of the small branch), gaussian (the nextGaussian of the large branch), out (c - count).
*> Small branch (c <= 128, or c p < 20, or c (1 - p) < 20): the number of integers i = 0, 1, ... with i < c for which the draw of that iteration is below p.
*> Large branch: mean = floor(c p), sd = sqrt(c p (1 - p)), count = round(mean + gaussian sd) clamped to 0 to int(c).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CP                  FLOAT-LONG.
 01 WS-CQ                  FLOAT-LONG.
 01 WS-MEAN                FLOAT-LONG.
 01 WS-SD                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DRAW-M              BINARY-DOUBLE.
 01 WS-P-M                 BINARY-DOUBLE.
 01 WS-SMALL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CURRENT              FLOAT-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 129 TIMES.
 01 L-GAUSSIAN             FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-CURRENT L-CHANCE L-DRAWS L-GAUSSIAN L-OUT.
     COMPUTE WS-CP = L-CURRENT * L-CHANCE
     COMPUTE WS-CQ = L-CURRENT * (1 - L-CHANCE)
     MOVE 0 TO WS-SMALL WS-COUNT
     IF L-CURRENT <= 128.0 OR WS-CP < 20.0 OR WS-CQ < 20.0
         MOVE 1 TO WS-SMALL
     END-IF
     IF WS-SMALL = 1
*>       The iterations i = 0 .. ceil(c) - 1 (i < c).
         COMPUTE WS-N = 0 - FUNCTION INTEGER(0 - L-CURRENT)
         COMPUTE WS-P-M = L-CHANCE * 1000000
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             COMPUTE WS-DRAW-M = L-DRAW(WS-I) * 1000000
             IF WS-DRAW-M < WS-P-M
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     ELSE
         COMPUTE WS-MEAN = FUNCTION INTEGER(WS-CP)
         COMPUTE WS-SD = FUNCTION SQRT(WS-CP * (1 - L-CHANCE))
         COMPUTE WS-X = WS-MEAN + L-GAUSSIAN * WS-SD
         COMPUTE WS-COUNT = FUNCTION INTEGER(WS-X + 0.5)
         MOVE FUNCTION INTEGER-PART(L-CURRENT) TO WS-MAX
         IF WS-COUNT < 0
             MOVE 0 TO WS-COUNT
         END-IF
         IF WS-COUNT > WS-MAX
             MOVE WS-MAX TO WS-COUNT
         END-IF
     END-IF
     COMPUTE L-OUT = L-CURRENT - WS-COUNT
     GOBACK.
 END PROGRAM Q5-REMOVE-BINOMIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-RESULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-VALUE L-OUT.
     MOVE FUNCTION INTEGER-PART(L-VALUE) TO WS-INT
     EVALUATE L-KIND
         WHEN 1
         WHEN 3
*>           Projectile count and piercing: max(0, int(value)), the float truncated toward zero.
             IF WS-INT < 0
                 MOVE 0 TO WS-INT
             END-IF
             MOVE WS-INT TO L-OUT
         WHEN 2
         WHEN 4
*>           Spread and charge time: max(0.0, value).
             MOVE L-VALUE TO L-OUT
             IF L-VALUE < 0
                 MOVE 0 TO L-OUT
             END-IF
         WHEN OTHER
*>           Ammo use: int(value), no lower clamp.
             MOVE WS-INT TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-CHARGE-TICKS.
*> getChargeDuration (2.3 step 1): floor(max(0, 1.25 + quick charge effect) x 20) with the effect linear(-0.25, -0.25) of the level (none at level 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND-LINEAR         BINARY-LONG VALUE 2.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-KIND-CHARGE         BINARY-LONG VALUE 4.
 01 WS-BASE                FLOAT-LONG VALUE -0.25.
 01 WS-PER                 FLOAT-LONG VALUE -0.25.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-START               FLOAT-LONG VALUE 1.25.
 01 WS-EFFECT              FLOAT-LONG.
 01 WS-SECONDS             FLOAT-LONG.
 01 WS-CLAMPED             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-TICKS.
     MOVE WS-START TO WS-SECONDS
     IF L-LEVEL > 0
         CALL "Q5-LEVEL-VALUE" USING WS-KIND-LINEAR WS-BASE WS-PER L-LEVEL WS-EFFECT
         CALL "Q5-VALUE-EFFECT" USING WS-OP-ADD WS-EFFECT WS-ZERO WS-START WS-SECONDS
     END-IF
     CALL "Q5-RESULT" USING WS-KIND-CHARGE WS-SECONDS WS-CLAMPED
     COMPUTE L-TICKS = FUNCTION INTEGER(WS-CLAMPED * 20 + 0.0000001)
     GOBACK.
 END PROGRAM Q5-CHARGE-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-CHARGE-PHASE.
*> onUseTick (2.3 step 3) from the elapsed use ticks and the charge duration: progress = elapsed / duration. Phase 0: below 0.2 (the sound flags are reset),
*> 1: from 0.2 (the start sound), 2: from 0.5 (the middle sound), 3: from 1 (load the projectiles). A duration of 0 makes progress NaN at elapsed 0 (phase 0)
*> and +Infinity from elapsed 1 (phase 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ELAPSED              BINARY-LONG.
 01 L-DURATION             BINARY-LONG.
 01 L-PHASE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ELAPSED L-DURATION L-PHASE.
     MOVE 0 TO L-PHASE
     EVALUATE TRUE
         WHEN L-DURATION = 0
             IF L-ELAPSED >= 1
                 MOVE 3 TO L-PHASE
             END-IF
         WHEN L-ELAPSED >= L-DURATION
             MOVE 3 TO L-PHASE
         WHEN L-ELAPSED * 2 >= L-DURATION
             MOVE 2 TO L-PHASE
         WHEN L-ELAPSED * 5 >= L-DURATION
             MOVE 1 TO L-PHASE
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-CHARGE-PHASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-DRAW-COUNT.
*> draw (2.4): n = max(0, int(projectile_count value)) on a server level, 1 elsewhere (the value is 1 + 2 x multishot level on a server).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND-COUNT          BINARY-LONG VALUE 1.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-SERVER L-N.
     MOVE 1 TO L-N
     IF L-SERVER = 1
         CALL "Q5-RESULT" USING WS-KIND-COUNT L-VALUE WS-R
         MOVE WS-R TO L-N
     END-IF
     GOBACK.
 END PROGRAM Q5-DRAW-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-USE-AMMO.
*> useAmmo (2.4): cost 0 when forced free, the shooter has infinite materials or the level is not a server; else the processed ammo_use cost. A cost above the
*> stack count gives result 0 (empty); cost 0 gives result 1 (a copy of count 1, intangible); otherwise result 2 (cost items split off) with taken = cost.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FREE                 BINARY-LONG.
 01 L-INFINITE             BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-TAKEN                BINARY-LONG.
 PROCEDURE DIVISION USING L-FREE L-INFINITE L-SERVER L-COST L-COUNT L-RESULT L-TAKEN.
     MOVE L-COST TO WS-COST
     IF L-FREE = 1 OR L-INFINITE = 1 OR L-SERVER = 0
         MOVE 0 TO WS-COST
     END-IF
     MOVE 0 TO L-TAKEN
     EVALUATE TRUE
         WHEN WS-COST > L-COUNT
             MOVE 0 TO L-RESULT
         WHEN WS-COST = 0
             MOVE 1 TO L-RESULT
         WHEN OTHER
             MOVE 2 TO L-RESULT
             MOVE WS-COST TO L-TAKEN
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-USE-AMMO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-SHOOT-ANGLE.
*> shoot (2.5): s = 0 for n = 1, else 2 spread / (n - 1); b = ((n - 1) mod 2) s / 2; angle_i = b + (-1)^i floor((i + 1) / 2) s (degrees).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-SPREAD               FLOAT-LONG.
 01 L-I                    BINARY-LONG.
 01 L-ANGLE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-N L-SPREAD L-I L-ANGLE.
     MOVE 0 TO WS-S
     IF L-N > 1
         COMPUTE WS-S = 2 * L-SPREAD / (L-N - 1)
     END-IF
     COMPUTE WS-B = FUNCTION MOD(L-N - 1, 2) * WS-S / 2
     COMPUTE WS-K = FUNCTION INTEGER((L-I + 1) / 2)
     IF FUNCTION MOD(L-I, 2) = 0
         COMPUTE L-ANGLE = WS-B + WS-K * WS-S
     ELSE
         COMPUTE L-ANGLE = WS-B - WS-K * WS-S
     END-IF
     GOBACK.
 END PROGRAM Q5-SHOOT-ANGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-SHOT-PITCH.
*> getShotPitch (2.6): 1.0 for i = 0 (r is not drawn); else base + 1 / (0.5 r + 1.8), base 0.63 for an odd i and 0.43 for an even one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 PROCEDURE DIVISION USING L-I L-R L-PITCH.
     MOVE 1.0 TO L-PITCH
     IF L-I > 0
         MOVE 0.43 TO WS-BASE
         IF FUNCTION MOD(L-I, 2) = 1
             MOVE 0.63 TO WS-BASE
         END-IF
         COMPUTE L-PITCH = WS-BASE + 1 / (0.5 * L-R + 1.8)
     END-IF
     GOBACK.
 END PROGRAM Q5-SHOT-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-CROSSBOW-POWER.
*> The power of a shot and the durability it costs (2.3 step 6, 2.5): a player's use fires at 3.15, or 1.6 with a firework rocket charged; a mob (performCrossbowAttack)
*> always passes 1.6. The durability is 1, or 3 for a firework rocket.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-FIREWORK             BINARY-LONG.
 01 L-POWER                FLOAT-LONG.
 01 L-DURABILITY           BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-FIREWORK L-POWER L-DURABILITY.
     MOVE 1.6 TO L-POWER
     IF L-PLAYER = 1 AND L-FIREWORK = 0
         MOVE 3.15 TO L-POWER
     END-IF
     MOVE 1 TO L-DURABILITY
     IF L-FIREWORK = 1
         MOVE 3 TO L-DURABILITY
     END-IF
     GOBACK.
 END PROGRAM Q5-CROSSBOW-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-MONSTER-AMMO.
*> Monster.getProjectile (2.3 step 7): the held projectile is the off-hand stack when it fits the weapon, else the main-hand stack when it fits (source 1 off hand,
*> 2 main hand); when neither does, a fresh arrow stack (source 0), so a monster always has ammunition.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OFF                  BINARY-LONG.
 01 L-MAIN                 BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-OFF L-MAIN L-SOURCE.
     EVALUATE TRUE
         WHEN L-OFF = 1
             MOVE 1 TO L-SOURCE
         WHEN L-MAIN = 1
             MOVE 2 TO L-SOURCE
         WHEN OTHER
             MOVE 0 TO L-SOURCE
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-MONSTER-AMMO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-CROSSBOW-CRIT.
*> The crit rule of 2.6 (corrects 17 section 3.9): an arrow is a crit arrow when the shooter is a player.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-CRIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-CRIT.
     MOVE 0 TO L-CRIT
     IF L-PLAYER = 1
         MOVE 1 TO L-CRIT
     END-IF
     GOBACK.
 END PROGRAM Q5-CROSSBOW-CRIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-PIERCE-HIT.
*> onHitEntity (2.7 step 2): with a pierce level above 0 the arrow keeps the set of struck entities; while it holds fewer than level + 1 the entity is added and the hit
*> goes on (hit 1, discard 0), else the arrow is discarded and the hit does nothing. Without piercing the hit counts and the arrow is discarded.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-STRUCK               BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 01 L-DISCARD              BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-STRUCK L-HIT L-DISCARD.
     MOVE 1 TO L-HIT
     MOVE 1 TO L-DISCARD
     IF L-LEVEL > 0
         IF L-STRUCK < L-LEVEL + 1
             ADD 1 TO L-STRUCK
             MOVE 0 TO L-DISCARD
         ELSE
             MOVE 0 TO L-HIT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q5-PIERCE-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ARROW-DAMAGE.
*> damage = ceil(clamp(speed x base, 0, 2147483647)) (2.7 step 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SPEED                FLOAT-LONG.
 01 L-BASE                 FLOAT-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SPEED L-BASE L-DAMAGE.
     COMPUTE WS-X = L-SPEED * L-BASE
     IF WS-X < 0
         MOVE 0 TO WS-X
     END-IF
     IF WS-X > 2147483647
         MOVE 2147483647 TO WS-X
     END-IF
     COMPUTE L-DAMAGE = 0 - FUNCTION INTEGER(0 - WS-X + 0.0000001)
     GOBACK.
 END PROGRAM Q5-ARROW-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-CRIT-BOUND.
*> A crit arrow adds nextInt(damage / 2 + 2) (integer division): the bound of that draw.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DAMAGE               BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DAMAGE L-BOUND.
     COMPUTE L-BOUND = FUNCTION INTEGER(L-DAMAGE / 2) + 2
     GOBACK.
 END PROGRAM Q5-CRIT-BOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-AIM-DY.
*> The vertical component of a mob's aim (2.6): dy = target.getY(1/3) - projectile.y + h x 0.2 (the float 0.2 widened: 0.20000000298).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TARGET-Y             FLOAT-LONG.
 01 L-PROJECTILE-Y         FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-TARGET-Y L-PROJECTILE-Y L-H L-DY.
     COMPUTE L-DY = L-TARGET-Y - L-PROJECTILE-Y + L-H * 0.20000000298
     GOBACK.
 END PROGRAM Q5-AIM-DY.

*> ---------------------------------------------------------------------------------------------------------------------------------------------------------
*> Section 3: the warden (WardenAi, TryToSniff, Digging, Emerging, WardenEntitySensor, AngerManagement).
*>   Q5-WARDEN-CONST USING code, out           1 dig 100, 2 emerge 134, 3 roar 84, 4 sniffing 84, 5 dig cooldown 1200, 6 disturbance expiry 100, 7 follow range 24,
*>                                             8 sensor scan rate 20, 9 sniff cooldown minimum 100, 10 maximum 200
*>   Q5-WARDEN-ACTIVITY USING emerging, roar target, dig cooldown, attack target, disturbance, sniffing (each 1 when the memory holds a value), activity out
*>                                             (the first valid of 1 EMERGE, 2 DIG, 3 ROAR, 4 FIGHT, 5 INVESTIGATE, 6 SNIFF, else 7 IDLE)
*>   Q5-WARDEN-BEHAVIOUR USING activity (0 CORE, 1 EMERGE ... 7 IDLE as above), slot, priority out, name out
*>   Q5-SNIFF-START USING sniffing registered, walk target registered, cooldown present, attackable present, disturbance present, ok out
*>   Q5-SNIFF-COOLDOWN USING draw (0 to 100), ticks out
*>   Q5-DIG-START USING on ground, in liquid, result out (0 cannot start, 1 digging pose, 2 agitated sound and stop at once)
*>   Q5-DIG-STOP USING removed, remove out
*>   Q5-EMERGE-START USING emerging present, walk target present, ok out;  Q5-EMERGE-STOP USING pose emerging, standing out
*>   Q5-WARDEN-PICK USING count, players table, accepted table, index out
*>   Q5-ANGER-LEVEL USING value, level out, angry out
*>   Q5-ANGER-INIT / -INCREASE / -CLEAR / -TICK / -TOP / -ACTIVE: AngerManagement over Q5ANGER.cpy

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-WARDEN-CONST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-OUT.
     EVALUATE L-CODE
         WHEN 1
             MOVE 100 TO L-OUT
         WHEN 2
             MOVE 134 TO L-OUT
         WHEN 3
             MOVE 84 TO L-OUT
         WHEN 4
             MOVE 84 TO L-OUT
         WHEN 5
             MOVE 1200 TO L-OUT
         WHEN 6
             MOVE 100 TO L-OUT
         WHEN 7
             MOVE 24 TO L-OUT
         WHEN 8
             MOVE 20 TO L-OUT
         WHEN 9
             MOVE 100 TO L-OUT
         WHEN OTHER
             MOVE 200 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-WARDEN-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-WARDEN-ACTIVITY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMERGING             BINARY-LONG.
 01 L-ROAR                 BINARY-LONG.
 01 L-DIG-COOLDOWN         BINARY-LONG.
 01 L-ATTACK               BINARY-LONG.
 01 L-DISTURBANCE          BINARY-LONG.
 01 L-SNIFFING             BINARY-LONG.
 01 L-ACTIVITY             BINARY-LONG.
 PROCEDURE DIVISION USING L-EMERGING L-ROAR L-DIG-COOLDOWN L-ATTACK L-DISTURBANCE L-SNIFFING L-ACTIVITY.
     EVALUATE TRUE
         WHEN L-EMERGING = 1
             MOVE 1 TO L-ACTIVITY
         WHEN L-ROAR = 0 AND L-DIG-COOLDOWN = 0
             MOVE 2 TO L-ACTIVITY
         WHEN L-ROAR = 1
             MOVE 3 TO L-ACTIVITY
         WHEN L-ATTACK = 1
             MOVE 4 TO L-ACTIVITY
         WHEN L-DISTURBANCE = 1
             MOVE 5 TO L-ACTIVITY
         WHEN L-SNIFFING = 1
             MOVE 6 TO L-ACTIVITY
         WHEN OTHER
             MOVE 7 TO L-ACTIVITY
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-WARDEN-ACTIVITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-WARDEN-BEHAVIOUR.
*> The behaviours of an activity in list order (3.1); the priority is the start priority of the list + slot - 1 (the priority rule). Slot 0 or one past the list: name spaces.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DATA.
    05 FILLER              PIC X(30) VALUE "0 1  0swim".
    05 FILLER              PIC X(30) VALUE "0 2  0look target setter".
    05 FILLER              PIC X(30) VALUE "0 3  0look at target sink".
    05 FILLER              PIC X(30) VALUE "0 4  0move to target sink".
    05 FILLER              PIC X(30) VALUE "1 1  5emerging".
    05 FILLER              PIC X(30) VALUE "2 1  0force unmount".
    05 FILLER              PIC X(30) VALUE "2 2  0digging".
    05 FILLER              PIC X(30) VALUE "3 1 10roar".
    05 FILLER              PIC X(30) VALUE "4 1 10dig cooldown setter".
    05 FILLER              PIC X(30) VALUE "4 2 10stop attacking".
    05 FILLER              PIC X(30) VALUE "4 3 10look at target".
    05 FILLER              PIC X(30) VALUE "4 4 10walk to target".
    05 FILLER              PIC X(30) VALUE "4 5 10sonic boom".
    05 FILLER              PIC X(30) VALUE "4 6 10melee".
    05 FILLER              PIC X(30) VALUE "5 1  5set roar target".
    05 FILLER              PIC X(30) VALUE "5 2  5walk to disturbance".
    05 FILLER              PIC X(30) VALUE "6 1  5set roar target".
    05 FILLER              PIC X(30) VALUE "6 2  5sniffing".
    05 FILLER              PIC X(30) VALUE "7 1 10set roar target".
    05 FILLER              PIC X(30) VALUE "7 2 10try to sniff".
    05 FILLER              PIC X(30) VALUE "7 3 10stroll group".
 01 WS-ROWS REDEFINES WS-DATA.
    05 WS-ROW              OCCURS 21 TIMES.
       10 WS-R-ACT         PIC 9.
       10 FILLER           PIC X.
       10 WS-R-SLOT        PIC 9.
       10 FILLER           PIC X.
       10 WS-R-START       PIC 99.
       10 WS-R-NAME        PIC X(24).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ACTIVITY             BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-PRIORITY             BINARY-LONG.
 01 L-NAME                 PIC X(24).
 PROCEDURE DIVISION USING L-ACTIVITY L-SLOT L-PRIORITY L-NAME.
     MOVE SPACES TO L-NAME
     MOVE -1 TO L-PRIORITY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 21
         IF WS-R-ACT(WS-I) = L-ACTIVITY AND WS-R-SLOT(WS-I) = L-SLOT
             MOVE WS-R-NAME(WS-I) TO L-NAME
             COMPUTE L-PRIORITY = WS-R-START(WS-I) + L-SLOT - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q5-WARDEN-BEHAVIOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-SNIFF-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SNIFFING-REG         BINARY-LONG.
 01 L-WALK-REG             BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-ATTACKABLE           BINARY-LONG.
 01 L-DISTURBANCE          BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SNIFFING-REG L-WALK-REG L-COOLDOWN L-ATTACKABLE L-DISTURBANCE L-OK.
     MOVE 0 TO L-OK
     IF L-SNIFFING-REG = 1 AND L-WALK-REG = 1 AND L-COOLDOWN = 0 AND L-ATTACKABLE = 1 AND L-DISTURBANCE = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q5-SNIFF-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-SNIFF-COOLDOWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-TICKS.
     COMPUTE L-TICKS = 100 + L-DRAW
     GOBACK.
 END PROGRAM Q5-SNIFF-COOLDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-DIG-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROUND               BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUND L-LIQUID L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE TRUE
         WHEN L-GROUND = 1
             MOVE 1 TO L-RESULT
         WHEN L-LIQUID = 1
             MOVE 2 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-DIG-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-DIG-STOP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REMOVED              BINARY-LONG.
 01 L-REMOVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-REMOVED L-REMOVE.
     MOVE 1 TO L-REMOVE
     IF L-REMOVED = 1
         MOVE 0 TO L-REMOVE
     END-IF
     GOBACK.
 END PROGRAM Q5-DIG-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-EMERGE-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMERGING             BINARY-LONG.
 01 L-WALK                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-EMERGING L-WALK L-OK.
     MOVE 0 TO L-OK
     IF L-EMERGING = 1 AND L-WALK = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q5-EMERGE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-EMERGE-STOP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMERGING-POSE        BINARY-LONG.
 01 L-STANDING             BINARY-LONG.
 PROCEDURE DIVISION USING L-EMERGING-POSE L-STANDING.
     MOVE 0 TO L-STANDING
     IF L-EMERGING-POSE = 1
         MOVE 1 TO L-STANDING
     END-IF
     GOBACK.
 END PROGRAM Q5-EMERGE-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-WARDEN-PICK.
*> USING count, players (PIC 9 per entry of the list sorted by squared distance: 1 a player), accepted (1 when canTargetEntity holds), index out (0 none): the first
*> accepted player, else the first accepted non-player (3.5 step 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-PLAYERS.
    05 L-PLAYER            PIC 9 OCCURS 64 TIMES.
 01 L-ACCEPTED.
    05 L-OK                PIC 9 OCCURS 64 TIMES.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-PLAYERS L-ACCEPTED L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR L-INDEX > 0
         IF L-PLAYER(WS-I) = 1 AND L-OK(WS-I) = 1
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR L-INDEX > 0
         IF L-OK(WS-I) = 1
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q5-WARDEN-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-LEVEL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-ANGRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-LEVEL L-ANGRY.
     MOVE 0 TO L-LEVEL L-ANGRY
     IF L-VALUE >= 40
         MOVE 1 TO L-LEVEL
     END-IF
     IF L-VALUE >= 80
         MOVE 2 TO L-LEVEL
         MOVE 1 TO L-ANGRY
     END-IF
     GOBACK.
 END PROGRAM Q5-ANGER-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-INIT.
*> USING Q5-ANGER, delay (the initial conversion delay, a random integer 0 to 2): an empty manager.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY Q5ANGER.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING Q5-ANGER L-DELAY.
     INITIALIZE Q5-ANGER
     MOVE L-DELAY TO AN-DELAY
     GOBACK.
 END PROGRAM Q5-ANGER-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-VALUE.
*> USING Q5-ANGER, entity id, value out (0 when the entity has no live entry), player out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY Q5ANGER.
 01 L-ID                   BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING Q5-ANGER L-ID L-VALUE L-PLAYER.
     MOVE 0 TO L-VALUE L-PLAYER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AN-LIVE-COUNT
         IF AN-L-ID(WS-I) = L-ID
             MOVE AN-L-VALUE(WS-I) TO L-VALUE
             MOVE AN-L-PLAYER(WS-I) TO L-PLAYER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q5-ANGER-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-BEFORE.
*> USING Q5-ANGER, entity a, entity b, result out: 1 when a sorts strictly before b (Sorter.compare): an angry entity (value >= 80) before a non-angry one, then a player
*> before a non-player, then the higher value first; equal entities compare 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VA                  BINARY-LONG.
 01 WS-VB                  BINARY-LONG.
 01 WS-PA                  BINARY-LONG.
 01 WS-PB                  BINARY-LONG.
 01 WS-AA                  BINARY-LONG.
 01 WS-AB                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 COPY Q5ANGER.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING Q5-ANGER L-A L-B L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "Q5-ANGER-VALUE" USING Q5-ANGER L-A WS-VA WS-PA
     CALL "Q5-ANGER-VALUE" USING Q5-ANGER L-B WS-VB WS-PB
     CALL "Q5-ANGER-LEVEL" USING WS-VA WS-LEVEL WS-AA
     CALL "Q5-ANGER-LEVEL" USING WS-VB WS-LEVEL WS-AB
     EVALUATE TRUE
         WHEN L-A = L-B
             CONTINUE
         WHEN WS-AA > WS-AB
             MOVE 1 TO L-RESULT
         WHEN WS-AA = WS-AB AND WS-PA > WS-PB
             MOVE 1 TO L-RESULT
         WHEN WS-AA = WS-AB AND WS-PA = WS-PB AND WS-VA > WS-VB
             MOVE 1 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM Q5-ANGER-BEFORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-SORT.
*> USING Q5-ANGER: sortAndUpdateHighestAnger. The highest anger is 0 with no suspect and the suspect's value with one; with several it is the maximum over the suspects
*> (the working assumption of 3.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 COPY Q5ANGER.
 PROCEDURE DIVISION USING Q5-ANGER.
     MOVE 0 TO AN-HIGHEST
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > AN-SUSPECT-COUNT
         MOVE AN-SUSPECT(WS-I) TO WS-ID
         MOVE WS-I TO WS-J
         MOVE 1 TO WS-R
         PERFORM UNTIL WS-J < 2 OR WS-R = 0
             COMPUTE WS-K = WS-J - 1
             CALL "Q5-ANGER-BEFORE" USING Q5-ANGER WS-ID AN-SUSPECT(WS-K) WS-R
             IF WS-R = 1
                 MOVE AN-SUSPECT(WS-K) TO AN-SUSPECT(WS-J)
                 SUBTRACT 1 FROM WS-J
             END-IF
         END-PERFORM
         MOVE WS-ID TO AN-SUSPECT(WS-J)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AN-SUSPECT-COUNT
         CALL "Q5-ANGER-VALUE" USING Q5-ANGER AN-SUSPECT(WS-I) WS-VALUE WS-PLAYER
         IF WS-VALUE > AN-HIGHEST
             MOVE WS-VALUE TO AN-HIGHEST
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q5-ANGER-SORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-DROP.
*> USING Q5-ANGER, entity id: removes the live entry and the suspect of the entity (no sort).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 COPY Q5ANGER.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING Q5-ANGER L-ID.
     PERFORM VARYING WS-I FROM AN-LIVE-COUNT BY -1 UNTIL WS-I < 1
         IF AN-L-ID(WS-I) = L-ID
             PERFORM VARYING WS-NEXT FROM WS-I BY 1 UNTIL WS-NEXT >= AN-LIVE-COUNT
                 MOVE AN-LIVE(WS-NEXT + 1) TO AN-LIVE(WS-NEXT)
             END-PERFORM
             SUBTRACT 1 FROM AN-LIVE-COUNT
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM AN-SUSPECT-COUNT BY -1 UNTIL WS-I < 1
         IF AN-SUSPECT(WS-I) = L-ID
             PERFORM VARYING WS-NEXT FROM WS-I BY 1 UNTIL WS-NEXT >= AN-SUSPECT-COUNT
                 MOVE AN-SUSPECT(WS-NEXT + 1) TO AN-SUSPECT(WS-NEXT)
             END-PERFORM
             SUBTRACT 1 FROM AN-SUSPECT-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q5-ANGER-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-INCREASE.
*> USING Q5-ANGER, entity id, player (1 or 0), amount, new value out: increaseAnger. new = min(150, old + amount); an entity without a live entry first takes the pending UUID
*> value (removed from that map and added to the new value, the cap not applied again) and joins the suspect list; the suspects are sorted.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-PL                  BINARY-LONG.
 LINKAGE SECTION.
 COPY Q5ANGER.
 01 L-ID                   BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING Q5-ANGER L-ID L-PLAYER L-AMOUNT L-NEW.
     MOVE 0 TO WS-L
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AN-LIVE-COUNT
         IF AN-L-ID(WS-I) = L-ID
             MOVE WS-I TO WS-L
         END-IF
     END-PERFORM
     IF WS-L > 0
         COMPUTE L-NEW = AN-L-VALUE(WS-L) + L-AMOUNT
         IF L-NEW > 150
             MOVE 150 TO L-NEW
         END-IF
         MOVE L-NEW TO AN-L-VALUE(WS-L)
     ELSE
         MOVE L-AMOUNT TO L-NEW
         IF L-NEW > 150
             MOVE 150 TO L-NEW
         END-IF
         PERFORM VARYING WS-I FROM AN-UUID-COUNT BY -1 UNTIL WS-I < 1
             IF AN-U-ID(WS-I) = L-ID
                 ADD AN-U-VALUE(WS-I) TO L-NEW
                 PERFORM VARYING WS-NEXT FROM WS-I BY 1 UNTIL WS-NEXT >= AN-UUID-COUNT
                     MOVE AN-U(WS-NEXT + 1) TO AN-U(WS-NEXT)
                 END-PERFORM
                 SUBTRACT 1 FROM AN-UUID-COUNT
             END-IF
         END-PERFORM
         ADD 1 TO AN-LIVE-COUNT
         MOVE L-ID TO AN-L-ID(AN-LIVE-COUNT)
         MOVE L-PLAYER TO AN-L-PLAYER(AN-LIVE-COUNT)
         MOVE L-NEW TO AN-L-VALUE(AN-LIVE-COUNT)
         ADD 1 TO AN-SUSPECT-COUNT
         MOVE L-ID TO AN-SUSPECT(AN-SUSPECT-COUNT)
     END-IF
     CALL "Q5-ANGER-SORT" USING Q5-ANGER
     GOBACK.
 END PROGRAM Q5-ANGER-INCREASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-CLEAR.
*> USING Q5-ANGER, entity id: clearAnger (the entry and the suspect go, the suspects are sorted).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY Q5ANGER.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING Q5-ANGER L-ID.
     CALL "Q5-ANGER-DROP" USING Q5-ANGER L-ID
     CALL "Q5-ANGER-SORT" USING Q5-ANGER
     GOBACK.
 END PROGRAM Q5-ANGER-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-TICK.
*> USING Q5-ANGER, status (per entity id 1 to 64: 0 not in the level, 1 valid, 2 removed by a kill or discard, 3 removed by a dimension change or an unload, 4 the filter
*> rejects it): tick(level, filter). The conversion delay counts down and at 0 or below every UUID entry whose entity is now found (status 1) moves to the live map and
*> the suspects and the delay resets to 2; every remaining UUID entry of value <= 1 is dropped, the others lose 1; every live entry whose entity is removed, whose value
*> is <= 1 or which the filter rejects is dropped, and one removed by a dimension change or an unload with value > 1 keeps value - 1 in the UUID map; the others lose 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 LINKAGE SECTION.
 COPY Q5ANGER.
 01 L-STATUS.
    05 L-ST                BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING Q5-ANGER L-STATUS.
     SUBTRACT 1 FROM AN-DELAY
     IF AN-DELAY <= 0
         PERFORM VARYING WS-I FROM AN-UUID-COUNT BY -1 UNTIL WS-I < 1
             IF L-ST(AN-U-ID(WS-I)) = 1
                 ADD 1 TO AN-LIVE-COUNT
                 MOVE AN-U-ID(WS-I) TO AN-L-ID(AN-LIVE-COUNT)
                 MOVE AN-U-PLAYER(WS-I) TO AN-L-PLAYER(AN-LIVE-COUNT)
                 MOVE AN-U-VALUE(WS-I) TO AN-L-VALUE(AN-LIVE-COUNT)
                 ADD 1 TO AN-SUSPECT-COUNT
                 MOVE AN-U-ID(WS-I) TO AN-SUSPECT(AN-SUSPECT-COUNT)
                 PERFORM VARYING WS-NEXT FROM WS-I BY 1 UNTIL WS-NEXT >= AN-UUID-COUNT
                     MOVE AN-U(WS-NEXT + 1) TO AN-U(WS-NEXT)
                 END-PERFORM
                 SUBTRACT 1 FROM AN-UUID-COUNT
             END-IF
         END-PERFORM
         MOVE 2 TO AN-DELAY
     END-IF
     PERFORM VARYING WS-I FROM AN-UUID-COUNT BY -1 UNTIL WS-I < 1
         IF AN-U-VALUE(WS-I) <= 1
             PERFORM VARYING WS-NEXT FROM WS-I BY 1 UNTIL WS-NEXT >= AN-UUID-COUNT
                 MOVE AN-U(WS-NEXT + 1) TO AN-U(WS-NEXT)
             END-PERFORM
             SUBTRACT 1 FROM AN-UUID-COUNT
         ELSE
             SUBTRACT 1 FROM AN-U-VALUE(WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM AN-LIVE-COUNT BY -1 UNTIL WS-I < 1
         MOVE AN-L-ID(WS-I) TO WS-ID
         MOVE L-ST(WS-ID) TO WS-STATUS
         IF WS-STATUS > 1 OR AN-L-VALUE(WS-I) <= 1
             IF WS-STATUS = 3 AND AN-L-VALUE(WS-I) > 1
                 ADD 1 TO AN-UUID-COUNT
                 MOVE WS-ID TO AN-U-ID(AN-UUID-COUNT)
                 MOVE AN-L-PLAYER(WS-I) TO AN-U-PLAYER(AN-UUID-COUNT)
                 COMPUTE AN-U-VALUE(AN-UUID-COUNT) = AN-L-VALUE(WS-I) - 1
             END-IF
             CALL "Q5-ANGER-DROP" USING Q5-ANGER WS-ID
         ELSE
             SUBTRACT 1 FROM AN-L-VALUE(WS-I)
         END-IF
     END-PERFORM
     CALL "Q5-ANGER-SORT" USING Q5-ANGER
     GOBACK.
 END PROGRAM Q5-ANGER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-TOP.
*> USING Q5-ANGER, status (as Q5-ANGER-TICK; 4 fails the filter), entity out (0 none): getTopSuspect, the first suspect in sorted order that passes the filter.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY Q5ANGER.
 01 L-STATUS.
    05 L-ST                BINARY-LONG OCCURS 64 TIMES.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING Q5-ANGER L-STATUS L-ENTITY.
     MOVE 0 TO L-ENTITY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AN-SUSPECT-COUNT OR L-ENTITY > 0
         IF L-ST(AN-SUSPECT(WS-I)) NOT = 4
             MOVE AN-SUSPECT(WS-I) TO L-ENTITY
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q5-ANGER-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q5-ANGER-ACTIVE.
*> USING Q5-ANGER, entity (0 for none), anger out: getActiveAnger, the highest anger for no entity, else that entity's value (0 when unknown).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 COPY Q5ANGER.
 01 L-ENTITY               BINARY-LONG.
 01 L-ANGER                BINARY-LONG.
 PROCEDURE DIVISION USING Q5-ANGER L-ENTITY L-ANGER.
     IF L-ENTITY = 0
         MOVE AN-HIGHEST TO L-ANGER
     ELSE
         CALL "Q5-ANGER-VALUE" USING Q5-ANGER L-ENTITY L-ANGER WS-PLAYER
     END-IF
     GOBACK.
 END PROGRAM Q5-ANGER-ACTIVE.
