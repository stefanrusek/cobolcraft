*> Namespace audit: the rows of a standard (vanilla) world's block, item and entity tables have NO "minecraft:" prefix ("sand", "wheat",
*> "diamond", "zombie"); the rules of the core name them "minecraft:<name>" (docs/protocol). Every case runs against the REAL standard tables
*> (TEST-STANDARD-TABLES), never keys the test made up: key helpers, falling blocks (CC-0008: sand, gravel, concrete powder and anvils fall when
*> the support under them goes), crops and saplings, bone meal, underwater mining, the crafting bench, fire-proof items, the feature level's block
*> classes, the entity and item ids a saved world holds, and the type= selector.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NS-AUDIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BUSTATE.
 COPY FEATLEVEL.
 COPY ETIDS.
 COPY PROTO.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-OP-NAME             PIC X(16) VALUE "Opal".
 01 WS-OP-LENGTH           BINARY-LONG VALUE 4.
 01 WS-DISCARD             PIC X(4096).
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-A                   PIC X(48).
 01 WS-B                   PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-NULL                USAGE POINTER.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-B              BINARY-LONG VALUE 0.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-NBT-TEXT            PIC X(8192).
 01 WS-X-F                 FLOAT-LONG.
 01 WS-Y-F                 FLOAT-LONG.
 01 WS-Z-F                 FLOAT-LONG.
 01 WS-ZV                  FLOAT-LONG VALUE 0.
 01 WS-ZV2                 FLOAT-LONG VALUE 0.
 01 WS-ZV3                 FLOAT-LONG VALUE 0.
 01 WS-GROUND              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-TABLE.
    05 FILLER              PIC X(32) VALUE "sand".
    05 FILLER              PIC X(32) VALUE "red_sand".
    05 FILLER              PIC X(32) VALUE "gravel".
    05 FILLER              PIC X(32) VALUE "white_concrete_powder".
    05 FILLER              PIC X(32) VALUE "anvil".
    05 FILLER              PIC X(32) VALUE "chipped_anvil".
 01 WS-FALLERS REDEFINES WS-TABLE.
    05 WS-FALLER           PIC X(32) OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     CALL "GB-RULES-OPEN"
     MOVE "T" TO TL-MODE

*>   The helpers.
     MOVE "ns audit KEY-SAME takes minecraft:water and water as one key, stone and minecraft:stone_bricks as two" TO TL-CASE
     MOVE "minecraft:water" TO WS-A
     MOVE "water" TO WS-B
     CALL "KEY-SAME" USING WS-A WS-B WS-FLAG
     MOVE WS-FLAG TO WS-E1
     MOVE "stone" TO WS-A
     MOVE "minecraft:stone_bricks" TO WS-B
     CALL "KEY-SAME" USING WS-A WS-B WS-FLAG
     MOVE WS-FLAG TO WS-E2
     MOVE SPACES TO WS-A WS-B
     CALL "KEY-SAME" USING WS-A WS-B WS-FLAG
     MOVE WS-FLAG TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "ns audit KEY-NAMESPACED and KEY-BARE: dirt to minecraft:dirt, cobolcraft:loam stays, minecraft:dirt to dirt" TO TL-CASE
     MOVE "dirt" TO WS-A
     CALL "KEY-NAMESPACED" USING WS-A WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-B) "," DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "cobolcraft:loam" TO WS-A
     CALL "KEY-NAMESPACED" USING WS-A WS-B
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-B) "," DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "minecraft:dirt" TO WS-A
     CALL "KEY-BARE" USING WS-A WS-B
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-B) "," DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "cobolcraft:loam" TO WS-A
     CALL "KEY-BARE" USING WS-A WS-B
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "minecraft:dirt,cobolcraft:loam,dirt,cobolcraft:loam" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   29b 1.3: the block-name table and the growth blocks.
     MOVE "ns audit GB-PART finds the falling blocks and GB-GROWTH-KIND the crops and saplings by the standard set's keys (sand, anvil, white_concrete_powder, wheat, oak_sapling)"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "sand" TO WS-A
     CALL "GB-PART" USING WS-A WS-PART WS-SECTION
     MOVE WS-SECTION TO WS-E1
     MOVE "anvil" TO WS-A
     CALL "GB-PART" USING WS-A WS-PART WS-SECTION
     MOVE WS-SECTION TO WS-E2
     MOVE "white_concrete_powder" TO WS-A
     CALL "GB-PART" USING WS-A WS-PART WS-SECTION
     MOVE WS-SECTION TO WS-E3
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "wheat" TO WS-A
     CALL "GB-GROWTH-KIND" USING WS-A WS-KIND
     MOVE WS-KIND TO WS-E1
     MOVE "oak_sapling" TO WS-A
     CALL "GB-GROWTH-KIND" USING WS-A WS-KIND
     MOVE WS-KIND TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "32 34 33 1 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "ns audit GB-RULES-OPEN registers a fall tick for sand, an anvil and a concrete powder, and a random tick for wheat, of the standard table"
         TO TL-CASE
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-KEY
         MOVE WS-FALLER(WS-I) TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-ROW WS-STATUS
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > BU-RULE-COUNT
             IF BU-R-KIND(WS-N) = 7 AND BU-R-BLOCK(WS-N) = WS-BLOCK-ID AND BU-R-EFFECT(WS-N) = 6
                 ADD 1 TO WS-HITS
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "wheat" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-ROW WS-STATUS
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > BU-RULE-COUNT
         IF BU-R-KIND(WS-N) = 8 AND BU-R-BLOCK(WS-N) = WS-BLOCK-ID AND BU-R-EFFECT(WS-N) = 7
             ADD 10 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE WS-HITS TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "ns audit GB-HELD-BONEMEAL knows the standard bone_meal item and not the bone" TO TL-CASE
     MOVE "bone_meal" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROW WS-STATUS
     CALL "GB-HELD-BONEMEAL" USING WS-ITEM WS-FLAG
     MOVE WS-FLAG TO WS-E1
     MOVE "bone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROW WS-STATUS
     CALL "GB-HELD-BONEMEAL" USING WS-ITEM WS-FLAG
     MOVE WS-FLAG TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Gravity (CC-0008): each falling block of the standard set, placed above a stone block in the air, falls onto it; when the stone is removed it falls on.
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-BLOCK-ID WS-STONE WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-KEY
         MOVE WS-FALLER(WS-I) TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-ROW WS-STATUS
         CALL "CONTENT-STATE-DEFAULT" USING WS-BLOCK-ID WS-STATE WS-STATUS
         COMPUTE WS-X = 10 + WS-I
         MOVE 12 TO WS-Z
         MOVE 200 TO WS-Y
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
         MOVE 210 TO WS-Y
         CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         MOVE 4 TO WS-TICKS
         CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
         CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-N
         MOVE WS-N TO WS-E1
         MOVE 201 TO WS-Y
         CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-N
         MOVE WS-N TO WS-E2
         MOVE SPACES TO TL-OBSERVED TL-EXPECTED TL-CASE
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE WS-STATE TO WS-E2
         STRING "0 " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
         STRING "ns audit gravity " FUNCTION TRIM(WS-KEY) " placed in the air falls onto the block under it and leaves the air" DELIMITED BY SIZE
             INTO TL-CASE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>       The support goes: the block falls on (it was a stone block above ground; the cell it stood in is air).
         MOVE 200 TO WS-Y
         MOVE 0 TO WS-N
         CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-N
         MOVE 8 TO WS-TICKS
         CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
         MOVE 201 TO WS-Y
         CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-N
         MOVE WS-N TO WS-E1
         MOVE SPACES TO TL-OBSERVED TL-CASE
         MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
         STRING "ns audit gravity " FUNCTION TRIM(WS-KEY) " resting on a block that is broken falls (the cell it rested in is air)" DELIMITED BY SIZE
             INTO TL-CASE
         MOVE "0" TO TL-EXPECTED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   A column: two sand blocks fall together when the support under the lower one is broken.
*>   Underwater mining reads the block as water.
     MOVE "ns audit TOOL-IS-WATER takes the standard set's water key (water), minecraft:water, and nothing else" TO TL-CASE
     MOVE "water" TO WS-A
     CALL "TOOL-IS-WATER" USING WS-A WS-FLAG
     MOVE WS-FLAG TO WS-E1
     MOVE "minecraft:water" TO WS-A
     CALL "TOOL-IS-WATER" USING WS-A WS-FLAG
     MOVE WS-FLAG TO WS-E2
     MOVE "water_cauldron" TO WS-A
     CALL "TOOL-IS-WATER" USING WS-A WS-FLAG
     MOVE WS-FLAG TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "ns audit MENU-IS-BENCH opens for the standard crafting_table and not for a furnace" TO TL-CASE
     MOVE "crafting_table" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-BLOCK-ID WS-STATE WS-STATUS
     CALL "MENU-IS-BENCH" USING WS-STATE WS-FLAG
     MOVE WS-FLAG TO WS-E1
     MOVE "furnace" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-BLOCK-ID WS-STATE WS-STATUS
     CALL "MENU-IS-BENCH" USING WS-STATE WS-FLAG
     MOVE WS-FLAG TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "ns audit IP-RESISTANT: a netherite ingot survives fire, a nether star survives explosions, a diamond neither (standard item keys)" TO TL-CASE
     MOVE "netherite_ingot" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROW WS-STATUS
     MOVE 1 TO WS-KIND
     CALL "IP-RESISTANT" USING WS-ITEM WS-KIND WS-FLAG
     MOVE WS-FLAG TO WS-E1
     MOVE "nether_star" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROW WS-STATUS
     MOVE 9 TO WS-KIND
     CALL "IP-RESISTANT" USING WS-ITEM WS-KIND WS-FLAG
     MOVE WS-FLAG TO WS-E2
     MOVE "diamond" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROW WS-STATUS
     MOVE 1 TO WS-KIND
     CALL "IP-RESISTANT" USING WS-ITEM WS-KIND WS-FLAG
     MOVE WS-FLAG TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "ns audit FL-OPEN resolves air, cave air, void air, water, lava and bedrock of the standard table" TO TL-CASE
     SET WS-NULL TO NULL
     MOVE 0 TO FL-EPOCH
     CALL "FL-OPEN" USING WS-NULL WS-ZERO WS-ZERO-B WS-MIN WS-HEIGHT WS-SEA
     MOVE 0 TO WS-HITS
     IF FL-B-AIR > 0 AND FL-B-CAVE-AIR > 0 AND FL-B-VOID-AIR > 0
         ADD 1 TO WS-HITS
     END-IF
     IF FL-B-WATER > 0 AND FL-B-LAVA > 0 AND FL-B-BEDROCK > 0
         ADD 10 TO WS-HITS
     END-IF
     CALL "FL-CLOSE"
     MOVE WS-HITS TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "11" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Saved worlds hold "minecraft:" + path.
     MOVE "ns audit a saved ground item holds the id minecraft:diamond (not diamond) and reads back as the diamond item" TO TL-CASE
     MOVE "diamond" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROW WS-STATUS
     MOVE 40.5 TO WS-X-F
     MOVE 90 TO WS-Y-F
     MOVE 40.5 TO WS-Z-F
     CALL "GI-SPAWN" USING WS-DIM WS-X-F WS-Y-F WS-Z-F WS-ZV WS-ZV2 WS-ZV3 WS-ITEM WS-COUNT WS-DELAY WS-GROUND
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 2 TO WS-X
     MOVE 2 TO WS-Z
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-X WS-Z PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-NBT-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-NBT-TEXT TALLYING WS-HITS FOR ALL "Item:{id:minecraft:diamond,count:3}"
     MOVE WS-HITS TO WS-E1
     CALL "ENTITY-REMOVE" USING WS-GROUND
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-ITEM
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER

*>   The selector's type= and the roles.
     MOVE "ns audit the roles of the standard set (player, item) and the standard mob table are found by their keys" TO TL-CASE
     MOVE 0 TO WS-HITS
     IF CR-OPERATOR >= 0
         ADD 1 TO WS-HITS
     END-IF
     IF CR-LOOSE-ITEM >= 0
         ADD 10 TO WS-HITS
     END-IF
     MOVE WS-HITS TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "11" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-JOIN-OP" USING WS-OP-NAME WS-OP-LENGTH WS-OP
     CALL "TEST-DRAIN-CHAT" USING WS-OP WS-DISCARD
     MOVE "ns audit @e[type=minecraft:zombie] and @e[type=zombie] are known entity types of the standard set (no type.invalid error)" TO TL-CASE
     MOVE "execute if entity @e[type=minecraft:zombie]" TO WS-LINE
     CALL "TEST-RUN" USING WS-OP WS-LINE WS-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "type.invalid"
     MOVE WS-HITS TO WS-E1
     MOVE "execute if entity @e[type=zombie]" TO WS-LINE
     CALL "TEST-RUN" USING WS-OP WS-LINE WS-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "type.invalid"
     MOVE WS-HITS TO WS-E2
     MOVE "execute if entity @e[type=minecraft:nonesuch]" TO WS-LINE
     CALL "TEST-RUN" USING WS-OP WS-LINE WS-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "type.invalid"
     MOVE WS-HITS TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "ns audit @e[type=minecraft:item] counts the two ground items, @e[type=!minecraft:item] the two players, and summon names a standard mob minecraft:zombie"
         TO TL-CASE
     MOVE 40.5 TO WS-X-F
     MOVE 90 TO WS-Y-F
     MOVE 40.5 TO WS-Z-F
     CALL "GI-SPAWN" USING WS-DIM WS-X-F WS-Y-F WS-Z-F WS-ZV WS-ZV2 WS-ZV3 WS-ITEM WS-COUNT WS-DELAY WS-GROUND
     MOVE SPACES TO TL-OBSERVED
     MOVE "execute if entity @e[type=minecraft:item]" TO WS-LINE
     CALL "TEST-RUN" USING WS-OP WS-LINE WS-TEXT
     STRING FUNCTION TRIM(WS-TEXT) "," DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "execute if entity @e[type=!minecraft:item]" TO WS-LINE
     CALL "TEST-RUN" USING WS-OP WS-LINE WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-TEXT) "," DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "summon zombie 5.0 70.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-OP WS-LINE WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "commands.execute.conditional.pass_count(2),commands.execute.conditional.pass_count(2),entity.not_summonable(minecraft:zombie)"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-NS-AUDIT.

 COPY CORETEST.
 COPY CMDTEST.
