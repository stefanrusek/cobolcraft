*> The prerequisites of the jigsaw assembly (docs/protocol/36-structures-2 sections 1.5, 3.4, 3.5 and 9.6, 36-structures-3 sections 4 and 5.6): the jigsaw_replacement processor, the jigsaw
*> records of a placed template (getJigsaws) and calculateConnectedPosition. The template cache keeps each jigsaw's block entity record in STRUCT-TPL-BE (STRUCT-TPL-NBT).
*>
*> Entry points:
*>   STRUCT-PROC-JIGSAW USING STRUCT-CUR, keep out: JigsawReplacementProcessor.processBlock (9.6): a jigsaw with block entity data becomes its final_state parsed as block state text (no tag; the
*>     trailing {...} of the text is dropped), nothing at all (keep 0) when the text does not parse or the state is structure_void; any other block, and a jigsaw without data, is kept
*>   STRUCT-JIG-DIRS USING state, front out, top out: the FrontAndTop of a jigsaw state (0 down, 1 up, 2 north, 3 south, 4 west, 5 east; -1 for a block with no orientation)
*>   STRUCT-GET-JIGSAWS USING template row, origin x, y, z, rotation: getJigsaws (3.5) into STRUCT-JIGSAWS (STRUCTJIG.cpy): the jigsaws of the palette chosen at the origin, each at the origin plus
*>     the rotated position with its state rotated, in block order; none for a template that is not loaded
*>   STRUCT-CONNECTED-POS USING mirror, rotation, pivot x, pivot z, x, y, z of A, the same of B, x, y, z out: calculateConnectedPosition (3.4): relative(A) - relative(B), relative being the transform of 3.1

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-JIGSAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY CBLOCKS.
 01 WS-TEXT                PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-GOOD                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 COPY STRUCTCUR.
 01 L-KEEP                 BINARY-LONG.
 PROCEDURE DIVISION USING STRUCT-CUR L-KEEP.
     MOVE 1 TO L-KEEP
     MOVE CB-S-BLOCK(CU-STATE + 1) TO WS-BLOCK
     IF CB-KEY(WS-BLOCK + 1) = "jigsaw" AND CU-NBT > 0
         IF TN-KIND(CU-NBT) = 4
             MOVE TN-TEXT(CU-NBT) TO WS-TEXT
             CALL "STRUCT-BLOCK-TEXT" USING WS-TEXT WS-STATE WS-GOOD
             MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
             IF WS-GOOD = 0 OR CB-KEY(WS-BLOCK + 1) = "structure_void"
                 MOVE 0 TO L-KEEP
             ELSE
                 MOVE WS-STATE TO CU-STATE
                 MOVE 0 TO CU-NBT CU-LOOT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PROC-JIGSAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-JIG-DIR.
*> USING name (PIC X(8)), direction out: the direction code of a name (0 down, 1 up, 2 north, 3 south, 4 west, 5 east; -1 unknown).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(8).
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-DIR.
     EVALUATE L-NAME
         WHEN "down"
             MOVE 0 TO L-DIR
         WHEN "up"
             MOVE 1 TO L-DIR
         WHEN "north"
             MOVE 2 TO L-DIR
         WHEN "south"
             MOVE 3 TO L-DIR
         WHEN "west"
             MOVE 4 TO L-DIR
         WHEN "east"
             MOVE 5 TO L-DIR
         WHEN OTHER
             MOVE -1 TO L-DIR
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-JIG-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-JIG-DIRS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-PROP                PIC X(24) VALUE "orientation".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-FRONT               PIC X(8).
 01 WS-TOP                 PIC X(8).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FRONT                BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FRONT L-TOP.
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-PROP WS-TEXT WS-FOUND
     MOVE -1 TO L-FRONT L-TOP
     IF WS-FOUND = 1
         MOVE SPACES TO WS-FRONT WS-TOP
         UNSTRING WS-TEXT DELIMITED BY "_" INTO WS-FRONT WS-TOP
         CALL "STRUCT-JIG-DIR" USING WS-FRONT L-FRONT
         CALL "STRUCT-JIG-DIR" USING WS-TOP L-TOP
     END-IF
     GOBACK.
 END PROGRAM STRUCT-JIG-DIRS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-GET-JIGSAWS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-MIRROR              BINARY-LONG VALUE 0.
 01 WS-PIVOT-X             BINARY-LONG VALUE 0.
 01 WS-PIVOT-Z             BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OX L-OY L-OZ L-ROT.
     MOVE 0 TO JG-COUNT
     IF L-ROW < 1 OR L-ROW > TP-COUNT
         GOBACK
     END-IF
     IF TP-STATUS(L-ROW) NOT = 1
         GOBACK
     END-IF
*>   the palette of a fresh StructurePlaceSettings with only the rotation set, chosen at the origin (4.3)
     CALL "STRUCT-PALETTE-PICK" USING TP-PALETTES(L-ROW) L-OX L-OY L-OZ WS-INDEX
     IF WS-INDEX < 0
         GOBACK
     END-IF
     COMPUTE WS-BASE = TP-BASE(L-ROW, WS-INDEX + 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(L-ROW) OR JG-COUNT >= JG-MAX
         MOVE TB-NBT(WS-BASE + WS-I) TO WS-TAG
         IF WS-TAG > 0
             IF TN-KIND(WS-TAG) = 4
                 ADD 1 TO JG-COUNT
                 MOVE TB-X(WS-BASE + WS-I) TO WS-X
                 MOVE TB-Y(WS-BASE + WS-I) TO WS-Y
                 MOVE TB-Z(WS-BASE + WS-I) TO WS-Z
                 CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-MIRROR L-ROT WS-PIVOT-X WS-PIVOT-Z WS-RX WS-RY WS-RZ
                 COMPUTE JG-X(JG-COUNT) = L-OX + WS-RX
                 COMPUTE JG-Y(JG-COUNT) = L-OY + WS-RY
                 COMPUTE JG-Z(JG-COUNT) = L-OZ + WS-RZ
                 CALL "BLOCK-ROTATE-STATE" USING TB-STATE(WS-BASE + WS-I) L-ROT JG-STATE(JG-COUNT)
                 CALL "STRUCT-JIG-DIRS" USING JG-STATE(JG-COUNT) JG-FRONT(JG-COUNT) JG-TOP(JG-COUNT)
                 MOVE TN-JOINT(WS-TAG) TO JG-JOINT(JG-COUNT)
                 IF JG-JOINT(JG-COUNT) = 0
                     MOVE 2 TO JG-JOINT(JG-COUNT)
                     IF JG-FRONT(JG-COUNT) >= 2
                         MOVE 1 TO JG-JOINT(JG-COUNT)
                     END-IF
                 END-IF
                 MOVE WS-TAG TO JG-TAG(JG-COUNT)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-GET-JIGSAWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CONNECTED-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-A-MIR                BINARY-LONG.
 01 L-A-ROT                BINARY-LONG.
 01 L-A-PX                 BINARY-LONG.
 01 L-A-PZ                 BINARY-LONG.
 01 L-A-X                  BINARY-LONG.
 01 L-A-Y                  BINARY-LONG.
 01 L-A-Z                  BINARY-LONG.
 01 L-B-MIR                BINARY-LONG.
 01 L-B-ROT                BINARY-LONG.
 01 L-B-PX                 BINARY-LONG.
 01 L-B-PZ                 BINARY-LONG.
 01 L-B-X                  BINARY-LONG.
 01 L-B-Y                  BINARY-LONG.
 01 L-B-Z                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A-MIR L-A-ROT L-A-PX L-A-PZ L-A-X L-A-Y L-A-Z L-B-MIR L-B-ROT L-B-PX L-B-PZ L-B-X L-B-Y L-B-Z L-X L-Y L-Z.
     CALL "STRUCT-TX-POS" USING L-A-X L-A-Y L-A-Z L-A-MIR L-A-ROT L-A-PX L-A-PZ WS-AX WS-AY WS-AZ
     CALL "STRUCT-TX-POS" USING L-B-X L-B-Y L-B-Z L-B-MIR L-B-ROT L-B-PX L-B-PZ WS-BX WS-BY WS-BZ
     COMPUTE L-X = WS-AX - WS-BX
     COMPUTE L-Y = WS-AY - WS-BY
     COMPUTE L-Z = WS-AZ - WS-BZ
     GOBACK.
 END PROGRAM STRUCT-CONNECTED-POS.
