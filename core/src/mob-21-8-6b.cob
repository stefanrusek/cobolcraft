*> The fires of a lightning bolt (docs/protocol/21 section 8.6 spawnFire, 29b-8 sections 2.1 to 2.3 and 2.8, 33 section 8; lane p49t, T39000). The strike of a bolt that is not visual-only
*> (LIGHTNING-FIRST) tries the bolt's own cell and then 4 cells of the 3 x 3 x 3 block around it (nextInt(3) - 1 for x, y, z) on Normal and Hard; every later flash (LIGHTNING-STEP) tries the
*> own cell at every difficulty (spawnFire(0)). Nothing happens unless canSpreadFireAround holds (the rule fire_spread_radius_around_player: -1, or a non-spectator player of the dimension
*> strictly closer than the radius to the block position). A cell takes fire when it is air and the fire can survive there: soul fire above soul sand or soul soil (the tag soul_fire_base_blocks);
*> otherwise a fire that survives on a block with a solid top (the approximation of a sturdy up face the flint and steel code uses) or beside a block that can burn; a fire with neither a burning nor
*> a solid block below has the flag of each of north, east, south, west and up whose neighbour can burn. The random source is the hash of xp.cob (XP-RANDOM), not the bolt's own random.
*>
*>   FIRE-CAN-BURN USING dim, x, y, z, can out      FireBlock.canBurn of the block there: its ignite odds are above 0 (TOOL-FLAMMABILITY) and it is not waterlogged
*>   FIRE-STATE-AT USING dim, x, y, z, state out, survive out    BaseFireBlock.getState (2.2) and canSurvive (2.3) for the cell
*>   FIRE-TRY USING dim, x, y, z, placed out        places that state when the cell is air and the fire survives there
*>   FIRE-SPREAD-OK USING dim, x, y, z, ok out      Level.canSpreadFireAround
*>   LIGHTNING-SPAWN-FIRE USING bolt row, n          LightningBolt.spawnFire(n)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIRE-CAN-BURN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-LONG                PIC X(48).
 01 WS-KEY                 PIC X(48).
 01 WS-IGNITE              BINARY-LONG.
 01 WS-BURN                BINARY-LONG.
 01 WS-MODE-GET            BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(24) VALUE "waterlogged".
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-CAN.
     MOVE 0 TO L-CAN
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-LONG
     CALL "KEY-BARE" USING WS-LONG WS-KEY
     CALL "TOOL-FLAMMABILITY" USING WS-KEY WS-IGNITE WS-BURN
     IF WS-IGNITE > 0
         MOVE SPACES TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-MODE-GET WS-STATE WS-NAME WS-TEXT WS-RESULT
         IF WS-TEXT NOT = "true"
             MOVE 1 TO L-CAN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FIRE-CAN-BURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIRE-STATE-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WS-BELOW               BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-LONG                PIC X(48).
 01 WS-KEY                 PIC X(48).
 01 WS-LONG-KEY            PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-BURNS               BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-BELOW-BURNS         BINARY-LONG.
 01 WS-STURDY              BINARY-LONG.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(24).
 01 WS-TRUE                PIC X(32) VALUE "true".
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-SURVIVE.
     COMPUTE WS-BY = L-Y - 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-BY L-Z WS-BELOW
     MOVE CB-KEY(CB-S-BLOCK(WS-BELOW + 1) + 1) TO WS-LONG
     CALL "KEY-BARE" USING WS-LONG WS-KEY
     MOVE SPACES TO WS-LONG-KEY
     IF WS-KEY = "soul_sand" OR "soul_soil"
         MOVE "minecraft:soul_fire" TO WS-LONG-KEY
     ELSE
         MOVE "minecraft:fire" TO WS-LONG-KEY
     END-IF
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-LONG-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO L-STATE
     IF WS-KEY = "soul_sand" OR "soul_soil"
         MOVE 1 TO L-SURVIVE
         GOBACK
     END-IF
     MOVE CB-SOLID(CB-S-BLOCK(WS-BELOW + 1) + 1) TO WS-STURDY
     CALL "FIRE-CAN-BURN" USING L-DIM L-X WS-BY L-Z WS-BELOW-BURNS
     MOVE WS-BELOW-BURNS TO WS-ANY
*>   The five side neighbours (the sixth is the one below); the flags only when nothing below can hold the fire.
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 5
         MOVE L-X TO WS-NX
         MOVE L-Y TO WS-NY
         MOVE L-Z TO WS-NZ
         EVALUATE WS-D
             WHEN 1
                 SUBTRACT 1 FROM WS-NZ
                 MOVE "north" TO WS-NAME
             WHEN 2
                 ADD 1 TO WS-NX
                 MOVE "east" TO WS-NAME
             WHEN 3
                 ADD 1 TO WS-NZ
                 MOVE "south" TO WS-NAME
             WHEN 4
                 SUBTRACT 1 FROM WS-NX
                 MOVE "west" TO WS-NAME
             WHEN OTHER
                 ADD 1 TO WS-NY
                 MOVE "up" TO WS-NAME
         END-EVALUATE
         CALL "FIRE-CAN-BURN" USING L-DIM WS-NX WS-NY WS-NZ WS-BURNS
         IF WS-BURNS = 1
             MOVE 1 TO WS-ANY
             IF WS-BELOW-BURNS = 0 AND WS-STURDY = 0
                 CALL "BLOCK-STATE-PROP" USING WS-MODE-SET L-STATE WS-NAME WS-TRUE WS-NEW
                 MOVE WS-NEW TO L-STATE
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-ANY TO L-SURVIVE
     IF WS-STURDY = 1
         MOVE 1 TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM FIRE-STATE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIRE-TRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-SURVIVE             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-PLACED.
     MOVE 0 TO L-PLACED
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         CALL "FIRE-STATE-AT" USING L-DIM L-X L-Y L-Z WS-FIRE WS-SURVIVE
         IF WS-SURVIVE = 1
             CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-FIRE
             MOVE 1 TO L-PLACED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FIRE-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIRE-SPREAD-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RULE-NAME           PIC X(40) VALUE "fire_spread_radius_around_player".
 01 WS-RADIUS              BINARY-DOUBLE.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST2               FLOAT-LONG.
 01 WS-LIMIT2              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RADIUS
     IF WS-RADIUS = -1
         MOVE 1 TO L-OK
         GOBACK
     END-IF
     COMPUTE WS-LIMIT2 = WS-RADIUS * WS-RADIUS
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR L-OK = 1
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = L-DIM AND PL-MODE(WS-P) < 3
             COMPUTE WS-DX = PL-X(WS-P) - L-X
             COMPUTE WS-DY = PL-Y(WS-P) - L-Y
             COMPUTE WS-DZ = PL-Z(WS-P) - L-Z
             COMPUTE WS-DIST2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-DIST2 < WS-LIMIT2
                 MOVE 1 TO L-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FIRE-SPREAD-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-SPAWN-FIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9621.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-N.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0 OR PJ-I3(WS-SLOT) = 1
         GOBACK
     END-IF
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "FIRE-SPREAD-OK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "FIRE-TRY" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-PLACED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         CALL "XP-RANDOM" USING WS-SALT WS-THREE WS-DRAW
         COMPUTE WS-CX = WS-BX + WS-DRAW - 1
         CALL "XP-RANDOM" USING WS-SALT WS-THREE WS-DRAW
         COMPUTE WS-CY = WS-BY + WS-DRAW - 1
         CALL "XP-RANDOM" USING WS-SALT WS-THREE WS-DRAW
         COMPUTE WS-CZ = WS-BZ + WS-DRAW - 1
         CALL "FIRE-TRY" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-PLACED
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHTNING-SPAWN-FIRE.
