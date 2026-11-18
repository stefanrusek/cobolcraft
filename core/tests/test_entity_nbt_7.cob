*> Entity NBT, part 7 (docs/protocol/45-entity-nbt-7-aquatic-and-misc-mobs.md sections 3, 4 and 6; lane 002-lane-p49k, T24550): the fish write FromBucket and their own variant
*> keys and no Age keys (they are not AgeableMobs); the glow squid, the dolphin and the tadpole write theirs; reading the compound back restores the variant, the puff state, the
*> dark ticks, the moistness and the tadpole's age.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 COPY CONTENT.
 COPY PROTO.
 COPY BRWORLD.
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
 01 WS-MOB                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
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

*>   cod (chunk 1): FromBucket only, no Age keys
     MOVE 1 TO WS-CX
     MOVE "cod" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-7 cod: FromBucket 0 closes the compound" TO TL-CASE
     MOVE "LeftHanded:0,FromBucket:0}" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE "acceptance US15 45-7 cod: no Age keys (a fish is not an AgeableMob)" TO TL-CASE
     MOVE "ForcedAge" TO TL-EXPECTED
     PERFORM CHECK-LACKS

*>   salmon (chunk 2): a large one (EN-VARIANT 3 = 1 + id 2)
     MOVE 2 TO WS-CX
     MOVE "salmon" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 3 TO EN-VARIANT(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-7 salmon: FromBucket 0, type large" TO TL-CASE
     MOVE "FromBucket:0,type:large" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-7 salmon read back: large (EN-VARIANT 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   pufferfish (chunk 3): puffed up fully
     MOVE 3 TO WS-CX
     MOVE "pufferfish" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 2 TO EN-VARIANT(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-7 pufferfish: PuffState 2" TO TL-CASE
     MOVE "FromBucket:0,PuffState:2" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-7 pufferfish read back: puff state 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   tropical fish (chunk 4): packed variant 117506305 (stripey, orange, gray)
     MOVE 4 TO WS-CX
     MOVE "tropical_fish" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 117506306 TO EN-VARIANT(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-7 tropical fish: Variant 117506305" TO TL-CASE
     MOVE "FromBucket:0,Variant:117506305" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-7 tropical fish read back: the packed variant" TO TL-CASE
     MOVE 117506306 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   glow squid (chunk 5): 55 dark ticks left
     MOVE 5 TO WS-CX
     MOVE "glow_squid" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 55 TO EN-DARK(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-7 glow squid: DarkTicksRemaining 55" TO TL-CASE
     MOVE "DarkTicksRemaining:55" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-7 glow squid read back: 55" TO TL-CASE
     MOVE 55 TO TL-EXPECTED-N
     MOVE EN-DARK(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   dolphin (chunk 6): out of water for 600 ticks, so moistness 1800
     MOVE 6 TO WS-CX
     MOVE "dolphin" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 600 TO EN-DRY(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-7 dolphin: GotFish 0, Moistness 1800" TO TL-CASE
     MOVE "GotFish:0,Moistness:1800" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-7 dolphin read back: out of water for 600 ticks" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   tadpole (chunk 7): age 1000, locked
     MOVE 7 TO WS-CX
     MOVE "tadpole" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1000 TO EN-TAD-AGE(WS-MOB)
     MOVE 1 TO EN-LOCKED(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-7 tadpole: FromBucket, Age 1000 and AgeLocked 1 and no ForcedAge" TO TL-CASE
     MOVE "FromBucket:0,Age:1000,AgeLocked:1}" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE "ForcedAge" TO TL-EXPECTED
     MOVE "acceptance US15 45-7 tadpole: no ForcedAge" TO TL-CASE
     PERFORM CHECK-LACKS
     PERFORM RELOAD
     MOVE "acceptance US15 45-7 tadpole read back: age 1000 locked" TO TL-CASE
     MOVE 1001 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-TAD-AGE(WS-MOB) + EN-LOCKED(WS-MOB)
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
 END PROGRAM TEST-ENTITY-NBT-7.
 COPY CORETEST.
