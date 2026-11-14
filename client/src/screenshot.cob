*> The screenshot key (vanilla key.screenshot, default F2; docs 13 §7.3). SHOT-INPUT runs every frame: the key of the
*> screenshot binding pressed (a key repeat is ignored), or the frame CL-SHOT-AT reached (--screenshot-after-frames N, or
*> CC_SCREENSHOT_AT_FRAME; once), asks the shim (cc_vk_screenshot) to save the frame the next SUBMIT-FRAME presents as
*> <game directory>/screenshots/YYYY-MM-DD_HH.MM.SS.png (_1, _2 ... after a name that exists). The docs name no exclusion,
*> so the whole frame is saved as displayed: the world, the HUD and any open screen, and the F3 overlay if it is on.
*> SHOT-POLL runs every frame with cc_vk_screenshot_result: once the request is served it adds the chat message
*> screenshot.success ("Saved screenshot as <file name>") or screenshot.failure to the chat, writes a log line for
*> automated runs, and ends the run after an automatic screenshot when --screenshot-then-exit is given.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHOT-INPUT.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 COPY CLCONST.
 01 WS-KEY                 BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-AUTO                BINARY-LONG.
 01 WS-NOW                 PIC X(21).
 01 WS-PATH                PIC X(1200).
 01 WS-STAMP              PIC X(19).
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-GO WS-AUTO
     MOVE KB-CODE(KB-SCREENSHOT) TO WS-KEY
     IF WS-KEY > 0 AND IN-KEY-PRESSED(WS-KEY + 1) = 1 AND IN-KEY-REPEAT(WS-KEY + 1) = 0
         MOVE 1 TO WS-GO
     END-IF
     IF CL-SHOT-AT > 0 AND CL-FRAMES >= CL-SHOT-AT
         MOVE 1 TO WS-GO WS-AUTO
         MOVE 0 TO CL-SHOT-AT
     END-IF
     IF WS-GO = 1 AND CL-SHOT-PENDING = 0
         MOVE FUNCTION CURRENT-DATE TO WS-NOW
         MOVE SPACES TO WS-STAMP
         STRING WS-NOW(1:4) "-" WS-NOW(5:2) "-" WS-NOW(7:2) "_" WS-NOW(9:2) "." WS-NOW(11:2) "." WS-NOW(13:2)
             DELIMITED BY SIZE INTO WS-STAMP
         CALL "SHOT-NAME" USING CLIENT-STATE WS-STAMP WS-PATH
         MOVE 0 TO RETURN-CODE
         CALL STATIC "cc_vk_screenshot" USING BY REFERENCE WS-PATH RETURNING WS-RC
         IF WS-RC = 0
             MOVE 1 TO CL-SHOT-PENDING
             MOVE WS-AUTO TO CL-SHOT-AUTO
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHOT-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHOT-NAME.
*> USING CLIENT-STATE, stamp (PIC X(19), YYYY-MM-DD_HH.MM.SS), path out (PIC X(1200), z-string): creates the screenshots
*> directory, and sets CL-SHOT-NAME to the stamp and ".png", or to the stamp, "_1" (then "_2" and so on) and ".png" for the
*> first name that does not exist yet, and the path of that file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 PIC X(1100).
 01 WS-INFO                PIC X(16).
 01 WS-N                   BINARY-LONG.
 01 WS-SUFFIX              PIC Z(3)9.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-STAMP                PIC X(19).
 01 L-PATH                 PIC X(1200).
 PROCEDURE DIVISION USING CLIENT-STATE L-STAMP L-PATH.
     MOVE SPACES TO WS-DIR
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/screenshots" DELIMITED BY SIZE INTO WS-DIR
     CALL "CBL_CREATE_DIR" USING WS-DIR
     MOVE 0 TO WS-N WS-DONE
     PERFORM UNTIL WS-DONE = 1
         MOVE SPACES TO CL-SHOT-NAME
         IF WS-N = 0
             STRING L-STAMP ".png" DELIMITED BY SIZE INTO CL-SHOT-NAME
             MOVE 23 TO CL-SHOT-NAME-LENGTH
         ELSE
             MOVE WS-N TO WS-SUFFIX
             STRING L-STAMP "_" FUNCTION TRIM(WS-SUFFIX) ".png" DELIMITED BY SIZE INTO CL-SHOT-NAME
             COMPUTE CL-SHOT-NAME-LENGTH = 24 + FUNCTION LENGTH(FUNCTION TRIM(WS-SUFFIX))
         END-IF
         MOVE SPACES TO L-PATH
         STRING FUNCTION TRIM(WS-DIR) "/" CL-SHOT-NAME(1:CL-SHOT-NAME-LENGTH) X"00" DELIMITED BY SIZE INTO L-PATH
         CALL "CBL_CHECK_FILE_EXIST" USING L-PATH WS-INFO
*>       RETURN-CODE 0: the name exists, the next suffix is tried.
         IF RETURN-CODE = 0
             ADD 1 TO WS-N
         ELSE
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM SHOT-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHOT-POLL.
*> USING CLIENT-STATE, the result of cc_vk_screenshot_result (CC-AGAIN while the frame has not been presented).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 COPY CLARGS.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-RC                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-RC.
     IF CL-SHOT-PENDING = 1 AND L-RC NOT = CC-AGAIN
         MOVE 0 TO CL-SHOT-PENDING
         MOVE SPACES TO WS-KEY
         IF L-RC = 0
             MOVE "screenshot.success" TO WS-KEY
             MOVE 18 TO WS-KEY-LENGTH
         ELSE
             MOVE "screenshot.failure" TO WS-KEY
             MOVE 18 TO WS-KEY-LENGTH
         END-IF
         MOVE 1 TO LA-COUNT
         MOVE CL-SHOT-NAME-LENGTH TO LA-LENGTH(1)
         MOVE CL-SHOT-NAME TO LA-TEXT(1)
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
*>       A language without the key shows the key itself: the English text stands in.
         IF WS-TEXT(1:WS-LENGTH) = WS-KEY(1:WS-KEY-LENGTH)
             MOVE SPACES TO WS-TEXT
             IF L-RC = 0
                 STRING "Saved screenshot as " CL-SHOT-NAME(1:CL-SHOT-NAME-LENGTH) DELIMITED BY SIZE INTO WS-TEXT
                 COMPUTE WS-LENGTH = 20 + CL-SHOT-NAME-LENGTH
             ELSE
                 STRING "Couldn't save screenshot: " CL-SHOT-NAME(1:CL-SHOT-NAME-LENGTH) DELIMITED BY SIZE INTO WS-TEXT
                 COMPUTE WS-LENGTH = 26 + CL-SHOT-NAME-LENGTH
             END-IF
         END-IF
         CALL "CHAT-MESSAGE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH
         DISPLAY "screenshot: " WS-TEXT(1:WS-LENGTH)
         IF CL-SHOT-AUTO = 1 AND CL-SHOT-EXIT = 1
             MOVE 1 TO CL-QUIT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHOT-POLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STARTUP-COMMANDS.
*> USING CLIENT-STATE: from the frame CL-CMD-AT (CC_COMMANDS_AT_FRAME) on the world screen runs the console commands of CL-CMD-TEXT (CC_COMMANDS, up to 1024 bytes, a command cut at 256: commands without
*> the leading slash, separated by `;`, leading spaces dropped) once through the hosted world's console (CORE-CONSOLE), then clears CL-CMD-AT. For
*> screenshot runs that need mobs, the time of day or the game mode without typing; nothing happens when CL-CMD-AT is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-POS                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LINE                PIC X(257).
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF CL-CMD-AT = 0 OR CL-FRAMES < CL-CMD-AT OR SM-SCREEN NOT = SCR-WORLD
         GOBACK
     END-IF
     MOVE 0 TO CL-CMD-AT
     MOVE 1 TO WS-START
     PERFORM VARYING WS-POS FROM 1 BY 1 UNTIL WS-POS > 1025
         IF WS-POS = 1025 OR CL-CMD-TEXT(WS-POS:1) = ";"
             PERFORM UNTIL WS-START >= WS-POS OR CL-CMD-TEXT(WS-START:1) NOT = SPACE
                 ADD 1 TO WS-START
             END-PERFORM
             COMPUTE WS-LENGTH = WS-POS - WS-START
             IF WS-LENGTH > 256
                 MOVE 256 TO WS-LENGTH
             END-IF
             PERFORM UNTIL WS-LENGTH = 0 OR CL-CMD-TEXT(WS-START + WS-LENGTH - 1:1) NOT = SPACE
                 SUBTRACT 1 FROM WS-LENGTH
             END-PERFORM
             MOVE LOW-VALUES TO WS-LINE
             IF WS-LENGTH > 0
                 MOVE CL-CMD-TEXT(WS-START:WS-LENGTH) TO WS-LINE(1:WS-LENGTH)
                 CALL "CORE-CONSOLE" USING WS-LINE
             END-IF
             COMPUTE WS-START = WS-POS + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STARTUP-COMMANDS.
