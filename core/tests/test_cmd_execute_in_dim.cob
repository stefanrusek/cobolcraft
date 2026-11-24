*> Implementation test (lane cmdfix): in a standard world with the extra dimensions on, an operator moves players between minecraft:overworld,
*> minecraft:the_nether and minecraft:the_end with `execute in <dimension> run tp ...` through the real command chain (15 section 11, 16 section 5.2):
*> the dimension and position change and the Respawn packet of the dimension change is produced. Needs the generated packs (CC_GENERATED_DIR).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-EXECUTE-IN-DIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-ALICE            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-ROW                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-F1                  PIC -(5)9.9.
 01 WS-F2                  PIC -(5)9.9.
 01 WS-F3                  PIC -(5)9.9.
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
         MOVE "test execute in dim no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE CS-HOSTILE-MOBS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD

     MOVE "test execute in dim the executor in the overworld: execute in minecraft:the_nether run tp @s 0 100 0" TO TL-CASE
     MOVE "execute in minecraft:the_nether run tp @s 0 100 0" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     PERFORM SHOW THRU SHOW-ROW
     MOVE "4 0.5 100.0 0.5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test execute in dim the join of the nether is sent (Respawn first)" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID-OPAL WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:2) TO TL-OBSERVED
     MOVE "84" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ID-OPAL

     MOVE "test execute in dim bare dimension id: execute in the_nether run tp @s 5 90 5 from the overworld" TO TL-CASE
     MOVE "execute in minecraft:overworld run tp @s 1 80 1" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "execute in the_nether run tp @s 5 90 5" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     PERFORM SHOW THRU SHOW-ROW
     MOVE "4 5.5 90.0 5.5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test execute in dim relative coordinates: execute in minecraft:the_end run tp @s ~ ~ ~ keeps the x y z of the source" TO TL-CASE
     MOVE "execute in minecraft:the_end run tp @s ~ ~ ~" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW
     PERFORM SHOW THRU SHOW-ROW
     MOVE "5 5.5 90.0 5.5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test execute in dim the end: execute in minecraft:the_end run tp @s 0 70 0" TO TL-CASE
     MOVE "execute in minecraft:the_end run tp @s 0 70 0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     PERFORM SHOW THRU SHOW-ROW
     MOVE "5 0.5 70.0 0.5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test execute in dim back to the overworld: execute in minecraft:overworld run tp @s 0 100 0" TO TL-CASE
     MOVE "execute in minecraft:overworld run tp @s 0 100 0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     PERFORM SHOW THRU SHOW-ROW
     MOVE "3 0.5 100.0 0.5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test execute in dim as a target: execute as @a in minecraft:the_nether run tp @s 3 90 3 moves every player" TO TL-CASE
     MOVE "execute as @a in minecraft:the_nether run tp @s 3 90 3" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ROW
     PERFORM SHOW-ROW
     MOVE "4 3.5 90.0 3.5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test execute in dim an unknown bare dimension is refused with the typed text" TO TL-CASE
     MOVE "execute in nowhere run tp @s 0 70 0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "argument.dimension.invalid(nowhere)" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 SHOW.
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW.
 SHOW-ROW.
     MOVE PL-DIM(WS-ROW) TO WS-E1
     COMPUTE WS-F1 = PL-X(WS-ROW)
     COMPUTE WS-F2 = PL-Y(WS-ROW)
     COMPUTE WS-F3 = PL-Z(WS-ROW)
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " " FUNCTION TRIM(WS-F3)
         DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CMD-EXECUTE-IN-DIM.

 COPY CORETEST.
 COPY CMDTEST.
