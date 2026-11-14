*> The End rules of docs/protocol/39-portals.md section 7 (T1757, T1758), the part that portal-39.cob (nether portals) does not hold: the end portal frame block and its eyes,
*> the pattern search that opens the end portal, the entry gate (credits), the credits and respawn actions, the gateway transition and the block entity's faces. Facings are
*> 1 north, 2 east, 3 south, 4 west; directions of PORTAL-END-FACE are 1 down, 2 up, 3 north, 4 south, 5 west, 6 east. Placing an eye is done in a world (WORLD-GET-BLOCK).
*>
*> Entry points:
*>   PORTAL-FRAME-FACING USING placer facing, frame facing out (7.1: opposite of the placer's horizontal direction).   PORTAL-FRAME-COMPARATOR USING eye, output out (15 or 0).
*>   PORTAL-FRAME-INFO USING state, is frame out, eye out, facing out (0 for a state that is no frame).   PORTAL-FRAME-STATE USING eye, facing, state out.
*>   PORTAL-EYE-PLACE USING dim, x, y, z, result out (0 pass, 1 eye placed, 2 the portal opened), corner x, y, z out (the inner minimum corner), destroyed out (blocks replaced by the
*>     portal that held something: the caller drops their items; the caller also removes one eye of ender, sends Level Event 1503 and, when opened, the global 1038 at corner + (1, 0, 1)).
*>   PORTAL-END-INSIDE USING in the End, is player, seen credits, result out (1 credits, 2 the entity is inside the portal: 7.3).
*>   PORTAL-CREDITS USING won game (in/out), seen credits (in/out), send win game out (7.5 showEndCredits).   PORTAL-RESPAWN-ACTION USING won game, health, result out (1 credits respawn, 2 death respawn, 0 none).
*>   PORTAL-GATEWAY-DEST USING is thrown ender pearl, relative delta out, relative rotation out (7.6).   PORTAL-GATEWAY-COOLDOWN USING kind (1 player, 2 projectile, 3 other, 4 the gateway), ticks out.
*>   PORTAL-END-FACE USING direction, drawn out (7.5a).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FRAME-FACING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-PLACER               BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLACER L-FACING.
     COMPUTE L-FACING = FUNCTION MOD(L-PLACER + 1, 4) + 1
     GOBACK.
 END PROGRAM PORTAL-FRAME-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FRAME-COMPARATOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-EYE                  BINARY-LONG.
 01 L-OUTPUT               BINARY-LONG.
 PROCEDURE DIVISION USING L-EYE L-OUTPUT.
     MOVE 0 TO L-OUTPUT
     IF L-EYE = 1
         MOVE 15 TO L-OUTPUT
     END-IF
     GOBACK.
 END PROGRAM PORTAL-FRAME-COMPARATOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FRAME-INFO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-TEXT                PIC X(160).
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-IS                   BINARY-LONG.
 01 L-EYE                  BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-IS L-EYE L-FACING.
     MOVE 0 TO L-IS L-EYE L-FACING
     IF L-STATE > 0
         MOVE "end_portal_frame" TO WS-KEY
         CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
         IF CB-S-BLOCK(L-STATE + 1) = WS-ID
             MOVE 1 TO L-IS
             CALL "BLOCKS-STATE-PROPS" USING L-STATE WS-TEXT
             MOVE 0 TO WS-N
             INSPECT WS-TEXT TALLYING WS-N FOR ALL "eye=true"
             IF WS-N > 0
                 MOVE 1 TO L-EYE
             END-IF
             MOVE 0 TO WS-N
             INSPECT WS-TEXT TALLYING WS-N FOR ALL "facing=north"
             IF WS-N > 0
                 MOVE 1 TO L-FACING
             END-IF
             MOVE 0 TO WS-N
             INSPECT WS-TEXT TALLYING WS-N FOR ALL "facing=east"
             IF WS-N > 0
                 MOVE 2 TO L-FACING
             END-IF
             MOVE 0 TO WS-N
             INSPECT WS-TEXT TALLYING WS-N FOR ALL "facing=south"
             IF WS-N > 0
                 MOVE 3 TO L-FACING
             END-IF
             MOVE 0 TO WS-N
             INSPECT WS-TEXT TALLYING WS-N FOR ALL "facing=west"
             IF WS-N > 0
                 MOVE 4 TO L-FACING
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PORTAL-FRAME-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FRAME-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-NAME                PIC X(5).
 LINKAGE SECTION.
 01 L-EYE                  BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-EYE L-FACING L-STATE.
     MOVE "end_portal_frame" TO WS-KEY
     MOVE SPACES TO WS-PAIRS WS-NAME
     EVALUATE L-FACING
         WHEN 1
             MOVE "north" TO WS-NAME
         WHEN 2
             MOVE "east" TO WS-NAME
         WHEN 3
             MOVE "south" TO WS-NAME
         WHEN OTHER
             MOVE "west" TO WS-NAME
     END-EVALUATE
     IF L-EYE = 1
         STRING "eye=true,facing=" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-PAIRS
     ELSE
         STRING "eye=false,facing=" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-PAIRS
     END-IF
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS L-STATE
     GOBACK.
 END PROGRAM PORTAL-FRAME-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-RING-TEST.
*> USING dim, candidate x, y, z (the front top left cell: the ring's maximum x and z corner), ok out: the 12 frames of the pattern of 7.2: cell (i, j) is at
*> (x - i, y, z - j); j 0 faces north (i 1 to 3), j 4 south, i 0 west, i 4 east (j 1 to 3), every one with its eye.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-IS                  BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 1 TO L-OK
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4 OR L-OK = 0
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 4 OR L-OK = 0
             MOVE 0 TO WS-WANT
             EVALUATE TRUE
                 WHEN WS-J = 0 AND WS-I >= 1 AND WS-I <= 3
                     MOVE 1 TO WS-WANT
                 WHEN WS-J = 4 AND WS-I >= 1 AND WS-I <= 3
                     MOVE 3 TO WS-WANT
                 WHEN WS-I = 0 AND WS-J >= 1 AND WS-J <= 3
                     MOVE 4 TO WS-WANT
                 WHEN WS-I = 4 AND WS-J >= 1 AND WS-J <= 3
                     MOVE 2 TO WS-WANT
             END-EVALUATE
             IF WS-WANT > 0
                 COMPUTE WS-X = L-X - WS-I
                 COMPUTE WS-Z = L-Z - WS-J
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X L-Y WS-Z WS-STATE
                 CALL "PORTAL-FRAME-INFO" USING WS-STATE WS-IS WS-EYE WS-FACING
                 IF WS-IS = 0 OR WS-EYE = 0 OR WS-FACING NOT = WS-WANT
                     MOVE 0 TO L-OK
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-RING-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-EYE-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-IS                  BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-NONE                PIC X(160) VALUE SPACES.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-CORNER-X             BINARY-LONG.
 01 L-CORNER-Y             BINARY-LONG.
 01 L-CORNER-Z             BINARY-LONG.
 01 L-DESTROYED            BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-RESULT L-CORNER-X L-CORNER-Y L-CORNER-Z L-DESTROYED.
     MOVE 0 TO L-RESULT L-DESTROYED
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "PORTAL-FRAME-INFO" USING WS-STATE WS-IS WS-EYE WS-FACING
     IF WS-IS = 0 OR WS-EYE = 1
         GOBACK
     END-IF
     MOVE 1 TO L-RESULT
     CALL "PORTAL-FRAME-STATE" USING WS-ONE WS-FACING WS-NEW
     CALL "WORLD-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW
*>   the candidates are the cells from the clicked frame to + (4, 4, 4); the first ring that matches wins
     PERFORM VARYING WS-CX FROM L-X BY 1 UNTIL WS-CX > L-X + 4 OR L-RESULT = 2
         PERFORM VARYING WS-CY FROM L-Y BY 1 UNTIL WS-CY > L-Y + 4 OR L-RESULT = 2
             PERFORM VARYING WS-CZ FROM L-Z BY 1 UNTIL WS-CZ > L-Z + 4 OR L-RESULT = 2
                 CALL "PORTAL-RING-TEST" USING L-DIM WS-CX WS-CY WS-CZ WS-OK
                 IF WS-OK = 1
                     MOVE 2 TO L-RESULT
                     COMPUTE L-CORNER-X = WS-CX - 3
                     MOVE WS-CY TO L-CORNER-Y
                     COMPUTE L-CORNER-Z = WS-CZ - 3
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF L-RESULT = 2
         MOVE "end_portal" TO WS-KEY
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-NONE WS-PORTAL
         PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > 2
             PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > 2
                 COMPUTE WS-X = L-CORNER-X + WS-A
                 COMPUTE WS-Z = L-CORNER-Z + WS-B
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X L-CORNER-Y WS-Z WS-OLD
                 IF WS-OLD NOT = 0
                     ADD 1 TO L-DESTROYED
                 END-IF
                 CALL "WORLD-SET-BLOCK" USING L-DIM WS-X L-CORNER-Y WS-Z WS-PORTAL
             END-PERFORM
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PORTAL-EYE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-END-INSIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-IN-END               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-SEEN                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-END L-PLAYER L-SEEN L-RESULT.
     MOVE 2 TO L-RESULT
     IF L-IN-END = 1 AND L-PLAYER = 1 AND L-SEEN = 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM PORTAL-END-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-CREDITS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-WON                  BINARY-LONG.
 01 L-SEEN                 BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WON L-SEEN L-SEND.
     MOVE 0 TO L-SEND
     IF L-WON = 0
         MOVE 1 TO L-WON L-SEEN L-SEND
     END-IF
     GOBACK.
 END PROGRAM PORTAL-CREDITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-RESPAWN-ACTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-WON                  BINARY-LONG.
 01 L-HEALTH               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-WON L-HEALTH L-RESULT.
     EVALUATE TRUE
         WHEN L-WON = 1
             MOVE 1 TO L-RESULT
         WHEN L-HEALTH <= 0
             MOVE 2 TO L-RESULT
         WHEN OTHER
             MOVE 0 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM PORTAL-RESPAWN-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-GATEWAY-DEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-PEARL                BINARY-LONG.
 01 L-DELTA                BINARY-LONG.
 01 L-ROTATION             BINARY-LONG.
 PROCEDURE DIVISION USING L-PEARL L-DELTA L-ROTATION.
     MOVE 1 TO L-DELTA L-ROTATION
     IF L-PEARL = 1
         MOVE 0 TO L-DELTA L-ROTATION
     END-IF
     GOBACK.
 END PROGRAM PORTAL-GATEWAY-DEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-GATEWAY-COOLDOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TICKS.
     EVALUATE L-KIND
         WHEN 1
             MOVE 10 TO L-TICKS
         WHEN 2
             MOVE 2 TO L-TICKS
         WHEN 4
             MOVE 40 TO L-TICKS
         WHEN OTHER
             MOVE 300 TO L-TICKS
     END-EVALUATE
     GOBACK.
 END PROGRAM PORTAL-GATEWAY-COOLDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-END-FACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRECTION L-DRAWN.
     MOVE 0 TO L-DRAWN
     IF L-DIRECTION = 1 OR L-DIRECTION = 2
         MOVE 1 TO L-DRAWN
     END-IF
     GOBACK.
 END PROGRAM PORTAL-END-FACE.
