*> Acceptance test (002-lane-p49b fork u; docs/protocol/20 section 12): the phantom's end of swoop and box. A swoop ends (phase CIRCLE) when the phantom was hurt recently; when a cat is
*> within 16 blocks (the sweep goal scans every 20 ticks, a cat stops it: the target is cleared); touching the target hurts it and sends level event 1039; the hit box is the phantom's
*> box (0.9 x 0.5 scaled by 1 + 0.15 x size) inflated by 0.2; when the attack strategy stops, the anchor becomes the MOTION_BLOCKING height at the anchor's x and z plus 10 + nextInt(20).
*> Not here: the flying friction 0.2 (the document does not say how `travel` applies it), the phantom_swoop sound (volume 10), the horizontal-collision end of a swoop.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-12-MORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-CAT-TYPE            BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 24.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-HAS                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:phantom" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CAT-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 12
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE 18000 TO CW-TIME

*>   Box scaling: a target 1.1 blocks away on x is missed by a size 0 phantom (reach 0.45 + 0.2 + 0.3 = 0.95) and hit by a size 4 one (0.72 + 0.2 + 0.3 = 1.22).
     COMPUTE WS-X0 = WS-X - 1.1
     PERFORM VARYING WS-I FROM 0 BY 4 UNTIL WS-I > 4
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
         PERFORM SET-SWOOP
         MOVE WS-I TO EN-VARIANT(WS-MOB)
         MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         CALL "MOB-STEP" USING WS-MOB
         IF WS-I = 0
             MOVE "acceptance US15 20§12 Phantom size 0: a target 1.1 blocks away is out of reach" TO TL-CASE
             MOVE 0 TO TL-EXPECTED-N
         ELSE
             MOVE "acceptance US15 20§12 Phantom size 4: its box is 1.6 times larger, the target is hit" TO TL-CASE
             MOVE 1 TO TL-EXPECTED-N
         END-IF
         MOVE 0 TO TL-OBSERVED-N
         IF PL-HEALTH(WS-PLAYER) < WS-HEALTH
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "ENTITY-REMOVE" USING WS-MOB
     END-PERFORM

*>   A hit sends level event 1039 (packet 47) and ends the swoop.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     PERFORM SET-SWOOP
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "MOB-STEP" USING WS-MOB
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     MOVE SPACES TO WS-PADDED
     STRING " " DELIMITED BY SIZE FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-HAS
     INSPECT WS-PADDED TALLYING WS-HAS FOR ALL " 47 "
     MOVE "acceptance US15 20§12 Phantom hit sends level event 1039 (packet 47)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HAS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§12 Phantom hit ends the swoop (CIRCLE)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PH-PHASE(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   A swoop ends when the phantom was hurt recently (far from the target).
     COMPUTE WS-X0 = WS-X + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     PERFORM SET-SWOOP
     MOVE 5 TO EN-HURT(WS-MOB)
     CALL "MOB-STEP" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom hurt recently ends its swoop" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PH-PHASE(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   Without being hurt it keeps swooping.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     PERFORM SET-SWOOP
     CALL "MOB-STEP" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom not hurt keeps swooping" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-PH-PHASE(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   A cat within 16 blocks stops the swoop: the target is cleared (the scan runs once the tick count passes catSearchTick).
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     COMPUTE WS-X0 = WS-X + 12
     CALL "MOB-SPAWN" USING WS-DIM WS-CAT-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-CAT
     PERFORM SET-SWOOP
     MOVE 0 TO EN-WAKE(WS-MOB)
     ADD 100 TO CW-TICKS
     CALL "MOB-STEP" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom with a cat near loses its target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§12 Phantom with a cat near is in CIRCLE" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PH-PHASE(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-CAT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   The anchor on stop: the column top plus 10 + nextInt(20).
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE 1 TO EN-PH-SET(WS-MOB)
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     MOVE WS-BX TO EN-PH-AX(WS-MOB)
     MOVE 200 TO EN-PH-AY(WS-MOB)
     MOVE WS-BZ TO EN-PH-AZ(WS-MOB)
     CALL "WORLDSIM-COLUMN-TOP" USING WS-DIM WS-BX WS-BZ WS-TOP
     CALL "STDMOB-PHANTOM-STOP" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom stop: the anchor is 10 to 29 above the column top" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-PH-AY(WS-MOB) >= WS-TOP + 10 AND EN-PH-AY(WS-MOB) <= WS-TOP + 29
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-PH-SET(WS-MOB)
     MOVE 200 TO EN-PH-AY(WS-MOB)
     CALL "STDMOB-PHANTOM-STOP" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom stop: an unset anchor is left alone" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE EN-PH-AY(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     STOP RUN.
 SET-SWOOP.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
     MOVE 1 TO EN-PH-PHASE(WS-MOB)
     MOVE 200 TO EN-PH-TIMER(WS-MOB)
     MOVE 8 TO EN-PH-DIST(WS-MOB)
     MOVE 1 TO EN-PH-SET(WS-MOB)
     MOVE 1 TO EN-PH-CW(WS-MOB)
     COMPUTE EN-PH-AX(WS-MOB) = WS-X
     COMPUTE EN-PH-AY(WS-MOB) = WS-Y + 20
     COMPUTE EN-PH-AZ(WS-MOB) = WS-Z.
 END PROGRAM TEST-MOB-20-12-MORE.
 COPY CORETEST.
 COPY MOBSPTEST.
