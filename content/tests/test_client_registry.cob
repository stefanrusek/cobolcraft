*> Test of the client's registry load (T0208; docs/protocol/04-registry-sync.md sections 1 to 4, 23 section 4 and 6.6, world-types
*> WT-16): CONTENT-CLIENT-REGISTRY-ADD USING packet id (BINARY-LONG: 7 Registry Data, 14 Update Tags), packet
*> body (area, the bytes after the packet id), body length, status out (CT-OK; CT-BAD-DATA for a body that
*> does not decode, a Data-less entry (the client has no known packs), a repeated key, or another packet
*> id; nothing of the failed packet is kept). Registry Data entries are registered in received order (ids are
*> received indices, a registry split over packets is appended) with the network NBT bytes as payload;
*> Update Tags replaces the tag set of each registry it names, ids that do not resolve in a loaded registry
*> are dropped (6.6), those of a static registry are kept. CONTENT-CLIENT-FINISH USING world type out
*> (BINARY-LONG), status out decides the world type at Finish Configuration: any dimension_type entry keyed
*> cobolcraft:surface makes the set cobolcraft, otherwise standard (WT-16); CT-CLIENT-MISMATCH when no
*> dimension_type entry was received, CT-NOT-OPEN with nothing added. Packets are built with the proto
*> writers.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLIENT-REGISTRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-BODY                PIC X(4096).
 01 WS-BODY-LENGTH         BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(112).
 01 WS-REGISTRY-LENGTH     BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-DATA                PIC X(16).
 01 WS-DATA-LENGTH         BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 64 TIMES.
 01 WS-ID-COUNT            BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-LENGTH          BINARY-LONG.
 01 WS-TAG-REGISTRY        PIC X(48).
 01 WS-PAYLOAD             PIC X(112).
 01 WS-PAYLOAD-LENGTH      BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTRY-ID            BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-CAP-64              BINARY-LONG VALUE 64.
 01 WS-PRESENT-NONE        BINARY-LONG VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE LOW-VALUES TO WS-DATA
     MOVE FUNCTION CHAR(11) TO WS-DATA(1:1)
     MOVE 2 TO WS-DATA-LENGTH

*>   Nothing added yet: finish is CT-NOT-OPEN.
     MOVE 0 TO CT-OPEN
     CALL "CONTENT-CLOSE"
     CALL "CONTENT-CLIENT-FINISH" USING WS-TYPE WS-STATUS
     MOVE "client registry: finish with nothing added is CT-NOT-OPEN" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   Registry Data split over two packets: overworld and the_end, then the_nether.
     MOVE "minecraft:dimension_type" TO WS-REGISTRY
     MOVE 24 TO WS-REGISTRY-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 2 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:overworld" TO WS-KEY
     MOVE 19 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     MOVE "minecraft:the_end" TO WS-KEY
     MOVE 17 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     PERFORM SEND-REGISTRY
     MOVE "client registry: the first packet is ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "client registry: the first packet opens the set" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CT-OPEN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:the_nether" TO WS-KEY
     MOVE 20 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     PERFORM SEND-REGISTRY
     MOVE "client registry: the second packet appends" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "dimension_type" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "client registry: dimension_type has 3 entries" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 2 TO WS-ENTRY-ID
     PERFORM ENTRY-OF
     MOVE "client registry: id 2 is the_nether (received order)" TO TL-CASE
     MOVE "minecraft:the_nether" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "client registry: the payload is the NBT tag's 2 bytes" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-PAYLOAD-LENGTH TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "client registry: the payload starts with the compound type 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION ORD(WS-PAYLOAD(1:1)) - 1
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-ENTRY-ID
     PERFORM ENTRY-OF
     MOVE "client registry: id 0 is overworld" TO TL-CASE
     MOVE "minecraft:overworld" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   Failures keep nothing of the packet: a repeated key, Data-less entry, short or long body, another packet id.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     MOVE "minecraft:dimension_type" TO WS-REGISTRY
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:the_nether" TO WS-KEY
     MOVE 20 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     PERFORM SEND-REGISTRY
     MOVE "client registry: a key repeated across packets is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 2 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:new_a" TO WS-KEY
     MOVE 15 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     PERFORM PUT-ENTRY
     PERFORM SEND-REGISTRY
     MOVE "client registry: a key repeated in one packet is CT-BAD-DATA" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "dimension_type" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "client registry: a failed packet adds nothing (still 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:dimension_type" TO WS-REGISTRY
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:without_data" TO WS-KEY
     MOVE 22 TO WS-KEY-LENGTH
     CALL "PB-PUT-REGISTRY-ENTRY" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-PRESENT-NONE WS-DATA WS-DATA-LENGTH
     PERFORM SEND-REGISTRY
     MOVE "client registry: a Data-less entry is CT-BAD-DATA (no known packs)" TO TL-CASE
     PERFORM ASSERT-STATUS
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:cut_short" TO WS-KEY
     MOVE 19 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     PERFORM SEND-REGISTRY-SHORT
     MOVE "client registry: a body that ends inside an entry is CT-BAD-DATA" TO TL-CASE
     PERFORM ASSERT-STATUS
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:long_body" TO WS-KEY
     MOVE 19 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-PRESENT-NONE
     PERFORM SEND-REGISTRY
     MOVE "client registry: bytes after the last entry are CT-BAD-DATA" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 8 TO WS-PACKET-ID
     MOVE 1 TO WS-BODY-LENGTH
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BODY-LENGTH WS-STATUS
     MOVE "client registry: another packet id is CT-BAD-DATA" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "dimension_type" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "client registry: no failure changed dimension_type (still 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   Update Tags (6.6): static ids are kept, loaded-registry ids that do not resolve are dropped.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 2 TO WS-COUNT
     CALL "PB-PUT-TAGS-HEAD" USING PB-BUFFER WS-COUNT
     MOVE "minecraft:block" TO WS-REGISTRY
     MOVE 15 TO WS-REGISTRY-LENGTH
     MOVE 2 TO WS-COUNT
     CALL "PB-PUT-TAG-REGISTRY-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:logs" TO WS-TAG
     MOVE 14 TO WS-TAG-LENGTH
     MOVE 3 TO WS-ID-COUNT
     MOVE 51 TO WS-ID(1)
     MOVE 53 TO WS-ID(2)
     MOVE 77 TO WS-ID(3)
     CALL "PB-PUT-TAG" USING PB-BUFFER WS-TAG WS-TAG-LENGTH WS-IDS WS-ID-COUNT
     MOVE "minecraft:dirt" TO WS-TAG
     MOVE 14 TO WS-TAG-LENGTH
     MOVE 1 TO WS-ID-COUNT
     MOVE 10 TO WS-ID(1)
     CALL "PB-PUT-TAG" USING PB-BUFFER WS-TAG WS-TAG-LENGTH WS-IDS WS-ID-COUNT
     MOVE "minecraft:dimension_type" TO WS-REGISTRY
     MOVE 24 TO WS-REGISTRY-LENGTH
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-TAG-REGISTRY-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:some_dims" TO WS-TAG
     MOVE 19 TO WS-TAG-LENGTH
     MOVE 3 TO WS-ID-COUNT
     MOVE 0 TO WS-ID(1)
     MOVE 2 TO WS-ID(2)
     MOVE 7 TO WS-ID(3)
     CALL "PB-PUT-TAG" USING PB-BUFFER WS-TAG WS-TAG-LENGTH WS-IDS WS-ID-COUNT
     PERFORM SEND-TAGS
     MOVE "client registry: Update Tags is ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "block" TO WS-TAG-REGISTRY
     MOVE "minecraft:logs" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "client registry: a static registry's tag keeps its 3 ids" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-ID-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "client registry: ... in the order sent" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-ID(1) * 10000 + WS-ID(2) * 100 + WS-ID(3)
     MOVE 515377 TO TL-EXPECTED-N
     PERFORM ASSERT-NUMBER
     MOVE "dimension_type" TO WS-TAG-REGISTRY
     MOVE "minecraft:some_dims" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "client registry: id 7 of a 3-entry registry does not resolve and is dropped" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-ID-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   A later payload for the block registry replaces the earlier tag set.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-TAGS-HEAD" USING PB-BUFFER WS-COUNT
     MOVE "minecraft:block" TO WS-REGISTRY
     MOVE 15 TO WS-REGISTRY-LENGTH
     CALL "PB-PUT-TAG-REGISTRY-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:only_one" TO WS-TAG
     MOVE 18 TO WS-TAG-LENGTH
     MOVE 1 TO WS-ID-COUNT
     MOVE 1 TO WS-ID(1)
     CALL "PB-PUT-TAG" USING PB-BUFFER WS-TAG WS-TAG-LENGTH WS-IDS WS-ID-COUNT
     PERFORM SEND-TAGS
     MOVE "block" TO WS-TAG-REGISTRY
     MOVE "minecraft:logs" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "client registry: a later payload for block replaces its tags (logs is gone)" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:only_one" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "client registry: ... and the new tag is there" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "dimension_type" TO WS-TAG-REGISTRY
     MOVE "minecraft:some_dims" TO WS-TAG
     PERFORM MEMBERS-OF
     MOVE "client registry: ... while the other registry's tags stay" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-TAGS-HEAD" USING PB-BUFFER WS-COUNT
     MOVE "minecraft:block" TO WS-REGISTRY
     MOVE 15 TO WS-REGISTRY-LENGTH
     CALL "PB-PUT-TAG-REGISTRY-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     PERFORM SEND-TAGS-SHORT
     MOVE "client registry: Update Tags that ends inside a registry is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-TAGS-HEAD" USING PB-BUFFER WS-COUNT
     CALL "PB-PUT-TAG-REGISTRY-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-ZERO
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-PRESENT-NONE
     PERFORM SEND-TAGS
     MOVE "client registry: bytes after the last tag registry are CT-BAD-DATA" TO TL-CASE
     PERFORM ASSERT-STATUS

*>   Finish: the world type by the dimension_type entries (WT-16): no surface entry is standard.
     CALL "CONTENT-CLIENT-FINISH" USING WS-TYPE WS-STATUS
     MOVE "client registry: finish with vanilla dimension types is ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "client registry: ... the world type is standard" TO TL-CASE
     MOVE CT-TYPE-STANDARD TO TL-EXPECTED-N
     MOVE WS-TYPE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "client registry: ... and the set holds it" TO TL-CASE
     MOVE CT-TYPE-STANDARD TO TL-EXPECTED-N
     MOVE CT-SET-TYPE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "client registry: the standard set has the generated counts (1286 blocks)" TO TL-CASE
     MOVE 1286 TO TL-EXPECTED-N
     MOVE CT-BLOCK-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-BLOCK-ROW WS-STATUS
     MOVE "client registry: stone is block 1 after a standard finish" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "CONTENT-CLOSE"

*>   A surface entry makes the set cobolcraft, even beside vanilla entries; a split registry is read whole.
     MOVE "minecraft:dimension_type" TO WS-REGISTRY
     MOVE 24 TO WS-REGISTRY-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:overworld" TO WS-KEY
     MOVE 19 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     PERFORM SEND-REGISTRY
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 2 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "cobolcraft:surface" TO WS-KEY
     MOVE 18 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     MOVE "cobolcraft:sunless" TO WS-KEY
     PERFORM PUT-ENTRY
     PERFORM SEND-REGISTRY
     CALL "CONTENT-CLIENT-FINISH" USING WS-TYPE WS-STATUS
     MOVE "client registry: a surface entry makes the world type cobolcraft (WT-16)" TO TL-CASE
     MOVE CT-TYPE-COBOLCRAFT TO TL-EXPECTED-N
     MOVE WS-TYPE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "client registry: ... finish is ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "client registry: the cobolcraft set has its 13 blocks" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE CT-BLOCK-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "client registry: ... 19 states, 19 items, 4 entity types" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CT-STATE-COUNT * 10000 + CT-ITEM-COUNT * 100 + CT-ENTITY-COUNT
     MOVE 191904 TO TL-EXPECTED-N
     PERFORM ASSERT-NUMBER
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-BLOCK-ROW WS-STATUS
     MOVE "client registry: greystone is found after a cobolcraft finish" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "CONTENT-CLOSE"

*>   No dimension_type entry: the registry data decide no known world type.
     MOVE "minecraft:chat_type" TO WS-REGISTRY
     MOVE 19 TO WS-REGISTRY-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     MOVE "minecraft:chat" TO WS-KEY
     MOVE 14 TO WS-KEY-LENGTH
     PERFORM PUT-ENTRY
     PERFORM SEND-REGISTRY
     CALL "CONTENT-CLIENT-FINISH" USING WS-TYPE WS-STATUS
     MOVE "client registry: no dimension_type is CT-CLIENT-MISMATCH" TO TL-CASE
     MOVE CT-CLIENT-MISMATCH TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "client registry: ... and the world type out is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TYPE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "minecraft:dimension_type" TO WS-REGISTRY
     MOVE 24 TO WS-REGISTRY-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WS-COUNT
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH WS-COUNT
     PERFORM SEND-REGISTRY
     CALL "CONTENT-CLIENT-FINISH" USING WS-TYPE WS-STATUS
     MOVE "client registry: an empty dimension_type is CT-CLIENT-MISMATCH too" TO TL-CASE
     MOVE CT-CLIENT-MISMATCH TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "CONTENT-CLOSE"
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.

 PUT-ENTRY.
     MOVE 1 TO WS-PRESENT
     CALL "PB-PUT-REGISTRY-ENTRY" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-PRESENT WS-DATA WS-DATA-LENGTH.

 SEND-REGISTRY.
     MOVE 7 TO WS-PACKET-ID
     PERFORM SEND-BODY.

 SEND-TAGS.
     MOVE 14 TO WS-PACKET-ID
     PERFORM SEND-BODY.

 SEND-REGISTRY-SHORT.
     MOVE 7 TO WS-PACKET-ID
     PERFORM SEND-BODY-SHORT.

 SEND-TAGS-SHORT.
     MOVE 14 TO WS-PACKET-ID
     PERFORM SEND-BODY-SHORT.

 SEND-BODY.
     MOVE PB-LENGTH TO WS-BODY-LENGTH
     MOVE 0 TO PB-POS
     CALL "PB-GET-BYTES" USING PB-BUFFER WS-BODY WS-BODY-LENGTH
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BODY-LENGTH WS-STATUS.

*> The same bytes with the last byte left off (a body that ends too soon).
 SEND-BODY-SHORT.
     MOVE PB-LENGTH TO WS-BODY-LENGTH
     MOVE 0 TO PB-POS
     CALL "PB-GET-BYTES" USING PB-BUFFER WS-BODY WS-BODY-LENGTH
     SUBTRACT 1 FROM WS-BODY-LENGTH
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BODY-LENGTH WS-STATUS.

 ENTRY-OF.
     MOVE SPACES TO WS-KEY
     MOVE SPACES TO WS-PAYLOAD
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ENTRY-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD WS-CAP-64
         WS-PAYLOAD-LENGTH WS-STATUS.

 MEMBERS-OF.
     MOVE 64 TO WS-ID-COUNT
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-IDS WS-ID-COUNT WS-STATUS
     MOVE WS-COUNT TO WS-ID-COUNT.

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
