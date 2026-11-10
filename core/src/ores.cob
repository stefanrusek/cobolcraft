*> The ores of the standard overworld (docs/protocol/11 sections 6 to 8; T0431; ORE.cpy): decoration seeding over a Xoroshiro wrapped
*> WorldgenRandom (4), the placed feature table of 8.2, the ore blob (7.1 to 7.3) and the ore stage of the generation job.
*>
*> The stage generates one chunk T from the decoration of the 3 x 3 chunks around it: step GJ-SUB (0 to 269) is the chunk C
*> (GJ-SUB div 30, row-major from the north-west one) and the placed feature GJ-SUB mod 30 of OT-ROW. The positions are drawn from the
*> seeds of C (6.1), so a blob crossing the border of two chunks is the same blob whichever of them is generated; only the blocks
*> inside T are written (6.5). Deviations from the document: the feature indices of 6.1 are the table's own (OT-IDX: the order of
*> 6.2 with the biome extras spliced next to their neighbours, Open question 2 of document 11), the biome filter reads the stored
*> biome cell (the biome source's cell outside T) instead of the fuzzy zoom, blocks outside T count as not air in the air exposure
*> test, and a blob whose first column lies outside T always passes the heightmap column test (7.1 step 5).
*>
*> Entry points:
*>   WGR-SET-SEED USING state (XORO.cpy), seed (u64); WGR-NEXT USING state, bits, result (BINARY-DOUBLE); WGR-NEXT-INT-BOUND USING
*>     state, bound, result (BINARY-LONG); WGR-NEXT-FLOAT USING state, result (FLOAT-LONG); WGR-NEXT-DOUBLE (same); WGR-NEXT-LONG USING
*>     state, result (u64): the WorldgenRandom of 4 over a Xoroshiro source (next(bits) = high bits of nextLong)
*>   ORE-DECOR-SEED USING world seed, block x, block z (BINARY-LONG), state out, seed out: setDecorationSeed
*>   ORE-FEATURE-SEED USING decoration seed, feature index, step, seed out: setFeatureSeed
*>   ORE-TABLE-BUILD: fills OT-TABLE
*>   ORE-HEIGHT USING state, kind (1 uniform, 2 triangle), low, high, y out: the height provider of 4
*>   ORE-BIOME-OK USING limit, biome key (PIC X(40)), flag out
*>   ORE-BLOB-GEOM USING size, x, y, z (BINARY-LONG), angle (FLOAT-LONG), y draw 1, y draw 2: OB-X0 to OB-RR of 7.1
*>   ORE-PLACE-BLOB USING job, state, row, x, y, z: the blob of one placed feature row at a position (OB-PLACED the blocks placed)
*>   GEN-STAGE-ORES USING job: step GJ-SUB of the ore stage

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WGR-SET-SEED.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-STATE L-SEED.
     CALL "XORO-SEED" USING L-SEED L-STATE
     GOBACK.
 END PROGRAM WGR-SET-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WGR-NEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LONG                BINARY-DOUBLE UNSIGNED.
 01 WS-POW                 BINARY-DOUBLE UNSIGNED.
 01 WS-SHIFT               BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-BITS                 BINARY-LONG.
 01 L-RESULT               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-STATE L-BITS L-RESULT.
     CALL "XORO-NEXT-LONG" USING L-STATE WS-LONG
     COMPUTE WS-SHIFT = 64 - L-BITS
     COMPUTE WS-POW = 2 ** WS-SHIFT
     COMPUTE L-RESULT = FUNCTION INTEGER(WS-LONG / WS-POW)
     IF L-BITS = 32 AND L-RESULT >= 2147483648
         SUBTRACT 4294967296 FROM L-RESULT
     END-IF
     GOBACK.
 END PROGRAM WGR-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WGR-NEXT-INT-BOUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS                BINARY-LONG VALUE 31.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-VAL                 BINARY-DOUBLE.
 01 WS-POW                 BINARY-DOUBLE.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-BOUND                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BOUND L-RESULT.
     MOVE 1 TO WS-POW
     PERFORM UNTIL WS-POW >= L-BOUND
         COMPUTE WS-POW = WS-POW * 2
     END-PERFORM
     IF WS-POW = L-BOUND
         CALL "WGR-NEXT" USING L-STATE WS-BITS WS-R
         COMPUTE L-RESULT = FUNCTION INTEGER((L-BOUND * WS-R) / 2147483648)
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         CALL "WGR-NEXT" USING L-STATE WS-BITS WS-R
         COMPUTE WS-VAL = FUNCTION MOD(WS-R, L-BOUND)
         IF WS-R - WS-VAL + (L-BOUND - 1) < 2147483648
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     MOVE WS-VAL TO L-RESULT
     GOBACK.
 END PROGRAM WGR-NEXT-INT-BOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WGR-NEXT-FLOAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS                BINARY-LONG VALUE 24.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-F                   FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 16777216.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     CALL "WGR-NEXT" USING L-STATE WS-BITS WS-R
     MOVE WS-R TO WS-F
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-F WS-SCALE L-RESULT
     GOBACK.
 END PROGRAM WGR-NEXT-FLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WGR-NEXT-DOUBLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B26                 BINARY-LONG VALUE 26.
 01 WS-B27                 BINARY-LONG VALUE 27.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-LO                  BINARY-DOUBLE.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-F                   FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 9007199254740992.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     CALL "WGR-NEXT" USING L-STATE WS-B26 WS-HI
     CALL "WGR-NEXT" USING L-STATE WS-B27 WS-LO
     COMPUTE WS-SUM = WS-HI * 134217728 + WS-LO
     MOVE WS-SUM TO WS-F
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-F WS-SCALE L-RESULT
     GOBACK.
 END PROGRAM WGR-NEXT-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WGR-NEXT-LONG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-BITS                BINARY-LONG VALUE 32.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-LO                  BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     CALL "WGR-NEXT" USING L-STATE WS-BITS WS-HI
     CALL "WGR-NEXT" USING L-STATE WS-BITS WS-LO
     COMPUTE L-RESULT = FUNCTION MOD(WS-HI * 4294967296 + WS-LO, WS-M64)
     GOBACK.
 END PROGRAM WGR-NEXT-LONG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-DECOR-SEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-A                   BINARY-DOUBLE UNSIGNED.
 01 WS-B                   BINARY-DOUBLE UNSIGNED.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-ODD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-BX                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-OUT                  BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-SEED L-BX L-BZ L-STATE L-OUT.
     CALL "WGR-SET-SEED" USING L-STATE L-SEED
     CALL "WGR-NEXT-LONG" USING L-STATE WS-A
     CALL "WGR-NEXT-LONG" USING L-STATE WS-B
     COMPUTE WS-ODD = FUNCTION MOD(WS-A, 2)
     IF WS-ODD = 0
         ADD 1 TO WS-A
     END-IF
     COMPUTE WS-ODD = FUNCTION MOD(WS-B, 2)
     IF WS-ODD = 0
         ADD 1 TO WS-B
     END-IF
     COMPUTE WS-R = FUNCTION MOD(L-BX * WS-A + L-BZ * WS-B, WS-M64)
     CALL "CBL_XOR" USING L-SEED WS-R BY VALUE 8
     CALL "WGR-SET-SEED" USING L-STATE WS-R
     MOVE WS-R TO L-OUT
     GOBACK.
 END PROGRAM ORE-DECOR-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-FEATURE-SEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 LINKAGE SECTION.
 01 L-DECOR                BINARY-DOUBLE UNSIGNED.
 01 L-INDEX                BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-OUT                  BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-DECOR L-INDEX L-STEP L-OUT.
     COMPUTE L-OUT = FUNCTION MOD(L-DECOR + L-INDEX + 10000 * L-STEP, WS-M64)
     GOBACK.
 END PROGRAM ORE-FEATURE-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-TABLE-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ORE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 30 TO OT-COUNT
     MOVE 0 TO OB-READY OB-LIST OB-NPOS OB-PLACED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE 0 TO OB-RS1(WS-I) OB-RS2(WS-I)
     END-PERFORM
     MOVE "ore_dirt" TO OT-NAME(1)
     MOVE 0 TO OT-IDX(1)
     MOVE 6 TO OT-STEP(1)
     MOVE 1 TO OT-MOD(1)
     MOVE 7 TO OT-N(1)
     MOVE 1 TO OT-HKIND(1)
     MOVE 0 TO OT-LO(1)
     MOVE 160 TO OT-HI(1)
     MOVE 0 TO OT-BIOME(1)
     MOVE 33 TO OT-SIZE(1)
     MOVE 0 TO OT-AIR(1)
     MOVE 2 TO OT-KIND(1)
     MOVE "minecraft:dirt" TO OT-STONE(1)
     MOVE SPACES TO OT-DEEP(1)
     MOVE "ore_gravel" TO OT-NAME(2)
     MOVE 1 TO OT-IDX(2)
     MOVE 6 TO OT-STEP(2)
     MOVE 1 TO OT-MOD(2)
     MOVE 14 TO OT-N(2)
     MOVE 1 TO OT-HKIND(2)
     MOVE -64 TO OT-LO(2)
     MOVE 319 TO OT-HI(2)
     MOVE 0 TO OT-BIOME(2)
     MOVE 33 TO OT-SIZE(2)
     MOVE 0 TO OT-AIR(2)
     MOVE 2 TO OT-KIND(2)
     MOVE "minecraft:gravel" TO OT-STONE(2)
     MOVE SPACES TO OT-DEEP(2)
     MOVE "ore_granite_upper" TO OT-NAME(3)
     MOVE 2 TO OT-IDX(3)
     MOVE 6 TO OT-STEP(3)
     MOVE 3 TO OT-MOD(3)
     MOVE 6 TO OT-N(3)
     MOVE 1 TO OT-HKIND(3)
     MOVE 64 TO OT-LO(3)
     MOVE 128 TO OT-HI(3)
     MOVE 0 TO OT-BIOME(3)
     MOVE 64 TO OT-SIZE(3)
     MOVE 0 TO OT-AIR(3)
     MOVE 2 TO OT-KIND(3)
     MOVE "minecraft:granite" TO OT-STONE(3)
     MOVE SPACES TO OT-DEEP(3)
     MOVE "ore_granite_lower" TO OT-NAME(4)
     MOVE 3 TO OT-IDX(4)
     MOVE 6 TO OT-STEP(4)
     MOVE 1 TO OT-MOD(4)
     MOVE 2 TO OT-N(4)
     MOVE 1 TO OT-HKIND(4)
     MOVE 0 TO OT-LO(4)
     MOVE 60 TO OT-HI(4)
     MOVE 0 TO OT-BIOME(4)
     MOVE 64 TO OT-SIZE(4)
     MOVE 0 TO OT-AIR(4)
     MOVE 2 TO OT-KIND(4)
     MOVE "minecraft:granite" TO OT-STONE(4)
     MOVE SPACES TO OT-DEEP(4)
     MOVE "ore_diorite_upper" TO OT-NAME(5)
     MOVE 4 TO OT-IDX(5)
     MOVE 6 TO OT-STEP(5)
     MOVE 3 TO OT-MOD(5)
     MOVE 6 TO OT-N(5)
     MOVE 1 TO OT-HKIND(5)
     MOVE 64 TO OT-LO(5)
     MOVE 128 TO OT-HI(5)
     MOVE 0 TO OT-BIOME(5)
     MOVE 64 TO OT-SIZE(5)
     MOVE 0 TO OT-AIR(5)
     MOVE 2 TO OT-KIND(5)
     MOVE "minecraft:diorite" TO OT-STONE(5)
     MOVE SPACES TO OT-DEEP(5)
     MOVE "ore_diorite_lower" TO OT-NAME(6)
     MOVE 5 TO OT-IDX(6)
     MOVE 6 TO OT-STEP(6)
     MOVE 1 TO OT-MOD(6)
     MOVE 2 TO OT-N(6)
     MOVE 1 TO OT-HKIND(6)
     MOVE 0 TO OT-LO(6)
     MOVE 60 TO OT-HI(6)
     MOVE 0 TO OT-BIOME(6)
     MOVE 64 TO OT-SIZE(6)
     MOVE 0 TO OT-AIR(6)
     MOVE 2 TO OT-KIND(6)
     MOVE "minecraft:diorite" TO OT-STONE(6)
     MOVE SPACES TO OT-DEEP(6)
     MOVE "ore_andesite_upper" TO OT-NAME(7)
     MOVE 6 TO OT-IDX(7)
     MOVE 6 TO OT-STEP(7)
     MOVE 3 TO OT-MOD(7)
     MOVE 6 TO OT-N(7)
     MOVE 1 TO OT-HKIND(7)
     MOVE 64 TO OT-LO(7)
     MOVE 128 TO OT-HI(7)
     MOVE 0 TO OT-BIOME(7)
     MOVE 64 TO OT-SIZE(7)
     MOVE 0 TO OT-AIR(7)
     MOVE 2 TO OT-KIND(7)
     MOVE "minecraft:andesite" TO OT-STONE(7)
     MOVE SPACES TO OT-DEEP(7)
     MOVE "ore_andesite_lower" TO OT-NAME(8)
     MOVE 7 TO OT-IDX(8)
     MOVE 6 TO OT-STEP(8)
     MOVE 1 TO OT-MOD(8)
     MOVE 2 TO OT-N(8)
     MOVE 1 TO OT-HKIND(8)
     MOVE 0 TO OT-LO(8)
     MOVE 60 TO OT-HI(8)
     MOVE 0 TO OT-BIOME(8)
     MOVE 64 TO OT-SIZE(8)
     MOVE 0 TO OT-AIR(8)
     MOVE 2 TO OT-KIND(8)
     MOVE "minecraft:andesite" TO OT-STONE(8)
     MOVE SPACES TO OT-DEEP(8)
     MOVE "ore_tuff" TO OT-NAME(9)
     MOVE 8 TO OT-IDX(9)
     MOVE 6 TO OT-STEP(9)
     MOVE 1 TO OT-MOD(9)
     MOVE 2 TO OT-N(9)
     MOVE 1 TO OT-HKIND(9)
     MOVE -64 TO OT-LO(9)
     MOVE 0 TO OT-HI(9)
     MOVE 0 TO OT-BIOME(9)
     MOVE 64 TO OT-SIZE(9)
     MOVE 0 TO OT-AIR(9)
     MOVE 2 TO OT-KIND(9)
     MOVE "minecraft:tuff" TO OT-STONE(9)
     MOVE SPACES TO OT-DEEP(9)
     MOVE "ore_coal_upper" TO OT-NAME(10)
     MOVE 9 TO OT-IDX(10)
     MOVE 6 TO OT-STEP(10)
     MOVE 1 TO OT-MOD(10)
     MOVE 30 TO OT-N(10)
     MOVE 1 TO OT-HKIND(10)
     MOVE 136 TO OT-LO(10)
     MOVE 319 TO OT-HI(10)
     MOVE 0 TO OT-BIOME(10)
     MOVE 17 TO OT-SIZE(10)
     MOVE 0 TO OT-AIR(10)
     MOVE 1 TO OT-KIND(10)
     MOVE "minecraft:coal_ore" TO OT-STONE(10)
     MOVE "minecraft:deepslate_coal_ore" TO OT-DEEP(10)
     MOVE "ore_coal_lower" TO OT-NAME(11)
     MOVE 10 TO OT-IDX(11)
     MOVE 6 TO OT-STEP(11)
     MOVE 1 TO OT-MOD(11)
     MOVE 20 TO OT-N(11)
     MOVE 2 TO OT-HKIND(11)
     MOVE 0 TO OT-LO(11)
     MOVE 192 TO OT-HI(11)
     MOVE 0 TO OT-BIOME(11)
     MOVE 17 TO OT-SIZE(11)
     MOVE 50 TO OT-AIR(11)
     MOVE 1 TO OT-KIND(11)
     MOVE "minecraft:coal_ore" TO OT-STONE(11)
     MOVE "minecraft:deepslate_coal_ore" TO OT-DEEP(11)
     MOVE "ore_iron_upper" TO OT-NAME(12)
     MOVE 11 TO OT-IDX(12)
     MOVE 6 TO OT-STEP(12)
     MOVE 1 TO OT-MOD(12)
     MOVE 90 TO OT-N(12)
     MOVE 2 TO OT-HKIND(12)
     MOVE 80 TO OT-LO(12)
     MOVE 384 TO OT-HI(12)
     MOVE 0 TO OT-BIOME(12)
     MOVE 9 TO OT-SIZE(12)
     MOVE 0 TO OT-AIR(12)
     MOVE 1 TO OT-KIND(12)
     MOVE "minecraft:iron_ore" TO OT-STONE(12)
     MOVE "minecraft:deepslate_iron_ore" TO OT-DEEP(12)
     MOVE "ore_iron_middle" TO OT-NAME(13)
     MOVE 12 TO OT-IDX(13)
     MOVE 6 TO OT-STEP(13)
     MOVE 1 TO OT-MOD(13)
     MOVE 10 TO OT-N(13)
     MOVE 2 TO OT-HKIND(13)
     MOVE -24 TO OT-LO(13)
     MOVE 56 TO OT-HI(13)
     MOVE 0 TO OT-BIOME(13)
     MOVE 9 TO OT-SIZE(13)
     MOVE 0 TO OT-AIR(13)
     MOVE 1 TO OT-KIND(13)
     MOVE "minecraft:iron_ore" TO OT-STONE(13)
     MOVE "minecraft:deepslate_iron_ore" TO OT-DEEP(13)
     MOVE "ore_iron_small" TO OT-NAME(14)
     MOVE 13 TO OT-IDX(14)
     MOVE 6 TO OT-STEP(14)
     MOVE 1 TO OT-MOD(14)
     MOVE 10 TO OT-N(14)
     MOVE 1 TO OT-HKIND(14)
     MOVE -64 TO OT-LO(14)
     MOVE 72 TO OT-HI(14)
     MOVE 0 TO OT-BIOME(14)
     MOVE 4 TO OT-SIZE(14)
     MOVE 0 TO OT-AIR(14)
     MOVE 1 TO OT-KIND(14)
     MOVE "minecraft:iron_ore" TO OT-STONE(14)
     MOVE "minecraft:deepslate_iron_ore" TO OT-DEEP(14)
     MOVE "ore_gold" TO OT-NAME(15)
     MOVE 14 TO OT-IDX(15)
     MOVE 6 TO OT-STEP(15)
     MOVE 1 TO OT-MOD(15)
     MOVE 4 TO OT-N(15)
     MOVE 2 TO OT-HKIND(15)
     MOVE -64 TO OT-LO(15)
     MOVE 32 TO OT-HI(15)
     MOVE 0 TO OT-BIOME(15)
     MOVE 9 TO OT-SIZE(15)
     MOVE 50 TO OT-AIR(15)
     MOVE 1 TO OT-KIND(15)
     MOVE "minecraft:gold_ore" TO OT-STONE(15)
     MOVE "minecraft:deepslate_gold_ore" TO OT-DEEP(15)
     MOVE "ore_gold_lower" TO OT-NAME(16)
     MOVE 15 TO OT-IDX(16)
     MOVE 6 TO OT-STEP(16)
     MOVE 2 TO OT-MOD(16)
     MOVE 0 TO OT-N(16)
     MOVE 1 TO OT-HKIND(16)
     MOVE -64 TO OT-LO(16)
     MOVE -48 TO OT-HI(16)
     MOVE 0 TO OT-BIOME(16)
     MOVE 9 TO OT-SIZE(16)
     MOVE 50 TO OT-AIR(16)
     MOVE 1 TO OT-KIND(16)
     MOVE "minecraft:gold_ore" TO OT-STONE(16)
     MOVE "minecraft:deepslate_gold_ore" TO OT-DEEP(16)
     MOVE "ore_redstone" TO OT-NAME(17)
     MOVE 16 TO OT-IDX(17)
     MOVE 6 TO OT-STEP(17)
     MOVE 1 TO OT-MOD(17)
     MOVE 4 TO OT-N(17)
     MOVE 1 TO OT-HKIND(17)
     MOVE -64 TO OT-LO(17)
     MOVE 15 TO OT-HI(17)
     MOVE 0 TO OT-BIOME(17)
     MOVE 8 TO OT-SIZE(17)
     MOVE 0 TO OT-AIR(17)
     MOVE 1 TO OT-KIND(17)
     MOVE "minecraft:redstone_ore" TO OT-STONE(17)
     MOVE "minecraft:deepslate_redstone_ore" TO OT-DEEP(17)
     MOVE "ore_redstone_lower" TO OT-NAME(18)
     MOVE 17 TO OT-IDX(18)
     MOVE 6 TO OT-STEP(18)
     MOVE 1 TO OT-MOD(18)
     MOVE 8 TO OT-N(18)
     MOVE 2 TO OT-HKIND(18)
     MOVE -96 TO OT-LO(18)
     MOVE -32 TO OT-HI(18)
     MOVE 0 TO OT-BIOME(18)
     MOVE 8 TO OT-SIZE(18)
     MOVE 0 TO OT-AIR(18)
     MOVE 1 TO OT-KIND(18)
     MOVE "minecraft:redstone_ore" TO OT-STONE(18)
     MOVE "minecraft:deepslate_redstone_ore" TO OT-DEEP(18)
     MOVE "ore_diamond" TO OT-NAME(19)
     MOVE 18 TO OT-IDX(19)
     MOVE 6 TO OT-STEP(19)
     MOVE 1 TO OT-MOD(19)
     MOVE 7 TO OT-N(19)
     MOVE 2 TO OT-HKIND(19)
     MOVE -144 TO OT-LO(19)
     MOVE 16 TO OT-HI(19)
     MOVE 0 TO OT-BIOME(19)
     MOVE 4 TO OT-SIZE(19)
     MOVE 50 TO OT-AIR(19)
     MOVE 1 TO OT-KIND(19)
     MOVE "minecraft:diamond_ore" TO OT-STONE(19)
     MOVE "minecraft:deepslate_diamond_ore" TO OT-DEEP(19)
     MOVE "ore_diamond_medium" TO OT-NAME(20)
     MOVE 19 TO OT-IDX(20)
     MOVE 6 TO OT-STEP(20)
     MOVE 1 TO OT-MOD(20)
     MOVE 2 TO OT-N(20)
     MOVE 1 TO OT-HKIND(20)
     MOVE -64 TO OT-LO(20)
     MOVE -4 TO OT-HI(20)
     MOVE 0 TO OT-BIOME(20)
     MOVE 8 TO OT-SIZE(20)
     MOVE 50 TO OT-AIR(20)
     MOVE 1 TO OT-KIND(20)
     MOVE "minecraft:diamond_ore" TO OT-STONE(20)
     MOVE "minecraft:deepslate_diamond_ore" TO OT-DEEP(20)
     MOVE "ore_diamond_large" TO OT-NAME(21)
     MOVE 20 TO OT-IDX(21)
     MOVE 6 TO OT-STEP(21)
     MOVE 3 TO OT-MOD(21)
     MOVE 9 TO OT-N(21)
     MOVE 2 TO OT-HKIND(21)
     MOVE -144 TO OT-LO(21)
     MOVE 16 TO OT-HI(21)
     MOVE 0 TO OT-BIOME(21)
     MOVE 12 TO OT-SIZE(21)
     MOVE 70 TO OT-AIR(21)
     MOVE 1 TO OT-KIND(21)
     MOVE "minecraft:diamond_ore" TO OT-STONE(21)
     MOVE "minecraft:deepslate_diamond_ore" TO OT-DEEP(21)
     MOVE "ore_diamond_buried" TO OT-NAME(22)
     MOVE 21 TO OT-IDX(22)
     MOVE 6 TO OT-STEP(22)
     MOVE 1 TO OT-MOD(22)
     MOVE 4 TO OT-N(22)
     MOVE 2 TO OT-HKIND(22)
     MOVE -144 TO OT-LO(22)
     MOVE 16 TO OT-HI(22)
     MOVE 0 TO OT-BIOME(22)
     MOVE 8 TO OT-SIZE(22)
     MOVE 100 TO OT-AIR(22)
     MOVE 1 TO OT-KIND(22)
     MOVE "minecraft:diamond_ore" TO OT-STONE(22)
     MOVE "minecraft:deepslate_diamond_ore" TO OT-DEEP(22)
     MOVE "ore_lapis" TO OT-NAME(23)
     MOVE 22 TO OT-IDX(23)
     MOVE 6 TO OT-STEP(23)
     MOVE 1 TO OT-MOD(23)
     MOVE 2 TO OT-N(23)
     MOVE 2 TO OT-HKIND(23)
     MOVE -32 TO OT-LO(23)
     MOVE 32 TO OT-HI(23)
     MOVE 0 TO OT-BIOME(23)
     MOVE 7 TO OT-SIZE(23)
     MOVE 0 TO OT-AIR(23)
     MOVE 1 TO OT-KIND(23)
     MOVE "minecraft:lapis_ore" TO OT-STONE(23)
     MOVE "minecraft:deepslate_lapis_ore" TO OT-DEEP(23)
     MOVE "ore_lapis_buried" TO OT-NAME(24)
     MOVE 23 TO OT-IDX(24)
     MOVE 6 TO OT-STEP(24)
     MOVE 1 TO OT-MOD(24)
     MOVE 4 TO OT-N(24)
     MOVE 1 TO OT-HKIND(24)
     MOVE -64 TO OT-LO(24)
     MOVE 64 TO OT-HI(24)
     MOVE 0 TO OT-BIOME(24)
     MOVE 7 TO OT-SIZE(24)
     MOVE 100 TO OT-AIR(24)
     MOVE 1 TO OT-KIND(24)
     MOVE "minecraft:lapis_ore" TO OT-STONE(24)
     MOVE "minecraft:deepslate_lapis_ore" TO OT-DEEP(24)
     MOVE "ore_copper" TO OT-NAME(25)
     MOVE 24 TO OT-IDX(25)
     MOVE 6 TO OT-STEP(25)
     MOVE 1 TO OT-MOD(25)
     MOVE 16 TO OT-N(25)
     MOVE 2 TO OT-HKIND(25)
     MOVE -16 TO OT-LO(25)
     MOVE 112 TO OT-HI(25)
     MOVE 5 TO OT-BIOME(25)
     MOVE 10 TO OT-SIZE(25)
     MOVE 0 TO OT-AIR(25)
     MOVE 1 TO OT-KIND(25)
     MOVE "minecraft:copper_ore" TO OT-STONE(25)
     MOVE "minecraft:deepslate_copper_ore" TO OT-DEEP(25)
     MOVE "ore_copper_large" TO OT-NAME(26)
     MOVE 25 TO OT-IDX(26)
     MOVE 6 TO OT-STEP(26)
     MOVE 1 TO OT-MOD(26)
     MOVE 16 TO OT-N(26)
     MOVE 2 TO OT-HKIND(26)
     MOVE -16 TO OT-LO(26)
     MOVE 112 TO OT-HI(26)
     MOVE 3 TO OT-BIOME(26)
     MOVE 20 TO OT-SIZE(26)
     MOVE 0 TO OT-AIR(26)
     MOVE 1 TO OT-KIND(26)
     MOVE "minecraft:copper_ore" TO OT-STONE(26)
     MOVE "minecraft:deepslate_copper_ore" TO OT-DEEP(26)
     MOVE "ore_gold_extra" TO OT-NAME(27)
     MOVE 27 TO OT-IDX(27)
     MOVE 6 TO OT-STEP(27)
     MOVE 1 TO OT-MOD(27)
     MOVE 50 TO OT-N(27)
     MOVE 1 TO OT-HKIND(27)
     MOVE 32 TO OT-LO(27)
     MOVE 256 TO OT-HI(27)
     MOVE 2 TO OT-BIOME(27)
     MOVE 9 TO OT-SIZE(27)
     MOVE 0 TO OT-AIR(27)
     MOVE 1 TO OT-KIND(27)
     MOVE "minecraft:gold_ore" TO OT-STONE(27)
     MOVE "minecraft:deepslate_gold_ore" TO OT-DEEP(27)
     MOVE "ore_clay" TO OT-NAME(28)
     MOVE 28 TO OT-IDX(28)
     MOVE 6 TO OT-STEP(28)
     MOVE 1 TO OT-MOD(28)
     MOVE 46 TO OT-N(28)
     MOVE 1 TO OT-HKIND(28)
     MOVE -64 TO OT-LO(28)
     MOVE 192 TO OT-HI(28)
     MOVE 4 TO OT-BIOME(28)
     MOVE 33 TO OT-SIZE(28)
     MOVE 0 TO OT-AIR(28)
     MOVE 2 TO OT-KIND(28)
     MOVE "minecraft:clay" TO OT-STONE(28)
     MOVE SPACES TO OT-DEEP(28)
     MOVE "ore_emerald" TO OT-NAME(29)
     MOVE 33 TO OT-IDX(29)
     MOVE 6 TO OT-STEP(29)
     MOVE 1 TO OT-MOD(29)
     MOVE 100 TO OT-N(29)
     MOVE 2 TO OT-HKIND(29)
     MOVE -16 TO OT-LO(29)
     MOVE 480 TO OT-HI(29)
     MOVE 1 TO OT-BIOME(29)
     MOVE 3 TO OT-SIZE(29)
     MOVE 0 TO OT-AIR(29)
     MOVE 1 TO OT-KIND(29)
     MOVE "minecraft:emerald_ore" TO OT-STONE(29)
     MOVE "minecraft:deepslate_emerald_ore" TO OT-DEEP(29)
     MOVE "ore_infested" TO OT-NAME(30)
     MOVE 34 TO OT-IDX(30)
     MOVE 7 TO OT-STEP(30)
     MOVE 1 TO OT-MOD(30)
     MOVE 14 TO OT-N(30)
     MOVE 1 TO OT-HKIND(30)
     MOVE -64 TO OT-LO(30)
     MOVE 63 TO OT-HI(30)
     MOVE 1 TO OT-BIOME(30)
     MOVE 9 TO OT-SIZE(30)
     MOVE 0 TO OT-AIR(30)
     MOVE 1 TO OT-KIND(30)
     MOVE "minecraft:infested_stone" TO OT-STONE(30)
     MOVE "minecraft:infested_deepslate" TO OT-DEEP(30)
     GOBACK.
 END PROGRAM ORE-TABLE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-HEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RANGE               BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-SLOPE               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-KIND                 BINARY-LONG.
 01 L-LOW                   BINARY-LONG.
 01 L-HIGH                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-KIND L-LOW L-HIGH L-Y.
     COMPUTE WS-RANGE = L-HIGH - L-LOW
     IF L-KIND = 1
         COMPUTE WS-BOUND = WS-RANGE + 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D1
         COMPUTE L-Y = L-LOW + WS-D1
         GOBACK
     END-IF
     DIVIDE WS-RANGE BY 2 GIVING WS-WIDTH
     COMPUTE WS-SLOPE = WS-RANGE - WS-WIDTH
     COMPUTE WS-BOUND = WS-SLOPE + 1
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D1
     COMPUTE WS-BOUND = WS-WIDTH + 1
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D2
     COMPUTE L-Y = L-LOW + WS-D1 + WS-D2
     GOBACK.
 END PROGRAM ORE-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-BIOME-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIMIT                BINARY-LONG.
 01 L-BIOME                PIC X(40).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LIMIT L-BIOME L-FLAG.
     MOVE 0 TO L-FLAG
     EVALUATE L-LIMIT
         WHEN 0
             MOVE 1 TO L-FLAG
         WHEN 1
             IF L-BIOME = "minecraft:cherry_grove" OR "minecraft:frozen_peaks" OR "minecraft:grove"
                 OR "minecraft:jagged_peaks" OR "minecraft:meadow" OR "minecraft:snowy_slopes"
                 OR "minecraft:stony_peaks" OR "minecraft:windswept_forest"
                 OR "minecraft:windswept_gravelly_hills" OR "minecraft:windswept_hills"
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN 2
             IF L-BIOME = "minecraft:badlands" OR "minecraft:eroded_badlands" OR "minecraft:wooded_badlands"
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN 3
             IF L-BIOME = "minecraft:dripstone_caves"
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN 4
             IF L-BIOME = "minecraft:lush_caves"
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN OTHER
             IF L-BIOME NOT = "minecraft:dripstone_caves"
                 MOVE 1 TO L-FLAG
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM ORE-BIOME-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-BLOB-GEOM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ORE.
 01 WS-FS                  FLOAT-LONG.
 01 WS-EIGHT               FLOAT-LONG VALUE 8.
 01 WS-SIZE-F              FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-CFS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ANGLE                FLOAT-LONG.
 01 L-D1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-X L-Y L-Z L-ANGLE L-D1 L-D2.
     MOVE L-SIZE TO WS-SIZE-F
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-SIZE-F WS-EIGHT WS-FS
     CALL STATIC "cc_f64_sin" USING BY REFERENCE L-ANGLE WS-S
     CALL STATIC "cc_f64_cos" USING BY REFERENCE L-ANGLE WS-C
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-S WS-FS WS-D
     MOVE L-X TO WS-O
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-O WS-D OB-X0
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-O WS-D OB-X1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-C WS-FS WS-D
     MOVE L-Z TO WS-O
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-O WS-D OB-Z0
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-O WS-D OB-Z1
     COMPUTE OB-Y0 = L-Y + L-D1 - 2
     COMPUTE OB-Y1 = L-Y + L-D2 - 2
     COMPUTE WS-CFS = 0 - FUNCTION INTEGER(0 - L-SIZE / 8)
     COMPUTE OB-RR = 0 - FUNCTION INTEGER(0 - (L-SIZE / 16 + 0.5))
     COMPUTE OB-START-X = L-X - WS-CFS - OB-RR
     COMPUTE OB-START-Y = L-Y - 2 - OB-RR
     COMPUTE OB-START-Z = L-Z - WS-CFS - OB-RR
     COMPUTE OB-WIDTH = 2 * (WS-CFS + OB-RR)
     COMPUTE OB-HEIGHT = 2 * (2 + OB-RR)
     GOBACK.
 END PROGRAM ORE-BLOB-GEOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-AIR-EXPOSED.
*> USING job, x, y, z, flag out: 1 when a face neighbour inside the chunk is air (blocks outside the chunk count as not air).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-N                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     SET ADDRESS OF CE-CHUNK TO J-ADDR
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 6 OR L-FLAG = 1
         MOVE L-X TO WS-NX
         MOVE L-Y TO WS-NY
         MOVE L-Z TO WS-NZ
         EVALUATE WS-N
             WHEN 1
                 SUBTRACT 1 FROM WS-NX
             WHEN 2
                 ADD 1 TO WS-NX
             WHEN 3
                 SUBTRACT 1 FROM WS-NY
             WHEN 4
                 ADD 1 TO WS-NY
             WHEN 5
                 SUBTRACT 1 FROM WS-NZ
             WHEN OTHER
                 ADD 1 TO WS-NZ
         END-EVALUATE
         COMPUTE WS-LX = WS-NX - J-CX * 16
         COMPUTE WS-LZ = WS-NZ - J-CZ * 16
         IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15 AND WS-NY >= -64 AND WS-NY <= 319
             COMPUTE WS-CELL = (WS-NY + 64) * 256 + WS-LZ * 16 + WS-LX + 1
             IF CE-STATE(WS-CELL) = 0
                 MOVE 1 TO L-FLAG
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ORE-AIR-EXPOSED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-ACCEPT.
*> USING job, state, row, current block state, x, y, z, target (1 stone variant, 2 deepslate variant; 1 for a single block), flag out:
*> 7.3: the rule of the target, then the air exposure test (a draw only when the rule accepted and 0 < discard chance < 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ORE.
 01 WS-RULE                BINARY-LONG.
 01 WS-EXPOSED             BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-HUNDRED             FLOAT-LONG VALUE 100.
 01 WS-AIR-F               FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-CUR                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-STATE L-ROW L-CUR L-X L-Y L-Z L-TARGET L-FLAG.
     MOVE 0 TO L-FLAG WS-RULE
*>   air is never a target (a base stone the block table lacks resolves to state 0 and must not match it)
     IF L-CUR = 0
         GOBACK
     END-IF
     IF OT-KIND(L-ROW) = 2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
             IF L-CUR = OB-BASE(WS-I)
                 MOVE 1 TO WS-RULE
             END-IF
         END-PERFORM
     ELSE
         IF L-CUR = OB-BASE(5)
             IF L-TARGET = 1 AND L-Y >= 0 AND L-Y <= 2031
                 MOVE 1 TO WS-RULE
             END-IF
             IF L-TARGET = 2 AND L-Y >= -2032 AND L-Y <= 8
                 MOVE 1 TO WS-RULE
             END-IF
         ELSE
             IF L-TARGET = 1
                 IF L-CUR = OB-BASE(1) OR L-CUR = OB-BASE(2) OR L-CUR = OB-BASE(3) OR L-CUR = OB-BASE(4)
                     MOVE 1 TO WS-RULE
                 END-IF
             ELSE
                 IF L-CUR = OB-BASE(6)
                     MOVE 1 TO WS-RULE
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WS-RULE = 0
         GOBACK
     END-IF
     IF OT-AIR(L-ROW) = 0
         MOVE 1 TO L-FLAG
         GOBACK
     END-IF
     CALL "ORE-AIR-EXPOSED" USING L-JOB L-X L-Y L-Z WS-EXPOSED
     IF OT-AIR(L-ROW) >= 100
         IF WS-EXPOSED = 0
             MOVE 1 TO L-FLAG
         END-IF
         GOBACK
     END-IF
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-DRAW
     MOVE OT-AIR(L-ROW) TO WS-AIR-F
     CALL "CV-FDIV" USING WS-AIR-F WS-HUNDRED WS-CHANCE
     IF WS-DRAW >= WS-CHANCE OR WS-EXPOSED = 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM ORE-ACCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-STATES.
*> USING row: resolves the block states of the six base stones and of the ores of the row (once).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ORE.
 01 WS-KEYS.
    05 FILLER              PIC X(48) VALUE "minecraft:stone".
    05 FILLER              PIC X(48) VALUE "minecraft:granite".
    05 FILLER              PIC X(48) VALUE "minecraft:diorite".
    05 FILLER              PIC X(48) VALUE "minecraft:andesite".
    05 FILLER              PIC X(48) VALUE "minecraft:tuff".
    05 FILLER              PIC X(48) VALUE "minecraft:deepslate".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(48) OCCURS 6 TIMES.
 01 WS-K48                 PIC X(48).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF OB-READY = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
             CALL "GEN-BLOCK-STATE" USING WS-KEY(WS-I) OB-BASE(WS-I)
         END-PERFORM
         MOVE 1 TO OB-READY
     END-IF
     IF OB-RS1(L-ROW) = 0
         MOVE OT-STONE(L-ROW) TO WS-K48
         CALL "GEN-BLOCK-STATE" USING WS-K48 OB-RS1(L-ROW)
         IF OT-KIND(L-ROW) = 1
             MOVE OT-DEEP(L-ROW) TO WS-K48
             CALL "GEN-BLOCK-STATE" USING WS-K48 OB-RS2(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ORE-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-FILL-BALL.
*> USING job, state, row, ball x, y, z, radius (FLOAT-LONG), bits (BINARY-LONG, the size of the handled set): the fill of one ball (7.2 step 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY ORE.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-XD2                 FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-YD2T.
    05 WS-YD2T-ITEM        FLOAT-LONG OCCURS 64 TIMES.
 01 WS-ZD2T.
    05 WS-ZD2T-ITEM        FLOAT-LONG OCCURS 64 TIMES.
 01 WS-S2                  FLOAT-LONG.
 01 WS-S3                  FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-YLO                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-XHI                 BINARY-LONG.
 01 WS-YHI                 BINARY-LONG.
 01 WS-ZHI                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-TGT                 BINARY-LONG.
 01 WS-TGTS                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-BX                   FLOAT-LONG.
 01 L-BY                   FLOAT-LONG.
 01 L-BZ                   FLOAT-LONG.
 01 L-BR                   FLOAT-LONG.
 01 L-BITS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-STATE L-ROW L-BX L-BY L-BZ L-BR L-BITS.
     SET ADDRESS OF CE-CHUNK TO J-ADDR
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-BX L-BR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-XLO = FUNCTION MAX(WS-A, OB-START-X)
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-BY L-BR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-YLO = FUNCTION MAX(WS-A, OB-START-Y)
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-BZ L-BR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-ZLO = FUNCTION MAX(WS-A, OB-START-Z)
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-BX L-BR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-XHI = FUNCTION MAX(WS-A, WS-XLO)
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-BY L-BR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-YHI = FUNCTION MAX(WS-A, WS-YLO)
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-BZ L-BR WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-A
     COMPUTE WS-ZHI = FUNCTION MAX(WS-A, WS-ZLO)
*>   the squared distances along y and along z do not depend on the other axes: each once per layer, not once per block
     PERFORM VARYING WS-Y FROM WS-YLO BY 1 UNTIL WS-Y > WS-YHI
         COMPUTE WS-K = WS-Y - WS-YLO + 1
         MOVE WS-Y TO WS-V
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-V WS-HALF WS-T
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T L-BY WS-A
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A L-BR WS-D
         MOVE WS-D TO WS-C
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-C WS-YD2T-ITEM(WS-K)
     END-PERFORM
     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
         COMPUTE WS-K = WS-Z - WS-ZLO + 1
         MOVE WS-Z TO WS-V
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-V WS-HALF WS-T
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T L-BZ WS-A
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A L-BR WS-D
         MOVE WS-D TO WS-C
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-C WS-ZD2T-ITEM(WS-K)
     END-PERFORM
     PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
         MOVE WS-X TO WS-V
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-V WS-HALF WS-T
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T L-BX WS-A
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A L-BR WS-D
         MOVE WS-D TO WS-C
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-C WS-XD2
         IF WS-XD2 < 1
             PERFORM VARYING WS-Y FROM WS-YLO BY 1 UNTIL WS-Y > WS-YHI
                 COMPUTE WS-K = WS-Y - WS-YLO + 1
                 CALL STATIC "cc_f64_add" USING BY REFERENCE WS-XD2 WS-YD2T-ITEM(WS-K) WS-S2
                 IF WS-S2 < 1
                     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
                         COMPUTE WS-K = WS-Z - WS-ZLO + 1
                         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-S2 WS-ZD2T-ITEM(WS-K) WS-S3
                         IF WS-S3 < 1 AND WS-Y >= -64 AND WS-Y <= 319
                             COMPUTE WS-BIT = (WS-X - OB-START-X) + (WS-Y - OB-START-Y) * OB-WIDTH
                                 + (WS-Z - OB-START-Z) * OB-WIDTH * OB-HEIGHT + 1
                             IF WS-BIT >= 1 AND WS-BIT <= L-BITS AND OB-BITS(WS-BIT:1) = LOW-VALUE
                                 MOVE "1" TO OB-BITS(WS-BIT:1)
                                 COMPUTE WS-LX = WS-X - J-CX * 16
                                 COMPUTE WS-LZ = WS-Z - J-CZ * 16
                                 IF OB-LIST = 1
                                     IF OB-NPOS < 4000
                                         ADD 1 TO OB-NPOS
                                         MOVE WS-X TO OB-POS-X(OB-NPOS)
                                         MOVE WS-Y TO OB-POS-Y(OB-NPOS)
                                         MOVE WS-Z TO OB-POS-Z(OB-NPOS)
                                     END-IF
                                 ELSE
                                     IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
                                         COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-LZ * 16 + WS-LX + 1
                                         MOVE CE-STATE(WS-CELL) TO WS-CUR
                                         MOVE 1 TO WS-TGTS
                                         IF OT-KIND(L-ROW) = 1
                                             MOVE 2 TO WS-TGTS
                                         END-IF
                                         MOVE 0 TO WS-DONE
                                         PERFORM VARYING WS-TGT FROM 1 BY 1 UNTIL WS-TGT > WS-TGTS OR WS-DONE = 1
                                             CALL "ORE-ACCEPT" USING L-JOB L-STATE L-ROW WS-CUR WS-X WS-Y WS-Z WS-TGT WS-FLAG
                                             IF WS-FLAG = 1
                                                 MOVE OB-RS1(L-ROW) TO WS-STATE
                                                 IF WS-TGT = 2
                                                     MOVE OB-RS2(L-ROW) TO WS-STATE
                                                 END-IF
                                                 IF WS-STATE NOT = 0
                                                     MOVE WS-STATE TO CE-STATE(WS-CELL)
                                                     ADD 1 TO OB-PLACED
                                                 END-IF
                                                 MOVE 1 TO WS-DONE
                                             END-IF
                                         END-PERFORM
                                     END-IF
                                 END-IF
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ORE-FILL-BALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-PLACE-BLOB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY CARVER.
 COPY ORE.
 01 WS-SIZE                BINARY-LONG.
 01 WS-NF                  FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-IF                  FLOAT-LONG.
 01 WS-SIZE-F              FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-DN                  FLOAT-LONG.
 01 WS-SIXTEEN             FLOAT-LONG VALUE 16.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-BALLS.
    05 WS-BALL OCCURS 64 TIMES.
       10 WS-BX            FLOAT-LONG.
       10 WS-BY            FLOAT-LONG.
       10 WS-BZ            FLOAT-LONG.
       10 WS-BR            FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DR                  FLOAT-LONG.
 01 WS-PA                  FLOAT-LONG.
 01 WS-PB                  FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-SQ                  FLOAT-LONG.
 01 WS-CP                  FLOAT-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-YLO                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-XHI                 BINARY-LONG.
 01 WS-YHI                 BINARY-LONG.
 01 WS-ZHI                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-XD2                 FLOAT-LONG.
 01 WS-YD2                 FLOAT-LONG.
 01 WS-ZD2                 FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-BITS-N              BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-TGT                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-STATE L-ROW L-X L-Y L-Z.
     MOVE 0 TO OB-PLACED
     CALL "ORE-STATES" USING L-ROW
     MOVE OT-SIZE(L-ROW) TO WS-SIZE
     MOVE WS-SIZE TO WS-SIZE-F
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-NF
     CALL "CV-FMUL" USING WS-NF CV-PI WS-ANGLE
     MOVE 3 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D1
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-D2
     CALL "ORE-BLOB-GEOM" USING WS-SIZE L-X L-Y L-Z WS-ANGLE WS-D1 WS-D2
*>   the heightmap column test of 7.1 on the first column when it is one of this chunk's
     COMPUTE WS-LX = OB-START-X - J-CX * 16
     COMPUTE WS-LZ = OB-START-Z - J-CZ * 16
     IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
         COMPUTE WS-COL = WS-LZ * 16 + WS-LX + 1
         IF OB-START-Y > J-HM-OCEAN(WS-COL) + 1
             GOBACK
         END-IF
     END-IF
*>   the balls
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-SIZE
         MOVE WS-I TO WS-IF
         CALL "CV-FDIV" USING WS-IF WS-SIZE-F WS-T
         CALL STATIC "cc_f64_sub" USING BY REFERENCE OB-X1 OB-X0 WS-A
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-A WS-B
         COMPUTE WS-J = WS-I + 1
         CALL STATIC "cc_f64_add" USING BY REFERENCE OB-X0 WS-B WS-BX(WS-J)
         MOVE OB-Y0 TO WS-A
         MOVE OB-Y1 TO WS-B
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-B WS-A WS-C
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-C WS-B
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-A WS-B WS-BY(WS-J)
         CALL STATIC "cc_f64_sub" USING BY REFERENCE OB-Z1 OB-Z0 WS-A
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-A WS-B
         CALL STATIC "cc_f64_add" USING BY REFERENCE OB-Z0 WS-B WS-BZ(WS-J)
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-DN
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DN WS-SIZE-F WS-A
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-SIXTEEN WS-DN
         CALL "CV-FMUL" USING CV-PI WS-T WS-A
         CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE WS-A WS-S
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-S WS-ONE WS-A
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-DN WS-B
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-B WS-ONE WS-A
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-TWO WS-BR(WS-J)
     END-PERFORM
*>   a ball wholly inside a larger one is dropped
     COMPUTE WS-BOUND = WS-SIZE - 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-BOUND
         IF WS-BR(WS-I) > 0
             COMPUTE WS-J = WS-I + 1
             PERFORM VARYING WS-J FROM WS-J BY 1 UNTIL WS-J > WS-SIZE
                 IF WS-BR(WS-J) > 0
                     MOVE WS-BX(WS-I) TO WS-PA
                     MOVE WS-BX(WS-J) TO WS-PB
                     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-PA WS-PB WS-DX
                     MOVE WS-BY(WS-I) TO WS-PA
                     MOVE WS-BY(WS-J) TO WS-PB
                     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-PA WS-PB WS-DY
                     MOVE WS-BZ(WS-I) TO WS-PA
                     MOVE WS-BZ(WS-J) TO WS-PB
                     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-PA WS-PB WS-DZ
                     MOVE WS-BR(WS-I) TO WS-PA
                     MOVE WS-BR(WS-J) TO WS-PB
                     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-PA WS-PB WS-DR
                     MOVE WS-DR TO WS-SQ
                     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DR WS-SQ WS-A
                     MOVE WS-DX TO WS-SQ
                     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DX WS-SQ WS-B
                     MOVE WS-DY TO WS-SQ
                     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DY WS-SQ WS-C
                     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-B WS-C WS-SUM
                     MOVE WS-DZ TO WS-SQ
                     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DZ WS-SQ WS-B
                     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-SUM WS-B WS-C
                     IF WS-A > WS-C
                         IF WS-DR > 0
                             MOVE -1 TO WS-BR(WS-J)
                         ELSE
                             MOVE -1 TO WS-BR(WS-I)
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
*>   the fill, ball by ball
     COMPUTE WS-BITS-N = OB-WIDTH * OB-HEIGHT * OB-WIDTH
     MOVE LOW-VALUES TO OB-BITS(1:WS-BITS-N)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SIZE
         IF WS-BR(WS-I) >= 0
             CALL "ORE-FILL-BALL" USING L-JOB L-STATE L-ROW WS-BX(WS-I) WS-BY(WS-I) WS-BZ(WS-I) WS-BR(WS-I) WS-BITS-N
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ORE-PLACE-BLOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STAGE-ORES.
*> Step GJ-SUB (0 to 269) of the ore stage: placed feature GJ-SUB mod 30 of the decoration of chunk GJ-SUB div 30 of the 3 x 3 around the
*> target (6.1, 6.4): the modifiers count (or rarity filter), in_square, height_range and biome, then the blob of 7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY CBLOCKS.
 COPY CLIMATE.
 COPY CARVER.
 COPY ORE.
 COPY GENSTAGE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-CI                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-DECOR               BINARY-DOUBLE UNSIGNED.
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-N                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-ID                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD 1 TO GS-ORE
     IF CV-READY NOT = 1
         GOBACK
     END-IF
     IF OT-COUNT = 0
         CALL "ORE-TABLE-BUILD"
     END-IF
     DIVIDE J-SUB BY 30 GIVING WS-CI REMAINDER WS-ROW
     ADD 1 TO WS-ROW
     DIVIDE WS-CI BY 3 GIVING WS-DX REMAINDER WS-DZ
     COMPUTE WS-OX = (J-CX + WS-DX - 1) * 16
     COMPUTE WS-OZ = (J-CZ + WS-DZ - 1) * 16
     CALL "ORE-DECOR-SEED" USING CV-SEED WS-OX WS-OZ WS-XR WS-DECOR
     CALL "ORE-FEATURE-SEED" USING WS-DECOR OT-IDX(WS-ROW) OT-STEP(WS-ROW) WS-FSEED
     CALL "WGR-SET-SEED" USING WS-XR WS-FSEED
*>   the first modifier: how many positions
     MOVE 0 TO WS-N
     EVALUATE OT-MOD(WS-ROW)
         WHEN 1
             MOVE OT-N(WS-ROW) TO WS-N
         WHEN 2
             MOVE 2 TO WS-BOUND
             CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-BOUND WS-N
         WHEN OTHER
             CALL "WGR-NEXT-FLOAT" USING WS-XR WS-F
             MOVE OT-N(WS-ROW) TO WS-LIMIT
             CALL "CV-FDIV" USING WS-ONE WS-LIMIT WS-CHANCE
             IF WS-F < WS-CHANCE
                 MOVE 1 TO WS-N
             END-IF
     END-EVALUATE
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WS-N
         MOVE 16 TO WS-BOUND
         CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-BOUND WS-D
         COMPUTE WS-X = WS-OX + WS-D
         CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-BOUND WS-D
         COMPUTE WS-Z = WS-OZ + WS-D
         CALL "ORE-HEIGHT" USING WS-XR OT-HKIND(WS-ROW) OT-LO(WS-ROW) OT-HI(WS-ROW) WS-Y
         MOVE 1 TO WS-OK
         IF OT-BIOME(WS-ROW) NOT = 0
             MOVE SPACES TO WS-BIOME
             IF WS-Y < -64 OR WS-Y > 319
                 MOVE 0 TO WS-OK
             ELSE
                 COMPUTE WS-LX = WS-X - J-CX * 16
                 COMPUTE WS-LZ = WS-Z - J-CZ * 16
                 IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
                     SET ADDRESS OF CE-CHUNK TO J-ADDR
                     COMPUTE WS-SECTION = (WS-Y + 64) / 16
                     COMPUTE WS-LY = FUNCTION MOD(WS-Y + 64, 16) / 4
                     COMPUTE WS-CELL = WS-SECTION * 64 + WS-LY * 16 + FUNCTION INTEGER(WS-LZ / 4) * 4 + FUNCTION INTEGER(WS-LX / 4) + 1
                     MOVE CE-BIOME(WS-CELL) TO WS-ID
                     COMPUTE WS-INDEX = WS-ID + 1
                     IF WS-ID < CBI-COUNT
                         MOVE CBI-KEY(WS-INDEX)(1:40) TO WS-BIOME
                     END-IF
                 ELSE
                     IF CL-COUNT > 0
                         COMPUTE WS-QX = FUNCTION INTEGER(WS-X / 4)
                         COMPUTE WS-QY = FUNCTION INTEGER(WS-Y / 4)
                         COMPUTE WS-QZ = FUNCTION INTEGER(WS-Z / 4)
                         CALL "CLIMATE-BIOME-AT" USING WS-QX WS-QY WS-QZ WS-INDEX WS-BIOME
                     END-IF
                 END-IF
                 IF WS-OK = 1
                     CALL "ORE-BIOME-OK" USING OT-BIOME(WS-ROW) WS-BIOME WS-OK
                 END-IF
             END-IF
         END-IF
         IF WS-OK = 1
             CALL "ORE-PLACE-BLOB" USING L-JOB WS-XR WS-ROW WS-X WS-Y WS-Z
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-STAGE-ORES.
