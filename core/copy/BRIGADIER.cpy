*> The Brigadier-style command framework state (docs/protocol/15-commands-framework.md, 15a-brigadier-
*> command-library.md; core/src/cmd-tree.cob, cmd-reader.cob, cmd-dispatch.cob): one command tree
*> (BR-TREE, node 1 is the root, children kept in insertion order as a linked list), the input line
*> being parsed (BR-IN) and the last raised exception (BR-ERR). Cursors are 0-based offsets as in
*> 15a, so the character at cursor c is BR-IN-TEXT(c + 1:1). Requirements are permission levels
*> (15 §2.1: 0 all to 4 owners; a source holds level L or more).
 78 BR-MAX-NODES           VALUE 4096.
 78 BR-LINE-MAX            VALUE 1024.
 78 BR-LITERAL             VALUE 1.
 78 BR-ARGUMENT            VALUE 2.
*> Argument parser ids of 05a (the ones the framework parses itself; others read one word).
 78 BR-P-BOOL              VALUE 0.
 78 BR-P-FLOAT             VALUE 1.
 78 BR-P-DOUBLE            VALUE 2.
 78 BR-P-INTEGER           VALUE 3.
 78 BR-P-LONG              VALUE 4.
 78 BR-P-STRING            VALUE 5.
*> Parser ids of 05a for the types of 15 §6 to §9 (core/src/cmd-types.cob, cmd-coords.cob, cmd-selector.cob, cmd-snbt.cob).
 78 BR-P-ENTITY            VALUE 6.
 78 BR-P-GAME-PROFILE      VALUE 7.
 78 BR-P-BLOCK-POS         VALUE 8.
 78 BR-P-COLUMN-POS        VALUE 9.
 78 BR-P-VEC3              VALUE 10.
 78 BR-P-VEC2              VALUE 11.
 78 BR-P-BLOCK-STATE       VALUE 12.
 78 BR-P-BLOCK-PREDICATE   VALUE 13.
 78 BR-P-ITEM-STACK        VALUE 14.
 78 BR-P-ITEM-PREDICATE    VALUE 15.
 78 BR-P-TEAM-COLOR        VALUE 16.
 78 BR-P-HEX-COLOR         VALUE 17.
 78 BR-P-COMPONENT         VALUE 18.
 78 BR-P-STYLE             VALUE 19.
 78 BR-P-MESSAGE           VALUE 20.
 78 BR-P-NBT-COMPOUND      VALUE 21.
 78 BR-P-NBT-TAG           VALUE 22.
 78 BR-P-NBT-PATH          VALUE 23.
 78 BR-P-OBJECTIVE         VALUE 24.
 78 BR-P-CRITERIA          VALUE 25.
 78 BR-P-OPERATION         VALUE 26.
 78 BR-P-PARTICLE          VALUE 27.
 78 BR-P-ANGLE             VALUE 28.
 78 BR-P-ROTATION          VALUE 29.
 78 BR-P-SLOT-DISPLAY      VALUE 30.
 78 BR-P-SCORE-HOLDER      VALUE 31.
 78 BR-P-SWIZZLE           VALUE 32.
 78 BR-P-TEAM              VALUE 33.
 78 BR-P-ITEM-SLOT         VALUE 34.
 78 BR-P-ITEM-SLOTS        VALUE 35.
 78 BR-P-RESLOC            VALUE 36.
 78 BR-P-FUNCTION          VALUE 37.
 78 BR-P-ANCHOR            VALUE 38.
 78 BR-P-INT-RANGE         VALUE 39.
 78 BR-P-FLOAT-RANGE       VALUE 40.
 78 BR-P-DIMENSION         VALUE 41.
 78 BR-P-GAMEMODE          VALUE 42.
 78 BR-P-TIME              VALUE 43.
 78 BR-P-RES-OR-TAG        VALUE 44.
 78 BR-P-RES-OR-TAG-KEY    VALUE 45.
 78 BR-P-RESOURCE          VALUE 46.
 78 BR-P-RESOURCE-KEY      VALUE 47.
 78 BR-P-RES-SELECTOR      VALUE 48.
 78 BR-P-MIRROR            VALUE 49.
 78 BR-P-TEMPLATE-ROT      VALUE 50.
 78 BR-P-HEIGHTMAP         VALUE 51.
 78 BR-P-LOOT-TABLE        VALUE 52.
 78 BR-P-LOOT-PREDICATE    VALUE 53.
 78 BR-P-LOOT-MODIFIER     VALUE 54.
 78 BR-P-CTX-FLOAT         VALUE 55.
 78 BR-P-CTX-INT           VALUE 56.
 78 BR-P-SLOT-SOURCE       VALUE 57.
 78 BR-P-DIALOG            VALUE 58.
 78 BR-P-FEATURE           VALUE 59.
 78 BR-P-SWING             VALUE 60.
 78 BR-P-UUID              VALUE 61.
 78 BR-F-SINGLE            VALUE 1.
 78 BR-F-PLAYERS           VALUE 2.
 78 BR-S-WORD              VALUE 0.
 78 BR-S-PHRASE            VALUE 1.
 78 BR-S-GREEDY            VALUE 2.
 01 BR-TREE EXTERNAL.
    05 BR-NODE-COUNT        BINARY-LONG.
    05 BR-NODE              OCCURS 4096 TIMES.
       10 BR-N-KIND          BINARY-LONG.   *> 0 root, BR-LITERAL, BR-ARGUMENT
       10 BR-N-NAME-LENGTH   BINARY-LONG.
       10 BR-N-NAME          PIC X(64).
       10 BR-N-LEVEL         BINARY-LONG.   *> requirement: permission level 0 to 4
       10 BR-N-COMMAND       BINARY-LONG.   *> 0 = not executable, else the command id
       10 BR-N-REDIRECT      BINARY-LONG.   *> target node, 0 = none
       10 BR-N-FORK          BINARY-LONG.   *> 1 = fork
       10 BR-N-FIRST         BINARY-LONG.   *> first child, 0 = none
       10 BR-N-LAST          BINARY-LONG.
       10 BR-N-NEXT          BINARY-LONG.   *> next sibling
       10 BR-N-TYPE          BINARY-LONG.   *> argument parser id
       10 BR-N-STRING-KIND   BINARY-LONG.
       10 BR-N-HAS-MIN       BINARY-LONG.
       10 BR-N-HAS-MAX       BINARY-LONG.
       10 BR-N-IMIN          BINARY-DOUBLE.
       10 BR-N-IMAX          BINARY-DOUBLE.
       10 BR-N-DMIN          FLOAT-LONG.
       10 BR-N-DMAX          FLOAT-LONG.
       10 BR-N-SUGGEST       BINARY-LONG.   *> 0 none, 1 ask_server
       10 BR-N-FLAGS         BINARY-LONG.   *> entity and score_holder property byte (BR-F-*)
       10 BR-N-REG-LENGTH    BINARY-LONG.
       10 BR-N-REG           PIC X(40).     *> registry key of the resource types, e.g. minecraft:entity_type
       10 BR-N-MODIFIER      BINARY-LONG.   *> 0 none, else the id of the modifier of a redirect or fork (BR-MODIFY)
 01 BR-IN EXTERNAL.
    05 BR-IN-LENGTH         BINARY-LONG.
    05 BR-IN-CURSOR         BINARY-LONG.
    05 BR-IN-LEVEL          BINARY-LONG.    *> permission level of the source
    05 BR-IN-TEXT           PIC X(1024).
*> The exception being raised: translation key (spaces = none), up to two string arguments, cursor.
 01 BR-ERR EXTERNAL.
    05 BR-E-KEY             PIC X(48).
    05 BR-E-ARG-COUNT       BINARY-LONG.
    05 BR-E-ARG-LENGTH      BINARY-LONG OCCURS 3 TIMES.
    05 BR-E-ARG             PIC X(64) OCCURS 3 TIMES.
    05 BR-E-CURSOR          BINARY-LONG.
*> Usage lines (15a §7): BR-ALL-USAGE fills one entry per full usage line; BR-SMART-USAGE one entry per
*> usable child of the node, BR-U-NODE being that child.
 01 BR-USAGE EXTERNAL.
    05 BR-U-COUNT           BINARY-LONG.
    05 BR-U-ENTRY           OCCURS 128 TIMES.
       10 BR-U-NODE          BINARY-LONG.
       10 BR-U-LENGTH        BINARY-LONG.
       10 BR-U-TEXT          PIC X(256).
*> The suggestions of BR-SUGGEST (15a §6): the common range of the replaced text (start and length, 15a §6.5)
*> and the entries (sorted, no duplicates).
 78 BR-SG-MAX              VALUE 1000.
 01 BR-SUGGESTIONS EXTERNAL.
    05 BR-SG-START          BINARY-LONG.
    05 BR-SG-LENGTH         BINARY-LONG.
    05 BR-SG-COUNT          BINARY-LONG.
    05 BR-SG-ENTRY          OCCURS 1000 TIMES.
       10 BR-SG-TEXT-LENGTH  BINARY-LONG.
       10 BR-SG-TEXT         PIC X(64).
*> The value of the argument just parsed (BR-ARG-EXT fills it, BR-STEP copies it to the trail entry): BR-V-AUX flags,
*> a second integer and double, and up to three coordinate components (kind 0 absolute, 1 relative, 2 local).
 01 BR-VAL EXTERNAL.
    05 BR-V-AUX             BINARY-LONG.
    05 BR-V-IVAL2           BINARY-DOUBLE.
    05 BR-V-DVAL2           FLOAT-LONG.
    05 BR-V-KIND            BINARY-LONG OCCURS 3 TIMES.
    05 BR-V-NUM             FLOAT-LONG OCCURS 3 TIMES.
