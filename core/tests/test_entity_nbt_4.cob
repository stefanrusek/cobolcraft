*> Entity NBT, part 4 (docs/protocol/45-entity-nbt-4-land-animals.md sections 5 to 10; lane 002-lane-p49k, T24520): the species keys of goat, fox,
*> armadillo, turtle, bee, chicken, allay, camel, iron golem and snow golem are written after the chain keys, and reading the compound back restores the state.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-4.
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
 01 WS-HEAD                PIC X(8192).
 01 WS-TAIL                PIC X(8192).
 01 WS-A                   BINARY-LONG.
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

*>   goat (chunk 1): screaming, no left horn
     MOVE 1 TO WS-CX
     MOVE "goat" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 7 TO EN-WOOL(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 goat: IsScreamingGoat 1, HasLeftHorn 0, HasRightHorn 0" TO TL-CASE
     MOVE "IsScreamingGoat:1,HasLeftHorn:0,HasRightHorn:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 goat read back: screaming, both horns gone (EN-WOOL 7)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE EN-WOOL(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   fox (chunk 2): trusts two players, sleeping, crouching, sitting
     MOVE 2 TO WS-CX
     MOVE "fox" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE WS-OWNER TO EN-FOX-TRUST-A(WS-MOB)
     MOVE PL-UUID(WS-PLAYER) TO EN-FOX-TRUST-B(WS-MOB)
     COMPUTE EN-FOX-FLAGS(WS-MOB) = 32 + 4 + 1
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 fox: Trusted holds two UUID arrays" TO TL-CASE
     MOVE "Trusted:[I[1,2,3,4],I[" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE "acceptance US15 45-4 fox: Sleeping 1, Sitting 1, Crouching 1 after the trusted list" TO TL-CASE
     MOVE "Sleeping:1,Sitting:1,Crouching:1" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 fox read back: the two trusted UUIDs and the flags 37" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF EN-FOX-TRUST-A(WS-MOB) = WS-OWNER AND EN-FOX-TRUST-B(WS-MOB) = PL-UUID(WS-PLAYER) AND EN-FOX-FLAGS(WS-MOB) = 37
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-NUM

*>   armadillo (chunk 3): scared, scute time 1234
     MOVE 3 TO WS-CX
     MOVE "armadillo" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 2 TO EN-ARMA(WS-MOB)
     MOVE 1234 TO EN-SCUTE(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 armadillo: state scared, scute_time 1234" TO TL-CASE
     MOVE "state:scared,scute_time:1234" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 armadillo read back: state 2 with its 50 ticks, scute 1234" TO TL-CASE
     MOVE 2501234 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-MOB) * 1000000 + EN-ARMA-T(WS-MOB) * 10000 + EN-SCUTE(WS-MOB) - 0
     PERFORM CHECK-NUM

*>   turtle (chunk 4): home block (5, 60, 7), carries an egg
     MOVE 4 TO WS-CX
     MOVE "turtle" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-HOME-SET(WS-MOB) EN-TURTLE-EGG(WS-MOB)
     MOVE 5 TO EN-HOME-X(WS-MOB)
     MOVE 60 TO EN-HOME-Y(WS-MOB)
     MOVE 7 TO EN-HOME-Z(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 turtle: home_pos I[5,60,7], has_egg 1" TO TL-CASE
     MOVE "home_pos:I[5,60,7],has_egg:1" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 turtle read back: home (5, 60, 7), egg" TO TL-CASE
     MOVE 1506071 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-HOME-SET(WS-MOB) * 1000000 + EN-HOME-X(WS-MOB) * 100000 + EN-HOME-Y(WS-MOB) * 100 + EN-HOME-Z(WS-MOB) * 10 + EN-TURTLE-EGG(WS-MOB)
     PERFORM CHECK-NUM

*>   bee (chunk 5): hive and flower, nectar, stung, counters; angry for 100 ticks (NeutralMob)
     MOVE 5 TO WS-CX
     MOVE "bee" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-BEE-HV-ON(WS-MOB) EN-BEE-FL-ON(WS-MOB) EN-BEE-NECTAR(WS-MOB) EN-BEE-STUNG(WS-MOB)
     MOVE 10 TO EN-BEE-HV-X(WS-MOB) MOVE 64 TO EN-BEE-HV-Y(WS-MOB) MOVE -5 TO EN-BEE-HV-Z(WS-MOB)
     MOVE 12 TO EN-BEE-FL-X(WS-MOB) MOVE 65 TO EN-BEE-FL-Y(WS-MOB) MOVE -6 TO EN-BEE-FL-Z(WS-MOB)
     MOVE 77 TO EN-BEE-NONECT(WS-MOB)
     MOVE 33 TO EN-BEE-STAY(WS-MOB)
     MOVE 4 TO EN-BEE-CROPS(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 bee: hive_pos, flower_pos, HasNectar, HasStung and the three counters" TO TL-CASE
     MOVE "hive_pos:I[10,64,-5],flower_pos:I[12,65,-6],HasNectar:1,HasStung:1,TicksSincePollination:77,CannotEnterHiveTicks:33,CropsGrownSincePollination:4" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 bee read back: hive, flower, nectar, stung, 77, 33, 4" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF EN-BEE-HV-ON(WS-MOB) = 1 AND EN-BEE-HV-X(WS-MOB) = 10 AND EN-BEE-HV-Y(WS-MOB) = 64 AND EN-BEE-HV-Z(WS-MOB) = -5
        AND EN-BEE-FL-ON(WS-MOB) = 1 AND EN-BEE-FL-X(WS-MOB) = 12 AND EN-BEE-FL-Y(WS-MOB) = 65 AND EN-BEE-FL-Z(WS-MOB) = -6
        AND EN-BEE-NECTAR(WS-MOB) = 1 AND EN-BEE-STUNG(WS-MOB) = 1 AND EN-BEE-NONECT(WS-MOB) = 77
        AND EN-BEE-STAY(WS-MOB) = 33 AND EN-BEE-CROPS(WS-MOB) = 4
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-NUM

*>   chicken jockey (chunk 6)
     MOVE 6 TO WS-CX
     MOVE "chicken" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-JOCKEY(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 chicken: IsChickenJockey 1" TO TL-CASE
     MOVE "IsChickenJockey:1" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 chicken read back: the jockey flag" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-JOCKEY(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   allay (chunk 7): three items in its inventory, duplication cooldown 55
     MOVE 7 TO WS-CX
     MOVE "allay" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE WS-ITEM TO EN-ALLAY-ITEM(WS-MOB)
     MOVE 3 TO EN-ALLAY-COUNT(WS-MOB)
     MOVE 55 TO EN-ALLAY-DUP(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 allay: Inventory with the stack and DuplicationCooldown 55" TO TL-CASE
     MOVE "Inventory:[{id:minecraft:honeycomb,count:3}],DuplicationCooldown:55" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 allay read back: the held stack and the cooldown" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-ITEM * 100000 + 3 * 1000 + 55
     COMPUTE TL-OBSERVED-N = EN-ALLAY-ITEM(WS-MOB) * 100000 + EN-ALLAY-COUNT(WS-MOB) * 1000 + EN-ALLAY-DUP(WS-MOB)
     PERFORM CHECK-NUM

*>   camel (chunk 8): sitting since tick 4000
     MOVE 8 TO WS-CX
     MOVE "camel" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-CAMEL-POSE(WS-MOB)
     MOVE 4000 TO EN-CAMEL-POSE-T(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 camel: LastPoseTick is negative while sitting, and the horse keys" TO TL-CASE
     MOVE "LastPoseTick:-4000,EatingHaystack:0,Bred:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 camel read back: sitting, pose tick 4000" TO TL-CASE
     MOVE 1004000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-CAMEL-POSE(WS-MOB) * 1000000 + EN-CAMEL-POSE-T(WS-MOB)
     PERFORM CHECK-NUM

*>   iron golem and snow golem (chunks 9 and 10): the default keys
     MOVE 9 TO WS-CX
     MOVE "iron_golem" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 iron golem: PlayerCreated 0" TO TL-CASE
     MOVE "PlayerCreated:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE 10 TO WS-CX
     MOVE "snow_golem" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 snow golem: Pumpkin 1" TO TL-CASE
     MOVE "Pumpkin:1" TO TL-EXPECTED
     PERFORM CHECK-HAS

*>   armadillo rolling (chunk 11), unrolling (12) and idle (13): the state names and the ticks each state has left
     MOVE 11 TO WS-CX
     MOVE "armadillo" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-ARMA(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 armadillo: state rolling" TO TL-CASE
     MOVE "state:rolling" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 armadillo read back: rolling with 10 ticks" TO TL-CASE
     MOVE 1010 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-MOB) * 1000 + EN-ARMA-T(WS-MOB)
     PERFORM CHECK-NUM
     MOVE 12 TO WS-CX
     MOVE "armadillo" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 3 TO EN-ARMA(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 armadillo: state unrolling" TO TL-CASE
     MOVE "state:unrolling" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 armadillo read back: unrolling with 30 ticks" TO TL-CASE
     MOVE 3030 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-MOB) * 1000 + EN-ARMA-T(WS-MOB)
     PERFORM CHECK-NUM
     MOVE 13 TO WS-CX
     MOVE "armadillo" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 armadillo: state idle" TO TL-CASE
     MOVE "state:idle" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-4 armadillo read back: idle" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   a turtle with no home set writes its own block (chunk 14: x 228.5, y 55, z 37.25); an allay with nothing in its inventory writes an empty list (chunk 15)
     MOVE 14 TO WS-CX
     MOVE "turtle" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 turtle without a home: home_pos is its own block" TO TL-CASE
     MOVE "home_pos:I[228,55,37],has_egg:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE 15 TO WS-CX
     MOVE "allay" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-4 allay with nothing held: an empty Inventory" TO TL-CASE
     MOVE "Inventory:[],DuplicationCooldown:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
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
 END PROGRAM TEST-ENTITY-NBT-4.
 COPY CORETEST.
