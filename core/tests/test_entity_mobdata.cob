*> Implementation test of the saved state of mobs (core/src/entity-mobdata.cob MOB-NBT-WRITE, MOB-NBT-KEY, MOB-NBT-APPLY, MOB-LEASH-RESTORE;
*> docs/protocol/45-entity-nbt-2 sections 4 and 5, 45-4 sections 3 to 8, 45-5 section 4.1; 07 section 9.3): a standard-set mob is written
*> with the keys of its class chain (Age, ForcedAge, AgeLocked, InLove; Owner, Sitting; CollarColor; Sheared and Color; variant; Type;
*> Strength; Tame and Temper; equipment saddle and body; IsBaby, powered, Size; leash) and reading the payload back restores the
*> gameplay state of every species: owner, tamed, sitting, collar, baby, age, love, wool, saddle, wolf armour and the leash holder.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-MOBDATA.
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
 01 WS-I                   BINARY-LONG.
 01 WS-ARMOUR              BINARY-LONG.
 01 WS-OWNER               PIC X(16) VALUE X"00000001000000020000000300000004".
 01 WS-OWNER-CODE          PIC X.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-OBSERVED            PIC X(1024).
 01 WS-MOB-TABLE.
    05 WS-MOB              BINARY-LONG OCCURS 24 TIMES.
 01 WS-MOB-COUNT           BINARY-LONG VALUE 0.
 01 WS-COW                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = "wolf_armor"
             COMPUTE WS-ARMOUR = WS-I - 1
         END-IF
     END-PERFORM

*>   Chunk (1, 2) of the dimension (x 16 to 31, z 32 to 47) holds the mobs, one after the other along x.
     MOVE "wolf" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE WS-OWNER TO EN-OWNER-UUID(WS-ROW)
     MOVE 1 TO EN-SIT(WS-ROW)
     MOVE 4 TO EN-COLLAR(WS-ROW)
     MOVE WS-ARMOUR TO EN-WOLF-ARM(WS-ROW)
     MOVE 12 TO EN-WOLF-ARM-DMG(WS-ROW)
     MOVE 8 TO EN-HEALTH(WS-ROW)
     MOVE 0 TO EN-WOOL(WS-ROW)
     MOVE "sheep" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 21 TO EN-WOOL(WS-ROW)
     MOVE -12000 TO EN-MOBAGE(WS-ROW)
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE 40 TO EN-FORCED(WS-ROW)
     MOVE 1 TO EN-LOCKED(WS-ROW)
     MOVE "pig" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-SADDLE(WS-ROW)
     MOVE 2 TO EN-WOOL(WS-ROW)
     MOVE 300 TO EN-LOVE(WS-ROW)
     MOVE "llama" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 3 TO EN-WOOL(WS-ROW)
     MOVE 4 TO EN-STRENGTH(WS-ROW)
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE 55 TO EN-TEMPER(WS-ROW)
     MOVE WS-OWNER TO EN-OWNER-UUID(WS-ROW)
     MOVE "horse" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE 1 TO EN-SADDLE(WS-ROW)
     MOVE 70 TO EN-TEMPER(WS-ROW)
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-ROW)
     MOVE "mooshroom" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-WOOL(WS-ROW)
     MOVE "chicken" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-WOOL(WS-ROW)
     MOVE 1234 TO EN-EGG(WS-ROW)
     MOVE "fox" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-WOOL(WS-ROW)
     MOVE "panda" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 3 TO EN-GENE-MAIN(WS-ROW)
     MOVE 5 TO EN-GENE-HIDDEN(WS-ROW)
     MOVE "cat" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-ROW)
     MOVE 0 TO EN-COLLAR(WS-ROW)
     MOVE "parrot" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 2 TO EN-WOOL(WS-ROW)
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE WS-OWNER TO EN-OWNER-UUID(WS-ROW)
     MOVE "ocelot" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE "zombie" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE "creeper" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE "slime" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 3 TO EN-VARIANT(WS-ROW)
     MOVE "camel" TO WS-WANT-KEY PERFORM SPAWN-MOB
     MOVE 1 TO EN-SADDLE(WS-ROW)
     MOVE "iron_golem" TO WS-WANT-KEY PERFORM SPAWN-MOB

*>   The wolf's own compound, written alone: every key of its chain in order.
     MOVE 1 TO WS-CX
     MOVE 2 TO WS-CZ
     MOVE "mobdata wolf payload: Age, ForcedAge, AgeLocked, InLove, Owner, Sitting, CollarColor, body armour with its damage"
         TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "[{id:minecraft:wolf,Pos:[20.500,55.000,37.250],Motion:[0.000,0.000,0.000],Rotation:[90.000,0.000],"
         & "Health:8.000,Age:0,ForcedAge:0,AgeLocked:0,InLove:0,Owner:I[1,2,3,4],Sitting:1,CollarColor:3,"
         & "equipment:{body:{id:minecraft:wolf_armor,count:1,components:{minecraft:damage:12}}}}"
         TO TL-EXPECTED
     COMPUTE WS-A = FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED))
     MOVE WS-TEXT(1:WS-A) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every mob of the chunk leaves and the payload brings it back.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-MOB-COUNT
         CALL "ENTITY-REMOVE" USING WS-MOB(WS-I)
     END-PERFORM
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-I
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             ADD 1 TO WS-I
             MOVE WS-ROW TO WS-MOB(WS-I)
         END-IF
     END-PERFORM
     MOVE "mobdata every mob comes back (17 mobs)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 17 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO WS-I
     MOVE "mobdata wolf read back: owner, sitting, tamed, collar 3 (stored 4), armour with its damage" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own o sit 1 tame 1 col 4 wool 0 sad 0 arm " TO TL-EXPECTED
     MOVE WS-ARMOUR TO WS-EDIT
     STRING FUNCTION TRIM(TL-EXPECTED) " " FUNCTION TRIM(WS-EDIT) "/12 temper 0 str 0 egg 0 var 0 gene 0/0"
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE WS-OBSERVED TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 2 TO WS-I
     MOVE "mobdata sheep read back: baby by its negative age, forced age, locked, sheared lime" TO TL-CASE
     MOVE "age -12000 forced 40 lock 1 love 0 own - sit 0 tame 0 col 0 wool 21 sad 0 arm 0/0 temper 0 str 0 egg 0 var 1 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 3 TO WS-I
     MOVE "mobdata pig read back: saddle, warm variant, in love 300" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 300 own - sit 0 tame 0 col 0 wool 2 sad 1 arm 0/0 temper 0 str 0 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 4 TO WS-I
     MOVE "mobdata llama read back: tame, temper, owner, strength 4, variant 3" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own o sit 0 tame 1 col 0 wool 3 sad 0 arm 0/0 temper 55 str 4 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 5 TO WS-I
     MOVE "mobdata horse read back: tame, saddle, temper 70, the player as owner" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own p sit 0 tame 1 col 0 wool 0 sad 1 arm 0/0 temper 70 str 0 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 6 TO WS-I
     MOVE "mobdata mooshroom read back: brown" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own - sit 0 tame 0 col 0 wool 1 sad 0 arm 0/0 temper 0 str 0 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 7 TO WS-I
     MOVE "mobdata chicken read back: variant cold, egg timer" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own - sit 0 tame 0 col 0 wool 1 sad 0 arm 0/0 temper 0 str 0 egg 1234 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 8 TO WS-I
     MOVE "mobdata fox read back: snow" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own - sit 0 tame 0 col 0 wool 1 sad 0 arm 0/0 temper 0 str 0 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 9 TO WS-I
     MOVE "mobdata panda read back: main gene playful, hidden gene weak" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own - sit 0 tame 0 col 0 wool 0 sad 0 arm 0/0 temper 0 str 0 egg 0 var 0 gene 3/5"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 10 TO WS-I
     MOVE "mobdata cat read back: tame by its owner, the default collar stays unset" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own p sit 0 tame 1 col 0 wool 0 sad 0 arm 0/0 temper 0 str 0 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 11 TO WS-I
     MOVE "mobdata parrot read back: owner and variant 2" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own o sit 0 tame 1 col 0 wool 2 sad 0 arm 0/0 temper 0 str 0 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 12 TO WS-I
     MOVE "mobdata ocelot read back: trusting" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own - sit 0 tame 1 col 0 wool 0 sad 0 arm 0/0 temper 0 str 0 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 13 TO WS-I
     MOVE "mobdata zombie read back: IsBaby" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own - sit 0 tame 0 col 0 wool 0 sad 0 arm 0/0 temper 0 str 0 egg 0 var 1 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 14 TO WS-I
     MOVE "mobdata creeper read back: powered" TO TL-CASE
     PERFORM CHECK-MOB
     MOVE 15 TO WS-I
     MOVE "mobdata slime read back: size 3" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own - sit 0 tame 0 col 0 wool 0 sad 0 arm 0/0 temper 0 str 0 egg 0 var 3 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 16 TO WS-I
     MOVE "mobdata camel read back: saddle" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own - sit 0 tame 0 col 0 wool 0 sad 1 arm 0/0 temper 0 str 0 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB
     MOVE 17 TO WS-I
     MOVE "mobdata iron golem writes no Age keys: its payload has no Age" TO TL-CASE
     MOVE "age 0 forced 0 lock 0 love 0 own - sit 0 tame 0 col 0 wool 0 sad 0 arm 0/0 temper 0 str 0 egg 0 var 0 gene 0/0"
         TO TL-EXPECTED
     PERFORM CHECK-MOB

*>   A leashed cow: the holder is saved by UUID and found again when the player is in the dimension.
     CALL "ENTITY-REMOVE" USING WS-MOB(1)
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > 8
         PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > 8
             COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 4 + WS-A
             COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 4 + WS-B
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STATE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-Y = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 0.5
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     COMPUTE WS-X = PL-X(WS-PLAYER) + 2
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE "cow" TO WS-WANT-KEY
     PERFORM SPAWN-AT
     MOVE WS-ROW TO WS-COW
     MOVE WS-PLAYER TO EN-LEASH(WS-COW)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z / 16)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE 0 TO WS-A
     INSPECT WS-TEXT TALLYING WS-A FOR ALL ",leash:{UUID:I["
     MOVE "mobdata a leashed cow is saved with a leash compound holding the holder's UUID" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-COW
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-COW
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = WS-DIM
                 AND EN-X(WS-ROW) > PL-X(WS-PLAYER) AND EN-X(WS-ROW) < PL-X(WS-PLAYER) + 3
             MOVE WS-ROW TO WS-COW
         END-IF
     END-PERFORM
     MOVE "mobdata the leash is kept as the holder's UUID until the holder is found" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-LEASH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     IF EN-LEASH-UUID(WS-COW) = PL-UUID(WS-PLAYER)
         MOVE 0 TO WS-A
     END-IF
     MOVE "mobdata the pending holder is the player's UUID" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS-ANSWERED" USING 1
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "mobdata a tick finds the holder in the dimension: the cow is leashed to the player again" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-LEASH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mobdata the pending holder is cleared once found" TO TL-CASE
     MOVE 0 TO WS-A
     IF EN-LEASH-UUID(WS-COW) NOT = SPACES
         MOVE 1 TO WS-A
     END-IF
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SPAWN-MOB.
     COMPUTE WS-X = 17.5 + 0.75 * WS-MOB-COUNT
     MOVE 55 TO WS-Y
     MOVE 37.25 TO WS-Z
     IF WS-MOB-COUNT = 0
         MOVE 20.5 TO WS-X
     END-IF
     PERFORM SPAWN-AT
     ADD 1 TO WS-MOB-COUNT
     MOVE WS-ROW TO WS-MOB(WS-MOB-COUNT).

 SPAWN-AT.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW.

 CHECK-MOB.
     MOVE WS-MOB(WS-I) TO WS-ROW
     MOVE "-" TO WS-OWNER-CODE
     IF EN-OWNER-UUID(WS-ROW) = WS-OWNER
         MOVE "o" TO WS-OWNER-CODE
     END-IF
     IF EN-OWNER-UUID(WS-ROW) = PL-UUID(WS-PLAYER)
         MOVE "p" TO WS-OWNER-CODE
     END-IF
     MOVE SPACES TO WS-OBSERVED
     MOVE EN-MOBAGE(WS-ROW) TO WS-EDIT
     STRING "age " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-FORCED(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " forced " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-LOCKED(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " lock " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-LOVE(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " love " FUNCTION TRIM(WS-EDIT) " own " WS-OWNER-CODE DELIMITED BY SIZE
         INTO WS-OBSERVED
     MOVE EN-SIT(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " sit " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-TAMED(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " tame " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-COLLAR(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " col " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-WOOL(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " wool " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-SADDLE(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " sad " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-WOLF-ARM(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " arm " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-WOLF-ARM-DMG(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) "/" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-TEMPER(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " temper " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-STRENGTH(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " str " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-EGG(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " egg " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-VARIANT(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " var " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-GENE-MAIN(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " gene " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE EN-GENE-HIDDEN(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) "/" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-MOBDATA.

 COPY CORETEST.
