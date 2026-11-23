*> The nautilus and the zombie nautilus as mounts (wrap I2 round 4, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md sections 10.1 to 10.4). The seat (MOB-RIDE-SEAT, y 1.1375), the saddle
*> (MOB-SADDLE-USE) and the ride (MOB-RIDE-START) are the horse family's programs of mob-18-ride.cob; the body armor, the effect of the rider, the dash and the sun are here. Per-row state:
*> WC-BODY (the armor item), WC-NAU-DASH (metadata 20) and WC-NAU-DASH-CD (dashCooldown) of core/copy/WCSTATE.cpy.
*>   NAUTILUS-HELD USING player row, entity row, handled out   10.3.1 equip and 10.2 step 3: a tame adult takes the armor of the hand into an empty BODY slot (one item), else an item that is no food rides it
*>   NAUTILUS-RIDER-JUMP USING mount row, jumped out            10.4 START_RIDING_JUMP: a saddled nautilus sets DASH and, when its cooldown is 0, the cooldown 40
*>   NAUTILUS-DASH-TICK USING row                               10.4 tick: DASH is cleared once the cooldown is below 35, the cooldown counts down
*>   NAUTILUS-RIDE-TICK USING row, done out                     10.4 server tick of a ridden one: the rider sits on the seat and gets BREATH_OF_THE_NAUTILUS (60 ticks, every 40 ticks or when absent); done 1 when saddled (the client steers)
*>   NAUTILUS-SUN USING row, table row, alive out               20 section 3.5: the burn routine and the fire tick of a zombie nautilus; a filled BODY slot (sunProtectionSlot) protects it
*> Not built: the equip sound and the restriction radius of a tame one (checkRestriction: home within 32 or 16 blocks), the dash impulse (the controlling client applies it).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-HELD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-IKIND               BINARY-LONG.
 01 WS-CONTAINS            BINARY-LONG.
 01 WS-ISLOT               BINARY-LONG.
 01 WS-SHEAR               BINARY-LONG.
 01 WS-STACK               BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-HELD                PIC X(24).
 01 WS-FOOD                BINARY-LONG.
 01 WS-TAMING              BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-SLOT-BODY           BINARY-LONG VALUE 6.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ENTITY L-HANDLED.
     MOVE 0 TO L-HANDLED
*>   canUseSlot is false for an untamed one: every equippable item passes and the interaction goes on to taming (NAUTILUS-USE ran before).
     IF EN-TAMED(L-ENTITY) = 0
         GOBACK
     END-IF
     CALL "MNT-KIND" USING L-ENTITY WS-KIND
     MOVE PL-SLOT-ITEM(L-PLAYER, PL-HELD(L-PLAYER) + 1) TO WS-ITEM
     CALL "MNT-ITEM-KIND" USING WS-ITEM WS-IKIND
     CALL "MN6-ACCEPTS" USING WS-IKIND WS-KIND WS-CONTAINS
     CALL "MN6-EQUIPPABLE" USING WS-IKIND WS-ISLOT WS-SHEAR WS-STACK
     CALL "WC-ROW-OPEN" USING L-ENTITY
     IF WS-IKIND = 4 AND WS-ISLOT = 1 AND WS-CONTAINS = 1 AND WC-BODY(L-ENTITY) = 0
         MOVE WS-ITEM TO WC-BODY(L-ENTITY)
         MOVE PL-SLOT-VAR(L-PLAYER, PL-HELD(L-PLAYER) + 1) TO WC-BODY-VAR(L-ENTITY)
         CALL "MNT-EQUIP-SEND" USING L-ENTITY WS-SLOT-BODY WS-ITEM WS-ONE
         CALL "MOB-TAKE" USING L-PLAYER
         MOVE 1 TO L-HANDLED
         GOBACK
     END-IF
*>   10.2 step 3: tame, not secondary use, and the held item is not food: the player rides.
     CALL "TOOLUSE-KEY" USING WS-ITEM WS-KEY48
     MOVE WS-KEY48 TO WS-HELD
     CALL "Q7-NAU-FOOD" USING WS-HELD WS-FOOD WS-TAMING
     IF WS-FOOD = 0
         CALL "MOB-RIDE-START" USING L-PLAYER L-ENTITY WS-STARTED
         MOVE WS-STARTED TO L-HANDLED
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-HELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-RIDER-JUMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-FRESH               BINARY-LONG VALUE 40.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-JUMPED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-JUMPED.
     MOVE 0 TO L-JUMPED
*>   canJump is isSaddled; the strength above 0 was checked by the caller. handleStartJump sets DASH; onSyncedDataUpdated(DASH) starts the cooldown when it is 0.
     IF EN-SADDLE(L-ROW) = 1
         CALL "WC-ROW-OPEN" USING L-ROW
         IF WC-NAU-DASH(L-ROW) = 0
             MOVE 1 TO WC-NAU-DASH(L-ROW)
             IF WC-NAU-DASH-CD(L-ROW) = 0
                 MOVE WS-FRESH TO WC-NAU-DASH-CD(L-ROW)
             END-IF
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
         MOVE 1 TO L-JUMPED
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-RIDER-JUMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-DASH-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WC-ROW-OPEN" USING L-ROW
     IF WC-NAU-DASH(L-ROW) = 1 AND WC-NAU-DASH-CD(L-ROW) < 35
         MOVE 0 TO WC-NAU-DASH(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     IF WC-NAU-DASH-CD(L-ROW) > 0
         SUBTRACT 1 FROM WC-NAU-DASH-CD(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-DASH-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-RIDE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-EFFECT              BINARY-LONG VALUE 39.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 60.
 01 WS-FLAGS               BINARY-LONG VALUE 7.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DONE.
     MOVE 0 TO L-DONE
     CALL "MOB-RIDE-SYNC" USING L-ROW
*>   applyEffects: the first passenger (a player) gets BREATH_OF_THE_NAUTILUS for 60 ticks, ambient, visible, with an icon, when it lacks it or the game time is a multiple of 40.
     CALL "EFFECT-LEVEL" USING EN-RIDER(L-ROW) WS-EFFECT WS-LEVEL WS-LEFT
     IF WS-LEVEL = 0 OR FUNCTION MOD(CW-TICKS, 40) = 0
         CALL "EFFECT-ADD" USING EN-RIDER(L-ROW) WS-EFFECT WS-AMPLIFIER WS-DURATION WS-FLAGS
     END-IF
*>   A saddled nautilus is controlled by its rider's client: only the dash clock runs here.
     IF EN-SADDLE(L-ROW) = 1
         CALL "NAUTILUS-DASH-TICK" USING L-ROW
         MOVE 1 TO L-DONE
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-RIDE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-SUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-ALIVE.
     CALL "WC-ROW-OPEN" USING L-ROW
*>   The sun protection slot of the zombie nautilus is BODY: a filled slot (nautilus armor has no durability) means no ignition. The fire tick is the standard one (M182-ENV-TICK).
     IF WC-BODY(L-ROW) = 0
         CALL "STDMOB-BURN" USING L-ROW L-M
     END-IF
     CALL "M182-ENV-TICK" USING L-ROW
     CALL "STDMOB-FIRE-SYNC" USING L-ROW
     MOVE 0 TO L-ALIVE
     IF EN-USED(L-ROW) = 1 AND EN-HEALTH(L-ROW) > 0
         MOVE 1 TO L-ALIVE
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-SUN.
