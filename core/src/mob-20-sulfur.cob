*> The sulfur cube: BODY slot, archetypes, swallowing, shearing, the explosive fuse and the hot contact damage (docs/protocol/20 section 18.2, 45-5; 002-lane-p49n). State: P49NSTATE.cpy
*> (PN-BODY, PN-FUSE, PN-MAXFUSE), SULFARCH.cpy (the table of the 12 archetypes). Archetypes of the body item are found by the item tags minecraft:sulfur_cube_archetype/<name>.
*>
*>   SULFUR-ARCH-MASK USING item id, mask out: bit n (value 2 ** (n - 1)) for every archetype n of SULFARCH.cpy whose item tag holds the item; 0 = not swallowable (the union is the tag
*>     sulfur_cube_swallowable).
*>   SULFUR-DATA USING tracker row, buoyant out, fuse out, power out, contact out (thousandths): the data of the archetypes that match the body item (buoyant if any is, the explosion data of
*>     the explosive one, the contact damage of the hot one; 0 for none or an empty body).
*>   SULFUR-BABY USING tracker row, baby out: size 1 is the baby form (setSize(1, true) makes a non-baby a baby).
*>   SULFUR-EQUIP USING tracker row, item id (0 based), previous out (-1 none): the BODY slot takes the item; the previous body item is returned for the caller to drop.
*>   SULFUR-DROP-BODY USING tracker row: the body item is dropped as a ground item at the passenger attachment point (the cube's top) and the slot is empty.
*>   SULFUR-PICKUP-TICK USING tracker row: pickUpItem (Mob.aiStep loot pickup, 18 section 2.7): a cube that is not a baby, with an empty BODY slot and mob_griefing on takes one item of a
*>     swallowable ground stack within 1 block horizontally of its box (no pickup delay); the stack loses one item.
*>   SULFUR-USE USING player row, entity row, held key (PIC X(24)): mobInteract: shears with a body item drop it (the shears lose 1); flint and steel or a fire charge prime an explosive cube
*>     with the normal fuse (the item is used); a swallowable held item is given to a cube that is not a baby (it replaces and drops the current body item; the held stack loses one).
*>   SULFUR-PRIME USING tracker row, short fuse (0 or 1), primed out: primeTime: needs an explosive body, a live cube, tnt_explodes on and no fuse running; fuse = the archetype's, or
*>     nextInt(max(1, fuse / 4)) + fuse / 8 when short; PN-MAXFUSE is set (metadata 19).
*>   SULFUR-HURT USING tracker row, cause, handled out: a primed cube is invulnerable (handled 1); a fire cause (in_fire, on_fire, lava, sulfur_cube_hot) primes with the normal fuse and an
*>     explosion primes with the short one (the hit is then ignored).
*>   SULFUR-CONTACT USING tracker row: a hot body: every living mob whose box overlaps the cube's takes 1.0 of sulfur_cube_hot damage.
*>   SULFUR-DEATH USING tracker row: the body item drops (guaranteed). SULFUR-SPLIT USING tracker row, count: 0 when primed.
*>   SULFUR-TICK USING tracker row: the pickup, the contact damage and the fuse: a fuse above 0 counts down; at 0 the cube explodes at (x, y + 0.0625, z) with the archetype's power and no fire,
*>     destroying blocks when mob_griefing is on and not when it is off (no explosion when tnt_explodes is off), and is discarded without splitting.
*> Not here: the tempt goal and the search for items (they need the move control of 20 section 10), the hop movement, buoyancy and per-size speed, the bucket (pick-up conditions and the bucket item
*> are not documented), the pickup timer, a redstone signal priming it, burning arrows, the player as a victim of the contact damage, the immune damage tag, the sound and game events.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-ARCH-MASK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SULFARCH.
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-MASK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-MASK.
     MOVE 0 TO L-MASK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SA-COUNT
         MOVE SPACES TO WS-TAG
         STRING "minecraft:sulfur_cube_archetype/" DELIMITED BY SIZE SA-NAME(WS-I) DELIMITED BY SPACE INTO WS-TAG
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-ITEM WS-HAS
         IF WS-HAS = 1
             COMPUTE L-MASK = L-MASK + 2 ** (WS-I - 1)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SULFUR-ARCH-MASK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 COPY SULFARCH.
 01 WS-MASK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BUOYANT              BINARY-LONG.
 01 L-FUSE                 BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-CONTACT              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BUOYANT L-FUSE L-POWER L-CONTACT.
     MOVE 0 TO L-BUOYANT L-FUSE L-POWER L-CONTACT
     CALL "PN-ROW-OPEN" USING L-ROW
     IF PN-BODY(L-ROW) = 0
         GOBACK
     END-IF
     COMPUTE WS-I = PN-BODY(L-ROW) - 1
     CALL "SULFUR-ARCH-MASK" USING WS-I WS-MASK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SA-COUNT
         COMPUTE WS-BIT = FUNCTION MOD(WS-MASK / 2 ** (WS-I - 1), 2)
         IF WS-BIT = 1
             IF SA-BUOYANT(WS-I) = 1
                 MOVE 1 TO L-BUOYANT
             END-IF
             IF SA-FUSE(WS-I) > 0
                 MOVE SA-FUSE(WS-I) TO L-FUSE
                 MOVE SA-POWER(WS-I) TO L-POWER
             END-IF
             IF SA-CONTACT-MILLI(WS-I) > 0
                 MOVE SA-CONTACT-MILLI(WS-I) TO L-CONTACT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SULFUR-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BABY.
     MOVE 0 TO L-BABY
     IF EN-VARIANT(L-ROW) <= 1
         MOVE 1 TO L-BABY
     END-IF
     GOBACK.
 END PROGRAM SULFUR-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-EQUIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-PREVIOUS             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-PREVIOUS.
     CALL "PN-ROW-OPEN" USING L-ROW
     COMPUTE L-PREVIOUS = PN-BODY(L-ROW) - 1
     COMPUTE PN-BODY(L-ROW) = L-ITEM + 1
     GOBACK.
 END PROGRAM SULFUR-EQUIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-DROP-ITEM.
*> USING tracker row, item id: one such item as a ground item at the cube's passenger attachment point (its top).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-Y              FLOAT-LONG VALUE 0.
 01 WS-ZERO-Z              FLOAT-LONG VALUE 0.
 01 WS-UP                  FLOAT-LONG VALUE 0.2.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM.
     COMPUTE WS-SIZE = FUNCTION MAX(EN-VARIANT(L-ROW), 1)
     MOVE EN-X(L-ROW) TO WS-X
     COMPUTE WS-Y = EN-Y(L-ROW) + 0.49 * WS-SIZE
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "GI-SPAWN" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-ZERO WS-UP WS-ZERO-Z L-ITEM WS-COUNT WS-DELAY WS-ITEM-ROW
     GOBACK.
 END PROGRAM SULFUR-DROP-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-DROP-BODY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-ROW-OPEN" USING L-ROW
     IF PN-BODY(L-ROW) > 0
         COMPUTE WS-ITEM = PN-BODY(L-ROW) - 1
         MOVE 0 TO PN-BODY(L-ROW)
         CALL "SULFUR-DROP-ITEM" USING L-ROW WS-ITEM
     END-IF
     GOBACK.
 END PROGRAM SULFUR-DROP-BODY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-PICKUP-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 COPY CITEMS.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-BABY                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-PREVIOUS            BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-ROW-OPEN" USING L-ROW
     CALL "SULFUR-BABY" USING L-ROW WS-BABY
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-BABY = 1 OR WS-RULE = 0 OR PN-BODY(L-ROW) NOT = 0
         GOBACK
     END-IF
     COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) * FUNCTION MAX(EN-VARIANT(L-ROW), 1) / 2000 + 1
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) * FUNCTION MAX(EN-VARIANT(L-ROW), 1) / 1000
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-DONE = 1
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-DIM(WS-E) = EN-DIM(L-ROW)
                 AND EN-ITEM-COUNT(WS-E) > 0 AND EN-DELAY(WS-E) <= 0
             IF FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) < WS-HALF AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) < WS-HALF
                     AND EN-Y(WS-E) >= EN-Y(L-ROW) - 0.25 AND EN-Y(WS-E) < EN-Y(L-ROW) + WS-HEIGHT
                 CALL "SULFUR-ARCH-MASK" USING EN-ITEM(WS-E) WS-MASK
                 IF WS-MASK > 0
                     CALL "SULFUR-EQUIP" USING L-ROW EN-ITEM(WS-E) WS-PREVIOUS
                     SUBTRACT 1 FROM EN-ITEM-COUNT(WS-E)
                     IF EN-ITEM-COUNT(WS-E) = 0
                         CALL "ENTITY-REMOVE" USING WS-E
                     END-IF
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SULFUR-PICKUP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-PRIME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 COPY XORO.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-BUOYANT             BINARY-LONG.
 01 WS-FUSE                BINARY-LONG.
 01 WS-POWER               BINARY-LONG.
 01 WS-CONTACT             BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SHORT                BINARY-LONG.
 01 L-PRIMED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SHORT L-PRIMED.
     MOVE 0 TO L-PRIMED
     CALL "PN-ROW-OPEN" USING L-ROW
     CALL "SULFUR-DATA" USING L-ROW WS-BUOYANT WS-FUSE WS-POWER WS-CONTACT
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-FUSE = 0 OR WS-RULE = 0 OR PN-MAXFUSE(L-ROW) > 0 OR EN-HEALTH(L-ROW) = 0
         GOBACK
     END-IF
     IF L-SHORT = 1
         COMPUTE WS-BOUND = FUNCTION MAX(1, WS-FUSE / 4)
         COMPUTE WS-SEED = EN-ID(L-ROW) * 1000003 + CW-TICKS * 11 + 5
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "XORO-NEXT-INT" USING XR-STATE WS-BOUND WS-DRAW
         COMPUTE WS-FUSE = WS-DRAW + WS-FUSE / 8
     END-IF
     MOVE WS-FUSE TO PN-FUSE(L-ROW) PN-MAXFUSE(L-ROW)
     MOVE 1 TO L-PRIMED
     CALL "STDMOB-FLAGS-SEND" USING L-ROW
     GOBACK.
 END PROGRAM SULFUR-PRIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY RULES.
 COPY P49NSTATE.
 01 WS-M                   BINARY-LONG.
 01 WS-SHORT               BINARY-LONG.
 01 WS-PRIMED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAUSE L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     IF SM-KEY(WS-M) NOT = "sulfur_cube"
         GOBACK
     END-IF
     CALL "PN-ROW-OPEN" USING L-ROW
     IF PN-MAXFUSE(L-ROW) > 0
         MOVE 1 TO L-HANDLED
         GOBACK
     END-IF
     EVALUATE L-CAUSE
         WHEN CAUSE-IN-FIRE
         WHEN CAUSE-ON-FIRE
         WHEN CAUSE-LAVA
         WHEN CAUSE-SULFUR-HOT
             MOVE 0 TO WS-SHORT
             CALL "SULFUR-PRIME" USING L-ROW WS-SHORT WS-PRIMED
             IF WS-PRIMED = 1
                 MOVE 1 TO L-HANDLED
             END-IF
         WHEN CAUSE-EXPLOSION
             MOVE 1 TO WS-SHORT
             CALL "SULFUR-PRIME" USING L-ROW WS-SHORT WS-PRIMED
             IF WS-PRIMED = 1
                 MOVE 1 TO L-HANDLED
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SULFUR-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 01 WS-BABY                BINARY-LONG.
 01 WS-COST                BINARY-LONG VALUE 1.
 01 WS-BROKE               BINARY-LONG.
 01 WS-SHORT               BINARY-LONG VALUE 0.
 01 WS-PRIMED              BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-PREVIOUS            BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HELD                 PIC X(24).
 PROCEDURE DIVISION USING L-PLAYER L-ENTITY L-HELD.
     CALL "PN-ROW-OPEN" USING L-ENTITY
     EVALUATE TRUE
         WHEN L-HELD = "shears" AND PN-BODY(L-ENTITY) > 0
             CALL "SULFUR-DROP-BODY" USING L-ENTITY
             CALL "TOOL-HURT-STACK" USING PL-CONN(L-PLAYER) PL-HELD(L-PLAYER) WS-COST WS-BROKE
         WHEN L-HELD = "flint_and_steel" OR "fire_charge"
             CALL "SULFUR-PRIME" USING L-ENTITY WS-SHORT WS-PRIMED
             IF WS-PRIMED = 1
                 IF L-HELD = "flint_and_steel"
                     CALL "TOOL-HURT-STACK" USING PL-CONN(L-PLAYER) PL-HELD(L-PLAYER) WS-COST WS-BROKE
                 ELSE
                     CALL "MOB-TAKE" USING L-PLAYER
                 END-IF
             END-IF
         WHEN OTHER
             CALL "SULFUR-BABY" USING L-ENTITY WS-BABY
             IF WS-BABY = 0 AND PL-SLOT-COUNT(L-PLAYER, PL-HELD(L-PLAYER) + 1) > 0
                 MOVE PL-SLOT-ITEM(L-PLAYER, PL-HELD(L-PLAYER) + 1) TO WS-ITEM
                 CALL "SULFUR-ARCH-MASK" USING WS-ITEM WS-MASK
                 IF WS-MASK > 0
                     CALL "SULFUR-EQUIP" USING L-ENTITY WS-ITEM WS-PREVIOUS
                     IF WS-PREVIOUS >= 0
                         CALL "SULFUR-DROP-ITEM" USING L-ENTITY WS-PREVIOUS
                     END-IF
                     CALL "MOB-TAKE" USING L-PLAYER
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SULFUR-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-CONTACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY RULES.
 01 WS-BUOYANT             BINARY-LONG.
 01 WS-FUSE                BINARY-LONG.
 01 WS-POWER               BINARY-LONG.
 01 WS-CONTACT             BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-OHALF               FLOAT-LONG.
 01 WS-OHEIGHT             FLOAT-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-SULFUR-HOT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SULFUR-DATA" USING L-ROW WS-BUOYANT WS-FUSE WS-POWER WS-CONTACT
     IF WS-CONTACT = 0
         GOBACK
     END-IF
     COMPUTE WS-AMOUNT = FUNCTION MAX(1, WS-CONTACT / 1000)
     COMPUTE WS-SIZE = FUNCTION MAX(EN-VARIANT(L-ROW), 1)
     COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) * WS-SIZE / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) * WS-SIZE / 1000
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-HEALTH(WS-E) > 0 AND EN-DIM(WS-E) = EN-DIM(L-ROW)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 COMPUTE WS-OHALF = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
                 COMPUTE WS-OHEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                 IF FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) < WS-HALF + WS-OHALF
                         AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) < WS-HALF + WS-OHALF
                         AND EN-Y(WS-E) < EN-Y(L-ROW) + WS-HEIGHT AND EN-Y(WS-E) + WS-OHEIGHT > EN-Y(L-ROW)
                     CALL "HEALTH-MOB-DAMAGE" USING WS-E WS-AMOUNT WS-CAUSE WS-NONE
                     CALL "MOB-HURT-BY-MOB" USING WS-E L-ROW
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SULFUR-CONTACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NO-FIRE             BINARY-LONG VALUE 0.
 COPY CORESTATE.
 COPY P49NSTATE.
 01 WS-TNT-RULE            PIC X(40) VALUE "tnt_explodes".
 01 WS-GRIEF-RULE          PIC X(40) VALUE "mob_griefing".
 01 WS-TNT                 BINARY-DOUBLE.
 01 WS-GRIEF               BINARY-DOUBLE.
 01 WS-BUOYANT             BINARY-LONG.
 01 WS-FUSE                BINARY-LONG.
 01 WS-POWER               BINARY-LONG.
 01 WS-CONTACT             BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-POWERF              FLOAT-LONG.
 01 WS-DESTROY             BINARY-LONG.
 01 WS-NO-SOURCE           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-ROW-OPEN" USING L-ROW
     CALL "SULFUR-PICKUP-TICK" USING L-ROW
     CALL "SULFUR-CONTACT" USING L-ROW
     IF PN-MAXFUSE(L-ROW) = 0
         GOBACK
     END-IF
     IF PN-FUSE(L-ROW) > 0
         SUBTRACT 1 FROM PN-FUSE(L-ROW)
     END-IF
     IF PN-FUSE(L-ROW) > 0
         GOBACK
     END-IF
     CALL "SULFUR-DATA" USING L-ROW WS-BUOYANT WS-FUSE WS-POWER WS-CONTACT
     CALL "BR-RULE-GET" USING WS-TNT-RULE WS-TNT
     CALL "BR-RULE-GET" USING WS-GRIEF-RULE WS-GRIEF
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     COMPUTE WS-Y = EN-Y(L-ROW) + 0.0625
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE WS-POWER TO WS-POWERF
     MOVE 0 TO WS-DESTROY
     IF WS-GRIEF NOT = 0
         MOVE 1 TO WS-DESTROY
     END-IF
     MOVE 0 TO PN-BODY(L-ROW)
     CALL "ENTITY-REMOVE" USING L-ROW
     IF WS-TNT NOT = 0
         CALL "EXPLODE-RUN" USING WS-DIM WS-X WS-Y WS-Z WS-POWERF WS-DESTROY WS-NO-SOURCE WS-NO-FIRE
     END-IF
     GOBACK.
 END PROGRAM SULFUR-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-DEATH.
*> USING tracker row: a dying cube drops its body item (guaranteed: the drop chance of a picked-up item is 2, 18 section 7.1.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SULFUR-DROP-BODY" USING L-ROW
     GOBACK.
 END PROGRAM SULFUR-DEATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-SPLIT.
*> USING tracker row, split count (in and out): getSplitCount is 0 while the cube is primed (an exploding cube never splits), else the 2 it is given.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-COUNT.
     CALL "PN-ROW-OPEN" USING L-ROW
     IF PN-MAXFUSE(L-ROW) > 0
         MOVE 0 TO L-COUNT
     END-IF
     GOBACK.
 END PROGRAM SULFUR-SPLIT.
