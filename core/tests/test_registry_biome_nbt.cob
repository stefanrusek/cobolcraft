*> Implementation test of BIOME-NBT (core/src/registry-biome.cob): the network NBT of a standard world's worldgen/biome
*> entry, built from the entry's JSON in the vanilla-data pack (04 section 6 biome codec: has_precipitation Byte,
*> temperature and downfall Float, effects with the four colours as the pack gives them and grass_color_modifier,
*> the visual attributes; generation settings, spawns and sounds left out). Before this the JSON bytes themselves were
*> sent as the entry's data and the client stopped reading the registry at the first biome.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REGISTRY-BIOME-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY CONTENT.
 COPY SYNCREG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-JSON                PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TYPE2               BINARY-LONG.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WN2                    PIC X(64).
 01 WL2                    BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-E                   PIC 9.99.
 01 WS-D1                  PIC 9.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(400).
 01 WS-PTR                 BINARY-LONG.
 01 WS-DIR                 PIC X(1100).
 01 WS-SET-TYPE            BINARY-LONG.
 01 WS-REG                 BINARY-LONG VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NAME-AREA           PIC X(112).
 01 WS-NAME-LEN            BINARY-LONG.
 01 WS-BIG                 BINARY-LONG VALUE 65536.
 01 WS-EDIT                PIC -(4)9.
 01 WS-NUM                 PIC -(4)9.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-JSON
     STRING '{"attributes": {"minecraft:gameplay/increased_fire_burnout": true,'
         ' "minecraft:visual/sky_color": "#78a7ff", "minecraft:visual/water_fog_color": "#232317",'
         ' "minecraft:visual/water_fog_end_distance": {"argument": 0.85, "modifier": "multiply"}},'
         ' "carvers": ["minecraft:cave"], "downfall": 0.9,'
         ' "effects": {"dry_foliage_color": "#7b5334", "foliage_color": "#6a7039",'
         ' "grass_color_modifier": "swamp", "water_color": "#617b64"},'
         ' "features": [[], ["minecraft:lake_lava_underground"]], "has_precipitation": true, "temperature": 0.8}'
         DELIMITED BY SIZE INTO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BIOME-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS

     MOVE "T" TO TL-MODE
     MOVE "biome-nbt given a swamp biome JSON when converted then the status is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE WS-STATUS TO WS-D1
     MOVE WS-D1 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Read the NBT back, noting each field.
     CALL "TEST-BIOME-READ" USING PB-BUFFER WS-LINE
     MOVE "biome-nbt given a swamp biome JSON when the NBT is read back then climate, the four colours, the modifier "
         & "and the visual attributes are there and the other fields are not" TO TL-CASE
     MOVE "precip=1 temperature= 0.80 downfall= 0.90 attr:sky_color=#78a7ff attr:water_fog_color=#232317 "
         & "attr:water_fog_end_distance=compound water_color=#617b64 foliage_color=#6a7039 "
         & "dry_foliage_color=#7b5334 grass_color_modifier=swamp" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-LINE) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A frozen biome with Int colours, a Float attribute and a missing precipitation flag; and text that is no object.
     MOVE SPACES TO WS-JSON
     STRING '{"attributes": {"minecraft:visual/fog_color": 5, "minecraft:gameplay/x": 1}, "downfall": 0.5,'
         ' "effects": {"water_color": 3750201, "grass_color": 255}, "has_precipitation": false,'
         ' "temperature": -0.5, "temperature_modifier": "frozen"}' DELIMITED BY SIZE INTO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BIOME-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS
     CALL "TEST-BIOME-READ" USING PB-BUFFER WS-LINE
     MOVE "biome-nbt given a frozen biome with Int colours and a Float attribute when read back then the modifier, the "
         & "Ints and the Float are there" TO TL-CASE
     MOVE "precip=0 temperature=-0.50 downfall= 0.50 modifier=frozen attr:fog_color= 5.00 water_color=3750201 "
         & "grass_color=255" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-LINE) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-JSON
     MOVE "[1, 2]" TO WS-JSON
     MOVE 6 TO WS-LENGTH
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BIOME-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS
     MOVE WS-STATUS TO WS-D1
     MOVE "biome-nbt given text that is no JSON object when converted then the status is 1 and nothing is written" TO TL-CASE
     MOVE "1 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE PB-LENGTH TO WS-NUM
     STRING WS-D1 " " FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The Registry Data packet of a standard set (the fixture pack: 5 biomes): every entry's data reads as NBT to the end,
*>   so a client reads all the entries (before: the JSON bytes made the client stop after the first).
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-BIG
     MOVE SPACES TO WS-DIR
     MOVE "content/tests/fixtures/std" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-SET-TYPE
     CALL "CONTENT-OPEN" USING WS-SET-TYPE WS-DIR WS-STATUS
     CALL "REGISTRY-PACKET-BUILD" USING WS-REG PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     MOVE SPACES TO WS-NAME-AREA
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-NAME-AREA WS-CAP WS-NAME-LEN
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
         MOVE SPACES TO WS-NAME-AREA
         CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-NAME-AREA WS-CAP WS-NAME-LEN
         CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
         CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         IF PB-ERROR = 0 AND WS-TYPE = 10
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO WS-EDIT
     MOVE "registry-packet-build given a standard set when the biome packet is read then every entry holds a compound, "
         & "count and read entries equal" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING "id7 " FUNCTION TRIM(WS-EDIT) " entries" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-N TO WS-EDIT
     MOVE WS-ID TO WS-NUM
     STRING "id" FUNCTION TRIM(WS-NUM) " " FUNCTION TRIM(WS-EDIT) " entries" DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-REGISTRY-BIOME-NBT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BIOME-READ.
*> USING PB-BUFFER (a biome compound, read from its start), text out: each field noted as name=value.
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
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-E                   PIC -9.99.
 01 WS-D1                  PIC 9.
 01 WS-INT-E               PIC -(9)9.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-LINE                 PIC X(400).
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
             WHEN WN = "has_precipitation"
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-VALUE
                 MOVE WS-VALUE TO WS-D1
                 STRING "precip=" WS-D1 " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN WN = "temperature" OR WN = "downfall"
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
                 COMPUTE WS-E ROUNDED = WS-FLOAT
                 STRING FUNCTION TRIM(WN) "=" WS-E " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN WN = "temperature_modifier"
                 MOVE SPACES TO WS-TEXT
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP WS-TEXT-LENGTH
                 STRING "modifier=" FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
             WHEN WN = "effects"
                 MOVE 1 TO WS-TYPE2
                 PERFORM UNTIL WS-TYPE2 = 0
                     MOVE SPACES TO WN2
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE2 WN2 WS-CAP WL2
                     EVALUATE WS-TYPE2
                         WHEN 8
                             MOVE SPACES TO WS-TEXT
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP WS-TEXT-LENGTH
                             STRING FUNCTION TRIM(WN2) "=" FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE
                                 INTO L-LINE WITH POINTER WS-PTR
                         WHEN 3
                             CALL "PB-GET-INT" USING PB-BUFFER WS-VALUE
                             MOVE WS-VALUE TO WS-INT-E
                             STRING FUNCTION TRIM(WN2) "=" FUNCTION TRIM(WS-INT-E) " " DELIMITED BY SIZE
                                 INTO L-LINE WITH POINTER WS-PTR
                     END-EVALUATE
                 END-PERFORM
             WHEN WN = "attributes"
                 MOVE 1 TO WS-TYPE2
                 PERFORM UNTIL WS-TYPE2 = 0
                     MOVE SPACES TO WN2
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE2 WN2 WS-CAP WL2
                     EVALUATE WS-TYPE2
                         WHEN 0
                             CONTINUE
                         WHEN 8
                             MOVE SPACES TO WS-TEXT
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP WS-TEXT-LENGTH
                             STRING "attr:" FUNCTION TRIM(WN2(18:40)) "=" FUNCTION TRIM(WS-TEXT) " "
                                 DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
                         WHEN 5
                             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
                             COMPUTE WS-E ROUNDED = WS-FLOAT
                             STRING "attr:" FUNCTION TRIM(WN2(18:40)) "=" WS-E " " DELIMITED BY SIZE
                                 INTO L-LINE WITH POINTER WS-PTR
                         WHEN OTHER
                             STRING "attr:" FUNCTION TRIM(WN2(18:40)) "=compound " DELIMITED BY SIZE
                                 INTO L-LINE WITH POINTER WS-PTR
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE2
                     END-EVALUATE
                 END-PERFORM
             WHEN OTHER
                 STRING "other:" FUNCTION TRIM(WN) " " DELIMITED BY SIZE INTO L-LINE WITH POINTER WS-PTR
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-BIOME-READ.
