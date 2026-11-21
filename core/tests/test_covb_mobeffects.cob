*> Implementation test (lane covB; docs/protocol/17 section 4.9a): mob effects: an effect kept when the new one is weaker in duration or the old one is infinite, undead mobs, the instant
*> effect entry ignoring other effects, the periodic wither effect of an infinite duration and a mob killed by its own wither effect during the effect tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-MOBEFFECTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-ZOMBIE-T            BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SLOWNESS            BINARY-LONG VALUE 1.
 01 WS-WITHER              BINARY-LONG VALUE 19.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-UNDEAD              BINARY-LONG.
 01 WS-T                   BINARY-LONG VALUE 1000.
 01 WS-HEALTH0             BINARY-LONG.
01 WS-X1                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-BOBBER-KIND         BINARY-LONG VALUE 7.
 01 WS-BOBBER-KEY          PIC X(112) VALUE "minecraft:fishing_bobber".
 01 WS-ZA                  FLOAT-LONG VALUE 0.
 01 WS-ZB                  FLOAT-LONG VALUE 0.
 01 WS-ZC                  FLOAT-LONG VALUE 0.
 01 WS-INFINITE            BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-T WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 5
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-X WS-Y WS-Z WS-YAW WS-COW
     COMPUTE WS-X = PL-X(WS-PLAYER) + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-T WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE
*>   An infinite effect is not replaced by a timed one of the same strength.
     MOVE -1 TO WS-DUR
     CALL "MEF-ADD" USING EN-ID(WS-COW) WS-SLOWNESS WS-AMP WS-DUR WS-FLAGS
     MOVE 100 TO WS-DUR
     CALL "MEF-ADD" USING EN-ID(WS-COW) WS-SLOWNESS WS-AMP WS-DUR WS-FLAGS
     CALL "MEF-LEVEL" USING EN-ID(WS-COW) WS-SLOWNESS WS-LEVEL WS-LEFT
     MOVE "covB 17 4.9 a timed effect does not replace an infinite one of the same level" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A shorter timed effect does not replace a longer one of the same strength.
     CALL "MEF-REMOVE" USING EN-ID(WS-COW) WS-SLOWNESS
     MOVE 100 TO WS-DUR
     CALL "MEF-ADD" USING EN-ID(WS-COW) WS-SLOWNESS WS-AMP WS-DUR WS-FLAGS
     MOVE 50 TO WS-DUR
     CALL "MEF-ADD" USING EN-ID(WS-COW) WS-SLOWNESS WS-AMP WS-DUR WS-FLAGS
     CALL "MEF-LEVEL" USING EN-ID(WS-COW) WS-SLOWNESS WS-LEVEL WS-LEFT
     MOVE "covB 17 4.9 a shorter effect does not replace a longer one of the same level" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Undead species.
     CALL "MEF-UNDEAD" USING WS-ZOMBIE WS-UNDEAD
     MOVE "covB 17 4.9a a zombie is undead (instant health harms it)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-UNDEAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The instant entry point leaves effects that are not instant health or harm alone.
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     CALL "MEF-INSTANT-T" USING WS-COW WS-SLOWNESS WS-AMP WS-T
     MOVE "covB 17 4.9a the instant entry ignores slowness" TO TL-CASE
     MOVE WS-HEALTH0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Wither of infinite duration: the periodic hit is timed by the game tick (here the first beat of the 40 tick period).
     MOVE 40 TO CW-TICKS
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     CALL "MEF-PERIODIC" USING WS-COW WS-WITHER WS-AMP WS-INFINITE
     MOVE "covB 17 4.9a an infinite wither hurts on the beat of the game tick" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-HEALTH0 - 1
     MOVE EN-HEALTH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An entity that is no species of the mob tables with 1 health and a wither effect dies at once of the first beat; the effect tick copes with its effects being cleared.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 3
     CALL "THROWN-SPAWN" USING WS-BOBBER-KIND WS-BOBBER-KEY WS-DIM WS-X WS-Y WS-Z WS-ZA WS-ZB WS-ZC WS-NONE WS-ROW
     MOVE 1 TO EN-HEALTH(WS-ROW)
     MOVE 40 TO WS-DUR
     CALL "MEF-ADD" USING EN-ID(WS-ROW) WS-WITHER WS-AMP WS-DUR WS-FLAGS
     CALL "MEF-TICK" USING WS-ROW
     MOVE "covB 17 4.9a an entity killed by its own wither effect is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-MOBEFFECTS.
 COPY CORETEST.
 COPY MOBSPTEST.
