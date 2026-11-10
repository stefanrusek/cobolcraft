*> Implementation test of client/src/packs/lang.cob (LANG-LOAD, LANG-GET, LANG-FORMAT,
*> LANG-FORMAT-TEXT; 08 §8, §10.8): keys resolve to the en_us texts of the packs; a key no pack
*> defines shows as the key itself; %s placeholders take the arguments in order and %n$s the n-th
*> one; %% is a percent sign.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LANG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLARGS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-TEMPLATE            PIC X(200).
 01 WS-TEMPLATE-LENGTH     BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     MOVE "lang loads the 296 keys of the built-in en_us.json" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 296 TO TL-EXPECTED-N
     MOVE LG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cobolcraft.screen.server_list.title" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
     MOVE "lang cobolcraft.screen.server_list.title is Servers" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Servers" TO TL-EXPECTED
     MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "no.such.key" TO WS-KEY
     MOVE 11 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
     MOVE "lang a key no pack defines shows as the key itself (08 §10.8)" TO TL-CASE
     MOVE "no.such.key" TO TL-EXPECTED
     MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cobolcraft.screen.server_list.online" TO WS-KEY
     MOVE 36 TO WS-KEY-LENGTH
     MOVE 2 TO LA-COUNT
     MOVE "3" TO LA-TEXT(1)
     MOVE 1 TO LA-LENGTH(1)
     MOVE "20" TO LA-TEXT(2)
     MOVE 2 TO LA-LENGTH(2)
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-TEXT-LENGTH
     MOVE "lang server_list.online with arguments 3 and 20 is 3 of 20 online" TO TL-CASE
     MOVE "3 of 20 online" TO TL-EXPECTED
     MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "b=%2$s a=%1$s %% %s %s %s." TO WS-TEMPLATE
     MOVE 27 TO WS-TEMPLATE-LENGTH
     CALL "LANG-FORMAT-TEXT" USING WS-TEMPLATE WS-TEMPLATE-LENGTH LANG-ARGS WS-TEXT
         WS-TEXT-LENGTH
     MOVE "lang %2$s and %1$s take the n-th argument, %% is a percent, a %s past the arguments is "
         & "empty" TO TL-CASE
     MOVE "b=20 a=3 % 3 20 ." TO TL-EXPECTED
     MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2 TO PK-COUNT
     MOVE 0 TO PK-KIND(2)
     CALL "LANG-LOAD" USING CLIENT-STATE
     MOVE "lang a higher pack's en_us.json replaces the texts of the same keys" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 296 TO TL-EXPECTED-N
     MOVE LG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-LANG.
