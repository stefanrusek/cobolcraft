*> Test of 31 section 12 (BarrelBlockEntity; T0863): 27 slots and the default name, Items always written even when empty, the sound offset
*> half a unit along FACING (all six facings), and no lid animation or block event (the counter hooks are in test 8).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-1-12.
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
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 5.
 01 WS-T                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BARREL              BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-OUT                 PIC X(8192).
 01 WS-K32                 PIC X(32).
 01 WS-SIZE                BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 1.
 01 WS-PARAM               BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE "minecraft:barrel" TO WS-KEY
     MOVE 16 TO WS-LEN
     MOVE 26 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-BARREL

     MOVE "acceptance US12 31-1§12 barrel: 27 slots, container.barrel, an empty barrel still writes Items, no block event 1 handling" TO TL-CASE
     CALL "BE-CONTAINER-SIZE" USING WS-T WS-SIZE
     CALL "BE-DEFAULT-NAME" USING WS-T WS-K32 WS-LEN
     MOVE WS-SIZE TO WS-EDIT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-BARREL WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-PTR
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-TYPE10 WS-OUT WS-PTR
     CALL "PB-FREE" USING PB-BUFFER
     CALL "BE-TRIGGER-EVENT" USING WS-BARREL WS-EVENT WS-PARAM WS-HANDLED
     MOVE WS-HANDLED TO WS-EDIT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " WS-K32(1:WS-LEN) " " WS-OUT(1:WS-PTR) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "27 container.barrel {Items:[],components:{},id:minecraft:barrel,x:5,y:70,z:5} 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§12 barrel: the sound position is the block centre plus half a unit along FACING (down, up, north, south, west, east)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-FACING FROM 0 BY 1 UNTIL WS-FACING > 5
         CALL "BE-BARREL-SOUND" USING WS-FACING WS-HX WS-HY WS-HZ
         MOVE WS-HX TO WS-EDIT
         MOVE WS-HY TO WS-EDIT2
         MOVE WS-HZ TO WS-EDIT3
         STRING FUNCTION TRIM(WS-EDIT) "," FUNCTION TRIM(WS-EDIT2) "," FUNCTION TRIM(WS-EDIT3) " " DELIMITED BY SIZE
             INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE "0,-1,0 0,1,0 0,0,-1 0,0,1 -1,0,0 1,0,0" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-31-1-12.

 COPY CORETEST.
