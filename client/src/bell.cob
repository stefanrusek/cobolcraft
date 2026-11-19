*> The bells of the loaded chunks and their block entity renderer (docs/protocol/31-block-entities-4 section 4; 14 section 4.1 for the sprite `entity/bell/bell_body`, 51 R-C19 for the
*> frame). The block model of a bell is only its frame (the bar and post), so the bell itself, the body and the lip (`BellModel`: bell_body box (-3, -6, -3) 6 x 7 x 6 at texture (0, 0),
*> part offset (8, 12, 8), and its child bell_base box (4, 4, 4) 8 x 2 x 8 at texture (0, 13), 32 x 32 texels), was never drawn. The replica keeps the bells (BL-BELL of CLSTATE.cpy): a bell
*> is noted when a chunk loads (BELL-SCAN reads every cell), when a block changes (BELL-NOTE, from WORLD-BLOCK-SET), forgotten with its chunk (BELL-FORGET) or the dimension (BELL-CLEAR) and
*> dropped by the tick when its block is gone. Block Event 1 (BELL-EVENT) starts the swing in the direction of the parameter (31-4 4.2: ticks 0, shaking), BELL-TICK counts it (4.3: one more
*> a tick, ended at 50), BELL-MESH draws the body and the lip into the ground items mesh (the block atlas): at rest, or turned about the part pivot (8, 12, 8) by the swing of 4.4 (BE4-BELL-ANIM
*> of the core: a = sin(ticks / pi) / (4 + ticks / 3), xRot -a for a north ring and +a for south, zRot -a for east and +a for west; ticks is the tick count and the part of the tick the
*> frame is in). The model has y up and no flip, like the chest (52 2.2), so it is unwrapped like the chest (SPECIAL-CUBOID with the y ends exchanged).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-TABLE.
*> USING CLIENT-STATE: BL-IS of every block id from its name in the state tables (`bell`); BL-READY becomes 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 2048
         MOVE 0 TO BL-IS(WS-B)
         IF ST-BLOCK-NAME(WS-B) = "bell"
             MOVE 1 TO BL-IS(WS-B)
         END-IF
     END-PERFORM
     MOVE 1 TO BL-READY
     GOBACK.
 END PROGRAM BELL-TABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-ADD.
*> USING CLIENT-STATE, x, y, z, state id of a bell block: the bell of that place takes the state (a new one is still); no free slot of the 32: it is not kept.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         IF BL-USED(WS-I) = 1 AND BL-X(WS-I) = L-X AND BL-Y(WS-I) = L-Y AND BL-Z(WS-I) = L-Z
             MOVE WS-I TO WS-AT
         END-IF
         IF BL-USED(WS-I) = 0 AND WS-FREE = 0
             MOVE WS-I TO WS-FREE
         END-IF
     END-PERFORM
     IF WS-AT = 0 AND WS-FREE > 0
         MOVE WS-FREE TO WS-AT
         MOVE 1 TO BL-USED(WS-AT)
         MOVE L-X TO BL-X(WS-AT)
         MOVE L-Y TO BL-Y(WS-AT)
         MOVE L-Z TO BL-Z(WS-AT)
         MOVE 0 TO BL-SHAKING(WS-AT) BL-TICKS(WS-AT) BL-DIR(WS-AT)
         ADD 1 TO BL-COUNT
     END-IF
     IF WS-AT > 0
         MOVE L-STATE TO BL-SID(WS-AT)
     END-IF
     GOBACK.
 END PROGRAM BELL-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-NOTE.
*> USING CLIENT-STATE, x, y, z, state id (BINARY-LONG): a cell took the state: a bell state is noted (BELL-ADD); the tables are built when they are not.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-STATE.
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     IF BL-READY = 0
         CALL "BELL-TABLE" USING CLIENT-STATE
     END-IF
     IF L-STATE > 0 AND L-STATE < ST-COUNT
         IF BL-IS(ST-BLOCK(L-STATE + 1) + 1) = 1
             CALL "BELL-ADD" USING CLIENT-STATE L-X L-Y L-Z L-STATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BELL-NOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-SCAN.
*> USING CLIENT-STATE, chunk x, chunk z: every cell of the chunk in the replica that holds a bell state is noted (the chunk has just loaded).
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
     IF BL-READY = 0
         CALL "BELL-TABLE" USING CLIENT-STATE
     END-IF
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ WS-ROW
     IF WS-ROW > 0
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
         COMPUTE WS-CELLS = PL-HEIGHT * 256
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
             IF CE-STATE(WS-I) > 0 AND CE-STATE(WS-I) < ST-COUNT
                 IF BL-IS(ST-BLOCK(CE-STATE(WS-I) + 1) + 1) = 1
                     MOVE CE-STATE(WS-I) TO WS-STATE
                     COMPUTE WS-Y = (WS-I - 1) / 256
                     COMPUTE WS-REST = WS-I - 1 - WS-Y * 256
                     COMPUTE WS-Z = WS-REST / 16
                     COMPUTE WS-X = WS-REST - WS-Z * 16
                     COMPUTE WS-X = L-CX * 16 + WS-X
                     COMPUTE WS-Z = L-CZ * 16 + WS-Z
                     COMPUTE WS-Y = PL-MIN-Y + WS-Y
                     CALL "BELL-ADD" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BELL-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-FORGET.
*> USING CLIENT-STATE, chunk x, chunk z: the bells of that chunk are dropped (Forget Level Chunk).
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         IF BL-USED(WS-I) = 1
             COMPUTE WS-CX = FUNCTION INTEGER(BL-X(WS-I) / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(BL-Z(WS-I) / 16)
             IF WS-CX = L-CX AND WS-CZ = L-CZ
                 MOVE 0 TO BL-USED(WS-I)
                 SUBTRACT 1 FROM BL-COUNT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BELL-FORGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-CLEAR.
*> USING CLIENT-STATE: no bells (the replica is cleared).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         MOVE 0 TO BL-USED(WS-I)
     END-PERFORM
     MOVE 0 TO BL-COUNT
     GOBACK.
 END PROGRAM BELL-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-EVENT.
*> USING CLIENT-STATE, x, y, z, action id, parameter (BINARY-LONG): Block Event of a bell (31-4 4.2 triggerEvent): action 1 sets the click direction to the parameter (the Direction order),
*> ticks 0 and shaking; another action changes nothing. The bell is noted when the cell holds one and the replica did not have it yet.
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
     CALL "BELL-NOTE" USING CLIENT-STATE L-X L-Y L-Z WS-STATE
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         IF BL-USED(WS-I) = 1 AND BL-X(WS-I) = L-X AND BL-Y(WS-I) = L-Y AND BL-Z(WS-I) = L-Z
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF WS-AT > 0
         MOVE L-PARAM TO BL-DIR(WS-AT)
         MOVE 0 TO BL-TICKS(WS-AT)
         MOVE 1 TO BL-SHAKING(WS-AT)
     END-IF
     GOBACK.
 END PROGRAM BELL-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-TICK.
*> USING CLIENT-STATE: one client tick of every bell (31-4 4.3 steps 1 and 2): a bell whose block is gone (the cell no longer holds its state: a bell of another state is taken over, anything
*> else drops the bell) is dropped; a shaking bell counts one more tick, and at 50 ticks it stops (ticks 0, not shaking).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         IF BL-USED(WS-I) = 1
             CALL "WORLD-CELL" USING CLIENT-STATE BL-X(WS-I) BL-Y(WS-I) BL-Z(WS-I) WS-STATE WS-SKY WS-BLK
             IF WS-STATE NOT = BL-SID(WS-I)
                 MOVE 0 TO BL-USED(WS-I)
                 SUBTRACT 1 FROM BL-COUNT
                 CALL "BELL-NOTE" USING CLIENT-STATE BL-X(WS-I) BL-Y(WS-I) BL-Z(WS-I) WS-STATE
             END-IF
         END-IF
         IF BL-USED(WS-I) = 1 AND BL-SHAKING(WS-I) = 1
             ADD 1 TO BL-TICKS(WS-I)
             IF BL-TICKS(WS-I) >= 50
                 MOVE 0 TO BL-SHAKING(WS-I) BL-TICKS(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BELL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): the body and the lip of every bell within 64 blocks as quads into the ground items mesh (SPECIAL-EMIT-WORLD): the two cuboids of the model turned
*> about the pivot (8, 12, 8) by the swing, in the block's own cell, with the light of that cell. The swing time is the tick count and the part of the tick the frame is in.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLSQ.
 COPY CLSQP.
 01 WS-ROWS-DATA.
    05 FILLER PIC X(95) VALUE "-0003-0006-0003+0006+0007+0006+0000+0000+0008+0012+0008+0008+0012+0008+0000+0000+0000+0000+0001".
    05 FILLER PIC X(95) VALUE "+0004+0004+0004+0008+0002+0008+0000+0013+0000+0000+0000+0008+0012+0008+0000+0000+0000+0000+0001".
 01 WS-ROWS REDEFINES WS-ROWS-DATA.
    05 WS-ROW              PIC X(95) OCCURS 2 TIMES.
 01 WS-ID                  PIC X(80) VALUE "minecraft:entity/bell/bell_body".
 01 WS-ID-LEN              BINARY-LONG VALUE 31.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-PARTIAL             FLOAT-LONG.
 01 WS-TICKS               FLOAT-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-XROT                FLOAT-LONG.
 01 WS-ZROT                FLOAT-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-OFFSET.
    05 WS-OF               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     IF BL-COUNT = 0
         GOBACK
     END-IF
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LEN WS-SPRITE
     IF WS-SPRITE = 0
         MOVE 1 TO WS-SPRITE
     END-IF
*>   The part of the tick the frame is in (the next client tick is due at CL-NEXT-TICK).
     COMPUTE WS-PARTIAL = FUNCTION MAX(0, FUNCTION MIN(1, 1 - (CL-NEXT-TICK - CL-NOW-MS) / 50))
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         IF BL-USED(WS-I) = 1
             COMPUTE WS-DX = BL-X(WS-I) + 0.5 - L-EYE(1)
             COMPUTE WS-DZ = BL-Z(WS-I) + 0.5 - L-EYE(3)
             IF WS-DX * WS-DX + WS-DZ * WS-DZ <= 4096
                 MOVE 0 TO WS-TICKS WS-DIR WS-XROT WS-ZROT
                 IF BL-SHAKING(WS-I) = 1
                     COMPUTE WS-TICKS = BL-TICKS(WS-I) + WS-PARTIAL
                     MOVE BL-DIR(WS-I) TO WS-DIR
                     CALL "BE4-BELL-ANIM" USING WS-TICKS WS-DIR WS-XROT WS-ZROT
                 END-IF
                 MOVE 0 TO SQ-COUNT
                 PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 2
                     CALL "SPECIAL-ROW-PART" USING WS-ROW(WS-R) SQ-PART
                     COMPUTE SP-RX = WS-XROT * 180 / FUNCTION PI
                     COMPUTE SP-RZ = WS-ZROT * 180 / FUNCTION PI
                     MOVE WS-SPRITE TO SP-SPRITE
                     MOVE 32 TO SP-TSIZE SP-THEIGHT
                     MOVE 1 TO SP-EXCH
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                         MOVE 0 TO SP-T(WS-K)
                         MOVE 1 TO SP-S(WS-K) SP-TINT(WS-K)
                     END-PERFORM
                     CALL "SPECIAL-CUBOID" USING CLIENT-STATE SQ-TABLE SQ-PART
                 END-PERFORM
                 CALL "WORLD-CELL" USING CLIENT-STATE BL-X(WS-I) BL-Y(WS-I) BL-Z(WS-I) WS-STATE WS-SKY WS-BLK
                 COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLK) / 15, 0.1)
                 COMPUTE WS-OF(1) = BL-X(WS-I) - L-EYE(1)
                 COMPUTE WS-OF(2) = BL-Y(WS-I) - L-EYE(2)
                 COMPUTE WS-OF(3) = BL-Z(WS-I) - L-EYE(3)
                 CALL "SPECIAL-EMIT-WORLD" USING CLIENT-STATE SQ-TABLE WS-OFFSET WS-LIGHT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BELL-MESH.
