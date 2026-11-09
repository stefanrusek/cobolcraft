*> Content library records and constants (specs/002-client-polish/contracts/content-api.md section 1;
*> T0051). Contract artifact (constitution 3.3): not edited by lanes. The generated tables under
*> content/copy/gen/ are authoritative for the row views below (tools/contract_check.py compares the
*> widths); a caller reads a row only through the content accessors.

*> World types (CT-SET type, CONTENT-OPEN type parameter; PIC 9).
 78 CT-TYPE-STANDARD      VALUE 0.
 78 CT-TYPE-COBOLCRAFT    VALUE 1.
 78 CT-TYPE-DEBUG         VALUE 2.   *> the hidden debug world: opens as the standard set (data-model 1)

*> Packs status (22 section 8.2; CT-PACKS-STATUS and the OUT status of CONTENT-PACKS-CHECK).
 78 CT-PACKS-OK           VALUE 0.
 78 CT-PACKS-ABSENT       VALUE 1.
 78 CT-PACKS-INCOMPLETE   VALUE 2.
 78 CT-PACKS-STALE        VALUE 3.
 78 CT-PACKS-DAMAGED      VALUE 4.

*> Outcome words of the content entry points (BINARY-LONG status parameters).
 78 CT-OK                 VALUE 0.
 78 CT-NOT-FOUND          VALUE 1.   *> an unknown key or id: a defined outcome, never a crash
 78 CT-PACKS-NOT-OK       VALUE 2.   *> CONTENT-OPEN standard with a packs status other than ok
 78 CT-BAD-DATA           VALUE 3.   *> strict JSON, freeze or validate failed (23 section 3); errors listed
 78 CT-NOT-OPEN           VALUE 4.   *> no set is open
 78 CT-WRONG-TYPE         VALUE 5.   *> the type is not one of the CT-TYPE-* words
 78 CT-TOO-SMALL          VALUE 6.   *> an OUT area is smaller than the result
 78 CT-NO-DIMENSION       VALUE 7.   *> a standard world's dimension has no minecraft:dimension_type entry
 78 CT-CLIENT-MISMATCH    VALUE 8.   *> CONTENT-CLIENT-FINISH: the registry data decide no known world type
 78 CT-REASON-MAX         VALUE 128. *> bytes of the reason text

*> Capacities.
 78 CT-MAX-REGISTRIES     VALUE 64.  *> the 51 world registries plus the dynamic ones
 78 CT-KEY-MAX            VALUE 64.  *> bytes of a registry or entry key, with namespace
 78 CT-ROW-BYTES          VALUE 400.

*> One set per open world or connection. EXTERNAL: every program that copies this book shares the one
*> record. The registry counts are those of the set (blocks, block states, items, entity types).
 01 CT-SET EXTERNAL.
    05 CT-OPEN               PIC 9.             *> 1 = a set is open
    05 CT-SET-TYPE           PIC 9.             *> CT-TYPE-*
    05 CT-PACKS-STATUS       PIC 9.             *> CT-PACKS-*
    05 CT-GENERATED-DIR      PIC X(1024).       *> generated directory the set was opened from
    05 CT-GENERATED-LENGTH   BINARY-LONG.
    05 CT-BLOCK-COUNT        BINARY-LONG.
    05 CT-STATE-COUNT        BINARY-LONG.
    05 CT-ITEM-COUNT         BINARY-LONG.
    05 CT-ENTITY-COUNT       BINARY-LONG.
    05 CT-REGISTRY-COUNT     BINARY-LONG.
    05 CT-TAG-COUNT          BINARY-LONG.
    05 CT-REGISTRY-ADDR      USAGE POINTER.     *> table of CT-REGISTRY-COUNT CT-REGISTRY rows
    05 CT-TAG-ADDR           USAGE POINTER.     *> table of CT-TAG-COUNT CT-TAG rows

*> Fixed-width views of the generated rows. The generated tables (content/copy/gen/*.cpy, made by
*> tools/gen/gen_tables.py) are authoritative: each row is concatenated text columns of the widths of
*> that file's GEN-<TABLE>-W-<COLUMN> constants, GEN-<TABLE>-ROW-WIDTH bytes in all; the row data sit in
*> 400-character literal chunks (CT-ROW-BYTES) and row N starts at byte (N - 1) * width + 1. Every column
*> is text, left-justified and space padded (a number is its decimal text, left-justified). tools/
*> contract_check.py fails when a width here differs from the generated constants.
*> Block row (24 part 1 section 2): CT-BR-KEY with its namespace; CT-BR-PROPS the names of the block's
*> properties separated by single spaces; first state id + state count - 1 is the last.
 01 CT-BLOCK-ROW.
    05 CT-BR-ID              PIC X(4).
    05 CT-BR-KEY             PIC X(35).
    05 CT-BR-CLASS           PIC X(32).
    05 CT-BR-PROPS           PIC X(288).
    05 CT-BR-STATE-COUNT     PIC X(4).
    05 CT-BR-FIRST-STATE     PIC X(5).
    05 CT-BR-DEFAULT-STATE   PIC X(5).
    05 CT-BR-HARDNESS        PIC X(21).
    05 CT-BR-BLAST           PIC X(9).
    05 CT-BR-TOOL-REQUIRED   PIC X(3).
    05 CT-BR-LIGHT           PIC X(41).
    05 CT-BR-MAP-COLOUR      PIC X(50).
    05 CT-BR-SOUND-TYPE      PIC X(150).
    05 CT-BR-PUSH            PIC X(10).
    05 CT-BR-INSTRUMENT      PIC X(15).
    05 CT-BR-FLAGS           PIC X(147).
*> Item row (25 part 1).
 01 CT-ITEM-ROW.
    05 CT-IR-ID              PIC X(4).
    05 CT-IR-KEY             PIC X(38).
    05 CT-IR-CLASS           PIC X(24).
    05 CT-IR-BLOCK           PIC X(4).          *> block id of a block item, else empty
    05 CT-IR-STACK-SIZE      PIC X(2).
    05 CT-IR-MAX-DAMAGE      PIC X(4).
    05 CT-IR-FLAGS           PIC X(34).
    05 CT-IR-COMPONENTS      PIC X(160).        *> default components summary
*> Entity type row (21 section 2, 46 section 11); CT-ER-SIZE is the width and height text.
 01 CT-ENTITY-ROW.
    05 CT-ER-ID              PIC X(3).
    05 CT-ER-KEY             PIC X(22).
    05 CT-ER-SIZE            PIC X(15).
    05 CT-ER-CATEGORY        PIC X(26).
*> Static registry id row (46).
 01 CT-STATIC-ID-ROW.
    05 CT-SI-REGISTRY        PIC X(33).
    05 CT-SI-ID              PIC X(4).
    05 CT-SI-KEY             PIC X(53).

*> A registry (23 section 3.4): the key, and its entries in id order (CT-ENTRY table at
*> CTR-ENTRY-ADDR). Payloads are the strict-JSON or NBT bytes of the entry, kept in one buffer.
 01 CT-REGISTRY.
    05 CTR-KEY               PIC X(64).
    05 CTR-KEY-LENGTH        BINARY-LONG.
    05 CTR-ENTRY-COUNT       BINARY-LONG.
    05 CTR-ENTRY-ADDR        USAGE POINTER.     *> CTR-ENTRY-COUNT CT-ENTRY rows, id order
    05 CTR-PAYLOAD-ADDR      USAGE POINTER.     *> the payload bytes of every entry
    05 CTR-PAYLOAD-LENGTH    BINARY-LONG.
*> One entry: the id is its index in the table plus 0 (the table is in id order).
 01 CT-ENTRY.
    05 CTE-KEY               PIC X(64).
    05 CTE-KEY-LENGTH        BINARY-LONG.
    05 CTE-PAYLOAD-OFFSET    BINARY-LONG.       *> 0-based, into CTR-PAYLOAD-ADDR
    05 CTE-PAYLOAD-LENGTH    BINARY-LONG.
*> A resolved tag (23 section 6.3): the key and the member ids (BINARY-LONG table, ascending
*> order of the tag file, 23 section 6.4).
 01 CT-TAG.
    05 CTT-KEY               PIC X(64).
    05 CTT-KEY-LENGTH        BINARY-LONG.
    05 CTT-REGISTRY          PIC X(48).         *> the registry the members belong to
    05 CTT-MEMBER-COUNT      BINARY-LONG.
    05 CTT-MEMBER-ADDR       USAGE POINTER.     *> CTT-MEMBER-COUNT BINARY-LONG ids
