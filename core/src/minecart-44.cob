*> Minecarts with the old rail behaviour (docs/protocol/44 part 8 section 4, 21 section 8.8), PJ-KIND 10. PJ-I1 the kind (1 minecart, 2 chest, 3 hopper, 4 furnace, 5 tnt, 6 spawner,
*> 7 command block), PJ-I2 flipped, PJ-I3 fuel (furnace) or fuse (TNT, -1 not primed), PJ-I4 hurt time, PJ-I5 hurt direction, PJ-I6 enabled (hopper), PJ-R1 and PJ-R2 the furnace push,
*> PJ-R3 the damage. A tick (MINECART-STEP): hurt time and damage fall, gravity 0.04, then moveAlongTrack on a rail (the 14 steps of 4.4.1) or comeOffTrack, the yaw, the kind's tick (furnace
*> fuel, TNT fuse) and the activator rail (4.6).
*> Gaps: boarding and the rider (interact, the player input start, dismount, 0.75 move factor is read from EN-RIDER but nothing sets it), pushing other entities and carts (pushOtherMinecart,
*> pushAndPickupEntities), water (gravity 0.005, 0.2 speed, 0.95), the container (chest and hopper menus, contents, hopper suction, the comparator slowdown factor uses an empty container: 0.995),
*> spawner and command block carts (no spawner or command run), the item (placing a cart on a rail: see DECOR-ITEM-USE) and hurt, break and drops, saving, the fall damage explosion, the flip of
*> the yaw uses an arctangent of the step, the metadata (hurt, display block, fuel flag), a redstone conductor is read as a solid cell, TNT arrow ignition.
*>
*>   MC-RAIL USING dim, x, y, z (BINARY-LONG), kind out (1 rail, 2 powered, 3 activator, 4 detector, 0 none), shape out (0 to 9), powered out
*>   MC-EXITS USING shape, first x y z, second x y z (BINARY-LONG)
*>   MC-RAILPOINT USING dim, x, y, z (FLOAT-LONG), found out, px py pz out (FLOAT-LONG)
*>   MINECART-SPAWN USING kind, dim, x, y, z (FLOAT-LONG), row out (0 for an unknown kind)
*>   MINECART-FUEL USING row, player x, z (FLOAT-LONG), added out
*>   MINECART-PRIME USING row                                tnt cart primeFuse
*>   MINECART-STEP USING row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-RAIL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PATH                PIC X(48).
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-TEXT40              PIC X(40).
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-SHAPE L-POWERED.
     MOVE 0 TO L-KIND L-SHAPE L-POWERED
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
     IF WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:38) TO WS-PATH
     ELSE
         MOVE WS-KEY TO WS-PATH
     END-IF
     EVALUATE WS-PATH
         WHEN "rail"
             MOVE 1 TO L-KIND
         WHEN "powered_rail"
             MOVE 2 TO L-KIND
         WHEN "activator_rail"
             MOVE 3 TO L-KIND
         WHEN "detector_rail"
             MOVE 4 TO L-KIND
     END-EVALUATE
     IF L-KIND > 0
         MOVE "shape" TO WS-NAME
         CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-RESULT
         MOVE WS-TEXT TO WS-TEXT40
         CALL "RS3-SHAPE-ORDINAL" USING WS-TEXT40 L-SHAPE
         IF L-SHAPE < 0
             MOVE 0 TO L-SHAPE
         END-IF
         MOVE "powered" TO WS-NAME
         CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-RESULT
         IF WS-TEXT = "true"
             MOVE 1 TO L-POWERED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MC-RAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-EXITS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-FX                   BINARY-LONG.
 01 L-FY                   BINARY-LONG.
 01 L-FZ                   BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-FX L-FY L-FZ L-SX L-SY L-SZ.
     EVALUATE L-SHAPE
         WHEN 0
             MOVE 0 TO L-FX L-FY L-SX L-SY
             MOVE -1 TO L-FZ
             MOVE 1 TO L-SZ
         WHEN 1
             MOVE 0 TO L-FY L-FZ L-SY L-SZ
             MOVE -1 TO L-FX
             MOVE 1 TO L-SX
         WHEN 2
             MOVE -1 TO L-FX L-FY
             MOVE 0 TO L-FZ L-SY L-SZ
             MOVE 1 TO L-SX
         WHEN 3
             MOVE -1 TO L-FX
             MOVE 0 TO L-FY L-FZ L-SZ
             MOVE 1 TO L-SX
             MOVE -1 TO L-SY
         WHEN 4
             MOVE 0 TO L-FX L-FY L-SX
             MOVE -1 TO L-FZ L-SY
             MOVE 1 TO L-SZ
         WHEN 5
             MOVE 0 TO L-FX L-SX L-SY
             MOVE -1 TO L-FY L-FZ
             MOVE 1 TO L-SZ
         WHEN 6
             MOVE 0 TO L-FX L-FY L-SY L-SZ
             MOVE 1 TO L-FZ L-SX
         WHEN 7
             MOVE 0 TO L-FX L-FY L-SY L-SZ
             MOVE 1 TO L-FZ
             MOVE -1 TO L-SX
         WHEN 8
             MOVE 0 TO L-FX L-FY L-SY L-SZ
             MOVE -1 TO L-FZ L-SX
         WHEN OTHER
             MOVE 0 TO L-FX L-FY L-SY L-SZ
             MOVE -1 TO L-FZ
             MOVE 1 TO L-SX
     END-EVALUATE
     GOBACK.
 END PROGRAM MC-EXITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-RAILPOINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-POWERED             BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-P1X                 FLOAT-LONG.
 01 WS-P1Y                 FLOAT-LONG.
 01 WS-P1Z                 FLOAT-LONG.
 01 WS-P2X                 FLOAT-LONG.
 01 WS-P2Y                 FLOAT-LONG.
 01 WS-P2Z                 FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FOUND L-PX L-PY L-PZ.
     MOVE 0 TO L-FOUND
     COMPUTE WS-BX = FUNCTION INTEGER(L-X)
     COMPUTE WS-BY = FUNCTION INTEGER(L-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(L-Z)
     COMPUTE WS-BELOW = WS-BY - 1
     CALL "MC-RAIL" USING L-DIM WS-BX WS-BELOW WS-BZ WS-KIND WS-SHAPE WS-POWERED
     IF WS-KIND > 0
         MOVE WS-BELOW TO WS-BY
     END-IF
     CALL "MC-RAIL" USING L-DIM WS-BX WS-BY WS-BZ WS-KIND WS-SHAPE WS-POWERED
     IF WS-KIND = 0
         GOBACK
     END-IF
     MOVE 1 TO L-FOUND
     CALL "MC-EXITS" USING WS-SHAPE WS-FX WS-FY WS-FZ WS-SX WS-SY WS-SZ
     COMPUTE WS-P1X = WS-BX + 0.5 + WS-FX * 0.5
     COMPUTE WS-P1Y = WS-BY + 0.0625 + WS-FY * 0.5
     COMPUTE WS-P1Z = WS-BZ + 0.5 + WS-FZ * 0.5
     COMPUTE WS-P2X = WS-BX + 0.5 + WS-SX * 0.5
     COMPUTE WS-P2Y = WS-BY + 0.0625 + WS-SY * 0.5
     COMPUTE WS-P2Z = WS-BZ + 0.5 + WS-SZ * 0.5
     COMPUTE WS-EX = WS-P2X - WS-P1X
     COMPUTE WS-EY = (WS-P2Y - WS-P1Y) * 2
     COMPUTE WS-EZ = WS-P2Z - WS-P1Z
     EVALUATE TRUE
         WHEN WS-EX = 0
             COMPUTE WS-T = L-Z - WS-BZ
         WHEN WS-EZ = 0
             COMPUTE WS-T = L-X - WS-BX
         WHEN OTHER
             COMPUTE WS-T = ((L-X - WS-P1X) * WS-EX + (L-Z - WS-P1Z) * WS-EZ) * 2
     END-EVALUATE
     COMPUTE L-PX = WS-P1X + WS-EX * WS-T
     COMPUTE L-PY = WS-P1Y + WS-EY * WS-T
     COMPUTE L-PZ = WS-P1Z + WS-EZ * WS-T
     IF WS-EY < 0
         COMPUTE L-PY = L-PY + 1
     END-IF
     IF WS-EY > 0
         COMPUTE L-PY = L-PY + 0.5
     END-IF
     GOBACK.
 END PROGRAM MC-RAILPOINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112).
 01 WS-PJ                  BINARY-LONG VALUE 10.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-ROW.
     MOVE 0 TO L-ROW
     MOVE SPACES TO WS-KEY
     EVALUATE L-KIND
         WHEN 1
             MOVE "minecraft:minecart" TO WS-KEY
         WHEN 2
             MOVE "minecraft:chest_minecart" TO WS-KEY
         WHEN 3
             MOVE "minecraft:hopper_minecart" TO WS-KEY
         WHEN 4
             MOVE "minecraft:furnace_minecart" TO WS-KEY
         WHEN 5
             MOVE "minecraft:tnt_minecart" TO WS-KEY
         WHEN 6
             MOVE "minecraft:spawner_minecart" TO WS-KEY
         WHEN 7
             MOVE "minecraft:command_block_minecart" TO WS-KEY
     END-EVALUATE
     IF WS-KEY = SPACES
         GOBACK
     END-IF
     CALL "THROWN-SPAWN" USING WS-PJ WS-KEY L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-NONE L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     MOVE 1 TO EN-HEALTH(L-ROW)
     MOVE L-KIND TO PJ-I1(WS-SLOT)
     MOVE 1 TO PJ-I5(WS-SLOT) PJ-I6(WS-SLOT)
     IF L-KIND = 5
         MOVE -1 TO PJ-I3(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM MINECART-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-FUEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-ADDED                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PX L-PZ L-ADDED.
     MOVE 0 TO L-ADDED
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0 AND PJ-I1(WS-SLOT) = 4 AND PJ-I3(WS-SLOT) + 3600 <= 32000
         ADD 3600 TO PJ-I3(WS-SLOT)
         COMPUTE PJ-R1(WS-SLOT) = EN-X(L-ROW) - L-PX
         COMPUTE PJ-R2(WS-SLOT) = EN-Z(L-ROW) - L-PZ
         MOVE 1 TO L-ADDED
     END-IF
     GOBACK.
 END PROGRAM MINECART-FUEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-PRIME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY PROTO.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 70.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-RULE NOT = 0 AND WS-SLOT > 0
         MOVE 80 TO PJ-I3(WS-SLOT)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM MINECART-PRIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-MOVE.
*> USING row, dx, dy, dz (FLOAT-LONG), horizontal hit out: the cart moves along y, then x, then z, each stopped by solid cells (ENTITY-BOX-HITS of its type); a downward block sets
*> EN-ON-GROUND and zeroes vy, a block in x or z zeroes that velocity and reports the horizontal hit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-HHIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DX L-DY L-DZ L-HHIT.
     MOVE 0 TO L-HHIT
     COMPUTE WS-NY = EN-Y(L-ROW) + L-DY
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) EN-X(L-ROW) WS-NY EN-Z(L-ROW) WS-HIT WS-TOP
     IF WS-HIT = 1
         IF L-DY < 0
             MOVE 1 TO EN-ON-GROUND(L-ROW)
         END-IF
         MOVE 0 TO EN-VY(L-ROW)
     ELSE
         MOVE WS-NY TO EN-Y(L-ROW)
         MOVE 0 TO EN-ON-GROUND(L-ROW)
     END-IF
     COMPUTE WS-NX = EN-X(L-ROW) + L-DX
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-NX EN-Y(L-ROW) EN-Z(L-ROW) WS-HIT WS-TOP
     IF WS-HIT = 1
         MOVE 0 TO EN-VX(L-ROW)
         MOVE 1 TO L-HHIT
     ELSE
         MOVE WS-NX TO EN-X(L-ROW)
     END-IF
     COMPUTE WS-NZ = EN-Z(L-ROW) + L-DZ
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) WS-NZ WS-HIT WS-TOP
     IF WS-HIT = 1
         MOVE 0 TO EN-VZ(L-ROW)
         MOVE 1 TO L-HHIT
     ELSE
         MOVE WS-NZ TO EN-Z(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM MC-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-MAXSPEED.
*> USING slot, max speed out: 0.4 on land; the furnace cart halves it (4.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-MAX                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-SLOT L-MAX.
     MOVE 0.4 TO L-MAX
     IF PJ-I1(L-SLOT) = 4
         MOVE 0.2 TO L-MAX
     END-IF
     GOBACK.
 END PROGRAM MC-MAXSPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-SLOWDOWN.
*> USING row, slot: applyNaturalSlowdown (4.4.1 step 11 and 4.6): the kind's factors, the vertical velocity zeroed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-F                   FLOAT-LONG.
 01 WS-WX                  FLOAT-LONG.
 01 WS-WZ                  FLOAT-LONG.
 01 WS-PH                  FLOAT-LONG.
 01 WS-VH                  FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-PLEN                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     MOVE EN-VX(L-ROW) TO WS-WX
     MOVE EN-VZ(L-ROW) TO WS-WZ
     IF PJ-I1(L-SLOT) = 4
         COMPUTE WS-PH = PJ-R1(L-SLOT) * PJ-R1(L-SLOT) + PJ-R2(L-SLOT) * PJ-R2(L-SLOT)
         IF WS-PH > 0.0000001
             COMPUTE WS-VH = WS-WX * WS-WX + WS-WZ * WS-WZ
             IF WS-PH > 0.0001 AND WS-VH > 0.001
                 COMPUTE WS-DOT = (PJ-R1(L-SLOT) * WS-WX + PJ-R2(L-SLOT) * WS-WZ) / WS-VH
                 COMPUTE WS-PLEN = FUNCTION SQRT(WS-PH) / FUNCTION SQRT(WS-VH)
                 IF WS-DOT < 0
                     COMPUTE WS-PLEN = 0 - WS-PLEN
                 END-IF
                 COMPUTE PJ-R1(L-SLOT) = WS-WX * WS-PLEN
                 COMPUTE PJ-R2(L-SLOT) = WS-WZ * WS-PLEN
             END-IF
             COMPUTE WS-WX = WS-WX * 0.8 + PJ-R1(L-SLOT)
             COMPUTE WS-WZ = WS-WZ * 0.8 + PJ-R2(L-SLOT)
         ELSE
             COMPUTE WS-WX = WS-WX * 0.98
             COMPUTE WS-WZ = WS-WZ * 0.98
         END-IF
     END-IF
     EVALUATE TRUE
         WHEN PJ-I1(L-SLOT) = 2 OR PJ-I1(L-SLOT) = 3
             MOVE 0.995 TO WS-F
         WHEN EN-RIDER(L-ROW) > 0
             MOVE 0.997 TO WS-F
         WHEN OTHER
             MOVE 0.96 TO WS-F
     END-EVALUATE
     COMPUTE EN-VX(L-ROW) = WS-WX * WS-F
     MOVE 0 TO EN-VY(L-ROW)
     COMPUTE EN-VZ(L-ROW) = WS-WZ * WS-F
     GOBACK.
 END PROGRAM MC-SLOWDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-ALONG.
*> USING row, slot, block x, y, z, rail kind, shape, powered: moveAlongTrack (44 part 8 section 4.4.1, steps 1 to 14 with step 6 left out).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-OLD-FOUND           BINARY-LONG.
 01 WS-OLD-X               FLOAT-LONG.
 01 WS-OLD-Y               FLOAT-LONG.
 01 WS-OLD-Z               FLOAT-LONG.
 01 WS-NEW-FOUND           BINARY-LONG.
 01 WS-NEW-X               FLOAT-LONG.
 01 WS-NEW-Y               FLOAT-LONG.
 01 WS-NEW-Z               FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-BRAKE               BINARY-LONG.
 01 WS-POWERED-RAIL        BINARY-LONG.
 01 WS-SLOPE               FLOAT-LONG VALUE 0.0078125.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-P1X                 FLOAT-LONG.
 01 WS-P1Z                 FLOAT-LONG.
 01 WS-P2X                 FLOAT-LONG.
 01 WS-P2Z                 FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-MX                  FLOAT-LONG.
 01 WS-MZ                  FLOAT-LONG.
 01 WS-HHIT                BINARY-LONG.
 01 WS-OFF-X               BINARY-LONG.
 01 WS-OFF-Z               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-SOLID               BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BX L-BY L-BZ L-KIND L-SHAPE L-POWERED.
     CALL "MC-RAILPOINT" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OLD-FOUND WS-OLD-X WS-OLD-Y WS-OLD-Z
     MOVE L-BY TO WS-Y
     MOVE 0 TO WS-BRAKE WS-POWERED-RAIL
     IF L-KIND = 2
         IF L-POWERED = 1
             MOVE 1 TO WS-POWERED-RAIL
         ELSE
             MOVE 1 TO WS-BRAKE
         END-IF
     END-IF
     CALL "MC-EXITS" USING L-SHAPE WS-FX WS-FY WS-FZ WS-SX WS-SY WS-SZ
     EVALUATE L-SHAPE
         WHEN 2
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) - WS-SLOPE
             COMPUTE WS-Y = WS-Y + 1
         WHEN 3
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + WS-SLOPE
             COMPUTE WS-Y = WS-Y + 1
         WHEN 4
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + WS-SLOPE
             COMPUTE WS-Y = WS-Y + 1
         WHEN 5
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) - WS-SLOPE
             COMPUTE WS-Y = WS-Y + 1
     END-EVALUATE
*>   Step 5: align the velocity with the rail.
     COMPUTE WS-DX = WS-SX - WS-FX
     COMPUTE WS-DZ = WS-SZ - WS-FZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     IF EN-VX(L-ROW) * WS-DX + EN-VZ(L-ROW) * WS-DZ < 0
         COMPUTE WS-DX = 0 - WS-DX
         COMPUTE WS-DZ = 0 - WS-DZ
     END-IF
     COMPUTE WS-SPEED = FUNCTION MIN(2.0, FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW)))
     COMPUTE EN-VX(L-ROW) = WS-SPEED * WS-DX / WS-LEN
     COMPUTE EN-VZ(L-ROW) = WS-SPEED * WS-DZ / WS-LEN
*>   Step 7: brake.
     IF WS-BRAKE = 1
         COMPUTE WS-H = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
         IF WS-H < 0.03
             MOVE 0 TO EN-VX(L-ROW) EN-VZ(L-ROW)
         ELSE
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.5
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.5
         END-IF
     END-IF
*>   Step 8: snap to the rail line.
     COMPUTE WS-P1X = L-BX + 0.5 + WS-FX * 0.5
     COMPUTE WS-P1Z = L-BZ + 0.5 + WS-FZ * 0.5
     COMPUTE WS-P2X = L-BX + 0.5 + WS-SX * 0.5
     COMPUTE WS-P2Z = L-BZ + 0.5 + WS-SZ * 0.5
     COMPUTE WS-EX = WS-P2X - WS-P1X
     COMPUTE WS-EZ = WS-P2Z - WS-P1Z
     EVALUATE TRUE
         WHEN WS-EX = 0
             COMPUTE WS-T = EN-Z(L-ROW) - L-BZ
         WHEN WS-EZ = 0
             COMPUTE WS-T = EN-X(L-ROW) - L-BX
         WHEN OTHER
             COMPUTE WS-T = ((EN-X(L-ROW) - WS-P1X) * WS-EX + (EN-Z(L-ROW) - WS-P1Z) * WS-EZ) * 2
     END-EVALUATE
     COMPUTE WS-PX = WS-P1X + WS-EX * WS-T
     COMPUTE WS-PZ = WS-P1Z + WS-EZ * WS-T
     MOVE WS-PX TO EN-X(L-ROW)
     MOVE WS-Y TO EN-Y(L-ROW)
     MOVE WS-PZ TO EN-Z(L-ROW)
*>   Step 9: move, a loaded cart at 0.75 of its stored speed.
     MOVE 1.0 TO WS-F
     IF EN-RIDER(L-ROW) > 0
         MOVE 0.75 TO WS-F
     END-IF
     CALL "MC-MAXSPEED" USING L-SLOT WS-M
     COMPUTE WS-MX = FUNCTION MAX(0 - WS-M, FUNCTION MIN(WS-M, WS-F * EN-VX(L-ROW)))
     COMPUTE WS-MZ = FUNCTION MAX(0 - WS-M, FUNCTION MIN(WS-M, WS-F * EN-VZ(L-ROW)))
     CALL "MC-MOVE" USING L-ROW WS-MX WS-ZERO WS-MZ WS-HHIT
     IF WS-HHIT = 1
         MOVE 1 TO PJ-I7(L-SLOT)
     ELSE
         MOVE 0 TO PJ-I7(L-SLOT)
     END-IF
*>   Step 10: the height correction at the foot of a slope.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     COMPUTE WS-OFF-X = WS-CX - L-BX
     COMPUTE WS-OFF-Z = WS-CZ - L-BZ
     EVALUATE TRUE
         WHEN WS-FY NOT = 0 AND WS-OFF-X = WS-FX AND WS-OFF-Z = WS-FZ
             COMPUTE EN-Y(L-ROW) = EN-Y(L-ROW) + WS-FY
         WHEN WS-SY NOT = 0 AND WS-OFF-X = WS-SX AND WS-OFF-Z = WS-SZ
             COMPUTE EN-Y(L-ROW) = EN-Y(L-ROW) + WS-SY
     END-EVALUATE
*>   Step 11: the natural slowdown.
     CALL "MC-SLOWDOWN" USING L-ROW L-SLOT
*>   Step 12: the height along the rail.
     CALL "MC-RAILPOINT" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-NEW-FOUND WS-NEW-X WS-NEW-Y WS-NEW-Z
     IF WS-OLD-FOUND = 1 AND WS-NEW-FOUND = 1
         COMPUTE WS-DY = (WS-OLD-Y - WS-NEW-Y) * 0.05
         COMPUTE WS-H = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
         IF WS-H > 0
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * (WS-H + WS-DY) / WS-H
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * (WS-H + WS-DY) / WS-H
         END-IF
         MOVE WS-NEW-Y TO EN-Y(L-ROW)
     END-IF
*>   Step 13: crossing into the next block redirects all the horizontal speed along the step.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     IF WS-CX NOT = L-BX OR WS-CZ NOT = L-BZ
         COMPUTE WS-H = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
         COMPUTE EN-VX(L-ROW) = WS-H * (WS-CX - L-BX)
         COMPUTE EN-VZ(L-ROW) = WS-H * (WS-CZ - L-BZ)
     END-IF
*>   Step 14: a powered rail pushes, or starts a stopped cart away from an adjacent solid block.
     IF WS-POWERED-RAIL = 1
         COMPUTE WS-H = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
         IF WS-H > 0.01
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + EN-VX(L-ROW) / WS-H * 0.06
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + EN-VZ(L-ROW) / WS-H * 0.06
         ELSE
             MOVE EN-VX(L-ROW) TO WS-VX
             MOVE EN-VZ(L-ROW) TO WS-VZ
             EVALUATE L-SHAPE
                 WHEN 1
                     COMPUTE WS-NX = L-BX - 1
                     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-NX L-BY L-BZ WS-SOLID
                     IF WS-SOLID = 1
                         MOVE 0.02 TO WS-VX
                     ELSE
                         COMPUTE WS-NX = L-BX + 1
                         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-NX L-BY L-BZ WS-SOLID
                         IF WS-SOLID = 1
                             MOVE -0.02 TO WS-VX
                         END-IF
                     END-IF
                 WHEN 0
                     COMPUTE WS-NZ = L-BZ - 1
                     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) L-BX L-BY WS-NZ WS-SOLID
                     IF WS-SOLID = 1
                         MOVE 0.02 TO WS-VZ
                     ELSE
                         COMPUTE WS-NZ = L-BZ + 1
                         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) L-BX L-BY WS-NZ WS-SOLID
                         IF WS-SOLID = 1
                             MOVE -0.02 TO WS-VZ
                         END-IF
                     END-IF
             END-EVALUATE
             MOVE WS-VX TO EN-VX(L-ROW)
             MOVE WS-VZ TO EN-VZ(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MC-ALONG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-EXPLODE.
*> USING row, slot: the TNT cart's explode (4.6): radius 4.0 + 1.0 x nextDouble x 1.5 x min(horizontal speed, 5), no fire; the cart is gone (an explosion only with tnt_explodes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-S                   FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9111.
 01 WS-THOUSAND            BINARY-LONG VALUE 1000.
 01 WS-R                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DESTROY             BINARY-LONG VALUE 1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     COMPUTE WS-S = FUNCTION MIN(5.0, FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW)))
     CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-R
     COMPUTE WS-POWER = 4.0 + WS-R / 1000 * 1.5 * WS-S
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "PJ-DROP" USING L-ROW
     IF WS-RULE NOT = 0
         CALL "EXPLODE-RUN" USING WS-DIM WS-X WS-Y WS-Z WS-POWER WS-DESTROY WS-NONE
     END-IF
     GOBACK.
 END PROGRAM MC-EXPLODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-ACTIVATE.
*> USING row, slot, powered: activateMinecart (4.6): a plain cart shakes, a hopper cart is enabled when the rail is unpowered, a TNT cart is primed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-POWERED.
     EVALUATE PJ-I1(L-SLOT)
         WHEN 1
             IF L-POWERED = 1 AND PJ-I4(L-SLOT) = 0
                 COMPUTE PJ-I5(L-SLOT) = 0 - PJ-I5(L-SLOT)
                 MOVE 10 TO PJ-I4(L-SLOT)
                 MOVE 50 TO PJ-R3(L-SLOT)
             END-IF
         WHEN 3
             IF L-POWERED = 1
                 MOVE 0 TO PJ-I6(L-SLOT)
             ELSE
                 MOVE 1 TO PJ-I6(L-SLOT)
             END-IF
         WHEN 5
             IF L-POWERED = 1 AND PJ-I3(L-SLOT) < 0
                 CALL "MINECART-PRIME" USING L-ROW
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MC-ACTIVATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-POWERED             BINARY-LONG.
 01 WS-ON-RAIL             BINARY-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-MX                  FLOAT-LONG.
 01 WS-MY                  FLOAT-LONG.
 01 WS-MZ                  FLOAT-LONG.
 01 WS-HHIT                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H2                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF PJ-I4(WS-SLOT) > 0
         SUBTRACT 1 FROM PJ-I4(WS-SLOT)
     END-IF
     IF PJ-R3(WS-SLOT) > 0
         COMPUTE PJ-R3(WS-SLOT) = PJ-R3(WS-SLOT) - 1
     END-IF
     MOVE EN-X(L-ROW) TO WS-OX
     MOVE EN-Z(L-ROW) TO WS-OZ
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.04
*>   The block of the cart, or the rail below it.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "MC-RAIL" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-KIND WS-SHAPE WS-POWERED
     IF WS-KIND = 0
         COMPUTE WS-BELOW = WS-BY - 1
         CALL "MC-RAIL" USING EN-DIM(L-ROW) WS-BX WS-BELOW WS-BZ WS-KIND WS-SHAPE WS-POWERED
         IF WS-KIND > 0
             MOVE WS-BELOW TO WS-BY
         END-IF
     END-IF
     IF WS-KIND > 0
         CALL "MC-ALONG" USING L-ROW WS-SLOT WS-BX WS-BY WS-BZ WS-KIND WS-SHAPE WS-POWERED
         IF WS-KIND = 3
             CALL "MC-ACTIVATE" USING L-ROW WS-SLOT WS-POWERED
         END-IF
     ELSE
         CALL "MC-MAXSPEED" USING WS-SLOT WS-MAX
         COMPUTE EN-VX(L-ROW) = FUNCTION MAX(0 - WS-MAX, FUNCTION MIN(WS-MAX, EN-VX(L-ROW)))
         COMPUTE EN-VZ(L-ROW) = FUNCTION MAX(0 - WS-MAX, FUNCTION MIN(WS-MAX, EN-VZ(L-ROW)))
         IF EN-ON-GROUND(L-ROW) = 1
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.5
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.5
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.5
         END-IF
         MOVE EN-VX(L-ROW) TO WS-MX
         MOVE EN-VY(L-ROW) TO WS-MY
         MOVE EN-VZ(L-ROW) TO WS-MZ
         CALL "MC-MOVE" USING L-ROW WS-MX WS-MY WS-MZ WS-HHIT
         IF WS-HHIT = 1
             MOVE 1 TO PJ-I7(WS-SLOT)
         ELSE
             MOVE 0 TO PJ-I7(WS-SLOT)
         END-IF
         IF EN-ON-GROUND(L-ROW) = 0
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.95
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.95
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.95
         END-IF
     END-IF
*>   The yaw follows the movement and flips when the cart reverses (step 6).
     COMPUTE WS-DX = WS-OX - EN-X(L-ROW)
     COMPUTE WS-DZ = WS-OZ - EN-Z(L-ROW)
     IF WS-DX * WS-DX + WS-DZ * WS-DZ > 0.001
         EVALUATE TRUE
             WHEN WS-DX = 0 AND WS-DZ > 0
                 MOVE 90 TO WS-YAW
             WHEN WS-DX = 0
                 MOVE -90 TO WS-YAW
             WHEN WS-DX > 0
                 COMPUTE WS-YAW = FUNCTION ATAN(WS-DZ / WS-DX) * 180 / FUNCTION PI
             WHEN OTHER
                 COMPUTE WS-YAW = FUNCTION ATAN(WS-DZ / WS-DX) * 180 / FUNCTION PI + 180
         END-EVALUATE
         IF PJ-I2(WS-SLOT) = 1
             COMPUTE WS-YAW = WS-YAW + 180
         END-IF
         COMPUTE WS-D = FUNCTION MOD(WS-YAW - EN-YAW(L-ROW) + 540, 360) - 180
         IF WS-D < -170 OR WS-D >= 170
             COMPUTE WS-YAW = WS-YAW + 180
             COMPUTE PJ-I2(WS-SLOT) = 1 - PJ-I2(WS-SLOT)
         END-IF
         COMPUTE EN-YAW(L-ROW) = FUNCTION MOD(WS-YAW, 360)
     END-IF
*>   The kind's own tick.
     EVALUATE PJ-I1(WS-SLOT)
         WHEN 4
             IF PJ-I3(WS-SLOT) > 0
                 SUBTRACT 1 FROM PJ-I3(WS-SLOT)
                 IF PJ-I3(WS-SLOT) <= 0
                     MOVE 0 TO PJ-R1(WS-SLOT) PJ-R2(WS-SLOT)
                 END-IF
             END-IF
         WHEN 5
             COMPUTE WS-H2 = EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW)
             EVALUATE TRUE
                 WHEN PJ-I3(WS-SLOT) > 0
                     SUBTRACT 1 FROM PJ-I3(WS-SLOT)
                 WHEN PJ-I3(WS-SLOT) = 0
                     CALL "MC-EXPLODE" USING L-ROW WS-SLOT
                     GOBACK
             END-EVALUATE
             IF PJ-I7(WS-SLOT) = 1 AND WS-H2 >= 0.01
                 CALL "MC-EXPLODE" USING L-ROW WS-SLOT
                 GOBACK
             END-IF
     END-EVALUATE
     CALL "MINECART-ENTITIES" USING L-ROW
     CALL "MINECART-SYNC" USING L-ROW
     CALL "THROWN-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM MINECART-STEP.
