*> Setting a mob alight (002-lane-fire, T11110; docs/protocol/18 section 2.5 and 4.4, 17 sections 3.9 and 4.11, 21 section 2.1 fireImmune, 29b-8 section 2.10): the fire count of
*> a standard mob is EN-BURN of its tracker row (M182-ENV-TICK counts it down and hurts).
*>   MOB-FIRE-IMMUNE USING tracker row, immune out   1 when the species is fire immune (M1-FLAGS bit 1 of the mob table: blaze, ghast, magma cube, strider, zombified piglin,
*>     wither skeleton, wither, ender dragon, vex, warden, zoglin, shulker and the like); an entity with no species row is not
*>   MOB-IGNITE USING tracker row, ticks   igniteForTicks: the count rises to at least ticks unless the species is fire immune (a fire aspect hit: 80 a level, a burning
*>     arrow: 100, a fire block: 160, lava: 300)
*>   FIRE-SCAN-BOX USING dimension, x, y, z (FLOAT-LONG), half width, height (FLOAT-LONG), fire out (0 none, 1 fire, 2 soul fire), snow out   the cells of the box:
*>     a fire or soul fire block (the larger damage), powder snow or a water cauldron (puts a burning entity out)
*>   COMBAT-FIRE-ASPECT USING attacker player row, victim tracker row, victim player row (one of the two is 0), item handle   Fire Aspect of the held item (the enchantment
*>     fire_aspect, 4 seconds a level, 28 section "ignite") sets the victim alight

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-FIRE-IMMUNE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY MOB181.
 01 WS-KEY                 PIC X(24).
 01 WS-R1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-IMMUNE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-IMMUNE.
     MOVE 0 TO L-IMMUNE
*>   The registry key of the entity type (the mob table of 18 section 1 covers species the stdmob rows do not: strider, wither).
     MOVE ET-KEY(EN-TYPE(L-ROW) + 1) TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-R1
     IF WS-R1 > 0
         COMPUTE L-IMMUNE = FUNCTION MOD(M1-FLAGS(WS-R1), 2)
     END-IF
     GOBACK.
 END PROGRAM MOB-FIRE-IMMUNE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-IGNITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-IMMUNE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TICKS.
     CALL "MOB-FIRE-IMMUNE" USING L-ROW WS-IMMUNE
     IF WS-IMMUNE = 0 AND EN-BURN(L-ROW) < L-TICKS
         MOVE L-TICKS TO EN-BURN(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM MOB-IGNITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIRE-SCAN-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HALF                 FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-SNOW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HALF L-HEIGHT L-FIRE L-SNOW.
     MOVE 0 TO L-FIRE L-SNOW
     COMPUTE WS-LOW = L-X - L-HALF
     COMPUTE WS-HIGH = L-X + L-HALF
     COMPUTE WS-X0 = FUNCTION INTEGER(WS-LOW)
     COMPUTE WS-X1 = FUNCTION INTEGER(WS-HIGH)
     COMPUTE WS-LOW = L-Z - L-HALF
     COMPUTE WS-HIGH = L-Z + L-HALF
     COMPUTE WS-Z0 = FUNCTION INTEGER(WS-LOW)
     COMPUTE WS-Z1 = FUNCTION INTEGER(WS-HIGH)
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y)
     COMPUTE WS-HIGH = L-Y + L-HEIGHT - 0.01
     COMPUTE WS-Y1 = FUNCTION INTEGER(WS-HIGH)
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = 0
                     EVALUATE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)
                         WHEN "fire"
                             MOVE FUNCTION MAX(L-FIRE, 1) TO L-FIRE
                         WHEN "soul_fire"
                             MOVE 2 TO L-FIRE
                         WHEN "powder_snow"
                         WHEN "water_cauldron"
                             MOVE 1 TO L-SNOW
                     END-EVALUATE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FIRE-SCAN-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. COMBAT-FIRE-ASPECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:fire_aspect".
 01 WS-ID                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ATTACKER             BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACKER L-ENTITY L-TARGET L-HANDLE.
     MOVE 0 TO WS-LEVEL
     CALL "TOOL-ENCHANT-ID" USING WS-KEY WS-ID
     IF WS-ID >= 0
         CALL "SP-ENCHANT-LEVEL" USING L-HANDLE WS-ID WS-LEVEL
     END-IF
     IF WS-LEVEL > 0
         COMPUTE WS-TICKS = WS-LEVEL * 80
         IF L-TARGET > 0
             CALL "PLAYER-IGNITE" USING L-TARGET WS-TICKS
         ELSE
             IF EN-USED(L-ENTITY) = 1
                 CALL "MOB-IGNITE" USING L-ENTITY WS-TICKS
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM COMBAT-FIRE-ASPECT.
