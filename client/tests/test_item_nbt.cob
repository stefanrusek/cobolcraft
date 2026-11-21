*> Implementation test of client/src/item-nbt.cob ITEM-NBT-SKIP: the end of a nameless network NBT value (the text component of an inline holder, 54 section 18.1) inside a
*> component's bytes: a String tag, a Compound with every tag type (byte, short, int, long, float, double, byte array, string, list of compounds, nested compound, int
*> array, long array) and an empty list; the position moves to the byte after the value; a truncated or malformed value (a bad tag, a list of unknown elements, a
*> compound nested past the depth the skipper keeps) gives ok 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEM-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-V                   PIC X(2048).
 01 WS-LEN                 BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-E                   PIC -(5)9.
 01 WS-I                   BINARY-LONG.
 01 WS-PD                  PIC Z(3)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
*>   A String tag "hi": 08 0002 'h' 'i', then a marker byte 7F.
     MOVE LOW-VALUES TO WS-V
     MOVE X"0800026869" TO WS-V(1:5)
     MOVE X"7F" TO WS-V(6:1)
     MOVE 6 TO WS-LEN
     MOVE 1 TO WS-POS
     CALL "ITEM-NBT-SKIP" USING WS-V WS-LEN WS-POS WS-OK
     MOVE "item nbt skip: a string tag moves the position past its 5 bytes" TO TL-CASE
     PERFORM SHOW
     MOVE "1 6" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A compound with all the tag types:
*>   0A  01 0001 'a' 05 | 02 0001 'b' 0007 | 03 0001 'c' 00000001 | 04 0001 'd' 0000000000000002 | 05 0001 'e' 3F800000 | 06 0001 'f' 3FF0000000000000
*>   07 0001 'g' 00000002 AA BB | 08 0001 'h' 0001 'x' | 09 0001 'i' 0A 00000002 { 01 0001 'k' 09 00 } { 00 } | 0A 0001 'j' { 00 }
*>   0B 0001 'l' 00000001 00000007 | 0C 0001 'm' 00000001 0000000000000008 | 09 0001 'n' 00 00000000 | 00
     MOVE LOW-VALUES TO WS-V
     MOVE 1 TO WS-POS
     MOVE X"0A" TO WS-V(WS-POS:1)
     ADD 1 TO WS-POS
     MOVE X"01000161" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"05" TO WS-V(WS-POS:1)
     ADD 1 TO WS-POS
     MOVE X"020001620007" TO WS-V(WS-POS:6)
     ADD 6 TO WS-POS
     MOVE X"03000163" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"00000001" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"04000164" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"0000000000000002" TO WS-V(WS-POS:8)
     ADD 8 TO WS-POS
     MOVE X"05000165" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"3F800000" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"06000166" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"3FF0000000000000" TO WS-V(WS-POS:8)
     ADD 8 TO WS-POS
     MOVE X"07000167" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"00000002AABB" TO WS-V(WS-POS:6)
     ADD 6 TO WS-POS
     MOVE X"080001680001" TO WS-V(WS-POS:6)
     ADD 6 TO WS-POS
     MOVE X"78" TO WS-V(WS-POS:1)
     ADD 1 TO WS-POS
     MOVE X"09000169" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"0A00000002" TO WS-V(WS-POS:5)
     ADD 5 TO WS-POS
     MOVE X"0100016B0900" TO WS-V(WS-POS:6)
     ADD 6 TO WS-POS
     MOVE X"00" TO WS-V(WS-POS:1)
     ADD 1 TO WS-POS
     MOVE X"0A00016A" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"00" TO WS-V(WS-POS:1)
     ADD 1 TO WS-POS
     MOVE X"0B00016C" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"0000000100000007" TO WS-V(WS-POS:8)
     ADD 8 TO WS-POS
     MOVE X"0C00016D" TO WS-V(WS-POS:4)
     ADD 4 TO WS-POS
     MOVE X"000000010000000000000008" TO WS-V(WS-POS:12)
     ADD 12 TO WS-POS
     MOVE X"0900016E0000000000" TO WS-V(WS-POS:9)
     ADD 9 TO WS-POS
     MOVE X"00" TO WS-V(WS-POS:1)
     ADD 1 TO WS-POS
     MOVE X"7F" TO WS-V(WS-POS:1)
     MOVE WS-POS TO WS-LEN
     MOVE 1 TO WS-POS
     CALL "ITEM-NBT-SKIP" USING WS-V WS-LEN WS-POS WS-OK
     MOVE "item nbt skip: a compound with every tag type ends before the marker byte" TO TL-CASE
     MOVE WS-OK TO WS-E
     MOVE SPACES TO TL-OBSERVED
     MOVE "1 marker" TO TL-EXPECTED
     IF WS-OK = 1 AND WS-POS = WS-LEN
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Truncated: the String tag claims 5 bytes of text with 2 left.
     MOVE LOW-VALUES TO WS-V
     MOVE X"0800056869" TO WS-V(1:5)
     MOVE 5 TO WS-LEN
     MOVE 1 TO WS-POS
     CALL "ITEM-NBT-SKIP" USING WS-V WS-LEN WS-POS WS-OK
     MOVE "item nbt skip: a string longer than the value is not ok" TO TL-CASE
     MOVE WS-OK TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A bad tag type (13) and an empty value are not ok; a list of unknown elements (type 99) too.
     MOVE X"0D" TO WS-V(1:1)
     MOVE 1 TO WS-LEN
     MOVE 1 TO WS-POS
     CALL "ITEM-NBT-SKIP" USING WS-V WS-LEN WS-POS WS-OK
     MOVE "item nbt skip: tag type 13 is not ok" TO TL-CASE
     MOVE WS-OK TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LEN
     MOVE 1 TO WS-POS
     CALL "ITEM-NBT-SKIP" USING WS-V WS-LEN WS-POS WS-OK
     MOVE "item nbt skip: an empty value is not ok" TO TL-CASE
     MOVE WS-OK TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE X"096300000001" TO WS-V(1:6)
     MOVE 6 TO WS-LEN
     MOVE 1 TO WS-POS
     CALL "ITEM-NBT-SKIP" USING WS-V WS-LEN WS-POS WS-OK
     MOVE "item nbt skip: a list of element type 99 with one element is not ok" TO TL-CASE
     MOVE WS-OK TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Nesting: 20 compounds in a row (the skipper keeps 16 levels) is not ok.
     MOVE LOW-VALUES TO WS-V
     MOVE X"0A" TO WS-V(1:1)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= 19
         MOVE X"0A000178" TO WS-V(WS-I * 4 + 2:4)
     END-PERFORM
     MOVE 77 TO WS-LEN
     MOVE 1 TO WS-POS
     CALL "ITEM-NBT-SKIP" USING WS-V WS-LEN WS-POS WS-OK
     MOVE "item nbt skip: 20 nested compounds are not ok" TO TL-CASE
     MOVE WS-OK TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   More malformed values: a length cut off, a negative length, a list header cut off, a compound with no end tag, an entry name past the value.
     MOVE X"0800" TO WS-V(1:2)
     MOVE 2 TO WS-LEN
     MOVE "item nbt skip: a string whose length is cut off is not ok" TO TL-CASE
     PERFORM TRY-ONE
     MOVE X"07FFFFFFFF" TO WS-V(1:5)
     MOVE 5 TO WS-LEN
     MOVE "item nbt skip: a byte array with a negative length is not ok" TO TL-CASE
     PERFORM TRY-ONE
     MOVE X"090A00" TO WS-V(1:3)
     MOVE 3 TO WS-LEN
     MOVE "item nbt skip: a list header cut off is not ok" TO TL-CASE
     PERFORM TRY-ONE
     MOVE X"0A" TO WS-V(1:1)
     MOVE 1 TO WS-LEN
     MOVE "item nbt skip: a compound with no end tag is not ok" TO TL-CASE
     PERFORM TRY-ONE
     MOVE X"0A01000561" TO WS-V(1:5)
     MOVE 5 TO WS-LEN
     MOVE "item nbt skip: an entry name past the end of the value is not ok" TO TL-CASE
     PERFORM TRY-ONE
     STOP RUN.

 TRY-ONE.
     MOVE 1 TO WS-POS
     CALL "ITEM-NBT-SKIP" USING WS-V WS-LEN WS-POS WS-OK
     MOVE WS-OK TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SHOW.
     MOVE WS-OK TO WS-E
     MOVE WS-POS TO WS-PD
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E) " " FUNCTION TRIM(WS-PD) DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM TEST-ITEM-NBT.
 COPY CLTEST.
