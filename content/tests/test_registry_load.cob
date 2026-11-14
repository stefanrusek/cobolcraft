*> Test of the registry loader (T0196; docs/protocol/23-registry-loading.md sections 1, 3 and 2.1, 04 section 3.2). REGISTRY-LOAD-ALL
*> USING generated directory (PIC X(1100), z-string or space padded), status out (CT-OK, or CT-BAD-DATA
*> with every error printed on standard error as "ERROR registry: ..."): loads the 51 world registries from
*> <dir>/vanilla-data/data/<namespace>/<registry path>/**/*.json: strict JSON (23 3.2), entry ids in the order
*> of the element id, path first and then namespace (23 3.4, 1), the 13 non-empty validators (23 2.1),
*> identifier rules (23 1). CONTENT-REGISTRY-COUNT USING registry (PIC X(112)), count out, status;
*> CONTENT-REGISTRY-ENTRY USING registry, id, key out (PIC X(112)), key length out, payload area (any size),
*> capacity, payload length out, status. REGISTRY-FREE releases everything. Trees: build/content-test/reg, a
*> copy of content/tests/fixtures/std (the contract's valid tree plus the 13 variant registries and
*> elements in several namespaces) altered per case.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REGISTRY-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(112).
 01 WS-COUNT               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAYLOAD             PIC X(2000).
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COMMAND             PIC X(300).
 01 WS-T                   PIC X(60).
 01 WS-COUNT-TEXT          PIC 9(4).
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/reg/t" TO WS-DIR

*>   No set open: the entry points answer CT-NOT-OPEN.
     MOVE 0 TO CT-OPEN
     MOVE "dimension_type" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "registry: no set open, count" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 0 TO WS-ID
     MOVE 2000 TO WS-CAPACITY
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD WS-CAPACITY
         WS-LENGTH WS-STATUS
     MOVE "registry: no set open, entry" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 1 TO CT-OPEN

*>   The standard fixture loads; ids follow the sorted order of the element ids.
     PERFORM FRESH-TREE
     PERFORM LOAD-TREE
     MOVE "registry: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "dimension_type" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: dimension_type has 3 entries" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM ASSERT-COUNT
     MOVE "minecraft:dimension_type" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: the namespace of the registry is optional" TO TL-CASE
     PERFORM ASSERT-COUNT
     MOVE "dimension_type" TO WS-REGISTRY
     MOVE 0 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: dimension_type id 0 is overworld" TO TL-CASE
     MOVE "minecraft:overworld" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "registry: the key length is that of minecraft:overworld" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE WS-KEY-LENGTH TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "registry: the payload is the 487 bytes of the file" TO TL-CASE
     MOVE 487 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "registry: the payload starts with the file's text" TO TL-CASE
     MOVE "{" TO TL-EXPECTED
     MOVE WS-PAYLOAD(1:1) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "registry: the payload holds the file's own fields" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     INSPECT WS-PAYLOAD(1:487) TALLYING TL-OBSERVED-N FOR ALL """min_y"": -64"
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: dimension_type id 1 is the_end" TO TL-CASE
     MOVE "minecraft:the_end" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 2 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: dimension_type id 2 is the_nether" TO TL-CASE
     MOVE "minecraft:the_nether" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   23 3.4 example 1: path first, nested paths by their slash, the namespace last.
     MOVE "worldgen/biome" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: worldgen/biome has 5 entries" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ASSERT-COUNT
     MOVE 0 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: biome id 0 is minecraft:a/b" TO TL-CASE
     MOVE "minecraft:a/b" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 1 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: biome id 1 is minecraft:badlands" TO TL-CASE
     MOVE "minecraft:badlands" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 2 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: biome id 2 is mymod:beach (path beach sorts before desert)" TO TL-CASE
     MOVE "mymod:beach" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 3 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: biome id 3 is minecraft:desert" TO TL-CASE
     MOVE "minecraft:desert" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 4 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: biome id 4 is minecraft:plains" TO TL-CASE
     MOVE "minecraft:plains" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   23 3.4 example 2: equal paths in namespace order.
     MOVE "chat_type" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: chat_type has 4 entries" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     PERFORM ASSERT-COUNT
     MOVE 0 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: chat_type id 0 is alpha:apple" TO TL-CASE
     MOVE "alpha:apple" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 1 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: chat_type id 1 is minecraft:apple" TO TL-CASE
     MOVE "minecraft:apple" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 2 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: chat_type id 2 is zeta:apple" TO TL-CASE
     MOVE "zeta:apple" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 3 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: chat_type id 3 is minecraft:chat" TO TL-CASE
     MOVE "minecraft:chat" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   A registry without files is empty, not unknown; unknown names and ids are defined outcomes.
     MOVE "enchantment" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: a registry without files has 0 entries" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-COUNT
     MOVE "registry: ... and is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "no_such_registry" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: an unknown registry is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "registry: an unknown registry has count 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-COUNT
     MOVE 0 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: an entry of an unknown registry is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "dimension_type" TO WS-REGISTRY
     MOVE 3 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: id 3 of dimension_type is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE -1 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "registry: id -1 is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 0 TO WS-ID
     MOVE 100 TO WS-CAPACITY
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD WS-CAPACITY
         WS-LENGTH WS-STATUS
     MOVE "registry: a payload area that is too small is CT-TOO-SMALL" TO TL-CASE
     MOVE CT-TOO-SMALL TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "registry: ... and the payload length is still given" TO TL-CASE
     MOVE 487 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "REGISTRY-FREE"
     MOVE "dimension_type" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: after a free no registry is found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   A tree that is not there, and the data failures: each is CT-BAD-DATA.
     MOVE "build/content-test/reg/no-such-tree" TO WS-DIR
     PERFORM LOAD-TREE
     MOVE "registry: a tree with no vanilla-data fails the non-empty validators" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "build/content-test/reg/t" TO WS-DIR
     MOVE "bad JSON: a trailing comma" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""a"": 1,}' > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/bad.json"
     PERFORM LOAD-FAILS
     PERFORM FRESH-TREE
     MOVE "bad JSON: a comment" TO WS-T
     CALL "SYSTEM" USING "printf '{} // c' > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/bad.json"
     PERFORM LOAD-FAILS
     PERFORM FRESH-TREE
     MOVE "bad JSON: an empty file" TO WS-T
     CALL "SYSTEM" USING ": > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/bad.json"
     PERFORM LOAD-FAILS
     PERFORM FRESH-TREE
     MOVE "bad JSON: a repeated member name" TO WS-T
     CALL "SYSTEM" USING "printf '{""a"":1,""a"":2}' > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/bad.json"
     PERFORM LOAD-FAILS
     PERFORM FRESH-TREE
     MOVE "bad id: an upper case letter in the path" TO WS-T
     CALL "SYSTEM" USING "printf '{}' > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/Bad.json"
     PERFORM LOAD-FAILS
     PERFORM FRESH-TREE
     MOVE "bad id: an upper case letter in a nested directory" TO WS-T
     CALL "SYSTEM" USING "mkdir build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/Dir && printf '{}' > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/Dir/x.json"
     PERFORM LOAD-FAILS
     PERFORM FRESH-TREE
     MOVE "bad id: an upper case letter in the namespace" TO WS-T
     CALL "SYSTEM" USING "mkdir -p build/content-test/reg/t/vanilla-data/data/Bad/worldgen/biome && printf '{}' > build/content-test/reg/t/vanilla-data/data/Bad/worldgen/biome/x.json"
     PERFORM LOAD-FAILS
     PERFORM FRESH-TREE
     MOVE "bad id: a key over 112 bytes" TO WS-T
     CALL "SYSTEM" USING "f=$(printf 'a%.0s' $(seq 1 120)); printf '{}' > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/$f.json"
     PERFORM LOAD-FAILS
     PERFORM FRESH-TREE
     MOVE "a key of 100 bytes (real keys: 88, 112)" TO WS-T
     CALL "SYSTEM" USING "f=$(printf 'a%.0s' $(seq 1 100)); printf '{}' > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/$f.json"
     PERFORM LOAD-TREE
     MOVE "registry: a key of 100 bytes loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "worldgen/biome" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: ... the biome count includes it" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     PERFORM ASSERT-COUNT
     CALL "REGISTRY-FREE"
     PERFORM FRESH-TREE
     MOVE "a validator: wolf_variant is empty" TO WS-T
     CALL "SYSTEM" USING "rm build/content-test/reg/t/vanilla-data/data/minecraft/wolf_variant/test.json"
     PERFORM LOAD-FAILS
     PERFORM FRESH-TREE
     MOVE "a validator: painting_variant, the last of the 13, is empty" TO WS-T
     CALL "SYSTEM" USING "rm build/content-test/reg/t/vanilla-data/data/minecraft/painting_variant/test.json"
     PERFORM LOAD-FAILS

*>   Things that are not elements are left alone.
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf 'text' > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/readme.txt && printf '{}' > build/content-test/reg/t/vanilla-data/data/minecraft/worldgen/biome/.json.bak"
     PERFORM LOAD-TREE
     MOVE "registry: files without the .json extension are not elements" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "worldgen/biome" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: ... the biome count is unchanged" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ASSERT-COUNT
     CALL "REGISTRY-FREE"

*>   A file of the data directory that is not a namespace directory, and a file of the same name as a registry.
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf 'x' > build/content-test/reg/t/vanilla-data/data/stray.txt && printf 'x' > build/content-test/reg/t/vanilla-data/data/minecraft/enchantment"
     PERFORM LOAD-TREE
     MOVE "registry: a stray file in data and a file named like a registry are skipped" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "REGISTRY-FREE"

*>   A second load replaces the first (no leak, same answers).
     PERFORM FRESH-TREE
     PERFORM LOAD-TREE
     PERFORM LOAD-TREE
     MOVE "registry: loading again replaces the registries" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "chat_type" TO WS-REGISTRY
     PERFORM COUNT-OF
     MOVE "registry: ... and chat_type still has 4 entries" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     PERFORM ASSERT-COUNT
     CALL "REGISTRY-FREE"
     STOP RUN.

 FRESH-TREE.
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/reg 2>/dev/null; rm -rf build/content-test/reg; mkdir -p build/content-test/reg && cp -R content/tests/fixtures/std build/content-test/reg/t".

 LOAD-TREE.
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS.

 LOAD-FAILS.
     PERFORM LOAD-TREE
     MOVE SPACES TO TL-CASE
     STRING "registry: " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "REGISTRY-FREE".

 COUNT-OF.
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS.

 ENTRY-OF.
     MOVE 2000 TO WS-CAPACITY
     MOVE SPACES TO WS-KEY
     MOVE 0 TO WS-LENGTH
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD WS-CAPACITY
         WS-LENGTH WS-STATUS.

 ASSERT-COUNT.
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
