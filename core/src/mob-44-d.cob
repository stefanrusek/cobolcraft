*> Variant entities of the animals with registry variants (002-lane-mobsa2; docs/protocol/19-mobs-land-friendly-and-neutral.md sections 1.3 and 1.6; 00 section 13.2).
*> The variant number of a row (EN-WOOL: wolf 0 pale, 1 ashen, 2 black, 3 chestnut, 4 rusty, 5 snowy, 6 spotted, 7 striped, 8 woods; frog, pig, cow and chicken 0 temperate, 1 cold, 2 warm)
*> is sent as a registry id: the position of the variant's file in the registry as loaded (the registry order is the loader's, so an id is looked up by the key, never fixed). A key the registry
*> lacks gives 0 (the built-in set holds one placeholder entry). Entries: wolf 23 (serializer 25), frog 18 (27), pig 19 (28), cow 18 (23), chicken 18 (30), all VarInt ids.
*>
*> Entry points:
*>   M44-VARIANT-KEY USING species key (PIC X(24)), variant number, bare variant key out (PIC X(48), spaces for a species without)
*>   M44-VARIANT-INDEX USING bare key, keys table (PIC X(48) OCCURS n, with namespace), count, id out
*>   M44-VARIANT-ID USING registry (PIC X(48), such as "wolf_variant"), bare key, id out (the loaded registry through CONTENT-REGISTRY-ENTRY)
*>   M44-VARIANT-DATA USING row, PB-BUFFER   the entry before the end marker (called by MOB-CARE-DATA)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-VARIANT-KEY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPECIES              PIC X(24).
 01 L-VARIANT              BINARY-LONG.
 01 L-KEY                  PIC X(48).
 PROCEDURE DIVISION USING L-SPECIES L-VARIANT L-KEY.
     MOVE SPACES TO L-KEY
     EVALUATE TRUE
         WHEN L-SPECIES = "wolf"
             EVALUATE L-VARIANT
                 WHEN 1 MOVE "ashen" TO L-KEY
                 WHEN 2 MOVE "black" TO L-KEY
                 WHEN 3 MOVE "chestnut" TO L-KEY
                 WHEN 4 MOVE "rusty" TO L-KEY
                 WHEN 5 MOVE "snowy" TO L-KEY
                 WHEN 6 MOVE "spotted" TO L-KEY
                 WHEN 7 MOVE "striped" TO L-KEY
                 WHEN 8 MOVE "woods" TO L-KEY
                 WHEN OTHER MOVE "pale" TO L-KEY
             END-EVALUATE
         WHEN L-SPECIES = "frog" OR "pig" OR "cow" OR "chicken"
             EVALUATE L-VARIANT
                 WHEN 1 MOVE "cold" TO L-KEY
                 WHEN 2 MOVE "warm" TO L-KEY
                 WHEN OTHER MOVE "temperate" TO L-KEY
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM M44-VARIANT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-VARIANT-INDEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FULL                PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-TABLE BASED.
    05 L-ENTRY             PIC X(48) OCCURS 256 TIMES.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-KEYS                 PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-KEYS L-COUNT L-ID.
     MOVE 0 TO L-ID
     SET ADDRESS OF WS-TABLE TO ADDRESS OF L-KEYS
     MOVE SPACES TO WS-FULL
     STRING "minecraft:" FUNCTION TRIM(L-KEY) DELIMITED BY SIZE INTO WS-FULL
     PERFORM VARYING WS-I FROM L-COUNT BY -1 UNTIL WS-I < 1
         IF L-ENTRY(WS-I) = WS-FULL
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M44-VARIANT-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-VARIANT-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REG                 PIC X(112).
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LIST.
    05 WS-ENTRY            PIC X(48) OCCURS 256 TIMES.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAYLOAD             PIC X(4096).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-KEY                  PIC X(48).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-KEY L-ID.
     MOVE 0 TO L-ID
     MOVE SPACES TO WS-REG
     MOVE L-REGISTRY TO WS-REG
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REG WS-COUNT WS-STATUS
     IF WS-COUNT > 256
         MOVE 256 TO WS-COUNT
     END-IF
     MOVE SPACES TO WS-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         COMPUTE WS-ID = WS-I - 1
         CALL "CONTENT-REGISTRY-ENTRY" USING WS-REG WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD WS-CAPACITY WS-LENGTH WS-STATUS
         MOVE WS-KEY TO WS-ENTRY(WS-I)
     END-PERFORM
     CALL "M44-VARIANT-INDEX" USING L-KEY WS-LIST WS-COUNT L-ID
     GOBACK.
 END PROGRAM M44-VARIANT-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-VARIANT-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==VD-==.
 01 WS-SPECIES             PIC X(24).
 01 WS-KEY                 PIC X(48).
 01 WS-REG                 PIC X(48).
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-SPECIES
     MOVE SPACES TO WS-REG
     INITIALIZE VD-METADATA-ENTRY-X
     EVALUATE WS-SPECIES
         WHEN "wolf"
             MOVE "wolf_variant" TO WS-REG
             MOVE 23 TO VD-MX-INDEX
             MOVE 25 TO VD-MX-SERIALIZER
         WHEN "frog"
             MOVE "frog_variant" TO WS-REG
             MOVE 18 TO VD-MX-INDEX
             MOVE 27 TO VD-MX-SERIALIZER
         WHEN "pig"
             MOVE "pig_variant" TO WS-REG
             MOVE 19 TO VD-MX-INDEX
             MOVE 28 TO VD-MX-SERIALIZER
         WHEN "cow"
             MOVE "cow_variant" TO WS-REG
             MOVE 18 TO VD-MX-INDEX
             MOVE 23 TO VD-MX-SERIALIZER
         WHEN "chicken"
             MOVE "chicken_variant" TO WS-REG
             MOVE 18 TO VD-MX-INDEX
             MOVE 30 TO VD-MX-SERIALIZER
     END-EVALUATE
     IF WS-REG NOT = SPACES
         CALL "M44-VARIANT-KEY" USING WS-SPECIES EN-WOOL(L-ROW) WS-KEY
         CALL "M44-VARIANT-ID" USING WS-REG WS-KEY WS-ID
         MOVE WS-ID TO VD-MX-INT
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER VD-METADATA-ENTRY-X
     END-IF
     GOBACK.
 END PROGRAM M44-VARIANT-DATA.
