*> Implementation test of the End's fixed values (core/src/end-38b.cob END-CONST; docs/protocol/38-end.md section 3, Noise settings `minecraft:end`): every value of the section's table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "noise-min-y" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§3 Noise settings `minecraft:end` noise-min-y" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "noise-height" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§3 Noise settings `minecraft:end` noise-height" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sea-level" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§3 Noise settings `minecraft:end` sea-level" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "legacy-random-source" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§3 Noise settings `minecraft:end` legacy-random-source" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "disable-mob-generation" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§3 Noise settings `minecraft:end` disable-mob-generation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "aquifers" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§3 Noise settings `minecraft:end` aquifers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "spawn-targets" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§3 Noise settings `minecraft:end` spawn-targets" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "skipped-draws" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§3 Noise settings `minecraft:end` skipped-draws" TO TL-CASE
     MOVE 17292 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
