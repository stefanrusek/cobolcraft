*> Implementation test of DIMENSION-TYPE-NBT (core/src/registry-dimension.cob): the network NBT of a standard world's dimension_type entry,
*> built from the entry's JSON in the vanilla-data pack (04 section 6 dimension_type codec: has_fixed_time, has_skylight, has_ceiling and
*> has_ender_dragon_fight Byte, coordinate_scale Double, min_y, height, logical_height and monster_spawn_block_light_limit Int, infiniburn, skybox and
*> cardinal_light String, ambient_light Float, monster_spawn_light_level an Int or an int provider compound; attributes, timelines and the clock left out).
*> Before this the JSON bytes themselves were sent as the entry's data, so the client stopped reading the registry at its first entry and knew one dimension
*> type only (the Nether arrived with the overworld's sky). On the generated vanilla-data (CC_GENERATED_DIR, read only; skipped without the packs) the
*> Registry Data packet of the dimension types holds four compounds that read to the end, and the Nether has no sky light and the others have it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REGISTRY-DIMENSION-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY CONTENT.
 COPY SYNCREG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-BIG                 BINARY-LONG VALUE 65536.
 01 WS-JSON                PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-CAP                 BINARY-LONG VALUE 112.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LINE                PIC X(600).
 01 WS-D1                  PIC 9.
 01 WS-NUM                 PIC -(4)9.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SET-TYPE            BINARY-LONG.
 01 WS-REG                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-NAME-AREA           PIC X(112).
 01 WS-NAME-LEN            BINARY-LONG.
 01 WS-N                   PIC 9.
 01 WS-SKIES               PIC X(60).
 01 WS-PTR                 BINARY-LONG.
 01 WS-SKY                 PIC 9.
 01 WS-K                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-JSON
     STRING '{"ambient_light": 0.1, "attributes": {"minecraft:gameplay/fast_lava": true}, "cardinal_light": "nether",'
         ' "coordinate_scale": 8.0, "has_ceiling": true, "has_ender_dragon_fight": false, "has_fixed_time": true,'
         ' "has_skylight": false, "height": 256, "infiniburn": "#minecraft:infiniburn_nether", "logical_height": 128,'
         ' "min_y": 0, "monster_spawn_block_light_limit": 15, "monster_spawn_light_level": 7, "skybox": "none",'
         ' "timelines": "#minecraft:in_nether"}' DELIMITED BY SIZE INTO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "DIMENSION-TYPE-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS
     MOVE WS-STATUS TO WS-D1
     MOVE "dimension-nbt given a nether-like JSON when converted then the status is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE WS-D1 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DIM-READ" USING PB-BUFFER WS-LINE
     MOVE "dimension-nbt given a nether-like JSON when the NBT is read back then the Bytes, the Double, the Ints, the Float, the Int light level and "
         & "the three Strings are there and the attributes and timelines are not" TO TL-CASE
     MOVE "has_fixed_time=1 has_skylight=0 has_ceiling=1 has_ender_dragon_fight=0 scale=8.0 min_y=0 height=256 logical_height=128 monster_spawn_block_light_limit=15 "
         & "ambient=0.10 light=7 infiniburn=#minecraft:infiniburn_nether skybox=none cardinal_light=nether" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-LINE) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An overworld-like type: the light level is an int provider, no fixed time, no skybox and no cardinal light.
     MOVE SPACES TO WS-JSON
     STRING '{"ambient_light": 0.0, "coordinate_scale": 1.0, "has_ceiling": false, "has_ender_dragon_fight": false,'
         ' "has_skylight": true, "height": 384, "infiniburn": "#minecraft:infiniburn_overworld", "logical_height": 384,'
         ' "min_y": -64, "monster_spawn_block_light_limit": 0,'
         ' "monster_spawn_light_level": {"type": "minecraft:uniform", "max_inclusive": 7, "min_inclusive": 0}}'
         DELIMITED BY SIZE INTO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "DIMENSION-TYPE-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS
     CALL "TEST-DIM-READ" USING PB-BUFFER WS-LINE
     MOVE "dimension-nbt given an overworld-like JSON when read back then the light level is the compound of its provider, min_y is -64 and the "
         & "optional fields are not written" TO TL-CASE
     MOVE "has_skylight=1 has_ceiling=0 has_ender_dragon_fight=0 scale=1.0 min_y=-64 height=384 logical_height=384 monster_spawn_block_light_limit=0 ambient=0.00 "
         & "light=uniform 0..7 infiniburn=#minecraft:infiniburn_overworld" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-LINE) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An empty object: every member takes its default, the provider is written as the Int 0 and the optional Strings are left out.
     MOVE "{}" TO WS-JSON
     MOVE 2 TO WS-LENGTH
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "DIMENSION-TYPE-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS
     CALL "TEST-DIM-READ" USING PB-BUFFER WS-LINE
     MOVE "dimension-nbt given an empty object when read back then every member has its default" TO TL-CASE
     MOVE "has_skylight=0 has_ceiling=0 has_ender_dragon_fight=0 scale=1.0 min_y=0 height=0 logical_height=0 monster_spawn_block_light_limit=0 ambient=0.00 light=0"
         TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-LINE) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A provider with no members and a text that is no object.
     MOVE '{"monster_spawn_light_level": {}}' TO WS-JSON
     MOVE 33 TO WS-LENGTH
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "DIMENSION-TYPE-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS
     CALL "TEST-DIM-READ" USING PB-BUFFER WS-LINE
     MOVE "dimension-nbt given a provider object with no members when read back then its type is empty and both bounds are 0" TO TL-CASE
     MOVE "has_skylight=0 has_ceiling=0 has_ender_dragon_fight=0 scale=1.0 min_y=0 height=0 logical_height=0 monster_spawn_block_light_limit=0 ambient=0.00 light= 0..0"
         TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-LINE) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "[1, 2]" TO WS-JSON
     MOVE 6 TO WS-LENGTH
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "DIMENSION-TYPE-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS
     MOVE WS-STATUS TO WS-D1
     MOVE "dimension-nbt given text that is no JSON object when converted then the status is 1 and nothing is written" TO TL-CASE
     MOVE "1 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE PB-LENGTH TO WS-NUM
     STRING WS-D1 " " FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The packet of a standard set (the generated data): four entries, each a compound that reads to the end.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "dimension-nbt: no generated packs here, the real packet is skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-SET-TYPE
     CALL "CONTENT-OPEN" USING WS-SET-TYPE WS-DIR WS-STATUS
     MOVE 0 TO WS-REG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > REG-COUNT
         IF REG-NAME(WS-I) = "minecraft:dimension_type"
             COMPUTE WS-REG = WS-I - 1
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-BIG
     CALL "REGISTRY-PACKET-BUILD" USING WS-REG PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     MOVE SPACES TO WS-NAME-AREA
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-NAME-AREA WS-CAP WS-NAME-LEN
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     MOVE 0 TO WS-N
     MOVE SPACES TO WS-SKIES
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
         MOVE SPACES TO WS-NAME-AREA
         CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-NAME-AREA WS-CAP WS-NAME-LEN
         CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
         CALL "TEST-DIM-READ" USING PB-BUFFER WS-LINE
         IF PB-ERROR = 0 AND WS-PRESENT = 1
             ADD 1 TO WS-N
         END-IF
         MOVE 0 TO WS-K
         INSPECT WS-LINE TALLYING WS-K FOR CHARACTERS BEFORE INITIAL "has_skylight="
         MOVE WS-LINE(WS-K + 14:1) TO WS-SKY
         STRING WS-NAME-AREA(11:3) "=" WS-SKY " " DELIMITED BY SIZE INTO WS-SKIES WITH POINTER WS-PTR
     END-PERFORM
     MOVE WS-COUNT TO WS-NUM
     MOVE "registry-packet-build given the generated data when the dimension_type packet is read then it holds four entries that all read as "
         & "compounds to the end, and the sky light flag of each is the pack's (overworld, caves, end, nether: 1 1 1 0)" TO TL-CASE
     MOVE "id7 4 entries 4 read: ove=1 ove=1 the=1 the=0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-ID TO WS-D1
     STRING "id" WS-D1 " " FUNCTION TRIM(WS-NUM) " entries " WS-N " read: " FUNCTION TRIM(WS-SKIES) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-REGISTRY-DIMENSION-NBT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DIM-READ.
*> USING PB-BUFFER (a dimension type compound, read from its start), text out: each field noted as name=value (a provider compound as <type> <min>..<max>).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TYPE2               BINARY-LONG.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WN2                    PIC X(64).
 01 WL2                    BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-E                   PIC 9.99.
 01 WS-DE                  PIC 9.9.
 01 WS-INT-E               PIC -(9)9.
 01 WS-TEXT                PIC X(64).
 01 WS-SHORT               PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-LINE                 PIC X(600).
 PROCEDURE DIVISION USING PB-BUFFER L-LINE.
     MOVE SPACES TO L-LINE
     MOVE 1 TO WS-PTR
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL WS-TYPE = 0 OR PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAP WL
         EVALUATE TRUE
             WHEN WS-TYPE = 0
                 CONTINUE
             WHEN WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-VALUE
                 MOVE WS-VALUE TO WS-INT-E
                 STRING FUNCTION TRIM(WN) "=" FUNCTION TRIM(WS-INT-E) " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN WS-TYPE = 5
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
                 COMPUTE WS-E ROUNDED = WS-FLOAT
                 STRING "ambient=" WS-E " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN WS-TYPE = 6
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-DOUBLE
                 COMPUTE WS-DE ROUNDED = WS-DOUBLE
                 STRING "scale=" WS-DE " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN WS-TYPE = 3 AND WN = "monster_spawn_light_level"
                 CALL "PB-GET-INT" USING PB-BUFFER WS-VALUE
                 MOVE WS-VALUE TO WS-INT-E
                 STRING "light=" FUNCTION TRIM(WS-INT-E) " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-VALUE
                 MOVE WS-VALUE TO WS-INT-E
                 STRING FUNCTION TRIM(WN) "=" FUNCTION TRIM(WS-INT-E) " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN WS-TYPE = 8
                 MOVE SPACES TO WS-TEXT
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP WS-TEXT-LENGTH
                 STRING FUNCTION TRIM(WN) "=" FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN WS-TYPE = 10
                 MOVE SPACES TO WS-TEXT WS-SHORT
                 MOVE 1 TO WS-TYPE2
                 PERFORM UNTIL WS-TYPE2 = 0
                     MOVE SPACES TO WN2
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE2 WN2 WS-CAP WL2
                     EVALUATE TRUE
                         WHEN WS-TYPE2 = 8
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP WS-TEXT-LENGTH
                             MOVE WS-TEXT TO WS-SHORT
                             IF WS-TEXT(1:10) = "minecraft:"
                                 MOVE WS-TEXT(11:20) TO WS-SHORT
                             END-IF
                         WHEN WS-TYPE2 = 3 AND WN2(1:3) = "min"
                             CALL "PB-GET-INT" USING PB-BUFFER WS-MIN
                         WHEN WS-TYPE2 = 3
                             CALL "PB-GET-INT" USING PB-BUFFER WS-MAX
                     END-EVALUATE
                 END-PERFORM
                 MOVE WS-MIN TO WS-INT-E
                 STRING "light=" FUNCTION TRIM(WS-SHORT) " " FUNCTION TRIM(WS-INT-E) ".." DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
                 MOVE WS-MAX TO WS-INT-E
                 STRING FUNCTION TRIM(WS-INT-E) " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN OTHER
                 STRING "other:" FUNCTION TRIM(WN) " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-DIM-READ.
