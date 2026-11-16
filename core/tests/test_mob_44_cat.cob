*> Implementation test (002-lane-mobsa3; docs/protocol/19 sections 1.3 and 1.6): the cat variant (metadata 20, serializer 21): the key per number, the selection pool and the entry.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-CAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-D2                 FLOAT-LONG.
 01 WS-WALK               BINARY-LONG.
 01 WS-CLEAR              BINARY-LONG.
 01 WS-DX                 FLOAT-LONG.
 01 WS-DY                 FLOAT-LONG.
 01 WS-DZ                 FLOAT-LONG.
 01 WS-STARTED            BINARY-LONG.
 01 WS-ALIVE              BINARY-LONG.
 01 WS-CONT               BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-LEN0               BINARY-LONG.
 01 WS-CAPACITY           BINARY-LONG VALUE 256.
 01 WS-KEYS.
    05 WS-KEY-ENTRY         PIC X(48) OCCURS 9 TIMES.
 01 WS-REG                PIC X(48).
 01 WS-SPECIES            PIC X(24).
 01 WS-VAR                BINARY-LONG.
 01 WS-VKEY               PIC X(48).
 01 WS-ID                 BINARY-LONG.
 01 WS-N                  BINARY-LONG VALUE 9.
 01 WS-WANT               PIC X(48).
 01 WS-EXPECT-LEN         BINARY-LONG.

 01 WS-BAD               BINARY-LONG.
 01 WS-MOON              BINARY-LONG.
 01 WS-HUT               BINARY-LONG.
 01 WS-DRAW              BINARY-LONG.
 01 WS-CATV              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "cat" TO WS-SPECIES
     PERFORM VARYING WS-VAR FROM 0 BY 1 UNTIL WS-VAR > 10
         CALL "M44-VARIANT-KEY" USING WS-SPECIES WS-VAR WS-VKEY
         EVALUATE WS-VAR
             WHEN 0 MOVE "black" TO WS-WANT
             WHEN 1 MOVE "all_black" TO WS-WANT
             WHEN 2 MOVE "british_shorthair" TO WS-WANT
             WHEN 3 MOVE "calico" TO WS-WANT
             WHEN 4 MOVE "jellie" TO WS-WANT
             WHEN 5 MOVE "persian" TO WS-WANT
             WHEN 6 MOVE "ragdoll" TO WS-WANT
             WHEN 7 MOVE "red" TO WS-WANT
             WHEN 8 MOVE "siamese" TO WS-WANT
             WHEN 9 MOVE "tabby" TO WS-WANT
             WHEN OTHER MOVE "white" TO WS-WANT
         END-EVALUATE
         MOVE "acceptance US15 19§1.6 Variant key: the cat numbers 0 to 10 name the cat_variant files (black is the default 0)" TO WS-CASE
         MOVE 0 TO WS-O
         IF WS-VKEY = WS-WANT
             MOVE 1 TO WS-O
         END-IF
         MOVE 1 TO WS-E
         PERFORM CHECK-N
     END-PERFORM
*>   The pool: ten variants of priority 0; all_black joins them at a moon brightness of 0.9 or more; a swamp hut gives all_black alone (priority 1).
     MOVE 0 TO WS-MOON WS-HUT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-DRAW FROM 0 BY 1 UNTIL WS-DRAW > 9
         CALL "M44-CAT-VARIANT" USING WS-MOON WS-HUT WS-DRAW WS-CATV
         IF WS-CATV = 1 OR WS-CATV < 0 OR WS-CATV > 10
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§1.6 Cat variant: without the moon or a hut all_black is never picked and the ten others are" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BAD TO WS-O
     PERFORM CHECK-N
     MOVE 10 TO WS-DRAW
     CALL "M44-CAT-VARIANT" USING WS-MOON WS-HUT WS-DRAW WS-CATV
     MOVE "acceptance US15 19§1.6 Cat variant: the draw is taken mod the pool (10 -> the first, black)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CATV TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-MOON
     MOVE 10 TO WS-DRAW
     CALL "M44-CAT-VARIANT" USING WS-MOON WS-HUT WS-DRAW WS-CATV
     MOVE "acceptance US15 19§1.6 Cat variant: at the full moon the pool has eleven, the eleventh is all_black (1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CATV TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-MOON
     MOVE 1 TO WS-HUT
     MOVE 3 TO WS-DRAW
     CALL "M44-CAT-VARIANT" USING WS-MOON WS-HUT WS-DRAW WS-CATV
     MOVE "acceptance US15 19§1.6 Cat variant: a swamp hut gives all_black (priority 1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CATV TO WS-O
     PERFORM CHECK-N
*>   The entry: baby (3), variant 20 (3), sound variant 24 (3), end marker (1), packet id (1), entity id.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:cat" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE "acceptance US15 19§1.6 Cat variant: a spawned cat has a stored variant of 0 to 10" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-WOOL(WS-ROW) >= 0 AND EN-WOOL(WS-ROW) <= 10
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO EN-TAMED(WS-ROW) EN-COLLAR(WS-ROW) EN-VARIANT(WS-ROW)
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
     MOVE 11 TO WS-EXPECT-LEN
     IF EN-ID(WS-ROW) < 128
         ADD 1 TO WS-EXPECT-LEN
     ELSE
         ADD 2 TO WS-EXPECT-LEN
     END-IF
     MOVE "acceptance US15 19§1.3 Cat entry: a wild cat sends baby, variant 20, sound variant 24 and the end marker" TO WS-CASE
     MOVE TP-LENGTH TO WS-O
     MOVE WS-EXPECT-LEN TO WS-E
     PERFORM CHECK-N
     CALL "PB-FREE" USING TP-BUFFER
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-44-CAT.
 COPY CORETEST.
 COPY MOBSPTEST.
