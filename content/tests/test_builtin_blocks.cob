*> Test of the built-in block layer (T0202; docs/design/standin-content.md section 1.1 and 1.2, cobolcraft-standard-core.md
*> section 5.1): the cobolcraft set answers the same block lookups as the standard one, with the twelve blocks
*> and the eighteen states (state ids 0 to 17) of the stand-in. Rows carry the columns of the core table.
*> The set is made by setting CT-SET (CONTENT-OPEN has its own acceptance test).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUILTIN-BLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTPROPS.
 01 WS-KEY                 PIC X(64).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 WS-R-ID             PIC X(4).
    05 WS-R-KEY            PIC X(35).
    05 WS-R-CLASS          PIC X(32).
    05 WS-R-PROPS          PIC X(288).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 WS-R-DEFAULT        PIC X(5).
    05 WS-R-HARDNESS       PIC X(21).
    05 WS-R-BLAST          PIC X(9).
    05 WS-R-TOOL           PIC X(3).
    05 WS-R-LIGHT          PIC X(41).
    05 WS-R-MAP            PIC X(50).
    05 WS-R-SOUND          PIC X(150).
    05 WS-R-PUSH           PIC X(10).
    05 WS-R-INSTRUMENT     PIC X(15).
    05 WS-R-FLAGS          PIC X(147).
 01 WS-TAG-REGISTRY        PIC X(48).
 01 WS-TAG                 PIC X(64).
 01 WS-RESULT              BINARY-LONG.
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 16 TIMES.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NUM                 PIC 99.
 01 WS-KEYS.
    05 FILLER PIC X(24) VALUE "cobolcraft:void".
    05 FILLER PIC X(24) VALUE "cobolcraft:baseplate".
    05 FILLER PIC X(24) VALUE "cobolcraft:greystone".
    05 FILLER PIC X(24) VALUE "cobolcraft:loam".
    05 FILLER PIC X(24) VALUE "cobolcraft:turf".
    05 FILLER PIC X(24) VALUE "cobolcraft:grit".
    05 FILLER PIC X(24) VALUE "cobolcraft:cardstack".
    05 FILLER PIC X(24) VALUE "cobolcraft:lucite".
    05 FILLER PIC X(24) VALUE "cobolcraft:glowtube".
    05 FILLER PIC X(24) VALUE "cobolcraft:ledger_tile".
    05 FILLER PIC X(24) VALUE "cobolcraft:goto_pad".
    05 FILLER PIC X(24) VALUE "cobolcraft:slag".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY-OF           PIC X(24) OCCURS 12 TIMES.
*> The block of each state 0 to 17 (standin 1.2).
 01 WS-STATE-BLOCKS.
    05 FILLER PIC X(36) VALUE "000102030405060606060606070808091011".
 01 WS-STATE-BLOCK-TABLE REDEFINES WS-STATE-BLOCKS.
    05 WS-STATE-BLOCK      PIC 99 OCCURS 18 TIMES.
*> Hand-written copy of standin 1.2, the properties of states 6 to 14.
 01 WS-EXPECT-PROPS.
    05 FILLER PIC X(40) VALUE "axis=x,punched=true".
    05 FILLER PIC X(40) VALUE "axis=x,punched=false".
    05 FILLER PIC X(40) VALUE "axis=y,punched=true".
    05 FILLER PIC X(40) VALUE "axis=y,punched=false".
    05 FILLER PIC X(40) VALUE "axis=z,punched=true".
    05 FILLER PIC X(40) VALUE "axis=z,punched=false".
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(40) VALUE "lit=true".
    05 FILLER PIC X(40) VALUE "lit=false".
 01 WS-EXPECT-TABLE REDEFINES WS-EXPECT-PROPS.
    05 WS-EXPECT           PIC X(40) OCCURS 9 TIMES.
 PROCEDURE DIVISION.
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE

*>   Each of the twelve keys is block N, row N.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE SPACES TO WS-KEY
         MOVE WS-KEY-OF(WS-I) TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
         COMPUTE WS-NUM = WS-I - 1
         MOVE SPACES TO TL-CASE
         STRING "builtin blocks: " FUNCTION TRIM(WS-KEY-OF(WS-I)) " is found with id " WS-NUM DELIMITED BY SIZE
             INTO TL-CASE
         MOVE "N" TO TL-MODE
         COMPUTE TL-EXPECTED-N = WS-I - 1
         MOVE WS-ID TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "builtin blocks: the found status is ok" TO TL-CASE
         MOVE CT-OK TO TL-EXPECTED-N
         MOVE WS-STATUS TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   The rows of the core table (5.1): columns and numbers.
     MOVE "cobolcraft:baseplate" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "T" TO TL-MODE
     MOVE "builtin blocks: baseplate is unbreakable (hardness -1.0)" TO TL-CASE
     MOVE "-1.0" TO TL-EXPECTED
     MOVE WS-R-HARDNESS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin blocks: baseplate blast resistance" TO TL-CASE
     MOVE "3600000.0" TO TL-EXPECTED
     MOVE WS-R-BLAST TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin blocks: baseplate flags" TO TL-CASE
     MOVE "noLootTable validSpawn:never" TO TL-EXPECTED
     MOVE WS-R-FLAGS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobolcraft:goto_pad" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "builtin blocks: goto_pad emits light 6" TO TL-CASE
     MOVE "6" TO TL-EXPECTED
     MOVE WS-R-LIGHT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin blocks: goto_pad hardness 1.3" TO TL-CASE
     MOVE "1.3" TO TL-EXPECTED
     MOVE WS-R-HARDNESS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobolcraft:glowtube" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "builtin blocks: glowtube light follows lit" TO TL-CASE
     MOVE "15 if lit, else 0" TO TL-EXPECTED
     MOVE WS-R-LIGHT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin blocks: glowtube property list" TO TL-CASE
     MOVE "lit[true/false]" TO TL-EXPECTED
     MOVE WS-R-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobolcraft:lucite" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "builtin blocks: lucite class" TO TL-CASE
     MOVE "TransparentBlock" TO TL-EXPECTED
     MOVE WS-R-CLASS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin blocks: lucite flags" TO TL-CASE
     MOVE "noOcclusion validSpawn:never suffocating:never redstoneConductor:never" TO TL-EXPECTED
     MOVE WS-R-FLAGS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobolcraft:void" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "builtin blocks: void has no property list" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-R-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin blocks: void flags" TO TL-CASE
     MOVE "replaceable noCollision noLootTable air" TO TL-EXPECTED
     MOVE WS-R-FLAGS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The sets share no rows (WT-25): a standard key is unknown here, and the unknown outcome is row 0.
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "builtin blocks: stone is not in the cobolcraft set" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin blocks: unknown key gives row 0 (cobolcraft:void)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "cobolcraft:void" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "builtin blocks: minecraft:stone is not in the cobolcraft set" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   States 0 to 17 and the first state past the set.
     PERFORM VARYING WS-STATE FROM 0 BY 1 UNTIL WS-STATE > 17
         CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-ROW WS-STATUS
         MOVE WS-STATE TO WS-NUM
         MOVE SPACES TO TL-CASE
         STRING "builtin blocks: state " WS-NUM " belongs to the block of standin 1.2" DELIMITED BY SIZE
             INTO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-STATE-BLOCK(WS-STATE + 1) TO TL-EXPECTED-N
         MOVE WS-ID TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 8 TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-ROW WS-STATUS
     MOVE "builtin blocks: state 8 is cardstack index 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-ROW WS-STATUS
     MOVE "builtin blocks: state 18 is not found (the bench is a later phase)" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Property values of states 6 to 14, and the empty list of the one-state blocks.
     PERFORM VARYING WS-STATE FROM 6 BY 1 UNTIL WS-STATE > 14
         CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
         MOVE SPACES TO WS-TEXT
         MOVE 1 TO WS-POS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CTP-COUNT
             IF WS-I > 1
                 MOVE "," TO WS-TEXT(WS-POS:1)
                 ADD 1 TO WS-POS
             END-IF
             STRING FUNCTION TRIM(CTP-NAME(WS-I)) "=" FUNCTION TRIM(CTP-VALUE(WS-I)) DELIMITED BY SIZE
                 INTO WS-TEXT WITH POINTER WS-POS
         END-PERFORM
         MOVE WS-STATE TO WS-NUM
         MOVE SPACES TO TL-CASE
         STRING "builtin blocks: properties of state " WS-NUM DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-EXPECT(WS-STATE - 5) TO TL-EXPECTED
         MOVE WS-TEXT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   Default states: cardstack 9 and glowtube 13 are not the first states; the others are their own.
     MOVE 6 TO WS-ID
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "builtin blocks: default state of cardstack is 9" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-ID
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "builtin blocks: default state of glowtube is 13" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-ID
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "builtin blocks: default state of slag is 17" TO TL-CASE
     MOVE 17 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-ID
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "builtin blocks: block 12 is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ID
     CALL "BLOCK-ROW-AT" USING WS-ID WS-ROW WS-STATUS WS-COUNT
     MOVE "builtin blocks: the layer has 12 rows" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-ID
     CALL "BLOCK-ROW-AT" USING WS-ID WS-ROW WS-STATUS WS-COUNT
     MOVE "builtin blocks: row -1 is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The built-in block tags (core 4.1, 4.4): the members are block ids, not state ids.
     CALL "BUILTIN-BLOCK-TAGS"
     MOVE "block" TO WS-TAG-REGISTRY
     MOVE "minecraft:mineable/pickaxe" TO WS-TAG
     MOVE 16 TO WS-CAPACITY
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-CAPACITY WS-STATUS
     MOVE "builtin blocks: mineable/pickaxe members 2, 6, 9, 11 (core 4.4)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-OBSERVED-N = WS-MEMBER(1) * 1000000000 + WS-MEMBER(2) * 1000000 + WS-MEMBER(3) * 1000
         + WS-MEMBER(4)
     MOVE 2006009011 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin blocks: mineable/pickaxe has 4 members" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:mineable/shovel" TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-CAPACITY WS-STATUS
     MOVE "builtin blocks: mineable/shovel members 3, 4, 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-MEMBER(1) * 1000000 + WS-MEMBER(2) * 1000 + WS-MEMBER(3)
     MOVE 3004005 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:replaceable" TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-CAPACITY WS-STATUS
     MOVE "builtin blocks: replaceable holds only void (0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT * 100 + WS-MEMBER(1)
     MOVE 100 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:air" TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-CAPACITY WS-STATUS
     MOVE "builtin blocks: air holds only void (0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT * 100 + WS-MEMBER(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:causes_suffocation" TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-CAPACITY WS-STATUS
     MOVE "builtin blocks: causes_suffocation holds blocks 1 to 11" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT * 100 + WS-MEMBER(1) + WS-MEMBER(11) * 10
     MOVE 1211 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:blocks_motion_in_heightmap_no_leaves" TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-CAPACITY WS-STATUS
     MOVE "builtin blocks: the last blocks_motion tag holds blocks 1 to 11" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT * 100 + WS-MEMBER(1) + WS-MEMBER(11) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STATE
     MOVE "minecraft:mineable/pickaxe" TO WS-TAG
     MOVE 9 TO WS-STATE
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-STATE WS-RESULT
     MOVE "builtin blocks: ledger_tile (9) is in mineable/pickaxe" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-STATE
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-STATE WS-RESULT
     MOVE "builtin blocks: lucite (7) is in no mineable tag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TAGS-FREE"
     STOP RUN.
