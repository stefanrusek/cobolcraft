*> Implementation test (T0323; docs/protocol/06 §2 to §7, contract fixture
*> play-s2c-2e-level-chunk-with-light-standard-24-sections.hex): the chunk packet the core builds for a
*> standard overworld column (dimension row 3, min y -64, 24 sections) loads through PB-GET-CHUNK-24 and
*> carries the fixture's block states, biomes, block entities and every light array. (The fixture's own
*> non-empty count of section 9 is 4096 although one of its cells is state 0: counts are asserted against the states.)
*> The fixture is a synthetic codec example: its three heightmaps say 128 for every column although its
*> states reach the top of section 18, and some light sections are "none" where a core packet says
*> "empty"; so the heightmap is asserted against an independent scan of the states (value = top + 1 - min y)
*> and light states are asserted only where the fixture has an array.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHUNKS-STREAM24.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY PROTO.
 COPY CHUNK24TAB.
 COPY CHUNK24TAB REPLACING LEADING ==CH-== BY ==GT-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-PATH                PIC X(256).
 01 WS-BYTE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-NONEMPTY            BINARY-LONG.
 01 WS-MIN-EDIT            PIC -(9)9.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-HEIGHT-EDIT         PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-standard-24-sections.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-BYTE
     CALL "PB-GET-CHUNK-24" USING PB-BUFFER CH-X CH-Z CH-SECTIONS CH-HM-BITS CH-HM-MASK CH-HM-VALUES
         CH-COUNTS CH-STATES CH-BIOMES CH-BLOCK-GBITS CH-BIOME-GBITS CH-BE-MAX CH-BE-DATA-MAX
         CH-BE-COUNT CH-BE-HEADS CH-BE-DATA CH-SKY-STATES CH-SKY-ARRAYS CH-BLK-STATES
         CH-BLK-ARRAYS

     MOVE "T" TO TL-MODE
     MOVE "test chunks stream24 dimension row 3 is the standard overworld with 24 sections" TO TL-CASE
     MOVE "minecraft:overworld -64 384" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE DM-KEY-LENGTH(3) TO WS-J
     MOVE DM-MIN-Y(3) TO WS-MIN-EDIT
     MOVE DM-HEIGHT(3) TO WS-HEIGHT-EDIT
     STRING DM-KEY(3)(1:WS-J) " " FUNCTION TRIM(WS-MIN-EDIT) " " FUNCTION TRIM(WS-HEIGHT-EDIT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Load the fixture into the cache chunk of (0, 0) in dimension 3.
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         MOVE CH-STATE(WS-I) TO CE-STATE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         MOVE CH-BIOME(WS-I) TO CE-BIOME(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 26
         COMPUTE WS-J = (WS-I - 1) * 2048 + 1
         IF CH-SKY-STATE(WS-I) = 2
             MOVE CH-SKY-ARRAY(WS-I) TO CE-SKYS(WS-J:2048)
         END-IF
         IF CH-BLK-STATE(WS-I) = 2
             MOVE CH-BLK-ARRAY(WS-I) TO CE-BLOCK-LIGHTS(WS-J:2048)
         END-IF
     END-PERFORM
     MOVE 1 TO CK-LIT(WS-ROW)

     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-PACKET-BUILD" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-BYTE
     CALL "PB-GET-CHUNK-24" USING PB-BUFFER GT-X GT-Z GT-SECTIONS GT-HM-BITS GT-HM-MASK GT-HM-VALUES
         GT-COUNTS GT-STATES GT-BIOMES GT-BLOCK-GBITS GT-BIOME-GBITS GT-BE-MAX GT-BE-DATA-MAX
         GT-BE-COUNT GT-BE-HEADS GT-BE-DATA GT-SKY-STATES GT-SKY-ARRAYS GT-BLK-STATES
         GT-BLK-ARRAYS
     MOVE "test chunks stream24 the packet id is 46 and it decodes with no error and no byte left" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-BYTE TO WS-E1
     MOVE PB-ERROR TO WS-E2
     MOVE PB-POS TO WS-E3
     MOVE PB-LENGTH TO WS-E4
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "46 0 " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test chunks stream24 chunk x and z and the block entity count" TO TL-CASE
     MOVE "0 0 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE GT-X TO WS-E1
     MOVE GT-Z TO WS-E2
     MOVE GT-BE-COUNT TO WS-E3
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "N" TO TL-MODE
     MOVE "test chunks stream24 all 98304 block states equal the fixture" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         IF GT-STATE(WS-I) NOT = CH-STATE(WS-I)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test chunks stream24 all 1536 biomes equal the fixture" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         IF GT-BIOME(WS-I) NOT = CH-BIOME(WS-I)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test chunks stream24 the 24 non-empty counts are the states other than 0 per section, no fluid"
         TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         MOVE 0 TO WS-NONEMPTY
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4096
             IF CH-STATE((WS-I - 1) * 4096 + WS-J) NOT = 0
                 ADD 1 TO WS-NONEMPTY
             END-IF
         END-PERFORM
         IF GT-COUNT-ENTRY(WS-I * 2 - 1) NOT = WS-NONEMPTY OR GT-COUNT-ENTRY(WS-I * 2) NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test chunks stream24 every light array the fixture holds is in the packet unchanged" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 26
         IF CH-SKY-STATE(WS-I) = 2
             IF GT-SKY-STATE(WS-I) NOT = 2 OR GT-SKY-ARRAY(WS-I) NOT = CH-SKY-ARRAY(WS-I)
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
         IF CH-BLK-STATE(WS-I) = 2
             IF GT-BLK-STATE(WS-I) NOT = 2 OR GT-BLK-ARRAY(WS-I) NOT = CH-BLK-ARRAY(WS-I)
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test chunks stream24 heightmaps 1, 4 and 5 (mask 50) hold top + 1 - min y of each column"
         TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE 383 TO WS-TOP
         COMPUTE WS-CELL = WS-TOP * 256 + WS-I
         PERFORM UNTIL WS-TOP < 0 OR CH-STATE(WS-CELL) NOT = 0
             SUBTRACT 1 FROM WS-TOP
             COMPUTE WS-CELL = WS-TOP * 256 + WS-I
         END-PERFORM
         COMPUTE WS-SECTION = WS-TOP + 1
         IF GT-HM(256 + WS-I) NOT = WS-SECTION OR GT-HM(1024 + WS-I) NOT = WS-SECTION
                 OR GT-HM(1280 + WS-I) NOT = WS-SECTION
                 OR GT-HM(WS-I) NOT = 0 OR GT-HM(512 + WS-I) NOT = 0 OR GT-HM(768 + WS-I) NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CHUNKS-STREAM24.

 COPY CORETEST.
