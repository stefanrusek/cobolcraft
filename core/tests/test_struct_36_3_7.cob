*> Test of the pool aliases (docs/protocol/36-structures-3-jigsaw-assembly.md sections 3.4 and 7; core/src/struct-jig-alias.cob). The resolution of a binding list (direct, random, random_group,
*> nested groups, empty group) with the positional legacy random of the world seed at the start position (7.1, 7.2) is compared with an independent model (core/tests/fixtures/gen_jigsaw.py
*> alias_map): six (seed, position) pairs over a synthetic list and eight over the trial chambers' own list, which includes the two worked draws of 7.4 (seed 0 at (0, -30, 0): skeleton group,
*> zombie, cave_spider; seed 12345 at (16, -30, -32): poison_skeleton group, spider, baby_zombie). The lookup maps a key to its target in one step and every other key to itself; an empty list
*> maps nothing; a duplicate alias is flagged; malformed bindings and full tables are refused when read (3.4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-3-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY STRUCTJIG.
 COPY JSONDOC.
 01 SYN-DATA.
    05 FILLER BINARY-DOUBLE VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -30.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(200) VALUE "a=t1;b=b2;".
    05 FILLER BINARY-DOUBLE VALUE 12345.
    05 FILLER BINARY-LONG VALUE 16.
    05 FILLER BINARY-LONG VALUE -30.
    05 FILLER BINARY-LONG VALUE -32.
    05 FILLER PIC X(200) VALUE "a=t1;b=b1;c=c1;e=e1;".
    05 FILLER BINARY-DOUBLE VALUE 7.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 64.
    05 FILLER BINARY-LONG VALUE -9.
    05 FILLER PIC X(200) VALUE "a=t1;b=b2;c=c1;e=e1;".
    05 FILLER BINARY-DOUBLE VALUE -5.
    05 FILLER BINARY-LONG VALUE -100.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 200.
    05 FILLER PIC X(200) VALUE "a=t1;b=b2;c=c1;e=e1;".
    05 FILLER BINARY-DOUBLE VALUE 99999.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(200) VALUE "a=t1;b=b1;".
    05 FILLER BINARY-DOUBLE VALUE 42.
    05 FILLER BINARY-LONG VALUE 160.
    05 FILLER BINARY-LONG VALUE -30.
    05 FILLER BINARY-LONG VALUE 320.
    05 FILLER PIC X(200) VALUE "a=t1;b=b2;".
 01 SYN-TAB REDEFINES SYN-DATA.
    05 SYN-REC OCCURS 6 TIMES.
       10 SYN-SEED BINARY-DOUBLE.
       10 SYN-X BINARY-LONG.
       10 SYN-Y BINARY-LONG.
       10 SYN-Z BINARY-LONG.
       10 SYN-EXP PIC X(200).
 01 TC-DATA.
    05 FILLER BINARY-DOUBLE VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -30.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(200) VALUE "ranged/skeleton;slow_ranged/skeleton;melee/zombie;small_melee/cave_spider;".
    05 FILLER BINARY-DOUBLE VALUE 12345.
    05 FILLER BINARY-LONG VALUE 16.
    05 FILLER BINARY-LONG VALUE -30.
    05 FILLER BINARY-LONG VALUE -32.
    05 FILLER PIC X(200) VALUE "ranged/poison_skeleton;slow_ranged/poison_skeleton;melee/spider;small_melee/baby_zombie;".
    05 FILLER BINARY-DOUBLE VALUE 1.
    05 FILLER BINARY-LONG VALUE 48.
    05 FILLER BINARY-LONG VALUE -25.
    05 FILLER BINARY-LONG VALUE 64.
    05 FILLER PIC X(200) VALUE "ranged/skeleton;slow_ranged/skeleton;melee/spider;small_melee/cave_spider;".
    05 FILLER BINARY-DOUBLE VALUE -77.
    05 FILLER BINARY-LONG VALUE -16.
    05 FILLER BINARY-LONG VALUE -40.
    05 FILLER BINARY-LONG VALUE -16.
    05 FILLER PIC X(200) VALUE "ranged/skeleton;slow_ranged/skeleton;melee/spider;small_melee/slime;".
    05 FILLER BINARY-DOUBLE VALUE 31337.
    05 FILLER BINARY-LONG VALUE 512.
    05 FILLER BINARY-LONG VALUE -21.
    05 FILLER BINARY-LONG VALUE -512.
    05 FILLER PIC X(200) VALUE "ranged/skeleton;slow_ranged/skeleton;melee/zombie;small_melee/slime;".
    05 FILLER BINARY-DOUBLE VALUE 2024.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -35.
    05 FILLER BINARY-LONG VALUE 96.
    05 FILLER PIC X(200) VALUE "ranged/poison_skeleton;slow_ranged/poison_skeleton;melee/zombie;small_melee/baby_zombie;".
    05 FILLER BINARY-DOUBLE VALUE 5.
    05 FILLER BINARY-LONG VALUE 112.
    05 FILLER BINARY-LONG VALUE -22.
    05 FILLER BINARY-LONG VALUE 176.
    05 FILLER PIC X(200) VALUE "ranged/poison_skeleton;slow_ranged/poison_skeleton;melee/husk;small_melee/baby_zombie;".
    05 FILLER BINARY-DOUBLE VALUE 123456789012.
    05 FILLER BINARY-LONG VALUE -48.
    05 FILLER BINARY-LONG VALUE -30.
    05 FILLER BINARY-LONG VALUE 48.
    05 FILLER PIC X(200) VALUE "ranged/stray;slow_ranged/stray;melee/husk;small_melee/baby_zombie;".
 01 TC-TAB REDEFINES TC-DATA.
    05 TC-REC OCCURS 8 TIMES.
       10 TC-SEED BINARY-DOUBLE.
       10 TC-X BINARY-LONG.
       10 TC-Y BINARY-LONG.
       10 TC-Z BINARY-LONG.
       10 TC-EXP PIC X(200).
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TEXT                PIC X(6000).
 01 WS-DOC-TEXT            PIC X(6100).
 01 WS-LEN                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-OUT                 PIC X(300).
 01 WS-PTR                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY2                PIC X(80).
 01 WS-ED                  PIC -(9)9.
 01 WS-CASE                PIC X(200).
 01 WS-TRIAL               BINARY-LONG.
 01 WS-PRE                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   a synthetic list with nested groups: six seeds and positions
     MOVE 743 TO WS-LEN
     MOVE '[{"type": "minecraft:direct", "alias": "minecraft:a", "target": "minecraft:t1"}, {"type": "minecraft' &
         ':random", "alias": "minecraft:b", "targets": [{"data": "minecraft:b1", "weight": 1}, {"data": "minec' &
         'raft:b2", "weight": 3}]}, {"type": "minecraft:random_group", "groups": [{"data": [{"type": "minecraf' &
         't:random_group", "groups": [{"data": [{"type": "minecraft:direct", "alias": "minecraft:c", "target":' &
         ' "minecraft:c1"}], "weight": 2}, {"data": [{"type": "minecraft:direct", "alias": "minecraft:c", "tar' &
         'get": "minecraft:c2"}, {"type": "minecraft:direct", "alias": "minecraft:d", "target": "minecraft:d2"' &
         '}], "weight": 1}]}, {"type": "minecraft:direct", "alias": "minecraft:e", "target": "minecraft:e1"}],' &
         ' "weight": 1}, {"data": [], "weight": 1}]}]' TO WS-TEXT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE 0 TO SD-AL-COUNT SD-AL-ECOUNT
         PERFORM READ-LIST
         MOVE SYN-SEED(WS-K) TO WS-SEED
         MOVE SYN-X(WS-K) TO WS-PX
         MOVE SYN-Y(WS-K) TO WS-PY
         MOVE SYN-Z(WS-K) TO WS-PZ
         CALL "JIG-ALIAS-BUILD" USING WS-ROW WS-SEED WS-PX WS-PY WS-PZ
         PERFORM SHOW-MAP
         MOVE WS-K TO WS-ED
         MOVE SPACES TO WS-CASE
         STRING "acceptance US12 36-3§7.1 nested groups, case " FUNCTION TRIM(WS-ED) ": the resolved map equals the model's (alias=target in resolution order)" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE SYN-EXP(WS-K) TO TL-EXPECTED
         MOVE WS-OUT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "N" TO TL-MODE
     END-PERFORM
     MOVE "acceptance US12 36-3§7.2 a duplicate alias is not flagged by a resolution that binds each alias once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE JM-DUP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   an empty binding list maps nothing: every key maps to itself
     MOVE '[]' TO WS-TEXT
     MOVE 2 TO WS-LEN
     MOVE 0 TO SD-AL-COUNT SD-AL-ECOUNT
     PERFORM READ-LIST
     MOVE 5 TO WS-SEED
     CALL "JIG-ALIAS-BUILD" USING WS-ROW WS-SEED WS-PX WS-PY WS-PZ
     MOVE "minecraft:village/plains/houses" TO WS-KEY
     CALL "JIG-ALIAS-LOOKUP" USING WS-KEY WS-KEY2
     MOVE "acceptance US12 36-3§7.2 an empty binding list is the empty lookup: no pair, every key maps to itself" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF JM-COUNT = 0 AND WS-KEY2 = WS-KEY AND SDT-JIG-AL-N(WS-ROW) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the lookup is one step: a target is not looked up again
     MOVE '[{"type": "minecraft:direct", "alias": "minecraft:a", "target": "minecraft:b"}, {"type": "minecraft:direct", "alias": "minecraft:b", "target": "minecraft:c"}]' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     MOVE 0 TO SD-AL-COUNT SD-AL-ECOUNT
     PERFORM READ-LIST
     CALL "JIG-ALIAS-BUILD" USING WS-ROW WS-SEED WS-PX WS-PY WS-PZ
     MOVE "minecraft:a" TO WS-KEY
     CALL "JIG-ALIAS-LOOKUP" USING WS-KEY WS-KEY2
     MOVE "acceptance US12 36-3§7.2 lookup(a) is b, not c: a target is not looked up again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-KEY2 = "minecraft:b"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:z" TO WS-KEY
     CALL "JIG-ALIAS-LOOKUP" USING WS-KEY WS-KEY2
     MOVE "acceptance US12 36-3§7.2 a key that is no alias maps to itself" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-KEY2 = WS-KEY
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a duplicate alias in one resolution is flagged (the game throws), also when it is bound by two groups' direct bindings in the same resolution
     MOVE '[{"type": "minecraft:direct", "alias": "minecraft:a", "target": "minecraft:b"}, {"type": "minecraft:direct", "alias": "minecraft:a", "target": "minecraft:c"}]' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     MOVE 0 TO SD-AL-COUNT SD-AL-ECOUNT
     PERFORM READ-LIST
     CALL "JIG-ALIAS-BUILD" USING WS-ROW WS-SEED WS-PX WS-PY WS-PZ
     MOVE "acceptance US12 36-3§7.2 an alias bound twice in one resolution sets the duplicate flag and the second binding is not kept" TO TL-CASE
     MOVE 1011 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = JM-DUP * 1000 + JM-COUNT * 10 + 1
     IF JM-TARGET(1) NOT = "minecraft:b"
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   more than 32 pairs: the 33rd is refused through the same flag
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     STRING "[" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 33
         MOVE WS-I TO WS-ED
         IF WS-I > 1
             STRING ", " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
         STRING '{"type": "minecraft:direct", "alias": "minecraft:a' FUNCTION TRIM(WS-ED) '", "target": "minecraft:t"}' DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     STRING "]" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     COMPUTE WS-LEN = WS-PTR - 1
     MOVE 0 TO SD-AL-COUNT SD-AL-ECOUNT
     PERFORM READ-LIST
     CALL "JIG-ALIAS-BUILD" USING WS-ROW WS-SEED WS-PX WS-PY WS-PZ
     MOVE "acceptance US12 36-3§7.2 a 33rd pair does not fit the map of 32: flagged" TO TL-CASE
     MOVE 32001 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = JM-COUNT * 1000 + JM-DUP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   3.4: malformed bindings are refused when read
     MOVE '[{"type": "minecraft:foo", "alias": "minecraft:a", "target": "minecraft:b"}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a binding of an unknown type is refused" TO WS-CASE
     PERFORM READ-REFUSED
     MOVE '[{"alias": "minecraft:a", "target": "minecraft:b"}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a binding without a type is refused" TO WS-CASE
     PERFORM READ-REFUSED
     MOVE '[{"type": "minecraft:direct", "alias": "minecraft:a"}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a direct binding without a target is refused" TO WS-CASE
     PERFORM READ-REFUSED
     MOVE '[{"type": "minecraft:direct", "target": "minecraft:b"}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a direct binding without an alias is refused" TO WS-CASE
     PERFORM READ-REFUSED
     MOVE '[{"type": "minecraft:random", "targets": [{"data": "minecraft:b", "weight": 1}]}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a random binding without an alias is refused" TO WS-CASE
     PERFORM READ-REFUSED
     MOVE '[{"type": "minecraft:random", "alias": "minecraft:a", "targets": []}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a random binding with no targets is refused (the list is non-empty)" TO WS-CASE
     PERFORM READ-REFUSED
     MOVE '[{"type": "minecraft:random", "alias": "minecraft:a", "targets": [{"data": "minecraft:b", "weight": 0}]}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a random binding with a weight of 0 is refused" TO WS-CASE
     PERFORM READ-REFUSED
     MOVE '[{"type": "minecraft:random", "alias": "minecraft:a", "targets": [{"data": "minecraft:b"}]}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a random binding whose target has no weight is refused" TO WS-CASE
     PERFORM READ-REFUSED
     MOVE '[{"type": "minecraft:random_group", "groups": []}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a random_group with no groups is refused" TO WS-CASE
     PERFORM READ-REFUSED
     MOVE '[{"type": "minecraft:random_group", "groups": [{"data": [{"type": "minecraft:foo"}], "weight": 1}]}]' TO WS-TEXT
     MOVE "acceptance US12 36-3§3.4 a random_group whose nested binding is malformed is refused" TO WS-CASE
     PERFORM READ-REFUSED
*>   the tables: 96 binding nodes, 192 entries
     MOVE '[{"type": "minecraft:direct", "alias": "minecraft:a", "target": "minecraft:b"}, {"type": "minecraft:direct", "alias": "minecraft:c", "target": "minecraft:d"}]' TO WS-TEXT
     MOVE 95 TO SD-AL-COUNT
     MOVE 0 TO SD-AL-ECOUNT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     PERFORM READ-LIST
     MOVE "acceptance US12 36-3§3.4 two bindings that do not fit the 96 nodes left are refused" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '[{"type": "minecraft:random", "alias": "minecraft:a", "targets": [{"data": "minecraft:b", "weight": 1}, {"data": "minecraft:c", "weight": 1}]}]' TO WS-TEXT
     MOVE 0 TO SD-AL-COUNT
     MOVE 191 TO SD-AL-ECOUNT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     PERFORM READ-LIST
     MOVE "acceptance US12 36-3§3.4 two targets that do not fit the 192 entries are refused" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '[{"type": "minecraft:random_group", "groups": [{"data": [{"type": "minecraft:direct", "alias": "minecraft:a", "target": "minecraft:b"}, {"type": "minecraft:direct", "alias": "minecraft:c", "target": "minecraft:d"}], "weight": 1}]}]' TO WS-TEXT
     MOVE 94 TO SD-AL-COUNT
     MOVE 0 TO SD-AL-ECOUNT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     PERFORM READ-LIST
     MOVE "acceptance US12 36-3§3.4 a group of two bindings that do not fit the nodes left is refused" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM REAL-DATA
     STOP RUN.

*> READ-LIST: the array in WS-TEXT (length WS-LEN) as the pool_aliases member of an object, read into the bindings of row WS-ROW
 READ-LIST.
     MOVE SPACES TO WS-DOC-TEXT
     STRING '{"pool_aliases": ' WS-TEXT(1:WS-LEN) '}' DELIMITED BY SIZE INTO WS-DOC-TEXT
     COMPUTE WS-LEN = WS-LEN + 18
     CALL "JSON-PARSE" USING JSON-DOC WS-DOC-TEXT WS-LEN
     CALL "JIG-ALIAS-READ" USING JSON-DOC WS-ROW WS-OK
     .
*> READ-REFUSED: WS-TEXT read from empty tables is refused (case text WS-CASE)
 READ-REFUSED.
     MOVE 0 TO SD-AL-COUNT SD-AL-ECOUNT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     PERFORM READ-LIST
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
*> SHOW-MAP: the pairs of the map as alias=target; without the namespace minecraft:
 SHOW-MAP.
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JM-COUNT
         STRING FUNCTION TRIM(JM-ALIAS(WS-I)(11:70)) "=" FUNCTION TRIM(JM-TARGET(WS-I)(11:70)) ";" DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     END-PERFORM
     .
*> the trial chambers' own list from the data pack
 REAL-DATA.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-3§7 Pool aliases: no generated packs here, the trial chambers cases are skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         EXIT PARAGRAPH
     END-IF
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-DIR
     CALL "WORLDGEN-FREE"
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE 0 TO WS-TRIAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:trial_chambers"
             MOVE WS-I TO WS-TRIAL
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-3§7.4 trial chambers: three top-level bindings (a random_group and two random), and the structure is buildable (aliases and uniform height are read)" TO TL-CASE
     MOVE 1031 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SDT-JIG-OK(WS-TRIAL) * 1000 + SDT-JIG-AL-N(WS-TRIAL) * 10 + SDT-JIG-YKIND(WS-TRIAL)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
         MOVE TC-SEED(WS-K) TO WS-SEED
         MOVE TC-X(WS-K) TO WS-PX
         MOVE TC-Y(WS-K) TO WS-PY
         MOVE TC-Z(WS-K) TO WS-PZ
         CALL "JIG-ALIAS-BUILD" USING WS-TRIAL WS-SEED WS-PX WS-PY WS-PZ
         MOVE SPACES TO WS-OUT
         MOVE 1 TO WS-PTR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JM-COUNT
             STRING FUNCTION TRIM(JM-TARGET(WS-I)(34:47)) ";" DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         END-PERFORM
         MOVE WS-K TO WS-ED
         MOVE SPACES TO WS-CASE
         STRING "acceptance US12 36-3§7.4 trial chambers resolution " FUNCTION TRIM(WS-ED) ": the four targets (ranged, slow_ranged, melee, small_melee) equal the model's"
             DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE TC-EXP(WS-K) TO TL-EXPECTED
         MOVE WS-OUT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "N" TO TL-MODE
     END-PERFORM
     CALL "JIG-ALIAS-BUILD" USING WS-TRIAL WS-SEED WS-PX WS-PY WS-PZ
     MOVE "acceptance US12 36-3§7.4 each resolution makes four pairs: ranged, slow_ranged, melee, small_melee" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE JM-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "minecraft:trial_chambers/spawner/contents/ranged" TO TL-EXPECTED
     MOVE JM-ALIAS(1) TO TL-OBSERVED
     MOVE "acceptance US12 36-3§7.4 the first alias bound is the group's contents/ranged" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     .
 END PROGRAM TEST-STRUCT-36-3-7.
