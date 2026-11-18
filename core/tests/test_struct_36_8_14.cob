*> Acceptance test of the bastion's pool graphs and connector odds (docs/protocol/36-structures-8-nether-and-end.md sections 13.1, 14, 15.1, 15.2, 15.5, 17.1, 17.3; T26002): on the generated
*> vanilla-data (CC_GENERATED_DIR, read only; passes as skipped without it) the closure of each start element is followed through the jigsaw pool values of its templates and the elements of
*> its pools, and counted against the document: pools, templates, pool-element entries, processor lists and chests per variant (14), the connectors of each mob and block pool by target name
*> (15.2), the weights that make the first-choice odds of 15.1/15.2/17.1 (attachable weight, result weights), the entity each mob template stores, the ten melee connectors of the treasure
*> room by template (17.3) and its 2.67 expected brutes of main_entrance, the single spawner of the treasure closure (15.4) and that every element is single_pool_element, rigid (13.1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-14.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTJIG.
 COPY STRUCTTPL.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-V                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-STARTS              BINARY-LONG.
 01 WS-POOL-ROW            BINARY-LONG.
 01 WS-ELEM                BINARY-LONG.
 01 WS-LOC                 PIC X(96).
 01 WS-TROW                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-PKEY                PIC X(80).
 01 WS-PROW                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
*> the closure being followed
 01 WS-PV.
    05 WS-PV-FLAG          BINARY-LONG OCCURS 200 TIMES.
 01 WS-TS.
    05 WS-T-NAME           PIC X(96) OCCURS 120 TIMES.
    05 WS-T-DONE           BINARY-LONG OCCURS 120 TIMES.
 01 WS-T-COUNT             BINARY-LONG.
 01 WS-POOLS               BINARY-LONG.
 01 WS-ENTRIES             BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-BAD-ELEM            BINARY-LONG VALUE 0.
 01 WS-LOST                BINARY-LONG VALUE 0.
 01 WS-SPAWNERS            BINARY-LONG.
*> processor lists: 12 names plus the inline empty
 01 WS-PROCS.
    05 FILLER PIC X(48) VALUE "minecraft:bastion_generic_degradation".
    05 FILLER PIC X(48) VALUE "minecraft:housing".
    05 FILLER PIC X(48) VALUE "minecraft:stable_degradation".
    05 FILLER PIC X(48) VALUE "minecraft:side_wall_degradation".
    05 FILLER PIC X(48) VALUE "minecraft:treasure_rooms".
    05 FILLER PIC X(48) VALUE "minecraft:high_wall".
    05 FILLER PIC X(48) VALUE "minecraft:roof".
    05 FILLER PIC X(48) VALUE "minecraft:bottom_rampart".
    05 FILLER PIC X(48) VALUE "minecraft:high_rampart".
    05 FILLER PIC X(48) VALUE "minecraft:bridge".
    05 FILLER PIC X(48) VALUE "minecraft:rampart_degradation".
    05 FILLER PIC X(48) VALUE "minecraft:entrance_replacement".
 01 WS-PR REDEFINES WS-PROCS.
    05 WS-PNAME            PIC X(48) OCCURS 12 TIMES.
 01 WS-PCOUNT.
    05 WS-PC               BINARY-LONG OCCURS 13 TIMES.
*> expected processor counts by variant, list order of WS-PROCS then the inline empty list
 01 WS-PEXP.
    05 FILLER PIC X(39) VALUE "000031000000000000000000000000000000009".
    05 FILLER PIC X(39) VALUE "000000051002000000000000000000000000011".
    05 FILLER PIC X(39) VALUE "000000000000050010003001001000000000007".
    05 FILLER PIC X(39) VALUE "005000000000000000000000000001005001009".
 01 WS-PE REDEFINES WS-PEXP.
    05 WS-PE-ROW           OCCURS 4 TIMES.
       10 WS-PE-N          PIC 999 OCCURS 13 TIMES.
*> expected: pools, templates, entries, chest tables (treasure, hoglin stable, bridge, other), spawners
 01 WS-EXP.
    05 FILLER PIC X(24) VALUE "018038040000000000011000".
    05 FILLER PIC X(24) VALUE "017062064000002000008000".
    05 FILLER PIC X(24) VALUE "022066072005000000006001".
    05 FILLER PIC X(24) VALUE "010019021000000001004000".
 01 WS-EX REDEFINES WS-EXP.
    05 WS-EX-ROW           OCCURS 4 TIMES.
       10 WS-EX-POOLS      PIC 999.
       10 WS-EX-TPLS       PIC 999.
       10 WS-EX-ENTRIES    PIC 999.
       10 WS-EX-TREASURE   PIC 999.
       10 WS-EX-STABLE     PIC 999.
       10 WS-EX-BRIDGE     PIC 999.
       10 WS-EX-OTHER      PIC 999.
       10 WS-EX-SPAWN      PIC 999.
 01 WS-CH-TREASURE         BINARY-LONG.
 01 WS-CH-STABLE           BINARY-LONG.
 01 WS-CH-BRIDGE           BINARY-LONG.
 01 WS-CH-OTHER            BINARY-LONG.
*> connectors per variant: piglin/mob, piglin_melee/mob, piglin_melee/melee, hoglin/mob, gold/block
 01 WS-CONN.
    05 WS-CN               BINARY-LONG OCCURS 5 TIMES.
 01 WS-CEXP.
    05 FILLER PIC X(15) VALUE "020006000000008".
    05 FILLER PIC X(15) VALUE "027006000010003".
    05 FILLER PIC X(15) VALUE "022008010000000".
    05 FILLER PIC X(15) VALUE "029004000002000".
 01 WS-CE REDEFINES WS-CEXP.
    05 WS-CE-ROW           OCCURS 4 TIMES.
       10 WS-CE-N          PIC 999 OCCURS 5 TIMES.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DETAIL              PIC X(200).
 01 WS-NUM                 PIC 999.
 01 WS-NOTE                PIC -(9)9.
*> mob pools: attachable weight by target and result weights
 01 WS-POOL-KEY            PIC X(80).
 01 WS-TARGET              PIC X(48).
 01 WS-ATTACH              BINARY-LONG.
 01 WS-W-MELEE             BINARY-LONG.
 01 WS-W-ALWAYS            BINARY-LONG.
 01 WS-W-SWORD             BINARY-LONG.
 01 WS-W-CROSS             BINARY-LONG.
 01 WS-W-EMPTY             BINARY-LONG.
 01 WS-W-HOG               BINARY-LONG.
 01 WS-W-AIR               BINARY-LONG.
 01 WS-W-GOLD              BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-ENT-ID              PIC X(24).
 01 WS-TALLY               BINARY-LONG.
 01 WS-WORD                PIC X(24).
 01 WS-MELEE-N             BINARY-LONG.
 01 WS-MOB-N               BINARY-LONG.
 01 WS-MELEE-TOTAL         BINARY-LONG.
 01 WS-EXPECT-LOC.
    05 FILLER PIC X(64) VALUE "bases/centers/center_0".
    05 FILLER PIC X(64) VALUE "bases/centers/center_1".
    05 FILLER PIC X(64) VALUE "bases/centers/center_2".
    05 FILLER PIC X(64) VALUE "bases/centers/center_3".
    05 FILLER PIC X(64) VALUE "bases/lava_basin".
    05 FILLER PIC X(64) VALUE "ramparts/mid_wall_main".
    05 FILLER PIC X(64) VALUE "walls/bottom/wall_0".
    05 FILLER PIC X(64) VALUE "walls/mid/wall_0".
    05 FILLER PIC X(64) VALUE "walls/top/main_entrance".
 01 WS-EL REDEFINES WS-EXPECT-LOC.
    05 WS-EL-SUFFIX        PIC X(64) OCCURS 9 TIMES.
 01 WS-EL-N                BINARY-LONG OCCURS 9 TIMES.
 01 WS-LEN                 BINARY-LONG.
 01 WS-LEN2                BINARY-LONG.
 01 WS-MAIN-MELEE          BINARY-LONG.
 01 WS-MAIN-MOB            BINARY-LONG.
 01 WS-SUM-MELEE           BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-NEWLOC              PIC X(96).
 01 WS-ODDS                PIC X(120).
 01 WS-ODDS-WANT           PIC X(120).
 01 WS-A2                  PIC 99.
 01 WS-D1                  PIC 9.
 01 WS-NAMES.
    05 WS-NM               BINARY-LONG OCCURS 8 TIMES.
 01 WS-HANDS               PIC X(200).
 01 WS-PTR                 BINARY-LONG.
 01 WS-SHORT               PIC X(24).
 01 WS-ONE-BIG             BINARY-LONG.
 01 WS-MAIN-W              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-8§14 C. The four variants and their pool graphs: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "JIG-RESET"
     MOVE "minecraft:bastion/starts" TO WS-PKEY
     CALL "JIG-POOL-FIND" USING WS-PKEY WS-POOL-ROW
     MOVE "acceptance US12 36-8§13.1 C. Parameters: the start pool has four elements of weight 1 (single_pool_element, rigid)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-POOL-ROW > 1 AND JP-N(WS-POOL-ROW) = 4 AND JP-TOTAL(WS-POOL-ROW) = 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-POOL-ROW < 2
         STOP RUN
     END-IF
     MOVE JP-N(WS-POOL-ROW) TO WS-STARTS
     MOVE 0 TO WS-SUM-MELEE WS-MAIN-MELEE WS-MAIN-MOB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-EL-N(WS-I)
     END-PERFORM
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 4
         PERFORM FOLLOW-CLOSURE
         MOVE 0 TO WS-BAD
         MOVE WS-POOLS TO WS-NUM
         IF WS-NUM NOT = WS-EX-POOLS(WS-V)
             ADD 1 TO WS-BAD
         END-IF
         DISPLAY "PROBE variant " WS-V " pools " WS-POOLS " templates " WS-T-COUNT " entries " WS-ENTRIES " chests treasure " WS-CH-TREASURE " stable "
             WS-CH-STABLE " bridge " WS-CH-BRIDGE " other " WS-CH-OTHER " spawners " WS-SPAWNERS
         MOVE "acceptance US12 36-8§14 C. The four variants and their pool graphs: pools in the closure of the variant (the start pool not counted)" TO TL-CASE
         MOVE WS-EX-POOLS(WS-V) TO TL-EXPECTED-N
         MOVE WS-POOLS TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "acceptance US12 36-8§14 C. The four variants and their pool graphs: templates in the closure, the start included" TO TL-CASE
         MOVE WS-EX-TPLS(WS-V) TO TL-EXPECTED-N
         MOVE WS-T-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "acceptance US12 36-8§14 C. The four variants and their pool graphs: pool-element entries of the closure's pools" TO TL-CASE
         MOVE WS-EX-ENTRIES(WS-V) TO TL-EXPECTED-N
         MOVE WS-ENTRIES TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 13
             MOVE WS-PE-N(WS-V, WS-K) TO WS-NUM
             IF WS-PC(WS-K) NOT = WS-NUM
                 ADD 1 TO WS-BAD
                 DISPLAY "PROBE variant " WS-V " processor list " WS-K " count " WS-PC(WS-K) " expected " WS-NUM
             END-IF
         END-PERFORM
         MOVE "acceptance US12 36-8§14 C. The four variants and their pool graphs: processor lists referenced by the elements, with their counts" TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "acceptance US12 36-8§14 C. The four variants and their pool graphs: chest blocks of the closure's templates by loot table, and the spawner" TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-CH-TREASURE NOT = WS-EX-TREASURE(WS-V) OR WS-CH-STABLE NOT = WS-EX-STABLE(WS-V) OR WS-CH-BRIDGE NOT = WS-EX-BRIDGE(WS-V)
             OR WS-CH-OTHER NOT = WS-EX-OTHER(WS-V) OR WS-SPAWNERS NOT = WS-EX-SPAWN(WS-V)
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
             MOVE WS-CE-N(WS-V, WS-K) TO WS-NUM
             IF WS-CN(WS-K) NOT = WS-NUM
                 ADD 1 TO WS-BAD
                 DISPLAY "PROBE variant " WS-V " connector class " WS-K " count " WS-CN(WS-K) " expected " WS-NUM
             END-IF
         END-PERFORM
         MOVE "acceptance US12 36-8§15.2 C. Which element a connector gets: connectors per variant of each mob and block pool by target name" TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   17.3: the ten melee connectors of the treasure room by template (counted once per template while its closure was followed)
     MOVE SPACES TO WS-ODDS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         MOVE WS-EL-N(WS-S) TO WS-A2
         STRING WS-A2 " " DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
     END-PERFORM
     MOVE WS-SUM-MELEE TO WS-A2
     STRING WS-A2 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-8§17.3 C. Brute odds in a treasure room: melee connectors per template: center_0..3 1 2 1 1, lava_basin, mid_wall_main, wall_0 bottom, wall_0 mid, main_entrance 1 each, total 10" TO TL-CASE
     MOVE "01 02 01 01 01 01 01 01 01 10" TO TL-EXPECTED
     MOVE WS-ODDS(1:30) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-8§17.3 C. Brute odds in a treasure room: main_entrance has three piglin_melee connectors, one targeting melee_connector and two mob_connector" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 102
     COMPUTE TL-OBSERVED-N = WS-MAIN-MELEE * 100 + WS-MAIN-MOB
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   15.1, 15.2, 17.1: the attachable weight of each mob and block pool by the target of its parent connector and the weight of each result
     MOVE "T" TO TL-MODE
     MOVE "minecraft:bastion/mobs/piglin" TO WS-POOL-KEY
     MOVE "minecraft:mob_connector" TO WS-TARGET
     PERFORM POOL-ODDS
     MOVE "acceptance US12 36-8§17.1 C. Mob connector, step by step: mobs/piglin for a mob_connector attaches all four elements: brute 1, sword piglin 4, crossbow piglin 4, empty 1 of 10" TO TL-CASE
     MOVE "A10 m1 a0 s4 c4 e1 h0 a0 g0" TO TL-EXPECTED
     MOVE WS-ODDS(1:27) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:bastion/mobs/piglin_melee" TO WS-POOL-KEY
     PERFORM POOL-ODDS
     MOVE WS-NM(1) TO WS-MAIN-W
     MOVE "acceptance US12 36-8§15.2 C. Which element a connector gets: mobs/piglin_melee for a mob_connector attaches melee_piglin 5 and sword_piglin 1 of 6 (melee_piglin_always does not match)" TO TL-CASE
     MOVE "A06 m5 a0 s1 c0 e0 h0 a0 g0" TO TL-EXPECTED
     MOVE WS-ODDS(1:27) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:melee_connector" TO WS-TARGET
     PERFORM POOL-ODDS
     MOVE "acceptance US12 36-8§15.2 C. Which element a connector gets: mobs/piglin_melee for a melee_connector attaches only melee_piglin_always (a brute with certainty)" TO TL-CASE
     MOVE "A01 m0 a1 s0 c0 e0 h0 a0 g0" TO TL-EXPECTED
     MOVE WS-ODDS(1:27) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:bastion/mobs/hoglin" TO WS-POOL-KEY
     MOVE "minecraft:mob_connector" TO WS-TARGET
     PERFORM POOL-ODDS
     MOVE "acceptance US12 36-8§15.2 C. Which element a connector gets: mobs/hoglin for a mob_connector attaches hoglin 2 and empty 1 of 3" TO TL-CASE
     MOVE "A03 m0 a0 s0 c0 e1 h2 a0 g0" TO TL-EXPECTED
     MOVE WS-ODDS(1:27) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:bastion/blocks/gold" TO WS-POOL-KEY
     MOVE "minecraft:block_connector" TO WS-TARGET
     PERFORM POOL-ODDS
     MOVE "acceptance US12 36-8§15.2 C. Which element a connector gets: blocks/gold for a block_connector attaches air 3 and gold block 1 of 4" TO TL-CASE
     MOVE "A04 m0 a0 s0 c0 e0 h0 a3 g1" TO TL-EXPECTED
     MOVE WS-ODDS(1:27) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§17.3 C. Brute odds in a treasure room: the expected brutes of main_entrance are 1 + 2 x 5/6 = 16/6 (six times the sum is 6 x 1 + 5 x 2)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 16 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = 6 * WS-MAIN-MELEE + WS-MAIN-W * WS-MAIN-MOB
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   15.1: what each mob template stores: one entity (the brute, the piglin or the hoglin), the piglins' hands
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-HANDS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 7
         EVALUATE WS-S
             WHEN 1 MOVE "minecraft:bastion/mobs/melee_piglin_always" TO WS-LOC
             WHEN 2 MOVE "minecraft:bastion/mobs/melee_piglin" TO WS-LOC
             WHEN 3 MOVE "minecraft:bastion/mobs/sword_piglin" TO WS-LOC
             WHEN 4 MOVE "minecraft:bastion/mobs/crossbow_piglin" TO WS-LOC
             WHEN 5 MOVE "minecraft:bastion/mobs/hoglin" TO WS-LOC
             WHEN 6 MOVE "minecraft:bastion/mobs/empty" TO WS-LOC
             WHEN OTHER MOVE "minecraft:bastion/blocks/gold" TO WS-LOC
         END-EVALUATE
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-LOC WS-TROW
         MOVE "-" TO WS-SHORT
         MOVE 0 TO WS-N
         IF WS-TROW > 0
             MOVE TP-ENTITIES(WS-TROW) TO WS-N
         END-IF
         IF WS-N > 0
             COMPUTE WS-K = TP-ENT-BASE(WS-TROW) + 1
             MOVE 0 TO WS-TALLY
             INSPECT TE-DATA(WS-K)(1:TE-LEN(WS-K)) TALLYING WS-TALLY FOR ALL "minecraft:piglin_brute"
             IF WS-TALLY > 0
                 MOVE "B" TO WS-SHORT
             END-IF
             MOVE 0 TO WS-TALLY
             INSPECT TE-DATA(WS-K)(1:TE-LEN(WS-K)) TALLYING WS-TALLY FOR ALL "minecraft:hoglin"
             IF WS-TALLY > 0
                 MOVE "H" TO WS-SHORT
             END-IF
             IF WS-SHORT = "-"
                 MOVE "P" TO WS-SHORT
             END-IF
             MOVE 0 TO WS-TALLY
             INSPECT TE-DATA(WS-K)(1:TE-LEN(WS-K)) TALLYING WS-TALLY FOR ALL "golden_sword"
             IF WS-TALLY > 0
                 STRING FUNCTION TRIM(WS-SHORT) "+sword" DELIMITED BY SIZE INTO WS-SHORT
             END-IF
             MOVE 0 TO WS-TALLY
             INSPECT TE-DATA(WS-K)(1:TE-LEN(WS-K)) TALLYING WS-TALLY FOR ALL "crossbow"
             IF WS-TALLY > 0
                 STRING FUNCTION TRIM(WS-SHORT) "+crossbow" DELIMITED BY SIZE INTO WS-SHORT
             END-IF
         END-IF
         STRING FUNCTION TRIM(WS-SHORT) " " DELIMITED BY SIZE INTO WS-HANDS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 36-8§15.1 C. Connectors and mob templates: each template stores its mob: brute, brute, piglin with sword, piglin with crossbow, hoglin, nothing, nothing" TO TL-CASE
     MOVE "B B P+sword P+crossbow H - -" TO TL-EXPECTED
     MOVE WS-HANDS(1:30) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-8§13.1 C. Parameters: every element of the four closures is a single_pool_element with projection rigid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-ELEM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§14 C. The four variants and their pool graphs: no jigsaw pool name was lost (every pool value resolves to a pool)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LOST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 FOLLOW-CLOSURE.
*>   the start element's template, then every template of every pool its jigsaws name, until nothing is new
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE 0 TO WS-PV-FLAG(WS-I)
     END-PERFORM
     MOVE 0 TO WS-T-COUNT WS-POOLS WS-ENTRIES WS-SPAWNERS WS-CH-TREASURE WS-CH-STABLE WS-CH-BRIDGE WS-CH-OTHER
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 13
         MOVE 0 TO WS-PC(WS-K)
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE 0 TO WS-CN(WS-K)
     END-PERFORM
     COMPUTE WS-B = JP-FIRST(WS-POOL-ROW) + WS-V - 1
     MOVE JN-ELEM(WS-B) TO WS-ELEM
     MOVE JE-LOC(WS-ELEM) TO WS-NEWLOC
     PERFORM ADD-TEMPLATE
     MOVE 1 TO WS-CHANGED
     PERFORM UNTIL WS-CHANGED = 0
         MOVE 0 TO WS-CHANGED
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-T-COUNT
             IF WS-T-DONE(WS-I) = 0
                 MOVE 1 TO WS-T-DONE(WS-I)
                 MOVE 1 TO WS-CHANGED
                 PERFORM READ-TEMPLATE
             END-IF
         END-PERFORM
     END-PERFORM
     EXIT PARAGRAPH.
 ADD-TEMPLATE.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-T-COUNT
         IF WS-T-NAME(WS-S) = WS-NEWLOC
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0 AND WS-T-COUNT < 120
         ADD 1 TO WS-T-COUNT
         MOVE WS-NEWLOC TO WS-T-NAME(WS-T-COUNT)
         MOVE 0 TO WS-T-DONE(WS-T-COUNT)
     END-IF
     EXIT PARAGRAPH.
 READ-TEMPLATE.
*>   the template's own jigsaws (their pools and targets) and its chests and spawners
     MOVE WS-T-NAME(WS-I) TO WS-LOC
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-LOC WS-TROW
     IF WS-TROW < 1
         ADD 1 TO WS-LOST
         DISPLAY "PROBE template not loaded " FUNCTION TRIM(WS-LOC) " row " WS-TROW
         EXIT PARAGRAPH
     END-IF
     CALL "JIG-TPL-JIGS" USING WS-TROW WS-FIRST WS-N
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-N
         COMPUTE WS-K = WS-FIRST + WS-J
         MOVE JX-TAG(WS-K) TO WS-TAG
         PERFORM COUNT-CONNECTOR
         IF TN-POOL(WS-TAG) NOT = "minecraft:empty"
             MOVE TN-POOL(WS-TAG) TO WS-PKEY
             CALL "JIG-POOL-FIND" USING WS-PKEY WS-PROW
             IF WS-PROW < 2
                 ADD 1 TO WS-LOST
                 DISPLAY "PROBE pool not found " FUNCTION TRIM(WS-PKEY)
             ELSE
                 IF WS-PV-FLAG(WS-PROW) = 0
                     MOVE 1 TO WS-PV-FLAG(WS-PROW)
                     ADD 1 TO WS-POOLS
                     PERFORM TAKE-POOL
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-LOC WS-TROW
     COMPUTE WS-BASE = TP-BASE(WS-TROW, 1)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TP-BLOCKS(WS-TROW)
         MOVE TB-NBT(WS-BASE + WS-J) TO WS-TAG
         IF WS-TAG > 0
             IF TN-KIND(WS-TAG) = 2
                 ADD 1 TO WS-SPAWNERS
             END-IF
             IF TN-KIND(WS-TAG) = 1 AND TN-LOOT(WS-TAG) NOT = SPACES
                 EVALUATE TN-LOOT(WS-TAG)
                     WHEN "minecraft:chests/bastion_treasure"
                         ADD 1 TO WS-CH-TREASURE
                     WHEN "minecraft:chests/bastion_hoglin_stable"
                         ADD 1 TO WS-CH-STABLE
                     WHEN "minecraft:chests/bastion_bridge"
                         ADD 1 TO WS-CH-BRIDGE
                     WHEN "minecraft:chests/bastion_other"
                         ADD 1 TO WS-CH-OTHER
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     EXIT PARAGRAPH.
 COUNT-CONNECTOR.
     IF WS-V = 3 AND TN-TARGET(WS-TAG) = "minecraft:melee_connector"
         ADD 1 TO WS-SUM-MELEE
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
             MOVE 0 TO WS-TALLY
             INSPECT WS-LOC TALLYING WS-TALLY FOR ALL FUNCTION TRIM(WS-EL-SUFFIX(WS-S))
             IF WS-TALLY > 0
                 ADD 1 TO WS-EL-N(WS-S)
             END-IF
         END-PERFORM
     END-IF
     IF WS-V = 3 AND TN-POOL(WS-TAG) = "minecraft:bastion/mobs/piglin_melee"
         MOVE 0 TO WS-TALLY
         INSPECT WS-LOC TALLYING WS-TALLY FOR ALL "walls/top/main_entrance"
         IF WS-TALLY > 0 AND TN-TARGET(WS-TAG) = "minecraft:melee_connector"
             ADD 1 TO WS-MAIN-MELEE
         END-IF
         IF WS-TALLY > 0 AND TN-TARGET(WS-TAG) = "minecraft:mob_connector"
             ADD 1 TO WS-MAIN-MOB
         END-IF
     END-IF
     EVALUATE TRUE
         WHEN TN-POOL(WS-TAG) = "minecraft:bastion/mobs/piglin" AND TN-TARGET(WS-TAG) = "minecraft:mob_connector"
             ADD 1 TO WS-CN(1)
         WHEN TN-POOL(WS-TAG) = "minecraft:bastion/mobs/piglin_melee" AND TN-TARGET(WS-TAG) = "minecraft:mob_connector"
             ADD 1 TO WS-CN(2)
         WHEN TN-POOL(WS-TAG) = "minecraft:bastion/mobs/piglin_melee" AND TN-TARGET(WS-TAG) = "minecraft:melee_connector"
             ADD 1 TO WS-CN(3)
         WHEN TN-POOL(WS-TAG) = "minecraft:bastion/mobs/hoglin" AND TN-TARGET(WS-TAG) = "minecraft:mob_connector"
             ADD 1 TO WS-CN(4)
         WHEN TN-POOL(WS-TAG) = "minecraft:bastion/blocks/gold" AND TN-TARGET(WS-TAG) = "minecraft:block_connector"
             ADD 1 TO WS-CN(5)
     END-EVALUATE
     EXIT PARAGRAPH.
POOL-ODDS.
*>   WS-ODDS: A<attachable weight> m melee_piglin a melee_piglin_always s sword c crossbow e empty h hoglin a air g gold, the weights of the attachable entries
     CALL "JIG-POOL-FIND" USING WS-POOL-KEY WS-PROW
     MOVE 0 TO WS-ATTACH
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 8
         MOVE 0 TO WS-NM(WS-S)
     END-PERFORM
     PERFORM VARYING WS-Q FROM 0 BY 1 UNTIL WS-Q >= JP-N(WS-PROW)
         COMPUTE WS-B = JP-FIRST(WS-PROW) + WS-Q
         MOVE JE-LOC(JN-ELEM(WS-B)) TO WS-LOC
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-LOC WS-TROW
         CALL "JIG-TPL-JIGS" USING WS-TROW WS-FIRST WS-N
         MOVE 0 TO WS-HAS
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-N
             COMPUTE WS-K = WS-FIRST + WS-J
             IF TN-NAME(JX-TAG(WS-K)) = WS-TARGET
                 MOVE 1 TO WS-HAS
             END-IF
         END-PERFORM
         IF WS-HAS = 1
             ADD JN-WEIGHT(WS-B) TO WS-ATTACH
             EVALUATE TRUE
                 WHEN WS-LOC = "minecraft:bastion/mobs/melee_piglin"
                     ADD JN-WEIGHT(WS-B) TO WS-NM(1)
                 WHEN WS-LOC = "minecraft:bastion/mobs/melee_piglin_always"
                     ADD JN-WEIGHT(WS-B) TO WS-NM(2)
                 WHEN WS-LOC = "minecraft:bastion/mobs/sword_piglin"
                     ADD JN-WEIGHT(WS-B) TO WS-NM(3)
                 WHEN WS-LOC = "minecraft:bastion/mobs/crossbow_piglin"
                     ADD JN-WEIGHT(WS-B) TO WS-NM(4)
                 WHEN WS-LOC = "minecraft:bastion/mobs/empty"
                     ADD JN-WEIGHT(WS-B) TO WS-NM(5)
                 WHEN WS-LOC = "minecraft:bastion/mobs/hoglin"
                     ADD JN-WEIGHT(WS-B) TO WS-NM(6)
                 WHEN WS-LOC = "minecraft:bastion/blocks/air"
                     ADD JN-WEIGHT(WS-B) TO WS-NM(7)
                 WHEN WS-LOC = "minecraft:bastion/blocks/gold"
                     ADD JN-WEIGHT(WS-B) TO WS-NM(8)
             END-EVALUATE
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-ODDS
     MOVE 1 TO WS-PTR
     MOVE WS-ATTACH TO WS-A2
     STRING "A" WS-A2 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 8
         MOVE WS-NM(WS-S) TO WS-D1
         EVALUATE WS-S
             WHEN 1 STRING " m" WS-D1 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
             WHEN 2 STRING " a" WS-D1 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
             WHEN 3 STRING " s" WS-D1 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
             WHEN 4 STRING " c" WS-D1 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
             WHEN 5 STRING " e" WS-D1 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
             WHEN 6 STRING " h" WS-D1 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
             WHEN 7 STRING " a" WS-D1 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
             WHEN OTHER STRING " g" WS-D1 DELIMITED BY SIZE INTO WS-ODDS WITH POINTER WS-PTR
         END-EVALUATE
     END-PERFORM
     EXIT PARAGRAPH.
 TAKE-POOL.
*>   the entries of the pool: their processor list and template; the fallback pool is minecraft:empty (no entries)
     PERFORM VARYING WS-Q FROM 0 BY 1 UNTIL WS-Q >= JP-N(WS-PROW)
         COMPUTE WS-B = JP-FIRST(WS-PROW) + WS-Q
         MOVE JN-ELEM(WS-B) TO WS-ELEM
         ADD 1 TO WS-ENTRIES
         IF JE-KIND(WS-ELEM) NOT = 1 OR JE-PROJ(WS-ELEM) NOT = 0
             ADD 1 TO WS-BAD-ELEM
         END-IF
         MOVE 13 TO WS-P
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 12
             IF JE-PROC(WS-ELEM) = WS-PNAME(WS-R)
                 MOVE WS-R TO WS-P
             END-IF
         END-PERFORM
         ADD 1 TO WS-PC(WS-P)
         MOVE JE-LOC(WS-ELEM) TO WS-NEWLOC
         IF WS-NEWLOC NOT = SPACES
             PERFORM ADD-TEMPLATE
         END-IF
     END-PERFORM
     EXIT PARAGRAPH.
 END PROGRAM TEST-STRUCT-36-8-14.

 COPY NOSPAWN.
 COPY CORETEST.
