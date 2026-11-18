*> MEASUREMENT (lane buglocate2): prints the CPU seconds (C clock(), user + system of the process) of the real command `locate structure <id>` from a spot, and of the cell filter alone
*> (STRUCT-POTENTIAL + STRUCT-IS-CHUNK over the 201 x 201 cells around the spot, the cells that pass counted). Wants and spots come from the environment so a run can be one
*> measurement: CC_COST_SEED, CC_COST_X, CC_COST_Z (block position of the spot), CC_COST_WANT (an id, `#tag` for a tag). Skipped as a pass without the generated packs or without CC_COST_WANT.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LOCATE-COST.
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
 01 WS-WANT                PIC X(120).
 01 WS-SEED-TEXT           PIC X(40).
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-ROW                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-SECONDS             PIC -(6)9.999.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-WANTED              BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EYE-NAME            PIC X(40) VALUE "strongholds".
 01 WS-OY                  BINARY-LONG VALUE 64.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CHX                 BINARY-LONG.
 01 WS-CHZ                 BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-WANT
     ACCEPT WS-WANT FROM ENVIRONMENT "CC_COST_WANT"
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0 OR WS-WANT = SPACES
         MOVE "measurement /locate cost: no generated packs or no CC_COST_WANT, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-SEED-TEXT
     ACCEPT WS-SEED-TEXT FROM ENVIRONMENT "CC_COST_SEED"
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE WS-SEED-TEXT TO CS-SEED-TEXT
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW
     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-SZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_COST_X"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-SX = FUNCTION NUMVAL(WS-ENV)
         MOVE SPACES TO WS-ENV
         ACCEPT WS-ENV FROM ENVIRONMENT "CC_COST_Z"
         COMPUTE WS-SZ = FUNCTION NUMVAL(WS-ENV)
         COMPUTE PL-X(WS-ROW) = WS-SX + 0.5
         COMPUTE PL-Z(WS-ROW) = WS-SZ + 0.5
     END-IF
*>   the eye of ender's search (thrown-44g.cob: STRUCT-NEAREST-NAMED "strongholds" from the thrower's block position)
     IF WS-WANT = "eye"
         CALL "COST-CLOCK" USING WS-T0
         CALL "STRUCT-NEAREST-NAMED" USING WS-EYE-NAME CW-SEED WS-SX WS-OY WS-SZ WS-FOUND WS-CHX WS-CHZ WS-LX WS-LY WS-LZ
         CALL "COST-CLOCK" USING WS-T1
         COMPUTE WS-SECONDS = (WS-T1 - WS-T0) / 1000000
         DISPLAY "COST eye from " WS-SX "," WS-SZ " cpu=" WS-SECONDS " found=" WS-FOUND " at " WS-LX "," WS-LZ
         MOVE "measurement /locate cost: ran" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
*>   the cell filter alone, for the sets that hold the wanted structure
     IF WS-WANT(1:1) = "#"
         MOVE 2 TO WS-KIND
         MOVE WS-WANT(2:119) TO WS-ID
     ELSE
         MOVE 1 TO WS-KIND
         MOVE WS-WANT TO WS-ID
     END-IF
     COMPUTE WS-OX = FUNCTION INTEGER(WS-SX / 16)
     COMPUTE WS-OZ = FUNCTION INTEGER(WS-SZ / 16)
     CALL "COST-CLOCK" USING WS-T0
     MOVE 0 TO WS-CELLS WS-PASS
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         MOVE 0 TO WS-N
         IF SS-KIND(WS-S) = 2
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
                 MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-K) TO WS-ST
                 CALL "CXC-STRUCT-WANT" USING WS-KIND WS-ID WS-ST WS-WANTED
                 IF WS-WANTED = 1
                     MOVE 1 TO WS-N
                 END-IF
             END-PERFORM
         END-IF
         IF WS-N = 1
             PERFORM VARYING WS-IX FROM -100 BY 1 UNTIL WS-IX > 100
                 PERFORM VARYING WS-IZ FROM -100 BY 1 UNTIL WS-IZ > 100
                     COMPUTE WS-CX = WS-OX + SS-SPACING(WS-S) * WS-IX
                     COMPUTE WS-CZ = WS-OZ + SS-SPACING(WS-S) * WS-IZ
                     CALL "STRUCT-POTENTIAL" USING WS-S CW-SEED WS-CX WS-CZ WS-PX WS-PZ
                     CALL "STRUCT-IS-CHUNK" USING WS-S CW-SEED WS-PX WS-PZ WS-FLAG
                     ADD 1 TO WS-CELLS
                     ADD WS-FLAG TO WS-PASS
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     CALL "COST-CLOCK" USING WS-T1
     COMPUTE WS-SECONDS = (WS-T1 - WS-T0) / 1000000
     DISPLAY "COST filter " FUNCTION TRIM(WS-WANT) " cells=" WS-CELLS " pass=" WS-PASS " cpu=" WS-SECONDS
     MOVE SPACES TO WS-LINE
     IF WS-KIND = 2
         STRING "locate structure #" FUNCTION TRIM(WS-ID) DELIMITED BY SIZE INTO WS-LINE
     ELSE
         STRING "locate structure " FUNCTION TRIM(WS-ID) DELIMITED BY SIZE INTO WS-LINE
     END-IF
     CALL "COST-CLOCK" USING WS-T0
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "COST-CLOCK" USING WS-T1
     COMPUTE WS-SECONDS = (WS-T1 - WS-T0) / 1000000
     DISPLAY "COST command " FUNCTION TRIM(WS-WANT) " from " WS-SX "," WS-SZ " cpu=" WS-SECONDS " reply=" FUNCTION TRIM(WS-TEXT(1:120))
     MOVE "measurement /locate cost: ran" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CMD-LOCATE-COST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. COST-CLOCK.
*> USING microseconds out: the CPU time of the process (C clock(), CLOCKS_PER_SEC is 1000000 on this platform).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-US                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-US.
     CALL STATIC "clock" RETURNING L-US
     GOBACK.
 END PROGRAM COST-CLOCK.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY CMDTEST.
