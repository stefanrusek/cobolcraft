*> Equivalence test (lane perfsteady): GI-IN-REACH made its three box sizes from the entity table in every call, for every player slot of every ground item every tick (8.7 percent of a
*> loading world's profile with a few hundred items); the sizes are made once now, GI-PICKUP does not ask a slot that is not in use, and an unused slot is answered before the sizes are looked at.
*> The old program is kept below as REF-GI-IN-REACH. 20000 draws of an item position round the player (offsets from a table that holds the edges of the reach: 1.425 and 0.5 blocks, one
*> unit of the seventh decimal either side, zero and negatives), both dimensions, a dead player, an unused slot and a player without an entity row: the answers are the same.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GI-IN-REACH-EQUIV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 4242.
 01 WS-GOT                 BINARY-LONG.
 01 WS-REF                 BINARY-LONG.
 01 WS-DIFFER              BINARY-LONG VALUE 0.
 01 WS-INS                 BINARY-LONG VALUE 0.
 01 WS-OUTS                BINARY-LONG VALUE 0.
 01 WS-SAVE-STATE          BINARY-LONG.
 01 WS-SAVE-USED           BINARY-LONG.
 01 WS-SAVE-ROW            BINARY-LONG.
 01 WS-SAVE-DIM            BINARY-LONG.
 01 WS-OFFSETS.
    05 FILLER PIC X(12) VALUE "0".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(12) VALUE "-0.5".
    05 FILLER PIC X(12) VALUE "1.425".
    05 FILLER PIC X(12) VALUE "-1.425".
    05 FILLER PIC X(12) VALUE "1.4249999".
    05 FILLER PIC X(12) VALUE "-1.4249999".
    05 FILLER PIC X(12) VALUE "1.4250001".
    05 FILLER PIC X(12) VALUE "-1.4250001".
    05 FILLER PIC X(12) VALUE "0.9999999".
    05 FILLER PIC X(12) VALUE "2.3".
    05 FILLER PIC X(12) VALUE "-2.3".
    05 FILLER PIC X(12) VALUE "0.25".
    05 FILLER PIC X(12) VALUE "-0.25".
    05 FILLER PIC X(12) VALUE "1.8".
    05 FILLER PIC X(12) VALUE "-1.8".
    05 FILLER PIC X(12) VALUE "0.75".
    05 FILLER PIC X(12) VALUE "-0.75".
 01 WS-OFFSET-TABLE REDEFINES WS-OFFSETS.
    05 WS-OFFSET-TEXT      PIC X(12) OCCURS 18 TIMES.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-STATE(WS-PLAYER) TO WS-SAVE-STATE
     MOVE PL-USED(WS-PLAYER) TO WS-SAVE-USED
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-SAVE-ROW
     MOVE PL-DIM(WS-PLAYER) TO WS-SAVE-DIM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20000
         PERFORM DRAW
         COMPUTE WS-DX = FUNCTION NUMVAL(WS-OFFSET-TEXT(FUNCTION MOD(WS-PICK, 18) + 1))
         PERFORM DRAW
         COMPUTE WS-DZ = FUNCTION NUMVAL(WS-OFFSET-TEXT(FUNCTION MOD(WS-PICK, 18) + 1))
         PERFORM DRAW
         COMPUTE WS-DY = FUNCTION NUMVAL(WS-OFFSET-TEXT(FUNCTION MOD(WS-PICK, 18) + 1))
         COMPUTE EN-X(WS-ROW) = PL-X(WS-PLAYER) + WS-DX
         COMPUTE EN-Z(WS-ROW) = PL-Z(WS-PLAYER) + WS-DZ
*>       the item's y from the player's feet less the item height up to the head and the margin
         COMPUTE EN-Y(WS-ROW) = PL-Y(WS-PLAYER) + WS-DY * 2 - 0.25
         MOVE WS-SAVE-DIM TO EN-DIM(WS-ROW)
         MOVE WS-SAVE-STATE TO PL-STATE(WS-PLAYER)
         MOVE WS-SAVE-USED TO PL-USED(WS-PLAYER)
         MOVE WS-SAVE-ROW TO PL-ENTITY-ROW(WS-PLAYER)
         PERFORM DRAW
         EVALUATE FUNCTION MOD(WS-PICK, 16)
             WHEN 0 ADD 1 TO EN-DIM(WS-ROW)
             WHEN 1 MOVE 0 TO PL-USED(WS-PLAYER)
             WHEN 2 MOVE 0 TO PL-ENTITY-ROW(WS-PLAYER)
             WHEN 3 COMPUTE PL-STATE(WS-PLAYER) = PS-ALIVE + 1
             WHEN OTHER CONTINUE
         END-EVALUATE
         CALL "GI-IN-REACH" USING WS-PLAYER WS-ROW WS-GOT
         CALL "REF-GI-IN-REACH" USING WS-PLAYER WS-ROW WS-REF
         IF WS-GOT NOT = WS-REF
             ADD 1 TO WS-DIFFER
         END-IF
         IF WS-REF = 1
             ADD 1 TO WS-INS
         ELSE
             ADD 1 TO WS-OUTS
         END-IF
     END-PERFORM
     MOVE "perfsteady: given 20000 item positions at the edges of the reach when GI-IN-REACH and the old program answer then they answer the same" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFFER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "perfsteady: the draws had both answers in good numbers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INS > 500 AND WS-OUTS > 500
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 DRAW.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     COMPUTE WS-PICK = FUNCTION MOD(WS-SEED / 65536, 32768)
     .
 END PROGRAM TEST-GI-IN-REACH-EQUIV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REF-GI-IN-REACH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-REACH-XZ            FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-ITEM-HEIGHT         FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-IN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-IN.
     MOVE 0 TO L-IN
     COMPUTE WS-REACH-XZ = ET-WIDTH-MILLI(CR-OPERATOR + 1) / 2000 + 1 + ET-WIDTH-MILLI(CR-LOOSE-ITEM + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(CR-OPERATOR + 1) / 1000
     COMPUTE WS-ITEM-HEIGHT = ET-HEIGHT-MILLI(CR-LOOSE-ITEM + 1) / 1000
     IF PL-USED(L-PLAYER) = 1 AND PL-ENTITY-ROW(L-PLAYER) > 0 AND PL-STATE(L-PLAYER) = PS-ALIVE
             AND PL-DIM(L-PLAYER) = EN-DIM(L-ROW)
             AND FUNCTION ABS(EN-X(L-ROW) - PL-X(L-PLAYER)) < WS-REACH-XZ
             AND FUNCTION ABS(EN-Z(L-ROW) - PL-Z(L-PLAYER)) < WS-REACH-XZ
             AND EN-Y(L-ROW) + WS-ITEM-HEIGHT > PL-Y(L-PLAYER) - 0.5
             AND EN-Y(L-ROW) < PL-Y(L-PLAYER) + WS-HEIGHT + 0.5
         MOVE 1 TO L-IN
     END-IF
     GOBACK.
 END PROGRAM REF-GI-IN-REACH.
 COPY CORETEST.
 COPY MOBSPTEST.
