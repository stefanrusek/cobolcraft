*> Contract test of the proto side of the wire seam (specs/002-client-polish/contracts/wire-delta.md
*> section 4): each fixture of contract/fixtures/wire decodes to its stated fields and the same
*> fields encode to the same bytes. Phase 10 holds Block Destruction (play-s2c-05) and Player
*> Action (play-c2s-29); Phase 11 holds the item stack with components (Container Set Slot, Set
*> Content, Set Cursor Item), the container packets (Open Screen, Click, Close) and the recipe
*> book packets (Place Recipe, Recipe Book Add, Remove, Settings, Change Settings, Seen). Phase 12
*> holds the 24-section Level Chunk With Light (play-s2c-2e), the 26-index Light Update (play-s2c-31),
*> every Registry Data fixture (config-s2c-07) and Update Tags (config-s2c-0e). Phase 13 holds Level
*> Event (play-s2c-2f), Level Particles (play-s2c-30), Block Event (play-s2c-07), Block Entity Data
*> (play-s2c-06), Login (play-s2c-32) and Respawn (play-s2c-54) for one, two and three dimensions.
*> Phase 14 holds Commands (play-s2c-10, with every argument parser), Command Suggestion (play-c2s-0f),
*> Command Suggestions (play-s2c-0f), Chat Command (play-c2s-07), Player Chat (play-s2c-42) and
*> Disguised Chat (play-s2c-21). Phase 15 holds Update Attributes (play-s2c-86) and Update Mob Effect
*> (play-s2c-87). Phase 16 holds Spawn Entity (play-s2c-01, seven fixtures), Set Entity Data
*> (play-s2c-65, with an entry for every one of the 44 serializers) and Entity Event (play-s2c-22). The
*> expected fields are the "Stated inputs" of each fixture file.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-WIRE-PROVIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PBLEVEL.
 COPY PBCHAT.
 COPY PBATTR.
 COPY PBENT.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-FIXTURE             PIC X(256).
 01 WS-NAME                PIC X(60).
 01 WS-STATED              PIC X(40).
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STAGE               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQUENCE            BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-HEX-A               PIC X(1024).
 01 WS-HEX-B               PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-CLICK-TYPE          BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MENU                BINARY-LONG.
 01 WS-RECIPE              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-FILTERING           BINARY-LONG.
 01 WS-REPLACE             BINARY-LONG.
 01 WS-ID-TABLE.
    05 WS-ID               BINARY-LONG OCCURS 64 TIMES.
 01 WS-STATED-LONG         PIC X(1000).
 01 WS-OFFSET              BINARY-LONG.
 01 WS-EQUAL               BINARY-LONG.
 01 WS-SLOT-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-14-container-set-slot".
    05 FILLER PIC X(300) VALUE "0 2 0 63x2".
    05 FILLER PIC X(100) VALUE "play-s2c-14-container-set-slot-components".
    05 FILLER PIC X(300) VALUE "0 5 36 1x1 +3=05 +6=0800024869 -1".
 01 WS-SLOTS REDEFINES WS-SLOT-TABLE.
    05 WS-SL                  OCCURS 2 TIMES.
       10 WS-SL-NAME          PIC X(100).
       10 WS-SL-FIELDS        PIC X(300).
 01 WS-CURSOR-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-62-set-cursor-item".
    05 FILLER PIC X(300) VALUE "16x63".
    05 FILLER PIC X(100) VALUE "play-s2c-62-set-cursor-item-empty".
    05 FILLER PIC X(300) VALUE "empty".
 01 WS-CURSORS REDEFINES WS-CURSOR-TABLE.
    05 WS-CU                  OCCURS 2 TIMES.
       10 WS-CU-NAME          PIC X(100).
       10 WS-CU-FIELDS        PIC X(300).
 01 WS-CONTENT-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-12-container-set-content-empty".
    05 FILLER PIC X(300) VALUE "0 1 36 carried empty".
    05 FILLER PIC X(100) VALUE "play-s2c-12-container-set-content-starting-items".
    05 FILLER PIC X(300) VALUE "0 1 36 0:64x2 1:64x3 2:64x4 3:64x5 4:64x6 5:64x7 6:64x8 7:64x9 8:1x10 9:1x11 carried empty".
    05 FILLER PIC X(100) VALUE "play-s2c-12-container-set-content-46-slots".
    05 FILLER PIC X(300) VALUE "0 3 46 36:64x1 40:1x1 +3=05 +6=0800024869 -1 45:1x62 carried 5x63".
    05 FILLER PIC X(100) VALUE "play-s2c-12-container-set-content-crafting-bench".
    05 FILLER PIC X(300) VALUE "1 1 46 0:1x62 1:1x63 5:1x63 37:64x1 carried empty".
 01 WS-CONTENTS REDEFINES WS-CONTENT-TABLE.
    05 WS-CT                  OCCURS 4 TIMES.
       10 WS-CT-NAME          PIC X(100).
       10 WS-CT-FIELDS        PIC X(300).
 01 WS-CLICK-TABLE.
    05 FILLER PIC X(100) VALUE "play-c2s-12-container-click".
    05 FILLER PIC X(300) VALUE "0 1 0 0 0 1 0:empty carried 64x2".
    05 FILLER PIC X(100) VALUE "play-c2s-12-container-click-hashed-components".
    05 FILLER PIC X(300) VALUE "2 300 45 1 0 1 45:1x1 +3=-559038737 -1 carried 2x63 +6=305419896".
    05 FILLER PIC X(100) VALUE "play-c2s-12-container-click-outside".
    05 FILLER PIC X(300) VALUE "2 1 -999 0 0 0 carried 3x62".
    05 FILLER PIC X(100) VALUE "play-c2s-12-container-click-quick-move".
    05 FILLER PIC X(300) VALUE "2 7 9 0 1 2 9:empty 36:64x1 carried empty".
 01 WS-CLICKS REDEFINES WS-CLICK-TABLE.
    05 WS-CK                  OCCURS 4 TIMES.
       10 WS-CK-NAME          PIC X(100).
       10 WS-CK-FIELDS        PIC X(300).
 01 WS-SCREEN-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-3c-open-screen-chest-with-name".
    05 FILLER PIC X(300) VALUE "127 2 plain Loot".
    05 FILLER PIC X(100) VALUE "play-s2c-3c-open-screen-crafting".
    05 FILLER PIC X(300) VALUE "2 12 translate container.crafting".
 01 WS-SCREENS REDEFINES WS-SCREEN-TABLE.
    05 WS-SC                  OCCURS 2 TIMES.
       10 WS-SC-NAME          PIC X(100).
       10 WS-SC-FIELDS        PIC X(300).
 01 WS-SPAWN-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-01-add-entity-standard-cow".
    05 FILLER PIC X(300) VALUE "300 000000000000000000000000000000b1 30 -12.50 64.00 40.25 0.00 0.00 0.00 0.00 90.00 90.00 0".
    05 FILLER PIC X(100) VALUE "play-s2c-01-add-entity-item-standard".
    05 FILLER PIC X(300) VALUE "301 000000000000000000000000000000b1 72 0.50 70.00 0.50 0.10 0.20 -0.10 9.84 -45.00 -45.00 0".
    05 FILLER PIC X(100) VALUE "play-s2c-01-add-entity-zombie-fast".
    05 FILLER PIC X(300) VALUE "302 000000000000000000000000000000b1 154 1.00 2.00 3.00 8.00 0.00 0.00 0.00 0.00 0.00 0".
    05 FILLER PIC X(100) VALUE "play-s2c-01-add-entity-loose-item".
    05 FILLER PIC X(300) VALUE "10 0000000000000000000000000000000a 1 5.50 53.25 8.50 0.00 0.00 0.00 0.00 0.00 0.00 0".
    05 FILLER PIC X(100) VALUE "play-s2c-01-add-entity-operator".
    05 FILLER PIC X(300) VALUE "1 10920508d5d83eed93d292f193afe7d7 0 4.50 54.00 8.50 0.00 0.00 0.00 0.00 -90.00 -90.00 0".
    05 FILLER PIC X(100) VALUE "play-s2c-01-add-entity-sodgrazer".
    05 FILLER PIC X(300) VALUE "20 00000000000000000000000000000014 2 12.50 56.00 3.50 0.00 0.00 0.00 0.00 90.00 90.00 0".
    05 FILLER PIC X(100) VALUE "play-s2c-01-add-entity-abend".
    05 FILLER PIC X(300) VALUE "21 00000000000000000000000000000015 3 -3.50 52.00 -6.50 0.00 0.00 0.00 0.00 -180.00 -180.00 0".
 01 WS-SPAWNS REDEFINES WS-SPAWN-TABLE.
    05 WS-SPN                 OCCURS 7 TIMES.
       10 WS-SPN-NAME         PIC X(100).
       10 WS-SPN-FIELDS       PIC X(300).
 01 WS-PLACE-TABLE.
    05 FILLER PIC X(100) VALUE "play-c2s-27-place-recipe".
    05 FILLER PIC X(300) VALUE "0 0 0".
    05 FILLER PIC X(100) VALUE "play-c2s-27-place-recipe-standard".
    05 FILLER PIC X(300) VALUE "2 300 1".
 01 WS-PLACES REDEFINES WS-PLACE-TABLE.
    05 WS-PL                  OCCURS 2 TIMES.
       10 WS-PL-NAME          PIC X(100).
       10 WS-PL-FIELDS        PIC X(300).
 01 WS-ADD-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-4b-recipe-book-add-standard-replace-empty".
    05 FILLER PIC X(300) VALUE "n0 replace 1".
    05 FILLER PIC X(100) VALUE "play-s2c-4b-recipe-book-add-standard-tag-slots".
    05 FILLER PIC X(300) VALUE "n1 7:t0 g0 c3 q- f1 replace 0".
    05 FILLER PIC X(100) VALUE "play-s2c-4b-recipe-book-add-standard".
    05 FILLER PIC X(300) VALUE "n5 0:t0 g0 c0 q2 f3 300:t1 g6 c0 q- f2 301:t2 g0 c4 q- f0 302:t3 g0 c10 q- f0 303:t4 g0 c11 q- f0 replace 0".
    05 FILLER PIC X(100) VALUE "play-s2c-4b-recipe-book-add".
    05 FILLER PIC X(300) VALUE "n9 0:t0 g0 c0 q1 f0 1:t0 g0 c0 q- f0 2:t0 g0 c0 q- f0 3:t0 g0 c0 q- f0 4:t0 g0 c0 q- f0 5:t0 g0 c0 q- f0 6:t0 g0 c0 q- f0 7:t0 g0 c0 q- f0 8:t0 g0 c0 q- f0 replace 1".
 01 WS-ADDS REDEFINES WS-ADD-TABLE.
    05 WS-AD                  OCCURS 4 TIMES.
       10 WS-AD-NAME          PIC X(100).
       10 WS-AD-FIELDS        PIC X(300).
 01 WS-DESTRUCTION-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-05-block-destruction".
    05 FILLER PIC X(40)  VALUE "1 5 53 8 3".
    05 FILLER PIC X(100) VALUE "play-s2c-05-block-destruction-standard".
    05 FILLER PIC X(40)  VALUE "300 -12 -60 40 9".
    05 FILLER PIC X(100) VALUE "play-s2c-05-block-destruction-standard-clear".
    05 FILLER PIC X(40)  VALUE "1 7 70 -3 255".
 01 WS-DESTRUCTIONS REDEFINES WS-DESTRUCTION-TABLE.
    05 WS-DESTRUCTION         OCCURS 3 TIMES.
       10 WS-D-NAME           PIC X(100).
       10 WS-D-FIELDS         PIC X(40).
 01 WS-ACTION-TABLE.
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-start-destroy".
    05 FILLER PIC X(40)  VALUE "0 4 53 8 1 1".
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-abort-destroy".
    05 FILLER PIC X(40)  VALUE "2 4 53 8 1 2".
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-stop-destroy".
    05 FILLER PIC X(40)  VALUE "3 4 53 8 1 3".
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-drop-all-items".
    05 FILLER PIC X(40)  VALUE "4 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-drop-item".
    05 FILLER PIC X(40)  VALUE "5 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-release-use-item".
    05 FILLER PIC X(40)  VALUE "6 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-swap-item-with-offhand".
    05 FILLER PIC X(40)  VALUE "7 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-start-destroy-standard".
    05 FILLER PIC X(40)  VALUE "0 -12 -60 40 1 41".
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-abort-destroy-standard".
    05 FILLER PIC X(40)  VALUE "2 -12 -60 40 1 42".
    05 FILLER PIC X(100) VALUE "play-c2s-29-player-action-stop-destroy-standard".
    05 FILLER PIC X(40)  VALUE "3 -12 -60 40 1 300".
 01 WS-ACTIONS REDEFINES WS-ACTION-TABLE.
    05 WS-ACTION              OCCURS 10 TIMES.
       10 WS-A-NAME           PIC X(100).
       10 WS-A-FIELDS         PIC X(40).
 01 WS-REGISTRY-TABLE.
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-cat-sound-variant".
    05 FILLER PIC X(300) VALUE "minecraft:cat_sound_variant 1 cobolcraft:placeholder cobolcraft:placeholder 925".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-cat-variant".
    05 FILLER PIC X(300) VALUE "minecraft:cat_variant 1 cobolcraft:placeholder cobolcraft:placeholder 139".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-chat-type-standard".
    05 FILLER PIC X(300) VALUE "minecraft:chat_type 3 minecraft:chat minecraft:msg_command_incoming 660".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-chat-type".
    05 FILLER PIC X(300) VALUE "minecraft:chat_type 1 cobolcraft:say cobolcraft:say 217".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-chicken-sound-variant".
    05 FILLER PIC X(300) VALUE "minecraft:chicken_sound_variant 1 cobolcraft:placeholder cobolcraft:placeholder 451".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-chicken-variant".
    05 FILLER PIC X(300) VALUE "minecraft:chicken_variant 1 cobolcraft:placeholder cobolcraft:placeholder 159".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-cow-sound-variant".
    05 FILLER PIC X(300) VALUE "minecraft:cow_sound_variant 1 cobolcraft:placeholder cobolcraft:placeholder 236".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-cow-variant".
    05 FILLER PIC X(300) VALUE "minecraft:cow_variant 1 cobolcraft:placeholder cobolcraft:placeholder 155".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-damage-type".
    05 FILLER PIC X(300) VALUE "minecraft:damage_type 32 cobolcraft:generic cobolcraft:hail 2893".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-dimension-type-standard".
    05 FILLER PIC X(300) VALUE "minecraft:dimension_type 3 minecraft:overworld minecraft:the_end 1109".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-dimension-type".
    05 FILLER PIC X(300) VALUE "minecraft:dimension_type 2 cobolcraft:surface cobolcraft:sunless 617".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-enchantment".
    05 FILLER PIC X(300) VALUE "minecraft:enchantment 1 minecraft:efficiency minecraft:efficiency 527".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-frog-variant".
    05 FILLER PIC X(300) VALUE "minecraft:frog_variant 1 cobolcraft:placeholder cobolcraft:placeholder 93".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-painting-variant".
    05 FILLER PIC X(300) VALUE "minecraft:painting_variant 1 cobolcraft:placeholder cobolcraft:placeholder 136".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-pig-sound-variant".
    05 FILLER PIC X(300) VALUE "minecraft:pig_sound_variant 1 cobolcraft:placeholder cobolcraft:placeholder 533".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-pig-variant".
    05 FILLER PIC X(300) VALUE "minecraft:pig_variant 1 cobolcraft:placeholder cobolcraft:placeholder 155".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-timeline".
    05 FILLER PIC X(300) VALUE "minecraft:timeline 2 minecraft:day minecraft:moon 3759".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-wolf-sound-variant".
    05 FILLER PIC X(300) VALUE "minecraft:wolf_sound_variant 1 cobolcraft:placeholder cobolcraft:placeholder 716".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-wolf-variant".
    05 FILLER PIC X(300) VALUE "minecraft:wolf_variant 1 cobolcraft:placeholder cobolcraft:placeholder 306".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-world-clock".
    05 FILLER PIC X(300) VALUE "minecraft:world_clock 1 cobolcraft:daylight cobolcraft:daylight 47".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-worldgen-biome".
    05 FILLER PIC X(300) VALUE "minecraft:worldgen/biome 3 minecraft:plains cobolcraft:ash_flats 500".
    05 FILLER PIC X(100) VALUE "config-s2c-07-registry-data-zombie-nautilus-variant".
    05 FILLER PIC X(300) VALUE "minecraft:zombie_nautilus_variant 1 cobolcraft:placeholder cobolcraft:placeholder 120".
 01 WS-REGISTRIES REDEFINES WS-REGISTRY-TABLE.
    05 WS-RG                  OCCURS 22 TIMES.
       10 WS-RG-NAME          PIC X(100).
       10 WS-RG-FIELDS        PIC X(300).
 01 WS-TAGS-TABLE.
    05 FILLER PIC X(100) VALUE "config-s2c-0e-update-tags".
    05 FILLER PIC X(300) VALUE "0".
    05 FILLER PIC X(100) VALUE "config-s2c-0e-update-tags-standard".
    05 FILLER PIC X(300) VALUE "3 minecraft:block(2) minecraft:planks=13 minecraft:base_stone_overworld=1,12 minecraft:item(1) minecraft:planks=63 minecraft:dimension_type(1) minecraft:in_overworld=0".
 01 WS-TAGSS REDEFINES WS-TAGS-TABLE.
    05 WS-TG                  OCCURS 2 TIMES.
       10 WS-TG-NAME          PIC X(100).
       10 WS-TG-FIELDS        PIC X(300).
 01 RG-NAME                PIC X(64).
 01 RG-NAME-CAP            BINARY-LONG VALUE 64.
 01 RG-NAME-LEN            BINARY-LONG.
 01 RG-COUNT               BINARY-LONG.
 01 RG-PRESENT             BINARY-LONG.
 01 RG-DATA                PIC X(8192).
 01 RG-DATA-CAP            BINARY-LONG VALUE 8192.
 01 RG-DATA-LEN            BINARY-LONG.
 01 RG-FIRST               PIC X(64).
 01 RG-FIRST-LEN           BINARY-LONG.
 01 RG-LAST                PIC X(64).
 01 RG-LAST-LEN            BINARY-LONG.
 01 RG-TAG-IDS.
    05 RG-TAG-ID           BINARY-LONG OCCURS 256 TIMES.
 01 RG-ID-CAP              BINARY-LONG VALUE 256.
 01 RG-SAME                BINARY-LONG.
 01 RG-ZERO                BINARY-LONG VALUE 0.
 01 CH-SECTIONS            BINARY-LONG VALUE 24.
 01 CH-HM-BITS             BINARY-LONG VALUE 9.
 01 CH-HM-MASK             BINARY-LONG.
 01 CH-BLOCK-GBITS         BINARY-LONG VALUE 16.
 01 CH-BIOME-GBITS         BINARY-LONG VALUE 7.
 01 CH-BE-MAX              BINARY-LONG VALUE 16.
 01 CH-BE-DATA-MAX         BINARY-LONG VALUE 1024.
 01 CH-BE-COUNT            BINARY-LONG.
 01 CH-X                   BINARY-LONG.
 01 CH-Z                   BINARY-LONG.
 01 CH-SUM                 BINARY-DOUBLE.
 01 CH-SUM-2               BINARY-DOUBLE.
 01 CH-SUM-3               BINARY-DOUBLE.
 01 CH-LIGHT-COUNT         BINARY-LONG VALUE 26.
 01 CH-HM-VALUES.
    05 CH-HM               BINARY-LONG OCCURS 1536 TIMES.
 01 CH-COUNTS.
    05 CH-COUNT-ENTRY      BINARY-LONG OCCURS 48 TIMES.
 01 CH-STATES.
    05 CH-STATE            BINARY-LONG OCCURS 98304 TIMES.
 01 CH-BIOMES.
    05 CH-BIOME            BINARY-LONG OCCURS 1536 TIMES.
 01 CH-BE-HEADS.
    05 CH-BE-HEAD          BINARY-LONG OCCURS 80 TIMES.
 01 CH-BE-DATA             PIC X(1024).
 01 CH-SKY-STATES.
    05 CH-SKY-STATE        BINARY-LONG OCCURS 26 TIMES.
 01 CH-BLK-STATES.
    05 CH-BLK-STATE        BINARY-LONG OCCURS 26 TIMES.
 01 CH-SKY-ARRAYS.
    05 CH-SKY-ARRAY        PIC X(2048) OCCURS 26 TIMES.
 01 CH-BLK-ARRAYS.
    05 CH-BLK-ARRAY        PIC X(2048) OCCURS 26 TIMES.

 01 LV-EDIT-BIG            PIC -(19)9.
 01 LV-FLT                 PIC -(5)9.99.
 01 LV-DUMP                PIC X(1100).
 01 LV-DATA                PIC X(64).
 01 LV-NBT                 PIC X(256).
 01 LV-NBT-CAP             BINARY-LONG VALUE 256.
 01 LV-NBT-LEN             BINARY-LONG.
 01 LV-KEEP                BINARY-LONG.
 01 LV-EVENT               BINARY-LONG.
 01 LV-DATA-INT            BINARY-LONG.
 01 LV-GLOBAL              BINARY-LONG.
 01 LV-P0                  BINARY-LONG.
 01 LV-P1                  BINARY-LONG.
 01 LV-BLOCK               BINARY-LONG.
 01 LV-TYPE                BINARY-LONG.
 01 LV-X                   BINARY-LONG.
 01 LV-Y                   BINARY-LONG.
 01 LV-Z                   BINARY-LONG.
 01 LV-I                   BINARY-LONG.
 01 LV-PARTICLE-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-30-level-particles".
    05 FILLER PIC X(300) VALUE "1 3 1 0 -1.50 3.00 8.25 0.00 0.00 0.00 0.00 0.00 0.00 0 0".
    05 FILLER PIC X(100) VALUE "play-s2c-30-level-particles-dust".
    05 FILLER PIC X(300) VALUE "21 8 0 1 0.50 65.00 0.50 0.25 0.50 0.25 0.00 0.00 0.00 7 1".
 01 LV-PARTICLES REDEFINES LV-PARTICLE-TABLE.
    05 LV-PA                  OCCURS 2 TIMES.
       10 LV-PA-NAME          PIC X(100).
       10 LV-PA-FIELDS        PIC X(300).
 01 LV-LOGIN-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-32-login-main".
    05 FILLER PIC X(300) VALUE
       "1 0 1 cobolcraft:main 20 8 8 0 1 0 0 0 0 cobolcraft:main 0 0 -1 0 0 - 0 48".
    05 FILLER PIC X(100) VALUE "play-s2c-32-login-all-dimensions".
    05 FILLER PIC X(300) VALUE
       "1 0 2 cobolcraft:main cobolcraft:subroutine 20 8 8 0 1 0 0 0 0 cobolcraft:main 0 0 -1 0 0 - 0 48".
    05 FILLER PIC X(100) VALUE "play-s2c-32-login-all-dimensions-standard".
    05 FILLER PIC X(300) VALUE
       "1 0 3 minecraft:overworld minecraft:the_nether minecraft:the_end 20 10 10 0 1 0 0 0 0 minecraft:overworld 1234605616436508552 1 0 0 0 minecraft:overworld 10 64 -10 0 63".
 01 LV-LOGINS REDEFINES LV-LOGIN-TABLE.
    05 LV-LG                  OCCURS 3 TIMES.
       10 LV-LG-NAME          PIC X(100).
       10 LV-LG-FIELDS        PIC X(300).
 01 LV-RESPAWN-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-54-respawn-main".
    05 FILLER PIC X(300) VALUE "0 cobolcraft:main 0 0 -1 0 0 - 0 48 3".
    05 FILLER PIC X(100) VALUE "play-s2c-54-respawn-subroutine".
    05 FILLER PIC X(300) VALUE "1 cobolcraft:subroutine 0 0 -1 0 0 - 0 32 3".
    05 FILLER PIC X(100) VALUE "play-s2c-54-respawn-main-standard".
    05 FILLER PIC X(300) VALUE
       "0 minecraft:overworld 1234605616436508552 1 0 0 0 minecraft:overworld 10 64 -10 0 63 0".
    05 FILLER PIC X(100) VALUE "play-s2c-54-respawn-the-nether-standard".
    05 FILLER PIC X(300) VALUE
       "1 minecraft:the_nether 1234605616436508552 1 0 0 0 minecraft:overworld 10 64 -10 0 32 1".
    05 FILLER PIC X(100) VALUE "play-s2c-54-respawn-the-end-standard".
    05 FILLER PIC X(300) VALUE
       "2 minecraft:the_end 1234605616436508552 1 0 0 0 minecraft:overworld 10 64 -10 0 0 3".
 01 LV-RESPAWNS REDEFINES LV-RESPAWN-TABLE.
    05 LV-RS                  OCCURS 5 TIMES.
       10 LV-RS-NAME          PIC X(100).
       10 LV-RS-FIELDS        PIC X(300).
 01 CM-COUNT              BINARY-LONG.
 01 CM-ROOT               BINARY-LONG.
 01 CM-I                  BINARY-LONG.
 01 CM-BITS               BINARY-LONG.
 01 CM-TYPE               BINARY-LONG.
 01 CM-TALLY.
    05 CM-LIT             BINARY-LONG.
    05 CM-ARG             BINARY-LONG.
    05 CM-EXEC            BINARY-LONG.
    05 CM-RESTRICTED      BINARY-LONG.
    05 CM-REDIRECT        BINARY-LONG.
    05 CM-SUGGEST         BINARY-LONG.
 01 CM-TRANS              BINARY-LONG.
 01 CM-LEN                BINARY-LONG.
 01 CM-XS                 BINARY-LONG.
 01 CM-TEXT               PIC X(300).
 01 CM-COMMANDS-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-10-commands-everyone".
    05 FILLER PIC X(300) VALUE "6 0 3 2 3 0 0 1".
    05 FILLER PIC X(100) VALUE "play-s2c-10-commands-operator".
    05 FILLER PIC X(300) VALUE "90 0 42 47 44 0 0 22".
    05 FILLER PIC X(100) VALUE "play-s2c-10-commands-all-parsers".
    05 FILLER PIC X(300) VALUE "67 0 3 63 64 1 1 1".
 01 CM-COMMANDS REDEFINES CM-COMMANDS-TABLE.
    05 CM-CO                  OCCURS 3 TIMES.
       10 CM-CO-NAME          PIC X(100).
       10 CM-CO-FIELDS        PIC X(300).
 01 CM-REQUEST-TABLE.
    05 FILLER PIC X(100) VALUE "play-c2s-0f-command-suggestion".
    05 FILLER PIC X(300) VALUE "1 /murmur Al".
    05 FILLER PIC X(100) VALUE "play-c2s-0f-command-suggestion-standard".
    05 FILLER PIC X(300) VALUE "300 /gamemode c".
 01 CM-REQUESTS REDEFINES CM-REQUEST-TABLE.
    05 CM-RQ                  OCCURS 2 TIMES.
       10 CM-RQ-NAME          PIC X(100).
       10 CM-RQ-FIELDS        PIC X(300).
 01 CM-SUGGESTIONS-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-0f-command-suggestions".
    05 FILLER PIC X(300) VALUE "1 8 2 1 Alice".
    05 FILLER PIC X(100) VALUE "play-s2c-0f-command-suggestions-standard".
    05 FILLER PIC X(300) VALUE "300 10 1 2 creative c+p:short".
 01 CM-SUGGESTIONS REDEFINES CM-SUGGESTIONS-TABLE.
    05 CM-SG                  OCCURS 2 TIMES.
       10 CM-SG-NAME          PIC X(100).
       10 CM-SG-FIELDS        PIC X(300).
 01 CM-COMMAND-TABLE.
    05 FILLER PIC X(100) VALUE "play-c2s-07-chat-command".
    05 FILLER PIC X(300) VALUE "13 promote Alice".
    05 FILLER PIC X(100) VALUE "play-c2s-07-chat-command-standard".
    05 FILLER PIC X(300) VALUE "144 gamemode creative x120 Steve".
 01 CM-COMMAND-LINES REDEFINES CM-COMMAND-TABLE.
    05 CM-CL                  OCCURS 2 TIMES.
       10 CM-CL-NAME          PIC X(100).
       10 CM-CL-FIELDS        PIC X(300).
 01 CM-DISGUISED-TABLE.
    05 FILLER PIC X(100) VALUE "play-s2c-21-disguised-chat".
    05 FILLER PIC X(300) VALUE "p:waves 1 Alice -".
    05 FILLER PIC X(100) VALUE "play-s2c-21-disguised-chat-say".
    05 FILLER PIC X(300) VALUE "p:restart soon 1 Server -".
    05 FILLER PIC X(100) VALUE "play-s2c-21-disguised-chat-msg-incoming".
    05 FILLER PIC X(300) VALUE "p:psst 2 Alice p:Bob".
 01 CM-DISGUISED REDEFINES CM-DISGUISED-TABLE.
    05 CM-DG                  OCCURS 3 TIMES.
       10 CM-DG-NAME          PIC X(100).
       10 CM-DG-FIELDS        PIC X(300).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-D-NAME(WS-I) TO WS-NAME
         MOVE WS-D-FIELDS(WS-I) TO WS-STATED
         PERFORM DESTRUCTION-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-A-NAME(WS-I) TO WS-NAME
         MOVE WS-A-FIELDS(WS-I) TO WS-STATED
         PERFORM ACTION-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE WS-SL-NAME(WS-I) TO WS-NAME
         MOVE WS-SL-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM SET-SLOT-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE WS-CU-NAME(WS-I) TO WS-NAME
         MOVE WS-CU-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM CURSOR-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-CT-NAME(WS-I) TO WS-NAME
         MOVE WS-CT-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM CONTENT-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-CK-NAME(WS-I) TO WS-NAME
         MOVE WS-CK-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM CLICK-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE WS-SC-NAME(WS-I) TO WS-NAME
         MOVE WS-SC-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM SCREEN-CASE
     END-PERFORM
     MOVE "play-c2s-13-container-close" TO WS-NAME
     MOVE "0" TO WS-STATED-LONG
     PERFORM CLOSE-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE WS-PL-NAME(WS-I) TO WS-NAME
         MOVE WS-PL-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM PLACE-CASE
     END-PERFORM
     MOVE "play-c2s-30-recipe-book-seen-recipe" TO WS-NAME
     MOVE "300" TO WS-STATED-LONG
     PERFORM SEEN-CASE
     MOVE "play-c2s-2f-recipe-book-change-settings" TO WS-NAME
     MOVE "1 1 0" TO WS-STATED-LONG
     PERFORM CHANGE-CASE
     MOVE "play-s2c-4c-recipe-book-remove" TO WS-NAME
     MOVE "0 1 300" TO WS-STATED-LONG
     PERFORM REMOVE-CASE
     MOVE "play-s2c-4d-recipe-book-settings" TO WS-NAME
     MOVE "1 0 0 1 1 1 0 0" TO WS-STATED-LONG
     PERFORM SETTINGS-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-AD-NAME(WS-I) TO WS-NAME
         MOVE WS-AD-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM ADD-CASE
     END-PERFORM
     MOVE "play-s2c-2e-level-chunk-with-light-standard-24-sections" TO WS-NAME
     MOVE "0 0 50 0 73728 61782688 2434" TO WS-STATED-LONG
     PERFORM CHUNK-CASE
     MOVE "play-s2c-31-light-update-standard" TO WS-NAME
     MOVE "-1 2 11111111111111111111111122 1112111111111111111111111" TO WS-STATED-LONG
     PERFORM LIGHT-UPDATE-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22
         MOVE WS-RG-NAME(WS-I) TO WS-NAME
         MOVE WS-RG-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM REGISTRY-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE WS-TG-NAME(WS-I) TO WS-NAME
         MOVE WS-TG-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM TAGS-CASE
     END-PERFORM
     MOVE "play-s2c-2f-level-event" TO WS-NAME
     MOVE "2001 -3 12 9 88 0" TO WS-STATED-LONG
     PERFORM LEVEL-EVENT-CASE
     MOVE "play-s2c-07-block-event-standard" TO WS-NAME
     MOVE "3 64 -5 1 2 300" TO WS-STATED-LONG
     PERFORM BLOCK-EVENT-CASE
     MOVE "play-s2c-06-block-entity-data-standard" TO WS-NAME
     MOVE "-8 70 21 7 25 0a01000869735f7761786564010800046e6f74650002686900" TO WS-STATED-LONG
     PERFORM BLOCK-ENTITY-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE LV-PA-NAME(WS-I) TO WS-NAME
         MOVE LV-PA-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM PARTICLES-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE LV-LG-NAME(WS-I) TO WS-NAME
         MOVE LV-LG-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM LOGIN-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE LV-RS-NAME(WS-I) TO WS-NAME
         MOVE LV-RS-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM RESPAWN-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE CM-CO-NAME(WS-I) TO WS-NAME
         MOVE CM-CO-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM COMMANDS-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE CM-RQ-NAME(WS-I) TO WS-NAME
         MOVE CM-RQ-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM SUGGESTION-REQUEST-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE CM-SG-NAME(WS-I) TO WS-NAME
         MOVE CM-SG-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM SUGGESTIONS-CASE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE CM-CL-NAME(WS-I) TO WS-NAME
         MOVE CM-CL-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM CHAT-COMMAND-CASE
     END-PERFORM
     MOVE "play-s2c-42-player-chat" TO WS-NAME
     MOVE SPACES TO WS-STATED-LONG
     STRING "5 000000000000000000000000000000a1 2 0 hello 1700000000000 0 0 -1 0 0 "
         "Alice -" DELIMITED BY SIZE INTO WS-STATED-LONG
     PERFORM PLAYER-CHAT-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE CM-DG-NAME(WS-I) TO WS-NAME
         MOVE CM-DG-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM DISGUISED-CASE
     END-PERFORM
     MOVE "play-s2c-86-update-attributes" TO WS-NAME
     MOVE "300 2 23 20.00 0 26 0.10 1 minecraft:sprinting 0.30 2" TO WS-STATED-LONG
     PERFORM ATTRIBUTES-CASE
     MOVE "play-s2c-87-update-mob-effect" TO WS-NAME
     MOVE "300 2 1 600 7" TO WS-STATED-LONG
     PERFORM EFFECT-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE WS-SPN-NAME(WS-I) TO WS-NAME
         MOVE WS-SPN-FIELDS(WS-I) TO WS-STATED-LONG
         PERFORM SPAWN-CASE
     END-PERFORM
     MOVE "play-s2c-65-set-entity-data-item" TO WS-NAME
     MOVE "10 0.7=1x4 end" TO WS-STATED-LONG
     PERFORM DATA-CASE
     MOVE "play-s2c-65-set-entity-data-living" TO WS-NAME
     MOVE "301 0.0=0 2.6=080006426573736965 9.3=10.00 end" TO WS-STATED-LONG
     PERFORM DATA-CASE
     MOVE "play-s2c-65-set-entity-data-all-serializers" TO WS-NAME
     MOVE "300" TO WS-STATED-LONG
     MOVE " 0.0=32 1.1=300 2.2=5000000000 3.3=1.50 4.4=name 5.5=08000163 6.6=0800016f 7.7=3x63"
         & " 8.8=1 9.9=1.00,2.00,3.00 10.10=-1,64,2 11.11=5,6,7 12.12=4"
         & " 13.13=000000000000000000000000000000b1 14.14=88 15.15=0 16.16=1500ff88003f800000"
         & " 17.17=0137 18.18=2,9,3 19.19=8 20.20=5 21.21=1 22.22=2 23.23=3 24.24=4 25.25=5"
         & " 26.26=6 27.27=7 28.28=8 29.29=9 30.30=10 31.31=11 32.32=12"
         & " 33.33=136d696e6563726166743a6f766572776f726c640000004000003002 34.34=04 35.35=3"
         & " 36.36=2 37.37=1 38.38=3 39.39=0.50,1.50,-2.00 40.40=0.00,0.00,0.00,1.00"
         & " 41.41=0001055374657665000000000000 42.42=1 43.43=11 end" TO WS-STATED-LONG(4:)
     PERFORM DATA-CASE
     MOVE "play-s2c-22-entity-event-poof" TO WS-NAME
     MOVE "300 60" TO WS-STATED-LONG
     PERFORM EVENT-CASE
     MOVE "play-s2c-22-entity-event-eating-finished" TO WS-NAME
     MOVE "1 9" TO WS-STATED-LONG
     PERFORM EVENT-CASE
     MOVE "play-s2c-22-entity-event-permission-level" TO WS-NAME
     MOVE "1 28" TO WS-STATED-LONG
     PERFORM EVENT-CASE
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     STOP RUN.

*> Level Chunk With Light, 24 sections: x z heightmap mask, block entities, the non-empty block total,
*> the sums of every block state id and every biome id (read from the fixture with an independent
*> decoder), then the same fields written again equal the fixture.
 CHUNK-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-CHUNK-24" USING PB-BUFFER CH-X CH-Z CH-SECTIONS CH-HM-BITS CH-HM-MASK CH-HM-VALUES
         CH-COUNTS CH-STATES CH-BIOMES CH-BLOCK-GBITS CH-BIOME-GBITS CH-BE-MAX CH-BE-DATA-MAX
         CH-BE-COUNT CH-BE-HEADS CH-BE-DATA CH-SKY-STATES CH-SKY-ARRAYS CH-BLK-STATES
         CH-BLK-ARRAYS
     MOVE 0 TO CH-SUM CH-SUM-2 CH-SUM-3
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 24
         ADD CH-COUNT-ENTRY(WS-J * 2 - 1) TO CH-SUM
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 98304
         ADD CH-STATE(WS-J) TO CH-SUM-2
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 1536
         ADD CH-BIOME(WS-J) TO CH-SUM-3
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " decodes to the stated fields"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-STATED-LONG TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE CH-X TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CH-Z TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CH-HM-MASK TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CH-BE-COUNT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CH-SUM TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CH-SUM-2 TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CH-SUM-3 TO WS-EDIT
     PERFORM ADD-FIELD
     IF PB-ERROR NOT = 0 OR PB-POS NOT = PB-LENGTH
         STRING " unread-or-error" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-CHUNK-24" USING PK-BUFFER CH-X CH-Z CH-SECTIONS CH-HM-BITS CH-HM-MASK CH-HM-VALUES
         CH-COUNTS CH-STATES CH-BIOMES CH-BLOCK-GBITS CH-BIOME-GBITS CH-BE-COUNT CH-BE-HEADS
         CH-BE-DATA CH-SKY-STATES CH-SKY-ARRAYS CH-BLK-STATES CH-BLK-ARRAYS
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " re-encodes to the fixture bytes"
         DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-SAME-BYTES-BIG.

*> Light Update: VarInt chunk x and z, then the light of 26 indices; the stated fields are x z and
*> the sky and block states of the indices as digits (0 none, 1 empty, 2 array).
 LIGHT-UPDATE-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-X
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-Z
     CALL "LIGHT-DECODE" USING PB-BUFFER CH-LIGHT-COUNT CH-SKY-STATES CH-SKY-ARRAYS
         CH-BLK-STATES CH-BLK-ARRAYS
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " decodes to the stated fields"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-STATED-LONG TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-X TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-Z TO WS-EDIT
     PERFORM ADD-FIELD
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 26
         MOVE CH-SKY-STATE(WS-J) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 25
         MOVE CH-BLK-STATE(WS-J) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     IF PB-ERROR NOT = 0 OR PB-POS NOT = PB-LENGTH
         STRING " unread-or-error" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PK-BUFFER WS-X
     CALL "PB-PUT-VARINT" USING PK-BUFFER WS-Z
     CALL "LIGHT-ENCODE" USING PK-BUFFER CH-LIGHT-COUNT CH-SKY-STATES CH-SKY-ARRAYS
         CH-BLK-STATES CH-BLK-ARRAYS
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " re-encodes to the fixture bytes"
         DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-SAME-BYTES-BIG.

*> Registry Data: registry key, entry count, first and last entry id and the packet length; the
*> entries are written again one by one as they are read.
 REGISTRY-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-REGISTRY-DATA-HEAD" USING PB-BUFFER RG-NAME RG-NAME-CAP RG-NAME-LEN RG-COUNT
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PK-BUFFER RG-NAME RG-NAME-LEN RG-COUNT
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " decodes to the stated fields"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-STATED-LONG TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING RG-NAME(1:RG-NAME-LEN) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE RG-COUNT TO WS-COUNT
     MOVE RG-COUNT TO WS-EDIT
     STRING " " FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
         CALL "PB-GET-REGISTRY-ENTRY" USING PB-BUFFER RG-FIRST RG-NAME-CAP RG-FIRST-LEN
             RG-PRESENT RG-DATA RG-DATA-CAP RG-DATA-LEN
         CALL "PB-PUT-REGISTRY-ENTRY" USING PK-BUFFER RG-FIRST RG-FIRST-LEN RG-PRESENT RG-DATA
             RG-DATA-LEN
         IF WS-J = 1
             STRING RG-FIRST(1:RG-FIRST-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED
                 WITH POINTER WS-PTR
         END-IF
         MOVE RG-FIRST TO RG-LAST
         MOVE RG-FIRST-LEN TO RG-LAST-LEN
     END-PERFORM
     STRING RG-LAST(1:RG-LAST-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE PB-LENGTH TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     IF PB-ERROR NOT = 0 OR PB-POS NOT = PB-LENGTH
         STRING " unread-or-error" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " re-encodes to the fixture bytes"
         DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-SAME-BYTES-BIG.

*> Update Tags: the registry count, then per registry " <key>(<tag count>)" and per tag
*> " <name>=<id>,<id>"; written again as read.
 TAGS-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-TAGS-HEAD" USING PB-BUFFER WS-COUNT
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-TAGS-HEAD" USING PK-BUFFER WS-COUNT
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " decodes to the stated fields"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-STATED-LONG TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-COUNT TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-COUNT TO WS-K
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-K
         CALL "PB-GET-TAG-REGISTRY-HEAD" USING PB-BUFFER RG-NAME RG-NAME-CAP RG-NAME-LEN
             RG-COUNT
         CALL "PB-PUT-TAG-REGISTRY-HEAD" USING PK-BUFFER RG-NAME RG-NAME-LEN RG-COUNT
         MOVE RG-COUNT TO WS-EDIT
         STRING " " RG-NAME(1:RG-NAME-LEN) "(" FUNCTION TRIM(WS-EDIT) ")" DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE RG-COUNT TO WS-MAX
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-MAX
             CALL "PB-GET-TAG" USING PB-BUFFER RG-FIRST RG-NAME-CAP RG-FIRST-LEN RG-TAG-IDS
                 RG-ID-CAP RG-COUNT
             CALL "PB-PUT-TAG" USING PK-BUFFER RG-FIRST RG-FIRST-LEN RG-TAG-IDS RG-COUNT
             STRING " " RG-FIRST(1:RG-FIRST-LEN) "=" DELIMITED BY SIZE INTO TL-OBSERVED
                 WITH POINTER WS-PTR
             PERFORM VARYING WS-LEN FROM 1 BY 1 UNTIL WS-LEN > RG-COUNT
                 MOVE RG-TAG-ID(WS-LEN) TO WS-EDIT
                 IF WS-LEN > 1
                     STRING "," DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
                 END-IF
                 STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
                     WITH POINTER WS-PTR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF PB-ERROR NOT = 0 OR PB-POS NOT = PB-LENGTH
         STRING " unread-or-error" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " re-encodes to the fixture bytes"
         DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-SAME-BYTES-BIG.

 DESTRUCTION-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-BLOCK-DESTRUCTION" USING PB-BUFFER WS-ENTITY WS-X WS-Y WS-Z WS-STAGE
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " decodes to the stated fields"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-STATED TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-ENTITY TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-X TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-Y TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-Z TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-STAGE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-ERROR TO WS-EDIT
     IF PB-ERROR NOT = 0 OR PB-POS NOT = PB-LENGTH
         STRING " unread-or-error" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-BLOCK-DESTRUCTION" USING PK-BUFFER WS-ENTITY WS-X WS-Y WS-Z WS-STAGE
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " re-encodes to the fixture bytes"
         DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-SAME-BYTES.

 ACTION-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-PLAYER-ACTION" USING PB-BUFFER WS-STATUS WS-X WS-Y WS-Z WS-FACE WS-SEQUENCE
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " decodes to the stated fields"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-STATED TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-STATUS TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-X TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-Y TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-Z TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-FACE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-SEQUENCE TO WS-EDIT
     PERFORM ADD-FIELD
     IF PB-ERROR NOT = 0 OR PB-POS NOT = PB-LENGTH
         STRING " unread-or-error" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-PLAYER-ACTION" USING PK-BUFFER WS-STATUS WS-X WS-Y WS-Z WS-FACE WS-SEQUENCE
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " re-encodes to the fixture bytes"
         DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-SAME-BYTES.

*> ---- helpers that build TL-OBSERVED ----
 START-OBSERVED.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR.

 PUT-NUM.
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR.

 PUT-SPACE.
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR.

*> The stack of PB-ITEMSTACK-X as "<count>x<item>", then " +<type>=<value hex>" per added
*> component and " -<type>" per removed one; "empty" for count 0.
 DESC-STACK.
     IF PB-ISX-COUNT <= 0
         STRING "empty" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         MOVE PB-ISX-COUNT TO WS-EDIT
         PERFORM PUT-NUM
         STRING "x" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE PB-ISX-ITEM TO WS-EDIT
         PERFORM PUT-NUM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-ISX-ADDED-COUNT
             STRING " +" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             MOVE PB-ISX-TYPE(WS-K) TO WS-EDIT
             PERFORM PUT-NUM
             MOVE PB-ISX-VALUE-LENGTH(WS-K) TO WS-LEN
             IF WS-LEN > 0
                 STRING "=" FUNCTION LOWER-CASE(FUNCTION HEX-OF(PB-ISX-VALUE(WS-K)(1:WS-LEN)))
                     DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
         END-PERFORM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-ISX-REMOVED-COUNT
             STRING " -" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             MOVE PB-ISX-REMOVED(WS-K) TO WS-EDIT
             PERFORM PUT-NUM
         END-PERFORM
     END-IF.

*> The hashed stack of PB-HASHED-STACK: "empty" or "<count>x<item>", " +<type>=<hash>", " -<type>".
 DESC-HASHED.
     IF PB-HS-PRESENT = 0
         STRING "empty" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         MOVE PB-HS-COUNT TO WS-EDIT
         PERFORM PUT-NUM
         STRING "x" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE PB-HS-ITEM TO WS-EDIT
         PERFORM PUT-NUM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-HS-ADDED-COUNT
             STRING " +" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             MOVE PB-HS-TYPE(WS-K) TO WS-EDIT
             PERFORM PUT-NUM
             STRING "=" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             MOVE PB-HS-HASH(WS-K) TO WS-EDIT
             PERFORM PUT-NUM
         END-PERFORM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-HS-REMOVED-COUNT
             STRING " -" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             MOVE PB-HS-REMOVED(WS-K) TO WS-EDIT
             PERFORM PUT-NUM
         END-PERFORM
     END-IF.

*> Case name for the decode and re-encode assertions of WS-NAME.
 NAME-DECODE.
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " decodes to the stated fields"
         DELIMITED BY SIZE INTO TL-CASE.

 NAME-ENCODE.
     MOVE SPACES TO TL-CASE
     STRING "contract wire provider " FUNCTION TRIM(WS-NAME) " re-encodes to the fixture bytes"
         DELIMITED BY SIZE INTO TL-CASE.

*> Asserts the decode: the observed fields, plus a marker when bytes are unread or PB-ERROR is set.
 CHECK-DECODE.
     IF PB-ERROR NOT = 0 OR PB-POS NOT = PB-LENGTH
         STRING " unread-or-error" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     PERFORM NAME-DECODE
     MOVE "T" TO TL-MODE
     MOVE WS-STATED-LONG TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-ENCODE.
     PERFORM NAME-ENCODE
     PERFORM CHECK-SAME-BYTES.

 SET-SLOT-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-CONTAINER-SET-SLOT" USING PB-BUFFER WS-CONTAINER WS-STATE WS-SLOT
         PB-ITEMSTACK-X
     PERFORM START-OBSERVED
     MOVE WS-CONTAINER TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-STATE TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-SLOT TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     PERFORM DESC-STACK
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-CONTAINER-SET-SLOT" USING PK-BUFFER WS-CONTAINER WS-STATE WS-SLOT
         PB-ITEMSTACK-X
     PERFORM CHECK-ENCODE.

 CURSOR-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     PERFORM START-OBSERVED
     PERFORM DESC-STACK
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-ITEM-STACK" USING PK-BUFFER PB-ITEMSTACK-X
     PERFORM CHECK-ENCODE.

*> Set Content: head, then count stacks and the carried stack; each is re-encoded as it is read.
 CONTENT-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-GET-CONTAINER-CONTENT-HEAD" USING PB-BUFFER WS-CONTAINER WS-STATE WS-COUNT
     CALL "PB-PUT-CONTAINER-CONTENT-HEAD" USING PK-BUFFER WS-CONTAINER WS-STATE WS-COUNT
     PERFORM START-OBSERVED
     MOVE WS-CONTAINER TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-STATE TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-COUNT TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM VARYING WS-SLOT FROM 0 BY 1 UNTIL WS-SLOT >= WS-COUNT
         CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
         CALL "PB-PUT-ITEM-STACK" USING PK-BUFFER PB-ITEMSTACK-X
         IF PB-ISX-COUNT > 0
             PERFORM PUT-SPACE
             MOVE WS-SLOT TO WS-EDIT
             PERFORM PUT-NUM
             STRING ":" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             PERFORM DESC-STACK
         END-IF
     END-PERFORM
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     CALL "PB-PUT-ITEM-STACK" USING PK-BUFFER PB-ITEMSTACK-X
     PERFORM PUT-SPACE
     STRING "carried " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM DESC-STACK
     PERFORM CHECK-DECODE
     PERFORM CHECK-ENCODE.

*> Click: head, count changed slots, carried stack; re-encoded as read.
 CLICK-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-GET-CONTAINER-CLICK-HEAD" USING PB-BUFFER WS-CONTAINER WS-STATE WS-SLOT
         WS-BUTTON WS-CLICK-TYPE WS-COUNT
     CALL "PB-PUT-CONTAINER-CLICK-HEAD" USING PK-BUFFER WS-CONTAINER WS-STATE WS-SLOT
         WS-BUTTON WS-CLICK-TYPE WS-COUNT
     PERFORM START-OBSERVED
     MOVE WS-CONTAINER TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-STATE TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-SLOT TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-BUTTON TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-CLICK-TYPE TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-COUNT TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
         CALL "PB-GET-CLICK-CHANGED" USING PB-BUFFER WS-SLOT PB-HASHED-STACK
         CALL "PB-PUT-CLICK-CHANGED" USING PK-BUFFER WS-SLOT PB-HASHED-STACK
         PERFORM PUT-SPACE
         MOVE WS-SLOT TO WS-EDIT
         PERFORM PUT-NUM
         STRING ":" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         PERFORM DESC-HASHED
     END-PERFORM
     CALL "PB-GET-HASHED-STACK" USING PB-BUFFER PB-HASHED-STACK
     CALL "PB-PUT-HASHED-STACK" USING PK-BUFFER PB-HASHED-STACK
     PERFORM PUT-SPACE
     STRING "carried " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM DESC-HASHED
     PERFORM CHECK-DECODE
     PERFORM CHECK-ENCODE.

 SCREEN-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-OPEN-SCREEN" USING PB-BUFFER WS-CONTAINER WS-MENU PB-TEXT
     PERFORM START-OBSERVED
     MOVE WS-CONTAINER TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-MENU TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     EVALUATE PB-TX-KIND
         WHEN PB-TEXT-PLAIN
             STRING "plain " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         WHEN PB-TEXT-LITERAL
             STRING "literal " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         WHEN OTHER
             STRING "translate " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-EVALUATE
     MOVE PB-TX-LENGTH TO WS-LEN
     STRING PB-TX-VALUE(1:WS-LEN) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-OPEN-SCREEN" USING PK-BUFFER WS-CONTAINER WS-MENU PB-TEXT
     PERFORM CHECK-ENCODE.

 CLOSE-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-CONTAINER-CLOSE" USING PB-BUFFER WS-CONTAINER
     PERFORM START-OBSERVED
     MOVE WS-CONTAINER TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-CONTAINER-CLOSE" USING PK-BUFFER WS-CONTAINER
     PERFORM CHECK-ENCODE.

 PLACE-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-PLACE-RECIPE" USING PB-BUFFER WS-CONTAINER WS-RECIPE WS-MAX
     PERFORM START-OBSERVED
     MOVE WS-CONTAINER TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-RECIPE TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-MAX TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-PLACE-RECIPE" USING PK-BUFFER WS-CONTAINER WS-RECIPE WS-MAX
     PERFORM CHECK-ENCODE.

 SEEN-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-RECIPE-SEEN" USING PB-BUFFER WS-RECIPE
     PERFORM START-OBSERVED
     MOVE WS-RECIPE TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-RECIPE-SEEN" USING PK-BUFFER WS-RECIPE
     PERFORM CHECK-ENCODE.

 CHANGE-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-RECIPE-BOOK-CHANGE" USING PB-BUFFER WS-BOOK WS-OPEN WS-FILTERING
     PERFORM START-OBSERVED
     MOVE WS-BOOK TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-OPEN TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM PUT-SPACE
     MOVE WS-FILTERING TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-RECIPE-BOOK-CHANGE" USING PK-BUFFER WS-BOOK WS-OPEN WS-FILTERING
     PERFORM CHECK-ENCODE.

 REMOVE-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     MOVE 64 TO WS-MAX
     CALL "PB-GET-RECIPE-BOOK-REMOVE" USING PB-BUFFER WS-ID-TABLE WS-MAX WS-COUNT
     PERFORM START-OBSERVED
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
         MOVE WS-ID(WS-J) TO WS-EDIT
         IF WS-J > 1
             PERFORM PUT-SPACE
         END-IF
         PERFORM PUT-NUM
     END-PERFORM
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-RECIPE-BOOK-REMOVE" USING PK-BUFFER WS-ID-TABLE WS-COUNT
     PERFORM CHECK-ENCODE.

 SETTINGS-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-RECIPE-BOOK-SETTINGS" USING PB-BUFFER PB-RECIPE-BOOK-SETTINGS
     PERFORM START-OBSERVED
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
         IF WS-J > 1
             PERFORM PUT-SPACE
         END-IF
         MOVE PB-RBS-OPEN(WS-J) TO WS-EDIT
         PERFORM PUT-NUM
         PERFORM PUT-SPACE
         MOVE PB-RBS-FILTERING(WS-J) TO WS-EDIT
         PERFORM PUT-NUM
     END-PERFORM
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-RECIPE-BOOK-SETTINGS" USING PK-BUFFER PB-RECIPE-BOOK-SETTINGS
     PERFORM CHECK-ENCODE.

*> Recipe Book Add: entry count, then count entries (each re-encoded as read), then Replace.
 ADD-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     CALL "PB-PUT-VARINT" USING PK-BUFFER WS-COUNT
     PERFORM START-OBSERVED
     STRING "n" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-COUNT TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > WS-COUNT
         CALL "PB-GET-RECIPE-ENTRY" USING PB-BUFFER PB-RECIPE-ENTRY PB-SLOT-DISPLAY-TABLE
         CALL "PB-PUT-RECIPE-ENTRY" USING PK-BUFFER PB-RECIPE-ENTRY PB-SLOT-DISPLAY-TABLE
         PERFORM PUT-SPACE
         MOVE PB-RE-DISPLAY-ID TO WS-EDIT
         PERFORM PUT-NUM
         STRING ":t" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE PB-RE-TYPE TO WS-EDIT
         PERFORM PUT-NUM
         STRING " g" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE PB-RE-GROUP TO WS-EDIT
         PERFORM PUT-NUM
         STRING " c" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE PB-RE-CATEGORY TO WS-EDIT
         PERFORM PUT-NUM
         STRING " q" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         IF PB-RE-REQ-PRESENT = 1
             MOVE PB-RE-REQ-COUNT TO WS-EDIT
             PERFORM PUT-NUM
         ELSE
             STRING "-" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING " f" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE PB-RE-FLAGS TO WS-EDIT
         PERFORM PUT-NUM
     END-PERFORM
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-REPLACE
     CALL "PB-PUT-BOOL" USING PK-BUFFER WS-REPLACE
     PERFORM PUT-SPACE
     STRING "replace " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-REPLACE TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM CHECK-DECODE
     PERFORM CHECK-ENCODE.

 LOAD-FIXTURE.
     MOVE SPACES TO WS-FIXTURE
     STRING "contract/fixtures/wire/" FUNCTION TRIM(WS-NAME) ".hex" DELIMITED BY SIZE
         INTO WS-FIXTURE
     CALL "TEST-LOAD-HEX" USING WS-FIXTURE PB-BUFFER.

 ADD-FIELD.
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR.

*> Whole-buffer form of CHECK-SAME-BYTES for fixtures above 512 bytes: no error, equal length and
*> equal bytes ("0 0 1" is expected).
 CHECK-SAME-BYTES-BIG.
     MOVE 0 TO WS-OFFSET
     CALL "TEST-SLICE-EQUALS" USING PB-BUFFER WS-OFFSET PK-BUFFER WS-EQUAL
     MOVE "T" TO TL-MODE
     MOVE "0 0 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE PK-ERROR TO WS-EDIT
     PERFORM ADD-FIELD
     COMPUTE WS-EDIT = PB-LENGTH - PK-LENGTH
     PERFORM ADD-FIELD
     MOVE WS-EQUAL TO WS-EDIT
     PERFORM ADD-FIELD
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The encoder's buffer (PK) against the fixture's bytes (PB, still whole: PB-LENGTH is unchanged).
 CHECK-SAME-BYTES.
     CALL "TEST-BUFFER-HEX" USING PB-BUFFER WS-HEX-A
     CALL "TEST-BUFFER-HEX" USING PK-BUFFER WS-HEX-B
     MOVE "T" TO TL-MODE
     MOVE WS-HEX-A TO TL-EXPECTED
     MOVE WS-HEX-B TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Level Event: Int event, Position, Int data, Boolean global.
 LEVEL-EVENT-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-LEVEL-EVENT" USING PB-BUFFER LV-EVENT LV-X LV-Y LV-Z LV-DATA-INT LV-GLOBAL
     PERFORM START-OBSERVED
     MOVE LV-EVENT TO WS-EDIT
     PERFORM PUT-NUM
     MOVE LV-X TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-Y TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-Z TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-DATA-INT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-GLOBAL TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LEVEL-EVENT" USING PK-BUFFER LV-EVENT LV-X LV-Y LV-Z LV-DATA-INT LV-GLOBAL
     PERFORM CHECK-ENCODE.

*> Block Event: Position, UByte, UByte, VarInt block id.
 BLOCK-EVENT-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-BLOCK-EVENT" USING PB-BUFFER LV-X LV-Y LV-Z LV-P0 LV-P1 LV-BLOCK
     PERFORM START-OBSERVED
     MOVE LV-X TO WS-EDIT
     PERFORM PUT-NUM
     MOVE LV-Y TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-Z TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-P0 TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-P1 TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-BLOCK TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-BLOCK-EVENT" USING PK-BUFFER LV-X LV-Y LV-Z LV-P0 LV-P1 LV-BLOCK
     PERFORM CHECK-ENCODE.

*> Block Entity Data: Position, VarInt type, network NBT compound; stated as x y z type, the byte
*> length of the compound and its bytes as lowercase hex.
 BLOCK-ENTITY-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-BLOCK-ENTITY-DATA" USING PB-BUFFER LV-X LV-Y LV-Z LV-TYPE LV-NBT LV-NBT-CAP
         LV-NBT-LEN
     PERFORM START-OBSERVED
     MOVE LV-X TO WS-EDIT
     PERFORM PUT-NUM
     MOVE LV-Y TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-Z TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-TYPE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE LV-NBT-LEN TO WS-EDIT
     PERFORM ADD-FIELD
     STRING " " FUNCTION LOWER-CASE(FUNCTION HEX-OF(LV-NBT(1:LV-NBT-LEN))) DELIMITED BY SIZE
         INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-BLOCK-ENTITY-DATA" USING PK-BUFFER LV-X LV-Y LV-Z LV-TYPE LV-NBT LV-NBT-LEN
     PERFORM CHECK-ENCODE.

*> Level Particles: particle type and option length, override, always, X Y Z, three distances,
*> three speeds, count, randomization.
 PARTICLES-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-LEVEL-PARTICLES" USING PB-BUFFER PB-LEVEL-PARTICLES
     PERFORM START-OBSERVED
     MOVE PB-LP-TYPE TO WS-EDIT
     PERFORM PUT-NUM
     MOVE PB-LP-DATA-LENGTH TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LP-OVERRIDE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LP-ALWAYS TO WS-EDIT
     PERFORM ADD-FIELD
     COMPUTE LV-FLT ROUNDED = PB-LP-X
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-LP-Y
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-LP-Z
     PERFORM ADD-FLOAT
     PERFORM VARYING LV-I FROM 1 BY 1 UNTIL LV-I > 3
         COMPUTE LV-FLT ROUNDED = PB-LP-DIST(LV-I)
         PERFORM ADD-FLOAT
     END-PERFORM
     PERFORM VARYING LV-I FROM 1 BY 1 UNTIL LV-I > 3
         COMPUTE LV-FLT ROUNDED = PB-LP-SPEED(LV-I)
         PERFORM ADD-FLOAT
     END-PERFORM
     MOVE PB-LP-COUNT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LP-RANDOMIZATION TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LEVEL-PARTICLES" USING PK-BUFFER PB-LEVEL-PARTICLES
     PERFORM CHECK-ENCODE.

*> Login: entity, hardcore, dimension count and names, max players, view, simulation, reduced
*> debug, death screen, limited crafting, online mode, secure chat, then the spawn info fields.
 LOGIN-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-LOGIN" USING PB-BUFFER PB-LOGIN PB-SPAWN-INFO
     PERFORM START-OBSERVED
     MOVE PB-LG-ENTITY TO WS-EDIT
     PERFORM PUT-NUM
     MOVE PB-LG-HARDCORE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LG-DIM-COUNT TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM VARYING LV-I FROM 1 BY 1 UNTIL LV-I > PB-LG-DIM-COUNT
         STRING " " PB-LG-DIM-NAME(LV-I)(1:PB-LG-DIM-LENGTH(LV-I)) DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE PB-LG-MAX-PLAYERS TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LG-VIEW-DISTANCE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LG-SIM-DISTANCE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LG-REDUCED-DEBUG TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LG-DEATH-SCREEN TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LG-LIMITED-CRAFT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LG-ONLINE-MODE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-LG-SECURE-CHAT TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM ADD-SPAWN-FIELDS
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LOGIN" USING PK-BUFFER PB-LOGIN PB-SPAWN-INFO
     PERFORM CHECK-ENCODE.

*> Respawn: the spawn info fields, then the data to keep.
 RESPAWN-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-RESPAWN" USING PB-BUFFER PB-SPAWN-INFO LV-KEEP
     PERFORM START-OBSERVED
     MOVE PB-SI-DIM-TYPE TO WS-EDIT
     PERFORM PUT-NUM
     PERFORM ADD-SPAWN-REST
     MOVE LV-KEEP TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-RESPAWN" USING PK-BUFFER PB-SPAWN-INFO LV-KEEP
     PERFORM CHECK-ENCODE.

*> Appends dimension type, then the rest of the spawn info (spawn info text of the stated fields).
 ADD-SPAWN-FIELDS.
     MOVE PB-SI-DIM-TYPE TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM ADD-SPAWN-REST.

*> " <dimension> <seed> <mode> <previous> <debug> <flat> <death dim x y z or -> <cooldown> <sea>".
 ADD-SPAWN-REST.
     STRING " " PB-SI-DIM(1:PB-SI-DIM-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE PB-SI-SEED TO LV-EDIT-BIG
     STRING " " FUNCTION TRIM(LV-EDIT-BIG) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE PB-SI-GAME-MODE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-SI-PREVIOUS-MODE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-SI-DEBUG TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-SI-FLAT TO WS-EDIT
     PERFORM ADD-FIELD
     IF PB-SI-DEATH-PRESENT = 1
         STRING " " PB-SI-DEATH-DIM(1:PB-SI-DEATH-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
         MOVE PB-SI-DEATH-X TO WS-EDIT
         PERFORM ADD-FIELD
         MOVE PB-SI-DEATH-Y TO WS-EDIT
         PERFORM ADD-FIELD
         MOVE PB-SI-DEATH-Z TO WS-EDIT
         PERFORM ADD-FIELD
     ELSE
         STRING " -" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     MOVE PB-SI-PORTAL-COOLDOWN TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-SI-SEA-LEVEL TO WS-EDIT
     PERFORM ADD-FIELD.

*> Commands: every node of the tree is decoded and written again; the observed fields are the node
*> count, the root index and the numbers of literal, argument, executable, restricted, redirecting and
*> suggesting nodes. The re-encoded packet must equal the fixture byte for byte.
 COMMANDS-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER CM-COUNT
     CALL "PB-PUT-VARINT" USING PK-BUFFER CM-COUNT
     INITIALIZE CM-TALLY
     PERFORM VARYING CM-I FROM 1 BY 1 UNTIL CM-I > CM-COUNT
         CALL "PB-GET-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
         COMPUTE CM-TYPE = FUNCTION MOD(PB-CX-FLAGS, 4)
         IF CM-TYPE = PB-NODE-LITERAL
             ADD 1 TO CM-LIT
         END-IF
         IF CM-TYPE = PB-NODE-ARGUMENT
             ADD 1 TO CM-ARG
         END-IF
         DIVIDE PB-CX-FLAGS BY 4 GIVING CM-BITS
         ADD FUNCTION MOD(CM-BITS, 2) TO CM-EXEC
         DIVIDE PB-CX-FLAGS BY 8 GIVING CM-BITS
         ADD FUNCTION MOD(CM-BITS, 2) TO CM-REDIRECT
         DIVIDE PB-CX-FLAGS BY 16 GIVING CM-BITS
         ADD FUNCTION MOD(CM-BITS, 2) TO CM-SUGGEST
         DIVIDE PB-CX-FLAGS BY 32 GIVING CM-BITS
         ADD FUNCTION MOD(CM-BITS, 2) TO CM-RESTRICTED
         CALL "PB-PUT-COMMAND-NODE-X" USING PK-BUFFER PB-COMMAND-NODE-X
     END-PERFORM
     CALL "PB-GET-VARINT" USING PB-BUFFER CM-ROOT
     CALL "PB-PUT-VARINT" USING PK-BUFFER CM-ROOT
     PERFORM START-OBSERVED
     MOVE CM-COUNT TO WS-EDIT
     PERFORM PUT-NUM
     MOVE CM-ROOT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CM-LIT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CM-ARG TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CM-EXEC TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CM-RESTRICTED TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CM-REDIRECT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE CM-SUGGEST TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM CHECK-DECODE
     PERFORM NAME-ENCODE
     PERFORM CHECK-SAME-BYTES-BIG.

*> Command Suggestion request: transaction id, text.
 SUGGESTION-REQUEST-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     MOVE 300 TO CM-LEN
     CALL "PB-GET-SUGGESTION-REQUEST" USING PB-BUFFER CM-TRANS CM-TEXT CM-LEN CM-XS
     PERFORM START-OBSERVED
     MOVE CM-TRANS TO WS-EDIT
     PERFORM PUT-NUM
     STRING " " CM-TEXT(1:CM-XS) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-SUGGESTION-REQUEST" USING PK-BUFFER CM-TRANS CM-TEXT CM-XS
     PERFORM CHECK-ENCODE.

*> Command Suggestions: transaction id, range start and length, entry count, then each entry as its
*> text, and "+<p, l or t>:<tooltip>" when it has a tooltip.
 SUGGESTIONS-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-SUGGESTIONS" USING PB-BUFFER PB-SUGGESTIONS
     PERFORM START-OBSERVED
     MOVE PB-SG-TRANSACTION TO WS-EDIT
     PERFORM PUT-NUM
     MOVE PB-SG-START TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-SG-LENGTH TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-SG-COUNT TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM VARYING CM-I FROM 1 BY 1 UNTIL CM-I > PB-SG-COUNT
         MOVE PB-SG-TEXT-LENGTH(CM-I) TO CM-LEN
         STRING " " PB-SG-TEXT(CM-I)(1:CM-LEN) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
         IF PB-SG-TOOLTIP-KIND(CM-I) >= 0
             MOVE PB-SG-TOOLTIP-LENGTH(CM-I) TO CM-LEN
             EVALUATE PB-SG-TOOLTIP-KIND(CM-I)
                 WHEN PB-TEXT-PLAIN
                     STRING "+p:" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
                 WHEN PB-TEXT-LITERAL
                     STRING "+l:" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
                 WHEN OTHER
                     STRING "+t:" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-EVALUATE
             STRING PB-SG-TOOLTIP(CM-I)(1:CM-LEN) DELIMITED BY SIZE INTO TL-OBSERVED
                 WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-SUGGESTIONS" USING PK-BUFFER PB-SUGGESTIONS
     PERFORM CHECK-ENCODE.

*> Chat Command: the length, then the whole text; for the long fixture (a run of 120 x) the first 17
*> characters, the number of x and the last 5 characters.
 CHAT-COMMAND-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     MOVE 300 TO CM-LEN
     CALL "PB-GET-CHAT-COMMAND" USING PB-BUFFER CM-TEXT CM-LEN CM-XS
     PERFORM START-OBSERVED
     MOVE CM-XS TO WS-EDIT
     PERFORM PUT-NUM
     MOVE 0 TO CM-I
     INSPECT CM-TEXT(1:CM-XS) TALLYING CM-I FOR ALL "x"
     IF CM-I > 100
         STRING " " CM-TEXT(1:17) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE CM-I TO WS-EDIT
         STRING " x" FUNCTION TRIM(WS-EDIT) " " CM-TEXT(CM-XS - 4:5) DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         STRING " " CM-TEXT(1:CM-XS) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-CHAT-COMMAND" USING PK-BUFFER CM-TEXT CM-XS
     PERFORM CHECK-ENCODE.

*> Player Chat: global index, sender (hex), index, signature flag, content, timestamp, salt, last-seen
*> count, unsigned content kind, filter kind, chat type, then the sender name
*> and the target name ("p:<text>", or "-" when absent).
 PLAYER-CHAT-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-PLAYER-CHAT" USING PB-BUFFER PB-PLAYER-CHAT PB-CHAT-BOUND
     PERFORM START-OBSERVED
     MOVE PB-PCH-GLOBAL-INDEX TO WS-EDIT
     PERFORM PUT-NUM
     STRING " " FUNCTION LOWER-CASE(FUNCTION HEX-OF(PB-PCH-SENDER)) DELIMITED BY SIZE
         INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE PB-PCH-INDEX TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-PCH-SIGNATURE-PRESENT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-PCH-CONTENT-LENGTH TO CM-LEN
     STRING " " PB-PCH-CONTENT(1:CM-LEN) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE PB-PCH-TIMESTAMP TO LV-EDIT-BIG
     STRING " " FUNCTION TRIM(LV-EDIT-BIG) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE PB-PCH-SALT TO LV-EDIT-BIG
     STRING " " FUNCTION TRIM(LV-EDIT-BIG) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE PB-PCH-SEEN-COUNT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-PCH-UNSIGNED-KIND TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE PB-PCH-FILTER-KIND TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM ADD-BOUND
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-PLAYER-CHAT" USING PK-BUFFER PB-PLAYER-CHAT PB-CHAT-BOUND
     PERFORM CHECK-ENCODE.

*> Disguised Chat: message as "<kind>:<text>", chat type, sender name, target name.
 DISGUISED-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-UBYTE" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-DISGUISED-CHAT" USING PB-BUFFER PB-DISGUISED-CHAT PB-CHAT-BOUND
     PERFORM START-OBSERVED
     MOVE PB-DC-LENGTH TO CM-LEN
     STRING "p:" PB-DC-MESSAGE(1:CM-LEN) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM ADD-BOUND
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-UBYTE" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-DISGUISED-CHAT" USING PK-BUFFER PB-DISGUISED-CHAT PB-CHAT-BOUND
     PERFORM CHECK-ENCODE.

*> " <chat type> <sender>" then " -" or " p:<target>" (the fixtures use plain texts only).
 ADD-BOUND.
     MOVE PB-CB-TYPE TO WS-EDIT
     PERFORM ADD-FIELD
     IF PB-CB-SENDER-KIND = PB-TEXT-PLAIN AND PB-CB-SENDER-LENGTH > 0
         MOVE PB-CB-SENDER-LENGTH TO CM-LEN
         STRING " " PB-CB-SENDER(1:CM-LEN) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
     END-IF
     IF PB-CB-TARGET-KIND = -1
         STRING " -" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         MOVE PB-CB-TARGET-LENGTH TO CM-LEN
         STRING " p:" PB-CB-TARGET(1:CM-LEN) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
     END-IF.

 ADD-FLOAT.
     STRING " " FUNCTION TRIM(LV-FLT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR.

*> Update Attributes: entity, snapshot count, then per snapshot the attribute id, base and modifier
*> count, and per modifier its identifier, amount and operation.
 ATTRIBUTES-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-UPDATE-ATTRIBUTES" USING PB-BUFFER PB-ATTRIBUTES
     PERFORM START-OBSERVED
     MOVE PB-AT-ENTITY TO WS-EDIT
     PERFORM PUT-NUM
     MOVE PB-AT-COUNT TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-AT-COUNT
         MOVE PB-AT-ATTRIBUTE(WS-I) TO WS-EDIT
         PERFORM ADD-FIELD
         COMPUTE LV-FLT ROUNDED = PB-AT-BASE(WS-I)
         PERFORM ADD-FLOAT
         MOVE PB-AT-MOD-COUNT(WS-I) TO WS-EDIT
         PERFORM ADD-FIELD
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-AT-MOD-COUNT(WS-I)
             MOVE PB-AT-MOD-ID-LENGTH(WS-I, WS-J) TO WS-LEN
             STRING " " PB-AT-MOD-ID(WS-I, WS-J)(1:WS-LEN) DELIMITED BY SIZE
                 INTO TL-OBSERVED WITH POINTER WS-PTR
             COMPUTE LV-FLT ROUNDED = PB-AT-MOD-AMOUNT(WS-I, WS-J)
             PERFORM ADD-FLOAT
             MOVE PB-AT-MOD-OPERATION(WS-I, WS-J) TO WS-EDIT
             PERFORM ADD-FIELD
         END-PERFORM
     END-PERFORM
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-VARINT" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-UPDATE-ATTRIBUTES" USING PK-BUFFER PB-ATTRIBUTES
     PERFORM CHECK-ENCODE.

*> Update Mob Effect: entity, effect, amplifier, duration, flags.
 EFFECT-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-UPDATE-MOB-EFFECT" USING PB-BUFFER WS-ENTITY WS-RECIPE WS-COUNT WS-LEN
         WS-STATE
     PERFORM START-OBSERVED
     MOVE WS-ENTITY TO WS-EDIT
     PERFORM PUT-NUM
     MOVE WS-RECIPE TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-COUNT TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-LEN TO WS-EDIT
     PERFORM ADD-FIELD
     MOVE WS-STATE TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-VARINT" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-UPDATE-MOB-EFFECT" USING PK-BUFFER WS-ENTITY WS-RECIPE WS-COUNT WS-LEN
         WS-STATE
     PERFORM CHECK-ENCODE.

*> Spawn Entity: entity id, UUID, entity type, position, movement, pitch, yaw, head yaw and data.
 SPAWN-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-SPAWN-ENTITY" USING PB-BUFFER PB-SPAWN
     PERFORM START-OBSERVED
     MOVE PB-SP-ENTITY TO WS-EDIT
     PERFORM PUT-NUM
     STRING " " FUNCTION LOWER-CASE(FUNCTION HEX-OF(PB-SP-UUID)) DELIMITED BY SIZE
         INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE PB-SP-TYPE TO WS-EDIT
     PERFORM ADD-FIELD
     COMPUTE LV-FLT ROUNDED = PB-SP-X
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-SP-Y
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-SP-Z
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-SP-MOVE-X
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-SP-MOVE-Y
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-SP-MOVE-Z
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-SP-PITCH
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-SP-YAW
     PERFORM ADD-FLOAT
     COMPUTE LV-FLT ROUNDED = PB-SP-HEAD-YAW
     PERFORM ADD-FLOAT
     MOVE PB-SP-DATA TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-VARINT" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-SPAWN-ENTITY" USING PK-BUFFER PB-SPAWN
     PERFORM CHECK-ENCODE.

*> Set Entity Data: the entity id, then each entry shown by TEST-DUMP-METADATA up to the terminator;
*> every entry is re-encoded as it is read.
 DATA-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ENTITY
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-VARINT" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PK-BUFFER WS-ENTITY
     PERFORM START-OBSERVED
     MOVE WS-ENTITY TO WS-EDIT
     PERFORM PUT-NUM
     MOVE 0 TO PB-MX-INDEX
     PERFORM UNTIL PB-MX-INDEX = PB-MD-END OR PB-ERROR = 1
         CALL "PB-GET-METADATA-ENTRY-X" USING PB-BUFFER PB-METADATA-ENTRY-X
         CALL "PB-PUT-METADATA-ENTRY-X" USING PK-BUFFER PB-METADATA-ENTRY-X
         CALL "TEST-DUMP-METADATA" USING PB-METADATA-ENTRY-X LV-DUMP
         STRING " " FUNCTION TRIM(LV-DUMP) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     PERFORM CHECK-DECODE
     PERFORM CHECK-ENCODE.

*> Entity Event: entity id (Int) and event id (Byte).
 EVENT-CASE.
     PERFORM LOAD-FIXTURE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-ENTITY-EVENT" USING PB-BUFFER WS-ENTITY LV-EVENT
     PERFORM START-OBSERVED
     MOVE WS-ENTITY TO WS-EDIT
     PERFORM PUT-NUM
     MOVE LV-EVENT TO WS-EDIT
     PERFORM ADD-FIELD
     PERFORM CHECK-DECODE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "PB-PUT-VARINT" USING PK-BUFFER WS-PACKET-ID
     CALL "PB-PUT-ENTITY-EVENT" USING PK-BUFFER WS-ENTITY LV-EVENT
     PERFORM CHECK-ENCODE.
 END PROGRAM CONTRACT-WIRE-PROVIDER.
 COPY PROTOTEST.
