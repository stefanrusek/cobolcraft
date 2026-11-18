*> The eye of ender locate (docs/protocol/36-structures-5-mineshaft-stronghold.md section 3.10, 36-1 section 11 step 3): the answer for a concentric_rings set is the locate position (4.8) of the
*> ring chunk whose centre (16 cx + 8, 32, 16 cz + 8) is nearest to the origin block position; a later chunk replaces the best only when strictly nearer, so the first of equal distances wins.
*> Every ring chunk counts as a present start: the start check of getStructureGeneratingAt (a loaded start, a valid biome at its stub) is not made, which makes the answer the same for a world whose
*> starts are not generated yet (the radius of the item is not used by this placement kind). The ring list is made (STRUCT-RINGS-PREP) when absent or made for another seed and its positions are snapped (the biome snap of 4.6.1) only as far as the answer needs (STRUCT-NEAREST-RING).
*>
*> Entry points:
*>   STRUCT-NEAREST-RING USING set, seed (BINARY-DOUBLE), origin x, origin y, origin z, found out (0 for a set that is not concentric_rings or has no ring), chunk x out, chunk z out, locate x out, y out, z out
*>   STRUCT-NEAREST-NAMED USING name (PIC X(40), the path of the set key without the namespace: "stronghold"), seed, origin x, y, z, found out, chunk x, chunk z, locate x, y, z out:
*>     the same for the set of that name (found 0 when the structure sets of the loaded data have none); the eye of ender uses the name "strongholds" (the key of the structure set)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-NEAREST-RING.
*> The ring list is snapped on demand (STRUCT-RING-READY; each position has its own forked seed, so the order of the snaps changes none of them): the biome snap moves a ring position by
*> at most 7 chunks on each axis (STRUCT-RING-HAS), that is at most 112 blocks on each axis and 159 blocks apart, so a position whose raw centre is farther from the origin than the best answer so far
*> plus 160 blocks cannot be nearer and is never snapped. Positions already snapped count with their chunk; the unsnapped one with the nearest raw centre is snapped next. The answer is the one
*> of the whole list (the first of equal distances wins by its index) but a search from a spot near one of the 128 strongholds snaps a handful of the positions (one snap is 3249 biome lookups). With SD-SNAP-LIMIT above 0 a call
*> does that many rows of the biome searches (57 rows a position) and leaves SD-SNAP-PENDING 1 when more were needed: the answer of such a call is not final, the next call goes on from the rows done (the locate search of a tick).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-STALE               BINARY-LONG.
 01 WS-BEST                BINARY-DOUBLE.
 01 WS-BEST-I              BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-PICK-D              BINARY-DOUBLE.
 01 WS-STOP                BINARY-LONG.
 01 WS-ROWS-USED           BINARY-LONG.
 01 WS-ALLOW               BINARY-LONG.
 01 WS-ROWS-DONE           BINARY-LONG.
 01 WS-SNAP-DONE           BINARY-LONG.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-LOW                 BINARY-DOUBLE.
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
     MOVE 0 TO L-FOUND L-CX L-CZ L-X L-Y L-Z WS-ROWS-USED
     IF L-SET < 1 OR L-SET > SD-SET-COUNT
         GOBACK
     END-IF
     IF SS-KIND(L-SET) NOT = 0
         GOBACK
     END-IF
*>   the ring list for the seed (filled when absent or stale; no position snapped by this)
     CALL "STRUCT-RING-SEED" USING L-SEED WS-SEED
     CALL "STRUCT-RING-STALE" USING L-SET WS-SEED WS-STALE
     IF WS-STALE = 1
         CALL "STRUCT-RINGS-PREP" USING L-SET WS-SEED
     END-IF
*>   STRUCT-RINGS-PREP always gives the set a ring row (at least 1).
     MOVE SS-RING-ROW(L-SET) TO WS-ROW
     COMPUTE WS-DY = 32 - L-OY
     MOVE 9223372036854775807 TO WS-BEST
     MOVE 0 TO WS-BEST-I
*>   the positions snapped already: their chunk counts at once
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-N(WS-ROW)
         IF SR-DONE(WS-ROW, WS-I) = 1
             COMPUTE WS-DX = SR-X(WS-ROW, WS-I) * 16 + 8 - L-OX
             COMPUTE WS-DZ = SR-Z(WS-ROW, WS-I) * 16 + 8 - L-OZ
             COMPUTE WS-D = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-BEST-I = 0 OR WS-D < WS-BEST
                 MOVE WS-D TO WS-BEST
                 MOVE WS-I TO WS-BEST-I
             END-IF
         END-IF
     END-PERFORM
*>   then the unsnapped position with the nearest raw centre, until none can beat the best answer
     MOVE 0 TO WS-STOP
     PERFORM UNTIL WS-STOP = 1
         MOVE 0 TO WS-PICK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-N(WS-ROW)
             IF SR-DONE(WS-ROW, WS-I) = 0
                 COMPUTE WS-DX = SR-RAW-X(WS-ROW, WS-I) * 16 + 8 - L-OX
                 COMPUTE WS-DZ = SR-RAW-Z(WS-ROW, WS-I) * 16 + 8 - L-OZ
                 COMPUTE WS-D = WS-DX * WS-DX + WS-DZ * WS-DZ
                 IF WS-PICK = 0 OR WS-D < WS-PICK-D
                     MOVE WS-D TO WS-PICK-D
                     MOVE WS-I TO WS-PICK
                 END-IF
             END-IF
         END-PERFORM
         MOVE 1 TO WS-STOP
         IF WS-PICK > 0
*>           the least distance a snapped position can have: the raw distance (rounded down) less 160 blocks
             COMPUTE WS-H = FUNCTION INTEGER(FUNCTION SQRT(WS-PICK-D))
             COMPUTE WS-LOW = WS-H - 160
             COMPUTE WS-D = WS-LOW * WS-LOW + WS-DY * WS-DY
             IF WS-BEST-I = 0 OR WS-LOW <= 0 OR WS-D <= WS-BEST
*>               the rows of the biome search this call may still do (0: all of them)
                 MOVE 0 TO WS-ALLOW
                 IF SD-SNAP-LIMIT > 0
                     COMPUTE WS-ALLOW = SD-SNAP-LIMIT - WS-ROWS-USED
                 END-IF
                 IF SD-SNAP-LIMIT > 0 AND WS-ALLOW <= 0
                     MOVE 1 TO SD-SNAP-PENDING
                 ELSE
                     CALL "STRUCT-RING-READY-ROWS" USING L-SET WS-ROW WS-PICK WS-ALLOW WS-ROWS-DONE WS-SNAP-DONE
                     ADD WS-ROWS-DONE TO WS-ROWS-USED
                     IF WS-SNAP-DONE = 0
                         MOVE 1 TO SD-SNAP-PENDING
                     ELSE
                         COMPUTE WS-DX = SR-X(WS-ROW, WS-PICK) * 16 + 8 - L-OX
                         COMPUTE WS-DZ = SR-Z(WS-ROW, WS-PICK) * 16 + 8 - L-OZ
                         COMPUTE WS-D = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                         IF WS-BEST-I = 0 OR WS-D < WS-BEST OR (WS-D = WS-BEST AND WS-PICK < WS-BEST-I)
                             MOVE WS-D TO WS-BEST
                             MOVE WS-PICK TO WS-BEST-I
                         END-IF
                         MOVE 0 TO WS-STOP
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST-I > 0
         MOVE 1 TO L-FOUND
         MOVE SR-X(WS-ROW, WS-BEST-I) TO L-CX
         MOVE SR-Z(WS-ROW, WS-BEST-I) TO L-CZ
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
