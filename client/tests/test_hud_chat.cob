*> Implementation test of docs/protocol/57-client-closures-5 section 2 (task T47400): the chat of the HUD. Word wrapping (a continuation line starts with a space that counts in
*> the width), the window of the closed chat (10 lines at the defaults, each line's background from x 0 to 332, the 2 pixel tag bar and the text at x 4, bottom line ending at GUI
*> height - 40), the fade (age 180: 1.0, 185: 0.5625, 190: 0.25 with background alpha 31, 195: 0.0625, 200: not drawn), the tag colours, the chat options (opacity, background
*> opacity, line spacing, unfocused height, width), the visibility option, the delay queue, and the four chat packets with their validator, trust tags and index check. The
*> expected numbers are those of the document's worked values; the lines of wrapped text are counted from the glyph advances the font gives.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HUD-CHAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-SERVER              BINARY-LONG.
 01 WS-NAME                PIC X(200).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT256             PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-GW                  BINARY-LONG VALUE 427.
 01 WS-GH                  BINARY-LONG VALUE 240.
 01 WS-OPT-NAME            PIC X(40).
 01 WS-OPT-VALUE           PIC X(4096).
 01 WS-OPT-LENGTH          BINARY-LONG.
 01 WS-OPT-OK              BINARY-LONG.
 01 WS-LINES.
    05 WS-LN OCCURS 32 TIMES.
       10 WS-LN-START      BINARY-LONG.
       10 WS-LN-LENGTH     BINARY-LONG.
       10 WS-LN-PREFIX     BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-W1                  BINARY-LONG.
 01 WS-M-W                 BINARY-LONG.
 01 WS-S-W                 BINARY-LONG.
 01 WS-LABELS              BINARY-LONG.
 01 WS-OVERLAYS            BINARY-LONG.
 01 WS-LAST-LABEL          BINARY-LONG.
 01 WS-LAST-BG             BINARY-LONG.
 01 WS-LAST-BAR            BINARY-LONG.
 01 WS-UUID                PIC X(16) VALUE "0123456789abcdef".
 01 WS-CAP                 BINARY-LONG VALUE 2048.
 01 WS-ID                  BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-REGISTRY-NAME       PIC X(64).
 01 WS-INDEX               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PRESENT             BINARY-LONG VALUE 0.
 01 WS-MSG                 PIC X(1024).
 01 WS-MSG-LEN             BINARY-LONG.
 01 WS-SIG                 PIC X(256) VALUE LOW-VALUES.
 01 WS-BIG                 PIC X(300).
 01 WS-SEND-INDEX          BINARY-LONG.
 01 WS-HAS-UNSIGNED        BINARY-LONG.
 01 WS-UNSIGNED            PIC X(64).
 01 WS-UNSIGNED-LEN        BINARY-LONG.
 01 WS-CONTENT             PIC X(64).
 01 WS-CONTENT-LEN         BINARY-LONG.
 01 WS-SENDER              PIC X(64).
 01 WS-SENDER-LEN          BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-TARGET-PRESENT      BINARY-LONG.
 01 WS-TARGET              PIC X(64).
 01 WS-TARGET-LEN          BINARY-LONG.
 01 WS-GLOBAL              BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-SIGNED              BINARY-LONG.
 01 WS-PIECE               PIC X(64).
 01 WS-PIECE-LEN           BINARY-LONG.
 01 WS-CAP-256             BINARY-LONG VALUE 256.
 01 WS-MAX-256             BINARY-LONG VALUE 256.
 01 WS-MAX-32767           BINARY-LONG VALUE 32767.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-LONG-ZERO           BINARY-DOUBLE VALUE 0.
 01 WS-N-D                 PIC 99.
 01 WS-AGE-D               PIC 999.
 01 WS-PIECE-X             PIC X(256).
 01 WS-HEX                 PIC X(800).
 01 WS-HEX-LEN             BINARY-LONG.
 01 WS-HP                  BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-ONE-BYTE            PIC X.
 01 WS-ONE-COUNT           BINARY-LONG.
 01 WS-LAST-MODE            BINARY-LONG VALUE 0.
 01 WS-MASK-N              BINARY-LONG VALUE 0.
 01 WS-BAD-DECO            BINARY-LONG VALUE 0.
 01 WS-DUMMY               BINARY-LONG.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-DEATH               BINARY-LONG.
 01 WS-ENF                 BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-N3                  PIC 999.
 01 WS-NINE-HUNDRED        BINARY-LONG VALUE 900.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
*>   ---- word wrapping (2.7) ----
     MOVE SPACES TO WS-TEXT256
     CALL "CHAT-WRAP" USING CLIENT-STATE WS-TEXT256 WS-ZERO WS-GW WS-LINES WS-COUNT
     MOVE "an empty text is one empty line" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "aaa bbb ccc" TO WS-TEXT256
     MOVE 11 TO WS-LENGTH
     MOVE "aaa bbb" TO WS-PIECE-X
     MOVE 7 TO WS-PIECE-LEN
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-PIECE-X WS-PIECE-LEN WS-W1
     CALL "CHAT-WRAP" USING CLIENT-STATE WS-TEXT256 WS-LENGTH WS-W1 WS-LINES WS-COUNT
     MOVE "text that fills the width exactly to the second word breaks before the third: two lines" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "the first line is aaa bbb (bytes 1 to 7, no prefix)" TO WS-NAME
     MOVE 1007 TO WS-EXP
     COMPUTE WS-OBS = WS-LN-START(1) * 1000 + WS-LN-LENGTH(1) + WS-LN-PREFIX(1) * 100000
     PERFORM CHK
     MOVE "the second line is ccc (bytes 9 to 11) with the prefix space" TO WS-NAME
     MOVE 190003 TO WS-EXP
     COMPUTE WS-OBS = WS-LN-START(2) * 10000 + WS-LN-LENGTH(2) * 1 + WS-LN-PREFIX(2) * 100000
     PERFORM CHK
     COMPUTE WS-W1 = WS-W1 - 1
     CALL "CHAT-WRAP" USING CLIENT-STATE WS-TEXT256 WS-LENGTH WS-W1 WS-LINES WS-COUNT
     MOVE "one pixel narrower the second word goes to the next line: three lines" TO WS-NAME
     MOVE 3 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "the first of them is aaa (3 bytes: the space is dropped)" TO WS-NAME
     MOVE 3 TO WS-EXP
     MOVE WS-LN-LENGTH(1) TO WS-OBS
     PERFORM CHK
     MOVE "a word longer than the line is cut where the width ends" TO WS-NAME
     MOVE "mmmmmmmmmm" TO WS-TEXT256
     MOVE 10 TO WS-LENGTH
     MOVE "mmmmm" TO WS-PIECE-X
     MOVE 5 TO WS-PIECE-LEN
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-PIECE-X WS-PIECE-LEN WS-W1
     CALL "CHAT-WRAP" USING CLIENT-STATE WS-TEXT256 WS-LENGTH WS-W1 WS-LINES WS-COUNT
     MOVE 3 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "the first cut line is 5 glyphs" TO WS-NAME
     MOVE 5 TO WS-EXP
     MOVE WS-LN-LENGTH(1) TO WS-OBS
     PERFORM CHK
     MOVE "the space of a continuation line takes room: 4 glyphs follow it" TO WS-NAME
     MOVE 4 TO WS-EXP
     MOVE WS-LN-LENGTH(2) TO WS-OBS
     PERFORM CHK
*>   ---- the window of the closed chat with the defaults (2.7) ----
     MOVE 0 TO CH-COUNT HX-GUI-TICKS
     MOVE "hello" TO WS-TEXT
     MOVE 5 TO WS-LENGTH
     MOVE 5 TO WS-TAG
     MOVE 3 TO WS-SRC
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     PERFORM BUILD
     MOVE "one line: a background, a tag bar and a text: three widgets" TO WS-NAME
     MOVE 3 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "the background is an overlay at x 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE SM-W-X(1) TO WS-OBS
     PERFORM CHK
     MOVE "the bottom line's background starts at 240 - 40 - 9 = 191" TO WS-NAME
     MOVE 191 TO WS-EXP
     MOVE SM-W-Y(1) TO WS-OBS
     PERFORM CHK
     MOVE "the background is 332 wide and 9 high" TO WS-NAME
     MOVE 332009 TO WS-EXP
     COMPUTE WS-OBS = SM-W-W(1) * 1000 + SM-W-H(1)
     PERFORM CHK
     MOVE "the background alpha at age 0 is floor(1.0 x 0.5 x 255) = 127" TO WS-NAME
     MOVE 127 TO WS-EXP
     MOVE SM-W-ALPHA(1) TO WS-OBS
     PERFORM CHK
     MOVE "the tag bar is 2 wide at x 0 over the line" TO WS-NAME
     MOVE 2000 TO WS-EXP
     COMPUTE WS-OBS = SM-W-W(2) * 1000 + SM-W-X(2)
     PERFORM CHK
     MOVE "the tag bar of a server message is D0D0D0" TO WS-NAME
     MOVE 13684944 TO WS-EXP
     MOVE SM-W-COLOUR(2) TO WS-OBS
     PERFORM CHK
     MOVE "and has alpha 255" TO WS-NAME
     MOVE 255 TO WS-EXP
     MOVE SM-W-ALPHA(2) TO WS-OBS
     PERFORM CHK
     MOVE "the text is hello at x 4, y 200 - 8 = 192, alpha 255" TO WS-NAME
     MOVE 4192255 TO WS-EXP
     COMPUTE WS-OBS = SM-W-X(3) * 1000000 + SM-W-Y(3) * 1000 + SM-W-ALPHA(3)
     PERFORM CHK
     MOVE "T" TO TL-MODE
     MOVE "the label's text" TO TL-CASE
     MOVE "hello" TO TL-EXPECTED
     MOVE SM-W-TEXT(3)(1:5) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   ---- the fade (2.7): age in GUI ticks 180, 185, 190, 195, 200 ----
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         COMPUTE HX-GUI-TICKS = 180 + WS-I * 5
         PERFORM BUILD
         EVALUATE WS-I
             WHEN 0 MOVE 127255 TO WS-EXP
             WHEN 1 MOVE 71143 TO WS-EXP
             WHEN 2 MOVE 31063 TO WS-EXP
             WHEN 3 MOVE 7015 TO WS-EXP
             WHEN OTHER MOVE 0 TO WS-EXP
         END-EVALUATE
         MOVE SPACES TO WS-NAME
         MOVE HX-GUI-TICKS TO WS-AGE-D
         STRING "fade of age " WS-AGE-D ": background alpha x 1000 + text alpha" DELIMITED BY SIZE INTO WS-NAME
         IF WS-I = 4
             MOVE SM-WIDGET-COUNT TO WS-OBS
         ELSE
             COMPUTE WS-OBS = SM-W-ALPHA(1) * 1000 + SM-W-ALPHA(3)
         END-IF
         PERFORM CHK
     END-PERFORM
     MOVE 0 TO HX-GUI-TICKS
*>   ---- the tags (2.4) ----
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
         MOVE 0 TO CH-COUNT
         MOVE WS-I TO WS-TAG
         CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
         PERFORM BUILD
         EVALUATE WS-I
             WHEN 0 MOVE 2 TO WS-EXP
             WHEN OTHER MOVE 3 TO WS-EXP
         END-EVALUATE
         MOVE SPACES TO WS-NAME
         MOVE WS-I TO WS-N-D
         STRING "tag " WS-N-D ": widget count" DELIMITED BY SIZE INTO WS-NAME
         MOVE SM-WIDGET-COUNT TO WS-OBS
         PERFORM CHK
         IF WS-I > 0
             EVALUATE WS-I
                 WHEN 2 MOVE 6316128 TO WS-EXP
                 WHEN 3 MOVE 16733525 TO WS-EXP
                 WHEN OTHER MOVE 13684944 TO WS-EXP
             END-EVALUATE
             MOVE SPACES TO WS-NAME
             STRING "tag " WS-N-D ": indicator colour" DELIMITED BY SIZE INTO WS-NAME
             MOVE SM-W-COLOUR(2) TO WS-OBS
             PERFORM CHK
         END-IF
     END-PERFORM
*>   ---- history: 12 lines, the window shows the newest 10 oldest first (2.7) ----
     MOVE 0 TO CH-COUNT
     MOVE 5 TO WS-TAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-I TO WS-N-D
         MOVE SPACES TO WS-TEXT
         STRING "line " WS-N-D DELIMITED BY SIZE INTO WS-TEXT
         MOVE 7 TO WS-LENGTH
         CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     END-PERFORM
     PERFORM BUILD
     MOVE "12 lines: ten labels are drawn" TO WS-NAME
     MOVE 10 TO WS-EXP
     MOVE WS-LABELS TO WS-OBS
     PERFORM CHK
     MOVE "T" TO TL-MODE
     MOVE "the oldest label drawn is line 03" TO TL-CASE
     MOVE "line 03" TO TL-EXPECTED
     MOVE SM-W-TEXT(3)(1:7) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "the newest line is at the bottom: its label y is 192" TO WS-NAME
     MOVE 192 TO WS-EXP
     MOVE SM-W-Y(SM-WIDGET-COUNT) TO WS-OBS
     PERFORM CHK
     MOVE "the oldest drawn is 9 lines above: y 192 - 81 = 111" TO WS-NAME
     MOVE 111 TO WS-EXP
     MOVE SM-W-Y(3) TO WS-OBS
     PERFORM CHK
*>   ---- the options (2.8) ----
     MOVE 0 TO CH-COUNT
     MOVE "hello" TO WS-TEXT
     MOVE 5 TO WS-LENGTH
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     MOVE "chatOpacity" TO WS-OPT-NAME
     MOVE "0.5" TO WS-OPT-VALUE
     MOVE 3 TO WS-OPT-LENGTH
     PERFORM SET-OPT
     PERFORM BUILD
     MOVE "chatOpacity 0.5: text opacity 0.55, text alpha floor(0.55 x 255) = 140" TO WS-NAME
     MOVE 140 TO WS-EXP
     MOVE SM-W-ALPHA(3) TO WS-OBS
     PERFORM CHK
     MOVE "chatOpacity 0.5: the background alpha is unchanged (127)" TO WS-NAME
     MOVE 127 TO WS-EXP
     MOVE SM-W-ALPHA(1) TO WS-OBS
     PERFORM CHK
     MOVE "1.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
     MOVE "textBackgroundOpacity" TO WS-OPT-NAME
     MOVE "1.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
     PERFORM BUILD
     MOVE "textBackgroundOpacity 1.0: background alpha 255" TO WS-NAME
     MOVE 255 TO WS-EXP
     MOVE SM-W-ALPHA(1) TO WS-OBS
     PERFORM CHK
     MOVE "0.5" TO WS-OPT-VALUE
     PERFORM SET-OPT
     MOVE "chatLineSpacing" TO WS-OPT-NAME
     MOVE "1.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
     PERFORM BUILD
     MOVE "chatLineSpacing 1.0: line height 18 (background y 182), text offset 12 (label y 188)" TO WS-NAME
     MOVE 182018188 TO WS-EXP
     COMPUTE WS-OBS = SM-W-Y(1) * 1000000 + SM-W-H(1) * 1000 + SM-W-Y(3)
     PERFORM CHK
     MOVE "0.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
     MOVE "chatHeightUnfocused" TO WS-OPT-NAME
     MOVE "0.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
     MOVE 0 TO CH-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     END-PERFORM
     PERFORM BUILD
     MOVE "chatHeightUnfocused 0: 20 pixels, floor(20 / 9) = 2 lines" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE WS-LABELS TO WS-OBS
     PERFORM CHK
     MOVE "0.4375" TO WS-OPT-VALUE
     PERFORM SET-OPT
     MOVE "chatWidth" TO WS-OPT-NAME
     MOVE "0.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
     MOVE 0 TO CH-COUNT
     MOVE "one two three four five six seven eight nine ten" TO WS-TEXT
     MOVE 48 TO WS-LENGTH
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     PERFORM BUILD
     MOVE "chatWidth 0: 40 pixels, the message wraps into several lines" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-LABELS > 4
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     MOVE "the second line begins with a space" TO WS-NAME
     MOVE 32 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION ORD(SM-W-TEXT(SM-WIDGET-COUNT - 1)(1:1)) - 1
     PERFORM CHK
     MOVE "1.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
*>   ---- the visibility option (2.8) ----
     MOVE "chatVisibility" TO WS-OPT-NAME
     MOVE "1" TO WS-OPT-VALUE
     MOVE 1 TO WS-OPT-LENGTH
     PERFORM SET-OPT
     MOVE 0 TO CH-COUNT
     MOVE "hello" TO WS-TEXT
     MOVE 5 TO WS-LENGTH
     MOVE 2 TO WS-SRC
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     MOVE "Commands Only: a player line is dropped" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 3 TO WS-SRC
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     MOVE "Commands Only: a server system line is kept" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "2" TO WS-OPT-VALUE
     PERFORM SET-OPT
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     MOVE "Hidden: a server system line is dropped" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 1 TO WS-SRC
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     MOVE "Hidden: the client's own line is kept" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "0" TO WS-OPT-VALUE
     PERFORM SET-OPT
*>   ---- the delay queue (2.9): chatDelay 1 second = 20 unpaused ticks ----
     MOVE 0 TO CH-COUNT HX-DQ-COUNT HX-GUI-TICKS HX-CHAT-PREV-MS
     MOVE "chatDelay" TO WS-OPT-NAME
     MOVE "1.0" TO WS-OPT-VALUE
     MOVE 3 TO WS-OPT-LENGTH
     PERFORM SET-OPT
     MOVE 2 TO WS-SRC
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     MOVE "delay 1 s: two player lines wait in the queue" TO WS-NAME
     MOVE 2000 TO WS-EXP
     COMPUTE WS-OBS = HX-DQ-COUNT * 1000 + CH-COUNT
     PERFORM CHK
     PERFORM 19 TIMES
         CALL "CHAT-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "19 ticks later (950 ms): nothing is shown yet" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     CALL "CHAT-TICK" USING CLIENT-STATE
     MOVE "20 ticks (1000 ms): the first queued line is shown, one only" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     PERFORM 19 TIMES
         CALL "CHAT-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "20 ticks after that line the second one is still waiting" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     CALL "CHAT-TICK" USING CLIENT-STATE
     MOVE "and now it is shown" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     MOVE "0.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
     CALL "CHAT-TICK" USING CLIENT-STATE
     MOVE "delay set to 0: a tick shows the whole queue" TO WS-NAME
     MOVE 3 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "the queue is empty then" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-DQ-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 3 TO WS-SRC
     MOVE "1.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     MOVE "a system line is never delayed" TO WS-NAME
     MOVE 4 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "0.0" TO WS-OPT-VALUE
     PERFORM SET-OPT
     MOVE "chatDelay" TO WS-OPT-NAME
*>   ---- the chat packets (2.1 to 2.6) through the packet dispatcher ----
     PERFORM SETUP-TYPES
     MOVE 0 TO CH-COUNT
     MOVE 0 TO HX-CHAT-INDEX HX-ENFORCES
*>   the sender is in the player list
     MOVE 1 TO PI-COUNT
     MOVE 1 TO PI-USED(1)
     MOVE WS-UUID TO PI-UUID(1)
     MOVE "Steve" TO PI-NAME(1)
     MOVE 5 TO PI-NAME-LENGTH(1)
     MOVE 0 TO WS-GLOBAL
     MOVE 0 TO WS-SIGNED WS-HAS-UNSIGNED WS-MASK
     MOVE "hello" TO WS-CONTENT
     MOVE 5 TO WS-CONTENT-LEN
     MOVE "Steve" TO WS-SENDER
     MOVE 5 TO WS-SENDER-LEN
     MOVE 1 TO WS-HOLDER
     MOVE 0 TO WS-TARGET-PRESENT
     PERFORM SEND-PLAYER-CHAT
     MOVE "Player Chat, type chat, unsigned: the line is <Steve> hello" TO WS-NAME
     PERFORM CHECK-LAST-LINE-1
     MOVE "it is a player line with the not secure tag (1)" TO WS-NAME
     MOVE 1002 TO WS-EXP
     COMPUTE WS-OBS = HX-CM-TAG(CH-COUNT) * 1000 + HX-CM-SRC(CH-COUNT)
     PERFORM CHK
     MOVE "the counter is 1 after one message" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE HX-CHAT-INDEX TO WS-OBS
     PERFORM CHK
*>   the unsigned content replaces the signed body when the packet has it
     MOVE 1 TO WS-GLOBAL
     MOVE 1 TO WS-HAS-UNSIGNED
     MOVE "unsigned!" TO WS-UNSIGNED
     MOVE 9 TO WS-UNSIGNED-LEN
     PERFORM SEND-PLAYER-CHAT
     MOVE "the unsigned content is shown instead of the body" TO WS-NAME
     PERFORM CHECK-LAST-LINE-2
*>   a signed packet is stripped by the accept-unsigned validator: still not secure
     MOVE 2 TO WS-GLOBAL
     MOVE 0 TO WS-HAS-UNSIGNED
     MOVE 1 TO WS-SIGNED
     PERFORM SEND-PLAYER-CHAT
     MOVE "a signed packet under the accept-unsigned validator is not secure (tag 1)" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE HX-CM-TAG(CH-COUNT) TO WS-OBS
     PERFORM CHK
     MOVE 0 TO WS-SIGNED
*>   emote_command type, sender and content
     MOVE 3 TO WS-GLOBAL
     MOVE 2 TO WS-HOLDER
     PERFORM SEND-PLAYER-CHAT
     MOVE "chat type emote_command: * Steve hello" TO WS-NAME
     MOVE "* Steve hello" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT
*>   a team message: target Red, sender Steve
     MOVE 4 TO WS-GLOBAL
     MOVE 6 TO WS-HOLDER
     MOVE 1 TO WS-TARGET-PRESENT
     MOVE "Red" TO WS-TARGET
     MOVE 3 TO WS-TARGET-LEN
     MOVE "hi" TO WS-CONTENT
     MOVE 2 TO WS-CONTENT-LEN
     PERFORM SEND-PLAYER-CHAT
     MOVE "team_msg_command_incoming: Red <Steve> hi" TO WS-NAME
     MOVE "Red <Steve> hi" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT
     MOVE 0 TO WS-TARGET-PRESENT
*>   a fully filtered message is dropped
     MOVE 5 TO WS-GLOBAL
     MOVE 1 TO WS-HOLDER
     MOVE 1 TO WS-MASK
     MOVE CH-COUNT TO WS-N
     PERFORM SEND-PLAYER-CHAT
     MOVE "a fully filtered message is dropped" TO WS-NAME
     MOVE WS-N TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 0 TO WS-MASK
*>   an inline chat type: its own decoration (key chat.type.announcement, parameters sender and content)
     MOVE 6 TO WS-GLOBAL
     MOVE 0 TO WS-HOLDER
     MOVE "hello" TO WS-CONTENT
     MOVE 5 TO WS-CONTENT-LEN
     PERFORM SEND-PLAYER-CHAT
     MOVE "an inline decoration is used: [Steve] hello" TO WS-NAME
     MOVE "[Steve] hello" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT
*>   an unknown sender: the error line
     MOVE 7 TO WS-GLOBAL
     MOVE 1 TO WS-HOLDER
     MOVE "0" TO WS-UUID(1:1)
     MOVE "9" TO WS-UUID(1:1)
     PERFORM SEND-PLAYER-CHAT
     MOVE "a sender that is not in the player list: the error line" TO WS-NAME
     MOVE "<Steve> Chat validation error" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT
     MOVE "it has the error tag (3)" TO WS-NAME
     MOVE 3 TO WS-EXP
     MOVE HX-CM-TAG(CH-COUNT) TO WS-OBS
     PERFORM CHK
     MOVE "0" TO WS-UUID(1:1)
*>   enforcesSecureChat true: every message is an error line
     MOVE 8 TO WS-GLOBAL
     MOVE 1 TO HX-ENFORCES
     PERFORM SEND-PLAYER-CHAT
     MOVE "enforcesSecureChat: the same packet is the error line" TO WS-NAME
     MOVE "<Steve> Chat validation error" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT
     MOVE 0 TO HX-ENFORCES
*>   onlyShowSecureChat drops not secure lines
     MOVE "onlyShowSecureChat" TO WS-OPT-NAME
     MOVE "true" TO WS-OPT-VALUE
     MOVE 4 TO WS-OPT-LENGTH
     PERFORM SET-OPT
     MOVE 9 TO WS-GLOBAL
     MOVE CH-COUNT TO WS-N
     PERFORM SEND-PLAYER-CHAT
     MOVE "onlyShowSecureChat drops a not secure line" TO WS-NAME
     MOVE WS-N TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "false" TO WS-OPT-VALUE
     MOVE 5 TO WS-OPT-LENGTH
     PERFORM SET-OPT
*>   a wrong index ends the connection
     MOVE 99 TO WS-GLOBAL
     PERFORM SEND-PLAYER-CHAT
     MOVE "a missed global index disconnects (the server list screen)" TO WS-NAME
     MOVE SCR-SERVER-LIST TO WS-EXP
     MOVE SM-SCREEN TO WS-OBS
     PERFORM CHK
     MOVE "T" TO TL-MODE
     MOVE "the disconnect text is the language's bad_chat_index" TO TL-CASE
     MOVE "Detected a missed or reordered chat message from the server" TO TL-EXPECTED
     MOVE SM-MESSAGE(1:SM-MESSAGE-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   ---- the rest of the packets: a started client again (the disconnect ended the first) ----
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PI-COUNT
     MOVE 1 TO PI-USED(1)
     MOVE WS-UUID TO PI-UUID(1)
     MOVE "Steve" TO PI-NAME(1)
     MOVE 5 TO PI-NAME-LENGTH(1)
     PERFORM SETUP-TYPES
     MOVE 0 TO CH-COUNT HX-CHAT-INDEX
     MOVE 0 TO WS-SIGNED WS-HAS-UNSIGNED WS-MASK WS-TARGET-PRESENT
     MOVE "hello" TO WS-CONTENT
     MOVE 5 TO WS-CONTENT-LEN
     MOVE "Steve" TO WS-SENDER
     MOVE 5 TO WS-SENDER-LEN
*>   a chat type index the registry does not have shows the content alone
     MOVE 0 TO WS-GLOBAL
     MOVE 10 TO WS-HOLDER
     PERFORM SEND-PLAYER-CHAT
     MOVE "a holder the registry does not have: the content alone" TO WS-NAME
     MOVE "hello" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT
*>   a partly filtered message (a ByteBitSet of two bytes) and a packed last-seen list (a full signature and a cache reference)
     MOVE 1 TO WS-GLOBAL
     MOVE 1 TO WS-HOLDER
     MOVE 2 TO WS-MASK
     MOVE 2 TO WS-MASK-N
     MOVE 1 TO WS-LAST-MODE
     PERFORM SEND-PLAYER-CHAT
     MOVE "a partly filtered message with a last-seen list is shown (the text is not rewritten)" TO WS-NAME
     MOVE "<Steve> hello" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT
     MOVE 0 TO WS-MASK WS-MASK-N WS-LAST-MODE
*>   more than 20 last-seen entries is a malformed packet: no line and the counter is not touched
     MOVE CH-COUNT TO WS-N
     MOVE HX-CHAT-INDEX TO WS-I
     MOVE 2 TO WS-GLOBAL
     MOVE 2 TO WS-LAST-MODE
     PERFORM SEND-PLAYER-CHAT
     MOVE "21 last-seen entries: the packet is dropped" TO WS-NAME
     MOVE WS-N TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "and the global index counter stays" TO WS-NAME
     MOVE WS-I TO WS-EXP
     MOVE HX-CHAT-INDEX TO WS-OBS
     PERFORM CHK
     MOVE 0 TO WS-LAST-MODE
*>   a filter mask of 5000 bytes is malformed
     MOVE 2 TO WS-MASK
     MOVE 5000 TO WS-MASK-N
     MOVE 1 TO WS-HOLDER
     PERFORM SEND-PLAYER-CHAT
     MOVE "a filter mask over 4096 bytes: the packet is dropped" TO WS-NAME
     MOVE WS-N TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 0 TO WS-MASK WS-MASK-N
*>   an inline decoration with 65 parameters is malformed
     MOVE 0 TO WS-HOLDER
     MOVE 1 TO WS-BAD-DECO
     PERFORM SEND-PLAYER-CHAT
     MOVE "an inline decoration with 65 parameters: the packet is dropped" TO WS-NAME
     MOVE WS-N TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 0 TO WS-BAD-DECO
*>   a truncated packet is dropped, a short System Chat too
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     MOVE 66 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE 0 TO PB-POS
     MOVE 124 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "truncated Player Chat and System Chat packets add no line" TO WS-NAME
     MOVE WS-N TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
*>   the local player's own message on a hosted world is secure (no tag)
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "Alice" TO PI-NAME(1)
     MOVE 1 TO SP-ACTIVE
     MOVE HX-CHAT-INDEX TO WS-GLOBAL
     MOVE 1 TO WS-HOLDER
     PERFORM SEND-PLAYER-CHAT
     MOVE "the local player on a hosted world: tag 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-CM-TAG(CH-COUNT) TO WS-OBS
     PERFORM CHK
     MOVE 0 TO SP-ACTIVE
*>   Disguised Chat (33): text hi, chat type say_command (holder 3), sender Steve: [Steve] hi, system tag, player line
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE "hi" TO WS-PIECE
     MOVE 2 TO WS-PIECE-LEN
     PERFORM PUT-PLAIN
     MOVE 3 TO WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     MOVE "Steve" TO WS-PIECE
     MOVE 5 TO WS-PIECE-LEN
     PERFORM PUT-PLAIN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     MOVE 33 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "Disguised Chat say_command: [Steve] hi" TO WS-NAME
     MOVE "[Steve] hi" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT
     MOVE "it is a player line with the system tag (4)" TO WS-NAME
     MOVE 4002 TO WS-EXP
     COMPUTE WS-OBS = HX-CM-TAG(CH-COUNT) * 1000 + HX-CM-SRC(CH-COUNT)
     PERFORM CHK
     MOVE "a truncated Disguised Chat is dropped" TO WS-NAME
     MOVE CH-COUNT TO WS-N
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE WS-N TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
*>   Delete Chat (31): a full signature and a cache reference are read and change nothing
     MOVE CH-COUNT TO WS-N
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-SIG WS-CAP-256
     MOVE 0 TO PB-POS
     MOVE 31 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FIVE
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "Delete Chat finds no unsigned line: nothing changes" TO WS-NAME
     MOVE WS-N TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
*>   the history keeps 100 lines (the oldest goes)
     MOVE 0 TO CH-COUNT
     MOVE 1 TO WS-SRC
     MOVE 5 TO WS-TAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 101
         MOVE SPACES TO WS-TEXT
         MOVE WS-I TO WS-N3
         STRING "m" WS-N3 DELIMITED BY SIZE INTO WS-TEXT
         MOVE 4 TO WS-LENGTH
         CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SRC
     END-PERFORM
     MOVE "101 lines: the history holds 100" TO WS-NAME
     MOVE 100 TO WS-EXP
     MOVE CH-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "T" TO TL-MODE
     MOVE "the oldest kept line is the second one" TO TL-CASE
     MOVE "m002" TO TL-EXPECTED
     MOVE CH-TEXT(1)(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Registry Data of chat_type (04): the vanilla entry without data, a custom one with a decoration, one with a non-compound value
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE "13 6D 69 6E 65 63 72 61 66 74 3A 63 68 61 74 5F 74 79 70 65 03 0E 6D 69 "
         & "6E 65 63 72 61 66 74 3A 63 68 61 74 00 0C 63 75 73 74 6F 6D 3A 73 68 6F "
         & "75 74 01 0A 01 00 03 66 6F 6F 05 0A 00 04 63 68 61 74 08 00 0F 74 72 61 "
         & "6E 73 6C 61 74 69 6F 6E 5F 6B 65 79 00 05 6D 79 2E 25 73 09 00 0A 70 61 "
         & "72 61 6D 65 74 65 72 73 08 00 00 00 02 00 07 63 6F 6E 74 65 6E 74 00 06 "
         & "73 65 6E 64 65 72 0A 00 05 73 74 79 6C 65 00 00 0A 00 09 6E 61 72 72 61 "
         & "74 69 6F 6E 08 00 0F 74 72 61 6E 73 6C 61 74 69 6F 6E 5F 6B 65 79 00 01 "
         & "6E 00 00 0A 63 75 73 74 6F 6D 3A 6F 64 64 01 08 00 01 7A" TO WS-HEX
     PERFORM APPEND-HEX
     MOVE 0 TO PB-POS
     CALL "REGISTRY-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "Registry Data chat_type: three entries kept" TO WS-NAME
     MOVE 3 TO WS-EXP
     MOVE HX-CT-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "T" TO TL-MODE
     MOVE "the data of the second entry gives its translation key" TO TL-CASE
     MOVE "my.%s" TO TL-EXPECTED
     MOVE HX-CT-KEY(2)(1:5) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "and its parameters content, sender" TO WS-NAME
     MOVE 2002 TO WS-EXP
     COMPUTE WS-OBS = HX-CT-PCOUNT(2) * 1000 + HX-CT-PARAM(2, 1) * 1 + HX-CT-PARAM(2, 2) * 10 + 1 * 0
     PERFORM CHK
     MOVE "the first entry took the vanilla decoration (chat.type.text)" TO WS-NAME
     MOVE 14 TO WS-EXP
     MOVE HX-CT-KEY-LEN(1) TO WS-OBS
     PERFORM CHK
     MOVE 0 TO CH-COUNT HX-CHAT-INDEX
     MOVE 2 TO WS-HOLDER
     MOVE 0 TO WS-GLOBAL
     PERFORM SEND-PLAYER-CHAT
     MOVE "a message of the custom type is shown with its own key: my.hello" TO WS-NAME
     MOVE "my.hello" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT
*>   Login: the rest of the packet (last death location, portal cooldown, sea level, onlineMode, enforcesSecureChat)
     MOVE 0 TO WS-DEATH
     MOVE 1 TO WS-ENF
     PERFORM SEND-LOGIN
     MOVE "Login without a last death location and enforcesSecureChat true: the flag is kept" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE HX-ENFORCES TO WS-OBS
     PERFORM CHK
     MOVE "the chat's global index starts at 0 again" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-CHAT-INDEX TO WS-OBS
     PERFORM CHK
     MOVE 1 TO WS-DEATH
     MOVE 0 TO WS-ENF
     PERFORM SEND-LOGIN
     MOVE "Login with a last death location and enforcesSecureChat false: the flag is off" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-ENFORCES TO WS-OBS
     PERFORM CHK
     STOP RUN.

 CHK.
     MOVE WS-NAME TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SET-OPT.
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK.

*> The widgets of the closed chat window.
 BUILD.
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "CHAT-HUD-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE 0 TO WS-LABELS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-J) = WK-LABEL
             ADD 1 TO WS-LABELS
         END-IF
     END-PERFORM.

 CHECK-LAST-TEXT.
     MOVE "T" TO TL-MODE
     MOVE WS-NAME TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE CH-TEXT(CH-COUNT)(1:CH-LENGTH(CH-COUNT)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE.

 CHECK-LAST-LINE-1.
     MOVE "<Steve> hello" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT.

 CHECK-LAST-LINE-2.
     MOVE "<Steve> unsigned!" TO TL-EXPECTED
     PERFORM CHECK-LAST-TEXT.

*> The seven chat types of 57-5 section 2.3 as the registry sends them without data: index 1 chat, 2 emote_command, 3 say_command, 4 msg_command_incoming, 5 msg_command_outgoing,
*> 6 team_msg_command_incoming, 7 team_msg_command_outgoing; the holder of a packet is the index.
 SETUP-TYPES.
     MOVE 0 TO HX-CT-COUNT
     MOVE "minecraft:chat" TO WS-REGISTRY-NAME
     MOVE 1 TO WS-INDEX
     CALL "CHAT-TYPE-ENTRY" USING CLIENT-STATE WS-INDEX WS-REGISTRY-NAME WS-PRESENT PB-BUFFER
     MOVE "minecraft:emote_command" TO WS-REGISTRY-NAME
     MOVE 2 TO WS-INDEX
     CALL "CHAT-TYPE-ENTRY" USING CLIENT-STATE WS-INDEX WS-REGISTRY-NAME WS-PRESENT PB-BUFFER
     MOVE "minecraft:say_command" TO WS-REGISTRY-NAME
     MOVE 3 TO WS-INDEX
     CALL "CHAT-TYPE-ENTRY" USING CLIENT-STATE WS-INDEX WS-REGISTRY-NAME WS-PRESENT PB-BUFFER
     MOVE "minecraft:msg_command_incoming" TO WS-REGISTRY-NAME
     MOVE 4 TO WS-INDEX
     CALL "CHAT-TYPE-ENTRY" USING CLIENT-STATE WS-INDEX WS-REGISTRY-NAME WS-PRESENT PB-BUFFER
     MOVE "minecraft:msg_command_outgoing" TO WS-REGISTRY-NAME
     MOVE 5 TO WS-INDEX
     CALL "CHAT-TYPE-ENTRY" USING CLIENT-STATE WS-INDEX WS-REGISTRY-NAME WS-PRESENT PB-BUFFER
     MOVE "minecraft:team_msg_command_incoming" TO WS-REGISTRY-NAME
     MOVE 6 TO WS-INDEX
     CALL "CHAT-TYPE-ENTRY" USING CLIENT-STATE WS-INDEX WS-REGISTRY-NAME WS-PRESENT PB-BUFFER
     MOVE "minecraft:team_msg_command_outgoing" TO WS-REGISTRY-NAME
     MOVE 7 TO WS-INDEX
     CALL "CHAT-TYPE-ENTRY" USING CLIENT-STATE WS-INDEX WS-REGISTRY-NAME WS-PRESENT PB-BUFFER.

*> Player Chat (id 66) from the WS- fields: global index, sender UUID, per-sender index 0, an optional signature (WS-SIGNED), the packed body (WS-CONTENT), the optional unsigned
*> content, the filter mask kind WS-MASK, the chat type bound (holder WS-HOLDER, the sender name, the optional target).
 SEND-PLAYER-CHAT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-GLOBAL
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-SIGNED
     IF WS-SIGNED = 1
         CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-SIG WS-CAP-256
     END-IF
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-CONTENT WS-CONTENT-LEN WS-MAX-256
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-LONG-ZERO
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-LONG-ZERO
     EVALUATE WS-LAST-MODE
         WHEN 1
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TWO
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
             CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-SIG WS-CAP-256
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FIVE
         WHEN 2
             MOVE 21 TO WS-INT
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-INT
         WHEN OTHER
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     END-EVALUATE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-HAS-UNSIGNED
     IF WS-HAS-UNSIGNED = 1
         MOVE WS-UNSIGNED TO WS-PIECE
         MOVE WS-UNSIGNED-LEN TO WS-PIECE-LEN
         PERFORM PUT-PLAIN
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-MASK
     IF WS-MASK = 2
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-MASK-N
         IF WS-MASK-N <= 256
             CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-SIG WS-MASK-N
         END-IF
     END-IF
     EVALUATE TRUE
         WHEN WS-HOLDER = 0 AND WS-BAD-DECO = 1
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
             MOVE "chat.type.announcement" TO WS-PIECE
             MOVE 22 TO WS-PIECE-LEN
             CALL "PB-PUT-STRING" USING PB-BUFFER WS-PIECE WS-PIECE-LEN WS-MAX-32767
             MOVE 65 TO WS-INT
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-INT
         WHEN WS-HOLDER = 0
*>           inline: chat decoration (chat.type.announcement; sender, content; empty style), narration (the same key)
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
             PERFORM PUT-ANNOUNCEMENT
             PERFORM PUT-ANNOUNCEMENT
         WHEN OTHER
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     END-EVALUATE
     MOVE WS-SENDER TO WS-PIECE
     MOVE WS-SENDER-LEN TO WS-PIECE-LEN
     PERFORM PUT-PLAIN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-TARGET-PRESENT
     IF WS-TARGET-PRESENT = 1
         MOVE WS-TARGET TO WS-PIECE
         MOVE WS-TARGET-LEN TO WS-PIECE-LEN
         PERFORM PUT-PLAIN
     END-IF
     MOVE 0 TO PB-POS
     MOVE 66 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.

*> Login (id 50): player id 7, one level minecraft:overworld, view distance 5, dimension minecraft:overworld, the last death location when WS-DEATH is 1, enforcesSecureChat WS-ENF.
 SEND-LOGIN.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE 7 TO WS-INT
     CALL "PB-PUT-INT" USING PB-BUFFER WS-INT
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     MOVE "minecraft:overworld" TO WS-PIECE
     MOVE 19 TO WS-PIECE-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-PIECE WS-PIECE-LEN
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TEN
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FIVE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FIVE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-PIECE WS-PIECE-LEN
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-LONG-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-DEATH
     IF WS-DEATH = 1
         CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-PIECE WS-PIECE-LEN
         CALL "PB-PUT-LONG" USING PB-BUFFER WS-LONG-ZERO
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FIVE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ENF
     MOVE 0 TO PB-POS
     MOVE 50 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.

 PUT-ANNOUNCEMENT.
     MOVE "chat.type.announcement" TO WS-PIECE
     MOVE 22 TO WS-PIECE-LEN
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-PIECE WS-PIECE-LEN WS-MAX-32767
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TWO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TWO
*>   the style: an empty compound, network NBT 0A 00
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-TEN
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-ZERO.

 PUT-PLAIN.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE WS-PIECE TO PB-TX-VALUE
     MOVE WS-PIECE-LEN TO PB-TX-LENGTH
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT.

*> Appends the bytes of WS-HEX (pairs separated by spaces) to PB-BUFFER.
 APPEND-HEX.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-HEX TRAILING)) TO WS-HEX-LEN
     MOVE 1 TO WS-HP
     PERFORM UNTIL WS-HP > WS-HEX-LEN
         MOVE WS-HEX(WS-HP:1) TO WS-CH
         PERFORM HEX-DIGIT
         MOVE WS-DIGIT TO WS-HI
         MOVE WS-HEX(WS-HP + 1:1) TO WS-CH
         PERFORM HEX-DIGIT
         COMPUTE WS-BYTE = WS-HI * 16 + WS-DIGIT
         MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-ONE-BYTE
         MOVE 1 TO WS-ONE-COUNT
         CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-ONE-BYTE WS-ONE-COUNT
         ADD 3 TO WS-HP
     END-PERFORM.

 HEX-DIGIT.
     EVALUATE TRUE
         WHEN WS-CH >= "0" AND WS-CH <= "9"
             COMPUTE WS-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("0")
         WHEN WS-CH >= "A" AND WS-CH <= "F"
             COMPUTE WS-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("A") + 10
         WHEN OTHER
             MOVE 0 TO WS-DIGIT
     END-EVALUATE.
 END PROGRAM TEST-HUD-CHAT.

 COPY CLTEST.
