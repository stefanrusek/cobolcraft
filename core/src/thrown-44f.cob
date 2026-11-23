*> Projectile deflection of lane 002-lane-mobsb6 (44 part 8 section 6.3): AIM_DEFLECT of a large fireball by a player's attack and REVERSE for any projectile row.
*> A player's attack (HEALTH-ATTACK, before the combat rules) on a projectile of the tag redirectable_projectile (here the large fireball; the wind charge does not exist yet) deflects it:
*> velocity = the player's look direction x (1, 1, 1), the player becomes the owner (the later hits use it), accelerationPower stays 0.1 (the thrust of mob-21-proj.cob is that constant).
*> REVERSE: velocity x (-0.5, -0.5, -0.5), yaw + 170 to 190 degrees (a breeze's deflection tag is not an entity here, so nothing calls it yet).
*> Gaps: the sound, the entity's deflection tag (breeze) and lastDeflectedBy, the pickable radius 1.0, game event PROJECTILE_LAND, a deflected fireball killing a ghast (the advancement).
*>
*>   PROJ-REDIRECT USING player row, tracker row, done out (1 when the row was a large fireball or a wind charge and was redirected or refused)
*>   PROJ-REVERSE USING tracker row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-REDIRECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-DONE.
     MOVE 0 TO L-DONE
     CALL "PROJ-KIND" USING EN-TYPE(L-ROW) WS-KIND
     IF WS-KIND = 1
         COMPUTE WS-YAW = PL-YAW(L-PLAYER) * FUNCTION PI / 180
         COMPUTE WS-PITCH = PL-PITCH(L-PLAYER) * FUNCTION PI / 180
         COMPUTE EN-VX(L-ROW) = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
         COMPUTE EN-VY(L-ROW) = 0 - FUNCTION SIN(WS-PITCH)
         COMPUTE EN-VZ(L-ROW) = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
         MOVE PL-ENTITY-ID(L-PLAYER) TO EN-TARGET-ID(L-ROW)
         CALL "PROJ-ROTATE" USING L-ROW
         MOVE 1 TO L-DONE
     END-IF
*>   A shulker bullet is destroyed by a hit (21 section 6.2).
     IF WS-KIND = 4
         CALL "ENTITY-REMOVE" USING L-ROW
         MOVE 1 TO L-DONE
     END-IF
*>   A wind charge is redirected onto the aim of the attacker (44 part 8 sections 6.3 and 8) unless it is in its no-deflect window; the attack does not hurt it either way.
     IF WS-KIND = 0 OR WS-KIND = 6
         CALL "WIND-REDIRECT" USING L-PLAYER L-ROW L-DONE
     END-IF
     GOBACK.
 END PROGRAM PROJ-REDIRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-REVERSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 9101.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * -0.5
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * -0.5
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * -0.5
     CALL "XP-RANDOM" USING WS-SALT WS-TWENTY WS-R
     COMPUTE EN-YAW(L-ROW) = EN-YAW(L-ROW) + 170 + WS-R
     GOBACK.
 END PROGRAM PROJ-REVERSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-PICK-RADIUS.
*> USING tracker row, radius out (BINARY-LONG, blocks): getPickRadius of the entity (44 part 8 section 6.1): 1 for a redirectable projectile (tag redirectable_projectile: a large fireball, a wind charge
*> of a player or of a breeze), else 0. The attack reach of HEALTH-ATTACK inflates the entity's box by it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RADIUS.
     MOVE 0 TO L-RADIUS
     CALL "PROJ-KIND" USING EN-TYPE(L-ROW) WS-KIND
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-KIND = 1 OR (WS-SLOT > 0 AND PJ-KIND(WS-SLOT) = 42)
         MOVE 1 TO L-RADIUS
     END-IF
     GOBACK.
 END PROGRAM PROJ-PICK-RADIUS.
