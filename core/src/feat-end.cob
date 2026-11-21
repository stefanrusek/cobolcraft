*> The End and void features as data-driven feature types (docs/protocol/35-worldgen-features-7-nether-end-misc.md sections 8 to 10; registry ids 15 end_spike, 6 chorus_plant, 12 end_island, 13 end_platform,
*> 11 end_gateway, 55 void_start_platform). The engines are the programs of end-38c.cob (END-SPIKE-PLACE, END-CHORUS-PLACE, END-ISLAND-PLACE, END-PLATFORM-PLACE, END-GATEWAY-PLACE; tested by
*> test_end_38_8.cob), called with mode 0 (the level of the chunk being generated); FR-END dispatches on the type. FD-END-NODE USING doc, node, type validates the configuration: an end_spike must
*> have an empty spikes list (the list of getSpikesForLevel; a custom list is unsupported) and an end_gateway a boolean exact member (its exit is read but the block entity of the gateway is not
*> written by the engine itself, see below). The crystals an end_spike asks for are not created on this path (the End driver END-GEN-FEATURES
*> returns them to its caller). The world seed of the spike list is CW-SEED. void_start_platform (10.5): when the origin's chunk is more than one chunk (checkerboard distance) from chunk (0, 0)
*> nothing is done; else the centre is (8, origin.y + 3, 8) and every block of the chunk within checkerboard distance 16 of the centre at y = centre.y becomes stone, the centre cobblestone.
*>
*> end_podium (type 14, 10.3): FT-A the active flag (1 true, absent or false 0; a non-boolean is unsupported), placed by END-PODIUM-PLACE. An end_gateway keeps its exit in the row (FT-A 1 when the
*> exit is present, FT-B, FT-C, FT-D its x, y, z, FT-E the exact flag) and asks the block entity channel (GBE-ADD kind 3, gen-be.cob) for the entity at its centre: GBL-SEED the flags (1 exit present
*> plus 2 exact), GBL-TEXT the exit as three 10-character signed numbers; an exit that is not an array of three numbers is unsupported.
*>
*> Entry points: FD-END-NODE USING doc, node, type, row; FR-END USING state, type, x, y, z, result out, row.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-END-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-E                   BINARY-LONG.
 01 WS-K-SPIKES            PIC X(40) VALUE "spikes".
 01 WS-K-EXACT             PIC X(40) VALUE "exact".
 01 WS-K-EXIT              PIC X(40) VALUE "exit".
 01 WS-K-ACTIVE            PIC X(40) VALUE "active".
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-V                   BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-TYPE L-ROW.
     EVALUATE L-TYPE
         WHEN 14
             MOVE 0 TO FT-A(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ACTIVE WS-E
             IF WS-E > 0
                 EVALUATE JN-TYPE(WS-E)
                     WHEN JT-TRUE
                         MOVE 1 TO FT-A(L-ROW)
                     WHEN JT-FALSE
                         CONTINUE
                     WHEN OTHER
                         MOVE 1 TO FD-BAD
                 END-EVALUATE
             END-IF
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
                 IF JN-TYPE(WS-E) = JT-TRUE
                     MOVE 1 TO FT-E(L-ROW)
                 ELSE
                     MOVE 0 TO FT-E(L-ROW)
                 END-IF
             END-IF
             MOVE 0 TO FT-A(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-EXIT WS-E
             IF WS-E > 0
                 IF JN-TYPE(WS-E) NOT = JT-ARRAY OR JN-COUNT(WS-E) NOT = 3
                     MOVE 1 TO FD-BAD
                 ELSE
                     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
                         CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
                         CALL "FD-J-INT" USING JSON-DOC WS-N WS-V(WS-I + 1) WS-OK
                         IF WS-OK = 0
                             MOVE 1 TO FD-BAD
                         END-IF
                     END-PERFORM
                     MOVE 1 TO FT-A(L-ROW)
                     MOVE WS-V(1) TO FT-B(L-ROW)
                     MOVE WS-V(2) TO FT-C(L-ROW)
                     MOVE WS-V(3) TO FT-D(L-ROW)
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
 COPY FEATDATA.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-GKIND               BINARY-LONG VALUE 3.
 01 WS-GLOOT               PIC X(48) VALUE SPACES.
 01 WS-GSEED               BINARY-DOUBLE.
 01 WS-GTEXT.
    05 WS-GNUM             PIC S9(9) SIGN LEADING SEPARATE OCCURS 3 TIMES.
    05 FILLER              PIC X(2) VALUE SPACES.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-TYPE L-X L-Y L-Z L-RESULT L-ROW.
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
*>           the entity: the exit and the exact flag (10.4 rule 1), through the block entity channel
             IF FT-E(L-ROW) = 1
                 MOVE 2 TO WS-GSEED
             ELSE
                 MOVE 0 TO WS-GSEED
             END-IF
             IF FT-A(L-ROW) = 1
                 ADD 1 TO WS-GSEED
                 MOVE FT-B(L-ROW) TO WS-GNUM(1)
                 MOVE FT-C(L-ROW) TO WS-GNUM(2)
                 MOVE FT-D(L-ROW) TO WS-GNUM(3)
             ELSE
                 MOVE 0 TO WS-GNUM(1) WS-GNUM(2) WS-GNUM(3)
             END-IF
             CALL "GBE-ADD" USING L-X L-Y L-Z WS-GKIND WS-GLOOT WS-GSEED WS-GTEXT
         WHEN 14
             MOVE FT-A(L-ROW) TO WS-ACTIVE
             CALL "END-PODIUM-PLACE" USING WS-MODE WS-DIM L-X L-Y L-Z WS-ACTIVE WS-DROPPED
         WHEN OTHER
             PERFORM VOID-START-PLATFORM
     END-EVALUATE
     GO TO MAIN-EXIT.
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
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM FR-END.
