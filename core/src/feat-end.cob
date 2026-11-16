*> The End and void features as data-driven feature types (docs/protocol/35-worldgen-features-7-nether-end-misc.md sections 8 to 10; registry ids 15 end_spike, 6 chorus_plant, 12 end_island, 13 end_platform,
*> 11 end_gateway, 55 void_start_platform). The engines are the programs of end-38c.cob (END-SPIKE-PLACE, END-CHORUS-PLACE, END-ISLAND-PLACE, END-PLATFORM-PLACE, END-GATEWAY-PLACE; tested by
*> test_end_38_8.cob), called with mode 0 (the level of the chunk being generated); FR-END dispatches on the type. FD-END-NODE USING doc, node, type validates the configuration: an end_spike must
*> have an empty spikes list (the list of getSpikesForLevel; a custom list is unsupported) and an end_gateway a boolean exact member (its exit is read but the block entity of the gateway is not
*> written: the generation channel holds containers and spawners only, as in END-GATEWAY-ROLL). The crystals an end_spike asks for are not created on this path (the End driver END-GEN-FEATURES
*> returns them to its caller). The world seed of the spike list is CW-SEED. void_start_platform (10.5): when the origin's chunk is more than one chunk (checkerboard distance) from chunk (0, 0)
*> nothing is done; else the centre is (8, origin.y + 3, 8) and every block of the chunk within checkerboard distance 16 of the centre at y = centre.y becomes stone, the centre cobblestone.
*>
*> Entry points: FD-END-NODE USING doc, node, type; FR-END USING state, type, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-END-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-E                   BINARY-LONG.
 01 WS-K-SPIKES            PIC X(40) VALUE "spikes".
 01 WS-K-EXACT             PIC X(40) VALUE "exact".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-TYPE.
     EVALUATE L-TYPE
         WHEN 15
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SPIKES WS-E
             IF WS-E = 0 OR JN-TYPE(WS-E) NOT = JT-ARRAY OR JN-COUNT(WS-E) NOT = 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 11
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-EXACT WS-E
             IF WS-E = 0
                 MOVE 1 TO FD-BAD
             ELSE
                 IF JN-TYPE(WS-E) NOT = JT-TRUE AND JN-TYPE(WS-E) NOT = JT-FALSE
                     MOVE 1 TO FD-BAD
                 END-IF
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM FD-END-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-END.
*> USING state, type, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENDSPIKE.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-DROP                BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-KEY-STONE           PIC X(48) VALUE "stone".
 01 WS-KEY-COBBLE          PIC X(48) VALUE "cobblestone".
 01 WS-NONE                PIC X(160) VALUE SPACES.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-COBBLE            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CHUNK-X             BINARY-LONG.
 01 WS-CHUNK-Z             BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-TYPE L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     EVALUATE L-TYPE
         WHEN 15
             MOVE 0 TO EC-COUNT
             MOVE CW-SEED TO WS-SEED
             CALL "END-SPIKE-PLACE" USING WS-MODE WS-DIM L-X L-Z WS-SEED L-STATE CRYSTAL-LIST
         WHEN 6
             CALL "END-CHORUS-PLACE" USING WS-MODE WS-DIM L-X L-Y L-Z L-STATE L-RESULT
         WHEN 12
             CALL "END-ISLAND-PLACE" USING WS-MODE WS-DIM L-X L-Y L-Z L-STATE
         WHEN 13
             CALL "END-PLATFORM-PLACE" USING WS-MODE WS-DIM L-X L-Y L-Z WS-DROP WS-DROPPED
         WHEN 11
             CALL "END-GATEWAY-PLACE" USING WS-MODE WS-DIM L-X L-Y L-Z
         WHEN OTHER
             PERFORM VOID-START-PLATFORM
     END-EVALUATE
     GOBACK.
 VOID-START-PLATFORM.
     COMPUTE WS-CHUNK-X = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CHUNK-Z = FUNCTION INTEGER(L-Z / 16)
     IF FUNCTION ABS(WS-CHUNK-X) > 1 OR FUNCTION ABS(WS-CHUNK-Z) > 1
         EXIT PARAGRAPH
     END-IF
     CALL "END-STATE-ID" USING WS-KEY-STONE WS-NONE WS-S-STONE
     CALL "END-STATE-ID" USING WS-KEY-COBBLE WS-NONE WS-S-COBBLE
     COMPUTE WS-CY = L-Y + 3
     COMPUTE WS-X0 = WS-CHUNK-X * 16
     COMPUTE WS-Z0 = WS-CHUNK-Z * 16
     PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z0 + 15
         PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X0 + 15
             COMPUTE WS-DX = FUNCTION ABS(8 - WS-X)
             COMPUTE WS-DZ = FUNCTION ABS(8 - WS-Z)
             IF WS-DX <= 16 AND WS-DZ <= 16
                 IF WS-X = 8 AND WS-Z = 8
                     MOVE WS-S-COBBLE TO WS-STATE
                 ELSE
                     MOVE WS-S-STONE TO WS-STATE
                 END-IF
                 CALL "END-PUT" USING WS-MODE WS-DIM WS-X WS-CY WS-Z WS-STATE
             END-IF
         END-PERFORM
     END-PERFORM
     .
 END PROGRAM FR-END.
