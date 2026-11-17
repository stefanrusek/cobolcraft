*> Coverage of core/src/anvil.cob and core/src/menu-grind.cob: two enchanted books in the anvil (the result takes the stored_enchantments component, so equal levels of sharpness rise by one),
*> and a grindstone with only its lower slot filled by an enchanted sword (the single item comes out stripped, as when only the upper slot is filled).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-C-ANVIL-GRIND.
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
 01 WS-EBOOK               BINARY-LONG.
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
 01 WS-LITEM               BINARY-LONG.
 01 WS-LCOUNT              BINARY-LONG VALUE 1.
 01 WS-LVAR                BINARY-LONG.
 01 WS-RITEM               BINARY-LONG.
 01 WS-RCOUNT              BINARY-LONG VALUE 1.
 01 WS-RVAR                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAMELEN             BINARY-LONG VALUE 0.
 01 WS-INF                 BINARY-LONG VALUE 0.
 01 WS-OITEM               BINARY-LONG.
 01 WS-OCOUNT              BINARY-LONG.
 01 WS-OVAR                BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-UNITS               BINARY-LONG.
 01 WS-ONLY                BINARY-LONG.
 01 WS-T13                 BINARY-LONG VALUE 13.
 01 WS-T45                 BINARY-LONG VALUE 45.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-AI                  BINARY-LONG.
 01 WS-AC                  BINARY-LONG.
 01 WS-AV                  BINARY-LONG.
 01 WS-BI                  BINARY-LONG.
 01 WS-BC                  BINARY-LONG.
 01 WS-BV                  BINARY-LONG.
 01 WS-OI                  BINARY-LONG.
 01 WS-OC                  BINARY-LONG.
 01 WS-OV                  BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
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
     MOVE "enchanted_book" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-EBOOK
     MOVE "minecraft:sharpness" TO WS-KEY64
     MOVE 19 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-SHARP WS-MAX WS-TAG WS-TAGLEN
     MOVE "minecraft:smite" TO WS-KEY64
     MOVE 15 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-SMITE WS-MAX WS-TAG WS-TAGLEN
     MOVE "enchantment" TO WS-REGI
     MOVE WS-SMITE TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     MOVE "minecraft:curse" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     MOVE WS-SHARP TO WS-MEMBER(1)
     MOVE WS-SMITE TO WS-MEMBER(2)
     MOVE 2 TO WS-N2
     MOVE "minecraft:exclusive_set/damage" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS

     MOVE "cove-c anvil: two enchanted books with sharpness 2 combine into sharpness 3 in stored_enchantments for 3 levels" TO TL-CASE
     MOVE 0 TO WS-LVAR WS-RVAR
     MOVE WS-EBOOK TO WS-LITEM WS-RITEM
     MOVE SPACES TO WS-NAME
     MOVE 2 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-LVAR WS-T45 WS-SHARP WS-L1
     CALL "SC-ENCH-ADD" USING WS-RVAR WS-T45 WS-SHARP WS-L1
     CALL "ANVIL-CREATE-RESULT" USING WS-LITEM WS-LCOUNT WS-LVAR WS-RITEM WS-RCOUNT WS-RVAR WS-NAME WS-NAMELEN WS-INF
         WS-OITEM WS-OCOUNT WS-OVAR WS-COST WS-UNITS WS-ONLY
     CALL "SC-ENCH-LEVEL" USING WS-OVAR WS-T45 WS-SHARP WS-L2
     CALL "SC-ENCH-COUNT" USING WS-OVAR WS-T13 WS-N
     MOVE WS-L2 TO WS-E1
     MOVE WS-COST TO WS-E2
     MOVE WS-N TO WS-E3
     MOVE 0 TO WS-E4
     IF WS-OITEM = WS-EBOOK
         MOVE 1 TO WS-E4
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "level " FUNCTION TRIM(WS-E1) " cost " FUNCTION TRIM(WS-E2) " plain " FUNCTION TRIM(WS-E3) " ebook " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "level 3 cost 3 plain 0 ebook 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cove-c grind: only the lower slot filled with a sword holding sharpness 3 and smite 1 (a curse here) gives that sword with only the curse" TO TL-CASE
     MOVE 0 TO WS-AV WS-BV WS-AI WS-BI
     MOVE 0 TO WS-AC
     MOVE 1 TO WS-BC
     MOVE WS-SWORD TO WS-BI
     MOVE 3 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-BV WS-T13 WS-SHARP WS-L1
     MOVE 1 TO WS-L1
     CALL "SC-ENCH-ADD" USING WS-BV WS-T13 WS-SMITE WS-L1
     CALL "GRIND-RESULT" USING WS-AI WS-AC WS-AV WS-BI WS-BC WS-BV WS-OI WS-OC WS-OV
     CALL "SC-ENCH-COUNT" USING WS-OV WS-T13 WS-N
     CALL "SC-ENCH-LEVEL" USING WS-OV WS-T13 WS-SMITE WS-L2
     MOVE 0 TO WS-E1
     IF WS-OI = WS-SWORD
         MOVE 1 TO WS-E1
     END-IF
     MOVE WS-OC TO WS-E2
     MOVE WS-N TO WS-E3
     MOVE WS-L2 TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "sword " FUNCTION TRIM(WS-E1) " count " FUNCTION TRIM(WS-E2) " pairs " FUNCTION TRIM(WS-E3) " smite " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "sword 1 count 1 pairs 1 smite 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.
 END PROGRAM TEST-COVE-C-ANVIL-GRIND.
 COPY CORETEST.
