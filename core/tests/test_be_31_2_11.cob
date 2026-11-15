*> Test of 31-2 section 11, What clients see (core/src/be-31-2.cob; T0887): no entity of part 2 sends a block entity data packet; the clients see block states and menu data.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-2-11.
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
 01 WS-EV                BINARY-LONG.
 01 WS-O1                 BINARY-LONG.
 01 WS-O2                 BINARY-LONG.
 01 WS-O3                 BINARY-LONG.
 01 WS-O4                 BINARY-LONG.
 01 WS-FA                FLOAT-LONG.
 01 WS-FB                FLOAT-LONG.
 01 WS-FC                FLOAT-LONG.
 01 WS-LIST.
    05 WS-L               BINARY-LONG OCCURS 5 TIMES.
 01 WS-DATA.
    05 WS-D10             BINARY-LONG OCCURS 10 TIMES.
 COPY CTRECIPE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-2§11 What clients see: no data path (11, 2.6): the furnaces, brewing stand, hopper, dispenser, dropper, crafter, comparator, daylight detector and chiseled bookshelf have tag kind 0 and no Block Entity Data" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 27 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 28 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 12 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 18 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 5 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 6 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 42 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 19 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 17 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 38 TO WS-A
     CALL "BE-SYNC-INFO" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-2§11 What clients see: nothing is written (11): no packet is built for a brewing stand (written 0, length 0) and the update tag of a crafter has no entries (length 0)" TO TL-CASE
     PERFORM BEGIN-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "BE-DATA-PACKET" USING WS-IDX PB-BUFFER WS-A
     MOVE PB-LENGTH TO WS-B
     CALL "PB-FREE" USING PB-BUFFER
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:crafter" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 42 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER
     MOVE PB-LENGTH TO WS-B
     CALL "PB-FREE" USING PB-BUFFER
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 0" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-2-11.

 COPY CORETEST.
