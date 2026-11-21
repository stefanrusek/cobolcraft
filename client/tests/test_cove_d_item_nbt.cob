*> Coverage of the early exit of ITEM-NBT-SKIP: a value whose first tag type byte is 0 (an End tag, no value) gives ok 0 and leaves the position after that byte.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-D-ITEM-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-V                   PIC X(2048).
 01 WS-LEN                 BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE LOW-VALUES TO WS-V
     MOVE 3 TO WS-LEN
     MOVE 1 TO WS-POS
     MOVE 7 TO WS-OK
     CALL "ITEM-NBT-SKIP" USING WS-V WS-LEN WS-POS WS-OK
     MOVE "N" TO TL-MODE
     MOVE "cove-d item nbt skip: a leading End tag is not a value (ok 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cove-d item nbt skip: a leading End tag moves the position past its byte" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-POS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVE-D-ITEM-NBT.
