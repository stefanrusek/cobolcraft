*> Implementation test of the language report (T5002): LANG-LOAD counts the lang files it merges, the
*> ones that could not be read and a key list that overflowed, and LANG-REPORT turns the counts into
*> the line the console shows, so a missing language is visible in the log and not only as raw keys.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LANG-REPORT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-LINE                PIC X(160).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ROOT                PIC X(64).
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "LANG-REPORT" USING CLIENT-STATE WS-LINE WS-LENGTH
     MOVE "lang report the built-in pack alone is one file and no warning" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "language: 1 lang files, no problem" TO TL-EXPECTED
     MOVE WS-LINE(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO PK-COUNT
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "LANG-REPORT" USING CLIENT-STATE WS-LINE WS-LENGTH
     MOVE "lang report a stack without a lang file warns that texts show as keys" TO TL-CASE
     MOVE "WARNING language: no lang/en_us.json in any pack, texts show as their keys"
         TO TL-EXPECTED
     MOVE WS-LINE(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2 TO LG-FILES
     MOVE 1 TO LG-FAILED
     MOVE 0 TO LG-OVERFLOW
     CALL "LANG-REPORT" USING CLIENT-STATE WS-LINE WS-LENGTH
     MOVE "lang report a lang file that cannot be read is counted" TO TL-CASE
     MOVE "WARNING language: 1 lang files could not be read" TO TL-EXPECTED
     MOVE WS-LINE(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO LG-FAILED
     MOVE 1 TO LG-OVERFLOW
     CALL "LANG-REPORT" USING CLIENT-STATE WS-LINE WS-LENGTH
     MOVE "lang report more keys than the table holds warns" TO TL-CASE
     MOVE "WARNING language: more keys than the table holds (12000), the rest are not loaded"
         TO TL-EXPECTED
     MOVE WS-LINE(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "client/tests/fixtures/hugelang" TO WS-ROOT
     PERFORM LOAD-FIXTURE
     MOVE "lang report a file of more keys than the table holds sets the overflow" TO TL-CASE
     MOVE "WARNING language: more keys than the table holds (12000), the rest are not loaded"
         TO TL-EXPECTED
     MOVE WS-LINE(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "client/tests/fixtures/oversizelang" TO WS-ROOT
     PERFORM LOAD-FIXTURE
     MOVE "lang report a lang file larger than the read area is counted as unreadable" TO TL-CASE
     MOVE "WARNING language: 1 lang files could not be read" TO TL-EXPECTED
     MOVE WS-LINE(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 LOAD-FIXTURE.
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "LANG-REPORT" USING CLIENT-STATE WS-LINE WS-LENGTH.
 END PROGRAM TEST-LANG-REPORT.
