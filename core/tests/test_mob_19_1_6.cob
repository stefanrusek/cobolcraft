*> Implementation test (US15; docs/protocol/19-mobs-land-friendly-and-neutral.md section 1.6): the variant of a new mob by the biome it spawns in
*> (wolf, frog, fox, pig, cow, chicken) and the shared variant of a spawn group.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-1-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-KEY                PIC X(48).
 01 WS-FLAGS              BINARY-LONG.
 01 WS-VARIANT            BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-CX                 BINARY-LONG.
 01 WS-CZ                 BINARY-LONG.
 01 WS-X                  BINARY-LONG.
 01 WS-Y                  BINARY-LONG.
 01 WS-Z                  BINARY-LONG.
 01 WS-CHUNK              BINARY-LONG.
 01 WS-ID                 BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-K                 BINARY-LONG.
 01 WS-J                 BINARY-LONG.
 01 WS-ROW2               BINARY-LONG.
 01 WS-CASES.
    05 FILLER PIC X(32) VALUE "21snowy_taiga".
    05 FILLER PIC X(32) VALUE "10desert".
    05 FILLER PIC X(32) VALUE "10jungle".
    05 FILLER PIC X(32) VALUE "00plains".
    05 FILLER PIC X(32) VALUE "01taiga".
    05 FILLER PIC X(32) VALUE "02deep_lukewarm_ocean".
    05 FILLER PIC X(32) VALUE "05end_highlands".
    05 FILLER PIC X(32) VALUE "10nether_wastes".
    05 FILLER PIC X(32) VALUE "21grove".
    05 FILLER PIC X(32) VALUE "01windswept_forest".
    05 FILLER PIC X(32) VALUE "10mangrove_swamp".
    05 FILLER PIC X(32) VALUE "02lukewarm_ocean".
    05 FILLER PIC X(32) VALUE "10badlands".
    05 FILLER PIC X(32) VALUE "10sparse_jungle".
    05 FILLER PIC X(32) VALUE "10savanna_plateau".
    05 FILLER PIC X(32) VALUE "00forest".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE-ROW        OCCURS 16 TIMES.
       10 WS-CASE-FLAGS   PIC 99.
       10 WS-CASE-KEY     PIC X(30).
 01 WS-WOLVES.
    05 FILLER PIC X(32) VALUE "0plains".
    05 FILLER PIC X(32) VALUE "1snowy_taiga".
    05 FILLER PIC X(32) VALUE "2old_growth_pine_taiga".
    05 FILLER PIC X(32) VALUE "3old_growth_spruce_taiga".
    05 FILLER PIC X(32) VALUE "4jungle".
    05 FILLER PIC X(32) VALUE "4bamboo_jungle".
    05 FILLER PIC X(32) VALUE "5grove".
    05 FILLER PIC X(32) VALUE "6savanna".
    05 FILLER PIC X(32) VALUE "6windswept_savanna".
    05 FILLER PIC X(32) VALUE "7badlands".
    05 FILLER PIC X(32) VALUE "7wooded_badlands".
    05 FILLER PIC X(32) VALUE "8forest".
 01 WS-WOLF-TABLE REDEFINES WS-WOLVES.
    05 WS-WOLF-ROW        OCCURS 12 TIMES.
       10 WS-WOLF-ID      PIC 9.
       10 WS-WOLF-KEY     PIC X(31).
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE SPACES TO WS-KEY
         MOVE WS-CASE-KEY(WS-I) TO WS-KEY
         CALL "M19-BIOME-FLAGS" USING WS-KEY WS-FLAGS
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 19§1.6 Variant selection: the biome tags of " DELIMITED BY SIZE WS-KEY DELIMITED BY SPACE INTO WS-CASE
         MOVE WS-CASE-FLAGS(WS-I) TO WS-E
         MOVE WS-FLAGS TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE SPACES TO WS-KEY
         MOVE WS-WOLF-KEY(WS-I) TO WS-KEY
         CALL "M19-WOLF-VARIANT" USING WS-KEY WS-VARIANT
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 19§1.6 Variant selection: the wolf variant of " DELIMITED BY SIZE WS-KEY DELIMITED BY SPACE INTO WS-CASE
         MOVE WS-WOLF-ID(WS-I) TO WS-E
         MOVE WS-VARIANT TO WS-O
         PERFORM CHECK-N
     END-PERFORM

     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-X = WS-X + 4000
     CALL "M19-BIOME-KEY-AT" USING WS-DIM WS-X WS-Y WS-Z WS-KEY
     MOVE "acceptance US15 19§1.6 Variant selection: a column that is not loaded has no biome key" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-KEY = SPACES
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   Every biome cell of the player's chunk becomes the snowy taiga (the registry id of its key).
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-CHUNK
*>   The test set carries few biomes: the registry gets the snowy taiga in a free row (id 99).
     MOVE "minecraft:snowy_taiga" TO CBI-KEY(100)
     MOVE 99 TO WS-ID
     MOVE "acceptance US15 19§1.6 Variant selection: the biome registry row of the snowy taiga is set up" TO WS-CASE
     MOVE 99 TO WS-E
     MOVE WS-ID TO WS-O
     PERFORM CHECK-N
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-CHUNK)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-BIOME-BYTES
         MOVE WS-ID TO CE-BIOME(WS-I)
     END-PERFORM
     CALL "M19-BIOME-KEY-AT" USING WS-DIM WS-X WS-Y WS-Z WS-KEY
     MOVE "acceptance US15 19§1.6 Variant selection: a loaded column gives the bare key of its biome" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-KEY = "snowy_taiga"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:wolf" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE "acceptance US15 19§1.6 Variant selection: a wolf born in the snowy taiga is ashen (1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-WOOL(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:frog" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
     MOVE "acceptance US15 19§1.6 Variant selection: a frog born in the snowy taiga is cold (1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:fox" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
     MOVE "acceptance US15 19§1.6 Variant selection: a fox born in the snowy taiga is a snow fox (1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:pig" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
     MOVE "acceptance US15 19§1.6 Variant selection: a pig born in the snowy taiga is cold (1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:cow" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
     MOVE "acceptance US15 19§1.6 Variant selection: a cow born in the snowy taiga is cold (1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:chicken" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
     MOVE "acceptance US15 19§1.6 Variant selection: a chicken born in the snowy taiga is cold (1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:sheep" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO WS-I
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 40
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
         IF FUNCTION MOD(EN-WOOL(WS-ROW2), 16) = 15
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§2.4 Sheep colour: a sheep born in a cold biome is mostly black (the cold configuration)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-I > 20
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "minecraft:desert" TO CBI-KEY(99)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > CE-BIOME-BYTES
         MOVE 98 TO CE-BIOME(WS-K)
     END-PERFORM
     MOVE 0 TO WS-I
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 40
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
         IF FUNCTION MOD(EN-WOOL(WS-ROW2), 16) = 12
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§2.4 Sheep colour: a sheep born in a warm biome is mostly brown (the warm configuration)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-I > 20
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "minecraft:frog" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
     MOVE "acceptance US15 19§1.6 Variant selection: a frog born in a desert is warm (2)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N
*>   A group shares the first member's variant (wolf, fox, llama); another species and an empty first row are left alone.
     MOVE 5 TO EN-WOOL(WS-ROW)
     MOVE "minecraft:wolf" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
     CALL "M19-PACK-SHARE" USING WS-ROW WS-ROW2
     MOVE "acceptance US15 19§6.1 Wolf pack: every wolf of a group takes the first wolf's variant" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO EN-WOOL(WS-ROW2)
     MOVE 0 TO WS-I
     CALL "M19-PACK-SHARE" USING WS-I WS-ROW2
     MOVE "acceptance US15 19§6.1 Wolf pack: the first wolf of a group keeps its own variant" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:pig" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
     MOVE 0 TO EN-WOOL(WS-ROW2)
     CALL "M19-PACK-SHARE" USING WS-ROW WS-ROW2
     MOVE "acceptance US15 19§1.6 Variant selection: farm animals do not share a variant in a group" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-1-6.
 COPY CORETEST.
 COPY MOBSPTEST.
