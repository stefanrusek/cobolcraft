*> Acceptance test (T1763, US12-3; docs/protocol/39-portals.md sections 3, 4, 5, 6, 8): a creative player lights an overworld portal with flint
*> and steel, steps into it and arrives in a portal made for her in the nether at the scaled position, with Respawn first and the portal
*> sound last; going back through that portal she arrives where she started (the existing portal is found, none is made); an axis Z
*> entry into the existing axis X nether portal turns her by 90 degrees; with allow_entering_nether_using_portals false she stays; after a save
*> and a reopen the portal blocks of the loaded chunks are points of interest again. Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-PORTALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PORTAL.
 COPY CBLOCKS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 2.
 01 WS-H                   BINARY-LONG VALUE 3.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-TWELVE              BINARY-LONG VALUE 12.
 01 WS-RULE-NAME           PIC X(40) VALUE "allow_entering_nether_using_portals".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-CREATED             BINARY-LONG.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-F1                  PIC -(5)9.9.
 01 WS-F2                  PIC -(5)9.9.
 01 WS-F3                  PIC -(5)9.9.
 01 WS-F4                  PIC -(5)9.9.
 01 WS-TEXT                PIC X(4096).
 01 WS-HITS                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-3 portals: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)

*>   An X frame in the overworld at bl (10, 100, 10): interior x 9..10, y 100..102, z 10, lit by flint and steel on the bottom obsidian.
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     MOVE 10 TO WS-X MOVE 100 TO WS-Y MOVE 10 TO WS-Z
     MOVE 0 TO WS-AXIS
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE "flint_and_steel" TO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE WS-ID TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 4 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 9 TO WS-X MOVE 99 TO WS-Y
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 10 TO WS-X MOVE 100 TO WS-Y
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-A
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "acceptance US12 39§3 The nether portal frame: flint and steel used on the bottom obsidian of a frame in the overworld lights "
         & "its six interior cells" TO TL-CASE
     MOVE "6" TO TL-EXPECTED
     PERFORM CHECK

*>   She steps into it (feet (10.0, 100, 10.5)) and the world ticks twice (creative: process, then transfer).
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE 10.0 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     MOVE 0 TO PL-YAW(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "84 10 34 65 107"
     MOVE PL-DIM(WS-ROW) TO WS-A
     MOVE WS-HITS TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING "dim " FUNCTION TRIM(WS-A) " Respawn, abilities, held slot in a row " FUNCTION TRIM(WS-B)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§8 A player changes dimension: after two ticks she is in the nether (row 4) and her packets hold "
         & "Respawn (84), Change Difficulty (10), permission Entity Event (34), abilities (65), held slot (107) in that order" TO TL-CASE
     MOVE "dim 4 Respawn, abilities, held slot in a row 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 39§8 A player changes dimension: the Level Event 1032 (id 47) is the last packet, after Player Position (73) and the Set Experience (105) and Set Health (106) refresh" TO TL-CASE
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "73 105 106 47"
     MOVE WS-HITS TO WS-A
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 39§4 Nether portal travel: she arrives at the scaled position (10.0 / 8, 10.5 / 8) in a portal made for her: "
         & "feet (2.0, 41.0, 1.5), six portal blocks at (1, 41, 1), the same game mode" TO TL-CASE
     COMPUTE WS-F1 ROUNDED = PL-X(WS-ROW)
     COMPUTE WS-F2 ROUNDED = PL-Y(WS-ROW)
     COMPUTE WS-F3 ROUNDED = PL-Z(WS-ROW)
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 2 TO WS-X MOVE 41 TO WS-Y MOVE 1 TO WS-Z
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-A
     MOVE PL-MODE(WS-ROW) TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " " FUNCTION TRIM(WS-F3) " portal " FUNCTION TRIM(WS-A)
         " mode " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2.0 41.0 1.5 portal 6 mode 1" TO TL-EXPECTED
     PERFORM CHECK

*>   Back: she leaves, the cooldown runs out, she walks in again at (2.0, 41, 1.5) and arrives at (10.0, 100, 10.5): the portal is found.
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     MOVE 6.5 TO PL-X(WS-ROW)
     MOVE 41.0 TO PL-Y(WS-ROW)
     MOVE 6.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWELVE
     MOVE 2.0 TO PL-X(WS-ROW)
     MOVE 41.0 TO PL-Y(WS-ROW)
     MOVE 1.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     COMPUTE WS-F1 ROUNDED = PL-X(WS-ROW)
     COMPUTE WS-F2 ROUNDED = PL-Y(WS-ROW)
     COMPUTE WS-F3 ROUNDED = PL-Z(WS-ROW)
     MOVE PL-DIM(WS-ROW) TO WS-A
     MOVE PQ-POI-COUNT TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING "dim " FUNCTION TRIM(WS-A) " at " FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " " FUNCTION TRIM(WS-F3)
         " points of interest " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§5 PortalForcer: the way back finds the overworld portal and none is made: dim 3 at (10.0, 100.0, 10.5), "
         & "12 points of interest (six portal blocks in each dimension)" TO TL-CASE
     MOVE "dim 3 at 10.0 100.0 10.5 points of interest 12" TO TL-EXPECTED
     PERFORM CHECK

*>   Axis Z entry: a Z frame at bl (8, 100, 8) (interior z 8..9 at x 8) leads to the existing X portal in the nether; yaw gains 90.
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     MOVE 8 TO WS-X MOVE 100 TO WS-Y MOVE 8 TO WS-Z
     MOVE 1 TO WS-AXIS
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 8 TO WS-X MOVE 99 TO WS-Y MOVE 8 TO WS-Z
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     MOVE 40.5 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 40.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWELVE
     MOVE 8.5 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 9.0 TO PL-Z(WS-ROW)
     MOVE 0 TO PL-YAW(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     MOVE PL-DIM(WS-ROW) TO WS-A
     COMPUTE WS-F1 = PL-YAW(WS-ROW)
     MOVE PQ-POI-COUNT TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING "dim " FUNCTION TRIM(WS-A) " yaw " FUNCTION TRIM(WS-F1) " points of interest " FUNCTION TRIM(WS-B)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§6 The teleport transition model: an axis Z portal leading to an axis X one adds 90 degrees to the yaw "
         & "(4.4); the nether portal is reused (18 points of interest)" TO TL-CASE
     MOVE "dim 4 yaw 90.0 points of interest 18" TO TL-EXPECTED
     PERFORM CHECK

*>   The rule allow_entering_nether_using_portals false: entering the nether does nothing (the cooldown is still set), leaving it works.
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     MOVE 6.5 TO PL-X(WS-ROW)
     MOVE 41.0 TO PL-Y(WS-ROW)
     MOVE 6.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWELVE
     MOVE 2.0 TO PL-X(WS-ROW)
     MOVE 41.0 TO PL-Y(WS-ROW)
     MOVE 1.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     MOVE PL-DIM(WS-ROW) TO WS-A
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     MOVE 6.5 TO PL-X(WS-ROW)
     MOVE 6.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWELVE
     MOVE 10.0 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     MOVE PL-DIM(WS-ROW) TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING "after leaving the nether dim " FUNCTION TRIM(WS-A) ", entering the overworld portal with the rule off dim "
         FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§4 Nether portal travel: V11 with the rule false the nether portal in the overworld does nothing "
         & "and the nether portal leads out" TO TL-CASE
     MOVE "after leaving the nether dim 3, entering the overworld portal with the rule off dim 3" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE

*>   Save and reopen: the points of interest come back with the loaded chunks.
     CALL "CORE-SAVE"
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     MOVE PQ-POI-COUNT TO WS-A
     MOVE 2 TO WS-X MOVE 41 TO WS-Y MOVE 1 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-ID
     MOVE 10 TO WS-X MOVE 100 TO WS-Y MOVE 10 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-ID
     MOVE PQ-POI-COUNT TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING "after opening " FUNCTION TRIM(WS-A) ", after loading the two chunks " FUNCTION TRIM(WS-B)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§5 PortalForcer: after a save and a reopen no point of interest is known until the chunks load; loading the "
         & "nether and overworld chunks of the portals records their 18 portal blocks again" TO TL-CASE
     MOVE "after opening 0, after loading the two chunks 18" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US12-PORTALS.

 COPY CORETEST.
 COPY PORTALTEST.
