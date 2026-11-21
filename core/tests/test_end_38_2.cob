*> Implementation test of the End's fixed values (core/src/end-38b.cob END-CONST; docs/protocol/38-end.md section 2, Dimension type `minecraft:the_end`): every value of the section's table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "min-y" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` min-y" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "height" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` height" TO TL-CASE
     MOVE 256 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "logical-height" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` logical-height" TO TL-CASE
     MOVE 256 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "has-skylight" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` has-skylight" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "has-ceiling" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` has-ceiling" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "has-fixed-time" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` has-fixed-time" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "has-dragon-fight" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` has-dragon-fight" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ambient-light-x100" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` ambient-light-x100" TO TL-CASE
     MOVE 25 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "monster-light-level" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` monster-light-level" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "monster-block-light-limit" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` monster-block-light-limit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sky-color" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` sky-color" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fog-color" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` fog-color" TO TL-CASE
     MOVE 1577752 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ambient-light-color" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` ambient-light-color" TO TL-CASE
     MOVE 4147007 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sky-light-color" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` sky-light-color" TO TL-CASE
     MOVE 11296973 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sky-light-factor-x100" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` sky-light-factor-x100" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bed-can-set-spawn" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` bed-can-set-spawn" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bed-can-sleep" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` bed-can-sleep" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bed-destroy-on-use" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` bed-destroy-on-use" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "respawn-anchor-works" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` respawn-anchor-works" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "music-delay-min" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` music-delay-min" TO TL-CASE
     MOVE 6000 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "music-delay-max" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` music-delay-max" TO TL-CASE
     MOVE 24000 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mood-delay" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` mood-delay" TO TL-CASE
     MOVE 6000 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mood-extent" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§2 Dimension type `minecraft:the_end` mood-extent" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
