*> Test of the terrain adaptation of the Nether's structures (docs/protocol/37-nether-2 section 10.1, 36-1 section 9.1): on the generated vanilla data (CC_GENERATED_DIR; passes as skipped without it) only
*> nether_fossil adapts the terrain in the Nether (beard_thin); fortress, bastion_remnant and ruined_portal_nether have no terrain_adaptation key, so none. The beardifier node itself (37-2 section 10.2 to 10.4,
*> the terms and the worked table) is the work of lane p45f (core/src/struct-beard.cob, struct-36-1-9.cob), not in this base: the Nether's terrain adds no beardifier here (core/src/nether-37-2.cob).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-37-2-ADAPT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEYS.
    05 FILLER PIC X(80) VALUE "minecraft:fortress".
    05 FILLER PIC X(80) VALUE "minecraft:bastion_remnant".
    05 FILLER PIC X(80) VALUE "minecraft:ruined_portal_nether".
    05 FILLER PIC X(80) VALUE "minecraft:nether_fossil".
 01 WS-KEY-TAB REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(80) OCCURS 4 TIMES.
 01 WS-WANT.
    05 WS-W                BINARY-LONG OCCURS 4 TIMES.
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
         MOVE "37-2 10.1 Nether terrain adaptation: no generated packs here, skipped" TO TL-CASE
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
     MOVE 0 TO WS-W(1) WS-W(2) WS-W(3)
     MOVE 2 TO WS-W(4)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE -1 TO WS-FOUND
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
             IF SDT-KEY(WS-I) = WS-KEY(WS-K)
                 MOVE SDT-ADAPT(WS-I) TO WS-FOUND
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "37-2 10.1 terrain_adaptation of " FUNCTION TRIM(WS-KEY(WS-K)) " (0 none, 2 beard_thin)" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-W(WS-K) TO TL-EXPECTED-N
         MOVE WS-FOUND TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-STRUCT-37-2-ADAPT.

 COPY NOSPAWN.
 COPY CORETEST.
