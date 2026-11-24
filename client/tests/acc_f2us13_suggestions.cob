*> Acceptance test US13-1 (spec 002 FR-034; SC-008; 15 §14.1, §14.2, §14.5): the received command tree drives the chat suggestions: the commands that
*> start with the typed word whatever its case, sorted by lower-cased text (the level 0 tree of 57-client-closures-4 section 10.1 lists me, help, list, msg, tell, w,
*> random, teammsg, tm, trigger: the list is help, list, me, msg, random, teammsg, tell, tm, trigger, w); Tab puts the first suggestion in place of the word being typed
*> and each further Tab the next one, round (help ... w, help) while the list is kept; typing or Backspace ends the cycle; at an ask_server argument (trigger <objective>)
*> Tab takes the server's answer (Alice) in place of the word; with the 91 commands of the operator's tree only the first 10 (sorted) are shown.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US13-SUGGESTIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-SCREEN-TEXT         PIC X(1024).
 01 WS-TYPED               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-KEY                 BINARY-LONG.
 01 WS-E                   PIC Z9.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 3 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "contract/fixtures/wire/play-s2c-10-commands-everyone.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-SLASH TO WS-A(1) WS-A(3)
     MOVE CC-EV-TEXT TO WS-KIND(2)
     MOVE 47 TO WS-A(2)
     MOVE CC-EV-KEY-UP TO WS-KIND(3)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-THREE
     MOVE "T" TO TL-MODE
     MOVE "acceptance US13-1 the commands of the tree are suggested sorted by lower-cased text: help, list, me, msg, random, teammsg, tell, tm, trigger, w" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/|help|list|me|msg|random|teammsg|tell|tm|trigger|w" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Tab cycles help, list, me, msg, random, teammsg, tell, tm, trigger, w, help.
     MOVE SPACES TO TL-OBSERVED
     PERFORM 11 TIMES
         MOVE CC-KEY-TAB TO WS-KEY
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
         STRING FUNCTION TRIM(TL-OBSERVED) " " CH-LINE(1:CH-LINE-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     MOVE "acceptance US13-1 Tab eleven times puts /help to /w on the line and /help again (the list is kept while cycling)" TO TL-CASE
     MOVE "/help /list /me /msg /random /teammsg /tell /tm /trigger /w /help" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 while cycling the list stays: help to w" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/help|help|list|me|msg|random|teammsg|tell|tm|trigger|w" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Backspace ends the cycle too: /hel, and the list is made again from it (help only).
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 Backspace after the cycle gives /hel and the list made again: help" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/hel|help" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "p" TO WS-TYPED
     MOVE 1 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
*>   Typing ends the cycle: /helpx has no suggestion; Backspace gives /help and its one suggestion again.
     MOVE "x" TO WS-TYPED
     MOVE 1 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 typing x after the cycle gives the line /helpx with no suggestion" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/helpx" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 Backspace gives /help and the suggestion help" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/help|help" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The case of the typed word does not matter: /HE suggests help; Tab with it puts help in place of HE.
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM 4 TIMES
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     END-PERFORM
     MOVE "HE" TO WS-TYPED
     MOVE 2 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 /HE suggests help (the match ignores case)" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/HE|help" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-TAB TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US13-1 Tab on /HE puts /help on the line" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE CH-LINE(1:CH-LINE-LENGTH) TO TL-OBSERVED
     MOVE "/help" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The suggestions are in the order of their lower-cased text, whatever the case: Bb, aa, Cc give aa, Bb, Cc.
     MOVE 3 TO CS-COUNT
     MOVE "Bb" TO CS-TEXT(1)
     MOVE 2 TO CS-LENGTH(1)
     MOVE "aa" TO CS-TEXT(2)
     MOVE 2 TO CS-LENGTH(2)
     MOVE "Cc" TO CS-TEXT(3)
     MOVE 2 TO CS-LENGTH(3)
     CALL "CHAT-SORT" USING CLIENT-STATE
     MOVE "acceptance US13-1 the suggestions Bb, aa, Cc are sorted aa, Bb, Cc (lower-cased text)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING CS-TEXT(1)(1:2) "," CS-TEXT(2)(1:2) "," CS-TEXT(3)(1:2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "aa,Bb,Cc" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Tab with no suggestion changes nothing.
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM 4 TIMES
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     END-PERFORM
     MOVE "zz" TO WS-TYPED
     MOVE 2 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE CC-KEY-TAB TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US13-1 Tab with no suggestion leaves the line /zz" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE CH-LINE(1:CH-LINE-LENGTH) TO TL-OBSERVED
     MOVE "/zz" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An ask_server argument: the line /trigger Al asks the server; its answer Alice is taken by Tab in place of Al.
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM 2 TIMES
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     END-PERFORM
     MOVE "trigger Al" TO WS-TYPED
     MOVE 10 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE "contract/fixtures/wire/play-s2c-0f-command-suggestions.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE CC-KEY-TAB TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US13-1 Tab on /trigger Al takes the server's answer: the line is /trigger Alice" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE CH-LINE(1:CH-LINE-LENGTH) TO TL-OBSERVED
     MOVE "/trigger Alice" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With the operator's 91 commands only the first 10 (sorted) are shown, as 10 lines above the input line (15 §14.5).
     MOVE "contract/fixtures/wire/play-s2c-10-commands-operator.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "/" TO CH-LINE
     MOVE 1 TO CH-LINE-LENGTH
     MOVE 0 TO CS-FROZEN CS-SELECTED
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 with 91 commands the chat shows the first 10 sorted: advancement to damage" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/|advancement|attribute|ban|ban-ip|banlist|bossbar|clear|clone|compute|damage" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US13-SUGGESTIONS.
 COPY CLTEST.
