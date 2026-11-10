*> Registration of commands in the command tree (docs/protocol/16-commands-catalog.md §1, §2, §14; core/src/cmd-tree.cob): a
*> command form is one line of words, each a literal or an argument, ending in an executable node.
*>
*> A line is words separated by single spaces. A literal is its name, with @N after it for the permission level of that node
*> (the first word of a line gets the level the caller passes; a node that already exists keeps its attributes, 15a §2.3). An
*> argument is <name:type> or <name:type:p1:p2>, with ! before the closing > for the custom suggestions of the server
*> (ask_server). Types and their parameters:
*>   bool; int and long (min, max; empty = none); float and double (min, max); word, phrase, greedy (the string kinds);
*>   entities, entity, players, player (selectors: several, one, several players, one player); profiles (game_profile);
*>   holder and holders (score_holder, one or several); pos, colpos, vec3, vec2, rotation, angle, swizzle (coordinates);
*>   blockstate, blockpred, item, itempred, component, style, message, nbt (compound), nbttag, nbtpath; objective, criteria,
*>   operation, particle, team, slot, slots, resloc, function, anchor, intrange, floatrange, dimension, gamemode, uuid,
*>   hexcolor, teamcolor; time (min ticks).
*>
*> Entry points:
*>   BR-REG USING level (of the first word), command id, line (PIC X(256)): adds the nodes and sets the command of the last
*>   BR-REG-ALIAS USING alias (PIC X(32)), alias length, target (PIC X(32)), target length: a literal under the root that
*>     redirects to the target literal (same children, same level; 16 §14)
*>   BR-TREE-ENSURE: builds the standard tree (BR-STD-TREE) the first time it is called

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-REG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-POS                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PARENT              BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TYPE-NAME           PIC X(16).
 01 WS-TYPE-LENGTH         BINARY-LONG.
 01 WS-TYPE-ID             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-P1                  PIC X(24).
 01 WS-P1-LENGTH           BINARY-LONG.
 01 WS-P2                  PIC X(24).
 01 WS-P2-LENGTH           BINARY-LONG.
 01 WS-SUGGEST             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-STRING-KIND         BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-COMMAND              BINARY-LONG.
 01 L-LINE                 PIC X(256).
 PROCEDURE DIVISION USING L-LEVEL L-COMMAND L-LINE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-LINE TRAILING)) TO WS-LENGTH
     MOVE 1 TO WS-PARENT WS-POS
     MOVE 1 TO WS-FIRST
     PERFORM UNTIL WS-POS > WS-LENGTH
         MOVE WS-POS TO WS-END
         PERFORM UNTIL WS-END > WS-LENGTH OR L-LINE(WS-END:1) = SPACE
             ADD 1 TO WS-END
         END-PERFORM
         COMPUTE WS-I = WS-END - WS-POS
         IF L-LINE(WS-POS:1) = "<"
             PERFORM ONE-ARGUMENT
         ELSE
             PERFORM ONE-LITERAL
         END-IF
         MOVE WS-NODE TO WS-PARENT
         MOVE 0 TO WS-FIRST
         COMPUTE WS-POS = WS-END + 1
     END-PERFORM
     MOVE L-COMMAND TO BR-N-COMMAND(WS-PARENT)
     GOBACK.

*> The literal word at WS-POS of WS-I characters, with an optional @level.
 ONE-LITERAL.
     MOVE L-LEVEL TO WS-LEVEL
     MOVE WS-I TO WS-NAME-LENGTH
     MOVE 0 TO WS-J
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-I
         IF L-LINE(WS-POS + WS-J - 1:1) = "@"
             COMPUTE WS-LEVEL = FUNCTION NUMVAL(L-LINE(WS-POS + WS-J:WS-I - WS-J))
             COMPUTE WS-NAME-LENGTH = WS-J - 1
             COMPUTE WS-J = WS-I + 1
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-NAME
     MOVE L-LINE(WS-POS:WS-NAME-LENGTH) TO WS-NAME
     MOVE BR-LITERAL TO WS-KIND
     CALL "BR-ADD-NODE" USING WS-PARENT WS-KIND WS-NAME WS-NAME-LENGTH WS-ZERO WS-NODE WS-CREATED
     IF WS-CREATED = 1 AND (WS-FIRST = 1 OR WS-LEVEL NOT = L-LEVEL)
         MOVE WS-LEVEL TO BR-N-LEVEL(WS-NODE)
     END-IF.

*> <name:type...>: the name, the type word and up to two parameters.
 ONE-ARGUMENT.
     MOVE SPACES TO WS-NAME WS-TYPE-NAME WS-P1 WS-P2
     MOVE 0 TO WS-NAME-LENGTH WS-TYPE-LENGTH WS-P1-LENGTH WS-P2-LENGTH WS-SUGGEST
     COMPUTE WS-J = WS-POS + 1
     PERFORM UNTIL L-LINE(WS-J:1) = ":"
         ADD 1 TO WS-NAME-LENGTH
         MOVE L-LINE(WS-J:1) TO WS-NAME(WS-NAME-LENGTH:1)
         ADD 1 TO WS-J
     END-PERFORM
     ADD 1 TO WS-J
     PERFORM UNTIL L-LINE(WS-J:1) = ":" OR L-LINE(WS-J:1) = ">" OR L-LINE(WS-J:1) = "!"
         ADD 1 TO WS-TYPE-LENGTH
         MOVE L-LINE(WS-J:1) TO WS-TYPE-NAME(WS-TYPE-LENGTH:1)
         ADD 1 TO WS-J
     END-PERFORM
     IF L-LINE(WS-J:1) = ":"
         ADD 1 TO WS-J
         PERFORM UNTIL L-LINE(WS-J:1) = ":" OR L-LINE(WS-J:1) = ">" OR L-LINE(WS-J:1) = "!"
             ADD 1 TO WS-P1-LENGTH
             MOVE L-LINE(WS-J:1) TO WS-P1(WS-P1-LENGTH:1)
             ADD 1 TO WS-J
         END-PERFORM
     END-IF
     IF L-LINE(WS-J:1) = ":"
         ADD 1 TO WS-J
         PERFORM UNTIL L-LINE(WS-J:1) = ">" OR L-LINE(WS-J:1) = "!"
             ADD 1 TO WS-P2-LENGTH
             MOVE L-LINE(WS-J:1) TO WS-P2(WS-P2-LENGTH:1)
             ADD 1 TO WS-J
         END-PERFORM
     END-IF
     IF L-LINE(WS-J:1) = "!"
         MOVE 1 TO WS-SUGGEST
     END-IF
     PERFORM TYPE-OF
     MOVE BR-ARGUMENT TO WS-KIND
     CALL "BR-ADD-NODE" USING WS-PARENT WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE-ID WS-NODE WS-CREATED
     IF WS-CREATED = 1
         MOVE WS-SUGGEST TO BR-N-SUGGEST(WS-NODE)
         MOVE WS-FLAGS TO BR-N-FLAGS(WS-NODE)
         MOVE WS-STRING-KIND TO BR-N-STRING-KIND(WS-NODE)
         PERFORM SET-LIMITS
     END-IF.

*> The parser id, selector flags and string kind of the type word.
 TYPE-OF.
     MOVE 0 TO WS-FLAGS WS-STRING-KIND
     EVALUATE WS-TYPE-NAME
         WHEN "bool"        MOVE BR-P-BOOL TO WS-TYPE-ID
         WHEN "int"         MOVE BR-P-INTEGER TO WS-TYPE-ID
         WHEN "long"        MOVE BR-P-LONG TO WS-TYPE-ID
         WHEN "float"       MOVE BR-P-FLOAT TO WS-TYPE-ID
         WHEN "double"      MOVE BR-P-DOUBLE TO WS-TYPE-ID
         WHEN "word"        MOVE BR-P-STRING TO WS-TYPE-ID
         WHEN "phrase"
             MOVE BR-P-STRING TO WS-TYPE-ID
             MOVE BR-S-PHRASE TO WS-STRING-KIND
         WHEN "greedy"
             MOVE BR-P-STRING TO WS-TYPE-ID
             MOVE BR-S-GREEDY TO WS-STRING-KIND
         WHEN "entities"    MOVE BR-P-ENTITY TO WS-TYPE-ID
         WHEN "entity"
             MOVE BR-P-ENTITY TO WS-TYPE-ID
             MOVE BR-F-SINGLE TO WS-FLAGS
         WHEN "players"
             MOVE BR-P-ENTITY TO WS-TYPE-ID
             MOVE BR-F-PLAYERS TO WS-FLAGS
         WHEN "player"
             MOVE BR-P-ENTITY TO WS-TYPE-ID
             COMPUTE WS-FLAGS = BR-F-SINGLE + BR-F-PLAYERS
         WHEN "profiles"    MOVE BR-P-GAME-PROFILE TO WS-TYPE-ID
         WHEN "holder"      MOVE BR-P-SCORE-HOLDER TO WS-TYPE-ID
         WHEN "holders"
             MOVE BR-P-SCORE-HOLDER TO WS-TYPE-ID
             MOVE 1 TO WS-FLAGS
         WHEN "pos"         MOVE BR-P-BLOCK-POS TO WS-TYPE-ID
         WHEN "colpos"      MOVE BR-P-COLUMN-POS TO WS-TYPE-ID
         WHEN "vec3"        MOVE BR-P-VEC3 TO WS-TYPE-ID
         WHEN "vec2"        MOVE BR-P-VEC2 TO WS-TYPE-ID
         WHEN "rotation"    MOVE BR-P-ROTATION TO WS-TYPE-ID
         WHEN "angle"       MOVE BR-P-ANGLE TO WS-TYPE-ID
         WHEN "swizzle"     MOVE BR-P-SWIZZLE TO WS-TYPE-ID
         WHEN "blockstate"  MOVE BR-P-BLOCK-STATE TO WS-TYPE-ID
         WHEN "blockpred"   MOVE BR-P-BLOCK-PREDICATE TO WS-TYPE-ID
         WHEN "item"        MOVE BR-P-ITEM-STACK TO WS-TYPE-ID
         WHEN "itempred"    MOVE BR-P-ITEM-PREDICATE TO WS-TYPE-ID
         WHEN "component"   MOVE BR-P-COMPONENT TO WS-TYPE-ID
         WHEN "style"       MOVE BR-P-STYLE TO WS-TYPE-ID
         WHEN "message"     MOVE BR-P-MESSAGE TO WS-TYPE-ID
         WHEN "nbt"         MOVE BR-P-NBT-COMPOUND TO WS-TYPE-ID
         WHEN "nbttag"      MOVE BR-P-NBT-TAG TO WS-TYPE-ID
         WHEN "nbtpath"     MOVE BR-P-NBT-PATH TO WS-TYPE-ID
         WHEN "objective"   MOVE BR-P-OBJECTIVE TO WS-TYPE-ID
         WHEN "criteria"    MOVE BR-P-CRITERIA TO WS-TYPE-ID
         WHEN "operation"   MOVE BR-P-OPERATION TO WS-TYPE-ID
         WHEN "particle"    MOVE BR-P-PARTICLE TO WS-TYPE-ID
         WHEN "team"        MOVE BR-P-TEAM TO WS-TYPE-ID
         WHEN "slot"        MOVE BR-P-ITEM-SLOT TO WS-TYPE-ID
         WHEN "slots"       MOVE BR-P-ITEM-SLOTS TO WS-TYPE-ID
         WHEN "resloc"      MOVE BR-P-RESLOC TO WS-TYPE-ID
         WHEN "function"    MOVE BR-P-FUNCTION TO WS-TYPE-ID
         WHEN "anchor"      MOVE BR-P-ANCHOR TO WS-TYPE-ID
         WHEN "intrange"    MOVE BR-P-INT-RANGE TO WS-TYPE-ID
         WHEN "floatrange"  MOVE BR-P-FLOAT-RANGE TO WS-TYPE-ID
         WHEN "dimension"   MOVE BR-P-DIMENSION TO WS-TYPE-ID
         WHEN "gamemode"    MOVE BR-P-GAMEMODE TO WS-TYPE-ID
         WHEN "uuid"        MOVE BR-P-UUID TO WS-TYPE-ID
         WHEN "hexcolor"    MOVE BR-P-HEX-COLOR TO WS-TYPE-ID
         WHEN "teamcolor"   MOVE BR-P-TEAM-COLOR TO WS-TYPE-ID
         WHEN OTHER         MOVE BR-P-TIME TO WS-TYPE-ID
     END-EVALUATE.

*> The minimum and maximum of a number type and the minimum ticks of a time.
 SET-LIMITS.
     IF WS-P1-LENGTH > 0
         MOVE 1 TO BR-N-HAS-MIN(WS-NODE)
         COMPUTE BR-N-IMIN(WS-NODE) = FUNCTION NUMVAL(WS-P1(1:WS-P1-LENGTH))
         COMPUTE BR-N-DMIN(WS-NODE) = FUNCTION NUMVAL(WS-P1(1:WS-P1-LENGTH))
     END-IF
     IF WS-P2-LENGTH > 0
         MOVE 1 TO BR-N-HAS-MAX(WS-NODE)
         COMPUTE BR-N-IMAX(WS-NODE) = FUNCTION NUMVAL(WS-P2(1:WS-P2-LENGTH))
         COMPUTE BR-N-DMAX(WS-NODE) = FUNCTION NUMVAL(WS-P2(1:WS-P2-LENGTH))
     END-IF.
 END PROGRAM BR-REG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-REG-ALIAS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-NODE                BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ALIAS                PIC X(32).
 01 L-ALIAS-LENGTH         BINARY-LONG.
 01 L-TARGET               PIC X(32).
 01 L-TARGET-LENGTH        BINARY-LONG.
 PROCEDURE DIVISION USING L-ALIAS L-ALIAS-LENGTH L-TARGET L-TARGET-LENGTH.
     MOVE BR-LITERAL TO WS-KIND
     CALL "BR-ADD-NODE" USING WS-ROOT WS-KIND L-TARGET L-TARGET-LENGTH WS-ZERO WS-TARGET WS-CREATED
     CALL "BR-ADD-NODE" USING WS-ROOT WS-KIND L-ALIAS L-ALIAS-LENGTH WS-ZERO WS-NODE WS-CREATED
     MOVE WS-TARGET TO BR-N-REDIRECT(WS-NODE)
     MOVE BR-N-LEVEL(WS-TARGET) TO BR-N-LEVEL(WS-NODE)
     GOBACK.
 END PROGRAM BR-REG-ALIAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-TREE-ENSURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 PROCEDURE DIVISION.
     IF BR-NODE-COUNT <= 1
         CALL "BR-STD-TREE"
     END-IF
     GOBACK.
 END PROGRAM BR-TREE-ENSURE.
