*> Real-data test (skipped as a pass without the generated packs; lane buglocate3 T43400, operator report of try15: "using an ender eye doesn't throw it into the air"). A standard world
*> of seed 12345 is opened from the generated packs, a survival player holds ender eyes and sends the real Use Item packet (0x43) through the play path (no direct call of
*> THROWN-ITEM-USE and no fixture data: the structure sets, the climate source and the ring list are the ones the world made), on the new world and again on the same world saved and
*> opened from disk (the climate points cleared the way a new process starts). Expected (docs/protocol/25 section 6.3, 21 section 8.12, 36-5 section 3.10): one eye_of_ender entity is
*> added (Add Entity), the stack loses one, the eye rises and moves (Teleport Entity packets), and after its flight it is removed and drops as an item (or breaks). The core was found to
*> do all of it (green on the first run): the throw was invisible because the client drew no ThrownItemRenderer (client/tests/test_thrown_item_eye.cob).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EYE-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY CLIMATE.
 COPY STRUCTDATA.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
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
 01 WS-PHASE               BINARY-LONG VALUE 0.
 01 WS-ITEM-TYPE           BINARY-LONG.
 01 WS-EYE-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-TYPE-EDIT           PIC -(9)9.
 01 WS-ID-EDIT             PIC -(9)9.
 01 WS-EXPECTED            PIC X(40).
 01 WS-TELEPORT            PIC X(24).
 01 WS-REMOVE              PIC X(24).
 01 WS-EROW                BINARY-LONG.
 01 WS-EID                 BINARY-LONG.
 01 WS-MOVES               BINARY-LONG.
 01 WS-REMOVES             BINARY-LONG.
 01 WS-DROPS               BINARY-LONG.
 01 WS-RISE-TICK           BINARY-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-TOP-Y               FLOAT-LONG.
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
     PERFORM USE-EYE
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     MOVE 0 TO CL-COUNT
     DISPLAY "STATE reopened setup-done " GQ-SETUP-DONE " cl-count " CL-COUNT " poss-done " SD-POSS-DONE " created " WS-CREATED
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     PERFORM USE-EYE
     STOP RUN.

 USE-EYE.
     ADD 1 TO WS-PHASE
     MOVE CN-PLAYER(WS-ID) TO WS-ROW
     MOVE "minecraft:ender_eye" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EYE-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:eye_of_ender" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-EYE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITEM-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     MOVE WS-EYE-ITEM TO PL-SLOT-ITEM(WS-ROW, WS-SLOT)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, WS-SLOT)
     CALL "CRAFT-REFRESH-ALL"
     CALL "TEST-DRAIN-ENTITIES" USING WS-ID WS-DISCARD
     CALL "TEST-USE-ITEM" USING WS-ID
     CALL "TEST-DRAIN-ENTITIES" USING WS-ID WS-TEXT
     MOVE WS-EYE-TYPE TO WS-TYPE-EDIT
     MOVE SPACES TO WS-EXPECTED
     STRING "," FUNCTION TRIM(WS-TYPE-EDIT) "@" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-EXPECTED)
     PERFORM SHOW-PHASE
     MOVE "acceptance eye real: Use Item with an ender eye in a real world adds one eye_of_ender entity" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance eye real: the survival stack loses one" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the eye's row in the entity table and what it does on the ticks that follow
     MOVE 0 TO WS-EROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-EYE-TYPE AND WS-EROW = 0
             MOVE WS-I TO WS-EROW
         END-IF
     END-PERFORM
     MOVE "acceptance eye real: the eye is in the entity table" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-EROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-ID(WS-EROW) TO WS-EID
     MOVE WS-EID TO WS-ID-EDIT
     MOVE SPACES TO WS-TELEPORT WS-REMOVE
     STRING "128(" FUNCTION TRIM(WS-ID-EDIT) ")" DELIMITED BY SIZE INTO WS-TELEPORT
     STRING "78(" FUNCTION TRIM(WS-ID-EDIT) ")" DELIMITED BY SIZE INTO WS-REMOVE
     COMPUTE WS-Y0 = EN-Y(WS-EROW)
     MOVE 0 TO WS-MOVES WS-REMOVES WS-DROPS WS-RISE-TICK
     MOVE EN-Y(WS-EROW) TO WS-TOP-Y
     PERFORM VARYING WS-TICKS FROM 1 BY 1 UNTIL WS-TICKS > 100
         MOVE 1 TO WS-COUNT
         CALL "TEST-TICKS" USING WS-COUNT
         CALL "TEST-DRAIN-ENTITIES" USING WS-ID WS-TEXT
         MOVE 0 TO WS-COUNT
         INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-TELEPORT)
         ADD WS-COUNT TO WS-MOVES
         MOVE 0 TO WS-COUNT
         INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-REMOVE)
         ADD WS-COUNT TO WS-REMOVES
         MOVE SPACES TO WS-EXPECTED
         MOVE WS-ITEM-TYPE TO WS-TYPE-EDIT
         STRING "," FUNCTION TRIM(WS-TYPE-EDIT) "@" DELIMITED BY SIZE INTO WS-EXPECTED
         MOVE 0 TO WS-COUNT
         INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-EXPECTED)
         ADD WS-COUNT TO WS-DROPS
         IF EN-USED(WS-EROW) = 1 AND EN-ID(WS-EROW) = WS-EID AND EN-Y(WS-EROW) > WS-TOP-Y
             MOVE EN-Y(WS-EROW) TO WS-TOP-Y
         END-IF
     END-PERFORM
     MOVE "acceptance eye real: the eye moves, a Teleport Entity packet on most ticks of its flight" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MOVES >= 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance eye real: it rises above where it was thrown (the throw goes into the air)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TOP-Y > WS-Y0 + 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance eye real: after its flight the eye is removed from the viewers and drops as an item (or breaks)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-REMOVES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SHOW-PHASE.
     DISPLAY "EYE phase " WS-PHASE ": " FUNCTION TRIM(WS-TEXT).
 END PROGRAM TEST-EYE-REAL.

 COPY NOSPAWN.
 COPY CORETEST.
