*> Item frames, glow item frames and paintings (docs/protocol/44 part 9 sections 5.1 to 5.4; lane 002-lane-mobsb6, T9010).
*> Item frame, PJ-KIND 12: PJ-I1 the direction (data value 0 down, 1 up, 2 north, 3 south, 4 west, 5 east), PJ-I2 the item (0 empty), PJ-I3 the rotation 0 to 7, PJ-I4 glow, PJ-I5 fixed, PJ-I6
*> invisible. The entity sits at its cell's centre moved 0.46875 against the facing (toward the wall). Placement (the item): never on a vertical face, target = the clicked cell moved by the face,
*> a solid block behind it, the cell free, no other frame or painting of that direction in the cell. A click with an item puts one in, a click on a filled frame rotates it (mod 8), the comparator
*> reads rotation + 1 (0 when empty); a hit drops the item first, then breaks the frame (the frame item and a held item at the drop chance 1.0), a creative attacker drops nothing and a fixed frame
*> ignores a survival player.
*> Painting, PJ-KIND 13: PJ-I1 the direction, PJ-I2 the width, PJ-I3 the height in blocks. PAINTING-PLACE gets the candidate sizes (the variant registry is not readable from here, so the caller
*> passes the placeable variants as widths and heights): those that fit are kept, the largest area wins, a random one of them is chosen (XP-RANDOM); the box centre is the block centre moved 0.46875
*> against the facing, by 0.5 along the counter-clockwise direction for an even width and 0.5 up for an even height.
*> Gaps: the variant identity (only its width and height are stored), maps in frames (size 1.0, the 256 player limit), the 100 tick survival check and the push and move kill, the coexist rule for
*> paintings uses the cell of the other entity's position, repeaters and comparators as a support block, glow frame sounds, item components (rotation of a stored item display), invisible frames,
*> the entity_drops rule and the drop chance field (always 1.0), the metadata (direction, item, rotation, variant), explosions' water rule, pop box collision with entities.
*>
*>   DECOR-STEP USING direction (data value), dx, dy, dz out (BINARY-LONG)
*>   ITEM-FRAME-PLACE USING player row, clicked x, y, z, face, glow, row out (0 refused)
*>   ITEM-FRAME-INTERACT USING frame row, player row, done out
*>   ITEM-FRAME-SIGNAL USING frame row, signal out
*>   ITEM-FRAME-HURT USING frame row, attacker player row (0 none), explosion (0 or 1), done out
*>   PAINTING-PLACE USING dim, clicked x, y, z, face, candidate count, widths (table of 64), heights (table of 64), row out (0 none); PJ-I4 of the painting is the index of the chosen candidate
*>   PAINTING-HURT USING painting row, attacker player row, done out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-STEP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-DX L-DY L-DZ.
     MOVE 0 TO L-DX L-DY L-DZ
     EVALUATE L-DIR
         WHEN 0
             MOVE -1 TO L-DY
         WHEN 1
             MOVE 1 TO L-DY
         WHEN 2
             MOVE -1 TO L-DZ
         WHEN 3
             MOVE 1 TO L-DZ
         WHEN 4
             MOVE -1 TO L-DX
         WHEN OTHER
             MOVE 1 TO L-DX
     END-EVALUATE
     GOBACK.
 END PROGRAM DECOR-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-OCCUPIED.
*> USING cell x, y, z, direction, excluded row, occupied out: another frame or painting of that direction whose position lies in the cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-EXCLUDED             BINARY-LONG.
 01 L-OCCUPIED             BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-EXCLUDED L-OCCUPIED.
     MOVE 0 TO L-OCCUPIED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND (PJ-KIND(WS-I) = 12 OR PJ-KIND(WS-I) = 13) AND PJ-I1(WS-I) = L-DIR
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I) AND WS-E NOT = L-EXCLUDED
                     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-E))
                     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-E))
                     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-E))
                     IF WS-CX = L-X AND WS-CY = L-Y AND WS-CZ = L-Z
                         MOVE 1 TO L-OCCUPIED
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM DECOR-OCCUPIED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-SPAWN.
*> USING kind (PROJSTATE kind), key (PIC X(112)), dim, x, y, z (FLOAT-LONG), direction, row out: a hanging entity of that key with EN-HEALTH 1 and the direction in PJ-I1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-KEY L-DIM L-X L-Y L-Z L-DIR L-ROW.
     CALL "THROWN-SPAWN" USING L-KIND L-KEY L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-NONE L-ROW
     IF L-ROW > 0
         MOVE 1 TO EN-HEALTH(L-ROW)
         CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
         MOVE L-DIR TO PJ-I1(WS-SLOT)
         EVALUATE L-DIR
             WHEN 2
                 MOVE 180 TO EN-YAW(L-ROW)
             WHEN 4
                 MOVE 90 TO EN-YAW(L-ROW)
             WHEN 5
                 MOVE 270 TO EN-YAW(L-ROW)
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM DECOR-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-FRAME-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-FRAME-KEY           PIC X(112) VALUE "minecraft:item_frame".
 01 WS-GLOW-KEY            PIC X(112) VALUE "minecraft:glow_item_frame".
 01 WS-KIND                BINARY-LONG VALUE 12.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-OCC                 BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-GLOW                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-X L-Y L-Z L-FACE L-GLOW L-ROW.
     MOVE 0 TO L-ROW
     IF L-FACE < 2
         GOBACK
     END-IF
     CALL "DECOR-STEP" USING L-FACE WS-DX WS-DY WS-DZ
     COMPUTE WS-TX = L-X + WS-DX
     COMPUTE WS-TY = L-Y + WS-DY
     COMPUTE WS-TZ = L-Z + WS-DZ
     COMPUTE WS-BX = WS-TX - WS-DX
     COMPUTE WS-BY = WS-TY - WS-DY
     COMPUTE WS-BZ = WS-TZ - WS-DZ
     CALL "GI-SOLID-CELL" USING PL-DIM(L-PLAYER) WS-BX WS-BY WS-BZ WS-SOLID
     CALL "GI-SOLID-CELL" USING PL-DIM(L-PLAYER) WS-TX WS-TY WS-TZ WS-FREE
     CALL "DECOR-OCCUPIED" USING WS-TX WS-TY WS-TZ L-FACE WS-NONE WS-OCC
     IF WS-SOLID = 0 OR WS-FREE = 1 OR WS-OCC = 1
         GOBACK
     END-IF
     COMPUTE WS-X = WS-TX + 0.5 - WS-DX * 0.46875
     COMPUTE WS-Y = WS-TY + 0.5
     COMPUTE WS-Z = WS-TZ + 0.5 - WS-DZ * 0.46875
     IF L-GLOW = 1
         CALL "DECOR-SPAWN" USING WS-KIND WS-GLOW-KEY PL-DIM(L-PLAYER) WS-X WS-Y WS-Z L-FACE L-ROW
     ELSE
         CALL "DECOR-SPAWN" USING WS-KIND WS-FRAME-KEY PL-DIM(L-PLAYER) WS-X WS-Y WS-Z L-FACE L-ROW
     END-IF
     IF L-ROW > 0
         CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
         MOVE L-GLOW TO PJ-I4(WS-SLOT)
         CALL "MOB-TAKE" USING L-PLAYER
     END-IF
     GOBACK.
 END PROGRAM ITEM-FRAME-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-FRAME-INTERACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0 OR PJ-I5(WS-SLOT) = 1
         GOBACK
     END-IF
     COMPUTE WS-HELD = PL-HELD(L-PLAYER) + 1
     IF PJ-I2(WS-SLOT) = 0
         IF PL-SLOT-COUNT(L-PLAYER, WS-HELD) > 0
             MOVE PL-SLOT-ITEM(L-PLAYER, WS-HELD) TO PJ-I2(WS-SLOT)
             CALL "MOB-TAKE" USING L-PLAYER
             MOVE 1 TO L-DONE
         END-IF
     ELSE
         COMPUTE PJ-I3(WS-SLOT) = FUNCTION MOD(PJ-I3(WS-SLOT) + 1, 8)
         MOVE 1 TO L-DONE
     END-IF
     GOBACK.
 END PROGRAM ITEM-FRAME-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-FRAME-SIGNAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0 AND PJ-I2(WS-SLOT) > 0
         COMPUTE L-SIGNAL = FUNCTION MOD(PJ-I3(WS-SLOT), 8) + 1
     END-IF
     GOBACK.
 END PROGRAM ITEM-FRAME-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-DROP-AT-FACE.
*> USING tracker row, direction, item id: the item pops at the entity's position moved 0.15 along the facing (spawnAtLocation).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIR L-ITEM.
     CALL "DECOR-STEP" USING L-DIR WS-DX WS-DY WS-DZ
     COMPUTE WS-X = EN-X(L-ROW) + WS-DX * 0.15
     MOVE EN-Y(L-ROW) TO WS-Y
     COMPUTE WS-Z = EN-Z(L-ROW) + WS-DZ * 0.15
     CALL "DECOR-DROP" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z L-ITEM
     GOBACK.
 END PROGRAM DECOR-DROP-AT-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-FRAME-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FRAME-KEY           PIC X(112) VALUE "minecraft:item_frame".
 01 WS-GLOW-KEY            PIC X(112) VALUE "minecraft:glow_item_frame".
 01 WS-FRAME-ITEM          BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-EXPLOSION            BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-EXPLOSION L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-CREATIVE
     IF L-PLAYER > 0
         IF PL-MODE(L-PLAYER) = 1
             MOVE 1 TO WS-CREATIVE
         END-IF
     END-IF
     IF PJ-I5(WS-SLOT) = 1 AND WS-CREATIVE = 0
         GOBACK
     END-IF
     MOVE 1 TO L-DONE
     MOVE PJ-I1(WS-SLOT) TO WS-DIR
     MOVE PJ-I2(WS-SLOT) TO WS-ITEM
     IF L-EXPLOSION = 0 AND WS-ITEM > 0 AND PJ-I5(WS-SLOT) = 0
         MOVE 0 TO PJ-I2(WS-SLOT)
         IF WS-CREATIVE = 0
             CALL "DECOR-DROP-AT-FACE" USING L-ROW WS-DIR WS-ITEM
         END-IF
         GOBACK
     END-IF
     IF WS-CREATIVE = 0
         IF PJ-I4(WS-SLOT) = 1
             CALL "CONTENT-ITEM-BY-KEY" USING WS-GLOW-KEY WS-FRAME-ITEM WS-ITEM-ROW WS-STATUS
         ELSE
             CALL "CONTENT-ITEM-BY-KEY" USING WS-FRAME-KEY WS-FRAME-ITEM WS-ITEM-ROW WS-STATUS
         END-IF
         CALL "DECOR-DROP-AT-FACE" USING L-ROW WS-DIR WS-FRAME-ITEM
         IF PJ-I5(WS-SLOT) = 0
             CALL "DECOR-DROP-AT-FACE" USING L-ROW WS-DIR WS-ITEM
         END-IF
     END-IF
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM ITEM-FRAME-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PAINTING-FITS.
*> USING dim, target x, y, z, direction, width, height, ok out: every cell of the painting's area is free with a solid block behind it and no other hanging entity of the direction in it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-OFF-W               FLOAT-LONG.
 01 WS-OFF-H               FLOAT-LONG.
 01 WS-CT                  FLOAT-LONG.
 01 WS-CYC                 FLOAT-LONG.
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-OCC                 BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-HALF                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DIR L-W L-H L-OK.
     MOVE 1 TO L-OK
     CALL "DECOR-STEP" USING L-DIR WS-DX WS-DY WS-DZ
*>   The counter-clockwise tangent: north goes west (-x), west south (+z), south east (+x), east north (-z).
     MOVE 0 TO WS-TX WS-TZ
     EVALUATE L-DIR
         WHEN 2
             MOVE -1 TO WS-TX
         WHEN 4
             MOVE 1 TO WS-TZ
         WHEN 3
             MOVE 1 TO WS-TX
         WHEN OTHER
             MOVE -1 TO WS-TZ
     END-EVALUATE
     MOVE 0 TO WS-OFF-W WS-OFF-H
     IF FUNCTION MOD(L-W, 2) = 0
         MOVE 0.5 TO WS-OFF-W
     END-IF
     IF FUNCTION MOD(L-H, 2) = 0
         MOVE 0.5 TO WS-OFF-H
     END-IF
     COMPUTE WS-HALF = L-W / 2
     IF WS-TX NOT = 0
         COMPUTE WS-CT = L-X + 0.5 + WS-OFF-W * WS-TX
     ELSE
         COMPUTE WS-CT = L-Z + 0.5 + WS-OFF-W * WS-TZ
     END-IF
     COMPUTE WS-T0 = FUNCTION INTEGER(WS-CT - WS-HALF + 0.0000001)
     COMPUTE WS-T1 = FUNCTION INTEGER(WS-CT + WS-HALF - 0.0000001)
     IF WS-CT + WS-HALF - 0.0000001 = WS-T1
         SUBTRACT 1 FROM WS-T1
     END-IF
     COMPUTE WS-CYC = L-Y + 0.5 + WS-OFF-H
     COMPUTE WS-HALF = L-H / 2
     COMPUTE WS-Y0 = FUNCTION INTEGER(WS-CYC - WS-HALF + 0.0000001)
     COMPUTE WS-Y1 = FUNCTION INTEGER(WS-CYC + WS-HALF - 0.0000001)
     IF WS-CYC + WS-HALF - 0.0000001 = WS-Y1
         SUBTRACT 1 FROM WS-Y1
     END-IF
     PERFORM VARYING WS-T FROM WS-T0 BY 1 UNTIL WS-T > WS-T1
         PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
             IF WS-TX NOT = 0
                 MOVE WS-T TO WS-CX
                 MOVE L-Z TO WS-CZ
             ELSE
                 MOVE L-X TO WS-CX
                 MOVE WS-T TO WS-CZ
             END-IF
             COMPUTE WS-BX = WS-CX - WS-DX
             COMPUTE WS-BZ = WS-CZ - WS-DZ
             CALL "GI-SOLID-CELL" USING L-DIM WS-BX WS-Y WS-BZ WS-SOLID
             CALL "GI-SOLID-CELL" USING L-DIM WS-CX WS-Y WS-CZ WS-FREE
             CALL "DECOR-OCCUPIED" USING WS-CX WS-Y WS-CZ L-DIR WS-NONE WS-OCC
             IF WS-SOLID = 0 OR WS-FREE = 1 OR WS-OCC = 1
                 MOVE 0 TO L-OK
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PAINTING-FITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PAINTING-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:painting".
 01 WS-KIND                BINARY-LONG VALUE 13.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FITS.
    05 WS-FIT              BINARY-LONG OCCURS 64 TIMES.
 01 WS-MAX                 BINARY-LONG.
 01 WS-AREA                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9121.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-OFF-W               FLOAT-LONG.
 01 WS-OFF-H               FLOAT-LONG.
 01 WS-TX2                 BINARY-LONG.
 01 WS-TZ2                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-WIDTHS.
    05 L-W                 BINARY-LONG OCCURS 64 TIMES.
 01 L-HEIGHTS.
    05 L-H                 BINARY-LONG OCCURS 64 TIMES.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACE L-COUNT L-WIDTHS L-HEIGHTS L-ROW.
     MOVE 0 TO L-ROW
     IF L-FACE < 2
         GOBACK
     END-IF
     CALL "DECOR-STEP" USING L-FACE WS-DX WS-DY WS-DZ
     COMPUTE WS-TX = L-X + WS-DX
     COMPUTE WS-TY = L-Y + WS-DY
     COMPUTE WS-TZ = L-Z + WS-DZ
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         CALL "PAINTING-FITS" USING L-DIM WS-TX WS-TY WS-TZ L-FACE L-W(WS-I) L-H(WS-I) WS-OK
         MOVE WS-OK TO WS-FIT(WS-I)
         IF WS-OK = 1
             COMPUTE WS-AREA = L-W(WS-I) * L-H(WS-I)
             IF WS-AREA > WS-MAX
                 MOVE WS-AREA TO WS-MAX
             END-IF
         END-IF
     END-PERFORM
     IF WS-MAX = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         IF WS-FIT(WS-I) = 1 AND L-W(WS-I) * L-H(WS-I) = WS-MAX
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     CALL "XP-RANDOM" USING WS-SALT WS-N WS-R
     MOVE 0 TO WS-PICK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         IF WS-FIT(WS-I) = 1 AND L-W(WS-I) * L-H(WS-I) = WS-MAX
             IF WS-R = 0 AND WS-PICK = 0
                 MOVE WS-I TO WS-PICK
             END-IF
             SUBTRACT 1 FROM WS-R
         END-IF
     END-PERFORM
     MOVE 0 TO WS-OFF-W WS-OFF-H
     IF FUNCTION MOD(L-W(WS-PICK), 2) = 0
         MOVE 0.5 TO WS-OFF-W
     END-IF
     IF FUNCTION MOD(L-H(WS-PICK), 2) = 0
         MOVE 0.5 TO WS-OFF-H
     END-IF
     MOVE 0 TO WS-TX2 WS-TZ2
     EVALUATE L-FACE
         WHEN 2
             MOVE -1 TO WS-TX2
         WHEN 4
             MOVE 1 TO WS-TZ2
         WHEN 3
             MOVE 1 TO WS-TX2
         WHEN OTHER
             MOVE -1 TO WS-TZ2
     END-EVALUATE
     COMPUTE WS-X = WS-TX + 0.5 - WS-DX * 0.46875 + WS-OFF-W * WS-TX2
     COMPUTE WS-Y = WS-TY + 0.5 + WS-OFF-H
     COMPUTE WS-Z = WS-TZ + 0.5 - WS-DZ * 0.46875 + WS-OFF-W * WS-TZ2
     CALL "DECOR-SPAWN" USING WS-KIND WS-KEY L-DIM WS-X WS-Y WS-Z L-FACE L-ROW
     IF L-ROW > 0
         CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
         MOVE L-W(WS-PICK) TO PJ-I2(WS-SLOT)
         MOVE L-H(WS-PICK) TO PJ-I3(WS-SLOT)
         MOVE WS-PICK TO PJ-I4(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM PAINTING-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PAINTING-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:painting".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE 1 TO L-DONE
     MOVE PJ-I1(WS-SLOT) TO WS-DIR
     IF L-PLAYER = 0 OR PL-MODE(L-PLAYER) NOT = 1
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         CALL "DECOR-DROP-AT-FACE" USING L-ROW WS-DIR WS-ITEM
     END-IF
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM PAINTING-HURT.
