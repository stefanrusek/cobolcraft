*> Acceptance test (002-lane-p49b; docs/protocol/20 section 19.4): despawning. Peaceful discards the types built notInPeaceful (the document's list; the piglin and
*> the shulker are not on it); otherwise with a player: a non-persistent mob that is removable beyond 128 blocks (squared 16384) is discarded; with the no-action counter
*> above 600, the draw nextInt(800) = 0 and a distance beyond 32 blocks it is discarded; within 32 blocks the counter is reset to 0; a persistent mob is never discarded for
*> distance; the warden is never removed for distance (removeWhenFarAway false).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-19-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CAT                 BINARY-LONG VALUE 1.
 01 WS-PERSIST             BINARY-LONG.
 01 WS-REMOVABLE           BINARY-LONG.
 01 WS-PEACEFUL            BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-IDLE                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-BAD                 BINARY-LONG VALUE 0.
 01 WS-SEEN                BINARY-LONG VALUE 0.
 01 WS-NAMES.
    05 FILLER              PIC X(20) VALUE "blaze".
    05 FILLER              PIC X(20) VALUE "enderman".
    05 FILLER              PIC X(20) VALUE "endermite".
    05 FILLER              PIC X(20) VALUE "evoker".
    05 FILLER              PIC X(20) VALUE "ghast".
    05 FILLER              PIC X(20) VALUE "giant".
    05 FILLER              PIC X(20) VALUE "hoglin".
    05 FILLER              PIC X(20) VALUE "illusioner".
    05 FILLER              PIC X(20) VALUE "magma_cube".
    05 FILLER              PIC X(20) VALUE "phantom".
    05 FILLER              PIC X(20) VALUE "piglin_brute".
    05 FILLER              PIC X(20) VALUE "pillager".
    05 FILLER              PIC X(20) VALUE "ravager".
    05 FILLER              PIC X(20) VALUE "silverfish".
    05 FILLER              PIC X(20) VALUE "slime".
    05 FILLER              PIC X(20) VALUE "vex".
    05 FILLER              PIC X(20) VALUE "vindicator".
    05 FILLER              PIC X(20) VALUE "warden".
    05 FILLER              PIC X(20) VALUE "witch".
    05 FILLER              PIC X(20) VALUE "wither_skeleton".
    05 FILLER              PIC X(20) VALUE "zoglin".
    05 FILLER              PIC X(20) VALUE "zombified_piglin".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(20) OCCURS 22 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
*>   Every listed type that has a standard mob row is a monster row (SM-KIND 1), so Peaceful discards it.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
         IF WS-INDEX > 0
             ADD 1 TO WS-SEEN
             CALL "STDMOB-HOSTILE" USING WS-TYPE WS-RESULT
             IF WS-RESULT NOT = 1
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§19.4 every notInPeaceful type with a row is a monster row" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§19.4 at least ten of the listed types have a row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SEEN >= 10
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Mob.checkDespawn (MS6-DESPAWN: category, persistent, removeWhenFarAway, peaceful discard, player exists, squared distance, counter, draw, result).
     MOVE 0 TO WS-PERSIST
     MOVE 1 TO WS-REMOVABLE
     MOVE 1 TO WS-HAVE
     MOVE 0 TO WS-IDLE
     MOVE 5 TO WS-DRAW
     MOVE 0 TO WS-D2
     MOVE 1 TO WS-PEACEFUL
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 Peaceful discards a type that is not allowed in it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-PEACEFUL
     MOVE 0 TO WS-HAVE
     MOVE 99999999 TO WS-D2
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 no player: nothing is discarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-HAVE
     MOVE 16385 TO WS-D2
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 beyond 128 blocks (squared 16384) a removable mob is discarded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16384 TO WS-D2
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 at exactly 128 blocks it is kept" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-PERSIST
     MOVE 99999999 TO WS-D2
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 a persistent mob is never discarded for distance" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-PERSIST
     MOVE 0 TO WS-REMOVABLE
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 a mob that keeps when far away is not discarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-REMOVABLE
     MOVE 1025 TO WS-D2
     MOVE 601 TO WS-IDLE
     MOVE 0 TO WS-DRAW
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 counter 601, draw 0, beyond 32 blocks: discarded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 600 TO WS-IDLE
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 counter 600 is not above 600: kept" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 601 TO WS-IDLE
     MOVE 1 TO WS-DRAW
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 a draw other than 0: kept" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-DRAW
     MOVE 1024 TO WS-D2
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 at exactly 32 blocks the random despawn does not apply" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1023 TO WS-D2
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 within 32 blocks the counter is reset to 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-IDLE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-PERSIST
     MOVE 601 TO WS-IDLE
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE WS-DRAW WS-RESULT
     MOVE "acceptance US15 20§19.4 the counter of a persistent mob is reset within 32 blocks too" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-IDLE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Live: a warden 200 blocks from the player is kept; a zombie there is discarded; in Peaceful a zombie beside the player is discarded and a piglin kept.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE WS-X = PL-X(WS-PLAYER) + 200
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "MS6-DESPAWN-TICK" USING WS-ROW
     MOVE "acceptance US15 20§19.4 the warden is not removed for distance (removeWhenFarAway false)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "MS6-DESPAWN-TICK" USING WS-ROW
     MOVE "acceptance US15 20§19.4 a zombie 200 blocks from the player is discarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BW-DIFFICULTY
     COMPUTE WS-X = PL-X(WS-PLAYER) + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "MS6-DESPAWN-TICK" USING WS-ROW
     MOVE "acceptance US15 20§19.4 Peaceful discards a zombie beside the player" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "MS6-DESPAWN-TICK" USING WS-ROW
     MOVE "acceptance US15 20§19.4 Peaceful keeps a piglin (not built notInPeaceful)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-19-4.
 COPY CORETEST.
 COPY MOBSPTEST.
