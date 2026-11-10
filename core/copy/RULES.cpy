*> Shared player rules (docs/protocol/17 section 4.7, 4.9, 4.11; both world types). Tested by
*> core/tests/acc_f2us2_shared_rules.cob and test_content_tables.cob.
*> Maximum health (the max_health attribute, 17 section 4.10): 20 for new and respawned players.
 78 RULE-MAX-HEALTH           VALUE 20.
*> Maximum food level (17 section 4.9): 20; a new player has food 20 and saturation 5.0.
 78 RULE-MAX-FOOD             VALUE 20.
 78 RULE-START-SATURATION     VALUE 5.
*> Day length (shared rule of both world types, docs/protocol/33 §3, 12 §3.2c): the time of day runs 0..23999,
*> advancing 1 per tick and wrapping to 0. A level.dat of feature 001 (30000-tick day) is re-based on opening
*> (LEVEL-TIME-REBASE).
 78 RULE-DAY-LENGTH           VALUE 24000.
 78 RULE-OLD-DAY-LENGTH       VALUE 30000.
*> Ground items (§9; §1.3 block yields; data-model §5). Lengths, speeds and factors are integer
*> THOUSANDTHS (0.035 -> 35), as in ENTITYTYPES.cpy; times are ticks.
*> Pickup delay of a new ground item (§9.1): a survival block break or a mob defeat 6, a throw 30.
 78 RULE-GI-BREAK-DELAY       VALUE 6.
 78 RULE-GI-THROW-DELAY       VALUE 30.
*> Block yield position (§1.3, §9.1): (x + 0.5, y + 0.25, z + 0.5) of the broken block at (x, y, z).
 78 RULE-GI-BREAK-DXZ-MILLI   VALUE 500.
 78 RULE-GI-BREAK-DY-MILLI    VALUE 250.
*> Throw (§9.1): from the thrower's feet + (0, 1.3, 0); motion mx = -sin(yaw) cos(pitch) x 0.25,
*> my = -sin(pitch) x 0.25 + 0.12, mz = cos(yaw) cos(pitch) x 0.25 blocks per tick; no spread.
 78 RULE-GI-THROW-DY-MILLI    VALUE 1300.
 78 RULE-GI-THROW-SPEED-MILLI VALUE 250.
 78 RULE-GI-THROW-LIFT-MILLI  VALUE 120.
*> Age (§9.2 step 2): it advances only while a player of the dimension is within 32.0 blocks (3D
*> Euclidean distance between positions); at 4800 the item despawns.
 78 RULE-GI-NEAR-MILLI        VALUE 32000.
 78 RULE-GI-DESPAWN-AGE       VALUE 4800.
*> Movement (§9.2 step 3): gravity 0.035 per tick, drag factor 0.97 per tick.
 78 RULE-GI-GRAVITY-MILLI     VALUE 35.
 78 RULE-GI-DRAG-MILLI        VALUE 970.
*> Pickup range (§9.3): the player's box expanded by 0.75 in x and z and by 0.25 in y.
 78 RULE-GI-REACH-XZ-MILLI    VALUE 750.
 78 RULE-GI-REACH-Y-MILLI     VALUE 250.
*> Merging (§9.2): ground items never merge (0 = never).
 78 RULE-GI-MERGES            VALUE 0.
*> Block yields (§1.3): the item of a block broken in survival, by block id (index block id + 1);
*> 0 = no yield (void; the baseplate is never broken). Block 2-9 -> item 2-9, goto_pad (10) -> 16,
*> slag (11) -> 17.
 01 RULE-YIELD-DATA.
    05 FILLER BINARY-LONG VALUE 0.              *> void
    05 FILLER BINARY-LONG VALUE 0.              *> baseplate
    05 FILLER BINARY-LONG VALUE 2.              *> greystone
    05 FILLER BINARY-LONG VALUE 3.              *> loam
    05 FILLER BINARY-LONG VALUE 4.              *> turf
    05 FILLER BINARY-LONG VALUE 5.              *> grit
    05 FILLER BINARY-LONG VALUE 6.              *> cardstack
    05 FILLER BINARY-LONG VALUE 7.              *> lucite
    05 FILLER BINARY-LONG VALUE 8.              *> glowtube
    05 FILLER BINARY-LONG VALUE 9.              *> ledger_tile
    05 FILLER BINARY-LONG VALUE 16.             *> goto_pad
    05 FILLER BINARY-LONG VALUE 17.             *> slag
 01 RULE-YIELD-TABLE REDEFINES RULE-YIELD-DATA.
    05 RULE-YIELD-ITEM BINARY-LONG OCCURS 12 TIMES.
*> Health and death (17 section 4.7, 4.9, 4.11). Lengths and amounts in THOUSANDTHS where marked MILLI.
*> Hurt window (4.7): an accepted hit sets invulnerableTime to 20; a hit while it is above 10 applies
*> only its excess over the last damage (ignored when not above it).
 78 RULE-HURT-WINDOW          VALUE 20.
 78 RULE-HURT-FRESH           VALUE 10.
*> Fall damage (4.11): floor(distance + 1e-6 - 3.0).
 78 RULE-SAFE-FALL            VALUE 3.
*> Causes of damage (§10.3), numbered in table order; MESSAGES.cpy has each cause's death message.
 78 CAUSE-FALL                VALUE 1.
 78 CAUSE-ABEND               VALUE 2.
 78 CAUSE-PLAYER              VALUE 3.
 78 CAUSE-STARVATION          VALUE 4.
 78 CAUSE-HAIL                VALUE 5.
 78 CAUSE-COMMAND             VALUE 6.
 78 CAUSE-COUNT               VALUE 6.
*> Per cause: the damage type id, the fixed amount (0: the fall formula, the attacker's held item
*> (§10.4), or the command sets health to 0 directly) and the damage type's exhaustion in thousandths
*> (17 section 4.12: 0.1 for mob_attack, player_attack and hail, 0 for fall, starve and generic).
 01 RULE-CAUSE-DATA.
    05 FILLER BINARY-LONG VALUE 1.              *> fall: cobolcraft:impact
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.             *> exhaustion
    05 FILLER BINARY-LONG VALUE 28.             *> abend: cobolcraft:mob_attack
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 100.           *> exhaustion
    05 FILLER BINARY-LONG VALUE 29.             *> player: cobolcraft:player_attack
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 100.           *> exhaustion
    05 FILLER BINARY-LONG VALUE 30.             *> starvation: cobolcraft:starvation
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.             *> exhaustion
    05 FILLER BINARY-LONG VALUE 31.             *> hail: cobolcraft:hail
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 100.           *> exhaustion
    05 FILLER BINARY-LONG VALUE 0.              *> command: cobolcraft:generic
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.             *> exhaustion
 01 RULE-CAUSE-TABLE REDEFINES RULE-CAUSE-DATA.
    05 RULE-CAUSE OCCURS 6 TIMES.
       10 RULE-CAUSE-TYPE    BINARY-LONG.
       10 RULE-CAUSE-AMOUNT  BINARY-LONG.
       10 RULE-CAUSE-EXHAUST BINARY-LONG.
*> Attacks (§10.4): a hit reaches at most 4.0 blocks from the attacker's eye point, feet + (0, 1.6, 0),
*> to the nearest point of the target's collision box.
 78 RULE-ATTACK-REACH-MILLI   VALUE 4000.
 78 RULE-ATTACK-EYE-MILLI     VALUE 1600.
*> FoodData (17 section 4.9): exhaustion of 4.0 is spent per tick on saturation, then food; natural
*> regeneration every 10 ticks while saturated at food 20 (heal min(saturation, 6) / 6, exhaustion
*> min(saturation, 6)), every 80 ticks from food 18 (heal 1, exhaustion 6.0); at food 0 every 80
*> ticks 1 starvation damage while health is above 1 (Normal difficulty). Sprinting needs food above 6.
 78 RULE-EXHAUST-DROP-MILLI   VALUE 4000.
 78 RULE-EXHAUST-CAP-MILLI    VALUE 40000.
 78 RULE-REGEN-FAST-TICKS     VALUE 10.
 78 RULE-REGEN-TICKS          VALUE 80.
 78 RULE-REGEN-SATURATION-CAP VALUE 6.
 78 RULE-HEAL-FOOD            VALUE 18.
 78 RULE-REGEN-SLOW-EXHAUST   VALUE 6.
 78 RULE-SPRINT-FOOD          VALUE 6.
*> Death drops (§10.6): slot s (0 to 35) becomes a ground item at the feet + (0, 0.5, 0) with motion
*> (((s mod 6) x 2 - 5) x 0.02, 0.2, (((s div 6) mod 6) x 2 - 5) x 0.02) and pickup delay 30.
 78 RULE-DEATH-DY-MILLI       VALUE 500.
 78 RULE-DEATH-SPREAD-MILLI   VALUE 20.
 78 RULE-DEATH-LIFT-MILLI     VALUE 200.
 78 RULE-DEATH-DELAY          VALUE 30.
*> Exhaustion of actions (17 section 4.9), in THOUSANDTHS: per metre of horizontal distance sprinting
*> 0.1 (walking 0); per jump 0.05, per sprinting jump 0.2; per hit 0.15 -> 0.1; per completed survival
*> break 0.005.
 78 RULE-EXHAUST-SPRINT-MILLI VALUE 100.
 78 RULE-EXHAUST-JUMP-MILLI   VALUE 50.
 78 RULE-EXHAUST-SPRINT-JUMP-MILLI VALUE 200.
 78 RULE-EXHAUST-ATTACK-MILLI VALUE 100.
 78 RULE-EXHAUST-BREAK-MILLI  VALUE 5.
*> Eating (§11.6): the eating time is 30 ticks; completion sends Entity Event 9 (eating finished).
 78 RULE-EAT-TICKS            VALUE 30.
 78 RULE-EAT-EVENT            VALUE 9.
