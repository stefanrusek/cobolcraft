*> Implementation test (coverage lane A; core/src/mob-44-l.cob EGG-RULES-OPEN): opening the egg rules a second time leaves the rules of the turtle egg and frogspawn as they are (a block that
*> already has its rows is left alone).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-EGGRULES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BUSTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "EGG-RULES-OPEN"
     MOVE BU-RULE-COUNT TO WS-BEFORE
     CALL "EGG-RULES-OPEN"
     MOVE "test cova eggrules opening the egg rules again adds no rule" TO WS-CASE
     MOVE WS-BEFORE TO WS-E
     MOVE BU-RULE-COUNT TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-EGGRULES.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
