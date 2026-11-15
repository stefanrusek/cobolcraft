*> Test of 31-6 section 2, The command block entity (core/src/be-31-6.cob; T0935): state, saved keys in write order, lenient load, mode of the block.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-6-2.
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
     MOVE "acceptance US12 31-6§2 The command block entity: fresh entity saves the keys of 12.1 in order (Command empty here; no CustomName, LastOutput, LastExecution), defaults trackOutput 1 and updateLastExecution 1, lastExecution -1" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:command_block" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 23 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 7) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{Command:,SuccessCount:0,TrackOutput:1,UpdateLastExecution:1,powered:0,conditionMet:0,auto:0} 1 1 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§2 The command block entity: round trip (2.2, 2.3): every key loads and saves back in the order Command, SuccessCount, CustomName, TrackOutput, LastOutput, UpdateLastExecution, LastExecution, powered," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:command_block" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 23 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Command" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "say hi" TO WS-SV
     MOVE 6 TO WS-SVL
     PERFORM NB-S
     MOVE "SuccessCount" TO WS-NM
     MOVE 12 TO WS-NML
     MOVE 3 TO WS-NV
     PERFORM NB-I
     MOVE "CustomName" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "Boss" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "TrackOutput" TO WS-NM
     MOVE 11 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     MOVE "LastOutput" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "[14:03:07]hi" TO WS-SV
     MOVE 12 TO WS-SVL
     PERFORM NB-S
     MOVE "UpdateLastExecution" TO WS-NM
     MOVE 19 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     MOVE "LastExecution" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 99 TO WS-LV
     PERFORM NB-LONG
     MOVE "powered" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     MOVE "conditionMet" TO WS-NM
     MOVE 12 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     MOVE "auto" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{Command:say hi,SuccessCount:3,CustomName:Boss,TrackOutput:1,LastOutput:[14:03:07]hi,UpdateLastExecu" &
         "tion:1,LastExecution:99,powered:1,conditionMet:1,auto:1} 99 12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§2 The command block entity: load rules (2.3, validation 2): with TrackOutput false LastOutput is dropped, with UpdateLastExecution false LastExecution is -1; neither is written" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:command_block" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 23 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Command" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "x" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "TrackOutput" TO WS-NM
     MOVE 11 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     MOVE "LastOutput" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "gone" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "UpdateLastExecution" TO WS-NM
     MOVE 19 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     MOVE "LastExecution" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 5 TO WS-LV
     PERFORM NB-LONG
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{Command:x,SuccessCount:0,TrackOutput:0,UpdateLastExecution:0,powered:0,conditionMet:0,auto:0} -1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§2 The command block entity: load rules (2.3): the dropping does not depend on the order of the keys" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:command_block" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 23 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "LastOutput" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "late" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "TrackOutput" TO WS-NM
     MOVE 11 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     MOVE "LastExecution" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 5 TO WS-LV
     PERFORM NB-LONG
     MOVE "UpdateLastExecution" TO WS-NM
     MOVE 19 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§2 The command block entity: load (2.3): a command longer than the 256 bytes kept is cut" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:command_block" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 23 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE ALL "a" TO WS-OUT
     MOVE "Command" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 300 TO WS-SVL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NML WS-OUT WS-SVL
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     MOVE BE-CMD-LENGTH(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "256" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§2 The command block entity: load (2.3): an empty compound gives the defaults (Command empty, count 0, track and update true, no last execution, not powered, no condition, not auto); a key of the wrong tag" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:command_block" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 23 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 4 TO BE-XI(WS-IDX, 4)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Command" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 5 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     MOVE BE-CMD-LENGTH(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 7) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SEED(WS-IDX) TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 1 1 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§2 The command block entity: LastExecution of the current game time is written when updateLastExecution is set and the value is not -1" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:command_block" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 23 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 77 TO BE-SEED(WS-IDX)
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{Command:,SuccessCount:0,TrackOutput:1,UpdateLastExecution:1,LastExecution:77,powered:0,conditionMet" &
         ":0,auto:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§2 The command block entity: mode (2.4): command_block REDSTONE 2, repeating AUTO 1, chain SEQUENCE 0 (the order of the packet), any other block REDSTONE" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-N48
     MOVE "minecraft:command_block" TO WS-N48
     MOVE 23 TO WS-SVL
     CALL "BE6-MODE" USING WS-N48 WS-SVL WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE SPACES TO WS-N48
     MOVE "minecraft:repeating_command_block" TO WS-N48
     MOVE 33 TO WS-SVL
     CALL "BE6-MODE" USING WS-N48 WS-SVL WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE SPACES TO WS-N48
     MOVE "minecraft:chain_command_block" TO WS-N48
     MOVE 29 TO WS-SVL
     CALL "BE6-MODE" USING WS-N48 WS-SVL WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE SPACES TO WS-N48
     MOVE "minecraft:stone" TO WS-N48
     MOVE 15 TO WS-SVL
     CALL "BE6-MODE" USING WS-N48 WS-SVL WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE "2 1 0 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-6§2 The command block entity: isConditional (2.4): false without a level or when the block is not a command block, else the property (level, block is command block, property in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE6-IS-CONDITIONAL" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE6-IS-CONDITIONAL" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE6-IS-CONDITIONAL" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE6-IS-CONDITIONAL" USING WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 0" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-6-2.

 COPY CORETEST.
