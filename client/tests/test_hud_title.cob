*> Implementation test of docs/protocol/57-client-closures-5 section 3 (task T47410): the title, the subtitle and the action bar. The state machine of the five packets (3.1: the
*> defaults 10, 70, 20; a Set Title Text restarts the whole timer; the animation packet changes only the times that are not negative and restarts a running title; Clear Titles
*> keeps the times unless it resets), the fade alpha of every titleTime of the worked example (fade in 5, stay 40, fade out 10: alpha 0 at 55, 51, 102, 153, 204, 255 down to
*> 11 and 10, then 229, 204, 178, 153, 127, 102, 76, 51, 25 at 9 to 1; 127 at titleTime 53 with the partial tick 0.5), the layout (centre, scale 4 and 2, y -10 and 5), the backdrop,
*> the action bar (60 ticks, alpha min(255, trunc(t x 255 / 20)), position H - 68 - 4) and the rainbow of the "now playing" display (hsvToArgb of 3.5, worked values 45 153 153,
*> 153 45 45, 153 255 45, 0 153 45).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HUD-TITLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-SERVER              BINARY-LONG.
 01 WS-NAME                PIC X(200).
 01 WS-EXP                 BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-GW                  BINARY-LONG VALUE 427.
 01 WS-GH                  BINARY-LONG VALUE 240.
 01 WS-ALPHAS-DATA.
    05 FILLER PIC 999 VALUE 025.
    05 FILLER PIC 999 VALUE 051.
    05 FILLER PIC 999 VALUE 076.
    05 FILLER PIC 999 VALUE 102.
    05 FILLER PIC 999 VALUE 127.
    05 FILLER PIC 999 VALUE 153.
    05 FILLER PIC 999 VALUE 178.
    05 FILLER PIC 999 VALUE 204.
    05 FILLER PIC 999 VALUE 229.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 255.
    05 FILLER PIC 999 VALUE 204.
    05 FILLER PIC 999 VALUE 153.
    05 FILLER PIC 999 VALUE 102.
    05 FILLER PIC 999 VALUE 051.
    05 FILLER PIC 999 VALUE 000.
 01 WS-ALPHAS REDEFINES WS-ALPHAS-DATA.
    05 WS-ALPHA            PIC 999 OCCURS 55 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 512.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-ID                  BINARY-LONG.
 01 WS-PIECE               PIC X(64).
 01 WS-PIECE-LEN           BINARY-LONG.
 01 WS-X256                PIC X(256).
 01 WS-W                   BINARY-LONG.
 01 WS-W2                  BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-HUE                 FLOAT-LONG.
 01 WS-SAT                 FLOAT-LONG VALUE 0.7.
 01 WS-VAL                 FLOAT-LONG VALUE 0.6.
 01 WS-RGB                 BINARY-LONG.
 01 WS-OPT-NAME            PIC X(40).
 01 WS-OPT-VALUE           PIC X(4096).
 01 WS-OPT-LENGTH          BINARY-LONG.
 01 WS-OPT-OK              BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ANIMATE             BINARY-LONG.
 01 WS-D                   PIC 99.
 01 WS-KIND                BINARY-LONG.
 01 WS-ZERO-STATE          BINARY-LONG VALUE 0.
 01 WS-INT2                BINARY-LONG VALUE 0.
 01 WS-INT3                BINARY-LONG VALUE 0.
 01 WS-QW1                 FLOAT-LONG.
 01 WS-QW4                 FLOAT-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-HALF2               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     MOVE "the defaults of the three times are 10, 70 and 20" TO WS-NAME
     MOVE 107020 TO WS-EXP
     COMPUTE WS-OBS = HX-T-IN * 10000 + HX-T-STAY * 100 + HX-T-OUT
     PERFORM CHK
*>   ---- the worked sequence (3.2): animation 5 40 10, subtitle Sub, title Hi ----
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE 5 TO WS-INT
     CALL "PB-PUT-INT" USING PB-BUFFER WS-INT
     MOVE 40 TO WS-INT
     CALL "PB-PUT-INT" USING PB-BUFFER WS-INT
     MOVE 10 TO WS-INT
     CALL "PB-PUT-INT" USING PB-BUFFER WS-INT
     MOVE 0 TO PB-POS
     MOVE 117 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "Set Titles Animation 5 40 10 sets the three times" TO WS-NAME
     MOVE 5040010 TO WS-EXP
     COMPUTE WS-OBS = HX-T-IN * 1000000 + HX-T-STAY * 1000 + HX-T-OUT
     PERFORM CHK
     MOVE "it does not start a title: titleTime stays 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-TITLE-TIME TO WS-OBS
     PERFORM CHK
     MOVE "Sub" TO WS-PIECE
     MOVE 3 TO WS-PIECE-LEN
     MOVE 114 TO WS-ID
     PERFORM SEND-TEXT
     MOVE "a subtitle alone draws nothing and starts no timer" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-TITLE-TIME TO WS-OBS
     PERFORM CHK
     MOVE "Hi" TO WS-PIECE
     MOVE 2 TO WS-PIECE-LEN
     MOVE 116 TO WS-ID
     PERFORM SEND-TEXT
     MOVE "Set Title Text starts the timer: 5 + 40 + 10 = 55" TO WS-NAME
     MOVE 55 TO WS-EXP
     MOVE HX-TITLE-TIME TO WS-OBS
     PERFORM CHK
*>   the fade, titleTime 55 down to 1, partial tick 0
     COMPUTE CL-NEXT-TICK = CL-NOW-MS + 50
     PERFORM VARYING WS-I FROM 55 BY -1 UNTIL WS-I < 1
         MOVE WS-I TO HX-TITLE-TIME
         MOVE 0 TO SM-WIDGET-COUNT
         CALL "HUD-TITLE-ADD" USING CLIENT-STATE WS-GW WS-GH
         MOVE WS-I TO WS-D
         MOVE SPACES TO WS-NAME
         STRING "titleTime " WS-D ": the title alpha" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-ALPHA(WS-I) TO WS-EXP
         MOVE 0 TO WS-OBS
         IF SM-WIDGET-COUNT > 0
             MOVE SM-W-ALPHA(1) TO WS-OBS
         END-IF
         PERFORM CHK
     END-PERFORM
*>   the partial tick 0.5 at titleTime 53: t = 52.5, alpha trunc(2.5 x 255 / 5) = 127
     COMPUTE CL-NEXT-TICK = CL-NOW-MS + 25
     MOVE 53 TO HX-TITLE-TIME
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "HUD-TITLE-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "partial tick 0.5 at titleTime 53: alpha 127" TO WS-NAME
     MOVE 127 TO WS-EXP
     MOVE SM-W-ALPHA(1) TO WS-OBS
     PERFORM CHK
     COMPUTE CL-NEXT-TICK = CL-NOW-MS + 50
*>   the layout at titleTime 30 (alpha 255): the title at scale 4 and the subtitle at scale 2
     MOVE 30 TO HX-TITLE-TIME
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "HUD-TITLE-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "title and subtitle: two labels (the backdrop is off by default)" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "Hi" TO WS-X256
     MOVE 2 TO WS-PIECE-LEN
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-X256 WS-PIECE-LEN WS-W
     COMPUTE WS-HALF = WS-W / 2
     MOVE "the title is at scale 4" TO WS-NAME
     MOVE 4 TO WS-EXP
     MOVE SM-W-SCALE(1) TO WS-OBS
     PERFORM CHK
     MOVE "the title's x is 213 - 4 x (width / 2) and y is 120 - 40" TO WS-NAME
     COMPUTE WS-EXP = (213 - 4 * WS-HALF) * 1000 + 80
     COMPUTE WS-OBS = SM-W-X(1) * 1000 + SM-W-Y(1)
     PERFORM CHK
     MOVE "Sub" TO WS-X256
     MOVE 3 TO WS-PIECE-LEN
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-X256 WS-PIECE-LEN WS-W2
     COMPUTE WS-HALF2 = WS-W2 / 2
     MOVE "the subtitle is at scale 2 with x 213 - 2 x (width / 2) and y 120 + 10" TO WS-NAME
     COMPUTE WS-EXP = 2 * 1000000 + (213 - 2 * WS-HALF2) * 1000 + 130
     COMPUTE WS-OBS = SM-W-SCALE(2) * 1000000 + SM-W-X(2) * 1000 + SM-W-Y(2)
     PERFORM CHK
*>   the backdrop when the text background is Everywhere (backgroundForChatOnly false): alpha 127 x 255 / 255, (x - 2s, y - 2s) to (x + w s + 2s, y + 9s + 2s)
     MOVE "backgroundForChatOnly" TO WS-OPT-NAME
     MOVE "false" TO WS-OPT-VALUE
     MOVE 5 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "HUD-TITLE-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "with the text background Everywhere the title has a backdrop first (4 widgets)" TO WS-NAME
     MOVE 4 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "the backdrop: black, alpha 127, corner (x - 8, y - 8)" TO WS-NAME
     COMPUTE WS-EXP = 127 * 1000000 + (213 - 4 * WS-HALF - 8) * 1000 + 72
     COMPUTE WS-OBS = SM-W-ALPHA(1) * 1000000 + SM-W-X(1) * 1000 + SM-W-Y(1)
     PERFORM CHK
     MOVE "the backdrop is (w x 4 + 16) wide and 9 x 4 + 16 high" TO WS-NAME
     COMPUTE WS-EXP = (WS-W * 4 + 16) * 1000 + 52
     COMPUTE WS-OBS = SM-W-W(1) * 1000 + SM-W-H(1)
     PERFORM CHK
     MOVE "true" TO WS-OPT-VALUE
     MOVE 4 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
*>   ---- the timers (3.1) ----
     MOVE 3 TO HX-TITLE-TIME
     CALL "HUD-TITLE-TICK" USING CLIENT-STATE
     CALL "HUD-TITLE-TICK" USING CLIENT-STATE
     MOVE "two ticks from 3: titleTime 1, the title is still there" TO WS-NAME
     MOVE 1001 TO WS-EXP
     COMPUTE WS-OBS = HX-TITLE-TIME + HX-TITLE-LENGTH * 500
     COMPUTE WS-OBS = HX-TITLE-TIME + 1000 * (HX-TITLE-LENGTH / 2)
     PERFORM CHK
     CALL "HUD-TITLE-TICK" USING CLIENT-STATE
     MOVE "the tick that reaches 0 clears the title and the subtitle" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = HX-TITLE-TIME + HX-TITLE-LENGTH + HX-SUB-LENGTH
     PERFORM CHK
     MOVE "and the times stay 5, 40, 10" TO WS-NAME
     MOVE 5040010 TO WS-EXP
     COMPUTE WS-OBS = HX-T-IN * 1000000 + HX-T-STAY * 1000 + HX-T-OUT
     PERFORM CHK
*>   a title with zero time stays stored and is never drawn
     MOVE 116 TO WS-ID
     MOVE "Hi" TO WS-PIECE
     MOVE 2 TO WS-PIECE-LEN
     PERFORM SEND-TEXT
     MOVE 114 TO WS-ID
     MOVE "Sub" TO WS-PIECE
     MOVE 3 TO WS-PIECE-LEN
     PERFORM SEND-TEXT
*>   Titles Animation restarts a running title with the new total, and does not change a time that is negative
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE -1 TO WS-INT
     CALL "PB-PUT-INT" USING PB-BUFFER WS-INT
     MOVE 7 TO WS-INT
     CALL "PB-PUT-INT" USING PB-BUFFER WS-INT
     MOVE -5 TO WS-INT
     CALL "PB-PUT-INT" USING PB-BUFFER WS-INT
     MOVE 0 TO PB-POS
     MOVE 117 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "animation -1 7 -5 changes only the stay time; the running title restarts at 5 + 7 + 10" TO WS-NAME
     MOVE 22 TO WS-EXP
     MOVE HX-TITLE-TIME TO WS-OBS
     PERFORM CHK
*>   Clear Titles with reset false and true
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE 0 TO WS-BOOL
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-BOOL
     MOVE 0 TO PB-POS
     MOVE 14 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "Clear Titles (false): the screen is cleared at once, the times stay" TO WS-NAME
     MOVE 5007010 TO WS-EXP
     COMPUTE WS-OBS = HX-T-IN * 1000000 + HX-T-STAY * 1000 + HX-T-OUT + HX-TITLE-TIME + HX-TITLE-LENGTH
     PERFORM CHK
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE 1 TO WS-BOOL
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-BOOL
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "Clear Titles (true): the times are 10, 70, 20 again" TO WS-NAME
     MOVE 10070020 TO WS-EXP
     COMPUTE WS-OBS = HX-T-IN * 1000000 + HX-T-STAY * 1000 + HX-T-OUT
     PERFORM CHK
*>   ---- the action bar (3.4) ----
     MOVE "Bar" TO WS-PIECE
     MOVE 3 TO WS-PIECE-LEN
     MOVE 89 TO WS-ID
     PERFORM SEND-TEXT
     MOVE "Set Action Bar Text: 60 ticks, no animation" TO WS-NAME
     MOVE 60000 TO WS-EXP
     COMPUTE WS-OBS = HX-AB-TIME * 1000 + HX-AB-ANIM
     PERFORM CHK
     COMPUTE CL-NEXT-TICK = CL-NOW-MS + 50
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         EVALUATE WS-I
             WHEN 1 MOVE 60 TO HX-AB-TIME
             WHEN 2 MOVE 40 TO HX-AB-TIME
             WHEN 3 MOVE 20 TO HX-AB-TIME
             WHEN 4 MOVE 19 TO HX-AB-TIME
             WHEN 5 MOVE 15 TO HX-AB-TIME
             WHEN 6 MOVE 10 TO HX-AB-TIME
             WHEN 7 MOVE 5 TO HX-AB-TIME
             WHEN OTHER MOVE 1 TO HX-AB-TIME
         END-EVALUATE
         EVALUATE WS-I
             WHEN 1 MOVE 255 TO WS-EXP
             WHEN 2 MOVE 255 TO WS-EXP
             WHEN 3 MOVE 255 TO WS-EXP
             WHEN 4 MOVE 242 TO WS-EXP
             WHEN 5 MOVE 191 TO WS-EXP
             WHEN 6 MOVE 127 TO WS-EXP
             WHEN 7 MOVE 63 TO WS-EXP
             WHEN OTHER MOVE 12 TO WS-EXP
         END-EVALUATE
         MOVE 0 TO SM-WIDGET-COUNT
         CALL "HUD-ACTIONBAR-ADD" USING CLIENT-STATE WS-GW WS-GH
         MOVE HX-AB-TIME TO WS-D
         MOVE SPACES TO WS-NAME
         STRING "action bar time " WS-D ": alpha" DELIMITED BY SIZE INTO WS-NAME
         MOVE SM-W-ALPHA(1) TO WS-OBS
         PERFORM CHK
     END-PERFORM
     MOVE 30 TO HX-AB-TIME
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "HUD-ACTIONBAR-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "Bar" TO WS-X256
     MOVE 3 TO WS-PIECE-LEN
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-X256 WS-PIECE-LEN WS-W
     COMPUTE WS-HALF = WS-W / 2
     MOVE "the action bar's x is 213 - width / 2 and y is 240 - 68 - 4" TO WS-NAME
     COMPUTE WS-EXP = (213 - WS-HALF) * 1000 + 168
     COMPUTE WS-OBS = SM-W-X(1) * 1000 + SM-W-Y(1)
     PERFORM CHK
     MOVE "the action bar is white" TO WS-NAME
     MOVE 16777215 TO WS-EXP
     MOVE SM-W-COLOUR(1) TO WS-OBS
     PERFORM CHK
     MOVE 0 TO HX-AB-TIME
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "HUD-ACTIONBAR-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "an action bar with no time left draws nothing" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
*>   System Chat with the overlay flag set is the action bar; a tick counts it down and keeps the text
     MOVE "Over" TO WS-PIECE
     MOVE 4 TO WS-PIECE-LEN
     MOVE 124 TO WS-ID
     MOVE 1 TO WS-BOOL
     PERFORM SEND-TEXT-FLAG
     MOVE "System Chat with overlay true: the action bar (60 ticks), no chat line" TO WS-NAME
     MOVE 60000 TO WS-EXP
     COMPUTE WS-OBS = HX-AB-TIME * 1000 + CH-COUNT
     PERFORM CHK
     CALL "HUD-TITLE-TICK" USING CLIENT-STATE
     MOVE "a tick counts it down to 59" TO WS-NAME
     MOVE 59 TO WS-EXP
     MOVE HX-AB-TIME TO WS-OBS
     PERFORM CHK
*>   ---- the rainbow of 3.5 ----
     MOVE 0.5 TO WS-HUE
     CALL "HUD-HSV" USING WS-HUE WS-SAT WS-VAL WS-RGB
     MOVE "hue 0.5: 45 153 153" TO WS-NAME
     MOVE 2988441 TO WS-EXP
     MOVE WS-RGB TO WS-OBS
     PERFORM CHK
     MOVE 0 TO WS-HUE
     CALL "HUD-HSV" USING WS-HUE WS-SAT WS-VAL WS-RGB
     MOVE "hue 0: 153 45 45" TO WS-NAME
     MOVE 10038573 TO WS-EXP
     MOVE WS-RGB TO WS-OBS
     PERFORM CHK
     MOVE 1.1 TO WS-HUE
     CALL "HUD-HSV" USING WS-HUE WS-SAT WS-VAL WS-RGB
     MOVE "hue 1.1 (t 55): the clamped t' gives 153 255 45" TO WS-NAME
     MOVE 10092333 TO WS-EXP
     MOVE WS-RGB TO WS-OBS
     PERFORM CHK
     MOVE 1.18 TO WS-HUE
     CALL "HUD-HSV" USING WS-HUE WS-SAT WS-VAL WS-RGB
     MOVE "hue 1.18 (t 59): the clamped q gives 0 153 45" TO WS-NAME
     MOVE 39213 TO WS-EXP
     MOVE WS-RGB TO WS-OBS
     PERFORM CHK
     MOVE 0.999998 TO WS-HUE
     CALL "HUD-HSV" USING WS-HUE WS-SAT WS-VAL WS-RGB
     MOVE "hue just below 1: 153 45 45" TO WS-NAME
     MOVE 10038573 TO WS-EXP
     MOVE WS-RGB TO WS-OBS
     PERFORM CHK
     MOVE "Playing" TO WS-PIECE
     MOVE 7 TO WS-PIECE-LEN
     MOVE 1 TO WS-ANIMATE
     MOVE SPACES TO WS-TEXT
     MOVE WS-PIECE TO WS-TEXT
     MOVE WS-PIECE-LEN TO WS-LENGTH
     CALL "ACTIONBAR-SET" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-ANIMATE
     MOVE 25 TO HX-AB-TIME
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "HUD-ACTIONBAR-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "the now playing text at t = 25 is drawn in 45 153 153" TO WS-NAME
     MOVE 2988441 TO WS-EXP
     MOVE SM-W-COLOUR(1) TO WS-OBS
     PERFORM CHK
*>   hues of the segments i = 2 and i = 4 (0.34: p v t; 0.67: t p v), from the formulas of 3.5
     MOVE 0.34 TO WS-HUE
     CALL "HUD-HSV" USING WS-HUE WS-SAT WS-VAL WS-RGB
     MOVE "hue 0.34 (segment 2)" TO WS-NAME
     MOVE 2988338 TO WS-EXP
     MOVE WS-RGB TO WS-OBS
     PERFORM CHK
     MOVE 0.67 TO WS-HUE
     CALL "HUD-HSV" USING WS-HUE WS-SAT WS-VAL WS-RGB
     MOVE "hue 0.67 (segment 4)" TO WS-NAME
     MOVE 3157401 TO WS-EXP
     MOVE WS-RGB TO WS-OBS
     PERFORM CHK
*>   the partial tick of a frame: 0 before the first tick, clamped to 0 and 1 (HUD-PARTIAL)
     MOVE 0 TO CL-NEXT-TICK
     CALL "HUD-PARTIAL" USING CLIENT-STATE WS-HUE
     MOVE "no tick yet: partial 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = WS-HUE * 1000
     PERFORM CHK
     COMPUTE CL-NEXT-TICK = CL-NOW-MS + 1000
     CALL "HUD-PARTIAL" USING CLIENT-STATE WS-HUE
     MOVE "a clock before the tick that ran: partial 0" TO WS-NAME
     COMPUTE WS-OBS = WS-HUE * 1000
     PERFORM CHK
     COMPUTE CL-NEXT-TICK = CL-NOW-MS - 1000
     CALL "HUD-PARTIAL" USING CLIENT-STATE WS-HUE
     MOVE "a clock far past the next tick: partial 1" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS = WS-HUE * 1000
     PERFORM CHK
*>   an action bar with t = 0 (time 1, partial 1) draws nothing
     MOVE 1 TO HX-AB-TIME
     MOVE 3 TO HX-AB-LENGTH
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "HUD-ACTIONBAR-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "an action bar whose alpha is 0 draws nothing" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
*>   the title text grows with its scale: the glyph quad of a scale 4 label is four times that of a scale 1 label (vertex level, UI-RENDER)
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE "Hi" TO WS-PIECE
     MOVE 2 TO WS-PIECE-LEN
     MOVE WS-PIECE TO WS-TEXT
     MOVE 0 TO WS-INT
     MOVE WK-LABEL TO WS-KIND
     MOVE 0 TO WS-ID
     MOVE 20 TO WS-W
     MOVE 9 TO WS-W2
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ID WS-INT WS-INT2 WS-INT3 WS-W WS-W2 WS-TEXT WS-PIECE-LEN WS-ZERO-STATE
     MOVE 255 TO WS-INT
     CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-INT
     CALL "UI-RENDER" USING CLIENT-STATE
     COMPUTE WS-QW1 = RL-UI-X(3) - RL-UI-X(1)
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE 0 TO WS-INT
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ID WS-INT WS-INT2 WS-INT3 WS-W WS-W2 WS-TEXT WS-PIECE-LEN WS-ZERO-STATE
     MOVE 255 TO WS-INT
     CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-INT
     MOVE 4 TO WS-INT
     CALL "WIDGET-SCALE" USING CLIENT-STATE WS-INT
     CALL "UI-RENDER" USING CLIENT-STATE
     COMPUTE WS-QW4 = RL-UI-X(3) - RL-UI-X(1)
     MOVE "a scale 4 glyph quad is 4 times as wide as a scale 1 quad (vertex level, thousandths)" TO WS-NAME
     COMPUTE WS-EXP = WS-QW1 * 4000
     COMPUTE WS-OBS = WS-QW4 * 1000
     PERFORM CHK-NEAR
     STOP RUN.

 CHK.
     MOVE WS-NAME TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHK-NEAR.
     COMPUTE WS-DIFF = FUNCTION ABS(WS-EXP - WS-OBS)
     IF WS-DIFF <= 20
         MOVE WS-EXP TO WS-OBS
     END-IF
     PERFORM CHK.

 SEND-TEXT.
     MOVE 0 TO WS-BOOL
     PERFORM SEND-TEXT-FLAG.

*> A packet of id WS-ID whose body is the plain text WS-PIECE and, for System Chat (124), the Boolean WS-BOOL.
 SEND-TEXT-FLAG.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE WS-PIECE TO PB-TX-VALUE
     MOVE WS-PIECE-LEN TO PB-TX-LENGTH
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     IF WS-ID = 124
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-BOOL
     END-IF
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.
 END PROGRAM TEST-HUD-TITLE.

 COPY CLTEST.
