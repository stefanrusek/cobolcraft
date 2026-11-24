*> Test of the thirteen processor lists of the bastion group (docs/protocol/37-nether-6-structures-spawns-hooks.md section 5.2, the exact rule order): on the generated vanilla data (CC_GENERATED_DIR, read only;
*> passes as skipped without it) each list loads as one rule processor whose rules, in order, are the doc's table: the input test (random_block_match with its block and probability, or always_true), the
*> position test (the axis_aligned_linear_pos of high_rampart with its four numbers), the location test always_true and the output block's default state; `empty` holds no processor. Section 5.1 (the draw index
*> of the start pool to the variant) is held by test_struct_36_8_13 (the start template of every start is the second draw nextInt(4) after the rotation).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-37-6-PROC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY STRUCTPROC.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-PKEY                PIC X(80).
 01 WS-PID                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-TEXT                PIC X(900).
 01 WS-PTR                 BINARY-LONG.
 01 WS-P                   PIC 9.9999.
 01 WS-P2                  PIC 9.9999.
 01 WS-N1                  PIC 999.
 01 WS-N2                  PIC 999.
 01 WS-AX                  PIC 9.
 01 WS-NAME                PIC X(48).
 01 WS-NAME2               PIC X(48).
 01 WS-F                   FLOAT-LONG.
 01 WS-LISTS.
    05 FILLER PIC X(40) VALUE "bastion_generic_degradation".
    05 FILLER PIC X(900) VALUE "rbm:polished_blackstone_bricks:0.3000>cracked_polished_blackstone_bricks;rbm:blackstone:0.0001>air;rbm:gold_block:0.3000>cracked_polished_blackstone_bricks;rbm:gilded_blackstone:0.5000>blackstone;rbm:blackstone:0.0100>gilded_blackstone;".
    05 FILLER PIC X(40) VALUE "housing".
    05 FILLER PIC X(900) VALUE "rbm:polished_blackstone_bricks:0.3000>cracked_polished_blackstone_bricks;rbm:blackstone:0.0001>air;rbm:gilded_blackstone:0.5000>blackstone;rbm:blackstone:0.0100>gilded_blackstone;".
    05 FILLER PIC X(40) VALUE "stable_degradation".
    05 FILLER PIC X(900) VALUE "rbm:polished_blackstone_bricks:0.1000>cracked_polished_blackstone_bricks;rbm:blackstone:0.0001>air;rbm:gilded_blackstone:0.5000>blackstone;rbm:blackstone:0.0100>gilded_blackstone;".
    05 FILLER PIC X(40) VALUE "side_wall_degradation".
    05 FILLER PIC X(900) VALUE "rbm:chiseled_polished_blackstone:0.5000>air;rbm:gold_block:0.1000>cracked_polished_blackstone_bricks;rbm:gilded_blackstone:0.5000>blackstone;rbm:blackstone:0.0100>gilded_blackstone;".
    05 FILLER PIC X(40) VALUE "treasure_rooms".
    05 FILLER PIC X(900) VALUE "rbm:polished_blackstone_bricks:0.3500>cracked_polished_blackstone_bricks;rbm:chiseled_polished_blackstone:0.1000>cracked_polished_blackstone_bricks;rbm:gilded_blackstone:0.5000>blackstone;rbm:blackstone:0.0100>gilded_blackstone;".
    05 FILLER PIC X(40) VALUE "high_wall".
    05 FILLER PIC X(900) VALUE "rbm:polished_blackstone_bricks:0.0100>air;rbm:polished_blackstone_bricks:0.5000>cracked_polished_blackstone_bricks;rbm:polished_blackstone_bricks:0.3000>blackstone;rbm:gilded_blackstone:0.5000>blackstone;".
    05 FILLER PIC X(40) VALUE "roof".
    05 FILLER PIC X(900) VALUE "rbm:polished_blackstone_bricks:0.3000>cracked_polished_blackstone_bricks;rbm:polished_blackstone_bricks:0.1500>air;rbm:polished_blackstone_bricks:0.3000>blackstone;".
    05 FILLER PIC X(40) VALUE "bottom_rampart".
    05 FILLER PIC X(900) VALUE "rbm:magma_block:0.7500>cracked_polished_blackstone_bricks;rbm:cracked_polished_blackstone_bricks:0.1500>polished_blackstone_bricks;rbm:gilded_blackstone:0.5000>blackstone;rbm:blackstone:0.0100>gilded_blackstone;".
    05 FILLER PIC X(40) VALUE "high_rampart".
    05 FILLER PIC X(900) VALUE "rbm:gold_block:0.3000>cracked_polished_blackstone_bricks;always+pos:1:0.0000:0.0500:000:100>air;rbm:gilded_blackstone:0.5000>blackstone;".
    05 FILLER PIC X(40) VALUE "rampart_degradation".
    05 FILLER PIC X(900) VALUE "rbm:polished_blackstone_bricks:0.4000>cracked_polished_blackstone_bricks;rbm:blackstone:0.0100>cracked_polished_blackstone_bricks;rbm:polished_blackstone_bricks:0.0001>air;rbm:blackstone:0.0001>air;rbm:gold_block:0.3000>cracked_polished_blackstone_bricks;rbm:gilded_blackstone:0.5000>blackstone;rbm:blackstone:0.0100>gilded_blackstone;".
    05 FILLER PIC X(40) VALUE "bridge".
    05 FILLER PIC X(900) VALUE "rbm:polished_blackstone_bricks:0.3000>cracked_polished_blackstone_bricks;rbm:blackstone:0.0001>air;".
    05 FILLER PIC X(40) VALUE "entrance_replacement".
    05 FILLER PIC X(900) VALUE "rbm:chiseled_polished_blackstone:0.5000>air;rbm:gold_block:0.6000>cracked_polished_blackstone_bricks;rbm:gilded_blackstone:0.5000>blackstone;rbm:blackstone:0.0100>gilded_blackstone;".
    05 FILLER PIC X(40) VALUE "empty".
    05 FILLER PIC X(900) VALUE "no processor".
 01 WS-LIST-TAB REDEFINES WS-LISTS.
    05 WS-L OCCURS 13 TIMES.
       10 WS-L-NAME        PIC X(40).
       10 WS-L-RULES       PIC X(900).
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
         MOVE "37-6 5.2 processor lists: no generated packs here, skipped" TO TL-CASE
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         MOVE SPACES TO WS-PKEY
         STRING "minecraft:" FUNCTION TRIM(WS-L-NAME(WS-I)) DELIMITED BY SIZE INTO WS-PKEY
         CALL "STRUCT-PROC-LOAD" USING WS-PKEY WS-PID
         MOVE SPACES TO WS-TEXT
         MOVE 1 TO WS-PTR
         IF WS-PID < 1
             STRING "not loaded" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         ELSE
             PERFORM RENDER-LIST
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "37-6 5.2 the processor list " FUNCTION TRIM(WS-L-NAME(WS-I)) " holds the doc's rules in the doc's order" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-TEXT TO TL-OBSERVED
         MOVE WS-L-RULES(WS-I) TO TL-EXPECTED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

*> RENDER-LIST: WS-TEXT = the rules of the list WS-PID: "rbm:<block>:<p>><output block>;" (a "!" after the output when it is not the block's default state), "always+pos:<axis>:<min chance>:<max chance>:<min dist>:<max dist>>"
*> for an always_true input with a position test, "?" for anything else; a list that is not one rule processor reads "no processor" when it is empty, else "other"
 RENDER-LIST.
     IF SPL-N(WS-PID) = 0
         STRING "no processor" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         EXIT PARAGRAPH
     END-IF
     IF SPL-N(WS-PID) NOT = 1 OR SPP-TYPE(SPL-FIRST(WS-PID)) NOT = 1
         STRING "other" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         EXIT PARAGRAPH
     END-IF
     MOVE SPP-A(SPL-FIRST(WS-PID)) TO WS-ROW
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R >= SPP-N(SPL-FIRST(WS-PID))
         COMPUTE WS-T = WS-ROW + WS-R
         PERFORM RENDER-RULE
     END-PERFORM
     .
 RENDER-RULE.
     MOVE SPR-IN(WS-T) TO WS-B
     IF SPT-TYPE(WS-B) = 5
         MOVE CB-KEY(SPT-A(WS-B))(1:48) TO WS-NAME
         PERFORM STRIP-NAME
         MOVE SPT-F(WS-B) TO WS-F
         COMPUTE WS-P ROUNDED = WS-F
         STRING "rbm:" FUNCTION TRIM(WS-NAME) ":" WS-P ">" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     ELSE
         IF SPT-TYPE(WS-B) = 1 AND SPR-POS(WS-T) > 0
             MOVE SPR-POS(WS-T) TO WS-B
             IF SPT-TYPE(WS-B) = 23
                 MOVE SPT-F(WS-B) TO WS-F
                 COMPUTE WS-P ROUNDED = WS-F
                 MOVE SPT-F2(WS-B) TO WS-F
                 COMPUTE WS-P2 ROUNDED = WS-F
                 MOVE SPT-B(WS-B) TO WS-N1
                 MOVE SPT-C(WS-B) TO WS-N2
                 MOVE SPT-D(WS-B) TO WS-AX
                 STRING "always+pos:" WS-AX ":" WS-P ":" WS-P2 ":" WS-N1 ":" WS-N2 ">" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             ELSE
                 STRING "?>" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-IF
         ELSE
             STRING "?>" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-IF
*>   the location test is always true (0 or the always_true type)
     IF SPR-LOC(WS-T) > 0
         IF SPT-TYPE(SPR-LOC(WS-T)) NOT = 1
             STRING "loc?" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-IF
     COMPUTE WS-B = CB-S-BLOCK(SPR-STATE(WS-T) + 1) + 1
     MOVE CB-KEY(WS-B)(1:48) TO WS-NAME
     PERFORM STRIP-NAME
     STRING FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     IF SPR-STATE(WS-T) NOT = CB-DEFAULT-STATE(WS-B)
         STRING "!" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-IF
     STRING ";" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     .
 STRIP-NAME.
     IF WS-NAME(1:10) = "minecraft:"
         MOVE WS-NAME(11:38) TO WS-NAME2
         MOVE WS-NAME2 TO WS-NAME
     END-IF
     .
 END PROGRAM TEST-STRUCT-37-6-PROC.

 COPY NOSPAWN.
 COPY CORETEST.
