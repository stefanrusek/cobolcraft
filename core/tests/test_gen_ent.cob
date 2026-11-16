*> Implementation test of the worldgen entity channel (GENENT.cpy, core/src/gen-ent.cob): requests are appended bounded (16, the rest counted), a mob of code gets its compound, the job keeps
*> them bounded, and applying them makes the mobs once on the main thread: a persistent witch, a villager that keeps the profession and level of its VillagerData and is not persistent, no
*> second mob where one already stands, none when the entity table is nearly full; the persistence flag is written and read with the entity storage and keeps a mob from despawning.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-ENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY GENENT.
 COPY VILSTATE.
 COPY BRWORLD.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG VALUE 7.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 90.
 01 WS-ID                  PIC X(32).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-NBT                 PIC X(1344).
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WITCH-TYPE          BINARY-LONG.
 01 WS-VILLAGER-TYPE       BINARY-LONG.
 01 WS-WITCH               BINARY-LONG.
 01 WS-VILLAGER            BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-COUNTED             BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FLAG-A              BINARY-LONG.
 01 WS-FLAG-B              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:witch" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WITCH-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VILLAGER-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO GEL-COUNT GEL-LOST J-ENT-COUNT J-ENT-LOST GE-COUNT GE-LOST

*>   the level's list is bounded
     MOVE "minecraft:witch" TO WS-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE WS-I TO WS-X
         MOVE 64 TO WS-Y
         MOVE 5 TO WS-Z
         CALL "GENT-ADD-MOB" USING WS-X WS-Y WS-Z WS-ID WS-ONE
     END-PERFORM
     MOVE "test gen ent: 18 requests: 16 kept and 2 counted as lost" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GEL-COUNT * 100 + GEL-LOST
     MOVE 1602 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen ent: a request keeps its position and the compound of the mob (46 bytes for minecraft:witch)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GEL-X(7) * 1000 + GEL-LEN(7)
     MOVE 7046 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "test gen ent: the compound starts with the String id and ends with PersistenceRequired 1 and the End tag" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     IF GEL-NBT(7)(1:5) = X"080002" & "id" AND GEL-NBT(7)(8:15) = "minecraft:witch" AND GEL-NBT(7)(23:3) = X"010013"
             AND GEL-NBT(7)(45:2) = X"0100"
         MOVE "ok" TO TL-OBSERVED
     END-IF
     MOVE "ok" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   a bare key gets the namespace; a request over the compound limit is lost
     MOVE "cat" TO WS-ID
     MOVE 0 TO GEL-COUNT GEL-LOST
     CALL "GENT-ADD-MOB" USING WS-X WS-Y WS-Z WS-ID WS-ZERO
     MOVE "test gen ent: a bare key is given the namespace (minecraft:cat is 13 characters: 44 bytes)" TO TL-CASE
     MOVE GEL-LEN(1) TO TL-OBSERVED-N
     MOVE 44 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1345 TO WS-LEN
     CALL "GENT-ADD" USING WS-X WS-Y WS-Z WS-YAW WS-LEN WS-NBT
     MOVE ZERO TO WS-LEN
     CALL "GENT-ADD" USING WS-X WS-Y WS-Z WS-YAW WS-LEN WS-NBT
     MOVE "test gen ent: a compound over 1344 bytes and an empty one are counted as lost, not kept" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GEL-COUNT * 10 + GEL-LOST
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the job's list is bounded too
     MOVE 15 TO J-ENT-COUNT
     MOVE 0 TO J-ENT-LOST
     CALL "GENT-KEEP" USING WS-JOB
     MOVE "test gen ent: kept into a job with room for one: 16 in the job, 2 lost and the level's list is empty" TO TL-CASE
     COMPUTE TL-OBSERVED-N = J-ENT-COUNT * 1000 + J-ENT-LOST * 100 + GEL-COUNT + GEL-LOST
     MOVE 16200 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   application: a witch (persistent) and a villager with VillagerData
     MOVE 0 TO GEL-COUNT GEL-LOST GE-COUNT GE-LOST
     MOVE 1 TO WS-I
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 6.5
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 0.5
     MOVE "witch" TO WS-ID
     CALL "GENT-ADD-MOB" USING WS-X WS-Y WS-Z WS-ID WS-ONE
     MOVE SPACES TO WS-NBT
     MOVE 1 TO WS-POINTER
     STRING X"080002" "id" X"0012" "minecraft:villager" X"010013" "PersistenceRequired" X"00"
         X"0A000C" "VillagerData" X"08000A" "profession" X"0010" "minecraft:nitwit" X"030005" "level" X"00000002" X"00" X"00"
         DELIMITED BY SIZE INTO WS-NBT WITH POINTER WS-POINTER
     COMPUTE WS-LEN = WS-POINTER - 1
     COMPUTE WS-X = WS-X + 2
     CALL "GENT-ADD" USING WS-X WS-Y WS-Z WS-YAW WS-LEN WS-NBT
     MOVE GEL-COUNT TO J-ENT-COUNT
     MOVE GEL-ENTRY(1) TO J-ENT-ENTRY(1)
     MOVE GEL-ENTRY(2) TO J-ENT-ENTRY(2)
     MOVE 0 TO J-ENT-LOST
     MOVE J-ENT TO GE-DATA
     MOVE EN-COUNT TO WS-BEFORE
     CALL "GENT-APPLY" USING WS-DIM WS-ROW
     MOVE 0 TO WS-WITCH WS-VILLAGER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-WITCH-TYPE
             MOVE WS-I TO WS-WITCH
         END-IF
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-VILLAGER-TYPE
             MOVE WS-I TO WS-VILLAGER
         END-IF
     END-PERFORM
     MOVE "test gen ent: the applied list made a witch and a villager and is emptied" TO TL-CASE
     MOVE 0 TO WS-FLAG-A WS-FLAG-B
     IF WS-WITCH > 0
         MOVE 1 TO WS-FLAG-A
     END-IF
     IF WS-VILLAGER > 0
         MOVE 1 TO WS-FLAG-B
     END-IF
     COMPUTE TL-OBSERVED-N = WS-FLAG-A * 100 + WS-FLAG-B * 10 + GE-COUNT
     MOVE 110 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen ent: the witch is persistent and stands where it was asked for" TO TL-CASE
     MOVE 0 TO WS-FLAG-A
     IF EN-X(WS-WITCH) = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 6.5
         MOVE 1 TO WS-FLAG-A
     END-IF
     COMPUTE TL-OBSERVED-N = EN-PERSISTENT(WS-WITCH) * 10 + WS-FLAG-A
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen ent: the villager is not persistent (PersistenceRequired 0), faces yaw 90 and is two blocks further" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-PERSISTENT(WS-VILLAGER) * 1000 + EN-YAW(WS-VILLAGER) * 10 + (EN-X(WS-VILLAGER) - EN-X(WS-WITCH))
     MOVE 902 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VL-FIND" USING EN-ID(WS-VILLAGER) WS-ZERO WS-SLOT
     MOVE "T" TO TL-MODE
     MOVE "test gen ent: the villager keeps the profession of its VillagerData" TO TL-CASE
     MOVE VL-PROF(WS-SLOT) TO TL-OBSERVED
     MOVE "nitwit" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "test gen ent: and its level" TO TL-CASE
     MOVE VL-LEVEL(WS-SLOT) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the same list again (the chunk generated again while the mobs were kept): nothing is made twice
     MOVE J-ENT TO GE-DATA
     MOVE EN-COUNT TO WS-BEFORE
     MOVE 0 TO WS-COUNTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         ADD EN-USED(WS-I) TO WS-COUNTED
     END-PERFORM
     MOVE WS-COUNTED TO WS-BEFORE
     CALL "GENT-APPLY" USING WS-DIM WS-ROW
     MOVE 0 TO WS-COUNTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         ADD EN-USED(WS-I) TO WS-COUNTED
     END-PERFORM
     MOVE "test gen ent: applying the same requests again makes no entity" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNTED - WS-BEFORE
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a nearly full entity table makes none (a full table is fatal)
     MOVE EN-COUNT TO WS-BEFORE
     PERFORM VARYING WS-I FROM EN-COUNT BY 1 UNTIL WS-I > 1010
         MOVE 1 TO EN-USED(WS-I)
         MOVE 0 TO EN-PLAYER(WS-I)
         MOVE 99 TO EN-DIM(WS-I)
     END-PERFORM
     MOVE 1010 TO EN-COUNT
     MOVE J-ENT TO GE-DATA
     MOVE 1 TO GE-COUNT
     COMPUTE GE-X(1) = GE-X(1) + 50
     CALL "GENT-APPLY" USING WS-DIM WS-ROW
     MOVE 0 TO WS-COUNTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-DIM(WS-I) = WS-DIM AND EN-X(WS-I) > GE-X(1) - 1 AND EN-X(WS-I) < GE-X(1) + 1
             ADD 1 TO WS-COUNTED
         END-IF
     END-PERFORM
     MOVE "test gen ent: with 16 rows or fewer free no entity is made" TO TL-CASE
     MOVE WS-COUNTED TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM WS-BEFORE BY 1 UNTIL WS-I > 1010
         IF EN-DIM(WS-I) = 99
             MOVE 0 TO EN-USED(WS-I)
         END-IF
     END-PERFORM
     MOVE WS-BEFORE TO EN-COUNT

*>   an empty list changes nothing and clears the lost count
     MOVE 0 TO GE-COUNT
     MOVE 5 TO GE-LOST
     CALL "GENT-APPLY" USING WS-DIM WS-ROW
     MOVE "test gen ent: an empty list: lost count cleared" TO TL-CASE
     MOVE GE-LOST TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   persistence: the flag is saved with the entity and read back
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-WITCH) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-WITCH) / 16)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     CALL "ENTITY-REMOVE" USING WS-WITCH
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-WITCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-WITCH-TYPE
             MOVE WS-I TO WS-WITCH
         END-IF
     END-PERFORM
     MOVE "test gen ent: the witch is read back from the entity storage still persistent" TO TL-CASE
     MOVE 0 TO WS-FLAG-A
     IF WS-WITCH > 0
         MOVE 1 TO WS-FLAG-A
     END-IF
     COMPUTE TL-OBSERVED-N = WS-FLAG-A * 10 + EN-PERSISTENT(WS-WITCH)
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   despawn: far from every player, the persistent witch stays; the same witch without the flag goes
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE EN-X(WS-WITCH) = PL-X(WS-PLAYER) + 300
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "MS6-DESPAWN-TICK" USING WS-WITCH
     END-PERFORM
     MOVE "test gen ent: a persistent witch 300 blocks from the player is not despawned" TO TL-CASE
     MOVE EN-USED(WS-WITCH) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-PERSISTENT(WS-WITCH)
     CALL "MS6-DESPAWN-TICK" USING WS-WITCH
     MOVE "test gen ent: the same witch without the flag is despawned" TO TL-CASE
     MOVE EN-USED(WS-WITCH) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 END PROGRAM TEST-GEN-ENT.
 COPY CORETEST.
