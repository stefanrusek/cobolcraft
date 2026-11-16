*> Implementation test (US15; docs/protocol/44-residual-mob-questions-4-land-animals.md section 4, Fox): StalkPrey, FoxPounce and the flags byte (metadata 19).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-FOX.
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
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:fox" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
*>   StalkPrey: prey beyond squared distance 36 is approached; within it the fox crouches and is interested.
     MOVE 49 TO WS-D2
     CALL "M44-FOX-STALK" USING WS-ROW WS-D2 WS-WALK
     MOVE "acceptance US15 44§4 Fox stalk: prey at squared distance 49 is walked to, no crouch" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-WALK * 100 + EN-FOX-FLAGS(WS-ROW)
     MOVE 100 TO WS-E
     PERFORM CHECK-N
     MOVE 36 TO WS-D2
     CALL "M44-FOX-STALK" USING WS-ROW WS-D2 WS-WALK
     MOVE "acceptance US15 44§4 Fox stalk: within squared distance 36 it stops, crouches (4) and is interested (8)" TO WS-CASE
     COMPUTE WS-O = WS-WALK * 100 + EN-FOX-FLAGS(WS-ROW)
     MOVE 12 TO WS-E
     PERFORM CHECK-N
     MOVE 49 TO WS-D2
     CALL "M44-FOX-STALK" USING WS-ROW WS-D2 WS-WALK
     MOVE "acceptance US15 44§4 Fox stalk: a crouching fox does not use the goal again" TO WS-CASE
     COMPUTE WS-O = WS-WALK * 100 + EN-FOX-FLAGS(WS-ROW)
     MOVE 12 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO EN-FOX-FLAGS(WS-ROW)
     MOVE 32 TO EN-FOX-FLAGS(WS-ROW)
     CALL "M44-FOX-STALK" USING WS-ROW WS-D2 WS-WALK
     MOVE "acceptance US15 44§4 Fox stalk: a sleeping fox does not stalk" TO WS-CASE
     COMPUTE WS-O = WS-WALK * 100 + EN-FOX-FLAGS(WS-ROW)
     MOVE 32 TO WS-E
     PERFORM CHECK-N
*>   Stop: a clear path keeps the crouch, an unclear one clears it.
     MOVE 0 TO EN-FOX-FLAGS(WS-ROW)
     MOVE 1 TO WS-CLEAR
     CALL "M44-FOX-STALK-STOP" USING WS-ROW WS-CLEAR
     MOVE "acceptance US15 44§4 Fox stalk stop: a clear path sets crouching and interested" TO WS-CASE
     MOVE EN-FOX-FLAGS(WS-ROW) TO WS-O
     MOVE 12 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-CLEAR
     CALL "M44-FOX-STALK-STOP" USING WS-ROW WS-CLEAR
     MOVE "acceptance US15 44§4 Fox stalk stop: a blocked path clears both" TO WS-CASE
     MOVE EN-FOX-FLAGS(WS-ROW) TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
*>   The crouch amount rises 0.2 a tick to 5.0 (25 ticks) and resets when not crouching.
     MOVE 4 TO EN-FOX-FLAGS(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "M44-FOX-CROUCH-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44§4 Fox crouch: the crouch counter stops at 25 ticks (amount 5.0)" TO WS-CASE
     MOVE EN-FOX-CROUCH(WS-ROW) TO WS-O
     MOVE 25 TO WS-E
     PERFORM CHECK-N
*>   Pounce: a fully crouched fox jumps with (0.8 dir.x, 0.9, 0.8 dir.z) added to its motion.
     MOVE 3 TO WS-DX
     MOVE 0 TO WS-DY
     MOVE 4 TO WS-DZ
     MOVE 0.1 TO EN-VX(WS-ROW)
     MOVE 0 TO EN-VY(WS-ROW)
     MOVE 0 TO EN-VZ(WS-ROW)
     CALL "M44-FOX-POUNCE" USING WS-ROW WS-DX WS-DY WS-DZ WS-STARTED
     MOVE "acceptance US15 44§4 Fox pounce: it starts when crouched; flags crouching and pouncing, no longer interested" TO WS-CASE
     COMPUTE WS-O = WS-STARTED * 100 + EN-FOX-FLAGS(WS-ROW)
     MOVE 120 TO WS-E
     PERFORM CHECK-N
     MOVE "acceptance US15 44§4 Fox pounce: vx = 0.1 + 0.8 * 3/5 = 0.58 (the old motion is kept, not scaled)" TO WS-CASE
     COMPUTE WS-O ROUNDED = EN-VX(WS-ROW) * 1000
     MOVE 580 TO WS-E
     PERFORM CHECK-N
     MOVE "acceptance US15 44§4 Fox pounce: vy = 0.9 and vz = 0.8 * 4/5 = 0.64" TO WS-CASE
     COMPUTE WS-O ROUNDED = EN-VY(WS-ROW) * 1000 + EN-VZ(WS-ROW) * 1000000
     MOVE 640900 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO EN-ON-GROUND(WS-ROW)
     MOVE 1 TO WS-ALIVE
     CALL "M44-FOX-POUNCE-STILL" USING WS-ROW WS-ALIVE WS-CONT
     MOVE "acceptance US15 44§4 Fox pounce: it goes on while the target lives and the fox is in the air" TO WS-CASE
     MOVE WS-CONT TO WS-O
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     CALL "M44-FOX-POUNCE-STILL" USING WS-ROW WS-ALIVE WS-CONT
     MOVE "acceptance US15 44§4 Fox pounce: landing ends it and clears the pouncing flag" TO WS-CASE
     COMPUTE WS-O = WS-CONT * 100 + EN-FOX-FLAGS(WS-ROW)
     MOVE 4 TO WS-E
     PERFORM CHECK-N
*>   A fox that is not crouched does not pounce; a not fully crouched one neither.
     MOVE 0 TO EN-FOX-FLAGS(WS-ROW) EN-FOX-CROUCH(WS-ROW)
     CALL "M44-FOX-POUNCE" USING WS-ROW WS-DX WS-DY WS-DZ WS-STARTED
     MOVE "acceptance US15 44§4 Fox pounce: a standing fox does not pounce" TO WS-CASE
     MOVE WS-STARTED TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE 4 TO EN-FOX-FLAGS(WS-ROW)
     MOVE 24 TO EN-FOX-CROUCH(WS-ROW)
     CALL "M44-FOX-POUNCE" USING WS-ROW WS-DX WS-DY WS-DZ WS-STARTED
     MOVE "acceptance US15 44§4 Fox pounce: a fox crouched for 24 ticks is not fully crouched yet" TO WS-CASE
     MOVE WS-STARTED TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE 25 TO EN-FOX-CROUCH(WS-ROW)
     MOVE 1 TO EN-FOX-FLAGS(WS-ROW)
     MOVE 0 TO WS-ALIVE
     MOVE 0 TO EN-ON-GROUND(WS-ROW)
     MOVE 16 TO EN-FOX-FLAGS(WS-ROW)
     CALL "M44-FOX-POUNCE-STILL" USING WS-ROW WS-ALIVE WS-CONT
     MOVE "acceptance US15 44§4 Fox pounce: the death of the target ends it" TO WS-CASE
     COMPUTE WS-O = WS-CONT * 100 + EN-FOX-FLAGS(WS-ROW)
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     CALL "M44-FOX-POUNCE-STILL" USING WS-ROW WS-ALIVE WS-CONT
*>   Metadata 19: the flags byte is sent when it is not 0 (3 bytes: index, serializer, value).
     MOVE 0 TO EN-FOX-FLAGS(WS-ROW)
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
     MOVE TP-LENGTH TO WS-LEN0
     MOVE 12 TO EN-FOX-FLAGS(WS-ROW)
     CALL "MOB-DATA-VALUES" USING WS-ROW WS-I WS-J WS-STATUS
     MOVE "acceptance US15 44§4 Fox flags: a fox with flags is listed as needing entity data" TO WS-CASE
     MOVE WS-STATUS TO WS-O
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     CALL "PB-FREE" USING TP-BUFFER
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
     MOVE "acceptance US15 44§4 Fox flags: the flags byte adds one BYTE entry (index 19, serializer 0, value) = 3 bytes" TO WS-CASE
     COMPUTE WS-O = TP-LENGTH - WS-LEN0
     MOVE 3 TO WS-E
     PERFORM CHECK-N
     CALL "PB-FREE" USING TP-BUFFER
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-44-FOX.
 COPY CORETEST.
 COPY MOBSPTEST.
