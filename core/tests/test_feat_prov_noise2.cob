*> The refusals and variants of the noise providers (docs/protocol/35-worldgen-features-2 sections 4.5 and 5.1; core/src/feat-prov-noise.cob): each document is compiled with FD-PROV-NODE and
*> must compile whole (FD-BAD 0) or be refused (FD-BAD 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-PROV-NOISE2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY JSONDOC.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/feat".
 01 WS-TEXT                PIC X(600).
 01 WS-LEN                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-PV                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 3 TO CB-BLOCK-COUNT
     MOVE 300 TO CB-STATE-COUNT
     MOVE 21 TO CB-EPOCH
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:poppy" TO CB-KEY(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "NOISE-RESET"
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 123 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: plain noise" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":2,"base_amplitude":2.0},"scale":1.0,"seed":-9,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 124 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: positive octave and negative seed" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"states":[{"id":"minecraft:poppy"}]}' TO WS-TEXT
     MOVE 130 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: string-free state object" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:dual_noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"slow_noise":{"base_octave":0,"base_amplitude":1.0},"slow_scale":1.0,"states":["minecraft:poppy"],"variety":2}' TO WS-TEXT
     MOVE 209 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: variety as a number" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:dual_noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"slow_noise":{"base_octave":0,"base_amplitude":1.0},"slow_scale":1.0,"states":["minecraft:poppy"],"variety":{"min_inclusive":1,"max_inclusive":3}}' TO WS-TEXT
     MOVE 245 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: variety as an object" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:dual_noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"slow_noise":{"base_octave":0,"base_amplitude":1.0},"slow_scale":1.0,"states":["minecraft:poppy"],"variety":[1,2,3]}' TO WS-TEXT
     MOVE 215 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: variety list of three" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:dual_noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"slow_noise":{"base_octave":0,"base_amplitude":1.0},"slow_scale":1.0,"states":["minecraft:poppy"],"variety":[1,65]}' TO WS-TEXT
     MOVE 214 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: variety above 64" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:dual_noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"slow_noise":{"base_octave":0,"base_amplitude":1.0},"slow_scale":1.0,"states":["minecraft:poppy"],"variety":"x"}' TO WS-TEXT
     MOVE 211 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: variety is a string" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:dual_noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"slow_noise":{"base_octave":0,"base_amplitude":1.0},"slow_scale":1.0,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 197 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: variety missing" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 114 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: seed missing" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":1e+17,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 127 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: seed too large" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 76 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: noise missing" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":40},"scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 103 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: octave out of range" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_amplitude":1.0},"scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 107 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: octave missing" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"base_amplitude":1e-07},"scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 125 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: amplitude below range" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"base_amplitude":"x"},"scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 123 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: amplitude not a number" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"octave_count":"x"},"scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 121 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: octave_count not a number" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"normalize":false},"scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 120 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: normalize false" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"normalize":true,"amplitude_modifiers":[]},"scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 144 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: normalize true" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"amplitude_modifiers":[1.0]},"scale":1.0,"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 130 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: amplitude modifiers" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"base_amplitude":1.0},"seed":5,"states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 111 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: scale missing" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"states":"minecraft:poppy"}' TO WS-TEXT
     MOVE 121 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: states not a list" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5}' TO WS-TEXT
     MOVE 94 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: states missing" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:dual_noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"slow_noise":{"base_octave":0,"base_amplitude":1.0},"slow_scale":0,"states":["minecraft:poppy"],"variety":[1,2]}' TO WS-TEXT
     MOVE 211 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: slow scale zero" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:dual_noise","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"slow_noise":{"base_octave":99},"slow_scale":1.0,"states":["minecraft:poppy"],"variety":[1,2]}' TO WS-TEXT
     MOVE 193 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: slow noise bad" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise_threshold","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"threshold":0.0,"high_chance":0.5,"default_state":"minecraft:poppy","low_states":["minecraft:poppy"],"high_states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 239 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: threshold plain" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise_threshold","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"threshold":2,"high_chance":0.5,"default_state":"minecraft:poppy","low_states":["minecraft:poppy"],"high_states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 237 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: threshold above 1" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise_threshold","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"high_chance":0.5,"default_state":"minecraft:poppy","low_states":["minecraft:poppy"],"high_states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 223 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: threshold missing" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise_threshold","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"threshold":0.0,"high_chance":1.5,"default_state":"minecraft:poppy","low_states":["minecraft:poppy"],"high_states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 239 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: chance above 1" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise_threshold","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"threshold":0.0,"default_state":"minecraft:poppy","low_states":["minecraft:poppy"],"high_states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 221 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: chance missing" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise_threshold","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"threshold":0.0,"high_chance":0.5,"default_state":"minecraft:nothing","low_states":["minecraft:poppy"],"high_states":["minecraft:poppy"]}' TO WS-TEXT
     MOVE 241 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: default unknown" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type":"minecraft:noise_threshold","noise":{"base_octave":0,"base_amplitude":1.0},"scale":1.0,"seed":5,"threshold":0.0,"high_chance":0.5,"default_state":"minecraft:poppy","low_states":["minecraft:poppy"],"high_states":[]}' TO WS-TEXT
     MOVE 222 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: high states empty" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '"\"minecraft:no_such_named\""' TO WS-TEXT
     MOVE 29 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ROOT WS-PV
     MOVE "acceptance 35-2§5 noise provider: a string is not a provider that exists" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-PROV-NOISE2.
