*> Test of 31-6 section 9, The test block entity (core/src/be-31-6.cob; T0949): keys, mode defaults, trigger, reset, redstone handling, output signal and the Set Test Block handler.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-6-9.
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
     MOVE "acceptance US12 31-6§9 The test block entity: new entity (9.1): mode start, empty message, not powered; saves mode, message, powered" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{mode:start,message:,powered:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§9 The test block entity: round trip (9.1): mode log, message and powered load and save back; the transient triggered is not saved" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "mode" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "log" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "message" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "hello" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "powered" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO BE-XI(WS-IDX, 4)
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{mode:log,message:hello,powered:1}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§9 The test block entity: load defaults (9.1): a missing or invalid mode gives fail" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "mode" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE "Start" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{mode:fail,message:,powered:0} {mode:fail,message:,powered:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§9 The test block entity: trigger (9.2, validation 17): in mode start with a level power the block, update the neighbours and log, leaving triggered false; in log mode log and set triggered; in fail or accept" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE "hi" TO BE-XT(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 1 TO WS-A
     CALL "BE6-TB-TRIGGER" USING WS-IDX WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE "hi" TO BE-XT(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 0 TO WS-A
     CALL "BE6-TB-TRIGGER" USING WS-IDX WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 1)
     MOVE "hi" TO BE-XT(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 1 TO WS-A
     CALL "BE6-TB-TRIGGER" USING WS-IDX WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 1)
     MOVE "hi" TO BE-XT(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 1 TO WS-A
     CALL "BE6-TB-TRIGGER" USING WS-IDX WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 3 TO BE-XI(WS-IDX, 1)
     MOVE "hi" TO BE-XT(WS-IDX, 1)
     MOVE 2 TO BE-XI(WS-IDX, 2)
     MOVE 1 TO WS-A
     CALL "BE6-TB-TRIGGER" USING WS-IDX WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 1 0 0 0 0 1 1 0 0 1 0 0 0 1 0 0 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§9 The test block entity: reset (9.2): clears triggered; in mode start with a level it also clears powered and updates the neighbours" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE 1 TO BE-XI(WS-IDX, 4)
     MOVE 1 TO WS-A
     CALL "BE6-TB-RESET" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE 1 TO BE-XI(WS-IDX, 4)
     MOVE 0 TO WS-A
     CALL "BE6-TB-RESET" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE 1 TO BE-XI(WS-IDX, 4)
     MOVE 1 TO WS-A
     CALL "BE6-TB-RESET" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO BE-XI(WS-IDX, 1)
     MOVE 0 TO BE-XI(WS-IDX, 3)
     MOVE 0 TO BE-XI(WS-IDX, 4)
     MOVE 1 TO WS-A
     CALL "BE6-TB-RESET" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 0 1 0 0 1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§9 The test block entity: neighbourChanged (9.2): only in mode start a rising signal powers and triggers, a falling one unpowers (signal, powered in; trigger, powered out)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 0 TO BE-XI(WS-IDX, 3)
     MOVE 1 TO WS-A
     CALL "BE6-TB-NEIGHBOUR" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE 1 TO WS-A
     CALL "BE6-TB-NEIGHBOUR" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE 0 TO WS-A
     CALL "BE6-TB-NEIGHBOUR" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 0 TO BE-XI(WS-IDX, 3)
     MOVE 0 TO WS-A
     CALL "BE6-TB-NEIGHBOUR" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 1)
     MOVE 0 TO BE-XI(WS-IDX, 3)
     MOVE 1 TO WS-A
     CALL "BE6-TB-NEIGHBOUR" USING WS-IDX WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 0 1 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§9 The test block entity: output signal and log (9.2): 15 while powered in mode start, else 0; log() writes a line only when the message is not blank" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO BE-XI(WS-IDX, 3)
     CALL "BE6-TB-SIGNAL" USING WS-IDX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 1)
     MOVE 0 TO BE-XI(WS-IDX, 3)
     CALL "BE6-TB-SIGNAL" USING WS-IDX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 1)
     MOVE 1 TO BE-XI(WS-IDX, 3)
     CALL "BE6-TB-SIGNAL" USING WS-IDX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE SPACES TO WS-T64
     MOVE 0 TO BE-XI(WS-IDX, 2)
     MOVE WS-T64 TO BE-XT(WS-IDX, 1)
     CALL "BE6-TB-LOG" USING WS-IDX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE SPACES TO WS-T64
     MOVE "   " TO WS-T64
     MOVE 3 TO BE-XI(WS-IDX, 2)
     MOVE WS-T64 TO BE-XT(WS-IDX, 1)
     CALL "BE6-TB-LOG" USING WS-IDX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE SPACES TO WS-T64
     MOVE "x" TO WS-T64
     MOVE 1 TO BE-XI(WS-IDX, 2)
     MOVE WS-T64 TO BE-XT(WS-IDX, 1)
     CALL "BE6-TB-LOG" USING WS-IDX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE "15 0 0 0 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§9 The test block entity: Set Test Block (9.2): ignored without the rights; otherwise setMode (the block property is rewritten) and the message are stored and the block is updated" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE SPACES TO WS-T64
     MOVE "m1" TO WS-T64
     MOVE 0 TO WS-A
     MOVE 2 TO WS-B
     MOVE 2 TO WS-LEN
     CALL "BE6-TB-SET" USING WS-IDX WS-A WS-B WS-T64 WS-LEN WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:test_block" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 45 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE SPACES TO WS-T64
     MOVE "m1" TO WS-T64
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 2 TO WS-LEN
     CALL "BE6-TB-SET" USING WS-IDX WS-A WS-B WS-T64 WS-LEN WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 0 1 2 2" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-6-9.

 COPY CORETEST.
