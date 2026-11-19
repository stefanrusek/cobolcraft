*> Implementation test (lane p49v; docs/protocol/19-mobs-land-friendly-and-neutral.md section 4 Rabbit, 1.6): the variant of a rabbit at spawn by its biome
*> (white tag: r < 80 white else splotched; gold tag: gold; otherwise r < 50 brown, r < 90 salt, else black), the breeding variant (95 percent a parent's, 5 percent the
*> biome's), the killer bunny (variant 99: armor +8, attack damage +5, the name), the group sharing the first member's variant and the variant as entity data (index 18 INT).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CELLS.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-WHITE              BINARY-LONG.
 01 WS-GOLD               BINARY-LONG.
 01 WS-DRAW               BINARY-LONG.
 01 WS-VARIANT            BINARY-LONG.
 01 WS-COIN               BINARY-LONG.
 01 WS-ARMOR              BINARY-LONG.
 01 WS-DAMAGE             BINARY-LONG.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-CX                 BINARY-LONG.
 01 WS-CZ                 BINARY-LONG.
 01 WS-CHUNK              BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-N0                 BINARY-LONG.
 01 WS-N1                 BINARY-LONG.
 01 WS-N2                 BINARY-LONG.
 01 WS-N3                 BINARY-LONG.
 01 WS-N4                 BINARY-LONG.
 01 WS-N5                 BINARY-LONG.
 01 WS-NX                 BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-ROW2               BINARY-LONG.
 01 WS-BABY               BINARY-LONG.
 01 WS-WOOL               BINARY-LONG.
 01 WS-NEEDED             BINARY-LONG.
 01 WS-CAPACITY           BINARY-LONG VALUE 256.
 01 WS-EXPECT-LEN         BINARY-LONG.
 PROCEDURE DIVISION.
*>   The spawn variant by the draw r = nextInt(100) and the two biome tags.
     MOVE 0 TO WS-WHITE WS-GOLD
     MOVE 49 TO WS-DRAW
     PERFORM CHECK-SPAWN-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: no tag, r 49 is brown (0)" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 50 TO WS-DRAW
     PERFORM CHECK-SPAWN-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: no tag, r 50 is salt (5)" TO WS-CASE
     MOVE 5 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 89 TO WS-DRAW
     PERFORM CHECK-SPAWN-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: no tag, r 89 is salt (5)" TO WS-CASE
     MOVE 5 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 90 TO WS-DRAW
     PERFORM CHECK-SPAWN-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: no tag, r 90 is black (2)" TO WS-CASE
     MOVE 2 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 0 TO WS-DRAW
     PERFORM CHECK-SPAWN-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: no tag, r 0 is brown (0)" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 1 TO WS-WHITE
     MOVE 79 TO WS-DRAW
     PERFORM CHECK-SPAWN-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: white tag, r 79 is white (1)" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 80 TO WS-DRAW
     PERFORM CHECK-SPAWN-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: white tag, r 80 is white splotched (3)" TO WS-CASE
     MOVE 3 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 0 TO WS-WHITE
     MOVE 1 TO WS-GOLD
     MOVE 57 TO WS-DRAW
     PERFORM CHECK-SPAWN-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: gold tag is gold (4) whatever r is" TO WS-CASE
     MOVE 4 TO WS-E
     PERFORM CHECK-VARIANT

*>   The breeding variant: nextInt(20) != 0 takes a parent's variant by the coin, the remaining 5 percent keeps the biome's.
     MOVE 0 TO WS-DRAW WS-COIN
     MOVE 1 TO WS-I
     MOVE 2 TO WS-J
     MOVE 4 TO WS-ARMOR
     CALL "RABBIT-BRED-VARIANT" USING WS-I WS-DRAW WS-COIN WS-J WS-ARMOR WS-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: a draw of 0 keeps the biome's variant (1)" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 7 TO WS-DRAW
     CALL "RABBIT-BRED-VARIANT" USING WS-I WS-DRAW WS-COIN WS-J WS-ARMOR WS-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: another draw and coin 0 takes the first parent's variant (2)" TO WS-CASE
     MOVE 2 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 1 TO WS-COIN
     CALL "RABBIT-BRED-VARIANT" USING WS-I WS-DRAW WS-COIN WS-J WS-ARMOR WS-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: coin 1 takes the other parent's variant (4)" TO WS-CASE
     MOVE 4 TO WS-E
     PERFORM CHECK-VARIANT
     MOVE 19 TO WS-DRAW
     CALL "RABBIT-BRED-VARIANT" USING WS-I WS-DRAW WS-COIN WS-J WS-ARMOR WS-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: a draw of 19 still takes a parent's variant (4)" TO WS-CASE
     MOVE 4 TO WS-E
     PERFORM CHECK-VARIANT

*>   The killer bunny: armor +8 and attack damage +5 at variant 99, nothing for any other variant.
     MOVE 99 TO WS-VARIANT
     CALL "RABBIT-EVIL" USING WS-VARIANT WS-ARMOR WS-DAMAGE
     MOVE "acceptance US15 19§4 Rabbit: the killer bunny has armor +8" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE WS-ARMOR TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: the killer bunny has attack damage +5" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-DAMAGE TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-VARIANT
     CALL "RABBIT-EVIL" USING WS-VARIANT WS-ARMOR WS-DAMAGE
     MOVE "acceptance US15 19§4 Rabbit: any other variant has no modifier" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-ARMOR + WS-DAMAGE
     PERFORM CHECK-N

*>   In a world: the biome of the spawn cell decides the variant.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-CHUNK
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-CHUNK)
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:rabbit" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:snowy_taiga" TO CBI-KEY(100)
     MOVE "minecraft:desert" TO CBI-KEY(101)
     MOVE "minecraft:plains" TO CBI-KEY(102)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-BIOME-BYTES
         MOVE 99 TO CE-BIOME(WS-I)
     END-PERFORM
     MOVE 0 TO WS-N0 WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-NX
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 60
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
         PERFORM COUNT-VARIANT
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 19§4 Rabbit: in the snowy taiga every rabbit is white or splotched, most are white" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-N1 + WS-N3 = 60 AND WS-N1 > WS-N3 AND WS-N3 > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-BIOME-BYTES
         MOVE 100 TO CE-BIOME(WS-I)
     END-PERFORM
     MOVE 0 TO WS-N0 WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-NX
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 20
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
         PERFORM COUNT-VARIANT
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 19§4 Rabbit: in the desert every rabbit is gold" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE WS-N4 TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-BIOME-BYTES
         MOVE 101 TO CE-BIOME(WS-I)
     END-PERFORM
     MOVE 0 TO WS-N0 WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-NX
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 90
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
         PERFORM COUNT-VARIANT
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 19§4 Rabbit: in plains the rabbits are brown, salt or black and all three occur" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-N0 + WS-N5 + WS-N2 = 90 AND WS-N0 > 0 AND WS-N5 > 0 AND WS-N2 > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N

*>   A group shares the first member's variant.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW2
     MOVE 4 TO EN-WOOL(WS-ROW)
     MOVE 0 TO EN-WOOL(WS-ROW2)
     CALL "M19-PACK-SHARE" USING WS-ROW WS-ROW2
     MOVE "acceptance US15 19§4 Rabbit: a group spawn reuses the first member's variant" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N

*>   The variant is entity data: index 18 INT, sent when it is not the default brown.
     MOVE 0 TO EN-WOOL(WS-ROW) EN-VARIANT(WS-ROW)
     CALL "MOB-DATA-VALUES" USING WS-ROW WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§4 Rabbit: an adult brown rabbit needs no entity data" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-NEEDED TO WS-O
     PERFORM CHECK-N
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
     MOVE 5 TO WS-EXPECT-LEN
     PERFORM ADD-ID-LENGTH
     MOVE "acceptance US15 19§4 Rabbit: a brown rabbit sends the baby entry and the end marker only" TO WS-CASE
     MOVE WS-EXPECT-LEN TO WS-E
     MOVE TP-LENGTH TO WS-O
     PERFORM CHECK-N
     CALL "PB-FREE" USING TP-BUFFER
     MOVE 99 TO EN-WOOL(WS-ROW)
     CALL "MOB-DATA-VALUES" USING WS-ROW WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§4 Rabbit: a killer bunny needs entity data" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-NEEDED TO WS-O
     PERFORM CHECK-N
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
     MOVE 8 TO WS-EXPECT-LEN
     PERFORM ADD-ID-LENGTH
     MOVE "acceptance US15 19§4 Rabbit: a killer bunny sends baby, variant 18 (3 bytes) and the end marker" TO WS-CASE
     MOVE WS-EXPECT-LEN TO WS-E
     MOVE TP-LENGTH TO WS-O
     PERFORM CHECK-N
     CALL "PB-FREE" USING TP-BUFFER

*>   Setting the variant 99 names an unnamed rabbit "Killer Bunny"; a named one keeps its name.
     MOVE 0 TO EN-CNAME-LEN(WS-ROW2)
     MOVE 99 TO WS-VARIANT
     CALL "RABBIT-SET-VARIANT" USING WS-ROW2 WS-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: variant 99 gives an unnamed rabbit the name Killer Bunny" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-CNAME-LEN(WS-ROW2) = 12 AND EN-CNAME(WS-ROW2)(1:12) = "Killer Bunny" AND EN-WOOL(WS-ROW2) = 99
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE SPACES TO EN-CNAME(WS-ROW2)
     MOVE "Thumper" TO EN-CNAME(WS-ROW2)
     MOVE 7 TO EN-CNAME-LEN(WS-ROW2)
     CALL "RABBIT-SET-VARIANT" USING WS-ROW2 WS-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: a named rabbit keeps its name when it becomes a killer bunny" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-CNAME-LEN(WS-ROW2) = 7 AND EN-CNAME(WS-ROW2)(1:7) = "Thumper"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 1 TO WS-VARIANT
     CALL "RABBIT-SET-VARIANT" USING WS-ROW2 WS-VARIANT
     MOVE "acceptance US15 19§4 Rabbit: setting another variant stores it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-WOOL(WS-ROW2) TO WS-O
     PERFORM CHECK-N

*>   Breeding two rabbits: a baby with a variant of a parent (or, 5 percent, the biome's: plains here, 0, 5 or 2).
     MOVE 4 TO EN-WOOL(WS-ROW)
     MOVE 3 TO EN-WOOL(WS-ROW2)
     CALL "MOB-BREED" USING WS-ROW WS-ROW2
     MOVE 0 TO WS-BABY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND WS-I NOT = WS-ROW AND WS-I NOT = WS-ROW2
             MOVE WS-I TO WS-BABY
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§4 Rabbit: the baby of rabbits 4 and 3 has a variant of the parents or of its biome" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-BABY > 0
         IF EN-VARIANT(WS-BABY) = 1 AND (EN-WOOL(WS-BABY) = 4 OR 3 OR 0 OR 5 OR 2)
             MOVE 1 TO WS-O
         END-IF
     END-IF
     PERFORM CHECK-N
     STOP RUN.

 CHECK-SPAWN-VARIANT.
     CALL "RABBIT-SPAWN-VARIANT" USING WS-WHITE WS-GOLD WS-DRAW WS-VARIANT.

 CHECK-VARIANT.
     MOVE WS-VARIANT TO WS-O
     PERFORM CHECK-N.

 COUNT-VARIANT.
     EVALUATE EN-WOOL(WS-ROW)
         WHEN 0 ADD 1 TO WS-N0
         WHEN 1 ADD 1 TO WS-N1
         WHEN 2 ADD 1 TO WS-N2
         WHEN 3 ADD 1 TO WS-N3
         WHEN 4 ADD 1 TO WS-N4
         WHEN 5 ADD 1 TO WS-N5
         WHEN OTHER ADD 1 TO WS-NX
     END-EVALUATE.

 ADD-ID-LENGTH.
     IF EN-ID(WS-ROW) < 128
         ADD 1 TO WS-EXPECT-LEN
     ELSE
         ADD 2 TO WS-EXPECT-LEN
     END-IF.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-4.
 COPY CORETEST.
 COPY MOBSPTEST.
