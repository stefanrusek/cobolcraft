*> Implementation test (002-lane-mobsfull-h11; docs/protocol/20 section 7.2 Cave spider): row 15 (health 12, attack 2, follow 16, experience 5); it inherits the spider's
*> leap and Hard spawn effect; a successful hit gives Poison for 7 s on Normal, 15 s on Hard, none on Easy (the hit itself is covered in test_mob_20_rows); the
*> drops are the loot table minecraft:entities/cave_spider (string, spider eye when killed by a player); natural spawns are the sulfur_caves entries of
*> the biome lists (19.1; the mineshaft spawner blocks are structure content, open).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-7-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROLL                BINARY-LONG VALUE 0.
 01 WS-LEAPT               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 7.
 01 WS-SPECIAL             BINARY-LONG VALUE 1000.
 01 WS-I                   BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X0 = WS-X - 3
     MOVE "minecraft:cave_spider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE "acceptance US15 20§7.2 Cave spider: row 15, health 12, attack 2, follow 16, xp 5" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 15 * 1000000 + 12 * 10000 + 2 * 1000 + 16 * 10 + 5
     COMPUTE TL-OBSERVED-N = WS-M * 1000000 + SM-HEALTH(WS-M) * 10000 + SM-ATTACK(WS-M) * 1000
         + SM-FOLLOW(WS-M) * 10 + SM-XP(WS-M)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§7.2 Cave spider: hit effect Poison (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SM-HITFX(WS-M) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
     MOVE 1 TO EN-ON-GROUND(WS-MOB)
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.2 Cave spider: inherits the spider's leap" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEAPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO BW-DIFFICULTY
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 0 TO EN-FX-SPEED(WS-MOB) EN-FX-STRENGTH(WS-MOB) EN-FX-REGEN(WS-MOB) EN-FX-INVIS(WS-MOB)
         CALL "STDMOB-SPIDER-FX" USING XR-STATE WS-MOB WS-SPECIAL
         IF EN-FX-SPEED(WS-MOB) NOT = 0 OR EN-FX-STRENGTH(WS-MOB) NOT = 0 OR EN-FX-REGEN(WS-MOB) NOT = 0
                 OR EN-FX-INVIS(WS-MOB) NOT = 0
             ADD 1 TO WS-ANY
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§7.2 Cave spider: inherits the Hard spawn effect" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ANY > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-MOB
     CALL "ENTITY-REMOVE" USING WS-MOB
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE 1 TO EN-ON-GROUND(WS-MOB)
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.2 a zombie never leaps" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEAPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     STOP RUN.
 END PROGRAM TEST-MOB-20-7-2.
 COPY CORETEST.
 COPY MOBSPTEST.
