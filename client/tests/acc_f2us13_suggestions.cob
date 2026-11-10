*> Acceptance test US13-1 (spec 002 FR-034; SC-008; 15 §14.1, §14.2, §14.5): the received command tree drives the chat suggestions: the commands that
*> start with the typed word whatever its case, sorted by lower-cased text (the tree lists howto, roster, murmur: the list is howto, murmur, roster);
*> Tab puts the first suggestion in place of the word being typed and each further Tab the next one, round (howto, murmur, roster, howto) while
*> the list is kept; typing or Backspace ends the cycle; at an ask_server argument Tab takes the server's answer (Alice) in place of the word.
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
     MOVE "acceptance US13-1 the commands of the tree are suggested sorted by lower-cased text: howto, murmur, roster" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/|howto|murmur|roster" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Tab cycles howto, murmur, roster, howto.
     MOVE SPACES TO TL-OBSERVED
     PERFORM 4 TIMES
         MOVE CC-KEY-TAB TO WS-KEY
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
         STRING FUNCTION TRIM(TL-OBSERVED) " " CH-LINE(1:CH-LINE-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     MOVE "acceptance US13-1 Tab four times puts /howto, /murmur, /roster and /howto on the line (the list is kept while cycling)" TO TL-CASE
     MOVE "/howto /murmur /roster /howto" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 while cycling the list stays: howto, murmur, roster" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/howto|howto|murmur|roster" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Backspace ends the cycle too: /howt, and the list is made again from it (howto only).
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 Backspace after the cycle gives /howt and the list made again: howto" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/howt|howto" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "o" TO WS-TYPED
     MOVE 1 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
*>   Typing ends the cycle: /howtox has no suggestion; Backspace gives /howto and its one suggestion again.
     MOVE "x" TO WS-TYPED
     MOVE 1 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 typing x after the cycle gives the line /howtox with no suggestion" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/howtox" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 Backspace gives /howto and the suggestion howto" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/howto|howto" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The case of the typed word does not matter: /HO suggests howto; Tab with it puts howto in place of HO.
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM 5 TIMES
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     END-PERFORM
     MOVE "HO" TO WS-TYPED
     MOVE 2 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US13-1 /HO suggests howto (the match ignores case)" TO TL-CASE
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/HO|howto" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-TAB TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US13-1 Tab on /HO puts /howto on the line" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE CH-LINE(1:CH-LINE-LENGTH) TO TL-OBSERVED
     MOVE "/howto" TO TL-EXPECTED
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
     PERFORM 5 TIMES
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

*>   An ask_server argument: the line /murmur Al asks the server; its answer Alice is taken by Tab in place of Al.
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM 2 TIMES
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     END-PERFORM
     MOVE "murmur Al" TO WS-TYPED
     MOVE 9 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE "contract/fixtures/wire/play-s2c-0f-command-suggestions.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE CC-KEY-TAB TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US13-1 Tab on /murmur Al takes the server's answer: the line is /murmur Alice" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE CH-LINE(1:CH-LINE-LENGTH) TO TL-OBSERVED
     MOVE "/murmur Alice" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US13-SUGGESTIONS.
 COPY CLTEST.
