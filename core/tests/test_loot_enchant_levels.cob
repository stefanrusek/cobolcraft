*> Test of the loot function enchant_with_levels (26 section 7.3, 17 section 6.5; lane itemcomp3, T10602): the selection of the enchanting table with the loot context's random over the pool
*> `options` (a tag; every enchantment of the registry without it), the levels an int provider (a constant or uniform); a book becomes an enchanted book with stored enchantments, a failing
*> condition leaves the stack alone. Run through LOOT-MODIFIER on the item modifiers of core/tests/fixtures/loot over the registry of core/tests/fixtures/anvil-registry.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-ENCHANT-LEVELS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CSTACK.
 COPY LOOTCTX.
 COPY CITEMS.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot".
 01 WS-REGDIR              PIC X(1100) VALUE "core/tests/fixtures/anvil-registry".
 01 WS-STATUS              BINARY-LONG.
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ID                  BINARY-LONG.
 01 WS-SWORD               BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-EBOOK               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SHARP               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-TAGLEN              BINARY-LONG.
 01 WS-KEY64               PIC X(64).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-REGI                PIC X(48).
 01 WS-TAGKEY              PIC X(112).
 01 WS-IDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 4 TIMES.
 01 WS-N2                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SEEDN               BINARY-LONG VALUE 100.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-REGDIR WS-REG-STATUS
     CALL "TEST-STANDARD-TABLES"
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE "diamond_sword" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-SWORD
     MOVE "book" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-BOOK
     MOVE "enchanted_book" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-EBOOK
     MOVE "minecraft:sharpness" TO WS-KEY64
     MOVE 19 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-SHARP WS-MAX WS-TAG WS-TAGLEN
*>   The pool tag holds sharpness only; the sword is in the supported tag of sharpness.
     MOVE "item" TO WS-REGI
     MOVE WS-SWORD TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     MOVE "minecraft:enchantable/sharp_weapon" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     MOVE "enchantment" TO WS-REGI
     MOVE WS-SHARP TO WS-MEMBER(1)
     MOVE "minecraft:test_only_sharp" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS

     MOVE "test loot enchant_with_levels 30 levels over a pool of sharpness only gives the sword exactly one enchantment, sharpness" TO TL-CASE
     MOVE "test:m_elevels_pool" TO WS-KEY
     MOVE WS-SWORD TO WS-ITEM
     PERFORM RUN-MODIFIER
     MOVE 13 TO WS-TYPE
     CALL "SC-ENCH-COUNT" USING WS-HANDLE WS-TYPE WS-N
     CALL "SC-ENCH-LEVEL" USING WS-HANDLE WS-TYPE WS-SHARP WS-LEVEL
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N = 1 AND WS-LEVEL >= 1 AND WS-LEVEL <= 5 AND WS-ITEM = WS-SWORD
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test loot enchant_with_levels on a book gives an enchanted book with sharpness in stored_enchantments" TO TL-CASE
     MOVE "test:m_elevels_pool" TO WS-KEY
     MOVE WS-BOOK TO WS-ITEM
     PERFORM RUN-MODIFIER
     MOVE 45 TO WS-TYPE
     CALL "SC-ENCH-LEVEL" USING WS-HANDLE WS-TYPE WS-SHARP WS-LEVEL
     MOVE 13 TO WS-TYPE
     CALL "SC-ENCH-COUNT" USING WS-HANDLE WS-TYPE WS-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ITEM = WS-EBOOK AND WS-LEVEL >= 1 AND WS-N = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test loot enchant_with_levels with uniform levels 20 to 30 enchants the sword" TO TL-CASE
     MOVE "test:m_elevels_uniform" TO WS-KEY
     MOVE WS-SWORD TO WS-ITEM
     PERFORM RUN-MODIFIER
     MOVE 13 TO WS-TYPE
     CALL "SC-ENCH-COUNT" USING WS-HANDLE WS-TYPE WS-N
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test loot enchant_with_levels without options draws from every enchantment of the registry: the sword gets at least one" TO TL-CASE
     MOVE "test:m_elevels_default" TO WS-KEY
     MOVE WS-SWORD TO WS-ITEM
     PERFORM RUN-MODIFIER
     CALL "SC-ENCH-COUNT" USING WS-HANDLE WS-TYPE WS-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test loot enchant_with_levels with a failing condition leaves the stack alone" TO TL-CASE
     MOVE "test:m_elevels_cond" TO WS-KEY
     MOVE WS-SWORD TO WS-ITEM
     PERFORM RUN-MODIFIER
     CALL "SC-ENCH-COUNT" USING WS-HANDLE WS-TYPE WS-N
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 RUN-MODIFIER.
     INITIALIZE LOOT-CONTEXT
     ADD 7 TO WS-SEEDN
     MOVE WS-SEEDN TO LC-SEED
     MOVE 0 TO WS-HANDLE
     MOVE 1 TO WS-COUNT
     CALL "LOOT-MODIFIER" USING WS-KEY LOOT-CONTEXT WS-ITEM WS-COUNT WS-HANDLE WS-FOUND.

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.
 END PROGRAM TEST-LOOT-ENCHANT-LEVELS.
 COPY CORETEST.
