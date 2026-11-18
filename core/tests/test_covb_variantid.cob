*> Implementation test (lane covB; docs/protocol/19 sections 1.3 and 1.6; 00 section 13.2): the registry id of a variant is the position of its file in the registry as loaded, looked up by key:
*> with a registry that holds two wolf variants each key gives its own id (0 or 1) and a key the registry lacks gives 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-VARIANTID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-REG                 PIC X(112) VALUE "wolf_variant".
 01 WS-WANT                PIC X(48).
 01 WS-ID-A                BINARY-LONG.
 01 WS-ID-B                BINARY-LONG.
 01 WS-ID-C                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "core/tests/fixtures/covb-paint" TO CS-GENERATED-DIR
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "ashen" TO WS-WANT
     CALL "M44-VARIANT-ID" USING WS-REG WS-WANT WS-ID-A
     MOVE "test" TO WS-WANT
     CALL "M44-VARIANT-ID" USING WS-REG WS-WANT WS-ID-B
     MOVE "no_such_variant" TO WS-WANT
     CALL "M44-VARIANT-ID" USING WS-REG WS-WANT WS-ID-C
     MOVE "covB 19 1.3 the two wolf variants of the registry have the ids 0 and 1 between them" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ID-A + WS-ID-B
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 19 1.3 each key has its own id" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ID-A NOT = WS-ID-B
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 19 1.3 a key the registry lacks gives 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ID-C TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-VARIANTID.
 COPY NOSPAWN.
 COPY CORETEST.
