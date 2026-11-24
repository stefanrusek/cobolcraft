*> The end crystal (docs/protocol/21 section 6.3, 44 part 9 section 11.1; lane 002-lane-mobsb6, T9013), PJ-KIND 16: PJ-I1 show bottom (1 default), PJ-I2 permanently invulnerable. The row has EN-HEALTH 1.
*>   CRYSTAL-SPAWN USING dim, x, y, z (FLOAT-LONG, the bottom centre), show bottom, row out
*>   CRYSTAL-FIRE USING row, dragon fight level (0 or 1): in a dragon fight level a fire block is set in the crystal's cell when it holds air
*>   CRYSTAL-HURT USING row, attacker is the dragon, damage is an explosion, attacker player row, done out: ignored when the dragon hits it or it is invulnerable; otherwise the crystal is removed and, unless
*>     the damage already is an explosion, explodes with power 6.0 (blocks are destroyed)
*>   CRYSTAL-PLACE USING player row, clicked x, y, z (BINARY-LONG), placed out: EndCrystalItem.useOn (11.1): obsidian or bedrock below, air above, the 2 high cell free of solid blocks; one item is used
*> Gaps: the crystal tick (nothing calls CRYSTAL-FIRE: whether the level has a dragon fight is the End dimension, the call is not wired into the tick), the beam target (metadata 8, healing the dragon),
*> EnderDragonFight.onCrystalDestroyed and the dragon fight respawn (tryRespawn) which need the dragon (T9014 PARTIAL), entity collision of the placement box, the attacker attribution of the
*> explosion, creative attackers, the metadata 8 and 9, and the respawn pillars' permanent invulnerability is only the flag.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRYSTAL-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:end_crystal".
 01 WS-KIND                BINARY-LONG VALUE 16.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-BOTTOM               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BOTTOM L-ROW.
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-NONE L-ROW
     IF L-ROW > 0
         MOVE 1 TO EN-HEALTH(L-ROW)
         CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
         MOVE L-BOTTOM TO PJ-I1(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM CRYSTAL-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRYSTAL-FIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "fire".
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-FIRE                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FIGHT.
     IF L-FIGHT = 1
         COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-STATE
         IF WS-STATE = 0
             CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-FIRE
             CALL "BLOCK-CHANGE" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-FIRE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CRYSTAL-FIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRYSTAL-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NO-FIRE             BINARY-LONG VALUE 0.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 6.0.
 01 WS-DESTROY             BINARY-LONG VALUE 1.
 01 WS-ATTACKER            BINARY-LONG VALUE 0.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DRAGON               BINARY-LONG.
 01 L-EXPLOSION            BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DRAGON L-EXPLOSION L-PLAYER L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0 OR PJ-I2(WS-SLOT) = 1 OR L-DRAGON = 1
         GOBACK
     END-IF
     MOVE 1 TO L-DONE
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE L-PLAYER TO WS-ATTACKER
     MOVE EN-ID(L-ROW) TO WS-ID
     CALL "PJ-DROP" USING L-ROW
     IF L-EXPLOSION = 0
         CALL "EXPLODE-RUN" USING WS-DIM WS-X WS-Y WS-Z WS-POWER WS-DESTROY WS-ATTACKER WS-NO-FIRE
     END-IF
     CALL "DRAGON-CRYSTAL-DESTROYED" USING WS-ID WS-ATTACKER WS-X WS-Y WS-Z
     GOBACK.
 END PROGRAM CRYSTAL-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRYSTAL-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-PATH                PIC X(48).
 01 WS-Y1                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-X L-Y L-Z L-PLACED.
     MOVE 0 TO L-PLACED
     CALL "WORLD-GET-BLOCK" USING PL-DIM(L-PLAYER) L-X L-Y L-Z WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-PATH
     IF WS-PATH NOT = "obsidian" AND WS-PATH NOT = "bedrock"
         GOBACK
     END-IF
     COMPUTE WS-Y1 = L-Y + 1
     COMPUTE WS-Y2 = L-Y + 2
     CALL "WORLD-GET-BLOCK" USING PL-DIM(L-PLAYER) L-X WS-Y1 L-Z WS-S1
     CALL "WORLD-GET-BLOCK" USING PL-DIM(L-PLAYER) L-X WS-Y2 L-Z WS-S2
     IF WS-S1 NOT = 0
         GOBACK
     END-IF
     CALL "GI-SOLID-CELL" USING PL-DIM(L-PLAYER) L-X WS-Y2 L-Z WS-SOLID
     IF WS-SOLID = 1
         GOBACK
     END-IF
     COMPUTE WS-X = L-X + 0.5
     MOVE WS-Y1 TO WS-Y
     COMPUTE WS-Z = L-Z + 0.5
     CALL "CRYSTAL-SPAWN" USING PL-DIM(L-PLAYER) WS-X WS-Y WS-Z WS-NO WS-ROW
     IF WS-ROW > 0
         CALL "MOB-TAKE" USING L-PLAYER
         MOVE 1 TO L-PLACED
         CALL "FIGHT-RESPAWN-TRY" USING PL-DIM(L-PLAYER)
     END-IF
     GOBACK.
 END PROGRAM CRYSTAL-PLACE.
