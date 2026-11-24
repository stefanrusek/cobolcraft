*> Test of the repair materials of the anvil (core/src/anvil.cob ANVIL-REPAIRS; docs/protocol/17 section 2.1; lane itemcomp2, T10102): each tool and armour material takes its own ingredient and
*> refuses another, the elytra, shield and mace take theirs, an item that is no tool takes nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ANVIL-REPAIRS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-PAIRS-DATA.
    05 FILLER PIC X(64) VALUE "wooden_sword        oak_planks          1".
    05 FILLER PIC X(64) VALUE "stone_axe           cobblestone         1".
    05 FILLER PIC X(64) VALUE "copper_pickaxe      copper_ingot        1".
    05 FILLER PIC X(64) VALUE "iron_shovel         iron_ingot          1".
    05 FILLER PIC X(64) VALUE "chainmail_helmet    iron_ingot          1".
    05 FILLER PIC X(64) VALUE "golden_hoe          gold_ingot          1".
    05 FILLER PIC X(64) VALUE "diamond_chestplate  diamond             1".
    05 FILLER PIC X(64) VALUE "netherite_leggings  netherite_ingot     1".
    05 FILLER PIC X(64) VALUE "leather_boots       leather             1".
    05 FILLER PIC X(64) VALUE "turtle_helmet       turtle_scute        1".
    05 FILLER PIC X(64) VALUE "elytra              phantom_membrane    1".
    05 FILLER PIC X(64) VALUE "shield              oak_planks          1".
    05 FILLER PIC X(64) VALUE "mace                breeze_rod          1".
    05 FILLER PIC X(64) VALUE "iron_sword          diamond             0".
    05 FILLER PIC X(64) VALUE "stick               iron_ingot          0".
 01 WS-PAIRS REDEFINES WS-PAIRS-DATA.
    05 WS-PAIR OCCURS 15 TIMES.
       10 WS-ITEM-KEY      PIC X(20).
       10 WS-MAT-KEY       PIC X(20).
       10 WS-WANT          PIC 9.
       10 FILLER           PIC X(23).
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-MAT                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-MISMATCH            BINARY-LONG VALUE 0.
 01 WS-REGI                PIC X(48) VALUE "item".
 01 WS-TAGKEY              PIC X(112) VALUE "minecraft:planks".
 01 WS-IDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 4 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 1.
 01 WS-E1                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "T" TO TL-MODE
*>   The planks tag of the test world: oak planks.
     MOVE "minecraft:oak_planks" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-MEMBER(1) WS-ITEM-ROW WS-STATUS
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N1 WS-IDS WS-STATUS
     MOVE "test anvil repairs every material takes its ingredient and nothing else" TO TL-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         MOVE SPACES TO WS-ITEM-ROW
         STRING "minecraft:" FUNCTION TRIM(WS-ITEM-KEY(WS-I)) DELIMITED BY SIZE INTO WS-ITEM-ROW
         MOVE WS-ITEM-ROW TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         MOVE SPACES TO WS-ITEM-ROW
         STRING "minecraft:" FUNCTION TRIM(WS-MAT-KEY(WS-I)) DELIMITED BY SIZE INTO WS-ITEM-ROW
         MOVE WS-ITEM-ROW TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-MAT WS-ITEM-ROW WS-STATUS
         CALL "ANVIL-REPAIRS" USING WS-ITEM WS-MAT WS-OK
         IF WS-OK NOT = WS-WANT(WS-I)
             ADD 1 TO WS-MISMATCH
         END-IF
     END-PERFORM
     MOVE WS-MISMATCH TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ANVIL-REPAIRS.
 COPY CORETEST.
