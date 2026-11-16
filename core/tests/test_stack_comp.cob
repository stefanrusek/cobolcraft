*> Test of the typed component accessors over the stack patch pool (core/src/stack-comp.cob; docs/protocol/17 section 1.2, 46 section 8.1; T9600): enchantments and
*> stored_enchantments are read, written, counted and enumerated by component type; the 13 accessors of stack-patch.cob are the same programs for type 13.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STACK-COMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CSTACK.
 COPY CONTENT.
 COPY COREAPI.
 COPY PROTO.
 01 WS-H1                  BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-T13                 BINARY-LONG VALUE 13.
 01 WS-T45                 BINARY-LONG VALUE 45.
 01 WS-ID                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM CLEAR-POOL

     MOVE "test stack comp stored enchantments are separate from enchantments and listed by ascending id" TO TL-CASE
     MOVE 0 TO WS-H1
     MOVE 40 TO WS-ID
     MOVE 2 TO WS-LEVEL
     CALL "SC-ENCH-ADD" USING WS-H1 WS-T45 WS-ID WS-LEVEL
     MOVE 7 TO WS-ID
     MOVE 3 TO WS-LEVEL
     CALL "SC-ENCH-ADD" USING WS-H1 WS-T45 WS-ID WS-LEVEL
     MOVE 40 TO WS-ID
     MOVE 5 TO WS-LEVEL
     CALL "SC-ENCH-ADD" USING WS-H1 WS-T45 WS-ID WS-LEVEL
     CALL "SC-ENCH-COUNT" USING WS-H1 WS-T45 WS-N
     CALL "SC-ENCH-COUNT" USING WS-H1 WS-T13 WS-A
     MOVE 1 TO WS-I
     CALL "SC-ENCH-NTH" USING WS-H1 WS-T45 WS-I WS-ID WS-LEVEL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-N TO WS-E1
     MOVE WS-A TO WS-E2
     MOVE WS-ID TO WS-E3
     MOVE WS-LEVEL TO WS-E4
     STRING "n=" FUNCTION TRIM(WS-E1) " plain=" FUNCTION TRIM(WS-E2) " first=" FUNCTION TRIM(WS-E3) "/" FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "n=2 plain=0 first=7/3" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CLEAR-POOL.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 512
         MOVE 0 TO SP-LIVE(WS-I)
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STACK-COMP.
 COPY CORETEST.
