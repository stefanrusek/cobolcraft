*> Test of the command tree against the node listings of docs/protocol/57-client-closures-4-command-tree.md section 7 (T2014): the dedicated server's tree with every level
*> visible is written as one line per node, depth first, in the document's notation (the name or <name:parser#id(properties)>, then x for a command, R<n> for the node's own
*> requirement, ->/target for a redirect and sug=<provider>), and compared command by command with core/tests/fixtures/command-tree-57-4.txt (made from the document by
*> core/tests/fixtures/gen_command_tree.py: the listings with the {Tn} and {=Tn} marks expanded, the gamerule rows of the default feature set). The core's lines are also
*> written to build/command-tree-core.txt. Every command is asserted against its listing except those of WS-KNOWN, which have the document's node counts and differ in the names
*> of arguments, the order of children or the parser ids of arguments (outside the lane that made the counts equal): the last case pins that set, so that a command that comes
*> to equal its listing, or a command that starts to differ, changes it. A second pass builds a tree of the commands of WS-FILL alone with BR-DOC-FILL (no hand registration): their nodes
*> equal the listing too, with every executable node marked as not run (every kind of property and provider of the listings: greedy and phrase strings, the four providers).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-TREE-DOC.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT FIXTURE-FILE ASSIGN TO "core/tests/fixtures/command-tree-57-4.txt"
         ORGANIZATION IS LINE SEQUENTIAL FILE STATUS IS WS-FILE-STATUS.
     SELECT DUMP-FILE ASSIGN TO "build/command-tree-core.txt"
         ORGANIZATION IS LINE SEQUENTIAL.
 DATA DIVISION.
 FILE SECTION.
 FD FIXTURE-FILE.
 01 FIXTURE-RECORD         PIC X(240).
 FD DUMP-FILE.
 01 DUMP-RECORD            PIC X(240).
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRIGADIER.
 01 WS-FILE-STATUS         PIC XX.
 01 WS-PARSERS.
    05 FILLER              PIC X(24) VALUE "bool".
    05 FILLER              PIC X(24) VALUE "float".
    05 FILLER              PIC X(24) VALUE "double".
    05 FILLER              PIC X(24) VALUE "integer".
    05 FILLER              PIC X(24) VALUE "long".
    05 FILLER              PIC X(24) VALUE "string".
    05 FILLER              PIC X(24) VALUE "entity".
    05 FILLER              PIC X(24) VALUE "game_profile".
    05 FILLER              PIC X(24) VALUE "block_pos".
    05 FILLER              PIC X(24) VALUE "column_pos".
    05 FILLER              PIC X(24) VALUE "vec3".
    05 FILLER              PIC X(24) VALUE "vec2".
    05 FILLER              PIC X(24) VALUE "block_state".
    05 FILLER              PIC X(24) VALUE "block_predicate".
    05 FILLER              PIC X(24) VALUE "item_stack".
    05 FILLER              PIC X(24) VALUE "item_predicate".
    05 FILLER              PIC X(24) VALUE "team_color".
    05 FILLER              PIC X(24) VALUE "hex_color".
    05 FILLER              PIC X(24) VALUE "component".
    05 FILLER              PIC X(24) VALUE "style".
    05 FILLER              PIC X(24) VALUE "message".
    05 FILLER              PIC X(24) VALUE "nbt_compound_tag".
    05 FILLER              PIC X(24) VALUE "nbt_tag".
    05 FILLER              PIC X(24) VALUE "nbt_path".
    05 FILLER              PIC X(24) VALUE "objective".
    05 FILLER              PIC X(24) VALUE "objective_criteria".
    05 FILLER              PIC X(24) VALUE "operation".
    05 FILLER              PIC X(24) VALUE "particle".
    05 FILLER              PIC X(24) VALUE "angle".
    05 FILLER              PIC X(24) VALUE "rotation".
    05 FILLER              PIC X(24) VALUE "scoreboard_slot".
    05 FILLER              PIC X(24) VALUE "score_holder".
    05 FILLER              PIC X(24) VALUE "swizzle".
    05 FILLER              PIC X(24) VALUE "team".
    05 FILLER              PIC X(24) VALUE "item_slot".
    05 FILLER              PIC X(24) VALUE "item_slots".
    05 FILLER              PIC X(24) VALUE "resource_location".
    05 FILLER              PIC X(24) VALUE "function".
    05 FILLER              PIC X(24) VALUE "entity_anchor".
    05 FILLER              PIC X(24) VALUE "int_range".
    05 FILLER              PIC X(24) VALUE "float_range".
    05 FILLER              PIC X(24) VALUE "dimension".
    05 FILLER              PIC X(24) VALUE "gamemode".
    05 FILLER              PIC X(24) VALUE "time".
    05 FILLER              PIC X(24) VALUE "resource_or_tag".
    05 FILLER              PIC X(24) VALUE "resource_or_tag_key".
    05 FILLER              PIC X(24) VALUE "resource".
    05 FILLER              PIC X(24) VALUE "resource_key".
    05 FILLER              PIC X(24) VALUE "resource_selector".
    05 FILLER              PIC X(24) VALUE "template_mirror".
    05 FILLER              PIC X(24) VALUE "template_rotation".
    05 FILLER              PIC X(24) VALUE "heightmap".
    05 FILLER              PIC X(24) VALUE "loot_table".
    05 FILLER              PIC X(24) VALUE "loot_predicate".
    05 FILLER              PIC X(24) VALUE "loot_modifier".
    05 FILLER              PIC X(24) VALUE "context_float_provider".
    05 FILLER              PIC X(24) VALUE "context_int_provider".
    05 FILLER              PIC X(24) VALUE "slot_source".
    05 FILLER              PIC X(24) VALUE "dialog".
    05 FILLER              PIC X(24) VALUE "feature".
    05 FILLER              PIC X(24) VALUE "swing_animation".
    05 FILLER              PIC X(24) VALUE "uuid".
 01 WS-PARSER-TABLE REDEFINES WS-PARSERS.
    05 WS-PARSER           PIC X(24) OCCURS 62 TIMES.
 01 WS-FIXTURE.
    05 WS-FX-COUNT         BINARY-LONG.
    05 WS-FX-DEPTH         BINARY-LONG OCCURS 3000 TIMES.
    05 WS-FX-TEXT          PIC X(200) OCCURS 3000 TIMES.
 01 WS-CORE.
    05 WS-CR-COUNT         BINARY-LONG.
    05 WS-CR-DEPTH         BINARY-LONG OCCURS 4096 TIMES.
    05 WS-CR-TEXT          PIC X(200) OCCURS 4096 TIMES.
 01 WS-STACK.
    05 WS-NEXT-NODE        BINARY-LONG OCCURS 64 TIMES.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-PTR                 BINARY-LONG.
 01 WS-PROPS               PIC X(100).
 01 WS-PROPS-LENGTH        BINARY-LONG.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-DNUM                FLOAT-LONG.
 01 WS-EDIT                PIC -(18)9.
 01 WS-DEPTH-EDIT          PIC Z9.
 01 WS-NUM-TEXT            PIC X(24).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FX-END              BINARY-LONG.
 01 WS-CR                  BINARY-LONG.
 01 WS-CR-END              BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-FIRST-DIFF          BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-FOUND               BINARY-LONG.
 01 WS-ROOTS               BINARY-LONG.
 01 WS-ORDER-OK            BINARY-LONG.
 01 WS-KNOWN              PIC X(400).
 01 WS-FILL               PIC X(120) VALUE " advancement datapack stopsound posteffect test execute ".
 01 WS-FILL-ONLY           BINARY-LONG VALUE 0.
 01 WS-FILL-NAME           PIC X(32).
 01 WS-DIFFERING           PIC X(400).
 01 WS-DIFFERING-PTR       BINARY-LONG.
 01 WS-PATTERN             PIC X(66).
 01 WS-IS-KNOWN            BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-DISPLAY-PTR         BINARY-LONG.
 01 WS-LINE-OUT            PIC X(240).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 0 TO CS-HOST-KIND
     MOVE CORE-SETTINGS TO CW-SETTINGS
     CALL "BR-TREE-RESET"
     CALL "BR-STD-TREE"
     PERFORM READ-FIXTURE
     PERFORM DUMP-CORE
     MOVE "T" TO TL-MODE
     MOVE " advancement attribute damage datapack effect fill function gamemode item loot playsound posteffect recipe rotate scoreboard" &
         " stopsound team teleport tick worldborder transfer whitelist " TO WS-KNOWN
     MOVE SPACES TO WS-DIFFERING
     MOVE 1 TO WS-DIFFERING-PTR
*>   The roots in the order of the document.
     MOVE 1 TO WS-ORDER-OK
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CR-COUNT
         IF WS-CR-DEPTH(WS-I) = 0
             ADD 1 TO WS-J
         END-IF
     END-PERFORM
     MOVE WS-J TO WS-ROOTS
     MOVE WS-FX-COUNT TO WS-E1
     MOVE WS-CR-COUNT TO WS-E2
     MOVE WS-ROOTS TO WS-E3
     MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
     MOVE "test command tree doc the tree has the nodes of the document in all (nodes of the document, nodes of the core, roots of the core)" TO TL-CASE
     STRING FUNCTION TRIM(WS-E1) " 91" DELIMITED BY SIZE INTO TL-EXPECTED
     STRING FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The names of the roots in order (the order of 6.1 numbers the nodes of the packet).
     MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 1 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-FX-COUNT
         IF WS-FX-DEPTH(WS-I) = 0
             MOVE 0 TO WS-LENGTH
             INSPECT WS-FX-TEXT(WS-I) TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
             STRING WS-FX-TEXT(WS-I)(1:WS-LENGTH) " " DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CR-COUNT
         IF WS-CR-DEPTH(WS-I) = 0
             MOVE 0 TO WS-LENGTH
             INSPECT WS-CR-TEXT(WS-I) TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
             STRING WS-CR-TEXT(WS-I)(1:WS-LENGTH) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
         END-IF
     END-PERFORM
     MOVE "test command tree doc the 91 root literals are in the order of 57-4 section 6.1 (the numbering of the packet)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-FX
     PERFORM UNTIL WS-FX > WS-FX-COUNT
         PERFORM COMPARE-ROOT
     END-PERFORM
     MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
     MOVE "test command tree doc the commands that differ in argument names, child order or parser ids from their listing (known gaps, counts equal)" TO TL-CASE
     MOVE WS-KNOWN TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-EXPECTED) TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-DIFFERING) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The second pass: the filled commands alone.
     MOVE 1 TO WS-FILL-ONLY
     CALL "BR-TREE-RESET"
     MOVE "advancement" TO WS-FILL-NAME
     CALL "BR-DOC-FILL" USING WS-FILL-NAME
     MOVE "datapack" TO WS-FILL-NAME
     CALL "BR-DOC-FILL" USING WS-FILL-NAME
     MOVE "stopsound" TO WS-FILL-NAME
     CALL "BR-DOC-FILL" USING WS-FILL-NAME
     MOVE "posteffect" TO WS-FILL-NAME
     CALL "BR-DOC-FILL" USING WS-FILL-NAME
     MOVE "test" TO WS-FILL-NAME
     CALL "BR-DOC-FILL" USING WS-FILL-NAME
     MOVE "execute" TO WS-FILL-NAME
     CALL "BR-DOC-FILL" USING WS-FILL-NAME
     MOVE "nosuchcommand" TO WS-FILL-NAME
     CALL "BR-DOC-FILL" USING WS-FILL-NAME
     PERFORM DUMP-CORE
     MOVE 1 TO WS-FX
     PERFORM UNTIL WS-FX > WS-FX-COUNT
         PERFORM COMPARE-ROOT
     END-PERFORM
     STOP RUN.

*> The fixture lines into the table.
 READ-FIXTURE.
     MOVE 0 TO WS-FX-COUNT
     OPEN INPUT FIXTURE-FILE
     IF WS-FILE-STATUS NOT = "00"
         DISPLAY "cannot open the fixture " WS-FILE-STATUS
         STOP RUN
     END-IF
     PERFORM UNTIL WS-FILE-STATUS NOT = "00"
         MOVE SPACES TO FIXTURE-RECORD
         READ FIXTURE-FILE
         IF WS-FILE-STATUS = "00"
             ADD 1 TO WS-FX-COUNT
             MOVE 0 TO WS-I
             INSPECT FIXTURE-RECORD TALLYING WS-I FOR CHARACTERS BEFORE INITIAL SPACE
             COMPUTE WS-FX-DEPTH(WS-FX-COUNT) = FUNCTION NUMVAL(FIXTURE-RECORD(1:WS-I))
             MOVE FIXTURE-RECORD(WS-I + 2:) TO WS-FX-TEXT(WS-FX-COUNT)
         END-IF
     END-PERFORM
     CLOSE FIXTURE-FILE.

*> The core's tree as lines, and the lines in build/command-tree-core.txt.
 DUMP-CORE.
     MOVE 0 TO WS-CR-COUNT
     MOVE 1 TO WS-DEPTH
     MOVE BR-N-FIRST(1) TO WS-NEXT-NODE(1)
     PERFORM UNTIL WS-DEPTH = 0
         MOVE WS-NEXT-NODE(WS-DEPTH) TO WS-CHILD
         IF WS-CHILD = 0
             SUBTRACT 1 FROM WS-DEPTH
         ELSE
             MOVE BR-N-NEXT(WS-CHILD) TO WS-NEXT-NODE(WS-DEPTH)
             MOVE WS-CHILD TO WS-NODE
             PERFORM NODE-TEXT
             ADD 1 TO WS-CR-COUNT
             COMPUTE WS-CR-DEPTH(WS-CR-COUNT) = WS-DEPTH - 1
             MOVE WS-TEXT TO WS-CR-TEXT(WS-CR-COUNT)
             IF BR-N-FIRST(WS-CHILD) > 0
                 ADD 1 TO WS-DEPTH
                 MOVE BR-N-FIRST(WS-CHILD) TO WS-NEXT-NODE(WS-DEPTH)
             END-IF
         END-IF
     END-PERFORM
     IF WS-FILL-ONLY = 0
     OPEN OUTPUT DUMP-FILE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CR-COUNT
         MOVE WS-CR-DEPTH(WS-I) TO WS-DEPTH-EDIT
         MOVE SPACES TO DUMP-RECORD
         STRING FUNCTION TRIM(WS-DEPTH-EDIT) " " FUNCTION TRIM(WS-CR-TEXT(WS-I) TRAILING) DELIMITED BY SIZE INTO DUMP-RECORD
         WRITE DUMP-RECORD
     END-PERFORM
     CLOSE DUMP-FILE
     END-IF.

*> The text of the node WS-NODE in the document's notation.
 NODE-TEXT.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE BR-N-NAME-LENGTH(WS-NODE) TO WS-NAME-LENGTH
     IF BR-N-KIND(WS-NODE) = BR-LITERAL
         STRING BR-N-NAME(WS-NODE)(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     ELSE
         PERFORM PROPERTY-TEXT
         MOVE BR-N-TYPE(WS-NODE) TO WS-EDIT
         STRING "<" BR-N-NAME(WS-NODE)(1:WS-NAME-LENGTH) ":" FUNCTION TRIM(WS-PARSER(BR-N-TYPE(WS-NODE) + 1)) "#"
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         IF WS-PROPS-LENGTH > 0
             STRING "(" WS-PROPS(1:WS-PROPS-LENGTH) ")" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
         STRING ">" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-IF
     IF BR-N-COMMAND(WS-NODE) > 0
         STRING " x" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-IF
     IF BR-N-LEVEL(WS-NODE) > 0
         MOVE BR-N-LEVEL(WS-NODE) TO WS-EDIT
         STRING " R" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-IF
     IF BR-N-REDIRECT(WS-NODE) > 0
         STRING " ->/" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         IF BR-N-REDIRECT(WS-NODE) > 1
             MOVE BR-N-NAME-LENGTH(BR-N-REDIRECT(WS-NODE)) TO WS-LENGTH
             STRING BR-N-NAME(BR-N-REDIRECT(WS-NODE))(1:WS-LENGTH) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-IF
     IF BR-N-SUGGEST(WS-NODE) > 0 AND BR-N-KIND(WS-NODE) = BR-ARGUMENT
         EVALUATE BR-N-SUGGEST(WS-NODE)
             WHEN 2
                 STRING " sug=available_sounds" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             WHEN 3
                 STRING " sug=summonable_entities" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             WHEN 4
                 STRING " sug=post_effects" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             WHEN OTHER
                 STRING " sug=ask" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-EVALUATE
     END-IF.

*> The property text of the argument WS-NODE (05a: the flags of an entity and a score holder, the string kind, the bounds of a number, the minimum of a time, the registry).
 PROPERTY-TEXT.
     MOVE SPACES TO WS-PROPS
     MOVE 0 TO WS-PROPS-LENGTH
     MOVE 1 TO WS-K
     EVALUATE BR-N-TYPE(WS-NODE)
         WHEN BR-P-ENTITY
             EVALUATE BR-N-FLAGS(WS-NODE)
                 WHEN 1
                     STRING "single" DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
                 WHEN 2
                     STRING "players" DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
                 WHEN 3
                     STRING "single,players" DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
             END-EVALUATE
         WHEN BR-P-SCORE-HOLDER
             IF BR-N-FLAGS(WS-NODE) = 1
                 STRING "multiple" DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
             END-IF
         WHEN BR-P-STRING
             EVALUATE BR-N-STRING-KIND(WS-NODE)
                 WHEN BR-S-WORD
                     STRING "word" DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
                 WHEN BR-S-PHRASE
                     STRING "phrase" DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
                 WHEN OTHER
                     STRING "greedy" DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
             END-EVALUATE
         WHEN BR-P-TIME
             MOVE BR-N-IMIN(WS-NODE) TO WS-EDIT
             STRING "min=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
         WHEN BR-P-INTEGER
         WHEN BR-P-LONG
             IF BR-N-HAS-MIN(WS-NODE) = 1
                 MOVE BR-N-IMIN(WS-NODE) TO WS-EDIT
                 STRING "min=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
             END-IF
             IF BR-N-HAS-MAX(WS-NODE) = 1
                 IF WS-K > 1
                     STRING "," DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
                 END-IF
                 MOVE BR-N-IMAX(WS-NODE) TO WS-EDIT
                 STRING "max=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
             END-IF
         WHEN BR-P-FLOAT
         WHEN BR-P-DOUBLE
             IF BR-N-HAS-MIN(WS-NODE) = 1
                 MOVE BR-N-DMIN(WS-NODE) TO WS-DNUM
                 PERFORM FLOAT-TEXT
                 STRING "min=" FUNCTION TRIM(WS-NUM-TEXT) DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
             END-IF
             IF BR-N-HAS-MAX(WS-NODE) = 1
                 IF WS-K > 1
                     STRING "," DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
                 END-IF
                 MOVE BR-N-DMAX(WS-NODE) TO WS-DNUM
                 PERFORM FLOAT-TEXT
                 STRING "max=" FUNCTION TRIM(WS-NUM-TEXT) DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
             END-IF
         WHEN BR-P-RES-OR-TAG THRU BR-P-RES-SELECTOR
             IF BR-N-REG-LENGTH(WS-NODE) > 0
                 STRING BR-N-REG(WS-NODE)(1:BR-N-REG-LENGTH(WS-NODE)) DELIMITED BY SIZE INTO WS-PROPS WITH POINTER WS-K
             END-IF
     END-EVALUATE
     COMPUTE WS-PROPS-LENGTH = WS-K - 1.

*> WS-DNUM as the document writes it: an integer, or 1.0E-5.
 FLOAT-TEXT.
     MOVE SPACES TO WS-NUM-TEXT
     IF WS-DNUM > 0 AND WS-DNUM < 0.001
         MOVE "1.0E-5" TO WS-NUM-TEXT
     ELSE
         COMPUTE WS-NUM = WS-DNUM
         MOVE WS-NUM TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-NUM-TEXT
     END-IF.

*> The fixture command at WS-FX against the core's root of that name; WS-FX moves to the next command.
 COMPARE-ROOT.
     MOVE WS-FX TO WS-FX-END
     ADD 1 TO WS-FX-END
     PERFORM UNTIL WS-FX-END > WS-FX-COUNT OR WS-FX-DEPTH(WS-FX-END) = 0
         ADD 1 TO WS-FX-END
     END-PERFORM
     MOVE 0 TO WS-LENGTH
     INSPECT WS-FX-TEXT(WS-FX) TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
     MOVE SPACES TO WS-PATTERN
     STRING " " WS-FX-TEXT(WS-FX)(1:WS-LENGTH) " " DELIMITED BY SIZE INTO WS-PATTERN
     MOVE 0 TO WS-IS-KNOWN
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 120 - WS-LENGTH - 1 OR WS-IS-KNOWN = 1
         IF WS-FILL(WS-K:WS-LENGTH + 2) = WS-PATTERN(1:WS-LENGTH + 2)
             MOVE 1 TO WS-IS-KNOWN
         END-IF
     END-PERFORM
     IF WS-FILL-ONLY = 1 AND WS-IS-KNOWN = 0
         MOVE WS-FX-END TO WS-FX
     ELSE
         PERFORM COMPARE-BODY
     END-IF.

*> The fixture command at WS-FX against the core's root of that name (the second pass: its case names say fill only).
 COMPARE-BODY.
     MOVE WS-FX TO WS-FX-END
     ADD 1 TO WS-FX-END
     PERFORM UNTIL WS-FX-END > WS-FX-COUNT OR WS-FX-DEPTH(WS-FX-END) = 0
         ADD 1 TO WS-FX-END
     END-PERFORM
*>   the name of the root: the text up to the first space
     MOVE 0 TO WS-LENGTH
     INSPECT WS-FX-TEXT(WS-FX) TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
     MOVE SPACES TO WS-NAME
     MOVE WS-FX-TEXT(WS-FX)(1:WS-LENGTH) TO WS-NAME
     MOVE 0 TO WS-CR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CR-COUNT OR WS-CR > 0
         IF WS-CR-DEPTH(WS-I) = 0
             MOVE 0 TO WS-J
             INSPECT WS-CR-TEXT(WS-I) TALLYING WS-J FOR CHARACTERS BEFORE INITIAL SPACE
             IF WS-J = WS-LENGTH AND WS-CR-TEXT(WS-I)(1:WS-J) = WS-NAME(1:WS-LENGTH)
                 MOVE WS-I TO WS-CR
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO WS-FIRST-DIFF
     MOVE 0 TO WS-CR-END
     IF WS-CR > 0
         MOVE WS-CR TO WS-CR-END
         ADD 1 TO WS-CR-END
         PERFORM UNTIL WS-CR-END > WS-CR-COUNT OR WS-CR-DEPTH(WS-CR-END) = 0
             ADD 1 TO WS-CR-END
         END-PERFORM
     END-IF
     MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
     IF WS-FILL-ONLY = 0
         STRING "test command tree doc " WS-NAME(1:WS-LENGTH) " has the nodes of the document's listing (57-4 section 7)"
             DELIMITED BY SIZE INTO TL-CASE
     ELSE
         STRING "test command tree doc fill only " WS-NAME(1:WS-LENGTH) " built by BR-DOC-FILL alone has the nodes of the document's listing"
             DELIMITED BY SIZE INTO TL-CASE
     END-IF
     IF WS-CR = 0
         MOVE "present" TO TL-EXPECTED
         MOVE "no such root" TO TL-OBSERVED
     ELSE
         MOVE WS-FX TO WS-I
         MOVE WS-CR TO WS-J
         PERFORM UNTIL WS-FIRST-DIFF > 0 OR (WS-I >= WS-FX-END AND WS-J >= WS-CR-END)
             EVALUATE TRUE
                 WHEN WS-I >= WS-FX-END OR WS-J >= WS-CR-END
                     MOVE WS-I TO WS-FIRST-DIFF
                 WHEN WS-FX-DEPTH(WS-I) NOT = WS-CR-DEPTH(WS-J) OR WS-FX-TEXT(WS-I) NOT = WS-CR-TEXT(WS-J)
                     MOVE WS-I TO WS-FIRST-DIFF
                 WHEN OTHER
                     ADD 1 TO WS-I
                     ADD 1 TO WS-J
             END-EVALUATE
         END-PERFORM
         COMPUTE WS-E1 = WS-FX-END - WS-FX
         COMPUTE WS-E2 = WS-CR-END - WS-CR
         IF WS-FIRST-DIFF = 0
             STRING FUNCTION TRIM(WS-E1) " nodes" DELIMITED BY SIZE INTO TL-EXPECTED
             MOVE TL-EXPECTED TO TL-OBSERVED
         ELSE
             COMPUTE WS-K = WS-FIRST-DIFF - WS-FX
             MOVE WS-K TO WS-E3
             STRING FUNCTION TRIM(WS-E1) " nodes, node " FUNCTION TRIM(WS-E3) " (" FUNCTION TRIM(WS-FX-TEXT(WS-I)) ")"
                 DELIMITED BY SIZE INTO TL-EXPECTED
             IF WS-J >= WS-CR-END
                 STRING FUNCTION TRIM(WS-E2) " nodes, ends there" DELIMITED BY SIZE INTO TL-OBSERVED
             ELSE
                 STRING FUNCTION TRIM(WS-E2) " nodes, node " FUNCTION TRIM(WS-E3) " (" FUNCTION TRIM(WS-CR-TEXT(WS-J)) ")"
                     DELIMITED BY SIZE INTO TL-OBSERVED
             END-IF
         END-IF
     END-IF
     MOVE SPACES TO WS-PATTERN
     STRING " " WS-NAME(1:WS-LENGTH) " " DELIMITED BY SIZE INTO WS-PATTERN
     MOVE 0 TO WS-IS-KNOWN
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 400 - WS-LENGTH - 1 OR WS-IS-KNOWN = 1
         IF WS-KNOWN(WS-K:WS-LENGTH + 2) = WS-PATTERN(1:WS-LENGTH + 2)
             MOVE 1 TO WS-IS-KNOWN
         END-IF
     END-PERFORM
     IF WS-IS-KNOWN = 0 OR WS-FILL-ONLY = 1
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ELSE
         IF TL-EXPECTED NOT = TL-OBSERVED
             STRING WS-NAME(1:WS-LENGTH) " " DELIMITED BY SIZE INTO WS-DIFFERING WITH POINTER WS-DIFFERING-PTR
         END-IF
     END-IF
     MOVE WS-FX-END TO WS-FX.
 END PROGRAM TEST-COMMAND-TREE-DOC.

 COPY CORETEST.
