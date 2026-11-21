*> Acceptance test of the start of the ocean monument (docs/protocol/36-structures-6-ocean.md section 5.1 and the placement hook of 5.7; core/src/struct-mon-build.cob MON-FIND-POINT, struct-place.cob) over the generated
*> vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass without it): the biome tag required_ocean_monument_surrounding (is_ocean or is_river) is read, a start whose surroundings are all in it (the biome source
*> of a superflat world is one biome everywhere, 56 section 4.2) makes the one building piece (type 38, box x and z from chunkMin - 29 to chunkMin + 28, y 39 to 61 for every direction, the orientation the one
*> nextInt(4) of the start random of world seed 12345, against the Java LCG model of core/tests/fixtures/gen_monument.py), a start with any other biome in range is absent, the stub is on top of the chunk centre, and
*> STRUCT-PLACE-START hands the piece to the monument's postProcess (the window of the start chunk is the model's).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-5-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY FLATSET.
 COPY MTDATA.
 COPY MONCASES.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STRUCT              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-WANT-DIR            BINARY-LONG.
 01 WS-NAME                PIC X(160).
 01 WS-CS                  PIC -999.
 01 WS-CS2                 PIC -999.
 01 WS-H                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-SEED                BINARY-LONG VALUE 1112.
 01 WS-WX                  BINARY-LONG VALUE 0.
 01 WS-WZ                  BINARY-LONG VALUE 0.
 01 WS-KEEP-TYPE           PIC X(40).
 01 WS-CASES.
    05 FILLER              PIC X(9) VALUE "+000+0001".
    05 FILLER              PIC X(9) VALUE "-003+0052".
    05 FILLER              PIC X(9) VALUE "+004-0061".
    05 FILLER              PIC X(9) VALUE "+010+0102".
    05 FILLER              PIC X(9) VALUE "-007-0090".
    05 FILLER              PIC X(9) VALUE "+001+0000".
 01 WS-CASE-TAB REDEFINES WS-CASES.
    05 WS-C OCCURS 6 TIMES.
       10 WS-C-CX          PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-CZ          PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-DIR         PIC 9.
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
         MOVE "acceptance US12 36-6§5.1 no generated packs here, skipped" TO TL-CASE
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
     MOVE 0 TO WS-STRUCT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:monument"
             MOVE WS-I TO WS-STRUCT
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§5.1 The start: the monument structure is in the data" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STRUCT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   step 3: the tag required_ocean_monument_surrounding holds the ocean and river biomes and no land biome
     MOVE "minecraft:deep_ocean" TO WS-KEEP-TYPE
     PERFORM SURR-HAS
     MOVE "acceptance US12 36-6§5.1 The start: the surrounding tag holds deep_ocean (is_ocean)" TO TL-CASE
     PERFORM CHECK
     MOVE "minecraft:river" TO WS-KEEP-TYPE
     PERFORM SURR-HAS
     MOVE "acceptance US12 36-6§5.1 The start: the surrounding tag holds river (is_river)" TO TL-CASE
     PERFORM CHECK
     MOVE "minecraft:plains" TO WS-KEEP-TYPE
     PERFORM SURR-HAS
     MOVE "acceptance US12 36-6§5.1 The start: the surrounding tag does not hold plains" TO TL-CASE
     IF WS-FLAG = 0
         MOVE 1 TO WS-FLAG
     ELSE
         MOVE 0 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   a superflat world has one biome everywhere (56 section 4.2)
     MOVE "superflat" TO CW-WORLD-TYPE
     MOVE 1 TO FS-LOADED
     MOVE "minecraft:deep_ocean" TO FS-BIOME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-C-CX(WS-I) TO WS-CX
         MOVE WS-C-CZ(WS-I) TO WS-CZ
         MOVE WS-C-DIR(WS-I) TO WS-WANT-DIR
         CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE WS-CX TO WS-CS
         MOVE WS-CZ TO WS-CS2
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§5.1 The start: chunk " WS-CS "," WS-CS2 " in the deep ocean is valid with one building piece" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-VALID = 1 AND SP-COUNT = 1 AND SP-TYPE(1) = 38
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§5.1 The start: chunk " WS-CS "," WS-CS2 " the box is chunkMin - 29 to chunkMin + 28 and y 39 to 61, the stub the chunk centre" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO WS-FLAG
         IF SP-X0(1) = WS-CX * 16 - 29 AND SP-Z0(1) = WS-CZ * 16 - 29 AND SP-X1(1) = WS-CX * 16 + 28 AND SP-Z1(1) = WS-CZ * 16 + 28
            AND SP-Y0(1) = 39 AND SP-Y1(1) = 61 AND WS-X = WS-CX * 16 + 8 AND WS-Z = WS-CZ * 16 + 8
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§5.1 The start: chunk " WS-CS "," WS-CS2 " the orientation is the one nextInt(4) of the start random (model)" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE WS-WANT-DIR TO WS-J
         COMPUTE WS-J = FUNCTION MOD(WS-J + 2, 4)
         MOVE WS-J TO TL-EXPECTED-N
         MOVE SP-ORIENT(1) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   the river is in the tag too, plains is not
     MOVE "minecraft:river" TO FS-BIOME
     MOVE 0 TO WS-CX WS-CZ
     CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE "acceptance US12 36-6§5.1 The start: a river everywhere is accepted too" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 1 AND SP-COUNT = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:plains" TO FS-BIOME
     CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE "acceptance US12 36-6§5.1 The start: any biome of the range outside the tag makes the start absent (no piece)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 0 AND SP-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   the hook: STRUCT-PLACE-START post-processes the piece; the window of the start chunk (0, 0), world seed 12345, direction 1 is the model's (case 2 of MONCASES, window 13)
     MOVE "minecraft:deep_ocean" TO FS-BIOME
     CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE CW-SEED TO SP-SEED
     CALL "MT-SETUP"
     CALL "MT-WINDOW" USING WS-WX WS-WZ
     CALL "MT-SEED" USING WS-SEED
     CALL "STRUCT-PLACE-START"
     CALL "MT-HASH" USING WS-WX WS-WZ WS-HASH
     MOVE MC-B-HASH(2, 13) TO WS-WANT
     MOVE "acceptance US12 36-6§5.7 The start: STRUCT-PLACE-START draws the building through MON-POST (the window of the start chunk is the model's)" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-HASH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "standard" TO CW-WORLD-TYPE
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
*> WS-FLAG 1 when the biome WS-KEEP-TYPE is in the surrounding tag
 SURR-HAS.
     MOVE 0 TO WS-FLAG
     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N >= SD-SURR-COUNT
         COMPUTE WS-J = SD-SURR-FIRST + WS-N
         IF SD-BIOME(WS-J) = WS-KEEP-TYPE
             MOVE 1 TO WS-FLAG
         END-IF
     END-PERFORM.

 END PROGRAM TEST-STRUCT-36-6-5-1.
 COPY MONTEST.
 COPY NOSPAWN.
 COPY CORETEST.
