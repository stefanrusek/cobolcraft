*> Test of the enchantments a villager's trade result carries (docs/protocol/54 section 4.1 and 4.3; lane itemcomp, T9610): VIL-ROW-STACK draws the enchantment of a modifier-1 trade (an enchanted book)
*> once, so the extra price and the stored_enchantments of the result agree: the level is 1 to the enchantment's max level and the extra price is E of VIL-ENCH-PICK; rows without that modifier
*> have no patch. The result of an offer is handed to the merchant menu in MN-RESULT-VAR.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VIL-STACKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CSTACK.
 COPY CONTENT.
 COPY COREAPI.
 COPY VILSTATE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/itemcomp-registry".
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-WANT                PIC X(32).
 01 WS-EXT                 PIC X(32).
 01 WS-GIVE                PIC X(32).
 01 WS-WC                  BINARY-LONG.
 01 WS-EC                  BINARY-LONG.
 01 WS-GC                  BINARY-LONG.
 01 WS-MU                  BINARY-LONG.
 01 WS-XPV                 BINARY-LONG.
 01 WS-MULT                BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-MOD                 BINARY-LONG.
 01 WS-BOOK-ROW            BINARY-LONG.
 01 WS-GEAR-ROW            BINARY-LONG.
 01 WS-PLAIN-ROW           BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SALT                BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-T45                 BINARY-LONG VALUE 45.
 01 WS-T13                 BINARY-LONG VALUE 13.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-GOOD                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NTH                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 8.5.
 01 WS-X2                  FLOAT-LONG VALUE 8.5.
 01 WS-X3                  FLOAT-LONG VALUE 8.5.
 01 WS-X4                  FLOAT-LONG VALUE 0.
 01 WS-X5                  FLOAT-LONG VALUE 0.
 01 WS-X6                  FLOAT-LONG VALUE 0.
 01 WS-KEY112              PIC X(112).
 01 WS-ROWTXT              PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGI                PIC X(48).
 01 WS-TAGKEY              PIC X(112).
 01 WS-TIDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 2 TIMES.
 01 WS-N2                  BINARY-LONG.
 01 WS-UNB                 BINARY-LONG.
 01 WS-MAXL                BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-TAGLEN              BINARY-LONG.
 01 WS-KEY64               PIC X(64).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-REG-STATUS
     CALL "TEST-STANDARD-TABLES"
     MOVE 0 TO WS-BOOK-ROW WS-GEAR-ROW WS-PLAIN-ROW
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 397
         CALL "VIL-TRADE-ROW" USING WS-J WS-WANT WS-WC WS-EXT WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
         EVALUATE WS-MOD
             WHEN 1
                 IF WS-BOOK-ROW = 0
                     MOVE WS-J TO WS-BOOK-ROW
                 END-IF
             WHEN 2
                 IF WS-GEAR-ROW = 0
                     MOVE WS-J TO WS-GEAR-ROW
                 END-IF
             WHEN OTHER
                 IF WS-PLAIN-ROW = 0
                     MOVE WS-J TO WS-PLAIN-ROW
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE "N" TO TL-MODE

     MOVE "test vil stacks 300 draws of a book trade: the stored enchantment has a level of 1 or more, one pair, and the extra price is 5 to 142" TO TL-CASE
     MOVE 0 TO WS-GOOD WS-BAD WS-FOUND
     PERFORM VARYING WS-SALT FROM 1 BY 1 UNTIL WS-SALT > 300
         MOVE 0 TO WS-HANDLE
         CALL "VIL-ROW-STACK" USING WS-BOOK-ROW WS-SALT WS-EXTRA WS-HANDLE
         IF WS-EXTRA < 5 OR WS-EXTRA > 142
             ADD 1 TO WS-BAD
         END-IF
         IF WS-HANDLE > 0
             ADD 1 TO WS-FOUND
             CALL "SC-ENCH-COUNT" USING WS-HANDLE WS-T45 WS-N
             CALL "SC-ENCH-COUNT" USING WS-HANDLE WS-T13 WS-A
             MOVE 1 TO WS-NTH
             CALL "SC-ENCH-NTH" USING WS-HANDLE WS-T45 WS-NTH WS-ID WS-LEVEL
             IF WS-N NOT = 1 OR WS-A NOT = 0 OR WS-LEVEL < 1 OR WS-LEVEL > 5
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test vil stacks some of the 300 draws land on an enchantment the registry knows and carry it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test vil stacks an equipment trade and a plain trade have no patch, the same extra price as VIL-ROW-EXTRA's range" TO TL-CASE
     MOVE 0 TO WS-HANDLE
     MOVE 7 TO WS-SALT
     CALL "VIL-ROW-STACK" USING WS-GEAR-ROW WS-SALT WS-EXTRA WS-HANDLE
     MOVE WS-HANDLE TO WS-E1
     MOVE WS-EXTRA TO WS-E2
     MOVE 0 TO WS-HANDLE
     CALL "VIL-ROW-STACK" USING WS-PLAIN-ROW WS-SALT WS-EXTRA WS-HANDLE
     MOVE WS-HANDLE TO WS-E3
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     IF WS-EXTRA = 0 AND WS-E1 = "         0" AND WS-E3 = "         0"
         MOVE "ok" TO TL-OBSERVED
     ELSE
         MOVE "bad" TO TL-OBSERVED
     END-IF
     MOVE "ok" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test vil stacks the sweep keeps the result of an offer and the patch of an item on the ground" TO TL-CASE
     MOVE 0 TO WS-HANDLE
     MOVE 5 TO WS-ID
     MOVE 2 TO WS-LEVEL
     CALL "SC-ENCH-ADD" USING WS-HANDLE WS-T45 WS-ID WS-LEVEL
     INITIALIZE VL-ENTRY(1)
     MOVE 77 TO VL-ID(1)
     MOVE 1 TO VL-O-N(1)
     MOVE WS-HANDLE TO VL-O-VAR(1, 1)
     MOVE 0 TO WS-A
     MOVE 6 TO WS-ID
     CALL "SC-ENCH-ADD" USING WS-A WS-T45 WS-ID WS-LEVEL
     MOVE 1 TO WS-DIM
     MOVE 1 TO WS-ITEM
     MOVE 1 TO WS-COUNT
     MOVE 0 TO WS-DELAY
     CALL "GI-SPAWN-X" USING WS-DIM WS-X WS-X2 WS-X3 WS-X4 WS-X5 WS-X6 WS-ITEM WS-COUNT WS-DELAY WS-J WS-A
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 512
         IF WS-J NOT = WS-HANDLE AND WS-J NOT = WS-A
             MOVE 0 TO SP-LIVE(WS-J)
         END-IF
     END-PERFORM
     CALL "SP-SWEEP"
     MOVE SPACES TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE SP-LIVE(WS-HANDLE) TO WS-E1
     MOVE SP-LIVE(WS-A) TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An equipment trade: the pool on_traded_equipment holds unbreaking, whose supported items (durability) hold the traded item; V is 5 to 19.
     CALL "VIL-TRADE-ROW" USING WS-GEAR-ROW WS-WANT WS-WC WS-EXT WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
     MOVE SPACES TO WS-KEY112
     STRING "minecraft:" FUNCTION TRIM(WS-GIVE) DELIMITED BY SIZE INTO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ID WS-ROWTXT WS-STATUS
     MOVE "item" TO WS-REGI
     MOVE WS-ID TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     MOVE "minecraft:enchantable/durability" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     MOVE "minecraft:unbreaking" TO WS-KEY64
     MOVE 20 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-UNB WS-MAXL WS-TAG WS-TAGLEN
     MOVE "enchantment" TO WS-REGI
     MOVE WS-UNB TO WS-MEMBER(1)
     MOVE "minecraft:on_traded_equipment" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     MOVE "test vil stacks 100 draws of an equipment trade: V is 5 to 19 so the extra price is V, the result carries unbreaking of level 1 to 3 in enchantments (13) alone" TO TL-CASE
     MOVE 0 TO WS-GOOD WS-BAD
     PERFORM VARYING WS-SALT FROM 1 BY 1 UNTIL WS-SALT > 100
         MOVE 0 TO WS-HANDLE
         CALL "VIL-ROW-STACK" USING WS-GEAR-ROW WS-SALT WS-EXTRA WS-HANDLE
         CALL "SC-ENCH-COUNT" USING WS-HANDLE WS-T13 WS-N
         CALL "SC-ENCH-LEVEL" USING WS-HANDLE WS-T13 WS-UNB WS-LEVEL
         IF WS-EXTRA < 5 OR WS-EXTRA > 19 OR WS-N NOT = 1 OR WS-LEVEL < 1 OR WS-LEVEL > 3
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-VIL-STACKS.
 COPY CORETEST.
