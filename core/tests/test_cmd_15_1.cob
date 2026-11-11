*> Acceptance test of docs/protocol/15-commands-framework.md §1 Table of contents of the standard commands (the implemented ones): each root literal
*> of the standard tree has the level of its row (the dedicated server: seed and version are level 2), the common commands keep the order of
*> the table and so do the dedicated-server commands (the registration order fixes the child order of the root, §3.2), the aliases
*> tell, w and tp redirect to their target with its level, and a command no row names is not registered.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 01 WS-ROWS.
    05 FILLER PIC X(20) VALUE "execute".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "clear".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "defaultgamemode".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "difficulty".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "effect".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "me".
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(20) VALUE "fill".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "gamemode".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "gamerule".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "give".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "help".
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(20) VALUE "kick".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC X(20) VALUE "kill".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "list".
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(20) VALUE "msg".
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(20) VALUE "random".
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(20) VALUE "reload".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "say".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "seed".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "version".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "setblock".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "spawnpoint".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "setworldspawn".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "summon".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "teleport".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "time".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "weather".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC X(20) VALUE "ban-ip".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC X(20) VALUE "banlist".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC X(20) VALUE "ban".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC X(20) VALUE "deop".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC X(20) VALUE "op".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC X(20) VALUE "pardon".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC X(20) VALUE "pardon-ip".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC X(20) VALUE "save-all".
    05 FILLER PIC S9(9) BINARY VALUE 4.
    05 FILLER PIC X(20) VALUE "save-off".
    05 FILLER PIC S9(9) BINARY VALUE 4.
    05 FILLER PIC X(20) VALUE "save-on".
    05 FILLER PIC S9(9) BINARY VALUE 4.
    05 FILLER PIC X(20) VALUE "setidletimeout".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC X(20) VALUE "stop".
    05 FILLER PIC S9(9) BINARY VALUE 4.
    05 FILLER PIC X(20) VALUE "whitelist".
    05 FILLER PIC S9(9) BINARY VALUE 3.
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 40 TIMES.
       10 WS-ROW-NAME PIC X(20).
       10 WS-ROW-LEVEL PIC S9(9) BINARY.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LAST-COMMON         BINARY-LONG.
 01 WS-LAST-DEDICATED      BINARY-LONG.
 01 WS-POSITION            BINARY-LONG.
 01 WS-ORDER-OK            BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(20).
 01 WS-LEN                 BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "BR-STD-TREE"
     MOVE 0 TO WS-LAST-COMMON WS-LAST-DEDICATED
     MOVE 1 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands execute is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 2 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands clear is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 3 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands defaultgamemode is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 4 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands difficulty is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 5 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands effect is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 6 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands me is a root literal of level 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 0
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 7 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands fill is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 8 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands gamemode is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 9 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands gamerule is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 10 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands give is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 11 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands help is a root literal of level 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 0
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 12 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands kick is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 13 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands kill is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 14 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands list is a root literal of level 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 0
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 15 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands msg is a root literal of level 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 0
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 16 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands random is a root literal of level 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 0
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 17 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands reload is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 18 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands say is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 19 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands seed is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 20 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands version is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 21 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands setblock is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 22 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands spawnpoint is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 23 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands setworldspawn is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 24 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands summon is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 25 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands teleport is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 26 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands time is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 27 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands weather is a root literal of level 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 2
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-COMMON
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-COMMON
     END-IF
     MOVE 28 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands ban-ip is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 29 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands banlist is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 30 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands ban is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 31 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands deop is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 32 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands op is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 33 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands pardon is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 34 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands pardon-ip is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 35 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands save-all is a root literal of level 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 4
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 36 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands save-off is a root literal of level 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 4
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 37 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands save-on is a root literal of level 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 4
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 38 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands setidletimeout is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 39 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands stop is a root literal of level 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 4
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE 40 TO WS-I
     PERFORM FIND-ROOT-CHILD
     MOVE "acceptance US13 15§1 Table of contents of the standard commands whitelist is a root literal of level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000 + 3
     COMPUTE TL-OBSERVED-N = 1000 + BR-N-LEVEL(WS-NODE)
     IF WS-NODE = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-NODE > 0
         MOVE 0 TO WS-POSITION
         PERFORM POSITION-OF-NODE
         IF WS-POSITION < WS-LAST-DEDICATED
             MOVE 0 TO WS-ORDER-OK
         END-IF
         MOVE WS-POSITION TO WS-LAST-DEDICATED
     END-IF
     MOVE "acceptance US13 15§1 Table of contents of the standard commands the commands of each group keep the order of the table" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ORDER-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "tell" TO WS-NAME
     PERFORM FIND-BY-NAME
     MOVE WS-NODE TO WS-TARGET
     MOVE "msg" TO WS-NAME
     PERFORM FIND-BY-NAME
     MOVE "acceptance US13 15§1 Table of contents of the standard commands the alias tell redirects to msg with its level" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = WS-NODE * 10 + BR-N-LEVEL(WS-NODE)
     COMPUTE TL-OBSERVED-N = BR-N-REDIRECT(WS-TARGET) * 10 + BR-N-LEVEL(WS-TARGET)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "w" TO WS-NAME
     PERFORM FIND-BY-NAME
     MOVE WS-NODE TO WS-TARGET
     MOVE "msg" TO WS-NAME
     PERFORM FIND-BY-NAME
     MOVE "acceptance US13 15§1 Table of contents of the standard commands the alias w redirects to msg with its level" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = WS-NODE * 10 + BR-N-LEVEL(WS-NODE)
     COMPUTE TL-OBSERVED-N = BR-N-REDIRECT(WS-TARGET) * 10 + BR-N-LEVEL(WS-TARGET)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "tp" TO WS-NAME
     PERFORM FIND-BY-NAME
     MOVE WS-NODE TO WS-TARGET
     MOVE "teleport" TO WS-NAME
     PERFORM FIND-BY-NAME
     MOVE "acceptance US13 15§1 Table of contents of the standard commands the alias tp redirects to teleport with its level" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = WS-NODE * 10 + BR-N-LEVEL(WS-NODE)
     COMPUTE TL-OBSERVED-N = BR-N-REDIRECT(WS-TARGET) * 10 + BR-N-LEVEL(WS-TARGET)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "advancement" TO WS-NAME
     PERFORM FIND-BY-NAME
     MOVE "acceptance US13 15§1 Table of contents of the standard commands a command that is not implemented is not registered" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

*> WS-NODE: the root child named WS-ROW-NAME(WS-I), 0 when none.
 FIND-ROOT-CHILD.
     MOVE WS-ROW-NAME(WS-I) TO WS-NAME
     PERFORM FIND-BY-NAME.

*> WS-NODE: the root child named WS-NAME (space padded), 0 when none.
 FIND-BY-NAME.
     MOVE 0 TO WS-FOUND
     MOVE BR-N-FIRST(1) TO WS-NODE
     PERFORM UNTIL WS-NODE = 0 OR WS-FOUND = 1
         MOVE BR-N-NAME-LENGTH(WS-NODE) TO WS-LEN
         IF WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) AND BR-N-NAME(WS-NODE) = WS-NAME
             MOVE 1 TO WS-FOUND
         ELSE
             MOVE BR-N-NEXT(WS-NODE) TO WS-NODE
         END-IF
     END-PERFORM.

*> WS-POSITION: the place of WS-NODE among the children of the root.
 POSITION-OF-NODE.
     MOVE 0 TO WS-POSITION
     MOVE BR-N-FIRST(1) TO WS-TARGET
     PERFORM UNTIL WS-TARGET = 0 OR WS-TARGET = WS-NODE
         ADD 1 TO WS-POSITION
         MOVE BR-N-NEXT(WS-TARGET) TO WS-TARGET
     END-PERFORM.

 END PROGRAM TEST-CMD-15-1.

 COPY CORETEST.
