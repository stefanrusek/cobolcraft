*> Implementation test of the superflat world type in the client (docs/protocol/56-superflat-world.md §3.2, §6.1,
*> §6.2, §6.3, §6.5, §6.6; docs/design/world-types.md §12): the create-world screen's World Type control cycles
*> standard, superflat, cobolcraft (superflat is a normal visible entry; the hidden debug type stays a
*> Ctrl-click) and reads "World type: Superflat"; the Customize button is enabled for superflat only; Create
*> passes the world type string superflat to the core settings (and is refused with the packs not ok, like
*> standard); the minimal flat editor (layer list top first with the Top/Bottom texts, Presets, Done, Cancel);
*> the preset screen (the nine presets in the order of §3.1, Use Preset enabled by a selection, Cancel);
*> Done keeps the chosen preset name in SP-FLAT-PRESET, Cancel does not; the world list shows a superflat
*> world as Superflat and refuses it with the packs not ok; the language keys of §6.5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SUPERFLAT-UI.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY CCSHIM.
 COPY CLLANG.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-superflat-ui".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-FIND-ACTION         BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TYPE                PIC X(16).
 01 WS-TYPE-LENGTH         BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 9.
 01 WS-E3                  PIC 9.
 01 WS-E4                  PIC 9.
 01 WS-E5                  PIC 99.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-KEYC                BINARY-LONG.
 01 WS-KEYS.
    05 FILLER PIC X(80) VALUE "createWorld.customize.flat.title".
    05 FILLER PIC X(64) VALUE "Superflat Customization".
    05 FILLER PIC X(80) VALUE "createWorld.customize.flat.tile".
    05 FILLER PIC X(64) VALUE "Layer Material".
    05 FILLER PIC X(80) VALUE "createWorld.customize.flat.height".
    05 FILLER PIC X(64) VALUE "Height".
    05 FILLER PIC X(80) VALUE "createWorld.customize.flat.layer".
    05 FILLER PIC X(64) VALUE "%s".
    05 FILLER PIC X(80) VALUE "createWorld.customize.flat.layer.top".
    05 FILLER PIC X(64) VALUE "Top - %s".
    05 FILLER PIC X(80) VALUE "createWorld.customize.flat.layer.bottom".
    05 FILLER PIC X(64) VALUE "Bottom - %s".
    05 FILLER PIC X(80) VALUE "createWorld.customize.flat.removeLayer".
    05 FILLER PIC X(64) VALUE "Remove Layer".
    05 FILLER PIC X(80) VALUE "createWorld.customize.presets".
    05 FILLER PIC X(64) VALUE "Presets".
    05 FILLER PIC X(80) VALUE "createWorld.customize.presets.title".
    05 FILLER PIC X(64) VALUE "Select a Preset".
    05 FILLER PIC X(80) VALUE "createWorld.customize.presets.share".
    05 FILLER PIC X(64) VALUE "Want to share your preset with someone? Use the box below!".
    05 FILLER PIC X(80) VALUE "createWorld.customize.presets.list".
    05 FILLER PIC X(64) VALUE "Alternatively, here are some we made earlier!".
    05 FILLER PIC X(80) VALUE "createWorld.customize.presets.select".
    05 FILLER PIC X(64) VALUE "Use Preset".
    05 FILLER PIC X(80) VALUE "flat_world_preset.minecraft.classic_flat".
    05 FILLER PIC X(64) VALUE "Classic Flat".
    05 FILLER PIC X(80) VALUE "flat_world_preset.minecraft.tunnelers_dream".
    05 FILLER PIC X(64) VALUE "Tunnelers' Dream".
    05 FILLER PIC X(80) VALUE "flat_world_preset.minecraft.water_world".
    05 FILLER PIC X(64) VALUE "Water World".
    05 FILLER PIC X(80) VALUE "flat_world_preset.minecraft.overworld".
    05 FILLER PIC X(64) VALUE "Overworld".
    05 FILLER PIC X(80) VALUE "flat_world_preset.minecraft.snowy_kingdom".
    05 FILLER PIC X(64) VALUE "Snowy Kingdom".
    05 FILLER PIC X(80) VALUE "flat_world_preset.minecraft.bottomless_pit".
    05 FILLER PIC X(64) VALUE "Bottomless Pit".
    05 FILLER PIC X(80) VALUE "flat_world_preset.minecraft.desert".
    05 FILLER PIC X(64) VALUE "Desert".
    05 FILLER PIC X(80) VALUE "flat_world_preset.minecraft.redstone_ready".
    05 FILLER PIC X(64) VALUE "Redstone Ready".
    05 FILLER PIC X(80) VALUE "flat_world_preset.minecraft.the_void".
    05 FILLER PIC X(64) VALUE "The Void".
    05 FILLER PIC X(80) VALUE "flat_world_preset.unknown".
    05 FILLER PIC X(64) VALUE "???".
    05 FILLER PIC X(80) VALUE "generator.minecraft.flat".
    05 FILLER PIC X(64) VALUE "Superflat".
    05 FILLER PIC X(80) VALUE "selectWorld.customizeType".
    05 FILLER PIC X(64) VALUE "Customize".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY-ROW OCCURS 24 TIMES.
       10 WS-K-KEY         PIC X(80).
       10 WS-K-TEXT        PIC X(64).
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE CT-PACKS-OK TO CL-PACKS-STATUS
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE

*>   The cycle: standard (0), superflat (3), cobolcraft (1), standard, superflat.
     MOVE ACT-WORLD-TYPE TO WS-ACTION
     MOVE SPACES TO TL-OBSERVED
     MOVE SP-CREATE-TYPE TO WS-E1
     MOVE WS-E1 TO TL-OBSERVED(1:1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
         MOVE SP-CREATE-TYPE TO WS-E1
         MOVE WS-E1 TO TL-OBSERVED(WS-I * 2 + 1:1)
     END-PERFORM
     MOVE "superflat cycle: standard 0, then clicks give superflat 3, cobolcraft 1, standard 0, superflat 3"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 3 1 0 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The label of superflat and its Customize button (enabled), then cobolcraft and standard (disabled).
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "World type: Superflat"
     MOVE WS-HITS TO WS-E1
     MOVE ACT-FLAT-CUSTOMIZE TO WS-FIND-ACTION
     PERFORM FIND-WIDGET
     MOVE WS-STATE TO WS-E2
     MOVE "superflat the control reads World type: Superflat and the Customize button is enabled (state 0)"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 " " SM-W-TEXT(WS-W)(1:SM-W-LENGTH(WS-W)) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 Customize" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-WORLD-TYPE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM FIND-WIDGET
     MOVE WS-STATE TO WS-E1
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM FIND-WIDGET
     MOVE WS-STATE TO WS-E2
     MOVE "superflat Customize is disabled (state 2) with the cobolcraft and the standard types" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Ctrl-click: the hidden debug type, Customize disabled; the word superflat never shown for it.
     MOVE 1 TO IN-KEY-DOWN(CC-KEY-LEFT-CONTROL + 1)
     MOVE CC-MOD-CONTROL TO IN-MODS
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE 0 TO IN-KEY-DOWN(CC-KEY-LEFT-CONTROL + 1)
     MOVE 0 TO IN-MODS
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM FIND-WIDGET
     MOVE WS-STATE TO WS-E1
     MOVE SP-CREATE-TYPE TO WS-E2
     MOVE "superflat a Ctrl-click still selects the hidden debug type (2) and its Customize is disabled" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Create with superflat: the settings carry the world type string superflat.
     MOVE SPACES TO WS-TEXT
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE "superflat Create with the superflat type passes the world type superflat to the core settings"
         TO TL-CASE
     MOVE "superflat" TO TL-EXPECTED
     MOVE FUNCTION TRIM(CS-WORLD-TYPE) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   With the packs not ok Create with superflat is refused like standard (its blocks are Minecraft content).
     MOVE 0 TO SP-ACTIVE
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CT-PACKS-STALE TO CL-PACKS-STATUS
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Standard worlds need the Minecraft content"
     MOVE WS-HITS TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE "superflat Create with superflat and the packs not ok is refused with the packs explanation; nothing opens"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CT-PACKS-OK TO CL-PACKS-STATUS

*>   A fresh create-world screen starts with the default preset; the editor lists its layers top first.
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "superflat a fresh create-world screen holds the default preset classic_flat" TO TL-CASE
     MOVE "classic_flat" TO TL-EXPECTED
     MOVE FUNCTION TRIM(SP-FLAT-PRESET) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-FLAT-CUSTOMIZE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "superflat the editor shows the title, the header, the layers top first (Top - 1, 2, Bottom - 1) "
         & "and Presets, Done, Cancel" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E5
     STRING WS-E5 " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "26 Superflat Customization|Layer Material|Height|grass_block|Top - 1|dirt|2|bedrock|Bottom - 1|"
         & "Presets|Done|Cancel" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The preset screen: the nine presets in the order of 56 3.1; Use Preset disabled until a row is selected.
     MOVE ACT-FLAT-PRESETS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "superflat the preset screen lists the nine presets in the order of 56 3.1 with Use Preset and Cancel"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E5
     STRING WS-E5 " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "27 Select a Preset|Alternatively, here are some we made earlier!|Classic Flat|Tunnelers' Dream|"
         & "Water World|Overworld|Snowy Kingdom|Bottomless Pit|Desert|Redstone Ready|The Void|Use Preset|Cancel"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-FLAT-USE TO WS-FIND-ACTION
     PERFORM FIND-WIDGET
     MOVE WS-STATE TO WS-E1
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 3 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM FIND-WIDGET
     MOVE WS-STATE TO WS-E2
     MOVE "superflat Use Preset is disabled with no row selected (state 2) and enabled after selecting a row (0)"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Use Preset (Water World, the third row) returns to the editor with that preset's layers.
     MOVE ACT-FLAT-USE TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "superflat Use Preset of Water World returns to the editor listing water 90 down to bedrock 1"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E5
     STRING WS-E5 " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "26 Superflat Customization|Layer Material|Height|water_bucket|Top - 90|gravel|5|dirt|5|stone|5|"
         & "deepslate|64|bedrock|Bottom - 1|Presets|Done|Cancel" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "superflat before Done the world's chosen preset is still classic_flat" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "classic_flat" TO TL-EXPECTED
     MOVE FUNCTION TRIM(SP-FLAT-PRESET) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Done keeps the preset name, returns to the create-world screen with the type and name unchanged.
     MOVE "Mine" TO SM-EDIT-NAME
     MOVE 4 TO SM-EDIT-NAME-LENGTH
     MOVE ACT-FLAT-DONE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "superflat Done stores water_world, returns to the create-world screen (14) with type superflat (3) "
         & "and the typed name" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E5
     MOVE SP-CREATE-TYPE TO WS-E1
     STRING FUNCTION TRIM(SP-FLAT-PRESET) " " WS-E5 " " WS-E1 " " SM-EDIT-NAME(1:SM-EDIT-NAME-LENGTH)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "water_world 14 3 Mine" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Cancel of the editor and of the preset screen change nothing; the editor starts from the stored preset.
     MOVE ACT-FLAT-CUSTOMIZE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-FLAT-PRESETS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 9 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-FLAT-BACK TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Top - 90"
     MOVE WS-HITS TO WS-E1
     MOVE SM-SCREEN TO WS-E5
     MOVE "superflat Cancel on the preset screen returns to the editor, still showing the stored preset's layers"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E5 " " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "26 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Use The Void, then Cancel the editor: the stored preset stays.
     MOVE ACT-FLAT-PRESETS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 9 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-FLAT-USE TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "air|Top - 1|"
     MOVE WS-HITS TO WS-E1
     MOVE ACT-FLAT-CANCEL TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SM-SCREEN TO WS-E5
     MOVE "superflat The Void is one air layer (Top - 1); Cancel of the editor returns to the create-world "
         & "screen and keeps water_world" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E5 " " FUNCTION TRIM(SP-FLAT-PRESET) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 14 water_world" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Escape: the preset screen to the editor, the editor to the create-world screen.
     MOVE ACT-FLAT-CUSTOMIZE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-FLAT-PRESETS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE CC-KEY-ESCAPE TO WS-KEYC
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEYC
     MOVE SM-SCREEN TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-E5 TO TL-OBSERVED(1:2)
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEYC
     MOVE SM-SCREEN TO WS-E5
     MOVE WS-E5 TO TL-OBSERVED(4:2)
     MOVE "superflat Escape leaves the preset screen for the editor (26) and the editor for the create-world "
         & "screen (14)" TO TL-CASE
     MOVE "26 14" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The world list: a superflat world is listed as Superflat; the type id; Play is refused with the packs not ok.
     MOVE CT-PACKS-STALE TO CL-PACKS-STATUS
     MOVE 1 TO WL-COUNT
     MOVE "a_flat" TO WL-FOLDER(1)
     MOVE 6 TO WL-FOLDER-LENGTH(1)
     MOVE "a_flat" TO WL-NAME(1)
     MOVE 6 TO WL-NAME-LENGTH(1)
     MOVE 0 TO WL-MODE(1)
     MOVE "superflat" TO WL-TYPE(1)
     MOVE SCR-WORLD-LIST TO SM-SCREEN
     MOVE 0 TO SM-SELECTED SP-CREATE-REFUSED
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Type: Superflat"
     MOVE WS-HITS TO WS-E1
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PLAY-WORLD TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SP-CREATE-REFUSED TO WS-E2
     MOVE SP-ACTIVE TO WS-E3
     MOVE SPACES TO WS-TYPE
     MOVE "superflat" TO WS-TYPE
     CALL "WORLD-TYPE-ID" USING WS-TYPE WS-T1
     MOVE WS-T1 TO WS-E4
     MOVE "superflat the world list shows Type: Superflat; Play with the packs not ok is refused (1), nothing "
         & "opens; the level.dat text superflat is type 3" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 " " WS-E3 " " WS-E4 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1 0 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The language keys of 56 6.5 are in the built-in language with their English texts.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         MOVE WS-K-KEY(WS-I) TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
         IF WS-OUT(1:WS-OUT-LENGTH) NOT = FUNCTION TRIM(WS-K-TEXT(WS-I))
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "superflat the 24 keys of 56 6.5 the screens use have their English texts in the language"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIND-WIDGET.
*>   WS-FIND-ACTION: the first widget with that action: WS-W its index (0 none) and WS-STATE its state.
     MOVE 0 TO WS-W
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT OR WS-W > 0
         IF SM-W-ACTION(WS-I) = WS-FIND-ACTION
             MOVE WS-I TO WS-W
             MOVE SM-W-STATE(WS-I) TO WS-STATE
         END-IF
     END-PERFORM.
 END PROGRAM TEST-SUPERFLAT-UI.
 COPY CLTEST.
