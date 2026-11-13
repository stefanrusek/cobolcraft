*> Shared player rules (docs/protocol/17 section 4.7, 4.9, 4.11; both world types). Tested by
*> core/tests/acc_f2us2_shared_rules.cob and test_content_tables.cob.
*> Maximum health (the max_health attribute, 17 section 4.10): 20 for new and respawned players.
 78 RULE-MAX-HEALTH           VALUE 20.
*> Maximum food level (17 section 4.9): 20; a new player has food 20 and saturation 5.0.
 78 RULE-MAX-AIR              VALUE 300.
 78 RULE-MAX-FOOD             VALUE 20.
 78 RULE-START-SATURATION     VALUE 5.
*> Day length (shared rule of both world types, docs/protocol/33 §3, 12 §3.2c): the time of day runs 0..23999,
*> advancing 1 per tick and wrapping to 0. A level.dat of feature 001 (30000-tick day) is re-based on opening
*> (LEVEL-TIME-REBASE).
 78 RULE-DAY-LENGTH           VALUE 24000.
 78 RULE-OLD-DAY-LENGTH       VALUE 30000.
*> Ground items: the stand-in constants of standin-content §9 (delays 6 and 30, gravity 0.035, drag 0.97, lifetime 4800, pickup reach
*> 0.75 and 0.25, no merging) were replaced by docs/protocol/41-item-entity-physics.md; its constants are in CITEMPHYS.cpy (IP-*).
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
*> CAUSE-MOB (002-lane-mobs): a standard mob's melee hit on a player (damage type mob_attack, armor applies, 17 section 4.12).
 78 CAUSE-MOB                VALUE 7.
 78 CAUSE-DROWN               VALUE 8.
 *> CAUSE-EXPLOSION (002-lane-mobs2): an explosion (damage type explosion, 20 section 6.2); armor applies.
 78 CAUSE-EXPLOSION           VALUE 9.
 *> CAUSE-ARROW (002-lane-mobs2): an arrow (damage type arrow, 44 section 7.3); armor applies.
 78 CAUSE-ARROW               VALUE 10.
 78 CAUSE-COUNT               VALUE 10.
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
    05 FILLER BINARY-LONG VALUE 28.             *> mob: mob_attack (the standard set looks the id up by key: DAMAGE-TYPE-ID)
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 100.           *> exhaustion
    05 FILLER BINARY-LONG VALUE 6.              *> drown: minecraft:drown (the sixth of the 51 types sorted by path, 17 4.12)
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 0.             *> exhaustion
    05 FILLER BINARY-LONG VALUE 0.             *> explosion: the standard set looks the id up by key (DAMAGE-TYPE-ID)
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 100.           *> exhaustion
    05 FILLER BINARY-LONG VALUE 0.             *> arrow: the standard set looks the id up by key (DAMAGE-TYPE-ID)
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 100.           *> exhaustion
 01 RULE-CAUSE-TABLE REDEFINES RULE-CAUSE-DATA.
    05 RULE-CAUSE OCCURS 10 TIMES.
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
