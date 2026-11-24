*> Donkey and mule chests (docs/protocol/19-mobs-land-friendly-and-neutral.md section 3.5 step 5 and 3.6, 45-4 section 6.5, 21 appendix metadata of the donkey). Wrap C round 6, T52093.
*> The chest flag is WC-CHEST of core/copy/WCSTATE.cpy. Open: the chest inventory (15 slots, the mount screen of 40 part 6), the equip sound, the chest item dropping with the animal.
*>   MOB-EQUINE-USE USING player row, entity row, held key (PIC X(24)), handled out   equipChest: a chest item in the main hand of a player on a tamed adult donkey or mule that has no chest
*>   MOB-EQUINE-DATA USING row, PB-BUFFER                                             the equine entries of Set Entity Data: index 18 BYTE flags (2 tamed), index 19 BOOLEAN chest

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-EQUINE-USE.
*> A tamed adult donkey or mule without a chest takes a chest item: the chest flag is set, one item is used (not in creative mode) and the viewers get Set Entity Data.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HELD                 PIC X(24).
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ENTITY L-HELD L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-KEY
     IF (WS-KEY = "donkey" OR "mule" OR "llama" OR "trader_llama") AND L-HELD = "chest" AND EN-TAMED(L-ENTITY) = 1 AND EN-MOBAGE(L-ENTITY) >= 0
         CALL "WC-ROW-OPEN" USING L-ENTITY
         IF WC-CHEST(L-ENTITY) = 0
             MOVE 1 TO WC-CHEST(L-ENTITY)
             CALL "MOB-TAKE" USING L-PLAYER
             CALL "MOB-DATA-SEND" USING L-ENTITY
             MOVE 1 TO L-HANDLED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-EQUINE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-EQUINE-DATA.
*> The flags byte (index 18) of a tamed horse, donkey or mule carries the tamed flag 2 (19 section 3.1); a donkey or mule with a chest also sends index 19 BOOLEAN true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==EQ-==.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF (WS-KEY = "horse" OR "donkey" OR "mule") AND EN-TAMED(L-ROW) = 1
         INITIALIZE EQ-METADATA-ENTRY
         MOVE 18 TO EQ-MD-INDEX
         MOVE EQ-MDS-BYTE TO EQ-MD-SERIALIZER
         MOVE 2 TO EQ-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER EQ-METADATA-ENTRY
     END-IF
     IF WS-KEY = "donkey" OR "mule" OR "llama" OR "trader_llama"
         CALL "WC-ROW-OPEN" USING L-ROW
         IF WC-CHEST(L-ROW) = 1
             INITIALIZE EQ-METADATA-ENTRY
             MOVE 19 TO EQ-MD-INDEX
             MOVE EQ-MDS-BOOLEAN TO EQ-MD-SERIALIZER
             MOVE 1 TO EQ-MD-INT
             CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER EQ-METADATA-ENTRY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-EQUINE-DATA.
