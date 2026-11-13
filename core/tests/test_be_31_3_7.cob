*> Test of 31-3 section 7, Beds (core/src/be-31-3.cob; T0901): no bed block entity type exists: the registry has no bed and a saved bed entry is skipped with the invalid-type result.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-3-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-SHOW                PIC -(9)9.
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
 01 WS-FA                FLOAT-LONG.
 01 WS-FB                FLOAT-LONG.
 01 WS-FC                FLOAT-LONG.
 01 WS-FD                FLOAT-LONG.
 01 WS-FE                FLOAT-LONG.
 01 WS-FF                FLOAT-LONG.
 01 WS-U16                PIC X(16) VALUE "0123456789abcdef".
 01 WS-V16                PIC X(16) VALUE "fedcba9876543210".
 01 WS-N24                PIC X(24).
 01 WS-N32                PIC X(32).
 01 WS-TX                 PIC X(384).
 01 WS-LINES.
    05 WS-LINE            OCCURS 4 TIMES.
       10 WS-LINE-LEN     BINARY-LONG.
       10 WS-LINE-TEXT    PIC X(384).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-3§7 Beds: registry (7): bed and white_bed are no block entity type and none of the 49 type keys contains bed" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "bed" TO WS-N24
     MOVE 3 TO WS-LEN
     CALL "BE-TYPE-ID" USING WS-N24 WS-LEN WS-A
     MOVE "white_bed" TO WS-N24
     MOVE 9 TO WS-LEN
     CALL "BE-TYPE-ID" USING WS-N24 WS-LEN WS-B
     MOVE 0 TO WS-F
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 48
     CALL "BE-TYPE-INFO" USING WS-J WS-N24 WS-LEN WS-C
     INSPECT WS-N24 TALLYING WS-F FOR ALL "bed"
     END-PERFORM
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "-1 -1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§7 Beds: stored bed (7): a block_entities compound with id minecraft:bed is skipped with the invalid-type result 2 (no entity is created, index 0)" TO TL-CASE
     PERFORM BEGIN-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:bed" TO WS-SV
     MOVE 13 TO WS-SVL
     PERFORM NB-S
     MOVE "x" TO WS-NM
     MOVE 1 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     MOVE "y" TO WS-NM
     MOVE 1 TO WS-NML
     MOVE 64 TO WS-NV
     PERFORM NB-I
     MOVE "z" TO WS-NM
     MOVE 1 TO WS-NML
     MOVE 2 TO WS-NV
     PERFORM NB-I
     MOVE "flag" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE 0 TO PB-POS
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE 17 TO WS-SVL
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE-LOAD-CHUNK-ENTRY" USING PB-BUFFER WS-D WS-A WS-B WS-KEY WS-SVL WS-C WS-IDX
     CALL "PB-FREE" USING PB-BUFFER
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-IDX TO WS-SHOW
     PERFORM ADD-N
     MOVE "2 0" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-3-7.

 COPY CORETEST.
