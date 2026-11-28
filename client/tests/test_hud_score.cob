*> Implementation test of docs/protocol/57-client-closures-5 section 5 (task T47430): the scoreboard. The five packets (add, change and remove of an objective, an objective added
*> twice ends the connection, display slots with the empty and the unknown name, Set Score assigning value, display and number format, Reset Score with and without an objective,
*> the team methods add, join, leave, change, remove, a leave of a name that is not in the team ends the connection) and the sidebar of 5.4: entries sorted by value descending and by
*> name ascending ignoring case, hidden owners (#) left out, at most 15, the red default numbers, the number formats blank, styled and fixed, the team prefix, suffix and colour of
*> a name, the objective of the colour slot of the local player's team, and the geometry from the measured glyph widths (totalH = 9 n, bottom = H / 2 + totalH / 3, left = W - maxW - 3,
*> right = W - 1, strip alpha 102 and body alpha 76).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HUD-SCORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-HEX                 PIC X(400).
 01 WS-HEX-LEN             BINARY-LONG.
 01 WS-HP                  BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-ONE-BYTE            PIC X.
 01 WS-ONE-COUNT           BINARY-LONG.
 01 WS-SERVER              BINARY-LONG.
 01 WS-NAME                PIC X(200).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 2048.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-ID                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG VALUE 427.
 01 WS-GH                  BINARY-LONG VALUE 240.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PIECE               PIC X(64).
 01 WS-PIECE-LEN           BINARY-LONG.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-VALUE               BINARY-LONG.
 01 WS-METHOD              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-OWNER               PIC X(64).
 01 WS-OWNER-LEN           BINARY-LONG.
 01 WS-OBJ                 PIC X(64).
 01 WS-OBJ-LEN             BINARY-LONG.
 01 WS-TITLE               PIC X(64).
 01 WS-TITLE-LEN           BINARY-LONG.
 01 WS-FMT                 BINARY-LONG.
 01 WS-STYLE-HEX           PIC X(100).
 01 WS-FIXED               PIC X(64).
 01 WS-FIXED-LEN           BINARY-LONG.
 01 WS-DISPLAY             PIC X(64).
 01 WS-DISPLAY-LEN         BINARY-LONG.
 01 WS-W-NAME-1            BINARY-LONG.
 01 WS-X256                PIC X(256).
 01 WS-LEN                 BINARY-LONG.
 01 WS-MAXW                BINARY-LONG.
 01 WS-TW                  BINARY-LONG.
 01 WS-COLON-W             BINARY-LONG.
 01 WS-NW                  BINARY-LONG.
 01 WS-SW                  BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-LABELS              BINARY-LONG.
 01 WS-LB                  BINARY-LONG OCCURS 64 TIMES.
 01 WS-N2                  PIC 99.
 01 WS-HA                  BINARY-LONG.
 01 WS-HB                  BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-TEAM-COLOUR         BINARY-LONG.
 01 WS-PLAYERS             BINARY-LONG.
 01 WS-PLAYER-1            PIC X(64).
 01 WS-PLAYER-1-LEN        BINARY-LONG.
 01 WS-PLAYER-2            PIC X(64).
 01 WS-PLAYER-2-LEN        BINARY-LONG.
 01 WS-PREFIX              PIC X(64).
 01 WS-PREFIX-LEN          BINARY-LONG.
 01 WS-SUFFIX              PIC X(64).
 01 WS-SUFFIX-LEN          BINARY-LONG.
 01 WS-COLOUR-OBS          BINARY-LONG.
 01 WS-STYLE-RGB           BINARY-LONG.
 01 WS-OPT-NAME            PIC X(40).
 01 WS-OPT-VALUE           PIC X(4096).
 01 WS-OPT-LENGTH          BINARY-LONG.
 01 WS-OPT-OK              BINARY-LONG.
 01 WS-N3                  PIC 999.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
*>   ---- objectives and slots ----
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     MOVE "Kills" TO WS-TITLE
     MOVE 5 TO WS-TITLE-LEN
     MOVE 0 TO WS-METHOD
     MOVE -1 TO WS-FMT
     PERFORM SEND-OBJECTIVE
     MOVE "Set Objective add: the objective is kept (row 1)" TO WS-NAME
     MOVE 1001 TO WS-EXP
     COMPUTE WS-OBS = HX-SO-USED(1) * 1000 + HX-SO-NAME-LEN(1) - 4
     PERFORM CHK
     MOVE 1 TO WS-VALUE
     MOVE "kills" TO WS-OBJ
     PERFORM SEND-DISPLAY
     MOVE "Set Display Objective slot 1 (sidebar) shows the objective" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE HX-SLOT(2) TO WS-OBS
     PERFORM CHK
     MOVE "nosuch" TO WS-OBJ
     MOVE 6 TO WS-OBJ-LEN
     MOVE 0 TO WS-VALUE
     PERFORM SEND-DISPLAY
     MOVE "an unknown objective name clears slot 0 (list)" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-SLOT(1) TO WS-OBS
     PERFORM CHK
     MOVE 77 TO WS-VALUE
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     PERFORM SEND-DISPLAY
     MOVE "a slot id out of range reads as 0 (list)" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE HX-SLOT(1) TO WS-OBS
     PERFORM CHK
     MOVE SPACES TO WS-OBJ
     MOVE 0 TO WS-OBJ-LEN
     PERFORM SEND-DISPLAY
     MOVE "the empty name means no objective" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-SLOT(1) TO WS-OBS
     PERFORM CHK
*>   ---- scores: Bob 12, Alice 7, Dan 7, Cy 6, #hidden 99 ----
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     MOVE "Bob" TO WS-OWNER
     MOVE 3 TO WS-OWNER-LEN
     MOVE 12 TO WS-VALUE
     PERFORM SEND-SCORE
     MOVE "Alice" TO WS-OWNER
     MOVE 5 TO WS-OWNER-LEN
     MOVE 7 TO WS-VALUE
     PERFORM SEND-SCORE
     MOVE "Dan" TO WS-OWNER
     MOVE 3 TO WS-OWNER-LEN
     PERFORM SEND-SCORE
     MOVE "Cy" TO WS-OWNER
     MOVE 2 TO WS-OWNER-LEN
     MOVE 6 TO WS-VALUE
     PERFORM SEND-SCORE
     MOVE "#hidden" TO WS-OWNER
     MOVE 7 TO WS-OWNER-LEN
     MOVE 99 TO WS-VALUE
     PERFORM SEND-SCORE
     MOVE "five scores are kept" TO WS-NAME
     MOVE 5 TO WS-EXP
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         ADD HX-SS-USED(WS-I) TO WS-OBS
     END-PERFORM
     PERFORM CHK
     MOVE "nosuch" TO WS-OBJ
     MOVE 6 TO WS-OBJ-LEN
     MOVE "Zed" TO WS-OWNER
     MOVE 3 TO WS-OWNER-LEN
     PERFORM SEND-SCORE
     MOVE "Set Score of an unknown objective is ignored" TO WS-NAME
     MOVE 5 TO WS-EXP
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         ADD HX-SS-USED(WS-I) TO WS-OBS
     END-PERFORM
     PERFORM CHK
     MOVE 1 TO WS-VALUE
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     PERFORM SEND-DISPLAY
*>   ---- the sidebar of 5.4 ----
     PERFORM BUILD
     MOVE "the sidebar: two backgrounds, the title and four entries with a score each: 11 widgets" TO WS-NAME
     MOVE 11 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
     MOVE ":" TO WS-X256
     MOVE 1 TO WS-LEN
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-X256 WS-LEN WS-COLON-W
     MOVE "Kills" TO WS-X256
     MOVE 5 TO WS-LEN
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-X256 WS-LEN WS-TW
     MOVE WS-TW TO WS-MAXW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE "Bob" TO WS-X256
             WHEN 2 MOVE "Alice" TO WS-X256
             WHEN 3 MOVE "Dan" TO WS-X256
             WHEN OTHER MOVE "Cy" TO WS-X256
         END-EVALUATE
         EVALUATE WS-I
             WHEN 1 MOVE 3 TO WS-LEN
             WHEN 2 MOVE 5 TO WS-LEN
             WHEN 3 MOVE 3 TO WS-LEN
             WHEN OTHER MOVE 2 TO WS-LEN
         END-EVALUATE
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-X256 WS-LEN WS-NW
         EVALUATE WS-I
             WHEN 1 MOVE "12" TO WS-X256
             WHEN 2 MOVE "7" TO WS-X256
             WHEN 3 MOVE "7" TO WS-X256
             WHEN OTHER MOVE "6" TO WS-X256
         END-EVALUATE
         MOVE 1 TO WS-LEN
         IF WS-I = 1
             MOVE 2 TO WS-LEN
         END-IF
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-X256 WS-LEN WS-SW
         MOVE FUNCTION MAX(WS-MAXW, WS-NW + WS-COLON-W + WS-SW) TO WS-MAXW
     END-PERFORM
     COMPUTE WS-TOTAL = 4 * 9
     COMPUTE WS-HA = WS-TOTAL / 3
     COMPUTE WS-BOTTOM = 120 + WS-HA
     COMPUTE WS-TOP = WS-BOTTOM - WS-TOTAL
     COMPUTE WS-LEFT = 427 - WS-MAXW - 3
     COMPUTE WS-RIGHT = 427 - 3 + 2
     MOVE "the title strip: x left - 2, y top - 10, to x right, 9 high, alpha 102" TO WS-NAME
     COMPUTE WS-EXP = (WS-LEFT - 2) * 1000000 + (WS-TOP - 10) * 1000 + 102
     COMPUTE WS-OBS = SM-W-X(1) * 1000000 + SM-W-Y(1) * 1000 + SM-W-ALPHA(1)
     PERFORM CHK
     MOVE "the strip is right - (left - 2) wide and 9 high" TO WS-NAME
     COMPUTE WS-EXP = (WS-RIGHT - WS-LEFT + 2) * 1000 + 9
     COMPUTE WS-OBS = SM-W-W(1) * 1000 + SM-W-H(1)
     PERFORM CHK
     MOVE "the body: y top - 1 to bottom, alpha 76" TO WS-NAME
     COMPUTE WS-EXP = (WS-TOP - 1) * 100000 + (WS-BOTTOM - WS-TOP + 1) * 100 + 76
     COMPUTE WS-OBS = SM-W-Y(2) * 100000 + SM-W-H(2) * 100 + SM-W-ALPHA(2)
     PERFORM CHK
     MOVE "the title: x left + maxW / 2 - titleWidth / 2, y top - 9, no shadow (state 9)" TO WS-NAME
     COMPUTE WS-HA = WS-MAXW / 2
     COMPUTE WS-HB = WS-TW / 2
     COMPUTE WS-EXP = (WS-LEFT + WS-HA - WS-HB) * 10000 + (WS-TOP - 9) * 10 + 9
     COMPUTE WS-OBS = SM-W-X(3) * 10000 + SM-W-Y(3) * 10 + SM-W-STATE(3)
     PERFORM CHK
     MOVE "entry 1 is Bob at x left, y bottom - 4 x 9" TO WS-NAME
     COMPUTE WS-EXP = WS-LEFT * 1000 + WS-BOTTOM - 36
     COMPUTE WS-OBS = SM-W-X(4) * 1000 + SM-W-Y(4)
     PERFORM CHK
     MOVE "T" TO TL-MODE
     MOVE "the first entry's name" TO TL-CASE
     MOVE "Bob" TO TL-EXPECTED
     MOVE SM-W-TEXT(4)(1:3) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "its score 12" TO TL-CASE
     MOVE "12" TO TL-EXPECTED
     MOVE SM-W-TEXT(5)(1:2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "12" TO WS-X256
     MOVE 2 TO WS-LEN
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-X256 WS-LEN WS-SW
     MOVE "the score is at x right - scoreWidth" TO WS-NAME
     COMPUTE WS-EXP = WS-RIGHT - WS-SW
     MOVE SM-W-X(5) TO WS-OBS
     PERFORM CHK
     MOVE "the default score colour is red FF5555" TO WS-NAME
     MOVE 16733525 TO WS-EXP
     MOVE SM-W-COLOUR(5) TO WS-OBS
     PERFORM CHK
     MOVE "the order after Bob: Alice, Dan (equal values by name), Cy; the hidden owner is not there" TO WS-NAME
     MOVE 0 TO WS-OBS
     MOVE 0 TO WS-LABELS
     PERFORM VARYING WS-I FROM 4 BY 2 UNTIL WS-I > SM-WIDGET-COUNT
         ADD 1 TO WS-LABELS
         EVALUATE WS-LABELS
             WHEN 1
                 IF SM-W-TEXT(WS-I)(1:3) = "Bob"
                     ADD 1 TO WS-OBS
                 END-IF
             WHEN 2
                 IF SM-W-TEXT(WS-I)(1:5) = "Alice"
                     ADD 1 TO WS-OBS
                 END-IF
             WHEN 3
                 IF SM-W-TEXT(WS-I)(1:3) = "Dan"
                     ADD 1 TO WS-OBS
                 END-IF
             WHEN OTHER
                 IF SM-W-TEXT(WS-I)(1:2) = "Cy"
                     ADD 1 TO WS-OBS
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE 4 TO WS-EXP
     PERFORM CHK
*>   ---- number formats (5.4): blank, fixed, styled ----
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     MOVE "Kills" TO WS-TITLE
     MOVE 5 TO WS-TITLE-LEN
     MOVE 2 TO WS-METHOD
     MOVE 0 TO WS-FMT
     PERFORM SEND-OBJECTIVE
     PERFORM BUILD
     MOVE "objective number format blank: no score labels (3 + 4 widgets)" TO WS-NAME
     MOVE 7 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 1 TO WS-FMT
     MOVE "0A 08 00 05 63 6F 6C 6F 72 00 04 67 6F 6C 64 00" TO WS-STYLE-HEX
     PERFORM SEND-OBJECTIVE
     PERFORM BUILD
     MOVE "objective number format styled gold: the scores are FFAA00" TO WS-NAME
     MOVE 16755200 TO WS-EXP
     MOVE SM-W-COLOUR(5) TO WS-OBS
     PERFORM CHK
*>   a score's own format beats the objective's: Bob shows a fixed text
     MOVE "Bob" TO WS-OWNER
     MOVE 3 TO WS-OWNER-LEN
     MOVE 12 TO WS-VALUE
     MOVE 2 TO WS-FMT
     MOVE "xx" TO WS-FIXED
     MOVE 2 TO WS-FIXED-LEN
     MOVE 0 TO WS-PRESENT
     PERFORM SEND-SCORE-FORMAT
     PERFORM BUILD
     MOVE "T" TO TL-MODE
     MOVE "a score's fixed format shows its text, not the number" TO TL-CASE
     MOVE "xx" TO TL-EXPECTED
     MOVE SM-W-TEXT(5)(1:2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE -1 TO WS-FMT
     PERFORM SEND-SCORE-FORMAT
*>   a display text replaces the owner's name
     MOVE 1 TO WS-PRESENT
     MOVE "Bobby" TO WS-DISPLAY
     MOVE 5 TO WS-DISPLAY-LEN
     PERFORM SEND-SCORE-FORMAT
     PERFORM BUILD
     MOVE "T" TO TL-MODE
     MOVE "a score's display text replaces the owner" TO TL-CASE
     MOVE "Bobby" TO TL-EXPECTED
     MOVE SM-W-TEXT(4)(1:5) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-PRESENT
     PERFORM SEND-SCORE-FORMAT
*>   a styled number format with no colour is white; the options Everywhere give the backgrounds the text background opacity
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     MOVE "Kills" TO WS-TITLE
     MOVE 5 TO WS-TITLE-LEN
     MOVE 2 TO WS-METHOD
     MOVE 1 TO WS-FMT
     MOVE "0A 00" TO WS-STYLE-HEX
     PERFORM SEND-OBJECTIVE
     PERFORM BUILD
     MOVE "a styled format without a colour: white (16777215)" TO WS-NAME
     MOVE 16777215 TO WS-EXP
     MOVE SM-W-COLOUR(5) TO WS-OBS
     PERFORM CHK
     MOVE -1 TO WS-FMT
     PERFORM SEND-OBJECTIVE
     MOVE "backgroundForChatOnly" TO WS-OPT-NAME
     MOVE "false" TO WS-OPT-VALUE
     MOVE 5 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
     PERFORM BUILD
     MOVE "text background Everywhere: both backgrounds take alpha floor(255 x 0.5) = 127" TO WS-NAME
     MOVE 127127 TO WS-EXP
     COMPUTE WS-OBS = SM-W-ALPHA(1) * 1000 + SM-W-ALPHA(2)
     PERFORM CHK
     MOVE "true" TO WS-OPT-VALUE
     MOVE 4 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
*>   at most 15 entries: 20 scores of another objective, the lowest five are cut
     MOVE "many" TO WS-OBJ
     MOVE 4 TO WS-OBJ-LEN
     MOVE "Many" TO WS-TITLE
     MOVE 4 TO WS-TITLE-LEN
     MOVE 0 TO WS-METHOD
     MOVE -1 TO WS-FMT
     PERFORM SEND-OBJECTIVE
     MOVE 1 TO WS-VALUE
     PERFORM SEND-DISPLAY
     MOVE 3 TO WS-OWNER-LEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-N2
         MOVE SPACES TO WS-OWNER
         STRING "n" WS-N2 DELIMITED BY SIZE INTO WS-OWNER
         MOVE WS-I TO WS-VALUE
         PERFORM SEND-SCORE
     END-PERFORM
     MOVE "AA" TO WS-OWNER
     MOVE 2 TO WS-OWNER-LEN
     MOVE 20 TO WS-VALUE
     PERFORM SEND-SCORE
     MOVE 3 TO WS-OWNER-LEN
     PERFORM BUILD
     MOVE "20 scores and AA: 15 entries of two labels, a title and the two backgrounds: 33 widgets" TO WS-NAME
     MOVE 33 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "T" TO TL-MODE
     MOVE "equal highest scores go by name ignoring case: AA before n20" TO TL-CASE
     MOVE "AA" TO TL-EXPECTED
     MOVE SM-W-TEXT(4)(1:2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "then n20" TO TL-CASE
     MOVE "n20" TO TL-EXPECTED
     MOVE SM-W-TEXT(6)(1:3) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "the lowest entry kept is n07" TO TL-CASE
     MOVE "n07" TO TL-EXPECTED
     MOVE SM-W-TEXT(SM-WIDGET-COUNT - 1)(1:3) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     MOVE 1 TO WS-VALUE
     PERFORM SEND-DISPLAY
*>   ---- teams (5.2, 5.3) ----
     MOVE 0 TO WS-FMT
     MOVE 5 TO WS-METHOD
     MOVE 2 TO WS-METHOD
     PERFORM SEND-OBJECTIVE
     MOVE "red" TO WS-OBJ
     MOVE 3 TO WS-OBJ-LEN
     MOVE 0 TO WS-METHOD
     MOVE "[R] " TO WS-PREFIX
     MOVE 4 TO WS-PREFIX-LEN
     MOVE "!" TO WS-SUFFIX
     MOVE 1 TO WS-SUFFIX-LEN
     MOVE 12 TO WS-TEAM-COLOUR
     MOVE 1 TO WS-PLAYERS
     MOVE "Bob" TO WS-PLAYER-1
     MOVE 3 TO WS-PLAYER-1-LEN
     PERFORM SEND-TEAM
     MOVE "Set Player Team add: the team and its member are kept" TO WS-NAME
     MOVE 1012 TO WS-EXP
     COMPUTE WS-OBS = HX-TM-USED(1) * 1000 + HX-TM-COLOUR(1)
     PERFORM CHK
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     MOVE "Kills" TO WS-TITLE
     MOVE 5 TO WS-TITLE-LEN
     MOVE 2 TO WS-METHOD
     MOVE -1 TO WS-FMT
     PERFORM SEND-OBJECTIVE
     PERFORM BUILD
     MOVE "T" TO TL-MODE
     MOVE "a team member's name is prefix + name + suffix" TO TL-CASE
     MOVE "[R] Bob!" TO TL-EXPECTED
     MOVE SM-W-TEXT(4)(1:8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "and it is in the team colour red (FF5555)" TO WS-NAME
     MOVE 16733525 TO WS-EXP
     MOVE SM-W-COLOUR(4) TO WS-OBS
     PERFORM CHK
*>   the local player's team colour slot (3 + 12 = 15 -> HX-SLOT(16)) is tried first
     MOVE "team" TO WS-OBJ
     MOVE 4 TO WS-OBJ-LEN
     MOVE "Team" TO WS-TITLE
     MOVE 4 TO WS-TITLE-LEN
     MOVE 0 TO WS-METHOD
     MOVE 0 TO WS-FMT
     PERFORM SEND-OBJECTIVE
     MOVE 15 TO WS-VALUE
     PERFORM SEND-DISPLAY
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE 0 TO WS-METHOD
     MOVE 3 TO WS-METHOD
     MOVE "red" TO WS-OBJ
     MOVE 3 TO WS-OBJ-LEN
     MOVE 1 TO WS-PLAYERS
     MOVE "Alice" TO WS-PLAYER-1
     MOVE 5 TO WS-PLAYER-1-LEN
     PERFORM SEND-TEAM
     MOVE "Set Player Team join: the local player is in the red team" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         IF HX-TP-TEAM(WS-I) = 1 AND HX-TP-NAME(WS-I)(1:5) = "Alice"
             MOVE 1 TO WS-OBS
         END-IF
     END-PERFORM
     PERFORM CHK
     MOVE "team" TO WS-OBJ
     MOVE 4 TO WS-OBJ-LEN
     MOVE "Zed" TO WS-OWNER
     MOVE 3 TO WS-OWNER-LEN
     MOVE 5 TO WS-VALUE
     PERFORM SEND-SCORE
     PERFORM BUILD
     MOVE "T" TO TL-MODE
     MOVE "the team's colour slot shows its own objective: its title and entry" TO TL-CASE
     MOVE "Team" TO TL-EXPECTED
     MOVE SM-W-TEXT(3)(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Set Player Team change and remove; Reset Score
     MOVE 2 TO WS-METHOD
     MOVE "red" TO WS-OBJ
     MOVE 3 TO WS-OBJ-LEN
     MOVE "[X] " TO WS-PREFIX
     PERFORM SEND-TEAM
     MOVE "Set Player Team change: the prefix is replaced" TO WS-NAME
     MOVE "[X] " TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     MOVE HX-TM-PREFIX(1)(1:4) TO TL-OBSERVED
     MOVE WS-NAME TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     MOVE "Bob" TO WS-OWNER
     MOVE 3 TO WS-OWNER-LEN
     MOVE 1 TO WS-PRESENT
     PERFORM SEND-RESET
     MOVE "Reset Score of one objective removes that score" TO WS-NAME
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         IF HX-SS-USED(WS-I) = 1 AND HX-SS-OWNER(WS-I)(1:3) = "Bob"
             ADD 1 TO WS-OBS
         END-IF
     END-PERFORM
     MOVE 0 TO WS-EXP
     PERFORM CHK
     MOVE "Alice" TO WS-OWNER
     MOVE 5 TO WS-OWNER-LEN
     MOVE 0 TO WS-PRESENT
     PERFORM SEND-RESET
     MOVE "Reset Score without an objective removes every score of the owner" TO WS-NAME
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         IF HX-SS-USED(WS-I) = 1 AND HX-SS-OWNER(WS-I)(1:5) = "Alice"
             ADD 1 TO WS-OBS
         END-IF
     END-PERFORM
     MOVE 0 TO WS-EXP
     PERFORM CHK
*>   removing an objective clears its slots and scores
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     MOVE 1 TO WS-METHOD
     PERFORM SEND-OBJECTIVE
     MOVE "Set Objective remove: the sidebar slot is cleared" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-SLOT(2) TO WS-OBS
     PERFORM CHK
     MOVE "and its scores are deleted (the 21 of many and Zed of team are left)" TO WS-NAME
     MOVE 22 TO WS-EXP
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         ADD HX-SS-USED(WS-I) TO WS-OBS
     END-PERFORM
     PERFORM CHK
*>   Set Objective with an unknown number format type and an unknown method are ignored
     MOVE "bad" TO WS-OBJ
     MOVE 3 TO WS-OBJ-LEN
     MOVE 0 TO WS-METHOD
     MOVE 5 TO WS-FMT
     PERFORM SEND-OBJECTIVE
     MOVE 7 TO WS-METHOD
     PERFORM SEND-OBJECTIVE
     MOVE "an unknown format type and an unknown method add no objective" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         ADD HX-SO-USED(WS-I) TO WS-OBS
     END-PERFORM
     PERFORM CHK
*>   the Style of a number format: a hex colour, a bad hex colour, a member that is skipped, a string root, an absent root
     MOVE "0A 08 00 05 63 6F 6C 6F 72 00 07 23 31 30 32 30 33 30 00" TO WS-HEX
     PERFORM STYLE-OF
     MOVE "style colour #102030" TO WS-NAME
     MOVE 1056816 TO WS-EXP
     MOVE WS-STYLE-RGB TO WS-OBS
     PERFORM CHK
     MOVE "0A 08 00 05 63 6F 6C 6F 72 00 07 23 61 62 63 64 65 66 00" TO WS-HEX
     PERFORM STYLE-OF
     MOVE "style colour #abcdef (lower case)" TO WS-NAME
     MOVE 11259375 TO WS-EXP
     MOVE WS-STYLE-RGB TO WS-OBS
     PERFORM CHK
     MOVE "0A 08 00 05 63 6F 6C 6F 72 00 07 23 41 42 43 44 45 46 00" TO WS-HEX
     PERFORM STYLE-OF
     MOVE "style colour #ABCDEF (upper case)" TO WS-NAME
     MOVE 11259375 TO WS-EXP
     MOVE WS-STYLE-RGB TO WS-OBS
     PERFORM CHK
     MOVE "0A 08 00 05 63 6F 6C 6F 72 00 07 23 31 32 33 34 35 47 00" TO WS-HEX
     PERFORM STYLE-OF
     MOVE "style colour #12345G is not a colour" TO WS-NAME
     MOVE -1 TO WS-EXP
     MOVE WS-STYLE-RGB TO WS-OBS
     PERFORM CHK
     MOVE "0A 01 00 04 62 6F 6C 64 01 08 00 05 63 6F 6C 6F 72 00 04 67 6F 6C 64 00" TO WS-HEX
     PERFORM STYLE-OF
     MOVE "a bold byte member is skipped, then gold" TO WS-NAME
     MOVE 16755200 TO WS-EXP
     MOVE WS-STYLE-RGB TO WS-OBS
     PERFORM CHK
     MOVE "08 00 01 78" TO WS-HEX
     PERFORM STYLE-OF
     MOVE "a string root is no style" TO WS-NAME
     MOVE -1 TO WS-EXP
     MOVE WS-STYLE-RGB TO WS-OBS
     PERFORM CHK
     MOVE "00" TO WS-HEX
     PERFORM STYLE-OF
     MOVE "an absent root is no style" TO WS-NAME
     MOVE WS-STYLE-RGB TO WS-OBS
     PERFORM CHK
     MOVE 12 TO WS-I
     CALL "SCORE-COLOUR-RGB" USING WS-I WS-STYLE-RGB
     MOVE "team colour 12 is red FF5555" TO WS-NAME
     MOVE 16733525 TO WS-EXP
     MOVE WS-STYLE-RGB TO WS-OBS
     PERFORM CHK
     MOVE 16 TO WS-I
     CALL "SCORE-COLOUR-RGB" USING WS-I WS-STYLE-RGB
     MOVE "team colour 16 is none" TO WS-NAME
     MOVE -1 TO WS-EXP
     MOVE WS-STYLE-RGB TO WS-OBS
     PERFORM CHK
*>   the style colour names of the sixteen team colours
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         CALL "SCORE-COLOUR-RGB" USING WS-I WS-STYLE-RGB
         MOVE WS-I TO WS-N2
         MOVE SPACES TO WS-NAME
         STRING "a team colour ordinal " WS-N2 " is a colour" DELIMITED BY SIZE INTO WS-NAME
         MOVE 1 TO WS-EXP
         MOVE 0 TO WS-OBS
         IF WS-STYLE-RGB >= 0
             MOVE 1 TO WS-OBS
         END-IF
         PERFORM CHK
     END-PERFORM
*>   short packets of every scoreboard id change nothing
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1 MOVE 108 TO WS-ID
             WHEN 2 MOVE 100 TO WS-ID
             WHEN 3 MOVE 112 TO WS-ID
             WHEN 4 MOVE 80 TO WS-ID
             WHEN OTHER MOVE 111 TO WS-ID
         END-EVALUATE
         CALL "PB-INIT" USING PB-BUFFER WS-CAP
         MOVE 0 TO PB-POS
         CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     END-PERFORM
     MOVE "short packets leave the connection up" TO WS-NAME
     MOVE SCR-WORLD TO WS-EXP
     MOVE SM-SCREEN TO WS-OBS
     PERFORM CHK
*>   Reset Score of an unknown objective changes nothing; a team packet with 5000 players is malformed
     MOVE "nosuch" TO WS-OBJ
     MOVE 6 TO WS-OBJ-LEN
     MOVE "Mia" TO WS-OWNER
     MOVE 3 TO WS-OWNER-LEN
     MOVE 1 TO WS-PRESENT
     PERFORM SEND-RESET
     MOVE "ta" TO WS-OBJ
     MOVE 2 TO WS-OBJ-LEN
     MOVE 3 TO WS-METHOD
     MOVE 5000 TO WS-PLAYERS
     PERFORM SEND-TEAM
     MOVE 1 TO WS-PLAYERS
     MOVE "both packets leave the connection up" TO WS-NAME
     MOVE SCR-WORLD TO WS-EXP
     MOVE SM-SCREEN TO WS-OBS
     PERFORM CHK
*>   team membership: join moves a name between teams, leave of a member, a full list
     MOVE "ta" TO WS-OBJ
     MOVE 2 TO WS-OBJ-LEN
     MOVE 0 TO WS-METHOD
     MOVE 12 TO WS-TEAM-COLOUR
     MOVE "p" TO WS-PREFIX
     MOVE 1 TO WS-PREFIX-LEN
     MOVE 1 TO WS-SUFFIX-LEN
     MOVE 1 TO WS-PLAYERS
     MOVE "Mia" TO WS-PLAYER-1
     MOVE 3 TO WS-PLAYER-1-LEN
     PERFORM SEND-TEAM
     MOVE "tb" TO WS-OBJ
     PERFORM SEND-TEAM
     MOVE "ta" TO WS-OBJ
     MOVE 3 TO WS-METHOD
     PERFORM SEND-TEAM
     MOVE "Mia joined tb, then ta: she is a member of the second team (row of ta)" TO WS-NAME
     MOVE "ta" TO WS-OWNER
     MOVE 2 TO WS-OWNER-LEN
     CALL "SCORE-TEAM-FIND" USING CLIENT-STATE WS-OWNER WS-OWNER-LEN WS-J
     MOVE "Mia" TO WS-OWNER
     MOVE 3 TO WS-OWNER-LEN
     CALL "SCORE-OWNER-TEAM" USING CLIENT-STATE WS-OWNER WS-OWNER-LEN WS-OBS
     MOVE WS-J TO WS-EXP
     PERFORM CHK
     MOVE 4 TO WS-METHOD
     PERFORM SEND-TEAM
     CALL "SCORE-OWNER-TEAM" USING CLIENT-STATE WS-OWNER WS-OWNER-LEN WS-OBS
     MOVE "a leave takes the member out" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM CHK
     MOVE 3 TO WS-METHOD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 129
         MOVE WS-I TO WS-N3
         MOVE SPACES TO WS-PLAYER-1
         STRING "p" WS-N3 DELIMITED BY SIZE INTO WS-PLAYER-1
         MOVE 4 TO WS-PLAYER-1-LEN
         PERFORM SEND-TEAM
     END-PERFORM
     MOVE "129 joins: 128 members fit" TO WS-NAME
     MOVE 128 TO WS-EXP
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         IF HX-TP-TEAM(WS-I) > 0
             ADD 1 TO WS-OBS
         END-IF
     END-PERFORM
     PERFORM CHK
*>   Set Player Team remove, then a leave of a name that is not in the team ends the connection
     MOVE "red" TO WS-OBJ
     MOVE 3 TO WS-OBJ-LEN
     MOVE 1 TO WS-METHOD
     PERFORM SEND-TEAM
     MOVE "Set Player Team remove: the team is gone" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-TM-USED(1) TO WS-OBS
     PERFORM CHK
     MOVE "blue" TO WS-OBJ
     MOVE 4 TO WS-OBJ-LEN
     MOVE 0 TO WS-METHOD
     MOVE 1 TO WS-PLAYERS
     MOVE "Zed" TO WS-PLAYER-1
     MOVE 3 TO WS-PLAYER-1-LEN
     PERFORM SEND-TEAM
     MOVE 4 TO WS-METHOD
     MOVE "Bob" TO WS-PLAYER-1
     PERFORM SEND-TEAM
     MOVE "a leave of a name that is not in the team ends the connection (server list)" TO WS-NAME
     MOVE SCR-SERVER-LIST TO WS-EXP
     MOVE SM-SCREEN TO WS-OBS
     PERFORM CHK
     MOVE "and the scoreboard goes with the connection" TO WS-NAME
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         ADD HX-SO-USED(WS-I) TO WS-OBS
     END-PERFORM
     MOVE 0 TO WS-EXP
     PERFORM CHK
*>   an objective added twice ends the connection of a client that is up again
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "kills" TO WS-OBJ
     MOVE 5 TO WS-OBJ-LEN
     MOVE "Kills" TO WS-TITLE
     MOVE 5 TO WS-TITLE-LEN
     MOVE 0 TO WS-METHOD
     MOVE -1 TO WS-FMT
     PERFORM SEND-OBJECTIVE
     PERFORM SEND-OBJECTIVE
     MOVE "an objective added twice ends the connection (server list)" TO WS-NAME
     MOVE SCR-SERVER-LIST TO WS-EXP
     MOVE SM-SCREEN TO WS-OBS
     PERFORM CHK
     STOP RUN.

 CHK.
     MOVE WS-NAME TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BUILD.
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "SCORE-SIDEBAR-ADD" USING CLIENT-STATE WS-GW WS-GH.

*> A Style of the bytes in WS-HEX read by SCORE-STYLE-COLOUR: WS-STYLE-RGB.
 STYLE-OF.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     PERFORM APPEND-HEX
     MOVE 0 TO PB-POS
     CALL "SCORE-STYLE-COLOUR" USING PB-BUFFER WS-STYLE-RGB.

 PUT-STRING.
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-PIECE WS-PIECE-LEN WS-MAX.

 PUT-PLAIN.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE WS-PIECE TO PB-TX-VALUE
     MOVE WS-PIECE-LEN TO PB-TX-LENGTH
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT.

*> The number format WS-FMT (-1 absent, 0 blank, 1 styled with WS-STYLE-HEX, 2 fixed WS-FIXED) as an Optional NumberFormat.
 PUT-FORMAT.
     IF WS-FMT < 0
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     ELSE
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FMT
         IF WS-FMT = 1
             MOVE WS-STYLE-HEX TO WS-HEX
             PERFORM APPEND-HEX
         END-IF
         IF WS-FMT = 2
             MOVE WS-FIXED TO WS-PIECE
             MOVE WS-FIXED-LEN TO WS-PIECE-LEN
             PERFORM PUT-PLAIN
         END-IF
     END-IF.

*> Set Objective (108): WS-OBJ, WS-METHOD, WS-TITLE, render type 0, WS-FMT.
 SEND-OBJECTIVE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE WS-OBJ TO WS-PIECE
     MOVE WS-OBJ-LEN TO WS-PIECE-LEN
     PERFORM PUT-STRING
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-METHOD
     IF WS-METHOD = 0 OR WS-METHOD = 2
         MOVE WS-TITLE TO WS-PIECE
         MOVE WS-TITLE-LEN TO WS-PIECE-LEN
         PERFORM PUT-PLAIN
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         PERFORM PUT-FORMAT
     END-IF
     MOVE 0 TO PB-POS
     MOVE 108 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.

*> Set Display Objective (100): slot WS-VALUE, objective WS-OBJ.
 SEND-DISPLAY.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE WS-OBJ TO WS-PIECE
     MOVE WS-OBJ-LEN TO WS-PIECE-LEN
     PERFORM PUT-STRING
     MOVE 0 TO PB-POS
     MOVE 100 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.

 SEND-SCORE.
     MOVE -1 TO WS-FMT
     MOVE 0 TO WS-PRESENT
     PERFORM SEND-SCORE-FORMAT.

*> Set Score (112): owner WS-OWNER, objective WS-OBJ, value WS-VALUE, display WS-DISPLAY when WS-PRESENT is 1, format WS-FMT.
 SEND-SCORE-FORMAT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE WS-OWNER TO WS-PIECE
     MOVE WS-OWNER-LEN TO WS-PIECE-LEN
     PERFORM PUT-STRING
     MOVE WS-OBJ TO WS-PIECE
     MOVE WS-OBJ-LEN TO WS-PIECE-LEN
     PERFORM PUT-STRING
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-PRESENT
     IF WS-PRESENT = 1
         MOVE WS-DISPLAY TO WS-PIECE
         MOVE WS-DISPLAY-LEN TO WS-PIECE-LEN
         PERFORM PUT-PLAIN
     END-IF
     PERFORM PUT-FORMAT
     MOVE 0 TO PB-POS
     MOVE 112 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.

*> Reset Score (80): owner WS-OWNER, objective WS-OBJ when WS-PRESENT is 1.
 SEND-RESET.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE WS-OWNER TO WS-PIECE
     MOVE WS-OWNER-LEN TO WS-PIECE-LEN
     PERFORM PUT-STRING
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-PRESENT
     IF WS-PRESENT = 1
         MOVE WS-OBJ TO WS-PIECE
         MOVE WS-OBJ-LEN TO WS-PIECE-LEN
         PERFORM PUT-STRING
     END-IF
     MOVE 0 TO PB-POS
     MOVE 80 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.

*> Set Player Team (111): team WS-OBJ, method WS-METHOD, parameters (prefix WS-PREFIX, suffix WS-SUFFIX, colour WS-TEAM-COLOUR) for 0 and 2, the players WS-PLAYER-1 for 0, 3 and 4.
 SEND-TEAM.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE WS-OBJ TO WS-PIECE
     MOVE WS-OBJ-LEN TO WS-PIECE-LEN
     PERFORM PUT-STRING
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-METHOD
     IF WS-METHOD = 0 OR WS-METHOD = 2
         MOVE WS-OBJ TO WS-PIECE
         MOVE WS-OBJ-LEN TO WS-PIECE-LEN
         PERFORM PUT-PLAIN
         MOVE WS-PREFIX TO WS-PIECE
         MOVE WS-PREFIX-LEN TO WS-PIECE-LEN
         PERFORM PUT-PLAIN
         MOVE WS-SUFFIX TO WS-PIECE
         MOVE WS-SUFFIX-LEN TO WS-PIECE-LEN
         PERFORM PUT-PLAIN
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TEAM-COLOUR
         CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-ONE
     END-IF
     IF WS-METHOD = 0 OR WS-METHOD = 3 OR WS-METHOD = 4
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PLAYERS
         MOVE WS-PLAYER-1 TO WS-PIECE
         MOVE WS-PLAYER-1-LEN TO WS-PIECE-LEN
         PERFORM PUT-STRING
     END-IF
     MOVE 0 TO PB-POS
     MOVE 111 TO WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.

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
 END PROGRAM TEST-HUD-SCORE.

 COPY CLTEST.
