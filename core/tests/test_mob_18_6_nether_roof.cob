*> Implementation test (lane bugcreative; operator report of try15 "mobs are spawning on bedrock", the Nether roof; docs/protocol/18 sections 6.4, 6.8 and 6.9,
*> 44-residual-mob-questions-1 RQ-1.10, 37-nether-1 section 6.9 and 37-nether-6 section 6): a standard world with the extra dimensions on and the placeholder Nether terrain
*> (bedrock floor y 0, bedrock roof y 127, nothing above it). A player stands on the roof (y 129) and then in the cavity below it (y 41), and the natural spawner runs for
*> 400 ticks each time with every new mob recorded (the mobs are taken away as they appear, so the cap does not stop the spawning). Spawn positions follow the surface
*> height + 1 (6.4), so y 128 above the roof is a candidate; the rule that keeps a mob off it is the floor: bedrock sets isValidSpawn to "never" (RQ-1.10). Expected: no mob
*> spawns at y 128 or above, none with a bedrock block below it, and mobs do spawn in the cavity (the control). Needs the generated packs (CC_GENERATED_DIR; a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-NETHER-ROOF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 COPY CBLOCKS.
 COPY PROTO.
 COPY STDMOBS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LOAD                BINARY-LONG VALUE 60.
 01 WS-TICK                BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-ENT                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SEEN.
    05 WS-SEEN-ID          BINARY-LONG OCCURS 4096 TIMES.
 01 WS-TOTAL-ROOF          BINARY-LONG VALUE 0.
 01 WS-TOTAL-CAVITY        BINARY-LONG VALUE 0.
 01 WS-HIGH                BINARY-LONG VALUE 0.
 01 WS-ON-BEDROCK          BINARY-LONG VALUE 0.
 01 WS-N1                  PIC -(5)9.
 01 WS-N2                  PIC -(5)9.
 01 WS-N3                  PIC -(5)9.
 01 WS-FLOOR-KEY           PIC X(48).
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
         MOVE "test mob 18-6 nether roof no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE 1 TO ND-PLACEHOLDER
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 1 TO CS-HOSTILE-MOBS CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE DIM-STANDARD-NETHER TO WS-DEST
     MOVE 10.5 TO WS-X
     MOVE 129 TO WS-Y
     MOVE 10.5 TO WS-Z
     CALL "DIM-SWITCH" USING WS-ROW WS-DEST WS-X WS-Y WS-Z
     CALL "TEST-ACCEPT-TELEPORT" USING WS-CONN
     CALL "TEST-TICKS" USING WS-LOAD
     PERFORM DRAIN
     PERFORM VARYING WS-ENT FROM 1 BY 1 UNTIL WS-ENT > EN-COUNT
         MOVE EN-ID(WS-ENT) TO WS-SEEN-ID(WS-ENT)
     END-PERFORM
     PERFORM VARYING WS-PHASE FROM 1 BY 1 UNTIL WS-PHASE > 2
         IF WS-PHASE = 2
             MOVE 10.5 TO PL-X(WS-ROW)
             MOVE 41 TO PL-Y(WS-ROW)
             MOVE 10.5 TO PL-Z(WS-ROW)
         END-IF
         PERFORM VARYING WS-TICK FROM 1 BY 1 UNTIL WS-TICK > 400
             CALL "TEST-TICKS" USING WS-ONE
             PERFORM RECORD-NEW
             IF FUNCTION MOD(WS-TICK, 20) = 0
                 PERFORM DRAIN
             END-IF
         END-PERFORM
     END-PERFORM

     MOVE "test mob 18-6 nether roof with the player on the roof no mob spawns at y 128 or above (above the bedrock roof)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIGH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob 18-6 nether roof no mob spawns with a bedrock block below it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ON-BEDROCK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob 18-6 nether roof control: mobs do spawn in the Nether cavity below" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TOTAL-CAVITY > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 DRAIN.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     CALL "PB-FREE" USING PB-BUFFER.

*> Every entity row that is new since the last look: its cell and the block below it. The mob is removed once recorded.
 RECORD-NEW.
     PERFORM VARYING WS-ENT FROM 1 BY 1 UNTIL WS-ENT > EN-COUNT
         IF EN-USED(WS-ENT) = 1 AND WS-ENT NOT = PL-ENTITY-ROW(WS-ROW) AND EN-ID(WS-ENT) NOT = WS-SEEN-ID(WS-ENT)
             MOVE EN-ID(WS-ENT) TO WS-SEEN-ID(WS-ENT)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ENT) WS-S
             IF WS-S > 0
                 PERFORM RECORD-ONE
             END-IF
         END-IF
     END-PERFORM.

 RECORD-ONE.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-ENT))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-ENT))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-ENT))
     COMPUTE WS-DOWN = WS-BY - 1
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-BX WS-DOWN WS-BZ WS-STATE
     MOVE SPACES TO WS-FLOOR-KEY
     IF WS-STATE NOT = 0
         COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE CB-KEY(WS-BLOCK) TO WS-FLOOR-KEY
     END-IF
     MOVE WS-BX TO WS-N1
     MOVE WS-BY TO WS-N2
     MOVE WS-BZ TO WS-N3
     DISPLAY "SPAWN phase " WS-PHASE " " FUNCTION TRIM(SM-KEY(WS-S)) " cell " WS-N1 WS-N2 WS-N3 " floor " FUNCTION TRIM(WS-FLOOR-KEY)
     IF WS-BY >= 128
         ADD 1 TO WS-HIGH
     END-IF
     IF WS-FLOOR-KEY = "bedrock"
         ADD 1 TO WS-ON-BEDROCK
     END-IF
     IF WS-PHASE = 1
         ADD 1 TO WS-TOTAL-ROOF
     ELSE
         ADD 1 TO WS-TOTAL-CAVITY
     END-IF
     CALL "ENTITY-REMOVE" USING WS-ENT.
 END PROGRAM TEST-MOB-18-6-NETHER-ROOF.
 COPY CORETEST.
