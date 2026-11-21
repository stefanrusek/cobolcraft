*> Entity NBT, part 6 (docs/protocol/45-entity-nbt-6-villagers-illagers-piglins.md sections 6, 7, 11 and 13; lane 002-lane-p49k, T24540): a villager's compound holds its
*> Inventory, VillagerData {type, profession, level}, VillagerDataFinalized, FoodLevel, Gossips, Xp, LastRestock, LastGossipDecay and RestocksToday; the pillager, evoker
*> and piglin carry their own keys; CanPickUpLoot is true for the piglins and the pillager. Reading a villager back restores its table entry.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-6.
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

*>   villager (chunk 1): a snow mason of level 3 with 120 xp, food 5, restocked at 7000, restocks today 2
     MOVE 1 TO WS-CX
     MOVE "villager" TO WS-WANT-KEY PERFORM SPAWN-ONE
     CALL "VL-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
     MOVE "mason" TO VL-PROF(WS-SLOT)
     MOVE 3 TO VL-LEVEL(WS-SLOT)
     MOVE 4 TO VL-TYPE(WS-SLOT)
     MOVE 120 TO VL-XP(WS-SLOT)
     MOVE 5 TO VL-FOOD(WS-SLOT)
     MOVE 7000 TO VL-LAST-RESTOCK(WS-SLOT)
     MOVE 24500 TO VL-LAST-DECAY(WS-SLOT)
     MOVE 2 TO VL-RESTOCKS(WS-SLOT)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-6 villager: Inventory, VillagerData, finalized, food, gossips, xp, restock and decay stamps, restocks today" TO TL-CASE
     MOVE "Inventory:[],VillagerData:{type:minecraft:snow,profession:minecraft:mason,level:3},VillagerDataFinalized:1,FoodLevel:5,Gossips:[],Xp:120,LastRestock:7000,LastGossipDecay:24500,RestocksToday:2" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     CALL "VL-FIND" USING EN-ID(WS-MOB) WS-ZERO WS-SLOT
     MOVE "acceptance US15 45-6 villager read back: profession, level, type, xp, food, stamps, restocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF VL-PROF(WS-SLOT) = "mason" AND VL-LEVEL(WS-SLOT) = 3 AND VL-TYPE(WS-SLOT) = 4 AND VL-XP(WS-SLOT) = 120
        AND VL-FOOD(WS-SLOT) = 5 AND VL-LAST-RESTOCK(WS-SLOT) = 7000 AND VL-LAST-DECAY(WS-SLOT) = 24500
        AND VL-RESTOCKS(WS-SLOT) = 2
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-NUM

*>   a newborn villager: plains, none, level 1
     MOVE 2 TO WS-CX
     MOVE "villager" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-6 villager without a job: type plains, profession none, level 1, 0 xp" TO TL-CASE
     MOVE "VillagerData:{type:minecraft:plains,profession:minecraft:none,level:1},VillagerDataFinalized:1,FoodLevel:0,Gossips:[],Xp:0," TO TL-EXPECTED
     PERFORM CHECK-HAS

*>   pillager (chunk 3): picks up loot, Inventory of 5 (empty)
     MOVE 3 TO WS-CX
     MOVE "pillager" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-6 pillager: CanPickUpLoot 1 and an empty Inventory" TO TL-CASE
     MOVE "CanPickUpLoot:1," TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE "acceptance US15 45-6 pillager: Inventory after the raider keys" TO TL-CASE
     MOVE "CanJoinRaid:0,Inventory:[]" TO TL-EXPECTED
     PERFORM CHECK-HAS

*>   evoker (chunk 4)
     MOVE 4 TO WS-CX
     MOVE "evoker" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-6 evoker: SpellTicks 0" TO TL-CASE
     MOVE "SpellTicks:0" TO TL-EXPECTED
     PERFORM CHECK-HAS

*>   piglin (chunk 5): immune, 90 ticks in the overworld
     MOVE 5 TO WS-CX
     MOVE "piglin" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-PIG-IMMUNE(WS-MOB)
     MOVE 90 TO EN-ZOMBIFY(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-6 piglin: CanPickUpLoot 1" TO TL-CASE
     MOVE "CanPickUpLoot:1," TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE "acceptance US15 45-6 piglin: IsImmuneToZombification, TimeInOverworld, IsBaby, CannotHunt, Inventory" TO TL-CASE
     MOVE "IsImmuneToZombification:1,TimeInOverworld:90,IsBaby:0,CannotHunt:0,Inventory:[]" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-6 piglin read back: immune and 90 ticks" TO TL-CASE
     MOVE 1090 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-PIG-IMMUNE(WS-MOB) * 1000 + EN-ZOMBIFY(WS-MOB)
     PERFORM CHECK-NUM

*>   piglin brute (chunk 6)
     MOVE 6 TO WS-CX
     MOVE "piglin_brute" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-6 piglin brute: the two conversion keys and no piglin keys" TO TL-CASE
     MOVE "IsImmuneToZombification:0,TimeInOverworld:0}" TO TL-EXPECTED
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
 END PROGRAM TEST-ENTITY-NBT-6.
 COPY CORETEST.
