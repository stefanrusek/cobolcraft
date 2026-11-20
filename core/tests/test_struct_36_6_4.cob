*> Acceptance test of the shipwrecks (docs/protocol/36-structures-6-ocean.md section 4, 4.1 to 4.4; core/src/struct-tpl-gen.cob STRUCT-SHIPWRECK-PIECE, struct-tpl-piece.cob) over the generated vanilla-data
*> (CC_GENERATED_DIR, read only; skipped as a pass without it): the 20 and the 11 entry template lists in index order (every index is reached by a start of the Java LCG model of core/tests/fixtures/gen_monument.py: the
*> template, the rotation, the anchor, the pivot (4, 0, 15), the box by the rotation table of 2.2 and the one block_ignore processor), the sizes, the 8 palettes and the 14 + 16 + 14 loot markers of the 20 files (each above a
*> chest), no jigsaw, the dead branch of 4.2 step 3 (no template is above 32 in x or y), the beached rule `lowest - size.y / 2 - nextInt(3)` and the ocean rule (the mean of the floor heights) over the base heights, the loot
*> markers (the chest below gets the table and one nextLong, nothing else draws) and a template placed through the chunk window (a draw per chest when it is written, then one per marker).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPROC.
 COPY GENBE.
 COPY CELLS.
 COPY CBLOCKS.
 COPY FEATLEVEL.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SHIP                BINARY-LONG.
 01 WS-BEACH               BINARY-LONG.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BEACHED             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KIND-H              BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-AREA                BINARY-LONG.
 01 WS-WANT-Y              BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-WANT-KEY            PIC X(96).
 01 WS-LABEL               PIC X(80).
 01 WS-CS                  PIC -999.
 01 WS-CS2                 PIC -999.
 01 WS-IX                  PIC 99.
 01 WS-DRAW-D              PIC 9.
 01 WS-NAME                PIC X(200).
 01 WS-BX0                BINARY-LONG.
 01 WS-BZ0                BINARY-LONG.
 01 WS-BX1                BINARY-LONG.
 01 WS-BZ1                BINARY-LONG.
 01 WS-AX                 BINARY-LONG.
 01 WS-AZ                 BINARY-LONG.
 01 WS-CX1                 BINARY-LONG.
 01 WS-CZ1                 BINARY-LONG.
 01 WS-SUPPLY              BINARY-LONG.
 01 WS-MAP                 BINARY-LONG.
 01 WS-TREASURE            BINARY-LONG.
 01 WS-CHESTS-BELOW        BINARY-LONG.
 01 WS-JIG                 BINARY-LONG.
 01 WS-BIG                 BINARY-LONG.
 01 WS-TNBT                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-META                PIC X(96).
 01 WS-S1                  BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 4242.
 01 WS-SEED-SIGNED         BINARY-DOUBLE.
 01 WS-PTR                 USAGE POINTER.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-WCX                 BINARY-LONG VALUE 0.
 01 WS-WCZ                 BINARY-LONG VALUE 0.
 01 WS-PRIM-X              BINARY-LONG.
 01 WS-PRIM-Z              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(80).
 01 WS-PROC                BINARY-LONG.
 01 WS-CHESTS              BINARY-LONG.
 01 WS-MARKERS             BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-U64                 BINARY-DOUBLE UNSIGNED.
 01 WS-PX                  BINARY-LONG VALUE 4.
 01 WS-PZ                  BINARY-LONG VALUE 15.
 01 WS-NAMES.
    05 FILLER              PIC X(32) VALUE "with_mast".
    05 FILLER              PIC X(32) VALUE "upsidedown_full".
    05 FILLER              PIC X(32) VALUE "upsidedown_fronthalf".
    05 FILLER              PIC X(32) VALUE "upsidedown_backhalf".
    05 FILLER              PIC X(32) VALUE "sideways_full".
    05 FILLER              PIC X(32) VALUE "sideways_fronthalf".
    05 FILLER              PIC X(32) VALUE "sideways_backhalf".
    05 FILLER              PIC X(32) VALUE "rightsideup_full".
    05 FILLER              PIC X(32) VALUE "rightsideup_fronthalf".
    05 FILLER              PIC X(32) VALUE "rightsideup_backhalf".
    05 FILLER              PIC X(32) VALUE "with_mast_degraded".
    05 FILLER              PIC X(32) VALUE "upsidedown_full_degraded".
    05 FILLER              PIC X(32) VALUE "upsidedown_fronthalf_degraded".
    05 FILLER              PIC X(32) VALUE "upsidedown_backhalf_degraded".
    05 FILLER              PIC X(32) VALUE "sideways_full_degraded".
    05 FILLER              PIC X(32) VALUE "sideways_fronthalf_degraded".
    05 FILLER              PIC X(32) VALUE "sideways_backhalf_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_full_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_fronthalf_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_backhalf_degraded".
    05 FILLER              PIC X(32) VALUE "with_mast".
    05 FILLER              PIC X(32) VALUE "sideways_full".
    05 FILLER              PIC X(32) VALUE "sideways_fronthalf".
    05 FILLER              PIC X(32) VALUE "sideways_backhalf".
    05 FILLER              PIC X(32) VALUE "rightsideup_full".
    05 FILLER              PIC X(32) VALUE "rightsideup_fronthalf".
    05 FILLER              PIC X(32) VALUE "rightsideup_backhalf".
    05 FILLER              PIC X(32) VALUE "with_mast_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_full_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_fronthalf_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_backhalf_degraded".
 01 WS-NAME-TAB REDEFINES WS-NAMES.
    05 WS-LIST-NAME        PIC X(32) OCCURS 31 TIMES.
*> the sizes of the 20 files (x, y, z) in the order of the ocean list
 01 WS-SIZES.
    05 FILLER              PIC X(6) VALUE "092128".
    05 FILLER              PIC X(6) VALUE "090928".
    05 FILLER              PIC X(6) VALUE "090922".
    05 FILLER              PIC X(6) VALUE "090916".
    05 FILLER              PIC X(6) VALUE "090928".
    05 FILLER              PIC X(6) VALUE "090924".
    05 FILLER              PIC X(6) VALUE "090917".
    05 FILLER              PIC X(6) VALUE "090928".
    05 FILLER              PIC X(6) VALUE "090924".
    05 FILLER              PIC X(6) VALUE "090916".
    05 FILLER              PIC X(6) VALUE "092128".
    05 FILLER              PIC X(6) VALUE "090928".
    05 FILLER              PIC X(6) VALUE "090922".
    05 FILLER              PIC X(6) VALUE "090916".
    05 FILLER              PIC X(6) VALUE "090928".
    05 FILLER              PIC X(6) VALUE "090924".
    05 FILLER              PIC X(6) VALUE "090917".
    05 FILLER              PIC X(6) VALUE "090928".
    05 FILLER              PIC X(6) VALUE "090924".
    05 FILLER              PIC X(6) VALUE "090916".
 01 WS-SIZE-TAB REDEFINES WS-SIZES.
    05 WS-SZ OCCURS 20 TIMES.
       10 WS-SZ-X          PIC 99.
       10 WS-SZ-Y          PIC 99.
       10 WS-SZ-Z          PIC 99.
*> the starts: beached (1), list index (2), chunk x and z (sign and 3 digits), rotation (1), the beached draw (1)
 01 WS-CASES.
    05 FILLER              PIC X(13) VALUE "000+000+00010".
    05 FILLER              PIC X(13) VALUE "001+001+00210".
    05 FILLER              PIC X(13) VALUE "002+001+01030".
    05 FILLER              PIC X(13) VALUE "003+000+02610".
    05 FILLER              PIC X(13) VALUE "004+000+00600".
    05 FILLER              PIC X(13) VALUE "005+000+00120".
    05 FILLER              PIC X(13) VALUE "006+000+00500".
    05 FILLER              PIC X(13) VALUE "007+000+03210".
    05 FILLER              PIC X(13) VALUE "008+000+03500".
    05 FILLER              PIC X(13) VALUE "009+000+00800".
    05 FILLER              PIC X(13) VALUE "010+000+01800".
    05 FILLER              PIC X(13) VALUE "011+000+01300".
    05 FILLER              PIC X(13) VALUE "012+000+02110".
    05 FILLER              PIC X(13) VALUE "013+000+00300".
    05 FILLER              PIC X(13) VALUE "014+001+00810".
    05 FILLER              PIC X(13) VALUE "015+000+02400".
    05 FILLER              PIC X(13) VALUE "016+000+03130".
    05 FILLER              PIC X(13) VALUE "017+001+02330".
    05 FILLER              PIC X(13) VALUE "018+000+01230".
    05 FILLER              PIC X(13) VALUE "019+002+00000".
    05 FILLER              PIC X(13) VALUE "100+000+01232".
    05 FILLER              PIC X(13) VALUE "101+000+00202".
    05 FILLER              PIC X(13) VALUE "102+000+00412".
    05 FILLER              PIC X(13) VALUE "103+000+00802".
    05 FILLER              PIC X(13) VALUE "104+000+01801".
    05 FILLER              PIC X(13) VALUE "105+000+01032".
    05 FILLER              PIC X(13) VALUE "106+000+00010".
    05 FILLER              PIC X(13) VALUE "107+000+00122".
    05 FILLER              PIC X(13) VALUE "108+000+02911".
    05 FILLER              PIC X(13) VALUE "109+000+00701".
    05 FILLER              PIC X(13) VALUE "110+000+00930".
 01 WS-CASE-TAB REDEFINES WS-CASES.
    05 WS-C OCCURS 31 TIMES.
       10 WS-C-BEACHED     PIC 9.
       10 WS-C-IDX         PIC 99.
       10 WS-C-CX          PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-CZ          PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-ROT         PIC 9.
       10 WS-C-DRAW        PIC 9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
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
         MOVE "acceptance US12 36-6§4 Shipwrecks: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         EVALUATE SDT-KEY(WS-I)
             WHEN "minecraft:shipwreck"
                 MOVE WS-I TO WS-SHIP
             WHEN "minecraft:shipwreck_beached"
                 MOVE WS-I TO WS-BEACH
         END-EVALUATE
     END-PERFORM
     PERFORM SIZE-CASES
     PERFORM START-CASES
     PERFORM MARKER-CASES
     PERFORM PLACE-CASE
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 4.1: the sizes, the palettes and the markers of the 20 files of the ocean list, no jigsaw, and for 4.2 step 3 that no size is above 32 in x or y
 SIZE-CASES.
     MOVE 0 TO WS-SUPPLY WS-MAP WS-TREASURE WS-CHESTS-BELOW WS-JIG WS-BIG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE SPACES TO WS-ID
         STRING "minecraft:shipwreck/" FUNCTION TRIM(WS-LIST-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         MOVE SPACES TO WS-NAME
         MOVE WS-I TO WS-IX
         STRING "acceptance US12 36-6§4.1 Template lists: entry " WS-IX " " FUNCTION TRIM(WS-LIST-NAME(WS-I)) " has the size of the document and 8 palettes" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO WS-FLAG
         IF TP-STATUS(WS-ROW) = 1 AND TP-SX(WS-ROW) = WS-SZ-X(WS-I) AND TP-SY(WS-ROW) = WS-SZ-Y(WS-I) AND TP-SZ(WS-ROW) = WS-SZ-Z(WS-I) AND TP-PALETTES(WS-ROW) = 8
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
         IF TP-SX(WS-ROW) > 32 OR TP-SY(WS-ROW) > 32
             ADD 1 TO WS-BIG
         END-IF
*>       the records of the first palette
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TP-BLOCKS(WS-ROW)
             COMPUTE WS-K = TP-BASE(WS-ROW, 1) + WS-J
             MOVE TB-NBT(WS-K) TO WS-TNBT
             IF WS-TNBT > 0
                 EVALUATE TN-KIND(WS-TNBT)
                     WHEN 3
                         EVALUATE TRUE
                             WHEN TN-TEXT(WS-TNBT) = "supply_chest"
                                 ADD 1 TO WS-SUPPLY
                                 PERFORM CHEST-BELOW
                             WHEN TN-TEXT(WS-TNBT) = "map_chest"
                                 ADD 1 TO WS-MAP
                                 PERFORM CHEST-BELOW
                             WHEN TN-TEXT(WS-TNBT) = "treasure_chest"
                                 ADD 1 TO WS-TREASURE
                                 PERFORM CHEST-BELOW
                         END-EVALUATE
                     WHEN 4
                         ADD 1 TO WS-JIG
                 END-EVALUATE
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§4.1 Template lists: the 20 files hold 14 supply_chest markers" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-SUPPLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§4.1 Template lists: the 20 files hold 16 map_chest markers" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-MAP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§4.1 Template lists: the 20 files hold 14 treasure_chest markers" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-TREASURE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§4.1 Template lists: every marker sits directly above a chest block of the template" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-SUPPLY + WS-MAP + WS-TREASURE
     MOVE WS-CHESTS-BELOW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§2.3 What a template piece does when it is placed: no shipwreck template holds a jigsaw block" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-JIG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§4.2 The structure start: no template is above 32 in x or y, so isTooBigToFitInWorldGenRegion is false for all 20 (the dead branch of step 3)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BIG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> a marker record (WS-K) has a chest record in the same palette one block lower
 CHEST-BELOW.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > TP-BLOCKS(WS-ROW)
         COMPUTE WS-IDX = TP-BASE(WS-ROW, 1) + WS-R
         IF TB-X(WS-IDX) = TB-X(WS-K) AND TB-Z(WS-IDX) = TB-Z(WS-K) AND TB-Y(WS-IDX) = TB-Y(WS-K) - 1
             MOVE TB-STATE(WS-IDX) TO WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF CB-KEY(WS-BLOCK) = "chest"
                 MOVE 1 TO WS-N
             END-IF
         END-IF
     END-PERFORM
     ADD WS-N TO WS-CHESTS-BELOW.

*> 4.1 to 4.4: every index of both lists reached by a start of the model
 START-CASES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
         MOVE WS-C-BEACHED(WS-I) TO WS-BEACHED
         MOVE WS-C-IDX(WS-I) TO WS-IDX
         MOVE WS-C-CX(WS-I) TO WS-CX
         MOVE WS-C-CZ(WS-I) TO WS-CZ
         MOVE WS-C-ROT(WS-I) TO WS-ROT
         MOVE WS-C-DRAW(WS-I) TO WS-DRAW
         IF WS-BEACHED = 1
             MOVE WS-BEACH TO WS-STRUCT
             MOVE 0 TO WS-KIND-H
             COMPUTE WS-J = 20 + WS-IDX + 1
             MOVE "beached" TO WS-LABEL
         ELSE
             MOVE WS-SHIP TO WS-STRUCT
             MOVE 1 TO WS-KIND-H
             COMPUTE WS-J = WS-IDX + 1
             MOVE "ocean" TO WS-LABEL
         END-IF
         CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE WS-IDX TO WS-IX
         MOVE WS-CX TO WS-CS
         MOVE WS-CZ TO WS-CS2
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§4.1 Template lists: " FUNCTION TRIM(WS-LABEL) " entry " WS-IX " (chunk " WS-CS "," WS-CS2 ") is " FUNCTION TRIM(WS-LIST-NAME(WS-J)) DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO WS-FLAG
         MOVE SPACES TO WS-WANT-KEY
         STRING "minecraft:shipwreck/" FUNCTION TRIM(WS-LIST-NAME(WS-J)) DELIMITED BY SIZE INTO WS-WANT-KEY
         IF WS-VALID = 1 AND SP-COUNT = 1
             MOVE SP-T-ROW(1) TO WS-ROW
             IF TP-KEY(WS-ROW) = WS-WANT-KEY
                 MOVE 1 TO WS-FLAG
             END-IF
         END-IF
         PERFORM CHECK
*>       4.2: the anchor is the chunk's minimum corner, the rotation is the first draw, the stub is on top of the chunk centre by the heightmap of the structure
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§4.2 The structure start: " FUNCTION TRIM(WS-LABEL) " entry " WS-IX " (chunk " WS-CS "," WS-CS2 ") the piece is at (minX, y, minZ) with the model's rotation" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO WS-FLAG
         IF SP-T-X(1) = WS-CX * 16 AND SP-T-Z(1) = WS-CZ * 16 AND SP-T-ROT(1) = WS-ROT
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
         COMPUTE WS-GX = WS-CX * 16 + 8
         COMPUTE WS-GZ = WS-CZ * 16 + 8
         CALL "STRUCT-BASE-HEIGHT" USING WS-GX WS-GZ WS-KIND-H WS-H
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§4.2 The structure start: " FUNCTION TRIM(WS-LABEL) " entry " WS-IX " (chunk " WS-CS "," WS-CS2 ") the stub is on top of the chunk centre (WORLD_SURFACE_WG beached, OCEAN_FLOOR_WG else)" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-X = WS-GX AND WS-Z = WS-GZ AND WS-Y = WS-H - 1
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
*>       4.3: the pivot (4, 0, 15), the one block_ignore processor, the box by the rotation table of 2.2 around the pivot
         PERFORM BOX-OF
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§4.3 The piece: " FUNCTION TRIM(WS-LABEL) " entry " WS-IX " (chunk " WS-CS "," WS-CS2 ") has the pivot (4, 0, 15), one processor (block_ignore) and the box of 2.2 around the pivot" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO WS-FLAG
         MOVE SP-T-PROC(1) TO WS-PROC
         IF SP-T-PIV-X(1) = 4 AND SP-T-PIV-Z(1) = 15 AND SP-T-KIND(1) = 2 AND WS-PROC > 0
             IF SPL-N(WS-PROC) = 1 AND SP-X0(1) = WS-BX0 AND SP-X1(1) = WS-BX1 AND SP-Z0(1) = WS-BZ0 AND SP-Z1(1) = WS-BZ1
                 MOVE 1 TO WS-FLAG
             END-IF
         END-IF
         PERFORM CHECK
*>       4.3 and 4.4: the height: the mean of the floor heights of the unrotated footprint (ocean), or the lowest surface minus half the template's height minus the draw in 0 to 2 (beached)
         COMPUTE WS-GX = WS-CX * 16
         COMPUTE WS-GZ = WS-CZ * 16
         MOVE 0 TO WS-SUM
         MOVE 1000 TO WS-LOW
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ >= TP-SZ(WS-ROW)
             PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX >= TP-SX(WS-ROW)
                 COMPUTE WS-WX = WS-GX + WS-LX
                 COMPUTE WS-WZ = WS-GZ + WS-LZ
                 CALL "STRUCT-BASE-HEIGHT" USING WS-WX WS-WZ WS-KIND-H WS-H
                 ADD WS-H TO WS-SUM
                 IF WS-H < WS-LOW
                     MOVE WS-H TO WS-LOW
                 END-IF
             END-PERFORM
         END-PERFORM
         COMPUTE WS-AREA = TP-SX(WS-ROW) * TP-SZ(WS-ROW)
         IF WS-BEACHED = 1
             COMPUTE WS-K = TP-SY(WS-ROW) / 2
             COMPUTE WS-WANT-Y = WS-LOW - WS-K - WS-DRAW
         ELSE
             COMPUTE WS-WANT-Y = WS-SUM / WS-AREA
         END-IF
         MOVE SPACES TO WS-NAME
         MOVE WS-DRAW TO WS-DRAW-D
         IF WS-BEACHED = 1
             STRING "acceptance US12 36-6§4.4 Rotted, beached and ocean wrecks: beached entry " WS-IX " sits at lowest - size.y / 2 - the draw " WS-DRAW-D " of the start random" DELIMITED BY SIZE INTO WS-NAME
         ELSE
             STRING "acceptance US12 36-6§4.4 Rotted, beached and ocean wrecks: ocean entry " WS-IX " sits at the mean floor height of the unrotated footprint" DELIMITED BY SIZE INTO WS-NAME
         END-IF
         MOVE WS-NAME TO TL-CASE
         MOVE WS-WANT-Y TO TL-EXPECTED-N
         MOVE SP-T-Y(1) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM.

*> WS-BX0, WS-BZ0, WS-BX1, WS-BZ1: the box of the piece in row 1 by 2.2: the per-axis min and max of the transformed (0, 0) and (sx - 1, sz - 1), pivot (4, 15), moved by the anchor
 BOX-OF.
     MOVE 0 TO WS-WX WS-WZ
     PERFORM ROTATE-POS
     MOVE WS-PRIM-X TO WS-AX
     MOVE WS-PRIM-Z TO WS-AZ
     COMPUTE WS-WX = TP-SX(WS-ROW) - 1
     COMPUTE WS-WZ = TP-SZ(WS-ROW) - 1
     PERFORM ROTATE-POS
     COMPUTE WS-BX0 = FUNCTION MIN(WS-AX, WS-PRIM-X) + SP-T-X(1)
     COMPUTE WS-BX1 = FUNCTION MAX(WS-AX, WS-PRIM-X) + SP-T-X(1)
     COMPUTE WS-BZ0 = FUNCTION MIN(WS-AZ, WS-PRIM-Z) + SP-T-Z(1)
     COMPUTE WS-BZ1 = FUNCTION MAX(WS-AZ, WS-PRIM-Z) + SP-T-Z(1).
*> (WS-PRIM-X, WS-PRIM-Z) of (WS-WX, WS-WZ) by the rotation WS-ROT and the pivot (4, 15) (the table of 2.2)
 ROTATE-POS.
     EVALUATE WS-ROT
         WHEN 0
             MOVE WS-WX TO WS-PRIM-X
             MOVE WS-WZ TO WS-PRIM-Z
         WHEN 1
             COMPUTE WS-PRIM-X = WS-PX + WS-PZ - WS-WZ
             COMPUTE WS-PRIM-Z = WS-PZ - WS-PX + WS-WX
         WHEN 2
             COMPUTE WS-PRIM-X = 2 * WS-PX - WS-WX
             COMPUTE WS-PRIM-Z = 2 * WS-PZ - WS-WZ
         WHEN OTHER
             COMPUTE WS-PRIM-X = WS-PX - WS-PZ + WS-WZ
             COMPUTE WS-PRIM-Z = WS-PX + WS-PZ - WS-WX
     END-EVALUATE.

*> the chunk window of chunk (0, 0), empty
 WINDOW-OPEN.
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-WCX WS-WCZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 0 TO GBL-COUNT GBL-LOST.
*> the piece random at a known state, its first draw recorded in WS-S1
 RESET-RANDOM.
     MOVE 0 TO GBL-COUNT GBL-LOST
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     CALL "MSP-RNG-LONG" USING WS-S1
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI.

*> 4.3 handleDataMarker: a marker of the three kinds gives the chest below it the table of MARKERS_TO_LOOT and one nextLong; with no chest below, or any other metadata, nothing changes and nothing is drawn
 MARKER-CASES.
     PERFORM WINDOW-OPEN
     MOVE 1 TO SP-COUNT
     MOVE 2 TO SP-T-KIND(1)
     MOVE "minecraft:chest" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY WS-STATE
     MOVE 4 TO WS-X
     MOVE 39 TO WS-Y
     MOVE 4 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-TWO WS-FLAG
     MOVE 40 TO WS-Y
     MOVE "map_chest" TO WS-META
     MOVE "minecraft:chests/shipwreck_map" TO WS-ID
     PERFORM ONE-MARKER
     MOVE "treasure_chest" TO WS-META
     MOVE "minecraft:chests/shipwreck_treasure" TO WS-ID
     PERFORM ONE-MARKER
     MOVE "supply_chest" TO WS-META
     MOVE "minecraft:chests/shipwreck_supply" TO WS-ID
     PERFORM ONE-MARKER
*>   no chest below (the marker one block higher): the draw happens only when the block entity exists
     MOVE 41 TO WS-Y
     PERFORM RESET-RANDOM
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     CALL "MSP-RNG-LONG" USING WS-SEED-SIGNED
     MOVE "acceptance US12 36-6§4.3 The piece: a loot marker over a block that is not a chest asks for nothing and draws nothing" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF GBL-COUNT = 0 AND WS-SEED-SIGNED = WS-S1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 40 TO WS-Y
     MOVE "something" TO WS-META
     PERFORM RESET-RANDOM
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     CALL "MSP-RNG-LONG" USING WS-SEED-SIGNED
     MOVE "acceptance US12 36-6§4.3 The piece: any other metadata does nothing and draws nothing" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF GBL-COUNT = 0 AND WS-SEED-SIGNED = WS-S1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 ONE-MARKER.
     PERFORM RESET-RANDOM
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     MOVE SPACES TO WS-NAME
     STRING "acceptance US12 36-6§4.3 The piece: the " FUNCTION TRIM(WS-META) " marker gives the chest below the table " FUNCTION TRIM(WS-ID) " and the first nextLong" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF GBL-COUNT = 1 AND GBL-KIND(1) = 1 AND GBL-SEED(1) = WS-S1 AND GBL-X(1) = WS-X AND GBL-Z(1) = WS-Z AND GBL-Y(1) = WS-Y - 1 AND GBL-LOOT(1) = WS-ID
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 2.3 and 4.3: a template placed through the window (rightsideup_full, no rotation, anchor (1, 40, 0), one chunk pass): every chest written draws one nextLong at block writing, then every marker one more
*> (the marker's seed stays): the n chests of the window ask for the n draws that follow the first n, in the order of the markers
 PLACE-CASE.
     PERFORM WINDOW-OPEN
     CALL "SPB-RESET"
     MOVE "minecraft:shipwreck/rightsideup_full" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     MOVE "cobolcraft:inline/ignore_structure_and_air" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-PROC
     MOVE 2 TO WS-K
     MOVE 1 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 0 TO WS-Z
     MOVE 0 TO WS-ROT
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-K WS-ROW WS-X WS-Y WS-Z WS-ROT WS-ZERO WS-PX WS-Z2 WS-PZ WS-PROC WS-Z3 WS-Z4 WS-R
     CALL "MSP-OPEN"
     PERFORM RESET-RANDOM
     CALL "STRUCT-PLACE-START"
     MOVE 0 TO WS-CHESTS
     PERFORM VARYING WS-Y FROM 38 BY 1 UNTIL WS-Y > 70
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 IF CB-KEY(WS-BLOCK) = "chest"
                     ADD 1 TO WS-CHESTS
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§2.3 What a template piece does when it is placed: the template's chests are written in the window" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CHESTS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§4.3 The piece: every chest written has one loot request of the marker above it" TO TL-CASE
     MOVE WS-CHESTS TO TL-EXPECTED-N
     MOVE GBL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     PERFORM WS-CHESTS TIMES
         CALL "MSP-RNG-LONG" USING WS-SEED-SIGNED
     END-PERFORM
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GBL-COUNT
         CALL "MSP-RNG-LONG" USING WS-SEED-SIGNED
         IF GBL-SEED(WS-I) = WS-SEED-SIGNED AND GBL-LOOT(WS-I)(1:21) = "minecraft:chests/ship"
             ADD 1 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§4.3 The piece: the seed of each marker is the draw after the chests' own draws, in the order of the markers" TO TL-CASE
     MOVE GBL-COUNT TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-STRUCT-36-6-4.

 COPY NOSPAWN.
 COPY CORETEST.
