*> Acceptance test (US3-client, lane portalrender T54000; docs/protocol/52 section 8.1 point 2 and 8.13 E1): a client creates the block entity of an end_portal (type 14)
*> and of an end_gateway (type 22) only from the block entity list of a Level Chunk packet (06 section 3.2), so the core must list every such block there. Checked
*> through BE-CHUNK-PACKET (the list CHUNK-PACKET-BUILD sends): an end_portal put into the world by a player, a command or the portal fill is listed with type 14 and
*> an empty tag (data length 0, sent as absent); an end_gateway put there the same way is listed with type 22 and its Age tag; an end_gateway the worldgen channel
*> placed (GBE-APPLY kind 3, which made only the gateway table row) is listed too; and a chunk read from a save whose list lacks them (a world made before the
*> fix) gets the entities back from its cells (BE-CHUNK-BACKFILL, called by CHUNK-NBT-READ). Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-PORTALRENDER-CHUNK-BE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY BESTATE.
 COPY GENBE.
 COPY ENDGATEWAY.
 01 WS-SKIP                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-GATEWAY             BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE DIM-STANDARD-END.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HEADS.
    05 WS-HEAD             BINARY-LONG OCCURS 320 TIMES.
 01 WS-DATA                PIC X(65536).
 01 WS-I                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-GNUMS.
    05 WS-GNUM             PIC S9(9) SIGN LEADING SEPARATE OCCURS 3 TIMES.
    05 FILLER              PIC X(2) VALUE SPACES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance portalrender chunk BE: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "end_portal" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-PORTAL
     MOVE "end_gateway" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-GATEWAY

*>   An end_portal and an end_gateway put in by WORLD-SET-BLOCK (a player's placement, /setblock, the portal fill, the fight's gateways).
     MOVE 10 TO WS-X MOVE 60 TO WS-Y MOVE 10 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-PORTAL
     MOVE 12 TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GATEWAY
     CALL "BE-CHUNK-PACKET" USING WS-DIM WS-CX WS-CZ WS-COUNT WS-HEADS WS-DATA
     MOVE 10 TO WS-X
     PERFORM FIND-ENTRY
     MOVE "acceptance portalrender chunk BE: an end_portal set in the world is listed in the chunk packet with type 14 and an empty tag (E1)" TO TL-CASE
     MOVE 140 TO TL-EXPECTED-N
     PERFORM ENTRY-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-X
     PERFORM FIND-ENTRY
     MOVE "acceptance portalrender chunk BE: an end_gateway set in the world is listed with type 22 and a tag (its Age)" TO TL-CASE
     MOVE 221 TO TL-EXPECTED-N
     PERFORM ENTRY-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance portalrender chunk BE: the gateway's tag names Age" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO WS-HITS
     IF WS-FOUND = 1 AND WS-LENGTH > 0
         INSPECT WS-DATA(WS-OFFSET + 1:WS-LENGTH) TALLYING WS-HITS FOR ALL "Age"
     END-IF
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A gateway the worldgen channel placed (kind 3): the block is in the cells, the request asks for its entity.
     MOVE 3 TO WS-ROW
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE 14 TO WS-X MOVE 60 TO WS-Y MOVE 6 TO WS-Z
     COMPUTE WS-CELL = (WS-Y - DM-MIN-Y(WS-DIM)) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-GATEWAY TO CE-STATE(WS-CELL)
     MOVE 1 TO GB-COUNT
     MOVE WS-X TO GB-X(1)
     MOVE WS-Y TO GB-Y(1)
     MOVE WS-Z TO GB-Z(1)
     MOVE 3 TO GB-KIND(1)
     MOVE 3 TO GB-SEED(1)
     MOVE 7 TO WS-GNUM(1)
     MOVE 8 TO WS-GNUM(2)
     MOVE -9 TO WS-GNUM(3)
     MOVE WS-GNUMS TO GB-TEXT(1)
     CALL "GBE-APPLY" USING WS-DIM WS-ROW
     CALL "BE-CHUNK-PACKET" USING WS-DIM WS-CX WS-CZ WS-COUNT WS-HEADS WS-DATA
     PERFORM FIND-ENTRY
     MOVE "acceptance portalrender chunk BE: an end_gateway the worldgen channel placed is listed with type 22 too" TO TL-CASE
     MOVE 221 TO TL-EXPECTED-N
     PERFORM ENTRY-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A chunk read from a save that lists none of them: BE-CHUNK-BACKFILL makes the entities from the cells (the two blocks written raw, as a save made before the fix).
     MOVE 3 TO WS-X MOVE 61 TO WS-Y MOVE 4 TO WS-Z
     COMPUTE WS-CELL = (WS-Y - DM-MIN-Y(WS-DIM)) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-PORTAL TO CE-STATE(WS-CELL)
     MOVE 5 TO WS-X
     COMPUTE WS-CELL = (WS-Y - DM-MIN-Y(WS-DIM)) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-GATEWAY TO CE-STATE(WS-CELL)
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-INDEX
     MOVE "acceptance portalrender chunk BE: before the backfill a block written raw has no entity" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BE-CHUNK-BACKFILL" USING WS-ROW
     CALL "BE-CHUNK-PACKET" USING WS-DIM WS-CX WS-CZ WS-COUNT WS-HEADS WS-DATA
     MOVE 3 TO WS-X
     PERFORM FIND-ENTRY
     MOVE "acceptance portalrender chunk BE: after the backfill the raw end_portal is listed with type 14" TO TL-CASE
     MOVE 140 TO TL-EXPECTED-N
     PERFORM ENTRY-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     PERFORM FIND-ENTRY
     MOVE "acceptance portalrender chunk BE: and the raw end_gateway with type 22" TO TL-CASE
     MOVE 221 TO TL-EXPECTED-N
     PERFORM ENTRY-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The backfill makes none for a block that already has one, and none for another block.
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) = WS-DIM AND BE-X(WS-I) = 10 AND BE-Y(WS-I) = 60 AND BE-Z(WS-I) = 10
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     CALL "BE-CHUNK-BACKFILL" USING WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) = WS-DIM AND BE-X(WS-I) = 10 AND BE-Y(WS-I) = 60 AND BE-Z(WS-I) = 10
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE "acceptance portalrender chunk BE: a second backfill leaves one entity for a block that has one (1 before, 1 after)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> ENTRY-CODE: type * 10 + 1 when the entry has a tag (-1 when there is no entry).
*> FIND-ENTRY: the entry of the chunk list at local (WS-X, WS-Y, WS-Z of the packed position): WS-FOUND, WS-TYPE, WS-LENGTH, WS-OFFSET (data bytes before it).
 FIND-ENTRY.
     MOVE 0 TO WS-FOUND WS-TYPE WS-LENGTH WS-OFFSET
     MOVE 0 TO WS-INDEX
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT
         IF WS-HEAD(WS-I * 5 + 1) = WS-X AND WS-HEAD(WS-I * 5 + 2) = WS-Y AND WS-HEAD(WS-I * 5 + 3) = WS-Z
             MOVE 1 TO WS-FOUND
             MOVE WS-HEAD(WS-I * 5 + 4) TO WS-TYPE
             MOVE WS-HEAD(WS-I * 5 + 5) TO WS-LENGTH
             MOVE WS-INDEX TO WS-OFFSET
         END-IF
         ADD WS-HEAD(WS-I * 5 + 5) TO WS-INDEX
     END-PERFORM.

 ENTRY-CODE.
     MOVE -1 TO TL-OBSERVED-N
     IF WS-FOUND = 1
         COMPUTE TL-OBSERVED-N = WS-TYPE * 10
         IF WS-LENGTH > 0
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-IF.

 END PROGRAM ACC-PORTALRENDER-CHUNK-BE.

 COPY CORETEST.
 COPY PORTALTEST.
