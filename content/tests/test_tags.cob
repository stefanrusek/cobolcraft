*> Test of tag loading and resolution (T0198; docs/protocol/23-registry-loading.md section 6, worked examples 6.7).
*> TAGS-BEGIN (no parameters) forgets the collected tag files. TAG-ADD-FILE USING registry (PIC X(48)), tag key
*> (PIC X(64)), pack name (PIC X(32), for messages), text area, length, status adds one pack's tag file in
*> pack order, lowest priority first (6.2, 6.3 step A): CT-OK, or CT-BAD-DATA when the file is ignored (the
*> one place a bad data file is not fatal, 6.3); a file that fails to parse leaves no trace, one that
*> fails to decode leaves the tag existing with what the other packs gave it. TAGS-BUILD USING registry,
*> status resolves the collected tags of that registry (steps B to D) and binds them to the set: CT-OK, or
*> CT-BAD-DATA when a tag of a registry loaded from data names an element that no file defines (the freeze
*> error of 6.3); a tag with a missing required reference is not built. TAG-PUT USING registry, tag key,
*> count, ids (table of BINARY-LONG), status binds one resolved tag (the network form of 6.6 and the built-in
*> layer). CONTENT-TAG-HAS USING registry, tag key, entry id, result (1 member, else 0);
*> CONTENT-TAG-MEMBERS USING registry, tag key, count out, ids out (table), capacity, status. TAGS-FREE
*> releases the bound tags. Static registry elements are looked up in the set's tables (here block).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TAGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-REGISTRY            PIC X(48).
 01 WS-TAG                 PIC X(64).
 01 WS-PACK                PIC X(32).
 01 WS-JSON                PIC X(1500).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 64 TIMES.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-LOOKUP-STATUS       BINARY-LONG.
 01 WS-EXPECTED            PIC X(200).
 01 WS-OBSERVED            PIC X(200).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NUM                 PIC Z(4)9.
 01 WS-DIR                 PIC X(1100).
 PROCEDURE DIVISION.
*>   No set open.
     MOVE 0 TO CT-OPEN
     MOVE "block" TO WS-REGISTRY
     MOVE "minecraft:logs" TO WS-TAG
     MOVE 5 TO WS-ID(1)
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-ID(1) WS-RESULT
     MOVE "tags: no set open, has is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 64 TO WS-CAPACITY
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     MOVE "tags: no set open, members" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "REGISTRY-FREE"

*>   Example 1 of 6.7: base logs and birch_logs, a user logs with an optional missing element.
     CALL "TAGS-BEGIN"
     MOVE "base" TO WS-PACK
     MOVE "minecraft:logs" TO WS-TAG
     MOVE '{"values": ["minecraft:oak_log", "#minecraft:birch_logs", "minecraft:acacia_log"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:birch_logs" TO WS-TAG
     MOVE '{"values": ["minecraft:birch_log", "minecraft:birch_wood"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "user" TO WS-PACK
     MOVE "minecraft:logs" TO WS-TAG
     MOVE '{"values": ["minecraft:oak_log", {"id": "x:cherry_log", "required": false}, "minecraft:dark_oak_log"]}'
         TO WS-JSON
     PERFORM ADD-FILE
     MOVE "tags: a valid file is ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     PERFORM BUILD-BLOCK
     MOVE "tags: example 1 builds" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:logs" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "oak_log" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "birch_log" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "birch_wood" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "acacia_log" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "dark_oak_log" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: example 1 logs in order, duplicate dropped, optional skipped" TO TL-CASE
     PERFORM ASSERT-MEMBERS
     MOVE "tags: example 1 members count 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:birch_logs" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "birch_log" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "birch_wood" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: example 1 birch_logs" TO TL-CASE
     PERFORM ASSERT-MEMBERS
     MOVE "minecraft:logs" TO WS-TAG
     MOVE "dark_oak_log" TO WS-KEY
     PERFORM HAS-KEY
     MOVE "tags: has of the last member of logs" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "stone" TO WS-KEY
     PERFORM HAS-KEY
     MOVE "tags: has of a block not in logs" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "logs" TO WS-TAG
     MOVE "oak_log" TO WS-KEY
     PERFORM HAS-KEY
     MOVE "tags: the namespace of a tag key is optional" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:block" TO WS-REGISTRY
     MOVE "minecraft:logs" TO WS-TAG
     MOVE "oak_log" TO WS-KEY
     PERFORM HAS-KEY
     MOVE "tags: the namespace of a registry is optional" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "item" TO WS-REGISTRY
     MOVE "oak_log" TO WS-KEY
     PERFORM HAS-KEY
     MOVE "tags: a tag of block is not a tag of item" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "block" TO WS-REGISTRY
     MOVE 2 TO WS-CAPACITY
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     MOVE "tags: a capacity of 2 is too small for logs" TO TL-CASE
     MOVE CT-TOO-SMALL TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "tags: ... and the count is given" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:no_such_tag" TO WS-TAG
     MOVE 64 TO WS-CAPACITY
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     MOVE "tags: an unknown tag is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "tags: an unknown tag has 0 members" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "oak_log" TO WS-KEY
     PERFORM HAS-KEY
     MOVE "tags: has of an unknown tag is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   Example 2: the user file replaces what the base gave (birch_logs is still built).
     CALL "TAGS-FREE"
     CALL "TAGS-BEGIN"
     MOVE "base" TO WS-PACK
     MOVE "minecraft:logs" TO WS-TAG
     MOVE '{"values": ["minecraft:oak_log", "#minecraft:birch_logs", "minecraft:acacia_log"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:birch_logs" TO WS-TAG
     MOVE '{"values": ["minecraft:birch_log", "minecraft:birch_wood"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "user" TO WS-PACK
     MOVE "minecraft:logs" TO WS-TAG
     MOVE '{"replace": true, "values": ["minecraft:oak_log", {"id": "x:cherry_log", "required": false}, "minecraft:dark_oak_log"]}'
         TO WS-JSON
     PERFORM ADD-FILE
     PERFORM BUILD-BLOCK
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "oak_log" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "dark_oak_log" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: example 2 replace keeps only the user's entries" TO TL-CASE
     PERFORM ASSERT-MEMBERS
     MOVE "minecraft:birch_logs" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "tags: example 2 birch_logs is still built" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   Example 3: a required missing element: the tag is not built, and a tag that requires it is not built either.
     CALL "TAGS-FREE"
     CALL "TAGS-BEGIN"
     MOVE "base" TO WS-PACK
     MOVE "minecraft:logs" TO WS-TAG
     MOVE '{"values": ["minecraft:oak_log", "#minecraft:birch_logs", "minecraft:acacia_log"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:birch_logs" TO WS-TAG
     MOVE '{"values": ["minecraft:birch_log", "minecraft:birch_wood"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "user" TO WS-PACK
     MOVE "minecraft:logs" TO WS-TAG
     MOVE '{"values": ["minecraft:oak_log", "x:cherry_log", "minecraft:dark_oak_log"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:consumer" TO WS-TAG
     MOVE '{"values": ["#minecraft:logs"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:optional_consumer" TO WS-TAG
     MOVE '{"values": ["minecraft:stone", {"id": "#minecraft:logs", "required": false}]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM BUILD-BLOCK
     MOVE "tags: example 3 builds (a static registry's failure is only logged)" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:logs" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "tags: example 3 logs is not built" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:consumer" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "tags: example 3 a tag requiring logs is not built either" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:birch_logs" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "tags: example 3 birch_logs is built" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:optional_consumer" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "stone" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: an optional reference to a missing tag is skipped" TO TL-CASE
     PERFORM ASSERT-MEMBERS

*>   Example 4 and cycles (6.5).
     CALL "TAGS-FREE"
     CALL "TAGS-BEGIN"
     MOVE "base" TO WS-PACK
     MOVE "minecraft:logs" TO WS-TAG
     MOVE '{"values": ["minecraft:oak_log", "#minecraft:logs"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:ra" TO WS-TAG
     MOVE '{"values": ["minecraft:stone", "#minecraft:rb"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:rb" TO WS-TAG
     MOVE '{"values": ["minecraft:dirt", "#minecraft:ra"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:ma" TO WS-TAG
     MOVE '{"values": ["minecraft:sand", "#minecraft:mb"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:mb" TO WS-TAG
     MOVE '{"values": ["minecraft:gravel", {"id": "#minecraft:ma", "required": false}]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:mc" TO WS-TAG
     MOVE '{"values": ["minecraft:gravel", {"id": "#minecraft:md", "required": false}]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:md" TO WS-TAG
     MOVE '{"values": ["minecraft:sand", "#minecraft:mc"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:oa" TO WS-TAG
     MOVE '{"values": ["minecraft:stone", {"id": "#minecraft:ob", "required": false}]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:ob" TO WS-TAG
     MOVE '{"values": ["minecraft:dirt"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:oc" TO WS-TAG
     MOVE '{"values": [{"id": "#minecraft:fails", "required": false}, "minecraft:stone"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:fails" TO WS-TAG
     MOVE '{"values": ["x:nope"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:rn" TO WS-TAG
     MOVE '{"values": ["#minecraft:ghost"]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM BUILD-BLOCK
     MOVE "minecraft:logs" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "tags: example 4 a tag naming itself is missing" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:ra" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE WS-STATUS TO WS-I
     MOVE "minecraft:rb" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "tags: a cycle of required references: at least one tag is missing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-I = CT-NOT-FOUND OR WS-STATUS = CT-NOT-FOUND
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-NUMBER
*>   A mixed cycle: the optional edge is dropped from the order, both tags are built (6.5), mb first.
     MOVE "minecraft:ma" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "sand" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "gravel" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: a mixed cycle builds ma with mb inside" TO TL-CASE
     PERFORM ASSERT-MEMBERS
     MOVE "minecraft:mb" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "gravel" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: a mixed cycle builds mb without the optional ma" TO TL-CASE
     PERFORM ASSERT-MEMBERS

*>   mc names md optionally and md names mc: the optional edge is dropped even when mc is built first.
     MOVE "minecraft:mc" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "gravel" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: a mixed cycle built from the optional side: mc has no md" TO TL-CASE
     PERFORM ASSERT-MEMBERS
     MOVE "minecraft:md" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "sand" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "gravel" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: ... and md holds sand and mc's gravel" TO TL-CASE
     PERFORM ASSERT-MEMBERS
     MOVE "minecraft:oa" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "stone" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "dirt" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: an optional tag reference to a tag not yet built is built first" TO TL-CASE
     PERFORM ASSERT-MEMBERS
     MOVE "minecraft:oc" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "stone" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: an optional reference to a tag that failed is skipped" TO TL-CASE
     PERFORM ASSERT-MEMBERS
     MOVE "minecraft:rn" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "tags: a required reference to a tag nobody defines is missing" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   Files that fail: a syntax error leaves no trace, a decode failure leaves the tag existing and empty.
     CALL "TAGS-FREE"
     CALL "TAGS-BEGIN"
     MOVE "base" TO WS-PACK
     MOVE "minecraft:syntax" TO WS-TAG
     MOVE '{"values": ["minecraft:stone",]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "tags: a syntax error is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:novalues" TO WS-TAG
     MOVE '{"replace": false}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "tags: a file without values is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:notarray" TO WS-TAG
     MOVE '{"values": "minecraft:stone"}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:notobject" TO WS-TAG
     MOVE '[1, 2]' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:badreplace" TO WS-TAG
     MOVE '{"replace": 1, "values": ["minecraft:stone"]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:badentry" TO WS-TAG
     MOVE '{"values": ["minecraft:stone", 5]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:noid" TO WS-TAG
     MOVE '{"values": [{"required": false}]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:idnotstring" TO WS-TAG
     MOVE '{"values": [{"id": 3}]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:badrequired" TO WS-TAG
     MOVE '{"values": [{"id": "minecraft:stone", "required": "no"}]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:badid" TO WS-TAG
     MOVE '{"values": ["Minecraft:Stone"]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:hashonly" TO WS-TAG
     MOVE '{"values": ["#"]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:twohash" TO WS-TAG
     MOVE '{"values": ["##minecraft:x"]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:longid" TO WS-TAG
     MOVE '{"values": ["minecraft:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]}'
         TO WS-JSON
     PERFORM ADD-FILE
     PERFORM EXPECT-BAD
     MOVE "minecraft:withbad" TO WS-TAG
     MOVE '{"values": ["minecraft:stone"]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "user" TO WS-PACK
     MOVE '{"values": ["minecraft:dirt", 7]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM BUILD-BLOCK
     MOVE "minecraft:syntax" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "tags: a file that does not parse leaves no tag" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:novalues" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "tags: a file that does not decode leaves an empty tag" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "tags: ... with 0 members" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:withbad" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "stone" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: a failed later file adds nothing to the earlier pack's entries" TO TL-CASE
     PERFORM ASSERT-MEMBERS

*>   Entries by tag object, an element named without a namespace, a nested tag declared after its user.
     CALL "TAGS-FREE"
     CALL "TAGS-BEGIN"
     MOVE "base" TO WS-PACK
     MOVE "minecraft:outer" TO WS-TAG
     MOVE '{"values": ["stone", {"id": "#minecraft:inner"}, {"id": "minecraft:sand", "required": true}]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:inner" TO WS-TAG
     MOVE '{"values": ["minecraft:dirt", "minecraft:stone"]}' TO WS-JSON
     PERFORM ADD-FILE
     PERFORM BUILD-BLOCK
     MOVE "minecraft:outer" TO WS-TAG
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POS
     MOVE "stone" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "dirt" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "sand" TO WS-KEY
     PERFORM EXPECT-ADD
     MOVE "tags: nested tag contents sit at the #tag's place, first occurrence wins" TO TL-CASE
     PERFORM ASSERT-MEMBERS

*>   A registry loaded from data: a required element that no file defines is a freeze error (6.3).
     CALL "TAGS-FREE"
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/tags 2>/dev/null; rm -rf build/content-test/tags; mkdir -p build/content-test/tags && cp -R content/tests/fixtures/std build/content-test/tags/t"
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/tags/t" TO WS-DIR
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE "tags: the fixture registries load" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "TAGS-BEGIN"
     MOVE "worldgen/biome" TO WS-REGISTRY
     MOVE "base" TO WS-PACK
     MOVE "minecraft:is_good" TO WS-TAG
     MOVE '{"values": ["minecraft:plains", "mymod:beach", {"id": "minecraft:nope", "required": false}]}' TO WS-JSON
     PERFORM ADD-FILE
     MOVE "minecraft:is_better" TO WS-TAG
     MOVE '{"values": ["#minecraft:is_good", "minecraft:desert"]}' TO WS-JSON
     PERFORM ADD-FILE
     CALL "TAGS-BUILD" USING WS-REGISTRY WS-STATUS
     MOVE "tags: a loaded registry builds from its entries" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 64 TO WS-CAPACITY
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     MOVE "tags: is_better holds plains 4, beach 2, desert 3 (ids by the registry's order)" TO TL-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-ID(WS-I) TO WS-NUM
         IF WS-I > 1
             MOVE "," TO WS-OBSERVED(WS-POS:1)
             ADD 1 TO WS-POS
         END-IF
         STRING FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-POS
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "4,2,3" TO TL-EXPECTED
     MOVE WS-OBSERVED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TAGS-BEGIN"
     MOVE "minecraft:is_bad" TO WS-TAG
     MOVE '{"values": ["minecraft:plains", "minecraft:nope"]}' TO WS-JSON
     PERFORM ADD-FILE
     CALL "TAGS-BUILD" USING WS-REGISTRY WS-STATUS
     MOVE "tags: a required element that no file defines is a freeze error" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "REGISTRY-FREE"
     CALL "TAGS-FREE"

*>   TAG-PUT: bind a resolved tag, replace it, ask for a member; an empty tag.
     MOVE "item" TO WS-REGISTRY
     MOVE "minecraft:picks" TO WS-TAG
     MOVE 3 TO WS-COUNT
     MOVE 10 TO WS-ID(1)
     MOVE 20 TO WS-ID(2)
     MOVE 30 TO WS-ID(3)
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "tags: put binds a tag" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 20 TO WS-ID(1)
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-ID(1) WS-RESULT
     MOVE "tags: put tag has 20" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-COUNT
     MOVE 40 TO WS-ID(1)
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE 20 TO WS-ID(1)
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-ID(1) WS-RESULT
     MOVE "tags: a second put replaces the tag (20 is gone)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 40 TO WS-ID(1)
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-ID(1) WS-RESULT
     MOVE "tags: ... and 40 is in" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-COUNT
     MOVE "minecraft:empty" TO WS-TAG
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE 64 TO WS-CAPACITY
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     MOVE "tags: an empty tag is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "TAGS-FREE"
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     MOVE "tags: after a free no tag is found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ADD-FILE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON TRAILING)) TO WS-LENGTH
     CALL "TAG-ADD-FILE" USING WS-REGISTRY WS-TAG WS-PACK WS-JSON WS-LENGTH WS-STATUS.

 BUILD-BLOCK.
     MOVE "block" TO WS-REGISTRY
     CALL "TAGS-BUILD" USING WS-REGISTRY WS-STATUS.

 MEMBERS-OF.
     MOVE 64 TO WS-CAPACITY
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS.

 EXPECT-BAD.
     MOVE SPACES TO TL-CASE
     STRING "tags: a decode failure is CT-BAD-DATA (" FUNCTION TRIM(WS-TAG) ")" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 EXPECT-ADD.
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-BLOCK-ROW WS-LOOKUP-STATUS
     MOVE WS-BLOCK-ID TO WS-NUM
     IF WS-POS > 1
         MOVE "," TO WS-EXPECTED(WS-POS:1)
         ADD 1 TO WS-POS
     END-IF
     STRING FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE INTO WS-EXPECTED WITH POINTER WS-POS.

 HAS-KEY.
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-BLOCK-ROW WS-LOOKUP-STATUS
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK-ID WS-RESULT.

 ASSERT-MEMBERS.
     PERFORM MEMBERS-OF
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-ID(WS-I) TO WS-NUM
         IF WS-I > 1
             MOVE "," TO WS-OBSERVED(WS-POS:1)
             ADD 1 TO WS-POS
         END-IF
         STRING FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-POS
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE WS-OBSERVED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
