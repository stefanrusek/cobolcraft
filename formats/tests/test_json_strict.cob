*> Implementation test of formats/src/json-strict.cob (JSON-STRICT; 23 §3.2): documents of the strict
*> grammar are accepted and give the same nodes as the lenient JSON-PARSE; comments, trailing commas,
*> unquoted names, duplicate keys (also through escapes), trailing data, bad numbers (NaN, a leading
*> zero, a bare minus), bad escapes and control characters, depth and node capacity are rejected with a
*> reason code and the 0-based byte offset of the problem. A rejected document has JD-ERROR 1 and no
*> nodes. Fixtures: contract/fixtures/formats/json (the reason of each in expected.txt).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-JSON-STRICT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FORMATS.
 COPY JSONDOC.
 01 WS-FILES.
*>   file name (40), reason (2 digits), offset (4 digits)
    05 FILLER PIC X(46) VALUE 'accept-object.json                      000000'.
    05 FILLER PIC X(46) VALUE 'accept-empty-containers.json            000000'.
    05 FILLER PIC X(46) VALUE 'accept-whitespace.json                  000000'.
    05 FILLER PIC X(46) VALUE 'accept-numbers.json                     000000'.
    05 FILLER PIC X(46) VALUE 'accept-escapes.json                     000000'.
    05 FILLER PIC X(46) VALUE 'accept-utf8.json                        000000'.
    05 FILLER PIC X(46) VALUE 'accept-scalar.json                      000000'.
    05 FILLER PIC X(46) VALUE 'accept-nested.json                      000000'.
    05 FILLER PIC X(46) VALUE 'accept-same-name-in-two-objects.json    000000'.
    05 FILLER PIC X(46) VALUE 'reject-comment-line.json                020008'.
    05 FILLER PIC X(46) VALUE 'reject-comment-block.json               020005'.
    05 FILLER PIC X(46) VALUE 'reject-trailing-comma-object.json       030006'.
    05 FILLER PIC X(46) VALUE 'reject-trailing-comma-array.json        030004'.
    05 FILLER PIC X(46) VALUE 'reject-duplicate-key.json               040013'.
    05 FILLER PIC X(46) VALUE 'reject-trailing-data.json               050008'.
    05 FILLER PIC X(46) VALUE 'reject-unquoted-name.json               070001'.
    05 FILLER PIC X(46) VALUE 'reject-single-quotes.json               010001'.
    05 FILLER PIC X(46) VALUE 'reject-unterminated-string.json         010005'.
    05 FILLER PIC X(46) VALUE 'reject-empty.json                       010000'.
    05 FILLER PIC X(46) VALUE 'reject-leading-zero.json                060001'.
    05 FILLER PIC X(46) VALUE 'reject-nan.json                         060001'.
    05 FILLER PIC X(46) VALUE 'reject-bad-escape.json                  100002'.
    05 FILLER PIC X(46) VALUE 'reject-control-character.json           100003'.
 01 WS-FILE-TABLE REDEFINES WS-FILES.
    05 WS-FILE             OCCURS 23 TIMES.
       10 WS-FILE-NAME     PIC X(40).
       10 WS-FILE-REASON   PIC 99.
       10 WS-FILE-OFFSET   PIC 9(4).
 01 WS-INLINE.
*>   text (40), length (2), reason (2), offset (4)
    05 FILLER PIC X(48) VALUE '{"o":{"k":1,"k":2}}                     19040012'.
    05 FILLER PIC X(48) VALUE '{"a":1,"\u0061":2}                      18040007'.
    05 FILLER PIC X(48) VALUE '{"a":1,"b":2}                           13000000'.
    05 FILLER PIC X(48) VALUE '{"\n":1,"n":2}                          14000000'.
    05 FILLER PIC X(48) VALUE '{"a\nb":1,"a\nb":2}                     19040010'.
    05 FILLER PIC X(48) VALUE '[1,2,3,3]                               09000000'.
    05 FILLER PIC X(48) VALUE '{"a":1,"A":2}                           13000000'.
    05 FILLER PIC X(48) VALUE '[1,/                                    04010003'.
    05 FILLER PIC X(48) VALUE '[1,/x]                                  06010003'.
    05 FILLER PIC X(48) VALUE '-                                       01060000'.
    05 FILLER PIC X(48) VALUE '[-x]                                    04060001'.
    05 FILLER PIC X(48) VALUE '[1.]                                    04060001'.
    05 FILLER PIC X(48) VALUE '[1.5e]                                  06060001'.
    05 FILLER PIC X(48) VALUE '[1e+]                                   05060001'.
    05 FILLER PIC X(48) VALUE '[-Infinity]                             11060001'.
    05 FILLER PIC X(48) VALUE '[Infinity]                              10060001'.
    05 FILLER PIC X(48) VALUE '[nul]                                   05010001'.
    05 FILLER PIC X(48) VALUE '[tru]                                   05010001'.
    05 FILLER PIC X(48) VALUE '[fals]                                  06010001'.
    05 FILLER PIC X(48) VALUE '[1}                                     03010002'.
    05 FILLER PIC X(48) VALUE '{"a":1]                                 07010006'.
    05 FILLER PIC X(48) VALUE '{"a" 1}                                 07010005'.
    05 FILLER PIC X(48) VALUE '{"a":1 "b":2}                           13010007'.
    05 FILLER PIC X(48) VALUE '{"a"}                                   05010004'.
    05 FILLER PIC X(48) VALUE '{"a"                                    04010004'.
    05 FILLER PIC X(48) VALUE '{,}                                     03010001'.
    05 FILLER PIC X(48) VALUE '[,1]                                    04010001'.
    05 FILLER PIC X(48) VALUE '{"a":,}                                 07010005'.
    05 FILLER PIC X(48) VALUE '{"a":}                                  06010005'.
    05 FILLER PIC X(48) VALUE '{"a":1,,}                               09010007'.
    05 FILLER PIC X(48) VALUE '{"a":1,"b"}                             11010010'.
    05 FILLER PIC X(48) VALUE '{1:2}                                   05070001'.
    05 FILLER PIC X(48) VALUE '{_a:2}                                  06070001'.
    05 FILLER PIC X(48) VALUE '{$a:2}                                  06070001'.
    05 FILLER PIC X(48) VALUE '{ }}                                    04050003'.
    05 FILLER PIC X(48) VALUE '[1]]                                    04050003'.
    05 FILLER PIC X(48) VALUE '1 2                                     03050002'.
    05 FILLER PIC X(48) VALUE '["\u12G4"]                              10100002'.
    05 FILLER PIC X(48) VALUE '["\u12"]                                08100002'.
    05 FILLER PIC X(48) VALUE '["abc\                                  06010001'.
    05 FILLER PIC X(48) VALUE '["abc                                   05010001'.
    05 FILLER PIC X(48) VALUE '/* c */ [1] /* d */                     19020000'.
    05 FILLER PIC X(48) VALUE '[1] // x                                08020004'.
    05 FILLER PIC X(48) VALUE '[0,-0,0.0,1E5,-1e-2]                    20000000'.
    05 FILLER PIC X(48) VALUE '[true,false,null]                       17000000'.
    05 FILLER PIC X(48) VALUE '[true ,false , null ]                   21000000'.
    05 FILLER PIC X(48) VALUE '{"":1}                                  06000000'.
    05 FILLER PIC X(48) VALUE '{"a":{"b":{"c":[]}}}                    20000000'.
    05 FILLER PIC X(48) VALUE '{"a":1,"b":[1,2,{"c":2,"c":3}]}         31040023'.
    05 FILLER PIC X(48) VALUE '[{"k":1},{"k":2}]                       17000000'.
    05 FILLER PIC X(48) VALUE '{"a":-}                                 07060005'.
    05 FILLER PIC X(48) VALUE '{"a" :1, "b" : 2 }                      18000000'.
    05 FILLER PIC X(48) VALUE '["a" "b"]                               09010005'.
    05 FILLER PIC X(48) VALUE '{"a":[1,2}                              10010009'.
    05 FILLER PIC X(48) VALUE '[]                                      02000000'.
    05 FILLER PIC X(48) VALUE '{}                                      02000000'.
    05 FILLER PIC X(48) VALUE '[ ]                                     03000000'.
    05 FILLER PIC X(48) VALUE '"\u1                                    04010000'.
    05 FILLER PIC X(48) VALUE '{"":1,"":2}                             11040006'.
    05 FILLER PIC X(48) VALUE '{"":1,"":2,"\n":3}                      18040006'.
    05 FILLER PIC X(48) VALUE '{"\n":1,"":2,"":3}                      18040013'.
 01 WS-INLINE-TABLE REDEFINES WS-INLINE.
    05 WS-CASE             OCCURS 61 TIMES.
       10 WS-CASE-TEXT     PIC X(40).
       10 WS-CASE-LENGTH   PIC 99.
       10 WS-CASE-REASON   PIC 99.
       10 WS-CASE-OFFSET   PIC 9(4).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(9000).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 9000.
 01 WS-STATUS              BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-REASON              BINARY-LONG.
 01 WS-LENIENT-COUNT       BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SHOWN               PIC -(9)9.
 01 WS-SHOWN2              PIC -(9)9.
 01 WS-NAME                PIC X(40).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-EXPECT-REASON       BINARY-LONG.
 01 WS-EXPECT-OFFSET       BINARY-LONG.
 PROCEDURE DIVISION.
*>   The fixture files of contract/fixtures/formats/json.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         MOVE SPACES TO WS-PATH
         MOVE WS-FILE-NAME(WS-I) TO WS-NAME
         STRING "contract/fixtures/formats/json/" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-PATH
         COMPUTE WS-PATH-LENGTH = 31 + FUNCTION LENGTH(FUNCTION TRIM(WS-NAME))
         CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-TEXT-LENGTH WS-STATUS
         MOVE WS-FILE-REASON(WS-I) TO WS-EXPECT-REASON
         MOVE WS-FILE-OFFSET(WS-I) TO WS-EXPECT-OFFSET
         MOVE SPACES TO TL-CASE
         STRING "json-strict " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
         IF WS-STATUS NOT = 0
             MOVE 1 TO WS-TEXT-LENGTH
             MOVE "?" TO WS-TEXT
             MOVE 99 TO WS-EXPECT-REASON
         END-IF
         PERFORM CHECK-TEXT
     END-PERFORM

*>   Inline cases of every reason and every branch of the scanner.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 61
         MOVE SPACES TO WS-TEXT
         MOVE WS-CASE-TEXT(WS-I) TO WS-TEXT
         MOVE WS-CASE-LENGTH(WS-I) TO WS-TEXT-LENGTH
         MOVE WS-CASE-REASON(WS-I) TO WS-EXPECT-REASON
         MOVE WS-CASE-OFFSET(WS-I) TO WS-EXPECT-OFFSET
         MOVE SPACES TO TL-CASE
         STRING "json-strict text " WS-TEXT(1:WS-TEXT-LENGTH) DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK-TEXT
     END-PERFORM

*>   A text with a tab in a string: control character at offset 3.
     MOVE SPACES TO WS-TEXT
     MOVE '["a' TO WS-TEXT(1:3)
     MOVE X"09" TO WS-TEXT(4:1)
     MOVE 'b"]' TO WS-TEXT(5:3)
     MOVE 7 TO WS-TEXT-LENGTH
     MOVE FM-JS-ESCAPE TO WS-EXPECT-REASON
     MOVE 3 TO WS-EXPECT-OFFSET
     MOVE "json-strict a tab inside a string is a control character at offset 3" TO TL-CASE
     PERFORM CHECK-TEXT

*>   Nesting: 64 levels pass, 65 are too deep (offset of the 65th bracket).
     MOVE SPACES TO WS-TEXT
     MOVE ALL "[" TO WS-TEXT(1:64)
     MOVE ALL "]" TO WS-TEXT(65:64)
     MOVE 128 TO WS-TEXT-LENGTH
     MOVE FM-JS-OK TO WS-EXPECT-REASON
     MOVE 0 TO WS-EXPECT-OFFSET
     MOVE "json-strict 64 nested arrays are accepted" TO TL-CASE
     PERFORM CHECK-TEXT
     MOVE SPACES TO WS-TEXT
     MOVE ALL "[" TO WS-TEXT(1:65)
     MOVE ALL "]" TO WS-TEXT(66:65)
     MOVE 130 TO WS-TEXT-LENGTH
     MOVE FM-JS-DEPTH TO WS-EXPECT-REASON
     MOVE 64 TO WS-EXPECT-OFFSET
     MOVE "json-strict 65 nested arrays are too deep, at offset 64" TO TL-CASE
     PERFORM CHECK-TEXT

*>   Nodes: an array of 4095 numbers is 4096 nodes (the most), 4096 numbers do not fit (offset 8191).
     MOVE SPACES TO WS-TEXT
     MOVE "[" TO WS-TEXT(1:1)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4094
         MOVE "0," TO WS-TEXT(WS-J * 2:2)
     END-PERFORM
     MOVE "0]" TO WS-TEXT(8190:2)
     MOVE 8191 TO WS-TEXT-LENGTH
     MOVE FM-JS-OK TO WS-EXPECT-REASON
     MOVE 0 TO WS-EXPECT-OFFSET
     MOVE "json-strict 4095 numbers in an array (4096 nodes) are accepted" TO TL-CASE
     PERFORM CHECK-TEXT
     MOVE SPACES TO WS-TEXT
     MOVE "[" TO WS-TEXT(1:1)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4095
         MOVE "0," TO WS-TEXT(WS-J * 2:2)
     END-PERFORM
     MOVE "0]" TO WS-TEXT(8192:2)
     MOVE 8193 TO WS-TEXT-LENGTH
     MOVE FM-JS-CAPACITY TO WS-EXPECT-REASON
     MOVE 8191 TO WS-EXPECT-OFFSET
     MOVE "json-strict 4096 numbers in an array are more nodes than the document holds" TO TL-CASE
     PERFORM CHECK-TEXT

*>   An accepted document is usable: the members are found, the strings decode.
     MOVE '{"a":{"b":[1,"x"]},"c":true}' TO WS-TEXT
     MOVE 28 TO WS-TEXT-LENGTH
     CALL "JSON-STRICT" USING WS-TEXT WS-TEXT-LENGTH JSON-DOC WS-OFFSET WS-REASON
     MOVE "a.b[1]" TO WS-PATH
     MOVE 6 TO WS-PATH-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
     MOVE "json-strict an accepted document is searchable: a.b[1] is node 5, a string" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-NODE TO TL-OBSERVED-N
     IF JN-TYPE(WS-NODE) NOT = JT-STRING
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-TEXT.
     CALL "JSON-STRICT" USING WS-TEXT WS-TEXT-LENGTH JSON-DOC WS-OFFSET WS-REASON
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE WS-EXPECT-REASON TO WS-SHOWN
     MOVE WS-EXPECT-OFFSET TO WS-SHOWN2
     STRING "reason " FUNCTION TRIM(WS-SHOWN) " offset " FUNCTION TRIM(WS-SHOWN2)
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-REASON TO WS-SHOWN
     MOVE WS-OFFSET TO WS-SHOWN2
     STRING "reason " FUNCTION TRIM(WS-SHOWN) " offset " FUNCTION TRIM(WS-SHOWN2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-REASON = 0 AND WS-EXPECT-REASON = 0
         MOVE "reason 0 offset 0" TO TL-EXPECTED
         MOVE "reason 0 offset 0" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A rejected text leaves no nodes and JD-ERROR 1; an accepted one has the nodes of JSON-PARSE.
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-LENIENT-COUNT
     IF WS-EXPECT-REASON = 0
         CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-TEXT-LENGTH
         MOVE JD-COUNT TO WS-LENIENT-COUNT
         CALL "JSON-STRICT" USING WS-TEXT WS-TEXT-LENGTH JSON-DOC WS-OFFSET WS-REASON
         MOVE WS-LENIENT-COUNT TO TL-EXPECTED-N
         MOVE JD-COUNT TO TL-OBSERVED-N
         IF JD-ERROR NOT = 0
             MOVE -1 TO TL-OBSERVED-N
         END-IF
     ELSE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF JD-ERROR = 1 AND JD-COUNT = 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     MOVE FUNCTION CONCATENATE(FUNCTION TRIM(TL-CASE) " (document)") TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-JSON-STRICT.
