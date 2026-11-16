*> Implementation test (US15; docs/protocol/44-residual-mob-questions-4-land-animals.md section 4, Panda): eating and the flags and eating metadata.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-PANDA.
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
 01 WS-ROLL               BINARY-LONG.
 01 WS-DONE               BINARY-LONG.

 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:panda" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     MOVE 1 TO WS-ROLL
     CALL "M44-PANDA-EAT-START" USING WS-ROW WS-ROLL WS-DONE
     MOVE "acceptance US15 44§7 Panda eating: a standing panda does not start" TO WS-CASE
     COMPUTE WS-O = WS-DONE * 100 + EN-PANDA-EAT(WS-ROW)
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE 8 TO EN-PANDA-FLAGS(WS-ROW)
     CALL "M44-PANDA-EAT-START" USING WS-ROW WS-ROLL WS-DONE
     MOVE "acceptance US15 44§7 Panda eating: a sitting panda with an empty mouth does not start" TO WS-CASE
     COMPUTE WS-O = WS-DONE * 100 + EN-PANDA-EAT(WS-ROW)
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE 5 TO EN-PANDA-HAND(WS-ROW)
     MOVE 0 TO WS-ROLL
     CALL "M44-PANDA-EAT-START" USING WS-ROW WS-ROLL WS-DONE
     MOVE "acceptance US15 44§7 Panda eating: only the roll nextInt(80) = 1 starts it (0 does not)" TO WS-CASE
     MOVE WS-DONE TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO WS-ROLL
     CALL "M44-PANDA-EAT-START" USING WS-ROW WS-ROLL WS-DONE
     MOVE "acceptance US15 44§7 Panda eating: sitting, holding bamboo, roll 1: eating starts (counter 1)" TO WS-CASE
     COMPUTE WS-O = WS-DONE * 100 + EN-PANDA-EAT(WS-ROW)
     MOVE 101 TO WS-E
     PERFORM CHECK-N
     CALL "M44-PANDA-EAT-START" USING WS-ROW WS-ROLL WS-DONE
     MOVE "acceptance US15 44§7 Panda eating: an eating panda does not start again" TO WS-CASE
     COMPUTE WS-O = WS-DONE * 100 + EN-PANDA-EAT(WS-ROW)
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO WS-ROLL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 99
         CALL "M44-PANDA-EAT-TICK" USING WS-ROW WS-ROLL WS-DONE
     END-PERFORM
     MOVE "acceptance US15 44§7 Panda eating: at counter 100 the item is not eaten yet" TO WS-CASE
     COMPUTE WS-O = WS-DONE * 1000 + EN-PANDA-EAT(WS-ROW)
     MOVE 100 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-ROLL
     CALL "M44-PANDA-EAT-TICK" USING WS-ROW WS-ROLL WS-DONE
     MOVE "acceptance US15 44§7 Panda eating: past 100 a roll other than 1 does not finish it" TO WS-CASE
     COMPUTE WS-O = WS-DONE * 1000 + EN-PANDA-EAT(WS-ROW)
     MOVE 101 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO WS-ROLL
     CALL "M44-PANDA-EAT-TICK" USING WS-ROW WS-ROLL WS-DONE
     MOVE "acceptance US15 44§7 Panda eating: roll 1 past 100: item consumed, eating and sitting stop" TO WS-CASE
     COMPUTE WS-O = WS-DONE * 1000 + EN-PANDA-EAT(WS-ROW) * 100 + EN-PANDA-HAND(WS-ROW) * 10 + EN-PANDA-FLAGS(WS-ROW)
     MOVE 1000 TO WS-E
     PERFORM CHECK-N
*>   Before 80 ticks the finish roll is not drawn at all: counter 50 with roll 1 keeps eating.
     MOVE 50 TO EN-PANDA-EAT(WS-ROW)
     MOVE 5 TO EN-PANDA-HAND(WS-ROW)
     MOVE 8 TO EN-PANDA-FLAGS(WS-ROW)
     CALL "M44-PANDA-EAT-TICK" USING WS-ROW WS-ROLL WS-DONE
     MOVE "acceptance US15 44§7 Panda eating: before 80 ticks the finish roll is not used" TO WS-CASE
     COMPUTE WS-O = WS-DONE * 1000 + EN-PANDA-EAT(WS-ROW)
     MOVE 51 TO WS-E
     PERFORM CHECK-N
*>   Metadata: eating counter (20) and flags (23: sitting 8) are sent when set.
     MOVE 0 TO EN-PANDA-EAT(WS-ROW) EN-PANDA-FLAGS(WS-ROW)
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
     MOVE TP-LENGTH TO WS-LEN0
     CALL "PB-FREE" USING TP-BUFFER
     MOVE 8 TO EN-PANDA-FLAGS(WS-ROW)
     MOVE 40 TO EN-PANDA-EAT(WS-ROW)
     CALL "MOB-DATA-VALUES" USING WS-ROW WS-I WS-J WS-STATUS
     MOVE "acceptance US15 44§7 Panda flags: a sitting eating panda needs entity data" TO WS-CASE
     MOVE WS-STATUS TO WS-O
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
     MOVE "acceptance US15 44§7 Panda flags: the eating counter 40 adds one INT entry (index 20, serializer 1, VarInt) = 3 bytes" TO WS-CASE
     COMPUTE WS-O = TP-LENGTH - WS-LEN0
     MOVE 3 TO WS-E
     PERFORM CHECK-N
     MOVE TP-LENGTH TO WS-LEN0
     CALL "PB-FREE" USING TP-BUFFER
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-44-PANDA.
 COPY CORETEST.
 COPY MOBSPTEST.
