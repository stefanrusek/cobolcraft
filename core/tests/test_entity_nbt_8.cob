*> Entity NBT, part 8 (docs/protocol/45-entity-nbt-8-vehicles-projectiles-items.md sections 2.1, 3.1, 3.3 and 3.4; lane 002-lane-p49k, T24560): the ground item writes Health, Age and
*> PickupDelay as Shorts before its Item; a falling block writes its BlockState (Name and Properties), Time, DropItem, HurtEntities, FallHurtAmount, FallHurtMax and CancelDrop; a primed
*> TNT writes fuse and block_state; reading each back restores it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 COPY CONTENT.
 COPY PROTO.
 COPY BRWORLD.
 COPY CBLOCKS.
 COPY VILSTATE.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WANT-KEY            PIC X(24).
 01 WS-WANT-TYPE           BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 90.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-HEAD                PIC X(8192).
 01 WS-TAIL                PIC X(8192).
 01 WS-A                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG VALUE 7.
 01 WS-DELAY               BINARY-LONG VALUE 25.
 01 WS-FUSE                BINARY-LONG VALUE 55.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-ANVIL-KEY           PIC X(112) VALUE "minecraft:anvil".
 01 WS-FACING              PIC X(24) VALUE "facing".
 01 WS-WEST                PIC X(32) VALUE "west".
 01 WS-RESULT              BINARY-LONG.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-MOB                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OWNER               PIC X(16) VALUE X"00000001000000020000000300000004".
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 6000 TO CW-TIME
     MOVE 2 TO WS-CZ
     MOVE 55 TO WS-Y
     MOVE 37.25 TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = "honeycomb" AND WS-ITEM = 0
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM

*>   a ground item (chunk 1): 7 of an item, 25 ticks of pickup delay, age 1200
     MOVE 1 TO WS-CX
     MOVE 20.5 TO WS-X
     MOVE 1200 TO WS-AGE
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-MOB
     MOVE WS-AGE TO EN-AGE(WS-MOB)
     MOVE EN-TYPE(WS-MOB) TO WS-TYPE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-8 ground item: Health 5, Age 1200, PickupDelay 25 as Shorts before Item" TO TL-CASE
     MOVE "Health:5,Age:1200,PickupDelay:25,Item:{id:minecraft:honeycomb,count:7}" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-8 ground item read back: age 1200 and a pickup delay of 25 ticks" TO TL-CASE
     MOVE 1200025 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-AGE(WS-MOB) * 1000 + EN-DELAY(WS-MOB)
     PERFORM CHECK-NUM

*>   a falling anvil facing west (chunk 2), 12 ticks old
     MOVE 2 TO WS-CX
     MOVE "falling_block" TO WS-WANT-KEY PERFORM SPAWN-ONE
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-ANVIL-KEY WS-BLOCK-ID WS-BLOCK-ROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BLOCK-ID + 1) TO WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-FACING WS-WEST WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     MOVE WS-STATE TO EN-FB-STATE(WS-MOB)
     MOVE 12 TO EN-FB-TIME(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-8 falling block: BlockState with Properties, Time, DropItem, HurtEntities 1 for an anvil, FallHurtAmount, FallHurtMax, CancelDrop" TO TL-CASE
     MOVE "BlockState:{Name:minecraft:anvil,Properties:{facing:west}},Time:12,DropItem:1,HurtEntities:1,FallHurtAmount:0.000,FallHurtMax:40,CancelDrop:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE EN-FB-STATE(WS-MOB) TO WS-STATE
     PERFORM RELOAD
     MOVE "acceptance US15 45-8 falling block read back: the same state and 12 ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-STATE * 100 + 12
     COMPUTE TL-OBSERVED-N = EN-FB-STATE(WS-MOB) * 100 + EN-FB-TIME(WS-MOB)
     PERFORM CHECK-NUM

*>   a primed TNT with 55 ticks of fuse (chunk 3)
     MOVE 3 TO WS-CX
     MOVE 52.5 TO WS-X
     CALL "TNT-PRIME-FUSE" USING WS-DIM WS-X WS-Y WS-Z WS-FUSE WS-MOB
     MOVE EN-TYPE(WS-MOB) TO WS-TYPE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-8 tnt: fuse 55 and block_state minecraft:tnt with its Properties" TO TL-CASE
     MOVE "fuse:55,block_state:{Name:minecraft:tnt,Properties:{unstable:false}}" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE "acceptance US15 45-8 tnt: an Entity only, so no Health and no LivingEntity keys" TO TL-CASE
     MOVE "Health:" TO TL-EXPECTED
     PERFORM CHECK-LACKS
     PERFORM RELOAD
     MOVE "acceptance US15 45-8 tnt read back: fuse 55" TO TL-CASE
     MOVE 55 TO TL-EXPECTED-N
     MOVE EN-SWELL(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     STOP RUN.
 SPAWN-ONE.
     COMPUTE WS-X = 16 * WS-CX + 4.5
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE WS-WANT-TYPE TO WS-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB.
 WRITE-CHUNK.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT.
 CHECK-HAS.
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-FOUND
     MOVE FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED)) TO WS-A
     PERFORM VARYING WS-FOUND FROM 1 BY 1 UNTIL WS-FOUND > 8000 - WS-A
         IF WS-TEXT(WS-FOUND:WS-A) = TL-EXPECTED(1:WS-A)
             EXIT PERFORM
         END-IF
     END-PERFORM
     IF WS-FOUND > 8000 - WS-A
         MOVE WS-TEXT(1:1500) TO TL-OBSERVED
     ELSE
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 RELOAD.
     MOVE 0 TO PB-POS
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-MOB
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-TYPE(WS-ROW) = WS-TYPE
             MOVE WS-ROW TO WS-MOB
         END-IF
     END-PERFORM.
 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CHECK-LACKS.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED)) TO WS-A
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8000 - WS-A
         IF WS-TEXT(WS-I:WS-A) = TL-EXPECTED(1:WS-A)
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 1
         MOVE "present" TO TL-OBSERVED
     ELSE
         MOVE "absent" TO TL-OBSERVED
     END-IF
     MOVE "absent" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-NBT-8.
 COPY CORETEST.
