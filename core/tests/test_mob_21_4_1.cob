*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 sections 4.1, 4.2 and 3.3 with doc 44 part 7 sections 2.6, 4.1 and 6.1): the water animals. Rows of
*> cod, salmon, pufferfish, tropical_fish (water ambient, category 7), squid, dolphin (water creature, 6) and glow_squid (underground, 5) in STDMOBS.cpy
*> (MOB21ROWS.cpy); fish have 3 health, the rest 10; a fish swims inside its water (RandomSwimmingGoal, FishMoveControl), flops on land (every tick it
*> is on the ground), takes 2 drown damage when its air (300) has run to -20, refills in water, and drops its loot table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-TYPE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-BIG                 FLOAT-LONG.
 01 WS-LASTX               FLOAT-LONG.
 01 WS-LASTZ               FLOAT-LONG.
 01 WS-MAXVY               FLOAT-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/aquatic-loot".
 01 WS-AMOUNT              BINARY-LONG VALUE 10.
 01 WS-CAUSE               BINARY-LONG VALUE 6.
 01 WS-COD                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(14) VALUE "cod".
    05 FILLER              PIC X(14) VALUE "salmon".
    05 FILLER              PIC X(14) VALUE "pufferfish".
    05 FILLER              PIC X(14) VALUE "tropical_fish".
    05 FILLER              PIC X(14) VALUE "squid".
    05 FILLER              PIC X(14) VALUE "dolphin".
    05 FILLER              PIC X(14) VALUE "glow_squid".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(14) OCCURS 7 TIMES.
 01 WS-HEALTHS.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 10.
 01 WS-HEALTH-TABLE REDEFINES WS-HEALTHS.
    05 WS-HEALTH           BINARY-LONG OCCURS 7 TIMES.
 01 WS-CATS.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 5.
 01 WS-CAT-TABLE REDEFINES WS-CATS.
    05 WS-CATEGORY         BINARY-LONG OCCURS 7 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE
             " has a species row" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-INDEX > 0
             IF SM-KEY(WS-INDEX) = WS-NAME(WS-I)
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 21§4.2 minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE
             " max health" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-HEALTH(WS-I) TO TL-EXPECTED-N
         CALL "STDMOB-HEALTH" USING WS-TYPE TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 21§3.3 minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE
             " spawn category" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-CATEGORY(WS-I) TO TL-EXPECTED-N
         CALL "MS6-ROW-CAT" USING WS-INDEX WS-CAT
         MOVE WS-CAT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "acceptance US15 21§3.3 land rows keep their categories (cow creature 2, zombie monster 1)" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     MOVE 1 TO WS-INDEX
     CALL "MS6-ROW-CAT" USING WS-INDEX WS-CAT
     COMPUTE TL-OBSERVED-N = WS-CAT * 10
     MOVE 6 TO WS-INDEX
     CALL "MS6-ROW-CAT" USING WS-INDEX WS-CAT
     ADD WS-CAT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A tank of 8 x 8 x 6 water cells inside a stone shell, far above the terrain, and a dry stone floor beside it.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 20
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     PERFORM VARYING WS-BX FROM WS-X0 BY 1 UNTIL WS-BX > WS-X0 + 9
         PERFORM VARYING WS-BZ FROM WS-Z0 BY 1 UNTIL WS-BZ > WS-Z0 + 9
             PERFORM VARYING WS-BY FROM WS-Y0 BY 1 UNTIL WS-BY > WS-Y0 + 7
                 MOVE WS-WATER TO WS-J
                 IF WS-BX = WS-X0 OR WS-BX = WS-X0 + 9 OR WS-BZ = WS-Z0 OR WS-BZ = WS-Z0 + 9
                         OR WS-BY = WS-Y0 OR WS-BY = WS-Y0 + 7
                     MOVE WS-STONE TO WS-J
                 END-IF
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-J
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-BX = WS-X0 + 12
     COMPUTE WS-BZ = WS-Z0 + 2
     MOVE WS-Y0 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-BY = WS-Y0 + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     END-PERFORM

     MOVE SPACES TO WS-KEY
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COD WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 5
     COMPUTE WS-Y = WS-Y0 + 4
     COMPUTE WS-Z = WS-Z0 + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-X TO WS-MINX WS-MAXX WS-LASTX
     MOVE WS-Y TO WS-MINY WS-MAXY
     MOVE WS-Z TO WS-MINZ WS-MAXZ WS-LASTZ
     MOVE 0 TO WS-BIG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE WS-MINX = FUNCTION MIN(WS-MINX, EN-X(WS-ROW))
         COMPUTE WS-MAXX = FUNCTION MAX(WS-MAXX, EN-X(WS-ROW))
         COMPUTE WS-MINY = FUNCTION MIN(WS-MINY, EN-Y(WS-ROW))
         COMPUTE WS-MAXY = FUNCTION MAX(WS-MAXY, EN-Y(WS-ROW))
         COMPUTE WS-MINZ = FUNCTION MIN(WS-MINZ, EN-Z(WS-ROW))
         COMPUTE WS-MAXZ = FUNCTION MAX(WS-MAXZ, EN-Z(WS-ROW))
         COMPUTE WS-STEP = FUNCTION ABS(EN-X(WS-ROW) - WS-LASTX) + FUNCTION ABS(EN-Z(WS-ROW) - WS-LASTZ)
         COMPUTE WS-BIG = FUNCTION MAX(WS-BIG, WS-STEP)
         MOVE EN-X(WS-ROW) TO WS-LASTX
         MOVE EN-Z(WS-ROW) TO WS-LASTZ
     END-PERFORM
     MOVE "acceptance US15 21§4.1 minecraft:cod swims about in its water for 400 ticks (RandomSwimmingGoal): it moved 1 block or more" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF (WS-MAXX - WS-MINX) + (WS-MAXZ - WS-MINZ) + (WS-MAXY - WS-MINY) >= 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§4.1 minecraft:cod never leaves the tank of water (stone walls and ceiling)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MINX > WS-X0 + 1 AND WS-MAXX < WS-X0 + 9 AND WS-MINZ > WS-Z0 + 1 AND WS-MAXZ < WS-Z0 + 9
             AND WS-MINY >= WS-Y0 + 1 AND WS-MAXY < WS-Y0 + 7
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§4.1 minecraft:cod swims slower than 0.2 blocks a tick (about 0.07)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BIG > 0 AND WS-BIG < 0.2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A fish hit by a player panics (PanicGoal): it swims away from the attacker faster.
     MOVE 5 TO EN-FLEE(WS-ROW)
     MOVE WS-PLAYER TO EN-FLEE-PLAYER(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FLEE-ID(WS-ROW)
     COMPUTE EN-FLEE-X(WS-ROW) = EN-X(WS-ROW) - 3
     MOVE EN-Z(WS-ROW) TO EN-FLEE-Z(WS-ROW)
     MOVE EN-X(WS-ROW) TO WS-LASTX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§4.1 a hit fish panics: it swims away from the attacker (east here)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-ROW) > WS-LASTX
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   On land: it falls, lands, and flops (velocity up 0.4) on a tick it stands on the ground.
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-Y0 + 3
     COMPUTE WS-Z = WS-Z0 + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO WS-MAXVY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE WS-MAXVY = FUNCTION MAX(WS-MAXVY, EN-VY(WS-ROW))
     END-PERFORM
     MOVE "acceptance US15 44-7§4.1 a fish out of water flops: velocity + 0.4 up on a tick on the ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAXVY > 0.25
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Air: 300 + 20 ticks without water, then 2 damage and the air back to 0 (44-7 2.6).
     MOVE 3 TO EN-HEALTH(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 319 TO EN-DRY(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-7§2.6 a fish whose air has run to -20 takes 2 drown damage (3 to 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-7§2.6 the air is then reset to 0 (300 ticks used), so damage comes every 20 ticks" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 319 TO EN-DRY(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.1 a second drowning kills the fish (health 0, the row stays as a dying mob)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-INDEX WS-ITEM-ROW WS-STATUS
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ITEM(WS-I) = WS-INDEX
             ADD EN-ITEM-COUNT(WS-I) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§4.2 a dead cod drops a cod from minecraft:entities/cod" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   In water the air is refilled.
     COMPUTE WS-X = WS-X0 + 5
     COMPUTE WS-Y = WS-Y0 + 4
     COMPUTE WS-Z = WS-Z0 + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 100 TO EN-DRY(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.1 in water the air is back to the maximum" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   AQUA-MOVE: a velocity into a wall (z) or the ceiling (up) is lost, the position stays.
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-X = WS-X0 + 5.5
     COMPUTE WS-Y = WS-Y0 + 6.5
     COMPUTE WS-Z = WS-Z0 + 8.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0.5 TO EN-VZ(WS-ROW)
     MOVE 0.5 TO EN-VY(WS-ROW)
     CALL "AQUA-MOVE" USING WS-ROW WS-YAW
     MOVE "acceptance US15 21§4.1 a fish pushed into the wall and the ceiling keeps its place and loses that velocity" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-Z(WS-ROW) = WS-Z AND EN-Y(WS-ROW) = WS-Y AND EN-VZ(WS-ROW) = 0 AND EN-VY(WS-ROW) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-21-4-1.
 COPY CORETEST.
 COPY MOBSPTEST.
