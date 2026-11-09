*> Implementation test (T0210) for the lines of content/src that the contract, acceptance and unit tests of the phase
*> leave unexecuted: property values of boolean properties (candle), ids outside a built-in or generated table,
*> attribute rows of ids outside 0 to 9, a registry table with no data-pack registries asked for an entry, a
*> registry given with its namespace, a generated directory path with no end, folders two levels below a
*> registry, an unreadable element file, a registry of more than 8192 elements (which also grows the folder
*> listing buffer past 4096 bytes), element files that grow the payload buffer past its first 64 KiB, tag
*> entries that are not identifiers (empty, over 128 bytes, no namespace colon rule, namespace and path
*> limits), more tags and tag entries than the collector holds, a full tag table, a tag with two missing
*> references, a tag failure while a set opens, a client registry head that does not decode, a 65th
*> registry, and an Update Tags registry outside the minecraft namespace. Scratch trees under
*> build/content-test/cover.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONTENT-COVER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTPROPS.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(363).
    05 WS-R-FIRST          PIC X(5).
    05 FILLER              PIC X(451).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(20).
 01 WS-TEXT                PIC X(200).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   PIC Z(5)9.
 01 WS-REGISTRY            PIC X(64).
 01 WS-REGISTRY-48         PIC X(48).
 01 WS-TAG                 PIC X(64).
 01 WS-PACK                PIC X(32) VALUE "pack".
 01 WS-JSON                PIC X(120000).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ENTRY-KEY           PIC X(64).
 01 WS-ENTRY-LENGTH        BINARY-LONG.
 01 WS-PAYLOAD             PIC X(100).
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-PAYLOAD-LENGTH      BINARY-LONG.
 01 WS-BODY                PIC X(4096).
 01 WS-BODY-LENGTH         BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-PB-CAPACITY         BINARY-LONG VALUE 4096.
 01 WS-REGISTRY-LENGTH     BINARY-LONG.
 01 WS-COUNT-OUT           BINARY-LONG.
 01 WS-DATA                PIC X(16).
 01 WS-DATA-LENGTH         BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-IDS.
    05 WS-ID-ENTRY         BINARY-LONG OCCURS 8 TIMES.
 01 WS-ID-COUNT            BINARY-LONG.
 01 WS-TAG-LENGTH          BINARY-LONG.
 01 WS-BIG                 PIC X(1100).
 01 WS-RESULT-WORD         BINARY-LONG.
 PROCEDURE DIVISION.
*>   ---- Boolean property values: candle (candles[1..4] lit[bool] waterlogged[bool]).
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "candle" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-R-FIRST)
     CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
     PERFORM PROPS-TEXT
     MOVE "cover: the first candle state" TO TL-CASE
     MOVE "candles=1,lit=true,waterlogged=true" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     ADD 7 TO WS-STATE
     CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
     PERFORM PROPS-TEXT
     MOVE "cover: candle state 7 (candles=2, lit=false, waterlogged=false)" TO TL-CASE
     MOVE "candles=2,lit=false,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   ---- Ids outside the entity tables, attribute ids outside 0 to 9.
     MOVE -1 TO WS-ID
     CALL "ENTITY-ROW-AT" USING WS-ID WS-ENTITY-ROW WS-STATUS WS-COUNT
     MOVE "cover: standard entity row -1 is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 161 TO WS-ID
     CALL "ENTITY-ROW-AT" USING WS-ID WS-ENTITY-ROW WS-STATUS WS-COUNT
     MOVE "cover: standard entity row 161 is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     MOVE -1 TO WS-ID
     CALL "ENTITY-ROW-AT" USING WS-ID WS-ENTITY-ROW WS-STATUS WS-COUNT
     MOVE "cover: built-in entity row -1 is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 4 TO WS-ID
     CALL "ENTITY-ROW-AT" USING WS-ID WS-ENTITY-ROW WS-STATUS WS-COUNT
     MOVE "cover: built-in entity row 4 is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "max_health" TO WS-NAME
     MOVE -1 TO WS-ID
     CALL "CONTENT-ENTITY-ATTRIBUTE" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "cover: attributes of entity -1 are not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 10 TO WS-ID
     CALL "CONTENT-ENTITY-ATTRIBUTE" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "cover: attributes of entity 10 are not found" TO TL-CASE
     PERFORM ASSERT-STATUS

*>   ---- A cobolcraft set has no registry table: an entry is not found.
     MOVE "dimension_type" TO WS-REGISTRY
     MOVE 0 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "cover: a set without data-pack registries has no entry" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 0 TO CT-OPEN
     CALL "CONTENT-CLOSE"

*>   ---- A generated directory path with no end (1100 bytes, no NUL, no space).
     MOVE ALL "a" TO WS-DIR
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE "cover: a directory path with no end is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   ---- Trees: a registry two folders deep, an unreadable file, a registry with a namespace on lookup.
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/cover 2>/dev/null; rm -rf build/content-test/cover; mkdir -p build/content-test/cover && cp -R content/tests/fixtures/std build/content-test/cover/deep && cp -R content/tests/fixtures/std build/content-test/cover/locked && cp -R content/tests/fixtures/std build/content-test/cover/many && cp -R content/tests/fixtures/std build/content-test/cover/big && cp -R content/tests/fixtures/std build/content-test/cover/tagfail"
     CALL "SYSTEM" USING "mkdir -p build/content-test/cover/deep/vanilla-data/data/minecraft/worldgen/biome/x/y && printf '{}' > build/content-test/cover/deep/vanilla-data/data/minecraft/worldgen/biome/x/y/z.json"
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/cover/deep" TO WS-DIR
     MOVE 1 TO CT-OPEN
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE "cover: a registry two folders deep loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "minecraft:worldgen/biome" TO WS-REGISTRY
     MOVE 5 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "cover: the entry of a registry given with its namespace" TO TL-CASE
     MOVE "minecraft:x/y/z" TO TL-EXPECTED
     MOVE WS-ENTRY-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "REGISTRY-FREE"
     CALL "SYSTEM" USING "chmod 000 build/content-test/cover/locked/vanilla-data/data/minecraft/worldgen/biome/plains.json"
     MOVE "build/content-test/cover/locked" TO WS-DIR
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE "cover: an unreadable element file is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "chmod 600 build/content-test/cover/locked/vanilla-data/data/minecraft/worldgen/biome/plains.json"

*>   ---- 8193 elements fail; the listing buffer grows on the way.
     CALL "SYSTEM" USING "cd build/content-test/cover/many/vanilla-data/data/minecraft/worldgen/biome && i=0 && while [ $i -le 8192 ]; do i=$((i+1)); printf '{}' > e$i.json; done"
     MOVE "build/content-test/cover/many" TO WS-DIR
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE "cover: more than 8192 elements in a registry is CT-BAD-DATA" TO TL-CASE
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "rm -f build/content-test/cover/many/vanilla-data/data/minecraft/worldgen/biome/e8*.json build/content-test/cover/many/vanilla-data/data/minecraft/worldgen/biome/e9*.json"
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE "cover: ... fewer elements (all but those removed) load" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "worldgen/biome" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "cover: ... in sorted order the first is minecraft:a/b" TO TL-CASE
     MOVE 0 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "minecraft:a/b" TO TL-EXPECTED
     MOVE WS-ENTRY-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "REGISTRY-FREE"

*>   ---- Two 100 KB element files grow the payload buffer past 64 KiB, twice.
     CALL "SYSTEM" USING "cd build/content-test/cover/big/vanilla-data/data/minecraft/worldgen/biome && for n in a1 a2; do { printf '{""k"":""'; head -c 100000 /dev/zero | tr '\0' x; printf '""}'; } > $n.json; done"
     MOVE "build/content-test/cover/big" TO WS-DIR
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE "cover: two 100 KB elements load" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "worldgen/biome" TO WS-REGISTRY
     MOVE 1 TO WS-ID
     MOVE 100 TO WS-CAPACITY
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-ENTRY-KEY WS-ENTRY-LENGTH WS-PAYLOAD
         WS-CAPACITY WS-PAYLOAD-LENGTH WS-STATUS
     MOVE "cover: the second 100 KB element has its length" TO TL-CASE
     MOVE 100008 TO TL-EXPECTED-N
     MOVE WS-PAYLOAD-LENGTH TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "REGISTRY-FREE"

*>   ---- A tag failure while a set opens: a required element of a loaded registry that no file defines.
     CALL "SYSTEM" USING "mkdir -p build/content-test/cover/tagfail/vanilla-data/data/minecraft/tags/worldgen/biome && printf '{""values"": [""minecraft:nope""]}' > build/content-test/cover/tagfail/vanilla-data/data/minecraft/tags/worldgen/biome/bad.json"
     MOVE "build/content-test/cover/tagfail" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "cover: a tag with an undefined required element fails the open" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   ---- Tag entries that are not identifiers, by registry block (a static registry).
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "TAGS-BEGIN"
     MOVE "block" TO WS-REGISTRY-48
     MOVE "minecraft:ids" TO WS-TAG
     MOVE '{"values": [""]}' TO WS-JSON
     PERFORM ADD-TAG
     MOVE "cover: an empty tag entry is ignored" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE ALL "a" TO WS-BIG
     MOVE SPACES TO WS-JSON
     STRING '{"values": ["' WS-BIG(1:130) '"]}' DELIMITED BY SIZE INTO WS-JSON
     PERFORM ADD-TAG
     MOVE "cover: a tag entry over 128 bytes is ignored" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-JSON
     STRING '{"values": ["' WS-BIG(1:65) '"]}' DELIMITED BY SIZE INTO WS-JSON
     PERFORM ADD-TAG
     MOVE "cover: a path of 65 bytes is ignored" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-JSON
     STRING '{"values": ["' WS-BIG(1:64) ':x"]}' DELIMITED BY SIZE INTO WS-JSON
     PERFORM ADD-TAG
     MOVE "cover: a namespace of 64 bytes is ignored" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-JSON
     STRING '{"values": ["' WS-BIG(1:40) ':' WS-BIG(1:40) '"]}' DELIMITED BY SIZE INTO WS-JSON
     PERFORM ADD-TAG
     MOVE "cover: a key of 81 bytes is ignored" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE '{"values": ["minecraft:"]}' TO WS-JSON
     PERFORM ADD-TAG
     MOVE "cover: an empty path is ignored" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE '{"values": ["..:stone"]}' TO WS-JSON
     PERFORM ADD-TAG
     MOVE "cover: the namespace .. is ignored" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE '{"values": [":stone"]}' TO WS-JSON
     PERFORM ADD-TAG
     MOVE "cover: a colon at index 0 means minecraft" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "minecraft:two_missing" TO WS-TAG
     MOVE '{"values": ["x:a", "x:b"]}' TO WS-JSON
     PERFORM ADD-TAG
     CALL "TAGS-BUILD" USING WS-REGISTRY-48 WS-STATUS
     MOVE "cover: two missing required elements still build the rest" TO TL-CASE
     PERFORM ASSERT-STATUS

*>   ---- More tag entries than the collector holds: 4 files of 4000 fit, the 5th does not.
     CALL "TAGS-BEGIN"
     MOVE SPACES TO WS-JSON
     MOVE 1 TO WS-POS
     STRING '{"values": [' DELIMITED BY SIZE INTO WS-JSON WITH POINTER WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000
         IF WS-I > 1
             STRING ',' DELIMITED BY SIZE INTO WS-JSON WITH POINTER WS-POS
         END-IF
         STRING '"stone"' DELIMITED BY SIZE INTO WS-JSON WITH POINTER WS-POS
     END-PERFORM
     STRING ']}' DELIMITED BY SIZE INTO WS-JSON WITH POINTER WS-POS
     MOVE "minecraft:big" TO WS-TAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         PERFORM ADD-TAG
     END-PERFORM
     MOVE "cover: four files of 4000 entries are collected" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     PERFORM ADD-TAG
     MOVE "cover: the fifth file passes the 16384 entries and is ignored" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   ---- More tags than the collector holds (4096), then a full tag table when building one.
     CALL "TAGS-BEGIN"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
         MOVE WS-I TO WS-N
         MOVE SPACES TO WS-TAG
         STRING "minecraft:t" FUNCTION TRIM(WS-N) DELIMITED BY SIZE INTO WS-TAG
         MOVE '{"values": []}' TO WS-JSON
         PERFORM ADD-TAG
     END-PERFORM
     MOVE "minecraft:one_more" TO WS-TAG
     PERFORM ADD-TAG
     MOVE "cover: the 4097th tag is ignored" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "TAGS-FREE"
     MOVE "fluid" TO WS-REGISTRY-48
     MOVE 0 TO WS-ID-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
         MOVE WS-I TO WS-N
         MOVE SPACES TO WS-TAG
         STRING "minecraft:f" FUNCTION TRIM(WS-N) DELIMITED BY SIZE INTO WS-TAG
         CALL "TAG-PUT" USING WS-REGISTRY-48 WS-TAG WS-ID-COUNT WS-IDS WS-STATUS
     END-PERFORM
     MOVE "cover: 4096 tags are bound" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "minecraft:extra" TO WS-TAG
     CALL "TAG-PUT" USING WS-REGISTRY-48 WS-TAG WS-ID-COUNT WS-IDS WS-STATUS
     MOVE "cover: the 4097th bound tag is CT-TOO-SMALL" TO TL-CASE
     MOVE CT-TOO-SMALL TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "TAGS-BEGIN"
     MOVE "block" TO WS-REGISTRY-48
     MOVE "minecraft:late" TO WS-TAG
     MOVE '{"values": ["minecraft:stone"]}' TO WS-JSON
     PERFORM ADD-TAG
     CALL "TAGS-BUILD" USING WS-REGISTRY-48 WS-STATUS
     MOVE "cover: building a tag into a full table is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "TAGS-FREE"
     CALL "CONTENT-CLOSE"

*>   ---- Client: a head that does not decode, a 65th registry, an Update Tags registry outside minecraft.
     CALL "PB-INIT" USING PB-BUFFER WS-PB-CAPACITY
     MOVE LOW-VALUES TO WS-DATA
     MOVE FUNCTION CHAR(11) TO WS-DATA(1:1)
     MOVE 2 TO WS-DATA-LENGTH
     MOVE 7 TO WS-PACKET-ID
     MOVE 1 TO WS-BODY-LENGTH
     MOVE FUNCTION CHAR(256) TO WS-BODY(1:1)
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BODY-LENGTH WS-STATUS
     MOVE "cover: a Registry Data head that does not decode is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 65
         MOVE WS-I TO WS-N
         MOVE SPACES TO WS-REGISTRY
         STRING "minecraft:r" FUNCTION TRIM(WS-N) DELIMITED BY SIZE INTO WS-REGISTRY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-REGISTRY)) TO WS-REGISTRY-LENGTH
         CALL "PB-RESET" USING PB-BUFFER
         MOVE 1 TO WS-COUNT-OUT
         CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT-OUT
         MOVE "minecraft:e" TO WS-ENTRY-KEY
         MOVE 11 TO WS-ENTRY-LENGTH
         MOVE 1 TO WS-PRESENT
         CALL "PB-PUT-REGISTRY-ENTRY" USING PB-BUFFER WS-ENTRY-KEY WS-ENTRY-LENGTH WS-PRESENT WS-DATA
             WS-DATA-LENGTH
         MOVE PB-LENGTH TO WS-BODY-LENGTH
         MOVE 0 TO PB-POS
         CALL "PB-GET-BYTES" USING PB-BUFFER WS-BODY WS-BODY-LENGTH
         CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BODY-LENGTH WS-STATUS
     END-PERFORM
     MOVE "cover: the 65th registry is CT-BAD-DATA" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 14 TO WS-PACKET-ID
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT-OUT
     CALL "PB-PUT-TAGS-HEAD" USING PB-BUFFER WS-COUNT-OUT
     MOVE "mymod:things" TO WS-REGISTRY
     MOVE 12 TO WS-REGISTRY-LENGTH
     CALL "PB-PUT-TAG-REGISTRY-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT-OUT
     MOVE "mymod:a_tag" TO WS-TAG
     MOVE 11 TO WS-TAG-LENGTH
     MOVE 1 TO WS-ID-COUNT
     MOVE 3 TO WS-ID-ENTRY(1)
     CALL "PB-PUT-TAG" USING PB-BUFFER WS-TAG WS-TAG-LENGTH WS-IDS WS-ID-COUNT
     MOVE PB-LENGTH TO WS-BODY-LENGTH
     MOVE 0 TO PB-POS
     CALL "PB-GET-BYTES" USING PB-BUFFER WS-BODY WS-BODY-LENGTH
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BODY-LENGTH WS-STATUS
     MOVE "cover: Update Tags for a registry outside minecraft is ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "mymod:things" TO WS-REGISTRY-48
     MOVE "mymod:a_tag" TO WS-TAG
     MOVE 3 TO WS-ID
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY-48 WS-TAG WS-ID WS-RESULT-WORD
     MOVE "cover: ... and its tag is bound under the registry as sent" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT-WORD TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "CONTENT-CLOSE"
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.

 ADD-TAG.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON TRAILING)) TO WS-LENGTH
     CALL "TAG-ADD-FILE" USING WS-REGISTRY-48 WS-TAG WS-PACK WS-JSON WS-LENGTH WS-STATUS.

 ENTRY-OF.
     MOVE 100 TO WS-CAPACITY
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-ENTRY-KEY WS-ENTRY-LENGTH WS-PAYLOAD
         WS-CAPACITY WS-PAYLOAD-LENGTH WS-STATUS.

 PROPS-TEXT.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CTP-COUNT
         IF WS-I > 1
             MOVE "," TO WS-TEXT(WS-POS:1)
             ADD 1 TO WS-POS
         END-IF
         STRING FUNCTION TRIM(CTP-NAME(WS-I)) "=" FUNCTION TRIM(CTP-VALUE(WS-I)) DELIMITED BY SIZE
             INTO WS-TEXT WITH POINTER WS-POS
     END-PERFORM
     MOVE WS-TEXT TO TL-OBSERVED.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
