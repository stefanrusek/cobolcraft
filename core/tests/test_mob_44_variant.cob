*> Implementation test (US15; docs/protocol/19-mobs-land-friendly-and-neutral.md sections 1.3 and 1.6): the variant entry of wolf (23), frog (18), pig (19), cow (18) and chicken (18) with the id from the registry order.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-VARIANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-D2                 FLOAT-LONG.
 01 WS-WALK               BINARY-LONG.
 01 WS-CLEAR              BINARY-LONG.
 01 WS-DX                 FLOAT-LONG.
 01 WS-DY                 FLOAT-LONG.
 01 WS-DZ                 FLOAT-LONG.
 01 WS-STARTED            BINARY-LONG.
 01 WS-ALIVE              BINARY-LONG.
 01 WS-CONT               BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-LEN0               BINARY-LONG.
 01 WS-CAPACITY           BINARY-LONG VALUE 256.
 01 WS-KEYS.
    05 WS-KEY-ENTRY         PIC X(48) OCCURS 9 TIMES.
 01 WS-REG                PIC X(48).
 01 WS-SPECIES            PIC X(24).
 01 WS-VAR                BINARY-LONG.
 01 WS-VKEY               PIC X(48).
 01 WS-ID                 BINARY-LONG.
 01 WS-N                  BINARY-LONG VALUE 9.
 01 WS-WANT               PIC X(48).
 01 WS-EXPECT-LEN         BINARY-LONG.

 PROCEDURE DIVISION.
*>   The fixture registry: the wolf_variant files in the order a registry loads them (by name).
     MOVE "minecraft:ashen" TO WS-KEY-ENTRY(1)
     MOVE "minecraft:black" TO WS-KEY-ENTRY(2)
     MOVE "minecraft:chestnut" TO WS-KEY-ENTRY(3)
     MOVE "minecraft:pale" TO WS-KEY-ENTRY(4)
     MOVE "minecraft:rusty" TO WS-KEY-ENTRY(5)
     MOVE "minecraft:snowy" TO WS-KEY-ENTRY(6)
     MOVE "minecraft:spotted" TO WS-KEY-ENTRY(7)
     MOVE "minecraft:striped" TO WS-KEY-ENTRY(8)
     MOVE "minecraft:woods" TO WS-KEY-ENTRY(9)
     MOVE "pale" TO WS-WANT
     CALL "M44-VARIANT-INDEX" USING WS-WANT WS-KEYS WS-N WS-ID
     MOVE "acceptance US15 19§1.3 Variant id: pale is the fourth file, id 3" TO WS-CASE
     MOVE WS-ID TO WS-O
     MOVE 3 TO WS-E
     PERFORM CHECK-N
     MOVE "woods" TO WS-WANT
     CALL "M44-VARIANT-INDEX" USING WS-WANT WS-KEYS WS-N WS-ID
     MOVE "acceptance US15 19§1.3 Variant id: woods is the last file, id 8" TO WS-CASE
     MOVE WS-ID TO WS-O
     MOVE 8 TO WS-E
     PERFORM CHECK-N
     MOVE "nothing" TO WS-WANT
     CALL "M44-VARIANT-INDEX" USING WS-WANT WS-KEYS WS-N WS-ID
     MOVE "acceptance US15 19§1.3 Variant id: a key the registry lacks gives id 0" TO WS-CASE
     MOVE WS-ID TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
*>   The key of a variant number per species.
     MOVE "wolf" TO WS-SPECIES
     MOVE 4 TO WS-VAR
     CALL "M44-VARIANT-KEY" USING WS-SPECIES WS-VAR WS-VKEY
     MOVE "acceptance US15 19§1.6 Variant key: wolf 4 is rusty" TO WS-CASE
     IF WS-VKEY = "rusty" MOVE 1 TO WS-O ELSE MOVE 0 TO WS-O END-IF
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-VAR
     CALL "M44-VARIANT-KEY" USING WS-SPECIES WS-VAR WS-VKEY
     MOVE "acceptance US15 19§1.6 Variant key: wolf 0 is pale" TO WS-CASE
     IF WS-VKEY = "pale" MOVE 1 TO WS-O ELSE MOVE 0 TO WS-O END-IF
     PERFORM CHECK-N
     MOVE "frog" TO WS-SPECIES
     MOVE 2 TO WS-VAR
     CALL "M44-VARIANT-KEY" USING WS-SPECIES WS-VAR WS-VKEY
     MOVE "acceptance US15 19§1.6 Variant key: frog 2 is warm" TO WS-CASE
     IF WS-VKEY = "warm" MOVE 1 TO WS-O ELSE MOVE 0 TO WS-O END-IF
     PERFORM CHECK-N
     MOVE "cow" TO WS-SPECIES
     MOVE 1 TO WS-VAR
     CALL "M44-VARIANT-KEY" USING WS-SPECIES WS-VAR WS-VKEY
     MOVE "acceptance US15 19§1.6 Variant key: cow 1 is cold" TO WS-CASE
     IF WS-VKEY = "cold" MOVE 1 TO WS-O ELSE MOVE 0 TO WS-O END-IF
     PERFORM CHECK-N
     MOVE "pig" TO WS-SPECIES
     MOVE 0 TO WS-VAR
     CALL "M44-VARIANT-KEY" USING WS-SPECIES WS-VAR WS-VKEY
     MOVE "acceptance US15 19§1.6 Variant key: pig 0 is temperate" TO WS-CASE
     IF WS-VKEY = "temperate" MOVE 1 TO WS-O ELSE MOVE 0 TO WS-O END-IF
     PERFORM CHECK-N
*>   The loaded registry of the open world (the built-in set holds one placeholder entry): every key is unknown there, id 0.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "wolf_variant" TO WS-REG
     MOVE "ashen" TO WS-WANT
     CALL "M44-VARIANT-ID" USING WS-REG WS-WANT WS-ID
     MOVE "acceptance US15 19§1.3 Variant id: the loaded built-in registry has no ashen file: id 0" TO WS-CASE
     MOVE WS-ID TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:wolf" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 0 TO EN-TAMED(WS-ROW) EN-COLLAR(WS-ROW)
     MOVE 0 TO EN-VARIANT(WS-ROW)
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
*>   Packet id (1 byte), entity id (1 or 2), baby entry 3, variant entry 3, end 1.
     MOVE 11 TO WS-EXPECT-LEN
     IF EN-ID(WS-ROW) < 128
         ADD 1 TO WS-EXPECT-LEN
     ELSE
         ADD 2 TO WS-EXPECT-LEN
     END-IF
     MOVE "acceptance US15 19§1.3 Variant entry: a wild wolf sends baby (3), variant 23 (3), sound variant 24 (3) and the end marker" TO WS-CASE
     MOVE TP-LENGTH TO WS-O
     MOVE WS-EXPECT-LEN TO WS-E
     PERFORM CHECK-N
     CALL "PB-FREE" USING TP-BUFFER
     MOVE "minecraft:cow" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
     MOVE "acceptance US15 19§1.3 Variant entry: a cow sends baby, variant 18, sound variant 19 and the end marker" TO WS-CASE
     MOVE 11 TO WS-EXPECT-LEN
     IF EN-ID(WS-ROW) < 128
         ADD 1 TO WS-EXPECT-LEN
     ELSE
         ADD 2 TO WS-EXPECT-LEN
     END-IF
     MOVE TP-LENGTH TO WS-O
     MOVE WS-EXPECT-LEN TO WS-E
     PERFORM CHECK-N
     CALL "PB-FREE" USING TP-BUFFER
*>   Pig, chicken, frog and cat rows build their entries too (each adds the variant, the sound variant for all but the frog, and the cat only the sound one).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:pig" TO WS-EKEY
             WHEN 2 MOVE "minecraft:chicken" TO WS-EKEY
             WHEN 3 MOVE "minecraft:frog" TO WS-EKEY
             WHEN OTHER MOVE "minecraft:cat" TO WS-EKEY
         END-EVALUATE
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
         CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
         CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
         MOVE "acceptance US15 19§1.3 Variant entry: pig, chicken, frog and cat rows send more than the baby entry and the end marker" TO WS-CASE
         MOVE 0 TO WS-O
         IF TP-LENGTH >= 9
             MOVE 1 TO WS-O
         END-IF
         MOVE 1 TO WS-E
         PERFORM CHECK-N
         CALL "PB-FREE" USING TP-BUFFER
     END-PERFORM
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-44-VARIANT.
 COPY CORETEST.
 COPY MOBSPTEST.
