*> Combat rules of docs/protocol/17 section 4 (US14; T2139 onward) as formula programs over integers: damage, speeds and fractions in thousandths
*> unless said otherwise, ticks in whole ticks (or thousandths of a tick where the name says delay). The damage entry point for the
*> player-versus-player and player-versus-entity path is TOOL-HURT-PIPELINE (section 4.4); the mobs lane plugs a mob victim or attacker into
*> the same programs (a mob has no difficulty scaling: scales = 0).
*>
*> Section 4.1:
*>   TOOL-ATTACK-SPEED USING item modifier (e.g. -2400), haste levels (amplifier + 1, 0 none), fatigue levels, attack speed out (4.0 + modifier,
*>     times 1 + 0.1 haste, times 1 - 0.1 fatigue)
*>   TOOL-ATTACK-DELAY USING attack speed, delay out (thousandths of a tick: 20 / A)
*>   TOOL-ATTACK-ATTR USING item bonus, strength levels, weakness levels, attack damage out (1.0 + bonus + 3.0 S - 4.0 W)
*>   TOOL-ATTACK-SCALE USING ticker, a (500 for an attack), delay (thousandths of a tick), scale out (clamp((ticker + a) / D, 0, 1))
*>   TOOL-ATTACK-REFUSED USING ticker, margin, delay, minimum attack charge, refused out ((ticker + margin) / D under the minimum)
*>   TOOL-ATTACK-IN-RANGE USING distance, reach, margin (thousandths of a block), in range out
*>   TOOL-ATTACK-PACKET USING spectator, in range, piercing weapon, target kind (0 other, 1 item entity, 2 experience orb, 3 the player itself,
*>     4 arrow that is not attackable), too soon, result out (0 ignored, 1 attack, 2 disconnect)
*> Section 4.2:
*>   TOOL-ATTACK-CALC USING base damage, enchantment damage (E before the scale), scale, sprinting, fall distance above 0, on ground, on a
*>     climbable, in water, blinded, passenger, target is living, item bonus (mace), total out, crit out, sprint knockback out, full strength out
*> Section 4.3:
*>   TOOL-SWEEP-CHECK USING full strength, crit, sprint knockback, on ground, horizontal speed, movement speed, sword, sweep out
*>   TOOL-SWEEPING-RATIO USING Sweeping Edge level, ratio out (L / (L + 1))
*>   TOOL-SWEEP-DAMAGE USING damage, ratio, sweep damage out (1.0 + ratio x damage)
*>   TOOL-SWEEP-VICTIM USING is the attacker, is the target, allied, marker armor stand, squared distance to the target, hit out (under 9.0)
*>   TOOL-SWEEP-KNOCKBACK USING yaw (thousandths of a degree), strength out (400), x out (sin yaw), z out (-cos yaw)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ATTACK-SPEED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODIFIER             BINARY-LONG.
 01 L-HASTE                BINARY-LONG.
 01 L-FATIGUE              BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 PROCEDURE DIVISION USING L-MODIFIER L-HASTE L-FATIGUE L-SPEED.
     COMPUTE L-SPEED = (4000 + L-MODIFIER) * (1000 + 100 * L-HASTE) * (1000 - 100 * L-FATIGUE) / 1000000
     GOBACK.
 END PROGRAM TOOL-ATTACK-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ATTACK-DELAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPEED                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-SPEED L-DELAY.
     COMPUTE L-DELAY = 20000000 / L-SPEED
     GOBACK.
 END PROGRAM TOOL-ATTACK-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ATTACK-ATTR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BONUS                BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-WEAKNESS             BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-BONUS L-STRENGTH L-WEAKNESS L-DAMAGE.
     COMPUTE L-DAMAGE = 1000 + L-BONUS + 3000 * L-STRENGTH - 4000 * L-WEAKNESS
     GOBACK.
 END PROGRAM TOOL-ATTACK-ATTR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ATTACK-SCALE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKER               BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKER L-A L-DELAY L-SCALE.
     COMPUTE L-SCALE = (L-TICKER * 1000 + L-A) * 1000 / L-DELAY
     IF L-SCALE > 1000
         MOVE 1000 TO L-SCALE
     END-IF
     IF L-SCALE < 0
         MOVE 0 TO L-SCALE
     END-IF
     GOBACK.
 END PROGRAM TOOL-ATTACK-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ATTACK-REFUSED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FRACTION            BINARY-LONG.
 LINKAGE SECTION.
 01 L-TICKER               BINARY-LONG.
 01 L-MARGIN               BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-MINIMUM              BINARY-LONG.
 01 L-REFUSED              BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKER L-MARGIN L-DELAY L-MINIMUM L-REFUSED.
     COMPUTE WS-FRACTION = (L-TICKER + L-MARGIN) * 1000000 / L-DELAY
     MOVE 0 TO L-REFUSED
     IF WS-FRACTION < L-MINIMUM
         MOVE 1 TO L-REFUSED
     END-IF
     GOBACK.
 END PROGRAM TOOL-ATTACK-REFUSED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ATTACK-IN-RANGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-REACH                BINARY-LONG.
 01 L-MARGIN               BINARY-LONG.
 01 L-IN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-REACH L-MARGIN L-IN.
     MOVE 0 TO L-IN
     IF L-DISTANCE <= L-REACH + L-MARGIN
         MOVE 1 TO L-IN
     END-IF
     GOBACK.
 END PROGRAM TOOL-ATTACK-IN-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ATTACK-PACKET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-IN-RANGE             BINARY-LONG.
 01 L-PIERCING             BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-SOON                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECTATOR L-IN-RANGE L-PIERCING L-KIND L-SOON L-RESULT.
     EVALUATE TRUE
         WHEN L-SPECTATOR = 1 OR L-IN-RANGE = 0 OR L-PIERCING = 1
             MOVE 0 TO L-RESULT
         WHEN L-KIND > 0
             MOVE 2 TO L-RESULT
         WHEN L-SOON = 1
             MOVE 0 TO L-RESULT
         WHEN OTHER
             MOVE 1 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-ATTACK-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ATTACK-CALC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                BINARY-DOUBLE.
 01 WS-E                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-ENCHANT              BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 01 L-SPRINTING            BINARY-LONG.
 01 L-FALL                 BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-CLIMB                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-BLIND                BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-BONUS                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-CRIT                 BINARY-LONG.
 01 L-SPRINT-KB            BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-ENCHANT L-SCALE L-SPRINTING L-FALL L-GROUND L-CLIMB L-WATER L-BLIND L-PASSENGER
         L-LIVING L-BONUS L-TOTAL L-CRIT L-SPRINT-KB L-FULL.
     MOVE 0 TO L-TOTAL L-CRIT L-SPRINT-KB L-FULL
     IF L-SCALE > 900
         MOVE 1 TO L-FULL
     END-IF
     COMPUTE WS-E = L-SCALE * L-ENCHANT / 1000
     COMPUTE WS-BASE = L-BASE * (200 + 800 * L-SCALE * L-SCALE / 1000000) / 1000
     IF L-BASE > 0 OR WS-E > 0
         IF L-FULL = 1 AND L-SPRINTING = 1
             MOVE 1 TO L-SPRINT-KB
         END-IF
         COMPUTE WS-BASE = WS-BASE + L-BONUS
         IF L-FULL = 1 AND L-FALL = 1 AND L-GROUND = 0 AND L-CLIMB = 0 AND L-WATER = 0 AND L-BLIND = 0 AND L-PASSENGER = 0
                 AND L-LIVING = 1 AND L-SPRINTING = 0
             MOVE 1 TO L-CRIT
             COMPUTE WS-BASE = WS-BASE * 3 / 2
         END-IF
         COMPUTE L-TOTAL = WS-BASE + WS-E
     END-IF
     GOBACK.
 END PROGRAM TOOL-ATTACK-CALC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SWEEP-CHECK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FULL                 BINARY-LONG.
 01 L-CRIT                 BINARY-LONG.
 01 L-SPRINT-KB            BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-MOVEMENT             BINARY-LONG.
 01 L-SWORD                BINARY-LONG.
 01 L-SWEEP                BINARY-LONG.
 PROCEDURE DIVISION USING L-FULL L-CRIT L-SPRINT-KB L-GROUND L-SPEED L-MOVEMENT L-SWORD L-SWEEP.
     MOVE 0 TO L-SWEEP
     IF L-FULL = 1 AND L-CRIT = 0 AND L-SPRINT-KB = 0 AND L-GROUND = 1 AND L-SPEED * 2 < L-MOVEMENT * 5 AND L-SWORD = 1
         MOVE 1 TO L-SWEEP
     END-IF
     GOBACK.
 END PROGRAM TOOL-SWEEP-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SWEEPING-RATIO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-RATIO                BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-RATIO.
     COMPUTE L-RATIO = L-LEVEL * 1000 / (L-LEVEL + 1)
     GOBACK.
 END PROGRAM TOOL-SWEEPING-RATIO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SWEEP-DAMAGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DAMAGE               BINARY-LONG.
 01 L-RATIO                BINARY-LONG.
 01 L-SWEEP                BINARY-LONG.
 PROCEDURE DIVISION USING L-DAMAGE L-RATIO L-SWEEP.
     COMPUTE L-SWEEP = 1000 + L-RATIO * L-DAMAGE / 1000
     GOBACK.
 END PROGRAM TOOL-SWEEP-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SWEEP-VICTIM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACKER             BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-ALLIED               BINARY-LONG.
 01 L-MARKER               BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACKER L-TARGET L-ALLIED L-MARKER L-D2 L-HIT.
     MOVE 0 TO L-HIT
     IF L-ATTACKER = 0 AND L-TARGET = 0 AND L-ALLIED = 0 AND L-MARKER = 0 AND L-D2 < 9000
         MOVE 1 TO L-HIT
     END-IF
     GOBACK.
 END PROGRAM TOOL-SWEEP-VICTIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SWEEP-KNOCKBACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAD                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-YAW                  BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-YAW L-STRENGTH L-X L-Z.
     MOVE 400 TO L-STRENGTH
     COMPUTE WS-RAD = L-YAW * 0.017453292519943295 / 1000
     COMPUTE L-X ROUNDED = FUNCTION SIN(WS-RAD) * 1000
     COMPUTE L-Z ROUNDED = 0 - FUNCTION COS(WS-RAD) * 1000
     GOBACK.
 END PROGRAM TOOL-SWEEP-KNOCKBACK.

*> Section 4.4 (receiving damage; the entry point is TOOL-HURT-PIPELINE):
*>   TOOL-DIFFICULTY-SCALE USING difficulty (0 peaceful to 3 hard), source scales with difficulty, amount, amount out
*>   TOOL-HURT-GATE USING invulnerable, creative invulnerability, source bypasses invulnerability, dead, caused by a player, PvP on, teams allow,
*>     accepted out
*>   TOOL-HURT-KNOCKBACK USING fresh hit, type in no_knockback, blocked, remaining, default knockback out, hurt animation out
*>   TOOL-HURT-SPECIAL USING source is freezing, type hurt extra by freezing, source damages the helmet, helmet worn, amount, amount out,
*>     helmet worn down out
*>   TOOL-MAGIC-ABSORB USING amount, Resistance amplifier (-1 none), bypasses_resistance, bypasses_effects, bypasses_enchantments, protection
*>     points, amount out
*>   TOOL-ABSORB USING amount, absorption, amount out, new absorption out, absorbed out
*>   TOOL-HURT-PIPELINE USING amount, difficulty, scales, blocked, armor, toughness, bypasses_armor, Resistance amplifier (-1 none),
*>     bypasses_resistance, bypasses_effects, protection points, absorption, health taken out, new absorption out, armor wear out (per piece)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-DIFFICULTY-SCALE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-SCALES               BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFICULTY L-SCALES L-AMOUNT L-OUT.
     MOVE L-AMOUNT TO L-OUT
     IF L-SCALES = 1
         EVALUATE L-DIFFICULTY
             WHEN 0
                 MOVE 0 TO L-OUT
             WHEN 1
                 COMPUTE L-OUT = L-AMOUNT / 2 + 1000
                 IF L-OUT > L-AMOUNT
                     MOVE L-AMOUNT TO L-OUT
                 END-IF
             WHEN 3
                 COMPUTE L-OUT = L-AMOUNT * 3 / 2
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM TOOL-DIFFICULTY-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-HURT-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INVULNERABLE         BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-BYPASS               BINARY-LONG.
 01 L-DEAD                 BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-PVP                  BINARY-LONG.
 01 L-TEAMS                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-INVULNERABLE L-CREATIVE L-BYPASS L-DEAD L-PLAYER L-PVP L-TEAMS L-OK.
     MOVE 1 TO L-OK
     IF L-INVULNERABLE = 1 OR (L-CREATIVE = 1 AND L-BYPASS = 0) OR L-DEAD = 1
             OR (L-PLAYER = 1 AND (L-PVP = 0 OR L-TEAMS = 0))
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM TOOL-HURT-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-HURT-KNOCKBACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FRESH                BINARY-LONG.
 01 L-NONE                 BINARY-LONG.
 01 L-BLOCKED              BINARY-LONG.
 01 L-REMAINING            BINARY-LONG.
 01 L-KNOCKBACK            BINARY-LONG.
 01 L-ANIMATION            BINARY-LONG.
 PROCEDURE DIVISION USING L-FRESH L-NONE L-BLOCKED L-REMAINING L-KNOCKBACK L-ANIMATION.
     MOVE 0 TO L-KNOCKBACK L-ANIMATION
     IF L-FRESH = 1 AND L-NONE = 0 AND NOT (L-BLOCKED > 0 AND L-REMAINING <= 0)
         MOVE 1 TO L-KNOCKBACK
     END-IF
     IF L-BLOCKED = 0
         MOVE 1 TO L-ANIMATION
     END-IF
     GOBACK.
 END PROGRAM TOOL-HURT-KNOCKBACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-HURT-SPECIAL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FREEZING             BINARY-LONG.
 01 L-SENSITIVE            BINARY-LONG.
 01 L-HELMET-SOURCE        BINARY-LONG.
 01 L-HELMET               BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 01 L-WEAR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FREEZING L-SENSITIVE L-HELMET-SOURCE L-HELMET L-AMOUNT L-OUT L-WEAR.
     MOVE L-AMOUNT TO L-OUT
     MOVE 0 TO L-WEAR
     IF L-FREEZING = 1 AND L-SENSITIVE = 1
         COMPUTE L-OUT = L-AMOUNT * 5
     END-IF
     IF L-HELMET-SOURCE = 1 AND L-HELMET = 1
         COMPUTE L-OUT = L-AMOUNT * 3 / 4
         MOVE 1 TO L-WEAR
     END-IF
     GOBACK.
 END PROGRAM TOOL-HURT-SPECIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-MAGIC-ABSORB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-AMOUNT               BINARY-LONG.
 01 L-RESISTANCE           BINARY-LONG.
 01 L-BYPASS-RESISTANCE    BINARY-LONG.
 01 L-BYPASS-EFFECTS       BINARY-LONG.
 01 L-BYPASS-ENCHANT       BINARY-LONG.
 01 L-PROTECTION           BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AMOUNT L-RESISTANCE L-BYPASS-RESISTANCE L-BYPASS-EFFECTS L-BYPASS-ENCHANT L-PROTECTION L-OUT.
     MOVE L-AMOUNT TO L-OUT
     IF L-BYPASS-EFFECTS = 0
         IF L-RESISTANCE >= 0 AND L-BYPASS-RESISTANCE = 0
             COMPUTE L-OUT = L-OUT * (25 - 5 * (L-RESISTANCE + 1)) / 25
             IF L-OUT < 0
                 MOVE 0 TO L-OUT
             END-IF
         END-IF
         IF L-OUT > 0 AND L-BYPASS-ENCHANT = 0
             MOVE L-PROTECTION TO WS-P
             IF WS-P > 20
                 MOVE 20 TO WS-P
             END-IF
             IF WS-P < 0
                 MOVE 0 TO WS-P
             END-IF
             COMPUTE L-OUT = L-OUT * (25 - WS-P) / 25
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-MAGIC-ABSORB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ABSORB.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AMOUNT               BINARY-LONG.
 01 L-ABSORPTION           BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-ABSORBED             BINARY-LONG.
 PROCEDURE DIVISION USING L-AMOUNT L-ABSORPTION L-OUT L-NEW L-ABSORBED.
     COMPUTE L-OUT = L-AMOUNT - L-ABSORPTION
     IF L-OUT < 0
         MOVE 0 TO L-OUT
     END-IF
     COMPUTE L-ABSORBED = L-AMOUNT - L-OUT
     COMPUTE L-NEW = L-ABSORPTION - L-ABSORBED
     GOBACK.
 END PROGRAM TOOL-ABSORB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-HURT-PIPELINE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-AMOUNT               BINARY-LONG.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-SCALES               BINARY-LONG.
 01 L-BLOCKED              BINARY-LONG.
 01 L-ARMOR                BINARY-LONG.
 01 L-TOUGHNESS            BINARY-LONG.
 01 L-BYPASS-ARMOR         BINARY-LONG.
 01 L-RESISTANCE           BINARY-LONG.
 01 L-BYPASS-RESISTANCE    BINARY-LONG.
 01 L-BYPASS-EFFECTS       BINARY-LONG.
 01 L-PROTECTION           BINARY-LONG.
 01 L-ABSORPTION           BINARY-LONG.
 01 L-TAKEN                BINARY-LONG.
 01 L-NEW-ABSORPTION       BINARY-LONG.
 01 L-WEAR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AMOUNT L-DIFFICULTY L-SCALES L-BLOCKED L-ARMOR L-TOUGHNESS L-BYPASS-ARMOR L-RESISTANCE
         L-BYPASS-RESISTANCE L-BYPASS-EFFECTS L-PROTECTION L-ABSORPTION L-TAKEN L-NEW-ABSORPTION L-WEAR.
     MOVE 0 TO L-WEAR
     CALL "TOOL-DIFFICULTY-SCALE" USING L-DIFFICULTY L-SCALES L-AMOUNT WS-AMOUNT
     SUBTRACT L-BLOCKED FROM WS-AMOUNT
     IF WS-AMOUNT < 0
         MOVE 0 TO WS-AMOUNT
     END-IF
     IF L-BYPASS-ARMOR = 0
         CALL "TOOL-ARMOR-WEAR" USING WS-AMOUNT L-BYPASS-ARMOR L-WEAR
         CALL "TOOL-ARMOR-ABSORB" USING WS-AMOUNT L-ARMOR L-TOUGHNESS WS-NONE WS-AMOUNT
     END-IF
     CALL "TOOL-MAGIC-ABSORB" USING WS-AMOUNT L-RESISTANCE L-BYPASS-RESISTANCE L-BYPASS-EFFECTS WS-NONE L-PROTECTION
         L-TAKEN
     CALL "TOOL-ABSORB" USING L-TAKEN L-ABSORPTION WS-AMOUNT L-NEW-ABSORPTION WS-NONE
     MOVE WS-AMOUNT TO L-TAKEN
     GOBACK.
 END PROGRAM TOOL-HURT-PIPELINE.

*> Section 4.5 (armor and toughness):
*>   TOOL-ARMOR-ABSORB USING damage, armor value, toughness (thousandths), Breach levels, damage out (d (1 - q), q = clamp(R - d / (2 + T / 4),
*>     0.2 R, 20) / 25 less 0.15 per Breach level)
*>   TOOL-ARMOR-WEAR USING damage, bypasses_armor, wear out (max(1, floor(d / 4)) per piece; 0 when bypassed)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ARMOR-ABSORB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-FLOOR               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DAMAGE               BINARY-LONG.
 01 L-ARMOR                BINARY-LONG.
 01 L-TOUGHNESS            BINARY-LONG.
 01 L-BREACH               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DAMAGE L-ARMOR L-TOUGHNESS L-BREACH L-OUT.
     COMPUTE WS-D = L-DAMAGE / 1000
     COMPUTE WS-F = 2 + L-TOUGHNESS / 4000
     COMPUTE WS-E = L-ARMOR - WS-D / WS-F
     COMPUTE WS-FLOOR = L-ARMOR * 0.2
     IF WS-E < WS-FLOOR
         MOVE WS-FLOOR TO WS-E
     END-IF
     IF WS-E > 20
         MOVE 20 TO WS-E
     END-IF
     COMPUTE WS-Q = WS-E / 25 - 0.15 * L-BREACH
     IF WS-Q < 0
         MOVE 0 TO WS-Q
     END-IF
     IF WS-Q > 1
         MOVE 1 TO WS-Q
     END-IF
     COMPUTE L-OUT = WS-D * (1 - WS-Q) * 1000
     GOBACK.
 END PROGRAM TOOL-ARMOR-ABSORB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ARMOR-WEAR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DAMAGE               BINARY-LONG.
 01 L-BYPASS               BINARY-LONG.
 01 L-WEAR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DAMAGE L-BYPASS L-WEAR.
     MOVE 0 TO L-WEAR
     IF L-BYPASS = 0
         COMPUTE L-WEAR = L-DAMAGE / 4000
         IF L-WEAR < 1
             MOVE 1 TO L-WEAR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-ARMOR-WEAR.

*> Section 4.6 (knockback):
*>   TOOL-KNOCKBACK USING strength, knockback resistance (thousandths), dx, dz (the direction, any scale), vx, vy, vz (the velocity), on ground,
*>     new vx out, new vy out, new vz out, status out (0 stopped by resistance, 1 applied, 2 the direction vanishes: pick a random one)
*>   TOOL-ATTACK-KNOCKBACK USING attack_knockback attribute, Knockback level, sprinting, K out ((attr + level) / 2 + 0.5 sprinting)
*>   TOOL-ARROW-KNOCKBACK USING Punch level, resistance, horizontal push out (level x 0.6 x (1 - resistance))
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-KNOCKBACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-UP                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRENGTH             BINARY-LONG.
 01 L-RESISTANCE           BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VY                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-NX                   BINARY-LONG.
 01 L-NY                   BINARY-LONG.
 01 L-NZ                   BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-STRENGTH L-RESISTANCE L-DX L-DZ L-VX L-VY L-VZ L-GROUND L-NX L-NY L-NZ L-STATUS.
     MOVE L-VX TO L-NX
     MOVE L-VY TO L-NY
     MOVE L-VZ TO L-NZ
     COMPUTE WS-S = L-STRENGTH * (1000 - L-RESISTANCE) / 1000
     EVALUATE TRUE
         WHEN WS-S <= 0
             MOVE 0 TO L-STATUS
         WHEN L-DX * L-DX + L-DZ * L-DZ < 10
             MOVE 2 TO L-STATUS
         WHEN OTHER
             MOVE 1 TO L-STATUS
             COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + L-DZ * L-DZ)
             COMPUTE L-NX ROUNDED = L-VX / 2 - L-DX / WS-LEN * WS-S
             COMPUTE L-NZ ROUNDED = L-VZ / 2 - L-DZ / WS-LEN * WS-S
             IF L-GROUND = 1
                 COMPUTE WS-UP ROUNDED = L-VY / 2 + WS-S
                 IF WS-UP > 400
                     MOVE 400 TO WS-UP
                 END-IF
                 MOVE WS-UP TO L-NY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-KNOCKBACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ATTACK-KNOCKBACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTRIBUTE            BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-SPRINT               BINARY-LONG.
 01 L-K                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTRIBUTE L-LEVEL L-SPRINT L-K.
     COMPUTE L-K = (L-ATTRIBUTE + 1000 * L-LEVEL) / 2
     IF L-SPRINT = 1
         ADD 500 TO L-K
     END-IF
     GOBACK.
 END PROGRAM TOOL-ATTACK-KNOCKBACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ARROW-KNOCKBACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-RESISTANCE           BINARY-LONG.
 01 L-PUSH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-RESISTANCE L-PUSH.
     COMPUTE L-PUSH = L-LEVEL * 600 * (1000 - L-RESISTANCE) / 1000
     GOBACK.
 END PROGRAM TOOL-ARROW-KNOCKBACK.

*> Section 4.7 (the hurt window):
*>   TOOL-HURT-WINDOW USING window (invulnerableTime), lastHurt, amount, type bypasses_cooldown, mode out (0 ignored, 1 new window, 2 only the
*>     excess over lastHurt), applied out, new lastHurt out, new window out
*>   TOOL-HURT-TICK USING window, new window out (minus 1 to 0)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-HURT-WINDOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WINDOW               BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-BYPASS               BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-APPLIED              BINARY-LONG.
 01 L-NEW-LAST             BINARY-LONG.
 01 L-NEW-WINDOW           BINARY-LONG.
 PROCEDURE DIVISION USING L-WINDOW L-LAST L-AMOUNT L-BYPASS L-MODE L-APPLIED L-NEW-LAST L-NEW-WINDOW.
     MOVE L-LAST TO L-NEW-LAST
     MOVE L-WINDOW TO L-NEW-WINDOW
     MOVE 0 TO L-APPLIED
     EVALUATE TRUE
         WHEN L-WINDOW <= 10 OR L-BYPASS = 1
             MOVE 1 TO L-MODE
             MOVE L-AMOUNT TO L-APPLIED L-NEW-LAST
             MOVE 20 TO L-NEW-WINDOW
         WHEN L-AMOUNT <= L-LAST
             MOVE 0 TO L-MODE
         WHEN OTHER
             MOVE 2 TO L-MODE
             COMPUTE L-APPLIED = L-AMOUNT - L-LAST
             MOVE L-AMOUNT TO L-NEW-LAST
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-HURT-WINDOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-HURT-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WINDOW               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WINDOW L-NEW.
     MOVE L-WINDOW TO L-NEW
     IF L-NEW > 0
         SUBTRACT 1 FROM L-NEW
     END-IF
     GOBACK.
 END PROGRAM TOOL-HURT-TICK.

*> Section 4.8 (mace):
*>   TOOL-MACE-CAN-SMASH USING fall distance (thousandths), gliding, can smash out
*>   TOOL-MACE-BONUS USING fall distance, Density level, bonus out
*>   TOOL-MACE-SHOCK USING distance from the attacker, fall distance, victim knockback resistance, knockback power out (0 beyond 3.5)
*>   TOOL-WIND-BURST USING level, fall distance, attacker flying, multiplier out (1200, 1750, 2200), allowed out (fall >= 1.5, not flying)
*>   TOOL-MACE-SOUND USING fall distance, on ground, sound out
*>   TOOL-MACE-INFO USING bounce velocity (10), level event (2013), event data (750), shockwave radius (3500)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-MACE-CAN-SMASH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FALL                 BINARY-LONG.
 01 L-GLIDING              BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FALL L-GLIDING L-CAN.
     MOVE 0 TO L-CAN
     IF L-FALL > 1500 AND L-GLIDING = 0
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM TOOL-MACE-CAN-SMASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-MACE-BONUS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FALL                 BINARY-LONG.
 01 L-DENSITY              BINARY-LONG.
 01 L-BONUS                BINARY-LONG.
 PROCEDURE DIVISION USING L-FALL L-DENSITY L-BONUS.
     EVALUATE TRUE
         WHEN L-FALL <= 3000
             COMPUTE L-BONUS = 4 * L-FALL
         WHEN L-FALL <= 8000
             COMPUTE L-BONUS = 12000 + 2 * (L-FALL - 3000)
         WHEN OTHER
             COMPUTE L-BONUS = 22000 + (L-FALL - 8000)
     END-EVALUATE
     COMPUTE L-BONUS = L-BONUS + 500 * L-DENSITY * L-FALL / 1000
     GOBACK.
 END PROGRAM TOOL-MACE-BONUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-MACE-SHOCK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-FALL                 BINARY-LONG.
 01 L-RESISTANCE           BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-FALL L-RESISTANCE L-POWER.
     MOVE 0 TO L-POWER
     IF L-DISTANCE <= 3500
         COMPUTE L-POWER = (3500 - L-DISTANCE) * 7 / 10 * (1000 - L-RESISTANCE) / 1000
         IF L-FALL > 5000
             COMPUTE L-POWER = L-POWER * 2
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-MACE-SHOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-WIND-BURST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-FALL                 BINARY-LONG.
 01 L-FLYING               BINARY-LONG.
 01 L-MULTIPLIER           BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-FALL L-FLYING L-MULTIPLIER L-ALLOWED.
     EVALUATE L-LEVEL
         WHEN 1
             MOVE 1200 TO L-MULTIPLIER
         WHEN 2
             MOVE 1750 TO L-MULTIPLIER
         WHEN OTHER
             MOVE 2200 TO L-MULTIPLIER
     END-EVALUATE
     MOVE 0 TO L-ALLOWED
     IF L-FALL >= 1500 AND L-FLYING = 0
         MOVE 1 TO L-ALLOWED
     END-IF
     GOBACK.
 END PROGRAM TOOL-WIND-BURST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-MACE-SOUND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FALL                 BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-SOUND                PIC X(48).
 PROCEDURE DIVISION USING L-FALL L-GROUND L-SOUND.
     EVALUATE TRUE
         WHEN L-FALL > 5000
             MOVE "item.mace.smash_ground_heavy" TO L-SOUND
         WHEN L-GROUND = 1
             MOVE "item.mace.smash_ground" TO L-SOUND
         WHEN OTHER
             MOVE "item.mace.smash_air" TO L-SOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-MACE-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-MACE-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOUNCE               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-BOUNCE L-EVENT L-DATA L-RADIUS.
     MOVE 10 TO L-BOUNCE
     MOVE 2013 TO L-EVENT
     MOVE 750 TO L-DATA
     MOVE 3500 TO L-RADIUS
     GOBACK.
 END PROGRAM TOOL-MACE-INFO.
