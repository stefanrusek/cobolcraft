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
