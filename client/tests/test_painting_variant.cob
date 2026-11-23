*> Implementation test of REGISTRY-READ for minecraft:painting_variant (T51207, docs/protocol/34-9 section 11, 04 section 6): every
*> entry's width and height (Int) and asset_id (String) are kept in RG-PAINT under its registry index + 1; the title and author
*> compounds are skipped; an entry sent without data stays 0 x 0 with no asset; a second packet replaces the first; the fixture
*> of the cobolcraft stand-in set (one placeholder entry) is read through a connection like any Registry Data.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PAINTING-VARIANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-NAME                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-NEG2                BINARY-LONG VALUE -2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-INT                 BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:painting_variant" TO WS-NAME
     MOVE 26 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-THREE
*>   Entry 0: kebab 1 x 1 with a title compound after the asset (skipped).
     MOVE "minecraft:kebab" TO WS-NAME
     MOVE 15 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
     MOVE SPACE TO WS-KEY
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-NEG2
     MOVE "width" TO WS-KEY
     MOVE 5 TO WS-KEY-LENGTH
     MOVE 1 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT
     MOVE "height" TO WS-KEY
     MOVE 6 TO WS-KEY-LENGTH
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT
     MOVE "asset_id" TO WS-KEY
     MOVE 8 TO WS-KEY-LENGTH
     MOVE "minecraft:kebab" TO WS-TEXT
     MOVE 15 TO WS-TEXT-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
     MOVE "title" TO WS-KEY
     MOVE 5 TO WS-KEY-LENGTH
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEY-LENGTH
     MOVE "text" TO WS-KEY
     MOVE 4 TO WS-KEY-LENGTH
     MOVE "Kebab" TO WS-TEXT
     MOVE 5 TO WS-TEXT-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
*>   Entry 1: pointer 4 x 3, the asset first and an unknown Int field in between.
     MOVE "minecraft:pointer" TO WS-NAME
     MOVE 17 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
     MOVE SPACE TO WS-KEY
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-NEG2
     MOVE "asset_id" TO WS-KEY
     MOVE 8 TO WS-KEY-LENGTH
     MOVE "minecraft:pointer" TO WS-TEXT
     MOVE 17 TO WS-TEXT-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
     MOVE "other" TO WS-KEY
     MOVE 5 TO WS-KEY-LENGTH
     MOVE 99 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT
     MOVE "width" TO WS-KEY
     MOVE 5 TO WS-KEY-LENGTH
     MOVE 4 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT
     MOVE "height" TO WS-KEY
     MOVE 6 TO WS-KEY-LENGTH
     MOVE 3 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
*>   Entry 2: sent without data.
     MOVE "minecraft:aztec2" TO WS-NAME
     MOVE 16 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "REGISTRY-READ" USING CLIENT-STATE PB-BUFFER

     MOVE "T" TO TL-MODE
     MOVE "painting variant: the packet keeps three entries" TO TL-CASE
     MOVE "3" TO TL-EXPECTED
     MOVE RG-PAINT-COUNT TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "painting variant: entry 0 is kebab, 1 x 1, the title compound after the asset skipped" TO TL-CASE
     MOVE "1 1 minecraft:kebab" TO TL-EXPECTED
     MOVE 1 TO WS-IDX
     PERFORM SHOW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "painting variant: entry 1 is pointer, 4 x 3, with the asset first and an unknown field between" TO TL-CASE
     MOVE "4 3 minecraft:pointer" TO TL-EXPECTED
     MOVE 2 TO WS-IDX
     PERFORM SHOW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "painting variant: entry 2 sent without data stays 0 x 0 with no asset" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     MOVE 3 TO WS-IDX
     PERFORM SHOW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The fixture of the stand-in set replaces the table: one entry, placeholder 1 x 1.
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-painting-variant.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "painting variant: the stand-in fixture replaces the table with its one placeholder entry" TO TL-CASE
     MOVE "1 1 1 cobolcraft:placeholder" TO TL-EXPECTED
     MOVE RG-PAINT-COUNT TO WS-E1
     MOVE RG-PAINT-W(1) TO WS-E2
     MOVE RG-PAINT-H(1) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
         FUNCTION TRIM(RG-PAINT-ASSET(1)) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 SHOW.
     MOVE RG-PAINT-W(WS-IDX) TO WS-E1
     MOVE RG-PAINT-H(WS-IDX) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     IF RG-PAINT-ASSET(WS-IDX) = SPACES
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(RG-PAINT-ASSET(WS-IDX))
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.
 END PROGRAM TEST-PAINTING-VARIANT.
 COPY CLTEST.
