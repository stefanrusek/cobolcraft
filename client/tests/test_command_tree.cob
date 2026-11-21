*> Implementation test of the command tree and the suggestions (client/src/protocol-play.cob
*> COMMANDS-READ, SUGGESTIONS-READ; client/src/screens/chat.cob CHAT-SUGGEST; 05a 0x0F, 0x10;
*> 09 §3.3 command tree; the trees of 57-client-closures-4: everyone is the level 0 tree of 10.1, operator the level 4 tree of a dedicated server, 2396 nodes): a Commands packet
*> cut short leaves no tree; the whole operator tree is kept; the 91 commands are suggested (the chat shows the first CL-MAX-SUGGEST);
*> words follow argument nodes (teleport <location> ...), a greedy argument or an
*> unknown word ends the suggestions; an answer to an older request is dropped, tooltips are read
*> and not shown, a malformed answer leaves none; a line that needs no answer forgets the last.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-TREE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-VALUE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-E                   PIC Z(4)9.
 01 WS-STRING              PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

*>   Commands (everyone) without its last byte (the root index).
     MOVE "contract/fixtures/wire/play-s2c-10-commands-everyone.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
     SUBTRACT 1 FROM PB-LENGTH
     CALL "COMMANDS-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "/" TO CH-LINE
     MOVE 1 TO CH-LINE-LENGTH
     CALL "CHAT-SUGGEST" USING CLIENT-STATE
     MOVE "test command tree a Commands packet cut short leaves no tree, so nothing is suggested"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CM-COUNT * 100 + CS-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-10-commands-operator.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
     CALL "COMMANDS-READ" USING CLIENT-STATE PB-BUFFER
     CALL "CHAT-SUGGEST" USING CLIENT-STATE
     MOVE "test command tree / with the operator tree keeps all 91 commands, sorted by lower-cased text (the chat shows the first 10)"
         TO TL-CASE
     PERFORM SUGGESTED-TEXT
     MOVE "91 advancement attribute ban ban-ip banlist bossbar clear clone compute damage data datapack debug " &
         "defaultgamemode deop dialog difficulty effect enchant execute experience fetchprofile fill fillbiome forceload " &
         "function gamemode gamerule give help item kick kill list locate loot me msg op pardon pardon-ip particle perf " &
         "place playsound posteffect random recipe reload return ride rotate save-all save-off save-on say schedule " &
         "scoreboard seed setblock setidletimeout setworldspawn spawnpoint spectate spreadplayers stop stopsound " &
         "stopwatch summon swing tag team teammsg teleport tell tellraw test tick time title tm tp transfer trigger " &
         "version w waypoint weather whitelist worldborder xp"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "/execute positioned a" TO CH-LINE
     MOVE 21 TO CH-LINE-LENGTH
     CALL "CHAT-SUGGEST" USING CLIENT-STATE
     MOVE "test command tree after a literal word (execute positioned) the fixed words starting "
         & "with the typed one are suggested and the position argument asks nothing" TO TL-CASE
     PERFORM SUGGESTED-TEXT
     MOVE "1 as asked 0" TO TL-EXPECTED
     PERFORM ASKED-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "/teleport Alice 1 " TO CH-LINE
     MOVE 18 TO CH-LINE-LENGTH
     CALL "CHAT-SUGGEST" USING CLIENT-STATE
     MOVE "test command tree words follow argument nodes (teleport <location> then the next word): "
         & "nothing to suggest, nothing asked" TO TL-CASE
     PERFORM SUGGESTED-TEXT
     MOVE "0 asked 0" TO TL-EXPECTED
     PERFORM ASKED-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "/help hello th" TO CH-LINE
     MOVE 14 TO CH-LINE-LENGTH
     CALL "CHAT-SUGGEST" USING CLIENT-STATE
     MOVE "test command tree a greedy argument (help <command>) takes the rest of the line: "
         & "nothing suggested" TO TL-CASE
     PERFORM SUGGESTED-TEXT
     MOVE "0 asked 0" TO TL-EXPECTED
     PERFORM ASKED-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "/nosuch h" TO CH-LINE
     MOVE 9 TO CH-LINE-LENGTH
     CALL "CHAT-SUGGEST" USING CLIENT-STATE
     MOVE "test command tree an unknown command word ends the walk: nothing suggested" TO TL-CASE
     PERFORM SUGGESTED-TEXT
     MOVE "0 asked 0" TO TL-EXPECTED
     PERFORM ASKED-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   /trigger ob: the objective argument asks the server.
     MOVE "/trigger ob" TO CH-LINE
     MOVE 11 TO CH-LINE-LENGTH
     CALL "CHAT-SUGGEST" USING CLIENT-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "test command tree /trigger ob asks the server (transaction 1)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "0f010b2f74726967676572206f62" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An answer to transaction 0 (older): dropped.
     MOVE "Zed" TO WS-STRING
     MOVE 3 TO WS-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TEN
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TWO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-STRING WS-LENGTH WS-MAX
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "SUGGESTIONS-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "test command tree an answer to an older request is dropped" TO TL-CASE
     PERFORM ANSWERS-TEXT
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The answer to transaction 1: Alice (with a tooltip) and Alan.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TEN
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TWO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TWO
     MOVE "Alice" TO WS-STRING
     MOVE 5 TO WS-LENGTH
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-STRING WS-LENGTH WS-MAX
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE "online" TO PB-TX-VALUE
     MOVE 6 TO PB-TX-LENGTH
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     MOVE "Alan" TO WS-STRING
     MOVE 4 TO WS-LENGTH
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-STRING WS-LENGTH WS-MAX
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "SUGGESTIONS-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "test command tree the answer's suggestions are kept, a tooltip read and not shown"
         TO TL-CASE
     PERFORM ANSWERS-TEXT
     MOVE "2 Alice Alan" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The same answer cut inside its first suggestion.
     MOVE 9 TO PB-LENGTH
     MOVE 0 TO PB-POS PB-ERROR
     CALL "SUGGESTIONS-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "test command tree a malformed answer leaves no answers" TO TL-CASE
     PERFORM ANSWERS-TEXT
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2 TO CS-ANSWERS
     MOVE "/trigger" TO CH-LINE
     MOVE 8 TO CH-LINE-LENGTH
     CALL "CHAT-SUGGEST" USING CLIENT-STATE
     MOVE "test command tree a line that needs no answer forgets the question and its answers"
         TO TL-CASE
     PERFORM SUGGESTED-TEXT
     MOVE CS-ANSWERS TO WS-E
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " answers " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 trigger answers 0 asked 0" TO TL-EXPECTED
     PERFORM ASKED-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SUGGESTED-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE CS-COUNT TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CS-COUNT
         MOVE CS-LENGTH(WS-I) TO WS-K
         STRING FUNCTION TRIM(TL-OBSERVED) " " CS-TEXT(WS-I)(1:WS-K) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     .

*> Appends " asked <length of the line last asked about>" to TL-OBSERVED.
 ASKED-TEXT.
     MOVE CS-ASKED-LENGTH TO WS-E
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " asked " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     .

 ANSWERS-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE CS-ANSWERS TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CS-ANSWERS
         MOVE CS-A-LENGTH(WS-I) TO WS-K
         STRING FUNCTION TRIM(TL-OBSERVED) " " CS-A-TEXT(WS-I)(1:WS-K) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     .
 END PROGRAM TEST-COMMAND-TREE.
 COPY CLTEST.
