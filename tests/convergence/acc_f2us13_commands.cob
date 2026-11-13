*> Convergence acceptance test of US13-1 and US13-3 (spec 002 FR-034; SC-008; 15 §14 the command tree and its
*> permission levels, 16 §6.1 give): the server program on loopback with two clients. Alice is made an operator at the
*> console (level 4, the default operator level); Bobby is not (level 0). Each receives the Commands packet built for
*> their level: Alice's tree holds commands that Bobby's does not (give, op, stop), Bobby's holds the level-0 ones
*> (msg, list). Alice types /give and the chat line offers the server's completions; the command runs end to end:
*> the world gives her the items and the confirmation comes back to her chat. Bobby's attempt to run it is refused.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US13-COMMANDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us13-commands".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-CONF                PIC X(1024)
     VALUE "view-distance=2|hostile-mobs=false|default-game-mode=survival|world-type=cobolcraft".
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-LINE                PIC X(256).
 01 WS-JOINED              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SUGGESTED           PIC X(1024).
 01 WS-CHAT                PIC X(4096).
 01 WS-ITEM                BINARY-LONG.
 01 WS-CORE-TOTAL          BINARY-LONG.
 01 WS-CLIENT-TOTAL        BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-A-COUNT             BINARY-LONG.
 01 WS-B-COUNT             BINARY-LONG.
 01 WS-WORD                PIC X(32).
 01 WS-WORD-LENGTH         BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-K                  BINARY-LONG.
 01 WS-L                  BINARY-LONG.
 01 WS-A-GIVE              PIC 9.
 01 WS-A-MSG               PIC 9.
 01 WS-A-STOP              PIC 9.
 01 WS-B-GIVE              PIC 9.
 01 WS-B-MSG               PIC 9.
 01 WS-B-STOP              PIC 9.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
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

*>   US13-3: each client's tree is the one built for their level: root commands by name.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE CM-COUNT TO WS-A-COUNT
     MOVE "give" TO WS-WORD
     MOVE 4 TO WS-WORD-LENGTH
     PERFORM HAS-ROOT
     MOVE WS-HAS TO WS-A-GIVE
     MOVE "msg" TO WS-WORD
     MOVE 3 TO WS-WORD-LENGTH
     PERFORM HAS-ROOT
     MOVE WS-HAS TO WS-A-MSG
     MOVE "stop" TO WS-WORD
     MOVE 4 TO WS-WORD-LENGTH
     PERFORM HAS-ROOT
     MOVE WS-HAS TO WS-A-STOP
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE CM-COUNT TO WS-B-COUNT
     MOVE "give" TO WS-WORD
     MOVE 4 TO WS-WORD-LENGTH
     PERFORM HAS-ROOT
     MOVE WS-HAS TO WS-B-GIVE
     MOVE "msg" TO WS-WORD
     MOVE 3 TO WS-WORD-LENGTH
     PERFORM HAS-ROOT
     MOVE WS-HAS TO WS-B-MSG
     MOVE "stop" TO WS-WORD
     MOVE 4 TO WS-WORD-LENGTH
     PERFORM HAS-ROOT
     MOVE WS-HAS TO WS-B-STOP
     MOVE "acceptance US13-3 given a level-4 operator and a level-0 Player on one server when both have "
         & "joined then both clients hold a command tree" TO TL-CASE
     MOVE "both trees held 1" TO TL-EXPECTED
     MOVE "both trees held 0" TO TL-OBSERVED
     IF WS-A-COUNT > 0 AND WS-B-COUNT > 0
         MOVE "both trees held 1" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13-3 given the two trees when their root commands are looked up then the "
         & "operator's holds give and stop and msg, the level-0 Player's only msg" TO TL-CASE
     MOVE "alice give 1 msg 1 stop 1 | bobby give 0 msg 1 stop 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "alice give " WS-A-GIVE " msg " WS-A-MSG " stop " WS-A-STOP " | bobby give " WS-B-GIVE
         " msg " WS-B-MSG " stop " WS-B-STOP DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13-3 given the two trees when their sizes are compared then the operator's is "
         & "larger than the level-0 Player's" TO TL-CASE
     MOVE "alice larger 1" TO TL-EXPECTED
     MOVE "alice larger 0" TO TL-OBSERVED
     IF WS-A-COUNT > WS-B-COUNT
         MOVE "alice larger 1" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US13-1: /gi in the operator's chat line offers give from the tree; the completion of the player argument
*>   comes from the server.
     MOVE "/gi" TO WS-TEXT
     MOVE 3 TO WS-LENGTH
     CALL "F2CD-SUGGEST" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-SUGGESTED
     MOVE "acceptance US13-1 given the operator types the command prefix gi when the chat line is open "
         & "then give is among the suggestions" TO TL-CASE
     MOVE "give" TO TL-EXPECTED
     MOVE WS-SUGGESTED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/give Al" TO WS-TEXT
     MOVE 8 TO WS-LENGTH
     CALL "F2CD-SUGGEST" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-SUGGESTED
     MOVE "acceptance US13-1 given the operator types give and the start of a player name when the "
         & "server answers then Alice is among the completions" TO TL-CASE
     MOVE "Alice" TO TL-EXPECTED
     MOVE WS-SUGGESTED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US13-1: /give runs end to end: 3 dump_shards (item 15) into Alice's inventory in the world and in her client,
*>   with the server's confirmation in her chat.
     MOVE 15 TO WS-ITEM
     CALL "F2CD-CORE-TOTAL" USING WS-NAME WS-ITEM WS-BEFORE
     MOVE "/give Alice cobolcraft:dump_shard 3" TO WS-TEXT
     MOVE 35 TO WS-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-TEXT WS-LENGTH
     MOVE 8 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "Alice" TO WS-NAME
     CALL "F2CD-CORE-TOTAL" USING WS-NAME WS-ITEM WS-CORE-TOTAL
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO WS-CLIENT-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-I) = WS-ITEM
             ADD PL-SLOT-COUNT(WS-I) TO WS-CLIENT-TOTAL
         END-IF
     END-PERFORM
     COMPUTE WS-CORE-TOTAL = WS-CORE-TOTAL - WS-BEFORE
     MOVE "acceptance US13-1 given the operator runs give for 3 dump_shards when the command is "
         & "carried out then the world and her client both hold 3 more" TO TL-CASE
     MOVE "gave 3 client 3" TO TL-EXPECTED
     MOVE WS-CORE-TOTAL TO WS-E1
     MOVE WS-CLIENT-TOTAL TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "gave " FUNCTION TRIM(WS-E1) " client " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-CHAT
     MOVE "acceptance US13-1 given the give command succeeded when Alice reads her chat then it holds "
         & "the server's confirmation commands.give.success.single" TO TL-CASE
     MOVE "found" TO TL-EXPECTED
     MOVE "missing" TO TL-OBSERVED
     MOVE 0 TO WS-HAS
     INSPECT WS-CHAT TALLYING WS-HAS FOR ALL "commands.give.success.single"
     IF WS-HAS > 0
         MOVE "found" TO TL-OBSERVED
     ELSE
         MOVE WS-CHAT(1:200) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US13-3: the level-0 Player's give is refused: nothing is given.
     MOVE "Bobby" TO WS-NAME
     CALL "F2CD-CORE-TOTAL" USING WS-NAME WS-ITEM WS-BEFORE
     MOVE "/give Bobby cobolcraft:dump_shard 3" TO WS-TEXT
     MOVE 35 TO WS-LENGTH
     CALL "CV-SAY" USING CONVH WS-BOBBY WS-TEXT WS-LENGTH
     MOVE 8 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "F2CD-CORE-TOTAL" USING WS-NAME WS-ITEM WS-CORE-TOTAL
     COMPUTE WS-CORE-TOTAL = WS-CORE-TOTAL - WS-BEFORE
     MOVE "acceptance US13-3 given a level-0 Player when they run give then it is refused and nothing "
         & "is given" TO TL-CASE
     MOVE "gave 0" TO TL-EXPECTED
     MOVE WS-CORE-TOTAL TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "gave " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   WS-HAS: 1 when the root of the client's tree has a child with the name WS-WORD.
 HAS-ROOT.
     MOVE 0 TO WS-HAS
     IF CM-COUNT > 0
         COMPUTE WS-N = CM-ROOT + 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CM-CHILDREN(WS-N)
             COMPUTE WS-K = CM-FIRST(WS-N) + WS-I - 1
             COMPUTE WS-K = CM-LINK(WS-K) + 1
             IF WS-K <= CM-COUNT
                 IF CM-NAME-LENGTH(WS-K) = WS-WORD-LENGTH
                     MOVE CM-NAME-LENGTH(WS-K) TO WS-L
                     IF CM-NAME(WS-K)(1:WS-L) = WS-WORD(1:WS-L)
                         MOVE 1 TO WS-HAS
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-IF.
 END PROGRAM ACC-F2US13-COMMANDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2CD-SUGGEST.
*> USING CONVH, client index, line text (PIC X(64), with its leading /), length, out (PIC X(1024)): the chat opened
*> (T), the line typed, three frames; the local suggestions then the server's answers, space-separated; the chat
*> closed (Escape).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-T                   BINARY-LONG VALUE CC-KEY-T.
 01 WS-ESCAPE              BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-OUT                  PIC X(1024).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT L-LENGTH L-OUT.
     CALL "CV-KEY" USING CONVH L-INDEX WS-T
     CALL "CV-TYPE" USING CONVH L-INDEX L-TEXT L-LENGTH
     CALL "CV-STEPS" USING CONVH WS-THREE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE SPACES TO L-OUT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CS-COUNT
         MOVE CS-LENGTH(WS-I) TO WS-LENGTH
         IF WS-I > 1
             STRING " " DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
         END-IF
         STRING CS-TEXT(WS-I)(1:WS-LENGTH) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CS-ANSWERS
         MOVE CS-A-LENGTH(WS-I) TO WS-LENGTH
         IF WS-PTR > 1
             STRING " " DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
         END-IF
         STRING CS-A-TEXT(WS-I)(1:WS-LENGTH) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
     END-PERFORM
     CALL "CV-KEY" USING CONVH L-INDEX WS-ESCAPE
     GOBACK.
 END PROGRAM F2CD-SUGGEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2CD-CORE-TOTAL.
*> USING name (PIC X(16)), item, total out: the count of the item over that online player's 36 slots in the world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-R                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-ITEM                 BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ITEM L-TOTAL.
     MOVE 0 TO WS-P L-TOTAL
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64 OR WS-P > 0
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = L-NAME
             MOVE WS-R TO WS-P
         END-IF
     END-PERFORM
     IF WS-P > 0
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
             IF PL-SLOT-ITEM(WS-P, WS-S) = L-ITEM
                 ADD PL-SLOT-COUNT(WS-P, WS-S) TO L-TOTAL
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM F2CD-CORE-TOTAL.
