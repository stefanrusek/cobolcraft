*> Implementation test (US15; docs/protocol/44-residual-mob-questions-4-land-animals.md section 4, Fox): the hunt of a chicken or rabbit (stalk, crouch, pounce) wired into the fox tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-FOX-HUNT.
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
 01 WS-FOX                BINARY-LONG.
 01 WS-PREY               BINARY-LONG.
 01 WS-HX                 FLOAT-LONG.
 01 WS-HZ                 FLOAT-LONG.
 01 WS-PZ                 FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:fox" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-FOX
     MOVE 1 TO EN-ON-GROUND(WS-FOX)
     MOVE "minecraft:chicken" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PZ = WS-FZ + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-PZ WS-YAW WS-PREY
     CALL "M44-FOX-HUNT" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox hunt: a chicken 10 blocks away becomes the prey and the fox walks to it (+z)" TO WS-CASE
     MOVE WS-WALK TO WS-O
     MULTIPLY 10 BY WS-O
     IF EN-FOE(WS-FOX) = WS-PREY
         ADD 1 TO WS-O
     END-IF
     MOVE 11 TO WS-E
     PERFORM CHECK-N
     MOVE "acceptance US15 44§4 Fox hunt: the walk heads straight to the prey (hx 0, hz > 0)" TO WS-CASE
     MOVE 0 TO WS-O
     IF WS-HZ > 0
         ADD 1 TO WS-O
     END-IF
     IF WS-HX = 0
         ADD 1 TO WS-O
     END-IF
     MOVE 2 TO WS-E
     PERFORM CHECK-N
     MOVE WS-PREY TO WS-ROW
     COMPUTE EN-Z(WS-ROW) = WS-FZ + 5
     CALL "M44-FOX-HUNT" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox hunt: within squared distance 36 the fox stops and crouches (flags 12)" TO WS-CASE
     COMPUTE WS-O = WS-WALK * 100 + EN-FOX-FLAGS(WS-FOX)
     MOVE 12 TO WS-E
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 25
         CALL "M44-FOX-HUNT" USING WS-FOX WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE "acceptance US15 44§4 Fox hunt: crouched for 25 ticks the fox pounces (flags 20, vy 0.9)" TO WS-CASE
     COMPUTE WS-O ROUNDED = EN-FOX-FLAGS(WS-FOX) * 10 + EN-VY(WS-FOX)
     MOVE 201 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO EN-ON-GROUND(WS-FOX)
     CALL "M44-FOX-HUNT" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox hunt: in the air the pounce goes on" TO WS-CASE
     MOVE EN-FOX-FLAGS(WS-FOX) TO WS-O
     MOVE 20 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO EN-ON-GROUND(WS-FOX)
     CALL "M44-FOX-HUNT" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox hunt: landed, the pounce flag is cleared" TO WS-CASE
     COMPUTE WS-O = EN-FOX-FLAGS(WS-FOX) - FUNCTION MOD(EN-FOX-FLAGS(WS-FOX), 16)
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-PREY
     CALL "M44-FOX-HUNT" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox hunt: with the prey gone the target and the flags are cleared" TO WS-CASE
     COMPUTE WS-O = EN-FOE(WS-FOX) * 100 + EN-FOX-FLAGS(WS-FOX)
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-44-FOX-HUNT.
 COPY CORETEST.
 COPY MOBSPTEST.
