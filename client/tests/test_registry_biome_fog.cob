*> Implementation test of the water fog data of REGISTRY-READ (client/src/protocol-config.cob; 43 section 5: attributes minecraft:visual/water_fog_color
*> as a "#RRGGBB" String or an Int, minecraft:visual/water_fog_end_distance as a compound with the multiplier argument 0.85): TINT-BIOME-FOG keeps the
*> fog colour (TB-FOG) and the end multiplier (TB-FOG-END) of the biome under its registry index; a biome without the attributes has 0 for both.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REGISTRY-BIOME-FOG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CLTINT.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NAME                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-NEG2                BINARY-LONG VALUE -2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 3.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-KEY                 PIC X(40).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-INT-2               BINARY-LONG.
 01 WS-MUL                 PIC -9.99.
 01 WS-COL                 PIC Z(9)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:worldgen/biome" TO WS-NAME
     MOVE 24 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TWO
*>   Entry 1: minecraft:plains with no attributes. Entry 2: minecraft:swamp, a String fog colour and a multiplied end distance.
*>   Entry 3: minecraft:warm_ocean, an Int fog colour and an end distance as a bare compound without the argument.
     PERFORM VARYING WS-INT FROM 1 BY 1 UNTIL WS-INT > 3
         EVALUATE WS-INT
             WHEN 1
                 MOVE "minecraft:plains" TO WS-NAME
                 MOVE 16 TO WS-LEN
             WHEN 2
                 MOVE "minecraft:swamp" TO WS-NAME
                 MOVE 15 TO WS-LEN
             WHEN OTHER
                 MOVE "minecraft:warm_ocean" TO WS-NAME
                 MOVE 20 TO WS-LEN
         END-EVALUATE
         CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
         MOVE SPACE TO WS-KEY
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-NEG2
         IF WS-INT > 1
             MOVE "attributes" TO WS-KEY
             MOVE 10 TO WS-KEY-LENGTH
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEY-LENGTH
             MOVE "minecraft:visual/water_fog_color" TO WS-KEY
             MOVE 32 TO WS-KEY-LENGTH
             IF WS-INT = 2
                 MOVE "#112244" TO WS-TEXT
                 MOVE 7 TO WS-TEXT-LENGTH
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
             ELSE
                 MOVE 3820700 TO WS-INT-2
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT-2
             END-IF
             MOVE "minecraft:visual/sky_color" TO WS-KEY
             MOVE 26 TO WS-KEY-LENGTH
             MOVE "#78A7FF" TO WS-TEXT
             MOVE 7 TO WS-TEXT-LENGTH
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
             MOVE "minecraft:visual/water_fog_end_distance" TO WS-KEY
             MOVE 39 TO WS-KEY-LENGTH
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEY-LENGTH
             MOVE "modifier" TO WS-KEY
             MOVE 8 TO WS-KEY-LENGTH
             MOVE "multiply" TO WS-TEXT
             MOVE 8 TO WS-TEXT-LENGTH
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
             IF WS-INT = 2
                 MOVE "argument" TO WS-KEY
                 MOVE 8 TO WS-KEY-LENGTH
                 MOVE 0.85 TO WS-FLOAT
                 CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-FLOAT
             END-IF
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-PERFORM
     MOVE 0 TO PB-POS
     CALL "REGISTRY-READ" USING CLIENT-STATE PB-BUFFER

     MOVE "T" TO TL-MODE
     MOVE "registry biome fog plains: no attributes, no fog colour and no end multiplier" TO TL-CASE
     MOVE "0  0.00" TO TL-EXPECTED
     MOVE TB-FOG-END(1) TO WS-MUL
     MOVE SPACES TO TL-OBSERVED
     MOVE TB-FOG(1) TO WS-COL
     STRING FUNCTION TRIM(WS-COL) " " WS-MUL DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "registry biome fog swamp: the String colour #112244 (opaque) and the end multiplier 0.85" TO TL-CASE
     MOVE "4279312964  0.85" TO TL-EXPECTED
     MOVE TB-FOG-END(2) TO WS-MUL
     MOVE SPACES TO TL-OBSERVED
     MOVE TB-FOG(2) TO WS-COL
     STRING FUNCTION TRIM(WS-COL) " " WS-MUL DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "registry biome fog warm ocean: the Int colour as written (3820700, no alpha: the low 24 bits are the colour), an end distance without an argument leaves the multiplier unset" TO TL-CASE
     MOVE "3820700  0.00" TO TL-EXPECTED
     MOVE TB-FOG-END(3) TO WS-MUL
     MOVE SPACES TO TL-OBSERVED
     MOVE TB-FOG(3) TO WS-COL
     STRING FUNCTION TRIM(WS-COL) " " WS-MUL DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-REGISTRY-BIOME-FOG.
 COPY CLTEST.
