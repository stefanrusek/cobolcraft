*> Implementation test (wrap I2 round 5, T24090; docs/protocol/45-entity-nbt-7-aquatic-and-misc-mobs.md section 7 with 45-2 section 5 and 44-7 section 10.2): the saved state of the nautilus
*> and the zombie nautilus. A nautilus is an Animal that can be a baby: it writes Age, ForcedAge, AgeLocked and InLove, then the owner and the sitting order of a TamableAnimal. A zombie
*> nautilus cannot be a baby, so it writes InLove but none of the three age keys; it also writes its `variant` identifier (temperate or warm). Reading the compound back restores the tame
*> state (the owner), the sitting order, the age and the zombie nautilus's variant.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NAUTILUS-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 COPY CONTENT.
 COPY PROTO.
 COPY BRWORLD.
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
 01 WS-A                   BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
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

*>   A tame adult nautilus (chunk 1) that is ordered to sit and has been on a breeding cooldown of 300 ticks.
     MOVE 1 TO WS-CX
     MOVE "nautilus" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-TAMED(WS-MOB)
     MOVE WS-OWNER TO EN-OWNER-UUID(WS-MOB)
     MOVE 1 TO EN-SIT(WS-MOB)
     MOVE 300 TO EN-MOBAGE(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "implementation 45-7 7 nautilus: the age keys, InLove, Owner and Sitting in the chain order" TO TL-CASE
     MOVE "Age:300,ForcedAge:0,AgeLocked:0,InLove:0,Owner:I[1,2,3,4],Sitting:1" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "implementation 45-7 7 nautilus read back: tame" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-TAMED(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "implementation 45-7 7 nautilus read back: the owner" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-OWNER TO TL-EXPECTED
     MOVE EN-OWNER-UUID(WS-MOB) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 45-7 7 nautilus read back: ordered to sit" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-SIT(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "implementation 45-7 7 nautilus read back: the breeding cooldown 300" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     MOVE EN-MOBAGE(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   An untamed baby nautilus (chunk 2): no Owner, Sitting 0, a negative Age.
     MOVE 2 TO WS-CX
     MOVE "nautilus" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE -23000 TO EN-MOBAGE(WS-MOB)
     MOVE 1 TO EN-LOCKED(WS-MOB)
     MOVE 50 TO EN-FORCED(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "implementation 45-7 7 untamed baby nautilus: Age -23000, ForcedAge 50, AgeLocked 1, Sitting 0" TO TL-CASE
     MOVE "Age:-23000,ForcedAge:50,AgeLocked:1,InLove:0,Sitting:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE "implementation 45-7 7 untamed nautilus: no Owner key" TO TL-CASE
     MOVE "Owner" TO TL-EXPECTED
     PERFORM CHECK-LACKS
     PERFORM RELOAD
     MOVE "implementation 45-7 7 baby nautilus read back: Age -23000" TO TL-CASE
     MOVE -23000 TO TL-EXPECTED-N
     MOVE EN-MOBAGE(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "implementation 45-7 7 baby nautilus read back: untamed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TAMED(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "implementation 45-7 7 baby nautilus read back: age locked and forced age" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-LOCKED(WS-MOB) + EN-FORCED(WS-MOB)
     PERFORM CHECK-NUM

*>   A tame zombie nautilus of the warm variant (chunk 3): InLove, Owner, Sitting and variant, none of the age keys.
     MOVE 3 TO WS-CX
     MOVE "zombie_nautilus" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-VARIANT(WS-MOB)
     MOVE 1 TO EN-TAMED(WS-MOB)
     MOVE WS-OWNER TO EN-OWNER-UUID(WS-MOB)
     MOVE 40 TO EN-LOVE(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "implementation 45-7 7 zombie nautilus: InLove, Owner, Sitting and the warm variant" TO TL-CASE
     MOVE "InLove:40,Owner:I[1,2,3,4],Sitting:0,variant:minecraft:warm" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE "implementation 45-7 7 zombie nautilus: no Age, ForcedAge or AgeLocked (canBeABaby is false)" TO TL-CASE
     MOVE "Age" TO TL-EXPECTED
     PERFORM CHECK-LACKS
     PERFORM RELOAD
     MOVE "implementation 45-7 7 zombie nautilus read back: the warm variant is id 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "implementation 45-7 7 zombie nautilus read back: tame" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-TAMED(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "implementation 45-7 7 zombie nautilus read back: in love 40" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE EN-LOVE(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   A temperate zombie nautilus (chunk 4): `variant` temperate and an unnamed variant reads as temperate.
     MOVE 4 TO WS-CX
     MOVE "zombie_nautilus" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "implementation 45-7 7 zombie nautilus: variant temperate" TO TL-CASE
     MOVE "variant:minecraft:temperate" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE "Owner" TO TL-EXPECTED
     MOVE "implementation 45-7 7 untamed zombie nautilus: no Owner key" TO TL-CASE
     PERFORM CHECK-LACKS
     PERFORM RELOAD
     MOVE "implementation 45-7 7 zombie nautilus read back: temperate is id 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-MOB) TO TL-OBSERVED-N
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
 END PROGRAM TEST-NAUTILUS-NBT.
 COPY CORETEST.
