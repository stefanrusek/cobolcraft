*> Rabbit (lane p49v; docs/protocol/19-mobs-land-friendly-and-neutral.md section 4). The variant is EN-WOOL (metadata 18 INT): 0 brown, 1 white, 2 black, 3 white splotched,
*> 4 gold, 5 salt, 99 killer bunny.
*>   RABBIT-SPAWN-VARIANT USING white tag, gold tag, draw (0 to 99), variant out     the variant of a new rabbit by its biome
*>   RABBIT-BRED-VARIANT USING biome variant, draw (0 to 19), coin, variant a, variant b, variant out     the foal's variant
*>   RABBIT-EVIL USING variant, armor out, damage out                                the killer bunny's attribute modifiers
*>   RABBIT-SET-VARIANT USING row, variant                                          stores a variant (99 names an unnamed rabbit)
*>   RABBIT-BORN USING row                                                          the variant of a rabbit that has just been spawned
*>   RABBIT-BRED USING parent a, parent b, baby, coin                               the foal's variant after the biome's
*>   MOB-RABBIT-DATA USING row, PB-BUFFER                                           index 18 INT before the end marker
 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-SPAWN-VARIANT.
*> A biome in spawns_white_rabbits: r < 80 white (1), else white splotched (3); in spawns_gold_rabbits: gold (4); otherwise r < 50 brown (0), r < 90 salt (5), else black (2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WHITE                BINARY-LONG.
 01 L-GOLD                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-VARIANT              BINARY-LONG.
 PROCEDURE DIVISION USING L-WHITE L-GOLD L-DRAW L-VARIANT.
     EVALUATE TRUE
         WHEN L-WHITE = 1 AND L-DRAW < 80
             MOVE 1 TO L-VARIANT
         WHEN L-WHITE = 1
             MOVE 3 TO L-VARIANT
         WHEN L-GOLD = 1
             MOVE 4 TO L-VARIANT
         WHEN L-DRAW < 50
             MOVE 0 TO L-VARIANT
         WHEN L-DRAW < 90
             MOVE 5 TO L-VARIANT
         WHEN OTHER
             MOVE 2 TO L-VARIANT
     END-EVALUATE
     GOBACK.
 END PROGRAM RABBIT-SPAWN-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-BRED-VARIANT.
*> The foal first has the biome variant of its birth position; nextInt(20) != 0 (95 percent) then takes a parent's variant, the coin choosing the first parent (0) or the other one (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BIOME                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-VARIANT              BINARY-LONG.
 PROCEDURE DIVISION USING L-BIOME L-DRAW L-COIN L-A L-B L-VARIANT.
     MOVE L-BIOME TO L-VARIANT
     IF L-DRAW NOT = 0
         MOVE L-A TO L-VARIANT
         IF L-COIN = 1
             MOVE L-B TO L-VARIANT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RABBIT-BRED-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-EVIL.
*> Variant 99, the killer bunny: armor base +8 and an attack-damage modifier of +5 (ADD_VALUE); any other variant has neither.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VARIANT              BINARY-LONG.
 01 L-ARMOR                BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-VARIANT L-ARMOR L-DAMAGE.
     MOVE 0 TO L-ARMOR L-DAMAGE
     IF L-VARIANT = 99
         MOVE 8 TO L-ARMOR
         MOVE 5 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM RABBIT-EVIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-SET-VARIANT.
*> Setting the variant 99 gives an unnamed rabbit the custom name Killer Bunny; a named one keeps its name.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VARIANT              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-VARIANT.
     MOVE L-VARIANT TO EN-WOOL(L-ROW)
     IF L-VARIANT = 99 AND EN-CNAME-LEN(L-ROW) = 0
         MOVE SPACES TO EN-CNAME(L-ROW)
         MOVE "Killer Bunny" TO EN-CNAME(L-ROW)(1:12)
         MOVE 12 TO EN-CNAME-LEN(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM RABBIT-SET-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-BIOME-VARIANT.
*> USING row, variant out: the biome variant of the cell the rabbit stands in (RABBIT-SPAWN-VARIANT with the white tag of the snowy biomes and the gold tag of the desert).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-BIOME               PIC X(48).
 01 WS-TAGS                BINARY-LONG.
 01 WS-WHITE               BINARY-LONG.
 01 WS-GOLD                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 5201.
 01 WS-BOUND               BINARY-LONG VALUE 100.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VARIANT              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-VARIANT.
     COMPUTE WS-IX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-IY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-IZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "M19-BIOME-KEY-AT" USING EN-DIM(L-ROW) WS-IX WS-IY WS-IZ WS-BIOME
     CALL "M19-BIOME-FLAGS" USING WS-BIOME WS-TAGS
     COMPUTE WS-WHITE = FUNCTION MOD(FUNCTION INTEGER(WS-TAGS / 16), 2)
     MOVE 0 TO WS-GOLD
     IF WS-BIOME = "desert"
         MOVE 1 TO WS-GOLD
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     CALL "RABBIT-SPAWN-VARIANT" USING WS-WHITE WS-GOLD WS-DRAW L-VARIANT
     GOBACK.
 END PROGRAM RABBIT-BIOME-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-BORN.
*> USING row: a new rabbit takes the variant of its biome (a group then shares the first member's, M19-PACK-SHARE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VARIANT             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "RABBIT-BIOME-VARIANT" USING L-ROW WS-VARIANT
     CALL "RABBIT-SET-VARIANT" USING L-ROW WS-VARIANT
     GOBACK.
 END PROGRAM RABBIT-BORN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-BRED.
*> USING parent a, parent b, baby, coin: the baby already has the biome variant of its position (RABBIT-BORN); 95 percent of foals take a parent's instead.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 5202.
 01 WS-BOUND               BINARY-LONG VALUE 20.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-VARIANT             BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-BABY L-COIN.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     MOVE EN-WOOL(L-BABY) TO WS-BIOME
     MOVE EN-WOOL(L-A) TO WS-A
     MOVE EN-WOOL(L-B) TO WS-B
     CALL "RABBIT-BRED-VARIANT" USING WS-BIOME WS-DRAW L-COIN WS-A WS-B WS-VARIANT
     CALL "RABBIT-SET-VARIANT" USING L-BABY WS-VARIANT
     GOBACK.
 END PROGRAM RABBIT-BRED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RABBIT-DATA.
*> USING row, PB-BUFFER: the variant of a rabbit (index 18 INT, 19 section 4), sent when it is not the default brown.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==RD-==.
 01 WS-KEY                 PIC X(24).
 01 WS-SERIALIZER-INT      BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "rabbit" AND EN-WOOL(L-ROW) > 0
         INITIALIZE RD-METADATA-ENTRY-X
         MOVE 18 TO RD-MX-INDEX
         MOVE WS-SERIALIZER-INT TO RD-MX-SERIALIZER
         MOVE EN-WOOL(L-ROW) TO RD-MX-INT
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER RD-METADATA-ENTRY-X
     END-IF
     GOBACK.
 END PROGRAM MOB-RABBIT-DATA.
