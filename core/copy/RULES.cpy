*> Player rules (standin-content §10, §11), transcribed. Tested by core/tests/test_content_tables.cob.
*> Maximum health (§10.1): health is a whole number 0..30; new and respawned players have 30.
 78 RULE-MAX-HEALTH           VALUE 30.
*> Maximum food level (§11.1): food is a whole number 0..24; new and respawned players have 24.
 78 RULE-MAX-FOOD             VALUE 24.
*> Day length (§4.8): the time of day runs 0..29999, advancing 1 per tick and wrapping to 0.
 78 RULE-DAY-LENGTH           VALUE 30000.
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
*> Health and death (§10.2 to §10.6; US7). Lengths and amounts in THOUSANDTHS where marked MILLI.
*> Hurt cooldown (§10.2): after damage, further damage is ignored for 12 ticks.
 78 RULE-HURT-COOLDOWN        VALUE 12.
*> Fall damage (§10.3): 2 x (floor(D) - 4) when floor(D) >= 5; the safe fall height is 4 blocks.
 78 RULE-SAFE-FALL            VALUE 4.
 78 RULE-FALL-FACTOR          VALUE 2.
*> Causes of damage (§10.3), numbered in table order; MESSAGES.cpy has each cause's death message.
 78 CAUSE-FALL                VALUE 1.
 78 CAUSE-ABEND               VALUE 2.
 78 CAUSE-PLAYER              VALUE 3.
 78 CAUSE-STARVATION          VALUE 4.
 78 CAUSE-HAIL                VALUE 5.
 78 CAUSE-COMMAND             VALUE 6.
 78 CAUSE-COUNT               VALUE 6.
*> Per cause: the damage type id (§4.7) and the fixed amount (0: the fall formula, the attacker's
*> held item (§10.4), or the command sets health to 0 directly).
 01 RULE-CAUSE-DATA.
    05 FILLER BINARY-LONG VALUE 1.              *> fall: cobolcraft:impact
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 28.             *> abend: cobolcraft:mob_attack
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 29.             *> player: cobolcraft:player_attack
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 30.             *> starvation: cobolcraft:starvation
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 31.             *> hail: cobolcraft:hail
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.              *> command: cobolcraft:generic
    05 FILLER BINARY-LONG VALUE 0.
 01 RULE-CAUSE-TABLE REDEFINES RULE-CAUSE-DATA.
    05 RULE-CAUSE OCCURS 6 TIMES.
       10 RULE-CAUSE-TYPE    BINARY-LONG.
       10 RULE-CAUSE-AMOUNT  BINARY-LONG.
*> Starvation (§10.3): 1 damage every 60th consecutive tick at food 0.
 78 RULE-STARVE-TICKS         VALUE 60.
*> Attacks (§10.4): a hit reaches at most 4.0 blocks from the attacker's eye point, feet + (0, 1.6, 0),
*> to the nearest point of the target's collision box.
 78 RULE-ATTACK-REACH-MILLI   VALUE 4000.
 78 RULE-ATTACK-EYE-MILLI     VALUE 1600.
*> Recovery (§10.5): while food is at least 20 and health below the maximum, every 50th consecutive
*> tick gives 1 health and 2.5 exhaustion.
 78 RULE-RECOVER-FOOD         VALUE 20.
 78 RULE-RECOVER-TICKS        VALUE 50.
 78 RULE-RECOVER-AMOUNT       VALUE 1.
 78 RULE-RECOVER-EXHAUST-MILLI VALUE 2500.
*> Death drops (§10.6): slot s (0 to 35) becomes a ground item at the feet + (0, 0.5, 0) with motion
*> (((s mod 6) x 2 - 5) x 0.02, 0.2, (((s div 6) mod 6) x 2 - 5) x 0.02) and pickup delay 30.
 78 RULE-DEATH-DY-MILLI       VALUE 500.
 78 RULE-DEATH-SPREAD-MILLI   VALUE 20.
 78 RULE-DEATH-LIFT-MILLI     VALUE 200.
 78 RULE-DEATH-DELAY          VALUE 30.
*> Hunger and eating (§11.2, §11.3, §11.6; US8). Exhaustion amounts in THOUSANDTHS. The movement
*> speeds of §11.4 are the client's and are not core rules.
*> Exhaustion (§11.2): every tick 0.005; per block of horizontal distance 0.02 walking and 0.12
*> running (sprinting), neither while flying; per jump 0.3; per hit 0.15; per completed survival
*> break 0.025 (recovery's 2.5 is RULE-RECOVER-EXHAUST-MILLI).
 78 RULE-EXHAUST-TICK-MILLI   VALUE 5.
 78 RULE-EXHAUST-WALK-MILLI   VALUE 20.
 78 RULE-EXHAUST-SPRINT-MILLI VALUE 120.
 78 RULE-EXHAUST-JUMP-MILLI   VALUE 300.
 78 RULE-EXHAUST-ATTACK-MILLI VALUE 150.
 78 RULE-EXHAUST-BREAK-MILLI  VALUE 25.
*> Food point removal (§11.3): whenever exhaustion is at least 5.0, 5.0 is subtracted and food
*> (if above 0) decreases by 1.
 78 RULE-EXHAUST-FOOD-MILLI   VALUE 5000.
*> Eating (§11.6): the eating time is 30 ticks; completion sends Entity Event 9 (eating finished).
 78 RULE-EAT-TICKS            VALUE 30.
 78 RULE-EAT-EVENT            VALUE 9.
