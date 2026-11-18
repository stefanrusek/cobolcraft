*> Entity NBT, part 1 rest (docs/protocol/45-entity-nbt-1 sections 1.4, 6 and 7; lane 002-lane-p49m, T31002): a mob that rides a mob is saved inside its vehicle's Passengers list (its Pos the
*> vehicle's, never an entity of its own) and loaded riding it; a UUID that a loaded entity has refuses the entity; a payload of a data version below 5023 is refused.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-1C.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-SNBT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SPIDER              BINARY-LONG.
 01 WS-SKELETON            BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-VERSION             BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE DIM-MAIN TO WS-DIM
*>   A spider carrying a skeleton: both are created, the skeleton rides the spider.
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:spider",Pos:[20.5d,55.0d,37.25d],Passengers:[{id:"minecraft:skeleton",Pos:[20.5d,55.0d,37.25d]}]}'
         DELIMITED BY SIZE INTO WS-SNBT
     MOVE 0 TO WS-VERSION
     PERFORM LOAD
     PERFORM FIND-ROWS
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-1§7.3 the passenger is created and rides its vehicle (both rows linked)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SPIDER > 0 AND WS-SKELETON > 0
         IF EN-PASS(WS-SPIDER) = WS-SKELETON AND EN-MOUNT(WS-SKELETON) = WS-SPIDER
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Saved: one entity of the chunk, the spider, with the skeleton in its Passengers.
     PERFORM SAVE-AND-RENDER
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "},{id:"
     MOVE "acceptance US15 45-1§7.1 a passenger is no entity of the chunk: the list holds the spider only" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Passengers:[{id:minecraft:skeleton,Pos:[20.500,55.000,37.250]"
     MOVE "acceptance US15 45-1§7.1 the skeleton is in the Passengers of the spider with the spider's Pos" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Loaded again from that text without removing the first pair: every UUID is in use, so neither is created.
     PERFORM COUNT-MOBS
     MOVE WS-COUNT TO WS-HITS
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 45-1§6 the same compounds loaded twice leave two mobs (a UUID already in use refuses the entity)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Passengers of passengers load too (a zombie on the skeleton on the spider: three mobs); a rider row that points at a mob that rides nothing ends the chain when saving.
     PERFORM REMOVE-ALL
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:spider",Pos:[20.5d,55.0d,37.25d],Passengers:[{id:"minecraft:skeleton",Pos:[20.5d,55.0d,37.25d],'
         'Passengers:[{id:"minecraft:zombie",Pos:[20.5d,55.0d,37.25d]}]}]}' DELIMITED BY SIZE INTO WS-SNBT
     MOVE 0 TO WS-VERSION
     PERFORM LOAD
     PERFORM COUNT-MOBS
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-1§7.3 the passenger of a passenger is loaded (three mobs)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIND-ROWS
     MOVE 0 TO WS-ZOMBIE
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             CALL "MOB-SPECIES-KEY" USING WS-ROW WS-KEY
             IF WS-KEY = "zombie"
                 MOVE WS-ROW TO WS-ZOMBIE
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO EN-MOUNT(WS-ZOMBIE) EN-MOUNT-ID(WS-ZOMBIE)
     MOVE WS-ZOMBIE TO EN-PASS(WS-SKELETON)
     PERFORM SAVE-AND-RENDER
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Passengers:"
     MOVE "acceptance US15 45-1§7.1 a rider that rides nothing is no passenger: the chain ends at the skeleton" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   One compound with a UUID loaded twice: the second is refused, a UUID is in use once.
     PERFORM REMOVE-ALL
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:spider",Pos:[20.5d,55.0d,37.25d],UUID:[I;1,2,3,4]}' DELIMITED BY SIZE INTO WS-SNBT
     MOVE 0 TO WS-VERSION
     PERFORM LOAD
     PERFORM LOAD
     PERFORM COUNT-MOBS
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-1§6 a compound whose UUID a loaded entity has is refused (one spider after two loads)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A payload of an older data version is refused, one of 5023 and one of a newer version are read.
     PERFORM REMOVE-ALL
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:spider",Pos:[20.5d,55.0d,37.25d]}' DELIMITED BY SIZE INTO WS-SNBT
     MOVE 4000 TO WS-VERSION
     PERFORM LOAD
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 45-1§1.4 DataVersion 4000 is refused: no entity, outcome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTCOME + WS-COUNT * 10
     COMPUTE TL-EXPECTED-N = 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5023 TO WS-VERSION
     PERFORM LOAD
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 45-1§1.4 DataVersion 5023 is read" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTCOME + WS-COUNT * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM REMOVE-ALL
     MOVE 6000 TO WS-VERSION
     PERFORM LOAD
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 45-1§1.4 a newer DataVersion is read as it is" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTCOME + WS-COUNT * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 LOAD.
     CALL "ENT-SNBT-V" USING WS-SNBT WS-VERSION PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME.
 REMOVE-ALL.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-IF
     END-PERFORM.
 COUNT-MOBS.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 FIND-ROWS.
     MOVE 0 TO WS-SPIDER WS-SKELETON
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             CALL "MOB-SPECIES-KEY" USING WS-ROW WS-KEY
             IF WS-KEY = "spider"
                 MOVE WS-ROW TO WS-SPIDER
             END-IF
             IF WS-KEY = "skeleton"
                 MOVE WS-ROW TO WS-SKELETON
             END-IF
         END-IF
     END-PERFORM.
 SAVE-AND-RENDER.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT.
 END PROGRAM TEST-ENTITY-NBT-1C.
 COPY ENTSNBT.
 COPY CORETEST.
