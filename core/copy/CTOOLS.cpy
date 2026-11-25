*> Per player row state of the tool and combat rules (core/src/combat.cob; docs/protocol/17 sections 4.1 and 4.7); EXTERNAL, one entry per
*> CORE-PLAYERS row. TS-OWNER is the entity id of the player the entry was written for (a row another player took over counts as empty).
*> TS-LAST-ATTACK is CW-TICKS + 1 of the last attack or held-item change (0: never, a full charge); TS-LAST-HURT the lastHurt of the hurt window
*> in thousandths of a point.
 01 CORE-TOOLSTATE EXTERNAL.
    05 TS-ENTRY OCCURS 64 TIMES.
       10 TS-OWNER            BINARY-LONG.
       10 TS-LAST-ATTACK      BINARY-DOUBLE.
       10 TS-LAST-HURT        BINARY-LONG.
       10 TS-BLOCK-START      BINARY-DOUBLE.      *> CW-TICKS + 1 when the shield was raised, 0 down
       10 TS-BLOCK-HAND       BINARY-LONG.        *> 0 the held slot, 1 the off-hand
       10 TS-SHIELD-COOLDOWN  BINARY-DOUBLE.      *> CW-TICKS + 1 until which a disabled shield cannot be raised
*>     --- 002-lane-p46e: the item in use and gliding (core/src/ranged-use.cob; 17 sections 3.9, 3.10, 3.13) ---
       10 TS-USE-START        BINARY-DOUBLE.      *> CW-TICKS + 1 when Use Item started a bow, crossbow or trident use, 0 none
       10 TS-USE-ITEM         BINARY-LONG.        *> the item id in use
       10 TS-GLIDE-TICKS      BINARY-LONG.        *> 0 not gliding, else 1 + the ticks glided (fallFlyTicks)
       10 TS-GLIDE-LAST-X     FLOAT-LONG.         *> the position of the last gliding tick (the glider's velocity is the step from it)
       10 TS-GLIDE-LAST-Y     FLOAT-LONG.
       10 TS-GLIDE-LAST-Z     FLOAT-LONG.
       10 TS-SPIN-TICKS        BINARY-LONG.        *> ticks left of a Riptide spin attack (20 at the launch), 0 none
*>     --- 002-lane-bugusein: the click Use Item On consumed (core/src/blocks.cob BLOCK-USE-ON, play.cob PLAY-PACKET) ---
       10 TS-CLICK-TICK        BINARY-DOUBLE.      *> CW-TICKS + 1 of the Use Item On that a block took (the Use Item of that tick is ignored), 0 none
*>     --- CC-0014: the goat horn (core/src/horn-use.cob; 25 part 7 section 12.2) ---
       10 TS-HORN-COOLDOWN     BINARY-DOUBLE.      *> CW-TICKS + 1 until which the goat horn is on its item cooldown (140 ticks from a use), 0 none
*>     --- CC-0014: the item in use as the viewers see it (docs/protocol/58 sections 2.1, 2.2; core/src/horn-use.cob, core/src/poses.cob USE-FLAGS-SYNC) ---
       10 TS-HORN-USE-START    BINARY-DOUBLE.      *> CW-TICKS + 1 when the use of a goat horn started (140 ticks), 0 none
       10 TS-HORN-USE-HAND     BINARY-LONG.        *> the hand of the horn use (0 the held slot, 1 the off-hand)
       10 TS-LIVING-SENT       BINARY-LONG.        *> the living entity flags byte (entry 8) last sent: 1 using an item, 2 the used hand is the off-hand (kept when the use ends)
