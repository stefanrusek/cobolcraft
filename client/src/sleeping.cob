*> Sleeping in a bed on the client (lane bugsleep, operator report of try19: "no getting into the bed or getting out ... Villagers are invisible in beds"; docs/protocol/12 section 7.2 step 6
*> (the camera while sleeping), 18 section 1.4 entries 6 and 14, 34-1 section 6.5 and 34-2 sections 2.1 and 2.2 (the sleeping pose of a model), 53 (pose SLEEPING, eye height 0.2),
*> 05c Player Command 0 STOP_SLEEPING).
*> What the server says is kept: the pose of the own entity (PL-SLEEP, entry 6 = 2) and the bed cell (PL-BED-X..Z, entry 14) and, of every other entity, its sleeping position (EN-BED-SET,
*> EN-BED-X..Z). The bed's facing is read from the block of the replica at the bed cell (the bed orientation of the renderer).
*> Not done (no doc section says it): the darkening of the screen while asleep and the Leave Bed button; the way out is the Sneak key (Player Command STOP_SLEEPING).
*> Entry points:
*>   SLEEP-BED-FACING USING CLIENT-STATE, x, y, z (the bed cell), found out (PIC 9), step x, step z out (BINARY-LONG: the unit step of the facing), body yaw A out (the renderer's
*>     rotation about Y, 34-2 2.2: south 90, west 0, north 270, east 180), camera yaw out (the facing's yaw - 180: south 180, west -90, north 0, east 90; FLOAT-LONG)
*>   SLEEP-DATA-SET USING CLIENT-STATE, entity id, replica row (0 = none), entry index, serializer, int value, present, x, y, z: one entry of a Set Entity Data
*>   ENTITY-SLEEP-SEQUENCE USING CLIENT-STATE, replica row, ops out (64 FLOAT-LONG): the render sequence of a sleeping model (EM6-POSE-CHAIN)
*>   SLEEP-CAMERA USING CLIENT-STATE, yaw out, pitch out, eye out (3 FLOAT-LONG), active out (PIC 9): the camera of the sleeping player
*>   CONTROLS-WAKE USING CLIENT-STATE: Player Command STOP_SLEEPING when the Sneak key goes down while the player is asleep

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-BED-FACING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-HAS-PART            BINARY-LONG.
 01 WS-FACING              PIC X(32).
 01 WS-PROPS.
    05 WS-P-COUNT          BINARY-LONG.
    05 WS-P-ENTRY OCCURS 16 TIMES.
       10 WS-P-NAME        PIC X(24).
       10 WS-P-VALUE       PIC X(32).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FOUND                PIC 9.
 01 L-STEP-X               BINARY-LONG.
 01 L-STEP-Z               BINARY-LONG.
 01 L-YAW-A                FLOAT-LONG.
 01 L-CAM-YAW              FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-FOUND L-STEP-X L-STEP-Z L-YAW-A L-CAM-YAW.
     MOVE 0 TO L-FOUND L-STEP-X L-STEP-Z
     MOVE 0 TO L-YAW-A L-CAM-YAW
     MOVE 0 TO WS-HAS-PART
     MOVE SPACES TO WS-FACING
     CALL "WORLD-CELL" USING CLIENT-STATE L-X L-Y L-Z WS-STATE WS-SKY WS-BLOCK
     CALL "CONTENT-STATE-PROPS" USING WS-STATE WS-PROPS WS-STATUS
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-P-COUNT
         IF WS-P-NAME(WS-P) = "part"
             MOVE 1 TO WS-HAS-PART
         END-IF
         IF WS-P-NAME(WS-P) = "facing"
             MOVE WS-P-VALUE(WS-P) TO WS-FACING
         END-IF
     END-PERFORM
*>   A bed block has both the property part and a facing.
     IF WS-HAS-PART = 1
         EVALUATE WS-FACING
             WHEN "south"
                 MOVE 1 TO L-FOUND L-STEP-Z
                 MOVE 90 TO L-YAW-A
                 MOVE 180 TO L-CAM-YAW
             WHEN "west"
                 MOVE 1 TO L-FOUND
                 MOVE -1 TO L-STEP-X
                 MOVE 0 TO L-YAW-A
                 MOVE -90 TO L-CAM-YAW
             WHEN "north"
                 MOVE 1 TO L-FOUND
                 MOVE -1 TO L-STEP-Z
                 MOVE 270 TO L-YAW-A
                 MOVE 0 TO L-CAM-YAW
             WHEN "east"
                 MOVE 1 TO L-FOUND L-STEP-X
                 MOVE 180 TO L-YAW-A
                 MOVE 90 TO L-CAM-YAW
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM SLEEP-BED-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-DATA-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POSE-ENTRY          BINARY-LONG VALUE 6.
 01 WS-POS-ENTRY           BINARY-LONG VALUE 14.
 01 WS-POSE-SERIALIZER     BINARY-LONG VALUE 20.
 01 WS-POS-SERIALIZER      BINARY-LONG VALUE 11.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-INT                  BINARY-LONG.
 01 L-PRESENT              PIC 9.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-ROW L-INDEX L-SERIALIZER L-INT L-PRESENT L-X L-Y L-Z.
*>   The own entity: asleep while its pose is SLEEPING (53 section 1, id 2); the bed cell comes with entry 14.
     IF L-ID = PL-ENTITY-ID AND L-INDEX = WS-POSE-ENTRY AND L-SERIALIZER = WS-POSE-SERIALIZER
         MOVE 0 TO PL-SLEEP
         IF L-INT = 2
             MOVE 1 TO PL-SLEEP
         END-IF
     END-IF
     IF L-ID = PL-ENTITY-ID AND L-INDEX = WS-POS-ENTRY AND L-SERIALIZER = WS-POS-SERIALIZER AND L-PRESENT = 1
         MOVE L-X TO PL-BED-X
         MOVE L-Y TO PL-BED-Y
         MOVE L-Z TO PL-BED-Z
     END-IF
     IF L-ROW > 0 AND L-INDEX = WS-POS-ENTRY AND L-SERIALIZER = WS-POS-SERIALIZER
         MOVE L-PRESENT TO EN-BED-SET(L-ROW)
         MOVE L-X TO EN-BED-X(L-ROW)
         MOVE L-Y TO EN-BED-Y(L-ROW)
         MOVE L-Z TO EN-BED-Z(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM SLEEP-DATA-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SLEEP-SEQUENCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-FOUND               PIC 9.
 01 WS-STEP-X              BINARY-LONG.
 01 WS-STEP-Z              BINARY-LONG.
 01 WS-YAW-A               FLOAT-LONG.
 01 WS-CAM-YAW             FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-OPS.
    05 L-OP                FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-OPS.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
         MOVE 0 TO WS-IV(WS-K)
     END-PERFORM
     CALL "SLEEP-BED-FACING" USING CLIENT-STATE EN-BED-X(L-ROW) EN-BED-Y(L-ROW) EN-BED-Z(L-ROW) WS-FOUND WS-STEP-X WS-STEP-Z
         WS-YAW-A WS-CAM-YAW
     MOVE 1 TO WS-IV(1)
     MOVE WS-FOUND TO WS-IV(2)
     MOVE WS-STEP-X TO WS-IV(3)
     MOVE WS-STEP-Z TO WS-IV(4)
     MOVE WS-YAW-A TO WS-IV(5)
*>   The standing eye height of the entity (34-2 5.7, 34-3 section 1): the zombie family 1.74, the piglins 1.79, the villagers, witch and players 1.62.
     MOVE 1.62 TO WS-IV(6)
     EVALUATE EN-KEY(L-ROW)
         WHEN "zombie"
         WHEN "husk"
         WHEN "drowned"
         WHEN "zombie_villager"
         WHEN "skeleton"
         WHEN "stray"
         WHEN "bogged"
         WHEN "parched"
             MOVE 1.74 TO WS-IV(6)
         WHEN "piglin"
         WHEN "piglin_brute"
         WHEN "zombified_piglin"
             MOVE 1.79 TO WS-IV(6)
     END-EVALUATE
     MOVE 1 TO WS-IV(7)
     MOVE EN-YAW(L-ROW) TO WS-IV(8)
     MOVE 90 TO WS-IV(10)
     MOVE EN-AGE(L-ROW) TO WS-IV(13)
     CALL "EM6-POSE-CHAIN" USING WS-I WS-O
     MOVE WS-OV(1) TO L-OP(1)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 63
         MOVE WS-OV(WS-K + 1) TO L-OP(WS-K + 1)
     END-PERFORM
*>   The renderer's code for a rotation about Z is 7 (EM6-POSE-CHAIN says 4; any other unknown code turns about Y).
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-OV(1)
         COMPUTE WS-A = WS-K * 4 - 2
         IF L-OP(WS-A) = 4
             MOVE 7 TO L-OP(WS-A)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-SLEEP-SEQUENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-CAMERA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOUND               PIC 9.
 01 WS-STEP-X              BINARY-LONG.
 01 WS-STEP-Z              BINARY-LONG.
 01 WS-YAW-A               FLOAT-LONG.
 01 WS-CAM-YAW             FLOAT-LONG.
 01 WS-RAD                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-ACTIVE               PIC 9.
 PROCEDURE DIVISION USING CLIENT-STATE L-YAW L-PITCH L-EYE-TABLE L-ACTIVE.
     MOVE 0 TO L-ACTIVE
     IF PL-SLEEP = 1
         CALL "SLEEP-BED-FACING" USING CLIENT-STATE PL-BED-X PL-BED-Y PL-BED-Z WS-FOUND WS-STEP-X WS-STEP-Z WS-YAW-A WS-CAM-YAW
         IF WS-FOUND = 1
*>           12 section 7.2 step 6: at the bed, yaw = the bed direction's yaw - 180, pitch 0, the eye 0.2 above the feet on the mattress (53 SLEEPING eye height), moved 0.15 blocks along the view.
             MOVE 1 TO L-ACTIVE
             MOVE WS-CAM-YAW TO L-YAW
             MOVE 0 TO L-PITCH
             COMPUTE WS-RAD = WS-CAM-YAW * FUNCTION PI / 180
             COMPUTE L-EYE(1) = PL-BED-X + 0.5 - FUNCTION SIN(WS-RAD) * 0.15
             COMPUTE L-EYE(2) = PL-BED-Y + 0.5625 + 0.2
             COMPUTE L-EYE(3) = PL-BED-Z + 0.5 + FUNCTION COS(WS-RAD) * 0.15
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SLEEP-CAMERA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-WAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-K1                  BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE KB-CODE(KB-SNEAK) TO WS-K1
     IF PL-SLEEP = 1 AND SM-SCREEN = SCR-WORLD AND IN-KEY-PRESSED(WS-K1 + 1) = 1
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         CALL "PB-RESET" USING PB-BUFFER
         CALL "CLP-PLAYER-COMMAND" USING PB-BUFFER PL-ENTITY-ID WS-ACTION
         CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-WAKE.
