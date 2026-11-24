*> Section test of 36-structures-6-ocean.md section 3 (ocean ruins) and the start vectors of its section 6.3, over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass
*> without it). The expectations are the document's: the 48 template names of 3.1 (sizes 6 x 7 x 7 and 16 x 16 x 16, one palette, 47 chest and 51 drowned markers in all), the draws of 3.2 to 3.4
*> (rotation, the large draw with its less-than-or-equal, the template index, the three pieces of a cold ruin with the integrities 0.8/0.7/0.5), the cluster of 3.6 (the worked 8-member cluster of
*> 6.3 at world seed 0, chunk (4, 1), the footprint corners of the four rotations) and the processor lists of 3.5 and 2.4 by key. Written from the document alone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPROC.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-WARM                BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-KEY                 PIC X(80).
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CHESTS              BINARY-LONG.
 01 WS-DROWNED             BINARY-LONG.
 01 WS-SIZE-OK             BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-DEC                 PIC 9.
*> the template names of 3.1 in array order: prefix, count (8 small lists, then the four big lists with their own numbers)
 01 WS-SMALL-PREFIX.
    05 FILLER PIC X(8) VALUE "warm_   ".
    05 FILLER PIC X(8) VALUE "brick_  ".
    05 FILLER PIC X(8) VALUE "cracked_".
    05 FILLER PIC X(8) VALUE "mossy_  ".
 01 WS-SMALL-T REDEFINES WS-SMALL-PREFIX.
    05 WS-SP               PIC X(8) OCCURS 4 TIMES.
 01 WS-BIG-NAMES.
    05 FILLER PIC X(14) VALUE "big_warm_4    ".
    05 FILLER PIC X(14) VALUE "big_warm_5    ".
    05 FILLER PIC X(14) VALUE "big_warm_6    ".
    05 FILLER PIC X(14) VALUE "big_warm_7    ".
    05 FILLER PIC X(14) VALUE "big_brick_1   ".
    05 FILLER PIC X(14) VALUE "big_brick_2   ".
    05 FILLER PIC X(14) VALUE "big_brick_3   ".
    05 FILLER PIC X(14) VALUE "big_brick_8   ".
    05 FILLER PIC X(14) VALUE "big_cracked_1 ".
    05 FILLER PIC X(14) VALUE "big_cracked_2 ".
    05 FILLER PIC X(14) VALUE "big_cracked_3 ".
    05 FILLER PIC X(14) VALUE "big_cracked_8 ".
    05 FILLER PIC X(14) VALUE "big_mossy_1   ".
    05 FILLER PIC X(14) VALUE "big_mossy_2   ".
    05 FILLER PIC X(14) VALUE "big_mossy_3   ".
    05 FILLER PIC X(14) VALUE "big_mossy_8   ".
 01 WS-BIG-T REDEFINES WS-BIG-NAMES.
    05 WS-BN               PIC X(14) OCCURS 16 TIMES.
*> 6.3 cluster members at world seed 0, chunk (4, 1): x, z, rotation, template number
 01 WS-MEMBERS.
    05 FILLER PIC X(15) VALUE "+0069+0004108".
    05 FILLER PIC X(15) VALUE "+0056+0007207".
    05 FILLER PIC X(15) VALUE "+0085+0007103".
    05 FILLER PIC X(15) VALUE "+0051+0019108".
    05 FILLER PIC X(15) VALUE "+0070+0039105".
    05 FILLER PIC X(15) VALUE "+0085+0038107".
    05 FILLER PIC X(15) VALUE "+0084+0023001".
    05 FILLER PIC X(15) VALUE "+0056+0036307".
 01 WS-MEMBER-T REDEFINES WS-MEMBERS.
    05 WS-M OCCURS 8 TIMES.
       10 M-X              PIC S9(4) SIGN LEADING SEPARATE.
       10 M-Z              PIC S9(4) SIGN LEADING SEPARATE.
       10 M-ROT            PIC 9.
       10 M-NUM            PIC 99.
       10 FILLER           PIC X(2).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-6§3 Ocean ruins: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         EVALUATE SDT-KEY(WS-I)
             WHEN "minecraft:ocean_ruin_warm"
                 MOVE WS-I TO WS-WARM
             WHEN "minecraft:ocean_ruin_cold"
                 MOVE WS-I TO WS-COLD
         END-EVALUATE
     END-PERFORM
     PERFORM TEMPLATE-CASES
     PERFORM START-CASES
     PERFORM CLUSTER-CASES
     PERFORM CORNER-CASES
     PERFORM LIST-CASES
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 3.1: the 48 templates exist, every small one is 6 x 7 x 7 and every big one 16 x 16 x 16 with one palette; 47 chest and 51 drowned markers in all
 TEMPLATE-CASES.
     MOVE 0 TO WS-CHESTS WS-DROWNED WS-SIZE-OK
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 8
             MOVE WS-J TO WS-DEC
             MOVE SPACES TO WS-ID
             STRING "minecraft:underwater_ruin/" FUNCTION TRIM(WS-SP(WS-I)) WS-DEC DELIMITED BY SIZE INTO WS-ID
             PERFORM LOAD-AND-COUNT
             IF TP-STATUS(WS-ROW) = 1 AND TP-SX(WS-ROW) = 6 AND TP-SY(WS-ROW) = 7 AND TP-SZ(WS-ROW) = 7 AND TP-PALETTES(WS-ROW) = 1
                 ADD 1 TO WS-N
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§3.1 Ocean ruins: the 32 small templates exist, 6 x 7 x 7, one palette" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE SPACES TO WS-ID
         STRING "minecraft:underwater_ruin/" FUNCTION TRIM(WS-BN(WS-I)) DELIMITED BY SIZE INTO WS-ID
         PERFORM LOAD-AND-COUNT
         IF TP-STATUS(WS-ROW) = 1 AND TP-SX(WS-ROW) = 16 AND TP-SY(WS-ROW) = 16 AND TP-SZ(WS-ROW) = 16 AND TP-PALETTES(WS-ROW) = 1
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§3.1 Ocean ruins: the 16 big templates exist, 16 x 16 x 16, one palette" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§3.1 Ocean ruins: the 48 files hold 47 chest markers" TO TL-CASE
     MOVE 47 TO TL-EXPECTED-N
     MOVE WS-CHESTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§3.1 Ocean ruins: the 48 files hold 51 drowned markers" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     MOVE WS-DROWNED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> loads the template WS-ID into WS-ROW and adds its DATA markers to the totals
 LOAD-AND-COUNT.
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     IF TP-STATUS(WS-ROW) = 1
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TP-BLOCKS(WS-ROW)
             MOVE TB-NBT(TP-BASE(WS-ROW, 1) + WS-K) TO WS-TAG
             IF WS-TAG > 0
                 IF TN-KIND(WS-TAG) = 3
                     IF TN-TEXT(WS-TAG) = "chest"
                         ADD 1 TO WS-CHESTS
                     END-IF
                     IF TN-TEXT(WS-TAG) = "drowned"
                         ADD 1 TO WS-DROWNED
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-IF.

*> the start at a chunk: STRUCT-TPL-FIND-POINT draws the start random of 3.2 and the pieces of 3.3 and 3.4 (no biome test: that is the caller's)
 FIND-START.
     CALL "STRUCT-TPL-FIND-POINT" USING WS-LIST WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE.

*> the piece I of the builder is the template WS-ID at (WS-AX, 90, WS-AZ) with rotation WS-ROT and the processor list WS-KEY: WS-FLAG 1 when so
 PIECE-IS.
     MOVE 0 TO WS-FLAG
     IF WS-I <= SP-COUNT
         MOVE SP-T-ROW(WS-I) TO WS-ROW
         IF TP-KEY(WS-ROW) = WS-ID AND SP-T-X(WS-I) = WS-AX AND SP-T-Y(WS-I) = 90 AND SP-T-Z(WS-I) = WS-AZ AND SP-T-ROT(WS-I) = WS-ROT
            AND SPL-KEY(SP-T-PROC(WS-I)) = WS-KEY
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF.

*> 6.3: world seed 0, chunk (0, 0): rotation CLOCKWISE_180, small, template 2 (warm_2; cold brick_2, cracked_2, mossy_2 at 0.8, 0.7, 0.5), no cluster draw
 START-CASES.
     MOVE WS-WARM TO WS-LIST
     MOVE 0 TO WS-CX WS-CZ
     PERFORM FIND-START
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: seed 0 chunk (0,0) warm is valid with one piece" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 1 AND SP-COUNT = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 1 TO WS-I
     MOVE "minecraft:underwater_ruin/warm_2" TO WS-ID
     MOVE 0 TO WS-AX WS-AZ
     MOVE 2 TO WS-ROT
     MOVE "cobolcraft:inline/ruin/w/8" TO WS-KEY
     PERFORM PIECE-IS
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: seed 0 chunk (0,0) warm is warm_2 at (0,90,0), CLOCKWISE_180, integrity 0.8" TO TL-CASE
     PERFORM CHECK
     MOVE WS-COLD TO WS-LIST
     PERFORM FIND-START
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: seed 0 chunk (0,0) cold has three pieces" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 1 AND SP-COUNT = 3
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 1 TO WS-I
     MOVE "minecraft:underwater_ruin/brick_2" TO WS-ID
     MOVE "cobolcraft:inline/ruin/c/8" TO WS-KEY
     PERFORM PIECE-IS
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: cold piece 1 is brick_2 with integrity 0.8" TO TL-CASE
     PERFORM CHECK
     MOVE 2 TO WS-I
     MOVE "minecraft:underwater_ruin/cracked_2" TO WS-ID
     MOVE "cobolcraft:inline/ruin/c/7" TO WS-KEY
     PERFORM PIECE-IS
     MOVE "acceptance US12 36-6§3.4 Ocean ruins: cold piece 2 is cracked_2 at the same position and rotation with integrity 0.7" TO TL-CASE
     PERFORM CHECK
     MOVE 3 TO WS-I
     MOVE "minecraft:underwater_ruin/mossy_2" TO WS-ID
     MOVE "cobolcraft:inline/ruin/c/5" TO WS-KEY
     PERFORM PIECE-IS
     MOVE "acceptance US12 36-6§3.4 Ocean ruins: cold piece 3 is mossy_2 at the same position and rotation with integrity 0.5" TO TL-CASE
     PERFORM CHECK
     MOVE 1 TO WS-FLAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         IF SP-T-AUX(WS-I) NOT = 0
             MOVE 0 TO WS-FLAG
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§3.4 Ocean ruins: the three pieces of a small cold ruin are not large" TO TL-CASE
     PERFORM CHECK.

*> 6.3: world seed 0, chunk (4, 1), warm: pos (64,90,16), NONE, large (0.9), big_warm_5, the cluster draw passes, eight members in order, none skipped
 CLUSTER-CASES.
     MOVE WS-WARM TO WS-LIST
     MOVE 4 TO WS-CX
     MOVE 1 TO WS-CZ
     PERFORM FIND-START
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: seed 0 chunk (4,1) warm holds the large ruin and eight cluster members" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 1 AND SP-COUNT = 9
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 1 TO WS-I
     MOVE "minecraft:underwater_ruin/big_warm_5" TO WS-ID
     MOVE 64 TO WS-AX
     MOVE 16 TO WS-AZ
     MOVE 0 TO WS-ROT
     MOVE "cobolcraft:inline/ruin/w/9" TO WS-KEY
     PERFORM PIECE-IS
     IF WS-FLAG = 1 AND SP-T-AUX(1) NOT = 1
         MOVE 0 TO WS-FLAG
     END-IF
     MOVE "acceptance US12 36-6§3.3 Ocean ruins: the main ruin is large (less than or equal), big_warm_5, integrity 0.9, NONE at (64,90,16)" TO TL-CASE
     PERFORM CHECK
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
         COMPUTE WS-I = WS-K + 1
         MOVE M-X(WS-K) TO WS-AX
         MOVE M-Z(WS-K) TO WS-AZ
         MOVE M-ROT(WS-K) TO WS-ROT
*>       M-NUM is two digits: the template names are warm_1 to warm_8
         MOVE M-NUM(WS-K) TO WS-N
         MOVE WS-N TO WS-DEC
         MOVE SPACES TO WS-ID
         STRING "minecraft:underwater_ruin/warm_" WS-DEC DELIMITED BY SIZE INTO WS-ID
         MOVE "cobolcraft:inline/ruin/w/8" TO WS-KEY
         PERFORM PIECE-IS
         IF WS-FLAG = 1 AND SP-T-AUX(WS-I) NOT = 0
             MOVE 0 TO WS-FLAG
         END-IF
         MOVE WS-K TO WS-DEC
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-6§3.6 Ocean ruins: cluster member " WS-DEC " of the 6.3 vector (anchor, rotation, small warm template, integrity 0.8)" DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK
     END-PERFORM.

*> 3.6 and 6.3: the footprint corner of a small ruin (5, 0, 6) and of the main ruin (15, 0, 15) for the four rotations (section 2.2 with the pivot at zero)
 CORNER-CASES.
     MOVE 5 TO WS-AX
     MOVE 6 TO WS-AZ
     MOVE 0 TO WS-ROT
     CALL "STRUCT-RUIN-ROT" USING WS-AX WS-AZ WS-ROT WS-RX WS-RZ
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: the small corner (5,6) under NONE stays (5,6)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-RX = 5 AND WS-RZ = 6
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 1 TO WS-ROT
     CALL "STRUCT-RUIN-ROT" USING WS-AX WS-AZ WS-ROT WS-RX WS-RZ
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: the small corner (5,6) under CLOCKWISE_90 is (-6,5)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-RX = -6 AND WS-RZ = 5
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 2 TO WS-ROT
     CALL "STRUCT-RUIN-ROT" USING WS-AX WS-AZ WS-ROT WS-RX WS-RZ
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: the small corner (5,6) under CLOCKWISE_180 is (-5,-6)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-RX = -5 AND WS-RZ = -6
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 3 TO WS-ROT
     CALL "STRUCT-RUIN-ROT" USING WS-AX WS-AZ WS-ROT WS-RX WS-RZ
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: the small corner (5,6) under COUNTERCLOCKWISE_90 is (6,-5)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-RX = 6 AND WS-RZ = -5
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 15 TO WS-AX
     MOVE 15 TO WS-AZ
     MOVE 0 TO WS-FLAG
     MOVE 0 TO WS-ROT
     CALL "STRUCT-RUIN-ROT" USING WS-AX WS-AZ WS-ROT WS-RX WS-RZ
     IF WS-RX = 15 AND WS-RZ = 15
         ADD 1 TO WS-FLAG
     END-IF
     MOVE 1 TO WS-ROT
     CALL "STRUCT-RUIN-ROT" USING WS-AX WS-AZ WS-ROT WS-RX WS-RZ
     IF WS-RX = -15 AND WS-RZ = 15
         ADD 1 TO WS-FLAG
     END-IF
     MOVE 2 TO WS-ROT
     CALL "STRUCT-RUIN-ROT" USING WS-AX WS-AZ WS-ROT WS-RX WS-RZ
     IF WS-RX = -15 AND WS-RZ = -15
         ADD 1 TO WS-FLAG
     END-IF
     MOVE 3 TO WS-ROT
     CALL "STRUCT-RUIN-ROT" USING WS-AX WS-AZ WS-ROT WS-RX WS-RZ
     IF WS-RX = 15 AND WS-RZ = -15
         ADD 1 TO WS-FLAG
     END-IF
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: the main corner (15,15) maps to (15,15), (-15,15), (-15,-15), (15,-15)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO TL-EXPECTED-N.

*> 3.5 and 2.4: the processor lists of a piece are rot, block_ignore (air and structure block), the capped archaeology rule: by their keys
 LIST-CASES.
     MOVE "cobolcraft:inline/ruin/w/8" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE "acceptance US12 36-6§3.5 Ocean ruins: the warm list at integrity 0.8 loads with three processors" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 3
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE "cobolcraft:inline/ruin/q/8" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE "acceptance US12 36-6§3.5 Ocean ruins: a key that is not a ruin list loads nothing" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 END PROGRAM TEST-STRUCT-36-6-3.

 COPY NOSPAWN.
 COPY CORETEST.
