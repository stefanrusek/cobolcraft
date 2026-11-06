*> Convergence acceptance test of US6-1 and SC-006 (spec.md US6; standin-content §4.4, §17 player chat
*> stays literal): two Players, the host of a single-player world (Alice) and a second client on a
*> further memory connection of the same core (Bobby), exchange messages through the chat control
*> (T, typing, Enter); each client's received chat shows every message as "<name> message", and
*> messages sent by both in the same frames arrive at both clients in the same order.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US6-CHAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us6-chat".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 19.
 01 WS-NAME                PIC X(16).
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Chat".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 4.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED-A            BINARY-LONG.
 01 WS-JOINED-B            BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT-B              PIC X(64).
 01 WS-LENGTH-B            BINARY-LONG.
 01 WS-LOG-A               PIC X(4096).
 01 WS-LOG-B               PIC X(4096).
 01 WS-ROUND               BINARY-LONG.
 01 WS-EDIT                PIC 9.
 01 WS-EDIT-B              PIC 9.
 01 WS-SAME                PIC 9.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-BOBBY
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED-A
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED-B
     CALL "CV-STEPS" USING CONVH WS-TEN

*>   US6-1: each sends one message; both see both, as "<name> message", the sender included.
     MOVE "hello from Alice" TO WS-TEXT
     MOVE 16 TO WS-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-LENGTH
     CALL "CV-STEPS" USING CONVH WS-TEN
     MOVE "and hello from Bobby" TO WS-TEXT
     MOVE 20 TO WS-LENGTH
     CALL "CV-SAY" USING CONVH WS-BOBBY WS-TEXT WS-LENGTH
     CALL "CV-STEPS" USING CONVH WS-TEN
     CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-LOG-A
     CALL "CV-CHAT-LOG" USING CONVH WS-BOBBY WS-LOG-B
     MOVE "acceptance US6-1 given two Players in the world when each opens chat, types a message "
         & "and sends it then both see both messages as <name> message, the sender included"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "joined 1 1 Alice sees <Alice> hello from Alice|<Bobby> and hello from Bobby Bobby sees "
         & "<Alice> hello from Alice|<Bobby> and hello from Bobby" TO TL-EXPECTED
     MOVE WS-JOINED-A TO WS-EDIT
     MOVE WS-JOINED-B TO WS-EDIT-B
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " WS-EDIT " " WS-EDIT-B " Alice sees " FUNCTION TRIM(WS-LOG-A)
         " Bobby sees " FUNCTION TRIM(WS-LOG-B) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   SC-006: three rounds in which both send in the same frames.
     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > 3
         MOVE WS-ROUND TO WS-EDIT
         MOVE SPACES TO WS-TEXT WS-TEXT-B
         STRING "a" WS-EDIT DELIMITED BY SIZE INTO WS-TEXT
         STRING "b" WS-EDIT DELIMITED BY SIZE INTO WS-TEXT-B
         MOVE 2 TO WS-LENGTH WS-LENGTH-B
         CALL "SAY-BOTH" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-BOBBY WS-TEXT-B WS-LENGTH-B
     END-PERFORM
     CALL "CV-STEPS" USING CONVH WS-TEN
     CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-LOG-A
     CALL "CV-CHAT-LOG" USING CONVH WS-BOBBY WS-LOG-B
     MOVE "SC-006 given two Players sending messages in the same frames when they arrive then "
         & "every message is seen by every connected player in the same order" TO TL-CASE
     MOVE "same 1 count 8" TO TL-EXPECTED
     MOVE 0 TO WS-ROUND
     INSPECT WS-LOG-A TALLYING WS-ROUND FOR ALL "<"
     MOVE 0 TO WS-SAME
     IF WS-LOG-A = WS-LOG-B
         MOVE 1 TO WS-SAME
     END-IF
     MOVE WS-ROUND TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING "same " WS-SAME " count " WS-EDIT DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-SAME = 0
         MOVE 16 TO WS-PTR
         STRING " Alice " FUNCTION TRIM(WS-LOG-A) " Bobby "
             FUNCTION TRIM(WS-LOG-B) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 END PROGRAM ACC-US6-CHAT.

*> SAY-BOTH USING CONVH, client a, text a (PIC X(64)), length a, client b, text b, length b: both
*> open chat in one frame, type in the next and press Enter in the third (test infrastructure).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SAY-BOTH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-TEXT-KIND           BINARY-LONG VALUE CC-EV-TEXT.
 01 WS-X                   FLOAT-SHORT VALUE 0.
 01 WS-Y                   FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-A                    BINARY-LONG.
 01 L-TEXT-A               PIC X(64).
 01 L-LENGTH-A             BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-TEXT-B               PIC X(64).
 01 L-LENGTH-B             BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-A L-TEXT-A L-LENGTH-A L-B L-TEXT-B L-LENGTH-B.
     MOVE CC-KEY-T TO WS-KEY
     CALL "CV-QUEUE" USING CONVH L-A WS-DOWN WS-KEY WS-X WS-Y
     CALL "CV-QUEUE" USING CONVH L-A WS-UP WS-KEY WS-X WS-Y
     CALL "CV-QUEUE" USING CONVH L-B WS-DOWN WS-KEY WS-X WS-Y
     CALL "CV-QUEUE" USING CONVH L-B WS-UP WS-KEY WS-X WS-Y
     CALL "CV-STEP" USING CONVH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH-A
         COMPUTE WS-CODE = FUNCTION ORD(L-TEXT-A(WS-I:1)) - 1
         CALL "CV-QUEUE" USING CONVH L-A WS-TEXT-KIND WS-CODE WS-X WS-Y
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH-B
         COMPUTE WS-CODE = FUNCTION ORD(L-TEXT-B(WS-I:1)) - 1
         CALL "CV-QUEUE" USING CONVH L-B WS-TEXT-KIND WS-CODE WS-X WS-Y
     END-PERFORM
     CALL "CV-STEP" USING CONVH
     MOVE CC-KEY-ENTER TO WS-KEY
     CALL "CV-QUEUE" USING CONVH L-A WS-DOWN WS-KEY WS-X WS-Y
     CALL "CV-QUEUE" USING CONVH L-A WS-UP WS-KEY WS-X WS-Y
     CALL "CV-QUEUE" USING CONVH L-B WS-DOWN WS-KEY WS-X WS-Y
     CALL "CV-QUEUE" USING CONVH L-B WS-UP WS-KEY WS-X WS-Y
     CALL "CV-STEP" USING CONVH
     GOBACK.
 END PROGRAM SAY-BOTH.
