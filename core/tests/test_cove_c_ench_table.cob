*> Coverage of core/src/ench-table.cob over a small registry (fixtures/cove-c-registry): ENCH-COST-DEF of an entry whose primary_items is a single item key, ENCH-ITEM-N of air and of a book,
*> ENCH-SELECT at a table level below zero (m is clamped to 1, so only level 1 enchantments are offered) and ENCH-OFFER of a book over many seeds (a book offer with several entries loses one
*> and the later entries move up).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-C-ENCH-TABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/cove-c-registry".
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-SWORD               BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-KEY64               PIC X(64).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-TAGLEN              BINARY-LONG.
 01 WS-PLAIN               BINARY-LONG.
 01 WS-REGI                PIC X(48).
 01 WS-REGN                PIC X(112) VALUE "enchantment".
 01 WS-TAGKEY              PIC X(112).
 01 WS-IDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 16 TIMES.
 01 WS-REGCOUNT            BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-MINB                BINARY-LONG.
 01 WS-MINP                BINARY-LONG.
 01 WS-MAXB                BINARY-LONG.
 01 WS-MAXP                BINARY-LONG.
 01 WS-PRIMARY             PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ST                  BINARY-DOUBLE UNSIGNED.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-POOLTAG             PIC X(112) VALUE SPACES.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LIST.
    05 WS-E OCCURS 16 TIMES.
       10 WS-EID           BINARY-LONG.
       10 WS-ELV           BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-MANY                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-REG-STATUS
     MOVE "T" TO TL-MODE

     CALL "TEST-STANDARD-TABLES"
     MOVE "diamond_sword" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-SWORD
     MOVE "book" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-BOOK
     MOVE "minecraft:plain" TO WS-KEY64
     MOVE 15 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-PLAIN WS-MAX WS-TAG WS-TAGLEN
     MOVE "enchantment" TO WS-REGI
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGN WS-REGCOUNT WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-REGCOUNT
         COMPUTE WS-MEMBER(WS-I) = WS-I - 1
     END-PERFORM
     MOVE WS-REGCOUNT TO WS-N2
     MOVE "minecraft:in_enchanting_table" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS

     MOVE "cove-c cost def: an entry whose primary_items is one item key reports that key as it is, with its cost fields" TO TL-CASE
     CALL "ENCH-COST-DEF" USING WS-PLAIN WS-MINB WS-MINP WS-MAXB WS-MAXP WS-PRIMARY WS-FOUND
     MOVE WS-MINB TO WS-E1
     MOVE WS-MAXP TO WS-E2
     MOVE WS-FOUND TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-PRIMARY) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 11 1 minecraft:diamond_sword" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cove-c item n: with the standard items air has no enchantability, a book has 1, a diamond sword has more" TO TL-CASE
     CALL "ENCH-ITEM-N" USING WS-ZERO WS-N
     MOVE WS-N TO WS-E1
     CALL "ENCH-ITEM-N" USING WS-BOOK WS-N
     MOVE WS-N TO WS-E2
     CALL "ENCH-ITEM-N" USING WS-SWORD WS-N
     MOVE 0 TO WS-E3
     IF WS-N > 1
         MOVE 1 TO WS-E3
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cove-c select: a table level of -5 clamps m to 1, so a book is offered something and only at level 1" TO TL-CASE
     MOVE -5 TO WS-LEVEL
     MOVE 1 TO WS-N
     MOVE 12345 TO WS-SEED
     CALL "ENCH-STATE-SEED" USING WS-SEED WS-ST
     MOVE "minecraft:in_enchanting_table" TO WS-POOLTAG
     CALL "ENCH-SELECT" USING WS-ST WS-MODE WS-POOLTAG WS-BOOK WS-LEVEL WS-N WS-COUNT WS-LIST
     MOVE 1 TO WS-E2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF WS-ELV(WS-I) NOT = 1
             MOVE 0 TO WS-E2
         END-IF
     END-PERFORM
     MOVE 0 TO WS-E1
     IF WS-COUNT >= 1
         MOVE 1 TO WS-E1
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "some " FUNCTION TRIM(WS-E1) " all-level-1 " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "some 1 all-level-1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cove-c offer: a book over 300 seeds is always offered one to four distinct enchantments, some seeds drop an entry of several" TO TL-CASE
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-MANY
     PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 300
         MOVE 22 TO WS-N
         MOVE 25 TO WS-COST
         MOVE 2 TO WS-SLOT
         CALL "ENCH-OFFER" USING WS-SEED WS-SLOT WS-BOOK WS-N WS-COST WS-ST WS-COUNT WS-LIST
         IF WS-COUNT < 1
             ADD 1 TO WS-BAD
         END-IF
         IF WS-COUNT > 1
             ADD 1 TO WS-MANY
         END-IF
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-COUNT
             COMPUTE WS-K = WS-J + 1
             PERFORM VARYING WS-K FROM WS-K BY 1 UNTIL WS-K > WS-COUNT
                 IF WS-EID(WS-J) = WS-EID(WS-K)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-BAD TO WS-E1
     MOVE 0 TO WS-E2
     IF WS-MANY > 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "bad " FUNCTION TRIM(WS-E1) " several " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "bad 0 several 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.
 END PROGRAM TEST-COVE-C-ENCH-TABLE.
 COPY CORETEST.
