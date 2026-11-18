*> Implementation test (superflat lane; docs/protocol/56-superflat-world.md sections 2 and 3, docs/design/world-types.md superflat): the flat
*> generator settings of the core (FLATSET.cpy, flat-settings.cob). The default is the world preset `flat` (bedrock 1, dirt 2, grass_block 1, plains,
*> lakes and features off, structure overrides strongholds and villages); the nine presets of 56 section 3.2 are data selected by name
*> (FLAT-PRESET-SET, with or without minecraft:); an unknown name changes nothing. The settings are saved to and loaded from
*> data/minecraft/world_gen_settings.dat in the form of 56 section 2.5 (FLAT-SETTINGS-SAVE, FLAT-SETTINGS-LOAD), the member structure_overrides
*> readable as a bare string or a list; a file whose generator is not flat is refused. FLAT-SETTINGS-OPEN decides what a world opens with: the
*> preset a host chose, else the file of the folder, else the default. No generated packs are needed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FLAT-SETTINGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY FLATSET.
 COPY PROTO.
 01 WS-FOLDER              PIC X(64) VALUE Z"build/flat-settings-folder".
 01 WS-COMMAND             PIC X(200).
 01 WS-CREATED             BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-TEXT                PIC X(900).
 01 WS-PTR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-H                   PIC Z(3)9.
 01 WS-F1                  PIC 9.
 01 WS-D1                  PIC 9.
 01 WS-D2                  PIC 9.
 01 WS-D3                  PIC 9.
 01 WS-D4                  PIC 9.
 01 WS-D5                  PIC 9.
 01 WS-OK                  BINARY-LONG.
 01 WS-SET                 PIC X(80).
 01 WS-L1                  PIC 9.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-STR                 PIC X(40).
 01 WS-STR-LENGTH          BINARY-LONG.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/data/minecraft/world_gen_settings.dat".
 01 WS-PRESET-NAMES.
    05 FILLER PIC X(40) VALUE "classic_flat".
    05 FILLER PIC X(40) VALUE "tunnelers_dream".
    05 FILLER PIC X(40) VALUE "water_world".
    05 FILLER PIC X(40) VALUE "overworld".
    05 FILLER PIC X(40) VALUE "snowy_kingdom".
    05 FILLER PIC X(40) VALUE "bottomless_pit".
    05 FILLER PIC X(40) VALUE "desert".
    05 FILLER PIC X(40) VALUE "redstone_ready".
    05 FILLER PIC X(40) VALUE "the_void".
 01 WS-NAMES REDEFINES WS-PRESET-NAMES.
    05 WS-PRESET           PIC X(40) OCCURS 9 TIMES.
*> layers (bottom first, "block height"), biome, features, lakes, overrides: 56 section 3.2
 01 WS-EXPECTED-TEXT.
    05 FILLER PIC X(150) VALUE "bedrock 1,dirt 2,grass_block 1|plains|f0 l0|villages".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 230,dirt 5,grass_block 1|windswept_hills|f1 l0|mineshafts,strongholds".
    05 FILLER PIC X(150) VALUE "bedrock 1,deepslate 64,stone 5,dirt 5,gravel 5,water 90|deep_ocean|f0 l0|ocean_ruins,shipwrecks,ocean_monuments".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 59,dirt 3,grass_block 1|plains|f1 l1|villages,mineshafts,pillager_outposts,ruined_portals,strongholds".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 59,dirt 3,grass_block 1,snow 1|snowy_plains|f0 l0|villages,igloos".
    05 FILLER PIC X(150) VALUE "cobblestone 2,dirt 3,grass_block 1|plains|f0 l0|villages".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 3,sandstone 52,sand 8|desert|f1 l0|villages,desert_pyramids,mineshafts,strongholds".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 3,sandstone 116|desert|f0 l0|-".
    05 FILLER PIC X(150) VALUE "air 1|the_void|f1 l0|-".
 01 WS-EXPECTED REDEFINES WS-EXPECTED-TEXT.
    05 WS-EXPECT           PIC X(150) OCCURS 9 TIMES.
 01 WS-DEFAULT-TEXT        PIC X(150) VALUE "bedrock 1,dirt 2,grass_block 1|plains|f0 l0|strongholds,villages".
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE 0 TO FS-LOADED FS-PENDING
     MOVE "rm -rf build/flat-settings-folder && mkdir -p build/flat-settings-folder" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE "superflat" TO CW-WORLD-TYPE

     CALL "FLAT-SETTINGS-DEFAULT"
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings the default is the world preset flat: bedrock 1, dirt 2, grass_block 1, plains, strongholds and villages" TO TL-CASE
     MOVE WS-DEFAULT-TEXT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE WS-PRESET(WS-I) TO WS-NAME
         CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
         PERFORM RENDER-SETTINGS
         MOVE SPACES TO TL-CASE
         STRING "test flat settings preset " FUNCTION TRIM(WS-NAME) " (56 section 3.2)" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-EXPECT(WS-I) TO TL-EXPECTED
         MOVE WS-TEXT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     MOVE "minecraft:classic_flat" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings a preset name with the minecraft: prefix is the same preset" TO TL-CASE
     MOVE WS-EXPECT(1) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "flat" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings the name flat selects the world preset (strongholds and villages)" TO TL-CASE
     MOVE WS-DEFAULT-TEXT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "water_world" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     MOVE "nope" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings an unknown preset name answers status 1 and changes nothing" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "1 " FUNCTION TRIM(WS-EXPECT(3)) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-STATUS TO WS-H
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-H) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Save and load: the overworld preset (both flags on, five overrides) and the void preset (an empty override list) survive.
     MOVE "overworld" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     CALL "FLAT-SETTINGS-SAVE"
     MOVE 0 TO FS-LAYER-COUNT FS-LAKES FS-FEATURES FS-OVR-COUNT
     MOVE SPACES TO FS-BIOME
     CALL "FLAT-SETTINGS-LOAD" USING WS-STATUS
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings save then load of the overworld preset gives the same settings (56 section 2.5)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "0 " FUNCTION TRIM(WS-EXPECT(4)) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-STATUS TO WS-H
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-H) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "the_void" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     CALL "FLAT-SETTINGS-SAVE"
     MOVE 0 TO FS-LAYER-COUNT FS-LAKES FS-FEATURES FS-OVR-COUNT
     MOVE 0 TO FS-OVR-MODE
     CALL "FLAT-SETTINGS-LOAD" USING WS-STATUS
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings an empty structure_overrides list (the void preset) is kept as none, not as all" TO TL-CASE
     MOVE WS-EXPECT(9) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test flat settings the saved overrides mode of an empty list is 1 (listed)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE FS-OVR-MODE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   A hand-written file: structure_overrides as one bare string, lakes and features as bytes, generate_structures 0.
     PERFORM WRITE-BARE-FILE
     MOVE 1 TO FS-GEN-STRUCT
     CALL "FLAT-SETTINGS-LOAD" USING WS-STATUS
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings a bare-string structure_overrides reads as a list of one" TO TL-CASE
     MOVE "stone 3|desert|f1 l1|villages" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test flat settings generate_structures of the file is read (0)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE FS-GEN-STRUCT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   A file with a noise generator is not a flat world: status 1, the settings stay.
     PERFORM WRITE-NOISE-FILE
     CALL "FLAT-SETTINGS-LOAD" USING WS-STATUS
     MOVE "test flat settings a file whose overworld generator is not flat is refused with status 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   FLAT-SETTINGS-OPEN: the preset a host chose wins; else the file of the folder; else the default; another type leaves them alone.
     MOVE "snowy_kingdom" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     CALL "FLAT-SETTINGS-SAVE"
     MOVE "the_void" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     CALL "FLAT-SETTINGS-OPEN"
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings opening a world with a preset the host chose uses that preset (and consumes the choice)" TO TL-CASE
     MOVE WS-EXPECT(9) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FLAT-SETTINGS-OPEN"
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings opening again with no choice reads the file of the folder (snowy_kingdom)" TO TL-CASE
     MOVE WS-EXPECT(5) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "rm -rf build/flat-settings-folder/data" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "FLAT-SETTINGS-OPEN"
     PERFORM RENDER-SETTINGS
     MOVE "test flat settings opening with no choice and no file uses the default" TO TL-CASE
     MOVE WS-DEFAULT-TEXT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "standard" TO CW-WORLD-TYPE
     MOVE "overworld" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     CALL "FLAT-SETTINGS-OPEN"
     MOVE "test flat settings a world of another type drops the pending choice and keeps nothing pending" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE FS-PENDING TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "superflat" TO CW-WORLD-TYPE
     MOVE "T" TO TL-MODE
*>   Saving with no settings loaded saves the default.
     MOVE 0 TO FS-LOADED
     CALL "FLAT-SETTINGS-SAVE"
     MOVE "test flat settings saving with no settings loaded loads the default settings" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE FS-LOADED TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   FLAT-STRUCT-SET-OK: a listed set passes, another does not, an absent list passes all, generate_structures 0 stops all, another type passes all.
     MOVE "overworld" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     MOVE "minecraft:villages" TO WS-SET
     CALL "FLAT-STRUCT-SET-OK" USING WS-SET WS-OK
     MOVE WS-OK TO WS-D1
     MOVE "minecraft:igloos" TO WS-SET
     CALL "FLAT-STRUCT-SET-OK" USING WS-SET WS-OK
     MOVE WS-OK TO WS-D2
     MOVE 0 TO FS-OVR-MODE
     CALL "FLAT-STRUCT-SET-OK" USING WS-SET WS-OK
     MOVE WS-OK TO WS-D3
     MOVE 0 TO FS-GEN-STRUCT
     CALL "FLAT-STRUCT-SET-OK" USING WS-SET WS-OK
     MOVE WS-OK TO WS-D4
     MOVE "standard" TO CW-WORLD-TYPE
     CALL "FLAT-STRUCT-SET-OK" USING WS-SET WS-OK
     MOVE WS-OK TO WS-D5
     MOVE "superflat" TO CW-WORLD-TYPE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-D1 WS-D2 WS-D3 WS-D4 WS-D5 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "test flat settings a listed structure set passes (1), an unlisted one not (0), an absent list passes (1), generate_structures 0 stops (0), another type passes (1)" TO TL-CASE
     MOVE "10101" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Saving for a world of another type writes nothing.
     MOVE "standard" TO CW-WORLD-TYPE
     MOVE "rm -rf build/flat-settings-folder/data" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "FLAT-SETTINGS-SAVE"
     MOVE "test flat settings a world of another type writes no world_gen_settings.dat" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE "test -e build/flat-settings-folder/data/minecraft/world_gen_settings.dat" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     IF RETURN-CODE = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The settings as text: layers "block height" joined by commas, then |biome|f<features> l<lakes>|overrides ("-" for none; "all" when absent).
 RENDER-SETTINGS.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > FS-LAYER-COUNT
         IF WS-J > 1
             STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
         MOVE FS-L-HEIGHT(WS-J) TO WS-H
         STRING FUNCTION TRIM(FS-L-KEY(WS-J)(11:)) " " FUNCTION TRIM(WS-H) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE FS-FEATURES TO WS-F1
     MOVE FS-LAKES TO WS-L1
     STRING "|" FUNCTION TRIM(FS-BIOME(11:)) "|f" WS-F1 " l" WS-L1 "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     EVALUATE TRUE
         WHEN FS-OVR-MODE = 0
             STRING "all" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN FS-OVR-COUNT = 0
             STRING "-" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN OTHER
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > FS-OVR-COUNT
                 IF WS-J > 1
                     STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
                 END-IF
                 STRING FUNCTION TRIM(FS-OVR(WS-J)(11:)) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-PERFORM
     END-EVALUATE.

*> A file of the 26.3 shape with a flat overworld whose structure_overrides is a bare String.
 WRITE-BARE-FILE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "data" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "generate_structures" TO WN MOVE 19 TO WL
     MOVE 0 TO WS-INT
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     MOVE "dimensions" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:the_nether" TO WN MOVE 19 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "type" TO WN MOVE 4 TO WL
     MOVE "minecraft:the_nether" TO WS-STR
     MOVE 20 TO WS-STR-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STR-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "minecraft:overworld" TO WN MOVE 19 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "generator" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "type" TO WN MOVE 4 TO WL
     MOVE "minecraft:flat" TO WS-STR
     MOVE 14 TO WS-STR-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STR-LENGTH
     MOVE "settings" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "layers" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ONE
     MOVE SPACES TO WN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
     MOVE "height" TO WN MOVE 6 TO WL
     MOVE 3 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "block" TO WN MOVE 5 TO WL
     MOVE "minecraft:stone" TO WS-STR
     MOVE 15 TO WS-STR-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STR-LENGTH
     MOVE "extra" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     MOVE "unknown_member" TO WN MOVE 14 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "biome" TO WN MOVE 5 TO WL
     MOVE "minecraft:desert" TO WS-STR
     MOVE 16 TO WS-STR-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STR-LENGTH
     MOVE "lakes" TO WN MOVE 5 TO WL
     MOVE 1 TO WS-INT
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     MOVE "features" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     MOVE "structure_overrides" TO WN MOVE 19 TO WL
     MOVE "minecraft:villages" TO WS-STR
     MOVE 18 TO WS-STR-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STR-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER.

*> The same shape with a noise generator.
 WRITE-NOISE-FILE.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "data" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "dimensions" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:overworld" TO WN MOVE 19 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "generator" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "type" TO WN MOVE 4 TO WL
     MOVE "minecraft:noise" TO WS-STR
     MOVE 15 TO WS-STR-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STR-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER.
 END PROGRAM TEST-FLAT-SETTINGS.

 COPY CORETEST.
