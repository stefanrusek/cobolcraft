*> The title, the subtitle and the action bar (docs/protocol/57-client-closures-5 section 3, task T47410). TITLE-READ handles Set Title Text (id 0x74 = 116), Set Subtitle Text
*> (0x72 = 114), Set Titles Animation (0x75 = 117) and Clear Titles (0x0E = 14): the state HX-TITLE, HX-SUB, HX-TITLE-TIME (ticks left) and the three times HX-T-IN, HX-T-STAY,
*> HX-T-OUT (10, 70, 20 until told; CL-INIT). ACTIONBAR-SET and ACTIONBAR-PACKET (Set Action Bar Text 0x59 = 89; System Chat with the overlay flag) keep HX-AB and
*> HX-AB-TIME (60 ticks) and whether the colour animates (the "now playing" display). HUD-TITLE-TICK is the unpaused client tick, HUD-TITLE-ADD and HUD-ACTIONBAR-ADD build
*> the widgets in the layer order of 57-5 section 1.2 (HUD-BUILD): the action bar, then the title. HUD-HSV is Mth.hsvToArgb of 3.5, HUD-PARTIAL the partial tick of a frame,
*> HUD-BACKDROP-ADD the backdrop of text with background of 3.2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-PARTIAL.
*> USING CLIENT-STATE, partial tick out (FLOAT-LONG 0 to 1): how far the clock is into the 50 ms client tick that last ran (the tick due at CL-NEXT-TICK started 50 ms before it).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PARTIAL              FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PARTIAL.
     COMPUTE L-PARTIAL = (CL-NOW-MS - (CL-NEXT-TICK - 50)) / 50
     IF CL-NEXT-TICK = 0 OR L-PARTIAL < 0
         MOVE 0 TO L-PARTIAL
     END-IF
     IF L-PARTIAL > 1
         MOVE 1 TO L-PARTIAL
     END-IF
     GOBACK.
 END PROGRAM HUD-PARTIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TITLE-READ.
*> USING CLIENT-STATE, PB-BUFFER, packet id (116 title, 114 subtitle, 117 animation, 14 clear): the five packets of 57-5 section 3.1. Set Title Text keeps the text and restarts
*> titleTime at fade in + stay + fade out (the subtitle is kept); Set Subtitle Text keeps only the text; Set Titles Animation (three Ints) replaces each time that is not
*> negative and, when a title runs, restarts it with the new total; Clear Titles (a Boolean) clears both texts and titleTime and, when the Boolean is true, resets the
*> three times to 10, 70, 20.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-STAY                BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER L-ID.
     EVALUATE L-ID
         WHEN 116
             CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
             IF PB-ERROR = 0
                 CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
                 MOVE WS-TEXT(1:256) TO HX-TITLE
                 MOVE FUNCTION MIN(WS-LENGTH, 256) TO HX-TITLE-LENGTH
                 COMPUTE HX-TITLE-TIME = HX-T-IN + HX-T-STAY + HX-T-OUT
             END-IF
         WHEN 114
             CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
             IF PB-ERROR = 0
                 CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
                 MOVE WS-TEXT(1:256) TO HX-SUB
                 MOVE FUNCTION MIN(WS-LENGTH, 256) TO HX-SUB-LENGTH
             END-IF
         WHEN 117
             CALL "PB-GET-INT" USING PB-BUFFER WS-IN
             CALL "PB-GET-INT" USING PB-BUFFER WS-STAY
             CALL "PB-GET-INT" USING PB-BUFFER WS-OUT
             IF PB-ERROR = 0
                 IF WS-IN >= 0
                     MOVE WS-IN TO HX-T-IN
                 END-IF
                 IF WS-STAY >= 0
                     MOVE WS-STAY TO HX-T-STAY
                 END-IF
                 IF WS-OUT >= 0
                     MOVE WS-OUT TO HX-T-OUT
                 END-IF
                 IF HX-TITLE-TIME > 0
                     COMPUTE HX-TITLE-TIME = HX-T-IN + HX-T-STAY + HX-T-OUT
                 END-IF
             END-IF
         WHEN OTHER
             CALL "PB-GET-BOOL" USING PB-BUFFER WS-VALUE
             IF PB-ERROR = 0
                 MOVE 0 TO HX-TITLE-LENGTH HX-SUB-LENGTH HX-TITLE-TIME
                 IF WS-VALUE = 1
                     MOVE 10 TO HX-T-IN
                     MOVE 70 TO HX-T-STAY
                     MOVE 20 TO HX-T-OUT
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM TITLE-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACTIONBAR-SET.
*> USING CLIENT-STATE, text (PIC X(512)), length, animate (1 for the "now playing" display): Hud.setOverlayMessage (57-5 section 3.4): the text is kept, the time is 60 ticks.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 01 L-ANIMATE              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-ANIMATE.
     MOVE L-TEXT(1:256) TO HX-AB
     MOVE FUNCTION MIN(L-LENGTH, 256) TO HX-AB-LENGTH
     MOVE 60 TO HX-AB-TIME
     MOVE L-ANIMATE TO HX-AB-ANIM
     GOBACK.
 END PROGRAM ACTIONBAR-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACTIONBAR-PACKET.
*> USING CLIENT-STATE, PB-BUFFER: Set Action Bar Text (05b 0x59): a text component; the action bar without the colour animation.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ANIMATE             BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
     IF PB-ERROR = 0
         CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
         CALL "ACTIONBAR-SET" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-ANIMATE
     END-IF
     GOBACK.
 END PROGRAM ACTIONBAR-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-TITLE-TICK.
*> USING CLIENT-STATE: one unpaused client tick (57-5 sections 1.3, 3.1, 3.4): titleTime counts down and the title and subtitle go when it reaches 0 (the times stay);
*> the action bar's time counts down (its text is not cleared).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF HX-TITLE-TIME > 0
         SUBTRACT 1 FROM HX-TITLE-TIME
         IF HX-TITLE-TIME <= 0
             MOVE 0 TO HX-TITLE-TIME HX-TITLE-LENGTH HX-SUB-LENGTH
         END-IF
     END-IF
     IF HX-AB-TIME > 0
         SUBTRACT 1 FROM HX-AB-TIME
     END-IF
     GOBACK.
 END PROGRAM HUD-TITLE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-HSV.
*> USING hue (FLOAT-LONG), saturation, value, RGB out (BINARY-LONG, red * 65536 + green * 256 + blue): Mth.hsvToArgb of 57-5 section 3.5: i = trunc(h x 6) mod 6, f = h x 6 - i (the
*> reduced i, the unreduced product), p = v (1 - s), q = v (1 - f s), t = v (1 - (1 - f) s); (r, g, b) by i: 0 (v, t, p), 1 (q, v, p), 2 (p, v, t), 3 (p, q, v), 4 (t, p, v),
*> 5 (v, p, q); each channel is clamp(trunc(channel x 255), 0, 255).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H6                  FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-RI                  BINARY-LONG.
 01 WS-GI                  BINARY-LONG.
 01 WS-BI                  BINARY-LONG.
 01 WS-TRUNC               BINARY-LONG.
 LINKAGE SECTION.
 01 L-H                    FLOAT-LONG.
 01 L-S                    FLOAT-LONG.
 01 L-V                    FLOAT-LONG.
 01 L-RGB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-H L-S L-V L-RGB.
     COMPUTE WS-H6 = L-H * 6
     COMPUTE WS-TRUNC = FUNCTION INTEGER-PART(WS-H6)
     COMPUTE WS-I = FUNCTION MOD(WS-TRUNC, 6)
     COMPUTE WS-F = WS-H6 - WS-I
     COMPUTE WS-P = L-V * (1 - L-S)
     COMPUTE WS-Q = L-V * (1 - WS-F * L-S)
     COMPUTE WS-T = L-V * (1 - (1 - WS-F) * L-S)
     EVALUATE WS-I
         WHEN 0
             MOVE L-V TO WS-R
             MOVE WS-T TO WS-G
             MOVE WS-P TO WS-B
         WHEN 1
             MOVE WS-Q TO WS-R
             MOVE L-V TO WS-G
             MOVE WS-P TO WS-B
         WHEN 2
             MOVE WS-P TO WS-R
             MOVE L-V TO WS-G
             MOVE WS-T TO WS-B
         WHEN 3
             MOVE WS-P TO WS-R
             MOVE WS-Q TO WS-G
             MOVE L-V TO WS-B
         WHEN 4
             MOVE WS-T TO WS-R
             MOVE WS-P TO WS-G
             MOVE L-V TO WS-B
         WHEN OTHER
             MOVE L-V TO WS-R
             MOVE WS-P TO WS-G
             MOVE WS-Q TO WS-B
     END-EVALUATE
     COMPUTE WS-RI = FUNCTION INTEGER-PART(WS-R * 255)
     COMPUTE WS-GI = FUNCTION INTEGER-PART(WS-G * 255)
     COMPUTE WS-BI = FUNCTION INTEGER-PART(WS-B * 255)
     MOVE FUNCTION MAX(0, FUNCTION MIN(255, WS-RI)) TO WS-RI
     MOVE FUNCTION MAX(0, FUNCTION MIN(255, WS-GI)) TO WS-GI
     MOVE FUNCTION MAX(0, FUNCTION MIN(255, WS-BI)) TO WS-BI
     COMPUTE L-RGB = WS-RI * 65536 + WS-GI * 256 + WS-BI
     GOBACK.
 END PROGRAM HUD-HSV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-BACKDROP-ADD.
*> USING CLIENT-STATE, x0, y0, x1, y1 (GUI pixels of the corners), text alpha (1 to 255): GuiGraphicsExtractor.textWithBackdrop (57-5 section 3.2): when the option Text Background is
*> Everywhere (backgroundForChatOnly false) a black rectangle of alpha floor(255 x textBackgroundOpacity) times the text's alpha / 255; with the default (chat only) nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-N-CHAT              PIC X(40) VALUE "backgroundForChatOnly".
 01 WS-N-OPACITY           PIC X(40) VALUE "textBackgroundOpacity".
 01 WS-D-HALF              FLOAT-LONG VALUE 0.5.
 01 WS-CHAT-ONLY           BINARY-LONG.
 01 WS-DEFAULT-ONE         BINARY-LONG VALUE 1.
 01 WS-OPACITY             FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-OVERLAY.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-BLACK               BINARY-LONG VALUE SW-BLACK.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-EMPTY               PIC X(512) VALUE SPACES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-ALPHA                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X0 L-Y0 L-X1 L-Y1 L-ALPHA.
     CALL "CHAT-OPT-FLAG" USING CLIENT-STATE WS-N-CHAT WS-DEFAULT-ONE WS-CHAT-ONLY
     IF WS-CHAT-ONLY = 0
         CALL "CHAT-OPT" USING CLIENT-STATE WS-N-OPACITY WS-D-HALF WS-OPACITY
         COMPUTE WS-A = FUNCTION INTEGER(255 * WS-OPACITY) * L-ALPHA / 255
         IF WS-A > 0
             MOVE L-X0 TO WS-X
             MOVE L-Y0 TO WS-Y
             COMPUTE WS-W = L-X1 - L-X0
             COMPUTE WS-H = L-Y1 - L-Y0
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-BLACK WS-X WS-Y WS-W WS-H WS-EMPTY WS-Z WS-Z2
             CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-A
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HUD-BACKDROP-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-TITLE-ADD.
*> USING CLIENT-STATE, GUI width, GUI height: Hud.extractTitle (57-5 section 3.2): drawn while a title exists and titleTime > 0, with t = titleTime - the partial tick. alpha =
*> 255, but trunc((in + stay + out - t) x 255 / in) while the integer titleTime is above out + stay and trunc(t x 255 / out) while it is out or less, clamped to 0 to 255 (none
*> drawn for 0). The pose goes to the centre of the screen (W / 2, H / 2 by integer division): the title at scale 4, x = -w / 2 (truncating) and y = -10 in scaled units,
*> the subtitle (when set) at scale 2, x = -w / 2 and y = 5; white with the alpha, with the shadow, over the backdrop of text with background.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-PARTIAL             FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-ALPHA               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-SCALE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-LABEL.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT256             PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WHITE               BINARY-LONG VALUE 16777215.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     IF HX-TITLE-LENGTH = 0 OR HX-TITLE-TIME <= 0
         GOBACK
     END-IF
     CALL "HUD-PARTIAL" USING CLIENT-STATE WS-PARTIAL
     COMPUTE WS-T = HX-TITLE-TIME - WS-PARTIAL
     MOVE 255 TO WS-ALPHA
     IF HX-TITLE-TIME > HX-T-OUT + HX-T-STAY
         COMPUTE WS-ALPHA = (HX-T-IN + HX-T-STAY + HX-T-OUT - WS-T) * 255 / HX-T-IN
     ELSE
         IF HX-TITLE-TIME <= HX-T-OUT
             COMPUTE WS-ALPHA = WS-T * 255 / HX-T-OUT
         END-IF
     END-IF
     MOVE FUNCTION MAX(0, FUNCTION MIN(255, WS-ALPHA)) TO WS-ALPHA
     IF WS-ALPHA <= 0
         GOBACK
     END-IF
     COMPUTE WS-CX = L-GW / 2
     COMPUTE WS-CY = L-GH / 2
     MOVE SPACES TO WS-TEXT
     MOVE HX-TITLE TO WS-TEXT256
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 HX-TITLE-LENGTH WS-WIDTH
     COMPUTE WS-HALF = WS-WIDTH / 2
     MOVE 4 TO WS-SCALE
     COMPUTE WS-X = WS-CX - WS-SCALE * WS-HALF
     COMPUTE WS-Y = WS-CY - WS-SCALE * 10
     COMPUTE WS-X1 = WS-X + WS-SCALE * WS-WIDTH
     COMPUTE WS-Y1 = WS-Y + WS-SCALE * 9
     COMPUTE WS-W = WS-X - 2 * WS-SCALE
     COMPUTE WS-H = WS-Y - 2 * WS-SCALE
     COMPUTE WS-X1 = WS-X1 + 2 * WS-SCALE
     COMPUTE WS-Y1 = WS-Y1 + 2 * WS-SCALE
     CALL "HUD-BACKDROP-ADD" USING CLIENT-STATE WS-W WS-H WS-X1 WS-Y1 WS-ALPHA
     MOVE HX-TITLE TO WS-TEXT
     MOVE HX-TITLE-LENGTH TO WS-LENGTH
     COMPUTE WS-W = WS-WIDTH * WS-SCALE
     COMPUTE WS-H = 9 * WS-SCALE
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-Z2
     CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-WHITE
     CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-ALPHA
     CALL "WIDGET-SCALE" USING CLIENT-STATE WS-SCALE
     IF HX-SUB-LENGTH > 0
         MOVE HX-SUB TO WS-TEXT256
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 HX-SUB-LENGTH WS-WIDTH
         COMPUTE WS-HALF = WS-WIDTH / 2
         MOVE 2 TO WS-SCALE
         COMPUTE WS-X = WS-CX - WS-SCALE * WS-HALF
         COMPUTE WS-Y = WS-CY + WS-SCALE * 5
         COMPUTE WS-W = WS-X - 2 * WS-SCALE
         COMPUTE WS-H = WS-Y - 2 * WS-SCALE
         COMPUTE WS-X1 = WS-X + WS-SCALE * WS-WIDTH + 2 * WS-SCALE
         COMPUTE WS-Y1 = WS-Y + WS-SCALE * 9 + 2 * WS-SCALE
         CALL "HUD-BACKDROP-ADD" USING CLIENT-STATE WS-W WS-H WS-X1 WS-Y1 WS-ALPHA
         MOVE SPACES TO WS-TEXT
         MOVE HX-SUB TO WS-TEXT
         MOVE HX-SUB-LENGTH TO WS-LENGTH
         COMPUTE WS-W = WS-WIDTH * WS-SCALE
         COMPUTE WS-H = 9 * WS-SCALE
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-Z2
         CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-WHITE
         CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-ALPHA
         CALL "WIDGET-SCALE" USING CLIENT-STATE WS-SCALE
     END-IF
     GOBACK.
 END PROGRAM HUD-TITLE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-ACTIONBAR-ADD.
*> USING CLIENT-STATE, GUI width, GUI height: Hud.extractOverlayMessage (57-5 section 3.4): drawn while the action bar has a text and its time is above 0, with t = time - the partial
*> tick; alpha = min(255, trunc(t x 255 / 20)) (none for 0 or less). The pose goes to (W / 2, H - 68); the text at x = -w / 2 (truncating), y = -4, scale 1, with the shadow and
*> the backdrop. The colour is white with the alpha, or, for the "now playing" display (animate), hsvToArgb(t / 50, 0.7, 0.6) with the alpha (3.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-PARTIAL             FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-ALPHA               BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-LABEL.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT256             PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-RGB                 BINARY-LONG.
 01 WS-HUE                 FLOAT-LONG.
 01 WS-SAT                 FLOAT-LONG VALUE 0.7.
 01 WS-VAL                 FLOAT-LONG VALUE 0.6.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     IF HX-AB-LENGTH = 0 OR HX-AB-TIME <= 0
         GOBACK
     END-IF
     CALL "HUD-PARTIAL" USING CLIENT-STATE WS-PARTIAL
     COMPUTE WS-T = HX-AB-TIME - WS-PARTIAL
     COMPUTE WS-ALPHA = WS-T * 255 / 20
     MOVE FUNCTION MIN(255, WS-ALPHA) TO WS-ALPHA
     IF WS-ALPHA <= 0
         GOBACK
     END-IF
     MOVE 16777215 TO WS-RGB
     IF HX-AB-ANIM = 1
         COMPUTE WS-HUE = WS-T / 50
         CALL "HUD-HSV" USING WS-HUE WS-SAT WS-VAL WS-RGB
     END-IF
     MOVE HX-AB TO WS-TEXT256
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 HX-AB-LENGTH WS-WIDTH
     COMPUTE WS-HALF = WS-WIDTH / 2
     COMPUTE WS-X = L-GW / 2 - WS-HALF
     COMPUTE WS-Y = L-GH - 68 - 4
     COMPUTE WS-W = WS-X - 2
     COMPUTE WS-H = WS-Y - 2
     COMPUTE WS-X1 = WS-X + WS-WIDTH + 2
     COMPUTE WS-Y1 = WS-Y + 9 + 2
     CALL "HUD-BACKDROP-ADD" USING CLIENT-STATE WS-W WS-H WS-X1 WS-Y1 WS-ALPHA
     MOVE SPACES TO WS-TEXT
     MOVE HX-AB TO WS-TEXT
     MOVE HX-AB-LENGTH TO WS-LENGTH
     MOVE WS-WIDTH TO WS-W
     MOVE 9 TO WS-H
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-Z2
     CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-RGB
     CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-ALPHA
     GOBACK.
 END PROGRAM HUD-ACTIONBAR-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-RESET.
*> USING CLIENT-STATE: Hud.onDisconnected (57-5 section 1.3): the boss bars, the chat lines and the delay queue, the title and subtitle go and the title times are 10, 70, 20 again; the
*> action bar goes too. The scoreboard of the connection (objectives, scores, display slots, teams) is dropped with the connection.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         INITIALIZE HX-BB(WS-I)
     END-PERFORM
     MOVE 0 TO HX-BB-COUNT HX-BB-DARK HX-BB-DARK-O
     MOVE 0 TO CH-COUNT CH-SCROLL HX-DQ-COUNT HX-CHAT-PREV-MS
     MOVE 0 TO HX-TITLE-LENGTH HX-SUB-LENGTH HX-TITLE-TIME HX-AB-LENGTH HX-AB-TIME HX-AB-ANIM
     MOVE 10 TO HX-T-IN
     MOVE 70 TO HX-T-STAY
     MOVE 20 TO HX-T-OUT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         INITIALIZE HX-SO(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         INITIALIZE HX-SS(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         MOVE 0 TO HX-SLOT(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         INITIALIZE HX-TM(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         INITIALIZE HX-TP(WS-I)
     END-PERFORM
     MOVE 0 TO HX-SO-COUNT HX-SS-COUNT HX-TM-COUNT
     GOBACK.
 END PROGRAM HUD-RESET.
