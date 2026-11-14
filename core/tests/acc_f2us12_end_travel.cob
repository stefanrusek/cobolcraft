*> Acceptance test (US12-3 with the End wired in; docs/protocol/38-end.md section 9, 39-portals.md section 7): a player in an end portal block of the overworld
*> arrives in the End at (100.5, 49, 0.5), yaw 90, on the obsidian platform rebuilt for her (a dirt block of the old platform volume drops as an item); an end portal
*> block of the End shows her the credits first (Game Event 4 once, the portal does not move her; PERFORM_RESPAWN then returns her to the world spawn), and takes her
*> to the world spawn directly once she has seen them; an eye of ender used on the last empty end_portal_frame of a ring is consumed, sends Level Event 1503 and, with the ring
*> complete, opens nine end portal blocks and sends the global Level Event 1038; below y -64 in the End she takes 4 damage a tick. Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-END-TRAVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 COPY ENDTRAVEL.
 COPY BRWORLD.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-ED                  PIC -(7)9.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HEALTH              BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-FRAME               BINARY-LONG.
 01 WS-HEALTH-BEFORE       FLOAT-SHORT.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-3 end travel: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE 0 TO ND-PLACEHOLDER
     MOVE "end_portal" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-PORTAL
     MOVE "dirt" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-DIRT
     MOVE "obsidian" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-OBSIDIAN
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW

*>   The End's platform volume holds a dirt block before she comes.
     MOVE 99 TO WS-X MOVE 49 TO WS-Y MOVE 0 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-DIRT
*>   She stands in an end portal block of the overworld.
     MOVE 10 TO WS-X MOVE 100 TO WS-Y MOVE 10 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-PORTAL
     MOVE 10.5 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO

     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-3 end travel: she is in the End (row 5) after two ticks" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PL-DIM(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end travel: she stands at (100.5, 49, 0.5) looking west (yaw 90)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-ED = PL-X(WS-ROW) - 0.5
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     COMPUTE WS-ED = PL-Y(WS-ROW)
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-ED = PL-YAW(WS-ROW)
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "100 49 90" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 98 TO WS-X MOVE 48 TO WS-Y MOVE -2 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-3 end travel: the platform corner (98, 48, -2) is obsidian" TO TL-CASE
     MOVE WS-OBSIDIAN TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 99 TO WS-X MOVE 49 TO WS-Y MOVE 0 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12-3 end travel: the dirt block of the platform volume is air again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     MOVE "dirt" TO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ID WS-ROW-TEXT WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-DIM(WS-I) = DIM-STANDARD-END AND EN-ITEM(WS-I) = WS-ID
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US12-3 end travel: the dirt block dropped one dirt item in the End (the seed's own terrain in the volume may drop more)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Falling out of the world in the End: 4 damage a tick below y -64 (survival).
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 100.5 TO PL-X(WS-ROW)
     MOVE -70.0 TO PL-Y(WS-ROW)
     MOVE 0.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end travel: below y -64 in the End she lost 4 health in a tick" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-HEALTH(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 1 TO PL-MODE(WS-ROW)

*>   The credits: an end portal block in the End.
     MOVE 0 TO WS-X MOVE 70 TO WS-Y MOVE 0 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-PORTAL
     MOVE 0.5 TO PL-X(WS-ROW)
     MOVE 70.0 TO PL-Y(WS-ROW)
     MOVE 0.5 TO PL-Z(WS-ROW)
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     CALL "TEST-TICKS" USING WS-TWO
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     MOVE "acceptance US12-3 end travel: the end portal of the End did not move her before the credits" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PL-DIM(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end travel: one Game Event 39 (WIN_GAME) was sent for the credits" TO TL-CASE
     MOVE 0 TO WS-COUNT
     INSPECT WS-IDS TALLYING WS-COUNT FOR ALL "39"
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "TEST-CLIENT-COMMAND" USING WS-ALICE WS-A
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end travel: PERFORM_RESPAWN after the credits returns her to the overworld" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-DIM(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Having seen the credits, the End portal takes her out at once.
     CALL "BR-WORLD-READY"
     MOVE 1 TO BW-SPAWN-SET(WS-ROW)
     MOVE DIM-STANDARD-OVERWORLD TO BW-SPAWN-DIM(WS-ROW)
     MOVE 50.5 TO BW-SPAWN-X(WS-ROW)
     MOVE 80.0 TO BW-SPAWN-Y(WS-ROW)
     MOVE 60.5 TO BW-SPAWN-Z(WS-ROW)
     MOVE 0 TO BW-SPAWN-YAW(WS-ROW)
     MOVE 0 TO BW-SPAWN-PITCH(WS-ROW)
     MOVE 5 TO WS-A
     CALL "DIM-SWITCH" USING WS-ROW WS-A PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW)
     MOVE 0.5 TO PL-X(WS-ROW)
     MOVE 70.0 TO PL-Y(WS-ROW)
     MOVE 0.5 TO PL-Z(WS-ROW)
     MOVE 0 TO ET-COOLDOWN(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     MOVE "acceptance US12-3 end travel: after the credits the end portal takes her to the overworld (row 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-DIM(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end travel: she arrives at her respawn point (50, 60) and not at the world spawn" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PL-X(WS-ROW) * 1000 + PL-Z(WS-ROW)
     MOVE 50560 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An eye of ender on the last empty frame of a ring (200..204, 60, 200..204).
     MOVE "end_portal_frame" TO WS-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-X = 200 + WS-I
         MOVE 204 TO WS-Z
         MOVE 1 TO WS-FACING
         PERFORM PUT-FRAME
         MOVE 200 TO WS-Z
         MOVE 3 TO WS-FACING
         PERFORM PUT-FRAME
         COMPUTE WS-Z = 200 + WS-I
         MOVE 204 TO WS-X
         MOVE 4 TO WS-FACING
         PERFORM PUT-FRAME
         MOVE 200 TO WS-X
         MOVE 2 TO WS-FACING
         PERFORM PUT-FRAME
     END-PERFORM
     MOVE 202 TO WS-X MOVE 60 TO WS-Y MOVE 200 TO WS-Z
     MOVE 0 TO WS-EYE
     MOVE 3 TO WS-FACING
     CALL "PORTAL-FRAME-STATE" USING WS-EYE WS-FACING WS-FRAME
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-FRAME
     MOVE "ender_eye" TO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE WS-ID TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 4 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 202.5 TO PL-X(WS-ROW)
     MOVE 62.0 TO PL-Y(WS-ROW)
     MOVE 198.5 TO PL-Z(WS-ROW)
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     MOVE 201 TO WS-X MOVE 60 TO WS-Y MOVE 201 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-3 end travel: the eye completed the ring and (201, 60, 201) is an end portal block" TO TL-CASE
     MOVE WS-PORTAL TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 203 TO WS-X MOVE 203 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12-3 end travel: and so is the far corner (203, 60, 203) of the 3 x 3" TO TL-CASE
     MOVE WS-PORTAL TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end travel: one eye of the two is left (consumed in creative too)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, 5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end travel: two Level Events (1503 and the global 1038) were sent" TO TL-CASE
     MOVE 0 TO WS-COUNT
     INSPECT WS-IDS TALLYING WS-COUNT FOR ALL "47x2"
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The second eye on a frame that already holds one, and an empty hand on a frame: not handled, the eye count stays.
     MOVE 202 TO WS-X MOVE 60 TO WS-Y MOVE 200 TO WS-Z
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-ITEM(WS-ROW, 5)
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE "acceptance US12-3 end travel: an eye on a frame that has one and an empty hand use nothing up" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, 5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A spectator in an end portal block is not moved.
     MOVE 3 TO PL-MODE(WS-ROW)
     MOVE 0 TO ET-COOLDOWN(WS-ROW)
     MOVE 201.5 TO PL-X(WS-ROW)
     MOVE 60.0 TO PL-Y(WS-ROW)
     MOVE 201.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     MOVE "acceptance US12-3 end travel: a spectator in the end portal stays in the overworld (row 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-DIM(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 PUT-FRAME.
     MOVE 1 TO WS-EYE
     CALL "PORTAL-FRAME-STATE" USING WS-EYE WS-FACING WS-FRAME
     MOVE 60 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-FRAME.
 END PROGRAM ACC-F2US12-END-TRAVEL.

 COPY CORETEST.
 COPY PORTALTEST.
