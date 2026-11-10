*> Test of the ordering of block state property values (26 section 10.3, state properties: "the state's value must be >= min and <= max in the
*> property's ordering: false < true for booleans, enum ordinal order, numeric order for integers; an unparsable bound fails"): LOOT-SPEC-ORDINAL
*> USING the value spec of a property as the block rows write it ("a/b/c" an enum in declaration order, "lo..hi" an integer range, "bool"), a value
*> text, ordinal out (-1 for a value the spec does not hold). A list of the two values true and false is a boolean (false first whatever the order
*> of the row). Expected values are the positions of the document's rule, written out by hand.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "x/y/z|x|0".
    05 FILLER PIC X(60) VALUE "x/y/z|y|1".
    05 FILLER PIC X(60) VALUE "x/y/z|z|2".
    05 FILLER PIC X(60) VALUE "x/y/z|w|-1".
    05 FILLER PIC X(60) VALUE "x/y/z|xy|-1".
    05 FILLER PIC X(60) VALUE "north/east/south/west|south|2".
    05 FILLER PIC X(60) VALUE "true/false|false|0".
    05 FILLER PIC X(60) VALUE "true/false|true|1".
    05 FILLER PIC X(60) VALUE "false/true|true|1".
    05 FILLER PIC X(60) VALUE "true/false|maybe|-1".
    05 FILLER PIC X(60) VALUE "bool|false|0".
    05 FILLER PIC X(60) VALUE "bool|true|1".
    05 FILLER PIC X(60) VALUE "bool|maybe|-1".
    05 FILLER PIC X(60) VALUE "0..15|0|0".
    05 FILLER PIC X(60) VALUE "0..15|7|7".
    05 FILLER PIC X(60) VALUE "0..15|15|15".
    05 FILLER PIC X(60) VALUE "0..15|16|-1".
    05 FILLER PIC X(60) VALUE "1..4|0|-1".
    05 FILLER PIC X(60) VALUE "1..4|1|1".
    05 FILLER PIC X(60) VALUE "1..4|abc|-1".
    05 FILLER PIC X(60) VALUE "1..4|2x|-1".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE             PIC X(60) OCCURS 21 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-SPEC                PIC X(280).
 01 WS-VALUE               PIC X(32).
 01 WS-EXPECT              PIC X(8).
 01 WS-ORDINAL             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 21
         MOVE SPACES TO WS-SPEC WS-VALUE WS-EXPECT
         UNSTRING WS-CASE(WS-I) DELIMITED BY "|" INTO WS-SPEC WS-VALUE WS-EXPECT
         CALL "LOOT-SPEC-ORDINAL" USING WS-SPEC WS-VALUE WS-ORDINAL
         MOVE SPACES TO TL-CASE
         STRING "test loot state ordinal of " FUNCTION TRIM(WS-VALUE) " in " FUNCTION TRIM(WS-SPEC) DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = FUNCTION NUMVAL(WS-EXPECT)
         MOVE WS-ORDINAL TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-LOOT-STATE.
