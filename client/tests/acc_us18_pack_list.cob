*> Acceptance test US18-1 (spec.md User Story 18; 08 §1.1, §1.2, §2.3; client/src/packs/local.cob,
*> screens/pack-select.cob): the packs of the packs folder are listed on the pack selection screen
*> with their description, their icon if they have one, and whether they are compatible, too old,
*> too new or of unknown version.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-PACK-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-pack-list".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAMES               PIC X(256) VALUE "alpha beta.zip mystery newer old.zip".
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-ICONS               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-E                   PIC ZZ9.
 01 B-ATLAS                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US18-1 Given packs in the packs folder When the Pack creator opens the pack "
         & "selection screen from the title screen Then each pack is listed with its description "
         & "and whether it is compatible, too old, too new or of unknown version" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Resource Packs|Selected|Built-in pack|Available|alpha||Alpha pack|Compatible|beta.zip|"
         & "Beta pack|Compatible|mystery||Mystery pack|Version unknown|newer|Newer pack|Made for a"
         & " newer version|old.zip|Old pack|Made for an older version|Faithful Skin|Uses Faithful 32x textures for CobolCraft blocks and items. Needs the generated vanilla "
         & "pack or a Faithful pack.|Compatible|Enable|Disable|Move Up|Move"
         & " Down|Done|Open Pack Folder" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Icons: alpha's pack.png (32 x 32, red = 8x, green = 8y) scaled to its 16 x 16 cell; mystery's
*>   unreadable pack.png shows the missing texture; beta.zip, newer and old.zip have none.
     MOVE 0 TO WS-ICONS
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-ICON
             ADD 1 TO WS-ICONS
             MOVE SM-W-ARG(WS-I) TO WS-CELL
             PERFORM SHOW-CELL
         END-IF
     END-PERFORM
     MOVE "acceptance US18-1 Given a pack with pack.png When the pack screen shows it Then its icon"
         & " is drawn beside it (scaled to 16 x 16), a pack.png that cannot be read shows the "
         & "missing texture, and a pack without one has no icon" TO TL-CASE
     MOVE "0,0,100,255 240,240,100,255 64,32,100,255|242,140,40,255 26,26,26,255 26,26,26,255"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The icon is drawn: UI vertices on the icon cell.
     MOVE "acceptance US18-1 the pack icons are drawn as UI quads" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-ICONS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   Selecting a pack marks its entry.
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 2 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US18-1 a clicked pack entry is selected" TO TL-CASE
     MOVE "2 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SELECTED TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-ENTRY AND SM-W-ARG(WS-I) = 2
             MOVE SM-W-STATE(WS-I) TO WS-E
             MOVE SPACES TO WS-TEXT
             STRING TL-OBSERVED DELIMITED BY SPACE " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
                 INTO WS-TEXT
             MOVE WS-TEXT TO TL-OBSERVED
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SHOW-CELL.
     SET ADDRESS OF B-ATLAS TO UA-ADDR
     COMPUTE WS-X = FUNCTION MOD(WS-CELL - 1, UA-W / 16) * 16
     COMPUTE WS-Y = (WS-CELL - 1) / (UA-W / 16)
     COMPUTE WS-Y = UA-ICON-Y + WS-Y * 16
     IF WS-ICONS > 1
         STRING "|" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
*>   Pixels (0, 0), (15, 15) and (4, 2) of the cell.
     COMPUTE WS-POS = (WS-Y * UA-W + WS-X) * 4 + 1
     PERFORM SHOW-PIXEL
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     COMPUTE WS-POS = ((WS-Y + 15) * UA-W + WS-X + 15) * 4 + 1
     PERFORM SHOW-PIXEL
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     COMPUTE WS-POS = ((WS-Y + 2) * UA-W + WS-X + 4) * 4 + 1
     PERFORM SHOW-PIXEL.

 SHOW-PIXEL.
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 3
         COMPUTE WS-E = FUNCTION ORD(B-ATLAS(WS-POS + WS-K:1)) - 1
         IF WS-K > 0
             STRING "," DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM.
 END PROGRAM ACC-US18-PACK-LIST.
 COPY CLTEST.
 COPY PACKTEST.
