*> Implementation test of client/src/packs/blockstates.cob (BLOCKSTATE-SELECT; 08 §4, §10.6):
*> the built-in block state files select one model and Variant rotation for every block state of
*> standin-content §1.2 (void has no file); variant keys name some or all properties, the empty key
*> matches every state; multipart cases apply every model whose condition holds (key-value terms
*> with "|" and "!", AND, OR, no condition); variants come first and multipart only fills states no
*> variant matched; a weighted list contributes its first entry; Quadrant values are taken modulo 360.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCKSTATES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY JSONDOC.
 COPY CLMODEL.
 COPY TESTLIB.
 01 WS-EXPECTED-DATA.
    05 FILLER PIC X(48) VALUE "baseplate 0 0".
    05 FILLER PIC X(48) VALUE "greystone 0 0".
    05 FILLER PIC X(48) VALUE "loam 0 0".
    05 FILLER PIC X(48) VALUE "turf 0 0".
    05 FILLER PIC X(48) VALUE "grit 0 0".
    05 FILLER PIC X(48) VALUE "cardstack_punched 90 90".
    05 FILLER PIC X(48) VALUE "cardstack 90 90".
    05 FILLER PIC X(48) VALUE "cardstack_punched 0 0".
    05 FILLER PIC X(48) VALUE "cardstack 0 0".
    05 FILLER PIC X(48) VALUE "cardstack_punched 90 0".
    05 FILLER PIC X(48) VALUE "cardstack 90 0".
    05 FILLER PIC X(48) VALUE "lucite 0 0".
    05 FILLER PIC X(48) VALUE "glowtube_lit 0 0".
    05 FILLER PIC X(48) VALUE "glowtube_unlit 0 0".
    05 FILLER PIC X(48) VALUE "ledger_tile 0 0".
    05 FILLER PIC X(48) VALUE "goto_pad 0 0".
    05 FILLER PIC X(48) VALUE "slag 0 0".
 01 WS-EXPECTED-TABLE REDEFINES WS-EXPECTED-DATA.
    05 WS-EXPECTED         PIC X(48) OCCURS 17 TIMES.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(8192).
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BLOCK               PIC X(32).
 01 WS-PROPS               PIC X(62).
 01 WS-PROPS-LENGTH        BINARY-LONG.
 01 WS-OUT                 PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-FULL                BINARY-LONG VALUE 0.
 01 WS-EDIT                PIC Z(2)9.
 01 WS-EDIT2               PIC Z(2)9.
 01 WS-EDIT3               PIC Z(2)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     PERFORM VARYING WS-S FROM 2 BY 1 UNTIL WS-S > 18
         MOVE SPACES TO WS-BLOCK WS-PROPS WS-PATH
         UNSTRING CL-BS-TEXT(WS-S) DELIMITED BY SPACE INTO WS-BLOCK WS-PROPS
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PROPS)) TO WS-PROPS-LENGTH
         IF WS-PROPS = SPACES
             MOVE 0 TO WS-PROPS-LENGTH
         END-IF
         STRING "assets/cobolcraft/blockstates/" FUNCTION TRIM(WS-BLOCK) ".json"
             DELIMITED BY SIZE INTO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH
             WS-FOUND
         CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
         CALL "BLOCKSTATE-SELECT" USING JSON-DOC WS-PROPS WS-PROPS-LENGTH STATE-MODELS
         PERFORM SHOW-MODELS
         STRING FUNCTION TRIM(TL-OBSERVED) "|" FUNCTION TRIM(WS-OUT) DELIMITED BY SIZE
             INTO TL-OBSERVED
         STRING FUNCTION TRIM(TL-EXPECTED) "|cobolcraft:block/" FUNCTION TRIM(WS-EXPECTED(WS-S - 1))
             DELIMITED BY SIZE INTO TL-EXPECTED
     END-PERFORM
     MOVE "blockstates every state 1 to 17 of standin-content §1.2 gets one model and its "
         & "rotation (x, y) from the built-in files" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A file with both forms: variants first, multipart for states no variant matched.
     MOVE 1 TO WS-FULL
     MOVE '{"variants":{"axis=y":{"model":"v","y":-90}},"multipart":[{"apply":{"model":"a"}},'
         & '{"when":{"punched":"true"},"apply":{"model":"b","x":450,"uvlock":true}},'
         & '{"when":{"OR":[{"axis":"x|z","punched":"!false"},{"axis":"!y"}]},'
         & '"apply":[{"model":"c","weight":3},{"model":"d"}]},'
         & '{"when":{"AND":[{"axis":"z"},{"punched":false}]},"apply":{"model":"e","z":180}},'
         & '{"when":{"axis":"y"},"apply":{"model":"f"}}]}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
     MOVE "blockstates a matching variant wins; -90 is 270" TO TL-CASE
     MOVE "axis=y,punched=true" TO WS-PROPS
     MOVE 19 TO WS-PROPS-LENGTH
     CALL "BLOCKSTATE-SELECT" USING JSON-DOC WS-PROPS WS-PROPS-LENGTH STATE-MODELS
     PERFORM SHOW-MODELS
     MOVE "v 0 270 0" TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "blockstates multipart for axis=z,punched=true: no condition, a term, OR of key-value "
         & "sets (first weighted entry), 450 is 90" TO TL-CASE
     MOVE "axis=z,punched=true" TO WS-PROPS
     CALL "BLOCKSTATE-SELECT" USING JSON-DOC WS-PROPS WS-PROPS-LENGTH STATE-MODELS
     PERFORM SHOW-MODELS
     MOVE "a 0 0 0, b 90 0 0 uvlock, c 0 0 0" TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "blockstates multipart for axis=z,punched=false: AND holds, a boolean term, OR by its "
         & "second set" TO TL-CASE
     MOVE "axis=z,punched=false" TO WS-PROPS
     MOVE 20 TO WS-PROPS-LENGTH
     CALL "BLOCKSTATE-SELECT" USING JSON-DOC WS-PROPS WS-PROPS-LENGTH STATE-MODELS
     PERFORM SHOW-MODELS
     MOVE "a 0 0 0, c 0 0 0, e 0 0 180" TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE '{"multipart":[{"when":{"lit":true},"apply":{"model":"t"}},'
         & '{"when":{"level":3},"apply":{"model":"n"}},{"when":{"lit":false},"apply":{"model":"f"}}]}'
         TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
     MOVE "level=3,lit=true" TO WS-PROPS
     MOVE 16 TO WS-PROPS-LENGTH
     CALL "BLOCKSTATE-SELECT" USING JSON-DOC WS-PROPS WS-PROPS-LENGTH STATE-MODELS
     PERFORM SHOW-MODELS
     MOVE "blockstates multipart terms given as JSON true, false and a number match their text"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "t 0 0 0, n 0 0 0" TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE '{"variants":{"lit=true":{"model":"x"}}}' TO WS-TEXT
     MOVE 38 TO WS-LENGTH
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
     MOVE "lit=false" TO WS-PROPS
     MOVE 9 TO WS-PROPS-LENGTH
     CALL "BLOCKSTATE-SELECT" USING JSON-DOC WS-PROPS WS-PROPS-LENGTH STATE-MODELS
     MOVE "blockstates a state no variant matches gets no model" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SX-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SHOW-MODELS.
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SX-COUNT
         MOVE SX-X(WS-I) TO WS-EDIT
         MOVE SX-Y(WS-I) TO WS-EDIT2
         MOVE SX-Z(WS-I) TO WS-EDIT3
         IF WS-I > 1
             STRING ", " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(SX-ID(WS-I)) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2)
             DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         IF WS-FULL = 1
             STRING " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
             IF SX-UVLOCK(WS-I) = 1
                 STRING " uvlock" DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-BLOCKSTATES.
