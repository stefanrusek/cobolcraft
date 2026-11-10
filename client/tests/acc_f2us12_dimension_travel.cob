*> Acceptance test US12-3 (spec 002 FR-031, FR-032, FR-038; docs/protocol/39 section 8.4, 9; 05a Respawn 0x54): Respawn into another dimension swaps the replica and the dimension
*> type (the Nether and the End have no sky light) and, until the new level is loaded (Player Loaded not yet sent), the world screen shows the level-loading overlay:
*> the reason is the Nether portal when the player is not dying and either dimension is the Nether, the End portal when either is the End (and not the Nether), else
*> none (LL-REASON 0: the same dimension, or a death). The overlay is a full-screen overlay widget and a label; it goes once the level is loaded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-DIMENSION-TRAVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-OVERLAYS            BINARY-LONG.
 01 WS-LABELS              BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-worldgen-biome.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-dimension-type-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/play-s2c-32-login-all-dimensions-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO CL-NOW-MS PL-HURT-UNTIL
     MOVE "T" TO TL-MODE

     PERFORM STATE-TEXT
     MOVE "acceptance US12-3 after Login the player is in the overworld, no loading reason" TO TL-CASE
     MOVE "minecraft:overworld 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-54-respawn-the-nether-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     PERFORM STATE-TEXT
     MOVE "acceptance US12-3 Respawn into the Nether: the dimension is the Nether, the reason Nether portal (1), not loaded" TO TL-CASE
     MOVE "minecraft:the_nether 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-3 the Nether has no sky light (the dimension type of the replica)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-HAS-SKY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM OVERLAY-TEXT
     MOVE "acceptance US12-3 while the level loads the world screen has the portal overlay and one label" TO TL-CASE
     MOVE "1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-LOADED
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM OVERLAY-TEXT
     MOVE "acceptance US12-3 once the level is loaded the overlay and label are gone" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Nether to End: the Nether is involved, so Nether portal; End to overworld: End portal; overworld to overworld: none.
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-the-end-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     PERFORM STATE-TEXT
     MOVE "acceptance US12-3 Nether to End: Nether portal (1)" TO TL-CASE
     MOVE "minecraft:the_end 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-main-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     PERFORM STATE-TEXT
     MOVE "acceptance US12-3 End to overworld: End portal (2)" TO TL-CASE
     MOVE "minecraft:overworld 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     PERFORM STATE-TEXT
     MOVE "acceptance US12-3 a Respawn into the same dimension (a respawn after death): no reason (0)" TO TL-CASE
     MOVE "minecraft:overworld 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A dying player (health 0) changing dimension: none.
     MOVE 0 TO PL-HEALTH
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-the-nether-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     PERFORM STATE-TEXT
     MOVE "acceptance US12-3 a player who is dying (health 0) gets reason none (0) even into the Nether" TO TL-CASE
     MOVE "minecraft:the_nether 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Any other dimension change (cobolcraft:subroutine): reason other (3).
     MOVE 20 TO PL-HEALTH
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-main-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-subroutine.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     PERFORM STATE-TEXT
     MOVE "acceptance US12-3 a change to any other dimension (cobolcraft:subroutine) has reason other (3)" TO TL-CASE
     MOVE "cobolcraft:subroutine 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 STATE-TEXT.
     MOVE SPACES TO TL-OBSERVED
     MOVE LL-REASON TO WS-E1
     STRING FUNCTION TRIM(PL-DIM-NAME) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     .

*> "overlays labels" of the screen model.
 OVERLAY-TEXT.
     MOVE 0 TO WS-OVERLAYS WS-LABELS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-ARG(WS-I) = SW-BLACK
             ADD 1 TO WS-OVERLAYS
         END-IF
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-LENGTH(WS-I) > 0 AND SM-W-ARG(WS-I) = 77
             ADD 1 TO WS-LABELS
         END-IF
     END-PERFORM
     MOVE WS-OVERLAYS TO WS-E2
     MOVE WS-LABELS TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     .
 END PROGRAM ACC-F2US12-DIMENSION-TRAVEL.

 COPY CLTEST.
