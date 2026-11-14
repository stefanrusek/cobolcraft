*> Implementation test of the built-in registry entries of the cobolcraft set (T0327;
*> docs/design/cobolcraft-standard-core.md sections 3.1, 3.2 and 3.7; content-api section 2): CONTENT-REGISTRY-ENTRY
*> returns the entry as network NBT. The Registry Data packet built from the counts, keys and payloads of
*> minecraft:timeline (2 entries) and minecraft:enchantment (1 entry) equals the contract fixtures byte for byte;
*> minecraft:world_clock holds one entry, the empty compound; a standard-schema registry without built-in text still
*> answers with no payload; a too-small area is CT-TOO-SMALL with the length given.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUILTIN-REGISTRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FX-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-DIR                 PIC X(1100) VALUE SPACES.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(112).
 01 WS-REGISTRY-LENGTH     BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAYLOAD             PIC X(65536).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ID-PACKET           BINARY-LONG VALUE 7.
 01 WS-PATH                PIC X(256).
 01 WS-SMALL               PIC X(8).
 01 WS-SMALL-CAPACITY      BINARY-LONG.
 01 WS-FULL-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-E4                  PIC -(9)9.
 01 WS-VARIANT-TABLE.
    05 FILLER PIC X(32) VALUE "wolf_variant".
    05 FILLER PIC X(32) VALUE "wolf_sound_variant".
    05 FILLER PIC X(32) VALUE "pig_variant".
    05 FILLER PIC X(32) VALUE "pig_sound_variant".
    05 FILLER PIC X(32) VALUE "frog_variant".
    05 FILLER PIC X(32) VALUE "cat_variant".
    05 FILLER PIC X(32) VALUE "cat_sound_variant".
    05 FILLER PIC X(32) VALUE "cow_sound_variant".
    05 FILLER PIC X(32) VALUE "cow_variant".
    05 FILLER PIC X(32) VALUE "chicken_sound_variant".
    05 FILLER PIC X(32) VALUE "chicken_variant".
    05 FILLER PIC X(32) VALUE "zombie_nautilus_variant".
    05 FILLER PIC X(32) VALUE "painting_variant".
 01 WS-VARIANTS REDEFINES WS-VARIANT-TABLE.
    05 WS-VARIANT          PIC X(32) OCCURS 13 TIMES.
 01 WS-DASHED              PIC X(48).
 01 WS-TEXT                PIC X(8192).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-RENDER              PIC X(8192).
 01 WS-TOTAL               BINARY-LONG.
 01 WS-COUNT-TABLE.
    05 FILLER PIC X(32) VALUE "worldgen/biome".
    05 FILLER PIC X(32) VALUE "chat_type".
    05 FILLER PIC X(32) VALUE "dimension_type".
    05 FILLER PIC X(32) VALUE "damage_type".
    05 FILLER PIC X(32) VALUE "enchantment".
    05 FILLER PIC X(32) VALUE "world_clock".
    05 FILLER PIC X(32) VALUE "timeline".
 01 WS-COUNTS REDEFINES WS-COUNT-TABLE.
    05 WS-COUNT-NAME       PIC X(32) OCCURS 7 TIMES.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-BAD                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 B-A                    PIC X(262144) BASED.
 01 B-B                    PIC X(262144) BASED.
 PROCEDURE DIVISION.
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING FX-BUFFER WS-CAPACITY

     MOVE "minecraft:timeline" TO WS-REGISTRY
     MOVE 18 TO WS-REGISTRY-LENGTH
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-timeline.hex" TO WS-PATH
     MOVE "test builtin registry the timeline packet equals the contract fixture" TO TL-CASE
     PERFORM PACKET-CASE

     MOVE "minecraft:enchantment" TO WS-REGISTRY
     MOVE 21 TO WS-REGISTRY-LENGTH
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-enchantment.hex" TO WS-PATH
     MOVE "test builtin registry the enchantment packet equals the contract fixture" TO TL-CASE
     PERFORM PACKET-CASE

     MOVE "minecraft:worldgen/biome" TO WS-REGISTRY
     MOVE 24 TO WS-REGISTRY-LENGTH
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-worldgen-biome.hex" TO WS-PATH
     MOVE "test builtin registry the biome packet equals the contract fixture" TO TL-CASE
     PERFORM PACKET-CASE

*>   The 13 mandatory variant registries, one placeholder entry each, equal their fixtures.
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 13
         MOVE SPACES TO WS-REGISTRY WS-PATH WS-DASHED
         STRING "minecraft:" FUNCTION TRIM(WS-VARIANT(WS-V)) DELIMITED BY SIZE INTO WS-REGISTRY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-REGISTRY)) TO WS-REGISTRY-LENGTH
         MOVE FUNCTION TRIM(WS-VARIANT(WS-V)) TO WS-DASHED
         INSPECT WS-DASHED REPLACING ALL "_" BY "-"
         STRING "contract/fixtures/wire/config-s2c-07-registry-data-" FUNCTION TRIM(WS-DASHED) ".hex"
             DELIMITED BY SIZE INTO WS-PATH
         MOVE SPACES TO TL-CASE
         STRING "test builtin registry the " FUNCTION TRIM(WS-VARIANT(WS-V)) " packet equals the contract fixture"
             DELIMITED BY SIZE INTO TL-CASE
         PERFORM PACKET-CASE
     END-PERFORM

*>   The counts of the seven other synchronized registries: 3 + 8 + 2 + 52 + 1 + 1 + 2, with the 13 variants 82.
     MOVE 13 TO WS-TOTAL
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 7
         MOVE SPACES TO WS-REGISTRY
         STRING "minecraft:" FUNCTION TRIM(WS-COUNT-NAME(WS-V)) DELIMITED BY SIZE INTO WS-REGISTRY
         CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
         ADD WS-COUNT TO WS-TOTAL
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "test builtin registry the 20 synchronized registries hold 82 entries" TO TL-CASE
     MOVE 82 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every one of the 82 entries has a payload, and the 82 keys are the keys of the count.
     MOVE 0 TO WS-TOTAL WS-BAD
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 20
         MOVE SPACES TO WS-REGISTRY
         IF WS-V <= 13
             STRING "minecraft:" FUNCTION TRIM(WS-VARIANT(WS-V)) DELIMITED BY SIZE INTO WS-REGISTRY
         ELSE
             COMPUTE WS-C = WS-V - 13
             STRING "minecraft:" FUNCTION TRIM(WS-COUNT-NAME(WS-C)) DELIMITED BY SIZE INTO WS-REGISTRY
         END-IF
         CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
         PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-COUNT
             CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD
                 WS-FULL-CAPACITY WS-LENGTH WS-STATUS
             ADD 1 TO WS-TOTAL
             IF WS-LENGTH < 2 OR WS-STATUS NOT = CT-OK OR WS-KEY-LENGTH < 8
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "test builtin registry all 82 entries of the 20 registries answer a payload and a key" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 82 * 1000
     COMPUTE TL-OBSERVED-N = WS-TOTAL * 1000 + WS-BAD
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Rendered entries against the document (cobolcraft-standard-core.md 3.3, 3.5, 3.6).
     MOVE "minecraft:chat_type" TO WS-REGISTRY
     MOVE 2 TO WS-ID
     PERFORM RENDER-ENTRY
     MOVE "T" TO TL-MODE
     MOVE "test builtin registry chat_type 2 msg_command_incoming has the gray italic style after parameters"
         TO TL-CASE
     MOVE "minecraft:msg_command_incoming {chat:{translation_key:commands.message.display.incoming,pa"
         & "rameters:[sender,content],style:{color:gray,italic:1}},narration:{translation_key:chat.typ"
         & "e.text.narrate,parameters:[sender,content]}}"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "minecraft:worldgen/biome" TO WS-REGISTRY
     MOVE 2 TO WS-ID
     PERFORM RENDER-ENTRY
     MOVE "test builtin registry biome 2 ash_flats: no precipitation, temperature 1.4, downfall 0" TO TL-CASE
     MOVE "cobolcraft:ash_flats {has_precipitation:0,temperature:1.400,downfall:0.000,effects:{water_color:#3A2F2A,grass_color:#5A4A40,foliage_color:#5A4A40}}"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-ID
     PERFORM RENDER-ENTRY
     MOVE "test builtin registry biome 0 plains: precipitation, temperature 0.6, downfall 0.4" TO TL-CASE
     MOVE "minecraft:plains {has_precipitation:1,temperature:0.600,downfall:0.400,effects:{water_color:#3A6EA5,grass_color:#4F8F3A,foliage_color:#4F8F3A}}"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "minecraft:damage_type" TO WS-REGISTRY
     MOVE 10 TO WS-ID
     PERFORM RENDER-ENTRY
     MOVE "test builtin registry damage_type 10 fall: no exhaustion, fall_variants" TO TL-CASE
     MOVE "minecraft:fall {message_id:fall,scaling:when_caused_by_living_non_player,exhaustion:0.000,death_message_type:fall_variants}"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3 TO WS-ID
     PERFORM RENDER-ENTRY
     MOVE "test builtin registry damage_type 3 campfire: burning effects" TO TL-CASE
     MOVE "minecraft:campfire {message_id:campfire,scaling:when_caused_by_living_non_player,exhaustion:0.100,effects:burning}"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 34 TO WS-ID
     PERFORM RENDER-ENTRY
     MOVE "test builtin registry damage_type 34 outside_border keeps the read message id outsideBorder" TO TL-CASE
     MOVE "minecraft:outside_border {message_id:outsideBorder,scaling:when_caused_by_living_non_player,exhaustion:0.000}"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO WS-ID
     PERFORM RENDER-ENTRY
     MOVE "test builtin registry damage_type 1 bad_respawn_point: always scaling, intentional_game_design" TO TL-CASE
     MOVE "minecraft:bad_respawn_point {message_id:bad_respawn_point,scaling:always,exhaustion:0.100,death_message_type:intentional_game_design}"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "minecraft:dimension_type" TO WS-REGISTRY
     MOVE 1 TO WS-ID
     PERFORM RENDER-ENTRY
     MOVE "test builtin registry dimension_type 1 sunless: fixed time, no sky light, skybox none, no clock" TO TL-CASE
     MOVE "cobolcraft:sunless {has_fixed_time:1,has_skylight:0,has_ceiling:0,has_ender_dragon_fight:0"
         & ",coordinate_scale:1.000,min_y:0,height:128,logical_height:128,infiniburn:[],ambient_light:"
         & "0.000,monster_spawn_light_level:{type:minecraft:uniform,min_inclusive:0,max_inclusive:7},m"
         & "onster_spawn_block_light_limit:0,skybox:none,attributes:{minecraft:visual/sky_color:#100c1"
         & "2,minecraft:visual/fog_color:#100c12,minecraft:visual/ambient_light_color:#1a1a1a,minecraf"
         & "t:visual/sky_light_factor:0.000}}"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-ID
     PERFORM RENDER-ENTRY
     MOVE "test builtin registry dimension_type 0 surface: sky, two timelines, the overworld clock" TO TL-CASE
     MOVE "cobolcraft:surface {has_skylight:1,has_ceiling:0,has_ender_dragon_fight:0,coordinate_scale"
         & ":1.000,min_y:0,height:256,logical_height:256,infiniburn:[],ambient_light:0.000,monster_spa"
         & "wn_light_level:{type:minecraft:uniform,min_inclusive:0,max_inclusive:7},monster_spawn_bloc"
         & "k_light_limit:0,attributes:{minecraft:visual/ambient_light_color:#0a0a0a,minecraft:visual/"
         & "cloud_color:#ccffffff,minecraft:visual/cloud_height:192.330,minecraft:visual/fog_color:#c0"
         & "d8ff,minecraft:visual/sky_color:#78a7ff},timelines:[minecraft:day,minecraft:moon],default_"
         & "clock:minecraft:overworld}"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   world_clock: one entry, minecraft:overworld, the empty compound (CORE-5).
     MOVE "minecraft:world_clock" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE 0 TO WS-ID
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD
         WS-FULL-CAPACITY WS-LENGTH WS-STATUS
     MOVE "T" TO TL-MODE
     MOVE "test builtin registry world_clock is one entry minecraft:overworld holding 0a00" TO TL-CASE
     MOVE WS-COUNT TO WS-E1
     MOVE WS-LENGTH TO WS-E2
     MOVE FUNCTION ORD(WS-PAYLOAD(1:1)) TO WS-E3
     MOVE FUNCTION ORD(WS-PAYLOAD(2:1)) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " WS-KEY(1:WS-KEY-LENGTH) " " FUNCTION TRIM(WS-E2) " "
         FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 minecraft:overworld 2 11 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A too-small area: CT-TOO-SMALL and the length of the payload.
     MOVE "minecraft:timeline" TO WS-REGISTRY
     MOVE 1 TO WS-ID
     MOVE 8 TO WS-SMALL-CAPACITY
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-SMALL
         WS-SMALL-CAPACITY WS-LENGTH WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE "test builtin registry a payload larger than the area is CT-TOO-SMALL" TO TL-CASE
     MOVE CT-TOO-SMALL TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A registry with entries but no built-in text keeps answering by key only (no payload).
     MOVE "minecraft:block" TO WS-REGISTRY
     MOVE 1 TO WS-ID
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD
         WS-FULL-CAPACITY WS-LENGTH WS-STATUS
     MOVE "test builtin registry an entry without built-in text has length 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The Registry Data packet of WS-REGISTRY from the content set, compared with the fixture at WS-PATH.
 RENDER-ENTRY.
     MOVE SPACES TO WS-TEXT
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD
         WS-FULL-CAPACITY WS-LENGTH WS-STATUS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-PAYLOAD WS-LENGTH
     MOVE 0 TO PB-POS
     CALL "PB-SKIP" USING PB-BUFFER WS-ONE
     MOVE 10 TO WS-ELEMENT-TYPE
     MOVE 0 TO WS-TEXT-LENGTH
     MOVE SPACES TO WS-RENDER
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-ELEMENT-TYPE WS-RENDER WS-TEXT-LENGTH
     STRING WS-KEY(1:WS-KEY-LENGTH) " " WS-RENDER(1:WS-TEXT-LENGTH) DELIMITED BY SIZE INTO WS-TEXT.

 PACKET-CASE.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID-PACKET
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-REGISTRY WS-REGISTRY-LENGTH
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-COUNT
         CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD
             WS-FULL-CAPACITY WS-LENGTH WS-STATUS
         CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-KEY WS-KEY-LENGTH
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
         IF WS-LENGTH > 0
             CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-PAYLOAD WS-LENGTH
         END-IF
     END-PERFORM
     CALL "TEST-LOAD-HEX" USING WS-PATH FX-BUFFER
     SET ADDRESS OF B-A TO PB-ADDR
     SET ADDRESS OF B-B TO FX-ADDR
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-I
     IF PB-LENGTH = FX-LENGTH
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-LENGTH OR WS-BAD > 0
             IF B-A(WS-I:1) NOT = B-B(WS-I:1)
                 MOVE WS-I TO WS-BAD
             END-IF
         END-PERFORM
     ELSE
         COMPUTE WS-BAD = 0 - 1
     END-IF
     MOVE "T" TO TL-MODE
     MOVE PB-LENGTH TO WS-E1
     MOVE FX-LENGTH TO WS-E2
     MOVE WS-BAD TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E2) " 0" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BUILTIN-REGISTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-HEX.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT HEX-FILE ASSIGN TO WS-PATH
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD HEX-FILE.
 01 HEX-LINE               PIC X(4096).
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(256).
 01 WS-STATUS              PIC XX.
 01 WS-I                   BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BYTE                PIC X.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING L-PATH PB-BUFFER.
     MOVE L-PATH TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     OPEN INPUT HEX-FILE
     IF WS-STATUS NOT = "00"
         DISPLAY "TEST-LOAD-HEX cannot open " FUNCTION TRIM(WS-PATH) " status " WS-STATUS
         STOP RUN RETURNING 2
     END-IF
     PERFORM UNTIL WS-STATUS NOT = "00"
         MOVE SPACES TO HEX-LINE
         READ HEX-FILE
         IF WS-STATUS = "00"
             MOVE 4096 TO WS-END
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
                 IF HEX-LINE(WS-I:1) = "#" AND WS-END = 4096
                     COMPUTE WS-END = WS-I - 1
                 END-IF
             END-PERFORM
             MOVE 1 TO WS-I
             PERFORM UNTIL WS-I > WS-END
                 IF HEX-LINE(WS-I:1) = SPACE OR HEX-LINE(WS-I:1) = X"09"
                     ADD 1 TO WS-I
                 ELSE
                     MOVE FUNCTION HEX-TO-CHAR(HEX-LINE(WS-I:2)) TO WS-BYTE
                     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-BYTE WS-ONE
                     ADD 2 TO WS-I
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     CLOSE HEX-FILE
     GOBACK.
 END PROGRAM TEST-LOAD-HEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NBT-RENDER RECURSIVE.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-INT                 BINARY-LONG.
 01 LS-LONG                BINARY-DOUBLE.
 01 LS-FLOAT               FLOAT-SHORT.
 01 LS-DOUBLE              FLOAT-LONG.
 01 LS-EDIT                PIC -(18)9.
 01 LS-FEDIT               PIC -(12)9.999.
 01 LS-TEXT                PIC X(1024).
 01 LS-LENGTH              BINARY-LONG.
 01 LS-CAPACITY            BINARY-LONG VALUE 1024.
 01 LS-TYPE                BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-INTS.
    05 LS-INT-ITEM         BINARY-LONG OCCURS 64 TIMES.
 01 LS-INT-CAPACITY        BINARY-LONG VALUE 64.
 01 LS-NUMBER              PIC X(32).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-TEXT                 PIC X(8192).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-TEXT L-LENGTH.
     MOVE SPACES TO LS-NUMBER
     EVALUATE L-TYPE
         WHEN 1
             CALL "PB-GET-BYTE" USING PB-BUFFER LS-INT
             MOVE LS-INT TO LS-EDIT
             MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
         WHEN 2
             CALL "PB-GET-SHORT" USING PB-BUFFER LS-INT
             MOVE LS-INT TO LS-EDIT
             MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
         WHEN 3
             CALL "PB-GET-INT" USING PB-BUFFER LS-INT
             MOVE LS-INT TO LS-EDIT
             MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
         WHEN 4
             CALL "PB-GET-LONG" USING PB-BUFFER LS-LONG
             MOVE LS-LONG TO LS-EDIT
             MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
         WHEN 5
             CALL "PB-GET-FLOAT" USING PB-BUFFER LS-FLOAT
             COMPUTE LS-FEDIT ROUNDED = LS-FLOAT
             MOVE FUNCTION TRIM(LS-FEDIT) TO LS-NUMBER
         WHEN 6
             CALL "PB-GET-DOUBLE" USING PB-BUFFER LS-DOUBLE
             COMPUTE LS-FEDIT ROUNDED = LS-DOUBLE
             MOVE FUNCTION TRIM(LS-FEDIT) TO LS-NUMBER
         WHEN 7
             CALL "PB-GET-INT" USING PB-BUFFER LS-COUNT
             CALL "PB-SKIP" USING PB-BUFFER LS-COUNT
             MOVE LS-COUNT TO LS-EDIT
             STRING "B" FUNCTION TRIM(LS-EDIT) DELIMITED BY SIZE INTO LS-NUMBER
         WHEN 8
             CALL "NBT-READ-STRING" USING PB-BUFFER LS-TEXT LS-CAPACITY LS-LENGTH
             IF LS-LENGTH > 0
                 MOVE LS-TEXT(1:LS-LENGTH) TO L-TEXT(L-LENGTH + 1:LS-LENGTH)
                 ADD LS-LENGTH TO L-LENGTH
             END-IF
         WHEN 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER LS-TYPE LS-COUNT
             MOVE "[" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT OR PB-ERROR = 1
                 IF LS-I > 1
                     MOVE "," TO L-TEXT(L-LENGTH + 1:1)
                     ADD 1 TO L-LENGTH
                 END-IF
                 CALL "TEST-NBT-RENDER" USING PB-BUFFER LS-TYPE L-TEXT L-LENGTH
             END-PERFORM
             MOVE "]" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
         WHEN 10
             MOVE "{" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
             MOVE 0 TO LS-I
             PERFORM UNTIL PB-ERROR = 1
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER LS-TYPE LS-TEXT LS-CAPACITY
                     LS-LENGTH
                 IF LS-TYPE = 0
                     EXIT PERFORM
                 END-IF
                 IF LS-I > 0
                     MOVE "," TO L-TEXT(L-LENGTH + 1:1)
                     ADD 1 TO L-LENGTH
                 END-IF
                 ADD 1 TO LS-I
                 IF LS-LENGTH > 0
                     MOVE LS-TEXT(1:LS-LENGTH) TO L-TEXT(L-LENGTH + 1:LS-LENGTH)
                     ADD LS-LENGTH TO L-LENGTH
                 END-IF
                 MOVE ":" TO L-TEXT(L-LENGTH + 1:1)
                 ADD 1 TO L-LENGTH
                 CALL "TEST-NBT-RENDER" USING PB-BUFFER LS-TYPE L-TEXT L-LENGTH
             END-PERFORM
             MOVE "}" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
         WHEN 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER LS-INT-CAPACITY LS-COUNT LS-INTS
             MOVE "I[" TO L-TEXT(L-LENGTH + 1:2)
             ADD 2 TO L-LENGTH
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT
                 IF LS-I > 1
                     MOVE "," TO L-TEXT(L-LENGTH + 1:1)
                     ADD 1 TO L-LENGTH
                 END-IF
                 MOVE LS-INT-ITEM(LS-I) TO LS-EDIT
                 MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(LS-NUMBER)) TO LS-LENGTH
                 MOVE LS-NUMBER(1:LS-LENGTH) TO L-TEXT(L-LENGTH + 1:LS-LENGTH)
                 ADD LS-LENGTH TO L-LENGTH
             END-PERFORM
             MOVE SPACES TO LS-NUMBER
             MOVE "]" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
         WHEN 12
             CALL "PB-GET-INT" USING PB-BUFFER LS-COUNT
             COMPUTE LS-I = LS-COUNT * 8
             CALL "PB-SKIP" USING PB-BUFFER LS-I
             MOVE LS-COUNT TO LS-EDIT
             STRING "L" FUNCTION TRIM(LS-EDIT) DELIMITED BY SIZE INTO LS-NUMBER
     END-EVALUATE
     IF LS-NUMBER NOT = SPACES
         MOVE FUNCTION LENGTH(FUNCTION TRIM(LS-NUMBER)) TO LS-LENGTH
         MOVE LS-NUMBER(1:LS-LENGTH) TO L-TEXT(L-LENGTH + 1:LS-LENGTH)
         ADD LS-LENGTH TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM TEST-NBT-RENDER.
