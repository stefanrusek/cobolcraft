*> The loot conditions and predicates of the loot engine (T0436; docs/protocol/26-loot-and-predicates.md section 8, and the predicates of
*> section 10 that a table needs: 10.1 item, 10.2 enchantment component predicate, 10.3 block and state, 10.10 bounds). A condition
*> is a JSON node (slot, node) of LOOT-DOCS: an object with a "type", a string naming an entry of the registry predicate, or an
*> array (all_of its elements). Random draws happen in the order of section 5.3 note: all_of stops at the first false term and
*> any_of at the first true one, so later terms draw nothing.
*> Evaluated: all 20 condition types of section 8. Parts of them that need what the core does not hold are false: the damage source
*> (damage_source_properties), the scoreboard (entity_scores with a score, int/float scores), environment attributes
*> (environment_attribute_check), location predicates other than {} (location_check: needs the level), entity predicate members
*> other than "type", item predicates with "components" or partial predicates other than enchantments (damage, custom_data, potion
*> contents and the rest), block predicates with block entity parts (nbt, components: the engine has no block entity). An entity target other than this, attacker and attacking_player is absent (the context holds no
*> direct attacker, target or interacting entity).
*> Entry points:
*>   LOOT-COND-EVAL USING slot, node, result out (BINARY-LONG 1 or 0)
*>   LOOT-PREDICATE USING name (PIC X(112)), LOOT-CONTEXT, result out, found out   a named predicate of the data registry
*>   LOOT-ENCH-ID USING key (PIC X(112)), id out (BINARY-LONG, -1 when the enchantment registry holds no such key)
*>   LOOT-ITEM-ID USING key, id out (-1 when the open set holds no such item)
*>   LOOT-STACK-ENCHANTS USING handle, count out, ids out (20 BINARY-LONG), levels out (20 BINARY-LONG)   the enchantments component
*>   LOOT-TOOL-LEVEL USING enchantment key (PIC X(112)), level out    the level on the tool stack of the context (0 without a tool)
*>   LOOT-ATTACKER-LEVEL USING enchantment key, level out    the level on the attacking entity (0 without one)
*>   LOOT-BOUNDS-TEST USING slot, node, value (FLOAT-LONG), result out   MinMaxBounds (10.10): a number is exact, {min, max} inclusive
*>   LOOT-RANGE-TEST USING slot, node, value (FLOAT-LONG), kind (1 int providers, 2 float providers), result out   IntRangePredicate and
*>     FloatRangePredicate (10.10): a provider is equality, {min, max} of providers inclusive
*>   LOOT-ITEM-MATCH USING slot, node, item, count, handle, result out   an item predicate (10.1)
*>   LOOT-STATE-MATCH USING slot, node, state id, result out   a state properties predicate (10.3)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-J-KEY.
*> USING slot, member node, key out (PIC X(64)), length out: the key of an object member.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-KEY L-LENGTH.
     MOVE SPACES TO L-KEY
     CALL "JSON-KEY" USING LDS-DOC(L-SLOT) L-NODE L-KEY WS-CAPACITY L-LENGTH
     GOBACK.
 END PROGRAM LOOT-J-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ENCH-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(112) VALUE "minecraft:enchantment".
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-WANT                PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PAYLOAD             PIC X(1).
 01 WS-CAPACITY            BINARY-LONG VALUE 0.
 01 WS-PAYLOAD-LENGTH      BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE -1 TO L-ID
     IF L-KEY(1:10) = "minecraft:"
         MOVE L-KEY TO WS-WANT
     ELSE
         MOVE SPACES TO WS-WANT
         STRING "minecraft:" FUNCTION TRIM(L-KEY) DELIMITED BY SIZE INTO WS-WANT
     END-IF
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-COUNT OR L-ID >= 0
         CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-LENGTH WS-PAYLOAD WS-CAPACITY
             WS-PAYLOAD-LENGTH WS-STATUS
         IF WS-KEY = WS-WANT
             MOVE WS-ID TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-ENCH-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ITEM-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     CALL "CONTENT-ITEM-BY-KEY" USING L-KEY L-ID WS-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         MOVE -1 TO L-ID
     END-IF
     GOBACK.
 END PROGRAM LOOT-ITEM-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-STACK-ENCHANTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 13.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-IDS.
    05 L-ID                BINARY-LONG OCCURS 20 TIMES.
 01 L-LEVELS.
    05 L-LEVEL             BINARY-LONG OCCURS 20 TIMES.
 PROCEDURE DIVISION USING L-HANDLE L-COUNT L-IDS L-LEVELS.
     MOVE 0 TO L-COUNT
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-I > 20 OR WS-POS > 63
             CALL "SP-VARINT-GET" USING WS-VALUE WS-POS L-ID(WS-I)
             CALL "SP-VARINT-GET" USING WS-VALUE WS-POS L-LEVEL(WS-I)
             ADD 1 TO L-COUNT
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM LOOT-STACK-ENCHANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-TOOL-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-LEVEL.
     MOVE 0 TO L-LEVEL
     IF LW-C-TOOL-SET = 1
         CALL "LOOT-ENCH-ID" USING L-KEY WS-ID
         CALL "SP-ENCHANT-LEVEL" USING LW-C-TOOL-HANDLE WS-ID L-LEVEL
     END-IF
     GOBACK.
 END PROGRAM LOOT-TOOL-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ATTACKER-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-LEVEL.
     MOVE 0 TO L-LEVEL
     IF LW-C-ATTACKER-SET = 1
         CALL "LOOT-ENCH-ID" USING L-KEY WS-ID
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LW-C-ATTACKER-ENCH-COUNT
             IF LW-C-AE-ID(WS-I) = WS-ID AND LW-C-AE-LEVEL(WS-I) > L-LEVEL
                 MOVE LW-C-AE-LEVEL(WS-I) TO L-LEVEL
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM LOOT-ATTACKER-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-BOUNDS-TEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY LOOTSTATE.
 01 WS-N-MIN               PIC X(32) VALUE "min".
 01 WS-N-MAX               PIC X(32) VALUE "max".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-BOUND               FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-VALUE L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-NODE = 0
         GOBACK
     END-IF
     IF LDS-JN-TYPE(L-SLOT, L-NODE) = JT-NUMBER
         IF L-VALUE NOT = LDS-JN-NUM(L-SLOT, L-NODE)
             MOVE 0 TO L-RESULT
         END-IF
         GOBACK
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-MIN WS-MEMBER
     CALL "LOOT-J-NUMBER" USING L-SLOT WS-MEMBER WS-BOUND WS-OK
     IF WS-OK = 1 AND L-VALUE < WS-BOUND
         MOVE 0 TO L-RESULT
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-MAX WS-MEMBER
     CALL "LOOT-J-NUMBER" USING L-SLOT WS-MEMBER WS-BOUND WS-OK
     IF WS-OK = 1 AND L-VALUE > WS-BOUND
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM LOOT-BOUNDS-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-RANGE-BOUND.
*> USING slot, node, kind (1 int, 2 float), value out (FLOAT-LONG): a bound provider evaluated through the context.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-KIND L-VALUE.
     IF L-KIND = 1
         CALL "LOOT-INT-GET" USING L-SLOT L-NODE WS-INT
         MOVE WS-INT TO L-VALUE
     ELSE
         CALL "LOOT-FLOAT-GET" USING L-SLOT L-NODE L-VALUE
     END-IF
     GOBACK.
 END PROGRAM LOOT-RANGE-BOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-RANGE-TEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY LOOTSTATE.
 01 WS-N-MIN               PIC X(32) VALUE "min".
 01 WS-N-MAX               PIC X(32) VALUE "max".
 01 WS-N-TYPE              PIC X(32) VALUE "type".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-BOUND               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-VALUE L-KIND L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-NODE = 0
         GOBACK
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-TYPE WS-MEMBER
     IF LDS-JN-TYPE(L-SLOT, L-NODE) NOT = JT-OBJECT OR WS-MEMBER > 0
*>       A Point: equality with the provider's value.
         CALL "LOOT-RANGE-BOUND" USING L-SLOT L-NODE L-KIND WS-BOUND
         IF L-VALUE NOT = WS-BOUND
             MOVE 0 TO L-RESULT
         END-IF
         GOBACK
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-MIN WS-MEMBER
     IF WS-MEMBER > 0
         CALL "LOOT-RANGE-BOUND" USING L-SLOT WS-MEMBER L-KIND WS-BOUND
         IF L-VALUE < WS-BOUND
             MOVE 0 TO L-RESULT
         END-IF
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-MAX WS-MEMBER
     IF WS-MEMBER > 0
         CALL "LOOT-RANGE-BOUND" USING L-SLOT WS-MEMBER L-KIND WS-BOUND
         IF L-VALUE > WS-BOUND
             MOVE 0 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LOOT-RANGE-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ITEM-IN-SET IS RECURSIVE.
*> USING slot, node, kind (1 item ids and tags, 2 block ids and tags, 3 enchantment ids and tags), id (BINARY-LONG), result out:
*> the id is in the id, "#tag" or list of the node.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY LOOTSTATE.
 01 WS-ITEM-REGISTRY       PIC X(48) VALUE "item".
 01 WS-BLOCK-REGISTRY      PIC X(48) VALUE "block".
 01 WS-ENCH-REGISTRY       PIC X(48) VALUE "enchantment".
 LOCAL-STORAGE SECTION.
 01 LS-CHILD               BINARY-LONG.
 01 LS-TEXT                PIC X(112).
 01 LS-KEY                 PIC X(112).
 01 LS-LENGTH              BINARY-LONG.
 01 LS-OTHER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-KIND L-ID L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-NODE = 0
         GOBACK
     END-IF
     IF LDS-JN-TYPE(L-SLOT, L-NODE) = JT-ARRAY
         MOVE LDS-JN-FIRST(L-SLOT, L-NODE) TO LS-CHILD
         PERFORM UNTIL LS-CHILD = 0 OR L-RESULT = 1
             CALL "LOOT-ITEM-IN-SET" USING L-SLOT LS-CHILD L-KIND L-ID L-RESULT
             MOVE LDS-JN-NEXT(L-SLOT, LS-CHILD) TO LS-CHILD
         END-PERFORM
         GOBACK
     END-IF
     CALL "LOOT-J-TEXT" USING L-SLOT L-NODE LS-TEXT LS-LENGTH
     IF LS-TEXT(1:1) = "#"
         MOVE LS-TEXT(2:) TO LS-KEY
         EVALUATE L-KIND
             WHEN 1
                 CALL "CONTENT-TAG-HAS" USING WS-ITEM-REGISTRY LS-KEY L-ID L-RESULT
             WHEN 2
                 CALL "CONTENT-TAG-HAS" USING WS-BLOCK-REGISTRY LS-KEY L-ID L-RESULT
             WHEN OTHER
                 CALL "CONTENT-TAG-HAS" USING WS-ENCH-REGISTRY LS-KEY L-ID L-RESULT
         END-EVALUATE
         GOBACK
     END-IF
     MOVE -1 TO LS-OTHER
     EVALUATE L-KIND
         WHEN 1
             CALL "LOOT-ITEM-ID" USING LS-TEXT LS-OTHER
         WHEN 2
             CALL "BLOCKS-ID-OF" USING LS-TEXT LS-OTHER
         WHEN OTHER
             CALL "LOOT-ENCH-ID" USING LS-TEXT LS-OTHER
     END-EVALUATE
     IF LS-OTHER = L-ID AND LS-OTHER >= 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM LOOT-ITEM-IN-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ENCH-PRED.
*> USING slot, enchantment predicate node ({enchantments, levels}), handle, result out: one entry of the enchantments list of the
*> component predicate (10.2): with enchantments, some enchantment of that set on the stack has a level in levels (any level when
*> there is none); without them and with levels, some enchantment has a level in levels; with neither, the stack has an enchantment.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N-ENCHANTMENTS      PIC X(32) VALUE "enchantments".
 01 WS-N-LEVELS            PIC X(32) VALUE "levels".
 01 WS-SET                 BINARY-LONG.
 01 WS-LEVELS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 20 TIMES.
 01 WS-LEVEL-TABLE.
    05 WS-LEVEL            BINARY-LONG OCCURS 20 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-IN-SET              BINARY-LONG.
 01 WS-IN-LEVELS           BINARY-LONG.
 01 WS-KIND-ENCH           BINARY-LONG VALUE 3.
 01 WS-VALUE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-HANDLE L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ENCHANTMENTS WS-SET
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-LEVELS WS-LEVELS
     CALL "LOOT-STACK-ENCHANTS" USING L-HANDLE WS-COUNT WS-IDS WS-LEVEL-TABLE
     IF WS-SET = 0 AND WS-LEVELS = 0 AND WS-COUNT > 0
         MOVE 1 TO L-RESULT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR L-RESULT = 1
         MOVE 1 TO WS-IN-SET
         IF WS-SET > 0
             CALL "LOOT-ITEM-IN-SET" USING L-SLOT WS-SET WS-KIND-ENCH WS-ID(WS-I) WS-IN-SET
         END-IF
         MOVE WS-LEVEL(WS-I) TO WS-VALUE
         CALL "LOOT-BOUNDS-TEST" USING L-SLOT WS-LEVELS WS-VALUE WS-IN-LEVELS
         IF WS-IN-SET = 1 AND WS-IN-LEVELS = 1 AND (WS-SET > 0 OR WS-LEVELS > 0)
             MOVE 1 TO L-RESULT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-ENCH-PRED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ITEM-MATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY LOOTSTATE.
 01 WS-N-ITEMS             PIC X(32) VALUE "items".
 01 WS-N-COUNT             PIC X(32) VALUE "count".
 01 WS-N-COMPONENTS        PIC X(32) VALUE "components".
 01 WS-N-PREDICATES        PIC X(32) VALUE "predicates".
 01 WS-N-ENCHANTMENTS      PIC X(32) VALUE "minecraft:enchantments".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-KIND-ITEM           BINARY-LONG VALUE 1.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-ITEM L-COUNT L-HANDLE L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-NODE = 0
         GOBACK
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ITEMS WS-MEMBER
     IF WS-MEMBER > 0
         CALL "LOOT-ITEM-IN-SET" USING L-SLOT WS-MEMBER WS-KIND-ITEM L-ITEM L-RESULT
         IF L-RESULT = 0
             GOBACK
         END-IF
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-COUNT WS-MEMBER
     MOVE L-COUNT TO WS-VALUE
     CALL "LOOT-BOUNDS-TEST" USING L-SLOT WS-MEMBER WS-VALUE L-RESULT
     IF L-RESULT = 0
         GOBACK
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-COMPONENTS WS-MEMBER
     IF WS-MEMBER > 0
         MOVE 0 TO L-RESULT
         GOBACK
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-PREDICATES WS-MEMBER
     IF WS-MEMBER = 0
         GOBACK
     END-IF
*>   Every member of the partial predicates must hold: the enchantments list is evaluated, any other key is not.
     MOVE LDS-JN-FIRST(L-SLOT, WS-MEMBER) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0 OR L-RESULT = 0
         CALL "LOOT-J-KEY" USING L-SLOT WS-CHILD WS-KEY WS-KEY-LENGTH
         IF WS-KEY = WS-N-ENCHANTMENTS
             MOVE LDS-JN-FIRST(L-SLOT, WS-CHILD) TO WS-ENTRY
             PERFORM UNTIL WS-ENTRY = 0 OR L-RESULT = 0
                 CALL "LOOT-ENCH-PRED" USING L-SLOT WS-ENTRY L-HANDLE WS-OK
                 MOVE WS-OK TO L-RESULT
                 MOVE LDS-JN-NEXT(L-SLOT, WS-ENTRY) TO WS-ENTRY
             END-PERFORM
         ELSE
             MOVE 0 TO L-RESULT
         END-IF
         MOVE LDS-JN-NEXT(L-SLOT, WS-CHILD) TO WS-CHILD
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-ITEM-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-STATE-MATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY LOOTSTATE.
 01 WS-PROPS               PIC X(160).
 01 WS-HAVE                PIC X(164).
 01 WS-CHILD               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-VALUE               PIC X(112).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-NEEDLE              PIC X(200).
 01 WS-HITS                BINARY-LONG.
 01 WS-PROP-NAME           PIC X(24).
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-STATE L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-NODE = 0
         GOBACK
     END-IF
     CALL "BLOCKS-STATE-PROPS" USING L-STATE WS-PROPS
     MOVE SPACES TO WS-HAVE
     STRING "," FUNCTION TRIM(WS-PROPS) "," DELIMITED BY SIZE INTO WS-HAVE
     MOVE LDS-JN-FIRST(L-SLOT, L-NODE) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0 OR L-RESULT = 0
         CALL "LOOT-J-KEY" USING L-SLOT WS-CHILD WS-KEY WS-KEY-LENGTH
         CALL "LOOT-J-TEXT" USING L-SLOT WS-CHILD WS-VALUE WS-VALUE-LENGTH
         MOVE 0 TO WS-HITS
         IF WS-VALUE-LENGTH = 0 AND LDS-JN-TYPE(L-SLOT, WS-CHILD) = JT-OBJECT
*>           a range matcher {min, max} (loot-state.cob)
             MOVE WS-KEY(1:24) TO WS-PROP-NAME
             CALL "LOOT-STATE-RANGE" USING L-SLOT WS-CHILD L-STATE WS-PROP-NAME WS-HITS
         END-IF
         IF WS-VALUE-LENGTH > 0
             MOVE SPACES TO WS-NEEDLE
             STRING "," WS-KEY(1:WS-KEY-LENGTH) "=" WS-VALUE(1:WS-VALUE-LENGTH) ","
                 DELIMITED BY SIZE INTO WS-NEEDLE
             INSPECT WS-HAVE TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-NEEDLE)
         END-IF
         IF WS-HITS = 0
             MOVE 0 TO L-RESULT
         END-IF
         MOVE LDS-JN-NEXT(L-SLOT, WS-CHILD) TO WS-CHILD
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-STATE-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-TARGET.
*> USING slot, entity member node, present out, type out (PIC X(48)): the entity of a target name (26 section 3.1): this,
*> attacker and attacking_player; any other target is absent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-TEXT                PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-TYPE                 PIC X(48).
 PROCEDURE DIVISION USING L-SLOT L-NODE L-PRESENT L-TYPE.
     MOVE 0 TO L-PRESENT
     MOVE SPACES TO L-TYPE
     CALL "LOOT-J-TEXT" USING L-SLOT L-NODE WS-TEXT WS-LENGTH
     EVALUATE WS-TEXT
         WHEN "this"
             MOVE LW-C-THIS-SET TO L-PRESENT
             MOVE LW-C-THIS-TYPE TO L-TYPE
         WHEN "attacker"
             MOVE LW-C-ATTACKER-SET TO L-PRESENT
             MOVE LW-C-ATTACKER-TYPE TO L-TYPE
         WHEN "attacking_player"
             MOVE LW-C-KILLER TO L-PRESENT
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ENTITY-MATCH.
*> USING slot, entity predicate node, entity type (PIC X(48)), result out: the predicate's "type" (an id or a list of ids) holds
*> for the entity; every other member of the predicate is not evaluated (false).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-CHILD               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG.
 01 WS-WANT                PIC X(112).
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-TYPE                 PIC X(48).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-TYPE L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE LDS-JN-FIRST(L-SLOT, L-NODE) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0 OR L-RESULT = 0
         CALL "LOOT-J-KEY" USING L-SLOT WS-CHILD WS-KEY WS-KEY-LENGTH
         MOVE 0 TO L-RESULT
         IF WS-KEY = "type"
             CALL "LOOT-J-TEXT" USING L-SLOT WS-CHILD WS-TEXT WS-LENGTH
             IF WS-LENGTH > 0
                 IF L-TYPE NOT = SPACES AND WS-TEXT(1:48) = L-TYPE
                     MOVE 1 TO L-RESULT
                 END-IF
             ELSE
                 MOVE LDS-JN-FIRST(L-SLOT, WS-CHILD) TO WS-ELEMENT
                 PERFORM UNTIL WS-ELEMENT = 0 OR L-RESULT = 1
                     CALL "LOOT-J-TEXT" USING L-SLOT WS-ELEMENT WS-TEXT WS-LENGTH
                     IF L-TYPE NOT = SPACES AND WS-TEXT(1:48) = L-TYPE
                         MOVE 1 TO L-RESULT
                     END-IF
                     MOVE LDS-JN-NEXT(L-SLOT, WS-ELEMENT) TO WS-ELEMENT
                 END-PERFORM
             END-IF
         END-IF
         MOVE LDS-JN-NEXT(L-SLOT, WS-CHILD) TO WS-CHILD
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-ENTITY-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-MATCH-BLOCK.
*> USING slot, match_block condition node, result out: the block state of the context against blocks, state, nbt and components.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY CBLOCKS.
 01 WS-N-BLOCKS            PIC X(32) VALUE "blocks".
 01 WS-N-STATE             PIC X(32) VALUE "state".
 01 WS-N-NBT               PIC X(32) VALUE "nbt".
 01 WS-N-COMPONENTS        PIC X(32) VALUE "components".
 01 WS-KIND-BLOCK          BINARY-LONG VALUE 2.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-RESULT.
     MOVE 0 TO L-RESULT
     IF LW-C-STATE-SET = 0
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(LW-C-STATE + 1)
     MOVE 1 TO L-RESULT
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-BLOCKS WS-MEMBER
     IF WS-MEMBER > 0
         CALL "LOOT-ITEM-IN-SET" USING L-SLOT WS-MEMBER WS-KIND-BLOCK WS-BLOCK L-RESULT
     END-IF
     IF L-RESULT = 1
         CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-STATE WS-MEMBER
         CALL "LOOT-STATE-MATCH" USING L-SLOT WS-MEMBER LW-C-STATE L-RESULT
     END-IF
     IF L-RESULT = 1
         CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-NBT WS-MEMBER
         CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-COMPONENTS WS-OTHER
         IF WS-MEMBER > 0 OR WS-OTHER > 0
             MOVE 0 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LOOT-MATCH-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-COND-EVAL IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "predicate".
 01 WS-N-TERM              PIC X(32) VALUE "term".
 01 WS-N-TERMS             PIC X(32) VALUE "terms".
 01 WS-N-CHANCE            PIC X(32) VALUE "chance".
 01 WS-N-UNENCHANTED       PIC X(32) VALUE "unenchanted_chance".
 01 WS-N-ENCHANTED         PIC X(32) VALUE "enchanted_chance".
 01 WS-N-ENCHANTMENT       PIC X(32) VALUE "enchantment".
 01 WS-N-CHANCES           PIC X(32) VALUE "chances".
 01 WS-N-PREDICATE         PIC X(32) VALUE "predicate".
 01 WS-N-BLOCKS            PIC X(32) VALUE "blocks".
 01 WS-N-STATE             PIC X(32) VALUE "state".
 01 WS-N-NBT               PIC X(32) VALUE "nbt".
 01 WS-N-COMPONENTS        PIC X(32) VALUE "components".
 01 WS-N-ENTITY            PIC X(32) VALUE "entity".
 01 WS-N-SCORES            PIC X(32) VALUE "scores".
 01 WS-N-RAINING           PIC X(32) VALUE "raining".
 01 WS-N-THUNDERING        PIC X(32) VALUE "thundering".
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-N-RANGE             PIC X(32) VALUE "range".
 01 WS-N-PERIOD            PIC X(32) VALUE "period".
 01 WS-N-ACTIVE            PIC X(32) VALUE "active".
 01 WS-KIND-BLOCK          BINARY-LONG VALUE 2.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-INT-KIND            BINARY-LONG VALUE 1.
 01 WS-FLOAT-KIND          BINARY-LONG VALUE 2.
 LOCAL-STORAGE SECTION.
 01 LS-SLOT                BINARY-LONG.
 01 LS-NODE                BINARY-LONG.
 01 LS-KIND                PIC X(48).
 01 LS-MEMBER              BINARY-LONG.
 01 LS-OTHER               BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-A                   FLOAT-LONG.
 01 LS-B                   FLOAT-LONG.
 01 LS-C                   FLOAT-LONG.
 01 LS-LEVEL               BINARY-LONG.
 01 LS-INT                 BINARY-LONG.
 01 LS-TYPE                PIC X(48).
 01 LS-KEY                 PIC X(112).
 01 LS-TICKS               BINARY-DOUBLE.
 01 LS-PERIOD              FLOAT-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE L-SLOT TO LS-SLOT
     MOVE L-NODE TO LS-NODE
     IF LS-NODE = 0
         GOBACK
     END-IF
     EVALUATE LDS-JN-TYPE(LS-SLOT, LS-NODE)
         WHEN JT-STRING
             CALL "LOOT-HOLDER" USING WS-REGISTRY LS-SLOT LS-NODE
             CALL "LOOT-COND-EVAL" USING LS-SLOT LS-NODE L-RESULT
             GOBACK
         WHEN JT-ARRAY
*>           A list is all_of its elements (section 1).
             MOVE 1 TO L-RESULT
             MOVE LDS-JN-FIRST(LS-SLOT, LS-NODE) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0 OR L-RESULT = 0
                 CALL "LOOT-COND-EVAL" USING LS-SLOT LS-CHILD L-RESULT
                 MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
             GOBACK
         WHEN JT-OBJECT
             CONTINUE
         WHEN OTHER
             GOBACK
     END-EVALUATE
     CALL "LOOT-J-KIND" USING LS-SLOT LS-NODE LS-KIND
     EVALUATE LS-KIND
         WHEN "inverted"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-TERM LS-MEMBER
             CALL "LOOT-COND-EVAL" USING LS-SLOT LS-MEMBER LS-OK
             COMPUTE L-RESULT = 1 - LS-OK
         WHEN "all_of"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-TERMS LS-MEMBER
             CALL "LOOT-COND-EVAL" USING LS-SLOT LS-MEMBER L-RESULT
         WHEN "any_of"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-TERMS LS-MEMBER
             MOVE 0 TO L-RESULT
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0 OR L-RESULT = 1
                 CALL "LOOT-COND-EVAL" USING LS-SLOT LS-CHILD L-RESULT
                 MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN "random_chance"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-CHANCE LS-MEMBER
             CALL "LOOT-FLOAT-GET" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-RNG-FLOAT" USING LS-B
             IF LS-B < LS-A
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN "random_chance_with_enchanted_bonus"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-UNENCHANTED LS-MEMBER
             CALL "LOOT-FLOAT-GET" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-ENCHANTMENT LS-MEMBER
             CALL "LOOT-J-TEXT" USING LS-SLOT LS-MEMBER LS-KEY LS-INT
             CALL "LOOT-ATTACKER-LEVEL" USING LS-KEY LS-LEVEL
             IF LS-LEVEL > 0
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-ENCHANTED LS-MEMBER
                 CALL "LOOT-LEVEL-EVAL" USING LS-SLOT LS-MEMBER LS-LEVEL LS-A
             END-IF
             CALL "LOOT-RNG-FLOAT" USING LS-B
             IF LS-B < LS-A
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN "killed_by_player"
             MOVE LW-C-KILLER TO L-RESULT
         WHEN "survives_explosion"
             MOVE 1 TO L-RESULT
             IF LW-C-RADIUS-SET = 1
                 CALL STATIC "cc_f64_div" USING BY REFERENCE WS-ONE BY REFERENCE LW-C-RADIUS BY REFERENCE LS-A
                 CALL "LOOT-F32" USING LS-A
                 CALL "LOOT-RNG-FLOAT" USING LS-B
                 IF LS-B > LS-A
                     MOVE 0 TO L-RESULT
                 END-IF
             END-IF
         WHEN "table_bonus"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-ENCHANTMENT LS-MEMBER
             CALL "LOOT-J-TEXT" USING LS-SLOT LS-MEMBER LS-KEY LS-INT
             CALL "LOOT-TOOL-LEVEL" USING LS-KEY LS-LEVEL
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-CHANCES LS-MEMBER
             MOVE LDS-JN-COUNT(LS-SLOT, LS-MEMBER) TO LS-INT
             IF LS-LEVEL > LS-INT - 1
                 COMPUTE LS-LEVEL = LS-INT - 1
             END-IF
             MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
             PERFORM LS-LEVEL TIMES
                 MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
             CALL "LOOT-J-NUMBER" USING LS-SLOT LS-CHILD LS-A LS-OK
             CALL "LOOT-F32" USING LS-A
             CALL "LOOT-RNG-FLOAT" USING LS-B
             IF LS-B < LS-A
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN "match_tool"
             IF LW-C-TOOL-SET = 1
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-PREDICATE LS-MEMBER
                 CALL "LOOT-ITEM-MATCH" USING LS-SLOT LS-MEMBER LW-C-TOOL-ITEM LW-C-TOOL-COUNT
                     LW-C-TOOL-HANDLE L-RESULT
             END-IF
         WHEN "match_block"
             CALL "LOOT-MATCH-BLOCK" USING LS-SLOT LS-NODE L-RESULT
         WHEN "weather_check"
             MOVE 1 TO L-RESULT
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-RAINING LS-MEMBER
             IF LS-MEMBER > 0
                 CALL "LOOT-J-TRUE" USING LS-SLOT LS-MEMBER LS-FLAG
                 IF LS-FLAG NOT = LW-C-RAINING
                     MOVE 0 TO L-RESULT
                 END-IF
             END-IF
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-THUNDERING LS-MEMBER
             IF LS-MEMBER > 0
                 CALL "LOOT-J-TRUE" USING LS-SLOT LS-MEMBER LS-FLAG
                 IF LS-FLAG NOT = LW-C-THUNDERING
                     MOVE 0 TO L-RESULT
                 END-IF
             END-IF
         WHEN "time_check"
             MOVE 0 TO LS-TICKS
             IF LW-C-CLOCK-SET = 1
                 MOVE LW-C-CLOCK-TICKS TO LS-TICKS
             END-IF
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-PERIOD LS-MEMBER
             CALL "LOOT-J-NUMBER" USING LS-SLOT LS-MEMBER LS-PERIOD LS-OK
             IF LS-OK = 1
                 COMPUTE LS-TICKS = FUNCTION REM(LS-TICKS, LS-PERIOD)
             END-IF
             MOVE LS-TICKS TO LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-VALUE LS-MEMBER
             CALL "LOOT-RANGE-TEST" USING LS-SLOT LS-MEMBER LS-A WS-INT-KIND L-RESULT
         WHEN "int_value_check"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-VALUE LS-MEMBER
             CALL "LOOT-INT-GET" USING LS-SLOT LS-MEMBER LS-INT
             MOVE LS-INT TO LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-RANGE LS-MEMBER
             CALL "LOOT-RANGE-TEST" USING LS-SLOT LS-MEMBER LS-A WS-INT-KIND L-RESULT
         WHEN "float_value_check"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-VALUE LS-MEMBER
             CALL "LOOT-FLOAT-GET" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-RANGE LS-MEMBER
             CALL "LOOT-RANGE-TEST" USING LS-SLOT LS-MEMBER LS-A WS-FLOAT-KIND L-RESULT
         WHEN "enchantment_active_check"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-ACTIVE LS-MEMBER
             CALL "LOOT-J-TRUE" USING LS-SLOT LS-MEMBER LS-FLAG
             IF LW-C-ACTIVE-SET = 1 AND LW-C-ACTIVE = LS-FLAG
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN "entity_properties"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-ENTITY LS-MEMBER
             CALL "LOOT-TARGET" USING LS-SLOT LS-MEMBER LS-OK LS-TYPE
             IF LS-OK = 1
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-PREDICATE LS-MEMBER
                 CALL "LOOT-ENTITY-MATCH" USING LS-SLOT LS-MEMBER LS-TYPE L-RESULT
             END-IF
         WHEN "entity_scores"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-ENTITY LS-MEMBER
             CALL "LOOT-TARGET" USING LS-SLOT LS-MEMBER LS-OK LS-TYPE
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-SCORES LS-MEMBER
             IF LS-OK = 1 AND LDS-JN-COUNT(LS-SLOT, LS-MEMBER) = 0
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN "location_check"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-PREDICATE LS-MEMBER
             IF LW-C-ORIGIN-SET = 1 AND (LS-MEMBER = 0 OR LDS-JN-COUNT(LS-SLOT, LS-MEMBER) = 0)
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-COND-EVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-PREDICATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "predicate".
 01 WS-SLOT                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SEQUENCE            PIC X(112) VALUE SPACES.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(112).
 COPY LOOTCTX.
 01 L-RESULT               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME LOOT-CONTEXT L-RESULT L-FOUND.
     MOVE 0 TO L-RESULT L-FOUND
     CALL "LOOT-ENTER" USING LOOT-CONTEXT WS-SEQUENCE
     CALL "LOOT-DOC-GET" USING WS-REGISTRY L-NAME WS-SLOT
     IF WS-SLOT > 0
         MOVE 1 TO WS-NODE
         MOVE 1 TO L-FOUND
         CALL "LOOT-COND-EVAL" USING WS-SLOT WS-NODE L-RESULT
     END-IF
     GOBACK.
 END PROGRAM LOOT-PREDICATE.
