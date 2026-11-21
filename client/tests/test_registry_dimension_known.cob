*> Implementation test of REGISTRY-READ for dimension_type entries sent without data (a standard world: the
*> server names the vanilla entries of the known pack and sends no NBT, docs/protocol/04 section 3.2): the
*> client takes the height range and sky light of the vanilla dimension types (overworld and overworld_caves
*> min_y -64, height 384; the_nether and the_end min_y 0, height 256; sky light on except the nether). Before
*> this the entries stayed 0 high, DIMENSION-ENTER gave the replica 0 sections, no chunk was kept and the
*> player fell forever. An entry that carries data keeps the data's values.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REGISTRY-DIMENSION-KNOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NAME                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-NEG2                BINARY-LONG VALUE -2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-INT                 BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:dimension_type" TO WS-NAME
     MOVE 24 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FOUR
     MOVE "minecraft:overworld" TO WS-NAME
     MOVE 19 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     MOVE "minecraft:the_nether" TO WS-NAME
     MOVE 20 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     MOVE "minecraft:the_end" TO WS-NAME
     MOVE 17 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     MOVE "cobolcraft:surface" TO WS-NAME
     MOVE 18 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
     MOVE SPACE TO WS-KEY
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-NEG2
     MOVE "min_y" TO WS-KEY
     MOVE 5 TO WS-KEY-LENGTH
     MOVE 16 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT
     MOVE "height" TO WS-KEY
     MOVE 6 TO WS-KEY-LENGTH
     MOVE 32 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "REGISTRY-READ" USING CLIENT-STATE PB-BUFFER

     MOVE "registry dimension known: overworld without data is -64 / 384 with sky light" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "-64 384 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-IDX
     PERFORM SHOW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "registry dimension known: the nether without data is 0 / 256 without sky light" TO TL-CASE
     MOVE "0 256 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 2 TO WS-IDX
     PERFORM SHOW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "registry dimension known: the end without data is 0 / 256 with sky light" TO TL-CASE
     MOVE "0 256 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 3 TO WS-IDX
     PERFORM SHOW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "registry dimension known: an entry with data keeps its own values" TO TL-CASE
     MOVE "16 32 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 4 TO WS-IDX
     PERFORM SHOW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 SHOW.
     MOVE RG-DIM-MIN-Y(WS-IDX) TO WS-E1
     MOVE RG-DIM-HEIGHT(WS-IDX) TO WS-E2
     MOVE RG-DIM-HAS-SKY(WS-IDX) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM TEST-REGISTRY-DIMENSION-KNOWN.
 COPY CLTEST.
