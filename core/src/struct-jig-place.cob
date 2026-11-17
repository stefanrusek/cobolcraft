*> The placement of jigsaw pieces (docs/protocol/36-structures-3 sections 5, 12.4 and 14.3; 36-structures-9 sections 3.4 and 7): postProcess of a piece of SP-TYPE 60 (struct-jig.cob).
*> A template element (single_pool_element, legacy_single_pool_element) is placed with StructureTemplate.placeInWorld (STRUCT-PLACE): the rotation of the piece, the piece's
*> liquid settings, the write box of the chunk, knownShape (no shape updates), the processors of 5.1 and 5.2, flags 18 (the flags only tell which updates are made, none of which
*> the generation window has). A list element places its sub-elements in order and stops at the first that fails. A feature element and the empty element write nothing here: a
*> placed feature is not run from a piece (the trees and the like of the pools are not made; docs/design/world-types.md structures part 8).
*>
*> The processors of an element are one list per (kind, projection, list): the structure-block ignore, the jigsaw replacement, the element's list in its own order and, for a
*> terrain_matching element, the gravity processor (WORLD_SURFACE_WG, offset -1); a legacy element has no structure-block ignore first and the structure-block-and-air ignore last.
*>
*> Entry points:
*>   JIG-PROCS USING element row, list out: the index of that list in STRUCT-PROC (0 when the tables are full); a list the element names that does not exist is no list
*>   JIG-PLACE-ONE USING piece row, element row, result out: one template element of the piece (result 0 when the template is not there or placeInWorld fails)
*>   JIG-POST USING piece row: postProcess for the chunk of the window (SW-* of STRUCTPIECE.cpy)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-PROCS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY STRUCTJIG.
 01 WS-KEY                 PIC X(80).
 01 WS-LEGACY              PIC 9.
 01 WS-PROJ                PIC 9.
 01 WS-NAME                PIC X(80).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 K-IGNORE-BLOCK         PIC X(80) VALUE "cobolcraft:inline/ignore_structure_block".
 01 K-IGNORE-AIR           PIC X(80) VALUE "cobolcraft:inline/ignore_structure_and_air".
 01 K-REPLACE              PIC X(80) VALUE "cobolcraft:inline/jigsaw_replacement".
 01 K-GRAVITY              PIC X(80) VALUE "cobolcraft:inline/gravity".
 LINKAGE SECTION.
 01 L-EL                   BINARY-LONG.
 01 L-LIST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EL L-LIST.
     GO TO MAIN-LINE.


*> the processors of the list WS-SRC are appended to the new list
 COPY-LIST.
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SPL-N(WS-SRC)
         ADD 1 TO SP-PROC-COUNT
         COMPUTE WS-ROW = SPL-FIRST(WS-SRC) + WS-K
         MOVE SP-PROC(WS-ROW) TO SP-PROC(SP-PROC-COUNT)
     END-PERFORM.

 MAIN-LINE.
     MOVE 0 TO L-LIST
     MOVE 0 TO WS-LEGACY
     IF JE-KIND(L-EL) = 2
         MOVE 1 TO WS-LEGACY
     END-IF
     MOVE JE-PROJ(L-EL) TO WS-PROJ
     MOVE SPACES TO WS-KEY
     STRING "cobolcraft:compose/" WS-LEGACY "/" WS-PROJ "/" FUNCTION TRIM(JE-PROC(L-EL)) DELIMITED BY SIZE INTO WS-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-LIST-COUNT
         IF SPL-KEY(WS-I) = WS-KEY
             MOVE WS-I TO L-LIST
             GOBACK
         END-IF
     END-PERFORM
*>   the lists that make it: the ones of the code (4: ignore, 5: air ignore, 6: replacement, 7: gravity) and the element's own (0 when it names none or none exists)
     CALL "STRUCT-PROC-LOAD" USING K-IGNORE-BLOCK WS-A
     CALL "STRUCT-PROC-LOAD" USING K-IGNORE-AIR WS-E
     CALL "STRUCT-PROC-LOAD" USING K-REPLACE WS-B
     MOVE 0 TO WS-C WS-D
     IF JE-PROC(L-EL) NOT = SPACES
         MOVE JE-PROC(L-EL) TO WS-NAME
         CALL "STRUCT-PROC-LOAD" USING WS-NAME WS-C
     END-IF
     IF WS-PROJ = 1
         CALL "STRUCT-PROC-LOAD" USING K-GRAVITY WS-D
     END-IF
     MOVE 0 TO WS-N
     IF WS-LEGACY = 0
         ADD SPL-N(WS-A) TO WS-N
     ELSE
         ADD SPL-N(WS-E) TO WS-N
     END-IF
     ADD SPL-N(WS-B) TO WS-N
     IF WS-C > 0
         ADD SPL-N(WS-C) TO WS-N
     END-IF
     IF WS-D > 0
         ADD SPL-N(WS-D) TO WS-N
     END-IF
     IF SP-LIST-COUNT >= SP-MAX-LISTS OR SP-PROC-COUNT + WS-N > SP-MAX-PROCS
         GOBACK
     END-IF
     ADD 1 TO SP-LIST-COUNT
     MOVE SP-LIST-COUNT TO L-LIST
     MOVE WS-KEY TO SPL-KEY(L-LIST)
     MOVE 1 TO SPL-STATUS(L-LIST)
     COMPUTE SPL-FIRST(L-LIST) = SP-PROC-COUNT + 1
     MOVE WS-N TO SPL-N(L-LIST)
     IF WS-LEGACY = 0
         MOVE WS-A TO WS-SRC
         PERFORM COPY-LIST
     END-IF
     MOVE WS-B TO WS-SRC
     PERFORM COPY-LIST
     IF WS-C > 0
         MOVE WS-C TO WS-SRC
         PERFORM COPY-LIST
     END-IF
     IF WS-D > 0
         MOVE WS-D TO WS-SRC
         PERFORM COPY-LIST
     END-IF
     IF WS-LEGACY = 1
         MOVE WS-E TO WS-SRC
         PERFORM COPY-LIST
     END-IF
     GOBACK.
 END PROGRAM JIG-PROCS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-PLACE-ONE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 COPY STRUCTSET.
 COPY STRUCTDATA.
 01 WS-TROW                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 18.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EL                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EL L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "STRUCT-TPL-LOAD" USING SD-DIR JE-LOC(L-EL) WS-TROW
     IF WS-TROW < 1
         GOBACK
     END-IF
     IF TP-STATUS(WS-TROW) NOT = 1
         GOBACK
     END-IF
     CALL "JIG-PROCS" USING L-EL WS-LIST
     INITIALIZE STRUCT-SETTINGS
     MOVE SP-T-ROT(L-ROW) TO PS-ROTATION
     MOVE SP-T-LIQ(L-ROW) TO PS-LIQUID
     MOVE 1 TO PS-KNOWN-SHAPE
     MOVE WS-LIST TO PS-PROCESSORS
     MOVE SP-SEED TO PS-SEED
     MOVE 1 TO PS-BOX-SET
     MOVE SW-X0 TO PS-BOX(1)
     MOVE SW-Y0 TO PS-BOX(2)
     MOVE SW-Z0 TO PS-BOX(3)
     MOVE SW-X1 TO PS-BOX(4)
     MOVE SW-Y1 TO PS-BOX(5)
     MOVE SW-Z1 TO PS-BOX(6)
     CALL "STRUCT-PLACE" USING WS-TROW SP-T-X(L-ROW) SP-T-Y(L-ROW) SP-T-Z(L-ROW) SP-PIV-X SP-PIV-Y SP-PIV-Z STRUCT-SETTINGS WS-FLAGS L-RESULT
     GOBACK.
 END PROGRAM JIG-PLACE-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-FEATURE.
*> USING piece row, element row: the feature pool element's place (36-3 5.5, 36-9 8.1): the placed feature of the element runs once at the piece position (the jigsaw cell, SP-T-X..Z), after the
*> template blocks. Its result is not used (a failing tree is not retried). Deviation: the feature random is derived from the position (the positional random of the level seed), not the stream
*> shared by the pieces of the pass, so the passes of neighbouring chunks agree on one tree whose blocks each pass writes inside its own chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTJIG.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-KEY                 PIC X(80).
 01 WS-PF                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EL                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EL.
     MOVE JE-FEATURE(L-EL) TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     IF WS-PF = 0
         GOBACK
     END-IF
     CALL "FD-ENSURE-PF" USING WS-PF
     CALL "XORO-GET-SEED" USING SP-T-X(L-ROW) SP-T-Y(L-ROW) SP-T-Z(L-ROW) WS-SEED
     COMPUTE WS-USEED = FUNCTION MOD(WS-SEED + WS-M64, WS-M64)
     CALL "WGR-SET-SEED" USING WS-XR WS-USEED
     MOVE WS-PF TO WS-TOP
     CALL "FR-PLACE-PF" USING WS-XR WS-PF WS-TOP SP-T-X(L-ROW) SP-T-Y(L-ROW) SP-T-Z(L-ROW) WS-RESULT
     GOBACK.
 END PROGRAM JIG-FEATURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-POST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 01 WS-EL                  BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SP-F1(L-ROW) TO WS-EL
     EVALUATE JE-KIND(WS-EL)
         WHEN 1
             CALL "JIG-PLACE-ONE" USING L-ROW WS-EL WS-RESULT
         WHEN 2
             CALL "JIG-PLACE-ONE" USING L-ROW WS-EL WS-RESULT
         WHEN 3
             MOVE 1 TO WS-RESULT
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JE-SUB-N(WS-EL) OR WS-RESULT = 0
                 MOVE JS-ELEM(JE-SUB-FIRST(WS-EL) + WS-I) TO WS-SUB
                 IF JE-KIND(WS-SUB) = 1 OR JE-KIND(WS-SUB) = 2
                     CALL "JIG-PLACE-ONE" USING L-ROW WS-SUB WS-RESULT
                 END-IF
             END-PERFORM
         WHEN 4
             CALL "JIG-FEATURE" USING L-ROW WS-EL
     END-EVALUATE
     GOBACK.
 END PROGRAM JIG-POST.
