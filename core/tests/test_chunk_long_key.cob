*> Implementation test (chunk-data.cob CHUNK-NBT-PALETTE-ENTRY; docs/protocol/07 section 7.3): a palette entry of a real
*> 26.3 chunk names blocks whose key is longer than 32 characters (minecraft:waxed_weathered_cut_copper_stairs, 46)
*> and may hold many properties; the key is read whole and the entry is not malformed (a malformed chunk is
*> generated again, which lost every such chunk of a saved world).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHUNK-LONG-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ELEMENT             BINARY-LONG VALUE 10.
 01 WS-KEY-TEXT            PIC X(64) VALUE "minecraft:waxed_weathered_cut_copper_stairs".
 01 WS-KEY-TEXT-LENGTH     BINARY-LONG VALUE 43.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAIRS               PIC X(160).
 01 WS-PAIR-COUNT          BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN
     MOVE 2 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-KEY-TEXT WS-KEY-TEXT-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE SPACES TO WS-KEY WS-PAIRS
     MOVE 0 TO WS-KEY-LENGTH WS-PAIR-COUNT
     CALL "CHUNK-NBT-PALETTE-ENTRY" USING PB-BUFFER WS-ELEMENT WS-KEY WS-KEY-LENGTH WS-PAIRS WS-PAIR-COUNT
     MOVE WS-KEY-LENGTH TO WS-E1
     MOVE PB-ERROR TO WS-E2
     MOVE "test chunk long key: a 43-character palette key is read whole without an error" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "43 0 minecraft:waxed_weathered_cut_copper_stairs" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CHUNK-LONG-KEY.
