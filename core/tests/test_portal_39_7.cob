*> Implementation test of the End rules of docs/protocol/39-portals.md section 7 (core/src/portal-39b.cob; T1757, T1758): the frame block (facing opposite to the placer,
*> comparator 15 with an eye), placing an eye and opening the portal (the pattern of 12 eyed frames facing inward, the 3 x 3 fill at the inner corner, a ring missing an eye, a frame
*> facing the wrong way, a block that is no frame, a frame that has its eye), entering an end portal block (credits gate in the End), the credits and the respawn actions, the gateway
*> transition and the end portal block entity's faces. Needs the generated packs for the world part (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DESTROYED           BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160).
 01 WS-F-N                 BINARY-LONG.
 01 WS-F-E                 BINARY-LONG.
 01 WS-F-S                 BINARY-LONG.
 01 WS-F-W                 BINARY-LONG.
 01 WS-F-N0                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-A
     CALL "PORTAL-FRAME-FACING" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways placed facing the player: placer 1 gives facing 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "PORTAL-FRAME-FACING" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways placed facing the player: placer 2 gives facing 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "PORTAL-FRAME-FACING" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways placed facing the player: placer 3 gives facing 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "PORTAL-FRAME-FACING" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways placed facing the player: placer 4 gives facing 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "PORTAL-FRAME-COMPARATOR" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways comparator output with eye 1" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "PORTAL-FRAME-COMPARATOR" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways comparator output with eye 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "PORTAL-END-INSIDE" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways a player in the End without credits sees the credits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "PORTAL-END-INSIDE" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways a player in the End who saw them is inside the portal" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "PORTAL-END-INSIDE" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways a player outside the End is inside the portal" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "PORTAL-END-INSIDE" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways another entity in the End is inside the portal" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "PORTAL-CREDITS" USING WS-A WS-B WS-C
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways showEndCredits: wonGame false sends Game Event 4" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-C TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways wonGame becomes true" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways seenCredits becomes true" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-B TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PORTAL-CREDITS" USING WS-A WS-B WS-C
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways wonGame already true sends nothing more" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-C TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 20 TO WS-B
     CALL "PORTAL-RESPAWN-ACTION" USING WS-A WS-B WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways Client Command respawn: won game: credits respawn" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "PORTAL-RESPAWN-ACTION" USING WS-A WS-B WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways Client Command respawn: dead: death respawn" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 10 TO WS-B
     CALL "PORTAL-RESPAWN-ACTION" USING WS-A WS-B WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways Client Command respawn: alive and not won: ignored" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "PORTAL-RESPAWN-ACTION" USING WS-A WS-B WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways Client Command respawn: won game wins over death" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "PORTAL-GATEWAY-DEST" USING WS-A WS-B WS-C
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways gateway pearl 1: relative delta" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-B TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways gateway pearl 1: relative rotation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-C TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "PORTAL-GATEWAY-DEST" USING WS-A WS-B WS-C
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways gateway pearl 0: relative delta" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-B TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways gateway pearl 0: relative rotation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-C TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "PORTAL-GATEWAY-COOLDOWN" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways cooldown kind 1" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "PORTAL-GATEWAY-COOLDOWN" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways cooldown kind 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "PORTAL-GATEWAY-COOLDOWN" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways cooldown kind 3" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "PORTAL-GATEWAY-COOLDOWN" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways cooldown kind 4" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "PORTAL-END-FACE" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways block entity face 1 drawn: 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "PORTAL-END-FACE" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways block entity face 2 drawn: 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "PORTAL-END-FACE" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways block entity face 3 drawn: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "PORTAL-END-FACE" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways block entity face 4 drawn: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "PORTAL-END-FACE" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways block entity face 5 drawn: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-A
     CALL "PORTAL-END-FACE" USING WS-A WS-R
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways block entity face 6 drawn: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     MOVE "end_portal" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-PORTAL
     MOVE "stone" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "end_portal_frame" TO WS-KEY
     MOVE "eye=true,facing=north" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-F-N
     MOVE "eye=true,facing=east" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-F-E
     MOVE "eye=true,facing=south" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-F-S
     MOVE "eye=true,facing=west" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-F-W
     MOVE "eye=false,facing=north" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-F-N0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 1 TO WS-A
         CALL "PORTAL-FRAME-STATE" USING WS-A WS-I WS-STATE
         CALL "PORTAL-FRAME-INFO" USING WS-STATE WS-A WS-B WS-C
         COMPUTE WS-COUNT = WS-B * 10 + WS-C
         MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways frame state with eye keeps its facing" TO TL-CASE
         COMPUTE TL-EXPECTED-N = 10 + WS-I
         MOVE WS-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 0 TO WS-A
         CALL "PORTAL-FRAME-STATE" USING WS-A WS-I WS-STATE
         CALL "PORTAL-FRAME-INFO" USING WS-STATE WS-A WS-B WS-C
         COMPUTE WS-COUNT = WS-B * 10 + WS-C
         MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways frame state without eye keeps its facing" TO TL-CASE
         MOVE WS-I TO TL-EXPECTED-N
         MOVE WS-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     PERFORM BUILD-RING
     MOVE 2 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 4 TO WS-Z
     CALL "PORTAL-FRAME-INFO" USING WS-F-N0 WS-A WS-B WS-C
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways frame info: is a frame" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways frame info: no eye" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-B TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways frame info: facing north is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-C TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PORTAL-FRAME-INFO" USING WS-STONE WS-A WS-B WS-C
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways stone is no frame" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the ring lacks the eye of the north-side middle frame (2, 60, 4); the eye placed there opens the portal
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-F-N0
     CALL "PORTAL-EYE-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-R WS-CX WS-CY WS-CZ WS-DESTROYED
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways last eye opens the portal: result 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways corner x is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways corner y is 60" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE WS-CY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways corner z is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CZ TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 3
         PERFORM VARYING WS-Z FROM 1 BY 1 UNTIL WS-Z > 3
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE = WS-PORTAL
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways the 3 x 3 centre holds nine end portal blocks" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-X
     MOVE 4 TO WS-Z
     CALL "PORTAL-EYE-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-R WS-CX WS-CY WS-CZ WS-DESTROYED
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways a frame that already has its eye passes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-X
     MOVE 3 TO WS-Z
     CALL "PORTAL-EYE-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-R WS-CX WS-CY WS-CZ WS-DESTROYED
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways an end portal block is no frame: pass" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a ring with one eye missing: the eye placed on a different frame leaves the ring open
     PERFORM BUILD-RING
     MOVE 1 TO WS-X
     MOVE 4 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-F-N0
     MOVE 3 TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-F-N0
     CALL "PORTAL-EYE-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-R WS-CX WS-CY WS-CZ WS-DESTROYED
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways an eye in a ring that still lacks one only fills the frame: result 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways the frame now holds its eye" TO TL-CASE
     MOVE WS-F-N TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a frame facing the wrong way breaks the pattern
     PERFORM BUILD-RING
     MOVE 4 TO WS-X
     MOVE 2 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-F-E
     MOVE 2 TO WS-X
     MOVE 4 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-F-N0
     CALL "PORTAL-EYE-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-R WS-CX WS-CY WS-CZ WS-DESTROYED
     MOVE "acceptance US12 39§7 The End: frames, eyes, the end portal, the return, credits, gateways a frame facing the wrong way: result 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 BUILD-RING.
     MOVE 60 TO WS-Y
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 4
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-I TO WS-X
         MOVE 4 TO WS-Z
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-F-N
         MOVE 0 TO WS-Z
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-F-S
         MOVE WS-I TO WS-Z
         MOVE 4 TO WS-X
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-F-W
         MOVE 0 TO WS-X
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-F-E
     END-PERFORM.
 END PROGRAM TEST-PORTAL-39-7.

 COPY CORETEST.
 COPY PORTALTEST.
