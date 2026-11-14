*> Non-mob entities of document 21 section 8 (002-lane-mobsfull-h22). Implemented: 8.3 primed TNT. Everything else of section 8 (falling blocks, area effect clouds,
*> lightning, fireworks, boats and minecarts, eye of ender, thrown bottles, llama spit, leash knots, ...) is open, see specs/002-client-polish/tasks.md.
*>
*> Primed TNT (8.3): a tracker row of the standard entity type tnt (0.98 x 0.98). EN-SWELL holds the fuse (80 at the start; the field is the creeper's counter and unused by this
*> type). Created by TNT-IGNITE (flint and steel or a fire charge on a TNT block: the block becomes air) with the velocity (-sin a x 0.02, 0.2, -cos a x 0.02) for a random angle a.
*> Each tick (TNT-TICK -> TNT-STEP): gravity 0.04 on the vertical speed, the move, the drag 0.98 on all three speeds, on the ground (0.7, -0.5, 0.7) of the speed, then
*> the fuse falls by 1; at 0 the entity is removed and, with the game rule tnt_explodes, an explosion of power 4 happens at (x, y + 0.0625, z) destroying blocks (EXPLODE-RUN).
*> Approximations (open): the move tests the entity box per axis against solid cells (no stepping or friction of the block below: the drag stays 0.98 on all axes, no block
*> friction), no portals, fluids or Set Entity Data (the client counts the default fuse of 80 itself), chain ignition by other explosions, fire or redstone, the
*> explosion_power NBT key, saving (a primed TNT is not saved) and the TNT interaction's own block decay rule.
*>
*> Entry points:
*>   TNT-PRIME USING dim, x, y, z (FLOAT-LONG), row out        a primed TNT at the position with fuse 80 and the random start velocity
*>   TNT-IGNITE USING dim, block x, y, z (BINARY-LONG)         the block becomes air and a TNT is primed at its bottom centre
*>   TNT-STEP USING row                                        one tick of a primed TNT
*>   TNT-TICK                                                  every primed TNT (CORE-TICK, after the projectiles)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-PRIME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260803.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:tnt".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     MOVE WS-TYPE TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW)
     CALL "XORO-NEXT-DOUBLE" USING WS-STATE WS-D
     COMPUTE WS-A = WS-D * 2 * FUNCTION PI
     COMPUTE EN-VX(WS-ROW) = 0 - FUNCTION SIN(WS-A) * 0.02
     MOVE 0.2 TO EN-VY(WS-ROW)
     COMPUTE EN-VZ(WS-ROW) = 0 - FUNCTION COS(WS-A) * 0.02
     MOVE 0 TO EN-ON-GROUND(WS-ROW)
     MOVE 80 TO EN-SWELL(WS-ROW)
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM TNT-PRIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-IGNITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-AIR
     COMPUTE WS-X = L-X + 0.5
     MOVE L-Y TO WS-Y
     COMPUTE WS-Z = L-Z + 0.5
     CALL "TNT-PRIME" USING L-DIM WS-X WS-Y WS-Z WS-ROW
     GOBACK.
 END PROGRAM TNT-IGNITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 4.
 01 WS-DESTROY             BINARY-LONG VALUE 1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-TYPE(L-ROW) TO WS-TYPE
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.04
     MOVE 0 TO EN-ON-GROUND(L-ROW)
     COMPUTE WS-X = EN-X(L-ROW) + EN-VX(L-ROW)
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-X EN-Y(L-ROW) EN-Z(L-ROW) WS-HIT WS-TOP
     IF WS-HIT = 1
         MOVE EN-X(L-ROW) TO WS-X
         MOVE 0 TO EN-VX(L-ROW)
     END-IF
     COMPUTE WS-Z = EN-Z(L-ROW) + EN-VZ(L-ROW)
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-X EN-Y(L-ROW) WS-Z WS-HIT WS-TOP
     IF WS-HIT = 1
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE 0 TO EN-VZ(L-ROW)
     END-IF
     COMPUTE WS-Y = EN-Y(L-ROW) + EN-VY(L-ROW)
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-HIT WS-TOP
     IF WS-HIT = 1
         IF EN-VY(L-ROW) < 0
             MOVE 1 TO EN-ON-GROUND(L-ROW)
             COMPUTE WS-Y = WS-TOP + 1
         ELSE
             MOVE EN-Y(L-ROW) TO WS-Y
         END-IF
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.7
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.7
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * -0.5
     END-IF
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.98
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.98
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.98
     CALL "IP-ENSURE" USING L-ROW
     CALL "GI-SEND-MOVE" USING L-ROW WS-X WS-Y WS-Z
     SUBTRACT 1 FROM EN-SWELL(L-ROW)
     IF EN-SWELL(L-ROW) <= 0
         MOVE EN-X(L-ROW) TO WS-X
         COMPUTE WS-Y = EN-Y(L-ROW) + 0.0625
         MOVE EN-Z(L-ROW) TO WS-Z
         CALL "ENTITY-REMOVE" USING L-ROW
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
         IF WS-RULE NOT = 0
             CALL "EXPLODE-RUN" USING WS-DIM WS-X WS-Y WS-Z WS-POWER WS-DESTROY WS-NONE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TNT-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:tnt".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     IF WS-STATUS NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE
             CALL "TNT-STEP" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TNT-TICK.
