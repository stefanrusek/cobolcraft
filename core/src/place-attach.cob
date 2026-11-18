*> Placement of the blocks that attach to a neighbour (lane wallitems, CC-0009; docs/protocol/25 part 4 section 9.2, 24 part 2 section 7.2 (ladder), part 3 sections 7.4 and 7.5 (signs, hanging signs, lever, button), part 4
*> sections 6.7 and 6.8 (vine, multiface), part 5 section 7.1 (skulls) and 7.17 (banners), part 7 section 11.2 (lantern)). Each program takes the placement context (PLACECTX.cpy) with PC-STATE the state the item
*> places and leaves the state to place there and PC-FITS (0: nothing is placed). The survive test is SUP-SURVIVES (support-29.cob), so a block is placed only where it would stay.
*> Entry points:
*>   PS-STANDWALL         the standing-and-wall items: torches, signs, hanging signs, banners, skulls and heads, coral fans (StandingAndWallBlockItem.getPlacementState)
*>   PS-HANGING-PLACE     USING PLACE-CONTEXT, wall hanging sign state, ok out: WallHangingSignBlock.canPlace
*>   PS-FACE-ATTACHED     levers, buttons, grindstones (FaceAttachedHorizontalDirectionalBlock.getStateForPlacement)
*>   PS-LADDER            ladders
*>   PS-LANTERN           lanterns (standing on a block or hanging from one)
*>   PS-MULTIFACE         vines, glow lichen, sculk veins, resin clumps (the face of the nearest looking direction that has something to hold on to)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-HANGING-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FACING              PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-SIDE-DIR            BINARY-LONG.
 01 WS-N-DIR               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-N-STATE             BINARY-LONG.
 01 WS-N-NAME              PIC X(48).
 01 WS-SUFFIX              PIC X(24) VALUE "wall_hanging_sign".
 01 WS-IS-SIGN             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PLACECTX.
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING PLACE-CONTEXT L-STATE L-OK.
     MOVE 0 TO L-OK
     CALL "PS-GET" USING L-STATE WS-FACING WS-TEXT WS-FOUND
     CALL "PS-DIR-OF" USING WS-TEXT WS-F
*>   canAttachTo for the neighbour on each side of the sign (clockwise then counter-clockwise): a wall hanging sign there must face along the same axis, any other block must be solid on the sign's side.
     PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 2 OR L-OK = 1
         IF WS-SIDE = 1
             CALL "PS-CW" USING WS-F WS-SIDE-DIR
         ELSE
             CALL "PS-CCW" USING WS-F WS-SIDE-DIR
         END-IF
         CALL "PS-DIR-STEP" USING WS-SIDE-DIR WS-DX WS-DY WS-DZ
         COMPUTE WS-X = PC-X + WS-DX
         COMPUTE WS-Y = PC-Y + WS-DY
         COMPUTE WS-Z = PC-Z + WS-DZ
         CALL "WORLD-GET-BLOCK" USING PC-DIM WS-X WS-Y WS-Z WS-N-STATE
         CALL "PS-NAME-OF" USING WS-N-STATE WS-N-NAME
         CALL "PS-ENDS" USING WS-N-NAME WS-SUFFIX WS-IS-SIGN
         IF WS-IS-SIGN = 1
             CALL "PS-GET" USING WS-N-STATE WS-FACING WS-TEXT WS-FOUND
             CALL "PS-DIR-OF" USING WS-TEXT WS-N-DIR
             COMPUTE WS-A1 = WS-N-DIR / 2
             COMPUTE WS-A2 = WS-F / 2
             IF WS-N-DIR >= 2 AND WS-A1 = WS-A2
                 MOVE 1 TO L-OK
             END-IF
         ELSE
             CALL "SUP-SOLID-AT" USING PC-DIM WS-X WS-Y WS-Z WS-SOLID WS-BLOCK WS-BITS
             IF WS-SOLID = 1
                 MOVE 1 TO L-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PS-HANGING-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-STANDWALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-WALL                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ATTACH              BINARY-LONG.
 01 WS-ATTACH-OPP          BINARY-LONG.
 01 WS-WALL-STATE          BINARY-LONG.
 01 WS-STANDING            BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FACING              PIC X(24) VALUE "facing".
 01 WS-ROTATION            PIC X(24) VALUE "rotation".
 01 WS-ATTACHED            PIC X(24) VALUE "attached".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-REPLACEABLE         BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:replaceable".
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-SEGMENT             BINARY-LONG.
 01 WS-SEGMENT-TEXT        PIC Z9.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-SNEAK-ATTACHED      BINARY-LONG.
 01 WS-ABOVE-NAME          PIC X(48).
 01 WS-SIGN-SUFFIX         PIC X(24) VALUE "hanging_sign".
 01 WS-IS-SIGN             BINARY-LONG.
 01 WS-A-DIR               BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-ATTACHED-TEXT       PIC X(32).
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE 1 TO PC-FITS
     CALL "PS-WALL-BLOCK" USING PC-STATE WS-WALL WS-KIND
*>   The attachment direction: DOWN for everything but the hanging sign, which hangs from UP.
     MOVE 0 TO WS-ATTACH
     IF WS-KIND = 5
         MOVE 1 TO WS-ATTACH
     END-IF
     CALL "PS-OPP" USING WS-ATTACH WS-ATTACH-OPP
*>   Step 1: the wall block's own getStateForPlacement. A torch, sign, banner or fan faces the opposite of the first horizontal nearest direction at which it survives (WallTorchBlock, WallSignBlock, WallBannerBlock,
*>   CoralWallFanBlock); a wall skull the opposite of the first horizontal direction that holds a block that is not replaceable (WallSkullBlock); a wall hanging sign the opposite of the first horizontal direction along
*>   the axis of the clicked face where it can be placed (WallHangingSignBlock).
     MOVE 0 TO WS-WALL-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-WALL-STATE > 0
         MOVE PC-DIR(WS-I) TO WS-D
         IF WS-D >= 2
             CALL "PS-OPP" USING WS-D WS-OPP
             CALL "PS-DIR-NAME" USING WS-OPP WS-TEXT
             MOVE CB-DEFAULT-STATE(WS-WALL) TO WS-CAND
             CALL "PS-PUT" USING WS-CAND WS-FACING WS-TEXT
             EVALUATE WS-KIND
                 WHEN 4
                     CALL "PS-DIR-STEP" USING WS-D WS-DX WS-DY WS-DZ
                     COMPUTE WS-X = PC-X + WS-DX
                     COMPUTE WS-Y = PC-Y + WS-DY
                     COMPUTE WS-Z = PC-Z + WS-DZ
                     CALL "WORLD-GET-BLOCK" USING PC-DIM WS-X WS-Y WS-Z WS-OLD
                     MOVE 1 TO WS-REPLACEABLE
                     IF WS-OLD > 0
                         MOVE CB-S-BLOCK(WS-OLD + 1) TO WS-BLOCK
                         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-REPLACEABLE
                     END-IF
                     IF WS-REPLACEABLE = 0
                         MOVE WS-CAND TO WS-WALL-STATE
                     END-IF
                 WHEN 5
                     COMPUTE WS-A1 = WS-D / 2
                     COMPUTE WS-A2 = PC-FACE / 2
                     IF WS-A1 = WS-A2
                         CALL "PS-HANGING-PLACE" USING PLACE-CONTEXT WS-CAND WS-OK
                         IF WS-OK = 1
                             MOVE WS-CAND TO WS-WALL-STATE
                         END-IF
                     END-IF
                 WHEN OTHER
                     CALL "SUP-SURVIVES" USING PC-DIM PC-X PC-Y PC-Z WS-CAND WS-OK
                     IF WS-OK = 1
                         MOVE WS-CAND TO WS-WALL-STATE
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
*>   The standing block's state: a sign and a banner turn to the player (the segment of the yaw plus 180 degrees), a skull or head to the yaw itself; a torch and a fan are the default state; a ceiling hanging
*>   sign is attached unless a full block holds its centre, and then turns to the player's direction.
     MOVE PC-STATE TO WS-STANDING
     EVALUATE WS-KIND
         WHEN 2
         WHEN 3
             COMPUTE WS-ANGLE = PC-YAW + 180
             CALL "PS-SEGMENT" USING WS-ANGLE WS-SEGMENT
             MOVE WS-SEGMENT TO WS-SEGMENT-TEXT
             MOVE FUNCTION TRIM(WS-SEGMENT-TEXT) TO WS-TEXT
             CALL "PS-PUT" USING WS-STANDING WS-ROTATION WS-TEXT
         WHEN 4
             CALL "PS-SEGMENT" USING PC-YAW WS-SEGMENT
             MOVE WS-SEGMENT TO WS-SEGMENT-TEXT
             MOVE FUNCTION TRIM(WS-SEGMENT-TEXT) TO WS-TEXT
             CALL "PS-PUT" USING WS-STANDING WS-ROTATION WS-TEXT
         WHEN 5
             COMPUTE WS-ABOVE = PC-Y + 1
             CALL "WORLD-GET-BLOCK" USING PC-DIM PC-X WS-ABOVE PC-Z WS-OLD
             CALL "PS-FULL-AT" USING PC-DIM PC-X WS-ABOVE PC-Z WS-SOLID
             MOVE 1 TO WS-SNEAK-ATTACHED
             IF WS-SOLID = 1 AND PC-SNEAK = 0
                 MOVE 0 TO WS-SNEAK-ATTACHED
             END-IF
*>           A hanging sign above (not sneaking) lines up with it: a wall hanging sign by its facing, a ceiling one by its rotation when that is a quarter turn.
             CALL "PS-NAME-OF" USING WS-OLD WS-ABOVE-NAME
             CALL "PS-ENDS" USING WS-ABOVE-NAME WS-SIGN-SUFFIX WS-IS-SIGN
             IF WS-IS-SIGN = 1 AND PC-SNEAK = 0
                 MOVE -1 TO WS-A-DIR
                 CALL "PS-GET" USING WS-OLD WS-FACING WS-TEXT WS-FOUND
                 IF WS-FOUND = 1
                     CALL "PS-DIR-OF" USING WS-TEXT WS-A-DIR
                 ELSE
                     CALL "PS-GET" USING WS-OLD WS-ROTATION WS-TEXT WS-FOUND
                     IF WS-FOUND = 1
                         COMPUTE WS-ROT = FUNCTION NUMVAL(WS-TEXT)
                         EVALUATE WS-ROT
                             WHEN 0
                                 MOVE 2 TO WS-A-DIR
                             WHEN 4
                                 MOVE 5 TO WS-A-DIR
                             WHEN 8
                                 MOVE 3 TO WS-A-DIR
                             WHEN 12
                                 MOVE 4 TO WS-A-DIR
                         END-EVALUATE
                     END-IF
                 END-IF
                 IF WS-A-DIR >= 2
                     COMPUTE WS-A1 = WS-A-DIR / 2
                     COMPUTE WS-A2 = PC-HDIR / 2
                     IF WS-A1 = WS-A2
                         MOVE 0 TO WS-SNEAK-ATTACHED
                     END-IF
                 END-IF
             END-IF
             IF WS-SNEAK-ATTACHED = 1
                 MOVE "true" TO WS-ATTACHED-TEXT
                 COMPUTE WS-ANGLE = PC-YAW + 180
                 CALL "PS-SEGMENT" USING WS-ANGLE WS-SEGMENT
             ELSE
                 MOVE "false" TO WS-ATTACHED-TEXT
*>               convertToSegment of the opposite of the player's direction: 0 for a player looking north, 4 east, 8 south, 12 west.
                 EVALUATE PC-HDIR
                     WHEN 2
                         MOVE 0 TO WS-SEGMENT
                     WHEN 5
                         MOVE 4 TO WS-SEGMENT
                     WHEN 3
                         MOVE 8 TO WS-SEGMENT
                     WHEN OTHER
                         MOVE 12 TO WS-SEGMENT
                 END-EVALUATE
             END-IF
             CALL "PS-PUT" USING WS-STANDING WS-ATTACHED WS-ATTACHED-TEXT
             MOVE WS-SEGMENT TO WS-SEGMENT-TEXT
             MOVE FUNCTION TRIM(WS-SEGMENT-TEXT) TO WS-TEXT
             CALL "PS-PUT" USING WS-STANDING WS-ROTATION WS-TEXT
     END-EVALUATE
*>   Step 2 and 3 of 25 part 4 section 9.2: the first nearest direction that is not the opposite of the attachment takes the standing state when it is the attachment direction and the wall state otherwise; the first
*>   candidate that can be placed wins.
     MOVE 0 TO WS-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-RESULT > 0
         MOVE PC-DIR(WS-I) TO WS-D
         IF WS-D NOT = WS-ATTACH-OPP
             IF WS-D = WS-ATTACH
                 MOVE WS-STANDING TO WS-CAND
             ELSE
                 MOVE WS-WALL-STATE TO WS-CAND
             END-IF
             IF WS-CAND > 0
                 MOVE 1 TO WS-OK
                 IF NOT (WS-KIND = 5 AND WS-D NOT = WS-ATTACH)
                     CALL "SUP-SURVIVES" USING PC-DIM PC-X PC-Y PC-Z WS-CAND WS-OK
                 END-IF
                 IF WS-OK = 1
                     MOVE WS-CAND TO WS-RESULT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-RESULT = 0
         MOVE 0 TO PC-FITS
         GOBACK
     END-IF
     MOVE WS-RESULT TO PC-STATE
     GOBACK.
 END PROGRAM PS-STANDWALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-FACE-ATTACHED.
*> The first nearest looking direction at which the lever, button or grindstone survives (24 part 3 section 7.5): a vertical direction gives face ceiling (up) or floor (down) and the player's horizontal direction as
*> facing, a horizontal one face wall and the opposite of the direction as facing. Nothing survives: nothing is placed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FACE-NAME           PIC X(24) VALUE "face".
 01 WS-FACING-NAME         PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE 0 TO WS-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-RESULT > 0
         MOVE PC-DIR(WS-I) TO WS-D
         MOVE PC-STATE TO WS-CAND
         IF WS-D < 2
             MOVE "floor" TO WS-TEXT
             IF WS-D = 1
                 MOVE "ceiling" TO WS-TEXT
             END-IF
             CALL "PS-PUT" USING WS-CAND WS-FACE-NAME WS-TEXT
             CALL "PS-DIR-NAME" USING PC-HDIR WS-TEXT
         ELSE
             MOVE "wall" TO WS-TEXT
             CALL "PS-PUT" USING WS-CAND WS-FACE-NAME WS-TEXT
             CALL "PS-OPP" USING WS-D WS-OPP
             CALL "PS-DIR-NAME" USING WS-OPP WS-TEXT
         END-IF
         CALL "PS-PUT" USING WS-CAND WS-FACING-NAME WS-TEXT
         CALL "SUP-SURVIVES" USING PC-DIM PC-X PC-Y PC-Z WS-CAND WS-OK
         IF WS-OK = 1
             MOVE WS-CAND TO WS-RESULT
         END-IF
     END-PERFORM
     MOVE 1 TO PC-FITS
     IF WS-RESULT = 0
         MOVE 0 TO PC-FITS
     ELSE
         MOVE WS-RESULT TO PC-STATE
     END-IF
     GOBACK.
 END PROGRAM PS-FACE-ATTACHED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-LADDER.
*> LadderBlock.getStateForPlacement (24 part 2 section 7.2) and the tripwire hook (24 part 4 section 6.26: the opposite of the first horizontal direction where it survives): a ladder is refused when the item does not replace the clicked block and the clicked block is a ladder facing the clicked face; otherwise the opposite of the
*> first horizontal nearest looking direction at which the ladder survives.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FACING-NAME         PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-CLICKED             BINARY-LONG.
 01 WS-FACE-DIR            BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE 1 TO PC-FITS
     CALL "PS-NAME-OF" USING PC-STATE WS-KEY
     IF PC-REPLACE = 0 AND WS-KEY = "ladder"
         CALL "WORLD-GET-BLOCK" USING PC-DIM PC-BX PC-BY PC-BZ WS-CLICKED
         IF WS-CLICKED > 0 AND WS-CLICKED < CB-STATE-COUNT
             IF CB-S-BLOCK(WS-CLICKED + 1) = CB-S-BLOCK(PC-STATE + 1)
                 CALL "PS-GET" USING WS-CLICKED WS-FACING-NAME WS-TEXT WS-FOUND
                 CALL "PS-DIR-OF" USING WS-TEXT WS-FACE-DIR
                 IF WS-FACE-DIR = PC-FACE
                     MOVE 0 TO PC-FITS
                     GOBACK
                 END-IF
             END-IF
         END-IF
     END-IF
     MOVE 0 TO WS-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-RESULT > 0
         MOVE PC-DIR(WS-I) TO WS-D
         IF WS-D >= 2
             CALL "PS-OPP" USING WS-D WS-OPP
             CALL "PS-DIR-NAME" USING WS-OPP WS-TEXT
             MOVE PC-STATE TO WS-CAND
             CALL "PS-PUT" USING WS-CAND WS-FACING-NAME WS-TEXT
             CALL "SUP-SURVIVES" USING PC-DIM PC-X PC-Y PC-Z WS-CAND WS-OK
             IF WS-OK = 1
                 MOVE WS-CAND TO WS-RESULT
             END-IF
         END-IF
     END-PERFORM
     IF WS-RESULT = 0
         MOVE 0 TO PC-FITS
     ELSE
         MOVE WS-RESULT TO PC-STATE
     END-IF
     GOBACK.
 END PROGRAM PS-LADDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-LANTERN.
*> LanternBlock.getStateForPlacement (24 part 7 section 11.2): the first vertical nearest looking direction at which the lantern survives gives hanging = the direction is up.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-HANGING-NAME        PIC X(24) VALUE "hanging".
 01 WS-TEXT                PIC X(32).
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE 0 TO WS-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-RESULT > 0
         MOVE PC-DIR(WS-I) TO WS-D
         IF WS-D < 2
             MOVE "false" TO WS-TEXT
             IF WS-D = 1
                 MOVE "true" TO WS-TEXT
             END-IF
             MOVE PC-STATE TO WS-CAND
             CALL "PS-PUT" USING WS-CAND WS-HANGING-NAME WS-TEXT
             CALL "SUP-SURVIVES" USING PC-DIM PC-X PC-Y PC-Z WS-CAND WS-OK
             IF WS-OK = 1
                 MOVE WS-CAND TO WS-RESULT
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO PC-FITS
     IF WS-RESULT = 0
         MOVE 0 TO PC-FITS
     ELSE
         MOVE WS-RESULT TO PC-STATE
     END-IF
     GOBACK.
 END PROGRAM PS-LANTERN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-MULTIFACE.
*> VineBlock and MultifaceBlock.getStateForPlacement (24 part 4 sections 6.7 and 6.8): the base is the block already at the cell when it is the same block, else the default state; the first nearest looking
*> direction (not down for a vine) whose face is not set and whose neighbour can hold the face sets that face. Nothing qualifies: nothing is placed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-DIR-TEXT            PIC X(32).
 01 WS-TRUE                PIC X(32) VALUE "true".
 01 WS-FOUND               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-IS-VINE             BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE PC-STATE TO WS-BASE
     CALL "WORLD-GET-BLOCK" USING PC-DIM PC-X PC-Y PC-Z WS-OLD
     IF WS-OLD > 0 AND WS-OLD < CB-STATE-COUNT
         IF CB-S-BLOCK(WS-OLD + 1) = CB-S-BLOCK(PC-STATE + 1)
             MOVE WS-OLD TO WS-BASE
         END-IF
     END-IF
     CALL "PS-NAME-OF" USING PC-STATE WS-KEY
     MOVE 0 TO WS-IS-VINE
     IF WS-KEY = "vine"
         MOVE 1 TO WS-IS-VINE
     END-IF
     MOVE 0 TO WS-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-RESULT > 0
         MOVE PC-DIR(WS-I) TO WS-D
         IF NOT (WS-D = 0 AND WS-IS-VINE = 1)
             CALL "PS-DIR-NAME" USING WS-D WS-DIR-TEXT
             MOVE WS-DIR-TEXT TO WS-NAME
             CALL "PS-GET" USING WS-BASE WS-NAME WS-TEXT WS-FOUND
             IF WS-FOUND = 1 AND FUNCTION TRIM(WS-TEXT) NOT = "true"
                 CALL "PS-DIR-STEP" USING WS-D WS-DX WS-DY WS-DZ
                 COMPUTE WS-X = PC-X + WS-DX
                 COMPUTE WS-Y = PC-Y + WS-DY
                 COMPUTE WS-Z = PC-Z + WS-DZ
                 CALL "SUP-SOLID-AT" USING PC-DIM WS-X WS-Y WS-Z WS-SOLID WS-BLOCK WS-BITS
                 IF WS-SOLID = 1
                     MOVE WS-BASE TO WS-CAND
                     CALL "PS-PUT" USING WS-CAND WS-NAME WS-TRUE
                     MOVE WS-CAND TO WS-RESULT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO PC-FITS
     IF WS-RESULT = 0
         MOVE 0 TO PC-FITS
     ELSE
         MOVE WS-RESULT TO PC-STATE
     END-IF
     GOBACK.
 END PROGRAM PS-MULTIFACE.
