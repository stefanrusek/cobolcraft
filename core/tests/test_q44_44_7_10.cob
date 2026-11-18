*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 10 and worked cases 13.9 to 13.13, 13.16, 13.17, lane 002-lane-p49j-a): the nautilus
*> family as functions: food and taming (10.2), the slot rule and the armor table (10.3), shear order (10.3.1), ridden input, speed, dash scale and impulse, dash flag and
*> cooldown, the rider effect refresh, the restriction radius (10.4), the vehicle speed bound (10.4.1), bubble probability (10.4.2), the target finder (10.5), the charge
*> attack (10.6, 13.10) and the zombie nautilus variant choice (10.1, 13.13). There is no nautilus mob row in the core: not wired into a tick (gap).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-TAME                BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TAMED               BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-ARMOR               BINARY-LONG.
 01 WS-TOUGH               BINARY-LONG.
 01 WS-KB                  BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-SADDLE              BINARY-LONG.
 01 WS-XXA                 FLOAT-LONG.
 01 WS-ZZA                 FLOAT-LONG.
 01 WS-XROT                FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-INWATER             BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-OUTF                FLOAT-LONG.
 01 WS-STRENGTH            BINARY-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-MOVE                FLOAT-LONG.
 01 WS-BLOCKF              FLOAT-LONG.
 01 WS-CD                  BINARY-LONG.
 01 WS-DASH                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-ADULT               BINARY-LONG.
 01 WS-SADDLED             BINARY-LONG.
 01 WS-M2                  FLOAT-LONG.
 01 WS-V2                  FLOAT-LONG.
 01 WS-BREEDING            BINARY-LONG.
 01 WS-ANGRY               BINARY-LONG.
 01 WS-CDPRESENT           BINARY-LONG.
 01 WS-COIN                BINARY-LONG.
 01 WS-HOSTILE             BINARY-LONG.
 01 WS-TGT                 BINARY-LONG.
 01 WS-SETCD               BINARY-LONG.
 01 WS-D2S                 FLOAT-LONG.
 01 WS-D2T                 FLOAT-LONG.
 01 WS-LOS                 BINARY-LONG.
 01 WS-CCD                 BINARY-LONG.
 01 WS-TARGETP             BINARY-LONG.
 01 WS-SPEEDAMP            BINARY-LONG.
 01 WS-SLOWAMP             BINARY-LONG.
 01 WS-FORCE               FLOAT-LONG.
 01 WS-ATTR                FLOAT-LONG.
 01 WS-WARM                BINARY-LONG.
 01 WS-LEN                 FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   10.2 food: untamed adult only pufferfish and its bucket; tame adult or any baby nautilus_food. 13.9: a cod does nothing to an untamed adult.
     MOVE 0 TO WS-TAME
     MOVE 0 TO WS-BABY
     MOVE "cod" TO WS-KEY
     CALL "Q7-NAU-IS-FOOD" USING WS-KEY WS-TAME WS-BABY WS-OBS
     MOVE "acceptance US15 44-7§10.2 13.9 a cod is not food for an untamed adult (the taming tag applies)" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE "pufferfish" TO WS-KEY
     CALL "Q7-NAU-IS-FOOD" USING WS-KEY WS-TAME WS-BABY WS-OBS
     MOVE "acceptance US15 44-7§10.2 pufferfish is food for an untamed adult" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE "pufferfish_bucket" TO WS-KEY
     CALL "Q7-NAU-IS-FOOD" USING WS-KEY WS-TAME WS-BABY WS-OBS
     MOVE "acceptance US15 44-7§10.2 and so is its bucket" TO WS-NAME
     PERFORM EXPECT
     MOVE 1 TO WS-TAME
     MOVE "cod" TO WS-KEY
     CALL "Q7-NAU-IS-FOOD" USING WS-KEY WS-TAME WS-BABY WS-OBS
     MOVE "acceptance US15 44-7§10.2 a tame adult is fed fish (nautilus_food)" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-TAME
     MOVE 1 TO WS-BABY
     CALL "Q7-NAU-IS-FOOD" USING WS-KEY WS-TAME WS-BABY WS-OBS
     MOVE "acceptance US15 44-7§10.2 an untamed baby also takes nautilus_food" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-BABY
     MOVE "bread" TO WS-KEY
     MOVE 1 TO WS-TAME
     CALL "Q7-NAU-IS-FOOD" USING WS-KEY WS-TAME WS-BABY WS-OBS
     MOVE "acceptance US15 44-7§10.2 bread is no food" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
*>   taming roll: nextInt(3) == 0 tames (event 7), else event 6.
     MOVE 0 TO WS-DRAW
     CALL "Q7-NAU-TAME-ROLL" USING WS-DRAW WS-TAMED WS-EVENT
     MOVE "acceptance US15 44-7§10.2 13.9 draw 0 tames (event 7)" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-TAMED TO WS-OBS
     PERFORM EXPECT
     MOVE 7 TO WS-EXP
     MOVE WS-EVENT TO WS-OBS
     PERFORM EXPECT
     MOVE 2 TO WS-DRAW
     CALL "Q7-NAU-TAME-ROLL" USING WS-DRAW WS-TAMED WS-EVENT
     MOVE "acceptance US15 44-7§10.2 13.9 draw 2 fails (event 6, not tamed)" TO WS-NAME
     MOVE 6 TO WS-EXP
     MOVE WS-EVENT TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-EXP
     MOVE WS-TAMED TO WS-OBS
     PERFORM EXPECT
*>   10.3 the slot rule.
     MOVE 1 TO WS-ALIVE
     MOVE 0 TO WS-BABY
     MOVE 1 TO WS-TAME
     CALL "Q7-NAU-SLOT" USING WS-ALIVE WS-BABY WS-TAME WS-OBS
     MOVE "acceptance US15 44-7§10.3 SADDLE and BODY are usable on an alive tame adult" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-TAME
     CALL "Q7-NAU-SLOT" USING WS-ALIVE WS-BABY WS-TAME WS-OBS
     MOVE "acceptance US15 44-7§10.3 13.16 not on an untamed one (the item passes on to taming)" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-TAME
     MOVE 1 TO WS-BABY
     CALL "Q7-NAU-SLOT" USING WS-ALIVE WS-BABY WS-TAME WS-OBS
     MOVE "acceptance US15 44-7§10.3 not on a baby" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-BABY
     MOVE 0 TO WS-ALIVE
     CALL "Q7-NAU-SLOT" USING WS-ALIVE WS-BABY WS-TAME WS-OBS
     MOVE "acceptance US15 44-7§10.3 not on a dead one" TO WS-NAME
     PERFORM EXPECT
*>   10.3 armor table (armor, toughness, knockback resistance x1000).
     MOVE "copper" TO WS-KEY
     PERFORM ARMOR
     MOVE "acceptance US15 44-7§10.3 copper nautilus armor: armor 4, toughness 0, no knockback resistance" TO WS-NAME
     COMPUTE WS-OBS = WS-ARMOR * 10000 + WS-TOUGH * 100 + WS-KB
     MOVE 40000 TO WS-EXP
     PERFORM EXPECT
     MOVE "iron" TO WS-KEY
     PERFORM ARMOR
     MOVE "acceptance US15 44-7§10.3 iron: armor 5" TO WS-NAME
     MOVE 50000 TO WS-EXP
     COMPUTE WS-OBS = WS-ARMOR * 10000 + WS-TOUGH * 100 + WS-KB
     PERFORM EXPECT
     MOVE "golden" TO WS-KEY
     PERFORM ARMOR
     MOVE "acceptance US15 44-7§10.3 golden: armor 7" TO WS-NAME
     MOVE 70000 TO WS-EXP
     COMPUTE WS-OBS = WS-ARMOR * 10000 + WS-TOUGH * 100 + WS-KB
     PERFORM EXPECT
     MOVE "diamond" TO WS-KEY
     PERFORM ARMOR
     MOVE "acceptance US15 44-7§10.3 13.12 diamond: armor 11, toughness 2" TO WS-NAME
     MOVE 110200 TO WS-EXP
     COMPUTE WS-OBS = WS-ARMOR * 10000 + WS-TOUGH * 100 + WS-KB
     PERFORM EXPECT
     MOVE "netherite" TO WS-KEY
     PERFORM ARMOR
     MOVE "acceptance US15 44-7§10.3 13.12 netherite: armor 19, toughness 3, knockback resistance 0.1 (100)" TO WS-NAME
     MOVE 190300 TO WS-EXP
     COMPUTE WS-EXP = 190300 + 100
     COMPUTE WS-OBS = WS-ARMOR * 10000 + WS-TOUGH * 100 + WS-KB
     PERFORM EXPECT
*>   10.3.1 shear order: BODY before SADDLE; a ridden nautilus cannot be sheared.
     MOVE 0 TO WS-PASS
     MOVE 1 TO WS-BODY
     MOVE 1 TO WS-SADDLE
     CALL "Q7-NAU-SHEAR" USING WS-PASS WS-BODY WS-SADDLE WS-OBS
     MOVE "acceptance US15 44-7§10.3.1 13.16 both worn: the armor (BODY, 1) is sheared first" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-BODY
     CALL "Q7-NAU-SHEAR" USING WS-PASS WS-BODY WS-SADDLE WS-OBS
     MOVE "acceptance US15 44-7§10.3.1 13.16 then the saddle (2)" TO WS-NAME
     MOVE 2 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-SADDLE
     CALL "Q7-NAU-SHEAR" USING WS-PASS WS-BODY WS-SADDLE WS-OBS
     MOVE "acceptance US15 44-7§10.3.1 nothing worn: nothing sheared (0)" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-PASS
     MOVE 1 TO WS-BODY
     CALL "Q7-NAU-SHEAR" USING WS-PASS WS-BODY WS-SADDLE WS-OBS
     MOVE "acceptance US15 44-7§10.3.1 13.16 with a rider aboard nothing is sheared" TO WS-NAME
     PERFORM EXPECT
*>   10.4 ridden input: looking down while pressing forward dives.
     MOVE 0 TO WS-XXA
     MOVE 1 TO WS-ZZA
     MOVE 90 TO WS-XROT
     CALL "Q7-NAU-RIDDEN-INPUT" USING WS-XXA WS-ZZA WS-XROT WS-OX WS-OY WS-OZ
     MOVE "acceptance US15 44-7§10.4 forward with pitch 90 (looking straight down): y = -sin(90) = -1 (x1000)" TO WS-NAME
     MOVE -1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OY * 1000
     PERFORM EXPECT
     MOVE 0 TO WS-XROT
     CALL "Q7-NAU-RIDDEN-INPUT" USING WS-XXA WS-ZZA WS-XROT WS-OX WS-OY WS-OZ
     MOVE "acceptance US15 44-7§10.4 forward on the level: z = cos 0 = 1 (x1000)" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OZ * 1000
     PERFORM EXPECT
     MOVE -1 TO WS-ZZA
     CALL "Q7-NAU-RIDDEN-INPUT" USING WS-XXA WS-ZZA WS-XROT WS-OX WS-OY WS-OZ
     MOVE "acceptance US15 44-7§10.4 reverse moves at half rate: z = -0.5 (x1000)" TO WS-NAME
     MOVE -500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OZ * 1000
     PERFORM EXPECT
     MOVE 0 TO WS-ZZA
     MOVE 0.7 TO WS-XXA
     MOVE 45 TO WS-XROT
     CALL "Q7-NAU-RIDDEN-INPUT" USING WS-XXA WS-ZZA WS-XROT WS-OX WS-OY WS-OZ
     MOVE "acceptance US15 44-7§10.4 no forward input: y = z = 0 and x = the sideways input (x1000 = 700)" TO WS-NAME
     MOVE 700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OX * 1000
     PERFORM EXPECT
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = (WS-OY + WS-OZ) * 1000
     PERFORM EXPECT
     MOVE 1 TO WS-INWATER
     MOVE 1.1 TO WS-SPEED
     CALL "Q7-NAU-RIDDEN-SPEED" USING WS-INWATER WS-SPEED WS-OUTF
     MOVE "acceptance US15 44-7§10.4 10.8 zombie nautilus (1.1) ridden in water: 0.0325 x 1.1 = 0.03575 (x100000)" TO WS-NAME
     MOVE 3575 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OUTF * 100000
     PERFORM EXPECT
     MOVE 0 TO WS-INWATER
     MOVE 1.0 TO WS-SPEED
     CALL "Q7-NAU-RIDDEN-SPEED" USING WS-INWATER WS-SPEED WS-OUTF
     MOVE "acceptance US15 44-7§10.4 13.11 on land 0.02 (x100000)" TO WS-NAME
     MOVE 2000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OUTF * 100000
     PERFORM EXPECT
*>   13.11 the dash.
     MOVE 45 TO WS-STRENGTH
     CALL "Q7-NAU-JUMP-SCALE" USING WS-STRENGTH WS-SCALE
     MOVE "acceptance US15 44-7§10.4 13.11 strength 45: scale 0.4 + 0.4 x 45 / 90 = 0.6 (x1000)" TO WS-NAME
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-SCALE * 1000
     PERFORM EXPECT
     MOVE 100 TO WS-STRENGTH
     CALL "Q7-NAU-JUMP-SCALE" USING WS-STRENGTH WS-SCALE
     MOVE "acceptance US15 44-7§10.4 13.11 strength 100: scale 1.0" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-SCALE * 1000
     PERFORM EXPECT
     MOVE 90 TO WS-STRENGTH
     CALL "Q7-NAU-JUMP-SCALE" USING WS-STRENGTH WS-SCALE
     MOVE "acceptance US15 44-7§10.4 strength 90 is already full scale 1.0" TO WS-NAME
     COMPUTE WS-OBS ROUNDED = WS-SCALE * 1000
     PERFORM EXPECT
     MOVE 0 TO WS-STRENGTH
     CALL "Q7-NAU-JUMP-SCALE" USING WS-STRENGTH WS-SCALE
     MOVE "acceptance US15 44-7§10.4 strength 0: scale 0.4" TO WS-NAME
     MOVE 400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-SCALE * 1000
     PERFORM EXPECT
     MOVE 0.6 TO WS-SCALE
     MOVE 1 TO WS-INWATER
     MOVE 1.0 TO WS-MOVE
     MOVE 1.0 TO WS-BLOCKF
     CALL "Q7-NAU-DASH-IMPULSE" USING WS-SCALE WS-INWATER WS-MOVE WS-BLOCKF WS-OUTF
     MOVE "acceptance US15 44-7§10.4 13.11 the impulse in water: 1.2 x 0.6 x 1 x 1 = 0.72 (x1000)" TO WS-NAME
     MOVE 720 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OUTF * 1000
     PERFORM EXPECT
     MOVE 1.0 TO WS-SCALE
     MOVE 0 TO WS-INWATER
     CALL "Q7-NAU-DASH-IMPULSE" USING WS-SCALE WS-INWATER WS-MOVE WS-BLOCKF WS-OUTF
     MOVE "acceptance US15 44-7§10.4 13.11 on land at full strength 0.5 (x1000)" TO WS-NAME
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OUTF * 1000
     PERFORM EXPECT
*>   dash flag: the cooldown starts at 40 with DASH true, the flag clears on the tick that starts with a cooldown of 34 or less (the 7th), the cooldown ends 40 ticks after.
     MOVE 40 TO WS-CD
     MOVE 1 TO WS-DASH
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-DASH = 0
         CALL "Q7-NAU-DASH-TICK" USING WS-CD WS-DASH
         ADD 1 TO WS-I
     END-PERFORM
     MOVE "acceptance US15 44-7§10.4 the DASH flag is cleared on the 7th tick after the cooldown starts" TO WS-NAME
     MOVE 7 TO WS-EXP
     MOVE WS-I TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§10.4 the cooldown then reads 33 (one decrement on each of 7 ticks)" TO WS-NAME
     MOVE 33 TO WS-EXP
     MOVE WS-CD TO WS-OBS
     PERFORM EXPECT
     MOVE 40 TO WS-CD
     MOVE 0 TO WS-DASH
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-CD = 0
         CALL "Q7-NAU-DASH-TICK" USING WS-CD WS-DASH
         ADD 1 TO WS-I
     END-PERFORM
     MOVE "acceptance US15 44-7§10.4 13.11 the next dash is possible 40 ticks after the previous one" TO WS-NAME
     MOVE 40 TO WS-EXP
     MOVE WS-I TO WS-OBS
     PERFORM EXPECT
*>   rider effect: when the player lacks it or gameTime mod 40 = 0.
     MOVE 0 TO WS-HAS
     MOVE 17 TO WS-TIME
     CALL "Q7-NAU-RIDER-FX" USING WS-HAS WS-TIME WS-OBS
     MOVE "acceptance US15 44-7§10.4 the rider without Breath of the Nautilus gets 60 ticks of it (1)" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-HAS
     CALL "Q7-NAU-RIDER-FX" USING WS-HAS WS-TIME WS-OBS
     MOVE "acceptance US15 44-7§10.4 with it, not refreshed at game time 17" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 80 TO WS-TIME
     CALL "Q7-NAU-RIDER-FX" USING WS-HAS WS-TIME WS-OBS
     MOVE "acceptance US15 44-7§10.4 13.11 refreshed at game time 80 (multiple of 40)" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
*>   restriction radius.
     MOVE 1 TO WS-ADULT
     MOVE 0 TO WS-SADDLED
     CALL "Q7-NAU-RADIUS" USING WS-ADULT WS-SADDLED WS-OBS
     MOVE "acceptance US15 44-7§10.4 an unsaddled tame adult stays within 32" TO WS-NAME
     MOVE 32 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-SADDLED
     CALL "Q7-NAU-RADIUS" USING WS-ADULT WS-SADDLED WS-OBS
     MOVE "acceptance US15 44-7§10.4 a saddled one within 16" TO WS-NAME
     MOVE 16 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-ADULT
     MOVE 0 TO WS-SADDLED
     CALL "Q7-NAU-RADIUS" USING WS-ADULT WS-SADDLED WS-OBS
     MOVE "acceptance US15 44-7§10.4 a baby always 16" TO WS-NAME
     PERFORM EXPECT
*>   10.4.1 vehicle speed bound (13: 8 blocks accepted, 11 rejected, velocity length 0.5).
     MOVE 64 TO WS-M2
     MOVE 0.25 TO WS-V2
     CALL "Q7-VEHICLE-OK" USING WS-M2 WS-V2 WS-OBS
     MOVE "acceptance US15 44-7§10.4.1 an 8 block report (64 - 0.25 <= 100) is accepted" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 121 TO WS-M2
     CALL "Q7-VEHICLE-OK" USING WS-M2 WS-V2 WS-OBS
     MOVE "acceptance US15 44-7§10.4.1 an 11 block report (121 - 0.25 > 100) is rejected" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
*>   10.4.2 bubble probability (13.17).
     MOVE 0 TO WS-SPEED
     CALL "Q7-NAU-BUBBLE-P" USING WS-SPEED WS-OUTF
     MOVE "acceptance US15 44-7§10.4.2 13.17 at rest p = 0.15 (x1000)" TO WS-NAME
     MOVE 150 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OUTF * 1000
     PERFORM EXPECT
     MOVE 0.3 TO WS-SPEED
     CALL "Q7-NAU-BUBBLE-P" USING WS-SPEED WS-OUTF
     MOVE "acceptance US15 44-7§10.4.2 13.17 at speed 0.3 p = 0.6" TO WS-NAME
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OUTF * 1000
     PERFORM EXPECT
     MOVE 0.7 TO WS-SPEED
     CALL "Q7-NAU-BUBBLE-P" USING WS-SPEED WS-OUTF
     MOVE "acceptance US15 44-7§10.4.2 at speed 0.7 p is capped at 1.0" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OUTF * 1000
     PERFORM EXPECT
*>   10.5 target finder: breeding, out of water, baby or tame: none; ANGRY_AT wins without cooldown; cooldown present: none; else cooldown set and a 50% roll.
     MOVE 0 TO WS-BREEDING
     MOVE 1 TO WS-INWATER
     MOVE 0 TO WS-BABY
     MOVE 0 TO WS-TAME
     MOVE 0 TO WS-ANGRY
     MOVE 0 TO WS-CDPRESENT
     MOVE 1 TO WS-COIN
     MOVE 1 TO WS-HOSTILE
     PERFORM TARGET
     MOVE "acceptance US15 44-7§10.5 a wild adult in water with no cooldown and the no-target roll (nextFloat < 0.5): no target, but the cooldown is stored" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-TGT TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-EXP
     MOVE WS-SETCD TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-COIN
     PERFORM TARGET
     MOVE "acceptance US15 44-7§10.5 with the roll at or above 0.5 and a pufferfish in water: it is the target" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-TGT TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-HOSTILE
     PERFORM TARGET
     MOVE "acceptance US15 44-7§10.5 no pufferfish near: no target" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-TGT TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-HOSTILE
     MOVE 1 TO WS-CDPRESENT
     PERFORM TARGET
     MOVE "acceptance US15 44-7§10.5 ATTACK_TARGET_COOLDOWN present: no target and no new cooldown" TO WS-NAME
     MOVE WS-TGT TO WS-OBS
     PERFORM EXPECT
     MOVE WS-SETCD TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-ANGRY
     PERFORM TARGET
     MOVE "acceptance US15 44-7§10.5 a valid ANGRY_AT target in water is chosen even during the cooldown" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-TGT TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-TAME
     PERFORM TARGET
     MOVE "acceptance US15 44-7§10.5 a tame nautilus never gets a target" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-TGT TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-TAME
     MOVE 0 TO WS-INWATER
     PERFORM TARGET
     MOVE "acceptance US15 44-7§10.5 out of water: no target" TO WS-NAME
     PERFORM EXPECT
     MOVE 1 TO WS-INWATER
     MOVE 1 TO WS-BABY
     PERFORM TARGET
     MOVE "acceptance US15 44-7§10.5 a baby: no target" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-BABY
     MOVE 1 TO WS-BREEDING
     PERFORM TARGET
     MOVE "acceptance US15 44-7§10.5 breeding: no target" TO WS-NAME
     PERFORM EXPECT
*>   10.6 charge: canStillUse.
     MOVE 0 TO WS-TAME
     MOVE 100 TO WS-D2S
     MOVE 100 TO WS-D2T
     MOVE 1 TO WS-LOS
     MOVE 0 TO WS-CCD
     MOVE 1 TO WS-TARGETP
     PERFORM CHARGE
     MOVE "acceptance US15 44-7§10.6 13.10 a charge within 12 of the start and 11 of the target with line of sight continues" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 144 TO WS-D2S
     PERFORM CHARGE
     MOVE "acceptance US15 44-7§10.6 13.10 (b) squared distance 144 from the start is not below 144: it ends" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 100 TO WS-D2S
     MOVE 121 TO WS-D2T
     PERFORM CHARGE
     MOVE "acceptance US15 44-7§10.6 squared distance 121 to the target is not below 121: it ends" TO WS-NAME
     PERFORM EXPECT
     MOVE 100 TO WS-D2T
     MOVE 0 TO WS-LOS
     PERFORM CHARGE
     MOVE "acceptance US15 44-7§10.6 no line of sight: it ends" TO WS-NAME
     PERFORM EXPECT
     MOVE 1 TO WS-LOS
     MOVE 1 TO WS-TAME
     PERFORM CHARGE
     MOVE "acceptance US15 44-7§10.6 a tame animal stops at once" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-TAME
     MOVE 1 TO WS-CCD
     PERFORM CHARGE
     MOVE "acceptance US15 44-7§10.6 while CHARGE_COOLDOWN_TICKS is present it ends" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-CCD
     MOVE 0 TO WS-TARGETP
     PERFORM CHARGE
     MOVE "acceptance US15 44-7§10.6 without an ATTACK_TARGET it ends" TO WS-NAME
     PERFORM EXPECT
*>   13.10 the charge velocity and the knockback arithmetic.
     MOVE 6 TO WS-OX
     MOVE 0 TO WS-OY
     MOVE 8 TO WS-OZ
     MOVE 0.6 TO WS-SPEED
     CALL "Q7-NAU-CHARGE-VEL" USING WS-OX WS-OY WS-OZ WS-SPEED WS-XXA WS-ZZA WS-LEN
     MOVE "acceptance US15 44-7§10.6 13.10 target at (6, 0, 8): chargeVelocity x = 0.36 (x1000)" TO WS-NAME
     MOVE 360 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-XXA * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§10.6 13.10 chargeVelocity z = 0.48 (x1000)" TO WS-NAME
     MOVE 480 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-ZZA * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§10.6 13.10 and y = 0 (the dolphin-like dash is level here)" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-LEN * 1000
     PERFORM EXPECT
     MOVE 0.6 TO WS-SPEED
     MOVE 1.0 TO WS-ATTR
     MOVE 0 TO WS-SPEEDAMP
     MOVE 0 TO WS-SLOWAMP
     CALL "Q7-NAU-KNOCKBACK" USING WS-SPEED WS-ATTR WS-SPEEDAMP WS-SLOWAMP WS-FORCE
     MOVE "acceptance US15 44-7§10.6 13.10 nautilus knockback: clamp(0.6 x 1.0) x 2.0 = 1.2 (x1000)" TO WS-NAME
     MOVE 1200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-FORCE * 1000
     PERFORM EXPECT
     MOVE 0.5 TO WS-SPEED
     MOVE 1.1 TO WS-ATTR
     CALL "Q7-NAU-KNOCKBACK" USING WS-SPEED WS-ATTR WS-SPEEDAMP WS-SLOWAMP WS-FORCE
     MOVE "acceptance US15 44-7§10.6 13.10 zombie nautilus: clamp(0.5 x 1.1) x 2.0 = 1.1" TO WS-NAME
     MOVE 1100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-FORCE * 1000
     PERFORM EXPECT
     MOVE 0.6 TO WS-SPEED
     MOVE 1.0 TO WS-ATTR
     MOVE 2 TO WS-SPEEDAMP
     CALL "Q7-NAU-KNOCKBACK" USING WS-SPEED WS-ATTR WS-SPEEDAMP WS-SLOWAMP WS-FORCE
     MOVE "acceptance US15 44-7§10.6 13.10 with Speed II (amp + 1 = 2): (0.6 + 0.5) x 2.0 = 2.2" TO WS-NAME
     MOVE 2200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-FORCE * 1000
     PERFORM EXPECT
     MOVE 0.01 TO WS-SPEED
     MOVE 0 TO WS-SPEEDAMP
     CALL "Q7-NAU-KNOCKBACK" USING WS-SPEED WS-ATTR WS-SPEEDAMP WS-SLOWAMP WS-FORCE
     MOVE "acceptance US15 44-7§10.6 the strength floor 0.2 applies before the force: 0.4" TO WS-NAME
     MOVE 400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-FORCE * 1000
     PERFORM EXPECT
*>   13.13 zombie nautilus variant.
     MOVE 1 TO WS-WARM
     CALL "Q7-NAU-VARIANT" USING WS-WARM WS-OBS
     MOVE "acceptance US15 44-7§10.1 13.13 in a warm ocean the coral (warm) variant, priority 1, wins (1)" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-WARM
     CALL "Q7-NAU-VARIANT" USING WS-WARM WS-OBS
     MOVE "acceptance US15 44-7§10.1 13.13 anywhere else the temperate variant (0)" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     STOP RUN.
 ARMOR.
     CALL "Q7-NAU-ARMOR" USING WS-KEY WS-ARMOR WS-TOUGH WS-KB.
 TARGET.
     CALL "Q7-NAU-TARGET" USING WS-BREEDING WS-INWATER WS-BABY WS-TAME WS-ANGRY WS-CDPRESENT WS-COIN WS-HOSTILE WS-TGT WS-SETCD.
 CHARGE.
     CALL "Q7-NAU-CHARGE-USE" USING WS-TARGETP WS-TAME WS-D2S WS-D2T WS-LOS WS-CCD WS-OBS.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-7-10.
