*> Creaking (002-lane-p49b; docs/protocol/20-mobs-overworld-hostile.md section 17), and the melee cooldown of the standard mobs whose goal list gives their own.
*> Entry points:
*>   STDMOB-ATTACK-GAP USING table row, gap out: the ticks between two melee hits of a standard mob: the creaking's fight activity melee has a cooldown of 40 (20 section 17), the
*>     warden's 18 (20 section 15); every other row the SM-ATTACK-TICKS of the table (MeleeAttackGoal, 20 section 4.1).
*>   Not here: the freeze-when-watched rule (checkCanMove / isLookingAtMe: the document names the call and its tolerance 0.5 but has no vector test, line-of-sight rule or
*>     nearest-player list), the creaking_active environment attribute, the heart binding (spawnProtector, home position, teardown) and the heart block entity's constants.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ATTACK-GAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 LINKAGE SECTION.
 01 L-M                    BINARY-LONG.
 01 L-GAP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-GAP.
     EVALUATE SM-KEY(L-M)
         WHEN "creaking"
             MOVE 40 TO L-GAP
         WHEN "warden"
             MOVE 18 TO L-GAP
         WHEN OTHER
             MOVE SM-ATTACK-TICKS TO L-GAP
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-ATTACK-GAP.
