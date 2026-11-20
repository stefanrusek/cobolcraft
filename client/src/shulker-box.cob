*> The shulker boxes of the loaded chunks and their block entity renderer (docs/protocol/52 section 4, 31-1 section 13). The model of a shulker box block has no elements, so the box is drawn from
*> the replica's own list (SB-BOX of CLSTATE.cpy): a box is noted when a chunk loads (SHULKER-SCAN reads every cell), when a block changes (SHULKER-NOTE, from WORLD-BLOCK-SET), forgotten with its
*> chunk (SHULKER-FORGET) or the dimension (SHULKER-CLEAR) and dropped by the tick when its block is gone. Block Event 1 (SHULKER-EVENT) opens (parameter 1) or closes (0) the lid, SHULKER-TICK steps
*> the lid by a tenth a tick (31-1 13.2: ticks 0 to 10, the status flips on the tenth tick), SHULKER-MESH draws the lid and the base (52 4.2 to 4.4) into the entity mesh, SHULKER-SLOTS gives the
*> colours' textures their slots of the entity atlas (the model row shulker_box, texture code 7000 + the colour, 16 undyed).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-TABLE.
*> USING CLIENT-STATE: SB-IS and SB-DYE of every block id from its name in the state tables (`shulker_box`: colour 16, `<dye>_shulker_box`: the dye's id in the order of 43 section 8, white to black);
*> SB-READY becomes 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DYES-DATA.
    05 FILLER PIC X(12) VALUE "white".
    05 FILLER PIC X(12) VALUE "orange".
    05 FILLER PIC X(12) VALUE "magenta".
    05 FILLER PIC X(12) VALUE "light_blue".
    05 FILLER PIC X(12) VALUE "yellow".
    05 FILLER PIC X(12) VALUE "lime".
    05 FILLER PIC X(12) VALUE "pink".
    05 FILLER PIC X(12) VALUE "gray".
    05 FILLER PIC X(12) VALUE "light_gray".
    05 FILLER PIC X(12) VALUE "cyan".
    05 FILLER PIC X(12) VALUE "purple".
    05 FILLER PIC X(12) VALUE "blue".
    05 FILLER PIC X(12) VALUE "brown".
    05 FILLER PIC X(12) VALUE "green".
    05 FILLER PIC X(12) VALUE "red".
    05 FILLER PIC X(12) VALUE "black".
 01 WS-DYES REDEFINES WS-DYES-DATA.
    05 WS-DYE              PIC X(12) OCCURS 16 TIMES.
 01 WS-B                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-PREFIX              PIC X(32).
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 2048
         MOVE 0 TO SB-IS(WS-B)
         MOVE 0 TO SB-DYE(WS-B)
         MOVE 0 TO WS-HITS
         INSPECT ST-BLOCK-NAME(WS-B) TALLYING WS-HITS FOR ALL "shulker_box"
         IF WS-HITS > 0
             MOVE 1 TO SB-IS(WS-B)
             MOVE 16 TO SB-DYE(WS-B)
             IF ST-BLOCK-NAME(WS-B) NOT = "shulker_box"
                 MOVE SPACES TO WS-PREFIX
                 UNSTRING ST-BLOCK-NAME(WS-B) DELIMITED BY "_shulker_box" INTO WS-PREFIX
                 PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 16
                     IF WS-PREFIX = WS-DYE(WS-D)
                         COMPUTE SB-DYE(WS-B) = WS-D - 1
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO SB-READY
     GOBACK.
 END PROGRAM SHULKER-TABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-FACING.
*> USING state id, facing out (BINARY-LONG in the Direction order: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east; up when the state has no facing): the property `facing` of the state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PROPS.
    05 WS-P-COUNT          BINARY-LONG.
    05 WS-P-ENTRY OCCURS 16 TIMES.
       10 WS-P-NAME        PIC X(24).
       10 WS-P-VALUE       PIC X(32).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FACE.
     MOVE 1 TO L-FACE
     CALL "CONTENT-STATE-PROPS" USING L-STATE WS-PROPS WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-P-COUNT
         IF WS-P-NAME(WS-I) = "facing"
             EVALUATE WS-P-VALUE(WS-I)
                 WHEN "down"
                     MOVE 0 TO L-FACE
                 WHEN "north"
                     MOVE 2 TO L-FACE
                 WHEN "south"
                     MOVE 3 TO L-FACE
                 WHEN "west"
                     MOVE 4 TO L-FACE
                 WHEN "east"
                     MOVE 5 TO L-FACE
                 WHEN OTHER
                     MOVE 1 TO L-FACE
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHULKER-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-ADD.
*> USING CLIENT-STATE, x, y, z, state id of a shulker box block: the box of that place takes the state, colour and facing (a new one starts closed); no free slot of the 64: it is not kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-STATE.
     MOVE 0 TO WS-AT WS-FREE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         IF SB-USED(WS-I) = 1 AND SB-X(WS-I) = L-X AND SB-Y(WS-I) = L-Y AND SB-Z(WS-I) = L-Z
             MOVE WS-I TO WS-AT
         END-IF
         IF SB-USED(WS-I) = 0 AND WS-FREE = 0
             MOVE WS-I TO WS-FREE
         END-IF
     END-PERFORM
     IF WS-AT = 0 AND WS-FREE > 0
         MOVE WS-FREE TO WS-AT
         MOVE 1 TO SB-USED(WS-AT)
         MOVE L-X TO SB-X(WS-AT)
         MOVE L-Y TO SB-Y(WS-AT)
         MOVE L-Z TO SB-Z(WS-AT)
         MOVE 0 TO SB-STATUS(WS-AT) SB-T(WS-AT) SB-TOLD(WS-AT)
         ADD 1 TO SB-COUNT
     END-IF
     IF WS-AT > 0
         MOVE L-STATE TO SB-SID(WS-AT)
         MOVE SB-DYE(ST-BLOCK(L-STATE + 1) + 1) TO SB-COLOUR(WS-AT)
         CALL "SHULKER-FACING" USING L-STATE SB-FACE(WS-AT)
     END-IF
     GOBACK.
 END PROGRAM SHULKER-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-NOTE.
*> USING CLIENT-STATE, x, y, z, state id (BINARY-LONG): a cell took the state: a shulker box state is noted (SHULKER-ADD); the tables are built when they are not.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-STATE.
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     IF SB-READY = 0
         CALL "SHULKER-TABLE" USING CLIENT-STATE
     END-IF
     IF L-STATE > 0 AND L-STATE < ST-COUNT
         IF SB-IS(ST-BLOCK(L-STATE + 1) + 1) = 1
             CALL "SHULKER-ADD" USING CLIENT-STATE L-X L-Y L-Z L-STATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHULKER-NOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-SCAN.
*> USING CLIENT-STATE, chunk x, chunk z: every cell of the chunk in the replica that holds a shulker box state is noted (the chunk has just loaded).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ.
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     IF SB-READY = 0
         CALL "SHULKER-TABLE" USING CLIENT-STATE
     END-IF
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ WS-ROW
     IF WS-ROW > 0
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
         COMPUTE WS-CELLS = PL-HEIGHT * 256
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
             IF CE-STATE(WS-I) > 0 AND CE-STATE(WS-I) < ST-COUNT
                 IF SB-IS(ST-BLOCK(CE-STATE(WS-I) + 1) + 1) = 1
                     MOVE CE-STATE(WS-I) TO WS-STATE
                     COMPUTE WS-Y = (WS-I - 1) / 256
                     COMPUTE WS-REST = WS-I - 1 - WS-Y * 256
                     COMPUTE WS-Z = WS-REST / 16
                     COMPUTE WS-X = WS-REST - WS-Z * 16
                     COMPUTE WS-X = L-CX * 16 + WS-X
                     COMPUTE WS-Z = L-CZ * 16 + WS-Z
                     COMPUTE WS-Y = PL-MIN-Y + WS-Y
                     CALL "SHULKER-ADD" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SHULKER-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-FORGET.
*> USING CLIENT-STATE, chunk x, chunk z: the boxes of that chunk are dropped (Forget Level Chunk).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         IF SB-USED(WS-I) = 1
             COMPUTE WS-CX = FUNCTION INTEGER(SB-X(WS-I) / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(SB-Z(WS-I) / 16)
             IF WS-CX = L-CX AND WS-CZ = L-CZ
                 MOVE 0 TO SB-USED(WS-I)
                 SUBTRACT 1 FROM SB-COUNT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHULKER-FORGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-CLEAR.
*> USING CLIENT-STATE: no boxes (the replica is cleared).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 0 TO SB-USED(WS-I)
     END-PERFORM
     MOVE 0 TO SB-COUNT
     GOBACK.
 END PROGRAM SHULKER-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-EVENT.
*> USING CLIENT-STATE, x, y, z, action id, parameter (BINARY-LONG): Block Event of a shulker box (31-1 13.3 triggerEvent): action 1 with the parameter 0 closes the lid (status
*> closing), 1 opens it (opening); 2 or more changes neither; another action changes nothing. The box is noted when the cell holds one and the replica did not have it yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-PARAM                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-ACTION L-PARAM.
     IF L-ACTION NOT = 1
         GOBACK
     END-IF
     CALL "WORLD-CELL" USING CLIENT-STATE L-X L-Y L-Z WS-STATE WS-SKY WS-BLK
     CALL "SHULKER-NOTE" USING CLIENT-STATE L-X L-Y L-Z WS-STATE
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         IF SB-USED(WS-I) = 1 AND SB-X(WS-I) = L-X AND SB-Y(WS-I) = L-Y AND SB-Z(WS-I) = L-Z
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF WS-AT > 0
         IF L-PARAM = 0
             MOVE 3 TO SB-STATUS(WS-AT)
         END-IF
         IF L-PARAM = 1
             MOVE 1 TO SB-STATUS(WS-AT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHULKER-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-TICK.
*> USING CLIENT-STATE: one client tick of every box (31-1 13.2): the box whose block is gone (the cell no longer holds its state: a shulker box of another state is taken over, anything else drops
*> the box) is dropped; the old lid value is the lid; opening adds a tenth and flips to opened on the tenth tick, closing takes a tenth and flips to closed on the tenth, a closed box is 0 and an opened
*> one 10 (SB-T ticks).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         IF SB-USED(WS-I) = 1
             CALL "WORLD-CELL" USING CLIENT-STATE SB-X(WS-I) SB-Y(WS-I) SB-Z(WS-I) WS-STATE WS-SKY WS-BLK
             IF WS-STATE NOT = SB-SID(WS-I)
                 MOVE 0 TO SB-USED(WS-I)
                 SUBTRACT 1 FROM SB-COUNT
                 CALL "SHULKER-NOTE" USING CLIENT-STATE SB-X(WS-I) SB-Y(WS-I) SB-Z(WS-I) WS-STATE
             END-IF
         END-IF
         IF SB-USED(WS-I) = 1
             MOVE SB-T(WS-I) TO SB-TOLD(WS-I)
             EVALUATE SB-STATUS(WS-I)
                 WHEN 0
                     MOVE 0 TO SB-T(WS-I)
                 WHEN 1
                     ADD 1 TO SB-T(WS-I)
                     IF SB-T(WS-I) >= 10
                         MOVE 10 TO SB-T(WS-I)
                         MOVE 2 TO SB-STATUS(WS-I)
                     END-IF
                 WHEN 2
                     MOVE 10 TO SB-T(WS-I)
                 WHEN OTHER
                     SUBTRACT 1 FROM SB-T(WS-I)
                     IF SB-T(WS-I) <= 0
                         MOVE 0 TO SB-T(WS-I) SB-STATUS(WS-I)
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHULKER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-SLOTS.
*> USING CLIENT-STATE, new (BINARY-LONG, set to 1 when a slot's image changed): the entity atlas slot of the texture of every box's colour (model row shulker_box, code 7000 + colour).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24) VALUE "shulker_box".
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NEW.
     IF SB-COUNT > 0
         CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-ROW
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
             IF SB-USED(WS-I) = 1
                 COMPUTE WS-CODE = 7000 + SB-COLOUR(WS-I)
                 CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SHULKER-SLOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): the lid and the base of every box within 64 blocks (52 4.2 to 4.4) as cuboids into the entity mesh: the block transform M = T(cell + 0.5 - eye)
*> S(0.9995) R(facing) S(1, -1, -1) T(0, -1, 0), the base at the pivot (0, 24, 0) (box (-8, -8, -8) 16 x 8 x 16, texture (0, 28)), the lid at (0, 24 - 8 p, 0) turned p x 270 degrees about Y
*> (box (-8, -16, -8) 16 x 12 x 16, texture (0, 0)), p the lid in tenths (the partial tick 1: SB-T / 10), 64 x 64 texels of the colour's slot; the light is the box's own cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KEY                 PIC X(24) VALUE "shulker_box".
 01 WS-R-DATA.
    05 FILLER PIC X(18) VALUE "+1+0+0+0-1+0+0+0-1".
    05 FILLER PIC X(18) VALUE "+1+0+0+0+1+0+0+0+1".
    05 FILLER PIC X(18) VALUE "-1+0+0+0+0-1+0-1+0".
    05 FILLER PIC X(18) VALUE "+1+0+0+0+0-1+0+1+0".
    05 FILLER PIC X(18) VALUE "+0-1+0+0+0-1+1+0+0".
    05 FILLER PIC X(18) VALUE "+0+1+0+0+0-1-1+0+0".
 01 WS-R-TABLE REDEFINES WS-R-DATA.
    05 WS-RD OCCURS 6 TIMES.
       10 WS-RV            PIC S9 SIGN LEADING SEPARATE OCCURS 9 TIMES.
 01 WS-DSIGN-DATA          PIC X(3) VALUE "+-1".
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-RR                  BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-M0.
    05 WS-M0V              FLOAT-LONG OCCURS 12 TIMES.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 5.
 01 WS-GEOM.
    05 WS-GV               FLOAT-LONG OCCURS 15 TIMES.
 01 WS-TINT.
    05 WS-TV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     IF SB-COUNT = 0
         GOBACK
     END-IF
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-ROW
     MOVE 1 TO WS-TV(1) WS-TV(2) WS-TV(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         IF SB-USED(WS-I) = 1
             COMPUTE WS-DX = SB-X(WS-I) + 0.5 - L-EYE(1)
             COMPUTE WS-DZ = SB-Z(WS-I) + 0.5 - L-EYE(3)
             MOVE 0 TO WS-SLOT
             COMPUTE WS-CODE = 7000 + SB-COLOUR(WS-I)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
                 IF EA-MT-MODEL(WS-S) = WS-ROW AND EA-MT-TEX(WS-S) = WS-CODE
                     MOVE WS-S TO WS-SLOT
                 END-IF
             END-PERFORM
             IF WS-SLOT > 0 AND WS-DX * WS-DX + WS-DZ * WS-DZ <= 4096 AND RL-EN-COUNT + 72 <= CL-MAX-ENTITY-VERTICES
*>               The linear part A = 0.9995 R diag(1, -1, -1) by rows (element (r, c) is MV((r - 1) * 3 + c)), the translation (cell + 0.5 - eye) - the second column.
                 COMPUTE WS-AT = SB-FACE(WS-I) + 1
                 PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 3
                     PERFORM VARYING WS-RR FROM 1 BY 1 UNTIL WS-RR > 3
                         COMPUTE WS-MV((WS-RR - 1) * 3 + WS-C) = 0.9995 * WS-RV(WS-AT, (WS-RR - 1) * 3 + WS-C)
                         IF WS-C > 1
                             COMPUTE WS-MV((WS-RR - 1) * 3 + WS-C) = 0 - WS-MV((WS-RR - 1) * 3 + WS-C)
                         END-IF
                     END-PERFORM
                 END-PERFORM
                 COMPUTE WS-MV(10) = SB-X(WS-I) + 0.5 - L-EYE(1) - WS-MV(2)
                 COMPUTE WS-MV(11) = SB-Y(WS-I) + 0.5 - L-EYE(2) - WS-MV(5)
                 COMPUTE WS-MV(12) = SB-Z(WS-I) + 0.5 - L-EYE(3) - WS-MV(8)
                 MOVE WS-M TO WS-M0
*>               The light of the box's own cell.
                 CALL "WORLD-CELL" USING CLIENT-STATE SB-X(WS-I) SB-Y(WS-I) SB-Z(WS-I) WS-STATE WS-SKY WS-BLK
                 COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLK) / 15, 0.1)
                 COMPUTE WS-P = SB-T(WS-I) / 10
*>               The lid: pivot (0, 24 - 8 p, 0), turned p x 270 degrees about Y.
                 MOVE 0 TO WS-AX WS-AZ
                 COMPUTE WS-AY = (24 - 8 * WS-P) / 16
                 CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
                 MOVE 2 TO WS-AXIS
                 COMPUTE WS-DEG = WS-P * 270
                 CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
                 MOVE 0 TO WS-GV(1) WS-GV(2) WS-GV(3) WS-GV(4) WS-GV(11) WS-GV(12) WS-GV(13)
                 MOVE -8 TO WS-GV(5) WS-GV(7)
                 MOVE -16 TO WS-GV(6)
                 MOVE 16 TO WS-GV(8) WS-GV(10)
                 MOVE 12 TO WS-GV(9)
                 MOVE 64 TO WS-GV(14) WS-GV(15)
                 CALL "HAND-CUBOID-MODE" USING CLIENT-STATE WS-M WS-SLOT WS-GEOM WS-TINT WS-LIGHT WS-MODE
*>               The base: pivot (0, 24, 0).
                 MOVE WS-M0 TO WS-M
                 MOVE 0 TO WS-AX WS-AZ
                 MOVE 1.5 TO WS-AY
                 CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
                 MOVE -8 TO WS-GV(5) WS-GV(6) WS-GV(7)
                 MOVE 16 TO WS-GV(8) WS-GV(10)
                 MOVE 8 TO WS-GV(9)
                 MOVE 0 TO WS-GV(11)
                 MOVE 28 TO WS-GV(12)
                 CALL "HAND-CUBOID-MODE" USING CLIENT-STATE WS-M WS-SLOT WS-GEOM WS-TINT WS-LIGHT WS-MODE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHULKER-MESH.
