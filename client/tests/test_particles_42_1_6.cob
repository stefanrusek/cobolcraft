*> Acceptance test of docs/protocol/42-particles-1-shared-model-engine.md section 6 (particle definitions,
*> sprite sets and loading): the definition schema, pack stacking of the listing, redundant lists, the
*> missing-sprite rules, an empty list, unbound sets, SpriteSet get(age, lifetime), get(random), first (E3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-1-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPDEF.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-JSON                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WARNING             PIC X(512).
 01 WS-N                   BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-REG                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-LIFE                BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-REDUNDANT           BINARY-LONG.
 PROCEDURE DIVISION.
*>   6.1 schema: textures array of sprite ids; namespace added; other fields ignored.
     MOVE '{"textures":["minecraft:angry","glint"],"other":5}' TO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "PDEF-PARSE" USING WS-JSON WS-LENGTH PDEF
     MOVE "definition: two textures, no error" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 20
     COMPUTE TL-OBSERVED-N = PD-COUNT * 10 + PD-ERROR
     PERFORM ASSERT-NUMBER
     MOVE "definition: first sprite id" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "minecraft:angry" TO TL-EXPECTED
     MOVE PD-TEXTURE(1) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "definition: a sprite id without a namespace gets minecraft:" TO WS-NAME
     MOVE "minecraft:glint" TO TL-EXPECTED
     MOVE PD-TEXTURE(2) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
*>   textures absent -> empty list.
     MOVE '{"other":[1]}' TO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "PDEF-PARSE" USING WS-JSON WS-LENGTH PDEF
     MOVE "definition: textures absent gives an empty list" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PD-COUNT + PD-ERROR
     PERFORM ASSERT-NUMBER
*>   malformed file and a non-object root are hard errors.
     MOVE '{"textures":[' TO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "PDEF-PARSE" USING WS-JSON WS-LENGTH PDEF
     MOVE "definition: a malformed file is a hard error" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE PD-ERROR TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE '[1,2]' TO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "PDEF-PARSE" USING WS-JSON WS-LENGTH PDEF
     MOVE "definition: a root that is not an object is a hard error" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE PD-ERROR TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   6.2 point 2: later-pushed pack replaces an earlier one's file; a filter removes ids from earlier packs.
     MOVE 5 TO PL-COUNT
     MOVE 1 TO PL-PACK(1)
     MOVE "minecraft:heart" TO PL-ID(1)
     MOVE 0 TO PL-FILTER(1)
     MOVE 1 TO PL-PACK(2)
     MOVE "minecraft:angry_villager" TO PL-ID(2)
     MOVE 0 TO PL-FILTER(2)
     MOVE 2 TO PL-PACK(3)
     MOVE "minecraft:heart" TO PL-ID(3)
     MOVE 0 TO PL-FILTER(3)
     MOVE 3 TO PL-PACK(4)
     MOVE "minecraft:angry_villager" TO PL-ID(4)
     MOVE 1 TO PL-FILTER(4)
     MOVE 3 TO PL-PACK(5)
     MOVE "minecraft:cloud" TO PL-ID(5)
     MOVE 0 TO PL-FILTER(5)
     CALL "PDEF-LIST" USING PDEF-LISTING PDEF-MAP
     MOVE "listing: filter removes angry_villager, heart and cloud remain" TO WS-NAME
     MOVE 2 TO TL-EXPECTED-N
     MOVE PM-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "listing: the result is sorted by id (cloud first)" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "minecraft:cloud" TO TL-EXPECTED
     MOVE PM-ID(1) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "listing: heart is the later-pushed pack 2's file" TO WS-NAME
     MOVE 2 TO TL-EXPECTED-N
     MOVE PM-PACK(2) TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Redundant list: an id with no sprite registration is skipped; ambient_entity_effect matches none.
     MOVE "minecraft:ambient_entity_effect" TO WS-ID
     CALL "PDEF-REGISTERED" USING WS-ID WS-REG
     MOVE "registration: ambient_entity_effect has none (redundant texture list)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-REG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:heart" TO WS-ID
     CALL "PDEF-REGISTERED" USING WS-ID WS-REG
     MOVE "registration: heart is sprite-registered" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-REG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:block" TO WS-ID
     CALL "PDEF-REGISTERED" USING WS-ID WS-REG
     MOVE "registration: block is a plain provider, no sprite registration" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-REG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   6.2 point 3: resolve against the atlas; missing -> the missing sprite (index 0) and a sorted warning.
     MOVE 3 TO PA-COUNT
     MOVE "minecraft:a" TO PA-ID(1)
     MOVE "minecraft:b" TO PA-ID(2)
     MOVE "minecraft:c" TO PA-ID(3)
     MOVE 4 TO PD-COUNT
     MOVE "minecraft:c" TO PD-TEXTURE(1)
     MOVE "minecraft:zzz" TO PD-TEXTURE(2)
     MOVE "minecraft:a" TO PD-TEXTURE(3)
     MOVE "minecraft:mmm" TO PD-TEXTURE(4)
     CALL "PDEF-RESOLVE" USING PDEF PDEF-ATLAS PSET WS-WARNING
     MOVE "resolve: sprites c, missing, a, missing -> 3, 0, 1, 0" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 4 * 10000 + 3 * 1000 + 0 * 100 + 1 * 10 + 0
     COMPUTE TL-OBSERVED-N = PS-COUNT * 10000 + PS-SPRITE(1) * 1000 + PS-SPRITE(2) * 100
         + PS-SPRITE(3) * 10 + PS-SPRITE(4)
     PERFORM ASSERT-NUMBER
     MOVE "resolve: the set is bound" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE PS-BOUND TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "resolve: one sorted warning for the missing ids" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "Missing particle sprites: minecraft:mmm, minecraft:zzz" TO TL-EXPECTED
     MOVE WS-WARNING TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 1 TO PD-COUNT
     MOVE "minecraft:b" TO PD-TEXTURE(1)
     CALL "PDEF-RESOLVE" USING PDEF PDEF-ATLAS PSET WS-WARNING
     MOVE "resolve: no missing sprite gives no warning" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-WARNING TO TL-OBSERVED
     PERFORM ASSERT-TEXT
*>   An empty list becomes the single missing sprite.
     MOVE 0 TO PD-COUNT
     CALL "PDEF-RESOLVE" USING PDEF PDEF-ATLAS PSET WS-WARNING
     MOVE "resolve: an empty list becomes one missing sprite" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1 * 10 + 0
     COMPUTE TL-OBSERVED-N = PS-COUNT * 10 + PS-SPRITE(1)
     PERFORM ASSERT-NUMBER
     MOVE "resolve: the empty-list substitution adds no warning" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-WARNING TO TL-OBSERVED
     PERFORM ASSERT-TEXT
*>   6.2 point 4: a type with no definition keeps an unbound set.
     CALL "PSET-UNBOUND" USING PSET
     MOVE "unbound set: never bound, no sprites" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PS-BOUND + PS-COUNT
     PERFORM ASSERT-NUMBER
*>   6.3 / E3: sprite by age; random and first.
     MOVE 8 TO WS-N
     MOVE 20 TO WS-LIFE
     MOVE 10 TO WS-AGE
     CALL "PCL-SPRITE-INDEX" USING WS-AGE WS-LIFE WS-N WS-INDEX
     MOVE "E3: 8 sprites, lifetime 20, age 10 gives index 3" TO WS-NAME
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 20 TO WS-AGE
     CALL "PCL-SPRITE-INDEX" USING WS-AGE WS-LIFE WS-N WS-INDEX
     MOVE "E3: age 20 gives index 7" TO WS-NAME
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-AGE
     CALL "PCL-SPRITE-INDEX" USING WS-AGE WS-LIFE WS-N WS-INDEX
     MOVE "E3: age 0 gives index 0" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 16 TO WS-N
     MOVE 6 TO WS-LIFE
     MOVE 3 TO WS-AGE
     CALL "PCL-SPRITE-INDEX" USING WS-AGE WS-LIFE WS-N WS-INDEX
     MOVE "E3: 16 sprites, lifetime 6, age 3 gives 3 * 15 / 6 = 7 (integer division)" TO WS-NAME
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-N
     MOVE 5 TO WS-AGE
     CALL "PCL-SPRITE-INDEX" USING WS-AGE WS-LIFE WS-N WS-INDEX
     MOVE "one sprite: always index 0" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 5 TO WS-N
     MOVE 0.65 TO WS-DRAW
     CALL "PSET-RANDOM" USING WS-N WS-DRAW WS-INDEX
     MOVE "get(random): nextInt(5) from a draw of 0.65 is 3" TO WS-NAME
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-N
     CALL "PSET-RANDOM" USING WS-N WS-DRAW WS-INDEX
     MOVE "get(random) with one sprite is index 0 (still one draw)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 2 TO PS-COUNT
     MOVE 9 TO PS-SPRITE(1)
     MOVE 8 TO PS-SPRITE(2)
     CALL "PSET-FIRST" USING PSET WS-INDEX
     MOVE "first() is the sprite at index 0 (here atlas index 9)" TO WS-NAME
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "heart" TO WS-ID
     CALL "PDEF-REGISTERED" USING WS-ID WS-REG
     MOVE "registration: a name without namespace is accepted" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-REG TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 5 TO WS-N
     MOVE 1.0 TO WS-DRAW
     CALL "PSET-RANDOM" USING WS-N WS-DRAW WS-INDEX
     MOVE "get(random) never passes n - 1 (draw 1.0 gives 4)" TO WS-NAME
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-1§6 Particle definitions, sprite sets and loading: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-1§6 Particle definitions, sprite sets and loading: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-1-6.
