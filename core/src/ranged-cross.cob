*> The crossbow (docs/protocol/17 section 3.9; 25 part 7 section 9; lane 002-lane-p46e, T27012). Use Item with an uncharged crossbow starts the charge when a projectile exists (the
*> off hand's arrow or firework rocket, else an arrow of the inventory, else for a creative player the plain arrow); the tick (RANGED-TICK, after the thrown entities) completes the
*> charge when the use has lasted floor(20 (1.25 - 0.25 Quick Charge level)) = 25 - 5 L ticks: the ammunition goes into the charged_projectiles component (type 51, a VarInt count and
*> per projectile its item stack template: count 1, item id, patch with the intangible_projectile marker (22) for a free copy), one item of the ammunition is used up (nothing for a
*> creative player; the extra arrows of Multishot, 3 in all, are free marked copies). Releasing the use early only stops the charge. Use Item with a charged crossbow shoots every
*> projectile (the component becomes empty): power 3.15 for arrows (critical arrows, the pickup mode 2 for a marked copy, Piercing carried to the arrow) or 1.6 for a firework rocket
*> (a rocket from the eye less 0.15; its flight is the thrown-entity step of thrown-44d.cob), the angles 0, -10, +10 degrees about the up vector for Multishot (25 part 7 section 9.5), and
*> the crossbow takes 1 durability per projectile, 3 for a firework rocket. Not done: the loading and shot sounds, the shooter's motion added to the velocity, the firework's stars and
*> flight duration (a stack here carries no fireworks component: duration 1, no star), a crossbow in the off hand.
*>
*>   RANGED-CHARGED-READ USING stack patch handle, list out (count, then 8 item ids and 8 marker flags)   the charged projectiles (count 0: none)
*>   RANGED-SHOOT-ANGLE USING projectile count, index (0 based), spread (degrees), angle out (degrees)
*>   RANGED-CROSSBOW-USE USING player row, done out
*>   RANGED-CROSSBOW-LOAD USING player row          the charge is complete: draw the projectiles into the component
*>   RANGED-CROSSBOW-FIRE USING player row          shoot every charged projectile
*>   RANGED-TICK                                    CORE-TICK: the charge of every player's crossbow

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-CHARGED-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 51.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-LIST.
    05 L-N                 BINARY-LONG.
    05 L-ITEM              BINARY-LONG OCCURS 8 TIMES.
    05 L-FREE              BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION USING L-HANDLE L-LIST.
     MOVE 0 TO L-N
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     MOVE 1 TO WS-POS
     CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-I > 8
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-SKIP
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-ITEM
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-ADDED
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-REMOVED
         MOVE 0 TO WS-KIND
         IF WS-ADDED > 0
*>           The one added component of a free copy is the intangible_projectile marker (type 22, no payload).
             CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-KIND
         END-IF
         ADD 1 TO L-N
         MOVE WS-ITEM TO L-ITEM(L-N)
         MOVE 0 TO L-FREE(L-N)
         IF WS-KIND = 22
             MOVE 1 TO L-FREE(L-N)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RANGED-CHARGED-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-SHOOT-ANGLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP                BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-SIGN                BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-SPREAD               BINARY-LONG.
 01 L-ANGLE                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-INDEX L-SPREAD L-ANGLE.
*>   step = 2 x spread / (n - 1) (0 for one projectile), base = ((n - 1) mod 2) x step / 2, and the sign alternates from + (25 part 7 section 9.5).
     MOVE 0 TO WS-STEP
     IF L-N > 1
         COMPUTE WS-STEP = 2 * L-SPREAD / (L-N - 1)
     END-IF
     COMPUTE WS-BASE = FUNCTION MOD(L-N - 1, 2) * WS-STEP / 2
     MOVE 1 TO WS-SIGN
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= L-INDEX
         COMPUTE WS-SIGN = 0 - WS-SIGN
     END-PERFORM
     COMPUTE WS-K = (L-INDEX + 1) / 2
     COMPUTE L-ANGLE = WS-BASE + WS-SIGN * WS-K * WS-STEP
     GOBACK.
 END PROGRAM RANGED-SHOOT-ANGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-CROSSBOW-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-LIST.
    05 WS-N                BINARY-LONG.
    05 WS-ITEM             BINARY-LONG OCCURS 8 TIMES.
    05 WS-FREE             BINARY-LONG OCCURS 8 TIMES.
 01 WS-WHERE               BINARY-LONG.
 01 WS-AMMO-SLOT           BINARY-LONG.
 01 WS-AMMO                BINARY-LONG.
 01 WS-CROSSBOW            BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DONE.
     MOVE 0 TO L-DONE
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
     CALL "RANGED-CHARGED-READ" USING PL-SLOT-VAR(L-ROW, WS-SLOT) WS-LIST
     IF WS-N > 0
         CALL "RANGED-CROSSBOW-FIRE" USING L-ROW
         MOVE 1 TO L-DONE
         GOBACK
     END-IF
     CALL "RANGED-AMMO" USING L-ROW WS-CROSSBOW WS-WHERE WS-AMMO-SLOT WS-AMMO
     IF WS-WHERE > 0
         COMPUTE TS-USE-START(L-ROW) = CW-TICKS + 1
         MOVE PL-SLOT-ITEM(L-ROW, WS-SLOT) TO TS-USE-ITEM(L-ROW)
         MOVE 1 TO L-DONE
     END-IF
     GOBACK.
 END PROGRAM RANGED-CROSSBOW-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-CROSSBOW-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY CMENU.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-LEVEL-KEY           PIC X(112).
 01 WS-QUICK               BINARY-LONG.
 01 WS-MULTI               BINARY-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-WHERE               BINARY-LONG.
 01 WS-AMMO-SLOT           BINARY-LONG.
 01 WS-AMMO                BINARY-LONG.
 01 WS-CROSSBOW            BINARY-LONG VALUE 1.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-VALUE               PIC X(64).
 01 WS-POS                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 51.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MARKER              BINARY-LONG VALUE 22.
 01 WS-FREE                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
     MOVE PL-SLOT-VAR(L-ROW, WS-SLOT) TO WS-HANDLE
     MOVE "minecraft:quick_charge" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-QUICK
     MOVE FUNCTION MIN(WS-QUICK, 3) TO WS-QUICK
     CALL "TOOL-CROSSBOW-CHARGE" USING WS-QUICK WS-CHARGE
     COMPUTE WS-USED = CW-TICKS + 1 - TS-USE-START(L-ROW)
     IF WS-USED < WS-CHARGE
         GOBACK
     END-IF
*>   The charge is complete: tryLoadProjectiles. Either way the use is over (a crossbow without ammunition any more is simply not loaded).
     MOVE 0 TO TS-USE-START(L-ROW) TS-USE-ITEM(L-ROW)
     CALL "RANGED-AMMO" USING L-ROW WS-CROSSBOW WS-WHERE WS-AMMO-SLOT WS-AMMO
     IF WS-WHERE = 0
         GOBACK
     END-IF
     MOVE "minecraft:multishot" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-MULTI
     COMPUTE WS-N = 1 + 2 * WS-MULTI
     MOVE FUNCTION MIN(WS-N, 3) TO WS-N
*>   The first projectile costs one item (nothing for a creative player), the extra ones are free copies.
     MOVE 1 TO WS-POS
     CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-ONE
         CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-AMMO
         MOVE 0 TO WS-FREE
         IF WS-I > 1 OR WS-WHERE = 3 OR PL-MODE(L-ROW) = 1
             MOVE 1 TO WS-FREE
         END-IF
         IF WS-FREE = 1
             CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-ONE
             CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-ZERO
             CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-MARKER
         ELSE
             CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-ZERO
             CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-ZERO
         END-IF
     END-PERFORM
     COMPUTE WS-LENGTH = WS-POS - 1
     IF PL-MODE(L-ROW) NOT = 1
         CALL "RANGED-TAKE-AMMO" USING L-ROW WS-WHERE WS-AMMO-SLOT
     END-IF
     CALL "SP-SET-COMPONENT" USING WS-HANDLE WS-TYPE WS-VALUE WS-LENGTH
     MOVE WS-HANDLE TO PL-SLOT-VAR(L-ROW, WS-SLOT)
     MOVE PL-HELD(L-ROW) TO WS-HELD
     CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) WS-HELD
     GOBACK.
 END PROGRAM RANGED-CROSSBOW-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-CROSSBOW-FIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-LIST.
    05 WS-N                BINARY-LONG.
    05 WS-ITEM             BINARY-LONG OCCURS 8 TIMES.
    05 WS-FREE             BINARY-LONG OCCURS 8 TIMES.
 01 WS-LEVEL-KEY           PIC X(112).
 01 WS-MULTI               BINARY-LONG.
 01 WS-PIERCE              BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-ANGLE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-POWER               BINARY-LONG.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-PICKUP              BINARY-LONG.
 01 WS-CRIT                BINARY-LONG VALUE 1.
 01 WS-NO-PUNCH            BINARY-LONG VALUE 0.
 01 WS-NO-FLAME            BINARY-LONG VALUE 0.
 01 WS-ARROW               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-BROKE               BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG VALUE 51.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DEGREES             FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-INACCURACY          FLOAT-LONG VALUE 1.0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DURATION            BINARY-LONG VALUE 1.
 01 WS-STARS               BINARY-LONG VALUE 0.
 01 WS-ATTACHED            BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
     MOVE PL-SLOT-VAR(L-ROW, WS-SLOT) TO WS-HANDLE
     CALL "RANGED-CHARGED-READ" USING WS-HANDLE WS-LIST
     IF WS-N = 0
         GOBACK
     END-IF
     MOVE "minecraft:multishot" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-MULTI
     MOVE "minecraft:piercing" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-PIERCE
     COMPUTE WS-SPREAD = 10 * WS-MULTI
*>   The component is empty from the moment of the shot.
     MOVE SPACES TO WS-VALUE
     MOVE FUNCTION CHAR(1) TO WS-VALUE(1:1)
     CALL "SP-SET-COMPONENT" USING WS-HANDLE WS-TYPE WS-VALUE WS-LENGTH
     MOVE WS-HANDLE TO PL-SLOT-VAR(L-ROW, WS-SLOT)
*>   Firework power 1.6 when the list holds a rocket, else 3.15.
     MOVE 3150 TO WS-POWER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "TOOLUSE-KEY" USING WS-ITEM(WS-I) WS-KEY
         IF WS-KEY = "firework_rocket"
             MOVE 1600 TO WS-POWER
         END-IF
     END-PERFORM
     MOVE 0 TO WS-BROKE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-BROKE = 1
         COMPUTE WS-IDX = WS-I - 1
         CALL "RANGED-SHOOT-ANGLE" USING WS-N WS-IDX WS-SPREAD WS-ANGLE
         CALL "TOOLUSE-KEY" USING WS-ITEM(WS-I) WS-KEY
         MOVE 1 TO WS-DURABILITY
         IF WS-KEY = "firework_rocket"
             MOVE 3 TO WS-DURABILITY
             MOVE WS-ANGLE TO WS-DEGREES
             CALL "RANGED-DIRECTION" USING PL-YAW(L-ROW) PL-PITCH(L-ROW) WS-DEGREES WS-DX WS-DY WS-DZ
             COMPUTE WS-SPEED = WS-POWER / 1000
             CALL "RANGED-VELOCITY" USING WS-DX WS-DY WS-DZ WS-SPEED WS-INACCURACY WS-VX WS-VY WS-VZ
             MOVE PL-X(L-ROW) TO WS-X
             COMPUTE WS-Y = PL-Y(L-ROW) + 1.62 - 0.15
             MOVE PL-Z(L-ROW) TO WS-Z
             CALL "FIREWORK-SPAWN" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-ATTACHED PL-ENTITY-ID(L-ROW)
                 WS-ROW
             IF WS-ROW > 0
                 MOVE WS-VX TO EN-VX(WS-ROW)
                 MOVE WS-VY TO EN-VY(WS-ROW)
                 MOVE WS-VZ TO EN-VZ(WS-ROW)
             END-IF
         ELSE
             MOVE 1 TO WS-PICKUP
             IF WS-FREE(WS-I) = 1
                 MOVE 2 TO WS-PICKUP
             END-IF
             CALL "RANGED-ARROW-SHOT" USING L-ROW WS-ITEM(WS-I) WS-POWER WS-ANGLE WS-CRIT WS-BASE WS-PICKUP WS-PIERCE
                 WS-NO-PUNCH WS-NO-FLAME WS-ARROW
         END-IF
         MOVE PL-HELD(L-ROW) TO WS-HELD
         CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) WS-HELD WS-DURABILITY WS-BROKE
     END-PERFORM
     GOBACK.
 END PROGRAM RANGED-CROSSBOW-FIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0 AND PL-STATE(WS-ROW) = PS-ALIVE
             CALL "COMBAT-TS-CHECK" USING WS-ROW
             IF TS-USE-START(WS-ROW) > 0
                 COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
                 IF PL-SLOT-COUNT(WS-ROW, WS-SLOT) > 0 AND PL-SLOT-ITEM(WS-ROW, WS-SLOT) = TS-USE-ITEM(WS-ROW)
                     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, WS-SLOT) WS-KEY
                     IF WS-KEY = "crossbow"
                         CALL "RANGED-CROSSBOW-LOAD" USING WS-ROW
                     END-IF
                 ELSE
*>                   The held slot changed: the use is over.
                     MOVE 0 TO TS-USE-START(WS-ROW) TS-USE-ITEM(WS-ROW)
                 END-IF
             END-IF
             IF TS-SPIN-TICKS(WS-ROW) > 0
                 CALL "RANGED-SPIN" USING WS-ROW
             END-IF
             IF TS-GLIDE-TICKS(WS-ROW) > 0
                 CALL "RANGED-GLIDE-TICK" USING WS-ROW
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RANGED-TICK.
