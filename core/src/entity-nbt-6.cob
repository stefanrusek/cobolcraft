*> Entity NBT, part 6 (docs/protocol/45-entity-nbt-6-villagers-illagers-piglins.md sections 6, 7, 11 and 13; lane 002-lane-p49k, T24540): the villager, illager
*> and piglin keys after the chain keys.
*>   VILLAGER6-NBT-WRITE USING row, species key (PIC X(24)), PB-BUFFER   villager (Inventory, VillagerData {type, profession, level}, VillagerDataFinalized,
*>        FoodLevel, Gossips, Xp, LastRestock, LastGossipDecay, RestocksToday), pillager (Inventory), evoker and illusioner (SpellTicks), piglin and
*>        piglin brute (IsImmuneToZombification, TimeInOverworld; the piglin also IsBaby, CannotHunt, Inventory)
*>   VILLAGER6-NBT-KEY USING PB-BUFFER, tag type, name, V6-DATA, handled   VillagerData, FoodLevel, Xp, LastRestock, LastGossipDecay, RestocksToday
*>        (the piglin's IsImmuneToZombification and TimeInOverworld are read by HOSTILE5-NBT-KEY: ENTITY-NBT-ONE hands them to V6-IMMUNE and V6-TIME)
*>   VILLAGER6-NBT-APPLY USING row, species key, V6-DATA   the villager's table entry (VILSTATE.cpy) and a piglin's immunity and time in the overworld
*> No state in the core, written at the default: Inventory (the villager keeps food points only), Gossips, VillagerDataFinalized 1, SpellTicks 0, IsBaby 0, CannotHunt 0.
*> Not modelled: Offers (the table of VILSTATE.cpy has the trade sets by level, no saved form here), the wandering trader (section 9), Johnny, the raid state (12.2), the piglin
*> memories (13.2), the zombie villager.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VILLAGER6-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-TYPES.
    05 FILLER              PIC X(8) VALUE "desert".
    05 FILLER              PIC X(8) VALUE "jungle".
    05 FILLER              PIC X(8) VALUE "plains".
    05 FILLER              PIC X(8) VALUE "savanna".
    05 FILLER              PIC X(8) VALUE "snow".
    05 FILLER              PIC X(8) VALUE "swamp".
    05 FILLER              PIC X(8) VALUE "taiga".
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE-NAME        PIC X(8) OCCURS 7 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW L-KEY PB-BUFFER.
     IF L-KEY = "villager"
         CALL "VL-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
         MOVE "Inventory" TO WN MOVE 9 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ZERO
         MOVE "VillagerData" TO WN MOVE 12 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "type" TO WN MOVE 4 TO WL
         MOVE SPACES TO WS-TEXT
         MOVE "minecraft:plains" TO WS-TEXT
         IF WS-SLOT > 0
             IF VL-TYPE(WS-SLOT) >= 0 AND VL-TYPE(WS-SLOT) <= 6
                 MOVE SPACES TO WS-TEXT
                 STRING "minecraft:" WS-TYPE-NAME(VL-TYPE(WS-SLOT) + 1) DELIMITED BY SPACE INTO WS-TEXT
             END-IF
         END-IF
         COMPUTE WS-TEXT-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
         MOVE "profession" TO WN MOVE 10 TO WL
         MOVE "minecraft:none" TO WS-TEXT
         IF WS-SLOT > 0
             MOVE SPACES TO WS-TEXT
             STRING "minecraft:" VL-PROF(WS-SLOT) DELIMITED BY SPACE INTO WS-TEXT
         END-IF
         COMPUTE WS-TEXT-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
         MOVE "level" TO WN MOVE 5 TO WL
         MOVE 1 TO WS-VALUE
         IF WS-SLOT > 0
             MOVE FUNCTION MAX(VL-LEVEL(WS-SLOT), 1) TO WS-VALUE
         END-IF
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         MOVE "VillagerDataFinalized" TO WN MOVE 21 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
         MOVE "FoodLevel" TO WN MOVE 9 TO WL
         MOVE 0 TO WS-VALUE
         IF WS-SLOT > 0
             MOVE VL-FOOD(WS-SLOT) TO WS-VALUE
         END-IF
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
         MOVE "Gossips" TO WN MOVE 7 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ZERO
         MOVE "Xp" TO WN MOVE 2 TO WL
         MOVE 0 TO WS-VALUE
         IF WS-SLOT > 0
             MOVE VL-XP(WS-SLOT) TO WS-VALUE
         END-IF
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
         MOVE "LastRestock" TO WN MOVE 11 TO WL
         MOVE 0 TO WS-LONG
         IF WS-SLOT > 0
             MOVE VL-LAST-RESTOCK(WS-SLOT) TO WS-LONG
         END-IF
         CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
         MOVE "LastGossipDecay" TO WN MOVE 15 TO WL
         MOVE 0 TO WS-LONG
         IF WS-SLOT > 0
             MOVE VL-LAST-DECAY(WS-SLOT) TO WS-LONG
         END-IF
         CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
         MOVE "RestocksToday" TO WN MOVE 13 TO WL
         MOVE 0 TO WS-VALUE
         IF WS-SLOT > 0
             MOVE VL-RESTOCKS(WS-SLOT) TO WS-VALUE
         END-IF
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     END-IF
     IF L-KEY = "pillager"
         MOVE "Inventory" TO WN MOVE 9 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ZERO
     END-IF
     IF L-KEY = "evoker" OR "illusioner"
         MOVE "SpellTicks" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
     END-IF
     IF L-KEY = "piglin" OR "piglin_brute"
         MOVE "IsImmuneToZombification" TO WN MOVE 23 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-PIG-IMMUNE(L-ROW)
         MOVE "TimeInOverworld" TO WN MOVE 15 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-ZOMBIFY(L-ROW)
     END-IF
     IF L-KEY = "piglin"
         MOVE "IsBaby" TO WN MOVE 6 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
         MOVE "CannotHunt" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
         MOVE "Inventory" TO WN MOVE 9 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM VILLAGER6-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VILLAGER6-NBT-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG VALUE 10.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PATH                PIC X(24).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-LOCAL               PIC X(48).
 01 WS-BARE                PIC X(48).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 COPY V6DATA.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-NAME V6-DATA L-HANDLED.
     MOVE 1 TO L-HANDLED
     MOVE PB-POS TO WS-START
     EVALUATE TRUE
         WHEN L-NAME = "VillagerData" AND L-TYPE = 10
*>           The compound {type, profession, level}: the two keys without their namespace, and the level.
             MOVE "profession" TO WS-PATH
             MOVE 10 TO WS-PATH-LENGTH
             CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
             IF WS-FOUND = 8
                 MOVE SPACES TO WS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                 CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                 CALL "KEY-BARE" USING WS-LOCAL WS-BARE
                 MOVE WS-BARE TO V6-PROF
             END-IF
             MOVE WS-START TO PB-POS
             MOVE "type" TO WS-PATH
             MOVE 4 TO WS-PATH-LENGTH
             CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
             IF WS-FOUND = 8
                 MOVE SPACES TO WS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                 CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                 CALL "KEY-BARE" USING WS-LOCAL WS-BARE
                 MOVE WS-BARE TO V6-TYPE
             END-IF
             MOVE WS-START TO PB-POS
             MOVE "level" TO WS-PATH
             MOVE 5 TO WS-PATH-LENGTH
             CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
             IF WS-FOUND = 3
                 CALL "PB-GET-INT" USING PB-BUFFER V6-LEVEL
             END-IF
             MOVE WS-START TO PB-POS
             CALL "NBT-READ-SKIP" USING PB-BUFFER L-TYPE
         WHEN L-NAME = "FoodLevel" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER V6-FOOD
         WHEN L-NAME = "Xp" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER V6-XP
         WHEN L-NAME = "LastRestock" AND L-TYPE = 4
             CALL "PB-GET-LONG" USING PB-BUFFER V6-RESTOCK
         WHEN L-NAME = "LastGossipDecay" AND L-TYPE = 4
             CALL "PB-GET-LONG" USING PB-BUFFER V6-DECAY
         WHEN L-NAME = "RestocksToday" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER V6-RESTOCKS
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM VILLAGER6-NBT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VILLAGER6-NBT-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TYPES.
    05 FILLER              PIC X(8) VALUE "desert".
    05 FILLER              PIC X(8) VALUE "jungle".
    05 FILLER              PIC X(8) VALUE "plains".
    05 FILLER              PIC X(8) VALUE "savanna".
    05 FILLER              PIC X(8) VALUE "snow".
    05 FILLER              PIC X(8) VALUE "swamp".
    05 FILLER              PIC X(8) VALUE "taiga".
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE-NAME        PIC X(8) OCCURS 7 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 COPY V6DATA.
 PROCEDURE DIVISION USING L-ROW L-KEY V6-DATA.
     IF L-KEY = "villager"
         CALL "VL-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
         IF WS-SLOT > 0
             IF V6-PROF NOT = SPACES AND V6-PROF NOT = "none"
                 MOVE V6-PROF TO VL-PROF(WS-SLOT)
             END-IF
             IF V6-LEVEL > 0
                 MOVE V6-LEVEL TO VL-LEVEL(WS-SLOT)
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
                 IF V6-TYPE NOT = SPACES AND WS-TYPE-NAME(WS-I) = V6-TYPE
                     COMPUTE VL-TYPE(WS-SLOT) = WS-I - 1
                 END-IF
             END-PERFORM
             MOVE V6-FOOD TO VL-FOOD(WS-SLOT)
             MOVE V6-XP TO VL-XP(WS-SLOT)
             MOVE V6-RESTOCK TO VL-LAST-RESTOCK(WS-SLOT)
             MOVE V6-DECAY TO VL-LAST-DECAY(WS-SLOT)
             MOVE V6-RESTOCKS TO VL-RESTOCKS(WS-SLOT)
         END-IF
     END-IF
     IF L-KEY = "piglin" OR "piglin_brute"
         MOVE 0 TO EN-PIG-IMMUNE(L-ROW)
         IF V6-IMMUNE NOT = 0
             MOVE 1 TO EN-PIG-IMMUNE(L-ROW)
         END-IF
         MOVE V6-TIME TO EN-ZOMBIFY(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM VILLAGER6-NBT-APPLY.
