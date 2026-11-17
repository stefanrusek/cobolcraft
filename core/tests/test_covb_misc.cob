*> Implementation test (lane covB): small paths of several units. End gateway set again on a known gateway (the exit and exact flags overwritten and cleared); a thunderstorm over a player
*> eventually striking one chunk (docs/protocol/44 part 8 section 7.1: 1 in 100000 per chunk and tick); the validity of a merchant window through the container validity check
*> (docs/protocol/40 menus); and the firework explosion component carrying colours of the high bit (negative Ints) through a set and a get.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-MISC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY ENDGATEWAY.
 COPY CMENU.
 COPY EXPREC.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 12.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 34.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-EX                  BINARY-LONG VALUE 100.
 01 WS-EY                  BINARY-LONG VALUE 50.
 01 WS-EZ                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STRUCK              BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
*>   End gateway set: a new row with an exit and the exact flag, then the same gateway again without either.
     MOVE 3 TO WS-FLAGS
     CALL "END-GATEWAY-SET" USING WS-DIM WS-X WS-Y WS-Z WS-FLAGS WS-EX WS-EY WS-EZ
     MOVE EG-COUNT TO WS-ROW
     MOVE "covB 31-5 4.2 a gateway set with flags 3 has its exit and is exact" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EG-HAS-EXIT(WS-ROW) * 10 + EG-EXACT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-FLAGS
     CALL "END-GATEWAY-SET" USING WS-DIM WS-X WS-Y WS-Z WS-FLAGS WS-EX WS-EY WS-EZ
     MOVE "covB 31-5 4.2 setting the same gateway again with flags 0 clears both and adds no row" TO TL-CASE
     MOVE ZEROS TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EG-HAS-EXIT(WS-ROW) * 100 + EG-EXACT(WS-ROW) * 10 + EG-COUNT - WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A thunderstorm over the player strikes a chunk after some thousand ticks.
     MOVE 1 TO CW-RAIN-LEVEL(WS-DIM)
     MOVE 1 TO CW-THUNDER-LEVEL(WS-DIM)
     MOVE 0 TO WS-STRUCK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40000 OR WS-STRUCK = 1
         CALL "LIGHTNING-WEATHER-TICK"
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PJ-MAX
             IF PJ-ENT(WS-J) > 0 AND PJ-KIND(WS-J) = 9
                 MOVE 1 TO WS-STRUCK
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "covB 44-8 7.1 a thunderstorm over a player strikes lightning within 40000 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STRUCK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A firework explosion whose colours have the high bit set (negative Ints) survives a set and a get.
     INITIALIZE EX-REC
     MOVE 2 TO EX-SHAPE
     MOVE 1 TO EX-N
     MOVE -16711936 TO EX-COLOR(1)
     MOVE 1 TO EX-FN
     MOVE -65536 TO EX-FADE(1)
     MOVE 0 TO WS-HANDLE
     CALL "SC-EXPLOSION-SET" USING WS-HANDLE EX-REC
     INITIALIZE EX-REC
     CALL "SC-EXPLOSION-GET" USING WS-HANDLE EX-REC WS-FOUND
     MOVE "covB 54 21.1 a negative colour comes back as it went in" TO TL-CASE
     MOVE -16711936 TO TL-EXPECTED-N
     MOVE EX-COLOR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 54 21.1 and so does a negative fade colour" TO TL-CASE
     MOVE -65536 TO TL-EXPECTED-N
     MOVE EX-FADE(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The validity of a merchant window is the merchant's: with no merchant it is not valid.
     MOVE 29 TO MN-CFAMILY(WS-PLAYER)
     MOVE 999999 TO MN-BENCH-X(WS-PLAYER)
     CALL "MENU-CONT-VALID" USING WS-PLAYER WS-VALID
     MOVE "covB 40 a merchant window with no merchant is not valid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-MISC.
 COPY CORETEST.
 COPY MOBSPTEST.
