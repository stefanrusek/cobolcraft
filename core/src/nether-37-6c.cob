*> The Nether's structure definitions (docs/protocol/37-nether-6 section 3; T1706): the common settings of the four instances, their stub positions, the fortress start's vertical shift,
*> the bastion's jigsaw fields with Y_SIZE, the ruined portal's single setup and the fossil's height provider.
*>
*> Entry points (structures: 1 fortress, 2 bastion_remnant, 3 ruined_portal_nether, 4 nether_fossil):
*>   NETHER-STRUCTURE-DEF USING structure, code, value out (-1 when the structure has no such field). Codes: 1 step (1 underground_decoration, 2 surface_structures), 2 terrain adaptation
*>     (0 none, 1 beard_thin), 3 spawn override entries, 4 override bounding box (1 piece), 5 jigsaw size, 6 start height, 7 max distance horizontal, 8 max distance vertical, 9 use_expansion_hack,
*>     10 project_start_to_heightmap present, 11 pool aliases, 12 dimension padding, 13 liquid settings (1 apply_waterlogging), 14 setup count, 15 setup placement (6 in_nether), 16 air pocket
*>     probability x100, 17 mossiness x100, 18 overgrown, 19 vines, 20 can_be_cold, 21 replace_with_blackstone, 22 weight x100, 23 fossil height minimum (absolute), 24 fossil below_top offset
*>   NETHER-STUB USING structure, x1, z1 (chunk minimum, the box minimum for the bastion, the drawn column for the fossil), x2, z2 (box maximum, bastion only), y (ruined portal and fossil), stub x, y, z out
*>   NETHER-QUART USING block coordinate, quart out (QuartPos.fromBlock: floor division by 4)
*>   NETHER-FORTRESS-SHIFT USING y span of the union box, draw (nextInt(room) value), draw needed out, new minimum y out (moveInsideHeights 48 to 70)
*>   NETHER-FORTRESS-MOVE USING box minimum y, new minimum y, delta out
*>   NETHER-Y-SIZE USING code (1 packed horizontal length, 2 packed y length, 3 Y_SIZE, 4 MAX_Y, 5 MIN_Y), value out
*>   NETHER-JIGSAW-RANGE USING horizontal reach, ok out (1 for 1 to 128)
*>   NETHER-BELOW-TOP USING level min y, generator min y, level height, generator gen depth, offset, y out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STRUCTURE-DEF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-THREE               BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-CODE L-VALUE.
     MOVE -1 TO L-VALUE
     EVALUATE L-CODE
         WHEN 1
             MOVE 2 TO L-VALUE
             IF L-STRUCT = 1 OR L-STRUCT = 4
                 MOVE 1 TO L-VALUE
             END-IF
         WHEN 2
             MOVE 0 TO L-VALUE
             IF L-STRUCT = 4
                 MOVE 1 TO L-VALUE
             END-IF
         WHEN 3
             MOVE 0 TO L-VALUE
             IF L-STRUCT = 1
                 MOVE 5 TO L-VALUE
             END-IF
         WHEN 4
             MOVE 0 TO L-VALUE
             IF L-STRUCT = 1
                 MOVE 1 TO L-VALUE
             END-IF
         WHEN 5
             IF L-STRUCT = 2
                 MOVE 6 TO L-VALUE
             END-IF
         WHEN 6
             IF L-STRUCT = 2
                 MOVE 33 TO L-VALUE
             END-IF
         WHEN 7
             IF L-STRUCT = 2
                 MOVE 80 TO L-VALUE
             END-IF
         WHEN 8
             IF L-STRUCT = 2
                 CALL "NETHER-Y-SIZE" USING WS-THREE L-VALUE
             END-IF
         WHEN 9 THRU 12
             IF L-STRUCT = 2
                 MOVE 0 TO L-VALUE
             END-IF
         WHEN 13
             IF L-STRUCT = 2
                 MOVE 1 TO L-VALUE
             END-IF
         WHEN 14
             IF L-STRUCT = 3
                 MOVE 1 TO L-VALUE
             END-IF
         WHEN 15
             IF L-STRUCT = 3
                 MOVE 6 TO L-VALUE
             END-IF
         WHEN 16 THRU 20
             IF L-STRUCT = 3
                 MOVE 0 TO L-VALUE
             END-IF
         WHEN 21
             IF L-STRUCT = 3
                 MOVE 1 TO L-VALUE
             END-IF
         WHEN 22
             IF L-STRUCT = 3
                 MOVE 100 TO L-VALUE
             END-IF
         WHEN 23
             IF L-STRUCT = 4
                 MOVE 32 TO L-VALUE
             END-IF
         WHEN 24
             IF L-STRUCT = 4
                 MOVE 2 TO L-VALUE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-STRUCTURE-DEF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STUB.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-X2                   BINARY-LONG.
 01 L-Z2                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-X1 L-Z1 L-X2 L-Z2 L-Y L-SX L-SY L-SZ.
     MOVE L-X1 TO L-SX
     MOVE L-Z1 TO L-SZ
     MOVE L-Y TO L-SY
     EVALUATE L-STRUCT
         WHEN 1
             MOVE 64 TO L-SY
         WHEN 2
             COMPUTE L-SX = (L-X2 + L-X1) / 2
             COMPUTE L-SZ = (L-Z2 + L-Z1) / 2
             MOVE 33 TO L-SY
         WHEN 3
         WHEN 4
             CONTINUE
         WHEN OTHER
             MOVE -1 TO L-SY
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-STUB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-QUART.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-QUART                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-QUART.
     COMPUTE L-QUART = FUNCTION INTEGER(L-BLOCK / 4)
     GOBACK.
 END PROGRAM NETHER-QUART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FORTRESS-SHIFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROOM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SPAN                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-NEED                 BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SPAN L-DRAW L-NEED L-MIN.
     COMPUTE WS-ROOM = 23 - L-SPAN
     MOVE 48 TO L-MIN
     MOVE 0 TO L-NEED
     IF WS-ROOM > 1
         MOVE 1 TO L-NEED
         ADD L-DRAW TO L-MIN
     END-IF
     GOBACK.
 END PROGRAM NETHER-FORTRESS-SHIFT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FORTRESS-MOVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOX-MIN              BINARY-LONG.
 01 L-NEW-MIN              BINARY-LONG.
 01 L-DELTA                BINARY-LONG.
 PROCEDURE DIVISION USING L-BOX-MIN L-NEW-MIN L-DELTA.
     COMPUTE L-DELTA = L-NEW-MIN - L-BOX-MIN
     GOBACK.
 END PROGRAM NETHER-FORTRESS-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-Y-SIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POWER               BINARY-DOUBLE.
 01 WS-LOG                 BINARY-LONG.
 01 WS-HORIZONTAL          BINARY-LONG.
 01 WS-Y-LENGTH            BINARY-LONG.
 01 WS-Y-SIZE              BINARY-LONG.
 01 WS-MAX-Y               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-VALUE.
*>   the smallest power of two not below 30000000 is 2^25
     MOVE 1 TO WS-POWER
     MOVE 0 TO WS-LOG
     PERFORM UNTIL WS-POWER >= 30000000
         COMPUTE WS-POWER = WS-POWER * 2
         ADD 1 TO WS-LOG
     END-PERFORM
     COMPUTE WS-HORIZONTAL = 1 + WS-LOG
     COMPUTE WS-Y-LENGTH = 64 - 2 * WS-HORIZONTAL
     COMPUTE WS-Y-SIZE = 2 ** WS-Y-LENGTH - 32
     COMPUTE WS-MAX-Y = WS-Y-SIZE / 2 - 1
     EVALUATE L-CODE
         WHEN 1
             MOVE WS-HORIZONTAL TO L-VALUE
         WHEN 2
             MOVE WS-Y-LENGTH TO L-VALUE
         WHEN 3
             MOVE WS-Y-SIZE TO L-VALUE
         WHEN 4
             MOVE WS-MAX-Y TO L-VALUE
         WHEN 5
             COMPUTE L-VALUE = WS-MAX-Y - WS-Y-SIZE + 1
         WHEN OTHER
             MOVE -1 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-Y-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-JIGSAW-RANGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REACH                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-REACH L-OK.
     MOVE 0 TO L-OK
     IF L-REACH >= 1 AND L-REACH <= 128
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM NETHER-JIGSAW-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BELOW-TOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MIN-GEN             BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEVEL-MIN            BINARY-LONG.
 01 L-GEN-MIN              BINARY-LONG.
 01 L-LEVEL-HEIGHT         BINARY-LONG.
 01 L-GEN-DEPTH            BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL-MIN L-GEN-MIN L-LEVEL-HEIGHT L-GEN-DEPTH L-OFFSET L-Y.
     COMPUTE WS-MIN-GEN = FUNCTION MAX(L-LEVEL-MIN, L-GEN-MIN)
     COMPUTE WS-DEPTH = FUNCTION MIN(L-LEVEL-HEIGHT, L-GEN-DEPTH)
     COMPUTE L-Y = WS-MIN-GEN + WS-DEPTH - 1 - L-OFFSET
     GOBACK.
 END PROGRAM NETHER-BELOW-TOP.
