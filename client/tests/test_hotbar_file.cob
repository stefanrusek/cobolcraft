*> Test US12-client (spec 002; docs/protocol/40-menus-7-creative-inventory.md section 10): the saved hotbars file hotbar.nbt (client/src/screens/hotbarfile.cob). Saving hotbar 3 writes the gzip NBT file with
*> DataVersion 5023, the entry "3" a list of nine compounds (an empty slot an empty compound, an item {id minecraft:..., count}); loading it in a fresh state gives the same stacks back and the other
*> eight hotbars empty; a missing file and a garbage file keep nine empty hotbars; nothing is written when no game directory is set.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HOTBAR-FILE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 01 WS-PATH                PIC X(64) VALUE "build/client-test-hotbar/hotbar.nbt".
 01 WS-PATH-LENGTH         BINARY-LONG VALUE 35.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-INFO                PIC X(16).
 01 WS-TALLY               BINARY-LONG.
 01 B-BYTES                PIC X(65536) BASED.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-hotbar; mkdir -p build/client-test-hotbar"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO CL-GAME-DIR-LENGTH
     MOVE 5 TO WS-STONE
     MOVE WS-STONE TO PL-SLOT-ITEM(1)
     MOVE 7 TO PL-SLOT-COUNT(1)
     MOVE WS-STONE TO PL-SLOT-ITEM(9)
     MOVE 1 TO PL-SLOT-COUNT(9)
     MOVE 3 TO WS-K
     CALL "CREATIVE-HOTBAR-SAVE" USING CLIENT-STATE WS-K
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§10 with no game directory set nothing is written" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF RETURN-CODE NOT = 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 0 TO RETURN-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "build/client-test-hotbar" TO CL-GAME-DIR
     MOVE 24 TO CL-GAME-DIR-LENGTH
     CALL "CREATIVE-HOTBAR-SAVE" USING CLIENT-STATE WS-K
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBT-FILE-READ" USING WS-PATH WS-PATH-LENGTH PB-BUFFER WS-OUTCOME
     MOVE "acceptance US12 40-7§10 saving hotbar 3 writes build/client-test-hotbar/hotbar.nbt as a readable gzip NBT file" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SET ADDRESS OF B-BYTES TO PB-ADDR
     MOVE 0 TO WS-TALLY
     INSPECT B-BYTES(1:PB-LENGTH) TALLYING WS-TALLY FOR ALL "DataVersion"
     MOVE "acceptance US12 40-7§10 the file holds DataVersion and the item id cobolcraft:<key>" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-TALLY TO TL-OBSERVED-N
     MOVE 0 TO WS-N
     INSPECT B-BYTES(1:PB-LENGTH) TALLYING WS-N FOR ALL "cobolcraft:"
     IF WS-N = 2
         ADD 0 TO WS-TALLY
     ELSE
         MOVE 99 TO WS-TALLY
     END-IF
     MOVE WS-TALLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
*>   Load in a fresh state.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 81
         MOVE 99 TO CR-HB-ITEM(WS-I)
         MOVE 99 TO CR-HB-COUNT(WS-I)
     END-PERFORM
     CALL "HOTBAR-FILE-LOAD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE CR-HB-ITEM(28) TO WS-E1
     MOVE CR-HB-COUNT(28) TO WS-E2
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-7§10 loading gives hotbar 3 slot 0 back: stone x7" TO TL-CASE
     MOVE WS-STONE TO WS-E1
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) "x7" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§10 the empty slots and the other eight hotbars load empty (the other 79 entries hold no stack)" TO TL-CASE
     MOVE 79 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 81
         IF CR-HB-COUNT(WS-I) = 0 AND CR-HB-ITEM(WS-I) = 0
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A missing file and a garbage file keep nine empty hotbars.
     CALL "SYSTEM" USING "rm -f build/client-test-hotbar/hotbar.nbt"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 81
         MOVE 5 TO CR-HB-ITEM(WS-I)
         MOVE 5 TO CR-HB-COUNT(WS-I)
     END-PERFORM
     CALL "HOTBAR-FILE-LOAD" USING CLIENT-STATE
     MOVE "acceptance US12 40-7§10 a missing hotbar.nbt keeps nine empty hotbars" TO TL-CASE
     MOVE 81 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 81
         IF CR-HB-COUNT(WS-I) = 0
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SYSTEM" USING "echo garbage > build/client-test-hotbar/hotbar.nbt"
     MOVE 5 TO CR-HB-COUNT(1)
     CALL "HOTBAR-FILE-LOAD" USING CLIENT-STATE
     MOVE "acceptance US12 40-7§10 a garbage hotbar.nbt keeps nine empty hotbars" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CR-HB-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-HOTBAR-FILE.

 COPY CLTEST.
