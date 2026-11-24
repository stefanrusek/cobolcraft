*> The nodes of a command as docs/protocol/57-client-closures-4-command-tree.md section 7 lists them (core/copy/BRDOC.cpy, one row per node, depth first).
*>
*>   BR-DOC-FILL USING command (PIC X(32), the root literal): adds every node of the command's listing that the tree does not have yet, in the order of the
*>     listing, below the nodes of the path to it (a node that exists is kept with its attributes, 15a section 2.3). A created node gets the kind, name, parser and
*>     its properties (the entity and score holder flags, the string kind, the bounds of a number, the minimum of a time, the registry), the requirement level
*>     R<n>, the custom suggestion provider sug= and the redirect ->/target (a root literal, or the root). A node marked x that has no command gets BC-UNSUPPORTED
*>     and a created redirect gets the modifier MX-UNSUPPORTED, so that a form the core does not run yet parses and then reports cobolcraft.command.unsupported
*>     (CX-UNSUPPORTED, CX-MODIFY). The registration of the command that follows (CMDS-REG-<name>) puts the real command and modifier ids on the nodes it runs.
*>     A command with no listing is left alone.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-DOC-FILL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRCMD.
 COPY BRDOC.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-TEXT                PIC X(81).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-HEAD-END            BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-MARK                PIC X(48).
 01 WS-MARK-LENGTH         BINARY-LONG.
 01 WS-STACK.
    05 WS-STACK-NODE       BINARY-LONG OCCURS 24 TIMES.
 01 WS-PARENT              BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ARG-NAME            PIC X(64).
 01 WS-ARG-NAME-LENGTH     BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-HASH                BINARY-LONG.
 01 WS-PAREN               BINARY-LONG.
 01 WS-ID-END              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PROPS               PIC X(48).
 01 WS-PROPS-LENGTH        BINARY-LONG.
 01 WS-ITEM                PIC X(48).
 01 WS-ITEM-LENGTH         BINARY-LONG.
 01 WS-ITEM-POS            BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-STRING-KIND         BINARY-LONG.
 01 WS-HAS-MIN             BINARY-LONG.
 01 WS-HAS-MAX             BINARY-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-REGISTRY            PIC X(40).
 01 WS-REGISTRY-LENGTH     BINARY-LONG.
 01 WS-EXEC                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-SUGGEST             BINARY-LONG.
 01 WS-REDIRECT            BINARY-LONG.
 01 WS-TARGET              PIC X(48).
 01 WS-TARGET-LENGTH       BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 PROCEDURE DIVISION USING L-NAME.
     GO TO MAIN-LINE.

*> The marks after the head of the row: x, R<n>, ->/target, sug=<provider>.
 READ-MARKS.
     MOVE 0 TO WS-EXEC WS-LEVEL WS-SUGGEST WS-REDIRECT
     MOVE SPACES TO WS-TARGET
     MOVE 0 TO WS-TARGET-LENGTH
     COMPUTE WS-POS = WS-HEAD-END + 2
     PERFORM UNTIL WS-POS > WS-LENGTH
         MOVE SPACES TO WS-MARK
         MOVE 0 TO WS-MARK-LENGTH
         PERFORM UNTIL WS-POS > WS-LENGTH OR WS-TEXT(WS-POS:1) = SPACE
             ADD 1 TO WS-MARK-LENGTH
             MOVE WS-TEXT(WS-POS:1) TO WS-MARK(WS-MARK-LENGTH:1)
             ADD 1 TO WS-POS
         END-PERFORM
         ADD 1 TO WS-POS
         EVALUATE TRUE
             WHEN WS-MARK = "x"
                 MOVE 1 TO WS-EXEC
             WHEN WS-MARK(1:1) = "R"
                 COMPUTE WS-LEVEL = FUNCTION NUMVAL(WS-MARK(2:1))
             WHEN WS-MARK(1:3) = "->/"
                 MOVE 1 TO WS-REDIRECT
                 COMPUTE WS-TARGET-LENGTH = WS-MARK-LENGTH - 3
                 IF WS-TARGET-LENGTH > 0
                     MOVE WS-MARK(4:WS-TARGET-LENGTH) TO WS-TARGET
                 END-IF
             WHEN WS-MARK(1:4) = "sug="
                 EVALUATE WS-MARK(5:)
                     WHEN "ask"
                         MOVE 1 TO WS-SUGGEST
                     WHEN "available_sounds"
                         MOVE 2 TO WS-SUGGEST
                     WHEN "summonable_entities"
                         MOVE 3 TO WS-SUGGEST
                     WHEN OTHER
                         MOVE 4 TO WS-SUGGEST
                 END-EVALUATE
         END-EVALUATE
     END-PERFORM.

*> <name:parser#id(properties)> at the start of WS-TEXT, WS-HEAD-END characters long: the name, the parser id and the properties.
 READ-ARGUMENT.
     MOVE SPACES TO WS-ARG-NAME WS-PROPS WS-REGISTRY
     MOVE 0 TO WS-COLON WS-HASH WS-PAREN WS-PROPS-LENGTH WS-REGISTRY-LENGTH
     MOVE 0 TO WS-FLAGS WS-STRING-KIND WS-HAS-MIN WS-HAS-MAX WS-MIN WS-MAX
     PERFORM VARYING WS-POS FROM 2 BY 1 UNTIL WS-POS > WS-HEAD-END
         EVALUATE TRUE
             WHEN WS-TEXT(WS-POS:1) = ":" AND WS-COLON = 0
                 MOVE WS-POS TO WS-COLON
             WHEN WS-TEXT(WS-POS:1) = "#" AND WS-HASH = 0
                 MOVE WS-POS TO WS-HASH
             WHEN WS-TEXT(WS-POS:1) = "(" AND WS-PAREN = 0
                 MOVE WS-POS TO WS-PAREN
         END-EVALUATE
     END-PERFORM
     COMPUTE WS-ARG-NAME-LENGTH = WS-COLON - 2
     MOVE WS-TEXT(2:WS-ARG-NAME-LENGTH) TO WS-ARG-NAME
     IF WS-PAREN = 0
         COMPUTE WS-ID-END = WS-HEAD-END - 1
     ELSE
         COMPUTE WS-ID-END = WS-PAREN - 1
         COMPUTE WS-PROPS-LENGTH = WS-HEAD-END - WS-PAREN - 2
         MOVE WS-TEXT(WS-PAREN + 1:WS-PROPS-LENGTH) TO WS-PROPS
     END-IF
     COMPUTE WS-TYPE = FUNCTION NUMVAL(WS-TEXT(WS-HASH + 1:WS-ID-END - WS-HASH))
     IF WS-TYPE >= BR-P-RES-OR-TAG AND WS-TYPE <= BR-P-RES-SELECTOR AND WS-PROPS-LENGTH > 0
         MOVE WS-PROPS TO WS-REGISTRY
         MOVE WS-PROPS-LENGTH TO WS-REGISTRY-LENGTH
     ELSE
         MOVE 1 TO WS-ITEM-POS
         PERFORM UNTIL WS-ITEM-POS > WS-PROPS-LENGTH
             MOVE SPACES TO WS-ITEM
             UNSTRING WS-PROPS(1:WS-PROPS-LENGTH) DELIMITED BY "," INTO WS-ITEM WITH POINTER WS-ITEM-POS
             PERFORM READ-ITEM
         END-PERFORM
     END-IF.

*> One property: single, players, multiple, word, phrase, greedy, min=<n> or max=<n>.
 READ-ITEM.
     EVALUATE TRUE
         WHEN WS-ITEM = "single"
             ADD BR-F-SINGLE TO WS-FLAGS
         WHEN WS-ITEM = "players"
             ADD BR-F-PLAYERS TO WS-FLAGS
         WHEN WS-ITEM = "multiple"
             MOVE 1 TO WS-FLAGS
         WHEN WS-ITEM = "phrase"
             MOVE BR-S-PHRASE TO WS-STRING-KIND
         WHEN WS-ITEM = "greedy"
             MOVE BR-S-GREEDY TO WS-STRING-KIND
         WHEN WS-ITEM(1:4) = "min="
             MOVE 1 TO WS-HAS-MIN
             IF WS-ITEM(5:) = "1.0E-5"
                 MOVE 0.00001 TO WS-MIN
             ELSE
                 COMPUTE WS-MIN = FUNCTION NUMVAL(WS-ITEM(5:))
             END-IF
         WHEN WS-ITEM(1:4) = "max="
             MOVE 1 TO WS-HAS-MAX
             COMPUTE WS-MAX = FUNCTION NUMVAL(WS-ITEM(5:))
     END-EVALUATE.

*> The node of the row: found or created below WS-PARENT.
 ONE-NODE.
     MOVE 0 TO WS-HEAD-END
     PERFORM VARYING WS-POS FROM 1 BY 1 UNTIL WS-POS > WS-LENGTH OR WS-HEAD-END > 0
         IF WS-TEXT(WS-POS:1) = SPACE
             COMPUTE WS-HEAD-END = WS-POS - 1
         END-IF
     END-PERFORM
     IF WS-HEAD-END = 0
         MOVE WS-LENGTH TO WS-HEAD-END
     END-IF
     PERFORM READ-MARKS
     MOVE 0 TO WS-COLON
     IF WS-TEXT(1:1) = "<" AND WS-HEAD-END > 2
         PERFORM VARYING WS-POS FROM 2 BY 1 UNTIL WS-POS > WS-HEAD-END OR WS-COLON > 0
             IF WS-TEXT(WS-POS:1) = ":"
                 MOVE WS-POS TO WS-COLON
             END-IF
         END-PERFORM
     END-IF
     IF WS-COLON > 0
         PERFORM READ-ARGUMENT
         MOVE BR-ARGUMENT TO WS-KIND
         CALL "BR-ADD-NODE" USING WS-PARENT WS-KIND WS-ARG-NAME WS-ARG-NAME-LENGTH WS-TYPE WS-NODE WS-CREATED
         IF WS-CREATED = 1
             MOVE WS-STRING-KIND TO BR-N-STRING-KIND(WS-NODE)
             MOVE WS-FLAGS TO BR-N-FLAGS(WS-NODE)
             MOVE WS-HAS-MIN TO BR-N-HAS-MIN(WS-NODE)
             MOVE WS-HAS-MAX TO BR-N-HAS-MAX(WS-NODE)
             COMPUTE BR-N-IMIN(WS-NODE) = WS-MIN
             COMPUTE BR-N-IMAX(WS-NODE) = WS-MAX
             MOVE WS-MIN TO BR-N-DMIN(WS-NODE)
             MOVE WS-MAX TO BR-N-DMAX(WS-NODE)
             IF WS-REGISTRY-LENGTH > 0
                 MOVE WS-REGISTRY TO BR-N-REG(WS-NODE)
                 MOVE WS-REGISTRY-LENGTH TO BR-N-REG-LENGTH(WS-NODE)
             END-IF
         END-IF
     ELSE
         MOVE BR-LITERAL TO WS-KIND
         CALL "BR-ADD-NODE" USING WS-PARENT WS-KIND WS-TEXT WS-HEAD-END WS-ZERO WS-NODE WS-CREATED
     END-IF
     IF WS-CREATED = 1
         MOVE WS-LEVEL TO BR-N-LEVEL(WS-NODE)
         MOVE WS-SUGGEST TO BR-N-SUGGEST(WS-NODE)
     END-IF
     IF WS-EXEC = 1 AND BR-N-COMMAND(WS-NODE) = 0
         MOVE BC-UNSUPPORTED TO BR-N-COMMAND(WS-NODE)
     END-IF
     IF WS-REDIRECT = 1 AND BR-N-REDIRECT(WS-NODE) = 0
         MOVE 1 TO BR-N-REDIRECT(WS-NODE)
         IF WS-TARGET-LENGTH > 0
             MOVE BR-N-FIRST(1) TO WS-CHILD
             PERFORM UNTIL WS-CHILD = 0
                 IF BR-N-NAME-LENGTH(WS-CHILD) = WS-TARGET-LENGTH
                         AND BR-N-NAME(WS-CHILD)(1:WS-TARGET-LENGTH) = WS-TARGET(1:WS-TARGET-LENGTH)
                     MOVE WS-CHILD TO BR-N-REDIRECT(WS-NODE)
                 END-IF
                 MOVE BR-N-NEXT(WS-CHILD) TO WS-CHILD
             END-PERFORM
         END-IF
         MOVE MX-UNSUPPORTED TO BR-N-MODIFIER(WS-NODE)
     END-IF.

 MAIN-LINE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME TRAILING)) TO WS-NAME-LENGTH
     MOVE 0 TO WS-START
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > BRDOC-ROWS OR WS-START > 0
         IF BRDOC-ROW(WS-ROW)(1:3) = " 0 " AND BRDOC-ROW(WS-ROW)(4:WS-NAME-LENGTH) = L-NAME(1:WS-NAME-LENGTH)
                 AND (BRDOC-ROW(WS-ROW)(4 + WS-NAME-LENGTH:1) = SPACE)
             MOVE WS-ROW TO WS-START
         END-IF
     END-PERFORM
     IF WS-START > 0
         MOVE WS-START TO WS-END
         ADD 1 TO WS-END
         PERFORM UNTIL WS-END > BRDOC-ROWS OR BRDOC-ROW(WS-END)(1:3) = " 0 "
             ADD 1 TO WS-END
         END-PERFORM
         MOVE 1 TO WS-STACK-NODE(1)
         PERFORM VARYING WS-ROW FROM WS-START BY 1 UNTIL WS-ROW >= WS-END
             COMPUTE WS-DEPTH = FUNCTION NUMVAL(BRDOC-ROW(WS-ROW)(1:2))
             MOVE WS-STACK-NODE(WS-DEPTH + 1) TO WS-PARENT
             MOVE BRDOC-ROW(WS-ROW)(4:) TO WS-TEXT
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT TRAILING)) TO WS-LENGTH
             PERFORM ONE-NODE
             MOVE WS-NODE TO WS-STACK-NODE(WS-DEPTH + 2)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BR-DOC-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-UNSUPPORTED.
*> The runner of a node that BR-DOC-FILL added and the core does not run, and the modifier of a redirect it added: the exception cobolcraft.command.unsupported with the literal words of
*> the context that failed, separated by spaces (the command, or the clause of an execute chain).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-KEY                 PIC X(48) VALUE "cobolcraft.command.unsupported".
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-A2                  PIC X(64) VALUE SPACES.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-I                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-A1
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-R-COUNT
         MOVE BA-NAME-LENGTH(WS-I) TO WS-LENGTH
         IF BA-ARG(WS-I) = 0 AND WS-PTR + WS-LENGTH < 64
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO WS-A1 WITH POINTER WS-PTR
             END-IF
             STRING BA-NAME(WS-I)(1:WS-LENGTH) DELIMITED BY SIZE INTO WS-A1 WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     COMPUTE WS-L1 = WS-PTR - 1
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED
     GOBACK.
 END PROGRAM CX-UNSUPPORTED.
