*> The saved fields of a villager (docs/protocol/44 section 3.2, 45-entity-nbt-6 section 7; lane 002-lane-p49h, T22006): VillagerData {type, profession, level},
*> VillagerDataFinalized, FoodLevel, Xp, LastRestock, LastGossipDecay, RestocksToday, in that order, after the keys of the mob chain. Offers, Inventory and Gossips are not written
*> (gaps: the offer table, the inventory items and the gossip table have no NBT writer yet). The state is VILSTATE.cpy.
*>   MOB-VILLAGER-WRITE USING row, PB-BUFFER      the keys of the villager of the row
*>   MOB-VILLAGER-APPLY USING row, MQ-DATA        the keys MOB-NBT-KEY collected become the state of the villager (a type of unknown name keeps plains)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-VILLAGER-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TYPES.
    05 FILLER              PIC X(16) VALUE "minecraft:desert".
    05 FILLER              PIC X(16) VALUE "minecraft:jungle".
    05 FILLER              PIC X(16) VALUE "minecraft:plains".
    05 FILLER              PIC X(16) VALUE "minecraft:savanna".
    05 FILLER              PIC X(16) VALUE "minecraft:snow".
    05 FILLER              PIC X(16) VALUE "minecraft:swamp".
    05 FILLER              PIC X(16) VALUE "minecraft:taiga".
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE-NAME        PIC X(16) OCCURS 7 TIMES.
 01 WS-TEXT                PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LONG                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE "VillagerData" TO WN MOVE 12 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "type" TO WN MOVE 4 TO WL
     COMPUTE WS-INDEX = FUNCTION MIN(FUNCTION MAX(VL-TYPE(WS-SLOT), 0), 6) + 1
     MOVE WS-TYPE-NAME(WS-INDEX) TO WS-TEXT
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-LENGTH
     MOVE "profession" TO WN MOVE 10 TO WL
     MOVE SPACES TO WS-TEXT
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(VL-PROF(WS-SLOT)) DELIMITED BY SIZE INTO WS-TEXT
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-LENGTH
     MOVE "level" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL VL-LEVEL(WS-SLOT)
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "VillagerDataFinalized" TO WN MOVE 21 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
     MOVE "FoodLevel" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL VL-FOOD(WS-SLOT)
     MOVE "Xp" TO WN MOVE 2 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL VL-XP(WS-SLOT)
     MOVE "LastRestock" TO WN MOVE 11 TO WL
     MOVE VL-LAST-RESTOCK(WS-SLOT) TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     MOVE "LastGossipDecay" TO WN MOVE 15 TO WL
     MOVE VL-LAST-DECAY(WS-SLOT) TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     MOVE "RestocksToday" TO WN MOVE 13 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL VL-RESTOCKS(WS-SLOT)
     GOBACK.
 END PROGRAM MOB-VILLAGER-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-VILLAGER-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TYPES.
    05 FILLER              PIC X(10) VALUE "desert".
    05 FILLER              PIC X(10) VALUE "jungle".
    05 FILLER              PIC X(10) VALUE "plains".
    05 FILLER              PIC X(10) VALUE "savanna".
    05 FILLER              PIC X(10) VALUE "snow".
    05 FILLER              PIC X(10) VALUE "swamp".
    05 FILLER              PIC X(10) VALUE "taiga".
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE-NAME        PIC X(10) OCCURS 7 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY ENMOBDATA.
 PROCEDURE DIVISION USING L-ROW MQ-DATA.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         IF MQ-VTYPE = WS-TYPE-NAME(WS-I)
             COMPUTE VL-TYPE(WS-SLOT) = WS-I - 1
         END-IF
     END-PERFORM
     MOVE MQ-FOOD TO VL-FOOD(WS-SLOT)
     MOVE MQ-VXP TO VL-XP(WS-SLOT)
     MOVE MQ-LAST-RESTOCK TO VL-LAST-RESTOCK(WS-SLOT)
     MOVE MQ-LAST-DECAY TO VL-LAST-DECAY(WS-SLOT)
     MOVE MQ-RESTOCKS TO VL-RESTOCKS(WS-SLOT)
     GOBACK.
 END PROGRAM MOB-VILLAGER-APPLY.
