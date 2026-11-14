*> Acceptance test (US15; docs/protocol/19-mobs-land-friendly-and-neutral.md sections 1.4, 1.5, 11, 12, 14 to 17): the species rows of core/copy/MOB19ROWS2.cpy (parrot, turtle, bee,
*> frog, tadpole, sniffer, allay): found by the natural spawning table, their health and panic speed, and the floors the parrot, turtle and frog spawn on.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-ROWS2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY STDMOBS.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-FX                 BINARY-LONG.
 01 WS-FZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-Y                  BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 8.
 01 WS-KIND               BINARY-LONG VALUE 2.
 01 WS-X                  BINARY-LONG.
 01 WS-Z                  BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-BLOCK-KEY          PIC X(112).
 01 WS-KEY48              PIC X(48).
 01 WS-ROW                BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-REASON             BINARY-LONG VALUE 0.
 01 WS-I                  BINARY-LONG.
 01 WS-TYPE               BINARY-LONG.
 01 WS-EKEY               PIC X(112).
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-VALUE              BINARY-LONG.
 01 WS-NAME               PIC X(16).
 01 WS-LENGTH             BINARY-LONG.
 01 WS-SPECIES.
    05 FILLER PIC X(33) VALUE "parrot                  057006138".
    05 FILLER PIC X(33) VALUE "turtle                  058030198".
    05 FILLER PIC X(33) VALUE "bee                     059010000".
    05 FILLER PIC X(33) VALUE "frog                    060010999".
    05 FILLER PIC X(33) VALUE "tadpole                 061006999".
    05 FILLER PIC X(33) VALUE "sniffer                 062014088".
    05 FILLER PIC X(33) VALUE "allay                   063020138".
 01 WS-SPECIES-TABLE REDEFINES WS-SPECIES.
    05 WS-SP                 OCCURS 7 TIMES.
       10 WS-SP-KEY          PIC X(24).
       10 WS-SP-ROW          PIC 999.
       10 WS-SP-HEALTH       PIC 999.
       10 WS-SP-PANIC        PIC 999.
 01 WS-FLOORS.
    05 FILLER PIC X(23) VALUE "grass_block parrot    1".
    05 FILLER PIC X(23) VALUE "stone       parrot    0".
    05 FILLER PIC X(23) VALUE "oak_leaves  parrot    1".
    05 FILLER PIC X(23) VALUE "jungle_log  parrot    1".
    05 FILLER PIC X(23) VALUE "sand        turtle    1".
    05 FILLER PIC X(23) VALUE "grass_block turtle    0".
    05 FILLER PIC X(23) VALUE "mud         frog      1".
    05 FILLER PIC X(23) VALUE "grass_block frog      1".
    05 FILLER PIC X(23) VALUE "sand        frog      0".
 01 WS-FLOOR-TABLE REDEFINES WS-FLOORS.
    05 WS-FL                 OCCURS 9 TIMES.
       10 WS-FL-BLOCK        PIC X(12).
       10 WS-FL-SPECIES      PIC X(10).
       10 WS-FL-OK           PIC 9.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 6000 TO CW-TIME
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-X = WS-FX + 2
     COMPUTE WS-Z = WS-FZ + 2
     COMPUTE WS-Y = WS-FY + 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE SPACES TO WS-KEY48
         MOVE WS-SP-KEY(WS-I) TO WS-KEY48
         CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
         MOVE "acceptance US15 19§1.5 Species rows: the row number of the land species in the standard mob table" TO WS-CASE
         MOVE WS-SP-ROW(WS-I) TO WS-E
         MOVE WS-ROW TO WS-O
         PERFORM CHECK-N
         MOVE SPACES TO WS-EKEY
         STRING "minecraft:" DELIMITED BY SIZE WS-SP-KEY(WS-I) DELIMITED BY SPACE INTO WS-EKEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "STDMOB-HEALTH" USING WS-TYPE WS-VALUE
         MOVE "acceptance US15 19§3 Species rows: max health of the type (random-gene species use the mean)" TO WS-CASE
         MOVE WS-SP-HEALTH(WS-I) TO WS-E
         MOVE WS-VALUE TO WS-O
         PERFORM CHECK-N
         CALL "STDMOB-PANIC" USING WS-TYPE WS-VALUE
         MOVE "acceptance US15 19§3 Species rows: panic speed in thousandths of a block per tick, (speed x modifier) squared / 0.454" TO WS-CASE
         MOVE WS-SP-PANIC(WS-I) TO WS-E
         MOVE WS-VALUE TO WS-O
         PERFORM CHECK-N
         CALL "STDMOB-NAME" USING WS-TYPE WS-NAME WS-LENGTH
         MOVE "acceptance US15 19§1.1 Species rows: the display name starts with a capital" TO WS-CASE
         MOVE 1 TO WS-E
         IF WS-NAME(1:1) >= "A" AND WS-NAME(1:1) <= "Z" AND WS-LENGTH > 0
             MOVE 1 TO WS-O
         ELSE
             MOVE 0 TO WS-O
         END-IF
         PERFORM CHECK-N
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE SPACES TO WS-BLOCK-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-FL-BLOCK(WS-I) DELIMITED BY SPACE INTO WS-BLOCK-KEY
         CALL "MS-TEST-STATE" USING WS-BLOCK-KEY WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FY WS-Z WS-STATE
         MOVE SPACES TO WS-KEY48
         MOVE WS-FL-SPECIES(WS-I) TO WS-KEY48
         CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
         CALL "MS6-VALID-SPOT" USING XR-STATE WS-DIM WS-ROW WS-X WS-Y WS-Z WS-REASON WS-OK
         MOVE "acceptance US15 19§1.4 Spawn floors: the species spawns only on the blocks of its rule" TO WS-CASE
         MOVE WS-FL-OK(WS-I) TO WS-E
         MOVE WS-OK TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-ROWS2.
 COPY CORETEST.
 COPY MOBSPTEST.
