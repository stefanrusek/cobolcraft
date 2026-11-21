*> Implementation test (operator playtest: holding Space while flying stopped the flight): the window system repeats a held
*> key as further key-down events with the repeat flag (shim cc_win.c: event field C = 1). A repeat is not a press: it must
*> not count as the second tap of the double-tap flight toggle (13 section 1.4: a rising edge of Space).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FLIGHT-REPEAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 WS-B                BINARY-LONG.
    05 WS-C                BINARY-LONG.
    05 WS-X                FLOAT-SHORT.
    05 WS-Y                FLOAT-SHORT.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MS                  BINARY-LONG VALUE 50.
 01 WS-I                   BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-creative.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
*>   A flying Player holds Space: one press, then repeats.
     MOVE 1 TO PL-FLYING
     MOVE 0 TO PL-ON-GROUND
     MOVE 15 TO PL-Y
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     MOVE 0 TO WS-C
     PERFORM SEND-KEY
     MOVE 1 TO WS-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         PERFORM SEND-KEY
     END-PERFORM
     MOVE "flight repeat a held Space (one press, then key repeats) does not stop the flight" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-FLYING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Two real presses within 0.3 s still toggle.
     MOVE 0 TO WS-C
     MOVE CC-EV-KEY-UP TO WS-KIND
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE WS-MS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     CALL "TEST-KEY" USING CLIENT-STATE WS-A
     CALL "TEST-KEY" USING CLIENT-STATE WS-A
     MOVE "flight repeat two presses within 0.3 s still stop the flight" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-FLYING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SEND-KEY.
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     MOVE CC-KEY-SPACE TO WS-A
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE WS-MS.
 END PROGRAM TEST-FLIGHT-REPEAT.
 COPY CLTEST.
