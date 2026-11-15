*> Implementation test (002-lane-mobsfull-h22; docs/protocol/18 section 6.12, 31-7 section 3, 44-2 section 2): the mob spawner block entity ticks (BE-TICK-ALL ->
*> BE-SPAWNER-TICK): defaults at creation, nothing without a living non-spectator player within RequiredPlayerRange or with spawner_blocks_work false, the delay
*> counts down, an empty spawn data only rolls a delay, a set species spawns up to MaxNearbyEntities, and the saved keys (Delay ... SpawnData) read back.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-SPAWNER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY CONTENT.
 01 WS-CASE                PIC X(120).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 60.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112).
 01 WS-STATE               BINARY-LONG.
 01 WS-COWS                BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SAVED-X             FLOAT-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "spawner_blocks_work".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FORM                BINARY-LONG.
 01 WS-BKEY                PIC X(48).
 01 WS-BLEN                BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-TEXT                PIC X(24).
 01 WS-TLEN                BINARY-LONG.
 01 WS-BE3                 BINARY-LONG.
 01 WS-SET-ID             PIC X(64).
 01 WS-SET-LEN            BINARY-LONG.
 01 WS-BTYPE               BINARY-LONG VALUE 9.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 30
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 30
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-SZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3
     MOVE "minecraft:spawner" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-FY WS-SZ WS-STATE
     CALL "BE-FIND" USING WS-DIM WS-SX WS-FY WS-SZ WS-BE
     MOVE "implementation 31-7 3: a placed spawner has the entity with the defaults" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-BE > 0 AND BE-XI(WS-BE, 1) = 20 AND BE-XI(WS-BE, 2) = 200 AND BE-XI(WS-BE, 3) = 800 AND BE-XI(WS-BE, 4) = 4
             AND BE-XI(WS-BE, 5) = 6 AND BE-XI(WS-BE, 6) = 16 AND BE-XI(WS-BE, 7) = 4 AND BE-XI(WS-BE, 8) = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE PL-X(WS-PLAYER) TO WS-SAVED-X
     COMPUTE PL-X(WS-PLAYER) = WS-SAVED-X + 100
     CALL "BE-TICK-ALL"
     MOVE "implementation 18§6.12: no player within 16 blocks: the delay stays" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
     MOVE WS-SAVED-X TO PL-X(WS-PLAYER)
     MOVE 3 TO PL-MODE(WS-PLAYER)
     CALL "BE-TICK-ALL"
     MOVE "implementation 18§6.12: a spectator does not count" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "BE-TICK-ALL"
     MOVE "implementation 18§6.12: spawner_blocks_work false stops it" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "BE-TICK-ALL"
     MOVE "implementation 18§6.12: a player in range counts the delay down" TO WS-CASE
     MOVE 19 TO WS-E
     MOVE BE-XI(WS-BE, 1) TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         CALL "BE-TICK-ALL"
     END-PERFORM
     MOVE "implementation 18§6.12: at 0 with no spawn data a delay of 200 to 799 is rolled" TO WS-CASE
     CALL "BE-TICK-ALL"
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XI(WS-BE, 1) >= 200 AND BE-XI(WS-BE, 1) <= 799
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE SPACES TO WS-SET-ID
     MOVE "minecraft:cow" TO WS-SET-ID
     MOVE 13 TO WS-SET-LEN
     CALL "BE7-SET-ENTITY-ID" USING WS-BE WS-SET-ID WS-SET-LEN
     MOVE 0 TO BE-XI(WS-BE, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6000
         CALL "BE-TICK-ALL"
     END-PERFORM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO WS-COWS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-COW-TYPE
             ADD 1 TO WS-COWS
         END-IF
     END-PERFORM
     MOVE "implementation 18§6.12: a cow spawner fills up to MaxNearbyEntities (6) and no more" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-COWS TO WS-O
     PERFORM CHECK-N
     MOVE 33 TO BE-XI(WS-BE, 1)
     MOVE 250 TO BE-XI(WS-BE, 2)
     MOVE 1000 TO BE-XI(WS-BE, 3)
     MOVE 7 TO BE-XI(WS-BE, 4)
     MOVE 9 TO BE-XI(WS-BE, 5)
     MOVE 20 TO BE-XI(WS-BE, 6)
     MOVE 5 TO BE-XI(WS-BE, 7)
     MOVE "minecraft:spawner" TO WS-BKEY
     MOVE 17 TO WS-BLEN
     ADD 5 TO WS-SX
     CALL "BE-CREATE" USING WS-DIM WS-SX WS-FY WS-SZ WS-BTYPE WS-BKEY WS-BLEN WS-BE2
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 2 TO WS-FORM
     CALL "BE-SAVE" USING WS-BE WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-BE2 PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "implementation 31-7 3.1: the saved keys read back (Delay, delays, counts, ranges, SpawnData entity id)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XI(WS-BE2, 1) = 33 AND BE-XI(WS-BE2, 2) = 250 AND BE-XI(WS-BE2, 3) = 1000 AND BE-XI(WS-BE2, 4) = 7
             AND BE-XI(WS-BE2, 5) = 9 AND BE-XI(WS-BE2, 6) = 20 AND BE-XI(WS-BE2, 7) = 5 AND BE-XT(WS-BE2, 1) = "minecraft:cow"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO BE-XI(WS-BE2, 1)
     MOVE SPACES TO WS-SET-ID
     MOVE "minecraft:cow" TO WS-SET-ID
     MOVE 13 TO WS-SET-LEN
     CALL "BE7-SET-ENTITY-ID" USING WS-BE2 WS-SET-ID WS-SET-LEN
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Foo" TO WN MOVE 3 TO WL MOVE 1 TO WS-V
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-V
     MOVE "Delay" TO WN MOVE 5 TO WL MOVE 9 TO WS-V
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-V
     MOVE "SpawnData" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "entity" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Foo" TO WN MOVE 3 TO WL MOVE 1 TO WS-V
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-V
     MOVE "id" TO WN MOVE 2 TO WL MOVE "minecraft:pig" TO WS-TEXT MOVE 13 TO WS-TLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TLEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "custom_spawn_rules" TO WN MOVE 18 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "Delay" TO WN MOVE 5 TO WL MOVE 77 TO WS-V
     CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL WS-V
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-BE2 PB-BUFFER
     MOVE "implementation 31-7 3.1: other keys and a wrong tag type are skipped, SpawnData.entity.id is read" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XI(WS-BE2, 1) = 77 AND BE-XT(WS-BE2, 1) = "minecraft:pig"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "SpawnData" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "entity" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN MOVE 2 TO WL MOVE "other:thing" TO WS-TEXT MOVE 11 TO WS-TLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TLEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-BE2 PB-BUFFER
     MOVE "implementation 31-7 3.1: an id of another namespace is kept as the data holds it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF BE-XI(WS-BE2, 8) = 1 AND BE-XT(WS-BE2, 1) = "other:thing"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     ADD 5 TO WS-SX
     CALL "BE-CREATE" USING WS-DIM WS-SX WS-FY WS-SZ WS-BTYPE WS-BKEY WS-BLEN WS-BE3
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-BE3 WS-FORM PB-BUFFER
     MOVE "implementation 31-7 3.1: a spawner without a species saves the keys of 31-7 3.1 (177 bytes, the full set)" TO WS-CASE
     MOVE 177 TO WS-E
     MOVE PB-LENGTH TO WS-O
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
     MOVE -1 TO BE-XI(WS-BE3, 6)
     MOVE 5 TO BE-XI(WS-BE3, 1)
     COMPUTE PL-X(WS-PLAYER) = WS-SAVED-X + 500
     CALL "BE-TICK-ALL"
     MOVE "implementation 18§6.12: a negative RequiredPlayerRange accepts any living player" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE BE-XI(WS-BE3, 1) TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-SPAWNER.
 COPY CORETEST.
 COPY MOBSPTEST.
