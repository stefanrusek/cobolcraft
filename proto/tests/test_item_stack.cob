*> Implementation test of the item stack with a DataComponentPatch (00 §12.1, §12.2) in
*> proto/src/item-stack.cob: PB-PUT-ITEM-STACK writes count, item, the counts and the added and
*> removed lists (component values verbatim); PB-GET-ITEM-STACK reads the value of the component
*> types whose codec the documents give (46 §8.1, 17 §1.2) and rejects every other type. Values the
*> writer cannot encode append nothing and set PB-ERROR; a failed read leaves PB-POS where it was
*> and yields an all-zero record.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEM-STACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-HEX                 PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-BIG                 PIC X(700).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM PUT-CASES
     PERFORM GET-CASES
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.

 PUT-CASES.
     INITIALIZE PB-ITEMSTACK-X
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of an empty stack is the single byte 00" TO TL-CASE
     MOVE "00" TO TL-EXPECTED
     PERFORM CHECK-BYTES
     MOVE -1 TO PB-ISX-COUNT
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of count -1 is the empty stack 00" TO TL-CASE
     MOVE "00" TO TL-EXPECTED
     PERFORM CHECK-BYTES
     MOVE 16 TO PB-ISX-COUNT
     MOVE 63 TO PB-ISX-ITEM
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of 16 x item 63 with an empty patch is 10 3f 00 00" TO TL-CASE
     MOVE "103f0000" TO TL-EXPECTED
     PERFORM CHECK-BYTES
     MOVE 1 TO PB-ISX-COUNT
     MOVE 1 TO PB-ISX-ITEM
     MOVE 2 TO PB-ISX-ADDED-COUNT
     MOVE 1 TO PB-ISX-REMOVED-COUNT
     MOVE 3 TO PB-ISX-TYPE(1)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"05" TO PB-ISX-VALUE(1)(1:1)
     MOVE 6 TO PB-ISX-TYPE(2)
     MOVE 5 TO PB-ISX-VALUE-LENGTH(2)
     MOVE FUNCTION HEX-TO-CHAR("0800024869") TO PB-ISX-VALUE(2)(1:5)
     MOVE 1 TO PB-ISX-REMOVED(1)
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put with damage, custom_name and a removed max_stack_size" TO TL-CASE
     MOVE "01010201030506080002486901" TO TL-EXPECTED
     PERFORM CHECK-BYTES
     INITIALIZE PB-ITEMSTACK-X
     MOVE 2 TO PB-ISX-COUNT
     MOVE 300 TO PB-ISX-ITEM
     MOVE 2 TO PB-ISX-REMOVED-COUNT
     MOVE 1 TO PB-ISX-REMOVED(1)
     MOVE 2 TO PB-ISX-REMOVED(2)
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of a patch with removals only and a two-byte item id" TO TL-CASE
     MOVE "02ac0200020102" TO TL-EXPECTED
     PERFORM CHECK-BYTES
*>   ---- values the writer rejects ----
     INITIALIZE PB-ITEMSTACK-X
     MOVE 1 TO PB-ISX-COUNT
     MOVE 1 TO PB-ISX-ITEM
     MOVE 33 TO PB-ISX-ADDED-COUNT
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of 33 added components sets PB-ERROR and appends nothing"
         TO TL-CASE
     PERFORM CHECK-PUT-ERROR
     MOVE 0 TO PB-ISX-ADDED-COUNT
     MOVE 33 TO PB-ISX-REMOVED-COUNT
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of 33 removed components sets PB-ERROR and appends nothing"
         TO TL-CASE
     PERFORM CHECK-PUT-ERROR
     MOVE -1 TO PB-ISX-REMOVED-COUNT
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of a negative removed count sets PB-ERROR and appends nothing"
         TO TL-CASE
     PERFORM CHECK-PUT-ERROR
     MOVE 0 TO PB-ISX-REMOVED-COUNT
     MOVE -1 TO PB-ISX-ADDED-COUNT
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of a negative added count sets PB-ERROR and appends nothing"
         TO TL-CASE
     PERFORM CHECK-PUT-ERROR
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 513 TO PB-ISX-VALUE-LENGTH(1)
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of a 513-byte component value sets PB-ERROR and appends nothing"
         TO TL-CASE
     PERFORM CHECK-PUT-ERROR
     MOVE -1 TO PB-ISX-VALUE-LENGTH(1)
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of a negative value length sets PB-ERROR and appends nothing"
         TO TL-CASE
     PERFORM CHECK-PUT-ERROR
     MOVE 0 TO PB-ISX-VALUE-LENGTH(1)
     MOVE -1 TO PB-ISX-TYPE(1)
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of a negative component type sets PB-ERROR and appends nothing"
         TO TL-CASE
     PERFORM CHECK-PUT-ERROR
     MOVE 0 TO PB-ISX-TYPE(1)
     MOVE 1 TO PB-ISX-REMOVED-COUNT
     MOVE -1 TO PB-ISX-REMOVED(1)
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of a negative removed type sets PB-ERROR and appends nothing"
         TO TL-CASE
     PERFORM CHECK-PUT-ERROR
     MOVE 0 TO PB-ISX-REMOVED-COUNT
     MOVE -1 TO PB-ISX-ITEM
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack put of a negative item id sets PB-ERROR and appends nothing"
         TO TL-CASE
     PERFORM CHECK-PUT-ERROR.

 GET-CASES.
     MOVE "00" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of 00 is the empty stack, one byte read" TO TL-CASE
     MOVE "c0 i0 pos 1 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "ffffffff0f" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of count -1 is the empty stack with nothing more read" TO TL-CASE
     MOVE "c0 i0 pos 5 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "10 3f 00 00" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of 16 x item 63 with an empty patch" TO TL-CASE
     MOVE "c16 i63 pos 4 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 02 01 03 05 06 08 00 02 48 69 01" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of damage, custom_name and a removed max_stack_size" TO TL-CASE
     MOVE "c1 i1 +3=05 +6=0800024869 -1 pos 13 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "02 ac02 00 02 01 02" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of removals only and a two-byte item id" TO TL-CASE
     MOVE "c2 i300 -1 -2 pos 7 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
*>   one value of each documented codec: unit, boolean, float, VarInt, enum, text compound
     MOVE "01 01 06 00 04 15 01 07 3f800000 13 ac02 0c 02 06 0a0800047465787400014100" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of unit, boolean, float, VarInt, enum and text compound values"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "c1 i1 +4 +21=01 +7=3f800000 +19=ac02 +12=02 +6=0a0800047465787400014100 "
         "pos 30 error 0" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-GET
*>   ItemEnchantments (13 and 45, 17 section 1.2): a count, then pairs of enchantment id and level
     MOVE "01 01 02 00 0d 02 05 03 02 01 2d 00" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of enchantments (two pairs) and empty stored enchantments" TO TL-CASE
     MOVE "c1 i1 +13=0205030201 +45=00 pos 12 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
*>   Book components (46 section 8.1 ids 56 and 57; the Filterable layout is the raw value then an optional filtered one, a Boolean and the value).
     MOVE "01 01 01 00 38 01 02 4869 00" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of writable_book_content: one page Hi with no filtered text" TO TL-CASE
     MOVE "c1 i1 +56=0102486900 pos 10 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 38 02 02 4869 01 01 48 00 00" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of writable_book_content: a page with a filtered text, then an empty page" TO TL-CASE
     MOVE "c1 i1 +56=020248690101480000 pos 14 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 39 01 54 00 01 41 00 01 08 0001 61 00 01" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of written_book_content: title T, author A, generation 0, one text page, resolved" TO TL-CASE
     MOVE "c1 i1 +57=01540001410001080001610001 pos 18 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 38 65" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of writable_book_content with 101 pages sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 39 01 54 00 01 41 04 00 01" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of written_book_content with generation 4 sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 39 01 54 01 01 74 01 41 00 00 01" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of written_book_content with a filtered title and no pages" TO TL-CASE
     MOVE "c1 i1 +57=01540101740141000001 pos 15 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 39 01 54 00 01 41 00 01 08 0001 61 01 08 0001 62 00" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of written_book_content with a filtered page, not resolved" TO TL-CASE
     MOVE "c1 i1 +57=0154000141000108000161010800016200 pos 22 error 0" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 39 01 54 00 01 41 00 65" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of written_book_content with 101 pages sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
*>   ---- values the reader rejects ----
     MOVE "01 01 01 00 10 00" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of attribute_modifiers (16, layout not read) sets PB-ERROR, PB-POS 0"
         TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 0d ff7f" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of enchantments with 16383 pairs sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 2d 02 05" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of stored enchantments cut short sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 01 00 03" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of a value cut short sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 21 00" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of 33 added components sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 00 21" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of 33 removed components sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 ffffffff0f 00" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of a negative added count sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 00 ffffffff0f" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of a negative removed count sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
     MOVE "01 01 00 01" TO WS-HEX
     PERFORM FILL
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of a removed list cut short sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET
*>   a text value of 600 bytes does not fit PB-ISX-VALUE-MAX
     CALL "PB-RESET" USING PB-BUFFER
     MOVE "01 01 01 00 06 08 02 58" TO WS-HEX
     CALL "TEST-FILL-HEX" USING WS-HEX PB-BUFFER
     MOVE ALL "a" TO WS-BIG
     MOVE 600 TO WS-LEN
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-BIG WS-LEN
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE "test item-stack get of a 600-byte text value sets PB-ERROR, PB-POS 0" TO TL-CASE
     MOVE "c0 i0 pos 0 error 1" TO TL-EXPECTED
     PERFORM CHECK-GET.

*> Asserts TL-EXPECTED against "c<count> i<item>", the components and "pos <PB-POS> error <PB-ERROR>".
 CHECK-GET.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE PB-ISX-COUNT TO WS-EDIT
     STRING "c" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE PB-ISX-ITEM TO WS-EDIT
     STRING " i" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-ISX-ADDED-COUNT
         MOVE PB-ISX-TYPE(WS-J) TO WS-EDIT
         STRING " +" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
         MOVE PB-ISX-VALUE-LENGTH(WS-J) TO WS-LEN
         IF WS-LEN > 0
             STRING "=" FUNCTION LOWER-CASE(FUNCTION HEX-OF(PB-ISX-VALUE(WS-J)(1:WS-LEN)))
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-ISX-REMOVED-COUNT
         MOVE PB-ISX-REMOVED(WS-J) TO WS-EDIT
         STRING " -" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
     END-PERFORM
     MOVE PB-POS TO WS-EDIT
     STRING " pos " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE PB-ERROR TO WS-EDIT
     STRING " error " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The buffer's bytes (hex) against TL-EXPECTED; the buffer is emptied afterwards.
 CHECK-BYTES.
     MOVE "T" TO TL-MODE
     CALL "TEST-BUFFER-HEX" USING PB-BUFFER TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING PB-BUFFER.

*> PB-ERROR 1 and nothing appended.
 CHECK-PUT-ERROR.
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PB-ERROR * 10 + PB-LENGTH
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING PB-BUFFER.

 FILL.
     CALL "TEST-FILL-HEX" USING WS-HEX PB-BUFFER.
 END PROGRAM TEST-ITEM-STACK.
 COPY PROTOTEST.
