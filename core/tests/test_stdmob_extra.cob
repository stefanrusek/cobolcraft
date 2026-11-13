*> Implementation test (002-lane-mobs): the edges of the standard mobs of core/src/stdmobs.cob: panic away from the attacker, a mob in
*> an unloaded chunk, the spawn rule's refusals (blocked space, dark cell, creature cap, unloaded column), a pack of four, the spawn
*> cycle and its attempts around a player, the light read on both nibbles, and the table in a cobolcraft world.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-EXTRA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-GRASS-STATE         BINARY-LONG.
 01 WS-STONE-STATE         BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-FAR                 FLOAT-LONG VALUE 100000.
 01 WS-FAR-Z               FLOAT-LONG VALUE 100000.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-R                   BINARY-DOUBLE VALUE 0.
 01 WS-PACK                BINARY-DOUBLE VALUE 3.
 01 WS-AMOUNT              BINARY-LONG VALUE 3.
 01 WS-CAUSE               BINARY-LONG VALUE 1.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-FARX                BINARY-LONG VALUE 100000.
 01 WS-X0                  FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NEW-CX              BINARY-LONG.
 01 WS-LIT-BEFORE          BINARY-LONG.
 01 WS-ANIMALS             BINARY-LONG VALUE 1.
 01 WS-HASH-COUNT          BINARY-LONG.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-ROW
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z

*>   Panic: a pig hit by the player, 3 blocks east of it, runs east (away) and its panic ticks count down.
     COMPUTE WS-X0 = WS-X + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-PIG
     CALL "HEALTH-MOB-DAMAGE" USING WS-PIG WS-AMOUNT WS-CAUSE WS-PLAYER
     CALL "MOB-STEP" USING WS-PIG
     CALL "MOB-STEP" USING WS-PIG
     MOVE "N" TO TL-MODE
     MOVE "test stdmob extra: two ticks of panic leave 38 panic ticks" TO TL-CASE
     MOVE 38 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob extra: the hurt window counts down in a mob tick" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 18
     MOVE EN-HURT(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob extra: a panicking pig moves away from the attacker" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF EN-X(WS-PIG) > WS-X0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A mob whose chunk is not loaded does nothing.
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-FAR WS-Y WS-FAR-Z WS-YAW WS-PIG
     CALL "MOB-STEP" USING WS-PIG
     MOVE "test stdmob extra: a pig in an unloaded chunk stays" TO TL-CASE
     MOVE "no" TO TL-OBSERVED
     IF EN-X(WS-PIG) = WS-FAR AND EN-COOLDOWN(WS-PIG) = 0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Ready: the player's chunk is generated and lit, a far chunk is not in the cache.
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z / 16)
     CALL "STDMOB-READY" USING WS-DIM WS-BX WS-BZ WS-INDEX
     MOVE "test stdmob extra: the player's chunk is ready for mobs" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-READY" USING WS-DIM WS-FARX WS-FARX WS-INDEX
     MOVE "test stdmob extra: a chunk that is not loaded is not ready" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A chunk that is in the cache but not lit yet (just installed) is ready after STDMOB-READY lit it: its light is needed by the dark and
*>   daylight rules.
     MOVE 60 TO WS-NEW-CX
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-NEW-CX WS-NEW-CX WS-ROW
     MOVE CK-LIT(WS-ROW) TO WS-LIT-BEFORE
     CALL "STDMOB-READY" USING WS-DIM WS-NEW-CX WS-NEW-CX WS-INDEX
     MOVE "test stdmob extra: a loaded chunk that was not lit is ready" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob extra: and it has been lit on demand" TO TL-CASE
     MOVE CK-LIT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Light: an unloaded cell is 0; a loaded sky cell reads on both nibbles (cells x and x + 1).
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) + 40
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "STDMOB-BRIGHT" USING WS-DIM WS-FARX WS-BY WS-BZ WS-LIGHT
     MOVE "test stdmob extra: the light of an unloaded cell is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LIGHT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob extra: the sky light high above the terrain is 15 on both nibbles" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     CALL "STDMOB-BRIGHT" USING WS-DIM WS-BX WS-BY WS-BZ WS-LIGHT
     MOVE WS-LIGHT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 1 TO WS-BX
     CALL "STDMOB-BRIGHT" USING WS-DIM WS-BX WS-BY WS-BZ WS-LIGHT
     MOVE WS-LIGHT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SUBTRACT 1 FROM WS-BX

*>   The spawn rule: a grass column high above the terrain; refusals leave the entity count alone.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-GRASS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STONE-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-TOP = WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-TOP WS-BZ WS-GRASS-STATE

*>   A block in the first cell above refuses, then in the second.
     COMPUTE WS-BY = WS-TOP + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE-STATE
     PERFORM COUNT-ALL
     MOVE WS-COUNT TO WS-BEFORE
     CALL "STDMOB-SPAWN-RULE" USING WS-DIM WS-BX WS-BZ WS-TOP WS-R
     PERFORM COUNT-ALL
     MOVE "test stdmob extra: no spawn with a block in the cell above the ground" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-TOP + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE-STATE
     CALL "STDMOB-SPAWN-RULE" USING WS-DIM WS-BX WS-BZ WS-TOP WS-R
     PERFORM COUNT-ALL
     MOVE "test stdmob extra: no spawn with a block two cells above the ground" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR

*>   An unloaded column refuses.
     CALL "STDMOB-SPAWN-RULE" USING WS-DIM WS-FARX WS-BZ WS-TOP WS-R
     PERFORM COUNT-ALL
     MOVE "test stdmob extra: no spawn in an unloaded column" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A dark cell (deep in the terrain) refuses.
     COMPUTE WS-TOP = FUNCTION INTEGER(WS-Y) - 20
     COMPUTE WS-BY = WS-TOP
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-GRASS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-BY = WS-TOP + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     END-PERFORM
     CALL "STDMOB-SPAWN-RULE" USING WS-DIM WS-BX WS-BZ WS-TOP WS-R
     PERFORM COUNT-ALL
     MOVE "test stdmob extra: no spawn in a dark cell" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A pack of four (r = 3): the first member stands on the lit grass, the others at the cursor.
     COMPUTE WS-TOP = FUNCTION INTEGER(WS-Y) + 40
     PERFORM COUNT-ALL
     MOVE WS-COUNT TO WS-BEFORE
     CALL "STDMOB-SPAWN-RULE" USING WS-DIM WS-BX WS-BZ WS-TOP WS-PACK
     PERFORM COUNT-ALL
     MOVE "test stdmob extra: a pack makes 1 to 4 mobs" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF WS-COUNT > WS-BEFORE AND WS-COUNT <= WS-BEFORE + 4
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The creature cap: with 10 standard mobs around, the rule refuses.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     END-PERFORM
     PERFORM COUNT-ALL
     MOVE WS-COUNT TO WS-BEFORE
     CALL "STDMOB-SPAWN-RULE" USING WS-DIM WS-BX WS-BZ WS-TOP WS-R
     PERFORM COUNT-ALL
     MOVE "test stdmob extra: no spawn at the creature cap" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Attempts around the player: many times, none crashes, and the cycle runs on ticks of 400 only.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE WS-I TO CW-TIME
         CALL "STDMOB-SPAWN-TRY" USING WS-DIM WS-PLAYER WS-ANIMALS
     END-PERFORM
*>   An attempt whose column has ground: the same hash as STDMOB-SPAWN-TRY picks the column of the first time that is far enough,
*>   which gets a stone floor at y = 5; the attempt reaches the rule and the stone is no ground for an animal.
     MOVE 0 TO WS-I
     MOVE 0 TO WS-FOUND
     PERFORM UNTIL WS-FOUND = 1
         ADD 1 TO WS-I
         COMPUTE WS-ARG(1) = WS-DIM - 1
         COMPUTE WS-ARG(2) = FUNCTION INTEGER(PL-X(WS-PLAYER))
         COMPUTE WS-ARG(3) = FUNCTION INTEGER(PL-Z(WS-PLAYER))
         MOVE WS-I TO WS-ARG(4)
         MOVE 4 TO WS-HASH-COUNT
         CALL "RNG-HASH" USING WS-HASH-COUNT WS-ARGS WS-H
         COMPUTE WS-BX = FUNCTION MOD(WS-H, 81) - 40
         COMPUTE WS-Q = WS-H / 81
         COMPUTE WS-BZ = FUNCTION MOD(WS-Q, 81) - 40
         IF WS-BX * WS-BX + WS-BZ * WS-BZ > 576
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     COMPUTE WS-BX = WS-BX + WS-ARG(2)
     COMPUTE WS-BZ = WS-BZ + WS-ARG(3)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX 5 WS-BZ WS-STONE-STATE
     PERFORM COUNT-ALL
     MOVE WS-COUNT TO WS-BEFORE
     MOVE WS-I TO CW-TIME
     CALL "STDMOB-SPAWN-TRY" USING WS-DIM WS-PLAYER WS-ANIMALS
     PERFORM COUNT-ALL
     MOVE "test stdmob extra: an attempt on a stone floor spawns nothing" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A player in an unloaded part of the dimension: the attempt ends at the unloaded column.
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE WS-FAR TO PL-X(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         MOVE WS-I TO CW-TIME
         CALL "STDMOB-SPAWN-TRY" USING WS-DIM WS-PLAYER WS-ANIMALS
     END-PERFORM
     MOVE WS-X0 TO PL-X(WS-PLAYER)
     MOVE 401 TO CW-TIME
     CALL "STDMOB-SPAWN-TICK"
     MOVE 800 TO CW-TIME
     CALL "STDMOB-SPAWN-TICK"
     MOVE "test stdmob extra: the spawn cycle ran without leaving the world" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ok" TO TL-EXPECTED
     MOVE "ok" TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The table in a cobolcraft world: no row, no spawn cycle of this table.
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "STDMOB-SPAWN-TICK"
     CALL "STDMOB-INDEX" USING WS-PIG-TYPE WS-INDEX
     MOVE "test stdmob extra: STDMOB-INDEX in a cobolcraft world is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 COUNT-ALL.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > EN-COUNT
         IF EN-USED(WS-INDEX) = 1
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-STDMOB-EXTRA.
 COPY CORETEST.
