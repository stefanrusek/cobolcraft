*> The spawn data loaders (T0291; docs/protocol/44-residual-mob-questions-2-spawning-structures.md sections 7.1 to 7.3,
*> 18-mob-framework.md sections 6.6 and 6.7, 21 sections 3.3 and 3.4, 23 sections 8.8 and 9.1, 19 section 1).
*> SPAWN-DATA-LOAD USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, CT-BAD-DATA; every error is on
*> standard error as "ERROR registry: ..." and nothing of the load stays). Two kinds of file are read by the shape engine
*> (shapes.cob, CTSHAPE.cpy) and kept as elements of its store:
*>   the biomes of data/<namespace>/worldgen/biome, whose attribute minecraft:gameplay/natural_mob_spawns holds the spawner
*>     lists and the spawn costs: spawns_by_category (a map from the 8 mob categories of 44 section 7.3 to a list of entries
*>     {type, weight, count}: weight an integer from 0, count an integer or a provider; 18 section 6.6) and spawn_costs (a map
*>     from an entity type to {charge, energy_budget}, numbers; 18 section 6.7). The value is {modifier, argument} (18 section
*>     6.6, 23 section 8.4) or the plain object of the argument;
*>   the seven variant registries with spawn_conditions (23 section 9.1): wolf_variant, pig_variant, frog_variant, cat_variant,
*>     cow_variant, chicken_variant and zombie_nautilus_variant, each with a list of selectors {condition?, priority}; a
*>     condition is of type biome (biomes), structure (structures) or moon_brightness (range).
*> A list is kept as the file wrote it (duplicate entries stay two items, 44 section 7.2: the overlay of 44 section 7.3
*> is the engine's matter). The accessors read the stored file on every call:
*>   SPAWN-LIST-COUNT USING biome key (PIC X(64)), category (PIC X(32)), count out (BINARY-LONG: the entries of the list, 0 for a
*>     category the biome lists empty, -1 for a category it does not define, 44 section 7.3), status out (CT-OK, CT-NOT-FOUND for
*>     a biome that is not stored, with count -1);
*>   SPAWN-LIST-ENTRY USING biome key, category, index (1-based), type out (PIC X(64)), weight, minimum, maximum (BINARY-LONG; a
*>     bare integer count is both bounds, uniform gives min_inclusive and max_inclusive, constant its value, 18 section 6.5
*>     step 5), status out (CT-OK, CT-NOT-FOUND);
*>   SPAWN-COST USING biome key, entity key (PIC X(64), as the file names it), charge, energy budget (FLOAT-LONG), status out
*>     (CT-OK, CT-NOT-FOUND for a biome or an entity without a cost);
*>   SPAWN-VARIANT-COUNT USING registry (PIC X(48), such as "wolf_variant"), key, count out, status out (CT-OK, CT-NOT-FOUND with
*>     count 0): the selectors of the variant;
*>   SPAWN-VARIANT-SELECTOR USING registry, key, index (1-based), priority out, kind out (0 no condition, 1 biome, 2 structure,
*>     3 moon_brightness), argument out (PIC X(64): the first identifier or #tag of biomes or structures, spaces otherwise),
*>     status out (CT-OK, CT-NOT-FOUND). The moon_brightness range stays in the stored file for the engine.
*> Documented assumptions: S1 a biome without the attribute, or a biome whose attribute does not name a category, has no natural
*> spawns of it (-1, 44 section 7.3); S2 the entries and costs are required to carry all their members (type, weight and count;
*> charge and energy_budget), because 18 section 6.6 gives the form without marking optional members; S3 a count that is an
*> object of another provider type than uniform or constant is accepted unchecked and reads as 0 to 0; S4 the category name of a
*> list is one of the 8 names of 44 section 8.3; S5 a variant registry with no file ("Registry must be non-empty", 23 section
*> 11) is the registry freeze's rule, not checked by this loader; S6 the structure spawn_overrides of 44 section 8 are
*> structure files and belong to the structure loaders; S7 the argument of a condition given as an inline object (a holder
*> set object form) reads as spaces.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-ATTRIBUTE.
*> USING JSON-DOC, the parsed biome (node 1 is its root), value node out (BINARY-LONG: the value of the attribute
*> minecraft:gameplay/natural_mob_spawns, 0 when the biome has no attributes or not that one).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ATTRIBUTES          PIC X(32) VALUE "attributes".
 01 WS-KEY                 PIC X(64) VALUE "minecraft:gameplay/natural_mob_spawns".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 37.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-VALUE.
     MOVE 0 TO L-VALUE
     CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-ATTRIBUTES WS-NODE
     IF WS-NODE > 0
         CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY WS-KEY-LENGTH L-VALUE
     END-IF
     GOBACK.
 END PROGRAM SPAWN-ATTRIBUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-SETTINGS.
*> USING JSON-DOC, value node of SPAWN-ATTRIBUTE (an object), settings node out (BINARY-LONG: the member argument when there is
*> one, else the value itself: the two forms of 18 section 6.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARGUMENT            PIC X(32) VALUE "argument".
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-VALUE                BINARY-LONG.
 01 L-SETTINGS             BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-VALUE L-SETTINGS.
     MOVE L-VALUE TO L-SETTINGS
     CALL "RECIPE-MEMBER" USING JSON-DOC L-VALUE WS-ARGUMENT WS-NODE
     IF WS-NODE > 0
         MOVE WS-NODE TO L-SETTINGS
     END-IF
     GOBACK.
 END PROGRAM SPAWN-SETTINGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-CATEGORIES-CHECK.
*> USING JSON-DOC, the spawns_by_category object, biome key (PIC X(64)): every category is one of the 8 mob categories with a
*> list of entries of the shape spawn_entry (one error each otherwise, WG-FAIL).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CATEGORIES.
    05 FILLER PIC X(32) VALUE "monster".
    05 FILLER PIC X(32) VALUE "creature".
    05 FILLER PIC X(32) VALUE "ambient".
    05 FILLER PIC X(32) VALUE "axolotls".
    05 FILLER PIC X(32) VALUE "underground_water_creature".
    05 FILLER PIC X(32) VALUE "water_creature".
    05 FILLER PIC X(32) VALUE "water_ambient".
    05 FILLER PIC X(32) VALUE "misc".
 01 WS-CATEGORY-TABLE REDEFINES WS-CATEGORIES.
    05 WS-CATEGORY         PIC X(32) OCCURS 8 TIMES.
 01 WS-ENTRY-GROUP         PIC X(24) VALUE "spawn_entry".
 01 WS-LENIENT             BINARY-LONG VALUE 0.
 01 B-TEXT                 PIC X(268435456) BASED.
 01 WS-I                   BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NAME-POS            BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-MAP                  BINARY-LONG.
 01 L-KEY                  PIC X(64).
 PROCEDURE DIVISION USING JSON-DOC L-MAP L-KEY.
     SET ADDRESS OF B-TEXT TO JD-ADDR
     MOVE JN-FIRST(L-MAP) TO WS-MEMBER
     PERFORM UNTIL WS-MEMBER = 0
         MOVE JN-KEY-POS(WS-MEMBER) TO WS-NAME-POS
         MOVE JN-KEY-LENGTH(WS-MEMBER) TO WS-NAME-LENGTH
         MOVE SPACES TO WS-NAME
         IF WS-NAME-LENGTH <= 64
             MOVE B-TEXT(WS-NAME-POS:WS-NAME-LENGTH) TO WS-NAME
         END-IF
         MOVE 0 TO WS-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
             IF WS-NAME = WS-CATEGORY(WS-I)
                 MOVE 1 TO WS-OK
             END-IF
         END-PERFORM
         IF WS-OK = 0
             MOVE SPACES TO WS-DETAIL
             STRING "spawns_by_category: " FUNCTION TRIM(WS-NAME) " is not a mob category" DELIMITED BY SIZE INTO WS-DETAIL
             CALL "WG-FAIL" USING L-KEY WS-DETAIL
         END-IF
         IF JN-TYPE(WS-MEMBER) = JT-ARRAY
             MOVE JN-FIRST(WS-MEMBER) TO WS-ITEM
             PERFORM UNTIL WS-ITEM = 0
                 CALL "SHAPE-VALIDATE" USING JSON-DOC WS-ITEM WS-ENTRY-GROUP L-KEY WS-LENIENT WS-STATUS
                 MOVE JN-NEXT(WS-ITEM) TO WS-ITEM
             END-PERFORM
         ELSE
             MOVE SPACES TO WS-DETAIL
             STRING "spawns_by_category: " FUNCTION TRIM(WS-NAME) " must be a list" DELIMITED BY SIZE INTO WS-DETAIL
             CALL "WG-FAIL" USING L-KEY WS-DETAIL
         END-IF
         MOVE JN-NEXT(WS-MEMBER) TO WS-MEMBER
     END-PERFORM
     GOBACK.
 END PROGRAM SPAWN-CATEGORIES-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-VALUE-CHECK.
*> USING JSON-DOC, the value of the attribute natural_mob_spawns, biome key (PIC X(64)): the value and its argument are objects,
*> the settings pass the shape spawn_settings, the categories pass SPAWN-CATEGORIES-CHECK and every spawn cost passes the shape
*> spawn_cost (errors reported with WG-FAIL).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BY-CATEGORY         PIC X(32) VALUE "spawns_by_category".
 01 WS-COSTS               PIC X(32) VALUE "spawn_costs".
 01 WS-SETTINGS-GROUP      PIC X(24) VALUE "spawn_settings".
 01 WS-COST-GROUP          PIC X(24) VALUE "spawn_cost".
 01 WS-LENIENT             BINARY-LONG VALUE 0.
 01 WS-SETTINGS            BINARY-LONG.
 01 WS-MAP                 BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-VALUE                BINARY-LONG.
 01 L-KEY                  PIC X(64).
 PROCEDURE DIVISION USING JSON-DOC L-VALUE L-KEY.
     MOVE 0 TO WS-SETTINGS
     IF JN-TYPE(L-VALUE) = JT-OBJECT
         CALL "SPAWN-SETTINGS" USING JSON-DOC L-VALUE WS-SETTINGS
     ELSE
         MOVE "natural_mob_spawns must be an object" TO WS-DETAIL
         CALL "WG-FAIL" USING L-KEY WS-DETAIL
     END-IF
     IF WS-SETTINGS > 0 AND JN-TYPE(WS-SETTINGS) NOT = JT-OBJECT
         MOVE "natural_mob_spawns argument must be an object" TO WS-DETAIL
         CALL "WG-FAIL" USING L-KEY WS-DETAIL
         MOVE 0 TO WS-SETTINGS
     END-IF
     IF WS-SETTINGS > 0
         CALL "SHAPE-VALIDATE" USING JSON-DOC WS-SETTINGS WS-SETTINGS-GROUP L-KEY WS-LENIENT WS-STATUS
         CALL "RECIPE-MEMBER" USING JSON-DOC WS-SETTINGS WS-BY-CATEGORY WS-MAP
         IF WS-MAP > 0 AND JN-TYPE(WS-MAP) = JT-OBJECT
             CALL "SPAWN-CATEGORIES-CHECK" USING JSON-DOC WS-MAP L-KEY
         END-IF
         CALL "RECIPE-MEMBER" USING JSON-DOC WS-SETTINGS WS-COSTS WS-MAP
         IF WS-MAP > 0 AND JN-TYPE(WS-MAP) = JT-OBJECT
             MOVE JN-FIRST(WS-MAP) TO WS-MEMBER
             PERFORM UNTIL WS-MEMBER = 0
                 CALL "SHAPE-VALIDATE" USING JSON-DOC WS-MEMBER WS-COST-GROUP L-KEY WS-LENIENT WS-STATUS
                 MOVE JN-NEXT(WS-MEMBER) TO WS-MEMBER
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SPAWN-VALUE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-BIOME-CHECK.
*> No parameters: checks the spawn data of the biomes of the registry worldgen/biome stored since SHAPE-BEGIN (the shapes have
*> already vouched for their form) with SPAWN-VALUE-CHECK. Errors are counted for SHAPE-END.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 COPY CTWORLDGEN.
 COPY JSONDOC.
 01 B-TEXT                 PIC X(268435456) BASED.
 01 WS-E                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 PROCEDURE DIVISION.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > SH-ELEMENT-COUNT
         IF WS-E > SH-MARK AND SH-E-REGISTRY(WS-E) = "worldgen/biome"
             SET ADDRESS OF B-TEXT TO SH-E-ADDR(WS-E)
             MOVE SH-E-LENGTH(WS-E) TO WS-LENGTH
             MOVE SH-E-KEY(WS-E) TO WS-KEY
             MOVE SPACES TO WG-LABEL
             MOVE "worldgen/biome" TO WG-LABEL
             CALL "JSON-PARSE" USING JSON-DOC B-TEXT WS-LENGTH
             CALL "SPAWN-ATTRIBUTE" USING JSON-DOC WS-VALUE
             IF WS-VALUE > 0
                 CALL "SPAWN-VALUE-CHECK" USING JSON-DOC WS-VALUE WS-KEY
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPAWN-BIOME-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-DATA-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the header of this file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "biome_spawn".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "o attributes".
    05 FILLER PIC X(24) VALUE "spawn_settings".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "o spawns_by_category;o spawn_costs".
    05 FILLER PIC X(24) VALUE "spawn_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D type;I weight=0..;V count=spawn_count".
    05 FILLER PIC X(24) VALUE "spawn_count".
    05 FILLER PIC X(48) VALUE "uniform".
    05 FILLER PIC X(600) VALUE "I min_inclusive;I max_inclusive".
    05 FILLER PIC X(24) VALUE "spawn_count".
    05 FILLER PIC X(48) VALUE "constant".
    05 FILLER PIC X(600) VALUE "I value".
    05 FILLER PIC X(24) VALUE "spawn_cost".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "N charge;N energy_budget".
    05 FILLER PIC X(24) VALUE "variant".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L spawn_conditions=spawn_selector".
    05 FILLER PIC X(24) VALUE "spawn_selector".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "t condition=spawn_condition;I priority".
    05 FILLER PIC X(24) VALUE "spawn_condition".
    05 FILLER PIC X(48) VALUE "biome".
    05 FILLER PIC X(600) VALUE "H biomes=biome".
    05 FILLER PIC X(24) VALUE "spawn_condition".
    05 FILLER PIC X(48) VALUE "structure".
    05 FILLER PIC X(600) VALUE "H structures=structure".
    05 FILLER PIC X(24) VALUE "spawn_condition".
    05 FILLER PIC X(48) VALUE "moon_brightness".
    05 FILLER PIC X(600) VALUE "X range".
    05 FILLER PIC X(24) VALUE "spawn_condition".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 13.
 01 WS-REGISTRIES.
    05 FILLER PIC X(48) VALUE "wolf_variant".
    05 FILLER PIC X(48) VALUE "pig_variant".
    05 FILLER PIC X(48) VALUE "frog_variant".
    05 FILLER PIC X(48) VALUE "cat_variant".
    05 FILLER PIC X(48) VALUE "cow_variant".
    05 FILLER PIC X(48) VALUE "chicken_variant".
    05 FILLER PIC X(48) VALUE "zombie_nautilus_variant".
 01 WS-REGISTRY-TABLE REDEFINES WS-REGISTRIES.
    05 WS-REGISTRY         PIC X(48) OCCURS 7 TIMES.
 01 WS-BIOME               PIC X(48) VALUE "worldgen/biome".
 01 WS-BIOME-GROUP         PIC X(24) VALUE "biome_spawn".
 01 WS-VARIANT-GROUP       PIC X(24) VALUE "variant".
 01 WS-LENIENT             BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-BIOME WS-BIOME-GROUP WS-LENIENT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY(WS-I) WS-VARIANT-GROUP WS-LENIENT
     END-PERFORM
     CALL "SPAWN-BIOME-CHECK"
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM SPAWN-DATA-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-CATEGORY-NODE.
*> USING JSON-DOC, biome key (PIC X(64)), category (PIC X(32)), list node out (BINARY-LONG: the list of the category, 0 when the
*> biome does not define it), settings node out (BINARY-LONG: the settings object, 0 when the biome has no spawn data),
*> status out (CT-OK, CT-NOT-FOUND for a biome that is not stored). The biome file is parsed into the document.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-REGISTRY            PIC X(48) VALUE "worldgen/biome".
 01 WS-BY-CATEGORY         PIC X(32) VALUE "spawns_by_category".
 01 WS-ROW                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-MAP                 BINARY-LONG.
 01 B-TEXT                 PIC X(268435456) BASED.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-KEY                  PIC X(64).
 01 L-CATEGORY             PIC X(32).
 01 L-LIST                 BINARY-LONG.
 01 L-SETTINGS             BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-KEY L-CATEGORY L-LIST L-SETTINGS L-STATUS.
     MOVE 0 TO L-LIST L-SETTINGS
     MOVE CT-NOT-FOUND TO L-STATUS
     CALL "SHAPE-FIND" USING WS-REGISTRY L-KEY WS-ROW
     IF WS-ROW > 0
         MOVE CT-OK TO L-STATUS
         SET ADDRESS OF B-TEXT TO SH-E-ADDR(WS-ROW)
         MOVE SH-E-LENGTH(WS-ROW) TO WS-LENGTH
         CALL "JSON-PARSE" USING JSON-DOC B-TEXT WS-LENGTH
         CALL "SPAWN-ATTRIBUTE" USING JSON-DOC WS-VALUE
         IF WS-VALUE > 0
             CALL "SPAWN-SETTINGS" USING JSON-DOC WS-VALUE L-SETTINGS
             CALL "RECIPE-MEMBER" USING JSON-DOC L-SETTINGS WS-BY-CATEGORY WS-MAP
             CALL "RECIPE-MEMBER" USING JSON-DOC WS-MAP L-CATEGORY L-LIST
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SPAWN-CATEGORY-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-LIST-COUNT.
*> USING biome key (PIC X(64)), category (PIC X(32)), count out, status out: the header of this file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY JSONDOC.
 01 WS-LIST                BINARY-LONG.
 01 WS-SETTINGS            BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-CATEGORY             PIC X(32).
 01 L-COUNT                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CATEGORY L-COUNT L-STATUS.
     MOVE -1 TO L-COUNT
     CALL "SPAWN-CATEGORY-NODE" USING JSON-DOC L-KEY L-CATEGORY WS-LIST WS-SETTINGS L-STATUS
     IF WS-LIST > 0
         MOVE JN-COUNT(WS-LIST) TO L-COUNT
     END-IF
     GOBACK.
 END PROGRAM SPAWN-LIST-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-LIST-ENTRY.
*> USING biome key, category, index (1-based), type out (PIC X(64)), weight, minimum, maximum (BINARY-LONG), status out: the
*> header of this file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY JSONDOC.
 01 WS-TYPE-NAME           PIC X(32) VALUE "type".
 01 WS-WEIGHT-NAME         PIC X(32) VALUE "weight".
 01 WS-COUNT-NAME          PIC X(32) VALUE "count".
 01 WS-MIN-NAME            PIC X(32) VALUE "min_inclusive".
 01 WS-MAX-NAME            PIC X(32) VALUE "max_inclusive".
 01 WS-VALUE-NAME          PIC X(32) VALUE "value".
 01 WS-LIST                BINARY-LONG.
 01 WS-SETTINGS            BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT-NODE          BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-FOUND               BINARY-LONG.
 01 WS-NUMBER              USAGE FLOAT-LONG.
 01 WS-LOW                 USAGE FLOAT-LONG.
 01 WS-HIGH                USAGE FLOAT-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-CATEGORY             PIC X(32).
 01 L-INDEX                BINARY-LONG.
 01 L-TYPE                 PIC X(64).
 01 L-WEIGHT               BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CATEGORY L-INDEX L-TYPE L-WEIGHT L-MIN L-MAX L-STATUS.
     MOVE SPACES TO L-TYPE
     MOVE 0 TO L-WEIGHT L-MIN L-MAX WS-ITEM WS-LOW WS-HIGH
     CALL "SPAWN-CATEGORY-NODE" USING JSON-DOC L-KEY L-CATEGORY WS-LIST WS-SETTINGS L-STATUS
     IF WS-LIST > 0 AND L-INDEX > 0
         MOVE JN-FIRST(WS-LIST) TO WS-ITEM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= L-INDEX OR WS-ITEM = 0
             MOVE JN-NEXT(WS-ITEM) TO WS-ITEM
         END-PERFORM
     END-IF
     IF WS-ITEM = 0
         MOVE CT-NOT-FOUND TO L-STATUS
     ELSE
         MOVE CT-OK TO L-STATUS
         CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-ITEM WS-TYPE-NAME WS-TEXT WS-FOUND
         MOVE WS-TEXT TO L-TYPE
         CALL "RECIPE-NUMBER" USING JSON-DOC WS-ITEM WS-WEIGHT-NAME WS-NUMBER WS-FOUND
         MOVE WS-NUMBER TO L-WEIGHT
         CALL "RECIPE-MEMBER" USING JSON-DOC WS-ITEM WS-COUNT-NAME WS-COUNT-NODE
         IF JN-TYPE(WS-COUNT-NODE) = JT-NUMBER
             MOVE JN-NUM(WS-COUNT-NODE) TO WS-LOW
             MOVE WS-LOW TO WS-HIGH
         END-IF
         IF JN-TYPE(WS-COUNT-NODE) = JT-OBJECT
             CALL "RECIPE-NUMBER" USING JSON-DOC WS-COUNT-NODE WS-MIN-NAME WS-LOW WS-FOUND
             CALL "RECIPE-NUMBER" USING JSON-DOC WS-COUNT-NODE WS-MAX-NAME WS-HIGH WS-FOUND
             CALL "RECIPE-NUMBER" USING JSON-DOC WS-COUNT-NODE WS-VALUE-NAME WS-NUMBER WS-FOUND
             IF WS-FOUND = 1
                 MOVE WS-NUMBER TO WS-LOW WS-HIGH
             END-IF
         END-IF
         MOVE WS-LOW TO L-MIN
         MOVE WS-HIGH TO L-MAX
     END-IF
     GOBACK.
 END PROGRAM SPAWN-LIST-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-COST.
*> USING biome key (PIC X(64)), entity key (PIC X(64)), charge, energy budget (FLOAT-LONG), status out: the header of this file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY JSONDOC.
 01 WS-CATEGORY            PIC X(32) VALUE "monster".
 01 WS-COSTS               PIC X(32) VALUE "spawn_costs".
 01 WS-CHARGE-NAME         PIC X(32) VALUE "charge".
 01 WS-BUDGET-NAME         PIC X(32) VALUE "energy_budget".
 01 WS-LIST                BINARY-LONG.
 01 WS-SETTINGS            BINARY-LONG.
 01 WS-MAP                 BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-ENTITY               PIC X(64).
 01 L-CHARGE               USAGE FLOAT-LONG.
 01 L-BUDGET               USAGE FLOAT-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ENTITY L-CHARGE L-BUDGET L-STATUS.
     MOVE 0 TO L-CHARGE L-BUDGET WS-COST
     CALL "SPAWN-CATEGORY-NODE" USING JSON-DOC L-KEY WS-CATEGORY WS-LIST WS-SETTINGS L-STATUS
     IF WS-SETTINGS > 0
         CALL "RECIPE-MEMBER" USING JSON-DOC WS-SETTINGS WS-COSTS WS-MAP
         MOVE 0 TO WS-LENGTH
         INSPECT L-ENTITY TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
         CALL "JSON-MEMBER" USING JSON-DOC WS-MAP L-ENTITY WS-LENGTH WS-COST
     END-IF
     IF WS-COST = 0
         MOVE CT-NOT-FOUND TO L-STATUS
     ELSE
         MOVE CT-OK TO L-STATUS
         CALL "RECIPE-NUMBER" USING JSON-DOC WS-COST WS-CHARGE-NAME L-CHARGE WS-FOUND
         CALL "RECIPE-NUMBER" USING JSON-DOC WS-COST WS-BUDGET-NAME L-BUDGET WS-FOUND
     END-IF
     GOBACK.
 END PROGRAM SPAWN-COST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-VARIANT-NODE.
*> USING JSON-DOC, registry (PIC X(48)), key (PIC X(64)), list node out (BINARY-LONG: spawn_conditions of the stored variant, 0
*> when the variant is not stored). The variant file is parsed into the document.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 01 WS-CONDITIONS          PIC X(32) VALUE "spawn_conditions".
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 B-TEXT                 PIC X(268435456) BASED.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-REGISTRY             PIC X(48).
 01 L-KEY                  PIC X(64).
 01 L-LIST                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-REGISTRY L-KEY L-LIST.
     MOVE 0 TO L-LIST
     CALL "SHAPE-FIND" USING L-REGISTRY L-KEY WS-ROW
     IF WS-ROW > 0
         SET ADDRESS OF B-TEXT TO SH-E-ADDR(WS-ROW)
         MOVE SH-E-LENGTH(WS-ROW) TO WS-LENGTH
         CALL "JSON-PARSE" USING JSON-DOC B-TEXT WS-LENGTH
         CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-CONDITIONS L-LIST
     END-IF
     GOBACK.
 END PROGRAM SPAWN-VARIANT-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-VARIANT-COUNT.
*> USING registry (PIC X(48)), key (PIC X(64)), count out, status out: the header of this file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY JSONDOC.
 01 WS-LIST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-KEY                  PIC X(64).
 01 L-COUNT                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-KEY L-COUNT L-STATUS.
     MOVE 0 TO L-COUNT
     CALL "SPAWN-VARIANT-NODE" USING JSON-DOC L-REGISTRY L-KEY WS-LIST
     MOVE CT-NOT-FOUND TO L-STATUS
     IF WS-LIST > 0
         MOVE CT-OK TO L-STATUS
         MOVE JN-COUNT(WS-LIST) TO L-COUNT
     END-IF
     GOBACK.
 END PROGRAM SPAWN-VARIANT-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-VARIANT-SELECTOR.
*> USING registry (PIC X(48)), key (PIC X(64)), index (1-based), priority out, kind out, argument out (PIC X(64)), status out:
*> the header of this file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY JSONDOC.
 01 WS-PRIORITY-NAME       PIC X(32) VALUE "priority".
 01 WS-CONDITION-NAME      PIC X(32) VALUE "condition".
 01 WS-TYPE-NAME           PIC X(32) VALUE "type".
 01 WS-BIOMES-NAME         PIC X(32) VALUE "biomes".
 01 WS-STRUCTURES-NAME     PIC X(32) VALUE "structures".
 01 WS-LIST                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CONDITION           BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-SHORT               PIC X(200).
 01 WS-NUMBER              USAGE FLOAT-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-KEY                  PIC X(64).
 01 L-INDEX                BINARY-LONG.
 01 L-PRIORITY             BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ARGUMENT             PIC X(64).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-KEY L-INDEX L-PRIORITY L-KIND L-ARGUMENT L-STATUS.
     MOVE 0 TO L-PRIORITY L-KIND WS-ITEM WS-HOLDER
     MOVE SPACES TO L-ARGUMENT
     CALL "SPAWN-VARIANT-NODE" USING JSON-DOC L-REGISTRY L-KEY WS-LIST
     IF WS-LIST > 0 AND L-INDEX > 0
         MOVE JN-FIRST(WS-LIST) TO WS-ITEM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= L-INDEX OR WS-ITEM = 0
             MOVE JN-NEXT(WS-ITEM) TO WS-ITEM
         END-PERFORM
     END-IF
     IF WS-ITEM = 0
         MOVE CT-NOT-FOUND TO L-STATUS
     ELSE
         MOVE CT-OK TO L-STATUS
         CALL "RECIPE-NUMBER" USING JSON-DOC WS-ITEM WS-PRIORITY-NAME WS-NUMBER WS-FOUND
         MOVE WS-NUMBER TO L-PRIORITY
         CALL "RECIPE-MEMBER" USING JSON-DOC WS-ITEM WS-CONDITION-NAME WS-CONDITION
         IF WS-CONDITION > 0
             CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-CONDITION WS-TYPE-NAME WS-TEXT WS-FOUND
             MOVE WS-TEXT TO WS-SHORT
             IF WS-TEXT(1:10) = "minecraft:"
                 MOVE SPACES TO WS-SHORT
                 MOVE WS-TEXT(11:) TO WS-SHORT
             END-IF
             EVALUATE WS-SHORT
                 WHEN "biome"
                     MOVE 1 TO L-KIND
                     CALL "RECIPE-MEMBER" USING JSON-DOC WS-CONDITION WS-BIOMES-NAME WS-HOLDER
                 WHEN "structure"
                     MOVE 2 TO L-KIND
                     CALL "RECIPE-MEMBER" USING JSON-DOC WS-CONDITION WS-STRUCTURES-NAME WS-HOLDER
                 WHEN OTHER
                     MOVE 3 TO L-KIND
             END-EVALUATE
             IF WS-HOLDER > 0
                 CALL "SPAWN-HOLDER-TEXT" USING JSON-DOC WS-HOLDER L-ARGUMENT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SPAWN-VARIANT-SELECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-HOLDER-TEXT.
*> USING JSON-DOC, holder set node, text out (PIC X(64)): the identifier or #tag of a string, or of the first element of an
*> array; spaces for anything else.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODE                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-HOLDER               BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 PROCEDURE DIVISION USING JSON-DOC L-HOLDER L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE L-HOLDER TO WS-NODE
     IF JN-TYPE(WS-NODE) = JT-ARRAY
         MOVE JN-FIRST(WS-NODE) TO WS-NODE
     END-IF
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-STRING
             CALL "JSON-STRING" USING JSON-DOC WS-NODE L-TEXT WS-CAPACITY WS-LENGTH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SPAWN-HOLDER-TEXT.
