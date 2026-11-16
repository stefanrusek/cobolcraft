*> Implementation test of LANG-LOAD on a vanilla-sized en_us.json (08 §8; fixtures/biglang: 9,000 keys,
*> over 500 KB, written by gen_packs.py): the file is read whole, every key past the first 4,096 JSON
*> nodes loads, a death message translates with its arguments, a value with escapes and separators is
*> kept, and the built-in keys stay.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LANG-BIG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLARGS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/biglang" TO PK-ROOT(PK-COUNT)
     MOVE 29 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "LANG-LOAD" USING CLIENT-STATE
     MOVE "lang a 9,000-key file and the 358 built-in keys all load" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 9358 TO TL-EXPECTED-N
     MOVE LG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "death.attack.mob" TO WS-KEY
     MOVE 16 TO WS-KEY-LENGTH
     MOVE 2 TO LA-COUNT
     MOVE "Stefan" TO LA-TEXT(1)
     MOVE 6 TO LA-LENGTH(1)
     MOVE "Zombie" TO LA-TEXT(2)
     MOVE 6 TO LA-LENGTH(2)
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-TEXT-LENGTH
     MOVE "lang death.attack.mob reads Stefan was slain by Zombie" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Stefan was slain by Zombie" TO TL-EXPECTED
     MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "zzz.last.key" TO WS-KEY
     MOVE 12 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
     MOVE "lang the last key of the file loads" TO TL-CASE
     MOVE "the last one" TO TL-EXPECTED
     MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "tricky.value" TO WS-KEY
     MOVE 12 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
     MOVE "lang a value with a quote, commas and braces is kept whole" TO TL-CASE
     MOVE 'a, "b": {c} [d], e' TO TL-EXPECTED
     MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cobolcraft.screen.server_list.title" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
     MOVE "lang a built-in key stays under the larger pack" TO TL-CASE
     MOVE "Servers" TO TL-EXPECTED
     MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-LANG-BIG.
