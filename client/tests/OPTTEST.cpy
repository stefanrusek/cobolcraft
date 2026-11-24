*> Test helpers of the options tests (test infrastructure, excluded from coverage). COPY this after the END PROGRAM of
*> a test program (and after CLTEST):
*>   TEST-OPT-LINE USING text area (PIC X(16384)), text length, name (PIC X(40)), value out (PIC X(64)), found out:
*>     the value after "<name>:" on a line of an options.txt text (the whole line is the name and the colon).
*>   TEST-OPT-SAME USING path a (PIC X(256)), path b (PIC X(256)), same out: 1 when the two files hold the same bytes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPT-LINE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(16384).
 01 L-LENGTH               BINARY-LONG.
 01 L-NAME                 PIC X(40).
 01 L-VALUE                PIC X(64).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-NAME L-VALUE L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE SPACES TO L-VALUE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WS-NAME-LENGTH
     MOVE 1 TO WS-START
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH OR L-FOUND = 1
         IF L-TEXT(WS-I:1) = X"0A"
             COMPUTE WS-END = WS-I - 1
             IF WS-END - WS-START >= WS-NAME-LENGTH
                     AND L-TEXT(WS-START:WS-NAME-LENGTH) = L-NAME(1:WS-NAME-LENGTH)
                     AND L-TEXT(WS-START + WS-NAME-LENGTH:1) = ":"
                 MOVE 1 TO L-FOUND
                 COMPUTE WS-VALUE-LENGTH = WS-END - WS-START - WS-NAME-LENGTH
                 MOVE L-TEXT(WS-START + WS-NAME-LENGTH + 1:WS-VALUE-LENGTH) TO L-VALUE
             END-IF
             COMPUTE WS-START = WS-I + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-OPT-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPT-SAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   PIC X(16384).
 01 WS-B                   PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-LA                  BINARY-LONG.
 01 WS-LB                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    PIC X(256).
 01 L-B                    PIC X(256).
 01 L-SAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-SAME.
     MOVE 0 TO L-SAME
     CALL "TEST-READ-FILE" USING L-A WS-A WS-CAPACITY WS-LA
     CALL "TEST-READ-FILE" USING L-B WS-B WS-CAPACITY WS-LB
     IF WS-LA > 0 AND WS-LA = WS-LB AND WS-A(1:WS-LA) = WS-B(1:WS-LB)
         MOVE 1 TO L-SAME
     END-IF
     GOBACK.
 END PROGRAM TEST-OPT-SAME.

*>   TEST-OPT-EXPECTED USING file name (PIC X(32)), row (1-based), key out (PIC X(40)), value out (PIC X(64)), found out
*>     (0 past the last): the row-th line of contract/fixtures/client/expected.txt for that file: "<file> <key> <value>".
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPT-EXPECTED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(256) VALUE "contract/fixtures/client/expected.txt".
 01 WS-TEXT                PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LINE                PIC X(160).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-FILE                PIC X(32).
 01 WS-KEY                 PIC X(40).
 01 WS-VALUE               PIC X(64).
 LINKAGE SECTION.
 01 L-FILE                 PIC X(32).
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(40).
 01 L-VALUE                PIC X(64).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-FILE L-ROW L-KEY L-VALUE L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE SPACES TO L-KEY L-VALUE
     CALL "TEST-READ-FILE" USING WS-PATH WS-TEXT WS-CAPACITY WS-LENGTH
     MOVE 1 TO WS-START
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LENGTH OR L-FOUND = 1
         IF WS-TEXT(WS-I:1) = X"0A"
             COMPUTE WS-LINE-LENGTH = WS-I - WS-START
             MOVE SPACES TO WS-LINE WS-FILE WS-KEY WS-VALUE
             IF WS-LINE-LENGTH > 0 AND WS-LINE-LENGTH <= 160 AND WS-TEXT(WS-START:1) NOT = "#"
                 MOVE WS-TEXT(WS-START:WS-LINE-LENGTH) TO WS-LINE
                 UNSTRING WS-LINE DELIMITED BY SPACE INTO WS-FILE WS-KEY WS-VALUE
                 IF WS-FILE = L-FILE
                     ADD 1 TO WS-COUNT
                     IF WS-COUNT = L-ROW
                         MOVE 1 TO L-FOUND
                         MOVE WS-KEY TO L-KEY
                         MOVE WS-VALUE TO L-VALUE
                     END-IF
                 END-IF
             END-IF
             COMPUTE WS-START = WS-I + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-OPT-EXPECTED.
