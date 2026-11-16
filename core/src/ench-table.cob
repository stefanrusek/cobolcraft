*> The enchanting table's rules over the registry and the world (docs/protocol/17 section 6.5, 40-4 section 2.4 and 2.5; lane itemcomp3, T10600 and on): the cost fields of an enchantment, the
*> enchantability of a stack, selectEnchantment (the weighted pick over the tag in_enchanting_table), getEnchantmentList (the seeded list of an option) and the bookshelf count.
*> A list is a table of 16 pairs (enchantment id, level). The random is the java.util.Random state of rng-java.cob (BINARY-DOUBLE UNSIGNED); floats follow Java's float arithmetic through the
*> cc_f64 shim (every operation rounded to a 32-bit float).
*>   ENCH-COST-DEF USING enchantment id, min base, min per level, max base, max per level, primary items out (PIC X(112), the tag without #; the supported tag when the entry has none), found out
*>   ENCH-ENCHANTABILITY USING item, handle, enchantability out, ok out (the item has an enchantable component and no enchantments: 2.4 step 1)
*>   ENCH-SELECT USING random state, item, level, enchantability, count out, list out   selectEnchantment (17 6.5 "Selection")
*>   ENCH-OFFER USING enchantment seed, slot index, item, enchantability, cost, random state out, count out, list out   getEnchantmentList (2.5)
*>   ENCH-SHELVES USING dim, x, y, z, bookshelf count out   the valid bookshelf offsets around the table (17 6.5)
*> Gaps: an enchantable component of a stack's own patch is not read (the item's default only); a supported_items or primary_items entry that is a single key and not a tag is read as a tag.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-COST-DEF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY JSONDOC.
 01 WS-JNAME               PIC X(32).
 01 WS-JNAME-LENGTH        BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-REGISTRY            PIC X(112) VALUE "enchantment".
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-AREA                PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-ANVIL               BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-EXCLUSIVE           PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-MIN-BASE             BINARY-LONG.
 01 L-MIN-PER              BINARY-LONG.
 01 L-MAX-BASE             BINARY-LONG.
 01 L-MAX-PER              BINARY-LONG.
 01 L-PRIMARY              PIC X(112).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-MIN-BASE L-MIN-PER L-MAX-BASE L-MAX-PER L-PRIMARY L-FOUND.
     MOVE 0 TO L-MIN-BASE L-MIN-PER L-MAX-BASE L-MAX-PER
     CALL "ENCH-DEF" USING L-ID WS-MAX WS-ANVIL WS-WEIGHT WS-TAG WS-EXCLUSIVE L-FOUND
     MOVE WS-TAG TO L-PRIMARY
     IF L-FOUND = 0
         GOBACK
     END-IF
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY L-ID WS-KEY WS-KEY-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
*>   A data tree keeps strict JSON; the built-in set's network NBT has no costs (they stay 0).
     IF WS-AREA(1:1) NOT = "{"
         GOBACK
     END-IF
     CALL "JSON-PARSE" USING JSON-DOC WS-AREA WS-LENGTH
     MOVE "min_cost" TO WS-JNAME
     MOVE 8 TO WS-JNAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
     PERFORM READ-COST
     MOVE WS-SUB TO L-MIN-BASE
     MOVE WS-COUNT TO L-MIN-PER
     MOVE "max_cost" TO WS-JNAME
     MOVE 8 TO WS-JNAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
     PERFORM READ-COST
     MOVE WS-SUB TO L-MAX-BASE
     MOVE WS-COUNT TO L-MAX-PER
     MOVE "primary_items" TO WS-JNAME
     MOVE 13 TO WS-JNAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
     IF WS-NODE > 0 AND JN-TYPE(WS-NODE) = JT-STRING
         MOVE SPACES TO WS-TAG
         MOVE WS-AREA(JN-POS(WS-NODE):JN-LENGTH(WS-NODE)) TO WS-TAG
         IF WS-TAG(1:1) = "#"
             MOVE WS-TAG(2:111) TO L-PRIMARY
         ELSE
             MOVE WS-TAG TO L-PRIMARY
         END-IF
     END-IF
     GOBACK.

*> The cost object of WS-NODE: base in WS-SUB, per_level_above_first in WS-COUNT.
 READ-COST.
     MOVE 0 TO WS-SUB WS-COUNT
     IF WS-NODE > 0
         MOVE WS-NODE TO WS-ROOT
         MOVE "base" TO WS-JNAME
         MOVE 4 TO WS-JNAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
         IF WS-NODE > 0
             MOVE JN-NUM(WS-NODE) TO WS-SUB
         END-IF
         MOVE "per_level_above_first" TO WS-JNAME
         MOVE 21 TO WS-JNAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
         IF WS-NODE > 0
             MOVE JN-NUM(WS-NODE) TO WS-COUNT
         END-IF
         MOVE 1 TO WS-ROOT
     END-IF.
 END PROGRAM ENCH-COST-DEF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-ENCHANTABILITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-NAME                PIC X(32) VALUE "enchantable".
 01 WS-TEXT                PIC X(100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 13.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-HANDLE L-N L-OK.
     MOVE 0 TO L-N L-OK
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     CALL "CONTENT-ITEM-COMPONENT" USING L-ITEM WS-NAME WS-TEXT WS-STATUS
     IF WS-STATUS = 0
         COMPUTE L-N = FUNCTION NUMVAL(WS-TEXT)
         MOVE 1 TO L-OK
     ELSE
*>       The book's enchantability is 1 (25 item table, row `book`).
         IF IT-KEY(L-ITEM + 1) = "minecraft:book" OR IT-KEY(L-ITEM + 1) = "book"
             MOVE 1 TO L-N L-OK
         END-IF
     END-IF
     IF L-OK = 1
         CALL "SC-ENCH-COUNT" USING L-HANDLE WS-TYPE WS-COUNT
         IF WS-COUNT > 0
             MOVE 0 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENCH-ENCHANTABILITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-SELECT.
*> The pool is the tag in_enchanting_table in tag order. m = level + 1 + nextInt(N / 4 + 1) twice, scaled by f = (nextFloat + nextFloat - 1) x 0.15 and clamped to 1 or more; a candidate is
*> an enchantment whose primary items hold the item (any for a book) at its highest level whose cost range holds m; the first is picked by weight, then while nextInt(50) <= m the candidates that
*> exclude the last pick (and the pick itself) are dropped and another is picked with m halved.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-ENCH-REG            PIC X(48) VALUE "enchantment".
 01 WS-ITEM-REG            PIC X(48) VALUE "item".
 01 WS-POOL-TAG            PIC X(112) VALUE "minecraft:in_enchanting_table".
 01 WS-POOL.
    05 WS-POOL-ID          BINARY-LONG OCCURS 64 TIMES.
 01 WS-POOL-N              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-CAND.
    05 WS-C OCCURS 64 TIMES.
       10 WS-C-ID          BINARY-LONG.
       10 WS-C-LEVEL       BINARY-LONG.
       10 WS-C-WEIGHT      BINARY-LONG.
 01 WS-NC                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 01 WS-K15R                FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-U2                  FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-K15                 FLOAT-LONG.
 01 WS-K15-TEXT            PIC X(5) VALUE Z"0.15".
 01 WS-F                   FLOAT-LONG.
 01 WS-MF                 FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-ANVIL               BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-EXCL                PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 01 WS-MINB                BINARY-LONG.
 01 WS-MINP                BINARY-LONG.
 01 WS-MAXB                BINARY-LONG.
 01 WS-MAXP                BINARY-LONG.
 01 WS-PRIMARY             PIC X(112).
 01 WS-HAS                 BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-LV                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PICKED              BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LAST-ID             BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG VALUE 50.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ST                   BINARY-DOUBLE UNSIGNED.
 01 L-ITEM                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-LIST.
    05 L-E OCCURS 16 TIMES.
       10 L-EID            BINARY-LONG.
       10 L-ELV            BINARY-LONG.
 PROCEDURE DIVISION USING L-ST L-ITEM L-LEVEL L-N L-COUNT L-LIST.
     MOVE 0 TO L-COUNT WS-NC
     COMPUTE WS-Q = L-N / 4 + 1
     CALL "JRAND-NEXT-INT-BOUND" USING L-ST WS-Q WS-D1
     CALL "JRAND-NEXT-INT-BOUND" USING L-ST WS-Q WS-D2
     COMPUTE WS-M = L-LEVEL + 1 + WS-D1 + WS-D2
     PERFORM SCALE-M
     MOVE 0 TO WS-BOOK
     IF L-ITEM > 0 AND L-ITEM < IT-COUNT
         IF IT-KEY(L-ITEM + 1) = "minecraft:book" OR IT-KEY(L-ITEM + 1) = "book"
             MOVE 1 TO WS-BOOK
         END-IF
     END-IF
     CALL "CONTENT-TAG-MEMBERS" USING WS-ENCH-REG WS-POOL-TAG WS-POOL-N WS-POOL WS-CAP WS-STATUS
     IF WS-STATUS NOT = 0
         MOVE 0 TO WS-POOL-N
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-POOL-N
         PERFORM ADD-CANDIDATE
     END-PERFORM
     IF WS-NC > 0
         PERFORM PICK-ONE
         MOVE 0 TO WS-DONE
         PERFORM UNTIL WS-DONE = 1
             CALL "JRAND-NEXT-INT-BOUND" USING L-ST WS-LIMIT WS-DRAW
             IF WS-DRAW > WS-M
                 MOVE 1 TO WS-DONE
             ELSE
                 PERFORM DROP-INCOMPATIBLE
                 IF WS-NC = 0
                     MOVE 1 TO WS-DONE
                 ELSE
                     PERFORM PICK-ONE
                     COMPUTE WS-M = WS-M / 2
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.

*> m = clamp(round(m + m x f), 1, 2147483647) with f = (a + b - 1) x 0.15 in float arithmetic.
 SCALE-M.
     CALL "JRAND-NEXT-FLOAT" USING L-ST WS-A
     CALL "JRAND-NEXT-FLOAT" USING L-ST WS-B
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-A WS-B WS-S
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-S WS-S2
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-S2 WS-ONE WS-S
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-S WS-S2
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-K15-TEXT WS-K15
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-K15 WS-K15R
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-S2 WS-K15R WS-S
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-S WS-F
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-M WS-MF
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-MF WS-F WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-T2
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-MF WS-T2 WS-U
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-U WS-U2
     CALL STATIC "cc_f64_round_f32" USING BY REFERENCE WS-U2 WS-M
     IF WS-M < 1
         MOVE 1 TO WS-M
     END-IF.

*> The enchantment WS-POOL-ID(WS-I) when the item is in its primary items (or the item is a book): its highest level whose cost range holds m.
 ADD-CANDIDATE.
     CALL "ENCH-DEF" USING WS-POOL-ID(WS-I) WS-MAX WS-ANVIL WS-WEIGHT WS-TAG WS-EXCL WS-FOUND
     IF WS-FOUND = 1
         CALL "ENCH-COST-DEF" USING WS-POOL-ID(WS-I) WS-MINB WS-MINP WS-MAXB WS-MAXP WS-PRIMARY WS-FOUND
         MOVE WS-BOOK TO WS-HAS
         IF WS-HAS = 0
             CALL "CONTENT-TAG-HAS" USING WS-ITEM-REG WS-PRIMARY L-ITEM WS-HAS
         END-IF
         IF WS-HAS = 1
             PERFORM VARYING WS-LV FROM WS-MAX BY -1 UNTIL WS-LV < 1
                 COMPUTE WS-LO = WS-MINB + WS-MINP * (WS-LV - 1)
                 COMPUTE WS-HI = WS-MAXB + WS-MAXP * (WS-LV - 1)
                 IF WS-M >= WS-LO AND WS-M <= WS-HI AND WS-NC < 64
                     ADD 1 TO WS-NC
                     MOVE WS-POOL-ID(WS-I) TO WS-C-ID(WS-NC)
                     MOVE WS-LV TO WS-C-LEVEL(WS-NC)
                     COMPUTE WS-C-WEIGHT(WS-NC) = FUNCTION MAX(WS-WEIGHT, 1)
                     MOVE 0 TO WS-LV
                 END-IF
             END-PERFORM
         END-IF
     END-IF.

*> getRandomItem: one nextInt(total weight) walked over the candidates; the pick joins the list.
 PICK-ONE.
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NC
         ADD WS-C-WEIGHT(WS-J) TO WS-TOTAL
     END-PERFORM
     CALL "JRAND-NEXT-INT-BOUND" USING L-ST WS-TOTAL WS-DRAW
     MOVE 0 TO WS-PICKED
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NC OR WS-PICKED > 0
         SUBTRACT WS-C-WEIGHT(WS-J) FROM WS-DRAW
         IF WS-DRAW < 0
             MOVE WS-J TO WS-PICKED
         END-IF
     END-PERFORM
     MOVE WS-C-ID(WS-PICKED) TO WS-LAST-ID
     IF L-COUNT < 16
         ADD 1 TO L-COUNT
         MOVE WS-C-ID(WS-PICKED) TO L-EID(L-COUNT)
         MOVE WS-C-LEVEL(WS-PICKED) TO L-ELV(L-COUNT)
     END-IF.

*> filterCompatibleEnchantments: the candidates compatible with the last pick stay (the pick itself is not compatible with itself).
 DROP-INCOMPATIBLE.
     MOVE 0 TO WS-KEEP
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NC
         MOVE 0 TO WS-OK
         IF WS-C-ID(WS-J) NOT = WS-LAST-ID
             CALL "ENCH-COMPATIBLE" USING WS-LAST-ID WS-C-ID(WS-J) WS-OK
         END-IF
         IF WS-OK = 1
             ADD 1 TO WS-KEEP
             MOVE WS-C(WS-J) TO WS-C(WS-KEEP)
         END-IF
     END-PERFORM
     MOVE WS-KEEP TO WS-NC.
 END PROGRAM ENCH-SELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-OFFER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-LSEED               BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-ST                   BINARY-DOUBLE UNSIGNED.
 01 L-COUNT                BINARY-LONG.
 01 L-LIST.
    05 L-E OCCURS 16 TIMES.
       10 L-EID            BINARY-LONG.
       10 L-ELV            BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-SLOT L-ITEM L-N L-COST L-ST L-COUNT L-LIST.
     CALL "ENCH-LIST-SEED" USING L-SEED L-SLOT WS-LSEED
     CALL "ENCH-STATE-SEED" USING WS-LSEED L-ST
     CALL "ENCH-SELECT" USING L-ST L-ITEM L-COST L-N L-COUNT L-LIST
     MOVE 0 TO WS-BOOK
     IF L-ITEM > 0 AND L-ITEM < IT-COUNT
         IF IT-KEY(L-ITEM + 1) = "minecraft:book" OR IT-KEY(L-ITEM + 1) = "book"
             MOVE 1 TO WS-BOOK
         END-IF
     END-IF
     CALL "ENCH-LIST-POST" USING L-ST WS-BOOK L-COUNT WS-IDX
     IF WS-IDX >= 0
         PERFORM VARYING WS-I FROM WS-IDX BY 1 UNTIL WS-I + 1 >= L-COUNT
             MOVE L-E(WS-I + 2) TO L-E(WS-I + 1)
         END-PERFORM
         SUBTRACT 1 FROM L-COUNT
     END-IF
     GOBACK.
 END PROGRAM ENCH-OFFER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-SHELVES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK-REG           PIC X(48) VALUE "block".
 01 WS-PROVIDER            PIC X(112) VALUE "minecraft:enchantment_power_provider".
 01 WS-TRANSMITTER         PIC X(112) VALUE "minecraft:enchantment_power_transmitter".
 01 WS-I                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PROV                BINARY-LONG.
 01 WS-TRANS               BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-B.
     MOVE 0 TO L-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         CALL "ENCH-OFFSET" USING WS-I WS-DX WS-DY WS-DZ WS-TX WS-TY WS-TZ
         MOVE 0 TO WS-PROV WS-TRANS
         COMPUTE WS-X = L-X + WS-DX
         COMPUTE WS-Y = L-Y + WS-DY
         COMPUTE WS-Z = L-Z + WS-DZ
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
         PERFORM STATE-BLOCK
         CALL "CONTENT-TAG-HAS" USING WS-BLOCK-REG WS-PROVIDER WS-BLOCK WS-PROV
         IF WS-PROV = 1
             COMPUTE WS-X = L-X + WS-TX
             COMPUTE WS-Y = L-Y + WS-TY
             COMPUTE WS-Z = L-Z + WS-TZ
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
             PERFORM STATE-BLOCK
             CALL "CONTENT-TAG-HAS" USING WS-BLOCK-REG WS-TRANSMITTER WS-BLOCK WS-TRANS
         END-IF
         MOVE L-B TO WS-PREV
         CALL "ENCH-POWER-ADD" USING WS-PREV WS-PROV WS-TRANS L-B
     END-PERFORM
     GOBACK.

*> The registry id of the block of the state WS-STATE (-1 outside the state table).
 STATE-BLOCK.
     MOVE -1 TO WS-BLOCK
     IF WS-STATE >= 0 AND WS-STATE < CB-STATE-COUNT
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     END-IF.
 END PROGRAM ENCH-SHELVES.
