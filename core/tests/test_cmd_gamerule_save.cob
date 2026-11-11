*> Acceptance test of the persistence of the game rules (docs/protocol/07-nbt-and-anvil.md §9.2 GameRules): level.dat holds one entry for each rule that is not at its default
*> (a Byte for a boolean, an Int for an integer rule), an absent entry is the default, and reading the file sets the rules again. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-GAMERULE-SAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 COPY BRRULES.
 01 WS-SUF                 PIC X(128).
 01 WS-PATHL               PIC X(1100).
 01 WS-PLEN                BINARY-LONG.
 01 WS-FILE                PIC X(256).
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH2               PIC X(128).
 01 WS-BIG                 PIC X(8192).
 01 WS-RULE-NAME           PIC X(40).
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-CAPACITY2           BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "CORE-SAVE"
     PERFORM READ-RULES
     MOVE "acceptance US13 /gamerule a world with every rule at its def" & "ault saves an empty GameRules compound" TO TL-CASE
     CONTINUE
     MOVE "{}" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule a boolean rule changed" TO TL-CASE
     MOVE "gamerule keep_inventory true" TO WS-LINE
     MOVE "commands.gamerule.set(keep_inventory,true)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule an integer rule changed" TO TL-CASE
     MOVE "gamerule max_command_forks 100" TO WS-LINE
     MOVE "commands.gamerule.set(max_command_forks,100)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule a rule whose name is longer than 3" & "2 characters" TO TL-CASE
     MOVE "gamerule allow_entering_nether_using_portals false" TO WS-LINE
     MOVE "commands.gamerule.set(allow_entering_nether_using_portals,fa" & "lse)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "CORE-SAVE"
     PERFORM READ-RULES
     MOVE "acceptance US13 /gamerule the saved compound holds the three" & " rules that differ" TO TL-CASE
     CONTINUE
     MOVE "{allow_entering_nether_using_portals:0,keep_inventory:1,max_" & "command_forks:100}" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "RULES-RESET"
     MOVE "keep_inventory" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-VALUE
     MOVE "acceptance US13 /gamerule a reset puts keep_inventory back t" & "o false" TO TL-CASE
     MOVE WS-RULE-VALUE TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "LEVEL-DAT-READ"
     MOVE "keep_inventory" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-VALUE
     MOVE "acceptance US13 /gamerule reading the file sets keep_invento" & "ry again" TO TL-CASE
     MOVE WS-RULE-VALUE TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "max_command_forks" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-VALUE
     MOVE "acceptance US13 /gamerule and max_command_forks" TO TL-CASE
     MOVE WS-RULE-VALUE TO WS-NUM
     MOVE 100 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "fall_damage" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-VALUE
     MOVE "acceptance US13 /gamerule a rule that was not saved keeps it" & "s default (fall_damage true)" TO TL-CASE
     MOVE WS-RULE-VALUE TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "no_such_rule" TO WS-RULE-NAME
     MOVE "no_such_rule" TO WS-PATH2
     MOVE 12 TO WS-PLEN
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-PATH2 WS-PLEN WS-ROOT
     MOVE "fall_damage" TO WS-PATH2
     MOVE 11 TO WS-PLEN
     MOVE 0 TO WS-ROOT
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-PATH2 WS-PLEN WS-ROOT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "RULES-NBT-READ" USING PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "fall_damage" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-VALUE
     MOVE "acceptance US13 /gamerule a rule the game does not know is s" & "kipped and the next entry is read (fall_damage false)" TO TL-CASE
     MOVE WS-RULE-VALUE TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     GOBACK.

*> WS-TEXT: the GameRules compound of the saved level.dat.
 READ-RULES.
     MOVE "/level.dat" TO WS-SUF
     CALL "PERSIST-PATH" USING WS-SUF WS-PATHL WS-PLEN
     MOVE WS-PATHL(1:256) TO WS-FILE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE "GameRules" TO WS-PATH2
     MOVE SPACES TO WS-BIG
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH2 WS-BIG
     MOVE WS-BIG(1:200) TO WS-TEXT
     CALL "PB-FREE" USING PB-BUFFER.
 END PROGRAM TEST-CMD-GAMERULE-SAVE.

 COPY CORETEST.
 COPY CMDTEST.
