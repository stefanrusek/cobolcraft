*> Test of 31-6 section 10, The test instance block entity (core/src/be-31-6.cob; T0951): keys, data transitions, geometry, beam colours and the action handler.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-6-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-SHOW                PIC -(10)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-OUT                 PIC X(8192).
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-T10                 BINARY-LONG VALUE 10.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-NM                  PIC X(32).
 01 WS-NML                 BINARY-LONG.
 01 WS-SV                  PIC X(256).
 01 WS-SVL                 BINARY-LONG.
 01 WS-NV                  BINARY-LONG.
 01 WS-LV                  BINARY-DOUBLE.
 01 WS-FV                  FLOAT-SHORT.
 01 WS-IA.
    05 WS-IAV              BINARY-LONG OCCURS 8 TIMES.
 01 WS-LT                  BINARY-LONG.
 01 WS-LC                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KP                  BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-P                 BINARY-LONG.
 01 WS-Q                 BINARY-LONG.
 01 WS-R                 BINARY-LONG.
 01 WS-S                 BINARY-LONG.
 01 WS-U                 BINARY-LONG.
 01 WS-V                 BINARY-LONG.
 01 WS-W                 BINARY-LONG.
 01 WS-EV                BINARY-LONG.
 01 WS-O1                 BINARY-LONG.
 01 WS-O2                 BINARY-LONG.
 01 WS-O3                 BINARY-LONG.
 01 WS-O4                 BINARY-LONG.
 01 WS-O5                 BINARY-LONG.
 01 WS-O6                 BINARY-LONG.
 01 WS-O7                 BINARY-LONG.
 01 WS-FA                FLOAT-LONG.
 01 WS-FB                FLOAT-LONG.
 01 WS-FC                FLOAT-LONG.
 01 WS-FD                FLOAT-LONG.
 01 WS-FE                FLOAT-LONG.
 01 WS-FF                FLOAT-LONG.
 01 WS-FS1                FLOAT-SHORT.
 01 WS-FS2                FLOAT-SHORT.
 01 WS-N24                PIC X(24).
 01 WS-N48                PIC X(48).
 01 WS-T64                PIC X(64).
 01 WS-T256               PIC X(256).
 01 WS-T2                 PIC X(64).
 01 WS-TAB.
    05 WS-TV              BINARY-LONG OCCURS 64 TIMES.
 01 WS-LONG1              BINARY-DOUBLE.
 01 WS-LONG2              BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-6§10 The test instance block entity: new entity (10.1): data with no test, size 0 0 0, rotation none, ignore_entities false, status cleared; errors is not written when empty" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{data:{size:I[0,0,0],rotation:none,ignore_entities:0,status:cleared}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§10 The test instance block entity: round trip (10.1): data keys in codec order (test, size, rotation with lower-case names, ignore_entities, status, error_message) and the errors list of {pos, text} load and" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "data" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "test" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "minecraft:foo" TO WS-SV
     MOVE 13 TO WS-SVL
     PERFORM NB-S
     MOVE "size" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE 5 TO WS-IAV(1)
     MOVE 3 TO WS-IAV(2)
     MOVE 7 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "rotation" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE "clockwise_90" TO WS-SV
     MOVE 12 TO WS-SVL
     PERFORM NB-S
     MOVE "ignore_entities" TO WS-NM
     MOVE 15 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     MOVE "status" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE "finished" TO WS-SV
     MOVE 8 TO WS-SVL
     PERFORM NB-S
     MOVE "error_message" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE "boom" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "errors" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "text" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "oops" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 4 TO WS-IAV(1)
     MOVE 5 TO WS-IAV(2)
     MOVE 6 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "text" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "bad" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-XI(WS-IDX, 9) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{data:{test:minecraft:foo,size:I[5,3,7],rotation:clockwise_90,ignore_entities:1,status:finished,erro" &
         "r_message:boom},errors:[{pos:I[1,2,3],text:oops},{pos:I[4,5,6],text:bad}]} 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§10 The test instance block entity: load (10.1): an unknown key inside data or an error marker is skipped; more than 4 markers keep the first 4" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "data" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "zzz" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE "x" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "size" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     PERFORM NB-E
     MOVE "errors" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 5 TO WS-LC
     PERFORM NB-L
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 0 TO WS-IAV(1)
     MOVE 0 TO WS-IAV(2)
     MOVE 0 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "junk" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "q" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "text" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "e0" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 1 TO WS-IAV(1)
     MOVE 1 TO WS-IAV(2)
     MOVE 1 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "junk" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "q" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "text" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "e1" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 2 TO WS-IAV(1)
     MOVE 2 TO WS-IAV(2)
     MOVE 2 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "junk" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "q" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "text" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "e2" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 3 TO WS-IAV(1)
     MOVE 3 TO WS-IAV(2)
     MOVE 3 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "junk" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "q" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "text" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "e3" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "pos" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 4 TO WS-IAV(1)
     MOVE 4 TO WS-IAV(2)
     MOVE 4 TO WS-IAV(3)
     MOVE 3 TO WS-LC
     PERFORM NB-IA
     MOVE "junk" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "q" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "text" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "e4" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-XI(WS-IDX, 9) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{data:{size:I[1,2,3],rotation:none,ignore_entities:0,status:cleared},errors:[{pos:I[0,0,0],text:e0}," &
         "{pos:I[1,1,1],text:e1},{pos:I[2,2,2],text:e2},{pos:I[3,3,3],text:e3}]} 4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§10 The test instance block entity: load (10.1): a missing data compound leaves the data at its defaults (BE-LOAD resets the cells first), the error list is cleared and re-read; an invalid rotation or status" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 4 TO BE-XI(WS-IDX, 2)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "data" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "rotation" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE "CLOCKWISE_90" TO WS-SV
     MOVE 12 TO WS-SVL
     PERFORM NB-S
     MOVE "status" TO WS-NM
     MOVE 6 TO WS-NML
     MOVE "done" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{data:{size:I[0,0,0],rotation:none,ignore_entities:0,status:cleared}} {data:{size:I[0,0,0],rotation:" &
         "none,ignore_entities:0,status:cleared}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§10 The test instance block entity: data transitions (10.2): withStatus replaces the status and clears the error message; withError sets finished and the message; setRunning and setSuccess are withStatus 1 and" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 7)
     MOVE "bad" TO BE-XT(WS-IDX, 2)
     MOVE 3 TO BE-XI(WS-IDX, 8)
     MOVE 0 TO WS-A
     CALL "BE6-TI-WITH-STATUS" USING WS-IDX WS-A
     MOVE BE-XI(WS-IDX, 7) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE SPACES TO WS-T64
     MOVE "boom" TO WS-T64
     MOVE 4 TO WS-LEN
     CALL "BE6-TI-WITH-ERROR" USING WS-IDX WS-T64 WS-LEN
     MOVE BE-XI(WS-IDX, 7) TO WS-SHOW
     PERFORM ADD-N
     STRING BE-XT(WS-IDX, 2)(1:BE-XI(WS-IDX, 8)) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 1 TO WS-A
     CALL "BE6-TI-WITH-STATUS" USING WS-IDX WS-A
     MOVE BE-XI(WS-IDX, 7) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 2 boom 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§10 The test instance block entity: error markers (10.2): markError appends a marker and marks the entity changed (up to 4 here, a fifth is dropped), clearErrorMarkers empties the list and reports a change" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE SPACES TO WS-T64
     MOVE "e1" TO WS-T64
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 3 TO WS-C
     MOVE 2 TO WS-LEN
     CALL "BE6-TI-MARK" USING WS-IDX WS-A WS-B WS-C WS-T64 WS-LEN WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 9) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 10) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 12) TO WS-SHOW
     PERFORM ADD-N
     STRING BE-XT(WS-IDX, 3)(1:BE-XI(WS-IDX, 23)) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "BE6-TI-MARK" USING WS-IDX WS-A WS-B WS-C WS-T64 WS-LEN WS-E
     CALL "BE6-TI-MARK" USING WS-IDX WS-A WS-B WS-C WS-T64 WS-LEN WS-E
     CALL "BE6-TI-MARK" USING WS-IDX WS-A WS-B WS-C WS-T64 WS-LEN WS-E
     CALL "BE6-TI-MARK" USING WS-IDX WS-A WS-B WS-C WS-T64 WS-LEN WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 9) TO WS-SHOW
     PERFORM ADD-N
     CALL "BE6-TI-CLEAR" USING WS-IDX WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 9) TO WS-SHOW
     PERFORM ADD-N
     CALL "BE6-TI-CLEAR" USING WS-IDX WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 1 3 e1 0 4 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§10 The test instance block entity: geometry (10.3, example 12.8): structure origin = block + padding + (0, 1, 1), the size with x and z swapped for the quarter turns, inclusive structure box, test box" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 100 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 100 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 5 TO BE-XI(WS-IDX, 2)
     MOVE 3 TO BE-XI(WS-IDX, 3)
     MOVE 7 TO BE-XI(WS-IDX, 4)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE6-TI-GEOM" USING WS-IDX WS-A WS-B WS-TAB
     MOVE WS-TV(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(5) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(6) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(7) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(8) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(9) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(10) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(11) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(12) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(13) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(14) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(15) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(16) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(17) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(18) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(19) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(20) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(21) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(22) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(23) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(24) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(25) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(26) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(27) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 100 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 100 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 5 TO BE-XI(WS-IDX, 2)
     MOVE 3 TO BE-XI(WS-IDX, 3)
     MOVE 7 TO BE-XI(WS-IDX, 4)
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE6-TI-GEOM" USING WS-IDX WS-A WS-B WS-TAB
     MOVE WS-TV(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(5) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(6) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(7) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(8) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(9) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(10) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(11) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(12) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(13) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(14) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(15) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(16) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(17) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(18) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(19) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(20) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(21) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(22) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(23) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(24) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(25) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(26) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(27) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 100 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 100 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 5 TO BE-XI(WS-IDX, 2)
     MOVE 3 TO BE-XI(WS-IDX, 3)
     MOVE 7 TO BE-XI(WS-IDX, 4)
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE6-TI-GEOM" USING WS-IDX WS-A WS-B WS-TAB
     MOVE WS-TV(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(5) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(6) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(7) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(8) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(9) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(10) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(11) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(12) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(13) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(14) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(15) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(16) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(17) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(18) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(19) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(20) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(21) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(22) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(23) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(24) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(25) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(26) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(27) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_instance_block" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 46 TO WS-NV
     MOVE 100 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 100 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 5 TO BE-XI(WS-IDX, 2)
     MOVE 3 TO BE-XI(WS-IDX, 3)
     MOVE 7 TO BE-XI(WS-IDX, 4)
     MOVE 3 TO WS-A
     MOVE 3 TO WS-B
     CALL "BE6-TI-GEOM" USING WS-IDX WS-A WS-B WS-TAB
     MOVE WS-TV(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(5) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(6) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(7) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(8) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(9) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(10) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(11) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(12) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(13) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(14) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(15) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(16) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(17) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(18) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(19) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(20) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(21) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(22) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(23) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(24) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(25) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(26) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV(27) TO WS-SHOW
     PERFORM ADD-N
     MOVE "102 67 103 7 3 5 102 67 103 108 69 107 100 65 101 110 71 109 108 67 103 2 3 3 7 3 5 100 65 101 5 3 7" &
         " 100 65 101 104 67 107 100 65 101 104 67 107 100 65 101 0 1 1 5 3 7 101 66 102 5 3 7 101 66 102 105 " &
         "68 108 100 65 101 106 69 109 105 66 108 1 2 2 5 3 7 103 68 104 7 3 5 103 68 104 109 70 108 100 65 10" &
         "1 112 73 111 103 68 108 3 4 4 7 3 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§10 The test instance block entity: effective rotation (10.3): the test definition rotation composed with the data rotation (a quarter-turn sum modulo 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE6-ROT-COMPOSE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE6-ROT-COMPOSE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 3 TO WS-B
     CALL "BE6-ROT-COMPOSE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 3 TO WS-B
     CALL "BE6-ROT-COMPOSE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE6-ROT-COMPOSE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE6-ROT-COMPOSE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 2 1 2 2 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§10 The test instance block entity: beam colours (10.3): cleared none, running grey 128 128 128, finished green, finished with an error red for a required test and orange 255 128 0 for an optional one (status," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE6-TI-BEAM" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE6-TI-BEAM" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE6-TI-BEAM" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE6-TI-BEAM" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE6-TI-BEAM" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 0 0 1 128 128 128 1 0 255 0 1 255 0 0 1 255 128 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§10 The test instance block entity: Test Instance Block Action (10.4): without the rights or the entity only the final block update happens; INIT and QUERY answer with a Test Instance Block Status packet; SET," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 2 TO WS-C
     CALL "BE6-TI-ACTION" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 2 TO WS-C
     CALL "BE6-TI-ACTION" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE6-TI-ACTION" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE6-TI-ACTION" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 2 TO WS-C
     CALL "BE6-TI-ACTION" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 3 TO WS-C
     CALL "BE6-TI-ACTION" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 4 TO WS-C
     CALL "BE6-TI-ACTION" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 5 TO WS-C
     CALL "BE6-TI-ACTION" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 6 TO WS-C
     CALL "BE6-TI-ACTION" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 0 0 1 0 1 0 0 1 0 1 0 1 0 1 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 ADD-N.
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> Saves entity WS-IDX in form WS-FORM, renders the compound and appends it to TL-OBSERVED.
 SAVE-RENDER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> The NBT builders of the cases (name WS-NM and length WS-NML, text WS-SV and length WS-SVL, number WS-NV, list type WS-LT and count WS-LC).
 NB-S.
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NML WS-SV WS-SVL
     .
 NB-I.
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-LONG.
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WS-NM WS-NML WS-LV
     .
 NB-IA.
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WS-NM WS-NML WS-LC WS-IA
     .
 NB-FLOAT.
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-NM WS-NML WS-FV
     .
 NB-B.
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-C.
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NM WS-NML
     .
 NB-E.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     .
 NB-STACK.
     MOVE 0 TO WS-KP
     CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-ITEM WS-NV WS-KP
     .
 NB-L.
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-NM WS-NML WS-LT WS-LC
     .

*> Loads entity WS-IDX from the compound the case built in PB-BUFFER (the closing End tag is written here).
 LOAD-BUFFER.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-IDX PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     .
 END PROGRAM TEST-BE-31-6-10.

 COPY CORETEST.
