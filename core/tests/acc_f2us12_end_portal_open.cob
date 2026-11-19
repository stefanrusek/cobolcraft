*> Acceptance test (lane bugendportal, T46000+; operator report try15: "placing eyes of ender uses the eye and you can't use one more than once on an empty end portal block, but
*> the block doesn't update and the portal doesn't open"; docs/protocol/39-portals.md section 7.2, 25 section 6.3, 29 section 7): a ring of 12 end_portal_frame blocks (each facing inward;
*> ten with an eye) in a standard world, two players watching. An ender_eye used (Use Item On, the real packet path) on an empty frame sets eye true and BOTH players get the Block Update
*> with the frame's new state id and Level Event 1503, the survival stack loses one; an eye on a frame that has one changes nothing (item kept, no update, no event); the eye in the last
*> frame sends the frame's update, the nine interior cells as end_portal (a Section Blocks Update) and the global Level Event 1038 at the middle. A second ring built with /setblock (Alice is an operator) opens
*> the same way. The state ids are the registry's (BLOCKS-STATE-OF of eye=..,facing=..). Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-END-PORTAL-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 01 WS-SKIP                BINARY-LONG.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-BOB-NAME            PIC X(16) VALUE "Bob".
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BROW                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WAIT-CX             BINARY-LONG.
 01 WS-WAIT-CZ             BINARY-LONG.
 01 WS-WAIT-ROW            BINARY-LONG.
 01 WS-WAIT-K              BINARY-LONG.
 01 WS-EYE-SOUTH           BINARY-LONG.
 01 WS-EMPTY-SOUTH         BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EXPECT-STATE        BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-FRAME               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ATEXT               PIC X(4096).
 01 WS-BTEXT               PIC X(4096).
 01 WS-NEEDLE              PIC X(64).
 01 WS-NEEDLE-LENGTH       BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-ED2                 PIC -(9)9.
 01 WS-ED3                 PIC -(9)9.
 01 WS-ED4                 PIC -(9)9.
 01 WS-RUN-TEXT            PIC X(4096).
 01 WS-LINE                PIC X(768).
 01 WS-CASE-TAIL           PIC X(120).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-3 end portal open: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE 0 TO ND-PLACEHOLDER
     MOVE 12345 TO CW-SEED
     MOVE "end_portal" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-PORTAL
     MOVE "end_portal_frame" TO WS-KEY
     MOVE "eye=true,facing=south" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-EYE-SOUTH
     MOVE "eye=false,facing=south" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-EMPTY-SOUTH
     MOVE SPACES TO WS-PAIRS
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-ALICE-NAME WS-NAME-LENGTH WS-ALICE
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-BOB-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE CN-PLAYER(WS-BOB) TO WS-BROW

*>   The ring of 24-4 6.20 / 39 7.2: x and z 200..204 at y 60, the three frames of each side facing inward, all with eyes except (201, 60, 200) and (202, 60, 200).
     MOVE 150 TO WS-Y
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-X = 200 + WS-I
         MOVE 204 TO WS-Z
         MOVE 1 TO WS-FACING
         PERFORM PUT-FRAME
         MOVE 200 TO WS-Z
         MOVE 3 TO WS-FACING
         MOVE 1 TO WS-EYE
         IF WS-I < 3
             MOVE 0 TO WS-EYE
         END-IF
         PERFORM PUT-FRAME-EYE
         COMPUTE WS-Z = 200 + WS-I
         MOVE 204 TO WS-X
         MOVE 4 TO WS-FACING
         PERFORM PUT-FRAME
         MOVE 200 TO WS-X
         MOVE 2 TO WS-FACING
         PERFORM PUT-FRAME
     END-PERFORM
*>   one stone in the interior (the opening destroys it), and stone floors under the places the players stand (the ring is high above the terrain)
     MOVE "stone" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-STONE
     MOVE 202 TO WS-X MOVE 150 TO WS-Y MOVE 202 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STONE
     MOVE 149 TO WS-Y
     MOVE 198 TO WS-Z
     MOVE 202 TO WS-X
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STONE
     MOVE 203 TO WS-X
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STONE
     MOVE 212 TO WS-X
     MOVE 208 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STONE

     MOVE "ender_eye" TO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE WS-ID TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 4 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 202.5 TO PL-X(WS-ROW)
     MOVE 151.0 TO PL-Y(WS-ROW)
     MOVE 198.5 TO PL-Z(WS-ROW)
     MOVE 203.5 TO PL-X(WS-BROW)
     MOVE 151.0 TO PL-Y(WS-BROW)
     MOVE 198.5 TO PL-Z(WS-BROW)
*>   a teleport's tail (cmd-actions.cob): the players follow their new chunks, so they watch the ring
     CALL "CHUNKS-FOLLOW" USING WS-ALICE
     CALL "CHUNKS-FOLLOW" USING WS-BOB
     MOVE 14 TO WS-WAIT-CX
     MOVE 14 TO WS-WAIT-CZ
     PERFORM WAIT-CHUNK
     CALL "TEST-TICKS" USING WS-THREE
     CALL "EP-DRAIN" USING WS-ALICE WS-ATEXT
     CALL "EP-DRAIN" USING WS-BOB WS-BTEXT

*>   The first eye: (201, 60, 200) facing south, eye false -> eye true.
     MOVE 201 TO WS-X MOVE 150 TO WS-Y MOVE 200 TO WS-Z
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-TICKS" USING WS-ONE
     CALL "EP-DRAIN" USING WS-ALICE WS-ATEXT
     CALL "EP-DRAIN" USING WS-BOB WS-BTEXT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-3 end portal open: the world holds the frame with its eye (registry state of eye=true,facing=south)" TO TL-CASE
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STATE
     MOVE WS-EYE-SOUTH TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: Alice gets the Block Update of the frame with eye true" TO TL-CASE
     PERFORM SOUTH-NEEDLE-201
     PERFORM TALLY-ALICE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: Bob, who watches the chunk, gets it too" TO TL-CASE
     PERFORM TALLY-BOB
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: Alice gets Level Event 1503 at the frame" TO TL-CASE
     MOVE "47(1503,201,150,200,0)" TO WS-NEEDLE
     MOVE 22 TO WS-NEEDLE-LENGTH
     PERFORM TALLY-ALICE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: Bob gets Level Event 1503" TO TL-CASE
     PERFORM TALLY-BOB
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: the survival stack lost one eye (3 -> 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, 5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: the ring is incomplete: no portal block opened, no 1038" TO TL-CASE
     MOVE "47(1038" TO WS-NEEDLE
     MOVE 7 TO WS-NEEDLE-LENGTH
     PERFORM TALLY-ALICE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A second eye on the same frame: nothing changes (PASS), the item is kept, no update and no event.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-TICKS" USING WS-ONE
     CALL "EP-DRAIN" USING WS-ALICE WS-ATEXT
     MOVE "acceptance US12-3 end portal open: an eye on a frame that has one keeps the item (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, 5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: and sends no Level Event" TO TL-CASE
     MOVE "47(" TO WS-NEEDLE
     MOVE 3 TO WS-NEEDLE-LENGTH
     PERFORM TALLY-ALICE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The last eye: (202, 150, 200), the ring is complete, the 3 x 3 interior (201..203, 150, 201..203) opens.
     MOVE 202 TO WS-X MOVE 150 TO WS-Y MOVE 200 TO WS-Z
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-TICKS" USING WS-ONE
     CALL "EP-DRAIN" USING WS-ALICE WS-ATEXT
     CALL "EP-DRAIN" USING WS-BOB WS-BTEXT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 201 BY 1 UNTIL WS-I > 203
         PERFORM VARYING WS-J FROM 201 BY 1 UNTIL WS-J > 203
             MOVE 150 TO WS-Y
             CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-I WS-Y WS-J WS-STATE
             IF WS-STATE = WS-PORTAL
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12-3 end portal open: the nine interior cells are end_portal blocks" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: the last frame update reaches Alice (eye true facing south)" TO TL-CASE
     PERFORM SOUTH-NEEDLE-202
     PERFORM TALLY-ALICE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: Alice is told nine end_portal states (Section Blocks Update)" TO TL-CASE
     MOVE SPACES TO WS-NEEDLE
     MOVE WS-PORTAL TO WS-ED
     STRING "=" FUNCTION TRIM(WS-ED) ")" DELIMITED BY SIZE INTO WS-NEEDLE
     COMPUTE WS-NEEDLE-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-NEEDLE TRAILING))
     PERFORM TALLY-ALICE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: Bob is told nine end_portal states too" TO TL-CASE
     PERFORM TALLY-BOB
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: the global Level Event 1038 at the middle (202, 150, 202) reaches Alice" TO TL-CASE
     MOVE "47(1038,202,150,202,1)" TO WS-NEEDLE
     MOVE 22 TO WS-NEEDLE-LENGTH
     PERFORM TALLY-ALICE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: and Bob" TO TL-CASE
     PERFORM TALLY-BOB
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: one eye is left (3 - 2)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, 5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A ring built with /setblock (console, sender 0): x and z 210..214 at y 70, the last frame without an eye; one eye opens it.
     MOVE 214 TO WS-Z
     PERFORM VARYING WS-I FROM 211 BY 1 UNTIL WS-I > 213
         MOVE WS-I TO WS-X
         MOVE 214 TO WS-Z
         MOVE "north" TO WS-CASE-TAIL
         PERFORM SETBLOCK-FRAME
         MOVE 210 TO WS-Z
         MOVE "south" TO WS-CASE-TAIL
         IF WS-I = 213
             PERFORM SETBLOCK-EMPTY-FRAME
         ELSE
             PERFORM SETBLOCK-FRAME
         END-IF
         MOVE WS-I TO WS-Z
         MOVE 214 TO WS-X
         MOVE "west" TO WS-CASE-TAIL
         PERFORM SETBLOCK-FRAME
         MOVE 210 TO WS-X
         MOVE "east" TO WS-CASE-TAIL
         PERFORM SETBLOCK-FRAME
     END-PERFORM
     CALL "TEST-TICKS" USING WS-ONE
     CALL "EP-DRAIN" USING WS-ALICE WS-ATEXT
     MOVE 213 TO WS-X MOVE 150 TO WS-Y MOVE 210 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12-3 end portal open: /setblock built the last frame with eye false facing south (registry state of eye=false,facing=south)" TO TL-CASE
     MOVE WS-EMPTY-SOUTH TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 212.5 TO PL-X(WS-ROW)
     MOVE 151.0 TO PL-Y(WS-ROW)
     MOVE 208.5 TO PL-Z(WS-ROW)
     CALL "CHUNKS-FOLLOW" USING WS-ALICE
     MOVE 15 TO WS-WAIT-CX
     MOVE 15 TO WS-WAIT-CZ
     PERFORM WAIT-CHUNK
     CALL "TEST-TICKS" USING WS-THREE
     CALL "EP-DRAIN" USING WS-ALICE WS-ATEXT
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-TICKS" USING WS-ONE
     CALL "EP-DRAIN" USING WS-ALICE WS-ATEXT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 211 BY 1 UNTIL WS-I > 213
         PERFORM VARYING WS-J FROM 211 BY 1 UNTIL WS-J > 213
             MOVE 150 TO WS-Y
             CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-I WS-Y WS-J WS-STATE
             IF WS-STATE = WS-PORTAL
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12-3 end portal open: the /setblock ring opens nine end_portal blocks" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end portal open: and Alice is told nine end_portal states" TO TL-CASE
     PERFORM TALLY-ALICE-PORTAL
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 WAIT-CHUNK.
*>   the chunk feed generates the new view over several ticks: run them until the far corner of the view is loaded
     MOVE 0 TO WS-WAIT-ROW
     PERFORM VARYING WS-WAIT-K FROM 1 BY 1 UNTIL WS-WAIT-K > 600 OR WS-WAIT-ROW > 0
*>       the number of ticks the feed needs varies with the machine: the players answer every Keep Alive (a test client does not), or they time out
         MOVE 0 TO CN-KA-PENDING(WS-ALICE) CN-KA-PENDING(WS-BOB)
         COMPUTE CN-KA-DEADLINE(WS-ALICE) = CW-TICKS + 1000
         COMPUTE CN-KA-DEADLINE(WS-BOB) = CW-TICKS + 1000
         CALL "TEST-TICKS" USING WS-ONE
         CALL "WORLD-FIND" USING DIM-STANDARD-OVERWORLD WS-WAIT-CX WS-WAIT-CZ WS-WAIT-ROW
     END-PERFORM.

 PUT-FRAME.
     MOVE 1 TO WS-EYE
     PERFORM PUT-FRAME-EYE.

 PUT-FRAME-EYE.
     CALL "PORTAL-FRAME-STATE" USING WS-EYE WS-FACING WS-FRAME
     MOVE 150 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-FRAME.

 SOUTH-NEEDLE-201.
     MOVE SPACES TO WS-NEEDLE
     MOVE WS-EYE-SOUTH TO WS-ED
     STRING "8(201,150,200=" FUNCTION TRIM(WS-ED) ")" DELIMITED BY SIZE INTO WS-NEEDLE
     COMPUTE WS-NEEDLE-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-NEEDLE TRAILING)).

 SOUTH-NEEDLE-202.
     MOVE SPACES TO WS-NEEDLE
     MOVE WS-EYE-SOUTH TO WS-ED
     STRING "(202,150,200=" FUNCTION TRIM(WS-ED) ")" DELIMITED BY SIZE INTO WS-NEEDLE
     COMPUTE WS-NEEDLE-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-NEEDLE TRAILING)).

 TALLY-ALICE.
     MOVE 0 TO WS-COUNT
     INSPECT WS-ATEXT TALLYING WS-COUNT FOR ALL WS-NEEDLE(1:WS-NEEDLE-LENGTH).

 TALLY-BOB.
     MOVE 0 TO WS-COUNT
     INSPECT WS-BTEXT TALLYING WS-COUNT FOR ALL WS-NEEDLE(1:WS-NEEDLE-LENGTH).

 TALLY-ALICE-PORTAL.
     MOVE SPACES TO WS-NEEDLE
     MOVE WS-PORTAL TO WS-ED
     STRING "=" FUNCTION TRIM(WS-ED) ")" DELIMITED BY SIZE INTO WS-NEEDLE
     COMPUTE WS-NEEDLE-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-NEEDLE TRAILING))
     PERFORM TALLY-ALICE.

 SETBLOCK-FRAME.
     MOVE SPACES TO WS-LINE
     MOVE WS-X TO WS-ED2
     MOVE 150 TO WS-ED3
     MOVE WS-Z TO WS-ED4
     STRING "setblock " FUNCTION TRIM(WS-ED2) " 150 " FUNCTION TRIM(WS-ED4)
         " minecraft:end_portal_frame[eye=true,facing=" FUNCTION TRIM(WS-CASE-TAIL) "]"
         DELIMITED BY SIZE INTO WS-LINE
     CALL "TEST-RUN" USING WS-ALICE WS-LINE WS-RUN-TEXT.

 SETBLOCK-EMPTY-FRAME.
     MOVE SPACES TO WS-LINE
     MOVE WS-X TO WS-ED2
     MOVE WS-Z TO WS-ED4
     STRING "setblock " FUNCTION TRIM(WS-ED2) " 150 " FUNCTION TRIM(WS-ED4)
         " minecraft:end_portal_frame[eye=false,facing=" FUNCTION TRIM(WS-CASE-TAIL) "]"
         DELIMITED BY SIZE INTO WS-LINE
     CALL "TEST-RUN" USING WS-ALICE WS-LINE WS-RUN-TEXT.
 END PROGRAM ACC-F2US12-END-PORTAL-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EP-DRAIN.
*> USING connection id, text out (PIC X(4096)): drains the connection; Block Update "8(x,y,z=state)", each entry of a Section Blocks Update "86(x,y,z=state)", Level Event
*> "47(event,x,y,z,global)", other packets left out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-POS                 BINARY-DOUBLE.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-REM                 BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-TWO-42              BINARY-DOUBLE VALUE 4398046511104.
 01 WS-TWO-20              BINARY-DOUBLE VALUE 1048576.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             EVALUATE WS-PACKET-ID
                 WHEN 8
                     CALL "PB-GET-POSITION" USING PK-BUFFER WS-X WS-Y WS-Z
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     MOVE WS-X TO WS-E1
                     MOVE WS-Y TO WS-E2
                     MOVE WS-Z TO WS-E3
                     MOVE WS-A TO WS-E4
                     STRING "8(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "="
                         FUNCTION TRIM(WS-E4) ") " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 WHEN 47
                     CALL "PB-GET-INT" USING PK-BUFFER WS-A
                     CALL "PB-GET-POSITION" USING PK-BUFFER WS-X WS-Y WS-Z
                     CALL "PB-GET-INT" USING PK-BUFFER WS-D
                     CALL "PB-GET-BOOL" USING PK-BUFFER WS-G
                     MOVE WS-A TO WS-E1
                     MOVE WS-X TO WS-E2
                     MOVE WS-Y TO WS-E3
                     MOVE WS-Z TO WS-E4
                     MOVE WS-G TO WS-E5
                     STRING "47(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) ","
                         FUNCTION TRIM(WS-E4) "," FUNCTION TRIM(WS-E5) ") " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 WHEN 86
                     CALL "PB-GET-LONG" USING PK-BUFFER WS-POS
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-N
                     DIVIDE WS-POS BY WS-TWO-42 GIVING WS-Q REMAINDER WS-REM
                     MOVE WS-Q TO WS-SX
                     DIVIDE WS-REM BY WS-TWO-20 GIVING WS-Q REMAINDER WS-V
                     MOVE WS-Q TO WS-SZ
                     MOVE WS-V TO WS-SY
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
                         CALL "PB-GET-VARLONG" USING PK-BUFFER WS-V
                         DIVIDE WS-V BY 4096 GIVING WS-Q REMAINDER WS-REM
                         MOVE WS-Q TO WS-STATE
                         MOVE WS-REM TO WS-LOCAL
                         COMPUTE WS-X = WS-SX * 16 + (WS-LOCAL - FUNCTION MOD(WS-LOCAL, 256)) / 256
                         COMPUTE WS-A = FUNCTION MOD(WS-LOCAL, 256)
                         COMPUTE WS-Z = WS-SZ * 16 + (WS-A - FUNCTION MOD(WS-A, 16)) / 16
                         COMPUTE WS-Y = WS-SY * 16 + FUNCTION MOD(WS-A, 16)
                         MOVE WS-X TO WS-E1
                         MOVE WS-Y TO WS-E2
                         MOVE WS-Z TO WS-E3
                         MOVE WS-STATE TO WS-E4
                         STRING "86(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "="
                             FUNCTION TRIM(WS-E4) ") " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                     END-PERFORM
             END-EVALUATE
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM EP-DRAIN.

 COPY CORETEST.
 COPY PORTALTEST.
 COPY CMDTEST.
