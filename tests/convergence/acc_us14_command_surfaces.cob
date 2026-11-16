*> Convergence acceptance test of SC-009 and US14-1 on the surfaces of a server (docs/protocol 15 and
*> 16 section 3: the standard commands; the command set itself is covered by the command tests of
*> core/tests and by acc_f2us13_commands; the client's chat lines hold translation keys): the server console, the chat of a Player with operator
*> status (Alice, op at the console) and the chat of a Player without it (Bobby). Each surface runs
*> the standard gamemode command on Bobby through its own entry and Bobby's client shows the effect;
*> Bobby's gamemode is refused (the mode stays) and his msg command, a level-0 command, works; the
*> console's say reaches both Players' chat.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-COMMAND-SURFACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us14-command-surfaces".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-CONF                PIC X(1024)
     VALUE "view-distance=2|hostile-mobs=false|default-game-mode=survival|world-type=cobolcraft".
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-LINE                PIC X(256).
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CHAT-A              PIC X(4096).
 01 WS-CHAT-B              PIC X(4096).
 01 WS-HITS                BINARY-LONG.
 01 WS-MODE-1              BINARY-LONG.
 01 WS-MODE-2              BINARY-LONG.
 01 WS-MODE-3              BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     MOVE "op Alice" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     CALL "CV-STEP" USING CONVH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         CALL "CV-JOIN" USING CONVH WS-I CV-PORT
         CALL "CV-UNTIL-PLAY" USING CONVH WS-I WS-JOINED
     END-PERFORM
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "T" TO TL-MODE

*>   Surface 1: the server console.
     MOVE "gamemode creative Bobby" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     MOVE 8 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-MODE TO WS-MODE-1

*>   Surface 2: the chat of the operator.
     MOVE "/gamemode survival Bobby" TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-LENGTH
     MOVE 8 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-MODE TO WS-MODE-2

*>   Surface 3: the chat of a Player without operator status: refused.
     MOVE "/gamemode creative Bobby" TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
     CALL "CV-SAY" USING CONVH WS-BOBBY WS-TEXT WS-LENGTH
     MOVE 8 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-MODE TO WS-MODE-3
     MOVE "acceptance US14-1 SC-009 given the console, an operator and a Player without operator "
         & "status when each runs gamemode on Bobby then the console and the operator change his "
         & "mode (creative, survival) and the refused Player's attempt leaves it" TO TL-CASE
     MOVE "console 1 operator 0 refused 0" TO TL-EXPECTED
     MOVE WS-MODE-1 TO WS-E1
     MOVE WS-MODE-2 TO WS-E2
     MOVE WS-MODE-3 TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "console " FUNCTION TRIM(WS-E1) " operator " FUNCTION TRIM(WS-E2) " refused "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A level-0 command (msg) works from the Player without operator status.
     MOVE "/msg Alice surfacehello" TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
     CALL "CV-SAY" USING CONVH WS-BOBBY WS-TEXT WS-LENGTH
     MOVE 8 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-CHAT-A
     MOVE 0 TO WS-HITS
     INSPECT WS-CHAT-A TALLYING WS-HITS FOR ALL "commands.message.display.incoming"
     MOVE "acceptance US14-1 given a Player without operator status when they run msg (level 0) "
         & "then the other Player's chat shows the incoming message line" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The console's say reaches both Players' chat.
     MOVE "say consolehello" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     MOVE 8 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-CHAT-A
     CALL "CV-CHAT-LOG" USING CONVH WS-BOBBY WS-CHAT-B
     MOVE 0 TO WS-HITS
     INSPECT WS-CHAT-A TALLYING WS-HITS FOR ALL "chat.type.announcement"
     MOVE 0 TO WS-N
     INSPECT WS-CHAT-B TALLYING WS-N FOR ALL "chat.type.announcement"
     MOVE "acceptance US14-1 given the server console when it runs say then both Players' chat "
         & "shows the announcement line" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS > 0
         ADD 10 TO TL-OBSERVED-N
     END-IF
     IF WS-N > 0
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CV-SERVER-STOP" USING CONVH
     STOP RUN.
 END PROGRAM ACC-US14-COMMAND-SURFACES.
