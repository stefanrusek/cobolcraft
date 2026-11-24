*> Goat ram: knockback to the player and the horn-breaking block (002-lane-mobsa5; docs/protocol/54 sections 7.2 and 7.4, 44 part 4 section 9, 19 section 10).
*> - M44-RAM-KNOCK USING player row, goat row, strength (FLOAT-LONG, M44-RAM-KNOCKBACK): the standard knockback (TOOL-KNOCKBACK, no knockback resistance: gap) along the ram direction
*>   (EN-RAM-DX, EN-RAM-DZ, from the target back to the goat), and Set Entity Motion to the player (COMBAT-MOTION-SEND).
*> - M44-GOAT-HORN-TEST USING row, vx, vz, broke out: the block at floor(goat position + normalise(velocity x (1, 0, 1))) or the one above it in the block tag snaps_goat_horn: the horn breaks:
*>   M44-GOAT-DROP-HORN (not for a baby, EN-VARIANT 1; one present horn, the left first when both, EN-WOOL bit 2 no left, 4 no right, goes; a goat_horn item drops at the goat; the metadata is sent). The
*>   instrument of the dropped horn (random from screaming_goat_horns or regular_goat_horns by the UUID hash) is not stored (no instrument data: gap); sounds are not sent.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-RAM-KNOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-STRENGTH            BINARY-LONG.
 01 WS-RESIST              BINARY-LONG VALUE 0.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-VX                  BINARY-LONG VALUE 0.
 01 WS-VY                  BINARY-LONG VALUE 0.
 01 WS-VZ                  BINARY-LONG VALUE 0.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-GOAT                 BINARY-LONG.
 01 L-STRENGTH             FLOAT-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-GOAT L-STRENGTH.
     COMPUTE WS-STRENGTH ROUNDED = L-STRENGTH * 1000
     COMPUTE WS-DX ROUNDED = EN-RAM-DX(L-GOAT) * 1000
     COMPUTE WS-DZ ROUNDED = EN-RAM-DZ(L-GOAT) * 1000
     MOVE PL-ON-GROUND(L-PLAYER) TO WS-GROUND
     CALL "TOOL-KNOCKBACK" USING WS-STRENGTH WS-RESIST WS-DX WS-DZ WS-VX WS-VY WS-VZ WS-GROUND WS-NX WS-NY WS-NZ WS-STATUS
     CALL "COMBAT-MOTION-SEND" USING L-PLAYER WS-NX WS-NY WS-NZ
     GOBACK.
 END PROGRAM M44-RAM-KNOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-GOAT-DROP-HORN.
*> USING row, dropped out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-ITEM-KEY            PIC X(112) VALUE "minecraft:goat_horn".
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-HAS-LEFT            BINARY-LONG.
 01 WS-HAS-RIGHT           BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-COIN                BINARY-LONG VALUE 0.
 01 WS-SALT                BINARY-LONG VALUE 59.
 01 WS-BOUND               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DROPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DROPPED.
     MOVE 0 TO L-DROPPED WS-BABY
*>   Goat.dropHorn (44-x1 section 8.10, X1-GOAT-DROP): not for a baby, none with both horns gone, the horn that is left when there is one, else nextBoolean picks left (true) or right.
     IF EN-VARIANT(L-ROW) = 1
         MOVE 1 TO WS-BABY
     END-IF
     COMPUTE WS-HAS-LEFT = 1 - FUNCTION MOD(FUNCTION INTEGER(EN-WOOL(L-ROW) / 2), 2)
     COMPUTE WS-HAS-RIGHT = 1 - FUNCTION MOD(FUNCTION INTEGER(EN-WOOL(L-ROW) / 4), 2)
     IF WS-BABY = 0 AND WS-HAS-LEFT = 1 AND WS-HAS-RIGHT = 1
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-COIN
     END-IF
     CALL "X1-GOAT-DROP" USING WS-BABY WS-HAS-LEFT WS-HAS-RIGHT WS-COIN WS-OK
     IF WS-OK = 1
         COMPUTE EN-WOOL(L-ROW) = FUNCTION MOD(EN-WOOL(L-ROW), 2) + 2 * (1 - WS-HAS-LEFT) + 4 * (1 - WS-HAS-RIGHT)
         MOVE 1 TO L-DROPPED
         CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET WS-ITEM WS-ONE WS-PATCH WS-DROPPED
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM M44-GOAT-DROP-HORN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-GOAT-HORN-TEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:snaps_goat_horn".
 01 WS-LEN                 FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TAGGED              BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-BROKE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-VX L-VZ L-BROKE.
     MOVE 0 TO L-BROKE
     COMPUTE WS-LEN = FUNCTION SQRT(L-VX * L-VX + L-VZ * L-VZ)
     IF WS-LEN > 0
         COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW) + L-VX / WS-LEN)
         COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW) + L-VZ / WS-LEN)
         PERFORM VARYING WS-PASS FROM 0 BY 1 UNTIL WS-PASS > 1 OR L-BROKE = 1
             COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW)) + WS-PASS
             CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
             MOVE 0 TO WS-TAGGED
             IF WS-STATE > 0
                 MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
                 CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-TAGGED
             END-IF
             IF WS-TAGGED = 1
                 MOVE 1 TO L-BROKE
             END-IF
         END-PERFORM
*>       The horn breaks (the impact sound is not sent); a goat without a horn to lose still ends its ram.
         IF L-BROKE = 1
             CALL "M44-GOAT-DROP-HORN" USING L-ROW WS-DROPPED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-GOAT-HORN-TEST.
