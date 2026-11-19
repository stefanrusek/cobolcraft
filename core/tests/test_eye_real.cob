*> Real-data test (skipped as a pass without the generated packs; lane buglocate3, operator report of try15: "using an ender eye doesn't throw it into the air"). A standard world
*> of seed 12345 is opened from the generated packs, a survival player holds ender eyes and sends the real Use Item packet (0x43) through the play path (no direct call of
*> THROWN-ITEM-USE and no fixture data: the structure sets, the climate source and the ring list are the ones the world made). Expected (docs/protocol/25 section 6.3, 21 section 8.12,
*> 36-5 section 3.10): one eye_of_ender entity is added for the player (Add Entity), the stack loses one, and the eye moves on the next ticks (Teleport Entity or Entity Motion packets).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EYE-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ID                  BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-EYE-ITEM            BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-DISCARD             PIC X(1024).
 01 WS-TICKS               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
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
         MOVE "acceptance eye real: no generated packs here, skipped" TO TL-CASE
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
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE CN-PLAYER(WS-ID) TO WS-ROW
     MOVE "minecraft:ender_eye" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EYE-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     MOVE WS-EYE-ITEM TO PL-SLOT-ITEM(WS-ROW, WS-SLOT)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, WS-SLOT)
     CALL "CRAFT-REFRESH-ALL"
     CALL "TEST-DRAIN-ENTITIES" USING WS-ID WS-DISCARD
     CALL "TEST-USE-ITEM" USING WS-ID
     CALL "TEST-DRAIN-ENTITIES" USING WS-ID WS-TEXT
     DISPLAY "EYE use: " FUNCTION TRIM(WS-TEXT) " count " PL-SLOT-COUNT(WS-ROW, WS-SLOT)
     PERFORM VARYING WS-TICKS FROM 1 BY 1 UNTIL WS-TICKS > 100
         MOVE 1 TO WS-COUNT
         CALL "TEST-TICKS" USING WS-COUNT
         CALL "TEST-DRAIN-ENTITIES" USING WS-ID WS-TEXT
         IF WS-TEXT NOT = SPACES AND (WS-TICKS < 6 OR WS-TICKS > 78)
             DISPLAY "EYE tick " WS-TICKS ": " FUNCTION TRIM(WS-TEXT)
         END-IF
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-EYE-REAL.

 COPY NOSPAWN.
 COPY CORETEST.
