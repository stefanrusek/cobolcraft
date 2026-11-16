*> T10404 (bug-sweep: the biome tint reached only the top of a grass block; operator play of try7): the real grass_block model has two elements, the
*> base cube (the top tinted, tintindex 0) and an overlay element on the four sides (grass_block_side_overlay, tintindex 0). A lone grass block
*> in the air meshes ten opaque quads: five tinted (the top and the four overlays) and five white (the bottom and the four base sides), and
*> where two quads lie in one plane the overlay (the tinted one) is the one drawn second (the solid pipeline passes equal depth).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-GRASS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.

 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BIG                 BINARY-LONG VALUE 64.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-KEYSTR              PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-GRASS               BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.

 01 WS-TINTED              BINARY-LONG.
 01 WS-WHITE               BINARY-LONG.
 01 WS-ORDER-BAD           BINARY-LONG.
 01 WS-KEY                 BINARY-LONG OCCURS 16 TIMES.
 01 WS-KT                  BINARY-LONG OCCURS 16 TIMES.
 01 WS-NQ                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 B-VERTICES BASED.
    05 B-VERTEX OCCURS 150000 TIMES.
       10 B-X              FLOAT-SHORT.
       10 B-Y              FLOAT-SHORT.
       10 B-Z              FLOAT-SHORT.
       10 B-U              FLOAT-SHORT.
       10 B-V              FLOAT-SHORT.
       10 B-B              FLOAT-SHORT.
       10 B-ALPHA          FLOAT-SHORT.
       10 B-SKY            FLOAT-SHORT.
       10 B-R              FLOAT-SHORT.
       10 B-G              FLOAT-SHORT.
       10 B-BLUE           FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-ice" TO PK-ROOT(PK-COUNT)
     MOVE 30 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 0 TO ST-READY MB-CREDIT-ON
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 384 TO PL-HEIGHT
     MOVE -64 TO PL-MIN-Y
     MOVE 1 TO PL-HAS-SKY
     MOVE 1000 TO SK-U
     MOVE 1 TO MB-FAKE
     MOVE 0 TO MB-FAKE-STEP MB-FAKE-NOW
     MOVE 1000000000 TO MB-BUDGET-US
     MOVE "grass_block" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-GRASS WS-STATUS
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE ALL X"FF" TO CE-SKYS
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 12288
         MOVE 0 TO CE-STATE(WS-CELL)
     END-PERFORM
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     COMPUTE WS-WY = 5 + PL-MIN-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-GRASS
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         MOVE 1 TO WR-DIRTY(WS-ROW, WS-S)
     END-PERFORM
     MOVE 0 TO WS-FRAMES
     MOVE 1 TO WS-DIRTY
     PERFORM UNTIL WS-DIRTY = 0 OR WS-FRAMES > 400
         ADD 1 TO WS-FRAMES
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
         MOVE 0 TO WS-DIRTY
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             IF WR-DIRTY(WS-ROW, WS-S) = 1
                 MOVE 1 TO WS-DIRTY
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-TINTED WS-WHITE WS-ORDER-BAD WS-NQ
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         IF WR-OP-COUNT(WS-ROW, WS-S) > 0
             SET ADDRESS OF B-VERTICES TO WR-OP-ADDR(WS-ROW, WS-S)
             PERFORM VARYING WS-Q FROM 0 BY 6 UNTIL WS-Q >= WR-OP-COUNT(WS-ROW, WS-S)
                 ADD 1 TO WS-NQ
                 COMPUTE WS-T = 0
                 IF B-R(WS-Q + 1) < 0.99 OR B-G(WS-Q + 1) < 0.99 OR B-BLUE(WS-Q + 1) < 0.99
                     MOVE 1 TO WS-T
                     ADD 1 TO WS-TINTED
                 ELSE
                     ADD 1 TO WS-WHITE
                 END-IF
*>               The plane: the doubled centre of the quad, as one number.
                 COMPUTE WS-KEY(WS-NQ) = FUNCTION INTEGER((B-X(WS-Q + 1) + B-X(WS-Q + 3)) * 100 + 0.5) * 1000000
                     + FUNCTION INTEGER((B-Y(WS-Q + 1) + B-Y(WS-Q + 3)) * 100 + 0.5) * 1000
                     + FUNCTION INTEGER((B-Z(WS-Q + 1) + B-Z(WS-Q + 3)) * 100 + 0.5)
                 MOVE WS-T TO WS-KT(WS-NQ)
             END-PERFORM
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NQ
         PERFORM VARYING WS-P FROM WS-I BY 1 UNTIL WS-P > WS-NQ
             IF WS-P > WS-I AND WS-KEY(WS-P) = WS-KEY(WS-I) AND WS-KT(WS-I) = 1 AND WS-KT(WS-P) = 0
                 ADD 1 TO WS-ORDER-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "mesher grass a lone grass block meshes ten opaque quads" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-NQ TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mesher grass five of the quads take the biome tint (the top and the four overlays)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-TINTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mesher grass where two quads share a plane the tinted overlay is drawn after the white base" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ORDER-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MESHER-GRASS.
