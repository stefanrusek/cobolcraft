*> Test of content/src/entities.cob (T0194; content-api section 2; 46 section 11 and 15): CONTENT-ENTITY-BY-KEY USING
*> key (PIC X(64)), entity id out, row out (PIC X(66), CT-ENTITY-ROW), status; CONTENT-STATIC-ID USING registry
*> (PIC X(48)), key (PIC X(64)), id out, status. The static registries keep the vanilla numbering; the block,
*> item and entity_type registries answer by the lookups of the set. An unknown key is CT-NOT-FOUND with id 0.
*> The set is made by setting CT-SET.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONTENT-ENTITIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-KEY                 PIC X(64).
 01 WS-REGISTRY            PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(66).
 01 WS-VIEW REDEFINES WS-ROW.
    05 WS-R-ID             PIC X(3).
    05 WS-R-KEY            PIC X(22).
    05 WS-R-SIZE           PIC X(15).
    05 WS-R-CATEGORY       PIC X(26).
 PROCEDURE DIVISION.
     MOVE 0 TO CT-OPEN
     MOVE "pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: no set open, by key" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "mob_effect" TO WS-REGISTRY
     MOVE "haste" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "entities: no set open, static id" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE

*>   Entity types: 46 section 11 (pig 101, item 72, player 159, fishing_bobber 160, the six off-order ids).
     MOVE "pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: pig is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "entities: pig is entity 101" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "entities: pig size" TO TL-CASE
     MOVE "0.9 x 0.9" TO TL-EXPECTED
     MOVE WS-R-SIZE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "entities: pig category" TO TL-CASE
     MOVE "CREATURE" TO TL-EXPECTED
     MOVE WS-R-CATEGORY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "minecraft:item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: item with its namespace is entity 72" TO TL-CASE
     MOVE 72 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "player" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: player is entity 159" TO TL-CASE
     MOVE 159 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "fishing_bobber" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: fishing_bobber is entity 160, the last" TO TL-CASE
     MOVE 160 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "copper_golem" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: copper_golem is entity 28 (not at its sorted place)" TO TL-CASE
     MOVE 28 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "happy_ghast" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: happy_ghast is entity 59" TO TL-CASE
     MOVE 59 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "splash_potion" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: splash_potion is entity 108" TO TL-CASE
     MOVE 108 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "lingering_potion" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: lingering_potion is entity 109" TO TL-CASE
     MOVE 109 TO TL-EXPECTED-N
     PERFORM ASSERT-ID

*>   Unknown keys: the defined outcome, and the sets share no rows (WT-25).
     MOVE "no_such_entity" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: unknown key is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "entities: unknown key gives id 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "entities: unknown key gives row 0 (acacia_boat)" TO TL-CASE
     MOVE "acacia_boat" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "cobolcraft:operator" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: a cobolcraft key is not in the standard set" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "entities: a blank key is not found" TO TL-CASE
     PERFORM ASSERT-STATUS

*>   Static ids: 46 section 15 examples.
     MOVE "mob_effect" TO WS-REGISTRY
     MOVE "haste" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: mob_effect haste is 2 (example 1)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "entities: static lookup status ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "regeneration" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: mob_effect regeneration is 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "minecraft:speed" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: mob_effect minecraft:speed is 0 (the namespace is optional)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "minecraft:menu" TO WS-REGISTRY
     MOVE "crafting" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: minecraft:menu crafting is 12 (example 2)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "generic_9x3" TO WS-KEY
     MOVE "menu" TO WS-REGISTRY
     PERFORM STATIC-LOOKUP
     MOVE "entities: menu generic_9x3 is 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "command_argument_type" TO WS-REGISTRY
     MOVE "brigadier:integer" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: command argument brigadier:integer is 3 (example 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "uuid" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: command argument uuid is 61" TO TL-CASE
     MOVE 61 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "block_entity_type" TO WS-REGISTRY
     MOVE "chest" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: block entity chest is 1 (example 4)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "particle_type" TO WS-REGISTRY
     MOVE "flash" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: particle flash is 52 (example 5)" TO TL-CASE
     MOVE 52 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "stat_type" TO WS-REGISTRY
     MOVE "custom" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: stat type custom is 8 (example 6)" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "sound_event" TO WS-REGISTRY
     MOVE "entity.horse.ambient" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: sound entity.horse.ambient is 853 (example 9)" TO TL-CASE
     MOVE 853 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "point_of_interest_type" TO WS-REGISTRY
     MOVE "lightning_rod" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: point of interest lightning_rod is 20 (example 10)" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "data_component_type" TO WS-REGISTRY
     MOVE "cushion/color" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: component cushion/color is 121 (example 11)" TO TL-CASE
     MOVE 121 TO TL-EXPECTED-N
     PERFORM ASSERT-ID

*>   The three content registries go through the set's lookups.
     MOVE "block" TO WS-REGISTRY
     MOVE "stone" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: block stone is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "minecraft:item" TO WS-REGISTRY
     MOVE "oak_log" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: item oak_log is 163" TO TL-CASE
     MOVE 163 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "entity_type" TO WS-REGISTRY
     MOVE "pig" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: entity_type pig is 101 (example 12)" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "block" TO WS-REGISTRY
     MOVE "no_such_block" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: an unknown block key is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "entities: an unknown block key gives id 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-ID

*>   Unknown registry or key.
     MOVE "no_such_registry" TO WS-REGISTRY
     MOVE "haste" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: an unknown registry is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "entities: an unknown registry gives id 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "mob_effect" TO WS-REGISTRY
     MOVE "no_such_effect" TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: an unknown key in a known registry is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-KEY
     PERFORM STATIC-LOOKUP
     MOVE "entities: a blank key is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "haste" TO WS-KEY
     MOVE "attribute" TO WS-REGISTRY
     PERFORM STATIC-LOOKUP
     MOVE "entities: a key of another registry is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     STOP RUN.

 STATIC-LOOKUP.
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS.

 ASSERT-ID.
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
