*> Test of the built-in entity layer (T0206; docs/design/standin-content.md section 3 and 12, cobolcraft-standard-core.md
*> section 5.5): the cobolcraft set answers CONTENT-ENTITY-BY-KEY with the four entity types as rows of the
*> same shape as the standard set (id, key, size, category), and CONTENT-ENTITY-ATTRIBUTE USING entity id,
*> attribute name (PIC X(32)), value out (PIC X(20)), status answers the mob values of core 5.5 (attributes,
*> eye height, tracking range and update interval). CONTENT-STATIC-ID of the entity_type registry uses the
*> same rows. The standard set has no attribute rows: CT-NOT-FOUND.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUILTIN-ENTITIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112).
 01 WS-REGISTRY            PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(66).
 01 WS-VIEW REDEFINES WS-ROW.
    05 WS-R-ID             PIC X(3).
    05 WS-R-KEY            PIC X(22).
    05 WS-R-SIZE           PIC X(15).
    05 WS-R-CATEGORY       PIC X(26).
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(20).
 PROCEDURE DIVISION.
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE

     MOVE "cobolcraft:operator" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "builtin entities: operator is entity 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "builtin entities: operator is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "builtin entities: operator size" TO TL-CASE
     MOVE "0.6 x 1.8" TO TL-EXPECTED
     MOVE WS-R-SIZE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "builtin entities: operator category is the player's" TO TL-CASE
     MOVE "MISC" TO TL-EXPECTED
     MOVE WS-R-CATEGORY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "cobolcraft:loose_item" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "builtin entities: loose_item is entity 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "builtin entities: loose_item size" TO TL-CASE
     MOVE "0.25 x 0.25" TO TL-EXPECTED
     MOVE WS-R-SIZE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "cobolcraft:sodgrazer" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "builtin entities: sodgrazer is entity 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "builtin entities: sodgrazer size" TO TL-CASE
     MOVE "0.9 x 0.9" TO TL-EXPECTED
     MOVE WS-R-SIZE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "builtin entities: sodgrazer is a creature (CORE-30)" TO TL-CASE
     MOVE "CREATURE" TO TL-EXPECTED
     MOVE WS-R-CATEGORY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "cobolcraft:abend" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "builtin entities: abend is entity 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "builtin entities: abend size" TO TL-CASE
     MOVE "0.75 x 0.75" TO TL-EXPECTED
     MOVE WS-R-SIZE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "builtin entities: abend is a monster" TO TL-CASE
     MOVE "MONSTER" TO TL-EXPECTED
     MOVE WS-R-CATEGORY TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   The sets share no rows (WT-25).
     MOVE "pig" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "builtin entities: pig is not in the cobolcraft set" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "builtin entities: unknown key gives row 0 (operator)" TO TL-CASE
     MOVE "cobolcraft:operator" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "minecraft:player" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "builtin entities: minecraft:player is not in the cobolcraft set" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   The static lookup of entity_type goes through the same rows.
     MOVE "entity_type" TO WS-REGISTRY
     MOVE "cobolcraft:abend" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "builtin entities: entity_type cobolcraft:abend is 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "block" TO WS-REGISTRY
     MOVE "cobolcraft:slag" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "builtin entities: block cobolcraft:slag is 11" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "item" TO WS-REGISTRY
     MOVE "cobolcraft:dump_shard" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "builtin entities: item cobolcraft:dump_shard is 15" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "mob_effect" TO WS-REGISTRY
     MOVE "haste" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "builtin entities: the other static registries keep the vanilla numbering" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     PERFORM ASSERT-ID

*>   Mob values of core 5.5.
     MOVE 2 TO WS-ID
     MOVE "max_health" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: sodgrazer max_health 8.0" TO TL-CASE
     MOVE "8.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "builtin entities: attribute lookup status ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "movement_speed" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: sodgrazer movement_speed 0.1" TO TL-CASE
     MOVE "0.1" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "step_height" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: sodgrazer step_height 1.0" TO TL-CASE
     MOVE "1.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "eye_height" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: sodgrazer eye height 0.7" TO TL-CASE
     MOVE "0.7" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "attack_damage" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: the sodgrazer never attacks (no attack_damage)" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "builtin entities: a missing attribute leaves the value blank" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 3 TO WS-ID
     MOVE "max_health" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: abend max_health 12.0" TO TL-CASE
     MOVE "12.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "movement_speed" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: abend movement_speed 0.12" TO TL-CASE
     MOVE "0.12" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "attack_damage" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: abend attack_damage 3.0" TO TL-CASE
     MOVE "3.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "follow_range" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: abend follow_range 20.0" TO TL-CASE
     MOVE "20.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "eye_height" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: abend eye height 0.5" TO TL-CASE
     MOVE "0.5" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "tracking_range" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: abend tracking range 5" TO TL-CASE
     MOVE "5" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "update_interval" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: abend update interval 3" TO TL-CASE
     MOVE "3" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 0 TO WS-ID
     MOVE "eye_height" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: operator eye height 1.62" TO TL-CASE
     MOVE "1.62" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 1 TO WS-ID
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: loose_item eye height 0.2125" TO TL-CASE
     MOVE "0.2125" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 9 TO WS-ID
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: an unknown entity has no attribute rows" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   The standard set has no attribute rows, and no set open is a defined outcome.
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 101 TO WS-ID
     MOVE "max_health" TO WS-NAME
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: the standard set has no attribute rows" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 0 TO CT-OPEN
     PERFORM ATTRIBUTE-OF
     MOVE "builtin entities: no set open, attribute" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     STOP RUN.

 ENTITY-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS.

 ATTRIBUTE-OF.
     CALL "CONTENT-ENTITY-ATTRIBUTE" USING WS-ID WS-NAME WS-VALUE WS-STATUS.

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
