*> Test of the grindstone engine over live stacks (core/src/menu-grind.cob; docs/protocol/40-menus-3 section 4.3 and 4.4; lane itemcomp3, T10604): GRIND-RESULT (an item without
*> enchantments gives nothing, removeNonCurses keeps the curses and sets the repair cost, an enchanted book that loses everything becomes a book, mergeItems of two damaged tools with its 5 percent
*> bonus and max_damage, mergeEnchants with curses moving only when the result lacks them, unequal items, stacks above 1, two stackable plain items, two books) and GRIND-XP-TOTAL (the minimum costs of the
*> enchantments that are not curses).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GRIND.
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
 01 WS-EBOOK               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-SHARP               BINARY-LONG.
 01 WS-SMITE               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-TAGLEN              BINARY-LONG.
 01 WS-KEY64               PIC X(64).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-REGI                PIC X(48).
 01 WS-TAGKEY              PIC X(112).
 01 WS-IDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 2 TIMES.
 01 WS-N2                  BINARY-LONG.
 01 WS-AI                  BINARY-LONG.
 01 WS-AC                  BINARY-LONG VALUE 1.
 01 WS-AV                  BINARY-LONG.
 01 WS-BI                  BINARY-LONG.
 01 WS-BC                  BINARY-LONG VALUE 1.
 01 WS-BV                  BINARY-LONG.
 01 WS-OI                  BINARY-LONG.
 01 WS-OC                  BINARY-LONG.
 01 WS-OV                  BINARY-LONG.
 01 WS-T13                 BINARY-LONG VALUE 13.
 01 WS-T45                 BINARY-LONG VALUE 45.
 01 WS-T19                 BINARY-LONG VALUE 19.
 01 WS-T2                  BINARY-LONG VALUE 2.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-DMG                 BINARY-LONG.
 01 WS-MD                  BINARY-LONG.
 01 WS-VALUE               PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
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
     MOVE "enchanted_book" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-EBOOK
     MOVE "dirt" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-DIRT
     MOVE "minecraft:sharpness" TO WS-KEY64
     MOVE 19 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-SHARP WS-MAX WS-TAG WS-TAGLEN
     MOVE "minecraft:smite" TO WS-KEY64
     MOVE 15 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-SMITE WS-MAX WS-TAG WS-TAGLEN
*>   Smite stands in for a curse.
     MOVE "enchantment" TO WS-REGI
     MOVE WS-SMITE TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     MOVE "minecraft:curse" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS

     MOVE "test grind an item without enchantments gives nothing (a damaged single item too); an enchanted single sword keeps only its curse and has repair cost 1" TO TL-CASE
     PERFORM FRESH
     MOVE WS-PICK TO WS-AI
     MOVE 100 TO WS-DMG
     CALL "SP-SET-DAMAGE" USING WS-AV WS-DMG
     MOVE 0 TO WS-BI WS-BC
     PERFORM DO-GRIND
     MOVE WS-OC TO WS-E1
     PERFORM FRESH
     MOVE WS-SWORD TO WS-AI
     MOVE 3 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-AV WS-T13 WS-SHARP WS-L1
     MOVE 1 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-AV WS-T13 WS-SMITE WS-L1
     MOVE 0 TO WS-BI WS-BC
     PERFORM DO-GRIND
     CALL "SC-ENCH-COUNT" USING WS-OV WS-T13 WS-N
     CALL "SC-ENCH-LEVEL" USING WS-OV WS-T13 WS-SMITE WS-L2
     PERFORM READ-RC
     MOVE WS-OC TO WS-E2
     MOVE WS-N TO WS-E3
     MOVE WS-L2 TO WS-E4
     MOVE WS-RC TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "plain " FUNCTION TRIM(WS-E1) " ench count " FUNCTION TRIM(WS-E2) " pairs " FUNCTION TRIM(WS-E3) " smite " FUNCTION TRIM(WS-E4) " rc " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "plain 0 ench count 1 pairs 1 smite 1 rc 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test grind an enchanted book with sharpness alone becomes a book with no stored enchantments and no repair cost" TO TL-CASE
     PERFORM FRESH
     MOVE WS-EBOOK TO WS-AI
     MOVE 2 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-AV WS-T45 WS-SHARP WS-L1
     MOVE 0 TO WS-BI WS-BC
     PERFORM DO-GRIND
     CALL "SC-ENCH-COUNT" USING WS-OV WS-T45 WS-N
     PERFORM READ-RC
     MOVE WS-OI TO WS-E1
     MOVE WS-BOOK TO WS-E2
     MOVE WS-N TO WS-E3
     MOVE WS-RC TO WS-E4
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING "item " FUNCTION TRIM(WS-E1) " stored " FUNCTION TRIM(WS-E3) " rc " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     STRING "item " FUNCTION TRIM(WS-E2) " stored 0 rc 0" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test grind two iron pickaxes of damage 200 and 220 (max 250): remaining 50 + 30 + 12 gives damage 158 and max_damage 250, one item" TO TL-CASE
     PERFORM FRESH
     MOVE WS-PICK TO WS-AI WS-BI
     MOVE 200 TO WS-DMG
     CALL "SP-SET-DAMAGE" USING WS-AV WS-DMG
     MOVE 220 TO WS-DMG
     CALL "SP-SET-DAMAGE" USING WS-BV WS-DMG
     PERFORM DO-GRIND
     CALL "SP-GET-DAMAGE" USING WS-OI WS-OV WS-DMG
     CALL "SP-GET-MAX-DAMAGE" USING WS-OI WS-OV WS-MD
     MOVE WS-OC TO WS-E1
     MOVE WS-DMG TO WS-E2
     MOVE WS-MD TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "count " FUNCTION TRIM(WS-E1) " damage " FUNCTION TRIM(WS-E2) " max " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "count 1 damage 158 max 250" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test grind merge enchantments: sharpness 2 with sharpness 3 and smite 1 (a curse) gives smite 1 only (sharpness removed, the curse moved because the result lacked it), repair cost 1" TO TL-CASE
     PERFORM FRESH
     MOVE WS-SWORD TO WS-AI WS-BI
     MOVE 2 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-AV WS-T13 WS-SHARP WS-L1
     MOVE 3 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-BV WS-T13 WS-SHARP WS-L1
     MOVE 1 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-BV WS-T13 WS-SMITE WS-L1
     PERFORM DO-GRIND
     CALL "SC-ENCH-COUNT" USING WS-OV WS-T13 WS-N
     CALL "SC-ENCH-LEVEL" USING WS-OV WS-T13 WS-SMITE WS-L2
     PERFORM READ-RC
     MOVE WS-OC TO WS-E1
     MOVE WS-N TO WS-E2
     MOVE WS-L2 TO WS-E3
     MOVE WS-RC TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "count " FUNCTION TRIM(WS-E1) " pairs " FUNCTION TRIM(WS-E2) " smite " FUNCTION TRIM(WS-E3) " rc " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "count 1 pairs 1 smite 1 rc 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test grind refusals: unequal items, a stack of 2, two enchanted books (stack size 1) give nothing; two dirt (stackable, equal) give a stack of 2" TO TL-CASE
     PERFORM FRESH
     MOVE WS-SWORD TO WS-AI
     MOVE WS-PICK TO WS-BI
     PERFORM DO-GRIND
     MOVE WS-OC TO WS-E1
     PERFORM FRESH
     MOVE WS-SWORD TO WS-AI WS-BI
     MOVE 2 TO WS-AC
     PERFORM DO-GRIND
     MOVE WS-OC TO WS-E2
     PERFORM FRESH
     MOVE WS-EBOOK TO WS-AI WS-BI
     PERFORM DO-GRIND
     MOVE WS-OC TO WS-E3
     PERFORM FRESH
     MOVE WS-DIRT TO WS-AI WS-BI
     PERFORM DO-GRIND
     MOVE WS-OC TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0 0 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test grind experience: sharpness 3 (minimum cost 23) and smite 1 (a curse, not counted) and an enchanted book with sharpness 2 (minimum cost 12) give a total of 35" TO TL-CASE
     PERFORM FRESH
     MOVE WS-SWORD TO WS-AI
     MOVE 3 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-AV WS-T13 WS-SHARP WS-L1
     MOVE 1 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-AV WS-T13 WS-SMITE WS-L1
     MOVE WS-EBOOK TO WS-BI
     MOVE 2 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-BV WS-T45 WS-SHARP WS-L1
     CALL "GRIND-XP-TOTAL" USING WS-AI WS-AV WS-BI WS-BV WS-TOTAL
     MOVE WS-TOTAL TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "35" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 FRESH.
     MOVE 0 TO WS-AV WS-BV WS-AI WS-BI
     MOVE 1 TO WS-AC WS-BC.

 DO-GRIND.
     CALL "GRIND-RESULT" USING WS-AI WS-AC WS-AV WS-BI WS-BC WS-BV WS-OI WS-OC WS-OV.

*> The repair cost component (19) of the result, 0 when absent.
 READ-RC.
     MOVE 0 TO WS-RC
     CALL "SP-GET-COMPONENT" USING WS-OV WS-T19 WS-VALUE WS-LEN WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-RC
     END-IF.

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-GRIND.
 COPY CORETEST.
