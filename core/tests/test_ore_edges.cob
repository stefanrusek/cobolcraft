*> Edge-case test of the ores (T0432; docs/protocol/11 sections 6.5, 7.3): air exposure (a buried ore never touches air, an exposed
*> block keeps the rule) and a blob crossing the border of two chunks, placed identically from either chunk.
*> Block table of the test: air 0, stone 1, granite 2, diorite 3, andesite 4, tuff 5, deepslate 6, then the ores.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ORE-EDGES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CARVER.
 COPY ORE.
 COPY GENSTAGE.
 COPY GENSTEPS.
 COPY CLIMATE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-U64                 BINARY-DOUBLE UNSIGNED.
 01 WS-D                   BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-PEAK                BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-FLAG                BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-BIOME               PIC X(40).
 01 WS-F                   FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-DIAMOND-BAD         BINARY-LONG.
 01 WS-REF                 PIC X(304640).
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/terrain".
 01 WS-STATUS              BINARY-LONG.
 01 WS-EMERALDS            BINARY-LONG.
 01 WS-BNAME               PIC X(40).
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-MINS.
    05 WS-MINV             BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAXV             BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-BLOCKS.
    05 WS-B-KEY            PIC X(40) OCCURS 24 TIMES.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM BUILD-BLOCKS
     CALL "CARVER-SETUP" USING WS-SEED
     CALL "ORE-TABLE-BUILD"
*>   air exposure: a one block slab of stone has air above every block
     PERFORM MAKE-JOB
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-CELL = (40 + 64) * 256 + WS-I
         MOVE 1 TO CE-STATE(WS-CELL)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE 40 TO T-HM-OCEAN(WS-I)
     END-PERFORM
     MOVE "ore_diamond_buried" TO WS-NAME
     PERFORM FIND-ROW
     MOVE 8 TO WS-CX
     MOVE 40 TO WS-Y
     MOVE 8 TO WS-CZ
     MOVE 0 TO WS-U64
     CALL "WGR-SET-SEED" USING WS-XR WS-U64
     MOVE 0 TO OB-LIST
     CALL "ORE-PLACE-BLOB" USING WS-JOB WS-XR WS-ROW WS-CX WS-Y WS-CZ
     MOVE "acceptance US11-2 a buried ore (air 100) is never placed against air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE OB-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ore_iron_upper" TO WS-NAME
     PERFORM FIND-ROW
     CALL "WGR-SET-SEED" USING WS-XR WS-U64
     CALL "ORE-PLACE-BLOB" USING WS-JOB WS-XR WS-ROW WS-CX WS-Y WS-CZ
     MOVE "acceptance US11-2 an iron blob (air 0) is placed in the same slab" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF OB-PLACED >= 1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-CX
     MOVE 40 TO WS-Y
     MOVE 8 TO WS-CZ
     CALL "ORE-AIR-EXPOSED" USING WS-JOB WS-CX WS-Y WS-CZ WS-FLAG
     MOVE "acceptance US11-2 a block of the slab has air above it: exposed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB

*>   a blob on the border of two chunks: the positions the whole blob takes (list mode) split exactly into what each chunk takes
     MOVE "ore_iron_upper" TO WS-NAME
     PERFORM FIND-ROW
     MOVE 16 TO WS-CX
     MOVE 30 TO WS-Y
     MOVE 8 TO WS-CZ
     PERFORM MAKE-JOB
     PERFORM FILL-ALL-STONE
     MOVE 0 TO T-CX
     MOVE 0 TO WS-U64
     CALL "WGR-SET-SEED" USING WS-XR WS-U64
     MOVE 1 TO OB-LIST
     MOVE 0 TO OB-NPOS
     CALL "ORE-PLACE-BLOB" USING WS-JOB WS-XR WS-ROW WS-CX WS-Y WS-CZ
     MOVE 0 TO WS-LEFT
     MOVE 0 TO WS-RIGHT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OB-NPOS
         IF OB-POS-X(WS-I) < 16 AND OB-POS-X(WS-I) >= 0
             ADD 1 TO WS-LEFT
         END-IF
         IF OB-POS-X(WS-I) >= 16 AND OB-POS-X(WS-I) < 32
             ADD 1 TO WS-RIGHT
         END-IF
     END-PERFORM
     MOVE 0 TO OB-LIST
     CALL "WGR-SET-SEED" USING WS-XR WS-U64
     CALL "ORE-PLACE-BLOB" USING WS-JOB WS-XR WS-ROW WS-CX WS-Y WS-CZ
     MOVE "acceptance US11-2 border blob: chunk 0 takes exactly the positions of the whole blob with x below 16" TO TL-CASE
     MOVE WS-LEFT TO TL-EXPECTED-N
     MOVE OB-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     PERFORM MAKE-JOB
     PERFORM FILL-ALL-STONE
     MOVE 1 TO T-CX
     CALL "WGR-SET-SEED" USING WS-XR WS-U64
     CALL "ORE-PLACE-BLOB" USING WS-JOB WS-XR WS-ROW WS-CX WS-Y WS-CZ
     MOVE "acceptance US11-2 border blob: chunk 1 takes exactly the positions of the whole blob with x from 16" TO TL-CASE
     MOVE WS-RIGHT TO TL-EXPECTED-N
     MOVE OB-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US11-2 border blob: the blob has blocks on both sides" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-LEFT > 0 AND WS-RIGHT > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB

*>   a world without a seed (CARVER-SETUP not run) places nothing but still counts the step
     PERFORM MAKE-JOB
     PERFORM FILL-ALL-STONE
     MOVE 0 TO CV-READY
     INITIALIZE GEN-STAGES
     MOVE 5 TO T-SUB
     CALL "GEN-STAGE-ORES" USING WS-JOB
     MOVE "test ore edges without a world seed the ore step counts and changes nothing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE GS-ORE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CV-READY
     CALL "GEN-JOB-FREE" USING WS-JOB
     STOP RUN.

 FIND-ROW.
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OT-COUNT
         IF OT-NAME(WS-I) = WS-NAME
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM.


 ADD-BLOCK.
     ADD 1 TO CB-BLOCK-COUNT
     MOVE WS-NAME TO CB-KEY(CB-BLOCK-COUNT)
     MOVE 0 TO WS-K
     INSPECT WS-NAME TALLYING WS-K FOR CHARACTERS BEFORE INITIAL SPACE
     MOVE WS-K TO CB-KEY-LENGTH(CB-BLOCK-COUNT)
     MOVE WS-STATE TO CB-DEFAULT-STATE(CB-BLOCK-COUNT).

*> the block table: the six base blocks and, from state 101, the blocks the table of ores places (in the order of the paragraph)

 BUILD-BLOCKS.
     MOVE 0 TO CB-BLOCK-COUNT
     MOVE "minecraft:air" TO WS-NAME
     MOVE 0 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:stone" TO WS-NAME
     MOVE 1 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:granite" TO WS-NAME
     MOVE 2 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:diorite" TO WS-NAME
     MOVE 3 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:andesite" TO WS-NAME
     MOVE 4 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:tuff" TO WS-NAME
     MOVE 5 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate" TO WS-NAME
     MOVE 6 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:dirt" TO WS-NAME
     MOVE 101 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:gravel" TO WS-NAME
     MOVE 102 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:coal_ore" TO WS-NAME
     MOVE 103 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_coal_ore" TO WS-NAME
     MOVE 104 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:iron_ore" TO WS-NAME
     MOVE 105 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_iron_ore" TO WS-NAME
     MOVE 106 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:gold_ore" TO WS-NAME
     MOVE 107 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_gold_ore" TO WS-NAME
     MOVE 108 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:redstone_ore" TO WS-NAME
     MOVE 109 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_redstone_ore" TO WS-NAME
     MOVE 110 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:lapis_ore" TO WS-NAME
     MOVE 111 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_lapis_ore" TO WS-NAME
     MOVE 112 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:copper_ore" TO WS-NAME
     MOVE 113 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_copper_ore" TO WS-NAME
     MOVE 114 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:emerald_ore" TO WS-NAME
     MOVE 115 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_emerald_ore" TO WS-NAME
     MOVE 116 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:diamond_ore" TO WS-NAME
     MOVE 117 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_diamond_ore" TO WS-NAME
     MOVE 118 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:infested_stone" TO WS-NAME
     MOVE 119 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:infested_deepslate" TO WS-NAME
     MOVE 120 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:clay" TO WS-NAME
     MOVE 121 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE 0 TO CBI-COUNT.


 MAKE-JOB.
     INITIALIZE WS-JOB
     MOVE 1 TO T-ACTIVE
     MOVE 3 TO T-DIM
     MOVE 0 TO T-CX
     MOVE 0 TO T-CZ
     MOVE 0 TO T-AQ-READY
     MOVE LOW-VALUES TO T-CV
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING T-ADDR
     SET ADDRESS OF WS-A TO T-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE -65 TO T-HM-OCEAN(WS-I)
         MOVE -65 TO T-HM-SURFACE(WS-I)
     END-PERFORM.


 FILL-ALL-STONE.
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         MOVE 1 TO CE-STATE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE 100 TO T-HM-OCEAN(WS-I)
     END-PERFORM.


 END PROGRAM TEST-ORE-EDGES.
 COPY CORETEST.
