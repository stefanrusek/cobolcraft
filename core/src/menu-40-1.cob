*> Menus, part 1: the shared model's tables and rules and the container menus of the chest family, shulker box, hopper and dispenser
*> (docs/protocol/40-menus-1-model-and-containers.md; US12 phase 44). Pure programs: the registry (2.1), the click and id rules (3.3, 3.4, 4),
*> the generic screen geometry (5.1) and the slot tables (M2), quick-move ranges (M5) and slot rules of sections 7 to 10. The live window of a
*> player (menus.cob) is not changed by this file: kinds are 1 chest family (rows 1 to 6), 2 shulker box, 3 hopper, 4 dispenser or dropper.
*>
*>   MENU-SCOPE USING outside slot out, none slot out, slot size out, slots per row out, menu type count out           section 1
*>   MENU-TYPE-INFO USING id, key out (X(32)), length out (0 when out of range); MENU-TYPE-ID USING key (X(32)), length, id out (-1)   2.1
*>   MENU-VALID-SLOT USING index, slot count, result out; MENU-INPUT-DECODE USING id, input out; MENU-QC-MASK USING button, header out,
*>        type out, mask out; MENU-APPEND USING own slot count, menu slot, player container slot out (-1 for an own slot)    3.3, 3.4
*>   MENU-ID-NEXT USING counter, next out; MENU-STATE-NEXT USING state id, next out; MENU-DESYNC USING client state, server state, result out    4
*>   MENU-GEOMETRY USING gui width, gui height, image width, image height, leftPos out, topPos out, inventory label y out;
*>        MENU-HIGHLIGHT USING slot x, slot y, x out, y out; MENU-TITLE-X USING image width, title width, x out            5.1, 5.4, 10.5
*>   MENU-OWN-SLOTS USING kind, rows, own out, total out; MENU-TYPE-OF USING kind, rows, type id out                      6, M1
*>   MENU-LAYOUT USING kind, rows, menu slot, part out (0 none, 1 container, 2 player), container slot out, x out, y out    M2 of 7.2, 8.2, 9.2, 10.2
*>   MENU-IMAGE USING kind, rows, width out, height out, inventory label y out                                            M7
*>   MENU-QUICK-RANGE USING kind, rows, index, first out, end out (exclusive), reverse out, progress test out               M5
*>   MENU-QUICK-OK USING kind, stack count after, original count, ok out (0 when the dispenser moved nothing)                10.3 step 4
*>   MENU-MAY-PLACE-K USING kind, menu slot, item is a shulker box, result out                                              8.2

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SCOPE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OUTSIDE              BINARY-LONG.
 01 L-NONE                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-TYPES                BINARY-LONG.
 PROCEDURE DIVISION USING L-OUTSIDE L-NONE L-SIZE L-ROW L-TYPES.
     MOVE -999 TO L-OUTSIDE
     MOVE -1 TO L-NONE
     MOVE 18 TO L-SIZE
     MOVE 9 TO L-ROW
     MOVE 25 TO L-TYPES
     GOBACK.
 END PROGRAM MENU-SCOPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-TYPE-INFO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(20) VALUE "generic_9x1         ".
    05 FILLER PIC X(20) VALUE "generic_9x2         ".
    05 FILLER PIC X(20) VALUE "generic_9x3         ".
    05 FILLER PIC X(20) VALUE "generic_9x4         ".
    05 FILLER PIC X(20) VALUE "generic_9x5         ".
    05 FILLER PIC X(20) VALUE "generic_9x6         ".
    05 FILLER PIC X(20) VALUE "generic_3x3         ".
    05 FILLER PIC X(20) VALUE "crafter_3x3         ".
    05 FILLER PIC X(20) VALUE "anvil               ".
    05 FILLER PIC X(20) VALUE "beacon              ".
    05 FILLER PIC X(20) VALUE "blast_furnace       ".
    05 FILLER PIC X(20) VALUE "brewing_stand       ".
    05 FILLER PIC X(20) VALUE "crafting            ".
    05 FILLER PIC X(20) VALUE "enchantment         ".
    05 FILLER PIC X(20) VALUE "furnace             ".
    05 FILLER PIC X(20) VALUE "grindstone          ".
    05 FILLER PIC X(20) VALUE "hopper              ".
    05 FILLER PIC X(20) VALUE "lectern             ".
    05 FILLER PIC X(20) VALUE "loom                ".
    05 FILLER PIC X(20) VALUE "merchant            ".
    05 FILLER PIC X(20) VALUE "shulker_box         ".
    05 FILLER PIC X(20) VALUE "smithing            ".
    05 FILLER PIC X(20) VALUE "smoker              ".
    05 FILLER PIC X(20) VALUE "cartography_table   ".
    05 FILLER PIC X(20) VALUE "stonecutter         ".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-KEY                PIC X(20) OCCURS 25 TIMES.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(32).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-KEY L-LENGTH.
     MOVE SPACES TO L-KEY
     MOVE 0 TO L-LENGTH
     IF L-ID >= 0 AND L-ID <= 24
         MOVE WS-KEY(L-ID + 1) TO L-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(L-KEY)) TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM MENU-TYPE-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-TYPE-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(32).
 01 L-LENGTH               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-LENGTH L-ID.
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 24
         CALL "MENU-TYPE-INFO" USING WS-I WS-KEY WS-LENGTH
         IF WS-KEY = L-KEY AND WS-LENGTH = L-LENGTH
             MOVE WS-I TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-TYPE-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-VALID-SLOT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-COUNT L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-INDEX = -1 OR L-INDEX = -999 OR L-INDEX < L-COUNT
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM MENU-VALID-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-INPUT-DECODE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-INPUT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-INPUT.
     MOVE 0 TO L-INPUT
     IF L-ID >= 0 AND L-ID <= 6
         MOVE L-ID TO L-INPUT
     END-IF
     GOBACK.
 END PROGRAM MENU-INPUT-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-QC-MASK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BUTTON               BINARY-LONG.
 01 L-HEADER               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-MASK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BUTTON L-HEADER L-TYPE L-MASK.
     COMPUTE L-HEADER = FUNCTION MOD(L-BUTTON, 4)
     COMPUTE L-TYPE = FUNCTION MOD((L-BUTTON - L-HEADER) / 4, 4)
     COMPUTE L-MASK = L-HEADER + L-TYPE * 4
     GOBACK.
 END PROGRAM MENU-QC-MASK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-APPEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-OWN                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-CONTAINER-SLOT       BINARY-LONG.
 PROCEDURE DIVISION USING L-OWN L-SLOT L-CONTAINER-SLOT.
     MOVE -1 TO L-CONTAINER-SLOT
     IF L-SLOT >= L-OWN
         COMPUTE WS-REL = L-SLOT - L-OWN
         IF WS-REL < 27
             COMPUTE L-CONTAINER-SLOT = 9 + WS-REL
         ELSE
             COMPUTE L-CONTAINER-SLOT = WS-REL - 27
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MENU-APPEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-ID-NEXT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTER              BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTER L-NEXT.
     COMPUTE L-NEXT = FUNCTION MOD(L-COUNTER, 100) + 1
     GOBACK.
 END PROGRAM MENU-ID-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATE-NEXT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-NEXT.
     COMPUTE L-NEXT = FUNCTION MOD(L-STATE + 1, 32768)
     GOBACK.
 END PROGRAM MENU-STATE-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-DESYNC.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLIENT               BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLIENT L-SERVER L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-CLIENT NOT = L-SERVER
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM MENU-DESYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-GEOMETRY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GUI-W                BINARY-LONG.
 01 L-GUI-H                BINARY-LONG.
 01 L-IMAGE-W              BINARY-LONG.
 01 L-IMAGE-H              BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-LABEL-Y              BINARY-LONG.
 PROCEDURE DIVISION USING L-GUI-W L-GUI-H L-IMAGE-W L-IMAGE-H L-LEFT L-TOP L-LABEL-Y.
     COMPUTE L-LEFT = (L-GUI-W - L-IMAGE-W) / 2
     COMPUTE L-TOP = (L-GUI-H - L-IMAGE-H) / 2
     COMPUTE L-LABEL-Y = L-IMAGE-H - 94
     GOBACK.
 END PROGRAM MENU-GEOMETRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-HIGHLIGHT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-OUT-X                BINARY-LONG.
 01 L-OUT-Y                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-OUT-X L-OUT-Y.
     COMPUTE L-OUT-X = L-X - 4
     COMPUTE L-OUT-Y = L-Y - 4
     GOBACK.
 END PROGRAM MENU-HIGHLIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-TITLE-X.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IMAGE-W              BINARY-LONG.
 01 L-TITLE-W              BINARY-LONG.
 01 L-X                    BINARY-LONG.
 PROCEDURE DIVISION USING L-IMAGE-W L-TITLE-W L-X.
     COMPUTE L-X = (L-IMAGE-W - L-TITLE-W) / 2
     GOBACK.
 END PROGRAM MENU-TITLE-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-OWN-SLOTS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ROWS L-OWN L-TOTAL.
     EVALUATE L-KIND
         WHEN 1 COMPUTE L-OWN = 9 * L-ROWS
         WHEN 2 MOVE 27 TO L-OWN
         WHEN 3 MOVE 5 TO L-OWN
         WHEN OTHER MOVE 9 TO L-OWN
     END-EVALUATE
     COMPUTE L-TOTAL = L-OWN + 36
     GOBACK.
 END PROGRAM MENU-OWN-SLOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-TYPE-OF.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ROWS L-TYPE.
     EVALUATE L-KIND
         WHEN 1 COMPUTE L-TYPE = L-ROWS - 1
         WHEN 2 MOVE 20 TO L-TYPE
         WHEN 3 MOVE 16 TO L-TYPE
         WHEN OTHER MOVE 6 TO L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-TYPE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-LAYOUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OWN                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-REL                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-CSLOT                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ROWS L-SLOT L-PART L-CSLOT L-X L-Y.
     MOVE 0 TO L-PART L-CSLOT L-X L-Y
     CALL "MENU-OWN-SLOTS" USING L-KIND L-ROWS WS-OWN WS-TOTAL
     IF L-SLOT < 0 OR L-SLOT >= WS-TOTAL
         GOBACK
     END-IF
     IF L-SLOT < WS-OWN
         MOVE 1 TO L-PART
         MOVE L-SLOT TO L-CSLOT
         EVALUATE L-KIND
             WHEN 3
                 COMPUTE L-X = 44 + 18 * L-SLOT
                 MOVE 20 TO L-Y
             WHEN 4
                 COMPUTE WS-COL = FUNCTION MOD(L-SLOT, 3)
                 COMPUTE WS-ROW = (L-SLOT - WS-COL) / 3
                 COMPUTE L-X = 62 + 18 * WS-COL
                 COMPUTE L-Y = 17 + 18 * WS-ROW
             WHEN OTHER
                 COMPUTE WS-COL = FUNCTION MOD(L-SLOT, 9)
                 COMPUTE WS-ROW = (L-SLOT - WS-COL) / 9
                 COMPUTE L-X = 8 + 18 * WS-COL
                 COMPUTE L-Y = 18 + 18 * WS-ROW
         END-EVALUATE
         GOBACK
     END-IF
     MOVE 2 TO L-PART
     EVALUATE L-KIND
         WHEN 1 COMPUTE WS-Y0 = 31 + 18 * L-ROWS
         WHEN 3 MOVE 51 TO WS-Y0
         WHEN OTHER MOVE 84 TO WS-Y0
     END-EVALUATE
     CALL "MENU-APPEND" USING WS-OWN L-SLOT L-CSLOT
     COMPUTE WS-REL = L-SLOT - WS-OWN
     IF WS-REL < 27
         COMPUTE WS-COL = FUNCTION MOD(WS-REL, 9)
         COMPUTE WS-ROW = (WS-REL - WS-COL) / 9
         COMPUTE L-X = 8 + 18 * WS-COL
         COMPUTE L-Y = WS-Y0 + 18 * WS-ROW
     ELSE
         COMPUTE L-X = 8 + 18 * L-CSLOT
         COMPUTE L-Y = WS-Y0 + 58
     END-IF
     GOBACK.
 END PROGRAM MENU-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-IMAGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-LABEL-Y              BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ROWS L-WIDTH L-HEIGHT L-LABEL-Y.
     MOVE 176 TO L-WIDTH
     EVALUATE L-KIND
         WHEN 1 COMPUTE L-HEIGHT = 114 + 18 * L-ROWS
         WHEN 2 MOVE 167 TO L-HEIGHT
         WHEN 3 MOVE 133 TO L-HEIGHT
         WHEN OTHER MOVE 166 TO L-HEIGHT
     END-EVALUATE
     COMPUTE L-LABEL-Y = L-HEIGHT - 94
     GOBACK.
 END PROGRAM MENU-IMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-QUICK-RANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OWN                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REVERSE              BINARY-LONG.
 01 L-PROGRESS             BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ROWS L-INDEX L-FIRST L-END L-REVERSE L-PROGRESS.
     CALL "MENU-OWN-SLOTS" USING L-KIND L-ROWS WS-OWN WS-TOTAL
     IF L-INDEX < WS-OWN
         MOVE WS-OWN TO L-FIRST
         MOVE WS-TOTAL TO L-END
         MOVE 1 TO L-REVERSE
     ELSE
         MOVE 0 TO L-FIRST L-REVERSE
         MOVE WS-OWN TO L-END
     END-IF
     MOVE 0 TO L-PROGRESS
     IF L-KIND = 4
         MOVE 1 TO L-PROGRESS
     END-IF
     GOBACK.
 END PROGRAM MENU-QUICK-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-QUICK-OK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-ORIGINAL             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-AFTER L-ORIGINAL L-OK.
     MOVE 1 TO L-OK
     IF L-KIND = 4 AND L-AFTER = L-ORIGINAL
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MENU-QUICK-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-MAY-PLACE-K.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-SHULKER              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SLOT L-SHULKER L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-KIND = 2 AND L-SLOT < 27 AND L-SHULKER = 1
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM MENU-MAY-PLACE-K.
