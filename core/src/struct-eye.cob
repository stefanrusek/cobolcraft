*> The eye of ender locate (docs/protocol/36-structures-5-mineshaft-stronghold.md section 3.10, 36-1 section 11 step 3): the answer for a concentric_rings set is the locate position (4.8) of the
*> ring chunk whose centre (16 cx + 8, 32, 16 cz + 8) is nearest to the origin block position; a later chunk replaces the best only when strictly nearer, so the first of equal distances wins.
*> Every ring chunk counts as a present start: the start check of getStructureGeneratingAt (a loaded start, a valid biome at its stub) is not made, which makes the answer the same for a world whose
*> starts are not generated yet (the radius of the item is not used by this placement kind). The whole ring list is made (STRUCT-RINGS-ALL, the biome snap of 4.6.1) when absent or made for another seed.
*>
*> Entry points:
*>   STRUCT-NEAREST-RING USING set, seed (BINARY-DOUBLE), origin x, origin y, origin z, found out (0 for a set that is not concentric_rings or has no ring), chunk x out, chunk z out, locate x out, y out, z out
*>   STRUCT-NEAREST-NAMED USING name (PIC X(40), the path of the set key without the namespace: "stronghold"), seed, origin x, y, z, found out, chunk x, chunk z, locate x, y, z out:
*>     the same for the set of that name (found 0 when the structure sets of the loaded data have none); the eye of ender uses the name "strongholds" (the key of the structure set)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-NEAREST-RING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BEST                BINARY-DOUBLE.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-DX                  BINARY-DOUBLE.
 01 WS-DY                  BINARY-DOUBLE.
 01 WS-DZ                  BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-SEED L-OX L-OY L-OZ L-FOUND L-CX L-CZ L-X L-Y L-Z.
     MOVE 0 TO L-FOUND L-CX L-CZ L-X L-Y L-Z
     IF L-SET < 1 OR L-SET > SD-SET-COUNT
         GOBACK
     END-IF
     IF SS-KIND(L-SET) NOT = 0
         GOBACK
     END-IF
*>   the whole ring list for the seed (filled when absent or stale, every position snapped)
     CALL "STRUCT-RINGS-ALL" USING L-SET L-SEED
*>   STRUCT-RINGS-PREP always gives the set a ring row (at least 1).
     MOVE SS-RING-ROW(L-SET) TO WS-ROW
     MOVE 9223372036854775807 TO WS-BEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-N(WS-ROW)
         COMPUTE WS-DX = SR-X(WS-ROW, WS-I) * 16 + 8 - L-OX
         COMPUTE WS-DY = 32 - L-OY
         COMPUTE WS-DZ = SR-Z(WS-ROW, WS-I) * 16 + 8 - L-OZ
         COMPUTE WS-D = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         IF L-FOUND = 0 OR WS-D < WS-BEST
             MOVE WS-D TO WS-BEST
             MOVE 1 TO L-FOUND
             MOVE SR-X(WS-ROW, WS-I) TO L-CX
             MOVE SR-Z(WS-ROW, WS-I) TO L-CZ
         END-IF
     END-PERFORM
     IF L-FOUND = 1
         CALL "STRUCT-LOCATE-POS" USING L-SET L-CX L-CZ L-X L-Y L-Z
     END-IF
     GOBACK.
 END PROGRAM STRUCT-NEAREST-RING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-NEAREST-NAMED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-I                   BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-PATH                PIC X(80).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-SEED                 BINARY-DOUBLE.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-SEED L-OX L-OY L-OZ L-FOUND L-CX L-CZ L-X L-Y L-Z.
     MOVE 0 TO L-FOUND L-CX L-CZ L-X L-Y L-Z WS-SET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-SET-COUNT OR WS-SET > 0
         MOVE SPACES TO WS-PATH
         IF SS-KEY(WS-I)(1:10) = "minecraft:"
             MOVE SS-KEY(WS-I)(11:70) TO WS-PATH
         ELSE
             MOVE SS-KEY(WS-I) TO WS-PATH
         END-IF
         IF FUNCTION TRIM(WS-PATH) = FUNCTION TRIM(L-NAME)
             MOVE WS-I TO WS-SET
         END-IF
     END-PERFORM
     IF WS-SET > 0
         CALL "STRUCT-NEAREST-RING" USING WS-SET L-SEED L-OX L-OY L-OZ L-FOUND L-CX L-CZ L-X L-Y L-Z
     END-IF
     GOBACK.
 END PROGRAM STRUCT-NEAREST-NAMED.
