*> Real-data probe of the feature pool element (docs/protocol/36-structures-3 section 5.5, 36-structures-9 section 8.1; core/src/struct-jig-place.cob JIG-FEATURE; T10502; skipped as a pass without the
*> generated packs): the placed feature of a village trees/decor element runs once at the piece position after the template blocks. On grass an oak at the position puts oak logs up the column; the
*> same position twice gives the same tree (the random is derived from the position, so the passes of the chunks agree); a position under a solid ceiling puts no log; an unknown feature id does nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-JIG-FEATURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600) VALUE SPACES.
 01 WS-STONE               BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-PT                  BINARY-LONG VALUE 60.
 01 WS-PO                  BINARY-LONG VALUE 2.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-LAST                BINARY-LONG VALUE 32768.
 01 WS-LOGS                BINARY-LONG.
 01 WS-LOGS2               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
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
         MOVE "test struct jig feature no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-GRASS
*>   the element row: a feature element of the placed feature oak
     ADD 1 TO JE-COUNT
     MOVE JE-COUNT TO WS-EL
     MOVE 4 TO JE-KIND(WS-EL)
     MOVE "minecraft:oak" TO JE-FEATURE(WS-EL)
     PERFORM FLAT-WORLD
     PERFORM ADD-AND-POST
     PERFORM COUNT-LOGS
     MOVE "acceptance US12 36-3§5.5 an oak feature element on grass grows logs at the piece position" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LOGS >= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-LOGS TO WS-LOGS2
     PERFORM FLAT-WORLD
     PERFORM ADD-AND-POST
     PERFORM COUNT-LOGS
     MOVE "acceptance US12 36-3§5.5 the same position grows the same tree in every pass" TO TL-CASE
     MOVE WS-LOGS2 TO TL-EXPECTED-N
     MOVE WS-LOGS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a ceiling directly above: no room, no log
     PERFORM FLAT-WORLD
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             MOVE 66 TO WS-Y
             CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STONE WS-FLAGS WS-OK
         END-PERFORM
     END-PERFORM
     PERFORM ADD-AND-POST
     PERFORM COUNT-LOGS
     MOVE "acceptance US12 36-3§5.5 a tree with no room under a ceiling places nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LOGS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   an unknown feature id does nothing
     MOVE "minecraft:no_such_feature" TO JE-FEATURE(WS-EL)
     PERFORM FLAT-WORLD
     PERFORM ADD-AND-POST
     PERFORM COUNT-LOGS
     MOVE "acceptance US12 36-3§5.5 an unknown placed feature id does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LOGS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 FLAT-WORLD.
     CALL "SPB-RESET"
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 127 * 256
         MOVE WS-STONE TO CE-STATE(WS-IDX)
     END-PERFORM
     COMPUTE WS-IDX = 127 * 256 + 1
     PERFORM VARYING WS-IDX FROM WS-IDX BY 1 UNTIL WS-IDX > WS-LAST
         MOVE WS-GRASS TO CE-STATE(WS-IDX)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 0 TO SW-X0
     MOVE -63 TO SW-Y0
     MOVE 0 TO SW-Z0
     MOVE 15 TO SW-X1
     MOVE 319 TO SW-Y1
     MOVE 15 TO SW-Z1.
 ADD-AND-POST.
     MOVE 8 TO A-X0 MOVE 64 TO A-Y0 MOVE 8 TO A-Z0 MOVE 8 TO A-X1 MOVE 64 TO A-Y1 MOVE 8 TO A-Z1
     CALL "SPB-ADD" USING WS-PT WS-PO WS-DEP WS-MST WS-BOX WS-ROW
     MOVE WS-EL TO SP-F1(WS-ROW)
     MOVE 8 TO SP-T-X(WS-ROW)
     MOVE 64 TO SP-T-Y(WS-ROW)
     MOVE 8 TO SP-T-Z(WS-ROW)
     CALL "JIG-POST" USING WS-ROW.
 COUNT-LOGS.
     MOVE 0 TO WS-LOGS
     PERFORM VARYING WS-Y FROM 64 BY 1 UNTIL WS-Y > 90
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
             PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 IF WS-BLOCK > 0
                     IF CB-KEY(WS-BLOCK) = "oak_log"
                         ADD 1 TO WS-LOGS
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-STRUCT-JIG-FEATURE.

 COPY NOSPAWN.
 COPY CORETEST.
