commit 5e9a6a530a1d1ddf20e92f141cfc0f4cb5319225
Author: Stefan Rusek <stefan@rusek.org>
Date:   Thu Nov 19 14:18:49 2026 -0500

    fix(client): letting go of the right button sends release use item for a held brush (T61003)
    
    Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>
    Claude-Session: https://claude.ai/code/session_01XrVsM2eDRRo1xQapRd9Uam

diff --git a/client/copy/CLSTATE.cpy b/client/copy/CLSTATE.cpy
index 38d2def5..50339c2d 100644
--- a/client/copy/CLSTATE.cpy
+++ b/client/copy/CLSTATE.cpy
@@ -502,6 +502,9 @@
        10 PL-SPRINTING       PIC 9.
        10 PL-EATING          PIC 9.
        10 PL-EAT-START       BINARY-DOUBLE.
+*>     A brush in use (lane bugbrush; 17 section 3.5, 25 part 8 section 7): 1 from the right press that used the held brush on a block until the button is released
+*>     (controls.cob sends release use item, which ends the server's use); the server's use also ends by itself when the view ray leaves the block.
+       10 PL-BRUSHING        PIC 9.
 *>     Weather (US11; standin-content §14): the rain and thunder levels of the last Game Events 7
 *>     and 8 (2 sets both to 0), and the kind they map to (WX-*).
        10 PL-RAIN            FLOAT-SHORT.
diff --git a/client/src/controls.cob b/client/src/controls.cob
index 87875b05..f5c4a759 100644
--- a/client/src/controls.cob
+++ b/client/src/controls.cob
@@ -71,6 +71,7 @@
      END-IF
      CALL "CL-ITEM-FLAGS" USING CLIENT-STATE WS-ITEM WS-IBLOCK WS-ITOOL WS-IFOOD
      MOVE 0 TO WS-IS-BUCKET
+     MOVE SPACES TO WS-PATH
      IF WS-ITEM > 0
          CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-PATH WS-MAX WS-IB2 WS-IT2 WS-IF2 WS-KNOWN
          IF WS-PATH = "bucket" OR WS-PATH = "water_bucket" OR WS-PATH = "lava_bucket"
@@ -106,6 +107,15 @@
          WHEN IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD AND WS-IS-BUCKET = 1
              CALL "CONTROLS-SEND-BUCKET" USING CLIENT-STATE
      END-EVALUATE
+*>   A brush (25 part 8 section 7): the right press that sent Use Item On at a block with the brush held starts its use; the use goes on while the button is held and the
+*>   server is told with release use item when the button comes up (the server's use lasts 200 ticks otherwise).
+     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD AND TG-HIT = 1 AND WS-PATH = "brush"
+         MOVE 1 TO PL-BRUSHING
+     END-IF
+     IF PL-BRUSHING = 1 AND IN-BUTTON-DOWN(CC-BUTTON-RIGHT + 1) = 0
+         MOVE 0 TO PL-BRUSHING
+         CALL "CONTROLS-SEND-ITEM-ACTION" USING CLIENT-STATE WS-ACTION6
+     END-IF
 *>   Eating ends when the button is released; early, the server is told.
      IF PL-EATING = 1 AND IN-BUTTON-DOWN(CC-BUTTON-RIGHT + 1) = 0
          MOVE 0 TO PL-EATING
diff --git a/client/src/protocol-world.cob b/client/src/protocol-world.cob
index 3928b2f6..258e2fb1 100644
--- a/client/src/protocol-world.cob
+++ b/client/src/protocol-world.cob
@@ -124,7 +124,7 @@
  PROCEDURE DIVISION USING CLIENT-STATE.
      MOVE 0 TO PL-MIN-Y PL-LOADED PL-POSITIONED PL-BATCHES PL-VY PL-HURT-UNTIL PL-WAIT
      MOVE CL-NOW-MS TO PL-WAIT-START
-     MOVE 0 TO PL-SPRINTING PL-EATING PL-POSE PL-EYE PL-SNEAK-FLAG PL-GLIDING
+     MOVE 0 TO PL-SPRINTING PL-EATING PL-BRUSHING PL-POSE PL-EYE PL-SNEAK-FLAG PL-GLIDING
      MOVE 256 TO PL-HEIGHT
      MOVE 1 TO PL-HAS-SKY
      COMPUTE WS-D = PL-DIM-TYPE + 1
diff --git a/client/tests/acc_bugbrush_control.cob b/client/tests/acc_bugbrush_control.cob
new file mode 100644
index 00000000..8a5bb7f3
--- /dev/null
+++ b/client/tests/acc_bugbrush_control.cob
@@ -0,0 +1,99 @@
+*> Acceptance test, lane bugbrush, client half (operator report try18: right click on suspicious sand did nothing visible): the right button pressed on a block with a brush held
+*> sends Use Item On (the server starts the use of the brush, 17 section 3.5, 25 part 8 section 7) and, when the button is released, Player Action 6 release use item, which ends
+*> the server's use (it otherwise lasts 200 ticks); another item at the same block sends only Use Item On and no release. The brush is item 1578 of the standard set.
+ IDENTIFICATION DIVISION.
+ PROGRAM-ID. ACC-BUGBRUSH-CONTROL.
+ DATA DIVISION.
+ WORKING-STORAGE SECTION.
+ COPY CLSTATE.
+ COPY CLCONST.
+ COPY CCSHIM.
+ COPY CONTENT.
+ COPY TESTLIB.
+ 01 WS-SERVER              BINARY-LONG.
+ 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
+ 01 WS-TEXT                PIC X(1024).
+ 01 WS-KIND                BINARY-LONG.
+ 01 WS-MS                  BINARY-LONG.
+ 01 WS-KEY                 PIC X(112).
+ 01 WS-BRUSH               BINARY-LONG.
+ 01 WS-ROW                 PIC X(270).
+ 01 WS-STATUS              BINARY-LONG.
+ PROCEDURE DIVISION.
+     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
+     MOVE 1 TO CT-OPEN
+     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
+     MOVE "brush" TO WS-KEY
+     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BRUSH WS-ROW WS-STATUS
+*>   Survival, looking straight down at the greystone (0, 9, 0) under the feet, a brush held.
+     MOVE 0 TO PL-MODE PL-HELD
+     MOVE 1 TO PL-SLOT-COUNT(1)
+     MOVE WS-BRUSH TO PL-SLOT-ITEM(1)
+     MOVE 90 TO PL-PITCH
+     CALL "TEST-STEP" USING CLIENT-STATE
+     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
+
+     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
+     MOVE 20 TO WS-MS
+     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
+     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
+     MOVE "acceptance bugbrush client: given a brush held and a block aimed at when the right button is pressed then Use Item On is sent and nothing else" TO TL-CASE
+     MOVE "T" TO TL-MODE
+     MOVE "4200000000000000000901" & "3f0000003f8000003f000000" & "000001" TO TL-EXPECTED
+     MOVE WS-TEXT TO TL-OBSERVED
+     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
+
+     MOVE CC-EV-BUTTON-UP TO WS-KIND
+     MOVE 20 TO WS-MS
+     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
+     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
+     MOVE "acceptance bugbrush client: when the button is released then Player Action 6 release use item is sent, ending the brushing" TO TL-CASE
+     MOVE "290600000000000000000000" TO TL-EXPECTED
+     MOVE WS-TEXT TO TL-OBSERVED
+     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
+
+     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
+     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
+     MOVE "acceptance bugbrush client: a second release sends nothing" TO TL-CASE
+     MOVE SPACES TO TL-EXPECTED
+     MOVE WS-TEXT TO TL-OBSERVED
+     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
+
+*>   Greystone (item 2) at the same block: only Use Item On.
+     MOVE 2 TO PL-SLOT-ITEM(1)
+     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
+     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
+     MOVE CC-EV-BUTTON-UP TO WS-KIND
+     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
+     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
+     MOVE "acceptance bugbrush client: given another item held when the button is pressed and released then no release use item is sent" TO TL-CASE
+     MOVE "T" TO TL-MODE
+     MOVE "4200000000000000000901" & "3f0000003f8000003f000000" & "000002" TO TL-EXPECTED
+     MOVE WS-TEXT TO TL-OBSERVED
+     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
+     STOP RUN.
+ END PROGRAM ACC-BUGBRUSH-CONTROL.
+
+ IDENTIFICATION DIVISION.
+ PROGRAM-ID. TEST-RIGHT-BUTTON.
+*> USING CLIENT-STATE, event kind (CC-EV-BUTTON-DOWN or CC-EV-BUTTON-UP), milliseconds: one CL-STEP that many milliseconds after the last with that right-button event.
+ DATA DIVISION.
+ WORKING-STORAGE SECTION.
+ COPY CCSHIM.
+ 01 WS-EVENT.
+    05 WS-KIND             BINARY-LONG.
+    05 WS-A                BINARY-LONG.
+    05 FILLER              PIC X(16).
+ 01 WS-ONE                 BINARY-LONG VALUE 1.
+ LINKAGE SECTION.
+ COPY CLSTATE.
+ 01 L-KIND                 BINARY-LONG.
+ 01 L-MS                   BINARY-LONG.
+ PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-MS.
+     INITIALIZE WS-EVENT
+     MOVE L-KIND TO WS-KIND
+     MOVE CC-BUTTON-RIGHT TO WS-A
+     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE L-MS
+     GOBACK.
+ END PROGRAM TEST-RIGHT-BUTTON.
+ COPY CLTEST.
diff --git a/specs/002-client-polish/tasks/lanes/bugbrush.md b/specs/002-client-polish/tasks/lanes/bugbrush.md
new file mode 100644
index 00000000..73b8873f
--- /dev/null
+++ b/specs/002-client-polish/tasks/lanes/bugbrush.md
@@ -0,0 +1,8 @@
+## Phase bugbrush: using the brush on suspicious sand and gravel (lane 002-lane-bugbrush, T61000 to T61099; operator report try18: "suspicious sand doesn't do the brush animation when I right click on it; if I break the block with the brush it does drop treasure")
+
+Root cause: the core had the decision units of the brush (TOOL-BRUSH-*, BE4-BRUSH*, GB-BRUSHABLE; T2112, T2113, T0917, T0918) but nothing called them: Use Item On with a brush did nothing (no use started, no brushing events, the block's dusted value never moved, no sound, no particles), suspicious blocks had no scheduled-tick rules (no checkReset, no fall), and the block entity of a suspicious block was treated as a container, so removing the block (a break with any tool, the brush included) rolled its archaeology table and dropped the treasure (BE-BLOCK-SET to BE-DROP-CONTENTS). The client sent no release use item for a brush, so a server-side use could not be ended by letting go of the button.
+
+- [x] T61000 [US14-core] Brush use (17 section 3.5, 25 part 8 section 7, 31-4 section 7): `core/src/brush-use.cob` (BRUSH-HIT, BRUSH-START, BRUSH-TICK, BRUSH-STEP, BRUSH-SOUND, BRUSH-UNPACK, BRUSH-COMPLETE, BRUSH-DUSTED-SET, BRUSH-BLOCK-TICK), wired into BLOCK-USE-ON (Use Item On), HEALTH-TICK and HUNGER-CANCEL (release use item); new player fields PL-BRUSH-* in CORESTATE.cpy. Test `core/tests/acc_bugbrush_use.cob`.
+- [x] T61001 [US14-core] A brushable block entity is not a container (31-4 section 7.2, 29b part 1 section 3.5): `BE-BLOCK-SET` no longer calls BE-DROP-CONTENTS for type 40, so breaking the block (or its falling) drops nothing from the block entity.
+- [x] T61002 [US14-core] Suspicious blocks tick (31-4 section 7.6): GB-RULES-OPEN registers onPlace and updateShape (2-tick tick) and the scheduled tick (BU-HOOK effect 11, BRUSH-BLOCK-TICK: checkReset, then the fall with cancelDrop).
+- [x] T61003 [US4-client] The right press with a brush held at a block sends release use item when the button comes up (`PL-BRUSHING`, controls.cob). Test `client/tests/acc_bugbrush_control.cob`.
