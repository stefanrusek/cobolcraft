*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 1.2, with doc 44 part 2 section 8): the mob categories.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-1-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBCATS.
 COPY MOB181.
 01 WS-NAME               PIC X(32).
 01 WS-X                  BINARY-LONG.
 01 WS-KEY                PIC X(24).
 01 WS-ROW                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 1 TO WS-X
     CALL "M181-CAT-NAME" USING WS-X WS-NAME
     MOVE "acceptance US15 18§1.2 Mob categories: category 1 is serialized as monster" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "monster" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: monster caps at 70 per chunk unit" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 70
     COMPUTE TL-OBSERVED-N ROUNDED = MC-MAX(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: monster friendly 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MC-FRIENDLY(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: monster persistent 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MC-PERSIST(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: monster despawns at 128 blocks" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 128
     COMPUTE TL-OBSERVED-N ROUNDED = MC-DESPAWN(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-X
     CALL "M181-CAT-SPAWNING" USING WS-X WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: monster takes part in natural spawning" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-X
     CALL "M181-CAT-NAME" USING WS-X WS-NAME
     MOVE "acceptance US15 18§1.2 Mob categories: category 2 is serialized as creature" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "creature" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: creature caps at 10 per chunk unit" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 10
     COMPUTE TL-OBSERVED-N ROUNDED = MC-MAX(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: creature friendly 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-FRIENDLY(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: creature persistent 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-PERSIST(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: creature despawns at 128 blocks" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 128
     COMPUTE TL-OBSERVED-N ROUNDED = MC-DESPAWN(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-X
     CALL "M181-CAT-SPAWNING" USING WS-X WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: creature takes part in natural spawning" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-X
     CALL "M181-CAT-NAME" USING WS-X WS-NAME
     MOVE "acceptance US15 18§1.2 Mob categories: category 3 is serialized as ambient" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ambient" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: ambient caps at 15 per chunk unit" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 15
     COMPUTE TL-OBSERVED-N ROUNDED = MC-MAX(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: ambient friendly 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-FRIENDLY(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: ambient persistent 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MC-PERSIST(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: ambient despawns at 128 blocks" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 128
     COMPUTE TL-OBSERVED-N ROUNDED = MC-DESPAWN(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-X
     CALL "M181-CAT-SPAWNING" USING WS-X WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: ambient takes part in natural spawning" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-X
     CALL "M181-CAT-NAME" USING WS-X WS-NAME
     MOVE "acceptance US15 18§1.2 Mob categories: category 4 is serialized as axolotls" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "axolotls" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: axolotls caps at 5 per chunk unit" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 5
     COMPUTE TL-OBSERVED-N ROUNDED = MC-MAX(4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: axolotls friendly 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-FRIENDLY(4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: axolotls persistent 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MC-PERSIST(4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: axolotls despawns at 128 blocks" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 128
     COMPUTE TL-OBSERVED-N ROUNDED = MC-DESPAWN(4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-X
     CALL "M181-CAT-SPAWNING" USING WS-X WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: axolotls takes part in natural spawning" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     CALL "M181-CAT-NAME" USING WS-X WS-NAME
     MOVE "acceptance US15 18§1.2 Mob categories: category 5 is serialized as underground_water_creature" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "underground_water_creature" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: underground_water_creature caps at 5 per chunk unit" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 5
     COMPUTE TL-OBSERVED-N ROUNDED = MC-MAX(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: underground_water_creature friendly 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-FRIENDLY(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: underground_water_creature persistent 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MC-PERSIST(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: underground_water_creature despawns at 128 blocks" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 128
     COMPUTE TL-OBSERVED-N ROUNDED = MC-DESPAWN(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     CALL "M181-CAT-SPAWNING" USING WS-X WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: underground_water_creature takes part in natural spawning" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-X
     CALL "M181-CAT-NAME" USING WS-X WS-NAME
     MOVE "acceptance US15 18§1.2 Mob categories: category 6 is serialized as water_creature" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "water_creature" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: water_creature caps at 5 per chunk unit" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 5
     COMPUTE TL-OBSERVED-N ROUNDED = MC-MAX(6)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: water_creature friendly 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-FRIENDLY(6)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: water_creature persistent 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MC-PERSIST(6)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: water_creature despawns at 128 blocks" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 128
     COMPUTE TL-OBSERVED-N ROUNDED = MC-DESPAWN(6)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-X
     CALL "M181-CAT-SPAWNING" USING WS-X WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: water_creature takes part in natural spawning" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-X
     CALL "M181-CAT-NAME" USING WS-X WS-NAME
     MOVE "acceptance US15 18§1.2 Mob categories: category 7 is serialized as water_ambient" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "water_ambient" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: water_ambient caps at 20 per chunk unit" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 20
     COMPUTE TL-OBSERVED-N ROUNDED = MC-MAX(7)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: water_ambient friendly 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-FRIENDLY(7)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: water_ambient persistent 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MC-PERSIST(7)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: water_ambient despawns at 64 blocks" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 64
     COMPUTE TL-OBSERVED-N ROUNDED = MC-DESPAWN(7)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-X
     CALL "M181-CAT-SPAWNING" USING WS-X WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: water_ambient takes part in natural spawning" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-X
     CALL "M181-CAT-NAME" USING WS-X WS-NAME
     MOVE "acceptance US15 18§1.2 Mob categories: category 8 is serialized as misc" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "misc" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: misc caps at 1 per chunk unit" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-MAX(8)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: misc friendly 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-FRIENDLY(8)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: misc persistent 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MC-PERSIST(8)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.2 Mob categories: misc despawns at 128 blocks" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 128
     COMPUTE TL-OBSERVED-N ROUNDED = MC-DESPAWN(8)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-X
     CALL "M181-CAT-SPAWNING" USING WS-X WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: misc does not take part in natural spawning" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M181-NO-DESPAWN" USING WS-X
     MOVE "acceptance US15 18§1.2 Mob categories: the no-despawn distance is 32 for every category" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 32
     COMPUTE TL-OBSERVED-N ROUNDED = WS-X
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-X
     CALL "M181-CAT-NAME" USING WS-X WS-NAME
     MOVE "acceptance US15 18§1.2 Mob categories: a category outside 1 to 8 has no name" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE " " TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zombie" TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: zombie belongs to category 1 (the registry column)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = M1-CAT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cow" TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: cow belongs to category 2 (the registry column)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = M1-CAT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bat" TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: bat belongs to category 3 (the registry column)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 3
     COMPUTE TL-OBSERVED-N ROUNDED = M1-CAT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "axolotl" TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: axolotl belongs to category 4 (the registry column)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4
     COMPUTE TL-OBSERVED-N ROUNDED = M1-CAT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "glow_squid" TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: glow_squid belongs to category 5 (the registry column)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 5
     COMPUTE TL-OBSERVED-N ROUNDED = M1-CAT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "squid" TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: squid belongs to category 6 (the registry column)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 6
     COMPUTE TL-OBSERVED-N ROUNDED = M1-CAT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cod" TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: cod belongs to category 7 (the registry column)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 7
     COMPUTE TL-OBSERVED-N ROUNDED = M1-CAT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "item" TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.2 Mob categories: item belongs to category 8 (the registry column)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 8
     COMPUTE TL-OBSERVED-N ROUNDED = M1-CAT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-1-2.
