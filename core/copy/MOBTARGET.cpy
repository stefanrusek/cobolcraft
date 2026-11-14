*> TargetingConditions test input (docs/protocol/18-mob-framework.md section 4.3): the conditions of the test and the facts about
*> attacker and target that the caller reads from the world. Flags are 1 (yes) or 0. TC-RANGE <= 0 means unlimited range.
 01 TC-RECORD.
    05 TC-COMBAT            BINARY-LONG.
    05 TC-IGNORE-LOS        BINARY-LONG.
    05 TC-HAS-SELECTOR      BINARY-LONG.
    05 TC-SELECTOR-OK       BINARY-LONG.
    05 TC-SAME              BINARY-LONG.
    05 TC-VISIBLE-ANYONE    BINARY-LONG.
    05 TC-HAS-ATTACKER      BINARY-LONG.
    05 TC-INVULNERABLE      BINARY-LONG.
    05 TC-PEACEFUL          BINARY-LONG.
    05 TC-CAN-ATTACK        BINARY-LONG.
    05 TC-ALLIED            BINARY-LONG.
    05 TC-ATTACKER-IS-MOB   BINARY-LONG.
    05 TC-LINE-OF-SIGHT     BINARY-LONG.
    05 TC-RANGE             FLOAT-LONG.
    05 TC-VISIBILITY        FLOAT-LONG.
    05 TC-DIST-SQ           FLOAT-LONG.
