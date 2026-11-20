*> Section test of 36-structures-6-ocean.md section 6.4 (shipwreck vectors) with the template facts of 4.1, over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass without
*> it): the twenty template files with the sizes of 4.1 (a degraded variant the size of its twin), eight palettes each and 14 supply, 16 map and 14 treasure markers in all; the starts of 6.4 at
*> world seed 0 (chunk (0,0) ocean and beached, chunk (7,-3) ocean); the palette choice LCG(getSeed(templatePosition)).nextInt(8) at five positions; the box of a with_mast piece at (0,90,0)
*> rotated clockwise 90 with the pivot (4,0,15). Written from the document alone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-6-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-OCEAN               BINARY-LONG.
 01 WS-BEACHED             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-LIST                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-N                   BINARY-LONG.
 01 WS-SIZES-OK            BINARY-LONG.
 01 WS-PAL-OK              BINARY-LONG.
 01 WS-SUPPLY              BINARY-LONG.
 01 WS-MAP                 BINARY-LONG.
 01 WS-TREASURE            BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-PI                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-BX                  BINARY-LONG.
 01 WS-MIR                 BINARY-LONG VALUE 0.
 01 WS-ROT                 BINARY-LONG.
 01 WS-PVX                 BINARY-LONG VALUE 4.
 01 WS-PVZ                 BINARY-LONG VALUE 15.
 01 WS-SX                  BINARY-LONG VALUE 9.
 01 WS-SY                  BINARY-LONG VALUE 21.
 01 WS-SZ                  BINARY-LONG VALUE 28.
 01 WS-OX                  BINARY-LONG VALUE 0.
 01 WS-OY                  BINARY-LONG VALUE 90.
 01 WS-OZ                  BINARY-LONG VALUE 0.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-DEC                 PIC 9.
 01 WS-ED                  PIC -(3)9.
 01 WS-NAME-L              BINARY-LONG.
*> the ten base names with the size of 4.1: x, y, z
 01 WS-BASES.
    05 FILLER PIC X(29) VALUE "with_mast            09 21 28".
    05 FILLER PIC X(29) VALUE "upsidedown_full      09 09 28".
    05 FILLER PIC X(29) VALUE "upsidedown_fronthalf 09 09 22".
    05 FILLER PIC X(29) VALUE "upsidedown_backhalf  09 09 16".
    05 FILLER PIC X(29) VALUE "sideways_full        09 09 28".
    05 FILLER PIC X(29) VALUE "sideways_fronthalf   09 09 24".
    05 FILLER PIC X(29) VALUE "sideways_backhalf    09 09 17".
    05 FILLER PIC X(29) VALUE "rightsideup_full     09 09 28".
    05 FILLER PIC X(29) VALUE "rightsideup_fronthalf09 09 24".
    05 FILLER PIC X(29) VALUE "rightsideup_backhalf 09 09 16".
 01 WS-BASE-T REDEFINES WS-BASES.
    05 WS-B OCCURS 10 TIMES.
       10 B-NAME           PIC X(21).
       10 B-SX             PIC 99.
       10 FILLER           PIC X.
       10 B-SY             PIC 99.
       10 FILLER           PIC X.
       10 B-SZ             PIC 99.
*> the palette cases of 6.4: x, y, z, the index
 01 WS-PALS.
    05 FILLER PIC X(18) VALUE "+0000+0040+0000+03".
    05 FILLER PIC X(18) VALUE "+0000+0041+0000+00".
    05 FILLER PIC X(18) VALUE "+0000+0062+0000+02".
    05 FILLER PIC X(18) VALUE "+0100+0045-0030+05".
    05 FILLER PIC X(18) VALUE "-0017+0052+0033+03".
 01 WS-PAL-T REDEFINES WS-PALS.
    05 WS-PC OCCURS 5 TIMES.
       10 PC-X             PIC S9(4) SIGN LEADING SEPARATE.
       10 PC-Y             PIC S9(4) SIGN LEADING SEPARATE.
       10 PC-Z             PIC S9(4) SIGN LEADING SEPARATE.
       10 PC-V             PIC S9(2) SIGN LEADING SEPARATE.
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
         MOVE "acceptance US12 36-6§6.4 Shipwreck vectors: no generated packs here, skipped" TO TL-CASE
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
                 MOVE WS-I TO WS-OCEAN
             WHEN "minecraft:shipwreck_beached"
                 MOVE WS-I TO WS-BEACHED
         END-EVALUATE
     END-PERFORM
     PERFORM TEMPLATE-CASES
     PERFORM START-CASES
     PERFORM PALETTE-CASES
     PERFORM BOX-CASE
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 4.1: the twenty files (ten names, each intact and degraded): sizes, eight palettes, the supply, map and treasure markers (14, 16, 14 over the twenty files)
 TEMPLATE-CASES.
     MOVE 0 TO WS-SIZES-OK WS-PAL-OK WS-SUPPLY WS-MAP WS-TREASURE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 1
             MOVE SPACES TO WS-ID
             IF WS-J = 0
                 STRING "minecraft:shipwreck/" FUNCTION TRIM(B-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
             ELSE
                 STRING "minecraft:shipwreck/" FUNCTION TRIM(B-NAME(WS-I)) "_degraded" DELIMITED BY SIZE INTO WS-ID
             END-IF
             CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
             IF TP-STATUS(WS-ROW) = 1 AND TP-SX(WS-ROW) = B-SX(WS-I) AND TP-SY(WS-ROW) = B-SY(WS-I) AND TP-SZ(WS-ROW) = B-SZ(WS-I)
                 ADD 1 TO WS-SIZES-OK
             END-IF
             IF TP-PALETTES(WS-ROW) = 8
                 ADD 1 TO WS-PAL-OK
             END-IF
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TP-BLOCKS(WS-ROW)
                 MOVE TB-NBT(TP-BASE(WS-ROW, 1) + WS-K) TO WS-TAG
                 IF WS-TAG > 0
                     IF TN-KIND(WS-TAG) = 3
                         EVALUATE TN-TEXT(WS-TAG)
                             WHEN "supply_chest"
                                 ADD 1 TO WS-SUPPLY
                             WHEN "map_chest"
                                 ADD 1 TO WS-MAP
                             WHEN "treasure_chest"
                                 ADD 1 TO WS-TREASURE
                         END-EVALUATE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§4.1 Shipwrecks: the 20 template files exist with the sizes of 4.1 (a degraded variant the size of its twin)" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-SIZES-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§4.1 Shipwrecks: every file has 8 palettes" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-PAL-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§4.1 Shipwrecks: the 20 files hold 14 supply_chest markers" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-SUPPLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§4.1 Shipwrecks: the 20 files hold 16 map_chest markers" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-MAP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§4.1 Shipwrecks: the 20 files hold 14 treasure_chest markers" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-TREASURE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the start of WS-LIST at chunk WS-CX WS-CZ (world seed 0): the piece 1 is the template WS-ID with rotation WS-ROT
 START-IS.
     CALL "STRUCT-TPL-FIND-POINT" USING WS-LIST WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 1 AND SP-COUNT = 1
         MOVE SP-T-ROW(1) TO WS-ROW
         IF TP-KEY(WS-ROW) = WS-ID AND SP-T-ROT(1) = WS-ROT AND SP-T-X(1) = WS-CX * 16 AND SP-T-Z(1) = WS-CZ * 16
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF.

*> 6.4: world seed 0 chunk (0,0): ocean CLOCKWISE_180 and index 8 = rightsideup_fronthalf; beached CLOCKWISE_180 and index 6 = rightsideup_backhalf; chunk (7,-3) ocean CLOCKWISE_90, upsidedown_full
 START-CASES.
     MOVE 0 TO WS-CX WS-CZ
     MOVE WS-OCEAN TO WS-LIST
     MOVE "minecraft:shipwreck/rightsideup_fronthalf" TO WS-ID
     MOVE 2 TO WS-ROT
     PERFORM START-IS
     MOVE "acceptance US12 36-6§6.4 Shipwreck vectors: seed 0 chunk (0,0) ocean is CLOCKWISE_180 with index 8, rightsideup_fronthalf" TO TL-CASE
     PERFORM CHECK
     MOVE WS-BEACHED TO WS-LIST
     MOVE "minecraft:shipwreck/rightsideup_backhalf" TO WS-ID
     MOVE 2 TO WS-ROT
     PERFORM START-IS
     MOVE "acceptance US12 36-6§6.4 Shipwreck vectors: seed 0 chunk (0,0) beached is CLOCKWISE_180 with index 6, rightsideup_backhalf" TO TL-CASE
     PERFORM CHECK
     MOVE 7 TO WS-CX
     MOVE -3 TO WS-CZ
     MOVE WS-OCEAN TO WS-LIST
     MOVE "minecraft:shipwreck/upsidedown_full" TO WS-ID
     MOVE 1 TO WS-ROT
     PERFORM START-IS
     MOVE "acceptance US12 36-6§6.4 Shipwreck vectors: seed 0 chunk (7,-3) ocean is CLOCKWISE_90, upsidedown_full" TO TL-CASE
     PERFORM CHECK.

*> 6.4: the palette index LCG(getSeed(templatePosition)).nextInt(8) at five positions
 PALETTE-CASES.
     PERFORM VARYING WS-PI FROM 1 BY 1 UNTIL WS-PI > 5
         MOVE PC-X(WS-PI) TO WS-X
         MOVE PC-Y(WS-PI) TO WS-Y
         MOVE PC-Z(WS-PI) TO WS-Z
         CALL "STRUCT-PALETTE-PICK" USING WS-EIGHT WS-X WS-Y WS-Z WS-INDEX
         MOVE WS-PI TO WS-DEC
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-6§6.4 Shipwreck vectors: palette choice at position case " WS-DEC " is the document's" DELIMITED BY SIZE INTO TL-CASE
         MOVE PC-V(WS-PI) TO TL-EXPECTED-N
         MOVE WS-INDEX TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM.

*> 6.4: with_mast (9 x 21 x 28) at (0,90,0), CLOCKWISE_90, pivot (4,0,15): transform((0,0,0)) = (19,11), transform((8,20,27)) = (-8,19), box x -8..19, z 11..19, y 90..110
 BOX-CASE.
     MOVE 1 TO WS-ROT
     CALL "STRUCT-TX-BOX" USING WS-SX WS-SY WS-SZ WS-MIR WS-ROT WS-PVX WS-PVZ WS-OX WS-OY WS-OZ WS-BOX
     MOVE "acceptance US12 36-6§6.4 Shipwreck vectors: the with_mast box at (0,90,0) rotated clockwise 90 about (4,0,15) is x -8..19, y 90..110, z 11..19" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF B-X0 = -8 AND B-X1 = 19 AND B-Y0 = 90 AND B-Y1 = 110 AND B-Z0 = 11 AND B-Z1 = 19
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 END PROGRAM TEST-STRUCT-36-6-6-4.

 COPY NOSPAWN.
 COPY CORETEST.
