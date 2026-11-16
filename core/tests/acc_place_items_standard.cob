*> Acceptance test, lane try6fix (operator report: holding wheat and right-clicking plants wheat seeds): the block an item places (IT-PLACES-STATE)
*> in a standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without
*> it). The generated item rows link an item to the block of the same key, so the item wheat (class Item) was linked to the crop block wheat and the
*> seeds, carrot and potato (class BlockItem; the crop blocks are named wheat, carrots, potatoes) to nothing. Items that are no block items place
*> nothing (wheat, apple, beetroot, melon slice, pumpkin pie); the crop and wire items place their block.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-PLACE-ITEMS-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-KEY            PIC X(48).
 01 WS-BLOCK-KEY           PIC X(48).
 01 WS-IID                 BINARY-LONG.
 01 WS-BID                 BINARY-LONG.
 01 WS-IROW                PIC X(270).
 01 WS-BROW                PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-E                   PIC -(9)9.
 01 WS-OK                  PIC X(5).
 01 WS-TEXT                PIC X(300).
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance eat standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Placing" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "acceptance place items standard: wheat, apple, beetroot, melon_slice and pumpkin_pie place nothing" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "wheat" TO WS-ITEM-KEY
     PERFORM ADD-ITEM
     MOVE "apple" TO WS-ITEM-KEY
     PERFORM ADD-ITEM
     MOVE "beetroot" TO WS-ITEM-KEY
     PERFORM ADD-ITEM
     MOVE "melon_slice" TO WS-ITEM-KEY
     PERFORM ADD-ITEM
     MOVE "pumpkin_pie" TO WS-ITEM-KEY
     PERFORM ADD-ITEM
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "wheat -1, apple -1, beetroot -1, melon_slice -1, pumpkin_pie -1," TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance place items standard: seeds, carrot, potato, string and redstone place their crop or wire block" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "wheat_seeds" TO WS-ITEM-KEY
     MOVE "wheat" TO WS-BLOCK-KEY
     PERFORM ADD-LINK
     MOVE "carrot" TO WS-ITEM-KEY
     MOVE "carrots" TO WS-BLOCK-KEY
     PERFORM ADD-LINK
     MOVE "potato" TO WS-ITEM-KEY
     MOVE "potatoes" TO WS-BLOCK-KEY
     PERFORM ADD-LINK
     MOVE "beetroot_seeds" TO WS-ITEM-KEY
     MOVE "beetroots" TO WS-BLOCK-KEY
     PERFORM ADD-LINK
     MOVE "melon_seeds" TO WS-ITEM-KEY
     MOVE "melon_stem" TO WS-BLOCK-KEY
     PERFORM ADD-LINK
     MOVE "pumpkin_seeds" TO WS-ITEM-KEY
     MOVE "pumpkin_stem" TO WS-BLOCK-KEY
     PERFORM ADD-LINK
     MOVE "string" TO WS-ITEM-KEY
     MOVE "tripwire" TO WS-BLOCK-KEY
     PERFORM ADD-LINK
     MOVE "redstone" TO WS-ITEM-KEY
     MOVE "redstone_wire" TO WS-BLOCK-KEY
     PERFORM ADD-LINK
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "wheat_seeds ok, carrot ok, potato ok, beetroot_seeds ok, melon_seeds ok, pumpkin_seeds ok, string ok, redstone ok," TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADD-ITEM.
     MOVE WS-ITEM-KEY TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE IT-PLACES-STATE(WS-IID + 1) TO WS-E
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ITEM-KEY) " " FUNCTION TRIM(WS-E) ","
         DELIMITED BY SIZE INTO WS-TEXT.

 ADD-LINK.
     MOVE WS-ITEM-KEY TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE WS-BLOCK-KEY TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE "WRONG" TO WS-OK
     IF IT-PLACES-STATE(WS-IID + 1) = CB-DEFAULT-STATE(WS-BID + 1)
         MOVE "ok" TO WS-OK
     END-IF
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ITEM-KEY) " " FUNCTION TRIM(WS-OK) ","
         DELIMITED BY SIZE INTO WS-TEXT.
 END PROGRAM ACC-PLACE-ITEMS-STANDARD.

 COPY CORETEST.
