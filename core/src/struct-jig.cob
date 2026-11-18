*> The jigsaw assembly (docs/protocol/36-structures-3 sections 8 to 13 and 17; 36-structures-9 sections 5 and 6): JigsawStructure.findGenerationPoint and JigsawPlacement.addPieces with
*> tryPlacingChildren. A start is a pure function of the world seed and its chunk; it is rebuilt from them whenever a chunk needs it (STRUCT-DECORATE, 36-1 7), so the result is remembered
*> by structure, seed and chunk in a few slots (a rebuilt start is copied back, the same pieces and junctions).
*>
*> The pieces of a start are pieces of SP-TYPE 60 in the builder (STRUCTPIECE.cpy): SP-F1 the element row (STRUCT-JIG-POOLS), SP-F2 the ground level delta, SP-T-X..Z the position (the origin
*> of the element), SP-T-ROT the rotation, SP-T-LIQ 1 for ignore_waterlogging, SP-T-AUX the projection of the element (0 rigid, 1 terrain_matching), the box SP-X0..SP-Z1 the (possibly
*> expansion-enlarged) bounding box. The junctions are the rows of JJ (STRUCTJIG.cpy), owner the piece row.
*>
*> The free volume of 13 is a holder: a limit box and a list of removed boxes (a cell is free when it is inside the limit and in none of the removed boxes; a box is accepted only when
*> every one of its cells is free, 13.1). The global holder is the structure limit box minus the start piece, an interior jigsaw's holder the parent's own box (10.2 step 4, 10.5).
*> Deviations: the start height provider is the absolute one or a uniform one of two absolute anchors (36-10 2.2 step 1; start_jigsaw_name and the pool aliases are in struct-jig-alias.cob) and the heightmap one of the two the column query knows (WORLD_SURFACE_WG, OCEAN_FLOOR_WG); couldStructureExistInColumn (9.4 step 2) is not
*> asked on its own (the caller's biome test at the stub, which is in the column, implies it; the biome at the stub is asked here before the assembly so a start in the wrong biome
*> costs nothing); the dimension is the overworld (min y -64, max y 319); the surface of a column is the base height (STRUCT-BASE-HEIGHT kind 0, the noise terrain, no beardifier).
*>
*> Entry points:
*>   JIG-SURFACE USING x, z, kind (0 WORLD_SURFACE_WG, 1 OCEAN_FLOOR_WG), height out: getFirstFreeHeight (jig-surface.cob, a program of its own: a test links its own)
*>   STRUCT-JIG-READ USING JSON-DOC, structure row: the jigsaw fields of the structure file into SDT-JIG-*
*>   JIG-FIND-POINT USING structure row, seed (BINARY-DOUBLE), chunk x, chunk z, stub x out, stub y out, stub z out, valid out: the stub of 9.6 and the pieces in the builder (SPB-RESET first);
*>     valid 0 when there is no structure (size 0, an empty start element, a stub whose biome is not the structure's: JIG-BIOME-OK, jig-biome-ok.cob, a program of its own)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ASSEMBLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 COPY STRUCTTPL.
 COPY STRUCTALIAS.
 COPY STRUCTALIASMAP.
 78 H-MAX                  VALUE 400.
 78 R-MAX                  VALUE 4096.
 78 Q-MAX                  VALUE 1100.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-STRUCT-ROW          BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-MAX-Y               BINARY-LONG VALUE 319.
*> the start
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-POOL                BINARY-LONG.
 01 WS-PKEY                PIC X(80).
 01 WS-AKEY                PIC X(80).
 01 WS-PPX                 BINARY-LONG.
 01 WS-PPY                 BINARY-LONG.
 01 WS-PPZ                 BINARY-LONG.
 01 WS-OFFX                BINARY-LONG.
 01 WS-OFFY                BINARY-LONG.
 01 WS-OFFZ                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-CCX                 BINARY-LONG.
 01 WS-CCZ                 BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-SURF                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-MOVE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-PIECE-TYPE          BINARY-LONG VALUE 60.
 01 WS-ORIENT              BINARY-LONG VALUE -1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-NEW                 BINARY-LONG.
 01 WS-BOX.
    05 WB                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-NB.
    05 NB                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-BOX0.
    05 B0                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-SBOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==SBX-==.
*> holders: the limit box (inclusive) and the chain of removed boxes
 01 WS-HOLDERS.
    05 WH-COUNT            BINARY-LONG.
    05 WH-REC OCCURS 400 TIMES.
       10 WH-L             BINARY-LONG OCCURS 6 TIMES.
       10 WH-HEAD          BINARY-LONG.
 01 WS-REMOVED.
    05 WR-COUNT            BINARY-LONG.
    05 WR-REC OCCURS 4096 TIMES.
       10 WR-B             BINARY-LONG OCCURS 6 TIMES.
       10 WR-NEXT          BINARY-LONG.
 01 WS-HNEW                BINARY-LONG.
 01 WS-HLIM.
    05 HL                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-HID                 BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
*> the queue: entries with a priority, taken highest first and first in first out
 01 WS-QUEUE.
    05 WQ-COUNT            BINARY-LONG.
    05 WQ-SEQ              BINARY-LONG.
    05 WQ-REC OCCURS 1100 TIMES.
       10 WQ-PIECE         BINARY-LONG.
       10 WQ-HOLDER        BINARY-LONG.
       10 WQ-DEPTH         BINARY-LONG.
       10 WQ-PRIO          BINARY-LONG.
       10 WQ-ORDER         BINARY-LONG.
       10 WQ-LIVE          BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
*> the parent being expanded and its jigsaws
 01 WS-P                   BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-PRIGID              BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-PEL                 BINARY-LONG.
 01 WS-PJ-COUNT            BINARY-LONG.
 01 WS-PJ.
    05 PJ-REC OCCURS 128 TIMES.
       10 PJ-X             BINARY-LONG.
       10 PJ-Y             BINARY-LONG.
       10 PJ-Z             BINARY-LONG.
       10 PJ-FRONT         BINARY-LONG.
       10 PJ-TOP           BINARY-LONG.
       10 PJ-JOINT         BINARY-LONG.
       10 PJ-TAG           BINARY-LONG.
       10 PJ-PLACE         BINARY-LONG.
       10 PJ-SELECT        BINARY-LONG.
*> the jigsaw being served
 01 WS-J                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-SDX                 BINARY-LONG.
 01 WS-SDY                 BINARY-LONG.
 01 WS-SDZ                 BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-REL                 BINARY-LONG.
 01 WS-SURF-SET            BINARY-LONG.
 01 WS-POOLROW             BINARY-LONG.
 01 WS-FBROW               BINARY-LONG.
 01 WS-FH                  BINARY-LONG.
 01 WS-PRIO                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-SEG                 BINARY-LONG.
 01 WS-SEGLEN              BINARY-LONG.
 01 WS-CAND-COUNT          BINARY-LONG.
 01 WS-CANDS.
    05 WC                  BINARY-LONG OCCURS 2048 TIMES.
 01 WS-ROTS.
    05 WROT                BINARY-LONG OCCURS 4 TIMES.
 01 WS-C                   BINARY-LONG.
 01 WS-CI                  BINARY-LONG.
 01 WS-CEL                 BINARY-LONG.
 01 WS-RI                  BINARY-LONG.
 01 WS-CROT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TMP                 BINARY-LONG.
 01 WS-HACK                BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-TAGKEY              PIC X(48).
*> the candidate's jigsaws
 01 WS-CJ-COUNT            BINARY-LONG.
 01 WS-CJ.
    05 CJ-REC OCCURS 128 TIMES.
       10 CJ-X             BINARY-LONG.
       10 CJ-Y             BINARY-LONG.
       10 CJ-Z             BINARY-LONG.
       10 CJ-FRONT         BINARY-LONG.
       10 CJ-TOP           BINARY-LONG.
       10 CJ-JOINT         BINARY-LONG.
       10 CJ-TAG           BINARY-LONG.
       10 CJ-PLACE         BINARY-LONG.
       10 CJ-SELECT        BINARY-LONG.
*> the attachment
 01 WS-KJ                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-CRIGID              BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-YJ                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-GPARENT             BINARY-LONG.
 01 WS-GCHILD              BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CPROJ               BINARY-LONG.
 01 WS-JY                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID.
     GO TO MAIN-LINE.


*> the element WS-DRAW of the expanded list of the pool WS-POOL (the entries repeated by weight, in order)
 PICK-ELEMENT.
     MOVE WS-DRAW TO WS-K
     MOVE 1 TO WS-EL
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JP-N(WS-POOL) OR WS-DONE = 1
         IF WS-K < JN-WEIGHT(JP-FIRST(WS-POOL) + WS-I)
             MOVE JN-ELEM(JP-FIRST(WS-POOL) + WS-I) TO WS-EL
             MOVE 1 TO WS-DONE
         ELSE
             SUBTRACT JN-WEIGHT(JP-FIRST(WS-POOL) + WS-I) FROM WS-K
         END-IF
     END-PERFORM.

*> a piece of element WS-CEL at (WS-OX, WS-OY, WS-OZ) with rotation WS-CROT, ground delta WS-GROUND, box WS-BOX: the row in WS-CHILD
 ADD-PIECE.
     MOVE WB(1) TO SBX-X0
     MOVE WB(2) TO SBX-Y0
     MOVE WB(3) TO SBX-Z0
     MOVE WB(4) TO SBX-X1
     MOVE WB(5) TO SBX-Y1
     MOVE WB(6) TO SBX-Z1
     CALL "SPB-ADD" USING WS-PIECE-TYPE WS-ORIENT WS-ZERO WS-Z2 WS-SBOX WS-CHILD
     IF WS-CHILD > 0
         MOVE WS-CEL TO SP-F1(WS-CHILD)
         MOVE WS-GROUND TO SP-F2(WS-CHILD)
         MOVE WS-OX TO SP-T-X(WS-CHILD)
         MOVE WS-OY TO SP-T-Y(WS-CHILD)
         MOVE WS-OZ TO SP-T-Z(WS-CHILD)
         MOVE WS-CROT TO SP-T-ROT(WS-CHILD)
         MOVE SDT-JIG-LIQ(WS-STRUCT-ROW) TO SP-T-LIQ(WS-CHILD)
         MOVE JE-PROJ(WS-CEL) TO SP-T-AUX(WS-CHILD)
     END-IF.

 HOLDER-NEW.
     ADD 1 TO WH-COUNT
     MOVE WH-COUNT TO WS-HNEW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE HL(WS-I) TO WH-L(WS-HNEW, WS-I)
     END-PERFORM
     MOVE 0 TO WH-HEAD(WS-HNEW).

*> NB: a box; WS-HID: a holder: WS-FREE 1 when every cell of the box is free (inside the limit and in no removed box)
 CHECK-FREE.
     MOVE 1 TO WS-FREE
     IF NB(1) < WH-L(WS-HID, 1) OR NB(2) < WH-L(WS-HID, 2) OR NB(3) < WH-L(WS-HID, 3)
        OR NB(4) > WH-L(WS-HID, 4) OR NB(5) > WH-L(WS-HID, 5) OR NB(6) > WH-L(WS-HID, 6)
         MOVE 0 TO WS-FREE
     END-IF
     MOVE WH-HEAD(WS-HID) TO WS-R
     PERFORM UNTIL WS-R = 0 OR WS-FREE = 0
         IF NB(1) <= WR-B(WS-R, 4) AND NB(4) >= WR-B(WS-R, 1) AND NB(2) <= WR-B(WS-R, 5) AND NB(5) >= WR-B(WS-R, 2)
            AND NB(3) <= WR-B(WS-R, 6) AND NB(6) >= WR-B(WS-R, 3)
             MOVE 0 TO WS-FREE
         END-IF
         MOVE WR-NEXT(WS-R) TO WS-R
     END-PERFORM.

*> the box NB is taken out of the holder WS-HID
 RESERVE-BOX.
     ADD 1 TO WR-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE NB(WS-I) TO WR-B(WR-COUNT, WS-I)
     END-PERFORM
     MOVE WH-HEAD(WS-HID) TO WR-NEXT(WR-COUNT)
     MOVE WR-COUNT TO WH-HEAD(WS-HID).

*> the queue entry of the highest priority, the oldest of them: WS-BEST its row (0 when none is live)
 POP-QUEUE.
     MOVE 0 TO WS-BEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WQ-COUNT
         IF WQ-LIVE(WS-I) = 1
             IF WS-BEST = 0
                 MOVE WS-I TO WS-BEST
             ELSE
                 IF WQ-PRIO(WS-I) > WQ-PRIO(WS-BEST)
                     MOVE WS-I TO WS-BEST
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST = 0
         MOVE 0 TO WQ-COUNT
     END-IF.

*> the steps of the direction WS-F
 SET-STEP.
     MOVE 0 TO WS-SDX WS-SDY WS-SDZ
     EVALUATE WS-F
         WHEN 0
             MOVE -1 TO WS-SDY
         WHEN 1
             MOVE 1 TO WS-SDY
         WHEN 2
             MOVE -1 TO WS-SDZ
         WHEN 3
             MOVE 1 TO WS-SDZ
         WHEN 4
             MOVE -1 TO WS-SDX
         WHEN OTHER
             MOVE 1 TO WS-SDX
     END-EVALUATE.

*> 10: the parent WS-P (depth WS-DEPTH, free holder WS-GH): every jigsaw in the shuffled order of 4.3
 PLACE-CHILDREN.
     MOVE SP-F1(WS-P) TO WS-PEL
     MOVE SP-Y0(WS-P) TO WS-Y0
     MOVE 0 TO WS-OWN
     IF JE-PROJ(WS-PEL) = 0
         MOVE 1 TO WS-PRIGID
     ELSE
         MOVE 0 TO WS-PRIGID
     END-IF
     CALL "JIG-EL-JIGS" USING WS-PEL SP-T-X(WS-P) SP-T-Y(WS-P) SP-T-Z(WS-P) SP-T-ROT(WS-P)
     MOVE JW-COUNT TO WS-PJ-COUNT
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-PJ-COUNT
         MOVE JW-REC(WS-J) TO PJ-REC(WS-J)
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-PJ-COUNT
         PERFORM SERVE-JIGSAW
     END-PERFORM.

*> 10.2: the jigsaw WS-J of the parent
 SERVE-JIGSAW.
     MOVE PJ-FRONT(WS-J) TO WS-F
     PERFORM SET-STEP
     COMPUTE WS-TX = PJ-X(WS-J) + WS-SDX
     COMPUTE WS-TY = PJ-Y(WS-J) + WS-SDY
     COMPUTE WS-TZ = PJ-Z(WS-J) + WS-SDZ
     COMPUTE WS-REL = PJ-Y(WS-J) - WS-Y0
     MOVE 0 TO WS-SURF-SET
     MOVE "minecraft:empty" TO WS-PKEY
     IF PJ-TAG(WS-J) > 0
         MOVE TN-POOL(PJ-TAG(WS-J)) TO WS-PKEY
     END-IF
*>   the pool field of a jigsaw block goes through the alias lookup (36-10 2.6; the identity without bindings)
     CALL "JIG-ALIAS-LOOKUP" USING JIG-ALIAS-MAP WS-PKEY WS-AKEY
     MOVE WS-AKEY TO WS-PKEY
     CALL "JIG-POOL-FIND" USING WS-PKEY WS-POOLROW
     IF WS-POOLROW = 0
         EXIT PARAGRAPH
     END-IF
     IF JP-TOTAL(WS-POOLROW) = 0 AND WS-POOLROW NOT = 1
         EXIT PARAGRAPH
     END-IF
     MOVE JP-FALLBACK(WS-POOLROW) TO WS-FBROW
     IF JP-TOTAL(WS-FBROW) = 0 AND WS-FBROW NOT = 1
         EXIT PARAGRAPH
     END-IF
*>   step 4: the free volume of this jigsaw
     IF WS-TX >= SP-X0(WS-P) AND WS-TX <= SP-X1(WS-P) AND WS-TY >= SP-Y0(WS-P) AND WS-TY <= SP-Y1(WS-P)
        AND WS-TZ >= SP-Z0(WS-P) AND WS-TZ <= SP-Z1(WS-P)
         IF WS-OWN = 0
             MOVE SP-X0(WS-P) TO HL(1)
             MOVE SP-Y0(WS-P) TO HL(2)
             MOVE SP-Z0(WS-P) TO HL(3)
             MOVE SP-X1(WS-P) TO HL(4)
             MOVE SP-Y1(WS-P) TO HL(5)
             MOVE SP-Z1(WS-P) TO HL(6)
             PERFORM HOLDER-NEW
             MOVE WS-HNEW TO WS-OWN
         END-IF
         MOVE WS-OWN TO WS-FH
     ELSE
         MOVE WS-GH TO WS-FH
     END-IF
*>   step 5: the candidates, the pool then the fallback, each shuffled
     MOVE 0 TO WS-CAND-COUNT
     IF WS-DEPTH NOT = SDT-JIG-SIZE(WS-STRUCT-ROW)
         MOVE WS-POOLROW TO WS-SEG
         PERFORM EXPAND-SHUFFLE
     END-IF
     MOVE WS-FBROW TO WS-SEG
     PERFORM EXPAND-SHUFFLE
     MOVE PJ-PLACE(WS-J) TO WS-PRIO
*>   step 7: the candidates in order until one is attached; the empty element stops the search
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-CI FROM 1 BY 1 UNTIL WS-CI > WS-CAND-COUNT OR WS-DONE NOT = 0
         MOVE WC(WS-CI) TO WS-C
         IF JE-KIND(WS-C) = 5
             MOVE 2 TO WS-DONE
         ELSE
             PERFORM TRY-CANDIDATE
         END-IF
     END-PERFORM.

*> appends the expanded list of the pool WS-SEG (entries repeated by weight) to WC and shuffles that run (Util.shuffle)
 EXPAND-SHUFFLE.
     MOVE WS-CAND-COUNT TO WS-N
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JP-N(WS-SEG)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > JN-WEIGHT(JP-FIRST(WS-SEG) + WS-I)
             ADD 1 TO WS-CAND-COUNT
             MOVE JN-ELEM(JP-FIRST(WS-SEG) + WS-I) TO WC(WS-CAND-COUNT)
         END-PERFORM
     END-PERFORM
     COMPUTE WS-SEGLEN = WS-CAND-COUNT - WS-N
     PERFORM VARYING WS-I FROM WS-SEGLEN BY -1 UNTIL WS-I < 2
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-I WS-K
         MOVE WC(WS-N + WS-I) TO WS-TMP
         MOVE WC(WS-N + WS-K + 1) TO WC(WS-N + WS-I)
         MOVE WS-TMP TO WC(WS-N + WS-K + 1)
     END-PERFORM.

*> 10.2 step 7: every rotation of the candidate WS-C in a shuffled order (WS-DONE 1 once an attachment was made)
 TRY-CANDIDATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WROT(WS-I) = WS-I - 1
     END-PERFORM
     PERFORM VARYING WS-I FROM 4 BY -1 UNTIL WS-I < 2
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-I WS-K
         MOVE WROT(WS-I) TO WS-TMP
         MOVE WROT(WS-K + 1) TO WROT(WS-I)
         MOVE WS-TMP TO WROT(WS-K + 1)
     END-PERFORM
     PERFORM VARYING WS-RI FROM 1 BY 1 UNTIL WS-RI > 4 OR WS-DONE = 1
         MOVE WROT(WS-RI) TO WS-CROT
         CALL "JIG-EL-JIGS" USING WS-C WS-ZERO WS-Z2 WS-Z3 WS-CROT
         MOVE JW-COUNT TO WS-CJ-COUNT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CJ-COUNT
             MOVE JW-REC(WS-K) TO CJ-REC(WS-K)
         END-PERFORM
         CALL "JIG-EL-BOX" USING WS-C WS-ZERO WS-Z2 WS-Z3 WS-CROT WS-BOX0
         PERFORM COMPUTE-HACK
         PERFORM VARYING WS-KJ FROM 1 BY 1 UNTIL WS-KJ > WS-CJ-COUNT OR WS-DONE = 1
             PERFORM CAN-ATTACH
             IF WS-OK = 1
                 PERFORM TRY-ATTACH
             END-IF
         END-PERFORM
     END-PERFORM.

*> 10.4: the height h that the inward jigsaws of the candidate could bring (0 without the hack or for an element over 16 high)
 COMPUTE-HACK.
     MOVE 0 TO WS-HACK
     IF SDT-JIG-HACK(WS-STRUCT-ROW) = 1 AND B0(5) - B0(2) + 1 <= 16
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CJ-COUNT
             MOVE CJ-FRONT(WS-K) TO WS-F
             PERFORM SET-STEP
             COMPUTE WS-FX = CJ-X(WS-K) + WS-SDX
             COMPUTE WS-FY = CJ-Y(WS-K) + WS-SDY
             COMPUTE WS-FZ = CJ-Z(WS-K) + WS-SDZ
             IF WS-FX >= B0(1) AND WS-FX <= B0(4) AND WS-FY >= B0(2) AND WS-FY <= B0(5) AND WS-FZ >= B0(3) AND WS-FZ <= B0(6)
                 MOVE "minecraft:empty" TO WS-PKEY
                 IF CJ-TAG(WS-K) > 0
                     MOVE TN-POOL(CJ-TAG(WS-K)) TO WS-PKEY
                 END-IF
                 CALL "JIG-ALIAS-LOOKUP" USING JIG-ALIAS-MAP WS-PKEY WS-AKEY
                 MOVE WS-AKEY TO WS-PKEY
                 CALL "JIG-POOL-FIND" USING WS-PKEY WS-MS
                 IF WS-MS > 0
                     CALL "JIG-POOL-MAXSIZE" USING WS-MS WS-N
                     MOVE FUNCTION MAX(WS-HACK, WS-N) TO WS-HACK
                     MOVE JP-FALLBACK(WS-MS) TO WS-MS
                     CALL "JIG-POOL-MAXSIZE" USING WS-MS WS-N
                     MOVE FUNCTION MAX(WS-HACK, WS-N) TO WS-HACK
                 END-IF
             END-IF
         END-PERFORM
     END-IF.


*> 4.1: WS-OK 1 when the parent's jigsaw WS-J can attach the candidate's WS-KJ (front opposite, the parent's joint rollable or the tops equal, the name matches the target)
 CAN-ATTACH.
     MOVE 0 TO WS-OK
     COMPUTE WS-TMP = PJ-FRONT(WS-J) + 1 - 2 * FUNCTION MOD(PJ-FRONT(WS-J), 2)
     IF CJ-FRONT(WS-KJ) = WS-TMP
         IF PJ-JOINT(WS-J) = 2 OR PJ-TOP(WS-J) = CJ-TOP(WS-KJ)
             IF CJ-TAG(WS-KJ) = 0
                 MOVE 1 TO WS-OK
             ELSE
                 MOVE "minecraft:empty" TO WS-TAGKEY
                 IF PJ-TAG(WS-J) > 0
                     MOVE TN-TARGET(PJ-TAG(WS-J)) TO WS-TAGKEY
                 END-IF
                 IF WS-TAGKEY = TN-NAME(CJ-TAG(WS-KJ))
                     MOVE 1 TO WS-OK
                 END-IF
             END-IF
         END-IF
     END-IF.

*> 10.3: the candidate WS-C at rotation WS-CROT attached through its jigsaw WS-KJ to the parent's WS-J
 TRY-ATTACH.
     COMPUTE WS-OX = WS-TX - CJ-X(WS-KJ)
     COMPUTE WS-OY = WS-TY - CJ-Y(WS-KJ)
     COMPUTE WS-OZ = WS-TZ - CJ-Z(WS-KJ)
     CALL "JIG-EL-BOX" USING WS-C WS-OX WS-OY WS-OZ WS-CROT WS-BOX
     MOVE CJ-Y(WS-KJ) TO WS-QY
     MOVE PJ-FRONT(WS-J) TO WS-F
     PERFORM SET-STEP
     IF JE-PROJ(WS-C) = 0
         MOVE 1 TO WS-CRIGID
     ELSE
         MOVE 0 TO WS-CRIGID
     END-IF
     COMPUTE WS-D = WS-REL - WS-QY + WS-SDY
     IF WS-PRIGID = 1 AND WS-CRIGID = 1
         COMPUTE WS-YJ = WS-Y0 + WS-D
     ELSE
         PERFORM FIND-SURFACE
         COMPUTE WS-YJ = WS-SURF - WS-QY
     END-IF
     COMPUTE WS-DY = WS-YJ - WB(2)
     ADD WS-DY TO WB(2)
     ADD WS-DY TO WB(5)
     ADD WS-DY TO WS-OY
*>   the expansion: the box reaches h + 1 above its bottom at least
     IF WS-HACK > 0
         COMPUTE WS-K = FUNCTION MAX(WS-HACK + 1, WB(5) - WB(2))
         MOVE FUNCTION MAX(WB(5), WB(2) + WS-K) TO WB(5)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WB(WS-I) TO NB(WS-I)
     END-PERFORM
     MOVE WS-FH TO WS-HID
     PERFORM CHECK-FREE
     IF WS-FREE = 1
         PERFORM RESERVE-BOX
         MOVE SP-F2(WS-P) TO WS-GPARENT
         IF WS-CRIGID = 1
             COMPUTE WS-GCHILD = WS-GPARENT - WS-D
         ELSE
             MOVE 1 TO WS-GCHILD
         END-IF
*>       the junction ground height G (10.3 step 10)
         IF WS-PRIGID = 1
             COMPUTE WS-G = WS-Y0 + WS-REL
         ELSE
             IF WS-CRIGID = 1
                 COMPUTE WS-G = WS-YJ + WS-QY
             ELSE
                 PERFORM FIND-SURFACE
                 DIVIDE WS-D BY 2 GIVING WS-HALF
                 COMPUTE WS-G = WS-SURF + WS-HALF
             END-IF
         END-IF
         MOVE WS-C TO WS-CEL
         MOVE WS-GCHILD TO WS-GROUND
         PERFORM ADD-PIECE
         IF WS-CHILD > 0
             MOVE WS-TX TO WS-FX
             COMPUTE WS-FY = WS-G - WS-REL + WS-GPARENT
             MOVE WS-TZ TO WS-FZ
             MOVE JE-PROJ(WS-C) TO WS-CPROJ
             MOVE WS-P TO WS-HNEW
             PERFORM ADD-JUNCTION
             MOVE PJ-X(WS-J) TO WS-FX
             COMPUTE WS-FY = WS-G - WS-QY + WS-GCHILD
             MOVE PJ-Z(WS-J) TO WS-FZ
             MOVE JE-PROJ(WS-PEL) TO WS-CPROJ
             COMPUTE WS-D = 0 - WS-D
             MOVE WS-CHILD TO WS-HNEW
             PERFORM ADD-JUNCTION
             IF WS-DEPTH + 1 <= SDT-JIG-SIZE(WS-STRUCT-ROW) AND WQ-COUNT < Q-MAX
                 ADD 1 TO WQ-COUNT
                 MOVE WS-CHILD TO WQ-PIECE(WQ-COUNT)
                 MOVE WS-FH TO WQ-HOLDER(WQ-COUNT)
                 COMPUTE WQ-DEPTH(WQ-COUNT) = WS-DEPTH + 1
                 MOVE WS-PRIO TO WQ-PRIO(WQ-COUNT)
                 MOVE 1 TO WQ-LIVE(WQ-COUNT)
             END-IF
         END-IF
         MOVE 1 TO WS-DONE
     END-IF.

*> the first free height of the column of the parent's jigsaw (WORLD_SURFACE_WG, whatever the structure's own heightmap), asked once per jigsaw
 FIND-SURFACE.
     IF WS-SURF-SET = 0
         MOVE 0 TO WS-KIND
         CALL "JIG-SURFACE" USING PJ-X(WS-J) PJ-Z(WS-J) WS-KIND WS-SURF
         MOVE 1 TO WS-SURF-SET
     END-IF.

*> a junction of the piece WS-HNEW: source (WS-FX, WS-FY, WS-FZ), delta WS-D, destination projection WS-CPROJ
 ADD-JUNCTION.
     IF JJ-COUNT < JJ-MAX
         ADD 1 TO JJ-COUNT
         MOVE WS-HNEW TO JJ-OWNER(JJ-COUNT)
         MOVE WS-FX TO JJ-X(JJ-COUNT)
         MOVE WS-FY TO JJ-Y(JJ-COUNT)
         MOVE WS-FZ TO JJ-Z(JJ-COUNT)
         MOVE WS-D TO JJ-DELTA(JJ-COUNT)
         MOVE WS-CPROJ TO JJ-PROJ(JJ-COUNT)
     END-IF.

 MAIN-LINE.
     MOVE 0 TO L-VALID
     MOVE L-STRUCT TO WS-STRUCT-ROW
     MOVE 0 TO JJ-COUNT
     CALL "SPB-RESET"
     COMPUTE L-X = L-CX * 16 + 8
     MOVE 0 TO L-Y
     COMPUTE L-Z = L-CZ * 16 + 8
     IF SDT-JIG-OK(L-STRUCT) = 0
         GOBACK
     END-IF
*>   8.2: the start random and the start position (the chunk's minimum corner at the start height)
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED L-CX L-CZ
     COMPUTE WS-PX = L-CX * 16
     MOVE SDT-JIG-Y(L-STRUCT) TO WS-PY
     COMPUTE WS-PZ = L-CZ * 16
*>   36-10 2.2 step 1: a uniform start height draws once (a constant draws nothing); step 3: the alias lookup of this start
     IF SDA-Y-KIND(L-STRUCT) = 1
         COMPUTE WS-BOUND = SDA-Y-MAX(L-STRUCT) - SDA-Y-MIN(L-STRUCT) + 1
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         COMPUTE WS-PY = SDA-Y-MIN(L-STRUCT) + WS-DRAW
     END-IF
     CALL "JIG-ALIAS-BUILD" USING L-STRUCT WS-PX WS-PY WS-PZ L-SEED JIG-ALIAS-MAP
*>   9.1 and 9.2: the rotation, then the start element (one draw over the expanded list)
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
     CALL "JIG-ALIAS-LOOKUP" USING JIG-ALIAS-MAP SDT-JIG-POOL(L-STRUCT) WS-PKEY
     CALL "JIG-POOL-FIND" USING WS-PKEY WS-POOL
*>   2.2 step 5: an aliased key that is not registered falls back to the declared pool
     IF WS-POOL = 0 AND WS-PKEY NOT = SDT-JIG-POOL(L-STRUCT)
         MOVE SDT-JIG-POOL(L-STRUCT) TO WS-PKEY
         CALL "JIG-POOL-FIND" USING WS-PKEY WS-POOL
     END-IF
     IF WS-POOL = 0
         GOBACK
     END-IF
     IF JP-TOTAL(WS-POOL) = 0
         GOBACK
     END-IF
     MOVE JP-TOTAL(WS-POOL) TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     PERFORM PICK-ELEMENT
     IF JE-KIND(WS-EL) = 5
         GOBACK
     END-IF
*>   2.2 step 7 and 8: with a start jigsaw name the element's jigsaw of that name (in the shuffled order of 4.3) lands on the origin, so the piece position is the origin minus its offset
     MOVE 0 TO WS-OFFX WS-OFFY WS-OFFZ
     IF SDA-START(L-STRUCT) NOT = SPACES
         CALL "JIG-EL-JIGS" USING WS-EL WS-PX WS-PY WS-PZ WS-ROT
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JW-COUNT OR WS-FOUND > 0
             IF JW-TAG(WS-I) > 0
                 IF TN-NAME(JW-TAG(WS-I)) = SDA-START(L-STRUCT)
                     MOVE WS-I TO WS-FOUND
                 END-IF
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             GOBACK
         END-IF
         COMPUTE WS-OFFX = JW-X(WS-FOUND) - WS-PX
         COMPUTE WS-OFFY = JW-Y(WS-FOUND) - WS-PY
         COMPUTE WS-OFFZ = JW-Z(WS-FOUND) - WS-PZ
     END-IF
     COMPUTE WS-PPX = WS-PX - WS-OFFX
     COMPUTE WS-PPY = WS-PY - WS-OFFY
     COMPUTE WS-PPZ = WS-PZ - WS-OFFZ
*>   9.3 and 9.4: the box at the piece position, its centre, the height of the heightmap (or the piece's) and the move that puts the ground layer on it
     CALL "JIG-EL-BOX" USING WS-EL WS-PPX WS-PPY WS-PPZ WS-ROT WS-BOX
     COMPUTE WS-CCX = (WB(4) + WB(1)) / 2
     COMPUTE WS-CCZ = (WB(6) + WB(3)) / 2
     MOVE WS-PPY TO WS-Y
     IF SDT-JIG-PROJ(L-STRUCT) >= 0
         MOVE SDT-JIG-PROJ(L-STRUCT) TO WS-KIND
         CALL "JIG-SURFACE" USING WS-CCX WS-CCZ WS-KIND WS-SURF
         COMPUTE WS-Y = WS-PY + WS-SURF
     END-IF
     COMPUTE WS-MOVE = WS-Y - (WB(2) + 1)
     ADD WS-MOVE TO WB(2)
     ADD WS-MOVE TO WB(5)
     MOVE WS-CCX TO L-X
     COMPUTE L-Y = WS-Y + WS-OFFY
     MOVE WS-CCZ TO L-Z
*>   9.7 step 1: no pieces at all for a size of 0; and the stub's biome (5.3) before the work of the expansion
     IF SDT-JIG-SIZE(L-STRUCT) <= 0
         GOBACK
     END-IF
     CALL "JIG-BIOME-OK" USING L-STRUCT L-X L-Y L-Z WS-FLAG
     IF WS-FLAG = 0
         GOBACK
     END-IF
     MOVE 1 TO L-VALID
     MOVE WS-EL TO WS-CEL
     COMPUTE WS-OY = WS-PPY + WS-MOVE
     MOVE 1 TO WS-GROUND
     MOVE WS-PPX TO WS-OX
     MOVE WS-PPZ TO WS-OZ
     MOVE WS-ROT TO WS-CROT
     PERFORM ADD-PIECE
     MOVE WS-CHILD TO WS-P
*>   9.7 step 2 and 13.2: the structure's free volume
     MOVE 0 TO WH-COUNT WR-COUNT WQ-COUNT WQ-SEQ
     COMPUTE HL(1) = WS-CCX - SDT-JIG-HOR(L-STRUCT)
     COMPUTE HL(2) = FUNCTION MAX(L-Y - SDT-JIG-VER(L-STRUCT), WS-MIN-Y + SDT-JIG-PADB(L-STRUCT))
     COMPUTE HL(3) = WS-CCZ - SDT-JIG-HOR(L-STRUCT)
     COMPUTE HL(4) = WS-CCX + SDT-JIG-HOR(L-STRUCT)
     COMPUTE HL(5) = FUNCTION MIN(L-Y + SDT-JIG-VER(L-STRUCT), WS-MAX-Y - SDT-JIG-PADT(L-STRUCT))
     COMPUTE HL(6) = WS-CCZ + SDT-JIG-HOR(L-STRUCT)
     PERFORM HOLDER-NEW
     MOVE WS-HNEW TO WS-GH
     MOVE WS-GH TO WS-HID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WB(WS-I) TO NB(WS-I)
     END-PERFORM
     PERFORM RESERVE-BOX
*>   10 and 11: the start piece is expanded at depth 0, then the queue until it is empty
     MOVE 0 TO WS-DEPTH
     PERFORM PLACE-CHILDREN
     PERFORM UNTIL WQ-COUNT = 0
         PERFORM POP-QUEUE
         IF WS-BEST > 0
             MOVE WQ-PIECE(WS-BEST) TO WS-P
             MOVE WQ-HOLDER(WS-BEST) TO WS-GH
             MOVE WQ-DEPTH(WS-BEST) TO WS-DEPTH
             MOVE 0 TO WQ-LIVE(WS-BEST)
             PERFORM PLACE-CHILDREN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM JIG-ASSEMBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-FIND-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 COPY STRUCTTPL.
 COPY CTWORLDGEN.
 COPY NOISE.
 78 MS-SLOTS               VALUE 12.
 78 MS-PIECES              VALUE 400.
 78 MS-JUNCS               VALUE 1200.
 01 WS-MEMO.
    05 MS-NEXT             BINARY-LONG VALUE 0.
    05 MS-REC OCCURS 12 TIMES.
       10 MS-USED          BINARY-LONG VALUE 0.
       10 MS-STRUCT        BINARY-LONG.
       10 MS-SEED          BINARY-DOUBLE.
       10 MS-CX            BINARY-LONG.
       10 MS-CZ            BINARY-LONG.
       10 MS-STAMP         BINARY-LONG.
       10 MS-GEN           BINARY-LONG.
       10 MS-X             BINARY-LONG.
       10 MS-Y             BINARY-LONG.
       10 MS-Z             BINARY-LONG.
       10 MS-N             BINARY-LONG.
       10 MS-JN            BINARY-LONG.
 01 WS-PIECES.
    05 MP-REC OCCURS 4800 TIMES.
       10 MP-EL            BINARY-LONG.
       10 MP-X             BINARY-LONG.
       10 MP-Y             BINARY-LONG.
       10 MP-Z             BINARY-LONG.
       10 MP-ROT           BINARY-LONG.
       10 MP-GROUND        BINARY-LONG.
       10 MP-LIQ           BINARY-LONG.
       10 MP-AUX           BINARY-LONG.
       10 MP-B             BINARY-LONG OCCURS 6 TIMES.
 01 WS-JUNCS.
    05 MJ-REC OCCURS 14400 TIMES.
       10 MJ-OWNER         BINARY-LONG.
       10 MJ-X             BINARY-LONG.
       10 MJ-Y             BINARY-LONG.
       10 MJ-Z             BINARY-LONG.
       10 MJ-DELTA         BINARY-LONG.
       10 MJ-PROJ          BINARY-LONG.
 01 WS-STAMP-NOW           BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-JBASE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 60.
 01 WS-ORIENT              BINARY-LONG VALUE -1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID.
     GO TO MAIN-LINE.


 STORE.
     COMPUTE WS-SLOT = FUNCTION MOD(MS-NEXT, MS-SLOTS) + 1
     ADD 1 TO MS-NEXT
     MOVE 1 TO MS-USED(WS-SLOT)
     MOVE L-STRUCT TO MS-STRUCT(WS-SLOT)
     MOVE L-SEED TO MS-SEED(WS-SLOT)
     MOVE L-CX TO MS-CX(WS-SLOT)
     MOVE L-CZ TO MS-CZ(WS-SLOT)
     MOVE WS-STAMP-NOW TO MS-STAMP(WS-SLOT)
     MOVE JIG-GEN TO MS-GEN(WS-SLOT)
     MOVE L-X TO MS-X(WS-SLOT)
     MOVE L-Y TO MS-Y(WS-SLOT)
     MOVE L-Z TO MS-Z(WS-SLOT)
     MOVE SP-COUNT TO MS-N(WS-SLOT)
     MOVE JJ-COUNT TO MS-JN(WS-SLOT)
     COMPUTE WS-BASE = (WS-SLOT - 1) * MS-PIECES
     COMPUTE WS-JBASE = (WS-SLOT - 1) * MS-JUNCS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         COMPUTE WS-K = WS-BASE + WS-I
         MOVE SP-F1(WS-I) TO MP-EL(WS-K)
         MOVE SP-T-X(WS-I) TO MP-X(WS-K)
         MOVE SP-T-Y(WS-I) TO MP-Y(WS-K)
         MOVE SP-T-Z(WS-I) TO MP-Z(WS-K)
         MOVE SP-T-ROT(WS-I) TO MP-ROT(WS-K)
         MOVE SP-F2(WS-I) TO MP-GROUND(WS-K)
         MOVE SP-T-LIQ(WS-I) TO MP-LIQ(WS-K)
         MOVE SP-T-AUX(WS-I) TO MP-AUX(WS-K)
         MOVE SP-X0(WS-I) TO MP-B(WS-K, 1)
         MOVE SP-Y0(WS-I) TO MP-B(WS-K, 2)
         MOVE SP-Z0(WS-I) TO MP-B(WS-K, 3)
         MOVE SP-X1(WS-I) TO MP-B(WS-K, 4)
         MOVE SP-Y1(WS-I) TO MP-B(WS-K, 5)
         MOVE SP-Z1(WS-I) TO MP-B(WS-K, 6)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JJ-COUNT
         COMPUTE WS-K = WS-JBASE + WS-I
         MOVE JJ-OWNER(WS-I) TO MJ-OWNER(WS-K)
         MOVE JJ-X(WS-I) TO MJ-X(WS-K)
         MOVE JJ-Y(WS-I) TO MJ-Y(WS-K)
         MOVE JJ-Z(WS-I) TO MJ-Z(WS-K)
         MOVE JJ-DELTA(WS-I) TO MJ-DELTA(WS-K)
         MOVE JJ-PROJ(WS-I) TO MJ-PROJ(WS-K)
     END-PERFORM.

 RESTORE.
     CALL "SPB-RESET"
     COMPUTE WS-BASE = (WS-SLOT - 1) * MS-PIECES
     COMPUTE WS-JBASE = (WS-SLOT - 1) * MS-JUNCS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MS-N(WS-SLOT)
         COMPUTE WS-K = WS-BASE + WS-I
         MOVE MP-B(WS-K, 1) TO B-X0
         MOVE MP-B(WS-K, 2) TO B-Y0
         MOVE MP-B(WS-K, 3) TO B-Z0
         MOVE MP-B(WS-K, 4) TO B-X1
         MOVE MP-B(WS-K, 5) TO B-Y1
         MOVE MP-B(WS-K, 6) TO B-Z1
         CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-ZERO WS-Z2 WS-BOX WS-ROW
         MOVE MP-EL(WS-K) TO SP-F1(WS-ROW)
         MOVE MP-GROUND(WS-K) TO SP-F2(WS-ROW)
         MOVE MP-X(WS-K) TO SP-T-X(WS-ROW)
         MOVE MP-Y(WS-K) TO SP-T-Y(WS-ROW)
         MOVE MP-Z(WS-K) TO SP-T-Z(WS-ROW)
         MOVE MP-ROT(WS-K) TO SP-T-ROT(WS-ROW)
         MOVE MP-LIQ(WS-K) TO SP-T-LIQ(WS-ROW)
         MOVE MP-AUX(WS-K) TO SP-T-AUX(WS-ROW)
     END-PERFORM
     MOVE MS-JN(WS-SLOT) TO JJ-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JJ-COUNT
         COMPUTE WS-K = WS-JBASE + WS-I
         MOVE MJ-OWNER(WS-K) TO JJ-OWNER(WS-I)
         MOVE MJ-X(WS-K) TO JJ-X(WS-I)
         MOVE MJ-Y(WS-K) TO JJ-Y(WS-I)
         MOVE MJ-Z(WS-K) TO JJ-Z(WS-I)
         MOVE MJ-DELTA(WS-K) TO JJ-DELTA(WS-I)
         MOVE MJ-PROJ(WS-K) TO JJ-PROJ(WS-I)
     END-PERFORM
     MOVE MS-X(WS-SLOT) TO L-X
     MOVE MS-Y(WS-SLOT) TO L-Y
     MOVE MS-Z(WS-SLOT) TO L-Z
     MOVE 1 TO L-VALID.

 MAIN-LINE.
*>   the remembered starts belong to one world and one cache epoch (the content and noise generation, the jigsaw tables)
     COMPUTE WS-STAMP-NOW = WG-LOAD-GEN + NZ-GEN
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MS-SLOTS OR WS-SLOT > 0
         IF MS-USED(WS-I) = 1 AND MS-STRUCT(WS-I) = L-STRUCT AND MS-SEED(WS-I) = L-SEED AND MS-CX(WS-I) = L-CX AND MS-CZ(WS-I) = L-CZ
            AND MS-STAMP(WS-I) = WS-STAMP-NOW AND MS-GEN(WS-I) = JIG-GEN
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT > 0
         PERFORM RESTORE
         GOBACK
     END-IF
*>   the tables are emptied between starts when they are getting full (the rows of a start in the builder are not used after it is placed)
     IF TP-COUNT > 100 OR TP-USED > 250000 OR TN-USED > 5000 OR JE-COUNT > 1400 OR JP-COUNT > 130 OR JN-USED > 3000 OR JS-COUNT > 400
         CALL "STRUCT-TPL-RESET"
         CALL "JIG-RESET"
     END-IF
     CALL "JIG-ASSEMBLE" USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID
     IF L-VALID = 1 AND SP-COUNT <= MS-PIECES AND JJ-COUNT <= MS-JUNCS
         PERFORM STORE
     END-IF
     GOBACK.
 END PROGRAM JIG-FIND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-JIG-READ.
*> USING JSON-DOC (the structure's file), structure row: the jigsaw fields of 3.1 into SDT-JIG-*: start_pool, size, start_height (the absolute provider), project_start_to_heightmap (-1 absent,
*> 0 WORLD_SURFACE_WG, 1 OCEAN_FLOOR_WG), use_expansion_hack, max_distance_from_center (an int is a cube, an object has horizontal and vertical, the latter 4064 by default),
*> dimension_padding (an int or bottom and top), liquid_settings, and through STRUCT-ALIAS-READ (struct-jig-alias.cob) the start_jigsaw_name, the uniform start height and the pool aliases.
*> SDT-JIG-OK is 1 for a jigsaw structure the assembler can build; 0 for any other type and for a jigsaw structure with a start height of another provider, a malformed alias or a heightmap the
*> column query does not know.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTALIAS.
 01 WS-AOK                 BINARY-LONG.
 01 WS-KIND-TYPE           BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(40).
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-NODE                BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 K-POOL                 PIC X(40) VALUE "start_pool".
 01 K-SIZE                 PIC X(40) VALUE "size".
 01 K-HEIGHT               PIC X(40) VALUE "start_height".
 01 K-ABSOLUTE             PIC X(40) VALUE "absolute".
 01 K-PROJECT              PIC X(40) VALUE "project_start_to_heightmap".
 01 K-HACK                 PIC X(40) VALUE "use_expansion_hack".
 01 K-DISTANCE             PIC X(40) VALUE "max_distance_from_center".
 01 K-HORIZONTAL           PIC X(40) VALUE "horizontal".
 01 K-VERTICAL             PIC X(40) VALUE "vertical".
 01 K-PADDING              PIC X(40) VALUE "dimension_padding".
 01 K-BOTTOM               PIC X(40) VALUE "bottom".
 01 K-TOP                  PIC X(40) VALUE "top".
 01 K-LIQUID               PIC X(40) VALUE "liquid_settings".
 01 K-ALIASES              PIC X(40) VALUE "pool_aliases".
 01 K-START-NAME           PIC X(40) VALUE "start_jigsaw_name".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ROW.
     MOVE SPACES TO SDT-JIG-POOL(L-ROW)
     MOVE 0 TO SDT-JIG-OK(L-ROW) SDT-JIG-SIZE(L-ROW) SDT-JIG-Y(L-ROW) SDT-JIG-HACK(L-ROW) SDT-JIG-HOR(L-ROW) SDT-JIG-PADB(L-ROW) SDT-JIG-PADT(L-ROW)
         SDT-JIG-LIQ(L-ROW)
     MOVE -1 TO SDT-JIG-PROJ(L-ROW)
     MOVE 4064 TO SDT-JIG-VER(L-ROW)
     CALL "STRUCT-ENUM-NAME" USING WS-KIND-TYPE SDT-TYPE(L-ROW) WS-NAME
     IF WS-NAME NOT = "jigsaw"
         GOBACK
     END-IF
     MOVE 1 TO SDT-JIG-OK(L-ROW)
     CALL "FD-J-STRING" USING JSON-DOC K-POOL 1 WS-TEXT WS-LEN
     CALL "FD-KEY" USING WS-TEXT WS-KEY
     MOVE WS-KEY TO SDT-JIG-POOL(L-ROW)
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-SIZE WS-NODE
     CALL "FD-J-INT" USING JSON-DOC WS-NODE SDT-JIG-SIZE(L-ROW) WS-OK
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-HEIGHT WS-NODE
     MOVE 0 TO WS-INNER
     IF WS-NODE > 0
         CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-ABSOLUTE WS-INNER
     END-IF
     CALL "FD-J-INT" USING JSON-DOC WS-INNER SDT-JIG-Y(L-ROW) WS-OK
*>   a uniform start height (36-10 2.1) is read by STRUCT-ALIAS-READ with the start jigsaw name and the pool aliases
     CALL "STRUCT-ALIAS-READ" USING JSON-DOC L-ROW WS-AOK
     IF SDA-Y-KIND(L-ROW) = 1
         MOVE SDA-Y-MIN(L-ROW) TO SDT-JIG-Y(L-ROW)
         MOVE 1 TO WS-OK
     END-IF
     IF WS-OK = 0 OR WS-AOK = 0
         MOVE 0 TO SDT-JIG-OK(L-ROW)
     END-IF
     CALL "FD-J-STRING" USING JSON-DOC K-PROJECT 1 WS-TEXT WS-LEN
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "WORLD_SURFACE_WG"
             MOVE 0 TO SDT-JIG-PROJ(L-ROW)
         WHEN "OCEAN_FLOOR_WG"
             MOVE 1 TO SDT-JIG-PROJ(L-ROW)
         WHEN SPACES
             MOVE -1 TO SDT-JIG-PROJ(L-ROW)
         WHEN OTHER
             MOVE 0 TO SDT-JIG-OK(L-ROW)
     END-EVALUATE
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-HACK WS-NODE
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-TRUE
             MOVE 1 TO SDT-JIG-HACK(L-ROW)
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-DISTANCE WS-NODE
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-NUMBER
             CALL "FD-J-INT" USING JSON-DOC WS-NODE SDT-JIG-HOR(L-ROW) WS-OK
             MOVE SDT-JIG-HOR(L-ROW) TO SDT-JIG-VER(L-ROW)
         ELSE
             CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-HORIZONTAL WS-INNER
             CALL "FD-J-INT" USING JSON-DOC WS-INNER SDT-JIG-HOR(L-ROW) WS-OK
             CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-VERTICAL WS-INNER
             CALL "FD-J-INT" USING JSON-DOC WS-INNER WS-VALUE WS-OK
             IF WS-OK = 1
                 MOVE WS-VALUE TO SDT-JIG-VER(L-ROW)
             END-IF
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-PADDING WS-NODE
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-NUMBER
             CALL "FD-J-INT" USING JSON-DOC WS-NODE SDT-JIG-PADB(L-ROW) WS-OK
             MOVE SDT-JIG-PADB(L-ROW) TO SDT-JIG-PADT(L-ROW)
         ELSE
             CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-BOTTOM WS-INNER
             CALL "FD-J-INT" USING JSON-DOC WS-INNER SDT-JIG-PADB(L-ROW) WS-OK
             CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-TOP WS-INNER
             CALL "FD-J-INT" USING JSON-DOC WS-INNER SDT-JIG-PADT(L-ROW) WS-OK
         END-IF
     END-IF
     CALL "FD-J-STRING" USING JSON-DOC K-LIQUID 1 WS-TEXT WS-LEN
     IF FUNCTION TRIM(WS-TEXT) = "ignore_waterlogging"
         MOVE 1 TO SDT-JIG-LIQ(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM STRUCT-JIG-READ.
