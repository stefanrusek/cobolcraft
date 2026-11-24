*> Implementation test of the behaviour summary of the End (core/src/end-38.cob, end-38c.cob, end-38e.cob; T1743, T1744; docs/protocol/38-end.md section 12), the six items
*> end to end for seed 0 in a standard world: terrain and decoration of chunk (2, 0) (the pillar of spike 0 at (42, 0): obsidian to y 93, bedrock cap at y 94, fire at y 95, a crystal
*> asked for, air above y 65 around it), of chunk (6, 0) (the platform at y 48), small islands in the void of small_end_islands chunks (some chunk of the scan holds end_stone from the
*> island feature, and only at y 55 to 70; the void is not generated for the scan), chorus plants on the highlands (some chunk of the scan holds chorus blocks), the arrival constants and the empty features of a midlands or
*> barrens chunk (placed 0); needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY ENDSPIKE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-CHUNK               PIC X(304640).
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160).
 01 WS-S-OBSIDIAN          BINARY-LONG.
 01 WS-S-BEDROCK           BINARY-LONG.
 01 WS-S-FIRE              BINARY-LONG.
 01 WS-S-END-STONE         BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-B-PLANT             BINARY-LONG.
 01 WS-B-FLOWER            BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-CHORUS              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-PTR                 USAGE POINTER.
 01 WS-MINY                BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 0.
 01 WS-S-GATEWAY           BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SEED-NEG            BINARY-DOUBLE SIGNED VALUE -7.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "acceptance US12 38§12 Behaviour summary for implementers: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-PAIRS
     MOVE "obsidian" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-OBSIDIAN
     MOVE "bedrock" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-BEDROCK
     MOVE "fire" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-FIRE
     MOVE "end_stone" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-END-STONE
     MOVE "chorus_plant" TO WS-KEY112
     CALL "BLOCKS-ID-OF" USING WS-KEY112 WS-B-PLANT
     MOVE "chorus_flower" TO WS-KEY112
     CALL "BLOCKS-ID-OF" USING WS-KEY112 WS-B-FLOWER
*>   items 2 and 4: chunk (2, 0) of the central disc: terrain, then the pillar of spike 0
     MOVE 2 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "END-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     CALL "END-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-CHUNK CRYSTAL-LIST WS-PLACED
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK
     MOVE "acceptance US12 38§12 Behaviour summary for implementers the_end chunk runs two placed features" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§12 Behaviour summary for implementers pillar of spike 0 asks for one crystal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 93 TO WS-Y
     PERFORM STATE-AT-42
     MOVE "acceptance US12 38§12 Behaviour summary for implementers pillar top (42, 93, 0) is obsidian" TO TL-CASE
     MOVE WS-S-OBSIDIAN TO TL-EXPECTED-N
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 94 TO WS-Y
     PERFORM STATE-AT-42
     MOVE "acceptance US12 38§12 Behaviour summary for implementers cap (42, 94, 0) is bedrock" TO TL-CASE
     MOVE WS-S-BEDROCK TO TL-EXPECTED-N
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 95 TO WS-Y
     PERFORM STATE-AT-42
     MOVE "acceptance US12 38§12 Behaviour summary for implementers fire (42, 95, 0)" TO TL-CASE
     MOVE WS-S-FIRE TO TL-EXPECTED-N
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 80 TO WS-Y
     PERFORM STATE-AT-42
     MOVE "acceptance US12 38§12 Behaviour summary for implementers inside the pillar (42, 80, 0) is obsidian" TO TL-CASE
     MOVE WS-S-OBSIDIAN TO TL-EXPECTED-N
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   item 5: the platform of chunk (6, 0): obsidian at (100, 48, 0)
     MOVE 6 TO WS-CX
     CALL "END-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     CALL "END-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-CHUNK CRYSTAL-LIST WS-PLACED
     COMPUTE WS-CELL = 48 * 256 + 0 * 16 + 4 + 1
     MOVE "acceptance US12 38§12 Behaviour summary for implementers platform (100, 48, 0) is obsidian" TO TL-CASE
     MOVE WS-S-OBSIDIAN TO TL-EXPECTED-N
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-CELL = 49 * 256 + 0 * 16 + 4 + 1
     MOVE "acceptance US12 38§12 Behaviour summary for implementers platform air above it (100, 49, 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   item 3: the void island chunks (small_end_islands around (2000, 2000)): islands only at y 55 to 70
     MOVE 0 TO WS-FOUND WS-LOW
     PERFORM VARYING WS-CX FROM 120 BY 1 UNTIL WS-CX > 149
         PERFORM VARYING WS-CZ FROM 120 BY 1 UNTIL WS-CZ > 129
             CALL "END-BIOME-OF" USING WS-CX WS-CZ WS-IDX
             IF WS-IDX = 4
                 MOVE LOW-VALUES TO WS-CHUNK
                 CALL "END-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-CHUNK CRYSTAL-LIST WS-PLACED
                 PERFORM SCAN-STONE
                 IF WS-HIGH > 0
                     ADD 1 TO WS-FOUND
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 38§12 Behaviour summary for implementers some small_end_islands chunk holds an island" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§12 Behaviour summary for implementers island stone lies at y 49 to 70 only (origin 55 to 70, discs reach five layers down)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LOW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   item 4: chorus plants on the highlands
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-CX FROM 187 BY 1 UNTIL WS-CX > 190
         PERFORM VARYING WS-CZ FROM 187 BY 1 UNTIL WS-CZ > 190
             CALL "END-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
             CALL "END-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-CHUNK CRYSTAL-LIST WS-PLACED
             PERFORM SCAN-CHORUS
             IF WS-CHORUS > 0
                 ADD 1 TO WS-FOUND
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 38§12 Behaviour summary for implementers some highlands chunk holds chorus plants" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the gateway modifiers (rarity 700 makes it rare, so the rest of the chain runs on its own) on the highlands chunk (190, 190) that is still in memory
     MOVE "end_gateway" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-GATEWAY
     SET WS-PTR TO ADDRESS OF WS-CHUNK
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MINY WS-HEIGHT WS-SEA
     COMPUTE WS-BX = WS-CX * 16
     COMPUTE WS-BZ = WS-CZ * 16
*>   a seed whose first float passes the rarity filter 700 (about one in 700 does): the whole feature then runs
     MOVE 0 TO WS-FOUND
     MOVE 1 TO WS-U
     PERFORM UNTIL WS-FOUND = 1
         CALL "WGR-SET-SEED" USING WS-XR WS-U
         CALL "WGR-NEXT-FLOAT" USING WS-XR WS-F
         IF WS-F < 0.0014285714
             MOVE 1 TO WS-FOUND
         ELSE
             ADD 1 TO WS-U
         END-IF
     END-PERFORM
     CALL "WGR-SET-SEED" USING WS-XR WS-U
     CALL "END-GATEWAY-FEATURE" USING WS-XR WS-BX WS-BZ
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 65536 OR WS-FOUND = 1
         IF CE-STATE(WS-CELL) = WS-S-GATEWAY
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     CALL "FL-CLOSE"
     MOVE "acceptance US12 38§12 Behaviour summary for implementers a gateway stands over the highlands surface" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a negative world seed makes the same chain from its unsigned bits
     MOVE 2 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "END-GEN-FEATURES" USING WS-SEED-NEG WS-CX WS-CZ WS-CHUNK CRYSTAL-LIST WS-PLACED
     MOVE "acceptance US12 38§12 Behaviour summary for implementers seed -7 runs the two placed features of the_end chunk (2, 0)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a barrens chunk runs no feature: chunk (63, 63) is end_barrens
     MOVE 63 TO WS-CX
     MOVE 63 TO WS-CZ
     CALL "END-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     CALL "END-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-CHUNK CRYSTAL-LIST WS-PLACED
     MOVE "acceptance US12 38§12 Behaviour summary for implementers a barrens chunk runs no placed feature" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   item 5 and 6: arrival and the dimension's values
     MOVE "platform-floor-y" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§12 Behaviour summary for implementers platform floor y 48" TO TL-CASE
     MOVE 48 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "arrival-yaw" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VALUE
     MOVE "acceptance US12 38§12 Behaviour summary for implementers arrival yaw 90" TO TL-CASE
     MOVE 90 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 STATE-AT-42.
     COMPUTE WS-CELL = WS-Y * 256 + 0 * 16 + 10 + 1.
 SCAN-STONE.
     MOVE 0 TO WS-HIGH
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 65536
         IF CE-STATE(WS-CELL) NOT = 0
             COMPUTE WS-Y = (WS-CELL - 1) / 256
             IF WS-Y >= 49 AND WS-Y <= 70
                 ADD 1 TO WS-HIGH
             ELSE
                 ADD 1 TO WS-LOW
             END-IF
         END-IF
     END-PERFORM.
 SCAN-CHORUS.
     MOVE 0 TO WS-CHORUS
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 65536 OR WS-CHORUS > 0
         IF CE-STATE(WS-CELL) NOT = 0 AND CE-STATE(WS-CELL) NOT = WS-S-END-STONE
             MOVE CB-S-BLOCK(CE-STATE(WS-CELL) + 1) TO WS-BLOCK
             IF WS-BLOCK = WS-B-PLANT OR WS-BLOCK = WS-B-FLOWER
                 ADD 1 TO WS-CHORUS
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-END-38-12.

 COPY CORETEST.
 COPY PORTALTEST.
