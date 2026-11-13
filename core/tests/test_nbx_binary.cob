*> Implementation test of the conversion between the NBT value tree and binary NBT (core/src/nbx-binary.cob): the entries of a compound written to a PB-BUFFER as named tags
*> (07 §1) and read back, and a buffer written with the proto NBT writers read into a tree. Arrays are cut at 256 elements and a list whose elements differ in type is written with the type of
*> its first element (gaps: the mixed-list wrapper of 07 §1.1 is not produced).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NBX-BINARY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY NBXTREE.
 01 WS-CASE                PIC X(240).
 01 WS-IN                  PIC X(256).
 01 WS-OUT                 PIC X(256).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-T-INT               BINARY-LONG VALUE 3.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 01 WS-CAP32               BINARY-LONG VALUE 32.
 01 WS-TEXT                PIC X(16).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "binary: every tag type survives a write and a read" TO WS-CASE
     MOVE '{b:-3b,s:300s,i:70000,l:5000000000L,f:1.5f,d:2.25d,str:"hi there",ba:[B;1b,-2b,127b],ia:[I;1,-2,3],la:[L;1L,-2L],li:[1,2,3],lc:[{x:1},{y:"z"}],e:[],c:{a:{b:{}}}}' TO WS-IN
     MOVE '{b:-3b,s:300s,i:70000,l:5000000000L,f:1.5f,d:2.25d,str:"hi there",ba:[B;1B,-2B,127B],ia:[I;1,-2,3],la:[L;1L,-2L],li:[1,2,3],lc:[{x:1},{y:"z"}],e:[],c:{a:{b:{}}}}' TO WS-OUT
     CALL "TS-PARSE" USING WS-IN WS-A
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBX-TO-BUFFER" USING PB-BUFFER WS-A
     MOVE 0 TO PB-POS
     CALL "NBX-FROM-BUFFER" USING PB-BUFFER WS-B
     CALL "TS-SHOW" USING WS-CASE WS-B WS-OUT
     CALL "PB-FREE" USING PB-BUFFER
     CALL "NBX-FREE" USING WS-A
     CALL "NBX-FREE" USING WS-B
     MOVE "binary: a buffer of the proto writers, with an End tag, reads into a tree" TO WS-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "n" TO WN
     MOVE 1 TO WL
     MOVE 42 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "p" TO WN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "t" TO WN
     MOVE "abc" TO WS-TEXT
     MOVE 3 TO WS-TEXT-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBX-FROM-BUFFER" USING PB-BUFFER WS-B
     MOVE '{n:42,p:{t:"abc"}}' TO WS-OUT
     CALL "TS-SHOW" USING WS-CASE WS-B WS-OUT
     CALL "PB-FREE" USING PB-BUFFER
     CALL "NBX-FREE" USING WS-B
     MOVE "binary: a tree written by NBX-TO-BUFFER reads with the proto reader" TO WS-CASE
     MOVE '{k:7}' TO WS-IN
     CALL "TS-PARSE" USING WS-IN WS-A
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBX-TO-BUFFER" USING PB-BUFFER WS-A
     MOVE 0 TO PB-POS
     MOVE SPACES TO WN
     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INT WN WS-CAP32 WL
     MOVE WS-INT TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-CASE TO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     CALL "NBX-FREE" USING WS-A
     GOBACK.
 END PROGRAM TEST-NBX-BINARY.

 COPY CORETEST.
 COPY CMDTEST.
 COPY NBXTEST.
