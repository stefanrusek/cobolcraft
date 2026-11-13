*> Command line of the client (contracts/client-surface.md §1; research R14; wire-profile.md §1):
*> ARGS-PARSE takes --name <name> (required: 1 to 16 characters of A-Z a-z 0-9 _) and
*> --gamedir <path> (default $HOME/.cobolcraft) and --generated-dir <path> (the generated packs of the
*> extraction tool, 22 section 5.1; default <game directory>/generated), --world <save folder name> (or the
*> environment variable CC_WORLD; the option wins): the single-player save opened right after start-up
*> (WORLD-OPEN-ARG, world-list.cob), --camera <x,y,z,yaw,pitch> (or CC_CAMERA; ARGS-CAMERA, camera.cob): the view of every frame is that eye position
*> and look direction, --screenshot-after-frames <N> (one screenshot at frame N,
*> screenshot.cob) and --screenshot-then-exit (the run ends once it is saved). Other words are ignored. A missing or invalid name
*> is fatal: "FATAL arguments: ...", exit status 1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARGS-PARSE.
*> USING CLIENT-STATE, CL-ARGS (the words of the command line): sets CL-NAME, CL-GAME-DIR and
*> CL-GENERATED-DIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-HOME                PIC X(1024).
 01 WS-WHAT                PIC X(128).
 01 WS-CHAR                PIC X.
 01 WS-CAMERA              PIC X(128).
 01 WS-ENV-WORLD           PIC X(80).
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLARGS.
 PROCEDURE DIVISION USING CLIENT-STATE CL-ARGS.
     MOVE 0 TO CL-NAME-LENGTH
     MOVE SPACES TO CL-NAME
     ACCEPT WS-HOME FROM ENVIRONMENT "HOME"
     MOVE SPACES TO CL-GAME-DIR
     STRING FUNCTION TRIM(WS-HOME) "/.cobolcraft" DELIMITED BY SIZE INTO CL-GAME-DIR
     COMPUTE CL-GAME-DIR-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-HOME)) + 12
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE 0 TO CL-GENERATED-DIR-LENGTH
     MOVE -1 TO WS-BAD
     MOVE SPACES TO CL-WORLD WS-ENV-WORLD
     MOVE 0 TO CL-WORLD-LENGTH
     ACCEPT WS-ENV-WORLD FROM ENVIRONMENT "CC_WORLD"
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ENV-WORLD TRAILING)) TO CL-WORLD-LENGTH
     IF WS-ENV-WORLD = SPACES
         MOVE 0 TO CL-WORLD-LENGTH
     ELSE
         MOVE WS-ENV-WORLD TO CL-WORLD
     END-IF
*>   The same two settings from the environment (CC_SCREENSHOT_AT_FRAME = N, CC_SCREENSHOT_THEN_EXIT = 1); the command line wins.
     MOVE SPACES TO WS-HOME
     ACCEPT WS-HOME FROM ENVIRONMENT "CC_SCREENSHOT_AT_FRAME"
     IF WS-HOME NOT = SPACES
         COMPUTE CL-SHOT-AT = FUNCTION NUMVAL(WS-HOME)
     END-IF
     MOVE SPACES TO WS-HOME
     ACCEPT WS-HOME FROM ENVIRONMENT "CC_SCREENSHOT_THEN_EXIT"
     IF WS-HOME(1:1) = "1"
         MOVE 1 TO CL-SHOT-EXIT
     END-IF
     MOVE SPACES TO WS-CAMERA
     ACCEPT WS-CAMERA FROM ENVIRONMENT "CC_CAMERA"
     CALL "ARGS-CAMERA" USING CLIENT-STATE WS-CAMERA
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AR-COUNT
         EVALUATE TRUE
             WHEN AR-TEXT(WS-I) = "--camera"
                 IF WS-I < AR-COUNT
                     ADD 1 TO WS-I
                     MOVE SPACES TO WS-CAMERA
                     MOVE AR-TEXT(WS-I)(1:AR-LENGTH(WS-I)) TO WS-CAMERA
                     CALL "ARGS-CAMERA" USING CLIENT-STATE WS-CAMERA
                 END-IF
             WHEN AR-TEXT(WS-I) = "--name"
                 ADD 1 TO WS-I
                 MOVE 0 TO WS-BAD
                 IF AR-LENGTH(WS-I) < 1 OR AR-LENGTH(WS-I) > 16
                     MOVE 1 TO WS-BAD
                 END-IF
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > AR-LENGTH(WS-I) OR WS-K > 16
                     MOVE AR-TEXT(WS-I)(WS-K:1) TO WS-CHAR
                     IF NOT (WS-CHAR IS ALPHABETIC-UPPER OR WS-CHAR IS ALPHABETIC-LOWER
                             OR WS-CHAR IS NUMERIC OR WS-CHAR = "_") OR WS-CHAR = SPACE
                         MOVE 1 TO WS-BAD
                     END-IF
                 END-PERFORM
                 MOVE AR-TEXT(WS-I)(1:16) TO CL-NAME
                 MOVE FUNCTION MIN(AR-LENGTH(WS-I), 16) TO CL-NAME-LENGTH
             WHEN AR-TEXT(WS-I) = "--gamedir"
                 ADD 1 TO WS-I
                 MOVE AR-TEXT(WS-I) TO CL-GAME-DIR
                 MOVE AR-LENGTH(WS-I) TO CL-GAME-DIR-LENGTH
             WHEN AR-TEXT(WS-I) = "--world"
                 ADD 1 TO WS-I
                 MOVE SPACES TO CL-WORLD
                 MOVE AR-TEXT(WS-I)(1:80) TO CL-WORLD
                 MOVE FUNCTION MIN(AR-LENGTH(WS-I), 80) TO CL-WORLD-LENGTH
             WHEN AR-TEXT(WS-I) = "--screenshot-after-frames"
                 ADD 1 TO WS-I
                 COMPUTE CL-SHOT-AT = FUNCTION NUMVAL(AR-TEXT(WS-I)(1:AR-LENGTH(WS-I)))
             WHEN AR-TEXT(WS-I) = "--screenshot-then-exit"
                 MOVE 1 TO CL-SHOT-EXIT
             WHEN AR-TEXT(WS-I) = "--generated-dir"
                 ADD 1 TO WS-I
                 MOVE AR-TEXT(WS-I) TO CL-GENERATED-DIR
                 MOVE AR-LENGTH(WS-I) TO CL-GENERATED-DIR-LENGTH
         END-EVALUATE
     END-PERFORM
     IF CL-GENERATED-DIR-LENGTH = 0
         STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/generated" DELIMITED BY SIZE
             INTO CL-GENERATED-DIR
         COMPUTE CL-GENERATED-DIR-LENGTH = CL-GAME-DIR-LENGTH + 10
     END-IF
     EVALUATE WS-BAD
         WHEN -1
             MOVE LOW-VALUES TO WS-WHAT
             STRING "arguments: --name <name> is required" DELIMITED BY SIZE INTO WS-WHAT
             CALL STATIC "cc_fatal" USING BY REFERENCE WS-WHAT
         WHEN 1
             MOVE LOW-VALUES TO WS-WHAT
             STRING "arguments: --name must be 1 to 16 characters of A-Z a-z 0-9 _"
                 DELIMITED BY SIZE INTO WS-WHAT
             CALL STATIC "cc_fatal" USING BY REFERENCE WS-WHAT
     END-EVALUATE
     GOBACK.
 END PROGRAM ARGS-PARSE.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARGS-CAMERA.
*> USING CLIENT-STATE, text (PIC X(128)): "x,y,z,yaw,pitch", five numbers separated by commas (the eye position in blocks, the look yaw and pitch in
*> degrees), sets CL-CAM-SET and CL-CAM-X to CL-CAM-PITCH (CAMERA-PLACE then shows exactly that view). Fewer than five fields, a sixth field or a
*> field that is no number leaves the view alone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FIELDS.
    05 WS-FIELD            PIC X(32) OCCURS 6 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NUMBERS.
    05 WS-NUMBER           FLOAT-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(128).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE SPACES TO WS-FIELDS
     MOVE 0 TO WS-COUNT WS-BAD
     UNSTRING FUNCTION TRIM(L-TEXT) DELIMITED BY "," INTO WS-FIELD(1) WS-FIELD(2) WS-FIELD(3) WS-FIELD(4)
         WS-FIELD(5) WS-FIELD(6) TALLYING IN WS-COUNT
     IF WS-COUNT NOT = 5
         MOVE 1 TO WS-BAD
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR WS-BAD = 1
         IF FUNCTION TEST-NUMVAL(WS-FIELD(WS-I)) NOT = 0
             MOVE 1 TO WS-BAD
         ELSE
             COMPUTE WS-NUMBER(WS-I) = FUNCTION NUMVAL(WS-FIELD(WS-I))
         END-IF
     END-PERFORM
     IF WS-BAD = 0
         MOVE 1 TO CL-CAM-SET
         MOVE WS-NUMBER(1) TO CL-CAM-X
         MOVE WS-NUMBER(2) TO CL-CAM-Y
         MOVE WS-NUMBER(3) TO CL-CAM-Z
         MOVE WS-NUMBER(4) TO CL-CAM-YAW
         MOVE WS-NUMBER(5) TO CL-CAM-PITCH
     END-IF
     GOBACK.
 END PROGRAM ARGS-CAMERA.
