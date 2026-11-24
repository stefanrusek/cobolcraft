*> Acceptance test (lane p49a, T14502; docs/protocol/18-mob-framework.md section 10.2 A natural spawn attempt): the parts of the worked example that do not
*> depend on its hand-picked random draws: the category filter of the tick (gameTime mod 400 != 0 excludes CREATURE, MONSTER stays at count 12), the
*> global cap arithmetic (70 with 289 chunks, 6 with 25), the plains MONSTER list of appendix A (total 515) and the position draw ranges (x in the chunk's 16,
*> y in [minY, top] with the minY + 1 floor). The draws themselves (nextInt(16) = 5 ...) cannot be fed to the xoroshiro source: see the lane report.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-10-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY MOBSPAWN.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-TIME               BINARY-DOUBLE.
 01 WS-MOBS               BINARY-LONG VALUE 1.
 01 WS-MONSTERS           BINARY-LONG VALUE 1.
 01 WS-COUNTS.
    05 WS-COUNT           BINARY-LONG OCCURS 8 TIMES.
 01 WS-CHUNKS             BINARY-LONG.
 01 WS-FLAGS.
    05 WS-FLAG            BINARY-LONG OCCURS 8 TIMES.
 01 WS-N                  BINARY-LONG.
 01 WS-KEY                PIC X(48).
 01 WS-BIOME              BINARY-LONG.
 01 WS-CAT                BINARY-LONG.
 01 WS-TOTAL              BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-CX                 BINARY-LONG VALUE 192.
 01 WS-CZ                 BINARY-LONG VALUE 0.
 01 WS-MINY               BINARY-LONG VALUE -64.
 01 WS-TOP                BINARY-LONG VALUE 65.
 01 WS-X                  BINARY-LONG.
 01 WS-Y                  BINARY-LONG.
 01 WS-Z                  BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-BAD                BINARY-LONG.
 01 WS-LOW-OK             BINARY-LONG.
 PROCEDURE DIVISION.
*>   Setup: one player, difficulty Normal, spawn_mobs true, game time 401 (mod 400 != 0), 289 chunks counted, 12 monsters.
     MOVE 401 TO WS-TIME
     MOVE 289 TO WS-CHUNKS
     INITIALIZE WS-COUNTS
     MOVE 12 TO WS-COUNT(1)
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: MONSTER (12 below the cap 70) is in the category list" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FLAG(1) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: CREATURE is excluded this tick (gameTime mod 400 != 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FLAG(2) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-CAT
     MOVE 12 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: 12 monsters pass the global cap 70 x 289 / 289" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE 69 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: the cap with 289 chunks is exactly 70 (69 pass)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE 70 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: 70 do not" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
*>   With 25 chunks counted (view distance 2) the cap is 70 x 25 / 289 = 6.
     MOVE 25 TO WS-CHUNKS
     MOVE 5 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: with 25 chunks the cap is 6 (5 pass)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE 6 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: and 6 do not" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
*>   Plains: the MONSTER list of appendix A has the total weight 515 (spider 100, zombie 90, zombie_villager 5, zombie_horse 5, skeleton 100, creeper 100, slime 100,
*>   enderman 10, witch 5).
     MOVE "minecraft:plains" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-BIOME
     MOVE 1 TO WS-CAT
     CALL "MS6-LIST-TOTAL" USING WS-BIOME WS-CAT WS-TOTAL
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: the plains MONSTER list has the total weight 515" TO WS-CASE
     MOVE 515 TO WS-E
     MOVE WS-TOTAL TO WS-O
     PERFORM CHECK-N
*>   The position draw: x = 192 + nextInt(16), z = nextInt(16), y in [-64, 65]; ok only for y >= -63.
     MOVE 5 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     MOVE 0 TO WS-BAD WS-LOW-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         CALL "MS6-RANDOM-POS" USING XR-STATE WS-CX WS-CZ WS-MINY WS-TOP WS-X WS-Y WS-Z WS-OK
         IF WS-X < 192 OR WS-X > 207 OR WS-Z < 0 OR WS-Z > 15 OR WS-Y < -64 OR WS-Y > 65
             ADD 1 TO WS-BAD
         END-IF
         IF WS-Y = -64 AND WS-OK = 1
             ADD 1 TO WS-LOW-OK
         END-IF
         IF WS-Y > -64 AND WS-OK = 0
             ADD 1 TO WS-LOW-OK
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: 300 position draws stay in the chunk and in [minY, top]" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BAD TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§10.2 A natural spawn attempt: ok is exactly y >= minY + 1" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-LOW-OK TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-10-2.
