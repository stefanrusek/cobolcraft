*> Piglins angered by a player who touches their treasure (docs/protocol/44-residual-mob-questions-6-nether.md section 2.9; lane 002-lane-p49c, T15510).
*>   PIGLIN-GUARDED USING block key (X(48), no namespace), guarded out      1 when the block is in block tag guarded_by_piglins
*>   PIGLIN-ANGER-NEARBY USING player row, line of sight required (0/1)      angerNearbyPiglins: every piglin (not a brute) in the box of the player inflated by 16 whose
*>                                                                           brain is idle (no target, not admiring, avoiding, celebrating or riding) and, when required,
*>                                                                           that sees the player gets the anger of 600 ticks at the player (the nearest attackable player with
*>                                                                           the universal_anger rule); no broadcast. A creative or spectator player angers nobody
*>   PIGLIN-GUARDED-BREAK USING player row, state before the break          Block.playerWillDestroy: breaking a guarded block angers without line of sight
*>   PIGLIN-CONTAINER-OPENED USING player row                                 a container opened: angers with line of sight
*> Not modelled: the UNIVERSAL_ANGER memory (set with the anger; nothing reads it), the entity_drops rule path of a destroyed chest vehicle (no chest vehicles exist).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-GUARDED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-GUARDED              BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-GUARDED.
     MOVE 0 TO L-GUARDED
     EVALUATE TRUE
         WHEN L-KEY = "gold_block" OR "barrel" OR "chest" OR "ender_chest" OR "gilded_blackstone" OR "trapped_chest"
             OR "raw_gold_block" OR "shulker_box" OR "gold_ore" OR "deepslate_gold_ore" OR "nether_gold_ore"
             OR "copper_chest" OR "exposed_copper_chest" OR "weathered_copper_chest" OR "oxidized_copper_chest"
             OR "waxed_copper_chest" OR "waxed_exposed_copper_chest" OR "waxed_weathered_copper_chest" OR "waxed_oxidized_copper_chest"
             MOVE 1 TO L-GUARDED
         WHEN OTHER
*>           The sixteen coloured shulker boxes end in _shulker_box.
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
                 IF L-KEY(WS-I:12) = "_shulker_box" AND L-KEY(WS-I + 12:1) = SPACE
                     MOVE 1 TO L-GUARDED
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM PIGLIN-GUARDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-ANGER-NEARBY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RULE-NAME           PIC X(40) VALUE "universal_anger".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-E                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-SPECIES             PIC X(24).
 01 WS-LEFT                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-TICKS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-LOS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-LOS.
     IF PL-MODE(L-PLAYER) = 1 OR PL-MODE(L-PLAYER) = 3
         GOBACK
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = PL-DIM(L-PLAYER) AND EN-HEALTH(WS-E) > 0
             CALL "MOB-SPECIES-KEY" USING WS-E WS-SPECIES
         ELSE
             MOVE SPACES TO WS-SPECIES
         END-IF
         IF WS-SPECIES = "piglin"
*>           The box of the player (0.6 x 1.8) inflated by 16 meets the piglin's (0.6 x 1.95).
             COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-E) - PL-X(L-PLAYER))
             COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-E) - PL-Z(L-PLAYER))
             COMPUTE WS-LOW = PL-Y(L-PLAYER) - 16 - 1.95
             COMPUTE WS-HIGH = PL-Y(L-PLAYER) + 1.8 + 16
             CALL "PGB-AVOID-LEFT" USING WS-E WS-LEFT
             MOVE WS-LEFT TO WS-TICKS
             CALL "PGB-CELEBRATE-LEFT" USING WS-E WS-LEFT
             IF WS-DX <= 16.6 AND WS-DZ <= 16.6 AND EN-Y(WS-E) >= WS-LOW AND EN-Y(WS-E) <= WS-HIGH
                 AND EN-TARGET(WS-E) = 0 AND EN-ADMIRE(WS-E) = 0 AND EN-MOUNT(WS-E) = 0
                 AND WS-TICKS = 0 AND WS-LEFT = 0
                 MOVE 1 TO WS-SEES
                 IF L-LOS = 1
                     COMPUTE WS-AY = EN-Y(WS-E) + 1.74
                     COMPUTE WS-BY = PL-Y(L-PLAYER) + 1.62
                     MOVE EN-X(WS-E) TO WS-AX
                     MOVE EN-Z(WS-E) TO WS-AZ
                     MOVE PL-X(L-PLAYER) TO WS-BX
                     MOVE PL-Z(L-PLAYER) TO WS-BZ
                     CALL "MOB-SEES" USING EN-DIM(WS-E) WS-AX WS-AY WS-AZ WS-BX WS-BY WS-BZ WS-SEES
                 END-IF
                 IF WS-SEES = 1
                     MOVE L-PLAYER TO WS-TARGET
                     IF WS-RULE = 1
*>                       setAngerTargetToNearestTargetablePlayerIfFound: the nearest survival player within 16 blocks, else the player.
                         MOVE 0 TO WS-BEST
                         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
                             IF PL-USED(WS-P) = 1 AND (PL-MODE(WS-P) = 0 OR PL-MODE(WS-P) = 2) AND PL-DIM(WS-P) = EN-DIM(WS-E)
                                 COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(WS-E)) ** 2 + (PL-Y(WS-P) - EN-Y(WS-E)) ** 2
                                     + (PL-Z(WS-P) - EN-Z(WS-E)) ** 2
                                 IF WS-D2 <= 256 AND (WS-BEST = 0 OR WS-D2 < WS-BEST)
                                     MOVE WS-D2 TO WS-BEST
                                     MOVE WS-P TO WS-TARGET
                                 END-IF
                             END-IF
                         END-PERFORM
                     END-IF
                     CALL "NETHER-ANGER-TICKS" USING WS-E WS-TICKS
                     MOVE WS-TICKS TO EN-ANGER(WS-E)
                     MOVE WS-TARGET TO EN-TARGET(WS-E)
                     MOVE PL-ENTITY-ID(WS-TARGET) TO EN-TARGET-ID(WS-E)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PIGLIN-ANGER-NEARBY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-GUARDED-BREAK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-LOS                 BINARY-LONG VALUE 0.
 01 WS-KEY0                PIC X(48).
 01 WS-KEY                 PIC X(48).
 01 WS-GUARDED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATE.
     IF L-STATE = 0
         GOBACK
     END-IF
     MOVE CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) TO WS-KEY0
     MOVE WS-KEY0 TO WS-KEY
     IF WS-KEY0(1:10) = "minecraft:"
         MOVE WS-KEY0(11:38) TO WS-KEY
     END-IF
     CALL "PIGLIN-GUARDED" USING WS-KEY WS-GUARDED
     IF WS-GUARDED = 1
         CALL "PIGLIN-ANGER-NEARBY" USING L-ROW WS-LOS
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-GUARDED-BREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-CONTAINER-OPENED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOS                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PIGLIN-ANGER-NEARBY" USING L-ROW WS-LOS
     GOBACK.
 END PROGRAM PIGLIN-CONTAINER-OPENED.
