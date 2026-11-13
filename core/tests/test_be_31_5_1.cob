*> Test of 31-5 section 1, Types, blocks, tickers (core/src/be-31-5.cob; T0921): the six types with keys, ids, valid blocks, tag kinds and tickers.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-5-1.
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
 01 WS-N24                PIC X(24).
 01 WS-N32                PIC X(32).
 01 WS-PK                 PIC X(32).
 01 WS-SK                 PIC X(32).
 01 WS-PASSES.
    05 WS-PASS            BINARY-LONG OCCURS 4 TIMES.
 01 WS-OFFS.
    05 WS-OFF             OCCURS 64 TIMES.
       10 WS-OX           BINARY-LONG.
       10 WS-OY           BINARY-LONG.
       10 WS-OZ           BINARY-LONG.
 01 WS-TX                 PIC X(64).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-5§1 Types, blocks, tickers: types (1): key by registry id (beacon 15, conduit 25, end_portal 14, end_gateway 22, piston 11, creaking_heart 10), update tag kind (1 custom only) and the Block Entity Data packet" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 15 TO WS-A
     CALL "BE-TYPE-INFO" USING WS-A WS-N24 WS-LEN WS-B
     CALL "BE-SYNC-INFO" USING WS-A WS-C WS-E
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 25 TO WS-A
     CALL "BE-TYPE-INFO" USING WS-A WS-N24 WS-LEN WS-B
     CALL "BE-SYNC-INFO" USING WS-A WS-C WS-E
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 14 TO WS-A
     CALL "BE-TYPE-INFO" USING WS-A WS-N24 WS-LEN WS-B
     CALL "BE-SYNC-INFO" USING WS-A WS-C WS-E
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 22 TO WS-A
     CALL "BE-TYPE-INFO" USING WS-A WS-N24 WS-LEN WS-B
     CALL "BE-SYNC-INFO" USING WS-A WS-C WS-E
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 11 TO WS-A
     CALL "BE-TYPE-INFO" USING WS-A WS-N24 WS-LEN WS-B
     CALL "BE-SYNC-INFO" USING WS-A WS-C WS-E
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 10 TO WS-A
     CALL "BE-TYPE-INFO" USING WS-A WS-N24 WS-LEN WS-B
     CALL "BE-SYNC-INFO" USING WS-A WS-C WS-E
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "beacon 1 1 conduit 1 1 end_portal 0 0 end_gateway 1 1 piston 1 0 creaking_heart 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-5§1 Types, blocks, tickers: valid blocks (1): each type has the block of its name (the piston entity belongs to moving_piston, not to the piston block)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:beacon" TO WS-KEY
     MOVE 16 TO WS-SVL
     MOVE 15 TO WS-A
     CALL "BE-VALID-BLOCK" USING WS-A WS-KEY WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:conduit" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 25 TO WS-A
     CALL "BE-VALID-BLOCK" USING WS-A WS-KEY WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:end_portal" TO WS-KEY
     MOVE 20 TO WS-SVL
     MOVE 14 TO WS-A
     CALL "BE-VALID-BLOCK" USING WS-A WS-KEY WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:end_gateway" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 22 TO WS-A
     CALL "BE-VALID-BLOCK" USING WS-A WS-KEY WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:moving_piston" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 11 TO WS-A
     CALL "BE-VALID-BLOCK" USING WS-A WS-KEY WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:creaking_heart" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 10 TO WS-A
     CALL "BE-VALID-BLOCK" USING WS-A WS-KEY WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:piston" TO WS-KEY
     MOVE 16 TO WS-SVL
     MOVE 11 TO WS-A
     CALL "BE-VALID-BLOCK" USING WS-A WS-KEY WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:conduit" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 15 TO WS-A
     CALL "BE-VALID-BLOCK" USING WS-A WS-KEY WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 1 1 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-5§1 Types, blocks, tickers: tickers (1): server and client ticker per type (1 beacon tick on both sides, 3 conduit serverTick and 2 clientTick, 5 gateway portalTick and 4 beamAnimationTick, 6 piston on both, 7" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 15 TO WS-A
     CALL "BE5-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 25 TO WS-A
     CALL "BE5-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 14 TO WS-A
     CALL "BE5-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 22 TO WS-A
     CALL "BE5-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 11 TO WS-A
     CALL "BE5-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 10 TO WS-A
     CALL "BE5-REGISTRATION" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 3 2 0 0 5 4 6 6 7 0" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-5-1.

 COPY CORETEST.
