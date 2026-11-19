*> Test of the node counts per command of the core's command tree (docs/protocol/57-client-closures-4 sections 6.1 and 7; T2014): for each of the 86 commands of the dedicated
*> server's tree the requirement level of its root literal and the number of
*> nodes of its subtree (the unmerged tree nodes of the heading of each part of section 7). Every command has the document's count: the grammars of execute, data, time, test (built from
*> the listing by BR-DOC-FILL, the forms the core does not run report cobolcraft.command.unsupported), random, clone, compute, swing, dialog and debug were brought to it, and
*> gamerule has the 58 rules of the default feature set (max_minecart_speed needs minecraft:minecart_improvements, BRFEAT.cpy).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-TREE-COMMANDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRIGADIER.
 01 WS-TABLE.
    05 FILLER              PIC X(24) VALUE "advancement 2 25".
    05 FILLER              PIC X(24) VALUE "attribute 2 24".
    05 FILLER              PIC X(24) VALUE "execute 2 289".
    05 FILLER              PIC X(24) VALUE "bossbar 2 39".
    05 FILLER              PIC X(24) VALUE "clear 2 4".
    05 FILLER              PIC X(24) VALUE "clone 2 123".
    05 FILLER              PIC X(24) VALUE "compute 2 21".
    05 FILLER              PIC X(24) VALUE "damage 2 10".
    05 FILLER              PIC X(24) VALUE "data 2 752".
    05 FILLER              PIC X(24) VALUE "datapack 2 17".
    05 FILLER              PIC X(24) VALUE "debug 3 5".
    05 FILLER              PIC X(24) VALUE "defaultgamemode 2 2".
    05 FILLER              PIC X(24) VALUE "dialog 2 6".
    05 FILLER              PIC X(24) VALUE "difficulty 2 5".
    05 FILLER              PIC X(24) VALUE "effect 2 13".
    05 FILLER              PIC X(24) VALUE "me 0 2".
    05 FILLER              PIC X(24) VALUE "enchant 2 4".
    05 FILLER              PIC X(24) VALUE "experience 2 15".
    05 FILLER              PIC X(24) VALUE "fill 2 15".
    05 FILLER              PIC X(24) VALUE "fillbiome 2 6".
    05 FILLER              PIC X(24) VALUE "forceload 2 10".
    05 FILLER              PIC X(24) VALUE "function 2 13".
    05 FILLER              PIC X(24) VALUE "gamemode 2 3".
    05 FILLER              PIC X(24) VALUE "gamerule 2 233".
    05 FILLER              PIC X(24) VALUE "give 2 4".
    05 FILLER              PIC X(24) VALUE "help 0 2".
    05 FILLER              PIC X(24) VALUE "item 2 103".
    05 FILLER              PIC X(24) VALUE "kick 3 3".
    05 FILLER              PIC X(24) VALUE "kill 2 2".
    05 FILLER              PIC X(24) VALUE "list 0 2".
    05 FILLER              PIC X(24) VALUE "locate 2 7".
    05 FILLER              PIC X(24) VALUE "loot 2 121".
    05 FILLER              PIC X(24) VALUE "msg 0 3".
    05 FILLER              PIC X(24) VALUE "swing 2 8".
    05 FILLER              PIC X(24) VALUE "particle 2 10".
    05 FILLER              PIC X(24) VALUE "place 2 20".
    05 FILLER              PIC X(24) VALUE "playsound 2 68".
    05 FILLER              PIC X(24) VALUE "posteffect 2 11".
    05 FILLER              PIC X(24) VALUE "random 0 16".
    05 FILLER              PIC X(24) VALUE "reload 2 1".
    05 FILLER              PIC X(24) VALUE "recipe 2 9".
    05 FILLER              PIC X(24) VALUE "fetchprofile 2 7".
    05 FILLER              PIC X(24) VALUE "return 2 4".
    05 FILLER              PIC X(24) VALUE "ride 2 5".
    05 FILLER              PIC X(24) VALUE "rotate 2 8".
    05 FILLER              PIC X(24) VALUE "say 2 2".
    05 FILLER              PIC X(24) VALUE "schedule 2 8".
    05 FILLER              PIC X(24) VALUE "scoreboard 2 70".
    05 FILLER              PIC X(24) VALUE "seed 2 1".
    05 FILLER              PIC X(24) VALUE "version 2 1".
    05 FILLER              PIC X(24) VALUE "setblock 2 7".
    05 FILLER              PIC X(24) VALUE "spawnpoint 2 4".
    05 FILLER              PIC X(24) VALUE "setworldspawn 2 3".
    05 FILLER              PIC X(24) VALUE "spectate 2 3".
    05 FILLER              PIC X(24) VALUE "spreadplayers 2 10".
    05 FILLER              PIC X(24) VALUE "stopsound 2 26".
    05 FILLER              PIC X(24) VALUE "stopwatch 2 10".
    05 FILLER              PIC X(24) VALUE "summon 2 4".
    05 FILLER              PIC X(24) VALUE "tag 2 7".
    05 FILLER              PIC X(24) VALUE "team 2 45".
    05 FILLER              PIC X(24) VALUE "teammsg 0 2".
    05 FILLER              PIC X(24) VALUE "teleport 2 12".
    05 FILLER              PIC X(24) VALUE "tellraw 2 3".
    05 FILLER              PIC X(24) VALUE "test 2 48".
    05 FILLER              PIC X(24) VALUE "tick 3 12".
    05 FILLER              PIC X(24) VALUE "time 2 30".
    05 FILLER              PIC X(24) VALUE "title 2 14".
    05 FILLER              PIC X(24) VALUE "trigger 0 6".
    05 FILLER              PIC X(24) VALUE "waypoint 2 13".
    05 FILLER              PIC X(24) VALUE "weather 2 7".
    05 FILLER              PIC X(24) VALUE "worldborder 2 20".
    05 FILLER              PIC X(24) VALUE "ban-ip 3 3".
    05 FILLER              PIC X(24) VALUE "banlist 3 3".
    05 FILLER              PIC X(24) VALUE "ban 3 3".
    05 FILLER              PIC X(24) VALUE "deop 3 2".
    05 FILLER              PIC X(24) VALUE "op 3 2".
    05 FILLER              PIC X(24) VALUE "pardon 3 2".
    05 FILLER              PIC X(24) VALUE "pardon-ip 3 2".
    05 FILLER              PIC X(24) VALUE "perf 4 3".
    05 FILLER              PIC X(24) VALUE "save-all 4 2".
    05 FILLER              PIC X(24) VALUE "save-off 4 1".
    05 FILLER              PIC X(24) VALUE "save-on 4 1".
    05 FILLER              PIC X(24) VALUE "setidletimeout 3 2".
    05 FILLER              PIC X(24) VALUE "stop 4 1".
    05 FILLER              PIC X(24) VALUE "transfer 3 4".
    05 FILLER              PIC X(24) VALUE "whitelist 3 9".
 01 WS-ROWS REDEFINES WS-TABLE.
    05 WS-ROW              PIC X(24) OCCURS 86 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-LEVEL-TEXT          PIC X(4).
 01 WS-COUNT-TEXT          PIC X(8).
 01 WS-CORE-TEXT           PIC X(8).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-STACK.
    05 WS-NEXT-NODE        BINARY-LONG OCCURS 64 TIMES.
 01 WS-SIZE                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-POS                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "BR-TREE-RESET"
     CALL "BR-STD-TREE"
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 86
         MOVE SPACES TO WS-NAME WS-LEVEL-TEXT WS-COUNT-TEXT WS-CORE-TEXT
         UNSTRING WS-ROW(WS-I) DELIMITED BY SPACE INTO WS-NAME WS-LEVEL-TEXT WS-COUNT-TEXT WS-CORE-TEXT
         MOVE 0 TO WS-NAME-LENGTH
         INSPECT WS-NAME TALLYING WS-NAME-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
*>       the root literal of that name
         MOVE 0 TO WS-ROOT
         MOVE BR-N-FIRST(1) TO WS-CHILD
         PERFORM UNTIL WS-CHILD = 0
             IF BR-N-NAME-LENGTH(WS-CHILD) = WS-NAME-LENGTH AND BR-N-NAME(WS-CHILD)(1:WS-NAME-LENGTH) = WS-NAME(1:WS-NAME-LENGTH)
                 MOVE WS-CHILD TO WS-ROOT
             END-IF
             MOVE BR-N-NEXT(WS-CHILD) TO WS-CHILD
         END-PERFORM
         MOVE 0 TO WS-SIZE WS-LEVEL
         IF WS-ROOT > 0
             MOVE BR-N-LEVEL(WS-ROOT) TO WS-LEVEL
             MOVE 1 TO WS-SIZE
             MOVE 1 TO WS-DEPTH
             MOVE BR-N-FIRST(WS-ROOT) TO WS-NEXT-NODE(1)
             PERFORM UNTIL WS-DEPTH = 0
                 MOVE WS-NEXT-NODE(WS-DEPTH) TO WS-CHILD
                 IF WS-CHILD = 0
                     SUBTRACT 1 FROM WS-DEPTH
                 ELSE
                     MOVE BR-N-NEXT(WS-CHILD) TO WS-NEXT-NODE(WS-DEPTH)
                     ADD 1 TO WS-SIZE
                     IF BR-N-FIRST(WS-CHILD) > 0
                         ADD 1 TO WS-DEPTH
                         MOVE BR-N-FIRST(WS-CHILD) TO WS-NEXT-NODE(WS-DEPTH)
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
         MOVE WS-LEVEL TO WS-E1
         MOVE WS-SIZE TO WS-E2
         MOVE SPACES TO TL-CASE TL-OBSERVED TL-EXPECTED
         IF WS-CORE-TEXT = SPACES
             STRING "test command tree commands " FUNCTION TRIM(WS-NAME) " has the requirement level and the subtree nodes of the document"
                 DELIMITED BY SIZE INTO TL-CASE
             STRING FUNCTION TRIM(WS-LEVEL-TEXT) " " FUNCTION TRIM(WS-COUNT-TEXT) DELIMITED BY SIZE INTO TL-EXPECTED
         ELSE
             STRING "test command tree commands " FUNCTION TRIM(WS-NAME) " known gap: the grammar has the nodes of the core (the vanilla tree has "
                 FUNCTION TRIM(WS-COUNT-TEXT) ")" DELIMITED BY SIZE INTO TL-CASE
             STRING FUNCTION TRIM(WS-LEVEL-TEXT) " " FUNCTION TRIM(WS-CORE-TEXT) DELIMITED BY SIZE INTO TL-EXPECTED
         END-IF
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-COMMAND-TREE-COMMANDS.

 COPY CORETEST.
