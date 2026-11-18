*> The placed state of a torch item (lane bugtorch T30001; docs/protocol/25 part 4 section 9.2 StandingAndWallBlockItem.getPlacementState and 24 part 3 section 7.8 WallTorchBlock.getStateForPlacement):
*> the torch, soul torch, redstone torch and copper torch items are standing-and-wall items, so a torch clicked on the side of a block becomes the wall torch of its kind facing away from that
*> block. BLOCK-PLACE calls TORCH-PLACE-STATE with the state the item places; any other state is left as it is.
*>
*> Entry points:
*>   TORCH-WALL-BLOCK USING state, wall block number out (1-based, 0 when the state is not a standing torch)
*>   TORCH-PLACE-STATE USING dimension row, x, y, z (the cell the block goes to), clicked face, yaw, pitch (FLOAT-SHORT), state in and out, fits out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TORCH-WALL-BLOCK.
*> USING state, wall block number out (BINARY-LONG): the block (1-based table index) of the wall torch that belongs to the standing torch of the state: torch gives wall_torch, soul_torch
*> soul_wall_torch, redstone_torch redstone_wall_torch, copper_torch copper_wall_torch; 0 for any other block or a set without the wall block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FULL                PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-WALL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-WALL.
     MOVE 0 TO L-WALL
     IF L-STATE <= 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     CALL "KEY-NAMESPACED" USING CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) WS-FULL
     MOVE SPACES TO WS-KEY
     EVALUATE FUNCTION TRIM(WS-FULL)
         WHEN "minecraft:torch"
             MOVE "minecraft:wall_torch" TO WS-KEY
         WHEN "minecraft:soul_torch"
             MOVE "minecraft:soul_wall_torch" TO WS-KEY
         WHEN "minecraft:redstone_torch"
             MOVE "minecraft:redstone_wall_torch" TO WS-KEY
         WHEN "minecraft:copper_torch"
             MOVE "minecraft:copper_wall_torch" TO WS-KEY
         WHEN OTHER
             GOBACK
     END-EVALUATE
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     IF WS-ID >= 0
         COMPUTE L-WALL = WS-ID + 1
     END-IF
     GOBACK.
 END PROGRAM TORCH-WALL-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TORCH-PLACE-STATE.
*> USING dimension row, x, y, z (the cell the torch goes to), clicked face (0 down, 1 up, 2 north, 3 south, 4 west, 5 east), yaw, pitch (FLOAT-SHORT, degrees), state in and out, fits out
*> (BINARY-LONG): a state that is not a standing torch is left alone (fits 1). Otherwise 25-4 section 9.2 with the attachment direction DOWN: the directions are the nearest looking ones of 29
*> section 9.5 with the opposite of the clicked face first (the clicked block is not replaced; UI-NEAREST, UI-NEAREST-DIRS), the wall state is the first horizontal direction d whose wall torch
*> facing the opposite of d survives (WallTorchBlock.getStateForPlacement), and the result is the first direction other than UP whose candidate survives: the standing state for DOWN, the wall
*> state for a horizontal direction. No candidate survives: fits 0 and the state is unchanged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-WALL                BINARY-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-ORDER.
    05 WS-DIR              BINARY-LONG OCCURS 6 TIMES.
 01 WS-REPLACE             BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-PAIR                BINARY-LONG.
 01 WS-WALL-STATE          BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west ".
    05 FILLER              PIC X(5) VALUE "east ".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-FACING-NAME      PIC X(5) OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 01 L-STATE                BINARY-LONG.
 01 L-FITS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACE L-YAW L-PITCH L-STATE L-FITS.
     MOVE 1 TO L-FITS
     CALL "TORCH-WALL-BLOCK" USING L-STATE WS-WALL
     IF WS-WALL = 0
         GOBACK
     END-IF
     MOVE L-YAW TO WS-YAW
     MOVE L-PITCH TO WS-PITCH
     CALL "UI-NEAREST" USING WS-YAW WS-PITCH WS-ORDER
     CALL "UI-NEAREST-DIRS" USING WS-REPLACE L-FACE WS-ORDER
*>   The wall state: the first horizontal direction d (north 2, south 3, west 4, east 5) with the wall torch facing opposite(d) that survives; opposite(d) is the neighbour of d's pair.
     MOVE 0 TO WS-WALL-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-WALL-STATE > 0
         MOVE WS-DIR(WS-I) TO WS-D
         IF WS-D >= 2
             COMPUTE WS-PAIR = WS-D + 1 - 2 * FUNCTION MOD(WS-D, 2) - 1
             MOVE SPACES TO WS-TEXT
             MOVE WS-FACING-NAME(WS-PAIR) TO WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE CB-DEFAULT-STATE(WS-WALL) WS-NAME WS-TEXT WS-NEW
             CALL "SUP-SURVIVES" USING L-DIM L-X L-Y L-Z WS-NEW WS-OK
             IF WS-OK = 1
                 MOVE WS-NEW TO WS-WALL-STATE
             END-IF
         END-IF
     END-PERFORM
*>   The result: the first direction other than UP whose candidate survives (DOWN: the standing state; horizontal: the wall state).
     MOVE 0 TO WS-CAND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-CAND > 0
         MOVE WS-DIR(WS-I) TO WS-D
         EVALUATE TRUE
             WHEN WS-D = 1
                 CONTINUE
             WHEN WS-D = 0
                 CALL "SUP-SURVIVES" USING L-DIM L-X L-Y L-Z L-STATE WS-OK
                 IF WS-OK = 1
                     MOVE L-STATE TO WS-CAND
                 END-IF
             WHEN WS-WALL-STATE > 0
                 MOVE WS-WALL-STATE TO WS-CAND
         END-EVALUATE
     END-PERFORM
     IF WS-CAND = 0
         MOVE 0 TO L-FITS
         GOBACK
     END-IF
     MOVE WS-CAND TO L-STATE
     GOBACK.
 END PROGRAM TORCH-PLACE-STATE.
