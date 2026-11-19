*> The doors of the villagers (lane 002-lane-bugvlclaim, T57001; docs/protocol/18 section 5.1 path types WALKABLE_DOOR and DOOR_IRON_CLOSED, 44 part 3 section 2.15 InteractWithDoor). A villager's
*> path goes through a closed wooden door (a door whose block can be opened by hand, SW-BLOCK-KIND kind 3: not an iron door, whose malus is -1): STDMOB-CELL reads it as passable while VD-PATH-DOORS is
*> 1 (VILDOOR.cpy). VL-DOOR-TICK, run every tick of the brain, opens a closed wooden door on the cell the villager stands in or the next cell of its walk (both halves) and remembers it (doors_to_close, one
*> door here: TM-DOOR-ON, TM-DOOR-X/Y/Z of VM-T); a remembered door that is no longer on the path (not the cell of the villager nor the next cell) is closed again, one farther than 3 blocks, no longer
*> a wooden door or closed already is dropped. Not modelled: the sounds, the 20 tick hold-off of the document's countdown (the door is opened on the tick the next node is the door), the check for
*> another villager coming through the door (the other one opens it again on the tick its own next cell is the door), a list of doors (a second door on the path closes the first once passed).
*>   VL-DOOR-CLASS USING block (BINARY-LONG block id, as CB-S-BLOCK), class out        0 no door, 1 a door a mob opens by hand, 2 an iron door (cached per CB-EPOCH, VILDOOR.cpy)
*>   VL-DOOR-BLOCK USING block, wooden out                                          1 when the block is a door a mob can open
*>   VL-DOOR-STATE-OPEN USING state, open out                                       1 when the state is an open door (wooden or iron)
*>   VL-DOOR-OPEN-AT USING dim, x, y, z, state out, open out (0/1)                  the block state of a cell if it holds a wooden door, 0 if not; whether it is open
*>   VL-DOOR-SET USING dim, x, y, z (the cell of one half), open (0/1)               open or close both halves
*>   VL-DOOR-TICK USING entity row, slot                                              one tick of InteractWithDoor

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-DOOR-CLASS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY VILDOOR.
 01 WS-KIND                BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-CLASS.
     IF VD-EPOCH NOT = CB-EPOCH + 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1400
             MOVE 0 TO VD-CLASS(WS-I)
         END-PERFORM
         COMPUTE VD-EPOCH = CB-EPOCH + 1
     END-IF
     IF VD-CLASS(L-BLOCK + 1) = 0
         MOVE 1 TO VD-CLASS(L-BLOCK + 1)
         CALL "SW-BLOCK-KIND" USING L-BLOCK WS-KIND WS-DELAY
         IF WS-KIND = 3
             MOVE 2 TO VD-CLASS(L-BLOCK + 1)
         ELSE
             MOVE 0 TO WS-N
             INSPECT CB-KEY(L-BLOCK + 1) TALLYING WS-N FOR ALL "iron_door"
             IF WS-N > 0
                 MOVE 3 TO VD-CLASS(L-BLOCK + 1)
             END-IF
         END-IF
     END-IF
     COMPUTE L-CLASS = VD-CLASS(L-BLOCK + 1) - 1
     GOBACK.
 END PROGRAM VL-DOOR-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-DOOR-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-WOODEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-WOODEN.
     MOVE 0 TO L-WOODEN
     CALL "VL-DOOR-CLASS" USING L-BLOCK WS-CLASS
     IF WS-CLASS = 1
         MOVE 1 TO L-WOODEN
     END-IF
     GOBACK.
 END PROGRAM VL-DOOR-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-DOOR-STATE-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-NAME-OPEN           PIC X(16) VALUE "open".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-OLD                 PIC X(16).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-OPEN.
     MOVE 0 TO L-OPEN
     IF L-STATE > 0 AND L-STATE < CB-STATE-COUNT
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
         CALL "VL-DOOR-CLASS" USING WS-BLOCK WS-CLASS
         IF WS-CLASS > 0
             CALL "SW-SET-PROP" USING L-STATE WS-NAME-OPEN WS-KEEP WS-NEW WS-OLD
             IF WS-OLD = "true"
                 MOVE 1 TO L-OPEN
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-DOOR-STATE-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-DOOR-OPEN-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-WOODEN              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-OPEN.
     MOVE 0 TO L-STATE L-OPEN
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0 AND WS-STATE < CB-STATE-COUNT
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
         CALL "VL-DOOR-BLOCK" USING WS-BLOCK WS-WOODEN
         IF WS-WOODEN = 1
             MOVE WS-STATE TO L-STATE
             CALL "VL-DOOR-STATE-OPEN" USING WS-STATE L-OPEN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-DOOR-OPEN-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-DOOR-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-NAME-OPEN           PIC X(16) VALUE "open".
 01 WS-NAME-HALF           PIC X(16) VALUE "half".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-HALF                PIC X(16).
 01 WS-VALUE               PIC X(16).
 01 WS-OLD                 PIC X(16).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OPEN.
     MOVE "false" TO WS-VALUE
     IF L-OPEN = 1
         MOVE "true" TO WS-VALUE
     END-IF
*>   The cell given and the one beside it in the other half's direction: every one that holds a door of the same block is written (both halves hold the same open, 30 part 7).
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-Y = L-Y + WS-I
         CALL "VL-DOOR-OPEN-AT" USING L-DIM L-X WS-Y L-Z WS-STATE WS-OPEN
         IF WS-STATE > 0
             CALL "SW-SET-PROP" USING WS-STATE WS-NAME-OPEN WS-VALUE WS-NEW WS-OLD
             IF WS-NEW NOT = WS-STATE
                 CALL "BLOCK-CHANGE" USING L-DIM L-X WS-Y L-Z WS-NEW
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-DOOR-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-DOOR-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 78 TM-DOOR-ON             VALUE 54.
 78 TM-DOOR-X              VALUE 55.
 78 TM-DOOR-Y              VALUE 56.
 78 TM-DOOR-Z              VALUE 57.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-HAS-NEXT            BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-ON-PATH             BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE 0 TO WS-HAS-NEXT
     MOVE WS-CX TO WS-NX
     MOVE WS-CZ TO WS-NZ
     IF EN-COOLDOWN(L-ROW) > 0 AND (EN-WAY-X(L-ROW) NOT = 0 OR EN-WAY-Z(L-ROW) NOT = 0)
         COMPUTE WS-NX = FUNCTION INTEGER(EN-WAY-X(L-ROW))
         COMPUTE WS-NZ = FUNCTION INTEGER(EN-WAY-Z(L-ROW))
         MOVE 1 TO WS-HAS-NEXT
     END-IF
*>   The remembered door: dropped when farther than 3 blocks, no longer a wooden door or closed already; closed (and dropped) once it is neither the villager's cell nor the next one.
     IF VM-T(L-SLOT, TM-DOOR-ON) = 1
         MOVE VM-T(L-SLOT, TM-DOOR-X) TO WS-DX
         MOVE VM-T(L-SLOT, TM-DOOR-Y) TO WS-DY
         MOVE VM-T(L-SLOT, TM-DOOR-Z) TO WS-DZ
         COMPUTE WS-FX = WS-DX + 0.5 - EN-X(L-ROW)
         COMPUTE WS-FZ = WS-DZ + 0.5 - EN-Z(L-ROW)
         COMPUTE WS-D2 = WS-FX * WS-FX + WS-FZ * WS-FZ
         CALL "VL-DOOR-OPEN-AT" USING EN-DIM(L-ROW) WS-DX WS-DY WS-DZ WS-STATE WS-OPEN
         MOVE 0 TO WS-ON-PATH
         IF WS-DX = WS-CX AND WS-DZ = WS-CZ
             MOVE 1 TO WS-ON-PATH
         END-IF
         IF WS-HAS-NEXT = 1 AND WS-DX = WS-NX AND WS-DZ = WS-NZ
             MOVE 1 TO WS-ON-PATH
         END-IF
         EVALUATE TRUE
             WHEN WS-D2 > 9 OR WS-STATE = 0 OR WS-OPEN = 0
                 MOVE 0 TO VM-T(L-SLOT, TM-DOOR-ON)
             WHEN WS-ON-PATH = 0
                 CALL "VL-DOOR-SET" USING EN-DIM(L-ROW) WS-DX WS-DY WS-DZ WS-ZERO
                 MOVE 0 TO VM-T(L-SLOT, TM-DOOR-ON)
         END-EVALUATE
     END-IF
*>   A closed wooden door on the villager's cell or the next one is opened.
     CALL "VL-DOOR-OPEN-AT" USING EN-DIM(L-ROW) WS-NX WS-CY WS-NZ WS-STATE WS-OPEN
     IF WS-STATE > 0 AND WS-OPEN = 0
         CALL "VL-DOOR-SET" USING EN-DIM(L-ROW) WS-NX WS-CY WS-NZ WS-ONE
         MOVE 1 TO VM-T(L-SLOT, TM-DOOR-ON)
         MOVE WS-NX TO VM-T(L-SLOT, TM-DOOR-X)
         MOVE WS-CY TO VM-T(L-SLOT, TM-DOOR-Y)
         MOVE WS-NZ TO VM-T(L-SLOT, TM-DOOR-Z)
     END-IF
     GOBACK.
 END PROGRAM VL-DOOR-TICK.
