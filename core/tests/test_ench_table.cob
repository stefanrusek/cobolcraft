*> Test of the enchanting table's rules (core/src/ench-table.cob; docs/protocol/17 section 6.5, 40-4 section 2.4 and 2.5; lane itemcomp3, T10600): ENCH-COST-DEF (cost fields, the primary items
*> of an entry that has them and the supported tag of one that has not), ENCH-ENCHANTABILITY, ENCH-SELECT through ENCH-OFFER over a pool of six enchantments (the lists are the ones of an
*> independent port of the algorithm: java.util.Random, float arithmetic, weights, exclusive sets, the book that loses an entry) and ENCH-SHELVES over a small world.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENCH-TABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/anvil-registry".
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-SWORD               BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-KEY64               PIC X(64).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-TAGLEN              BINARY-LONG.
 01 WS-ENCH.
    05 WS-EN               BINARY-LONG OCCURS 6 TIMES.
 01 WS-NAMES.
    05 FILLER              PIC X(12) VALUE "sharpness".
    05 FILLER              PIC X(12) VALUE "smite".
    05 FILLER              PIC X(12) VALUE "efficiency".
    05 FILLER              PIC X(12) VALUE "knockback".
    05 FILLER              PIC X(12) VALUE "looting".
    05 FILLER              PIC X(12) VALUE "unbreaking".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(12) OCCURS 6 TIMES.
 01 WS-REGI                PIC X(48).
 01 WS-TAGKEY              PIC X(112).
 01 WS-IDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 8 TIMES.
 01 WS-N2                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MINB                BINARY-LONG.
 01 WS-MINP                BINARY-LONG.
 01 WS-MAXB                BINARY-LONG.
 01 WS-MAXP                BINARY-LONG.
 01 WS-PRIMARY             PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ST                  BINARY-DOUBLE UNSIGNED.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LIST.
    05 WS-E OCCURS 16 TIMES.
       10 WS-EID           BINARY-LONG.
       10 WS-ELV           BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-TEXT                PIC X(160).
 01 WS-LEV                BINARY-LONG.
 01 WS-PTR                BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-TMP                 PIC X(160).
 01 WS-LV                  PIC 9.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-BAD                 BINARY-LONG VALUE 999.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-REG-STATUS
     CALL "TEST-STANDARD-TABLES"
     MOVE "T" TO TL-MODE
     MOVE "diamond_sword" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-SWORD
     MOVE "iron_pickaxe" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-PICK
     MOVE "book" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-BOOK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-KEY64
         STRING "minecraft:" FUNCTION TRIM(WS-NAME(WS-I)) DELIMITED BY SIZE INTO WS-KEY64
         COMPUTE WS-KEYLEN = 10 + FUNCTION LENGTH(FUNCTION TRIM(WS-NAME(WS-I)))
         CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-EN(WS-I) WS-MAX WS-TAG WS-TAGLEN
     END-PERFORM

*>   The tags the fixture rows name and the pool of the table.
     MOVE "item" TO WS-REGI
     MOVE WS-SWORD TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     MOVE "minecraft:enchantable/sharp_weapon" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     MOVE "minecraft:enchantable/melee_weapon" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     MOVE "minecraft:enchantable/weapon" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     MOVE WS-PICK TO WS-MEMBER(2)
     MOVE 2 TO WS-N2
     MOVE "minecraft:enchantable/durability" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     MOVE WS-PICK TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     MOVE "minecraft:enchantable/mining" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     MOVE "enchantment" TO WS-REGI
     MOVE WS-EN(1) TO WS-MEMBER(1)
     MOVE WS-EN(2) TO WS-MEMBER(2)
     MOVE 2 TO WS-N2
     MOVE "minecraft:exclusive_set/damage" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-EN(WS-I) TO WS-MEMBER(WS-I)
     END-PERFORM
     MOVE 6 TO WS-N2
     MOVE "minecraft:in_enchanting_table" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS

     MOVE "test ench table cost fields: sharpness costs 1 + 11 per level and 21 + 11, its primary items are its supported tag; looting has its own primary items; an unknown id is not found" TO TL-CASE
     CALL "ENCH-COST-DEF" USING WS-EN(1) WS-MINB WS-MINP WS-MAXB WS-MAXP WS-PRIMARY WS-FOUND
     MOVE WS-MINB TO WS-E1
     MOVE WS-MINP TO WS-E2
     MOVE WS-MAXB TO WS-E3
     MOVE WS-MAXP TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-PRIMARY) " "
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "ENCH-COST-DEF" USING WS-EN(5) WS-MINB WS-MINP WS-MAXB WS-MAXP WS-PRIMARY WS-FOUND
     MOVE WS-MINB TO WS-E1
     MOVE WS-MAXB TO WS-E3
     MOVE WS-FOUND TO WS-E5
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-PRIMARY) " " FUNCTION TRIM(WS-E5) " "
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "ENCH-COST-DEF" USING WS-BAD WS-MINB WS-MINP WS-MAXB WS-MAXP WS-PRIMARY WS-FOUND
     MOVE WS-FOUND TO WS-E5
     MOVE WS-MINB TO WS-E1
     STRING FUNCTION TRIM(WS-E5) FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "1 11 21 11 minecraft:enchantable/sharp_weapon 15 65 minecraft:enchantable/melee_weapon 1 00" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ench table enchantability: a sword and a book are enchantable (a book 1), a sword that has an enchantment is not, dirt is not, an unknown item is not" TO TL-CASE
     MOVE 0 TO WS-HANDLE
     CALL "ENCH-ENCHANTABILITY" USING WS-SWORD WS-HANDLE WS-N WS-OK
     MOVE WS-N TO WS-E1
     MOVE WS-OK TO WS-E2
     CALL "ENCH-ENCHANTABILITY" USING WS-BOOK WS-HANDLE WS-N WS-OK
     MOVE WS-N TO WS-E3
     MOVE WS-OK TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) "/" FUNCTION TRIM(WS-E4) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 1 TO WS-LEV
     MOVE 13 TO WS-J
     CALL "SC-ENCH-ADD" USING WS-HANDLE WS-J WS-EN(1) WS-LEV
     CALL "ENCH-ENCHANTABILITY" USING WS-SWORD WS-HANDLE WS-N WS-OK
     MOVE WS-OK TO WS-E1
     MOVE "dirt" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE 0 TO WS-HANDLE
     CALL "ENCH-ENCHANTABILITY" USING WS-ID WS-HANDLE WS-N WS-OK
     MOVE WS-OK TO WS-E2
     CALL "ENCH-ENCHANTABILITY" USING WS-BAD WS-HANDLE WS-N WS-OK
     MOVE WS-OK TO WS-E3
     STRING FUNCTION TRIM(WS-E1) FUNCTION TRIM(WS-E2) FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "10/1 1/1 000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ench table offers, a sword: seed 12345 slot 2 cost 30 gives unbreaking 3, sharpness 4, looting 3; seed -1234567 slot 0 cost 5 gives unbreaking 2" TO TL-CASE
     MOVE WS-SWORD TO WS-ITEM
     MOVE 14 TO WS-N
     MOVE 12345 TO WS-SEED
     MOVE 2 TO WS-SLOT
     MOVE 30 TO WS-COST
     PERFORM OFFER
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE -1234567 TO WS-SEED
     MOVE 0 TO WS-SLOT
     MOVE 5 TO WS-COST
     PERFORM OFFER
     PERFORM APPEND
     MOVE "unbreaking:3 sharpness:4 looting:3 | unbreaking:2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ench table offers, exclusive sets and primary items: seed 777 slot 1 cost 20 gives knockback 2, smite 2; seed 5 slot 0 cost 2 gives knockback 1, sharpness 1" TO TL-CASE
     MOVE 777 TO WS-SEED
     MOVE 1 TO WS-SLOT
     MOVE 20 TO WS-COST
     MOVE 10 TO WS-N
     PERFORM OFFER
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 5 TO WS-SEED
     MOVE 0 TO WS-SLOT
     MOVE 2 TO WS-COST
     MOVE 14 TO WS-N
     PERFORM OFFER
     PERFORM APPEND
     MOVE "knockback:2 smite:2 | knockback:1 sharpness:1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ench table offers, a pickaxe: seed 2147483647 slot 2 cost 30 gives efficiency 3, unbreaking 3 (the sword enchantments are not offered)" TO TL-CASE
     MOVE WS-PICK TO WS-ITEM
     MOVE 2147483647 TO WS-SEED
     MOVE 2 TO WS-SLOT
     MOVE 30 TO WS-COST
     MOVE 14 TO WS-N
     PERFORM OFFER
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "efficiency:3 unbreaking:3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ench table offers, a book offers any enchantment and loses one entry when it has several: seed 99 slot 2 cost 30 gives unbreaking 3; seed 31337 slot 1 cost 15 gives smite 2" TO TL-CASE
     MOVE WS-BOOK TO WS-ITEM
     MOVE 99 TO WS-SEED
     MOVE 2 TO WS-SLOT
     MOVE 30 TO WS-COST
     MOVE 1 TO WS-N
     PERFORM OFFER
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 31337 TO WS-SEED
     MOVE 1 TO WS-SLOT
     MOVE 15 TO WS-COST
     MOVE 22 TO WS-N
     PERFORM OFFER
     PERFORM APPEND
     MOVE "unbreaking:3 | smite:2" TO TL-EXPECTED
     PERFORM CHECK

     STOP RUN.

*> The offer of option WS-SLOT for the item WS-ITEM: WS-TEXT "name:level ...".
 OFFER.
     CALL "ENCH-OFFER" USING WS-SEED WS-SLOT WS-ITEM WS-N WS-COST WS-ST WS-COUNT WS-LIST
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-OP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             IF WS-EID(WS-I) = WS-EN(WS-J)
                 MOVE WS-ELV(WS-I) TO WS-LV
                 IF WS-I > 1
                     STRING " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-OP
                 END-IF
                 STRING FUNCTION TRIM(WS-NAME(WS-J)) ":" WS-LV DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-OP
             END-IF
         END-PERFORM
     END-PERFORM.

 APPEND.
     MOVE SPACES TO WS-TMP
     STRING FUNCTION TRIM(TL-OBSERVED) " | " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-TMP
     MOVE WS-TMP TO TL-OBSERVED.

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENCH-TABLE.
 COPY CORETEST.
