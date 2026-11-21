*> Test of the item data loot functions that the core can evaluate from closed forms (26 section 7.3, set_ominous_bottle_amplifier and copy_state), run
*> through LOOT-MODIFIER from the named item modifiers of core/tests/fixtures/loot. set_ominous_bottle_amplifier sets the component 65 (a VarInt)
*> to clamp(amplifier, 0, 4). copy_state needs the context's block state: it sets the component 78 (block_state: a map of UTF-8 strings, VarInt
*> count then key and value pairs, 25-3 section 5.2) with the listed properties the state has, the listed order, after the entries the stack has
*> (a property already in the map is replaced). The component is shown as hex ("-" when the stack has none). Expected hex is built by
*> scratchpad/loot2/gen_fndata.py (an independent Python encoder of the wire forms), not by the COBOL code. Scenarios: 0 empty context;
*> 1 killed by a player; 2 block cardstack axis=y, punched=true. A case with existing 1 starts with the block_state {level: 15}, existing 2 with {axis: x, level: 15}.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-FUNCTIONS-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CSTACK.
 COPY LOOTCTX.
 01 WS-CASES.
    05 FILLER PIC X(100) VALUE "m_ominous|0|0|03|-".
    05 FILLER PIC X(100) VALUE "m_ominous_hi|0|0|04|-".
    05 FILLER PIC X(100) VALUE "m_ominous_lo|0|0|00|-".
    05 FILLER PIC X(100) VALUE "m_ominous_cond|0|0|-|-".
    05 FILLER PIC X(100) VALUE "m_ominous_cond|1|0|02|-".
    05 FILLER PIC X(100) VALUE "m_copy_state_axis|2|0|-|0104617869730179".
    05 FILLER PIC X(100) VALUE "m_copy_state_axis|0|0|-|-".
    05 FILLER PIC X(100) VALUE "m_copy_state_two|2|0|-|02046178697301790770756e636865640474727565".
    05 FILLER PIC X(100) VALUE "m_copy_state_unknown|2|0|-|00".
    05 FILLER PIC X(100) VALUE "m_copy_state_axis|2|1|-|02056c6576656c02313504617869730179".
    05 FILLER PIC X(100) VALUE "m_copy_state_axis|0|1|-|01056c6576656c023135".
    05 FILLER PIC X(100) VALUE "m_copy_state_axis|2|2|-|02056c6576656c02313504617869730179".
    05 FILLER PIC X(100) VALUE "m_copy_state_two|2|2|-|03056c6576656c023135046178697301790770756e636865640474727565".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE             PIC X(100) OCCURS 13 TIMES.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-SCENARIO            PIC X(4).
 01 WS-EXISTING            PIC X(4).
 01 WS-HEX65               PIC X(60).
 01 WS-HEX78               PIC X(60).
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FOUND2              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HEXDIGITS           PIC X(16) VALUE "0123456789abcdef".
 01 WS-OUT                 PIC X(130).
 01 WS-POS                 BINARY-LONG.
 01 WS-OBSERVED65          PIC X(60).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "test loot function data the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         MOVE SPACES TO WS-NAME WS-SCENARIO WS-EXISTING WS-HEX65 WS-HEX78
         UNSTRING WS-CASE(WS-I) DELIMITED BY "|" INTO WS-NAME WS-SCENARIO WS-EXISTING WS-HEX65 WS-HEX78
         INITIALIZE LOOT-CONTEXT
         IF FUNCTION NUMVAL(WS-SCENARIO) = 1
             MOVE 1 TO LC-KILLER
         END-IF
         IF FUNCTION NUMVAL(WS-SCENARIO) = 2
             MOVE "cobolcraft:cardstack" TO WS-KEY
             MOVE "axis=y,punched=true" TO WS-PAIRS
             CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
             MOVE 1 TO LC-STATE-SET
             MOVE WS-STATE TO LC-STATE
         END-IF
         MOVE 0 TO WS-HANDLE
         MOVE 1 TO WS-COUNT
         IF FUNCTION NUMVAL(WS-EXISTING) = 1
             MOVE 78 TO WS-TYPE
             MOVE SPACES TO WS-VALUE
             MOVE FUNCTION CHAR(2) TO WS-VALUE(1:1)
             MOVE FUNCTION CHAR(6) TO WS-VALUE(2:1)
             MOVE "level" TO WS-VALUE(3:5)
             MOVE FUNCTION CHAR(3) TO WS-VALUE(8:1)
             MOVE "15" TO WS-VALUE(9:2)
             MOVE 10 TO WS-LENGTH
             CALL "SP-SET-COMPONENT" USING WS-HANDLE WS-TYPE WS-VALUE WS-LENGTH
         END-IF
         IF FUNCTION NUMVAL(WS-EXISTING) = 2
             MOVE 78 TO WS-TYPE
             MOVE SPACES TO WS-VALUE
             MOVE FUNCTION CHAR(3) TO WS-VALUE(1:1)
             MOVE FUNCTION CHAR(5) TO WS-VALUE(2:1)
             MOVE "axis" TO WS-VALUE(3:4)
             MOVE FUNCTION CHAR(2) TO WS-VALUE(7:1)
             MOVE "x" TO WS-VALUE(8:1)
             MOVE FUNCTION CHAR(6) TO WS-VALUE(9:1)
             MOVE "level" TO WS-VALUE(10:5)
             MOVE FUNCTION CHAR(3) TO WS-VALUE(15:1)
             MOVE "15" TO WS-VALUE(16:2)
             MOVE 17 TO WS-LENGTH
             CALL "SP-SET-COMPONENT" USING WS-HANDLE WS-TYPE WS-VALUE WS-LENGTH
         END-IF
         MOVE SPACES TO WS-KEY
         STRING "test:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
         CALL "LOOT-MODIFIER" USING WS-KEY LOOT-CONTEXT WS-ITEM WS-COUNT WS-HANDLE WS-FOUND
         MOVE 65 TO WS-TYPE
         PERFORM SHOW-COMPONENT
         MOVE WS-OUT TO WS-OBSERVED65
         MOVE 78 TO WS-TYPE
         PERFORM SHOW-COMPONENT
         MOVE SPACES TO TL-OBSERVED TL-EXPECTED TL-CASE
         STRING FUNCTION TRIM(WS-OBSERVED65) "|" FUNCTION TRIM(WS-OUT) DELIMITED BY SIZE INTO TL-OBSERVED
         STRING FUNCTION TRIM(WS-HEX65) "|" FUNCTION TRIM(WS-HEX78) DELIMITED BY SIZE INTO TL-EXPECTED
         STRING "test loot function data " FUNCTION TRIM(WS-NAME) " scenario " FUNCTION TRIM(WS-SCENARIO) " existing "
             FUNCTION TRIM(WS-EXISTING) DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     GOBACK.

*> The component WS-TYPE of the patch WS-HANDLE as hex in WS-OUT ("-" without it).
 SHOW-COMPONENT.
     CALL "SP-GET-COMPONENT" USING WS-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND2
     MOVE SPACES TO WS-OUT
     IF WS-FOUND2 = 0
         MOVE "-" TO WS-OUT
     ELSE
         MOVE 1 TO WS-POS
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-LENGTH
             COMPUTE WS-BYTE = FUNCTION ORD(WS-VALUE(WS-J:1)) - 1
             DIVIDE WS-BYTE BY 16 GIVING WS-HI REMAINDER WS-LO
             MOVE WS-HEXDIGITS(WS-HI + 1:1) TO WS-OUT(WS-POS:1)
             MOVE WS-HEXDIGITS(WS-LO + 1:1) TO WS-OUT(WS-POS + 1:1)
             ADD 2 TO WS-POS
         END-PERFORM
     END-IF.
 END PROGRAM TEST-LOOT-FUNCTIONS-DATA.
 COPY CORETEST.
