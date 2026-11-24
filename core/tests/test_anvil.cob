*> Test of the anvil engine over live stacks (core/src/anvil.cob, ench-def.cob; docs/protocol/40-menus-3 section 3.3; lane itemcomp2, T10102): the material repair (units, cost, new repair cost), the
*> durability merge of two tools, an enchanted book combined into a sword (level up, cost by anvil_cost, book halves it), incompatible enchantments (early exit D), a rename and its removal,
*> the too-expensive limit with and without infinite materials, and the early exits A, B and C.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ANVIL.
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
 01 WS-PICK                BINARY-LONG.
 01 WS-SWORD               BINARY-LONG.
 01 WS-INGOT               BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-SHARP               BINARY-LONG.
 01 WS-SMITE               BINARY-LONG.
 01 WS-KEY64               PIC X(64).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-TAGLEN              BINARY-LONG.
 01 WS-LITEM               BINARY-LONG.
 01 WS-LCOUNT              BINARY-LONG VALUE 1.
 01 WS-LVAR                BINARY-LONG.
 01 WS-RITEM               BINARY-LONG.
 01 WS-RCOUNT              BINARY-LONG VALUE 1.
 01 WS-RVAR                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAMELEN             BINARY-LONG.
 01 WS-INF                 BINARY-LONG.
 01 WS-OITEM               BINARY-LONG.
 01 WS-OCOUNT              BINARY-LONG.
 01 WS-OVAR                BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-UNITS               BINARY-LONG.
 01 WS-ONLY                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-REGI                PIC X(48).
 01 WS-TAGKEY              PIC X(112).
 01 WS-IDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 4 TIMES.
 01 WS-N2                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-CLEN                BINARY-LONG.
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
     MOVE "iron_pickaxe" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-PICK
     MOVE "diamond_sword" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-SWORD
     MOVE "iron_ingot" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-INGOT
     MOVE "enchanted_book" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-BOOK
     MOVE "stick" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-STICK
     MOVE "minecraft:sharpness" TO WS-KEY64
     MOVE 19 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-SHARP WS-MAX WS-TAG WS-TAGLEN
     MOVE "minecraft:smite" TO WS-KEY64
     MOVE 15 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-SMITE WS-MAX WS-TAG WS-TAGLEN

*>   The tags the fixture's registry rows name: the sword is a sharp weapon, sharpness and smite exclude each other.
     MOVE "item" TO WS-REGI
     MOVE "minecraft:enchantable/sharp_weapon" TO WS-TAGKEY
     MOVE WS-SWORD TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     MOVE "enchantment" TO WS-REGI
     MOVE "minecraft:exclusive_set/damage" TO WS-TAGKEY
     MOVE WS-SHARP TO WS-MEMBER(1)
     MOVE WS-SMITE TO WS-MEMBER(2)
     MOVE 2 TO WS-N2
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-IDS WS-STATUS
     MOVE "test anvil material repair: an iron pickaxe of damage 100 with three iron ingots takes two ingots, costs 2 levels and carries repair cost 1" TO TL-CASE
     PERFORM FRESH
     MOVE WS-PICK TO WS-LITEM
     MOVE 100 TO WS-A
     CALL "SP-SET-DAMAGE" USING WS-LVAR WS-A
     MOVE WS-INGOT TO WS-RITEM
     MOVE 3 TO WS-RCOUNT
     PERFORM DO-ANVIL
     MOVE WS-OVAR TO WS-H
     CALL "SP-GET-DAMAGE" USING WS-OITEM WS-H WS-A
     MOVE 19 TO WS-T
     CALL "SP-GET-COMPONENT" USING WS-OVAR WS-T WS-NAME WS-CLEN WS-B
     MOVE WS-A TO WS-E1
     MOVE WS-COST TO WS-E2
     MOVE WS-UNITS TO WS-E3
     MOVE WS-NAME(1:1) TO WS-E4
     MOVE FUNCTION ORD(WS-NAME(1:1)) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "damage " FUNCTION TRIM(WS-E1) " cost " FUNCTION TRIM(WS-E2) " units " FUNCTION TRIM(WS-E3) " rc-byte " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "damage 0 cost 2 units 2 rc-byte 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test anvil durability merge: two iron pickaxes of damage 100 and 50 give damage 0 for 2 levels and use the whole right stack" TO TL-CASE
     PERFORM FRESH
     MOVE WS-PICK TO WS-LITEM WS-RITEM
     MOVE 100 TO WS-A
     CALL "SP-SET-DAMAGE" USING WS-LVAR WS-A
     MOVE 50 TO WS-A
     CALL "SP-SET-DAMAGE" USING WS-RVAR WS-A
     PERFORM DO-ANVIL
     MOVE WS-OVAR TO WS-H
     CALL "SP-GET-DAMAGE" USING WS-OITEM WS-H WS-A
     MOVE WS-A TO WS-E1
     MOVE WS-COST TO WS-E2
     MOVE WS-UNITS TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "damage " FUNCTION TRIM(WS-E1) " cost " FUNCTION TRIM(WS-E2) " units " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "damage 0 cost 2 units 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test anvil merge that does not repair: a pickaxe with a clean pair of equal damage keeps its damage; a damaged tool with the sticks is empty (early exit C)" TO TL-CASE
     PERFORM FRESH
     MOVE WS-PICK TO WS-LITEM WS-RITEM
     PERFORM DO-ANVIL
     MOVE WS-COST TO WS-E1
     MOVE WS-OITEM TO WS-E2
     PERFORM FRESH
     MOVE WS-SWORD TO WS-LITEM
     MOVE WS-STICK TO WS-RITEM
     PERFORM DO-ANVIL
     MOVE WS-COST TO WS-E3
     MOVE WS-OITEM TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) "/" FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0/0 0/0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test anvil early exits: an empty left stack, an undamaged pickaxe with an ingot (exit B) give no result" TO TL-CASE
     PERFORM FRESH
     MOVE 0 TO WS-LITEM WS-LCOUNT
     MOVE WS-INGOT TO WS-RITEM
     PERFORM DO-ANVIL
     MOVE WS-OITEM TO WS-E1
     PERFORM FRESH
     MOVE WS-PICK TO WS-LITEM
     MOVE WS-INGOT TO WS-RITEM
     PERFORM DO-ANVIL
     MOVE WS-OITEM TO WS-E2
     MOVE WS-COST TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test anvil book: sharpness 3 sword plus a book of sharpness 3 gives sharpness 4 for 4 levels (book anvil cost max(1, cost / 2) x level)" TO TL-CASE
     PERFORM FRESH
     MOVE WS-SWORD TO WS-LITEM
     MOVE 3 TO WS-A
     CALL "SP-ADD-ENCHANT" USING WS-LVAR WS-SHARP WS-A
     MOVE WS-BOOK TO WS-RITEM
     MOVE 45 TO WS-T
     CALL "SC-ENCH-ADD" USING WS-RVAR WS-T WS-SHARP WS-A
     PERFORM DO-ANVIL
     CALL "SP-ENCHANT-LEVEL" USING WS-OVAR WS-SHARP WS-A
     MOVE WS-A TO WS-E1
     MOVE WS-COST TO WS-E2
     MOVE WS-OITEM TO WS-E3
     MOVE WS-SWORD TO WS-E4
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING "level " FUNCTION TRIM(WS-E1) " cost " FUNCTION TRIM(WS-E2) " item " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     STRING "level 4 cost 4 item " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test anvil incompatible: smite from a book onto a sword with sharpness is rejected, nothing applied: no result" TO TL-CASE
     PERFORM FRESH
     MOVE WS-SWORD TO WS-LITEM
     MOVE 1 TO WS-A
     CALL "SP-ADD-ENCHANT" USING WS-LVAR WS-SHARP WS-A
     MOVE WS-BOOK TO WS-RITEM
     MOVE 5 TO WS-A
     CALL "SC-ENCH-ADD" USING WS-RVAR WS-T WS-SMITE WS-A
     PERFORM DO-ANVIL
     MOVE WS-OITEM TO WS-E1
     MOVE WS-COST TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test anvil rename: naming a sword costs 1, is rename only, keeps the repair cost; a blank name removes the custom name for 1" TO TL-CASE
     PERFORM FRESH
     MOVE WS-SWORD TO WS-LITEM
     MOVE 0 TO WS-RCOUNT WS-RITEM
     MOVE "Excalibur" TO WS-NAME
     MOVE 9 TO WS-NAMELEN
     PERFORM DO-ANVIL
     MOVE WS-OVAR TO WS-H
     CALL "SP-GET-NAME" USING WS-H WS-NAME WS-CLEN
     MOVE WS-COST TO WS-E1
     MOVE WS-ONLY TO WS-E2
     MOVE WS-CLEN TO WS-E3
     MOVE WS-OVAR TO WS-LVAR
     MOVE 0 TO WS-NAMELEN
     PERFORM DO-ANVIL
     MOVE WS-COST TO WS-E4
     MOVE WS-OVAR TO WS-H
     CALL "SP-GET-NAME" USING WS-H WS-NAME WS-CLEN
     MOVE WS-CLEN TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "named " FUNCTION TRIM(WS-E1) " only " FUNCTION TRIM(WS-E2) " len " FUNCTION TRIM(WS-E3) " cleared " FUNCTION TRIM(WS-E4)
         " len " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "named 1 only 1 len 9 cleared 1 len 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test anvil rename of an already named sword to the same name costs nothing: no result" TO TL-CASE
     PERFORM FRESH
     MOVE WS-SWORD TO WS-LITEM
     MOVE "Excalibur" TO WS-NAME
     CALL "SP-SET-NAME" USING WS-LVAR WS-NAME WS-NAMELEN
     MOVE 0 TO WS-RCOUNT WS-RITEM
     MOVE 9 TO WS-NAMELEN
     CALL "SP-SET-NAME" USING WS-LVAR WS-NAME WS-NAMELEN
     PERFORM DO-ANVIL
     MOVE WS-OITEM TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test anvil too expensive: a stack of two swords with a book costs 40 and gives no result in survival, a result for infinite materials" TO TL-CASE
     PERFORM FRESH
     MOVE WS-SWORD TO WS-LITEM
     MOVE 2 TO WS-LCOUNT
     MOVE WS-BOOK TO WS-RITEM
     MOVE 1 TO WS-RCOUNT
     MOVE 2 TO WS-A
     CALL "SC-ENCH-ADD" USING WS-RVAR WS-T WS-SHARP WS-A
     PERFORM DO-ANVIL
     MOVE WS-OITEM TO WS-E1
     MOVE WS-COST TO WS-E2
     MOVE 1 TO WS-INF
     PERFORM DO-ANVIL
     MOVE WS-OITEM TO WS-E3
     MOVE WS-COST TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "survival " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " creative " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "survival 0/40 creative " TO TL-EXPECTED
     IF WS-E3 NOT = SPACES AND WS-OITEM = WS-SWORD AND WS-COST >= 40
         MOVE "survival 0/40 creative " TO TL-OBSERVED
     END-IF
     PERFORM CHECK

     MOVE "test anvil repair cost: a book with repair cost 7 on a fresh sword gives the new repair cost 15; renaming a sword of repair cost 45 is lowered to 39 and stays rename only" TO TL-CASE
     PERFORM FRESH
     MOVE WS-SWORD TO WS-LITEM
     MOVE WS-BOOK TO WS-RITEM
     MOVE 1 TO WS-A
     MOVE 45 TO WS-T
     CALL "SC-ENCH-ADD" USING WS-RVAR WS-T WS-SHARP WS-A
     MOVE 7 TO WS-B
     PERFORM PUT-RC-RIGHT
     PERFORM DO-ANVIL
     MOVE 19 TO WS-T
     CALL "SP-GET-COMPONENT" USING WS-OVAR WS-T WS-NAME WS-CLEN WS-B
     MOVE FUNCTION ORD(WS-NAME(1:1)) TO WS-E1
     MOVE WS-COST TO WS-E2
     PERFORM FRESH
     MOVE WS-SWORD TO WS-LITEM
     MOVE 0 TO WS-RCOUNT WS-RITEM
     MOVE 45 TO WS-B
     MOVE 19 TO WS-T
     MOVE SPACES TO WS-NAME
     MOVE 1 TO WS-CLEN
     MOVE FUNCTION CHAR(WS-B + 1) TO WS-NAME(1:1)
     CALL "SP-SET-COMPONENT" USING WS-LVAR WS-T WS-NAME WS-CLEN
     MOVE "Blade" TO WS-NAME
     MOVE 5 TO WS-NAMELEN
     PERFORM DO-ANVIL
     MOVE WS-COST TO WS-E3
     MOVE WS-ONLY TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "rc-byte " FUNCTION TRIM(WS-E1) " cost " FUNCTION TRIM(WS-E2) " rename " FUNCTION TRIM(WS-E3) " only " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "rc-byte 16 cost 8 rename 39 only 1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 PUT-RC-RIGHT.
     MOVE 19 TO WS-T
     MOVE SPACES TO WS-NAME
     MOVE 1 TO WS-CLEN
     MOVE FUNCTION CHAR(WS-B + 1) TO WS-NAME(1:1)
     CALL "SP-SET-COMPONENT" USING WS-RVAR WS-T WS-NAME WS-CLEN.

 FRESH.
     MOVE 0 TO WS-LVAR WS-RVAR WS-NAMELEN WS-INF WS-LITEM WS-RITEM
     MOVE 1 TO WS-LCOUNT WS-RCOUNT
     MOVE SPACES TO WS-NAME.

 DO-ANVIL.
     CALL "ANVIL-CREATE-RESULT" USING WS-LITEM WS-LCOUNT WS-LVAR WS-RITEM WS-RCOUNT WS-RVAR WS-NAME WS-NAMELEN WS-INF
         WS-OITEM WS-OCOUNT WS-OVAR WS-COST WS-UNITS WS-ONLY.

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ANVIL.
 COPY CORETEST.
