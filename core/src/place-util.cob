*> Small helpers of the block placement rules (lane wallitems, CC-0009; docs/protocol/29 section 9.5 and 25 part 4 section 9.2). Directions are the face numbers of Use Item On: 0 down, 1 up, 2 north, 3 south, 4 west,
*> 5 east. Entry points:
*>   PS-DIR-STEP USING direction, dx, dy, dz out (BINARY-LONG)       the unit step of a direction
*>   PS-OPP USING direction, opposite out                            Direction.getOpposite
*>   PS-CW USING direction, turned out, PS-CCW likewise              Direction.getClockWise / getCounterClockWise of a horizontal direction (seen from above)
*>   PS-DIR-NAME USING direction, text out (PIC X(32))               "down", "up", "north", "south", "west", "east"; PS-DIR-OF USING text, direction out (-1 for another text) is its inverse
*>   PS-PUT USING state in and out, property name (PIC X(24)), value text (PIC X(32))   sets one property (the state is left alone when the block has no such property or value)
*>   PS-GET USING state, property name, value text out, found out    reads one property
*>   PS-NAME-OF USING state, key out (PIC X(48))                     the key of the state's block without "minecraft:"
*>   PS-ENDS USING key (PIC X(48)), suffix (PIC X(24)), flag out     1 when the key ends with the suffix
*>   PS-HDIR USING yaw (FLOAT-LONG), direction out                   Direction.fromYRot: the horizontal direction a yaw looks to (0 south, 90 west, 180 north, 270 east)
*>   PS-SEGMENT USING angle in degrees (FLOAT-LONG), segment out     RotationSegment.convertToSegment: round(angle * 16 / 360) taken modulo 16
*>   PS-STANDING-KEY USING key (PIC X(48)), standing key out         the key a wall variant takes its loot table and item from ("wall_torch" gives "torch", "oak_wall_sign" "oak_sign", "oak_wall_hanging_sign"
*>                                                                   "oak_hanging_sign"); spaces for a key that is no wall variant

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-DIR-STEP.
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
 END PROGRAM PS-DIR-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-OPP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-OPP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-OPP.
     COMPUTE L-OPP = L-DIR + 1 - 2 * FUNCTION MOD(L-DIR, 2)
     GOBACK.
 END PROGRAM PS-OPP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-CW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-OUT.
*>   north to east to south to west to north.
     EVALUATE L-DIR
         WHEN 2
             MOVE 5 TO L-OUT
         WHEN 5
             MOVE 3 TO L-OUT
         WHEN 3
             MOVE 4 TO L-OUT
         WHEN OTHER
             MOVE 2 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM PS-CW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-CCW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-OUT.
*>   north to west to south to east to north.
     EVALUATE L-DIR
         WHEN 2
             MOVE 4 TO L-OUT
         WHEN 4
             MOVE 3 TO L-OUT
         WHEN 3
             MOVE 5 TO L-OUT
         WHEN OTHER
             MOVE 2 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM PS-CCW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-DIR-NAME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-TEXT                 PIC X(32).
 PROCEDURE DIVISION USING L-DIR L-TEXT.
     MOVE SPACES TO L-TEXT
     EVALUATE L-DIR
         WHEN 0
             MOVE "down" TO L-TEXT
         WHEN 1
             MOVE "up" TO L-TEXT
         WHEN 2
             MOVE "north" TO L-TEXT
         WHEN 3
             MOVE "south" TO L-TEXT
         WHEN 4
             MOVE "west" TO L-TEXT
         WHEN OTHER
             MOVE "east" TO L-TEXT
     END-EVALUATE
     GOBACK.
 END PROGRAM PS-DIR-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-PUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(24).
 01 L-TEXT                 PIC X(32).
 PROCEDURE DIVISION USING L-STATE L-NAME L-TEXT.
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE L-NAME L-TEXT WS-NEW
     MOVE WS-NEW TO L-STATE
     GOBACK.
 END PROGRAM PS-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(24).
 01 L-TEXT                 PIC X(32).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-NAME L-TEXT L-FOUND.
     MOVE SPACES TO L-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE L-NAME L-TEXT L-FOUND
     GOBACK.
 END PROGRAM PS-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-NAME-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(48).
 PROCEDURE DIVISION USING L-STATE L-NAME.
     MOVE SPACES TO L-NAME
     IF L-STATE >= 0 AND L-STATE < CB-STATE-COUNT
         CALL "KEY-BARE" USING CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) L-NAME
     END-IF
     GOBACK.
 END PROGRAM PS-NAME-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-ENDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-SUFFIX               PIC X(24).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-SUFFIX L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE WS-N = FUNCTION LENGTH(FUNCTION TRIM(L-NAME))
     COMPUTE WS-M = FUNCTION LENGTH(FUNCTION TRIM(L-SUFFIX))
     IF L-NAME NOT = SPACES AND WS-N >= WS-M
         COMPUTE WS-FROM = WS-N - WS-M + 1
         IF L-NAME(WS-FROM:WS-M) = L-SUFFIX(1:WS-M)
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PS-ENDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-HDIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-YAW L-DIR.
     COMPUTE WS-Q = FUNCTION MOD(FUNCTION INTEGER(L-YAW / 90 + 0.5), 4)
     EVALUATE WS-Q
         WHEN 0
             MOVE 3 TO L-DIR
         WHEN 1
             MOVE 4 TO L-DIR
         WHEN 2
             MOVE 2 TO L-DIR
         WHEN OTHER
             MOVE 5 TO L-DIR
     END-EVALUATE
     GOBACK.
 END PROGRAM PS-HDIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-SEGMENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALED              FLOAT-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ANGLE                FLOAT-LONG.
 01 L-SEGMENT              BINARY-LONG.
 PROCEDURE DIVISION USING L-ANGLE L-SEGMENT.
     COMPUTE WS-SCALED = L-ANGLE * 16 / 360 + 0.5
     COMPUTE WS-R = FUNCTION INTEGER(WS-SCALED)
     COMPUTE L-SEGMENT = FUNCTION MOD(WS-R, 16)
     GOBACK.
 END PROGRAM PS-SEGMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-STANDING-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-STANDING             PIC X(48).
 PROCEDURE DIVISION USING L-KEY L-STANDING.
     MOVE SPACES TO L-STANDING
     IF L-KEY(1:5) = "wall_"
         MOVE L-KEY(6:43) TO L-STANDING
         GOBACK
     END-IF
*>   "<name>_wall_<kind>": the text before "_wall_" and the text after "wall_" (the underscore before "wall" stays).
     MOVE 0 TO WS-N
     INSPECT L-KEY TALLYING WS-N FOR CHARACTERS BEFORE INITIAL "_wall_"
     COMPUTE WS-FROM = WS-N + 1
     IF WS-N < 42 AND L-KEY(WS-FROM:6) = "_wall_"
         COMPUTE WS-AFTER = WS-N + 6
         COMPUTE WS-LEFT = 48 - WS-AFTER
         COMPUTE WS-FROM = WS-AFTER + 1
         STRING L-KEY(1:WS-N) "_" L-KEY(WS-FROM:WS-LEFT) DELIMITED BY SIZE INTO L-STANDING
     END-IF
     GOBACK.
 END PROGRAM PS-STANDING-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-DIR-OF.
*> USING direction name (PIC X(32): "down", "up", "north", "south", "west", "east"), direction out (BINARY-LONG, -1 for any other text).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(32).
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-DIR.
     EVALUATE FUNCTION TRIM(L-TEXT)
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
 END PROGRAM PS-DIR-OF.
