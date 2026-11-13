*> Test of 31-8 section 5, Calibrated sculk sensor (core/src/be-31-8.cob; T0975): radius, active ticks, the signal rule and the shared keys.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-8-5.
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
 01 WS-TAB2.
    05 WS-TV2            BINARY-LONG OCCURS 64 TIMES.
 01 WS-TAB3.
    05 WS-TV3            BINARY-LONG OCCURS 192 TIMES.
 01 WS-LONG1              BINARY-DOUBLE.
 01 WS-LONG2              BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-8§5 Calibrated sculk sensor: differences (3.3, 5): listener radius 8 (sensor), 16 (calibrated sensor), 8 (shrieker); active ticks 30 and 10; the output is 0 toward the facing direction, else the power" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 34 TO WS-A
     CALL "BE8-RADIUS" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 35 TO WS-A
     CALL "BE8-RADIUS" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 37 TO WS-A
     CALL "BE8-RADIUS" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     CALL "BE8-ACTIVE-TICKS" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     CALL "BE8-ACTIVE-TICKS" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 9 TO WS-B
     CALL "BE8-CAL-SIGNAL" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 9 TO WS-B
     CALL "BE8-CAL-SIGNAL" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "8 16 8 30 10 0 9" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§5 Calibrated sculk sensor: worked values (5): at radius 16 the strength is 15 at distance 0, 12 at 4 and 1 at 16" TO TL-CASE
     PERFORM BEGIN-CASE
     COMPUTE WS-FS1 = 0
     MOVE 16 TO WS-A
     CALL "BE8-STRENGTH" USING WS-FS1 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 4
     MOVE 16 TO WS-A
     CALL "BE8-STRENGTH" USING WS-FS1 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-FS1 = 16
     MOVE 16 TO WS-A
     CALL "BE8-STRENGTH" USING WS-FS1 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "15 12 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§5 Calibrated sculk sensor: keys (5): the calibrated sensor has the sensor keys (last_vibration_frequency, listener)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:calibrated_sculk_sensor" TO WS-KEY
     MOVE 33 TO WS-SVL
     MOVE 35 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:calibrated_sculk_sensor" TO WS-KEY
     MOVE 33 TO WS-SVL
     MOVE 35 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 2)
     MOVE "minecraft:step" TO BE-XT(WS-IDX, 1)
     MOVE 14 TO BE-XI(WS-IDX, 3)
     COMPUTE BE-XF(WS-IDX, 1) = 5.0
     COMPUTE BE-XD(WS-IDX, 1) = 10.5
     COMPUTE BE-XD(WS-IDX, 2) = 64.0
     COMPUTE BE-XD(WS-IDX, 3) = 20.5
     MOVE 1 TO BE-XI(WS-IDX, 4)
     MOVE 1 TO BE-UUID(WS-IDX, 1)
     MOVE 2 TO BE-UUID(WS-IDX, 2)
     MOVE 3 TO BE-UUID(WS-IDX, 3)
     MOVE 4 TO BE-UUID(WS-IDX, 4)
     MOVE 3 TO BE-XI(WS-IDX, 6)
     MOVE 1 TO BE-XI(WS-IDX, 1)
     MOVE WS-IDX TO WS-U
     MOVE "minecraft:calibrated_sculk_sensor" TO WS-KEY
     MOVE 33 TO WS-SVL
     MOVE 35 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE WS-IDX TO WS-Q
     MOVE WS-U TO WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-Q PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE WS-Q TO WS-IDX
     PERFORM SAVE-RENDER
     MOVE "{last_vibration_frequency:0,listener:{selector:{tick:-1},event_delay:0}} {last_vibration_frequency:1" &
         ",listener:{event:{game_event:minecraft:step,distance:5.000,pos:[10.500,64.000,20.500],source:I[1,2,3" &
         ",4]},selector:{tick:-1},event_delay:3}}" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-8-5.

 COPY CORETEST.
