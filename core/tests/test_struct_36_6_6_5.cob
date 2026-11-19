*> Section test of 36-structures-6-ocean.md section 6.5 (data marker effects of an ocean ruin) with the handler of 3.5, over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a
*> pass without it): a chest marker in water makes a chest (facing north, single) with waterlogged true and the loot table chests/underwater_ruin_small with the next nextLong of the placement random as
*> its seed (the big table for a large ruin); a drowned marker at y 62 with the sea level 63 asks for one persistent drowned and the marker cell becomes water, at y 64 it becomes air and no other
*> marker draws. Written from the document alone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-6-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY GENBE.
 COPY GENENT.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-PTR                 USAGE POINTER.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-META                PIC X(96).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-WCX                 BINARY-LONG VALUE 0.
 01 WS-WCZ                 BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 424242.
 01 WS-S1                  BINARY-DOUBLE.
 01 WS-S2                  BINARY-DOUBLE.
 01 WS-PROP                PIC X(24).
 01 WS-TEXT                PIC X(32).
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
         MOVE "acceptance US12 36-6§6.5 Data marker effects: no generated packs here, skipped" TO TL-CASE
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
     PERFORM CHEST-CASES
     PERFORM DROWNED-CASES
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the chunk window of chunk (0, 0), empty, and one ocean ruin piece (kind 3, small: aux 0)
 WINDOW-OPEN.
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-WCX WS-WCZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 0 TO GBL-COUNT GBL-LOST
     MOVE 0 TO GEL-COUNT GEL-LOST
     MOVE 1 TO SP-COUNT
     MOVE 3 TO SP-T-KIND(1)
     MOVE 0 TO SP-T-AUX(1).

*> the placement random at a known state, its first draw in WS-S1 and the state back
 RESET-RANDOM.
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     CALL "MSP-RNG-LONG" USING WS-S1
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI.

 BLOCK-KEY-AT.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE SPACES TO WS-KEY
     MOVE CB-KEY(WS-BLOCK) TO WS-KEY.

*> 6.5: a chest marker at (x, y, z) in water: the chest, waterlogged true, the small table and the next nextLong
 CHEST-CASES.
     PERFORM WINDOW-OPEN
     MOVE "minecraft:water" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY WS-STATE
     MOVE 4 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 4 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-TWO WS-FLAG
     PERFORM RESET-RANDOM
     MOVE "chest" TO WS-META
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     PERFORM BLOCK-KEY-AT
     MOVE "acceptance US12 36-6§6.5 Data marker effects: a chest marker in water becomes a chest" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-KEY = "chest"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "waterlogged" TO WS-PROP
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-PROP WS-TEXT WS-FLAG
     MOVE "acceptance US12 36-6§6.5 Data marker effects: that chest is waterlogged" TO TL-CASE
     IF WS-FLAG = 1 AND WS-TEXT = "true"
         MOVE 1 TO WS-FLAG
     ELSE
         MOVE 0 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "facing" TO WS-PROP
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-PROP WS-TEXT WS-FLAG
     MOVE "acceptance US12 36-6§3.5 Ocean ruins piece: the chest of a marker always faces north" TO TL-CASE
     IF WS-FLAG = 1 AND WS-TEXT = "north"
         MOVE 1 TO WS-FLAG
     ELSE
         MOVE 0 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "acceptance US12 36-6§6.5 Data marker effects: one request with chests/underwater_ruin_small and the next nextLong of the placement random as its seed" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF GBL-COUNT = 1 AND GBL-LOOT(1) = "minecraft:chests/underwater_ruin_small" AND GBL-SEED(1) = WS-S1 AND GBL-X(1) = WS-X AND GBL-Y(1) = WS-Y AND GBL-Z(1) = WS-Z
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     PERFORM WINDOW-OPEN
     MOVE 1 TO SP-T-AUX(1)
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     PERFORM RESET-RANDOM
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-6§3.5 Ocean ruins piece: a large ruin's chest asks for chests/underwater_ruin_big" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF GBL-COUNT = 1 AND GBL-LOOT(1) = "minecraft:chests/underwater_ruin_big" AND GBL-SEED(1) = WS-S1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 6.5: a drowned marker at y 62 (sea level 63): one persistent drowned and the cell becomes water; at y 64 the cell becomes air; another metadata does nothing and draws nothing
 DROWNED-CASES.
     PERFORM WINDOW-OPEN
     MOVE "drowned" TO WS-META
     MOVE 5 TO WS-X
     MOVE 62 TO WS-Y
     MOVE 5 TO WS-Z
     PERFORM RESET-RANDOM
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     PERFORM BLOCK-KEY-AT
     MOVE "acceptance US12 36-6§6.5 Data marker effects: a drowned marker at y 62 asks for one persistent drowned at the block centre" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF GEL-COUNT = 1 AND GEL-NBT(1)(8:17) = "minecraft:drowned" AND GEL-Y(1) = 62
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "acceptance US12 36-6§6.5 Data marker effects: a drowned marker at y 62 below the sea level 63 leaves water in its cell" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-KEY = "water"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 64 TO WS-Y
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     PERFORM BLOCK-KEY-AT
     MOVE "acceptance US12 36-6§6.5 Data marker effects: a drowned marker at y 64 above the sea level leaves air in its cell" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-KEY = "air"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "something" TO WS-META
     MOVE 66 TO WS-Y
     PERFORM RESET-RANDOM
     MOVE 0 TO GBL-COUNT GEL-COUNT
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     CALL "MSP-RNG-LONG" USING WS-S2
     MOVE "acceptance US12 36-6§3.5 Ocean ruins piece: any other metadata changes nothing, asks for nothing and draws nothing" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-S2 = WS-S1 AND GBL-COUNT = 0 AND GEL-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 END PROGRAM TEST-STRUCT-36-6-6-5.

 COPY NOSPAWN.
 COPY CORETEST.
