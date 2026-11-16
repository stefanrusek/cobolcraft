*> Acceptance test (lane fixa, A1; 20 section 7.1): in a standard world (generated data pack, CC_GENERATED_DIR; skipped as a pass without it) a spider
*> next to a player in full daylight takes no target (neutral where the light is 13 or more), and the cell of the spider has sky light.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SPIDER-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-IID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-PICK                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-SPIDER-TYPE         BINARY-LONG.
 01 WS-SPIDER              BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ENTITY-ROW          PIC X(66).
 PROCEDURE DIVISION.
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
         MOVE "N" TO TL-MODE
         MOVE "acceptance spider standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Spider" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:spider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SPIDER-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-ROW) TO WS-PX
     MOVE PL-Z(WS-ROW) TO WS-PZ
     MOVE 6000 TO CW-TIME
     COMPUTE WS-X = FUNCTION INTEGER(WS-PX) + 2
     COMPUTE WS-Z = FUNCTION INTEGER(WS-PZ)
*>   The highest solid cell of that column (the top of the terrain), the spider stands on it.
     MOVE 300 TO WS-Y
     MOVE 1 TO WS-STATE
     PERFORM UNTIL WS-STATE NOT = 0 OR WS-Y < 0
         SUBTRACT 1 FROM WS-Y
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     END-PERFORM
     ADD 1 TO WS-Y
     COMPUTE WS-PX = WS-X + 0.5
     COMPUTE WS-PZ = WS-Z + 0.5
     MOVE WS-Y TO WS-PY
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE WS-PY TO PL-Y(WS-ROW)
     MOVE WS-PZ TO PL-Z(WS-ROW)
     COMPUTE PL-X(WS-ROW) = WS-PX + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SPIDER-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-SPIDER
     MOVE "N" TO TL-MODE
     COMPUTE WS-GX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-GZ = FUNCTION INTEGER(WS-Z / 16)
     CALL "STDMOB-READY" USING WS-DIM WS-GX WS-GZ WS-GY
     CALL "STDMOB-LIGHTS" USING WS-DIM WS-X WS-Y WS-Z WS-SKY WS-BLK
     MOVE "acceptance spider standard: the cell above the top of the terrain has sky light 15" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-SKY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TARGET(WS-SPIDER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-PX TO EN-X(WS-SPIDER)
         MOVE WS-PY TO EN-Y(WS-SPIDER)
         CALL "MOB-STEP" USING WS-SPIDER
     END-PERFORM
     MOVE "acceptance spider standard: by day the spider next to a player takes no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-SPIDER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-SPIDER-STANDARD.
 COPY CORETEST.
