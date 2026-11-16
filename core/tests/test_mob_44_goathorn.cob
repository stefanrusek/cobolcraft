*> Implementation test (002-lane-mobsa5; 54 sections 7.2 and 7.4, 44 part 4 section 9): a charging goat whose way ahead is a block of the tag snaps_goat_horn loses a horn (a goat_horn item drops,
*> EN-WOOL bit 2 left, 4 right), the ram ends with the cooldown; a baby or a goat without a horn only ends its ram; a hit on a player throws the player along the charge (Set Entity Motion 0x67).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-GOATHORN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-GOAT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-TREG                PIC X(48) VALUE "block".
 01 WS-TTAG                PIC X(112) VALUE "minecraft:snaps_goat_horn".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 1 TIMES.
 01 WS-TEXT                PIC X(1024).
 01 WS-HAYSTACK            PIC X(1026).
 01 WS-A                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     MOVE "N" TO TL-MODE
     MOVE 2 TO BW-DIFFICULTY
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE WS-BLOCK TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-TREG WS-TTAG WS-ONE WS-MEMBERS WS-STATUS
     MOVE "minecraft:goat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-Y = WS-FLOOR + 1
     COMPUTE WS-X = WS-X0 + 20.5
     COMPUTE WS-Z = WS-Z0 + 24.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-GOAT
     MOVE "minecraft:goat_horn" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
*>   A stone block one cell ahead of the charge (+x).
     COMPUTE WS-SX = WS-X0 + 21
     COMPUTE WS-SY = WS-FLOOR + 1
     COMPUTE WS-SZ = WS-Z0 + 24
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STATE
*>   The player stands far (no hit).
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 5.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE 0 TO EN-WOOL(WS-GOAT) EN-VARIANT(WS-GOAT)
     MOVE 2 TO EN-RAM-STATE(WS-GOAT)
     MOVE 1 TO EN-RAM-DX(WS-GOAT)
     MOVE 0 TO EN-RAM-DZ(WS-GOAT)
     COMPUTE EN-RAM-PX(WS-GOAT) = WS-X0 + 40
     MOVE EN-Z(WS-GOAT) TO EN-RAM-PZ(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ITEM(WS-I) = WS-ITEM AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 54§7.2 Goat horn: the block ahead in snaps_goat_horn drops a goat horn" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 54§7.2 Goat horn: the left horn is gone (bit 2) and the ram has ended with a cooldown of 600 or more" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-WOOL(WS-GOAT) = 2 AND EN-RAM-STATE(WS-GOAT) = 0 AND EN-RAM-CD(WS-GOAT) >= 600
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The second break takes the right horn; a third has none to give.
     MOVE 2 TO EN-RAM-STATE(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 54§7.2 Goat horn: the second break takes the right horn (EN-WOOL 6)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE EN-WOOL(WS-GOAT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO EN-RAM-STATE(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 54§7.2 Goat horn: without a horn the ram still ends and nothing more is dropped" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-WOOL(WS-GOAT) + EN-RAM-STATE(WS-GOAT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ITEM(WS-I) = WS-ITEM AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 54§7.2 Goat horn: two horns dropped in all" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby has no horn to drop.
     MOVE 0 TO EN-WOOL(WS-GOAT)
     MOVE 1 TO EN-VARIANT(WS-GOAT)
     MOVE 2 TO EN-RAM-STATE(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 54§7.2 Goat horn: a baby keeps its horns, the ram ends" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-WOOL(WS-GOAT) + EN-RAM-STATE(WS-GOAT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hit on a player: the charge ends and the player gets Set Entity Motion.
     MOVE 0 TO EN-VARIANT(WS-GOAT)
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-GOAT) + 0.3
     MOVE EN-Z(WS-GOAT) TO PL-Z(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 2 TO EN-RAM-STATE(WS-GOAT)
     MOVE 1 TO PL-ON-GROUND(WS-PLAYER)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-HAYSTACK
     STRING " " DELIMITED BY SIZE WS-TEXT DELIMITED BY SIZE INTO WS-HAYSTACK
     MOVE 0 TO WS-A
     INSPECT WS-HAYSTACK TALLYING WS-A FOR ALL " 103"
     MOVE "acceptance US15 54§7.2 Goat ram: the hit throws the player (Set Entity Motion)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-GOATHORN.
 COPY CORETEST.
 COPY MOBSPTEST.
