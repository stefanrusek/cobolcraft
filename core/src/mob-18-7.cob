*> Damage, knockback, death, drops and experience of the mob framework (docs/protocol/18-mob-framework.md section 7; lane 002-lane-mobsfull-h13).
*>
*>   M187-RESIST USING species, resistance out (thousandths)           the knockback_resistance of a species (7.4; the species with an override in documents 19 and 21)
*>   M187-KNOCK USING row, source x, source z (FLOAT-LONG), strength, resistance (thousandths)   LivingEntity.knockback (7.4) on the velocity EN-VX, EN-VY, EN-VZ of a mob row
*>   M187-HIT USING row, attacker player row                           dealDefaultKnockback (7.4): strength 0.4 away from the attacker, the species' resistance

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-RESIST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPECIES              PIC X(24).
 01 L-MILLI                BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECIES L-MILLI.
     EVALUATE L-SPECIES
         WHEN "iron_golem"
             MOVE 1000 TO L-MILLI
         WHEN "hoglin" WHEN "zoglin"
             MOVE 600 TO L-MILLI
         WHEN "nautilus" WHEN "zombie_nautilus"
             MOVE 300 TO L-MILLI
         WHEN OTHER
             MOVE 0 TO L-MILLI
     END-EVALUATE
     GOBACK.
 END PROGRAM M187-RESIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-KNOCK.
*> USING mob tracker row, source x, source z (FLOAT-LONG), strength and resistance (BINARY-LONG thousandths): strength = strength x (1 - resistance), nothing at 0 or
*> below; (dx, dz) is the direction from the victim to the source, and while its squared length is below 1.0E-5 it is replaced by a random pair
*> ((a - b) x 0.01 each, drawn from the hash of the entity id and the time and a counter); the new velocity is x = vx / 2 - dx / |d| x strength, z likewise,
*> y = min(0.4, vy / 2 + strength) on the ground and unchanged in the air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-S                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-UP                  FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-TRY                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-RESIST               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Z L-STRENGTH L-RESIST.
     COMPUTE WS-S = L-STRENGTH * (1000 - L-RESIST) / 1000000
     IF WS-S <= 0
         GOBACK
     END-IF
     COMPUTE WS-DX = L-X - EN-X(L-ROW)
     COMPUTE WS-DZ = L-Z - EN-Z(L-ROW)
     MOVE 0 TO WS-TRY
     PERFORM UNTIL WS-DX * WS-DX + WS-DZ * WS-DZ >= 0.00001
         ADD 1 TO WS-TRY
         MOVE EN-ID(L-ROW) TO WS-ARG(1)
         MOVE CW-TICKS TO WS-ARG(2)
         MOVE 31 TO WS-ARG(3)
         MOVE WS-TRY TO WS-ARG(4)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         COMPUTE WS-Q = FUNCTION MOD(WS-R, 2001)
         COMPUTE WS-DX = (WS-Q - 1000) / 100000
         COMPUTE WS-Q = FUNCTION MOD(WS-R / 2001, 2001)
         COMPUTE WS-DZ = (WS-Q - 1000) / 100000
     END-PERFORM
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) / 2 - WS-DX / WS-LEN * WS-S
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) / 2 - WS-DZ / WS-LEN * WS-S
     IF EN-ON-GROUND(L-ROW) = 1
         COMPUTE WS-UP = FUNCTION MIN(0.4, EN-VY(L-ROW) / 2 + WS-S)
         MOVE WS-UP TO EN-VY(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M187-KNOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-HIT.
*> USING mob tracker row, attacker player row: the default knockback of a fresh hit (7.4), strength 0.4, away from the attacker.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-RESIST              BINARY-LONG.
 01 WS-STRENGTH            BINARY-LONG VALUE 400.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     CALL "M187-RESIST" USING WS-KEY WS-RESIST
     CALL "M187-KNOCK" USING L-ROW PL-X(L-ATTACKER) PL-Z(L-ATTACKER) WS-STRENGTH WS-RESIST
     GOBACK.
 END PROGRAM M187-HIT.
