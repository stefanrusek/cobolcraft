*> Game rules that make a player immune to damage (docs/protocol/33 section 6): drowning_damage, fall_damage and
*> fire_damage (Player.isInvulnerableTo: a player is invulnerable to damage tagged is_drowning, is_fall or is_fire
*> while the rule is false; mobs are unaffected) and pvp (a player can damage another player only with the rule on).
*> freeze_damage has no damage cause in the core yet (no powder snow), so nothing reads it.
*>
*> Entry point: HURT-RULE-BLOCKED USING cause, attacker player row (0 = none), blocked out (1 = the rule refuses it).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HURT-RULE-BLOCKED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RULES.
 01 WS-RULE-NAME           PIC X(40).
 01 WS-VALUE               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-CAUSE                BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 01 L-BLOCKED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CAUSE L-ATTACKER L-BLOCKED.
     MOVE 0 TO L-BLOCKED
     MOVE SPACES TO WS-RULE-NAME
     EVALUATE TRUE
         WHEN L-CAUSE = CAUSE-FALL
             MOVE "fall_damage" TO WS-RULE-NAME
         WHEN L-CAUSE = CAUSE-DROWN
             MOVE "drowning_damage" TO WS-RULE-NAME
         WHEN L-CAUSE = CAUSE-ON-FIRE OR L-CAUSE = CAUSE-LAVA
             MOVE "fire_damage" TO WS-RULE-NAME
         WHEN L-CAUSE = CAUSE-PLAYER AND L-ATTACKER > 0
             MOVE "pvp" TO WS-RULE-NAME
     END-EVALUATE
     IF WS-RULE-NAME NOT = SPACES
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-VALUE
         IF WS-VALUE = 0
             MOVE 1 TO L-BLOCKED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HURT-RULE-BLOCKED.
