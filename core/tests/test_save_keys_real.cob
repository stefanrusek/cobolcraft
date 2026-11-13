*> Real-data test (skipped as a pass without the generated packs; vanfmt lane; docs/protocol/07 section 7.3, 9.2, 9.3): a
*> standard set keeps item keys without a namespace in memory (CITEMS.cpy), but the world folder always stores
*> "minecraft:" + path (the player file's stack id, a ground item's Item.id). The stack of the player file is written
*> with the namespace and read back from the namespaced and from the bare form, and a key longer than 32 characters
*> (minecraft:waxed_weathered_cut_copper_stairs) is read whole.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SAVE-KEYS-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 COPY PROTO.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 7.
 01 WS-KP                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BACK-ITEM           BINARY-LONG.
 01 WS-BACK-COUNT          BINARY-LONG.
 01 WS-BACK-KP             BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-WANT                PIC X(64).
 01 WS-WANT-LENGTH         BINARY-LONG.
 01 WS-ID-TEXT             PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-SLOT-BYTE           BINARY-LONG VALUE 3.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
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
         MOVE "test save keys real no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "T" TO TL-MODE
     MOVE "granite" TO WS-WANT
     MOVE 7 TO WS-WANT-LENGTH
     PERFORM FIND-ITEM
     PERFORM WRITE-STACK
     MOVE "test save keys real a standard item is written as minecraft:granite" TO TL-CASE
     MOVE "id" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED
     MOVE "minecraft:granite" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-ROOT TO PB-POS
     CALL "PNBT-STACK-READ" USING PB-BUFFER WS-SLOT WS-BACK-ITEM WS-BACK-COUNT WS-BACK-KP
     MOVE "test save keys real the namespaced stack reads back as the same item and count" TO TL-CASE
     MOVE WS-ITEM TO WS-EDIT
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-EDIT) " 7" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-BACK-ITEM TO WS-EDIT
     MOVE WS-BACK-COUNT TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:waxed_weathered_cut_copper_stairs" TO WS-WANT
     MOVE 43 TO WS-WANT-LENGTH
     PERFORM FIND-ITEM
     PERFORM WRITE-STACK
     MOVE WS-ROOT TO PB-POS
     CALL "PNBT-STACK-READ" USING PB-BUFFER WS-SLOT WS-BACK-ITEM WS-BACK-COUNT WS-BACK-KP
     MOVE "test save keys real a 43-character item key is read back to the same item" TO TL-CASE
     MOVE WS-ITEM TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-EXPECTED
     MOVE WS-BACK-ITEM TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-ITEM: the item whose key (with or without "minecraft:") is WS-WANT, else -1.
 FIND-ITEM.
     MOVE -1 TO WS-ITEM
     MOVE WS-WANT TO WS-ID-TEXT
     IF WS-WANT(1:10) = "minecraft:"
         MOVE SPACES TO WS-ID-TEXT
         MOVE WS-WANT(11:54) TO WS-ID-TEXT
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > IT-COUNT
         IF IT-KEY(WS-K) = WS-ID-TEXT
             COMPUTE WS-ITEM = WS-K - 1
         END-IF
     END-PERFORM.

*> PB-BUFFER holds one compound with Slot and the stack of WS-ITEM; WS-ROOT is its payload position.
 WRITE-STACK.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-ITEM WS-COUNT WS-KP
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT.
 END PROGRAM TEST-SAVE-KEYS-REAL.

 COPY CORETEST.
