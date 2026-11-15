*> Test of 31-7 section 2, Registration, blocks, tickers (core/src/be-31-7.cob; T0957): blocks, tickers by side, light levels and update tag kinds.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-7-2.
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
 01 WS-FG                FLOAT-LONG.
 01 WS-FH                FLOAT-LONG.
 01 WS-FS1                FLOAT-SHORT.
 01 WS-FS2                FLOAT-SHORT.
 01 WS-FS3                FLOAT-SHORT.
 01 WS-FS4                FLOAT-SHORT.
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
     MOVE "acceptance US12 31-7§2 Registration, blocks, tickers: valid blocks (2): each type has exactly one valid block, spawner, trial_spawner and vault" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 9 TO WS-A
     MOVE SPACES TO WS-N48
     MOVE "minecraft:spawner" TO WS-N48
     MOVE 17 TO WS-SVL
     CALL "BE-VALID-BLOCK" USING WS-A WS-N48 WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 43 TO WS-A
     MOVE SPACES TO WS-N48
     MOVE "minecraft:trial_spawner" TO WS-N48
     MOVE 23 TO WS-SVL
     CALL "BE-VALID-BLOCK" USING WS-A WS-N48 WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 44 TO WS-A
     MOVE SPACES TO WS-N48
     MOVE "minecraft:vault" TO WS-N48
     MOVE 15 TO WS-SVL
     CALL "BE-VALID-BLOCK" USING WS-A WS-N48 WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 9 TO WS-A
     MOVE SPACES TO WS-N48
     MOVE "minecraft:trial_spawner" TO WS-N48
     MOVE 23 TO WS-SVL
     CALL "BE-VALID-BLOCK" USING WS-A WS-N48 WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 44 TO WS-A
     MOVE SPACES TO WS-N48
     MOVE "minecraft:spawner" TO WS-N48
     MOVE 17 TO WS-SVL
     CALL "BE-VALID-BLOCK" USING WS-A WS-N48 WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 43 TO WS-A
     MOVE SPACES TO WS-N48
     MOVE "minecraft:vault" TO WS-N48
     MOVE 15 TO WS-SVL
     CALL "BE-VALID-BLOCK" USING WS-A WS-N48 WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 1 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§2 Registration, blocks, tickers: update tags (2, 3.2, 4.5, 5.4): the spawner tag is the custom form minus SpawnPotentials (kind 3), the trial spawner kind 7 and the vault kind 8; all three send the Block" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 9 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 43 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 44 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "3 1 7 1 8 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§2 Registration, blocks, tickers: tickers (2): the spawner has BaseSpawner.serverTick (1) and clientTick (2), the trial spawner tickServer (3) and tickClient (4), the vault Server.tick (5) and Client.tick (6);" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 9 TO WS-A
     CALL "BE7-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 43 TO WS-A
     CALL "BE7-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 44 TO WS-A
     CALL "BE7-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     CALL "BE7-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 2 3 4 5 6 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-7§2 Registration, blocks, tickers: light levels (2): trial spawner 0, 4, 8, 8, 8, 0 by state in order, vault inactive 6 and the other three states 12 (type, state in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 43 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 43 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 43 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 43 TO WS-A
     MOVE 3 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 43 TO WS-A
     MOVE 4 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 43 TO WS-A
     MOVE 5 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 44 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 44 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 44 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 44 TO WS-A
     MOVE 3 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 9 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE7-LIGHT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 4 8 8 8 0 6 12 12 12 0" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-7-2.

 COPY CORETEST.
