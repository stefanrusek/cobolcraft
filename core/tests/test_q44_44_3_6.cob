*> Test of 44 part 3 section 3.2 (and 45-6 section 7), the saved fields of a villager (lane 002-lane-p49h, T22006): VillagerData, VillagerDataFinalized, FoodLevel, Xp, LastRestock,
*> LastGossipDecay and RestocksToday are written with the entity and read back (type, profession, level, xp, restock clock, restocks today, food level).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-3-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY VILSTATE.
 COPY ENMOBDATA.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-WANT                PIC X(160).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 0.5
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
     MOVE "farmer" TO VL-PROF(WS-SLOT)
     MOVE 3 TO VL-LEVEL(WS-SLOT)
     MOVE 3 TO VL-TYPE(WS-SLOT)
     MOVE 80 TO VL-XP(WS-SLOT)
     MOVE 2 TO VL-RESTOCKS(WS-SLOT)
     MOVE 12345 TO VL-LAST-RESTOCK(WS-SLOT)
     MOVE 24000 TO VL-LAST-DECAY(WS-SLOT)
     MOVE 7 TO VL-FOOD(WS-SLOT)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z / 16)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
*>   The villager keys are written by VILLAGER6-NBT-WRITE (lane p49k, 45-6 section 7), which puts the Gossips between FoodLevel and Xp; MOB-VILLAGER-WRITE of this lane is no longer called.
     MOVE "VillagerData:{type:minecraft:savanna,profession:minecraft:farmer,level:3},VillagerDataFinalized:1,FoodLevel:7," TO WS-WANT
     MOVE 0 TO WS-A
     INSPECT WS-TEXT TALLYING WS-A FOR ALL FUNCTION TRIM(WS-WANT)
     MOVE "acceptance US15 44-3§3.2 the villager's saved fields: VillagerData, VillagerDataFinalized, FoodLevel in the documented order" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "Xp:80,LastRestock:12345,LastGossipDecay:24000,RestocksToday:2" TO WS-WANT
     MOVE 0 TO WS-A
     INSPECT WS-TEXT TALLYING WS-A FOR ALL FUNCTION TRIM(WS-WANT)
     MOVE "acceptance US15 44-3§3.2 Xp, LastRestock, LastGossipDecay and RestocksToday follow" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The villager leaves and the payload brings it back with the same state.
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > EN-COUNT
         IF EN-USED(WS-A) = 1 AND EN-PLAYER(WS-A) = 0 AND EN-TYPE(WS-A) = WS-TYPE
             MOVE WS-A TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-3§3.2 the villager comes back" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-ROW > 0
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
     MOVE "acceptance US15 44-3§3.2 profession farmer is read back" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF VL-PROF(WS-SLOT) = "farmer"
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§3.2 level 3 is read back" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE VL-LEVEL(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§3.2 the savanna type (3) is read back" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE VL-TYPE(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§3.2 Xp 80 is read back" TO WS-CASE
     MOVE 80 TO WS-E
     MOVE VL-XP(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§3.2 RestocksToday 2 is read back" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE VL-RESTOCKS(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§3.2 LastRestock 12345 is read back" TO WS-CASE
     MOVE 12345 TO WS-E
     MOVE VL-LAST-RESTOCK(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§3.2 LastGossipDecay 24000 is read back" TO WS-CASE
     MOVE 24000 TO WS-E
     MOVE VL-LAST-DECAY(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§3.2 FoodLevel 7 is read back" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE VL-FOOD(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   An entity row that holds no villager state writes nothing and applies nothing.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "MOB-VILLAGER-WRITE" USING PL-ENTITY-ROW(WS-PLAYER) PB-BUFFER
     MOVE "acceptance US15 44-3§3.2 a row without villager state writes no keys" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE PB-LENGTH TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 4 TO VL-TYPE(WS-SLOT)
     MOVE SPACES TO MQ-VTYPE
     MOVE 5 TO MQ-RESTOCKS
     CALL "MOB-VILLAGER-APPLY" USING PL-ENTITY-ROW(WS-PLAYER) MQ-DATA
     MOVE "acceptance US15 44-3§3.2 applying to a row without villager state changes nothing" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE VL-RESTOCKS(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A type of unknown name keeps the type of the villager.
     CALL "MOB-VILLAGER-APPLY" USING WS-ROW MQ-DATA
     MOVE "acceptance US15 44-3§3.2 a saved type of no known name keeps the villager's type" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE VL-TYPE(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-Q44-44-3-6.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
