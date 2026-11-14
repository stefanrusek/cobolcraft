*> Test of content/src/blocks.cob (T0190; content-api section 2; 24 part 1 section 3 and its worked examples
*> 1 to 4): CONTENT-BLOCK-BY-KEY USING key (PIC X(112)), block id out, row out (CT-BLOCK-ROW), status;
*> CONTENT-BLOCK-OF-STATE USING state id, block id out, state index out, row out, status;
*> CONTENT-STATE-PROPS USING state id, CT-PROPS (CTPROPS.cpy) out, status; CONTENT-STATE-DEFAULT USING block id,
*> default state id out, status. State rows are never stored: the state id rule gives the block, the index
*> and the property values. An unknown key or id gives CT-NOT-FOUND and row 0 (air). The standard set is
*> opened by setting CT-SET directly (CONTENT-OPEN is tested by acc_f2us2_content_open).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONTENT-BLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTPROPS.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 WS-R-ID             PIC X(4).
    05 WS-R-KEY            PIC X(35).
    05 WS-R-CLASS          PIC X(32).
    05 WS-R-PROPS          PIC X(288).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 WS-R-DEFAULT        PIC X(5).
    05 WS-R-REST           PIC X(446).
 01 WS-TEXT                PIC X(200).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
*>   No set open: the defined outcome CT-NOT-OPEN for every lookup.
     MOVE 0 TO CT-OPEN
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "blocks: no set open, by key" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 1 TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-ROW WS-STATUS
     MOVE "blocks: no set open, of state" TO TL-CASE
     PERFORM ASSERT-STATUS
     CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
     MOVE "blocks: no set open, props" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 1 TO WS-ID
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "blocks: no set open, default" TO TL-CASE
     PERFORM ASSERT-STATUS

     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE

*>   By key.
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "blocks: stone by key is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "blocks: stone is block 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "blocks: stone row key" TO TL-CASE
     MOVE "stone" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:oak_log" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "blocks: oak_log with its namespace is block 51" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "blocks: oak_log first state 139" TO TL-CASE
     MOVE "139" TO TL-EXPECTED
     MOVE WS-R-FIRST TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "blocks: oak_log has 3 states" TO TL-CASE
     MOVE "3" TO TL-EXPECTED
     MOVE WS-R-COUNT TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "blocks: oak_log default state 140" TO TL-CASE
     MOVE "140" TO TL-EXPECTED
     MOVE WS-R-DEFAULT TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "blocks: oak_log property list" TO TL-CASE
     MOVE "axis[x/y/z]" TO TL-EXPECTED
     MOVE WS-R-PROPS TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "bedrock" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "blocks: bedrock is block 36" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Unknown keys: not found, row 0 (air), id 0; a cobolcraft key is not in the standard set (WT-25).
     MOVE "no_such_block" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "blocks: unknown key is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "blocks: unknown key gives id 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "blocks: unknown key gives row 0 (air)" TO TL-CASE
     MOVE "air" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "blocks: a cobolcraft key is not in the standard set" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "blocks: a blank key is not found" TO TL-CASE
     PERFORM ASSERT-STATUS

*>   Of state: worked examples 1 to 4 of 24 part 1 section 16.
     MOVE 139 TO WS-STATE
     MOVE "blocks: state 139 is oak_log axis=x" TO TL-CASE
     PERFORM OF-STATE
     MOVE 51 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "blocks: state 139 index 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 141 TO WS-STATE
     MOVE "blocks: state 141 is oak_log axis=z, index 2" TO TL-CASE
     PERFORM OF-STATE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 142 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 142 belongs to the block after oak_log" TO TL-CASE
     MOVE 52 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 267 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 267 is oak_leaves, index 0" TO TL-CASE
     MOVE "oak_leaves" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 294 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 294 is oak_leaves, index 27" TO TL-CASE
     MOVE 27 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 295 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 295 starts spruce_leaves" TO TL-CASE
     MOVE "spruce_leaves" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 46 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 46 is mangrove_propagule" TO TL-CASE
     MOVE "mangrove_propagule" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 85 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 85 is the last of mangrove_propagule, index 39" TO TL-CASE
     MOVE 39 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 86 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 86 starts poplar_sapling" TO TL-CASE
     MOVE "poplar_sapling" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 89 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 89 is water" TO TL-CASE
     MOVE "water" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 104 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 104 is water level 15, index 15" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 105 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 105 is lava" TO TL-CASE
     MOVE "lava" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 121 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 121 is sand" TO TL-CASE
     MOVE "sand" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 0 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: state 0 is air" TO TL-CASE
     MOVE "air" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "blocks: state 0 is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE -1 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: a negative state is not found, row 0" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "air" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     MOVE "blocks: a negative state gives row 0 (air)" TO TL-CASE
     PERFORM ASSERT-TEXT
     MOVE 99999999 TO WS-STATE
     PERFORM OF-STATE
     MOVE "blocks: a state past the last is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   Property values by the state id rule.
     MOVE 139 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: props of state 139" TO TL-CASE
     MOVE "axis=x" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 140 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: props of state 140" TO TL-CASE
     MOVE "axis=y" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 267 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: props of state 267 (oak_leaves, example 2)" TO TL-CASE
     MOVE "distance=1,persistent=true,waterlogged=true" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 294 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: props of the default state 294" TO TL-CASE
     MOVE "distance=7,persistent=false,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 51 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: props of the propagule default (example 3)" TO TL-CASE
     MOVE "age=0,hanging=false,stage=0,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 104 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: props of water level 15" TO TL-CASE
     MOVE "level=15" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 1 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: stone has no properties" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "blocks: stone props status ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 9 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: props of grass_block state 9 (snowy=false)" TO TL-CASE
     MOVE "snowy=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 5463 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: oak_stairs first state lists its four properties" TO TL-CASE
     MOVE "facing=north,half=top,shape=straight,waterlogged=true" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "blocks: oak_stairs props status ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
*>   24 part 2 worked example 4: facing east (3), half top (0), shape outer_left (3), waterlogged true (0) is
*>   index 3 * 20 + 0 * 10 + 3 * 2 + 0 = 66.
     MOVE 5529 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: oak_stairs state 66 (example 4)" TO TL-CASE
     MOVE "facing=east,half=top,shape=outer_left,waterlogged=true" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 12963 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: anvil state 1 is facing south (values from the family rule)" TO TL-CASE
     MOVE "facing=south" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "blocks: anvil props status ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 11214 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: redstone_lamp state 11214 is lit=false" TO TL-CASE
     MOVE "lit=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "note_block" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     PERFORM DEFAULT-OF
     MOVE "blocks: note_block default is its second state (24 part 2 section 4: index 1)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION NUMVAL(WS-R-FIRST) + 1
     PERFORM ASSERT-STATE-ID
     MOVE "blocks: note_block default status ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
*>   The note block lists its 27 instruments, 25 notes and powered (24 part 2 section 4): state 0 is
*>   instrument harp, note 0, powered true; the last state of the first instrument is note 24, powered false.
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-R-FIRST)
     PERFORM PROPS-OF
     MOVE "blocks: note_block first state lists its properties" TO TL-CASE
     MOVE "instrument=harp,note=0,powered=true" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-R-FIRST) + 1349
     PERFORM PROPS-OF
     MOVE "blocks: note_block last state is the last instrument (custom_head)" TO TL-CASE
     MOVE "instrument=custom_head,note=24,powered=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "chiseled_bookshelf" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     PERFORM DEFAULT-OF
     MOVE "blocks: chiseled_bookshelf default is first state + 63" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION NUMVAL(WS-R-FIRST) + 63
     PERFORM ASSERT-STATE-ID
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-R-FIRST) + 63
     PERFORM PROPS-OF
     MOVE "blocks: chiseled_bookshelf default state lists seven properties" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "facing=north,slot_0_occupied=false,slot_1_occupied=false,slot_2_occupied=false,"
         "slot_3_occupied=false,slot_4_occupied=false,slot_5_occupied=false" DELIMITED BY SIZE
         INTO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE -5 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "blocks: props of an unknown state" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "blocks: unknown state props count 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CTP-COUNT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Default states.
     MOVE 51 TO WS-ID
     PERFORM DEFAULT-OF
     MOVE "blocks: default state of oak_log is 140" TO TL-CASE
     MOVE 140 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE-ID
     MOVE 94 TO WS-ID
     PERFORM DEFAULT-OF
     MOVE "blocks: default state of oak_leaves is 294" TO TL-CASE
     MOVE 294 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE-ID
     MOVE 34 TO WS-ID
     PERFORM DEFAULT-OF
     MOVE "blocks: default state of mangrove_propagule is 51" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE-ID
     MOVE 1 TO WS-ID
     PERFORM DEFAULT-OF
     MOVE "blocks: default state of stone is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE-ID
     MOVE 110 TO WS-ID
     PERFORM DEFAULT-OF
     MOVE "blocks: glass has one state: the default is the first (661)" TO TL-CASE
     MOVE 661 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE-ID
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE "blocks: glass default status ok" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 445 TO WS-ID
     PERFORM DEFAULT-OF
     MOVE "blocks: redstone_lamp default is lit=false, the second state (11214)" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 11214 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE-ID
     MOVE "oak_stairs" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     PERFORM DEFAULT-OF
     MOVE "blocks: oak_stairs default is first state + 11 (5474)" TO TL-CASE
     MOVE 5474 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE-ID
     MOVE "oak_door" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     PERFORM DEFAULT-OF
     MOVE "blocks: oak_door default is first state + 11 (7254)" TO TL-CASE
     MOVE 7254 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE-ID
     MOVE "redstone_torch" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     PERFORM DEFAULT-OF
     MOVE "blocks: redstone_torch is lit by default: its first state" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION NUMVAL(WS-R-FIRST)
     PERFORM ASSERT-STATE-ID
     MOVE 99999 TO WS-ID
     PERFORM DEFAULT-OF
     MOVE "blocks: default of an unknown block" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE -1 TO WS-ID
     PERFORM DEFAULT-OF
     MOVE "blocks: default of a negative block id" TO TL-CASE
     PERFORM ASSERT-STATUS
     STOP RUN.

 OF-STATE.
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-ROW WS-STATUS.

 PROPS-OF.
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
     MOVE WS-TEXT TO TL-OBSERVED.

 DEFAULT-OF.
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS.

 ASSERT-STATE-ID.
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
