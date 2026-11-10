*> Test of 31 section 2 (The block entity base model; T0843): creation validates the block against the type's valid set; setChanged marks
*> the chunk unsaved and updates comparators only for a non-air state and an entity with a level; removed flag; getPosFromTag relocation
*> (worked example 2); the four save forms and their key order (2.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-1-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TYPE10              BINARY-LONG VALUE 10.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-N3                  BINARY-LONG.
 01 WS-C1                  PIC 9.
 01 WS-C2                  PIC 9.
 01 WS-C3                  PIC 9.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-FORM                BINARY-LONG.
 01 WS-OUT                 PIC X(8192).
 01 WS-TEXT2               PIC X(8192).
 01 WS-KEY                PIC X(48).
 01 WS-PTR                 BINARY-LONG.
 01 WS-D1                  PIC 9.
 01 WS-D2                  PIC 9.
 01 WS-D3                  PIC 9.
 PROCEDURE DIVISION.
     MOVE "acceptance US12 31-1§2 base model: a chest entity is created at its position for minecraft:chest and refused for minecraft:barrel" TO TL-CASE
     MOVE "minecraft:barrel" TO WS-KEY
     MOVE 16 TO WS-LEN
     MOVE 35 TO WS-X
     MOVE 64 TO WS-Y
     MOVE -3 TO WS-Z
     MOVE 1 TO WS-D
     MOVE 1 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-IDX
     MOVE WS-IDX TO WS-EDIT
     MOVE "minecraft:chest" TO WS-KEY
     MOVE 15 TO WS-LEN
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-IDX
     MOVE WS-IDX TO WS-CHEST
     MOVE BE-X(WS-CHEST) TO WS-EDIT2
     MOVE BE-Z(WS-CHEST) TO WS-EDIT3
     MOVE BE-TYPE(WS-CHEST) TO WS-EDIT4
     MOVE SPACES TO WS-TEXT
     STRING "refused " FUNCTION TRIM(WS-EDIT) " chest " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) " type "
         FUNCTION TRIM(WS-EDIT4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "refused 0 chest 35 -3 type 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§2 base model: setChanged marks the entity changed and asks for comparator updates unless the state is air or the entity is detached" TO TL-CASE
     MOVE 0 TO WS-AIR
     CALL "BE-SET-CHANGED" USING WS-CHEST WS-AIR WS-N1
     MOVE BE-CHANGED(WS-CHEST) TO WS-C1
     MOVE 0 TO BE-CHANGED(WS-CHEST)
     MOVE 1 TO WS-AIR
     CALL "BE-SET-CHANGED" USING WS-CHEST WS-AIR WS-N2
     MOVE BE-CHANGED(WS-CHEST) TO WS-C2
     MOVE 0 TO BE-CHANGED(WS-CHEST)
     MOVE 0 TO BE-DIM(WS-CHEST)
     MOVE 0 TO WS-AIR
     CALL "BE-SET-CHANGED" USING WS-CHEST WS-AIR WS-N3
     MOVE BE-CHANGED(WS-CHEST) TO WS-C3
     MOVE 1 TO BE-DIM(WS-CHEST)
     MOVE SPACES TO WS-TEXT
     MOVE WS-N1 TO WS-D1
     MOVE WS-N2 TO WS-D2
     MOVE WS-N3 TO WS-D3
     STRING WS-C1 WS-D1 " " WS-C2 WS-D2 " " WS-C3 WS-D3 DELIMITED BY SIZE INTO WS-TEXT
     MOVE "11 10 00" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§2 base model: setRemoved and clearRemoved only flip the flag" TO TL-CASE
     MOVE 1 TO WS-FLAG
     CALL "BE-SET-REMOVED" USING WS-CHEST WS-FLAG
     MOVE BE-REMOVED(WS-CHEST) TO WS-EDIT
     MOVE 0 TO WS-FLAG
     CALL "BE-SET-REMOVED" USING WS-CHEST WS-FLAG
     MOVE BE-REMOVED(WS-CHEST) TO WS-EDIT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "10" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§2 base model: getPosFromTag relocates (35, 64, -3) read for chunk (0, -1) to (3, 64, -3) and keeps a position of its own chunk" TO TL-CASE
     MOVE 0 TO WS-CX
     MOVE -1 TO WS-CZ
     CALL "BE-POS-FROM-TAG" USING WS-CX WS-CZ WS-X WS-Y WS-Z WS-RX WS-RY WS-RZ WS-MOVED
     MOVE WS-RX TO WS-EDIT
     MOVE WS-RY TO WS-EDIT2
     MOVE WS-RZ TO WS-EDIT3
     MOVE WS-MOVED TO WS-EDIT4
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) " " FUNCTION TRIM(WS-EDIT4) " "
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE 2 TO WS-CX
     MOVE -1 TO WS-CZ
     CALL "BE-POS-FROM-TAG" USING WS-CX WS-CZ WS-X WS-Y WS-Z WS-RX WS-RY WS-RZ WS-MOVED
     MOVE WS-RX TO WS-EDIT
     MOVE WS-RZ TO WS-EDIT3
     MOVE WS-MOVED TO WS-EDIT4
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT3) " " FUNCTION TRIM(WS-EDIT4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "3 64 -3 1 35 -3 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§2 base model: the four save forms of an empty chest: key order, components always present, id x y z only in the metadata forms" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-FORM
     PERFORM 4 TIMES
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "BE-SAVE" USING WS-CHEST WS-FORM PB-BUFFER
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         MOVE 0 TO PB-POS
         MOVE 0 TO WS-LEN
         MOVE SPACES TO WS-OUT
         CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-TYPE10 WS-OUT WS-LEN
         CALL "PB-FREE" USING PB-BUFFER
         STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         ADD 1 TO WS-FORM
     END-PERFORM
     MOVE '{Items:[],components:{}} {Items:[],components:{},id:minecraft:chest,x:35,y:64,z:-3} {Items:[]} {Items:[],components:{},id:minecraft:chest}' TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-31-1-2.

 COPY CORETEST.
