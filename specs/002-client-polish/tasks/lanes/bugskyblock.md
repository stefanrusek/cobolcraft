commit b92ca81911275e8183ec24a6cd178fe8c23017a1
Author: Stefan Rusek <stefan@rusek.org>
Date:   Thu Nov 19 18:01:49 2026 -0500

    fix(core): a 26.3 world gets the overworld generator its world_gen_settings.dat declares (flat void stays void, a generator of a mod gives void chunks)
    
    Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>
    Claude-Session: https://claude.ai/code/session_01XrVsM2eDRRo1xQapRd9Uam

diff --git a/core/src/api.cob b/core/src/api.cob
index ba068f09..d59f5c46 100644
--- a/core/src/api.cob
+++ b/core/src/api.cob
@@ -417,7 +417,9 @@
  WORKING-STORAGE SECTION.
  COPY CORESTATE.
  COPY COREAPI.
+ COPY FLATSET.
  01 WS-FOUND               BINARY-LONG.
+ 01 WS-GENERATOR           BINARY-LONG.
  01 WS-TEXT                PIC X(32).
  01 WS-FILE                PIC X(1100).
  01 WS-INFO                PIC X(16).
@@ -430,6 +432,7 @@
  01 L-STATUS               BINARY-LONG.
  PROCEDURE DIVISION USING L-REQUEST L-TYPE L-STATUS.
      MOVE CORE-WO-OK TO L-STATUS
+     MOVE 0 TO FS-FALLBACK
      MOVE SPACES TO L-TYPE WS-FILE
      STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/level.dat" X"00" DELIMITED BY SIZE INTO WS-FILE
      CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
@@ -460,9 +463,22 @@
          EVALUATE TRUE
              WHEN WS-FOUND = 1
                  MOVE WS-TEXT TO L-TYPE
-*>           A level.dat of a real 26.3 game (compound Data, no WorldType): a standard world (33 section 10).
+*>           A level.dat of a real 26.3 game (compound Data, no WorldType): the world of the generator its world_gen_settings.dat declares for the
+*>           overworld (56 section 5.1: flat is a superflat world, debug the debug world, noise the standard world; a generator this core cannot make
+*>           gives void chunks, FS-FALLBACK: lane bugskyblock), else a standard world (33 section 10).
              WHEN WS-FOUND = 3
-                 MOVE "standard" TO L-TYPE
+                 CALL "LEVEL-PEEK-GENERATOR" USING WS-GENERATOR
+                 EVALUATE WS-GENERATOR
+                     WHEN 1
+                         MOVE "superflat" TO L-TYPE
+                     WHEN 2
+                         MOVE "debug" TO L-TYPE
+                     WHEN 3
+                         MOVE "superflat" TO L-TYPE
+                         MOVE 1 TO FS-FALLBACK
+                     WHEN OTHER
+                         MOVE "standard" TO L-TYPE
+                 END-EVALUATE
              WHEN WS-FOUND = 0 AND WS-HAS-MINECRAFT = 0
                  MOVE "cobolcraft" TO L-TYPE
              WHEN OTHER
diff --git a/core/src/flat-settings.cob b/core/src/flat-settings.cob
index 76445a6e..9ef10301 100644
--- a/core/src/flat-settings.cob
+++ b/core/src/flat-settings.cob
@@ -348,8 +348,13 @@
  COPY CORESTATE.
  COPY FLATSET.
  01 WS-STATUS              BINARY-LONG.
+ 01 WS-VOID                PIC X(40) VALUE "the_void".
  PROCEDURE DIVISION.
      IF CW-WORLD-TYPE = "superflat"
+*>       A world whose declared generator this core cannot make (WORLD-TYPE-DECIDE, FS-FALLBACK): its chunks are the void preset's, whatever the file says.
+         IF FS-FALLBACK = 1
+             CALL "FLAT-PRESET-SET" USING WS-VOID WS-STATUS
+         END-IF
          IF FS-PENDING = 1
              MOVE 0 TO FS-PENDING
              MOVE -1 TO FS-STAMP
@@ -391,6 +396,10 @@
      IF CW-WORLD-TYPE NOT = "superflat"
          GOBACK
      END-IF
+*>   A world of the 26.3 layout keeps the file as the game wrote it (VANILLA-SAVED-WRITE keeps its dimensions map: the nether and end stems, a generator of a mod).
+     IF CW-LAYOUT = 1
+         GOBACK
+     END-IF
      IF FS-LOADED = 0
          CALL "FLAT-SETTINGS-DEFAULT"
      END-IF
diff --git a/core/src/level-data.cob b/core/src/level-data.cob
index 34f48873..144d01ab 100644
--- a/core/src/level-data.cob
+++ b/core/src/level-data.cob
@@ -491,6 +491,133 @@
      GOBACK.
  END PROGRAM LEVEL-PEEK-TYPE.
 
+ IDENTIFICATION DIVISION.
+ PROGRAM-ID. LEVEL-PEEK-GENERATOR.
+*> USING kind out (BINARY-LONG): the generator the overworld stem of <world>/data/minecraft/world_gen_settings.dat declares (07 section 10.4.5, 56 section 2.5),
+*> so that a world of a real 26.3 game gets the generator it declares and not always the standard terrain (lane bugskyblock: a void world grew mountains around its
+*> island). 1 = minecraft:flat, 2 = minecraft:debug, 3 = a generator this core cannot make (a generator type of a mod, or minecraft:noise whose settings are a
+*> compound or an id of another namespace than minecraft:), 0 = the standard noise generator, or nothing to go by (no file, not readable, no overworld stem, a
+*> generator without a type).
+ DATA DIVISION.
+ WORKING-STORAGE SECTION.
+ COPY PROTO.
+ 01 WS-READY               PIC 9 VALUE 0.
+ 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
+ 01 WS-FRAMING             BINARY-LONG VALUE 1.
+ 01 WS-OUTCOME             BINARY-LONG.
+ 01 WN                     PIC X(32).
+ 01 WL                     BINARY-LONG.
+ 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
+ 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 64.
+ 01 WS-TYPE                BINARY-LONG.
+ 01 WS-DATA-TYPE           BINARY-LONG.
+ 01 WS-DIM-TYPE            BINARY-LONG.
+ 01 WS-STEM-TYPE           BINARY-LONG.
+ 01 WS-GEN-TYPE            BINARY-LONG.
+ 01 WS-LENGTH              BINARY-LONG.
+ 01 WS-GEN-NAME            PIC X(64).
+ 01 WS-SETTINGS            PIC X(64).
+ 01 WS-SETTINGS-KIND       BINARY-LONG.
+ 01 WS-SUFFIX              PIC X(128) VALUE "/data/minecraft/world_gen_settings.dat".
+ 01 WS-PATH                PIC X(1100).
+ 01 WS-PATH-LENGTH         BINARY-LONG.
+ LINKAGE SECTION.
+ 01 L-KIND                 BINARY-LONG.
+ PROCEDURE DIVISION USING L-KIND.
+     MOVE 0 TO L-KIND
+     IF WS-READY = 0
+         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
+         MOVE 1 TO WS-READY
+     END-IF
+     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
+     CALL "PB-RESET" USING PB-BUFFER
+     CALL "NBT-FILE-READ" USING WS-PATH WS-PATH-LENGTH PB-BUFFER WS-OUTCOME
+     IF WS-OUTCOME NOT = 0
+         GOBACK
+     END-IF
+     MOVE SPACES TO WS-GEN-NAME WS-SETTINGS
+     MOVE 0 TO WS-SETTINGS-KIND
+     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
+     PERFORM UNTIL PB-ERROR = 1
+         MOVE SPACES TO WN
+         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
+         IF WS-TYPE = 0
+             EXIT PERFORM
+         END-IF
+         IF WN = "data" AND WS-TYPE = 10
+             PERFORM UNTIL PB-ERROR = 1
+                 MOVE SPACES TO WN
+                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-DATA-TYPE WN WS-NAME-CAPACITY WL
+                 IF WS-DATA-TYPE = 0
+                     EXIT PERFORM
+                 END-IF
+                 IF WN = "dimensions" AND WS-DATA-TYPE = 10
+                     PERFORM UNTIL PB-ERROR = 1
+                         MOVE SPACES TO WN
+                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-DIM-TYPE WN WS-NAME-CAPACITY WL
+                         IF WS-DIM-TYPE = 0
+                             EXIT PERFORM
+                         END-IF
+                         IF WN = "minecraft:overworld" AND WS-DIM-TYPE = 10
+                             PERFORM UNTIL PB-ERROR = 1
+                                 MOVE SPACES TO WN
+                                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-STEM-TYPE WN WS-NAME-CAPACITY WL
+                                 IF WS-STEM-TYPE = 0
+                                     EXIT PERFORM
+                                 END-IF
+                                 IF WN = "generator" AND WS-STEM-TYPE = 10
+                                     PERFORM UNTIL PB-ERROR = 1
+                                         MOVE SPACES TO WN
+                                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-GEN-TYPE WN WS-NAME-CAPACITY WL
+                                         IF WS-GEN-TYPE = 0
+                                             EXIT PERFORM
+                                         END-IF
+                                         EVALUATE TRUE
+                                             WHEN WN = "type" AND WS-GEN-TYPE = 8
+                                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-GEN-NAME WS-TEXT-CAPACITY WS-LENGTH
+                                             WHEN WN = "settings" AND WS-GEN-TYPE = 8
+                                                 MOVE 1 TO WS-SETTINGS-KIND
+                                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-SETTINGS WS-TEXT-CAPACITY WS-LENGTH
+                                             WHEN WN = "settings"
+                                                 MOVE 2 TO WS-SETTINGS-KIND
+                                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-GEN-TYPE
+                                             WHEN OTHER
+                                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-GEN-TYPE
+                                         END-EVALUATE
+                                     END-PERFORM
+                                 ELSE
+                                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-STEM-TYPE
+                                 END-IF
+                             END-PERFORM
+                         ELSE
+                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-DIM-TYPE
+                         END-IF
+                     END-PERFORM
+                 ELSE
+                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-DATA-TYPE
+                 END-IF
+             END-PERFORM
+         ELSE
+             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
+         END-IF
+     END-PERFORM
+     EVALUATE TRUE
+         WHEN WS-GEN-NAME = SPACES
+             MOVE 0 TO L-KIND
+         WHEN WS-GEN-NAME = "minecraft:flat"
+             MOVE 1 TO L-KIND
+         WHEN WS-GEN-NAME = "minecraft:debug"
+             MOVE 2 TO L-KIND
+         WHEN WS-GEN-NAME NOT = "minecraft:noise"
+             MOVE 3 TO L-KIND
+         WHEN WS-SETTINGS-KIND = 2
+             MOVE 3 TO L-KIND
+         WHEN WS-SETTINGS-KIND = 1 AND WS-SETTINGS(1:10) NOT = "minecraft:"
+             MOVE 3 TO L-KIND
+     END-EVALUATE
+     GOBACK.
+ END PROGRAM LEVEL-PEEK-GENERATOR.
+
  IDENTIFICATION DIVISION.
  PROGRAM-ID. VANILLA-SEED-READ.
 *> USING seed (BINARY-DOUBLE, in and out): the `seed` of the compound `data` of <world>/data/minecraft/world_gen_settings.dat
diff --git a/specs/002-client-polish/tasks/lanes/bugskyblock.md b/specs/002-client-polish/tasks/lanes/bugskyblock.md
new file mode 100644
index 00000000..8e8cea87
--- /dev/null
+++ b/specs/002-client-polish/tasks/lanes/bugskyblock.md
@@ -0,0 +1,9 @@
+## Lane 002-lane-bugskyblock (T63200-T63299)
+
+Operator report from the try19 play: "my skyblock world bugged out and started generating chunks" (a world that is void everywhere except a small island). Base of the lane: origin/002-client-polish a2502892 (batch15). The operator's world was inspected read-only (its level.dat copied to the scratchpad, region file names and sizes listed, world_gen_settings.dat read in place; nothing written there).
+
+- [x] T63200 [US10] (lane bugskyblock) Findings on the real world ("Banclam's Dappled Skyblock World"; the folder name has "Banclam", not "bandclam"). level.dat: root compound `Data` and no `WorldType` (a 26.3 layout, DataVersion 5023, Version 26.3, `ServerBrands` vanilla and fabric, `WasModded` 1, `DataPacks` enabled vanilla and fabric-convention-tags-v2, spawn in minecraft:overworld, GameType 0); it names no generator. `data/minecraft/world_gen_settings.dat` (rewritten by an autosave of this game, so the file as the mod made it is not recoverable) now declares overworld `minecraft:noise`, settings `minecraft:overworld`, biome source multi_noise preset overworld, i.e. the ordinary standard terrain, plus the ordinary nether and end stems. Overworld region files: r.-1.-1 156 KB, r.-1.0 4.1 MB, r.0.-1 4.1 MB, r.0.0 136 KB (the two big ones hold about one sector per chunk for all 1024 chunks, i.e. saved void chunks; the other two hold a few dozen chunks): the saved area is the island's, every chunk outside it is absent from the files.
+- [x] T63201 [US10] (lane bugskyblock) Root cause, in the core (not the client, not the shim): `WORLD-TYPE-DECIDE` took every level.dat of a real 26.3 game (compound `Data`, no `WorldType`) for a `standard` world (WT-26) without looking at the generator the world declares, and a standard world makes the noise terrain (`GEN-STANDARD-INSTALL`) for every chunk that is absent from the region files; chunks absent were void only while the generated terrain data were missing (`WORLDGEN-VOID-CHUNK` placeholder). So a void world (the Superflat Void preset, `minecraft:flat` with no layers) or a world of a mod generator (a generator type this game does not know, or noise settings of another namespace) grew terrain around its saved island as soon as the terrain data existed. Also: for a `minecraft:flat` world `FLAT-SETTINGS-SAVE` would have rewritten world_gen_settings.dat with the overworld stem only (the nether and end stems lost). What the real file declares today (plain noise overworld) cannot be told apart from an ordinary world by this core: see the report.
+- [x] T63202 [US10] (lane bugskyblock) Red first: `core/tests/acc_skyblock_void.cob` with the synthetic worlds of `core/tests/fixtures/gen_skyblock.py` (the level.dat key set of the real world; flat with no layers and the_void biome, a mod generator type, noise with another namespace's settings, the plain noise control, debug, a file without dimensions, a generator without a type). Before the fix: every decided type was `standard`, and after join and 40 ticks each of the three void worlds had 274 non-air blocks in the nine chunks around the island (expected 0). Passed 3 of 18 before the fix.
+- [x] T63203 [US10] (lane bugskyblock) Fix: new `LEVEL-PEEK-GENERATOR` (core/src/level-data.cob) reads the overworld stem's generator of world_gen_settings.dat (flat 1, debug 2, one this core cannot make 3, else 0); `WORLD-TYPE-DECIDE` (core/src/api.cob) maps a 26.3 level.dat to superflat (flat), debug, standard (noise with a minecraft: settings id, no file, unreadable file, no overworld stem, no type) or, for a generator it cannot make, superflat with the new `FS-FALLBACK` 1 (core/copy/FLATSET.cpy): `FLAT-SETTINGS-OPEN` then gives it the void preset of 56 section 3.2 whatever the file says. `FLAT-SETTINGS-SAVE` writes nothing for a world of the 26.3 layout (`CW-LAYOUT` 1): `VANILLA-SAVED-WRITE` keeps the file's dimensions map, so a saved world keeps its generator and its nether and end stems (checked in the test).
+- [x] T63204 [US10] (lane bugskyblock) Known limit (reported, not hidden): a world of the fallback is opened as a superflat world, so the wire flag `is_flat` of Login/Respawn is 1 for it (a skyblock mod world is not flat in the game). The noise-settings variants of vanilla (amplified, large_biomes) stay standard terrain as before.
